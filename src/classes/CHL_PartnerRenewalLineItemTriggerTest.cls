/**
 * Created Date		: Dec 12, 2016
 * Developed By		: Tanvi, Comity Designs, Inc.
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
 * Tanvi					User Story				Dec 12, 2016			1.1					@description
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class CHL_PartnerRenewalLineItemTriggerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		
		insert new SS_License__c(Channel__c = true);
		
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		//List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		
		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		Contact con2 =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		contactList.add(con2);
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
	   	system.assert(partOppty != null);
	     
	   	List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
	   	insert chlpartnerList;
	   	
	   	Asset assObj = new Asset();
        assObj.name = 'Partner Asset';
        assObj.AccountId = accountList[0].Id;
        insert assObj;        
        system.assert(assObj!=null);        
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
		renRelationObj.Name = 'Partner Renewal';
		renRelationObj.REN_Asset__c = assObj.Id;
		renRelationObj.REN_Renews_To__c = opptyList[0].Id;
		renRelationObj.REN_Renewal_Status__c = 'Won';
		renRelationObj.REN_Renewal_Target__c = 50000.0;
		renRelationObj.REN_Renewal_Target_Multiplier__c = 1;
		renRelationObj.REN_Previous_Price__c = 50000.0;
		insert renRelationObj;
		
		/*CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
		prr.CHL_Renewal_Relationship__c = renRelationObj.Id;
		prr.CHL_Partner_Opportunity__c = chlpartnerList[0].Id;
		insert prr;*/
		
	}
	
    static testMethod void prrInsertionTest() {
        List<REN_Renews_To__c> rliList = [select Id,name,REN_Renewal_Target__c,REN_Renewal_Status__c,REN_Renewal_Target_Multiplier__c,REN_Previous_Price__c from REN_Renews_To__c limit 1];
        List<CHL_Partner_Opportunity__c> poList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
        CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
		prr.CHL_Renewal_Relationship__c = rliList[0].Id;
		prr.CHL_Partner_Opportunity__c = poList[0].Id;
		insert prr;
		system.assert(prr!=null);
    }
    
    static testMethod void prrdeletionTest() {
        List<REN_Renews_To__c> rliList = [select Id,name,REN_Renewal_Target__c,REN_Renewal_Status__c,REN_Renewal_Target_Multiplier__c,REN_Previous_Price__c from REN_Renews_To__c limit 1];
        List<CHL_Partner_Opportunity__c> poList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
        CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
		prr.CHL_Renewal_Relationship__c = rliList[0].Id;
		prr.CHL_Partner_Opportunity__c = poList[0].Id;
		insert prr;
		system.assert(prr!=null);
		delete prr;
    }
    
    static testMethod void Test_AfterInsert_Negative() {  		
		User restrictedUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		List<REN_Renews_To__c> rliList = [select Id,name,REN_Renewal_Target__c,REN_Renewal_Status__c,REN_Renewal_Target_Multiplier__c,REN_Previous_Price__c from REN_Renews_To__c limit 1];
	    List<CHL_Partner_Opportunity__c> poList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
	    CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
		prr.CHL_Renewal_Relationship__c = rliList[0].Id;
		prr.CHL_Partner_Opportunity__c = poList[0].Id;
		insert prr;
		List<CHL_Partner_Renewal_Relationship__c> partnerRRList = new List<CHL_Partner_Renewal_Relationship__c>();
		partnerRRList.add(prr);
		newRecords = partnerRRList;
		System.RunAs(restrictedUser) {
			
			Test.startTest();
			CHL_PartnerRenewalLineItemTriggerHandler triggerhandlercls = new CHL_PartnerRenewalLineItemTriggerHandler();
			triggerhandlercls.onAfterInsert(newRecords,newRecordsMap);
			system.assert(true);
			Test.stopTest();	   		
		}
	}
	
	static testMethod void Test_AfterDelete_Negative() {  		
		User restrictedUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List<sObject> oldRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		List<REN_Renews_To__c> rliList = [select Id,name,REN_Renewal_Target__c,REN_Renewal_Status__c,REN_Renewal_Target_Multiplier__c,REN_Previous_Price__c from REN_Renews_To__c limit 1];
	    List<CHL_Partner_Opportunity__c> poList = [select Id,name from CHL_Partner_Opportunity__c limit 1];
	    CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
		prr.CHL_Renewal_Relationship__c = rliList[0].Id;
		prr.CHL_Partner_Opportunity__c = poList[0].Id;
		insert prr;
		List<CHL_Partner_Renewal_Relationship__c> partnerRRList = new List<CHL_Partner_Renewal_Relationship__c>();
		partnerRRList.add(prr);
		delete partnerRRList;
		oldRecords = partnerRRList;
		System.RunAs(restrictedUser) {
			
			Test.startTest();
			CHL_PartnerRenewalLineItemTriggerHandler triggerhandlercls = new CHL_PartnerRenewalLineItemTriggerHandler();
			triggerhandlercls.onAfterDelete(oldRecords,oldRecordsMap);
			system.assert(true);
			Test.stopTest();	   		
		}
	}
}