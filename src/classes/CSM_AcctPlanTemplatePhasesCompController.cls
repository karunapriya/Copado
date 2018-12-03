/**
* @author         Mike Faust (mike@comitydesigns.com)
* @date           07.23.2014
* @description    CSM_AccountPlanTemplatePhasesDataAccess class performs Data Access for  Acount Plan Phase object
*/

public with sharing class CSM_AcctPlanTemplatePhasesCompController {
	
	private List<CSM_Account_Plan_Phase__c> accountPlanPhaseList;
	public String newPhaseName {get; set;}
	public String newPhaseLength {get; set;}
	public boolean isEditable {get; set;}
	public String addSuccessful {get; set;}
	public String deleteId {get; set;}
	public String deleteName {get; set;}
	public String helpParam {get; set;}
	public Integer phaseSequence {get; set;}	
	
	
	/**
	 *@description constructor 
     */
	public CSM_AcctPlanTemplatePhasesCompController() {
		addSuccessful = '';
		deleteId = '';	
		helpParam = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_PHASES;
	}
	public CSM_Account_Plan_Template__c theAccountPlanTemplate 
	{ get; 
		set {
			if (value != null)
			{
				theAccountPlanTemplate = value;
			    if (CSM_AccountPlanTemplateController != null)
			    {
				    CSM_AccountPlanTemplateController.setaccountPlanTemplatePhasesCompController(this);
			    }		
			}
		}
	}
			
	/**
	 *@description constructor 
     */
	public List<CSM_Account_Plan_Phase__c> getAccountPlanPhaseList()
	{
		if(accountPlanPhaseList == null)
		{
			populatePhases();
		}
		return accountPlanPhaseList;
	}
	
	/**
	 *@description populates the Success Plan phases for the page's Success Plan template 
     */
	private void populatePhases() {
		accountPlanPhaseList = new List<CSM_Account_Plan_Phase__c>();
		try
		{
			//If the Success Plan template id is populated, query to get all the Success Plan phases
	    	if(theAccountPlanTemplate.id != null)
	    	{
	    		accountPlanPhaseList = CSM_AccountPlanTemplatePhasesDataAccess.populateAccountTemplatePhases(theAccountPlanTemplate.Id);
	    	}
    	}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}
	
	
	/**
	 *@description save all the phases from the page 
     */
	public boolean savePhase() {
		try {
			//Validation occurs when the length is required to be greater than 0 days
			boolean isSuccessfulUpdate = CSM_ACcountPlanTemplatePhasesDataAccess.updatePhases(accountPlanPhaseList);
			//If successful update, display message to page that was success
			if(isSuccessfulUpdate)
			{
				populatePhases();
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_PHASE_UPDATE));
				return true;
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));	
		}
		return false;
		
	}
	
	/**
	 *@description delete phase that is selected from page
     */
	public void deletePhase() {
		try {
			//Verify that the delete id is not null. If it isn't, then delete the phase
			if(!String.isBLank(deleteId))
			{
				boolean isSuccessfulDelete = CSM_AccountPlanTemplatePhasesDataAccess.deletePhases(new List<String>{deleteId});
				//If successfully, delete display message that it deleted
				if(isSuccessfulDelete)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_PHASE + ' ' + deleteName + ' ' + Label.CSM_MSG_PHASE_DELETE));
					for(integer i=0;i<accountPlanPhaseList.size();i++){
						if(deleteId == accountPlanPhaseList[i].Id){
							accountPlanPhaseList.remove(i);						
						}
					}
				}
				//refresh the list of phases and clear delete variables
				//populatePhases();
				deleteId = '';
				deleteName = '';
			}else{
				for(integer i=0;i<accountPlanPhaseList.size();i++){
					if(phaseSequence == i){
						if(String.isEmpty(accountPlanPhaseList[i].Id)){
							accountPlanPhaseList.remove(i);						
						}
					}
				}
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
	}
	
	  /**
	* @description Creating local reference to the CSM_AccountPlanTemplateController so that 
	*              setIndicatorComponentControllerMap may be used.
	*/
    public CSM_AccountPlanTemplateController CSM_AccountPlanTemplateController
	{ 
		get; 
    	set 
    	{
			if (value != null) 
			{
				CSM_AccountPlanTemplateController = value;		
						
			}
		}
	}
	
	public PageReference addPhase() {	
		try {
			accountPlanPhaseList.add(new CSM_Account_Plan_Phase__c(CSM_Account_Plan_Template__c=theAccountPlanTemplate.id, csm_order__c=accountPlanPhaseList.size()+1));
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}	
}