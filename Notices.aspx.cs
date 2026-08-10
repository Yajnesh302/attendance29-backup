using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    public partial class Notices : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                phAdminNoticeUpload.Visible = false; // Hide upload container for regular users
            }
            else
            {
                phAdminNoticeUpload.Visible = true;
            }

            if (!IsPostBack)
            {
                PopulateMainCategoryDropdowns();
                LoadNotices();
            }
        }

        private void PopulateMainCategoryDropdowns()
        {
            try
            {
                ddlNoticeMainCategory.Items.Clear();
                ddlFileNoticeMainCategory.Items.Clear();

                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";

                if (role == 4) // Super Admin: can select All or any specific MainCategory
                {
                    ddlNoticeMainCategory.Items.Add(new ListItem("-- All Main Categories --", ""));
                    ddlFileNoticeMainCategory.Items.Add(new ListItem("-- All Main Categories --", ""));

                    string q = "SELECT Id, Name FROM MainCategory ORDER BY Name ASC";
                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), q);
                    foreach (DataRow dr in dt.Rows)
                    {
                        string id = dr["Id"].ToString();
                        string name = dr["Name"].ToString();
                        ddlNoticeMainCategory.Items.Add(new ListItem(name, id));
                        ddlFileNoticeMainCategory.Items.Add(new ListItem(name, id));
                    }
                }
                else if (role == 1) // Admin: scoped by RoleMode
                {
                    string roleMode = Session["RoleMode"]?.ToString() ?? "";
                    string q = "";
                    if (roleMode == "PrimaryAdmin")
                    {
                        q = @"
                            SELECT DISTINCT mc.Id, mc.Name 
                            FROM MainCategory mc 
                            WHERE mc.AdminPCNO = :PCNO 
                            ORDER BY mc.Name ASC";
                    }
                    else if (roleMode == "SecondaryAdmin")
                    {
                        q = @"
                            SELECT DISTINCT mc.Id, mc.Name 
                            FROM MainCategory mc 
                            WHERE mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                            ORDER BY mc.Name ASC";
                    }
                    else
                    {
                        q = @"
                            SELECT DISTINCT mc.Id, mc.Name 
                            FROM MainCategory mc 
                            WHERE mc.AdminPCNO = :PCNO 
                               OR mc.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                            ORDER BY mc.Name ASC";
                    }

                    DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), q, new OracleParameter("PCNO", pcno));
                    foreach (DataRow dr in dt.Rows)
                    {
                        string id = dr["Id"].ToString();
                        string name = dr["Name"].ToString();
                        ddlNoticeMainCategory.Items.Add(new ListItem(name, id));
                        ddlFileNoticeMainCategory.Items.Add(new ListItem(name, id));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating main categories: " + ex.Message);
            }
        }

        private void ShowToast(string message, string type)
        {
            string cleanMessage = message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void LoadNotices()
        {
            try
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                string pcno = Session["PCNO"]?.ToString() ?? "";
                string query;
                DataTable dt;

                if (role == 4) // Super Admin sees all notices with MainCategoryName
                {
                    query = @"
                        SELECT n.Id, n.Name, n.FilePath, n.NoticeText, n.Category, n.IsHidden, n.UploadDate, n.MainCategoryId, mc.Name AS MainCategoryName
                        FROM Notices n
                        LEFT JOIN MainCategory mc ON n.MainCategoryId = mc.Id
                        ORDER BY n.UploadDate DESC";
                    dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                }
                else if (role == 1) // Admin sees global notices + notices for owned/shared MainCategories
                {
                    query = @"
                        SELECT n.Id, n.Name, n.FilePath, n.NoticeText, n.Category, n.IsHidden, n.UploadDate, n.MainCategoryId, mc.Name AS MainCategoryName
                        FROM Notices n
                        LEFT JOIN MainCategory mc ON n.MainCategoryId = mc.Id
                        WHERE n.MainCategoryId IS NULL
                           OR n.MainCategoryId IN (
                               SELECT mc2.Id FROM MainCategory mc2 
                               WHERE mc2.AdminPCNO = :PCNO 
                                  OR mc2.Id IN (SELECT sg.MainCategoryId FROM CategoryShareGrant sg WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1)
                           )
                        ORDER BY n.UploadDate DESC";
                    dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                }
                else // Regular user / POC sees visible notices for assigned MainCategories
                {
                    query = @"
                        SELECT n.Id, n.Name, n.FilePath, n.NoticeText, n.Category, n.IsHidden, n.UploadDate, n.MainCategoryId, mc.Name AS MainCategoryName
                        FROM Notices n
                        LEFT JOIN MainCategory mc ON n.MainCategoryId = mc.Id
                        WHERE n.IsHidden = 0
                          AND (
                              n.MainCategoryId IS NULL
                              OR n.MainCategoryId IN (
                                  SELECT t.MainCategoryId 
                                  FROM Tiers t 
                                  JOIN UserTiers ut ON t.Id = ut.TierId 
                                  WHERE ut.PCNO = :PCNO
                              )
                          )
                        ORDER BY n.UploadDate DESC";
                    dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new OracleParameter("PCNO", pcno));
                }

                if (dt != null && dt.Rows.Count > 0)
                {
                    rptNotices.DataSource = dt;
                    rptNotices.DataBind();
                    rptNotices.Visible = true;
                    phNoNotices.Visible = false;

                    MarkNoticesAsReadForUser(pcno, dt);
                }
                else
                {
                    rptNotices.Visible = false;
                    phNoNotices.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowToast("Error loading notices: " + ex.Message, "error");
            }
        }

        private void MarkNoticesAsReadForUser(string pcno, DataTable dt)
        {
            if (string.IsNullOrEmpty(pcno) || dt == null || dt.Rows.Count == 0) return;

            try
            {
                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    foreach (DataRow row in dt.Rows)
                    {
                        int noticeId = Convert.ToInt32(row["Id"]);
                        string mergeSql = @"
                            MERGE INTO NoticeReads nr
                            USING (SELECT :NoticeId AS NoticeId, :PCNO AS PCNO FROM DUAL) src
                            ON (nr.NoticeId = src.NoticeId AND nr.PCNO = src.PCNO)
                            WHEN NOT MATCHED THEN
                              INSERT (NoticeId, PCNO, ReadAt) VALUES (src.NoticeId, src.PCNO, SYSTIMESTAMP)";
                        using (OracleCommand cmd = new OracleCommand(mergeSql, conn))
                        {
                            cmd.Parameters.Add(new OracleParameter("NoticeId", noticeId));
                            cmd.Parameters.Add(new OracleParameter("PCNO", pcno));
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error marking notices as read: " + ex.Message);
            }
        }

        protected string GetMainCategoryBadge(object mainCategoryNameObj)
        {
            if (mainCategoryNameObj != null && mainCategoryNameObj != DBNull.Value && !string.IsNullOrWhiteSpace(mainCategoryNameObj.ToString()))
            {
                return string.Format("<span class='badge badge-info' style='font-size:0.72rem; font-weight:600; background:#3b82f6; color:#fff;'><i class='fas fa-layer-group mr-1'></i>{0}</span>", HttpUtility.HtmlEncode(mainCategoryNameObj.ToString()));
            }
            return "<span class='badge badge-secondary' style='font-size:0.72rem; font-weight:600;'><i class='fas fa-globe mr-1'></i>All Categories</span>";
        }

        protected bool IsTextNotice(object filePathObj, object textObj)
        {
            string text = textObj != null && textObj != DBNull.Value ? textObj.ToString() : "";
            if (!string.IsNullOrWhiteSpace(text)) return true;
            string path = filePathObj != null && filePathObj != DBNull.Value ? filePathObj.ToString() : "";
            return string.IsNullOrWhiteSpace(path);
        }

        protected string GetNoticeCategory(object categoryObj, object filePathObj, object textObj)
        {
            string cat = categoryObj != null && categoryObj != DBNull.Value ? categoryObj.ToString() : "";
            if (!string.IsNullOrWhiteSpace(cat)) return cat;
            if (IsTextNotice(filePathObj, textObj)) return "Announcement";
            return "Document";
        }

        protected string GetNoticeSnippet(object textObj)
        {
            if (textObj == null || textObj == DBNull.Value) return "";
            string rawHtml = textObj.ToString();
            string plainText = System.Text.RegularExpressions.Regex.Replace(rawHtml, "<.*?>", " ").Trim();
            if (plainText.Length > 120) return plainText.Substring(0, 120) + "...";
            return plainText;
        }

        protected string GetNoticeBorderColor(object filePathObj, object categoryObj, object textObj)
        {
            if (IsTextNotice(filePathObj, textObj))
            {
                string cat = GetNoticeCategory(categoryObj, filePathObj, textObj).ToLower();
                if (cat.Contains("urgent")) return "#ef4444";
                if (cat.Contains("holiday") || cat.Contains("schedule")) return "#f59e0b";
                if (cat.Contains("policy")) return "#8b5cf6";
                return "#3b82f6"; // Announcement default blue
            }

            string filePath = filePathObj != null ? filePathObj.ToString() : "";
            string ext = Path.GetExtension(filePath).ToLower();
            switch (ext)
            {
                case ".pdf": return "#ef4444";
                case ".docx": return "#2563eb";
                case ".png":
                case ".jpg":
                case ".jpeg":
                case ".gif": return "#10b981";
                default: return "#64748b";
            }
        }

        protected string GetNoticeBadgeBg(object filePathObj, object categoryObj, object textObj)
        {
            if (IsTextNotice(filePathObj, textObj))
            {
                string cat = GetNoticeCategory(categoryObj, filePathObj, textObj).ToLower();
                if (cat.Contains("urgent")) return "#fee2e2";
                if (cat.Contains("holiday") || cat.Contains("schedule")) return "#fef3c7";
                if (cat.Contains("policy")) return "#f3e8ff";
                return "#dbeafe";
            }

            string filePath = filePathObj != null ? filePathObj.ToString() : "";
            string ext = Path.GetExtension(filePath).ToLower();
            switch (ext)
            {
                case ".pdf": return "#fee2e2";
                case ".docx": return "#dbeafe";
                case ".png":
                case ".jpg":
                case ".jpeg":
                case ".gif": return "#d1fae5";
                default: return "#f1f5f9";
            }
        }

        protected string GetNoticeIconClass(object filePathObj, object textObj)
        {
            if (IsTextNotice(filePathObj, textObj)) return "fas fa-bullhorn";

            string filePath = filePathObj != null ? filePathObj.ToString() : "";
            string ext = Path.GetExtension(filePath).ToLower();
            switch (ext)
            {
                case ".pdf": return "fas fa-file-pdf";
                case ".docx": return "fas fa-file-word";
                case ".png":
                case ".jpg":
                case ".jpeg":
                case ".gif": return "fas fa-file-image";
                default: return "fas fa-file-alt";
            }
        }

        protected string GetNoticeCardStyle(object filePathObj, object isHiddenObj, object categoryObj, object textObj)
        {
            int isHidden = isHiddenObj != null ? Convert.ToInt32(isHiddenObj) : 0;
            string borderColor = GetNoticeBorderColor(filePathObj, categoryObj, textObj);
            string style = "border-radius: 14px; border: 1px solid #e2e8f0; border-left: 5px solid " + borderColor + " !important; background: white; transition: all 0.2s; position: relative;";
            if (isHidden == 1)
            {
                style += " opacity: 0.72; background-color: #f8fafc;";
            }
            return style;
        }

        protected string GetNoticeBadgeStyle(object filePathObj, object categoryObj, object textObj)
        {
            return "font-size: 0.72rem; padding: 4px 8px; border-radius: 6px; font-weight: 700; background: " + GetNoticeBadgeBg(filePathObj, categoryObj, textObj) + "; color: " + GetNoticeBorderColor(filePathObj, categoryObj, textObj) + ";";
        }

        protected void btnPublishTextNotice_Click(object sender, EventArgs e)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                ShowToast("Unauthorized access.", "error");
                return;
            }

            string title = txtNoticeTitle.Text != null ? txtNoticeTitle.Text.Trim() : "";
            string category = ddlNoticeCategory.SelectedValue != null ? ddlNoticeCategory.SelectedValue.Trim() : "General";
            string rawHtml = hfNoticeTextContent.Value != null ? hfNoticeTextContent.Value.Trim() : "";
            string contentHtml = HttpUtility.UrlDecode(rawHtml);

            if (string.IsNullOrEmpty(title))
            {
                ShowToast("Please enter a title", "warning");
                return;
            }
            if (string.IsNullOrEmpty(contentHtml))
            {
                ShowToast("Please enter notice content", "warning");
                return;
            }

            try
            {
                object mainCatVal = DBNull.Value;
                if (!string.IsNullOrEmpty(ddlNoticeMainCategory.SelectedValue))
                {
                    mainCatVal = Convert.ToInt32(ddlNoticeMainCategory.SelectedValue);
                }

                string insertQuery = "INSERT INTO Notices (Name, FilePath, NoticeText, Category, IsHidden, MainCategoryId) VALUES (:Name, NULL, :NoticeText, :Category, 0, :MainCategoryId)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery,
                    new OracleParameter("Name", title),
                    new OracleParameter("NoticeText", contentHtml),
                    new OracleParameter("Category", category),
                    new OracleParameter("MainCategoryId", mainCatVal));

                txtNoticeTitle.Text = "";
                hfNoticeTextContent.Value = "";

                LoadNotices();
                ShowToast("Announcement published successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error publishing announcement: " + ex.Message, "error");
            }
        }

        protected void btnUploadNotice_Click(object sender, EventArgs e)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                ShowToast("Unauthorized access.", "error");
                return;
            }

            if (!fuNotice.HasFile)
            {
                ShowToast("Please select a file to upload.", "warning");
                return;
            }

            try
            {
                string ext = Path.GetExtension(fuNotice.FileName).ToLower();
                if (ext != ".pdf" && ext != ".docx" && ext != ".png" && ext != ".jpg" && ext != ".jpeg" && ext != ".gif")
                {
                    ShowToast("Unsupported file type. Only PDF, DOCX, and Images are allowed.", "error");
                    return;
                }

                // Verify file size limit (10MB)
                if (fuNotice.PostedFile.ContentLength > 10 * 1024 * 1024)
                {
                    ShowToast("File size exceeds 10MB limit.", "error");
                    return;
                }

                string customTitle = txtFileNoticeTitle.Text != null ? txtFileNoticeTitle.Text.Trim() : "";
                string category = ddlFileNoticeCategory.SelectedValue != null ? ddlFileNoticeCategory.SelectedValue.Trim() : "Document";

                string noticeName = !string.IsNullOrEmpty(customTitle) ? customTitle : Path.GetFileNameWithoutExtension(fuNotice.FileName);
                if (string.IsNullOrEmpty(noticeName))
                {
                    noticeName = "Untitled Notice";
                }

                string uploadDir = Server.MapPath("~/Static/Uploads/Notices/");
                if (!Directory.Exists(uploadDir))
                {
                    Directory.CreateDirectory(uploadDir);
                }

                string fileGuid = Guid.NewGuid().ToString("N");
                string safeFileName = fileGuid + "_" + Path.GetFileName(fuNotice.FileName);
                string serverFilePath = Path.Combine(uploadDir, safeFileName);
                
                fuNotice.SaveAs(serverFilePath);

                string dbRelativePath = "~/Static/Uploads/Notices/" + safeFileName;

                object mainCatVal = DBNull.Value;
                if (!string.IsNullOrEmpty(ddlFileNoticeMainCategory.SelectedValue))
                {
                    mainCatVal = Convert.ToInt32(ddlFileNoticeMainCategory.SelectedValue);
                }

                string insertQuery = "INSERT INTO Notices (Name, FilePath, NoticeText, Category, IsHidden, MainCategoryId) VALUES (:Name, :FilePath, NULL, :Category, 0, :MainCategoryId)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery,
                    new OracleParameter("Name", noticeName),
                    new OracleParameter("FilePath", dbRelativePath),
                    new OracleParameter("Category", category),
                    new OracleParameter("MainCategoryId", mainCatVal));

                txtFileNoticeTitle.Text = "";

                LoadNotices();
                ShowToast("Notice file uploaded successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error uploading notice: " + ex.Message, "error");
            }
        }

        protected void rptNotices_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                ShowToast("Unauthorized access.", "error");
                return;
            }

            int noticeId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteNotice")
            {
                try
                {
                    // Get filepath to delete physical file if exists
                    string selectSql = "SELECT FilePath FROM Notices WHERE Id = :Id";
                    string relativePath = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), selectSql, new OracleParameter("Id", noticeId))?.ToString();

                    if (!string.IsNullOrEmpty(relativePath))
                    {
                        try
                        {
                            string physicalPath = Server.MapPath(relativePath);
                            if (File.Exists(physicalPath))
                            {
                                File.Delete(physicalPath);
                            }
                        }
                        catch (Exception fileEx)
                        {
                            System.Diagnostics.Debug.WriteLine("Error deleting physical file: " + fileEx.Message);
                        }
                    }

                    string deleteSql = "DELETE FROM Notices WHERE Id = :Id";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteSql, new OracleParameter("Id", noticeId));

                    LoadNotices();
                    ShowToast("Notice deleted successfully.", "success");
                }
                catch (Exception ex)
                {
                    ShowToast("Error deleting notice: " + ex.Message, "error");
                }
            }
            else if (e.CommandName == "ToggleHide")
            {
                try
                {
                    string selectSql = "SELECT IsHidden FROM Notices WHERE Id = :Id";
                    int currentHidden = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), selectSql, new OracleParameter("Id", noticeId)));

                    int newHidden = currentHidden == 1 ? 0 : 1;

                    string updateSql = "UPDATE Notices SET IsHidden = :IsHidden WHERE Id = :Id";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                        new OracleParameter("IsHidden", newHidden),
                        new OracleParameter("Id", noticeId));

                    LoadNotices();
                    string statusMsg = newHidden == 1 ? "Notice is now hidden." : "Notice is now visible.";
                    ShowToast(statusMsg, "success");
                }
                catch (Exception ex)
                {
                    ShowToast("Error toggling visibility: " + ex.Message, "error");
                }
            }
        }

        private void HandleRenameNotice(string eventArgument)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                ShowToast("Unauthorized access.", "error");
                return;
            }

            if (string.IsNullOrEmpty(eventArgument) || !eventArgument.Contains("|"))
            {
                ShowToast("Invalid rename arguments.", "error");
                return;
            }

            try
            {
                string[] parts = eventArgument.Split('|');
                int noticeId = Convert.ToInt32(parts[0]);
                string newName = parts[1].Trim();

                if (string.IsNullOrEmpty(newName))
                {
                    ShowToast("Notice name cannot be empty.", "warning");
                    return;
                }

                string updateSql = "UPDATE Notices SET Name = :Name WHERE Id = :Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                    new OracleParameter("Name", newName),
                    new OracleParameter("Id", noticeId));

                LoadNotices();
                ShowToast("Notice renamed successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error renaming notice: " + ex.Message, "error");
            }
        }

        protected void btnRenameSubmit_Click(object sender, EventArgs e)
        {
            string data = hfRenameData.Value;
            HandleRenameNotice(data);
        }

        protected void btnEditNoticeSubmit_Click(object sender, EventArgs e)
        {
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1 && role != 4)
            {
                ShowToast("Unauthorized access.", "error");
                return;
            }

            try
            {
                string data = hfEditNoticeData.Value;
                if (string.IsNullOrEmpty(data) || !data.Contains("~|~"))
                {
                    ShowToast("Invalid edit data.", "warning");
                    return;
                }

                string[] parts = data.Split(new string[] { "~|~" }, StringSplitOptions.None);
                int noticeId = Convert.ToInt32(parts[0]);
                string title = parts[1].Trim();
                string category = parts[2].Trim();
                string rawContent = parts[3].Trim();
                string contentHtml = HttpUtility.UrlDecode(rawContent);

                string updateSql = "UPDATE Notices SET Name = :Name, Category = :Category, NoticeText = :NoticeText WHERE Id = :Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateSql,
                    new OracleParameter("Name", title),
                    new OracleParameter("Category", category),
                    new OracleParameter("NoticeText", contentHtml),
                    new OracleParameter("Id", noticeId));

                LoadNotices();
                ShowToast("Announcement updated successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error updating announcement: " + ex.Message, "error");
            }
        }
    }
}
