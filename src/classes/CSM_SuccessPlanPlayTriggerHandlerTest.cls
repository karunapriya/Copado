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
private class CSM_SuccessPlanPlayTriggerHandlerTest {

    static testMethod void myUnitTest() {
    	
		CSM_TestDataUtility.enableAllTriggers();
		insert new SS_License__c(CSM__c = true);
		List<Account> accountList =  CSM_TestDataUtility.createAccount(1);
		LIst<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		List<CSM_Playbook__c> playbookLst = CSM_TestDataUtility.createPlaybooks(2);
		List<CSM_Play__c> plyLst = CSM_TestDataUtility.createPlayTestData(2);
		CSM_TestDataUtility.createPlaybookPlayTestData(playbookLst[0].id,plyLst[0].id);
		CSM_TestDataUtility.createPlaybookPlayTestData(playbookLst[0].id,plyLst[1].id);
		List<String> playbookIdList = new List<String>(); 
		for(CSM_Playbook__c playbook : playbookLst){
			playbookIdList.add(playbook.id);
		}
		String templateId = templateList[0].id;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
		CSM_TestDataUtility.createAccountPlanPlaybookData('', templateId , playbookIdList);		
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
		List<CSM_Account_Plan__c> acctPlan = CSM_TestDataUtility.createAccountPlan(accountList,templateList[0].Id);
    	
    	Test.startTest();
    	plyLst[0].CSM_Play_ReEntry__c = true;
    	plyLst[1].CSM_Play_ReEntry__c = true;
    	update plyLst;    	
    	    	
    	List<CSM_Successplan_play__c> spplList = [select Id,csm_play_outcome__c from CSM_Successplan_play__c where csm_play__c =: plyLst[0].Id ];
    	CSM_Constants.SPPL_TRIGGER = true;
    	spplList[0].csm_play_outcome__c = 'Successful Completion'; 
    	

    	update spplList; 	
    	//update accountList;
    	
    	system.debug('plyLst  - ' + plyLst);
    	system.debug('spplList   - ' + spplList);
    	Test.stopTest();
    	
    	List<CSM_Successplan_play__c> spplList1 = [select Id from CSM_Successplan_play__c where csm_play__c =: plyLst[0].Id ]; 
    	system.assert(spplList1.size() > 1);
        // TO DO: implement unit test
        
    }
}