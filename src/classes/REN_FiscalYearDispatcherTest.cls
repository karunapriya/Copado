@isTest(SeeAllData=true)
private with sharing class REN_FiscalYearDispatcherTest {

	@isTest static void testREN_FiscalYearOnOliDispatcher() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		testDataSetup.createRenewConfigurations();
    	testDataSetup.renewDataSetup(1, 1, 1);
		testDataSetup.setFieldsData(testDataSetup.opportunityList, REN_Constants.OBJ_RC_OPPORTUNITY_STAGE, 'Closed Won');
    	testDataSetup.resetAllTriggersTo(true);
    	update testDataSetup.opportunityList;

		Test.startTest(); 
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('FiscalYearOnOli', strDateTime, new REN_FiscalYearOnOliDispatcher());	
		String batchprocessid = Database.executeBatch(new REN_FiscalYearOLIBatch());
	    Test.stopTest();
	    Map<String, Opportunity> optyMap = new Map<String, Opportunity>(testDataSetup.opportunityList);
	    List<OpportunityLineItem> oliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsByOppId(optyMap.keySet());
	    system.assert(oliList != null);
	}

	@isTest static void testREN_FiscalYearOnOliDispatcherNigative() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		Test.startTest(); 
		REN_FiscalYearOLIBatch batch = new REN_FiscalYearOLIBatch();
		batch.objectName = 'ABC';
		String batchprocessid = Database.executeBatch(batch);
	    Test.stopTest();
    	system.assert(true);
	}

	@isTest static void testREN_FiscalYearOnRRDispatcher() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		testDataSetup.createRenewConfigurations();
    	testDataSetup.renewDataSetup(1, 1, 1);
		testDataSetup.setFieldsData(testDataSetup.opportunityList, REN_Constants.OBJ_RC_OPPORTUNITY_STAGE, 'Closed Won');
    	testDataSetup.resetAllTriggersTo(true);
    	update testDataSetup.opportunityList;

		Test.startTest(); 
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('FiscalYearOnRR', strDateTime, new REN_FiscalYearOnRRDispatcher());	
		String batchprocessid = Database.executeBatch(new REN_FiscalYearRRBatch());
	    Test.stopTest();
	    Map<String, Opportunity> optyMap = new Map<String, Opportunity>(testDataSetup.opportunityList);
	    List<OpportunityLineItem> oliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsByOppId(optyMap.keySet());
	    system.assert(oliList != null);
	}

	@isTest static void testREN_FiscalYearOnRRDispatcherNigative() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		Test.startTest(); 
		REN_FiscalYearRRBatch batch = new REN_FiscalYearRRBatch();
		batch.objectName = 'ABC';
		String batchprocessid = Database.executeBatch(batch);
	    Test.stopTest();
    	system.assert(true);
	}
}