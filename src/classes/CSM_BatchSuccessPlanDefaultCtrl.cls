public with sharing class CSM_BatchSuccessPlanDefaultCtrl {
  public String helpParam {get; set;}
  public CSM_Batch_Success_Plan_Default__c batchSuccessPlanDef {get; set;}
  private String planDefId;
  private String sourcePlanDefId;
  private String sourceFilterId;
  
  	public String accountManagerLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_ACCOUNT_MANAGER);
		}
		private set;
	}
	
	public String customerSuccessManagerLabel 
	{
		get {
			
			return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR);
		}
		private set;
	}
	
	public String csmReplacementLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_CONTACT);
		}
		private set;
	}
	
	public String csmManagerReplacementLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_MANAGER);
		}
		private set;
	}
	
	public String execSponsorReplacementLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_EXEC_SPONSOR);
		}
		private set;
	}
	
	public String renewalMgrReplacementLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_MANAGER);
		}
		private set;
	}
	
	public String renewalRepReplacementLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_CONTACT);
		}
		private set;
	}
	
	public String supportContactReplacementLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_SUPPORT_CONTACT);
		}
		private set;
	}
  
  public CSM_BatchSuccessPlanDefaultCtrl() 
  {
      helpParam = CSM_Constants.HELP_PLAYS;/*to be changed*/
      batchSuccessPlanDef = new CSM_Batch_Success_Plan_Default__c();
      planDefId =  ApexPages.currentPage().getParameters().get('id');
      sourcePlanDefId=ApexPages.currentPage().getParameters().get('pid');
	  sourceFilterId=ApexPages.currentPage().getParameters().get('fid');
      if(String.isNotBlank(planDefId))
      {
      	populateInfo();
      }
  }
  private void populateInfo()
    {
    	try
    	{
    		List<CSM_Batch_Success_Plan_Default__c> batchSuccessPlanDefList = CSM_BatchSuccessPlanDefaultDataAccess.getBatchSuccessPlanDefRec(planDefId);
	    	if(!batchSuccessPlanDefList.isEmpty()){
				batchSuccessPlanDef = batchSuccessPlanDefList[0];
			}	
    	}
    	catch(exception e)
    	{    		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
    	}
    }
    public PageReference saveBatchPlanDefault(){
    	try
    	{
	    	List<CSM_Batch_Success_Plan_Default__c> finalList = CSM_BatchSuccessPlanDefaultDataAccess.saveBatchPlanDefRecord(new List<CSM_Batch_Success_Plan_Default__c>{batchSuccessPlanDef});
	    	PageReference pageRef = Page.CSM_BatchPlanTemplateAssignment;
			if(String.isNotBlank(planDefId)){
				return this.redirectTo(planDefId);
			} else {
				return this.redirectTo(finalList[0].id);
			}
    	}
    	catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
	   	}
	   	return null;
    }  
    public PageReference cancel()
    {
		return this.redirectTo(sourcePlanDefId);
    }
    
    private PageReference redirectTo(String planId) 
    {
    	PageReference pageRef = Page.CSM_BatchPlanTemplateAssignment;
		pageRef.getParameters().put('pid',planId);
		pageRef.getParameters().put('fid',sourceFilterId);
		pageRef.getParameters().put('tabCategory', 'SuccessPlan');
		pageRef.setRedirect(true);
		return pageRef;
    } 
}