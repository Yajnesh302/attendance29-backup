<%@ Page Title="Employee Master" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Employee.aspx.cs" Inherits="AttendanceApp.Employee" EnableEventValidation="false" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
        Employee Master
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            .panel {
                background: white;
                padding: 20px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                margin-bottom: 20px;
                border: 1px solid #f1f5f9;
            }

            /* Modern Table Styling */
            .table-custom {
                border-collapse: separate !important;
                border-spacing: 0 !important;
                width: 100% !important;
                border: 1px solid #e2e8f0 !important;
                /* Outer table border */
                border-radius: 12px !important;
                overflow: hidden !important;
            }

            .table-custom th {
                background-color: #f8fafc !important;
                /* Soft slate gray */
                color: #475569 !important;
                /* Slate color */
                font-size: 0.8rem !important;
                text-transform: uppercase !important;
                letter-spacing: 0.06em !important;
                font-weight: 700 !important;
                padding: 14px 20px !important;
                border-top: none !important;
                border-bottom: 2px solid #e2e8f0 !important;
                border-left: none !important;
                border-right: 1px solid #e2e8f0 !important;
                /* Clean vertical line in header */
                vertical-align: middle !important;
            }

            .table-custom th:last-child {
                border-right: none !important;
            }

            .table-custom th.sortable-header {
                transition: background-color 0.2s ease, color 0.2s ease !important;
            }

            .table-custom th.sortable-header:hover {
                background-color: #cbd5e1 !important;
                color: #0f172a !important;
            }

            html.theme-dark .table-custom th.sortable-header:hover {
                background-color: #2d3348 !important;
                color: #cbd5e1 !important;
            }

            .table-custom td {
                padding: 14px 20px !important;
                color: #334155 !important;
                /* Charcoal slate */
                font-size: 0.92rem !important;
                font-weight: 500 !important;
                border-bottom: 1px solid #e2e8f0 !important;
                /* Horizontal separating lines */
                border-left: none !important;
                border-right: 1px solid #f1f5f9 !important;
                /* Soft vertical separating lines */
                vertical-align: middle !important;
            }

            .table-custom td:last-child {
                border-right: none !important;
            }

            .table-custom tr:last-child td {
                border-bottom: none !important;
                /* Remove bottom border on the last row */
            }

            .table-custom tr {
                transition: background-color 0.2s ease;
            }

            .table-custom tr:hover {
                background-color: #eef2ff !important;
                /* Distinct light indigo hover */
            }

            .table-custom tr:nth-child(even) {
                background-color: #fbfcfd;
            }

            /* Modern Pill Badge for Dropdown */
            .status-badge {
                border-radius: 50px !important;
                font-size: 0.78rem !important;
                font-weight: 700 !important;
                padding: 2px 24px 2px 10px !important;
                /* Right padding for custom Bootstrap select arrow */
                width: 110px !important;
                height: 28px !important;
                line-height: 1.2 !important;
                cursor: pointer !important;
                border: 1px solid transparent !important;
                display: inline-block !important;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                transition: all 0.15s ease;
            }

            /* Status Color Accents */
            select.status-badge.badge-active {
                background-color: #ecfdf5 !important;
                /* Light green */
                color: #047857 !important;
                /* Dark green */
                border-color: #a7f3d0 !important;
            }

            select.status-badge.badge-active:focus {
                box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
                border-color: #34d399 !important;
            }

            select.status-badge.badge-resigned {
                background-color: #fef2f2 !important;
                /* Light red */
                color: #b91c1c !important;
                /* Dark red */
                border-color: #fecaca !important;
            }

            select.status-badge.badge-resigned:focus {
                box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15) !important;
                border-color: #f87171 !important;
            }

            select.status-badge.badge-upgraded {
                background-color: #e0f2fe !important;
                /* Light blue */
                color: #0369a1 !important;
                /* Dark blue */
                border-color: #bae6fd !important;
            }

            select.status-badge.badge-upgraded:focus {
                box-shadow: 0 0 0 3px rgba(3, 105, 161, 0.15) !important;
                border-color: #38bdf8 !important;
            }

            select.status-badge.badge-downgraded {
                background-color: #fffbeb !important;
                /* Light amber */
                color: #b45309 !important;
                /* Dark amber */
                border-color: #fde68a !important;
            }

            select.status-badge.badge-downgraded:focus {
                box-shadow: 0 0 0 3px rgba(180, 83, 9, 0.15) !important;
                border-color: #fbbf24 !important;
            }

            select.status-badge.badge-contractended {
                background-color: #f1f5f9 !important;
                /* Light slate */
                color: #475569 !important;
                /* Slate color */
                border-color: #cbd5e1 !important;
            }

            select.status-badge.badge-contractended:focus {
                box-shadow: 0 0 0 3px rgba(71, 85, 105, 0.15) !important;
                border-color: #94a3b8 !important;
            }

            select.status-badge.badge-transferred {
                background-color: #faf5ff !important;
                /* Light purple */
                color: #6b21a8 !important;
                /* Dark purple */
                border-color: #e9d5ff !important;
            }

            select.status-badge.badge-transferred:focus {
                box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.15) !important;
                border-color: #c084fc !important;
            }

            /* Resigned Row Muted Effect (Selective strike-through) */
            .resigned-row {
                background-color: #fbfcfd !important;
                opacity: 0.8;
            }

            .resigned-row td {
                color: #94a3b8 !important;
                /* Muted gray text */
            }

            .resigned-row td:nth-child(2),
            /* ID */
            .resigned-row td:nth-child(3),
            /* Name */
            .resigned-row td:nth-child(4),
            /* Department */
            .resigned-row td:nth-child(5),
            /* Category */
            .resigned-row td:nth-child(6),
            /* Join Date */
            .resigned-row td:nth-child(7)

            /* Leave Balance */
                {
                text-decoration: line-through !important;
                text-decoration-color: #cbd5e1 !important;
            }

            /* Modern Buttons in Table */
            .table-custom .btn-outline-primary {
                border-color: #e2e8f0;
                color: #4f46e5;
                background-color: #f8fafc;
                border-radius: 6px;
                font-weight: 600;
                padding: 5px 12px;
                font-size: 0.8rem;
                transition: all 0.2s ease;
            }

            .table-custom .btn-outline-primary:hover {
                background-color: #4f46e5;
                border-color: #4f46e5;
                color: white;
                transform: translateY(-1.5px);
                box-shadow: 0 4px 10px rgba(79, 70, 229, 0.15);
            }

            .table-custom .btn-outline-danger {
                border-color: #e2e8f0;
                color: #dc2626;
                background-color: #f8fafc;
                border-radius: 6px;
                font-weight: 600;
                padding: 5px 12px;
                font-size: 0.8rem;
                transition: all 0.2s ease;
            }

            .table-custom .btn-outline-danger:hover {
                background-color: #dc2626;
                border-color: #dc2626;
                color: white;
                transform: translateY(-1.5px);
                box-shadow: 0 4px 10px rgba(220, 38, 38, 0.15);
            }

            .table-custom .btn-outline-info {
                border-color: #e2e8f0;
                color: #0ea5e9;
                background-color: #f8fafc;
                border-radius: 6px;
                font-weight: 600;
                padding: 5px 12px;
                font-size: 0.8rem;
                transition: all 0.2s ease;
            }

            .table-custom .btn-outline-info:hover {
                background-color: #0ea5e9;
                border-color: #0ea5e9;
                color: white;
                transform: translateY(-1.5px);
                box-shadow: 0 4px 10px rgba(14, 165, 233, 0.15);
            }

            .animate-hover {
                transition: all 0.2s ease;
            }

            .animate-hover:hover {
                transform: translateY(-1.5px);
                box-shadow: 0 4px 12px rgba(79, 70, 229, 0.2) !important;
            }


            /* Custom Tabs Styling */
            .nav-tabs .nav-link {
                border: 1px solid transparent;
                color: #64748b !important;
                /* Muted slate */
                font-size: 0.9rem;
                transition: all 0.2s ease;
                padding: 10px 20px;
            }

            .nav-tabs .nav-link:hover {
                color: #4f46e5 !important;
                /* Brand color */
                border-color: #f1f5f9 #f1f5f9 transparent;
                background-color: #fafbfc;
            }

            .nav-tabs .nav-link.active {
                border-color: #e2e8f0 #e2e8f0 #fff !important;
                /* Match table border */
                background-color: #fff !important;
                color: #4f46e5 !important;
                font-weight: 700 !important;
                box-shadow: 0 -2px 6px rgba(0, 0, 0, 0.02);
            }

            /* Modal Custom styles */
            .modal-content {
                border-radius: 14px;
                border: none;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            }

            .modal-header {
                border-top-left-radius: 14px;
                border-top-right-radius: 14px;
                background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%);
            }

            /* Fix Bootstrap modal backdrop z-index bug */
            .modal {
                background: rgba(0, 0, 0, 0.55);
            }

            .modal-backdrop {
                display: none !important;
            }

            /* ── Employee History Timeline ── */
            .history-modal .modal-dialog {
                max-width: 680px;
            }

            .emp-header-card {
                background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
                border-radius: 12px;
                padding: 18px 20px;
                color: #fff;
                margin-bottom: 20px;
            }

            .emp-header-card .emp-name {
                font-size: 1.25rem;
                font-weight: 700;
                letter-spacing: -0.01em;
            }

            .emp-header-card .emp-meta {
                font-size: 0.82rem;
                opacity: 0.85;
                margin-top: 4px;
            }

            .emp-header-card .status-pill {
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
                background: linear-gradient(to bottom, #c7d2fe, #e0e7ff);
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

            .dot-join {
                background: #10b981;
                color: #fff;
            }

            .dot-continue {
                background: #4f46e5;
                color: #fff;
            }

            .dot-upgrade {
                background: #0ea5e9;
                color: #fff;
            }

            .dot-downgrade {
                background: #f59e0b;
                color: #fff;
            }

            .dot-end {
                background: #ef4444;
                color: #fff;
            }

            .dot-active {
                background: #22c55e;
                color: #fff;
            }

            .dot-transfer {
                background: #8b5cf6;
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

            .tl-event-label.ev-join {
                background-color: #ecfdf5;
                border-color: #a7f3d0;
                color: #065f46;
            }

            .tl-event-label.ev-continue {
                background-color: #e0e7ff;
                border-color: #c7d2fe;
                color: #3730a3;
            }

            .tl-event-label.ev-upgrade {
                background-color: #f0f9ff;
                border-color: #bae6fd;
                color: #075985;
            }

            .tl-event-label.ev-downgrade {
                background-color: #fffbeb;
                border-color: #fde68a;
                color: #92400e;
            }

            .tl-event-label.ev-end {
                background-color: #fef2f2;
                border-color: #fecaca;
                color: #991b1b;
            }

            .tl-event-label.ev-active {
                background-color: #f0fdf4;
                border-color: #bbf7d0;
                color: #166534;
            }

            .tl-event-label.ev-transfer {
                background-color: #faf5ff;
                border-color: #e9d5ff;
                color: #6b21a8;
            }

            .tl-event-label.ev-current-downgrade {
                background-color: #fffbeb;
                border-color: #fde68a;
                color: #92400e;
            }

            .tl-event-label.ev-current-upgrade {
                background-color: #f0f9ff;
                border-color: #bae6fd;
                color: #075985;
            }

            .tl-event-label.ev-current-transfer {
                background-color: #faf5ff;
                border-color: #e9d5ff;
                color: #6b21a8;
            }

            .tl-event-label.ev-no-contract {
                background-color: #fef2f2;
                border-color: #fecaca;
                color: #991b1b;
            }

            .tl-contract-chip.chip-no-contract {
                background: #fef2f2;
                color: #b91c1c;
                border: 1px solid #fecaca;
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

            #historyModal .modal-body {
                max-height: 70vh;
                overflow-y: auto;
            }

            /* Premium custom select dropdown styling */
            .select-custom {
                display: inline-block;
                width: auto;
                height: calc(1.5em + .75rem + 2px);
                padding: .375rem 2rem .375rem .75rem;
                font-size: .9rem;
                font-weight: 600;
                line-height: 1.5;
                color: #475569;
                background-color: #fff;
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%234f46e5' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
                background-repeat: no-repeat;
                background-position: right .75rem center;
                background-size: 16px 12px;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
                transition: border-color .15s ease-in-out, background-color .15s ease-in-out, box-shadow .15s ease-in-out;
                -webkit-appearance: none;
                -moz-appearance: none;
                appearance: none;
                cursor: pointer;
            }

            .select-custom:focus {
                border-color: #6366f1;
                outline: 0;
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
            }

            .select-custom:hover {
                border-color: #94a3b8;
                background-color: #f8fafc;
            }

            /* Premium custom input styling */
            .input-custom {
                height: calc(1.5em + .75rem + 2px);
                padding: .375rem .75rem;
                font-size: .9rem;
                font-weight: 500;
                color: #1e293b;
                background-color: #fff;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
                transition: border-color .15s ease-in-out, box-shadow .15s ease-in-out;
            }

            .input-custom:focus {
                border-color: #6366f1;
                outline: 0;
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
            }

            .input-custom::placeholder {
                color: #94a3b8;
            }

            /* Premium redesigned Employee Modal layout */
            .modal-content-custom {
                border-radius: 16px !important;
                overflow: hidden !important;
                border: none !important;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25) !important;
            }

            .modal-header-custom {
                background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%) !important;
                padding: 18px 24px !important;
                border-bottom: none !important;
            }

            .modal-footer-custom {
                background-color: #f8fafc !important;
                border-top: 1px solid #f1f5f9 !important;
                padding: 16px 24px !important;
            }

            .form-label-custom {
                font-size: 0.72rem !important;
                font-weight: 700 !important;
                color: #475569 !important;
                margin-bottom: 6px !important;
                display: inline-block !important;
                text-transform: uppercase !important;
                letter-spacing: 0.05em !important;
            }

            .form-input-custom {
                border-radius: 8px !important;
                border: 1px solid #cbd5e1 !important;
                padding: 0.50rem 0.75rem !important;
                font-size: 0.9rem !important;
                font-weight: 500 !important;
                color: #1e293b !important;
                background-color: #fff !important;
                box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05) !important;
                transition: all 0.2s ease-in-out !important;
                height: auto !important;
            }

            .form-input-custom:focus {
                border-color: #6366f1 !important;
                outline: 0 !important;
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15) !important;
            }

            .form-input-custom:disabled,
            .form-input-custom[disabled] {
                background-color: #f1f5f9 !important;
                color: #64748b !important;
                border-color: #cbd5e1 !important;
                cursor: not-allowed !important;
                box-shadow: none !important;
            }

            /* ── End Timeline ── */

            /* Premium Action Toolbar Buttons */
            .btn-action-custom {
                font-size: 0.88rem !important;
                font-weight: 600 !important;
                padding: 10px 18px !important;
                border-radius: 10px !important;
                border: none !important;
                display: inline-flex !important;
                align-items: center !important;
                justify-content: center !important;
                gap: 8px !important;
                cursor: pointer !important;
                transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03) !important;
                color: #fff !important;
                text-decoration: none !important;
            }

            .btn-action-custom:hover {
                transform: translateY(-2px) !important;
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
                filter: brightness(1.08) !important;
            }

            .btn-action-custom:active {
                transform: translateY(0) !important;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05) !important;
            }

            /* Specific Button Gradients */
            .btn-action-add {
                background: linear-gradient(135deg, #4f46e5 0%, #3b82f6 100%) !important;
                /* Indigo to Blue */
            }

            .btn-action-bulk-leave {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
                /* Emerald */
            }

            .btn-action-delete {
                background: linear-gradient(135deg, #f43f5e 0%, #e11d48 100%) !important;
                /* Rose */
            }

            .btn-action-import {
                background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%) !important;
                /* Purple/Violet */
            }

            /* Custom modal and panel classes for clean theme toggling */
            .emp-id-box-custom {
                background-color: #f8fafc !important;
                border-color: #e2e8f0 !important;
            }

            .rejoin-box-custom {
                background-color: #fff !important;
                border-color: #e2e8f0 !important;
            }

            .modal-card-custom {
                background-color: #fff !important;
                border: 1px solid #e2e8f0 !important;
            }

            .modal-card-header-custom {
                background-color: #fafbfc !important;
                border-bottom: 1px solid #e2e8f0 !important;
            }

            .adv-filters-panel-custom {
                background-color: #f5f3ff !important;
                border: 1.5px solid #c4b5fd !important;
            }

            .adv-filters-card-custom {
                background-color: #fff !important;
                border: 1px solid #e2e8f0 !important;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0 text-dark font-weight-bold">Employee Master</h2>
            <div>
                <button type="button" class="btn btn-action-custom btn-action-add mr-2" data-bs-toggle="modal"
                    data-bs-target="#employeeModal" onclick="clearForm();">
                    <i class="fas fa-user-plus"></i> Add Employee
                </button>
                <button type="button" class="btn btn-action-custom btn-action-bulk-leave mr-2" data-bs-toggle="modal"
                    data-bs-target="#bulkLeaveModal" onclick="clearBulkLeaveForm();">
                    <i class="fas fa-plus-circle"></i> Bulk Add Leave
                </button>
                <button type="button" class="btn btn-action-custom btn-action-import" data-bs-toggle="modal"
                    data-bs-target="#importModal">
                    <i class="fas fa-file-import"></i> Import CSV
                </button>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-block d-none" Visible="false"></asp:Label>

        <!-- MAIN FILTER TOOLBAR -->
        <div class="panel mb-3 d-flex align-items-center justify-content-between flex-wrap"
            style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px 20px;">
            <div class="d-flex align-items-center mb-2 mb-md-0 flex-wrap">
                <div class="d-flex align-items-center mr-4 mb-2 mb-md-0">
                    <i class="fas fa-filter text-primary mr-2"
                        style="font-size: 0.9rem; color: #4f46e5 !important;"></i>
                    <span class="mr-2 text-dark font-weight-bold"
                        style="font-size: 0.9rem; color: #475569 !important;">Category:</span>
                    <asp:DropDownList ID="ddlFilter" runat="server" CssClass="select-custom shadow-sm"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>

                <div class="d-flex align-items-center mr-4 mb-2 mb-md-0">
                    <i class="fas fa-layer-group text-primary mr-2"
                        style="font-size: 0.9rem; color: #4f46e5 !important;"></i>
                    <span class="mr-2 text-dark font-weight-bold"
                        style="font-size: 0.9rem; color: #475569 !important;">Directorate:</span>
                    <asp:DropDownList ID="ddlFilterDiv" runat="server" CssClass="select-custom shadow-sm"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlFilterDiv_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>

                <div class="d-flex align-items-center mb-2 mb-md-0">
                    <i class="fas fa-info-circle text-primary mr-2"
                        style="font-size: 0.9rem; color: #4f46e5 !important;"></i>
                    <span class="mr-2 text-dark font-weight-bold"
                        style="font-size: 0.9rem; color: #475569 !important;">Status:</span>
                    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="select-custom shadow-sm"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged">
                        <asp:ListItem Value="All">All</asp:ListItem>
                        <asp:ListItem Value="Active">Active</asp:ListItem>
                        <asp:ListItem Value="ContractEnded">Contract Ended</asp:ListItem>
                        <asp:ListItem Value="Resigned">Resigned</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="d-flex align-items-center" style="gap:8px;">
                <div class="input-group" style="width: auto; display: flex; align-items: center;">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control input-custom mr-2 shadow-sm"
                        placeholder="Search ID or name..." onkeyup="filterEmployees()" style="width: 220px;">
                    </asp:TextBox>
                    <asp:LinkButton ID="btnSearch" runat="server"
                        CssClass="btn btn-primary shadow-sm animate-hover d-flex align-items-center"
                        OnClick="btnSearch_Click"
                        style="border-radius: 8px; font-weight: 700; background-color: #4f46e5; border-color: #4f46e5; height: calc(1.5em + .75rem + 2px);">
                        <i class="fas fa-search mr-1"></i> Search
                    </asp:LinkButton>
                </div>
                <button type="button" id="btnToggleAdvFilter" onclick="toggleAdvancedFilters()"
                    style="border-radius:8px; font-weight:600; padding:7px 14px; font-size:0.85rem; border:1.5px solid #a5b4fc; background:#f5f3ff; color:#4f46e5; cursor:pointer; display:inline-flex; align-items:center; gap:6px; transition:all 0.2s; white-space:nowrap;">
                    <i class="fas fa-sliders-h"></i> Advanced Filters
                    <span id="advFilterBadge"
                        style="display:none; background:#4f46e5; color:#fff; border-radius:50%; width:18px; height:18px; font-size:0.7rem; font-weight:700; align-items:center; justify-content:center;">0</span>
                </button>
            </div>
        </div>

        <!-- ADVANCED FILTERS PANEL -->
        <div id="advancedFiltersPanel" class="adv-filters-panel-custom"
            style="display:none; border-radius:12px; padding:18px 20px; margin-bottom:12px;">
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:14px;">
                <div style="font-weight:700; color:#4f46e5; font-size:0.92rem;"><i
                        class="fas fa-sliders-h mr-2"></i>Advanced Filters</div>
                <div style="display:flex; gap:8px;">
                    <button type="button" onclick="applyAdvancedFilters()"
                        style="background:#4f46e5; color:#fff; border:none; border-radius:7px; padding:5px 16px; font-weight:600; font-size:0.83rem; cursor:pointer;"><i
                            class="fas fa-check mr-1"></i>Apply</button>
                    <button type="button" onclick="clearAdvancedFilters()"
                        style="background:#fff; color:#64748b; border:1.5px solid #e2e8f0; border-radius:7px; padding:5px 14px; font-weight:600; font-size:0.83rem; cursor:pointer;"><i
                            class="fas fa-times mr-1"></i>Clear</button>
                </div>
            </div>
            <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(220px, 1fr)); gap:16px;">

                <!-- Join Date Filter -->
                <div class="adv-filters-card-custom" style="border-radius:10px; padding:14px;">
                    <div style="font-weight:700; font-size:0.82rem; color:#334155; margin-bottom:10px;"><i
                            class="fas fa-calendar-alt mr-1" style="color:#4f46e5;"></i> Join Date</div>
                    <select id="advJoinMode" onchange="toggleJoinDateInputs(); applyAdvancedFilters();"
                        style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:5px 8px; font-size:0.82rem; color:#334155; margin-bottom:8px; background:#f8fafc;">
                        <option value="">-- No Filter --</option>
                        <option value="before">Before</option>
                        <option value="after">After</option>
                        <option value="between">Between</option>
                        <option value="exact">On Exact Date</option>
                    </select>
                    <div id="advJoinDate1Wrap" style="display:none; margin-bottom:6px;">
                        <label style="font-size:0.75rem; color:#64748b; font-weight:600;">Date</label>
                        <input type="date" id="advJoinDate1" onchange="applyAdvancedFilters()"
                            style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:5px 8px; font-size:0.82rem; color:#334155;">
                    </div>
                    <div id="advJoinDate2Wrap" style="display:none;">
                        <label style="font-size:0.75rem; color:#64748b; font-weight:600;">To Date</label>
                        <input type="date" id="advJoinDate2" onchange="applyAdvancedFilters()"
                            style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:5px 8px; font-size:0.82rem; color:#334155;">
                    </div>
                </div>

                <!-- Experience Filter -->
                <div class="adv-filters-card-custom" style="border-radius:10px; padding:14px;">
                    <div style="font-weight:700; font-size:0.82rem; color:#334155; margin-bottom:10px;"><i
                            class="fas fa-briefcase mr-1" style="color:#4f46e5;"></i> Experience (Years)</div>
                    <select id="advExpMode" onchange="toggleExpInputs(); applyAdvancedFilters();"
                        style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:5px 8px; font-size:0.82rem; color:#334155; margin-bottom:8px; background:#f8fafc;">
                        <option value="">-- No Filter --</option>
                        <option value="lt">Less than</option>
                        <option value="gt">Greater than</option>
                        <option value="between">Between</option>
                        <option value="exact">Exactly</option>
                    </select>
                    <div id="advExpVal1Wrap" style="display:none; margin-bottom:6px;">
                        <label id="advExpVal1Label"
                            style="font-size:0.75rem; color:#64748b; font-weight:600;">Years</label>
                        <input type="number" id="advExpVal1" oninput="applyAdvancedFilters()" min="0" max="60"
                            step="0.5"
                            style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:5px 8px; font-size:0.82rem; color:#334155;"
                            placeholder="e.g. 3">
                    </div>
                    <div id="advExpVal2Wrap" style="display:none;">
                        <label style="font-size:0.75rem; color:#64748b; font-weight:600;">To (Years)</label>
                        <input type="number" id="advExpVal2" oninput="applyAdvancedFilters()" min="0" max="60"
                            step="0.5"
                            style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:5px 8px; font-size:0.82rem; color:#334155;"
                            placeholder="e.g. 10">
                    </div>
                </div>

                <!-- Qualification Filter -->
                <div class="adv-filters-card-custom" style="border-radius:10px; padding:14px;">
                    <div style="font-weight:700; font-size:0.82rem; color:#334155; margin-bottom:10px;"><i
                            class="fas fa-graduation-cap mr-1" style="color:#4f46e5;"></i> Qualification</div>
                    <input type="text" id="advQualText" placeholder="e.g. B.Tech, MBA, Diploma..."
                        oninput="applyAdvancedFilters()"
                        style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:6px 10px; font-size:0.82rem; color:#334155; margin-bottom:8px;">
                    <div style="font-size:0.75rem; color:#94a3b8;">Searches within employee's qualification description.
                        Separate multiple keywords with commas.</div>
                </div>

                <!-- Experience In Filter -->
                <div class="adv-filters-card-custom" style="border-radius:10px; padding:14px;">
                    <div style="font-weight:700; font-size:0.82rem; color:#334155; margin-bottom:10px;"><i
                            class="fas fa-tasks mr-1" style="color:#4f46e5;"></i> Experience In (keyword)</div>
                    <input type="text" id="advExpInText" placeholder="e.g. welding, manager, civil..."
                        oninput="applyAdvancedFilters()"
                        style="width:100%; border-radius:6px; border:1px solid #cbd5e1; padding:6px 10px; font-size:0.82rem; color:#334155; margin-bottom:8px;">
                    <div style="font-size:0.75rem; color:#94a3b8;">Searches within employee's experience description.
                        Separate multiple keywords with commas.</div>
                </div>

            </div>

            <!-- Active filter summary chips -->
            <div id="advFilterChips" style="display:none; margin-top:12px; display:flex; flex-wrap:wrap; gap:6px;">
            </div>
        </div>

        <!-- TABS NAVIGATION -->
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="Active" />
        <asp:HiddenField ID="hfHiddenEditMasterId" runat="server" ClientIDMode="Static" />
        <asp:LinkButton ID="btnHiddenEditTrigger" runat="server" OnClick="btnHiddenEditTrigger_Click"
            style="display:none;" />
        <asp:HiddenField ID="hfChangeCategory" runat="server" Value="" />
        <asp:HiddenField ID="hfChangeDate" runat="server" Value="" />
        <asp:HiddenField ID="hfChangeEmpId" runat="server" Value="" />
        <asp:HiddenField ID="hfChangeDivision" runat="server" Value="" />
        <ul class="nav nav-tabs mb-0 border-bottom-0" id="employeeTabs" role="tablist" style="padding-left: 4px;">
            <li class="nav-item">
                <asp:LinkButton ID="btnTabActive" runat="server" CssClass="nav-link active" OnClick="btnTabActive_Click"
                    style="font-weight: 600; border-radius: 8px 8px 0 0; margin-right: 4px;">
                    Active <span class="badge bg-success text-white ml-1" style="font-size: 0.75rem; padding: 3px 8px;">
                        <%= GetActiveCount() %>
                    </span>
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnTabResigned" runat="server" CssClass="nav-link" OnClick="btnTabResigned_Click"
                    style="font-weight: 600; border-radius: 8px 8px 0 0; margin-right: 4px;">
                    Resigned <span class="badge bg-secondary text-white ml-1"
                        style="font-size: 0.75rem; padding: 3px 8px;">
                        <%= GetResignedCount() %>
                    </span>
                </asp:LinkButton>
            </li>
        </ul>

        <div class="table-responsive bg-white rounded-lg shadow-sm border"
            style="border-radius: 12px; overflow: hidden; border-top-left-radius: 0px !important;">
            <asp:GridView ID="gvEmployees" runat="server" AutoGenerateColumns="False"
                CssClass="table table-hover table-custom mb-0" DataKeyNames="MasterId"
                OnRowCommand="gvEmployees_RowCommand" OnRowDataBound="gvEmployees_RowDataBound"
                OnRowDeleting="gvEmployees_RowDeleting">
                <Columns>
                    <asp:TemplateField HeaderText="S.No">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="MasterId" HeaderText="Master ID" />
                    <asp:BoundField DataField="ID" HeaderText="ID" />
                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkName" runat="server" CommandName="ViewHistory"
                                CommandArgument='<%# Eval("MasterId") %>' CssClass="emp-name-link"
                                style="color:#4f46e5;font-weight:700;text-decoration:none;border-bottom:1px dashed #a5b4fc;cursor:pointer;"
                                title="Click to view full history">
                                <%# Eval("Name") %>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Department" HeaderText="Directorate" />
                    <asp:BoundField DataField="Category" HeaderText="Category" />
                    <asp:BoundField DataField="JoinDate" HeaderText="Join Date" DataFormatString="{0:dd-MM-yyyy}" />
                    <asp:BoundField DataField="LeaveBalance" HeaderText="Leave" />
                    <asp:BoundField DataField="PrevLeaveBalance" HeaderText="Prev Leave" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <asp:DropDownList ID="ddlStatus" runat="server"
                                CssClass="form-select form-select-sm status-badge" onchange="handleStatusChange(this)"
                                OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                                <asp:ListItem Value="Active">Active</asp:ListItem>
                                <asp:ListItem Value="Resigned">Resigned</asp:ListItem>
                                <asp:ListItem Value="Transferred">Transferred</asp:ListItem>
                                <asp:ListItem Value="ContractEnded">Contract Ended</asp:ListItem>
                            </asp:DropDownList>
                            <asp:HiddenField ID="hfEmpID" runat="server" Value='<%# Eval("MasterId") %>' />
                            <asp:HiddenField ID="hfStatus" runat="server" Value='<%# Eval("Status") %>' />
                            <asp:HiddenField ID="hfResignDate" runat="server" Value="" />
                            <asp:HiddenField ID="hfEngStartDate" runat="server"
                                Value='<%# Eval("CurrentEngStartDate", "{0:yyyy-MM-dd}") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>


                </Columns>
            </asp:GridView>
        </div>

        <!-- BULK ADD LEAVE MODAL -->
        <div class="modal fade" id="bulkLeaveModal" tabindex="-1" role="dialog" aria-labelledby="bulkLeaveModalLabel"
            aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content"
                    style="border-radius: 16px; border: none; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 18px 24px;">
                        <h5 class="modal-title font-weight-bold" id="bulkLeaveModalLabel"><i
                                class="fas fa-plus-circle mr-2"></i> Bulk Add Leave Balance</h5>
                        <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close"
                            style="opacity: 0.8; outline: none; background: transparent; border: none;">
                            <span aria-hidden="true" style="font-size: 1.5rem;">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark" style="padding: 24px;">
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Category
                                *</label>
                            <asp:DropDownList ID="ddlBulkLeaveCategory" runat="server"
                                CssClass="form-control select-custom w-100" style="font-weight: 600;">
                            </asp:DropDownList>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Directorate
                                *</label>
                            <asp:DropDownList ID="ddlBulkLeaveDivision" runat="server"
                                CssClass="form-control select-custom w-100" style="font-weight: 600;">
                            </asp:DropDownList>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Leave Days
                                to Add *</label>
                            <asp:TextBox ID="txtBulkLeaveAmount" runat="server"
                                CssClass="form-control form-input-custom"
                                placeholder="e.g. 1.5 (Use negative to subtract)" type="number" step="0.5" min="-30"
                                max="30" style="font-weight: 600;"></asp:TextBox>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Effective
                                Date *</label>
                            <asp:TextBox ID="txtBulkLeaveDate" runat="server" CssClass="form-control form-input-custom"
                                type="date" style="font-weight: 600;"></asp:TextBox>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Remarks /
                                Note *</label>
                            <asp:TextBox ID="txtBulkLeaveRemarks" runat="server"
                                CssClass="form-control form-input-custom" placeholder="e.g. Monthly leave credit"
                                MaxLength="200" style="font-weight: 600;"></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer"
                        style="padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; width: 100%;">
                        <div>
                            <asp:Button ID="btnResetBulkLeave" runat="server" Text="Reset Balance to 0"
                                CssClass="btn btn-danger font-weight-bold" OnClick="btnResetBulkLeave_Click"
                                OnClientClick="return confirmResetBulkLeave(this.name);"
                                style="border-radius: 8px; font-size: 0.9rem; padding: 8px 16px; background-color: #ef4444; border-color: #ef4444;" />
                        </div>
                        <div>
                            <button type="button" class="btn btn-secondary font-weight-bold mr-2"
                                data-bs-dismiss="modal"
                                style="border-radius: 8px; font-size: 0.9rem; padding: 8px 16px;">Cancel</button>
                            <asp:Button ID="btnSubmitBulkLeave" runat="server" Text="Apply Leave Credit"
                                CssClass="btn btn-success font-weight-bold" OnClick="btnSubmitBulkLeave_Click"
                                OnClientClick="return validateBulkLeave();"
                                style="border-radius: 8px; font-size: 0.9rem; padding: 8px 16px; background-color: #10b981; border-color: #10b981;" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- EMPLOYEE MODAL -->
        <div class="modal fade" id="employeeModal" tabindex="-1" role="dialog" aria-labelledby="employeeModalLabel"
            aria-hidden="true">
            <div class="modal-dialog modal-lg" id="employeeModalDialog" role="document"
                style="transition: max-width 0.3s ease-in-out;">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header modal-header-custom text-white">
                        <h5 class="modal-title font-weight-bold" id="employeeModalLabel">Add New Employee</h5>
                        <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close"
                            style="opacity: 0.8; outline: none; background: transparent; border: none;">
                            <span aria-hidden="true" style="font-size: 1.5rem;">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark" style="max-height: 75vh; overflow-y: auto; padding: 24px;">
                        <div class="row" id="employeeModalRow">
                            <!-- Left Form Column -->
                            <div class="col-12" id="employeeFormCol">
                                <!-- Top System Identity Strip -->
                                <div class="row mb-4">
                                    <div class="col-md-6 mb-3 mb-md-0">
                                        <div class="p-3 rounded-lg border d-flex align-items-center emp-id-box-custom"
                                            style="height: 100%; border-radius: 12px;">
                                            <div class="bg-indigo-light text-indigo rounded-circle d-flex align-items-center justify-content-center mr-3"
                                                style="width: 42px; height: 42px; background-color: #e0e7ff; color: #4f46e5; flex-shrink: 0; border-radius: 50%;">
                                                <i class="fas fa-id-badge" style="font-size: 1.25rem;"></i>
                                            </div>
                                            <div>
                                                <div class="text-muted small uppercase font-weight-bold"
                                                    style="letter-spacing: 0.05em; font-size: 0.7rem; line-height: 1.2;">
                                                    Employee Master ID</div>
                                                <div class="font-weight-bold text-dark"
                                                    style="font-size: 1.15rem; font-family: monospace;">
                                                    <span id="displayMasterID">
                                                        <%= string.IsNullOrEmpty(txtMasterID.Text) ? "(Auto-Generated)"
                                                            : txtMasterID.Text %>
                                                    </span>
                                                </div>
                                            </div>
                                            <asp:TextBox ID="txtMasterID" runat="server" style="display: none;">
                                            </asp:TextBox>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="p-3 rounded-lg border d-flex align-items-center rejoin-box-custom"
                                            style="height: 100%; border-radius: 12px; justify-content: flex-start;">
                                            <asp:CheckBox ID="chkIsRejoining" runat="server"
                                                onclick="toggleRejoiningSelection();"
                                                style="transform: scale(1.2); margin-right: 10px; cursor: pointer;"
                                                ClientIDMode="Static" />
                                            <label class="form-check-label font-weight-bold text-primary mb-0"
                                                for="chkIsRejoining"
                                                style="cursor: pointer; font-size: 0.88rem; user-select: none;">
                                                Is Rejoining Employee?
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <!-- Link Resigned Selection (Hidden by default) -->
                                <div id="divRejoiningSelect" class="form-group mb-4"
                                    style="display: none; position: relative; background-color: #eff6ff; border: 1px dashed #bfdbfe; border-radius: 12px; padding: 16px;">
                                    <label class="font-weight-bold text-primary mb-2" style="font-size: 0.85rem;"><i
                                            class="fas fa-link mr-1"></i> Select Resigned Employee to Link</label>
                                    <div class="dropdown" id="rejoinDropdownContainer" style="position: relative;">
                                        <button type="button"
                                            class="form-select form-control text-left d-flex justify-content-between align-items-center form-input-custom"
                                            id="btnRejoinDropdown" aria-haspopup="true" aria-expanded="false"
                                            style="font-weight: 600; border-color: #3b82f6; background-color: #fff; text-align: left; width: 100%;">
                                            <span id="rejoinDropdownSelectedText">-- Select Resigned Employee --</span>
                                            <span class="dropdown-caret"
                                                style="border-top: 6px solid #4f46e5; border-left: 4px solid transparent; border-right: 4px solid transparent; display: inline-block; margin-left: 8px;"></span>
                                        </button>
                                        <div class="dropdown-menu p-3 shadow-lg" aria-labelledby="btnRejoinDropdown"
                                            style="width: 100%; max-height: 350px; overflow: hidden; border-radius: 12px; border: 1px solid #cbd5e1; z-index: 1060; position: absolute; top: 100%; left: 0; display: none;">
                                            <div class="form-group mb-2">
                                                <div class="input-group">
                                                    <div class="input-group-prepend" style="display: flex;">
                                                        <span class="input-group-text bg-white border-right-0"
                                                            style="border-radius: 8px 0 0 8px; border-right: none;"><i
                                                                class="fas fa-search text-muted"></i></span>
                                                    </div>
                                                    <input type="text" id="txtRejoinSearchFilter" class="form-control"
                                                        placeholder="Type name or Master ID to filter..."
                                                        oninput="filterRejoinDropdownList();" autocomplete="off"
                                                        style="font-weight: 600; border-radius: 0 8px 8px 0; border-left: 1px solid #ced4da;" />
                                                </div>
                                            </div>
                                            <div id="rejoinDropdownItems"
                                                style="max-height: 220px; overflow-y: auto; margin-top: 8px;">
                                                <!-- Options populated by JavaScript -->
                                            </div>
                                        </div>
                                    </div>
                                    <asp:DropDownList ID="ddlRejoiningEmployee" runat="server" style="display: none;">
                                    </asp:DropDownList>
                                </div>

                                <!-- Employment Info Section Card -->
                                <div class="card shadow-sm border-0 mb-4 modal-card-custom"
                                    style="border-radius: 12px; overflow: hidden;">
                                    <div class="card-header py-3 modal-card-header-custom">
                                        <h6 class="mb-0 text-indigo font-weight-bold"
                                            style="color: #4f46e5; font-size: 0.92rem;">
                                            <i class="fas fa-briefcase mr-2"></i>Employment Info
                                        </h6>
                                    </div>
                                    <div class="card-body p-4">
                                        <div class="row">
                                            <div class="col-md-4 mb-3">
                                                <label for="<%= txtEmpID.ClientID %>" class="form-label-custom">Employee
                                                    ID</label>
                                                <asp:TextBox ID="txtEmpID" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. 1001"></asp:TextBox>
                                            </div>
                                            <div class="col-md-8 mb-3">
                                                <label for="<%= txtEmpName.ClientID %>"
                                                    class="form-label-custom">Employee Name</label>
                                                <asp:TextBox ID="txtEmpName" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. John Doe"></asp:TextBox>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label for="<%= ddlDept.ClientID %>"
                                                    class="form-label-custom">Directorate</label>
                                                <asp:DropDownList ID="ddlDept" runat="server"
                                                    CssClass="form-control form-input-custom w-100">
                                                </asp:DropDownList>
                                                <asp:Label ID="lblDeptHelp" runat="server"
                                                    CssClass="form-text text-muted"
                                                    style="display:none; color: #6c757d; font-size: 0.75rem; margin-top: 4px;"
                                                    Text="Active employee directorate can only be changed via the 'Transferred' option in the Status dropdown.">
                                                </asp:Label>
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label for="<%= ddlCat.ClientID %>"
                                                    class="form-label-custom">Category</label>
                                                <asp:DropDownList ID="ddlCat" runat="server"
                                                    CssClass="form-control form-input-custom w-100">
                                                </asp:DropDownList>
                                                <asp:Label ID="lblCatHelp" runat="server"
                                                    CssClass="form-text text-muted"
                                                    style="display:none; color: #6c757d; font-size: 0.75rem; margin-top: 4px;"
                                                    Text="Active employee category can only be changed via the Status dropdown (e.g. 'Upgraded' or 'Downgraded').">
                                                </asp:Label>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-6 mb-3 mb-md-0">
                                                <label for="<%= txtJoinDate.ClientID %>"
                                                    class="form-label-custom">Joining Date</label>
                                                <asp:TextBox ID="txtJoinDate" runat="server"
                                                    CssClass="form-control form-input-custom w-100" TextMode="Date">
                                                </asp:TextBox>
                                            </div>
                                            <div class="col-md-6 mb-3 mb-md-0">
                                                <label for="<%= txtLeaveBalance.ClientID %>"
                                                    class="form-label-custom">Leave Balance</label>
                                                <asp:TextBox ID="txtLeaveBalance" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="Leave Balance" TextMode="Number"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Contact & Verification Info Section Card -->
                                <div class="card shadow-sm border-0 mb-2 modal-card-custom"
                                    style="border-radius: 12px; overflow: hidden;">
                                    <div class="card-header py-3 modal-card-header-custom">
                                        <h6 class="mb-0 text-indigo font-weight-bold"
                                            style="color: #4f46e5; font-size: 0.92rem;">
                                            <i class="fas fa-id-card mr-2"></i>Contact & Verification Info
                                        </h6>
                                    </div>
                                    <div class="card-body p-4">
                                        <div class="row">
                                            <div class="col-md-4 mb-3">
                                                <label for="<%= txtPhone.ClientID %>" class="form-label-custom">Phone
                                                    Number</label>
                                                <asp:TextBox ID="txtPhone" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. 9876543210" MaxLength="10"
                                                    oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                                </asp:TextBox>
                                            </div>
                                            <div class="col-md-4 mb-3">
                                                <label for="<%= txtEmail.ClientID %>"
                                                    class="form-label-custom">Email</label>
                                                <asp:TextBox ID="txtEmail" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. john@example.com" TextMode="Email"></asp:TextBox>
                                            </div>
                                            <div class="col-md-4 mb-3">
                                                <label for="<%= txtAadhar.ClientID %>" class="form-label-custom">Aadhar
                                                    Number</label>
                                                <asp:TextBox ID="txtAadhar" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. 1234 5678 9012" oninput="onAadharInputChanged();">
                                                </asp:TextBox>
                                                <div id="lblAadharDupError" class="text-danger font-weight-bold mt-1" style="display: none; font-size: 0.82rem;">
                                                    <i class="fas fa-exclamation-circle mr-1"></i>Aadhaar number already registered!
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-12">
                                                <label for="<%= txtAddress.ClientID %>"
                                                    class="form-label-custom">Address</label>
                                                <asp:TextBox ID="txtAddress" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. 123 Main St, City" TextMode="MultiLine" Rows="3">
                                                </asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- PROFESSIONAL DETAILS CARD -->
                                <div class="card shadow-sm mb-3 modal-card-custom"
                                    style="border-radius: 12px; overflow: hidden;">
                                    <div class="card-header"
                                        style="background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); padding: 12px 16px; border-radius: 0;">
                                        <h6 class="mb-0 text-white font-weight-bold" style="font-size: 0.9rem;">
                                            <i class="fas fa-briefcase mr-2"></i>Professional Details
                                        </h6>
                                    </div>
                                    <div class="card-body p-4">
                                        <div class="row">
                                            <div class="col-md-8 mb-3">
                                                <label for="<%= txtQualification.ClientID %>"
                                                    class="form-label-custom">Qualification</label>
                                                <asp:TextBox ID="txtQualification" runat="server"
                                                    CssClass="form-control form-input-custom w-100"
                                                    placeholder="e.g. B.Tech, ITI, Diploma, 10th Pass"></asp:TextBox>
                                            </div>
                                            <div class="col-md-4 mb-3">
                                                <label for="<%= txtExperience.ClientID %>"
                                                    class="form-label-custom">Experience (Years)</label>
                                                <asp:TextBox ID="txtExperience" runat="server"
                                                    CssClass="form-control form-input-custom w-100" placeholder="e.g. 3"
                                                    type="number" min="0" max="60" step="0.5"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-12 mb-3">
                                                <label for="<%= txtExperienceIn.ClientID %>"
                                                    class="form-label-custom">Experience In <small class="text-muted"
                                                        style="font-weight:400; font-size:0.78rem;">(projects, roles,
                                                        work done, etc.)</small></label>
                                                <asp:TextBox ID="txtExperienceIn" runat="server"
                                                    CssClass="form-control form-input-custom w-100" TextMode="MultiLine"
                                                    Rows="5"
                                                    placeholder="e.g.&#10;- Worked as welder at XYZ Company for 2 years&#10;- Handled pipe fitting and civil work at ABC Project&#10;- Operated heavy machinery at DEF site">
                                                </asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Match Side Panel Column (Hidden by Default) -->
                            <div class="col-md-5" id="employeeMatchPanelCol" style="display: none;">
                                <div class="card shadow-sm border-0 h-100"
                                    style="border-radius: 14px; background: #f8fafc; border: 1px solid #cbd5e1; overflow: hidden; animation: fadeInRight 0.3s ease-out;">
                                    <div class="card-header py-3"
                                        style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white;">
                                        <div class="d-flex align-items-center justify-content-between">
                                            <h6 class="mb-0 font-weight-bold" style="font-size: 0.92rem; color: white;">
                                                <i class="fas fa-exclamation-triangle mr-2"></i>Existing Employee Record
                                            </h6>
                                            <span class="badge badge-light"
                                                style="font-size: 0.72rem; color: #dc2626; font-weight: 800;">Aadhaar
                                                Match</span>
                                        </div>
                                    </div>
                                    <div class="card-body p-3" style="font-size: 0.85rem;">
                                        <!-- Profile Card -->
                                        <div class="p-3 mb-3 rounded-lg"
                                            style="background: #ffffff; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border-radius: 10px;">
                                            <div class="d-flex align-items-center mb-2">
                                                <div class="rounded-circle text-white d-flex align-items-center justify-content-center mr-3 font-weight-bold"
                                                    style="width: 44px; height: 44px; background: linear-gradient(135deg, #4f46e5 0%, #3b82f6 100%); font-size: 1.1rem; flex-shrink: 0;"
                                                    id="matchAvatar">
                                                    --
                                                </div>
                                                <div style="flex-grow: 1; overflow: hidden;">
                                                    <h6 class="mb-0 font-weight-bold text-dark text-truncate"
                                                        id="matchEmpName" style="font-size: 1.05rem;">--</h6>
                                                    <div class="d-flex align-items-center mt-1">
                                                        <span class="badge mr-2" id="matchEmpStatusBadge"
                                                            style="font-size: 0.75rem; padding: 4px 8px; border-radius: 6px;">--</span>
                                                        <small class="text-muted font-weight-bold"
                                                            id="matchMasterID">Master ID: --</small>
                                                    </div>
                                                </div>
                                            </div>
                                            <hr style="margin: 10px 0; border-color: #f1f5f9;" />
                                            <div class="row text-muted" style="font-size: 0.82rem;">
                                                <div class="col-6 mb-2">
                                                    <strong class="text-dark d-block">Emp ID</strong>
                                                    <span id="matchEmpID">--</span>
                                                </div>
                                                <div class="col-6 mb-2">
                                                    <strong class="text-dark d-block">Directorate</strong>
                                                    <span id="matchDepartment">--</span>
                                                </div>
                                                <div class="col-6 mb-2">
                                                    <strong class="text-dark d-block">Category</strong>
                                                    <span id="matchCategory">--</span>
                                                </div>
                                                <div class="col-6 mb-2">
                                                    <strong class="text-dark d-block">Phone</strong>
                                                    <span id="matchPhone">--</span>
                                                </div>
                                                <div class="col-6 mb-1">
                                                    <strong class="text-dark d-block">Join Date</strong>
                                                    <span id="matchJoinDate">--</span>
                                                </div>
                                                <div class="col-6 mb-1">
                                                    <strong class="text-dark d-block">Exit Date</strong>
                                                    <span id="matchResignDate"
                                                        class="text-danger font-weight-bold">--</span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Rejoin Action Button (Visible ONLY if Status === Resigned) -->
                                        <div id="matchRejoinActionBox" class="mb-3" style="display: none;">
                                            <button type="button" class="btn btn-primary btn-block shadow-sm"
                                                onclick="triggerRejoinFromMatch();"
                                                style="border-radius: 8px; font-weight: 700; background: linear-gradient(135deg, #4f46e5 0%, #3b82f6 100%); border: none; padding: 10px; width: 100%;">
                                                <i class="fas fa-user-check mr-2"></i>Link & Rejoin This Employee
                                            </button>
                                        </div>
                                        <div id="matchActiveNoticeBox" class="mb-3 p-2 text-center rounded"
                                            style="background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; font-size: 0.8rem; display: none;">
                                            <i class="fas fa-info-circle mr-1"></i> This employee is active or not
                                            resigned. Rejoining is disabled.
                                        </div>

                                        <!-- History Timeline Card -->
                                        <div class="card border-0 shadow-none mb-0"
                                            style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0;">
                                            <div class="card-header bg-light py-2 px-3">
                                                <h6 class="mb-0 font-weight-bold text-slate-700"
                                                    style="font-size: 0.82rem; color: #334155;">
                                                    <i class="fas fa-history mr-2 text-indigo"></i>Work & Contract
                                                    History
                                                </h6>
                                            </div>
                                            <div class="card-body p-2" style="max-height: 200px; overflow-y: auto;"
                                                id="matchHistoryList">
                                                <!-- History populated by JS -->
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <asp:HiddenField ID="hfEditOldID" runat="server" Value="" />
                        <asp:HiddenField ID="hfResignedEmployeesJson" runat="server" Value="" ClientIDMode="Static" />
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary"
                            OnClick="btnCancelEdit_Click" Visible="false" style="display:none;"
                            formnovalidate="formnovalidate" />
                    </div>
                    <div class="modal-footer modal-footer-custom">
                        <button type="button" class="btn btn-secondary shadow-sm" data-bs-dismiss="modal"
                            style="border-radius: 8px; font-weight: 600; padding: 8px 16px; background-color: #64748b; border-color: #64748b; color: #fff;">Close</button>
                        <asp:Button ID="btnAddEmployee" runat="server" Text="Add Employee"
                            CssClass="btn btn-success shadow-sm" OnClick="btnAddEmployee_Click"
                            OnClientClick="return validateEmployeeForm();"
                            style="border-radius: 8px; font-weight: 600; padding: 8px 20px; background-color: #10b981; border-color: #10b981; color: #fff;" />
                    </div>
                </div>
            </div>
        </div>

        <!-- IMPORT MODAL -->
        <div class="modal fade" id="importModal" tabindex="-1" role="dialog" aria-labelledby="importModalLabel"
            aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header modal-header-custom text-white">
                        <h5 class="modal-title font-weight-bold" id="importModalLabel">
                            <i class="fas fa-file-import mr-2"></i> Import Employees (Excel / CSV)
                        </h5>
                        <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close"
                            style="opacity: 0.9;">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark p-4">
                        <div class="alert alert-info border-0 shadow-sm rounded-lg mb-4"
                            style="background-color: #e0e7ff; color: #3730a3;">
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-info-circle fa-lg mr-2" style="color: #4f46e5;"></i>
                                <strong style="font-size: 0.95rem;">Excel / CSV Data Import Guide</strong>
                            </div>
                            <p class="mb-2 small">Upload an Excel (<code>.xlsx</code>, <code>.xls</code>) or
                                <code>.CSV</code> file to bulk-import employee master records into the database.</p>
                            <div class="d-flex align-items-center justify-content-between flex-wrap pt-2 border-top"
                                style="border-top-color: #c7d2fe !important;">
                                <span class="small font-weight-bold"><i class="fas fa-file-excel mr-1 text-success"></i>
                                    Download pre-formatted sample Excel file:</span>
                                <button type="button" class="btn btn-sm font-weight-bold px-3 py-1 mt-1"
                                    onclick="downloadImportTemplate()"
                                    style="background-color: #4f46e5; color: #fff; border-radius: 6px; font-size: 0.82rem;">
                                    <i class="fas fa-download mr-1"></i> Download Sample Excel Template
                                </button>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="<%= ddlImportCat.ClientID %>" class="form-label-custom">Default Category
                                    (Fallback)</label>
                                <asp:DropDownList ID="ddlImportCat" runat="server"
                                    CssClass="form-control form-input-custom">
                                </asp:DropDownList>
                                <small class="text-muted d-block mt-1">Used if no Category column is specified in the
                                    Excel sheet row.</small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="<%= fileCSV.ClientID %>" class="form-label-custom">Select Excel / CSV File
                                    <span class="text-danger">*</span></label>
                                <asp:FileUpload ID="fileCSV" runat="server" CssClass="form-control form-input-custom"
                                    style="height: auto;" accept=".csv,.xlsx,.xls" />
                                <asp:HiddenField ID="hfImportData" runat="server" />
                            </div>
                        </div>

                        <div class="card bg-light border-0 p-3 mt-2" style="border-radius: 10px;">
                            <h6 class="font-weight-bold text-dark mb-2" style="font-size: 0.85rem;"><i
                                    class="fas fa-table mr-2 text-primary"></i> Column Layout &amp; Format
                                Specifications:</h6>
                            <div class="table-responsive" style="max-height: 220px; overflow-y: auto;">
                                <table class="table table-sm table-bordered bg-white mb-0 small"
                                    style="font-size: 0.8rem;">
                                    <thead class="bg-light text-secondary">
                                        <tr>
                                            <th>Col #</th>
                                            <th>Header Name</th>
                                            <th>Required?</th>
                                            <th>Description &amp; Format Example</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td><strong>ID</strong></td>
                                            <td><span class="badge badge-danger">Required</span></td>
                                            <td>Employee Badge / ID No (e.g. <code>10001</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td><strong>Name</strong></td>
                                            <td><span class="badge badge-danger">Required</span></td>
                                            <td>Full Name (e.g. <code>John Doe</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td><strong>Department</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Directorate / Division (e.g. <code>D-FMM</code>, <code>CWG</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>4</td>
                                            <td><strong>Join Date</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Joining Date (YYYY-MM-DD, e.g. <code>2024-01-15</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>5</td>
                                            <td><strong>Leave Balance</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Current Leave Days (e.g. <code>10</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>6</td>
                                            <td><strong>Qualification</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Education Degree (e.g. <code>B.Tech</code>, <code>ITI</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>7</td>
                                            <td><strong>Experience</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Experience in Years (e.g. <code>3.5</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>8</td>
                                            <td><strong>Experience In</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Roles / Skill Field (e.g. <code>Software Engineer</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>9</td>
                                            <td><strong>Phone</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Mobile / Phone No (e.g. <code>9876543210</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>10</td>
                                            <td><strong>Email</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Email Address (e.g. <code>john@example.com</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>11</td>
                                            <td><strong>Aadhar</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Aadhar Number (e.g. <code>123456789012</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>12</td>
                                            <td><strong>Address</strong></td>
                                            <td><span class="badge badge-secondary">Optional</span></td>
                                            <td>Full Address (e.g. <code>123 Main St</code>)</td>
                                        </tr>
                                        <tr>
                                            <td>13</td>
                                            <td><strong>Category</strong></td>
                                            <td><span class="badge badge-info">Flexible</span></td>
                                            <td>Category / Sub-Category Name (e.g. <code>HR:Skilled</code>,
                                                <code>Skilled</code>)</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-custom">
                        <button type="button" class="btn btn-secondary shadow-sm" data-bs-dismiss="modal"
                            style="border-radius: 8px; font-weight: 600; padding: 8px 16px;">Close</button>
                        <asp:Button ID="btnImport" runat="server" Text="Import Records"
                            CssClass="btn btn-primary shadow-sm" OnClick="btnImport_Click"
                            OnClientClick="return processImportFile();"
                            style="border-radius: 8px; font-weight: 600; padding: 8px 20px; background-color: #8b5cf6; border-color: #8b5cf6; color: #fff;" />
                    </div>
                </div>
            </div>
        </div>

        <!-- DELETE EMPLOYEE MODAL -->
        <div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel"
            aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%);">
                        <h5 class="modal-title font-weight-bold" id="deleteModalLabel">
                            <i class="fas fa-user-minus mr-2"></i> Delete Employee Records
                        </h5>
                        <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark">
                        <div class="alert alert-danger" role="alert" style="border-radius: 8px;">
                            <i class="fas fa-exclamation-triangle mr-2"></i>
                            <strong>Critical Warning:</strong> This will completely delete the employee's master record,
                            active/past contract engagements, attendance data, and wage overrides. <strong>This action
                                is permanent and cannot be undone.</strong>
                        </div>
                        <div class="form-group mb-3" style="position: relative;">
                            <label class="font-weight-bold mb-2">Select Employee to Delete</label>
                            <div class="dropdown" id="deleteDropdownContainer" style="position: relative;">
                                <button type="button"
                                    class="form-select form-control text-left d-flex justify-content-between align-items-center"
                                    id="btnDeleteDropdown" aria-haspopup="true" aria-expanded="false"
                                    style="font-weight: 600; border-color: #ef4444; border-radius: 8px; background-color: #fff; text-align: left; width: 100%;">
                                    <span id="deleteDropdownSelectedText">-- Select Employee --</span>
                                    <span class="dropdown-caret"
                                        style="border-top: 6px solid #ef4444; border-left: 4px solid transparent; border-right: 4px solid transparent; display: inline-block; margin-left: 8px;"></span>
                                </button>
                                <div class="dropdown-menu p-3 shadow-lg" aria-labelledby="btnDeleteDropdown"
                                    style="width: 100%; max-height: 350px; overflow: hidden; border-radius: 12px; border: 1px solid #fecaca; z-index: 1060; position: absolute; top: 100%; left: 0; display: none;">
                                    <div class="form-group mb-2">
                                        <div class="input-group">
                                            <div class="input-group-prepend" style="display: flex;">
                                                <span class="input-group-text bg-white border-right-0"
                                                    style="border-radius: 8px 0 0 8px; border-right: none;"><i
                                                        class="fas fa-search text-muted"></i></span>
                                            </div>
                                            <input type="text" id="txtDeleteSearchFilter" class="form-control"
                                                placeholder="Type name, ID, or Master ID to filter..."
                                                oninput="filterDeleteDropdownList();" autocomplete="off"
                                                style="font-weight: 600; border-radius: 0 8px 8px 0; border-left: 1px solid #ced4da;" />
                                        </div>
                                    </div>
                                    <div id="deleteDropdownItems"
                                        style="max-height: 220px; overflow-y: auto; margin-top: 8px;">
                                        <!-- Options populated by JavaScript -->
                                    </div>
                                </div>
                            </div>
                            <asp:DropDownList ID="ddlDeleteEmployee" runat="server" style="display: none;">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="modal-footer" style="border-top: 1px solid #f1f5f9;">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete Employee Completely"
                            CssClass="btn btn-danger" OnClick="btnConfirmDelete_Click"
                            OnClientClick="return confirmDeleteEmployee();" />
                    </div>
                </div>
            </div>
        </div>

        <!-- EMPLOYEE HISTORY MODAL -->
        <div class="modal fade history-modal" id="historyModal" tabindex="-1" role="dialog"
            aria-labelledby="historyModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-white"
                        style="background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);">
                        <h5 class="modal-title font-weight-bold" id="historyModalLabel">
                            <i class="fas fa-user-circle mr-2"></i> Employee Profile & History
                        </h5>
                        <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-dark" id="historyModalBody">
                        <div class="text-center p-4"><i class="fas fa-spinner fa-spin text-primary"></i> Loading...
                        </div>
                    </div>
                    <div class="modal-footer" style="border-top: 1px solid #f1f5f9;">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="Static/js/xlsx.full.min.js"></script>
        <script>
            function downloadImportTemplate() {
                var headers = [
                    ["ID", "Name", "Department", "Join Date", "Leave Balance", "Qualification", "Experience (Years)", "Experience In", "Phone", "Email", "Aadhar", "Address", "Category"]
                ];
                var sampleRows = [
                    ["10001", "John Doe", "D-FMM", "2024-01-15", "10", "B.Tech", "3.5", "Software Engineer", "9876543210", "john@example.com", "123456789012", "123 Main St", "HR:Skilled"],
                    ["10002", "Jane Smith", "CWG", "2024-02-01", "8", "Diploma", "2.0", "Data Entry Operator", "9876543211", "jane@example.com", "987654321098", "456 Park Ave", "HR:Semi-Skilled"]
                ];
                var data = headers.concat(sampleRows);
                var ws = XLSX.utils.aoa_to_sheet(data);

                // Set column widths for clean template display
                ws['!cols'] = [
                    { wch: 10 }, { wch: 20 }, { wch: 15 }, { wch: 12 }, { wch: 14 },
                    { wch: 15 }, { wch: 18 }, { wch: 22 }, { wch: 14 }, { wch: 22 },
                    { wch: 16 }, { wch: 25 }, { wch: 16 }
                ];

                var wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Employee_Import_Template");
                XLSX.writeFile(wb, "Employee_Import_Template.xlsx");
            }

            function processImportFile() {
                var fileUpload = document.getElementById('<%= fileCSV.ClientID %>');
                if (!fileUpload.files || fileUpload.files.length === 0) {
                    showToast("Please select a file to import.", "error");
                    return false;
                }
                var file = fileUpload.files[0];
                var fileName = file.name.toLowerCase();

                // Show loading overlay
                if (typeof showLoading === 'function') {
                    showLoading("Processing and parsing import file...");
                }

                var reader = new FileReader();
                reader.onload = function (e) {
                    try {
                        var data = new Uint8Array(e.target.result);
                        var workbook = XLSX.read(data, { type: 'array' });
                        var firstSheetName = workbook.SheetNames[0];
                        var worksheet = workbook.Sheets[firstSheetName];

                        // Convert sheet to json array of arrays, using raw: false to get formatted strings
                        var rows = XLSX.utils.sheet_to_json(worksheet, { header: 1, raw: false, defval: "" });

                        // Save to hidden field
                        document.getElementById('<%= hfImportData.ClientID %>').value = JSON.stringify(rows);

                        if (typeof hideLoading === 'function') {
                            hideLoading();
                        }

                        // Trigger postback programmatically
                        __doPostBack('<%= btnImport.UniqueID %>', '');
                    } catch (err) {
                        if (typeof hideLoading === 'function') {
                            hideLoading();
                        }
                        showToast("Failed to parse file: " + err.message, "error");
                    }
                };

                reader.onerror = function () {
                    if (typeof hideLoading === 'function') {
                        hideLoading();
                    }
                    showToast("Error reading file.", "error");
                };

                reader.readAsArrayBuffer(file);
                return false; // Prevent immediate postback
            }

            // Move modals inside the form tag using vanilla JS as soon as the DOM is parsed
            document.addEventListener('DOMContentLoaded', function () {
                var form = document.getElementById('form1');
                var empModal = document.getElementById('employeeModal');
                var importModal = document.getElementById('importModal');
                var deleteModal = document.getElementById('deleteModal');
                var histModal = document.getElementById('historyModal');
                var bulkLeaveModal = document.getElementById('bulkLeaveModal');
                if (form) {
                    if (empModal) form.appendChild(empModal);
                    if (importModal) form.appendChild(importModal);
                    if (deleteModal) form.appendChild(deleteModal);
                    if (histModal) form.appendChild(histModal);
                    if (bulkLeaveModal) form.appendChild(bulkLeaveModal);
                }
            });

            function clearBulkLeaveForm() {
                var amount = document.getElementById('<%= txtBulkLeaveAmount.ClientID %>');
                var remarks = document.getElementById('<%= txtBulkLeaveRemarks.ClientID %>');
                var date = document.getElementById('<%= txtBulkLeaveDate.ClientID %>');
                var cat = document.getElementById('<%= ddlBulkLeaveCategory.ClientID %>');
                var div = document.getElementById('<%= ddlBulkLeaveDivision.ClientID %>');
                if (amount) amount.value = "";
                if (remarks) remarks.value = "";
                if (date) date.value = "";
                if (cat) cat.selectedIndex = 0;
                if (div) div.selectedIndex = 0;
            }

            function validateBulkLeave() {
                var amount = document.getElementById('<%= txtBulkLeaveAmount.ClientID %>').value;
                var date = document.getElementById('<%= txtBulkLeaveDate.ClientID %>').value;
                var remarks = document.getElementById('<%= txtBulkLeaveRemarks.ClientID %>').value.trim();

                if (!amount || isNaN(parseFloat(amount))) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Validation Error',
                        text: 'Please enter a valid numeric leave amount.',
                        confirmButtonColor: '#10b981'
                    });
                    return false;
                }
                if (!date) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Validation Error',
                        text: 'Please select an effective date for this bulk leave change.',
                        confirmButtonColor: '#10b981'
                    });
                    return false;
                }
                if (!remarks) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Validation Error',
                        text: 'Please enter remarks explaining this bulk leave change.',
                        confirmButtonColor: '#10b981'
                    });
                    return false;
                }
                return true;
            }

            function confirmResetBulkLeave(btnId) {
                var date = document.getElementById('<%= txtBulkLeaveDate.ClientID %>').value;
                var remarks = document.getElementById('<%= txtBulkLeaveRemarks.ClientID %>').value.trim();
                var category = document.getElementById('<%= ddlBulkLeaveCategory.ClientID %>').value;
                var division = document.getElementById('<%= ddlBulkLeaveDivision.ClientID %>').value;

                if (!date) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Validation Error',
                        text: 'Please select an effective date for this bulk leave reset.',
                        confirmButtonColor: '#3b82f6'
                    });
                    return false;
                }
                if (!remarks) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Validation Error',
                        text: 'Please enter remarks for this bulk leave reset.',
                        confirmButtonColor: '#3b82f6'
                    });
                    return false;
                }

                var targetText = "Category: " + (category === "All" ? "All Categories" : category) + ", Directorate: " + (division === "All" ? "All Directorates" : division);

                Swal.fire({
                    title: 'Are you sure?',
                    text: 'This will reset the leave balance to 0 for all active employees in: ' + targetText + '. A compensating leave adjustment will be logged.',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#ef4444',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Yes, Reset to 0'
                }).then((result) => {
                    if (result.isConfirmed) {
                        __doPostBack(btnId, '');
                    }
                });
                return false;
            }

            var deleteConfirmed = false;
            function confirmDeleteEmployee() {
                if (deleteConfirmed) {
                    deleteConfirmed = false;
                    return true;
                }

                var ddl = document.getElementById('<%= ddlDeleteEmployee.ClientID %>');
                if (!ddl || ddl.selectedIndex === 0) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'No Employee Selected',
                        text: 'Please select an employee to delete from the list.',
                        confirmButtonColor: '#ef4444'
                    });
                    return false;
                }
                var selectedText = ddl.options[ddl.selectedIndex].text;

                Swal.fire({
                    title: 'Are you sure?',
                    html: 'You are about to completely delete <strong>' + selectedText + '</strong>.<br/><br/><span style="color: #ef4444; font-weight: bold;"><i class="fas fa-exclamation-triangle"></i> Critical Warning:</span> This will permanently wipe their attendance history, calculated overrides, and all engagement records. This action <strong>cannot be undone</strong>.',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc2626',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Yes, delete permanently!',
                    cancelButtonText: 'Cancel'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        deleteConfirmed = true;
                        var btn = document.getElementById('<%= btnConfirmDelete.ClientID %>');
                        if (btn) {
                            btn.click();
                        }
                    }
                });

                return false;
            }

            // ── Employee History Modal ────────────────────────────────────────────────
            function openHistoryModal(emp, history) {
                var body = document.getElementById('historyModalBody');
                if (!body) return;

                // Status badge
                var statusClass = emp.status === 'Resigned' ? '#dc2626' :
                    emp.status === 'Upgraded' ? '#0369a1' :
                        emp.status === 'Downgraded' ? '#b45309' : '#059669';

                var resignNote = '';
                if (emp.resignDate) {
                    resignNote = '<div style="font-size:0.8rem;margin-top:4px;opacity:0.9;"><i class="fas fa-sign-out-alt mr-1"></i>Resigned: ' + emp.resignDate + '</div>';
                }
                if (emp.contractEndDate && !emp.resignDate) {
                    resignNote = '<div style="font-size:0.8rem;margin-top:4px;opacity:0.9;"><i class="fas fa-calendar-times mr-1"></i>Contract ended: ' + emp.contractEndDate + '</div>';
                }

                var html = '<div class="emp-header-card">';
                html += '<div class="d-flex justify-content-between align-items-start">';
                html += '<div style="flex:1; min-width:0;">';
                html += '<div class="emp-name"><i class="fas fa-user-circle mr-2"></i>' + emp.name + '</div>';
                html += '<div class="emp-meta">Master ID: <strong>' + emp.masterId + '</strong> &nbsp;|&nbsp; Employee ID: <strong>' + emp.empId + '</strong></div>';

                var rejoinText = '';
                if (emp.rejoinDate) {
                    rejoinText = ' &nbsp;|&nbsp; Rejoined: <strong>' + emp.rejoinDate + '</strong>';
                }
                html += '<div class="emp-meta">Dept: <strong>' + emp.dept + '</strong> &nbsp;|&nbsp; Joined: <strong>' + emp.joinDate + '</strong>' + rejoinText + '</div>';

                // Contact row
                var contactInfo = [];
                if (emp.phone) contactInfo.push('<i class="fas fa-phone mr-1"></i> ' + emp.phone);
                if (emp.email) contactInfo.push('<i class="fas fa-envelope mr-1"></i> ' + emp.email);
                if (emp.aadhar) contactInfo.push('<i class="fas fa-id-card mr-1"></i> Aadhar: ' + emp.aadhar);
                if (contactInfo.length > 0) {
                    html += '<div class="emp-meta" style="margin-top: 6px; font-size: 0.82rem; border-top: 1px solid rgba(255,255,255,0.15); padding-top: 6px;">' + contactInfo.join(' &nbsp;|&nbsp; ') + '</div>';
                }

                // Address: full-width row on its own
                if (emp.address) {
                    html += '<div style="font-size:0.82rem; margin-top:8px; border-top:1px solid rgba(255,255,255,0.15); padding-top:8px; display:flex; align-items:flex-start; gap:6px;">'
                        + '<i class="fas fa-map-marker-alt" style="margin-top:2px;flex-shrink:0;"></i>'
                        + '<span><span style="opacity:0.75;">Address</span><br><strong>' + emp.address + '</strong></span>'
                        + '</div>';
                }
                // Qualification + Experience side by side
                var hasQualExp = emp.qualification || emp.experience;
                if (hasQualExp) {
                    html += '<div style="display:grid; grid-template-columns:1fr 1fr; gap:4px 16px; margin-top:8px; border-top:1px solid rgba(255,255,255,0.15); padding-top:8px;">';
                    if (emp.qualification) {
                        html += '<div style="font-size:0.82rem; display:flex; align-items:flex-start; gap:5px;">'
                            + '<i class="fas fa-graduation-cap" style="margin-top:2px;flex-shrink:0;"></i>'
                            + '<span><span style="opacity:0.75;">Qualification</span><br><strong>' + emp.qualification + '</strong></span>'
                            + '</div>';
                    }
                    if (emp.experience) {
                        html += '<div style="font-size:0.82rem; display:flex; align-items:flex-start; gap:5px;">'
                            + '<i class="fas fa-briefcase" style="margin-top:2px;flex-shrink:0;"></i>'
                            + '<span><span style="opacity:0.75;">Experience</span><br><strong>' + emp.experience + ' yr(s)</strong></span>'
                            + '</div>';
                    }
                    html += '</div>';
                }

                // Full-width Experience In (multiline)
                if (emp.experienceIn) {
                    var expLines = emp.experienceIn.replace(/\n/g, '<br>');
                    html += '<div style="font-size:0.82rem; margin-top:8px; border-top:1px solid rgba(255,255,255,0.15); padding-top:8px;">'
                        + '<div style="opacity:0.75; margin-bottom:3px;"><i class="fas fa-tasks mr-1"></i> Experience In</div>'
                        + '<div style="line-height:1.7; padding-left:4px;">' + expLines + '</div>'
                        + '</div>';
                }

                html += resignNote;
                html += '</div>';
                html += '<div class="d-flex flex-column align-items-end" style="gap: 8px; flex-shrink:0; margin-left:12px;">';
                html += '<span class="status-pill" style="background:' + statusClass + '22;border-color:' + statusClass + '55;color:#fff;margin-bottom:4px;">' + emp.status + '</span>';
                html += '<button type="button" class="btn btn-sm btn-light animate-hover" onclick="triggerClientEdit(\'' + emp.masterId + '\')" style="font-weight: 700; border-radius: 6px; padding: 4px 10px; font-size: 0.8rem; color: #4f46e5; border: 1px solid rgba(255,255,255,0.25); display: inline-flex; align-items: center; transition: all 0.2s; cursor: pointer;"><i class="fas fa-edit mr-1"></i> Edit Profile</button>';
                html += '</div>';
                html += '</div></div>';


                var rejoinAlreadyRepresented = false;
                if (emp.rejoinDate && history) {
                    for (var i = 0; i < history.length; i++) {
                        if (history[i].start === emp.rejoinDate) {
                            rejoinAlreadyRepresented = true;
                            break;
                        }
                    }
                }

                var events = [];
                if (history) {
                    for (var i = 0; i < history.length; i++) {
                        var h = history[i];
                        var evType = 'continue';
                        var evLabel = '<i class="fas fa-sync-alt mr-1"></i> Contract Renewed';
                        var dotClass = 'dot-continue';
                        var dotIcon = 'fas fa-sync-alt';

                        if (i === 0) {
                            evType = 'join';
                            evLabel = '<i class="fas fa-user-plus mr-1"></i> Joined';
                            dotClass = 'dot-join';
                            dotIcon = 'fas fa-user-plus';
                        } else if (h.stintId !== history[i - 1].stintId) {
                            evType = 'join';
                            evLabel = '<i class="fas fa-user-plus mr-1"></i> Rejoined';
                            dotClass = 'dot-join';
                            dotIcon = 'fas fa-user-plus';
                        } else {
                            var prev = history[i - 1];
                            var rank = { 'Unskilled': 1, 'Semi-Skilled': 2, 'Skilled': 3 };
                            var oldRank = rank[prev.cat] || 0;
                            var newRank = rank[h.cat] || 0;

                            if (newRank > oldRank) {
                                evType = 'upgrade';
                                evLabel = '<i class="fas fa-arrow-up mr-1"></i> Upgraded';
                                dotClass = 'dot-upgrade';
                                dotIcon = 'fas fa-arrow-up';
                            } else if (newRank < oldRank) {
                                evType = 'downgrade';
                                evLabel = '<i class="fas fa-arrow-down mr-1"></i> Downgraded';
                                dotClass = 'dot-downgrade';
                                dotIcon = 'fas fa-arrow-down';
                            } else {
                                var reason = (prev.endReason || '').trim().toLowerCase();
                                if (reason === 'transferred') {
                                    evType = 'transfer';
                                    evLabel = '<i class="fas fa-exchange-alt mr-1"></i> Transferred';
                                    dotClass = 'dot-transfer';
                                    dotIcon = 'fas fa-exchange-alt';
                                } else if (reason === 'upgraded') {
                                    evType = 'upgrade';
                                    evLabel = '<i class="fas fa-arrow-up mr-1"></i> Upgraded';
                                    dotClass = 'dot-upgrade';
                                    dotIcon = 'fas fa-arrow-up';
                                } else if (reason === 'downgraded') {
                                    evType = 'downgrade';
                                    evLabel = '<i class="fas fa-arrow-down mr-1"></i> Downgraded';
                                    dotClass = 'dot-downgrade';
                                    dotIcon = 'fas fa-arrow-down';
                                } else if (reason === 'resigned' || reason === 'resign') {
                                    evType = 'join';
                                    evLabel = '<i class="fas fa-user-plus mr-1"></i> Rejoined';
                                    dotClass = 'dot-join';
                                    dotIcon = 'fas fa-user-plus';
                                } else if (reason === 'contractended' || reason === 'contractend') {
                                    evType = 'continue';
                                    evLabel = '<i class="fas fa-sync-alt mr-1"></i> Contract Renewed';
                                    dotClass = 'dot-continue';
                                    dotIcon = 'fas fa-sync-alt';
                                }
                            }
                        }

                        events.push({
                            type: 'engagement',
                            evType: evType,
                            evLabel: evLabel,
                            dotClass: dotClass,
                            dotIcon: dotIcon,
                            date: h.start,
                            h: h
                        });

                        if (h.end && h.endReason) {
                            var reasonLower = h.endReason.trim().toLowerCase();
                            if (reasonLower === 'resigned' || reasonLower === 'resign') {
                                events.push({
                                    type: 'termination',
                                    status: 'Resigned',
                                    evType: 'end',
                                    evLabel: '<i class="fas fa-user-slash mr-1"></i> Resigned',
                                    dotClass: 'dot-end',
                                    dotIcon: 'fas fa-user-slash',
                                    date: h.end,
                                    details: 'Employee resigned from the company.'
                                });
                            } else if (reasonLower === 'contractended' || reasonLower === 'contractend') {
                                events.push({
                                    type: 'termination',
                                    status: 'ContractEnded',
                                    evType: 'end',
                                    evLabel: '<i class="fas fa-file-contract mr-1"></i> Contract Ended',
                                    dotClass: 'dot-end',
                                    dotIcon: 'fas fa-file-contract',
                                    date: h.end,
                                    details: 'Contract period ended / expired.'
                                });
                            }
                        }
                    }
                }

                if (emp.rejoinDate && !rejoinAlreadyRepresented) {
                    events.push({
                        type: 'rejoin_placeholder',
                        evType: 'join',
                        evLabel: '<i class="fas fa-user-plus mr-1"></i> Rejoined',
                        dotClass: 'dot-join',
                        dotIcon: 'fas fa-user-plus',
                        date: emp.rejoinDate,
                        details: 'Employee rejoined the company (Contract Ended / Pending Enrollment).'
                    });
                }

                if (events.length === 0) {
                    html += '<div class="tl-no-history"><i class="fas fa-inbox"></i>No engagement history found.</div>';
                } else {
                    html += '<div class="timeline">';

                    for (var k = 0; k < events.length; k++) {
                        var ev = events[k];
                        var isLastEvent = (k === events.length - 1);

                        html += '<div class="tl-item">';
                        html += '<div class="tl-dot"><div class="tl-dot-icon ' + ev.dotClass + '"><i class="' + ev.dotIcon + '" style="font-size:0.8rem;"></i></div></div>';
                        html += '<div class="tl-body">';

                        if (ev.type === 'engagement') {
                            var h = ev.h;
                            var periodStr = h.end ? (h.start + ' &rarr; ' + h.end) : (h.start + ' &rarr; Present');
                            var isCurrentEngagement = !h.end && isLastEvent;

                            html += '<div class="d-flex align-items-center" style="margin-bottom: 14px;">';
                            html += '<span class="tl-event-label ev-' + ev.evType + '">' + ev.evLabel + '</span>';
                            if (isCurrentEngagement) {
                                var hasNoContract = (h.cpRange === 'No Contract');
                                if (hasNoContract) {
                                    // No active contract — show a clear "Contract Ended" badge
                                    html += '<span class="tl-event-label ev-no-contract" style="margin-left: 8px;"><i class="fas fa-ban mr-1"></i> Contract Ended</span>';
                                } else {
                                    // Only show status badge when it adds info beyond the event label
                                    var currentStatus = emp.status || 'Active';
                                    var statusMatchesEvent =
                                        (currentStatus === 'Downgraded' && ev.evType === 'downgrade') ||
                                        (currentStatus === 'Upgraded' && ev.evType === 'upgrade') ||
                                        (currentStatus === 'Transferred' && ev.evType === 'transfer') ||
                                        (currentStatus === 'Active' && ev.evType === 'join');
                                    if (!statusMatchesEvent) {
                                        var currentBadgeClass = 'ev-active';
                                        var currentBadgeIcon = 'fas fa-check-circle';
                                        var currentBadgeText = 'Active';
                                        if (currentStatus === 'Downgraded') {
                                            currentBadgeClass = 'ev-current-downgrade'; currentBadgeIcon = 'fas fa-arrow-down'; currentBadgeText = 'Downgraded';
                                        } else if (currentStatus === 'Upgraded') {
                                            currentBadgeClass = 'ev-current-upgrade'; currentBadgeIcon = 'fas fa-arrow-up'; currentBadgeText = 'Upgraded';
                                        } else if (currentStatus === 'Transferred') {
                                            currentBadgeClass = 'ev-current-transfer'; currentBadgeIcon = 'fas fa-exchange-alt'; currentBadgeText = 'Transferred';
                                        }
                                        html += '<span class="tl-event-label ' + currentBadgeClass + '" style="margin-left: 8px;"><i class="' + currentBadgeIcon + ' mr-1"></i> ' + currentBadgeText + '</span>';
                                    }
                                }
                            }
                            html += '</div>';

                            var noContract = (h.cpRange === 'No Contract');
                            html += '<div class="tl-detail">';
                            html += '<div class="tl-kv"><span class="k">Category</span><span class="v">' + h.cat + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Directorate</span><span class="v">' + h.dept + '</span></div>';
                            html += '<div class="tl-kv"><span class="k">Employee ID</span><span class="v">' + h.historicalEmpId + '</span></div>';
                            if (!noContract) {
                                html += '<div class="tl-kv"><span class="k">Vendor</span><span class="v">' + h.vendor + '</span></div>';
                            }
                            html += '<div class="tl-kv"><span class="k">Period</span><span class="v">' + periodStr + '</span></div>';
                            if (h.end && h.endReason && h.endReason.toLowerCase() !== 'resigned' && h.endReason.toLowerCase() !== 'contractended') {
                                html += '<div class="tl-kv"><span class="k">End Reason</span><span class="v">' + h.endReason + '</span></div>';
                            }
                            html += '</div>';
                            if (noContract) {
                                html += '<span class="tl-contract-chip chip-no-contract"><i class="fas fa-ban mr-1"></i>No Active Contract</span>';
                            } else {
                                html += '<span class="tl-contract-chip"><i class="fas fa-file-contract mr-1"></i>Contract: ' + h.cpRange + '</span>';
                            }

                        } else if (ev.type === 'termination') {
                            html += '<div class="d-flex align-items-center" style="margin-bottom: 6px;">';
                            html += '<span class="tl-event-label ev-end">' + ev.evLabel + '</span>';
                            html += '</div>';
                            html += '<div style="font-size: 0.85rem; color: #64748b; font-weight: 600; margin-top: 4px;">';
                            html += 'Date: <strong>' + ev.date + '</strong> &nbsp;|&nbsp; ' + ev.details;
                            html += '</div>';

                        } else if (ev.type === 'rejoin_placeholder') {
                            html += '<div class="d-flex align-items-center" style="margin-bottom: 6px;">';
                            html += '<span class="tl-event-label ev-join">' + ev.evLabel + '</span>';
                            html += '<span class="tl-event-label ev-end" style="margin-left: 8px;"><i class="fas fa-file-signature mr-1"></i> Contract Ended</span>';
                            html += '</div>';
                            html += '<div style="font-size: 0.85rem; color: #64748b; font-weight: 600; margin-top: 4px;">';
                            html += 'Date: <strong>' + ev.date + '</strong> &nbsp;|&nbsp; ' + ev.details;
                            html += '</div>';
                        }

                        html += '</div></div>';
                    }
                    html += '</div>';
                }

                body.innerHTML = html;

                var modalEl = document.getElementById('historyModal');
                if (modalEl) {
                    var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                    modal.show();
                }
            }

            function triggerClientEdit(masterId) {
                var hf = document.getElementById('hfHiddenEditMasterId');
                if (hf) {
                    hf.value = masterId;
                }
                var btn = document.getElementById('<%= btnHiddenEditTrigger.ClientID %>');
                if (btn) {
                    var modalEl = document.getElementById('historyModal');
                    if (modalEl) {
                        var modal = bootstrap.Modal.getInstance(modalEl);
                        if (modal) modal.hide();
                    }
                    btn.click();
                }
            }
            // ── End History Modal ─────────────────────────────────────────────────────

            // Prevent enter key from triggering default button (Logout)
            document.addEventListener('keydown', function (event) {
                if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                    event.preventDefault();
                    return false;
                }
            });

            function toggleRejoiningSelection() {
                var chk = document.getElementById('chkIsRejoining');
                var div = document.getElementById('divRejoiningSelect');
                var txtMaster = document.getElementById('<%= txtMasterID.ClientID %>');
                var txtName = document.getElementById('<%= txtEmpName.ClientID %>');
                var ddl = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');

                if (chk && chk.checked) {
                    if (div) div.style.display = 'block';
                    if (txtName) {
                        txtName.readOnly = true;
                        txtName.style.backgroundColor = '#f1f5f9';
                    }

                    // Populate custom searchable dropdown items from the hidden server-side dropdown
                    populateRejoinSearchableDropdown();

                    // Reset filter text and options visibility
                    var filterInput = document.getElementById('txtRejoinSearchFilter');
                    if (filterInput) filterInput.value = '';
                    filterRejoinDropdownList();

                    populateRejoiningDetails();
                } else {
                    if (div) div.style.display = 'none';
                    if (txtMaster) txtMaster.value = '(Auto-Generated)';
                    if (txtName) {
                        txtName.value = '';
                        txtName.readOnly = false;
                        txtName.style.backgroundColor = '';
                    }
                    if (ddl) {
                        ddl.selectedIndex = 0;
                        updateRejoinDropdownUI();
                    }
                    populateRejoiningDetails();
                }
            }

            // Toggle custom dropdown open/close manually
            document.addEventListener('DOMContentLoaded', function () {
                // Check box onload state
                var chk = document.getElementById('chkIsRejoining');
                if (chk && chk.checked) {
                    toggleRejoiningSelection();
                }

                var btnDropdown = document.getElementById('btnRejoinDropdown');
                if (btnDropdown) {
                    btnDropdown.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();

                        var container = document.getElementById('rejoinDropdownContainer');
                        var menu = container ? container.querySelector('.dropdown-menu') : null;
                        if (!menu) return;

                        var isShown = menu.style.display === 'block';
                        closeRejoinDropdown();

                        if (!isShown) {
                            menu.style.display = 'block';
                            container.classList.add('show');

                            // Focus the search filter input
                            setTimeout(function () {
                                var filterInput = document.getElementById('txtRejoinSearchFilter');
                                if (filterInput) {
                                    filterInput.focus();
                                    filterInput.select();
                                }
                            }, 50);
                        }
                    });
                }

                // Close dropdown when clicking outside
                document.addEventListener('click', function (e) {
                    var container = document.getElementById('rejoinDropdownContainer');
                    if (container && !container.contains(e.target)) {
                        closeRejoinDropdown();
                    }
                });

                // Delete dropdown toggling
                var btnDeleteDropdown = document.getElementById('btnDeleteDropdown');
                if (btnDeleteDropdown) {
                    btnDeleteDropdown.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();

                        var container = document.getElementById('deleteDropdownContainer');
                        var menu = container ? container.querySelector('.dropdown-menu') : null;
                        if (!menu) return;

                        var isShown = menu.style.display === 'block';
                        closeDeleteDropdown();
                        closeRejoinDropdown();

                        if (!isShown) {
                            menu.style.display = 'block';
                            container.classList.add('show');

                            // Focus the search filter input
                            setTimeout(function () {
                                var filterInput = document.getElementById('txtDeleteSearchFilter');
                                if (filterInput) {
                                    filterInput.focus();
                                    filterInput.select();
                                }
                            }, 50);
                        }
                    });
                }

                // Close delete dropdown when clicking outside
                document.addEventListener('click', function (e) {
                    var container = document.getElementById('deleteDropdownContainer');
                    if (container && !container.contains(e.target)) {
                        closeDeleteDropdown();
                    }
                });

                // Populate delete dropdown list when modal is about to be shown
                var delModalEl = document.getElementById('deleteModal');
                if (delModalEl) {
                    delModalEl.addEventListener('show.bs.modal', function () {
                        // Populate items
                        populateDeleteSearchableDropdown();

                        // Reset filter search input
                        var filterInput = document.getElementById('txtDeleteSearchFilter');
                        if (filterInput) filterInput.value = '';
                        filterDeleteDropdownList();

                        // Reset selection
                        var ddl = document.getElementById('<%= ddlDeleteEmployee.ClientID %>');
                        if (ddl) {
                            ddl.selectedIndex = 0;
                            updateDeleteDropdownUI();
                        }
                    });
                }
            });

            function closeRejoinDropdown() {
                var container = document.getElementById('rejoinDropdownContainer');
                if (!container) return;
                var menu = container.querySelector('.dropdown-menu');
                if (menu) {
                    menu.style.display = 'none';
                }
                container.classList.remove('show');
            }

            function populateRejoinSearchableDropdown() {
                var ddl = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                var container = document.getElementById('rejoinDropdownItems');
                var selectedTextSpan = document.getElementById('rejoinDropdownSelectedText');

                if (!ddl || !container) return;

                container.innerHTML = '';

                if (ddl.options.length <= 1) {
                    var noItem = document.createElement('div');
                    noItem.className = 'text-muted p-2 text-center';
                    noItem.style.fontSize = '0.9rem';
                    noItem.textContent = 'No resigned employees found';
                    container.appendChild(noItem);

                    if (selectedTextSpan) selectedTextSpan.textContent = '-- No Resigned Employees --';
                    return;
                }

                for (var i = 1; i < ddl.options.length; i++) {
                    var opt = ddl.options[i];
                    var mId = opt.value;
                    var name = opt.getAttribute('data-name') || '';
                    var text = opt.text;

                    var btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'dropdown-item rejoin-item-btn py-2 px-3 text-left w-100 border-0 bg-transparent';
                    btn.style.fontSize = '0.9rem';
                    btn.style.fontWeight = '500';
                    btn.style.borderRadius = '6px';
                    btn.style.color = '#334155';
                    btn.style.cursor = 'pointer';
                    btn.style.textAlign = 'left';
                    btn.style.display = 'block';
                    btn.style.transition = 'background-color 0.15s ease';

                    btn.addEventListener('mouseenter', function () {
                        this.style.backgroundColor = '#eef2ff';
                        this.style.color = '#4f46e5';
                    });
                    btn.addEventListener('mouseleave', function () {
                        this.style.backgroundColor = 'transparent';
                        this.style.color = '#334155';
                    });

                    btn.setAttribute('data-index', i);
                    btn.setAttribute('data-value', mId);
                    btn.setAttribute('data-name', name);
                    btn.setAttribute('data-dept', opt.getAttribute('data-dept') || '');
                    btn.setAttribute('data-tierid', opt.getAttribute('data-tierid') || '');
                    btn.setAttribute('data-phone', opt.getAttribute('data-phone') || '');
                    btn.setAttribute('data-email', opt.getAttribute('data-email') || '');
                    btn.setAttribute('data-aadhar', opt.getAttribute('data-aadhar') || '');
                    btn.setAttribute('data-address', opt.getAttribute('data-address') || '');
                    btn.setAttribute('data-qual', opt.getAttribute('data-qual') || '');
                    btn.setAttribute('data-exp', opt.getAttribute('data-exp') || '');
                    btn.setAttribute('data-expin', opt.getAttribute('data-expin') || '');
                    btn.setAttribute('data-display-text', text);

                    btn.textContent = text;

                    btn.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        var idx = parseInt(this.getAttribute('data-index'), 10);
                        var val = this.getAttribute('data-value');
                        var dispText = this.getAttribute('data-display-text');
                        selectRejoinEmployee(idx, val, dispText);
                    });

                    container.appendChild(btn);
                }

                updateRejoinDropdownUI();
            }

            function selectRejoinEmployee(idx, val, dispText) {
                var ddl = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                if (ddl) {
                    ddl.selectedIndex = idx;
                }

                updateRejoinDropdownUI();
                populateRejoiningDetails();
                closeRejoinDropdown();
            }

            function updateRejoinDropdownUI() {
                var ddl = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                var selectedTextSpan = document.getElementById('rejoinDropdownSelectedText');
                if (ddl && selectedTextSpan) {
                    if (ddl.selectedIndex > 0) {
                        selectedTextSpan.textContent = ddl.options[ddl.selectedIndex].text;
                        selectedTextSpan.style.color = '#1e293b';
                    } else {
                        selectedTextSpan.textContent = '-- Select Resigned Employee --';
                        selectedTextSpan.style.color = '#94a3b8';
                    }
                }
            }

            function filterRejoinDropdownList() {
                var filterInput = document.getElementById('txtRejoinSearchFilter');
                if (!filterInput) return;
                var filterText = filterInput.value.toLowerCase().trim();

                var container = document.getElementById('rejoinDropdownItems');
                if (!container) return;

                var buttons = container.getElementsByClassName('rejoin-item-btn');
                for (var i = 0; i < buttons.length; i++) {
                    var btn = buttons[i];
                    var dispText = btn.getAttribute('data-display-text').toLowerCase();
                    var val = btn.getAttribute('data-value').toLowerCase();
                    var name = btn.getAttribute('data-name').toLowerCase();

                    if (dispText.includes(filterText) || val.includes(filterText) || name.includes(filterText)) {
                        btn.style.setProperty('display', 'block', 'important');
                    } else {
                        btn.style.setProperty('display', 'none', 'important');
                    }
                }
            }

            function closeDeleteDropdown() {
                var container = document.getElementById('deleteDropdownContainer');
                if (!container) return;
                var menu = container.querySelector('.dropdown-menu');
                if (menu) {
                    menu.style.display = 'none';
                }
                container.classList.remove('show');
            }

            function populateDeleteSearchableDropdown() {
                var ddl = document.getElementById('<%= ddlDeleteEmployee.ClientID %>');
                var container = document.getElementById('deleteDropdownItems');
                var selectedTextSpan = document.getElementById('deleteDropdownSelectedText');

                if (!ddl || !container) return;

                container.innerHTML = '';

                if (ddl.options.length <= 1) {
                    var noItem = document.createElement('div');
                    noItem.className = 'text-muted p-2 text-center';
                    noItem.style.fontSize = '0.9rem';
                    noItem.textContent = 'No employees found';
                    container.appendChild(noItem);

                    if (selectedTextSpan) selectedTextSpan.textContent = '-- No Employees --';
                    return;
                }

                for (var i = 1; i < ddl.options.length; i++) {
                    var opt = ddl.options[i];
                    var mId = opt.value;
                    var text = opt.text;

                    var btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'dropdown-item delete-item-btn py-2 px-3 text-left w-100 border-0 bg-transparent';
                    btn.style.fontSize = '0.9rem';
                    btn.style.fontWeight = '500';
                    btn.style.borderRadius = '6px';
                    btn.style.color = '#334155';
                    btn.style.cursor = 'pointer';
                    btn.style.textAlign = 'left';
                    btn.style.display = 'block';
                    btn.style.transition = 'background-color 0.15s ease';

                    btn.addEventListener('mouseenter', function () {
                        this.style.backgroundColor = '#fee2e2';
                        this.style.color = '#dc2626';
                    });
                    btn.addEventListener('mouseleave', function () {
                        this.style.backgroundColor = 'transparent';
                        this.style.color = '#334155';
                    });

                    btn.setAttribute('data-index', i);
                    btn.setAttribute('data-value', mId);
                    btn.setAttribute('data-display-text', text);

                    btn.textContent = text;

                    btn.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        var idx = parseInt(this.getAttribute('data-index'), 10);
                        var val = this.getAttribute('data-value');
                        var dispText = this.getAttribute('data-display-text');
                        selectDeleteEmployee(idx, val, dispText);
                    });

                    container.appendChild(btn);
                }

                updateDeleteDropdownUI();
            }

            function selectDeleteEmployee(idx, val, dispText) {
                var ddl = document.getElementById('<%= ddlDeleteEmployee.ClientID %>');
                if (ddl) {
                    ddl.selectedIndex = idx;
                }
                updateDeleteDropdownUI();
                closeDeleteDropdown();
            }

            function updateDeleteDropdownUI() {
                var ddl = document.getElementById('<%= ddlDeleteEmployee.ClientID %>');
                var selectedTextSpan = document.getElementById('deleteDropdownSelectedText');
                if (ddl && selectedTextSpan) {
                    if (ddl.selectedIndex > 0) {
                        selectedTextSpan.textContent = ddl.options[ddl.selectedIndex].text;
                        selectedTextSpan.style.color = '#1e293b';
                    } else {
                        selectedTextSpan.textContent = '-- Select Employee --';
                        selectedTextSpan.style.color = '#94a3b8';
                    }
                }
            }

            function filterDeleteDropdownList() {
                var filterInput = document.getElementById('txtDeleteSearchFilter');
                if (!filterInput) return;
                var filterText = filterInput.value.toLowerCase().trim();

                var container = document.getElementById('deleteDropdownItems');
                if (!container) return;

                var buttons = container.getElementsByClassName('delete-item-btn');
                for (var i = 0; i < buttons.length; i++) {
                    var btn = buttons[i];
                    var dispText = btn.getAttribute('data-display-text').toLowerCase();
                    var val = btn.getAttribute('data-value').toLowerCase();

                    if (dispText.includes(filterText) || val.includes(filterText)) {
                        btn.style.setProperty('display', 'block', 'important');
                    } else {
                        btn.style.setProperty('display', 'none', 'important');
                    }
                }
            }

            function populateRejoiningDetails() {
                var ddl = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                var txtName = document.getElementById('<%= txtEmpName.ClientID %>');
                var txtMaster = document.getElementById('<%= txtMasterID.ClientID %>');
                var txtPhone = document.getElementById('<%= txtPhone.ClientID %>');
                var txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
                var txtAadhar = document.getElementById('<%= txtAadhar.ClientID %>');
                var txtAddress = document.getElementById('<%= txtAddress.ClientID %>');
                var txtQualification = document.getElementById('<%= txtQualification.ClientID %>');
                var txtExperience = document.getElementById('<%= txtExperience.ClientID %>');
                var txtExperienceIn = document.getElementById('<%= txtExperienceIn.ClientID %>');
                var ddlCat = document.getElementById('<%= ddlCat.ClientID %>');
                var ddlDept = document.getElementById('<%= ddlDept.ClientID %>');
                var hfJson = document.getElementById('hfResignedEmployeesJson');

                var resignedList = [];
                if (hfJson && hfJson.value) {
                    try {
                        resignedList = JSON.parse(hfJson.value);
                    } catch (e) {
                        console.error('Error parsing resigned employees JSON:', e);
                    }
                }

                if (ddl && ddl.selectedIndex > 0) {
                    var selectedMasterId = ddl.options[ddl.selectedIndex].value;
                    var emp = resignedList.find(function (e) { return e.masterId === selectedMasterId; });

                    if (emp) {
                        if (txtName) txtName.value = emp.name || '';
                        if (txtMaster) txtMaster.value = emp.masterId || '';
                        if (txtPhone) txtPhone.value = emp.phone || '';
                        if (txtEmail) txtEmail.value = emp.email || '';
                        if (txtAadhar) txtAadhar.value = emp.aadhar || '';
                        if (txtAddress) txtAddress.value = emp.address || '';
                        if (txtQualification) txtQualification.value = emp.qualification || '';
                        if (txtExperience) txtExperience.value = emp.experience || '';
                        if (txtExperienceIn) txtExperienceIn.value = emp.experienceIn || '';

                        if (ddlCat && emp.tierId) {
                            ddlCat.value = emp.tierId;
                        }
                        if (ddlDept && emp.dept && emp.dept !== "N/A") {
                            ddlDept.value = emp.dept;
                        }
                    }
                } else {
                    if (document.getElementById('chkIsRejoining') && document.getElementById('chkIsRejoining').checked) {
                        if (txtName) txtName.value = '';
                        if (txtMaster) txtMaster.value = '';
                    }
                    if (txtPhone) txtPhone.value = '';
                    if (txtEmail) txtEmail.value = '';
                    if (txtAadhar) txtAadhar.value = '';
                    if (txtAddress) txtAddress.value = '';
                    if (txtQualification) txtQualification.value = '';
                    if (txtExperience) txtExperience.value = '';
                    if (txtExperienceIn) txtExperienceIn.value = '';
                }
            }

            function clearForm() {
                var txtId = document.getElementById('<%= txtEmpID.ClientID %>');
                var txtName = document.getElementById('<%= txtEmpName.ClientID %>');
                var txtLeave = document.getElementById('<%= txtLeaveBalance.ClientID %>');
                var txtJoin = document.getElementById('<%= txtJoinDate.ClientID %>');
                var hfId = document.getElementById('<%= hfEditOldID.ClientID %>');
                var txtMaster = document.getElementById('<%= txtMasterID.ClientID %>');
                var chkRejoin = document.getElementById('chkIsRejoining');
                var divRejoin = document.getElementById('divRejoiningSelect');
                var ddlRejoin = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                var filterInput = document.getElementById('txtRejoinSearchFilter');

                if (filterInput) filterInput.value = '';

                if (txtId) {
                    txtId.value = '';
                    txtId.disabled = false;
                    txtId.readOnly = false;
                }
                if (txtName) {
                    txtName.value = '';
                    txtName.readOnly = false;
                    txtName.style.backgroundColor = '';
                }
                if (txtLeave) txtLeave.value = '';
                if (txtJoin) {
                    txtJoin.value = '';
                    txtJoin.disabled = false;
                    txtJoin.readOnly = false;
                }

                var txtPhone = document.getElementById('<%= txtPhone.ClientID %>');
                var txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
                var txtAadhar = document.getElementById('<%= txtAadhar.ClientID %>');
                var txtAddress = document.getElementById('<%= txtAddress.ClientID %>');
                var txtQualification = document.getElementById('<%= txtQualification.ClientID %>');
                var txtExperience = document.getElementById('<%= txtExperience.ClientID %>');
                var txtExperienceIn = document.getElementById('<%= txtExperienceIn.ClientID %>');
                if (txtPhone) txtPhone.value = '';
                if (txtEmail) txtEmail.value = '';
                if (txtAadhar) txtAadhar.value = '';
                if (txtAddress) txtAddress.value = '';
                if (txtQualification) txtQualification.value = '';
                if (txtExperience) txtExperience.value = '';
                if (txtExperienceIn) txtExperienceIn.value = '';

                if (hfId) hfId.value = '';
                if (txtMaster) txtMaster.value = '(Auto-Generated)';

                var displaySpan = document.getElementById('displayMasterID');
                if (displaySpan) displaySpan.textContent = '(Auto-Generated)';

                if (chkRejoin) {
                    chkRejoin.checked = false;
                    chkRejoin.disabled = false;
                }
                if (divRejoin) divRejoin.style.display = 'none';
                if (ddlRejoin) {
                    ddlRejoin.disabled = false;
                    ddlRejoin.selectedIndex = 0;
                    updateRejoinDropdownUI();
                }

                var ddlDept = document.getElementById('<%= ddlDept.ClientID %>');
                if (ddlDept) {
                    ddlDept.disabled = false;
                    ddlDept.selectedIndex = 0;
                }
                var lblDeptHelp = document.getElementById('<%= lblDeptHelp.ClientID %>');
                if (lblDeptHelp) lblDeptHelp.style.display = 'none';

                var ddlCat = document.getElementById('<%= ddlCat.ClientID %>');
                if (ddlCat) {
                    ddlCat.disabled = false;
                    ddlCat.selectedIndex = 0;
                }
                var lblCatHelp = document.getElementById('<%= lblCatHelp.ClientID %>');
                if (lblCatHelp) lblCatHelp.style.display = 'none';

                // Reset button text and modal header
                var btn = document.getElementById('<%= btnAddEmployee.ClientID %>');
                if (btn) btn.value = 'Add Employee';
                var label = document.getElementById('employeeModalLabel');
                if (label) label.textContent = 'Add New Employee';
                hideAadharMatchPanel();
            }

            // ── Aadhaar Duplicate Match & Rejoin JS Functions ──────────────────────
            let currentMatchedEmployee = null;
            let hasAadharDuplicateError = false;

            function onAadharInputChanged() {
                var txtAadhar = document.getElementById('<%= txtAadhar.ClientID %>');
                var errLabel = document.getElementById('lblAadharDupError');
                if (!txtAadhar) return;
                var rawVal = txtAadhar.value || '';
                var cleanVal = rawVal.replace(/[^0-9]/g, '');

                // EXACT 12 DIGITS REQUIREMENT CHECK!
                if (cleanVal.length === 12) {
                    var hfEditOldID = document.getElementById('<%= hfEditOldID.ClientID %>');
                    var chkRejoin = document.getElementById('chkIsRejoining');
                    var ddlRejoin = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                    var displayMaster = document.getElementById('displayMasterID');

                    var currentMasterId = '';
                    if (hfEditOldID && hfEditOldID.value) {
                        currentMasterId = hfEditOldID.value.trim();
                    } else if (chkRejoin && chkRejoin.checked && ddlRejoin && ddlRejoin.value) {
                        currentMasterId = ddlRejoin.value.trim();
                    } else if (displayMaster && displayMaster.textContent && displayMaster.textContent.trim() !== '(Auto-Generated)') {
                        currentMasterId = displayMaster.textContent.trim();
                    }

                    fetch('Employee.aspx/CheckAadharMatch', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ aadharNumber: cleanVal, currentMasterId: currentMasterId })
                    })
                        .then(r => r.json())
                        .then(res => {
                            var data = JSON.parse(res.d || '{}');
                            if (data.matched && data.employee) {
                                currentMatchedEmployee = data.employee;
                                renderAadharMatchPanel(data.employee, data.history || []);

                                var isRejoiningMatched = (chkRejoin && chkRejoin.checked && ddlRejoin && ddlRejoin.value === data.employee.MasterId);
                                var isEditingSelf = (hfEditOldID && hfEditOldID.value && hfEditOldID.value === data.employee.MasterId);

                                if (!isRejoiningMatched && !isEditingSelf) {
                                    hasAadharDuplicateError = true;
                                    if (errLabel) {
                                        var empLabel = data.employee.Name + (data.employee.EmployeeId ? (' (' + data.employee.EmployeeId + ')') : '');
                                        errLabel.innerHTML = '<i class="fas fa-exclamation-circle mr-1"></i>Aadhaar number already registered for employee ' + empLabel + '!';
                                        errLabel.style.display = 'block';
                                    }
                                } else {
                                    hasAadharDuplicateError = false;
                                    if (errLabel) errLabel.style.display = 'none';
                                }
                            } else {
                                hasAadharDuplicateError = false;
                                if (errLabel) errLabel.style.display = 'none';
                                hideAadharMatchPanel();
                            }
                        })
                        .catch(err => {
                            console.error('Error checking Aadhaar match:', err);
                            hasAadharDuplicateError = false;
                            if (errLabel) errLabel.style.display = 'none';
                            hideAadharMatchPanel();
                        });
                } else {
                    hasAadharDuplicateError = false;
                    if (errLabel) errLabel.style.display = 'none';
                    hideAadharMatchPanel();
                }
            }

            function validateEmployeeForm() {
                var txtAadhar = document.getElementById('<%= txtAadhar.ClientID %>');
                var chkRejoin = document.getElementById('chkIsRejoining');
                var ddlRejoin = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                var errLabel = document.getElementById('lblAadharDupError');

                if (txtAadhar) {
                    var rawVal = txtAadhar.value || '';
                    var cleanVal = rawVal.replace(/[^0-9]/g, '');

                    if (cleanVal.length > 0 && cleanVal.length !== 12) {
                        if (typeof showToast === 'function') {
                            showToast('Aadhaar number must be exactly 12 digits.', 'warning');
                        } else {
                            alert('Aadhaar number must be exactly 12 digits.');
                        }
                        txtAadhar.focus();
                        return false;
                    }

                    if (cleanVal.length === 12 && hasAadharDuplicateError) {
                        var isRejoiningMatched = (chkRejoin && chkRejoin.checked && ddlRejoin && ddlRejoin.value && currentMatchedEmployee && ddlRejoin.value === currentMatchedEmployee.MasterId);
                        if (!isRejoiningMatched) {
                            var matchedName = currentMatchedEmployee ? currentMatchedEmployee.Name : 'another employee';
                            var matchedId = (currentMatchedEmployee && currentMatchedEmployee.EmployeeId) ? (' (' + currentMatchedEmployee.EmployeeId + ')') : '';
                            var msg = 'Aadhaar number is already registered for employee ' + matchedName + matchedId + '!';
                            if (typeof showToast === 'function') {
                                showToast(msg, 'error');
                            } else {
                                alert(msg);
                            }
                            if (errLabel) errLabel.style.display = 'block';
                            txtAadhar.focus();
                            return false;
                        }
                    }
                }
                return true;
            }

            function renderAadharMatchPanel(emp, history) {
                var modalDialog = document.getElementById('employeeModalDialog');
                var formCol = document.getElementById('employeeFormCol');
                var matchCol = document.getElementById('employeeMatchPanelCol');

                if (modalDialog) modalDialog.classList.add('modal-xl');
                if (formCol) {
                    formCol.classList.remove('col-12');
                    formCol.classList.add('col-md-7');
                }

                // Set Avatar Initials
                var avatar = document.getElementById('matchAvatar');
                if (avatar) {
                    var parts = (emp.Name || '').trim().split(' ');
                    var initials = parts.length > 1 ? (parts[0][0] + parts[parts.length - 1][0]) : (emp.Name ? emp.Name.substring(0, 2) : '--');
                    avatar.textContent = initials.toUpperCase();
                }

                // Fill Employee Details
                var elName = document.getElementById('matchEmpName');
                var elMaster = document.getElementById('matchMasterID');
                var elEmpID = document.getElementById('matchEmpID');
                var elDept = document.getElementById('matchDepartment');
                var elCat = document.getElementById('matchCategory');
                var elPhone = document.getElementById('matchPhone');
                var elJoin = document.getElementById('matchJoinDate');
                var elResign = document.getElementById('matchResignDate');
                var elBadge = document.getElementById('matchEmpStatusBadge');

                if (elName) elName.textContent = emp.Name || '--';
                if (elMaster) elMaster.textContent = 'Master ID: ' + (emp.MasterId || '--');
                if (elEmpID) elEmpID.textContent = emp.EmployeeId || '--';
                if (elDept) elDept.textContent = emp.Department || '--';
                if (elCat) elCat.textContent = emp.CategoryName || '--';
                if (elPhone) elPhone.textContent = emp.Phone || '--';
                if (elJoin) elJoin.textContent = emp.JoinDate || '--';
                if (elResign) elResign.textContent = emp.ResignDate || emp.ContractEndDate || '--';

                // Status Badge Styling
                if (elBadge) {
                    elBadge.textContent = emp.Status || 'Unknown';
                    if (emp.Status === 'Resigned') {
                        elBadge.style.backgroundColor = '#fee2e2';
                        elBadge.style.color = '#991b1b';
                    } else if (emp.Status === 'Active') {
                        elBadge.style.backgroundColor = '#dcfce7';
                        elBadge.style.color = '#166534';
                    } else {
                        elBadge.style.backgroundColor = '#fef3c7';
                        elBadge.style.color = '#92400e';
                    }
                }

                // Rejoin Button vs Active Notice
                var actionBox = document.getElementById('matchRejoinActionBox');
                var activeBox = document.getElementById('matchActiveNoticeBox');

                if (emp.Status === 'Resigned') {
                    if (actionBox) actionBox.style.display = 'block';
                    if (activeBox) activeBox.style.display = 'none';
                } else {
                    if (actionBox) actionBox.style.display = 'none';
                    if (activeBox) activeBox.style.display = 'block';
                }

                // Render History List
                var histContainer = document.getElementById('matchHistoryList');
                if (histContainer) {
                    if (!history || history.length === 0) {
                        histContainer.innerHTML = '<div class="text-center text-muted py-3" style="font-size: 0.8rem;">No contract history recorded.</div>';
                    } else {
                        var html = '<ul class="list-unstyled mb-0" style="font-size: 0.78rem;">';
                        history.forEach(function (h, idx) {
                            html += '<li class="mb-2 pb-2" style="border-bottom: 1px dashed #e2e8f0;">';
                            html += '<div class="d-flex justify-content-between font-weight-bold text-dark">';
                            html += '<span><i class="fas fa-building mr-1 text-indigo"></i> ' + (h.VendorName || 'Direct Contract') + '</span>';
                            html += '<span class="text-muted">' + (h.StartDate || '') + ' - ' + (h.EndDate || 'Present') + '</span>';
                            html += '</div>';
                            html += '<div class="text-muted mt-1">';
                            if (h.CategoryName) html += '<span class="mr-2"><i class="fas fa-layer-group mr-1"></i>' + h.CategoryName + '</span>';
                            if (h.Department) html += '<span><i class="fas fa-sitemap mr-1"></i>' + h.Department + '</span>';
                            html += '</div>';
                            if (h.EndReason) {
                                html += '<div class="text-danger font-weight-bold mt-1" style="font-size: 0.72rem;">Exit Reason: ' + h.EndReason + '</div>';
                            }
                            html += '</li>';
                        });
                        html += '</ul>';
                        histContainer.innerHTML = html;
                    }
                }

                if (matchCol) matchCol.style.display = 'block';
            }

            function hideAadharMatchPanel() {
                currentMatchedEmployee = null;
                var modalDialog = document.getElementById('employeeModalDialog');
                var formCol = document.getElementById('employeeFormCol');
                var matchCol = document.getElementById('employeeMatchPanelCol');

                if (modalDialog) modalDialog.classList.remove('modal-xl');
                if (formCol) {
                    formCol.classList.remove('col-md-7');
                    formCol.classList.add('col-12');
                }
                if (matchCol) matchCol.style.display = 'none';
            }

            function triggerRejoinFromMatch() {
                if (!currentMatchedEmployee || currentMatchedEmployee.Status !== 'Resigned') {
                    if (typeof showToast === 'function') {
                        showToast('Only resigned employees can be linked for rejoining.', 'warning');
                    } else {
                        alert('Only resigned employees can be linked for rejoining.');
                    }
                    return;
                }

                var chkRejoin = document.getElementById('chkIsRejoining');
                if (chkRejoin && !chkRejoin.checked) {
                    chkRejoin.checked = true;
                    toggleRejoiningSelection();
                }

                var ddlRejoin = document.getElementById('<%= ddlRejoiningEmployee.ClientID %>');
                if (ddlRejoin) {
                    for (var i = 0; i < ddlRejoin.options.length; i++) {
                        if (ddlRejoin.options[i].value === currentMatchedEmployee.MasterId) {
                            ddlRejoin.selectedIndex = i;
                            break;
                        }
                    }
                    updateRejoinDropdownUI();
                    populateRejoiningDetails();
                }

                if (typeof showToast === 'function') {
                    showToast('Linked employee ' + currentMatchedEmployee.Name + ' (' + currentMatchedEmployee.MasterId + ') for rejoining!', 'success');
                } else {
                    alert('Linked employee ' + currentMatchedEmployee.Name + ' (' + currentMatchedEmployee.MasterId + ') for rejoining!');
                }
            }

            // ── Advanced Filter helpers ───────────────────────────────────────────────

            function toggleAdvancedFilters() {
                var panel = document.getElementById('advancedFiltersPanel');
                var btn = document.getElementById('btnToggleAdvFilter');
                if (!panel) return;
                var open = panel.style.display !== 'none';
                panel.style.display = open ? 'none' : 'block';
                btn.style.background = open ? '#f5f3ff' : '#ede9fe';
                btn.style.borderColor = open ? '#a5b4fc' : '#7c3aed';
            }

            function toggleJoinDateInputs() {
                var mode = document.getElementById('advJoinMode').value;
                var w1 = document.getElementById('advJoinDate1Wrap');
                var w2 = document.getElementById('advJoinDate2Wrap');
                var lbl = w1.querySelector('label');
                w1.style.display = mode ? 'block' : 'none';
                w2.style.display = mode === 'between' ? 'block' : 'none';
                if (lbl) lbl.textContent = mode === 'between' ? 'From Date' : 'Date';
            }

            function toggleExpInputs() {
                var mode = document.getElementById('advExpMode').value;
                var w1 = document.getElementById('advExpVal1Wrap');
                var w2 = document.getElementById('advExpVal2Wrap');
                var lbl = document.getElementById('advExpVal1Label');
                w1.style.display = mode ? 'block' : 'none';
                w2.style.display = mode === 'between' ? 'block' : 'none';
                if (lbl) lbl.textContent = mode === 'between' ? 'From (Years)' : 'Years';
            }

            function updateAdvFilterBadge(count) {
                var badge = document.getElementById('advFilterBadge');
                if (!badge) return;
                if (count > 0) {
                    badge.textContent = count;
                    badge.style.display = 'inline-flex';
                } else {
                    badge.style.display = 'none';
                }
            }

            function buildFilterChips(joinMode, joinD1, joinD2, expMode, expV1, expV2, expInText, qualText) {
                var chips = document.getElementById('advFilterChips');
                if (!chips) return;
                chips.innerHTML = '';
                var count = 0;

                function addChip(text, clearFn) {
                    count++;
                    var c = document.createElement('span');
                    c.style.cssText = 'background:#ede9fe;color:#4f46e5;border-radius:20px;padding:3px 10px;font-size:0.78rem;font-weight:600;display:inline-flex;align-items:center;gap:5px;';
                    c.innerHTML = text + ' <span onclick="' + clearFn + '" style="cursor:pointer;font-size:0.9rem;opacity:0.7;">&times;</span>';
                    chips.appendChild(c);
                }

                if (joinMode === 'before' && joinD1) addChip('<i class="fas fa-calendar-alt"></i> Joined before ' + joinD1, 'clearJoinFilter()');
                else if (joinMode === 'after' && joinD1) addChip('<i class="fas fa-calendar-alt"></i> Joined after ' + joinD1, 'clearJoinFilter()');
                else if (joinMode === 'exact' && joinD1) addChip('<i class="fas fa-calendar-alt"></i> Joined on ' + joinD1, 'clearJoinFilter()');
                else if (joinMode === 'between' && joinD1 && joinD2) addChip('<i class="fas fa-calendar-alt"></i> Joined ' + joinD1 + ' – ' + joinD2, 'clearJoinFilter()');

                if (expMode === 'lt' && expV1 !== '') addChip('<i class="fas fa-briefcase"></i> Exp &lt; ' + expV1 + ' yr(s)', 'clearExpFilter()');
                else if (expMode === 'gt' && expV1 !== '') addChip('<i class="fas fa-briefcase"></i> Exp &gt; ' + expV1 + ' yr(s)', 'clearExpFilter()');
                else if (expMode === 'exact' && expV1 !== '') addChip('<i class="fas fa-briefcase"></i> Exp = ' + expV1 + ' yr(s)', 'clearExpFilter()');
                else if (expMode === 'between' && expV1 !== '' && expV2 !== '') addChip('<i class="fas fa-briefcase"></i> Exp ' + expV1 + '–' + expV2 + ' yr(s)', 'clearExpFilter()');

                if (qualText) addChip('<i class="fas fa-graduation-cap"></i> Qual: "' + qualText + '"', 'clearQualFilter()');
                if (expInText) addChip('<i class="fas fa-tasks"></i> Exp In: "' + expInText + '"', 'clearExpInFilter()');

                chips.style.display = count > 0 ? 'flex' : 'none';
                updateAdvFilterBadge(count);
            }

            function clearJoinFilter() {
                document.getElementById('advJoinMode').value = '';
                toggleJoinDateInputs();
                applyAdvancedFilters();
            }
            function clearExpFilter() {
                document.getElementById('advExpMode').value = '';
                toggleExpInputs();
                applyAdvancedFilters();
            }
            function clearQualFilter() {
                document.getElementById('advQualText').value = '';
                applyAdvancedFilters();
            }
            function clearExpInFilter() {
                document.getElementById('advExpInText').value = '';
                applyAdvancedFilters();
            }

            function clearAdvancedFilters() {
                document.getElementById('advJoinMode').value = '';
                document.getElementById('advJoinDate1').value = '';
                document.getElementById('advJoinDate2').value = '';
                document.getElementById('advExpMode').value = '';
                document.getElementById('advExpVal1').value = '';
                document.getElementById('advExpVal2').value = '';
                document.getElementById('advQualText').value = '';
                document.getElementById('advExpInText').value = '';
                toggleJoinDateInputs();
                toggleExpInputs();
                applyAdvancedFilters();
            }

            function applyAdvancedFilters() {
                filterEmployees();
            }

            // ── Main unified filter function ──────────────────────────────────────────
            function filterEmployees() {
                var txtSearch = document.getElementById('<%= txtSearch.ClientID %>');
                var gv = document.getElementById('<%= gvEmployees.ClientID %>');
                if (!gv) return;

                // Text search input
                var searchInput = txtSearch ? txtSearch.value.toLowerCase().trim() : '';

                // Advanced: Join Date
                var joinMode = document.getElementById('advJoinMode') ? document.getElementById('advJoinMode').value : '';
                var joinD1Str = document.getElementById('advJoinDate1') ? document.getElementById('advJoinDate1').value : '';
                var joinD2Str = document.getElementById('advJoinDate2') ? document.getElementById('advJoinDate2').value : '';
                var joinD1 = joinD1Str ? new Date(joinD1Str) : null;
                var joinD2 = joinD2Str ? new Date(joinD2Str) : null;

                // Advanced: Experience Years
                var expMode = document.getElementById('advExpMode') ? document.getElementById('advExpMode').value : '';
                var expV1 = document.getElementById('advExpVal1') ? document.getElementById('advExpVal1').value : '';
                var expV2 = document.getElementById('advExpVal2') ? document.getElementById('advExpVal2').value : '';

                // Advanced: Qualification keyword(s)
                var qualRaw = document.getElementById('advQualText') ? document.getElementById('advQualText').value.trim() : '';
                var qualKeys = qualRaw ? qualRaw.toLowerCase().split(',').map(function (k) { return k.trim(); }).filter(function (k) { return k.length > 0; }) : [];

                // Advanced: Experience In keyword(s)
                var expInRaw = document.getElementById('advExpInText') ? document.getElementById('advExpInText').value.trim() : '';
                var expInKeys = expInRaw ? expInRaw.toLowerCase().split(',').map(function (k) { return k.trim(); }).filter(function (k) { return k.length > 0; }) : [];

                // Build active-filter chips
                buildFilterChips(joinMode, joinD1Str, joinD2Str, expMode, expV1, expV2, expInRaw, qualRaw);

                var rows = gv.querySelectorAll('tr:not(:first-child)');
                var sNo = 1;

                rows.forEach(function (row) {
                    var masterCell = row.cells[1];
                    var idCell = row.cells[2];
                    var nameCell = row.cells[3];

                    var show = true;

                    // ── 1. Text search ────────────────────────────────────────────
                    if (searchInput && idCell && nameCell) {
                        var masterText = masterCell ? masterCell.textContent.toLowerCase() : '';
                        var idText = idCell.textContent.toLowerCase();
                        var nameText = nameCell.textContent.toLowerCase();
                        if (!masterText.includes(searchInput) && !idText.includes(searchInput) && !nameText.includes(searchInput)) {
                            show = false;
                        }
                    }

                    // ── 2. Join Date filter ───────────────────────────────────────
                    if (show && joinMode && joinD1) {
                        var rowDateStr = row.getAttribute('data-joindate'); // "yyyy-MM-dd"
                        if (rowDateStr) {
                            var rowDate = new Date(rowDateStr);
                            if (joinMode === 'before' && !(rowDate < joinD1)) show = false;
                            else if (joinMode === 'after' && !(rowDate > joinD1)) show = false;
                            else if (joinMode === 'exact' && rowDateStr !== joinD1Str) show = false;
                            else if (joinMode === 'between' && joinD2 && !(rowDate >= joinD1 && rowDate <= joinD2)) show = false;
                        } else {
                            show = false; // no join date = no match
                        }
                    }

                    // ── 3. Experience (Years) filter ──────────────────────────────
                    if (show && expMode && expV1 !== '') {
                        var rowExpStr = row.getAttribute('data-experience');
                        if (rowExpStr !== null && rowExpStr !== '') {
                            var rowExp = parseFloat(rowExpStr);
                            var filterV1 = parseFloat(expV1);
                            var filterV2 = expV2 !== '' ? parseFloat(expV2) : null;
                            if (expMode === 'lt' && !(rowExp < filterV1)) show = false;
                            else if (expMode === 'gt' && !(rowExp > filterV1)) show = false;
                            else if (expMode === 'exact' && rowExp !== filterV1) show = false;
                            else if (expMode === 'between' && filterV2 !== null && !(rowExp >= filterV1 && rowExp <= filterV2)) show = false;
                        } else {
                            show = false; // no experience value = no match
                        }
                    }

                    // ── 4. Qualification keyword search ───────────────────────────
                    if (show && qualKeys.length > 0) {
                        var rowQual = (row.getAttribute('data-qualification') || '').toLowerCase();
                        var allMatch = qualKeys.every(function (kw) { return rowQual.indexOf(kw) !== -1; });
                        if (!allMatch) show = false;
                    }

                    // ── 5. Experience In keyword search ───────────────────────────
                    if (show && expInKeys.length > 0) {
                        var rowExpIn = (row.getAttribute('data-experiencein') || '').toLowerCase();
                        var allMatch = expInKeys.every(function (kw) { return rowExpIn.indexOf(kw) !== -1; });
                        if (!allMatch) show = false;
                    }

                    // ── Apply visibility ──────────────────────────────────────────
                    row.style.display = show ? '' : 'none';
                    if (show && row.cells[0]) row.cells[0].textContent = sNo++;
                });
            }



            function formatDateDisplay(dateStr) {
                if (!dateStr) return '';
                var parts = dateStr.split('-');
                if (parts.length !== 3) return dateStr;
                var year = parts[0];
                var monthIndex = parseInt(parts[1], 10) - 1;
                var day = parts[2];
                var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                var monthName = months[monthIndex] || parts[1];
                return day + '-' + monthName + '-' + year;
            }

            function handleStatusChange(ddl) {
                var val = ddl.value;
                var row = ddl.closest('tr');
                var hfResignDate = row.querySelector('input[id*="hfResignDate"]');
                var hfStatus = row.querySelector('input[id*="hfStatus"]');
                var hfEngStartDate = row.querySelector('input[id*="hfEngStartDate"]');
                var currentEngStart = hfEngStartDate ? hfEngStartDate.value : '';

                if (hfStatus.value === 'Resigned' && (val === 'Upgraded' || val === 'Downgraded' || val === 'Transferred')) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Invalid Action',
                        text: 'A resigned employee cannot be upgraded, downgraded, or transferred. They must rejoin first.',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#3b82f6'
                    }).then(() => {
                        ddl.value = hfStatus.value || 'Active';
                    });
                    return;
                }

                if ((val === 'Active' && hfStatus.value !== 'Upgraded' && hfStatus.value !== 'Downgraded' && hfStatus.value !== 'Transferred') || val === 'ContractEnded') {
                    ddl.value = hfStatus.value || 'Active';
                    return;
                }

                // Reset hidden inputs
                document.getElementById('<%= hfChangeCategory.ClientID %>').value = "";
                document.getElementById('<%= hfChangeDate.ClientID %>').value = "";

                if (val === 'Resigned') {
                    Swal.fire({
                        title: 'Confirm Resignation',
                        html: `
                        <div style="text-align: left;">
                            <p style="font-size: 0.95rem; color: #64748b; margin-bottom: 15px;">Please specify the date of resignation for this employee. This action will terminate their current active engagement.</p>
                            <div class="form-group mb-3">
                                <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Resignation Date *</label>
                                <input type="date" id="swalResignDate" class="form-control" value="${new Date().toISOString().split('T')[0]}" style="font-weight: 600;" />
                            </div>
                        </div>
                    `,
                        showCancelButton: true,
                        confirmButtonText: 'Confirm Resignation',
                        confirmButtonColor: '#ef4444',
                        cancelButtonText: 'Cancel',
                        preConfirm: () => {
                            var resignDate = Swal.getPopup().querySelector('#swalResignDate').value;
                            if (!resignDate) {
                                Swal.showValidationMessage('Please select a resignation date');
                                return false;
                            }
                            return { resignDate: resignDate };
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            hfResignDate.value = result.value.resignDate;
                            __doPostBack(ddl.name, '');
                        } else {
                            ddl.value = hfStatus.value || 'Active';
                        }
                    });
                } else if (val === 'Upgraded' || val === 'Downgraded') {
                    var currentCat = row.cells[5].textContent.trim(); // Category column is at cell index 5

                    var optionsHtml = '<option value="">-- Select Category --</option>';
                    var hasOptions = false;
                    if (val === 'Upgraded') {
                        if (currentCat === 'Unskilled') {
                            optionsHtml += '<option value="Semi-Skilled">Semi-Skilled</option>';
                            optionsHtml += '<option value="Skilled">Skilled</option>';
                            hasOptions = true;
                        } else if (currentCat === 'Semi-Skilled') {
                            optionsHtml += '<option value="Skilled">Skilled</option>';
                            hasOptions = true;
                        }
                    } else if (val === 'Downgraded') {
                        if (currentCat === 'Skilled') {
                            optionsHtml += '<option value="Semi-Skilled">Semi-Skilled</option>';
                            optionsHtml += '<option value="Unskilled">Unskilled</option>';
                            hasOptions = true;
                        } else if (currentCat === 'Semi-Skilled') {
                            optionsHtml += '<option value="Unskilled">Unskilled</option>';
                            hasOptions = true;
                        }
                    }

                    if (!hasOptions) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Invalid Action',
                            text: `Employee cannot be ${val.toLowerCase()} because they are already ${currentCat}.`,
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3b82f6'
                        }).then(() => {
                            ddl.value = hfStatus.value || 'Active';
                        });
                        return;
                    }

                    var currentEmpId = row.cells[2].textContent.trim(); // Employee ID is at cell index 2
                    var titleText = val === 'Upgraded' ? 'Promote/Upgrade Employee' : 'Demote/Downgrade Employee';
                    var confirmText = val === 'Upgraded' ? 'Confirm Upgrade' : 'Confirm Downgrade';
                    var confirmColor = val === 'Upgraded' ? '#3b82f6' : '#f59e0b';

                    var htmlContent = `
                    <div style="text-align: left;">
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Current Category</label>
                            <input class="form-control bg-light" value="${currentCat}" readonly disabled style="font-weight: 600;" />
                        </div>
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">New Category *</label>
                            <select id="swalNewCat" class="form-control" style="font-weight: 600;">
                                ${optionsHtml}
                            </select>
                        </div>
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">New Employee ID under New Category *</label>
                            <input type="text" id="swalNewEmpId" class="form-control" value="${currentEmpId}" style="font-weight: 600;" />
                        </div>
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Effective Date *</label>
                            <input type="date" id="swalChangeDate" class="form-control" value="${new Date().toISOString().split('T')[0]}" style="font-weight: 600;" />
                        </div>
                    </div>
                `;

                    Swal.fire({
                        title: titleText,
                        html: htmlContent,
                        showCancelButton: true,
                        confirmButtonText: confirmText,
                        confirmButtonColor: confirmColor,
                        preConfirm: () => {
                            var newCat = Swal.getPopup().querySelector('#swalNewCat').value;
                            var changeDate = Swal.getPopup().querySelector('#swalChangeDate').value;
                            var newEmpId = Swal.getPopup().querySelector('#swalNewEmpId').value.trim();
                            if (!newCat || !changeDate || !newEmpId) {
                                Swal.showValidationMessage('Please select a category, date, and enter a new Employee ID');
                                return false;
                            }

                            var rank = { 'Unskilled': 1, 'Semi-Skilled': 2, 'Skilled': 3 };
                            var oldRank = rank[currentCat] || 0;
                            var newRank = rank[newCat] || 0;

                            if (val === 'Upgraded' && newRank <= oldRank) {
                                Swal.showValidationMessage('Upgrade category must be higher than current category (' + currentCat + ')');
                                return false;
                            }
                            if (val === 'Downgraded' && newRank >= oldRank) {
                                Swal.showValidationMessage('Downgrade category must be lower than current category (' + currentCat + ')');
                                return false;
                            }
                            if (currentEngStart && changeDate <= currentEngStart) {
                                Swal.showValidationMessage('Effective date must be after the current engagement start date (' + formatDateDisplay(currentEngStart) + ')');
                                return false;
                            }

                            return { newCat: newCat, changeDate: changeDate, newEmpId: newEmpId };
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            document.getElementById('<%= hfChangeCategory.ClientID %>').value = result.value.newCat;
                            document.getElementById('<%= hfChangeDate.ClientID %>').value = result.value.changeDate;
                            document.getElementById('<%= hfChangeEmpId.ClientID %>').value = result.value.newEmpId;
                            __doPostBack(ddl.name, '');
                        } else {
                            ddl.value = hfStatus.value || 'Active';
                        }
                    });
                } else if (val === 'Transferred') {
                    var currentDept = row.cells[4].textContent.trim(); // Department is at cell index 4

                    // Build options by copying from ddlDept select element
                    var deptSelect = document.getElementById('<%= ddlDept.ClientID %>');
                    var optionsHtml = '';
                    if (deptSelect) {
                        for (var i = 0; i < deptSelect.options.length; i++) {
                            var opt = deptSelect.options[i];
                            if (opt.value && opt.value !== currentDept) {
                                optionsHtml += '<option value="' + opt.value + '">' + opt.text + '</option>';
                            }
                        }
                    }

                    if (!optionsHtml) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Invalid Action',
                            text: 'No other directorates available for transfer.',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3b82f6'
                        }).then(() => {
                            ddl.value = hfStatus.value || 'Active';
                        });
                        return;
                    }

                    var htmlContent = `
                    <div style="text-align: left;">
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Current Directorate</label>
                            <input class="form-control bg-light" value="${currentDept}" readonly disabled style="font-weight: 600;" />
                        </div>
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">New Directorate *</label>
                            <select id="swalNewDept" class="form-control" style="font-weight: 600;">
                                <option value="">-- Select Directorate --</option>
                                ${optionsHtml}
                            </select>
                        </div>
                        <div class="form-group mb-3">
                            <label class="font-weight-bold mb-1" style="font-size: 0.9rem; color: #475569;">Effective Date *</label>
                            <input type="date" id="swalChangeDate" class="form-control" value="${new Date().toISOString().split('T')[0]}" style="font-weight: 600;" />
                        </div>
                    </div>
                `;

                    Swal.fire({
                        title: 'Transfer Directorate',
                        html: htmlContent,
                        showCancelButton: true,
                        confirmButtonText: 'Confirm Transfer',
                        confirmButtonColor: '#8b5cf6',
                        preConfirm: () => {
                            var newDept = Swal.getPopup().querySelector('#swalNewDept').value;
                            var changeDate = Swal.getPopup().querySelector('#swalChangeDate').value;
                            if (!newDept || !changeDate) {
                                Swal.showValidationMessage('Please select a directorate and effective date');
                                return false;
                            }
                            if (currentEngStart && changeDate <= currentEngStart) {
                                Swal.showValidationMessage('Effective date must be after the current engagement start date (' + formatDateDisplay(currentEngStart) + ')');
                                return false;
                            }
                            return { newDept: newDept, changeDate: changeDate };
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            document.getElementById('<%= hfChangeDivision.ClientID %>').value = result.value.newDept;
                            document.getElementById('<%= hfChangeDate.ClientID %>').value = result.value.changeDate;
                            __doPostBack(ddl.name, '');
                        } else {
                            ddl.value = hfStatus.value || 'Active';
                        }
                    });
                } else {
                    hfResignDate.value = "";
                    __doPostBack(ddl.name, '');
                }
            }

            var currentEmpSortCol = '';
            var currentEmpSortDir = 'none';

            function initGridViewSorting() {
                var gv = document.getElementById('<%= gvEmployees.ClientID %>');
                if (!gv) return;
                var headerRow = gv.rows[0];
                if (!headerRow) return;

                // Columns to make sortable: index and key
                var sortableCols = [
                    { index: 1, key: 'MasterId' },
                    { index: 2, key: 'ID' },
                    { index: 3, key: 'Name' },
                    { index: 4, key: 'Department' },
                    { index: 5, key: 'Category' },
                    { index: 6, key: 'JoinDate' }
                ];

                // Store original index on each row
                var rows = gv.querySelectorAll('tr:not(:first-child)');
                rows.forEach(function (row, idx) {
                    row.setAttribute('data-orig-index', idx);
                });

                sortableCols.forEach(function (col) {
                    var cell = headerRow.cells[col.index];
                    if (!cell) return;

                    cell.classList.add('sortable-header');
                    cell.style.cursor = 'pointer';
                    cell.style.userSelect = 'none';

                    // Add icon container
                    var span = document.createElement('span');
                    span.className = 'sort-icon ml-1';
                    span.style.color = '#94a3b8';
                    span.style.fontSize = '0.75rem';
                    span.innerHTML = '<i class="fas fa-sort"></i>';
                    cell.appendChild(span);

                    cell.onclick = function () {
                        toggleEmpSort(col.key, col.index);
                    };
                });
            }

            function toggleEmpSort(key, colIndex) {
                var gv = document.getElementById('<%= gvEmployees.ClientID %>');
                if (!gv) return;
                var headerRow = gv.rows[0];
                if (!headerRow) return;

                // Update sort variables
                if (currentEmpSortCol === key) {
                    if (currentEmpSortDir === 'asc') {
                        currentEmpSortDir = 'desc';
                    } else if (currentEmpSortDir === 'desc') {
                        currentEmpSortCol = '';
                        currentEmpSortDir = 'none';
                    } else {
                        currentEmpSortDir = 'asc';
                    }
                } else {
                    currentEmpSortCol = key;
                    currentEmpSortDir = 'asc';
                }

                // Update icons
                var sortableCols = [
                    { index: 1, key: 'MasterId' },
                    { index: 2, key: 'ID' },
                    { index: 3, key: 'Name' },
                    { index: 4, key: 'Department' },
                    { index: 5, key: 'Category' },
                    { index: 6, key: 'JoinDate' }
                ];

                sortableCols.forEach(function (col) {
                    var cell = headerRow.cells[col.index];
                    if (!cell) return;
                    var icon = cell.querySelector('.sort-icon i');
                    if (!icon) return;

                    if (col.key === currentEmpSortCol) {
                        cell.querySelector('.sort-icon').style.color = '#4f46e5';
                        if (currentEmpSortDir === 'asc') {
                            icon.className = 'fas fa-sort-up';
                        } else if (currentEmpSortDir === 'desc') {
                            icon.className = 'fas fa-sort-down';
                        } else {
                            icon.className = 'fas fa-sort';
                            cell.querySelector('.sort-icon').style.color = '#94a3b8';
                        }
                    } else {
                        icon.className = 'fas fa-sort';
                        cell.querySelector('.sort-icon').style.color = '#94a3b8';
                    }
                });

                // Get all rows
                var tbody = gv.getElementsByTagName('tbody')[0] || gv;
                var rows = Array.from(gv.querySelectorAll('tr:not(:first-child)'));

                // Sort the rows
                if (currentEmpSortCol !== '') {
                    rows.sort(function (a, b) {
                        var cellA = a.cells[colIndex];
                        var cellB = b.cells[colIndex];
                        var valA = '', valB = '';

                        if (key === 'JoinDate') {
                            valA = a.getAttribute('data-joindate') || '';
                            valB = b.getAttribute('data-joindate') || '';
                        } else if (key === 'Name') {
                            var lnkA = cellA.querySelector('.emp-name-link');
                            var lnkB = cellB.querySelector('.emp-name-link');
                            valA = lnkA ? lnkA.textContent : cellA.textContent;
                            valB = lnkB ? lnkB.textContent : cellB.textContent;
                        } else {
                            valA = cellA ? cellA.textContent : '';
                            valB = cellB ? cellB.textContent : '';
                        }

                        valA = valA.trim().toLowerCase();
                        valB = valB.trim().toLowerCase();

                        // Try numeric sort
                        if (key === 'ID' || key === 'MasterId') {
                            var numA = parseFloat(valA);
                            var numB = parseFloat(valB);
                            if (!isNaN(numA) && !isNaN(numB)) {
                                return currentEmpSortDir === 'asc' ? numA - numB : numB - numA;
                            }
                        }

                        if (valA < valB) return currentEmpSortDir === 'asc' ? -1 : 1;
                        if (valA > valB) return currentEmpSortDir === 'asc' ? 1 : -1;
                        return 0;
                    });
                } else {
                    rows.sort(function (a, b) {
                        var indexA = parseInt(a.getAttribute('data-orig-index') || '0', 10);
                        var indexB = parseInt(b.getAttribute('data-orig-index') || '0', 10);
                        return indexA - indexB;
                    });
                }

                // Append sorted rows back to tbody
                rows.forEach(function (row) {
                    tbody.appendChild(row);
                });

                // Re-apply filtering to update S.No. and search match visibility
                filterEmployees();
            }

            document.addEventListener('DOMContentLoaded', initGridViewSorting);
        </script>
    </asp:Content>