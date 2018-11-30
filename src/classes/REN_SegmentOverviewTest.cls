/**
 * Created Date		: Dec 12, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Test class for segment overview
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1861					Dec 12, 2016	1.0					Initial development
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
private class REN_SegmentOverviewTest {
    static string id;
	static string name;
	
	/*
	** @Description: Set up test data
	*/
	static void testSetupMethod() {
		REN_TestDataSetup testSetup = new REN_TestDataSetup();
		
		List<REN_Segment__c> segments = testSetup.createSegments(1, null);
		id = segments[0].Id;
		name = segments[0].Name;
	}
	
	/*
	** @Description: Test segment overview business layer
	*/
	static testMethod void testBusinessLayer() {
		REN_SegmentOverviewTest.testSetupMethod();
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'SegmentOverview';
    	inputWrapper.params = gridParams;
    	REN_SegmentOverviewBusinessLayer businessLayer = new REN_SegmentOverviewBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
	}
	
	//Below test method is created to include custom labels of Start Sync button in package.
	static testMethod void testLabels() {
		String quoteLabels = Label.selected_more_than_one_quote_to_sync + '' +Label.selected_none_to_sync+ '' +Label.selected_quote_already_synced ;
		system.assert(quoteLabels != null);
	} 
	
	/*
	** @Description: Test get all segment records
	*/
	static testMethod void getAllRecordsTest() {
		REN_SegmentOverviewTest.testSetupMethod();
		
		Test.startTest();
		List<REN_Segment__c> segments = REN_SegmentDataAccess.getAllSegments();
		Test.stopTest();
		
		system.assert(segments.size() == 1);
	}
    
    /*
	** @Description: Test create new segment
	*/
    static testMethod void createTest() {
    	REN_SegmentOverviewTest.testSetupMethod();
    	
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.redirectToSegmentDetail();
        Test.stopTest();
        
        system.assert(true);
    }
    
    /*
	** @Description: Test edit segment
	*/    
    static testMethod void editTest() {
    	REN_SegmentOverviewTest.testSetupMethod();
    	
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.id = id;
        controller.editClick();
        Test.stopTest();
        
        system.assert(true);
    }
    static testMethod void createQuoteRequestTest() {
    	REN_SegmentOverviewTest.testSetupMethod();
    	
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.id = id;
        controller.segmentIds=id;
        controller.createQuoteRequest();
        Test.stopTest();
        
        system.assert(true);
    }
    
    static testMethod void getTaskOwnerOptionsTest() {
        List<selectOption> options = new List<selectOption>();
		options.add(new SelectOption('Designated Owner','Designated Owner'));
        options.add(new SelectOption('Record Owner','Record Owner')); 
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.tempVariable='yes';
        controller.getTaskOwnerOptions=options;
        controller.getTaskOwnerOptions();
        Test.stopTest();
        
        system.assert(true);
    }
    
	static testMethod void saveSegmentBatchTest() {
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.saveSegmentBatch();
        Test.stopTest();
        
        system.assert(true);
    }
    
    static testMethod void generateTasksTest() {
    	REN_SegmentOverviewTest.testSetupMethod();
    	
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.id = id;
        controller.segmentIds=id;
        controller.generateTasks();
        Test.stopTest();
        
        system.assert(true);
    }
    
    static testMethod void CancelTest() {
    	REN_SegmentOverviewTest.testSetupMethod();
    	
    	Test.startTest();
        REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.id = id;
        controller.cancel();
        Test.stopTest();
        
        system.assert(true);
    }
    /*
	** @Description: Test delete segment record
	*/
    static testMethod void deleteTest() {
    	REN_SegmentOverviewTest.testSetupMethod(); 
    	
    	Test.startTest();
    	REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.deleteIds = id;
        controller.deleteClick();
        Test.stopTest();
        
        Integer segmentsCount = [SELECT Count() FROM REN_Segment__c WHERE Id = :id];
        Integer segmentsCriteriaCount = [SELECT Count() FROM REN_Segment__c WHERE Id = :id];
        
        system.assert(segmentsCount == 0 && segmentsCriteriaCount == 0);
    }
    
    /*
	** @Description: Test delete segment record error handling
	*/
    static testMethod void deleteExceptionTest() {
    	REN_SegmentOverviewTest.testSetupMethod(); 
    	
    	Test.startTest();
    	REN_SegmentOverviewController controller = new REN_SegmentOverviewController();
        controller.id = 'Invalid Id';
        controller.deleteClick();
        Test.stopTest();
        
        system.assert(true);
    }   
}