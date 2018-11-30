@isTest
public with sharing class CSM_FocusCategoryFullListCtrlTest {
	
	static testMethod void testFocusCategoryFullListPage() {
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_FocusCategoriesFullList;
    	// Set the model action
        Test.setCurrentPage(csmPage);
    	ApexPages.currentPage().getParameters().put(CSM_Constants.PARAM_VIEWID, CSM_TestUtility.focusCategoryView.Id);
        CSM_FocusCategoriesFullListController controller = new CSM_FocusCategoriesFullListController();
    	system.assert(controller.hasCSMAccess==true);
    	
    	PageReference pageRef = controller.getListForViewId();
    	System.assert(pageRef==null);
    	
    	/*pageRef = controller.updateListViews();
    	System.assert(pageRef==null);*/
    	
    	controller.idVal = CSM_TestUtility.acct.Id;
    	pageRef = controller.redirectToAccountPlan();
    	System.assert(pageRef!=null);
    	
    	controller.focusCategoryObjectType = 'Account';
    	pageRef = controller.createNewFocusCategory();
    	System.assert(pageRef!=null);
    	
    	pageRef = controller.editNewFocusCategory();
    	System.assert(pageRef!=null);
    	
    	String filterPage = controller.getFilterEditPage(true);
    	System.assert(filterPage!=null);
    	
    	pageRef = controller.backButtonClick();
    	System.assert(pageRef!=null);

    	controller.isFromSSSetup = CSM_Constants.GRID_ATTR_TRUE;
    	pageRef = controller.backButtonClick();
    	System.assert(pageRef!=null);
    	
    	Test.stopTest();
	}
}