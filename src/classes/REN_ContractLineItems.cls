/**
 * Created Date		: Sep 6, 2016
 * Developed By		: Amit, Comity Designs, Inc.
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
 * Amit					User Story				Sep 6, 2016			1.1					@description
 *
 */
public with sharing class REN_ContractLineItems extends REN_Renewals {

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    public override List<SObject> createRenewals(List<SObject> opliList, Map<Id, Id> opptyToRenewalsMap){ 
    	List<SObject> renewedObjectList = new List<SObject>();
    	if(opptyToRenewalsMap != null && !opptyToRenewalsMap.isEmpty()){
    		renewedObjectList = this.applyMapping(opliList, 
    												REN_Constants.OBJ_CONTRACT_LINE_ITEM + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM, 
    												opptyToRenewalsMap);
    	}
    	return renewedObjectList;
    }
	
	public override List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey, Map<Id, Id> opptyToRenewalSCMap){
		List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
		List<SObject> renewedObjectList = new List<SObject>();
		if(fmList != null && !fmList.isEmpty()){
			for(SObject currentObj : objectList){
				SObject contractLineItemNew = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
				contractLineItemNew.put('PricebookEntryId', (String)currentObj.get('PricebookEntryId'));
				contractLineItemNew.put('ServiceContractId', (Id)opptyToRenewalSCMap.get((Id)currentObj.get('OpportunityId')));
				contractLineItemNew.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID, currentObj.Id);
				if(currentObj.get('REN_Covered_Asset__c') != null){
					contractLineItemNew.put('AssetId', (Id)currentObj.get('REN_Covered_Asset__c'));
				}
				for(REN_Field_Mappings__c fieldMapping : fmList){
					this.copyMappedValues(fieldMapping, contractLineItemNew, currentObj);
				}
				renewedObjectList.add(contractLineItemNew);
			}
		}
		return renewedObjectList;
	}
	
	public List<SObject> updateCoveredAssetOnCLI(List<SObject> renewedCliList, Map<Id, OpportunityLineItem> opptyToRenewedOliMap){
		if(renewedCliList != null && !renewedCliList.isEmpty()){
			for(SObject renewedCli : renewedCliList){
				if(opptyToRenewedOliMap.containsKey(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID)){
					OpportunityLineItem renewedOli = opptyToRenewedOliMap.get((Id)renewedCli.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID));
					renewedCli.put('REN_Covered_Asset__c', renewedOli.REN_Covered_Asset__c);
				}
			}
		}
		return renewedCliList;
	}
}