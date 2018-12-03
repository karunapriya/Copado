@isTest
public with sharing class CSM_ObjectFilterWidgetCompCtrlTest {

	static testMethod void myUnitTest() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest')[0];

    	Test.startTest(); 
    	CSM_ObjectFilterWidgetCompCtrl controller = new CSM_ObjectFilterWidgetCompCtrl(); 
	    controller.renConfigId = rc.Id;
	    system.assertEquals(controller.getViewName(), 'TestFilter: recordKey-1');
	    controller.getRenewConfig();
	    controller.getFilterCriteria();
	    String recordCnt = controller.getRecordsReturned();
	    system.assertEquals(controller.getRecordsReturned(), '0');
	    controller.renConfigId = '';
	    controller.getRenewConfig();
	    Test.stopTest();
    }
}