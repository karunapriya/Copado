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
private class CSM_AcctPlanTempIndicatorCompCntrlTest {

    static testMethod void myUnitTest() {
       	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
       	List<CSM_Indicator_Group__c> indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
       	List<CSM_Indicator__c> indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,2);
       	List<CSM_Account_Plan_Template_Indicator__c> acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accountPlanTemplateList[0].id, indicatorList);
    	PageREference pageRef = Page.CSM_AccountPlanTemplateList;
    	
    	
    	Test.setCurrentPage(pageRef);
    	CSM_AccountPlanTemplateController planTemplateController = new CSM_AccountPlanTemplateController();
    	Test.startTest();
    	CSM_AcctPlanTemplateIndicatorsCompCntrl controller = new CSM_AcctPlanTemplateIndicatorsCompCntrl();
    	controller.theAccountPlanTemplate = accountPlanTemplateList[0];
    	controller.CSM_AccountPlanTemplateController = planTemplateController;
    	
    	//Note need to change to move indicator wrapper to new class
    	controller.getIndicatorWrapperList();
    	system.assertEquals(2,controller.getIndicatorWrapperList().size());
    	controller.saveIndicators();
    	controller.addIndicator();
    	controller.indicatorToUpdate = indicatorList[0].id;
    	controller.updateIndicatorInformation();

    	controller.indicatorToDeleteId = acctPlanTemplateIndicatorList[0].id;
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<CSM_Account_Plan__c> apList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].Id); 
    	      	
    	system.assertEquals(null, controller.getAccountSuccessPlansCount());
    	system.assertEquals(null, controller.removePlanIndicator());    	
    	
    }
    
    static testMethod void testCloneTemplateIndicator() {
    	Test.startTest();
       	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
       	List<CSM_Indicator_Group__c> indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
       	List<CSM_Indicator__c> indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,2);
       	List<CSM_Account_Plan_Template_Indicator__c> acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accountPlanTemplateList[0].id, indicatorList);
    	CSM_Account_Plan_Template__c cloneTemplate = accountPlanTemplateList[0].clone(false, true);
    	cloneTemplate.CSM_Template_Name__c = 'ClonedTemplate';
    	insert cloneTemplate;
    	system.assert(String.isNotBlank(cloneTemplate.Id));
    	Map<Id, Id> templateIdMap = new Map<Id, Id>{accountPlanTemplateList[0].Id => cloneTemplate.Id};
    	CSM_AcctPlanTemplateIndicatorDataAccess.cloneAccountPlanTemplateIndicator(templateIdMap);
    	List<CSM_Account_Plan_Template_Indicator__c> clonePhasesList = [Select Id From CSM_Account_Plan_Template_Indicator__c Where CSM_Account_Plan_Template__c=:cloneTemplate.Id];
    	system.assert(!clonePhasesList.isEmpty());
    	Test.stopTest();
    }

    static testMethod void myUnitTest1() {
       	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
       	List<CSM_Indicator_Group__c> indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
       	List<CSM_Indicator__c> indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,7);
       	List<CSM_Account_Plan_Template_Indicator__c> acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accountPlanTemplateList[0].id, indicatorList);
    	PageREference pageRef = Page.CSM_AccountPlanTemplateList;

		for(CSM_Account_Plan_Template_Indicator__c ind:acctPlanTemplateIndicatorList){
			ind.CSM_Criteria_1_From_Value__c = null;			
			ind.CSM_Criteria_2_From_Value__c = null;
			ind.CSM_Criteria_3_From_Value__c = null;						

			ind.CSM_Criteria_1_To_Value__c = null;			
			ind.CSM_Criteria_2_To_Value__c = null;
			ind.CSM_Criteria_3_To_Value__c = null;
			
			/*ind.CSM_Criteria_1_Type__c = null;			
			ind.CSM_Criteria_2_Type__c = null;
			ind.CSM_Criteria_3_Type__c = null;*/

			ind.CSM_Criteria_1_To_Date__c = null;			
			ind.CSM_Criteria_2_To_Date__c = null;
			ind.CSM_Criteria_3_To_Date__c = null;

			ind.CSM_Criteria_1_From_Date__c = null;			
			ind.CSM_Criteria_2_From_Date__c = null;
			ind.CSM_Criteria_3_From_Date__c = null;
									
		}
		update acctPlanTemplateIndicatorList; 
		system.debug('indilist' + acctPlanTemplateIndicatorList);   	
    	
    	Test.setCurrentPage(pageRef);
    	CSM_AccountPlanTemplateController planTemplateController = new CSM_AccountPlanTemplateController();
    	Test.startTest();
    	CSM_AcctPlanTemplateIndicatorsCompCntrl controller = new CSM_AcctPlanTemplateIndicatorsCompCntrl();
    	controller.theAccountPlanTemplate = accountPlanTemplateList[0];
    	controller.CSM_AccountPlanTemplateController = planTemplateController;
    	
    	//Note need to change to move indicator wrapper to new class
    	controller.getIndicatorWrapperList();
    	system.assertEquals(7,controller.getIndicatorWrapperList().size());
    	controller.saveIndicators();
    	controller.addIndicator();
    	controller.indicatorToUpdate = indicatorList[0].id;
    	controller.updateIndicatorInformation();

    	controller.indicatorToDeleteId = acctPlanTemplateIndicatorList[0].id;
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<CSM_Account_Plan__c> apList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].Id); 
    	      	
    	system.assertEquals(null, controller.getAccountSuccessPlansCount());
    	system.assertEquals(null, controller.removePlanIndicator());    	
    	
    }

    static testMethod void myUnitTest2() {
       	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
       	List<CSM_Indicator_Group__c> indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
       	List<CSM_Indicator__c> indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,7);
       	List<CSM_Account_Plan_Template_Indicator__c> acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accountPlanTemplateList[0].id, indicatorList);
    	PageREference pageRef = Page.CSM_AccountPlanTemplateList;

		for(CSM_Account_Plan_Template_Indicator__c ind:acctPlanTemplateIndicatorList){
			
			ind.CSM_Criteria_1_Type__c = null;			
			ind.CSM_Criteria_2_Type__c = null;
			ind.CSM_Criteria_3_Type__c = null;

		}
		update acctPlanTemplateIndicatorList; 
    	
    	Test.setCurrentPage(pageRef);
    	CSM_AccountPlanTemplateController planTemplateController = new CSM_AccountPlanTemplateController();
    	Test.startTest();
    	CSM_AcctPlanTemplateIndicatorsCompCntrl controller = new CSM_AcctPlanTemplateIndicatorsCompCntrl();
    	controller.theAccountPlanTemplate = accountPlanTemplateList[0];
    	controller.CSM_AccountPlanTemplateController = planTemplateController;
    	
    	//Note need to change to move indicator wrapper to new class
    	controller.getIndicatorWrapperList();
    	system.assertEquals(7,controller.getIndicatorWrapperList().size());
    	controller.saveIndicators();
    	controller.addIndicator();
    	controller.indicatorToUpdate = indicatorList[0].id;
    	controller.updateIndicatorInformation();

    	controller.indicatorToDeleteId = acctPlanTemplateIndicatorList[0].id;
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<CSM_Account_Plan__c> apList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].Id); 
    	      	
    	system.assertEquals(null, controller.getAccountSuccessPlansCount());
    	system.assertEquals(null, controller.removePlanIndicator());    	
    	
    }


}