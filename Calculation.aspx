<%@ Page Title="Calculation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calculation.aspx.cs" Inherits="AttendanceApp.Calculation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Calculation
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Static/js/xlsx.full.min.js"></script>
    <style>
        /* Modern Premium Table Styling for Calculation Page */
        .table-calc {
            border-collapse: separate !important;
            border-spacing: 0 !important;
            width: 100% !important;
            border: none !important; /* Managed by the outer responsive container border */
            background-color: #fff;
        }
        .table-calc th {
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
            text-align: center !important;
        }
        .table-calc th:last-child {
            border-right: none !important;
        }
        .table-calc td {
            padding: 14px 20px !important;
            color: #334155 !important; /* Charcoal slate */
            font-size: 0.92rem !important;
            font-weight: 500 !important;
            border-bottom: 1px solid #e2e8f0 !important; /* Horizontal separating lines */
            border-left: none !important;
            border-right: 1px solid #f1f5f9 !important; /* Soft vertical separating lines */
            vertical-align: middle !important;
            text-align: center !important;
        }
        .table-calc td.name-col {
            text-align: left !important;
            padding-left: 20px !important;
            font-weight: 600 !important;
            color: #0f172a !important;
        }
        .table-calc td:last-child {
            border-right: none !important;
        }
        .table-calc tr:last-child td {
            border-bottom: none !important; /* Remove bottom border on the last row */
        }
        .table-calc tr {
            transition: background-color 0.2s ease;
        }
        .table-calc tr:hover {
            background-color: #eef2ff !important; /* Distinct light indigo hover */
        }
        .table-calc tr:nth-child(even) {
            background-color: #fbfcfd;
        }
        /* Custom Styling for Total Row */
        .table-calc tr.total-row {
            background-color: #ecfdf5 !important; /* Light emerald green */
        }
        .table-calc tr.total-row td {
            color: #047857 !important; /* Dark emerald green */
            border-bottom: none !important;
            font-weight: 700 !important;
        }
        
        .table-calc .btn-outline-primary {
            border-color: #e2e8f0 !important;
            color: #4f46e5 !important;
            background-color: #f8fafc !important;
            border-radius: 6px !important;
            font-weight: 600 !important;
            padding: 5px 12px !important;
            font-size: 0.8rem !important;
            transition: all 0.2s ease !important;
        }
        .table-calc .btn-outline-primary:hover {
            background-color: #4f46e5 !important;
            border-color: #4f46e5 !important;
            color: white !important;
            transform: translateY(-1.5px) !important;
            box-shadow: 0 4px 10px rgba(79, 70, 229, 0.15) !important;
        }
        
        /* Premium Invoice Summary Card */
        .summary-card {
            margin-top: 24px;
            background: #ffffff;
            border: 1px solid #e3e6f0;
            border-radius: 8px;
            padding: 20px;
            max-width: 400px;
            margin-left: auto;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border-top: 4px solid #4f46e5;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 0.95rem;
            color: #4e73df;
        }
        .summary-row-total {
            display: flex;
            justify-content: space-between;
            margin-top: 12px;
            padding-top: 12px;
            border-top: 2px dashed #e3e6f0;
            font-size: 1.15rem;
            font-weight: bold;
            color: #1a237e;
        }

        /* Custom spacing and layout for Calculation page controls */
        .calc-controls-container {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            justify-content: space-between;
            width: 100%;
        }
        .calc-left-group {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            flex-grow: 1;
        }
        .calc-control-item {
            margin-right: 16px;
            margin-bottom: 12px;
            min-width: 110px;
            flex: 1 1 auto;
        }
        .calc-control-item-category {
            margin-right: 16px;
            margin-bottom: 12px;
            min-width: 160px;
            flex: 1.5 1 auto;
        }
        .calc-control-item-wage {
            margin-right: 16px;
            margin-bottom: 12px;
            min-width: 240px;
            max-width: 260px;
            flex: 1.2 1 auto;
        }
        .calc-right-group {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            margin-bottom: 12px;
        }
        
        /* Select and Input styling to ensure matching heights */
        .calc-left-group select.form-control, 
        .calc-left-group input.form-control {
            height: 38px !important;
            font-size: 0.9rem;
            border-radius: 4px;
            border: 1px solid #d1d3e2;
            color: #111827;
            font-weight: 500;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
        }
        .calc-left-group select.form-control:focus, 
        .calc-left-group input.form-control:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 0.2rem rgba(79,70,229,0.25);
        }
        #category {
            transition: all 0.2s ease-in-out;
        }
        #category:focus {
            border-color: #4f46e5 !important;
            box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.35) !important;
            transform: scale(1.02);
        }
        
        /* Appended Save Wage button specific styling */
        .btn-save-wage {
            height: 38px !important;
            border-top-right-radius: 4px !important;
            border-bottom-right-radius: 4px !important;
            border-top-left-radius: 0 !important;
            border-bottom-left-radius: 0 !important;
            background-color: #4f46e5;
            border-color: #4f46e5;
            color: white !important;
            font-size: 0.85rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 12px;
            transition: all 0.2s ease;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-save-wage:hover {
            background-color: #3730a3;
            border-color: #3730a3;
        }
        .btn-save-wage i {
            margin-right: 4px;
        }

        /* Standalone Actions Button Styling */
        .btn-custom {
            height: 38px !important;
            padding: 0 18px;
            font-size: 0.9rem;
            font-weight: 600;
            border-radius: 4px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: none;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
            cursor: pointer;
            color: white !important;
        }
        .btn-custom i {
            margin-right: 6px;
        }
        .btn-custom-calc {
            background-color: #10b981;
            margin-right: 8px;
        }
        .btn-custom-calc:hover {
            background-color: #059669;
            box-shadow: 0 4px 8px rgba(16,185,129,0.2);
            transform: translateY(-1px);
        }
        .btn-custom-export {
            background-color: #f59e0b;
        }
        .btn-custom-export:hover {
            background-color: #d97706;
            box-shadow: 0 4px 8px rgba(245,158,11,0.2);
            transform: translateY(-1px);
        }

        /* Custom styled Override Modal Overlay */
        #overrideModal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.4);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            z-index: 100000;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .swal2-container {
            z-index: 200000 !important;
        }
        
        .confirm-modal-box {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25), inset 0 0 0 1px rgba(255, 255, 255, 0.6);
            width: 480px;
            max-width: 90%;
            transform: scale(0.92);
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            overflow: hidden;
            font-family: 'Segoe UI', system-ui, sans-serif;
            border: 1px solid rgba(226, 232, 240, 0.8);
        }
        
        .confirm-modal-header {
            background: #f8fafc;
            padding: 20px 24px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        
        .confirm-modal-icon-container {
            background: #fef3c7;
            color: #d97706;
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 6px -1px rgba(217, 119, 6, 0.1);
        }
        
        .confirm-modal-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: #0f172a;
            letter-spacing: -0.01em;
        }
        
        .confirm-modal-body {
            padding: 24px;
            font-size: 1rem;
            line-height: 1.6;
            color: #334155;
        }
        
        .confirm-modal-footer {
            background: #f8fafc;
            padding: 16px 24px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .btn-modal-action {
            padding: 10px 18px;
            font-size: 0.88rem;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        
        .btn-modal-cancel {
            border: 1px solid #cbd5e1;
            background: white;
            color: #475569;
        }
        .btn-modal-cancel:hover {
            background: #f1f5f9;
            color: #1e293b;
            border-color: #94a3b8;
        }
        
        .btn-modal-save {
            background: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
        }
        .btn-modal-save:hover {
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.35);
            transform: translateY(-1px);
            color: white !important;
        }
        
        /* Interactive sort headers styling for Calculation page */
        .sortable-th {
            cursor: pointer !important;
            user-select: none !important;
            position: relative;
            transition: background-color 0.2s ease;
        }
        .sortable-th:hover {
            background-color: #cbd5e1 !important;
            color: #0f172a !important;
        }

        .calc-sticky-card {
            position: sticky;
            top: 60px;
            z-index: 1010;
            background-color: #fff;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }
        .table-calc thead th {
            position: sticky !important;
            top: var(--calc-table-top, 145px) !important;
            z-index: 990 !important;
        }
        /* Hide spinner arrows on number inputs */
        input::-webkit-outer-spin-button,
        input::-webkit-inner-spin-button {
            -webkit-appearance: none !important;
            margin: 0 !important;
        }
        input[type=number] {
            -moz-appearance: textfield !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="h3 mb-0 text-gray-800">Salary Calculation</h2>
    </div>
    
    <div class="card shadow-sm border-0 rounded-lg mb-4 calc-sticky-card">
        <div class="card-body p-4 bg-white text-dark">
            <div class="calc-controls-container">
                <!-- Left Side: Dropdowns and Wage Input -->
                <div class="calc-left-group">
                    <!-- Year selector -->
                    <div class="calc-control-item">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-calendar mr-1 text-primary"></i> Year
                        </label>
                        <select id="year" class="form-control" onchange="onSelectionChange()"></select>
                    </div>
                    
                    <!-- Month selector -->
                    <div class="calc-control-item">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-calendar-alt mr-1 text-primary"></i> Month
                        </label>
                        <select id="month" class="form-control" onchange="onSelectionChange()"></select>
                    </div>
                    
                    <!-- Category selector -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-th-list mr-1 text-primary"></i> Category
                        </label>
                        <select id="category" class="form-control" onchange="onSelectionChange()" autofocus="autofocus">
                        </select>
                    </div>
                    
                    <!-- Directorate selector -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-building mr-1 text-primary"></i> Directorate
                        </label>
                        <select id="division" class="form-control" onchange="onSelectionChange(true)">
                        </select>
                    </div>
                    
                    <!-- Contract selector -->
                    <div id="contractDiv" class="calc-control-item-category" style="display: none;">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-file-contract mr-1 text-primary"></i> Contract Period
                        </label>
                        <select id="contract" class="form-control" onchange="onSelectionChange(true)">
                        </select>
                    </div>
                    
                    <!-- Search input -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-search mr-1 text-primary"></i> Search
                        </label>
                        <input id="search" class="form-control" placeholder="Search ID/Name" oninput="onSearchInput()" />
                    </div>
                    
                    <!-- Wage Rate selector (Read-only, loaded from saved Settings data) -->
                    <div class="calc-control-item-wage">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-money-bill-wave mr-1 text-primary"></i> Wage Rate
                        </label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text bg-light"><i class="fas fa-rupee-sign text-secondary"></i></span>
                            </div>
                            <input type="text" id="wage" class="form-control" placeholder="Rate" readonly="readonly" style="background-color: #f1f5f9; cursor: not-allowed;" />
                        </div>
                    </div>
                </div>
                
                <!-- Right Side: Action Buttons -->
                <div class="calc-right-group">
                    <button type="button" class="btn btn-custom btn-custom-calc" onclick="render()">
                        <i class="fas fa-calculator"></i> Calculate
                    </button>
                    <button type="button" class="btn btn-custom btn-custom-export" onclick="exportFull()">
                        <i class="fas fa-file-excel"></i> Export Excel
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div id="result"></div>

    <!-- Custom Override Modal Overlay -->
    <div id="overrideModal">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header" style="background: #eef2ff; border-bottom: 1px solid #e2e8f0;">
                <div class="confirm-modal-icon-container" style="background: #e0e7ff; color: #4f46e5; box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.1);">
                    <i class="fas fa-edit"></i>
                </div>
                <span class="confirm-modal-title">Override Final Days</span>
            </div>
            <div class="confirm-modal-body">
                <div style="font-size: 0.95rem; color: #475569; margin-bottom: 16px;">
                    Enter the final working days to override for employee <strong id="overrideEmpName" class="text-dark"></strong> (ID: <span id="overrideEmpId" class="text-secondary"></span>).
                </div>
                <div class="form-group">
                    <label for="overrideDaysInput" class="font-weight-bold" style="font-size: 0.88rem; color: #334155; margin-bottom: 6px;">New Final Days Value</label>
                    <input type="number" id="overrideDaysInput" class="form-control" step="0.5" placeholder="e.g. 26, 24.5" style="height: 42px; font-size: 1rem; border-radius: 8px;" />
                </div>
                <div class="form-group mb-0 mt-3">
                    <label for="overrideRemarksInput" class="font-weight-bold" style="font-size: 0.88rem; color: #334155; margin-bottom: 6px;">Remarks</label>
                    <input type="text" id="overrideRemarksInput" class="form-control" placeholder="Reason for override" style="height: 42px; font-size: 1rem; border-radius: 8px;" />
                </div>
                <div id="calcRecentRemarksContainer"></div>
            </div>
            <div class="confirm-modal-footer">
                <button id="btnOverrideReset" type="button" class="btn-modal-action" style="background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; margin-right: auto; display: none; padding: 10px 18px; font-size: 0.88rem; font-weight: 600; border-radius: 8px; cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); align-items: center; justify-content: center;">Reset to Normal</button>
                <button id="btnOverrideCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnOverrideApply" type="button" class="btn-modal-action btn-modal-save">Apply</button>
            </div>
        </div>
    </div>

    <script>
        function adjustStickyHeaderPosition() {
            const card = document.querySelector('.calc-sticky-card');
            if (card) {
                const height = card.offsetHeight;
                document.documentElement.style.setProperty('--calc-table-top', (60 + height) + 'px');
            }
        }
        window.addEventListener('resize', adjustStickyHeaderPosition);
        window.addEventListener('load', adjustStickyHeaderPosition);
        document.addEventListener('DOMContentLoaded', adjustStickyHeaderPosition);

        const year = document.getElementById("year");
        const month = document.getElementById("month");
        const category = document.getElementById("category");
        const division = document.getElementById("division");
        const wage = document.getElementById("wage");
        const searchBox = document.getElementById("search");
        const result = document.getElementById("result");
        let calcData = [];
        let currentSortCol = "";
        let currentSortDir = "none";

        for(let y=2020; y<=2100; y++) year.innerHTML+=`<option>${y}</option>`;
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].forEach((m, i) => {
            month.innerHTML += `<option value="${i}">${m}</option>`;
        });

        year.value = new Date().getFullYear();
        month.value = new Date().getMonth();

        // Fetch categories from DB and populate selector
        fetch('Calculation.aspx/GetCategories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }).then(r => r.json()).then(res => {
            const categories = JSON.parse(res.d);
            category.innerHTML = '<option value="All">All Categories</option>';
            categories.forEach(cat => {
                const parts = cat.split(':');
                if (parts.length > 1) {
                    category.innerHTML += `<option value="${parts[0]}">${parts[1]}</option>`;
                } else {
                    category.innerHTML += `<option>${cat}</option>`;
                }
            });
            
            // Fetch divisions from DB and populate selector
            return fetch('Calculation.aspx/GetDivisions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
        }).then(r => r.json()).then(res => {
            const divisions = JSON.parse(res.d);
            division.innerHTML = '<option value="All">All Directorates</option>';
            divisions.forEach(div => {
                division.innerHTML += `<option>${div}</option>`;
            });
            onSelectionChange(false);
            category.focus();
        }).catch(e => {
            console.error(e);
            onSelectionChange(false);
            category.focus();
        });

        function onSelectionChange(isDivisionOrWageChange) {
            if (isDivisionOrWageChange) {
                const contractSelect = document.getElementById("contract");
                const selectedCpId = contractSelect && contractSelect.value ? parseInt(contractSelect.value) : null;
                render(selectedCpId);
            } else {
                wage.value = ""; // Clear wage to fetch stored rate
                updateContractsAndRender();
            }
        }

        function updateContractsAndRender() {
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value
            };

            if (category.value === "All") {
                document.getElementById("contractDiv").style.display = "none";
                document.getElementById("contract").innerHTML = "";
                render(null);
                return;
            }

            fetch('Calculation.aspx/GetContractsForMonth', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                const contracts = JSON.parse(res.d);
                const contractDiv = document.getElementById("contractDiv");
                const contractSelect = document.getElementById("contract");
                
                if (contracts.length > 1) {
                    let optionsHtml = "";
                    contracts.forEach(c => {
                        optionsHtml += `<option value="${c.Value}">${c.Text}</option>`;
                    });
                    contractSelect.innerHTML = optionsHtml;
                    contractDiv.style.display = "block";
                    render(parseInt(contractSelect.value));
                } else {
                    contractDiv.style.display = "none";
                    contractSelect.innerHTML = "";
                    const activeCpId = contracts.length === 1 ? contracts[0].Value : null;
                    render(activeCpId);
                }
            }).catch(e => {
                console.error(e);
                render(null);
            });
        }

        let searchTimeout = null;
        function onSearchInput() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                const contractSelect = document.getElementById("contract");
                const selectedCpId = contractSelect && contractSelect.value ? parseInt(contractSelect.value) : null;
                render(selectedCpId);
            }, 300);
        }

        function getSortIcon(colName) {
            if (currentSortCol !== colName || currentSortDir === "none") {
                return '<span style="color: #94a3b8; font-size: 0.75rem;" class="ml-1"><i class="fas fa-sort"></i></span>';
            }
            if (currentSortDir === "asc") {
                return '<span style="color: #4f46e5; font-size: 0.75rem;" class="ml-1"><i class="fas fa-sort-up"></i></span>';
            } else {
                return '<span style="color: #4f46e5; font-size: 0.75rem;" class="ml-1"><i class="fas fa-sort-down"></i></span>';
            }
        }

        function sortCalcData(colName) {
            if (currentSortCol === colName) {
                currentSortDir = (currentSortDir === "asc") ? "desc" : "asc";
            } else {
                currentSortCol = colName;
                currentSortDir = "asc";
            }

            calcData.sort((a, b) => {
                let valA = a[colName] !== undefined ? a[colName] : "";
                let valB = b[colName] !== undefined ? b[colName] : "";

                let strA = String(valA).trim().toLowerCase();
                let strB = String(valB).trim().toLowerCase();

                let numA = parseFloat(strA);
                let numB = parseFloat(strB);
                if (!isNaN(numA) && !isNaN(numB)) {
                    return currentSortDir === "asc" ? numA - numB : numB - numA;
                }

                return currentSortDir === "asc" ? strA.localeCompare(strB) : strB.localeCompare(strA);
            });

            drawTable();
        }

        function render(contractPeriodId) {
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                division: division.value,
                wage: parseFloat(wage.value) || 0,
                contractPeriodId: contractPeriodId || null,
                search: searchBox.value
            };

            fetch('Calculation.aspx/GetCalculationData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                calcData = JSON.parse(res.d);
                if (calcData.length > 0 && req.wage === 0) {
                    if (category.value !== "All") {
                        wage.value = calcData[0].WageRate;
                    } else {
                        wage.value = "";
                    }
                }
                
                // If sort column is set, sort the loaded data
                if (currentSortCol && currentSortDir !== "none") {
                    calcData.sort((a, b) => {
                        let valA = a[currentSortCol] !== undefined ? a[currentSortCol] : "";
                        let valB = b[currentSortCol] !== undefined ? b[currentSortCol] : "";
                        let strA = String(valA).trim().toLowerCase();
                        let strB = String(valB).trim().toLowerCase();
                        let numA = parseFloat(strA);
                        let numB = parseFloat(strB);
                        if (!isNaN(numA) && !isNaN(numB)) {
                            return currentSortDir === "asc" ? numA - numB : numB - numA;
                        }
                        return currentSortDir === "asc" ? strA.localeCompare(strB) : strB.localeCompare(strA);
                    });
                }
                
                drawTable();
            }).catch(e => console.error(e));
        }

        function drawTable() {
            if (calcData.length === 0) {
                result.innerHTML = "<h4>No records found</h4>";
                return;
            }

            let totalDays = 0, totalAmount = 0;
            let dayCountMap = {};
            let tableHtml = `<div class="table-responsive bg-white rounded-lg shadow-sm border mb-4" style="border-radius: 12px; overflow: visible !important;">`;
            tableHtml += `<table class="table-calc"><thead><tr>
                <th onclick="sortCalcData('ID')" class="sortable-th">ID ${getSortIcon('ID')}</th>
                <th onclick="sortCalcData('MasterId')" class="sortable-th">Master ID ${getSortIcon('MasterId')}</th>
                <th onclick="sortCalcData('Name')" class="sortable-th" style="text-align: left !important; padding-left: 20px !important;">Name ${getSortIcon('Name')}</th>
                <th>Directorate</th>
                <th onclick="sortCalcData('Category')" class="sortable-th">Category ${getSortIcon('Category')}</th>
                <th>Present</th>
                <th>Final</th>
                <th>Edit</th>
                <th>Amount</th>
            </tr></thead><tbody>`;

            calcData.forEach(emp => {
                totalDays += emp.Final;
                totalAmount += emp.Amount;
                
                // Populate Days vs Employees map
                dayCountMap[emp.Final] = (dayCountMap[emp.Final] || 0) + 1;

                let finalStyle = emp.IsOverridden ? `style="color: #ea580c !important; font-weight: bold;"` : "";
                let finalTitle = emp.IsOverridden ? `title="${emp.Remarks.replace(/"/g, '&quot;')}"` : "";

                tableHtml += `<tr>
                    <td>${emp.ID}</td>
                    <td>${emp.MasterId}</td>
                    <td class="name-col">${emp.Name}</td>
                    <td>${emp.Department}</td>
                    <td>${emp.Category}</td>
                    <td>${emp.Present}</td>
                    <td ${finalStyle} ${finalTitle}>${emp.Final}</td>
                    <td><button type="button" class="btn btn-sm btn-outline-primary" onclick="editOverride('${emp.MasterId}', '${emp.Category}')"><i class="fas fa-edit"></i> Edit</button></td>
                    <td>${emp.Amount.toFixed(2)}</td>
                </tr>`;
            });

            tableHtml += `<tr class="total-row">
                <td colspan="6">Total</td>
                <td>${totalDays}</td><td></td>
                <td>${totalAmount.toFixed(2)}</td>
            </tr></tbody></table></div>`;

            // Build Days vs Employees Breakdown
            let breakdownHtml = `<div class="list-group list-group-flush">`;
            Object.keys(dayCountMap).sort((a, b) => b - a).forEach(d => {
                breakdownHtml += `<div class="list-group-item d-flex justify-content-between align-items-center py-2 px-3">
                    <span class="text-gray-800 font-weight-bold" style="font-size: 0.9rem;">
                        <i class="fas fa-calendar-day text-secondary mr-2"></i>${d} days
                    </span>
                    <span class="badge badge-primary badge-pill px-3 py-2 font-weight-bold" style="font-size: 0.85rem; border-radius: 20px;">
                        ${dayCountMap[d]} ${dayCountMap[d] === 1 ? 'person' : 'people'}
                    </span>
                </div>`;
            });
            breakdownHtml += `</div>`;

            // Save calculated data to localStorage for the invoice generator
            const finalEmployees = calcData.map(emp => ({
                id: emp.ID,
                name: emp.Name,
                dept: emp.Department,
                days: emp.Final,
                present: emp.Present,
                final: emp.Final,
                amt: emp.Amount,
                rate: emp.WageRate
            }));

            localStorage.setItem("finalData", JSON.stringify({
                employees: finalEmployees,
                rate: parseFloat(wage.value) || 0,
                category: category.value,
                year: parseInt(year.value),
                month: parseInt(month.value)
            }));

            // Build Invoice Action Card with "Generate Invoice" button
            let summaryCardHtml = `<div class="card shadow-sm border-0 h-100" style="border-top: 4px solid #4f46e5 !important;">
                <div class="card-header bg-white py-3 border-0">
                    <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-file-invoice mr-2"></i>Actions</h6>
                </div>
                <div class="card-body d-flex flex-column align-items-center justify-content-center p-4" style="min-height: 220px;">
                    <div class="text-center mb-4">
                        <i class="fas fa-file-invoice-dollar fa-3x text-muted mb-3" style="opacity: 0.35;"></i>
                        <h6 class="font-weight-bold text-dark mb-1">Generate Wage Statement</h6>
                        <p class="text-muted small px-3">Ready to export the monthly wages calculations as a formatted Excel sheet or print-ready document in the Document Hub.</p>
                    </div>
                    <button type="button" class="btn btn-primary px-5 py-2 font-weight-bold" onclick="generateInvoice()" style="font-size: 1.05rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(79,70,229,0.25);">
                        <i class="fas fa-file-invoice mr-2"></i> Generate Invoice
                    </button>
                </div>
            </div>`;

            // Combine everything into side-by-side cards below the table
            let footerHtml = `
            <div class="row mt-4">
                <!-- Days vs Employees Card -->
                <div class="col-md-6 mb-4">
                    <div class="card shadow-sm border-0 h-100">
                        <div class="card-header bg-white py-3 border-0">
                            <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-users mr-2"></i>Days vs Employees Breakdown</h6>
                        </div>
                        <div class="card-body p-0">
                            ${breakdownHtml}
                        </div>
                    </div>
                </div>
                
                <!-- Invoice Summary Card -->
                <div class="col-md-6 mb-4">
                    ${summaryCardHtml}
                </div>
            </div>`;

            result.innerHTML = tableHtml + footerHtml;
        }

        function generateInvoice() {
            const yearVal = document.getElementById("year").value;
            const monthVal = document.getElementById("month").value;
            const catVal = document.getElementById("category").value;
            const wageVal = document.getElementById("wage").value;
            const contractVal = document.getElementById("contract").value || "";
            
            const url = `Documents.aspx?doc=wages-calc&year=${yearVal}&month=${monthVal}&category=${encodeURIComponent(catVal)}&wage=${wageVal}&contract=${contractVal}`;
            window.location.href = url;
        }

        function saveWage() {
            if (category.value === "All") {
                showToast("Please select a specific category to save its wage rate.", "warning");
                return;
            }
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                wage: parseFloat(wage.value) || 0
            };
            fetch('Calculation.aspx/SaveWage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(() => {
                showToast("Wage rate saved successfully to database.", "success");
                const contractSelect = document.getElementById("contract");
                const selectedCpId = contractSelect && contractSelect.value ? parseInt(contractSelect.value) : null;
                render(selectedCpId);
            }).catch(e => console.error(e));
        }

        function getRecentCalcRemarks() {
            const remarksSet = new Set();
            if (calcData && Array.isArray(calcData)) {
                calcData.forEach(emp => {
                    if (emp && emp.Remarks && emp.Remarks.trim() !== "") {
                        remarksSet.add(emp.Remarks.trim());
                    }
                });
            }
            const defaults = ["LWP", "Half Day Present", "Training", "Special Duty", "Rejoined in middle of month", "Resigned in middle of month", "Duplicate Entry"];
            defaults.forEach(d => {
                if (remarksSet.size < 15) {
                    remarksSet.add(d);
                }
            });
            return Array.from(remarksSet);
        }

        function populateRecentCalcRemarks() {
            const container = document.getElementById("calcRecentRemarksContainer");
            if (!container) return;
            
            const list = getRecentCalcRemarks();
            if (list.length === 0) {
                container.innerHTML = "";
                return;
            }
            
            let html = `<label class="font-weight-bold mb-1" style="font-size: 0.8rem; color: #64748b; margin-top: 12px; display: block;">Recent / Common Remarks (Click to select):</label>`;
            html += `<div style="display: flex; flex-wrap: wrap; gap: 6px; max-height: 120px; overflow-y: auto; padding: 2px;">`;
            list.forEach(rem => {
                const escaped = rem.replace(/'/g, "\\'").replace(/"/g, "&quot;");
                html += `<span class="badge" onclick="document.getElementById('overrideRemarksInput').value = '${escaped}';" style="cursor: pointer; background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; padding: 5px 10px; border-radius: 15px; font-size: 0.78rem; font-weight: 600; display: inline-block; user-select: none; transition: all 0.15s;" onmouseover="this.style.backgroundColor='#e2e8f0'; this.style.borderColor='#94a3b8';" onmouseout="this.style.backgroundColor='#f1f5f9'; this.style.borderColor='#cbd5e1';">${rem}</span>`;
            });
            html += `</div>`;
            container.innerHTML = html;
        }

        function editOverride(id, catName) {
            const emp = calcData.find(e => e.MasterId === id && e.Category === catName);
            if (!emp) return;

            const modal = document.getElementById("overrideModal");
            const empNameLabel = document.getElementById("overrideEmpName");
            const empIdLabel = document.getElementById("overrideEmpId");
            const inputField = document.getElementById("overrideDaysInput");
            const remarksField = document.getElementById("overrideRemarksInput");
            const btnApply = document.getElementById("btnOverrideApply");
            const btnCancel = document.getElementById("btnOverrideCancel");
            const btnReset = document.getElementById("btnOverrideReset");

            if (!modal || !empNameLabel || !empIdLabel || !inputField || !remarksField || !btnReset) return;

            btnReset.style.display = emp.IsOverridden ? "inline-flex" : "none";

            empNameLabel.textContent = emp.Name;
            empIdLabel.textContent = emp.ID;
            inputField.value = emp.Final;
            remarksField.value = emp.Remarks || "";
            
            populateRecentCalcRemarks();

            modal.style.display = "flex";
            modal.offsetHeight; // trigger reflow
            modal.style.opacity = "1";
            modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";

            function closeModal() {
                modal.style.opacity = "0";
                modal.querySelector(".confirm-modal-box").style.transform = "scale(0.92)";
                setTimeout(() => {
                    modal.style.display = "none";
                }, 250);
            }

            btnCancel.onclick = function() {
                closeModal();
            };

            btnReset.onclick = function() {
                closeModal();
                const empNameEscaped = (emp.Name || '').replace(/</g, "&lt;").replace(/>/g, "&gt;");
                Swal.fire({
                    title: 'Reset Override to Normal?',
                    html: `Are you sure you want to remove the final days override for <strong>${empNameEscaped}</strong>?<br/><span style="font-size:0.85rem; color:#64748b; margin-top:6px; display:inline-block;">The working days will automatically revert to calculated attendance days.</span>`,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc2626',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: '<i class="fas fa-undo mr-1"></i> Reset to Normal',
                    cancelButtonText: 'Cancel',
                    reverseButtons: true,
                    customClass: {
                        popup: 'shadow-lg border-0',
                        confirmButton: 'font-weight-bold btn btn-danger',
                        cancelButton: 'font-weight-bold btn btn-secondary'
                    }
                }).then((result) => {
                    if (result.isConfirmed) {
                        const req = {
                            year: parseInt(year.value),
                            month: parseInt(month.value),
                            category: catName,
                            empId: id
                        };

                        fetch('Calculation.aspx/DeleteOverride', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(req)
                        }).then(r => r.json()).then(res => {
                            if (res.d && res.d.includes("error")) {
                                showToast(res.d, "error");
                            } else {
                                showToast(`Override reset to normal for ${emp.Name}`, "success");
                                render();
                            }
                        }).catch(e => {
                            console.error(e);
                            showToast("Error deleting override: " + e.message, "error");
                        });
                    } else {
                        // Re-open override modal if user cancelled
                        modal.style.display = "flex";
                        modal.offsetHeight; // trigger reflow
                        modal.style.opacity = "1";
                        modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";
                    }
                });
            };

            btnApply.onclick = function() {
                const val = inputField.value.trim();
                if (val === "") {
                    showToast("Please enter a valid override value.", "warning");
                    inputField.focus();
                    return;
                }

                const finalDays = parseFloat(val);
                if (isNaN(finalDays)) {
                    showToast("Please enter a valid numeric value.", "warning");
                    inputField.focus();
                    return;
                }

                const remarksVal = remarksField.value.trim();
                if (remarksVal === "") {
                    showToast("Please enter remarks explaining the override.", "warning");
                    remarksField.focus();
                    return;
                }

                const req = {
                    year: parseInt(year.value),
                    month: parseInt(month.value),
                    category: catName,
                    empId: id,
                    finalDays: finalDays,
                    remarks: remarksVal
                };

                fetch('Calculation.aspx/SaveOverride', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(req)
                }).then(r => r.json()).then(res => {
                    if (res.d && res.d.includes("error")) {
                        showToast(res.d, "error");
                    } else {
                        closeModal();
                        showToast(`Override saved for ${emp.Name}`, "success");
                        render();
                    }
                }).catch(e => {
                    console.error(e);
                    showToast("Error saving override: " + e.message, "error");
                });
            };
        }

        function exportFull() {
            if (calcData.length === 0) return showToast("No data available to export.", "info");
            const data = calcData.map(e => ({
                ID: e.ID, MasterID: e.MasterId, Name: e.Name, Department: e.Department,
                Category: e.Category,
                Present: e.Present, FinalDays: e.Final, Remarks: e.Remarks, Amount: e.Amount
            }));
            const ws = XLSX.utils.json_to_sheet(data);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Full Report");
            XLSX.writeFile(wb, "Full_Report.xlsx");
        }
    </script>
</asp:Content>
