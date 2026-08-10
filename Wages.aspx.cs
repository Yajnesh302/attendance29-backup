using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Wages : System.Web.UI.Page
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
                BindWagesManagement();
            }
        }

        private void ShowToast(string message, string type)
        {
            string cleanMessage = message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void BindWagesManagement()
        {
            try
            {
                BindWageMainCategories();
                BindWageCategoryInputs();
                BindWageOrderHistory();
                BindStatutoryHistory();
            }
            catch (Exception ex)
            {
                ShowToast("Error loading wages management: " + ex.Message, "error");
            }
        }

        private void BindWageMainCategories()
        {
            string pcno = Session["PCNO"]?.ToString() ?? "";
            int role = Convert.ToInt32(Session["Role"] ?? 0);

            string query = "";
            List<OracleParameter> prms = new List<OracleParameter>();

            if (role == 4) // Super Admin sees all categories
            {
                query = "SELECT Id, Name FROM MainCategory ORDER BY Name ASC";
            }
            else // Regular Admin sees owned + shared categories
            {
                query = @"
                    SELECT DISTINCT mc.Id, mc.Name
                    FROM MainCategory mc
                    LEFT JOIN CategoryShareGrant csg ON mc.Id = csg.MainCategoryId
                    WHERE mc.AdminPCNO = :pcno OR (csg.SharedWithPCNO = :pcno AND csg.IsActive = 1)
                    ORDER BY mc.Name ASC";
                prms.Add(new OracleParameter("pcno", pcno));
            }

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, prms.ToArray());
            
            string prevSelected = ddlWageMainCategory.SelectedValue;
            ddlWageMainCategory.DataSource = dt;
            ddlWageMainCategory.DataTextField = "Name";
            ddlWageMainCategory.DataValueField = "Id";
            ddlWageMainCategory.DataBind();

            if (!string.IsNullOrEmpty(prevSelected) && ddlWageMainCategory.Items.FindByValue(prevSelected) != null)
            {
                ddlWageMainCategory.SelectedValue = prevSelected;
            }
        }

        private void BindWageCategoryInputs()
        {
            if (ddlWageMainCategory.Items.Count == 0)
            {
                rptCategoryWageInputs.DataSource = null;
                rptCategoryWageInputs.DataBind();
                return;
            }

            int mcId = Convert.ToInt32(ddlWageMainCategory.SelectedValue);
            string query = @"
                SELECT t.Id, t.TierName, t.RoleLabel, NVL(lw.WageRate, 0) AS CurrentRate
                FROM Tiers t
                LEFT JOIN (
                    SELECT cw.TierId, cw.WageRate,
                           ROW_NUMBER() OVER (PARTITION BY cw.TierId ORDER BY wo.EffectiveDate DESC, wo.CreatedAt DESC, cw.Id DESC) AS rn
                    FROM CategoryWages cw
                    JOIN WageOrders wo ON cw.WageOrderId = wo.Id
                ) lw ON t.Id = lw.TierId AND lw.rn = 1
                WHERE t.MainCategoryId = :mcId
                ORDER BY t.SortOrder, t.TierName";

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("mcId", mcId));
            rptCategoryWageInputs.DataSource = dt;
            rptCategoryWageInputs.DataBind();
        }

        protected void ddlWageMainCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindWageCategoryInputs();
            BindWageOrderHistory();
        }

        private void BindWageOrderHistory()
        {
            if (ddlWageMainCategory.Items.Count == 0 || string.IsNullOrEmpty(ddlWageMainCategory.SelectedValue))
            {
                gvWageOrderHistory.DataSource = null;
                gvWageOrderHistory.DataBind();
                return;
            }

            int mcId = Convert.ToInt32(ddlWageMainCategory.SelectedValue);
            string query = @"
                SELECT wo.OrderId, mc.Name AS MainCategoryName, wo.EffectiveDate, wo.OrderDetails, wo.CreatedBy, wo.CreatedAt,
                       rates.RatesBreakdown
                FROM WageOrders wo
                JOIN MainCategory mc ON wo.MainCategoryId = mc.Id
                LEFT JOIN (
                    SELECT cw.WageOrderId,
                           LISTAGG(t.TierName || ': Rs. ' || TO_CHAR(cw.WageRate, 'FM9999990.00') || '/day', '<br/>') 
                           WITHIN GROUP (ORDER BY NVL(t.SortOrder, 0), t.TierName) AS RatesBreakdown
                    FROM CategoryWages cw
                    JOIN Tiers t ON cw.TierId = t.Id
                    GROUP BY cw.WageOrderId
                ) rates ON wo.Id = rates.WageOrderId
                WHERE wo.MainCategoryId = :mcId
                ORDER BY wo.EffectiveDate DESC, wo.CreatedAt DESC";

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("mcId", mcId));
            gvWageOrderHistory.DataSource = dt;
            gvWageOrderHistory.DataBind();
        }

        private void BindStatutoryHistory()
        {
            string query = @"
                SELECT OrderId, EffectiveDate, EpfRate, EpfLimit, EpfCappedAmount, GstRate, OrderDetails, CreatedBy, CreatedAt
                FROM StatutoryOrders
                ORDER BY EffectiveDate DESC, CreatedAt DESC";

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
            gvStatutoryHistory.DataSource = dt;
            gvStatutoryHistory.DataBind();

            // Also load the latest statutory values into the input fields if available
            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow latest = dt.Rows[0];
                if (!IsPostBack)
                {
                    txtEpfRate.Text = Convert.ToDecimal(latest["EpfRate"]).ToString("0.##");
                    txtEpfLimit.Text = Convert.ToDecimal(latest["EpfLimit"]).ToString("0.##");
                    txtEpfCappedAmount.Text = Convert.ToDecimal(latest["EpfCappedAmount"]).ToString("0.##");
                    txtGstRate.Text = Convert.ToDecimal(latest["GstRate"]).ToString("0.##");
                }
            }
        }

        protected void btnSaveWageOrder_Click(object sender, EventArgs e)
        {
            try
            {
                if (ddlWageMainCategory.Items.Count == 0)
                {
                    ShowToast("No category selected.", "warning");
                    return;
                }

                int mcId = Convert.ToInt32(ddlWageMainCategory.SelectedValue);
                string mcName = ddlWageMainCategory.SelectedItem.Text;

                string orderId = txtWageOrderId.Text.Trim();
                string effectiveDateStr = txtWageEffectiveDate.Text.Trim();
                string orderDetails = txtWageOrderDetails.Text.Trim();
                string createdBy = Session["PCNO"]?.ToString() ?? "ADMIN";

                if (string.IsNullOrEmpty(orderId))
                {
                    ShowToast("Please enter a Wage Order ID / Ref No.", "warning");
                    return;
                }

                DateTime effectiveDate;
                if (!DateTime.TryParse(effectiveDateStr, out effectiveDate))
                {
                    ShowToast("Please enter a valid Effective Date.", "warning");
                    return;
                }

                // Collect category wage rates from repeater
                List<KeyValuePair<int, decimal>> rateUpdates = new List<KeyValuePair<int, decimal>>();
                foreach (RepeaterItem item in rptCategoryWageInputs.Items)
                {
                    if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
                    {
                        HiddenField hfTierId = item.FindControl("hfTierId") as HiddenField;
                        TextBox txtWageRate = item.FindControl("txtWageRate") as TextBox;

                        if (hfTierId != null && txtWageRate != null)
                        {
                            int tierId = Convert.ToInt32(hfTierId.Value);
                            decimal rate = 0;
                            decimal.TryParse(txtWageRate.Text.Trim(), out rate);

                            rateUpdates.Add(new KeyValuePair<int, decimal>(tierId, rate));
                        }
                    }
                }

                // Update Tiers table and record WageOrders / CategoryWages history
                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1) Insert Master WageOrder
                            string insertMasterSql = @"
                                INSERT INTO WageOrders (OrderId, MainCategoryId, EffectiveDate, OrderDetails, CreatedBy, CreatedAt)
                                VALUES (:OrderId, :MainCategoryId, :EffectiveDate, :OrderDetails, :CreatedBy, SYSDATE)
                                RETURNING Id INTO :NewId";

                            decimal newWageOrderId = 0;
                            using (OracleCommand cmd = new OracleCommand(insertMasterSql, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("OrderId", orderId));
                                cmd.Parameters.Add(new OracleParameter("MainCategoryId", mcId));
                                cmd.Parameters.Add(new OracleParameter("EffectiveDate", effectiveDate));
                                cmd.Parameters.Add(new OracleParameter("OrderDetails", orderDetails));
                                cmd.Parameters.Add(new OracleParameter("CreatedBy", createdBy));

                                OracleParameter pOut = new OracleParameter("NewId", OracleDbType.Decimal, ParameterDirection.Output);
                                cmd.Parameters.Add(pOut);

                                cmd.ExecuteNonQuery();
                                newWageOrderId = Convert.ToDecimal(pOut.Value.ToString());
                            }

                            // 2) Insert CategoryWages history
                            foreach (var kvp in rateUpdates)
                            {
                                int tierId = kvp.Key;
                                decimal rate = kvp.Value;

                                string insertCatWageSql = @"
                                    INSERT INTO CategoryWages (WageOrderId, TierId, WageRate, CreatedBy, CreatedAt)
                                    VALUES (:WageOrderId, :TierId, :WageRate, :CreatedBy, SYSDATE)";
                                using (OracleCommand cmd = new OracleCommand(insertCatWageSql, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("WageOrderId", newWageOrderId));
                                    cmd.Parameters.Add(new OracleParameter("TierId", tierId));
                                    cmd.Parameters.Add(new OracleParameter("WageRate", rate));
                                    cmd.Parameters.Add(new OracleParameter("CreatedBy", createdBy));
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            trans.Commit();
                        }
                        catch
                        {
                            trans.Rollback();
                            throw;
                        }
                    }
                }

                txtWageOrderId.Text = "";
                txtWageOrderDetails.Text = "";
                BindWageCategoryInputs();
                BindWageOrderHistory();

                ShowToast($"Wage Order '{orderId}' saved successfully and category wage rates updated!", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error saving Wage Order revision: " + ex.Message, "error");
            }
        }

        protected void btnSaveStatutoryOrder_Click(object sender, EventArgs e)
        {
            try
            {
                string orderId = txtStatutoryOrderId.Text.Trim();
                string effectiveDateStr = txtStatutoryEffectiveDate.Text.Trim();
                string orderDetails = txtStatutoryOrderDetails.Text.Trim();
                string createdBy = Session["PCNO"]?.ToString() ?? "ADMIN";

                if (string.IsNullOrEmpty(orderId))
                {
                    ShowToast("Please enter Circular / Order ID for statutory revision.", "warning");
                    return;
                }

                DateTime effectiveDate;
                if (!DateTime.TryParse(effectiveDateStr, out effectiveDate))
                {
                    ShowToast("Please enter a valid Effective Date.", "warning");
                    return;
                }

                decimal epfRate, epfLimit, epfCapped, gstRate;
                if (!decimal.TryParse(txtEpfRate.Text.Trim(), out epfRate) || epfRate < 0)
                {
                    ShowToast("Please enter a valid EPF rate percentage.", "warning");
                    return;
                }
                if (!decimal.TryParse(txtEpfLimit.Text.Trim(), out epfLimit) || epfLimit < 0)
                {
                    ShowToast("Please enter a valid EPF wage limit amount.", "warning");
                    return;
                }
                if (!decimal.TryParse(txtEpfCappedAmount.Text.Trim(), out epfCapped) || epfCapped < 0)
                {
                    ShowToast("Please enter a valid EPF max capped amount.", "warning");
                    return;
                }
                if (!decimal.TryParse(txtGstRate.Text.Trim(), out gstRate) || gstRate < 0)
                {
                    ShowToast("Please enter a valid GST rate percentage.", "warning");
                    return;
                }

                // Insert into StatutoryOrders
                string insertSql = @"
                    INSERT INTO StatutoryOrders
                    (OrderId, EffectiveDate, EpfRate, EpfLimit, EpfCappedAmount, GstRate, OrderDetails, CreatedBy, CreatedAt)
                    VALUES
                    (:OrderId, :EffectiveDate, :EpfRate, :EpfLimit, :EpfCappedAmount, :GstRate, :OrderDetails, :CreatedBy, SYSDATE)";

                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertSql,
                    new OracleParameter("OrderId", orderId),
                    new OracleParameter("EffectiveDate", effectiveDate),
                    new OracleParameter("EpfRate", epfRate),
                    new OracleParameter("EpfLimit", epfLimit),
                    new OracleParameter("EpfCappedAmount", epfCapped),
                    new OracleParameter("GstRate", gstRate),
                    new OracleParameter("OrderDetails", orderDetails),
                    new OracleParameter("CreatedBy", createdBy));

                txtStatutoryOrderId.Text = "";
                txtStatutoryOrderDetails.Text = "";
                BindStatutoryHistory();

                ShowToast($"Statutory Revision '{orderId}' saved successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error saving Statutory revision: " + ex.Message, "error");
            }
        }
    }
}
