<%@ Page Title="My Remarks" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserRemarks.aspx.cs" Inherits="AttendanceApp.UserRemarks" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">My Remarks</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ── Page header ── */
        .ur-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
        }
        .ur-title-block { display: flex; align-items: center; gap: 14px; }
        .ur-title-icon {
            width: 48px; height: 48px; border-radius: 14px;
            background: linear-gradient(135deg, #4f46e5, #3730a3);
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 1.3rem;
            box-shadow: 0 4px 12px rgba(79,70,229,0.3);
        }
        .ur-page-title  { font-size: 1.6rem; font-weight: 800; color: #0f172a; margin: 0; }
        .ur-page-sub    { font-size: 0.85rem; color: #64748b; margin: 0; }

        /* ── Send button ── */
        .btn-send-remark {
            padding: 10px 22px; border-radius: 10px; border: none; cursor: pointer;
            font-weight: 700; font-size: 0.9rem;
            background: linear-gradient(135deg, #4f46e5, #3730a3);
            color: white; box-shadow: 0 4px 12px rgba(79,70,229,0.28);
            display: inline-flex; align-items: center; gap: 8px;
            transition: all 0.2s;
        }
        .btn-send-remark:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(79,70,229,0.35); }

        /* ── Stats strip ── */
        .ur-stats { display: flex; gap: 14px; margin-bottom: 20px; flex-wrap: wrap; }
        .ur-stat-chip {
            background: white; border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 10px 18px; display: flex; align-items: center; gap: 10px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04); font-size: 0.88rem; color: #334155;
        }
        .ur-stat-num { font-size: 1.3rem; font-weight: 800; color: #4f46e5; }
        .ur-stat-chip.pending .ur-stat-num { color: #f59e0b; }
        .ur-stat-chip.seen   .ur-stat-num  { color: #10b981; }

        /* ── Remark cards ── */
        .remark-list { display: flex; flex-direction: column; gap: 14px; }
        .remark-card {
            background: white; border-radius: 14px; padding: 20px 22px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06); border: 1px solid #e2e8f0;
            border-left: 5px solid #4f46e5; transition: all 0.22s ease;
        }
        .remark-card.seen { border-left-color: #10b981; }
        .remark-card:hover { box-shadow: 0 6px 20px rgba(0,0,0,0.1); transform: translateY(-1px); }

        .remark-card-top {
            display: flex; align-items: flex-start; justify-content: space-between;
            flex-wrap: wrap; gap: 8px; margin-bottom: 10px;
        }
        .remark-emp-info { display: flex; align-items: center; gap: 10px; }
        .remark-emp-avatar {
            width: 38px; height: 38px; border-radius: 50%;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            display: flex; align-items: center; justify-content: center;
            color: white; font-weight: 700; font-size: 0.85rem; flex-shrink: 0;
        }
        .remark-emp-name  { font-weight: 700; color: #0f172a; font-size: 0.93rem; }
        .remark-emp-id    { font-size: 0.8rem; color: #64748b; margin-top: 1px; }
        .remark-meta-right { text-align: right; }
        .remark-date-chip {
            display: inline-flex; align-items: center; gap: 5px;
            background: #eff6ff; color: #1d4ed8; padding: 3px 10px;
            border-radius: 20px; font-size: 0.78rem; font-weight: 600;
            border: 1px solid #bfdbfe;
        }
        .remark-sent-at { font-size: 0.75rem; color: #94a3b8; margin-top: 4px; }

        .remark-msg {
            color: #334155; font-size: 0.9rem; line-height: 1.65;
            background: #f8fafc; border-radius: 8px; padding: 10px 14px;
            border: 1px solid #e2e8f0; margin-bottom: 10px;
        }
        .badge-seen {
            display: inline-flex; align-items: center; gap: 5px;
            background: #dcfce7; color: #15803d; font-size: 0.77rem;
            padding: 3px 12px; border-radius: 20px; font-weight: 600;
        }
        .badge-pending {
            display: inline-flex; align-items: center; gap: 5px;
            background: #fef3c7; color: #b45309; font-size: 0.77rem;
            padding: 3px 12px; border-radius: 20px; font-weight: 600;
        }
        .ur-loader { text-align: center; padding: 48px; color: #64748b; }
        .spin { display: inline-block; width: 26px; height: 26px; border: 3px solid #e2e8f0;
                border-top-color: #4f46e5; border-radius: 50%; animation: spin .7s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .ur-empty { text-align: center; padding: 60px 20px; color: #64748b; }
        .ur-empty i { font-size: 2.8rem; color: #cbd5e1; display: block; margin-bottom: 16px; }
        .ur-empty-title { font-size: 1rem; font-weight: 600; color: #374151; margin-bottom: 6px; }
        .ur-empty-sub   { font-size: 0.86rem; }

        /* ── Modal ── */
        #remarkModal {
            display: none; position: fixed; inset: 0;
            background: rgba(15,23,42,0.45); backdrop-filter: blur(6px);
            z-index: 100000; align-items: center; justify-content: center;
        }
        #remarkModal.open { display: flex; }
        .remark-modal-box {
            background: white; border-radius: 18px; width: 520px; max-width: 95%;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.3);
            animation: popIn 0.28s cubic-bezier(0.34,1.56,0.64,1);
            overflow: hidden;
        }
        @keyframes popIn { from { opacity:0; transform:scale(0.93); } to { opacity:1; transform:scale(1); } }
        .remark-modal-header {
            background: linear-gradient(135deg, #4f46e5, #3730a3);
            padding: 20px 24px; color: white;
            display: flex; align-items: center; justify-content: space-between;
        }
        .remark-modal-title { font-size: 1.05rem; font-weight: 700; display: flex; align-items: center; gap: 10px; }
        .remark-modal-close {
            background: rgba(255,255,255,0.15); border: none; color: white;
            width: 32px; height: 32px; border-radius: 50%; cursor: pointer;
            font-size: 1rem; display: flex; align-items: center; justify-content: center;
            transition: background 0.2s;
        }
        .remark-modal-close:hover { background: rgba(255,255,255,0.3); }
        .remark-modal-body  { padding: 24px; }
        .remark-modal-footer {
            padding: 16px 24px; border-top: 1px solid #f1f5f9;
            display: flex; gap: 10px; justify-content: flex-end;
        }
        .remark-field { margin-bottom: 18px; }
        .remark-label { font-size: 0.84rem; font-weight: 700; color: #374151; margin-bottom: 6px; display: block; }
        .remark-input {
            width: 100%; padding: 10px 14px; border-radius: 8px;
            border: 1.5px solid #e2e8f0; font-size: 0.9rem; color: #1e293b;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s;
            background: #f8fafc; box-sizing: border-box;
        }
        .remark-input:focus { border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79,70,229,0.12); background: white; }
        .emp-contract-info {
            background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px;
            padding: 7px 12px; font-size: 0.8rem; color: #1d4ed8;
            margin-top: 6px; display: none;
        }
        .char-counter { font-size: 0.75rem; color: #94a3b8; text-align: right; margin-top: 4px; }
        .btn-cancel {
            padding: 9px 20px; border-radius: 8px; border: 1.5px solid #e2e8f0;
            background: white; color: #64748b; font-weight: 600; cursor: pointer;
            font-size: 0.88rem; transition: all 0.2s;
        }
        .btn-cancel:hover { background: #f8fafc; }
        .btn-submit {
            padding: 9px 22px; border-radius: 8px; border: none;
            background: linear-gradient(135deg, #4f46e5, #3730a3);
            color: white; font-weight: 700; cursor: pointer; font-size: 0.88rem;
            box-shadow: 0 4px 12px rgba(79,70,229,0.25);
            display: inline-flex; align-items: center; gap: 7px; transition: all 0.2s;
        }
        .btn-submit:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(79,70,229,0.35); }
        .btn-submit:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
        #toast-container {
            z-index: 200000 !important;
        }

        /* ── Delete Confirmation Modal ── */
        #deleteConfirmModal {
            display: none; position: fixed; inset: 0;
            background: rgba(15,23,42,0.45); backdrop-filter: blur(6px);
            z-index: 100000; align-items: center; justify-content: center;
        }
        #deleteConfirmModal.open { display: flex; }
        .confirm-modal-box {
            background: white; border-radius: 18px; width: 440px; max-width: 95%;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.3);
            animation: popIn 0.25s cubic-bezier(0.34,1.56,0.64,1);
            overflow: hidden;
        }
        .confirm-modal-header {
            background: #fff5f5; padding: 20px 24px; border-bottom: 1px solid #fee2e2;
            display: flex; align-items: center; gap: 14px;
        }
        .confirm-modal-icon {
            background: #fee2e2; color: #ef4444; width: 42px; height: 42px;
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
            font-size: 1.25rem; flex-shrink: 0;
        }
        .confirm-modal-title { font-size: 1.1rem; font-weight: 700; color: #991b1b; }
        .confirm-modal-body  { padding: 24px; font-size: 0.95rem; color: #475569; line-height: 1.5; }
        .confirm-modal-footer {
            padding: 16px 24px; border-top: 1px solid #f1f5f9;
            display: flex; gap: 12px; justify-content: flex-end;
            background: #f8fafc;
        }
        .btn-confirm-delete {
            padding: 9px 22px; border-radius: 8px; border: none;
            background: linear-gradient(135deg, #ef4444, #b91c1c);
            color: white; font-weight: 700; cursor: pointer; font-size: 0.88rem;
            box-shadow: 0 4px 12px rgba(239,68,68,0.25);
            display: inline-flex; align-items: center; gap: 7px; transition: all 0.2s;
        }
        .btn-confirm-delete:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(239,68,68,0.35); }
        .btn-confirm-delete:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Page header -->
    <div class="ur-header">
        <div class="ur-title-block">
            <div class="ur-title-icon"><i class="fas fa-comment-alt"></i></div>
            <div>
                <p class="ur-page-title">My Remarks</p>
                <p class="ur-page-sub">View and send attendance correction requests to admin</p>
            </div>
        </div>
        <button type="button" class="btn-send-remark" onclick="openRemarkModal()">
            <i class="fas fa-paper-plane"></i> Send Remark
        </button>
    </div>

    <!-- Stats strip -->
    <div class="ur-stats">
        <div class="ur-stat-chip"><div class="ur-stat-num" id="statTotal">--</div><div>Total Sent</div></div>
        <div class="ur-stat-chip pending"><div class="ur-stat-num" id="statPending">--</div><div>Pending Review</div></div>
        <div class="ur-stat-chip seen"><div class="ur-stat-num" id="statSeen">--</div><div>Seen by Admin</div></div>
    </div>

    <!-- Remarks list -->
    <div id="urLoader" class="ur-loader"><div class="spin"></div><p style="margin-top:12px;">Loading remarks...</p></div>
    <div id="urList" class="remark-list"></div>

    <!-- Send Remark Modal -->
    <div id="remarkModal">
        <div class="remark-modal-box">
            <div class="remark-modal-header">
                <div class="remark-modal-title"><i class="fas fa-comment-alt"></i> Send Attendance Remark</div>
                <button type="button" class="remark-modal-close" onclick="closeRemarkModal()">&#x2715;</button>
            </div>
            <div class="remark-modal-body">
                <div class="remark-field">
                    <label class="remark-label"><i class="fas fa-user-tie mr-1"></i> Employee</label>
                    <select id="rmEmpSelect" class="remark-input" onchange="onEmpChange()">
                        <option value="">-- Select Employee --</option>
                    </select>
                    <div class="emp-contract-info" id="empContractInfo"></div>
                </div>
                <div class="remark-field">
                    <label class="remark-label"><i class="fas fa-calendar-alt mr-1"></i> Date of concern</label>
                    <div class="d-flex" style="gap: 8px;">
                        <input type="date" id="rmDate" class="remark-input" style="flex-grow: 1;" />
                        <button type="button" class="btn btn-outline-primary font-weight-bold" onclick="addConcernDate()" style="border-radius: 8px; padding: 0 16px; border: 1.5px solid #4f46e5; color: #4f46e5; background: white; cursor: pointer; transition: all 0.2s;">
                            <i class="fas fa-plus"></i> Add
                        </button>
                    </div>
                    <div id="rmDateHelp" style="font-size:0.78rem; color:#94a3b8; margin-top:4px;"></div>
                    <div id="selectedDatesContainer" class="d-flex flex-wrap mt-2" style="gap: 8px;"></div>
                </div>
                <div class="remark-field">
                    <label class="remark-label"><i class="fas fa-question-circle mr-1"></i> What is this remark about?</label>
                    <div class="d-flex align-items-center flex-wrap" style="gap: 20px; margin-top: 8px;">
                        <label class="d-flex align-items-center mb-0" style="font-size: 0.9rem; font-weight: 600; color: #475569; cursor: pointer;">
                            <input type="radio" name="remarkType" value="attendance" onchange="onRemarkTypeChange()" style="margin-right: 8px; width: 18px; height: 18px; accent-color: #4f46e5;" />
                            Attendance correction / changes
                        </label>
                        <label class="d-flex align-items-center mb-0" style="font-size: 0.9rem; font-weight: 600; color: #475569; cursor: pointer;">
                            <input type="radio" name="remarkType" value="other" onchange="onRemarkTypeChange()" style="margin-right: 8px; width: 18px; height: 18px; accent-color: #4f46e5;" />
                            Other related remarks
                        </label>
                    </div>
                </div>
                <div class="remark-field" id="divRemarkMessage" style="display: none;">
                    <label class="remark-label"><i class="fas fa-pen mr-1"></i> Remarks / Reason</label>
                    <textarea id="rmMessage" class="remark-input" rows="4" maxlength="1000"
                        placeholder="e.g. Employee was present on this day but forgot to mark attendance..."
                        oninput="updateCharCount()"></textarea>
                    <div class="char-counter"><span id="charCount">0</span>/1000</div>
                </div>
            </div>
            <div class="remark-modal-footer">
                <button type="button" class="btn-cancel" onclick="closeRemarkModal()">Cancel</button>
                <button type="button" class="btn-submit" id="btnSubmitRemark" onclick="submitRemark()">
                    <i class="fas fa-paper-plane"></i> Send Remark
                </button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="deleteConfirmModal">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header">
                <div class="confirm-modal-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <span class="confirm-modal-title">Delete Remark</span>
            </div>
            <div class="confirm-modal-body">
                Are you sure you want to delete this remark? It will be removed from your list and the admin's inbox permanently.
            </div>
            <div class="confirm-modal-footer">
                <button type="button" class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
                <button type="button" class="btn-confirm-delete" id="btnConfirmDelete" onclick="executeDeleteMyRemark()">
                    <i class="fas fa-trash-alt"></i> Delete
                </button>
            </div>
        </div>
    </div>

    <script>
        var empList   = [];
        var myRemarks = [];

        window.addEventListener('DOMContentLoaded', function () {
            loadEmployees();
            loadMyRemarks();
        });

        // ── Load employees ────────────────────────────────────────────────

        function loadEmployees() {
            fetch('UserRemarks.aspx/GetEmployeesForRemark', {
                method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}'
            })
            .then(function(r){ return r.json(); })
            .then(function(data){
                empList = JSON.parse(data.d);
                var sel = document.getElementById('rmEmpSelect');
                empList.forEach(function(e){
                    var opt = document.createElement('option');
                    opt.value = e.MasterId;
                    opt.textContent = e.Name + ' (' + e.ID + ')';
                    opt.setAttribute('data-join', e.JoinDate || '');
                    opt.setAttribute('data-end',  e.EndDate  || '');
                    sel.appendChild(opt);
                });
            })
            .catch(function(){});
        }

        function onEmpChange() {
            var sel       = document.getElementById('rmEmpSelect');
            var opt       = sel.options[sel.selectedIndex];
            var infoDiv   = document.getElementById('empContractInfo');
            var dateInput = document.getElementById('rmDate');
            var helpDiv   = document.getElementById('rmDateHelp');

            if (!sel.value) { infoDiv.style.display = 'none'; return; }

            var joinDate = opt.getAttribute('data-join');
            var endDate  = opt.getAttribute('data-end');

            if (joinDate) dateInput.min = joinDate; else dateInput.removeAttribute('min');
            if (endDate)  dateInput.max = endDate;  else dateInput.removeAttribute('max');

            if (dateInput.value && joinDate && dateInput.value < joinDate) dateInput.value = '';
            if (dateInput.value && endDate  && dateInput.value > endDate)  dateInput.value = '';

            infoDiv.style.display = 'block';
            infoDiv.innerHTML = '<i class="fas fa-info-circle mr-1"></i> Contract period: '
                + (joinDate || 'N/A') + ' to ' + (endDate || 'Present');
            helpDiv.textContent = joinDate
                ? 'Allowed dates: ' + joinDate + ' to ' + (endDate || 'today') : '';
        }

        // ── Modal ─────────────────────────────────────────────────────────

        var selectedDates = [];

        function openRemarkModal() {
            var modal = document.getElementById('remarkModal');
            modal.classList.add('open');
            var today = new Date().toISOString().split('T')[0];
            document.getElementById('rmDate').value = today;

            // Reset type selection and hide message box
            var radios = document.getElementsByName('remarkType');
            for (var i = 0; i < radios.length; i++) {
                radios[i].checked = false;
            }
            document.getElementById('divRemarkMessage').style.display = 'none';
            document.getElementById('rmMessage').value = '';
            updateCharCount();

            // Reset dates list
            selectedDates = [];
            renderSelectedDates();
        }

        function closeRemarkModal() {
            document.getElementById('remarkModal').classList.remove('open');
        }

        document.addEventListener('click', function(e) {
            var modal = document.getElementById('remarkModal');
            if (e.target === modal) closeRemarkModal();
        });

        function addConcernDate() {
            var dateInput = document.getElementById('rmDate');
            var dateVal = dateInput.value;
            if (!dateVal) { showToast('Please select a date to add.', 'warning'); return; }

            // Verify contract bounds
            var sel = document.getElementById('rmEmpSelect');
            if (sel.value) {
                var opt = sel.options[sel.selectedIndex];
                var joinDate = opt.getAttribute('data-join');
                var endDate = opt.getAttribute('data-end');
                if (joinDate && dateVal < joinDate) {
                    showToast('Selected date is before employee join date (' + joinDate + ').', 'warning');
                    return;
                }
                if (endDate && dateVal > endDate) {
                    showToast('Selected date is after employee contract end date (' + endDate + ').', 'warning');
                    return;
                }
            }

            if (selectedDates.indexOf(dateVal) !== -1) {
                showToast('This date is already in the list.', 'warning');
                return;
            }

            selectedDates.push(dateVal);
            renderSelectedDates();
        }

        function removeConcernDate(d) {
            selectedDates = selectedDates.filter(function(x) { return x !== d; });
            renderSelectedDates();
        }

        function renderSelectedDates() {
            var container = document.getElementById('selectedDatesContainer');
            if (selectedDates.length === 0) {
                container.innerHTML = '<span class="text-muted small" style="font-style: italic;">No dates selected</span>';
                return;
            }
            container.innerHTML = selectedDates.map(function(d) {
                var dateObj = new Date(d);
                var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                var formatted = dateObj.getDate() + '-' + monthNames[dateObj.getMonth()] + '-' + dateObj.getFullYear();
                return '<span class="badge mb-1 mr-1" style="background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; font-size:0.82rem; padding: 4px 10px; border-radius: 6px; display:inline-flex; align-items:center; gap:6px; font-weight:600;">'
                    + '<i class="fas fa-calendar-day"></i> ' + formatted
                    + '<i class="fas fa-times-circle" onclick="removeConcernDate(\'' + d + '\')" style="cursor:pointer; color:#ef4444; font-size:0.88rem; margin-left: 2px;"></i>'
                    + '</span>';
            }).join('');
        }

        function onRemarkTypeChange() {
            var radios = document.getElementsByName('remarkType');
            var selectedVal = "";
            for (var i = 0; i < radios.length; i++) {
                if (radios[i].checked) {
                    selectedVal = radios[i].value;
                    break;
                }
            }

            var msgDiv = document.getElementById('divRemarkMessage');
            var msgInput = document.getElementById('rmMessage');

            if (selectedVal) {
                msgDiv.style.display = 'block';
                if (selectedVal === 'attendance') {
                    msgInput.placeholder = "e.g. Employee was present on this day but forgot to mark attendance...";
                } else {
                    msgInput.placeholder = "e.g. Leave application query, contract extension concern, or other general remarks...";
                }
            } else {
                msgDiv.style.display = 'none';
            }
        }

        function updateCharCount() {
            var len = document.getElementById('rmMessage').value.length;
            var el  = document.getElementById('charCount');
            el.textContent = len;
            el.style.color = len > 900 ? '#ef4444' : '#94a3b8';
        }

        // ── Submit ────────────────────────────────────────────────────────

        function submitRemark() {
            var empId   = document.getElementById('rmEmpSelect').value;
            var message = document.getElementById('rmMessage').value.trim();

            if (!empId) { showToast('Please select an employee.', 'warning'); return; }

            var radios = document.getElementsByName('remarkType');
            var selectedVal = "";
            for (var i = 0; i < radios.length; i++) {
                if (radios[i].checked) {
                    selectedVal = radios[i].value;
                    break;
                }
            }
            if (!selectedVal) { showToast('Please select what this remark is about.', 'warning'); return; }
            if (!message)     { showToast('Please enter a remark message.', 'warning'); return; }

            // Extract selected dates
            var datesToSend = [...selectedDates];
            var activeDateVal = document.getElementById('rmDate').value;
            if (activeDateVal && datesToSend.indexOf(activeDateVal) === -1) {
                // Auto-add date from field if not already in the list
                datesToSend.push(activeDateVal);
            }

            // Validation based on remark type
            if (selectedVal === 'attendance') {
                if (datesToSend.length === 0) {
                    showToast('Please select at least one date of concern.', 'warning');
                    return;
                }
            } else {
                // For other related remarks, date is not compulsory. If empty, default to today.
                if (datesToSend.length === 0) {
                    datesToSend.push(new Date().toISOString().split('T')[0]);
                }
            }

            var prefix = selectedVal === 'attendance' ? '[Attendance Correction] ' : '[General Remark] ';
            var finalMessage = prefix + message;

            var btn = document.getElementById('btnSubmitRemark');
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';

            fetch('UserRemarks.aspx/SubmitRemark', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ empId: empId, remarkDates: datesToSend, message: finalMessage })
            })
            .then(function(r){ return r.json(); })
            .then(function(data) {
                var res = JSON.parse(data.d || '{}');
                if (res.error) {
                    showToast('Error sending remark: ' + res.error, 'error');
                } else {
                    showToast('Remarks sent successfully!', 'success');
                    closeRemarkModal();
                    document.getElementById('rmEmpSelect').value = '';
                    document.getElementById('rmDate').value = '';
                    document.getElementById('rmMessage').value = '';
                    var radios = document.getElementsByName('remarkType');
                    for (var i = 0; i < radios.length; i++) {
                        radios[i].checked = false;
                    }
                    document.getElementById('divRemarkMessage').style.display = 'none';
                    selectedDates = [];
                    renderSelectedDates();
                    updateCharCount();
                    document.getElementById('empContractInfo').style.display = 'none';
                    loadMyRemarks();
                }
            })
            .catch(function(){ showToast('Failed to send remark. Please try again.', 'error'); })
            .finally(function(){
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-paper-plane"></i> Send Remark';
            });
        }

        // ── Load & render my remarks ──────────────────────────────────────

        function loadMyRemarks() {
            fetch('UserRemarks.aspx/GetMyRemarks', {
                method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}'
            })
            .then(function(r){ return r.json(); })
            .then(function(data){
                myRemarks = JSON.parse(data.d);
                document.getElementById('urLoader').style.display = 'none';
                updateStats();
                renderRemarks();
            })
            .catch(function(){
                document.getElementById('urLoader').innerHTML =
                    '<i class="fas fa-exclamation-circle" style="color:#ef4444;"></i> Failed to load remarks.';
            });
        }

        function updateStats() {
            var total   = myRemarks.length;
            var seen    = myRemarks.filter(function(r){ return r.IsRead; }).length;
            var pending = total - seen;
            document.getElementById('statTotal').textContent   = total;
            document.getElementById('statPending').textContent = pending;
            document.getElementById('statSeen').textContent    = seen;
        }

        function renderRemarks() {
            var container = document.getElementById('urList');
            if (!myRemarks || myRemarks.length === 0) {
                container.innerHTML =
                    '<div class="ur-empty">'
                    + '<i class="fas fa-comment-slash"></i>'
                    + '<div class="ur-empty-title">No remarks sent yet</div>'
                    + '<div class="ur-empty-sub">Click "Send Remark" above to report an attendance correction to admin.</div>'
                    + '</div>';
                return;
            }
            container.innerHTML = myRemarks.map(function(r) {
                var initials = (r.EmpName || 'E').split(' ').map(function(w){ return w[0]; }).join('').substring(0,2).toUpperCase();
                var seenCls  = r.IsRead ? 'seen' : '';
                var badge    = r.IsRead
                    ? '<span class="badge-seen"><i class="fas fa-check-circle mr-1"></i>Seen by admin</span>'
                    : '<span class="badge-pending"><i class="fas fa-clock mr-1"></i>Pending review</span>';

                var msg = r.Message || '';
                var typeBadge = '';
                if (msg.indexOf('[Attendance Correction] ') === 0) {
                    msg = msg.substring('[Attendance Correction] '.length);
                    typeBadge = '<span class="badge" style="background:#e0e7ff; color:#4f46e5; border: 1px solid #c7d2fe; font-size: 0.72rem; font-weight: 700; padding: 3px 8px; border-radius: 12px; vertical-align: middle; display: inline-flex; align-items: center; gap: 4px; margin-right: 6px;"><i class="fas fa-magic" style="font-size: 0.7rem;"></i>Correction</span> ';
                } else if (msg.indexOf('[General Remark] ') === 0) {
                    msg = msg.substring('[General Remark] '.length);
                    typeBadge = '<span class="badge" style="background:#f1f5f9; color:#475569; border: 1px solid #cbd5e1; font-size: 0.72rem; font-weight: 700; padding: 3px 8px; border-radius: 12px; vertical-align: middle; display: inline-flex; align-items: center; gap: 4px; margin-right: 6px;"><i class="fas fa-comment" style="font-size: 0.7rem;"></i>General</span> ';
                }

                var idsString = r.Ids && r.Ids.length ? r.Ids.join(',') : r.Id;
                var deleteBtn = '<button type="button" onclick="event.preventDefault(); deleteMyRemark(\'' + idsString + '\')" class="btn-delete-remark" style="background:none; border:none; color:#ef4444; cursor:pointer; font-size:0.82rem; display:inline-flex; align-items:center; gap:4px; font-weight:700; padding:4px 8px; border-radius:6px; transition:all 0.15s ease;" onmouseover="this.style.background=\'#fef2f2\'" onmouseout="this.style.background=\'none\'" title="Delete this remark"><i class="fas fa-trash-alt"></i> Delete</button>';

                return '<div class="remark-card ' + seenCls + '">'
                    + '<div class="remark-card-top">'
                    +   '<div class="remark-emp-info">'
                    +     '<div class="remark-emp-avatar">' + initials + '</div>'
                    +     '<div>'
                    +       '<div class="remark-emp-name">' + esc(r.EmpName) + '</div>'
                    +       '<div class="remark-emp-id"><i class="fas fa-id-badge mr-1"></i>ID: ' + esc(r.EmpIDDisplay) + ' | Master ID: ' + esc(r.EmpMasterId) + '</div>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="remark-meta-right">'
                    +     '<div class="remark-date-chip"><i class="fas fa-calendar-alt"></i>' + esc(r.RemarkDateStr) + '</div>'
                    +     '<div class="remark-sent-at">' + esc(r.CreatedAtStr) + '</div>'
                    +   '</div>'
                    + '</div>'
                    + '<div class="remark-msg">' + typeBadge + esc(msg) + '</div>'
                    + '<div style="display:flex; align-items:center; justify-content:space-between; margin-top:10px; border-top:1px solid #f1f5f9; padding-top:10px;">'
                    +   '<div>' + badge + '</div>'
                    +   '<div>' + deleteBtn + '</div>'
                    + '</div>'
                    + '</div>';
            }).join('');
        }

        var deleteTargetIds = null;

        function deleteMyRemark(ids) {
            deleteTargetIds = ids;
            document.getElementById('deleteConfirmModal').classList.add('open');
        }

        function closeDeleteModal() {
            document.getElementById('deleteConfirmModal').classList.remove('open');
            deleteTargetIds = null;
        }

        function executeDeleteMyRemark() {
            if (!deleteTargetIds) return;
            
            var btn = document.getElementById('btnConfirmDelete');
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';

            fetch('UserRemarks.aspx/DeleteMyRemark', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ids: deleteTargetIds })
            })
            .then(function(r){ return r.json(); })
            .then(function(data){
                var res = JSON.parse(data.d);
                if (res.error) {
                    showToast(res.error, 'error');
                } else {
                    showToast('Remark deleted successfully!', 'success');
                    closeDeleteModal();
                    loadMyRemarks();
                }
            })
            .catch(function(){
                showToast('Failed to delete remark. Please try again.', 'error');
            })
            .finally(function() {
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-trash-alt"></i> Delete';
            });
        }

        function esc(s) {
            if (!s) return '';
            return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
        }
    </script>
</asp:Content>
