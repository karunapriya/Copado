@isTest
private class REN_BatchOppFailureDataCleanupBatchTest {
	
	@testSetup public static void setup() {
		
		Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
    	insert customPB;
    	
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        ID testAccountId = accountList[0].Id;
        
        Product2 prod = REN_TestDataUtility.createProduct(1);
        
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
    	
    	Asset asset = REN_TestDataUtility.createAsset(testAccountId, prod.id);
    	
    	REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
    	
    	REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),customPB.id)[0];
		
		REN_Batch_Opportunity_Failure__c failureAsset = new REN_Batch_Opportunity_Failure__c();
        failureAsset.REN_Asset__c = asset.id;
		failureAsset.REN_Failure_Message__c = 'Test Fail';
		failureAsset.REN_Batch_Activity__c = batchActivityObj.id;
		insert failureAsset;
    }
	
	static testMethod void testManualMode() {
		REN_Batch_Activity__c batchActivity = [Select id from REN_Batch_Activity__c LIMIT 1];
		String batchActId = String.valueOf(batchActivity.id);
		batchActId = batchActId.substring(0,15);
		Test.startTest();
		Database.executeBatch(new REN_BatchOppFailureDataCleanupBatch(new Set<String>{batchActId}, true, -90), 200);
		Test.stopTest();
		List<REN_Batch_Opportunity_Failure__c> failureList = [Select id from REN_Batch_Opportunity_Failure__c where REN_Batch_Activity__c =: batchActId];
		system.assert(failureList.isEmpty());
	}
		
	static testMethod void testNonManualMode() {
		REN_Batch_Activity__c batchActivity = [Select id from REN_Batch_Activity__c LIMIT 1];
		String batchActId = String.valueOf(batchActivity.id);
		batchActId = batchActId.substring(0,15);
		Test.startTest();
		Database.executeBatch(new REN_BatchOppFailureDataCleanupBatch(new Set<String>{batchActId}, false, 2), 200);
		Test.stopTest();
		List<REN_Batch_Opportunity_Failure__c> failureList = [Select id from REN_Batch_Opportunity_Failure__c where REN_Batch_Activity__c =: batchActId];
		system.assert(failureList.isEmpty());
	}
}