using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Ledger : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                int currentYear = DateTime.Now.Year;
                for (int i = currentYear - 2; i <= currentYear + 2; i++)
                {
                    ddlYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
                }
                ddlYear.SelectedValue = currentYear.ToString();
                ddlMonth.SelectedValue = DateTime.Now.Month.ToString();
                
                PopulateCategories();
                PopulateContracts();
                BindGrid();
            }
            else
            {
                string target = Request.Form["__EVENTTARGET"];
                if (target == null || !target.Contains("ddlCategory"))
                {
                    PopulateContracts();
                    BindGrid();
                }
            }
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateContracts();
            BindGrid();
        }

        private void PopulateContracts()
        {
            string cat = ddlCategory.SelectedValue;
            if (cat == "All")
            {
                ddlContract.Visible = false;
                ddlContract.Items.Clear();
                return;
            }

            string prevSelected = "";
            if (ddlContract.Items.Count > 0)
            {
                prevSelected = ddlContract.SelectedValue;
            }

            try
            {
                int tY = int.Parse(ddlYear.SelectedValue);
                int tM = int.Parse(ddlMonth.SelectedValue);
                DateTime firstDay = new DateTime(tY, tM, 1);
                DateTime lastDay = firstDay.AddMonths(1).AddDays(-1);

                string query = @"
                    SELECT cp.Id, cp.StartDate, cp.EndDate, cp.Status, v.Name AS VendorName 
                    FROM ContractPeriods cp 
                    JOIN Vendors v ON cp.VendorId = v.Id 
                    WHERE cp.TierId = :TierId 
                      AND cp.StartDate <= :LastDay 
                      AND (cp.EndDate IS NULL OR cp.EndDate >= :FirstDay)
                    ORDER BY cp.Status ASC, cp.StartDate DESC";
                
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, 
                    new OracleParameter("TierId", Convert.ToInt32(cat)),
                    new OracleParameter("LastDay", lastDay),
                    new OracleParameter("FirstDay", firstDay));
                
                ddlContract.Items.Clear();
                
                if (dt.Rows.Count > 1)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        int id = Convert.ToInt32(row["Id"]);
                        string status = row["Status"].ToString();
                        DateTime start = Convert.ToDateTime(row["StartDate"]);
                        string dateStr = start.ToString("yyyy-MM-dd");
                        if (row["EndDate"] != DBNull.Value)
                        {
                            dateStr += " to " + Convert.ToDateTime(row["EndDate"]).ToString("yyyy-MM-dd");
                        }
                        else
                        {
                            dateStr += " onwards";
                        }
                        string vendor = row["VendorName"].ToString();
                        
                        string text = string.Format("{0} ({1}) - {2}", status, dateStr, vendor);
                        ddlContract.Items.Add(new ListItem(text, id.ToString()));
                    }
                    ddlContract.Visible = true;

                    if (!string.IsNullOrEmpty(prevSelected) && ddlContract.Items.FindByValue(prevSelected) != null)
                    {
                        ddlContract.SelectedValue = prevSelected;
                    }
                }
                else
                {
                    ddlContract.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating contracts: " + ex.Message);
            }
        }

        private void PopulateCategories()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                DataTable dtCat = DBHelper.GetVisibleTiersDataTable(pcno, role);
                foreach (DataRow row in dtCat.Rows)
                {
                    ddlCategory.Items.Add(new ListItem(row["DisplayName"].ToString(), row["TierId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating categories in Ledger: " + ex.Message);
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        private void BindGrid()
        {
            int tY = int.Parse(ddlYear.SelectedValue);
            int tM = int.Parse(ddlMonth.SelectedValue) - 1; // Convert 1-12 to 0-11 to match 0-indexed database Month
            string cat = ddlCategory.SelectedValue;
            string search = txtSearch.Text.Trim();

            DateTime firstDay = new DateTime(tY, tM + 1, 1);
            DateTime lastDay = firstDay.AddMonths(1).AddDays(-1);

            int? selectedCpId = null;
            DateTime? cpStartDate = null;
            DateTime? cpEndDate = null;

            if (cat != "All")
            {
                if (ddlContract.Visible && !string.IsNullOrEmpty(ddlContract.SelectedValue))
                {
                    selectedCpId = int.Parse(ddlContract.SelectedValue);
                }
                else
                {
                    string query = @"
                        SELECT Id, StartDate, EndDate 
                        FROM ContractPeriods 
                        WHERE TierId = :TierId 
                          AND StartDate <= :LastDay 
                          AND (EndDate IS NULL OR EndDate >= :FirstDay)
                        ORDER BY Status ASC, StartDate DESC";
                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, 
                        new OracleParameter("TierId", Convert.ToInt32(cat)),
                        new OracleParameter("LastDay", lastDay),
                        new OracleParameter("FirstDay", firstDay));
                    if (dt.Rows.Count > 0)
                    {
                        selectedCpId = Convert.ToInt32(dt.Rows[0]["Id"]);
                    }
                }
                
                if (selectedCpId.HasValue)
                {
                    string cpQuery = "SELECT StartDate, EndDate FROM ContractPeriods WHERE Id = :Id";
                    DataTable dtCp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), cpQuery, 
                        new OracleParameter("Id", selectedCpId.Value));
                    if (dtCp.Rows.Count > 0)
                    {
                        cpStartDate = Convert.ToDateTime(dtCp.Rows[0]["StartDate"]);
                        if (dtCp.Rows[0]["EndDate"] != DBNull.Value)
                        {
                            cpEndDate = Convert.ToDateTime(dtCp.Rows[0]["EndDate"]);
                        }
                    }
                }
            }

            // 1. Fetch Employees
            string empQuery;
            List<OracleParameter> empParams = new List<OracleParameter>();
            
            if (selectedCpId.HasValue)
            {
                empQuery = @"
                    SELECT DISTINCT e.MasterId, NVL(ee.EmployeeId, e.ID) AS ID, e.Name, 
                           e.Department, ee.TierId,
                           (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = ee.TierId) AS Category, 
                           e.JoinDate, e.ResignDate, e.ContractEndDate, 
                           CASE WHEN (SELECT ee_curr.ContractPeriodId FROM EmployeeEngagements ee_curr WHERE ee_curr.Id = e.CurrentEngagementId) = :SelectedCpId 
                                THEN e.LeaveBalance 
                                ELSE e.PrevLeaveBalance 
                           END AS LeaveBalance
                    FROM Employees e
                    JOIN EmployeeEngagements ee ON e.MasterId = ee.EmpID                     WHERE e.MasterId NOT LIKE 'GLOBAL%' AND e.Status <> 'System'
                       AND e.Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Resigned', 'Transferred')
                       AND ee.ContractPeriodId = :SelectedCpId";
                empParams.Add(new OracleParameter("SelectedCpId", selectedCpId.Value));
            }
            else
            {
                empQuery = "SELECT e.MasterId, e.ID, e.Name, e.Department, e.TierId, (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category, e.JoinDate, e.ResignDate, e.ContractEndDate, e.LeaveBalance FROM Employees e WHERE e.MasterId NOT LIKE 'GLOBAL%' AND e.Status <> 'System' AND e.Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Resigned', 'Transferred')";
            }
            
            if (cat != "All" && !selectedCpId.HasValue)
            {
                empQuery += " AND e.TierId = :Cat";
                empParams.Add(new OracleParameter("Cat", Convert.ToInt32(cat)));
            }
            if (!string.IsNullOrEmpty(search))
            {
                string idField = "e.ID";
                string nameField = "e.Name";
                empQuery += string.Format(" AND (UPPER({0}) LIKE UPPER(:Search) OR UPPER({1}) LIKE UPPER(:Search))", idField, nameField);
                empParams.Add(new OracleParameter("Search", "%" + search + "%"));
            }

            // Restrict by division for non-admins
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 4)
            {
                string userPcno = Session["PCNO"]?.ToString() ?? "";
                List<int> visibleTiers = DBHelper.GetVisibleTierIds(userPcno, role);
                if (visibleTiers.Count > 0)
                {
                    List<string> tierParams = new List<string>();
                    for (int i = 0; i < visibleTiers.Count; i++)
                    {
                        string paramName = "VTierId" + i;
                        tierParams.Add(":" + paramName);
                        empParams.Add(new OracleParameter(paramName, visibleTiers[i]));
                    }
                    string tierField = selectedCpId.HasValue ? "ee.TierId" : "e.TierId";
                    empQuery += string.Format(" AND {0} IN ({1})", tierField, string.Join(", ", tierParams));
                }
                else
                {
                    empQuery += " AND 1=0";
                }
            }

            if (role != 1 && role != 4)
            {
                var allowedDivs = Session["AllowedDivisions"] as List<string>;
                if (allowedDivs != null && allowedDivs.Count > 0)
                {
                    List<string> divClauses = new List<string>();
                    for (int i = 0; i < allowedDivs.Count; i++)
                    {
                        string paramName = "Div" + i;
                        string deptField = selectedCpId.HasValue ? "e.Department" : "Department";
                        divClauses.Add(deptField + " LIKE :" + paramName);
                        empParams.Add(new OracleParameter(paramName, allowedDivs[i] + "%"));
                    }
                    empQuery += " AND (" + string.Join(" OR ", divClauses) + ")";
                }
                else
                {
                    empQuery += " AND 1=0";
                }
            }

            string orderDept = selectedCpId.HasValue ? "e.Department" : "Department";
            string orderName = selectedCpId.HasValue ? "e.Name" : "Name";
            empQuery += string.Format(" ORDER BY {0} ASC, {1} ASC", orderDept, orderName);

            DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, empParams.ToArray());

            // 2. Output Table
            DataTable resultDt = new DataTable();
            resultDt.Columns.Add("ID", typeof(string));
            resultDt.Columns.Add("MasterID", typeof(string));
            resultDt.Columns.Add("Name", typeof(string));
            resultDt.Columns.Add("Department", typeof(string));
            resultDt.Columns.Add("Category", typeof(string));
            resultDt.Columns.Add("Opening", typeof(double));
            resultDt.Columns.Add("Paid", typeof(int));
            resultDt.Columns.Add("Half", typeof(double));
            resultDt.Columns.Add("Unpaid", typeof(int));
            resultDt.Columns.Add("SatCut", typeof(int));
            resultDt.Columns.Add("Closing", typeof(double));
            resultDt.Columns.Add("PresentDays", typeof(float));
            resultDt.Columns.Add("FinalDays", typeof(float));
            resultDt.Columns.Add("Remarks", typeof(string));

            // Fetch Global Adjustment
            float globalAdj = 0;
            string gq = "SELECT StatusValue FROM Attendance WHERE Year=:Y AND Month=:M AND EmpID='GLOBAL' AND Day=0 AND ROWNUM <= 1";
            object gRes = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), gq,
                new OracleParameter("Y", tY), new OracleParameter("M", tM));
            if (gRes != null && gRes != DBNull.Value)
            {
                globalAdj = Convert.ToSingle(gRes);
            }

            // Fetch Category-specific Global Adjustments
            Dictionary<string, float> catGlobalAdjDict = new Dictionary<string, float>(StringComparer.OrdinalIgnoreCase);
            try
            {
                string catGq = "SELECT EmpID, StatusValue FROM Attendance WHERE Year=:Y AND Month=:M AND EmpID LIKE 'GLOBAL_%' AND Day=0";
                DataTable dtCatGlob = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), catGq,
                    new OracleParameter("Y", tY), new OracleParameter("M", tM));
                foreach (DataRow r in dtCatGlob.Rows)
                {
                    string empId = r["EmpID"].ToString();
                    string catName = empId.Substring(7); // Extract category (TierId string) from 'GLOBAL_<Category>'
                    float val = r["StatusValue"] != DBNull.Value ? Convert.ToSingle(r["StatusValue"]) : 0f;
                    catGlobalAdjDict[catName] = val;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching category global adjustments in Ledger: " + ex.Message);
            }

            // Fetch Overlapping Engagements

            string engQuery = @"
                SELECT ee.EmpID, ee.StartDate, ee.EndDate, cp.EndDate AS CpEndDate
                FROM EmployeeEngagements ee
                JOIN ContractPeriods cp ON ee.ContractPeriodId = cp.Id
                WHERE (ee.StartDate <= :LastDay AND (ee.EndDate IS NULL OR ee.EndDate >= :FirstDay))";
            List<OracleParameter> engParams = new List<OracleParameter> {
                new OracleParameter("LastDay", lastDay),
                new OracleParameter("FirstDay", firstDay)
            };
            if (selectedCpId.HasValue)
            {
                engQuery += " AND ee.ContractPeriodId = :SelectedCpId";
                engParams.Add(new OracleParameter("SelectedCpId", selectedCpId.Value));
            }
            
            DataTable dtEng = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), engQuery, engParams.ToArray());

            Dictionary<string, List<EngagementRange>> engDict = new Dictionary<string, List<EngagementRange>>();
            foreach (DataRow dr in dtEng.Rows)
            {
                string empId = dr["EmpID"].ToString();
                DateTime startDate = Convert.ToDateTime(dr["StartDate"]);
                
                DateTime? eeEndDate = dr["EndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["EndDate"]) : null;
                DateTime? rowCpEndDate = dr["CpEndDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["CpEndDate"]) : null;
                
                DateTime? effectiveEndDate = null;
                if (eeEndDate.HasValue && rowCpEndDate.HasValue)
                {
                    effectiveEndDate = eeEndDate.Value < rowCpEndDate.Value ? eeEndDate.Value : rowCpEndDate.Value;
                }
                else if (eeEndDate.HasValue)
                {
                    effectiveEndDate = eeEndDate;
                }
                else if (rowCpEndDate.HasValue)
                {
                    effectiveEndDate = rowCpEndDate;
                }

                if (!engDict.ContainsKey(empId))
                    engDict[empId] = new List<EngagementRange>();

                engDict[empId].Add(new EngagementRange { StartDate = startDate, EndDate = effectiveEndDate });
            }

            // Fetch Calculation Overrides
            string oQ = "SELECT EmpID, FinalDays, Remarks FROM CalculationOverrides WHERE Year=:Y AND Month=:M";
            List<OracleParameter> oParams = new List<OracleParameter> {
                new OracleParameter("Y", tY),
                new OracleParameter("M", tM)
            };
            if (selectedCpId.HasValue)
            {
                oQ += " AND (ContractPeriodId = :SelectedCpId OR (ContractPeriodId IS NULL AND TierId = :TierId))";
                oParams.Add(new OracleParameter("SelectedCpId", selectedCpId.Value));
                oParams.Add(new OracleParameter("TierId", Convert.ToInt32(cat)));
            }
            else if (cat != "All")
            {
                oQ += " AND TierId=:TierId";
                oParams.Add(new OracleParameter("TierId", Convert.ToInt32(cat)));
            }
            DataTable dtOver = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), oQ, oParams.ToArray());
            Dictionary<string, OverrideInfo> overDict = new Dictionary<string, OverrideInfo>();
            foreach(DataRow dr in dtOver.Rows)
            {
                overDict[dr["EmpID"].ToString()] = new OverrideInfo {
                    FinalDays = Convert.ToSingle(dr["FinalDays"]),
                    Remarks = dr["Remarks"] == DBNull.Value ? "" : dr["Remarks"].ToString()
                };
            }

            foreach (DataRow row in dtEmp.Rows)
            {
                string masterId = row["MasterId"].ToString();
                string empId = row["ID"].ToString();
                DateTime? joinDate = row["JoinDate"] != DBNull.Value ? Convert.ToDateTime(row["JoinDate"]) : (DateTime?)null;
                DateTime? resignDate = row["ResignDate"] != DBNull.Value ? Convert.ToDateTime(row["ResignDate"]) : (DateTime?)null;
                DateTime? contractEndDate = row["ContractEndDate"] != DBNull.Value ? Convert.ToDateTime(row["ContractEndDate"]) : (DateTime?)null;
                double initialBalance = row["LeaveBalance"] != DBNull.Value ? Convert.ToDouble(row["LeaveBalance"]) : 0;
                List<EngagementRange> empEngs = engDict.ContainsKey(masterId) ? engDict[masterId] : new List<EngagementRange>();

                // Check Bounds
                if (joinDate.HasValue)
                {
                    if (tY < joinDate.Value.Year || (tY == joinDate.Value.Year && tM < (joinDate.Value.Month - 1)))
                    {
                        continue; // Skip, they haven't joined yet
                    }
                }
                
                if (resignDate.HasValue)
                {
                    if (tY > resignDate.Value.Year || (tY == resignDate.Value.Year && tM > (resignDate.Value.Month - 1)))
                    {
                        continue; // Skip, they have already left before this month
                    }
                }

                DateTime? effectiveContractEndDate = cpEndDate ?? contractEndDate;
                if (effectiveContractEndDate.HasValue)
                {
                    if (tY > effectiveContractEndDate.Value.Year || (tY == effectiveContractEndDate.Value.Year && tM > (effectiveContractEndDate.Value.Month - 1)))
                    {
                        continue; // Skip, contract has ended before this month
                    }
                }

                // Get Historical Totals (Prior to Target Month) restricted to the current contract period
string histQuery;
                List<OracleParameter> histParams = new List<OracleParameter> {
                    new OracleParameter("EmpID", masterId), 
                    new OracleParameter("TY", tY), 
                    new OracleParameter("TM", tM)
                };
                if (selectedCpId.HasValue)
                {
                    histQuery = @"
                        SELECT 
                            SUM(CASE WHEN (a.StatusValue = 0 AND a.LeaveType = 'Paid') OR a.LeaveType = 'Paired Paid' THEN 1 ELSE 0 END) as PrevFull,
                            SUM(CASE WHEN a.StatusValue = 0.5 THEN 1 ELSE 0 END) as PrevHalf
                        FROM Attendance a
                        JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                          AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                        WHERE a.EmpID = :EmpID
                          AND ee_past.ContractPeriodId = :SelectedCpId
                          AND ((a.Year < :TY) OR (a.Year = :TY AND a.Month < :TM))
                          AND a.EmpID NOT LIKE 'GLOBAL%'
                          AND a.Day > 0";
                    histParams.Add(new OracleParameter("SelectedCpId", selectedCpId.Value));
                }
                else
                {
                    histQuery = @"
                        SELECT 
                            SUM(CASE WHEN (a.StatusValue = 0 AND a.LeaveType = 'Paid') OR a.LeaveType = 'Paired Paid' THEN 1 ELSE 0 END) as PrevFull,
                            SUM(CASE WHEN a.StatusValue = 0.5 THEN 1 ELSE 0 END) as PrevHalf
                        FROM Attendance a
                        JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                          AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                        JOIN EmployeeEngagements ee_curr ON a.EmpID = ee_curr.EmpID
                          AND ee_curr.StartDate <= :LastDay
                          AND (ee_curr.EndDate IS NULL OR ee_curr.EndDate >= :FirstDay)
                        WHERE a.EmpID = :EmpID
                          AND (ee_past.ContractPeriodId = ee_curr.ContractPeriodId OR (ee_past.ContractPeriodId IS NULL AND ee_curr.ContractPeriodId IS NULL AND ee_past.TierId = ee_curr.TierId))
                          AND ((a.Year < :TY) OR (a.Year = :TY AND a.Month < :TM))
                          AND a.EmpID NOT LIKE 'GLOBAL%'
                          AND a.Day > 0";
                    histParams.Add(new OracleParameter("LastDay", lastDay));
                    histParams.Add(new OracleParameter("FirstDay", firstDay));
                }
                
                DataTable dtHist = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), histQuery, histParams.ToArray());

                int prevFull = 0;
                int prevHalf = 0;
                if (dtHist.Rows.Count > 0)
                {
                    prevFull = dtHist.Rows[0]["PrevFull"] != DBNull.Value ? Convert.ToInt32(dtHist.Rows[0]["PrevFull"]) : 0;
                    prevHalf = dtHist.Rows[0]["PrevHalf"] != DBNull.Value ? Convert.ToInt32(dtHist.Rows[0]["PrevHalf"]) : 0;
                }

                double openingBalance = initialBalance - prevFull - (prevHalf * 0.5);

                // Query raw attendance rows for the current month
                string currQuery = @"
                    SELECT Day, StatusValue, IsHoliday, LeaveType, AutoSat, Remarks
                    FROM Attendance
                    WHERE EmpID = :EmpID AND Year = :TY AND Month = :TM AND EmpID NOT LIKE 'GLOBAL%' AND Day > 0";
                
                List<OracleParameter> currParams = new List<OracleParameter> {
                    new OracleParameter("EmpID", masterId),
                    new OracleParameter("TY", tY),
                    new OracleParameter("TM", tM)
                };

                if (cpStartDate.HasValue)
                {
                    currQuery += " AND TO_DATE(Year || '-' || (Month + 1) || '-' || Day, 'YYYY-MM-DD') >= :CpStartDate";
                    currParams.Add(new OracleParameter("CpStartDate", cpStartDate.Value));
                }
                if (cpEndDate.HasValue)
                {
                    currQuery += " AND TO_DATE(Year || '-' || (Month + 1) || '-' || Day, 'YYYY-MM-DD') <= :CpEndDate";
                    currParams.Add(new OracleParameter("CpEndDate", cpEndDate.Value));
                }

                DataTable dtCurr = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), currQuery, currParams.ToArray());

                int currFullPaid = 0;
                int currFullUnpaid = 0;
                int currSatCut = 0;
                int currHalfCount = 0;
                double currLegacyHalf = 0;
                
                List<string> remarksList = new List<string>();

                // Parse current month rows
                foreach (DataRow r in dtCurr.Rows)
                {
                    int day = Convert.ToInt32(r["Day"]);
                    float? val = r["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(r["StatusValue"]);
                    string leaveType = r["LeaveType"].ToString();
                    bool isHoliday = Convert.ToInt32(r["IsHoliday"]) == 1;
                    int autoSat = r.Table.Columns.Contains("AutoSat") && r["AutoSat"] != DBNull.Value ? Convert.ToInt32(r["AutoSat"]) : 1;
                    string cellRemarks = r.Table.Columns.Contains("Remarks") && r["Remarks"] != DBNull.Value ? r["Remarks"].ToString() : "";

                    DateTime cellDate = new DateTime(tY, tM + 1, day);

                    // Active engagement bounds check matching presentCount loop
                    bool isOutOfBounds = true;
                    foreach (var eng in empEngs)
                    {
                        if (cellDate >= eng.StartDate.Date && (!eng.EndDate.HasValue || cellDate <= eng.EndDate.Value.Date))
                        {
                            isOutOfBounds = false;
                            break;
                        }
                    }

                    // Special Friday resignation exception for Saturday:
                    if (isOutOfBounds && cellDate.DayOfWeek == DayOfWeek.Saturday)
                    {
                        DateTime prevFriday = cellDate.AddDays(-1);
                        if (resignDate.HasValue && resignDate.Value.Date == prevFriday.Date && resignDate.Value.DayOfWeek == DayOfWeek.Friday)
                        {
                            foreach (var eng in empEngs)
                            {
                                if (prevFriday >= eng.StartDate.Date && (!eng.EndDate.HasValue || prevFriday <= eng.EndDate.Value.Date))
                                {
                                    isOutOfBounds = false;
                                    break;
                                }
                            }
                        }
                    }

                    if (isOutOfBounds) continue;

                    if (isHoliday) continue;
                    if (cellDate.DayOfWeek == DayOfWeek.Sunday) continue;

                    // Check Saturday Edits & General Remarks
                    if (!string.IsNullOrEmpty(cellRemarks))
                    {
                        if (cellDate.DayOfWeek == DayOfWeek.Saturday && autoSat == 0)
                        {
                            remarksList.Add("Saturday edited: " + cellDate.ToString("yyyy-MM-dd") + " (Reason: " + cellRemarks + ")");
                        }
                        else
                        {
                            remarksList.Add(cellDate.ToString("yyyy-MM-dd") + ": " + cellRemarks);
                        }
                    }

                    if (val == 0.5f)
                    {
                        currLegacyHalf += 1.0;
                    }
                    else if (val == 0f)
                    {
                        if (leaveType == "Paid")
                        {
                            currFullPaid++;
                        }
                        else if (cellDate.DayOfWeek == DayOfWeek.Saturday)
                        {
                            currSatCut++;
                        }
                        else if (leaveType == "Unpaid")
                        {
                            currFullUnpaid++;
                        }
                        else if (leaveType == "Paired Unpaid")
                        {
                            // Handled in chronological pairing
                        }
                        else
                        {
                            currFullUnpaid++;
                        }
                    }
                }

                // Chronological half-day pairing & remarks
                // Fetch stint start date
                DateTime stintStartDate = new DateTime(1900, 1, 1);
                string stintQuery = @"
                    SELECT MIN(ee.StartDate) AS StintStartDate
                    FROM EmployeeEngagements ee
                    WHERE ee.EmpID = :EmpID AND ee.StartDate > COALESCE(
                        (SELECT MAX(ex.EndDate) FROM EmployeeEngagements ex WHERE ex.EmpID = ee.EmpID AND UPPER(ex.EndReason) = 'RESIGNED'),
                        TO_DATE('1900-01-01', 'YYYY-MM-DD')
                    )";
                DataTable dtStint = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), stintQuery, new OracleParameter("EmpID", masterId));
                if (dtStint.Rows.Count > 0 && dtStint.Rows[0]["StintStartDate"] != DBNull.Value)
                {
                    stintStartDate = Convert.ToDateTime(dtStint.Rows[0]["StintStartDate"]);
                }

                // Fetch all half-day records under the stint up to the end of the target month, restricted to the current contract period
                DateTime targetMonthLastDay = new DateTime(tY, tM + 1, 1).AddMonths(1).AddDays(-1);
                string halfDaysQuery;
                List<OracleParameter> halfParams = new List<OracleParameter> {
                    new OracleParameter("EmpID", masterId),
                    new OracleParameter("StintStartDate", stintStartDate),
                    new OracleParameter("LastDay", targetMonthLastDay)
                };

                if (selectedCpId.HasValue)
                {
                    halfDaysQuery = @"
                        SELECT a.Year, a.Month, a.Day, a.LeaveType
                        FROM Attendance a
                        JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                          AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                        WHERE a.EmpID = :EmpID
                          AND ee_past.ContractPeriodId = :SelectedCpId
                          AND a.LeaveType IN ('Carried', 'Paired Paid', 'Paired Unpaid')
                          AND a.EmpID NOT LIKE 'GLOBAL%'
                          AND a.Day > 0
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= :StintStartDate
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= :LastDay
                        ORDER BY a.Year ASC, a.Month ASC, a.Day ASC";
                    halfParams.Add(new OracleParameter("SelectedCpId", selectedCpId.Value));
                }
                else
                {
                    halfDaysQuery = @"
                        SELECT a.Year, a.Month, a.Day, a.LeaveType
                        FROM Attendance a
                        JOIN EmployeeEngagements ee_past ON a.EmpID = ee_past.EmpID
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= ee_past.StartDate
                          AND (ee_past.EndDate IS NULL OR TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= ee_past.EndDate)
                        JOIN EmployeeEngagements ee_curr ON a.EmpID = ee_curr.EmpID
                          AND ee_curr.StartDate <= :LastDay
                          AND (ee_curr.EndDate IS NULL OR ee_curr.EndDate >= :FirstDay)
                        WHERE a.EmpID = :EmpID
                          AND (ee_past.ContractPeriodId = ee_curr.ContractPeriodId OR (ee_past.ContractPeriodId IS NULL AND ee_curr.ContractPeriodId IS NULL AND ee_past.TierId = ee_curr.TierId))
                          AND a.LeaveType IN ('Carried', 'Paired Paid', 'Paired Unpaid')
                          AND a.EmpID NOT LIKE 'GLOBAL%'
                          AND a.Day > 0
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') >= :StintStartDate
                          AND TO_DATE(a.Year || '-' || (a.Month + 1) || '-' || a.Day, 'YYYY-MM-DD') <= :LastDay
                        ORDER BY a.Year ASC, a.Month ASC, a.Day ASC";
                    halfParams.Add(new OracleParameter("FirstDay", firstDay));
                }
                
                DataTable dtHalfDays = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), halfDaysQuery, halfParams.ToArray());

                List<Tuple<DateTime, DateTime, string>> completedPairs = new List<Tuple<DateTime, DateTime, string>>();
                DateTime? unpairedCarriedDate = null;
                
                for (int idx = 0; idx < dtHalfDays.Rows.Count; idx++)
                {
                    DataRow r = dtHalfDays.Rows[idx];
                    int yr = Convert.ToInt32(r["Year"]);
                    int mn = Convert.ToInt32(r["Month"]);
                    int dy = Convert.ToInt32(r["Day"]);
                    string leaveType = r["LeaveType"].ToString();
                    DateTime date = new DateTime(yr, mn + 1, dy);

                    int overallIdx = idx + 1;
                    if (overallIdx % 2 == 1)
                    {
                        unpairedCarriedDate = date;
                    }
                    else
                    {
                        if (unpairedCarriedDate.HasValue)
                        {
                            completedPairs.Add(Tuple.Create(unpairedCarriedDate.Value, date, leaveType));
                            unpairedCarriedDate = null;
                        }
                    }
                }

                if (unpairedCarriedDate.HasValue && unpairedCarriedDate.Value.Year == tY && unpairedCarriedDate.Value.Month == (tM + 1))
                {
                    currHalfCount = 1;
                }

                // Process completed pairs to update Paid, Unpaid, and Remarks
                int pairedPaidThisMonth = 0;
                int pairedUnpaidThisMonth = 0;

                foreach (var pair in completedPairs)
                {
                    DateTime firstDate = pair.Item1;
                    DateTime secondDate = pair.Item2;
                    string leaveType = pair.Item3;

                    // If the pair is completed in the target month
                    if (secondDate.Year == tY && secondDate.Month == (tM + 1))
                    {
                        remarksList.Add("2 half days: " + firstDate.ToString("yyyy-MM-dd") + " & " + secondDate.ToString("yyyy-MM-dd"));
                        if (leaveType == "Paired Paid")
                        {
                            pairedPaidThisMonth++;
                        }
                        else if (leaveType == "Paired Unpaid")
                        {
                            pairedUnpaidThisMonth++;
                        }
                    }
                }

                int totalPaid = currFullPaid + pairedPaidThisMonth;
                int totalUnpaid = currFullUnpaid + pairedUnpaidThisMonth;
                double totalHalf = (currHalfCount + currLegacyHalf) * 0.5;

                double totalDeductionThisMonth = totalPaid + (currLegacyHalf * 0.5);
                double closingBalance = openingBalance - totalDeductionThisMonth;

                // Re-calculate present days and final days
                Dictionary<int, AttCell> empAtt = new Dictionary<int, AttCell>();
                foreach (DataRow r in dtCurr.Rows)
                {
                    int day = Convert.ToInt32(r["Day"]);
                    float? val = r["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(r["StatusValue"]);
                    bool isHoliday = Convert.ToInt32(r["IsHoliday"]) == 1;
                    string leaveType = r["LeaveType"] == DBNull.Value ? "" : r["LeaveType"].ToString();
                    empAtt[day] = new AttCell { Val = val, IsHoliday = isHoliday, LeaveType = leaveType };
                }

                int daysInMonth = DateTime.DaysInMonth(tY, tM + 1);
                float presentCount = 0f;

                for (int d = 1; d <= daysInMonth; d++)
                {
                    DateTime currDate = new DateTime(tY, tM + 1, d);

                    // boundary check matching Attendance.aspx
                    bool isOutOfBounds = true;
                    foreach (var eng in empEngs)
                    {
                        if (currDate >= eng.StartDate.Date && (!eng.EndDate.HasValue || currDate <= eng.EndDate.Value.Date))
                        {
                            isOutOfBounds = false;
                            break;
                        }
                    }

                    // Special Friday resignation exception for Saturday:
                    // If the day is a Saturday, and the employee resigned on the preceding Friday, Saturday is treated as in-bounds.
                    if (isOutOfBounds && currDate.DayOfWeek == DayOfWeek.Saturday)
                    {
                        DateTime prevFriday = currDate.AddDays(-1);
                        if (resignDate.HasValue && resignDate.Value.Date == prevFriday.Date && resignDate.Value.DayOfWeek == DayOfWeek.Friday)
                        {
                            foreach (var eng in empEngs)
                            {
                                if (prevFriday >= eng.StartDate.Date && (!eng.EndDate.HasValue || prevFriday <= eng.EndDate.Value.Date))
                                {
                                    isOutOfBounds = false;
                                    break;
                                }
                            }
                        }
                    }

                    if (isOutOfBounds) continue;

                    AttCell cell = empAtt.ContainsKey(d) ? empAtt[d] : new AttCell { Val = null, IsHoliday = false, LeaveType = "" };

                    // Skip non-holiday Sundays
                    if (currDate.DayOfWeek == DayOfWeek.Sunday && !cell.IsHoliday) continue;

                    if (cell.IsHoliday)
                    {
                        presentCount += 1.0f;
                    }
                    else if (cell.LeaveType == "Carried")
                    {
                        presentCount += 1.0f;
                    }
                    else if (cell.LeaveType == "Paired Paid")
                    {
                        presentCount += 1.0f;
                    }
                    else if (cell.LeaveType == "Paired Unpaid")
                    {
                        // +0.0
                    }
                    else if (cell.Val == 1.0f)
                    {
                        presentCount += 1.0f;
                    }
                    else if (cell.Val == 0.5f)
                    {
                        presentCount += 0.5f;
                    }
                    else if (cell.Val == 0.0f)
                    {
                        if (cell.LeaveType == "Paid")
                        {
                            presentCount += 1.0f;
                        }
                    }
                }

                float catGlobalAdj = 0;
                string tierIdStr = row["TierId"].ToString();
                if (catGlobalAdjDict.ContainsKey(tierIdStr))
                {
                    catGlobalAdj = catGlobalAdjDict[tierIdStr];
                }
                float presentDays = presentCount + globalAdj + catGlobalAdj;

                // Determine final days & override remarks
                bool isOverridden = overDict.ContainsKey(masterId);
                float finalDays = isOverridden ? overDict[masterId].FinalDays : presentDays;
                string overrideRemarks = isOverridden ? overDict[masterId].Remarks : "";

                // Join/Resign date remarks (matching Attendance Certificate behavior)
                if (joinDate.HasValue && joinDate.Value.Year == tY && joinDate.Value.Month == (tM + 1))
                {
                    remarksList.Add("Joined on " + joinDate.Value.ToString("dd-MMM-yyyy"));
                }
                if (resignDate.HasValue && resignDate.Value.Year == tY && resignDate.Value.Month == (tM + 1))
                {
                    remarksList.Add("Resigned on " + resignDate.Value.ToString("dd-MMM-yyyy"));
                }

                if (isOverridden && !string.IsNullOrEmpty(overrideRemarks))
                {
                    remarksList.Add("Override reason: " + overrideRemarks);
                }

                // Populate Row
                DataRow dr = resultDt.NewRow();
                dr["ID"] = empId;
                dr["MasterID"] = masterId;
                dr["Name"] = row["Name"];
                dr["Department"] = row["Department"];
                dr["Category"] = row["Category"];
                dr["Opening"] = openingBalance;
                dr["Paid"] = totalPaid > 0 ? "-" + totalPaid : "0";
                dr["Half"] = totalHalf;
                dr["Unpaid"] = totalUnpaid;
                dr["SatCut"] = currSatCut;
                dr["Closing"] = closingBalance;
                dr["PresentDays"] = presentDays;
                dr["FinalDays"] = finalDays;
                dr["Remarks"] = string.Join("; ", remarksList);
                resultDt.Rows.Add(dr);
            }

            gvLedger.DataSource = resultDt;
            gvLedger.DataBind();

            // Fetch holiday dates of the target month
            List<string> holidayDetails = new List<string>();
            try
            {
                string holidayQuery = @"
                    SELECT Day, MAX(Remarks) AS Remarks 
                    FROM Attendance 
                    WHERE Year = :Year AND Month = :Month AND IsHoliday = 1 AND EmpID NOT LIKE 'GLOBAL%' AND Day > 0";
                List<OracleParameter> holParams = new List<OracleParameter> {
                    new OracleParameter("Year", tY),
                    new OracleParameter("Month", tM)
                };
                if (cpStartDate.HasValue)
                {
                    holidayQuery += " AND TO_DATE(Year || '-' || (Month + 1) || '-' || Day, 'YYYY-MM-DD') >= :CpStartDate";
                    holParams.Add(new OracleParameter("CpStartDate", cpStartDate.Value));
                }
                if (cpEndDate.HasValue)
                {
                    holidayQuery += " AND TO_DATE(Year || '-' || (Month + 1) || '-' || Day, 'YYYY-MM-DD') <= :CpEndDate";
                    holParams.Add(new OracleParameter("CpEndDate", cpEndDate.Value));
                }
                holidayQuery += " GROUP BY Day ORDER BY Day ASC";

                DataTable dtHolidays = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), holidayQuery, holParams.ToArray());
                foreach (DataRow r in dtHolidays.Rows)
                {
                    int d = Convert.ToInt32(r["Day"]);
                    string remark = r["Remarks"] == DBNull.Value ? "" : r["Remarks"].ToString().Trim();
                    try
                    {
                        DateTime dDate = new DateTime(tY, tM + 1, d);
                        string dayOfWeek = dDate.ToString("ddd");
                        string dateStr = dDate.ToString("yyyy-MM-dd");
                        string detail = string.Format("{0} ({1}, {2}){3}", 
                            d, 
                            dayOfWeek, 
                            dateStr, 
                            string.IsNullOrEmpty(remark) ? "" : " - " + remark);
                        holidayDetails.Add(detail);
                    }
                    catch
                    {
                        holidayDetails.Add(d.ToString());
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching holidays in Ledger: " + ex.Message);
            }

            if (pnlHolidayBadge != null) pnlHolidayBadge.Visible = true;
            if (lblHolidays != null)
            {
                if (holidayDetails.Count > 0)
                {
                    lblHolidays.Text = string.Join("; ", holidayDetails);
                }
                else
                {
                    lblHolidays.Text = "None";
                }
            }

            if (pnlGlobalAdjustBadge != null) pnlGlobalAdjustBadge.Visible = true;
            if (lblGlobalAdjust != null)
            {
                lblGlobalAdjust.Text = (globalAdj > 0 ? "+" : "") + globalAdj.ToString("0.0");
            }
        }

        protected string FormatRemarks(object remarksObj)
        {
            if (remarksObj == null || remarksObj == DBNull.Value) return "";
            string remarks = remarksObj.ToString();
            if (string.IsNullOrWhiteSpace(remarks)) return "";

            string[] parts = remarks.Split(new[] { "; " }, StringSplitOptions.RemoveEmptyEntries);
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("<div class='remarks-list'>");
            foreach (var part in parts)
            {
                sb.AppendFormat("<div class='remarks-item' title=\"{0}\">{1}</div>", 
                    System.Web.HttpUtility.HtmlAttributeEncode(part), 
                    System.Web.HttpUtility.HtmlEncode(part));
            }
            sb.Append("</div>");
            return sb.ToString();
        }

        private struct AttCell
        {
            public float? Val;
            public bool IsHoliday;
            public string LeaveType;
        }

        private class EngagementRange
        {
            public DateTime StartDate { get; set; }
            public DateTime? EndDate { get; set; }
        }

        private class OverrideInfo
        {
            public float FinalDays { get; set; }
            public string Remarks { get; set; }
        }
    }
}
