public with sharing class REN_OpportunityLineItemRenewalHandler {

	/** @This method is used for OLI trigger to bypass metrics calculation for Data Service user
	*/
	public static void oliAfterTriggerEvent(Set<Id> oppIdsSet){
		CSM_TriggerEnablement__c triggerEnablement = CSM_TriggerEnablement__c.getOrgDefaults();
		Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
		if(!isDataServicesUser){
			REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdsSet, false);
		}else if(triggerEnablement.REN_Bypass_Metrics_Field_Calculations__c == false){
			List<Opportunity> impactedOpportunityList = REN_OpportunityDataAccess.getOpptyWithMasterProduct(oppIdsSet);
			for(Opportunity oppObj : impactedOpportunityList){
				oppObj.REN_Renewal_Metrics_Status__c	 = 'Not Calculated';
				oppObj.REN_Metrics_Calculation_Date__c 	 = System.now();
			}
			List<String> opportunityFieldListForFLS = new List<String>{'REN_Renewal_Metrics_Status__c','REN_Metrics_Calculation_Date__c'};
			REN_OpportunityDataAccess.updateOpportunitySObject(impactedOpportunityList, opportunityFieldListForFLS);
			//Schedule batch
			REN_AsyncUtil.scheduleMetricsFieldCalculation();
		}
	}

	public static void resetOpportunityColumns(List<OpportunityLineItem> lstOppLineItem){
		Set<ID> oppIdSet = new Set<ID>();
		for(OpportunityLineItem op : lstOppLineItem){
	    	oppIdSet.add(op.OpportunityId);
	    }
	    REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdSet,false);
	}

	public static Set<ID> resetFields(Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap, String comparableFieldName){
		Set<ID> changedRecIdSet = new Set<ID>();
		String endDateField = CSM_Util.getNameSpace() + 'REN_Is_End_Date_Modified__c'; 
		for(sObject newRec: newRecordsMap.values()){
			if(oldRecordsMap.get(newRec.id).get(comparableFieldName) != newRec.get(comparableFieldName)){
				changedRecIdSet.add(newRec.id);
				newRec.put(endDateField, true);
			}
		}
		return changedRecIdSet;
	}
	
	/*public static void resetFieldOnInsert(List<sObject> newRecords){
		String endDateField = CSM_Util.getNameSpace() + 'REN_Is_End_Date_Modified__c'; 
		for(sObject newRec: newRecords){
			newRec.put(endDateField, true);
		}
	}*/
	
	//refactored under US2949
	public static void checkForDuplicateMasterOLI(List<OpportunityLineItem> lstOppLineItem,Set<id> oppIdSet) {
			Map<Id,Opportunity> opptyWithMasterOLIMap = new Map<Id,Opportunity>(REN_RRSimplifiedTriggerHelper.getOpportuntyDetails(oppIdSet));			    	
			for(OpportunityLineItem oli : lstOppLineItem){ 
				if(oli.REN_Is_CLM_Renewal__c) {
			   		Opportunity oppty = opptyWithMasterOLIMap.get(oli.OpportunityId);
					if(oppty.OpportunityLineItems != null && !oppty.OpportunityLineItems.isEmpty()){
				    	Map<ID, OpportunityLineItem> oliMap = new Map<ID, OpportunityLineItem>(oppty.OpportunityLineItems);				    				
				    	if(oliMap.values()[0].REN_Is_CLM_Renewal__c && !oliMap.containsKey(oli.id)){
				    		oli.addError(System.Label.REN_DUPLICATE_MASTER_OLI);
				    	}
			    	}
			    } 
			}	
	}
	
	/*
	//ESWAR B: NEED TO CHANGE BELOW TO HAVE OPPT IN PARAM INSTEAD OF OPPTLINES. REASON: OPPT LINES WON'T BE AVAILABLE AFTER DELETE
	public static void resetOpportunityColumns(List<OpportunityLineItem> lstOppLineItem){
		Set<String> oppIdSet=new Set<String>();
		for(OpportunityLineItem op : lstOppLineItem){
	    	oppIdSet.add(op.OpportunityId);
	    }
		OpportunityLineItem oppLineItem = new OpportunityLineItem();
		//ESWAR B: NEED TO HAVE BOTH RENEWAL AND NON-RENEWAL OPPTS BROUGHT BACK BECAUSE WE NEED TO ACCOMMODATE CASE OF ONE RENEWAL AND ONE NON-RENEWAL SPLIT/MERGE
	    List<Opportunity> oppListToUpdate = REN_OpportunityDataAccess.getRenewedOpportunity(oppIdSet);
	    for(Opportunity oppObj:oppListToUpdate){
		    double addsAmount = 0;
		    double Amount = 0;
	   		oppObj.REN_ConversionDelta__c = 0;
	   		if(oppObj.REN_Renewal_Target__c == null){
	   			oppObj.REN_Renewal_Target__c=0;
	   		}
	   		if(oppObj.OpportunityLineItems!=null){
			    for(OpportunityLineItem op : oppObj.OpportunityLineItems){
			        Amount += op.TotalPrice;
					if(op.REN_Is_CLM_Renewal__c == false){
	                    addsAmount += op.TotalPrice;
	                }
			   	}
	   		}
	        oppObj.REN_AddsAmount__c = addsAmount;
	        if(Amount != 0){
	        	oppObj.REN_AddsRatio__c = (addsAmount/Amount)*100;
	        }
	        oppObj.REN_ConversionDelta__c = Amount-oppObj.REN_Renewal_Target__c-addsAmount;
	    }
	    update oppListToUpdate;
	}
	*/
	
	public static void createOLI(SS_TriggerCollectionParameters.RLITriggerParams rliTriggerParams) {
    	Savepoint sp = Database.setSavepoint();
        Map<Id, List<REN_Renews_To__c>> oppty2rrListMap = rliTriggerParams.oppty2rrListMap ; //new Map<Id, List<REN_Renews_To__c>>();
        List<Opportunity> sourceOpptyList = REN_OpportunityDataAccess.getOpportunityById(rliTriggerParams.oppty2RenewalIDMap.keySet(), new Set<String>{'id','PriceBook2Id'},null);
        Map<ID, Opportunity> sourceOpptyMap = new Map<ID, Opportunity>(sourceOpptyList);
        List <REN_Field_Mappings__c> fieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_REN_RENEWS_TO);
        Map<Id, List<PricebookEntry>> oppty2PBEntryMap = REN_PricebookDataAccess.getOppToPbEntries(sourceOpptyList, rliTriggerParams.productIdSet);
        boolean isErrorFound = false;
		for(REN_Renews_To__c rr: (List<REN_Renews_To__c>)rliTriggerParams.newRecordsMap.values()) {
            if(rr.REN_Renews_To__c != null) {
                if(!oppty2PBEntryMap.containsKey(rr.REN_Renews_To__c)) {
                    rr.addError(String.format(Label.REN_ERR_PB_ENTRY_MISSING, new String[]{rr.REN_Product__c, sourceOpptyMap.get(rr.REN_Renews_To__c).PriceBook2Id}));                    
                    isErrorFound = true;
                }
            }
        }
        if(isErrorFound){
        	return;
        }
        Map<ID, OpportunityLineItem> rli2OliMap = getRliToNewOliMap(sourceOpptyList, oppty2PBEntryMap, fieldMappingList, oppty2rrListMap);
        if(!rli2OliMap.isEmpty()) {
		    REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(rli2OliMap.values());
		}
    }
    
    public static Map<String, PricebookEntry> getCrncyPrdctPbEntryMap(Boolean isMultiCurrency, List<PricebookEntry> priceBookEntryList) {
		Map<String, PricebookEntry> currencyProductPricebookEntryMap = new Map<String, PricebookEntry>();
		for(PricebookEntry bookEntry : priceBookEntryList) {
			String key = isMultiCurrency? bookEntry.get('CurrencyIsoCode') + ''+ bookEntry.product2Id : bookEntry.product2Id;
			currencyProductPricebookEntryMap.put(key, bookEntry);
		}
		return currencyProductPricebookEntryMap;
    }
    
    public static void setRliToNewOliMap(List<REN_Renews_To__c> lstRenewalsToRebuild,
    											Map<String, PricebookEntry> currencyProductPricebookEntryMap,
                                                List<REN_Field_Mappings__c> fieldMappingList,Opportunity opp,Map<String, Schema.SobjectField> opptLineAllFieldNames, 
                                                Map<ID, OpportunityLineItem> rli2OliMap) {
        //Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(OpportunityLineItem.sObjectType);
        Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        OpportunityLineItem opli;
        for(REN_Renews_To__c rr:lstRenewalsToRebuild) {
            opli = new OpportunityLineItem();
            opli = (OpportunityLineItem)REN_Util.copyObjectUsingAdminMapping(rr, opli, opptLineAllFieldNames, fieldMappingList);
            opli.OpportunityId = rr.REN_Renews_To__c;
            opli.REN_Renewable_Line_Item__c = rr.Id;
            opli.REN_Is_CLM_Renewal__c = true;
            String key = isMultiCurrency? opp.get('CurrencyIsoCode') + '' + rr.REN_Product__c : rr.REN_Product__c;
            if(currencyProductPricebookEntryMap.containsKey(key)){
                opli.PricebookEntryId = currencyProductPricebookEntryMap.get(key).id;
            }else{
            	
            }
            rli2OliMap.put(rr.id, opli);
        }
    }
    
    public static Map<ID, OpportunityLineItem> getRliToNewOliMap(List<Opportunity> sourceOpptyList, 
    																Map<Id, List<PricebookEntry>> oppty2PBEntryMap, 
    																List<REN_Field_Mappings__c> fieldMappingList, 
    																Map<Id, List<REN_Renews_To__c>> oppty2RRMap) {
    	Map<String, PricebookEntry> currencyProductPricebookEntryMap = new Map<String, PricebookEntry> ();
    	Map<ID, OpportunityLineItem> rli2OliMap = new Map<ID, OpportunityLineItem>();
    	Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(OpportunityLineItem.sObjectType);
    	for(Opportunity sourceOpportunity : sourceOpptyList) {
        	if(oppty2PBEntryMap.containsKey(sourceOpportunity.id)) {
        		currencyProductPricebookEntryMap = getCrncyPrdctPbEntryMap(UserInfo.isMultiCurrencyOrganization(), oppty2PBEntryMap.get(sourceOpportunity.id));
        		setRliToNewOliMap(oppty2RRMap.get(sourceOpportunity.id),currencyProductPricebookEntryMap,fieldMappingList, sourceOpportunity,opptLineAllFieldNames, rli2OliMap);
        	}
        }
        return rli2OliMap;
    }
}