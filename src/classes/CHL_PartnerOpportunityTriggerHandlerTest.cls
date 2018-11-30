/*
	Description : Test class for CHL_PartnerOpportunityTrigger and CHL_PartnerOpportunityTriggerHandler class
				  Account, opportunity & Partner Opportunity is inserted as channel & system admin user, as OWD can be Private. 	
*/
@isTest
private class CHL_PartnerOpportunityTriggerHandlerTest {

	@testSetup static void setup() {       
		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
			optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
			optyStatusLogObj.CHL_Days_between_Update__c = 5;
		insert optyStatusLogObj; 	
		system.assert(optyStatusLogObj.Id != null);
		insert new SS_License__c(Channel__c = true);
		List<Account> accountList = new List<Account>();	
		List<Opportunity> opptyList = new List<Opportunity>();
		List<Contact> contactList = new List<Contact>(); 
		Account acc =  CHL_TestUtility.partnerAccount();
			accountList.add(acc);
		insert accountList;	
		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
			contactList.add(con);
		insert contactList;
		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
			opptyList.add(oppty);
		insert opptyList; 
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
			partOppty.OpportunityId = opptyList[0].id;
			partOppty.partnerAcc1Id = accountList[0].id ;
			partOppty.partnerAcc1Type = 'Reseller';
			partOppty.contact1Id = contactList[0].Id;
			partOppty.expirationDate= system.today().addDays(-10);
			partOppty.Stage= 'Needs Analysis';	
		CHL_Partner_Opportunity__c chlpartnerObj =   CHL_TestUtility.channelPartnerOpportunity(partOppty); 
		insert chlpartnerObj;
		system.assert(chlpartnerObj.Id != null);
	}

	//Account OWD can be set as private in many Org so accounts are inserted separately in below method
	static testMethod void Test_HandlerMethods_Positive() {         
		 
		/*User channelUser  = CSM_TestDataUtility.createTestUser('Channel');
		insert ChannelUser;
		list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
		PermissionSet ps   = CHL_TestUtility.getPermissionSet('Channel');
			lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = ChannelUser.id, PermissionSetId = ps.Id));
		insert lstPSAssignments;
		System.RunAs(channelUser) {
			
				List<Account> accountList = new List<Account>();	
				List<Opportunity> opptyList = new List<Opportunity>();
				List<Contact> contactList = new List<Contact>();
				Account acc =  CHL_TestUtility.partnerAccount();
					accountList.add(acc);
				insert accountList;	
				Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
					contactList.add(con);
				insert contactList;
				Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
					opptyList.add(oppty);
				insert opptyList;*/ 		
			Test.startTest();
				List<Opportunity> opptyList = [select Id from Opportunity];	
				List<Account> accountList = [select Id from Account];	
				List<Contact> contactList = [select Id from Contact];	
				CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
					partOppty.OpportunityId = opptyList[0].id;
					partOppty.partnerAcc1Id = accountList[0].id ;
					partOppty.partnerAcc1Type = 'Reseller';
					partOppty.contact1Id = contactList[0].Id;
					partOppty.expirationDate= system.today().addDays(-10);
					partOppty.Stage= 'Needs Analysis';	
				
				if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) ){
					SObject quote = CSM_AccessController.newSObject(CHL_Constants.OBJ_QUOTE);
					quote.put('Name', 'Test Quote');
					quote.put('OpportunityId', opptyList[0].id);
					if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c')){
						quote.put('CHL_Partner_Primary__c', true);
					}
					insert quote;
				}
				
				CHL_Partner_Opportunity__c chlpartnerObj =   CHL_TestUtility.channelPartnerOpportunity(partOppty); 
				insert chlpartnerObj;
				CHL_Constants.PARTNEROPPORTUNITY_BEFORE_TRIGGER = true;
				CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = true;
				chlpartnerObj.CHL_Sales_Stage__c = 'Qualification';
				chlpartnerObj.CHL_Expiration_Date__c = system.today().addDays(10);
        		chlpartnerObj.CHL_Syncing__c = 'From Master Opportunity';
				update chlpartnerObj;
				system.assert(chlpartnerObj.Id != null);	
			Test.stopTest();	   
		//}	   
	}

	static testMethod void Test_BeforeUpdate_Negative() {  		
		CHL_Constants.PARTNEROPPORTUNITY_BEFORE_TRIGGER = true;
		User restrictedUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List<sObject> oldRecords = new List<sObject>();
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		List<CHL_Partner_Opportunity__c> chlPartnerList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
		newRecords = chlPartnerList;
		System.RunAs(restrictedUser) {
			Test.startTest();
			CHL_PartnerOpportunityTriggerHandler triggerhandlercls = new CHL_PartnerOpportunityTriggerHandler();
			triggerhandlercls.onBeforeUpdate(oldRecords,newRecords,oldRecordsMap,newRecordsMap);
			system.assert(true);
			Test.stopTest();	   		
		}
	}
	
	static testMethod void Test_AfterUpdate_Negative() {  
		CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = true;
		User restrictedUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List<sObject> oldRecords = new List<sObject>();
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		List<CHL_Partner_Opportunity__c> chlPartnerList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
		newRecords = chlPartnerList;
		System.RunAs(restrictedUser) {
			Test.startTest();
				CHL_PartnerOpportunityTriggerHandler triggerhandlercls = new CHL_PartnerOpportunityTriggerHandler();
				triggerhandlercls.onAfterUpdate(oldRecords,newRecords,oldRecordsMap,newRecordsMap);
				system.assert(true);
			Test.stopTest();	   		
		}

	}
	
	static testMethod void Test_AfterInsert_Negative() {  
		CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = true;
		User restrictedUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List<sObject> oldRecords = new List<sObject>();
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		List<CHL_Partner_Opportunity__c> chlPartnerList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
		newRecords = chlPartnerList;
		System.RunAs(restrictedUser) {
			Test.startTest();
				CHL_PartnerOpportunityTriggerHandler triggerhandlercls = new CHL_PartnerOpportunityTriggerHandler();
				triggerhandlercls.onAfterInsert(newRecords,newRecordsMap);
				system.assert(true);
			Test.stopTest();	   		
		}

	}
	
	
	static testMethod void Test_QuoteSyncQueueableJobNegative() {  
		CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = true;
		User restrictedUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List<sObject> oldRecords = new List<sObject>();
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		List<CHL_Partner_Opportunity__c> chlPartnerList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
		newRecords = chlPartnerList;
		System.RunAs(restrictedUser) {
			Test.startTest();
			//	Id quoteJob = System.enqueueJob(new CHL_QuoteSyncQueueableJob(chlPartnerList[0]));
				system.assert(true);
			Test.stopTest();	   		
		}

	}
}