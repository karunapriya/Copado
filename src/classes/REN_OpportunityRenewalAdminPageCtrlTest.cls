@isTest
private class REN_OpportunityRenewalAdminPageCtrlTest {

    static testMethod void Test_OpptyAdminPage() {
        Test.startTest();
        PageREference pageRef = Page.ren_opportunityrenewaladmin;
        pageRef.getParameters().put(CSM_Constants.ADMIN_HYPERLINK_FLAG, 'false');
    	Test.setCurrentPage(pageRef);
    	
    	REN_OpportunityRenewalAdminPageCtrl controller = new REN_OpportunityRenewalAdminPageCtrl();
    	
    	//controller.saveRenewOpptAdmin();
    	controller = new REN_OpportunityRenewalAdminPageCtrl();
    	PageReference cancelRef = controller.cancel();
    	system.assert(cancelRef != null);
    	PageReference PageRef2 = controller.manageMappings();
    	system.assert(PageRef2 != null);
    	controller.tabCategory = 'Admin';
    	try{
    		controller.saveRenewOpptAdmin();
    	}catch(Exception ex){
    		    	
    	}
    	controller.redirectToBatchOppGeneration();
    	Test.stopTest();
    }
}