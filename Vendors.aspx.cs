using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Vendors : System.Web.UI.Page
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
                BindGrid();
                txtMasterId.Text = "(Auto-Generated)";
            }
        }

        private void BindGrid()
        {
            try
            {
                string search = txtSearch.Text.Trim();
                string query = @"SELECT v.Id, v.MasterId, v.Name, 
                                       (SELECT cp.GemId FROM ContractPeriods cp WHERE cp.VendorId = v.Id AND cp.Status = 'Active' AND ROWNUM = 1) AS GemId,
                                       v.ContactName, v.ContactPhone, v.Address,
                                       (CASE WHEN EXISTS (
                                           SELECT 1 FROM ContractPeriods cp 
                                           WHERE cp.VendorId = v.Id AND cp.Status = 'Active'
                                       ) THEN 1 ELSE 0 END) AS IsActive 
                                FROM Vendors v 
                                WHERE 1=1";
                List<OracleParameter> pList = new List<OracleParameter>();

                if (!string.IsNullOrEmpty(search))
                {
                    query += " AND (UPPER(v.MasterId) LIKE :Search OR UPPER(v.Name) LIKE :Search OR EXISTS (SELECT 1 FROM ContractPeriods cp WHERE cp.VendorId = v.Id AND UPPER(cp.GemId) LIKE :Search))";
                    pList.Add(new OracleParameter("Search", "%" + search.ToUpper() + "%"));
                }

                query += " ORDER BY v.Name ASC";

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pList.ToArray());
                gvVendors.DataSource = dt;
                gvVendors.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading vendors: " + ex.Message, false);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = txtVendorName.Text.Trim();
            string address = txtAddress.Text.Trim();
            string editId = hfEditVendorId.Value;
            string contactsJson = hfVendorContacts.Value;

            if (string.IsNullOrEmpty(name))
            {
                ShowMessage("Vendor Name is required.", false, "vendorFormModal");
                return;
            }

            // Parse escalation contacts from hidden JSON field
            var contacts = ParseContactsJson(contactsJson);
            if (contacts.Count == 0 || string.IsNullOrWhiteSpace(contacts[0].Name))
            {
                ShowMessage("Primary contact name is required.", false, "vendorFormModal");
                return;
            }
            if (string.IsNullOrWhiteSpace(contacts[0].Phone))
            {
                ShowMessage("Primary contact phone is required.", false, "vendorFormModal");
                return;
            }
            if (string.IsNullOrWhiteSpace(contacts[0].Email))
            {
                ShowMessage("Primary contact email is required.", false, "vendorFormModal");
                return;
            }
            if (string.IsNullOrWhiteSpace(contacts[0].Address))
            {
                ShowMessage("Primary contact address is required.", false, "vendorFormModal");
                return;
            }

            // Validate secondary/etc. levels: Name and Phone are required
            for (int i = 1; i < contacts.Count; i++)
            {
                if (string.IsNullOrWhiteSpace(contacts[i].Name))
                {
                    ShowMessage(string.Format("Level {0} contact name is required.", i + 1), false, "vendorFormModal");
                    return;
                }
                if (string.IsNullOrWhiteSpace(contacts[i].Phone))
                {
                    ShowMessage(string.Format("Level {0} contact phone is required.", i + 1), false, "vendorFormModal");
                    return;
                }
            }

            string masterId = "";

            try
            {
                if (string.IsNullOrEmpty(editId))
                {
                    // --- INSERT MODE ---
                    masterId = GenerateNextMasterId();

                    // Verify unique MasterId (safety check)
                    string checkMasterQuery = "SELECT COUNT(*) FROM Vendors WHERE UPPER(MasterId) = :MasterId";
                    int countMaster = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkMasterQuery, 
                        new OracleParameter("MasterId", masterId.ToUpper())));
                    if (countMaster > 0)
                    {
                        ShowMessage("Auto-generated Vendor Master ID already exists. Please contact support.", false, "vendorFormModal");
                        return;
                    }

                    // Verify unique Name
                    string checkNameQuery = "SELECT COUNT(*) FROM Vendors WHERE UPPER(Name) = :Name";
                    int countName = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkNameQuery, 
                        new OracleParameter("Name", name.ToUpper())));
                    if (countName > 0)
                    {
                        ShowMessage("Vendor Name already exists. Please enter a unique name.", false, "vendorFormModal");
                        return;
                    }

                    // Primary contact details synced to legacy columns for backward compatibility
                    string insertQuery = @"INSERT INTO Vendors (MasterId, Name, ContactName, ContactPhone, Address, IsActive) 
                                           VALUES (:MasterId, :Name, :ContactName, :ContactPhone, :Address, 1)";
                    OracleParameter[] p = new OracleParameter[] {
                        new OracleParameter("MasterId", masterId),
                        new OracleParameter("Name", name),
                        new OracleParameter("ContactName", (object)contacts[0].Name ?? DBNull.Value),
                        new OracleParameter("ContactPhone", (object)contacts[0].Phone ?? DBNull.Value),
                        new OracleParameter("Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address)
                    };

                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery, p);

                    // Get inserted vendor ID
                    string newIdQuery = "SELECT Id FROM Vendors WHERE MasterId = :MasterId";
                    int newVendorId = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), newIdQuery,
                        new OracleParameter("MasterId", masterId)));

                    // Save all escalation contact rows into VendorContacts table
                    SaveVendorContacts(newVendorId, contacts);

                    ShowMessage("Vendor added successfully with ID " + masterId + ".", true);
                }
                else
                {
                    // --- UPDATE MODE ---
                    int vendorId = Convert.ToInt32(editId);
                    masterId = txtMasterId.Text.Trim();

                    // Verify unique Name (excluding current vendor)
                    string checkNameQuery = "SELECT COUNT(*) FROM Vendors WHERE UPPER(Name) = :Name AND Id != :Id";
                    int countName = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkNameQuery, 
                        new OracleParameter("Name", name.ToUpper()),
                        new OracleParameter("Id", vendorId)));
                    if (countName > 0)
                    {
                        ShowMessage("Vendor Name is already in use by another vendor.", false, "vendorFormModal");
                        return;
                    }

                    string updateQuery = @"UPDATE Vendors SET Name = :Name, 
                                           ContactName = :ContactName, ContactPhone = :ContactPhone, Address = :Address
                                           WHERE Id = :Id";
                    OracleParameter[] p = new OracleParameter[] {
                        new OracleParameter("Name", name),
                        new OracleParameter("ContactName", (object)contacts[0].Name ?? DBNull.Value),
                        new OracleParameter("ContactPhone", (object)contacts[0].Phone ?? DBNull.Value),
                        new OracleParameter("Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address),
                        new OracleParameter("Id", vendorId)
                    };

                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, p);

                    // Re-sync all escalation contact rows
                    SaveVendorContacts(vendorId, contacts);

                    ShowMessage("Vendor updated successfully.", true);
                }

                ResetForm();
                BindGrid();
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving vendor: " + ex.Message, false, "vendorFormModal");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
            ShowMessage("Edit cancelled.", true);
        }

        protected void gvVendors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditVendor")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                LoadVendorForEdit(id);
            }
            else if (e.CommandName == "ViewHistory")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                OpenHistoryModal(id);
            }
            else if (e.CommandName == "DeleteVendor")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                try
                {
                    // Check for dependencies: ContractPeriods
                    string checkContracts = "SELECT COUNT(*) FROM ContractPeriods WHERE VendorId = :Id";
                    int contractCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkContracts, new OracleParameter("Id", id)));

                    // Check for dependencies: EmployeeEngagements
                    string checkEngagements = "SELECT COUNT(*) FROM EmployeeEngagements WHERE VendorId = :Id";
                    int engagementCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkEngagements, new OracleParameter("Id", id)));

                    if (contractCount > 0 || engagementCount > 0)
                    {
                        // Active references exist -> Deactivate instead of deleting
                        string deactivateQuery = "UPDATE Vendors SET IsActive = 0 WHERE Id = :Id";
                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deactivateQuery, new OracleParameter("Id", id));
                        ShowMessage("Vendor has active contracts or employee records. It has been deactivated instead of deleted.", true);
                    }
                    else
                    {
                        // No references -> Delete completely
                        string deleteQuery = "DELETE FROM Vendors WHERE Id = :Id";
                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteQuery, new OracleParameter("Id", id));
                        ShowMessage("Vendor deleted successfully.", true);
                    }
                    
                    ResetForm();
                    BindGrid();
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting vendor: " + ex.Message, false);
                }
            }
        }

        private void ResetForm()
        {
            txtMasterId.Text = "(Auto-Generated)";
            txtVendorName.Text = "";
            txtContactName.Text = "";
            txtContactPhone.Text = "";
            txtAddress.Text = "";
            hfEditVendorId.Value = "";
            hfVendorContacts.Value = "";
            
            btnCancel.Visible = false;
            btnSave.Text = "Save Vendor";
            
            formTitle.InnerHtml = "<i class=\"fas fa-plus mr-2\"></i> Add New Vendor";
            formHeader.Style["background"] = "linear-gradient(135deg, #0f172a 0%, #1e293b 100%)";
        }

        protected void btnHiddenEditTrigger_Click(object sender, EventArgs e)
        {
            string vendorIdStr = hfHiddenEditVendorId.Value;
            if (!string.IsNullOrEmpty(vendorIdStr))
            {
                int id = Convert.ToInt32(vendorIdStr);
                LoadVendorForEdit(id);
            }
        }

        private void LoadVendorForEdit(int id)
        {
            try
            {
                string query = "SELECT Id, MasterId, Name, ContactName, ContactPhone, Address, IsActive FROM Vendors WHERE Id = :Id";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("Id", id));
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    hfEditVendorId.Value = dr["Id"].ToString();
                    txtMasterId.Text = dr["MasterId"].ToString();
                    txtVendorName.Text = dr["Name"].ToString();
                    txtContactName.Text = dr["ContactName"] != DBNull.Value ? dr["ContactName"].ToString() : "";
                    txtContactPhone.Text = dr["ContactPhone"] != DBNull.Value ? dr["ContactPhone"].ToString() : "";
                    txtAddress.Text = dr["Address"] != DBNull.Value ? dr["Address"].ToString() : "";

                    // Load escalation contacts from VendorContacts table
                    string cQuery = "SELECT Priority, ContactName, ContactPhone, ContactEmail, ContactAddress FROM VendorContacts WHERE VendorId = :Id ORDER BY Priority ASC";
                    DataTable dtC = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), cQuery, new OracleParameter("Id", id));
                    
                    var contactsList = new List<VendorContactEntry>();
                    if (dtC != null && dtC.Rows.Count > 0)
                    {
                        foreach (DataRow cr in dtC.Rows)
                        {
                            contactsList.Add(new VendorContactEntry
                            {
                                Name = cr["ContactName"] != DBNull.Value ? cr["ContactName"].ToString() : "",
                                Phone = cr["ContactPhone"] != DBNull.Value ? cr["ContactPhone"].ToString() : "",
                                Email = cr["ContactEmail"] != DBNull.Value ? cr["ContactEmail"].ToString() : "",
                                Address = cr["ContactAddress"] != DBNull.Value ? cr["ContactAddress"].ToString() : ""
                            });
                        }
                    }
                    else
                    {
                        // Fallback to legacy primary contact columns if VendorContacts table has no entries
                        contactsList.Add(new VendorContactEntry
                        {
                            Name = txtContactName.Text,
                            Phone = txtContactPhone.Text,
                            Email = "",
                            Address = txtAddress.Text
                        });
                    }

                    // Build JSON string for client-side loadContactsFromJson()
                    System.Text.StringBuilder jsonSb = new System.Text.StringBuilder();
                    jsonSb.Append("[");
                    for (int i = 0; i < contactsList.Count; i++)
                    {
                        if (i > 0) jsonSb.Append(",");
                        jsonSb.Append("{");
                        jsonSb.AppendFormat("\"priority\":{0},", i + 1);
                        jsonSb.AppendFormat("\"name\":\"{0}\",", EscapeJs(contactsList[i].Name));
                        jsonSb.AppendFormat("\"phone\":\"{0}\",", EscapeJs(contactsList[i].Phone));
                        jsonSb.AppendFormat("\"email\":\"{0}\",", EscapeJs(contactsList[i].Email));
                        jsonSb.AppendFormat("\"address\":\"{0}\"", EscapeJs(contactsList[i].Address));
                        jsonSb.Append("}");
                    }
                    jsonSb.Append("]");
                    hfVendorContacts.Value = jsonSb.ToString();

                    btnCancel.Visible = true;
                    btnSave.Text = "Update Vendor";
                    
                    formTitle.InnerHtml = "<i class=\"fas fa-edit mr-2\"></i> Edit Vendor Details";
                    formHeader.Style["background"] = "linear-gradient(135deg, #4f46e5 0%, #3730a3 100%)";
                    
                    ShowMessage("Editing vendor " + txtVendorName.Text, true, "vendorFormModal");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading vendor details: " + ex.Message, false);
            }
        }

        private void OpenHistoryModal(int vendorId)
        {
            try
            {
                // 1. Fetch vendor master info
                string query = @"SELECT v.Id, v.MasterId, v.Name, 
                                       (SELECT cp.GemId FROM ContractPeriods cp WHERE cp.VendorId = v.Id AND cp.Status = 'Active' AND ROWNUM = 1) AS GemId,
                                       v.ContactName, v.ContactPhone, v.Address,
                                       (CASE WHEN EXISTS (
                                           SELECT 1 FROM ContractPeriods cp 
                                           WHERE cp.VendorId = v.Id AND cp.Status = 'Active'
                                       ) THEN 1 ELSE 0 END) AS IsActive 
                                FROM Vendors v 
                                WHERE v.Id = :Id";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("Id", vendorId));
                if (dt == null || dt.Rows.Count == 0)
                {
                    ShowMessage("Vendor not found.", false);
                    return;
                }

                DataRow dr = dt.Rows[0];
                string vName = dr["Name"].ToString();
                string vMasterId = dr["MasterId"].ToString();
                string vGemId = dr["GemId"] != DBNull.Value ? dr["GemId"].ToString() : "";
                string vContactName = dr["ContactName"] != DBNull.Value ? dr["ContactName"].ToString() : "";
                string vContactPhone = dr["ContactPhone"] != DBNull.Value ? dr["ContactPhone"].ToString() : "";
                string vAddress = dr["Address"] != DBNull.Value ? dr["Address"].ToString() : "";
                string vStatus = Convert.ToInt32(dr["IsActive"]) == 1 ? "Active" : "Inactive";

                // 1b. Fetch escalation contacts
                string contactsQuery = "SELECT Priority, ContactName, ContactPhone, ContactEmail, ContactAddress FROM VendorContacts WHERE VendorId = :VendorId ORDER BY Priority ASC";
                DataTable dtContacts = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), contactsQuery, new OracleParameter("VendorId", vendorId));
                System.Text.StringBuilder contactsSb = new System.Text.StringBuilder();
                contactsSb.Append("[");
                if (dtContacts != null && dtContacts.Rows.Count > 0)
                {
                    for (int cIdx = 0; cIdx < dtContacts.Rows.Count; cIdx++)
                    {
                        DataRow cr = dtContacts.Rows[cIdx];
                        if (cIdx > 0) contactsSb.Append(",");
                        contactsSb.Append("{");
                        contactsSb.AppendFormat("\"priority\":{0},", cr["Priority"]);
                        contactsSb.AppendFormat("\"name\":\"{0}\",", EscapeJs(cr["ContactName"] != DBNull.Value ? cr["ContactName"].ToString() : ""));
                        contactsSb.AppendFormat("\"phone\":\"{0}\",", EscapeJs(cr["ContactPhone"] != DBNull.Value ? cr["ContactPhone"].ToString() : ""));
                        contactsSb.AppendFormat("\"email\":\"{0}\",", EscapeJs(cr["ContactEmail"] != DBNull.Value ? cr["ContactEmail"].ToString() : ""));
                        contactsSb.AppendFormat("\"address\":\"{0}\"", EscapeJs(cr["ContactAddress"] != DBNull.Value ? cr["ContactAddress"].ToString() : ""));
                        contactsSb.Append("}");
                    }
                }
                else
                {
                    contactsSb.Append("{");
                    contactsSb.AppendFormat("\"priority\":1,");
                    contactsSb.AppendFormat("\"name\":\"{0}\",", EscapeJs(vContactName));
                    contactsSb.AppendFormat("\"phone\":\"{0}\",", EscapeJs(vContactPhone));
                    contactsSb.AppendFormat("\"email\":\"\",");
                    contactsSb.AppendFormat("\"address\":\"{0}\"", EscapeJs(vAddress));
                    contactsSb.Append("}");
                }
                contactsSb.Append("]");

                // 2. Fetch full contract history (oldest -> newest)
                string histQuery = @"
                    SELECT cp.Id, cp.TierId, cp.GemId, cp.StartDate, cp.EndDate, cp.DatedOn, cp.Status,
                           (SELECT mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') FROM Tiers t JOIN MainCategory mc ON t.MainCategoryId = mc.Id WHERE t.Id = cp.TierId) AS Category,
                           (SELECT COUNT(*) FROM EmployeeEngagements ee 
                            WHERE ee.ContractPeriodId = cp.Id 
                              AND (ee.EndDate IS NULL OR ee.EndDate = cp.EndDate OR ee.EndReason = 'ContractEnd')) AS EmployeeCount,
                           (SELECT COUNT(*) FROM ContractExtensions ce WHERE ce.ContractPeriodId = cp.Id) AS ExtensionCount
                    FROM   ContractPeriods cp
                    WHERE  cp.VendorId = :VendorId
                    ORDER  BY cp.StartDate ASC, cp.Id ASC";
                DataTable dtHist = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), histQuery, new OracleParameter("VendorId", vendorId));

                // 2b. Fetch all extensions for this vendor's contract periods
                string extQuery = @"
                    SELECT ce.ContractPeriodId, ce.OldEndDate, ce.NewEndDate, ce.ExtensionDate
                    FROM   ContractExtensions ce
                    JOIN   ContractPeriods cp ON ce.ContractPeriodId = cp.Id
                    WHERE  cp.VendorId = :VendorId
                    ORDER  BY ce.ExtensionDate ASC, ce.Id ASC";
                DataTable dtExt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), extQuery, new OracleParameter("VendorId", vendorId));

                // 3. Build timeline JSON for client-side rendering
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                sb.Append("[");
                if (dtHist != null && dtHist.Rows.Count > 0)
                {
                    for (int i = 0; i < dtHist.Rows.Count; i++)
                    {
                        DataRow r = dtHist.Rows[i];
                        int periodId = Convert.ToInt32(r["Id"]);
                        string cat = r["Category"].ToString();
                        string startDate = Convert.ToDateTime(r["StartDate"]).ToString("dd-MMM-yyyy");
                        string endDate = r["EndDate"] != DBNull.Value ? Convert.ToDateTime(r["EndDate"]).ToString("dd-MMM-yyyy") : "";
                        string status = r["Status"].ToString();
                        int empCount = Convert.ToInt32(r["EmployeeCount"]);
                        int extensionCount = Convert.ToInt32(r["ExtensionCount"]);
                        string datedOn = r["DatedOn"] != DBNull.Value ? Convert.ToDateTime(r["DatedOn"]).ToString("dd-MMM-yyyy") : "";

                        if (i > 0) sb.Append(",");
                        sb.Append("{");
                        sb.AppendFormat("\"cat\":\"{0}\",", EscapeJs(cat));
                        sb.AppendFormat("\"gemId\":\"{0}\",", EscapeJs(r["GemId"] != DBNull.Value ? r["GemId"].ToString() : ""));
                        sb.AppendFormat("\"start\":\"{0}\",", startDate);
                        sb.AppendFormat("\"end\":\"{0}\",", endDate);
                        sb.AppendFormat("\"status\":\"{0}\",", EscapeJs(status));
                        sb.AppendFormat("\"empCount\":{0},", empCount);
                        sb.AppendFormat("\"extensionCount\":{0},", extensionCount);
                        sb.AppendFormat("\"datedOn\":\"{0}\",", datedOn);

                        // Build extensions list
                        sb.Append("\"extensions\":[");
                        bool firstExt = true;
                        if (dtExt != null)
                        {
                            foreach (DataRow extRow in dtExt.Rows)
                            {
                                if (Convert.ToInt32(extRow["ContractPeriodId"]) == periodId)
                                {
                                    if (!firstExt) sb.Append(",");
                                    firstExt = false;

                                    string oldEnd = extRow["OldEndDate"] != DBNull.Value ? Convert.ToDateTime(extRow["OldEndDate"]).ToString("dd-MMM-yyyy") : "Ongoing";
                                    string newEnd = Convert.ToDateTime(extRow["NewEndDate"]).ToString("dd-MMM-yyyy");
                                    string extDate = Convert.ToDateTime(extRow["ExtensionDate"]).ToString("dd-MMM-yyyy hh:mm tt");

                                    sb.Append("{");
                                    sb.AppendFormat("\"oldEndDate\":\"{0}\",", oldEnd);
                                    sb.AppendFormat("\"newEndDate\":\"{0}\",", newEnd);
                                    sb.AppendFormat("\"extDate\":\"{0}\"", extDate);
                                    sb.Append("}");
                                }
                            }
                        }
                        sb.Append("]");

                        sb.Append("}");
                    }
                }
                sb.Append("]");

                // Escape for JS string literal
                string vendorJson = string.Format("{{\"id\":{0},\"masterId\":\"{1}\",\"name\":\"{2}\",\"gemId\":\"{3}\",\"contactName\":\"{4}\",\"contactPhone\":\"{5}\",\"address\":\"{6}\",\"status\":\"{7}\",\"contacts\":{8}}}",
                    vendorId, EscapeJs(vMasterId), EscapeJs(vName), EscapeJs(vGemId), EscapeJs(vContactName), EscapeJs(vContactPhone), EscapeJs(vAddress), EscapeJs(vStatus), contactsSb.ToString());

                string script = string.Format("openVendorHistoryModal({0}, {1});", vendorJson, sb.ToString());
                ClientScript.RegisterStartupScript(this.GetType(), "vendorHist_" + Guid.NewGuid().ToString("N"), script, true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading vendor history: " + ex.Message, false);
            }
        }

        private static string EscapeJs(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("'", "\\'")
                    .Replace("\r", "").Replace("\n", " ");
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
            }

            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        // ── Escalation contacts helpers ───────────────────────────────────────
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
                    if (json[i] == '{') { if (depth == 0) start = i; depth++; }
                    else if (json[i] == '}') { depth--; if (depth == 0 && start >= 0) { list.Add(ParseSingleContact(json.Substring(start, i - start + 1))); start = -1; } }
                }
            }
            catch { }
            return list;
        }

        private VendorContactEntry ParseSingleContact(string obj)
        {
            return new VendorContactEntry
            {
                Name  = ExtractJsonString(obj, "name"),
                Phone = ExtractJsonString(obj, "phone"),
                Email = ExtractJsonString(obj, "email"),
                Address = ExtractJsonString(obj, "address")
            };
        }

        private string ExtractJsonString(string obj, string key)
        {
            string search = "\"" + key + "\":\"";
            int idx = obj.IndexOf(search, StringComparison.OrdinalIgnoreCase);
            if (idx < 0) return "";
            idx += search.Length;
            int end = idx;
            while (end < obj.Length && !(obj[end] == '"' && (end == 0 || obj[end - 1] != '\\'))) end++;
            return System.Web.HttpUtility.HtmlDecode(obj.Substring(idx, end - idx));
        }

        private void SaveVendorContacts(int vendorId, List<VendorContactEntry> contacts)
        {
            // First clear existing contacts for this vendor
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
        // ── End escalation contact helpers ────────────────────────────────────
    }
}
