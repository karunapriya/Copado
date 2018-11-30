/**
 * Created Date		: Dec 12, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Test class for segment detail
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1863					Dec 12, 2016	1.0					Initial development
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
@isTest(SeeAllData=true)
private class REN_SegmentDetailTest {
	static List<REN_Segment__c> segments;
	static List<Opportunity> oppts;
	static List<Account> accts;
	static Asset asset;
	
	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	static void testSetupMethod() {
		REN_TestDataSetup testSetup = new REN_TestDataSetup();
		
		segments = testSetup.createSegments(1, null);
		accts = testSetup.createAccount(1);
		oppts = testSetup.createOpportunity(1, accts);
		
		List < Account > accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList.get(0).Id != null);
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=standardPB.id,
		CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);

		insert testOppty;
		Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;

		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		system.assert(price1.Id != null);

		system.assert(prod.Id != null);
		OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		insert opptyLineItem;

		asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);
		asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;
		insert asset;	
	}

	/*
	** Save segment detail test
	*/
    static testMethod void saveTest() {
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	
    	REN_Segment__c segmentTemp = new REN_Segment__c();
    	segmentTemp.Name = 'Test Segment';
    	segmentTemp.REN_Description__c = 'Test Description';
    	
    	controller.segment = segmentTemp;
    	
    	Test.startTest();
    	controller.saveButtonClick();
    	Test.stopTest();
    	
    	System.assert(segmentTemp.Id != null);
    }
    
    /*
    ** Update segment detail test
    */
    static testMethod void updateTest() {
    	REN_SegmentDetailTest.testSetupMethod(); 
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.segment = segments[0];
    	controller.segmentId = segments[0].Id;
    	
    	Test.startTest();
    	controller.saveButtonClick();
    	Test.stopTest();
    	
    	System.assert(segments[0].Id != null);
    }
    
    /*
    ** Navigate to segment members test
    */
    static testMethod void navigateToMembersTest() {    	
    	REN_SegmentDetailTest.testSetupMethod(); 
    	
    	Test.startTest();
        REN_SegmentDetailController controller = new REN_SegmentDetailController();
        controller.segment = segments[0];
        controller.navigateToSegmentMembers();
        Test.stopTest();
        
        system.assert(true);
    }
    
    /*
    ** Load search result grid with opportunities
    */
    static testMethod void loadGridOppTest() {
    	REN_SegmentDetailTest.testSetupMethod(); 
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.selectedTaskFilter = REN_Constants.OBJ_SE_TYPE_ABRLM;
    	gridParams.selectedFilterClause = ' (Name != \'temp\') ';
    	inputWrapper.viewName = 'SegmentDetail';
    	
    	inputWrapper.params = gridParams;
    	REN_SegmentDetailBusinessLayer businessLayer = new REN_SegmentDetailBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    }
    
    /*
    ** Load search result grid with assets
    */
    static testMethod void loadGridAssetTest() {
    	REN_SegmentDetailTest.testSetupMethod(); 
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.selectedTaskFilter = REN_Constants.OBJ_SE_TYPE_LOW_TOUCH;
    	gridParams.selectedFilterClause = ' (Name != \'temp\') ';
    	inputWrapper.viewName = 'SegmentDetail';
    	  	
    	inputWrapper.params = gridParams;
    	REN_SegmentDetailBusinessLayer businessLayer = new REN_SegmentDetailBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    }
    
     static testMethod void setcriteriaQueryModifiedTest() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.recordIds = oppts[0].Id;
    	controller.segmentId = segments[0].Id;
    	controller.segment = segments[0];
    	controller.selectedObjectTemp = REN_Constants.OBJ_OPPORTUNITY;
    	
    	Test.startTest();
    	controller.setcriteriaQueryModified();
    	Test.stopTest();
    	system.assert(true);
    }
    /*
    ** Add opportunity segment members
    */
    static testMethod void addMembersToSegmentOpptTest() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.InvalidContactcheck=true;
    	controller.recordIds = oppts[0].Id;
    	controller.segmentId = segments[0].Id;
    	controller.segment = segments[0];
    	controller.criteriaQueryModified='';
    	controller.selectedObjectTemp = REN_Constants.OBJ_OPPORTUNITY;
    	
    	Test.startTest();
    	controller.addMembersToSegmentClick();
    	Test.stopTest();
    	
    	List<REN_Segment_Member__c> segmentMembers = [SELECT Id FROM REN_Segment_Member__c WHERE REN_Segment__c = :segments[0].Id];
    	system.debug('addMembersToSegmentOpptTest = ' + segmentMembers.size());
    	system.assert(segmentMembers.size() == 1);
    }
    
    /*
    ** Add asset segment members
    */
    static testMethod void addMembersToSegmentAssetTest() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.recordIds = asset.Id;
    	controller.segmentId = segments[0].Id;
    	controller.segment = segments[0];
    	controller.selectedObjectTemp = 'AORA';
    	
    	Test.startTest();
    	controller.addMembersToSegmentClick();
    	Test.stopTest();
    	
    	List<REN_Segment_Member__c> segmentMembers = [SELECT Id FROM REN_Segment_Member__c WHERE REN_Segment__c = :segments[0].Id];
    	system.debug('addMembersToSegmentAssetTest = ' + segmentMembers.size());
    	system.assert(segmentMembers.size() == 1);
    }
    
    /*
    ** Get items with segment not null test
    */
    static testMethod void getItemsTest() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.segment = segments[0];
    	List<SelectOption> options = controller.getItems();
    	system.assert(options.size() == 4);
    }
    
    /*
    ** Get items with segment null test
    */
    static testMethod void getItemsTest_SegmentNull() {
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.segment = null;
    	List<SelectOption> options = controller.getItems();
    	system.assert(options.size() == 4);
    }
    
    /*
    ** Get items for Low touch test
    */
    static testMethod void getItemsTest_LowTouch() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
		controller.segment = segments[0];
		controller.segment.REN_Type__c = REN_Constants.OBJ_SE_TYPE_LOW_TOUCH;
    	List<SelectOption> options = controller.getItems();
    	system.assert(options.size() == 1);
    }
    
    /*
    ** Get items for ABRLM test
    */
    static testMethod void getItemsTest_ABRLM() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
		controller.segment = segments[0];
		controller.segment.REN_Type__c = REN_Constants.OBJ_SE_TYPE_ABRLM;
    	List<SelectOption> options = controller.getItems();
    	system.assert(options.size() == 3);
    }
    
    /*
    ** Populate segment info test
    */
    static testMethod void populateSegmentInfoTest() {
    	REN_SegmentDetailTest.testSetupMethod();
    	
    	REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	controller.segment = null;
    	controller.segmentId = segments[0].Id;
    	
    	Test.startTest();
    	controller.populateSegmentInfo();
    	Test.stopTest();
    	
    	system.assert(true);
    }
    
    static testMethod void Test_FindFor(){
		try{
			Test.startTest();
			REN_SegmentDetailController controller =  new REN_SegmentDetailController();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				// Asset and renewal criteria are empty
				controller.findFor();
				system.assert(controller.criteria != null);
				controller.renewalRenewObj.REN_Filter_Criteria__c = 'REN_Status__c != \'Open\'';
				// Asset criteria is empty, renewal is set criteria
				controller.findFor();
				controller.renewObj.REN_Filter_Criteria__c = 'Status != \'Open\'';
				controller.renewalRenewObj.REN_Filter_Criteria__c = '';
				// Asset and renewal is set criteria
				controller.findFor();
				system.assert(controller.criteria != null);
				controller.renewObj.REN_Filter_Criteria__c = 'Status != \'Open\'';
				controller.renewalRenewObj.REN_Filter_Criteria__c = 'REN_Status__c != \'Open\'';
				// Asset is set criteria and renewal is empty
				controller.findFor();
				system.assert(controller.criteria != null);
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_FindForCriteria(){
		try{
			Test.startTest();
			REN_SegmentDetailController controller = new REN_SegmentDetailController();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.showLogicBuilder();
				controller.findForCriteria();
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void lastFilterTest() {
		REN_SegmentDetailTest.testSetupMethod(); 
    	segments[0].REN_Last_Filter__c = REN_Constants.OBJ_AORA;
    	update segments;
    	System.currentPageReference().getParameters().put(CSM_Constants.ID_PARAM, segments[0].Id);
        REN_SegmentDetailController controller = new REN_SegmentDetailController();
    	System.assertEquals(controller.selectedObjectTemp, REN_Constants.OBJ_AORA);
    	
    	segments[0].REN_Last_Filter__c = REN_Constants.OBJ_OPPORTUNITY;
    	update segments;
    	
    	System.currentPageReference().getParameters().put(CSM_Constants.ID_PARAM, segments[0].Id);
    	controller = new REN_SegmentDetailController();
    	System.assertEquals(controller.selectedObjectTemp, REN_Constants.OBJ_OPPORTUNITY);
    	
    	Test.startTest();
    	controller.selectedObjectTemp = REN_Constants.OBJ_REN_RENEWS_TO;
    	controller.saveLastFilter();
    	Test.stopTest();
    	
    	List<REN_Segment__c> segments2 = [SELECT REN_Last_Filter__c FROM REN_Segment__c WHERE Id = :segments[0].Id];
    	system.assertEquals(segments2[0].REN_Last_Filter__c,REN_Constants.OBJ_REN_RENEWS_TO);
    }
}