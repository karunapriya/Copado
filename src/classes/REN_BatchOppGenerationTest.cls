@isTest(SeeAllData=true)
private class REN_BatchOppGenerationTest {

    static testMethod void myUnitTest() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest')[0];
			
    	Test.startTest(); 
    	
    	REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
    	controller.deletableRecordId = rc.id +'';
    	controller.selectedRowId = rc.id +'';
    	
    	PageReference p1 = controller.createFilterRecord();
    	p1 = controller.createGroupRecord();
    	p1 = controller.deleteSelectedRecord();
    	p1 = controller.editSourceRecord();
    	p1 = controller.editGroupRecord();
    	
    	controller.getDateFormulaOptions();
	    system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testCloning()
    {
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('TestClone');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyFilterClone')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGroupClone')[0];
    
        Test.startTest(); 
    	
    	REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
    	
    	controller.cloneSourceRecordId = rc.id +'';
    	controller.cloneGroupRecordId = rc_group.id +'';
    	
    	PageReference p1 = controller.cloneSourceRecord();
    	system.assertNotEquals(p1,null);
    	p1 = controller.cloneGroupRecord();
    	system.assertNotEquals(p1,null);
    	
    	controller.deletableRecordId = rc.id +'';
    	p1 = controller.deleteSelectedRecord();
    	p1 = controller.cloneSourceRecord();
    	system.assertEquals(p1,null);
    	
    	controller.deletableRecordId = rc_group.id +'';
    	p1 = controller.deleteSelectedRecord();
    	p1 = controller.cloneGroupRecord();
    	system.assertEquals(p1,null);
    	
	    
	    Test.stopTest();
    }
    
    static testMethod void testSaveMethod() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
		REN_Email_Recipient__c newemailuser = new REN_Email_Recipient__c();
		newemailuser.REN_Batch__c = batchActivityObj.id;
		newemailuser.REN_Recipient__c = 'test';
		newemailuser.REN_User__c = userInfo.getuserID();
		insert newemailuser;
    	Test.startTest();     	
    	
	    PageReference myPage = Page.REN_BatchOppGeneration;	   
	    myPage.getParameters().put('id',batchActivityObj.id);
	    Test.setCurrentPageReference(myPage);
	    system.debug(' batchActivityObj ID : '+batchActivityObj.Id);
	    REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    controller.selectedValue = 'Generate on';
    	controller.selectedRowId = rc.id +'';
    	controller.selectedGroupRowId = rc_group.id + '';
    	controller.batchActivity.REN_Pricebook__c = standardPB.id;
    	controller.batchActivity.REN_Job_Start_Date__c = DateTime.now();
    	controller.populateEmailRecip = [select id, name, email from user];
    	controller.addRecipient = [select id, name, email from user];
    	controller.thisController = new REN_BaseMainController();
    	REN_BaseMainController baseMainCtrl = controller.thisController;
    	PageReference p1 = controller.saveBatchOpp();
    	p1 = controller.cancel();
	    system.assert(true);
	    
	    REN_Email_Recipient__c emailRep = new REN_Email_Recipient__c();
	    emailRep.REN_Batch__c = batchActivityObj.id;
		emailRep.REN_Recipient__c = 'test';
		emailRep.REN_User__c = userInfo.getuserID();
		List<REN_Email_Recipient__c> emailRepList = new List<REN_Email_Recipient__c>();
		emailRepList.add(emailRep);
		
		emailRepList = REN_EmailRecipientDataAccess.saveEmailRecip(emailRepList);
		system.assertNotEquals(emailRep,null);	
		
		List<User> emailRepDelList= [select id,name,email from user where id = :userInfo.getuserId()];
		String batId = String.valueOf(batchActivityObj.id);
		Boolean delRec = REN_EmailRecipientDataAccess.deleteEmailRecip(emailRepDelList,batId);
		system.assertEquals(delRec,true);
	    Test.stopTest();
    }
    
    static testMethod void testSaveMethod_RunButton() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest3')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping2')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
    	Test.startTest();     	
    	
	    PageReference myPage = Page.REN_BatchOppGeneration;	   
	    myPage.getParameters().put('id',batchActivityObj.id);
	    Test.setCurrentPageReference(myPage);
	    REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    controller.selectedValue = 'Generate now';
    	controller.selectedRowId = rc.id +'';
    	controller.selectedGroupRowId = rc_group.id + '';
    	controller.batchActivity.REN_Pricebook__c = standardPB.id;
    	PageReference p1 = controller.saveBatchOpp();
	    system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testSaveMethod_Negative() {
		Test.startTest();     	
    	
	    PageReference myPage = Page.REN_BatchOppGeneration;	   
	    Test.setCurrentPageReference(myPage);
	    REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    controller.selectedRowId = '';
    	controller.selectedGroupRowId = '';
    	PageReference p1 = controller.saveBatchOpp();
	    system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testSaveMethod_Negative2() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyNegativeTest')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyNegativeGrouping')[0];
    	Test.startTest();     	
    	REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
    	controller.selectedRowId = rc.id +'';
    	controller.selectedValue = 'Generate now';
    	PageReference p1 = controller.saveBatchOpp();
    	controller.selectedGroupRowId = rc_group.id + '';
    	p1 = controller.saveBatchOpp();
	    system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testSaveMethod_Negative3() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyNegativeGrouptest')[0];
    	Test.startTest();     	
    	REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
    	controller.selectedValue = 'Generate now';
    	//controller.selectedRowId = '';
    	PageReference p1 = controller.saveBatchOpp();
    	controller.selectedGroupRowId = rc_group.id + '';
    	p1 = controller.saveBatchOpp();
	    system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testSaveMethod_Negative_DateValidations() {
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyNegativeTest2')[0];
    	Test.startTest();     	
    	REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
	    controller.selectedRowId = rc.id +'';
    	controller.selectedValue = 'Generate on';
    	PageReference p1 = controller.saveBatchOpp();
    	p1 = controller.saveBatchOpp();
	    system.assert(true);
	    Test.stopTest();
    }
    
    static testMethod void testBusinessLayer() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest')[0];
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'Filter';
    	inputWrapper.params = gridParams;
    	REN_BatchOppGenBusinessLayer businessLayer = new REN_BatchOppGenBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
   		system.assertEquals(responseWrapper.hasAction, true);
    	system.assertEquals(responseWrapper.hasCheckbox, false);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	Test.stopTest();
    }
    static testMethod void testDeleteMethod_Negative() {
    	User RestrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest')[0];
			
    	Test.startTest(); 
    	
    	REN_BatchOppGenerationController controller = new REN_BatchOppGenerationController();
	    PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
    	controller.deletableRecordId = rc.id +'';
    	controller.selectedRowId = rc.id +'';
    	
    	PageReference p1 = controller.createFilterRecord();
    	p1 = controller.createGroupRecord();
    	system.runas(RestrictedUser){
    		p1 = controller.deleteSelectedRecord();
    	}
	    system.assert(true);
	    Test.stopTest();
    }
}