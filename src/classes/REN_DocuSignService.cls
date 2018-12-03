/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Low Touch service for DocuSign
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					User Story				Apr 19, 2018			1.1			Low Touch service for DocuSign.
 *
 */
public with sharing class REN_DocuSignService extends REN_JSONAPIBusinessLayer {
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad) {
		return null;
	}
   
	public override String getResponse(Set<String> oppIdSet){
		REN_JSONAPIPayLoad payLoadObj = new REN_JSONAPIPayLoad();
		REN_LowTouchUtil util = new REN_LowTouchUtil();
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        payLoadObj.status = 'SUCCESS';
        try { 
        	String oppId = (new List<String>(oppIdSet))[0];
        	REN_DocuSignApiCall docuSignObj  = new REN_DocuSignApiCall();
        	System.debug('OPPID :: '+ oppId);
            String urlToDocSign = docuSignObj.sendEnvelope(new Set<Id>{oppId});
            if(urlToDocSign == 'ConfigrationMissing' || urlToDocSign == 'Exception'){
	  	 		errorList.add(util.createErrorList('Exception', system.Label.REN_SIGN_PO_VIA_DOCUSIGN, 'ConfigrationMissing', system.label.REN_CONFIGURATION_MISSING));
	  	 		payLoadObj.status = 'ERROR';
	  	 	} else {
	  	 		/*String str = urlToDocSign;
	  	 		System.debug('str :: '+str);
				String[] strArray = str.split('lang=');
				if(strArray.size() >= 2){
  					String[] langCodeArray = strArray[1].split('#!');
  					preferedLang = langCodeArray[0];
				}*/
				List<OpportunityContactRole> contactList = CSM_ContactDataAccess.getContactFromOpp(new set<Id>{oppId});
				string preferedLang = contactList != null && !contactList.isEmpty() && String.isNotBlank(contactList[0].Contact.REN_Prefered_Language_Code__c) ? contactList[0].Contact.REN_Prefered_Language_Code__c:'en-US';
	  	 		String returnUrl = ((String)CSM_Admin__c.getOrgDefaults().REN_Low_Touch_User_URL__c)+'?lang='+preferedLang  + '&oppId='+oppId+'#!/opp/'+ oppId+'/checkout'; //+'?lang='+preferedLang
		        System.debug('meta >>>'+'\n ::: urlToDocSign : '+urlToDocSign);		        
		        payLoadObj.data = new List<REN_JSONAPIPayLoad.mainData>();	        
		       	REN_JSONAPIPayLoad.mainData payLoad = new REN_JSONAPIPayLoad.mainData();
		        payLoad.type = 'docusign-payment';
		        payLoad.Id = (new List<String>(oppIdSet))[0];
		        payLoad.attributes = new Map<String,String>();
		        payLoad.attributes.put('send-to-link', urlToDocSign);
		        payLoad.attributes.put('receive-success-link', returnUrl+'?event=signing_complete');
		        payLoad.attributes.put('receive-error-link', returnUrl+'?event=decline');
		        payLoadObj.data.add(payLoad);
		        system.debug('>>>JSON.serialize(payLoadObj) ::'+JSON.serialize(payLoadObj));
	  	 	}
	  	 	payLoadObj.errors = errorList;
        } catch(Exception e) {
        	payLoadObj.status = 'ERROR';
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_SIGN_PO_VIA_DOCUSIGN, e.getMessage(), (new List<String>(oppIdSet))[0]);
            errorList.add(util.createErrorList('Exception', system.Label.REN_SIGN_PO_VIA_DOCUSIGN, 'Exception occured', e.getMessage()));
            payLoadObj.errors = errorList;
        }
        return JSON.serialize(payLoadObj);
    } 
    
    
}