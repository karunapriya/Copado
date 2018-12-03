/**
 * Created Date     : Feb, 18 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Low Touch service for Case.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   User Story              Feb 18, 2018    1.0         Low Touch oAuth access token based on refresh token   
 *
 */
public with sharing class REN_LowTouchCasesService extends REN_LowTouchBusinessLayer {
	
    /* This method is used to handle GET response to fetch details of Contact */
    public override String getResponse(Set<String> oppIdSet){
 		String objectName = 'case';
 		String  oppId = (new List<String>(oppIdSet))[0];
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        REN_LowTouchPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, SObjectType.Case.FieldSets.CSM_Low_Touch_Contact_Form.getFields(), null);
        List<OpportunityContactRole> ocr = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppId});
        System.debug('ocr --> ' +ocr + 'lowTouchUtil.apiNameSet - '+ lowTouchUtil.apiNameSet + 'meta ->'+JSON.serialize(meta));
         if (!lowTouchUtil.apiNameSet.contains('contactname')){
        	REN_LowTouchPayLoad.fieldProperties fldProperties = new REN_LowTouchPayLoad.fieldProperties();
            fldProperties.title = 'Contact Name';
            fldProperties.type = 'Text';
            fldProperties.display = true;
            fldProperties.order = 0;
            meta.properties.put(fldProperties.title, fldProperties);
            lowTouchUtil.apiNameSet.add(fldProperties.title);
        }
        REN_LowTouchPayLoad payLoadParent = lowTouchUtil.getJSONData(objectName, ocr, lowTouchUtil.apiNameSet, 'contact');
        if(payLoadParent.data != null){
        	payLoadParent.data[0].attributes.put('Contact Name', payLoadParent.data[0].attributes.get('contact.name'));
        } 
		payLoadParent.meta = new REN_LowTouchPayLoad.definitionsMain();
		payLoadParent.meta.definitions = new Map<String, REN_LowTouchPayLoad.MetaData>();
		payLoadParent.meta.definitions.put(objectName, meta);
		payLoadParent.action = 'GET';
		System.debug('payLoadParent ->'+ JSON.serialize(payLoadParent));
        return JSON.serialize(payLoadParent);
	}
	
    /* This method is used to handle POST response for case which will create new case */
	public override String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad) {
     	List<REN_LowTouchPayLoad.mainData> mainData = payLoad.data;
     	REN_LowTouchPayLoad payLoadObj = createCase(payLoad, oppIdSet);
     	System.debug('payLoad >>>> ' + JSON.serialize(payLoadObj));
     	return JSON.serialize(payLoadObj);
    }
    
    /* This method is used to create new case and assigning cases to 'Digital Renewals Case' Queue */
    public REN_LowTouchPayLoad createCase(REN_LowTouchPayLoad payLoad, Set<String> oppIdSet) {
    	List<REN_LowTouchPayLoad.mainData> mainData = payLoad.data;
     	String caseObj;
     	if(!mainData.isEmpty() ){
     		caseObj = JSON.serialize(mainData[0].attributes);
     	}
    	Case caseObject;
    	String oppId = (new List<String>(oppIdSet))[0];
    	System.Savepoint sp;
    	List<REN_LowTouchPayLoad.Error> errorList = new List<REN_LowTouchPayLoad.Error>();
    	REN_LowTouchPayLoad.Error errorObj = new REN_LowTouchPayLoad.Error();
    	try{
    		Map<String,String> inputFormMap = new Map<String,String>();
	    	inputFormMap = (Map<String,String>)JSON.deserialize(caseObj, Map<String,String>.class);
	    	caseObject = (Case)JSON.deserialize(caseObj, Case.class);
	    	
	    	if(CSM_AccessController.hasField('Case', CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c') && String.isNotBlank(oppId)){
	    		caseObject.put(CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c', oppId);
	    	}
	    	List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId});	    	
            List<QueueSobject> queueObjlist = CSM_CaseDataAccess.getQueuesDetailByName(new Set<String> {'Digital Renewals Case'});
            
	    	String accId = null;
	    	if(oppList != null && !oppList.isEmpty()){
	    		accId = oppList[0].AccountId + '';
	    	}
	    	
	    	String name = inputFormMap.get('contact.name');
	    	List<Contact> contactList = CSM_ContactDataAccess.contactExactSearch(inputFormMap.get('contactemail'));
	    	sp = Database.setSavepoint();
	    	if(contactList == null || contactList.isEmpty()){
	    		Contact contactObj = new Contact();
	    		contactObj.accountId = accId;
	    		if(String.isNotBlank(name)){
	    			name = name.trim();
	    			if(name.lastIndexOf(' ') > 0){
	    				contactObj.FirstName = name.substring(0,name.lastIndexOf(' '));
	    				contactObj.LastName = name.substring(name.lastIndexOf(' '));
	    			}else{
	    				contactObj.LastName = name;
	    			}
	    		}
	    		contactObj.Phone = inputFormMap.get('contactphone');
	    		contactObj.Fax = inputFormMap.get('contactfax');
	    		contactObj.MobilePhone = inputFormMap.get('contactmobile');
	    		contactObj.Email = inputFormMap.get('contactemail');
	    		contactList = new List<Contact>{contactObj};
	    		CSM_ContactDataAccess.insertContact(contactList);
	    		caseObject.ContactId = contactList[0].id;
	    	}else{
	    		caseObject.ContactId = contactList[0].id;
	    	}
	    	
	    	//Added for US2960:	LT - Update Create a Sales Request Contact Logic
	    	String contactMobile = String.isNotBlank(inputFormMap.get('contactmobile')) ? 'ContactMobile:'+inputFormMap.get('contactmobile') +',\n'+'': '';
	    	String contactFax = String.isNotBlank(inputFormMap.get('contactfax')) ? 'ContactFax:'+inputFormMap.get('contactfax') +',\n': '';
	        String contactPhone = String.isNotBlank(inputFormMap.get('contactphone')) ? 'ContactPhone:'+inputFormMap.get('contactphone') +',\n': '';
	    	
	    	caseObject.description = 'Subject: '+inputFormMap.get('subject')+',\n'+'Name: '+ name+',\n'+'ContactEmail: '+inputFormMap.get('contactemail')+ ',\n'+contactPhone + contactMobile + contactFax + inputFormMap.get('description');
	    	caseObject.REN_Case_From_LT__c = true;
	    	caseObject.ownerId = queueObjlist != null && !queueObjlist.isEmpty() ? queueObjlist[0].QueueId : UserInfo.getUserID();
	    	caseObject.type = Label.REN_LT_DIGITAL_RENWALS_CASE;
	    	List<Case> caseList = new List<Case>{caseObject};
	    	CSM_CaseDataAccess.insertCases(caseList);
	    	payLoad.status = 'SUCCESS';
    	}catch(Exception e){
    		caseObject = new Case();
    		Database.rollback(sp); 
    		caseObject.description = 'Error: ' + e.getMessage();
    		payLoad.status = 'ERROR';
    		errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_CONTACT_ME, 'Exception occured', e.getMessage()));
    		REN_HandleOpportunityStageUpdate.updateErrorLog(system.label.CHL_LBL_CONTACT_ME, e.getMessage(), oppId);
    		errorList.add(errorObj);
    		payLoad.errors = errorList;
    	}
    	return payLoad;
    }
}