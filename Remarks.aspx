<%@ Page Title="Remarks" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Remarks.aspx.cs" Inherits="AttendanceApp.Remarks" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Remarks Inbox
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .remarks-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .remarks-title-block { display: flex; align-items: center; gap: 14px; }
        .remarks-title-icon {
            width: 48px; height: 48px; border-radius: 14px;
            background: linear-gradient(135deg, #4f46e5, #3730a3);
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 1.3rem;
            box-shadow: 0 4px 12px rgba(79,70,229,0.3);
        }
        .remarks-page-title { font-size: 1.6rem; font-weight: 800; color: #0f172a; margin: 0; }
        .remarks-page-sub { font-size: 0.85rem; color: #64748b; margin: 0; }

        .mark-all-btn {
            padding: 8px 20px; border-radius: 8px; border: none; cursor: pointer;
            font-weight: 700; font-size: 0.88rem; transition: all 0.2s;
            display: inline-flex; align-items: center; gap: 8px;
            background: linear-gradient(135deg, #4f46e5, #3730a3);
            color: white; box-shadow: 0 4px 12px rgba(79,70,229,0.25);
        }
        .mark-all-btn:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(79,70,229,0.35); }

        .stats-bar {
            display: flex; gap: 16px; margin-bottom: 20px; flex-wrap: wrap;
        }
        .stat-chip {
            display: flex; align-items: center; gap: 8px;
            background: white; border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 10px 18px; font-size: 0.88rem; color: #334155;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .stat-chip .stat-num { font-size: 1.3rem; font-weight: 800; color: #4f46e5; }
        .stat-chip.stat-unread .stat-num { color: #ef4444; }

        .filter-bar {
            background: white; border-radius: 12px; padding: 12px 18px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04); margin-bottom: 16px;
            display: flex; gap: 12px; align-items: center; flex-wrap: wrap;
            border: 1px solid #e2e8f0;
        }
        .filter-bar select, .filter-bar input {
            border: 1px solid #cbd5e1; border-radius: 8px; padding: 7px 12px;
            font-size: 0.88rem; color: #334155; outline: none;
            transition: border-color 0.2s; background: #f8fafc;
        }
        .filter-bar select:focus, .filter-bar input:focus { border-color: #4f46e5; background: white; }

        /* Split Master-Detail Container */
        .remarks-split-container {
            display: flex;
            gap: 20px;
            align-items: stretch;
            height: calc(100vh - 275px);
            min-height: 520px;
            margin-bottom: 20px;
        }

        /* Left List Pane */
        .remarks-list-pane {
            width: 380px;
            min-width: 380px;
            display: flex;
            flex-direction: column;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            background: white;
            overflow: hidden;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.04);
        }
        .remarks-list-header {
            padding: 14px 18px;
            border-bottom: 1px solid #f1f5f9;
            background: #faf5ff;
            font-weight: 700;
            font-size: 0.9rem;
            color: #4f46e5;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .remarks-compact-list {
            flex-grow: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        /* Compact list item */
        .compact-item {
            padding: 14px 16px 14px 28px;
            border-bottom: 1px solid #f1f5f9;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
            display: flex;
            flex-direction: column;
            gap: 6px;
            border-left: 4px solid transparent;
        }
        .compact-item:hover {
            background-color: #f8fafc;
        }
        .compact-item.active {
            background-color: #eff6ff;
            border-left-color: #4f46e5;
        }
        .compact-item.unread {
            background-color: #fafbff;
        }
        .compact-item.unread .compact-sender {
            font-weight: 700;
            color: #0f172a;
        }
        
        .compact-top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.8rem;
        }
        .compact-sender {
            font-weight: 600;
            color: #334155;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 200px;
        }
        .compact-time {
            color: #94a3b8;
            font-size: 0.75rem;
        }
        
        .compact-emp-row {
            font-size: 0.8rem;
            color: #64748b;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .compact-subject {
            font-size: 0.82rem;
            color: #475569;
            display: flex;
            align-items: center;
            gap: 6px;
            overflow: hidden;
        }
        .compact-subject-text {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex-grow: 1;
        }

        .unread-dot {
            width: 8px;
            height: 8px;
            background-color: #4f46e5;
            border-radius: 50%;
            display: inline-block;
            position: absolute;
            left: 10px;
            top: 20px;
        }

        /* Right Detail Pane */
        .remarks-detail-pane {
            flex-grow: 1;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            background: white;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.04);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .detail-placeholder {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            flex-grow: 1;
            color: #94a3b8;
            padding: 40px;
            text-align: center;
        }
        .detail-placeholder i {
            font-size: 3.5rem;
            color: #cbd5e1;
            margin-bottom: 16px;
        }
        .detail-placeholder h5 {
            font-weight: 700;
            color: #64748b;
            margin-bottom: 6px;
        }

        .detail-content {
            display: flex;
            flex-direction: column;
            height: 100%;
            padding: 24px;
            overflow-y: auto;
        }

        .detail-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 16px;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .detail-sender-info {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .detail-avatar {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.05rem;
        }
        .detail-sender-name {
            font-size: 1.02rem;
            font-weight: 700;
            color: #0f172a;
        }
        .detail-sender-pcno {
            font-size: 0.82rem;
            color: #64748b;
            margin-top: 1px;
        }

        .detail-meta-right {
            text-align: right;
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 6px;
        }

        .detail-emp-section {
            background: #f8fafc;
            border-radius: 12px;
            padding: 16px 20px;
            border: 1px solid #e2e8f0;
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .detail-emp-title {
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
            color: #94a3b8;
            letter-spacing: 0.05em;
        }
        .detail-emp-row {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            align-items: center;
        }
        .detail-emp-field {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.88rem;
            color: #334155;
        }
        .detail-emp-field.name {
            font-weight: 700;
            color: #0f172a;
        }

        .detail-msg-section {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 24px;
        }
        .detail-msg-title {
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
            color: #94a3b8;
            letter-spacing: 0.05em;
        }
        .detail-msg-text {
            font-size: 0.95rem;
            color: #334155;
            line-height: 1.65;
            background: #faf5ff;
            border-left: 4px solid #a855f7;
            border-radius: 4px 12px 12px 4px;
            padding: 18px 20px;
            margin: 0;
            white-space: pre-wrap;
            flex-grow: 1;
            overflow-y: auto;
        }
        .detail-msg-text.general {
            background: #f8fafc;
            border-left-color: #64748b;
        }

        .detail-footer-actions {
            border-top: 1px solid #f1f5f9;
            padding-top: 18px;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            align-items: center;
            flex-wrap: wrap;
        }

        .btn-remark-read {
            font-size: 0.82rem; padding: 7px 16px; border-radius: 8px;
            border: none; cursor: pointer; font-weight: 600; transition: all 0.2s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-read-action { background: #dbeafe; color: #1d4ed8; }
        .btn-read-action:hover { background: #1d4ed8; color: white; }
        .btn-delete-action { background: #fee2e2; color: #dc2626; }
        .btn-delete-action:hover { background: #dc2626; color: white; }
        .btn-process-action { background: #e0e7ff; color: #4f46e5; border: 1px solid #c7d2fe; }
        .btn-process-action:hover { background: #4f46e5; color: white; }
        
        .badge-unread {
            background: #4f46e5; color: white; font-size: 0.72rem;
            padding: 3px 8px; border-radius: 20px; font-weight: 700;
        }
        .badge-read {
            background: #e2e8f0; color: #64748b; font-size: 0.72rem;
            padding: 3px 8px; border-radius: 20px; font-weight: 600;
        }

        .empty-state {
            text-align: center; padding: 60px 20px;
            color: #64748b; font-size: 1rem;
        }
        .empty-state i { font-size: 3rem; color: #cbd5e1; margin-bottom: 16px; display: block; }

        #remarksLoader { text-align: center; padding: 40px; color: #64748b; }
        .spinner-ring {
            display: inline-block; width: 28px; height: 28px;
            border: 3px solid #e2e8f0; border-top-color: #4f46e5;
            border-radius: 50%; animation: spin 0.7s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="remarks-header">
        <div class="remarks-title-block">
            <div class="remarks-title-icon"><i class="fas fa-inbox"></i></div>
            <div>
                <p class="remarks-page-title">Remarks Inbox</p>
                <p class="remarks-page-sub">Attendance correction requests from regular users</p>
            </div>
        </div>
        <button class="mark-all-btn" onclick="markAllRead()">
            <i class="fas fa-check-double"></i> Mark All as Read
        </button>
    </div>

    <div class="stats-bar" id="statsBar">
        <div class="stat-chip"><div class="stat-num" id="statTotal">—</div><div>Total Remarks</div></div>
        <div class="stat-chip stat-unread"><div class="stat-num" id="statUnread">—</div><div>Unread</div></div>
    </div>

    <div class="filter-bar">
        <i class="fas fa-filter text-muted"></i>
        <select id="filterStatus" onchange="applyFilter()">
            <option value="all">All Remarks</option>
            <option value="unread">Unread Only</option>
            <option value="read">Read Only</option>
        </select>
        <input type="text" id="filterSearch" placeholder="Search by sender, employee or message..." oninput="applyFilter()" style="flex-grow: 1;" />
    </div>

    <div id="remarksLoader"><div class="spinner-ring"></div><p style="margin-top:12px;">Loading remarks...</p></div>
    
    <div class="remarks-split-container" id="remarksSplitContainer" style="display: none;">
        <!-- Left Pane: Compact List -->
        <div class="remarks-list-pane">
            <div class="remarks-list-header">
                <span>Active Inbox</span>
                <span id="listCountBadge" class="badge" style="background: #4f46e5; color: white; font-size: 0.75rem; padding: 2px 8px; border-radius: 10px;">0</span>
            </div>
            <div id="remarksList" class="remarks-compact-list"></div>
        </div>
        
        <!-- Right Pane: Detail View -->
        <div class="remarks-detail-pane" id="remarksDetailPane"></div>
    </div>

    <script>
        let allRemarks = [];
        let selectedRemarkId = null;

        function loadRemarks() {
            fetch('Remarks.aspx/GetAllRemarks', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: '{}'
            })
            .then(r => r.json())
            .then(data => {
                allRemarks = JSON.parse(data.d);
                document.getElementById('remarksLoader').style.display = 'none';
                document.getElementById('remarksSplitContainer').style.display = 'flex';
                updateStats();
                applyFilter();
            })
            .catch(() => {
                document.getElementById('remarksLoader').innerHTML = '<i class="fas fa-exclamation-circle text-danger"></i> Failed to load remarks.';
            });
        }

        function updateStats() {
            const total = allRemarks.length;
            const unread = allRemarks.filter(r => !r.IsRead).length;
            document.getElementById('statTotal').textContent = total;
            document.getElementById('statUnread').textContent = unread;
        }

        function applyFilter() {
            const statusFilter = document.getElementById('filterStatus').value;
            const searchVal = document.getElementById('filterSearch').value.toLowerCase();
            let filtered = allRemarks;
            if (statusFilter === 'unread') filtered = filtered.filter(r => !r.IsRead);
            if (statusFilter === 'read') filtered = filtered.filter(r => r.IsRead);
            if (searchVal) {
                filtered = filtered.filter(r =>
                    (r.SenderName || '').toLowerCase().includes(searchVal) ||
                    (r.EmpName || '').toLowerCase().includes(searchVal) ||
                    (r.EmpID || '').toLowerCase().includes(searchVal) ||
                    (r.Message || '').toLowerCase().includes(searchVal)
                );
            }
            renderRemarks(filtered);
        }

        function renderRemarks(list) {
            const container = document.getElementById('remarksList');
            document.getElementById('listCountBadge').textContent = list.length;
            
            if (!list || list.length === 0) {
                container.innerHTML = `<div class="empty-state" style="padding-top: 100px;"><i class="fas fa-inbox"></i><p>No remarks found.</p></div>`;
                renderEmptyDetail();
                return;
            }

            container.innerHTML = list.map(r => {
                const initials = (r.SenderName || 'U').split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase();
                const isUnread = !r.IsRead;
                const activeCls = (selectedRemarkId === r.Id) ? 'active' : '';
                const unreadCls = isUnread ? 'unread' : '';
                
                const isCorrection = (r.Message || '').startsWith('[Attendance Correction] ');
                const isGeneral = (r.Message || '').startsWith('[General Remark] ');
                let cleanMsg = r.Message || '';
                let typeBadge = '';
                if (isCorrection) {
                    cleanMsg = cleanMsg.substring('[Attendance Correction] '.length);
                    typeBadge = '<span class="badge" style="background:#e0e7ff; color:#4f46e5; border: 1px solid #c7d2fe; font-size: 0.7rem; font-weight: 700; padding: 1px 6px; border-radius: 8px;"><i class="fas fa-magic" style="font-size:0.65rem;"></i></span>';
                } else if (isGeneral) {
                    cleanMsg = cleanMsg.substring('[General Remark] '.length);
                    typeBadge = '<span class="badge" style="background:#f1f5f9; color:#475569; border: 1px solid #cbd5e1; font-size: 0.7rem; font-weight: 700; padding: 1px 6px; border-radius: 8px;"><i class="fas fa-comment" style="font-size:0.65rem;"></i></span>';
                }

                const unreadDot = isUnread ? '<span class="unread-dot"></span>' : '';

                return `
                <div class="compact-item ${unreadCls} ${activeCls}" onclick="selectRemark(${r.Id})" id="item-${r.Id}">
                    ${unreadDot}
                    <div class="compact-top-row">
                        <span class="compact-sender">${escHtml(r.SenderName)}</span>
                        <span class="compact-time">${r.CreatedAtStr.split(' ')[0]}</span>
                    </div>
                    <div class="compact-emp-row">
                        <i class="fas fa-user-tie" style="font-size: 0.75rem;"></i> ${escHtml(r.EmpName)} (ID: ${escHtml(r.EmpID)} | Master ID: ${escHtml(r.EmpMasterId)})
                        <span class="badge ml-1" style="background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd; font-size:0.7rem; font-weight:700; padding:1px 6px; border-radius:8px;"><i class="fas fa-layer-group" style="font-size:0.65rem;"></i> ${escHtml(r.MainCategoryName || 'General')}</span>
                    </div>
                    <div class="compact-subject">
                        ${typeBadge}
                        <span class="compact-subject-text">${escHtml(cleanMsg)}</span>
                    </div>
                </div>`;
            }).join('');

            // Render detail pane
            if (selectedRemarkId) {
                const current = list.find(x => x.Id === selectedRemarkId);
                if (current) {
                    renderDetail(current);
                } else {
                    selectedRemarkId = null;
                    renderEmptyDetail();
                }
            } else {
                renderEmptyDetail();
            }
        }

        function selectRemark(id) {
            selectedRemarkId = id;
            
            document.querySelectorAll('.compact-item').forEach(el => el.classList.remove('active'));
            const activeEl = document.getElementById(`item-${id}`);
            if (activeEl) activeEl.classList.add('active');
            
            const r = allRemarks.find(x => x.Id === id);
            if (!r) return;
            
            renderDetail(r);
            
            // Auto-mark as read silently
            if (!r.IsRead) {
                const idsString = r.Ids && r.Ids.length ? r.Ids.join(',') : r.Id;
                markOneReadSilent(idsString);
            }
        }

        function renderDetail(r) {
            const detailPane = document.getElementById('remarksDetailPane');
            
            const isCorrection = (r.Message || '').startsWith('[Attendance Correction] ');
            const isGeneral = (r.Message || '').startsWith('[General Remark] ');
            let cleanMsg = r.Message || '';
            let typeBadgeHtml = '';
            let correctionBtn = '';
            
            const dateStr = r.RemarkDateStr || '';
            
            if (isCorrection) {
                cleanMsg = cleanMsg.substring('[Attendance Correction] '.length);
                typeBadgeHtml = `<span class="badge" style="background:#e0e7ff; color:#4f46e5; border: 1px solid #c7d2fe; font-size: 0.75rem; font-weight: 700; padding: 4px 10px; border-radius: 12px; display: inline-flex; align-items: center; gap: 4px;"><i class="fas fa-magic" style="font-size: 0.72rem;"></i>Correction Request</span>`;
                
                correctionBtn = `
                    <a href="Attendance.aspx?empId=${encodeURIComponent(r.EmpMasterId)}&date=${encodeURIComponent(dateStr)}&remark=${encodeURIComponent(cleanMsg)}" 
                       class="btn btn-remark-read btn-process-action" 
                       style="text-decoration:none; padding: 8px 16px; border-radius: 8px; font-weight: bold; font-size: 0.85rem;">
                        <i class="fas fa-external-link-alt"></i> Process Correction
                    </a>`;
            } else if (isGeneral) {
                cleanMsg = cleanMsg.substring('[General Remark] '.length);
                typeBadgeHtml = `<span class="badge" style="background:#f1f5f9; color:#475569; border: 1px solid #cbd5e1; font-size: 0.75rem; font-weight: 700; padding: 4px 10px; border-radius: 12px; display: inline-flex; align-items: center; gap: 4px;"><i class="fas fa-comment" style="font-size: 0.72rem;"></i>General Remark</span>`;
            }

            const idsString = r.Ids && r.Ids.length ? r.Ids.join(',') : r.Id;
            const initials = (r.SenderName || 'U').split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase();
            
            const readStatusBadge = !r.IsRead 
                ? `<span class="badge-unread" id="detailUnreadBadge">Unread</span>`
                : `<span class="badge-read" id="detailUnreadBadge">Read</span>`;

            detailPane.innerHTML = `
                <div class="detail-content">
                    <div class="detail-header">
                        <div class="detail-sender-info">
                            <div class="detail-avatar">${initials}</div>
                            <div>
                                <div class="detail-sender-name">${escHtml(r.SenderName)}</div>
                                <div class="detail-sender-pcno">PCNO: ${escHtml(r.SubmittedBy)}</div>
                            </div>
                        </div>
                        <div class="detail-meta-right">
                            <span class="remark-timestamp" style="font-size:0.8rem; color:#64748b;"><i class="far fa-clock mr-1"></i>${r.CreatedAtStr}</span>
                            <div style="display:flex; align-items:center; gap:8px; margin-top: 6px;">
                                ${typeBadgeHtml}
                                ${readStatusBadge}
                            </div>
                        </div>
                    </div>

                    <div class="detail-emp-section">
                        <div class="detail-emp-title">Target Employee & Concern Dates</div>
                        <div class="detail-emp-row">
                            <div class="detail-emp-field name">
                                <i class="fas fa-user-tie text-primary mr-1"></i> ${escHtml(r.EmpName)} (ID: ${escHtml(r.EmpID)} | Master ID: ${escHtml(r.EmpMasterId)})
                            </div>
                            <div class="detail-emp-field">
                                <span class="badge" style="background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; font-size:0.82rem; padding: 4px 10px; border-radius: 8px; font-weight:600;"><i class="fas fa-layer-group mr-1"></i>${escHtml(r.MainCategoryName || 'General')}</span>
                            </div>
                            <div class="detail-emp-field">
                                <span class="badge" style="background:#f0fdf4; color:#15803d; border:1px solid #bbf7d0; font-size:0.82rem; padding: 4px 10px; border-radius: 8px; font-weight:600;"><i class="fas fa-calendar-day mr-1"></i>${dateStr}</span>
                            </div>
                        </div>
                    </div>

                    <div class="detail-msg-section">
                        <div class="detail-msg-title">Remark Message</div>
                        <blockquote class="detail-msg-text ${!isCorrection ? 'general' : ''}">${escHtml(cleanMsg)}</blockquote>
                    </div>

                    <div class="detail-footer-actions">
                        ${correctionBtn}
                        ${!r.IsRead ? `<button class="btn btn-remark-read btn-read-action" style="padding: 8px 16px; border-radius: 8px; font-size: 0.85rem;" onclick="markOneRead('${idsString}')"><i class="fas fa-check"></i> Mark as Read</button>` : ''}
                        <button class="btn btn-remark-read btn-delete-action" style="padding: 8px 16px; border-radius: 8px; font-size: 0.85rem;" onclick="deleteRemark('${idsString}')"><i class="fas fa-trash-alt"></i> Delete</button>
                    </div>
                </div>
            `;
        }

        function renderEmptyDetail() {
            const detailPane = document.getElementById('remarksDetailPane');
            detailPane.innerHTML = `
                <div class="detail-placeholder">
                    <i class="fas fa-envelope-open-text"></i>
                    <h5>No Remark Selected</h5>
                    <p style="font-size: 0.88rem; max-width: 280px; margin: 0 auto;">Select a remark from the inbox list on the left to view details and process corrections.</p>
                </div>
            `;
        }

        function markOneRead(ids) {
            fetch('Remarks.aspx/MarkRead', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ids: ids })
            }).then(() => {
                const idArr = ids.split(',').map(Number);
                allRemarks.forEach(r => {
                    if (idArr.indexOf(r.Id) !== -1 || (r.Ids && r.Ids.some(i => idArr.indexOf(i) !== -1))) {
                        r.IsRead = true;
                    }
                });
                updateStats();
                applyFilter();
                showToast('Marked as read', 'success');
                updateNavBell();
            });
        }

        function markOneReadSilent(ids) {
            fetch('Remarks.aspx/MarkRead', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ids: ids })
            }).then(() => {
                const idArr = ids.split(',').map(Number);
                allRemarks.forEach(r => {
                    if (idArr.indexOf(r.Id) !== -1 || (r.Ids && r.Ids.some(i => idArr.indexOf(i) !== -1))) {
                        r.IsRead = true;
                    }
                });
                updateStats();
                
                const itemEl = document.getElementById(`item-${selectedRemarkId}`);
                if (itemEl) {
                    itemEl.classList.remove('unread');
                    const dot = itemEl.querySelector('.unread-dot');
                    if (dot) dot.remove();
                }
                const detailBadge = document.getElementById('detailUnreadBadge');
                if (detailBadge) {
                    detailBadge.className = 'badge-read';
                    detailBadge.textContent = 'Read';
                }
                updateNavBell();
            });
        }

        function markAllRead() {
            fetch('Remarks.aspx/MarkAllRead', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: '{}'
            }).then(() => {
                allRemarks.forEach(r => r.IsRead = true);
                updateStats();
                applyFilter();
                showToast('All remarks marked as read', 'success');
                updateNavBell();
            });
        }

        function deleteRemark(ids) {
            if (!confirm('Delete this remark? This cannot be undone.')) return;
            fetch('Remarks.aspx/DeleteRemark', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ids: ids })
            }).then(() => {
                const idArr = ids.split(',').map(Number);
                allRemarks = allRemarks.filter(r => {
                    return idArr.indexOf(r.Id) === -1 && (!r.Ids || !r.Ids.some(i => idArr.indexOf(i) !== -1));
                });
                
                if (idArr.indexOf(selectedRemarkId) !== -1) {
                    selectedRemarkId = null;
                }
                
                updateStats();
                applyFilter();
                showToast('Remark deleted', 'success');
            });
        }

        function updateNavBell() {
            const unread = allRemarks.filter(r => !r.IsRead).length;
            const badge = document.getElementById('notifBadge');
            if (badge) {
                badge.textContent = unread;
                badge.style.display = unread > 0 ? 'flex' : 'none';
            }
        }

        function escHtml(s) {
            if (!s) return '';
            return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
        }

        loadRemarks();
    </script>
</asp:Content>
