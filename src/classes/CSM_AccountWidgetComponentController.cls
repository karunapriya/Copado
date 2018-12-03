public with sharing class CSM_AccountWidgetComponentController {
	
	public String accountPlanTemplateId {get; set;}
	public String accountId {
		get; 
		set {
			if(value != null)
			{
				accountId = value;
				getAccountDetails();
				
			}
		}
	}
	
	public String accName {get; set;}
	public String accPhase {get; set;}
	public Date renewaldate {get; set;}
	public String accManager {get; set;}
	public String supportContact {get; set;}
	public boolean mcEnabled {get; set;}
	
	public List<CSM_IndicatiorThumbnailWrapper> indicatorWrapperList {get; set;}
	public List<CSM_IndicatiorThumbnailWrapper> indicatorWrapperListTemp {get; set;}
	public List<CSM_Account_Plan__c> accountFieldSet {get; set;}
    public Account AcctObject;
    
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
    public Account getAcctObject()
	{
	    try
	    {
	    	List<Account> acctList = CSM_AccountDataAccess.getAccountInformationById(accountId);
	        if (acctList != null && !acctList.isEmpty())
	        {
	        	acctObject = acctList[0];
	        	return acctObject;
	        }	
	    }
	    
	    catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             
        }
        return null;
	}
	
	public string acctPlanRecordCurrencyCode{
       get{
            if(String.isBlank(acctPlanRecordCurrencyCode) && accountFieldSet[0] != null){
            	SObject accountPlanObj = accountFieldSet[0];
                if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(CSM_Constants.OBJ_AP))     {
                        acctPlanRecordCurrencyCode = (String)accountPlanObj.get(REN_Constants.REN_CURRENCY_ISO_CODE) + ' ';
                }else{
                        acctPlanRecordCurrencyCode = CSM_Util.convertCurrencyNameToSymbol(UserInfo.getDefaultCurrency()) + ' ';
                }
             }
           return acctPlanRecordCurrencyCode;
       }
       private set;
    }

	public void getAccountDetails(){
		mcEnabled = UserInfo.isMultiCurrencyOrganization();		
		indicatorWrapperList = new  List<CSM_IndicatiorThumbnailWrapper>();
		try
		{
			List<CSM_Account_Plan__c> listOfAccountPlan = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, accountId);
			if(listOfAccountPlan != null && !listOfAccountPlan.isempty()){
				accName = listOfAccountPlan[0].CSM_AccountId__r.Name;
				
				renewaldate = listOfAccountPlan[0].CSM_Renewal_Date__c;
				accManager = listOfAccountPlan[0].CSM_Account_Manager__c;
				supportContact = listOfAccountPlan[0].CSM_Support_Contact__c;
				accountPlanTemplateId = listOfAccountPlan[0].CSM_Account_Plan_Template__c;
				
				accountFieldSet = CSM_AccountPlanDataAccess.getAccountFieldSet(listOfAccountPlan[0].Id);
				
				CSM_IndicatorRetriever indicatorCntrl = new CSM_IndicatorRetriever();			
				indicatorWrapperListTemp = indicatorCntrl.getIndicatorWrapperList(accountPlanTemplateId, accountId);
				if(indicatorWrapperListTemp.size() > 0 && indicatorWrapperListTemp[0] !=null)
					indicatorWrapperList.add(indicatorWrapperListTemp[0]);
				if(indicatorWrapperListTemp.size() > 1 && indicatorWrapperListTemp[1] !=null)
					indicatorWrapperList.add(indicatorWrapperListTemp[1]);
				
			}
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));			
		}
	}

}