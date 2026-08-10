namespace AttendanceApp {
    public partial class AdminManagement {
        protected global::System.Web.UI.WebControls.Label lblAdminMessage;
        protected global::System.Web.UI.WebControls.TextBox txtAdminPCNO;
        protected global::System.Web.UI.WebControls.TextBox txtAdminName;
        protected global::System.Web.UI.WebControls.Button btnAddAdmin;
        protected global::System.Web.UI.WebControls.Label lblGridMessage;
        protected global::System.Web.UI.WebControls.GridView gvAdminUsers;
        protected global::System.Web.UI.WebControls.HiddenField hfActiveTab;
        
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl liTabNonAdmins;
        protected global::System.Web.UI.WebControls.LinkButton btnTabNonAdmins;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl liTabAdmins;
        protected global::System.Web.UI.WebControls.LinkButton btnTabAdmins;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl liTabSuperAdmins;
        protected global::System.Web.UI.WebControls.LinkButton btnTabSuperAdmins;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl liTabShareGrants;
        protected global::System.Web.UI.WebControls.LinkButton btnTabShareGrants;

        protected global::System.Web.UI.WebControls.GridView gvShareGrants;
        
        protected global::System.Web.UI.WebControls.TextBox txtUserPCNO;
        protected global::System.Web.UI.WebControls.TextBox txtUserName;
        protected global::System.Web.UI.WebControls.CheckBoxList cblUserDivisions;
        protected global::System.Web.UI.WebControls.CheckBoxList cblUserTiers;
        protected global::System.Web.UI.WebControls.Button btnCancelUserEdit;
        protected global::System.Web.UI.WebControls.Button btnAddUser;
        protected global::System.Web.UI.WebControls.PlaceHolder phAdminForm;
        protected global::System.Web.UI.WebControls.PlaceHolder phEditAdminCategoriesForm;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl editAdminHeader;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl editAdminTitle;
        protected global::System.Web.UI.WebControls.TextBox txtEditAdminPCNO;
        protected global::System.Web.UI.WebControls.TextBox txtEditAdminName;
        protected global::System.Web.UI.WebControls.DropDownList ddlEditAdminCategory;
        protected global::System.Web.UI.WebControls.Button btnCancelAdminEdit;
        protected global::System.Web.UI.WebControls.Button btnSaveAdminCategories;
        protected global::System.Web.UI.WebControls.PlaceHolder phUserForm;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl userFormHeader;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl userFormTitle;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl adminFormTitle;

        protected global::System.Web.UI.WebControls.PlaceHolder phShareForm;
        protected global::System.Web.UI.WebControls.HiddenField hfSelectedTierIds;
        protected global::System.Web.UI.WebControls.HiddenField hfShareFullCategory;
        protected global::System.Web.UI.WebControls.DropDownList ddlShareCategory;
        protected global::System.Web.UI.WebControls.CheckBoxList cblShareTiers;
        protected global::System.Web.UI.WebControls.DropDownList ddlShareGuestAdmin;
        protected global::System.Web.UI.WebControls.TextBox txtShareGuestPCNO;
        protected global::System.Web.UI.WebControls.TextBox txtShareGuestName;
        protected global::System.Web.UI.WebControls.HiddenField hfEditShareId;
        protected global::System.Web.UI.WebControls.Button btnCancelShareEdit;
        protected global::System.Web.UI.WebControls.Button btnCreateShare;
    }
}
