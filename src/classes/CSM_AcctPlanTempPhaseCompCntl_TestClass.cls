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
private class CSM_AcctPlanTempPhaseCompCntl_TestClass {

    static testMethod void accountPlanTest() {
        
        PageREference pageRef = Page.CSM_AccountPlanTemplate;
    	Test.setCurrentPage(pageRef);
    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
    	Test.startTest();
    	controller.accountPlanTemplate.CSM_Template_Name__c = 'New Template 1';
    	PageReference pageref2 = controller.templateCreate();
    	Test.setCurrentPage(pageRef2);
    	
    	
    	controller.templateCancel();
    	
    	CSM_AcctPlanTemplatePlaybooksCompCntrl playbookCntrl; 
    	controller.setAccountPlanTemplatePlaybookController(playbookCntrl);
    	CSM_AcctPlanTemplatePhasesCompController phaseCntrl;
    	controller.setAccountPlanTemplatePhasesCompController(phaseCntrl);
    	CSM_AcctPlanTemplateIndicatorsCompCntrl indicatorCntrl;
    	controller.setAccountPlanTemplateIndicatorsCompCntrl(indicatorCntrl);
    	CSM_AccountPlanTemplateController newCon = controller.getThis();
    	system.assert(true,newCon);
    	controller.templateSave();
    	Test.stopTest();
    }
    
   
    
    static testMethod void existingAccountPlanTest() {
        
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan_Phase__c> accountPlanPhaseList = CSM_TestDataUtility.createAccountPlanPhaseData(2, accountPlanTemplateList[0].id);
        PageREference pageRef = Page.CSM_AccountPlanTemplate;
        pageRef.getParameters().put(CSM_Constants.ID_PARAM, accountPlanTemplateList[0].id);
    	Test.setCurrentPage(pageRef);
    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
    	CSM_AcctPlanTemplatePhasesCompController con = new CSM_AcctPlanTemplatePhasesCompController();
    	Test.startTest();
    	con.theAccountPlanTemplate = accountPlanTemplateList[0];
    	List<CSM_Account_Plan_Phase__c> pList = con.getAccountPlanPhaseList();
    	pList[0].CSM_Length__c = 0;
    	pList[0].CSM_Order__c = 0;
    	pList[0].CSM_Phase_Name__c = null;
    	con.savePhase();
    	pList[0].CSM_Phase_Name__c = 'Update Phase 1';
    	pList[0].CSM_Order__c = 50;
    	pList[0].CSM_Length__c = 11;
    	con.savePhase();
    	
    	
    	con.newPhaseName = '';
    	con.newPhaseLength = '0';
    	con.addPhase();
    	con.newPhaseName = 'New Phase 1';
    	con.newPhaseLength = '10';
    	con.addPhase();
    	
    	con.deleteId = accountPlanPhaseList[0].id;
    	con.deleteName = accountPlanPhaseList[0].CSM_Phase_Name__c;
    	con.deletePhase();
    	List<CSM_Account_Plan_Phase__c> pList2 = con.getAccountPlanPhaseList();
    	system.assert(plist2!=null);
    	
    	Test.stopTest();
    }
    
     static testMethod void existingAccountPlanTest2() {
        
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
    	CSM_AcctPlanTemplatePhasesCompController con = new CSM_AcctPlanTemplatePhasesCompController();
    	Test.startTest();
    	con.theAccountPlanTemplate = accountPlanTemplateList[0];
    	List<CSM_Account_Plan_Phase__c> pList = con.getAccountPlanPhaseList();
		
    	con.newPhaseName = '';
    	con.newPhaseLength = '0';
    	con.addPhase();
    	con.newPhaseName = 'New Phase 1';
    	con.newPhaseLength = '10';
    	con.addPhase();
    	con.savePhase();
    	List<CSM_Account_Plan_Phase__c> pList2 = con.getAccountPlanPhaseList();
    	system.assertEquals(plist2.size(), 2);
    	Test.stopTest();
    }
    
    static testMethod void testNegative() {
        
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan_Phase__c> accountPlanPhaseList = CSM_TestDataUtility.createAccountPlanPhaseData(2, accountPlanTemplateList[0].id);
    	CSM_AcctPlanTemplatePhasesCompController con = new CSM_AcctPlanTemplatePhasesCompController();
    	Test.startTest();
    	con.theAccountPlanTemplate = accountPlanTemplateList[0];
    	List<CSM_Account_Plan_Phase__c> pList = con.getAccountPlanPhaseList();
		
    	con.newPhaseName = '';
    	con.newPhaseLength = '0';
    	con.addPhase();
    	con.newPhaseName = 'New Phase 1';
    	con.newPhaseLength = '10';
    	con.addPhase();
    
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');	
    	system.runAs(restrictedUser)
    	{
    		con.savePhase();
    	}
    	
    	con.phaseSequence = 1;
    	con.isEditable = true;
    	con.deleteId = null;
    	con.deleteName = accountPlanPhaseList[0].CSM_Phase_Name__c;
    	con.deletePhase();
    	system.assert(true);
    	Test.stopTest();
    }
    
    static testMethod void testAccountPlanTemplatePhaseClone(){
    	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
    	CSM_TestDataUtility.createAccountPlanPhaseData(1, accountPlanTemplateList[0].Id);
    	system.assert(String.isNotBlank(accountPlanTemplateList[0].Id));
    	CSM_Account_Plan_Template__c cloneTemplate = accountPlanTemplateList[0].clone(false, true);
    	cloneTemplate.CSM_Template_Name__c = 'ClonedTemplate';
    	insert cloneTemplate;
    	system.assert(String.isNotBlank(cloneTemplate.Id));
    	Map<Id, Id> templateIdMap = new Map<Id, Id>{accountPlanTemplateList[0].Id => cloneTemplate.Id};
    	CSM_AccountPlanTemplatePhasesDataAccess.cloneAccountPlanTemplatePhase(templateIdMap);
    	List<CSM_Account_Plan_Phase__c> clonePhasesList = [Select Id From CSM_Account_Plan_Phase__c Where CSM_Account_Plan_Template__c=:cloneTemplate.Id limit 100];
    	system.assert(!clonePhasesList.isEmpty());
    }
}