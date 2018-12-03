@isTest
private class CSM_AccountPlanTemplateControllerTest {

    static testMethod void myUnitTest() {
        List<CSM_Account_Plan_Template__c> accPlanTemplate = CSM_TestDataUtility.createAccountPlanTemplateData(2);
        accPlanTemplate[0].CSM_UseasScout_Default_Template__c = true;
        update accPlanTemplate[0];

        test.StartTest();
		Test.setCurrentPage(Page.CSM_AccountPlanTemplate); 
		ApexPages.currentPage().getParameters().put(CSM_Constants.ID_PARAM, accPlanTemplate[0].Id);    		

    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
        CSM_AcctPlanTemplateIndicatorsCompCntrl indicatorController = new CSM_AcctPlanTemplateIndicatorsCompCntrl();
        CSM_AccountPlanTemplateOpp aptOppController = new CSM_AccountPlanTemplateOpp();
        CSM_AcctPlanTemplatePhasesCompController phController = new CSM_AcctPlanTemplatePhasesCompController();
        CSM_AcctPlanTemplatePlaybooksCompCntrl pbController = new CSM_AcctPlanTemplatePlaybooksCompCntrl();
        CSM_AccountPlanTemplateOppTimeLineCtrl oppTimelineController = new CSM_AccountPlanTemplateOppTimeLineCtrl();
        
        indicatorController.corpCurrCode = 'USD';
        aptOppController.selectedField = 'CloseDate';
    		       
        	controller.setaccountPlanTemplateIndicatorsCompCntrl(indicatorController);
        	controller.setaccountPlanTemplateOpp(aptOppController);
			controller.setaccountPlanTemplatePhasesCompController(phController);  
			controller.setAccountPlanTemplatePlaybookController(pbController);
			controller.setaccountPlanTemplateOppTimeLine(oppTimelineController);			
			controller.getThis();
									      	
        	controller.accountPlanTemplate.CSM_Template_Name__c = 'Test Template1';
            controller.templateCreate();
        	controller.findScoutDefaultTemplate();
        	
	        CSM_Account_Plan_Phase__c phase = new CSM_Account_Plan_Phase__c();
	        phase.CSM_Phase_Name__c = 'Phase 1';
        	phase.CSM_Account_Plan_Template__c = controller.accountPlanTemplate.Id;
        	phase.CSM_Length__c = 3;
        	phase.CSM_Order__c = 1;
        	insert phase;
        	
        	CSM_Playbook__c playBook = new CSM_Playbook__c();
        	playBook.CSM_Display_Name__c = 'Test Playbook';
        	insert playBook;
        	
        	CSM_Account_Plan_Playbook__c apPlayBook = new CSM_Account_Plan_Playbook__c();
        	apPlayBook.CSM_Playbook__c = playBook.Id;
        	apPlayBook.CSM_Account_Plan_Template__c = controller.accountPlanTemplate.Id;
        	
        	insert apPlayBook;
        	
        	
        	List<CSM_Account_Plan_Phase__c> apPhaseList = new List<CSM_Account_Plan_Phase__c>();
        	apPhaseList.add(phase);
        	phController.theAccountPlanTemplate = controller.accountPlanTemplate;
        	phController.getAccountPlanPhaseList();
        	pbController.theAccountPlanTemplate = controller.accountPlanTemplate;
        	pbController.getAccountPlanPlaybookList();

	    	List<CSM_Indicator_Group__c> groupList = CSM_TestDataUtility.createIndicatorGroups();
			List<CSM_Indicator__c> indicatorList = CSM_TestDataUtility.createIndicators(groupList[0].Id, 1);
			
        	CSM_Account_Plan_Template_Indicator__c aptIndicator = new CSM_Account_Plan_Template_Indicator__c();
        	aptIndicator.CSM_Account_Plan_Template__c = controller.accountPlanTemplate.Id;
			aptIndicator.CSM_Indicator__c = indicatorList[0].Id;

        	indicatorController.theAccountPlanTemplate = controller.accountPlanTemplate;
        	indicatorController.getIndicatorWrapperList();

        	
        	controller.templateSave();
        	controller.tabCategory = 'CSM';
        	controller.templateCancel();
        	system.assertNotEquals(controller.automateDefaultTemplate,null);
        	CSM_AccountPlanTemplateDataAccess.getIndicatorCurrencyCode(String.valueOF(accPlanTemplate[0].id));
        test.stopTest();
    }
}