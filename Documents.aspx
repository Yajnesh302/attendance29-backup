<%@ Page Title="Documents" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Documents.aspx.cs" Inherits="AttendanceApp.Documents" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
        Documents & Certificates
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
        <script src="Static/js/xlsx.full.min.js?v=1.2.0"></script>
        <style>
            .control-panel-card {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                border: 1px solid #e2e8f0;
                padding: 24px;
                margin-bottom: 24px;
            }

            .filter-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 16px;
                margin-bottom: 16px;
            }

            .form-label-bold {
                font-weight: 700;
                color: #334155;
                font-size: 0.85rem;
                margin-bottom: 6px;
                display: block;
            }

            .form-control-custom {
                height: 38px !important;
                font-size: 0.9rem;
                border-radius: 6px;
                border: 1px solid #cbd5e1;
                color: #1e293b;
                font-weight: 500;
                width: 100%;
                padding: 6px 12px;
                box-sizing: border-box;
                background-color: #f8fafc;
            }

            .form-control-custom:focus {
                border-color: #4f46e5;
                box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
                background-color: #ffffff;
                outline: none;
            }

            /* Checkbox Toggles block */
            .settings-section-title {
                font-size: 0.8rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                color: #64748b;
                margin-bottom: 10px;
                border-bottom: 1px solid #f1f5f9;
                padding-bottom: 4px;
            }

            .checkbox-group {
                display: flex;
                flex-wrap: wrap;
                gap: 12px 20px;
                margin-bottom: 16px;
            }

            .checkbox-item {
                display: inline-flex;
                align-items: center;
                font-size: 0.88rem;
                font-weight: 600;
                color: #475569;
                cursor: pointer;
                user-select: none;
            }

            .checkbox-item input[type="checkbox"] {
                margin-right: 8px;
                width: 16px;
                height: 16px;
                accent-color: #4f46e5;
                cursor: pointer;
            }

            .btn-action-container {
                display: flex;
                gap: 12px;
                justify-content: flex-end;
                margin-top: 16px;
                border-top: 1px solid #f1f5f9;
                padding-top: 16px;
            }

            .settings-info-panel {
                color: #64748b;
                font-size: 0.78rem;
                line-height: 1.5;
                background-color: #f8fafc;
                padding: 10px;
                border-radius: 6px;
                border: 1px solid #e2e8f0;
                width: 100%;
                box-sizing: border-box;
            }

            .settings-parameter-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 16px;
                margin-bottom: 16px;
                background-color: #f8fafc;
                padding: 16px;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }

            /* Local dark theme overrides to prevent browser cache issues */
            html.theme-dark .settings-parameter-grid {
                background-color: #1e2233 !important;
                border-color: #2d3348 !important;
            }

            html.theme-dark .settings-info-panel {
                background-color: #1e2233 !important;
                border-color: #2d3348 !important;
                color: #cbd5e1 !important;
            }

            /* Placeholders Drawer styling */

            .placeholders-drawer {
                position: fixed;
                top: 0;
                right: -400px;
                width: 380px;
                height: 100vh;
                background-color: #ffffff;
                box-shadow: -10px 0 30px rgba(0, 0, 0, 0.1);
                border-left: 1px solid #e2e8f0;
                z-index: 100000;
                transition: right 0.35s cubic-bezier(0.4, 0, 0.2, 1);
                display: flex;
                flex-direction: column;
            }

            .placeholders-drawer.open {
                right: 0;
            }

            .drawer-header {
                padding: 20px;
                border-bottom: 1px solid #f1f5f9;
                display: flex;
                align-items: center;
                justify-content: space-between;
                background-color: #f8fafc;
            }

            .drawer-content {
                padding: 20px;
                overflow-y: auto;
                flex: 1;
            }

            .drawer-close-btn {
                background: none;
                border: none;
                font-size: 1.5rem;
                font-weight: 700;
                color: #64748b;
                cursor: pointer;
                line-height: 1;
                padding: 4px 8px;
                border-radius: 4px;
                transition: all 0.15s ease;
            }

            .drawer-close-btn:hover {
                background-color: #e2e8f0;
                color: #0f172a;
            }

            .drawer-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100vw;
                height: 100vh;
                background-color: rgba(15, 23, 42, 0.4);
                backdrop-filter: blur(2px);
                z-index: 99999;
                display: none;
            }

            html.theme-dark .placeholders-drawer {
                background-color: #161922 !important;
                border-left-color: #2d3348 !important;
                box-shadow: -10px 0 30px rgba(0, 0, 0, 0.5) !important;
            }

            html.theme-dark .drawer-header {
                background-color: #1e2233 !important;
                border-bottom-color: #2d3348 !important;
            }

            html.theme-dark .drawer-close-btn:hover {
                background-color: #2d3348 !important;
                color: #f1f5f9 !important;
            }

            html.theme-dark .drawer-overlay {
                background-color: rgba(0, 0, 0, 0.6) !important;
            }

            .btn-custom {
                height: 38px;
                padding: 0 20px;
                font-size: 0.9rem;
                font-weight: 700;
                border-radius: 6px;
                border: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
                transition: all 0.15s ease;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            }

            .btn-custom:hover {
                transform: translateY(-1px);
            }

            .btn-load {
                background-color: #4f46e5;
                color: white;
            }

            .btn-load:hover {
                background-color: #3730a3;
                box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
            }

            .btn-print {
                background-color: #10b981;
                color: white;
            }

            .btn-print:hover {
                background-color: #059669;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
            }

            .btn-excel {
                background-color: #f59e0b;
                color: white;
            }

            .btn-excel:hover {
                background-color: #d97706;
                box-shadow: 0 4px 12px rgba(245, 158, 11, 0.25);
            }

            /* ── Preview sheet styling (A4 representation) ── */
            .preview-container {
                background-color: #f1f5f9;
                padding: 30px 10px;
                border-radius: 12px;
                border: 1px dashed #cbd5e1;
                margin-top: 20px;
            }

            .preview-sheet {
                background: white;
                padding: 60px 50px;
                border-radius: 8px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
                max-width: 1050px;
                margin: 0 auto;
                color: #000000 !important;
                font-family: 'Times New Roman', Times, serif;
                min-height: 800px;
                border: 1px solid #e2e8f0;
                box-sizing: border-box;
            }

            .sheet-editable-hdr {
                text-align: center;
                margin-bottom: 24px;
                outline: none;
                padding: 4px;
                border-radius: 4px;
                transition: background 0.15s;
            }

            .sheet-editable-hdr:hover {
                background-color: #f8fafc;
                box-shadow: 0 0 0 1px #cbd5e1;
            }

            .sheet-editable-hdr:focus {
                background-color: #ffffff;
                box-shadow: 0 0 0 2px #4f46e5;
            }

            .sheet-title {
                font-size: 1.85rem;
                font-weight: bold;
                letter-spacing: 0.12em;
                margin-bottom: 20px;
                text-transform: uppercase;
            }

            .sheet-desc {
                font-size: 1.08rem;
                line-height: 1.7;
                text-align: justify;
                margin-bottom: 12px;
            }

            #repTitle1,
            #repTitle2 {
                font-size: 14pt !important;
                font-weight: bold !important;
                text-align: center !important;
                text-transform: none !important;
                letter-spacing: normal !important;
                line-height: 1.5 !important;
            }

            /* Attendance certificate: top two sentences centred at 14pt */
            #certDesc1,
            #certDesc2 {
                font-size: 14pt !important;
                text-align: center !important;
                line-height: 1.6 !important;
            }

            .sat-paragraph-wrap {
                margin-bottom: 24px;
                font-size: 1.15rem;
                line-height: 1.8;
                text-align: left;
            }

            .cov-paragraph-wrap {
                margin-bottom: 50px;
                text-align: left;
                text-indent: 48px;
                line-height: 1.6;
            }


            /* Certificate Table layout */
            .table-cert-print {
                width: 100%;
                border-collapse: collapse !important;
                margin: 24px 0;
                font-size: 1.15rem;
                color: #000 !important;
                border: 1.5px solid #000000 !important;
                table-layout: fixed !important;
            }

            .table-cert-print th,
            #certTable th,
            #reportTable th {
                border: 1.5px solid #000000 !important;
                padding: 5px 8px !important;
                font-weight: bold;
                text-transform: uppercase;
                font-size: 1.0rem;
                background-color: #f8fafc !important;
                text-align: center;
                vertical-align: middle;
                white-space: normal !important;
                word-wrap: break-word !important;
                overflow-wrap: break-word !important;
                word-break: break-word !important;
            }

            .table-cert-print td,
            #certTable td,
            #reportTable td {
                border: 1px solid #000000 !important;
                padding: 5px 8px !important;
                text-align: center;
                vertical-align: middle;
                outline: none;
                word-wrap: break-word !important;
                overflow-wrap: break-word !important;
            }

            .table-cert-print td:focus {
                background-color: #eff6ff !important;
                box-shadow: inset 0 0 0 2px #3b82f6;
            }

            .table-cert-print td.text-left {
                text-align: left;
            }

            /* Column widths for screen */
            .table-cert-print .col-sno,
            .table-cert-print .rep-col-sno {
                width: 5%;
            }

            .table-cert-print .col-id,
            .table-cert-print .rep-col-id {
                width: 5%;
            }

            .table-cert-print .col-name,
            .table-cert-print .rep-col-name {
                width: 27%;
                text-align: left;
            }

            .table-cert-print .col-final,
            .table-cert-print .rep-col-final {
                width: 9%;
            }

            .table-cert-print .col-paid,
            .table-cert-print .rep-col-paid {
                width: 7%;
            }

            .table-cert-print .col-unpaid,
            .table-cert-print .rep-col-unpaid {
                width: 8%;
            }

            .table-cert-print .col-satcut,
            .table-cert-print .rep-col-satcut {
                width: 8%;
            }

            .table-cert-print .col-remarks,
            .table-cert-print .rep-col-remarks {
                width: 31%;
                text-align: left;
            }



            #wagesTable {
                border: 1px solid #000000 !important;
                border-collapse: collapse !important;
            }

            #wagesTable th,
            #wagesTable td {
                border: 1px solid #000000 !important;
            }

            /* Signatures block */
            .signature-section {
                display: flex;
                justify-content: space-between;
                margin-top: 80px;
                padding: 0 16px;
            }

            .sig-block {
                text-align: center;
                width: 280px;
                border-top: 1.5px solid #000000;
                padding-top: 8px;
                font-size: 0.9rem;
                font-weight: bold;
                outline: none;
                border-radius: 4px;
            }

            .sig-block:hover {
                background-color: #f8fafc;
                box-shadow: 0 0 0 1px #cbd5e1;
            }

            .sig-block:focus {
                background-color: #ffffff;
                box-shadow: 0 0 0 2px #4f46e5;
            }

            /* Global Toast Styles */
            #toast-container {
                position: fixed;
                top: 24px;
                right: 24px;
                display: flex;
                flex-direction: column;
                gap: 12px;
                z-index: 200000 !important;
                pointer-events: none;
            }

            .modern-toast {
                display: flex;
                align-items: center;
                gap: 14px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(12px) saturate(180%);
                border-radius: 12px;
                padding: 14px 20px;
                min-width: 320px;
                max-width: 420px;
                color: #1e293b;
                font-size: 0.92rem;
                font-weight: 600;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), inset 0 0 0 1px rgba(255, 255, 255, 0.5);
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
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .toast-success {
                border-left-color: #10b981;
                background: rgba(240, 253, 250, 0.98);
            }

            .toast-success .toast-icon {
                color: #10b981;
            }

            .toast-warning {
                border-left-color: #f59e0b;
                background: rgba(255, 251, 235, 0.98);
            }

            .toast-warning .toast-icon {
                color: #f59e0b;
            }

            .toast-error {
                border-left-color: #ef4444;
                background: rgba(254, 242, 242, 0.98);
            }

            .toast-error .toast-icon {
                color: #ef4444;
            }

            .toast-close-btn {
                background: transparent;
                border: none;
                color: #94a3b8;
                cursor: pointer;
                font-size: 1.2rem;
                margin-left: auto;
                line-height: 1;
            }

            /* Loader block */
            #previewLoader {
                display: none;
                text-align: center;
                padding: 60px;
                color: #4f46e5;
                font-weight: bold;
            }

            /* ── Document Hub Grid Styling ── */
            .hub-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 20px;
                margin-bottom: 24px;
            }

            .hub-card {
                background: white;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                padding: 24px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
                cursor: pointer;
                transition: all 0.2s ease-in-out;
                display: flex;
                flex-direction: column;
                position: relative;
                text-decoration: none !important;
                box-sizing: border-box;
            }

            .hub-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 20px rgba(79, 70, 229, 0.08);
                border-color: #4f46e5;
            }

            .hub-card-icon {
                width: 46px;
                height: 46px;
                border-radius: 10px;
                background: rgba(79, 70, 229, 0.08);
                color: #4f46e5;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.3rem;
                margin-bottom: 16px;
                transition: all 0.2s ease;
            }

            .hub-card:hover .hub-card-icon {
                background: #4f46e5;
                color: white;
            }

            .hub-card-title {
                font-size: 1.05rem;
                font-weight: 700;
                color: #1e293b;
                margin-bottom: 8px;
            }

            .hub-card-desc {
                font-size: 0.84rem;
                color: #64748b;
                line-height: 1.5;
                margin-bottom: 20px;
                flex-grow: 1;
            }

            .hub-card-btn {
                font-size: 0.84rem;
                font-weight: 700;
                color: #4f46e5;
                display: inline-flex;
                align-items: center;
                gap: 4px;
            }

            .hub-card.disabled {
                cursor: not-allowed;
                opacity: 0.65;
                background: #f8fafc;
                border-color: #cbd5e1;
            }

            .hub-card.disabled:hover {
                transform: none;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
                border-color: #cbd5e1;
            }

            .hub-card.disabled .hub-card-icon {
                background: #e2e8f0;
                color: #94a3b8;
            }

            .hub-card-badge {
                position: absolute;
                top: 12px;
                right: 12px;
                background: #e2e8f0;
                color: #475569;
                font-size: 0.68rem;
                font-weight: 700;
                padding: 2px 8px;
                border-radius: 20px;
                text-transform: uppercase;
            }

            /* ── Print Media Styles ── */
            @media print {
                @page {
                    size: A4 portrait;
                    margin: 6mm 10mm;
                }

                html,
                body,
                form,
                #wrapper,
                #content-wrapper,
                #content,
                .container-main {
                    background: white !important;
                    background-color: white !important;
                    color: black !important;
                    border: none !important;
                    box-shadow: none !important;
                    padding: 0 !important;
                    margin: 0 !important;
                }

                .app-sidebar,
                .navbar-custom,
                .container-main>h2,
                .container-main>hr,
                .control-panel-card,
                #toast-container,
                .btn-print-hide {
                    display: none !important;
                }

                .container-main {
                    padding: 0 !important;
                    margin: 0 !important;
                    background-color: transparent !important;
                }

                .preview-container {
                    background: transparent !important;
                    border: none !important;
                    padding: 0 !important;
                    margin: 0 !important;
                    box-shadow: none !important;
                }

                #printSheet,
                #reportPrintSheet {
                    border: none !important;
                    box-shadow: none !important;
                    padding: 0 !important;
                    margin: 0 !important;
                    width: 100% !important;
                    max-width: 100% !important;
                }

                #satisfactoryPrintSheet {
                    border: none !important;
                    box-shadow: none !important;
                    padding: 40px 50px !important;
                    margin: 0 auto !important;
                    width: 100% !important;
                    max-width: 100% !important;
                    box-sizing: border-box !important;
                    background: white !important;
                    font-size: 14pt !important;
                    line-height: 1.8 !important;
                }

                .sat-header-img-wrap {
                    margin-bottom: 25pt !important;
                }

                .sat-date-wrap {
                    margin-bottom: 25pt !important;
                }

                .sat-title-wrap {
                    margin-bottom: 25pt !important;
                    font-size: 14pt !important;
                }

                .sat-paragraph-wrap {
                    margin-bottom: 25pt !important;
                    font-size: 14pt !important;
                    line-height: 1.8 !important;
                    text-align: justify !important;
                }

                #satParagraph3.sat-paragraph-wrap {
                    margin-bottom: 50pt !important;
                }

                .sat-sig-wrap {
                    margin-top: 0 !important;
                }

                #coveringLetterPrintSheet {
                    border: none !important;
                    box-shadow: none !important;
                    padding: 40px 50px !important;
                    margin: 0 auto !important;
                    width: 100% !important;
                    max-width: 100% !important;
                    box-sizing: border-box !important;
                    background: white !important;
                    font-family: Arial, Helvetica, sans-serif !important;
                    font-size: 1.15rem !important;
                    line-height: 1.8 !important;
                }

                #wagesPrintSheet {
                    border: none !important;
                    box-shadow: none !important;
                    padding: 40px 50px !important;
                    margin: 0 auto !important;
                    width: 100% !important;
                    max-width: 100% !important;
                    box-sizing: border-box !important;
                    background: transparent !important;
                }

                /* Hide the signature section on print */
                .signature-section {
                    display: none !important;
                }

                /* Shrink typography and margins to fit on a single page */
                .sheet-title {
                    font-size: 1.3rem !important;
                    margin-bottom: 8px !important;
                }

                .sheet-desc {
                    font-size: 0.85rem !important;
                    margin-bottom: 4px !important;
                    line-height: 1.4 !important;
                    text-align: justify !important;
                }

                /* Attendance certificate: keep top sentences centred and 14pt on print */
                #certDesc1,
                #certDesc2 {
                    font-size: 14pt !important;
                    text-align: center !important;
                    line-height: 1.6 !important;
                }

                /* Style and shrink table for print to fit 50 rows on page 1 */
                .table-cert-print {
                    margin: 4px 0 !important;
                    font-size: 11.5pt !important;
                    border-collapse: collapse !important;
                    border: 1.5px solid #000000 !important;
                    width: 100% !important;
                    table-layout: fixed !important;
                }

                /* Explicit column widths for print (sum to 100%) */
                .table-cert-print .col-sno,
                .table-cert-print .rep-col-sno {
                    width: 5% !important;
                }

                .table-cert-print .col-id,
                .table-cert-print .rep-col-id {
                    width: 5% !important;
                }

                .table-cert-print .col-name,
                .table-cert-print .rep-col-name {
                    width: 27% !important;
                    text-align: left !important;
                }

                .table-cert-print .col-final,
                .table-cert-print .rep-col-final {
                    width: 9% !important;
                }

                .table-cert-print .col-paid,
                .table-cert-print .rep-col-paid {
                    width: 7% !important;
                }

                .table-cert-print .col-unpaid,
                .table-cert-print .rep-col-unpaid {
                    width: 8% !important;
                }

                .table-cert-print .col-satcut,
                .table-cert-print .rep-col-satcut {
                    width: 8% !important;
                }

                .table-cert-print .col-remarks,
                .table-cert-print .rep-col-remarks {
                    width: 31% !important;
                    text-align: left !important;
                }

                .table-cert-print th,
                #certTable th,
                #reportTable th {
                    font-size: 11.5pt !important;
                    font-weight: bold !important;
                    background-color: #f1f5f9 !important;
                    padding: 3px 5px !important;
                    white-space: normal !important;
                    word-wrap: break-word !important;
                    overflow-wrap: break-word !important;
                    word-break: break-word !important;
                }

                .table-cert-print th,
                #certTable th,
                #reportTable th,
                .table-cert-print td,
                #certTable td,
                #reportTable td {
                    padding: 1.5px 3.5px !important;
                    border: 1.5px solid #000000 !important;
                    /* Force solid thick borders on print */
                    line-height: 1.1 !important;
                    -webkit-print-color-adjust: exact !important;
                    print-color-adjust: exact !important;
                    word-wrap: break-word !important;
                    overflow-wrap: break-word !important;
                }

                #wagesTable {
                    border: 1.5px solid #000000 !important;
                    border-collapse: collapse !important;
                }

                #wagesTable th,
                #wagesTable td {
                    border: 1px solid #000000 !important;
                    padding: 6px 8px !important;
                    -webkit-print-color-adjust: exact !important;
                    print-color-adjust: exact !important;
                }
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <div id="toast-container"></div>

        <h2 class="mb-0 text-dark font-weight-bold btn-print-hide" id="pageMainHeader">Document Hub</h2>
        <hr class="btn-print-hide" style="border-color:#e2e8f0; margin-bottom: 24px;" />

        <!-- Document Selection Hub -->
        <div id="documentHubView" class="btn-print-hide">
            <h5 class="text-dark font-weight-bold mb-3" style="color: #475569;"><i
                    class="fas fa-file-alt mr-2 text-primary"></i>Document Generators</h5>
            <div class="hub-grid mb-4">
                <div class="hub-card" onclick="selectDocument('attendance-cert')">
                    <div class="hub-card-icon"><i class="fas fa-file-signature"></i></div>
                    <h5 class="hub-card-title">Attendance Certificate</h5>
                    <p class="hub-card-desc">Generate monthly attendance certificates for GeM contract vendors including
                        leaves, Saturday cuts, and auto-remarks.</p>
                    <span class="hub-card-btn">Open Generator <i class="fas fa-arrow-right ml-1"></i></span>
                </div>

                <div class="hub-card" onclick="selectDocument('satisfactory-cert')">
                    <div class="hub-card-icon"><i class="fas fa-clipboard-check"></i></div>
                    <h5 class="hub-card-title">Satisfactory Certificate</h5>
                    <p class="hub-card-desc">Generate monthly contractor satisfactory performance certificates with
                        custom headers, employee counts, and signatories.</p>
                    <span class="hub-card-btn">Open Generator <i class="fas fa-arrow-right ml-1"></i></span>
                </div>

                <div class="hub-card" onclick="selectDocument('covering-letter')">
                    <div class="hub-card-icon"><i class="fas fa-envelope-open-text"></i></div>
                    <h5 class="hub-card-title">Covering Letter</h5>
                    <p class="hub-card-desc">Generate monthly contractor covering letters with dynamically compiled
                        reference numbers, subjects, body paragraphs, and recipients.</p>
                    <span class="hub-card-btn">Open Generator <i class="fas fa-arrow-right ml-1"></i></span>
                </div>

                <div class="hub-card" onclick="selectDocument('wages-calc')">
                    <div class="hub-card-icon" style="background: rgba(245, 158, 11, 0.1); color: #f59e0b;"><i
                            class="fas fa-calculator"></i></div>
                    <h5 class="hub-card-title">Wages Calculation</h5>
                    <p class="hub-card-desc">Generate contractor monthly wages bill calculation statement with daily
                        wage rate group totals, EPF capping, service charges, and GST.</p>
                    <span class="hub-card-btn">Open Generator <i class="fas fa-arrow-right ml-1"></i></span>
                </div>

                <div class="hub-card" onclick="selectDocument('attendance-report')">
                    <div class="hub-card-icon" style="background: rgba(14, 165, 233, 0.1); color: #0ea5e9;"><i
                            class="fas fa-file-invoice"></i></div>
                    <h5 class="hub-card-title">Attendance Report</h5>
                    <p class="hub-card-desc">Generate monthly attendance reports with custom 2-line header templates,
                        selectable columns, and automatic stint/remarks details.</p>
                    <span class="hub-card-btn">Open Generator <i class="fas fa-arrow-right ml-1"></i></span>
                </div>
            </div>

            <h5 class="text-dark font-weight-bold mb-3 mt-4" style="color: #475569;"><i
                    class="fas fa-cog mr-2 text-secondary"></i>Administration</h5>
            <div class="hub-grid">
                <div class="hub-card" onclick="selectDocument('template-settings')">
                    <div class="hub-card-icon" style="background: rgba(99, 102, 241, 0.1); color: #6366f1;"><i
                            class="fas fa-sliders-h"></i></div>
                    <h5 class="hub-card-title">Template Settings</h5>
                    <p class="hub-card-desc">Manage global word sentence templates, paragraph layouts, header lines, and
                        placeholders across all documents in one place.</p>
                    <span class="hub-card-btn">Open Settings <i class="fas fa-arrow-right ml-1"></i></span>
                </div>
            </div>
        </div>

        <!-- Attendance Report Workspace -->
        <div id="attendanceReportWorkspace" style="display: none;">
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="goBackToHub()"
                style="background-color: #64748b; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Back to Document Hub
            </button>

            <!-- Control panel card -->
            <div class="control-panel-card btn-print-hide">
                <h5 class="font-weight-bold text-dark mb-3"><i class="fas fa-sliders-h mr-2 text-primary"></i>Attendance
                    Report Configuration</h5>

                <div class="filter-grid">
                    <div>
                        <label class="form-label-bold">Year</label>
                        <select id="repYear" class="form-control-custom" onchange="onReportFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Month</label>
                        <select id="repMonth" class="form-control-custom" onchange="onReportFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Category</label>
                        <select id="repCategory" class="form-control-custom" onchange="onReportFilterChange()"></select>
                    </div>
                    <div id="repContractGroup" style="display: none;">
                        <label class="form-label-bold">Contract Period</label>
                        <select id="repContract" class="form-control-custom"
                            onchange="onReportContractChange()"></select>
                    </div>
                    <div id="repDatedOnGroup" style="display: none;">
                        <label class="form-label-bold">Dated On (Editable)</label>
                        <input type="text" id="repDatedOnInput" class="form-control-custom"
                            oninput="onRepTemplateSelectChange()" />
                    </div>
                </div>

                <!-- Templates and Headers Settings -->
                <div class="settings-section-title mt-4">Heading Layout Settings</div>
                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Template Layout</label>
                        <select id="repTemplateSelect" class="form-control-custom"
                            onchange="onRepTemplateSelectChange()">
                            <option value="tpl1">Template 1: Worker Attendance Report</option>
                            <option value="tpl2">Template 2: Performance Summary Statement</option>
                        </select>
                    </div>
                    <div style="grid-column: span 2;">
                        <label class="form-label-bold">Heading Line 1 (Editable)</label>
                        <input type="text" id="repHeadingLine1" class="form-control-custom"
                            oninput="updateReportHeaderPreview()" />
                    </div>
                </div>
                <div class="filter-grid mt-2">
                    <div style="grid-column: span 3;">
                        <label class="form-label-bold">Heading Line 2 (Editable)</label>
                        <input type="text" id="repHeadingLine2" class="form-control-custom"
                            oninput="updateReportHeaderPreview()" />
                    </div>
                </div>

                <!-- Columns Checklist -->
                <div class="settings-section-title mt-4">Select Columns to Display</div>
                <div class="checkbox-group">
                    <label class="checkbox-item"><input type="checkbox" id="repColSNo" checked
                            onchange="toggleReportColumn('rep-col-sno', this.checked)" /> Sl.No</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColID"
                            onchange="toggleReportColumn('rep-col-id', this.checked)" /> ID</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColMasterID"
                            onchange="toggleReportColumn('rep-col-masterid', this.checked)" /> Master ID</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColName" checked
                            onchange="toggleReportColumn('rep-col-name', this.checked)" /> Employee Name</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColPresent" checked
                            onchange="toggleReportColumn('rep-col-present', this.checked)" /> Present Days</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColFinal"
                            onchange="toggleReportColumn('rep-col-final', this.checked)" /> Total Days</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColPaid"
                            onchange="toggleReportColumn('rep-col-paid', this.checked)" /> Paid Leaves</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColUnpaid"
                            onchange="toggleReportColumn('rep-col-unpaid', this.checked)" /> Unpaid Leaves</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColSatCut"
                            onchange="toggleReportColumn('rep-col-satcut', this.checked)" /> Saturday Cut</label>
                    <label class="checkbox-item"><input type="checkbox" id="repColRemarks" checked
                            onchange="toggleReportColumn('rep-col-remarks', this.checked)" /> Remarks</label>
                </div>

                <!-- Auto-Remarks Checklist -->
                <div class="settings-section-title mt-2">Auto-Remarks Options</div>
                <div class="checkbox-group">
                    <label class="checkbox-item"><input type="checkbox" id="repRemJoinResign" checked
                            onchange="rebuildReportRemarksColumn()" /> Auto-include Join/Resign Dates</label>
                    <label class="checkbox-item"><input type="checkbox" id="repRemOverride"
                            onchange="rebuildReportRemarksColumn()" /> Auto-include Overrides Reason</label>
                    <label class="checkbox-item"><input type="checkbox" id="repRemPairs"
                            onchange="rebuildReportRemarksColumn()" /> Auto-include Leave Pair Remarks</label>
                    <label class="checkbox-item"><input type="checkbox" id="repRemSatEdit"
                            onchange="rebuildReportRemarksColumn()" /> Auto-include Saturday Edit Remarks</label>
                    <label class="checkbox-item"><input type="checkbox" id="repRemCellSpecific"
                            onchange="rebuildReportRemarksColumn()" /> Auto-include Cell-Specific Remarks</label>
                </div>

                <!-- Buttons -->
                <div class="btn-action-container">
                    <button type="button" class="btn-custom btn-load" onclick="loadReportData()"><i
                            class="fas fa-sync-alt"></i> Load Data</button>
                    <button type="button" class="btn-custom btn-print" onclick="window.print()"><i
                            class="fas fa-print"></i> Print</button>
                    <button type="button" class="btn-custom btn-excel" onclick="exportReportToExcel()"><i
                            class="fas fa-file-excel"></i> Export Excel</button>
                </div>
            </div>

            <!-- Preview Container -->
            <div class="preview-container" id="reportPreviewArea" style="display: none;">
                <div class="preview-sheet" id="reportPrintSheet">

                    <!-- Document Headers -->
                    <div id="repTitle1" class="sheet-editable-hdr sheet-title" contenteditable="true"
                        style="margin-bottom: 8px;">
                        ATTENDANCE REPORT
                    </div>

                    <div id="repTitle2" class="sheet-editable-hdr sheet-desc" contenteditable="true"
                        style="font-weight: bold; margin-bottom: 20px; font-size: 0.95rem;">
                        Heading Line 2 Content
                    </div>

                    <!-- Employee table grid -->
                    <table class="table-cert-print" id="reportTable">
                        <thead>
                            <tr>
                                <th class="rep-col-sno">Sl.<br />No</th>
                                <th class="rep-col-id" style="display: none;">ID</th>
                                <th class="rep-col-masterid" style="display: none;">Master ID</th>
                                <th class="rep-col-name" style="text-align: left; padding-left: 20px;">Name</th>
                                <th class="rep-col-present">Present</th>
                                <th class="rep-col-final" style="display: none;">Total<br />Days</th>
                                <th class="rep-col-paid" style="display: none;">Paid</th>
                                <th class="rep-col-unpaid" style="display: none;">Unpaid</th>
                                <th class="rep-col-satcut" style="display: none;">Sat<br />Cut</th>
                                <th class="rep-col-remarks" style="text-align: left;">Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Populated dynamically via JS -->
                    </table>

                </div>
            </div>
        </div>

        <!-- Attendance Certificate Generator Workspace -->
        <div id="attendanceCertWorkspace" style="display: none;">
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="goBackToHub()"
                style="background-color: #64748b; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Back to Document Hub
            </button>

            <!-- Control panel card -->
            <div class="control-panel-card btn-print-hide">
                <h5 class="font-weight-bold text-dark mb-3"><i
                        class="fas fa-sliders-h mr-2 text-primary"></i>Configuration Panel</h5>

                <div class="filter-grid">
                    <div>
                        <label class="form-label-bold">Year</label>
                        <select id="year" class="form-control-custom" onchange="onFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Month</label>
                        <select id="month" class="form-control-custom" onchange="onFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Category</label>
                        <select id="category" class="form-control-custom" onchange="onFilterChange()"></select>
                    </div>
                    <div id="contractGroup" style="display: none;">
                        <label class="form-label-bold">Contract Period</label>
                        <select id="contract" class="form-control-custom" onchange="onContractChange()"></select>
                    </div>
                </div>

                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Vendor Name (Editable)</label>
                        <input type="text" id="vendorName" class="form-control-custom"
                            oninput="updateHeaderPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Vendor Address (Editable)</label>
                        <input type="text" id="vendorAddress" class="form-control-custom"
                            oninput="updateHeaderPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">GeM Contract No (Editable)</label>
                        <input type="text" id="gemContractNo" class="form-control-custom"
                            oninput="updateHeaderPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Contract Date (Editable)</label>
                        <input type="text" id="gemContractDate" class="form-control-custom"
                            oninput="updateHeaderPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Dated On (Editable)</label>
                        <input type="text" id="certDatedOnInput" class="form-control-custom"
                            oninput="updateHeaderPreview()" />
                    </div>
                </div>



                <!-- Columns Checklist -->
                <div class="settings-section-title mt-4">Select Columns to Display</div>
                <div class="checkbox-group">
                    <label class="checkbox-item"><input type="checkbox" id="colSNo" checked
                            onchange="toggleColumn('col-sno', this.checked)" /> Sl.No</label>
                    <label class="checkbox-item"><input type="checkbox" id="colID" checked
                            onchange="toggleColumn('col-id', this.checked)" /> ID</label>
                    <label class="checkbox-item"><input type="checkbox" id="colMasterID"
                            onchange="toggleColumn('col-masterid', this.checked)" /> Master ID</label>
                    <label class="checkbox-item"><input type="checkbox" id="colName" checked
                            onchange="toggleColumn('col-name', this.checked)" /> Employee Name</label>
                    <label class="checkbox-item"><input type="checkbox" id="colPresent"
                            onchange="toggleColumn('col-present', this.checked)" /> Present Days</label>
                    <label class="checkbox-item"><input type="checkbox" id="colFinal" checked
                            onchange="toggleColumn('col-final', this.checked)" /> Total Days</label>
                    <label class="checkbox-item"><input type="checkbox" id="colPaid" checked
                            onchange="toggleColumn('col-paid', this.checked)" /> Paid Leaves</label>
                    <label class="checkbox-item"><input type="checkbox" id="colUnpaid" checked
                            onchange="toggleColumn('col-unpaid', this.checked)" /> Unpaid Leaves</label>
                    <label class="checkbox-item"><input type="checkbox" id="colSatCut" checked
                            onchange="toggleColumn('col-satcut', this.checked)" /> Saturday Cut</label>
                    <label class="checkbox-item"><input type="checkbox" id="colRemarks" checked
                            onchange="toggleColumn('col-remarks', this.checked)" /> Remarks</label>
                </div>

                <!-- Auto-Remarks Checklist -->
                <div class="settings-section-title mt-2">Auto-Remarks Builder Options</div>
                <div class="checkbox-group">
                    <label class="checkbox-item"><input type="checkbox" id="remJoinResign" checked
                            onchange="rebuildRemarksColumn()" /> Auto-include Join/Resign Dates</label>
                    <label class="checkbox-item"><input type="checkbox" id="remOverride" checked
                            onchange="rebuildRemarksColumn()" /> Auto-include Overrides Reason</label>
                    <label class="checkbox-item"><input type="checkbox" id="remPairs" checked
                            onchange="rebuildRemarksColumn()" /> Auto-include Leave Pair Remarks</label>
                    <label class="checkbox-item"><input type="checkbox" id="remSatEdit" checked
                            onchange="rebuildRemarksColumn()" /> Auto-include Saturday Edit Remarks</label>
                    <label class="checkbox-item"><input type="checkbox" id="remCellSpecific" checked
                            onchange="rebuildRemarksColumn()" /> Auto-include Cell-Specific Remarks</label>
                </div>

                <!-- Buttons -->
                <div class="btn-action-container">
                    <button type="button" class="btn-custom btn-load" onclick="loadData()"><i
                            class="fas fa-sync-alt"></i> Load Data</button>
                    <button type="button" class="btn-custom btn-print" onclick="window.print()"><i
                            class="fas fa-print"></i> Print</button>
                    <button type="button" class="btn-custom btn-excel" onclick="exportToExcel()"><i
                            class="fas fa-file-excel"></i> Export Excel</button>
                </div>
            </div>

            <!-- Loader -->
            <div id="previewLoader">
                <i class="fas fa-spinner fa-spin fa-3x"></i>
                <div class="mt-3">Fetching attendance data and rendering certificate...</div>
            </div>

            <!-- Preview Container -->
            <div class="preview-container" id="previewArea" style="display: none;">
                <div class="preview-sheet" id="printSheet">

                    <!-- Document Headers -->
                    <div id="certTitle" class="sheet-editable-hdr sheet-title" contenteditable="true">
                        CERTIFICATE
                    </div>

                    <div id="certDesc1" class="sheet-editable-hdr sheet-desc" contenteditable="true">
                        This is certify that DEO (Skilled) under GeM Contract No: GEMC-511687761569464, dated:
                        17-Oct-2025
                    </div>

                    <div id="certDesc2" class="sheet-editable-hdr sheet-desc" contenteditable="true">
                        M/s. VISHAL MANPOWER & SECURITY CONSULTANTS, Mangalore worked as following, for the period from
                        01-May-2026 to 31-May-2026
                    </div>

                    <!-- Employee table grid -->
                    <table class="table-cert-print" id="certTable">
                        <thead>
                            <tr>
                                <th class="col-sno">Sl.<br />No</th>
                                <th class="col-id">ID</th>
                                <th class="col-masterid" style="display: none;">Master ID</th>
                                <th class="col-name" style="text-align: left; padding-left: 20px;">Name</th>
                                <th class="col-present" style="display: none;">Present</th>
                                <th class="col-final">Total<br />Days</th>
                                <th class="col-paid">Paid</th>
                                <th class="col-unpaid">Unpaid</th>
                                <th class="col-satcut">Sat<br />Cut</th>
                                <th class="col-remarks" style="text-align: left;">Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Populated dynamically via JS -->
                        </tbody>
                    </table>

                    <!-- Signature block -->
                    <div class="signature-section">
                        <div class="sig-block" contenteditable="true">
                            Signature of Contractor /<br />Vendor Representative
                        </div>
                        <div class="sig-block" contenteditable="true">
                            Controlling Officer /<br />Authorized Signature
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <!-- Satisfactory Certificate Generator Workspace -->
        <div id="satisfactoryCertWorkspace" style="display: none;">
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="goBackToHub()"
                style="background-color: #64748b; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Back to Document Hub
            </button>

            <!-- Control panel card -->
            <div class="control-panel-card btn-print-hide">
                <h5 class="font-weight-bold text-dark mb-3"><i
                        class="fas fa-sliders-h mr-2 text-primary"></i>Satisfactory Certificate Configuration</h5>

                <div class="filter-grid">
                    <div>
                        <label class="form-label-bold">Year</label>
                        <select id="satYear" class="form-control-custom" onchange="onSatFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Month</label>
                        <select id="satMonth" class="form-control-custom" onchange="onSatFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Category</label>
                        <select id="satCategory" class="form-control-custom" onchange="onSatFilterChange()"></select>
                    </div>
                    <div id="satContractGroup" style="display: none;">
                        <label class="form-label-bold">Contract Period</label>
                        <select id="satContract" class="form-control-custom" onchange="onSatContractChange()"></select>
                    </div>
                </div>

                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Vendor Name (Editable)</label>
                        <input type="text" id="satVendorNameInput" class="form-control-custom"
                            oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Vendor Address (Editable)</label>
                        <input type="text" id="satVendorAddressInput" class="form-control-custom"
                            oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">GeM Contract No (Editable)</label>
                        <input type="text" id="satGemNoInput" class="form-control-custom"
                            oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Contract Date (Editable)</label>
                        <input type="text" id="satContractDateInput" class="form-control-custom"
                            oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Dated On (Editable)</label>
                        <input type="text" id="satDatedOnInput" class="form-control-custom"
                            oninput="updateSatPreview()" />
                    </div>
                </div>

                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Contract Duration/Period (e.g. Two years)</label>
                        <input type="text" id="satDurationInput" class="form-control-custom" value="Two years"
                            oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">w.e.f. Date (e.g. 24 Oct 2025)</label>
                        <input type="text" id="satWefInput" class="form-control-custom" oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Services Description</label>
                        <input type="text" id="satServicesInput" class="form-control-custom"
                            value="Human Resource Outsourcing Services" oninput="updateSatPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Employee Count</label>
                        <input type="number" id="satEmpCountInput" class="form-control-custom"
                            oninput="updateSatPreview()" />
                    </div>
                </div>


                <!-- Buttons -->
                <div class="btn-action-container">
                    <button type="button" class="btn-custom btn-load" onclick="loadSatData()"><i
                            class="fas fa-sync-alt"></i> Load Data</button>
                    <button type="button" class="btn-custom btn-print" onclick="window.print()"><i
                            class="fas fa-print"></i> Print</button>
                    <button type="button" class="btn-custom"
                        style="background: linear-gradient(135deg, #10b981, #059669); color: #fff;"
                        onclick="downloadSatAsDoc()"><i class="fas fa-file-word"></i> Download as DOC</button>
                </div>
            </div>

            <!-- Loader -->
            <div id="satPreviewLoader"
                style="display: none; text-align: center; padding: 60px; color: #4f46e5; font-weight: bold;">
                <i class="fas fa-spinner fa-spin fa-3x"></i>
                <div class="mt-3">Fetching contract details and rendering certificate...</div>
            </div>

            <!-- Preview Container -->
            <div class="preview-container" id="satPreviewArea" style="display: none;">
                <div class="preview-sheet" id="satisfactoryPrintSheet"
                    style="font-family: Arial, Helvetica, sans-serif; color: #000000; font-size: 14pt; line-height: 1.8; text-align: left; padding: 50px 70px;">
                    <!-- Header Image -->
                    <div class="sat-header-img-wrap" style="text-align: center; margin-bottom: 25pt;">
                        <img id="satPreviewHeaderImage" src="Static/images/satisfactory_header.png"
                            style="width: 100%; display: block;" />
                    </div>

                    <!-- Date -->
                    <div class="sat-date-wrap" style="text-align: right; margin-bottom: 25pt; font-weight: bold;">
                        Date: &nbsp;&nbsp;&nbsp;&nbsp;<span id="satPreviewDate" contenteditable="true">July 2026</span>
                    </div>

                    <!-- Title -->
                    <div class="sat-title-wrap"
                        style="text-align: center; margin-bottom: 25pt; font-weight: bold; font-size: 14pt; text-decoration: underline; letter-spacing: 0.05em;">
                        SATISFACTORY CERTIFICATE
                    </div>

                    <!-- Paragraph 1 -->
                    <div id="satParagraph1" class="sat-paragraph-wrap" style="margin-bottom: 25pt; text-align: justify;"
                        contenteditable="true">
                        This is to certify that M/s. <b>[Vendor Name]</b>, [Vendor Address] is engaged as an Industry
                        Partner in our Establishment to provide Services towards <b>[Services Description]</b> for a
                        period of [Period] w.e.f. [w.e.f. Date] against GeM Contract No. <b>[GeM Contract No]</b> dated
                        [Contract Date].
                    </div>

                    <!-- Paragraph 2 -->
                    <div id="satParagraph2" class="sat-paragraph-wrap" style="margin-bottom: 25pt; text-align: justify;"
                        contenteditable="true">
                        The Industry Partner provided <b>[Count]</b> Contract Employees and found working
                        satisfactorily.
                    </div>

                    <!-- Paragraph 3 (2 blank lines before signatory) -->
                    <div id="satParagraph3" class="sat-paragraph-wrap" style="margin-bottom: 50pt; text-align: justify;"
                        contenteditable="true">
                        The service provided by the Industry Partner from [Start Date] to [End Date] is found
                        satisfactory.
                    </div>

                    <!-- Signatory Block -->
                    <div class="sat-sig-wrap" style="text-align: right;">
                        <div class="sat-sig-inner" style="display: inline-block; text-align: center;">
                            <div id="satPreviewSignatory" contenteditable="true" style="font-weight: bold;">(Raajita B
                                Reddy)</div>
                            <div id="satPreviewDesignation" contenteditable="true">Scientist 'F'</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Covering Letter Generator Workspace -->
        <div id="coveringLetterWorkspace" style="display: none;">
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="goBackToHub()"
                style="background-color: #64748b; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Back to Document Hub
            </button>

            <!-- Control panel card -->
            <div class="control-panel-card btn-print-hide">
                <h5 class="font-weight-bold text-dark mb-3"><i class="fas fa-sliders-h mr-2 text-primary"></i>Covering
                    Letter Configuration</h5>

                <div class="filter-grid">
                    <div>
                        <label class="form-label-bold">Year</label>
                        <select id="covYear" class="form-control-custom" onchange="onCovFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Month</label>
                        <select id="covMonth" class="form-control-custom" onchange="onCovFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Category</label>
                        <select id="covCategory" class="form-control-custom" onchange="onCovFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Directorate</label>
                        <select id="covDivision" class="form-control-custom" onchange="onCovFilterChange()"></select>
                    </div>
                    <div id="covContractGroup" style="display: none;">
                        <label class="form-label-bold">Contract Period</label>
                        <select id="covContract" class="form-control-custom" onchange="onCovContractChange()"></select>
                    </div>
                </div>

                <div class="btn-action-container">
                    <button type="button" class="btn-custom btn-print" onclick="window.print()"><i
                            class="fas fa-print"></i> Print</button>
                    <button type="button" class="btn-custom btn-excel" onclick="downloadCovAsDoc()"
                        style="background-color: #3b82f6; color: white;"><i class="fas fa-file-word"></i> Download
                        Word</button>
                </div>
            </div>

            <!-- Preview Container -->
            <div class="preview-container" id="covPreviewArea" style="display: none;">
                <div class="preview-sheet" id="coveringLetterPrintSheet"
                    style="font-family: Arial, Helvetica, sans-serif; color: #000000; font-size: 1.15rem; line-height: 1.8; text-align: left; padding: 50px 70px;">
                    <!-- Internal Phone Line -->
                    <div class="cov-phone-wrap" style="text-align: left; margin-bottom: 12px;">
                        Phone No (Internal): <span id="covPreviewPhone" contenteditable="true">2312</span>
                    </div>

                    <!-- Ref Number & Date Block -->
                    <div class="cov-ref-date-wrap"
                        style="display: flex; justify-content: space-between; margin-bottom: 30px;">
                        <div>No: <span id="covPreviewRefNo" contenteditable="true">49805/HRD/HM/2026</span></div>
                        <div style="font-weight: bold;"><span id="covPreviewDate" contenteditable="true">June
                                2026</span></div>
                    </div>

                    <!-- Division Name -->
                    <div class="cov-division-wrap" style="text-align: center; font-weight: bold; margin-bottom: 10px;">
                        <span id="covPreviewDivision" contenteditable="true">D-KRM</span>
                    </div>

                    <!-- Subject Title -->
                    <div class="cov-subject-wrap"
                        style="text-align: center; font-weight: bold; margin-bottom: 24px; text-transform: uppercase;">
                        <span id="covPreviewSubject" contenteditable="true">HIRING OF MANPOWER SERVICES</span>
                    </div>

                    <!-- Body Paragraph -->
                    <div id="covParagraph" class="cov-paragraph-wrap"
                        style="margin-bottom: 50px; text-align: left; text-indent: 48px; line-height: 1.6;"
                        contenteditable="true">
                        The copies of the Attendance report along with the wage calculation for skilled category
                        Contract Employees from M/s. Vishal Manpower & Security Consultants, Mangalore for the period of
                        01st May 2026 to 31st May 2026 is enclosed. This is for purpose of their payment processing
                        please.
                    </div>

                    <!-- Signatory Section -->
                    <div class="cov-sig-wrap"
                        style="margin-top: 60px; margin-bottom: 60px; text-align: right; line-height: 1.5;">
                        <div class="cov-sig-inner" style="display: inline-block; text-align: center;">
                            <div id="covPreviewSignatory" contenteditable="true" style="font-weight: bold;">Usha Nandini
                                AA</div>
                            <div id="covPreviewDesignation" contenteditable="true">TO C</div>
                            <div id="covPreviewAuthority" contenteditable="true">For GD, D-KRM</div>
                        </div>
                    </div>

                    <!-- Recipient Section -->
                    <div id="covRecipient" class="cov-recipient-wrap"
                        style="text-align: left; line-height: 1.5; font-weight: bold; margin-top: 40px;"
                        contenteditable="true">
                        To,<br />D-FMM/Purchase
                    </div>
                </div>
            </div>
        </div>

        <!-- Wages Calculation Workspace -->
        <div id="wagesCalcWorkspace" style="display: none;">
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="goBackToHub()"
                style="background-color: #64748b; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Back to Document Hub
            </button>

            <!-- Control panel card -->
            <div class="control-panel-card btn-print-hide">
                <h5 class="font-weight-bold text-dark mb-3"><i class="fas fa-sliders-h mr-2 text-primary"></i>Wages
                    Calculation Configuration</h5>

                <div class="filter-grid">
                    <div>
                        <label class="form-label-bold">Year</label>
                        <select id="wagesYear" class="form-control-custom" onchange="onWagesFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Month</label>
                        <select id="wagesMonth" class="form-control-custom" onchange="onWagesFilterChange()"></select>
                    </div>
                    <div>
                        <label class="form-label-bold">Category</label>
                        <select id="wagesCategory" class="form-control-custom"
                            onchange="onWagesFilterChange()"></select>
                    </div>
                    <div id="wagesContractGroup" style="display: none;">
                        <label class="form-label-bold">Contract Period</label>
                        <select id="wagesContract" class="form-control-custom"
                            onchange="onWagesContractChange()"></select>
                    </div>
                </div>

                <!-- Parameters Grid -->
                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Daily Wage Rate (Rs)</label>
                        <input type="number" id="wagesDailyRate" class="form-control-custom" step="any" readonly="readonly" style="background-color: #f1f5f9; cursor: not-allowed;"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">EPF Rate (%)</label>
                        <input type="number" id="wagesEpfRate" class="form-control-custom" step="any" value="13" readonly="readonly" style="background-color: #f1f5f9; cursor: not-allowed;"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">EPF Wage Limit (Rs)</label>
                        <input type="number" id="wagesEpfLimit" class="form-control-custom" step="any" value="15000" readonly="readonly" style="background-color: #f1f5f9; cursor: not-allowed;"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">EPF Capped Amount (Rs)</label>
                        <input type="number" id="wagesEpfCappedAmount" class="form-control-custom" step="any"
                            value="1950" readonly="readonly" style="background-color: #f1f5f9; cursor: not-allowed;" oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Service Charge (%)</label>
                        <input type="number" id="wagesServiceChargeRate" class="form-control-custom" step="any"
                            value="3.85" oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">GST (%)</label>
                        <input type="number" id="wagesGstRate" class="form-control-custom" step="any" value="18" readonly="readonly" style="background-color: #f1f5f9; cursor: not-allowed;"
                            oninput="updateWagesPreview()" />
                    </div>
                </div>

                <!-- Wages Header Placeholders (Editable) -->
                <div class="filter-grid mt-2"
                    style="border-top: 1px solid #e2e8f0; padding-top: 12px; margin-top: 12px;">
                    <div>
                        <label class="form-label-bold">Contract No (Editable)</label>
                        <input type="text" id="wagesContractNoInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Contract Date (Editable)</label>
                        <input type="text" id="wagesContractDateInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Extra Code (Editable)</label>
                        <input type="text" id="wagesExtraCodeInput" class="form-control-custom" value="(2GM0286/KRMD)"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Dated On (Editable)</label>
                        <input type="text" id="wagesDatedOnInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                </div>

                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Category Desc (Editable)</label>
                        <input type="text" id="wagesCategoryDescInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Contract Period (Editable)</label>
                        <input type="text" id="wagesPeriodInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                </div>

                <div class="filter-grid mt-2">
                    <div>
                        <label class="form-label-bold">Vendor Name (Editable)</label>
                        <input type="text" id="wagesVendorNameInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                    <div>
                        <label class="form-label-bold">Vendor Address (Editable)</label>
                        <input type="text" id="wagesVendorAddressInput" class="form-control-custom"
                            oninput="updateWagesPreview()" />
                    </div>
                </div>



                <div class="btn-action-container mt-3">
                    <button type="button" class="btn-custom btn-load" onclick="loadWagesData()"><i
                            class="fas fa-sync-alt"></i> Load Data</button>
                    <button type="button" class="btn-custom btn-print" onclick="window.print()"><i
                            class="fas fa-print"></i> Print</button>
                    <button type="button" class="btn-custom btn-excel" onclick="exportWagesToExcel()"><i
                            class="fas fa-file-excel"></i> Export Excel</button>
                </div>
            </div>

            <!-- Wages Loader -->
            <div id="wagesLoader"
                style="display: none; text-align: center; padding: 60px; color: #4f46e5; font-weight: bold;">
                <i class="fas fa-spinner fa-spin fa-3x"></i>
                <div class="mt-3">Fetching wages data and rendering statement...</div>
            </div>

            <!-- Preview Container -->
            <div class="preview-container" id="wagesPreviewArea" style="display: none;">
                <div class="preview-sheet" id="wagesPrintSheet"
                    style="font-family: Arial, Helvetica, sans-serif; color: #000000; font-size: 1.05rem; line-height: 1.6; text-align: left; padding: 40px 50px; background: white; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(0,0,0,0.05); max-width: 800px; margin: 0 auto 30px auto;">

                    <!-- Wages Calculation Header -->
                    <div
                        style="font-size: 0.95rem; line-height: 1.5; margin-bottom: 25px; font-weight: bold; text-align: center;">
                        <div id="wagesHeaderContract" style="margin-bottom: 4px;">Contract No.
                            [Contract No] Dt. [Contract Date]</div>
                        <div id="wagesHeaderCategory" style="margin-bottom: 4px;">Manpower
                            Services - [Category Name] - [People Count] No.s</div>
                        <div id="wagesHeaderPeriod" style="margin-bottom: 4px;">Contract Period
                            [Start Date] to [End Date]</div>
                        <div id="wagesHeaderVendor" style="margin-bottom: 4px;">[Vendor Name],
                            [Vendor Address]</div>
                        <div id="wagesHeaderPayment"
                            style="margin-bottom: 4px; border-bottom: 2px solid #000000; padding-bottom: 10px; font-size: 1rem;">
                            Payment for the period [Start Date] to [End Date]</div>
                    </div>

                    <!-- Wages Main Table -->
                    <table
                        style="width: 100%; border-collapse: collapse; margin-bottom: 25px; font-size: 0.95rem; border: 1px solid #000000;"
                        id="wagesTable">
                        <thead>
                            <tr style="background-color: #f8fafc; font-weight: bold; border-bottom: 2px solid #000000;">
                                <th style="border: 1px solid #000000; padding: 8px; text-align: center; width: 8%;">Sl No.</th>
                                <th style="border: 1px solid #000000; padding: 8px; text-align: left;">Description</th>
                                <th id="wagesColCHeader"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right; width: 22%;">Payment per person/per month Rs981/-PD</th>
                                <th style="border: 1px solid #000000; padding: 8px; text-align: center; width: 12%;">No of people</th>
                                <th style="border: 1px solid #000000; padding: 8px; text-align: center; width: 15%;">No of Days/Individual</th>
                                <th style="border: 1px solid #000000; padding: 8px; text-align: right; width: 22%;">Total No. of working days</th>
                            </tr>
                        </thead>
                        <tbody id="wagesTableBody">
                            <!-- Dynamic Rows -->
                        </tbody>
                        <tfoot>
                            <!-- Row 15: Footer Row (Total No of People & Total No of Days) -->
                            <tr style="font-weight: bold; border-top: 2px solid #000000; background-color: #f8fafc;">
                                <td colspan="2" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td style="border: 1px solid #000000; padding: 8px; text-align: right;">Total No of People</td>
                                <td id="wagesTotalPeople"
                                    style="border: 1px solid #000000; padding: 8px; text-align: center;">0</td>
                                <td style="border: 1px solid #000000; padding: 8px; text-align: center;">Total No of Days</td>
                                <td id="wagesTotalDays"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0</td>
                            </tr>
                            <!-- Row 16: Wages total calculation (981*1195) -->
                            <tr>
                                <td colspan="2" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td id="wagesFormulaDesc"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right; font-weight: bold;">Wages Total</td>
                                <td colspan="2" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td id="wagesAmountWages"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0.00</td>
                            </tr>
                            <!-- Row 17: EPF Capped (EPF @13%for 46 persons) -->
                            <tr>
                                <td colspan="3" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td id="wagesFormulaEpfCapped" colspan="2"
                                    style="border: 1px solid #000000; padding: 8px; text-align: left;">EPF @13% for 0 persons</td>
                                <td id="wagesAmountEpfCapped"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0.00</td>
                            </tr>
                            <!-- Row 18: EPF Actual (EPF @13%for 2 person) -->
                            <tr>
                                <td colspan="3" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td id="wagesFormulaEpfActual" colspan="2"
                                    style="border: 1px solid #000000; padding: 8px; text-align: left;">EPF @13% for 0 persons</td>
                                <td id="wagesAmountEpfActual"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0.00</td>
                            </tr>
                            <!-- Row 19: Sub Total -->
                            <tr style="font-weight: bold; background-color: #f8fafc;">
                                <td colspan="3" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td colspan="2" style="border: 1px solid #000000; padding: 8px; text-align: left;">Sub Total</td>
                                <td id="wagesAmountSubTotal"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0.00</td>
                            </tr>
                            <!-- Row 20: Service Charge -->
                            <tr>
                                <td colspan="3" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td id="wagesFormulaServiceCharge" colspan="2"
                                    style="border: 1px solid #000000; padding: 8px; text-align: left;">Service Charge @3.85%</td>
                                <td id="wagesAmountServiceCharge"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0.00</td>
                            </tr>
                            <!-- Row 21: GST -->
                            <tr>
                                <td colspan="4" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td id="wagesFormulaGst"
                                    style="border: 1px solid #000000; padding: 8px; text-align: center;">GST @18%</td>
                                <td id="wagesAmountGst"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right;">0.00</td>
                            </tr>
                            <!-- Row 22: Total Cost Per Month -->
                            <tr style="font-weight: bold; background-color: #f1f5f9; font-size: 1.05rem;">
                                <td colspan="3" style="border: 1px solid #000000; padding: 8px;"></td>
                                <td colspan="2" style="border: 1px solid #000000; padding: 8px; text-align: left;">Total Cost Per Month</td>
                                <td id="wagesAmountGrandTotal"
                                    style="border: 1px solid #000000; padding: 8px; text-align: right; color: #4f46e5;">0.00</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>

        <!-- Template Settings Workspace -->
        <div id="templateSettingsWorkspace" style="display: none;">
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="goBackToHub()"
                style="background-color: #64748b; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Back to Document Hub
            </button>
            <button type="button" class="btn-custom btn-print-hide mb-4" onclick="togglePlaceholdersDrawer()"
                style="background-color: #4f46e5; color: white; display: inline-flex; align-items: center; gap: 8px; margin-bottom: 20px; border: none; border-radius: 6px; padding: 0 16px; height: 38px; font-weight: 700; cursor: pointer; margin-left: 10px; transition: all 0.15s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <i class="fas fa-info-circle"></i> View Placeholders Guide
            </button>

            <div class="control-panel-card btn-print-hide" style="margin-top: 10px; margin-bottom: 0; width: 100%; box-sizing: border-box;">
                <h5 class="font-weight-bold text-dark mb-4"><i class="fas fa-sliders-h mr-2 text-primary"></i>Global
                    Document Templates</h5>

                <!-- Tabs Navigation -->
                <div class="template-tabs"
                    style="display: flex; flex-wrap: wrap; gap: 8px; border-bottom: 2px solid #e2e8f0; padding-bottom: 8px; margin-bottom: 24px;">
                    <button type="button" class="tab-btn active" onclick="switchTemplateTab(event, 'tab-attendance')"
                        style="padding: 8px 16px; font-weight: 700; border: none; background: none; color: #4f46e5; border-bottom: 2px solid #4f46e5; cursor: pointer; transition: all 0.15s ease;">Attendance
                        Certificate</button>
                    <button type="button" class="tab-btn" onclick="switchTemplateTab(event, 'tab-satisfactory')"
                        style="padding: 8px 16px; font-weight: 600; border: none; background: none; color: #64748b; cursor: pointer; transition: all 0.15s ease;">Satisfactory
                        Certificate</button>
                    <button type="button" class="tab-btn" onclick="switchTemplateTab(event, 'tab-covering')"
                        style="padding: 8px 16px; font-weight: 600; border: none; background: none; color: #64748b; cursor: pointer; transition: all 0.15s ease;">Covering
                        Letter</button>
                    <button type="button" class="tab-btn" onclick="switchTemplateTab(event, 'tab-wages')"
                        style="padding: 8px 16px; font-weight: 600; border: none; background: none; color: #64748b; cursor: pointer; transition: all 0.15s ease;">Wages
                        Calculation</button>
                    <button type="button" class="tab-btn" onclick="switchTemplateTab(event, 'tab-report')"
                        style="padding: 8px 16px; font-weight: 600; border: none; background: none; color: #64748b; cursor: pointer; transition: all 0.15s ease;">Attendance
                        Report</button>
                </div>

                <!-- Tab: Attendance Certificate -->
                <div id="tab-attendance" class="tab-content">
                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 16px; margin-bottom: 12px;">
                        <div>
                            <label class="form-label-bold">Sentence 1 Template</label>
                            <textarea id="txtTplDesc1" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateHeaderPreview()">This is certify that DEO ({Category}) under GeM Contract No: {ContractNo}, dated: {ContractDate}, Dated On: {DatedOn}</textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Sentence 2 Template</label>
                            <textarea id="txtTplDesc2" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateHeaderPreview()">M/s. {VendorName}, {VendorAddress} worked as following, for the period from {StartDate} to {EndDate}</textarea>

                        </div>
                    </div>
                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <button type="button" class="btn-custom btn-load"
                            style="background-color: #6366f1; color: white;" onclick="saveTpl()"><i
                                class="fas fa-save"></i> Save Attendance Templates</button>
                    </div>
                </div>

                <!-- Tab: Satisfactory Certificate -->
                <div id="tab-satisfactory" class="tab-content" style="display: none;">
                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 12px;">
                        <div>
                            <label class="form-label-bold">Paragraph 1 Template</label>
                            <textarea id="txtSatTplDesc1" class="form-control-custom"
                                style="height: 120px; min-height: 100px; resize: vertical;"
                                oninput="updateSatPreview()">This is to certify that M/s. <b>{VendorName}</b>, {VendorAddress} is engaged as an Industry Partner in our Establishment to provide Services towards <b>{Services}</b> for a period of {Duration} w.e.f. {WefDate} against GeM Contract No. <b>{ContractNo}</b> dated {ContractDate}, Dated On: {DatedOn}.</textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Paragraph 2 Template</label>
                            <textarea id="txtSatTplDesc2" class="form-control-custom"
                                style="height: 120px; min-height: 100px; resize: vertical;"
                                oninput="updateSatPreview()">The Industry Partner provided <b>{EmpCount}</b> Contract Employees and found working satisfactorily.</textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Paragraph 3 Template</label>
                            <textarea id="txtSatTplDesc3" class="form-control-custom"
                                style="height: 120px; min-height: 100px; resize: vertical;"
                                oninput="updateSatPreview()">The service provided by the Industry Partner from {StartDate} to {EndDate} is found satisfactory.</textarea>

                        </div>
                    </div>

                    <div class="filter-grid mt-3">
                        <div>
                            <label class="form-label-bold">Signatory PCNO</label>
                            <div style="display: flex; gap: 8px;">
                                <input type="text" id="satSignatoryPcnoInput" class="form-control-custom" placeholder="e.g. 1004" />
                                <button type="button" class="btn-custom" onclick="fetchSignatoryDetails()" style="margin: 0; white-space: nowrap; padding: 6px 12px; height: 38px; background: #4f46e5; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;"><i class="fas fa-search"></i> Fetch</button>
                            </div>
                        </div>
                        <div>
                            <label class="form-label-bold">Signatory Name</label>
                            <input type="text" id="satSignatoryInput" class="form-control-custom"
                                value="(Raajita B Reddy)" oninput="updateSatPreview()" />
                        </div>
                        <div>
                            <label class="form-label-bold">Signatory Designation</label>
                            <input type="text" id="satDesignationInput" class="form-control-custom"
                                value="Scientist 'F'" oninput="updateSatPreview()" />
                        </div>
                        <div>
                            <label class="form-label-bold">Upload Header Image</label>
                            <div style="display: flex; gap: 8px;">
                                <input type="file" id="satHeaderUploadInput" class="form-control-custom"
                                    accept="image/*" onchange="handleSatHeaderUpload(this)" style="padding: 4px;" />
                                <button type="button" class="btn btn-outline-secondary" onclick="resetSatHeaderImage()"
                                    style="height: 38px; border-radius: 6px;" title="Reset Default Header"><i
                                        class="fas fa-undo"></i></button>
                            </div>
                        </div>
                    </div>



                    <!-- Layout & Formatting Settings -->
                    <hr style="border-color:#e2e8f0; margin: 16px 0;" />
                    <h6 class="font-weight-bold text-dark mb-3"><i
                            class="fas fa-text-height mr-2 text-primary"></i>Layout &amp; Formatting</h6>
                    <div class="filter-grid mb-3">
                        <div>
                            <label class="form-label-bold">Font Size (pt)</label>
                            <input type="number" id="satFontSizeInput" class="form-control-custom" value="14" min="8"
                                max="24" step="1" oninput="previewSatLayout()" />
                            <small style="color: #64748b; font-size: 0.75rem; display: block; margin-top: 4px;">Body
                                text font size in points. Applies to all text in the certificate.</small>
                        </div>
                        <div>
                            <label class="form-label-bold">Section Spacing (pt)</label>
                            <input type="number" id="satSectionSpacingInput" class="form-control-custom" value="25"
                                min="0" max="100" step="1" oninput="previewSatLayout()" />
                            <small style="color: #64748b; font-size: 0.75rem; display: block; margin-top: 4px;">Space
                                between each section (header→date, date→title, title→paragraph, between
                                paragraphs).</small>
                        </div>
                        <div>
                            <label class="form-label-bold">Space Before Signatory (pt)</label>
                            <input type="number" id="satSigSpacingInput" class="form-control-custom" value="50" min="0"
                                max="200" step="1" oninput="previewSatLayout()" />
                            <small style="color: #64748b; font-size: 0.75rem; display: block; margin-top: 4px;">Space
                                after the last paragraph before the signatory name block (2 blank lines = 50pt at 14pt
                                font).</small>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <button type="button" class="btn-custom btn-load"
                            style="background-color: #6366f1; color: white;" onclick="saveSatTpl()"><i
                                class="fas fa-save"></i> Save Satisfactory Templates</button>
                    </div>

                </div>

                <!-- Tab: Covering Letter -->
                <div id="tab-covering" class="tab-content" style="display: none;">
                    <div class="filter-grid">
                        <div>
                            <label class="form-label-bold">Internal Phone No.</label>
                            <input type="text" id="covPhoneInput" class="form-control-custom"
                                oninput="updateCovPreview()" />
                        </div>
                        <div>
                            <label class="form-label-bold">Reference Number Template</label>
                            <input type="text" id="covRefNoInput" class="form-control-custom"
                                oninput="updateCovPreview()" />
                        </div>
                        <div>
                            <label class="form-label-bold">Subject Heading</label>
                            <input type="text" id="covSubjectInput" class="form-control-custom"
                                oninput="updateCovPreview()" />
                        </div>
                    </div>

                    <div class="filter-grid mt-2">
                        <div>
                            <label class="form-label-bold">Signatory PCNO</label>
                            <div style="display: flex; gap: 8px;">
                                <input type="text" id="covSignatoryPcnoInput" class="form-control-custom" placeholder="e.g. 1004" />
                                <button type="button" class="btn-custom" onclick="fetchCovSignatoryDetails()" style="margin: 0; white-space: nowrap; padding: 6px 12px; height: 38px; background: #4f46e5; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;"><i class="fas fa-search"></i> Fetch</button>
                            </div>
                        </div>
                        <div>
                            <label class="form-label-bold">Signatory Name</label>
                            <input type="text" id="covSignatoryInput" class="form-control-custom"
                                oninput="updateCovPreview()" />
                        </div>
                        <div>
                            <label class="form-label-bold">Signatory Designation</label>
                            <input type="text" id="covDesignationInput" class="form-control-custom"
                                oninput="updateCovPreview()" />
                        </div>
                        <div>
                            <label class="form-label-bold">Signatory Authority Template</label>
                            <input type="text" id="covAuthorityInput" class="form-control-custom"
                                oninput="updateCovPreview()" />
                        </div>
                    </div>

                    <div
                        style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 12px; margin-bottom: 12px;">
                        <div>
                            <label class="form-label-bold">Recipient Block Template</label>
                            <textarea id="covRecipientInput" class="form-control-custom"
                                style="height: 100px; min-height: 80px; resize: vertical;"
                                oninput="updateCovPreview()"></textarea>
                        </div>
                        <div>
                            <label class="form-label-bold">Body Paragraph Template</label>
                            <textarea id="covBodyInput" class="form-control-custom"
                                style="height: 100px; min-height: 80px; resize: vertical;"
                                oninput="updateCovPreview()"></textarea>
                        </div>
                    </div>



                    <!-- Layout & Formatting Settings -->
                    <hr style="border-color:#e2e8f0; margin: 16px 0;" />
                    <h6 class="font-weight-bold text-dark mb-3"><i
                            class="fas fa-text-height mr-2 text-primary"></i>Layout &amp; Formatting</h6>
                    <div class="filter-grid mb-3">
                        <div>
                            <label class="form-label-bold">Font Size (pt)</label>
                            <input type="number" id="covFontSizeInput" class="form-control-custom" value="12" min="8"
                                max="24" step="1" oninput="previewCovLayout()" />
                            <small style="color: #64748b; font-size: 0.75rem; display: block; margin-top: 4px;">Body
                                text font size in points. Applies to all text in the covering letter.</small>
                        </div>
                        <div>
                            <label class="form-label-bold">Section Spacing (pt)</label>
                            <input type="number" id="covSectionSpacingInput" class="form-control-custom" value="24"
                                min="0" max="100" step="1" oninput="previewCovLayout()" />
                            <small style="color: #64748b; font-size: 0.75rem; display: block; margin-top: 4px;">Space
                                between each section (phone→ref, ref→division, division→subject, subject→body).</small>
                        </div>
                        <div>
                            <label class="form-label-bold">Space Before Signatory (pt)</label>
                            <input type="number" id="covSigSpacingInput" class="form-control-custom" value="50" min="0"
                                max="200" step="1" oninput="previewCovLayout()" />
                            <small style="color: #64748b; font-size: 0.75rem; display: block; margin-top: 4px;">Space
                                after the body paragraph before the signatory name block.</small>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <button type="button" class="btn-custom btn-load" onclick="saveCovTpl()"
                            style="background-color: #6366f1; color: white;"><i class="fas fa-save"></i> Save Covering
                            Letter Templates</button>
                    </div>

                </div>

                <!-- Tab: Wages Calculation -->
                <div id="tab-wages" class="tab-content" style="display: none;">
                    <div class="settings-parameter-grid">
                        <div>
                            <label class="form-label-bold">Wages Category (To load/edit default description)</label>
                            <select id="wagesTplCategorySelect" class="form-control-custom"
                                onchange="onWagesTplCategoryChange()">
                                <option value="Skilled">Skilled</option>
                                <option value="Semi-Skilled">Semi-Skilled</option>
                                <option value="Unskilled">Unskilled</option>
                            </select>
                        </div>
                        <div>
                            <label class="form-label-bold">Default Category Description (Saved globally for selected
                                category)</label>
                            <input type="text" id="wagesTplCategoryDescInput" class="form-control-custom" />
                        </div>

                    </div>

                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 12px;">
                        <div>
                            <label class="form-label-bold">Line 1 Template (Contract Info)</label>
                            <textarea id="txtWagesTplContract" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateWagesPreview()"></textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Line 2 Template (Category & Strength)</label>
                            <textarea id="txtWagesTplCategory" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateWagesPreview()"></textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Line 3 Template (Contract Period)</label>
                            <textarea id="txtWagesTplPeriod" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateWagesPreview()"></textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Line 4 Template (Vendor)</label>
                            <textarea id="txtWagesTplVendor" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateWagesPreview()"></textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Line 5 Template (Payment Period)</label>
                            <textarea id="txtWagesTplPayment" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;"
                                oninput="updateWagesPreview()"></textarea>

                        </div>
                    </div>

                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <button type="button" class="btn-custom btn-load"
                            style="background-color: #6366f1; color: white;" onclick="saveWagesTpl()"><i
                                class="fas fa-save"></i> Save Wages Templates</button>
                    </div>
                </div>

                <!-- Tab: Attendance Report -->
                <div id="tab-report" class="tab-content" style="display: none;">
                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 16px; margin-bottom: 12px;">
                        <div>
                            <label class="form-label-bold">Heading Line 1 Template (Standard Layout)</label>
                            <textarea id="txtRepTpl1Heading1" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;">ATTENDANCE REPORT OF CONTRACTOR WORKERS FOR THE MONTH OF {Month} {Year}</textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Heading Line 2 Template (Standard Layout)</label>
                            <textarea id="txtRepTpl1Heading2" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;">Name of Vendor: M/s. {VendorName} | GeM Contract No: {ContractNo}</textarea>

                        </div>
                    </div>
                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 16px; margin-bottom: 12px; margin-top: 12px;">
                        <div>
                            <label class="form-label-bold">Heading Line 1 Template (Summary Layout)</label>
                            <textarea id="txtRepTpl2Heading1" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;">MONTHLY STATEMENT OF CONTRACTOR WORKERS ATTENDANCE</textarea>

                        </div>
                        <div>
                            <label class="form-label-bold">Heading Line 2 Template (Summary Layout)</label>
                            <textarea id="txtRepTpl2Heading2" class="form-control-custom"
                                style="height: 60px; min-height: 60px; resize: vertical;">Category: {Category} | Contract Period: {ContractPeriod} | GeM Contract: {ContractNo}</textarea>

                        </div>
                    </div>
                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <button type="button" class="btn-custom btn-load"
                            style="background-color: #6366f1; color: white;" onclick="saveReportTpl()"><i
                                class="fas fa-save"></i> Save Report Templates</button>
                    </div>
                </div>

                </div>
            </div>
        </div>

        <!-- Backdrop Overlay -->
        <div id="drawerOverlay" class="drawer-overlay" onclick="closePlaceholdersDrawer()"></div>

        <!-- Right: Global Placeholders Guide Drawer -->
        <div id="placeholdersDrawer" class="placeholders-drawer btn-print-hide">
            <div class="drawer-header">
                <h6 class="font-weight-bold text-dark mb-0" style="display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fas fa-info-circle text-primary"></i> Global Placeholders Guide
                </h6>
                <button type="button" class="drawer-close-btn" onclick="closePlaceholdersDrawer()">&times;</button>
            </div>
            <div class="drawer-content">
                <p style="color: #64748b; font-size: 0.8rem; line-height: 1.5; margin-bottom: 16px;">
                    You can use <strong>any</strong> placeholder in <strong>any</strong> document template. They are replaced dynamically based on the selected contract period and month.
                </p>
                <div style="padding-right: 4px;">
                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Category}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Category Name (lowercase)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>skilled</code>, <code>semi-skilled</code></div>
                    </div>
                    
                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{CategoryDesc}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Category Description</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>Data Entry Operators (Skilled)</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{VendorName}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Vendor Name</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>Vishal Manpower Services</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{VendorAddress}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Vendor Office Address</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{ContractNo}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">GeM Contract Number</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{ContractDate}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Contract Date / Start Date</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{DatedOn}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Contract "Dated On" Date</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{StartDate}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Start Date of Month (Default)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Formats adapt to document type automatically.</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{EndDate}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">End Date of Month (Default)</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.334155; color: #334155; font-weight: 700; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">{StartDateShort}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Short Start Date (Fixed)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>01-May-2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.334155; color: #334155; font-weight: 700; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">{EndDateShort}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Short End Date (Fixed)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>31-May-2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.334155; color: #334155; font-weight: 700; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">{StartDateSpace}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Space Start Date (Fixed)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>01 May 2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.334155; color: #334155; font-weight: 700; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">{EndDateSpace}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Space End Date (Fixed)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>31 May 2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.334155; color: #334155; font-weight: 700; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">{StartDateLong}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Long Start Date (Fixed)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>01st May 2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.334155; color: #334155; font-weight: 700; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">{EndDateLong}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Long End Date (Fixed)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>31st May 2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Month}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Selected Month Name</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>May</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Year}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Selected Year</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>2026</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Division}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Directorate Name</div>
                        <div style="font-size: 0.72rem; color: #64748b;">e.g., <code>AD-Admin</code></div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Services}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Services Description</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Duration}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Contract Period / Duration</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{WefDate}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">With Effect From (w.e.f.) Date</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{EmpCount}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Employees strength (Count)</div>
                        <div style="font-size: 0.72rem; color: #64748b;">(Also matches <code>{PeopleCount}</code>)</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{Period}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Contract Period Range</div>
                    </div>

                    <div class="placeholder-guide-item" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 10px;">
                        <code style="font-size: 0.85rem; color: #4f46e5; font-weight: 700; background: #e0e7ff; padding: 2px 6px; border-radius: 4px;">{WorkingDays}</code>
                        <div style="font-size: 0.78rem; color: #334155; font-weight: 600; margin-top: 4px;">Working Days (Excl. Sundays)</div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            function getSelectedCategoryInfo(selectElem) {
                if (!selectElem) return { val: "All", text: "Contract Staff", cleanName: "Contract Staff" };
                const val = selectElem.value || "All";
                const selectedOption = selectElem.options && selectElem.selectedIndex >= 0 ? selectElem.options[selectElem.selectedIndex] : null;
                let text = selectedOption ? (selectedOption.text || "") : "Contract Staff";
                
                if (val === "All" || text === "All Categories" || !val) {
                    return { val: "All", text: "Contract Staff", cleanName: "Contract Staff" };
                }

                // Extract tier/category name if format is "MainCategory › Tier (#Role)" or "Skilled"
                let cleanName = text;
                if (cleanName.includes(" › ")) {
                    const parts = cleanName.split(" › ");
                    cleanName = parts[parts.length - 1].trim();
                }
                cleanName = cleanName.replace(/\s*\(\s*#.*\)/, "").trim();

                return { val: val, text: text, cleanName: cleanName || text };
            }

            function getGlobalContext(docType) {
                // Collect year, month, category, division
                let year = "2026";
                let monthIndex = 4; // May
                let catInfo = { val: "All", text: "Contract Staff", cleanName: "Contract Staff" };
                let division = "[Division]";
                
                // Check active workspace or default based on docType
                let activeDoc = docType;
                if (!activeDoc) {
                    if (document.getElementById("attendanceCertWorkspace") && document.getElementById("attendanceCertWorkspace").style.display !== "none") activeDoc = "attendance";
                    else if (document.getElementById("satisfactoryCertWorkspace") && document.getElementById("satisfactoryCertWorkspace").style.display !== "none") activeDoc = "satisfactory";
                    else if (document.getElementById("coveringLetterWorkspace") && document.getElementById("coveringLetterWorkspace").style.display !== "none") activeDoc = "covering";
                    else if (document.getElementById("wagesCalcWorkspace") && document.getElementById("wagesCalcWorkspace").style.display !== "none") activeDoc = "wages";
                    else if (document.getElementById("attendanceReportWorkspace") && document.getElementById("attendanceReportWorkspace").style.display !== "none") activeDoc = "report";
                }

                if (activeDoc === "attendance") {
                    year = document.getElementById("year")?.value || "2026";
                    monthIndex = parseInt(document.getElementById("month")?.value || "4");
                    catInfo = getSelectedCategoryInfo(document.getElementById("category"));
                } else if (activeDoc === "satisfactory") {
                    year = document.getElementById("satYear")?.value || "2026";
                    monthIndex = parseInt(document.getElementById("satMonth")?.value || "4");
                    catInfo = getSelectedCategoryInfo(document.getElementById("satCategory"));
                } else if (activeDoc === "covering") {
                    year = document.getElementById("covYear")?.value || "2026";
                    monthIndex = parseInt(document.getElementById("covMonth")?.value || "4");
                    catInfo = getSelectedCategoryInfo(document.getElementById("covCategory"));
                    division = document.getElementById("covDivision")?.value || "[Division]";
                } else if (activeDoc === "wages") {
                    year = document.getElementById("wagesYear")?.value || "2026";
                    monthIndex = parseInt(document.getElementById("wagesMonth")?.value || "4");
                    catInfo = getSelectedCategoryInfo(document.getElementById("wagesCategory"));
                } else if (activeDoc === "report") {
                    year = document.getElementById("repYear")?.value || "2026";
                    monthIndex = parseInt(document.getElementById("repMonth")?.value || "4");
                    catInfo = getSelectedCategoryInfo(document.getElementById("repCategory"));
                }

                const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                const monthName = months[monthIndex];
                const daysInMonth = new Date(parseInt(year), monthIndex + 1, 0).getDate();

                // Ordinal suffix helper
                const getSuffix = (d) => {
                    if (d > 3 && d < 21) return 'th';
                    switch (d % 10) {
                        case 1:  return "st";
                        case 2:  return "nd";
                        case 3:  return "rd";
                        default: return "th";
                    }
                };

                // Formatted dates
                const shortStart = `01-${monthName.substring(0, 3)}-${year}`;
                const shortEnd = `${daysInMonth}-${monthName.substring(0, 3)}-${year}`;
                
                const spaceStart = `01 ${monthName} ${year}`;
                const spaceEnd = `${daysInMonth} ${monthName} ${year}`;
                
                const longStart = `01st ${monthName} ${year}`;
                const longEnd = `${daysInMonth}${getSuffix(daysInMonth)} ${monthName} ${year}`;

                // Context-sensitive values
                let defaultStart = shortStart;
                let defaultEnd = shortEnd;
                if (docType === "satisfactory") {
                    defaultStart = spaceStart;
                    defaultEnd = spaceEnd;
                } else if (docType === "covering") {
                    defaultStart = longStart;
                    defaultEnd = longEnd;
                } else if (docType === "wages") {
                    defaultStart = spaceStart;
                    defaultEnd = spaceEnd;
                }

                // Resolve contract object based on activeDoc
                let contractObj = null;
                if (activeDoc === "report") {
                    const contractSel = document.getElementById("repContract");
                    const selectedId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;
                    if (selectedId && typeof reportContractsList !== "undefined") {
                        contractObj = reportContractsList.find(c => c.Id === selectedId);
                    }
                } else if (activeDoc === "covering") {
                    const contractSel = document.getElementById("covContract");
                    const selectedId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;
                    if (selectedId && typeof covContractsList !== "undefined") {
                        contractObj = covContractsList.find(c => c.Id === selectedId);
                    }
                } else if (activeDoc === "satisfactory") {
                    const contractSel = document.getElementById("satContract");
                    const selectedId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;
                    if (selectedId && typeof satContractsList !== "undefined") {
                        contractObj = satContractsList.find(c => c.Id === selectedId);
                    }
                } else if (activeDoc === "wages") {
                    const contractSel = document.getElementById("wagesContract");
                    const selectedId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;
                    if (selectedId && typeof wagesContractsList !== "undefined") {
                        contractObj = wagesContractsList.find(c => c.Id === selectedId);
                    }
                } else {
                    const contractSel = document.getElementById("contract");
                    const selectedId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;
                    if (selectedId && typeof contractsList !== "undefined") {
                        contractObj = contractsList.find(c => c.Id === selectedId);
                    }
                }

                // Gather input values with fallback values
                const vendorName = (activeDoc === "report") ? (contractObj ? (contractObj.VendorName || "") : "VISHAL MANPOWER & SECURITY CONSULTANTS") :
                                   (contractObj && contractObj.VendorName ? contractObj.VendorName :
                                   (document.getElementById("vendorName")?.value || 
                                   document.getElementById("satVendorNameInput")?.value || 
                                   document.getElementById("wagesVendorNameInput")?.value || 
                                   "[Vendor Name]"));
                                   
                const vendorAddress = (activeDoc === "report") ? (contractObj ? (contractObj.VendorAddress || "") : "Mangalore") :
                                      (contractObj && contractObj.VendorAddress ? contractObj.VendorAddress :
                                      (document.getElementById("vendorAddress")?.value || 
                                      document.getElementById("satVendorAddressInput")?.value || 
                                      document.getElementById("wagesVendorAddressInput")?.value || 
                                      "[Vendor Address]"));
                                      
                const contractNo = (activeDoc === "report") ? (contractObj ? (contractObj.GemId || "") : "GEMC-511687761569464") :
                                   (contractObj && contractObj.GemId ? contractObj.GemId :
                                   (document.getElementById("gemContractNo")?.value || 
                                   document.getElementById("satGemNoInput")?.value || 
                                   document.getElementById("wagesContractNoInput")?.value || 
                                   "[GeM Contract No]"));
                                   
                const contractDate = (activeDoc === "report") ? (contractObj ? (contractObj.StartDate || "") : "[Contract Date]") :
                                     (contractObj && contractObj.StartDate ? contractObj.StartDate :
                                     (document.getElementById("gemContractDate")?.value || 
                                     document.getElementById("satContractDateInput")?.value || 
                                     document.getElementById("wagesContractDateInput")?.value || 
                                     "[Contract Date]"));
                                     
                const datedOn = (activeDoc === "report") ? (document.getElementById("repDatedOnInput")?.value || "[Dated On]") :
                                (contractObj && contractObj.VendorDatedOn ? contractObj.VendorDatedOn :
                                (document.getElementById("certDatedOnInput")?.value || 
                                document.getElementById("satDatedOnInput")?.value || 
                                document.getElementById("wagesDatedOnInput")?.value || 
                                "[Dated On]"));

                const services = document.getElementById("satServicesInput")?.value || "[Services]";
                const duration = document.getElementById("satDurationInput")?.value || "[Duration]";
                const wefDate = document.getElementById("satWefInput")?.value || "[w.e.f. Date]";
                
                // Signatory
                const signatory = document.getElementById("satSignatoryInput")?.value || 
                                  document.getElementById("covSignatoryInput")?.value || 
                                  "[Signatory Name]";
                const designation = document.getElementById("satDesignationInput")?.value || 
                                    document.getElementById("covDesignationInput")?.value || 
                                    "[Signatory Designation]";

                // EmpCount
                let empCount = document.getElementById("satEmpCountInput")?.value || "0";
                if (empCount === "0" && typeof wagesEmployeesData !== "undefined" && wagesEmployeesData.length > 0) {
                    empCount = wagesEmployeesData.length.toString();
                } else if (empCount === "0" && typeof satEmployeesData !== "undefined" && satEmployeesData.length > 0) {
                    empCount = satEmployeesData.length.toString();
                } else if (empCount === "0" && typeof employeesData !== "undefined" && employeesData.length > 0) {
                    empCount = employeesData.length.toString();
                }

                const catLabel = catInfo.val !== "All" ? catInfo.cleanName : "Contract Staff";
                const categoryDesc = document.getElementById("wagesCategoryDescInput")?.value || (catInfo.val !== "All" ? catInfo.cleanName : "Contract Staff");
                
                // Wages specific
                const period = document.getElementById("wagesPeriodInput")?.value || `${shortStart} to ${shortEnd}`;
                const extraCode = document.getElementById("wagesExtraCodeInput")?.value || "";

                // Working days excluding Sundays
                let workingDaysExcludingSundays = 0;
                for (let d = 1; d <= daysInMonth; d++) {
                    const dayOfWeek = new Date(parseInt(year), monthIndex, d).getDay();
                    if (dayOfWeek !== 0) workingDaysExcludingSundays++;
                }

                // Global Adjustment for wage calculation header
                let globalAdj = 0;
                if (typeof wagesMetadata !== 'undefined' && wagesMetadata && wagesMetadata.GlobalAdjustment !== undefined) {
                    globalAdj = parseFloat(wagesMetadata.GlobalAdjustment) || 0;
                }
                const totalWorkingDays = workingDaysExcludingSundays + globalAdj;

                const contractPeriod = (activeDoc === "report") ? (contractObj ? (contractObj.DisplayName || "") : "") : "";

                return {
                    "Category": catLabel,
                    "CategoryDesc": categoryDesc,
                    "VendorName": vendorName,
                    "VendorAddress": vendorAddress,
                    "ContractNo": contractNo,
                    "ContractDate": contractDate,
                    "DatedOn": datedOn,
                    "StartDate": defaultStart,
                    "EndDate": defaultEnd,
                    "StartDateShort": shortStart,
                    "EndDateShort": shortEnd,
                    "StartDateSpace": spaceStart,
                    "EndDateSpace": spaceEnd,
                    "StartDateLong": longStart,
                    "EndDateLong": longEnd,
                    "PaymentStart": defaultStart,
                    "PaymentEnd": defaultEnd,
                    "Year": year,
                    "Month": monthName,
                    "Division": division,
                    "Services": services,
                    "Duration": duration,
                    "WefDate": wefDate,
                    "EmpCount": empCount,
                    "PeopleCount": empCount,
                    "WorkingDays": totalWorkingDays,
                    "Period": period,
                    "ExtraCode": extraCode,
                    "ContractPeriod": contractPeriod
                };
            }

            function replacePlaceholders(templateText, docType) {
                if (!templateText) return "";
                const ctx = getGlobalContext(docType);
                let text = templateText;
                for (const [key, value] of Object.entries(ctx)) {
                    const regex = new RegExp(`\\{${key}\\}`, "gi");
                    text = text.replace(regex, value);
                }
                return text;
            }

            let categories = [];
            let contractsList = [];
            let employeesData = [];
            let tplDesc1 = "This is certify that DEO ({Category}) under GeM Contract No: {ContractNo}, dated: {ContractDate}";
            let tplDesc2 = "M/s. {VendorName}, {VendorAddress} worked as following, for the period from {StartDate} to {EndDate}";
            let tplSatDesc1 = "This is to certify that M/s. <b>{VendorName}</b>, {VendorAddress} is engaged as an Industry Partner in our Establishment to provide Services towards <b>{Services}</b> for a period of {Duration} w.e.f. {WefDate} against GeM Contract No. <b>{ContractNo}</b> dated {ContractDate}.";
            let tplSatDesc2 = "The Industry Partner provided <b>{EmpCount}</b> Contract Employees and found working satisfactorily.";
            let tplSatDesc3 = "The service provided by the Industry Partner from {StartDate} to {EndDate} is found satisfactory.";

            let tplCovPhone = "2312";
            let tplCovRefNo = "49805/HRD/HM/{Year}";
            let tplCovSubject = "HIRING OF MANPOWER SERVICES";
            let tplCovBody = "The copies of the Attendance report along with the wage calculation for {Category} category Contract Employees from M/s. {VendorName}, {VendorAddress} for the period of {StartDate} to {EndDate} is enclosed. This is for purpose of their payment processing please.";
            let tplCovSignatory = "Usha Nandini AA";
            let tplCovDesignation = "TO C";
            let tplCovAuthority = "For GD, {Division}";
            let tplCovRecipient = "To,\nD-FMM/Purchase";
            let tplWagesHdrContract = "Contract No. <b>{ContractNo}</b> Dt. <b>{ContractDate}</b> {ExtraCode}";
            let tplWagesHdrCategory = "Manpower Outstanding Services - Data Entry Operators({CategoryDesc}) - {PeopleCount} No.s";
            let tplWagesHdrPeriod = "Contract Period <b>{Period}</b>";
            let tplWagesHdrVendor = "M/s {VendorName}, {VendorAddress}";
            let tplWagesHdrPayment = "Payment for the period <b>{PaymentStart}</b> to <b>{PaymentEnd}</b> - <b>{WorkingDays} days</b>";

            let tplRepTpl1H1 = "ATTENDANCE REPORT OF CONTRACTOR WORKERS FOR THE MONTH OF {Month} {Year}";
            let tplRepTpl1H2 = "Name of Vendor: M/s. {VendorName} | GeM Contract No: {ContractNo}";
            let tplRepTpl2H1 = "MONTHLY STATEMENT OF CONTRACTOR WORKERS ATTENDANCE";
            let tplRepTpl2H2 = "Category: {Category} | Contract Period: {ContractPeriod} | GeM Contract: {ContractNo}";

            let wagesCategoryDescriptions = {
                "Skilled": "Data Entry Operators(Skilled)",
                "Semi-Skilled": "Staff",
                "Unskilled": "attender"
            };
            let covContractsList = [];

            // Global Toast Notification System
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

                // Trigger reflow
                toast.offsetHeight;
                toast.classList.add("toast-show");

                // Auto dismiss
                setTimeout(() => {
                    if (toast.parentElement) {
                        toast.classList.remove("toast-show");
                        toast.classList.add("toast-hide");
                        setTimeout(() => { toast.remove(); }, 400);
                    }
                }, 4000);
            }

            function togglePlaceholdersDrawer() {
                const drawer = document.getElementById("placeholdersDrawer");
                const overlay = document.getElementById("drawerOverlay");
                if (drawer && overlay) {
                    if (drawer.classList.contains("open")) {
                        closePlaceholdersDrawer();
                    } else {
                        drawer.classList.add("open");
                        overlay.style.display = "block";
                    }
                }
            }

            function closePlaceholdersDrawer() {
                const drawer = document.getElementById("placeholdersDrawer");
                const overlay = document.getElementById("drawerOverlay");
                if (drawer && overlay) {
                    drawer.classList.remove("open");
                    overlay.style.display = "none";
                }
            }

            function selectDocument(docType, skipFilterChange) {
                document.getElementById('documentHubView').style.display = 'none';

                // Close drawer when switching workspace
                closePlaceholdersDrawer();

                if (docType === 'attendance-cert') {
                    document.getElementById('attendanceCertWorkspace').style.display = 'block';
                    document.getElementById('satisfactoryCertWorkspace').style.display = 'none';
                    document.getElementById('coveringLetterWorkspace').style.display = 'none';
                    document.getElementById('wagesCalcWorkspace').style.display = 'none';
                    document.getElementById('templateSettingsWorkspace').style.display = 'none';
                    document.getElementById('pageMainHeader').textContent = 'Attendance Certificate Generator';
                } else if (docType === 'satisfactory-cert') {
                    document.getElementById('attendanceCertWorkspace').style.display = 'none';
                    document.getElementById('satisfactoryCertWorkspace').style.display = 'block';
                    document.getElementById('coveringLetterWorkspace').style.display = 'none';
                    document.getElementById('wagesCalcWorkspace').style.display = 'none';
                    document.getElementById('templateSettingsWorkspace').style.display = 'none';
                    document.getElementById('pageMainHeader').textContent = 'Satisfactory Certificate Generator';
                    populateSatSelectors();
                } else if (docType === 'covering-letter') {
                    document.getElementById('attendanceCertWorkspace').style.display = 'none';
                    document.getElementById('satisfactoryCertWorkspace').style.display = 'none';
                    document.getElementById('coveringLetterWorkspace').style.display = 'block';
                    document.getElementById('wagesCalcWorkspace').style.display = 'none';
                    document.getElementById('templateSettingsWorkspace').style.display = 'none';
                    document.getElementById('pageMainHeader').textContent = 'Covering Letter Generator';
                    populateCovSelectors();
                } else if (docType === 'wages-calc') {
                    document.getElementById('attendanceCertWorkspace').style.display = 'none';
                    document.getElementById('satisfactoryCertWorkspace').style.display = 'none';
                    document.getElementById('coveringLetterWorkspace').style.display = 'none';
                    document.getElementById('wagesCalcWorkspace').style.display = 'block';
                    document.getElementById('templateSettingsWorkspace').style.display = 'none';
                    document.getElementById('pageMainHeader').textContent = 'Wages Calculation Generator';
                    populateWagesSelectors(skipFilterChange);
                } else if (docType === 'attendance-report') {
                    document.getElementById('attendanceCertWorkspace').style.display = 'none';
                    document.getElementById('satisfactoryCertWorkspace').style.display = 'none';
                    document.getElementById('coveringLetterWorkspace').style.display = 'none';
                    document.getElementById('wagesCalcWorkspace').style.display = 'none';
                    document.getElementById('attendanceReportWorkspace').style.display = 'block';
                    document.getElementById('templateSettingsWorkspace').style.display = 'none';
                    document.getElementById('pageMainHeader').textContent = 'Attendance Report Generator';
                    populateReportSelectors();
                } else if (docType === 'template-settings') {
                    document.getElementById('attendanceCertWorkspace').style.display = 'none';
                    document.getElementById('satisfactoryCertWorkspace').style.display = 'none';
                    document.getElementById('coveringLetterWorkspace').style.display = 'none';
                    document.getElementById('wagesCalcWorkspace').style.display = 'none';
                    document.getElementById('attendanceReportWorkspace').style.display = 'none';
                    document.getElementById('templateSettingsWorkspace').style.display = 'block';
                    document.getElementById('pageMainHeader').textContent = 'Global Template Settings';
                    if (typeof onWagesTplCategoryChange === 'function') {
                        onWagesTplCategoryChange();
                    }
                }
            }

            function goBackToHub() {
                document.getElementById('documentHubView').style.display = 'block';
                document.getElementById('attendanceCertWorkspace').style.display = 'none';
                document.getElementById('satisfactoryCertWorkspace').style.display = 'none';
                document.getElementById('coveringLetterWorkspace').style.display = 'none';
                document.getElementById('wagesCalcWorkspace').style.display = 'none';
                document.getElementById('attendanceReportWorkspace').style.display = 'none';
                document.getElementById('templateSettingsWorkspace').style.display = 'none';
                document.getElementById('pageMainHeader').textContent = 'Document Hub';

                // Close drawer when going back
                closePlaceholdersDrawer();
            }

            function switchTemplateTab(evt, tabId) {
                const contents = document.querySelectorAll('#templateSettingsWorkspace .tab-content');
                contents.forEach(el => el.style.display = 'none');

                const btns = document.querySelectorAll('#templateSettingsWorkspace .tab-btn');
                btns.forEach(btn => {
                    btn.classList.remove('active');
                    btn.style.color = '#64748b';
                    btn.style.borderBottom = 'none';
                    btn.style.fontWeight = '600';
                });

                document.getElementById(tabId).style.display = 'block';
                evt.currentTarget.classList.add('active');
                evt.currentTarget.style.color = '#4f46e5';
                evt.currentTarget.style.borderBottom = '2px solid #4f46e5';
                evt.currentTarget.style.fontWeight = '700';
            }

            function onWagesTplCategoryChange() {
                const catSelect = document.getElementById("wagesTplCategorySelect");
                if (catSelect) {
                    const catVal = catSelect.value;
                    const descInput = document.getElementById("wagesTplCategoryDescInput");
                    if (descInput) {
                        descInput.value = wagesCategoryDescriptions[catVal] || "";
                    }
                }
            }

            // On Page Load
            document.addEventListener("DOMContentLoaded", () => {
                loadTemplates();
                populateSelectors();
                // check for custom header on page load
                const savedHeader = localStorage.getItem('satisfactory_custom_header');
                if (savedHeader) {
                    const imgEl = document.getElementById('satPreviewHeaderImage');
                    if (imgEl) imgEl.src = savedHeader;
                }

                // Recalculate wages total when any cell is edited in the table
                const recalculateWagesFromTable = () => {
                    const dailyRateInput = parseFloat(document.getElementById("wagesDailyRate").value) || 0;
                    const epfRate = parseFloat(document.getElementById("wagesEpfRate").value) || 0;
                    const epfLimit = parseFloat(document.getElementById("wagesEpfLimit").value) || 0;
                    const serviceChargeRate = parseFloat(document.getElementById("wagesServiceChargeRate").value) || 0;
                    const gstRate = parseFloat(document.getElementById("wagesGstRate").value) || 0;
                    const epfMaxAmount = parseFloat(document.getElementById("wagesEpfCappedAmount").value) || 0;

                    let totalPeople = 0;
                    let totalWorkingDays = 0;
                    let wagesTotal = 0;
                    let epfCappedCount = 0;
                    let epfCappedTotal = 0;
                    let epfActualCount = 0;
                    let epfActualSum = 0;

                    const rows = document.querySelectorAll("#wagesTableBody tr");
                    rows.forEach(tr => {
                        const cells = tr.querySelectorAll("td");
                        if (cells.length < 6) return;

                        const cellDailyRate = parseFloat(cells[1].textContent.replace(/,/g, '')) || 0;
                        const cellPeople = parseInt(cells[3].textContent.replace(/,/g, '')) || 0;
                        const cellDays = parseFloat(cells[4].textContent.replace(/,/g, '')) || 0;

                        const cellPayment = cellDailyRate * cellDays;
                        const cellTotalDays = cellPeople * cellDays;

                        if (document.activeElement !== cells[2]) {
                            cells[2].textContent = cellPayment.toFixed(2);
                        }
                        if (document.activeElement !== cells[5]) {
                            cells[5].textContent = cellTotalDays.toFixed(0);
                        }

                        totalPeople += cellPeople;
                        totalWorkingDays += cellTotalDays;

                        if (cellPayment >= epfLimit) {
                            epfCappedCount += cellPeople;
                            epfCappedTotal += cellPeople * epfMaxAmount;
                        } else {
                            epfActualCount += cellPeople;
                            epfActualSum += cellPeople * (cellPayment * (epfRate / 100));
                        }
                    });

                    document.getElementById("wagesTotalPeople").textContent = totalPeople;
                    document.getElementById("wagesTotalDays").textContent = totalWorkingDays;

                    document.getElementById("wagesFormulaDesc").textContent = `${dailyRateInput.toFixed(2)}*${totalWorkingDays}`;
                    wagesTotal = totalWorkingDays * dailyRateInput;

                    if (document.activeElement !== document.getElementById("wagesAmountWages")) {
                        document.getElementById("wagesAmountWages").textContent = wagesTotal.toFixed(2);
                    } else {
                        wagesTotal = parseFloat(document.getElementById("wagesAmountWages").textContent.replace(/,/g, '')) || 0;
                    }

                    document.getElementById("wagesFormulaEpfCapped").textContent = `EPF @${epfRate}%for ${epfCappedCount} persons`;

                    if (document.activeElement !== document.getElementById("wagesAmountEpfCapped")) {
                        document.getElementById("wagesAmountEpfCapped").textContent = epfCappedTotal.toFixed(2);
                    } else {
                        epfCappedTotal = parseFloat(document.getElementById("wagesAmountEpfCapped").textContent.replace(/,/g, '')) || 0;
                    }

                    document.getElementById("wagesFormulaEpfActual").textContent = `EPF @${epfRate}%for ${epfActualCount} person`;

                    if (document.activeElement !== document.getElementById("wagesAmountEpfActual")) {
                        document.getElementById("wagesAmountEpfActual").textContent = epfActualSum.toFixed(2);
                    } else {
                        epfActualSum = parseFloat(document.getElementById("wagesAmountEpfActual").textContent.replace(/,/g, '')) || 0;
                    }

                    let subTotal = wagesTotal + epfCappedTotal + epfActualSum;
                    if (document.activeElement !== document.getElementById("wagesAmountSubTotal")) {
                        document.getElementById("wagesAmountSubTotal").textContent = subTotal.toFixed(2);
                    } else {
                        subTotal = parseFloat(document.getElementById("wagesAmountSubTotal").textContent.replace(/,/g, '')) || 0;
                    }

                    let serviceCharge = subTotal * (serviceChargeRate / 100);
                    if (document.activeElement !== document.getElementById("wagesAmountServiceCharge")) {
                        document.getElementById("wagesAmountServiceCharge").textContent = serviceCharge.toFixed(5);
                    } else {
                        serviceCharge = parseFloat(document.getElementById("wagesAmountServiceCharge").textContent.replace(/,/g, '')) || 0;
                    }

                    let gst = subTotal * (gstRate / 100);
                    if (document.activeElement !== document.getElementById("wagesAmountGst")) {
                        document.getElementById("wagesAmountGst").textContent = gst.toFixed(5);
                    } else {
                        gst = parseFloat(document.getElementById("wagesAmountGst").textContent.replace(/,/g, '')) || 0;
                    }

                    const grandTotal = subTotal + serviceCharge + gst;
                    document.getElementById("wagesAmountGrandTotal").textContent = grandTotal.toFixed(2);
                };

                const wagesTable = document.getElementById("wagesTable");
                if (wagesTable) {
                    wagesTable.addEventListener("input", recalculateWagesFromTable);
                }
            });

            // ── Covering Letter Scripts ──
            let divisions = [];

            function getOrdinalSuffix(day) {
                if (day > 3 && day < 21) return 'th';
                switch (day % 10) {
                    case 1: return "st";
                    case 2: return "nd";
                    case 3: return "rd";
                    default: return "th";
                }
            }

            function populateCovSelectors() {
                const yearSel = document.getElementById("covYear");
                const monthSel = document.getElementById("covMonth");
                const categorySel = document.getElementById("covCategory");
                const divisionSel = document.getElementById("covDivision");

                // Fill Year if empty
                if (yearSel.innerHTML === "") {
                    const currYear = new Date().getFullYear();
                    for (let y = currYear - 2; y <= currYear + 2; y++) {
                        yearSel.innerHTML += `<option value="${y}">${y}</option>`;
                    }
                    yearSel.value = currYear;
                }

                // Fill Month if empty
                if (monthSel.innerHTML === "") {
                    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    months.forEach((m, i) => {
                        monthSel.innerHTML += `<option value="${i}">${m}</option>`;
                    });
                    monthSel.value = new Date().getMonth();
                }

                // Fill Category
                if (categorySel.innerHTML === "" || categorySel.options.length <= 1) {
                    fillCategoryDropdown(categorySel);
                }

                // Fill Division if empty
                if (divisionSel.innerHTML === "") {
                    if (divisions.length > 0) {
                        fillDivisionDropdown();
                        onCovFilterChange();
                    } else {
                        fetch('Documents.aspx/GetDivisions', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' }
                        })
                            .then(r => r.json())
                            .then(res => {
                                divisions = JSON.parse(res.d || "[]");
                                fillDivisionDropdown();
                                onCovFilterChange();
                            })
                            .catch(() => {
                                showToast("Failed to fetch divisions.", "error");
                                onCovFilterChange();
                            });
                    }
                } else {
                    onCovFilterChange();
                }
            }

            function fillDivisionDropdown() {
                const divisionSel = document.getElementById("covDivision");
                divisionSel.innerHTML = "";
                divisions.forEach(div => {
                    divisionSel.innerHTML += `<option value="${div}">${div}</option>`;
                });
                // Default to D-KRM if it exists
                const defaultDiv = divisions.find(d => d === "D-KRM");
                if (defaultDiv) {
                    divisionSel.value = "D-KRM";
                } else if (divisions.length > 0) {
                    divisionSel.value = divisions[0];
                }
            }

            function onCovFilterChange() {
                const yearElem = document.getElementById("covYear");
                const monthElem = document.getElementById("covMonth");
                const catElem = document.getElementById("covCategory");
                if (!yearElem || !monthElem || !catElem || !yearElem.value || !monthElem.value || !catElem.value) return;
                const yearVal = parseInt(yearElem.value);
                const monthVal = parseInt(monthElem.value);
                const catVal = catElem.value;
                if (isNaN(yearVal) || isNaN(monthVal)) return;

                if (catVal === "All") {
                    document.getElementById("covContractGroup").style.display = "none";
                    document.getElementById("covContract").innerHTML = "";
                    updateCovPreview();
                    return;
                }

                // Fetch Contracts
                fetch('Documents.aspx/GetContractsForMonth', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal })
                })
                    .then(r => r.json())
                    .then(res => {
                        covContractsList = JSON.parse(res.d || "[]");
                        const contractSel = document.getElementById("covContract");
                        const contractGroup = document.getElementById("covContractGroup");

                        if (covContractsList.length > 0) {
                            let optionsHtml = "";
                            covContractsList.forEach(c => {
                                optionsHtml += `<option value="${c.Id}">${c.DisplayName}</option>`;
                            });
                            contractSel.innerHTML = optionsHtml;
                            contractGroup.style.display = "block";
                            onCovContractChange();
                        } else {
                            contractGroup.style.display = "none";
                            contractSel.innerHTML = "";
                            updateCovPreview();
                        }
                    })
                    .catch(() => showToast("Failed to fetch contract periods.", "error"));
            }

            function onCovContractChange() {
                updateCovPreview();
            }

            function updateCovPreview() {
                const contractSel = document.getElementById("covContract");
                const selectedId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;
                const contract = covContractsList.find(c => c.Id === selectedId);

                const vendorName = contract ? contract.VendorName : "[Vendor Name]";
                const vendorAddress = contract ? contract.VendorAddress : "[Vendor Address]";

                const ySelect = document.getElementById("covYear");
                if (!ySelect || !ySelect.value) return;
                const yText = ySelect.value;

                const mSelect = document.getElementById("covMonth");
                if (!mSelect || mSelect.selectedIndex === -1) return;
                const mText = mSelect.options[mSelect.selectedIndex].text;

                const daysInMonth = new Date(parseInt(yText), parseInt(mSelect.value) + 1, 0).getDate();

                // Date of covering letter: usually the month after the selected month (e.g. May 2026 selected -> June 2026)
                let nextMonthIndex = (parseInt(mSelect.value) + 1) % 12;
                let nextYear = parseInt(yText);
                if (nextMonthIndex === 0) nextYear += 1;
                const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                const certMonthText = months[nextMonthIndex];

                // Formatted date period: e.g. 01st May 2026 to 31st May 2026
                const fullMonthName = months[parseInt(mSelect.value)];
                const formattedStart = `01st ${fullMonthName} ${yText}`;
                const formattedEnd = `${daysInMonth}${getOrdinalSuffix(daysInMonth)} ${fullMonthName} ${yText}`;

                // Read the template values from inputs
                const phone = document.getElementById("covPhoneInput").value || "";
                const refNoTpl = document.getElementById("covRefNoInput").value || "";
                const subject = document.getElementById("covSubjectInput").value || "";
                const bodyTpl = document.getElementById("covBodyInput").value || "";
                const signatory = document.getElementById("covSignatoryInput").value || "";
                const designation = document.getElementById("covDesignationInput").value || "";
                const authorityTpl = document.getElementById("covAuthorityInput").value || "";
                const recipientTpl = document.getElementById("covRecipientInput").value || "";

                const catVal = document.getElementById("covCategory").value;
                const catLabel = catVal !== "All" ? catVal.toLowerCase() : "contract staff";
                const divisionVal = document.getElementById("covDivision").value || "[Division]";

                // Placeholders replacements
                let refNo = replacePlaceholders(refNoTpl, "covering");
                let authority = replacePlaceholders(authorityTpl, "covering");
                let recipient = replacePlaceholders(recipientTpl, "covering");
                let body = replacePlaceholders(bodyTpl, "covering");

                // Bind to Preview UI elements
                document.getElementById("covPreviewPhone").textContent = phone;
                document.getElementById("covPreviewRefNo").textContent = refNo;
                document.getElementById("covPreviewDate").textContent = `${certMonthText} ${nextYear}`;
                document.getElementById("covPreviewDivision").textContent = divisionVal;
                document.getElementById("covPreviewSubject").textContent = subject;

                document.getElementById("covParagraph").innerHTML = body.replace(/\n/g, '<br/>');

                document.getElementById("covPreviewSignatory").textContent = signatory;
                document.getElementById("covPreviewDesignation").textContent = designation;
                document.getElementById("covPreviewAuthority").textContent = authority;

                document.getElementById("covRecipient").innerHTML = recipient.replace(/\n/g, '<br/>');

                document.getElementById("covPreviewArea").style.display = "block";
                updateCovMiniPreview();
            }

            function saveCovTpl() {
                const phone = document.getElementById("covPhoneInput").value;
                const refNo = document.getElementById("covRefNoInput").value;
                const subject = document.getElementById("covSubjectInput").value;
                const body = document.getElementById("covBodyInput").value;
                const signatory = document.getElementById("covSignatoryInput").value;
                const designation = document.getElementById("covDesignationInput").value;
                const authority = document.getElementById("covAuthorityInput").value;
                const recipient = document.getElementById("covRecipientInput").value;
                const pcno = document.getElementById("covSignatoryPcnoInput")?.value || "";
                const fontSizePt = parseInt(document.getElementById('covFontSizeInput')?.value) || 12;
                const sectionSpacingPt = parseInt(document.getElementById('covSectionSpacingInput')?.value) || 24;
                const sigSpacingPt = parseInt(document.getElementById('covSigSpacingInput')?.value) || 50;

                if (!phone.trim() || !refNo.trim() || !subject.trim() || !body.trim() || !signatory.trim() || !designation.trim() || !authority.trim() || !recipient.trim()) {
                    showToast("All fields are required and cannot be empty.", "warning");
                    return;
                }

                fetch('Documents.aspx/SaveCovTemplates', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        phone: phone,
                        refNo: refNo,
                        subject: subject,
                        body: body,
                        signatory: signatory,
                        designation: designation,
                        authority: authority,
                        recipient: recipient,
                        pcno: pcno,
                        fontSizePt: fontSizePt,
                        sectionSpacingPt: sectionSpacingPt,
                        sigSpacingPt: sigSpacingPt
                    })
                })
                    .then(r => r.json())
                    .then(res => {
                        const data = JSON.parse(res.d || "{}");
                        if (data.status === "success") {
                            tplCovPhone = phone;
                            tplCovRefNo = refNo;
                            tplCovSubject = subject;
                            tplCovBody = body;
                            tplCovSignatory = signatory;
                            tplCovDesignation = designation;
                            tplCovAuthority = authority;
                            tplCovRecipient = recipient;
                            applyCovLayout(fontSizePt, sectionSpacingPt, sigSpacingPt);
                            showToast("Covering Letter settings saved successfully.", "success");
                            updateCovPreview();
                        } else {
                            showToast(data.message || "Failed to save.", "error");
                        }
                    })
                    .catch(() => showToast("Error saving templates.", "error"));
            }

            function fetchCovSignatoryDetails() {
                const pcnoInput = document.getElementById("covSignatoryPcnoInput");
                const pcno = pcnoInput ? pcnoInput.value.trim() : "";
                if (!pcno) {
                    showToast("Please enter a PCNO first.", "warning");
                    return;
                }

                showToast("Fetching signatory details...", "info");

                fetch('Documents.aspx/GetEmployeeDetailsByPCNO', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ pcno: pcno })
                })
                .then(r => r.json())
                .then(res => {
                    const data = JSON.parse(res.d || "{}");
                    if (data.status === "success") {
                        const sigInput = document.getElementById("covSignatoryInput");
                        const desInput = document.getElementById("covDesignationInput");
                        
                        if (sigInput) sigInput.value = data.name || "";
                        if (desInput) desInput.value = data.designation || "";
                        
                        showToast("Signatory details fetched successfully!", "success");
                        updateCovPreview();
                    } else {
                        showToast(data.message || "Failed to fetch details.", "error");
                    }
                })
                .catch(err => {
                    console.error(err);
                    showToast("Error communicating with backend.", "error");
                });
            }

            function downloadCovAsDoc() {
                const sheet = document.getElementById('coveringLetterPrintSheet');
                if (!sheet) { showToast("Covering Letter preview not loaded.", "error"); return; }

                const txt = id => { const el = document.getElementById(id); return el ? el.textContent : ''; };

                // Read live covering letter layout settings
                const docFontSize = parseInt(document.getElementById('covFontSizeInput')?.value) || 12;
                const docSectionSpacing = parseInt(document.getElementById('covSectionSpacingInput')?.value) || 24;
                const docSigSpacing = parseInt(document.getElementById('covSigSpacingInput')?.value) || 50;

                const html = `<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta charset="UTF-8"/>
<meta name="ProgId" content="Word.Document"/>
<meta name="Generator" content="Microsoft Word 15"/>
<meta name="Originator" content="Microsoft Word 15"/>
<!--[if gte mso 9]><xml>
<w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>100</w:Zoom>
  <w:DoNotOptimizeForBrowser/>
</w:WordDocument>
</xml><![endif]-->
<style>
@page Section1 {
  size: 595.3pt 841.9pt;
  margin: 72.0pt 72.0pt 72.0pt 72.0pt;
  mso-header-margin: 36.0pt;
  mso-footer-margin: 36.0pt;
  mso-paper-source: 0;
}
div.Section1 { page: Section1; }
body {
  margin: 0;
  padding: 0;
  font-family: Arial, Helvetica, sans-serif;
  font-size: ${docFontSize}.0pt;
  color: black;
}
p { margin: 0; padding: 0; }
</style>
</head>
<body lang="EN-IN">
<div class="Section1">

<!-- Phone No (Internal) -->
<p style="text-align:left;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;margin-bottom:${docSectionSpacing / 2}pt;">
  Phone No (Internal): ${txt('covPreviewPhone')}
</p>

<!-- Reference Number & Date table -->
<table border="0" cellpadding="0" cellspacing="0" style="width:100%;border:none;border-collapse:collapse;margin-bottom:${docSectionSpacing}pt;">
  <tr>
    <td align="left" style="text-align:left;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;padding:0;width:50%;">
      No: ${txt('covPreviewRefNo')}
    </td>
    <td align="right" style="text-align:right;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;font-weight:bold;padding:0;width:50%;">
      ${txt('covPreviewDate')}
    </td>
  </tr>
</table>

<!-- Division -->
<p style="text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;font-weight:bold;margin-bottom:${docSectionSpacing / 2}pt;">
  ${txt('covPreviewDivision')}
</p>

<!-- Subject -->
<p style="text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;font-weight:bold;margin-bottom:${docSectionSpacing}pt;text-transform:uppercase;">
  ${txt('covPreviewSubject')}
</p>

<p style="text-align:left;text-indent:36.0pt;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;line-height:150%;margin-bottom:${docSigSpacing}pt;">${document.getElementById('covParagraph').innerHTML.trim()}</p>

<!-- Signatory Block -->
<table align="right" border="0" cellpadding="0" cellspacing="0" style="margin-top:20pt;margin-bottom:${docSectionSpacing}pt;border:none;border-collapse:collapse;">
  <tr>
    <td align="center" style="text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;padding:0;">
      <b>${txt('covPreviewSignatory')}</b>
    </td>
  </tr>
  <tr>
    <td align="center" style="text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;padding:0;">
      ${txt('covPreviewDesignation')}
    </td>
  </tr>
  <tr>
    <td align="center" style="text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;padding:0;">
      ${txt('covPreviewAuthority')}
    </td>
  </tr>
</table>
<div style="clear:both;"></div>

<!-- Recipient Block -->
<p style="text-align:left;font-family: Arial, Helvetica, sans-serif;font-size:${docFontSize}.0pt;font-weight:bold;margin-top:30pt;line-height:150%;">
  ${document.getElementById('covRecipient').innerHTML}
</p>

</div>
</body>
</html>`;

                const mSel = document.getElementById('covMonth');
                const ySel = document.getElementById('covYear');
                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                const mName = mSel ? months[parseInt(mSel.value)] : 'Month';
                const yName = ySel ? ySel.value : 'Year';

                const blob = new Blob(['\ufeff', html], { type: 'application/msword' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `Covering_Letter_${mName}_${yName}.doc`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                showToast("Covering Letter downloaded as DOC.", "success");
            }

            // ── Satisfactory Certificate Scripts ──
            let satContractsList = [];
            let satEmployeesData = [];

            function populateSatSelectors() {
                const yearSel = document.getElementById("satYear");
                const monthSel = document.getElementById("satMonth");
                const categorySel = document.getElementById("satCategory");

                // Fill Year if empty
                if (yearSel.innerHTML === "") {
                    const currYear = new Date().getFullYear();
                    for (let y = currYear - 2; y <= currYear + 2; y++) {
                        yearSel.innerHTML += `<option value="${y}">${y}</option>`;
                    }
                    yearSel.value = currYear;
                }

                // Fill Month if empty
                if (monthSel.innerHTML === "") {
                    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    months.forEach((m, i) => {
                        monthSel.innerHTML += `<option value="${i}">${m}</option>`;
                    });
                    monthSel.value = new Date().getMonth();
                }

                // Fill Category
                if (categorySel.innerHTML === "" || categorySel.options.length <= 1) {
                    fillCategoryDropdown(categorySel);
                }

                // Load saved custom header if exists
                const savedHeader = localStorage.getItem('satisfactory_custom_header');
                if (savedHeader) {
                    const imgEl = document.getElementById('satPreviewHeaderImage');
                    if (imgEl) imgEl.src = savedHeader;
                }

                onSatFilterChange();
            }

            function onSatFilterChange() {
                const yearElem = document.getElementById("satYear");
                const monthElem = document.getElementById("satMonth");
                const catElem = document.getElementById("satCategory");
                if (!yearElem || !monthElem || !catElem || !yearElem.value || !monthElem.value || !catElem.value) return;
                const yearVal = parseInt(yearElem.value);
                const monthVal = parseInt(monthElem.value);
                const catVal = catElem.value;
                if (isNaN(yearVal) || isNaN(monthVal)) return;

                if (catVal === "All") {
                    document.getElementById("satContractGroup").style.display = "none";
                    document.getElementById("satContract").innerHTML = "";
                    clearSatInputs();
                    updateSatPreview();
                    loadSatData();
                    return;
                }

                // Fetch Contracts using existing WebMethod
                fetch('Documents.aspx/GetContractsForMonth', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal })
                })
                    .then(r => r.json())
                    .then(res => {
                        satContractsList = JSON.parse(res.d || "[]");
                        const contractSel = document.getElementById("satContract");
                        const contractGroup = document.getElementById("satContractGroup");

                        if (satContractsList.length > 0) {
                            let optionsHtml = "";
                            satContractsList.forEach(c => {
                                optionsHtml += `<option value="${c.Id}">${c.DisplayName}</option>`;
                            });
                            contractSel.innerHTML = optionsHtml;
                            contractGroup.style.display = "block";
                            onSatContractChange();
                        } else {
                            contractGroup.style.display = "none";
                            contractSel.innerHTML = "";
                            clearSatInputs();
                            updateSatPreview();
                            loadSatData();
                        }
                    })
                    .catch(() => showToast("Failed to fetch contract periods.", "error"));
            }

            function clearSatInputs() {
                document.getElementById("satVendorNameInput").value = "";
                document.getElementById("satVendorAddressInput").value = "";
                document.getElementById("satGemNoInput").value = "";
                document.getElementById("satContractDateInput").value = "";
                document.getElementById("satWefInput").value = "";
                document.getElementById("satDatedOnInput").value = "";
                document.getElementById("satEmpCountInput").value = "0";
            }

            function onSatContractChange() {
                const contractSel = document.getElementById("satContract");
                const selectedId = parseInt(contractSel.value);
                const contract = satContractsList.find(c => c.Id === selectedId);

                if (contract) {
                    document.getElementById("satVendorNameInput").value = contract.VendorName || "";
                    document.getElementById("satVendorAddressInput").value = contract.VendorAddress || "";
                    document.getElementById("satGemNoInput").value = contract.GemId || "";
                    document.getElementById("satContractDateInput").value = contract.StartDate || ""; // Prefill with contract date
                    document.getElementById("satWefInput").value = contract.StartDate || ""; // w.e.f. date is contract start date
                    document.getElementById("satDatedOnInput").value = contract.VendorDatedOn || "";
                }
                updateSatPreview();
                loadSatData();
            }

            function loadSatData() {
                const loader = document.getElementById("satPreviewLoader");
                const previewArea = document.getElementById("satPreviewArea");

                loader.style.display = "block";
                previewArea.style.display = "none";

                const yearVal = parseInt(document.getElementById("satYear").value);
                const monthVal = parseInt(document.getElementById("satMonth").value);
                const catVal = document.getElementById("satCategory").value;
                const contractSel = document.getElementById("satContract");
                const selectedCpId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;

                // Fetch Live Attendance / Employee count using existing WebMethod
                fetch('Documents.aspx/GetCertificateData', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal, contractPeriodId: selectedCpId })
                })
                    .then(r => r.json())
                    .then(res => {
                        satEmployeesData = JSON.parse(res.d || "[]");
                        if (satEmployeesData.error) {
                            showToast(satEmployeesData.error, "error");
                            loader.style.display = "none";
                            return;
                        }

                        // Prefill employee count
                        document.getElementById("satEmpCountInput").value = satEmployeesData.length;

                        updateSatPreview();
                        loader.style.display = "none";
                        previewArea.style.display = "block";
                        showToast(`Loaded ${satEmployeesData.length} records successfully!`, "success");
                    })
                    .catch(() => {
                        loader.style.display = "none";
                        showToast("Failed to retrieve satisfactory certificate data.", "error");
                    });
            }

            function updateSatPreview() {
                const vendorName = document.getElementById("satVendorNameInput").value || "[Vendor Name]";
                const vendorAddress = document.getElementById("satVendorAddressInput").value || "[Vendor Address]";
                const gemNo = document.getElementById("satGemNoInput").value || "[GeM Contract No]";
                const contractDate = document.getElementById("satContractDateInput").value || "[Contract Date]";
                const datedOn = document.getElementById("satDatedOnInput").value || "[Dated On]";
                const duration = document.getElementById("satDurationInput").value || "[Period]";
                const wefDate = document.getElementById("satWefInput").value || "[w.e.f. Date]";
                const services = document.getElementById("satServicesInput").value || "[Services Description]";
                const empCount = document.getElementById("satEmpCountInput").value || "0";
                const signatory = document.getElementById("satSignatoryInput").value || "[Signatory Name]";
                const designation = document.getElementById("satDesignationInput").value || "[Signatory Designation]";

                const ySelect = document.getElementById("satYear");
                if (!ySelect || !ySelect.value) return;
                const yText = ySelect.value;

                const mSelect = document.getElementById("satMonth");
                if (!mSelect || mSelect.selectedIndex === -1) return;
                const mText = mSelect.options[mSelect.selectedIndex].text;

                const daysInMonth = new Date(parseInt(yText), parseInt(mSelect.value) + 1, 0).getDate();

                // Date of certificate: usually the month after the selected month (e.g. May 2026 selected -> prints June 2026)
                let nextMonthIndex = (parseInt(mSelect.value) + 1) % 12;
                let nextYear = parseInt(yText);
                if (nextMonthIndex === 0) nextYear += 1;
                const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                const certMonthText = months[nextMonthIndex];

                document.getElementById("satPreviewDate").textContent = `${certMonthText}  ${nextYear}`;

                // Formatted date period: e.g. 01 May 2026 to 31 May 2026
                const fullMonthName = months[parseInt(mSelect.value)];
                const formattedStart = `01 ${fullMonthName.substring(0, 3)} ${yText}`;
                const formattedEnd = `${daysInMonth} ${fullMonthName.substring(0, 3)} ${yText}`;

                // Sentence replacements from textareas (matching default fallbacks)
                const tpl1 = document.getElementById("txtSatTplDesc1")?.value || tplSatDesc1;
                const tpl2 = document.getElementById("txtSatTplDesc2")?.value || tplSatDesc2;
                const tpl3 = document.getElementById("txtSatTplDesc3")?.value || tplSatDesc3;

                let p1 = replacePlaceholders(tpl1, "satisfactory");
                let p2 = replacePlaceholders(tpl2, "satisfactory");
                let p3 = replacePlaceholders(tpl3, "satisfactory");

                document.getElementById("satParagraph1").innerHTML = p1.trim();
                document.getElementById("satParagraph2").innerHTML = p2.trim();
                document.getElementById("satParagraph3").innerHTML = p3.trim();

                document.getElementById("satPreviewSignatory").textContent = signatory;
                document.getElementById("satPreviewDesignation").textContent = designation;
                updateSatMiniPreview();
            }

            // Applies font size and spacing to both on-screen preview and @media print CSS
            function applySatLayout(fontSizePt, sectionSpacingPt, sigSpacingPt) {
                fontSizePt = parseInt(fontSizePt) || 14;
                sectionSpacingPt = parseInt(sectionSpacingPt) || 25;
                sigSpacingPt = parseInt(sigSpacingPt) || 50;

                // Update the on-screen preview container font
                const sheet = document.getElementById('satisfactoryPrintSheet');
                if (sheet) sheet.style.fontSize = fontSizePt + 'pt';

                // Update margins on all section wrappers
                const sectionMargin = sectionSpacingPt + 'pt';
                const headerWrap = document.querySelector('.sat-header-img-wrap');
                const dateWrap = document.querySelector('.sat-date-wrap');
                const titleWrap = document.querySelector('.sat-title-wrap');
                const p1 = document.getElementById('satParagraph1');
                const p2 = document.getElementById('satParagraph2');
                const p3 = document.getElementById('satParagraph3');
                if (headerWrap) headerWrap.style.marginBottom = sectionMargin;
                if (dateWrap) dateWrap.style.marginBottom = sectionMargin;
                if (titleWrap) titleWrap.style.marginBottom = sectionMargin;
                if (p1) p1.style.marginBottom = sectionMargin;
                if (p2) p2.style.marginBottom = sectionMargin;
                if (p3) p3.style.marginBottom = sigSpacingPt + 'pt';

                // Inject/update dynamic @media print CSS so print view matches preview
                let dynStyle = document.getElementById('satDynamicPrintCSS');
                if (!dynStyle) {
                    dynStyle = document.createElement('style');
                    dynStyle.id = 'satDynamicPrintCSS';
                    document.head.appendChild(dynStyle);
                }
                dynStyle.textContent = `@media print {
                #satisfactoryPrintSheet { font-size: ${fontSizePt}pt !important; }
                .sat-header-img-wrap  { margin-bottom: ${sectionSpacingPt}pt !important; }
                .sat-date-wrap        { margin-bottom: ${sectionSpacingPt}pt !important; }
                .sat-title-wrap       { margin-bottom: ${sectionSpacingPt}pt !important; font-size: ${fontSizePt}pt !important; }
                .sat-paragraph-wrap   { margin-bottom: ${sectionSpacingPt}pt !important; font-size: ${fontSizePt}pt !important; text-align: justify !important; }
                #satParagraph3.sat-paragraph-wrap { margin-bottom: ${sigSpacingPt}pt !important; }
            }`;
            }

            // Live preview when admin edits the Layout settings sliders
            function previewSatLayout() {
                const fs = parseInt(document.getElementById('satFontSizeInput')?.value) || 14;
                const ss = parseInt(document.getElementById('satSectionSpacingInput')?.value) || 25;
                const sig = parseInt(document.getElementById('satSigSpacingInput')?.value) || 50;
                applySatLayout(fs, ss, sig);
                updateSatMiniPreview();
            }

            // Update the mini preview panel in the Satisfactory Certificate template tab
            function updateSatMiniPreview() {
                const fs = parseInt(document.getElementById('satFontSizeInput')?.value) || 14;
                const ss = parseInt(document.getElementById('satSectionSpacingInput')?.value) || 25;
                const sig = parseInt(document.getElementById('satSigSpacingInput')?.value) || 50;
                const sheet = document.getElementById('satMiniPreviewSheet');
                if (!sheet) return;
                sheet.style.fontSize = fs + 'pt';
                // Section margins
                const sm = ss + 'pt';
                const sections = [
                    { id: 'satMiniP1', mb: sm }, { id: 'satMiniP2', mb: sm },
                    { id: 'satMiniP3', mb: sig + 'pt' }
                ];
                // Update header/date/title wrappers via inline style
                const children = sheet.children;
                if (children[0]) children[0].style.marginBottom = sm; // header img
                if (children[1]) children[1].style.marginBottom = sm; // date
                if (children[2]) children[2].style.marginBottom = sm; // title
                sections.forEach(s => { const el = document.getElementById(s.id); if (el) el.style.marginBottom = s.mb; });

                // Sync text content from main template inputs
                const p1Tpl = document.getElementById('txtSatTplDesc1')?.value;
                const p2Tpl = document.getElementById('txtSatTplDesc2')?.value;
                const p3Tpl = document.getElementById('txtSatTplDesc3')?.value;
                const sig_name = document.getElementById('satSignatoryInput')?.value || '(Signatory Name)';
                const sig_des = document.getElementById('satDesignationInput')?.value || 'Designation';
                if (document.getElementById('satMiniP1') && p1Tpl) document.getElementById('satMiniP1').innerHTML = p1Tpl.replace(/\{[^}]+\}/g, m => `<b style="color:#94a3b8">${m}</b>`);
                if (document.getElementById('satMiniP2') && p2Tpl) document.getElementById('satMiniP2').innerHTML = p2Tpl.replace(/\{[^}]+\}/g, m => `<b style="color:#94a3b8">${m}</b>`);
                if (document.getElementById('satMiniP3') && p3Tpl) document.getElementById('satMiniP3').innerHTML = p3Tpl.replace(/\{[^}]+\}/g, m => `<b style="color:#94a3b8">${m}</b>`);
                if (document.getElementById('satMiniSignatory')) document.getElementById('satMiniSignatory').textContent = sig_name;
                if (document.getElementById('satMiniDesignation')) document.getElementById('satMiniDesignation').textContent = sig_des;
                // Sync header image
                const mainImg = document.getElementById('satPreviewHeaderImage');
                const miniImg = document.getElementById('satMiniHeaderImg');
                if (mainImg && miniImg && mainImg.src) miniImg.src = mainImg.src;
            }

            // Applies font size and spacing to the covering letter preview and @media print CSS
            function applyCovLayout(fontSizePt, sectionSpacingPt, sigSpacingPt) {
                fontSizePt = parseInt(fontSizePt) || 12;
                sectionSpacingPt = parseInt(sectionSpacingPt) || 24;
                sigSpacingPt = parseInt(sigSpacingPt) || 50;

                // Update on-screen preview
                const sheet = document.getElementById('coveringLetterPrintSheet');
                if (sheet) sheet.style.fontSize = fontSizePt + 'pt';

                const sm = sectionSpacingPt + 'pt';
                const phoneWrap = document.querySelector('.cov-phone-wrap');
                const refDateWrap = document.querySelector('.cov-ref-date-wrap');
                const divWrap = document.querySelector('.cov-division-wrap');
                const subWrap = document.querySelector('.cov-subject-wrap');
                const paraWrap = document.getElementById('covParagraph');
                const sigWrap = document.querySelector('.cov-sig-wrap');
                if (phoneWrap) phoneWrap.style.marginBottom = sm;
                if (refDateWrap) refDateWrap.style.marginBottom = sm;
                if (divWrap) divWrap.style.marginBottom = sm;
                if (subWrap) subWrap.style.marginBottom = sm;
                if (paraWrap) paraWrap.style.marginBottom = sigSpacingPt + 'pt';
                if (sigWrap) { sigWrap.style.marginTop = '0'; sigWrap.style.marginBottom = sm; }

                // Inject dynamic print CSS
                let dynStyle = document.getElementById('covDynamicPrintCSS');
                if (!dynStyle) {
                    dynStyle = document.createElement('style');
                    dynStyle.id = 'covDynamicPrintCSS';
                    document.head.appendChild(dynStyle);
                }
                dynStyle.textContent = `@media print {
                #coveringLetterPrintSheet { font-size: ${fontSizePt}pt !important; }
                .cov-phone-wrap    { margin-bottom: ${sectionSpacingPt}pt !important; }
                .cov-ref-date-wrap { margin-bottom: ${sectionSpacingPt}pt !important; }
                .cov-division-wrap { margin-bottom: ${sectionSpacingPt}pt !important; }
                .cov-subject-wrap  { margin-bottom: ${sectionSpacingPt}pt !important; }
                #covParagraph      { margin-bottom: ${sigSpacingPt}pt !important; font-size: ${fontSizePt}pt !important; }
                .cov-sig-wrap      { margin-top: 0 !important; margin-bottom: ${sectionSpacingPt}pt !important; }
                .cov-recipient-wrap { font-size: ${fontSizePt}pt !important; }
            }`;
            }

            // Live preview when admin edits covering letter layout settings
            function previewCovLayout() {
                const fs = parseInt(document.getElementById('covFontSizeInput')?.value) || 12;
                const ss = parseInt(document.getElementById('covSectionSpacingInput')?.value) || 24;
                const sig = parseInt(document.getElementById('covSigSpacingInput')?.value) || 50;
                applyCovLayout(fs, ss, sig);
                updateCovMiniPreview();
            }

            // Update the mini preview panel in the Covering Letter template tab
            function updateCovMiniPreview() {
                const fs = parseInt(document.getElementById('covFontSizeInput')?.value) || 12;
                const ss = parseInt(document.getElementById('covSectionSpacingInput')?.value) || 24;
                const sig = parseInt(document.getElementById('covSigSpacingInput')?.value) || 50;
                const sheet = document.getElementById('covMiniPreviewSheet');
                if (!sheet) return;
                sheet.style.fontSize = fs + 'pt';
                // Update margins
                const sm = ss + 'pt';
                const phoneWrap = document.getElementById('covMiniPhoneWrap');
                const sigWrap = document.getElementById('covMiniSigWrap');
                const body = document.getElementById('covMiniBody');
                if (phoneWrap) phoneWrap.style.marginBottom = sm;
                if (body) body.style.marginBottom = sig + 'pt';
                if (sigWrap) sigWrap.style.marginBottom = sm;
                // Sync text from inputs
                const phone = document.getElementById('covPhoneInput')?.value || '2312';
                const refNo = document.getElementById('covRefNoInput')?.value || '49805/HRD/HM/2026';
                const subject = document.getElementById('covSubjectInput')?.value || 'HIRING OF MANPOWER SERVICES';
                const body_tpl = document.getElementById('covBodyInput')?.value || '';
                const sig_name = document.getElementById('covSignatoryInput')?.value || 'Signatory Name';
                const sig_des = document.getElementById('covDesignationInput')?.value || 'Designation';
                const sig_auth = document.getElementById('covAuthorityInput')?.value || 'Authority';
                const recipient = document.getElementById('covRecipientInput')?.value || 'To,\nD-FMM/Purchase';
                if (document.getElementById('covMiniPhone')) document.getElementById('covMiniPhone').textContent = phone;
                if (document.getElementById('covMiniRefNo')) document.getElementById('covMiniRefNo').textContent = refNo;
                if (document.getElementById('covMiniSubject')) document.getElementById('covMiniSubject').textContent = subject;
                if (document.getElementById('covMiniBody')) document.getElementById('covMiniBody').innerHTML = body_tpl.replace(/\{[^}]+\}/g, m => `<b style="color:#94a3b8">${m}</b>`).replace(/\n/g, '<br/>') || document.getElementById('covMiniBody').innerHTML;
                if (document.getElementById('covMiniSignatory')) document.getElementById('covMiniSignatory').textContent = sig_name;
                if (document.getElementById('covMiniDesignation')) document.getElementById('covMiniDesignation').textContent = sig_des;
                if (document.getElementById('covMiniAuthority')) document.getElementById('covMiniAuthority').textContent = sig_auth;
                if (document.getElementById('covMiniRecipient')) document.getElementById('covMiniRecipient').innerHTML = recipient.replace(/\n/g, '<br/>');
            }

            function handleSatHeaderUpload(input) {
                if (input.files && input.files[0]) {
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        const base64Data = e.target.result;
                        document.getElementById('satPreviewHeaderImage').src = base64Data;
                        try {
                            localStorage.setItem('satisfactory_custom_header', base64Data);
                            showToast("Header image uploaded and saved locally.", "success");
                        } catch (err) {
                            showToast("Image too large to persist locally, but preview updated.", "warning");
                        }
                    };
                    reader.readAsDataURL(input.files[0]);
                }
            }

            function downloadSatAsDoc() {
                const sheet = document.getElementById('satisfactoryPrintSheet');
                if (!sheet) { showToast("Certificate preview not loaded.", "error"); return; }

                const imgEl = document.getElementById('satPreviewHeaderImage');
                const headerSrc = imgEl ? imgEl.src : '';
                const txt = id => { const el = document.getElementById(id); return el ? el.textContent : ''; };

                // Read live layout settings
                const docFontSize = parseInt(document.getElementById('satFontSizeInput')?.value) || 14;
                const docSectionSpacing = parseInt(document.getElementById('satSectionSpacingInput')?.value) || 25;
                const docSigSpacing = parseInt(document.getElementById('satSigSpacingInput')?.value) || 50;

                const html = `<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta charset="UTF-8"/>
<meta name="ProgId" content="Word.Document"/>
<meta name="Generator" content="Microsoft Word 15"/>
<meta name="Originator" content="Microsoft Word 15"/>
<!--[if gte mso 9]><xml>
<w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>75</w:Zoom>
  <w:DoNotOptimizeForBrowser/>
</w:WordDocument>
</xml><![endif]-->
<style>
@page Section1 {
  size: 595.3pt 841.9pt;
  margin: 72.0pt 72.0pt 72.0pt 72.0pt;
  mso-header-margin: 36.0pt;
  mso-footer-margin: 36.0pt;
  mso-paper-source: 0;
}
div.Section1 { page: Section1; }
body {
  margin: 0;
  padding: 0;
  font-family: Arial, Helvetica, sans-serif;
  font-size: ${docFontSize}.0pt;
  color: black;
}
p { margin: 0; padding: 0; }
</style>
</head>
<body lang="EN-IN">
<div class="Section1">

<p align="center" style="text-align:center;margin-bottom:${docSectionSpacing}pt;">
<img src="${headerSrc}" width="602" height="142" style="width:451.3pt;height:106.3pt;"/>
</p>

<p align="right" style="text-align:right;margin-bottom:${docSectionSpacing}pt;">
<b>Date: ${txt('satPreviewDate')}</b>
</p>

<p align="center" style="text-align:center;margin-bottom:${docSectionSpacing}pt;">
<b><u>SATISFACTORY CERTIFICATE</u></b>
</p>

<p style="text-align:justify;margin-bottom:${docSectionSpacing}pt;line-height:180%;">${document.getElementById('satParagraph1').innerHTML.trim()}</p>

<p style="text-align:justify;margin-bottom:${docSectionSpacing}pt;line-height:180%;">${document.getElementById('satParagraph2').innerHTML.trim()}</p>

<p style="text-align:justify;margin-bottom:${docSigSpacing}pt;line-height:180%;">${document.getElementById('satParagraph3').innerHTML.trim()}</p>

<table align="right" border="0" cellpadding="0" cellspacing="0" style="margin-top:0; border:none; border-collapse:collapse;">
<tr>
  <td align="center" style="text-align:center; font-family: Arial, Helvetica, sans-serif; font-size:${docFontSize}.0pt; padding:0;">
    <b>${txt('satPreviewSignatory')}</b>
  </td>
</tr>
<tr>
  <td align="center" style="text-align:center; font-family: Arial, Helvetica, sans-serif; font-size:${docFontSize}.0pt; padding:0;">
    ${txt('satPreviewDesignation')}
  </td>
</tr>
</table>
<div style="clear:both;"></div>

</div>
</body>
</html>`;

                const mSel = document.getElementById('satMonth');
                const ySel = document.getElementById('satYear');
                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                const mName = mSel ? months[parseInt(mSel.value)] : 'Month';
                const yName = ySel ? ySel.value : 'Year';

                const blob = new Blob(['\ufeff', html], { type: 'application/msword' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `Satisfactory_Certificate_${mName}_${yName}.doc`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                showToast("Satisfactory Certificate downloaded as DOC.", "success");
            }

            function resetSatHeaderImage() {
                localStorage.removeItem('satisfactory_custom_header');
                document.getElementById('satPreviewHeaderImage').src = 'Static/images/satisfactory_header.png';
                document.getElementById('satHeaderUploadInput').value = '';
                showToast("Header image reset to default.", "success");
            }

            function formatCategoryText(rawText) {
                if (!rawText || rawText === "All Categories" || rawText === "All") return "All Categories";
                let text = rawText;
                if (text.includes(" › ")) {
                    const parts = text.split(" › ");
                    text = parts[parts.length - 1].trim();
                }
                return text.replace(/\s*\(\s*#.*\)/, "").trim();
            }

            function fillCategoryDropdown(selectElement) {
                if (!selectElement) return;
                selectElement.innerHTML = '<option value="All">All Categories</option>';
                if (categories && categories.length > 0) {
                    categories.forEach(cat => {
                        const parts = cat.split(':');
                        const catVal = parts[0];
                        const rawText = parts.length > 1 ? parts.slice(1).join(':') : cat;
                        const cleanText = formatCategoryText(rawText);
                        selectElement.innerHTML += `<option value="${catVal}">${cleanText}</option>`;
                    });
                }
            }

            function populateSelectors() {
                // Populate Year and Month dropdowns
                const yearSel = document.getElementById("year");
                const monthSel = document.getElementById("month");
                const categorySel = document.getElementById("category");

                const currYear = new Date().getFullYear();
                for (let y = currYear - 2; y <= currYear + 2; y++) {
                    yearSel.innerHTML += `<option value="${y}">${y}</option>`;
                }
                yearSel.value = currYear;

                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                months.forEach((m, i) => {
                    monthSel.innerHTML += `<option value="${i}">${m}</option>`;
                });
                monthSel.value = new Date().getMonth();

                // Load Categories
                fetch('Documents.aspx/GetCategories', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                })
                    .then(r => r.json())
                    .then(res => {
                        categories = JSON.parse(res.d || "[]");
                        fillCategoryDropdown(document.getElementById("category"));
                        fillCategoryDropdown(document.getElementById("satCategory"));
                        fillCategoryDropdown(document.getElementById("covCategory"));
                        fillCategoryDropdown(document.getElementById("repCategory"));
                        fillWagesCategoryDropdown(document.getElementById("wagesCategory"));
                        onFilterChange();
                        if (typeof onWagesFilterChange === 'function' && document.getElementById("wagesCategory").value) {
                            onWagesFilterChange();
                        }
                        checkUrlParams();
                    })
                    .catch(() => showToast("Failed to load categories.", "error"));
            }

            function checkUrlParams() {
                const urlParams = new URLSearchParams(window.location.search);
                const doc = urlParams.get('doc');
                if (doc === 'wages-calc') {
                    selectDocument('wages-calc', true);

                    const yearVal = urlParams.get('year');
                    const monthVal = urlParams.get('month');
                    const catVal = urlParams.get('category');
                    const wageVal = urlParams.get('wage');
                    const cpIdVal = urlParams.get('contract');

                    if (yearVal) document.getElementById("wagesYear").value = yearVal;
                    if (monthVal) document.getElementById("wagesMonth").value = monthVal;
                    if (catVal) document.getElementById("wagesCategory").value = catVal;
                    if (wageVal) document.getElementById("wagesDailyRate").value = wageVal;

                    if (catVal) {
                        onWagesFilterChange(cpIdVal);
                    }
                }
            }

            function onFilterChange() {
                const yearElem = document.getElementById("year");
                const monthElem = document.getElementById("month");
                const catElem = document.getElementById("category");
                if (!yearElem || !monthElem || !catElem || !yearElem.value || !monthElem.value || !catElem.value) return;
                const yearVal = parseInt(yearElem.value);
                const monthVal = parseInt(monthElem.value);
                const catVal = catElem.value;
                if (isNaN(yearVal) || isNaN(monthVal)) return;

                if (catVal === "All") {
                    document.getElementById("contractGroup").style.display = "none";
                    document.getElementById("contract").innerHTML = "";
                    document.getElementById("vendorName").value = "";
                    document.getElementById("vendorAddress").value = "";
                    document.getElementById("gemContractNo").value = "";
                    document.getElementById("gemContractDate").value = "";
                    updateHeaderPreview();
                    loadData();
                    return;
                }

                // Fetch Contracts
                fetch('Documents.aspx/GetContractsForMonth', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal })
                })
                    .then(r => r.json())
                    .then(res => {
                        contractsList = JSON.parse(res.d || "[]");
                        const contractSel = document.getElementById("contract");
                        const contractGroup = document.getElementById("contractGroup");

                        if (contractsList.length > 0) {
                            let optionsHtml = "";
                            contractsList.forEach(c => {
                                optionsHtml += `<option value="${c.Id}">${c.DisplayName}</option>`;
                            });
                            contractSel.innerHTML = optionsHtml;
                            contractGroup.style.display = "block";
                            onContractChange();
                        } else {
                            contractGroup.style.display = "none";
                            contractSel.innerHTML = "";
                            document.getElementById("vendorName").value = "";
                            document.getElementById("vendorAddress").value = "";
                            document.getElementById("gemContractNo").value = "";
                            document.getElementById("gemContractDate").value = "";
                            updateHeaderPreview();
                            loadData();
                        }
                    })
                    .catch(() => showToast("Failed to fetch contract periods.", "error"));
            }

            function onContractChange() {
                const contractSel = document.getElementById("contract");
                const selectedId = parseInt(contractSel.value);
                const contract = contractsList.find(c => c.Id === selectedId);

                if (contract) {
                    document.getElementById("vendorName").value = contract.VendorName || "";
                    document.getElementById("vendorAddress").value = contract.VendorAddress || "";
                    document.getElementById("gemContractNo").value = contract.GemId || "";
                    document.getElementById("gemContractDate").value = contract.StartDate || "";
                    document.getElementById("certDatedOnInput").value = contract.VendorDatedOn || "";
                }
                updateHeaderPreview();
                loadData();
            }

            // ── Wages Calculation Javascript Functions ──
            let wagesEmployeesData = [];
            let wagesMetadata = null;
            let wagesContractsList = [];

            function fillWagesCategoryDropdown(selectElement) {
                if (!selectElement) return;
                selectElement.innerHTML = "";
                if (categories && categories.length > 0) {
                    categories.forEach(cat => {
                        if (cat !== "All") {
                            const parts = cat.split(':');
                            const catVal = parts[0];
                            const rawText = parts.length > 1 ? parts.slice(1).join(':') : cat;
                            const cleanText = formatCategoryText(rawText);
                            selectElement.innerHTML += `<option value="${catVal}">${cleanText}</option>`;
                        }
                    });
                }
            }

            function populateWagesSelectors(skipFilterChange) {
                const yearSel = document.getElementById("wagesYear");
                const monthSel = document.getElementById("wagesMonth");
                const categorySel = document.getElementById("wagesCategory");

                // Fill Year if empty
                if (yearSel.innerHTML === "") {
                    const currYear = new Date().getFullYear();
                    for (let y = currYear - 2; y <= currYear + 2; y++) {
                        yearSel.innerHTML += `<option value="${y}">${y}</option>`;
                    }
                    yearSel.value = currYear;
                }

                // Fill Month if empty
                if (monthSel.innerHTML === "") {
                    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    months.forEach((m, i) => {
                        monthSel.innerHTML += `<option value="${i}">${m}</option>`;
                    });
                    monthSel.value = new Date().getMonth();
                }

                // Fill Categories if empty
                if (categorySel.innerHTML === "" || categorySel.options.length === 0) {
                    fillWagesCategoryDropdown(categorySel);
                }

                document.getElementById("wagesServiceChargeRate").value = "3.85";

                if (!skipFilterChange && categorySel.value) {
                    onWagesFilterChange();
                }
            }

            function onWagesFilterChange(selectedContractId) {
                const yearVal = parseInt(document.getElementById("wagesYear").value);
                const monthVal = parseInt(document.getElementById("wagesMonth").value);
                const catVal = document.getElementById("wagesCategory").value;

                if (!catVal || catVal === "All") {
                    document.getElementById("wagesContractGroup").style.display = "none";
                    document.getElementById("wagesContract").innerHTML = "";
                    resetWagesHeader();
                    return;
                }

                // Fetch Contracts
                fetch('Documents.aspx/GetContractsForMonth', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal })
                })
                    .then(r => r.json())
                    .then(res => {
                        wagesContractsList = JSON.parse(res.d || "[]");
                        const contractSel = document.getElementById("wagesContract");
                        const contractGroup = document.getElementById("wagesContractGroup");

                        if (wagesContractsList.length > 0) {
                            let optionsHtml = "";
                            wagesContractsList.forEach(c => {
                                optionsHtml += `<option value="${c.Id}">${c.DisplayName}</option>`;
                            });
                            contractSel.innerHTML = optionsHtml;
                            contractGroup.style.display = "block";

                            if (selectedContractId && wagesContractsList.some(c => c.Id === parseInt(selectedContractId))) {
                                contractSel.value = selectedContractId;
                            }

                            onWagesContractChange();
                        } else {
                            contractGroup.style.display = "none";
                            contractSel.innerHTML = "";
                            resetWagesHeader();
                        }
                    })
                    .catch(() => showToast("Failed to fetch contract periods.", "error"));
            }

            function onWagesContractChange() {
                const contractSel = document.getElementById("wagesContract");
                const selectedId = parseInt(contractSel.value);
                const contract = wagesContractsList.find(c => c.Id === selectedId);

                if (contract) {
                    loadWagesData();
                } else {
                    resetWagesHeader();
                }
            }

            function resetWagesHeader() {
                document.getElementById("wagesHeaderContract").innerHTML = "Contract No. [Contract No] Dt. [Contract Date]";
                document.getElementById("wagesHeaderCategory").innerHTML = "Manpower Services - [Category Name] - [People Count] No.s";
                document.getElementById("wagesHeaderPeriod").innerHTML = "Contract Period [Start Date] to [End Date]";
                document.getElementById("wagesHeaderVendor").innerHTML = "[Vendor Name], [Vendor Address]";
                document.getElementById("wagesHeaderPayment").innerHTML = "Payment for the period [Start Date] to [End Date]";

                document.getElementById("wagesContractNoInput").value = "";
                document.getElementById("wagesContractDateInput").value = "";
                document.getElementById("wagesDatedOnInput").value = "";
                document.getElementById("wagesCategoryDescInput").value = "";
                document.getElementById("wagesPeriodInput").value = "";
                document.getElementById("wagesVendorNameInput").value = "";
                document.getElementById("wagesVendorAddressInput").value = "";

                document.getElementById("wagesTableBody").innerHTML = "";
                document.getElementById("wagesTotalPeople").textContent = "0";
                document.getElementById("wagesTotalDays").textContent = "0";
                document.getElementById("wagesPreviewArea").style.display = "none";
            }

            function loadWagesData() {
                const loader = document.getElementById("wagesLoader");
                const previewArea = document.getElementById("wagesPreviewArea");
                const yearVal = parseInt(document.getElementById("wagesYear").value);
                const monthVal = parseInt(document.getElementById("wagesMonth").value);
                const catVal = document.getElementById("wagesCategory").value;
                const contractSel = document.getElementById("wagesContract");
                const selectedCpId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;

                if (!catVal || catVal === "All" || !selectedCpId) {
                    showToast("Please select a Category and Contract Period.", "warning");
                    return;
                }

                loader.style.display = "block";
                previewArea.style.display = "none";

                Promise.all([
                    fetch('Documents.aspx/GetWagesMetadata', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal, contractPeriodId: selectedCpId })
                    }).then(r => r.json()),

                    fetch('Documents.aspx/GetCertificateData', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal, contractPeriodId: selectedCpId })
                    }).then(r => r.json())
                ])
                    .then(([metaRes, empRes]) => {
                        wagesMetadata = JSON.parse(metaRes.d || "{}");
                        wagesEmployeesData = JSON.parse(empRes.d || "[]");

                        if (wagesEmployeesData.error) {
                            showToast(wagesEmployeesData.error, "error");
                            loader.style.display = "none";
                            return;
                        }

                        if (wagesMetadata.DailyWage > 0) {
                            document.getElementById("wagesDailyRate").value = wagesMetadata.DailyWage;
                        } else {
                            document.getElementById("wagesDailyRate").value = "";
                        }

                        if (wagesMetadata.EpfRate !== undefined && wagesMetadata.EpfRate !== null) {
                            document.getElementById("wagesEpfRate").value = wagesMetadata.EpfRate;
                        }
                        if (wagesMetadata.EpfLimit !== undefined && wagesMetadata.EpfLimit !== null) {
                            document.getElementById("wagesEpfLimit").value = wagesMetadata.EpfLimit;
                        }
                        if (wagesMetadata.EpfCappedAmount !== undefined && wagesMetadata.EpfCappedAmount !== null) {
                            document.getElementById("wagesEpfCappedAmount").value = wagesMetadata.EpfCappedAmount;
                        }
                        if (wagesMetadata.GstRate !== undefined && wagesMetadata.GstRate !== null) {
                            document.getElementById("wagesGstRate").value = wagesMetadata.GstRate;
                        }

                        // Prefill editable fields
                        if (wagesMetadata && wagesMetadata.Contract) {
                            const contract = wagesMetadata.Contract;
                            document.getElementById("wagesContractNoInput").value = contract.GemId || "";
                            document.getElementById("wagesContractDateInput").value = contract.StartDate || "";
                            document.getElementById("wagesDatedOnInput").value = contract.VendorDatedOn || "";
                            const catInfo = getSelectedCategoryInfo(document.getElementById("wagesCategory"));
                            const catName = catInfo.cleanName;
                            const customDesc = wagesCategoryDescriptions[catVal] || wagesCategoryDescriptions[catName] || `Data Entry Operators(${catName})`;
                            document.getElementById("wagesCategoryDescInput").value = customDesc;
                            document.getElementById("wagesPeriodInput").value = contract.EndDate ? `${contract.StartDate} to ${contract.EndDate}` : `${contract.StartDate} onwards`;
                            document.getElementById("wagesVendorNameInput").value = contract.VendorName || "";
                            document.getElementById("wagesVendorAddressInput").value = contract.VendorAddress || "";
                        }

                        updateWagesPreview();
                        loader.style.display = "none";
                        previewArea.style.display = "block";
                        showToast(`Loaded wages calculation data successfully!`, "success");
                    })
                    .catch((err) => {
                        console.error(err);
                        loader.style.display = "none";
                        showToast("Failed to retrieve wages calculation data.", "error");
                    });
            }

            function updateWagesPreview() {
                if (!wagesEmployeesData || wagesEmployeesData.length === 0) return;

                const dailyRate = parseFloat(document.getElementById("wagesDailyRate").value) || 0;
                const epfRate = parseFloat(document.getElementById("wagesEpfRate").value) || 0;
                const epfLimit = parseFloat(document.getElementById("wagesEpfLimit").value) || 0;
                const serviceChargeRate = parseFloat(document.getElementById("wagesServiceChargeRate").value) || 0;
                const gstRate = parseFloat(document.getElementById("wagesGstRate").value) || 0;

                const epfMaxAmount = parseFloat(document.getElementById("wagesEpfCappedAmount").value) || 0;

                // Group employees by FinalDays
                const groups = {};
                wagesEmployeesData.forEach(emp => {
                    const days = emp.FinalDays;
                    groups[days] = (groups[days] || 0) + 1;
                });

                // Sort days descending
                const sortedDays = Object.keys(groups).map(Number).sort((a, b) => b - a);

                let bodyHtml = "";
                let slNo = 1;
                let totalPeople = 0;
                let totalWorkingDays = 0;
                let epfCappedCount = 0;
                let epfActualCount = 0;
                let epfActualSum = 0;

                sortedDays.forEach(days => {
                    const peopleCount = groups[days];
                    const paymentPerPerson = days * dailyRate;
                    const rowTotalDays = peopleCount * days;

                    totalPeople += peopleCount;
                    totalWorkingDays += rowTotalDays;

                    // EPF Capping calculation
                    if (paymentPerPerson >= epfLimit) {
                        epfCappedCount += peopleCount;
                    } else {
                        epfActualCount += peopleCount;
                        epfActualSum += (paymentPerPerson * (epfRate / 100)) * peopleCount;
                    }

                    bodyHtml += `
                    <tr>
                        <td style="border: 1px solid #000000; padding: 8px; text-align: center;">${slNo++}</td>
                        <td style="border: 1px solid #000000; padding: 8px; text-align: left;">${dailyRate.toFixed(2)}</td>
                        <td style="border: 1px solid #000000; padding: 8px; text-align: right;">${paymentPerPerson.toFixed(2)}</td>
                        <td style="border: 1px solid #000000; padding: 8px; text-align: center;">${peopleCount}</td>
                        <td style="border: 1px solid #000000; padding: 8px; text-align: center;">${days}</td>
                        <td style="border: 1px solid #000000; padding: 8px; text-align: right;">${rowTotalDays}</td>
                    </tr>
                `;
                });

                document.getElementById("wagesTableBody").innerHTML = bodyHtml;
                document.getElementById("wagesTotalPeople").textContent = totalPeople;
                document.getElementById("wagesTotalDays").textContent = totalWorkingDays;

                // Update dynamically generated Col C header with daily rate
                document.getElementById("wagesColCHeader").textContent = `Payment per person/per month Rs${dailyRate.toFixed(2)}/-PD`;

                // Calculations breakdown
                const wagesTotal = totalWorkingDays * dailyRate;
                const epfCappedTotal = epfCappedCount * epfMaxAmount;
                const subTotal = wagesTotal + epfCappedTotal + epfActualSum;
                const serviceCharge = subTotal * (serviceChargeRate / 100);
                const gst = subTotal * (gstRate / 100);
                const grandTotal = subTotal + serviceCharge + gst;

                // Set breakdown values on screen
                document.getElementById("wagesFormulaDesc").textContent = `${dailyRate}*${totalWorkingDays}`;
                document.getElementById("wagesAmountWages").textContent = wagesTotal.toFixed(2);

                document.getElementById("wagesFormulaEpfCapped").textContent = `EPF @${epfRate}%for ${epfCappedCount} persons`;
                document.getElementById("wagesAmountEpfCapped").textContent = epfCappedTotal.toFixed(2);

                document.getElementById("wagesFormulaEpfActual").textContent = `EPF @${epfRate}%for ${epfActualCount} person`;
                document.getElementById("wagesAmountEpfActual").textContent = epfActualSum.toFixed(2);

                document.getElementById("wagesAmountSubTotal").textContent = subTotal.toFixed(2);

                document.getElementById("wagesFormulaServiceCharge").textContent = `Service Charge  @${serviceChargeRate.toFixed(2)}% `;
                document.getElementById("wagesAmountServiceCharge").textContent = serviceCharge.toFixed(5);

                document.getElementById("wagesFormulaGst").textContent = `GST @${gstRate.toFixed(2)}%`;
                document.getElementById("wagesAmountGst").textContent = gst.toFixed(5);

                document.getElementById("wagesAmountGrandTotal").textContent = grandTotal.toFixed(2);

                // Break-up calculation based on the Basic Daily Wage Rate
                const epfDaily = (epfLimit * 0.12) / 26;
                const edliDaily = (epfLimit * 0.005) / 26;
                const adminDaily = (epfLimit * 0.005) / 26;
                const grossDaily = dailyRate + epfDaily + edliDaily + adminDaily;

                const categoryVal = document.getElementById("wagesCategory").value;
                window.wagesBreakupData = {
                    title: "VALUE AS PER GOVT VALUE",
                    category: `DEO (${categoryVal})`,
                    basic: dailyRate,
                    epf: epfDaily,
                    epfDesc: "EPF @ 12% of Basic Wages",
                    edli: edliDaily,
                    edliDesc: "EPF ELDI @ 0.5% of Basic Wages",
                    admin: adminDaily,
                    adminDesc: "EPF Admin @ 0.5% of Basic Wages",
                    gross: grossDaily
                };

                // Update header text previews from config panel inputs (with fallback placeholders)
                const contractNo = document.getElementById("wagesContractNoInput").value || "[Contract No]";
                const contractDate = document.getElementById("wagesContractDateInput").value || "[Contract Date]";
                const extraCode = document.getElementById("wagesExtraCodeInput").value || "";
                const categoryDesc = document.getElementById("wagesCategoryDescInput").value || "[Category Description]";
                const periodVal = document.getElementById("wagesPeriodInput").value || "[Start Date] to [End Date]";
                const vendorName = document.getElementById("wagesVendorNameInput").value || "[Vendor Name]";
                const vendorAddress = document.getElementById("wagesVendorAddressInput").value || "[Vendor Address]";
                const wagesDatedOn = document.getElementById("wagesDatedOnInput").value || "[Dated On]";

                const yValSelect = document.getElementById("wagesYear");
                if (!yValSelect || !yValSelect.value) return;
                const yVal = yValSelect.value;

                const mSelect = document.getElementById("wagesMonth");
                if (!mSelect || mSelect.selectedIndex === -1) return;
                const mText = mSelect.options[mSelect.selectedIndex].text;

                const daysInMonth = new Date(parseInt(yVal), parseInt(mSelect.value) + 1, 0).getDate();

                // Working days excluding Sundays in the month of payment
                let workingDaysExcludingSundays = 0;
                for (let d = 1; d <= daysInMonth; d++) {
                    const dayOfWeek = new Date(parseInt(yVal), parseInt(mSelect.value), d).getDay();
                    if (dayOfWeek !== 0) { // 0 = Sunday
                        workingDaysExcludingSundays++;
                    }
                }

                // Substitute placeholders in loaded templates
                const tpl1 = document.getElementById("txtWagesTplContract").value;
                const tpl2 = document.getElementById("txtWagesTplCategory").value;
                const tpl3 = document.getElementById("txtWagesTplPeriod").value;
                const tpl4 = document.getElementById("txtWagesTplVendor").value;
                const tpl5 = document.getElementById("txtWagesTplPayment").value;

                const paymentStart = `01 ${mText} ${yVal}`;
                const paymentEnd = `${daysInMonth} ${mText} ${yVal}`;

                const line1Html = replacePlaceholders(tpl1, "wages");
                const line2Html = replacePlaceholders(tpl2, "wages");
                const line3Html = replacePlaceholders(tpl3, "wages");
                const line4Html = replacePlaceholders(tpl4, "wages");
                const line5Html = replacePlaceholders(tpl5, "wages");

                document.getElementById("wagesHeaderContract").innerHTML = line1Html;
                document.getElementById("wagesHeaderCategory").innerHTML = line2Html;
                document.getElementById("wagesHeaderPeriod").innerHTML = line3Html;
                document.getElementById("wagesHeaderVendor").innerHTML = line4Html;
                document.getElementById("wagesHeaderPayment").innerHTML = line5Html;
            }

            function exportWagesToExcel() {
                if (typeof XLSX === "undefined") {
                    showToast("Spreadsheet library is not loaded.", "error");
                    return;
                }

                const table = document.getElementById("wagesTable");
                if (!table || wagesEmployeesData.length === 0) {
                    showToast("No data available to export.", "warning");
                    return;
                }

                const wb = XLSX.utils.book_new();
                const data = [];

                // Extract header text values
                const contractText = document.getElementById("wagesHeaderContract").innerText;
                const categoryText = document.getElementById("wagesHeaderCategory").innerText;
                const periodText = document.getElementById("wagesHeaderPeriod").innerText;
                const vendorText = document.getElementById("wagesHeaderVendor").innerText;
                const paymentText = document.getElementById("wagesHeaderPayment").innerText;

                data.push([contractText]);
                data.push([categoryText]);
                data.push([periodText]);
                data.push([vendorText]);
                data.push([paymentText]);
                data.push([]); // blank row

                // Table headers
                const colCHeaderText = document.getElementById("wagesColCHeader").innerText;
                data.push(["Sl No.", "Description", colCHeaderText, "No of people", "No of Days/Individual", "Total No. of working days"]);

                // Table rows
                const rows = document.querySelectorAll("#wagesTableBody tr");
                rows.forEach(tr => {
                    const cells = tr.querySelectorAll("td");
                    data.push([
                        parseInt(cells[0].innerText),
                        parseFloat(cells[1].innerText),
                        parseFloat(cells[2].innerText),
                        parseInt(cells[3].innerText),
                        parseInt(cells[4].innerText),
                        parseInt(cells[5].innerText)
                    ]);
                });

                // Table footer matching Excel cells exactly
                const totalPeople = parseInt(document.getElementById("wagesTotalPeople").textContent);
                const totalDays = parseInt(document.getElementById("wagesTotalDays").textContent);
                data.push(["", "", "Total No of People", totalPeople, "Total No of Days", totalDays]);

                // Summary items inside the main table
                const wagesFormula = document.getElementById("wagesFormulaDesc").innerText;
                const wagesVal = parseFloat(document.getElementById("wagesAmountWages").innerText.replace(/,/g, ''));
                data.push(["", "", wagesFormula, "", "", wagesVal]);

                const epfCappedFormula = document.getElementById("wagesFormulaEpfCapped").innerText;
                const epfCappedVal = parseFloat(document.getElementById("wagesAmountEpfCapped").innerText.replace(/,/g, ''));
                data.push(["", "", "", epfCappedFormula, "", epfCappedVal]);

                const epfActualFormula = document.getElementById("wagesFormulaEpfActual").innerText;
                const epfActualVal = parseFloat(document.getElementById("wagesAmountEpfActual").innerText.replace(/,/g, ''));
                data.push(["", "", "", epfActualFormula, "", epfActualVal]);

                const subTotalVal = parseFloat(document.getElementById("wagesAmountSubTotal").innerText.replace(/,/g, ''));
                data.push(["", "", "", "Sub Total", "", subTotalVal]);

                const serviceChargeFormula = document.getElementById("wagesFormulaServiceCharge").innerText;
                const serviceChargeVal = parseFloat(document.getElementById("wagesAmountServiceCharge").innerText.replace(/,/g, ''));
                data.push(["", "", "", serviceChargeFormula, "", serviceChargeVal]);

                const gstFormula = document.getElementById("wagesFormulaGst").innerText;
                const gstVal = parseFloat(document.getElementById("wagesAmountGst").innerText.replace(/,/g, ''));
                data.push(["", "", "", "", gstFormula, gstVal]);

                const grandTotalVal = parseFloat(document.getElementById("wagesAmountGrandTotal").innerText.replace(/,/g, ''));
                data.push(["", "", "", "Total Cost Per Month", "", grandTotalVal]);

                const ws = XLSX.utils.aoa_to_sheet(data);

                // Merges
                ws["!merges"] = [
                    { s: { r: 0, c: 0 }, e: { r: 0, c: 5 } },
                    { s: { r: 1, c: 0 }, e: { r: 1, c: 5 } },
                    { s: { r: 2, c: 0 }, e: { r: 2, c: 5 } },
                    { s: { r: 3, c: 0 }, e: { r: 3, c: 5 } },
                    { s: { r: 4, c: 0 }, e: { r: 4, c: 5 } }
                ];

                // Widths
                ws["!cols"] = [
                    { wch: 8 },
                    { wch: 45 },
                    { wch: 30 },
                    { wch: 15 },
                    { wch: 20 },
                    { wch: 25 }
                ];

                // Apply formatting styles to ws
                // Headers styling (Row 1 to 5) -> Calibri 11 Bold, Centered
                const headerRowStyle = {
                    font: { bold: true, name: "Calibri", sz: 11 },
                    alignment: { horizontal: "center", vertical: "center" }
                };
                for (let r = 0; r < 5; r++) {
                    const cellRef = "A" + (r + 1);
                    if (ws[cellRef]) ws[cellRef].s = headerRowStyle;
                }

                // Table headers (Row 7) -> Calibri 11 Bold, Centered, Thin border
                const colHeaderStyle = {
                    font: { bold: true, name: "Calibri", sz: 11 },
                    alignment: { horizontal: "center", vertical: "center", wrapText: true },
                    border: {
                        top: { style: "thin", color: { auto: 1 } },
                        bottom: { style: "thin", color: { auto: 1 } },
                        left: { style: "thin", color: { auto: 1 } },
                        right: { style: "thin", color: { auto: 1 } }
                    }
                };
                for (let c = 0; c < 6; c++) {
                    const cellRef = String.fromCharCode(65 + c) + "7";
                    if (ws[cellRef]) ws[cellRef].s = colHeaderStyle;
                }

                // Body data rows -> Calibri 11, Thin border, proper alignments
                const bodyRowsCount = rows.length;
                for (let i = 0; i < bodyRowsCount; i++) {
                    const rowNum = 8 + i;
                    for (let c = 0; c < 6; c++) {
                        const cellRef = String.fromCharCode(65 + c) + rowNum;
                        if (ws[cellRef]) {
                            let alignH = "center";
                            if (c === 1) alignH = "left";
                            if (c === 2 || c === 5) alignH = "right";

                            ws[cellRef].s = {
                                font: { name: "Calibri", sz: 11 },
                                alignment: { horizontal: alignH, vertical: "center" },
                                border: {
                                    top: { style: "thin", color: { auto: 1 } },
                                    bottom: { style: "thin", color: { auto: 1 } },
                                    left: { style: "thin", color: { auto: 1 } },
                                    right: { style: "thin", color: { auto: 1 } }
                                }
                            };
                        }
                    }
                }

                // Summary footer rows -> Calibri 11 Bold, Thin border, aligned right
                const summaryStartRow = 8 + bodyRowsCount;
                for (let r = 0; r < 8; r++) {
                    const rowNum = summaryStartRow + r;
                    for (let c = 0; c < 6; c++) {
                        const cellRef = String.fromCharCode(65 + c) + rowNum;
                        if (ws[cellRef] && ws[cellRef].v !== "") {
                            let alignH = "right";
                            if (c === 2 || c === 3) alignH = "left";
                            if (c === 4) alignH = "right";

                            const isGrandTotal = (r === 7);

                            ws[cellRef].s = {
                                font: { bold: true, name: "Calibri", sz: 11 },
                                alignment: { horizontal: alignH, vertical: "center" },
                                border: {
                                    top: { style: "thin", color: { auto: 1 } },
                                    bottom: { style: isGrandTotal ? "double" : "thin", color: { auto: 1 } },
                                    left: { style: "thin", color: { auto: 1 } },
                                    right: { style: "thin", color: { auto: 1 } }
                                }
                            };
                        }
                    }
                }

                const monthText = document.getElementById("wagesMonth").options[document.getElementById("wagesMonth").selectedIndex].text;
                XLSX.utils.book_append_sheet(wb, ws, `${monthText} Salarywges`);

                // ── Build Break UP sheet ──
                const breakupData = [];
                const bData = window.wagesBreakupData || {
                    title: "VALUE AS PER GOVT VALUE",
                    category: "DEO (Skilled)",
                    basic: 981,
                    epf: 69.23,
                    epfDesc: "EPF @ 12% of Basic Wages",
                    edli: 2.88,
                    edliDesc: "EPF ELDI @ 0.5% of Basic Wages",
                    admin: 2.88,
                    adminDesc: "EPF Admin @ 0.5% of Basic Wages",
                    gross: 1055.99
                };
                breakupData.push([bData.title]);
                breakupData.push([bData.category]);
                breakupData.push(["Sl No.", "Description", "Govt Value"]);

                breakupData.push(["1", "Basic Wages per day", bData.basic]);
                breakupData.push(["2", bData.epfDesc, bData.epf]);
                breakupData.push(["3", bData.edliDesc, bData.edli]);
                breakupData.push(["4", bData.adminDesc, bData.admin]);
                breakupData.push(["5", "Gross Salary/Day", bData.gross]);

                const wsBu = XLSX.utils.aoa_to_sheet(breakupData);

                wsBu["!merges"] = [
                    { s: { r: 0, c: 0 }, e: { r: 0, c: 2 } },
                    { s: { r: 1, c: 0 }, e: { r: 1, c: 2 } }
                ];

                wsBu["!cols"] = [
                    { wch: 8 },
                    { wch: 45 },
                    { wch: 15 }
                ];

                // Apply formatting styles to wsBu
                if (wsBu["A1"]) {
                    wsBu["A1"].s = {
                        font: { bold: true, name: "Calibri", sz: 11 },
                        alignment: { horizontal: "center", vertical: "center" }
                    };
                }
                if (wsBu["A2"]) {
                    wsBu["A2"].s = {
                        font: { bold: true, name: "Calibri", sz: 11 },
                        alignment: { horizontal: "center", vertical: "center" }
                    };
                }

                for (let c = 0; c < 3; c++) {
                    const cellRef = String.fromCharCode(65 + c) + "3";
                    if (wsBu[cellRef]) {
                        wsBu[cellRef].s = {
                            font: { bold: true, name: "Calibri", sz: 11 },
                            alignment: { horizontal: "center", vertical: "center" },
                            border: {
                                top: { style: "thin", color: { auto: 1 } },
                                bottom: { style: "thin", color: { auto: 1 } },
                                left: { style: "thin", color: { auto: 1 } },
                                right: { style: "thin", color: { auto: 1 } }
                            }
                        };
                    }
                }

                for (let r = 4; r <= 8; r++) {
                    for (let c = 0; c < 3; c++) {
                        const cellRef = String.fromCharCode(65 + c) + r;
                        if (wsBu[cellRef]) {
                            let alignH = "center";
                            if (c === 1) alignH = "left";
                            if (c === 2) alignH = "right";

                            const isGross = (r === 8);

                            wsBu[cellRef].s = {
                                font: { name: "Calibri", sz: 11, bold: isGross },
                                alignment: { horizontal: alignH, vertical: "center" },
                                border: {
                                    top: { style: "thin", color: { auto: 1 } },
                                    bottom: { style: isGross ? "double" : "thin", color: { auto: 1 } },
                                    left: { style: "thin", color: { auto: 1 } },
                                    right: { style: "thin", color: { auto: 1 } }
                                }
                            };
                        }
                    }
                }

                XLSX.utils.book_append_sheet(wb, wsBu, `${monthText} salary breakup`);

                const categoryVal = document.getElementById("wagesCategory").value;
                const yearVal = document.getElementById("wagesYear").value;
                const filename = `Wages_Calculation_${categoryVal}_${monthText}_${yearVal}.xlsx`;

                XLSX.writeFile(wb, filename);
                showToast("Wages Calculation sheet exported successfully!", "success");
            }

            function updateHeaderPreview() {
                const catInfo = getSelectedCategoryInfo(document.getElementById("category"));
                const catText = catInfo.cleanName;
                const vendorNameVal = document.getElementById("vendorName").value || "[Vendor Name]";
                const vendorAddrVal = document.getElementById("vendorAddress").value || "[Vendor Address]";
                const gemNoVal = document.getElementById("gemContractNo").value || "[GeM Contract No]";
                const gemDateVal = document.getElementById("gemContractDate").value || "[Contract Date]";
                const certDatedOnVal = document.getElementById("certDatedOnInput")?.value || "[Dated On]";

                const ySelect = document.getElementById("year");
                if (!ySelect || !ySelect.value) return;
                const yText = ySelect.value;

                const mSelect = document.getElementById("month");
                if (!mSelect || mSelect.selectedIndex === -1) return;
                const mText = mSelect.options[mSelect.selectedIndex].text;

                const daysInMonth = new Date(parseInt(yText), parseInt(mSelect.value) + 1, 0).getDate();

                // Set Title dynamically
                document.getElementById("certTitle").textContent = "CERTIFICATE";

                let catLabel = catInfo.val !== "All" ? catText : "Contract Staff";
                const startDateStr = `01-${mText}-${yText}`;
                const endDateStr = `${daysInMonth}-${mText}-${yText}`;

                // Read the template values from the textareas
                const tpl1El = document.getElementById("txtTplDesc1");
                const tpl2El = document.getElementById("txtTplDesc2");

                let currentTpl1 = tpl1El && tpl1El.value ? tpl1El.value : tplDesc1;
                let currentTpl2 = tpl2El && tpl2El.value ? tpl2El.value : tplDesc2;

                // Perform global replacements
                let desc1 = replacePlaceholders(currentTpl1, "attendance");
                let desc2 = replacePlaceholders(currentTpl2, "attendance");

                document.getElementById("certDesc1").innerHTML = desc1;
                document.getElementById("certDesc2").innerHTML = desc2;
            }

            function loadTemplates() {
                fetch('Documents.aspx/GetTemplates', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                })
                    .then(r => r.json())
                    .then(res => {
                        const dict = JSON.parse(res.d || "{}");
                        if (dict.AttDesc1) {
                            tplDesc1 = dict.AttDesc1;
                        }
                        if (dict.AttDesc2) {
                            tplDesc2 = dict.AttDesc2;
                        }
                        if (dict.SatDesc1) {
                            tplSatDesc1 = dict.SatDesc1;
                        }
                        if (dict.SatDesc2) {
                            tplSatDesc2 = dict.SatDesc2;
                        }
                        if (dict.SatDesc3) {
                            tplSatDesc3 = dict.SatDesc3;
                        }
                        const tpl1El = document.getElementById("txtTplDesc1");
                        const tpl2El = document.getElementById("txtTplDesc2");
                        if (tpl1El) tpl1El.value = tplDesc1;
                        if (tpl2El) tpl2El.value = tplDesc2;

                        const satTpl1El = document.getElementById("txtSatTplDesc1");
                        const satTpl2El = document.getElementById("txtSatTplDesc2");
                        const satTpl3El = document.getElementById("txtSatTplDesc3");
                        if (satTpl1El) satTpl1El.value = tplSatDesc1;
                        if (satTpl2El) satTpl2El.value = tplSatDesc2;
                        if (satTpl3El) satTpl3El.value = tplSatDesc3;

                        // Load saved signatory, designation, services, pcno
                        const sigEl = document.getElementById("satSignatoryInput");
                        const desEl = document.getElementById("satDesignationInput");
                        const svcEl = document.getElementById("satServicesInput");
                        const pcnoEl = document.getElementById("satSignatoryPcnoInput");
                        if (dict.SatSignatory && sigEl) sigEl.value = dict.SatSignatory;
                        if (dict.SatDesignation && desEl) desEl.value = dict.SatDesignation;
                        if (dict.SatServices && svcEl) svcEl.value = dict.SatServices;
                        if (dict.SatSignatoryPcno && pcnoEl) pcnoEl.value = dict.SatSignatoryPcno;

                        // Load and apply layout settings
                        const satFontSizeEl = document.getElementById('satFontSizeInput');
                        const satSectionSpacingEl = document.getElementById('satSectionSpacingInput');
                        const satSigSpacingEl = document.getElementById('satSigSpacingInput');
                        const savedFontSize = parseInt(dict.SatFontSize) || 14;
                        const savedSectionSpacing = parseInt(dict.SatSectionSpacing) || 25;
                        const savedSigSpacing = parseInt(dict.SatSigSpacing) || 50;
                        if (satFontSizeEl) satFontSizeEl.value = savedFontSize;
                        if (satSectionSpacingEl) satSectionSpacingEl.value = savedSectionSpacing;
                        if (satSigSpacingEl) satSigSpacingEl.value = savedSigSpacing;
                        applySatLayout(savedFontSize, savedSectionSpacing, savedSigSpacing);

                        if (dict.CovPhone) tplCovPhone = dict.CovPhone;
                        if (dict.CovRefNo) tplCovRefNo = dict.CovRefNo;
                        if (dict.CovSubject) tplCovSubject = dict.CovSubject;
                        if (dict.CovBody) tplCovBody = dict.CovBody;
                        if (dict.CovSignatory) tplCovSignatory = dict.CovSignatory;
                        if (dict.CovDesignation) tplCovDesignation = dict.CovDesignation;
                        if (dict.CovAuthority) tplCovAuthority = dict.CovAuthority;
                        if (dict.CovRecipient) tplCovRecipient = dict.CovRecipient;

                        if (dict.WagesHdrContract) tplWagesHdrContract = dict.WagesHdrContract;
                        if (dict.WagesHdrCategory) tplWagesHdrCategory = dict.WagesHdrCategory;
                        if (dict.WagesHdrPeriod) tplWagesHdrPeriod = dict.WagesHdrPeriod;
                        if (dict.WagesHdrVendor) tplWagesHdrVendor = dict.WagesHdrVendor;
                        if (dict.WagesHdrPayment) tplWagesHdrPayment = dict.WagesHdrPayment;
                        if (dict.WagesDesc_Skilled) wagesCategoryDescriptions["Skilled"] = dict.WagesDesc_Skilled;
                        if (dict.WagesDesc_Semi_Skilled) wagesCategoryDescriptions["Semi-Skilled"] = dict.WagesDesc_Semi_Skilled;
                        if (dict.WagesDesc_Unskilled) wagesCategoryDescriptions["Unskilled"] = dict.WagesDesc_Unskilled;

                        const covPhoneEl = document.getElementById("covPhoneInput");
                        const covRefNoEl = document.getElementById("covRefNoInput");
                        const covSubjectEl = document.getElementById("covSubjectInput");
                        const covBodyEl = document.getElementById("covBodyInput");
                        const covSignatoryEl = document.getElementById("covSignatoryInput");
                        const covDesignationEl = document.getElementById("covDesignationInput");
                        const covAuthorityEl = document.getElementById("covAuthorityInput");
                        const covRecipientEl = document.getElementById("covRecipientInput");
                        const covPcnoEl = document.getElementById("covSignatoryPcnoInput");

                        if (covPhoneEl) covPhoneEl.value = tplCovPhone;
                        if (covRefNoEl) covRefNoEl.value = tplCovRefNo;
                        if (covSubjectEl) covSubjectEl.value = tplCovSubject;
                        if (covBodyEl) covBodyEl.value = tplCovBody;
                        if (covSignatoryEl) covSignatoryEl.value = tplCovSignatory;
                        if (covDesignationEl) covDesignationEl.value = tplCovDesignation;
                        if (covAuthorityEl) covAuthorityEl.value = tplCovAuthority;
                        if (covRecipientEl) covRecipientEl.value = tplCovRecipient;
                        if (dict.CovSignatoryPcno && covPcnoEl) covPcnoEl.value = dict.CovSignatoryPcno;

                        // Load and apply covering letter layout settings
                        const covFontSizeEl = document.getElementById('covFontSizeInput');
                        const covSectionSpacingEl = document.getElementById('covSectionSpacingInput');
                        const covSigSpacingEl = document.getElementById('covSigSpacingInput');
                        const savedCovFontSize = parseInt(dict.CovFontSize) || 12;
                        const savedCovSectionSpacing = parseInt(dict.CovSectionSpacing) || 24;
                        const savedCovSigSpacing = parseInt(dict.CovSigSpacing) || 50;
                        if (covFontSizeEl) covFontSizeEl.value = savedCovFontSize;
                        if (covSectionSpacingEl) covSectionSpacingEl.value = savedCovSectionSpacing;
                        if (covSigSpacingEl) covSigSpacingEl.value = savedCovSigSpacing;
                        applyCovLayout(savedCovFontSize, savedCovSectionSpacing, savedCovSigSpacing);


                        const w1 = document.getElementById("txtWagesTplContract");
                        const w2 = document.getElementById("txtWagesTplCategory");
                        const w3 = document.getElementById("txtWagesTplPeriod");
                        const w4 = document.getElementById("txtWagesTplVendor");
                        const w5 = document.getElementById("txtWagesTplPayment");

                        if (w1) w1.value = tplWagesHdrContract;
                        if (w2) w2.value = tplWagesHdrCategory;
                        if (w3) w3.value = tplWagesHdrPeriod;
                        if (w4) w4.value = tplWagesHdrVendor;
                        if (w5) w5.value = tplWagesHdrPayment;



                        if (dict.RepTpl1Heading1) tplRepTpl1H1 = dict.RepTpl1Heading1;
                        if (dict.RepTpl1Heading2) tplRepTpl1H2 = dict.RepTpl1Heading2;
                        if (dict.RepTpl2Heading1) tplRepTpl2H1 = dict.RepTpl2Heading1;
                        if (dict.RepTpl2Heading2) tplRepTpl2H2 = dict.RepTpl2Heading2;

                        const rep1 = document.getElementById("txtRepTpl1Heading1");
                        const rep2 = document.getElementById("txtRepTpl1Heading2");
                        const rep3 = document.getElementById("txtRepTpl2Heading1");
                        const rep4 = document.getElementById("txtRepTpl2Heading2");
                        if (rep1) rep1.value = tplRepTpl1H1;
                        if (rep2) rep2.value = tplRepTpl1H2;
                        if (rep3) rep3.value = tplRepTpl2H1;
                        if (rep4) rep4.value = tplRepTpl2H2;

                        updateHeaderPreview();
                        updateSatPreview();
                        updateCovPreview();
                        if (typeof onWagesTplCategoryChange === 'function') {
                            onWagesTplCategoryChange();
                        }
                    })
                    .catch(() => {
                        const tpl1El = document.getElementById("txtTplDesc1");
                        const tpl2El = document.getElementById("txtTplDesc2");
                        if (tpl1El) tpl1El.value = tplDesc1;
                        if (tpl2El) tpl2El.value = tplDesc2;

                        const satTpl1El = document.getElementById("txtSatTplDesc1");
                        const satTpl2El = document.getElementById("txtSatTplDesc2");
                        const satTpl3El = document.getElementById("txtSatTplDesc3");
                        if (satTpl1El) satTpl1El.value = tplSatDesc1;
                        if (satTpl2El) satTpl2El.value = tplSatDesc2;
                        if (satTpl3El) satTpl3El.value = tplSatDesc3;

                        const covPhoneEl = document.getElementById("covPhoneInput");
                        const covRefNoEl = document.getElementById("covRefNoInput");
                        const covSubjectEl = document.getElementById("covSubjectInput");
                        const covBodyEl = document.getElementById("covBodyInput");
                        const covSignatoryEl = document.getElementById("covSignatoryInput");
                        const covDesignationEl = document.getElementById("covDesignationInput");
                        const covAuthorityEl = document.getElementById("covAuthorityInput");
                        const covRecipientEl = document.getElementById("covRecipientInput");

                        if (covPhoneEl) covPhoneEl.value = tplCovPhone;
                        if (covRefNoEl) covRefNoEl.value = tplCovRefNo;
                        if (covSubjectEl) covSubjectEl.value = tplCovSubject;
                        if (covBodyEl) covBodyEl.value = tplCovBody;
                        if (covSignatoryEl) covSignatoryEl.value = tplCovSignatory;
                        if (covDesignationEl) covDesignationEl.value = tplCovDesignation;
                        if (covAuthorityEl) covAuthorityEl.value = tplCovAuthority;
                        if (covRecipientEl) covRecipientEl.value = tplCovRecipient;

                        const w1 = document.getElementById("txtWagesTplContract");
                        const w2 = document.getElementById("txtWagesTplCategory");
                        const w3 = document.getElementById("txtWagesTplPeriod");
                        const w4 = document.getElementById("txtWagesTplVendor");
                        const w5 = document.getElementById("txtWagesTplPayment");

                        if (w1) w1.value = tplWagesHdrContract;
                        if (w2) w2.value = tplWagesHdrCategory;
                        if (w3) w3.value = tplWagesHdrPeriod;
                        if (w4) w4.value = tplWagesHdrVendor;
                        if (w5) w5.value = tplWagesHdrPayment;

                        const rep1 = document.getElementById("txtRepTpl1Heading1");
                        const rep2 = document.getElementById("txtRepTpl1Heading2");
                        const rep3 = document.getElementById("txtRepTpl2Heading1");
                        const rep4 = document.getElementById("txtRepTpl2Heading2");
                        if (rep1) rep1.value = tplRepTpl1H1;
                        if (rep2) rep2.value = tplRepTpl1H2;
                        if (rep3) rep3.value = tplRepTpl2H1;
                        if (rep4) rep4.value = tplRepTpl2H2;

                        updateHeaderPreview();
                        updateSatPreview();
                        updateCovPreview();
                        showToast("Failed to load templates from database. Using defaults.", "warning");
                    });
            }

            function saveTpl() {
                const desc1 = document.getElementById("txtTplDesc1").value;
                const desc2 = document.getElementById("txtTplDesc2").value;

                if (!desc1.trim() || !desc2.trim()) {
                    showToast("Templates cannot be empty.", "warning");
                    return;
                }

                fetch('Documents.aspx/SaveTemplates', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ desc1: desc1, desc2: desc2 })
                })
                    .then(r => r.json())
                    .then(res => {
                        const data = JSON.parse(res.d || "{}");
                        if (data.status === "success") {
                            tplDesc1 = desc1;
                            tplDesc2 = desc2;
                            showToast("Templates saved successfully to database.", "success");
                            updateHeaderPreview();
                        } else {
                            showToast(data.message || "Failed to save templates.", "error");
                        }
                    })
                    .catch(() => showToast("Error saving templates.", "error"));
            }

            function saveSatTpl() {
                const desc1 = document.getElementById("txtSatTplDesc1").value;
                const desc2 = document.getElementById("txtSatTplDesc2").value;
                const desc3 = document.getElementById("txtSatTplDesc3").value;
                const signatory = document.getElementById("satSignatoryInput").value;
                const designation = document.getElementById("satDesignationInput").value;
                const services = document.getElementById("satServicesInput").value;
                const pcno = document.getElementById("satSignatoryPcnoInput")?.value || "";
                const fontSizePt = parseInt(document.getElementById("satFontSizeInput")?.value) || 14;
                const sectionSpacingPt = parseInt(document.getElementById("satSectionSpacingInput")?.value) || 25;
                const sigSpacingPt = parseInt(document.getElementById("satSigSpacingInput")?.value) || 50;

                if (!desc1.trim() || !desc2.trim() || !desc3.trim()) {
                    showToast("Templates cannot be empty.", "warning");
                    return;
                }

                fetch('Documents.aspx/SaveSatTemplates', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ desc1: desc1, desc2: desc2, desc3: desc3, signatory: signatory, designation: designation, services: services, pcno: pcno, fontSizePt: fontSizePt, sectionSpacingPt: sectionSpacingPt, sigSpacingPt: sigSpacingPt })
                })
                    .then(r => r.json())
                    .then(res => {
                        const data = JSON.parse(res.d || "{}");
                        if (data.status === "success") {
                            tplSatDesc1 = desc1;
                            tplSatDesc2 = desc2;
                            tplSatDesc3 = desc3;
                            applySatLayout(fontSizePt, sectionSpacingPt, sigSpacingPt);
                            showToast("Satisfactory Certificate settings saved successfully.", "success");
                            updateSatPreview();
                        } else {
                            showToast(data.message || "Failed to save.", "error");
                        }
                    })
                    .catch(() => showToast("Error saving templates.", "error"));
            }

            function fetchSignatoryDetails() {
                const pcnoInput = document.getElementById("satSignatoryPcnoInput");
                const pcno = pcnoInput ? pcnoInput.value.trim() : "";
                if (!pcno) {
                    showToast("Please enter a PCNO first.", "warning");
                    return;
                }

                showToast("Fetching signatory details...", "info");

                fetch('Documents.aspx/GetEmployeeDetailsByPCNO', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ pcno: pcno })
                })
                .then(r => r.json())
                .then(res => {
                    const data = JSON.parse(res.d || "{}");
                    if (data.status === "success") {
                        const sigInput = document.getElementById("satSignatoryInput");
                        const desInput = document.getElementById("satDesignationInput");
                        
                        if (sigInput) sigInput.value = data.name || "";
                        if (desInput) desInput.value = data.designation || "";
                        
                        showToast("Signatory details fetched successfully!", "success");
                        updateSatPreview();
                    } else {
                        showToast(data.message || "Failed to fetch details.", "error");
                    }
                })
                .catch(err => {
                    console.error(err);
                    showToast("Error communicating with backend.", "error");
                });
            }

            function saveWagesTpl() {
                const hContract = document.getElementById("txtWagesTplContract").value;
                const hCategory = document.getElementById("txtWagesTplCategory").value;
                const hPeriod = document.getElementById("txtWagesTplPeriod").value;
                const hVendor = document.getElementById("txtWagesTplVendor").value;
                const hPayment = document.getElementById("txtWagesTplPayment").value;
                const catVal = document.getElementById("wagesTplCategorySelect").value;
                const catDescVal = document.getElementById("wagesTplCategoryDescInput").value;


                if (!hContract.trim() || !hCategory.trim() || !hPeriod.trim() || !hVendor.trim() || !hPayment.trim()) {
                    showToast("Templates cannot be empty.", "warning");
                    return;
                }
                if (!catVal || catVal === "All" || !catDescVal.trim()) {
                    showToast("Category and Category Description cannot be empty.", "warning");
                    return;
                }


                fetch('Documents.aspx/SaveWagesTemplates', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        hdrContract: hContract,
                        hdrCategory: hCategory,
                        hdrPeriod: hPeriod,
                        hdrVendor: hVendor,
                        hdrPayment: hPayment,
                        category: catVal,
                        categoryDesc: catDescVal
                    })
                })
                    .then(r => r.json())
                    .then(res => {
                        const data = JSON.parse(res.d || "{}");
                        if (data.status === "success") {
                            tplWagesHdrContract = hContract;
                            tplWagesHdrCategory = hCategory;
                            tplWagesHdrPeriod = hPeriod;
                            tplWagesHdrVendor = hVendor;
                            tplWagesHdrPayment = hPayment;
                            wagesCategoryDescriptions[catVal] = catDescVal;



                            updateWagesPreview();
                            showToast(data.message || "Templates saved successfully.", "success");
                        } else {
                            showToast(data.message || "Failed to save templates.", "error");
                        }
                    })
                    .catch(() => showToast("Error saving templates.", "error"));
            }

            function saveReportTpl() {
                const t1h1 = document.getElementById("txtRepTpl1Heading1").value;
                const t1h2 = document.getElementById("txtRepTpl1Heading2").value;
                const t2h1 = document.getElementById("txtRepTpl2Heading1").value;
                const t2h2 = document.getElementById("txtRepTpl2Heading2").value;

                if (!t1h1.trim() || !t1h2.trim() || !t2h1.trim() || !t2h2.trim()) {
                    showToast("Templates cannot be empty.", "warning");
                    return;
                }

                fetch('Documents.aspx/SaveReportTemplates', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        tpl1H1: t1h1,
                        tpl1H2: t1h2,
                        tpl2H1: t2h1,
                        tpl2H2: t2h2
                    })
                })
                    .then(r => r.json())
                    .then(res => {
                        const data = JSON.parse(res.d || "{}");
                        if (data.status === "success") {
                            tplRepTpl1H1 = t1h1;
                            tplRepTpl1H2 = t1h2;
                            tplRepTpl2H1 = t2h1;
                            tplRepTpl2H2 = t2h2;

                            onRepTemplateSelectChange();
                            showToast(data.message || "Templates saved successfully.", "success");
                        } else {
                            showToast(data.message || "Failed to save templates.", "error");
                        }
                    })
                    .catch(() => showToast("Error saving templates.", "error"));
            }

            // Fetch Live Attendance Data
            function loadData() {
                const yearElem = document.getElementById("year");
                const monthElem = document.getElementById("month");
                const catElem = document.getElementById("category");
                if (!yearElem || !monthElem || !catElem || !yearElem.value || !monthElem.value || !catElem.value) return;
                const yearVal = parseInt(yearElem.value);
                const monthVal = parseInt(monthElem.value);
                const catVal = catElem.value;
                if (isNaN(yearVal) || isNaN(monthVal)) return;

                const loader = document.getElementById("previewLoader");
                const previewArea = document.getElementById("previewArea");

                loader.style.display = "block";
                previewArea.style.display = "none";
                const contractSel = document.getElementById("contract");
                const selectedCpId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;

                fetch('Documents.aspx/GetCertificateData', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal, contractPeriodId: selectedCpId })
                })
                    .then(r => r.json())
                    .then(res => {
                        employeesData = JSON.parse(res.d || "[]");
                        if (employeesData.error) {
                            showToast(employeesData.error, "error");
                            loader.style.display = "none";
                            return;
                        }
                        renderPreviewTable();
                        loader.style.display = "none";
                        previewArea.style.display = "block";
                        showToast(`Loaded ${employeesData.length} records successfully!`, "success");
                    })
                    .catch(() => {
                        loader.style.display = "none";
                        showToast("Failed to retrieve certificate data.", "error");
                    });
            }

            // Render table dynamically
            function renderPreviewTable() {
                const tableBody = document.querySelector("#certTable tbody");
                if (!tableBody) return;

                let bodyHtml = "";
                let sNoIdx = 1;

                if (employeesData.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="10" class="text-center font-weight-bold py-4">No employees matching search criteria in this month.</td></tr>`;
                    return;
                }

                employeesData.forEach(emp => {
                    bodyHtml += "<tr>";
                    bodyHtml += `<td class="col-sno">${sNoIdx++}</td>`;
                    bodyHtml += `<td class="col-id">${emp.EmployeeId}</td>`;
                    bodyHtml += `<td class="col-masterid" style="display: none;">${emp.MasterId}</td>`;
                    bodyHtml += `<td class="col-name text-left" style="text-align: left; padding-left: 20px; font-weight: bold;">${emp.Name}</td>`;
                    bodyHtml += `<td class="col-present" style="display: none;">${emp.PresentDays}</td>`;
                    bodyHtml += `<td class="col-final" style="${emp.IsOverridden ? 'color: #ea580c; font-weight: bold;' : ''}">${emp.FinalDays}</td>`;
                    bodyHtml += `<td class="col-paid">${emp.Paid}</td>`;
                    bodyHtml += `<td class="col-unpaid">${emp.Unpaid}</td>`;
                    bodyHtml += `<td class="col-satcut">${emp.SatCut}</td>`;

                    // Remarks builders
                    const remarkCellVal = getRemarksString(emp);
                    bodyHtml += `<td class="col-remarks text-left" style="text-align: left;">${remarkCellVal}</td>`;
                    bodyHtml += "</tr>";
                });

                tableBody.innerHTML = bodyHtml;

                // Set initial visibility states based on configuration checkmarks
                applyAllColumnToggles();
            }

            // Auto-remarks string builder
            function getRemarksString(emp) {
                const parts = [];
                const includeJoinResign = document.getElementById("remJoinResign").checked;
                const includeOverride = document.getElementById("remOverride").checked;
                const includePair = document.getElementById("remPairs").checked;
                const includeSatEdit = document.getElementById("remSatEdit").checked;
                const includeCellSpecific = document.getElementById("remCellSpecific").checked;

                if (includeJoinResign && emp.JoinResignRemark) parts.push(emp.JoinResignRemark);
                if (includeOverride && emp.OverrideRemark) parts.push(emp.OverrideRemark);
                if (includePair && emp.LeavePairRemark) parts.push(emp.LeavePairRemark);
                if (includeSatEdit && emp.SaturdayRemark) parts.push(emp.SaturdayRemark);
                if (includeCellSpecific && emp.CellRemarks) parts.push(emp.CellRemarks);

                return parts.join("; ");
            }

            // Rebuild Remarks Column values when builder checkboxes change (preserving SNo index and DOM elements)
            function rebuildRemarksColumn() {
                const rows = document.querySelectorAll("#certTable tbody tr");
                if (rows.length === 0 || employeesData.length === 0) return;

                rows.forEach((row, i) => {
                    const emp = employeesData[i];
                    if (!emp) return;
                    const remarksCell = row.querySelector(".col-remarks");
                    if (remarksCell) {
                        remarksCell.textContent = getRemarksString(emp);
                    }
                });
                showToast("Remarks column rebuilt.", "success");
            }

            // Dynamic column toggle (Client-side style update)
            function toggleColumn(colClass, isChecked) {
                const elements = document.querySelectorAll("#certTable ." + colClass);
                elements.forEach(el => {
                    el.style.display = isChecked ? "" : "none";
                });
            }

            function applyAllColumnToggles() {
                toggleColumn("col-sno", document.getElementById("colSNo").checked);
                toggleColumn("col-id", document.getElementById("colID").checked);
                toggleColumn("col-masterid", document.getElementById("colMasterID").checked);
                toggleColumn("col-name", document.getElementById("colName").checked);
                toggleColumn("col-present", document.getElementById("colPresent").checked);
                toggleColumn("col-final", document.getElementById("colFinal").checked);
                toggleColumn("col-paid", document.getElementById("colPaid").checked);
                toggleColumn("col-unpaid", document.getElementById("colUnpaid").checked);
                toggleColumn("col-satcut", document.getElementById("colSatCut").checked);
                toggleColumn("col-remarks", document.getElementById("colRemarks").checked);
            }

            // Client-side Excel export mirroring active DOM modifications
            function exportToExcel() {
                if (typeof XLSX === "undefined") {
                    showToast("Spreadsheet library is not loaded.", "error");
                    return;
                }

                const table = document.getElementById("certTable");
                if (!table || employeesData.length === 0) {
                    showToast("No data available to export.", "warning");
                    return;
                }

                // Helper to decode HTML entities (like &amp; to &)
                function decodeHTMLEntities(text) {
                    if (!text) return "";
                    const temp = document.createElement('div');
                    temp.innerHTML = text;
                    return temp.textContent || temp.innerText || "";
                }

                // Get current heading texts and decode entities
                const certTitle = decodeHTMLEntities(document.getElementById("certTitle").textContent.trim());
                const certDesc1 = decodeHTMLEntities(document.getElementById("certDesc1").textContent.trim());
                const certDesc2 = decodeHTMLEntities(document.getElementById("certDesc2").textContent.trim());

                const AOA = [
                    [certTitle],
                    [certDesc1],
                    [certDesc2]
                ];

                // 1. Write Header Column Names (filtering hidden columns)
                const headers = [];
                const headerCells = document.querySelectorAll("#certTable thead tr th");
                headerCells.forEach(th => {
                    if (th.style.display !== "none") {
                        headers.push(decodeHTMLEntities(th.innerText.trim()));
                    }
                });
                AOA.push(headers);

                // 2. Write Data Rows (filtering hidden cells and decoding custom edited texts)
                const rows = document.querySelectorAll("#certTable tbody tr");
                rows.forEach(tr => {
                    const rowVals = [];
                    const cells = tr.querySelectorAll("td");
                    cells.forEach(td => {
                        if (td.style.display !== "none") {
                            rowVals.push(decodeHTMLEntities(td.innerText.trim()));
                        }
                    });
                    AOA.push(rowVals);
                });

                // Write Worksheet
                const ws = XLSX.utils.aoa_to_sheet(AOA);
                const wb = XLSX.utils.book_new();

                // Set column widths based on visibility
                const colWidths = [];
                let headerIdx = 0;
                headerCells.forEach(th => {
                    if (th.style.display !== "none") {
                        const text = th.innerText.toLowerCase();
                        if (text.includes("name")) colWidths.push({ wch: 30 });
                        else if (text.includes("remark")) colWidths.push({ wch: 45 });
                        else if (text.includes("master")) colWidths.push({ wch: 15 });
                        else if (text.includes("days") || text.includes("total")) colWidths.push({ wch: 12 });
                        else colWidths.push({ wch: 8 });
                        headerIdx++;
                    }
                });
                ws["!cols"] = colWidths;

                // Merge titles dynamically across all visible columns
                const lastColIndex = headers.length - 1;
                ws["!merges"] = [
                    { s: { r: 0, c: 0 }, e: { r: 0, c: lastColIndex } },
                    { s: { r: 1, c: 0 }, e: { r: 1, c: lastColIndex } },
                    { s: { r: 2, c: 0 }, e: { r: 2, c: lastColIndex } }
                ];

                // Helper to get Excel column letters (A, B, C, ...)
                function getColLetter(index) {
                    return String.fromCharCode(65 + index);
                }

                // Apply formatting styles to cells in worksheet
                // A1: Title styling (Calibri 11 Bold, Centered)
                if (ws["A1"]) {
                    ws["A1"].s = {
                        font: { bold: true, name: "Calibri", sz: 11 },
                        alignment: { horizontal: "center", vertical: "center" }
                    };
                }

                // Keep certificate description rows normal (not bold) in Excel as requested
                const desc1Style = {
                    font: { name: "Calibri", sz: 10, bold: false },
                    alignment: { horizontal: "center", vertical: "center", wrapText: true }
                };
                const desc2Style = {
                    font: { name: "Calibri", sz: 10, bold: false },
                    alignment: { horizontal: "center", vertical: "center", wrapText: true }
                };

                if (ws["A2"]) {
                    ws["A2"].s = desc1Style;
                }
                if (ws["A3"]) {
                    ws["A3"].s = desc2Style;
                }

                // A4 onwards: Header columns styling (Row index 3 in AOA is Row 4 in Excel, Calibri 11 Bold, Centered)
                for (let c = 0; c <= lastColIndex; c++) {
                    const cellRef = getColLetter(c) + "4";
                    if (ws[cellRef]) {
                        ws[cellRef].s = {
                            font: { bold: true, name: "Calibri", sz: 11 },
                            alignment: { horizontal: "center", vertical: "center" },
                            border: {
                                top: { style: "thin", color: { auto: 1 } },
                                bottom: { style: "thin", color: { auto: 1 } },
                                left: { style: "thin", color: { auto: 1 } },
                                right: { style: "thin", color: { auto: 1 } }
                            }
                        };
                    }
                }

                // Data rows styling (Row index 4 onwards in AOA is Row 5 onwards in Excel, Calibri 11, centered/left borders)
                for (let r = 4; r < AOA.length; r++) {
                    const rowNum = r + 1;
                    for (let c = 0; c <= lastColIndex; c++) {
                        const cellRef = getColLetter(c) + rowNum;
                        if (ws[cellRef]) {
                            const headerText = headers[c].toLowerCase();
                            // Left-align Name & Remarks; Center-align everything else
                            const alignHoriz = (headerText.includes("name") || headerText.includes("remark")) ? "left" : "center";

                            // Employee name is bold on the screen, so keep it bold in Excel
                            const isNameCol = headerText.includes("name");

                            ws[cellRef].s = {
                                font: { name: "Calibri", sz: 11, bold: isNameCol },
                                alignment: { horizontal: alignHoriz, vertical: "center", wrapText: headerText.includes("remark") },
                                border: {
                                    top: { style: "thin", color: { auto: 1 } },
                                    bottom: { style: "thin", color: { auto: 1 } },
                                    left: { style: "thin", color: { auto: 1 } },
                                    right: { style: "thin", color: { auto: 1 } }
                                }
                            };
                        }
                    }
                }

                XLSX.utils.book_append_sheet(wb, ws, "Attendance Certificate");

                // Format Filename
                const catVal = document.getElementById("category").value;
                const monthSel = document.getElementById("month");
                const mText = monthSel.options[monthSel.selectedIndex].text;
                const yearVal = document.getElementById("year").value;

                XLSX.writeFile(wb, `Attendance_Certificate_${mText}_${yearVal}_${catVal}.xlsx`);
                showToast("Downloaded Excel file successfully!", "success");
            }

            // --- Attendance Report Script Logic ---
            let reportEmployeesData = [];
            let reportContractsList = [];

            function populateReportSelectors() {
                const yearSel = document.getElementById("repYear");
                const monthSel = document.getElementById("repMonth");
                const categorySel = document.getElementById("repCategory");

                // Fill Year if empty
                if (yearSel.innerHTML === "") {
                    const currYear = new Date().getFullYear();
                    for (let y = currYear - 2; y <= currYear + 2; y++) {
                        yearSel.innerHTML += `<option value="${y}">${y}</option>`;
                    }
                    yearSel.value = currYear;
                }

                // Fill Month if empty
                if (monthSel.innerHTML === "") {
                    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    months.forEach((m, i) => {
                        monthSel.innerHTML += `<option value="${i}">${m}</option>`;
                    });
                    monthSel.value = new Date().getMonth();
                }

                // Fill Categories if empty
                if (categorySel.innerHTML === "" || categorySel.options.length === 0) {
                    fillCategoryDropdown(categorySel);
                }

                onReportFilterChange();
            }

            function onReportFilterChange() {
                const yearElem = document.getElementById("repYear");
                const monthElem = document.getElementById("repMonth");
                const catElem = document.getElementById("repCategory");
                if (!yearElem || !monthElem || !catElem || !yearElem.value || !monthElem.value || !catElem.value) return;
                const yearVal = parseInt(yearElem.value);
                const monthVal = parseInt(monthElem.value);
                const catVal = catElem.value;
                if (isNaN(yearVal) || isNaN(monthVal)) return;

                if (catVal === "All") {
                    document.getElementById("repContractGroup").style.display = "none";
                    document.getElementById("repDatedOnGroup").style.display = "none";
                    document.getElementById("repContract").innerHTML = "";
                    document.getElementById("repDatedOnInput").value = "";
                    onRepTemplateSelectChange();
                    loadReportData();
                    return;
                }

                fetch('Documents.aspx/GetContractsForMonth', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal })
                })
                    .then(r => r.json())
                    .then(res => {
                        reportContractsList = JSON.parse(res.d || "[]");
                        const contractSel = document.getElementById("repContract");
                        const contractGroup = document.getElementById("repContractGroup");
                        const datedOnGroup = document.getElementById("repDatedOnGroup");

                        if (reportContractsList.length > 0) {
                            let optionsHtml = "";
                            reportContractsList.forEach(c => {
                                optionsHtml += `<option value="${c.Id}">${c.DisplayName}</option>`;
                            });
                            contractSel.innerHTML = optionsHtml;
                            contractGroup.style.display = "block";
                            datedOnGroup.style.display = "block";
                            onReportContractChange();
                        } else {
                            contractGroup.style.display = "none";
                            datedOnGroup.style.display = "none";
                            contractSel.innerHTML = "";
                            document.getElementById("repDatedOnInput").value = "";
                            onRepTemplateSelectChange();
                            loadReportData();
                        }
                    })
                    .catch(() => showToast("Failed to fetch contract periods.", "error"));
            }

            function onReportContractChange() {
                const contractSel = document.getElementById("repContract");
                const selectedId = parseInt(contractSel.value);
                const contract = reportContractsList.find(c => c.Id === selectedId);
                if (contract) {
                    document.getElementById("repDatedOnInput").value = contract.VendorDatedOn || "";
                }
                onRepTemplateSelectChange();
                loadReportData();
            }

            function onRepTemplateSelectChange() {
                const tpl = document.getElementById("repTemplateSelect").value;
                const yearVal = document.getElementById("repYear").value;
                const monthSel = document.getElementById("repMonth");
                const monthText = monthSel.options[monthSel.selectedIndex] ? monthSel.options[monthSel.selectedIndex].text : "";
                const catVal = document.getElementById("repCategory").value;

                const contractSel = document.getElementById("repContract");
                const selectedId = parseInt(contractSel.value);
                const contract = reportContractsList.find(c => c.Id === selectedId);

                const vendorName = contract ? (contract.VendorName || "") : "VISHAL MANPOWER & SECURITY CONSULTANTS";
                const vendorAddress = contract ? (contract.VendorAddress || "") : "Mangalore";
                const gemNo = contract ? (contract.GemId || "") : "GEMC-511687761569464";
                const contractPeriod = contract ? (contract.DisplayName || "") : "";
                const datedOn = document.getElementById("repDatedOnInput").value || "[Dated On]";

                let heading1 = "";
                let heading2 = "";

                if (tpl === "tpl1") {
                    heading1 = tplRepTpl1H1;
                    heading2 = tplRepTpl1H2;
                } else {
                    heading1 = tplRepTpl2H1;
                    heading2 = tplRepTpl2H2;
                }

                // Perform placeholder replacements using the global helper
                document.getElementById("repHeadingLine1").value = replacePlaceholders(heading1, "report");
                document.getElementById("repHeadingLine2").value = replacePlaceholders(heading2, "report");
                updateReportHeaderPreview();
            }

            function updateReportHeaderPreview() {
                document.getElementById("repTitle1").textContent = document.getElementById("repHeadingLine1").value;
                document.getElementById("repTitle2").textContent = document.getElementById("repHeadingLine2").value;
            }

            function loadReportData() {
                const yearElem = document.getElementById("repYear");
                const monthElem = document.getElementById("repMonth");
                const catElem = document.getElementById("repCategory");
                if (!yearElem || !monthElem || !catElem || !yearElem.value || !monthElem.value || !catElem.value) return;
                const yearVal = parseInt(yearElem.value);
                const monthVal = parseInt(monthElem.value);
                const catVal = catElem.value;
                if (isNaN(yearVal) || isNaN(monthVal)) return;

                const loader = document.getElementById("previewLoader");
                const previewArea = document.getElementById("reportPreviewArea");

                loader.style.display = "block";
                previewArea.style.display = "none";
                const contractSel = document.getElementById("repContract");
                const selectedCpId = contractSel && contractSel.value ? parseInt(contractSel.value) : null;

                fetch('Documents.aspx/GetCertificateData', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ year: yearVal, month: monthVal, category: catVal, contractPeriodId: selectedCpId })
                })
                    .then(r => r.json())
                    .then(res => {
                        reportEmployeesData = JSON.parse(res.d || "[]");
                        if (reportEmployeesData.error) {
                            showToast(reportEmployeesData.error, "error");
                            loader.style.display = "none";
                            return;
                        }
                        updateReportHeaderPreview();
                        renderReportTable();
                        loader.style.display = "none";
                        previewArea.style.display = "block";
                        showToast(`Loaded ${reportEmployeesData.length} records successfully!`, "success");
                    })
                    .catch(() => {
                        loader.style.display = "none";
                        showToast("Failed to retrieve report data.", "error");
                    });
            }

            function renderReportTable() {
                const tableBody = document.querySelector("#reportTable tbody");
                if (!tableBody) return;

                let bodyHtml = "";
                let sNoIdx = 1;

                if (reportEmployeesData.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="10" class="text-center font-weight-bold py-4">No employees matching search criteria in this month.</td></tr>`;
                    return;
                }

                reportEmployeesData.forEach(emp => {
                    bodyHtml += "<tr>";
                    bodyHtml += `<td class="rep-col-sno">${sNoIdx++}</td>`;
                    bodyHtml += `<td class="rep-col-id">${emp.EmployeeId}</td>`;
                    bodyHtml += `<td class="rep-col-masterid" style="display: none;">${emp.MasterId}</td>`;
                    bodyHtml += `<td class="rep-col-name text-left" style="text-align: left; padding-left: 20px; font-weight: bold;">${emp.Name}</td>`;
                    bodyHtml += `<td class="rep-col-present">${emp.PresentDays}</td>`;
                    bodyHtml += `<td class="rep-col-final" style="display: none; ${emp.IsOverridden ? 'color: #ea580c; font-weight: bold;' : ''}">${emp.FinalDays}</td>`;
                    bodyHtml += `<td class="rep-col-paid" style="display: none;">${emp.Paid}</td>`;
                    bodyHtml += `<td class="rep-col-unpaid" style="display: none;">${emp.Unpaid}</td>`;
                    bodyHtml += `<td class="rep-col-satcut" style="display: none;">${emp.SatCut}</td>`;

                    const remarkCellVal = getReportRemarksString(emp);
                    bodyHtml += `<td class="rep-col-remarks text-left" style="text-align: left;">${remarkCellVal}</td>`;
                    bodyHtml += "</tr>";
                });

                tableBody.innerHTML = bodyHtml;

                applyAllReportColumnToggles();
            }

            function getReportRemarksString(emp) {
                const parts = [];
                const includeJoinResign = document.getElementById("repRemJoinResign").checked;
                const includeOverride = document.getElementById("repRemOverride").checked;
                const includePair = document.getElementById("repRemPairs").checked;
                const includeSatEdit = document.getElementById("repRemSatEdit").checked;
                const includeCellSpecific = document.getElementById("repRemCellSpecific").checked;

                if (includeJoinResign && emp.JoinResignRemark) parts.push(emp.JoinResignRemark);
                if (includeOverride && emp.OverrideRemark) parts.push(emp.OverrideRemark);
                if (includePair && emp.LeavePairRemark) parts.push(emp.LeavePairRemark);
                if (includeSatEdit && emp.SaturdayRemark) parts.push(emp.SaturdayRemark);
                if (includeCellSpecific && emp.CellRemarks) parts.push(emp.CellRemarks);

                return parts.join("; ");
            }

            function toggleReportColumn(colClass, isChecked) {
                const cells = document.querySelectorAll(`.${colClass}`);
                cells.forEach(c => {
                    c.style.display = isChecked ? "" : "none";
                });
            }

            function applyAllReportColumnToggles() {
                toggleReportColumn("rep-col-sno", document.getElementById("repColSNo").checked);
                toggleReportColumn("rep-col-id", document.getElementById("repColID").checked);
                toggleReportColumn("rep-col-masterid", document.getElementById("repColMasterID").checked);
                toggleReportColumn("rep-col-name", document.getElementById("repColName").checked);
                toggleReportColumn("rep-col-present", document.getElementById("repColPresent").checked);
                toggleReportColumn("rep-col-final", document.getElementById("repColFinal").checked);
                toggleReportColumn("rep-col-paid", document.getElementById("repColPaid").checked);
                toggleReportColumn("rep-col-unpaid", document.getElementById("repColUnpaid").checked);
                toggleReportColumn("rep-col-satcut", document.getElementById("repColSatCut").checked);
                toggleReportColumn("rep-col-remarks", document.getElementById("repColRemarks").checked);
            }

            function rebuildReportRemarksColumn() {
                const rows = document.querySelectorAll("#reportTable tbody tr");
                if (rows.length === 0 || reportEmployeesData.length === 0) return;

                rows.forEach((row, i) => {
                    const emp = reportEmployeesData[i];
                    if (!emp) return;
                    const remarksCell = row.querySelector(".rep-col-remarks");
                    if (remarksCell) {
                        remarksCell.textContent = getReportRemarksString(emp);
                    }
                });
                showToast("Report remarks rebuilt.", "success");
            }

            function exportReportToExcel() {
                if (typeof XLSX === "undefined") {
                    showToast("Spreadsheet library is not loaded.", "error");
                    return;
                }

                const table = document.getElementById("reportTable");
                if (!table || reportEmployeesData.length === 0) {
                    showToast("No data available to export.", "warning");
                    return;
                }

                // Helper to decode HTML entities
                function decodeHTMLEntities(text) {
                    if (!text) return "";
                    const temp = document.createElement('div');
                    temp.innerHTML = text;
                    return temp.textContent || temp.innerText || "";
                }

                const title1 = decodeHTMLEntities(document.getElementById("repTitle1").textContent.trim());
                const title2 = decodeHTMLEntities(document.getElementById("repTitle2").textContent.trim());

                const AOA = [
                    [title1],
                    [title2]
                ];

                // 1. Write Header Column Names (filtering hidden columns)
                const headers = [];
                const headerCells = document.querySelectorAll("#reportTable thead tr th");
                headerCells.forEach(th => {
                    if (th.style.display !== "none") {
                        headers.push(decodeHTMLEntities(th.innerText.trim()));
                    }
                });
                AOA.push(headers);

                // 2. Write Data Rows (filtering hidden cells)
                const rows = document.querySelectorAll("#reportTable tbody tr");
                rows.forEach(tr => {
                    const rowVals = [];
                    const cells = tr.querySelectorAll("td");
                    cells.forEach(td => {
                        if (td.style.display !== "none") {
                            rowVals.push(decodeHTMLEntities(td.innerText.trim()));
                        }
                    });
                    AOA.push(rowVals);
                });

                // Write Worksheet
                const ws = XLSX.utils.aoa_to_sheet(AOA);
                const wb = XLSX.utils.book_new();

                // Set column widths based on visibility
                const colWidths = [];
                headerCells.forEach(th => {
                    if (th.style.display !== "none") {
                        const text = th.innerText.toLowerCase();
                        if (text.includes("name")) colWidths.push({ wch: 30 });
                        else if (text.includes("remark")) colWidths.push({ wch: 45 });
                        else if (text.includes("master")) colWidths.push({ wch: 15 });
                        else if (text.includes("days") || text.includes("present") || text.includes("total")) colWidths.push({ wch: 12 });
                        else colWidths.push({ wch: 8 });
                    }
                });
                ws["!cols"] = colWidths;

                // Merge titles dynamically across all visible columns
                const lastColIndex = headers.length - 1;
                ws["!merges"] = [
                    { s: { r: 0, c: 0 }, e: { r: 0, c: lastColIndex } },
                    { s: { r: 1, c: 0 }, e: { r: 1, c: lastColIndex } }
                ];

                // Apply formatting styles to cells in worksheet
                if (ws["A1"]) {
                    ws["A1"].s = {
                        font: { bold: true, name: "Calibri", sz: 11 },
                        alignment: { horizontal: "center", vertical: "center" }
                    };
                }
                if (ws["A2"]) {
                    ws["A2"].s = {
                        font: { bold: true, name: "Calibri", sz: 10 },
                        alignment: { horizontal: "center", vertical: "center" }
                    };
                }

                // Style headers row (AOA row index 2)
                const headerRowIdx = 2;
                for (let c = 0; c <= lastColIndex; c++) {
                    const cellRef = String.fromCharCode(65 + c) + (headerRowIdx + 1);
                    if (ws[cellRef]) {
                        ws[cellRef].s = {
                            font: { bold: true, name: "Calibri", sz: 10 },
                            fill: { fgColor: { rgb: "F2F2F2" } },
                            border: {
                                top: { style: "thin", color: { rgb: "D9D9D9" } },
                                bottom: { style: "thin", color: { rgb: "D9D9D9" } },
                                left: { style: "thin", color: { rgb: "D9D9D9" } },
                                right: { style: "thin", color: { rgb: "D9D9D9" } }
                            },
                            alignment: { horizontal: "center", vertical: "center" }
                        };
                    }
                }

                // Style data rows (AOA row index 3 onwards)
                const startDataRowIdx = 3;
                const endDataRowIdx = AOA.length - 1;
                for (let r = startDataRowIdx; r <= endDataRowIdx; r++) {
                    for (let c = 0; c <= lastColIndex; c++) {
                        const cellRef = String.fromCharCode(65 + c) + (r + 1);
                        if (ws[cellRef]) {
                            ws[cellRef].s = {
                                font: { name: "Calibri", sz: 10 },
                                border: {
                                    top: { style: "thin", color: { rgb: "E5E5E5" } },
                                    bottom: { style: "thin", color: { rgb: "E5E5E5" } },
                                    left: { style: "thin", color: { rgb: "E5E5E5" } },
                                    right: { style: "thin", color: { rgb: "E5E5E5" } }
                                },
                                alignment: {
                                    horizontal: (c === 0 || c === 1 || headers[c].toLowerCase().includes("days") || headers[c].toLowerCase().includes("total")) ? "center" : "left",
                                    vertical: "center"
                                }
                            };
                        }
                    }
                }

                XLSX.utils.book_append_sheet(wb, ws, "Attendance Report");

                const catVal = document.getElementById("repCategory").value;
                const monthSel = document.getElementById("repMonth");
                const mText = monthSel.options[monthSel.selectedIndex].text;
                const yearVal = document.getElementById("repYear").value;

                XLSX.writeFile(wb, `Attendance_Report_${mText}_${yearVal}_${catVal}.xlsx`);
                showToast("Downloaded Attendance Report Excel successfully!", "success");
            }
        </script>
    </asp:Content>
