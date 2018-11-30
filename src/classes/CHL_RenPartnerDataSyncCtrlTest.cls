@isTest
private class CHL_RenPartnerDataSyncCtrlTest {

    static testMethod void testWithNoRecords_OppStatusLog() {
		User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
		insert adminUser;
		list < PermissionSetAssignment > lstPSAssignments = new list < PermissionSetAssignment > ();
		PermissionSet ps = CHL_TestUtility.getPermissionSet('PRISM_Base');
		lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
		insert lstPSAssignments;
		System.RunAs(adminUser) {
			Test.startTest();
				CHL_RenPartnerDataSyncCtrl controller = new CHL_RenPartnerDataSyncCtrl();
				controller.save();
				controller.getQuoteOptions();
				controller.saveOppQuote();
				PageReference pr = controller.Cancel();
				System.assert(pr != null);
			Test.stopTest();
		}
    }
    
    static testMethod void testWithRecords_OppStatusLog() {
		 User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
		 insert adminUser;
		 list < PermissionSetAssignment > lstPSAssignments = new list < PermissionSetAssignment > ();
		 PermissionSet ps = CHL_TestUtility.getPermissionSet('PRISM_Base');
		 lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
		 insert lstPSAssignments;
		 System.RunAs(adminUser) {
		 	Test.startTest();
			 	CHL_RenPartnerDataSyncCtrl controller = new CHL_RenPartnerDataSyncCtrl();
			 	CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c();
			 	optyStatusLogObj.CHL_Field_API_Names__c = 'StageName';
			 	optyStatusLogObj.CHL_Days_between_Update__c = 12;
			 	optyStatusLogObj.CHL_Quote_PDF_Option__c = 'Notes & Attachment';
			 	insert optyStatusLogObj;
			
			 	REN_FieldMappingComponentController fmc = new REN_FieldMappingComponentController();
			 	controller.setBaseChildController(fmc);
			 	controller.setMappingToControllerMap('PartnerOpp to MasterOpp', controller.getBaseChildController());
			 	controller.setQuoteSelectedOption('Notes & Attachment');
			 	PageReference pr = controller.save();
			 	System.assert(pr == null);
			 	controller.save();
			 	controller.getQuoteOptions();
			 	controller.saveOppQuote();
			 	pr = controller.Cancel();
			 	System.assert(pr != null);
		 	Test.stopTest();
		 }
    }
    
}