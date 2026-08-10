using System;
using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using AttendanceApp.Utils;

namespace AttendanceApp
{
    public partial class AdminManagement : System.Web.UI.Page
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
                return;
            }

            // Ensure the Name column exists and setup tables
            EnsureNameColumnExists();
            EnsureUserDivisionsTableExists();

            if (!IsPostBack)
            {
                // Set default tab based on role
                hfActiveTab.Value = "NonAdmins";

                // Configure tabs visibility
                if (role == 4) // Super Admin
                {
                    liTabAdmins.Visible = true;
                    liTabSuperAdmins.Visible = true;
                    liTabShareGrants.Visible = true;
                    liTabNonAdmins.Visible = true;
                }
                else // Regular Admin
                {
                    liTabAdmins.Visible = false;
                    liTabSuperAdmins.Visible = false;
                    liTabShareGrants.Visible = true;
                    liTabNonAdmins.Visible = true;
                }

                PopulateUserDivisions();
                PopulateUserTiersChecklist();
                PopulateShareCategories();
                PopulateShareGuestAdmins();
                BindAdminGrid();
            }
        }

        #region Navigation & Counts

        protected void btnTabNonAdmins_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "NonAdmins";
            BindAdminGrid();
        }

        protected void btnTabAdmins_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "Admins";
            BindAdminGrid();
        }

        protected void btnTabSuperAdmins_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "SuperAdmins";
            BindAdminGrid();
        }

        protected void btnTabShareGrants_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "ShareGrants";
            ResetShareForm();
            BindAdminGrid();
        }

        public int GetAdminCount()
        {
            try
            {
                string q = @"SELECT COUNT(DISTINCT u.PCNO) FROM AppUsers u 
                             WHERE u.Role = 1 OR u.Role = 2 
                                OR u.PCNO IN (SELECT AdminPCNO FROM MainCategory WHERE AdminPCNO IS NOT NULL)
                                OR u.PCNO IN (SELECT SharedWithPCNO FROM CategoryShareGrant WHERE IsActive = 1)";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q);
                return res != null ? Convert.ToInt32(res) : 0;
            }
            catch { return 0; }
        }

        public int GetNonAdminCount()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                string q;
                OracleParameter[] pars;
                if (role == 4)
                {
                    q = @"SELECT COUNT(DISTINCT u.PCNO) FROM AppUsers u 
                          WHERE (u.Role = 0 OR u.Role = 3 OR u.PCNO IN (SELECT PCNO FROM UserDivisions) OR u.PCNO IN (SELECT PCNO FROM UserTiers)) 
                            AND (u.Role != 4 AND u.Role != 5)";
                    pars = new OracleParameter[0];
                }
                else
                {
                    q = @"SELECT COUNT(DISTINCT u.PCNO) FROM AppUsers u
                          WHERE (u.Role = 0 OR u.Role = 3 OR u.PCNO IN (SELECT PCNO FROM UserDivisions) OR u.PCNO IN (SELECT PCNO FROM UserTiers))
                            AND (u.Role != 4 AND u.Role != 5)
                            AND (
                                u.PCNO IN (
                                    SELECT ut.PCNO FROM UserTiers ut 
                                    WHERE ut.TierId IN (
                                        SELECT t2.Id FROM Tiers t2 
                                        JOIN MainCategory mc2 ON t2.MainCategoryId = mc2.Id 
                                        WHERE mc2.AdminPCNO = :PCNO 
                                           OR mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                                    )
                                )
                                OR NOT EXISTS (SELECT 1 FROM UserTiers ut2 WHERE ut2.PCNO = u.PCNO)
                            )";
                    pars = new OracleParameter[] { new OracleParameter("PCNO", pcno) };
                }
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q, pars);
                return res != null ? Convert.ToInt32(res) : 0;
            }
            catch { return 0; }
        }

        public int GetSuperAdminCount()
        {
            try
            {
                string q = "SELECT COUNT(*) FROM AppUsers WHERE Role = 4 OR Role = 5";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q);
                return res != null ? Convert.ToInt32(res) : 0;
            }
            catch { return 0; }
        }

        public int GetShareGrantsCount()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                string q;
                OracleParameter[] pars;
                if (role == 4)
                {
                    q = "SELECT COUNT(*) FROM CategoryShareGrant";
                    pars = new OracleParameter[0];
                }
                else
                {
                    q = "SELECT COUNT(*) FROM CategoryShareGrant WHERE OwnerAdminPCNO = :PCNO OR SharedWithPCNO = :PCNO";
                    pars = new OracleParameter[] { new OracleParameter("PCNO", pcno) };
                }
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q, pars);
                return res != null ? Convert.ToInt32(res) : 0;
            }
            catch { return 0; }
        }

        #endregion

        #region Populating Lists

        private void PopulateUserDivisions()
        {
            try
            {
                cblUserDivisions.Items.Clear();
                DataTable dt = DBHelper.GetCompanyDivisionsDataTable();
                foreach (DataRow row in dt.Rows)
                {
                    cblUserDivisions.Items.Add(new System.Web.UI.WebControls.ListItem(row["Name"].ToString(), row["Name"].ToString()));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating divisions: " + ex.Message);
            }
        }

        private void PopulateUserTiersChecklist()
        {
            try
            {
                cblUserTiers.Items.Clear();
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                DataTable dt = DBHelper.GetVisibleTiersDataTable(pcno, role);
                foreach (DataRow row in dt.Rows)
                {
                    cblUserTiers.Items.Add(new System.Web.UI.WebControls.ListItem(row["DisplayName"].ToString(), row["TierId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating tiers: " + ex.Message);
            }
        }

        private void PopulateShareCategories()
        {
            try
            {
                // Save current selection if any
                string prevSelectedCat = ddlShareCategory.SelectedValue;

                ddlShareCategory.Items.Clear();
                string pcno = Session["PCNO"]?.ToString() ?? "";
                int role = Convert.ToInt32(Session["Role"] ?? 0);

                // Get target guest PCNO
                string targetGuestPCNO = "";
                if (!string.IsNullOrEmpty(txtShareGuestPCNO.Text.Trim()))
                {
                    targetGuestPCNO = txtShareGuestPCNO.Text.Trim();
                }
                else if (!string.IsNullOrEmpty(ddlShareGuestAdmin.SelectedValue))
                {
                    targetGuestPCNO = ddlShareGuestAdmin.SelectedValue;
                }

                string query;
                List<OracleParameter> pars = new List<OracleParameter>();
                if (role == 4)
                {
                    query = "SELECT Id, Name FROM MainCategory";
                    if (!string.IsNullOrEmpty(targetGuestPCNO))
                    {
                        query += " WHERE AdminPCNO IS NULL OR AdminPCNO != :GuestPCNO";
                        pars.Add(new OracleParameter("GuestPCNO", targetGuestPCNO));
                    }
                    query += " ORDER BY Name ASC";
                }
                else
                {
                    query = "SELECT Id, Name FROM MainCategory WHERE AdminPCNO = :PCNO";
                    pars.Add(new OracleParameter("PCNO", pcno));
                    if (!string.IsNullOrEmpty(targetGuestPCNO))
                    {
                        query += " AND (AdminPCNO IS NULL OR AdminPCNO != :GuestPCNO)";
                        pars.Add(new OracleParameter("GuestPCNO", targetGuestPCNO));
                    }
                    query += " ORDER BY Name ASC";
                }

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pars.ToArray());
                
                foreach (DataRow row in dt.Rows)
                {
                    ddlShareCategory.Items.Add(new System.Web.UI.WebControls.ListItem(row["Name"].ToString(), row["Id"].ToString()));
                }

                if (ddlShareCategory.Items.Count > 0)
                {
                    // Try to restore previous selection if it is still valid
                    if (!string.IsNullOrEmpty(prevSelectedCat) && ddlShareCategory.Items.FindByValue(prevSelectedCat) != null)
                    {
                        ddlShareCategory.SelectedValue = prevSelectedCat;
                    }
                    else
                    {
                        ddlShareCategory.SelectedIndex = 0;
                    }
                    PopulateShareTiers(Convert.ToInt32(ddlShareCategory.SelectedValue));
                    PopulateShareGuestAdmins();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating share categories: " + ex.Message);
            }
        }

        private void PopulateShareTiers(int mcId)
        {
            try
            {
                cblShareTiers.Items.Clear();
                string query = "SELECT Id, TierName || NVL2(RoleLabel, ' (#' || RoleLabel || ')', '') AS DisplayName FROM Tiers WHERE MainCategoryId = :MCId ORDER BY SortOrder ASC, TierName ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("MCId", mcId));
                foreach (DataRow row in dt.Rows)
                {
                    cblShareTiers.Items.Add(new System.Web.UI.WebControls.ListItem(row["DisplayName"].ToString(), row["Id"].ToString()));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating share tiers: " + ex.Message);
            }
        }

        protected void ddlShareCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlShareCategory.SelectedValue))
            {
                PopulateShareTiers(Convert.ToInt32(ddlShareCategory.SelectedValue));
                PopulateShareGuestAdmins();
            }
        }

        protected void ddlShareGuestAdmin_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtShareGuestPCNO.Text = "";
            txtShareGuestName.Text = "";
            PopulateShareCategories();
        }

        protected void txtShareGuestPCNO_TextChanged(object sender, EventArgs e)
        {
            PopulateShareCategories();
        }

        private void PopulateShareGuestAdmins()
        {
            try
            {
                string prevSelectedGuest = ddlShareGuestAdmin.SelectedValue;

                ddlShareGuestAdmin.Items.Clear();
                string pcno = Session["PCNO"]?.ToString() ?? "";
                int role = Convert.ToInt32(Session["Role"] ?? 0);

                string categoryOwnerPCNO = "";
                string selectedCatVal = ddlShareCategory.SelectedValue;
                if (!string.IsNullOrEmpty(selectedCatVal))
                {
                    int catId = Convert.ToInt32(selectedCatVal);
                    string qOwner = "SELECT AdminPCNO FROM MainCategory WHERE Id = :Id";
                    object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qOwner, new OracleParameter("Id", catId));
                    categoryOwnerPCNO = res != null ? res.ToString() : "";
                }

                string query;
                List<OracleParameter> pars = new List<OracleParameter>();
                if (role == 4)
                {
                    query = "SELECT PCNO, Name || ' (' || PCNO || ')' AS DisplayName FROM AppUsers WHERE Role = 1";
                    if (!string.IsNullOrEmpty(categoryOwnerPCNO))
                    {
                        query += " AND PCNO != :OwnerPCNO";
                        pars.Add(new OracleParameter("OwnerPCNO", categoryOwnerPCNO));
                    }
                    query += " ORDER BY Name ASC";
                }
                else
                {
                    query = "SELECT PCNO, Name || ' (' || PCNO || ')' AS DisplayName FROM AppUsers WHERE Role = 1 AND PCNO != :PCNO";
                    pars.Add(new OracleParameter("PCNO", pcno));
                    if (!string.IsNullOrEmpty(categoryOwnerPCNO))
                    {
                        query += " AND PCNO != :OwnerPCNO";
                        pars.Add(new OracleParameter("OwnerPCNO", categoryOwnerPCNO));
                    }
                    query += " ORDER BY Name ASC";
                }

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pars.ToArray());
                
                foreach (DataRow row in dt.Rows)
                {
                    ddlShareGuestAdmin.Items.Add(new System.Web.UI.WebControls.ListItem(row["DisplayName"].ToString(), row["PCNO"].ToString()));
                }

                if (ddlShareGuestAdmin.Items.Count > 0)
                {
                    if (!string.IsNullOrEmpty(prevSelectedGuest) && ddlShareGuestAdmin.Items.FindByValue(prevSelectedGuest) != null)
                    {
                        ddlShareGuestAdmin.SelectedValue = prevSelectedGuest;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating guest admins: " + ex.Message);
            }
        }

        #endregion

        #region Grid Binding

        private void BindAdminGrid()
        {
            try
            {
                lblGridMessage.Visible = false;
                string activeTab = string.IsNullOrEmpty(hfActiveTab.Value) ? "NonAdmins" : hfActiveTab.Value;
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                // Form toggles
                phUserForm.Visible = (activeTab == "NonAdmins" && (role == 1 || role == 4));
                phAdminForm.Visible = ((activeTab == "Admins" || activeTab == "SuperAdmins") && role == 4 && string.IsNullOrEmpty(txtEditAdminPCNO.Text));
                phEditAdminCategoriesForm.Visible = (activeTab == "Admins" && role == 4 && !string.IsNullOrEmpty(txtEditAdminPCNO.Text));
                phShareForm.Visible = (activeTab == "ShareGrants" && (role == 1 || role == 4));

                if (phShareForm.Visible)
                {
                    PopulateShareCategories();
                    PopulateShareGuestAdmins();
                }

                // Grid toggles
                gvAdminUsers.Visible = (activeTab != "ShareGrants");
                gvShareGrants.Visible = (activeTab == "ShareGrants");

                // Toggle tabs CSS
                btnTabNonAdmins.CssClass = (activeTab == "NonAdmins") ? "nav-link active" : "nav-link";
                btnTabAdmins.CssClass = (activeTab == "Admins") ? "nav-link active" : "nav-link";
                btnTabSuperAdmins.CssClass = (activeTab == "SuperAdmins") ? "nav-link active" : "nav-link";
                btnTabShareGrants.CssClass = (activeTab == "ShareGrants") ? "nav-link active" : "nav-link";

                if (activeTab == "ShareGrants")
                {
                    string query = @"
                        SELECT MIN(sg.Id) AS Id, 
                               sg.OwnerAdminPCNO, 
                               sg.SharedWithPCNO, 
                               sg.MainCategoryId,
                               MAX(sg.IsActive) AS IsActive,
                               u1.Name || ' (' || u1.PCNO || ')' AS OwnerName, 
                               u2.Name || ' (' || u2.PCNO || ')' AS SharedWithName,
                               mc.Name AS CategoryName,
                               CASE 
                                 WHEN COUNT(CASE WHEN sg.TierId IS NULL THEN 1 END) > 0 THEN 'Entire Category'
                                 ELSE LISTAGG(t.TierName, ', ') WITHIN GROUP (ORDER BY t.SortOrder, t.TierName)
                               END AS TierName
                        FROM CategoryShareGrant sg
                        JOIN AppUsers u1 ON sg.OwnerAdminPCNO = u1.PCNO
                        JOIN AppUsers u2 ON sg.SharedWithPCNO = u2.PCNO
                        JOIN MainCategory mc ON sg.MainCategoryId = mc.Id
                        LEFT JOIN Tiers t ON sg.TierId = t.Id
                        WHERE :Role = 4
                           OR sg.OwnerAdminPCNO = :PCNO
                           OR sg.SharedWithPCNO = :PCNO
                        GROUP BY sg.OwnerAdminPCNO, sg.SharedWithPCNO, sg.MainCategoryId, u1.Name, u1.PCNO, u2.Name, u2.PCNO, mc.Name
                        ORDER BY mc.Name ASC, MIN(sg.Id) DESC";

                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query,
                        new OracleParameter("Role", role),
                        new OracleParameter("PCNO", pcno));

                    gvShareGrants.DataSource = dt;
                    gvShareGrants.DataBind();
                }
                else
                {
                    string query = "";
                    OracleParameter[] pars = null;

                    if (activeTab == "NonAdmins")
                    {
                        query = @"
                            SELECT u.PCNO, u.Name, u.Role, 
                                   (SELECT LISTAGG(ud.DivisionName, ', ') WITHIN GROUP (ORDER BY ud.DivisionName ASC) FROM UserDivisions ud WHERE ud.PCNO = u.PCNO) AS AllowedDivisions,
                                   (SELECT LISTAGG(mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', ''), ', ') WITHIN GROUP (ORDER BY mc.Name ASC, t.SortOrder ASC) FROM UserTiers ut JOIN Tiers t ON ut.TierId = t.Id JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE ut.PCNO = u.PCNO) AS AllowedTiers
                            FROM AppUsers u
                            WHERE (u.Role = 0 OR u.Role = 3 OR u.PCNO IN (SELECT PCNO FROM UserDivisions) OR u.PCNO IN (SELECT PCNO FROM UserTiers))
                              AND (u.Role != 4 AND u.Role != 5)
                              AND (
                                  :Role = 4
                                  OR u.PCNO IN (
                                      SELECT ut.PCNO FROM UserTiers ut 
                                      WHERE ut.TierId IN (
                                          SELECT t2.Id FROM Tiers t2 
                                          JOIN MainCategory mc2 ON t2.MainCategoryId = mc2.Id 
                                          WHERE mc2.AdminPCNO = :PCNO 
                                             OR mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                                      )
                                  )
                                  OR NOT EXISTS (SELECT 1 FROM UserTiers ut2 WHERE ut2.PCNO = u.PCNO)
                              )
                            ORDER BY u.Name ASC";
                        pars = new OracleParameter[] {
                            new OracleParameter("Role", role),
                            new OracleParameter("PCNO", pcno)
                        };
                    }
                    else if (activeTab == "Admins")
                    {
                        query = @"SELECT u.PCNO, u.Name, u.Role, NULL AS AllowedDivisions, NULL AS AllowedTiers, 
                                         (SELECT LISTAGG(mc.Name, ', ') WITHIN GROUP (ORDER BY mc.Name ASC) FROM MainCategory mc WHERE mc.AdminPCNO = u.PCNO) AS OwnedCategories 
                                  FROM AppUsers u 
                                  WHERE u.Role = 1 OR u.Role = 2 
                                     OR u.PCNO IN (SELECT AdminPCNO FROM MainCategory WHERE AdminPCNO IS NOT NULL)
                                     OR u.PCNO IN (SELECT SharedWithPCNO FROM CategoryShareGrant WHERE IsActive = 1)
                                  ORDER BY u.Name ASC";
                        pars = new OracleParameter[0];
                    }
                    else if (activeTab == "SuperAdmins")
                    {
                        query = "SELECT PCNO, Name, Role, NULL AS AllowedDivisions, NULL AS AllowedTiers FROM AppUsers WHERE Role = 4 OR Role = 5 ORDER BY Name ASC";
                        pars = new OracleParameter[0];
                    }

                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pars);
                    gvAdminUsers.DataSource = dt;
                    gvAdminUsers.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowGridMessage("Error loading grid data: " + ex.Message, false);
            }
        }

        public bool IsShareOwner(object ownerPcno)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role == 4) return true; // Super Admin can manage all share grants!
            string pcno = Session["PCNO"]?.ToString() ?? "";
            return ownerPcno != null && ownerPcno.ToString() == pcno;
        }

        #endregion

        #region Actions & Submissions

        protected void btnAddAdmin_Click(object sender, EventArgs e)
        {
            string pcno = txtAdminPCNO.Text.Trim();
            string name = txtAdminName.Text.Trim();
            string activeTab = hfActiveTab.Value;

            if (string.IsNullOrEmpty(pcno) || string.IsNullOrEmpty(name))
            {
                ShowAdminMessage("PCNO and Name are required.", false);
                return;
            }

            int targetRole = (activeTab == "SuperAdmins") ? 4 : 1;

            try
            {
                string queryUser = @"
                    MERGE INTO AppUsers t
                    USING (SELECT :PCNO as PCNO, :Name as Name, :Role as Role FROM DUAL) s
                    ON (t.PCNO = s.PCNO)
                    WHEN MATCHED THEN
                      UPDATE SET t.Name = s.Name, t.Role = s.Role
                    WHEN NOT MATCHED THEN
                      INSERT (PCNO, Name, Role) VALUES (s.PCNO, s.Name, s.Role)";
                
                OracleParameter[] paramsUser = new OracleParameter[] {
                    new OracleParameter("PCNO", pcno),
                    new OracleParameter("Name", name),
                    new OracleParameter("Role", targetRole)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), queryUser, paramsUser);

                string typeLabel = (targetRole == 4) ? "Super Admin" : "Admin";
                ShowAdminMessage($"{typeLabel} user '{name}' (PCNO: {pcno}) has been successfully created/updated.", true);
                
                txtAdminPCNO.Text = "";
                txtAdminName.Text = "";

                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnAddUser_Click(object sender, EventArgs e)
        {
            string pcno = txtUserPCNO.Text.Trim();
            string name = txtUserName.Text.Trim();
            
            if (string.IsNullOrEmpty(pcno) || string.IsNullOrEmpty(name))
            {
                ShowAdminMessage("PCNO and Name are required.", false);
                return;
            }
            
            List<string> selectedDivs = new List<string>();
            foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items)
            {
                if (item.Selected) selectedDivs.Add(item.Value);
            }
            
            List<int> selectedTiers = new List<int>();
            foreach (System.Web.UI.WebControls.ListItem item in cblUserTiers.Items)
            {
                if (item.Selected) selectedTiers.Add(Convert.ToInt32(item.Value));
            }

            if (selectedDivs.Count == 0)
            {
                ShowAdminMessage("Please select at least one division for the user.", false);
                return;
            }

            if (selectedTiers.Count == 0)
            {
                ShowAdminMessage("Please select at least one tier for the user.", false);
                return;
            }
            
            try
            {
                // 1. Save AppUsers
                string queryUser = @"
                    MERGE INTO AppUsers t
                    USING (SELECT :PCNO as PCNO, :Name as Name, 0 as Role FROM DUAL) s
                    ON (t.PCNO = s.PCNO)
                    WHEN MATCHED THEN
                      UPDATE SET t.Name = s.Name, t.Role = s.Role
                    WHEN NOT MATCHED THEN
                      INSERT (PCNO, Name, Role) VALUES (s.PCNO, s.Name, s.Role)";
                
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), queryUser, 
                    new OracleParameter("PCNO", pcno),
                    new OracleParameter("Name", name));

                // 2. Save UserDivisions
                string deleteDivs = "DELETE FROM UserDivisions WHERE PCNO = :PCNO";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteDivs, new OracleParameter("PCNO", pcno));

                string insertDiv = "INSERT INTO UserDivisions (PCNO, DivisionName) VALUES (:PCNO, :Div)";
                foreach (string div in selectedDivs)
                {
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertDiv, 
                        new OracleParameter("PCNO", pcno),
                        new OracleParameter("Div", div));
                }

                // 3. Save UserTiers
                string deleteTiers = "DELETE FROM UserTiers WHERE PCNO = :PCNO";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteTiers, new OracleParameter("PCNO", pcno));

                string insertTier = "INSERT INTO UserTiers (PCNO, TierId) VALUES (:PCNO, :TierId)";
                foreach (int tierId in selectedTiers)
                {
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertTier,
                        new OracleParameter("PCNO", pcno),
                        new OracleParameter("TierId", tierId));
                }

                ShowAdminMessage($"Regular user '{name}' (PCNO: {pcno}) has been successfully saved.", true);
                
                // Clear fields
                txtUserPCNO.Text = "";
                txtUserName.Text = "";
                txtUserPCNO.ReadOnly = false;
                btnAddUser.Text = "Save Regular User";
                btnCancelUserEdit.Visible = false;
                
                foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items) item.Selected = false;
                foreach (System.Web.UI.WebControls.ListItem item in cblUserTiers.Items) item.Selected = false;

                userFormTitle.InnerHtml = "<i class=\"fas fa-user mr-2\"></i> Add Regular User";
                userFormHeader.Style["background"] = "linear-gradient(135deg, #0f172a 0%, #1e293b 100%)";

                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error saving regular user: " + ex.Message, false);
            }
        }

        protected void btnCancelUserEdit_Click(object sender, EventArgs e)
        {
            txtUserPCNO.Text = "";
            txtUserPCNO.ReadOnly = false;
            txtUserName.Text = "";
            foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items) item.Selected = false;
            foreach (System.Web.UI.WebControls.ListItem item in cblUserTiers.Items) item.Selected = false;
            
            btnAddUser.Text = "Save Regular User";
            btnCancelUserEdit.Visible = false;

            userFormTitle.InnerHtml = "<i class=\"fas fa-user mr-2\"></i> Add Regular User";
            userFormHeader.Style["background"] = "linear-gradient(135deg, #0f172a 0%, #1e293b 100%)";
        }

        protected void btnCreateShare_Click(object sender, EventArgs e)
        {
            string guestPcno = ddlShareGuestAdmin.SelectedValue;
            string categoryVal = ddlShareCategory.SelectedValue;
            bool isFull = (hfShareFullCategory.Value == "true");

            string inputPcno = txtShareGuestPCNO.Text.Trim();
            string inputName = txtShareGuestName.Text.Trim();

            if (!string.IsNullOrEmpty(inputPcno))
            {
                if (string.IsNullOrEmpty(inputName))
                {
                    ShowAdminMessage("Please enter the name of the new guest admin.", false);
                    return;
                }
                guestPcno = inputPcno;

                try
                {
                    // Create or update the new admin user with Role = 1
                    string queryUser = @"
                        MERGE INTO AppUsers t
                        USING (SELECT :PCNO as PCNO, :Name as Name, :Role as Role FROM DUAL) s
                        ON (t.PCNO = s.PCNO)
                        WHEN MATCHED THEN
                          UPDATE SET t.Name = s.Name, t.Role = s.Role
                        WHEN NOT MATCHED THEN
                          INSERT (PCNO, Name, Role) VALUES (s.PCNO, s.Name, s.Role)";

                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), queryUser,
                        new OracleParameter("PCNO", inputPcno),
                        new OracleParameter("Name", inputName),
                        new OracleParameter("Role", 1));

                    // Refresh dropdown lists
                    PopulateShareGuestAdmins();
                }
                catch (Exception ex)
                {
                    ShowAdminMessage("Error creating guest admin user: " + ex.Message, false);
                    return;
                }
            }

            if (string.IsNullOrEmpty(guestPcno) || string.IsNullOrEmpty(categoryVal))
            {
                ShowAdminMessage("Please select a category and guest Admin (or enter new admin details).", false);
                return;
            }

            int categoryId = Convert.ToInt32(categoryVal);
            string ownerPcno = "";
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role == 4)
            {
                string qOwner = "SELECT AdminPCNO FROM MainCategory WHERE Id = :Id";
                object resOwner = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qOwner, new OracleParameter("Id", categoryId));
                ownerPcno = resOwner != null ? resOwner.ToString() : "";
            }
            else
            {
                ownerPcno = Session["PCNO"]?.ToString() ?? "";
            }

            if (!string.IsNullOrEmpty(guestPcno) && guestPcno == ownerPcno)
            {
                ShowAdminMessage("This administrator is already the owner of the selected category and does not need sharing access.", false);
                return;
            }

            try
            {
                if (!string.IsNullOrEmpty(hfEditShareId.Value))
                {
                    int editId = Convert.ToInt32(hfEditShareId.Value);
                    string getExistingQuery = "SELECT OwnerAdminPCNO, SharedWithPCNO, MainCategoryId FROM CategoryShareGrant WHERE Id = :Id";
                    DataTable dtExisting = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), getExistingQuery, new OracleParameter("Id", editId));
                    if (dtExisting.Rows.Count > 0)
                    {
                        string oPcno = dtExisting.Rows[0]["OwnerAdminPCNO"].ToString();
                        string sPcno = dtExisting.Rows[0]["SharedWithPCNO"].ToString();
                        string mcId = dtExisting.Rows[0]["MainCategoryId"].ToString();
                        
                        // Delete all category share grants between this owner, guest, and main category so that the new scope overrides it completely
                        string cleanupSql = "DELETE FROM CategoryShareGrant WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId";
                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), cleanupSql,
                            new OracleParameter("Owner", oPcno),
                            new OracleParameter("Guest", sPcno),
                            new OracleParameter("MCId", Convert.ToInt32(mcId)));
                    }
                }

                if (isFull)
                {
                    // Check if already shared
                    string checkSql = "SELECT COUNT(*) FROM CategoryShareGrant WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId AND TierId IS NULL";
                    int exists = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkSql,
                        new OracleParameter("Owner", ownerPcno),
                        new OracleParameter("Guest", guestPcno),
                        new OracleParameter("MCId", categoryId)));

                    if (exists > 0)
                    {
                        // Enable it
                        string updateSql = "UPDATE CategoryShareGrant SET IsActive = 1 WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId AND TierId IS NULL";
                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                            new OracleParameter("Owner", ownerPcno),
                            new OracleParameter("Guest", guestPcno),
                            new OracleParameter("MCId", categoryId));
                    }
                    else
                    {
                        string insertSql = "INSERT INTO CategoryShareGrant (OwnerAdminPCNO, SharedWithPCNO, MainCategoryId, TierId, IsActive) VALUES (:Owner, :Guest, :MCId, NULL, 1)";
                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertSql,
                            new OracleParameter("Owner", ownerPcno),
                            new OracleParameter("Guest", guestPcno),
                            new OracleParameter("MCId", categoryId));
                    }
                }
                else
                {
                    // Parse tier IDs from hidden field
                    string[] tierIdsStr = hfSelectedTierIds.Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string tidStr in tierIdsStr)
                    {
                        int tierId = Convert.ToInt32(tidStr);

                        string checkSql = "SELECT COUNT(*) FROM CategoryShareGrant WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId AND TierId = :TierId";
                        int exists = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkSql,
                            new OracleParameter("Owner", ownerPcno),
                            new OracleParameter("Guest", guestPcno),
                            new OracleParameter("MCId", categoryId),
                            new OracleParameter("TierId", tierId)));

                        if (exists > 0)
                        {
                            string updateSql = "UPDATE CategoryShareGrant SET IsActive = 1 WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId AND TierId = :TierId";
                            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                                new OracleParameter("Owner", ownerPcno),
                                new OracleParameter("Guest", guestPcno),
                                new OracleParameter("MCId", categoryId),
                                new OracleParameter("TierId", tierId));
                        }
                        else
                        {
                            string insertSql = "INSERT INTO CategoryShareGrant (OwnerAdminPCNO, SharedWithPCNO, MainCategoryId, TierId, IsActive) VALUES (:Owner, :Guest, :MCId, :TierId, 1)";
                            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertSql,
                                new OracleParameter("Owner", ownerPcno),
                                new OracleParameter("Guest", guestPcno),
                                new OracleParameter("MCId", categoryId),
                                new OracleParameter("TierId", tierId));
                        }
                    }
                }

                ShowAdminMessage(!string.IsNullOrEmpty(hfEditShareId.Value) ? "Category access has been updated successfully." : "Category access has been shared successfully.", true);
                ResetShareForm();
                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error sharing/updating category: " + ex.Message, false);
            }
        }

        protected void gvAdminUsers_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RevokeAdmin")
            {
                string targetPcno = e.CommandArgument.ToString();
                string currentPcno = Session["PCNO"]?.ToString() ?? "";

                if (targetPcno == currentPcno)
                {
                    ShowGridMessage("You cannot revoke your own administrator access.", false);
                    return;
                }

                try
                {
                    string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = :PCNO AND ROWNUM <= 1";
                    object resRole = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new OracleParameter("PCNO", targetPcno));
                    int currentRole = resRole != null ? Convert.ToInt32(resRole) : 0;
                    
                    int targetRevokedRole = (currentRole == 1) ? 2 : (currentRole == 4 ? 5 : 3);

                    // Clear MainCategory ownership
                    string clearOwnershipSql = "UPDATE MainCategory SET AdminPCNO = NULL WHERE AdminPCNO = :PCNO";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), clearOwnershipSql, new OracleParameter("PCNO", targetPcno));

                    string query = "UPDATE AppUsers SET Role = :TargetRole WHERE PCNO = :PCNO";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query,
                        new OracleParameter("TargetRole", targetRevokedRole),
                        new OracleParameter("PCNO", targetPcno));

                    ShowGridMessage($"Access for PCNO {targetPcno} has been successfully revoked.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error revoking access: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "GrantAdmin")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = :PCNO AND ROWNUM <= 1";
                    object resRole = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new OracleParameter("PCNO", targetPcno));
                    int currentRole = resRole != null ? Convert.ToInt32(resRole) : 0;

                    int targetGrantedRole = (currentRole == 2) ? 1 : (currentRole == 5 ? 4 : 0);

                    string query = "UPDATE AppUsers SET Role = :TargetRole WHERE PCNO = :PCNO";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query,
                        new OracleParameter("TargetRole", targetGrantedRole),
                        new OracleParameter("PCNO", targetPcno));

                    ShowGridMessage($"Access for PCNO {targetPcno} has been successfully restored.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error restoring access: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "DeleteUser")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    // Cascade delete local mapping tables
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "DELETE FROM UserDivisions WHERE PCNO = :PCNO", new OracleParameter("PCNO", targetPcno));
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "DELETE FROM UserTiers WHERE PCNO = :PCNO", new OracleParameter("PCNO", targetPcno));
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "DELETE FROM CategoryShareGrant WHERE SharedWithPCNO = :PCNO OR OwnerAdminPCNO = :PCNO", new OracleParameter("PCNO", targetPcno));

                    string query = "DELETE FROM AppUsers WHERE PCNO = :PCNO";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", targetPcno));

                    ShowGridMessage($"User with PCNO {targetPcno} has been permanently deleted from the registry.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error deleting user: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "EditUserDivs")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    string queryUser = "SELECT PCNO, Name FROM AppUsers WHERE PCNO = :PCNO";
                    DataTable dtUser = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryUser, new OracleParameter("PCNO", targetPcno));
                    if (dtUser.Rows.Count > 0)
                    {
                        txtUserPCNO.Text = dtUser.Rows[0]["PCNO"].ToString();
                        txtUserPCNO.ReadOnly = true;
                        txtUserName.Text = dtUser.Rows[0]["Name"].ToString();
                        
                        foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items) item.Selected = false;
                        foreach (System.Web.UI.WebControls.ListItem item in cblUserTiers.Items) item.Selected = false;
                        
                        // Set divisions
                        string queryDivs = "SELECT DivisionName FROM UserDivisions WHERE PCNO = :PCNO";
                        DataTable dtDivs = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryDivs, new OracleParameter("PCNO", targetPcno));
                        foreach (DataRow row in dtDivs.Rows)
                        {
                            string divName = row["DivisionName"].ToString();
                            System.Web.UI.WebControls.ListItem item = cblUserDivisions.Items.FindByValue(divName);
                            if (item != null) item.Selected = true;
                        }

                        // Set tiers
                        string queryTiers = "SELECT TierId FROM UserTiers WHERE PCNO = :PCNO";
                        DataTable dtTiers = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryTiers, new OracleParameter("PCNO", targetPcno));
                        foreach (DataRow row in dtTiers.Rows)
                        {
                            string tId = row["TierId"].ToString();
                            System.Web.UI.WebControls.ListItem item = cblUserTiers.Items.FindByValue(tId);
                            if (item != null) item.Selected = true;
                        }
                        
                        btnAddUser.Text = "Update Regular User";
                        btnCancelUserEdit.Visible = true;
                        
                        userFormTitle.InnerHtml = "<i class=\"fas fa-user-edit mr-2\"></i> Edit Regular User";
                        userFormHeader.Style["background"] = "linear-gradient(135deg, #4f46e5 0%, #3730a3 100%)";

                        ShowAdminMessage($"Editing details for user '{txtUserName.Text}'.", true);
                    }
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error loading user details: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "EditAdminCategory")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    string queryUser = "SELECT PCNO, Name FROM AppUsers WHERE PCNO = :PCNO";
                    DataTable dtUser = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryUser, new OracleParameter("PCNO", targetPcno));
                    if (dtUser.Rows.Count > 0)
                    {
                        txtEditAdminPCNO.Text = dtUser.Rows[0]["PCNO"].ToString();
                        txtEditAdminName.Text = dtUser.Rows[0]["Name"].ToString();

                        ddlEditAdminCategory.Items.Clear();
                        ddlEditAdminCategory.Items.Add(new System.Web.UI.WebControls.ListItem("None (No Category)", ""));

                        string queryCats = @"
                            SELECT Id, Name 
                            FROM MainCategory 
                            WHERE AdminPCNO IS NULL 
                               OR AdminPCNO = :PCNO 
                            ORDER BY Name ASC";
                        DataTable dtCats = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryCats, new OracleParameter("PCNO", targetPcno));
                        foreach (DataRow row in dtCats.Rows)
                        {
                            ddlEditAdminCategory.Items.Add(new System.Web.UI.WebControls.ListItem(row["Name"].ToString(), row["Id"].ToString()));
                        }

                        // Set the selected value to the currently owned category (if any)
                        string queryOwned = "SELECT Id FROM MainCategory WHERE AdminPCNO = :PCNO AND ROWNUM <= 1";
                        object ownedIdVal = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryOwned, new OracleParameter("PCNO", targetPcno));
                        if (ownedIdVal != null && ownedIdVal != DBNull.Value)
                        {
                            string mcId = ownedIdVal.ToString();
                            System.Web.UI.WebControls.ListItem item = ddlEditAdminCategory.Items.FindByValue(mcId);
                            if (item != null)
                            {
                                ddlEditAdminCategory.SelectedValue = mcId;
                            }
                        }
                        else
                        {
                            ddlEditAdminCategory.SelectedValue = "";
                        }

                        BindAdminGrid();
                        ShowAdminMessage($"Loaded main category access details for admin '{txtEditAdminName.Text}'.", true);
                    }
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error loading admin category details: " + ex.Message, false);
                }
            }
        }

        private void CleanUpOrphanedAdmin(string guestPcno)
        {
            try
            {
                // Check if they own any categories
                string checkOwn = "SELECT COUNT(*) FROM MainCategory WHERE AdminPCNO = :PCNO";
                int ownCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkOwn, new OracleParameter("PCNO", guestPcno)));

                // Check if they have other share grants
                string checkGrants = "SELECT COUNT(*) FROM CategoryShareGrant WHERE SharedWithPCNO = :PCNO";
                int grantsCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkGrants, new OracleParameter("PCNO", guestPcno)));

                if (ownCount == 0 && grantsCount == 0)
                {
                    // Clean up UserTiers/UserDivisions if any
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "DELETE FROM UserDivisions WHERE PCNO = :PCNO", new OracleParameter("PCNO", guestPcno));
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "DELETE FROM UserTiers WHERE PCNO = :PCNO", new OracleParameter("PCNO", guestPcno));
                    
                    // Delete from AppUsers
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "DELETE FROM AppUsers WHERE PCNO = :PCNO", new OracleParameter("PCNO", guestPcno));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error cleaning up orphaned admin: " + ex.Message);
            }
        }

        protected void btnCancelShareEdit_Click(object sender, EventArgs e)
        {
            ResetShareForm();
        }

        private void ResetShareForm()
        {
            hfEditShareId.Value = "";
            txtShareGuestPCNO.Text = "";
            txtShareGuestPCNO.ReadOnly = false;
            txtShareGuestName.Text = "";

            PopulateShareCategories();

            hfShareFullCategory.Value = "true";
            hfSelectedTierIds.Value = "";
            btnCreateShare.Text = "Grant Category Access";
            btnCancelShareEdit.Visible = false;
        }

        protected void gvShareGrants_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            string arg = e.CommandArgument != null ? e.CommandArgument.ToString() : "";
            string[] parts = arg.Split('|');
            string ownerPcno = parts.Length > 0 ? parts[0] : "";
            string guestPcno = parts.Length > 1 ? parts[1] : "";
            string mcIdStr = parts.Length > 2 ? parts[2] : "";
            int parsedId = 0;
            int id = parts.Length > 3 ? Convert.ToInt32(parts[3]) : (int.TryParse(arg, out parsedId) ? parsedId : 0);

            if (e.CommandName == "ToggleShare")
            {
                try
                {
                    int categoryId = Convert.ToInt32(mcIdStr);
                    string checkStatusSql = "SELECT MAX(IsActive) FROM CategoryShareGrant WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId";
                    object resStatus = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkStatusSql,
                        new OracleParameter("Owner", ownerPcno),
                        new OracleParameter("Guest", guestPcno),
                        new OracleParameter("MCId", categoryId));
                    int currentStatus = (resStatus != null && resStatus != DBNull.Value) ? Convert.ToInt32(resStatus) : 0;
                    int newStatus = (currentStatus == 1) ? 0 : 1;

                    string updateSql = "UPDATE CategoryShareGrant SET IsActive = :NewStatus WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                        new OracleParameter("NewStatus", newStatus),
                        new OracleParameter("Owner", ownerPcno),
                        new OracleParameter("Guest", guestPcno),
                        new OracleParameter("MCId", categoryId));

                    ShowGridMessage("Category sharing grant status updated.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error toggling share grant: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "DeleteShare")
            {
                try
                {
                    int categoryId = Convert.ToInt32(mcIdStr);

                    string deleteSql = "DELETE FROM CategoryShareGrant WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteSql,
                        new OracleParameter("Owner", ownerPcno),
                        new OracleParameter("Guest", guestPcno),
                        new OracleParameter("MCId", categoryId));

                    if (!string.IsNullOrEmpty(guestPcno))
                    {
                        CleanUpOrphanedAdmin(guestPcno);
                    }

                    ShowGridMessage("Category sharing grant deleted successfully.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error deleting share grant: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "EditShare")
            {
                try
                {
                    int categoryId = Convert.ToInt32(mcIdStr);

                    // Store representative Edit ID
                    hfEditShareId.Value = id.ToString();

                    // Find Name from AppUsers
                    string nameQuery = "SELECT Name FROM AppUsers WHERE PCNO = :PCNO";
                    object nameVal = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), nameQuery, new OracleParameter("PCNO", guestPcno));

                    txtShareGuestPCNO.Text = guestPcno;
                    txtShareGuestPCNO.ReadOnly = true;
                    txtShareGuestName.Text = nameVal != null ? nameVal.ToString() : "";

                    PopulateShareCategories();

                    System.Web.UI.WebControls.ListItem mcItem = ddlShareCategory.Items.FindByValue(mcIdStr);
                    if (mcItem != null)
                    {
                        ddlShareCategory.SelectedValue = mcIdStr;
                    }

                    // Populate tiers for this category
                    PopulateShareTiers(categoryId);

                    // Query all tier grants for this group
                    string grantsSql = "SELECT TierId FROM CategoryShareGrant WHERE OwnerAdminPCNO = :Owner AND SharedWithPCNO = :Guest AND MainCategoryId = :MCId";
                    DataTable dtGrants = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), grantsSql,
                        new OracleParameter("Owner", ownerPcno),
                        new OracleParameter("Guest", guestPcno),
                        new OracleParameter("MCId", categoryId));

                    bool isFullCategory = false;
                    List<string> selectedTiers = new List<string>();

                    foreach (DataRow row in dtGrants.Rows)
                    {
                        if (row["TierId"] == DBNull.Value)
                        {
                            isFullCategory = true;
                            break;
                        }
                        else
                        {
                            selectedTiers.Add(row["TierId"].ToString());
                        }
                    }

                    if (isFullCategory)
                    {
                        hfShareFullCategory.Value = "true";
                        hfSelectedTierIds.Value = "";
                        foreach (System.Web.UI.WebControls.ListItem item in cblShareTiers.Items)
                        {
                            item.Selected = false;
                        }
                    }
                    else
                    {
                        hfShareFullCategory.Value = "false";
                        hfSelectedTierIds.Value = string.Join(",", selectedTiers);
                        foreach (System.Web.UI.WebControls.ListItem item in cblShareTiers.Items)
                        {
                            item.Selected = selectedTiers.Contains(item.Value);
                        }
                    }

                    btnCreateShare.Text = "Update Category Access";
                    btnCancelShareEdit.Visible = true;

                    ShowGridMessage($"Loaded access settings for guest Admin '{txtShareGuestName.Text}'. You can now adjust their scope and save changes.", true);
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error loading share grant details: " + ex.Message, false);
                }
            }
        }

        #endregion

        #region Helpers & Schema Verification

        private void EnsureNameColumnExists()
        {
            try
            {
                string checkQuery = @"
                    SELECT COUNT(*) 
                    FROM USER_TAB_COLUMNS 
                    WHERE TABLE_NAME = 'APPUSERS' 
                      AND COLUMN_NAME = 'NAME'";
                
                object count = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery);
                if (count != null && Convert.ToInt32(count) == 0)
                {
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), "ALTER TABLE AppUsers ADD Name VARCHAR2(100)");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error verifying AppUsers columns: " + ex.Message);
            }
        }

        private void EnsureUserDivisionsTableExists()
        {
            // Auto-create Divisions table if not present
            DBHelper.EnsureDivisionsTableExists();

            // Auto-create UserDivisions table if not present
            try
            {
                string createUserDivs = @"
                    CREATE TABLE UserDivisions (
                        PCNO         VARCHAR2(50)  NOT NULL,
                        DivisionName VARCHAR2(100) NOT NULL,
                        PRIMARY KEY (PCNO, DivisionName),
                        FOREIGN KEY (PCNO) REFERENCES AppUsers(PCNO) ON DELETE CASCADE
                    )";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), createUserDivs);
            }
            catch (Exception ex)
            {
                if (!ex.Message.Contains("ORA-00955"))
                {
                    System.Diagnostics.Debug.WriteLine("Error verifying UserDivisions: " + ex.Message);
                }
            }

            // Auto-create UserTiers table if not present
            try
            {
                string createTiersTable = @"
                    CREATE TABLE UserTiers (
                        PCNO VARCHAR2(50),
                        TierId NUMBER,
                        PRIMARY KEY (PCNO, TierId),
                        FOREIGN KEY (TierId) REFERENCES Tiers(Id) ON DELETE CASCADE
                    )";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), createTiersTable);
            }
            catch (Exception ex)
            {
                if (!ex.Message.Contains("ORA-00955"))
                {
                    System.Diagnostics.Debug.WriteLine("Error verifying UserTiers: " + ex.Message);
                }
            }
        }

        protected void btnCancelAdminEdit_Click(object sender, EventArgs e)
        {
            txtEditAdminPCNO.Text = "";
            txtEditAdminName.Text = "";
            ddlEditAdminCategory.Items.Clear();
            BindAdminGrid();
        }

        protected void btnSaveAdminCategories_Click(object sender, EventArgs e)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 4)
            {
                ShowAdminMessage("Only Super Admins can edit Main Category access for administrators.", false);
                return;
            }

            string adminPcno = txtEditAdminPCNO.Text.Trim();
            if (string.IsNullOrEmpty(adminPcno))
            {
                ShowAdminMessage("No administrator selected for editing.", false);
                return;
            }

            string selectedMcIdStr = ddlEditAdminCategory.SelectedValue;

            try
            {
                // 1. Unassign all categories currently owned by this admin
                string unassignSql = "UPDATE MainCategory SET AdminPCNO = NULL WHERE AdminPCNO = :PCNO";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), unassignSql, new OracleParameter("PCNO", adminPcno));

                // 2. Assign the admin to the newly selected category (if not None)
                if (!string.IsNullOrEmpty(selectedMcIdStr))
                {
                    int mcId = Convert.ToInt32(selectedMcIdStr);
                    string assignSql = "UPDATE MainCategory SET AdminPCNO = :PCNO WHERE Id = :MCId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), assignSql,
                        new OracleParameter("PCNO", adminPcno),
                        new OracleParameter("MCId", mcId));
                }

                ShowAdminMessage("Administrator Main Category access successfully updated.", true);
                
                // Clear and refresh
                txtEditAdminPCNO.Text = "";
                txtEditAdminName.Text = "";
                ddlEditAdminCategory.Items.Clear();
                
                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error saving administrator category: " + ex.Message, false);
            }
        }

        private void ShowAdminMessage(string msg, bool success)
        {
            string type = success ? "success" : "error";
            string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void ShowGridMessage(string msg, bool success)
        {
            string type = success ? "success" : "error";
            string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        #endregion
    }
}
