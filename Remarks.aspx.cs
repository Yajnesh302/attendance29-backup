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
    public partial class Remarks : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                Response.Redirect("Dashboard.aspx");
            }
        }

        // ─── ADMIN WebMethods ────────────────────────────────────────────

        [WebMethod]
        public static string GetAllRemarks()
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            if (role != 1 && role != 4) return "[]";
            string pcno = HttpContext.Current.Session["PCNO"]?.ToString() ?? "";

            string sql;
            List<OracleParameter> pList = new List<OracleParameter>();

            if (role == 4) // Super Admin sees all remarks with MainCategoryName
            {
                sql = @"
                    SELECT ar.Id, ar.SubmittedBy, ar.SenderName, ar.EmpID, ar.RemarkDate,
                           ar.Message, ar.IsRead, ar.CreatedAt, ar.MainCategoryId,
                           NVL(mc.Name, NVL(mc_emp.Name, 'General')) AS MainCategoryName,
                           NVL(e.Name, '(Unknown)') AS EmpName,
                           NVL(e.ID, ar.EmpID) AS EmpIDDisplay
                    FROM AttendanceRemarks ar
                    LEFT JOIN MainCategory mc ON ar.MainCategoryId = mc.Id
                    LEFT JOIN Employees e ON e.MasterId = ar.EmpID
                    LEFT JOIN Tiers t ON e.TierId = t.Id
                    LEFT JOIN MainCategory mc_emp ON t.MainCategoryId = mc_emp.Id
                    ORDER BY ar.CreatedAt DESC, ar.RemarkDate ASC";
            }
            else // Admin (Role 1) sees only remarks for owned/shared MainCategories
            {
                string roleMode = HttpContext.Current.Session["RoleMode"]?.ToString() ?? "";
                string mcFilterCond = "";
                if (roleMode == "PrimaryAdmin")
                {
                    mcFilterCond = "mc2.AdminPCNO = :PCNO";
                }
                else if (roleMode == "SecondaryAdmin")
                {
                    mcFilterCond = "mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)";
                }
                else
                {
                    mcFilterCond = "(mc2.AdminPCNO = :PCNO OR mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1))";
                }

                sql = $@"
                    SELECT ar.Id, ar.SubmittedBy, ar.SenderName, ar.EmpID, ar.RemarkDate,
                           ar.Message, ar.IsRead, ar.CreatedAt, ar.MainCategoryId,
                           NVL(mc.Name, NVL(mc_emp.Name, 'General')) AS MainCategoryName,
                           NVL(e.Name, '(Unknown)') AS EmpName,
                           NVL(e.ID, ar.EmpID) AS EmpIDDisplay
                    FROM AttendanceRemarks ar
                    LEFT JOIN MainCategory mc ON ar.MainCategoryId = mc.Id
                    LEFT JOIN Employees e ON e.MasterId = ar.EmpID
                    LEFT JOIN Tiers t ON e.TierId = t.Id
                    LEFT JOIN MainCategory mc_emp ON t.MainCategoryId = mc_emp.Id
                    WHERE (
                        ar.MainCategoryId IN (
                            SELECT mc2.Id FROM MainCategory mc2 
                            WHERE {mcFilterCond}
                        )
                        OR t.MainCategoryId IN (
                            SELECT mc2.Id FROM MainCategory mc2 
                            WHERE {mcFilterCond}
                        )
                    )
                    ORDER BY ar.CreatedAt DESC, ar.RemarkDate ASC";
                pList.Add(new OracleParameter("PCNO", pcno));
            }

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), sql, pList.ToArray());
            var list = new List<object>();

            string lastKey = null;
            dynamic currentGroup = null;
            List<string> currentDates = null;
            List<int> currentIds = null;

            foreach (DataRow dr in dt.Rows)
            {
                string msg = dr["Message"].ToString();
                string empId = dr["EmpID"].ToString();
                string submittedBy = dr["SubmittedBy"].ToString();
                DateTime createdAt = Convert.ToDateTime(dr["CreatedAt"]);
                DateTime remarkDate = Convert.ToDateTime(dr["RemarkDate"]);
                string remarkDateStr = remarkDate.ToString("dd-MMM-yyyy");
                int id = Convert.ToInt32(dr["Id"]);

                string key = submittedBy + "_" + empId + "_" + msg + "_" + createdAt.ToString("yyyyMMddHHmmssfff");

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
                        { "Id",               id },
                        { "SubmittedBy",      submittedBy },
                        { "SenderName",       dr["SenderName"].ToString() },
                        { "EmpID",            dr["EmpIDDisplay"].ToString() },
                        { "EmpMasterId",      empId },
                        { "EmpName",          dr["EmpName"].ToString() },
                        { "MainCategoryName", dr["MainCategoryName"]?.ToString() ?? "General" },
                        { "RemarkDateStr",    "" },
                        { "Message",          msg },
                        { "IsRead",           Convert.ToInt32(dr["IsRead"]) == 1 },
                        { "CreatedAtStr",     createdAt.ToString("dd-MMM-yyyy hh:mm tt") },
                        { "Ids",              new List<int>() } // filled later
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
        public static void MarkRead(string ids)
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            if (role != 1 && role != 4 || string.IsNullOrEmpty(ids)) return;

            var idList = new List<int>();
            foreach (var s in ids.Split(','))
            {
                int val;
                if (int.TryParse(s, out val)) idList.Add(val);
            }
            if (idList.Count == 0) return;

            string sql = "UPDATE AttendanceRemarks SET IsRead = 1 WHERE Id IN (" + string.Join(",", idList) + ")";
            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), sql);
        }

        [WebMethod]
        public static void MarkAllRead()
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            if (role != 1 && role != 4) return;
            string sql = "UPDATE AttendanceRemarks SET IsRead = 1 WHERE IsRead = 0";
            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), sql);
        }

        [WebMethod]
        public static void DeleteRemark(string ids)
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            if (role != 1 && role != 4 || string.IsNullOrEmpty(ids)) return;

            var idList = new List<int>();
            foreach (var s in ids.Split(','))
            {
                int val;
                if (int.TryParse(s, out val)) idList.Add(val);
            }
            if (idList.Count == 0) return;

            string sql = "DELETE FROM AttendanceRemarks WHERE Id IN (" + string.Join(",", idList) + ")";
            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), sql);
        }

        // ─── Shared — unread count (used by Site.Master AJAX) ───────────

        [WebMethod]
        public static int GetUnreadCount()
        {
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            if (role != 1 && role != 4) return 0;
            string sql = "SELECT COUNT(DISTINCT ar.SubmittedBy || '_' || ar.EmpID || '_' || ar.Message || '_' || TO_CHAR(ar.CreatedAt, 'YYYYMMDDHH24MISS')) FROM AttendanceRemarks ar WHERE ar.IsRead = 0";
            object result = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), sql);
            return result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
        }
    }
}
