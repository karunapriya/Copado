@isTest
public with sharing class CSM_FocusCategoriesControllerTest
{
   	static User adminUser;
	static testMethod void init() {
			CSM_TestUtility.setup();	
	}
	static testMethod void cloneFocusCategoryGroup() {
		 CSM_TestUtility.addLicense();
    	 CSM_TestUtility.addCSMAdmin();
    	 adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
         System.RunAs(adminUser) { 
			init();
			Test.startTest();
			CSM_FocusCategoriesController FocusCategoriesController = new CSM_FocusCategoriesController();
			CSM_Focus_Category_Group__c FocusCategoryGroup =[Select Id from CSM_Focus_Category_Group__c limit 1];
			system.assert(FocusCategoryGroup.Id != null);
		//	FocusCategoriesController.focusCategoryId = FocusCategoryGroup.Id;
			//FocusCategoriesController.cloneFocusCategoryGroup();
			Test.stopTest();
         }
	}
	
	static testMethod void testFocusCategory() {
		
		init();		
        Test.startTest();	
    	Test.setCurrentPage(Page.CSM_FocusCategories);
    	CSM_FocusCategoriesController controller = new CSM_FocusCategoriesController();
    	List<CSM_FocusCategoryGroupWrapper> wrapperList = controller.getFocusCategoryGroupList();
    	System.assert(wrapperList.size() > 0);
    	
    	controller.focusCategoryGroupUniqueId = wrapperList[0].UniqueId;
    	System.assertNotEquals(null, controller.editFocusCategoryGroup());
    	
    	controller.focusCategoryGroupName = 'Test new Category Group Name';
    	controller.focusCategoryGroupType = CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_MAIN;
    	System.assertEquals(null, controller.createNewFocusCategoryGroup());
    	
    	System.assert(controller.getFocusCategoryGroups().size() > 0);
    	
    	System.assert(controller.getFocusCategoryGroupTypes().size() > 0);    
    	
    	PageReference pageRef = controller.saveFocusCategories();
    	System.assert(pageRef==null);	
    	
    	pageRef = controller.CancelFocusCategories();
    	System.assert(pageRef!=null);
    	
    	controller.focusCategoryGroupName = 'Test Focus Category Group Display Name 1';
    	controller.focusCategoryGroupType = CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_TILES;
    	System.assertEquals(null, controller.createNewFocusCategoryGroup());
    	
    	Test.stopTest();
	}
	
    static testMethod void Test_deleteFocusCategoryGroup() {
       	
       	CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
   	    fcv.CSM_Display_Name__c = 'TestFCV1';       	
       	insert fcv;
       	CSM_Focus_Category_Group__c fcg = new CSM_Focus_Category_Group__c();
       	fcg.CSM_GROUP_TYPE__c = 'Main';
       	fcg.CSM_Display_Name__c = 'TestGroup1';
       	fcg.CSM_Order__c = 1;       	
   	    insert fcg;

       	CSM_Focus_Category_Group__c fcg1 = new CSM_Focus_Category_Group__c();
       	fcg1.CSM_GROUP_TYPE__c = 'Tiles';
       	fcg1.CSM_Display_Name__c = 'TestGroup2';
       	fcg1.CSM_Order__c = 2;       	
   	    insert fcg1;


       	CSM_Focus_Category_Column__c fcc = new CSM_Focus_Category_Column__c(); 
   	    fcc.CSM_Display_Name__c = 'TestCol1';
       	fcc.CSM_Focus_Category_Group__c = fcg.Id;
       	insert fcc;
       	
       	CSM_Focus_Category_Column__c fcc1 = new CSM_Focus_Category_Column__c(); 
   	    fcc1.CSM_Display_Name__c = 'TestCol1';
       	fcc1.CSM_Focus_Category_Group__c = fcg1.Id;
       	insert fcc1;
       	
       	
       	CSM_Focus_Category__c fc = new CSM_Focus_Category__c();
       	fc.CSM_Focus_Category_Column__c = fcc.Id;
       	fc.CSM_Focus_Category_View__c = fcv.Id; 
       	insert fc;

       	CSM_Focus_Category__c fc1 = new CSM_Focus_Category__c();
       	fc1.CSM_Focus_Category_Column__c = fcc1.Id;
       	fc1.CSM_Focus_Category_View__c = fcv.Id; 
       	insert fc1;

       	Test.startTest();
    	//PageReference pageRefVF = Page.CSM_FocusCategoryViewList;
    	//Test.setCurrentPageReference(pageRefVF);
    	//System.currentPageReference().getParameters().put('serviceContractIds', scIdParam);
    	CSM_FocusCategoriesController controller = new CSM_FocusCategoriesController();
    	controller.focusCategoryId = fcg.Id;
    	
		controller.cloneFocusCategoryGroup();
    	controller.deleteFocusCategoryGroup();
    	List<CSM_Focus_Category_Group__c> fcgdel = [select Id from CSM_Focus_Category_Group__c where Id =: fcg.Id]; 
    	system.assertEquals(fcgdel.size(), 0);
    	Test.stopTest();

    }
	
	
}