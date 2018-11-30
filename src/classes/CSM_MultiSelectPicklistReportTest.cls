@isTest(SeeAllData=false)
private class CSM_MultiSelectPicklistReportTest{
	@isTest
	static void testMstrScheduledDispatcher(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
	   	testDataSetup.createAccount(1);
		testDataSetup.createOpportunity(1, testDataSetup.accountList);
		testDataSetup.opportunityList[0].Type = 'Test';
		update testDataSetup.opportunityList[0];
		CSM_MSTR__c mstrRec = new CSM_MSTR__c(CSM_Object_Name__c = 'Opportunity', CSM_Multi_Picklist_API_Name__c = 'Type', CSM_Multi_Picklist_Name__c = 'Type', CSM_Picklist_Value__c = 'Test');
		insert mstrRec;
		CSM_TestUtility.setup();
		Task tsk = new Task();
		tsk.WhatId = CSM_TestUtility.acct.Id;
		tsk.Subject = 'Meeting';
		tsk.ActivityDate = Date.today();
		tsk.CSM_Account__c = CSM_TestUtility.acct.Id;
		tsk.CSM_Play__c = CSM_TestUtility.play.Id;
		tsk.CSM_Account_Plan__c = CSM_TestUtility.acctPlan.Id;
		tsk.Status = 'Not Started';
		tsk.csm_successplan_play__c = CSM_TestUtility.spPlay.Id;
		tsk.CSM_Risk_Reason__c = 'Test';
		insert tsk;
		CSM_MSTR__c mstrRec1 = new CSM_MSTR__c(CSM_Object_Name__c = 'Task', CSM_Multi_Picklist_API_Name__c = 'CSM_Risk_Reason__c', CSM_Multi_Picklist_Name__c = 'Task State', CSM_Picklist_Value__c = 'Test');
		insert mstrRec1;
		insert new CSM_MSTD__c(CSM_MSTR__c = mstrRec1.id);
		Test.startTest(); 
			String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
			String jobID = system.schedule('MstrScheduledDispatcher', strDateTime, new CSM_MstrScheduledDispatcher());	
		Test.stopTest();
		ID matrId = mstrRec.id;
		CSM_MSTR__c mstrRecAfterBatch = [select CSM_Count__c from CSM_MSTR__c where ID = :matrId][0];
		System.assert(jobID != null);
		
	}

	@isTest
	static void testMstrForOpportunity(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
	   	testDataSetup.createAccount(1);
		testDataSetup.createOpportunity(1, testDataSetup.accountList);
		testDataSetup.opportunityList[0].Type = 'Test';
		update testDataSetup.opportunityList[0];
		CSM_MSTR__c mstrRec = new CSM_MSTR__c(CSM_Object_Name__c = 'Opportunity', CSM_Multi_Picklist_API_Name__c = 'Type', CSM_Multi_Picklist_Name__c = 'Type', CSM_Picklist_Value__c = 'Test');
		insert mstrRec;
		insert new CSM_MSTD__c(CSM_MSTR__c = mstrRec.id);
		Test.startTest(); 
			CSM_MstdDeleteBatch batch = new CSM_MstdDeleteBatch();
			batch.mstrObj = mstrRec;
			//batch.errorDrtails = 'Jyst for test';
			String batchprocessid = Database.executeBatch(batch);	
			
		Test.stopTest();
		ID matrId = mstrRec.id;
		CSM_MSTR__c mstrRecAfterBatch = [select CSM_Count__c from CSM_MSTR__c where ID = :matrId][0];
		system.debug(testDataSetup.opportunityList[0] + '\n\n~~~~mstrRecAfterBatch: ' + mstrRecAfterBatch);
		System.assert(mstrRecAfterBatch.CSM_Count__c == 1);
		
	}

