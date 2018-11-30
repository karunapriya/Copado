public with sharing class CSM_AccountPlanDetailsCompController
{
   	
   	public transient List<CSM_Account_Plan__c> accountPlanDetail;
   	public String editOpportunityId {get; set;}
   	public String acctPlanTempId {get; set;}
   	public Id deleteOpportunityId {get; set;}
   	public String viewOpportunityId {get; set;}
   	public transient List<Account> accountDetail;
   	public Boolean displayNewOpp {get; set;}
   	public transient Map<ID, String> accountPlanCurrentPhaseMap {get; set;}
   	public Set<Id> playbookSet {get; set;}
   	public Map<Id, CSM_Account_Plan_Playbook__c> mapAcctPlanPlaybook {get; set;}
   	
   	public String helpParam {get; set;} 
   	public transient List<Opportunity> opportunityDetailList {get; set;}
   	
   	public  Map<String,boolean> fieldSetCalculated {get; set;}
   	
   	public transient List<CSM_PlaybookWrapper> playbookList;
   	
   	public CSM_DataGridAttribute playbookGridAttribute {get; set;}
   	public CSM_DataGridAttribute opportunityGridAttribute {get; set;}
   	public String accountId
    {
        get
        {
            return accountId;
        }
        set
        {
            accountId = value;
            setGridAttribute();
        }
    }
    
    public String acctPlanId 
    {
    	get
        {
        	return acctPlanId;
        }
        
	    set
	    {
	    	acctPlanId = value;
	    	setGridAttribute();
	    }
    } 
    
    private void setGridAttribute()
    {	
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     	gridInputParams.accountId = accountId;
     	gridInputParams.accountPlanId = acctPlanId;
     	
        /*playbookGridAttribute = new CSM_DataGridAttribute();
        playbookGridAttribute.gridToolbarId = CSM_Constants.GRID_ATTR_PLAYBOOK_TOOLBAR;
        playbookGridAttribute.tableName = CSM_Constants.GRID_ATTR_PLAYBOOK_SP;
        playbookGridAttribute.objectType = Schema.SObjectType.CSM_PLaybook__c.label;
        playbookGridAttribute.viewName = CSM_Constants.GRID_ATTR_SUCCESS_PLAN_DETAIL;
        playbookGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
        playbookGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
        playbookGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
        playbookGridAttribute.showExport = CSM_Constants.GRID_ATTR_FALSE;
        playbookGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
        playbookGridAttribute.params = JSON.serialize(gridInputParams);*/	   
              
        
        opportunityGridAttribute = new CSM_DataGridAttribute();
        opportunityGridAttribute.tableName = CSM_Constants.GRID_ATTR_OPP_SP;
        opportunityGridAttribute.objectType = CSM_Constants.OBJ_TYPE_OPPORTUNITY;
        opportunityGridAttribute.viewName = CSM_Constants.GRID_ATTR_SUCCESS_PLAN_DETAIL;
        opportunityGridAttribute.gridToolBarId = CSM_Constants.GRID_ATTR_OPP_TOOLBAR;
        opportunityGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE; 
        opportunityGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
        opportunityGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
        opportunityGridAttribute.showExport = CSM_Constants.GRID_ATTR_FALSE;
        opportunityGridAttribute.showGlobalSelect = CSM_Constants.GRID_ATTR_FALSE;
        opportunityGridAttribute.params = JSON.serialize(gridInputParams);   
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		opportunityGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
   	
   	public List<CSM_PlaybookWrapper> getPlaybookList() {
   		if (acctPlanId!=null){
   			populatePlaybooksList();
   		} else {
			playbookList = new List<CSM_PlaybookWrapper>();
		}
		return playbookList;
	}
	
	public string recordCurrencyCode{
       get{
            if(String.isBlank(recordCurrencyCode) && accountDetail[0] != null){
            	SObject accountObj = accountDetail[0];
                if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(CSM_Constants.OBJ_ACCOUNT))     {
                        recordCurrencyCode = (String)accountObj.get(REN_Constants.REN_CURRENCY_ISO_CODE) + ' ';
                }else{
                        recordCurrencyCode = CSM_Util.convertCurrencyNameToSymbol(UserInfo.getDefaultCurrency()) + ' ';
                }
             }
           return recordCurrencyCode;
       }
       private set;
    }
    
    public string acctPlanRecordCurrencyCode{
       get{
            if(String.isBlank(acctPlanRecordCurrencyCode) && accountPlanDetail[0] != null){
            	SObject accountPlanObj = accountPlanDetail[0];
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
    
    public string oppRecordCurrencyCode{
       get{
            if(String.isBlank(oppRecordCurrencyCode) && opportunityDetails[0] != null){
            	SObject oppObj = opportunityDetails[0];
                if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(CSM_Constants.OBJ_OPPORTUNITY))     {
                        oppRecordCurrencyCode = (String)oppObj.get(REN_Constants.REN_CURRENCY_ISO_CODE) + ' ';
                }else{
                        oppRecordCurrencyCode = CSM_Util.convertCurrencyNameToSymbol(UserInfo.getDefaultCurrency()) + ' ';
                }
             }
           return oppRecordCurrencyCode;
       }
       private set;
    }
   	
   	public CSM_AccountPlanDetailsCompController()
   	{   		
   	    displayNewOpp = CSM_AccessController.getInstance().objectCrudCheck(CSM_Constants.OBJ_OPPORTUNITY, CSM_Constants.DML_OPERATION_INSERT);
   	    helpParam = CSM_Constants.HELP_PLAN_DETAILS_SUBTAB; 
   	    calculateDisplay();		
   	}
   	
   	/** 
	 * @description	populates the playbooks list 
	 */
	public void populatePlaybooksList() {
		
		playbookList = new List<CSM_PlaybookWrapper>();
		playbookSet = new Set<Id>();
   	    mapAcctPlanPlaybook = new Map<Id, CSM_Account_Plan_Playbook__c>(); 
		acctPlanTempId = '';
		try
		{
			List<CSM_Account_Plan__c> accPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(acctPlanId, null);
			if(accPlanList!=null && !accPlanList.isEmpty()){
				acctPlanTempId = accPlanList[0].CSM_Account_Plan_Template__c;
				
			}
    		List<CSM_Account_Plan_Playbook__c> accPlanPlaybooksList = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByAccPlanId(acctPlanId, acctPlanTempId);
    		for(CSM_Account_Plan_Playbook__c app : accPlanPlaybooksList){
    			playbookSet.add(app.CSM_Playbook__c);
    			mapAcctPlanPlaybook.put(app.CSM_Playbook__r.Id, app);
    		}
    		playbookList = CSM_PlaybooksDataAccess.populatePlaybooksInformationByAcctPlanPlaybookId(playbookSet);
    	}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
	}
   	
   	public List<CSM_Account_Plan__c> getAccountPlanDetail()
   	{
   		
		try
		{
		    accountPlanDetail = CSM_AccountPlanDataAccess.getDetailFieldSet(acctPlanId);
		    accountPlanCurrentPhaseMap = CSM_Util.getCurrentPahse (accountPlanDetail);
		
		}
		catch (Exception ex)
        {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	                
        } 
        return accountPlanDetail;
   	}
   	
   	public List<Account> getAccountDetail()
   	{
   		try
   		{
   	        accountDetail = CSM_AccountDataAccess.getDetailFieldSet(accountId);
   		}
   	    catch (Exception ex)
        {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	                
        } 
        return accountDetail;
   	}
		 
	public List<Opportunity> getOpportunityDetails() {
		try
		{	     
			if (accountId!=null && accountPlanDetail!=null && !accountPlanDetail.isEmpty()){
            	opportunityDetails = CSM_OpportunityDataAccess.getDetailFieldSetByAccount(accountId, accountPlanDetail[0].CSM_Phase_Start_Date__c);
			} else {
				opportunityDetails = new List<Opportunity>();
			}
            
            return opportunityDetails;
		}
		catch (Exception ex)
        {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
            return null;
        }             
	}
	
    public transient List<Opportunity> opportunityDetails;
	
	public PageReference newOpportunity()
	{
		PageReference pageRef = new PageReference('/'+CSM_Constants.OPPTY_PREFIX + '/e');
		
		PageReference aspRef = Page.CSM_AccountSuccessPlan;
		aspRef.getParameters().put(CSM_Constants.ID_PARAM,acctPlanid);
		String rUrl = aspRef.getUrl();
				
		pageRef.getParameters().put(CSM_Constants.ACCOUNT_ID_PARAM, accountId);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	pageRef.getParameters().put(CSM_Constants.SAVE_URL,rUrl);
    	pageRef.setRedirect(true);
    	return PageRef;		
	}
	
	public String getRetURL(){
		return null;	
	}
	
	public PageReference editOpportunity()
	{
		PageReference pageRef = new PageReference('/'+editOpportunityId+'/e');			
    	PageReference aspRef = Page.CSM_AccountSuccessPlan;
		aspRef.getParameters().put(CSM_Constants.ID_PARAM,acctPlanid);
		String rUrl = aspRef.getUrl();
    	
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	pageRef.setRedirect(true);
    	return PageRef;		
	}
	
	public PageReference viewOpportunity()
	{
		PageReference pageRef = new PageReference('/'+viewOpportunityId);	
    	pageRef.setRedirect(true);
    	return PageRef;		
	}
	
	public PageReference deleteOpportunity()
	{
		system.debug('deleteOpportunityId $$$$$$$ '+deleteOpportunityId);
		List<Opportunity> listOpportunity = new List<Opportunity>();
		listOpportunity.add(new Opportunity(Id=deleteOpportunityId));
		try
		{		
		    CSM_OpportunityDataAccess.deleteOpportunity(listOpportunity);		
		}
		catch (Exception ex)
        {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
            return null;
        } 
    	return null;		
	}
	
	public PageReference saveDetails()
	{
	    try
		{					
	        CSM_AccountPlanDataAccess.updateAccountPlan(accountPlanDetail);
	       	 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_ACCT_PLAN_SAVED));
	    }
		catch (Exception ex)
        {           
        	if(!(String.valueOf(ex)).contains(System.Label.CSM_EXCEPTION_STRING)) {
	 			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
	 		}
            return null;
        } 
        return null;
	}
	
	public void calculateDisplay() {
		fieldSetCalculated = new Map<String,boolean>();
            //NOTE: Could pass the sobjectype through 
            //Schema.SObjectType.CSM_Account_Plan__c.fieldSets.CSM_Account_Plan_Details.getSObjectType().getDescribe().getName()
      	fieldSetCalculated = CSM_AccessController.getInstance().returnFieldIsCalculated(CSM_Constants.OBJ_AP);
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