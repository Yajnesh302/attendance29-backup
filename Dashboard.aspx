<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="AttendanceApp.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Dashboard
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Base Dashboard Header */
        .dashboard-header-title {
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 4px;
            font-size: 1.65rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .dashboard-section-subtitle {
            font-size: 0.85rem;
            color: #64748b;
            font-weight: 400;
        }

        /* Carousel Outer Container */
        .dashboard-carousel-wrapper {
            position: relative;
            overflow: hidden !important;
            border-radius: 24px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
            padding: 28px 32px 20px 32px;
            touch-action: pan-y;
            user-select: none;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-sizing: border-box;
            width: 100%;
        }

        .dashboard-carousel-track-container {
            flex-grow: 1;
            display: flex;
            align-items: stretch;
            overflow: hidden !important;
            width: 100%;
            position: relative;
        }

        .dashboard-carousel-track {
            display: flex;
            transition: transform 0.45s cubic-bezier(0.16, 1, 0.3, 1);
            width: 100%;
            align-items: stretch;
        }

        .dashboard-carousel-page {
            flex: 0 0 100%;
            width: 100%;
            min-width: 100%;
            padding: 0 2px;
            box-sizing: border-box;
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
            transition: opacity 0.45s cubic-bezier(0.16, 1, 0.3, 1), visibility 0.45s cubic-bezier(0.16, 1, 0.3, 1);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }

        .dashboard-carousel-page.active-page {
            opacity: 1 !important;
            visibility: visible !important;
            pointer-events: auto !important;
        }

        /* Responsive 4-Column and 3-Column Single Row Grids */
        .dashboard-grid-4 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            width: 100%;
            box-sizing: border-box;
        }

        .dashboard-grid-3 {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            width: 100%;
            box-sizing: border-box;
            align-items: stretch;
        }

        @media (max-width: 1100px) {
            .dashboard-grid-4, .dashboard-grid-3 {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 640px) {
            .dashboard-grid-4, .dashboard-grid-3 {
                grid-template-columns: 1fr;
            }
            .dashboard-carousel-wrapper {
                padding: 18px 16px 14px 16px;
            }
        }

        /* Sub-Panel Sliding Transition Styles for Page 3 */
        .subpanel-view-container {
            transition: opacity 0.38s cubic-bezier(0.16, 1, 0.3, 1), transform 0.38s cubic-bezier(0.16, 1, 0.3, 1);
            width: 100%;
        }

        .subpanel-hidden-left {
            opacity: 0 !important;
            transform: translateX(-35px) !important;
            pointer-events: none !important;
            position: absolute;
            top: 0; left: 0; right: 0;
        }

        .subpanel-hidden-right {
            opacity: 0 !important;
            transform: translateX(35px) !important;
            pointer-events: none !important;
            position: absolute;
            top: 0; left: 0; right: 0;
        }

        .subpanel-visible {
            opacity: 1 !important;
            transform: translateX(0) !important;
            pointer-events: auto !important;
            position: relative;
        }

        /* Back Navigation Button */
        .btn-subpanel-back {
            background: #e0e7ff;
            color: #4338ca;
            border: none;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 0.88rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-subpanel-back:hover {
            background: #4f46e5;
            color: #ffffff;
            transform: translateX(-3px);
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
        }

        .subpanel-divider {
            color: #cbd5e1;
            margin: 0 8px;
        }

        /* Premium Tall Vertical Card Design */
        .card-custom {
            padding: 32px 28px 24px 28px;
            border-radius: 24px;
            cursor: pointer;
            transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
            text-decoration: none;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-start;
            width: 100%;
            min-height: 330px;
            box-sizing: border-box;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 14px rgba(0, 0, 0, 0.02);
        }

        .card-custom:hover {
            transform: translateY(-6px);
            box-shadow: 0 16px 36px rgba(0, 0, 0, 0.08);
            text-decoration: none;
        }

        /* Card Top Icon Box */
        .card-icon-box {
            width: 64px;
            height: 64px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin-bottom: 24px;
            flex-shrink: 0;
            transition: transform 0.35s ease;
        }

        .card-custom:hover .card-icon-box {
            transform: scale(1.1);
        }

        /* Card Main Content Area */
        .card-content-body {
            flex-grow: 1;
            text-align: left;
            z-index: 2;
        }

        .card-content-body h3 {
            margin: 0 0 10px 0;
            font-size: 1.35rem;
            font-weight: 800;
            letter-spacing: -0.3px;
        }

        .card-content-body p {
            color: #64748b;
            margin: 0;
            font-size: 0.9rem;
            font-weight: 500;
            line-height: 1.48;
        }

        /* Circular Arrow Button */
        .card-circle-arrow {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.05rem;
            transition: all 0.35s ease;
            margin-top: 24px;
            z-index: 2;
            flex-shrink: 0;
        }

        .card-custom:hover .card-circle-arrow {
            transform: scale(1.12);
        }

        /* Subtle Wavy Pattern Background Accent */
        .card-wave-accent {
            position: absolute;
            bottom: -15px;
            right: -15px;
            width: 140px;
            height: 140px;
            opacity: 0.35;
            pointer-events: none;
            z-index: 1;
            transition: opacity 0.35s ease, transform 0.35s ease;
        }

        .card-custom:hover .card-wave-accent {
            opacity: 0.6;
            transform: scale(1.08);
        }

        /* Module Theme Styles */
        
        /* Employee Card Theme (Indigo/Purple) */
        .card-theme-indigo {
            background: linear-gradient(145deg, #f5f3ff 0%, #faf5ff 100%);
            border: 1px solid #e9d5ff;
        }
        .card-theme-indigo .card-icon-box { background: #ede9fe; color: #6366f1; }
        .card-theme-indigo h3 { color: #4338ca; }
        .card-theme-indigo .card-circle-arrow { background: #ede9fe; color: #6366f1; }
        .card-theme-indigo .card-wave-accent { color: #c084fc; }

        /* Attendance Card Theme (Green/Emerald) */
        .card-theme-emerald {
            background: linear-gradient(145deg, #f0fdf4 0%, #f6fef9 100%);
            border: 1px solid #dcfce7;
        }
        .card-theme-emerald .card-icon-box { background: #d1fae5; color: #10b981; }
        .card-theme-emerald h3 { color: #059669; }
        .card-theme-emerald .card-circle-arrow { background: #d1fae5; color: #059669; }
        .card-theme-emerald .card-wave-accent { color: #34d399; }

        /* Ledger Card Theme (Blue/Sky) */
        .card-theme-sky {
            background: linear-gradient(145deg, #eff6ff 0%, #f8fafc 100%);
            border: 1px solid #dbeafe;
        }
        .card-theme-sky .card-icon-box { background: #e0f2fe; color: #0ea5e9; }
        .card-theme-sky h3 { color: #0284c7; }
        .card-theme-sky .card-circle-arrow { background: #e0f2fe; color: #0284c7; }
        .card-theme-sky .card-wave-accent { color: #38bdf8; }

        /* Remarks Inbox Card Theme (Pink/Purple) */
        .card-theme-purple {
            background: linear-gradient(145deg, #fdf2f8 0%, #fbf7f9 100%);
            border: 1px solid #fce7f3;
        }
        .card-theme-purple .card-icon-box { background: #fce7f3; color: #d946ef; }
        .card-theme-purple h3 { color: #c026d3; }
        .card-theme-purple .card-circle-arrow { background: #fce7f3; color: #c026d3; }
        .card-theme-purple .card-wave-accent { color: #f0abfc; }

        /* Calculation Card Theme (Amber/Orange) */
        .card-theme-amber {
            background: linear-gradient(145deg, #fffbeb 0%, #fefce8 100%);
            border: 1px solid #fef3c7;
        }
        .card-theme-amber .card-icon-box { background: #fef3c7; color: #f59e0b; }
        .card-theme-amber h3 { color: #d97706; }
        .card-theme-amber .card-circle-arrow { background: #fef3c7; color: #d97706; }
        .card-theme-amber .card-wave-accent { color: #fbbf24; }

        /* Documents / Settings Card Theme (Slate/Navy) */
        .card-theme-slate {
            background: linear-gradient(145deg, #f8fafc 0%, #f1f5f9 100%);
            border: 1px solid #e2e8f0;
        }
        .card-theme-slate .card-icon-box { background: #f1f5f9; color: #475569; }
        .card-theme-slate h3 { color: #334155; }
        .card-theme-slate .card-circle-arrow { background: #f1f5f9; color: #475569; }
        .card-theme-slate .card-wave-accent { color: #94a3b8; }

        /* Admin Management Card Theme (Rose/Red) */
        .card-theme-rose {
            background: linear-gradient(145deg, #fff1f2 0%, #fff5f5 100%);
            border: 1px solid #ffe4e6;
        }
        .card-theme-rose .card-icon-box { background: #ffe4e6; color: #f43f5e; }
        .card-theme-rose h3 { color: #e11d48; }
        .card-theme-rose .card-circle-arrow { background: #ffe4e6; color: #e11d48; }
        .card-theme-rose .card-wave-accent { color: #fb7185; }

        /* Page Indicator Header */
        .page-badge-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f5f9;
        }

        .page-badge-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .page-counter-tag {
            font-size: 0.78rem;
            font-weight: 700;
            background: #e0e7ff;
            color: #4338ca;
            padding: 3px 12px;
            border-radius: 20px;
            letter-spacing: 0.5px;
        }

        /* Compact Sleek Pagination Dots at Bottom */
        .carousel-dots-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding-top: 18px;
            border-top: 1px solid #f1f5f9;
            margin-top: 18px;
        }

        .carousel-dot {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: #cbd5e1;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: none;
            outline: none;
            padding: 0;
        }

        .carousel-dot:hover:not(.active) {
            background: #94a3b8;
            transform: scale(1.2);
        }

        .carousel-dot.active {
            width: 22px;
            height: 9px;
            border-radius: 5px;
            background: #4f46e5;
            box-shadow: 0 2px 8px rgba(79, 70, 229, 0.4);
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap" style="gap: 15px;">
        <h2 class="dashboard-header-title mb-0">
            <i class="fas fa-layer-group text-primary"></i> HR Dashboard
        </h2>

        <%-- Role Switcher Widget (Visible on Dashboard for multi-role users) --%>
        <asp:PlaceHolder ID="phDashboardRoleSwitcher" runat="server" Visible="false">
            <div class="dropdown">
                <button class="btn btn-white shadow-sm dropdown-toggle font-weight-bold d-flex align-items-center px-3 py-2" type="button" id="dashRoleDropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="border-radius: 14px; border: 1px solid #cbd5e1; background: #ffffff; color: #1e293b; transition: all 0.2s ease;">
                    <i id="lblDashRoleIcon" runat="server" class="fas fa-user-shield mr-2" style="font-size: 1.1rem; color: #4f46e5;"></i>
                    <div class="text-left mr-2" style="line-height: 1.2;">
                        <span class="text-muted d-block" style="font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Active Mode</span>
                        <span id="lblDashRoleTitle" runat="server" style="font-size: 0.88rem; font-weight: 700; color: #0f172a;">Primary Admin</span>
                    </div>
                </button>
                <div class="dropdown-menu dropdown-menu-right shadow-lg border-0 mt-2" aria-labelledby="dashRoleDropdown" style="border-radius: 14px; min-width: 280px; padding: 10px 0;">
                    <div class="dropdown-header text-uppercase font-weight-bold text-gray-800 px-3 py-2" style="font-size: 0.75rem; letter-spacing: 0.5px;">
                        <i class="fas fa-random mr-1 text-primary"></i> Switch Active Role Mode
                    </div>
                    <div class="dropdown-divider my-1"></div>
                    <asp:Repeater ID="rptDashboardRoles" runat="server" OnItemCommand="rptDashboardRoles_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnDashSwitchRole" runat="server" CommandName="SwitchRole" CommandArgument='<%# Eval("RoleMode") %>' CssClass='<%# GetRoleItemCssClass(Eval("RoleMode")) %>' style="padding: 10px 16px; display: block;">
                                <div class="d-flex align-items-center">
                                    <i class='<%# Eval("Icon") %>' style='<%# "color:" + Eval("BadgeColor") + "; font-size: 1.1rem; margin-right: 12px;" %>'></i>
                                    <div>
                                        <div style="font-size:0.88rem; font-weight: 700; color: #1e293b;"><%# Eval("Title") %></div>
                                        <small class="text-muted" style="font-size:0.75rem; display:block;"><%# Eval("Subtitle") %></small>
                                    </div>
                                </div>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </asp:PlaceHolder>
    </div>
    <asp:PlaceHolder ID="phUnreadNoticeAlert" runat="server" Visible="false">
        <div class="alert shadow-sm border-0 mb-4 p-3 d-flex align-items-center justify-content-between flex-wrap" style="background: linear-gradient(135deg, #fef3c7 0%, #fffbeb 100%); border-left: 5px solid #f59e0b !important; border-radius: 14px; gap: 12px;">
            <div class="d-flex align-items-center flex-wrap" style="gap: 14px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #fef3c7; color: #d97706; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; box-shadow: 0 4px 10px rgba(245, 158, 11, 0.2);">
                    <i class="fas fa-bullhorn"></i>
                </div>
                <div>
                    <h6 class="font-weight-bold text-dark mb-1" style="font-size: 0.98rem; display: flex; align-items: center; gap: 8px;">
                        <span>New Announcement / Notice</span>
                        <asp:Literal ID="litNoticeMainCatBadge" runat="server" />
                    </h6>
                    <p class="text-muted mb-0 small" style="font-size: 0.88rem;">
                        <asp:Literal ID="litNoticeAlertMessage" runat="server" />
                    </p>
                </div>
            </div>
            <a href="Notices.aspx" class="btn btn-warning font-weight-bold shadow-sm" style="border-radius: 10px; padding: 8px 20px; font-size: 0.88rem; background: #f59e0b; color: white; border: none; display: inline-flex; align-items: center; gap: 6px;">
                <i class="fas fa-arrow-right"></i> View Notices
            </a>
        </div>
    </asp:PlaceHolder>

    <% int userRole = Convert.ToInt32(Session["Role"] ?? 0);
       if (userRole == 1 || userRole == 4) { %>
        
        <!-- ADMIN / SUPER ADMIN 3-PAGE SWIPEABLE CAROUSEL CONTAINER -->
        <div class="dashboard-carousel-wrapper" id="dashboardCarouselWrapper">
            
            <div class="dashboard-carousel-track-container">
                <!-- Carousel Track -->
                <div class="dashboard-carousel-track" id="dashboardCarouselTrack">
                    
                    <!-- PAGE 1: Daily Operations (4 Cards Single Row) -->
                    <div class="dashboard-carousel-page active-page" id="page1">
                        <div class="page-badge-header">
                            <div class="page-badge-title">
                                <i class="fas fa-bolt" style="color:#4f46e5;"></i> Daily Operations
                                <span class="dashboard-section-subtitle">&mdash; Frequently accessed modules</span>
                            </div>
                            <span class="page-counter-tag">Page 1 of 3</span>
                        </div>

                        <div class="dashboard-grid-4">
                            <asp:PlaceHolder ID="phAdmin_Emp" runat="server">
                                <a href="Employee.aspx" class="card-custom card-theme-indigo">
                                    <div class="card-icon-box">
                                        <i class="fas fa-users"></i>
                                    </div>
                                    <div class="card-content-body">
                                        <h3>Employee</h3>
                                        <p>Manage employee records, engagements &amp; leave balances</p>
                                    </div>
                                    <div class="card-circle-arrow">
                                        <i class="fas fa-arrow-right"></i>
                                    </div>
                                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                    </svg>
                                </a>
                            </asp:PlaceHolder>

                            <a href="Attendance.aspx" class="card-custom card-theme-emerald">
                                <div class="card-icon-box">
                                    <i class="fas fa-calendar-check"></i>
                                </div>
                                <div class="card-content-body">
                                    <h3>Attendance</h3>
                                    <p>Mark daily attendance &amp; record work shifts</p>
                                </div>
                                <div class="card-circle-arrow">
                                    <i class="fas fa-arrow-right"></i>
                                </div>
                                <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                    <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                </svg>
                            </a>

                            <a href="Ledger.aspx" class="card-custom card-theme-sky">
                                <div class="card-icon-box">
                                    <i class="fas fa-book"></i>
                                </div>
                                <div class="card-content-body">
                                    <h3>Ledger</h3>
                                    <p>Track leave balance, history &amp; adjustments</p>
                                </div>
                                <div class="card-circle-arrow">
                                    <i class="fas fa-arrow-right"></i>
                                </div>
                                <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                    <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                </svg>
                            </a>

                            <asp:PlaceHolder ID="phAdmin_Remarks" runat="server">
                                <a href="Remarks.aspx" class="card-custom card-theme-purple">
                                    <div class="card-icon-box">
                                        <i class="fas fa-comment-dots"></i>
                                    </div>
                                    <div class="card-content-body">
                                        <h3>Remarks Inbox</h3>
                                        <p>Review &amp; approve attendance remark requests</p>
                                    </div>
                                    <div class="card-circle-arrow">
                                        <i class="fas fa-arrow-right"></i>
                                    </div>
                                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                    </svg>
                                </a>
                            </asp:PlaceHolder>
                        </div>
                    </div>

                    <!-- PAGE 2: Periodic Tasks & Notices (3 Cards Single Row) -->
                    <div class="dashboard-carousel-page" id="page2">
                        <div class="page-badge-header">
                            <div class="page-badge-title">
                                <i class="fas fa-calendar-alt" style="color:#d97706;"></i> Periodic Tasks &amp; Notices
                                <span class="dashboard-section-subtitle">&mdash; Monthly payroll, documents &amp; announcements</span>
                            </div>
                            <span class="page-counter-tag">Page 2 of 3</span>
                        </div>

                        <div class="dashboard-grid-3">
                            <asp:PlaceHolder ID="phAdmin_Calc" runat="server">
                                <a href="Calculation.aspx" class="card-custom card-theme-amber">
                                    <div class="card-icon-box">
                                        <i class="fas fa-calculator"></i>
                                    </div>
                                    <div class="card-content-body">
                                        <h3>Calculation</h3>
                                        <p>Process monthly salary &amp; generate payroll statements</p>
                                    </div>
                                    <div class="card-circle-arrow">
                                        <i class="fas fa-arrow-right"></i>
                                    </div>
                                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                    </svg>
                                </a>

                                <a href="Documents.aspx" class="card-custom card-theme-slate">
                                    <div class="card-icon-box">
                                        <i class="fas fa-file-alt"></i>
                                    </div>
                                    <div class="card-content-body">
                                        <h3>Documents</h3>
                                        <p>Generate certificates, wage sheets &amp; attendance reports</p>
                                    </div>
                                    <div class="card-circle-arrow">
                                        <i class="fas fa-arrow-right"></i>
                                    </div>
                                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                    </svg>
                                </a>
                            </asp:PlaceHolder>

                            <a href="Notices.aspx" class="card-custom card-theme-emerald">
                                <div class="card-icon-box">
                                    <i class="fas fa-bullhorn"></i>
                                </div>
                                <div class="card-content-body">
                                    <h3>Notices</h3>
                                    <p>Publish &amp; manage company announcements &amp; notices</p>
                                </div>
                                <div class="card-circle-arrow">
                                    <i class="fas fa-arrow-right"></i>
                                </div>
                                <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                    <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                </svg>
                            </a>
                        </div>
                    </div>

                    <!-- PAGE 3: System Administration (Admin Management, Settings, Service Provider Master Card) -->
                    <div class="dashboard-carousel-page" id="page3">
                        
                        <!-- PRIMARY VIEW (3 Cards: Admin Management, Settings, Service Provider) -->
                        <div id="page3PrimaryView" class="subpanel-view-container subpanel-visible">
                            <div class="page-badge-header">
                                <div class="page-badge-title">
                                    <i class="fas fa-sliders-h" style="color:#e11d48;"></i> System Administration
                                    <span class="dashboard-section-subtitle">&mdash; Admin setup, settings &amp; service provider management</span>
                                </div>
                                <span class="page-counter-tag">Page 3 of 3</span>
                            </div>

                            <div class="dashboard-grid-3">
                                <asp:PlaceHolder ID="phAdmin_AdminMgmt" runat="server">
                                    <a href="AdminManagement.aspx" class="card-custom card-theme-rose">
                                        <div class="card-icon-box">
                                            <i class="fas fa-user-shield"></i>
                                        </div>
                                        <div class="card-content-body">
                                            <h3>Admin Management</h3>
                                            <p>Configure administrator roles, permissions &amp; access control</p>
                                        </div>
                                        <div class="card-circle-arrow">
                                            <i class="fas fa-arrow-right"></i>
                                        </div>
                                        <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                            <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                        </svg>
                                    </a>
                                </asp:PlaceHolder>

                                <asp:PlaceHolder ID="phAdmin_Settings" runat="server">
                                    <a href="Settings.aspx" class="card-custom card-theme-slate">
                                        <div class="card-icon-box">
                                            <i class="fas fa-cog"></i>
                                        </div>
                                        <div class="card-content-body">
                                            <h3>Settings</h3>
                                            <p>Manage categories, tiers &amp; system parameters</p>
                                        </div>
                                        <div class="card-circle-arrow">
                                            <i class="fas fa-arrow-right"></i>
                                        </div>
                                        <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                            <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                        </svg>
                                    </a>
                                </asp:PlaceHolder>

                                <!-- SERVICE PROVIDER MASTER CARD -->
                                <div class="card-custom card-theme-amber" id="cardServiceProviderMaster" style="cursor: pointer;" title="Click to view Vendors & Contracts">
                                    <div class="card-icon-box">
                                        <i class="fas fa-briefcase"></i>
                                    </div>
                                    <div class="card-content-body">
                                        <h3>Service Provider</h3>
                                        <p>Manage contracting agencies, vendor profiles &amp; contract periods</p>
                                    </div>
                                    <div class="card-circle-arrow">
                                        <i class="fas fa-chevron-right"></i>
                                    </div>
                                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                    </svg>
                                </div>
                            </div>
                        </div>

                        <!-- SUB-PANEL VIEW (Vendors & Contracts Cards) -->
                        <div id="page3SubPanel" class="subpanel-view-container subpanel-hidden-right">
                            <div class="page-badge-header">
                                <div class="page-badge-title">
                                    <button type="button" class="btn-subpanel-back" id="btnBackToPage3">
                                        <i class="fas fa-arrow-left"></i> Back to System Administration
                                    </button>
                                    <span class="subpanel-divider">|</span>
                                    <i class="fas fa-briefcase" style="color:#d97706;"></i> Service Provider Modules
                                </div>
                                <span class="page-counter-tag">Page 3 Sub-View</span>
                            </div>

                            <div class="dashboard-grid-3">
                                <asp:PlaceHolder ID="phAdmin_Vendors" runat="server">
                                    <a href="Vendors.aspx" class="card-custom card-theme-sky">
                                        <div class="card-icon-box">
                                            <i class="fas fa-handshake"></i>
                                        </div>
                                        <div class="card-content-body">
                                            <h3>Vendors</h3>
                                            <p>Manage contracting agencies &amp; vendor details</p>
                                        </div>
                                        <div class="card-circle-arrow">
                                            <i class="fas fa-arrow-right"></i>
                                        </div>
                                        <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                            <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                        </svg>
                                    </a>
                                </asp:PlaceHolder>

                                <asp:PlaceHolder ID="phAdmin_Contracts" runat="server">
                                    <a href="Contracts.aspx" class="card-custom card-theme-amber">
                                        <div class="card-icon-box">
                                            <i class="fas fa-file-signature"></i>
                                        </div>
                                        <div class="card-content-body">
                                            <h3>Contracts</h3>
                                            <p>Configure contract periods &amp; GeM details</p>
                                        </div>
                                        <div class="card-circle-arrow">
                                            <i class="fas fa-arrow-right"></i>
                                        </div>
                                        <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                            <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                        </svg>
                                    </a>
                                </asp:PlaceHolder>

                                <asp:PlaceHolder ID="phAdmin_Wages" runat="server">
                                    <a href="Wages.aspx" class="card-custom card-theme-emerald">
                                        <div class="card-icon-box">
                                            <i class="fas fa-coins"></i>
                                        </div>
                                        <div class="card-content-body">
                                            <h3>Wages &amp; Statutory</h3>
                                            <p>Configure category wage orders, EPF limits &amp; statutory rates</p>
                                        </div>
                                        <div class="card-circle-arrow">
                                            <i class="fas fa-arrow-right"></i>
                                        </div>
                                        <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                                            <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                                        </svg>
                                    </a>
                                </asp:PlaceHolder>
                            </div>
                        </div>

                    </div>

                </div>
            </div>

            <!-- 3 COMPACT PAGINATION DOTS AT BOTTOM -->
            <div class="carousel-dots-container" id="carouselDotsContainer">
                <button type="button" class="carousel-dot active" data-page="0" title="Page 1: Daily Operations"></button>
                <button type="button" class="carousel-dot" data-page="1" title="Page 2: Periodic Tasks & Notices"></button>
                <button type="button" class="carousel-dot" data-page="2" title="Page 3: System Administration"></button>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                var wrapper = document.getElementById('dashboardCarouselWrapper');
                var track = document.getElementById('dashboardCarouselTrack');
                var dots = document.querySelectorAll('#carouselDotsContainer .carousel-dot');
                var pages = document.querySelectorAll('.dashboard-carousel-page');

                var cardServiceProviderMaster = document.getElementById('cardServiceProviderMaster');
                var btnBackToPage3 = document.getElementById('btnBackToPage3');
                var page3PrimaryView = document.getElementById('page3PrimaryView');
                var page3SubPanel = document.getElementById('page3SubPanel');

                if (!wrapper || !track) return;

                var currentPage = 0;
                var totalPages = 3;
                var isScrolling = false;

                function resetPage3SubPanel() {
                    if (page3PrimaryView && page3SubPanel) {
                        page3SubPanel.classList.remove('subpanel-visible');
                        page3SubPanel.classList.add('subpanel-hidden-right');

                        page3PrimaryView.classList.remove('subpanel-hidden-left');
                        page3PrimaryView.classList.add('subpanel-visible');
                    }
                }

                function updateCarousel() {
                    // Update slide transform position (each page is 100% width)
                    track.style.transform = 'translateX(-' + (currentPage * 100) + '%)';

                    // Update dot indicators & page visibilities
                    dots.forEach(function (dot, index) {
                        if (index === currentPage) {
                            dot.classList.add('active');
                        } else {
                            dot.classList.remove('active');
                        }
                    });

                    // Ensure non-active pages are strictly hidden
                    pages.forEach(function (page, index) {
                        if (index === currentPage) {
                            page.classList.add('active-page');
                        } else {
                            page.classList.remove('active-page');
                        }
                    });

                    // Reset sub-panel when leaving Page 3
                    if (currentPage !== 2) {
                        resetPage3SubPanel();
                    }
                }

                function goToPage(index) {
                    if (index < 0) index = 0;
                    if (index >= totalPages) index = totalPages - 1;
                    currentPage = index;
                    updateCarousel();
                }

                // Service Provider Sub-Panel Event Handlers
                if (cardServiceProviderMaster && page3PrimaryView && page3SubPanel) {
                    cardServiceProviderMaster.addEventListener('click', function () {
                        page3PrimaryView.classList.remove('subpanel-visible');
                        page3PrimaryView.classList.add('subpanel-hidden-left');

                        page3SubPanel.classList.remove('subpanel-hidden-right');
                        page3SubPanel.classList.add('subpanel-visible');
                    });
                }

                if (btnBackToPage3 && page3PrimaryView && page3SubPanel) {
                    btnBackToPage3.addEventListener('click', function (e) {
                        e.stopPropagation();
                        resetPage3SubPanel();
                    });
                }

                // Dot Navigation Click Listeners
                dots.forEach(function (dot) {
                    dot.addEventListener('click', function () {
                        var pageIndex = parseInt(this.getAttribute('data-page'), 10);
                        goToPage(pageIndex);
                    });
                });

                // Mouse Wheel Navigation Anywhere on Dashboard Container
                window.addEventListener('wheel', function (e) {
                    var rect = wrapper.getBoundingClientRect();
                    var isOverDashboard = (
                        e.clientX >= rect.left &&
                        e.clientX <= rect.right &&
                        e.clientY >= rect.top &&
                        e.clientY <= rect.bottom
                    );

                    if (!isOverDashboard) return;

                    if (isScrolling) return;

                    var delta = e.deltaY || e.deltaX;
                    if (Math.abs(delta) < 25) return;

                    if (delta > 0) {
                        if (currentPage < totalPages - 1) {
                            isScrolling = true;
                            goToPage(currentPage + 1);
                            setTimeout(function () { isScrolling = false; }, 400);
                        }
                    } else if (delta < 0) {
                        if (currentPage > 0) {
                            isScrolling = true;
                            goToPage(currentPage - 1);
                            setTimeout(function () { isScrolling = false; }, 400);
                        }
                    }
                }, { passive: true });

                // Touch & Gesture Swipe Support
                var touchStartX = 0;
                var touchEndX = 0;

                wrapper.addEventListener('touchstart', function (e) {
                    touchStartX = e.changedTouches[0].screenX;
                }, { passive: true });

                wrapper.addEventListener('touchend', function (e) {
                    touchEndX = e.changedTouches[0].screenX;
                    handleSwipe();
                }, { passive: true });

                function handleSwipe() {
                    var diffX = touchEndX - touchStartX;
                    if (Math.abs(diffX) > 40) {
                        if (diffX < 0 && currentPage < totalPages - 1) {
                            goToPage(currentPage + 1);
                        } else if (diffX > 0 && currentPage > 0) {
                            goToPage(currentPage - 1);
                        }
                    }
                }

                // Keyboard Arrow Keys Support
                document.addEventListener('keydown', function (e) {
                    if (e.key === 'ArrowRight') {
                        if (currentPage < totalPages - 1) goToPage(currentPage + 1);
                    } else if (e.key === 'ArrowLeft') {
                        if (currentPage > 0) goToPage(currentPage - 1);
                    }
                });

                // Initialize state
                updateCarousel();
            });
        </script>

    <% } else { %>

        <!-- REGULAR USER / POC WORKSPACE (Static Single Page) -->
        <div class="dashboard-section">
            <div class="dashboard-section-title" style="font-size: 1.1rem; font-weight: 700; color: #1e293b; margin-bottom: 14px;">
                <i class="fas fa-th-large" style="color:#4f46e5;"></i>
                <span>My Workspace</span>
            </div>
            <div class="dashboard-grid-4">
                <a href="Attendance.aspx" class="card-custom card-theme-emerald">
                    <div class="card-icon-box">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="card-content-body">
                        <h3>Attendance</h3>
                        <p>Mark daily attendance &amp; record shifts</p>
                    </div>
                    <div class="card-circle-arrow">
                        <i class="fas fa-arrow-right"></i>
                    </div>
                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                    </svg>
                </a>

                <a href="Ledger.aspx" class="card-custom card-theme-sky">
                    <div class="card-icon-box">
                        <i class="fas fa-book"></i>
                    </div>
                    <div class="card-content-body">
                        <h3>Ledger</h3>
                        <p>Track leave balance &amp; adjustments</p>
                    </div>
                    <div class="card-circle-arrow">
                        <i class="fas fa-arrow-right"></i>
                    </div>
                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                    </svg>
                </a>

                <a href="Notices.aspx" class="card-custom card-theme-emerald">
                    <div class="card-icon-box">
                        <i class="fas fa-bullhorn"></i>
                    </div>
                    <div class="card-content-body">
                        <h3>Notices</h3>
                        <p>View announcements &amp; notices</p>
                    </div>
                    <div class="card-circle-arrow">
                        <i class="fas fa-arrow-right"></i>
                    </div>
                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                    </svg>
                </a>

                <a href="UserRemarks.aspx" class="card-custom card-theme-indigo">
                    <div class="card-icon-box">
                        <i class="fas fa-comment-alt"></i>
                    </div>
                    <div class="card-content-body">
                        <h3>Remarks</h3>
                        <p>View sent &amp; report attendance corrections</p>
                    </div>
                    <div class="card-circle-arrow">
                        <i class="fas fa-arrow-right"></i>
                    </div>
                    <svg class="card-wave-accent" viewBox="0 0 100 100" fill="currentColor">
                        <path d="M0 50 Q 25 30, 50 50 T 100 50 L 100 100 L 0 100 Z" opacity="0.3"/>
                    </svg>
                </a>
            </div>
        </div>

    <% } %>
</asp:Content>
