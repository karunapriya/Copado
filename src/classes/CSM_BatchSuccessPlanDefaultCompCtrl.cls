public with sharing class CSM_BatchSuccessPlanDefaultCompCtrl {
    public CSM_Batch_Success_Plan_Default__c batchSPDefault{get; set;}
    
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
    
    public String batchSPDefaultId {
		get; 
		set {
			
				batchSPDefaultId = value;
				getbatchSPDefault();
		}
	}
	
	public CSM_Batch_Success_Plan_Default__c getbatchSPDefault(){
		List<CSM_Batch_Success_Plan_Default__c> batchSPDefaultList = new List<CSM_Batch_Success_Plan_Default__c>();
		batchSPDefaultList = CSM_BatchSuccessPlanDefaultDataAccess.getBatchSuccessPlanDefRec(batchSPDefaultId);
		if(!batchSPDefaultList.isEmpty()) {
			batchSPDefault = batchSPDefaultList[0];
		}
		
		return batchSPDefault;
		
	}
}