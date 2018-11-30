/**
 * Created Date		: Oct 10, 2016
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * admin					User Story				Oct 10, 2016			1.1					@description
 *
 */
public with sharing class REN_AsyncOppRenewalRRBatchHelper {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public static void processRenewalRelationship(List<REN_Line_Processing_Status__c> lineProcessStatusList) {
		Map<Id,REN_Line_Processing_Status__c> lpsMap = new Map<Id, REN_Line_Processing_Status__c>();
		Set<Id> renewalOliSet = new Set<Id>(); 
		Set<Id> sourceOliSet = new Set<Id>(); 
		Map<Id, Id> sourceOpptyLineId2AssetIdMap = new Map<Id, Id>();
		Set<Id> contractLineItemIdSet = new Set<Id>();
		Map<STring, String> cli2SourceOliMap = new Map<String, String>();
		Map<Id, Id> asset2LpsMap = new Map<Id, Id>();
		Map<Id, Id> cli2LpsMap = new Map<Id, Id>(); 
		if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
			for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
				lpsMap.put(record.id, record);
				if(String.isNotBlank(record.REN_Renewal_OLI_Id__c)) {
					renewalOliSet.add(record.REN_Renewal_OLI_Id__c);	
				}
				if(String.isNotBlank(record.REN_Renewal_Asset_Id__c)) {
					sourceOpptyLineId2AssetIdMap.put(record.REN_Source_OLI_Id__c, record.REN_Renewal_Asset_Id__c);
					asset2LpsMap.put(record.REN_Renewal_Asset_Id__c, record.id);
				}
				if(String.isNotBlank(record.REN_Renewal_Contract_Line_Item_Id__c)) {
					contractLineItemIdSet.add(record.REN_Renewal_Contract_Line_Item_Id__c);
					cli2SourceOliMap.put(record.REN_Renewal_Contract_Line_Item_Id__c, record.REN_Source_OLI_Id__c);
					cli2LpsMap.put(record.REN_Renewal_Contract_Line_Item_Id__c, record.id);
				}
				if(String.isNotBlank(record.REN_Source_OLI_Id__c)) {
					sourceOliSet.add(record.REN_Source_OLI_Id__c);
				}
			}
		}
		REN_RenewalRelationships renewalRelationshipClass = new REN_RenewalRelationships();
		List<SObject> renewOliList;
		if(SS_Constants.isSimplifiedDataModelEnabled){
			renewOliList = REN_OpportunityLineItemDataAccess.getOpptyLineItemsById(sourceOliSet, 
									renewalRelationshipClass.getMappingFieldsToQuery(REN_Constants.OBJ_REN_RENEWS_TO + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM));
		} else {
			renewOliList = REN_OpportunityLineItemDataAccess.getOpptyLineItemsById(renewalOliSet, 
									renewalRelationshipClass.getMappingFieldsToQuery(REN_Constants.OBJ_REN_RENEWS_TO + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM));
		}
		List<SObject> renewedOliList = new List<SObject>();
		Map<Id, SObject> sourceOliId2CliMap = new Map<Id, SObject>();
		Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
															REN_Constants.OBJ_OPPORTUNITY, 
															CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
		if(entitlementPkgInstalled) {
			List<SObject> contractLineItemList = REN_ContractLineItemDataAccess.getContractLineItemsDetails(contractLineItemIdSet);
			if(contractLineItemList != null && !contractLineItemList.isEmpty()) {
				for(SObject cliRecord : contractLineItemList) {
					if(cli2SourceOliMap.containsKey(cliRecord.id)) {
						sourceOliId2CliMap.put((Id)cli2SourceOliMap.get(cliRecord.id), cliRecord);
					}
				}
			}
		}
		Map<Id, Id> sourceOpp2RenewOppFinalMap = new Map<Id, Id>();
		if(sourceOpptyLineId2AssetIdMap != null && !sourceOpptyLineId2AssetIdMap.isEmpty()) {
			Map<Id, Id> sourceOpp2RenewOppMap = getSourceoppToRenewOppMap(sourceOpptyLineId2AssetIdMap.keySet());
			sourceOpp2RenewOppFinalMap.putAll(sourceOpp2RenewOppMap);
		}
		if(sourceOliId2CliMap != null && !sourceOliId2CliMap.isEmpty()) {
			Map<Id, Id> sourceOpp2RenewOppMap = getSourceoppToRenewOppMap(sourceOliId2CliMap.keySet());
			sourceOpp2RenewOppFinalMap.putAll(sourceOpp2RenewOppMap);
		}
		Map<String,REN_Renews_To__c> oliToRliObjMap = renewalRelationshipClass.createRenewalRelationships(renewOliList, sourceOpptyLineId2AssetIdMap, sourceOliId2CliMap, sourceOpp2RenewOppFinalMap);	
		renewOliList = oliToRliObjMap.values();
		Map<Id, SObject> lps2AssetRRMap = new Map<Id, SObject>();
		List<SObject> assetRRList = new List<SObject>();
		List<SObject> cliRRList = new List<SObject>();
		Map<Id, SObject> lps2CliRRMap = new Map<Id, SObject>();
		Set<Id> renOptyIdSet = new Set<Id>();
		if(renewOliList != null && !renewOliList.isEmpty()) {
			for(SObject record : renewOliList) {
				
				if(String.isNotBlank((String)record.get('REN_Asset__c'))) {
					if(asset2LpsMap.containsKey((Id)record.get('REN_Asset__c'))) {
						lps2AssetRRMap.put(asset2LpsMap.get((Id)record.get('REN_Asset__c')), record);
						assetRRList.add(record);
					}
				} else if((CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c')) && String.isNotBlank((String)record.get(CSM_Util.nameSpacePrefix21 +'REN_Contract_Line_Item__c'))) {
					if(cli2LpsMap.containsKey((Id)record.get(CSM_Util.nameSpacePrefix21 +'REN_Contract_Line_Item__c'))) {
						lps2CliRRMap.put(cli2LpsMap.get((Id)record.get(CSM_Util.nameSpacePrefix21 +'REN_Contract_Line_Item__c')), record);
						cliRRList.add(record);
					}
				}
				renOptyIdSet.add((Id)record.get('REN_Renews_To__c'));
			}
		}
		REN_RRSimplifiedTriggerHandler.isRRSimplifiedInsertTriggerByPass = true;
		REN_RRSimplifiedTriggerHelper.processRliRecords((List<REN_Renews_To__c>)assetRRList);
		List<Database.SaveResult> assetRRSaveResult = REN_RenewRelationshipDataAccess.insertRenewalRelationship(assetRRList);
		lps2AssetRRMap = REN_AsyncOppRenewalBatchHelper.setLineProcessingStatus(assetRRSaveResult, lps2AssetRRMap, lpsMap);
		REN_LineProcessingStatusDataAccess.updateLineProcessingStatusList(lpsMap.values());
		REN_RRSimplifiedTriggerHelper.processRliRecords((List<REN_Renews_To__c>)cliRRList);
		List<Database.SaveResult> cliRRSaveResult = REN_RenewRelationshipDataAccess.insertRenewalRelationship(cliRRList);
		lps2CliRRMap = REN_AsyncOppRenewalBatchHelper.setLineProcessingStatus(cliRRSaveResult, lps2CliRRMap, lpsMap);
		REN_LineProcessingStatusDataAccess.updateLineProcessingStatusList(lpsMap.values());
		REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(new Set<Id>(sourceOpp2RenewOppFinalMap.values()));
		
		//Populating Renewable Line Item lookup on OLI with corresponding RLI
		if(!SS_Constants.isSimplifiedDataModelEnabled){
            List<OpportunityLineItem> oliUpdateRliLookup = new List<OpportunityLineItem>();
            if(!oliToRliObjMap.isEmpty()){
                    for(String opliId : oliToRliObjMap.keySet()){
                    	String oliId = opliId.split(':')[1];
                    	OpportunityLineItem newOLI;
                    	if(opliId.startsWith('C:') && !oliToRliObjMap.containsKey('A:'+oliId)){
                    		newOLI = new OpportunityLineItem(id = oliId, REN_Renewable_Line_Item__c = oliToRliObjMap.get(opliId).Id);
                    	}else{
                    		newOLI = new OpportunityLineItem(id = oliId, REN_Renewable_Line_Item__c = oliToRliObjMap.get(opliId).Id);
                    	}
                        oliUpdateRliLookup.add(newOLI);
                    }
                }
                if(oliUpdateRliLookup.size() > 0){
                    REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliUpdateRliLookup, new Set<String>{'REN_Renewable_Line_Item__c'});
                }
        }		
	}
	
	public static Map<Id, Id> getSourceoppToRenewOppMap(Set<Id> opptyId) {
		Map<Id, Id> sourceOpp2RenewOppMap = new Map<Id, Id> ();
		List<REN_Line_Processing_Status__c> lineProcStatList = REN_LineProcessingStatusDataAccess.getLineProcStatusListBySrcOLI(opptyId);
    	Set<Id> renewProcStat = new Set<Id>();
    	if(lineProcStatList != null && !lineProcStatList.isEmpty()) {
    		for(REN_Line_Processing_Status__c lps : lineProcStatList) {
    			renewProcStat.add(lps.REN_Renewal_Processing_Status__c);	
    		}
    	}
    	
    	List<REN_Renewal_Processing_Status__c> renewProcStatList = REN_RenewalProcessingStatusDataAccess.getRecordsByIds(renewProcStat);
    	if(renewProcStatList != null && !renewProcStatList.isEmpty()) {
    		for(REN_Renewal_Processing_Status__c rps : renewProcStatList) {
    			sourceOpp2RenewOppMap.put(rps.REN_Source_Opportunity__c, rps.REN_Renewal_Opportunity__c);
    		}
    	}
    	return sourceOpp2RenewOppMap;
	}
}