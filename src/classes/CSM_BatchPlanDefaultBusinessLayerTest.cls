/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CSM_BatchPlanDefaultBusinessLayerTest {
	private static CSM_Batch_Success_Plan_Default__c planDefaultRecord;
    static testMethod void setUp() {
        List<CSM_Batch_Success_Plan_Default__c> planDefaultList = CSM_TestDataUtility.createSuccPlanDefRecord(1);
        planDefaultRecord = planDefaultList[0];
    }
    static testMethod void getPlanDefaultWrapperListPositive() {
        setUp();
    	Test.startTest();
    		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    		inputWrapper.viewName = 'SuccessPlanDefault';
    		gridParams.selectedTaskFilter = planDefaultRecord.id;
    		inputWrapper.params = gridParams;
    		CSM_BusinessLayer businessLayer = new CSM_BatchPlanDefaultBusinessLayer(inputWrapper);
    		CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    		system.assert(responseWrapper != null);
    		system.assert(responseWrapper.header != null);
    		system.assert(!responseWrapper.header.isEmpty());
    		system.assert(responseWrapper.row != null);
    		system.assert(!responseWrapper.row.isEmpty());
    		system.assertEquals(responseWrapper.hasAction, true);
    		system.assertEquals(responseWrapper.hasCheckbox, false);
    		system.assertEquals(responseWrapper.hasDetail, false);
    	Test.stopTest();
    }
    static testMethod void getPlanDefaultWrapperListNegative() {
        setUp();
        System.assertNotEquals(planDefaultRecord.Id, null);
        User CSMUser = CSM_TestDataUtility.createTestUser('Standard User');
    	Test.startTest();
    	system.runas(CSMUser){
    		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    		inputWrapper.viewName = 'SuccessPlanDefault';
    		gridParams.selectedTaskFilter = planDefaultRecord.id;
    		inputWrapper.params = gridParams;
    		CSM_BusinessLayer businessLayer = new CSM_BatchPlanDefaultBusinessLayer(inputWrapper);
    		CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	}
    	Test.stopTest();
    }
}