public with sharing class CSM_SuccessPlanDetailsController {
	public CSM_SuccessPlanDetailsController(ApexPages.StandardController stdController) {
        
    }
    
    private String namespace {
    	get{
    		return CSM_Util.getNamespace();
    	}
    }
	
	public String accountManager 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_ACCOUNT_MANAGER; 
		}
		private set;
	}
	
	public String accountManagerLabel 
	{
		get {
		    return CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_ACCOUNT_MANAGER);
		}
		private set;
	}
	
	public String customerSuccessManager 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR; 
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
	
	public String csmReplacement 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_CSM_CONTACT; 
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
	
	public String csmManagerReplacement 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_CSM_MANAGER; 
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
	
	public String execSponsorReplacement 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_EXEC_SPONSOR; 
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
	public String renewalMgrReplacement 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_RENEWAL_MANAGER; 
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
	public String renewalRepReplacement 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_RENEWAL_CONTACT; 
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
	public String supportContactReplacement 
	{
		get {
		    return namespace + CSM_Constants.OBJ_AP_SUPPORT_CONTACT; 
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
}