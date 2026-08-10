using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                if (role != 1 && role != 4)
                {
                    phAdmin_Emp.Visible       = false;
                    phAdmin_Calc.Visible      = false;
                    phAdmin_AdminMgmt.Visible = false;
                    phAdmin_Settings.Visible  = false;
                    phAdmin_Vendors.Visible   = false;
                    phAdmin_Contracts.Visible = false;
                    phAdmin_Wages.Visible     = false;
                    phAdmin_Remarks.Visible   = false;
                }

                CheckUnreadNotices();
                CheckAndBindRoleSwitcher();
            }
            else
            {
                CheckAndBindRoleSwitcher();
            }
        }

        private void CheckUnreadNotices()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                if (string.IsNullOrEmpty(pcno)) return;

                string query;
                DataTable dtUnread;

                if (role == 4) // Super Admin
                {
                    query = @"
                        SELECT n.Id, n.Name, n.MainCategoryId, mc.Name AS MainCategoryName
                        FROM Notices n
                        LEFT JOIN MainCategory mc ON n.MainCategoryId = mc.Id
                        WHERE n.IsHidden = 0
                          AND NOT EXISTS (
                              SELECT 1 FROM NoticeReads nr 
                              WHERE nr.NoticeId = n.Id AND nr.PCNO = :PCNO
                          )
                        ORDER BY n.UploadDate DESC";
                    dtUnread = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                }
                else if (role == 1) // Admin
                {
                    string roleMode = Session["RoleMode"]?.ToString() ?? "";
                    string mcCond = "";
                    if (roleMode == "PrimaryAdmin")
                    {
                        mcCond = "mc2.AdminPCNO = :PCNO";
                    }
                    else if (roleMode == "SecondaryAdmin")
                    {
                        mcCond = "mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)";
                    }
                    else
                    {
                        mcCond = "(mc2.AdminPCNO = :PCNO OR mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1))";
                    }

                    query = $@"
                        SELECT n.Id, n.Name, n.MainCategoryId, mc.Name AS MainCategoryName
                        FROM Notices n
                        LEFT JOIN MainCategory mc ON n.MainCategoryId = mc.Id
                        WHERE n.IsHidden = 0
                          AND (
                              n.MainCategoryId IS NULL
                              OR n.MainCategoryId IN (
                                  SELECT mc2.Id FROM MainCategory mc2 
                                  WHERE {mcCond}
                              )
                          )
                          AND NOT EXISTS (
                              SELECT 1 FROM NoticeReads nr 
                              WHERE nr.NoticeId = n.Id AND nr.PCNO = :PCNO
                          )
                        ORDER BY n.UploadDate DESC";
                    dtUnread = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                }
                else // Regular user / POC
                {
                    query = @"
                        SELECT n.Id, n.Name, n.MainCategoryId, mc.Name AS MainCategoryName
                        FROM Notices n
                        LEFT JOIN MainCategory mc ON n.MainCategoryId = mc.Id
                        WHERE n.IsHidden = 0
                          AND (
                              n.MainCategoryId IS NULL
                              OR n.MainCategoryId IN (
                                  SELECT t.MainCategoryId 
                                  FROM Tiers t 
                                  JOIN UserTiers ut ON t.Id = ut.TierId 
                                  WHERE ut.PCNO = :PCNO
                              )
                          )
                          AND NOT EXISTS (
                              SELECT 1 FROM NoticeReads nr 
                              WHERE nr.NoticeId = n.Id AND nr.PCNO = :PCNO
                          )
                        ORDER BY n.UploadDate DESC";
                    dtUnread = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                }

                if (dtUnread != null && dtUnread.Rows.Count > 0)
                {
                    phUnreadNoticeAlert.Visible = true;
                    int count = dtUnread.Rows.Count;
                    
                    List<string> mainCatNames = new List<string>();
                    foreach (DataRow r in dtUnread.Rows)
                    {
                        string mcName = r["MainCategoryName"] != DBNull.Value && !string.IsNullOrEmpty(r["MainCategoryName"].ToString()) 
                            ? r["MainCategoryName"].ToString() 
                            : "General";
                        if (!mainCatNames.Contains(mcName))
                            mainCatNames.Add(mcName);
                    }

                    string catLabel = string.Join(", ", mainCatNames);
                    litNoticeMainCatBadge.Text = "<span class='badge badge-info' style='font-size:0.75rem; background:#3b82f6; color:#fff;'><i class='fas fa-layer-group mr-1'></i>" + HttpUtility.HtmlEncode(catLabel) + "</span>";
                    
                    string firstTitle = dtUnread.Rows[0]["Name"].ToString();
                    if (count == 1)
                    {
                        litNoticeAlertMessage.Text = string.Format("You have 1 unread announcement: <strong>\"{0}\"</strong> for <strong>{1}</strong>.", HttpUtility.HtmlEncode(firstTitle), HttpUtility.HtmlEncode(catLabel));
                    }
                    else
                    {
                        litNoticeAlertMessage.Text = string.Format("You have <strong>{0}</strong> unread announcements for <strong>{1}</strong> (Latest: \"{2}\").", count, HttpUtility.HtmlEncode(catLabel), HttpUtility.HtmlEncode(firstTitle));
                    }
                }
                else
                {
                    phUnreadNoticeAlert.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking unread notices: " + ex.Message);
            }
        }

        private void CheckAndBindRoleSwitcher()
        {
            string pcno = Session["PCNO"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(pcno))
            {
                phDashboardRoleSwitcher.Visible = false;
                return;
            }

            var userRoles = Session["UserRoles"] as List<UserRoleOption>;
            if (userRoles == null || userRoles.Count == 0)
            {
                userRoles = DBHelper.GetAvailableUserRoles(pcno);
                Session["UserRoles"] = userRoles;
            }

            if (userRoles != null && userRoles.Count > 1)
            {
                phDashboardRoleSwitcher.Visible = true;
                string currentMode = Session["RoleMode"]?.ToString() ?? "";
                var currentObj = userRoles.Find(r => r.RoleMode == currentMode) ?? userRoles[0];

                lblDashRoleTitle.InnerText = currentObj.Title;
                lblDashRoleIcon.Attributes["class"] = currentObj.Icon + " mr-2";

                if (!IsPostBack)
                {
                    rptDashboardRoles.DataSource = userRoles;
                    rptDashboardRoles.DataBind();
                }
            }
            else
            {
                phDashboardRoleSwitcher.Visible = false;
            }
        }

        protected void rptDashboardRoles_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SwitchRole")
            {
                string targetMode = e.CommandArgument != null ? e.CommandArgument.ToString() : "";
                string pcno = Session["PCNO"]?.ToString() ?? "";

                var userRoles = Session["UserRoles"] as List<UserRoleOption>;
                if (userRoles == null || userRoles.Count == 0)
                {
                    userRoles = DBHelper.GetAvailableUserRoles(pcno);
                    Session["UserRoles"] = userRoles;
                }

                var selectedRole = userRoles.Find(r => r.RoleMode == targetMode);
                if (selectedRole != null)
                {
                    Session["Role"] = selectedRole.EffectiveRole;
                    Session["RoleMode"] = selectedRole.RoleMode;
                    Response.Redirect("Dashboard.aspx");
                }
            }
        }

        protected string GetRoleItemCssClass(object roleModeObj)
        {
            string roleMode = roleModeObj != null ? roleModeObj.ToString() : "";
            string currentMode = Session["RoleMode"] != null ? Session["RoleMode"].ToString() : "";
            if (string.Equals(roleMode, currentMode, StringComparison.OrdinalIgnoreCase))
            {
                return "dropdown-item active py-2 px-3 font-weight-bold";
            }
            return "dropdown-item py-2 px-3";
        }
    }
}
