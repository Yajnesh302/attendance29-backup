using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Settings : System.Web.UI.Page
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

            if (!IsPostBack)
            {
                string reqTab = Request.QueryString["tab"];
                if (!string.IsNullOrEmpty(reqTab))
                {
                    hfActiveTab.Value = reqTab.ToLower();
                }

                BindDivisions();
                BindCategories();
                BindActionLogs();
                BindEditWindowSettings();
            }
        }

        private void ShowToast(string message, string type)
        {
            string cleanMessage = message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        #region Directorate Management

        private void BindDivisions()
        {
            try
            {
                DataTable dt = DBHelper.GetCompanyDivisionsDataTable();
                gvDivisions.DataSource = dt;
                gvDivisions.DataBind();
            }
            catch (Exception ex)
            {
                ShowToast("Error loading directorates: " + ex.Message, "error");
            }
        }

        #endregion

        #region Category & Tier Management

        private void BindCategories()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                if (role == 4) // Super Admin: View Global Directory
                {
                    phNoMainCategory.Visible = false;
                    phSuperAdminCategories.Visible = true;

                    string query = @"
                        SELECT mc.Id, 
                               mc.Name AS MainCategoryName, 
                               u.Name AS AdminName, 
                               (SELECT RTRIM(XMLCAST(XMLAGG(XMLELEMENT(e, t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') || ', ') ORDER BY t.SortOrder, t.TierName).Extract('//text()') AS CLOB), ', ') 
                                FROM Tiers t WHERE t.MainCategoryId = mc.Id) AS TiersList
                        FROM MainCategory mc
                        JOIN AppUsers u ON mc.AdminPCNO = u.PCNO
                        ORDER BY mc.Name ASC";
                    
                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                    gvGlobalCategories.DataSource = dt;
                    gvGlobalCategories.DataBind();

                    if (!string.IsNullOrEmpty(hfSuperAdminSelectedMCId.Value))
                    {
                        phMainCategoryOwned.Visible = true;
                        btnSuperAdminCloseEditor.Visible = true;

                        int mcId = Convert.ToInt32(hfSuperAdminSelectedMCId.Value);
                        string mcNameQuery = "SELECT Name FROM MainCategory WHERE Id = :Id";
                        object mcNameObj = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), mcNameQuery, new OracleParameter("Id", mcId));
                        string mcName = mcNameObj != null ? mcNameObj.ToString() : "";
                        
                        lblMainCategoryDisplay.Text = mcName;
                        txtRenameMC.Text = mcName;

                        string queryTiers = "SELECT Id, TierName, RoleLabel, SortOrder FROM Tiers WHERE MainCategoryId = :MCId ORDER BY SortOrder ASC, TierName ASC";
                        DataTable dtTiers = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryTiers, new OracleParameter("MCId", mcId));
                        gvTiers.DataSource = dtTiers;
                        gvTiers.DataBind();
                    }
                    else
                    {
                        phMainCategoryOwned.Visible = false;
                        btnSuperAdminCloseEditor.Visible = false;
                    }
                }
                else if (role == 1) // Admin
                {
                    phSuperAdminCategories.Visible = false;
                    btnSuperAdminCloseEditor.Visible = false;

                    string roleMode = Session["RoleMode"]?.ToString() ?? "";
                    string queryMC = "";
                    if (roleMode == "PrimaryAdmin")
                    {
                        queryMC = @"
                            SELECT mc.Id, mc.Name, mc.AdminPCNO, 'Owned' AS AccessType 
                            FROM MainCategory mc 
                            WHERE mc.AdminPCNO = :PCNO 
                            ORDER BY mc.Name ASC";
                    }
                    else if (roleMode == "SecondaryAdmin")
                    {
                        queryMC = @"
                            SELECT mc.Id, mc.Name, mc.AdminPCNO, 'Shared' AS AccessType 
                            FROM MainCategory mc 
                            WHERE mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                            ORDER BY mc.Name ASC";
                    }
                    else
                    {
                        queryMC = @"
                            SELECT mc.Id, mc.Name, mc.AdminPCNO, 
                                   CASE WHEN mc.AdminPCNO = :PCNO THEN 'Owned' ELSE 'Shared' END AS AccessType 
                            FROM MainCategory mc 
                            WHERE mc.AdminPCNO = :PCNO 
                               OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                            ORDER BY CASE WHEN mc.AdminPCNO = :PCNO THEN 0 ELSE 1 END, mc.Name ASC";
                    }

                    DataTable dtMC = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryMC, new OracleParameter("PCNO", pcno));

                    if (dtMC.Rows.Count > 0)
                    {
                        phNoMainCategory.Visible = false;
                        phMainCategoryOwned.Visible = true;

                        if (dtMC.Rows.Count > 1)
                        {
                            ddlAdminSelectCategory.Visible = true;
                            if (ddlAdminSelectCategory.Items.Count == 0)
                            {
                                ddlAdminSelectCategory.DataSource = dtMC;
                                ddlAdminSelectCategory.DataTextField = "Name";
                                ddlAdminSelectCategory.DataValueField = "Id";
                                ddlAdminSelectCategory.DataBind();
                            }
                        }
                        else
                        {
                            ddlAdminSelectCategory.Visible = false;
                        }

                        int activeMcId = GetActiveMainCategoryId();
                        DataRow activeRow = null;
                        foreach (DataRow r in dtMC.Rows)
                        {
                            if (Convert.ToInt32(r["Id"]) == activeMcId)
                            {
                                activeRow = r;
                                break;
                            }
                        }
                        if (activeRow == null)
                        {
                            activeRow = dtMC.Rows[0];
                            activeMcId = Convert.ToInt32(activeRow["Id"]);
                        }

                        string mcName = activeRow["Name"].ToString();
                        bool isOwner = activeRow["AccessType"].ToString() == "Owned";

                        if (isOwner)
                        {
                            lblMainCategoryDisplay.Text = mcName + " <span class='badge badge-primary ml-2 font-weight-normal' style='font-size: 0.75rem;'><i class='fas fa-user-shield mr-1'></i>Owned Category</span>";
                            btnRenameMCTrigger.Visible = true;
                            pnlAddTierForm.Visible = true;
                        }
                        else
                        {
                            lblMainCategoryDisplay.Text = mcName + " <span class='badge badge-info ml-2 font-weight-normal' style='font-size: 0.75rem;'><i class='fas fa-share-alt mr-1'></i>Shared Category (Structure Read-Only)</span>";
                            btnRenameMCTrigger.Visible = false;
                            pnlAddTierForm.Visible = false;
                        }

                        txtRenameMC.Text = mcName;

                        // Bind tiers list
                        string queryTiers = "SELECT Id, TierName, RoleLabel, SortOrder FROM Tiers WHERE MainCategoryId = :MCId ORDER BY SortOrder ASC, TierName ASC";
                        DataTable dtTiers = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryTiers, new OracleParameter("MCId", activeMcId));
                        gvTiers.DataSource = dtTiers;
                        gvTiers.DataBind();
                    }
                    else
                    {
                        phNoMainCategory.Visible = true;
                        phMainCategoryOwned.Visible = false;
                        ddlAdminSelectCategory.Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowToast("Error loading categories/tiers: " + ex.Message, "error");
            }
        }

        protected void btnCreateMainCategory_Click(object sender, EventArgs e)
        {
            string mcName = txtMainCategoryName.Text.Trim();
            if (string.IsNullOrEmpty(mcName))
            {
                ShowToast("Main Category name cannot be empty.", "warning");
                return;
            }

            try
            {
                string pcno = Session["PCNO"]?.ToString() ?? "";
                int role = Convert.ToInt32(Session["Role"] ?? 0);

                if (role == 1)
                {
                    string checkOwned = "SELECT COUNT(*) FROM MainCategory WHERE AdminPCNO = :PCNO";
                    int ownedCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkOwned, new OracleParameter("PCNO", pcno)));
                    if (ownedCount > 0)
                    {
                        ShowToast("You already own a Main Category. Administrators are limited to one Main Category.", "warning");
                        return;
                    }
                }

                // Check global name uniqueness
                string checkQuery = "SELECT COUNT(*) FROM MainCategory WHERE UPPER(Name) = UPPER(:Name)";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, new OracleParameter("Name", mcName)));
                if (count > 0)
                {
                    ShowToast("Main Category name '" + mcName + "' is already in use.", "warning");
                    return;
                }

                string insertQuery = "INSERT INTO MainCategory (Name, AdminPCNO) VALUES (:Name, :PCNO)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery, 
                    new OracleParameter("Name", mcName),
                    new OracleParameter("PCNO", pcno));

                txtMainCategoryName.Text = "";
                BindCategories();
                ShowToast("Main Category '" + mcName + "' created successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error creating Main Category: " + ex.Message, "error");
            }
        }

        protected void btnRenameMC_Click(object sender, EventArgs e)
        {
            string newName = txtRenameMC.Text.Trim();
            if (string.IsNullOrEmpty(newName))
            {
                ShowToast("Main Category name cannot be empty.", "warning");
                return;
            }

            try
            {
                string pcno = Session["PCNO"]?.ToString() ?? "";
                int role = Convert.ToInt32(Session["Role"] ?? 0);

                int mcId = GetActiveMainCategoryId();
                if (mcId == 0) return;

                if (!IsCurrentMainCategoryOwned(mcId))
                {
                    ShowToast("Shared Category Admins cannot rename a shared Main Category.", "warning");
                    return;
                }

                if (role == 4)
                {
                    // Check uniqueness excluding self
                    string checkQuery = "SELECT COUNT(*) FROM MainCategory WHERE UPPER(Name) = UPPER(:Name) AND Id != :Id";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, 
                        new OracleParameter("Name", newName),
                        new OracleParameter("Id", mcId)));
                    if (count > 0)
                    {
                        ShowToast("Category name '" + newName + "' is already in use by another Admin.", "warning");
                        return;
                    }

                    string updateQuery = "UPDATE MainCategory SET Name = :Name WHERE Id = :Id";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, 
                        new OracleParameter("Name", newName),
                        new OracleParameter("Id", mcId));
                }
                else
                {
                    // Check uniqueness excluding self
                    string checkQuery = "SELECT COUNT(*) FROM MainCategory WHERE UPPER(Name) = UPPER(:Name) AND Id != :Id";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, 
                        new OracleParameter("Name", newName),
                        new OracleParameter("Id", mcId)));
                    if (count > 0)
                    {
                        ShowToast("Category name '" + newName + "' is already in use by another Admin.", "warning");
                        return;
                    }

                    string updateQuery = "UPDATE MainCategory SET Name = :Name WHERE Id = :Id AND AdminPCNO = :PCNO";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, 
                        new OracleParameter("Name", newName),
                        new OracleParameter("Id", mcId),
                        new OracleParameter("PCNO", pcno));
                }

                BindCategories();
                ShowToast("Main Category renamed successfully to '" + newName + "'.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error renaming Main Category: " + ex.Message, "error");
            }
        }

        protected void btnAddTier_Click(object sender, EventArgs e)
        {
            string tierName = txtNewTierName.Text.Trim();
            string roleLabel = txtNewRoleLabel.Text.Trim();

            if (string.IsNullOrEmpty(tierName))
            {
                ShowToast("Tier name is required.", "warning");
                return;
            }

            try
            {
                int mcId = GetActiveMainCategoryId();
                if (mcId == 0)
                {
                    ShowToast("Error: No Main Category selected/found.", "error");
                    return;
                }

                if (!IsCurrentMainCategoryOwned(mcId))
                {
                    ShowToast("Shared Category Admins cannot add sub-categories (tiers) to a shared Main Category.", "warning");
                    return;
                }

                // Check tier uniqueness under this MainCategory
                string checkQuery = "SELECT COUNT(*) FROM Tiers WHERE MainCategoryId = :MCId AND UPPER(TierName) = UPPER(:TierName) AND (UPPER(RoleLabel) = UPPER(:RoleLabel) OR (RoleLabel IS NULL AND :RoleLabel IS NULL))";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery,
                    new OracleParameter("MCId", mcId),
                    new OracleParameter("TierName", tierName),
                    new OracleParameter("RoleLabel", string.IsNullOrEmpty(roleLabel) ? (object)DBNull.Value : roleLabel)));
                
                if (count > 0)
                {
                    ShowToast("This sub-category tier or role label already exists under this Main Category.", "warning");
                    return;
                }

                // Determine next sort order
                string getSort = "SELECT NVL(MAX(SortOrder), 0) + 1 FROM Tiers WHERE MainCategoryId = :MCId";
                int sortOrder = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getSort, new OracleParameter("MCId", mcId)));

                string insertQuery = "INSERT INTO Tiers (MainCategoryId, TierName, RoleLabel, SortOrder) VALUES (:MCId, :TierName, :RoleLabel, :SortOrder)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery,
                    new OracleParameter("MCId", mcId),
                    new OracleParameter("TierName", tierName),
                    new OracleParameter("RoleLabel", string.IsNullOrEmpty(roleLabel) ? (object)DBNull.Value : roleLabel),
                    new OracleParameter("SortOrder", sortOrder));

                txtNewTierName.Text = "";
                txtNewRoleLabel.Text = "";
                BindCategories();
                ShowToast("Sub-category tier '" + tierName + "' added successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error adding tier: " + ex.Message, "error");
            }
        }

        protected void gvTiers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            int mcId = GetActiveMainCategoryId();
            if (!IsCurrentMainCategoryOwned(mcId))
            {
                ShowToast("Shared Category Admins cannot edit sub-categories (tiers) under a shared Main Category.", "warning");
                return;
            }
            gvTiers.EditIndex = e.NewEditIndex;
            BindCategories();
        }

        protected void gvTiers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvTiers.EditIndex = -1;
            BindCategories();
        }

        protected void gvTiers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int mcId = GetActiveMainCategoryId();
            if (!IsCurrentMainCategoryOwned(mcId))
            {
                ShowToast("Shared Category Admins cannot update sub-categories (tiers) under a shared Main Category.", "warning");
                return;
            }

            int id = Convert.ToInt32(gvTiers.DataKeys[e.RowIndex].Value);
                TextBox txtName = (TextBox)gvTiers.Rows[e.RowIndex].FindControl("txtTierName");
                TextBox txtRole = (TextBox)gvTiers.Rows[e.RowIndex].FindControl("txtRoleLabel");
                TextBox txtSort = (TextBox)gvTiers.Rows[e.RowIndex].FindControl("txtSortOrder");

                string newName = txtName != null ? txtName.Text.Trim() : "";
                string newRole = txtRole != null ? txtRole.Text.Trim() : "";
                int parsedSort = 0;
                int newSortOrder = (txtSort != null && int.TryParse(txtSort.Text.Trim(), out parsedSort)) ? parsedSort : (e.RowIndex + 1);

                if (string.IsNullOrEmpty(newName))
                {
                    ShowToast("Tier name cannot be empty.", "warning");
                    return;
                }

                try
                {
                    if (mcId == 0)
                    {
                        ShowToast("Error: No Main Category selected/found.", "error");
                        return;
                    }

                    // Check uniqueness excluding self
                    string checkQuery = "SELECT COUNT(*) FROM Tiers WHERE MainCategoryId = :MCId AND UPPER(TierName) = UPPER(:TierName) AND (UPPER(RoleLabel) = UPPER(:RoleLabel) OR (RoleLabel IS NULL AND :RoleLabel IS NULL)) AND Id != :Id";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery,
                        new OracleParameter("MCId", mcId),
                        new OracleParameter("TierName", newName),
                        new OracleParameter("RoleLabel", string.IsNullOrEmpty(newRole) ? (object)DBNull.Value : newRole),
                        new OracleParameter("Id", id)));
                    
                    if (count > 0)
                    {
                        ShowToast("This sub-category tier name/role combination already exists.", "warning");
                        return;
                    }

                    string updateQuery = "UPDATE Tiers SET TierName = :TierName, RoleLabel = :RoleLabel, SortOrder = :SortOrder WHERE Id = :Id";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery,
                        new OracleParameter("TierName", newName),
                        new OracleParameter("RoleLabel", string.IsNullOrEmpty(newRole) ? (object)DBNull.Value : newRole),
                        new OracleParameter("SortOrder", newSortOrder),
                        new OracleParameter("Id", id));

                    gvTiers.EditIndex = -1;
                    BindCategories();
                    ShowToast("Sub-category tier updated successfully.", "success");
                }
                catch (Exception ex)
                {
                    ShowToast("Error updating tier: " + ex.Message, "error");
                }
            }

            protected void gvTiers_RowDeleting(object sender, GridViewDeleteEventArgs e)
            {
                int mcId = GetActiveMainCategoryId();
                if (!IsCurrentMainCategoryOwned(mcId))
                {
                    ShowToast("Shared Category Admins cannot delete sub-categories (tiers) under a shared Main Category.", "warning");
                    return;
                }

                int id = Convert.ToInt32(gvTiers.DataKeys[e.RowIndex].Value);

                try
                {
                    // Verify if tier is assigned to any active employee stint
                    string countEmpQuery = "SELECT COUNT(*) FROM Employees WHERE TierId = :TierId";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), countEmpQuery, new OracleParameter("TierId", id)));
                    if (count > 0)
                    {
                        ShowToast("Cannot delete: " + count + " employee(s) are associated with this tier.", "warning");
                        return;
                    }

                    // Verify if contracts exist for this tier
                    string countContractQuery = "SELECT COUNT(*) FROM ContractPeriods WHERE TierId = :TierId";
                    int countContracts = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), countContractQuery, new OracleParameter("TierId", id)));
                    if (countContracts > 0)
                    {
                        ShowToast("Cannot delete: contract periods exist for this tier.", "warning");
                        return;
                    }

                    // Delete from Tiers
                    string deleteQuery = "DELETE FROM Tiers WHERE Id = :Id";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteQuery, new OracleParameter("Id", id));

                    BindCategories();
                    ShowToast("Sub-category tier deleted successfully.", "success");
                }
                catch (Exception ex)
                {
                    ShowToast("Error deleting tier: " + ex.Message, "error");
                }
            }

            protected void gvTiers_RowCommand(object sender, GridViewCommandEventArgs e)
            {
                if (e.CommandName == "MoveUp" || e.CommandName == "MoveDown")
                {
                    int mcId = GetActiveMainCategoryId();
                    if (!IsCurrentMainCategoryOwned(mcId))
                    {
                        ShowToast("Shared Category Admins cannot reorder sub-categories under a shared Main Category.", "warning");
                        return;
                    }

                    int tierId = Convert.ToInt32(e.CommandArgument);
                    try
                    {
                        string q = "SELECT Id, SortOrder FROM Tiers WHERE MainCategoryId = :MCId ORDER BY SortOrder ASC, TierName ASC";
                        DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), q, new OracleParameter("MCId", mcId));

                        int index = -1;
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            if (Convert.ToInt32(dt.Rows[i]["Id"]) == tierId)
                            {
                                index = i;
                                break;
                            }
                        }

                        if (index == -1) return;

                        int targetIndex = (e.CommandName == "MoveUp") ? index - 1 : index + 1;
                        if (targetIndex < 0 || targetIndex >= dt.Rows.Count) return;

                        // Normalize sort orders to sequential integers 1, 2, 3...
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            int tId = Convert.ToInt32(dt.Rows[i]["Id"]);
                            int currentSort = (dt.Rows[i]["SortOrder"] != DBNull.Value) ? Convert.ToInt32(dt.Rows[i]["SortOrder"]) : 0;
                            if (currentSort != i + 1)
                            {
                                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(),
                                    "UPDATE Tiers SET SortOrder = :SortOrder WHERE Id = :Id",
                                    new OracleParameter("SortOrder", i + 1),
                                    new OracleParameter("Id", tId));
                            }
                        }

                        // Swap sort order values between index and targetIndex
                        int currId = Convert.ToInt32(dt.Rows[index]["Id"]);
                        int targetId = Convert.ToInt32(dt.Rows[targetIndex]["Id"]);
                        int currSortOrder = index + 1;
                        int targetSortOrder = targetIndex + 1;

                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(),
                            "UPDATE Tiers SET SortOrder = :SortOrder WHERE Id = :Id",
                            new OracleParameter("SortOrder", targetSortOrder),
                            new OracleParameter("Id", currId));

                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(),
                            "UPDATE Tiers SET SortOrder = :SortOrder WHERE Id = :Id",
                            new OracleParameter("SortOrder", currSortOrder),
                            new OracleParameter("Id", targetId));

                        BindCategories();
                        ShowToast("Tier position updated.", "success");
                    }
                    catch (Exception ex)
                    {
                        ShowToast("Error updating tier order: " + ex.Message, "error");
                    }
                }
            }

            protected void gvTiers_RowDataBound(object sender, GridViewRowEventArgs e)
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    int mcId = GetActiveMainCategoryId();
                    bool isOwned = IsCurrentMainCategoryOwned(mcId);
                    
                    LinkButton btnEdit = e.Row.FindControl("btnEditTier") as LinkButton;
                    LinkButton btnDelete = e.Row.FindControl("btnDeleteTier") as LinkButton;
                    LinkButton btnMoveUp = e.Row.FindControl("btnMoveUp") as LinkButton;
                    LinkButton btnMoveDown = e.Row.FindControl("btnMoveDown") as LinkButton;

                    if (!isOwned)
                    {
                        if (btnEdit != null) btnEdit.Visible = false;
                        if (btnDelete != null) btnDelete.Visible = false;
                        if (btnMoveUp != null) btnMoveUp.Visible = false;
                        if (btnMoveDown != null) btnMoveDown.Visible = false;
                    }
                    else
                    {
                        // Disable MoveUp for top row
                        if (e.Row.RowIndex == 0 && btnMoveUp != null)
                        {
                            btnMoveUp.Enabled = false;
                            btnMoveUp.CssClass = "btn btn-sm btn-outline-secondary py-0 px-2 disabled opacity-50";
                            btnMoveUp.Style.Add("cursor", "not-allowed");
                        }

                        // Disable MoveDown for bottom row
                        DataTable dt = gvTiers.DataSource as DataTable;
                        int totalRows = dt != null ? dt.Rows.Count : gvTiers.Rows.Count;
                        if (e.Row.RowIndex == totalRows - 1 && btnMoveDown != null)
                        {
                            btnMoveDown.Enabled = false;
                            btnMoveDown.CssClass = "btn btn-sm btn-outline-secondary py-0 px-2 disabled opacity-50";
                            btnMoveDown.Style.Add("cursor", "not-allowed");
                        }
                    }
                }
            }

        protected void ddlAdminSelectCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindCategories();
        }

        private bool IsCurrentMainCategoryOwned(int mcId)
        {
            if (mcId == 0) return false;
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role == 4) return true;

            string pcno = Session["PCNO"]?.ToString() ?? "";
            string q = "SELECT COUNT(*) FROM MainCategory WHERE Id = :Id AND AdminPCNO = :PCNO";
            int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q,
                new OracleParameter("Id", mcId),
                new OracleParameter("PCNO", pcno)));
            return count > 0;
        }

        private int GetActiveMainCategoryId()
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role == 4)
            {
                if (!string.IsNullOrEmpty(hfSuperAdminSelectedMCId.Value))
                {
                    return Convert.ToInt32(hfSuperAdminSelectedMCId.Value);
                }
                return 0;
            }
            else
            {
                if (ddlAdminSelectCategory != null && ddlAdminSelectCategory.Visible && !string.IsNullOrEmpty(ddlAdminSelectCategory.SelectedValue))
                {
                    return Convert.ToInt32(ddlAdminSelectCategory.SelectedValue);
                }

                string pcno = Session["PCNO"]?.ToString() ?? "";
                string getMCQuery = @"
                    SELECT Id FROM MainCategory 
                    WHERE AdminPCNO = :PCNO 
                       OR Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                    ORDER BY CASE WHEN AdminPCNO = :PCNO THEN 0 ELSE 1 END, Name ASC";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getMCQuery, 
                    new OracleParameter("PCNO", pcno));
                return res != null ? Convert.ToInt32(res) : 0;
            }
        }

        protected void gvGlobalCategories_Command(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ConfigureMC")
            {
                hfSuperAdminSelectedMCId.Value = e.CommandArgument.ToString();
                BindCategories();
            }
        }

        protected void btnSuperAdminCloseEditor_Click(object sender, EventArgs e)
        {
            hfSuperAdminSelectedMCId.Value = "";
            BindCategories();
        }

        #endregion

        #region Undo Manager

        private void BindActionLogs()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                string roleMode = Session["RoleMode"]?.ToString() ?? "";

                string query = "";
                List<OracleParameter> pList = new List<OracleParameter>();

                if (role == 4) // Super Admin sees all logs
                {
                    query = "SELECT * FROM (SELECT Id, ActionTime, ActionType, Description, IsUndone FROM EmployeeActionLogs ORDER BY ActionTime DESC, Id DESC) WHERE ROWNUM <= 10";
                }
                else // Category Admin sees logs only for employees in their accessible Main Category / Shared Tiers
                {
                    string mcFilterCond = "";
                    if (roleMode == "PrimaryAdmin")
                    {
                        mcFilterCond = "mc.AdminPCNO = :PCNO";
                    }
                    else if (roleMode == "SecondaryAdmin")
                    {
                        mcFilterCond = @"(
                            mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL)
                         OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL)
                        )";
                    }
                    else
                    {
                        mcFilterCond = @"(
                            mc.AdminPCNO = :PCNO
                         OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL)
                         OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL)
                        )";
                    }

                    query = $@"
                        SELECT * FROM (
                            SELECT DISTINCT al.Id, al.ActionTime, al.ActionType, al.Description, al.IsUndone 
                            FROM EmployeeActionLogs al
                            LEFT JOIN Employees e ON al.EmpMasterId = e.MasterId
                            LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                            LEFT JOIN Tiers t ON NVL(e.TierId, ee.TierId) = t.Id
                            LEFT JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                            WHERE {mcFilterCond}
                            ORDER BY al.ActionTime DESC, al.Id DESC
                        ) WHERE ROWNUM <= 10";
                    pList.Add(new OracleParameter("PCNO", pcno));
                }

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pList.ToArray());
                gvActionLogs.DataSource = dt;
                gvActionLogs.DataBind();
            }
            catch (Exception ex)
            {
                ShowToast("Error loading action logs: " + ex.Message, "error");
            }
        }

        protected void gvActionLogs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "UndoCommand")
            {
                int targetLogId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    int role = Convert.ToInt32(Session["Role"] ?? 0);
                    string pcno = Session["PCNO"]?.ToString() ?? "";
                    string roleMode = Session["RoleMode"]?.ToString() ?? "";

                    if (role != 4)
                    {
                        // Verify target log belongs to an employee under admin's accessible category/tier
                        string mcFilterCond = (roleMode == "PrimaryAdmin") ? "mc.AdminPCNO = :PCNO"
                            : (roleMode == "SecondaryAdmin") ? "(mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))"
                            : "(mc.AdminPCNO = :PCNO OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))";

                        string checkAuth = $@"
                            SELECT COUNT(*) 
                            FROM EmployeeActionLogs al
                            LEFT JOIN Employees e ON al.EmpMasterId = e.MasterId
                            LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                            LEFT JOIN Tiers t ON NVL(e.TierId, ee.TierId) = t.Id
                            LEFT JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                            WHERE al.Id = :TargetLogId AND {mcFilterCond}";

                        object cntObj = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkAuth,
                            new OracleParameter("TargetLogId", targetLogId),
                            new OracleParameter("PCNO", pcno));
                        if (cntObj == null || Convert.ToInt32(cntObj) == 0)
                        {
                            ShowToast("You do not have permission to undo changes for this category.", "error");
                            return;
                        }
                    }

                    // Find all active logs for this employee that are newer than or equal to the target log
                    string selectChain = @"
                        SELECT Id, Description FROM EmployeeActionLogs 
                        WHERE EmpMasterId = (SELECT EmpMasterId FROM EmployeeActionLogs WHERE Id = :TargetLogId)
                          AND Id >= :TargetLogId 
                          AND IsUndone = 0 
                        ORDER BY Id DESC";
                    
                    DataTable dtChain = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), selectChain, new OracleParameter("TargetLogId", targetLogId));
                    if (dtChain.Rows.Count == 0)
                    {
                        ShowToast("No active action log found to undo.", "warning");
                        return;
                    }

                    int successfulUndos = 0;
                    string lastError = "";

                    // Run the undo in reverse chronological order
                    foreach (DataRow row in dtChain.Rows)
                    {
                        int logId = Convert.ToInt32(row["Id"]);
                        string desc = row["Description"].ToString();
                        
                        string errMsg;
                        bool success = ActionLogger.UndoAction(logId, out errMsg);
                        if (!success)
                        {
                            lastError = errMsg;
                            break; // Stop immediately to preserve logical ordering and consistency
                        }
                        successfulUndos++;
                    }

                    BindActionLogs();

                    if (successfulUndos == dtChain.Rows.Count)
                    {
                        if (successfulUndos == 1)
                        {
                            ShowToast("Action successfully undone.", "success");
                        }
                        else
                        {
                            ShowToast(string.Format("Successfully rolled back {0} linked changes in sequence.", successfulUndos), "success");
                        }
                    }
                    else
                    {
                        if (successfulUndos > 0)
                        {
                            ShowToast(string.Format("Partially rolled back {0} change(s). Stopped due to error: {1}", successfulUndos, lastError), "error");
                        }
                        else
                        {
                            ShowToast("Undo failed: " + lastError, "error");
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowToast("Error during undo operation: " + ex.Message, "error");
                }
            }
        }

        #endregion

        #region Database Backup & Restore

        private static readonly string[] BackupTables = new string[] {
            "AppUsers",
            "Divisions",
            "UserDivisions",
            "Vendors",
            "VendorContacts",
            "MainCategory",
            "Tiers",
            "UserTiers",
            "CategoryShareGrant",
            "GemContracts",
            "ContractPeriods",
            "ContractExtensions",
            "ContractPeriodVendors",
            "Employees",
            "EmployeeEngagements",
            "EmployeeLeaveCredits",
            "Attendance",
            "CalculationWages",
            "CalculationOverrides",
            "WageOrders",
            "CategoryWages",
            "StatutoryOrders",
            "CertificateTemplates",
            "EmployeeActionLogs",
            "ActionLog",
            "AdminActionLog",
            "AttendanceRemarks",
            "Notices",
            "NoticeReads"
        };

        private static readonly string[] DeleteSequence = new string[] {
            "NoticeReads",
            "Notices",
            "AttendanceRemarks",
            "AdminActionLog",
            "ActionLog",
            "EmployeeActionLogs",
            "CalculationOverrides",
            "CalculationWages",
            "Attendance",
            "EmployeeLeaveCredits",
            "Employees_NullEngagements",
            "EmployeeEngagements",
            "Employees",
            "ContractPeriodVendors",
            "ContractExtensions",
            "ContractPeriods",
            "GemContracts",
            "CategoryWages",
            "WageOrders",
            "StatutoryOrders",
            "CertificateTemplates",
            "CategoryShareGrant",
            "UserTiers",
            "Tiers",
            "MainCategory",
            "VendorContacts",
            "Vendors",
            "UserDivisions",
            "Divisions",
            "AppUsers"
        };

        private static readonly string[] InsertSequence = new string[] {
            "AppUsers",
            "Divisions",
            "UserDivisions",
            "Vendors",
            "VendorContacts",
            "MainCategory",
            "Tiers",
            "UserTiers",
            "CategoryShareGrant",
            "GemContracts",
            "ContractPeriods",
            "ContractExtensions",
            "ContractPeriodVendors",
            "Employees",
            "EmployeeEngagements",
            "Employees_UpdateEngagements",
            "EmployeeLeaveCredits",
            "Attendance",
            "CalculationWages",
            "CalculationOverrides",
            "WageOrders",
            "CategoryWages",
            "StatutoryOrders",
            "CertificateTemplates",
            "EmployeeActionLogs",
            "ActionLog",
            "AdminActionLog",
            "AttendanceRemarks",
            "Notices",
            "NoticeReads"
        };

        protected void btnExportBackup_Click(object sender, EventArgs e)
        {
            try
            {
                var backupData = new Dictionary<string, object>();

                // Export all active database tables
                foreach (string table in BackupTables)
                {
                    try
                    {
                        DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), "SELECT * FROM " + table);
                        var list = new List<Dictionary<string, object>>();
                        foreach (DataRow row in dt.Rows)
                        {
                            var dict = new Dictionary<string, object>();
                            foreach (DataColumn col in dt.Columns)
                            {
                                dict[col.ColumnName] = ConvertValue(row[col]);
                            }
                            list.Add(dict);
                        }
                        backupData[table] = list;
                    }
                    catch (OracleException oex)
                    {
                        // Skip if table does not exist in current Oracle database schema (ORA-00942)
                        if (oex.Number == 942)
                        {
                            continue;
                        }
                        throw;
                    }
                }

                var serializer = new JavaScriptSerializer();
                serializer.MaxJsonLength = int.MaxValue;
                string json = serializer.Serialize(backupData);

                Response.Clear();
                Response.ContentType = "application/json";
                Response.AddHeader("content-disposition", "attachment; filename=attendance_backup_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".json");
                Response.Write(json);
                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
                // Normal and expected on Response.End()
            }
            catch (Exception ex)
            {
                ShowToast("Error exporting database: " + ex.Message, "error");
            }
        }

        private object ConvertValue(object val)
        {
            if (val == null || val == DBNull.Value)
                return null;
            if (val is DateTime)
                return ((DateTime)val).ToString("yyyy-MM-dd HH:mm:ss.fff");
            if (val is string || val is ValueType)
                return val;
            return val.ToString();
        }

        protected void btnRestoreBackup_Click(object sender, EventArgs e)
        {
            if (!fuBackupFile.HasFile)
            {
                ShowToast("Please select a JSON backup file to restore.", "warning");
                return;
            }

            try
            {
                string jsonContent = "";
                using (var reader = new StreamReader(fuBackupFile.FileContent))
                {
                    jsonContent = reader.ReadToEnd();
                }

                var serializer = new JavaScriptSerializer();
                serializer.MaxJsonLength = int.MaxValue;
                var rawBackupData = serializer.Deserialize<Dictionary<string, List<Dictionary<string, object>>>>(jsonContent);

                if (rawBackupData == null)
                {
                    ShowToast("Invalid backup file format.", "error");
                    return;
                }

                // Convert all table names and row dictionary keys to be case-insensitive
                var backupData = new Dictionary<string, List<Dictionary<string, object>>>(StringComparer.OrdinalIgnoreCase);
                foreach (var kp in rawBackupData)
                {
                    var list = new List<Dictionary<string, object>>();
                    foreach (var dict in kp.Value)
                    {
                        list.Add(new Dictionary<string, object>(dict, StringComparer.OrdinalIgnoreCase));
                    }
                    backupData[kp.Key] = list;
                }

                // Ensure Divisions and UserDivisions tables exist prior to restore
                DBHelper.EnsureDivisionsTableExists();

                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            var sequenceMapping = new[] {
                                new { Table = "Divisions", Sequence = "SEQ_Divisions", Trigger = "TRG_Divisions" },
                                new { Table = "MainCategory", Sequence = "SEQ_MainCategory", Trigger = "TRG_MainCategory" },
                                new { Table = "Tiers", Sequence = "SEQ_Tiers", Trigger = "TRG_Tiers" },
                                new { Table = "UserTiers", Sequence = "SEQ_UserTiers", Trigger = "TRG_UserTiers" },
                                new { Table = "CategoryShareGrant", Sequence = "SEQ_CategoryShareGrant", Trigger = "TRG_CategoryShareGrant" },
                                new { Table = "Vendors", Sequence = "SEQ_Vendors", Trigger = "TRG_Vendors" },
                                new { Table = "GemContracts", Sequence = "SEQ_GemContracts", Trigger = "TRG_GemContracts" },
                                new { Table = "ContractPeriods", Sequence = "SEQ_ContractPeriods", Trigger = "TRG_ContractPeriods" },
                                new { Table = "ContractExtensions", Sequence = "SEQ_ContractExtensions", Trigger = "TRG_ContractExtensions" },
                                new { Table = "EmployeeEngagements", Sequence = "SEQ_EmployeeEngagements", Trigger = "TRG_EmployeeEngagements" },
                                new { Table = "EmployeeLeaveCredits", Sequence = "SEQ_EmployeeLeaveCredits", Trigger = "TRG_EmployeeLeaveCredits" },
                                new { Table = "Attendance", Sequence = "SEQ_Attendance", Trigger = "TRG_Attendance" },
                                new { Table = "WageOrders", Sequence = "SEQ_WageOrders", Trigger = "TRG_WageOrders" },
                                new { Table = "CategoryWages", Sequence = "SEQ_CategoryWages", Trigger = "TRG_CategoryWages" },
                                new { Table = "StatutoryOrders", Sequence = "SEQ_StatutoryOrders", Trigger = "TRG_StatutoryOrders" },
                                new { Table = "EmployeeActionLogs", Sequence = "SEQ_EmployeeActionLogs", Trigger = "TRG_EmployeeActionLogs" },
                                new { Table = "ActionLog", Sequence = "SEQ_ActionLog", Trigger = "TRG_ActionLog" },
                                new { Table = "AdminActionLog", Sequence = "SEQ_AdminActionLog", Trigger = "TRG_AdminActionLog" },
                                new { Table = "AttendanceRemarks", Sequence = "SEQ_AttendanceRemarks", Trigger = "TRG_AttendanceRemarks" },
                                new { Table = "Notices", Sequence = "SEQ_Notices", Trigger = "TRG_Notices" }
                            };

                            // 0. Disable all table triggers during restore to prevent ORA-04098 invalid trigger errors
                            foreach (var map in sequenceMapping)
                            {
                                try
                                {
                                    using (OracleCommand disableCmd = new OracleCommand(string.Format("ALTER TRIGGER {0} DISABLE", map.Trigger), conn))
                                    {
                                        disableCmd.Transaction = trans;
                                        disableCmd.ExecuteNonQuery();
                                    }
                                }
                                catch { }
                            }

                            // 1. Delete all tables in sequence
                            foreach (string table in DeleteSequence)
                            {
                                try
                                {
                                    if (table == "Employees_NullEngagements")
                                    {
                                        using (OracleCommand cmd = new OracleCommand("UPDATE Employees SET CurrentEngagementId = NULL", conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.ExecuteNonQuery();
                                        }
                                    }
                                    else
                                    {
                                        using (OracleCommand cmd = new OracleCommand("DELETE FROM " + table, conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.ExecuteNonQuery();
                                        }
                                    }
                                }
                                catch (OracleException oex)
                                {
                                    if (oex.Number == 942) continue; // Skip non-existent legacy tables
                                    throw;
                                }
                            }

                            // 2. Insert all tables in sequence
                            foreach (string table in InsertSequence)
                            {
                                if (table == "Employees_UpdateEngagements")
                                {
                                    if (backupData.ContainsKey("Employees"))
                                    {
                                        var employeeRows = backupData["Employees"];
                                        using (OracleCommand updateCmd = new OracleCommand("UPDATE Employees SET CurrentEngagementId = :CurrentEngagementId WHERE MasterId = :MasterId", conn))
                                        {
                                            updateCmd.Transaction = trans;
                                            updateCmd.BindByName = true;

                                            foreach (var row in employeeRows)
                                            {
                                                if (row.ContainsKey("CurrentEngagementId") && row["CurrentEngagementId"] != null)
                                                {
                                                    updateCmd.Parameters.Clear();
                                                    updateCmd.Parameters.Add(new OracleParameter("CurrentEngagementId", Convert.ToInt32(row["CurrentEngagementId"])));
                                                    updateCmd.Parameters.Add(new OracleParameter("MasterId", row["MasterId"].ToString()));
                                                    updateCmd.ExecuteNonQuery();
                                                }
                                            }
                                        }
                                    }
                                }
                                else if (table == "Employees")
                                {
                                    if (backupData.ContainsKey("Employees"))
                                    {
                                        var employeeRows = backupData["Employees"];
                                        var modifiedRows = new List<Dictionary<string, object>>();
                                        foreach (var row in employeeRows)
                                        {
                                            var copy = new Dictionary<string, object>(row, StringComparer.OrdinalIgnoreCase);
                                            if (copy.ContainsKey("CurrentEngagementId"))
                                            {
                                                copy["CurrentEngagementId"] = null;
                                            }
                                            modifiedRows.Add(copy);
                                        }
                                        InsertRows(conn, trans, "Employees", modifiedRows);
                                    }
                                }
                                else if (table == "CalculationWages" || table == "CategoryWages")
                                {
                                    if (backupData.ContainsKey(table))
                                    {
                                        var filteredRows = new List<Dictionary<string, object>>();
                                        foreach (var r in backupData[table])
                                        {
                                            if (r.ContainsKey("TierId") && r["TierId"] != null && !string.IsNullOrWhiteSpace(r["TierId"].ToString()))
                                            {
                                                filteredRows.Add(r);
                                            }
                                        }
                                        InsertRows(conn, trans, table, filteredRows);
                                    }
                                }
                                else
                                {
                                    if (backupData.ContainsKey(table))
                                    {
                                        InsertRows(conn, trans, table, backupData[table]);
                                    }
                                }
                            }

                            // 3. Reset all sequences and recompile/enable triggers
                            foreach (var map in sequenceMapping)
                            {
                                ResetSequenceAndTrigger(conn, trans, map.Table, map.Sequence, map.Trigger);
                            }

                            // 4. Log database restoration
                            string userPcno = Session["PCNO"]?.ToString() ?? "SYSTEM";
                            string userDisplayName = Session["Name"]?.ToString() ?? "Administrator";
                            string logSql = @"
                                INSERT INTO ActionLog (ActionType, PerformedBy, TargetId, Description, PreState, PostState)
                                VALUES ('DATABASE_RESTORE', :PerformedBy, 'SYSTEM', :Description, NULL, NULL)";
                            
                            using (OracleCommand logCmd = new OracleCommand(logSql, conn))
                            {
                                logCmd.Transaction = trans;
                                logCmd.Parameters.Add(new OracleParameter("PerformedBy", userDisplayName + " (" + userPcno + ")"));
                                logCmd.Parameters.Add(new OracleParameter("Description", "Database successfully restored from JSON backup file."));
                                logCmd.ExecuteNonQuery();
                            }

                            trans.Commit();
                            
                            BindDivisions();
                            BindCategories();
                            BindActionLogs();

                            ShowToast("Database successfully restored from backup file.", "success");
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            ShowToast("Error restoring database: " + ex.Message, "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowToast("Failed to process backup file: " + ex.Message, "error");
            }
        }

        private void InsertRows(OracleConnection conn, OracleTransaction trans, string tableName, List<Dictionary<string, object>> rows)
        {
            if (rows == null || rows.Count == 0)
                return;

            var typeDict = new Dictionary<string, Type>(StringComparer.OrdinalIgnoreCase);
            using (OracleCommand schemaCmd = new OracleCommand("SELECT * FROM " + tableName + " WHERE 1=0", conn))
            {
                schemaCmd.Transaction = trans;
                using (OracleDataReader reader = schemaCmd.ExecuteReader(CommandBehavior.SchemaOnly))
                {
                    DataTable schemaTable = reader.GetSchemaTable();
                    if (schemaTable != null)
                    {
                        foreach (DataRow colRow in schemaTable.Rows)
                        {
                            string colName = colRow["ColumnName"].ToString();
                            Type dataType = (Type)colRow["DataType"];
                            typeDict[colName] = dataType;
                        }
                    }
                }
            }

            var firstRow = rows[0];
            var columnNames = new List<string>();
            var parameterNames = new List<string>();

            foreach (var key in firstRow.Keys)
            {
                if (typeDict.ContainsKey(key))
                {
                    columnNames.Add(key);
                    parameterNames.Add(":" + key);
                }
            }

            if (columnNames.Count == 0)
                return;

            string insertSql = string.Format("INSERT INTO {0} ({1}) VALUES ({2})", 
                tableName, 
                string.Join(", ", columnNames), 
                string.Join(", ", parameterNames));

            using (OracleCommand cmd = new OracleCommand(insertSql, conn))
            {
                cmd.Transaction = trans;
                cmd.BindByName = true;

                foreach (var row in rows)
                {
                    cmd.Parameters.Clear();
                    foreach (string colName in columnNames)
                    {
                        object value = row[colName];
                        Type targetType;
                        Type tType;
                        if (value == null)
                        {
                            value = DBNull.Value;
                        }
                        else if (typeDict.TryGetValue(colName, out targetType) && targetType == typeof(DateTime))
                        {
                            if (value is string)
                            {
                                DateTime parsedDate;
                                if (DateTime.TryParse((string)value, out parsedDate))
                                {
                                    value = parsedDate;
                                }
                                else
                                {
                                    value = DBNull.Value;
                                }
                            }
                        }
                        else if (typeDict.TryGetValue(colName, out tType) && (tType == typeof(int) || tType == typeof(long) || tType == typeof(short) || tType == typeof(decimal) || tType == typeof(double) || tType == typeof(float)))
                        {
                            if (value is string)
                            {
                                decimal parsedNum;
                                if (decimal.TryParse((string)value, out parsedNum))
                                {
                                    value = parsedNum;
                                }
                                else
                                {
                                    value = DBNull.Value;
                                }
                            }
                        }

                        cmd.Parameters.Add(new OracleParameter(colName, value));
                    }
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void ResetSequenceAndTrigger(OracleConnection conn, OracleTransaction trans, string tableName, string seqName, string triggerName)
        {
            long maxId = 0;
            try
            {
                string queryMax = string.Format("SELECT MAX(Id) FROM {0}", tableName);
                using (OracleCommand cmd = new OracleCommand(queryMax, conn))
                {
                    cmd.Transaction = trans;
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        maxId = Convert.ToInt64(res);
                    }
                }
            }
            catch
            {
                return; // Skip sequence reset if table does not exist
            }

            long startWith = maxId + 1;
            if (startWith < 1) startWith = 1;

            try
            {
                string dropSql = string.Format("DROP SEQUENCE {0}", seqName);
                using (OracleCommand cmd = new OracleCommand(dropSql, conn))
                {
                    cmd.Transaction = trans;
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }

            string createSql = string.Format("CREATE SEQUENCE {0} START WITH {1} INCREMENT BY 1 NOCACHE NOCYCLE", seqName, startWith);
            using (OracleCommand cmd = new OracleCommand(createSql, conn))
            {
                cmd.Transaction = trans;
                cmd.ExecuteNonQuery();
            }

            try
            {
                string rebindSql = string.Format(@"
                    CREATE OR REPLACE TRIGGER {0}
                    BEFORE INSERT ON {1}
                    FOR EACH ROW
                    BEGIN
                        IF :NEW.Id IS NULL THEN
                            SELECT {2}.NEXTVAL INTO :NEW.Id FROM DUAL;
                        END IF;
                    END;", triggerName, tableName, seqName);
                using (OracleCommand cmd = new OracleCommand(rebindSql, conn))
                {
                    cmd.Transaction = trans;
                    cmd.ExecuteNonQuery();
                }

                using (OracleCommand enableCmd = new OracleCommand(string.Format("ALTER TRIGGER {0} ENABLE", triggerName), conn))
                {
                    enableCmd.Transaction = trans;
                    enableCmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        #endregion

        #region POC Edit Window Settings

        private void BindEditWindowSettings()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                if (role == 4) // Super Admin
                {
                    pnlSuperAdminEditDays.Visible = true;
                    pnlCategoryAdminEditDays.Visible = false;

                    string query = @"
                        SELECT mc.Id, mc.Name, mc.AdminPCNO, u.Name AS AdminName, mc.EditDaysAllowed, COALESCE(mc.EditMode, 0) AS EditMode 
                        FROM MainCategory mc 
                        LEFT JOIN AppUsers u ON mc.AdminPCNO = u.PCNO 
                        ORDER BY mc.Name ASC";

                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                    gvAllCategoryEditDays.DataSource = dt;
                    gvAllCategoryEditDays.DataBind();
                }
                else if (role == 1) // Category Admin
                {
                    pnlCategoryAdminEditDays.Visible = true;
                    pnlSuperAdminEditDays.Visible = false;

                    string roleMode = Session["RoleMode"]?.ToString() ?? "";
                    string query = "";
                    if (roleMode == "PrimaryAdmin")
                    {
                        query = @"
                            SELECT mc.Id, mc.Name, mc.EditDaysAllowed, COALESCE(mc.EditMode, 0) AS EditMode, 'Owner' AS AccessType 
                            FROM MainCategory mc 
                            WHERE mc.AdminPCNO = :PCNO 
                            ORDER BY mc.Name ASC";
                    }
                    else if (roleMode == "SecondaryAdmin")
                    {
                        query = @"
                            SELECT mc.Id, mc.Name, mc.EditDaysAllowed, COALESCE(mc.EditMode, 0) AS EditMode, 'Shared' AS AccessType 
                            FROM MainCategory mc 
                            WHERE mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                            ORDER BY mc.Name ASC";
                    }
                    else
                    {
                        query = @"
                            SELECT mc.Id, mc.Name, mc.EditDaysAllowed, COALESCE(mc.EditMode, 0) AS EditMode,
                                   CASE WHEN mc.AdminPCNO = :PCNO THEN 'Owner' ELSE 'Shared' END AS AccessType 
                            FROM MainCategory mc 
                            WHERE mc.AdminPCNO = :PCNO 
                               OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                            ORDER BY mc.Name ASC";
                    }

                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                    rptCategoryEditDays.DataSource = dt;
                    rptCategoryEditDays.DataBind();
                }

                ClientScript.RegisterStartupScript(GetType(), "InitEditToggles", "setTimeout(initEditModeToggles, 50);", true);
            }
            catch (Exception ex)
            {
                ShowToast("Error loading edit window settings: " + ex.Message, "error");
            }
        }

        protected void rptCategoryEditDays_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DropDownList ddlEditMode = e.Item.FindControl("ddlEditMode") as DropDownList;
                DataRowView drv = e.Item.DataItem as DataRowView;
                if (ddlEditMode != null && drv != null)
                {
                    int editMode = drv["EditMode"] != DBNull.Value ? Convert.ToInt32(drv["EditMode"]) : 0;
                    ddlEditMode.SelectedValue = editMode.ToString();
                }
            }
        }

        protected void rptCategoryEditDays_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SaveEditDays")
            {
                try
                {
                    DropDownList ddlEditMode = e.Item.FindControl("ddlEditMode") as DropDownList;
                    TextBox txtEditDays = e.Item.FindControl("txtEditDays") as TextBox;
                    HiddenField hfCatId = e.Item.FindControl("hfCatId") as HiddenField;

                    if (txtEditDays != null && hfCatId != null && ddlEditMode != null)
                    {
                        int catId = Convert.ToInt32(hfCatId.Value);
                        int editMode = Convert.ToInt32(ddlEditMode.SelectedValue);
                        int days;
                        if (!int.TryParse(txtEditDays.Text.Trim(), out days) || days < 0 || days > 30)
                        {
                            ShowToast("Past edit days must be a valid number between 0 and 30.", "warning");
                            return;
                        }

                        string pcno = Session["PCNO"]?.ToString() ?? "";
                        string updateSql = @"
                            UPDATE MainCategory 
                            SET EditDaysAllowed = :Days, EditMode = :EditModeVal 
                            WHERE Id = :Id 
                              AND (AdminPCNO = :PCNO OR Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1))";

                        int rows = DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                            new OracleParameter("Days", days),
                            new OracleParameter("EditModeVal", editMode),
                            new OracleParameter("Id", catId),
                            new OracleParameter("PCNO", pcno));

                        if (rows > 0)
                        {
                            string modeDesc = editMode == 1 ? "Current Month Only (Till Date)" : $"{days} day(s) window";
                            ShowToast($"Successfully updated edit window rule to {modeDesc}.", "success");
                            BindEditWindowSettings();
                        }
                        else
                        {
                            ShowToast("Could not update settings. Permission denied or category not found.", "error");
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowToast("Error updating edit days setting: " + ex.Message, "error");
                }
            }
        }

        protected void gvAllCategoryEditDays_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow && (e.Row.RowState & DataControlRowState.Edit) > 0)
            {
                DropDownList ddlEditMode = e.Row.FindControl("ddlEditMode") as DropDownList;
                DataRowView drv = e.Row.DataItem as DataRowView;
                if (ddlEditMode != null && drv != null)
                {
                    int editMode = drv["EditMode"] != DBNull.Value ? Convert.ToInt32(drv["EditMode"]) : 0;
                    ddlEditMode.SelectedValue = editMode.ToString();
                }
            }
        }

        protected void gvAllCategoryEditDays_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvAllCategoryEditDays.EditIndex = e.NewEditIndex;
            BindEditWindowSettings();
        }

        protected void gvAllCategoryEditDays_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvAllCategoryEditDays.EditIndex = -1;
            BindEditWindowSettings();
        }

        protected void gvAllCategoryEditDays_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                int catId = Convert.ToInt32(gvAllCategoryEditDays.DataKeys[e.RowIndex].Value);
                GridViewRow row = gvAllCategoryEditDays.Rows[e.RowIndex];
                DropDownList ddlEditMode = row.FindControl("ddlEditMode") as DropDownList;
                TextBox txtEditDays = row.FindControl("txtEditDaysAllowed") as TextBox;

                if (txtEditDays != null && ddlEditMode != null)
                {
                    int editMode = Convert.ToInt32(ddlEditMode.SelectedValue);
                    int days;
                    if (!int.TryParse(txtEditDays.Text.Trim(), out days) || days < 0 || days > 30)
                    {
                        ShowToast("Past edit days must be a valid number between 0 and 30.", "warning");
                        return;
                    }

                    string updateSql = "UPDATE MainCategory SET EditDaysAllowed = :Days, EditMode = :EditModeVal WHERE Id = :Id";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                        new OracleParameter("Days", days),
                        new OracleParameter("EditModeVal", editMode),
                        new OracleParameter("Id", catId));

                    gvAllCategoryEditDays.EditIndex = -1;
                    BindEditWindowSettings();
                    string modeDesc = editMode == 1 ? "Current Month Only (Till Date)" : $"{days} day(s) window";
                    ShowToast($"Updated edit window rule to {modeDesc} for the selected category.", "success");
                }
            }
            catch (Exception ex)
            {
                ShowToast("Error updating category edit days: " + ex.Message, "error");
            }
        }

        protected string FormatAdminDisplay(object adminNameObj, object adminPcnoObj)
        {
            string adminName = adminNameObj != DBNull.Value && adminNameObj != null ? adminNameObj.ToString() : "";
            string adminPcno = adminPcnoObj != DBNull.Value && adminPcnoObj != null ? adminPcnoObj.ToString() : "";

            if (string.IsNullOrEmpty(adminName) && string.IsNullOrEmpty(adminPcno))
            {
                return "<span class=\"text-muted font-italic\">Unassigned</span>";
            }

            if (string.IsNullOrEmpty(adminPcno))
            {
                return adminName;
            }

            return $"{adminName} ({adminPcno})";
        }

        #endregion
    }
}
