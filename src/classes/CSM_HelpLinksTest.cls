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
private class CSM_HelpLinksTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        CSM_TestUtility.addCSMHelpLinks();
        CSM_HelpLinks__c helpLinks = CSM_HelpLinks__c.getinstance();
    	Test.startTest();
    	CSM_HelpComponentCtrl ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_OVERVIEW;
    	System.assert(ext1.urlString.contains(helpLinks.CSM_Overview__c));
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_FOCUS_CATEGORY_GROUPS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_FOCUS_CATEGORY_VIEWS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_INDICATOR_GROUPS;
    	 
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_PLAYBOOKS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_PLAYS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_PLAN_DETAILS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_PLAN_HOME;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATES;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_FOCUS_CATEGORIES;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_TASKS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_PLAY_CRITERIA;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_PLAY_TASK;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_TASK_COMPLETE;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_TASK_DISMISS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_HEALTH_DONUT;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_HEALTH_MAP;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_PLAN_DETAILS_SUBTAB;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_PHASES;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_PLAYBOOKS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_INDICATORS;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.param = CSM_Constants.HELP_ADMIN_TAB;
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.textParam = CSM_Constants.HELP_OVERVIEW;
    	system.assert(ext1.textParam.contains(CSM_Constants.HELP_OVERVIEW));
    	
    	ext1 = new CSM_HelpComponentCtrl();
    	ext1.textParam = null;
    	
    	CSM_SuccessPlanHelpCtrl successPlanHelpCtrl = new CSM_SuccessPlanHelpCtrl();
    	system.assert(successplanHelpCtrl.urlString.contains(helpLinks.CSM_Success_Plan_Home__c));
        
        test.stopTest();
    }
}