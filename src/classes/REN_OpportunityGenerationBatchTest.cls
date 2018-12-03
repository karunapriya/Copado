@isTest(SeeAllData=true)
private class REN_OpportunityGenerationBatchTest {

	private static REN_TestDataSetup testDataSetup = null;

	@isTest static void testBatchOppGenScheduler() {
		setUp(true);
		testDataSetup.resetAllTriggersTo(true);
		Test.startTest(); 

		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		//String jobID = system.schedule('Batch Opportunity Generation1', strDateTime, new REN_BatchOppGenScheduledDispatcher());	
        //testDataSetup.batchActivityList[0].REN_Scheduler_ID__c = jobID;
        REN_BatchActivityDataAccess.saveBatchAct(testDataSetup.batchActivityList[0]);
    	//system.assert(jobID != null);
    	System.debug(Logginglevel.DEBUG,'\n\n1~~~~Created Opportunities: ' + testDataSetup.batchActivityList);
	    Test.stopTest();
    	Map<ID,Account> accMap = new Map<ID,Account>(testDataSetup.accountList);
    	Map<String, Account> accounttMap = new Map<String, Account>([select id, (select id, name from Opportunities) from Account where id in :accMap.keySet()]);
    	system.assert(accounttMap != null);
    	System.debug(Logginglevel.DEBUG,'\n\n2~~~~Created Opportunities: ' + accounttMap);
	}
	
	@isTest static void testBatchOppGenSchedulerNigative() {
		setUp(false);
		testDataSetup.resetAllTriggersTo(true);
		Test.startTest(); 

		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Batch Opportunity Generation1', strDateTime, new REN_BatchOppGenScheduledDispatcher());	
        testDataSetup.batchActivityList[0].REN_Scheduler_ID__c = jobID;
        REN_BatchActivityDataAccess.saveBatchAct(testDataSetup.batchActivityList[0]);
    	system.assert(jobID != null);
    	System.debug(Logginglevel.DEBUG,'\n\n1~~~~Created Opportunities: ' + testDataSetup.batchActivityList);
    	try{
			REN_Util.sendEmailNotificationUsingTemplate(new Set <Id>{UserInfo.getUserID()}, '' + UserInfo.getUserID(), testDataSetup.batchActivityList[0].id);
		}catch(Exception e){
			REN_Util.setErrorInObjects(testDataSetup.batchActivityList, e);
		}
	    Test.stopTest();
	}
	
	//Save error: Test class containing a test setup method cannot be annotated with @isTest(​SeeAllData=​true)
    static void setUp(boolean isValidTestData){ 
    	testDataSetup = new REN_TestDataSetup('ssTest4Batch');
    	testDataSetup.createRenewConfigurations();
    	testDataSetup.createProduct(40);
    	testDataSetup.createPricebookEntry(testDataSetup.product2List, null);

    	REN_Renew_Configuration__c myFilter = testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
    	myFilter.REN_Filter_Criteria__c = 'Name LIKE \'%ssTest4Batch%\'';
    	update myFilter;
    	
    	REN_Renew_Configuration__c renewConfig = new REN_Renew_Configuration__c();
    	renewConfig.REN_View_Name__c = myFilter.REN_View_Name__c +'_πRR';
		renewConfig.REN_Record_Key__c = myFilter.REN_Record_Key__c +'_πRR';
		renewConfig.REN_Is_Active__c = true;
		renewConfig.REN_Configuration_Type__c = REN_Constants.RENEW_REL_FILTER;
		renewConfig.REN_Filter_Criteria__c = 'Name != \'abc\'';
		renewConfig.RLM_Filter_Logic__c  = '1';
		renewConfig.REN_Description__c = 'This is ' + myFilter.REN_View_Name__c;
		insert renewConfig;
		
		REN_Renew_Configuration__c myGroup= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
    	myGroup.REN_Filter_Criteria__c = 'AccountId, Quantity';
    	update myGroup;
		ID pricebookId = testDataSetup.pricebookEntryList[0].Pricebook2Id;
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,myGroup, myFilter, DateTime.now(), pricebookId)[0];