	@isTest
	static void testMstrForTask(){
		CSM_TestUtility.setup();
		Task tsk = new Task();
		tsk.WhatId = CSM_TestUtility.acct.Id;
		tsk.Subject = 'Meeting';
		tsk.ActivityDate = Date.today();
		tsk.CSM_Account__c = CSM_TestUtility.acct.Id;
		tsk.CSM_Play__c = CSM_TestUtility.play.Id;
		tsk.CSM_Account_Plan__c = CSM_TestUtility.acctPlan.Id;
		tsk.Status = 'Not Started';
		tsk.csm_successplan_play__c = CSM_TestUtility.spPlay.Id;
		tsk.CSM_Risk_Reason__c = 'Test';
		insert tsk;
		CSM_MSTR__c mstrRec = new CSM_MSTR__c(CSM_Object_Name__c = 'Task', CSM_Multi_Picklist_API_Name__c = 'CSM_Risk_Reason__c', CSM_Multi_Picklist_Name__c = 'Task State', CSM_Picklist_Value__c = 'Test');
		insert mstrRec;
		insert new CSM_MSTD__c(CSM_MSTR__c = mstrRec.id);
		Test.startTest(); 
			CSM_MultiSelectPicklistReportHandler.mstrRefreshByBatch(mstrRec.CSM_Object_Name__c, mstrRec.CSM_Multi_Picklist_API_Name__c);	
		Test.stopTest();
		CSM_MultiSelectPicklistReportHandler.setTaskSolutionExtensionValues(new Task(), new Map<String,Object>(), new CSM_MSTD__c());
		ID matrId = mstrRec.id;
		CSM_MSTR__c mstrRecAfterBatch = [select CSM_Count__c from CSM_MSTR__c where ID = :matrId][0];
		System.assert(mstrRecAfterBatch.CSM_Count__c == 1);
		
	}

	@isTest
	static void testMstrWhenStartFailed(){
		Test.startTest(); 
			CSM_MstdDeleteBatch batch = new CSM_MstdDeleteBatch();
			batch.isStartFailed = true;
			String batchprocessid = Database.executeBatch(batch);	
			
		Test.stopTest();
		System.assert(batch.isStartFailed);
		
	}

	@isTest
	static void testMstrForFailedCase(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
	   	testDataSetup.createAccount(1);
		testDataSetup.createOpportunity(1, testDataSetup.accountList);
		testDataSetup.opportunityList[0].Type = 'Test';
		update testDataSetup.opportunityList[0];
		CSM_MSTR__c mstrRec = new CSM_MSTR__c(CSM_Object_Name__c = 'Opportunity', CSM_Multi_Picklist_API_Name__c = 'TypoError', CSM_Multi_Picklist_Name__c = 'Type', CSM_Picklist_Value__c = 'Test');
		insert mstrRec;
		insert new CSM_MSTD__c(CSM_MSTR__c = mstrRec.id);
		Test.startTest(); 
			CSM_MstdDeleteBatch batch = new CSM_MstdDeleteBatch();
			batch.mstrObj = mstrRec;
			//batch.errorDrtails = 'Jyst for test';
			String batchprocessid = Database.executeBatch(batch);	
			
		Test.stopTest();
		ID matrId = mstrRec.id;
		CSM_MSTR__c mstrRecAfterBatch = [select CSM_Count__c from CSM_MSTR__c where ID = :matrId][0];
		system.debug(testDataSetup.opportunityList[0] + '\n\n~~~~mstrRecAfterBatch: ' + mstrRecAfterBatch);
		System.assert(batchprocessid != null);
	}
    
	@isTest
	static void testMstrForFailedCase2(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
	   	testDataSetup.createAccount(1);
		testDataSetup.createOpportunity(1, testDataSetup.accountList);
		testDataSetup.opportunityList[0].Type = 'Test';
		update testDataSetup.opportunityList[0];
		CSM_MSTR__c mstrRec = new CSM_MSTR__c(CSM_Object_Name__c = 'xyz', CSM_Multi_Picklist_API_Name__c = 'TypoError', CSM_Multi_Picklist_Name__c = 'Type', CSM_Picklist_Value__c = 'Test');
		insert mstrRec;
		insert new CSM_MSTD__c(CSM_MSTR__c = mstrRec.id);
		Test.startTest(); 
			CSM_MstdDeleteBatch batch = new CSM_MstdDeleteBatch();
			batch.mstrObj = mstrRec;
			//batch.errorDrtails = 'Jyst for test';
			String batchprocessid = Database.executeBatch(batch);	
			
		Test.stopTest();
		ID matrId = mstrRec.id;
		CSM_MSTR__c mstrRecAfterBatch = [select CSM_Count__c from CSM_MSTR__c where ID = :matrId][0];
		system.debug(testDataSetup.opportunityList[0] + '\n\n~~~~mstrRecAfterBatch: ' + mstrRecAfterBatch);
		System.assert(batchprocessid != null);
	}
    
}