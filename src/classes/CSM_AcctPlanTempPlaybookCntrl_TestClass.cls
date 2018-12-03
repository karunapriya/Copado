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
private class CSM_AcctPlanTempPlaybookCntrl_TestClass {

    static testMethod void myUnitTest() {
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(10);
        List<String> pbIdList = new List<String>();
        for(CSM_Playbook__c p : playbookList)
        {
        	pbIdList.add(p.id);
        }
        List<CSM_Account_Plan_Playbook__c> accountPlanTemplate0 = CSM_TestDataUtility.createAccountPlanPlaybookData(null, accountPlanTemplateList[0].id, pbIdList);
        PageREference pageRef = Page.CSM_AccountPlanTemplate;
        pageRef.getParameters().put(CSM_Constants.ID_PARAM, accountPlanTemplateList[0].id);
    	Test.setCurrentPage(pageRef);
    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
    	CSM_AcctPlanTemplatePlaybooksCompCntrl con = new CSM_AcctPlanTemplatePlaybooksCompCntrl();
    	Test.startTest();
    	con.theAccountPlanTemplate = accountPlanTemplateList[0];
    	List<CSM_Account_Plan_Playbook__c> controllerPlaybookList = con.getAccountPlanPlaybookList();
    	system.assertEquals(10,controllerPlaybookList.size());
    	con.editPlaybookId = con.getAccountPlanPlaybookList()[0].id;
    	con.createPlaybook();
    
    	con.updatePlaybook();
    	con.addPlaybook();
    	con.saveTemplatePlaybooks();
    	
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<CSM_Account_Plan__c> apList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].Id);   	
    	List<CSM_Account_Plan_Playbook__c> appList = CSM_TestDataUtility.createAccountPlanPlaybookData(apList[0].Id, accountPlanTemplateList[0].Id, pbIdList );
    	System.assertEquals(null, con.getSuccessPlanAssociationCount());
    	System.assertEquals(null, con.removePlaybook());
    	
    	Test.stopTest();
    }
    static testMethod void myUnitTestNeg() {
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        system.assert(accountPlanTemplateList!=null);
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(10);
        List<String> pbIdList = new List<String>();
        for(CSM_Playbook__c p : playbookList)
        {
        	pbIdList.add(p.id);
        }
        List<CSM_Account_Plan_Playbook__c> accountPlanTemplate0 = CSM_TestDataUtility.createAccountPlanPlaybookData(null, accountPlanTemplateList[0].id, pbIdList);
    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
    	CSM_AcctPlanTemplatePlaybooksCompCntrl con = new CSM_AcctPlanTemplatePlaybooksCompCntrl();
        con.accountPlanTemplateController=controller;
        boolean isEditable=con.isEditable;
    	Test.startTest();
    	List<CSM_Account_Plan_Playbook__c> controllerPlaybookList = con.getAccountPlanPlaybookList();
    	con.createPlaybook();
        con.updatePlaybook();
        Test.stopTest();
    }
    static testMethod void myUnitTestNeg1() {
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(10);
        List<String> pbIdList = new List<String>();
        for(CSM_Playbook__c p : playbookList)
        {
        	pbIdList.add(p.id);
        }
        List<CSM_Account_Plan_Playbook__c> accountPlanTemplate0 = CSM_TestDataUtility.createAccountPlanPlaybookData(null, accountPlanTemplateList[0].id, pbIdList);
    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
    	CSM_AcctPlanTemplatePlaybooksCompCntrl con = new CSM_AcctPlanTemplatePlaybooksCompCntrl();
        con.accountPlanTemplateController=controller;
        boolean isEditable=con.isEditable;
    	Test.startTest();
    	con.theAccountPlanTemplate = accountPlanTemplateList[0];
    	List<CSM_Account_Plan_Playbook__c> controllerPlaybookList = con.getAccountPlanPlaybookList();
    	system.assertEquals(10,controllerPlaybookList.size());
    	con.editPlaybookId = con.getAccountPlanPlaybookList()[0].id;
        con.theAccountPlanTemplate = null;
    	con.createPlaybook();
        con.updatePlaybook();
        con.addPlaybook();
    	con.saveTemplatePlaybooks();
        Test.stopTest();
    }
}