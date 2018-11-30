/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - Low Touch service for Unsubscription
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi									Apr 19, 2018			1.1			@description - Low Touch service for Unsubscription.
 *
 */
 public with sharing class REN_ContactsService extends REN_JSONAPIBusinessLayer {
    
    
    /* This method is used to handle GET response to fetch details of Contact to unsubscribe */    
 	public override String getResponse(Set<String> oppIdSet){
 		REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        String  oppId = (new List<String>(oppIdSet))[0];
        List<OpportunityContactRole> opptyContactRoleList = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppId});
        REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
        payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
        if(opptyContactRoleList !=null && !opptyContactRoleList.isEmpty()) {
	        Set<Id> contactIdSet = new Set<ID> {opptyContactRoleList[0].ContactId};
	        List<Contact> contactList = CSM_ContactDataAccess.getContactsById(contactIdSet);        
	       	System.debug('contactList - '+contactList);
			REN_JSONAPIPayLoad.mainData payLoad;
	        for(Contact conObj: contactList) {
	        	payLoad = new REN_JSONAPIPayLoad.mainData();
		        payLoad.type = 'Contact';
		        payLoad.Id = conObj.Id;
		        payLoad.attributes = new Map<String,String>();
		        payLoad.attributes.put('name', conObj.name);
		        payLoad.attributes.put('email', conObj.email);
		        payLoad.attributes.put('phone', conObj.phone);
		        payLoad.attributes.put('unsubscribed', String.valueOf(conObj.HasOptedOutOfEmail));
		        payLoad.attributes.put('locale', conObj.REN_Prefered_Language_Code__c);
		        payLoadParent.data.add(payLoad);
	        }
			payLoadParent.action = 'GET';
			payLoadParent.status = 'SUCCESS';
			payLoadParent.links = new Map<String, String>();
			payLoadParent.links.put('self' , '/opportunities/'+oppId+'/contacts');
        } else {
        	List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        	payLoadParent.status = 'ERROR';
    		errorList.add(new REN_LowTouchUtil().createErrorList('Exception', 'Unsubscription', Label.REN_INVALID_CONTACT, Label.REN_INVALID_CONTACT));
        	REN_LowTouchUtil.updateErrorLog('Unsubscription', System.label.REN_INVALID_CONTACT, oppId); 
        	payLoadParent.errors = errorList;
        }
		system.debug('CONTACT >>?? JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
 	}
 	
 	 /* This method is used to handle POST response to update Contact if he opts for unsubscription. */    
 	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
 		
 		List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        String  oppId = (new List<String>(oppIdSet))[0];    	
    	System.Savepoint sp = Database.setSavepoint();
        try {
            List<OpportunityContactRole> opptyContactRoleList = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppId});
        	if(opptyContactRoleList !=null && !opptyContactRoleList.isEmpty()) {
        		Contact primaryContact = new Contact(Id=opptyContactRoleList[0].ContactId);
        		primaryContact.HasOptedOutOfEmail = payLoad.data != null && payLoad.data[0].attributes.containsKey('unsubscribed') ? Boolean.valueof(payLoad.data[0].attributes.get('unsubscribed')) : false;
        		primaryContact.REN_Prefered_Language_Code__c =  payLoad.data != null && payLoad.data[0].attributes.containsKey('locale') ? payLoad.data[0].attributes.get('locale') : 'en-US';
        		CSM_ContactDataAccess.updateContact(new List<contact>{primaryContact}, new List<String>{'Id', 'REN_Prefered_Language_Code__c', 'HasOptedOutOfEmail'});
        		payLoad.status = 'SUCCESS';
        	}	else {
	        	payLoad.status = 'ERROR';
	    		errorList.add(new REN_LowTouchUtil().createErrorList('Exception', Label.REN_LBL_UNSUBSCRIBE, Label.REN_INVALID_CONTACT, Label.REN_INVALID_CONTACT));
	        	REN_LowTouchUtil.updateErrorLog(Label.REN_LBL_UNSUBSCRIBE, System.label.REN_INVALID_CONTACT, oppId); 
	        	payLoad.errors = errorList;
	        }
        }
        catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            Database.rollback(sp);
            payLoad.status = 'ERROR';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', Label.REN_LBL_UNSUBSCRIBE, 'Exception occured', e.getMessage()));
            REN_LowTouchUtil.updateErrorLog(Label.REN_LBL_UNSUBSCRIBE, e.getMessage(), oppId);
            payLoad.errors = errorList;
        }
        return JSON.serialize(payload);
 	}
}