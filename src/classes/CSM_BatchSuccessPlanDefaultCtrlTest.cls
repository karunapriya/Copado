@isTest
private class CSM_BatchSuccessPlanDefaultCtrlTest {
    static testMethod void testPlanDefaultControllerPositive() {
    	List<CSM_Batch_Success_Plan_Default__c> planDefaultList = CSM_TestDataUtility.createSuccPlanDefRecord(1);
        Test.startTest();
        	Test.setCurrentPage(Page.CSM_BatchSuccessPlanDefault); 
        	ApexPages.currentPage().getParameters().put(CSM_Constants.ID_PARAM, planDefaultList[0].id);
        	CSM_BatchSuccessPlanDefaultCtrl ctrl = new CSM_BatchSuccessPlanDefaultCtrl();
        	
        	PageReference pageRef = Page.CSM_BatchSuccessPlanDefault;
        	
        	system.assert(ctrl.batchSuccessPlanDef != null);
        	
        	System.assertEquals(ctrl.accountManagerLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Account_Manager__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.customerSuccessManagerLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Customer_Success_Manager__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.csmReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Contact__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.csmManagerReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Manager__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.execSponsorReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Exec_Sponsor__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.renewalMgrReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Renewal_Manager__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.renewalRepReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Renewal_Contact__c.getDescribe().getLabel());
        	System.assertEquals(ctrl.supportContactReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Support_Contact__c.getDescribe().getLabel());
        	
        	ctrl.saveBatchPlanDefault();
        	ctrl.cancel();
        Test.stopTest();
    }
    static testMethod void testPlanDefaultControllerNegative() {
    	List<CSM_Batch_Success_Plan_Default__c> planDefaultList = CSM_TestDataUtility.createSuccPlanDefRecord(1);
    	System.assertNotEquals(planDefaultList[0].Id, null);
        User CSMUser = CSM_TestDataUtility.createTestUser('Standard User');
		Test.startTest();
		system.runas(CSMUser){
        	Test.setCurrentPage(Page.CSM_BatchSuccessPlanDefault); 
       		ApexPages.currentPage().getParameters().put(CSM_Constants.ID_PARAM, planDefaultList[0].id);
       		CSM_BatchSuccessPlanDefaultCtrl ctrl = new CSM_BatchSuccessPlanDefaultCtrl();
        	ctrl.saveBatchPlanDefault();
		}
        Test.stopTest();
    }
}