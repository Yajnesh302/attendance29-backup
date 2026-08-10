<%@ Page Title="Wages and Statutory" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Wages.aspx.cs" Inherits="AttendanceApp.Wages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Wages &amp; Statutory Management
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-header-title {
            font-weight: 800;
            color: #0f172a;
            font-size: 1.65rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-header-gradient {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }

        .form-label-bold {
            font-weight: 700;
            color: #334155;
            font-size: 0.85rem;
            margin-bottom: 6px;
            display: block;
        }

        .history-table-container {
            max-height: 380px;
            overflow-y: auto;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex align-items-center justify-content-between mb-2">
        <h2 class="dashboard-header-title">
            <i class="fas fa-coins text-success"></i> Category Wages &amp; Statutory Rates (EPF &amp; GST)
        </h2>
        <a href="Dashboard.aspx" class="btn btn-outline-secondary font-weight-bold">
            <i class="fas fa-arrow-left mr-1"></i> Back to Dashboard
        </a>
    </div>
    <hr style="border-color:#e2e8f0; margin-bottom: 20px;" />

    <!-- Wages & Statutory Standalone Panel -->
    <div class="card shadow-sm border-0 rounded-lg">
        <div class="card-header py-3 text-white card-header-gradient">
            <h5 class="m-0 font-weight-bold"><i class="fas fa-coins mr-2"></i> Category Wages &amp; Statutory Rates Configuration</h5>
        </div>
        <div class="card-body p-4 bg-white text-dark">
            <div class="alert alert-info py-2 px-3 mb-4 small">
                <i class="fas fa-info-circle mr-2"></i> Category wages are updated based on Government / Labour Rule Wage Orders (revised twice a year). Submit a new Wage Order with an Order ID to update category rates. All past wage orders and statutory revisions are saved historically for audit and calculation accuracy.
            </div>

            <!-- SUB-SECTION 1: CATEGORY WAGE ORDERS -->
            <div class="card mb-4 border shadow-none rounded">
                <div class="card-header bg-light py-2 px-3 border-bottom">
                    <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-file-invoice-dollar mr-2"></i> 1. Category Wage Order Revision</h6>
                </div>
                <div class="card-body p-3">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label-bold">Main Category <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlWageMainCategory" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlWageMainCategory_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label-bold">Wage Order ID / Ref No. <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtWageOrderId" runat="server" CssClass="form-control" placeholder="e.g., GO-2026-MAR-01"></asp:TextBox>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label-bold">Effective Date <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtWageEffectiveDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group mb-3">
                        <label class="form-label-bold">Order Details / Description / Remarks</label>
                        <asp:TextBox ID="txtWageOrderDetails" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control" placeholder="e.g., Minimum wage revision effective March 2026 to October 2026 as per Labour Dept notification."></asp:TextBox>
                    </div>

                    <div class="card bg-light border-0 p-3 mb-3">
                        <h6 class="font-weight-bold text-dark mb-2"><i class="fas fa-list-ol mr-2 text-info"></i> Category Wage Rates (Daily Rate in Rs.)</h6>
                        <asp:Repeater ID="rptCategoryWageInputs" runat="server">
                            <HeaderTemplate>
                                <div class="row font-weight-bold text-secondary mb-2 small text-uppercase">
                                    <div class="col-md-6">Sub-Category / Tier Name</div>
                                    <div class="col-md-6">Wage Rate (Rs. / day)</div>
                                </div>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="row align-items-center mb-2">
                                    <div class="col-md-6">
                                        <asp:HiddenField ID="hfTierId" runat="server" Value='<%# Eval("Id") %>' />
                                        <span class="font-weight-bold text-dark"><%# Eval("TierName") %></span>
                                        <asp:Literal ID="litRoleLabel" runat="server" Text='<%# !string.IsNullOrEmpty(Eval("RoleLabel") as string) ? " <span class=\"badge badge-secondary\">#" + Eval("RoleLabel") + "</span>" : "" %>'></asp:Literal>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="input-group input-group-sm">
                                            <div class="input-group-prepend"><span class="input-group-text">Rs.</span></div>
                                            <asp:TextBox ID="txtWageRate" runat="server" Text='<%# Eval("CurrentRate") %>' CssClass="form-control" TextMode="Number" step="any" placeholder="0.00"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Label ID="lblNoTiers" runat="server" Visible='<%# ((Repeater)Container.NamingContainer).Items.Count == 0 %>' 
                                           CssClass="text-muted font-italic d-block py-2">
                                    No sub-categories (tiers) defined for the selected Main Category. Please create sub-categories under "Category &amp; Tier Management" first.
                                </asp:Label>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="text-right">
                        <asp:Button ID="btnSaveWageOrder" runat="server" CssClass="btn btn-success font-weight-bold px-4" Text="Save Wage Order Revision" OnClick="btnSaveWageOrder_Click" />
                    </div>
                </div>
            </div>

            <!-- Wage Orders History -->
            <div class="card border shadow-none rounded mb-4">
                <div class="card-header bg-light py-2 px-3 border-bottom">
                    <h6 class="m-0 font-weight-bold text-dark"><i class="fas fa-history mr-2 text-secondary"></i> Wage Order Revisions History</h6>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive history-table-container">
                        <asp:GridView ID="gvWageOrderHistory" runat="server" AutoGenerateColumns="False" 
                                      CssClass="table table-hover table-striped mb-0 small" GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="S.No" ItemStyle-Width="50" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="OrderId" HeaderText="Order ID" ItemStyle-Font-Bold="true" />
                                <asp:BoundField DataField="MainCategoryName" HeaderText="Main Category" />
                                <asp:TemplateField HeaderText="Effective Date">
                                    <ItemTemplate><%# Convert.ToDateTime(Eval("EffectiveDate")).ToString("dd-MMM-yyyy") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="RatesBreakdown" HeaderText="Category Rates (Rs.)" HtmlEncode="false" />
                                <asp:BoundField DataField="OrderDetails" HeaderText="Details / Remarks" />
                                <asp:BoundField DataField="CreatedBy" HeaderText="Added By" />
                                <asp:TemplateField HeaderText="Added Date">
                                    <ItemTemplate><%# Eval("CreatedAt") != DBNull.Value ? Convert.ToDateTime(Eval("CreatedAt")).ToString("dd-MMM-yyyy HH:mm") : "-" %></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="p-3 text-center text-muted">No Wage Order revisions recorded yet.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- SUB-SECTION 2: STATUTORY REVISIONS (EPF & GST) -->
            <div class="card mb-4 border shadow-none rounded">
                <div class="card-header bg-light py-2 px-3 border-bottom">
                    <h6 class="m-0 font-weight-bold text-info"><i class="fas fa-percent mr-2"></i> 2. Statutory Rates Revision (EPF &amp; GST)</h6>
                </div>
                <div class="card-body p-3">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label-bold">Circular / Order ID <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtStatutoryOrderId" runat="server" CssClass="form-control" placeholder="e.g., EPF/GOV/2026/01"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label-bold">Effective Date <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtStatutoryEffectiveDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-3 mb-3">
                            <label class="form-label-bold">EPF Rate (%) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEpfRate" runat="server" CssClass="form-control" TextMode="Number" step="any" Text="13"></asp:TextBox>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label-bold">EPF Wage Limit (Rs.) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEpfLimit" runat="server" CssClass="form-control" TextMode="Number" step="any" Text="15000"></asp:TextBox>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label-bold">EPF Capped Max (Rs.) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEpfCappedAmount" runat="server" CssClass="form-control" TextMode="Number" step="any" Text="1950"></asp:TextBox>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label-bold">GST Rate (%) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtGstRate" runat="server" CssClass="form-control" TextMode="Number" step="any" Text="18"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group mb-3">
                        <label class="form-label-bold">Order Details / Circular Notes</label>
                        <asp:TextBox ID="txtStatutoryOrderDetails" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control" placeholder="e.g., Notification regarding EPF rate capping and GST applicability rules."></asp:TextBox>
                    </div>

                    <div class="text-right">
                        <asp:Button ID="btnSaveStatutoryOrder" runat="server" CssClass="btn btn-primary font-weight-bold px-4" Text="Save Statutory Revision" OnClick="btnSaveStatutoryOrder_Click" />
                    </div>
                </div>
            </div>

            <!-- Statutory History -->
            <div class="card border shadow-none rounded">
                <div class="card-header bg-light py-2 px-3 border-bottom">
                    <h6 class="m-0 font-weight-bold text-dark"><i class="fas fa-history mr-2 text-secondary"></i> Statutory Revisions History</h6>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive history-table-container">
                        <asp:GridView ID="gvStatutoryHistory" runat="server" AutoGenerateColumns="False" 
                                      CssClass="table table-hover table-striped mb-0 small" GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="S.No" ItemStyle-Width="50" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="OrderId" HeaderText="Circular / Order ID" ItemStyle-Font-Bold="true" />
                                <asp:TemplateField HeaderText="Effective Date">
                                    <ItemTemplate><%# Convert.ToDateTime(Eval("EffectiveDate")).ToString("dd-MMM-yyyy") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="EpfRate" HeaderText="EPF Rate (%)" />
                                <asp:BoundField DataField="EpfLimit" HeaderText="EPF Limit (Rs.)" />
                                <asp:BoundField DataField="EpfCappedAmount" HeaderText="EPF Capped (Rs.)" />
                                <asp:BoundField DataField="GstRate" HeaderText="GST Rate (%)" />
                                <asp:BoundField DataField="OrderDetails" HeaderText="Details / Notes" />
                                <asp:BoundField DataField="CreatedBy" HeaderText="Added By" />
                                <asp:TemplateField HeaderText="Added Date">
                                    <ItemTemplate><%# Eval("CreatedAt") != DBNull.Value ? Convert.ToDateTime(Eval("CreatedAt")).ToString("dd-MMM-yyyy HH:mm") : "-" %></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="p-3 text-center text-muted">No statutory revisions recorded yet.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>
