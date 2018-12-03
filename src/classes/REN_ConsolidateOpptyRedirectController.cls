public with sharing class REN_ConsolidateOpptyRedirectController
{
	 private transient ApexPages.StandardSetController standSetCont;
	 private String parentId;
	 private transient List<Opportunity> selectedOpportunities;
	 public CSM_DataGridAttribute opportunityGridAttribute{get; set;}
	 public Boolean showDataGrid{get; set;}
	 public String selectedOpportunityIds{get; set;}
	 private String syncQuoteEnabledOpportunities{get; set;}
	 private SS_Validations__c ssValidationsGlobal;
	 private Boolean isQuoteEnabled;
	 public String isSyncQuoteEnabledOnAnySelectedOpp{get; set;}
	 public String syncQuoteEnabledMsg{get; set;}
	 private String urlParam{get; set;}
	 public String hasSyncedPO{get;set;}
	 public boolean hasError{get;set;}
	 
     public REN_ConsolidateOpptyRedirectController(ApexPages.StandardSetController controller) {
        standSetCont = controller;
        this.parentId = ApexPages.currentPage().getParameters().get('Id');
        this.showDataGrid = false;
        this.setGridAttributes();
        ssValidationsGlobal = SS_Validations__c.getOrgDefaults();
        isQuoteEnabled = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId');
     }
     
      public PageReference returnPage(){
    	PageReference pageRef = null;
    	this.selectedOpportunities = (List<Opportunity>) standSetCont.getSelected();
        pageRef = processSelection();
    	     
        return pageRef;
    }
    
    private PageReference processSelection(){
    	PageReference pageRef = null;
    	if (selectedOpportunities == null || selectedOpportunities.isEmpty()){
    		this.showDataGrid = true;
    	} else{
	        pageRef = redirectToConsolidateOpportunity();
    	}
    	return pageRef;	
    }
    
    public PageReference consolidateSyncOpportunityAlso(){
		PageReference pageRef = Page.REN_ConsolidateOpportunity;
		pageRef.getParameters().put('opptyIds', urlParam);			
		pageRef.getParameters().put('rSyncQuote', 'y');//Remove SyncQuote from Opportunity
		if(String.isNotBlank(this.parentId)){
			pageRef.getParameters().put('parentId', this.parentId);
		}
    	return pageRef;
    }
    public PageReference consolidateOpportunity(){
	    PageReference pageRef = null;
    	if(String.isNotBlank(this.selectedOpportunityIds))
    	{
    		Set<String> oppIdSet = REN_Util.convertCSVtoSet(this.selectedOpportunityIds, '-');
    		if (validateSelectedOpportunities(oppIdSet))
     	    {
     	    	if(String.isNotBlank(isSyncQuoteEnabledOnAnySelectedOpp) 
     	    		&& isSyncQuoteEnabledOnAnySelectedOpp.equals('true') 
     	    		&& String.isNotBlank(syncQuoteEnabledOpportunities)){
					syncQuoteEnabledOpportunities = syncQuoteEnabledOpportunities.removeEnd(', ');
				    syncQuoteEnabledMsg = String.format(Label.REN_MSG_FOR_EXAMPLE, new String[]{syncQuoteEnabledOpportunities});
				    urlParam = this.selectedOpportunityIds;
     	    	}else{
		    		pageRef = Page.REN_ConsolidateOpportunity;
					pageRef.getParameters().put('opptyIds', this.selectedOpportunityIds);
					if(String.isNotBlank(this.parentId)){
						pageRef.getParameters().put('parentId', this.parentId);
					}
     	    	}
     	    }
    	}
    	else
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.MSG_AT_LEAST_ONE, new String[]{Schema.SObjectType.Opportunity.label})));
    	}
    	return pageRef;
    }
    
    private boolean validateSelectedOpportunities(Set<String> oppIdSet)
    {
    	hasError = false;
    	isSyncQuoteEnabledOnAnySelectedOpp = 'false';
    	syncQuoteEnabledOpportunities = '';
    	syncQuoteEnabledMsg = '';
    	Boolean isValid = true;
    	Boolean recordTypeExists = CSM_Util.getRecordTypeExists(new Opportunity());
    	Set<String> knownFields = new Set<String>{'Name','Pricebook2Id', 'IsClosed','REN_Is_Consolidated__c','CHL_QuoteSyncStatus__c','REN_Renewal_Metrics_Status__c'};
    	//Set<Id> oppIdSet = new Set<Id>();
    	Set<String> stagesNotAllowed = new Set<String>();
    	Set<String> recordTypes = new Set<String>();
    	if (isQuoteEnabled)
    	{ 	    
     	    knownFields.add('SyncedQuoteId');
    	}
	    if (String.isNotBlank(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c))
	    {
	    	knownFields.add('StageName');
	    	stagesNotAllowed = REN_Util.convertCSVtoSet(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c, ',');
	    }
	    if(UserInfo.isMultiCurrencyOrganization())	
	    {
	    	knownFields.add(REN_Constants.REN_CURRENCY_ISO_CODE);
	    }
	    
        if (recordTypeExists)
        {
            knownFields.add('RecordTypeId');
        }
        Set<Id> idSet2 = new Set<Id>( (List<Id>)new List<String>( oppIdSet ) );
    // 	for(Opportunity oppObject: selectedOpportunities){
		//	oppIdSet.add(oppObject.Id);
	//	}
 	    
 	    Set<String> pricebookSet = new Set<String>();
 	    Set<String> currencySet = new Set<String>();
 	    
 	    List<sObject> sObjects = REN_OpportunityDataAccess.getFilteredRecordsList(
 	        'Opportunity', knownFields, idSet2, null, null,null);
  	    for(sObject sObjectOpp: sObjects)
		{
			if (recordTypeExists && recordTypes.isEmpty())
			{
				recordTypes.add((String)sObjectOpp.get('RecordTypeId'));
				
			}
			else if(recordTypeExists && !recordTypes.contains((String)sObjectOpp.get('RecordTypeId')))
			{
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				'The Selected Opportunities must have matching Record Types.'));
				break;
			}
			if (pricebookSet.isEmpty())
			{
				pricebookSet.add((String)sObjectOpp.get('Pricebook2Id'));
			}
			else if (!pricebookSet.contains((String)sObjectOpp.get('Pricebook2Id')))
			{
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_LBL_PB_ERROR_MSG));
				break;
			}
			if(UserInfo.isMultiCurrencyOrganization())	
		    {
		        if (currencySet.isEmpty())
		        {
		        	currencySet.add((String)sObjectOpp.get(REN_Constants.REN_CURRENCY_ISO_CODE));
		        }
		        else if (!currencySet.contains((String)
		            sObjectOpp.get(REN_Constants.REN_CURRENCY_ISO_CODE)))
		        {
		        	isValid = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
					    System.label.REN_LBL_CURRENCY_ERROR_MSG));
					break;
		        }
		    }
			if (sObjectOpp.get('IsClosed') != null && Boolean.valueOf(sObjectOpp.get('IsClosed')))
			{
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				    Label.REN_MSG_CLOSED_OPP_CONS));
				break;
		    }
			
			if (isQuoteEnabled && sObjectOpp.get('SyncedQuoteId') != null){
				syncQuoteEnabledOpportunities =+ (String)sObjectOpp.get('Name') + ', ';
				isSyncQuoteEnabledOnAnySelectedOpp = 'true';
		    }
		   
		    if (!stagesNotAllowed.isEmpty() && stagesNotAllowed.contains((String)sObjectOpp.get('StageName')))
		    {
		    	isValid = false;
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
		    	String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_CONSOLIDATE, 
		    	new String[] {(String)sObjectOpp.get('StageName')})));
		    	break;
		    }
		    if (sObjectOpp.get('REN_Is_Consolidated__c') != null & (Boolean)sObjectOpp.get('REN_Is_Consolidated__c'))
            {
            	isValid = false;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(
                   System.Label.REN_LBL_CONSOIDATED_MSG, new String[] {(String)sObjectOpp.get('Name')})));
                break;
            }
            if ((sObjectOpp.get('CHL_QuoteSyncStatus__c') != null && sObjectOpp.get('CHL_QuoteSyncStatus__c') != 'None') 
            	|| (sObjectOpp.get('REN_Renewal_Metrics_Status__c') != null && sObjectOpp.get('REN_Renewal_Metrics_Status__c') != 'Calculated'))
            {
            	isValid = false;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.REN_PREVENT_CONSOLIDATE_IF_BATCHES_RUNNING));
            	break;
            }
            
		}
		list<CHL_Partner_Opportunity__c> poList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunity (idSet2);
	    hasSyncedPO = poList != null && !poList.isEmpty() ? 'true' : 'false';
    	if(ApexPages.hasMessages()){
    		hasError = true;
    		isSyncQuoteEnabledOnAnySelectedOpp = 'false';
    	}
    	return isValid;
    }
    
     private PageReference redirectToConsolidateOpportunity()
     {
     	PageReference pageRef = null;
     	Set<String> oppIdSet = new Set<String>();
     	for(Opportunity oppObject: selectedOpportunities){
		    oppIdSet.add(oppObject.Id);
		}
		urlParam = '';
     	if (validateSelectedOpportunities(oppIdSet)){
	    	String url = '';
	        Boolean firstIteration = true;
	        for(Opportunity oppObject: selectedOpportunities){
				if(firstIteration){
					url = oppObject.Id;
					firstIteration = false;
				}else{
					url = url + '-' + oppObject.Id; 
				} 
			}
 	    	if((String.isNotBlank(isSyncQuoteEnabledOnAnySelectedOpp) 
     	    		&& isSyncQuoteEnabledOnAnySelectedOpp.equals('true') 
     	    		&& String.isNotBlank(syncQuoteEnabledOpportunities))
 	    		|| (String.isNotBlank(this.hasSyncedPO) && this.hasSyncedPO.equals('true'))){
				syncQuoteEnabledOpportunities = syncQuoteEnabledOpportunities.removeEnd(', ');
			    syncQuoteEnabledMsg = String.format(Label.REN_MSG_FOR_EXAMPLE, new String[]{syncQuoteEnabledOpportunities});
			    urlParam = url;
     		}else{
				pageRef = Page.REN_ConsolidateOpportunity;
				pageRef.getParameters().put('opptyIds', url);
				if(String.isNotBlank(this.parentId)){
					pageRef.getParameters().put('parentId', this.parentId);
				}
     		}
			
        }
        
		return pageRef;
    }
     
    private void setGridAttributes() { 
        opportunityGridAttribute = new CSM_DataGridAttribute();        
        opportunityGridAttribute.tableName = Schema.SObjectType.Opportunity.label;
    	opportunityGridAttribute.objectType =Schema.SObjectType.Opportunity.label;
    	opportunityGridAttribute.viewName = CSM_Constants.GRID_ATTR_CONSOLIDATE;
    	opportunityGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	opportunityGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
    	opportunityGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
    	opportunityGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
    	opportunityGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
    	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
	    opportunityGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        gridInputParams.accountId = this.parentId;
        if(String.isBlank(this.parentId)){
	        gridInputParams.selectedFilterClause = standSetCont.getFilterId();
        }
     	opportunityGridAttribute.params = JSON.serialize(gridInputParams);
	}
  
}