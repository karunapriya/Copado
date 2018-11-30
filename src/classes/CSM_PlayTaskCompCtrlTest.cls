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
private class CSM_PlayTaskCompCtrlTest {

    static testMethod void playTaskCompTest() {
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
    	List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
    	List<CSM_Play_Task__c> playTaskLIst = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,playbookList[0].id);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,EncodingUtil.urlEncode('/apex/CSM_PlaybookManagement?id=' + playbookList[0].id,CSM_Constants.UTF_8));
    	Test.setCurrentPage(pageRef);
    	CSM_PlayManagementCtrl controller = new CSM_PlayManagementCtrl();
    	CSM_PlayTaskCompCtrl con2 = new CSM_PlayTaskCompCtrl();
    	Test.startTest();
    	CSM_PlayManagementCtrl ctrl = con2.CSM_PlayManagementCtrl;
    	con2.play = playList[0];
    	List<CSM_PlayTaskWrapper> taskWrapper = con2.getPlayTaskwrapperList();
    	
    	
    	taskWrapper[0].playTask.CSM_isActive__c = false;
    	con2.saveTasks();
    	con2.newTask();
    	system.assertEquals(con2.getPlayTaskWrapperList().size(),9);
    	List<CSM_PlayTaskWrapper> taskWrapper2 = con2.getPlayTaskwrapperList();
    	con2.seqNumberToUpdate = taskWrapper2[0].seqNum;
    	con2.deleteTask(); 
    	 Test.stopTest();
    }
    
    static testMethod void playTaskCompTest_OpportunityPlay() {
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
    	List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
    	playList.get(0).CSM_Object_Name__c = CSM_Constants.OBJ_OPPORTUNITY;
    	playList.get(0).CSM_Query_Criteria__c = 'Select id, name, Quantity from Opportunity where Quantity >= 1';
    	update playList;
    	List<CSM_Play_Task__c> playTaskLIst = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,playbookList[0].id);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,EncodingUtil.urlEncode('/apex/CSM_PlaybookManagement?id=' + playbookList[0].id,CSM_Constants.UTF_8));
    	Test.setCurrentPage(pageRef);
    	CSM_PlayManagementCtrl controller = new CSM_PlayManagementCtrl();
    	CSM_PlayTaskCompCtrl con2 = new CSM_PlayTaskCompCtrl();
    	Test.startTest();
    	CSM_PlayManagementCtrl ctrl = con2.CSM_PlayManagementCtrl;
    	con2.play = playList[0];
    	List<CSM_PlayTaskWrapper> taskWrapper = con2.getPlayTaskwrapperList();
    	
    	
    	taskWrapper[0].playTask.CSM_isActive__c = false;
    	con2.saveTasks();
    	con2.newTask();
    	system.assertEquals(con2.getPlayTaskWrapperList().size(),9);
    	List<CSM_PlayTaskWrapper> taskWrapper2 = con2.getPlayTaskwrapperList();
    	con2.seqNumberToUpdate = taskWrapper2[0].seqNum;
    	con2.deleteTask(); 
    	 Test.stopTest();
    }
    	
    }