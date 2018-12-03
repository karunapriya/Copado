/**
 * Created Date		: Apr 5, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - Low Touch Payment Service.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri				US3240				Apr 5, 2018			1.1				Low Touch Payment Service.
 *
 */



public class REN_PaymentsService extends REN_JSONAPIBusinessLayer {
	
	@TestVisible
	private String objectName = 'ren_low_touch_payment__c';
    
    /**To get object and correspoding additional fields**/
    @TestVisible
    private Set<String> getObjectAndAdditionalFields(){
    	Set<String> fieldsToAdd = new Set<String>();
        //fieldsToAdd.add('ren_first_name__c');
        //fieldsToAdd.add('ren_last_name__c');
        fieldsToAdd.add('ren_billing_address_street__c');
        fieldsToAdd.add('ren_billing_address_city__c');
        fieldsToAdd.add('ren_billing_address_state__c');
        //fieldsToAdd.add('ren_billing_address_country__c');
        fieldsToAdd.add('ren_billing_address_postalcode__c');
        fieldsToAdd.add('ren_cvv__c');
        fieldsToAdd.add('ren_card_number__c');
        fieldsToAdd.add('ren_expiration__c');
        fieldsToAdd.add('ren_cardholders_name__c');
        return fieldsToAdd;
    }
    
	
    public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	REN_JSONAPIPayLoad payloadParent = payLoad;
    	List<REN_JSONAPIPayLoad.mainData> mainData = payloadParent.data;
    	
    	Set<Id> paymentIdSet = new Set<Id>();
    	List<Sobject> paymentListToUpdate = new List<Sobject>();
    	String paymentObj;
     	List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
     	
