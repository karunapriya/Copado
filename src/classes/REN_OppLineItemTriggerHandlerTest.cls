/**
 * @author      Smita Hinge (smitah@comitydesigns.com)    
 * @date         03/23/2018
 * @description  Test class for REN_OpportunityLineItemTriggerHandler class
 */
@isTest
public class REN_OppLineItemTriggerHandlerTest {
	@testSetup 
	static void setup() {
        insert new SS_License__c(Renew__c = true, Channel__c = true);
	
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
	
		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		System.assert(accountList != null);
	
		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		insert contactList;
	
		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList; 
        system.assert(opptyList != null);
		
		List<Product2> productList = CHL_TestUtility.createProducts(2);
		insert productList;
		
		List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
		insert pbeList;
		
        List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList;
        
        
    }  
    public static testMethod void insertOliTest(){
        list<Opportunity> opptyList = [select Id from Opportunity limit 1];
        List<PricebookEntry> pbeList = [select Id from PricebookEntry limit 1];
        system.assert(opptyList != null);
        Test.startTest();
        List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList;
        system.assert(opliList != null);
        
        Test.stopTest();
    }
    public static testMethod void insertSimplifiedOliTest(){
        list<Opportunity> opptyList = [select Id from Opportunity limit 1];
        List<PricebookEntry> pbeList = [select Id from PricebookEntry limit 1];
        Test.startTest();
        SS_License__c productIdSetting= SS_License__c.getOrgDefaults();
        productIdSetting.Simplified_Data_Model_Is_Enabled__c=true;
        update productIdSetting;
        List <OpportunityLineItem> opliList1 = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList1;
        system.assert(opliList1 != null);
        Test.stopTest();
    }
    public static testMethod void updateOliTest(){
    	List <OpportunityLineItem> opliList = [select Id,REN_Start_Date__c,REN_End_Date__c from OpportunityLineItem limit 1];        
        Test.startTest();
        opliList[0].REN_Start_Date__c = Date.today();
        opliList[0].REN_End_Date__c = Date.today();
        update opliList;
		system.assert(opliList != null);        
        Test.stopTest();	
    }
    public static testMethod void updateSimplifiedOliTest(){
        List <OpportunityLineItem> opliList = [select Id,REN_Start_Date__c,REN_End_Date__c from OpportunityLineItem limit 1];        
        SS_License__c productIdSetting= SS_License__c.getOrgDefaults();
        productIdSetting.Simplified_Data_Model_Is_Enabled__c=true;
        update productIdSetting;
        Test.startTest();
        opliList[0].Quantity = 2;
        update opliList;
        system.assert(opliList != null);
        Test.stopTest();
    }
    public static testMethod void deleteOliTest(){
        List <OpportunityLineItem> opliList = [select Id,REN_Start_Date__c,REN_End_Date__c from OpportunityLineItem limit 1];
        system.assert(opliList != null);
        Test.startTest();
        delete opliList[0];
        Test.stopTest();
    }
}