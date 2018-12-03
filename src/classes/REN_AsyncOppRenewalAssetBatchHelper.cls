/**
 * Created Date		: Oct 7, 2016
 * Developed By		: admin, Comity Designs, Inc.
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
 * admin					User Story				Oct 7, 2016			1.1					@description
 *
 */
public with sharing class REN_AsyncOppRenewalAssetBatchHelper {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public static void processAssets(List<REN_Line_Processing_Status__c> lineProcessStatusList) {
		Map<Id,REN_Line_Processing_Status__c> lpsMap = new Map<Id, REN_Line_Processing_Status__c>();
		Set<Id> opplineIdSet = new Set<Id>();
		Set<Id> arpIds = new Set<Id>();
		Set<String> renewalOliSet = new Set<String>(); 
		if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
			for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
				lpsMap.put(record.id, record);
				opplineIdSet.add(record.REN_Source_OLI_Id__c);
				arpIds.add(record.REN_Renewal_Processing_Status__c);
				renewalOliSet.add(record.REN_Renewal_OLI_Id__c);
			}
		}
		REN_Assets assetClass = new REN_Assets();
		List<OpportunityLineItem> oliList = REN_OpportunityLineItemDataAccess.getOpptyLineItemsById(opplineIdSet, 
											assetClass.getMappingFieldsToQuery(REN_Constants.OBJ_ASSET + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM));
		List<REN_Renewal_Processing_Status__c> renewalProcessingStatusList = REN_RenewalProcessingStatusDataAccess.getProcessingStatusByIds(arpIds);
		List<SObject> renewedAssetsList = assetClass.createRenewals(oliList, null);
		
		Set<Id> opptyIdsSet = getOpptyIds(renewalProcessingStatusList);
		
		Map<Id, Id> opptyToOpptyContactMap = assetClass.getOpportunityContactMap(opptyIdsSet);
		
		List<Opportunity> opptyList = REN_OpportunityDataAccess.getOpportunitiesByIds(opptyIdsSet);
		Map<Id, Opportunity> oppty2OpptyMap = new Map<Id, Opportunity>();
		if(opptyList != null && !opptyList.isEmpty()) {
			for(Opportunity oppty : opptyList) {
				oppty2OpptyMap.put(oppty.id, oppty);
			}
		}
		
		assetClass.setChannelFields(renewedAssetsList, oppty2OpptyMap, opptyToOpptyContactMap);
		List<Database.SaveResult> saveResult = REN_AssetDataAccess.insertAssets(renewedAssetsList);
		Map<Id, SObject> sourceOli2AssetMap = new Map<Id, SObject>();
		String namespace = CSM_Util.getNameSpace();
		if(renewedAssetsList != null && !renewedAssetsList.isEmpty()) {
			for(SObject record : renewedAssetsList) {
				sourceOli2AssetMap.put((Id)record.get(namespace+'REN_Oppty_Line_Item_Id__c'), record);
			}
		}
		
		Map<Id, SObject> lps2AssetMap = new Map<Id, SObject>();
		if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
			for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
				if(sourceOli2AssetMap.containsKey(record.REN_Source_OLI_Id__c)) {
					lps2AssetMap.put(record.id, sourceOli2AssetMap.get(record.REN_Source_OLI_Id__c));
				}
			}
		}
		
		lps2AssetMap = REN_AsyncOppRenewalBatchHelper.setLineProcessingStatus(saveResult, lps2AssetMap, lpsMap);
		REN_LineProcessingStatusDataAccess.updateLineProcessingStatusList(lpsMap.values());
		Map<Id, List<OpportunityLineItem>> opptyToLineItemMap = new Map<Id, List<OpportunityLineItem>>();
		if(oliList != null && !oliList.isEmpty()) {
			for(OpportunityLineItem oli: oliList) {	
				List<OpportunityLineItem> oliListToAdd = opptyToLineItemMap.get(oli.OpportunityId);
                if(oliListToAdd == null){
                	oliListToAdd = new List<OpportunityLineItem>();
                }
                oliListToAdd.add(oli);
				opptyToLineItemMap.put(oli.OpportunityId, oliListToAdd);
			}
		}
		List<OpportunityLineItem> renewalOliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItems(renewalOliSet);
		Map<Id, OpportunityLineItem> oli2RenewalOliMap = new Map<Id, OpportunityLineItem>();
		if(renewalOliList != null && !renewalOliList.isEmpty()) {
			for(OpportunityLineItem oli : renewalOliList) {
				oli2RenewalOliMap.put(oli.REN_Source_Opportunity_Line_Item_Id__c, oli);
			}
		}
		
		if(!SS_Constants.isSimplifiedDataModelEnabled) {
			REN_Constants.ASSET_TRIGGER = false;
			REN_Constants.ASSET_TRIGGER_BEFORE_UPDATE = false;
			assetClass.setCoveredAssetOnOliAndAsset(renewedAssetsList, opptyToLineItemMap, oli2RenewalOliMap);
			if(renewalOliList != null && !renewalOliList.isEmpty()) {
				REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(renewalOliList, new Set<String>{'REN_Covered_Asset__c', 'REN_Covered_Product__c'});
			}	
		}
		
	}
	public static Set<Id> getOpptyIds(List<REN_Renewal_Processing_Status__c> renewalProcessingStatusList) {
		try {
			Set<Id> opptyIds = new Set<Id>();
			if(renewalProcessingStatusList != null && !renewalProcessingStatusList.isEmpty()) {
				for(REN_Renewal_Processing_Status__c renProcessStatus : renewalProcessingStatusList) {
					//if(String.isNotBlank(renProcessStatus.REN_Renewal_Opportunity__c)) {
						opptyIds.add(renProcessStatus.REN_Source_Opportunity__c);
					//}
				}
			}
			return opptyIds;
		} catch (exception ex) {
			return null;
        }
	}
}