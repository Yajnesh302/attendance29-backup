using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Contracts : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated || Session["PCNO"] == null)
            {
                System.Web.Security.FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx");
                return;
            }

            // Restrict page to Admin users only (Role = 1)
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                Response.Write("<!DOCTYPE html><html><head><title>Access Denied</title><link href='Static/fontawesome-free/css/all.min.css' rel='stylesheet' type='text/css' /><link href='Static/css/sb-admin-2.min.css' rel='stylesheet' /><style>body { background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); height: 100vh; display: flex; align-items: center; justify-content: center; font-family: 'Nunito', sans-serif; color: #f1f5f9; margin: 0; } .error-card { background: rgba(30, 41, 59, 0.7); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px; padding: 40px; text-align: center; max-width: 450px; width: 90%; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.3); animation: fadeIn 0.5s ease-out; } @keyframes fadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } } .error-icon { font-size: 64px; color: #f43f5e; margin-bottom: 20px; animation: pulse 2s infinite; } @keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.05); } 100% { transform: scale(1); } } h2 { font-size: 24px; margin-bottom: 10px; font-weight: 700; } p { color: #94a3b8; font-size: 16px; margin-bottom: 30px; line-height: 1.5; } .btn-action { display: inline-block; background: linear-gradient(135deg, #4f46e5 0%, #3b82f6 100%); color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: all 0.3s ease; box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.2); margin: 5px; } .btn-action:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(79, 70, 229, 0.4); color: white; } .btn-secondary-action { display: inline-block; background: rgba(255, 255, 255, 0.1); color: #e2e8f0; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: all 0.3s ease; margin: 5px; } .btn-secondary-action:hover { background: rgba(255, 255, 255, 0.2); color: white; }</style></head><body><div class='error-card'><div class='error-icon'><i class='fas fa-exclamation-triangle'></i></div><h2>Access Denied</h2><p>This page is restricted. Only administrators are allowed to access this resource.</p><div><a href='Login.aspx' class='btn-action'>Login as Admin</a><a href='Dashboard.aspx' class='btn-secondary-action'>Go to Dashboard</a></div></div></body></html>");
                Response.End();
                return;
            }

            if (!IsPostBack)
            {
                BindCategories();
                BindVendors();
                BindContractsHistory();
                mvContracts.ActiveViewIndex = 0;
                stepHeader1.Attributes["class"] = "wizard-step active";
                stepHeader2.Attributes["class"] = "wizard-step";
                stepHeader3.Attributes["class"] = "wizard-step";
            }
        }

        private void BindCategories()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                DataTable dt = DBHelper.GetVisibleTiersDataTable(pcno, role);

                // Populate ddlCategory
                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new ListItem("-- Select Category --", ""));
                foreach (DataRow row in dt.Rows)
                {
                    ddlCategory.Items.Add(new ListItem(row["DisplayName"].ToString(), row["TierId"].ToString()));
                }

                // Populate ddlFilterCategory
                ddlFilterCategory.Items.Clear();
                ddlFilterCategory.Items.Add(new ListItem("All Categories", ""));
                foreach (DataRow row in dt.Rows)
                {
                    ddlFilterCategory.Items.Add(new ListItem(row["DisplayName"].ToString(), row["TierId"].ToString()));
                }

                // Populate ddlFilterEnroll
                ddlFilterEnroll.Items.Clear();
                ddlFilterEnroll.Items.Add(new ListItem("All Categories", "All"));
                foreach (DataRow row in dt.Rows)
                {
                    ddlFilterEnroll.Items.Add(new ListItem(row["DisplayName"].ToString() + " Only", row["TierId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading categories: " + ex.Message, false);
            }
        }

        private void BindVendors()
        {
            try
            {
                string query = "SELECT Id, MasterId || ' - ' || Name AS DisplayName FROM Vendors WHERE IsActive = 1 ORDER BY Name ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);

                // Populate Single Vendor Dropdown
                ddlVendor.Items.Clear();
                ddlVendor.Items.Add(new ListItem("-- Select Vendor --", ""));
                foreach (DataRow row in dt.Rows)
                {
                    ddlVendor.Items.Add(new ListItem(row["DisplayName"].ToString(), row["Id"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading vendors: " + ex.Message, false);
            }
        }

        private void BindContractsHistory()
        {
            try
            {
                string category = ddlFilterCategory.SelectedValue;
                string status = ddlFilterStatus.SelectedValue;
                string search = txtSearchVendor.Text.Trim();

                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                string query = @"
                    SELECT cp.Id, 
                           (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = cp.TierId) AS Category,
                           cp.GemId, cp.StartDate, cp.EndDate, cp.DatedOn, cp.Status,
                           (SELECT COUNT(*) FROM ContractExtensions ce WHERE ce.ContractPeriodId = cp.Id) AS ExtensionCount
                    FROM ContractPeriods cp
                    JOIN Vendors v ON cp.VendorId = v.Id
                    WHERE 1=1";

                List<OracleParameter> pList = new List<OracleParameter>();

                if (!string.IsNullOrEmpty(category))
                {
                    query += " AND cp.TierId = :TierId";
                    pList.Add(new OracleParameter("TierId", Convert.ToInt32(category)));
                }

                // Scope to user visible contract periods
                query += @" AND (
                    :IsSuper = 1
                    OR cp.TierId IN (
                        SELECT t.Id 
                        FROM Tiers t
                        JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                        LEFT JOIN UserTiers ut ON t.Id = ut.TierId AND :Role = 0
                        WHERE (:Role = 4)
                           OR (:Role = 1 AND (
                               mc.AdminPCNO = :PCNO
                               OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL)
                               OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL)
                           ))
                           OR (:Role = 0 AND ut.PCNO = :PCNO)
                    )
                )";
                pList.Add(new OracleParameter("IsSuper", (role == 4) ? 1 : 0));
                pList.Add(new OracleParameter("Role", role));
                pList.Add(new OracleParameter("PCNO", pcno));

                if (!string.IsNullOrEmpty(status))
                {
                    query += " AND cp.Status = :Status";
                    pList.Add(new OracleParameter("Status", status));
                }

                if (!string.IsNullOrEmpty(search))
                {
                    query += " AND (UPPER(v.Name) LIKE :Search OR UPPER(v.MasterId) LIKE :Search)";
                    pList.Add(new OracleParameter("Search", "%" + search.ToUpper() + "%"));
                }

                query += " ORDER BY cp.StartDate DESC";

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pList.ToArray());
                rptContractPeriods.DataSource = dt;
                rptContractPeriods.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading contracts history: " + ex.Message, false);
            }
        }

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindContractsHistory();
        }

        protected void btnSearchContracts_Click(object sender, EventArgs e)
        {
            BindContractsHistory();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            ddlFilterCategory.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            txtSearchVendor.Text = "";
            BindContractsHistory();
        }

        protected void rptContractPeriods_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;
                int periodId = Convert.ToInt32(drv["Id"]);

                Repeater rptDetails = (Repeater)e.Item.FindControl("rptContractDetails");
                if (rptDetails != null)
                {
                    string category = ddlFilterCategory.SelectedValue;
                    string search = txtSearchVendor.Text.Trim();

                    string query = @"
                        SELECT (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = cp.TierId) AS Category,
                               v.MasterId, v.Name AS VendorName,
                               (SELECT COUNT(*) FROM EmployeeEngagements ee 
                                WHERE ee.ContractPeriodId = cp.Id 
                                  AND (ee.EndDate IS NULL OR ee.EndDate = cp.EndDate OR ee.EndReason = 'ContractEnd')) AS EmployeeCount
                        FROM ContractPeriods cp
                        JOIN Vendors v ON cp.VendorId = v.Id
                        WHERE cp.Id = :PeriodId";

                    List<OracleParameter> pList = new List<OracleParameter>();
                    pList.Add(new OracleParameter("PeriodId", periodId));

                    if (!string.IsNullOrEmpty(category))
                    {
                        query += " AND cp.TierId = :TierId";
                        pList.Add(new OracleParameter("TierId", Convert.ToInt32(category)));
                    }

                    if (!string.IsNullOrEmpty(search))
                    {
                        query += " AND (UPPER(v.Name) LIKE :Search OR UPPER(v.MasterId) LIKE :Search)";
                        pList.Add(new OracleParameter("Search", "%" + search.ToUpper() + "%"));
                    }

                    query += " ORDER BY cp.TierId ASC";

                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pList.ToArray());
                    rptDetails.DataSource = dt;
                    rptDetails.DataBind();
                }

                Repeater rptExtensions = (Repeater)e.Item.FindControl("rptExtensionHistory");
                if (rptExtensions != null)
                {
                    string queryExt = @"
                        SELECT OldEndDate, NewEndDate, ExtensionDate
                        FROM ContractExtensions
                        WHERE ContractPeriodId = :PeriodId
                        ORDER BY ExtensionDate DESC, Id DESC";

                    DataTable dtExt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryExt, new OracleParameter("PeriodId", periodId));
                    rptExtensions.DataSource = dtExt;
                    rptExtensions.DataBind();
                }
            }
        }


        protected void btnModalConfirmExtend_Click(object sender, EventArgs e)
        {
            string periodIdStr = hfExtendContractId.Value.Trim();
            string newEndStr = txtExtendContractNewEndDate.Text.Trim();

            if (string.IsNullOrEmpty(periodIdStr) || string.IsNullOrEmpty(newEndStr))
            {
                ShowMessage("Contract ID and New End Date are required.", false, "extendContractModal");
                return;
            }

            int periodId;
            if (!int.TryParse(periodIdStr, out periodId))
            {
                ShowMessage("Invalid Contract ID.", false, "extendContractModal");
                return;
            }

            DateTime newEndDate;
            if (!TryParseDate(newEndStr, out newEndDate))
            {
                ShowMessage("Please enter a valid New Extended End Date (YYYY-MM-DD).", false, "extendContractModal");
                return;
            }

            using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
            {
                conn.Open();
                using (OracleTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Get current contract dates to validate
                        string getDatesSql = "SELECT StartDate, EndDate FROM ContractPeriods WHERE Id = :Id";
                        DateTime startDate = DateTime.MinValue;
                        DateTime? currentEndDate = null;

                        using (OracleCommand cmd = new OracleCommand(getDatesSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("Id", periodId));
                            using (OracleDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    startDate = Convert.ToDateTime(reader["StartDate"]);
                                    if (reader["EndDate"] != DBNull.Value)
                                    {
                                        currentEndDate = Convert.ToDateTime(reader["EndDate"]);
                                    }
                                }
                                else
                                {
                                    ShowMessage("Contract period record not found.", false, "extendContractModal");
                                    return;
                                }
                            }
                        }

                        // Validation: new end date must be later than start date
                        if (newEndDate <= startDate)
                        {
                            ShowMessage("New Extended End Date must be after the Contract Start Date (" + startDate.ToString("dd-MMM-yyyy") + ").", false, "extendContractModal");
                            return;
                        }

                        // Validation: new end date must be later than current end date (if exists)
                        if (currentEndDate.HasValue && newEndDate <= currentEndDate.Value)
                        {
                            ShowMessage("New Extended End Date must be after the current Contract End Date (" + currentEndDate.Value.ToString("dd-MMM-yyyy") + ").", false, "extendContractModal");
                            return;
                        }

                        // 2. Insert into ContractExtensions
                        string insertExtensionSql = @"
                            INSERT INTO ContractExtensions (ContractPeriodId, OldEndDate, NewEndDate, ExtensionDate)
                            VALUES (:PeriodId, :OldEndDate, :NewEndDate, SYSTIMESTAMP)";
                        using (OracleCommand cmd = new OracleCommand(insertExtensionSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            cmd.Parameters.Add(new OracleParameter("OldEndDate", currentEndDate.HasValue ? (object)currentEndDate.Value : DBNull.Value));
                            cmd.Parameters.Add(new OracleParameter("NewEndDate", newEndDate));
                            cmd.ExecuteNonQuery();
                        }

                        // 3. Update ContractPeriods
                        string updatePeriodSql = "UPDATE ContractPeriods SET EndDate = :NewEndDate WHERE Id = :Id";
                        using (OracleCommand cmd = new OracleCommand(updatePeriodSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("NewEndDate", newEndDate));
                            cmd.Parameters.Add(new OracleParameter("Id", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        trans.Commit();

                        // Close modal
                        string script = @"
                            var modalEl = document.getElementById('extendContractModal');
                            if (modalEl) {
                                if (window.bootstrap && window.bootstrap.Modal) {
                                    var modal = window.bootstrap.Modal.getInstance(modalEl);
                                    if (modal) modal.hide();
                                } else if (window.jQuery && window.jQuery.fn.modal) {
                                    window.jQuery(modalEl).modal('hide');
                                } else {
                                    modalEl.classList.remove('show');
                                    modalEl.style.display = 'none';
                                    document.body.classList.remove('modal-open');
                                }
                            }";
                        ClientScript.RegisterStartupScript(this.GetType(), "closeExtendModal", script, true);

                        ShowMessage("Contract period extended successfully.", true);
                        BindContractsHistory();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ShowMessage("Database error while extending contract: " + ex.Message, false, "extendContractModal");
                    }
                }
            }
        }


        protected void btnModalConfirmEnd_Click(object sender, EventArgs e)
        {
            string periodIdStr = hfEndContractStartDate.Value.Trim();
            string endStr = txtEndContractEndDate.Text.Trim();

            if (string.IsNullOrEmpty(periodIdStr) || string.IsNullOrEmpty(endStr))
            {
                ShowMessage("Contract ID and End date are required.", false, "endContractModal");
                return;
            }

            int periodId;
            if (!int.TryParse(periodIdStr, out periodId))
            {
                ShowMessage("Invalid Contract ID.", false, "endContractModal");
                return;
            }

            DateTime endDate;
            if (!TryParseDate(endStr, out endDate))
            {
                ShowMessage("End date must be in a valid date format.", false, "endContractModal");
                return;
            }

            using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
            {
                conn.Open();
                using (OracleTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // Retrieve contract StartDate
                        DateTime startDate;
                        string selectCPSql = "SELECT StartDate FROM ContractPeriods WHERE Id = :Id";
                        using (OracleCommand cmd = new OracleCommand(selectCPSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("Id", periodId));
                            object res = cmd.ExecuteScalar();
                            if (res == null || res == DBNull.Value)
                            {
                                ShowMessage("Contract period not found.", false, "endContractModal");
                                return;
                            }
                            startDate = Convert.ToDateTime(res);
                        }

                        if (endDate < startDate)
                        {
                            ShowMessage("End date cannot be earlier than the start date (" + startDate.ToString("dd-MMM-yyyy") + ").", false, "endContractModal");
                            return;
                        }

                        // 1. Close ContractPeriods
                        string closeCP = "UPDATE ContractPeriods SET EndDate = :EndDate, Status = 'Closed' WHERE Id = :Id AND Status = 'Active'";
                        using (OracleCommand cmd = new OracleCommand(closeCP, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.BindByName = true;
                            cmd.Parameters.Add(new OracleParameter("EndDate", endDate));
                            cmd.Parameters.Add(new OracleParameter("Id", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Get active engagements under this ContractPeriod
                        string activeEngsQuery = @"
                            SELECT Id, EmpID FROM EmployeeEngagements 
                            WHERE ContractPeriodId = :PeriodId AND EndDate IS NULL";
                        
                        DataTable dtEngs = new DataTable();
                        using (OracleCommand cmd = new OracleCommand(activeEngsQuery, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.BindByName = true;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            using (OracleDataAdapter sda = new OracleDataAdapter(cmd))
                            {
                                sda.Fill(dtEngs);
                            }
                        }

                        foreach (DataRow row in dtEngs.Rows)
                        {
                            int engId = Convert.ToInt32(row["Id"]);
                            string empId = row["EmpID"].ToString();

                            // Close engagement
                            string closeEng = "UPDATE EmployeeEngagements SET EndDate = :EndDate, EndReason = 'ContractEnd' WHERE Id = :Id";
                            using (OracleCommand cmd = new OracleCommand(closeEng, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("EndDate", endDate));
                                cmd.Parameters.Add(new OracleParameter("Id", engId));
                                cmd.ExecuteNonQuery();
                            }

                            // Update Employee Master to set ContractEnded, record ContractEndDate and clear CurrentEngagementId
                            string updateEmp = "UPDATE Employees SET CurrentEngagementId = NULL, ContractEndDate = :ContractEndDate, Status = 'ContractEnded' WHERE MasterId = :MasterId AND CurrentEngagementId = :Id";
                            using (OracleCommand cmd = new OracleCommand(updateEmp, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("ContractEndDate", endDate));
                                cmd.Parameters.Add(new OracleParameter("MasterId", empId));
                                cmd.Parameters.Add(new OracleParameter("Id", engId));
                                cmd.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                        
                        // Close modal and refresh list
                        string script = @"
                            var modalEl = document.getElementById('endContractModal');
                            if (modalEl) {
                                if (window.bootstrap && window.bootstrap.Modal) {
                                    var modal = window.bootstrap.Modal.getInstance(modalEl);
                                    if (modal) modal.hide();
                                } else if (window.jQuery && window.jQuery.fn.modal) {
                                    window.jQuery(modalEl).modal('hide');
                                } else {
                                    modalEl.classList.remove('show');
                                    modalEl.style.display = 'none';
                                    document.body.classList.remove('modal-open');
                                }
                            }";
                        ClientScript.RegisterStartupScript(this.GetType(), "closeEndModal", script, true);

                        ShowMessage("Contract period ended successfully. All associated employee engagements have been closed.", true);
                        BindContractsHistory();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ShowMessage("Database error while ending contract: " + ex.Message, false, "endContractModal");
                    }
                }
            }
        }

        protected void btnModalConfirmDelete_Click(object sender, EventArgs e)
        {
            string periodIdStr = hfDeleteContractStartDate.Value.Trim();

            if (string.IsNullOrEmpty(periodIdStr))
            {
                ShowMessage("Contract ID is required.", false, "deleteContractModal");
                return;
            }

            int periodId;
            if (!int.TryParse(periodIdStr, out periodId))
            {
                ShowMessage("Invalid Contract ID.", false, "deleteContractModal");
                return;
            }

            using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
            {
                conn.Open();
                using (OracleTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Get current contract details
                        string getCPSql = "SELECT TierId, StartDate FROM ContractPeriods WHERE Id = :Id";
                        int tierId = 0;
                        DateTime startDate = DateTime.MinValue;
                        using (OracleCommand cmd = new OracleCommand(getCPSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("Id", periodId));
                            using (OracleDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    tierId = Convert.ToInt32(reader["TierId"]);
                                    startDate = Convert.ToDateTime(reader["StartDate"]);
                                }
                                else
                                {
                                    ShowMessage("Contract period not found.", false, "deleteContractModal");
                                    return;
                                }
                            }
                        }

                        // 2. Query previous contract period of same category
                        int? prevPeriodId = null;
                        DateTime? prevPeriodEndDate = null;
                        string getPrevPeriodSql = @"
                            SELECT Id, EndDate FROM ContractPeriods 
                            WHERE TierId = :TierId AND StartDate < :StartDate 
                            ORDER BY StartDate DESC";
                        using (OracleCommand cmd = new OracleCommand(getPrevPeriodSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("TierId", tierId));
                            cmd.Parameters.Add(new OracleParameter("StartDate", startDate));
                            using (OracleDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    prevPeriodId = Convert.ToInt32(reader["Id"]);
                                    if (reader["EndDate"] != DBNull.Value)
                                    {
                                        prevPeriodEndDate = Convert.ToDateTime(reader["EndDate"]);
                                    }
                                }
                            }
                        }

                        // 3. Cascade delete Attendance associated with this contract period
                        string deleteAttendanceSql = "DELETE FROM Attendance WHERE ContractPeriodId = :PeriodId";
                        using (OracleCommand cmd = new OracleCommand(deleteAttendanceSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        // 4. Cascade delete CalculationOverrides associated with this contract period
                        string deleteOverridesSql = "DELETE FROM CalculationOverrides WHERE ContractPeriodId = :PeriodId";
                        using (OracleCommand cmd = new OracleCommand(deleteOverridesSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        // 5. Fetch all current engagements in this contract period to relink or revert
                        DataTable dtEngs = new DataTable();
                        string getEngsSql = @"
                            SELECT Id, EmpID, PrevEngagementId, TierId, StartDate, Department 
                            FROM EmployeeEngagements 
                            WHERE ContractPeriodId = :PeriodId";
                        using (OracleCommand cmd = new OracleCommand(getEngsSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            using (OracleDataAdapter sda = new OracleDataAdapter(cmd))
                            {
                                sda.Fill(dtEngs);
                            }
                        }

                        foreach (DataRow engRow in dtEngs.Rows)
                        {
                            int engId = Convert.ToInt32(engRow["Id"]);
                            string empId = engRow["EmpID"].ToString();
                            object prevEngIdVal = engRow["PrevEngagementId"];

                            // a. Relink any subsequent engagements pointing to this engagement
                            string updateSubsequentSql = @"
                                UPDATE EmployeeEngagements 
                                SET PrevEngagementId = :PrevEngagementId 
                                WHERE PrevEngagementId = :CurrEngagementId";
                            using (OracleCommand cmd = new OracleCommand(updateSubsequentSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("PrevEngagementId", prevEngIdVal));
                                cmd.Parameters.Add(new OracleParameter("CurrEngagementId", engId));
                                cmd.ExecuteNonQuery();
                            }

                            // b. Revert Employees master record if they are currently pointed to this engagement
                            string checkEmpSql = "SELECT COUNT(*) FROM Employees WHERE MasterId = :MasterId AND CurrentEngagementId = :CurrEngagementId";
                            int isCurrent = 0;
                            using (OracleCommand cmd = new OracleCommand(checkEmpSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("MasterId", empId));
                                cmd.Parameters.Add(new OracleParameter("CurrEngagementId", engId));
                                isCurrent = Convert.ToInt32(cmd.ExecuteScalar());
                            }

                            if (isCurrent > 0)
                            {
                                if (prevEngIdVal != DBNull.Value)
                                {
                                    int prevEngId = Convert.ToInt32(prevEngIdVal);

                                    // Fetch previous engagement details to restore employee master state
                                    string getPrevEngDetailsSql = "SELECT TierId, StartDate, Department FROM EmployeeEngagements WHERE Id = :Id";
                                    string prevCategory = "";
                                    DateTime prevStartDate = DateTime.MinValue;
                                    string prevDept = "GENERAL";

                                    using (OracleCommand cmd = new OracleCommand(getPrevEngDetailsSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("Id", prevEngId));
                                        using (OracleDataReader reader = cmd.ExecuteReader())
                                        {
                                            if (reader.Read())
                                            {
                                                prevCategory = reader["TierId"].ToString();
                                                prevStartDate = Convert.ToDateTime(reader["StartDate"]);
                                                prevDept = reader["Department"] != DBNull.Value ? reader["Department"].ToString() : "GENERAL";
                                            }
                                        }
                                    }

                                    // Re-open the previous engagement (make it active again)
                                    string reopenPrevEngSql = "UPDATE EmployeeEngagements SET EndDate = NULL, EndReason = NULL WHERE Id = :Id";
                                    using (OracleCommand cmd = new OracleCommand(reopenPrevEngSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("Id", prevEngId));
                                        cmd.ExecuteNonQuery();
                                    }

                                    // Update employee master record back to the previous engagement
                                    string revertEmpSql = @"
                                        UPDATE Employees 
                                        SET CurrentEngagementId = :PrevEngagementId,
                                            TierId = :TierId,
                                            JoinDate = :JoinDate,
                                            Department = :Department,
                                            Status = 'Active',
                                            ResignDate = NULL,
                                            ContractEndDate = NULL
                                        WHERE MasterId = :MasterId";
                                    using (OracleCommand cmd = new OracleCommand(revertEmpSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("PrevEngagementId", prevEngId));
                                        cmd.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(prevCategory)));
                                        cmd.Parameters.Add(new OracleParameter("JoinDate", prevStartDate));
                                        cmd.Parameters.Add(new OracleParameter("Department", prevDept));
                                        cmd.Parameters.Add(new OracleParameter("MasterId", empId));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    // No previous engagement
                                    string revertNewEmpSql = @"
                                        UPDATE Employees 
                                        SET CurrentEngagementId = NULL,
                                            JoinDate = NULL,
                                            TierId = NULL,
                                            Status = 'ContractEnded',
                                            ResignDate = NULL,
                                            ContractEndDate = NULL
                                        WHERE MasterId = :MasterId";
                                    using (OracleCommand cmd = new OracleCommand(revertNewEmpSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("MasterId", empId));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }
                        }

                        // 6. Find and re-open preceding employee engagements that were closed when this contract started (unselected actions)
                        if (prevPeriodId.HasValue && prevPeriodEndDate.HasValue)
                        {
                            DataTable dtClosedEngs = new DataTable();
                            string getClosedEngsSql = @"
                                SELECT Id, EmpID, TierId, StartDate, Department 
                                FROM EmployeeEngagements 
                                WHERE ContractPeriodId = :PrevPeriodId AND EndDate = :PrevPeriodEndDate";
                            using (OracleCommand cmd = new OracleCommand(getClosedEngsSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("PrevPeriodId", prevPeriodId.Value));
                                cmd.Parameters.Add(new OracleParameter("PrevPeriodEndDate", prevPeriodEndDate.Value));
                                using (OracleDataAdapter sda = new OracleDataAdapter(cmd))
                                {
                                    sda.Fill(dtClosedEngs);
                                }
                            }

                            foreach (DataRow closedRow in dtClosedEngs.Rows)
                            {
                                int closedEngId = Convert.ToInt32(closedRow["Id"]);
                                string empId = closedRow["EmpID"].ToString();
                                string cat = closedRow["TierId"].ToString();
                                DateTime startDateVal = Convert.ToDateTime(closedRow["StartDate"]);
                                string dept = closedRow["Department"] != DBNull.Value ? closedRow["Department"].ToString() : "GENERAL";

                                // Re-open the engagement
                                string reopenSql = "UPDATE EmployeeEngagements SET EndDate = NULL, EndReason = NULL WHERE Id = :Id";
                                using (OracleCommand cmd = new OracleCommand(reopenSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", closedEngId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Revert employee master record back to this engagement
                                string revertEmpSql = @"
                                    UPDATE Employees 
                                    SET CurrentEngagementId = :CurrentEngagementId,
                                        TierId = :TierId,
                                        JoinDate = :JoinDate,
                                        Department = :Department,
                                        Status = 'Active',
                                        ResignDate = NULL,
                                        ContractEndDate = NULL
                                    WHERE MasterId = :MasterId";
                                using (OracleCommand cmd = new OracleCommand(revertEmpSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("CurrentEngagementId", closedEngId));
                                    cmd.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(cat)));
                                    cmd.Parameters.Add(new OracleParameter("JoinDate", startDateVal));
                                    cmd.Parameters.Add(new OracleParameter("Department", dept));
                                    cmd.Parameters.Add(new OracleParameter("MasterId", empId));
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // Re-open the previous contract period
                            string reopenPrevContractSql = "UPDATE ContractPeriods SET EndDate = NULL, Status = 'Active' WHERE Id = :PrevPeriodId";
                            using (OracleCommand cmd = new OracleCommand(reopenPrevContractSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("PrevPeriodId", prevPeriodId.Value));
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // 7. Delete EmployeeEngagements associated with the deleted contract period
                        string deleteEngagementsSql = "DELETE FROM EmployeeEngagements WHERE ContractPeriodId = :PeriodId";
                        using (OracleCommand cmd = new OracleCommand(deleteEngagementsSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        // 8. Delete ContractPeriodVendors associated with the deleted contract period
                        string deleteVendorsSql = "DELETE FROM ContractPeriodVendors WHERE ContractPeriodId = :PeriodId";
                        using (OracleCommand cmd = new OracleCommand(deleteVendorsSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        // 9. Delete the ContractPeriod row itself
                        string deleteContractPeriodsSql = "DELETE FROM ContractPeriods WHERE Id = :PeriodId";
                        using (OracleCommand cmd = new OracleCommand(deleteContractPeriodsSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                            cmd.ExecuteNonQuery();
                        }

                        trans.Commit();

                        // Close modal and refresh list
                        string script = @"
                            var modalEl = document.getElementById('deleteContractModal');
                            if (modalEl) {
                                if (window.bootstrap && window.bootstrap.Modal) {
                                    var modal = window.bootstrap.Modal.getInstance(modalEl);
                                    if (modal) modal.hide();
                                } else if (window.jQuery && window.jQuery.fn.modal) {
                                    window.jQuery(modalEl).modal('hide');
                                } else {
                                    modalEl.classList.remove('show');
                                    modalEl.style.display = 'none';
                                    document.body.classList.remove('modal-open');
                                }
                            }";
                        ClientScript.RegisterStartupScript(this.GetType(), "closeDeleteModal", script, true);

                        ShowMessage("Contract period and all associated history have been deleted successfully.", true);
                        BindContractsHistory();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ShowMessage("Database error while deleting contract: " + ex.Message, false, "deleteContractModal");
                    }
                }
            }
        }


        protected void btnNextStep_Click(object sender, EventArgs e)
        {
            string category = ddlCategory.SelectedValue;
            string startStr = txtStartDate.Text.Trim();
            string endStr = txtEndDate.Text.Trim();
            string vendorIdStr = ddlVendor.SelectedValue;

            if (string.IsNullOrEmpty(category))
            {
                ShowMessage("Please select a Category.", false);
                return;
            }

            if (string.IsNullOrEmpty(startStr))
            {
                ShowMessage("Contract Start Date is required.", false);
                return;
            }

            DateTime startDate;
            if (!TryParseDate(startStr, out startDate))
            {
                ShowMessage("Please enter a valid Contract Start Date (YYYY-MM-DD).", false);
                return;
            }

            if (string.IsNullOrEmpty(endStr))
            {
                ShowMessage("Contract End Date is required.", false);
                return;
            }

            DateTime endDate;
            if (!TryParseDate(endStr, out endDate))
            {
                ShowMessage("Please enter a valid Contract End Date (YYYY-MM-DD).", false);
                return;
            }

            if (endDate <= startDate)
            {
                ShowMessage("Contract End Date must be after the Contract Start Date.", false);
                return;
            }

            if (string.IsNullOrEmpty(vendorIdStr))
            {
                ShowMessage("Please select a winning vendor.", false);
                return;
            }

            int vendorId = Convert.ToInt32(vendorIdStr);

             string gemId = txtContractGemId.Text.Trim();
            if (string.IsNullOrEmpty(gemId))
            {
                ShowMessage("GeM ID is required for starting a new contract.", false);
                return;
            }

            string datedOnStr = txtContractDatedOn.Text.Trim();
            if (string.IsNullOrEmpty(datedOnStr))
            {
                ShowMessage("Dated On is required for starting a new contract.", false);
                return;
            }
            DateTime datedOn;
            if (!TryParseDate(datedOnStr, out datedOn))
            {
                ShowMessage("Please enter a valid Dated On Date (YYYY-MM-DD).", false);
                return;
            }

            // ── Guard: block new contract if selected category already has an active contract period ──
            try
            {
                string activeCheckSql = @"
                    SELECT TierId, TO_CHAR(StartDate, 'DD-Mon-YYYY') AS StartLabel
                    FROM ContractPeriods
                    WHERE Status = 'Active' AND TierId = :TierId";
                DataTable dtActive = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), activeCheckSql, new OracleParameter("TierId", Convert.ToInt32(category)));
                if (dtActive != null && dtActive.Rows.Count > 0)
                {
                    string startLabel = dtActive.Rows[0]["StartLabel"].ToString();
                    string categoryName = Convert.ToString(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(),
                        "SELECT mc.Name || ' › ' || t.TierName FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = :TierId",
                        new OracleParameter("TierId", Convert.ToInt32(category)))) ?? category;
                    ShowMessage("Cannot start a new contract — the selected category " + categoryName + " (from " + startLabel + ") is still Active. Please end the current contract before creating a new one.", false);
                    return;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error checking active contracts: " + ex.Message, false);
                return;
            }
            // ── End Guard ────────────────────────────────────────────────────────────

            // Step 1 is valid, load Step 2
            lblMessage.Visible = false;
            lblSelectedStartDate.Text = string.Format("{0}: {1:dd-MMM-yyyy} to {2:dd-MMM-yyyy}", category, startDate, endDate);
            
            string selectedVendorName = ddlVendor.SelectedItem.Text;
            lblSelectedVendor.Text = selectedVendorName;
            string categoryNameText = Convert.ToString(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(),
                "SELECT mc.Name || ' › ' || t.TierName FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = :TierId",
                new OracleParameter("TierId", Convert.ToInt32(category)))) ?? category;
            lblEnrollCategoryTitle.Text = categoryNameText;
            lblEnrollVendorTitle.Text = selectedVendorName;

            // Save values in ViewState
            ViewState["SelectedCategory"] = category;
            ViewState["ContractStartDate"] = startDate;
            ViewState["ContractEndDate"] = endDate;
            ViewState["SelectedVendorId"] = vendorId;
            ViewState["SelectedVendorName"] = selectedVendorName;
            ViewState["ContractGemId"] = gemId;
            ViewState["ContractDatedOn"] = datedOn;

            // Set Step 2 Card Visibilities
            divEnrollCard.Visible = true;

            LoadEmployees();

            mvContracts.ActiveViewIndex = 1;
            stepHeader1.Attributes["class"] = "wizard-step completed";
            stepHeader2.Attributes["class"] = "wizard-step active";
        }

        private void LoadEmployees()
        {
            try
            {
                string category = ViewState["SelectedCategory"] as string;
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                string roleMode = Session["RoleMode"]?.ToString() ?? "";
                string adminCatCond = (roleMode == "PrimaryAdmin") ? "mc.AdminPCNO = :PCNO"
                    : (roleMode == "SecondaryAdmin") ? "(mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))"
                    : "(mc.AdminPCNO = :PCNO OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL) OR t.Id IN (SELECT sg.TierId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL))";

                // Retrieve all employees excluding resigned ones
                string query = $@"
                    SELECT e.MasterId, e.ID, e.Name, e.Department, e.TierId,
                           (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = e.TierId) AS Category,
                           e.Status 
                    FROM Employees e 
                    WHERE e.Status != 'System' AND e.Status != 'Resigned'
                      AND (
                          :IsSuper = 1
                          OR e.TierId IN (
                              SELECT t.Id 
                              FROM Tiers t
                              JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                              LEFT JOIN UserTiers ut ON t.Id = ut.TierId AND :Role = 0
                              WHERE (:Role = 4)
                                 OR (:Role = 1 AND {adminCatCond})
                                 OR (:Role = 0 AND ut.PCNO = :PCNO)
                          )
                      )
                    ORDER BY Name ASC";
                
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query,
                    new OracleParameter("IsSuper", (role == 4) ? 1 : 0),
                    new OracleParameter("Role", role),
                    new OracleParameter("PCNO", pcno));

                // Bind to Enrollment Grid
                gvEmployeesEnroll.DataSource = dt;
                gvEmployeesEnroll.DataBind();
                SetGridCheckboxes(gvEmployeesEnroll, dt, category);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading employees: " + ex.Message, false);
            }
        }

        private void SetGridCheckboxes(GridView gv, DataTable dt, string targetCategory)
        {
            for (int i = 0; i < gv.Rows.Count; i++)
            {
                GridViewRow row = gv.Rows[i];
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                if (chk != null)
                {
                    string empId = gv.DataKeys[i].Value.ToString();
                    DataRow[] foundRows = dt.Select("MasterId = '" + empId.Replace("'", "''") + "'");
                    if (foundRows.Length > 0)
                    {
                        int empTierId = Convert.ToInt32(foundRows[0]["TierId"]);
                        string status = foundRows[0]["Status"].ToString();
                        int targetTierId = Convert.ToInt32(targetCategory);
                        // Pre-check if they are active AND currently in this category/tier
                        chk.Checked = ((status == "Active" || status == "Upgraded" || status == "Downgraded" || status == "Transferred") && empTierId == targetTierId);
                    }
                }
            }
        }

        protected void btnPrevStep_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            mvContracts.ActiveViewIndex = 0;
            stepHeader1.Attributes["class"] = "wizard-step active";
            stepHeader2.Attributes["class"] = "wizard-step";
        }

        protected void btnModalSaveVendor_Click(object sender, EventArgs e)
        {
            string name = txtModalVendorName.Text.Trim();
            string contactsJson = hfModalVendorContacts.Value;

            if (string.IsNullOrEmpty(name))
            {
                ShowMessage("Vendor Name is required.", false, "addVendorModal");
                return;
            }

            var contacts = ParseContactsJson(contactsJson);
            if (contacts.Count == 0 || string.IsNullOrWhiteSpace(contacts[0].Name))
            {
                ShowMessage("Primary contact name is required.", false, "addVendorModal");
                return;
            }
            if (string.IsNullOrWhiteSpace(contacts[0].Phone))
            {
                ShowMessage("Primary contact phone is required.", false, "addVendorModal");
                return;
            }
            if (string.IsNullOrWhiteSpace(contacts[0].Email))
            {
                ShowMessage("Primary contact email is required.", false, "addVendorModal");
                return;
            }
            if (string.IsNullOrWhiteSpace(contacts[0].Address))
            {
                ShowMessage("Primary contact address is required.", false, "addVendorModal");
                return;
            }

            for (int i = 1; i < contacts.Count; i++)
            {
                if (string.IsNullOrWhiteSpace(contacts[i].Name))
                {
                    ShowMessage(string.Format("Level {0} contact name is required.", i + 1), false, "addVendorModal");
                    return;
                }
                if (string.IsNullOrWhiteSpace(contacts[i].Phone))
                {
                    ShowMessage(string.Format("Level {0} contact phone is required.", i + 1), false, "addVendorModal");
                    return;
                }
            }

            try
            {
                // Generate sequential Master ID
                string masterId = GenerateNextMasterId();

                // Verify unique MasterId (safety check)
                string checkMasterQuery = "SELECT COUNT(*) FROM Vendors WHERE UPPER(MasterId) = :MasterId";
                int countMaster = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkMasterQuery, 
                    new OracleParameter("MasterId", masterId.ToUpper())));
                if (countMaster > 0)
                {
                    ShowMessage("Auto-generated Vendor Master ID already exists. Please contact support.", false, "addVendorModal");
                    return;
                }

                // Validate uniqueness of vendor name
                string checkQuery = "SELECT COUNT(*) FROM Vendors WHERE UPPER(Name) = :Name";
                int nameCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery,
                    new OracleParameter("Name", name.ToUpper())));

                if (nameCount > 0)
                {
                    ShowMessage("A vendor with this name already exists. Please choose a unique name.", false, "addVendorModal");
                    return;
                }

                // Insert new vendor record (primary contact synced to legacy columns)
                string insertQuery = @"INSERT INTO Vendors (MasterId, Name, ContactName, ContactPhone, Address, IsActive) 
                                       VALUES (:MasterId, :Name, :ContactName, :ContactPhone, :Address, 1)";
                OracleParameter[] p = new OracleParameter[] {
                    new OracleParameter("MasterId", masterId),
                    new OracleParameter("Name", name),
                    new OracleParameter("ContactName", (object)contacts[0].Name ?? DBNull.Value),
                    new OracleParameter("ContactPhone", (object)contacts[0].Phone ?? DBNull.Value),
                    new OracleParameter("Address", (object)contacts[0].Address ?? DBNull.Value)
                };

                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery, p);

                // Get inserted vendor ID
                string newIdQuery = "SELECT Id FROM Vendors WHERE MasterId = :MasterId";
                int newVendorId = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), newIdQuery,
                    new OracleParameter("MasterId", masterId)));

                // Save all escalation contact rows into VendorContacts table
                SaveVendorContacts(newVendorId, contacts);

                // Preserve existing dropdown selection
                string selectedVendor = ddlVendor.SelectedValue;

                // Refresh dropdown
                BindVendors();

                // Restore previous selection if it exists
                if (ddlVendor.Items.FindByValue(selectedVendor) != null) ddlVendor.SelectedValue = selectedVendor;

                // Reset modal fields
                txtModalVendorName.Text = "";
                txtModalContactName.Text = "";
                txtModalContactPhone.Text = "";
                txtModalAddress.Text = "";
                hfModalVendorContacts.Value = "";

                ShowMessage("Vendor '" + name + "' added successfully with ID " + masterId + ".", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving vendor: " + ex.Message, false, "addVendorModal");
            }
        }

        // ── Modal escalation contacts helpers ─────────────────────────────────
        private class VendorContactEntry { public string Name; public string Phone; public string Email; public string Address; }

        private List<VendorContactEntry> ParseContactsJson(string json)
        {
            var list = new List<VendorContactEntry>();
            if (string.IsNullOrWhiteSpace(json)) return list;
            try
            {
                json = json.Trim();
                if (json.StartsWith("[")) json = json.Substring(1);
                if (json.EndsWith("]")) json = json.Substring(0, json.Length - 1);
                int depth = 0; int start = -1;
                for (int i = 0; i < json.Length; i++)
                {
                    char c = json[i];
                    if (c == '{') { if (depth == 0) start = i; depth++; }
                    else if (c == '}')
                    {
                        depth--;
                        if (depth == 0 && start != -1)
                        {
                            string obj = json.Substring(start, i - start + 1);
                            string name = ExtractJsonProp(obj, "name");
                            string phone = ExtractJsonProp(obj, "phone");
                            string email = ExtractJsonProp(obj, "email");
                            string addr = ExtractJsonProp(obj, "address");
                            if (!string.IsNullOrWhiteSpace(name) || !string.IsNullOrWhiteSpace(phone) || !string.IsNullOrWhiteSpace(email) || !string.IsNullOrWhiteSpace(addr))
                            {
                                list.Add(new VendorContactEntry { Name = name, Phone = phone, Email = email, Address = addr });
                            }
                            start = -1;
                        }
                    }
                }
            }
            catch { }
            return list;
        }

        private static string ExtractJsonProp(string obj, string propName)
        {
            string search = "\"" + propName + "\":\"";
            int idx = obj.IndexOf(search, StringComparison.OrdinalIgnoreCase);
            if (idx < 0) return "";
            idx += search.Length;
            int end = idx;
            while (end < obj.Length && !(obj[end] == '"' && (end == 0 || obj[end - 1] != '\\'))) end++;
            return System.Web.HttpUtility.HtmlDecode(obj.Substring(idx, end - idx));
        }

        private void SaveVendorContacts(int vendorId, List<VendorContactEntry> contacts)
        {
            string delSql = "DELETE FROM VendorContacts WHERE VendorId = :VendorId";
            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delSql, new OracleParameter("VendorId", vendorId));

            for (int i = 0; i < contacts.Count; i++)
            {
                var c = contacts[i];
                if (string.IsNullOrWhiteSpace(c.Name) && string.IsNullOrWhiteSpace(c.Phone)) continue;
                string ins = @"INSERT INTO VendorContacts (VendorId, Priority, ContactName, ContactPhone, ContactEmail, ContactAddress, SortOrder)
                               VALUES (:VendorId, :Priority, :ContactName, :ContactPhone, :ContactEmail, :ContactAddress, :SortOrder)";
                OracleParameter[] p = new OracleParameter[]
                {
                    new OracleParameter("VendorId", vendorId),
                    new OracleParameter("Priority", i + 1),
                    new OracleParameter("ContactName", string.IsNullOrEmpty(c.Name) ? (object)DBNull.Value : c.Name),
                    new OracleParameter("ContactPhone", string.IsNullOrEmpty(c.Phone) ? (object)DBNull.Value : c.Phone),
                    new OracleParameter("ContactEmail", string.IsNullOrEmpty(c.Email) ? (object)DBNull.Value : c.Email),
                    new OracleParameter("ContactAddress", string.IsNullOrEmpty(c.Address) ? (object)DBNull.Value : c.Address),
                    new OracleParameter("SortOrder", i + 1)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), ins, p);
            }
        }

        private string GenerateNextMasterId()
        {
            int maxVal = 0;
            try
            {
                string query = "SELECT MasterId FROM Vendors WHERE MasterId LIKE 'VND%'";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                foreach (DataRow row in dt.Rows)
                {
                    string mId = row["MasterId"].ToString();
                    if (mId.Length > 3)
                    {
                        int val;
                        if (int.TryParse(mId.Substring(3), out val))
                        {
                            if (val > maxVal)
                            {
                                maxVal = val;
                            }
                        }
                    }
                }
            }
            catch { }
            return "VND" + (maxVal + 1).ToString("D3");
        }

        private int GetCategoryRank(string categoryName)
        {
            if (string.IsNullOrEmpty(categoryName)) return 0;
            switch (categoryName.Trim().ToLower())
            {
                case "unskilled": return 1;
                case "semi-skilled":
                case "semiskilled": return 2;
                case "skilled": return 3;
                default: return 0;
            }
        }

        private bool ValidateActiveContractsForDifferentCategory(Dictionary<string, string> selectedEmployees, out string errorMessage)
        {
            errorMessage = "";
            try
            {
                if (selectedEmployees == null || selectedEmployees.Count == 0) return true;

                string query = @"
                    SELECT MasterId, Name, TierId, Status 
                    FROM Employees 
                    WHERE Status IN ('Active', 'Upgraded', 'Downgraded', 'Transferred')";

                DataTable dtActive = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                
                List<string> violatingEmployees = new List<string>();
                foreach (DataRow row in dtActive.Rows)
                {
                    string mId = row["MasterId"].ToString();
                    if (selectedEmployees.ContainsKey(mId))
                    {
                        int currentTierId = Convert.ToInt32(row["TierId"]);
                        int enrollTierId = Convert.ToInt32(selectedEmployees[mId]);
                        
                        if (currentTierId != enrollTierId)
                        {
                            string name = row["Name"].ToString();
                            string currentCatName = Convert.ToString(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), "SELECT mc.Name || ' › ' || t.TierName FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = :TierId", new OracleParameter("TierId", currentTierId))) ?? currentTierId.ToString();
                            string enrollCatName = Convert.ToString(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), "SELECT mc.Name || ' › ' || t.TierName FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = :TierId", new OracleParameter("TierId", enrollTierId))) ?? enrollTierId.ToString();
                            violatingEmployees.Add(string.Format("{0} ({1}) [Current: {2}, Target: {3}]", name, mId, currentCatName, enrollCatName));
                        }
                    }
                }

                if (violatingEmployees.Count > 0)
                {
                    errorMessage = "Validation Error: The following selected employees have an active contract going on in a different category. They cannot be enrolled in a new category unless their active contract has ended:\\n" + string.Join("\\n", violatingEmployees);
                    return false;
                }
            }
            catch (Exception ex)
            {
                errorMessage = "Error validating active contracts: " + ex.Message;
                return false;
            }
            return true;
        }

        protected void btnSaveContract_Click(object sender, EventArgs e)
        {
            string category = ViewState["SelectedCategory"] as string;
            var startDateVal = ViewState["ContractStartDate"];
            var vendorIdVal = ViewState["SelectedVendorId"];
            var vendorNameVal = ViewState["SelectedVendorName"];

            if (string.IsNullOrEmpty(category) || startDateVal == null || vendorIdVal == null || vendorNameVal == null)
            {
                ShowMessage("Validation Error: Wizard state has expired. Please restart the process.", false);
                return;
            }

            DateTime startDate = (DateTime)startDateVal;
            int vendorId = (int)vendorIdVal;
            string vendorName = (string)vendorNameVal;

            // Dictionary to store employee enrollments (MasterId -> Category)
            Dictionary<string, string> selectedEmployees = new Dictionary<string, string>();

            // Gather selected employees from the enrollment GridView
            foreach (GridViewRow row in gvEmployeesEnroll.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                if (chk != null && chk.Checked)
                {
                    string empId = gvEmployeesEnroll.DataKeys[row.RowIndex].Value.ToString();
                    selectedEmployees.Add(empId, category);
                }
            }

            string validationMsg = "";
            if (!ValidateActiveContractsForDifferentCategory(selectedEmployees, out validationMsg))
            {
                ShowMessage(validationMsg, false);
                return;
            }

            // Check if there are active employees WHO ARE CURRENTLY IN THIS CATEGORY but are NOT selected
            try
            {
                string query = "SELECT MasterId, ID, Name, TierId AS Category FROM Employees WHERE MasterId NOT LIKE 'GLOBAL%' AND Status <> 'System' AND Status IN ('Active', 'Upgraded', 'Downgraded', 'Transferred') AND TierId = :TierId";
                DataTable dtActive = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("TierId", Convert.ToInt32(category)));
                
                DataTable dtUnselected = dtActive.Clone();
                foreach (DataRow row in dtActive.Rows)
                {
                    string masterId = row["MasterId"].ToString();
                    if (!selectedEmployees.ContainsKey(masterId))
                    {
                        dtUnselected.ImportRow(row);
                    }
                }

                if (dtUnselected.Rows.Count > 0)
                {
                    // Bind to the unselected employees repeater
                    rptUnselectedEmployees.DataSource = dtUnselected;
                    rptUnselectedEmployees.DataBind();

                    // Show the modal
                    string modalScript = @"
                        var modalEl = document.getElementById('unselectedEmployeesModal');
                        if (modalEl) {
                            if (window.bootstrap && window.bootstrap.Modal) {
                                var modal = window.bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                                modal.show();
                            } else if (window.jQuery && window.jQuery.fn.modal) {
                                window.jQuery(modalEl).modal('show');
                            } else {
                                modalEl.classList.add('show');
                                modalEl.style.display = 'block';
                                document.body.classList.add('modal-open');
                            }
                        }";
                    ClientScript.RegisterStartupScript(this.GetType(), "showUnselectedModal", modalScript, true);
                    return;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error checking active employees: " + ex.Message, false);
                return;
            }

            // Transition to Step 3 if all active employees of this category are accounted for
            TransitionToStep3(selectedEmployees, new Dictionary<string, string>(), category, startDate, vendorId, vendorName);
        }

        private void TransitionToStep3(Dictionary<string, string> selectedEmployees, Dictionary<string, string> unselectedActions, string category, DateTime startDate, int vendorId, string vendorName)
        {
            lblMessage.Visible = false;
            // Save to ViewState
            ViewState["SelectedEmployees"] = selectedEmployees;
            ViewState["UnselectedActions"] = unselectedActions;
            ViewState["SelectedCategory"] = category;
            ViewState["ContractStartDate"] = startDate;
            ViewState["SelectedVendorId"] = vendorId;
            ViewState["SelectedVendorName"] = vendorName;

            // Load Step 3 Grids
            BindStep3Grids(selectedEmployees, category);

            // Transition MultiView
            mvContracts.ActiveViewIndex = 2;
            stepHeader1.Attributes["class"] = "wizard-step completed";
            stepHeader2.Attributes["class"] = "wizard-step completed";
            stepHeader3.Attributes["class"] = "wizard-step active";
        }

        private void BindStep3Grids(Dictionary<string, string> selectedEmployees, string category)
        {
            try
            {
                string catName = Convert.ToString(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(),
                    "SELECT mc.Name || ' › ' || t.TierName FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = :TierId",
                    new OracleParameter("TierId", Convert.ToInt32(category)))) ?? category;
                lblStep3CategoryTitle.Text = catName;

                // Retrieve all employee details to populate Step 3, excluding resigned ones
                string query = "SELECT MasterId, ID, Name, Department FROM Employees WHERE MasterId NOT LIKE 'GLOBAL%' AND Status != 'System' AND Status != 'Resigned' ORDER BY Name ASC";
                DataTable dtAll = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);

                var enrolledIds = new HashSet<string>(selectedEmployees.Where(x => x.Value == category).Select(x => x.Key));
                DataTable dtEnroll = dtAll.Clone();
                foreach (DataRow row in dtAll.Rows)
                {
                    if (enrolledIds.Contains(row["MasterId"].ToString()))
                        dtEnroll.ImportRow(row);
                }
                gvIdsEnroll.DataSource = dtEnroll;
                gvIdsEnroll.DataBind();
                lblSelectedCountEnroll.Text = dtEnroll.Rows.Count.ToString();
                divEnrollIdAlert.Visible = (dtEnroll.Rows.Count == 0);
                gvIdsEnroll.Visible = (dtEnroll.Rows.Count > 0);
            }
            catch (Exception ex)
            {
                ShowMessage("Error populating employee ID lists: " + ex.Message, false);
            }
        }

        protected void btnBackToStep2_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            mvContracts.ActiveViewIndex = 1;
            stepHeader1.Attributes["class"] = "wizard-step completed";
            stepHeader2.Attributes["class"] = "wizard-step active";
            stepHeader3.Attributes["class"] = "wizard-step";
        }

        protected void btnFinalizeContract_Click(object sender, EventArgs e)
        {
            // Restore ViewState variables
            var selectedEmployees = ViewState["SelectedEmployees"] as Dictionary<string, string>;
            var unselectedActions = ViewState["UnselectedActions"] as Dictionary<string, string>;
            var category = ViewState["SelectedCategory"] as string;
            var startDateVal = ViewState["ContractStartDate"];
            var endDateVal = ViewState["ContractEndDate"];
            var vendorIdVal = ViewState["SelectedVendorId"];
            var gemIdVal = ViewState["ContractGemId"];
            var datedOnVal = ViewState["ContractDatedOn"];

            if (selectedEmployees == null || string.IsNullOrEmpty(category) || startDateVal == null || endDateVal == null || vendorIdVal == null || gemIdVal == null || datedOnVal == null)
            {
                ShowMessage("Validation Error: Wizard state has expired. Please restart the process.", false);
                return;
            }

            DateTime startDate = (DateTime)startDateVal;
            DateTime endDate = (DateTime)endDateVal;
            int vendorId = (int)vendorIdVal;
            string gemId = (string)gemIdVal;
            DateTime datedOn = (DateTime)datedOnVal;

            Dictionary<string, string> employeeNewIds = new Dictionary<string, string>();
            
            // Validate and gather IDs based on selected category
            if (gvIdsEnroll.Visible)
            {
                HashSet<string> categoryIdsCheck = new HashSet<string>();
                foreach (GridViewRow row in gvIdsEnroll.Rows)
                {
                    TextBox txtId = (TextBox)row.FindControl("txtNewEmpId");
                    if (txtId != null)
                    {
                        string masterId = gvIdsEnroll.DataKeys[row.RowIndex].Value.ToString();
                        string newId = txtId.Text.Trim();
                        if (string.IsNullOrEmpty(newId))
                        {
                            ShowMessage("Validation Error: Employee ID is required for all enrolled employees.", false);
                            return;
                        }
                        if (!categoryIdsCheck.Add(newId))
                        {
                            ShowMessage("Validation Error: Duplicate Employee ID '" + newId + "' found in " + category + " category.", false);
                            return;
                        }
                        employeeNewIds.Add(masterId, newId);
                    }
                }
            }

            if (string.IsNullOrEmpty(txtInitialLeaveBalance.Text.Trim()))
            {
                ShowMessage("Validation Error: Please enter the initial leave balance. It can be 0 or greater, but it must be filled.", false);
                return;
            }

            float initialLeaveBalance = 0;
            if (!float.TryParse(txtInitialLeaveBalance.Text.Trim(), out initialLeaveBalance) || initialLeaveBalance < 0)
            {
                ShowMessage("Validation Error: Please enter a valid initial leave balance (0 or greater).", false);
                return;
            }

            // Execute actual save
            ExecuteSaveContract(selectedEmployees, unselectedActions, category, startDate, endDate, vendorId, gemId, datedOn, initialLeaveBalance, employeeNewIds);
        }

        protected void btnConfirmSave_Click(object sender, EventArgs e)
        {
            string category = ViewState["SelectedCategory"] as string;
            var startDateVal = ViewState["ContractStartDate"];
            var vendorIdVal = ViewState["SelectedVendorId"];
            var vendorNameVal = ViewState["SelectedVendorName"];

            if (string.IsNullOrEmpty(category) || startDateVal == null || vendorIdVal == null || vendorNameVal == null)
            {
                ShowMessage("Validation Error: Wizard state has expired. Please restart the process.", false);
                return;
            }

            DateTime startDate = (DateTime)startDateVal;
            int vendorId = (int)vendorIdVal;
            string vendorName = (string)vendorNameVal;

            // Dictionary to store employee enrollments (MasterId -> Category)
            Dictionary<string, string> selectedEmployees = new Dictionary<string, string>();

            // Gather selected employees from the enrollment GridView
            foreach (GridViewRow row in gvEmployeesEnroll.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                if (chk != null && chk.Checked)
                {
                    string empId = gvEmployeesEnroll.DataKeys[row.RowIndex].Value.ToString();
                    selectedEmployees.Add(empId, category);
                }
            }

            Dictionary<string, string> unselectedActions = new Dictionary<string, string>();
            // Read assignments from the modal repeater
            foreach (RepeaterItem item in rptUnselectedEmployees.Items)
            {
                if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
                {
                    HiddenField hfMasterId = (HiddenField)item.FindControl("hfMasterId");
                    DropDownList ddlUnselectedAction = (DropDownList)item.FindControl("ddlUnselectedAction");

                    if (hfMasterId != null && ddlUnselectedAction != null)
                    {
                        string masterId = hfMasterId.Value;
                        string actionVal = ddlUnselectedAction.SelectedValue;

                        if (actionVal != "ContractEnded" && actionVal != "Resigned")
                        {
                            if (!selectedEmployees.ContainsKey(masterId))
                            {
                                selectedEmployees.Add(masterId, actionVal);
                            }
                        }
                        else
                        {
                            unselectedActions[masterId] = actionVal;
                        }
                    }
                }
            }

            string validationMsg = "";
            if (!ValidateActiveContractsForDifferentCategory(selectedEmployees, out validationMsg))
            {
                ShowMessage(validationMsg, false);
                return;
            }

            // Transition to Step 3
            TransitionToStep3(selectedEmployees, unselectedActions, category, startDate, vendorId, vendorName);
        }

        private void ExecuteSaveContract(Dictionary<string, string> selectedEmployees, Dictionary<string, string> unselectedActions, string category, DateTime startDate, DateTime newContractEndDate, int vendorId, string gemId, DateTime datedOn, float initialLeaveBalance, Dictionary<string, string> employeeNewIds)
        {
            DateTime endDate = startDate.AddDays(-1);

            // Dictionary to hold active contract period info: Category -> Tuple<PeriodId, VendorId, StartDate>
            Dictionary<string, Tuple<int, int, DateTime>> activePeriods = new Dictionary<string, Tuple<int, int, DateTime>>();

            // Run Transaction on Oracle Database
            using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
            {
                conn.Open();
                using (OracleTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // Query previous active contract's EndDate (if any)
                        DateTime? oldContractEndDate = null;
                        string getOldCPDateSql = "SELECT EndDate FROM ContractPeriods WHERE TierId = :TierId AND Status = 'Active'";
                        using (OracleCommand cmd = new OracleCommand(getOldCPDateSql, conn))
                        {
                            cmd.Transaction = trans;
                            cmd.BindByName = true;
                            cmd.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(category)));
                            using (OracleDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read() && reader["EndDate"] != DBNull.Value)
                                {
                                    oldContractEndDate = Convert.ToDateTime(reader["EndDate"]);
                                }
                            }
                        }

                        // Determine the actual end date to use for closing the old period & engagements
                        DateTime actualOldEndDate = oldContractEndDate.HasValue ? oldContractEndDate.Value : endDate;

                        // 1. Close active contract period for the configured category
                        string closeOldContractSql = @"
                            UPDATE ContractPeriods 
                            SET EndDate = :EndDate, Status = 'Closed' 
                            WHERE TierId = :TierId AND Status = 'Active'";
                        
                        using (OracleCommand cmdClose = new OracleCommand(closeOldContractSql, conn))
                        {
                            cmdClose.Transaction = trans;
                            cmdClose.BindByName = true;
                            cmdClose.Parameters.Add(new OracleParameter("EndDate", actualOldEndDate));
                            cmdClose.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(category)));
                            cmdClose.ExecuteNonQuery();
                        }

                        // 2. Insert new ContractPeriod for the configured category
                        string insertNewContractSql = @"
                            INSERT INTO ContractPeriods (TierId, VendorId, GemId, StartDate, EndDate, DatedOn, Status) 
                            VALUES (:TierId, :VendorId, :GemId, :StartDate, :EndDate, :DatedOn, 'Active') 
                            RETURNING Id INTO :NewId";
                        
                        int newPeriodId = 0;
                        using (OracleCommand cmdInsert = new OracleCommand(insertNewContractSql, conn))
                        {
                            cmdInsert.Transaction = trans;
                            cmdInsert.BindByName = true;
                            cmdInsert.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(category)));
                            cmdInsert.Parameters.Add(new OracleParameter("VendorId", vendorId));
                            cmdInsert.Parameters.Add(new OracleParameter("GemId", string.IsNullOrEmpty(gemId) ? (object)DBNull.Value : gemId));
                            cmdInsert.Parameters.Add(new OracleParameter("StartDate", startDate));
                            cmdInsert.Parameters.Add(new OracleParameter("EndDate", newContractEndDate));
                            cmdInsert.Parameters.Add(new OracleParameter("DatedOn", datedOn));
                            
                            OracleParameter outParam = new OracleParameter("NewId", OracleDbType.Int32);
                            outParam.Direction = ParameterDirection.Output;
                            cmdInsert.Parameters.Add(outParam);
                            
                            cmdInsert.ExecuteNonQuery();
                            newPeriodId = Convert.ToInt32(outParam.Value.ToString());
                        }

                        // Save the new period info to activePeriods
                        activePeriods.Add(category, Tuple.Create(newPeriodId, vendorId, startDate));

                        // 3. Insert into ContractPeriodVendors for history
                        string insertCPVendorSql = @"
                            INSERT INTO ContractPeriodVendors (ContractPeriodId, VendorId, TierId, IsActive) 
                            VALUES (:ContractPeriodId, :VendorId, :TierId, 1)";
                        
                        using (OracleCommand cmdCPV = new OracleCommand(insertCPVendorSql, conn))
                        {
                            cmdCPV.Transaction = trans;
                            cmdCPV.BindByName = true;
                            cmdCPV.Parameters.Add(new OracleParameter("ContractPeriodId", newPeriodId));
                            cmdCPV.Parameters.Add(new OracleParameter("VendorId", vendorId));
                            cmdCPV.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(category)));
                            cmdCPV.ExecuteNonQuery();
                        }

                        // 4. Retrieve other categories' active contract periods from database
                        string getActiveSql = "SELECT Id, TierId, VendorId, StartDate FROM ContractPeriods WHERE Status = 'Active'";
                        using (OracleCommand cmd = new OracleCommand(getActiveSql, conn))
                        {
                            cmd.Transaction = trans;
                            using (OracleDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    string tid = reader["TierId"].ToString();
                                    activePeriods[tid] = Tuple.Create(
                                        Convert.ToInt32(reader["Id"]),
                                        Convert.ToInt32(reader["VendorId"]),
                                        Convert.ToDateTime(reader["StartDate"])
                                    );
                                }
                            }
                        }

                        // 5. Retrieve all employee records to process
                        string selectEmployeesSql = "SELECT MasterId, ID, Name, Department, TierId AS Category, Status, CurrentEngagementId, JoinDate FROM Employees WHERE Status != 'System'";
                        DataTable dtEmployees = new DataTable();
                        using (OracleCommand cmdSelect = new OracleCommand(selectEmployeesSql, conn))
                        {
                            cmdSelect.Transaction = trans;
                            using (OracleDataAdapter sda = new OracleDataAdapter(cmdSelect))
                            {
                                sda.Fill(dtEmployees);
                            }
                        }

                        var logsToCreate = new List<Tuple<string, string, string, string>>();

                        // 6. Iterate and process only selected/transitioned employees and unselected category employees
                        foreach (DataRow empRow in dtEmployees.Rows)
                        {
                            string masterId = empRow["MasterId"].ToString();
                            string empId = empRow["ID"].ToString();
                            string empDept = empRow["Department"] != DBNull.Value ? empRow["Department"].ToString() : "GENERAL";
                            string empStatus = empRow["Status"].ToString();
                            object currentEngagementIdVal = empRow["CurrentEngagementId"];

                            bool isSelected = selectedEmployees.ContainsKey(masterId);
                            bool isUnselectedAction = unselectedActions.ContainsKey(masterId);

                            // Skip employees that are not part of the active category configuration or transition actions
                            if (!isSelected && !isUnselectedAction)
                                continue;

                            if (isSelected)
                            {
                                string targetCategory = selectedEmployees[masterId];
                                if (!activePeriods.ContainsKey(targetCategory))
                                {
                                    throw new Exception("Cannot enroll/transition employee " + masterId + " to category '" + targetCategory + "' because there is no active contract period configured for it.");
                                }

                                var targetPeriod = activePeriods[targetCategory];
                                int targetPeriodId = targetPeriod.Item1;
                                int targetVendorId = targetPeriod.Item2;
                                DateTime cpStartDate = targetPeriod.Item3;

                                DateTime targetStartDate = cpStartDate;
                                if (empRow["JoinDate"] != DBNull.Value)
                                {
                                    DateTime empJoinDate = Convert.ToDateTime(empRow["JoinDate"]);
                                    if (empJoinDate > cpStartDate)
                                    {
                                        targetStartDate = empJoinDate;
                                    }
                                }

                                string prevCategory = empRow["Category"].ToString();
                                DateTime targetEndDateForOld = (prevCategory == category) ? actualOldEndDate : startDate.AddDays(-1);

                                string empStatusText = "Active";
                                string endReasonText = "ContractEnd";

                                if (!string.IsNullOrEmpty(prevCategory) && prevCategory != targetCategory)
                                {
                                    int prevRank = GetCategoryRank(prevCategory);
                                    int targetRank = GetCategoryRank(targetCategory);

                                    if (targetRank > prevRank)
                                    {
                                        empStatusText = "Active";
                                        endReasonText = "Upgraded";
                                    }
                                    else if (targetRank < prevRank)
                                    {
                                        empStatusText = "Active";
                                        endReasonText = "Downgraded";
                                    }
                                    else
                                    {
                                        empStatusText = "Active";
                                        endReasonText = "Transferred";
                                    }
                                }

                                string preState = ActionLogger.CaptureEmployeeState(masterId);

                                int? prevEngagementId = null;
                                if (currentEngagementIdVal != DBNull.Value)
                                {
                                    prevEngagementId = Convert.ToInt32(currentEngagementIdVal);

                                    // Close previous engagement
                                    string closeOldEngagementSql = @"
                                        UPDATE EmployeeEngagements 
                                        SET EndDate = :EndDate, EndReason = :EndReason 
                                        WHERE Id = :OldEngagementId AND EndDate IS NULL";
                                    using (OracleCommand cmdCloseEng = new OracleCommand(closeOldEngagementSql, conn))
                                    {
                                        cmdCloseEng.Transaction = trans;
                                        cmdCloseEng.BindByName = true;
                                        cmdCloseEng.Parameters.Add(new OracleParameter("EndDate", targetEndDateForOld));
                                        cmdCloseEng.Parameters.Add(new OracleParameter("EndReason", endReasonText));
                                        cmdCloseEng.Parameters.Add(new OracleParameter("OldEngagementId", prevEngagementId.Value));
                                        cmdCloseEng.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    // Fallback: Query the last closed engagement to set as PrevEngagementId to maintain history
                                    string lastEngSql = @"
                                        SELECT Id FROM (
                                            SELECT Id FROM EmployeeEngagements 
                                            WHERE EmpID = :MasterId 
                                            ORDER BY StartDate DESC, Id DESC
                                        ) WHERE ROWNUM = 1";
                                    using (OracleCommand cmdLastEng = new OracleCommand(lastEngSql, conn))
                                    {
                                        cmdLastEng.Transaction = trans;
                                        cmdLastEng.BindByName = true;
                                        cmdLastEng.Parameters.Add(new OracleParameter("MasterId", masterId));
                                        object lastEngVal = cmdLastEng.ExecuteScalar();
                                        if (lastEngVal != null && lastEngVal != DBNull.Value)
                                        {
                                            prevEngagementId = Convert.ToInt32(lastEngVal);
                                        }
                                    }
                                }

                                // Insert new engagement
                                string insertNewEngagementSql = @"
                                    INSERT INTO EmployeeEngagements (EmpID, ContractPeriodId, TierId, VendorId, Department, StartDate, IsCarriedOver, PrevEngagementId, EmployeeId) 
                                    VALUES (:EmpID, :ContractPeriodId, :TierId, :VendorId, :Department, :StartDate, 1, :PrevEngagementId, :EmployeeId) 
                                    RETURNING Id INTO :NewEngagementId";
                                
                                int newEngagementId = 0;
                                using (OracleCommand cmdInsertEng = new OracleCommand(insertNewEngagementSql, conn))
                                {
                                    cmdInsertEng.Transaction = trans;
                                    cmdInsertEng.BindByName = true;
                                    cmdInsertEng.Parameters.Add(new OracleParameter("EmpID", masterId));
                                    cmdInsertEng.Parameters.Add(new OracleParameter("ContractPeriodId", targetPeriodId));
                                    cmdInsertEng.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(targetCategory)));
                                    cmdInsertEng.Parameters.Add(new OracleParameter("VendorId", targetVendorId));
                                    cmdInsertEng.Parameters.Add(new OracleParameter("Department", string.IsNullOrEmpty(empDept) ? (object)DBNull.Value : empDept));
                                    cmdInsertEng.Parameters.Add(new OracleParameter("StartDate", targetStartDate));
                                    cmdInsertEng.Parameters.Add(new OracleParameter("PrevEngagementId", prevEngagementId.HasValue ? (object)prevEngagementId.Value : DBNull.Value));
                                    string newEmpId = (employeeNewIds != null && employeeNewIds.ContainsKey(masterId)) ? employeeNewIds[masterId] : empId;
                                    cmdInsertEng.Parameters.Add(new OracleParameter("EmployeeId", newEmpId));
 
                                    OracleParameter outParam = new OracleParameter("NewEngagementId", OracleDbType.Int32);
                                    outParam.Direction = ParameterDirection.Output;
                                    cmdInsertEng.Parameters.Add(outParam);
 
                                    cmdInsertEng.ExecuteNonQuery();
                                    newEngagementId = Convert.ToInt32(outParam.Value.ToString());
                                }

                                // Update employee master record with new category-specific ID and engagement
                                string updateEmployeeSql = @"
                                    UPDATE Employees 
                                    SET CurrentEngagementId = :CurrentEngagementId, 
                                        JoinDate = NVL(JoinDate, :JoinDate), 
                                        TierId = :TierId, 
                                        ID = :NewEmpID,
                                        Status = :Status, 
                                        ResignDate = NULL,
                                        ContractEndDate = NULL,
                                        PrevLeaveBalance = LeaveBalance,
                                        LeaveBalance = :LeaveBalance
                                    WHERE MasterId = :MasterId";
                                
                                using (OracleCommand cmdUpdateEmp = new OracleCommand(updateEmployeeSql, conn))
                                {
                                    cmdUpdateEmp.Transaction = trans;
                                    cmdUpdateEmp.BindByName = true;
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("CurrentEngagementId", newEngagementId));
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("JoinDate", targetStartDate));
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(targetCategory)));
                                    string newEmpId = (employeeNewIds != null && employeeNewIds.ContainsKey(masterId)) ? employeeNewIds[masterId] : empId;
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("NewEmpID", newEmpId));
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("Status", empStatusText));
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("LeaveBalance", initialLeaveBalance));
                                    cmdUpdateEmp.Parameters.Add(new OracleParameter("MasterId", masterId));
                                    cmdUpdateEmp.ExecuteNonQuery();
                                }

                                // Record the initial contract balance credit
                                string insertCreditSql = @"
                                    INSERT INTO EmployeeLeaveCredits (EmpID, ContractPeriodId, Amount, EffectiveDate, Remarks)
                                    VALUES (:EmpID, :CpId, :Amount, :EffectiveDate, 'Contract Initial Balance')";
                                using (OracleCommand cmdInsCredit = new OracleCommand(insertCreditSql, conn))
                                {
                                    cmdInsCredit.Transaction = trans;
                                    cmdInsCredit.BindByName = true;
                                    cmdInsCredit.Parameters.Add(new OracleParameter("EmpID", masterId));
                                    cmdInsCredit.Parameters.Add(new OracleParameter("CpId", targetPeriodId));
                                    cmdInsCredit.Parameters.Add(new OracleParameter("Amount", initialLeaveBalance));
                                    cmdInsCredit.Parameters.Add(new OracleParameter("EffectiveDate", targetStartDate));
                                    cmdInsCredit.ExecuteNonQuery();
                                }

                                string actType = "EDIT";
                                string desc = "Enrolled employee " + empRow["Name"].ToString() + " into active contract.";

                                logsToCreate.Add(Tuple.Create(masterId, actType, desc, preState));
                            }
                            else if (isUnselectedAction)
                            {
                                string action = unselectedActions[masterId];
                                DateTime oldCatEndDate = actualOldEndDate;

                                if (empStatus == "Active" || empStatus == "Upgraded" || empStatus == "Downgraded" || empStatus == "Transferred")
                                {
                                    string preState = ActionLogger.CaptureEmployeeState(masterId);

                                    if (currentEngagementIdVal != DBNull.Value)
                                    {
                                        int prevEngagementId = Convert.ToInt32(currentEngagementIdVal);

                                        // Close previous engagement
                                        string closeOldEngagementSql = @"
                                            UPDATE EmployeeEngagements 
                                            SET EndDate = :EndDate, EndReason = :EndReason 
                                            WHERE Id = :OldEngagementId AND EndDate IS NULL";
                                        using (OracleCommand cmdCloseEng = new OracleCommand(closeOldEngagementSql, conn))
                                        {
                                            cmdCloseEng.Transaction = trans;
                                            cmdCloseEng.BindByName = true;
                                            cmdCloseEng.Parameters.Add(new OracleParameter("EndDate", oldCatEndDate));
                                            cmdCloseEng.Parameters.Add(new OracleParameter("EndReason", action == "Resigned" ? "Resigned" : "ContractEnd"));
                                            cmdCloseEng.Parameters.Add(new OracleParameter("OldEngagementId", prevEngagementId));
                                            cmdCloseEng.ExecuteNonQuery();
                                        }
                                    }

                                    if (action == "Resigned")
                                    {
                                        // Update employee master to Resigned status and record ResignDate
                                        string updateEmployeeResignSql = @"
                                            UPDATE Employees 
                                            SET CurrentEngagementId = NULL, 
                                                Status = 'Resigned', 
                                                ResignDate = :ResignDate, 
                                                ContractEndDate = NULL 
                                            WHERE MasterId = :MasterId";
                                        using (OracleCommand cmdUpdateEmpRes = new OracleCommand(updateEmployeeResignSql, conn))
                                        {
                                            cmdUpdateEmpRes.Transaction = trans;
                                            cmdUpdateEmpRes.BindByName = true;
                                            cmdUpdateEmpRes.Parameters.Add(new OracleParameter("ResignDate", oldCatEndDate));
                                            cmdUpdateEmpRes.Parameters.Add(new OracleParameter("MasterId", masterId));
                                            cmdUpdateEmpRes.ExecuteNonQuery();
                                        }
                                    }
                                    else
                                    {
                                        // Update employee master to set ContractEnded, record ContractEndDate and clear CurrentEngagementId
                                        string updateEmployeeContractEndSql = @"
                                            UPDATE Employees 
                                            SET CurrentEngagementId = NULL, 
                                                ContractEndDate = :ContractEndDate,
                                                Status = 'ContractEnded',
                                                ResignDate = NULL 
                                            WHERE MasterId = :MasterId";
                                        using (OracleCommand cmdUpdateEmpRes = new OracleCommand(updateEmployeeContractEndSql, conn))
                                        {
                                            cmdUpdateEmpRes.Transaction = trans;
                                            cmdUpdateEmpRes.BindByName = true;
                                            cmdUpdateEmpRes.Parameters.Add(new OracleParameter("ContractEndDate", oldCatEndDate));
                                            cmdUpdateEmpRes.Parameters.Add(new OracleParameter("MasterId", masterId));
                                            cmdUpdateEmpRes.ExecuteNonQuery();
                                        }
                                    }

                                    string actType = action == "Resigned" ? "RESIGN" : "CONTRACT_END";
                                    string desc = action == "Resigned" 
                                        ? "Marked employee " + empRow["Name"].ToString() + " as resigned." 
                                        : "Ended contract for employee " + empRow["Name"].ToString() + ".";

                                    logsToCreate.Add(Tuple.Create(masterId, actType, desc, preState));
                                }
                            }
                        }

                        trans.Commit();

                        // Write logs to action history after successful commit
                        foreach (var logInfo in logsToCreate)
                        {
                            try
                            {
                                string postState = ActionLogger.CaptureEmployeeState(logInfo.Item1);
                                ActionLogger.LogAction(logInfo.Item2, logInfo.Item1, logInfo.Item3, logInfo.Item4, postState);
                            }
                            catch (Exception exLog)
                            {
                                System.Diagnostics.Debug.WriteLine("Error logging contract wizard transition: " + exLog.Message);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ShowMessage("Database error during contract activation: " + ex.Message, false);
                        return;
                    }
                }
            }

            // Redirect on success
            Response.Redirect("Dashboard.aspx?msg=ContractActivated");
        }

        private void ShowMessage(string msg, bool success)
        {
            ShowMessage(msg, success, null);
        }

        private void ShowMessage(string msg, bool success, string showModalId)
        {
            string script = "";

            if (!string.IsNullOrEmpty(msg))
            {
                lblMessage.Text = msg;
                lblMessage.Visible = true;
                lblMessage.CssClass = "alert d-block " + (success ? "alert-success" : "alert-danger");

                string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                string toastType = success ? "success" : "error";
                script = string.Format("showToast('{0}', '{1}');", cleanMessage, toastType);
            }
            else
            {
                lblMessage.Visible = false;
            }

            if (!string.IsNullOrEmpty(showModalId))
            {
                script += string.Format(@"
                    var modalEl = document.getElementById('{0}');
                    if (modalEl) {{
                        if (window.bootstrap && window.bootstrap.Modal) {{
                            var modal = window.bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                            modal.show();
                        }} else if (window.jQuery && window.jQuery.fn.modal) {{
                            window.jQuery(modalEl).modal('show');
                        }} else {{
                            modalEl.classList.add('show');
                            modalEl.style.display = 'block';
                            document.body.classList.add('modal-open');
                        }}
                    }}", showModalId);
            }

            if (!string.IsNullOrEmpty(script))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
            }
        }

        private bool TryParseDate(string dateStr, out DateTime parsedDate)
        {
            if (string.IsNullOrEmpty(dateStr))
            {
                parsedDate = DateTime.MinValue;
                return false;
            }

            // Try standard parse
            if (DateTime.TryParse(dateStr, out parsedDate))
            {
                return true;
            }

            // Try explicit format yyyy-MM-dd (HTML5 date input format)
            if (DateTime.TryParseExact(dateStr, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out parsedDate))
            {
                return true;
            }

            // Try common culture formats (Indian, UK, US formats)
            string[] formats = new string[] { "yyyy-MM-dd", "dd-MM-yyyy", "dd/MM/yyyy", "MM/dd/yyyy", "d/M/yyyy", "yyyy/MM/dd" };
            if (DateTime.TryParseExact(dateStr, formats, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out parsedDate))
            {
                return true;
            }

            return false;
        }

        protected void btnConfigureNew_Click(object sender, EventArgs e)
        {
            pnlWizard.Visible = true;
            mvContracts.ActiveViewIndex = 0;
            stepHeader1.Attributes["class"] = "wizard-step active";
            stepHeader2.Attributes["class"] = "wizard-step";
            stepHeader3.Attributes["class"] = "wizard-step";

            // Clear inputs
            ddlCategory.SelectedIndex = 0;
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            ddlVendor.SelectedIndex = 0;
            txtContractGemId.Text = "";
            txtContractDatedOn.Text = "";
            txtInitialLeaveBalance.Text = "";
            lblMessage.Visible = false;
        }

        protected void btnCancelWizard_Click(object sender, EventArgs e)
        {
            pnlWizard.Visible = false;
            mvContracts.ActiveViewIndex = 0;
            stepHeader1.Attributes["class"] = "wizard-step active";
            stepHeader2.Attributes["class"] = "wizard-step";
            stepHeader3.Attributes["class"] = "wizard-step";

            // Clear inputs
            ddlCategory.SelectedIndex = 0;
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            ddlVendor.SelectedIndex = 0;
            txtContractGemId.Text = "";
            txtContractDatedOn.Text = "";
            txtInitialLeaveBalance.Text = "";
            lblMessage.Visible = false;
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (divContractsHistory != null && pnlWizard != null)
            {
                divContractsHistory.Visible = !pnlWizard.Visible;
            }
            if (btnConfigureNew != null && pnlWizard != null)
            {
                btnConfigureNew.Visible = !pnlWizard.Visible;
            }
        }

        #region Manage Employees Modal

        protected void rptContractPeriods_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ManageEmployees")
            {
                int contractPeriodId = Convert.ToInt32(e.CommandArgument);
                OpenManageEmployeesModal(contractPeriodId);
            }
        }

        private void OpenManageEmployeesModal(int contractPeriodId)
        {
            try
            {
                hfManageContractPeriodId.Value = contractPeriodId.ToString();

                // Fetch Contract Period Details
                string queryCP = @"
                    SELECT (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = cp.TierId) AS Category,
                           cp.TierId, cp.StartDate, cp.Status, cp.GemId, v.Name AS VendorName 
                    FROM ContractPeriods cp
                    JOIN Vendors v ON cp.VendorId = v.Id
                    WHERE cp.Id = :PeriodId";
                DataTable dtCP = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryCP, new OracleParameter("PeriodId", contractPeriodId));
                if (dtCP.Rows.Count == 0)
                {
                    ShowMessage("Contract period not found.", false);
                    return;
                }

                DataRow dr = dtCP.Rows[0];
                string category = dr["Category"].ToString();
                string tierIdStr = dr["TierId"].ToString();
                DateTime startDate = Convert.ToDateTime(dr["StartDate"]);
                string vendorName = dr["VendorName"].ToString();
                string gemId = dr["GemId"] != DBNull.Value ? dr["GemId"].ToString() : "";

                lblManageContractTitle.Text = category + " Contract Period";
                lblManageContractVendor.Text = vendorName;
                lblManageContractGemId.Text = string.IsNullOrEmpty(gemId) ? "—" : gemId;
                lblManageContractStart.Text = startDate.ToString("dd-MMM-yyyy");

                // Bind enrolled employees GridView
                BindManageEnrolledEmployees(contractPeriodId);

                // Bind candidate employees dropdown
                BindManageCandidates(tierIdStr, contractPeriodId);

                // Show the modal
                ShowMessage("", true, "manageEmployeesModal");
            }
            catch (Exception ex)
            {
                ShowMessage("Error opening manage employees: " + ex.Message, false);
            }
        }

        private void BindManageEnrolledEmployees(int contractPeriodId)
        {
            string query = @"
                SELECT e.MasterId, e.ID, e.Name, e.Department 
                FROM Employees e
                JOIN EmployeeEngagements ee ON e.CurrentEngagementId = ee.Id
                WHERE ee.ContractPeriodId = :PeriodId
                ORDER BY e.Name ASC";
            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PeriodId", contractPeriodId));
            gvManageEnrolledEmployees.DataSource = dt;
            gvManageEnrolledEmployees.DataBind();
        }

        private void BindManageCandidates(string category, int contractPeriodId)
        {
            // Fetch employees in this category that are not currently active in any contract period
            string query = @"
                SELECT MasterId, ID || ' - ' || Name AS DisplayName 
                FROM Employees 
                WHERE TierId = :TierId 
                  AND Status != 'System'
                  AND MasterId NOT LIKE 'GLOBAL%'
                  AND (CurrentEngagementId IS NULL OR Status NOT IN ('Active', 'Upgraded', 'Downgraded', 'Transferred')) 
                ORDER BY Name ASC";
            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("TierId", Convert.ToInt32(category)));
            
            ddlManageAddEmployee.Items.Clear();
            ddlManageAddEmployee.Items.Add(new ListItem("-- Select Employee --", ""));
            foreach (DataRow row in dt.Rows)
            {
                ddlManageAddEmployee.Items.Add(new ListItem(row["DisplayName"].ToString(), row["MasterId"].ToString()));
            }
        }

        protected void btnManageAddEmployee_Click(object sender, EventArgs e)
        {
            string empMasterId = ddlManageAddEmployee.SelectedValue;
            string periodIdStr = hfManageContractPeriodId.Value;

            if (string.IsNullOrEmpty(empMasterId))
            {
                ShowMessage("Please select an employee to add.", false, "manageEmployeesModal");
                return;
            }

            int periodId = Convert.ToInt32(periodIdStr);

            try
            {
                // Retrieve employee current details
                string empQuery = "SELECT ID, Name, Department, TierId, JoinDate, Status FROM Employees WHERE MasterId = :MasterId";
                DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, new OracleParameter("MasterId", empMasterId));
                if (dtEmp.Rows.Count == 0)
                {
                    ShowMessage("Employee not found.", false, "manageEmployeesModal");
                    return;
                }

                DataRow drEmp = dtEmp.Rows[0];
                string empId = drEmp["ID"].ToString();
                string name = drEmp["Name"].ToString();
                string dept = drEmp["Department"].ToString();
                string cat = drEmp["TierId"].ToString();
                string empStatus = drEmp["Status"].ToString();

                // Retrieve contract details
                string cpQuery = "SELECT VendorId, StartDate FROM ContractPeriods WHERE Id = :PeriodId";
                DataTable dtCP = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), cpQuery, new OracleParameter("PeriodId", periodId));
                if (dtCP.Rows.Count == 0)
                {
                    ShowMessage("Contract period not found.", false, "manageEmployeesModal");
                    return;
                }

                int vendorId = Convert.ToInt32(dtCP.Rows[0]["VendorId"]);
                DateTime cpStartDate = Convert.ToDateTime(dtCP.Rows[0]["StartDate"]);

                // Parse user input start/rejoin date
                DateTime? userInputStartDate = null;
                if (!string.IsNullOrEmpty(txtManageAddStartDate.Text))
                {
                    DateTime parsedDate;
                    if (DateTime.TryParse(txtManageAddStartDate.Text, out parsedDate))
                    {
                        userInputStartDate = parsedDate;
                    }
                }

                DateTime engagementStartDate = cpStartDate;
                bool updateJoinDate = false;

                if (empStatus == "Resigned")
                {
                    if (!userInputStartDate.HasValue)
                    {
                        ShowMessage("Employee is currently Resigned. Please enter a valid Rejoin/Start Date.", false, "manageEmployeesModal");
                        return;
                    }

                    DateTime resolvedRejoinDate = userInputStartDate.Value;
                    if (resolvedRejoinDate < cpStartDate)
                    {
                        resolvedRejoinDate = cpStartDate;
                    }
                    engagementStartDate = resolvedRejoinDate;
                    updateJoinDate = true;
                }
                else
                {
                    if (userInputStartDate.HasValue)
                    {
                        DateTime resolvedDate = userInputStartDate.Value;
                        if (resolvedDate < cpStartDate)
                        {
                            resolvedDate = cpStartDate;
                        }
                        engagementStartDate = resolvedDate;
                        updateJoinDate = true;
                    }
                    else
                    {
                        if (drEmp["JoinDate"] != DBNull.Value)
                        {
                            DateTime empJoinDate = Convert.ToDateTime(drEmp["JoinDate"]);
                            if (empJoinDate > cpStartDate)
                            {
                                engagementStartDate = empJoinDate;
                            }
                        }
                        else
                        {
                            updateJoinDate = true;
                        }
                    }
                }

                // Capture employee pre-state
                string preState = ActionLogger.CaptureEmployeeState(empMasterId);

                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // Create new engagement
                            string sql = @"
                                INSERT INTO EmployeeEngagements (EmpID, ContractPeriodId, TierId, VendorId, Department, StartDate, IsCarriedOver, EmployeeId) 
                                VALUES (:EmpID, :ContractPeriodId, :TierId, :VendorId, :Department, :StartDate, 1, :EmployeeId)
                                RETURNING Id INTO :NewId";
                            
                            int newEngId = 0;
                            using (OracleCommand cmd = new OracleCommand(sql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                cmd.Parameters.Add(new OracleParameter("ContractPeriodId", periodId));
                                cmd.Parameters.Add(new OracleParameter("TierId", Convert.ToInt32(cat)));
                                cmd.Parameters.Add(new OracleParameter("VendorId", vendorId));
                                cmd.Parameters.Add(new OracleParameter("Department", dept));
                                cmd.Parameters.Add(new OracleParameter("StartDate", engagementStartDate));
                                cmd.Parameters.Add(new OracleParameter("EmployeeId", empId));
                                
                                OracleParameter outParam = new OracleParameter("NewId", OracleDbType.Int32);
                                outParam.Direction = ParameterDirection.Output;
                                cmd.Parameters.Add(outParam);
                                
                                cmd.ExecuteNonQuery();
                                newEngId = Convert.ToInt32(outParam.Value.ToString());
                            }

                            // Update employee
                            string updateEmp = @"
                                UPDATE Employees 
                                SET CurrentEngagementId = :EngId, 
                                    Status = 'Active', 
                                    ResignDate = NULL, 
                                    ContractEndDate = NULL" +
                                    (updateJoinDate ? ", JoinDate = :JoinDate, OriginalJoinDate = NVL(OriginalJoinDate, JoinDate)" : "") +
                                " WHERE MasterId = :MasterId";
                            using (OracleCommand cmd = new OracleCommand(updateEmp, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.BindByName = true;
                                cmd.Parameters.Add(new OracleParameter("EngId", newEngId));
                                if (updateJoinDate)
                                {
                                    cmd.Parameters.Add(new OracleParameter("JoinDate", engagementStartDate));
                                }
                                cmd.Parameters.Add(new OracleParameter("MasterId", empMasterId));
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();
                        }
                        catch (Exception exTrans)
                        {
                            trans.Rollback();
                            throw exTrans;
                        }
                    }
                }

                // Log the action
                string postState = ActionLogger.CaptureEmployeeState(empMasterId);
                ActionLogger.LogAction("EDIT", empMasterId, "Enrolled employee " + name + " into active " + cat + " contract manually.", preState, postState);

                // Refresh grids
                BindManageEnrolledEmployees(periodId);
                BindManageCandidates(cat, periodId);
                BindContractsHistory();
                txtManageAddStartDate.Text = "";

                ShowMessage("Employee " + name + " successfully added to the contract.", true, "manageEmployeesModal");
            }
            catch (Exception ex)
            {
                ShowMessage("Error adding employee: " + ex.Message, false, "manageEmployeesModal");
            }
        }

        protected void btnUpdateAllIds_Click(object sender, EventArgs e)
        {
            int periodId = Convert.ToInt32(hfManageContractPeriodId.Value);

            try
            {
                // 1. Fetch category (TierId) of this contract period
                int tierId = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(),
                    "SELECT TierId FROM ContractPeriods WHERE Id = :PeriodId",
                    new OracleParameter("PeriodId", periodId)));
                string category = tierId.ToString();

                // 2. Gather new IDs and check for duplicates within the grid itself
                Dictionary<string, string> newIds = new Dictionary<string, string>();
                HashSet<string> gridIdsCheck = new HashSet<string>();
                List<string> gridMasterIds = new List<string>();

                foreach (GridViewRow row in gvManageEnrolledEmployees.Rows)
                {
                    string masterId = gvManageEnrolledEmployees.DataKeys[row.RowIndex].Value.ToString();
                    TextBox txtGridEmpID = (TextBox)row.FindControl("txtGridEmpID");
                    if (txtGridEmpID != null)
                    {
                        string newId = txtGridEmpID.Text.Trim();
                        if (string.IsNullOrEmpty(newId))
                        {
                            ShowMessage("Validation Error: Employee ID cannot be empty.", false, "manageEmployeesModal");
                            return;
                        }

                        if (!gridIdsCheck.Add(newId))
                        {
                            ShowMessage("Validation Error: Duplicate Employee ID '" + newId + "' found in the grid.", false, "manageEmployeesModal");
                            return;
                        }

                        newIds[masterId] = newId;
                        gridMasterIds.Add(masterId);
                    }
                }

                if (newIds.Count == 0)
                {
                    ShowMessage("No employee IDs found to update.", true, "manageEmployeesModal");
                    return;
                }

                // 3. Query the database to check if any new ID is taken by an employee OUTSIDE this contract period / grid
                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    
                    foreach (var kvp in newIds)
                    {
                        string targetMasterId = kvp.Key;
                        string targetNewId = kvp.Value;

                        string checkSql = @"
                            SELECT COUNT(*) FROM Employees 
                            WHERE ID = :ID 
                              AND TierId = :TierId 
                              AND Status IN ('Active', 'Upgraded', 'Downgraded', 'ContractEnded', 'Transferred') 
                              AND MasterId NOT IN (" + string.Join(",", gridMasterIds.Select(id => "'" + id.Replace("'", "''") + "'")) + ")";
                        
                        using (OracleCommand cmdCheck = new OracleCommand(checkSql, conn))
                        {
                            cmdCheck.BindByName = true;
                            cmdCheck.Parameters.Add(new OracleParameter("ID", targetNewId));
                            cmdCheck.Parameters.Add(new OracleParameter("TierId", tierId));
                            int count = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (count > 0)
                            {
                                string categoryName = Convert.ToString(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), "SELECT mc.Name || ' › ' || t.TierName FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = :TierId", new OracleParameter("TierId", tierId))) ?? category;
                                ShowMessage("Validation Error: Employee ID '" + targetNewId + "' is already assigned to another active employee in the '" + categoryName + "' category.", false, "manageEmployeesModal");
                                return;
                            }
                        }
                    }

                    // 4. Update the database inside a single transaction
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            foreach (var kvp in newIds)
                            {
                                string targetMasterId = kvp.Key;
                                string targetNewId = kvp.Value;

                                // Update Employees master table
                                string updateEmpSql = "UPDATE Employees SET ID = :NewId WHERE MasterId = :MasterId";
                                using (OracleCommand cmdEmp = new OracleCommand(updateEmpSql, conn))
                                {
                                    cmdEmp.Transaction = trans;
                                    cmdEmp.Parameters.Add(new OracleParameter("NewId", targetNewId));
                                    cmdEmp.Parameters.Add(new OracleParameter("MasterId", targetMasterId));
                                    cmdEmp.ExecuteNonQuery();
                                }

                                // Update active/open EmployeeEngagements
                                string updateEngSql = "UPDATE EmployeeEngagements SET EmployeeId = :NewId WHERE EmpID = :MasterId AND ContractPeriodId = :PeriodId AND EndDate IS NULL";
                                using (OracleCommand cmdEng = new OracleCommand(updateEngSql, conn))
                                {
                                    cmdEng.Transaction = trans;
                                    cmdEng.Parameters.Add(new OracleParameter("NewId", targetNewId));
                                    cmdEng.Parameters.Add(new OracleParameter("MasterId", targetMasterId));
                                    cmdEng.Parameters.Add(new OracleParameter("PeriodId", periodId));
                                    cmdEng.ExecuteNonQuery();
                                }
                            }

                            trans.Commit();
                        }
                        catch (Exception exTrans)
                        {
                            trans.Rollback();
                            throw exTrans;
                        }
                    }
                }

                // 5. Log actions after successful transaction
                foreach (var kvp in newIds)
                {
                    string targetMasterId = kvp.Key;
                    string targetNewId = kvp.Value;
                    string postState = ActionLogger.CaptureEmployeeState(targetMasterId);
                    ActionLogger.LogAction("EDIT", targetMasterId, "Updated employee ID to '" + targetNewId + "' via bulk manage update.", null, postState);
                }

                // 6. Re-bind the grids to reflect the updated IDs
                BindManageEnrolledEmployees(periodId);
                BindManageCandidates(category, periodId);
                BindContractsHistory();

                ShowMessage("All employee IDs updated successfully.", true, "manageEmployeesModal");
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating employee IDs: " + ex.Message, false, "manageEmployeesModal");
            }
        }

        protected void gvManageEnrolledEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoveEmp")
            {
                string empMasterId = e.CommandArgument.ToString();
                int periodId = Convert.ToInt32(hfManageContractPeriodId.Value);

                try
                {
                    // Get the current engagement details
                    string queryEng = "SELECT Id, PrevEngagementId, TierId FROM EmployeeEngagements WHERE EmpID = :EmpID AND ContractPeriodId = :PeriodId AND EndDate IS NULL";
                    DataTable dtEng = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryEng, 
                        new OracleParameter("EmpID", empMasterId),
                        new OracleParameter("PeriodId", periodId));
                    if (dtEng.Rows.Count == 0)
                    {
                        ShowMessage("Active engagement not found.", false, "manageEmployeesModal");
                        return;
                    }

                    int engId = Convert.ToInt32(dtEng.Rows[0]["Id"]);
                    object prevEngIdVal = dtEng.Rows[0]["PrevEngagementId"];
                    string cat = dtEng.Rows[0]["TierId"].ToString();

                    // Check if there are attendance records
                    string queryAtt = "SELECT COUNT(*) FROM Attendance WHERE EngagementId = :EngId";
                    int attCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryAtt, new OracleParameter("EngId", engId)));
                    
                    if (attCount > 0)
                    {
                        ShowMessage("Cannot remove employee: attendance records have already been recorded under this contract engagement. You must end their status instead.", false, "manageEmployeesModal");
                        return;
                    }

                    // Check if there are wage overrides
                    string queryOver = "SELECT COUNT(*) FROM CalculationOverrides WHERE EngagementId = :EngId";
                    int overCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryOver, new OracleParameter("EngId", engId)));
                    
                    if (overCount > 0)
                    {
                        ShowMessage("Cannot remove employee: wage calculation overrides are linked to this engagement.", false, "manageEmployeesModal");
                        return;
                    }

                    // Capture pre-state
                    string preState = ActionLogger.CaptureEmployeeState(empMasterId);

                    using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                    {
                        conn.Open();
                        using (OracleTransaction trans = conn.BeginTransaction())
                        {
                            try
                            {
                                // Remove employee link
                                string nullEmp = "UPDATE Employees SET CurrentEngagementId = NULL WHERE MasterId = :MasterId";
                                using (OracleCommand cmd = new OracleCommand(nullEmp, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("MasterId", empMasterId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Delete engagement
                                string delEng = "DELETE FROM EmployeeEngagements WHERE Id = :Id";
                                using (OracleCommand cmd = new OracleCommand(delEng, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("Id", engId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Revert back to previous engagement or set as ContractEnded
                                if (prevEngIdVal != DBNull.Value)
                                {
                                    int prevEngId = Convert.ToInt32(prevEngIdVal);

                                    // Re-open previous engagement
                                    string reopen = "UPDATE EmployeeEngagements SET EndDate = NULL, EndReason = NULL WHERE Id = :Id";
                                    using (OracleCommand cmd = new OracleCommand(reopen, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("Id", prevEngId));
                                        cmd.ExecuteNonQuery();
                                    }

                                    // Get previous engagement properties
                                    string queryPrevEng = "SELECT TierId, StartDate, Department FROM EmployeeEngagements WHERE Id = :Id";
                                    object prevTierIdVal = DBNull.Value;
                                    DateTime prevStart = DateTime.MinValue;
                                    string prevDept = "";
                                    using (OracleCommand cmd = new OracleCommand(queryPrevEng, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("Id", prevEngId));
                                        using (OracleDataReader r = cmd.ExecuteReader())
                                        {
                                            if (r.Read())
                                            {
                                                prevTierIdVal = r["TierId"];
                                                prevStart = Convert.ToDateTime(r["StartDate"]);
                                                prevDept = r["Department"]?.ToString() ?? "GENERAL";
                                            }
                                        }
                                    }

                                    // Revert employee record to previous engagement
                                    string revertEmp = @"
                                        UPDATE Employees 
                                        SET CurrentEngagementId = :PrevEngagementId,
                                            TierId = :TierId,
                                            JoinDate = :JoinDate,
                                            Department = :Department,
                                            Status = 'Active' 
                                        WHERE MasterId = :MasterId";
                                    using (OracleCommand cmd = new OracleCommand(revertEmp, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("PrevEngagementId", prevEngId));
                                        cmd.Parameters.Add(new OracleParameter("TierId", prevTierIdVal));
                                        cmd.Parameters.Add(new OracleParameter("JoinDate", prevStart));
                                        cmd.Parameters.Add(new OracleParameter("Department", prevDept));
                                        cmd.Parameters.Add(new OracleParameter("MasterId", empMasterId));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    // There is no linked PrevEngagementId on the engagement itself (it was a manual enrollment)
                                    // Let's find the last remaining engagement for this employee to see if they had a previous contract stint.
                                    string queryLastEng = @"
                                        SELECT * FROM (
                                            SELECT Id, TierId, StartDate, EndDate, EndReason, Department, EmployeeId 
                                            FROM EmployeeEngagements 
                                            WHERE EmpID = :EmpID 
                                            ORDER BY StartDate DESC, Id DESC
                                        ) WHERE ROWNUM = 1";
                                    
                                    object prevTierIdVal = DBNull.Value;
                                    DateTime? prevStart = null;
                                    DateTime? prevEnd = null;
                                    string prevEndReason = null;
                                    string prevDept = null;
                                    string prevEmpId = null;
                                    int? prevEngId = null;

                                    using (OracleCommand cmd = new OracleCommand(queryLastEng, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.BindByName = true;
                                        cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                        using (OracleDataReader r = cmd.ExecuteReader())
                                        {
                                            if (r.Read())
                                            {
                                                prevEngId = Convert.ToInt32(r["Id"]);
                                                prevTierIdVal = r["TierId"];
                                                prevStart = Convert.ToDateTime(r["StartDate"]);
                                                if (r["EndDate"] != DBNull.Value)
                                                    prevEnd = Convert.ToDateTime(r["EndDate"]);
                                                prevEndReason = r["EndReason"] != DBNull.Value ? r["EndReason"].ToString() : "";
                                                prevDept = r["Department"] != DBNull.Value ? r["Department"].ToString() : "";
                                                prevEmpId = r["EmployeeId"] != DBNull.Value ? r["EmployeeId"].ToString() : "";
                                            }
                                        }
                                    }

                                    if (prevEngId.HasValue)
                                    {
                                        // The employee has a previous contract history stint!
                                        // Revert the employee master record using values from this previous engagement.
                                        string prevStatus = "ContractEnded";
                                        DateTime? prevResignDate = null;
                                        DateTime? prevContractEndDate = prevEnd;

                                        if (prevEndReason.Trim().Equals("Resigned", StringComparison.OrdinalIgnoreCase) || 
                                            prevEndReason.Trim().Equals("Resign", StringComparison.OrdinalIgnoreCase))
                                        {
                                            prevStatus = "Resigned";
                                            prevResignDate = prevEnd;
                                            prevContractEndDate = null;
                                        }

                                        string revertEmp = @"
                                            UPDATE Employees 
                                            SET CurrentEngagementId = NULL,
                                                TierId = :TierId,
                                                JoinDate = :JoinDate,
                                                Department = :Department,
                                                ID = :NewID,
                                                Status = :Status,
                                                ResignDate = :ResignDate,
                                                ContractEndDate = :ContractEndDate
                                            WHERE MasterId = :MasterId";

                                        using (OracleCommand cmd = new OracleCommand(revertEmp, conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.BindByName = true;
                                            cmd.Parameters.Add(new OracleParameter("TierId", prevTierIdVal));
                                            cmd.Parameters.Add(new OracleParameter("JoinDate", prevStart.HasValue ? (object)prevStart.Value : DBNull.Value));
                                            cmd.Parameters.Add(new OracleParameter("Department", string.IsNullOrEmpty(prevDept) ? (object)DBNull.Value : prevDept));
                                            cmd.Parameters.Add(new OracleParameter("NewID", string.IsNullOrEmpty(prevEmpId) ? (object)DBNull.Value : prevEmpId));
                                            cmd.Parameters.Add(new OracleParameter("Status", prevStatus));
                                            cmd.Parameters.Add(new OracleParameter("ResignDate", prevResignDate.HasValue ? (object)prevResignDate.Value : DBNull.Value));
                                            cmd.Parameters.Add(new OracleParameter("ContractEndDate", prevContractEndDate.HasValue ? (object)prevContractEndDate.Value : DBNull.Value));
                                            cmd.Parameters.Add(new OracleParameter("MasterId", empMasterId));
                                            cmd.ExecuteNonQuery();
                                        }
                                    }
                                    else
                                    {
                                        // The employee has NO previous contract history (this was their first and only enrollment)
                                        // Revert their master record back to pre-enrollment state (clear JoinDate/OriginalJoinDate/dates, TierId and set status to ContractEnded)
                                        string revertEmp = @"
                                            UPDATE Employees 
                                            SET CurrentEngagementId = NULL,
                                                Status = 'ContractEnded',
                                                JoinDate = NULL,
                                                OriginalJoinDate = NULL,
                                                TierId = NULL,
                                                ResignDate = NULL,
                                                ContractEndDate = NULL
                                            WHERE MasterId = :MasterId";

                                        using (OracleCommand cmd = new OracleCommand(revertEmp, conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.Parameters.Add(new OracleParameter("MasterId", empMasterId));
                                            cmd.ExecuteNonQuery();
                                        }
                                    }
                                }

                                trans.Commit();
                            }
                            catch (Exception exTrans)
                            {
                                trans.Rollback();
                                throw exTrans;
                            }
                        }
                    }

                    // Log the action
                    string postState = ActionLogger.CaptureEmployeeState(empMasterId);
                    ActionLogger.LogAction("EDIT", empMasterId, "Manually removed employee from active contract.", preState, postState);

                    // Refresh
                    BindManageEnrolledEmployees(periodId);
                    BindManageCandidates(cat, periodId);
                    BindContractsHistory();

                    ShowMessage("Employee removed successfully from this contract.", true, "manageEmployeesModal");
                }
                catch (Exception ex)
                {
                    ShowMessage("Error removing employee: " + ex.Message, false, "manageEmployeesModal");
                }
            }
        }

        protected void rptUnselectedEmployees_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DropDownList ddl = (DropDownList)e.Item.FindControl("ddlUnselectedAction");
                if (ddl != null)
                {
                    ddl.Items.Clear();
                    ddl.Items.Add(new ListItem("Contract Ended", "ContractEnded"));
                    ddl.Items.Add(new ListItem("Mark as Resigned", "Resigned"));

                    try
                    {
                        int role = Convert.ToInt32(Session["Role"] ?? 0);
                        string pcno = Session["PCNO"]?.ToString() ?? "";
                        DataTable dt = DBHelper.GetVisibleTiersDataTable(pcno, role);
                        foreach (DataRow row in dt.Rows)
                        {
                            string tierId = row["TierId"].ToString();
                            string displayName = row["DisplayName"].ToString();
                            ddl.Items.Add(new ListItem("Enroll as " + displayName, tierId));
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowMessage("Error loading categories in modal: " + ex.Message, false);
                    }
                }
            }
        }

        protected void btnSaveEditContract_Click(object sender, EventArgs e)
        {
            string contractIdStr = hfEditContractId.Value;
            if (string.IsNullOrEmpty(contractIdStr))
            {
                ShowMessage("Error: Contract Period ID is missing.", false);
                return;
            }

            int contractId = Convert.ToInt32(contractIdStr);
            string gemId = txtEditContractGemId.Text.Trim();
            string datedOnStr = txtEditContractDatedOn.Text.Trim();

            DateTime? datedOn = null;
            if (!string.IsNullOrEmpty(datedOnStr))
            {
                DateTime parsedDate;
                if (DateTime.TryParse(datedOnStr, out parsedDate))
                {
                    datedOn = parsedDate;
                }
                else
                {
                    ShowMessage("Error: Invalid Dated On date format.", false);
                    return;
                }
            }

            try
            {
                string sql = "UPDATE ContractPeriods SET GemId = :GemId, DatedOn = :DatedOn WHERE Id = :Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), sql,
                    new OracleParameter("GemId", string.IsNullOrEmpty(gemId) ? (object)DBNull.Value : gemId),
                    new OracleParameter("DatedOn", datedOn.HasValue ? (object)datedOn.Value : (object)DBNull.Value),
                    new OracleParameter("Id", contractId));

                ShowMessage("Contract information updated successfully.", true);
                BindContractsHistory(); // Refresh list
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating contract: " + ex.Message, false);
            }
        }
        #endregion
    }
}
