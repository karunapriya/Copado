public with sharing class REN_CreateOpptyFromAssetsController {

	public boolean hasRenewAccess {get; private set;}
	public List<REN_OpptLineWrapper> opliWrapperList{get;set;} 
	public Opportunity renewOpportunity{get;set;}
	private List<Asset> assetList;
	private Map<Id, OpportunityLineItem> assetToOpliMap;
	public string recordCurrencyCode{get;set;}
    public String parentId{get;set;}
    List<REN_Field_Mappings__c> asset2OliFieldMappings = new List<REN_Field_Mappings__c>();
    Map<String, Schema.SobjectField> opptLineAllFieldNames = new   Map<String, Schema.SobjectField>();

	
	public REN_CreateOpptyFromAssetsController(){
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        this.parentId = ApexPages.currentPage().getParameters().get('parentId');
        this.init();
	}
   
    private void init(){
    	try {
			String assetIds = ApexPages.currentPage().getParameters().get('assetIds');
			if(String.isNotBlank(assetIds)){
				this.renewOpportunity = new Opportunity();
				List<String> assetIdList = assetIds.split('-');
				String mappingName = REN_Constants.FLD_MAP_OPPT_LINE_TO_ASSET;			
				asset2OliFieldMappings = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
															mappingName,
															REN_Constants.OBJ_OPPTY_LINE_ITEM,
															REN_Constants.OBJ_ASSET);
				List<REN_Field_Mappings__c> asset2OFieldMappings = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
															mappingName,
															REN_Constants.OBJ_OPPORTUNITY,
															REN_Constants.OBJ_ASSET);
				opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(OpportunityLineItem.sObjectType);
				
				Set<String> fieldSet = REN_Util.getFromFldsToQuery(asset2OliFieldMappings);
				fieldSet.addAll(REN_Util.getFromFldsToQuery(asset2OFieldMappings));
				if(UserInfo.isMultiCurrencyOrganization()){
					fieldSet.add(REN_Constants.REN_CURRENCY_ISO_CODE);
				}
				this.assetList = REN_AssetDataAccess.getAssetDetailsById(assetIdList, fieldSet);
				Map<String, Schema.SobjectField> oppFieldDefinition = CSM_AccessController.fetchAllFieldNames(new Opportunity().getSobjectType());
				REN_Util.copyObjectUsingAdminMapping(this.assetList[0], 
				                                     this.renewOpportunity, 
				                                     oppFieldDefinition, 
				                                     asset2OFieldMappings);
				this.populateOpliWrapperList(opptLineAllFieldNames, asset2OliFieldMappings);
				CSM_Util.setAppliedCurrency(this.renewOpportunity, CSM_Util.getAppliedCurrency(this.assetList[0]));//US452 
			    SObject thisAsset = this.assetList[0];
			    recordCurrencyCode = CSM_Util.getRecordLevelCurrency(thisAsset,false);
			}
    	} catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
	}
	
	private void populateOpliWrapperList(Map<String, Schema.SobjectField> opptLineAllFieldNames, 
										List<REN_Field_Mappings__c> fMappingList){
		this.assetToOpliMap = new Map<Id, OpportunityLineItem>();
		this.opliWrapperList = new List<REN_OpptLineWrapper>();
		for(Integer i=0; i<this.assetList.size(); i++){
			Asset asset = assetList.get(i);
			REN_OpptLineWrapper opliWrapper = new REN_OpptLineWrapper();
			OpportunityLineItem opli = new OpportunityLineItem();
			opliWrapper.opLine = opli;
			opliWrapper.customId = i;
			opliWrapper.product2Id = asset.Product2Id;
			this.assetToOpliMap.put(asset.Id, opli);
			opliWrapper.opportunityProduct = asset.Product2.Name;
			opli.REN_Covered_Asset__c = asset.REN_Covered_Asset__c;//US605
	        REN_ContractLineItemRenewalLogicHandler.copyObjectUsingAdminMapping(asset, opli, opptLineAllFieldNames, fMappingList);
	        opliWrapper.opLine.REN_Is_CLM_Renewal__c = true;
	        if(opliWrapper.opLine.UnitPrice != null)
	        {
	        	opliWrapper.opLine.TotalPrice = null;
	        }
	        this.opliWrapperList.add(opliWrapper);
		}
	}
	
	public PageReference save() {
		REN_CONSTANTS.IS_AUTO_REBUILD = false;
        PageReference page;
        Savepoint spBeforeOpptCreate = Database.setSavepoint();
        try {
        	CSM_TriggerManager.disableAllTriggers();
        	if(opliWrapperList == null || opliWrapperList.isEmpty()){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.REN_NO_RESULT_FOUND));//Need to create Custom Label.
        	}else{
	        	this.renewOpportunity.REN_Is_CLM_Renewal__c = true;
	        	if(CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c')){
					this.renewOpportunity.put('Opportunity_Name__c',this.renewOpportunity.Name);
				}
	            List <Opportunity> opportunityList = CSM_OpportunityDataAccess.insertRenewalOpportunity(new List<Opportunity>{this.renewOpportunity});
	            CSM_TriggerManager.TriggerHandler triggerHandler = new CSM_OpportunityTriggerHandler();
	            triggerHandler.onAfterInsert(opportunityList, new Map<Id, Opportunity>(opportunityList));
	            this.saveOpli();
	            this.createRenewsToRecords();
	            REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(opportunityList);	            
	            page = new PageReference('/' + this.renewOpportunity.Id);
        	}
        } catch (Exception ex) {
        	this.renewOpportunity.Id = null;
            Database.rollback(spBeforeOpptCreate); 
            if(opptLineAllFieldNames != null && asset2OliFieldMappings != null){
            	this.populateOpliWrapperList(opptLineAllFieldNames, asset2OliFieldMappings);	
            }                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
        return page;
    }
    
	public PageReference cancel() {
    	PageReference pageRef;
    	if(String.isNotBlank(this.parentId)){
    		pageRef = new PageReference('/' + this.parentId);
    	}else{
    		pageRef = new PageReference('/02i');
    	}
        return pageRef;
    }
    
	private Map<Id, PricebookEntry> getProdToPbEntryMap(){
		Set<Id> assetProductIds = new Set<Id>();
		Id localPricbook2ID = this.renewOpportunity.Pricebook2Id;
		for(Asset asset : this.assetList){
			assetProductIds.add(asset.Product2Id);	
		}
		List<PricebookEntry> pbEntryList =REN_PricebookDataAccess.getProductToPbEntry(localPricbook2ID,assetProductIds,recordCurrencyCode); //Database.query(queryString);
		system.debug('$$ LIST : = '+pbEntryList+UserInfo.getDefaultCurrency()+recordCurrencyCode);
		Map<Id, PricebookEntry> prodToPbEntryMap = new Map<Id, PricebookEntry>();
		for(PricebookEntry pbEntry : pbEntryList){
			prodToPbEntryMap.put(pbEntry.Product2Id, pbEntry);
		}
		return prodToPbEntryMap;
	}
    
    private void saveOpli(){
    	List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
    	Map<Id, PricebookEntry> prodToPbEntryMap = this.getProdToPbEntryMap();
        for (REN_OpptLineWrapper olW: this.opliWrapperList) {
            olW.opLine.OpportunityId = this.renewOpportunity.Id;
            PricebookEntry pbEntry = prodToPbEntryMap.get(olW.product2Id);
            if(pbEntry == null){
            	throw new PricebookEntryException(String.format(system.label.REN_LBL_PBENTRY_MSG, new String[]{olW.opportunityProduct})); 
            }else{
	            olW.opLine.PricebookEntryId = pbEntry.Id;
	            oliListToInsert.add(olW.opLine);
            }
        }
        List<OpportunityLineItem> opplineItems;
        if(!oliListToInsert.isEmpty()){
	        opplineItems = REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(oliListToInsert);
        }       
        List<REN_Field_Mappings__c> lstOliToRrFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_LINE_TO_RR);
		Set<String> additionalFieldSet =new Set<String>{'OpportunityId','REN_Source_Opportunity_Line_Item_Id__c', 'Product2Id', 'REN_Start_Date__c', 'REN_End_Date__c','Quantity','REN_Covered_Asset__c'};
        REN_Util.getFromAndToFldsToQuery(lstOliToRrFldMappings,additionalFieldSet,null);
		Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>(opplineItems);
        List<OpportunityLineItem> renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItemMap.keySet(), additionalFieldSet);
        Map<Id, OpportunityLineItem> oliDetailedMap = new Map<Id, OpportunityLineItem>(renewedOppLineItemList);
		for(ID assetId: assetToOpliMap.keySet()){
			assetToOpliMap.put(assetId, oliDetailedMap.get(assetToOpliMap.get(assetId).id));
		}
    }
    
    private void createRenewsToRecords(){
    	List<REN_Renews_To__c> renewsToList = new List<REN_Renews_To__c>();
    	List <REN_Field_Mappings__c> fieldMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM);
        Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(REN_Renews_To__c.sObjectType);
        Map<ID, Asset> assetIdMap = new Map<ID, Asset>(this.assetList);
    	Map<Id, REN_Renews_To__c> assetRLIMap = new Map<Id, REN_Renews_To__c>();
    	for(ID assetID :assetToOpliMap.keySet()){
    		REN_Renews_To__c renewsTo = new REN_Renews_To__c();
    		OpportunityLineItem oli = assetToOpliMap.get(assetID);
    		if(oli == null){
    			continue;
    		}
    		sObject sobjRR = REN_Util.copyObjectUsingAdminMapping(oli, renewsTo, opptLineAllFieldNames, fieldMappingLst);
    		CSM_Util.setAppliedCurrency(renewsTo, CSM_Util.getAppliedCurrency(assetIdMap.get(assetID)));//US452 
    		renewsTo.REN_Asset__c = assetID;
    		renewsTo.REN_Renews_To__c = oli.OpportunityId;
    		renewsTo.REN_Product__c = assetIdMap.get(assetID).Product2Id;	
    		renewsTo.REN_Quantity__c = oli.Quantity;	
    		if(renewsTo.REN_Asset__c != null){
    			renewsToList.add(renewsTo);
    			assetRLIMap.put(assetID, renewsTo);
    		}
    	} 
    	   
    	if(!renewsToList.isEmpty()){
			REN_RRSimplifiedTriggerHelper.processRliRecords(renewsToList);
			Set<String> fieldsSet = new Set<String>{REN_Constants.OBJ_REN_RENEWS_TO_ASSET, 
                                                            REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO,
                                                            'REN_Quantity__c',
                                                            'REN_Renewal_Status__c','REN_Previous_Price__c',
                                                            'REN_Renewal_Target_Multiplier__c','REN_Renewal_Target__c'
                                                           };
			REN_Util.getFromAndToFldsToQuery(fieldMappingLst,null,fieldsSet);
	    	REN_RenewRelationshipDataAccess.insertRLI(renewsToList,new List<String>(fieldsSet));
	    	updateOLIRecords(assetRLIMap, assetToOpliMap);
    	}
    }
    
    /* US3467 : This method is used populate new relationship field 'Renewable Line Item' on OLI with the corresponding RLI*/
    private void updateOLIRecords(Map<Id, REN_Renews_To__c> assetRLIMap, Map<Id, OpportunityLineItem> assetToOliMap){
    	List<OpportunityLineItem> oliListToUpdate = new List<OpportunityLineItem>();
    	system.debug('@@@ test');
    	for(ID assetID :assetToOliMap.keySet()){
	    	OpportunityLineItem oli = assetToOliMap.get(assetID);
	    	if(oli != null && assetRLIMap.containsKey(assetID)){
	    		REN_Renews_To__c renewsTo = assetRLIMap.get(assetID);
	    		oliListToUpdate.add(new OpportunityLineItem(id = oli.id, REN_Renewable_Line_Item__c = renewsTo.id));
	    	}
    	}
        REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliListToUpdate, new Set<String>{'REN_Renewable_Line_Item__c'});
    }
    
    
    public with sharing class PricebookEntryException extends Exception {}
}