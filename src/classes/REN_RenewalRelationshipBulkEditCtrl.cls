public with sharing class REN_RenewalRelationshipBulkEditCtrl {

    public String opptyId {get;set;}
    public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public String helpParam {get;set;}
    public String appendedIds{get; set;}
    public String productIds{get; set;}
    public String consolidateStr{get; set;}
    public String statusToUpdateTo{get; set;}
    public String hiddenColumns {get; set;}
    public CSM_User_Preferences__c preferenceObj{get; set;} 
    public CSM_DataGridAttribute renewalGridAttribute{get; set;} 
    public Opportunity sourceOpportunity {get;set;}
    private boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
    public SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance(); 
    
    public String disableConsolidate {get;set;}//Not in use need to delete.
    public boolean disableSplit {get;set;}//Not in use need to delete.

    public boolean disableRebuild {get;set;}
    public String hasQuote {get;set;}
    public boolean hasValidStageForSplit {get;set;}
    public boolean hasValidStageForConsolidate {get;set;}
    
    // Simplified data model flag
    public boolean isSimplifiedDataModelOn{get;set;}
    public boolean isRebuildValid{get;set;}
    public String isValidRli{get;set;}
    public List<Opportunity> oppToValidateRebuild;
    public String isSimplified{get;set;}
    public string hasSyncedPO{get;set;}
    public boolean isBatchRunning {get;set;}
    public String baseNamespace{get;set;}
    
    public REN_RenewalRelationshipBulkEditCtrl(ApexPages.StandardController stdController){
        try{
			baseNamespace = CSM_Util.getNamespace();
            //disableConsolidate =fetchValidationSettings.REN_Disable_Consolidate_Synced_Quote__c;
            isBatchRunning = false;
            disableRebuild = fetchValidationSettings.REN_Disable_Rebuild_with_Synced_Quote__c;
            opptyId = ApexPages.currentPage().getParameters().get('OpptId');

            // Code for simplefied data model goes here
            isRebuildValid= false;
            isValidRli = 'false';
            isSimplifiedDataModelOn = SS_Constants.isSimplifiedDataModelEnabled;
            oppToValidateRebuild = new List<Opportunity>();
            
            //Updated for DE2913
            //oppToValidateRebuild is the list of opptunities with master product
            oppToValidateRebuild = REN_RRSimplifiedTriggerHelper.getOpportuntyDetails(new set<Id>{opptyId});
            if(isSimplifiedDataModelOn && oppToValidateRebuild != null && oppToValidateRebuild.get(0).Renew_To__r.isEmpty()){
            	disableConsolidate = 'true';
            }
                
            if(isSimplifiedDataModelOn){          
                isSimplified = 'true';
                if(oppToValidateRebuild != null && !oppToValidateRebuild.get(0).Renew_To__r.isEmpty() && oppToValidateRebuild.get(0).OpportunityLineItems.isEmpty()){
                     isRebuildValid = true;
                }
            }else{
                isSimplified = 'false';
            }
            hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
            hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;  
            resetOpportunityInfo();
            preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'REN_Manage_RR_Grid_Columns__c');
            if(preferenceObj == null) {
                preferenceObj = new CSM_User_Preferences__c();
                preferenceObj.CSM_User__c = UserInfo.getUserId();
            }

            hasValidStageForSplit = !(REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',').contains(sourceOpportunity.StageName));
            hasValidStageForConsolidate = !(REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',').contains(sourceOpportunity.StageName));
          	if((sourceOpportunity.CHL_QuoteSyncStatus__c != null && sourceOpportunity.CHL_QuoteSyncStatus__c != 'None') 
          		|| (sourceOpportunity.REN_Renewal_Metrics_Status__c != null && sourceOpportunity.REN_Renewal_Metrics_Status__c != 'Calculated')){
          		isBatchRunning = true;
          	}
            setGridAttributes();
            
        }catch(Exception e){
            system.debug('Error : ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage()));
        }
    }
    
    private void resetOpportunityInfo()
    {
        //disableSplit = fetchValidationSettings.REN_Disable_Split_with_Synced_Quote__c;
        hasQuote = 'false';
        Set<String> oppFldSet = new Set<String>{'id', 'Name', 'PriceBook2Id', 'StageName','CHL_QuoteSyncStatus__c','REN_Renewal_Metrics_Status__c'};
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){
            oppFldSet.add('SyncedQuoteId');
        }
        if(isMultiCurrency){
            oppFldSet.add('CurrencyIsoCode');
        }
        sourceOpportunity = REN_OpportunityDataAccess.getOpportunityById(opptyId,oppFldSet);
        if(
            //disableSplit && 
            CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId') && String.isNotBlank(String.valueOf(sourceOpportunity.get('SyncedQuoteId')))
        ){
           hasQuote = 'true';
        } 
        list<CHL_Partner_Opportunity__c> poList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunity (new set<Id>{opptyId});
        hasSyncedPO = poList != null && !poList.isEmpty() ? 'true' : 'false'; 
    }
     
    public PageReference isValidRliForMove(){
    	return null;
    } 
    
    private void setGridAttributes()
    {                                
        renewalGridAttribute = new CSM_DataGridAttribute();        
        renewalGridAttribute.tableName = CSM_Constants.GRID_ATTR_RENEWAL_RELATIONSHIP_TABLE_NAME;
        renewalGridAttribute.objectType =CSM_Constants.GRID_ATTR_RENEWAL_RELATIONSHIP_OBJ_TYPE;
        renewalGridAttribute.viewName ='ManageRenewals';
        renewalGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
        renewalGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
        renewalGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
        renewalGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
        renewalGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        renewalGridAttribute.showExport=CSM_Constants.GRID_ATTR_TRUE;
        renewalGridAttribute.setFilterControl(CSM_Constants.GRID_ATTR_TRUE);
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
        gridInputParams.opptyId = opptyId;
        renewalGridAttribute.params = JSON.serialize(gridInputParams);
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
        renewalGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
    
    public PageReference changeStatus()
    {
        PageReference retPage = Page.REN_RenewalRelationshipBulkEdit;
        retPage.getParameters().put('OpptId', opptyId);
        retPage.setRedirect(true);
        
        List<REN_Renews_To__c> lstRenewalsToUpdateStatus = new List<REN_Renews_To__c>();  
        Set<String> renewalIds = new Set<String>();
        //Set savepoint
        Savepoint sp = Database.setSavepoint();
        try
        {
        	//Disable all triggers
        	CSM_triggerManager.disableAllTriggers();
            if(String.isNotBlank(appendedIds))
            {
                appendedIds = appendedIds.removeEnd('-');
                renewalIds = new Set<String>(appendedIds.split('-'));
                if(!renewalIds.isEmpty())
                {
                    lstRenewalsToUpdateStatus = REN_RenewRelationshipDataAccess.getRenewalRelationshipByIds(renewalIds);
                    for(REN_Renews_To__c r :lstRenewalsToUpdateStatus)
                    {
                        r.REN_Renewal_Status__c = statusToUpdateTo;
                    }
                    if(!lstRenewalsToUpdateStatus.isEmpty())
                    {
                        List<String> renewRelationFields = new List<String>{REN_Constants.OBJ_REN_RENEWS_TO_STATUS};
                        REN_RenewRelationshipDataAccess.updateRenewalRelationship(lstRenewalsToUpdateStatus,renewRelationFields);
                    }
                    if(opptyId != null){
            			List<Opportunity> impactedOpportunityList =  REN_RRSimplifiedTriggerHelper.getOpportuntyDetails(new Set<Id>{opptyId});
                    	if(statusToUpdateTo.startsWith('HA') || statusToUpdateTo.startsWith('NS')) {
                    		List<REN_Renews_To__c> rliListByOppty = REN_RenewRelationshipDataAccess.getLstRenRelationshipByOppSet(new Set<String>{opptyId});
                    		Integer counterForHA = 0, counterForNS = 0;
            				String opptyStage = '';
            				for(REN_Renews_To__c rliObj:rliListByOppty){
            					if((rliObj.REN_Renewal_Status__c).startsWith('HA')) {
            						counterForHA += 1;
            						opptyStage = 'House Account';
            					} else if((rliObj.REN_Renewal_Status__c).startsWith('NS')) {
            						counterForNS += 1;
            						opptyStage = 'No Service';
            					}
            				}
            				system.debug('rLIList :: '+rliListByOppty.size()+'haCount :: '+counterForHA+'naCount:: '+counterForNS);
            				if(String.isNotBlank(opptyStage) && ((counterForHA != 0 && counterForHA == rliListByOppty.size()) || (counterForNS != 0 && counterForNS == rliListByOppty.size()))) {
            					impactedOpportunityList[0].stageName = opptyStage;
            					String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
            					REN_OpportunityMetricsBusiness.setRliMetricsFieldsOnOpportunity(impactedOpportunityList);
            					SS_TriggerCollectionParameters.OpportunityTriggerParams opptyParams = new SS_TriggerCollectionParameters.OpportunityTriggerParams();
            					opptyParams.qualifiedIdSet = new Set<String>{impactedOpportunityList[0].Id};
            					opptyParams.triggerEvent = 'onAfterUpdate';
        						(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'OpportunityTriggerInvocationHandler', opptyParams);
            					retPage = new PageReference('/'+opptyId);
            				}
                    	}
                    	REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(impactedOpportunityList);
                    }
                }
            }
        }
        catch(Exception e)
        {
        	Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage());
            system.debug('ApexPages value : ' + ApexPages.getMessages() );
            ApexPages.addMessage(myMsg);
            retPage = null;
        }
        return retPage;
    }
    
    public PageReference rebuild(){
        PageReference pageRef = null;
        List<REN_Renews_To__c> lstRenewalsToRebuild = new List<REN_Renews_To__c>(); 
        Set<ID> productIdSet = new Set<ID>();
        Map<String, PricebookEntry> currencyProductPricebookEntryMap = new Map<String, PricebookEntry> ();
        Set<String> oppFldSet = null;
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){
            oppFldSet = new Set<String>{'id','PriceBook2Id', 'SyncedQuoteId'};
        }else{
            oppFldSet = new Set<String>{'id','PriceBook2Id'};
        }
        sourceOpportunity = REN_OpportunityDataAccess.getOpportunityById(opptyId,oppFldSet);
        if(disableRebuild && CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId') && String.isNotBlank(String.valueOf(sourceOpportunity.get('SyncedQuoteId')))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.REN_RR_SYNC_QUOTE_ERR_MSG, new String[] {})));
        }else{
            Savepoint sp = Database.setSavepoint();
            CSM_triggerManager.disableAllTriggers();
            try{
                if(String.isNotBlank(appendedIds) && isRebuildValid==false){
                    List <REN_Field_Mappings__c> fieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_REN_RENEWS_TO);
                    lstRenewalsToRebuild = getRenewalRelationships(appendedIds,fieldMappingList);
                    for(REN_Renews_To__c rr:lstRenewalsToRebuild){
                        productIdSet.add(rr.REN_Product__c);
                    }
                    Opportunity opp = sourceOpportunity; //REN_OpportunityDataAccess.getOpportunityById(opptyId,oppFldSet);
                    currencyProductPricebookEntryMap = getCrncyPrdctPbEntryMap(isMultiCurrency,opp,productIdSet);
                    List<OpportunityLineItem> oplLst = getOLILst(lstRenewalsToRebuild,currencyProductPricebookEntryMap,fieldMappingList,
                                                                opp,isMultiCurrency);
                    if(!oplLst.isEmpty()){
                        oplLst = REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(oplLst);
                        if(opptyId != null){
                    		REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(new Set<Id>{opptyId});
                    	}
                        pageRef = new PageReference('/' + opptyId);
                        pageRef.setRedirect(true);
                    }
                }else{
                    REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(new Set<Id>{opptyId});
                    pageRef = new PageReference('/' + opptyId);
                    pageRef.setRedirect(true);
                }
            }
            catch(Exception e)
            {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));
                pageRef = null;
            }
        }
        return pageRef;
    }
    
    private List<OpportunityLineItem> getOLILst(List<REN_Renews_To__c> lstRenewalsToRebuild,Map<String, PricebookEntry> currencyProductPricebookEntryMap,
                                                List<REN_Field_Mappings__c> fieldMappingList,Opportunity opp,Boolean isMultiCurrency){
        Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(OpportunityLineItem.sObjectType);
        List<OpportunityLineItem> oplLst = new List<OpportunityLineItem>();
        OpportunityLineItem opli;
        for(REN_Renews_To__c rr:lstRenewalsToRebuild){
            opli = new OpportunityLineItem();
            opli = (OpportunityLineItem)REN_Util.copyObjectUsingAdminMapping(rr, opli, opptLineAllFieldNames, fieldMappingList);
            opli.OpportunityId = rr.REN_Renews_To__c;
            //opli.REN_Original_Line_Item_ID__c = rr.REN_Original_Line_Item_ID__c;
            opli.REN_Renewable_Line_Item__c = rr.Id;
            opli.REN_Is_CLM_Renewal__c = true;
            String key = isMultiCurrency? opp.get('CurrencyIsoCode') + '' + rr.REN_Product__c : rr.REN_Product__c;
            if(currencyProductPricebookEntryMap.containsKey(key)){
                opli.PricebookEntryId = currencyProductPricebookEntryMap.get(key).id;
            }
            oplLst.add(opli);
        }
        return oplLst;
    }
    
    private Map<String, PricebookEntry> getCrncyPrdctPbEntryMap(Boolean isMultiCurrency,Opportunity opp,Set<ID> productIdSet){
        Map<String, PricebookEntry> currencyProductPricebookEntryMap = new Map<String, PricebookEntry> ();
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        
        String recordCurrencyCode = CSM_Util.getRecordLevelCurrency(opp,false);
        priceBookEntryList = REN_PricebookDataAccess.getProductToPbEntry(opp.PriceBook2Id,productIdSet,recordCurrencyCode);
        for(PricebookEntry bookEntry : (List<PricebookEntry>)priceBookEntryList){
            String key = isMultiCurrency? bookEntry.get('CurrencyIsoCode') + ''+ bookEntry.product2Id : bookEntry.product2Id;
            currencyProductPricebookEntryMap.put(key, bookEntry);
         }
       return currencyProductPricebookEntryMap;
    }
    
    private List<REN_Renews_To__c> getRenewalRelationships(String appendedIds,List<REN_Field_Mappings__c> fieldMappingList){
        Set<String> fldSet = new Set<String>();
        List<REN_Renews_To__c> lstRenewalsToRebuild = new List<REN_Renews_To__c>();
        Set<String> renewalIds = new Set<String>();
        appendedIds = appendedIds.removeEnd('-');
        renewalIds = new Set<String>(appendedIds.split('-'));
        REN_Util.getFromAndToFldsToQuery(fieldMappingList,fldSet,null);
        fldSet.add('REN_Product__c');
        fldSet.add('REN_Renews_To__c');
        //fldSet.add('REN_Original_Line_Item_ID__c');
        lstRenewalsToRebuild = REN_RenewRelationshipDataAccess.getRenewalRelationshipByIds(fldSet,renewalIds);
        return lstRenewalsToRebuild;
    }
    
    public Map<String, String> getRRStatusOptions(){  		
       return CHL_Util.getPicklistValuesMap(REN_Renews_To__c.REN_Renewal_Status__c.getDescribe());
   	}
       
    public PageReference cancel(){
        PageReference retPage = new PageReference('/' + opptyId);
        retPage.setRedirect(true);
        return retPage;
    }
        
    public PageReference saveRRColumnsToUserPreference(){
        try {
            preferenceObj.REN_Manage_RR_Grid_Columns__c = hiddenColumns;
            List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
            userPreferenceList.add(preferenceObj);
            CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'REN_Manage_RR_Grid_Columns__c,CSM_User__c');
        }catch (exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
        return null;
    }
    
    public PageReference validateSplit()
    {
        if(!hasValidStageForSplit)
        {      
            return validateOppStageForSplit();
        }
        else if(isBatchRunning){
        	return preventSplitIfBatchRunning();
        }
        else{
        	resetOpportunityInfo();
    		return null;
        }
    }
    
    public PageReference validateConsolidate()
    {
        if(!hasValidStageForConsolidate)
        {
            return validateOppStageForConsolidate();
        }
        else if(isBatchRunning){
        	return preventConsolidateIfBatchRunning();
        }
        else{
            return validateQuoteSync();
        }
    }
    
  public PageReference validateQuoteSync(){
  		PageReference pageRef = null;
        resetOpportunityInfo();
     	if (String.isNotEmpty(consolidateStr) && consolidateStr == 'true'){
       		pageRef = Page.REN_ConsolidateOpportunity;
     		pageRef.getParameters().put('opptyIds', opptyId);
 		    pageRef.getParameters().put('rSyncQuote', 'y');//Remove SyncQuote from Opportunity
 		    pageRef.getParameters().put('frmMR', 'y'); 
     		pageRef.setRedirect(true);
     	}
        return pageRef;
    }

    public PageReference validateOppStageForSplit(){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_SPLIT, new String[] {sourceOpportunity.StageName})));
       return null;
    }

    public PageReference validateOppStageForConsolidate(){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_CONSOLIDATE, new String[] {sourceOpportunity.StageName})));
       return null;
    }
    
    public PageReference preventSplitIfBatchRunning(){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.Label.REN_PREVENT_SPLIT_IF_BATCHES_RUNNING));
       return null;
    }
    
    public PageReference preventConsolidateIfBatchRunning(){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.Label.REN_PREVENT_CONSOLIDATE_IF_BATCHES_RUNNING));
       return null;
    }

}