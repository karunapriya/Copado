/**
 * Created Date		: Oct 6, 2016
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
 * admin					User Story				Oct 6, 2016			1.1					@description
 *
 */
public with sharing class REN_AsyncOppRenewalCLIBatchHelper {

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public static void processContractLineItems(List<REN_Line_Processing_Status__c> lineProcessStatusList) {
		Map<Id,REN_Line_Processing_Status__c> lpsMap = new Map<Id, REN_Line_Processing_Status__c>();
		Set<Id> opplineIdSet = new Set<Id>();
		Map<Id, Id> opp2SCMap = new Map<Id, Id>();
		Set<Id> arpIds = new Set<Id>();
		if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
			for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
				lpsMap.put(record.id, record);
				opplineIdSet.add(record.REN_Source_OLI_Id__c);
				arpIds.add(record.REN_Renewal_Processing_Status__c);
			}
		}
		REN_Renewals cliClass = new REN_ContractLineItems();
		List<OpportunityLineItem> oliList = REN_OpportunityLineItemDataAccess.getOpptyLineItemsById(opplineIdSet, 
											cliClass.getMappingFieldsToQuery(REN_Constants.OBJ_CONTRACT_LINE_ITEM + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM));
		List<REN_Renewal_Processing_Status__c> renewalProcessingStatusList = REN_RenewalProcessingStatusDataAccess.getProcessingStatusByIds(arpIds);
		opp2SCMap = getOpptyToServiceContractMap(renewalProcessingStatusList);
		List<SObject> renewedCliList = cliClass.createRenewals(oliList, opp2SCMap);
		List<Database.SaveResult> saveResult = REN_ContractLineItemDataAccess.insertContractLineItem(renewedCliList);
		Map<Id, SObject> sourceOli2NewCliMap = new Map<Id, SObject>();
		String namespace = CSM_Util.getNameSpace();
		if(renewedCliList != null && !renewedCliList.isEmpty()) {
			for(SObject record : renewedCliList) {
				sourceOli2NewCliMap.put((Id)record.get(CSM_Util.nameSpacePrefix21 + 'REN_Oppty_Line_Item_id__c'), record);
			}
		}
		Map<Id, SObject> lps2NewCliMap = new Map<Id, SObject>();
		if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
			for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
				if(sourceOli2NewCliMap.containsKey(record.REN_Source_OLI_Id__c)) {
					lps2NewCliMap.put(record.id, sourceOli2NewCliMap.get(record.REN_Source_OLI_Id__c));
				}
			}
		}
		lps2NewCliMap = REN_AsyncOppRenewalBatchHelper.setLineProcessingStatus(saveResult, lps2NewCliMap, lpsMap);
		REN_LineProcessingStatusDataAccess.updateLineProcessingStatusList(lpsMap.values());
	}
	
	private static Map<Id, Id> getOpptyToServiceContractMap(List<REN_Renewal_Processing_Status__c> renewalProcessingStatusList) {
		try {
			Map<Id, Id> opp2SCMap = new Map<Id,Id>();
			if(renewalProcessingStatusList != null && !renewalProcessingStatusList.isEmpty()) {
				for(REN_Renewal_Processing_Status__c renProcessStatus : renewalProcessingStatusList) {
					//if(String.isNotBlank(renProcessStatus.REN_Renewal_Opportunity__c)) {
						opp2SCMap.put(renProcessStatus.REN_Source_Opportunity__c, (Id)renProcessStatus.get(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c'));
					//}
				}
			}
			return opp2SCMap;
		} catch (exception ex) {
			return null;
        }
	}
}