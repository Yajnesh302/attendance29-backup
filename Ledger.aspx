<%@ Page Title="Leave Ledger" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Ledger.aspx.cs" Inherits="AttendanceApp.Ledger" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="Static/js/xlsx.full.min.js?v=1.2.0"></script>

    <style>
        /* Modern dark text colors for enhanced legibility */
        h2, .h2, 
        .panel, 
        .form-control,
        body {
            color: #0f172a !important; /* Extremely dark slate text */
        }
        
        /* Modern Premium Panel Container */
        .panel {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            margin-bottom: 20px;
            border: 1px solid #f1f5f9;
        }
        
        /* Modern Premium Table Styling */
        .table-custom {
            border-collapse: separate !important;
            border-spacing: 0 !important;
            width: 100% !important;
            border: none !important; /* Managed by the outer responsive container border */
            background-color: #fff;
        }
        .table-custom th {
            background-color: #f8fafc !important; /* Soft slate gray */
            color: #475569 !important; /* Slate color */
            font-size: 0.8rem !important;
            text-transform: uppercase !important;
            letter-spacing: 0.06em !important;
            font-weight: 700 !important;
            padding: 14px 20px !important;
            border-top: none !important;
            border-bottom: 2px solid #e2e8f0 !important;
            border-left: none !important;
            border-right: 1px solid #e2e8f0 !important; /* Clean vertical line in header */
            vertical-align: middle !important;
        }
        .table-custom th:last-child {
            border-right: none !important;
        }
        .table-custom td {
            padding: 14px 20px !important;
            color: #334155 !important; /* Charcoal slate */
            font-size: 0.92rem !important;
            font-weight: 500 !important;
            border-bottom: 1px solid #e2e8f0 !important; /* Horizontal separating lines */
            border-left: none !important;
            border-right: 1px solid #f1f5f9 !important; /* Soft vertical separating lines */
            vertical-align: middle !important;
        }
        .table-custom td:last-child {
            border-right: none !important;
        }
        .table-custom tr:last-child td {
            border-bottom: none !important; /* Remove bottom border on the last row */
        }
        .table-custom tr {
            transition: background-color 0.2s ease;
        }
        .table-custom tr:hover {
            background-color: #eef2ff !important; /* Distinct light indigo hover */
        }
        .table-custom tr:nth-child(even) {
            background-color: #fbfcfd;
        }
        
        /* Make sure Red highlights stay bold and legible */
        .table-custom td[style*="Red"], 
        .table-custom td[style*="red"],
        .table-custom td[style*="color:Red"],
        .table-custom td[style*="color:red"],
        .table-custom td[style*="color: Red"] {
            color: #ef4444 !important;
            font-weight: 700 !important;
        }

        /* Elegant Toast Container at Top Right */
        #toast-container {
            position: fixed;
            top: 24px;
            right: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            z-index: 200000;
            pointer-events: none;
        }
        
        .modern-toast {
            display: flex;
            align-items: center;
            gap: 14px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px) saturate(180%);
            -webkit-backdrop-filter: blur(12px) saturate(180%);
            border-radius: 12px;
            padding: 14px 20px;
            min-width: 320px;
            max-width: 420px;
            color: #1e293b;
            font-size: 0.92rem;
            font-weight: 600;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04), inset 0 0 0 1px rgba(255, 255, 255, 0.5);
            transform: translateX(120%);
            transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.3s ease;
            opacity: 0;
            pointer-events: auto;
            border-left: 6px solid #64748b;
        }
        
        .modern-toast.toast-show {
            transform: translateX(0);
            opacity: 1;
        }
        
        .modern-toast.toast-hide {
            transform: translateY(-20px) scale(0.9);
            opacity: 0;
        }
        
        .toast-icon {
            font-size: 1.35rem;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        /* Toast Alert States with Curated Color Accents */
        .toast-success {
            border-left-color: #10b981;
            background: rgba(240, 253, 250, 0.95);
        }
        .toast-success .toast-icon {
            color: #10b981;
        }
        
        .toast-error {
            border-left-color: #ef4444;
            background: rgba(254, 242, 242, 0.95);
        }
        .toast-error .toast-icon {
            color: #ef4444;
        }
        
        .toast-warning {
            border-left-color: #f59e0b;
            background: rgba(255, 251, 235, 0.95);
        }
        .toast-warning .toast-icon {
            color: #f59e0b;
        }
        
        .toast-info {
            border-left-color: #3b82f6;
            background: rgba(239, 246, 255, 0.95);
        }
        .toast-info .toast-icon {
            color: #3b82f6;
        }
        
        .toast-close-btn {
            background: transparent;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            font-size: 1.2rem;
            padding: 2px;
            line-height: 1;
            transition: color 0.15s ease;
            margin-left: auto;
        }
        .toast-close-btn:hover {
            color: #475569;
        }

        #loadingOverlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
            z-index: 99999;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            font-family: 'Segoe UI', system-ui, sans-serif;
        }
        .spinner-border-custom {
            width: 3.5rem;
            height: 3.5rem;
            border: 5px solid #e2e8f0;
            border-top: 5px solid #4f46e5;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Info Badges for top right */
        .d-flex.align-items-center.gap-2 {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .info-badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 700;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
            border: 1px solid;
            font-family: 'Segoe UI', system-ui, sans-serif;
            transition: all 0.2s ease;
        }
        .badge-holiday {
            background-color: #fee2e2;
            color: #dc2626;
            border-color: #fca5a5;
        }
        .badge-holiday:hover {
            background-color: #fef2f2;
            transform: translateY(-1px);
        }
        .badge-adjust {
            background-color: #f3e8ff;
            color: #7e22ce;
            border-color: #d8b4fe;
        }
        .badge-adjust:hover {
            background-color: #faf5ff;
            transform: translateY(-1px);
        }

        /* Remarks Column Styling */
        .remarks-col {
            max-width: 250px;
            width: 250px;
            padding: 8px 12px !important;
        }
        .remarks-list {
            display: flex;
            flex-direction: column;
            gap: 6px;
            max-height: 160px;
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 #f1f5f9;
            padding-right: 4px;
        }
        .remarks-list::-webkit-scrollbar {
            width: 6px;
        }
        .remarks-list::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 4px;
        }
        .remarks-list::-webkit-scrollbar-thumb {
            background-color: #cbd5e1;
            border-radius: 4px;
        }
        .remarks-list::-webkit-scrollbar-thumb:hover {
            background-color: #94a3b8;
        }
        .remarks-item {
            background-color: #f8fafc;
            border-left: 3px solid #0ea5e9;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            color: #334155;
            font-weight: 500;
            line-height: 1.3;
            word-break: break-word;
            white-space: normal;
            transition: all 0.2s ease;
            text-align: left;
        }
        .remarks-item:hover {
            background-color: #f0f9ff;
            border-left-color: #0284c7;
            transform: translateX(1px);
        }
        
        /* Interactive sort headers styling */
        .sortable-header {
            position: relative;
            transition: background-color 0.2s ease;
        }
        .sortable-header:hover {
            background-color: #cbd5e1 !important;
            color: #0f172a !important;
        }

        .ledger-sticky-panel {
            position: sticky;
            top: 60px;
            z-index: 1010;
            background-color: #fff;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }
        .table-custom th {
            position: sticky !important;
            top: var(--ledger-table-top, 125px) !important;
            z-index: 990 !important;
        }
    </style>

    <div id="toast-container"></div>

    <div id="loadingOverlay">
        <div class="spinner-border-custom" role="status"></div>
        <div style="margin-top: 16px; font-size: 1.1rem; font-weight: 700; color: #0f172a;">Loading Ledger Data...</div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2><i class="fas fa-book text-info mr-2"></i>Leave Ledger</h2>
        <div class="d-flex align-items-center gap-2">
            <asp:Panel ID="pnlHolidayBadge" runat="server" CssClass="info-badge badge-holiday" Visible="false">
                <i class="fas fa-calendar-alt mr-1"></i> Holidays: <asp:Label ID="lblHolidays" runat="server"></asp:Label>
            </asp:Panel>
            <asp:Panel ID="pnlGlobalAdjustBadge" runat="server" CssClass="info-badge badge-adjust" Visible="false">
                <i class="fas fa-adjust mr-1"></i> Global Adjust: <asp:Label ID="lblGlobalAdjust" runat="server"></asp:Label>
            </asp:Panel>
        </div>
    </div>

    <div class="panel mb-4 ledger-sticky-panel">
        <div class="row align-items-center g-3">
            <div class="col-auto">
                <asp:DropDownList ID="ddlYear" runat="server" CssClass="form-control" AutoPostBack="true" onchange="showLoading();"></asp:DropDownList>
            </div>
            <div class="col-auto">
                <asp:DropDownList ID="ddlMonth" runat="server" CssClass="form-control" AutoPostBack="true" onchange="showLoading();">
                    <asp:ListItem Value="1">Jan</asp:ListItem>
                    <asp:ListItem Value="2">Feb</asp:ListItem>
                    <asp:ListItem Value="3">Mar</asp:ListItem>
                    <asp:ListItem Value="4">Apr</asp:ListItem>
                    <asp:ListItem Value="5">May</asp:ListItem>
                    <asp:ListItem Value="6">Jun</asp:ListItem>
                    <asp:ListItem Value="7">Jul</asp:ListItem>
                    <asp:ListItem Value="8">Aug</asp:ListItem>
                    <asp:ListItem Value="9">Sep</asp:ListItem>
                    <asp:ListItem Value="10">Oct</asp:ListItem>
                    <asp:ListItem Value="11">Nov</asp:ListItem>
                    <asp:ListItem Value="12">Dec</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-auto">
                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" AutoPostBack="true" onchange="showLoading();" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                    <asp:ListItem Value="All">All Categories</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-auto">
                <asp:DropDownList ID="ddlContract" runat="server" CssClass="form-control" AutoPostBack="true" onchange="showLoading();" Visible="false">
                </asp:DropDownList>
            </div>
            <div class="col-auto" style="min-width: 250px;">
                <div class="input-group">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search name / ID..."></asp:TextBox>
                    <div class="input-group-append">
                        <button type="button" class="btn btn-primary" onclick="showLoading(); document.getElementById('<%= btnGenerate.ClientID %>').click();" title="Search Database">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="col-auto" style="display: none;">
                <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
            </div>
            <div class="col-auto">
                <button type="button" class="btn btn-outline-success" onclick="exportExcel()">Export</button>
            </div>
            <div class="col-auto">
                <button type="button" class="btn btn-outline-info" onclick="exportSummaryExcel()">Export Summary</button>
            </div>
        </div>
    </div>

    <div class="table-responsive bg-white rounded-lg shadow-sm border" style="border-radius: 12px; overflow: visible !important;">
        <asp:GridView ID="gvLedger" runat="server" AutoGenerateColumns="False" CssClass="table table-hover table-custom mb-0" ClientIDMode="Static">
            <Columns>
                <asp:TemplateField HeaderText="S.No">
                    <ItemTemplate>
                        <%# Container.DataItemIndex + 1 %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ID" HeaderText="ID" />
                <asp:BoundField DataField="MasterID" HeaderText="Master ID" />
                <asp:BoundField DataField="Name" HeaderText="Name" ItemStyle-Font-Bold="true" />
                <asp:BoundField DataField="Department" HeaderText="Directorate" />
                <asp:BoundField DataField="Category" HeaderText="Category" />
                <asp:BoundField DataField="Opening" HeaderText="Opening" DataFormatString="{0:0.0}" />
                <asp:BoundField DataField="Paid" HeaderText="Paid (-)" ItemStyle-ForeColor="Red" />
                <asp:BoundField DataField="Half" HeaderText="Half" />
                <asp:BoundField DataField="Unpaid" HeaderText="Unpaid" />
                <asp:BoundField DataField="SatCut" HeaderText="Sat Cut" />
                <asp:BoundField DataField="Closing" HeaderText="Closing" DataFormatString="{0:0.0}" ItemStyle-CssClass="fw-bold bg-light" />
                <asp:BoundField DataField="PresentDays" HeaderText="Present" DataFormatString="{0:0.0}" />
                <asp:BoundField DataField="FinalDays" HeaderText="Final" DataFormatString="{0:0.0}" />
                <asp:TemplateField HeaderText="Remarks" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="remarks-col">
                    <ItemTemplate>
                        <%# FormatRemarks(Eval("Remarks")) %>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <script>
        function showLoading() {
            const overlay = document.getElementById("loadingOverlay");
            if (overlay) {
                overlay.style.display = "flex";
            }
        }

        // Upgraded Toast Notification System
        function showToast(msg, type = 'info') {
            let container = document.getElementById("toast-container");
            if (!container) {
                container = document.createElement("div");
                container.id = "toast-container";
                document.body.appendChild(container);
            }

            const toast = document.createElement("div");
            toast.className = `modern-toast toast-${type}`;
            
            let iconClass = "fas fa-info-circle";
            if (type === "success") iconClass = "fas fa-check-circle";
            else if (type === "warning") iconClass = "fas fa-exclamation-triangle";
            else if (type === "error") iconClass = "fas fa-times-circle";

            toast.innerHTML = `
                <div class="toast-icon"><i class="${iconClass}"></i></div>
                <div style="flex-grow: 1; padding-right: 8px;">${msg}</div>
                <button type="button" class="toast-close-btn" onclick="this.parentElement.classList.remove('toast-show'); setTimeout(() => this.parentElement.remove(), 400);">&times;</button>
            `;

            container.appendChild(toast);
            
            // Trigger reflow to run transition
            toast.offsetHeight;
            toast.classList.add("toast-show");

            // Auto dismiss
            setTimeout(() => {
                if (toast.parentElement) {
                    toast.classList.remove("toast-show");
                    toast.classList.add("toast-hide");
                    setTimeout(() => {
                        toast.remove();
                    }, 400);
                }
            }, 4000);
        }

        function showPop(msg) {
            let type = "info";
            let lowerMsg = msg.toLowerCase();
            if (lowerMsg.includes("success") || lowerMsg.includes("loaded")) {
                type = "success";
            } else if (lowerMsg.includes("error") || lowerMsg.includes("fail") || lowerMsg.includes("invalid")) {
                type = "error";
            } else if (lowerMsg.includes("warning")) {
                type = "warning";
            }
            showToast(msg, type);
        }

        document.addEventListener('keydown', function(event) {
            if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                event.preventDefault();
                if (event.target.id === '<%= txtSearch.ClientID %>') {
                    const btnGen = document.getElementById('<%= btnGenerate.ClientID %>');
                    if (btnGen) {
                        showLoading();
                        btnGen.click();
                    }
                }
                return false;
            }
        });

        function updateSNo() {
            const gvLedger = document.getElementById('gvLedger');
            if (!gvLedger) return;
            const rows = gvLedger.querySelectorAll('tr:not(:first-child)');
            let sNo = 1;
            rows.forEach(function(row) {
                if (row.style.display !== 'none' && row.cells.length > 0) {
                    row.cells[0].textContent = sNo++;
                }
            });
        }

        function sortGrid(colIdx, dir) {
            const gvLedger = document.getElementById('gvLedger');
            if (!gvLedger) return;
            const tbody = gvLedger.querySelector('tbody') || gvLedger;
            const rows = Array.from(gvLedger.querySelectorAll('tr:not(:first-child)'));
            
            rows.sort((a, b) => {
                const cellA = a.cells[colIdx];
                const cellB = b.cells[colIdx];
                if (!cellA || !cellB) return 0;
                
                const valA = cellA.innerText.trim().toLowerCase();
                const valB = cellB.innerText.trim().toLowerCase();
                
                // Try numeric sort if both values are valid numbers
                const numA = parseFloat(valA);
                const numB = parseFloat(valB);
                if (!isNaN(numA) && !isNaN(numB)) {
                    return dir === 'asc' ? numA - numB : numB - numA;
                }
                
                return dir === 'asc' ? valA.localeCompare(valB) : valB.localeCompare(valA);
            });
            
            // Re-append sorted rows to the tbody
            rows.forEach(row => tbody.appendChild(row));
            
            // Re-sequence serial numbers
            updateSNo();
        }

        function adjustStickyHeaderPosition() {
            const panel = document.querySelector('.ledger-sticky-panel');
            if (panel) {
                const height = panel.offsetHeight;
                document.documentElement.style.setProperty('--ledger-table-top', (60 + height) + 'px');
            }
        }
        window.addEventListener('resize', adjustStickyHeaderPosition);
        window.addEventListener('load', adjustStickyHeaderPosition);
        document.addEventListener('DOMContentLoaded', adjustStickyHeaderPosition);

        // Real-time client-side table row filtering and page-load notifications
        document.addEventListener("DOMContentLoaded", () => {
            const txtSearch = document.getElementById('<%= txtSearch.ClientID %>');
            const gvLedger = document.getElementById('gvLedger');
            
            if (txtSearch && gvLedger) {
                txtSearch.addEventListener('input', function() {
                    const query = this.value.toLowerCase().trim();
                    const rows = gvLedger.getElementsByTagName('tr');
                    
                    // Start from index 1 to skip header row
                    for (let i = 1; i < rows.length; i++) {
                        const row = rows[i];
                        if (row.cells.length < 5) continue; // Skip pager or empty rows
                        
                        const idText = row.cells[1] ? row.cells[1].innerText.toLowerCase() : '';
                        const masterIdText = row.cells[2] ? row.cells[2].innerText.toLowerCase() : '';
                        const nameText = row.cells[3] ? row.cells[3].innerText.toLowerCase() : '';
                        const deptText = row.cells[4] ? row.cells[4].innerText.toLowerCase() : '';
                        
                        if (idText.includes(query) || masterIdText.includes(query) || nameText.includes(query) || deptText.includes(query)) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    }
                    updateSNo();
                });
            }

            // Add sorting capability to headers: ID (1), Name (3), Directorate (4), Category (5)
            if (gvLedger) {
                const sortableIndices = [1, 3, 4, 5];
                const headerRow = gvLedger.querySelector('tr:first-child');
                if (headerRow) {
                    sortableIndices.forEach(index => {
                        const th = headerRow.cells[index];
                        if (th) {
                            th.style.cursor = 'pointer';
                            th.style.userSelect = 'none';
                            th.classList.add('sortable-header');
                            // Add Sort Icon container
                            th.innerHTML = th.textContent.trim() + ' <span class="sort-icon ml-1" style="color: #94a3b8; font-size: 0.75rem;"><i class="fas fa-sort"></i></span>';
                            th.setAttribute('data-sort-index', index);
                            th.setAttribute('data-sort-dir', 'none');
                            
                            th.addEventListener('click', function() {
                                const colIdx = parseInt(this.getAttribute('data-sort-index'));
                                let currentDir = this.getAttribute('data-sort-dir');
                                let nextDir = (currentDir === 'asc') ? 'desc' : 'asc';
                                
                                // Reset all other headers
                                sortableIndices.forEach(idx => {
                                    const otherTh = headerRow.cells[idx];
                                    if (otherTh && idx !== colIdx) {
                                        otherTh.setAttribute('data-sort-dir', 'none');
                                        const icon = otherTh.querySelector('.sort-icon i');
                                        if (icon) {
                                            icon.className = 'fas fa-sort';
                                            icon.style.color = '#94a3b8';
                                        }
                                    }
                                });
                                
                                // Set current header direction
                                this.setAttribute('data-sort-dir', nextDir);
                                const icon = this.querySelector('.sort-icon i');
                                if (icon) {
                                    icon.className = (nextDir === 'asc') ? 'fas fa-sort-up' : 'fas fa-sort-down';
                                    icon.style.color = '#4f46e5'; // active color
                                }
                                
                                // Perform sort
                                sortGrid(colIdx, nextDir);
                            });
                        }
                    });
                }
            }

            // Check if this page load is a postback (e.g. dropdown changed or search submitted)
            const isPostBack = <%= Page.IsPostBack.ToString().ToLower() %>;
            if (isPostBack) {
                const year = document.getElementById('<%= ddlYear.ClientID %>').value;
                const monthSelect = document.getElementById('<%= ddlMonth.ClientID %>');
                const monthText = monthSelect.options[monthSelect.selectedIndex].text;
                const category = document.getElementById('<%= ddlCategory.ClientID %>').value;
                
                let text = `Loaded ledger for ${monthText} ${year} (${category})`;
                <% if (ddlContract.Visible) { %>
                    const contractSelect = document.getElementById('<%= ddlContract.ClientID %>');
                    if (contractSelect && contractSelect.selectedIndex >= 0) {
                        text += ` - ${contractSelect.options[contractSelect.selectedIndex].text}`;
                    }
                <% } %>
                showPop(text + " successfully!");
            }
            
            // Show loading on page unload (postback submit)
            const form = document.getElementById('form1');
            if (form) {
                form.addEventListener('submit', function() {
                    showLoading();
                });
            }
        });

        function exportExcel() {
            if (typeof XLSX === "undefined") {
                alert("XLSX library not loaded");
                return;
            }
            let table = document.getElementById("gvLedger");
            if (!table) return alert("No data to export!");

            // Remove S.No column before export
            let exportTable = table.cloneNode(true);
            for(let i=0; i<exportTable.rows.length; i++) {
                exportTable.rows[i].deleteCell(0);
            }

            const wb = XLSX.utils.table_to_book(exportTable, {sheet:"Ledger"});
            XLSX.writeFile(wb, "Leave_Ledger.xlsx", { bookType: "xlsx", type: "binary" });
        }

        function exportSummaryExcel() {
            if (typeof XLSX === "undefined") {
                alert("XLSX library not loaded");
                return;
            }
            let table = document.getElementById("gvLedger");
            if (!table) return alert("No data to export!");

            let data = [];
            let rows = table.rows;
            // Start from 1 to skip header
            for(let i=1; i<rows.length; i++) {
                data.push({
                    Name: rows[i].cells[3].innerText,
                    Directorate: rows[i].cells[4].innerText,
                    Paid: rows[i].cells[7].innerText,
                    Unpaid: rows[i].cells[9].innerText,
                    "Sat Cut": rows[i].cells[10].innerText
                });
            }

            const ws = XLSX.utils.json_to_sheet(data);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Summary");
            
            let mText = document.getElementById('<%= ddlMonth.ClientID %>').options[document.getElementById('<%= ddlMonth.ClientID %>').selectedIndex].text;
            XLSX.writeFile(wb, `Summary_${mText}.xlsx`, { bookType: "xlsx", type: "binary" });
        }
    </script>
</asp:Content>
