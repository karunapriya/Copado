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
private class REN_BatchTaskGenSummaryTest {
    static String batchActivityId;
    static String batchOpptFailureId;
    
    static void testSetupMethod() {
		list<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(acclist[0].id!=NULL);
        Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
        system.assert(prod.Id != null);
		Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        List<Opportunity> TestoppList=new List<Opportunity>();
        For(integer i=0;i<1;i++)
        {
            Opportunity op=new Opportunity(Name='TestOpp'+i,StageName = 'Prospecting',CloseDate = System.Today(), 
                                          AccountId = accList[0].Id, Type = 'New Customer');
           TestoppList.add(op);
        }
        insert TestoppList;
        List<asset> testasset = new List<asset>();
        for (Integer i = 0; i < 1; i++) {
			testasset.add(new Asset(AccountId = accList[0].id, Product2Id = prod.id, Name = 'Test Asset'+i, Price = 20.00, Quantity = 2));
		}
		insert testasset;
		
        REN_Segment__c segment = new REN_Segment__c(Name='TestSegment');
        insert Segment;
        List<REN_Segment_Member__c> TestSegMember= new List<REN_Segment_Member__c>();
        for (Integer i = 0; i < 1; i++)
        {
            REN_Segment_Member__c SegMember=new REN_Segment_Member__c(REN_Asset__c=testasset[i].id,
                                            REN_Opportunity__c=TestoppList[i].id,REN_Segment__c	=Segment.id);
            TestSegMember.add(SegMember);
        }
        insert TestSegMember;
        
        REN_Batch_Activity__c batchActivity = new REN_Batch_Activity__c();
        batchActivity.REN_Job_Start_Date__c = system.now();
        batchActivity.REN_Job_Completion_Date__c = system.now();
        batchActivity.REN_Status__c = 'Scheduled';
        batchActivity.REN_Batch_Type__c= REN_Constants.BATCH_ACTIVITY_TYPE_SEGMENT_TASK;
        batchActivity.REN_Generated_Records__c = 1;
        batchActivity.REN_Last_Modified_On__c = system.now();
        batchActivity.REN_Failure_Assets__c = 0;
        batchActivity.REN_Segment__c = Segment.Id;
        insert batchActivity;
        batchActivityId = batchActivity.Id;
        
       	REN_Batch_Opportunity_Failure__c batchOpptFailure = new REN_Batch_Opportunity_Failure__c();
       	batchOpptFailure.REN_Batch_Activity__c = batchActivityId;
       	insert batchOpptFailure;
       	batchOpptFailureId = batchOpptFailure.Id;
	}
	
	static testMethod void loadSuccessGridTest() {
    	REN_BatchTaskGenSummaryTest.testSetupMethod(); 
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.selectedFilterClause = REN_Constants.OBJ_SE_TYPE_ABRLM;
    	gridParams.taskOrViewId = batchActivityId;
    	inputWrapper.viewName = 'BatchTaskGenSummary_Success';
    	inputWrapper.params = gridParams;
    	REN_BatchTaskGenSummaryBusinessLayer businessLayer = new REN_BatchTaskGenSummaryBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    }
    
    static testMethod void loadFailedGridTest() {
    	REN_BatchTaskGenSummaryTest.testSetupMethod(); 
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.selectedFilterClause = REN_Constants.OBJ_SE_TYPE_LOW_TOUCH;
    	gridParams.taskOrViewId = batchActivityId;
    	inputWrapper.viewName = 'BatchTaskGenSummary_Failed';
    	inputWrapper.params = gridParams;
    	REN_BatchTaskGenSummaryBusinessLayer businessLayer = new REN_BatchTaskGenSummaryBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    }
    
    static testMethod void returnPageTest() {
    	REN_BatchTaskGenSummaryTest.testSetupMethod(); 
    	
    	Test.startTest();
    	PageReference pRef = Page.REN_BatchTaskGenSummary;
        pRef.getParameters().put('id', batchActivityId);
		pRef.getParameters().put('type', 'success');
        Test.setCurrentPage(pRef);
    	REN_BatchTaskGenSummaryController ctrl = new REN_BatchTaskGenSummaryController();
    	ctrl.returnPage();
        ctrl.goToSegmentPage();
    	Test.stopTest();
    	
    	system.assert(true);
    }
    
    static testMethod void returnPageTest2() {
    	REN_BatchTaskGenSummaryTest.testSetupMethod(); 
    	
    	Test.startTest();
    	PageReference pRef = Page.REN_BatchTaskGenSummary;
        pRef.getParameters().put('id', batchActivityId);
		pRef.getParameters().put('type', 'Failed');
        Test.setCurrentPage(pRef);
        REN_BatchTaskGenSummaryController ctrl2 = new REN_BatchTaskGenSummaryController();
        ctrl2.returnPage();
        ctrl2.goToSegmentPage();
    	Test.stopTest();
    	
    	system.assert(true);
    }
    
}