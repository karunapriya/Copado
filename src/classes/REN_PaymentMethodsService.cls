/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			:This class will return JSON structure for payments methods based on Low touch Client Object info.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri				US3312				Apr 19, 2018			1.1			This class will return JSON structure for payments methods based on Low touch Client Object info.
 *
 */
public with sharing class REN_PaymentMethodsService extends REN_JSONAPIBusinessLayer {

    public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return null;
    }
    
    /**Return JSON for all payment methods**/
	public override String getResponse(Set<String> oppIdSet) {
    	REN_JSONAPIPayLoad payLoadString = new REN_JSONAPIPayLoad();
        payLoadString.data = new List<REN_JSONAPIPayLoad.mainData>();
        REN_JSONAPIPayLoad.mainData payLoad;
        Map<String, String> lowTouchConfigMap = getLowTouchConfigurationMap();
        for(String paymentStr: lowTouchConfigMap.keySet()) {
        	payLoad = new REN_JSONAPIPayLoad.mainData();
	        payLoad.type = paymentStr;
	        payLoad.Id = '';
	        payLoad.attributes = new Map<String,String>();
	        payLoad.attributes.put('enabled', lowTouchConfigMap.get(paymentStr));
	        payLoadString.data.add(payLoad);
        }
        payLoadString.action = 'GET';
        payLoadString.status = 'SUCCESS';
        payLoadString.links = new Map<String, String>();
	    payLoadString.links.put('Self','/opportunities/'+ (new List<String>(oppIdSet))[0] +'/paymentmethods');
        system.debug('>>>JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadString));
        return JSON.serialize(payLoadString);
	}
	
	/***get info from low touch client object**/
	private Map<String, String> getLowTouchConfigurationMap() {
		List<REN_Low_Dollar_Client__c> clientDetailsList = REN_LowTouchClientDataAccess.getLowDollarClientDetails();   
        Boolean isDocuSignActive = clientDetailsList != null && !clientDetailsList.isEmpty() && clientDetailsList[0].REN_Docusign__c?true:false;        
        Boolean isLiveChatActive = clientDetailsList != null && !clientDetailsList.isEmpty() && clientDetailsList[0].REN_Live_Agent__c?true:false;        
        Boolean isFileUploadActive = clientDetailsList != null && !clientDetailsList.isEmpty() && clientDetailsList[0].REN_PO_Upload__c?true:false;       
        Boolean isPaymentActive = clientDetailsList != null && !clientDetailsList.isEmpty() && clientDetailsList[0].REN_Asparato_Payment__c?true:false;
        Map<String, String> lowTouchConfigMap = new Map<String, String>();
        lowTouchConfigMap.put('payment-processor', String.valueof(isPaymentActive));
        lowTouchConfigMap.put('docusign', String.valueof(isDocuSignActive));
        lowTouchConfigMap.put('purchase-order', String.valueof(isFileUploadActive));
        return lowTouchConfigMap;
	}
}