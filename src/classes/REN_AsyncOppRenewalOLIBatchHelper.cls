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
public with sharing class REN_AsyncOppRenewalOLIBatchHelper {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public static void processRenewOpportunityLineItems(List<REN_Line_Processing_Status__c> lineProcessStatusList) {
		try {
			Map<Id,REN_Line_Processing_Status__c> lpsMap = new Map<Id, REN_Line_Processing_Status__c>();
			Set<Id> opplineIdSet = new Set<Id>();
			Map<String,String> renewOliLpsMap = new Map<String,String>();
			Map<Id, Id> opp2RenewOppMap = new Map<Id,Id>();
			Set<Id> arpIds = new Set<Id>();
			if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
				for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
					lpsMap.put(record.id, record);
					opplineIdSet.add(record.REN_Source_OLI_Id__c);
					renewOliLpsMap.put(record.REN_Source_OLI_Id__c,record.id);
					arpIds.add(record.REN_Renewal_Processing_Status__c);
				}
			}
			REN_Renewals oliCls = new REN_OpportunityLineItems();
			List<SObject> oliList = REN_OpportunityLineItemDataAccess.getOpptyLineItemsById(opplineIdSet, 
									oliCls.getMappingFieldsToQuery(REN_Constants.OBJ_OPPTY_LINE_ITEM + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM));
			List<REN_Renewal_Processing_Status__c> renewalProcessingStatusList = REN_RenewalProcessingStatusDataAccess.getProcessingStatusByIds(arpIds);
			opp2RenewOppMap = getOpptyToRenewOpptyMap(renewalProcessingStatusList);
			List<SObject> renewedOliList = oliCls.createRenewals(oliList, opp2RenewOppMap);
			List<Database.SaveResult> saveResult = REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(renewedOliList);
			Map<Id,SObject> sourceOli2NewRecordMap = new Map<Id,SObject>();
			// Set original line item id right here.
			if(renewedOliList != null && !renewedOliList.isEmpty()) {
				for(SObject record : renewedOliList) {
					//Had to set total price here to avoid 'TotalPrice must be specified error'.
					record.put('TotalPrice',  (Decimal)record.get('Quantity') * (Decimal)record.get('UnitPrice'));
					sourceOli2NewRecordMap.put(record.getCloneSourceId(), record);
				}
			}
			// update OLIs again to set original line item id.
			REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(renewedOliList);
			Map<Id,SObject> lps2OliMap = new Map<Id,SObject>();
			if(lineProcessStatusList != null && !lineProcessStatusList.isEmpty()) {
				for(REN_Line_Processing_Status__c record : lineProcessStatusList) {
					if(sourceOli2NewRecordMap.containsKey(record.REN_Source_OLI_Id__c)) {
						lps2OliMap.put(record.id,sourceOli2NewRecordMap.get(record.REN_Source_OLI_Id__c));
					}
				}
			}
			lps2OliMap = REN_AsyncOppRenewalBatchHelper.setLineProcessingStatus(saveResult, lps2OliMap, lpsMap);
			REN_LineProcessingStatusDataAccess.updateLineProcessingStatusList(lpsMap.values());
		} catch(exception ex) {
			
		}
	}
	public static Map<Id, Id> getOpptyToRenewOpptyMap(List<REN_Renewal_Processing_Status__c> renewalProcessingStatusList) {
		try {
			Map<Id, Id> opp2RenewOppMap = new Map<Id,Id>();
			if(renewalProcessingStatusList != null && !renewalProcessingStatusList.isEmpty()) {
				for(REN_Renewal_Processing_Status__c renProcessStatus : renewalProcessingStatusList) {
					if(String.isNotBlank(renProcessStatus.REN_Renewal_Opportunity__c)) {
						opp2RenewOppMap.put(renProcessStatus.REN_Source_Opportunity__c, renProcessStatus.REN_Renewal_Opportunity__c);
					}
				}
			}
			return opp2RenewOppMap;
		} catch (exception ex) {
			return null;
        }
	}
}