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
private class CSM_PlaybooksTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDAtaUtility.createAccountPlanTemplateData(1);
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].id);
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(5);
        
       
        Test.startTest();
        CSM_PlaybooksComponentController controller = new CSM_PlaybooksComponentController();
        List<CSM_PlaybookWrapper> controllerPlaybookList = controller.playbookList;
        controller.createPlaybook();
        controller.playbookId = controllerPlaybookList[0].playbook.id;
        controller.editPlaybook();
        controller.retUrl = '/apex/CSM_Playbooks';
        controller.cancelAddPlaybook();
        controller.playbookId = controllerPlaybookList[0].playbook.id;
        controller.activatePlaybook();
        controller.playbookId = controllerPlaybookList[0].playbook.id;
        controller.deactivatePlaybook();
        List<CSM_Playbook__c> controllerPlaybookList2 = [select id, csm_isActive__c from CSM_Playbook__c where id = :controllerPlaybookList[0].playbook.id limit 10];
        system.assertEquals(controllerPlaybookList2[0].csm_isactive__c, false);
        
        controller.isAdding = true;
        controller.accountPlanId = accountPlanList[0].id;
        controller.acctPlanTemplateId = accountPlanTemplateList[0].id;
        controller.playbookId = controllerPlaybookList[0].playbook.id;
        controller.addPlaybook();
        
        Map<String,String> accountTemplateMap = new Map<String,STring>();
        accountTemplateMap.put(accountPlanTemplateList[0].id,playbookList[0].id);
        Map<String,String> accountPlanMap = new Map<String,String>();
        accountPlanMap.put(accountPLanList[0].id,playbookList[0].id);
        boolean assignmentSuccess = CSM_PlaybooksDataAccess.createPlaybookAssignment(accountTemplateMap,accountPlanMap, new List<CSM_Account_Plan_Playbook__c>(), false);
        
        Test.stopTest();
    }
}