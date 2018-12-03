@isTest
private class REN_SetOpportunityCloseDateBatchTest {
	public static Opportunity newOpportunity;
	public static PricebookEntry customPrice;
	public static List<Account> accList;
	public static Product2 prod;
	
	 @testSetup public static void setup() {
	 	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Batch_Activity__c batchActivity = new REN_Batch_Activity__c ();
		batchActivity.REN_Status__c = REN_Constants.STATUS_PROCESSING;
		batchActivity.REN_Closed_Date_Options__c = REN_Constants.EARLIEST_DATE;
		batchActivity.REN_Grouping__c = testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0].id;
	    batchActivity.REN_Source_Record_Filter__c = testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0].id;
	    batchActivity.REN_Closed_Date_Depends_On__c = 'InstallDate';
        insert batchActivity;
        system.assert(batchActivity.Id != null);
		accList  = CSM_TestDataUtility.createAccount(1);
    	
    	newOpportunity = new Opportunity();
		newOpportunity.accountId = accList[0].id;
		newOpportunity.Name = 'New Opp ' ;
		newOpportunity.CloseDate = System.Today();
		newOpportunity.StageName = 'Qualification';
		newOpportunity.REN_Batch_Activity_ID__c = (''+batchActivity.ID).subString(0,15);
		newOpportunity.REN_Is_Consolidated__c = false;
		insert newOpportunity; 
		 
		Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
    	insert customPB;
    	
    	prod = REN_TestDataUtility.createProduct(1);
    	insert prod;
    	
    	Id pricebookId = Test.getStandardPricebookId();
    
    	PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
    	insert standardPrice;
    	system.assert(standardPrice.Id != null);
    	customPrice = new PricebookEntry(
        Pricebook2Id = customPB.Id, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
    	insert customPrice;
		createAssetandOLI();	 	
	 }

	public static void createAssetandOLI()
    {
    	Date initialDate = Date.newInstance(2015,09,01);
    	List<OpportunityLineItem> opptyLineItemList = new List<OpportunityLineItem>(); 
    	List<REN_Renews_To__c> renewrelList = new List<REN_Renews_To__c>(); 
    	List<Asset> assetList = new List<Asset>();
    	
    	for(integer i=0; i<=4; i++){
			OpportunityLineItem opptyLineItem = new OpportunityLineItem();
			opptyLineItem.OpportunityId = newOpportunity.Id;
			opptyLineItem.Quantity = 1.0+i; 
			opptyLineItem.TotalPrice = 12000+i; 
			opptyLineItem.PricebookEntryId = customPrice.Id;
			opptyLineItem.REN_Start_Date__c = initialDate + i;
			opptyLineItem.REN_End_Date__c = initialDate + 3 + i;
			opptyLineItemList.add(opptyLineItem);
		}
		insert opptyLineItemList;
		
		for(integer i=0; i<=4; i++){
			Asset asset = new Asset();
			asset.Name = 'Asset'+i;
			asset.AccountId= accList[0].id; 
			asset.Product2 = prod;
			asset.Price = 12000 + i;
			asset.PurchaseDate = initialDate + i;
			asset.InstallDate = initialDate + i + 1;
			asset.REN_Start_Date__c = initialDate + i + 2;
			asset.REN_End_Date__c = initialDate + i + 3;
			asset.REN_Oppty_Line_Item_Id__c = opptyLineItemList[i].id;
			asset.REN_Opportunity__c = newOpportunity.Id;
			assetList.add(asset);
		}
		insert assetList;
		
		for(integer i=0; i<=4; i++){
    		REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
			renRelationObj.Name = 'Ren-OPP'+i;
			renRelationObj.REN_Asset__c = assetList[i].Id;
			renRelationObj.REN_Renews_To__c = newOpportunity.Id;
			//renRelationObj.REN_Renewal_Product_Line_Id__c = opptyLineItemList[i].Id;
			renewrelList.add(renRelationObj);
		}
		insert renewrelList;
    }
	
	static testMethod void testBatchOppEarliestCloseDate() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.EARLIEST_DATE;
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
        
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		
		List<Opportunity> oppList = [Select id,closedate FROM Opportunity Limit1];
		system.assertequals(oppList[0].closedate,Date.newInstance(2015,09,02));
		try{
			REN_Util.sendEmailNotificationUsingTemplate(new Set <Id>{UserInfo.getUserID()}, '' + UserInfo.getUserID(), batchActivityList[0].id);
		}catch(Exception e){
			REN_Util.setErrorInObjects(batchActivityList, e);
		}
	}
	
	static testMethod void testBatchOppLatestCloseDate() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.LATEST_DATE;
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
        
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		List<Opportunity> oppList = [Select id,closedate FROM Opportunity];
		system.assertequals(oppList[0].closedate,Date.newInstance(2015,09,6));
	}
	
	static testMethod void testBatchOppCommonCloseDate() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.COMMON_DATE;
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
        
        List<Asset> assetList = [Select id,InstallDate from Asset Limit 1];
		assetList[0].InstallDate = Date.newInstance(2015,09,4);	
		update assetList;
		
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		List<Opportunity> oppList = [Select id,closedate FROM Opportunity];
		system.assertequals(oppList[0].closedate,Date.newInstance(2015,09,04));
	}
	
	static testMethod void testBatchOppValuableCloseDate() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.VALUABLE_DATE;
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
		
		List<Asset> assetList = [Select id,InstallDate from Asset Limit 1];
		assetList[0].InstallDate = Date.newInstance(2015,09,5);	
		update assetList;
		
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		List<Opportunity> oppList = [Select id,closedate FROM Opportunity];
		system.assertequals(oppList[0].closedate,system.today());
	}
	
	static testMethod void testBatchOppNullCloseDate() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.VALUABLE_DATE;
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
		List<Asset> assetList = [Select id,InstallDate from Asset Limit 100];
		for(Asset asst : assetList){
			asst.InstallDate = null;
		}
		update assetList;
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		List<Opportunity> oppList = [Select id,closedate FROM Opportunity Limit 100];
		system.assert(oppList.isEmpty());
	}
	
	static testMethod void testBatchFailure() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.VALUABLE_DATE;
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
		List<Asset> assetList = [Select id,InstallDate from Asset Limit 100];
		for(Asset asst : assetList){
			asst.InstallDate = null;
		}
		update assetList;
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		List<REN_Batch_Activity__c> batchActivityListRes = [Select id,REN_Status__c from REN_Batch_Activity__c LIMIT 1];
		system.assertEquals(REN_Constants.STATUS_FAILED,batchActivityListRes[0].REN_Status__c);
	}
	
	static testMethod void testBatchPartial() {
		List<REN_Batch_Activity__c> batchActivityList = [Select id,REN_Closed_Date_Options__c,REN_Failure_Assets__c from REN_Batch_Activity__c LIMIT 1];
		batchActivityList[0].REN_Failure_Assets__c = 1;//failure can be carried over from previous batch
		batchActivityList[0].REN_Closed_Date_Options__c = REN_Constants.VALUABLE_DATE; 
		batchActivityList[0].REN_Closed_Date_Depends_On__c = 'InstallDate';
        update batchActivityList;
		
		Test.startTest();
		system.assert(batchActivityList[0].Id != null);
		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityList[0],'',false),1);
		Test.stopTest();
		List<REN_Batch_Activity__c> batchActivityListRes = [Select id,REN_Status__c from REN_Batch_Activity__c LIMIT 1];
		system.assertEquals(REN_Constants.STATUS_PARTIAL_SUCCESS,batchActivityListRes[0].REN_Status__c);
	}
	
}