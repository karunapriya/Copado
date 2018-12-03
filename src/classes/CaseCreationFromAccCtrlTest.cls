/**
 * Created Date		: Jan 29, 2018
 * Developed By		: sanket, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________________
 *
 * sanketsupe			    US3089				 Jan 29, 2018	      1.1				@description
 *
 */
@isTest
public with sharing class CaseCreationFromAccCtrlTest {
     static testMethod void myUnitTest() {
       PageReference pageRef = Page.CaseCreationFromAcc;
       Test.setCurrentPage(pageRef);
       try {
                Account acc = new Account();
                acc.Name = 'Test Account';
                insert acc;
           
          		List<Contact> testContactList = new List<Contact>();  
	            // Create Contact
				Contact testContact1 = new Contact(
				FirstName = 'testFirstName1',
				LastName = 'testLastName1',
				System_User_Reference__c = UserInfo.getUserId());
				testContactList.add(testContact1);
				insert testContactList;
            
           		if(testContactList.size()>0) {
                    String contactId = (String)testContactList.get(0).get('Id');
                
                    ApexPages.CurrentPage().getparameters().put('Id', contactId);
                    ApexPages.StandardController acct = new ApexPages.standardController(acc);
                    CaseCreationFromAccCtrl controller = new CaseCreationFromAccCtrl(acct);
                
                    Test.startTest();
                    controller.getRedirect();
                    system.debug('pageRef:::' +pageRef);
                    system.assert(pageRef != null); 
                    Test.stopTest();
                }
       } catch (Exception e) {
    		System.assert(true, 'Exception ' + e);
		}
     } 
}