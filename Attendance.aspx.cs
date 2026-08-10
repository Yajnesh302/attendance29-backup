using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Attendance : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
            }
        }

        private static void EnsureGlobalEmployeesExist()
        {
            try
            {
                string connStr = DBHelper.GetAttendanceDBConnection();
                
                // Ensure default 'GLOBAL' exists
                string checkQuery = "SELECT COUNT(*) FROM Employees WHERE MasterId = 'GLOBAL'";
                object countObj = DBHelper.ExecuteScalar(connStr, checkQuery);
                int count = countObj != null && countObj != DBNull.Value ? Convert.ToInt32(countObj) : 0;
                if (count == 0)
                {
                    string insertQuery = @"
                        INSERT INTO Employees (MasterId, ID, Name, Department, TierId, Status, LeaveBalance) 
                        VALUES ('GLOBAL', 'GLOBAL', 'GLOBAL Adjustment', NULL, NULL, 'System', 0)";
                    DBHelper.ExecuteNonQuery(connStr, insertQuery);
                }

                // Ensure tier-specific 'GLOBAL_<TierId>' exists for all tiers
                string catQuery = "SELECT Id, TierName FROM Tiers";
                DataTable dtCats = DBHelper.ExecuteQuery(connStr, catQuery);
                foreach (DataRow row in dtCats.Rows)
                {
                    string tierId = row["Id"].ToString();
                    string tierName = row["TierName"].ToString();
                    string empId = "GLOBAL_" + tierId;
                    string checkCatQuery = "SELECT COUNT(*) FROM Employees WHERE MasterId = :EmpID";
                    object countCatObj = DBHelper.ExecuteScalar(connStr, checkCatQuery, new OracleParameter("EmpID", empId));
                    int countCat = countCatObj != null && countCatObj != DBNull.Value ? Convert.ToInt32(countCatObj) : 0;
                    if (countCat == 0)
                    {
                        string insertQuery = @"
                            INSERT INTO Employees (MasterId, ID, Name, Department, TierId, Status, LeaveBalance) 
                            VALUES (:MasterId, :ID, :Name, NULL, :TierId, 'System', 0)";
                        DBHelper.ExecuteNonQuery(connStr, insertQuery,
                            new OracleParameter("MasterId", empId),
                            new OracleParameter("ID", empId),
                            new OracleParameter("Name", "GLOBAL Adjustment (" + tierName + ")"),
                            new OracleParameter("TierId", Convert.ToInt32(tierId)));
                    }
                }
                // Fix status for any existing GLOBAL records in Employees table
                DBHelper.ExecuteNonQuery(connStr, "UPDATE Employees SET Status = 'System' WHERE MasterId LIKE 'GLOBAL%'");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error ensuring GLOBAL employees exist: " + ex.Message);
            }
        }

        [WebMethod]
        public static string GetData(int year, int month, string category, string division, string search)
        {
            EnsureGlobalEmployeesExist();
            // Note: Use session to filter by division if user is not admin
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            string sessionDivision = HttpContext.Current.Session["Division"]?.ToString() ?? "";

            string empQuery = @"SELECT e.MasterId, e.ID, e.Name, e.Department, e.TierId,
                                       (SELECT mc.Name || ' > ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category, 
                                       e.JoinDate, e.ResignDate, e.ContractEndDate, e.LeaveBalance, e.PrevLeaveBalance, ee.ContractPeriodId AS CurrentContractPeriodId
                                FROM Employees e
                                LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                                 WHERE e.MasterId NOT LIKE 'GLOBAL%' AND e.Status <> 'System'
                                   AND (((e.Status IN ('Active', 'Upgraded', 'Downgraded', 'Transferred') AND (e.ContractEndDate IS NULL OR (EXTRACT(YEAR FROM e.ContractEndDate) > :Year OR (EXTRACT(YEAR FROM e.ContractEndDate) = :Year AND EXTRACT(MONTH FROM e.ContractEndDate) >= :Month))))
                                    OR (e.Status = 'ContractEnded' AND (e.ContractEndDate IS NULL OR (EXTRACT(YEAR FROM e.ContractEndDate) > :Year OR (EXTRACT(YEAR FROM e.ContractEndDate) = :Year AND EXTRACT(MONTH FROM e.ContractEndDate) >= :Month))))
                                    OR (e.Status = 'Resigned' AND (EXTRACT(YEAR FROM e.ResignDate) > :Year OR (EXTRACT(YEAR FROM e.ResignDate) = :Year AND EXTRACT(MONTH FROM e.ResignDate) >= :Month)))))";
            
            List<OracleParameter> parameters = new List<OracleParameter>
            {
                new OracleParameter("Year", year),
                new OracleParameter("Month", month + 1)
            };

            if (!string.IsNullOrEmpty(category) && category != "All")
            {
                empQuery += " AND e.TierId = :Cat";
                parameters.Add(new OracleParameter("Cat", Convert.ToInt32(category)));
            }

            if (role != 4)
            {
                string userPcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
                List<int> visibleTiers = DBHelper.GetVisibleTierIds(userPcno, role);
                if (visibleTiers.Count > 0)
                {
                    List<string> tierParams = new List<string>();
                    for (int i = 0; i < visibleTiers.Count; i++)
                    {
                        string paramName = "VTierId" + i;
                        tierParams.Add(":" + paramName);
                        parameters.Add(new OracleParameter(paramName, visibleTiers[i]));
                    }
                    empQuery += " AND e.TierId IN (" + string.Join(", ", tierParams) + ")";
                }
                else
                {
                    empQuery += " AND 1=0";
                }
            }

            if (role != 1 && role != 4)
            {
                var allowedDivs = HttpContext.Current.Session["AllowedDivisions"] as List<string>;
                if (allowedDivs != null && allowedDivs.Contains(division))
                {
                    empQuery += " AND e.Department LIKE :Div";
                    parameters.Add(new OracleParameter("Div", division + "%"));
                }
                else
                {
                    if (allowedDivs != null && allowedDivs.Count > 0)
                    {
                        List<string> divClauses = new List<string>();
                        for (int i = 0; i < allowedDivs.Count; i++)
                        {
                            string paramName = "Div" + i;
                            divClauses.Add("e.Department LIKE :" + paramName);
                            parameters.Add(new OracleParameter(paramName, allowedDivs[i] + "%"));
                        }
                        empQuery += " AND (" + string.Join(" OR ", divClauses) + ")";
                    }
                    else
                    {
                        empQuery += " AND 1=0";
                    }
                }
            }
            else
            {
                // Admin can filter by division
                if (!string.IsNullOrEmpty(division) && division != "All")
                {
                    empQuery += " AND e.Department = :Div";
                    parameters.Add(new OracleParameter("Div", division));
                }
            }

            if (!string.IsNullOrEmpty(search))
            {
                empQuery += " AND (UPPER(e.ID) LIKE UPPER(:Search) OR UPPER(e.Name) LIKE UPPER(:Search))";
                parameters.Add(new OracleParameter("Search", "%" + search + "%"));
            }

            empQuery += " ORDER BY e.Department ASC, e.Name ASC";

            DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, parameters.ToArray());

            DateTime firstDay = new DateTime(year, month + 1, 1);
            DateTime lastDay = firstDay.AddMonths(1).AddDays(-1);

            // Fetch engagements overlapping the selected month/year (moved up to determine contract balances)
            string engQuery = @"
                SELECT ee.EmpID, ee.StartDate, ee.EndDate, cp.Status, cp.EndDate AS CpEndDate, ee.ContractPeriodId
                FROM EmployeeEngagements ee
                JOIN ContractPeriods cp ON ee.ContractPeriodId = cp.Id
                WHERE (ee.StartDate <= :LastDay AND (ee.EndDate IS NULL OR ee.EndDate >= :FirstDay))";
            
            DataTable dtEng = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), engQuery,
                new OracleParameter("LastDay", lastDay),
                new OracleParameter("FirstDay", firstDay));

            // Query historical leaves taken prior to the target month grouped by EmpID and ContractPeriodId
            string histQuery = @"
                SELECT a.EmpID,
                       ee_past.ContractPeriodId,
                       SUM(CASE WHEN (a.StatusValue = 0 AND a.LeaveType = 'Paid') OR a.LeaveType = 'Paired Paid' THEN 1 ELSE 0 END) as PrevFull,
                       SUM(CASE WHEN a.StatusValue = 0.5 THEN 1 ELSE 0 END) as PrevHalf
                FROM Attendance a
                JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                  AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                  AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                WHERE ((a.Year < :TY) OR (a.Year = :TY AND a.Month < :TM))
                  AND a.EmpID NOT LIKE 'GLOBAL%'
                  AND a.Day > 0
                GROUP BY a.EmpID, ee_past.ContractPeriodId";
            
            DataTable dtHist = null;
            try
            {
                dtHist = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), histQuery,
                    new OracleParameter("TY", year),
                    new OracleParameter("TM", month));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching historical leave totals in GetData: " + ex.Message);
            }

            Dictionary<string, Dictionary<string, int>> prevHalfCounts = new Dictionary<string, Dictionary<string, int>>();
            string halfCountQuery = @"
                SELECT a.EmpID, ee_past.ContractPeriodId, COUNT(*) AS PrevHalfCount
                FROM Attendance a
                JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                  AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                  AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                JOIN EmployeeEngagements ee_curr ON a.EmpID = ee_curr.EmpID
                  AND ee_curr.StartDate <= :LastDay
                  AND (ee_curr.EndDate IS NULL OR ee_curr.EndDate >= :FirstDay)
                JOIN (
                    SELECT ee.EmpID, MIN(ee.StartDate) AS StintStartDate
                    FROM EmployeeEngagements ee
                    WHERE ee.StartDate > COALESCE(
                        (SELECT MAX(ex.EndDate) FROM EmployeeEngagements ex WHERE ex.EmpID = ee.EmpID AND UPPER(ex.EndReason) = 'RESIGNED'),
                        TO_DATE('1900-01-01', 'YYYY-MM-DD')
                    )
                    GROUP BY ee.EmpID
                ) stint ON stint.EmpID = a.EmpID
                WHERE (ee_past.ContractPeriodId = ee_curr.ContractPeriodId OR (ee_past.ContractPeriodId IS NULL AND ee_curr.ContractPeriodId IS NULL AND ee_past.TierId = ee_curr.TierId))
                  AND a.LeaveType IN ('Carried', 'Paired Paid', 'Paired Unpaid', 'Pending Pairing')
                  AND a.EmpID NOT LIKE 'GLOBAL%'
                  AND a.Day > 0
                  AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= stint.StintStartDate
                  AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') < :FirstDay
                GROUP BY a.EmpID, ee_past.ContractPeriodId";
            
            try
            {
                DataTable dtHalf = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), halfCountQuery,
                    new OracleParameter("LastDay", lastDay),
                    new OracleParameter("FirstDay", firstDay));
                foreach (DataRow row in dtHalf.Rows)
                {
                    string id = row["EmpID"].ToString();
                    string cpId = row["ContractPeriodId"].ToString();
                    if (!prevHalfCounts.ContainsKey(id))
                    {
                        prevHalfCounts[id] = new Dictionary<string, int>();
                    }
                    prevHalfCounts[id][cpId] = Convert.ToInt32(row["PrevHalfCount"]);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching historical half-day counts in GetData: " + ex.Message);
            }

            List<object> emps = new List<object>();
            foreach(DataRow dr in dtEmp.Rows)
            {
                string masterId = dr["MasterId"].ToString();
                double initialBalance = dr["LeaveBalance"] != DBNull.Value ? Convert.ToDouble(dr["LeaveBalance"]) : 0.0;
                double prevBalance = dr["PrevLeaveBalance"] != DBNull.Value ? Convert.ToDouble(dr["PrevLeaveBalance"]) : 0.0;
                object currentCpId = dr["CurrentContractPeriodId"];

                // Fetch past contract period
                int? pastCpId = null;
                string pastCpSql = @"
                    SELECT ContractPeriodId 
                    FROM EmployeeEngagements 
                    WHERE EmpID = :EmpID 
                      AND (ContractPeriodId != :CurrCpId OR :CurrCpId IS NULL)
                    ORDER BY StartDate DESC";
                object resPast = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), pastCpSql,
                    new OracleParameter("EmpID", masterId),
                    new OracleParameter("CurrCpId", currentCpId != DBNull.Value ? currentCpId : DBNull.Value));
                if (resPast != null && resPast != DBNull.Value)
                {
                    pastCpId = Convert.ToInt32(resPast);
                }

                double resolvedLeaveBalance = initialBalance;
                double resolvedPrevBalance = prevBalance;
                var creditsList = new List<object>();

                string creditSql = "SELECT ContractPeriodId, Amount, EffectiveDate FROM EmployeeLeaveCredits WHERE EmpID = :EmpID";
                DataTable dtCredits = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), creditSql, new OracleParameter("EmpID", masterId));
                
                DateTime monthLastDay = new DateTime(year, month + 1, 1).AddMonths(1).AddDays(-1);

                if (dtCredits.Rows.Count > 0)
                {
                    foreach (DataRow cr in dtCredits.Rows)
                    {
                        creditsList.Add(new {
                            ContractPeriodId = Convert.ToInt32(cr["ContractPeriodId"]),
                            Amount = Convert.ToDouble(cr["Amount"]),
                            EffectiveDate = Convert.ToDateTime(cr["EffectiveDate"]).ToString("yyyy-MM-dd")
                        });
                    }

                    // Calculate current Cp balance active in target month
                    if (currentCpId != DBNull.Value)
                    {
                        int currCpId = Convert.ToInt32(currentCpId);
                        double currSum = 0;
                        bool hasCredits = false;
                        foreach (DataRow cr in dtCredits.Rows)
                        {
                            if (Convert.ToInt32(cr["ContractPeriodId"]) == currCpId)
                            {
                                hasCredits = true;
                                DateTime effDate = Convert.ToDateTime(cr["EffectiveDate"]);
                                if (effDate <= monthLastDay)
                                {
                                    currSum += Convert.ToDouble(cr["Amount"]);
                                }
                            }
                        }
                        if (hasCredits)
                        {
                            resolvedLeaveBalance = currSum;
                        }
                    }

                    // Calculate past Cp balance active in target month
                    if (pastCpId.HasValue)
                    {
                        double pastSum = 0;
                        bool hasPastCredits = false;
                        foreach (DataRow cr in dtCredits.Rows)
                        {
                            if (Convert.ToInt32(cr["ContractPeriodId"]) == pastCpId.Value)
                            {
                                hasPastCredits = true;
                                DateTime effDate = Convert.ToDateTime(cr["EffectiveDate"]);
                                if (effDate <= monthLastDay)
                                {
                                    pastSum += Convert.ToDouble(cr["Amount"]);
                                }
                            }
                        }
                        if (hasPastCredits)
                        {
                            resolvedPrevBalance = pastSum;
                        }
                    }
                }

                // Build PrevLeaves dictionary for this employee
                var prevLeaves = new Dictionary<string, double>();
                if (dtHist != null)
                {
                    var histRows = dtHist.Select($"EmpID = '{masterId}'");
                    foreach (var hr in histRows)
                    {
                        string cpIdKey = hr["ContractPeriodId"] != DBNull.Value ? hr["ContractPeriodId"].ToString() : "null";
                        double full = hr["PrevFull"] != DBNull.Value ? Convert.ToDouble(hr["PrevFull"]) : 0;
                        prevLeaves[cpIdKey] = full;
                    }
                }

                // Find active CP ID for the employee in the selected month
                string activeCpIdStr = "null";
                double activeInitialBalance = resolvedLeaveBalance;
                var engRows = dtEng.Select($"EmpID = '{masterId}'");
                if (engRows.Length > 0)
                {
                    // Find the one that overlaps the month. If multiple, sort by StartDate desc and take the first.
                    DataRow latestEng = null;
                    DateTime maxStart = DateTime.MinValue;
                    foreach (var er in engRows)
                    {
                        DateTime start = Convert.ToDateTime(er["StartDate"]);
                        if (start > maxStart)
                        {
                            maxStart = start;
                            latestEng = er;
                        }
                    }
                    if (latestEng != null && latestEng["ContractPeriodId"] != DBNull.Value)
                    {
                        int cpId = Convert.ToInt32(latestEng["ContractPeriodId"]);
                        activeCpIdStr = cpId.ToString();
                        
                        // Check if it matches current engagement
                        bool isCurrent = false;
                        if (currentCpId != DBNull.Value && Convert.ToInt32(currentCpId) == cpId)
                        {
                            isCurrent = true;
                        }
                        activeInitialBalance = isCurrent ? resolvedLeaveBalance : resolvedPrevBalance;
                    }
                }

                double prevUsed = prevLeaves.ContainsKey(activeCpIdStr) ? prevLeaves[activeCpIdStr] : 0.0;
                double openingBalance = activeInitialBalance - prevUsed;

                emps.Add(new { 
                    MasterId = masterId,
                    ID = dr["ID"].ToString(), 
                    Name = dr["Name"].ToString(), 
                    Dept = dr["Department"].ToString(),
                    Category = dr["Category"].ToString(),
                    TierId = dr["TierId"] != DBNull.Value ? (object)Convert.ToInt32(dr["TierId"]) : null,
                    JoinDate = dr["JoinDate"] != DBNull.Value ? Convert.ToDateTime(dr["JoinDate"]).ToString("yyyy-MM-dd") : null,
                    ResignDate = dr["ResignDate"] != DBNull.Value ? Convert.ToDateTime(dr["ResignDate"]).ToString("yyyy-MM-dd") : null,
                    ContractEndDate = dr["ContractEndDate"] != DBNull.Value ? Convert.ToDateTime(dr["ContractEndDate"]).ToString("yyyy-MM-dd") : null,
                    LeaveBalance = activeInitialBalance,
                    PrevLeaveBalance = resolvedPrevBalance,
                    CurrentLeaveBalance = resolvedLeaveBalance,
                    CurrentContractPeriodId = currentCpId != DBNull.Value ? (object)Convert.ToInt32(currentCpId) : null,
                    OpeningBalance = openingBalance,
                    PrevLeaves = prevLeaves,
                    PrevHalfCounts = prevHalfCounts.ContainsKey(masterId) ? prevHalfCounts[masterId] : new Dictionary<string, int>(),
                    Credits = creditsList
                });
            }

            string attQuery = "SELECT EmpID, Day, StatusValue, IsHoliday, LeaveType, AutoSat, Remarks FROM Attendance WHERE Year = :Year AND Month = :Month";
            DataTable dtAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), attQuery,
                new OracleParameter("Year", year),
                new OracleParameter("Month", month));

            // Structure: { EmpID: { Day: { Val, Holiday, Leave } } }
            Dictionary<string, Dictionary<string, object>> attDict = new Dictionary<string, Dictionary<string, object>>();
            foreach(DataRow dr in dtAtt.Rows)
            {
                string empId = dr["EmpID"].ToString();
                int day = Convert.ToInt32(dr["Day"]);
                float? val = dr["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(dr["StatusValue"]);
                bool isHoliday = Convert.ToInt32(dr["IsHoliday"]) == 1;
                bool autoSat = dr.Table.Columns.Contains("AutoSat") && dr["AutoSat"] != DBNull.Value ? Convert.ToInt32(dr["AutoSat"]) == 1 : false;
                string leave = dr["LeaveType"].ToString();
                string remarks = dr.Table.Columns.Contains("Remarks") && dr["Remarks"] != DBNull.Value ? dr["Remarks"].ToString() : "";

                if (!attDict.ContainsKey(empId))
                    attDict[empId] = new Dictionary<string, object>();

                attDict[empId][day.ToString()] = new { Val = val, Holiday = isHoliday, Leave = leave, AutoSat = autoSat, Remarks = remarks };
            }

            // Fetch previous month trailing data for calcSat
            int prevMonth = month == 0 ? 11 : month - 1;
            int prevYear = month == 0 ? year - 1 : year;
            
            string prevAttQuery = "SELECT EmpID, Day, StatusValue, IsHoliday, LeaveType, AutoSat, Remarks FROM Attendance WHERE Year = :PYear AND Month = :PMonth AND Day >= 24";
            DataTable dtPrevAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), prevAttQuery,
                new OracleParameter("PYear", prevYear),
                new OracleParameter("PMonth", prevMonth));

            Dictionary<string, Dictionary<string, object>> prevAttDict = new Dictionary<string, Dictionary<string, object>>();
            foreach(DataRow dr in dtPrevAtt.Rows)
            {
                string empId = dr["EmpID"].ToString();
                int day = Convert.ToInt32(dr["Day"]);
                float? val = dr["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(dr["StatusValue"]);
                bool isHoliday = Convert.ToInt32(dr["IsHoliday"]) == 1;
                bool autoSat = dr.Table.Columns.Contains("AutoSat") && dr["AutoSat"] != DBNull.Value ? Convert.ToInt32(dr["AutoSat"]) == 1 : false;
                string leave = dr["LeaveType"].ToString();
                string remarks = dr.Table.Columns.Contains("Remarks") && dr["Remarks"] != DBNull.Value ? dr["Remarks"].ToString() : "";

                if (!prevAttDict.ContainsKey(empId))
                    prevAttDict[empId] = new Dictionary<string, object>();

                prevAttDict[empId][day.ToString()] = new { Val = val, Holiday = isHoliday, Leave = leave, AutoSat = autoSat, Remarks = remarks };
            }

            // Construct engagements list from already queried dtEng
            List<object> engagements = new List<object>();
            foreach (DataRow dr in dtEng.Rows)
            {
                DateTime? eeEndDate = dr["EndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["EndDate"]) : null;
                DateTime? cpEndDate = dr["CpEndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["CpEndDate"]) : null;
                
                DateTime? effectiveEndDate = null;
                if (eeEndDate.HasValue && cpEndDate.HasValue)
                {
                    effectiveEndDate = eeEndDate.Value < cpEndDate.Value ? eeEndDate.Value : cpEndDate.Value;
                }
                else if (eeEndDate.HasValue)
                {
                    effectiveEndDate = eeEndDate;
                }
                else if (cpEndDate.HasValue)
                {
                    effectiveEndDate = cpEndDate;
                }

                engagements.Add(new {
                    EmpID = dr["EmpID"].ToString(),
                    StartDate = Convert.ToDateTime(dr["StartDate"]).ToString("yyyy-MM-dd"),
                    EndDate = effectiveEndDate.HasValue ? effectiveEndDate.Value.ToString("yyyy-MM-dd") : null,
                    Status = dr["Status"] != DBNull.Value ? dr["Status"].ToString() : "Active",
                    ContractPeriodId = dr["ContractPeriodId"] != DBNull.Value ? (object)Convert.ToInt32(dr["ContractPeriodId"]) : null
                });
            }
            // Fetch future carried/paired leaves for target month's contract period
            string futQuery = @"
                SELECT a.EmpID, a.Year, a.Month, a.Day, a.StatusValue, a.LeaveType, ee_past.ContractPeriodId
                FROM Attendance a
                JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                  AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                  AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                JOIN EmployeeEngagements ee_curr ON a.EmpID = ee_curr.EmpID
                  AND ee_curr.StartDate <= :LastDay
                  AND (ee_curr.EndDate IS NULL OR ee_curr.EndDate >= :FirstDay)
                WHERE (ee_past.ContractPeriodId = ee_curr.ContractPeriodId OR (ee_past.ContractPeriodId IS NULL AND ee_curr.ContractPeriodId IS NULL AND ee_past.TierId = ee_curr.TierId))
                  AND a.LeaveType IN ('Carried', 'Paired Paid', 'Paired Unpaid', 'Pending Pairing')
                  AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') > :LastDay
                ORDER BY a.Year ASC, a.Month ASC, a.Day ASC";

            Dictionary<string, List<object>> futureCarried = new Dictionary<string, List<object>>();
            try
            {
                DataTable dtFut = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), futQuery,
                    new OracleParameter("LastDay", lastDay),
                    new OracleParameter("FirstDay", firstDay));
                foreach (DataRow row in dtFut.Rows)
                {
                    string id = row["EmpID"].ToString();
                    int y = Convert.ToInt32(row["Year"]);
                    int m = Convert.ToInt32(row["Month"]);
                    int d = Convert.ToInt32(row["Day"]);
                    float? val = row["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(row["StatusValue"]);
                    string leave = row["LeaveType"] == DBNull.Value ? "" : row["LeaveType"].ToString();
                    int? cpIdVal = null;
                    if (row["ContractPeriodId"] != DBNull.Value)
                    {
                        cpIdVal = Convert.ToInt32(row["ContractPeriodId"]);
                    }

                    if (!futureCarried.ContainsKey(id))
                    {
                        futureCarried[id] = new List<object>();
                    }
                    futureCarried[id].Add(new { Year = y, Month = m, Day = d, Val = val, Leave = leave, ContractPeriodId = (object)cpIdVal });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching future carried leaves: " + ex.Message);
            }

            List<string> recentRemarks = new List<string>();
            try
            {
                string remQuery = @"
                    SELECT Remarks FROM (
                        SELECT Remarks, COUNT(*) as cnt 
                        FROM Attendance 
                        WHERE Remarks IS NOT NULL AND TRIM(Remarks) IS NOT NULL 
                        GROUP BY Remarks 
                        ORDER BY cnt DESC
                    ) WHERE ROWNUM <= 15";
                DataTable dtRem = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), remQuery);
                foreach (DataRow row in dtRem.Rows)
                {
                    recentRemarks.Add(row["Remarks"].ToString());
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching recent remarks: " + ex.Message);
            }

            // Load POC edit remarks for this month (grouped by EmpID > Day > list of entries)
            // Structure: { "10001": { "5": [ { Remark, CreatedBy, CreatedAt } ] } }
            Dictionary<string, Dictionary<string, List<object>>> pocEditRemarks = new Dictionary<string, Dictionary<string, List<object>>>();
            try
            {
                EnsureAttPocEditRemarksTable();
                string pocQuery = "SELECT EmpID, Day, Remark, CreatedBy, CreatedAt FROM AttPocEditRemarks WHERE Year = :Year AND Month = :Month ORDER BY CreatedAt ASC";
                DataTable dtPoc = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), pocQuery,
                    new OracleParameter("Year", year),
                    new OracleParameter("Month", month));
                foreach (DataRow row in dtPoc.Rows)
                {
                    string eid = row["EmpID"].ToString();
                    string dayKey = row["Day"].ToString();
                    string remark = row["Remark"].ToString();
                    string createdBy = row["CreatedBy"].ToString();
                    string createdAt = row["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(row["CreatedAt"]).ToString("yyyy-MM-dd HH:mm") : "";
                    if (!pocEditRemarks.ContainsKey(eid)) pocEditRemarks[eid] = new Dictionary<string, List<object>>();
                    if (!pocEditRemarks[eid].ContainsKey(dayKey)) pocEditRemarks[eid][dayKey] = new List<object>();
                    pocEditRemarks[eid][dayKey].Add(new { Remark = remark, CreatedBy = createdBy, CreatedAt = createdAt });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching POC edit remarks: " + ex.Message);
            }

            int editDaysAllowed = 0;
            int editMode = 0;
            if (role != 1 && role != 4)
            {
                string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
                string qDays = @"
                    SELECT COALESCE(MAX(mc.EditDaysAllowed), 0) AS EditDaysAllowed,
                           COALESCE(MAX(mc.EditMode), 0) AS EditMode
                    FROM UserTiers ut 
                    JOIN Tiers t ON ut.TierId = t.Id 
                    JOIN MainCategory mc ON t.MainCategoryId = mc.Id 
                    WHERE ut.PCNO = :PCNO";
                DataTable dtMode = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), qDays, new OracleParameter("PCNO", pcno));
                if (dtMode.Rows.Count > 0)
                {
                    editDaysAllowed = Convert.ToInt32(dtMode.Rows[0]["EditDaysAllowed"]);
                    editMode = Convert.ToInt32(dtMode.Rows[0]["EditMode"]);
                }
            }

            var result = new { Employees = emps, Attendance = attDict, PrevAttendance = prevAttDict, Engagements = engagements, FutureCarried = futureCarried, RecentRemarks = recentRemarks, EditDaysAllowed = editDaysAllowed, EditMode = editMode, PocEditRemarks = pocEditRemarks };
            return new JavaScriptSerializer().Serialize(result);
        }

        [WebMethod]
        public static string SaveData(int year, int month, string category, string data, string futureUpdates = null, string pocEditRemarks = null)
        {
            EnsureGlobalEmployeesExist();
            var dict = new JavaScriptSerializer().Deserialize<Dictionary<string, Dictionary<string, Dictionary<string, object>>>>(data);
            var futDict = string.IsNullOrEmpty(futureUpdates) || futureUpdates == "{}" ? null : new JavaScriptSerializer().Deserialize<Dictionary<string, Dictionary<string, Dictionary<string, object>>>>(futureUpdates);

            string validationError;
            if (!ValidateLeaveBalances(DBHelper.GetAttendanceDBConnection(), dict, futDict, year, month, out validationError))
            {
                var errObj = new { status = "error", message = validationError };
                return new JavaScriptSerializer().Serialize(errObj);
            }

            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            DateTime today = DateTime.Today;

            int editDaysAllowed = 0;
            int editMode = 0;
            if (role != 1 && role != 4)
            {
                string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
                string qDays = @"
                    SELECT COALESCE(MAX(mc.EditDaysAllowed), 0) AS EditDaysAllowed,
                           COALESCE(MAX(mc.EditMode), 0) AS EditMode
                    FROM UserTiers ut 
                    JOIN Tiers t ON ut.TierId = t.Id 
                    JOIN MainCategory mc ON t.MainCategoryId = mc.Id 
                    WHERE ut.PCNO = :PCNO";
                DataTable dtMode = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), qDays, new OracleParameter("PCNO", pcno));
                if (dtMode.Rows.Count > 0)
                {
                    editDaysAllowed = Convert.ToInt32(dtMode.Rows[0]["EditDaysAllowed"]);
                    editMode = Convert.ToInt32(dtMode.Rows[0]["EditMode"]);
                }
            }

            DateTime minAllowedDate = today.AddDays(-editDaysAllowed);

            foreach (var empKvp in dict)
            {
                string empId = empKvp.Key;
                if (empId.StartsWith("GLOBAL", StringComparison.OrdinalIgnoreCase))
                {
                    EnsureGlobalEmployeeExists(empId);
                }

                foreach (var dayKvp in empKvp.Value)
                {
                    int day = Convert.ToInt32(dayKvp.Key);
                    
                    if (role != 1 && role != 4)
                    {
                        try
                        {
                            DateTime checkDate = new DateTime(year, month + 1, day);
                            if (editMode == 1)
                            {
                                // Current Month Only (Till Date): must be in current year and month AND <= today
                                if (checkDate > today || checkDate.Year != today.Year || checkDate.Month != today.Month)
                                {
                                    continue; // Skip saving days outside current month till date for non-admins
                                }
                            }
                            else
                            {
                                // Days-based Window
                                if (checkDate > today || checkDate < minAllowedDate)
                                {
                                    continue; // Skip saving days outside allowed edit window for non-admins
                                }
                            }

                            if (checkDate.DayOfWeek == DayOfWeek.Saturday)
                            {
                                continue; // Skip Saturday edits for non-admins
                            }
                        }
                        catch
                        {
                            // Skip on invalid date
                            continue;
                        }
                    }

                    var cell = dayKvp.Value;
                    
                    object val = cell.ContainsKey("Val") && cell["Val"] != null ? cell["Val"] : DBNull.Value;
                    bool isHoliday = cell.ContainsKey("Holiday") && cell["Holiday"] != null ? Convert.ToBoolean(cell["Holiday"]) : false;
                    string leave = cell.ContainsKey("Leave") && cell["Leave"] != null ? cell["Leave"].ToString() : "";
                    bool autoSat = cell.ContainsKey("AutoSat") && cell["AutoSat"] != null ? Convert.ToBoolean(cell["AutoSat"]) : false;
                    string remarks = cell.ContainsKey("Remarks") && cell["Remarks"] != null ? cell["Remarks"].ToString() : "";

                    string query = @"
                        MERGE INTO Attendance t
                        USING (SELECT :EmpID as EmpID, :Year as Year, :Month as Month, :Day as Day, :Val as StatusValue, :Holiday as IsHoliday, :Leave as LeaveType, :AutoSat as AutoSat, :Remarks as Remarks FROM DUAL) s
                        ON (t.EmpID = s.EmpID AND t.Year = s.Year AND t.Month = s.Month AND t.Day = s.Day)
                        WHEN MATCHED THEN
                          UPDATE SET t.StatusValue = s.StatusValue, t.IsHoliday = s.IsHoliday, t.LeaveType = s.LeaveType, t.AutoSat = s.AutoSat, t.Remarks = s.Remarks
                        WHEN NOT MATCHED THEN
                          INSERT (EmpID, Year, Month, Day, StatusValue, IsHoliday, LeaveType, AutoSat, Remarks)
                          VALUES (s.EmpID, s.Year, s.Month, s.Day, s.StatusValue, s.IsHoliday, s.LeaveType, s.AutoSat, s.Remarks)";
                                     
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query,
                        new OracleParameter("EmpID", empId),
                        new OracleParameter("Year", year),
                        new OracleParameter("Month", month),
                        new OracleParameter("Day", day),
                        new OracleParameter("Val", val),
                        new OracleParameter("Holiday", isHoliday ? 1 : 0),
                        new OracleParameter("Leave", leave),
                        new OracleParameter("AutoSat", autoSat ? 1 : 0),
                        new OracleParameter("Remarks", remarks));
                }
            }

            if (futDict != null && futDict.Count > 0)
            {
                foreach (var empKvp in futDict)
                {
                    string empId = empKvp.Key;
                    if (empId.StartsWith("GLOBAL", StringComparison.OrdinalIgnoreCase))
                    {
                        EnsureGlobalEmployeeExists(empId);
                    }

                    foreach (var dateKvp in empKvp.Value)
                    {
                        var cell = dateKvp.Value;
                        int fYear = Convert.ToInt32(cell["Year"]);
                        int fMonth = Convert.ToInt32(cell["Month"]);
                        int fDay = Convert.ToInt32(cell["Day"]);
                        object val = cell.ContainsKey("Val") && cell["Val"] != null ? cell["Val"] : DBNull.Value;
                        string leave = cell.ContainsKey("Leave") && cell["Leave"] != null ? cell["Leave"].ToString() : "";

                        // Merge future attendance record
                        string futMergeQuery = @"
                            MERGE INTO Attendance t
                            USING (SELECT :EmpID as EmpID, :Year as Year, :Month as Month, :Day as Day, :Val as StatusValue, :Leave as LeaveType FROM DUAL) s
                            ON (t.EmpID = s.EmpID AND t.Year = s.Year AND t.Month = s.Month AND t.Day = s.Day)
                            WHEN MATCHED THEN
                              UPDATE SET t.StatusValue = s.StatusValue, t.LeaveType = s.LeaveType
                            WHEN NOT MATCHED THEN
                              INSERT (EmpID, Year, Month, Day, StatusValue, LeaveType, IsHoliday, AutoSat, Remarks)
                              VALUES (s.EmpID, s.Year, s.Month, s.Day, s.StatusValue, s.LeaveType, 0, 0, '')";

                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), futMergeQuery,
                            new OracleParameter("EmpID", empId),
                            new OracleParameter("Year", fYear),
                            new OracleParameter("Month", fMonth),
                            new OracleParameter("Day", fDay),
                            new OracleParameter("Val", val),
                            new OracleParameter("Leave", leave));
                    }
                }
            }

            // Save POC edit remarks if provided (Option B: bundled with save)
            if (!string.IsNullOrEmpty(pocEditRemarks) && pocEditRemarks != "{}" && pocEditRemarks != "null")
            {
                try
                {
                    EnsureAttPocEditRemarksTable();
                    string createdBy = HttpContext.Current.Session["PCNO"]?.ToString() ?? "Unknown";
                    // pocEditRemarks: { empId: { day: ["reason1", "reason2", ...] } }
                    var pocDict = new JavaScriptSerializer().Deserialize<Dictionary<string, Dictionary<string, List<string>>>>(pocEditRemarks);
                    string connStr = DBHelper.GetAttendanceDBConnection();
                    foreach (var empKvp in pocDict)
                    {
                        string eid = empKvp.Key;
                        foreach (var dayKvp in empKvp.Value)
                        {
                            int d = Convert.ToInt32(dayKvp.Key);
                            foreach (string remark in dayKvp.Value)
                            {
                                if (string.IsNullOrWhiteSpace(remark)) continue;
                                string insQuery = @"INSERT INTO AttPocEditRemarks (EmpID, Year, Month, Day, RemarkType, Remark, CreatedBy) 
                                    VALUES (:EmpID, :Year, :Month, :Day, 'POCEdit', :Remark, :CreatedBy)";
                                DBHelper.ExecuteNonQuery(connStr, insQuery,
                                    new OracleParameter("EmpID", eid),
                                    new OracleParameter("Year", year),
                                    new OracleParameter("Month", month),
                                    new OracleParameter("Day", d),
                                    new OracleParameter("Remark", remark),
                                    new OracleParameter("CreatedBy", createdBy));
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error saving POC edit remarks: " + ex.Message);
                    // Non-fatal: don't block attendance save if this fails
                }
            }

            try
            {
                RecalculateNextMonthSaturdays(year, month, category);
            }
            catch { }
            return "{\"status\":\"success\"}";
        }

        [WebMethod]
        public static string ClearPocEditRemark(string empId, int year, int month, int day)
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                return "{\"status\":\"error\", \"message\":\"Permission denied: Admin only.\"}";
            }

            try
            {
                EnsureAttPocEditRemarksTable();
                string connStr = DBHelper.GetAttendanceDBConnection();
                string delQuery = "DELETE FROM AttPocEditRemarks WHERE EmpID = :EmpID AND Year = :Year AND Month = :Month AND Day = :Day";
                DBHelper.ExecuteNonQuery(connStr, delQuery,
                    new OracleParameter("EmpID", empId),
                    new OracleParameter("Year", year),
                    new OracleParameter("Month", month),
                    new OracleParameter("Day", day));

                return "{\"status\":\"success\"}";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error clearing POC edit remark: " + ex.Message);
                return "{\"status\":\"error\", \"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }

        /// <summary>Ensures AttPocEditRemarks table exists; creates it if absent (safe for existing DBs).</summary>
        private static void EnsureAttPocEditRemarksTable()
        {
            string connStr = DBHelper.GetAttendanceDBConnection();
            try
            {
                // Oracle stores table names in uppercase; AttPocEditRemarks => ATTPOCEDITREMARK (16 chars)
                object cnt = DBHelper.ExecuteScalar(connStr, "SELECT COUNT(*) FROM user_tables WHERE UPPER(table_name) = 'ATTPOCEDITREMARK'");
                if (Convert.ToInt32(cnt) == 0)
                {
                    string createSql = @"
                        CREATE TABLE AttPocEditRemarks (
                            Id          NUMBER          PRIMARY KEY,
                            EmpID       VARCHAR2(50)    NOT NULL,
                            Year        NUMBER          NOT NULL,
                            Month       NUMBER          NOT NULL,
                            Day         NUMBER          NOT NULL,
                            RemarkType  VARCHAR2(50)    DEFAULT 'POCEdit' NOT NULL,
                            Remark      VARCHAR2(1000)  NOT NULL,
                            CreatedBy   VARCHAR2(100)   NOT NULL,
                            CreatedAt   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL
                        )";
                    DBHelper.ExecuteNonQuery(connStr, createSql);
                    DBHelper.ExecuteNonQuery(connStr, "CREATE SEQUENCE SEQ_AttPocEditRemarks START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE");
                    DBHelper.ExecuteNonQuery(connStr, @"
                        CREATE OR REPLACE TRIGGER TRG_AttPocEditRemarks
                        BEFORE INSERT ON AttPocEditRemarks
                        FOR EACH ROW
                        BEGIN
                            IF :NEW.Id IS NULL THEN
                                SELECT SEQ_AttPocEditRemarks.NEXTVAL INTO :NEW.Id FROM DUAL;
                            END IF;
                        END;");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("EnsureAttPocEditRemarksTable error: " + ex.Message);
            }
        }


        private static void EnsureGlobalEmployeeExists(string globalEmpId)
        {
            try
            {
                string checkQuery = "SELECT COUNT(*) FROM Employees WHERE MasterId = :MasterId";
                object countObj = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, new OracleParameter("MasterId", globalEmpId));
                int count = Convert.ToInt32(countObj ?? 0);
                if (count == 0)
                {
                    string insertEmp = @"
                        INSERT INTO Employees (MasterId, ID, Name, EmployeeHistoryId, Status)
                        VALUES (:MasterId, :ID, :Name, :HistoryId, 'System')";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertEmp,
                        new OracleParameter("MasterId", globalEmpId),
                        new OracleParameter("ID", globalEmpId),
                        new OracleParameter("Name", "System Global Adjustment (" + globalEmpId + ")"),
                        new OracleParameter("HistoryId", globalEmpId));
                }
                else
                {
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "UPDATE Employees SET Status = 'System' WHERE MasterId = :MasterId", new OracleParameter("MasterId", globalEmpId));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("EnsureGlobalEmployeeExists error: " + ex.Message);
            }
        }

        private struct AttCell
        {
            public float? Val;
            public bool IsHoliday;
            public string LeaveType;
            public bool AutoSat;
        }

        private class EngagementRange
        {
            public DateTime StartDate { get; set; }
            public DateTime? EndDate { get; set; }
        }

        private static void RecalculateNextMonthSaturdays(int year, int month, string category)
        {
            int nextMonth = month == 11 ? 0 : month + 1;
            int nextYear = month == 11 ? year + 1 : year;

            DateTime firstDayOfNextMonth = new DateTime(nextYear, nextMonth + 1, 1);
            int firstSatDay = -1;
            for (int d = 1; d <= 7; d++)
            {
                DateTime dt = new DateTime(nextYear, nextMonth + 1, d);
                if (dt.DayOfWeek == DayOfWeek.Saturday)
                {
                    firstSatDay = d;
                    break;
                }
            }

            if (firstSatDay == -1 || firstSatDay > 5)
            {
                return;
            }

            DateTime nextSatDate = new DateTime(nextYear, nextMonth + 1, firstSatDay);

            string empQuery = @"
                SELECT MasterId, JoinDate, ResignDate
                FROM Employees
                WHERE Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Resigned', 'Transferred')";
            if (category != "All")
            {
                empQuery += " AND Category = :Category";
            }

            List<OracleParameter> empParams = new List<OracleParameter>();
            if (category != "All")
            {
                empParams.Add(new OracleParameter("Category", category));
            }

            DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, empParams.ToArray());
            if (dtEmp.Rows.Count == 0) return;

            string engQuery = @"
                SELECT ee.EmpID, ee.StartDate, ee.EndDate, cp.EndDate AS CpEndDate
                FROM EmployeeEngagements ee
                JOIN ContractPeriods cp ON ee.ContractPeriodId = cp.Id
                WHERE ee.StartDate <= :SatDate AND (ee.EndDate IS NULL OR ee.EndDate >= :SatDate)";
            DataTable dtEng = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), engQuery, 
                new OracleParameter("SatDate", nextSatDate));

            Dictionary<string, List<EngagementRange>> engDict = new Dictionary<string, List<EngagementRange>>();
            foreach (DataRow dr in dtEng.Rows)
            {
                string empId = dr["EmpID"].ToString();
                DateTime startDate = Convert.ToDateTime(dr["StartDate"]);
                DateTime? eeEndDate = dr["EndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["EndDate"]) : null;
                DateTime? cpEndDate = dr["CpEndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["CpEndDate"]) : null;
                
                DateTime? effectiveEndDate = null;
                if (eeEndDate.HasValue && cpEndDate.HasValue)
                {
                    effectiveEndDate = eeEndDate.Value < cpEndDate.Value ? eeEndDate.Value : cpEndDate.Value;
                }
                else if (eeEndDate.HasValue)
                {
                    effectiveEndDate = eeEndDate;
                }
                else if (cpEndDate.HasValue)
                {
                    effectiveEndDate = cpEndDate;
                }

                if (!engDict.ContainsKey(empId))
                    engDict[empId] = new List<EngagementRange>();

                engDict[empId].Add(new EngagementRange { StartDate = startDate, EndDate = effectiveEndDate });
            }

            string nextAttQuery = @"
                SELECT EmpID, Day, StatusValue, IsHoliday, LeaveType, AutoSat
                FROM Attendance
                WHERE Year = :Year AND Month = :Month AND Day <= :SatDay";
            DataTable dtNextAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), nextAttQuery,
                new OracleParameter("Year", nextYear),
                new OracleParameter("Month", nextMonth),
                new OracleParameter("SatDay", firstSatDay));

            Dictionary<string, Dictionary<int, AttCell>> nextAttDict = new Dictionary<string, Dictionary<int, AttCell>>();
            foreach (DataRow dr in dtNextAtt.Rows)
            {
                string empId = dr["EmpID"].ToString();
                int day = Convert.ToInt32(dr["Day"]);
                float? val = dr["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(dr["StatusValue"]);
                bool isHoliday = Convert.ToInt32(dr["IsHoliday"]) == 1;
                string leave = dr["LeaveType"].ToString();
                bool autoSat = dr.Table.Columns.Contains("AutoSat") && dr["AutoSat"] != DBNull.Value ? Convert.ToInt32(dr["AutoSat"]) == 1 : false;

                if (!nextAttDict.ContainsKey(empId))
                    nextAttDict[empId] = new Dictionary<int, AttCell>();

                nextAttDict[empId][day] = new AttCell { Val = val, IsHoliday = isHoliday, LeaveType = leave, AutoSat = autoSat };
            }

            int daysInCurrMonth = DateTime.DaysInMonth(year, month + 1);
            int earliestPrevDay = daysInCurrMonth + (firstSatDay - 5);

            string currAttQuery = @"
                SELECT EmpID, Day, StatusValue, IsHoliday, LeaveType
                FROM Attendance
                WHERE Year = :Year AND Month = :Month AND Day >= :EarliestDay";
            DataTable dtCurrAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), currAttQuery,
                new OracleParameter("Year", year),
                new OracleParameter("Month", month),
                new OracleParameter("EarliestDay", earliestPrevDay));

            Dictionary<string, Dictionary<int, AttCell>> currAttDict = new Dictionary<string, Dictionary<int, AttCell>>();
            foreach (DataRow dr in dtCurrAtt.Rows)
            {
                string empId = dr["EmpID"].ToString();
                int day = Convert.ToInt32(dr["Day"]);
                float? val = dr["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(dr["StatusValue"]);
                bool isHoliday = Convert.ToInt32(dr["IsHoliday"]) == 1;
                string leave = dr["LeaveType"].ToString();

                if (!currAttDict.ContainsKey(empId))
                    currAttDict[empId] = new Dictionary<int, AttCell>();

                currAttDict[empId][day] = new AttCell { Val = val, IsHoliday = isHoliday, LeaveType = leave };
            }

            foreach (DataRow row in dtEmp.Rows)
            {
                string empId = row["MasterId"].ToString();

                if (!nextAttDict.ContainsKey(empId) || !nextAttDict[empId].ContainsKey(firstSatDay) || !nextAttDict[empId][firstSatDay].AutoSat)
                {
                    continue;
                }

                DateTime? joinDate = row["JoinDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(row["JoinDate"]) : null;
                DateTime? resignDate = row["ResignDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(row["ResignDate"]) : null;

                List<EngagementRange> empEngs = engDict.ContainsKey(empId) ? engDict[empId] : new List<EngagementRange>();

                bool ok = true;
                DateTime monday = nextSatDate.AddDays(-5);
                DateTime friday = nextSatDate.AddDays(-1);

                if (joinDate.HasValue && joinDate.Value.Date > monday.Date && joinDate.Value.Date <= friday.Date)
                {
                    ok = false;
                }
                else
                {
                    for (int k = 1; k <= 5; k++)
                    {
                        DateTime c = nextSatDate.AddDays(-k);

                        bool isOutOfBoundsWeek = true;
                        foreach (var eng in empEngs)
                        {
                            if (c.Date >= eng.StartDate.Date && (!eng.EndDate.HasValue || c.Date <= eng.EndDate.Value.Date))
                            {
                                isOutOfBoundsWeek = false;
                                break;
                            }
                        }
                        if (isOutOfBoundsWeek) continue;

                        float? v = null;
                        string l = "";
                        bool isHol = false;

                        if (c.Month - 1 == nextMonth)
                        {
                            if (nextAttDict.ContainsKey(empId) && nextAttDict[empId].ContainsKey(c.Day))
                            {
                                v = nextAttDict[empId][c.Day].Val;
                                l = nextAttDict[empId][c.Day].LeaveType;
                                isHol = nextAttDict[empId][c.Day].IsHoliday;
                            }
                        }
                        else
                        {
                            if (currAttDict.ContainsKey(empId) && currAttDict[empId].ContainsKey(c.Day))
                            {
                                v = currAttDict[empId][c.Day].Val;
                                l = currAttDict[empId][c.Day].LeaveType;
                                isHol = currAttDict[empId][c.Day].IsHoliday;
                            }
                        }

                        bool came = (v == 1f) || (v == 0.5f) || (l == "Paid") || (l == "Carried") || (l == "Paired Paid") || (l == "Paired Unpaid") || (isHol == true);
                        if (!came)
                        {
                            ok = false;
                            break;
                        }
                    }
                }

                float newVal = ok ? 1f : 0f;
                float? currentVal = nextAttDict[empId][firstSatDay].Val;

                if (currentVal != newVal)
                {
                    string updateQuery = @"
                        UPDATE Attendance 
                        SET StatusValue = :Val 
                        WHERE EmpID = :EmpID AND Year = :Year AND Month = :Month AND Day = :Day";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery,
                        new OracleParameter("Val", newVal),
                        new OracleParameter("EmpID", empId),
                        new OracleParameter("Year", nextYear),
                        new OracleParameter("Month", nextMonth),
                        new OracleParameter("Day", firstSatDay));
                }
            }
        }


        [WebMethod]
        public static string GetCategories()
        {
            int role = Convert.ToInt32(System.Web.HttpContext.Current.Session["Role"] ?? 0);
            string pcno = System.Web.HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
            DataTable dt = DBHelper.GetVisibleTiersDataTable(pcno, role);
            List<string> list = new List<string>();
            foreach (DataRow dr in dt.Rows)
            {
                list.Add(dr["TierId"].ToString() + ":" + dr["DisplayName"].ToString());
            }
            return new JavaScriptSerializer().Serialize(list);
        }

        [WebMethod]
        public static string GetDivisions()
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
            
            List<string> list = new List<string>();
            if (role == 1 || role == 4)
            {
                DataTable dt = DBHelper.GetCompanyDivisionsDataTable();
                foreach (DataRow dr in dt.Rows)
                {
                    list.Add(dr["Name"].ToString());
                }
            }
            else
            {
                string query = "SELECT DivisionName FROM UserDivisions WHERE PCNO = :PCNO ORDER BY DivisionName ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                foreach (DataRow dr in dt.Rows)
                {
                    list.Add(dr["DivisionName"].ToString());
                }
            }
            return new JavaScriptSerializer().Serialize(list);
        }

        private static bool ValidateLeaveBalances(
            string connStr, 
            Dictionary<string, Dictionary<string, Dictionary<string, object>>> dict, 
            Dictionary<string, Dictionary<string, Dictionary<string, object>>> futDict, 
            int year, 
            int month, 
            out string errorMessage)
        {
            errorMessage = "";
            foreach (var empId in dict.Keys)
            {
                if (empId.StartsWith("GLOBAL")) continue;

                string empSql = @"
                    SELECT e.Name, e.LeaveBalance, e.PrevLeaveBalance, ee.ContractPeriodId AS CurrentContractPeriodId
                    FROM Employees e
                    LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                    WHERE e.MasterId = :MasterId";
                
                DataTable dtEmp = DBHelper.ExecuteQuery(connStr, empSql, new OracleParameter("MasterId", empId));
                if (dtEmp.Rows.Count == 0) continue;
                
                string empName = dtEmp.Rows[0]["Name"].ToString();

                string engSql = "SELECT Id, StartDate, EndDate, ContractPeriodId FROM EmployeeEngagements WHERE EmpID = :MasterId";
                DataTable dtEng = DBHelper.ExecuteQuery(connStr, engSql, new OracleParameter("MasterId", empId));

                Func<DateTime, int?> getCpIdForDate = (date) => {
                    foreach (DataRow er in dtEng.Rows)
                    {
                        DateTime start = Convert.ToDateTime(er["StartDate"]);
                        DateTime? end = er["EndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(er["EndDate"]) : null;
                        if (date >= start && (!end.HasValue || date <= end.Value))
                        {
                            return er["ContractPeriodId"] != DBNull.Value ? (int?)Convert.ToInt32(er["ContractPeriodId"]) : null;
                        }
                    }
                    return null;
                };

                // Identify unique CPs touched by these updates
                HashSet<int?> touchedCps = new HashSet<int?>();
                foreach (var dayKvp in dict[empId])
                {
                    touchedCps.Add(getCpIdForDate(new DateTime(year, month + 1, Convert.ToInt32(dayKvp.Key))));
                }
                if (futDict != null && futDict.ContainsKey(empId))
                {
                    foreach (var dateKvp in futDict[empId])
                    {
                        var cell = dateKvp.Value;
                        touchedCps.Add(getCpIdForDate(new DateTime(Convert.ToInt32(cell["Year"]), Convert.ToInt32(cell["Month"]) + 1, Convert.ToInt32(cell["Day"]))));
                    }
                }

                foreach (var targetCpId in touchedCps)
                {
                    if (!targetCpId.HasValue) continue;

                    string dbSql = @"
                        SELECT a.Year, a.Month, a.Day, a.StatusValue, a.LeaveType, a.IsHoliday
                        FROM Attendance a
                        JOIN EmployeeEngagements ee ON a.EmpID = ee.EmpID
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee.StartDate
                          AND (ee.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee.EndDate)
                        WHERE a.EmpID = :MasterId AND ee.ContractPeriodId = :CpId";
                    
                    DataTable dtDb = DBHelper.ExecuteQuery(connStr, dbSql, 
                        new OracleParameter("MasterId", empId),
                        new OracleParameter("CpId", targetCpId.Value));

                    // Get all leave credits for this employee under targetCpId
                    string creditSql = "SELECT Amount, EffectiveDate FROM EmployeeLeaveCredits WHERE EmpID = :MasterId AND ContractPeriodId = :CpId";
                    DataTable dtCredits = DBHelper.ExecuteQuery(connStr, creditSql, 
                        new OracleParameter("MasterId", empId),
                        new OracleParameter("CpId", targetCpId.Value));
                    
                    bool useCreditsTable = dtCredits.Rows.Count > 0;

                    // Combine all attendance records for this CP:
                    // 1. Existing DB records
                    // 2. New updates from dict
                    // 3. New updates from futDict
                    // We will map Date -> LeaveWeight
                    Dictionary<DateTime, double> allLeaves = new Dictionary<DateTime, double>();

                    // Add existing DB records
                    foreach (DataRow row in dtDb.Rows)
                    {
                        int yVal = Convert.ToInt32(row["Year"]);
                        int mVal = Convert.ToInt32(row["Month"]);
                        int dVal = Convert.ToInt32(row["Day"]);
                        DateTime date = new DateTime(yVal, mVal + 1, dVal);

                        bool isHoliday = row["IsHoliday"] != DBNull.Value && Convert.ToInt32(row["IsHoliday"]) == 1;
                        if (isHoliday) continue;

                        double val = row["StatusValue"] != DBNull.Value ? Convert.ToDouble(row["StatusValue"]) : 0.0;
                        string leaveType = row["LeaveType"] != DBNull.Value ? row["LeaveType"].ToString() : "";

                        double weight = 0.0;
                        if (val == 0.0 && leaveType == "Paid") weight = 1.0;
                        else if (leaveType == "Paired Paid") weight = 1.0;

                        allLeaves[date] = weight;
                    }

                    // Overwrite/Add from dict (current month updates)
                    foreach (var dayKvp in dict[empId])
                    {
                        int day = Convert.ToInt32(dayKvp.Key);
                        DateTime date = new DateTime(year, month + 1, day);
                        
                        int? cpId = getCpIdForDate(date);
                        if (cpId != targetCpId.Value) continue;

                        var cell = dayKvp.Value;
                        double weight = 0.0;
                        if (cell.ContainsKey("Holiday") && Convert.ToBoolean(cell["Holiday"]))
                        {
                            weight = 0.0;
                        }
                        else
                        {
                            object valObj = cell.ContainsKey("Val") ? cell["Val"] : null;
                            string leaveType = cell.ContainsKey("Leave") && cell["Leave"] != null ? cell["Leave"].ToString() : "";
                            double val = 0.0;
                            if (valObj != null && double.TryParse(valObj.ToString(), out val))
                            {
                                if (val == 0.0 && leaveType == "Paid") weight = 1.0;
                            }
                            if (leaveType == "Paired Paid") weight = 1.0;
                        }

                        allLeaves[date] = weight;
                    }

                    // Overwrite/Add from futDict (future updates)
                    if (futDict != null && futDict.ContainsKey(empId))
                    {
                        foreach (var dateKvp in futDict[empId])
                        {
                            var cell = dateKvp.Value;
                            int fYear = Convert.ToInt32(cell["Year"]);
                            int fMonth = Convert.ToInt32(cell["Month"]);
                            int fDay = Convert.ToInt32(cell["Day"]);
                            DateTime date = new DateTime(fYear, fMonth + 1, fDay);

                            int? cpId = getCpIdForDate(date);
                            if (cpId != targetCpId.Value) continue;

                            double weight = 0.0;
                            object valObj = cell.ContainsKey("Val") ? cell["Val"] : null;
                            string leaveType = cell.ContainsKey("Leave") && cell["Leave"] != null ? cell["Leave"].ToString() : "";
                            double val = 0.0;
                            if (valObj != null && double.TryParse(valObj.ToString(), out val))
                            {
                                if (val == 0.0 && leaveType == "Paid") weight = 1.0;
                            }
                            if (leaveType == "Paired Paid") weight = 1.0;

                            allLeaves[date] = weight;
                        }
                    }

                    // Now, validate chronologically!
                    var sortedDates = allLeaves.Keys.OrderBy(d => d).ToList();
                    
                    foreach (var date in sortedDates)
                    {
                        double weightAtDate = allLeaves[date];
                        if (weightAtDate == 0.0) continue; // No leave taken, no check needed for this date

                        // Sum leaves taken on or before this date
                        double leavesUsed = 0.0;
                        foreach (var prevDate in sortedDates)
                        {
                            if (prevDate <= date)
                            {
                                leavesUsed += allLeaves[prevDate];
                            }
                        }

                        // Get total credits active on or before this date
                        double allowedCredits = 0.0; 
                        if (useCreditsTable)
                        {
                            double creditSum = 0.0;
                            foreach (DataRow cr in dtCredits.Rows)
                            {
                                DateTime effDate = Convert.ToDateTime(cr["EffectiveDate"]);
                                if (effDate <= date)
                                {
                                    creditSum += Convert.ToDouble(cr["Amount"]);
                                }
                            }
                            allowedCredits = creditSum;
                        }
                        else
                        {
                            object currentCpIdObj = dtEmp.Rows[0]["CurrentContractPeriodId"];
                            bool isCurrentCp = currentCpIdObj != DBNull.Value && Convert.ToInt32(currentCpIdObj) == targetCpId.Value;
                            string balanceCol = isCurrentCp ? "LeaveBalance" : "PrevLeaveBalance";
                            allowedCredits = dtEmp.Rows[0][balanceCol] != DBNull.Value ? Convert.ToDouble(dtEmp.Rows[0][balanceCol]) : 0.0;
                        }

                        if (leavesUsed > allowedCredits)
                        {
                            errorMessage = string.Format(
                                "Validation Error: Employee {0} ({1}) would exceed paid leave limit on {2:yyyy-MM-dd}. Leaves used up to this date: {3} days, allowed credits: {4} days.",
                                empName, empId, date, leavesUsed, allowedCredits);
                            return false;
                        }
                    }
                }
            }
            return true;
        }
    }
}
