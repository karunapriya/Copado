/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		07.24.2014
 * @description	CSM_AccountPlanTemplateListController class is the controller for hte CSM_AccountPlanTemplateList
 */

public with sharing class CSM_AccountPlanTemplateListController {

	public boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public String helpParam {get; set;}
	private List<AccountPlanTemplateWrapper> accountPlanTemplateList;
	public String templateId {get; set;}
	public String tabCategory {get; set;} 
	public String strsuccessPlanNames {get; set;}	
	public Integer successPlanCount {get; set;}	
	
	/** 
	 * @description	Constructor
	 */
	public CSM_AccountPlanTemplateListController()
	{
		helpParam = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATES;
		hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        this.populateAccountPlanTemplateList();
	}
	
	
	/** 
	 * @description	private method populates the setController of Success Plan templates
	 */
	private void populateAccountPLanTemplateList() {
		this.accountPlanTemplateList = new List<AccountPlanTemplateWrapper>();
		try 
		{
			List<CSM_Account_Plan_Template__c> acctPlanTemplateList = CSM_AccountPlanTemplateDataAccess.populateAccountPlanTemplateInformation();
	    	if(acctPlanTemplateList != null){
	    		for(CSM_Account_Plan_Template__c acctPlanTemplate : acctPlanTemplateList){
	    			this.accountPlanTemplateList.add(new AccountPlanTemplateWrapper(acctPlanTemplate));
	    		}
	    	}	
		}    	
    	catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
	}
	
	
	
	/*Added for US320 to get the success plan names and count to which the to be deleted success plan template belongs to*/
	public PageReference getSuccessPlansSPTemplateDelete() {
		List<SObject> sobjsuccessPlans = CSM_AccountPlanTemplateDataAccess.getAllSuccessPlansforSPTemplates(templateId);
		Set<String> successPlanNames = new Set<String>();	
	    for(SObject sobjsuccessPlan: sobjsuccessPlans){
	    	successPlanNames.add((String)sobjsuccessPlan.get(CSM_Constants.OBJ_AP_DISPLAY_NAME));
	    }
	    strsuccessPlanNames = '';

	    successPlanCount = successPlanNames.size();
		if(successPlanCount < 6){
			List<String> tempObjList = new List<String>();
			for(String str: successPlanNames){
				tempObjList.add(str);
				//strsuccessPlanNames = strsuccessPlanNames + str + '\\n';
			}
			strsuccessPlanNames = JSON.serialize(tempObjList);
		}
		return null;
	}

	/*Added for US320 to delete the Success Plan Template*/
	public PageReference deleteSPTemplate() {
		List<CSM_Account_Plan_Template__c> listSPTempl = new List<CSM_Account_Plan_Template__c>();		
		CSM_Account_Plan_Template__c successPlanTemplate = new CSM_Account_Plan_Template__c(Id = templateId); 
		listSPTempl.add(successPlanTemplate);
		CSM_AccountPlanTemplateDataAccess.deleteSPTemplate(listSPTempl);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_SuccessPlanTemplate_DELETE));	
		
		populateAccountPLanTemplateList();
		
		return null;	
	}
	
	
	
	/**
	 * @description	returns list of Success Plan templates 
	 */
	
	public List<AccountPlanTemplateWrapper> getAccountPlanTemplateList() {
		return accountPLanTemplateList;
	}
    
    /**
     * @description	public method that navigates user to the edit Success Plan template page
     */
    public PageReference editTemplate() {
    	try {
    		//If user has access to edit a template
    		boolean isEditableTemplate = CSM_AccountPlanTemplateDataAccess.updateTemplateAvailable();
    		if(isEditableTemplate)
    		{
	    		PageReference pageRef = Page.CSM_AccountPlanTemplate;
	    		pageRef.getParameters().put(CSM_Constants.ID_PARAM,templateId);
	    		pageRef.getParameters().put('tabCategory', 'SuccessPlan');
	    		pageRef.setRedirect(true);
	    		return pageRef;
    		}
    		else
    		{
    			return null;
    		}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
    }
    
    /**
     * @description	public method that navigates user to the edit Success Plan template page
     */
    public PageReference cloneTemplate() {
    	try {
    		//If user has access to create a template
    		if(CSM_AccountPlanTemplateDataAccess.createTemplateAvailable()){
				CSM_Account_Plan_Template__c foundTemplate = findAccountTemplateById();
				CSM_AccountPlanTemplateDataAccess.cloneTemplate(new List<CSM_Account_Plan_Template__c>{foundTemplate});
				if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
			    	this.populateAccountPLanTemplateList();
				}
    		}
    	}catch (exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
    	return null;
    }
    
    /**
     * @description	public method navigates user to create new Success Plan template 
     */
    public PageReference createNew() {
    	try {
    		//If user has insert access, navigate to the Success Plan template page
    		boolean isCreateableTemplate = CSM_AccountPlanTemplateDataAccess.createTemplateAvailable();
    		if(isCreateableTemplate)
    		{
	    		PageReference pageRef = Page.CSM_AccountPlanTemplate;
	    		pageRef.getParameters().put('tabCategory', 'SuccessPlan');
	    		pageRef.setRedirect(true);
	    		return pageRef;
    		}
    		else
    		{
    			return null;
    		}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
    }
    
    private CSM_Account_Plan_Template__c findAccountTemplateById(){
    	CSM_Account_Plan_Template__c foundTemplate = null;
    	if(String.isNotBlank(this.templateId) && this.accountPlanTemplateList != null){
    		for(AccountPlanTemplateWrapper wrapper : this.accountPlanTemplateList){
    			if(this.templateId.equals(wrapper.accPlanTemplate.Id)){
    				foundTemplate = wrapper.accPlanTemplate;
    				break;
    			}
    		}
    	}
    	return foundTemplate;
    }
    
    public class AccountPlanTemplateWrapper {
    	public CSM_Account_Plan_Template__c accPlanTemplate{get;set;}
    	public Boolean allowClone{get;set;}
    	public accountPlanTemplateWrapper(CSM_Account_Plan_Template__c accPlanTemplate){
    		this.accPlanTemplate = accPlanTemplate;
    		this.allowClone = false;
    		if(this.accPlanTemplate != null){
    			canCloneTemplate(accPlanTemplate.Account_Plan_Playbooks__r);
    		}
    	}
    	
    	private void canCloneTemplate(List<CSM_Account_Plan_Playbook__c> accPlanPlaybookList){
    		for(CSM_Account_Plan_Playbook__c accPlanPlaybook : accPlanPlaybookList){
    			if(accPlanPlaybook != null && !accPlanPlaybook.CSM_Playbook__r.CSM_Automated__c){
    				this.allowClone = true;
    				break;
    			}
    		}
    	}
    }
}