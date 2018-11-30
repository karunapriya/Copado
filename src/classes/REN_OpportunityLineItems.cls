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
public with sharing class REN_OpportunityLineItems extends REN_Renewals {

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method	
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    public override List<SObject> createRenewals(List<SObject> opliList, Map<Id, Id> opptyToRenewalOpptyMap){
    	List<SObject> renewedObjectList = new List<SObject>();
    	if(opptyToRenewalOpptyMap != null && !opptyToRenewalOpptyMap.isEmpty()){
    		renewedObjectList = this.applyMapping(opliList, REN_Constants.OBJ_OPPTY_LINE_ITEM + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM, opptyToRenewalOpptyMap);
    	}
    	return renewedObjectList;
    }
    
	public override List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey, Map<Id, Id> opptyToRenewalOpptyMap){
		List<SObject> renewedObjectList = new List<SObject>();
		if(opptyToRenewalOpptyMap != null && !opptyToRenewalOpptyMap.isEmpty()){
			List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
			if(fmList != null && !fmList.isEmpty()){
				for(SObject currentObj : objectList){
					SObject renewedSobj = currentObj.clone(false, true, false, false);
					renewedSobj.put('REN_Is_CLM_Renewal__c', true);
					renewedSobj.put('OpportunityId', opptyToRenewalOpptyMap.get((Id)currentObj.get('OpportunityId')));
					renewedSobj.put('REN_Source_Opportunity_Line_Item_Id__c', currentObj.Id);
					renewedSobj.put('REN_Covered_Product__c', null); 
					for(REN_Field_Mappings__c fieldMapping : fmList){
						this.copyMappedValues(fieldMapping, renewedSobj, currentObj);
					}
					if(renewedSobj.get('TotalPrice') != null && renewedSobj.get('UnitPrice') != null){
						renewedSobj.put('TotalPrice', null);
					}
					renewedObjectList.add(renewedSobj);
				}
			}
		}
		return renewedObjectList;
	}
}