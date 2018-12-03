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
private class CSM_PlaybookManagementCtrlTest {

    static testMethod void existingPlaybookTest() {
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(3);
    	PageReference pageRef = Page.CSM_PlaybookManagement;
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playbookList[0].id);
    	Test.setCurrentPage(pageRef);
    	
    	Test.startTest();
    	CSM_PlaybookManagementCtrl controller = new CSM_PlaybookManagementCtrl();
    	CSM_PlaybookPlaysListCompCtrl con2 = new CSM_PlaybookPlaysListCompCtrl();
    	
    	con2.createPlay();
    	con2.editPlay();
    	
    	controller.playbook.CSM_IsActive__c = false;
    	controller.playbookSave();
    	
    	CSM_PlaybookManagementCtrl con1 = controller.getThis();
    	List<CSM_Playbook__c> playbookItem = [select id, CSM_IsActive__c from CSM_Playbook__c where id = :playbookList[0].id limit 1];
    	system.assertEquals(playbookItem[0].CSM_IsActive__c,false);
    	controller.saveAndNew();
    	controller.playbookCancel();
    	
    	String returnURL = pageRef.getURL();
    	controller.tabCategory = 'SuccessPlan';
    	controller.playbookEditId = String.valueOf(playbookItem[0].id);
    	
    	Test.stopTest();
    	
    	
    }
     static testMethod void newPlaybookTest() {
    	PageReference pageRef = Page.CSM_PlaybookManagement;
    	Test.setCurrentPage(pageRef);
    	
    	Test.startTest();
    	CSM_PlaybookManagementCtrl controller = new CSM_PlaybookManagementCtrl();
    	controller.playbook.CSM_IsActive__c = false;
    	controller.playbook.CSM_Display_Name__c = 'New Playbook ';
    	controller.playbook.CSM_Long_Description__c = 'Long description for New Playbook';
    	controller.playbook.CSM_Short_Description__c = 'Short description for New Playbook';
    	controller.playbook.CSM_External_Id__c = '1000';
    	PageReference pg1 = controller.playbookCreate();
 		system.assertNotEquals(pg1,null);
    	Test.stopTest();
    	
    	
    }
    static testMethod void playbookTestNegative() {
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(3);
    	PageReference pageRef = Page.CSM_PlaybookManagement;
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playbookList[0].id);
    	Test.setCurrentPage(pageRef);
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser)
    	{
    		Test.startTest();
    		CSM_PlaybookManagementCtrl controller = new CSM_PlaybookManagementCtrl();
    		CSM_PlaybookPlaysListCompCtrl con2 = new CSM_PlaybookPlaysListCompCtrl();
    	
    		con2.createPlay();
    		con2.editPlay();
    	
    		controller.playbook.CSM_IsActive__c = false;
    		system.assertEquals(controller.playbook.CSM_IsActive__c, false);
    		controller.playbookSave();
    		controller.saveAndNew();
    		controller.playbookCreate();
    		    		
    		Test.stopTest();
    	}
    }
}