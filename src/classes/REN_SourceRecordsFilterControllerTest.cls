@isTest
public with sharing class REN_SourceRecordsFilterControllerTest {
	
	static testMethod void Test_CreateAndEditConfiguration_Positive() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c renewal= new REN_Renew_Configuration__c();
		
        REN_LogicBuilderCmpCtrl logicBldCtrl =  new REN_LogicBuilderCmpCtrl();
        REN_LogicBuilderCmpCtrl logicBldCtrl2 =  new REN_LogicBuilderCmpCtrl();
        REN_SourceRecordsFilterController controller = new REN_SourceRecordsFilterController();
        logicBldCtrl.logicBuilderInput = controller.lbInputWrapperList[0];
        logicBldCtrl2.logicBuilderInput = controller.lbInputWrapperList[1];
        system.assert(controller.renconfigobj != null);
        controller.renconfigobj.REN_View_Name__c='Test';
        REN_Line_Criteria__c lineCriteriaObj1 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Asset Test','Asset','Name',
																						'String','Test',null,'Like',false,'',null,rc.Id, null);
		lineCriteriaObj1.RLM_LineNo__c =1;	
		REN_Line_Criteria__c lineCriteriaObj2 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Renew  Test',REN_Constants.OBJ_REN_RENEWS_TO,'Name',
																						'String','Test',null,'Like',false,'',null,renewal.Id, null);
		lineCriteriaObj2.RLM_LineNo__c =1;	
		
		logicBldCtrl.criteriaWrapperList.add(new REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper(lineCriteriaObj1, logicBldCtrl.fieldWrapperByLogicBuilderExtName, logicBldCtrl.criteriaWrapperList.size()+1, 
													logicBldCtrl.logicBuilderInput.logicBuilderObject, null, null, null, 
													CSM_Util.NewGuid(), logicBldCtrl.logicBuilderInput.criteriaObject)	);
/*
		logicBldCtrl2.criteriaWrapperList.add(new REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper(lineCriteriaObj2, logicBldCtrl2.fieldWrapperByLogicBuilderExtName, logicBldCtrl2.criteriaWrapperList.size()+1, 
													logicBldCtrl2.logicBuilderInput.logicBuilderObject, null, null, null, 
													CSM_Util.NewGuid(), logicBldCtrl2.logicBuilderInput.criteriaObject)	);
*/
		Test.startTest();														
        controller.saveDataGeneration();
        Test.stopTest();
        controller.retrieveRenewConfig(rc.id);
        controller = new REN_SourceRecordsFilterController();

    } 
    
    static testMethod void Test_CreateAndEditConfiguration_Negative() {
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c renewal= new REN_Renew_Configuration__c();
		
        REN_LogicBuilderCmpCtrl logicBldCtrl =  new REN_LogicBuilderCmpCtrl();
        REN_LogicBuilderCmpCtrl logicBldCtrl2 =  new REN_LogicBuilderCmpCtrl();
        REN_SourceRecordsFilterController controller = new REN_SourceRecordsFilterController();
        logicBldCtrl.logicBuilderInput = controller.lbInputWrapperList[0];
        logicBldCtrl2.logicBuilderInput = controller.lbInputWrapperList[1];
        system.assert(controller.renconfigobj != null);
        controller.renconfigobj.REN_View_Name__c='Test';
        Test.startTest();														
        controller.saveDataGeneration();
        Test.stopTest();
        List<REN_Line_Criteria__c> linCrit = [Select id from REN_Line_Criteria__c Limit 100];
        system.assert(linCrit.size()==2);
    }
    
    static testMethod void Test_Cancel() {
        Test.startTest();
        REN_SourceRecordsFilterController controller = new REN_SourceRecordsFilterController();
        PageReference cancelRef = controller.cancel();
        system.assert(true);
        Test.stopTest();
    }
    
     static testMethod void Test_Cancel_Negative() {
        Test.startTest();
        REN_SourceRecordsFilterController controller = new REN_SourceRecordsFilterController();
        controller.batchId='DFGGKIGMN2343ERF';
        controller.genCount = 'Success';
        PageReference cancelRef = controller.cancel();
        controller.genCount = 'Fail';
        cancelRef = controller.cancel();
        system.assert(true);
        Test.stopTest();
    }
    
    static testMethod void Test_FindFor() {
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		
        REN_LogicBuilderCmpCtrl logicBldCtrl =  new REN_LogicBuilderCmpCtrl();
        REN_LogicBuilderCmpCtrl logicBldCtrl2 =  new REN_LogicBuilderCmpCtrl();
        REN_SourceRecordsFilterController controller = new REN_SourceRecordsFilterController();
        logicBldCtrl.logicBuilderInput = controller.lbInputWrapperList[0];
        logicBldCtrl2.logicBuilderInput = controller.lbInputWrapperList[1];
        system.assert(controller.renconfigobj != null);
        controller.renconfigobj.REN_View_Name__c='Test';
        REN_Line_Criteria__c lineCriteriaObj1 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Asset Test','Asset','Name',
																						'String','Test',null,'Like',false,'',null,rc.Id, null);
		lineCriteriaObj1.RLM_LineNo__c =1;	
		logicBldCtrl.criteriaWrapperList.add(new REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper(lineCriteriaObj1, logicBldCtrl.fieldWrapperByLogicBuilderExtName, logicBldCtrl.criteriaWrapperList.size()+1, 
													logicBldCtrl.logicBuilderInput.logicBuilderObject, null, null, null, 
													CSM_Util.NewGuid(), logicBldCtrl.logicBuilderInput.criteriaObject)	);	
													
		Test.startTest();
		controller.findFor();
	    system.assert(controller.criteria != null);
	    Test.stopTest();
    }	
}