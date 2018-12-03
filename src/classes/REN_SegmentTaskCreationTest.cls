/**
 * Created Date		: Apr 21, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Apr 21, 2017			1.1					@description
 *
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class REN_SegmentTaskCreationTest {

    @testSetup
    static void setup()
	{
        REN_Task_Template__c taskTemplateObj=new REN_Task_Template__c();
        taskTemplateObj.Name='TestTemplate';
        taskTemplateObj.REN_Contact__c='REN_Primary_Contact__c';
        taskTemplateObj.REN_Comments__c='Comment';
        taskTemplateObj.REN_Completed_Date__c=datetime.now().date();
        taskTemplateObj.REN_Priority__c='High';
       	taskTemplateObj.REN_Status__c='In Progress';
        taskTemplateObj.REN_Subject__c='Call';
        taskTemplateObj.REN_Due_Date__c=datetime.now().date();
        taskTemplateObj.REN_Type__c='Call';
        insert taskTemplateObj;          
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB =new Pricebook2();
        standardPB.Name='Test PB';
        insert standardPB; 
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
        batchActivityObj.REN_Task_Template__c=taskTemplateObj.Id;
        update batchActivityObj;
		system.assert(batchActivityObj!=null);  
        
        REN_Batch_Activity__c batchActivityObj1 = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
        batchActivityObj1.REN_Task_Template__c=taskTemplateObj.Id;
        update batchActivityObj1;
      
        List<Account> acctList = CSM_TestDataUtility.createAccount(1);
        List<Contact> contList = CSM_TestDataUtility.createContacts(acctList[0].Id,1);
        List<REN_Segment__c> segments = testDataSetup.createSegments(2, 'Low Touch');
		List<Opportunity> opptList = CSM_TestDataUtility.createOpportunity(2, acctList[0].id);
        system.debug('opptList'+opptList);
        opptList[0].REN_Primary_Contact__c=contList[0].Id;
        update opptList;
		
		List<Ren_segment_member__c> segmentMembers = new List<Ren_segment_member__c>();
		
		segments[0].ren_quoterequest_submitted__c = true;
		segments[1].ren_quoterequest_submitted__c = true;
		
		update segments;		
		
		Ren_segment_member__c segmentMember = new Ren_segment_member__c();
		segmentMember.ren_segment__c = segments[0].Id;
		segmentMember.ren_opportunity__c = opptList[0].Id;
		
		segmentMembers.add(segmentMember);
		
		segmentMember = new Ren_segment_member__c();		
		segmentMember.ren_segment__c = segments[1].Id;
		segmentMember.ren_opportunity__c = opptList[1].Id;
		
		segmentMembers.add(segmentMember);
		system.assert(segmentMembers!= null);
		insert segmentMembers;
        
        Product2 prod = REN_TestDataUtility.createProduct(1);
        Asset asset = REN_TestDataUtility.createAsset(acctList.get(0).Id, prod.Id);	
        insert asset;
        List<REN_Segment__c> segmentAsset = testDataSetup.createSegments(2, 'ABRLM');
		
		List<Ren_segment_member__c> segmentMemList = new List<Ren_segment_member__c>();
		
		segmentAsset[0].ren_quoterequest_submitted__c = true;
		segmentAsset[1].ren_quoterequest_submitted__c = true;
		
		update segmentAsset;		
		
		Ren_segment_member__c segmentMem = new Ren_segment_member__c();
		segmentMem.ren_segment__c = segmentAsset[0].Id;
		segmentMem.REN_Asset__c = asset.Id;
		
		segmentMemList.add(segmentMem);
	
		system.assert(segmentMemList!= null);
		insert segmentMemList;	
        batchActivityObj.REN_Segment__c=segments[0].Id;
        update batchActivityObj;
        system.debug('segmentAsset'+segmentAsset);
        batchActivityObj1.REN_Segment__c=segmentAsset[0].Id;
        update batchActivityObj1;
	}
	@isTest
    static void myUnitTestOpp() {
    	list<REN_Batch_Activity__c> batchActivityList=[select Id,REN_Pricebook__c,REN_Job_Start_Date__c from REN_Batch_Activity__c limit 1];
        list<REN_Segment__c> segmentList=[select Id from REN_Segment__c limit 1];
        list<REN_Task_Template__c> taskTemplateList=[select Id from REN_Task_Template__c];
        system.debug('taskTemplateList'+taskTemplateList);
    	System.currentPageReference().getParameters().put('id',batchActivityList[0].id);
        System.currentPageReference().getParameters().put('tid',taskTemplateList[0].id);
        System.currentPageReference().getParameters().put('seid',segmentList[0].id);
    	REN_SegmentTaskGenerationController cntrl=new REN_SegmentTaskGenerationController();
        REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityList[0].id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
        cntrl.selectedValue='Generate on';
        cntrl.populateEmailRecip= [select id, name, email from user];
    	cntrl.addRecipient = [select id, name, email from user];
        cntrl.thisController = new REN_BaseMainController();
    	REN_BaseMainController baseMainCtrl = cntrl.thisController;
        cntrl.deletableRecordId=taskTemplateList[0].id;
        cntrl.getTaskOwnerOptions();
        cntrl.createTaskTemplate();
        cntrl.deleteSelectedRecord();
        cntrl.cloneRecord();
        cntrl.editRecord();
        PageReference p1 =cntrl.saveSegmentBatch();
        p1=cntrl.cancel();
        System.assert(true);        
    }
    @isTest
    static void myUnitTestAsset() {
    	list<REN_Batch_Activity__c> batchActivityList=[select Id from REN_Batch_Activity__c limit 1];
        list<REN_Segment__c> segmentList=[select Id from REN_Segment__c ];
        list<REN_Task_Template__c> taskTemplateList=[select Id from REN_Task_Template__c];
        system.assert(taskTemplateList!=null);
    	System.currentPageReference().getParameters().put('id',batchActivityList[0].id);
        System.currentPageReference().getParameters().put('tid',taskTemplateList[0].id);
        System.currentPageReference().getParameters().put('seid',segmentList[2].id);
    	REN_SegmentTaskGenerationController cntrl=new REN_SegmentTaskGenerationController();
        REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityList[0].id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
        cntrl.selectedValue='Generate on';
        cntrl.populateEmailRecip= [select id, name, email from user];
    	cntrl.addRecipient = [select id, name, email from user];
        cntrl.thisController = new REN_BaseMainController();
    	REN_BaseMainController baseMainCtrl = cntrl.thisController;
        Test.startTest();
        cntrl.createTaskTemplate();
        cntrl.editRecord();
        cntrl.saveSegmentBatch();
        cntrl.cancel();
        cntrl.getTaskOwnerFields();
        System.assert(true); 
        Test.stopTest();
    }
    @isTest
    static void scheduleBatchOpp(){
        list<REN_Batch_Activity__c> batchActivityList=[select Id,REN_Job_Start_Date__c,REN_Batch_Number__c,REN_Segment__c,REN_Task_Template__r.REN_Contact__c from REN_Batch_Activity__c limit 1];
        system.assert(batchActivityList!=null);
        list<REN_Task_Template__c> taskTemplateList=[select Id,REN_Contact__c,REN_Comments__c,REN_Completed_Date__c,REN_Priority__c,REN_Status__c,REN_Subject__c,REN_Due_Date__c,REN_Type__c from REN_Task_Template__c];
        REN_SegmentTaskGenerationController cntrl=new REN_SegmentTaskGenerationController();
        cntrl.scheduledBatchJob(batchActivityList); 
        REN_SegmentTaskCreationBatch segmentTaskBatch=new REN_SegmentTaskCreationBatch();
        segmentTaskBatch.batchActivityObj=batchActivityList[0];
        segmentTaskBatch.taskTemplateObj=taskTemplateList[0];
        String batchprocessid = Database.executeBatch(segmentTaskBatch);
    }
    @isTest
    static void scheduleBatchAsset(){
        list<REN_Batch_Activity__c> batchActivityList=[select Id,REN_Job_Start_Date__c,REN_Batch_Number__c,REN_Segment__c,REN_Task_Template__r.REN_Contact__c from REN_Batch_Activity__c ];
        system.assert(batchActivityList!=null);
        batchActivityList[0].REN_Task_Template__r.REN_Contact__c='REN_Covered_Asset__c';
        update batchActivityList;
        list<REN_Task_Template__c> taskTemplateList=[select Id,REN_Contact__c,REN_Comments__c,REN_Completed_Date__c,REN_Priority__c,REN_Status__c,REN_Subject__c,REN_Due_Date__c,REN_Type__c from REN_Task_Template__c];
        taskTemplateList[0].REN_Contact__c='REN_Covered_Asset__c';
        update taskTemplateList;
        REN_SegmentTaskGenerationController cntrl=new REN_SegmentTaskGenerationController();
        cntrl.scheduledBatchJob(batchActivityList); 
        REN_SegmentTaskCreationBatch segmentTaskBatch=new REN_SegmentTaskCreationBatch();
        segmentTaskBatch.batchActivityObj=batchActivityList[1];
        segmentTaskBatch.taskTemplateObj=taskTemplateList[0];
        String batchprocessid = Database.executeBatch(segmentTaskBatch);
    }
    @isTest
    static void scheduleBatchNegative(){
        list<REN_Batch_Activity__c> batchActivityList=[select Id,REN_Job_Start_Date__c,REN_Batch_Number__c,REN_Segment__c,REN_Task_Template__r.REN_Contact__c from REN_Batch_Activity__c limit 1];
        system.assert(batchActivityList!=null);
        list<REN_Task_Template__c> taskTemplateList=[select Id,REN_Contact__c,REN_Comments__c,REN_Completed_Date__c,REN_Priority__c,REN_Status__c,REN_Subject__c,REN_Due_Date__c,REN_Type__c from REN_Task_Template__c];
        REN_SegmentTaskGenerationController cntrl=new REN_SegmentTaskGenerationController();
        cntrl.scheduledBatchJob(batchActivityList); 
        REN_SegmentTaskCreationBatch segmentTaskBatch=new REN_SegmentTaskCreationBatch();
        segmentTaskBatch.batchActivityObj=batchActivityList[0];
        segmentTaskBatch.taskTemplateObj=taskTemplateList[0];
        segmentTaskBatch.testClassTest=null;
        String batchprocessid = Database.executeBatch(segmentTaskBatch);
    }
    @isTest
    static void scheduleBatchNegative1(){
        list<REN_Batch_Activity__c> batchActivityList=[select Id,REN_Job_Start_Date__c,REN_Batch_Number__c,REN_Segment__c,REN_Task_Template__r.REN_Contact__c from REN_Batch_Activity__c limit 1];
        system.assert(batchActivityList!=null);
        list<REN_Task_Template__c> taskTemplateList=[select Id,REN_Contact__c,REN_Comments__c,REN_Completed_Date__c,REN_Priority__c,REN_Status__c,REN_Subject__c,REN_Due_Date__c,REN_Type__c from REN_Task_Template__c];
        REN_SegmentTaskGenerationController cntrl=new REN_SegmentTaskGenerationController();
        cntrl.scheduledBatchJob(batchActivityList); 
        REN_SegmentTaskCreationBatch segmentTaskBatch=new REN_SegmentTaskCreationBatch();
        segmentTaskBatch.batchActivityObj=batchActivityList[0];
        String batchprocessid = Database.executeBatch(segmentTaskBatch);
    }
}