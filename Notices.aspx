<%@ Page Title="Notices & Announcements" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Notices.aspx.cs" Inherits="AttendanceApp.Notices" EnableEventValidation="false" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Notices &amp; Announcements
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header-block {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .page-title-container {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .page-title-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            background: linear-gradient(135deg, #10b981, #059669);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.3rem;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        .page-title-main {
            font-size: 1.6rem;
            font-weight: 800;
            color: #0f172a;
            margin: 0;
        }
        .page-title-sub {
            font-size: 0.85rem;
            color: #64748b;
            margin: 0;
        }

        .btn-back-dashboard {
            padding: 10px 20px;
            border-radius: 10px;
            border: 1px solid #cbd5e1;
            background: white;
            color: #475569;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-back-dashboard:hover {
            background: #f8fafc;
            color: #1e293b;
            border-color: #94a3b8;
            transform: translateY(-1px);
        }

        .notice-card {
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .notice-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.06) !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Page Header -->
    <div class="page-header-block">
        <div class="page-title-container">
            <div class="page-title-icon">
                <i class="fas fa-bullhorn"></i>
            </div>
            <div>
                <p class="page-title-main">Notices &amp; Announcements</p>
                <p class="page-title-sub">View and download announcements uploaded by administrators</p>
            </div>
        </div>
        <a href="Dashboard.aspx" class="btn-back-dashboard">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <!-- Admin Notice Creation Section -->
    <asp:PlaceHolder ID="phAdminNoticeUpload" runat="server">
        <div class="card mb-4 shadow-sm border-0" style="border-radius: 14px; background: white; border: 1px solid #e2e8f0; overflow: hidden;">
            <div class="card-header bg-light p-3 d-flex align-items-center justify-content-between flex-wrap" style="border-bottom: 1px solid #e2e8f0;">
                <h5 class="card-title font-weight-bold text-dark mb-0" style="font-size: 1.05rem; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-bullhorn text-success"></i> Create Announcement / Notice
                </h5>
                <div class="btn-group btn-group-toggle" data-toggle="buttons">
                    <button type="button" class="btn btn-sm btn-success font-weight-bold active" id="btnTabWrite" onclick="switchNoticeMode('write')">
                        <i class="fas fa-pen-fancy mr-1"></i> Write Text Notice
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-secondary font-weight-bold" id="btnTabUpload" onclick="switchNoticeMode('upload')">
                        <i class="fas fa-upload mr-1"></i> Upload File
                    </button>
                </div>
            </div>

            <div class="card-body p-4">
                <!-- Mode 1: Write Text Announcement -->
                <div id="panelWriteNotice">
                    <div class="row mb-3">
                        <div class="col-md-5 mb-3 mb-md-0">
                            <label class="small font-weight-bold text-muted d-block mb-1">Notice Title / Subject <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtNoticeTitle" runat="server" CssClass="form-control font-weight-bold" placeholder="e.g. Office Holiday Schedule for Independence Day..." style="border-radius: 8px; border-color: #cbd5e1; height: 42px; font-size: 0.95rem;" />
                        </div>
                        <div class="col-md-3 mb-3 mb-md-0">
                            <label class="small font-weight-bold text-muted d-block mb-1">Target Main Category <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlNoticeMainCategory" runat="server" CssClass="form-select form-control font-weight-bold" style="border-radius: 8px; border-color: #cbd5e1; height: 42px; font-size: 0.9rem;">
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label class="small font-weight-bold text-muted d-block mb-1">Category / Priority</label>
                            <asp:DropDownList ID="ddlNoticeCategory" runat="server" CssClass="form-select form-control font-weight-bold" style="border-radius: 8px; border-color: #cbd5e1; height: 42px; font-size: 0.9rem;">
                                <asp:ListItem Text="General Announcement" Value="General Announcement" Selected="True"></asp:ListItem>
                                <asp:ListItem Text="Urgent Notice" Value="Urgent Notice"></asp:ListItem>
                                <asp:ListItem Text="Holiday &amp; Schedule" Value="Holiday &amp; Schedule"></asp:ListItem>
                                <asp:ListItem Text="Policy Update" Value="Policy Update"></asp:ListItem>
                                <asp:ListItem Text="Important Instruction" Value="Important Instruction"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <!-- Rich Formatting Toolbar -->
                    <label class="small font-weight-bold text-muted d-block mb-1">Notice Content <span class="text-danger">*</span></label>
                    <div class="editor-toolbar d-flex align-items-center flex-wrap p-2 mb-2" style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px 8px 0 0; gap: 4px;">
                        <button type="button" class="btn btn-sm btn-light border font-weight-bold" onclick="execFormat('bold')" title="Bold (Ctrl+B)"><b>B</b></button>
                        <button type="button" class="btn btn-sm btn-light border font-italic" onclick="execFormat('italic')" title="Italic (Ctrl+I)"><i>I</i></button>
                        <button type="button" class="btn btn-sm btn-light border" onclick="execFormat('underline')" title="Underline"><u>U</u></button>
                        <button type="button" class="btn btn-sm btn-light border" onclick="execFormat('strikeThrough')" title="Strikethrough"><s>S</s></button>
                        <span class="border-right mx-1" style="height: 24px;"></span>
                        <button type="button" class="btn btn-sm btn-light border font-weight-bold" onclick="execFormat('formatBlock', '<h3>')" title="Heading">H3</button>
                        <button type="button" class="btn btn-sm btn-light border" onclick="execFormat('insertUnorderedList')" title="Bullet List"><i class="fas fa-list-ul"></i></button>
                        <button type="button" class="btn btn-sm btn-light border" onclick="execFormat('insertOrderedList')" title="Numbered List"><i class="fas fa-list-ol"></i></button>
                        <span class="border-right mx-1" style="height: 24px;"></span>
                        <button type="button" class="btn btn-sm btn-outline-primary" onclick="insertCallout('info')" title="Insert Info Box"><i class="fas fa-info-circle mr-1"></i>Info</button>
                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="insertCallout('urgent')" title="Insert Urgent Box"><i class="fas fa-exclamation-triangle mr-1"></i>Urgent</button>
                        <button type="button" class="btn btn-sm btn-outline-success" onclick="insertCallout('success')" title="Insert Note Box"><i class="fas fa-check-circle mr-1"></i>Note</button>
                    </div>

                    <!-- Editable Content Div -->
                    <div id="richEditor" contenteditable="true" class="form-control p-3 mb-3" style="min-height: 160px; max-height: 380px; overflow-y: auto; border-radius: 0 0 8px 8px; border-color: #cbd5e1; background: #ffffff; font-size: 0.95rem; line-height: 1.6;" placeholder="Type your official announcement here..."></div>
                    <asp:HiddenField ID="hfNoticeTextContent" runat="server" />

                    <div class="text-right">
                        <asp:Button ID="btnPublishTextNotice" runat="server" Text="Publish Announcement" OnClientClick="return syncEditorContent();" OnClick="btnPublishTextNotice_Click" CssClass="btn btn-success font-weight-bold" style="border-radius: 8px; padding: 10px 24px; font-size: 0.92rem; background: linear-gradient(135deg, #10b981, #059669); border: none; box-shadow: 0 4px 12px rgba(16,185,129,0.25);" />
                    </div>
                </div>

                <!-- Mode 2: Upload File Attachment -->
                <div id="panelUploadNotice" style="display: none;">
                    <div class="row mb-3">
                        <div class="col-md-5 mb-3 mb-md-0">
                            <label class="small font-weight-bold text-muted d-block mb-1">Notice Subject / Title <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtFileNoticeTitle" runat="server" CssClass="form-control font-weight-bold" placeholder="e.g. Q3 Safety &amp; Compliance Policy Guidelines..." style="border-radius: 8px; border-color: #cbd5e1; height: 42px; font-size: 0.95rem;" />
                        </div>
                        <div class="col-md-3 mb-3 mb-md-0">
                            <label class="small font-weight-bold text-muted d-block mb-1">Target Main Category <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlFileNoticeMainCategory" runat="server" CssClass="form-select form-control font-weight-bold" style="border-radius: 8px; border-color: #cbd5e1; height: 42px; font-size: 0.9rem;">
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label class="small font-weight-bold text-muted d-block mb-1">Category / Priority</label>
                            <asp:DropDownList ID="ddlFileNoticeCategory" runat="server" CssClass="form-select form-control font-weight-bold" style="border-radius: 8px; border-color: #cbd5e1; height: 42px; font-size: 0.9rem;">
                                <asp:ListItem Text="General Document" Value="Document" Selected="True"></asp:ListItem>
                                <asp:ListItem Text="Urgent Document" Value="Urgent Notice"></asp:ListItem>
                                <asp:ListItem Text="Holiday &amp; Schedule" Value="Holiday &amp; Schedule"></asp:ListItem>
                                <asp:ListItem Text="Policy Update" Value="Policy Update"></asp:ListItem>
                                <asp:ListItem Text="Important Instruction" Value="Important Instruction"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="row align-items-center">
                        <div class="col-md-9 mb-3 mb-md-0">
                            <label class="small font-weight-bold text-muted d-block mb-2">Select File (PDF, DOCX, Images)</label>
                            <div class="d-flex align-items-center flex-wrap" style="gap: 10px;">
                                <label for="<%= fuNotice.ClientID %>" class="btn btn-outline-secondary mb-0 animate-hover" style="border-radius: 8px; padding: 10px 20px; font-weight: 700; font-size: 0.88rem; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; border: 1.5px solid #cbd5e1; background: #f8fafc;">
                                    <i class="fas fa-folder-open text-primary" style="font-size: 1.05rem;"></i> Choose File...
                                </label>
                                <asp:FileUpload ID="fuNotice" runat="server" accept=".pdf,.docx,.png,.jpg,.jpeg,.gif" style="display: none;" onchange="updateFileNameLabel(this);" />
                                <span id="lblSelectedFileName" class="text-muted small" style="font-weight: 600; font-size: 0.9rem; margin-left: 12px;">No file chosen</span>
                            </div>
                        </div>
                        <div class="col-md-3 text-right mt-3 mt-md-0">
                            <asp:Button ID="btnUploadNotice" runat="server" Text="Upload File Notice" OnClientClick="return validateFileUpload();" CssClass="btn btn-primary font-weight-bold w-100" style="border-radius: 8px; padding: 10px 20px; font-size: 0.9rem; height: 42px;" OnClick="btnUploadNotice_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:PlaceHolder>

    <!-- Notices Cards List -->
    <div class="row">
        <asp:Repeater ID="rptNotices" runat="server" OnItemCommand="rptNotices_ItemCommand">
            <ItemTemplate>
                <div class="col-12 col-md-6 col-lg-4 mb-4">
                    <div class="card shadow-sm border-0 notice-card" style='<%# GetNoticeCardStyle(Eval("FilePath"), Eval("IsHidden"), Eval("Category"), Eval("NoticeText")) %>'>
                        <div class="card-body p-4 d-flex flex-column justify-content-between" style="min-height: 180px;">
                            <div>
                                <div class="d-flex align-items-center justify-content-between mb-2 flex-wrap" style="gap:4px;">
                                    <div class="d-flex align-items-center flex-wrap" style="gap:4px;">
                                        <span class='badge' style='<%# GetNoticeBadgeStyle(Eval("FilePath"), Eval("Category"), Eval("NoticeText")) %>'>
                                            <i class='<%# GetNoticeIconClass(Eval("FilePath"), Eval("NoticeText")) %> mr-1'></i>
                                            <%# IsTextNotice(Eval("FilePath"), Eval("NoticeText")) ? GetNoticeCategory(Eval("Category"), Eval("FilePath"), Eval("NoticeText")) : System.IO.Path.GetExtension(Eval("FilePath").ToString()).ToUpper().Replace(".", "") %>
                                        </span>
                                        <%# GetMainCategoryBadge(Eval("MainCategoryName")) %>
                                    </div>
                                    <span class="small text-muted" style="font-size: 0.75rem;"><%# Convert.ToDateTime(Eval("UploadDate")).ToString("dd-MMM-yyyy") %></span>
                                </div>
                                
                                <h6 class="font-weight-bold text-dark notice-title mb-2" style="font-size: 0.98rem; line-height: 1.4;"><%# Eval("Name") %></h6>
                                
                                <%# IsTextNotice(Eval("FilePath"), Eval("NoticeText")) ? "<p class='text-muted small mb-3' style='font-size: 0.84rem; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;'>" + HttpUtility.HtmlEncode(GetNoticeSnippet(Eval("NoticeText"))) + "</p>" : "" %>

                                <div class="notice-meta mb-3">
                                    <%# Convert.ToInt32(Eval("IsHidden")) == 1 ? "<span class='badge badge-warning' style='font-size:0.7rem; font-weight:600;'><i class='fas fa-eye-slash mr-1'></i>Hidden</span>" : "" %>
                                </div>
                            </div>
                            
                            <div class="d-flex align-items-center justify-content-between pt-3 border-top" style="border-top-color: #f1f5f9 !important;">
                                <%-- View / Read Link --%>
                                <%# IsTextNotice(Eval("FilePath"), Eval("NoticeText")) ? 
                                    "<button type='button' class='btn btn-sm btn-primary font-weight-bold' style='border-radius: 6px; padding: 5px 14px; font-size: 0.82rem; background: #3b82f6; border: none;' data-title='" + HttpUtility.HtmlEncode(Eval("Name").ToString()) + "' data-date='" + Convert.ToDateTime(Eval("UploadDate")).ToString("dd-MMM-yyyy") + "' data-category='" + HttpUtility.HtmlEncode(GetNoticeCategory(Eval("Category"), Eval("FilePath"), Eval("NoticeText"))) + "' data-content='" + HttpUtility.HtmlEncode(Eval("NoticeText") != null ? Eval("NoticeText").ToString() : "") + "' onclick='openNoticeReader(this); return false;'><i class='fas fa-book-open mr-1'></i>Read Notice</button>" : 
                                    "<a href='" + ResolveUrl(Eval("FilePath").ToString()) + "' target='_blank' class='btn btn-sm btn-outline-primary font-weight-bold' style='border-radius: 6px; padding: 5px 12px; font-size: 0.8rem; border-color: #4f46e5; color: #4f46e5;'><i class='fas fa-external-link-alt mr-1'></i>View File</a>" 
                                %>

                                <%-- Admin Action Controls --%>
                                <asp:PlaceHolder ID="phAdminActions" runat="server" Visible='<%# Convert.ToInt32(Session["Role"] ?? 0) == 1 || Convert.ToInt32(Session["Role"] ?? 0) == 4 %>'>
                                    <div class="btn-group shadow-sm" style="border-radius: 6px; overflow: hidden;">
                                        <button type="button" class="btn btn-sm btn-light text-primary" style="background:#f8fafc; border: 1px solid #e2e8f0; font-size:0.8rem;" title="Edit / Rename" data-id='<%# Eval("Id") %>' data-name='<%# Eval("Name") != null ? HttpUtility.HtmlEncode(Eval("Name").ToString()) : "" %>' data-category='<%# Eval("Category") != null ? HttpUtility.HtmlEncode(Eval("Category").ToString()) : "" %>' data-text='<%# Eval("NoticeText") != null ? HttpUtility.HtmlEncode(Eval("NoticeText").ToString()) : "" %>' data-istext='<%# IsTextNotice(Eval("FilePath"), Eval("NoticeText")) ? "1" : "0" %>' onclick="editNotice(this); return false;">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <asp:LinkButton ID="btnToggleHide" runat="server" CommandName="ToggleHide" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-sm btn-light text-warning" style="background:#f8fafc; border: 1px solid #e2e8f0; font-size:0.8rem;" ToolTip='<%# Convert.ToInt32(Eval("IsHidden")) == 1 ? "Unhide Notice" : "Hide Notice" %>'>
                                            <i class='<%# Convert.ToInt32(Eval("IsHidden")) == 1 ? "fas fa-eye" : "fas fa-eye-slash" %>'></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDeleteNotice" runat="server" CommandName="DeleteNotice" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-sm btn-light text-danger" style="background:#f8fafc; border: 1px solid #e2e8f0; font-size:0.8rem;" OnClientClick="return confirm('Are you sure you want to delete this notice?');" ToolTip="Delete Notice">
                                            <i class="fas fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </asp:PlaceHolder>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
            
        <asp:PlaceHolder ID="phNoNotices" runat="server" Visible="false">
            <div class="col-12 text-center py-5">
                <i class="fas fa-bullhorn fa-3x text-muted mb-3" style="opacity: 0.4;"></i>
                <h6 class="text-muted font-weight-bold">No announcements or notices posted yet.</h6>
            </div>
        </asp:PlaceHolder>
    </div>

    <!-- NOTICE READER MODAL FOR POC & ALL USERS -->
    <div class="modal fade" id="noticeReaderModal" tabindex="-1" role="dialog" aria-labelledby="noticeReaderModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                <div class="modal-header bg-gradient-primary text-white p-4" style="background: linear-gradient(135deg, #1e293b, #0f172a);">
                    <div>
                        <span id="modalNoticeCategory" class="badge badge-light font-weight-bold mb-2" style="font-size: 0.78rem; color: #0f172a; padding: 4px 10px;"></span>
                        <h5 class="modal-title font-weight-bold mb-0 text-white" id="modalNoticeTitle" style="font-size: 1.25rem;"></h5>
                        <span id="modalNoticeDate" class="small text-white-50 d-block mt-1" style="font-size: 0.8rem;"></span>
                    </div>
                    <button type="button" class="close text-white opacity-75" data-bs-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body p-4" id="modalNoticeBody" style="min-height: 200px; max-height: 60vh; overflow-y: auto; font-size: 1rem; line-height: 1.7; color: #1e293b;">
                </div>
                <div class="modal-footer bg-light p-3 justify-content-between">
                    <button type="button" class="btn btn-outline-secondary font-weight-bold" onclick="printModalNotice();">
                        <i class="fas fa-print mr-1"></i> Print Notice
                    </button>
                    <button type="button" class="btn btn-secondary font-weight-bold" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT TEXT NOTICE MODAL FOR ADMIN -->
    <div class="modal fade" id="editNoticeModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
                <div class="modal-header bg-primary text-white p-3">
                    <h5 class="modal-title font-weight-bold text-white mb-0"><i class="fas fa-edit mr-2"></i> Edit Announcement</h5>
                    <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body p-4">
                    <input type="hidden" id="editNoticeId" />
                    <div class="row mb-3">
                        <div class="col-md-8 mb-3 mb-md-0">
                            <label class="small font-weight-bold text-muted d-block mb-1">Notice Title</label>
                            <input type="text" id="editNoticeTitleInput" class="form-control font-weight-bold" style="border-radius: 8px; height: 42px;" />
                        </div>
                        <div class="col-md-4">
                            <label class="small font-weight-bold text-muted d-block mb-1">Category</label>
                            <select id="editNoticeCategorySelect" class="form-select form-control font-weight-bold" style="border-radius: 8px; height: 42px;">
                                <option value="General Announcement">General Announcement</option>
                                <option value="Urgent Notice">Urgent Notice</option>
                                <option value="Holiday &amp; Schedule">Holiday &amp; Schedule</option>
                                <option value="Policy Update">Policy Update</option>
                                <option value="Important Instruction">Important Instruction</option>
                            </select>
                        </div>
                    </div>
                    <label class="small font-weight-bold text-muted d-block mb-1">Notice Content</label>
                    <div class="editor-toolbar d-flex align-items-center flex-wrap p-2 mb-2" style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px 8px 0 0; gap: 4px;">
                        <button type="button" class="btn btn-sm btn-light border font-weight-bold" onclick="execFormatEdit('bold')"><b>B</b></button>
                        <button type="button" class="btn btn-sm btn-light border font-italic" onclick="execFormatEdit('italic')"><i>I</i></button>
                        <button type="button" class="btn btn-sm btn-light border" onclick="execFormatEdit('underline')"><u>U</u></button>
                        <button type="button" class="btn btn-sm btn-light border" onclick="execFormatEdit('insertUnorderedList')"><i class="fas fa-list-ul"></i></button>
                    </div>
                    <div id="editRichEditor" contenteditable="true" class="form-control p-3 mb-3" style="min-height: 160px; max-height: 350px; overflow-y: auto; border-radius: 0 0 8px 8px; background: #fff; font-size: 0.95rem; line-height: 1.6;"></div>
                </div>
                <div class="modal-footer bg-light p-3">
                    <button type="button" class="btn btn-secondary font-weight-bold" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary font-weight-bold" onclick="saveEditedNotice();">Save Changes</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden controls for Postback -->
    <asp:HiddenField ID="hfRenameData" runat="server" />
    <asp:Button ID="btnRenameSubmit" runat="server" OnClick="btnRenameSubmit_Click" style="display:none;" />
    
    <asp:HiddenField ID="hfEditNoticeData" runat="server" />
    <asp:Button ID="btnEditNoticeSubmit" runat="server" OnClick="btnEditNoticeSubmit_Click" style="display:none;" />

    <script>
        function switchNoticeMode(mode) {
            var panelWrite = document.getElementById("panelWriteNotice");
            var panelUpload = document.getElementById("panelUploadNotice");
            var btnWrite = document.getElementById("btnTabWrite");
            var btnUpload = document.getElementById("btnTabUpload");

            if (mode === "write") {
                panelWrite.style.display = "block";
                panelUpload.style.display = "none";
                btnWrite.className = "btn btn-sm btn-success font-weight-bold active";
                btnUpload.className = "btn btn-sm btn-outline-secondary font-weight-bold";
            } else {
                panelWrite.style.display = "none";
                panelUpload.style.display = "block";
                btnWrite.className = "btn btn-sm btn-outline-secondary font-weight-bold";
                btnUpload.className = "btn btn-sm btn-success font-weight-bold active";
            }
        }

        function updateFileNameLabel(input) {
            var lbl = document.getElementById("lblSelectedFileName");
            if (input.files && input.files.length > 0) {
                lbl.textContent = input.files[0].name;
                lbl.className = "text-success small font-weight-bold";
                lbl.style.marginLeft = "12px";
            } else {
                lbl.textContent = "No file chosen";
                lbl.className = "text-muted small";
                lbl.style.marginLeft = "12px";
            }
        }

        function execFormat(cmd, arg) {
            document.execCommand(cmd, false, arg || null);
            document.getElementById("richEditor").focus();
        }

        function execFormatEdit(cmd, arg) {
            document.execCommand(cmd, false, arg || null);
            document.getElementById("editRichEditor").focus();
        }

        function insertCallout(type) {
            var editor = document.getElementById("richEditor");
            var html = "";
            if (type === 'urgent') {
                html = '<div style="background: #fef2f2; border-left: 4px solid #ef4444; padding: 12px 16px; margin: 10px 0; border-radius: 6px; color: #991b1b;"><i class="fas fa-exclamation-triangle mr-2"></i><strong>Urgent:</strong> Type urgent note here...</div><p></p>';
            } else if (type === 'success') {
                html = '<div style="background: #f0fdf4; border-left: 4px solid #10b981; padding: 12px 16px; margin: 10px 0; border-radius: 6px; color: #065f46;"><i class="fas fa-check-circle mr-2"></i><strong>Note:</strong> Type important note here...</div><p></p>';
            } else {
                html = '<div style="background: #eff6ff; border-left: 4px solid #3b82f6; padding: 12px 16px; margin: 10px 0; border-radius: 6px; color: #1e40af;"><i class="fas fa-bullhorn mr-2"></i><strong>Announcement:</strong> Type notice details here...</div><p></p>';
            }
            editor.focus();
            document.execCommand('insertHTML', false, html);
        }

        function syncEditorContent() {
            var titleInp = document.getElementById("<%= txtNoticeTitle.ClientID %>");
            var editor = document.getElementById("richEditor");
            var hf = document.getElementById("<%= hfNoticeTextContent.ClientID %>");

            var title = titleInp ? titleInp.value.trim() : "";
            var contentText = editor ? editor.innerText.trim() : "";
            var contentHtml = editor ? editor.innerHTML : "";

            if (!title) {
                showToast("Please enter a title", "warning");
                if (titleInp) titleInp.focus();
                return false; // PREVENT POSTBACK so written text is preserved!
            }

            if (!contentText && !contentHtml.includes("<img")) {
                showToast("Please enter notice content", "warning");
                if (editor) editor.focus();
                return false; // PREVENT POSTBACK!
            }

            hf.value = encodeURIComponent(contentHtml);
            return true;
        }

        function validateFileUpload() {
            var titleInp = document.getElementById("<%= txtFileNoticeTitle.ClientID %>");
            var fu = document.getElementById("<%= fuNotice.ClientID %>");

            var title = titleInp ? titleInp.value.trim() : "";
            if (!title) {
                showToast("Please enter a title", "warning");
                if (titleInp) titleInp.focus();
                return false;
            }

            if (!fu || !fu.files || fu.files.length === 0) {
                showToast("Please select a file to upload", "warning");
                return false;
            }
            return true;
        }

        document.addEventListener("DOMContentLoaded", function () {
            var hf = document.getElementById("<%= hfNoticeTextContent.ClientID %>");
            var editor = document.getElementById("richEditor");
            if (hf && editor && hf.value) {
                try {
                    editor.innerHTML = decodeURIComponent(hf.value);
                } catch (e) {
                    editor.innerHTML = hf.value;
                }
            }
        });

        function openNoticeReader(btn) {
            var title = btn.getAttribute("data-title") || "";
            var date = btn.getAttribute("data-date") || "";
            var category = btn.getAttribute("data-category") || "Announcement";
            var content = btn.getAttribute("data-content") || "";

            document.getElementById("modalNoticeTitle").innerText = title;
            document.getElementById("modalNoticeDate").innerText = "Posted on " + date;
            document.getElementById("modalNoticeCategory").innerText = category;
            document.getElementById("modalNoticeBody").innerHTML = content;

            var modal = new bootstrap.Modal(document.getElementById('noticeReaderModal'));
            modal.show();
        }

        function printModalNotice() {
            var title = document.getElementById("modalNoticeTitle").innerText;
            var date = document.getElementById("modalNoticeDate").innerText;
            var category = document.getElementById("modalNoticeCategory").innerText;
            var content = document.getElementById("modalNoticeBody").innerHTML;

            var printWin = window.open('', '_blank');
            printWin.document.write('<html><head><title>' + title + '</title>');
            printWin.document.write('<style>body{font-family:Arial,sans-serif;padding:30px;color:#1e293b;} h2{color:#0f172a;} .meta{color:#64748b;font-size:14px;margin-bottom:20px;border-bottom:1px solid #ccc;padding-bottom:10px;}</style>');
            printWin.document.write('</head><body>');
            printWin.document.write('<h2>' + title + '</h2>');
            printWin.document.write('<div class="meta"><strong>Category:</strong> ' + category + ' | <strong>Date:</strong> ' + date + '</div>');
            printWin.document.write('<div>' + content + '</div>');
            printWin.document.write('</body></html>');
            printWin.document.close();
            printWin.print();
        }

        function editNotice(btn) {
            var id = btn.getAttribute("data-id");
            var name = btn.getAttribute("data-name") || "";
            var category = btn.getAttribute("data-category") || "General Announcement";
            var text = btn.getAttribute("data-text") || "";
            var isText = btn.getAttribute("data-istext");

            if (isText === "1") {
                document.getElementById("editNoticeId").value = id;
                document.getElementById("editNoticeTitleInput").value = name;
                document.getElementById("editNoticeCategorySelect").value = category;
                document.getElementById("editRichEditor").innerHTML = text;

                var editModal = new bootstrap.Modal(document.getElementById('editNoticeModal'));
                editModal.show();
            } else {
                renameNotice(btn);
            }
        }

        function saveEditedNotice() {
            var id = document.getElementById("editNoticeId").value;
            var title = document.getElementById("editNoticeTitleInput").value;
            var category = document.getElementById("editNoticeCategorySelect").value;
            var content = encodeURIComponent(document.getElementById("editRichEditor").innerHTML);

            if (!title || title.trim() === '') {
                alert("Please enter a notice title.");
                return;
            }

            document.getElementById("<%= hfEditNoticeData.ClientID %>").value = id + '~|~' + title + '~|~' + category + '~|~' + content;
            document.getElementById("<%= btnEditNoticeSubmit.ClientID %>").click();
        }

        function renameNotice(btn) {
            var id = btn.getAttribute("data-id");
            var currentName = btn.getAttribute("data-name") || "";
            if (typeof Swal === 'undefined') {
                var newName = prompt("Rename Notice:", currentName);
                if (newName && newName.trim() !== "") {
                    triggerRename(id, newName.trim());
                }
                return;
            }

            Swal.fire({
                title: 'Rename File Notice',
                input: 'text',
                inputValue: currentName,
                inputPlaceholder: 'Enter new display name...',
                showCancelButton: true,
                confirmButtonText: 'Save',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#10b981',
                cancelButtonColor: '#64748b',
                inputValidator: (value) => {
                    if (!value || value.trim() === '') {
                        return 'You need to write a name!';
                    }
                }
            }).then((result) => {
                if (result.isConfirmed && result.value) {
                    triggerRename(id, result.value.trim());
                }
            });
        }

        function triggerRename(id, newName) {
            document.getElementById("<%= hfRenameData.ClientID %>").value = id + '|' + newName;
            document.getElementById("<%= btnRenameSubmit.ClientID %>").click();
        }
    </script>
</asp:Content>
