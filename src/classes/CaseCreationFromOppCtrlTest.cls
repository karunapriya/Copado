/**
 * Created Date		: Aug 30, 2018
 * Developed By		: Smita, Comity Designs, Inc.
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
 * Smita					User Story				Aug 30, 2018			1.1					@description
 *
 
 */
@isTest
private class CaseCreationFromOppCtrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		Account acc = new Account();
                acc.Name = 'Test Account';
                insert acc;
        
        Contact testContact1 = new Contact(
            AccountId = acc.Id,
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Email = 'testContact1@servicesource.com',
            System_User_Reference__c = UserInfo.getUserId());
        	insert testContact1;
                
       Opportunity testOpportunity2 = new Opportunity(
            Name = 'testOpportunity2',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            StageName = 'Not Contacted',
            CurrencyIsoCode = 'USD',
            Amount = 25000,
            Business_Line__c = 'Core',
            Engagement_Type__c = 'SREV',
            Opportunity_Type__c = 'Enterprise',
            SSI_Theatre__c = 'NALA',
            Client_Region__c = 'USA',
            Client_Territory__c = 'USA',
            Country__c = 'United States');       
        insert testOpportunity2;
        
	}
	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        list<Opportunity> oppList = [select Id from Opportunity limit 1];
        system.assert(oppList != null);
        Test.startTest();
        ApexPages.StandardController casest = new ApexPages.standardController(oppList[0]);
       CaseCreationFromOppCtrl caseCtrl = new  CaseCreationFromOppCtrl(casest);
        caseCtrl.getRedirect();
        Test.stopTest();       
    }
}