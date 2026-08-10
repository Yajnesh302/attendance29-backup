<%@ Page Title="Contracts" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Contracts.aspx.cs" Inherits="AttendanceApp.Contracts" EnableEventValidation="false" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
        Contract Configuration
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            .wizard-container {
                margin-top: 10px;
            }

            .wizard-header {
                display: flex;
                justify-content: space-between;
                margin-bottom: 24px;
                position: relative;
                background: #fff;
                padding: 16px 24px;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
                border: 1px solid #e2e8f0;
            }

            .wizard-step {
                display: flex;
                align-items: center;
                font-weight: 600;
                color: #64748b;
                font-size: 0.95rem;
                z-index: 2;
            }

            .wizard-step.active {
                color: #4f46e5;
            }

            .wizard-step.completed {
                color: #10b981;
            }

            .wizard-step-num {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                border: 2px solid #cbd5e1;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-right: 8px;
                font-size: 0.85rem;
                background: white;
                transition: all 0.2s ease;
            }

            .active .wizard-step-num {
                border-color: #4f46e5;
                background-color: #e0e7ff;
                color: #4f46e5;
                font-weight: 700;
            }

            .completed .wizard-step-num {
                border-color: #10b981;
                background-color: #d1fae5;
                color: #10b981;
            }

            .panel-wizard {
                background: white;
                padding: 24px;
            }

            .table-custom-emp {
                border-collapse: separate !important;
                border-spacing: 0 !important;
                width: 100% !important;
                border: 1px solid #e2e8f0 !important;
                border-radius: 10px !important;
                overflow: hidden !important;
            }

            .table-custom-emp th {
                position: -webkit-sticky !important;
                position: sticky !important;
                top: 0 !important;
                z-index: 10 !important;
                background-color: #f8fafc !important;
                color: #475569 !important;
                font-size: 0.8rem !important;
                text-transform: uppercase !important;
                letter-spacing: 0.06em !important;
                font-weight: 700 !important;
                padding: 10px 16px !important;
                border-top: none !important;
                border-bottom: 2px solid #e2e8f0 !important;
                border-left: none !important;
                border-right: 1px solid #e2e8f0 !important;
                vertical-align: middle !important;
            }

            .table-custom-emp th:last-child {
                border-right: none !important;
            }

            .table-custom-emp td {
                padding: 10px 16px !important;
                color: #334155 !important;
                font-size: 0.88rem !important;
                font-weight: 500 !important;
                border-bottom: 1px solid #e2e8f0 !important;
                border-left: none !important;
                border-right: 1px solid #f1f5f9 !important;
                vertical-align: middle !important;
            }

            .table-custom-emp td:last-child {
                border-right: none !important;
            }

            .table-custom-emp tr:last-child td {
                border-bottom: none !important;
            }

            .table-custom-emp tr {
                transition: background-color 0.15s ease;
            }

            .table-custom-emp tr:hover {
                background-color: #eef2ff !important;
            }

            .table-custom-emp tr:nth-child(even) {
                background-color: #fbfcfd;
            }

            .card-header-gradient-contract {
                background: linear-gradient(135deg, #0b5c6b 0%, #08404a 100%);
                border-top-left-radius: 12px;
                border-top-right-radius: 12px;
                padding: 16px 20px;
                color: white;
            }

            .animate-hover {
                transition: all 0.2s ease;
            }

            .animate-hover:hover {
                transform: translateY(-1.5px);
                box-shadow: 0 4px 12px rgba(79, 70, 229, 0.2) !important;
            }

            .modal {
                background: rgba(0, 0, 0, 0.55);
            }

            .modal-backdrop {
                display: none !important;
            }

            .modal-content {
                border-radius: 14px;
                border: none;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            }

            .modal-header {
                border-top-left-radius: 14px;
                border-top-right-radius: 14px;
                background: linear-gradient(135deg, #0b5c6b 0%, #08404a 100%);
            }

            /* Manage Employee Modal Custom Styles */
            .manage-contract-info-card {
                background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px 20px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
            }

            .manage-contract-info-title {
                font-size: 1.05rem;
                font-weight: 800;
                color: #0b5c6b;
                margin-bottom: 4px;
            }

            .manage-add-section {
                border: 1px solid #e2e8f0;
                background-color: #ffffff;
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 24px;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03);
            }

            .manage-add-title {
                font-size: 0.95rem;
                font-weight: 700;
                color: #334155;
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .select-custom {
                border: 1.5px solid #cbd5e1 !important;
                border-radius: 8px !important;
                padding: 8px 12px !important;
                height: auto !important;
                font-size: 0.88rem !important;
                background-color: #f8fafc !important;
                color: #0f172a !important;
                outline: none !important;
                transition: border-color 0.2s !important;
            }

            .select-custom:focus {
                border-color: #0b5c6b !important;
                background-color: #fff !important;
            }

            .btn-add-custom {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
                border: none !important;
                color: white !important;
                font-weight: 700 !important;
                padding: 8.5px 20px !important;
                border-radius: 8px !important;
                transition: all 0.2s ease !important;
                height: auto !important;
                display: inline-flex !important;
                align-items: center !important;
                justify-content: center !important;
                gap: 6px !important;
            }

            .btn-add-custom:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3) !important;
            }

            .grid-id-input {
                border: 1.5px solid #cbd5e1 !important;
                border-radius: 6px !important;
                padding: 4px 8px !important;
                font-size: 0.85rem !important;
                color: #0f172a !important;
                background-color: #f8fafc !important;
                transition: all 0.2s ease-in-out !important;
                width: 80px !important;
                text-align: center !important;
                outline: none !important;
            }

            .grid-id-input:focus {
                border-color: #0b5c6b !important;
                background-color: #fff !important;
                box-shadow: 0 0 0 3px rgba(11, 92, 107, 0.15) !important;
            }

            .action-cell-container {
                display: flex;
                gap: 8px;
                align-items: center;
                justify-content: center;
            }

            .btn-grid-action {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                font-size: 0.8rem;
                font-weight: 700;
                padding: 5px 10px;
                border-radius: 6px;
                border: none;
                cursor: pointer;
                transition: all 0.15s ease;
                text-decoration: none !important;
            }

            .btn-grid-save {
                background-color: #e0f2fe;
                color: #0284c7;
            }

            .btn-grid-save:hover {
                background-color: #0284c7;
                color: #ffffff;
                transform: translateY(-1px);
                box-shadow: 0 2px 5px rgba(2, 132, 199, 0.2);
            }

            .btn-grid-remove {
                background-color: #fee2e2;
                color: #dc2626;
            }

            .btn-grid-remove:hover {
                background-color: #dc2626;
                color: #ffffff;
                transform: translateY(-1px);
                box-shadow: 0 2px 5px rgba(220, 38, 38, 0.2);
            }

            /* Contact Escalation Matrix Styles */
            .escalation-matrix-section {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px;
                margin-bottom: 16px;
            }
            .escalation-matrix-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 14px;
            }
            .escalation-matrix-title {
                font-size: 0.85rem;
                font-weight: 700;
                color: #1e293b;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .contact-level-card {
                background: #ffffff;
                border: 1px solid #cbd5e1;
                border-radius: 10px;
                padding: 14px 16px;
                margin-bottom: 12px;
                position: relative;
                box-shadow: 0 2px 4px rgba(0,0,0,0.03);
            }
            .contact-level-card:last-child {
                margin-bottom: 0;
            }
            .contact-level-title {
                font-size: 0.8rem;
                font-weight: 700;
                color: #1e293b;
                margin-bottom: 10px;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .contact-level-badge {
                font-size: 0.72rem;
                padding: 3px 10px;
                border-radius: 12px;
                font-weight: 700;
                display: inline-block;
            }
            .badge-level-1 { background: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; }
            .badge-level-n { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }
            .contact-field-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
            }
            .btn-add-contact {
                font-size: 0.8rem;
                font-weight: 700;
                color: #4f46e5;
                background: #e0e7ff;
                border: 1px solid #c7d2fe;
                border-radius: 8px;
                padding: 6px 14px;
                cursor: pointer;
                transition: all 0.2s ease;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-add-contact:hover {
                background: #4f46e5;
                color: #ffffff;
                box-shadow: 0 2px 6px rgba(79, 70, 229, 0.25);
            }
            .btn-remove-contact {
                position: absolute;
                top: 12px;
                right: 12px;
                font-size: 0.75rem;
                font-weight: 600;
                color: #ef4444;
                background: #fee2e2;
                border: 1px solid #fca5a5;
                border-radius: 6px;
                padding: 3px 10px;
                cursor: pointer;
                transition: all 0.2s ease;
            }
            .btn-remove-contact:hover {
                background: #ef4444;
                color: #ffffff;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0 text-dark font-weight-bold">Contract Periods Management</h2>
            <asp:LinkButton ID="btnConfigureNew" runat="server"
                CssClass="btn btn-primary font-weight-bold animate-hover shadow-sm"
                style="background-color: #4f46e5; border-color: #4f46e5;" OnClick="btnConfigureNew_Click">
                <i class="fas fa-plus-circle mr-2"></i>Configure New Contract
            </asp:LinkButton>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-block d-none" Visible="false"></asp:Label>

        <!-- Contracts List Card -->
        <div id="divContractsHistory" runat="server" class="card shadow-sm border-0 rounded-lg mb-4"
            style="border-radius: 12px; overflow: hidden;">
            <div class="card-header bg-gradient-primary text-white py-3"
                style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); border-top-left-radius: 12px; border-top-right-radius: 12px;">
                <h5 class="m-0 font-weight-bold"><i class="fas fa-file-contract mr-2"></i> Current &amp; Previous
                    Contracts</h5>
            </div>
            <div class="card-body bg-white text-dark p-4">
                <!-- Search & Filters -->
                <div class="row mb-4 align-items-end">
                    <div class="col-md-3 mb-3 mb-md-0">
                        <label class="font-weight-bold text-gray-700 mb-1" style="font-size: 0.85rem;">Filter by
                            Category</label>
                        <asp:DropDownList ID="ddlFilterCategory" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3 mb-3 mb-md-0">
                        <label class="font-weight-bold text-gray-700 mb-1" style="font-size: 0.85rem;">Filter by
                            Status</label>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                            <asp:ListItem Text="All Statuses" Value=""></asp:ListItem>
                            <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                            <asp:ListItem Text="Closed" Value="Closed"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4 mb-3 mb-md-0">
                        <label class="font-weight-bold text-gray-700 mb-1" style="font-size: 0.85rem;">Search Vendor
                            Name / ID</label>
                        <div class="input-group">
                            <asp:TextBox ID="txtSearchVendor" runat="server" CssClass="form-control"
                                placeholder="Search vendor..."></asp:TextBox>
                            <div class="input-group-append">
                                <asp:Button ID="btnSearchContracts" runat="server" Text="Search"
                                    CssClass="btn btn-primary" OnClick="btnSearchContracts_Click"
                                    style="background-color: #4f46e5; border-color: #4f46e5;" />
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2 text-right">
                        <asp:LinkButton ID="btnClearFilters" runat="server"
                            CssClass="btn btn-outline-secondary w-100 font-weight-bold" OnClick="btnClearFilters_Click">
                            Clear</asp:LinkButton>
                    </div>
                </div>

                <!-- Grouped Contracts List -->
                <asp:Repeater ID="rptContractPeriods" runat="server" OnItemDataBound="rptContractPeriods_ItemDataBound"
                    OnItemCommand="rptContractPeriods_ItemCommand">
                    <HeaderTemplate>
                        <div class="contracts-list-wrapper">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="card mb-4 border shadow-sm rounded-lg"
                            style="border-radius: 12px; overflow: hidden;">
                            <!-- Group Header -->
                            <div class="card-header d-flex justify-content-between align-items-center py-3 bg-light"
                                style="border-bottom: 1px solid #e2e8f0;">
                                <div>
                                    <h6 class="m-0 font-weight-bold text-dark" style="font-size: 1.05rem;">
                                        <i class="far fa-calendar-alt text-primary mr-2"></i>
                                        <%# Eval("Category") %> Contract:
                                            <span class="text-primary">
                                                <%# Eval("StartDate", "{0:dd-MMM-yyyy}" ) %>
                                            </span>
                                            to
                                            <span class="text-primary">
                                                <%# Eval("EndDate")==DBNull.Value ? "Present" :
                                                    Eval("EndDate", "{0:dd-MMM-yyyy}" ) %>
                                            </span>
                                            <span class="mx-2 text-muted">|</span>
                                            GeM ID: <span class="text-info">
                                                <%# Eval("GemId")==DBNull.Value ||
                                                    string.IsNullOrEmpty(Eval("GemId").ToString()) ? "-" : Eval("GemId")
                                                    %>
                                            </span>
                                            <span class="mx-2 text-muted">|</span>
                                            Dated On: <span class="text-info">
                                                <%# Eval("DatedOn")==DBNull.Value ||
                                                    string.IsNullOrEmpty(Eval("DatedOn").ToString()) ? "-" :
                                                    Eval("DatedOn", "{0:dd-MMM-yyyy}" ) %>
                                            </span>
                                    </h6>
                                </div>
                                <div class="d-flex align-items-center">
                                    <span
                                        class='badge <%# Eval("Status").ToString() == "Active" ? (Convert.ToInt32(Eval("ExtensionCount")) > 0 ? "bg-info text-white" : "bg-success text-white") : "bg-secondary text-white" %> px-3 py-2 mr-3'
                                        style="font-size: 0.85rem; border-radius: 20px;">
                                        <%# Eval("Status").ToString()=="Active" ?
                                            (Convert.ToInt32(Eval("ExtensionCount"))> 0 ? "Extended" : "Active") :
                                            "Closed" %>
                                    </span>
                                    <asp:HiddenField ID="hfContractPeriodId" runat="server" Value='<%# Eval("Id") %>' />

                                    <asp:LinkButton ID="btnManageEmployees" runat="server" CommandName="ManageEmployees"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CssClass="btn btn-sm btn-primary text-white font-weight-bold mr-2 animate-hover"
                                        Visible='<%# Eval("Status").ToString() == "Active" %>'
                                        style="background-color: #4f46e5; border-color: #4f46e5;">
                                        <i class="fas fa-users-cog mr-1"></i> Manage Employees
                                    </asp:LinkButton>

                                    <button type="button"
                                        class="btn btn-sm btn-info text-white font-weight-bold mr-2 animate-hover"
                                        data-toggle="collapse" data-target='#details-<%# Eval("Id") %>'
                                        data-bs-toggle="collapse" data-bs-target='#details-<%# Eval("Id") %>'
                                        style="background-color: #0b5c6b; border-color: #0b5c6b;">
                                        <i class="fas fa-eye mr-1"></i> Details
                                    </button>

                                    <button type="button"
                                        class="btn btn-sm btn-outline-secondary font-weight-bold mr-2 animate-hover"
                                        style='display: <%# Eval("Status").ToString() == "Active" ? "inline-block" : "none" %>;'
                                        onclick="openEditContractModal('<%# Eval("Id") %>', '<%# Eval("GemId") %>', '<%# Eval("DatedOn") == DBNull.Value ? "" : Eval("DatedOn", "{0:yyyy-MM-dd}") %>');">
                                        <i class="fas fa-edit mr-1"></i> Edit Info
                                    </button>

                                    <button type="button"
                                        class="btn btn-sm btn-outline-primary font-weight-bold mr-2 animate-hover"
                                        style='display: <%# Eval("Status").ToString() == "Active" ? "inline-block" : "none" %>;'
                                        onclick="openExtendContractModal('<%# Eval("Id") %>', '<%# Eval("Category") %> Contract starting <%# Eval("StartDate", "{0:dd-MMM-yyyy}") %>', '<%# Eval("EndDate", "{0:yyyy-MM-dd}") %>', '<%# Eval("GemId") %>');">
                                        Extend Contract
                                    </button>

                                    <button type="button"
                                        class="btn btn-sm btn-outline-danger font-weight-bold mr-2 animate-hover"
                                        style='display: <%# Eval("Status").ToString() == "Active" ? "inline-block" : "none" %>;'
                                        onclick="openEndContractModal('<%# Eval("Id") %>', '<%# Eval("Category") %> Contract starting <%# Eval("StartDate", "{0:dd-MMM-yyyy}") %>');">
                                        End Contract
                                    </button>

                                    <button type="button"
                                        class="btn btn-sm btn-danger text-white font-weight-bold animate-hover"
                                        onclick="openDeleteContractModal('<%# Eval("Id") %>', '<%# Eval("Category") %> Contract starting <%# Eval("StartDate", "{0:dd-MMM-yyyy}") %>');">
                                        <i class="fas fa-trash-alt mr-1"></i> Delete
                                    </button>
                                </div>
                            </div>

                            <!-- Group Body: List vendors & categories (Collapsable) -->
                            <div id='details-<%# Eval("Id") %>' class="collapse">
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0" style="font-size: 0.9rem;">
                                            <thead class="bg-light text-muted"
                                                style="font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.05em;">
                                                <tr>
                                                    <th style="padding: 12px 24px; width: 25%;">Category</th>
                                                    <th style="padding: 12px 24px; width: 40%;">Vendor Name</th>
                                                    <th style="padding: 12px 24px; width: 20%;">Vendor ID</th>
                                                    <th style="padding: 12px 24px; width: 15%; text-align: center;">
                                                        Enrolled Employees</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <!-- Nested Repeater for Categories & Vendors -->
                                                <asp:Repeater ID="rptContractDetails" runat="server">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td style="padding: 14px 24px; font-weight: 600;"
                                                                class="text-primary">
                                                                <%# Eval("Category") %>
                                                            </td>
                                                            <td
                                                                style="padding: 14px 24px; font-weight: 700; color: #1e293b;">
                                                                <%# Eval("VendorName") %>
                                                            </td>
                                                            <td style="padding: 14px 24px;" class="text-muted">
                                                                <%# Eval("MasterId") %>
                                                            </td>
                                                            <td style="padding: 14px 24px; text-align: center;"
                                                                class="font-weight-bold">
                                                                <%# Eval("EmployeeCount") %>
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- Extension History Section -->
                                    <asp:PlaceHolder ID="phExtensions" runat="server"
                                        Visible='<%# Convert.ToInt32(Eval("ExtensionCount")) > 0 %>'>
                                        <div class="p-3 border-top bg-light">
                                            <h6 class="font-weight-bold text-dark mb-2"><i
                                                    class="fas fa-history text-info mr-2"></i> Contract Date Extensions
                                                History</h6>
                                            <div class="table-responsive">
                                                <table class="table table-sm table-bordered mb-0 bg-white"
                                                    style="font-size: 0.85rem;">
                                                    <thead class="bg-light">
                                                        <tr>
                                                            <th class="py-2 px-3">Original/Previous End Date</th>
                                                            <th class="py-2 px-3">New Extended End Date</th>
                                                            <th class="py-2 px-3">Date Applied</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <asp:Repeater ID="rptExtensionHistory" runat="server">
                                                            <ItemTemplate>
                                                                <tr>
                                                                    <td class="py-2 px-3">
                                                                        <%# Eval("OldEndDate")==DBNull.Value ? "Ongoing"
                                                                            : Eval("OldEndDate", "{0:dd-MMM-yyyy}" ) %>
                                                                    </td>
                                                                    <td class="py-2 px-3 font-weight-bold text-success">
                                                                        <%# Eval("NewEndDate", "{0:dd-MMM-yyyy}" ) %>
                                                                    </td>
                                                                    <td class="py-2 px-3 text-muted">
                                                                        <%# Eval("ExtensionDate", "{0:dd-MMM-yyyy hh:mm tt}"
                                                                            ) %>
                                                                    </td>
                                                                </tr>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </asp:PlaceHolder>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
            </div>
            </FooterTemplate>
            </asp:Repeater>
        </div>
        </div>

        <!-- Wizard Container -->
        <asp:Panel ID="pnlWizard" runat="server" Visible="false">
            <div class="wizard-container">

                <!-- Wizard Progress Steps -->
                <div class="wizard-header">
                    <div id="stepHeader1" runat="server" class="wizard-step active">
                        <div class="wizard-step-num">1</div>
                        <span>Configure Contract &amp; Vendors</span>
                    </div>
                    <div
                        style="flex-grow: 1; align-self: center; height: 2px; background: #e2e8f0; margin: 0 15px; max-width: 250px;">
                    </div>
                    <div id="stepHeader2" runat="server" class="wizard-step">
                        <div class="wizard-step-num">2</div>
                        <span>Enroll Category Employees</span>
                    </div>
                    <div
                        style="flex-grow: 1; align-self: center; height: 2px; background: #e2e8f0; margin: 0 15px; max-width: 250px;">
                    </div>
                    <div id="stepHeader3" runat="server" class="wizard-step">
                        <div class="wizard-step-num">3</div>
                        <span>Assign Employee IDs</span>
                    </div>
                </div>

                <asp:MultiView ID="mvContracts" runat="server" ActiveViewIndex="0">

                    <!-- STEP 1: Contract Details and Vendor Assignment -->
                    <asp:View ID="viewStep1" runat="server">
                        <div class="card shadow-sm border-0 rounded-lg mb-4"
                            style="border-radius: 12px; overflow: hidden;">
                            <div class="card-header-gradient-contract">
                                <h5 class="m-0 font-weight-bold text-white"><i class="fas fa-file-contract mr-2"></i>
                                    Step 1: Contract Details</h5>
                            </div>
                            <div class="card-body panel-wizard bg-white text-dark p-4">

                                <div class="row mb-4">
                                    <!-- Category Select -->
                                    <div class="col-md-4 mb-3">
                                        <div class="card bg-light border p-3 rounded-lg" style="height: 100%;">
                                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                                    class="fas fa-tags mr-1 text-primary"></i> Category *</label>
                                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>

                                    <!-- Vendor Select -->
                                    <div class="col-md-4 mb-3">
                                        <div class="card bg-light border p-3 rounded-lg" style="height: 100%;">
                                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                                    class="fas fa-handshake mr-1 text-primary"></i> Winning Vendor
                                                *</label>
                                            <div class="input-group">
                                                <asp:DropDownList ID="ddlVendor" runat="server" CssClass="form-control">
                                                </asp:DropDownList>
                                                <div class="input-group-append">
                                                    <button type="button" class="btn btn-outline-primary"
                                                        data-toggle="modal" data-target="#addVendorModal"
                                                        data-bs-toggle="modal" data-bs-target="#addVendorModal"
                                                        onclick="clearModalVendorForm();"
                                                        title="Quick Add Vendor">
                                                        <i class="fas fa-plus"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- GeM ID -->
                                    <div class="col-md-4 mb-3">
                                        <div class="card bg-light border p-3 rounded-lg" style="height: 100%;">
                                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                                    class="fas fa-barcode mr-1 text-primary"></i> GeM ID *</label>
                                            <asp:TextBox ID="txtContractGemId" runat="server" CssClass="form-control"
                                                placeholder="e.g. GEM1001001" MaxLength="100"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>

                                <div class="row mb-4">
                                    <!-- Start Date -->
                                    <div class="col-md-4 mb-3">
                                        <div class="card bg-light border p-3 rounded-lg" style="height: 100%;">
                                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                                    class="far fa-calendar-alt mr-1 text-primary"></i> Contract Start
                                                Date *</label>
                                            <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control"
                                                TextMode="Date"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- End Date -->
                                    <div class="col-md-4 mb-3">
                                        <div class="card bg-light border p-3 rounded-lg" style="height: 100%;">
                                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                                    class="far fa-calendar-alt mr-1 text-primary"></i> Contract End Date
                                                *</label>
                                            <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control"
                                                TextMode="Date"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- Dated On -->
                                    <div class="col-md-4 mb-3">
                                        <div class="card bg-light border p-3 rounded-lg" style="height: 100%;">
                                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                                    class="far fa-calendar-alt mr-1 text-primary"></i> Dated On
                                                *</label>
                                            <asp:TextBox ID="txtContractDatedOn" runat="server" CssClass="form-control"
                                                TextMode="Date"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between mt-4 pt-3 border-top">
                                    <asp:LinkButton ID="btnCancelStep1" runat="server" Text="Cancel"
                                        CssClass="btn btn-outline-secondary px-4 font-weight-bold"
                                        OnClick="btnCancelWizard_Click" CausesValidation="false" />
                                    <asp:Button ID="btnNextStep" runat="server" Text="Next: Select Employees &gt;"
                                        CssClass="btn btn-primary px-4 shadow-sm animate-hover"
                                        style="background-color: #4f46e5; border-color: #4f46e5; font-weight: bold;"
                                        OnClick="btnNextStep_Click" />
                                </div>
                            </div>
                        </div>
                    </asp:View>

                    <!-- STEP 2: Employee Selection for Categories -->
                    <asp:View ID="viewStep2" runat="server">
                        <div class="card shadow-sm border-0 rounded-lg mb-4"
                            style="border-radius: 12px; overflow: hidden;">
                            <div class="card-header-gradient-contract">
                                <h5 class="m-0 font-weight-bold text-white"><i class="fas fa-users-cog mr-2"></i> Step
                                    2: Enroll Employees into Categories</h5>
                            </div>
                            <div class="card-body panel-wizard bg-white text-dark p-4">

                                <div class="alert alert-info border-0 shadow-sm d-flex align-items-center mb-4 py-3">
                                    <i class="fas fa-info-circle fa-2x mr-3 text-info"></i>
                                    <div>
                                        <span class="font-weight-bold">Contract Start Date:</span>
                                        <asp:Label ID="lblSelectedStartDate" runat="server" Font-Bold="true"
                                            ForeColor="#4f46e5"></asp:Label>
                                        <span class="mx-3">|</span>
                                        <span class="font-weight-bold">Vendor:</span>
                                        <span class="badge bg-primary text-white">
                                            <asp:Label ID="lblSelectedVendor" runat="server"></asp:Label>
                                        </span>
                                    </div>
                                </div>

                                <p class="text-muted mb-4" style="font-size: 0.9rem;">
                                    Verify the active workforce mapping. Employees currently active in the database are
                                    pre-checked in their respective categories. Check or uncheck employees to update
                                    their contract enrollment for the new period.
                                </p>

                                <div class="accordion" id="employeeCategoriesAccordion">
                                    <!-- ENROLLMENT GRID -->
                                    <div class="card mb-3 border rounded-lg" runat="server" id="divEnrollCard">
                                        <div class="card-header py-3 bg-light d-flex justify-content-between align-items-center"
                                            id="headingEnroll">
                                            <h6 class="m-0 font-weight-bold text-primary">
                                                <i class="fas fa-users mr-2"></i>
                                                <asp:Label ID="lblEnrollCategoryTitle" runat="server"></asp:Label>
                                                Category Employees (Vendor: <asp:Label ID="lblEnrollVendorTitle"
                                                    runat="server" Font-Bold="true"></asp:Label>)
                                            </h6>
                                            <span class="badge bg-primary text-white"><span id="lblCountEnroll">0</span>
                                                Checked</span>
                                        </div>
                                        <div class="card-body p-3">
                                            <!-- Filters and Search for Enroll Card -->
                                            <div class="row mb-3 bg-light p-2 rounded border mx-0 align-items-center animate-hover"
                                                style="font-size: 0.85rem; border-radius: 8px;">
                                                <div class="col-md-7 mb-2 mb-md-0 pl-1">
                                                    <div class="input-group input-group-sm">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text bg-white border-right-0"><i
                                                                    class="fas fa-search text-primary"></i></span>
                                                        </div>
                                                        <input type="text" id="txtSearchEnroll"
                                                            class="form-control border-left-0 font-weight-bold"
                                                            placeholder="Search name or ID..."
                                                            onkeyup="filterGridEmployees('gvEmployeesEnroll', 'txtSearchEnroll', 'ddlFilterEnroll');" />
                                                    </div>
                                                </div>
                                                <div class="col-md-5 mb-2 mb-md-0 pr-1">
                                                    <asp:DropDownList ID="ddlFilterEnroll" runat="server"
                                                        ClientIDMode="Static"
                                                        CssClass="form-control form-control-sm font-weight-bold"
                                                        onchange="filterGridEmployees('gvEmployeesEnroll', 'txtSearchEnroll', 'ddlFilterEnroll');">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
                                                <asp:GridView ID="gvEmployeesEnroll" runat="server"
                                                    ClientIDMode="Static" AutoGenerateColumns="False"
                                                    CssClass="table table-hover table-custom-emp mb-0"
                                                    DataKeyNames="MasterId" GridLines="None">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="70"
                                                            ItemStyle-HorizontalAlign="Center">
                                                            <HeaderTemplate>
                                                                <input type="checkbox" id="chkSelectAllEnroll"
                                                                    onclick="toggleSelectAll('gvEmployeesEnroll', this);"
                                                                    title="Select/Deselect All Visible"
                                                                    style="transform: scale(1.15); cursor: pointer;" />
                                                            </HeaderTemplate>
                                                            <ItemTemplate>
                                                                <asp:CheckBox ID="chkSelect" runat="server"
                                                                    onclick="updateCounts();" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="MasterId" HeaderText="Master ID" />
                                                        <asp:BoundField DataField="ID" HeaderText="Employee ID" />
                                                        <asp:BoundField DataField="Name" HeaderText="Employee Name" />
                                                        <asp:BoundField DataField="Department" HeaderText="Directorate" />
                                                        <asp:BoundField DataField="Category"
                                                            HeaderText="Current Category" />
                                                    </Columns>
                                                </asp:GridView>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between mt-4 pt-3 border-top">
                                    <div>
                                        <asp:Button ID="btnPrevStep" runat="server" Text="&lt; Back to Step 1"
                                            CssClass="btn btn-secondary px-4 font-weight-bold mr-2"
                                            OnClick="btnPrevStep_Click" />
                                        <asp:LinkButton ID="btnCancelStep2" runat="server" Text="Cancel"
                                            CssClass="btn btn-outline-secondary px-4 font-weight-bold"
                                            OnClick="btnCancelWizard_Click" CausesValidation="false" />
                                    </div>
                                    <asp:Button ID="btnSaveContract" runat="server"
                                        Text="Next: Assign Employee IDs &gt;"
                                        CssClass="btn btn-primary px-4 shadow-sm animate-hover font-weight-bold"
                                        OnClick="btnSaveContract_Click" />
                                </div>
                            </div>
                        </div>
                    </asp:View>

                    <!-- STEP 3: Assign Employee IDs -->
                    <asp:View ID="viewStep3" runat="server">
                        <div class="card shadow-sm border-0 rounded-lg mb-4"
                            style="border-radius: 12px; overflow: hidden;">
                            <div class="card-header-gradient-contract"
                                style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%);">
                                <h5 class="m-0 font-weight-bold text-white"><i class="fas fa-id-card mr-2"></i> Step 3:
                                    Assign Employee IDs</h5>
                            </div>
                            <div class="card-body panel-wizard bg-white text-dark p-4">
                                <p class="text-muted mb-4" style="font-size: 0.88rem;">
                                    Each employee's ID is unique under their assigned category. Verify or update the
                                    Employee IDs for the newly enrolled employees below.
                                    <span class="text-primary font-weight-bold">Tip: Use Enter or Arrow Up/Down keys to
                                        quickly navigate between rows.</span>
                                </p>

                                <!-- Initial Leave Balance Settings -->
                                <div class="card bg-light border p-3 rounded-lg mb-4">
                                    <div class="row align-items-center">
                                        <div class="col-md-8">
                                            <h6 class="font-weight-bold text-gray-800 mb-1">
                                                <i class="fas fa-calendar-check mr-2 text-primary"></i>Initial Leave
                                                Balance for New Contract *
                                            </h6>
                                            <span class="text-muted d-block" style="font-size: 0.78rem;">
                                                This resets the paid leave balance for all enrolled employees under this
                                                contract to this value. More leaves can be added via bulk/individual
                                                updates in the Employee Master.
                                            </span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtInitialLeaveBalance" runat="server"
                                                CssClass="form-control font-weight-bold text-center" TextMode="Number"
                                                min="0" step="0.5" placeholder="e.g. 15"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>

                                <div class="card mb-3 border rounded-lg">
                                    <div
                                        class="card-header py-3 bg-light d-flex justify-content-between align-items-center">
                                        <h6 class="m-0 font-weight-bold text-primary">
                                            <i class="fas fa-id-card mr-2"></i> Enrolled Employees for <asp:Label
                                                ID="lblStep3CategoryTitle" runat="server" Font-Bold="true"></asp:Label>
                                            Category (<asp:Label ID="lblSelectedCountEnroll" runat="server" Text="0">
                                            </asp:Label>)
                                        </h6>
                                    </div>
                                    <div class="card-body p-3 bg-white text-dark">
                                        <div class="alert alert-info py-2" id="divEnrollIdAlert" runat="server"
                                            visible="false">
                                            <i class="fas fa-info-circle mr-2"></i>No employees enrolled in this
                                            category.
                                        </div>
                                        <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                                            <asp:GridView ID="gvIdsEnroll" runat="server" AutoGenerateColumns="False"
                                                CssClass="table table-hover table-custom-emp mb-0"
                                                DataKeyNames="MasterId" GridLines="None">
                                                <Columns>
                                                    <asp:BoundField DataField="MasterId" HeaderText="Master ID"
                                                        ItemStyle-Width="120px" />
                                                    <asp:BoundField DataField="Name" HeaderText="Employee Name" />
                                                    <asp:BoundField DataField="Department" HeaderText="Directorate"
                                                        ItemStyle-Width="180px" />
                                                    <asp:TemplateField HeaderText="Current ID (Ref)"
                                                        ItemStyle-Width="150px">
                                                        <ItemTemplate>
                                                            <span
                                                                class="badge bg-white text-muted border py-1.5 px-2 font-weight-bold"
                                                                style="font-size: 0.85rem;">
                                                                <%# Eval("ID") %>
                                                            </span>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="New Employee ID *"
                                                        ItemStyle-Width="200px">
                                                        <ItemTemplate>
                                                            <asp:TextBox ID="txtNewEmpId" runat="server"
                                                                Text='<%# Eval("ID") %>'
                                                                CssClass="form-control form-control-sm employee-id-input font-weight-bold text-primary"
                                                                placeholder="Enter ID..."></asp:TextBox>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                </div>

                                <!-- Step 3 Navigation -->
                                <div class="d-flex justify-content-between mt-4 pt-3 border-top">
                                    <div>
                                        <asp:Button ID="btnBackToStep2" runat="server" Text="&lt; Back to Step 2"
                                            CssClass="btn btn-secondary px-4 font-weight-bold mr-2"
                                            OnClick="btnBackToStep2_Click" CausesValidation="false" />
                                        <asp:LinkButton ID="btnCancelStep3" runat="server" Text="Cancel"
                                            CssClass="btn btn-outline-secondary px-4 font-weight-bold"
                                            OnClick="btnCancelWizard_Click" CausesValidation="false" />
                                    </div>
                                    <asp:Button ID="btnFinalizeContract" runat="server"
                                        Text="Save &amp; Activate Contract Period"
                                        CssClass="btn btn-success px-4 shadow-sm animate-hover font-weight-bold"
                                        style="background-color: #10b981; border-color: #10b981;"
                                        OnClick="btnFinalizeContract_Click"
                                        OnClientClick="return confirmContractActivation(this);" />
                                </div>
                            </div>
                        </div>
                    </asp:View>

                </asp:MultiView>
            </div>
        </asp:Panel>

        <!-- END CONTRACT MODAL -->
        <div class="modal fade" id="endContractModal" tabindex="-1" role="dialog"
            aria-labelledby="endContractModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #e74a3b 0%, #be2617 100%);">
                        <h5 class="modal-title font-weight-bold" id="endContractModalLabel"><i
                                class="fas fa-calendar-times mr-2"></i> End Contract Period</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark">
                        <asp:HiddenField ID="hfEndContractStartDate" runat="server" />

                        <div class="alert alert-warning border-0 shadow-sm d-flex align-items-center mb-4">
                            <i class="fas fa-exclamation-triangle fa-2x mr-3 text-warning"></i>
                            <div>
                                Ending this contract period will close the period and automatically mark all currently
                                enrolled employees as **Resigned** on the end date.
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">Contract Start Date</label>
                            <asp:Label ID="lblEndContractStartDate" runat="server" CssClass="form-control bg-light"
                                Font-Bold="true"></asp:Label>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">Contract End Date *</label>
                            <asp:TextBox ID="txtEndContractEndDate" runat="server" CssClass="form-control"
                                TextMode="Date"></asp:TextBox>
                        </div>

                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="chkConfirmEnd" />
                            <label class="form-check-label text-danger font-weight-bold" for="chkConfirmEnd">
                                I confirm that I want to close this contract period.
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal"
                            data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnModalConfirmEnd" runat="server" Text="Confirm End Contract"
                            CssClass="btn btn-danger" OnClick="btnModalConfirmEnd_Click"
                            OnClientClick="return validateEndContract();" />
                    </div>
                </div>
            </div>
        </div>

        <!-- EXTEND CONTRACT MODAL -->
        <div class="modal fade" id="extendContractModal" tabindex="-1" role="dialog"
            aria-labelledby="extendContractModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);">
                        <h5 class="modal-title font-weight-bold" id="extendContractModalLabel"><i
                                class="fas fa-calendar-plus mr-2"></i> Extend Contract Period</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark">
                        <asp:HiddenField ID="hfExtendContractId" runat="server" />

                        <div class="alert alert-info border-0 shadow-sm d-flex align-items-center mb-4">
                            <i class="fas fa-info-circle fa-2x mr-3 text-info"></i>
                            <div>
                                This will extend the end date of the active contract. Active employee engagements under
                                this contract will continue seamlessly without interruption.
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">Contract / Category</label>
                            <asp:Label ID="lblExtendContractDisplay" runat="server" CssClass="form-control bg-light"
                                Font-Bold="true"></asp:Label>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">GeM ID</label>
                            <asp:Label ID="lblExtendContractGemId" runat="server" CssClass="form-control bg-light"
                                Font-Bold="true"></asp:Label>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">Current End Date</label>
                            <asp:Label ID="lblExtendContractCurrentEndDate" runat="server"
                                CssClass="form-control bg-light" Font-Bold="true"></asp:Label>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">New Extended End Date *</label>
                            <asp:TextBox ID="txtExtendContractNewEndDate" runat="server" CssClass="form-control"
                                TextMode="Date"></asp:TextBox>
                        </div>

                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="chkConfirmExtend" />
                            <label class="form-check-label text-primary font-weight-bold" for="chkConfirmExtend">
                                I confirm that I want to extend this contract period.
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal"
                            data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnModalConfirmExtend" runat="server" Text="Confirm Extension"
                            CssClass="btn btn-info text-white" style="background-color: #0284c7; border-color: #0284c7;"
                            OnClick="btnModalConfirmExtend_Click" OnClientClick="return validateExtendContract();" />
                    </div>
                </div>
            </div>
        </div>

        <!-- DELETE CONTRACT MODAL -->
        <div class="modal fade" id="deleteContractModal" tabindex="-1" role="dialog"
            aria-labelledby="deleteContractModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #dc3545 0%, #a71d2a 100%);">
                        <h5 class="modal-title font-weight-bold" id="deleteContractModalLabel"><i
                                class="fas fa-trash-alt mr-2"></i> Delete Contract Period</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark">
                        <asp:HiddenField ID="hfDeleteContractStartDate" runat="server" />

                        <div class="alert alert-danger border-0 shadow-sm d-flex align-items-center mb-4">
                            <i class="fas fa-exclamation-triangle fa-2x mr-3 text-danger"></i>
                            <div>
                                <strong>WARNING:</strong> Deleting this contract period will permanently remove all
                                associated vendor assignments, employee engagements, and **any recorded attendance
                                data** for this period.
                                If this is the active contract, the previous contract period (if any) will be re-opened
                                and employees will be reverted to their previous state.
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1">Contract Start Date</label>
                            <asp:Label ID="lblDeleteContractStartDate" runat="server" CssClass="form-control bg-light"
                                Font-Bold="true"></asp:Label>
                        </div>

                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="chkConfirmDelete" />
                            <label class="form-check-label text-danger font-weight-bold" for="chkConfirmDelete">
                                I confirm that I want to delete this contract period and all associated history.
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal"
                            data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnModalConfirmDelete" runat="server" Text="Delete Contract"
                            CssClass="btn btn-danger" OnClick="btnModalConfirmDelete_Click"
                            OnClientClick="return validateDeleteContract();" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit Contract Details Modal -->
        <div class="modal fade" id="editContractModal" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 14px; overflow: hidden;">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%); padding: 16px 24px;">
                        <h5 class="modal-title font-weight-bold text-white"><i class="fas fa-edit mr-2"></i> Edit
                            Contract Info</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close"
                            style="opacity: 0.8; outline: none; border: none; background: transparent; font-size: 1.5rem; cursor: pointer;">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body p-4 bg-white text-dark">
                        <asp:HiddenField ID="hfEditContractId" runat="server" />

                        <div class="form-group mb-3">
                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                    class="fas fa-barcode mr-1 text-primary"></i> GeM Contract No / ID</label>
                            <asp:TextBox ID="txtEditContractGemId" runat="server" CssClass="form-control"
                                placeholder="e.g. GEMC-511687761569464"></asp:TextBox>
                        </div>

                        <div class="form-group mb-0">
                            <label class="font-weight-bold text-gray-800 mb-2"><i
                                    class="far fa-calendar-alt mr-1 text-primary"></i> Dated On</label>
                            <asp:TextBox ID="txtEditContractDatedOn" runat="server" CssClass="form-control"
                                TextMode="Date"></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer bg-light"
                        style="border-top: 1px solid #f1f5f9; padding: 16px 24px; display: flex; justify-content: space-between;">
                        <button type="button" class="btn btn-secondary px-3" data-dismiss="modal"
                            data-bs-dismiss="modal">Close</button>
                        <asp:Button ID="btnSaveEditContract" runat="server" Text="Update Contract"
                            CssClass="btn btn-primary px-4 shadow-sm animate-hover"
                            style="background-color: #4f46e5; border-color: #4f46e5; font-weight: bold;"
                            OnClick="btnSaveEditContract_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- QUICK ADD VENDOR MODAL -->
        <div class="modal fade" id="addVendorModal" tabindex="-1" role="dialog" aria-labelledby="addVendorModalLabel"
            aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 14px; overflow: hidden;">
                    <div class="modal-header text-white" style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); padding: 16px 24px;">
                        <h5 class="modal-title font-weight-bold text-white mb-0" id="addVendorModalLabel">
                            <i class="fas fa-handshake mr-2 text-primary"></i> Quick Add Vendor
                        </h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close" style="opacity: 0.9; outline: none; border: none; background: transparent; font-size: 1.5rem; color: #fff; cursor: pointer;">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body p-4 bg-white text-dark">
                        <div class="row mb-3">
                            <div class="col-md-4 mb-2 mb-md-0">
                                <label class="font-weight-bold text-gray-700 mb-1" style="font-size:0.8rem; text-transform:uppercase; letter-spacing:0.03em;">
                                    <i class="fas fa-hashtag mr-1 text-muted"></i> Vendor Master ID
                                </label>
                                <asp:TextBox ID="txtModalMasterId" runat="server" CssClass="form-control" ReadOnly="true"
                                    BackColor="#f8fafc" Text="(Auto-Generated)" style="font-weight:600; color:#475569; border:1px solid #e2e8f0;"></asp:TextBox>
                            </div>
                            <div class="col-md-8">
                                <label class="font-weight-bold text-gray-800 mb-1" style="font-size:0.8rem; text-transform:uppercase; letter-spacing:0.03em;">
                                    <i class="fas fa-building mr-1 text-primary"></i> Vendor Name <span class="text-danger">*</span>
                                </label>
                                <asp:TextBox ID="txtModalVendorName" runat="server" CssClass="form-control"
                                    placeholder="e.g. Vishal Manpower Services" MaxLength="150" style="font-weight:500;"></asp:TextBox>
                            </div>
                        </div>

                        <asp:HiddenField ID="hfModalVendorContacts" runat="server" ClientIDMode="Static" />

                        <!-- Dynamic Contact Escalation Matrix -->
                        <div class="escalation-matrix-section mb-3">
                            <div class="escalation-matrix-header">
                                <span class="escalation-matrix-title">
                                    <i class="fas fa-sitemap text-indigo mr-1"></i> Contact Escalation Matrix
                                </span>
                                <button type="button" class="btn-add-contact" onclick="addModalContactRow('', '', '', '')">
                                    <i class="fas fa-plus"></i> Add Contact Level
                                </button>
                            </div>
                            <div id="modalContactLevelsContainer"></div>
                        </div>

                        <!-- Hidden legacy fields to satisfy WebForms designer backing controls -->
                        <div style="display:none;">
                            <asp:TextBox ID="txtModalContactName" runat="server"></asp:TextBox>
                            <asp:TextBox ID="txtModalContactPhone" runat="server"></asp:TextBox>
                            <asp:TextBox ID="txtModalAddress" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer bg-light px-4 py-3 border-top-0 d-flex justify-content-end gap-2">
                        <button type="button" class="btn btn-secondary font-weight-bold px-4" data-dismiss="modal"
                            data-bs-dismiss="modal" style="border-radius: 8px;">Cancel</button>
                        <asp:Button ID="btnModalSaveVendor" runat="server" Text="Save Vendor" CssClass="btn btn-success font-weight-bold px-4 shadow-sm"
                            style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none; border-radius: 8px;"
                            OnClick="btnModalSaveVendor_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- UNSELECTED EMPLOYEES MODAL -->
        <div class="modal fade" id="unselectedEmployeesModal" tabindex="-1" role="dialog"
            aria-labelledby="unselectedEmployeesModalLabel" aria-hidden="true" data-backdrop="static"
            data-bs-backdrop="static">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%);">
                        <h5 class="modal-title font-weight-bold" id="unselectedEmployeesModalLabel"><i
                                class="fas fa-exclamation-circle mr-2"></i> Unenrolled Active Employees</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark">
                        <div class="alert alert-warning border-0 shadow-sm d-flex align-items-center mb-4">
                            <i class="fas fa-exclamation-triangle fa-2x mr-3 text-warning"></i>
                            <div>
                                The following active employees are <strong>not selected</strong> in any category. Please
                                decide whether to mark them as <strong>Resigned</strong> or enroll them in a category
                                (in case they were missed by mistake).
                            </div>
                        </div>

                        <div style="max-height: 400px; overflow-y: auto;">
                            <asp:Repeater ID="rptUnselectedEmployees" runat="server"
                                OnItemDataBound="rptUnselectedEmployees_ItemDataBound">
                                <HeaderTemplate>
                                    <table class="table table-hover table-striped mb-0 table-custom-emp"
                                        style="font-size: 0.9rem;">
                                        <thead class="bg-light text-muted"
                                            style="font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.05em;">
                                            <tr>
                                                <th style="padding: 10px 16px;">Employee ID</th>
                                                <th style="padding: 10px 16px;">Employee Name</th>
                                                <th style="padding: 10px 16px;">Current Category</th>
                                                <th style="padding: 10px 16px; width: 220px;">Action / New Category</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td style="padding: 10px 16px; vertical-align: middle;">
                                            <asp:HiddenField ID="hfMasterId" runat="server"
                                                Value='<%# Eval("MasterId") %>' />
                                            <%# Eval("ID") %>
                                        </td>
                                        <td
                                            style="padding: 10px 16px; vertical-align: middle; font-weight: bold; color: #1e293b;">
                                            <%# Eval("Name") %>
                                        </td>
                                        <td style="padding: 10px 16px; vertical-align: middle;">
                                            <%# Eval("Category") %>
                                        </td>
                                        <td style="padding: 10px 16px; vertical-align: middle;">
                                            <asp:DropDownList ID="ddlUnselectedAction" runat="server"
                                                CssClass="form-control form-control-sm font-weight-bold">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary font-weight-bold" data-dismiss="modal"
                            data-bs-dismiss="modal">Go Back &amp; Edit</button>
                        <asp:Button ID="btnConfirmSave" runat="server" Text="Confirm Actions &amp; Save Contract"
                            CssClass="btn btn-success font-weight-bold shadow-sm animate-hover"
                            style="background-color: #10b981; border-color: #10b981;" OnClick="btnConfirmSave_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- MANAGE EMPLOYEES MODAL -->
        <div class="modal fade" id="manageEmployeesModal" tabindex="-1" role="dialog"
            aria-labelledby="manageEmployeesModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%);">
                        <h5 class="modal-title font-weight-bold" id="manageEmployeesModalLabel">
                            <i class="fas fa-users-cog mr-2"></i> Manage Contract Employees
                        </h5>
                        <button type="button" class="close text-white" data-dismiss="modal" data-bs-dismiss="modal"
                            aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body p-4 bg-white text-dark">
                        <asp:HiddenField ID="hfManageContractPeriodId" runat="server" />

                        <div class="manage-contract-info-card">
                            <div class="manage-contract-info-title">
                                <asp:Label ID="lblManageContractTitle" runat="server"></asp:Label>
                            </div>
                            <p class="text-muted mb-0" style="font-size: 0.88rem;">
                                Vendor: <span class="font-weight-bold text-dark">
                                    <asp:Label ID="lblManageContractVendor" runat="server"></asp:Label>
                                </span> <span class="mx-2 text-muted">|</span>
                                GeM ID: <span class="font-weight-bold text-dark">
                                    <asp:Label ID="lblManageContractGemId" runat="server"></asp:Label>
                                </span> <span class="mx-2 text-muted">|</span>
                                Start Date: <span class="font-weight-bold text-dark">
                                    <asp:Label ID="lblManageContractStart" runat="server"></asp:Label>
                                </span>
                            </p>
                        </div>

                        <!-- Add Employee Section -->
                        <div class="manage-add-section">
                            <div class="manage-add-title"><i class="fas fa-user-plus text-success"></i> Add Employee to
                                Contract</div>
                            <div class="row align-items-center">
                                <div class="col-md-5 mb-2 mb-md-0">
                                    <asp:DropDownList ID="ddlManageAddEmployee" runat="server"
                                        CssClass="form-control select-custom w-100"></asp:DropDownList>
                                </div>
                                <div class="col-md-4 mb-2 mb-md-0">
                                    <asp:TextBox ID="txtManageAddStartDate" runat="server" TextMode="Date"
                                        CssClass="form-control select-custom w-100" placeholder="Start Date">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <asp:LinkButton ID="btnManageAddEmployee" runat="server"
                                        OnClick="btnManageAddEmployee_Click"
                                        CssClass="btn-add-custom w-100 font-weight-bold text-white text-decoration-none"
                                        style="display: flex; align-items: center; justify-content: center; height: 38px;">
                                        <i class="fas fa-plus mr-1"></i> Add
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>

                        <!-- Enrolled Employees Grid -->
                        <h6 class="font-weight-bold text-dark mb-2"><i class="fas fa-list mr-1 text-primary"></i>
                            Currently Enrolled Employees</h6>
                        <div class="table-responsive border rounded-lg shadow-sm"
                            style="max-height: 280px; overflow-y: auto;">
                            <asp:GridView ID="gvManageEnrolledEmployees" runat="server" AutoGenerateColumns="False"
                                CssClass="table table-hover table-custom-emp mb-0" DataKeyNames="MasterId"
                                OnRowCommand="gvManageEnrolledEmployees_RowCommand" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="MasterId" HeaderText="Master ID" ItemStyle-Width="100"
                                        ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="Employee Name">
                                        <ItemTemplate>
                                            <span class="font-weight-bold" style="color: #1e293b;">
                                                <%# Eval("Name") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Department" HeaderText="Directorate"
                                        ItemStyle-Width="130" />
                                    <asp:TemplateField HeaderText="Current ID (Ref)" ItemStyle-Width="130"
                                        ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <span class="badge bg-white text-muted border py-1.5 px-2 font-weight-bold"
                                                style="font-size: 0.85rem;">
                                                <%# Eval("ID") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="New Employee ID *" ItemStyle-Width="150"
                                        ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtGridEmpID" runat="server" Text='<%# Eval("ID") %>'
                                                CssClass="form-control form-control-sm manage-employee-id-input font-weight-bold text-primary"
                                                placeholder="Enter ID..."></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="100"
                                        ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <div class="action-cell-container">
                                                <asp:LinkButton ID="btnRemoveEmp" runat="server" CommandName="RemoveEmp"
                                                    CommandArgument='<%# Eval("MasterId") %>'
                                                    CssClass="btn-grid-action btn-grid-remove"
                                                    OnClientClick='<%# "return confirmRemoveEmp(this, \"" + Eval("Name") + "\");" %>'
                                                    title="Remove Employee">
                                                    <i class="fas fa-user-minus"></i> Remove
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="text-center p-3 text-muted">
                                        No employees currently enrolled in this contract.
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="modal-footer bg-light d-flex justify-content-between">
                        <asp:Button ID="btnUpdateAllIds" runat="server" Text="Update All IDs"
                            CssClass="btn btn-success font-weight-bold shadow-sm animate-hover px-4"
                            OnClick="btnUpdateAllIds_Click"
                            style="background-color: #4f46e5; border-color: #4f46e5; border-radius: 8px;" />
                        <button type="button" class="btn btn-secondary font-weight-bold px-4" data-dismiss="modal"
                            data-bs-dismiss="modal" style="border-radius: 8px;">Close</button>
                    </div>
                </div>
            </div>
        </div>
        </div>

        <script>
            // Move modals inside the form tag to handle WebForms postbacks correctly
            document.addEventListener('DOMContentLoaded', function () {
                var form = document.getElementById('form1');
                var addVendorModal = document.getElementById('addVendorModal');
                if (form && addVendorModal) {
                    form.appendChild(addVendorModal);
                }
                var editContractModal = document.getElementById('editContractModal');
                if (form && editContractModal) {
                    form.appendChild(editContractModal);
                }
                var endContractModal = document.getElementById('endContractModal');
                if (form && endContractModal) {
                    form.appendChild(endContractModal);
                }
                var deleteContractModal = document.getElementById('deleteContractModal');
                if (form && deleteContractModal) {
                    form.appendChild(deleteContractModal);
                }
                var unselectedModal = document.getElementById('unselectedEmployeesModal');
                if (form && unselectedModal) {
                    form.appendChild(unselectedModal);
                }
                var manageEmployeesModal = document.getElementById('manageEmployeesModal');
                if (form && manageEmployeesModal) {
                    form.appendChild(manageEmployeesModal);

                    // When modal is shown, auto-focus and select first ID input inside it
                    manageEmployeesModal.addEventListener('shown.bs.modal', function () {
                        var firstInput = manageEmployeesModal.querySelector('.manage-employee-id-input');
                        if (firstInput) {
                            setTimeout(function () {
                                firstInput.focus();
                                firstInput.select();
                            }, 100);
                        }
                    });
                }
                if (addVendorModal) {
                    addVendorModal.addEventListener('show.bs.modal', function () {
                        var container = document.getElementById('modalContactLevelsContainer');
                        if (container && container.children.length === 0) {
                            addModalContactRow('', '', '', '');
                        }
                    });
                }

                updateCounts();
                setupIdKeyboardNavigation();
                setupManageGridKeyboardNavigation();
            });

            // ── Quick Add Vendor Escalation Matrix JS Helpers ────────────────
            function addModalContactRow(name, phone, email, address) {
                name = name || '';
                phone = phone || '';
                email = email || '';
                address = address || '';

                var container = document.getElementById('modalContactLevelsContainer');
                if (!container) return;

                var levelNum = container.children.length + 1;
                var card = document.createElement('div');
                card.className = 'contact-level-card';

                var isPrimary = (levelNum === 1);
                var badgeClass = isPrimary ? 'badge-level-1' : 'badge-level-n';
                var levelLabel = isPrimary ? 'Level 1 &ndash; Primary Contact' : ('Level ' + levelNum + ' Escalation');
                var nameReq = 'required';
                var phoneReq = 'required';
                var emailReq = isPrimary ? 'required' : '';
                var addressReq = isPrimary ? 'required' : '';
                var nameReqLabel = ' *';
                var phoneReqLabel = ' *';
                var emailReqLabel = isPrimary ? ' *' : '';
                var addressReqLabel = isPrimary ? ' *' : '';

                var removeBtnHtml = isPrimary ? '' : '<button type="button" class="btn-remove-contact" onclick="removeModalContactRow(this)"><i class="fas fa-trash-alt mr-1"></i> Remove</button>';

                card.innerHTML = 
                    '<div class="contact-level-title">' +
                        '<span class="contact-level-badge ' + badgeClass + '">' + levelLabel + '</span>' +
                    '</div>' +
                    removeBtnHtml +
                    '<div class="contact-field-row mb-2">' +
                        '<div>' +
                            '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Contact Name' + nameReqLabel + '</label>' +
                            '<input type="text" class="form-control form-control-sm mvc-name" value="' + EscapeModalHtmlAttr(name) + '" placeholder="Full Name" ' + nameReq + ' oninput="syncModalContactsToHidden()" />' +
                        '</div>' +
                        '<div>' +
                            '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Phone Number' + phoneReqLabel + '</label>' +
                            '<input type="text" class="form-control form-control-sm mvc-phone" value="' + EscapeModalHtmlAttr(phone) + '" placeholder="e.g. 9876543210" ' + phoneReq + ' oninput="syncModalContactsToHidden()" />' +
                        '</div>' +
                    '</div>' +
                    '<div class="contact-field-row">' +
                        '<div>' +
                            '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Email Address' + emailReqLabel + '</label>' +
                            '<input type="email" class="form-control form-control-sm mvc-email" value="' + EscapeModalHtmlAttr(email) + '" placeholder="email@domain.com" ' + emailReq + ' oninput="syncModalContactsToHidden()" />' +
                        '</div>' +
                        '<div>' +
                            '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Contact Address' + addressReqLabel + '</label>' +
                            '<input type="text" class="form-control form-control-sm mvc-address" value="' + EscapeModalHtmlAttr(address) + '" placeholder="Address / Office info" ' + addressReq + ' oninput="syncModalContactsToHidden()" />' +
                        '</div>' +
                    '</div>';

                container.appendChild(card);
                syncModalContactsToHidden();
            }

            function removeModalContactRow(btn) {
                var card = btn.closest('.contact-level-card');
                if (card) {
                    card.remove();
                    _renumberModalCards();
                    syncModalContactsToHidden();
                }
            }

            function _renumberModalCards() {
                var container = document.getElementById('modalContactLevelsContainer');
                if (!container) return;
                var cards = container.querySelectorAll('.contact-level-card');
                cards.forEach(function (card, idx) {
                    var levelNum = idx + 1;
                    var isPrimary = (levelNum === 1);
                    var badge = card.querySelector('.contact-level-badge');
                    if (badge) {
                        badge.className = 'contact-level-badge ' + (isPrimary ? 'badge-level-1' : 'badge-level-n');
                        badge.innerHTML = isPrimary ? 'Level 1 &ndash; Primary Contact' : ('Level ' + levelNum + ' Escalation');
                    }
                    var removeBtn = card.querySelector('.btn-remove-contact');
                    if (isPrimary && removeBtn) {
                        removeBtn.remove();
                    }
                });
            }

            function syncModalContactsToHidden() {
                var container = document.getElementById('modalContactLevelsContainer');
                var hfContacts = document.getElementById('<%= hfModalVendorContacts.ClientID %>');
                var txtName = document.getElementById('<%= txtModalContactName.ClientID %>');
                var txtPhone = document.getElementById('<%= txtModalContactPhone.ClientID %>');
                var txtAddr = document.getElementById('<%= txtModalAddress.ClientID %>');
                if (!container || !hfContacts) return;

                var cards = container.querySelectorAll('.contact-level-card');
                var list = [];

                cards.forEach(function (card, idx) {
                    var name = (card.querySelector('.mvc-name') ? card.querySelector('.mvc-name').value : '').trim();
                    var phone = (card.querySelector('.mvc-phone') ? card.querySelector('.mvc-phone').value : '').trim();
                    var email = (card.querySelector('.mvc-email') ? card.querySelector('.mvc-email').value : '').trim();
                    var address = (card.querySelector('.mvc-address') ? card.querySelector('.mvc-address').value : '').trim();

                    list.push({ priority: idx + 1, name: name, phone: phone, email: email, address: address });

                    if (idx === 0) {
                        if (txtName) txtName.value = name;
                        if (txtPhone) txtPhone.value = phone;
                        if (txtAddr) txtAddr.value = address;
                    }
                });

                hfContacts.value = JSON.stringify(list);
            }

            function clearModalVendorForm() {
                var txtVendorName = document.getElementById('<%= txtModalVendorName.ClientID %>');
                var txtContactName = document.getElementById('<%= txtModalContactName.ClientID %>');
                var txtContactPhone = document.getElementById('<%= txtModalContactPhone.ClientID %>');
                var txtAddress = document.getElementById('<%= txtModalAddress.ClientID %>');
                var hfContacts = document.getElementById('<%= hfModalVendorContacts.ClientID %>');

                if (txtVendorName) txtVendorName.value = '';
                if (txtContactName) txtContactName.value = '';
                if (txtContactPhone) txtContactPhone.value = '';
                if (txtAddress) txtAddress.value = '';
                if (hfContacts) hfContacts.value = '';

                var container = document.getElementById('modalContactLevelsContainer');
                if (container) container.innerHTML = '';
                addModalContactRow('', '', '', '');
                syncModalContactsToHidden();
            }

            function EscapeModalHtmlAttr(str) {
                if (!str) return '';
                return String(str).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            }

            let removeEmpTarget = null;
            function confirmRemoveEmp(sender, name) {
                if (removeEmpTarget === sender) {
                    removeEmpTarget = null;
                    return true; // Allow postback
                }

                Swal.fire({
                    title: 'Remove Employee',
                    text: `Are you sure you want to remove '${name}' from this contract? If they have no attendance records, their enrollment will be deleted and their previous status restored.`,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#ef4444',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Yes, remove them!',
                    cancelButtonText: 'Cancel',
                    customClass: {
                        popup: 'shadow-lg rounded-lg border-0 bg-white text-dark',
                        title: 'font-weight-bold text-dark',
                        confirmButton: 'btn btn-danger font-weight-bold px-4 py-2',
                        cancelButton: 'btn btn-secondary font-weight-bold px-4 py-2 ml-2'
                    },
                    buttonsStyling: false
                }).then((result) => {
                    if (result.isConfirmed) {
                        removeEmpTarget = sender;
                        sender.click(); // Re-trigger the click event
                    }
                });

                return false; // Block immediate postback
            }

            // Handle page reloads / postbacks (ASP.NET WebForms specific)
            if (typeof window.Sys !== 'undefined' && typeof window.Sys.WebForms !== 'undefined') {
                var prm = Sys.WebForms.PageRequestManager.getInstance();
                prm.add_endRequest(function () {
                    updateCounts();
                    setupManageGridKeyboardNavigation();
                });
            }

            function setupManageGridKeyboardNavigation() {
                var modalBody = document.querySelector('#manageEmployeesModal .modal-body');
                if (!modalBody) return;
                var inputs = modalBody.querySelectorAll('.manage-employee-id-input');
                inputs.forEach(function (input) {
                    // Focus: select all text to allow quick overwrite
                    input.removeEventListener('focus', handleManageInputFocus);
                    input.addEventListener('focus', handleManageInputFocus);

                    // Keydown: handle Enter, ArrowUp, ArrowDown
                    input.removeEventListener('keydown', handleManageInputKeydown);
                    input.addEventListener('keydown', handleManageInputKeydown);
                });
            }

            function handleManageInputFocus() {
                this.select();
            }

            function handleManageInputKeydown(e) {
                var modalBody = this.closest('.modal-body');
                if (!modalBody) return;
                var inputsList = Array.from(modalBody.querySelectorAll('.manage-employee-id-input:not([disabled])'));
                var currIdx = inputsList.indexOf(this);
                if (currIdx === -1) return;

                if (e.key === 'Enter' || e.key === 'ArrowDown') {
                    e.preventDefault();
                    var nextInput = inputsList[currIdx + 1];
                    if (nextInput) {
                        nextInput.focus();
                    }
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    var prevInput = inputsList[currIdx - 1];
                    if (prevInput) {
                        prevInput.focus();
                    }
                }
            }



            function validateEndContract() {
                var chk = document.getElementById('chkConfirmEnd');
                if (!chk || !chk.checked) {
                    if (typeof showToast === 'function') {
                        showToast("Please check the confirmation box to proceed.", "error");
                    } else {
                        alert("Please check the confirmation box to proceed.");
                    }
                    return false;
                }
                return true;
            }

            function validateDeleteContract() {
                var chk = document.getElementById('chkConfirmDelete');
                if (!chk || !chk.checked) {
                    if (typeof showToast === 'function') {
                        showToast("Please check the confirmation box to proceed.", "error");
                    } else {
                        alert("Please check the confirmation box to proceed.");
                    }
                    return false;
                }
                return true;
            }

            // Count checked employees in each GridView
            function updateCounts() {
                updateCountForGrid('gvEmployeesEnroll', 'lblCountEnroll');
            }

            function updateCountForGrid(gridId, labelId) {
                var gv = document.getElementById(gridId);
                if (!gv) {
                    gv = document.querySelector('[id$="' + gridId + '"]');
                }
                var lbl = document.getElementById(labelId);
                if (!gv || !lbl) return;

                // Only count checkboxes inside tbody cells (exclude headers)
                var checkboxes = gv.querySelectorAll('td input[type="checkbox"]:checked');
                lbl.textContent = checkboxes.length;
            }

            function filterGridEmployees(gridId, searchInputId, filterDropdownId) {
                var searchInput = document.getElementById(searchInputId);
                var filterDropdown = document.getElementById(filterDropdownId);
                var gv = document.getElementById(gridId);
                if (!gv) {
                    gv = document.querySelector('[id$="' + gridId + '"]');
                }
                if (!searchInput || !filterDropdown || !gv) return;

                var query = searchInput.value.toLowerCase();
                var category = filterDropdown.value;

                var rows = gv.querySelectorAll('tr:not(:first-child)');
                rows.forEach(function (row) {
                    // columns: 0=Checkbox, 1=MasterID, 2=EmployeeID, 3=Name, 4=Dept, 5=Category
                    var masterCell = row.cells[1];
                    var empIdCell = row.cells[2];
                    var nameCell = row.cells[3];
                    var categoryCell = row.cells[5];

                    var masterText = masterCell ? masterCell.textContent.toLowerCase() : '';
                    var empIdText = empIdCell ? empIdCell.textContent.toLowerCase() : '';
                    var nameText = nameCell ? nameCell.textContent.toLowerCase() : '';
                    var categoryText = categoryCell ? categoryCell.textContent.trim() : '';

                    var matchesSearch = masterText.includes(query) || empIdText.includes(query) || nameText.includes(query);
                    var matchesCategory = (category === 'All' || categoryText.toLowerCase() === category.toLowerCase());

                    if (matchesSearch && matchesCategory) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            function toggleSelectAll(gridId, headerChk) {
                var gv = document.getElementById(gridId);
                if (!gv) {
                    gv = document.querySelector('[id$="' + gridId + '"]');
                }
                if (!gv) return;
                var rows = gv.querySelectorAll('tr:not(:first-child)');
                rows.forEach(function (row) {
                    // Only select/deselect visible rows that match the filter query
                    if (row.style.display !== 'none') {
                        var chk = row.querySelector('input[type="checkbox"]');
                        if (chk) {
                            chk.checked = headerChk.checked;
                        }
                    }
                });
                updateCounts();
            }

            function openEndContractModal(startDateVal, startDateDisplay) {
                var hf = document.getElementById('<%= hfEndContractStartDate.ClientID %>');
                if (hf) {
                    hf.value = startDateVal;
                }

                var lbl = document.getElementById('<%= lblEndContractStartDate.ClientID %>');
                if (lbl) {
                    lbl.textContent = startDateDisplay;
                }

                var txt = document.getElementById('<%= txtEndContractEndDate.ClientID %>');
                if (txt) {
                    var today = new Date().toISOString().split('T')[0];
                    txt.value = today;
                }

                var chk = document.getElementById('chkConfirmEnd');
                if (chk) {
                    chk.checked = false;
                }

                var modalEl = document.getElementById('endContractModal');
                if (modalEl) {
                    if (window.bootstrap && window.bootstrap.Modal) {
                        var modal = window.bootstrap.Modal.getInstance(modalEl) || new window.bootstrap.Modal(modalEl);
                        modal.show();
                    } else if (window.jQuery && window.jQuery.fn.modal) {
                        window.jQuery(modalEl).modal('show');
                    } else {
                        modalEl.classList.add('show');
                        modalEl.style.display = 'block';
                        document.body.classList.add('modal-open');
                    }
                }
            }

            function formatDateDisplay(dateStr) {
                if (!dateStr) return "N/A";
                var parts = dateStr.split('-');
                if (parts.length !== 3) return dateStr;
                var year = parts[0];
                var monthIdx = parseInt(parts[1], 10) - 1;
                var day = parts[2];
                var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                return day + "-" + months[monthIdx] + "-" + year;
            }

            function validateExtendContract() {
                var chk = document.getElementById('chkConfirmExtend');
                if (!chk || !chk.checked) {
                    if (typeof showToast === 'function') {
                        showToast("Please check the confirmation box to proceed.", "error");
                    } else {
                        alert("Please check the confirmation box to proceed.");
                    }
                    return false;
                }

                var txt = document.getElementById('<%= txtExtendContractNewEndDate.ClientID %>');
                if (!txt || !txt.value) {
                    if (typeof showToast === 'function') {
                        showToast("New Extended End Date is required.", "error");
                    } else {
                        alert("New Extended End Date is required.");
                    }
                    return false;
                }
                return true;
            }

            function openExtendContractModal(periodId, displayLabel, currentEndDate, gemId) {
                var hf = document.getElementById('<%= hfExtendContractId.ClientID %>');
                if (hf) {
                    hf.value = periodId;
                }

                var lbl = document.getElementById('<%= lblExtendContractDisplay.ClientID %>');
                if (lbl) {
                    lbl.textContent = displayLabel;
                }

                var lblCurrentEnd = document.getElementById('<%= lblExtendContractCurrentEndDate.ClientID %>');
                if (lblCurrentEnd) {
                    lblCurrentEnd.textContent = currentEndDate ? formatDateDisplay(currentEndDate) : "N/A";
                }

                var lblGemId = document.getElementById('<%= lblExtendContractGemId.ClientID %>');
                if (lblGemId) {
                    lblGemId.textContent = gemId || "—";
                }

                var txt = document.getElementById('<%= txtExtendContractNewEndDate.ClientID %>');
                if (txt) {
                    if (currentEndDate) {
                        var curDate = new Date(currentEndDate);
                        curDate.setMonth(curDate.getMonth() + 6);
                        txt.value = curDate.toISOString().split('T')[0];
                    } else {
                        var tomorrow = new Date();
                        tomorrow.setDate(tomorrow.getDate() + 1);
                        txt.value = tomorrow.toISOString().split('T')[0];
                    }
                }

                var chk = document.getElementById('chkConfirmExtend');
                if (chk) {
                    chk.checked = false;
                }

                var modalEl = document.getElementById('extendContractModal');
                if (modalEl) {
                    if (window.bootstrap && window.bootstrap.Modal) {
                        var modal = window.bootstrap.Modal.getInstance(modalEl) || new window.bootstrap.Modal(modalEl);
                        modal.show();
                    } else if (window.jQuery && window.jQuery.fn.modal) {
                        window.jQuery(modalEl).modal('show');
                    } else {
                        modalEl.classList.add('show');
                        modalEl.style.display = 'block';
                        document.body.classList.add('modal-open');
                    }
                }
            }

            function openDeleteContractModal(startDateVal, startDateDisplay) {
                var hf = document.getElementById('<%= hfDeleteContractStartDate.ClientID %>');
                if (hf) {
                    hf.value = startDateVal;
                }

                var lbl = document.getElementById('<%= lblDeleteContractStartDate.ClientID %>');
                if (lbl) {
                    lbl.textContent = startDateDisplay;
                }

                var chk = document.getElementById('chkConfirmDelete');
                if (chk) {
                    chk.checked = false;
                }

                var modalEl = document.getElementById('deleteContractModal');
                if (modalEl) {
                    if (window.bootstrap && window.bootstrap.Modal) {
                        var modal = window.bootstrap.Modal.getInstance(modalEl) || new window.bootstrap.Modal(modalEl);
                        modal.show();
                    } else if (window.jQuery && window.jQuery.fn.modal) {
                        window.jQuery(modalEl).modal('show');
                    } else {
                        modalEl.classList.add('show');
                        modalEl.style.display = 'block';
                        document.body.classList.add('modal-open');
                    }
                }
            }

            let contractActivationConfirmed = false;
            function confirmContractActivation(sender) {
                if (contractActivationConfirmed) {
                    contractActivationConfirmed = false;
                    return true; // Allow postback
                }

                Swal.fire({
                    title: 'Confirm Contract Activation',
                    text: 'WARNING: Activating a new contract period will close the previous contract period and automatically seal all prior employee engagements and historical attendance records. This process cannot be undone. Are you sure you want to proceed?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#10b981',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Yes, Activate it!',
                    cancelButtonText: 'Cancel',
                    customClass: {
                        popup: 'shadow-lg rounded-lg border-0 bg-white text-dark',
                        title: 'font-weight-bold text-dark',
                        confirmButton: 'btn btn-success font-weight-bold px-4 py-2',
                        cancelButton: 'btn btn-secondary font-weight-bold px-4 py-2 ml-2'
                    },
                    buttonsStyling: false
                }).then((result) => {
                    if (result.isConfirmed) {
                        contractActivationConfirmed = true;
                        sender.click(); // Re-trigger the click event
                    }
                });

                return false; // Block immediate postback
            }

            function setupIdKeyboardNavigation() {
                var inputs = document.querySelectorAll('.employee-id-input');
                inputs.forEach(function (input) {
                    // Focus: select all text to allow quick overwrite
                    input.removeEventListener('focus', handleInputFocus);
                    input.addEventListener('focus', handleInputFocus);

                    // Keydown: handle Enter, ArrowUp, ArrowDown
                    input.removeEventListener('keydown', handleInputKeydown);
                    input.addEventListener('keydown', handleInputKeydown);
                });
            }

            function handleInputFocus() {
                this.select();
            }

            function handleInputKeydown(e) {
                var activeTabPane = this.closest('.tab-pane');
                if (!activeTabPane) return;
                var inputsList = Array.from(activeTabPane.querySelectorAll('.employee-id-input:not([disabled])'));
                var currIdx = inputsList.indexOf(this);
                if (currIdx === -1) return;

                if (e.key === 'Enter' || e.key === 'ArrowDown') {
                    e.preventDefault();
                    var nextInput = inputsList[currIdx + 1];
                    if (nextInput) {
                        nextInput.focus();
                    }
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    var prevInput = inputsList[currIdx - 1];
                    if (prevInput) {
                        prevInput.focus();
                    }
                }
            }

            // Initialize counts on page load
            document.addEventListener('DOMContentLoaded', function () {
                updateCounts();
                setupIdKeyboardNavigation();

                // Auto focus the first available employee ID textbox in Step 3
                var firstInput = document.querySelector('.employee-id-input');
                if (firstInput) {
                    setTimeout(function () {
                        firstInput.focus();
                    }, 100);
                }
            });

            function openEditContractModal(periodId, gemId, datedOn) {
                var hf = document.getElementById('<%= hfEditContractId.ClientID %>');
                if (hf) {
                    hf.value = periodId;
                }
                var txtGem = document.getElementById('<%= txtEditContractGemId.ClientID %>');
                if (txtGem) {
                    txtGem.value = gemId || "";
                }
                var txtDated = document.getElementById('<%= txtEditContractDatedOn.ClientID %>');
                if (txtDated) {
                    txtDated.value = datedOn || "";
                }

                var modalEl = document.getElementById('editContractModal');
                if (modalEl) {
                    try {
                        var modal = window.bootstrap.Modal.getInstance(modalEl) || new window.bootstrap.Modal(modalEl);
                        if (modal && typeof modal.show === 'function') {
                            modal.show();
                        } else {
                            window.jQuery(modalEl).modal('show');
                        }
                    } catch (e) {
                        window.jQuery(modalEl).modal('show');
                    }
                }
            }
        </script>
    </asp:Content>