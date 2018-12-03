/**
 * Created Date		: Jan 23, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
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
 * Chandra					User Story				Jan 23, 2017			1.1					@description
 * 
 */
public with sharing class REN_LT_RequestContactCtrl {
	
	public static String clientName;

    @AuraEnabled
    public static Case createCase(String caseObj, String oppId) {
    	Case caseObject;
    	System.Savepoint sp;
    	try{
    	    List<REN_Low_Dollar_Client__c> listOfLTConfig = REN_LowTouchClientDataAccess.getLowDollarClientDetails();
	        REN_Low_Dollar_Client__c adminLowTouchCS = null;
	        if(listOfLTConfig != null && !listOfLTConfig.isEmpty()){
	            adminLowTouchCS = listOfLTConfig.get(0);
	        }
	    	//System.debug(adminLowTouchCS + '\n\n4~~~~caseObj:' + caseObj);
	    	Map<String,String> inputFormMap = new Map<String,String>();
	    	inputFormMap = (Map<String,String>)JSON.deserialize(caseObj, Map<String,String>.class);
	    	//System.debug(adminLowTouchCS + '\n\n4~~~~inputFormMap:' + inputFormMap);
	    	caseObject = (Case)JSON.deserialize(caseObj, Case.class);
	    	/*String ltcaseRecordType = adminLowTouchCS != null && String.isNotBlank(adminLowTouchCS.REN_Request_Contact_Case_Type__c) ? adminLowTouchCS.REN_Request_Contact_Case_Type__c : '';
	    	
	    	if(adminLowTouchCS != null && String.isNotBlank(adminLowTouchCS.REN_Request_Contact_Case_Type__c)){
	            List<RecordType> recordTypeList = CSM_CaseDataAccess.getRecordTypes ('Case', adminLowTouchCS.REN_Request_Contact_Case_Type__c);
	            if(recordTypeList != null && !recordTypeList.isEmpty()){
		              caseObject.put('RecordTypeId', recordTypeList[0].id);
	            }
	        }*/
	        String ltCaseQueue = 'Digital Renewals Case';
	    	if(CSM_AccessController.hasField('Case', CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c') && String.isNotBlank(oppId)){
	    		caseObject.put(CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c', oppId);
	    	}
	    	List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId});	    	
            List<QueueSobject> queueObjlist = database.query('SELECT QueueId FROM QueueSobject WHERE SobjectType = \'Case\' AND (Queue.Name =:ltCaseQueue) Limit 1'); // \'Data Update\'
	    	String accId = null;
	    	if(oppList != null && !oppList.isEmpty()){
	    		accId = oppList[0].AccountId + '';
	    	}
	    	//System.debug( oppId + '\n\n4~~~~accId:' + accId);
	    	String name = inputFormMap.get('ContactId');
	    	List<Contact> contactList = CSM_ContactDataAccess.contactExactSearch( inputFormMap.get('ContactEmail'));
	    	sp = Database.setSavepoint();
	    	if(contactList == null || contactList.isEmpty()){
	    		Contact contactObj = new Contact();
	    		contactObj.accountId = accId;
	    		//{"Subject":"test","AccountId":"1","ContactId":"2","ContactEmail":"3","ContactMobile":"4","ContactPhone":"5","ContactFax":"6","Reason":"test-11","Description":"test22"}
	    		
	    		if(String.isNotBlank(name)){
	    			name = name.trim();
	    			if(name.lastIndexOf(' ') > 0){
	    				contactObj.FirstName = name.substring(0,name.lastIndexOf(' '));
	    				contactObj.LastName = name.substring(name.lastIndexOf(' '));
	    			}else{
	    				contactObj.LastName = name;
	    			}
	    		}
	    		
	    		contactObj.Phone = inputFormMap.get('ContactPhone');
	    		contactObj.Fax = inputFormMap.get('ContactFax');
	    		contactObj.MobilePhone = inputFormMap.get('ContactMobile');
	    		contactObj.Email = inputFormMap.get('ContactEmail');
	    		
	    		contactList = new List<Contact>{contactObj};
	    		
	    		CSM_ContactDataAccess.insertContact(contactList);
	    		
	    		caseObject.ContactId = contactList[0].id;
	    		//System.debug( '\n\n4~~~~Created contactList:' + contactList);
	    	}else{
	    		caseObject.ContactId = contactList[0].id;
	    		//System.debug( '\n\n4~~~~Existing contactList:' + contactList);
	    	}
	    	
	    	//Added for US2960:	LT - Update Create a Sales Request Contact Logic
	    	String contactMobile = String.isNotBlank(inputFormMap.get('ContactMobile')) ? 'ContactMobile:'+inputFormMap.get('ContactMobile') +',\n'+'': '';
	    	String contactFax = String.isNotBlank(inputFormMap.get('ContactFax')) ? 'ContactFax:'+inputFormMap.get('ContactFax') +',\n': '';
	        String contactPhone = String.isNotBlank(inputFormMap.get('ContactPhone')) ? 'ContactPhone:'+inputFormMap.get('ContactPhone') +',\n': '';
	    	
	    	caseObject.description = 'Subject: '+inputFormMap.get('Subject')+',\n'+'Name: '+ name+',\n'+'ContactEmail: '+inputFormMap.get('ContactEmail')+ ',\n'+contactPhone + contactMobile + contactFax + inputFormMap.get('Description');
	    	caseObject.REN_Case_From_LT__c = true;
	    	caseObject.ownerId = queueObjlist != null && !queueObjlist.isEmpty() ? queueObjlist[0].QueueId : UserInfo.getUserID();
	    	caseObject.type = Label.REN_LT_DIGITAL_RENWALS_CASE;
	    	List<Case> caseList = new List<Case>{caseObject};
	    	CSM_CaseDataAccess.insertCases(caseList);
    	}catch(Exception e){
    		caseObject = new Case();
    		Database.rollback(sp); 
    		caseObject.description = 'Error: ' + e.getMessage();
    		REN_HandleOpportunityStageUpdate.updateErrorLog(system.label.CHL_LBL_CONTACT_ME, e.getMessage(), oppId);
    	}
    	return caseObject;
    }

    @AuraEnabled
    public static CaseFormWrapper getCaseFormDetail(String oppId,Map<String,String> mapOfTranslatedLabels) {
    	CaseFormWrapper form = new CaseFormWrapper();
    	//fsName = CSM_Util.getNamespace()+'csm_low_touch_contact_form';
    	form.fieldSetMemberList = REN_LT_FieldSetMember.getFields('Case', CSM_Util.getNamespace()+'csm_low_touch_contact_form',mapOfTranslatedLabels);
    	List<OpportunityContactRole> oppContactList = null;
    	form.contactObj = new Contact();
    	if(String.isNotBlank(oppId)){
    		oppContactList = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppId});
    	}
    	if(oppContactList != null && !oppContactList.isEmpty()){
    		form.contactObj = oppContactList[0].Contact;
    	}
        form.jsCssFilePathList = new List<String>();
        
        //String baseURL = REN_Util.getStaticResourcePath('jquery_validation');
		//form.jsCssFilePathList.add(baseURL+ '/dist/jquery.validate.js'); 
		//form.validationRule = REN_LT_FieldSetMember.getValidationRules(form.fieldSetMemberList); 
		

        
    	//System.debug('\n\n~~~~form: ' + form);
        return form;
    }
    
    public class CaseFormWrapper {
	    @AuraEnabled
	    public List<REN_LT_FieldSetMember> fieldSetMemberList { get;set; }
	
	    @AuraEnabled
	    public Contact contactObj { get;set; }
        
	    @AuraEnabled
	    public List<String> jsCssFilePathList { get;set; }
    	
	    @AuraEnabled
	    public REN_LT_FieldSetMember.ValidationRules validationRule { get;set; }
    	
    }
    
}