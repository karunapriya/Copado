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
private class CSM_PlayTaskDataAccessTest {

    static testMethod void myUnitTest() {
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
    	List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        List<CSM_Play_Task__c> playtaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        Test.startTest();
        List<CSM_Play_Task__c> activeTestTaskList = CSM_PlayTaskDataAccess.getActiveTasks(new Set<String>{playList[0].id});
        List<CSM_Play_Task__c> testTaskLIst = CSM_PlayTaskDAtaAccess.populatePlayTaskInformation(playList[0].id);
        system.assertEquals(testTaskList[0].CSM_isActive__c,true);
        testTaskList[0].CSM_isActive__c = false;
        CSM_PlayTaskDataAccess.savePlayTask(testTaskList);
        List<CSM_Play_Task__c> testTaskLIst2 = CSM_PlayTaskDAtaAccess.populatePlayTaskInformation(playList[0].id);
        system.AssertEquals(testTaskList2[0].CSM_isActive__c, false);
        CSM_PlayTaskDataAccess.deletePlayTask(testTaskList2);
        List<CSM_Play_Task__c> testTaskLIst3 = CSM_PlayTaskDAtaAccess.populatePlayTaskInformation(playList[0].id);
        system.assertEquals(testTaskList3.size(),0);
        Test.stopTest();
    }
    
    static testMethod void Test_getActiveAutomatedTasks_Positive(){
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
    	List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        List<CSM_Play_Task__c> playtaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        Test.startTest();
        Set<String> playExternalIds = new Set<String>();
        playExternalIds.add('External1');
        List<CSM_Play_Task__c> automatedPlayTaskList = CSM_PlayTaskDataAccess.getActiveAutomatedTasks(playExternalIds);
        system.assertEquals(automatedPlayTaskList.size(), 0);
        Test.stopTest();
    }
}