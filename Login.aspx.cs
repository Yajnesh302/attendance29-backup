using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    Response.Redirect("Dashboard.aspx");
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username))
            {
                ShowError("Username is required.");
                return;
            }

            string pcno = null;

            try
            {
                pcno = ADHelper.AuthenticateAndGetPCNO(username, password);
            }
            catch (Exception ex)
            {
                ShowError("AD Error: " + ex.Message);
                return;
            }

            if (string.IsNullOrEmpty(pcno))
            {
                ShowError("Invalid credentials or user not found in AD.");
                return;
            }

            // Fetch Base Role from AttendanceDB
            int baseRole = 0;
            try
            {
                string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = :PCNO AND ROWNUM <= 1";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new OracleParameter("PCNO", pcno));
                if (res == null || res == DBNull.Value)
                {
                    ShowError("Access denied. You are not authorized to log in. Please contact an administrator.");
                    return;
                }
                baseRole = Convert.ToInt32(res);

                if (baseRole == 2)
                {
                    ShowError("Access denied. Your administrator access has been revoked. Please contact a system administrator.");
                    return;
                }
                if (baseRole == 3)
                {
                    ShowError("Access denied. Your regular user access has been revoked. Please contact a system administrator.");
                    return;
                }
            }
            catch (Exception ex)
            {
                ShowError("Database Connection Error: Could not connect to Attendance Database. Please verify database services are running. " + ex.Message);
                return;
            }

            // Detect all available access roles for this user
            List<UserRoleOption> roles = DBHelper.GetAvailableUserRoles(pcno);

            if (roles == null || roles.Count == 0)
            {
                ShowError("Access denied. No active roles found for your account.");
                return;
            }

            // Store temporary login context in session
            Session["PendingPCNO"] = pcno;
            Session["PendingRoles"] = roles;

            if (roles.Count == 1)
            {
                // Single role available: complete login directly
                CompleteUserLogin(pcno, roles[0], roles);
            }
            else
            {
                // Multiple roles available: show interactive Role Selection Panel
                string displayName = pcno;
                try
                {
                    string nameQuery = "SELECT Name FROM AppUsers WHERE PCNO = :PCNO AND ROWNUM <= 1";
                    object nameRes = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), nameQuery, new OracleParameter("PCNO", pcno));
                    if (nameRes != null && nameRes != DBNull.Value && !string.IsNullOrEmpty(nameRes.ToString()))
                    {
                        displayName = nameRes.ToString();
                    }
                }
                catch { }

                lblRoleSelectionUserName.Text = displayName;
                rptRoleOptions.DataSource = roles;
                rptRoleOptions.DataBind();

                pnlLoginForm.Visible = false;
                pnlRoleSelection.Visible = true;
                lblError.Visible = false;
            }
        }

        protected void rptRoleOptions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectRole")
            {
                string selectedMode = e.CommandArgument != null ? e.CommandArgument.ToString() : "";
                string pcno = Session["PendingPCNO"] as string;
                List<UserRoleOption> roles = Session["PendingRoles"] as List<UserRoleOption>;

                if (string.IsNullOrEmpty(pcno) || roles == null)
                {
                    ShowError("Session expired. Please log in again.");
                    pnlRoleSelection.Visible = false;
                    pnlLoginForm.Visible = true;
                    return;
                }

                UserRoleOption targetRole = roles.Find(r => r.RoleMode == selectedMode);
                if (targetRole == null)
                {
                    targetRole = roles[0];
                }

                CompleteUserLogin(pcno, targetRole, roles);
            }
        }

        protected void btnCancelRoleSelection_Click(object sender, EventArgs e)
        {
            Session["PendingPCNO"] = null;
            Session["PendingRoles"] = null;
            pnlRoleSelection.Visible = false;
            pnlLoginForm.Visible = true;
            lblError.Visible = false;
        }

        private void CompleteUserLogin(string pcno, UserRoleOption selectedRole, List<UserRoleOption> availableRoles)
        {
            // Load allowed divisions for regular user
            List<string> allowedDivisions = new List<string>();
            if (selectedRole.EffectiveRole != 1 && selectedRole.EffectiveRole != 4)
            {
                try
                {
                    DBHelper.EnsureDivisionsTableExists();
                    string queryDivs = "SELECT DivisionName FROM UserDivisions WHERE PCNO = :PCNO";
                    DataTable dtDivs = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryDivs, new OracleParameter("PCNO", pcno));
                    foreach (DataRow row in dtDivs.Rows)
                    {
                        allowedDivisions.Add(row["DivisionName"].ToString());
                    }
                    if (allowedDivisions.Count == 0)
                    {
                        allowedDivisions.Add("D-USER");
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error fetching user divisions: " + ex.Message);
                }
            }

            // Fetch Name/Division from CompanyDB (hrdata.empdetails)
            string division = "";
            string name = "User";
            string designation = "";
            try
            {
                string queryDiv = "SELECT NAME, DESIGNATION, DIVNAME FROM hrdata.empdetails WHERE PCNO = :PCNO AND ROWNUM <= 1";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetCompanyDBConnection(), queryDiv, new OracleParameter("PCNO", pcno));
                if (dt.Rows.Count > 0)
                {
                    name        = dt.Rows[0]["NAME"].ToString();
                    designation = dt.Rows[0]["DESIGNATION"].ToString();
                    division    = dt.Rows[0]["DIVNAME"].ToString();
                }
                else
                {
                    if (selectedRole.EffectiveRole == 1 || selectedRole.EffectiveRole == 4)
                    {
                        name        = selectedRole.EffectiveRole == 4 ? "Super Admin" : "Admin";
                        designation = selectedRole.EffectiveRole == 4 ? "Super Administrator" : "System Administrator";
                        division    = "D-ADMIN";
                    }
                    else
                    {
                        try
                        {
                            string queryName = "SELECT Name FROM AppUsers WHERE PCNO = :PCNO AND ROWNUM <= 1";
                            object nameRes = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryName, new OracleParameter("PCNO", pcno));
                            name = (nameRes != null && nameRes != DBNull.Value) ? nameRes.ToString() : pcno;
                        }
                        catch { name = pcno; }
                        designation = "";
                        division    = allowedDivisions.Count > 0 ? allowedDivisions[0] : "";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error connecting to HR DB: " + ex.Message);
            }

            // Store in Session
            Session["PCNO"] = pcno;
            Session["Role"] = selectedRole.EffectiveRole;
            Session["RoleMode"] = selectedRole.RoleMode;
            Session["UserRoles"] = availableRoles;
            Session["Name"] = name;
            Session["Designation"] = designation;
            Session["AllowedDivisions"] = allowedDivisions;

            if (selectedRole.EffectiveRole == 1 || selectedRole.EffectiveRole == 4)
            {
                string divPrefix = string.IsNullOrEmpty(division) ? "D-ADMIN" : division;
                if (divPrefix.Contains("/"))
                {
                    divPrefix = divPrefix.Split('/')[0].Trim();
                }
                Session["Division"] = divPrefix;
            }
            else
            {
                Session["Division"] = allowedDivisions.Count > 0 ? allowedDivisions[0] : "D-USER";
            }

            try
            {
                string updateNameQuery = @"
                    MERGE INTO AppUsers t
                    USING (SELECT :PCNO as PCNO, :Name as Name FROM DUAL) s
                    ON (t.PCNO = s.PCNO)
                    WHEN MATCHED THEN
                      UPDATE SET t.Name = s.Name
                    WHEN NOT MATCHED THEN
                      INSERT (PCNO, Name, Role) VALUES (s.PCNO, s.Name, :Role)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateNameQuery,
                    new OracleParameter("PCNO", pcno),
                    new OracleParameter("Name", name),
                    new OracleParameter("Role", selectedRole.EffectiveRole));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating user name on login: " + ex.Message);
            }

            FormsAuthentication.SetAuthCookie(pcno, false);
            Response.Redirect("Dashboard.aspx");
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }
    }
}