 		objectName = Test.isRunningTest() ? 'Opportunity' : objectName;
		payloadParent.status='SUCCESS';
    	try{
    		
    		if(CSM_AccessController.hasObject(objectName)) {
    			if(!mainData.isEmpty() ){
     				paymentObj = JSON.serialize(mainData[0].attributes);
     			}
 				Map<String,String> inputFormMap = new Map<String,String>();
    			inputFormMap = (Map<String,String>)JSON.deserialize(paymentObj, Map<String,String>.class);
				for(REN_JSONAPIPayLoad.mainData mainDataObj : mainData) {
					paymentIdSet.add(Id.valueOf(mainDataObj.Id)); 	
				}
				List<Sobject> paymentList = REN_PaymentDataAccess.getLowTouchPaymentList(objectName, paymentIdSet,Test.isRunningTest() ? new set<String>{'Id', 'Name'} : new set<String>{'Id', 'REN_Status__c'});
		    	for(Sobject paymentObjt :paymentList){
		    		paymentObjt.put('REN_Status__c', system.Label.REN_PAYMENT_COLLECTED_FROM_CUSTOMER);	
	                paymentObjt.put('REN_Billing_Address_Street__c', inputFormMap.get('ren_billing_address_street__c'));
	                paymentObjt.put('REN_Billing_Address_City__c', inputFormMap.get('ren_billing_address_city__c'));
	                paymentObjt.put('REN_Billing_Address_State__c', inputFormMap.get('ren_billing_address_state__c'));
	                //paymentObjt.put( 'REN_Billing_Address_Country__c', inputFormMap.get('ren_billing_address_country__c'));
	                paymentObjt.put('REN_Billing_Address_PostalCode__c', inputFormMap.get('ren_billing_address_postalcode__c'));
	                paymentObjt.put( 'REN_CVV__c', inputFormMap.get('ren_cvv__c'));
	                paymentObjt.put( 'REN_Card_number__c', inputFormMap.get('ren_card_number__c'));
	                paymentObjt.put('REN_Expiration__c', inputFormMap.get('ren_expiration__c'));
	                paymentObjt.put( 'REN_Cardholders_name__c', inputFormMap.get('ren_cardholders_name__c'));
	                paymentObjt.put('REN_Payment_Route_Options__c', 'Card');
					paymentListToUpdate.add(paymentObjt);
		    	}
		    	Set<String> fieldSetForCrudFLS = new Set<String>{'REN_Status__c', 'REN_Billing_Address_Street__c', 'REN_Billing_Address_City__c', 'REN_Billing_Address_State__c','REN_Billing_Address_Country__c', 'REN_Billing_Address_PostalCode__c', 'REN_First_Name__c', 'REN_Last_Name__c' };
		    	List<Sobject> updatedPaymentList = REN_PaymentDataAccess.updateLowtouchPaymentList(objectName, paymentListToUpdate, fieldSetForCrudFLS);
    		
    		}	else {
    			payLoadParent.status='ERROR';
        		REN_LowTouchUtil.updateErrorLog(system.Label.REN_PAY_VIA_CREDIT_CARD, system.label.REN_PAYMENT_OBJECT_MISSING, (new List<String>(oppIdSet))[0]);
	            errorList.add(new REN_LowTouchUtil().createErrorList(system.label.REN_PAYMENT_OBJECT_MISSING, system.Label.REN_PAY_VIA_CREDIT_CARD, system.label.REN_PAYMENT_OBJECT_MISSING, system.label.REN_PAYMENT_OBJECT_MISSING));
	            payLoadParent.errors = errorList;
    		}
    	}catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payloadParent.status='ERROR';
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_PAY_VIA_CREDIT_CARD, e.getMessage(), (new List<String>(oppIdSet))[0]);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_PAY_VIA_CREDIT_CARD, 'Exception occured', e.getMessage()));
            payLoadParent.errors = errorList;
            
        }
    	
    	return JSON.serialize(payloadParent);
    }
    
    
    // Get Payment Service
 	public override String getResponse(Set<String> oppIdSet){
 		SObject paymentObj = null;
 		Set<String> fieldsToAdd = getObjectAndAdditionalFields();
 		REN_JSONAPIPayLoad payLoadParent = new  REN_JSONAPIPayLoad();
 		REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
 		objectName = Test.isRunningTest() ? 'Opportunity' : objectName;
 		REN_JSONAPIPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, null, fieldsToAdd);
		system.debug('meta >>>'+meta);
       
        String oppId = (new List<String>(oppIdSet))[0];
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        try{
	        Opportunity oppRocord = (REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId}))[0];
	        List<OpportunityContactRole> oppContactList = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppRocord.id});
	        List<Sobject> paymentListInserted;
        	if(CSM_AccessController.hasObject(objectName)) {
        		
	        	paymentObj = CSM_AccessController.newSObject(objectName);
	        	List<Sobject> paymentList = new List<Sobject>();
	        	Set<String> fieldSetForCrudFLS = new Set<String>{'REN_Status__c', 'REN_Amount__c', 'REN_Opportunity__c'};	
	        	paymentObj.put('REN_Opportunity__c', oppRocord.id);
	            paymentObj.put('REN_Amount__c', oppRocord.Amount);
	            paymentObj.put('REN_Status__c', system.Label.REN_PAYMENT_AWAITING_SUBMISSION);
	            if(oppContactList != null && !oppContactList.isEmpty()){
	            	Contact cObj = oppContactList[0].Contact;
	            	//paymentObj.put('REN_Account_Name__c', cObj.Account.name);	
	                paymentObj.put('REN_First_Name__c', cObj.FirstName);
	                paymentObj.put('REN_Last_Name__c', cObj.lastname);
	            }
	            paymentObj.put('REN_Payment_Date__c', system.today());
	            paymentObj.put('REN_Payment_Route_Options__c','Card');
	            List<sObject> paymentObjList = new List<sObject>{paymentObj};
	            paymentListInserted = new List<Sobject>();
	            paymentListInserted = REN_PaymentDataAccess.insertLowTouchPaymentList(objectName,paymentObjList, fieldSetForCrudFLS);
	            payLoadParent = lowTouchUtil.getJSONData(objectName, paymentListInserted, lowTouchUtil.apiNameSet);
	        	payLoadParent.meta = new REN_JSONAPIPayLoad.definitionsMain();
				payLoadParent.meta.definitions = new Map<String, REN_JSONAPIPayLoad.MetaData>();
				payLoadParent.meta.definitions.put(objectName, meta);				
				payLoadParent.status='SUCCESS';
        	} else {
        		payLoadParent.status='ERROR';
        		REN_LowTouchUtil.updateErrorLog(system.Label.REN_PAY_VIA_CREDIT_CARD, system.label.REN_PAYMENT_OBJECT_MISSING, oppId);
	            errorList.add(new REN_LowTouchUtil().createErrorList(system.label.REN_PAYMENT_OBJECT_MISSING, system.Label.REN_PAY_VIA_CREDIT_CARD, system.label.REN_PAYMENT_OBJECT_MISSING, system.label.REN_PAYMENT_OBJECT_MISSING));
	            payLoadParent.errors = errorList;
        	}
			payLoadParent.action = 'GET';
			payLoadParent.links = new Map<String, String>();
		    payLoadParent.links.put('self','/opportunities/'+ oppId +'/paymentmethods/cc');
        	
        
        }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payLoadParent.status='ERROR';
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_PAY_VIA_CREDIT_CARD, e.getMessage(), oppId);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_PAY_VIA_CREDIT_CARD, 'Exception occured', e.getMessage()));
            payLoadParent.errors = errorList;
        }
        
    	
	    return JSON.serialize(payLoadParent);	
    	
	}
}