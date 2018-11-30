@isTest
public with sharing class REN_BatchOppGenDetailsCompCntrlTest {

	static testMethod void myUnitTest() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest')[0];
    	Test.startTest(); 
    	
    	REN_BatchOppGenDetailsCompCntrl controller = new REN_BatchOppGenDetailsCompCntrl();
	    system.assertEquals(controller.getRecordsReturned(), 'Records Returned: 0');
	    
	    controller.renConfigId = rc.Id;
	    controller.objType = 'groupWidget';
	    controller.updatefilterval();
	    system.assertEquals(controller.isFilterWidget, false);
	    
	    controller.objType = 'filterWidget';
	    controller.updatefilterval();
	    system.assertEquals(controller.getRecordsReturned(), 'Records Returned: 0');
	    system.assertEquals(controller.isFilterWidget, true);
	    //system.assertEquals(controller.getCriteria(), 'Asset Name != \'abc\' OR Asset Name != \'xyz\'');
	    system.assertEquals(controller.getViewName(), 'TestFilter: recordKey-1');
	    system.assertEquals(controller.getDescription(), 'This is TestFilter: recordKey-1');
	    controller.getFilterCriteria();
	    controller.objType='groupWidget';
	    controller.getGroupCriteria();
	    
	    Test.stopTest();
    }
  
}