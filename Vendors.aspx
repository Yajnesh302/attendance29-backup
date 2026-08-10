<%@ Page Title="Vendor Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Vendors.aspx.cs" Inherits="AttendanceApp.Vendors" EnableEventValidation="false" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
        Vendor Management
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            .panel-form {
                background: white;
                padding: 24px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                border: 1px solid #e2e8f0;
                margin-bottom: 20px;
            }

            .panel-list {
                background: white;
                padding: 24px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                border: 1px solid #e2e8f0;
            }

            .table-custom-vendor {
                border-collapse: separate !important;
                border-spacing: 0 !important;
                width: 100% !important;
                border: 1px solid #e2e8f0 !important;
                border-radius: 10px !important;
                overflow: hidden !important;
            }

            .table-custom-vendor th {
                background-color: #f8fafc !important;
                color: #475569 !important;
                font-size: 0.8rem !important;
                text-transform: uppercase !important;
                letter-spacing: 0.06em !important;
                font-weight: 700 !important;
                padding: 12px 16px !important;
                border-top: none !important;
                border-bottom: 2px solid #e2e8f0 !important;
                border-left: none !important;
                border-right: 1px solid #e2e8f0 !important;
                vertical-align: middle !important;
            }

            .table-custom-vendor th:last-child {
                border-right: none !important;
            }

            .table-custom-vendor td {
                padding: 12px 16px !important;
                color: #334155 !important;
                font-size: 0.9rem !important;
                font-weight: 500 !important;
                border-bottom: 1px solid #e2e8f0 !important;
                border-left: none !important;
                border-right: 1px solid #f1f5f9 !important;
                vertical-align: middle !important;
            }

            .table-custom-vendor td:last-child {
                border-right: none !important;
            }

            .table-custom-vendor tr:last-child td {
                border-bottom: none !important;
            }

            .table-custom-vendor tr {
                transition: background-color 0.15s ease;
            }

            .table-custom-vendor tr:hover {
                background-color: #eef2ff !important;
            }

            .table-custom-vendor tr:nth-child(even) {
                background-color: #fbfcfd;
            }

            .status-badge-active {
                background-color: #d1fae5 !important;
                color: #065f46 !important;
                font-weight: bold;
                padding: 4px 12px;
                border-radius: 50px;
                font-size: 0.75rem;
                display: inline-block;
            }

            .status-badge-inactive {
                background-color: #fee2e2 !important;
                color: #991b1b !important;
                font-weight: bold;
                padding: 4px 12px;
                border-radius: 50px;
                font-size: 0.75rem;
                display: inline-block;
            }

            .animate-hover {
                transition: all 0.2s ease;
            }

            .animate-hover:hover {
                transform: translateY(-1.5px);
                box-shadow: 0 4px 12px rgba(79, 70, 229, 0.2) !important;
            }

            .card-header-gradient-vendor {
                background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                border-top-left-radius: 12px;
                border-top-right-radius: 12px;
                padding: 16px 20px;
                color: white;
            }

            /* Modal Custom styles */
            .modal-content {
                border-radius: 14px;
                border: none;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            }

            /* Fix Bootstrap modal backdrop z-index bug */
            .modal {
                background: rgba(0, 0, 0, 0.55);
            }

            .modal-backdrop {
                display: none !important;
            }

            /* ── Vendor History Timeline ── */
            .vendor-history-modal .modal-dialog {
                max-width: 680px;
            }

            .vendor-header-card {
                background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                border-radius: 12px;
                padding: 18px 20px;
                color: #fff;
                margin-bottom: 20px;
            }

            .vendor-header-card .vendor-title {
                font-size: 1.25rem;
                font-weight: 700;
                letter-spacing: -0.01em;
            }

            .vendor-header-card .vendor-meta {
                font-size: 0.82rem;
                opacity: 0.85;
                margin-top: 4px;
            }

            .vendor-header-card .status-pill {
                display: inline-block;
                border-radius: 50px;
                padding: 2px 12px;
                font-size: 0.75rem;
                font-weight: 700;
                background: rgba(255, 255, 255, 0.2);
                border: 1px solid rgba(255, 255, 255, 0.35);
            }

            /* Timeline */
            .timeline {
                position: relative;
                padding: 4px 0 0 0;
            }

            .timeline::before {
                content: '';
                position: absolute;
                left: 24px;
                top: 0;
                bottom: 0;
                width: 2px;
                background: linear-gradient(to bottom, #cbd5e1, #e2e8f0);
                border-radius: 2px;
            }

            .tl-item {
                display: flex;
                align-items: flex-start;
                margin-bottom: 20px;
                position: relative;
            }

            .tl-item:last-child {
                margin-bottom: 0;
            }

            .tl-dot {
                width: 48px;
                flex-shrink: 0;
                display: flex;
                flex-direction: column;
                align-items: center;
                position: relative;
                z-index: 1;
            }

            .tl-dot-icon {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.9rem;
                font-weight: 700;
                border: 2px solid #fff;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
            }

            .dot-active {
                background: #10b981;
                color: #fff;
            }

            .dot-extended {
                background: #0284c7;
                color: #fff;
            }

            .dot-closed {
                background: #64748b;
                color: #fff;
            }

            .tl-body {
                flex: 1;
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 12px 16px;
                margin-left: 10px;
            }

            .tl-event-label {
                display: inline-flex;
                align-items: center;
                font-size: 0.72rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                padding: 4px 10px;
                border-radius: 6px;
                border: 1px solid transparent;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            }

            .tl-event-label.ev-active {
                background-color: #ecfdf5;
                border-color: #a7f3d0;
                color: #065f46;
            }

            .tl-event-label.ev-extended {
                background-color: #e0f2fe;
                border-color: #bae6fd;
                color: #0369a1;
            }

            .tl-event-label.ev-closed {
                background-color: #f1f5f9;
                border-color: #cbd5e1;
                color: #475569;
            }

            .tl-detail {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 6px 16px;
            }

            .tl-kv {
                display: flex;
                flex-direction: column;
            }

            .tl-kv .k {
                font-size: 0.7rem;
                color: #94a3b8;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .tl-kv .v {
                font-size: 0.875rem;
                color: #1e293b;
                font-weight: 600;
            }

            .tl-contract-chip {
                display: inline-block;
                font-size: 0.72rem;
                background: #e0e7ff !important;
                color: #312e81 !important;
                border-radius: 4px;
                padding: 3px 8px;
                margin-top: 8px;
                font-weight: 700;
                border: 1px solid #c7d2fe !important;
            }

            .tl-no-history {
                text-align: center;
                padding: 32px 16px;
                color: #94a3b8;
            }

            .tl-no-history i {
                font-size: 2rem;
                margin-bottom: 10px;
                display: block;
            }

            #vendorHistoryModal .modal-body {
                max-height: 70vh;
                overflow-y: auto;
            }

            /* Escalation Matrix Styles */
            .escalation-matrix-section {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 16px;
                margin-bottom: 16px;
            }
            .escalation-matrix-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 12px;
            }
            .escalation-matrix-title {
                font-size: 0.85rem;
                font-weight: 700;
                color: #334155;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .contact-level-card {
                background: #ffffff;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                padding: 12px;
                margin-bottom: 10px;
                position: relative;
                box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            }
            .contact-level-card:last-child {
                margin-bottom: 0;
            }
            .contact-level-title {
                font-size: 0.8rem;
                font-weight: 700;
                color: #1e293b;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .contact-level-badge {
                font-size: 0.7rem;
                padding: 2px 7px;
                border-radius: 12px;
                font-weight: 700;
            }
            .badge-level-1 { background: #dbeafe; color: #1e40af; }
            .badge-level-n { background: #f1f5f9; color: #475569; }
            .contact-field-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 8px;
            }
            .contact-field-row.single {
                grid-template-columns: 1fr;
            }
            .btn-add-contact {
                font-size: 0.78rem;
                font-weight: 700;
                color: #4f46e5;
                background: #e0e7ff;
                border: 1px solid #c7d2fe;
                border-radius: 6px;
                padding: 4px 10px;
                cursor: pointer;
                transition: all 0.2s;
            }
            .btn-add-contact:hover {
                background: #4f46e5;
                color: #ffffff;
            }
            .btn-remove-contact {
                position: absolute;
                top: 8px;
                right: 8px;
                font-size: 0.72rem;
                color: #ef4444;
                background: #fee2e2;
                border: 1px solid #fca5a5;
                border-radius: 4px;
                padding: 2px 6px;
                cursor: pointer;
            }
            .btn-remove-contact:hover {
                background: #ef4444;
                color: #ffffff;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0 text-dark font-weight-bold">Vendor Management</h2>
            <div>
                <button type="button" class="btn btn-primary shadow-sm animate-hover" data-bs-toggle="modal"
                    data-bs-target="#vendorFormModal" onclick="clearVendorForm();">
                    <i class="fas fa-plus mr-1"></i> Add Vendor
                </button>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-block d-none" Visible="false"></asp:Label>

        <asp:HiddenField ID="hfHiddenEditVendorId" runat="server" ClientIDMode="Static" />
        <asp:LinkButton ID="btnHiddenEditTrigger" runat="server" OnClick="btnHiddenEditTrigger_Click"
            style="display:none;" />

        <div class="row">
            <!-- Hidden button to satisfy designer backing field -->
            <asp:Button ID="btnCancel" runat="server" OnClick="btnCancel_Click" style="display:none;" />

            <!-- FULL-WIDTH: Vendor Registry List Card -->
            <div class="col-lg-12 mb-4">
                <div class="card shadow-sm border-0 rounded-lg" style="border-radius: 12px; overflow: hidden;">
                    <div
                        class="card-header py-3 bg-white border-bottom d-flex align-items-center justify-content-between flex-wrap">
                        <h5 class="m-0 font-weight-bold text-dark mb-2 mb-sm-0">
                            <i class="fas fa-handshake mr-2 text-primary"></i> Vendor Registry
                        </h5>

                        <div class="d-flex align-items-center">
                            <asp:TextBox ID="txtSearch" runat="server"
                                CssClass="form-control mr-2 shadow-sm form-control-sm"
                                placeholder="Search Master ID or Name..." onkeyup="filterVendors()"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                CssClass="btn btn-sm btn-outline-primary shadow-sm" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                    <div class="card-body panel-list bg-white text-dark p-4">
                        <div class="table-responsive">
                            <asp:GridView ID="gvVendors" runat="server" AutoGenerateColumns="False"
                                CssClass="table table-hover table-custom-vendor mb-0" DataKeyNames="Id"
                                OnRowCommand="gvVendors_RowCommand" GridLines="None">
                                <Columns>
                                    <asp:TemplateField HeaderText="S.No" ItemStyle-Width="50">
                                        <ItemTemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MasterId" HeaderText="Master ID"
                                        HeaderStyle-Font-Bold="true" />
                                    <asp:TemplateField HeaderText="Vendor Name" HeaderStyle-Font-Bold="true">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkVendorName" runat="server" CommandName="ViewHistory"
                                                CommandArgument='<%# Eval("Id") %>' CssClass="vendor-name-link"
                                                style="color:#4f46e5;font-weight:700;text-decoration:none;border-bottom:1px dashed #a5b4fc;cursor:pointer;"
                                                title="Click to view contract history">
                                                <%# Eval("Name") %>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Contact Person">
                                        <ItemTemplate>
                                            <div class="font-weight-bold">
                                                <%# Eval("ContactName") %>
                                            </div>
                                            <small class="text-muted">
                                                <%# Eval("ContactPhone") %>
                                            </small>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Status" ItemStyle-Width="100">
                                        <ItemTemplate>
                                            <span
                                                class='<%# Convert.ToInt32(Eval("IsActive")) == 1 ? "status-badge-active" : "status-badge-inactive" %>'>
                                                <%# Convert.ToInt32(Eval("IsActive"))==1 ? "Active" : "Inactive" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="100">
                                        <ItemTemplate>
                                             <div class="d-flex gap-2">
                                                 <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditVendor"
                                                     CommandArgument='<%# Eval("Id") %>'
                                                     CssClass="btn btn-sm btn-outline-primary mr-1"
                                                     style="font-size: 0.75rem; font-weight: bold; border-radius: 6px;">
                                                     <i class="fas fa-edit"></i> Edit
                                                 </asp:LinkButton>
                                                 <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteVendor"
                                                     CommandArgument='<%# Eval("Id") %>'
                                                     CssClass="btn btn-sm btn-outline-danger"
                                                     style="font-size: 0.75rem; font-weight: bold; border-radius: 6px;"
                                                     OnClientClick='<%# "return confirmDelete(this, \"" + Eval("Name") + "\");" %>'>
                                                     <i class="fas fa-trash-alt"></i> Delete
                                                 </asp:LinkButton>
                                             </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="text-center p-4 text-muted font-weight-bold">
                                        No vendors registered in the system. Use the form on the left to add one!
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- VENDOR HISTORY MODAL -->
        <div class="modal fade vendor-history-modal" id="vendorHistoryModal" tabindex="-1" role="dialog"
            aria-labelledby="vendorHistoryModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); padding: 16px 20px;">
                        <h5 class="modal-title font-weight-bold" id="vendorHistoryModalLabel">
                            <i class="fas fa-handshake mr-2"></i> Vendor Profile & History
                        </h5>
                        <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close"
                            style="background:none; border:none; font-size:1.5rem; opacity:0.8; outline:none;">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark" id="vendorHistoryModalBody" style="padding: 20px;">
                        <div class="text-center p-4"><i class="fas fa-spinner fa-spin text-primary"></i> Loading...
                        </div>
                    </div>
                    <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 12px 20px;">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
            <!-- ADD/EDIT VENDOR MODAL -->
            <div class="modal fade" id="vendorFormModal" tabindex="-1" role="dialog"
                aria-labelledby="vendorFormModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered" role="document">
                    <div class="modal-content" style="border-radius: 12px; overflow: hidden; border: none;">
                        <div class="card-header-gradient-vendor" id="formHeader" runat="server"
                            style="padding: 16px 20px;">
                            <h5 class="m-0 font-weight-bold" id="formTitle" runat="server" style="color: white;">
                                <i class="fas fa-plus mr-2"></i> Add New Vendor
                            </h5>
                        </div>
                        <div class="modal-body bg-white text-dark" style="padding: 24px;">
                            <div class="form-group mb-3">
                                <label class="font-weight-bold text-gray-800 mb-1" style="font-size: 0.85rem;">Vendor
                                    Master ID / Code</label>
                                <asp:TextBox ID="txtMasterId" runat="server" CssClass="form-control" ReadOnly="true"
                                    BackColor="#f1f5f9" placeholder="(Auto-Generated)" MaxLength="50"></asp:TextBox>
                            </div>

                            <div class="form-group mb-3">
                                <label class="font-weight-bold text-gray-800 mb-1" style="font-size: 0.85rem;">Vendor
                                    Name *</label>
                                <asp:TextBox ID="txtVendorName" runat="server" CssClass="form-control"
                                    placeholder="e.g. Vishal Manpower Services" MaxLength="150"></asp:TextBox>
                            </div>


                            <asp:HiddenField ID="hfVendorContacts" runat="server" ClientIDMode="Static" />

                            <!-- Dynamic Contact Escalation Matrix -->
                            <div class="escalation-matrix-section mb-3">
                                <div class="escalation-matrix-header mb-2">
                                    <span class="escalation-matrix-title"><i class="fas fa-sitemap mr-1"></i> Contact Escalation Matrix</span>
                                    <button type="button" class="btn-add-contact" onclick="addContactRow('', '', '', '')">
                                        <i class="fas fa-plus mr-1"></i> Add Contact Level
                                    </button>
                                </div>
                                <div id="contactLevelsContainer"></div>
                            </div>

                            <!-- Hidden legacy fields to satisfy WebForms designer backing controls -->
                            <div style="display:none;">
                                <asp:TextBox ID="txtContactName" runat="server"></asp:TextBox>
                                <asp:TextBox ID="txtContactPhone" runat="server"></asp:TextBox>
                                <asp:TextBox ID="txtAddress" runat="server"></asp:TextBox>
                            </div>

                            <asp:HiddenField ID="hfEditVendorId" runat="server" Value="" />
                        </div>
                        <div class="modal-footer bg-light"
                            style="border-top: 1px solid #f1f5f9; padding: 16px 24px; display: flex; justify-content: space-between;">
                            <button type="button" class="btn btn-secondary px-3" data-bs-dismiss="modal">Close</button>
                            <asp:Button ID="btnSave" runat="server" Text="Save Vendor"
                                CssClass="btn btn-primary px-4 shadow-sm animate-hover"
                                style="background-color: #4f46e5; border-color: #4f46e5;" OnClick="btnSave_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <script>
                function initVendorMatrixFromHidden() {
                    var hfJson = document.getElementById('<%= hfVendorContacts.ClientID %>');
                    var container = document.getElementById('contactLevelsContainer');
                    if (container) {
                        if (hfJson && hfJson.value && hfJson.value.trim() !== '') {
                            loadContactsFromJson(hfJson.value);
                        } else if (container.children.length === 0) {
                            addContactRow('', '', '', '');
                        }
                    }
                }

                document.addEventListener('DOMContentLoaded', function () {
                    var form = document.getElementById('form1');
                    var vHistModal = document.getElementById('vendorHistoryModal');
                    var vFormModal = document.getElementById('vendorFormModal');
                    if (form) {
                        if (vHistModal) form.appendChild(vHistModal);
                        if (vFormModal) form.appendChild(vFormModal);
                    }

                    initVendorMatrixFromHidden();

                    if (vFormModal) {
                        vFormModal.addEventListener('show.bs.modal', function () {
                            initVendorMatrixFromHidden();
                        });
                    }
                });

                function addContactRow(name, phone, email, address) {
                    name = name || '';
                    phone = phone || '';
                    email = email || '';
                    address = address || '';

                    var container = document.getElementById('contactLevelsContainer');
                    if (!container) return;

                    var levelNum = container.children.length + 1;
                    var card = document.createElement('div');
                    card.className = 'contact-level-card';

                    var isPrimary = (levelNum === 1);
                    var badgeClass = isPrimary ? 'badge-level-1' : 'badge-level-n';
                    var levelLabel = isPrimary ? 'Level 1 &ndash; Primary Contact' : ('Level ' + levelNum + ' Escalation');
                    var nameReq = isPrimary ? 'required' : 'required';
                    var phoneReq = isPrimary ? 'required' : 'required';
                    var emailReq = isPrimary ? 'required' : '';
                    var addressReq = isPrimary ? 'required' : '';
                    var nameReqLabel = ' *';
                    var phoneReqLabel = ' *';
                    var emailReqLabel = isPrimary ? ' *' : '';
                    var addressReqLabel = isPrimary ? ' *' : '';

                    var removeBtnHtml = isPrimary ? '' : '<button type="button" class="btn-remove-contact" onclick="removeContactRow(this)"><i class="fas fa-trash-alt mr-1"></i> Remove</button>';

                    card.innerHTML = 
                        '<div class="contact-level-title">' +
                            '<span class="contact-level-badge ' + badgeClass + '">' + levelLabel + '</span>' +
                        '</div>' +
                        removeBtnHtml +
                        '<div class="contact-field-row mb-2">' +
                            '<div>' +
                                '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Contact Name' + nameReqLabel + '</label>' +
                                '<input type="text" class="form-control form-control-sm vc-name" value="' + EscapeHtmlAttr(name) + '" placeholder="Full Name" ' + nameReq + ' oninput="syncContactsToHidden()" />' +
                            '</div>' +
                            '<div>' +
                                '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Phone Number' + phoneReqLabel + '</label>' +
                                '<input type="text" class="form-control form-control-sm vc-phone" value="' + EscapeHtmlAttr(phone) + '" placeholder="e.g. 9876543210" ' + phoneReq + ' oninput="syncContactsToHidden()" />' +
                            '</div>' +
                        '</div>' +
                        '<div class="contact-field-row">' +
                            '<div>' +
                                '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Email Address' + emailReqLabel + '</label>' +
                                '<input type="email" class="form-control form-control-sm vc-email" value="' + EscapeHtmlAttr(email) + '" placeholder="email@domain.com" ' + emailReq + ' oninput="syncContactsToHidden()" />' +
                            '</div>' +
                            '<div>' +
                                '<label class="font-weight-bold text-gray-700" style="font-size:0.75rem;">Contact Address' + addressReqLabel + '</label>' +
                                '<input type="text" class="form-control form-control-sm vc-address" value="' + EscapeHtmlAttr(address) + '" placeholder="Address / Office info" ' + addressReq + ' oninput="syncContactsToHidden()" />' +
                            '</div>' +
                        '</div>';

                    container.appendChild(card);
                    syncContactsToHidden();
                }

                function removeContactRow(btn) {
                    var card = btn.closest('.contact-level-card');
                    if (card) {
                        card.remove();
                        _renumberCards();
                        syncContactsToHidden();
                    }
                }

                function _renumberCards() {
                    var container = document.getElementById('contactLevelsContainer');
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

                function syncContactsToHidden() {
                    var container = document.getElementById('contactLevelsContainer');
                    var hfContacts = document.getElementById('<%= hfVendorContacts.ClientID %>');
                    var txtName = document.getElementById('<%= txtContactName.ClientID %>');
                    var txtPhone = document.getElementById('<%= txtContactPhone.ClientID %>');
                    var txtAddr = document.getElementById('<%= txtAddress.ClientID %>');
                    if (!container || !hfContacts) return;

                    var cards = container.querySelectorAll('.contact-level-card');
                    var list = [];

                    cards.forEach(function (card, idx) {
                        var name = (card.querySelector('.vc-name') ? card.querySelector('.vc-name').value : '').trim();
                        var phone = (card.querySelector('.vc-phone') ? card.querySelector('.vc-phone').value : '').trim();
                        var email = (card.querySelector('.vc-email') ? card.querySelector('.vc-email').value : '').trim();
                        var address = (card.querySelector('.vc-address') ? card.querySelector('.vc-address').value : '').trim();

                        list.push({ priority: idx + 1, name: name, phone: phone, email: email, address: address });

                        // Sync primary contact to legacy backing controls
                        if (idx === 0) {
                            if (txtName) txtName.value = name;
                            if (txtPhone) txtPhone.value = phone;
                            if (txtAddr) txtAddr.value = address;
                        }
                    });

                    hfContacts.value = JSON.stringify(list);
                }

                function loadContactsFromJson(jsonStr) {
                    var container = document.getElementById('contactLevelsContainer');
                    if (!container) return;
                    container.innerHTML = '';

                    if (!jsonStr) {
                        addContactRow('', '', '', '');
                        return;
                    }

                    try {
                        var list = JSON.parse(jsonStr);
                        if (Array.isArray(list) && list.length > 0) {
                            list.forEach(function (c) {
                                addContactRow(c.name || '', c.phone || '', c.email || '', c.address || '');
                            });
                        } else {
                            addContactRow('', '', '', '');
                        }
                    } catch (e) {
                        addContactRow('', '', '', '');
                    }
                }

                function EscapeHtmlAttr(str) {
                    if (!str) return '';
                    return String(str).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                }

                function clearVendorForm() {
                    var txtMasterId = document.getElementById('<%= txtMasterId.ClientID %>');
                    var txtVendorName = document.getElementById('<%= txtVendorName.ClientID %>');
                    var txtContactName = document.getElementById('<%= txtContactName.ClientID %>');
                    var txtContactPhone = document.getElementById('<%= txtContactPhone.ClientID %>');
                    var txtAddress = document.getElementById('<%= txtAddress.ClientID %>');
                    var hfEditVendorId = document.getElementById('<%= hfEditVendorId.ClientID %>');
                    var hfContacts = document.getElementById('<%= hfVendorContacts.ClientID %>');
                    var btnSave = document.getElementById('<%= btnSave.ClientID %>');
                    var formTitle = document.getElementById('<%= formTitle.ClientID %>');
                    var formHeader = document.getElementById('<%= formHeader.ClientID %>');

                    if (txtMasterId) txtMasterId.value = '(Auto-Generated)';
                    if (txtVendorName) txtVendorName.value = '';
                    if (txtContactName) txtContactName.value = '';
                    if (txtContactPhone) txtContactPhone.value = '';
                    if (txtAddress) txtAddress.value = '';
                    if (hfEditVendorId) hfEditVendorId.value = '';
                    if (hfContacts) hfContacts.value = '';

                    if (btnSave) btnSave.value = 'Save Vendor';

                    if (formTitle) formTitle.innerHTML = '<i class="fas fa-plus mr-2"></i> Add New Vendor';
                    if (formHeader) formHeader.style.background = 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)';

                    // Clear and re-initialize matrix container to 1 level
                    var container = document.getElementById('contactLevelsContainer');
                    if (container) container.innerHTML = '';
                    addContactRow('', '', '', '');
                    syncContactsToHidden();
                }

                function openVendorHistoryModal(vendor, history) {
                    var body = document.getElementById('vendorHistoryModalBody');
                    if (!body) return;

                    var statusClass = vendor.status === 'Active' ? '#059669' : '#dc2626';

                    var html = '<div class="vendor-header-card">';
                    html += '<div class="d-flex justify-content-between align-items-start">';
                    html += '<div>';
                    html += '<div class="vendor-title"><i class="fas fa-handshake mr-2"></i>' + vendor.name + '</div>';
                    html += '<div class="vendor-meta">Master ID: <strong>' + vendor.masterId + '</strong> &nbsp;|&nbsp; GeM ID: <strong>' + (vendor.gemId || '—') + '</strong></div>';
                    
                    // Render escalation matrix contacts in modal header if available
                    if (vendor.contacts && Array.isArray(vendor.contacts) && vendor.contacts.length > 0) {
                        html += '<div class="vendor-contacts-matrix mt-2 pt-2" style="border-top:1px solid rgba(255,255,255,0.15);">';
                        html += '<div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; opacity:0.8; font-weight:700; margin-bottom:4px;"><i class="fas fa-sitemap mr-1"></i> Escalation Contacts</div>';
                        vendor.contacts.forEach(function (c) {
                            var pLabel = c.priority === 1 ? 'Primary' : ('L' + c.priority);
                            html += '<div style="font-size:0.83rem; margin-bottom:3px;">';
                            html += '<span class="badge bg-light text-dark mr-1" style="font-size:0.7rem;">' + pLabel + '</span>';
                            html += '<strong>' + (c.name || '—') + '</strong> &nbsp;|&nbsp; <i class="fas fa-phone-alt mr-1"></i>' + (c.phone || '—');
                            if (c.email) html += ' &nbsp;|&nbsp; <i class="fas fa-envelope mr-1"></i>' + c.email;
                            if (c.address) html += ' &nbsp;|&nbsp; <i class="fas fa-map-marker-alt mr-1"></i>' + c.address;
                            html += '</div>';
                        });
                        html += '</div>';
                    } else {
                        html += '<div class="vendor-meta">Contact: <strong>' + (vendor.contactName || '—') + '</strong> &nbsp;|&nbsp; Phone: <strong>' + (vendor.contactPhone || '—') + '</strong></div>';
                        if (vendor.address) {
                            html += '<div class="vendor-meta" style="margin-top: 6px; font-size: 0.82rem; border-top: 1px solid rgba(255,255,255,0.15); padding-top: 6px;"><i class="fas fa-map-marker-alt mr-1"></i> Address: <strong>' + vendor.address + '</strong></div>';
                        }
                    }

                    html += '</div>';
                    html += '<div class="d-flex flex-column align-items-end" style="gap: 8px;">';
                    html += '<span class="status-pill" style="background:' + statusClass + '22;border-color:' + statusClass + '55;color:#fff;margin-bottom:4px;">' + vendor.status + '</span>';
                    html += '<button type="button" class="btn btn-sm btn-light animate-hover" onclick="triggerClientEdit(' + vendor.id + ')" style="font-weight: 700; border-radius: 6px; padding: 4px 10px; font-size: 0.8rem; color: #0f172a; border: 1px solid rgba(255,255,255,0.25); display: inline-flex; align-items: center; transition: all 0.2s; cursor: pointer;"><i class="fas fa-edit mr-1"></i> Edit Details</button>';
                    html += '</div>';
                    html += '</div></div>';

                    if (!history || history.length === 0) {
                        html += '<div class="tl-no-history"><i class="fas fa-inbox"></i>No contract history found for this vendor.</div>';
                    } else {
                        html += '<h6 class="font-weight-bold mb-3 text-secondary"><i class="fas fa-file-contract mr-1"></i> Contract History Timeline</h6>';
                        html += '<div class="timeline">';

                        for (var i = 0; i < history.length; i++) {
                            var h = history[i];
                            var isExt = h.extensionCount > 0;
                            var dotClass = h.status === 'Active' ? (isExt ? 'dot-extended' : 'dot-active') : 'dot-closed';
                            var dotIcon = h.status === 'Active' ? (isExt ? 'fas fa-calendar-plus' : 'fas fa-check') : 'fas fa-history';
                            var evLabelClass = h.status === 'Active' ? (isExt ? 'ev-extended' : 'ev-active') : 'ev-closed';
                            var evLabelText = h.status === 'Active' ? (isExt ? 'Active (Extended)' : 'Active Contract') : 'Closed Contract';
                            var periodStr = h.end ? (h.start + ' &rarr; ' + h.end) : (h.start + ' &rarr; Present');

                            html += '<div class="tl-item">';
                            html += '<div class="tl-dot"><div class="tl-dot-icon ' + dotClass + '"><i class="' + dotIcon + '" style="font-size:0.8rem;"></i></div></div>';
                            html += '<div class="tl-body">';

                            html += '<div class="d-flex align-items-center mb-2">';
                            html += '<span class="tl-event-label ' + evLabelClass + '">' + evLabelText + '</span>';
                            html += '</div>';

                            html += '<div class="tl-detail">';
                            html += '<div class="tl-kv"><span class="k">Category</span><span class="v">' + h.cat + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">GeM ID</span><span class="v">' + (h.gemId || '—') + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Dated On</span><span class="v">' + (h.datedOn || '—') + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Contract Status</span><span class="v">' + (h.status === 'Active' && isExt ? 'Active (Extended)' : h.status) + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Period</span><span class="v">' + periodStr + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Employees Engaged</span><span class="v">' + h.empCount + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Is Extended</span><span class="v">' + (isExt ? 'Yes (' + h.extensionCount + ' time' + (h.extensionCount > 1 ? 's' : '') + ')' : 'No') + '</span></div>';
                            html += '</div>';

                            if (isExt && h.extensions && h.extensions.length > 0) {
                                html += '<div class="tl-extensions-section" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #cbd5e1;">';
                                html += '<span style="font-size: 0.72rem; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-bottom: 6px;"><i class="fas fa-history mr-1 text-info"></i> Extension History</span>';
                                html += '<div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 8px 12px; font-size: 0.8rem; box-shadow: inset 0 1px 2px rgba(0,0,0,0.02);">';
                                for (var j = 0; j < h.extensions.length; j++) {
                                    var ext = h.extensions[j];
                                    var isLast = (j === h.extensions.length - 1);
                                    var borderStyle = isLast ? '' : 'border-bottom: 1px solid #f1f5f9; padding-bottom: 6px;';
                                    var marginStyle = isLast ? '' : 'margin-bottom: 6px;';
                                    html += '<div style="display: flex; justify-content: space-between; align-items: center; ' + borderStyle + ' ' + marginStyle + ' gap: 10px;">';
                                    html += '<span>Extended from <strong>' + ext.oldEndDate + '</strong> to <strong class="text-success">' + ext.newEndDate + '</strong></span>';
                                    html += '<span class="text-muted" style="font-size: 0.72rem;">' + ext.extDate + '</span>';
                                    html += '</div>';
                                }
                                html += '</div>';
                                html += '</div>';
                            }

                            html += '</div>'; // tl-body
                            html += '</div>'; // tl-item
                        }

                        html += '</div>'; // timeline
                    }

                    body.innerHTML = html;

                    var modalEl = document.getElementById('vendorHistoryModal');
                    if (modalEl) {
                        var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                        modal.show();
                    }
                }

                function triggerClientEdit(vendorId) {
                    var hf = document.getElementById('hfHiddenEditVendorId');
                    if (hf) {
                        hf.value = vendorId;
                    }
                    var btn = document.getElementById('<%= btnHiddenEditTrigger.ClientID %>');
                    if (btn) {
                        var modalEl = document.getElementById('vendorHistoryModal');
                        if (modalEl) {
                            var modal = bootstrap.Modal.getInstance(modalEl);
                            if (modal) modal.hide();
                        }
                        btn.click();
                    }
                }

                let deleteTarget = null;
                function confirmDelete(sender, name) {
                    if (deleteTarget === sender) {
                        deleteTarget = null;
                        return true; // Allow postback
                    }

                    Swal.fire({
                        title: 'Delete Vendor?',
                        text: `Are you sure you want to delete the vendor '${name}'? If this vendor has active contract periods, they will be deactivated instead of deleted.`,
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#ef4444',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Yes, Delete',
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
                            deleteTarget = sender;
                            sender.click(); // Re-trigger the click event
                        }
                    });

                    return false; // Block immediate postback
                }

                function filterVendors() {
                    var txtSearch = document.getElementById('<%= txtSearch.ClientID %>');
                    if (!txtSearch) return;
                    var input = txtSearch.value.toLowerCase();
                    var gv = document.getElementById('<%= gvVendors.ClientID %>');
                    if (!gv) return;
                    var rows = gv.querySelectorAll('tr:not(:first-child)');

                    var sNo = 1;
                    rows.forEach(function (row) {
                        // columns: 1=MasterId, 2=Name
                        var masterIdCell = row.cells[1];
                        var nameCell = row.cells[2];

                        if (masterIdCell && nameCell) {
                            var masterIdText = masterIdCell.textContent.toLowerCase();
                            var nameText = nameCell.textContent.toLowerCase();

                            if (masterIdText.includes(input) || nameText.includes(input)) {
                                row.style.display = '';
                                row.cells[0].textContent = sNo++;
                            } else {
                                row.style.display = 'none';
                            }
                        }
                    });
                }
            </script>
    </asp:Content>