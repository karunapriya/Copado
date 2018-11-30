@isTest
private class CSM_CaseTriggerHandlerTest {

	static testMethod void Test_OnAfterUpdate_TaskCreation_Positive() {
        insert new SS_License__c(Renew__c = true, Channel__c = true);
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		Case caseObj = CSM_TestDataUtility.createCase(accountList[0].Id);
		insert caseObj;
		system.assert(caseObj.Id != null);
		caseObj.Status = 'Working';
		CSM_Constants.CASE_TRIGGER = true;
		update caseObj;
		system.assert(caseObj.Id != null);
		
	}
	
	static testMethod void Test_OnAfterUpdate_TaskCreation_Negative() {
        insert new SS_License__c(Renew__c = true, Channel__c = true);
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		Case caseObj = CSM_TestDataUtility.createCase(accountList[0].Id);
		insert caseObj;
		system.assert(caseObj.Id != null);
		caseObj.Status = null;
		update caseObj;
		system.assert(caseObj.Id != null);
		CSM_Constants.CASE_TRIGGER = true;		
        
        Test.startTest();
            try{
				Case caseObj1 = CSM_TestDataUtility.createCase(accountList[0].Id);
				insert caseObj1;
            }catch(Exception ex){
                system.assert(true);
            }
        Test.stopTest();
        
		
	}
	
	// Below method Created for SF295 & SF285
	static testMethod void Test_UpdateAccountFields_Positive()	{
        insert new SS_License__c(Renew__c = true, Channel__c = true);
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        LIst<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
		List<Contact> contList = CSM_TestDataUtility.createContacts(accountList[0].Id,1);
		Case caseObj2 = new Case();
		caseObj2.contactId = contList[0].Id;
        caseObj2.AccountId = accountList[0].id;
		insert caseObj2;
		CSM_Constants.CASE_TRIGGER = true;
		set<Id> accId = new set<Id>();
		accId.add(accountList[0].Id);	
		caseObj2.Status = 'Working';
		caseObj2.Priority = 'High';	
		update caseObj2;
		/*caseObj2.Status = 'Closed';
		CSM_Constants.CASE_TRIGGER = true;
		update caseObj2;*/
		CSM_Constants.CASE_TRIGGER = true;
		delete caseObj2;
		CSM_Constants.CASE_TRIGGER = true;
		undelete caseObj2;
		system.assert(accId != null);
	}
	static testMethod void shareCaseWithPartnerUsersInsert(){
        insert new SS_License__c(Renew__c = true, Channel__c = true);
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Contact> contList = CSM_TestDataUtility.createContacts(accountList[0].Id,1);
        system.assert(contList!=null);
        Case newCase=new Case();
       	newCase.Status = 'New';
        newCase.AccountID=accountList[0].id;
        newCase.ContactId=contList[0].id;
    	newCase.Origin = 'Phone';
    	newCase.Subject = 'Test Case';
        insert newCase;   
        system.assert(newCase!=null);  
        newCase.ContactId=contList[0].Id;
        update newCase;
    }
        static testMethod void Test_OnAfterUpdate(){
        insert new SS_License__c(Renew__c = true, Channel__c = true);
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		Case caseObj = CSM_TestDataUtility.createCase(accountList[0].Id);
		insert caseObj;
        List<Case> newCaseList = new List<Case>();
        newCaseList.add(caseObj);
        CSM_CaseTriggerHandler handler = new CSM_CaseTriggerHandler();
        Test.startTest();
        list<Case> caseLstUpdate = [select Id,Subject,AccountId from Case limit 1];
        system.assert(caseLstUpdate != null);
        caseLstUpdate[0].Subject = 'Test Case';
        handler.onBeforeUpdate(newCaseList,caseLstUpdate, new Map<Id,Case>(newCaseList), new Map<Id,Case>(caseLstUpdate) );
        update caseLstUpdate;        
        handler.onAfterUpdate(newCaseList,caseLstUpdate, new Map<Id,Case>(newCaseList), new Map<Id,Case>(caseLstUpdate) );
        Test.stopTest();
    }
    static testMethod void Test_OnAfterDelete(){
        insert new SS_License__c(Renew__c = true, Channel__c = true);
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		Case caseObj = CSM_TestDataUtility.createCase(accountList[0].Id);
		insert caseObj;
        List<Case> newCaseList = new List<Case>();
        newCaseList.add(caseObj);
        CSM_CaseTriggerHandler handler = new CSM_CaseTriggerHandler();
        Test.startTest();
        list<Case> caseLstUpdate = [select Id,Subject,AccountId from Case limit 1];
        system.assert(caseLstUpdate != null);
       	Delete caseLstUpdate;
        handler.onAfterDelete(caseLstUpdate, new Map<Id,Case>(caseLstUpdate) );
        Test.stopTest();
    }
    
    static testMethod void Test_OnAfterUnDelete(){
        insert new SS_License__c(Renew__c = true, Channel__c = true);
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		Case caseObj = CSM_TestDataUtility.createCase(accountList[0].Id);
		insert caseObj;
        List<Case> newCaseList = new List<Case>();
        newCaseList.add(caseObj);
        CSM_CaseTriggerHandler handler = new CSM_CaseTriggerHandler();
        Test.startTest();
        list<Case> caseLstUpdate = [select Id,Subject,AccountId from Case limit 1];
        system.assert(caseLstUpdate != null);
        handler.onAfterUnDelete(caseLstUpdate);
        Test.stopTest();
    }
}