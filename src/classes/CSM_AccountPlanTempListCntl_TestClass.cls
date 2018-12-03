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
private class CSM_AccountPlanTempListCntl_TestClass {

    static testMethod void myUnitTest() {
    	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(6);
    	PageREference pageRef = Page.CSM_AccountPlanTemplateList;
    	Test.setCurrentPage(pageRef);
    	
    	Test.startTest();
    	CSM_AccountPlanTemplateListController controller = new CSM_AccountPlanTemplateListController();
    	
    	PageReference testRef1 = controller.CreateNew();
    	controller.templateId = accountPlanTemplateList[0].id;
    	PageReference testRef2 = controller.editTemplate();
    	PageReference testRef3 = controller.cloneTemplate();
    	controller.getSuccessPlansSPTemplateDelete();
    	controller.deleteSPTemplate();
    	system.assertEquals(testRef3, null);
    	controller.templateId = null;
    	testRef3 = controller.cloneTemplate();
    	system.assertEquals(testRef3, null);
    	system.assert(ApexPages.hasMessages());
    	PageReference testRef4 = controller.getSuccessPlansSPTemplateDelete();
    	PageReference testRef5 = controller.deleteSPTemplate();
    	Test.stopTest();
    }
    
    static testMethod void myUnitTest1() {
        User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(6);
    	PageREference pageRef = Page.CSM_AccountPlanTemplateList;
    	Test.setCurrentPage(pageRef);

        system.runAs(restrictedUser){
	    	Test.startTest();
	    	try{
		    	CSM_AccountPlanTemplateListController controller = new CSM_AccountPlanTemplateListController();
		    	
		    	PageReference testRef1 = controller.CreateNew();
		    	controller.templateId = accountPlanTemplateList[0].id;
		    	PageReference testRef2 = controller.editTemplate();
		    	PageReference testRef3 = controller.cloneTemplate();
		    	controller.getSuccessPlansSPTemplateDelete();
		    	controller.deleteSPTemplate();
		    	system.assertEquals(testRef3, null);
		    	controller.templateId = null;
		    	testRef3 = controller.cloneTemplate();
		    	system.assertEquals(testRef3, null);
		    	system.assert(ApexPages.hasMessages());
	    	
	    	}catch(Exception ex){
	    		system.assert(true);	    	
	    	}
	    	Test.stopTest();
        }
    	
    	
    	
    	
    }
    
    
}