    	if(!isValidTestData){
	    	myFilter.REN_Filter_Criteria__c = 'Name LIKE \'%ssTest4Batch%\' AND FALSE Date ';
	    	update myFilter;
    		return;
   	 	}
    	testDataSetup.createAccount(5);
		insert new REN_Email_Recipient__c(REN_Batch__c = batchActivityObj.id, REN_Recipient__c = UserInfo.getUserId());
		
		List<Asset> assetList = new List<Asset>();

    	for(Account acc: testDataSetup.accountList){
    		for(Integer i = 0; i < testDataSetup.product2List.size(); i++){
    			Product2 p = testDataSetup.product2List[i];
    			ID pid =  p.id;
    			Date sDate = System.today();
    			Date eDate = System.today();
    			Integer qty = Math.mod(i,5);
    			if(i == 5){
    				pid = null;
    			}
    			if(i == 6){
    				sDate = null;
    				eDate = null;
    			}
    			if(i == 7){
    				qty = null;
    			}
    			if(i == 8){
    				sDate = sDate + 10;
    				eDate = eDate + 15;
    			}
    			Asset a = new Asset(Name = p.name, accountId = acc.id, product2Id = pid, Quantity = qty, price=100, REN_Start_Date__c = sDate, REN_End_Date__c = eDate);
    			assetList.add(a);
    		}
    	}
    	insert assetList;
    	
    	List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
    	
    	REN_Field_Mappings__c fieldMapping = new REN_Field_Mappings__c();
    	fieldMapping.REN_Field_Data_Type__c = 'STRING';
    	fieldMapping.REN_From_Field_API_Name__c = 'Name';
    	fieldMapping.REN_From_Object_Api_Name__c = 'Asset';
    	fieldMapping.REN_Is_Required__c = true;
    	fieldMapping.REN_To_Field_API_Name__c = 'Name';
    	fieldMapping.REN_To_Object_API_Name__c = 'Opportunity';
    	fieldMappingList.add(fieldMapping);
    	
    	REN_Field_Mappings__c fieldMapping2 = new REN_Field_Mappings__c();
    	fieldMapping2.REN_Field_Data_Type__c = 'REFERENCE';
    	fieldMapping2.REN_From_Field_API_Name__c = 'AccountId';
    	fieldMapping2.REN_From_Object_Api_Name__c = 'Asset';
    	fieldMapping2.REN_Is_Required__c = false;
    	fieldMapping2.REN_To_Field_API_Name__c = 'AccountId';
    	fieldMapping2.REN_To_Object_API_Name__c = 'Opportunity';
    	fieldMappingList.add(fieldMapping2);
    	
    	REN_Field_Mappings__c fieldMapping3 = new REN_Field_Mappings__c();
    	fieldMapping3.REN_Field_Data_Type__c = 'DOUBLE';
    	fieldMapping3.REN_From_Field_API_Name__c = 'Quantity';
    	fieldMapping3.REN_From_Object_Api_Name__c = 'Asset';
    	fieldMapping3.REN_Is_Required__c = true;
    	fieldMapping3.REN_To_Field_API_Name__c = 'Quantity';
    	fieldMapping3.REN_To_Object_API_Name__c = 'OpportunityLineItem';
    	fieldMappingList.add(fieldMapping3);
    	
    	REN_Field_Mappings__c fieldMapping4 = new REN_Field_Mappings__c();
    	fieldMapping4.REN_Field_Data_Type__c = 'CURRENCY';
    	fieldMapping4.REN_From_Field_API_Name__c = '';
    	fieldMapping4.REN_From_Object_Api_Name__c = 'Asset';
    	fieldMapping4.REN_Is_Required__c = true;
    	fieldMapping4.REN_To_Field_API_Name__c = 'TotalPrice';
    	fieldMapping4.REN_To_Object_API_Name__c = 'OpportunityLineItem';
    	fieldMapping4.REN_Default_Value__c = '10000';
    	fieldMappingList.add(fieldMapping4);
    	
    	insert fieldMappingList;
	}
}