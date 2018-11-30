/**
* @description    Test class for CHL_RenRelationshipBusinessLayer        
*/
@isTest
public with sharing class CHL_RenRelationshipBusinessLayerTest {
	
    @testSetup
    static void setup() {  
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
		List<CHL_Partner_Opportunity__c> partnerOppList = [select name from CHL_Partner_Opportunity__c];
		CHL_GridInputWrapper gridInputWrapper = new CHL_GridInputWrapper();
		CHL_GridInputWrapper.CHL_CustomGridParams qp = new CHL_GridInputWrapper.CHL_CustomGridParams();
		qp.oppID = partnerOppList[0].id;
		CHL_RenRelationshipBusinessLayer rRBLObj = new CHL_RenRelationshipBusinessLayer(gridInputWrapper);
		rRBLObj.gridInputWrapper.queryParams = qp;    	
		Test.startTest();	
			CHL_AngularResponeWrapper resWrapper = rRBLObj.constructGridWrapper();
			system.assert(resWrapper != null);
		Test.stopTest();
	}

}