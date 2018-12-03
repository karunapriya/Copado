/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		08.05.2014
 * @description	CSM_AccountPlanTemplateController controller class for the Success Plan template page 
 */

public with sharing class CSM_AccountPlanTemplateController {
	
	public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public String sectionHeader {get; private set;}
	public boolean isEdit {get; private set;}
	public CSM_Account_Plan_Template__c accountPlanTemplate {get; set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	
	private String templateId {get; set;}
	private CSM_AcctPlanTemplatePhasesCompController accountPlanTemplatePhasesCompController; 
	private CSM_AcctPlanTemplatePlaybooksCompCntrl accountPlanTemplatePlaybooksCompCntrl;
	private CSM_AcctPlanTemplateIndicatorsCompCntrl accountPlanTemplateIndicatorsCompCntrl;
	private CSM_AccountPlanTemplateOpp accountPlanTemplateOpp;
	private CSM_AccountPlanTemplateOppTimeLineCtrl accountPlanTemplateOppTimeLine;
	public Boolean automateDefaultTemplate {get; set;}
	/** 
	 * @description constructor
	 */
	public CSM_AccountPlanTemplateController()
	{
		
		helpParam = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATES_EDIT;
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
        templateId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		isEdit = false;
		accountPlanTemplate = new CSM_Account_Plan_Template__c();	
		this.populatePageInformation();
		this.findScoutDefaultTemplate();
		
	}
	
	/** 
	 * @description populates the Success Plan template for provided templateId
	 */
	
	private void populatePageInformation() {
		try {
			if(templateId != null)
			{
				accountPlanTemplate = CSM_AccountPlanTemplateDataAccess.populateAccountPlanTemplateInformation(templateId);
				if(accountPlanTemplate != null)
				{
					//Sets page header
					sectionHeader = Label.CSM_LBL_EDIT_ACCT_PLAN_TEMPLATE;
					isEdit = true;
				}
				//No template found so display as blank for creation, default values;
				else
				{
					//accountPlanTemplate = new CSM_Account_Plan_Template__c();
					sectionHeader = Label.CSM_LBL_CREATE_ACCT_PLAN_TEMPLATE;
				}
			}
			//If no template id passed to page then it's a create method, default values
			else
			{
				sectionHeader = Label.CSM_LBL_CREATE_ACCT_PLAN_TEMPLATE;
				
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
	}
	
	/** 
	 * @description Peroforms create method for Success Plan template
	 */
	public PageReference templateCreate() {
		try {
			List<CSM_Account_Plan_Template__c> saveList = CSM_AccountPlanTemplateDataAccess.saveTemplate(new List<CSM_Account_Plan_Template__c>{accountPlanTemplate});
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_TEMPLATE_SAVE));
			if(!SaveList.isEmpty())
			{
				PageReference pageRef = Page.CSM_AccountPlanTemplate;
				pageRef.getParameters().put(CSM_Constants.ID_PARAM,saveList[0].id);
				pageRef.getParameters().put('tabCategory', 'SuccessPlan');
				pageRef.setRedirect(true);
				return pageRef;	
			}
			
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			
		}
		return null;
	}
	
	/** 
	 * @description saves the Success Plan template and all related components on the page
	 */
	public void templateSave() {
		try {
			accountPlanTemplate.CSM_Opp_Date__c = accountPlanTemplateOpp.selectedField;
			//accountPlanTemplate.CSM_Opp_Dates_TimeLines__c =  accountPlanTemplateOppTimeLine.getSemiColonSeparatedFields();
			accountPlanTemplate.CSM_Currency_Code__c = accountPlanTemplateIndicatorsCompCntrl.corpCurrCode;

			boolean phaseSaveSuccess = accountPlanTemplatePhasesCompController.savePhase();
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				List<CSM_Account_Plan_Template__c> saveList = CSM_AccountPlanTemplateDataAccess.saveTemplate(new List<CSM_Account_Plan_Template__c>{accountPlanTemplate});
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_TEMPLATE_SAVE));
				if(phaseSaveSuccess){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_PHASE_UPDATE));				
				}
				if(!SaveList.isEmpty())
				{
					accountPlanTemplate = saveList[0];
				}
				//Save playbook changes
				boolean playbookSaveSuccess = accountPlanTemplatePlaybooksCompCntrl.saveTemplatePlaybooks();
				boolean indicatorSaveSuccess = accountPlanTemplateIndicatorsCompCntrl.saveIndicators(); 
			}
			
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				this.populatePageInformation();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_TEMPLATE_SAVE));
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
			
	}
	
	/** 
	 * @description Navigates page back to the Success Plan template list
	 */
	public PageReference templateCancel() {
		try { 
			PageREference pageRef = Page.CSM_AccountPlanTemplateList;
			pageRef.getParameters().put('tabCategory', 'SuccessPlan');
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			return null;
		}
	}
	
	/*Find Scout Default Template if any*/
	public void findScoutDefaultTemplate()
	{
		List<CSM_Account_Plan_Template__c> successPlanTempList = new List<CSM_Account_Plan_Template__c>();
		automateDefaultTemplate = false;
		String scoutDefaultTemplateId = '';
		try
		{
			successPlanTempList = CSM_AccountPlanTemplateDataAccess.getTemplateByName();
			if(successPlanTempList!=null && !successPlanTempList.isEmpty())
			{
				for(CSM_Account_Plan_Template__c sdt :successPlanTempList)
				{
					scoutDefaultTemplateId = sdt.Id;
					if(scoutDefaultTemplateId == templateId)
					{
						automateDefaultTemplate = false;
					}
					else
					{
						automateDefaultTemplate = true;
					}
				}
			}
			else
			{
				automateDefaultTemplate = false;
			}
		}
		catch(exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));	
		}
	}
	/** 
	 * @description set the value of the Success Plan template phases component controller reference
	 */
	public void setaccountPlanTemplatePhasesCompController(CSM_AcctPlanTemplatePhasesCompController aptphaseController) {
		accountPlanTemplatePhasesCompController = aptphaseController;
	}
	
	/** 
	 * @description set the value of the Success Plan template playbook complete controller reference 
	 */
	public void setAccountPlanTemplatePlaybookController(CSM_AcctPlanTemplatePlaybooksCompCntrl appController)
	{
		accountPlanTemplatePlaybooksCompCntrl = appController;
	}
	
	/** 
	 * @description return the reference of the current controller
	 */
	public CSM_AccountPlanTemplateController getThis() 
	{
    	return this;
	}
	
	public void setaccountPlanTemplateIndicatorsCompCntrl(CSM_AcctPlanTemplateIndicatorsCompCntrl apiController)
	{
		accountPlanTemplateIndicatorsCompCntrl = apiController;
	}
	public void setaccountPlanTemplateOpp(CSM_AccountPlanTemplateOpp apiController){
			accountPlanTemplateOpp = apiController;
			
	}
	
	
public void setaccountPlanTemplateOppTimeLine(CSM_AccountPlanTemplateOppTimeLineCtrl apiController){
			accountPlanTemplateOppTimeLine = apiController;
			system.debug('\n\n\n\n' + accountPlanTemplateOppTimeLine);
			
	}
}