@isTest
public with sharing class CSM_FocusColumnAndCategoryControllerTest
{

	
	static testMethod void testFocusColumnAndCategory() {
		
		CSM_TestUtility.setup();
        Test.startTest();	
       
    	PageReference focusColumnAndCategoryPage = Page.CSM_FocusColumnAndCategory;
        Test.setCurrentPage(focusColumnAndCategoryPage);
    	ApexPages.currentPage().getParameters().put(CSM_Constants.OBJ_FCG_GROUPID, CSM_TestUtility.focusCategoryGroup.Id);
    	CSM_FocusColumnAndCategoryController controller = new CSM_FocusColumnAndCategoryController();
    	System.assertNotEquals(null, controller.hasCSMAccess);
    	
    	List<CSM_FocusCategoryColumnWrapper> wrapperList = controller.getFocusCategoryColumnList();
    	System.assert(!wrapperList.isEmpty());
    	
    	controller.focusCategoryObjectType = 'Account';
		controller.focusCategoryColumnName = 'New Category Column A';
    	controller.createNewFocusCategoryColumn();
    	System.assert(controller.focusCategoryColumnName == '');

		controller.focusCategoryColumnName = 'New Column ZZZ';
		controller.createNewFocusCategoryColumn();
		System.assert(controller.focusCategoryColumnName == '');

    	controller.saveFocusCategories();

		controller.focusCategoryColumnName = 'New Column ZZZ-1';
		controller.createNewFocusCategoryColumn();
		System.assert(controller.focusCategoryColumnName == '');

		controller.focusCategoryColumnName = 'New Column ZZZ-2';
		controller.createNewFocusCategoryColumn();
		System.assert(controller.focusCategoryColumnName != '');
		controller.saveFocusCategories();
		
		controller.focusCategoryColumnUniqueId = controller.getFocusCategoryColumnList()[0].UniqueId;
    	controller.editFocusCategoryColumn(); 
    	System.assert(controller.focusCategoryColumnId == CSM_TestUtility.focusCategoryColumn.Id);
    	
		
		List<CSM_FocusCategoryWrapper> categoryWrapperList = controller.getFocusCategoryList();
		controller.updateListViews();
		
		controller.createNewFocusCategory();
		controller.focusCategoryObjectType = CSM_Constants.OBJ_TYPE_ACCOUNT;
		List<SelectOption> options = controller.fcDA.setCon(controller.focusCategoryObjectType);
		System.assert(!options.isEmpty());
		
		controller.focusCategoryToAdd = options[0].getValue();
		controller.addFocusCategory();
		controller.saveFocusCategories();
		
		controller.categoryViewId = options[0].getValue();
		PageReference pageRef = controller.editFocusCategory();
		system.assert(pageRef!=null);
    	
    	controller.focusCategoryObjectType = 'Account';
    	controller.focusCategoryToAdd = '123456789012345678';
    	pageRef = controller.addFocusCategory();
    	system.assert(pageRef==null);
    	
    	String val = CSM_TestUtility.focusCategoryGroup.Id + '_' +CSM_TestUtility.focusCategoryColumn.Id+'_'+controller.focusCategoryObjectType + '_123';
    	ApexPages.currentPage().getParameters().put(CSM_Constants.OBJ_FCG_GROUPID, val);
    	controller = new CSM_FocusColumnAndCategoryController();
    	System.assertNotEquals(null, controller.hasCSMAccess);
    	
        controller.tabCategory='Test';
    	pageRef = controller.cancelFocusCategories();
		system.assert(pageRef!=null);
    	
    	controller.fccDA.populateWrapperClass();
    	Map<String, CSM_FocusCategoryColumnWrapper> fccActiveMap = new Map<String, CSM_FocusCategoryColumnWrapper>();
    	Set<String> groupIdSet = new Set<String>();
    	groupIdSet.add(CSM_TestUtility.focusCategoryGroup.Id);
    	
	 	controller.fcDA.populateWrapperClass();
	 	System.assert(controller.fcDA.focusCategoryMap!=null && !controller.fcDA.focusCategoryMap.isEmpty());
	 	
	 	
	 	controller.fcDA.populateWrapperClass(null, CSM_TestUtility.focusCategory.Id, null);
	 	System.assert(controller.fcDA.focusCategoryMap!=null && !controller.fcDA.focusCategoryMap.isEmpty());
		
		String fcId = controller.fcDA.saveAndRetrieveId(controller.fcDA.focusCategoryList[0].UniqueId);
		System.assert(fcId!=null);

		//controller.fcDA.focusCategoryList[0].CategoryId = null;

		fcId = controller.fcDA.saveAndRetrieveId(controller.fcDA.focusCategoryList[0].UniqueId);
		System.assert(fcId!=null);
		
    	wrapperList = controller.getFocusCategoryColumnList();
    	System.assert(!wrapperList.isEmpty());

		controller.focusCategoryColumnName = 'New Column XYZ-2';
		controller.createNewFocusCategoryColumn();
		System.assert(controller.focusCategoryColumnName != '');
		controller.saveFocusCategories();		
		
		controller.createNewFocusCategory();
		controller.focusCategoryObjectType = CSM_Constants.OBJ_TYPE_ACCOUNT;
		options = controller.fcDA.setCon(controller.focusCategoryObjectType);
		
		controller.focusCategoryToAdd = options[0].getValue();
		controller.addFocusCategory();
		controller.saveFocusCategories();
		

		controller.focusCategoryColumnUniqueId = controller.getFocusCategoryColumnList()[0].UniqueId;
		CSM_FocusCategoryColumnWrapper fcCW = controller.fccDA.saveAndRetrieveId(controller.focusCategoryColumnUniqueId);
		controller.focusCategoryColumnId = fcCW.ColumnId;
        
		controller.categoryId = controller.fcDA.focusCategoryList[0].CategoryId;
        
		controller.categoryDisplayName='Test';
		controller.categoryUniqueId=controller.getFocusCategoryColumnList()[0].UniqueId;
		controller.deleteFocusCategory();		
		
		controller.focusCategoryColumnUniqueId = controller.getFocusCategoryColumnList()[0].UniqueId;
		    	
    	pageRef = controller.deleteFocusCategoryColumn();		
    	
    	CSM_FocusCategoryWrapper focusCatWrapper = new CSM_FocusCategoryWrapper();
    	focusCatWrapper.CategoryFieldType = 'DATE';
    	focusCatWrapper.CategoryCount = 1;
    	focusCatWrapper.ListSObject = new List<Opportunity>();
    	focusCatWrapper.CriteriaObjList = new List<CSM_Focus_Category_View_Criteria__c>();
    	focusCatWrapper.CriteriaJSON = '';
    	
    	Set<String> columnKeySet = new Set<String>{'Id','Name','OwnerId'};
    	controller.fcDA.userPreferences = new CSM_UserPreferencesFilterWrapper();
		controller.fcDA.populateWrapperClass(CSM_TestUtility.focusCategoryViewColumn.id, CSM_TestUtility.focusCategory.Id, columnKeySet);
		
		Test.stopTest();
	}
    static testMethod void myTest()
    {
        CSM_FocusColumnAndCategoryController controller3 = new CSM_FocusColumnAndCategoryController();
        List<SelectOption> fcViewList = new List<SelectOption>();
        system.assertEquals(null, controller3.deleteFocusCategoryColumn());
        system.assertEquals(null, controller3.updateListViews());
        system.assertEquals(null, controller3.createNewFocusCategoryColumn());
        system.assertEquals(null, controller3.createNewFocusCategory());
        system.assertEquals(null, controller3.editFocusCategory());
        system.assertEquals(null, controller3.deleteFocusCategory());
        fcViewList=controller3.getFocusCategoryViewList();
        system.assertEquals(0, fcViewList.size());
        system.assertEquals(null, controller3.saveFocusCategories());
        system.assertEquals(null, controller3.editFocusCategoryColumn());
        system.assertNotEquals(null,controller3.cancelFocusCategories()) ; 
        
    }
    
    
}