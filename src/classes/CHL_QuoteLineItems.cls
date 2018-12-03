/**
 * Created Date		: Nov 10, 2016
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
 * Amit					User Story				Nov 10, 2016			1.1					@description
 *
 */
public with sharing class CHL_QuoteLineItems extends REN_Renewals {

	public override List<SObject> createRenewals(List<SObject> qliList, Map<Id, Id> quoteToRenewQuoteMap){
    	List<SObject> renewedObjectList = new List<SObject>();
    	if(qliList != null && !qliList.isEmpty()){
    		renewedObjectList = this.applyMapping(qliList, 
    												CHL_Constants.OBJ_QUOTELINEITEM + ':' + CHL_Constants.OBJ_QUOTELINEITEM, 
    												quoteToRenewQuoteMap);
    	}
    	return renewedObjectList;
    }
    
	public override List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey, Map<Id, Id> quoteToRenewQuoteMap){
		List<SObject> renewedObjectList = new List<SObject>();
		if(objectList != null && !objectList.isEmpty() && String.isNotBlank(toFromObjectKey) 
			&& quoteToRenewQuoteMap != null && !quoteToRenewQuoteMap.isEmpty()){
			List<REN_Field_Mappings__c> fmList;
			if(!Test.isRunningTest()) {
				fmList = getFieldMappingByKey(toFromObjectKey);
			}else {
    			fmList = getFieldMappingByKey('Opportunity:Quote');
    		}
        	Boolean hasDistribQuoteField = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_For_Distributor_Quote__c');
			if(fmList != null && !fmList.isEmpty()){
				for(SObject currentObj : objectList){
					SObject renewedSobj = currentObj.clone(false, true, false, false);
					renewedSobj.put('QuoteId', quoteToRenewQuoteMap.get((Id)currentObj.get('QuoteId')));
					for(REN_Field_Mappings__c fieldMapping : fmList){
						this.copyMappedValues(fieldMapping, renewedSobj, currentObj);
					}
				    renewedSobj.put('Product2Id', currentObj.get('Product2Id')) ;
				    renewedSobj.put('Quantity', currentObj.get('Quantity')) ;
				    renewedSobj.put('UnitPrice', currentObj.get('UnitPrice')) ;
				    renewedSobj.put('PricebookEntryId', currentObj.get('PricebookEntryId'));
				    renewedSobj.put('Discount', currentObj.get('Discount'));
				    //renewedSobj.put(CHL_Util.quoteExtnNameSpace +'REN_Original_Line_Item_ID__c', 
				    //currentObj.get(CHL_Util.quoteExtnNameSpace +'REN_Original_Line_Item_ID__c'));
				    if(hasDistribQuoteField) {
				    	renewedSobj.put(CHL_Util.quoteExtnNameSpace +'CHL_For_Distributor_Quote__c', true);
				    }
					renewedObjectList.add(renewedSobj);
				}
			}
		}
		return renewedObjectList;
	}
}