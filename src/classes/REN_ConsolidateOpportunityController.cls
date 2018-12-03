public with sharing class REN_ConsolidateOpportunityController
{
    public String selectedOpptType {get; set;}
    public String helpParam {get; set;} 
    public String isErrorReported {get; set;}
    public Boolean showAsInput {get; set;}
    public Boolean showTarget {get; set;}
    public Boolean showOpptPicker {get; set;}
    public Opportunity currentOpptDisplayed {get; set;}
    public OpportunityLineItem newExistingOpp {get; set;}
    public Opportunity targetOppt{get; set;}
    private String parentId{get;set;}
    private String preDeterminedAccount{get;set;}
    private String preDeterminedOwner{get;set;}
    public String consButtonLabel {get;set;}
   
    private Integer consolidateRecordLimit;
    
    private Set<String> oliFieldsSetForQuery;
    private List<Schema.FieldSetMember> oliFieldSetMemberList;
    private Set<String> oliDefaultFieldsSet;
    public Boolean isRequest{get;set;}
    private Set<Id> oppIdSet;
   
    private SS_Validations__c ssValidationsGlobal;
    private Boolean isQuoteEnabled;
    private Boolean shouldRemoveSyncQuoteIdOnOpp = false;
    public boolean hasSyncedPO{get;set;}
    
    private Set<String> stagesNotAllowed;
    private List<Opportunity> consolidateOpps;
    List<String> opptyIdList = new List<String>();
    String isFromManageRen;
    
    public boolean isSyncQuoteEnabledOnAnySelectedTargetOpp {
		get{
			return (
				(currentOpptDisplayed.get('SyncedQuoteId')!= null)
			);
		} 
		set;
	}
	
	public boolean isQuoteEnabledOnTargetOpp {
		get{
			return (
				isQuoteEnabled && (currentOpptDisplayed.get('SyncedQuoteId') != null)
			);
		} 
		set;
	}
	
    public REN_ConsolidateOpportunityController()
    {	
    	isFromManageRen = ApexPages.currentPage().getParameters().get('frmMR');
        helpParam = CSM_Constants.HELP_CONSOLIDATE_OPPORTUNITY;
        currentOpptDisplayed = new Opportunity();
        newExistingOpp = new OpportunityLineItem();
        targetOppt = new Opportunity();
        this.parentId = ApexPages.currentPage().getParameters().get('parentId');
        shouldRemoveSyncQuoteIdOnOpp = ApexPages.currentPage().getParameters().get('rSyncQuote') == 'y';
        init();
        String opptyIdsString = ApexPages.currentPage().getParameters().get('opptyIds');
        if(String.isNotBlank(opptyIdsString)){
            opptyIdList = opptyIdsString.split('-');
        }
    }
    
    private void init()
    {
    	ssValidationsGlobal = SS_Validations__c.getOrgDefaults();
        isQuoteEnabled = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId');
        isSyncQuoteEnabledOnAnySelectedTargetOpp=false;
        
        stagesNotAllowed = new Set<String>();
        if ( ssValidationsGlobal != null &&  String.isNotEmpty(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c))
        {
            stagesNotAllowed = REN_Util.convertCSVtoSet(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c, ',');
        }
        
        oliFieldSetMemberList =  SObjectType.OpportunityLineItem.FieldSets.REN_Product_Line_Items_on_Split.getFields();  
        oliDefaultFieldsSet = new Set<String>();
        oliFieldsSetForQuery = REN_Util.getFieldNameSetFromFieldSet(oliFieldSetMemberList, oliDefaultFieldsSet);
        
        determineButtonLabel();
        
        Set<String> oppFieldSet = new Set<String>{'Pricebook2Id','AccountId','OwnerId'};
        
        if(UserInfo.isMultiCurrencyOrganization()) 
        {
        	oppFieldSet.add(REN_Constants.REN_CURRENCY_ISO_CODE);
        	oliFieldsSetForQuery.add(REN_Constants.REN_CURRENCY_ISO_CODE);
        }
        consolidateOpps = REN_OpportunityDataAccess.getFilteredRecordsList(
                'Opportunity', oppFieldSet, oppIdSet, 
                null, null ,null);
        populatePreDetermines();
    }
    
    private void populatePreDetermines()
    {
    	
    	Set<String> accountSet = new Set<String>();
    	String sameAccount = '';
    	
    	Set<String> ownerSet = new Set<String>();
    	String sameOwner = '';
    	
    	for(Opportunity opp: consolidateOpps){
			accountSet.add(opp.AccountId);
			sameAccount = opp.AccountId;
			ownerSet.add(opp.OwnerId);
			sameOwner = opp.OwnerId;
		}
		if (accountSet.size() == 1)
		{
			preDeterminedAccount = sameAccount;
		}
		if (ownerSet.size() == 1)
		{
			preDeterminedOwner = sameOwner;
    	}
		else
		{
			preDeterminedOwner = UserInfo.getUserId();
		}
    }
    
    private void determineButtonLabel()
    {
        isRequest = false;
        consolidateRecordLimit = 100;
        CSM_Admin__c adminCustomSetting = CSM_AdminDataAccess.getCSMAdminInstance();
        
        if (adminCustomSetting != null 
            && adminCustomSetting.REN_Consolidate_Real_Oli_Thresh__c != null)
        {
            consolidateRecordLimit = (Integer)adminCustomSetting.REN_Consolidate_Real_Oli_Thresh__c;
        }
        
        consButtonLabel = Label.LBL_CONSOLIDATE_OPPORTUNITY;
        
        String stringOpptyIds = ApexPages.currentPage().getParameters().get('opptyIds');
        if(String.isNotBlank(stringOpptyIds)){
            List<Id> oppIdList = stringOpptyIds.split('-');
            oppIdSet = new Set<Id>();
            oppIdSet.addAll(oppIdList);
            set<string> rrDefaultFieldsSet = new Set<String>{'id'};
        
           	List<REN_Renews_To__c> lstSelectedRLI=REN_RenewRelationshipDataAccess.getRenewalRelationshipByOpportunityIds(oppIdSet,new Set<string>{'ID'},rrDefaultFieldsSet,consolidateRecordLimit+1);
            if (lstSelectedRLI.size() > consolidateRecordLimit){
                isRequest = true;
                consButtonLabel = Label.LBL_REQUEST_CONSOLIDATION;
            }
        }
    }
    
    public List<SelectOption> getOpptTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(OpportunityType.NONE.name(), Label.CSM_VAL_NONE));
        options.add(new SelectOption(OpportunityType.NEW_OPP.name(), Label.CSM_LBL_NEW_OPPORTUNITY));
        if(isFromManageRen == 'y'){
        	options.add(new SelectOption(OpportunityType.CLONE.name(), Label.REN_LBL_NEW_CLONED_OPPTY));
        }
        options.add(new SelectOption(OpportunityType.EXISTING.name(), Label.REN_LBL_EXISTING_OPPORTUNITY));  
        return options;
    }
    
    public PageReference processOpptTypeChange()
    {
        hasSyncedPO = false;
        try{
            if(selectedOpptType == OpportunityType.EXISTING.name())
            {
                showAsInput = false;
                showOpptPicker = true;
                showTarget = false;
                if(newExistingOpp.OpportunityId != null && targetOppt != null)
                {
                    showTarget = true;
                }
            }
            else if(selectedOpptType == OpportunityType.NEW_OPP.name())
            {
                newExistingOpp.OpportunityId = null;
                showAsInput = true;
                showOpptPicker = false;
                showTarget = true;
            }
            else if(selectedOpptType == OpportunityType.NONE.name())
            {
                newExistingOpp.OpportunityId = null;
                showAsInput = false;
                showOpptPicker = false;
                showTarget = false;
            }
            else if(selectedOpptType == OpportunityType.CLONE.name())
            {
                newExistingOpp.OpportunityId = null;
                showAsInput = true;
                showOpptPicker = false;
                showTarget = true;
            }
            currentOpptDisplayed = returnTargetOpportunity(selectedOpptType);
            
            if (selectedOpptType == OpportunityType.NEW_OPP.name())
            {
            	if (preDeterminedAccount != null)
                {
                	currentOpptDisplayed.AccountId = preDeterminedAccount;
                }
                currentOpptDisplayed.OwnerId = preDeterminedOwner;
                currentOpptDisplayed.StageName = REN_Constants.OBJ_OPPSTAGE_NOT_CONTACTED;
            }
 
        }catch(Exception e){
            system.debug('\n\n~~~~Error:' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    private boolean showExistMessage()
    {
    	boolean doesTheOppExist = false;
    	boolean displayMessage = false;
    	for (Integer i = 0; i < consolidateOpps.size(); i++)
    	{
    	    Opportunity opp = consolidateOpps.get(i);
    		if (opp.Id == targetOppt.Id)
        	{
    		    doesTheOppExist = true;
    			break;
    		}
    	}
    	if (doesTheOppExist)
    	{
    		displayMessage = true;
    	}
    	return displayMessage;
    }
    
    
    public PageReference opportunityPicked()
   {
        try{
            set<String> setFieldsRequested = REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Split Edit');
            setFieldsRequested.addAll(REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Read Only'));
            setFieldsRequested.add('REN_Is_Consolidated__c');
            setFieldsRequested.add('IsClosed');
            setFieldsRequested.add('Pricebook2Id');
            setFieldsRequested.add('Probability');
            setFieldsRequested.add('CHL_QuoteSyncStatus__c');
            setFieldsRequested.add('REN_Renewal_Metrics_Status__c');
            
            Boolean recordTypeExists = CSM_Util.getRecordTypeExists(new Opportunity());
	        if (recordTypeExists)
	        {
	            setFieldsRequested.add('RecordTypeId');
	        }
            if(isQuoteEnabled)
            {
                setFieldsRequested.add('SyncedQuoteId');
            }
			if(UserInfo.isMultiCurrencyOrganization()) 
			{
			    setFieldsRequested.add(REN_Constants.REN_CURRENCY_ISO_CODE);
			}
			
			targetOppt = REN_OpportunityDataAccess.getOpportunityById(String.valueOf(newExistingOpp.OpportunityId), setFieldsRequested);
			if(String.isNotBlank(String.valueOf(targetOppt.get('SyncedQuoteId')))){
		        	isSyncQuoteEnabledOnAnySelectedTargetOpp=true;
		    }
			if(recordTypeExists && (String)targetOppt.get('RecordTypeId') != (String) consolidateOpps[0].get('RecordTypeId'))
			{
			    showTarget = false;
		    	ApexPages.Message pricebookMismatchErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_MSG_OPP_MATCHING_RECORD_TYPES);
			        ApexPages.addMessage(pricebookMismatchErrMsg);
			}
            
            else if((String)targetOppt.get('Pricebook2Id') != consolidateOpps[0].Pricebook2Id)
            { 
                showTarget = false;
            	ApexPages.Message pricebookMismatchErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_PB_ERROR_MSG);
                   ApexPages.addMessage(pricebookMismatchErrMsg);   
            }
            
            else if(UserInfo.isMultiCurrencyOrganization() && (String)targetOppt.get(REN_Constants.REN_CURRENCY_ISO_CODE) 
                != (String) consolidateOpps[0].get(REN_Constants.REN_CURRENCY_ISO_CODE))
            {
           	    showTarget = false;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
					    System.label.REN_LBL_CURRENCY_ERROR_MSG)); 
            }
            
            /*else if (targetOppt.get('REN_Is_Consolidated__c') != null & (Boolean)targetOppt.get('REN_Is_Consolidated__c'))
            {
                showTarget = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(
                   System.Label.REN_LBL_CONSOIDATED_MSG, new String[] {(String)targetOppt.get('Name')})));
            }*/
            else if (!stagesNotAllowed.isEmpty() && stagesNotAllowed.contains((String)targetOppt.get('StageName')))
            {
                showTarget = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(
                    System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_CONSOLIDATE, new String[] {(String)targetOppt.get('StageName')})));
            }
            else if (targetOppt.get('IsClosed') != null && Boolean.valueOf(targetOppt.get('IsClosed')))
			{
				showTarget = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				    Label.REN_MSG_CLOSED_OPP_CONS));
		    }
		    else if (showExistMessage())
		    {
		    	showTarget = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				    Label.REN_MSG_PREVENT_SAME_SOURCE_TARGET_CONSOLIDATE_LISTVIEW));
		    }
		    else if((targetOppt.CHL_QuoteSyncStatus__c != null && targetOppt.CHL_QuoteSyncStatus__c != 'None') 
		    		|| (targetOppt.REN_Renewal_Metrics_Status__c != null && targetOppt.REN_Renewal_Metrics_Status__c != 'Calculated')){
		    	showTarget = false;
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				    Label.REN_PREVENT_CONSOLIDATE_IF_BATCHES_RUNNING));
	        }
            else 
            {
	            showTarget = true;
	            currentOpptDisplayed = targetOppt;
            }
            list<CHL_Partner_Opportunity__c> poList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunity (new set<Id>{targetOppt.id});
	        hasSyncedPO = poList != null && !poList.isEmpty() ? true : false;
        }
        catch(Exception e)
        {
            system.debug('\n\n~~~~Error:' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    public PageReference cancel() {
        PageReference pageRef;
        String returnPageName = ApexPages.currentPage().getParameters().get('retURL');
        if(String.isNotBlank(returnPageName) ){
        	pageRef = new PageReference(returnPageName);
			pageRef.setRedirect(true);
        } else if(String.isNotBlank(this.parentId)){
            pageRef = new PageReference('/' + this.parentId);
        }else if(opptyIdList != null && !opptyIdList.isEmpty() && opptyIdList.size() ==  1 && isFromManageRen == 'y'){
        	pageRef = new PageReference('/apex/ren_renewalrelationshipbulkedit?OpptId='+opptyIdList[0]);
        }
        else{
            pageRef = new PageReference('/'+CSM_Constants.OPPTY_PREFIX);
        }
        return pageRef;
    }
    
    public PageReference returnCorrectPage(Id consOpportunityId) {
        PageReference pageRef = new PageReference('/' + consOpportunityId);
        return pageRef;
    }
    
    public PageReference consolidateOpps()
    {
        return null;
    }
    
    public PageReference redirectAfterConsolidation(){
        PageReference pr;
        if(String.isNotBlank(this.parentId)){
            pr = new PageReference('/' + this.parentId);
        }else if(isFromManageRen == 'y'){
        	pr = new PageReference('/' + targetOppt.Id);
        }
        else{
            pr = new PageReference('/006');
        }
        return pr;
    }
    public PageReference requestConsolidation()
    {
    	Savepoint sp = Database.setSavepoint();
    	System.debug('\n~~~~~~~: 2');
    	isErrorReported = 'false';
        try
        {
        	CSM_TriggerManager.disableAllTriggers();
            if (selectedOpptType == OpportunityType.EXISTING.name()){
            	if (oppIdSet.contains(targetOppt.Id)){
            		oppIdSet.remove(targetOppt.Id);
            	}
            }
            else{
                targetOppt = currentOpptDisplayed;   
            }
            SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();
            if(String.valueOf(REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',')).contains(targetOppt.StageName) || targetOppt.StageName == 'No Service'){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_CONSOLIDATE, new String[] {targetOppt.StageName}));
                ApexPages.addMessage(errMsg);
                isErrorReported = 'true';
                return null;
            }
            
            List<Opportunity> oppListForUpsert = new List<Opportunity>();
            List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunitiesByIds(oppIdSet);
            if(UserInfo.isMultiCurrencyOrganization()){
				if(!oppList.isEmpty()){
					targetOppt.put(REN_Constants.REN_CURRENCY_ISO_CODE,oppList[0].get(REN_Constants.REN_CURRENCY_ISO_CODE));
				}
			}
			
			//Added to handle RR before update trigger functionality - US3280 & US3281
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
			Boolean isRenewalChecked = CSM_Admin__c.getOrgDefaults().REN_Set_New_Opportunity_as_Renewal__c;
			String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn; 
            Boolean hasOppNameField = CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c');
            
            if(hasRenewAccess && isRenewalChecked){
				targetOppt.REN_Is_CLM_Renewal__c = true;
			}
            
	        if(hasOppNameField){
	        	targetOppt.put('Opportunity_Name__c',targetOppt.Name);
	        }
			
            oppListForUpsert.add(targetOppt);
            CSM_OpportunityDataAccess.upsertOpportunityList(oppListForUpsert);
	        
            REN_Consolidation_Request__c consRequest = new REN_Consolidation_Request__c();
            consRequest.REN_Target_Opportunity__c = targetOppt.Id;
            List<String> fieldList = new List<String>{'REN_Target_Opportunity__c'};
            REN_ConsolidationRequestDataAccess.insertConsolidationRequest(
                new List<REN_Consolidation_Request__c>{consRequest}, fieldList);
            
            List<REN_Consolidation_Request_Source__c> consReqSourceList 
                = new List<REN_Consolidation_Request_Source__c>();
            
            Boolean chatterIsEnabled = REN_ChatterUtil.isChatterEnabled();
            List<sObject> chatterFeedItems = new List<sObject>();
            
            for (Opportunity opp: oppList){
            	REN_Consolidation_Request_Source__c reqSource = new REN_Consolidation_Request_Source__c();
                reqSource.REN_Consolidation_Request__c = consRequest.Id;
                reqSource.REN_Source_Opportunity__c = opp.id;
                consReqSourceList.add(reqSource);
               // Consolidation has been requested on this Opportunity at <time> by <User's Name with link>. It will be Consolidated into <Name of Target Opportunity with link>
                if (chatterIsEnabled)
                {
                    String postMsg = String.format(Label.REN_MSG_CHATTER_CONS_REQ, 
                            new String[]{String.valueOf(System.now()), UserInfo.getName(), targetOppt.Name});
                    chatterFeedItems.add(REN_ChatterUtil.addChatterMessage(opp.Id, postMsg, null));
                }
                
                
            }
            fieldList = new List<String>{'REN_Source_Opportunity__c','REN_Number_of_RLIs__c','REN_Number_of_OLIs__c'};
            REN_ConsolidationRequestDataAccess.insertConsolidationRequestSource(consReqSourceList,fieldList);
            if (!chatterFeedItems.isEmpty())
            {
            	REN_ChatterUtil.saveChatterMessages(chatterFeedItems);
            }
            if(consReqSourceList != null && !consReqSourceList.isEmpty()){
            	Database.executeBatch(new REN_ConsolidateOpportunityBatch(),1);
            }
        }
        catch(Exception e)
        {
        	Database.rollback(sp);
            targetOppt.Id = null;
            ApexPages.Message genericErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(genericErrMsg);
            //pr = null;
        }
        
        isErrorReported = ApexPages.hasMessages() + '';
        System.debug(ApexPages.getMessages() +'\n~~~~~~~3 isErrorReported: ' + isErrorReported);
        return null;
    }
    
    public PageReference consolidateRealTime()
    {
        PageReference pr;
        //REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = false;
        
        Savepoint sp = Database.setSavepoint();
        try
        {
        	CSM_TriggerManager.disableAllTriggers();
        	
        	if(selectedOpptType != OpportunityType.EXISTING.name()){
                targetOppt = currentOpptDisplayed;             
            	for (Integer i = 0; i < consolidateOpps.size(); i++){
    	    		Opportunity opp = consolidateOpps.get(i);
    				if (opp.Id == targetOppt.Id)
        			{
    					consolidateOpps.remove(i);
    					break;
    				}
    			}
            }
            Map<String, Id> sourceToTargetOpptyMap = new Map<String, Id>();
            Map<String, String> sourceToTargetOpptyNameMap = new Map<String, String>();
            for(Opportunity sourceOpp: consolidateOpps)
            {
            	if (selectedOpptType == OpportunityType.EXISTING.name() 
            	        &&  sourceOpp.Id == targetOppt.Id){
            		//Do not consolidate an opportunity if it is the same as the existing
            		continue; 
            	}else{
                    sourceToTargetOpptyMap.put(sourceOpp.Id, targetOppt.Id);
                    sourceToTargetOpptyNameMap.put(sourceOpp.Id, targetOppt.Name);
            	}
            }       
   
   			String ErrorMsg='';
    	   //call to common method for consolidation
    	   
        	ErrorMsg=REN_ConsolidateHandler.finalConsolidation(null,null, REN_Constants.STR_CONSOLIDATE, consolidateOpps, targetOppt);
            if(String.isNotBlank(ErrorMsg)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ErrorMsg));
				Database.rollback(sp);
				return null;
			} else {
				CHL_ManageSplitConsolidatePRR.handlePRRSplitAndConsolidate(null, consolidateOpps, targetOppt, REN_Constants.STR_CONSOLIDATE);
				for(Opportunity sourceOpp: consolidateOpps)
	            {
	            	if (sourceToTargetOpptyMap.containsKey(sourceOpp.Id) && sourceToTargetOpptyMap.get(sourceOpp.Id) == null){
	            		sourceToTargetOpptyMap.put(sourceOpp.Id, targetOppt.Id);
	            	}
	            } 
				// Added code to create chatter feed on creation of 
            	REN_ConsolidateHandler.createChatterFeeds(sourceToTargetOpptyNameMap,sourceToTargetOpptyMap); 
			}
            pr = returnCorrectPage(targetOppt.Id);
            
        }   
            catch(Exception e)
        {
            system.debug('An exception occurred : ' + e.getMessage() + ' ' + e.getStackTraceString());
            Database.rollback(sp);
            targetOppt.Id = null;
            ApexPages.Message genericErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(genericErrMsg);
            pr = null;
        }
        return pr;
    }
    
    private Opportunity returnTargetOpportunity(String selectedOpptType)
    {
        targetOppt = new Opportunity();
        set<String> setFieldsRequested = REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Split Edit');
        setFieldsRequested.addAll(REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Read Only'));
        if(selectedOpptType == OpportunityType.CLONE.name() && opptyIdList != null && !opptyIdList.isEmpty())
    	{
			Opportunity tmpExising = REN_OpportunityDataAccess.getOpportunityById(opptyIdList[0], setFieldsRequested);
			targetOppt = tmpExising.clone(false, true);			
    	}
        return targetOppt;
    }
    
   private enum OpportunityType {NONE, NEW_OPP, EXISTING, CLONE}
}