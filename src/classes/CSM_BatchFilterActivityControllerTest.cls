/**
 * Created Date		: Oct 28, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Test class for Batch filter activity page
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 *
 *
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
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class CSM_BatchFilterActivityControllerTest {
	static string id;
	static string batchFilterName;
	static string batchFilterCriteriaName;
	
	/*
	** @Description: Set up test data
	*/
	static void testSetupMethod() {
		CSM_TestDataSetup testSetup = new CSM_TestDataSetup();
		
		CSM_Batch_Filter__c batchFilter = testSetup.createBatchFilter();
		id = batchFilter.Id;
		batchFilterName = batchFilter.Name;
		
		CSM_Batch_Filter_Criteria__c batchFilterCriteria = testSetup.createBatchFilterCriteria(id);
		batchFilterCriteriaName = batchFilterCriteria.Name;
	}
	
	/*
	** @Description: Test batch filter activity business layer
	*/
	static testMethod void testBusinessLayer() {
		CSM_BatchFilterActivityControllerTest.testSetupMethod();
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'BatchFilter';
    	inputWrapper.params = gridParams;
    	CSM_BatchFilterActivityBusinessLayer businessLayer = new CSM_BatchFilterActivityBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
	}
	
	
	/*
	** @Description: Test grid attribute
	*/
	static testMethod void gridAttributeTest() {
		CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
		CSM_DataGridAttribute attr = controller.batchFilterActivityGridAttribute;
		
		system.assert(true);
	}	

	/*
	** @Description: Test edit batch filter record
	*/
   	static testMethod void editTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = id;
        controller.editClick();
        Test.stopTest();
        
        system.assert(true);
    }
    
    /*
	** @Description: Test create new batch filter
	*/
    static testMethod void createTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.redirectToBatchFilterGeneration();
        Test.stopTest();
        
        system.assert(true);
    }
    
    /*
	** @Description: Test deactivate batch filter
	*/
    static testMethod void deactivateTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = id;
        controller.deactivateClick();
        Test.stopTest();
        
        CSM_Batch_Filter__c batchFilter = [SELECT CSM_IsActive__c FROM CSM_Batch_Filter__c WHERE Id = :id];
        system.assert(batchFilter.CSM_IsActive__c == false);
    }
    
    /*
	** @Description: Test deactivate batch filter error handling
	*/
    static testMethod void deactivateExceptionTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = 'Invalid Id';
        controller.deactivateClick();
        Test.stopTest();
        
        system.assert(true);
    }
    
    /*
	** @Description: Test activate batch filter
	*/
    static testMethod void activateTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = id;
        controller.activateClick();
        Test.stopTest();
        
        CSM_Batch_Filter__c batchFilter = [SELECT CSM_IsActive__c FROM CSM_Batch_Filter__c WHERE Id = :id];
        system.assert(batchFilter.CSM_IsActive__c == true);
    }
    
    /*
	** @Description: Test activate batch filter error handling
	*/
    static testMethod void activateExceptionTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = 'Invalid Id';
        controller.activateClick();
        Test.stopTest();
        
        system.assert(true);        
    }
    
    /*
	** @Description: Test cloning batch filter record
	*/
    static testMethod void cloneTest() {
   		CSM_BatchFilterActivityControllerTest.testSetupMethod(); 
    	
    	Test.startTest();
    	CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = id;
        controller.cloneClick();
        Test.stopTest();
        
        Integer batchFilterCount = [SELECT Count() FROM CSM_Batch_Filter__c WHERE Name = :batchFilterName];
        Integer batchFilterCriteriaCount = [SELECT Count() FROM CSM_Batch_Filter_Criteria__c WHERE Name = :batchFilterCriteriaName];
        
        system.assert(batchFilterCount == 2 && batchFilterCriteriaCount == 2);
    }
    
    /*
	** @Description: Test cloning batch filter record error handling
	*/
    static testMethod void cloneExceptionTest() {
   		CSM_BatchFilterActivityControllerTest.testSetupMethod(); 
    	
    	Test.startTest();
    	CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = 'Invalid Id';
        controller.cloneClick();
        Test.stopTest();
        
        system.assert(true);
    }
    
    /*
	** @Description: Test delete batch filter record
	*/
    static testMethod void deleteTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod(); 
    	
    	Test.startTest();
    	CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = id;
        controller.deleteClick();
        Test.stopTest();
        
        Integer batchFilterCount = [SELECT Count() FROM CSM_Batch_Filter__c WHERE Id = :id];
        Integer batchFilterCriteriaCount = [SELECT Count() FROM CSM_Batch_Filter_Criteria__c WHERE Id = :id];
        
        system.assert(batchFilterCount == 0 && batchFilterCriteriaCount == 0);
    }
    
    /*
	** @Description: Test delete batch filter record error handling
	*/
    static testMethod void deleteExceptionTest() {
    	CSM_BatchFilterActivityControllerTest.testSetupMethod(); 
    	
    	Test.startTest();
    	CSM_BatchFilterActivityController controller = new CSM_BatchFilterActivityController();
        controller.id = 'Invalid id';
        controller.deleteClick();
        Test.stopTest();
        
        system.assert(true);
    }
}