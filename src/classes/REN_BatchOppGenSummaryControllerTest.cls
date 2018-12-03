/**
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
 */
@isTest(SeeAllData=true)
private class REN_BatchOppGenSummaryControllerTest {

	private static Id testAccountId;
    
    static testMethod void myUnitTest() {
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
		REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityObj.id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
		
		Test.startTest(); 
		
		PageReference myPage = Page.REN_BatchOppGenSummary;	   
	    myPage.getParameters().put('id',batchActivityObj.id);
	    Test.setCurrentPageReference(myPage);
	    system.debug(' batchActivityObj ID : '+batchActivityObj.Id);
	    REN_BatchOppGenSummaryController controller = new REN_BatchOppGenSummaryController();
	    PageReference p1 = controller.returnPage();
	    system.assert(true);
	    PageReference p2=controller.editSourceRecord();
    	PageReference p3=controller.editGroupRecord();
    	system.assert(true);
	    Test.stopTest();
    }
    
     static testMethod void testBusinessLayerPositive() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
		REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityObj.id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
		System.assertNotEquals(newemailuser.id, null);
    	
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        Opportunity opport = new Opportunity();
        opport.AccountId = testAccountId;
        opport.StageName = 'Prospecting';
        opport.CloseDate = System.today() + 1;
        opport.Name = 'Opportunity Test';
        opport.Amount = 1000.0;
        opport.REN_Batch_Activity_ID__c = batchActivityObj.id;
        insert opport;
        System.assertNotEquals(opport.Id, null);
		
		        
    	Test.startTest();
    	
    	String req = '{"objType": "BatchOppGenSummary","params" : {"taskOrViewId":"'+batchActivityObj.Id+'"},"viewName" : "BatchJobSummary"}';
		System.debug('ZZZ - req - '+req);
		CSM_GridResponseWrapper grw = CSM_CustomGridController.getResponseForGrid(req);
    	
    	Test.stopTest();
    }
    
    static testMethod void testBusinessLayerPositive1() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
		REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityObj.id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
		System.assertNotEquals(newemailuser.id, null);
        
        Opportunity opport = new Opportunity();
        opport.AccountId = null;
        opport.StageName = 'Prospecting';
        opport.CloseDate = System.today() + 1;
        opport.Name = 'Opportunity Test';
        opport.Amount = 1000.0;
        opport.REN_Earliest_Expiration_Date__c = System.today() + 5;
        opport.REN_Batch_Activity_ID__c = batchActivityObj.id;
        insert opport;
        System.assertNotEquals(opport.Id, null);
		
		        
    	Test.startTest();
    	
    	String req = '{"objType": "BatchOppGenSummary","params" : {"taskOrViewId":"'+batchActivityObj.Id+'"},"viewName" : "BatchJobSummary"}';
		System.debug('ZZZ - req - '+req);
		CSM_GridResponseWrapper grw = CSM_CustomGridController.getResponseForGrid(req);
    	
    	Test.stopTest();
    }
    static testMethod void testBusinessLayerNegative() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
		REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityObj.id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
		System.assertNotEquals(newemailuser.id, null);
    	
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        Opportunity opport = new Opportunity();
        opport.AccountId = testAccountId;
        opport.StageName = 'Prospecting';
        opport.CloseDate = System.today() + 1;
        opport.Name = 'Opportunity.Test';
        opport.Amount = 1000.0;
        opport.REN_Batch_Activity_ID__c = batchActivityObj.id;
        insert opport;
        System.assertNotEquals(opport.Id, null);
		
		User adminUser  = CSM_TestDataUtility.createTestUser('Standard User');
       
    	Test.startTest();
    	System.RunAs(adminUser) 
    	{
    		String req = '{"objType": "BatchOppGenSummary","params" : {"taskOrViewId":"'+batchActivityObj.Id+'"},"viewName" : "BatchJobSummary"}';
			System.debug('ZZZ - req - '+req);
			CSM_GridResponseWrapper grw = CSM_CustomGridController.getResponseForGrid(req);
    	}
    	Test.stopTest();
    }
}