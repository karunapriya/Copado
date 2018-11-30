/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Vishal, Comity Designs, Inc.
 *
 * Function			: Low Touch service for Case
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Vishal					User Story				Apr 19, 2018			1.1			Low Touch service for Case
 *
 */

public with sharing class REN_CasesService extends REN_JSONAPIBusinessLayer {
	
    /* This method is used to handle GET response to fetch details of Contact */
    public override String getResponse(Set<String> oppIdSet){
 		String objectName = 'case';
 		String  oppId = (new List<String>(oppIdSet))[0];
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        //Added for Translations
        List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppId});
        String langCode = opptyRoleList != null && !opptyRoleList.isEmpty() ? opptyRoleList[0].Contact.REN_Prefered_Language_Code__c : 'en-US';
        Map<String,String> mapOfTranslatedLabels;
        Pagereference pageRef;
        if(langCode != 'en-US') {
        	pageRef = Page.REN_LabelTranslatorPlaceholder;
        	pageRef.getParameters().put('languageCode', langCode);
	        REN_LabelTranslatorAPI lblTranslator = new REN_LabelTranslatorAPI();
	        mapOfTranslatedLabels = lblTranslator.translatedLabelsMap(new set<Pagereference>{pageRef});
        }
        REN_LowTouchUtil.LowTouchMetadataWrapper  lowTouchMetadataWrapper = new REN_LowTouchUtil.LowTouchMetadataWrapper();
		lowTouchMetadataWrapper.objectName = objectName;
		lowTouchMetadataWrapper.fieldSetMemberList = SObjectType.Case.FieldSets.CSM_Low_Touch_Contact_Form.getFields();
		lowTouchMetadataWrapper.fieldsToAdd = null;
		lowTouchMetadataWrapper.mapOfTranslatedLabels = mapOfTranslatedLabels;
		lowTouchMetadataWrapper.currencyCode = null;
		
        REN_JSONAPIPayLoad.MetaData meta = lowTouchUtil.getMetaData(lowTouchMetadataWrapper);
        List<OpportunityContactRole> ocr = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppId});
        System.debug('ocr --> ' +ocr + 'lowTouchUtil.apiNameSet - '+ lowTouchUtil.apiNameSet + 'meta ->'+JSON.serialize(meta));
         if (!lowTouchUtil.apiNameSet.contains('contactName')){
        	REN_JSONAPIPayLoad.fieldProperties fldProperties = new REN_JSONAPIPayLoad.fieldProperties();
            fldProperties.title = mapOfTranslatedLabels != null && mapOfTranslatedLabels.containsKey('REN_CONTACT_NAME') ? mapOfTranslatedLabels.get('REN_CONTACT_NAME') : 'Contact Name';
            fldProperties.type = 'Text';
            fldProperties.display = 'true';
            fldProperties.apiName = 'contactName';
            fldProperties.order = 0;
            fldProperties.dbRequired = 'false';
            meta.properties.put('Contact Name', fldProperties);
            lowTouchUtil.apiNameSet.add('contactName');
        }
        REN_JSONAPIPayLoad payLoadParent = lowTouchUtil.getJSONData(objectName, ocr, lowTouchUtil.apiNameSet, 'contact');
        if(payLoadParent.data != null){
        	payLoadParent.data[0].attributes.put('Contact Name', payLoadParent.data[0].attributes.get('contactName'));
        } 
		payLoadParent.meta = new REN_JSONAPIPayLoad.definitionsMain();
		payLoadParent.meta.definitions = new Map<String, REN_JSONAPIPayLoad.MetaData>();
		payLoadParent.meta.definitions.put(objectName, meta);
		payLoadParent.action = 'GET';
		payLoadParent.status = 'SUCCESS';
		System.debug('payLoadParent ->'+ JSON.serialize(payLoadParent));
        return JSON.serialize(payLoadParent);
	}
	
    /* This method is used to handle POST response for case which will create new case */
	public override String postResponse(Set<String> paramIdSet, REN_JSONAPIPayLoad payLoad) {
		CSM_TriggerManager.disableAllTriggers();
        List<REN_JSONAPIPayLoad.mainData> mainData = payLoad.data;
        String recordString = (new List<String>(paramIdSet))[0];
        Id recordId = Id.valueof(recordString) ;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        System.debug('sObjName :: '+sObjName);
        if(sObjName.equalsIgnoreCase('Opportunity')) {
            payLoad = createCase(payLoad, paramIdSet);
        }else {
            List<String> caseFieldsList = new List<String>{'Status'};
            try{
            	List<Case> caseList = CSM_CaseDataAccess.getCaseDetailsById(paramIdSet, caseFieldsList);
            	List<Case> newRecords =  caseList;  
            	if(newRecords != null && !newRecords.isEmpty()){                
	                newRecords[0].put('Status','Closed');
                    CSM_TriggerManager.TriggerHandler triggerHandler = new CSM_CaseTriggerHandler();
                    triggerHandler.onBeforeUpdate(caseList,newRecords, new Map<Id,Case>(caseList),new Map<Id,Case>(newRecords));
	                CSM_CaseDataAccess.updateCases(caseList, caseFieldsList);
                    triggerHandler.onAfterUpdate(caseList,newRecords, new Map<Id,Case>(caseList),new Map<Id,Case>(newRecords));
	                payLoad.status = 'SUCCESS';
            	}
            }catch(Exception e){
	            System.debug('\n\n~~~~~4: ' + e);
	            payLoad.status='ERROR';
	            List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>(); 
	            REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage() + ';\nStack Trace:' + e.getStackTraceString(), (new List<String>(paramIdSet))[0]);
	            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured', e.getMessage()));
	            payLoad.errors = errorList;           
        	}       	
        }                   
        System.debug('payLoad >>>> ' + JSON.serialize(payLoad));
        return JSON.serialize(payLoad);
    }
    
    /* This method is used to create new case and assigning cases to 'Digital Renewals Case' Queue */
    public REN_JSONAPIPayLoad createCase(REN_JSONAPIPayLoad payLoad, Set<String> oppIdSet) {
    	List<REN_JSONAPIPayLoad.mainData> mainData = payLoad.data;
     	String caseObj;
     	if(!mainData.isEmpty() ){
     		caseObj = JSON.serialize(mainData[0].attributes);
     	}
    	Case caseObject;
    	String oppId = (new List<String>(oppIdSet))[0];
    	System.Savepoint sp;
    	List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
    	REN_JSONAPIPayLoad.Error errorObj = new REN_JSONAPIPayLoad.Error();
    	try{
    		Map<String,String> inputFormMap = new Map<String,String>();
	    	inputFormMap = (Map<String,String>)JSON.deserialize(caseObj, Map<String,String>.class);
	    	caseObject = (Case)JSON.deserialize(caseObj, Case.class);
	    	
	    	if(CSM_AccessController.hasField('Case', CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c') && String.isNotBlank(oppId)){
	    		caseObject.put(CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c', oppId);
	    	}
	    	List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId});	    	
            List<QueueSobject> queueObjlist = CSM_CaseDataAccess.getQueuesDetailByName(new Set<String> {'Digital Renewals Case'});
            
	    	String accId = (oppList != null && !oppList.isEmpty()) ? oppList[0].AccountId + '': '';
	    	String name = inputFormMap.get('contactName');
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
    		REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_CONTACT_ME, e.getMessage(), oppId);
    		errorList.add(errorObj);
    		payLoad.errors = errorList;
    	}
    	return payLoad;
    }
}