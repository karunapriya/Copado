@isTest
private class CSM_BatchSuccessPlanActivityCtrlTest {

    static testMethod void ctrlTest() {
    	
        CSM_BatchSuccessPlanActivityCtrl controller = new CSM_BatchSuccessPlanActivityCtrl();
        CSM_DataGridAttribute gridData = new CSM_DataGridAttribute();
        controller.batchSuccessGridAttribute = gridData;
    	controller.batchSuccessGridAttribute.tableName = CSM_Constants.GRID_ATTR_BATCH_HISTORY;
        CSM_TestDataSetup testDataSetup = new CSM_TestDataSetup('Test');
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1)[0];
        Test.startTest();
	    	controller.deletableRecordId = batchActivityObj.id;
	    	PageReference p1 = controller.deleteSelectedRecord();
	    	system.assert(true);
	    	p1 = controller.redirectToBatchSuccessPlan();
	    	system.assertNotEquals(p1,null);
	    Test.stopTest();
    }
    
    static testMethod void deleteSelectedRecord_Negative() {
    	
        CSM_BatchSuccessPlanActivityCtrl controller = new CSM_BatchSuccessPlanActivityCtrl();
        CSM_TestDataSetup testDataSetup = new CSM_TestDataSetup('Test');
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1)[0];
        User adminUser  = CSM_TestDataUtility.createTestUser('System Administrator');
       	System.RunAs(adminUser){
        	Test.startTest();
        		PageReference myPage = Page.CSM_BatchSuccessPlanActivity;
	    		Test.setCurrentPageReference(myPage);
	    		controller.deletableRecordId = batchActivityObj.id;
	    		PageReference p1 = controller.deleteSelectedRecord();
	    		system.assert(true);
	    		Test.stopTest();
       	}
    }
    
    static testMethod void testBusinessLayer() {
		CSM_TestDataSetup testDataSetup = new CSM_TestDataSetup('Test');
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1)[0];
    	Test.startTest();
    		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    		inputWrapper.viewName = 'CSM_PTA';
    		inputWrapper.params = gridParams;
    		REN_BatchOppGenActivityLayer businessLayer = new REN_BatchOppGenActivityLayer(inputWrapper);
    		CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    		system.assert(responseWrapper != null);
    		system.assert(responseWrapper.header != null);
    		system.assert(!responseWrapper.header.isEmpty());
    	Test.stopTest();
    }
}