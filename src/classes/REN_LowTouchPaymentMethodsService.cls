/**
 * Created Date		: Apr 6, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - This class will return JSON structure for payments methods based on Low touch Client Object info.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri					US3312				Apr 6, 2018			1.1			This class will return JSON structure for payments methods based on Low touch Client Object info.
 *
 */
public with sharing class REN_LowTouchPaymentMethodsService extends REN_LowTouchBusinessLayer {

 	private Set<String> fieldsToAdd {get; set;}
	 
	 /**It will return additional fields**/
	 private void getObjectAndAdditionalFields(){
		fieldsToAdd = new Set<String>();
        fieldsToAdd.add('enabled');
        fieldsToAdd.add('create-record-link');
        fieldsToAdd.add('payment-link');
    }
    
    /**It will return field properties for additional field**/
    private List<REN_LowTouchPayLoad.fieldProperties> getfieldProperties(Set<String> fieldsToAdd) {
    	List<REN_LowTouchPayLoad.fieldProperties> fldList = new List<REN_LowTouchPayLoad.fieldProperties>();
        
        Integer order = 0;
        if (fieldsToAdd.contains('enabled')) {
        	REN_LowTouchPayLoad.fieldProperties fldProp1 = new REN_LowTouchPayLoad.fieldProperties();
            fldProp1.title = 'enabled';
            fldProp1.type = 'Checkbox';
            fldProp1.display = false;
            fldProp1.dbRequired = false;
            fldProp1.apiName = 'enabled';
            fldProp1.order = order;
            order++;
            fldList.add(fldProp1);
     	}
     	if(fieldsToAdd.contains('create-record-link')) {
     		REN_LowTouchPayLoad.fieldProperties fldProp2 = new REN_LowTouchPayLoad.fieldProperties();
            fldProp2.title = 'create-record-link';
            fldProp2.type = 'Text';
            fldProp2.display = false;
            fldProp2.dbRequired = false;
            fldProp2.apiName = 'create-record-link';
            fldProp2.order = order;
            order++;
            fldList.add(fldProp2);	
     	}
     	if(fieldsToAdd.contains('payment-link')) {
     		REN_LowTouchPayLoad.fieldProperties fldProp3 = new REN_LowTouchPayLoad.fieldProperties();
            fldProp3.title = 'payment-link';
            fldProp3.type = 'Text';
            fldProp3.display = false;
            fldProp3.dbRequired = false;
            fldProp3.apiName = 'payment-link';
            fldProp3.order = order;
            order++;
            fldList.add(fldProp3);	
     	}
     return fldList;
	}
	
	/**get data form Low touch client object**/
	private static REN_Low_Dollar_Client__c getClientDetails() {
        List<REN_Low_Dollar_Client__c> clientDetails = REN_LowTouchClientDataAccess.getLowDollarClientDetails();
        REN_Low_Dollar_Client__c clientDetail = new REN_Low_Dollar_Client__c();
        if (!clientDetails.isEmpty()){
            clientDetail = clientDetails[0];
        }
        return clientDetail;        
    }
    
    public override String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad){
    	return null;
    }
    
    /**Return JSON for all payment methods**/
	public override String getResponse(Set<String> oppIdSet) {
		 
        getObjectAndAdditionalFields();
        List<REN_LowTouchPayLoad.fieldProperties> fldProList = getfieldProperties(fieldsToAdd);
        REN_LowTouchPayLoad payLoadString = new REN_LowTouchPayLoad();
        payLoadString.data = new List<REN_LowTouchPayLoad.mainData>();
        
        REN_LowTouchPayLoad.mainData payLoad;
        Map<String, String> lowTouchConfigMap = getLowTouchConfigurationMap();
        for(String paymentStr: lowTouchConfigMap.keySet()) {
        	payLoad = new REN_LowTouchPayLoad.mainData();
	        payLoad.type = paymentStr;
	        payLoad.Id = '';
	        payLoad.attributes = new Map<String,String>();
	        payLoad.attributes.put(fldProList[1].title, '');
	        payLoad.attributes.put(fldProList[0].title, lowTouchConfigMap.get(paymentStr));
	        payLoadString.data.add(payLoad);
        }
        payLoadString.action = 'GET';
        payLoadString.links = new Map<String, String>();
	    payLoadString.links.put('Self','/opportunities/'+ (new List<String>(oppIdSet))[0] +'/paymentmethods');
        
            	
            
       system.debug('>>>JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadString));
       return JSON.serialize(payLoadString);
	}
	
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