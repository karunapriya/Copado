@isTest
public with sharing class CSM_BatchSuccessPlanDefaultCompCtrlTest {

	static testMethod void myUnitTest() {
       	CSM_TestDataSetup testDataSetup = new CSM_TestDataSetup('Test');
		CSM_Batch_Success_Plan_Default__c bacthSPD = testDataSetup.createBatchSuccPlanDefault(1)[0];
    	Test.startTest(); 
    	
    	CSM_BatchSuccessPlanDefaultCompCtrl controller = new CSM_BatchSuccessPlanDefaultCompCtrl();
    	
    	System.assertEquals(controller.accountManagerLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Account_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.customerSuccessManagerLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Customer_Success_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.csmReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Contact__c.getDescribe().getLabel());
        System.assertEquals(controller.csmManagerReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.execSponsorReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Exec_Sponsor__c.getDescribe().getLabel());
        System.assertEquals(controller.renewalMgrReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Renewal_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.renewalRepReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Renewal_Contact__c.getDescribe().getLabel());
        System.assertEquals(controller.supportContactReplacementLabel, Schema.CSM_Batch_Success_Plan_Default__c.fields.CSM_Support_Contact__c.getDescribe().getLabel());
        
	    controller.batchSPDefaultId = bacthSPD.Id;
	   	controller.getbatchSPDefault();
	    Test.stopTest();
    }
}