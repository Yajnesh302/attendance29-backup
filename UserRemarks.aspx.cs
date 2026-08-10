using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class UserRemarks : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }
            // Admins use Remarks.aspx, not this page
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role == 1 || role == 4)
            {
                Response.Redirect("Remarks.aspx");
            }
        }

        // ── Submit a remark ───────────────────────────────────────────────

        [WebMethod]
        public static string SubmitRemark(string empId, List<string> remarkDates, string message)
        {
            string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
            string name = HttpContext.Current.Session["Name"]?.ToString() ?? "Unknown";

            if (string.IsNullOrWhiteSpace(pcno))
                return "{\"error\":\"Not authenticated\"}";
            if (string.IsNullOrWhiteSpace(empId) || remarkDates == null || remarkDates.Count == 0 || string.IsNullOrWhiteSpace(message))
                return "{\"error\":\"All fields are required\"}";

            message = message.Trim();
            if (message.Length > 1000) message = message.Substring(0, 1000);

            DateTime createdAt = DateTime.Now;

            using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
            {
                conn.Open();
                using (OracleTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        object mainCatVal = DBNull.Value;
                        string getMcSql = "SELECT t.MainCategoryId FROM Employees e JOIN Tiers t ON e.TierId = t.Id WHERE e.MasterId = :EmpID";
                        using (OracleCommand cmdMc = new OracleCommand(getMcSql, conn))
                        {
                            cmdMc.Transaction = trans;
                            cmdMc.Parameters.Add(new OracleParameter("EmpID", empId));
                            object mcRes = cmdMc.ExecuteScalar();
                            if (mcRes != null && mcRes != DBNull.Value) mainCatVal = Convert.ToInt32(mcRes);
                        }

                        foreach (string dateStr in remarkDates)
                        {
                            DateTime parsedDate;
                            if (!DateTime.TryParse(dateStr, out parsedDate))
                                return "{\"error\":\"Invalid date format: " + dateStr + "\"}";

                            string sql = @"INSERT INTO AttendanceRemarks (SubmittedBy, SenderName, EmpID, RemarkDate, Message, IsRead, CreatedAt, MainCategoryId)
                                           VALUES (:SubmittedBy, :SenderName, :EmpID, :RemarkDate, :Message, 0, :CreatedAt, :MainCategoryId)";
                            using (OracleCommand cmd = new OracleCommand(sql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("SubmittedBy", pcno));
                                cmd.Parameters.Add(new OracleParameter("SenderName",  name));
                                cmd.Parameters.Add(new OracleParameter("EmpID",       empId));
                                cmd.Parameters.Add(new OracleParameter("RemarkDate",  parsedDate));
                                cmd.Parameters.Add(new OracleParameter("Message",     message));
                                cmd.Parameters.Add(new OracleParameter("CreatedAt",   createdAt));
                                cmd.Parameters.Add(new OracleParameter("MainCategoryId", mainCatVal));
                                cmd.ExecuteNonQuery();
                            }
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        return "{\"error\":\"" + ex.Message + "\"}";
                    }
                }
            }

            return "{\"status\":\"success\"}";
        }

        // ── Get remarks submitted by the current user ─────────────────────

        [WebMethod]
        public static string GetMyRemarks()
        {
            string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
            if (string.IsNullOrWhiteSpace(pcno)) return "[]";

            string sql = @"
                SELECT ar.Id, ar.EmpID, ar.RemarkDate,
                       ar.Message, ar.IsRead, ar.CreatedAt,
                       NVL(e.Name, '(Unknown)') AS EmpName,
                       NVL(e.ID,   ar.EmpID)    AS EmpIDDisplay
                FROM AttendanceRemarks ar
                LEFT JOIN Employees e ON e.MasterId = ar.EmpID
                WHERE ar.SubmittedBy = :PCNO
                ORDER BY ar.CreatedAt DESC, ar.RemarkDate ASC";

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), sql,
                new OracleParameter("PCNO", pcno));

            var list = new List<object>();
            string lastKey = null;
            dynamic currentGroup = null;
            List<string> currentDates = null;
            List<int> currentIds = null;

            foreach (DataRow dr in dt.Rows)
            {
                string msg = dr["Message"].ToString();
                string empId = dr["EmpID"].ToString();
                DateTime createdAt = Convert.ToDateTime(dr["CreatedAt"]);
                DateTime remarkDate = Convert.ToDateTime(dr["RemarkDate"]);
                string remarkDateStr = remarkDate.ToString("dd-MMM-yyyy");
                int id = Convert.ToInt32(dr["Id"]);

                string key = empId + "_" + msg + "_" + createdAt.ToString("yyyyMMddHHmmssfff");

                if (key == lastKey)
                {
                    if (currentDates != null && !currentDates.Contains(remarkDateStr))
                    {
                        currentDates.Add(remarkDateStr);
                    }
                    if (currentIds != null && !currentIds.Contains(id))
                    {
                        currentIds.Add(id);
                    }
                }
                else
                {
                    if (currentGroup != null)
                    {
                        currentGroup["RemarkDateStr"] = string.Join(", ", currentDates);
                        currentGroup["Ids"] = currentIds;
                        list.Add(currentGroup);
                    }

                    lastKey = key;
                    currentDates = new List<string> { remarkDateStr };
                    currentIds = new List<int> { id };
                    currentGroup = new Dictionary<string, object> {
                        { "Id",           id },
                        { "EmpName",      dr["EmpName"].ToString() },
                        { "EmpIDDisplay", dr["EmpIDDisplay"].ToString() },
                        { "EmpMasterId",  empId },
                        { "RemarkDateStr", "" },
                        { "Message",      msg },
                        { "IsRead",       Convert.ToInt32(dr["IsRead"]) == 1 },
                        { "CreatedAtStr", createdAt.ToString("dd-MMM-yyyy hh:mm tt") },
                        { "Ids",          new List<int>() }
                    };
                }
            }
            if (currentGroup != null)
            {
                currentGroup["RemarkDateStr"] = string.Join(", ", currentDates);
                currentGroup["Ids"] = currentIds;
                list.Add(currentGroup);
            }

            return new JavaScriptSerializer().Serialize(list);
        }

        [WebMethod]
        public static string DeleteMyRemark(string ids)
        {
            string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";
            if (string.IsNullOrWhiteSpace(pcno) || string.IsNullOrEmpty(ids))
                return "{\"error\":\"Not authenticated\"}";

            var idList = new List<int>();
            foreach (var s in ids.Split(','))
            {
                int val;
                if (int.TryParse(s, out val)) idList.Add(val);
            }
            if (idList.Count == 0)
                return "{\"error\":\"No valid IDs provided\"}";

            try
            {
                string sql = "DELETE FROM AttendanceRemarks WHERE SubmittedBy = :PCNO AND Id IN (" + string.Join(",", idList) + ")";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), sql,
                    new OracleParameter("PCNO", pcno));
                return "{\"status\":\"success\"}";
            }
            catch (Exception ex)
            {
                return "{\"error\":\"" + ex.Message + "\"}";
            }
        }

        // ── Get employees the current user is allowed to pick from ────────

        [WebMethod]
        public static string GetEmployeesForRemark()
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);

            string sql = @"SELECT MasterId, ID, Name, Department, JoinDate,
                                  ContractEndDate, ResignDate
                           FROM Employees
                            WHERE MasterId NOT LIKE 'GLOBAL%' AND Status <> 'System'
                              AND Status IN ('Active','Upgraded','Downgraded','Transferred')";

            var parms = new List<OracleParameter>();

            if (role != 1 && role != 4)
            {
                var allowedDivs = HttpContext.Current.Session["AllowedDivisions"] as List<string>;
                if (allowedDivs != null && allowedDivs.Count > 0)
                {
                    var clauses = new List<string>();
                    for (int i = 0; i < allowedDivs.Count; i++)
                    {
                        string pName = "Div" + i;
                        clauses.Add("Department LIKE :" + pName);
                        parms.Add(new OracleParameter(pName, allowedDivs[i] + "%"));
                    }
                    sql += " AND (" + string.Join(" OR ", clauses) + ")";
                }
                else
                {
                    sql += " AND 1=0";
                }
            }

            sql += " ORDER BY Name ASC";
            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), sql, parms.ToArray());

            var list = new List<object>();
            foreach (DataRow dr in dt.Rows)
            {
                string joinDate  = dr["JoinDate"]       != DBNull.Value ? Convert.ToDateTime(dr["JoinDate"]).ToString("yyyy-MM-dd")       : null;
                string contractE = dr["ContractEndDate"] != DBNull.Value ? Convert.ToDateTime(dr["ContractEndDate"]).ToString("yyyy-MM-dd") : null;
                string resignD   = dr["ResignDate"]     != DBNull.Value ? Convert.ToDateTime(dr["ResignDate"]).ToString("yyyy-MM-dd")     : null;
                string endDate   = resignD ?? contractE;

                list.Add(new {
                    MasterId = dr["MasterId"].ToString(),
                    ID       = dr["ID"].ToString(),
                    Name     = dr["Name"].ToString(),
                    JoinDate = joinDate,
                    EndDate  = endDate
                });
            }
            return new JavaScriptSerializer().Serialize(list);
        }
    }
}
