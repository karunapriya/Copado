/**
* @description    Test class for CHL_ContactBusinessLayer        
*/
@isTest 
public with sharing class CHL_ContactBusinessLayerTest {
	
	 @testSetup static void setup() {
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

		CHL_Partner_Opportunity__c parOptyObj = new CHL_Partner_Opportunity__c(); 
		parOptyObj.Name = 'testParOpp';
		parOptyObj.CHL_Opportunity__c = opptyList[0].id;
		insert parOptyObj; 		
		
	}
	
	static testmethod void constructGridWrapperTest(){
		CHL_Partner_Opportunity__c parOptyObj = [select Id from CHL_Partner_Opportunity__c limit 1];
		Test.startTest();			
			CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
			CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
			gridParams.oppId = parOptyObj.id;
		    inputWrapper.queryParams=gridParams;
			CHL_ContactBusinessLayer conBL=new CHL_ContactBusinessLayer(inputWrapper);
			CHL_AngularResponeWrapper wrapper = conBL.constructGridWrapper();
			system.assert(wrapper != null);
		Test.stopTest();
	}
	static testmethod void constructGridForAccount(){
		Account acc = [select Id from Account limit 1];
		Test.startTest();			
			CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
			CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
			gridParams.accountId = acc.Id;
		    inputWrapper.queryParams=gridParams;
			CHL_ContactBusinessLayer conBL=new CHL_ContactBusinessLayer(inputWrapper);
			CHL_AngularResponeWrapper wrapper = conBL.constructGridWrapper();
			system.assert(wrapper != null);
		Test.stopTest();
	}

}