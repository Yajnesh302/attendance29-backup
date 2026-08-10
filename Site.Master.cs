using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Security;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected int UnreadCount { get; private set; }
        protected List<string> UserAllowedDivisions { get; private set; }
        protected List<string> UserAllowedCategories { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Auto close expired contracts on page load
            try
            {
                AttendanceApp.Utils.DBHelper.AutoCloseExpiredContracts();
            }
            catch { }

            if (Session["PCNO"] == null && Page.User.Identity.IsAuthenticated)
            {
                // Session was lost (e.g., app rebuild) but auth cookie remains. Force logout.
                FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx");
                return;
            }

            int role = Convert.ToInt32(Session["Role"] ?? 0);
            string pcno = Session["PCNO"]?.ToString() ?? "";

            // Query unread remarks count for admin (server-side, no extra round-trip)
            if (role == 1 || role == 4)
            {
                try
                {
                    string sql = "SELECT COUNT(DISTINCT ar.SubmittedBy || '_' || ar.EmpID || '_' || ar.Message || '_' || TO_CHAR(ar.CreatedAt, 'YYYYMMDDHH24MISS')) FROM AttendanceRemarks ar WHERE ar.IsRead = 0";
                    object result = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), sql);
                    UnreadCount = result != null && result != System.DBNull.Value ? Convert.ToInt32(result) : 0;
                }
                catch { UnreadCount = 0; }
            }

            if (role == 1 || role == 4)
            {
                lblUserName.InnerText = (role == 4) ? "Super Admin" : "Administrator";
                myfw.Attributes["class"] = "fas fa-user-shield text-success";
                phEmployeeMaster.Visible = true;
                phCalculation.Visible = true;
            }
            else
            {
                lblUserName.InnerText = "User (POC)";
                myfw.Attributes["class"] = "fas fa-user";
                phEmployeeMaster.Visible = false;
                phCalculation.Visible = false;

                // Load User Accessible Divisions & Categories for Regular User (POC)
                try
                {
                    UserAllowedDivisions = new List<string>();
                    string sqlDivs = "SELECT DivisionName FROM UserDivisions WHERE PCNO = :PCNO ORDER BY DivisionName ASC";
                    DataTable dtDivs = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), sqlDivs, new OracleParameter("PCNO", pcno));
                    foreach (DataRow row in dtDivs.Rows)
                    {
                        if (row["DivisionName"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["DivisionName"].ToString()))
                        {
                            UserAllowedDivisions.Add(row["DivisionName"].ToString());
                        }
                    }

                    UserAllowedCategories = new List<string>();
                    string sqlCats = @"
                        SELECT DISTINCT t.TierName
                        FROM UserTiers ut 
                        JOIN Tiers t ON ut.TierId = t.Id 
                        WHERE ut.PCNO = :PCNO
                        ORDER BY t.TierName ASC";
                    DataTable dtCats = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), sqlCats, new OracleParameter("PCNO", pcno));
                    foreach (DataRow row in dtCats.Rows)
                    {
                        if (row["TierName"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["TierName"].ToString()))
                        {
                            UserAllowedCategories.Add(row["TierName"].ToString());
                        }
                    }
                }
                catch { }
            }

            // Toggle sidebar and top nav visibility based on the page
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath);
            bool isDashboard = currentPage.Equals("Dashboard.aspx", StringComparison.OrdinalIgnoreCase) ||
                               currentPage.Equals("Dashboard", StringComparison.OrdinalIgnoreCase);

            if (isDashboard)
            {
                phSidebar.Visible = true;
                phTopNav.Visible = false;
            }
            else
            {
                phSidebar.Visible = false;
                phTopNav.Visible = true;
            }

            int currentRole = Convert.ToInt32(Session["Role"] ?? 0);
            phNavAdminLinks.Visible = (currentRole == 1 || currentRole == 4);
            phNotifBell.Visible     = (currentRole == 1 || currentRole == 4);
            phStartTour.Visible     = isDashboard;
        }

        protected string GetNavClass(string pageName)
        {
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath);
            if (currentPage.Equals(pageName, StringComparison.OrdinalIgnoreCase))
            {
                return "nav-link active";
            }
            return "nav-link";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }
    }
}

