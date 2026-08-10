using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Employee : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated || Session["PCNO"] == null)
            {
                System.Web.Security.FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx");
                return;
            }

            // Only admin can access employee master in the original logic
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                Response.Write("<!DOCTYPE html><html><head><title>Access Denied</title><link href='Static/fontawesome-free/css/all.min.css' rel='stylesheet' type='text/css' /><link href='Static/css/sb-admin-2.min.css' rel='stylesheet' /><style>body { background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); height: 100vh; display: flex; align-items: center; justify-content: center; font-family: 'Nunito', sans-serif; color: #f1f5f9; margin: 0; } .error-card { background: rgba(30, 41, 59, 0.7); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px; padding: 40px; text-align: center; max-width: 450px; width: 90%; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.3); animation: fadeIn 0.5s ease-out; } @keyframes fadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } } .error-icon { font-size: 64px; color: #f43f5e; margin-bottom: 20px; animation: pulse 2s infinite; } @keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.05); } 100% { transform: scale(1); } } h2 { font-size: 24px; margin-bottom: 10px; font-weight: 700; } p { color: #94a3b8; font-size: 16px; margin-bottom: 30px; line-height: 1.5; } .btn-action { display: inline-block; background: linear-gradient(135deg, #4f46e5 0%, #3b82f6 100%); color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: all 0.3s ease; box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.2); margin: 5px; } .btn-action:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(79, 70, 229, 0.4); color: white; } .btn-secondary-action { display: inline-block; background: rgba(255, 255, 255, 0.1); color: #e2e8f0; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: all 0.3s ease; margin: 5px; } .btn-secondary-action:hover { background: rgba(255, 255, 255, 0.2); color: white; }</style></head><body><div class='error-card'><div class='error-icon'><i class='fas fa-exclamation-triangle'></i></div><h2>Access Denied</h2><p>This page is restricted. Only administrators are allowed to access this resource.</p><div><a href='Login.aspx' class='btn-action'>Login as Admin</a><a href='Dashboard.aspx' class='btn-secondary-action'>Go to Dashboard</a></div></div></body></html>");
                Response.End();
                return;
            }

            if (!IsPostBack)
            {
                PopulateDropdowns();
                BindResignedEmployees();
                PopulateDeleteEmployeeDropdown();
                BindGrid();
            }
        }

        private void PopulateDropdowns()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                // Populate Divisions
                DataTable dtDiv = DBHelper.GetCompanyDivisionsDataTable();
                ddlDept.DataSource = dtDiv;
                ddlDept.DataTextField = "Name";
                ddlDept.DataValueField = "Name";
                ddlDept.DataBind();

                // Populate Tiers (sub-categories)
                DataTable dtTiers = DBHelper.GetVisibleTiersDataTable(pcno, role);
                
                // For manual entry category
                ddlCat.DataSource = dtTiers;
                ddlCat.DataTextField = "DisplayName";
                ddlCat.DataValueField = "TierId";
                ddlCat.DataBind();

                // For import category
                ddlImportCat.DataSource = dtTiers;
                ddlImportCat.DataTextField = "DisplayName";
                ddlImportCat.DataValueField = "TierId";
                ddlImportCat.DataBind();

                // For search filter
                string selectedFilter = ddlFilter.SelectedValue;
                ddlFilter.Items.Clear();
                ddlFilter.Items.Add(new ListItem("All", "All"));
                foreach (DataRow row in dtTiers.Rows)
                {
                    ddlFilter.Items.Add(new ListItem(row["DisplayName"].ToString(), row["TierId"].ToString()));
                }
                if (ddlFilter.Items.FindByValue(selectedFilter) != null)
                {
                    ddlFilter.SelectedValue = selectedFilter;
                }
                
                // For search division filter
                string selectedDivFilter = ddlFilterDiv.SelectedValue;
                ddlFilterDiv.Items.Clear();
                ddlFilterDiv.Items.Add(new ListItem("All", "All"));
                foreach (DataRow row in dtDiv.Rows)
                {
                    ddlFilterDiv.Items.Add(new ListItem(row["Name"].ToString(), row["Name"].ToString()));
                }
                if (ddlFilterDiv.Items.FindByValue(selectedDivFilter) != null)
                {
                    ddlFilterDiv.SelectedValue = selectedDivFilter;
                }

                // Populate Bulk Leave Category Dropdown
                ddlBulkLeaveCategory.Items.Clear();
                ddlBulkLeaveCategory.Items.Add(new ListItem("All Categories", "All"));
                foreach (DataRow row in dtTiers.Rows)
                {
                    ddlBulkLeaveCategory.Items.Add(new ListItem(row["DisplayName"].ToString(), row["TierId"].ToString()));
                }

                // Populate Bulk Leave Division Dropdown
                ddlBulkLeaveDivision.Items.Clear();
                ddlBulkLeaveDivision.Items.Add(new ListItem("All Directorates", "All"));
                foreach (DataRow row in dtDiv.Rows)
                {
                    ddlBulkLeaveDivision.Items.Add(new ListItem(row["Name"].ToString(), row["Name"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error populating dropdowns: " + ex.Message, false);
            }
        }

        private void BindGrid()
        {
            string filter = ddlFilter.SelectedValue;
            string divFilter = ddlFilterDiv.SelectedValue;
            string search = txtSearch.Text.Trim();
            string tabStatus = string.IsNullOrEmpty(hfActiveTab.Value) ? "Active" : hfActiveTab.Value;

            string query = "";
            List<OracleParameter> pList = new List<OracleParameter>();

            int role = Convert.ToInt32(Session["Role"] ?? 0);
            string pcno = Session["PCNO"]?.ToString() ?? "";

            string catSelect = "(SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category";

            if (tabStatus == "Active")
            {
                query = "SELECT e.MasterId, e.ID, e.Name, e.Department, " + catSelect + ", NVL(e.OriginalJoinDate, e.JoinDate) AS JoinDate, e.LeaveBalance, e.PrevLeaveBalance, e.Status, e.Experience, e.ExperienceIn, e.Qualification, ee.StartDate AS CurrentEngStartDate FROM Employees e LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id WHERE e.MasterId NOT LIKE 'GLOBAL%' AND e.Status <> 'System' AND e.Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred')";
            }
            else
            {
                query = @"SELECT e.MasterId, e.ID, e.Name, e.Department, " + catSelect + @", 
                                 NVL(e.OriginalJoinDate, e.JoinDate) AS JoinDate, e.LeaveBalance, e.PrevLeaveBalance, 
                                 e.Status, e.Experience, e.ExperienceIn, e.Qualification, 
                                 ee.StartDate AS CurrentEngStartDate 
                          FROM Employees e 
                          LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id 
                          LEFT JOIN Tiers t ON e.TierId = t.Id
                          WHERE e.MasterId NOT LIKE 'GLOBAL%' AND e.Status <> 'System' AND e.Status = 'Resigned'
                            AND NOT EXISTS (
                                SELECT 1 
                                FROM   Employees e2
                                LEFT JOIN Tiers t2 ON e2.TierId = t2.Id
                                WHERE  e2.EmployeeHistoryId = e.EmployeeHistoryId
                                  AND  (t2.MainCategoryId IS NULL OR t.MainCategoryId IS NULL OR t2.MainCategoryId = t.MainCategoryId)
                                  AND  e2.Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred')
                            )";
            }
            
            if (filter != "All")
            {
                query += " AND e.TierId = :TierId";
                pList.Add(new OracleParameter("TierId", Convert.ToInt32(filter)));
            }
            if (divFilter != "All")
            {
                query += " AND e.Department = :Department";
                pList.Add(new OracleParameter("Department", divFilter));
            }
            if (!string.IsNullOrEmpty(search))
            {
                query += " AND (UPPER(e.ID) LIKE UPPER(:Search) OR UPPER(e.Name) LIKE UPPER(:Search))";
                pList.Add(new OracleParameter("Search", "%" + search + "%"));
            }

            string statusFilter = ddlFilterStatus.SelectedValue;
            if (statusFilter != "All" && tabStatus == "Active")
            {
                if (statusFilter == "Active")
                {
                    query += " AND e.Status IN ('Active', 'Upgraded', 'Downgraded', 'Transferred')";
                }
                else
                {
                    query += " AND e.Status = :StatusFilter";
                    pList.Add(new OracleParameter("StatusFilter", statusFilter));
                }
            }

            string roleMode = Session["RoleMode"]?.ToString() ?? "";
            string adminCatCond = (roleMode == "PrimaryAdmin") ? "mc.AdminPCNO = :PCNO"
                : (roleMode == "SecondaryAdmin") ? "(mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))"
                : "(mc.AdminPCNO = :PCNO OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))";

            // Scope logic for logged in user division/tier visibility
            query += $@" AND (
                :IsSuper = 1
                OR (NVL(ee.TierId, e.TierId) IS NOT NULL AND NVL(ee.TierId, e.TierId) IN (
                    SELECT t.Id 
                    FROM Tiers t
                    JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                    LEFT JOIN UserTiers ut ON t.Id = ut.TierId AND :Role = 0
                    WHERE (:Role = 4)
                       OR (:Role = 1 AND {adminCatCond})
                       OR (:Role = 0 AND ut.PCNO = :PCNO)
                ))
            )";
            pList.Add(new OracleParameter("IsSuper", (role == 4) ? 1 : 0));
            pList.Add(new OracleParameter("Role", role));
            pList.Add(new OracleParameter("PCNO", pcno));
            
            query += " ORDER BY e.Department ASC, e.Name ASC";
            
            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pList.ToArray());
            
            gvEmployees.DataSource = dt;
            gvEmployees.DataBind();

            // Set active states on the tab LinkButtons
            if (tabStatus == "Resigned")
            {
                btnTabActive.CssClass = "nav-link";
                btnTabResigned.CssClass = "nav-link active";
            }
            else
            {
                btnTabActive.CssClass = "nav-link active";
                btnTabResigned.CssClass = "nav-link";
            }
        }

        protected void btnSubmitBulkLeave_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate amount
                float amount;
                if (!float.TryParse(txtBulkLeaveAmount.Text, out amount))
                {
                    ShowMessage("Please enter a valid numeric leave amount.", false);
                    return;
                }

                // Validate date
                DateTime effectiveDate;
                if (!DateTime.TryParse(txtBulkLeaveDate.Text, out effectiveDate))
                {
                    ShowMessage("Please enter a valid effective date.", false);
                    return;
                }

                // Validate remarks
                string remarks = txtBulkLeaveRemarks.Text.Trim();
                if (string.IsNullOrEmpty(remarks))
                {
                    ShowMessage("Please enter remarks for this bulk leave adjustment.", false);
                    return;
                }

                string selectedCat = ddlBulkLeaveCategory.SelectedValue;
                string selectedDiv = ddlBulkLeaveDivision.SelectedValue;

                // Build query to select target employees who have active engagements
                string selectSql = @"
                    SELECT e.MasterId, ee.ContractPeriodId 
                    FROM Employees e
                    JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                    WHERE e.Status <> 'Resigned'";
                
                var parameters = new List<OracleParameter>();
                if (selectedCat != "All")
                {
                    selectSql += " AND e.Category = :Category";
                    parameters.Add(new OracleParameter("Category", selectedCat));
                }
                if (selectedDiv != "All")
                {
                    selectSql += " AND e.Department = :Division";
                    parameters.Add(new OracleParameter("Division", selectedDiv));
                }

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), selectSql, parameters.ToArray());

                int rowsAffected = 0;
                string connStr = DBHelper.GetAttendanceDBConnection();
                foreach (DataRow row in dt.Rows)
                {
                    string empMasterId = row["MasterId"].ToString();
                    int cpId = Convert.ToInt32(row["ContractPeriodId"]);

                    // Insert record in EmployeeLeaveCredits
                    string insCredit = @"
                        INSERT INTO EmployeeLeaveCredits (EmpID, ContractPeriodId, Amount, EffectiveDate, Remarks)
                        VALUES (:EmpID, :CpId, :Amount, :EffectiveDate, :Remarks)";
                    DBHelper.ExecuteNonQuery(connStr, insCredit,
                        new OracleParameter("EmpID", empMasterId),
                        new OracleParameter("CpId", cpId),
                        new OracleParameter("Amount", amount),
                        new OracleParameter("EffectiveDate", effectiveDate),
                        new OracleParameter("Remarks", remarks));

                    // Update Employee Master balance
                    string updEmp = "UPDATE Employees SET LeaveBalance = LeaveBalance + :Amount WHERE MasterId = :EmpID";
                    DBHelper.ExecuteNonQuery(connStr, updEmp,
                        new OracleParameter("Amount", amount),
                        new OracleParameter("EmpID", empMasterId));

                    rowsAffected++;
                }

                // Log the action
                string desc = $"Bulk leave adjustment: {(amount >= 0 ? "+" : "")}{amount} days applied with Effective Date {effectiveDate:yyyy-MM-dd} to Category: '{selectedCat}', Directorate: '{selectedDiv}'. Rows updated: {rowsAffected}. Remarks: {remarks}";
                ActionLogger.LogAction("BULK_LEAVE", "ALL", desc, null, null);

                // Clear controls
                txtBulkLeaveAmount.Text = "";
                txtBulkLeaveDate.Text = "";
                txtBulkLeaveRemarks.Text = "";

                // Bind grid & show success
                BindGrid();
                ShowMessage($"Successfully applied leave adjustment of {amount} days (Effective: {effectiveDate:yyyy-MM-dd}) to {rowsAffected} active employees.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error applying bulk leave adjustment: " + ex.Message, false);
            }
        }

        protected void btnResetBulkLeave_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate date
                DateTime effectiveDate;
                if (!DateTime.TryParse(txtBulkLeaveDate.Text, out effectiveDate))
                {
                    ShowMessage("Please enter a valid effective date.", false);
                    return;
                }

                // Validate remarks
                string remarks = txtBulkLeaveRemarks.Text.Trim();
                if (string.IsNullOrEmpty(remarks))
                {
                    ShowMessage("Please enter remarks for this bulk leave reset.", false);
                    return;
                }

                string selectedCat = ddlBulkLeaveCategory.SelectedValue;
                string selectedDiv = ddlBulkLeaveDivision.SelectedValue;

                // Build query to select target employees who have active engagements and get their current LeaveBalance
                string selectSql = @"
                    SELECT e.MasterId, e.LeaveBalance, ee.ContractPeriodId 
                    FROM Employees e
                    JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                    WHERE e.Status <> 'Resigned'";
                
                var parameters = new List<OracleParameter>();
                if (selectedCat != "All")
                {
                    selectSql += " AND e.Category = :Category";
                    parameters.Add(new OracleParameter("Category", selectedCat));
                }
                if (selectedDiv != "All")
                {
                    selectSql += " AND e.Department = :Division";
                    parameters.Add(new OracleParameter("Division", selectedDiv));
                }

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), selectSql, parameters.ToArray());

                int rowsAffected = 0;
                string connStr = DBHelper.GetAttendanceDBConnection();
                foreach (DataRow row in dt.Rows)
                {
                    string empMasterId = row["MasterId"].ToString();
                    float currentBalance = Convert.ToSingle(row["LeaveBalance"]);
                    int cpId = Convert.ToInt32(row["ContractPeriodId"]);

                    // We only apply correction if current balance is not zero
                    if (Math.Abs(currentBalance) > 0.001f)
                    {
                        float amountToAdjust = -currentBalance;

                        // Insert record in EmployeeLeaveCredits
                        string insCredit = @"
                            INSERT INTO EmployeeLeaveCredits (EmpID, ContractPeriodId, Amount, EffectiveDate, Remarks)
                            VALUES (:EmpID, :CpId, :Amount, :EffectiveDate, :Remarks)";
                        DBHelper.ExecuteNonQuery(connStr, insCredit,
                            new OracleParameter("EmpID", empMasterId),
                            new OracleParameter("CpId", cpId),
                            new OracleParameter("Amount", amountToAdjust),
                            new OracleParameter("EffectiveDate", effectiveDate),
                            new OracleParameter("Remarks", remarks));

                        // Update Employee Master balance to 0
                        string updEmp = "UPDATE Employees SET LeaveBalance = 0 WHERE MasterId = :EmpID";
                        DBHelper.ExecuteNonQuery(connStr, updEmp,
                            new OracleParameter("EmpID", empMasterId));

                        rowsAffected++;
                    }
                }

                // Log the action
                string desc = $"Bulk leave reset to 0 applied with Effective Date {effectiveDate:yyyy-MM-dd} to Category: '{selectedCat}', Directorate: '{selectedDiv}'. Active employees adjusted: {rowsAffected}. Remarks: {remarks}";
                ActionLogger.LogAction("BULK_LEAVE_RESET", "ALL", desc, null, null);

                // Clear controls
                txtBulkLeaveAmount.Text = "";
                txtBulkLeaveDate.Text = "";
                txtBulkLeaveRemarks.Text = "";

                // Bind grid & show success
                BindGrid();
                ShowMessage($"Successfully reset leave balance to 0 for {rowsAffected} active employees (Effective: {effectiveDate:yyyy-MM-dd}).", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error resetting bulk leave: " + ex.Message, false);
            }
        }


        protected void btnAddEmployee_Click(object sender, EventArgs e)
        {
            try
            {
                string id = txtEmpID.Text.Trim();
                string name = txtEmpName.Text.Trim();
                string dept = ddlDept.SelectedValue;
                int tierId = Convert.ToInt32(ddlCat.SelectedValue);
                string joinDate = txtJoinDate.Text;
                float l;
                float leave = float.TryParse(txtLeaveBalance.Text, out l) ? l : 0;
                float prevLeave = 0;
                string phone = txtPhone.Text.Trim();
                string email = txtEmail.Text.Trim();
                string aadhar = txtAadhar.Text.Trim();
                string address = txtAddress.Text.Trim();
                string qualification = txtQualification.Text.Trim();
                float exp;
                float? experience = float.TryParse(txtExperience.Text, out exp) ? (float?)exp : null;
                string experienceIn = txtExperienceIn.Text.Trim();
                string oldId = hfEditOldID.Value;

                // Server-side fallback for rejoining employee name detail
                if (string.IsNullOrEmpty(oldId) && chkIsRejoining.Checked && !string.IsNullOrEmpty(ddlRejoiningEmployee.SelectedValue))
                {
                    ListItem selectedItem = ddlRejoiningEmployee.SelectedItem;
                    if (selectedItem != null)
                    {
                        string fallbackName = selectedItem.Attributes["data-name"];
                        if (string.IsNullOrEmpty(fallbackName))
                        {
                            string itemText = selectedItem.Text;
                            int dashIdx = itemText.IndexOf(" - ");
                            int parenIdx = itemText.LastIndexOf(" (Ex-");
                            if (dashIdx >= 0 && parenIdx > dashIdx)
                            {
                                fallbackName = itemText.Substring(dashIdx + 3, parenIdx - (dashIdx + 3)).Trim();
                            }
                        }
                        if (string.IsNullOrEmpty(name) && !string.IsNullOrEmpty(fallbackName))
                        {
                            name = fallbackName;
                            txtEmpName.Text = name;
                        }
                    }
                }
                if (!string.IsNullOrEmpty(phone))
                {
                    if (!System.Text.RegularExpressions.Regex.IsMatch(phone, @"^\d{10}$"))
                    {
                        ShowMessage("Phone number must be exactly 10 digits.", false, "employeeModal");
                        return;
                    }
                }

                if (!string.IsNullOrEmpty(aadhar))
                {
                    string cleanAadhar = aadhar.Replace(" ", "").Replace("-", "").Trim();
                    if (cleanAadhar.Length == 12)
                    {
                        string excludeMasterId = "";
                        if (!string.IsNullOrEmpty(oldId))
                        {
                            excludeMasterId = oldId;
                        }
                        else if (chkIsRejoining.Checked && !string.IsNullOrEmpty(ddlRejoiningEmployee.SelectedValue))
                        {
                            excludeMasterId = ddlRejoiningEmployee.SelectedValue;
                        }

                        string qAadharCheck = @"
                            SELECT e.Name, e.ID, e.Status 
                            FROM Employees e 
                            WHERE e.Aadhar IS NOT NULL 
                              AND REPLACE(REPLACE(e.Aadhar, ' ', ''), '-', '') = :Aadhar 
                              AND e.MasterId <> 'GLOBAL'";

                        List<OracleParameter> aParams = new List<OracleParameter> {
                            new OracleParameter("Aadhar", cleanAadhar)
                        };

                        if (!string.IsNullOrEmpty(excludeMasterId))
                        {
                            qAadharCheck += " AND e.MasterId <> :ExcludeMasterId AND e.EmployeeHistoryId <> (SELECT NVL(ee.EmployeeHistoryId, ee.MasterId) FROM Employees ee WHERE ee.MasterId = :ExcludeMasterId2)";
                            aParams.Add(new OracleParameter("ExcludeMasterId", excludeMasterId));
                            aParams.Add(new OracleParameter("ExcludeMasterId2", excludeMasterId));
                        }

                        DataTable dtAadharCheck = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), qAadharCheck, aParams.ToArray());
                        if (dtAadharCheck.Rows.Count > 0)
                        {
                            DataRow matchRow = dtAadharCheck.Rows[0];
                            string matchedName = matchRow["Name"].ToString();
                            string matchedId = matchRow["ID"] != DBNull.Value ? matchRow["ID"].ToString() : "";
                            
                            ShowMessage("Aadhaar number already registered for employee " + matchedName + (string.IsNullOrEmpty(matchedId) ? "" : " (ID: " + matchedId + ")") + ".", false, "employeeModal");
                            return;
                        }
                    }
                }

                if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(name))
                {
                    ShowMessage("ID and Name are required", false, "employeeModal");
                    return;
                }

                string preState = null;
                string actionType = "ADD";
                string description = "";
                string targetMasterId = "";

                if (string.IsNullOrEmpty(oldId))
                {
                    string masterId = GenerateNextMasterId();
                    string historyId = masterId;
                    object originalJoinDate = string.IsNullOrEmpty(joinDate) ? (object)DBNull.Value : DateTime.Parse(joinDate);

                    if (chkIsRejoining.Checked && !string.IsNullOrEmpty(ddlRejoiningEmployee.SelectedValue))
                    {
                        string oldMasterId = ddlRejoiningEmployee.SelectedValue;
                        preState = ActionLogger.CaptureEmployeeState(oldMasterId);
                        description = "Rejoined employee " + name + " (ID: " + id + ")";

                        // Fetch historical mapping info from the old resigned stint
                        string qHist = "SELECT EmployeeHistoryId, OriginalJoinDate FROM Employees WHERE MasterId = :OldMasterId";
                        DataTable dtHist = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), qHist, new OracleParameter("OldMasterId", oldMasterId));
                        if (dtHist.Rows.Count > 0)
                        {
                            historyId = dtHist.Rows[0]["EmployeeHistoryId"].ToString();
                            if (dtHist.Rows[0]["OriginalJoinDate"] != DBNull.Value)
                            {
                                originalJoinDate = Convert.ToDateTime(dtHist.Rows[0]["OriginalJoinDate"]);
                            }
                        }
                    }
                    else
                    {
                        description = "Registered new employee " + name + " (ID: " + id + ")";
                    }
                    
                    targetMasterId = masterId;

                    string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = :ID AND TierId = :TierId AND Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred') AND MasterId != :MasterId";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCheck, 
                        new OracleParameter("ID", id),
                        new OracleParameter("TierId", tierId),
                        new OracleParameter("MasterId", masterId)));
                    if (count > 0)
                    {
                        ShowMessage("Employee ID already exists in this category.", false, "employeeModal");
                        return;
                    }

                    object dbJoinDate = string.IsNullOrEmpty(joinDate) ? (object)DBNull.Value : DateTime.Parse(joinDate);

                    // Ensure organizational division exists in Divisions table to satisfy foreign key constraint
                    DBHelper.EnsureDivisionExists(dept);

                    // Insert new employee record (either new signup or a new rejoin stint row)
                    string query = "INSERT INTO Employees (MasterId, ID, Name, Department, TierId, EmployeeHistoryId, JoinDate, OriginalJoinDate, LeaveBalance, PrevLeaveBalance, Status, Phone, Email, Aadhar, Address, Qualification, Experience, ExperienceIn) VALUES (:MasterId, :ID, :Name, :Dept, :TierId, :EmployeeHistoryId, :JoinDate, :OriginalJoinDate, :Leave, :PrevLeave, 'ContractEnded', :Phone, :Email, :Aadhar, :Address, :Qualification, :Experience, :ExperienceIn)";
                    OracleParameter[] p = new OracleParameter[] {
                        new OracleParameter("MasterId", masterId),
                        new OracleParameter("ID", id),
                        new OracleParameter("Name", name),
                        new OracleParameter("Dept", dept),
                        new OracleParameter("TierId", tierId),
                        new OracleParameter("EmployeeHistoryId", historyId),
                        new OracleParameter("JoinDate", dbJoinDate),
                        new OracleParameter("OriginalJoinDate", originalJoinDate),
                        new OracleParameter("Leave", leave),
                        new OracleParameter("PrevLeave", prevLeave),
                        new OracleParameter("Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone),
                        new OracleParameter("Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email),
                        new OracleParameter("Aadhar", string.IsNullOrEmpty(aadhar) ? (object)DBNull.Value : aadhar),
                        new OracleParameter("Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address),
                        new OracleParameter("Qualification", string.IsNullOrEmpty(qualification) ? (object)DBNull.Value : qualification),
                        new OracleParameter("Experience", experience.HasValue ? (object)experience.Value : DBNull.Value),
                        new OracleParameter("ExperienceIn", string.IsNullOrEmpty(experienceIn) ? (object)DBNull.Value : experienceIn)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, p);

                    AutoEnrollActiveContract(masterId, id, tierId, dept, string.IsNullOrEmpty(joinDate) ? (DateTime?)null : DateTime.Parse(joinDate));
                    SyncIndividualLeaveCredits(DBHelper.GetAttendanceDBConnection(), masterId, leave, prevLeave);

                    // Log addition/rejoining
                    string postState = ActionLogger.CaptureEmployeeState(targetMasterId);
                    ActionLogger.LogAction(actionType, targetMasterId, description, preState, postState);

                    ShowMessage("Employee added successfully with Master ID " + masterId + ".", true);
                }
                else
                {
                    // UPDATE MODE
                    string oldMasterId = oldId; // oldId contains MasterId when editing
                    targetMasterId = oldMasterId;
                    preState = ActionLogger.CaptureEmployeeState(targetMasterId);
                    description = "Updated employee " + name + " (ID: " + id + ")";
                    actionType = "EDIT";
                    
                    string currentDeptQuery = "SELECT Department, CurrentEngagementId, PrevLeaveBalance FROM Employees WHERE MasterId = :MasterId";
                    DataTable dtCurrent = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), currentDeptQuery, new OracleParameter("MasterId", oldMasterId));
                    if (dtCurrent.Rows.Count > 0)
                    {
                        DataRow drCurrent = dtCurrent.Rows[0];
                        bool hasActiveEng = drCurrent["CurrentEngagementId"] != DBNull.Value;
                        if (hasActiveEng)
                        {
                            dept = drCurrent["Department"].ToString();
                        }
                        if (drCurrent["PrevLeaveBalance"] != DBNull.Value)
                        {
                            prevLeave = Convert.ToSingle(drCurrent["PrevLeaveBalance"]);
                        }
                    }

                    string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = :ID AND TierId = :TierId AND Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred') AND MasterId != :MasterId";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCheck, 
                        new OracleParameter("ID", id),
                        new OracleParameter("TierId", tierId),
                        new OracleParameter("MasterId", oldMasterId)));
                    if (count > 0)
                    {
                        ShowMessage("New Employee ID is already present in this category.", false, "employeeModal");
                        return;
                    }

                    string updateQuery = "UPDATE Employees SET ID = :ID, Name = :Name, Department = :Dept, TierId = :TierId, OriginalJoinDate = :OriginalJoinDate, JoinDate = CASE WHEN CurrentEngagementId IS NULL THEN :JoinDate ELSE JoinDate END, LeaveBalance = :Leave, PrevLeaveBalance = :PrevLeave, Phone = :Phone, Email = :Email, Aadhar = :Aadhar, Address = :Address, Qualification = :Qualification, Experience = :Experience, ExperienceIn = :ExperienceIn WHERE MasterId = :MasterId";
                    object dbJoinDate = string.IsNullOrEmpty(joinDate) ? (object)DBNull.Value : DateTime.Parse(joinDate);
                    OracleParameter[] pUpdate = new OracleParameter[] {
                        new OracleParameter("ID", id),
                        new OracleParameter("Name", name),
                        new OracleParameter("Dept", dept),
                        new OracleParameter("TierId", tierId),
                        new OracleParameter("OriginalJoinDate", dbJoinDate),
                        new OracleParameter("JoinDate", dbJoinDate),
                        new OracleParameter("Leave", leave),
                        new OracleParameter("PrevLeave", prevLeave),
                        new OracleParameter("Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone),
                        new OracleParameter("Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email),
                        new OracleParameter("Aadhar", string.IsNullOrEmpty(aadhar) ? (object)DBNull.Value : aadhar),
                        new OracleParameter("Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address),
                        new OracleParameter("Qualification", string.IsNullOrEmpty(qualification) ? (object)DBNull.Value : qualification),
                        new OracleParameter("Experience", experience.HasValue ? (object)experience.Value : DBNull.Value),
                        new OracleParameter("ExperienceIn", string.IsNullOrEmpty(experienceIn) ? (object)DBNull.Value : experienceIn),
                        new OracleParameter("MasterId", oldMasterId)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, pUpdate);
                    SyncIndividualLeaveCredits(DBHelper.GetAttendanceDBConnection(), oldMasterId, leave, prevLeave);

                    // Log edit
                    string postState = ActionLogger.CaptureEmployeeState(targetMasterId);
                    ActionLogger.LogAction(actionType, targetMasterId, description, preState, postState);

                    ShowMessage("Employee updated successfully.", true);
                }

                ResetForm();
                BindResignedEmployees();
                PopulateDeleteEmployeeDropdown();
                BindGrid();
            }
            catch(Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false, "employeeModal");
            }
        }

        protected void btnImport_Click(object sender, EventArgs e)
        {
            if (fileCSV.HasFile || !string.IsNullOrEmpty(hfImportData.Value))
            {
                try
                {
                    string cat = ddlImportCat.SelectedValue;
                    int currentNextMaster = 10001;
                    try
                    {
                        string maxQuery = "SELECT MasterId FROM Employees WHERE MasterId IS NOT NULL ORDER BY MasterId DESC";
                        DataTable dtMax = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), maxQuery);
                        foreach (DataRow row in dtMax.Rows)
                        {
                            string mId = row["MasterId"].ToString();
                            int val;
                            if (int.TryParse(mId, out val))
                            {
                                if (val >= currentNextMaster)
                                {
                                    currentNextMaster = val + 1;
                                }
                            }
                        }
                    }
                    catch { }

                    if (!string.IsNullOrEmpty(hfImportData.Value))
                    {
                        var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                        serializer.MaxJsonLength = int.MaxValue;
                        var rows = serializer.Deserialize<List<List<object>>>(hfImportData.Value);
                        if (rows != null && rows.Count > 1)
                        {
                            for (int i = 1; i < rows.Count; i++)
                            {
                                var v = rows[i];
                                if (v.Count >= 2 && v[0] != null && v[1] != null && !string.IsNullOrWhiteSpace(v[0].ToString()) && !string.IsNullOrWhiteSpace(v[1].ToString()))
                                {
                                    string id = v[0].ToString().Trim();
                                    string name = v[1].ToString().Trim();
                                    string dept = v.Count > 2 && v[2] != null ? v[2].ToString().Trim() : "GENERAL";
                                    if (string.IsNullOrWhiteSpace(dept)) dept = "GENERAL";
                                    string joinDate = v.Count > 3 && v[3] != null ? v[3].ToString().Trim() : "";
                                    float l;
                                    float leave = v.Count > 4 && v[4] != null && float.TryParse(v[4].ToString(), out l) ? l : 0;
                                    string qualification = v.Count > 5 && v[5] != null ? v[5].ToString().Trim() : "";
                                    float? experience = null;
                                    float expVal;
                                    if (v.Count > 6 && v[6] != null && float.TryParse(v[6].ToString(), out expVal))
                                    {
                                        experience = expVal;
                                    }
                                    string experienceIn = v.Count > 7 && v[7] != null ? v[7].ToString().Trim() : "";
                                    string phone = v.Count > 8 && v[8] != null ? v[8].ToString().Trim() : "";
                                    string email = v.Count > 9 && v[9] != null ? v[9].ToString().Trim() : "";
                                    string aadhar = v.Count > 10 && v[10] != null ? v[10].ToString().Trim() : "";
                                    string address = v.Count > 11 && v[11] != null ? v[11].ToString().Trim() : "";
                                    string rowCat = v.Count > 12 && v[12] != null ? v[12].ToString().Trim() : "";

                                    ProcessImportedRow(id, name, dept, joinDate, leave, qualification, experience, experienceIn, phone, email, aadhar, address, cat, rowCat, ref currentNextMaster);
                                }
                            }
                        }
                    }
                    else
                    {
                        // Fallback to original CSV reader
                        using (StreamReader sr = new StreamReader(fileCSV.PostedFile.InputStream))
                        {
                            string line = sr.ReadLine(); // header
                            while ((line = sr.ReadLine()) != null)
                            {
                                string[] v = line.Split(',');
                                if (v.Length >= 2 && !string.IsNullOrWhiteSpace(v[0]) && !string.IsNullOrWhiteSpace(v[1]))
                                {
                                    string id = v[0].Trim();
                                    string name = v[1].Trim();
                                    string dept = v.Length > 2 ? v[2].Trim() : "GENERAL";
                                    if (string.IsNullOrWhiteSpace(dept)) dept = "GENERAL";
                                    string joinDate = v.Length > 3 ? v[3].Trim() : "";
                                    float l;
                                    float leave = v.Length > 4 && float.TryParse(v[4], out l) ? l : 0;
                                    string qualification = v.Length > 5 ? v[5].Trim() : "";
                                    float? experience = null;
                                    float expVal;
                                    if (v.Length > 6 && float.TryParse(v[6], out expVal))
                                    {
                                        experience = expVal;
                                    }
                                    string experienceIn = v.Length > 7 ? v[7].Trim() : "";
                                    string phone = v.Length > 8 ? v[8].Trim() : "";
                                    string email = v.Length > 9 ? v[9].Trim() : "";
                                    string aadhar = v.Length > 10 ? v[10].Trim() : "";
                                    string address = v.Length > 11 ? v[11].Trim() : "";
                                    string rowCat = v.Length > 12 ? v[12].Trim() : "";

                                    ProcessImportedRow(id, name, dept, joinDate, leave, qualification, experience, experienceIn, phone, email, aadhar, address, cat, rowCat, ref currentNextMaster);
                                }
                            }
                        }
                    }

                    // Reset hidden field value after successful processing
                    hfImportData.Value = "";

                    PopulateDropdowns(); // Refresh dropdown lists with any new divisions from import
                    BindResignedEmployees();
                    PopulateDeleteEmployeeDropdown();
                    BindGrid();
                    ShowMessage("Import successful.", true);
                }
                catch(Exception ex)
                {
                    ShowMessage("Import Error: " + ex.Message, false, "importModal");
                }
            }
        }

        private int ResolveTierId(string rowCat, string defaultCat, string pcno, int role)
        {
            if (!string.IsNullOrWhiteSpace(rowCat))
            {
                DataTable dtTiers = DBHelper.GetVisibleTiersDataTable(pcno, role);
                string clean = rowCat.Trim();

                foreach (DataRow r in dtTiers.Rows)
                {
                    string tierIdStr = r["TierId"].ToString();
                    string displayName = r["DisplayName"].ToString(); // e.g. "HR:Skilled" or "HR › Skilled"
                    string tierName = r["TierName"].ToString();       // e.g. "Skilled"

                    if (tierIdStr.Equals(clean, StringComparison.OrdinalIgnoreCase) ||
                        displayName.Equals(clean, StringComparison.OrdinalIgnoreCase) ||
                        tierName.Equals(clean, StringComparison.OrdinalIgnoreCase) ||
                        displayName.Replace(" › ", ":").Equals(clean, StringComparison.OrdinalIgnoreCase) ||
                        displayName.Replace(" › ", " - ").Equals(clean, StringComparison.OrdinalIgnoreCase))
                    {
                        return Convert.ToInt32(tierIdStr);
                    }
                }
            }
            return Convert.ToInt32(defaultCat);
        }

        private void ProcessImportedRow(string id, string name, string dept, string joinDate, float leave, string qualification, float? experience, string experienceIn, string phone, string email, string aadhar, string address, string defaultCat, string rowCat, ref int currentNextMaster)
        {
            string pcno = Session["PCNO"]?.ToString() ?? "";
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            int tierId = ResolveTierId(rowCat, defaultCat, pcno, role);

            // Preserve division case if present in Company DB
            if (!string.IsNullOrEmpty(dept))
            {
                DataTable dtCompanyDivs = DBHelper.GetCompanyDivisionsDataTable();
                foreach (DataRow r in dtCompanyDivs.Rows)
                {
                    if (r["Name"].ToString().Equals(dept, StringComparison.OrdinalIgnoreCase))
                    {
                        dept = r["Name"].ToString();
                        break;
                    }
                }
            }

            // check if exists in this tier
            string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = :ID AND TierId = :TierId AND Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred')";
            int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCheck, 
                new OracleParameter("ID", id),
                new OracleParameter("TierId", tierId)));
            if (count == 0)
            {
                string masterId = currentNextMaster.ToString();
                currentNextMaster++;

                DBHelper.EnsureDivisionExists(dept);

                string query = "INSERT INTO Employees (MasterId, ID, Name, Department, TierId, EmployeeHistoryId, JoinDate, OriginalJoinDate, LeaveBalance, Status, Qualification, Experience, ExperienceIn, Phone, Email, Aadhar, Address) VALUES (:MasterId, :ID, :Name, :Dept, :TierId, :EmployeeHistoryId, :JoinDate, :OriginalJoinDate, :Leave, 'ContractEnded', :Qualification, :Experience, :ExperienceIn, :Phone, :Email, :Aadhar, :Address)";
                object dbJoinDate = DBNull.Value;
                if (!string.IsNullOrEmpty(joinDate))
                {
                    DateTime parsedDate;
                    if (DateTime.TryParse(joinDate, out parsedDate))
                    {
                        dbJoinDate = parsedDate;
                    }
                }
                
                string formattedExpIn = FormatExperienceIn(experienceIn);
                
                OracleParameter[] p = new OracleParameter[] {
                    new OracleParameter("MasterId", masterId),
                    new OracleParameter("ID", id),
                    new OracleParameter("Name", name),
                    new OracleParameter("Dept", dept),
                    new OracleParameter("TierId", tierId),
                    new OracleParameter("EmployeeHistoryId", masterId),
                    new OracleParameter("JoinDate", dbJoinDate),
                    new OracleParameter("OriginalJoinDate", dbJoinDate),
                    new OracleParameter("Leave", leave),
                    new OracleParameter("Qualification", string.IsNullOrEmpty(qualification) ? (object)DBNull.Value : qualification),
                    new OracleParameter("Experience", experience.HasValue ? (object)experience.Value : DBNull.Value),
                    new OracleParameter("ExperienceIn", string.IsNullOrEmpty(formattedExpIn) ? (object)DBNull.Value : formattedExpIn),
                    new OracleParameter("Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone),
                    new OracleParameter("Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email),
                    new OracleParameter("Aadhar", string.IsNullOrEmpty(aadhar) ? (object)DBNull.Value : aadhar),
                    new OracleParameter("Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, p);
                
                DateTime? enrollDate = null;
                if (dbJoinDate != DBNull.Value)
                {
                    enrollDate = (DateTime)dbJoinDate;
                }
                AutoEnrollActiveContract(masterId, id, tierId, dept, enrollDate);
                SyncIndividualLeaveCredits(DBHelper.GetAttendanceDBConnection(), masterId, leave, 0);

                // Log imported employee
                string postState = ActionLogger.CaptureEmployeeState(masterId);
                ActionLogger.LogAction("ADD", masterId, "Imported employee " + name + " (ID: " + id + ")", null, postState);
            }
        }

        private string FormatExperienceIn(string expIn)
        {
            if (string.IsNullOrWhiteSpace(expIn)) return "";

            string[] lines;
            if (expIn.Contains("\n"))
            {
                lines = expIn.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            }
            else if (expIn.Contains(";"))
            {
                lines = expIn.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            }
            else if (expIn.Contains("|"))
            {
                lines = expIn.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
            }
            else
            {
                lines = new[] { expIn };
            }

            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i].Trim();
                if (!string.IsNullOrEmpty(line))
                {
                    if (!line.StartsWith("-"))
                    {
                        line = "- " + line;
                    }
                    lines[i] = line;
                }
            }

            return string.Join("\r\n", lines);
        }

        protected void btnTabActive_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "Active";
            if (ddlFilterStatus.SelectedValue == "Resigned")
            {
                ddlFilterStatus.SelectedValue = "All";
            }
            BindGrid();
        }

        protected void btnTabResigned_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "Resigned";
            if (ddlFilterStatus.SelectedValue != "Resigned" && ddlFilterStatus.SelectedValue != "All")
            {
                ddlFilterStatus.SelectedValue = "All";
            }
            BindGrid();
        }

        protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected string GetActiveCount()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                string roleMode = Session["RoleMode"]?.ToString() ?? "";
                string adminCatCond = (roleMode == "PrimaryAdmin") ? "mc.AdminPCNO = :PCNO"
                    : (roleMode == "SecondaryAdmin") ? "(mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))"
                    : "(mc.AdminPCNO = :PCNO OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))";

                string query = $@"
                    SELECT COUNT(*) 
                    FROM Employees e 
                    LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                    WHERE e.MasterId NOT LIKE 'GLOBAL%'
                      AND e.Status <> 'System'
                      AND e.Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred')
                      AND (
                          :IsSuper = 1
                          OR (NVL(ee.TierId, e.TierId) IS NOT NULL AND NVL(ee.TierId, e.TierId) IN (
                              SELECT t.Id 
                              FROM Tiers t
                              JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                              LEFT JOIN UserTiers ut ON t.Id = ut.TierId AND :Role = 0
                              WHERE (:Role = 4)
                                 OR (:Role = 1 AND {adminCatCond})
                                 OR (:Role = 0 AND ut.PCNO = :PCNO)
                          ))
                      )";
                object result = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), query,
                    new OracleParameter("IsSuper", (role == 4) ? 1 : 0),
                    new OracleParameter("Role", role),
                    new OracleParameter("PCNO", pcno));
                return result != null ? result.ToString() : "0";
            }
            catch
            {
                return "0";
            }
        }

        protected string GetResignedCount()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                string roleMode = Session["RoleMode"]?.ToString() ?? "";
                string adminCatCond = (roleMode == "PrimaryAdmin") ? "mc.AdminPCNO = :PCNO"
                    : (roleMode == "SecondaryAdmin") ? "(mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))"
                    : "(mc.AdminPCNO = :PCNO OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))";

                string query = $@"
                    SELECT COUNT(*) 
                    FROM   Employees e 
                    LEFT JOIN Tiers t ON e.TierId = t.Id
                    WHERE  e.MasterId NOT LIKE 'GLOBAL%'
                      AND  e.Status <> 'System'
                      AND  e.Status = 'Resigned'
                      AND  NOT EXISTS (
                          SELECT 1 
                          FROM   Employees e2
                          LEFT JOIN Tiers t2 ON e2.TierId = t2.Id
                          WHERE  e2.EmployeeHistoryId = e.EmployeeHistoryId
                            AND  (t2.MainCategoryId IS NULL OR t.MainCategoryId IS NULL OR t2.MainCategoryId = t.MainCategoryId)
                            AND  e2.Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred')
                      )
                      AND (
                          :IsSuper = 1
                          OR (e.TierId IS NOT NULL AND e.TierId IN (
                              SELECT t.Id 
                              FROM Tiers t
                              JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                              LEFT JOIN UserTiers ut ON t.Id = ut.TierId AND :Role = 0
                              WHERE (:Role = 4)
                                 OR (:Role = 1 AND {adminCatCond})
                                 OR (:Role = 0 AND ut.PCNO = :PCNO)
                          ))
                      )";
                object result = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), query,
                    new OracleParameter("IsSuper", (role == 4) ? 1 : 0),
                    new OracleParameter("Role", role),
                    new OracleParameter("PCNO", pcno));
                return result != null ? result.ToString() : "0";
            }
            catch
            {
                return "0";
            }
        }

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void ddlFilterDiv_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
            ShowMessage("Edit cancelled.", true);
        }

        private void ResetForm()
        {
            txtEmpID.Text = "";
            txtEmpName.Text = "";
            txtLeaveBalance.Text = "";
            txtJoinDate.Text = "";
            txtPhone.Text = "";
            txtEmail.Text = "";
            txtAadhar.Text = "";
            txtAddress.Text = "";
            txtQualification.Text = "";
            txtExperience.Text = "";
            txtExperienceIn.Text = "";
            hfEditOldID.Value = "";
            txtMasterID.Text = "(Auto-Generated)";
            chkIsRejoining.Checked = false;
            chkIsRejoining.Enabled = true;
            ddlRejoiningEmployee.Enabled = true;
            if (ddlRejoiningEmployee.Items.Count > 0)
            {
                ddlRejoiningEmployee.SelectedIndex = 0;
            }
            txtEmpID.Enabled = true;
            txtJoinDate.Enabled = true;
            ddlDept.Enabled = true;
            lblDeptHelp.Style["display"] = "none";
            ddlCat.Enabled = true;
            lblCatHelp.Style["display"] = "none";
            btnAddEmployee.Text = "Add Employee";
            btnCancelEdit.Visible = false;
        }

        private void PopulateDeleteEmployeeDropdown()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                string roleMode = Session["RoleMode"]?.ToString() ?? "";
                string adminCatCond = (roleMode == "PrimaryAdmin") ? "mc.AdminPCNO = :PCNO"
                    : (roleMode == "SecondaryAdmin") ? "(mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))"
                    : "(mc.AdminPCNO = :PCNO OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))";

                string query = $@"
                    SELECT MasterId, ID, Name 
                    FROM Employees 
                    WHERE :IsSuper = 1
                       OR TierId IN (
                           SELECT t.Id 
                           FROM Tiers t
                           JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                           LEFT JOIN UserTiers ut ON t.Id = ut.TierId AND :Role = 0
                           WHERE (:Role = 4)
                              OR (:Role = 1 AND {adminCatCond})
                              OR (:Role = 0 AND ut.PCNO = :PCNO)
                       )
                    ORDER BY Name ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query,
                    new OracleParameter("IsSuper", (role == 4) ? 1 : 0),
                    new OracleParameter("Role", role),
                    new OracleParameter("PCNO", pcno));
                ddlDeleteEmployee.Items.Clear();
                ddlDeleteEmployee.Items.Add(new ListItem("-- Select Employee to Delete --", ""));
                foreach (DataRow row in dt.Rows)
                {
                    string mId = row["MasterId"].ToString();
                    string id = row["ID"].ToString();
                    string name = row["Name"].ToString();
                    ddlDeleteEmployee.Items.Add(new ListItem(name + " (" + id + " - Master: " + mId + ")", mId));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating delete dropdown: " + ex.Message);
            }
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string masterId = ddlDeleteEmployee.SelectedValue;
            if (string.IsNullOrEmpty(masterId))
            {
                ShowMessage("Please select an employee to delete.", false, "deleteModal");
                return;
            }

            try
            {
                // Retrieve employee name for logging
                string nameQuery = "SELECT Name, ID FROM Employees WHERE MasterId = :MasterId";
                DataTable dtName = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), nameQuery, new OracleParameter("MasterId", masterId));
                string empName = "Unknown";
                string empId = "Unknown";
                if (dtName.Rows.Count > 0)
                {
                    empName = dtName.Rows[0]["Name"].ToString();
                    empId = dtName.Rows[0]["ID"].ToString();
                }

                // Log pre-state if logging is supported
                string preState = ActionLogger.CaptureEmployeeState(masterId);

                string delOver = "DELETE FROM CalculationOverrides WHERE EmpID = :MasterId";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delOver, new OracleParameter("MasterId", masterId));

                string delAtt = "DELETE FROM Attendance WHERE EmpID = :MasterId";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delAtt, new OracleParameter("MasterId", masterId));
                
                string nullEng = "UPDATE Employees SET CurrentEngagementId = NULL WHERE MasterId = :MasterId";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), nullEng, new OracleParameter("MasterId", masterId));

                string delEng = "DELETE FROM EmployeeEngagements WHERE EmpID = :MasterId";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delEng, new OracleParameter("MasterId", masterId));

                string delEmp = "DELETE FROM Employees WHERE MasterId = :MasterId";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delEmp, new OracleParameter("MasterId", masterId));
                
                // Log action
                ActionLogger.LogAction("DELETE", masterId, "Deleted employee " + empName + " (ID: " + empId + ")", preState, null);

                PopulateDeleteEmployeeDropdown();
                BindResignedEmployees();
                BindGrid();
                
                // Clear selected value
                ddlDeleteEmployee.SelectedIndex = 0;

                ShowMessage("Employee " + empName + " and their attendance history completely deleted.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting employee: " + ex.Message, false, "deleteModal");
            }
        }

        private void BindResignedEmployees()
        {
            try
            {
                string query = @"
                    SELECT MasterId, Name, Department, TierId, Phone, Email, Aadhar, Address, Qualification, Experience, ExperienceIn
                    FROM (
                        SELECT MasterId, Name, Department, TierId, Phone, Email, Aadhar, Address, Qualification, Experience, ExperienceIn, Status,
                               ROW_NUMBER() OVER (PARTITION BY EmployeeHistoryId ORDER BY JoinDate DESC, MasterId DESC) as rn
                        FROM Employees
                    )
                    WHERE rn = 1 
                      AND Status = 'Resigned'
                    ORDER BY Name ASC";
                
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                
                ddlRejoiningEmployee.Items.Clear();
                ddlRejoiningEmployee.Items.Add(new ListItem("-- Select Resigned Employee --", ""));
                
                var list = new List<object>();

                foreach (DataRow row in dt.Rows)
                {
                    string mId = row["MasterId"].ToString();
                    string name = row["Name"].ToString();
                    string dept = row["Department"] != DBNull.Value ? row["Department"].ToString() : "N/A";
                    string tierId = row["TierId"] != DBNull.Value ? row["TierId"].ToString() : "";
                    string phone = row["Phone"] != DBNull.Value ? row["Phone"].ToString() : "";
                    string email = row["Email"] != DBNull.Value ? row["Email"].ToString() : "";
                    string aadhar = row["Aadhar"] != DBNull.Value ? row["Aadhar"].ToString() : "";
                    string address = row["Address"] != DBNull.Value ? row["Address"].ToString() : "";
                    string qual = row["Qualification"] != DBNull.Value ? row["Qualification"].ToString() : "";
                    string exp = row["Experience"] != DBNull.Value ? row["Experience"].ToString() : "";
                    string expIn = row["ExperienceIn"] != DBNull.Value ? row["ExperienceIn"].ToString() : "";
                    
                    ddlRejoiningEmployee.Items.Add(new ListItem(mId + " - " + name + " (Ex-" + dept + ")", mId));

                    list.Add(new {
                        masterId = mId,
                        name = name,
                        dept = dept,
                        tierId = tierId,
                        phone = phone,
                        email = email,
                        aadhar = aadhar,
                        address = address,
                        qualification = qual,
                        experience = exp,
                        experienceIn = expIn
                    });
                }

                string json = new JavaScriptSerializer().Serialize(list);
                hfResignedEmployeesJson.Value = json;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading resigned employees: " + ex.Message);
            }
        }

        private string GenerateNextMasterId()
        {
            int currentNextMaster = 10001;
            try
            {
                string query = "SELECT MasterId FROM Employees WHERE MasterId IS NOT NULL ORDER BY MasterId DESC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                foreach (DataRow row in dt.Rows)
                {
                    string mId = row["MasterId"].ToString();
                    int val;
                    if (int.TryParse(mId, out val))
                    {
                        if (val >= currentNextMaster)
                        {
                            currentNextMaster = val + 1;
                        }
                    }
                }
            }
            catch { }
            return currentNextMaster.ToString();
        }

        private void AutoEnrollActiveContract(string masterId, string empId, int tierId, string department, DateTime? joinDate)
        {
            try
            {
                // Ensure department division exists in Divisions table
                DBHelper.EnsureDivisionExists(department);

                // Check if there is an active contract for this category/tier
                string activeContractSql = "SELECT Id, VendorId, StartDate FROM ContractPeriods WHERE TierId = :TierId AND Status = 'Active'";
                DataTable dtContract = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), activeContractSql, new OracleParameter("TierId", tierId));
                if (dtContract.Rows.Count > 0)
                {
                    int contractPeriodId = Convert.ToInt32(dtContract.Rows[0]["Id"]);
                    int vendorId = Convert.ToInt32(dtContract.Rows[0]["VendorId"]);
                    DateTime cpStartDate = Convert.ToDateTime(dtContract.Rows[0]["StartDate"]);

                    // Validate VendorId exists in Vendors table
                    int validVendorId = 0;
                    if (vendorId > 0)
                    {
                        string checkVendor = "SELECT COUNT(*) FROM Vendors WHERE Id = :Id";
                        if (Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkVendor, new OracleParameter("Id", vendorId))) > 0)
                        {
                            validVendorId = vendorId;
                        }
                    }

                    if (validVendorId == 0)
                    {
                        // Fallback to any active vendor in Vendors table
                        string fallbackVendorSql = "SELECT Id FROM Vendors WHERE ROWNUM = 1 ORDER BY IsActive DESC, Id ASC";
                        object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), fallbackVendorSql);
                        if (res != null && res != DBNull.Value)
                        {
                            validVendorId = Convert.ToInt32(res);
                        }
                    }

                    if (validVendorId == 0)
                    {
                        // Cannot auto-enroll without a valid vendor in Vendors table
                        return;
                    }

                    // Validate ContractPeriodId exists in ContractPeriods table
                    int? validContractPeriodId = null;
                    if (contractPeriodId > 0)
                    {
                        string checkCP = "SELECT COUNT(*) FROM ContractPeriods WHERE Id = :Id";
                        if (Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkCP, new OracleParameter("Id", contractPeriodId))) > 0)
                        {
                            validContractPeriodId = contractPeriodId;
                        }
                    }

                    // Validate TierId exists in Tiers table
                    string checkTier = "SELECT COUNT(*) FROM Tiers WHERE Id = :Id";
                    if (Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkTier, new OracleParameter("Id", tierId))) == 0)
                    {
                        return;
                    }

                    DateTime parsedJoinDate = joinDate ?? DateTime.Today;
                    if (parsedJoinDate < cpStartDate)
                    {
                        parsedJoinDate = cpStartDate;
                    }

                    using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                    {
                        conn.Open();
                        using (OracleTransaction trans = conn.BeginTransaction())
                        {
                            try
                            {
                                // 1. Insert new engagement
                                string insertEngSql = @"
                                    INSERT INTO EmployeeEngagements (EmpID, ContractPeriodId, TierId, VendorId, Department, StartDate, EmployeeId) 
                                    VALUES (:EmpID, :ContractPeriodId, :TierId, :VendorId, :Department, :StartDate, :EmployeeId)
                                    RETURNING Id INTO :NewEngagementId";

                                int newEngagementId = 0;
                                using (OracleCommand cmd = new OracleCommand(insertEngSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.BindByName = true;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", masterId));
                                    cmd.Parameters.Add(new OracleParameter("ContractPeriodId", validContractPeriodId.HasValue ? (object)validContractPeriodId.Value : DBNull.Value));
                                    cmd.Parameters.Add(new OracleParameter("TierId", tierId));
                                    cmd.Parameters.Add(new OracleParameter("VendorId", validVendorId));
                                    cmd.Parameters.Add(new OracleParameter("Department", string.IsNullOrEmpty(department) ? (object)DBNull.Value : department));
                                    cmd.Parameters.Add(new OracleParameter("StartDate", parsedJoinDate));
                                    cmd.Parameters.Add(new OracleParameter("EmployeeId", empId));

                                    OracleParameter outParam = new OracleParameter("NewEngagementId", OracleDbType.Int32);
                                    outParam.Direction = ParameterDirection.Output;
                                    cmd.Parameters.Add(outParam);

                                    cmd.ExecuteNonQuery();
                                    newEngagementId = Convert.ToInt32(outParam.Value.ToString());
                                }

                                // 2. Update Employee Master to Active and link the engagement
                                string updateEmpSql = @"
                                    UPDATE Employees 
                                    SET CurrentEngagementId = :CurrentEngagementId, 
                                        JoinDate = NVL(JoinDate, :JoinDate),
                                        OriginalJoinDate = NVL(OriginalJoinDate, :JoinDate),
                                        Status = 'Active' 
                                    WHERE MasterId = :MasterId";
                                using (OracleCommand cmd = new OracleCommand(updateEmpSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.BindByName = true;
                                    cmd.Parameters.Add(new OracleParameter("CurrentEngagementId", newEngagementId));
                                    cmd.Parameters.Add(new OracleParameter("JoinDate", parsedJoinDate));
                                    cmd.Parameters.Add(new OracleParameter("MasterId", masterId));
                                    cmd.ExecuteNonQuery();
                                }

                                trans.Commit();
                            }
                            catch (Exception ex)
                            {
                                trans.Rollback();
                                throw ex;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error auto-enrolling employee: " + ex.Message);
            }
        }

        protected void gvEmployees_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            // Empty handler to allow GridView to fire RowCommand without error for CommandName="Delete" if used.
            // Actual delete logic will be in RowCommand.
        }

        protected void gvEmployees_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField hfStatus = (HiddenField)e.Row.FindControl("hfStatus");
                DropDownList ddlStatus = (DropDownList)e.Row.FindControl("ddlStatus");
                
                if (hfStatus != null && ddlStatus != null)
                {
                    ddlStatus.SelectedValue = hfStatus.Value;

                    foreach (ListItem item in ddlStatus.Items)
                    {
                        if (item.Value == "Active" && (hfStatus.Value == "Resigned" || hfStatus.Value == "ContractEnded"))
                        {
                            item.Enabled = false;
                        }
                        else if (item.Value == "ContractEnded" && hfStatus.Value != "ContractEnded")
                        {
                            item.Enabled = false;
                        }
                        else if ((item.Value == "Upgraded" || item.Value == "Downgraded" || item.Value == "Transferred") && hfStatus.Value == "Resigned")
                        {
                            item.Enabled = false;
                        }
                    }

                    if (hfStatus.Value == "Resigned")
                    {
                        e.Row.CssClass = "resigned-row strike";
                        ddlStatus.CssClass = "form-select form-select-sm status-badge badge-resigned";
                    }
                    else if (hfStatus.Value == "Upgraded")
                    {
                        ddlStatus.CssClass = "form-select form-select-sm status-badge badge-upgraded";
                    }
                    else if (hfStatus.Value == "Downgraded")
                    {
                        ddlStatus.CssClass = "form-select form-select-sm status-badge badge-downgraded";
                    }
                    else if (hfStatus.Value == "ContractEnded")
                    {
                        ddlStatus.CssClass = "form-select form-select-sm status-badge badge-contractended";
                    }
                    else if (hfStatus.Value == "Transferred")
                    {
                        ddlStatus.CssClass = "form-select form-select-sm status-badge badge-transferred";
                    }
                    else
                    {
                        ddlStatus.CssClass = "form-select form-select-sm status-badge badge-active";
                    }
                }

                // ── Data attributes for client-side advanced filtering ────────────
                DataRowView drv = e.Row.DataItem as DataRowView;
                if (drv != null)
                {
                    // Join date in sortable ISO format (yyyy-MM-dd)
                    string jd = "";
                    if (drv.Row.Table.Columns.Contains("JoinDate") && drv["JoinDate"] != DBNull.Value)
                        jd = Convert.ToDateTime(drv["JoinDate"]).ToString("yyyy-MM-dd");
                    e.Row.Attributes["data-joindate"] = jd;

                    // Experience in years (numeric string, empty if null)
                    string exp = "";
                    if (drv.Row.Table.Columns.Contains("Experience") && drv["Experience"] != DBNull.Value)
                        exp = drv["Experience"].ToString();
                    e.Row.Attributes["data-experience"] = exp;

                    // Experience In — lowercased for easy contains-match in JS
                    string expIn = "";
                    if (drv.Row.Table.Columns.Contains("ExperienceIn") && drv["ExperienceIn"] != DBNull.Value)
                        expIn = drv["ExperienceIn"].ToString();
                    e.Row.Attributes["data-experiencein"] = expIn;

                    // Qualification — lowercased for easy contains-match in JS
                    string qual = "";
                    if (drv.Row.Table.Columns.Contains("Qualification") && drv["Qualification"] != DBNull.Value)
                        qual = drv["Qualification"].ToString();
                    e.Row.Attributes["data-qualification"] = qual;
                }
                // ─────────────────────────────────────────────────────────────────
            }
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl = (DropDownList)sender;
            GridViewRow row = (GridViewRow)ddl.NamingContainer;
            HiddenField hfEmpID = (HiddenField)row.FindControl("hfEmpID");
            HiddenField hfResignDate = (HiddenField)row.FindControl("hfResignDate");
 
            string id = hfEmpID.Value;
            string status = ddl.SelectedValue;

            // Capture pre-state
            string preState = ActionLogger.CaptureEmployeeState(id);

            // Check if the employee is currently resigned in the database
            string currentStatus = "";
            string queryCurrentStatus = "SELECT Status FROM Employees WHERE MasterId = :MasterId";
            DataTable dtStatus = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryCurrentStatus, new OracleParameter("MasterId", id));
            if (dtStatus.Rows.Count > 0)
            {
                currentStatus = dtStatus.Rows[0]["Status"].ToString();
            }

            if (currentStatus == "Resigned" && (status == "Upgraded" || status == "Downgraded" || status == "Transferred"))
            {
                ShowMessage("A resigned employee cannot be upgraded, downgraded, or transferred. They must rejoin first.", false);
                BindGrid();
                return;
            }
 
            if (status == "Active" || status == "ContractEnded")
            {
                bool isTransitioned = false;
                if (preState != null)
                {
                    isTransitioned = preState.IndexOf("\"STATUS\":\"Upgraded\"", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                     preState.IndexOf("\"STATUS\":\"Downgraded\"", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                     preState.IndexOf("\"STATUS\":\"Transferred\"", StringComparison.OrdinalIgnoreCase) >= 0;
                }

                if (status == "Active" && isTransitioned)
                {
                    // Allow manual reset to Active for transitioned employees
                }
                else
                {
                    ShowMessage("Status cannot be manually set to Active or Contract Ended.", false);
                    BindGrid();
                    return;
                }
            }

            if (status == "Upgraded" || status == "Downgraded")
            {
                string newCategory = hfChangeCategory.Value;
                string changeDateStr = hfChangeDate.Value;
                string newEmpId = hfChangeEmpId.Value.Trim();

                if (string.IsNullOrEmpty(newCategory) || string.IsNullOrEmpty(changeDateStr) || string.IsNullOrEmpty(newEmpId))
                {
                    ShowMessage("Category change parameters or New Employee ID are missing. Transition cancelled.", false);
                    BindGrid();
                    return;
                }

                DateTime changeDate;
                if (!DateTime.TryParse(changeDateStr, out changeDate))
                {
                    ShowMessage("Invalid change date: " + changeDateStr, false);
                    BindGrid();
                    return;
                }

                string pcno = Session["PCNO"]?.ToString() ?? "";
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                int newTierId = ResolveTierId(newCategory, "0", pcno, role);

                DateTime endDateForOldEngagement = changeDate.AddDays(-1);

                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // Validate that the new Employee ID is unique within the target category/tier
                            string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = :ID AND TierId = :TierId AND Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred') AND MasterId != :MasterId";
                            using (OracleCommand cmd = new OracleCommand(qCheck, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("ID", newEmpId));
                                cmd.Parameters.Add(new OracleParameter("TierId", newTierId));
                                cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                int count = Convert.ToInt32(cmd.ExecuteScalar());
                                if (count > 0)
                                {
                                    throw new Exception("New Employee ID '" + newEmpId + "' is already present in target category.");
                                }
                            }

                            // 1. Fetch employee details
                            string empDetailsSql = @"
                                SELECT e.Department, 
                                       (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category,
                                       e.CurrentEngagementId, ee.StartDate AS CurrentEngStartDate, ee.VendorId 
                                FROM   Employees e 
                                LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id 
                                WHERE  e.MasterId = :MasterId";
                            string empDept = "GENERAL";
                            string oldCategory = "";
                            int? oldEngagementId = null;
                            DateTime? currentEngStartDate = null;
                            int? oldVendorId = null;

                            using (OracleCommand cmd = new OracleCommand(empDetailsSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                using (OracleDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        empDept = reader["Department"] != DBNull.Value ? reader["Department"].ToString() : "GENERAL";
                                        oldCategory = reader["Category"]?.ToString();
                                        if (reader["CurrentEngagementId"] != DBNull.Value)
                                        {
                                            oldEngagementId = Convert.ToInt32(reader["CurrentEngagementId"]);
                                        }
                                        if (reader["CurrentEngStartDate"] != DBNull.Value)
                                        {
                                            currentEngStartDate = Convert.ToDateTime(reader["CurrentEngStartDate"]);
                                        }
                                        if (reader["VendorId"] != DBNull.Value)
                                        {
                                            oldVendorId = Convert.ToInt32(reader["VendorId"]);
                                        }
                                    }
                                    else
                                    {
                                        throw new Exception("Employee record not found.");
                                    }
                                }
                            }

                             // Fallback: If no current active engagement (e.g. contract ended), query the last closed engagement
                             if (!oldEngagementId.HasValue)
                             {
                                 string lastEngSql = @"
                                     SELECT Id, StartDate, VendorId FROM (
                                         SELECT Id, StartDate, VendorId FROM EmployeeEngagements 
                                         WHERE EmpID = :MasterId 
                                         ORDER BY StartDate DESC, Id DESC
                                     ) WHERE ROWNUM = 1";
                                 using (OracleCommand cmd = new OracleCommand(lastEngSql, conn))
                                 {
                                     cmd.Transaction = trans;
                                     cmd.BindByName = true;
                                     cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                     using (OracleDataReader reader = cmd.ExecuteReader())
                                     {
                                         if (reader.Read())
                                         {
                                             oldEngagementId = Convert.ToInt32(reader["Id"]);
                                             currentEngStartDate = Convert.ToDateTime(reader["StartDate"]);
                                             if (reader["VendorId"] != DBNull.Value)
                                             {
                                                 oldVendorId = Convert.ToInt32(reader["VendorId"]);
                                             }
                                         }
                                     }
                                 }
                             }

                            // Validate transition date
                            if (currentEngStartDate.HasValue && changeDate <= currentEngStartDate.Value)
                            {
                                throw new Exception("Transition date (" + changeDate.ToString("yyyy-MM-dd") + ") must be after the current engagement start date (" + currentEngStartDate.Value.ToString("yyyy-MM-dd") + ").");
                            }

                            // 2. Fetch the active contract period for the new category/tier
                            string contractSql = "SELECT Id, VendorId, StartDate FROM ContractPeriods WHERE TierId = :TierId AND Status = 'Active'";
                            int? newPeriodId = null;
                            int? newVendorId = null;
                            DateTime? cpStartDate = null;
                            string finalStatus = "Active";

                            using (OracleCommand cmd = new OracleCommand(contractSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("TierId", newTierId));
                                using (OracleDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        newPeriodId = Convert.ToInt32(reader["Id"]);
                                        newVendorId = Convert.ToInt32(reader["VendorId"]);
                                        if (reader["StartDate"] != DBNull.Value)
                                        {
                                            cpStartDate = Convert.ToDateTime(reader["StartDate"]);
                                        }
                                    }
                                    else
                                    {
                                        if (oldVendorId.HasValue)
                                        {
                                            newPeriodId = null;
                                            newVendorId = oldVendorId.Value;
                                            finalStatus = "ContractEnded";
                                        }
                                    }
                                }
                            }

                            // Validate / Resolve newVendorId (must exist in Vendors table)
                            int validVendorId = 0;
                            if (newVendorId.HasValue && newVendorId.Value > 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT COUNT(*) FROM Vendors WHERE Id = :Id", conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", newVendorId.Value));
                                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                                    {
                                        validVendorId = newVendorId.Value;
                                    }
                                }
                            }

                            if (validVendorId == 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT Id FROM Vendors WHERE ROWNUM = 1 ORDER BY IsActive DESC, Id ASC", conn))
                                {
                                    cmd.Transaction = trans;
                                    object res = cmd.ExecuteScalar();
                                    if (res != null && res != DBNull.Value)
                                    {
                                        validVendorId = Convert.ToInt32(res);
                                    }
                                }
                            }

                            if (validVendorId == 0)
                            {
                                throw new Exception("Transition failed: No active vendor exists in system. Please configure a vendor under Settings first.");
                            }

                            // Validate newPeriodId
                            int? validPeriodId = null;
                            if (newPeriodId.HasValue && newPeriodId.Value > 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT COUNT(*) FROM ContractPeriods WHERE Id = :Id", conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", newPeriodId.Value));
                                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                                    {
                                        validPeriodId = newPeriodId.Value;
                                    }
                                }
                            }

                            // Validate prev engagement ID
                            int? validPrevEngId = null;
                            if (oldEngagementId.HasValue && oldEngagementId.Value > 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT COUNT(*) FROM EmployeeEngagements WHERE Id = :Id", conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", oldEngagementId.Value));
                                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                                    {
                                        validPrevEngId = oldEngagementId.Value;
                                    }
                                }
                            }

                            DateTime targetEngStartDate = changeDate;
                            if (cpStartDate.HasValue && changeDate < cpStartDate.Value)
                            {
                                targetEngStartDate = cpStartDate.Value;
                            }

                            // 3. Close the previous active engagement
                            if (validPrevEngId.HasValue)
                            {
                                string closeOldEngSql = @"
                                    UPDATE EmployeeEngagements 
                                    SET EndDate = :EndDate, EndReason = :EndReason 
                                    WHERE Id = :OldEngagementId AND EndDate IS NULL";
                                
                                using (OracleCommand cmd = new OracleCommand(closeOldEngSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.BindByName = true;
                                    cmd.Parameters.Add(new OracleParameter("EndDate", endDateForOldEngagement));
                                    cmd.Parameters.Add(new OracleParameter("EndReason", status));
                                    cmd.Parameters.Add(new OracleParameter("OldEngagementId", validPrevEngId.Value));
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // 4. Insert the new engagement
                            string insertEngSql = @"
                                INSERT INTO EmployeeEngagements (EmpID, ContractPeriodId, TierId, VendorId, Department, StartDate, IsCarriedOver, PrevEngagementId, EmployeeId) 
                                VALUES (:EmpID, :ContractPeriodId, :TierId, :VendorId, :Department, :StartDate, 1, :PrevEngagementId, :EmployeeId)
                                RETURNING Id INTO :NewEngagementId";
                            
                            int newEngagementId = 0;
                            using (OracleCommand cmd = new OracleCommand(insertEngSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("EmpID", id));
                                cmd.Parameters.Add(new OracleParameter("ContractPeriodId", validPeriodId.HasValue ? (object)validPeriodId.Value : DBNull.Value));
                                cmd.Parameters.Add(new OracleParameter("TierId", newTierId));
                                cmd.Parameters.Add(new OracleParameter("VendorId", validVendorId));
                                cmd.Parameters.Add(new OracleParameter("Department", empDept));
                                cmd.Parameters.Add(new OracleParameter("StartDate", targetEngStartDate));
                                cmd.Parameters.Add(new OracleParameter("PrevEngagementId", validPrevEngId.HasValue ? (object)validPrevEngId.Value : DBNull.Value));
                                cmd.Parameters.Add(new OracleParameter("EmployeeId", newEmpId));

                                OracleParameter outParam = new OracleParameter("NewEngagementId", OracleDbType.Int32);
                                outParam.Direction = ParameterDirection.Output;
                                cmd.Parameters.Add(outParam);

                                cmd.ExecuteNonQuery();
                                newEngagementId = Convert.ToInt32(outParam.Value.ToString());
                            }

                            // 5. Update the master record in Employees
                            string updateEmpSql = @"
                                UPDATE Employees 
                                SET ID = :NewEmpID,
                                    CurrentEngagementId = :CurrentEngagementId, 
                                    TierId = :TierId, 
                                    Status = :Status,
                                    ResignDate = NULL,
                                    ContractEndDate = NULL 
                                WHERE MasterId = :MasterId";
                            
                            using (OracleCommand cmd = new OracleCommand(updateEmpSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("NewEmpID", newEmpId));
                                cmd.Parameters.Add(new OracleParameter("CurrentEngagementId", newEngagementId));
                                cmd.Parameters.Add(new OracleParameter("TierId", newTierId));
                                cmd.Parameters.Add(new OracleParameter("Status", finalStatus));
                                cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                cmd.ExecuteNonQuery();
                            }
 
                            trans.Commit();

                             // Capture post-state and log the status change
                             try
                             {
                                 string postState = ActionLogger.CaptureEmployeeState(id);
                                 string actType = status.ToUpper();
                                 string desc = status + " employee to category " + newCategory + " (New ID: " + newEmpId + ")";
                                 ActionLogger.LogAction(actType, id, desc, preState, postState);
                             }
                             catch (Exception exLog)
                             {
                                 System.Diagnostics.Debug.WriteLine("Error logging status change: " + exLog.Message);
                             }

                            ShowMessage("Employee status successfully changed to " + status + ". Category transitioned from " + oldCategory + " to " + newCategory + " and vendor reassigned.", true);
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            if (ex.Message.Contains("already present") || ex.Message.Contains("Transition date") || ex.Message.Contains("configured"))
                            {
                                ShowMessage(ex.Message, false);
                            }
                            else
                            {
                                ShowMessage("Database error during status change: " + ex.Message, false);
                            }
                        }
                    }
                }
            }
            else if (status == "Transferred")
            {
                string newDivision = hfChangeDivision.Value;
                string changeDateStr = hfChangeDate.Value;

                if (string.IsNullOrEmpty(newDivision) || string.IsNullOrEmpty(changeDateStr))
                {
                    ShowMessage("Directorate change parameters are missing. Transfer cancelled.", false);
                    BindResignedEmployees();
                    BindGrid();
                    return;
                }

                // Ensure new division exists in Divisions table to satisfy foreign key constraint
                DBHelper.EnsureDivisionExists(newDivision);

                DateTime changeDate;
                if (!DateTime.TryParse(changeDateStr, out changeDate))
                {
                    ShowMessage("Invalid change date: " + changeDateStr, false);
                    BindResignedEmployees();
                    BindGrid();
                    return;
                }

                DateTime endDateForOldEngagement = changeDate.AddDays(-1);

                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Fetch employee details
                            string empDetailsSql = @"
                                 SELECT e.ID, e.Name, e.Department, e.TierId,
                                        (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category, 
                                        e.CurrentEngagementId, ee.StartDate AS CurrentEngStartDate,
                                        ee.ContractPeriodId, ee.VendorId 
                                 FROM   Employees e 
                                 LEFT JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id 
                                 WHERE  e.MasterId = :MasterId";
                            
                            string empId = "";
                            string empName = "";
                            string oldDivision = "";
                            string empCategory = "";
                            int tierId = 0;
                            int? oldEngagementId = null;
                            DateTime? currentEngStartDate = null;
                            int? contractPeriodId = null;
                            int? vendorId = null;

                            using (OracleCommand cmd = new OracleCommand(empDetailsSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                using (OracleDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        empId = reader["ID"].ToString();
                                        empName = reader["Name"].ToString();
                                        oldDivision = reader["Department"] != DBNull.Value ? reader["Department"].ToString() : "";
                                        empCategory = reader["Category"].ToString();
                                        tierId = Convert.ToInt32(reader["TierId"]);
                                        if (reader["CurrentEngagementId"] != DBNull.Value)
                                        {
                                            oldEngagementId = Convert.ToInt32(reader["CurrentEngagementId"]);
                                        }
                                        if (reader["CurrentEngStartDate"] != DBNull.Value)
                                        {
                                            currentEngStartDate = Convert.ToDateTime(reader["CurrentEngStartDate"]);
                                        }
                                        if (reader["ContractPeriodId"] != DBNull.Value)
                                        {
                                            contractPeriodId = Convert.ToInt32(reader["ContractPeriodId"]);
                                        }
                                        if (reader["VendorId"] != DBNull.Value)
                                        {
                                            vendorId = Convert.ToInt32(reader["VendorId"]);
                                        }
                                    }
                                    else
                                    {
                                        throw new Exception("Employee record not found.");
                                    }
                                }
                            }

                            // Ensure old division also exists in Divisions table if present
                            if (!string.IsNullOrEmpty(oldDivision))
                            {
                                DBHelper.EnsureDivisionExists(oldDivision);
                            }

                            // Validate transition date
                            if (currentEngStartDate.HasValue && changeDate <= currentEngStartDate.Value)
                            {
                                throw new Exception("Transfer date (" + changeDate.ToString("yyyy-MM-dd") + ") must be after the current engagement start date (" + currentEngStartDate.Value.ToString("yyyy-MM-dd") + ").");
                            }

                            if (!oldEngagementId.HasValue)
                            {
                                string lastEngSql = @"
                                    SELECT Id, StartDate, ContractPeriodId, VendorId FROM (
                                        SELECT Id, StartDate, ContractPeriodId, VendorId FROM EmployeeEngagements 
                                        WHERE EmpID = :MasterId 
                                        ORDER BY StartDate DESC, Id DESC
                                    ) WHERE ROWNUM = 1";
                                using (OracleCommand cmd = new OracleCommand(lastEngSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.BindByName = true;
                                    cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                    using (OracleDataReader reader = cmd.ExecuteReader())
                                    {
                                        if (reader.Read())
                                        {
                                            oldEngagementId = Convert.ToInt32(reader["Id"]);
                                            if (!currentEngStartDate.HasValue && reader["StartDate"] != DBNull.Value)
                                            {
                                                currentEngStartDate = Convert.ToDateTime(reader["StartDate"]);
                                            }
                                            if (!contractPeriodId.HasValue && reader["ContractPeriodId"] != DBNull.Value)
                                            {
                                                contractPeriodId = Convert.ToInt32(reader["ContractPeriodId"]);
                                            }
                                            if (!vendorId.HasValue && reader["VendorId"] != DBNull.Value)
                                            {
                                                vendorId = Convert.ToInt32(reader["VendorId"]);
                                            }
                                        }
                                    }
                                }
                            }

                            // Validate / Resolve VendorId (must exist in Vendors table)
                            int validVendorId = 0;
                            Func<int, bool> checkVendorExists = (vId) =>
                            {
                                if (vId <= 0) return false;
                                using (OracleCommand vCmd = new OracleCommand("SELECT COUNT(*) FROM Vendors WHERE Id = :Id", conn))
                                {
                                    vCmd.Transaction = trans;
                                    vCmd.Parameters.Add(new OracleParameter("Id", vId));
                                    return Convert.ToInt32(vCmd.ExecuteScalar()) > 0;
                                }
                            };

                            if (vendorId.HasValue && checkVendorExists(vendorId.Value))
                            {
                                validVendorId = vendorId.Value;
                            }

                            if (validVendorId == 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT VendorId, Id FROM ContractPeriods WHERE TierId = :TierId AND Status = 'Active'", conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("TierId", tierId));
                                    using (OracleDataReader cpReader = cmd.ExecuteReader())
                                    {
                                        if (cpReader.Read())
                                        {
                                            int cpVendor = Convert.ToInt32(cpReader["VendorId"]);
                                            if (checkVendorExists(cpVendor))
                                            {
                                                validVendorId = cpVendor;
                                                if (!contractPeriodId.HasValue) contractPeriodId = Convert.ToInt32(cpReader["Id"]);
                                            }
                                        }
                                    }
                                }
                            }

                            if (validVendorId == 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT Id FROM Vendors ORDER BY IsActive DESC, Id ASC", conn))
                                {
                                    cmd.Transaction = trans;
                                    using (OracleDataReader vReader = cmd.ExecuteReader())
                                    {
                                        while (vReader.Read())
                                        {
                                            int candidateId = Convert.ToInt32(vReader["Id"]);
                                            if (checkVendorExists(candidateId))
                                            {
                                                validVendorId = candidateId;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }

                            if (validVendorId == 0)
                            {
                                throw new Exception("Transfer failed: No active vendor exists in system database. Please configure a vendor under Settings first.");
                            }

                            // Validate contractPeriodId
                            int? validContractPeriodId = null;
                            if (contractPeriodId.HasValue && contractPeriodId.Value > 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT COUNT(*) FROM ContractPeriods WHERE Id = :Id", conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", contractPeriodId.Value));
                                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                                    {
                                        validContractPeriodId = contractPeriodId.Value;
                                    }
                                }
                            }

                            // Validate prev engagement ID
                            int? validPrevEngId = null;
                            if (oldEngagementId.HasValue && oldEngagementId.Value > 0)
                            {
                                using (OracleCommand cmd = new OracleCommand("SELECT COUNT(*) FROM EmployeeEngagements WHERE Id = :Id", conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", oldEngagementId.Value));
                                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                                    {
                                        validPrevEngId = oldEngagementId.Value;
                                    }
                                }
                            }

                            DateTime? cpStartDate = null;
                            if (validContractPeriodId.HasValue)
                            {
                                string cpSql = "SELECT StartDate FROM ContractPeriods WHERE Id = :Id";
                                using (OracleCommand cmd = new OracleCommand(cpSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", validContractPeriodId.Value));
                                    object res = cmd.ExecuteScalar();
                                    if (res != null && res != DBNull.Value)
                                    {
                                        cpStartDate = Convert.ToDateTime(res);
                                    }
                                }
                            }
                            DateTime targetEngStartDate = changeDate;
                            if (cpStartDate.HasValue && changeDate < cpStartDate.Value)
                            {
                                targetEngStartDate = cpStartDate.Value;
                            }
 
                            // 2. Close the previous active engagement
                            if (validPrevEngId.HasValue)
                            {
                                string closeOldEngSql = @"
                                    UPDATE EmployeeEngagements 
                                    SET EndDate = :EndDate, EndReason = 'Transferred' 
                                    WHERE Id = :OldEngagementId AND EndDate IS NULL";
                                
                                using (OracleCommand cmd = new OracleCommand(closeOldEngSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.BindByName = true;
                                    cmd.Parameters.Add(new OracleParameter("EndDate", endDateForOldEngagement));
                                    cmd.Parameters.Add(new OracleParameter("OldEngagementId", validPrevEngId.Value));
                                    cmd.ExecuteNonQuery();
                                }
                            }
 
                            // 3. Insert the new engagement in the new department/division
                            string insertEngSql = @"
                                INSERT INTO EmployeeEngagements (EmpID, ContractPeriodId, TierId, VendorId, Department, StartDate, IsCarriedOver, PrevEngagementId, EmployeeId) 
                                VALUES (:EmpID, :ContractPeriodId, :TierId, :VendorId, :Department, :StartDate, 1, :PrevEngagementId, :EmployeeId)
                                RETURNING Id INTO :NewEngagementId";
                            
                            int newEngagementId = 0;
                            using (OracleCommand cmd = new OracleCommand(insertEngSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("EmpID", id));
                                cmd.Parameters.Add(new OracleParameter("ContractPeriodId", validContractPeriodId.HasValue ? (object)validContractPeriodId.Value : DBNull.Value));
                                cmd.Parameters.Add(new OracleParameter("TierId", tierId));
                                cmd.Parameters.Add(new OracleParameter("VendorId", validVendorId));
                                cmd.Parameters.Add(new OracleParameter("Department", newDivision));
                                cmd.Parameters.Add(new OracleParameter("StartDate", targetEngStartDate));
                                cmd.Parameters.Add(new OracleParameter("PrevEngagementId", validPrevEngId.HasValue ? (object)validPrevEngId.Value : DBNull.Value));
                                cmd.Parameters.Add(new OracleParameter("EmployeeId", empId));

                                OracleParameter outParam = new OracleParameter("NewEngagementId", OracleDbType.Int32);
                                outParam.Direction = ParameterDirection.Output;
                                cmd.Parameters.Add(outParam);

                                cmd.ExecuteNonQuery();
                                newEngagementId = Convert.ToInt32(outParam.Value.ToString());
                            }

                            // 4. Update the master record in Employees
                            string updateEmpSql = @"
                                UPDATE Employees 
                                SET Department = :Dept,
                                    CurrentEngagementId = :CurrentEngagementId,
                                    Status = 'Active',
                                    ResignDate = NULL,
                                    ContractEndDate = NULL 
                                WHERE MasterId = :MasterId";
                            
                            using (OracleCommand cmd = new OracleCommand(updateEmpSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("Dept", newDivision));
                                cmd.Parameters.Add(new OracleParameter("CurrentEngagementId", newEngagementId));
                                cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();

                             // Capture post-state and log the division transfer
                             try
                             {
                                 string postState = ActionLogger.CaptureEmployeeState(id);
                                 string desc = "Transferred employee directorate to " + newDivision;
                                 ActionLogger.LogAction("TRANSFER", id, desc, preState, postState);
                             }
                             catch (Exception exLog)
                             {
                                 System.Diagnostics.Debug.WriteLine("Error logging directorate transfer: " + exLog.Message);
                             }

                            ShowMessage("Employee directorate successfully changed to " + newDivision + " and recorded in history.", true);
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            ShowMessage("Error performing transfer: " + ex.Message, false);
                        }
                    }
                }
            }
            else
            {
                // Active, Resigned or ContractEnded
                string resignDateQuery = status == "Resigned" ? ", ResignDate = :ResignDate, ContractEndDate = NULL" : ", ResignDate = NULL, ContractEndDate = NULL";
                object dbDate = DBNull.Value;
                DateTime changeDate = DateTime.Now;
                if (status == "Resigned")
                {
                    DateTime dt;
                    if (DateTime.TryParse(hfResignDate.Value, out dt))
                    {
                        dbDate = dt;
                        changeDate = dt;
                    }
                    else
                    {
                        dbDate = DateTime.Now;
                        changeDate = DateTime.Now;
                    }
                }
                else if (status == "ContractEnded")
                {
                    changeDate = DateTime.Today;
                }

                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            if (status == "Resigned" || status == "ContractEnded")
                            {
                                string getEngSql = "SELECT CurrentEngagementId FROM Employees WHERE MasterId = :MasterId";
                                int? currentEngId = null;
                                using (OracleCommand cmd = new OracleCommand(getEngSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                    object res = cmd.ExecuteScalar();
                                    if (res != null && res != DBNull.Value)
                                    {
                                        currentEngId = Convert.ToInt32(res);
                                    }
                                }

                                if (currentEngId.HasValue)
                                {
                                    string closeSql = @"
                                        UPDATE EmployeeEngagements 
                                        SET EndDate = :EndDate, EndReason = :EndReason 
                                        WHERE Id = :EngagementId AND EndDate IS NULL";
                                    using (OracleCommand cmd = new OracleCommand(closeSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.BindByName = true;
                                        cmd.Parameters.Add(new OracleParameter("EndDate", changeDate));
                                        cmd.Parameters.Add(new OracleParameter("EndReason", status));
                                        cmd.Parameters.Add(new OracleParameter("EngagementId", currentEngId.Value));
                                        cmd.ExecuteNonQuery();
                                    }

                                    string clearEngSql = "UPDATE Employees SET CurrentEngagementId = NULL WHERE MasterId = :MasterId";
                                    using (OracleCommand cmd = new OracleCommand(clearEngSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            string updateSql = "UPDATE Employees SET Status = :Status " + resignDateQuery + " WHERE MasterId = :MasterId";
                            using (OracleCommand cmd = new OracleCommand(updateSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("Status", status));
                                cmd.Parameters.Add(new OracleParameter("ResignDate", dbDate));
                                cmd.Parameters.Add(new OracleParameter("MasterId", id));
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();

                             // Capture post-state and log status update
                             try
                             {
                                 string postState = ActionLogger.CaptureEmployeeState(id);
                                 string actType = status.ToUpper();
                                 string desc = "Changed employee status to " + status;
                                 ActionLogger.LogAction(actType, id, desc, preState, postState);
                             }
                             catch (Exception exLog)
                             {
                                 System.Diagnostics.Debug.WriteLine("Error logging status change: " + exLog.Message);
                             }

                            ShowMessage("Employee status successfully updated to " + status + ".", true);
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            ShowMessage("Error updating employee status: " + ex.Message, false);
                        }
                    }
                }
            }
 
            BindResignedEmployees();
            BindGrid();
        }

        protected void gvEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditEmp")
            {
                string masterId = e.CommandArgument.ToString();
                string query = "SELECT * FROM Employees WHERE MasterId = :MasterId";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("MasterId", masterId));
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    hfEditOldID.Value = dr["MasterId"].ToString();
                    txtEmpID.Text = dr["ID"].ToString();
                    txtEmpID.Enabled = false;
                    txtJoinDate.Enabled = false;
                    txtEmpName.Text = dr["Name"].ToString();
                    txtMasterID.Text = dr["MasterId"]?.ToString() ?? "";
                    
                    chkIsRejoining.Checked = false;
                    chkIsRejoining.Enabled = false;
                    ddlRejoiningEmployee.Enabled = false;

                    string deptValue = dr["Department"].ToString();
                    if (ddlDept.Items.FindByValue(deptValue) != null)
                    {
                        ddlDept.SelectedValue = deptValue;
                    }
                    else
                    {
                        ddlDept.Items.Add(new ListItem(deptValue, deptValue));
                        ddlDept.SelectedValue = deptValue;
                    }

                    bool hasActiveEng = dr["CurrentEngagementId"] != DBNull.Value;
                    ddlDept.Enabled = !hasActiveEng;
                    lblDeptHelp.Style["display"] = hasActiveEng ? "block" : "none";
                    ddlCat.Enabled = !hasActiveEng;
                    lblCatHelp.Style["display"] = hasActiveEng ? "block" : "none";

                    string catValue = dr["TierId"].ToString();
                    if (ddlCat.Items.FindByValue(catValue) != null)
                    {
                        ddlCat.SelectedValue = catValue;
                    }
                    else
                    {
                        ddlCat.Items.Add(new ListItem(catValue, catValue));
                        ddlCat.SelectedValue = catValue;
                    }

                    object oJoinDate = dr["OriginalJoinDate"] != DBNull.Value ? dr["OriginalJoinDate"] : dr["JoinDate"];
                    txtJoinDate.Text = oJoinDate != DBNull.Value ? Convert.ToDateTime(oJoinDate).ToString("yyyy-MM-dd") : "";
                    txtLeaveBalance.Text = dr["LeaveBalance"].ToString();
                    txtPhone.Text = dr["Phone"] != DBNull.Value ? dr["Phone"].ToString() : "";
                    txtEmail.Text = dr["Email"] != DBNull.Value ? dr["Email"].ToString() : "";
                    txtAadhar.Text = dr["Aadhar"] != DBNull.Value ? dr["Aadhar"].ToString() : "";
                    txtAddress.Text = dr["Address"] != DBNull.Value ? dr["Address"].ToString() : "";
                    txtQualification.Text = dr["Qualification"] != DBNull.Value ? dr["Qualification"].ToString() : "";
                    txtExperience.Text = dr["Experience"] != DBNull.Value ? dr["Experience"].ToString() : "";
                    txtExperienceIn.Text = dr["ExperienceIn"] != DBNull.Value ? dr["ExperienceIn"].ToString() : "";
                    
                    btnAddEmployee.Text = "Update Employee";
                    btnCancelEdit.Visible = true;
                    ShowMessage("Editing employee " + txtEmpName.Text, true, "employeeModal");
                }
            }
            else if (e.CommandName == "DeleteEmp")
            {
                string masterId = e.CommandArgument.ToString();
                try
                {
                    string delOver = "DELETE FROM CalculationOverrides WHERE EmpID = :MasterId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delOver, new OracleParameter("MasterId", masterId));

                    string delAtt = "DELETE FROM Attendance WHERE EmpID = :MasterId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delAtt, new OracleParameter("MasterId", masterId));
                    
                    string nullEng = "UPDATE Employees SET CurrentEngagementId = NULL WHERE MasterId = :MasterId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), nullEng, new OracleParameter("MasterId", masterId));

                    string delEng = "DELETE FROM EmployeeEngagements WHERE EmpID = :MasterId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delEng, new OracleParameter("MasterId", masterId));

                    string delEmp = "DELETE FROM Employees WHERE MasterId = :MasterId";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delEmp, new OracleParameter("MasterId", masterId));
                    
                    BindResignedEmployees();
                    BindGrid();
                    ShowMessage("Employee and their attendance history completely deleted.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting employee: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "ViewHistory")
            {
                string masterId = e.CommandArgument.ToString();
                OpenHistoryModal(masterId);
            }
        }

        protected void btnHiddenEditTrigger_Click(object sender, EventArgs e)
        {
            string masterId = hfHiddenEditMasterId.Value;
            if (!string.IsNullOrEmpty(masterId))
            {
                string query = "SELECT * FROM Employees WHERE MasterId = :MasterId";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("MasterId", masterId));
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    hfEditOldID.Value = dr["MasterId"].ToString();
                    txtEmpID.Text = dr["ID"].ToString();
                    txtEmpID.Enabled = false;
                    txtJoinDate.Enabled = false;
                    txtEmpName.Text = dr["Name"].ToString();
                    txtMasterID.Text = dr["MasterId"]?.ToString() ?? "";
                    
                    chkIsRejoining.Checked = false;
                    chkIsRejoining.Enabled = false;
                    ddlRejoiningEmployee.Enabled = false;

                    string deptValue = dr["Department"].ToString();
                    if (ddlDept.Items.FindByValue(deptValue) != null)
                    {
                        ddlDept.SelectedValue = deptValue;
                    }
                    else
                    {
                        ddlDept.Items.Add(new ListItem(deptValue, deptValue));
                        ddlDept.SelectedValue = deptValue;
                    }

                    bool hasActiveEng = dr["CurrentEngagementId"] != DBNull.Value;
                    ddlDept.Enabled = !hasActiveEng;
                    lblDeptHelp.Style["display"] = hasActiveEng ? "block" : "none";
                    ddlCat.Enabled = !hasActiveEng;
                    lblCatHelp.Style["display"] = hasActiveEng ? "block" : "none";

                    string catValue = dr["TierId"].ToString();
                    if (ddlCat.Items.FindByValue(catValue) != null)
                    {
                        ddlCat.SelectedValue = catValue;
                    }
                    else
                    {
                        ddlCat.Items.Add(new ListItem(catValue, catValue));
                        ddlCat.SelectedValue = catValue;
                    }

                    object oJoinDate = dr["OriginalJoinDate"] != DBNull.Value ? dr["OriginalJoinDate"] : dr["JoinDate"];
                    txtJoinDate.Text = oJoinDate != DBNull.Value ? Convert.ToDateTime(oJoinDate).ToString("yyyy-MM-dd") : "";
                    txtLeaveBalance.Text = dr["LeaveBalance"].ToString();
                    txtPhone.Text = dr["Phone"] != DBNull.Value ? dr["Phone"].ToString() : "";
                    txtEmail.Text = dr["Email"] != DBNull.Value ? dr["Email"].ToString() : "";
                    txtAadhar.Text = dr["Aadhar"] != DBNull.Value ? dr["Aadhar"].ToString() : "";
                    txtAddress.Text = dr["Address"] != DBNull.Value ? dr["Address"].ToString() : "";
                    txtQualification.Text = dr["Qualification"] != DBNull.Value ? dr["Qualification"].ToString() : "";
                    txtExperience.Text = dr["Experience"] != DBNull.Value ? dr["Experience"].ToString() : "";
                    txtExperienceIn.Text = dr["ExperienceIn"] != DBNull.Value ? dr["ExperienceIn"].ToString() : "";
                    
                    btnAddEmployee.Text = "Update Employee";
                    btnCancelEdit.Visible = true;
                    ShowMessage("Editing employee " + txtEmpName.Text, true, "employeeModal");
                }
            }
        }


        // ── Employee History ─────────────────────────────────────────────────────

        protected void gvEmployees_ViewHistory(object sender, GridViewCommandEventArgs e)
        {
            // handled via inline RowCommand – delegate here
        }

        /// <summary>
        /// Called from RowCommand when CommandName == "ViewHistory".
        /// Builds a JSON-like HTML block and pushes it to the client via JS.
        /// </summary>
        private void OpenHistoryModal(string masterId)
        {
            try
            {
                // 1. Fetch employee master info
                string empSql = @"
                    SELECT e.MasterId, e.ID, e.Name, e.Department, 
                           (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category,
                           e.Status, e.JoinDate, e.OriginalJoinDate, e.ResignDate, e.ContractEndDate,
                           e.Phone, e.Email, e.Aadhar, e.Address, e.Qualification, e.Experience, e.ExperienceIn
                    FROM   Employees e
                    WHERE  e.MasterId = :MasterId";
                DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empSql,
                    new OracleParameter("MasterId", masterId));

                if (dtEmp == null || dtEmp.Rows.Count == 0)
                {
                    ShowMessage("Employee not found.", false);
                    return;
                }

                DataRow emp = dtEmp.Rows[0];
                string empName     = emp["Name"].ToString();
                string empDept     = emp["Department"] != DBNull.Value ? emp["Department"].ToString() : "—";
                string empStatus   = emp["Status"].ToString();
                string empMasterId = emp["MasterId"].ToString();
                string empId       = emp["ID"] != DBNull.Value ? emp["ID"].ToString() : "—";

                DateTime? joinDateVal = emp["JoinDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(emp["JoinDate"]) : null;
                DateTime? origJoinDateVal = emp["OriginalJoinDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(emp["OriginalJoinDate"]) : null;

                string origJoinDateStr = origJoinDateVal.HasValue ? origJoinDateVal.Value.ToString("dd-MMM-yyyy") : (joinDateVal.HasValue ? joinDateVal.Value.ToString("dd-MMM-yyyy") : "—");
                string rejoinDateStr = "";
                if (joinDateVal.HasValue && origJoinDateVal.HasValue && joinDateVal.Value.Date != origJoinDateVal.Value.Date)
                {
                    rejoinDateStr = joinDateVal.Value.ToString("dd-MMM-yyyy");
                }

                string resignDateStr = emp["ResignDate"] != DBNull.Value
                    ? Convert.ToDateTime(emp["ResignDate"]).ToString("dd-MMM-yyyy") : "";
                string contractEndDateStr = emp["ContractEndDate"] != DBNull.Value
                    ? Convert.ToDateTime(emp["ContractEndDate"]).ToString("dd-MMM-yyyy") : "";
                
                string empPhone = emp["Phone"] != DBNull.Value ? emp["Phone"].ToString() : "";
                string empEmail = emp["Email"] != DBNull.Value ? emp["Email"].ToString() : "";
                string empAadhar = emp["Aadhar"] != DBNull.Value ? emp["Aadhar"].ToString() : "";
                string empAddress = emp["Address"] != DBNull.Value ? emp["Address"].ToString() : "";
                string empQualification = emp["Qualification"] != DBNull.Value ? emp["Qualification"].ToString() : "";
                string empExperience = emp["Experience"] != DBNull.Value ? emp["Experience"].ToString() : "";
                string empExperienceIn = emp["ExperienceIn"] != DBNull.Value ? emp["ExperienceIn"].ToString() : "";
 
                // 2. Fetch full engagement history (oldest → newest)
                string histSql = @"
                    SELECT ee.Id, ee.EmpID,
                           (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = ee.TierId) AS Category,
                           ee.StartDate, ee.EndDate, ee.EndReason,
                           ee.IsCarriedOver, ee.PrevEngagementId, ee.EmployeeId, ee.Department,
                           v.Name  AS VendorName,  v.MasterId AS VendorMasterId,
                           cp.StartDate AS ContractStart, cp.EndDate AS ContractEnd
                    FROM   EmployeeEngagements ee
                    JOIN   Vendors            v  ON v.Id  = ee.VendorId
                    LEFT JOIN ContractPeriods cp ON cp.Id = ee.ContractPeriodId
                    WHERE  ee.EmpID IN (SELECT MasterId FROM Employees WHERE EmployeeHistoryId = (SELECT EmployeeHistoryId FROM Employees WHERE MasterId = :MasterId))
                    ORDER  BY ee.StartDate ASC, ee.Id ASC";
                DataTable dtHist = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), histSql,
                    new OracleParameter("MasterId", masterId));
 
                // 3. Build timeline JSON for client-side rendering
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                sb.Append("[");
 
                if (dtHist != null && dtHist.Rows.Count > 0)
                {
                    for (int i = 0; i < dtHist.Rows.Count; i++)
                    {
                        DataRow r = dtHist.Rows[i];
                        string cat        = r["Category"].ToString();
                        string dept       = r["Department"] != DBNull.Value ? r["Department"].ToString() : "";
                        string vName      = r["VendorName"].ToString();
                        string vId        = r["VendorMasterId"].ToString();
                        string startDate  = Convert.ToDateTime(r["StartDate"]).ToString("dd-MMM-yyyy");
                        string endDate    = r["EndDate"] != DBNull.Value
                            ? Convert.ToDateTime(r["EndDate"]).ToString("dd-MMM-yyyy") : "";
                        string endReason  = r["EndReason"] != DBNull.Value ? r["EndReason"].ToString() : "";
                        
                        string cpRange = "No Contract";
                        if (r["ContractStart"] != DBNull.Value)
                        {
                            string cpStart = Convert.ToDateTime(r["ContractStart"]).ToString("dd-MMM-yyyy");
                            string cpEnd   = r["ContractEnd"] != DBNull.Value ? Convert.ToDateTime(r["ContractEnd"]).ToString("dd-MMM-yyyy") : "Present";
                            cpRange = cpStart + " to " + cpEnd;
                        }
                        
                        bool carriedOver  = Convert.ToInt32(r["IsCarriedOver"]) == 1;
                        bool hasPrev      = r["PrevEngagementId"] != DBNull.Value;
                        string historicalEmpId = r["EmployeeId"] != DBNull.Value ? r["EmployeeId"].ToString() : "—";
                        string stintId    = r["EmpID"].ToString();
 
                        if (i > 0) sb.Append(",");
                        sb.Append("{");
                        sb.AppendFormat("\"cat\":\"{0}\",", EscapeJs(cat));
                        sb.AppendFormat("\"dept\":\"{0}\",", EscapeJs(dept));
                        sb.AppendFormat("\"vendor\":\"{0} ({1})\",", EscapeJs(vName), EscapeJs(vId));
                        sb.AppendFormat("\"start\":\"{0}\",", startDate);
                        sb.AppendFormat("\"end\":\"{0}\",", endDate);
                        sb.AppendFormat("\"endReason\":\"{0}\",", EscapeJs(endReason));
                        sb.AppendFormat("\"cpRange\":\"{0}\",", EscapeJs(cpRange));
                        sb.AppendFormat("\"carriedOver\":{0},", carriedOver ? "true" : "false");
                        sb.AppendFormat("\"hasPrev\":{0},", hasPrev ? "true" : "false");
                        sb.AppendFormat("\"historicalEmpId\":\"{0}\",", EscapeJs(historicalEmpId));
                        sb.AppendFormat("\"stintId\":\"{0}\"", EscapeJs(stintId));
                        sb.Append("}");
                    }
                }
                sb.Append("]");
 
                // Escape for JS string literal
                string empJson = string.Format("{{\"name\":\"{0}\",\"masterId\":\"{1}\",\"dept\":\"{2}\",\"status\":\"{3}\",\"joinDate\":\"{4}\",\"rejoinDate\":\"{5}\",\"resignDate\":\"{6}\",\"contractEndDate\":\"{7}\",\"empId\":\"{8}\",\"phone\":\"{9}\",\"email\":\"{10}\",\"aadhar\":\"{11}\",\"address\":\"{12}\",\"qualification\":\"{13}\",\"experience\":\"{14}\",\"experienceIn\":\"{15}\"}}",
                    EscapeJs(empName), EscapeJs(empMasterId), EscapeJs(empDept), EscapeJs(empStatus),
                    origJoinDateStr, rejoinDateStr, resignDateStr, contractEndDateStr, EscapeJs(empId),
                    EscapeJs(empPhone), EscapeJs(empEmail), EscapeJs(empAadhar), EscapeJs(empAddress),
                    EscapeJs(empQualification), EscapeJs(empExperience), EscapeJs(empExperienceIn));

                string script = string.Format("openHistoryModal({0}, {1});", empJson, sb.ToString());
                ClientScript.RegisterStartupScript(this.GetType(), "hist_" + Guid.NewGuid().ToString("N"), script, true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading employee history: " + ex.Message, false);
            }
        }

        private static string EscapeJs(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("'", "\\'")
                    .Replace("\r\n", "\\n").Replace("\r", "").Replace("\n", "\\n");
        }
        // ── End Employee History ─────────────────────────────────────────────────

        private void ShowMessage(string msg, bool success)
        {
            ShowMessage(msg, success, null);
        }

        private void ShowMessage(string msg, bool success, string showModalId)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = false;

            string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string toastType = success ? "success" : "error";
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, toastType);

            if (!string.IsNullOrEmpty(showModalId))
            {
                script += string.Format(" var modalEl = document.getElementById('{0}'); if (modalEl) {{ var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl); modal.show(); }}", showModalId);
                if (showModalId == "employeeModal" && !string.IsNullOrEmpty(hfEditOldID.Value))
                {
                    script += " var label = document.getElementById('employeeModalLabel'); if (label) label.textContent = 'Edit Employee Details';";
                }
            }

            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void SyncIndividualLeaveCredits(string connStr, string masterId, double currentBalance, double prevBalance)
        {
            try
            {
                // Find current engagement details
                string currSql = @"
                    SELECT ee.ContractPeriodId, ee.StartDate 
                    FROM Employees e
                    JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                    WHERE e.MasterId = :MasterId";
                DataTable dtCurr = DBHelper.ExecuteQuery(connStr, currSql, new OracleParameter("MasterId", masterId));
                int? currCpId = null;
                if (dtCurr.Rows.Count > 0)
                {
                    currCpId = Convert.ToInt32(dtCurr.Rows[0]["ContractPeriodId"]);
                    DateTime currStartDate = Convert.ToDateTime(dtCurr.Rows[0]["StartDate"]);

                    // Check if initial balance record exists
                    string checkCurr = @"
                        SELECT Id FROM EmployeeLeaveCredits 
                        WHERE EmpID = :EmpID AND ContractPeriodId = :CpId AND Remarks = 'Contract Initial Balance'";
                    object resCurr = DBHelper.ExecuteScalar(connStr, checkCurr, 
                        new OracleParameter("EmpID", masterId),
                        new OracleParameter("CpId", currCpId.Value));
                    if (resCurr != null && resCurr != DBNull.Value)
                    {
                        // Update
                        string updateCurr = "UPDATE EmployeeLeaveCredits SET Amount = :Amount WHERE Id = :Id";
                        DBHelper.ExecuteNonQuery(connStr, updateCurr, 
                            new OracleParameter("Amount", currentBalance),
                            new OracleParameter("Id", Convert.ToInt32(resCurr)));
                    }
                    else
                    {
                        // Insert
                        string insertCurr = "INSERT INTO EmployeeLeaveCredits (EmpID, ContractPeriodId, Amount, EffectiveDate, Remarks) VALUES (:EmpID, :CpId, :Amount, :EffectiveDate, 'Contract Initial Balance')";
                        DBHelper.ExecuteNonQuery(connStr, insertCurr, 
                            new OracleParameter("EmpID", masterId),
                            new OracleParameter("CpId", currCpId),
                            new OracleParameter("Amount", currentBalance),
                            new OracleParameter("EffectiveDate", currStartDate));
                    }
                }

                // Find latest past engagement from a DIFFERENT contract period
                string pastSql = @"
                    SELECT ee.ContractPeriodId, ee.StartDate 
                    FROM Employees e
                    JOIN EmployeeEngagements ee ON e.MasterId = ee.EmpID
                    WHERE e.MasterId = :MasterId 
                      AND (ee.ContractPeriodId != :CurrCpId OR :CurrCpId IS NULL)
                    ORDER BY ee.StartDate DESC";
                DataTable dtPast = DBHelper.ExecuteQuery(connStr, pastSql, 
                    new OracleParameter("MasterId", masterId),
                    new OracleParameter("CurrCpId", currCpId.HasValue ? (object)currCpId.Value : DBNull.Value));
                if (dtPast.Rows.Count > 0)
                {
                    int pastCpId = Convert.ToInt32(dtPast.Rows[0]["ContractPeriodId"]);
                    DateTime pastStartDate = Convert.ToDateTime(dtPast.Rows[0]["StartDate"]);

                    // Check if initial balance record exists
                    string checkPast = @"
                        SELECT Id FROM EmployeeLeaveCredits 
                        WHERE EmpID = :EmpID AND ContractPeriodId = :CpId AND Remarks = 'Contract Initial Balance'";
                    object resPast = DBHelper.ExecuteScalar(connStr, checkPast, 
                        new OracleParameter("EmpID", masterId),
                        new OracleParameter("CpId", pastCpId));
                    if (resPast != null && resPast != DBNull.Value)
                    {
                        // Only overwrite existing past balance if prevBalance > 0 (prevents zeroing out valid past credits)
                        if (prevBalance > 0)
                        {
                            string updatePast = "UPDATE EmployeeLeaveCredits SET Amount = :Amount WHERE Id = :Id";
                            DBHelper.ExecuteNonQuery(connStr, updatePast, 
                                new OracleParameter("Amount", prevBalance),
                                new OracleParameter("Id", Convert.ToInt32(resPast)));
                        }
                    }
                    else if (prevBalance > 0)
                    {
                        // Insert
                        string insertPast = "INSERT INTO EmployeeLeaveCredits (EmpID, ContractPeriodId, Amount, EffectiveDate, Remarks) VALUES (:EmpID, :CpId, :Amount, :EffectiveDate, 'Contract Initial Balance')";
                        DBHelper.ExecuteNonQuery(connStr, insertPast, 
                            new OracleParameter("EmpID", masterId),
                            new OracleParameter("CpId", pastCpId),
                            new OracleParameter("Amount", prevBalance),
                            new OracleParameter("EffectiveDate", pastStartDate));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error syncing leave credits: " + ex.Message);
            }
        }

        [System.Web.Services.WebMethod]
        public static string CheckAadharMatch(string aadharNumber, string currentMasterId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(aadharNumber)) return "{\"matched\":false}";

                string cleanAadhar = aadharNumber.Replace(" ", "").Replace("-", "").Trim();
                if (cleanAadhar.Length != 12) return "{\"matched\":false}";

                string connStr = DBHelper.GetAttendanceDBConnection();
                string empSql = @"
                    SELECT e.MasterId, NVL(e.ID, '') AS EmployeeId, e.Name, e.Status, 
                           e.Department, e.Aadhar, e.Phone, e.Email, e.Address, 
                           e.Qualification, e.Experience, e.ExperienceIn,
                           e.OriginalJoinDate, e.JoinDate, e.ResignDate, e.ContractEndDate,
                           (SELECT t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t WHERE t.Id = e.TierId) AS TierName,
                           (SELECT mc.Name FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS MainCategoryName
                    FROM Employees e
                    WHERE e.Aadhar IS NOT NULL 
                      AND REPLACE(REPLACE(e.Aadhar, ' ', ''), '-', '') = :Aadhar
                      AND e.MasterId <> 'GLOBAL'";

                var parameters = new List<OracleParameter> {
                    new OracleParameter("Aadhar", cleanAadhar)
                };

                if (!string.IsNullOrWhiteSpace(currentMasterId))
                {
                    empSql += @" AND e.MasterId <> :CurrentMasterId 
                                 AND e.EmployeeHistoryId <> (
                                     SELECT NVL(ee.EmployeeHistoryId, ee.MasterId) 
                                     FROM Employees ee 
                                     WHERE ee.MasterId = :CurrentMasterId2
                                 )";
                    parameters.Add(new OracleParameter("CurrentMasterId", currentMasterId.Trim()));
                    parameters.Add(new OracleParameter("CurrentMasterId2", currentMasterId.Trim()));
                }

                DataTable dtEmp = DBHelper.ExecuteQuery(connStr, empSql, parameters.ToArray());
                if (dtEmp.Rows.Count == 0)
                {
                    return "{\"matched\":false}";
                }

                DataRow row = dtEmp.Rows[0];
                string masterId = row["MasterId"].ToString();
                string tierName = row["TierName"] != DBNull.Value ? row["TierName"].ToString() : "";
                string mainCat = row["MainCategoryName"] != DBNull.Value ? row["MainCategoryName"].ToString() : "";
                string categoryDisplay = !string.IsNullOrEmpty(mainCat) ? (mainCat + " › " + tierName) : tierName;

                var empObj = new
                {
                    MasterId = masterId,
                    EmployeeId = row["EmployeeId"].ToString(),
                    Name = row["Name"].ToString(),
                    Status = row["Status"].ToString(),
                    Department = row["Department"] != DBNull.Value ? row["Department"].ToString() : "",
                    Aadhar = row["Aadhar"] != DBNull.Value ? row["Aadhar"].ToString() : "",
                    Phone = row["Phone"] != DBNull.Value ? row["Phone"].ToString() : "",
                    Email = row["Email"] != DBNull.Value ? row["Email"].ToString() : "",
                    Address = row["Address"] != DBNull.Value ? row["Address"].ToString() : "",
                    Qualification = row["Qualification"] != DBNull.Value ? row["Qualification"].ToString() : "",
                    CategoryName = categoryDisplay,
                    OriginalJoinDate = row["OriginalJoinDate"] != DBNull.Value ? Convert.ToDateTime(row["OriginalJoinDate"]).ToString("dd-MMM-yyyy") : "",
                    JoinDate = row["JoinDate"] != DBNull.Value ? Convert.ToDateTime(row["JoinDate"]).ToString("dd-MMM-yyyy") : "",
                    ResignDate = row["ResignDate"] != DBNull.Value ? Convert.ToDateTime(row["ResignDate"]).ToString("dd-MMM-yyyy") : "",
                    ContractEndDate = row["ContractEndDate"] != DBNull.Value ? Convert.ToDateTime(row["ContractEndDate"]).ToString("dd-MMM-yyyy") : ""
                };

                // Fetch engagement history
                string historySql = @"
                    SELECT ee.Id, ee.Department, ee.StartDate, ee.EndDate, ee.EndReason, ee.EmployeeId,
                           t.TierName, mc.Name AS MainCategoryName, v.Name AS VendorName
                    FROM EmployeeEngagements ee
                    LEFT JOIN Tiers t ON ee.TierId = t.Id
                    LEFT JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                    LEFT JOIN Vendors v ON ee.VendorId = v.Id
                    WHERE ee.EmpID = :MasterId
                    ORDER BY ee.StartDate DESC";

                DataTable dtHist = DBHelper.ExecuteQuery(connStr, historySql, new OracleParameter("MasterId", masterId));
                var historyList = new List<object>();
                foreach (DataRow hRow in dtHist.Rows)
                {
                    string hTier = hRow["TierName"] != DBNull.Value ? hRow["TierName"].ToString() : "";
                    string hMain = hRow["MainCategoryName"] != DBNull.Value ? hRow["MainCategoryName"].ToString() : "";
                    string hCat = !string.IsNullOrEmpty(hMain) ? (hMain + " › " + hTier) : hTier;

                    historyList.Add(new
                    {
                        Department = hRow["Department"] != DBNull.Value ? hRow["Department"].ToString() : "",
                        CategoryName = hCat,
                        VendorName = hRow["VendorName"] != DBNull.Value ? hRow["VendorName"].ToString() : "",
                        EmployeeId = hRow["EmployeeId"] != DBNull.Value ? hRow["EmployeeId"].ToString() : "",
                        StartDate = hRow["StartDate"] != DBNull.Value ? Convert.ToDateTime(hRow["StartDate"]).ToString("dd-MMM-yyyy") : "",
                        EndDate = hRow["EndDate"] != DBNull.Value ? Convert.ToDateTime(hRow["EndDate"]).ToString("dd-MMM-yyyy") : "Present",
                        EndReason = hRow["EndReason"] != DBNull.Value ? hRow["EndReason"].ToString() : ""
                    });
                }

                var response = new
                {
                    matched = true,
                    employee = empObj,
                    history = historyList
                };

                return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(response);
            }
            catch (Exception ex)
            {
                return "{\"matched\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }
    }
}
