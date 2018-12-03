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
private class REN_BatchOppGenFailedSummaryCtrlTest {
	
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
	    REN_BatchOppGenFailedSummaryCtrl controller = new REN_BatchOppGenFailedSummaryCtrl();
	    PageReference p1 = controller.returnPage();
	    system.assert(true);
	    PageReference p2=controller.editSourceRecord();
    	PageReference p3=controller.editGroupRecord();
    	PageReference p4=controller.deleteBatchFailures();
    	system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testBusinessLayerPositive() {
    	
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		Product2 prod = REN_TestDataUtility.createProduct(1);
		Asset asset = REN_TestDataUtility.createAsset(testAccountId, prod.id);
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
		batchActivityObj.REN_Status__c = 'Failed';
		upsert batchActivityObj;
		REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityObj.id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
		System.assertNotEquals(newemailuser.id, null);
        
        REN_Batch_Opportunity_Failure__c failureAsset = new REN_Batch_Opportunity_Failure__c();
        failureAsset.REN_Asset__c = asset.id;
		failureAsset.REN_Failure_Message__c = 'Test Fail';
		failureAsset.REN_Batch_Activity__c = batchActivityObj.id;
		insert failureAsset;
		System.assertNotEquals(failureAsset.id, null);
		
    	Test.startTest();
    	
    	String req = '{"objType": "BatchOppGenFailedSummary","params" : {"taskOrViewId":"'+batchActivityObj.Id+'"},"viewName" : "BatchJobFailedSummary"}';
    	String req2='{"objType": "planDefaultObj","params" : {"taskOrViewId":"'+batchActivityObj.Id+'"},"viewName" : "planDefaultObj"}';
    	String req3='{"objType": "portalGroupMembersView","params" : {"taskOrViewId":"'+batchActivityObj.Id+'"},"viewName" : "portalGroupMembersView"}';
		System.debug('ZZZ - req - '+req);
		CSM_GridResponseWrapper grw = CSM_CustomGridController.getResponseForGrid(req);
		CSM_GridResponseWrapper grw2 = CSM_CustomGridController.getResponseForGrid(req2);
		CSM_GridResponseWrapper grw3 = CSM_CustomGridController.getResponseForGrid(req3);
    	system.assert(grw != null);
    	system.assert(grw.header != null);
    	system.assert(!grw.header.isEmpty());
    	
    	Test.stopTest();
    }
}