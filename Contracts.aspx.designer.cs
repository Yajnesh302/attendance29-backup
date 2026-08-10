namespace AttendanceApp {
    
    public partial class Contracts {
        
        protected global::System.Web.UI.WebControls.LinkButton btnConfigureNew;
        
        protected global::System.Web.UI.WebControls.Panel pnlWizard;
        
        protected global::System.Web.UI.WebControls.LinkButton btnCancelStep1;
        
        protected global::System.Web.UI.WebControls.LinkButton btnCancelStep2;
        
        protected global::System.Web.UI.WebControls.Label lblMessage;
        
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl stepHeader1;
        
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl stepHeader2;
        
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl stepHeader3;
        
        protected global::System.Web.UI.WebControls.MultiView mvContracts;
        
                protected global::System.Web.UI.WebControls.View viewStep1;
        
        protected global::System.Web.UI.WebControls.DropDownList ddlCategory;
        
        protected global::System.Web.UI.WebControls.TextBox txtStartDate;
        
        protected global::System.Web.UI.WebControls.TextBox txtEndDate;
        
        protected global::System.Web.UI.WebControls.DropDownList ddlVendor;
        
        protected global::System.Web.UI.WebControls.TextBox txtContractGemId;
        
        protected global::System.Web.UI.WebControls.Button btnNextStep;
        
        protected global::System.Web.UI.WebControls.View viewStep2;
        
        protected global::System.Web.UI.WebControls.Label lblSelectedStartDate;
        
        protected global::System.Web.UI.WebControls.Label lblSelectedVendor;
        
        protected global::System.Web.UI.WebControls.Label lblEnrollCategoryTitle;
        
        protected global::System.Web.UI.WebControls.Label lblEnrollVendorTitle;
        
        protected global::System.Web.UI.WebControls.DropDownList ddlFilterEnroll;
        
        protected global::System.Web.UI.WebControls.GridView gvEmployeesEnroll;
        
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl divEnrollCard;
        
        protected global::System.Web.UI.WebControls.Button btnPrevStep;
        
        protected global::System.Web.UI.WebControls.Button btnSaveContract;
        
        protected global::System.Web.UI.WebControls.TextBox txtModalMasterId;
        
        protected global::System.Web.UI.WebControls.TextBox txtModalVendorName;

        protected global::System.Web.UI.WebControls.HiddenField hfModalVendorContacts;

        
        protected global::System.Web.UI.WebControls.TextBox txtModalContactName;
        
        protected global::System.Web.UI.WebControls.TextBox txtModalContactPhone;
        
        protected global::System.Web.UI.WebControls.TextBox txtModalAddress;
        
        protected global::System.Web.UI.WebControls.Button btnModalSaveVendor;

        protected global::System.Web.UI.HtmlControls.HtmlGenericControl divContractsHistory;
        
        protected global::System.Web.UI.WebControls.DropDownList ddlFilterCategory;
        
        protected global::System.Web.UI.WebControls.DropDownList ddlFilterStatus;
        
        protected global::System.Web.UI.WebControls.TextBox txtSearchVendor;
        
        protected global::System.Web.UI.WebControls.Button btnSearchContracts;
        
        protected global::System.Web.UI.WebControls.LinkButton btnClearFilters;
        
        protected global::System.Web.UI.WebControls.Repeater rptContractPeriods;
        
        protected global::System.Web.UI.WebControls.HiddenField hfEndContractStartDate;
        
        protected global::System.Web.UI.WebControls.Label lblEndContractStartDate;
        
        protected global::System.Web.UI.WebControls.TextBox txtEndContractEndDate;
        
        protected global::System.Web.UI.WebControls.Button btnModalConfirmEnd;
        
        protected global::System.Web.UI.WebControls.Repeater rptUnselectedEmployees;
        
        protected global::System.Web.UI.WebControls.Button btnConfirmSave;

        protected global::System.Web.UI.WebControls.HiddenField hfDeleteContractStartDate;

        protected global::System.Web.UI.WebControls.Label lblDeleteContractStartDate;

        protected global::System.Web.UI.WebControls.Button btnModalConfirmDelete;

        protected global::System.Web.UI.WebControls.HiddenField hfExtendContractId;

        protected global::System.Web.UI.WebControls.Label lblExtendContractDisplay;

        protected global::System.Web.UI.WebControls.Label lblExtendContractCurrentEndDate;

        protected global::System.Web.UI.WebControls.Label lblExtendContractGemId;

        protected global::System.Web.UI.WebControls.TextBox txtExtendContractNewEndDate;

        protected global::System.Web.UI.WebControls.Button btnModalConfirmExtend;

        protected global::System.Web.UI.WebControls.View viewStep3;

        protected global::System.Web.UI.WebControls.Label lblStep3CategoryTitle;
        
        protected global::System.Web.UI.WebControls.Label lblSelectedCountEnroll;
        
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl divEnrollIdAlert;
        
        protected global::System.Web.UI.WebControls.GridView gvIdsEnroll;

        protected global::System.Web.UI.WebControls.Button btnBackToStep2;

        protected global::System.Web.UI.WebControls.Button btnFinalizeContract;

        protected global::System.Web.UI.WebControls.TextBox txtInitialLeaveBalance;



        protected global::System.Web.UI.WebControls.HiddenField hfManageContractPeriodId;
        protected global::System.Web.UI.WebControls.Label lblManageContractTitle;
        protected global::System.Web.UI.WebControls.Label lblManageContractVendor;
        protected global::System.Web.UI.WebControls.Label lblManageContractGemId;
        protected global::System.Web.UI.WebControls.Label lblManageContractStart;
        protected global::System.Web.UI.WebControls.DropDownList ddlManageAddEmployee;
        protected global::System.Web.UI.WebControls.LinkButton btnManageAddEmployee;
        protected global::System.Web.UI.WebControls.TextBox txtManageAddStartDate;
        protected global::System.Web.UI.WebControls.Button btnUpdateAllIds;
        protected global::System.Web.UI.WebControls.GridView gvManageEnrolledEmployees;

        protected global::System.Web.UI.WebControls.TextBox txtContractDatedOn;
        protected global::System.Web.UI.WebControls.HiddenField hfEditContractId;
        protected global::System.Web.UI.WebControls.TextBox txtEditContractGemId;
        protected global::System.Web.UI.WebControls.TextBox txtEditContractDatedOn;
        protected global::System.Web.UI.WebControls.Button btnSaveEditContract;
    }
}
