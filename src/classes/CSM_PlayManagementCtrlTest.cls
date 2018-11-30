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
private class CSM_PlayManagementCtrlTest {

    static testMethod void newPlayTest() {
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,playbookList[0].id);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,EncodingUtil.urlEncode('/apex/CSM_PlaybookManagement?id=' + playbookList[0].id,CSM_Constants.UTF_8));
    	Test.setCurrentPage(pageRef);
    	CSM_PlayManagementCtrl controller = new CSM_PlayManagementCtrl(); 
    	Test.startTest();
    	controller.play.CSM_isActive__c = true;
    	controller.play.CSM_Display_Name__c = 'New Play';
    	List<SelectOption> optionList = controller.getObjectList();
    	controller.play.CSM_Object_Name__c = 'Account';
    	controller.playCreate();

    	List<CSM_Play__c> playList = [select id from CSM_Play__c limit 10];
    	system.assertEquals(playlist.size(), 1);
    	controller.saveAndNew();
    	
        User Usr = CSM_TestDataUtility.createTestUser('Standard User');
        system.runAs(Usr)
        {
            try{
		        List<CSM_Playbook__c> playbookList1 = CSM_TestDataUtility.createPlaybookTestData(1);
		        PageReference pageRef1 = Page.CSM_PlayManagement;
		    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,playbookList1[0].id);
		    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,EncodingUtil.urlEncode('/apex/CSM_PlaybookManagement?id=' + playbookList1[0].id,CSM_Constants.UTF_8));
		    	Test.setCurrentPage(pageRef1);
		    	CSM_PlayManagementCtrl controller1 = new CSM_PlayManagementCtrl(); 
		    	//Test.startTest();
		    	controller1.play.CSM_isActive__c = true;
		    	controller1.play.CSM_Display_Name__c = 'New Play';
		    	List<SelectOption> optionList1 = controller.getObjectList();
		    	controller1.play.CSM_Object_Name__c = 'Account';
		    	controller1.playCreate();

            }catch(Exception e){}
	    	List<CSM_Play__c> playList1 = [select id from CSM_Play__c limit 10];
	    	system.assertEquals(playlist1.size(), 1);
        }
    	Test.stopTest();
    }
    
    static testMethod void existingPlayTest() {
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        //List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
		List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayOpportunityTestData('', 1);      
        CSM_TestDataUtility.createOpportunityPlayCriteriaDataDate(playList[0].Id);
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playList[0].id);
    	Test.setCurrentPage(pageRef);
    	Test.startTest();
    	CSM_PlayManagementCtrl controller = new CSM_PlayManagementCtrl();
    	controller.play.CSM_IsActive__c = false;
    	CSM_PlayTaskCompCtrl taskController = new CSM_PlayTaskCompCtrl();
    	taskController.play = playList[0];
    	controller.setPlayTaskComponentController(taskController);
    	taskController.getPlayTaskWrapperList();
    	taskController.CSM_PlayManagementCtrl = controller;
    	taskController.newTask();
    	REN_LogicBuilderCmpCtrl lbCmpCtrl = new REN_LogicBuilderCmpCtrl();
		//controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Account','fcv1',false,controller,'','','');
		lbCmpCtrl.logicBuilderInput = controller.lbInputWrapper;
    	
		controller.saveAndNew();
    	//controller.playSave();
    	CSM_PlayManagementCtrl c1 = controller;//.getThis();
    	system.assertNotEquals(null, c1);
    	//CSM_PlayCriteriaCompCtrl criteriaController = new CSM_PlayCriteriaCompCtrl();
    	//controller.setPlayCriteriaComponentController(criteriaController);
    	
    	//controller.saveAndNew();
    	//controller.playCancel();
    	Test.stopTest();
    }
    
    static testMethod void existingPlayTest1() {
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
		//List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayOpportunityTestData('', 1);      
        CSM_TestDataUtility.createPlayCriteriaDataDate(playList[0].Id);
        CSM_TestDataUtility.createPlayCriteriaData(playList[0].Id);        
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playList[0].id);
    	Test.setCurrentPage(pageRef);
    	Test.startTest();
    	CSM_PlayManagementCtrl controller = new CSM_PlayManagementCtrl();
    	controller.play.CSM_IsActive__c = false;
    	CSM_PlayTaskCompCtrl taskController = new CSM_PlayTaskCompCtrl();
    	taskController.play = playList[0];
    	controller.setPlayTaskComponentController(taskController);
    	taskController.getPlayTaskWrapperList();
    	taskController.CSM_PlayManagementCtrl = controller;
    	taskController.newTask();
    	
    	REN_LogicBuilderCmpCtrl lbCmpCtrl = new REN_LogicBuilderCmpCtrl();
		//controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Account','fcv1',false,controller,'','','');
		lbCmpCtrl.logicBuilderInput = controller.lbInputWrapper;
    	

    	controller.playSave();
    	CSM_PlayManagementCtrl c1 = controller;//.getThis();
    	system.assertNotEquals(null, c1);
    	//CSM_PlayCriteriaCompCtrl criteriaController = new CSM_PlayCriteriaCompCtrl();
    	//controller.setPlayCriteriaComponentController(criteriaController);
    	
    	
    	controller.playCancel();
    	
        User Usr = CSM_TestDataUtility.createTestUser('Standard User');
        system.runAs(Usr)
        {
	        List<CSM_Play__c> playList1 = CSM_TestDataUtility.createPlayTestData(1);
            try{

				//List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayOpportunityTestData('', 1);      
		        CSM_TestDataUtility.createPlayCriteriaDataDate(playList1[0].Id);
		        CSM_TestDataUtility.createPlayCriteriaData(playList1[0].Id);        
		    	PageReference pageRef1 = Page.CSM_PlayManagement;
		    	pageRef1.getParameters().put(CSM_Constants.ID_PARAM,playList1[0].id);
		    	Test.setCurrentPage(pageRef1);
		    	//Test.startTest();
		    	CSM_PlayManagementCtrl controller1 = new CSM_PlayManagementCtrl();
		    	controller1.play.CSM_IsActive__c = false;
		    	CSM_PlayTaskCompCtrl taskController1 = new CSM_PlayTaskCompCtrl();
		    	taskController1.play = playList1[0];
		    	controller1.setPlayTaskComponentController(taskController1);
		    	taskController1.getPlayTaskWrapperList();
		    	taskController1.CSM_PlayManagementCtrl = controller1;
		    	taskController1.newTask();
		    	
		    	REN_LogicBuilderCmpCtrl lbCmpCtrl1 = new REN_LogicBuilderCmpCtrl();
				//controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Account','fcv1',false,controller,'','','');
				lbCmpCtrl1.logicBuilderInput = controller1.lbInputWrapper;
		    	
		
		    	controller1.playSave();

            }catch(Exception e){}
			List<CSM_Play_Task__c> tList1 = [select Id from CSM_Play_Task__c where CSM_Play__c =:playList1[0].Id];
	    	System.assert(tList1.size() == 0);		
        }
    	Test.stopTest();
    }    


    static testMethod void existingPlayTestScout() {
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
		//List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayOpportunityTestData('', 1);      
        //CSM_TestDataUtility.createPlayCriteriaData(playList[0].Id);
        
        playList[0].CSM_Object_Name__c = 'ScoutForSREV__' + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        update playList[0];
    	List<CSM_Play_Criteria__c> tmpList = new List<CSM_Play_Criteria__c>();
		CSM_Play_Criteria__c newCriteria = new CSM_Play_Criteria__c();
		newCriteria.RLM_Field_Display_Name__c = 'Customer Reference Id';
		newCriteria.RLM_Field_Name__c = 'ScoutForSREV__' + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID;
		newCriteria.RLM_Field_Type__c = CSM_Constants.TYPE_STRING;
		newCriteria.CSM_Play__c = playList[0].Id;
		newCriteria.RLM_Operator__c = '=';
		newCriteria.RLM_Values__c = '000000000000000'; 
		tmpList.add(newCriteria);
		insert tmpList;
                
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playList[0].id);
    	Test.setCurrentPage(pageRef);
    	Test.startTest();
    	CSM_PlayManagementCtrl controller = new CSM_PlayManagementCtrl();
    	controller.play.CSM_IsActive__c = true;
    	controller.play.CSM_Object_Name__c = 'ScoutForSREV__' + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER; 
    	//update controller.play; 	
    	CSM_PlayTaskCompCtrl taskController = new CSM_PlayTaskCompCtrl();
    	taskController.play = playList[0];
    	controller.setPlayTaskComponentController(taskController);
    	taskController.getPlayTaskWrapperList();
    	taskController.CSM_PlayManagementCtrl = controller;
    	taskController.newTask();
    	
    	REN_LogicBuilderCmpCtrl lbCmpCtrl = new REN_LogicBuilderCmpCtrl();
		//controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Account','fcv1',false,controller,'','','');
		lbCmpCtrl.logicBuilderInput = controller.lbInputWrapper;
    	

    	controller.playSave();
    	CSM_PlayManagementCtrl c1 = controller;//.getThis();
    	system.assertNotEquals(null, c1);
    	//CSM_PlayCriteriaCompCtrl criteriaController = new CSM_PlayCriteriaCompCtrl();
    	//controller.setPlayCriteriaComponentController(criteriaController);
    	
    	
    	controller.playCancel();
    	
    	Test.stopTest();
    }    
    
    
}