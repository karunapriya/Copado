/**
 * Created Date		: Apr 5, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - This class will return all the lables required for LT.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri				US3240				Apr 5, 2018			1.1					This class will return all the lables required for LT.
 *
 */



public class REN_LowTouchPaymentsService extends REN_LowTouchBusinessLayer {
 	
    public static void insertPaymentList(List<sObject> paymentList, Set<String> fieldSetForCrudFLS){
     	CSM_Util.checkCRUD_FlsPermissions('REN_Low_Touch_Payment__c', fieldSetForCrudFLS, CSM_Constants.DML_OPERATION_INSERT);
     	
     	insert paymentList;
	}
    public override String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad){
    	REN_LowTouchPayLoad payloadParent = payLoad;
    	List<REN_Low_Touch_Payment__c> paymentList = new List<REN_Low_Touch_Payment__c>();
    	Set<String> fieldSetForCrudFLS = new Set<String>{'REN_Cardholders_name__c', 'REN_Card_number__c', 'REN_CVV__c', 'REN_Expiration__c', 'REN_Status__c'};
    	REN_Low_Touch_Payment__c paymentObj;
    	for(REN_LowTouchPayLoad.mainData mainData : payLoad.data) {
			paymentObj = new REN_Low_Touch_Payment__c();
			paymentObj.REN_Cardholders_name__c = mainData.attributes.get('Cardholders-name');
			paymentObj.REN_Card_number__c = Integer.valueof(mainData.attributes.get('Card-number'));
			paymentObj.REN_CVV__c = Integer.valueof(mainData.attributes.get('CVV'));
			paymentObj.REN_Expiration__c = mainData.attributes.get('Expiration');
			paymentObj.REN_Status__c = 'Collected from customer';
			paymentList.add(paymentObj);
    	}
    	if(!paymentList.IsEmpty()){
    		insertPaymentList(paymentList,fieldSetForCrudFLS);
    	}
    
    	return JSON.serialize(payloadParent);
    }
    
    
    // Get Payment Service
 	public override String getResponse(Set<String> oppIdSet){
        return null;
       
	}
}