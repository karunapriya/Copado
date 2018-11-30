/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		08.06.2014
 * @description	CSM_AcctPlanTemplatePlaybooksCompCntrl class is the controller for the CSM_AccountPlanTemplatePlaybooks Component
 */

public with sharing class CSM_AcctPlanTemplatePlaybooksCompCntrl {

	private List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList;
	
	public CSM_Account_Plan_Template__c theAccountPlanTemplate {get; set;}
	public boolean isEditable {get; set;}
	public String editPlaybookId {get; set;}
	public String removeAccountPlanPlaybookId {get; set;}
	public Integer successPlanCount {get; set;}
	public String acctPlayDisplayName {get; set;}
	public String helpParam {get; set;}
	
	/** 
	 * @description constructor
	 */
	public CSM_AcctPlanTemplatePlaybooksCompCntrl() 
	{
		editPlaybookId = '';
		successPlanCount = 0;
		helpParam = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_PLAYBOOKS;
	}
	
	/** 
	 * @description reference to CSM_AccountPlanTemplateController
	 */
	public CSM_AccountPlanTemplateController accountPlanTemplateController
	{
		get; 
		set {
				if(value != null)
				{
					accountPlanTemplateController = value;
					accountPlanTemplateController.setAccountPlanTemplatePlaybookController(this);
				}
			}
	}
	
	/** 
	 * @description returns the list of Success Plan playbooks
	 */
	public List<CSM_Account_Plan_Playbook__c> getAccountPlanPlaybookList() {
		populatePlaybooks();
		return accountPlanPlaybookList;
	}
	
	/** 
	 * @description gets the list of Success Plan playbooks to display on the page
	 */
	public void populatePlaybooks() {
		accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		try
		{
			accountPlanPlaybookList = CSM_AcctPlanTemplatePlaybooksDataAccess.populateAccountTemplatePlaybooks(theAccountPlanTemplate.id);
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}
	
	/** 
	 * @description Navigates the user to the create playbook page
	 */
	public PageReference createPlaybook() {
		try
		{
			if(CSM_AcctPlanTemplatePlaybooksDataAccess.createPlaybookAvailable())
			{
                PageReference returnUrl = Page.CSM_AccountPlanTemplate;
                returnUrl.getParameters().put(CSM_Constants.ID_PARAM, theAccountPlanTemplate.id);
                returnUrl.getParameters().put('tabCategory', 'SuccessPlan');
                String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(),CSM_Constants.UTF_8);
				
				//String rUrl = EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(),CSM_Constants.UTF_8);
				PageReference PageRef = Page.CSM_PlaybookManagement;
				pageRef.getParameters().put(CSM_Constants.ACCT_TEMPLATE_PARAM,theAccountPlanTemplate.id);
				pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
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
	 * @description If the user has access to edit the playbook, navigates the user to the playbook management page 
	  *				for the selected playbook
	 */
	public PageReference updatePlaybook() {
		try
		{
			if(CSM_AcctPlanTemplatePlaybooksDataAccess.updatePlaybookAvailable())
			{
				PageReference PageRef = Page.CSM_PlaybookManagement;
				pageRef.getParameters().put(CSM_Constants.ID_PARAM,editPlaybookId);
				pageRef.getParameters().put(CSM_Constants.ACCT_TEMPLATE_PARAM,theAccountPlanTemplate.id);
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
	 * @description removes the success plan template and playbook association
	 */
	public PageReference removePlaybook() {
		List<CSM_Account_Plan_Playbook__c> acctPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		boolean isSuccessFulDelete;
		try
		{
			acctPlanPlaybookList = CSM_AcctPlanTemplatePlaybooksDataAccess.getAcctPlanPlaybooksByPlaybookIdAndTemplateId(removeAccountPlanPlaybookId);
			isSuccessFulDelete = CSM_AcctPlanTemplatePlaybooksDataAccess.deleteAcctPlanTemplatePlaybook(acctPlanPlaybookList);
			
			if (isSuccessFulDelete) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_TMPL_PLAYBOOK_DELETE));
			}

		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	public PageReference getSuccessPlanAssociationCount()
	{
		List<CSM_Account_Plan__c> acctPlanList = new List<CSM_Account_Plan__c>();
		acctPlayDisplayName = '';
		try
		{
			acctPlanList = CSM_AccountPlanDataAccess.getAccountPlansByTemplateId(theAccountPlanTemplate.id);
			if(acctPlanList!=null && !acctPlanList.isEmpty())
			{
				successPlanCount = acctPlanList.size();
				if(successPlanCount <= 5)
				{
	        		List<String> tempObjList = new List<String>();					
					for(CSM_Account_Plan__c ap : acctPlanList){
						//acctPlayDisplayName = acctPlayDisplayName + ap.CSM_DisplayName__c + '\\n\t\t';
	          			tempObjList.add(ap.CSM_DisplayName__c);
					}
					acctPlayDisplayName = JSON.serialize(tempObjList);
				}
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	/** 
	 * @description adds the playbook to the account
	 */
	public PageReference addPlaybook() {
		try
		{
			//If the user has the ability to add a playbook to Success Plan playbook, redirect to that page
			if(CSM_AcctPlanTemplatePlaybooksDataAccess.addPlaybookAvailable())
			{
                PageReference returnUrl = Page.CSM_AccountPlanTemplate;
                returnUrl.getParameters().put(CSM_Constants.ID_PARAM, theAccountPlanTemplate.id);
                returnUrl.getParameters().put('tabCategory', 'SuccessPlan');
                String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(),CSM_Constants.UTF_8);
				PageReference pageRef = Page.CSM_AddPlaybook;
				pageRef.getParameters().put(CSM_Constants.RET_TO_URL, rUrl);
				pageRef.getParameters().put(CSM_Constants.ACCT_PLAN_TEMPLATE,theAccountPlanTemplate.id);
				pageRef.getParameters().put(CSM_Constants.TITLE_PARAM, EncodingUtil.urlEncode(Label.CSM_LBL_ACCT_PLAN_TEMPLATE, CSM_Constants.UTF_8));
				pageRef.getParameters().put(CSM_Constants.ADD_PARAM,'true');
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
	 * @description saves the template playbooks to Success Plan playbook
	 */
	public boolean saveTemplatePlaybooks() { 
		try {
			boolean isSuccess = CSM_AcctPlanTemplatePlaybooksDataAccess.saveTemplatePlaybooks(accountPlanPlaybookList);
			if(isSuccess)
			{
				return true;
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return false;
		
	}
}