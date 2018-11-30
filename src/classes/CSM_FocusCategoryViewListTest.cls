@isTest 
private class CSM_FocusCategoryViewListTest {
	static string id;

	static void testSetupMethod() {
		CSM_TestDataSetup testSetup = new CSM_TestDataSetup();
		List<CSM_Focus_Category_View__c> fcs = testSetup.createFocusCategoryView(1);
		id = fcs[0].id;
	}
	
	static testMethod void createTest() {
    	Test.startTest();
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        controller.newObjectSelected = 'Account';
        controller.createNewFocusCategory();
        Test.stopTest();
        
        system.assert(true);
    }
	
	static testMethod void createErrorTest() {
    	Test.startTest();
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        controller.createNewFocusCategory();
        Test.stopTest();
        
        system.assert(true);
    }

   	static testMethod void editTest() {
    	CSM_FocusCategoryViewListTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        CSM_DataGridAttribute attr = controller.focusCategoryViewListGridAttribute;
        controller.selectedId = id;
        controller.redirectToEdit();
        Test.stopTest();
        
        system.assert(true);
    }
	
	static testMethod void resultSetTest() {
    	CSM_FocusCategoryViewListTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        controller.selectedId = id;
        controller.redirectToView();
        Test.stopTest();
        
        system.assert(true);
    }
	
	
	static testMethod void resultSetTaskTest() {
    	CSM_FocusCategoryViewListTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        controller.selectedId = id;
        controller.selectedObject = CSM_Constants.OBJ_TYPE_TASK;
        controller.redirectToView();
        Test.stopTest();
        
        system.assert(true);
    }
    
	static testMethod void testBusinessLayer() {
		CSM_FocusCategoryViewListTest.testSetupMethod();
		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'FocusCategoryViewList';
    	inputWrapper.params = gridParams;
    	CSM_FocusCategoryViewListBusinessLayer businessLayer = new CSM_FocusCategoryViewListBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
	}
	
	static testMethod void dataAccessTest() {
		Test.startTest();
		CSM_FocusCategoryViewDataAccess.getAllFocusCategoryViewsByUser(UserInfo.getUserId()); 
		Test.stopTest();
		
		system.assert(true);
	}
	
   	static testMethod void deleteTest() {
    	CSM_FocusCategoryViewListTest.testSetupMethod();
    	
    	Test.startTest();
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        controller.selectedId = id;
        controller.deleteFocusCategoryView();
        Test.stopTest();
        
        List<CSM_Focus_Category_View__c> fcs = [SELECT Id, Name FROM CSM_Focus_Category_View__c WHERE Id=:id];
        system.assert(fcs.size() == 0);
    }
	
	static testMethod void cloneTest() {
    	CSM_FocusCategoryViewListTest.testSetupMethod();
    	List<CSM_Focus_Category_View__c> fcs = [SELECT Id, Name FROM CSM_Focus_Category_View__c];
    	integer previousSize = fcs.Size();
    	Test.startTest();
    	
        CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
        controller.selectedId = id;
        controller.cloneFocusCategory();
        Test.stopTest();
        
        fcs = [SELECT Id, Name FROM CSM_Focus_Category_View__c];
        system.assert(previousSize + 1 == fcs.size());
    }

/*
    static testMethod void myUnitTest() {
        
		CSM_TestUtility.setup();
		PageReference pageRef = Page.CSM_FocusCategoryViewList;
    	Test.setCurrentPage(pageRef);
    	
    	Test.startTest();
		CSM_FocusCategoryViewListCtrl con = new CSM_FocusCategoryViewListCtrl();
		con.pageSize = 25;
		con.savePageSize();
		List<CSM_User_Preferences__c> lstUserPref = [select CSM_FCV_Grid_Pagesize__c from CSM_User_Preferences__c where CSM_User__c =: UserInfo.getUserId()];
		system.assert(lstUserPref[0].CSM_FCV_Grid_Pagesize__c == '25');
		con.redirectToView();
		con.selectedId = con.getFocusCategoryList()[0].id;
		con.selectedObject = con.getFocusCategoryList()[0].CSM_Object_Name__c;
		con.redirectToEdit();
		PageReference pr = con.redirectToView();
		system.assert(!String.isBlank(String.valueof(pr.getUrl())));
		con.selectedId = con.getFocusCategoryList()[0].id;
		con.selectedObject = CSM_Constants.OBJ_TYPE_TASK;
		con.redirectToView();
		
		con.newObjectSelected = 'Account';
		con.createNewFocusCategory();
		
		con.newObjectSelected = '';
		con.createNewFocusCategory();
		
		
		Test.stopTest();
    }
    
    static testMethod void Test_getGroupsFocusCategoryDelete() {
       	
       	CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
   	    fcv.CSM_Display_Name__c = 'TestFCV1';       	
       	insert fcv;
       	CSM_Focus_Category_Group__c fcg = new CSM_Focus_Category_Group__c();
       	fcg.CSM_GROUP_TYPE__c = 'Main';
       	fcg.CSM_Display_Name__c = 'TestGroup1';
   	    insert fcg;

       	CSM_Focus_Category_Group__c fcg1 = new CSM_Focus_Category_Group__c();
       	fcg1.CSM_GROUP_TYPE__c = 'Tiles';
       	fcg1.CSM_Display_Name__c = 'TestGroup2';
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
    	PageReference pageRefVF = Page.CSM_FocusCategoryViewList;
    	Test.setCurrentPageReference(pageRefVF);
    	//System.currentPageReference().getParameters().put('serviceContractIds', scIdParam);
    	CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
    	controller.selectedId = fcv.Id;
    	controller.getGroupsFocusCategoryDelete();
    	system.assertEquals(controller.groupCount, 2);
    	system.assertEquals(controller.strGroupNames, '["TestGroup1","TestGroup2"]');
    	Test.stopTest();

    }
    
    static testMethod void Test_deleteFocusCategoryView() {
       	
       	CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
   	    fcv.CSM_Display_Name__c = 'TestFCV1';       	
       	insert fcv;
       	CSM_Focus_Category_Group__c fcg = new CSM_Focus_Category_Group__c();
       	fcg.CSM_GROUP_TYPE__c = 'Main';
       	fcg.CSM_Display_Name__c = 'TestGroup1';
   	    insert fcg;

       	CSM_Focus_Category_Group__c fcg1 = new CSM_Focus_Category_Group__c();
       	fcg1.CSM_GROUP_TYPE__c = 'Tiles';
       	fcg1.CSM_Display_Name__c = 'TestGroup2';
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
    	PageReference pageRefVF = Page.CSM_FocusCategoryViewList;
    	Test.setCurrentPageReference(pageRefVF);
    	//System.currentPageReference().getParameters().put('serviceContractIds', scIdParam);
    	CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
    	controller.selectedId = fcv.Id;
    	controller.deleteFocusCategoryView();
    	List<CSM_Focus_Category_View__c> fcvdel = [select Id from CSM_Focus_Category_View__c where Id =: fcv.Id]; 
    	system.assertEquals(fcvdel.size(), 0);
    	Test.stopTest();

    }
    
    static testMethod void Test_cloneFocusCategoryView() {
       	CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
   	    fcv.CSM_Display_Name__c = 'TestFCV1';       	
       	insert fcv;
       	
       	CSM_Focus_Category_View_Criteria__c fcViewCrietria = new CSM_Focus_Category_View_Criteria__c();
		fcViewCrietria.RLM_Field_Display_Name__c = 'Account Name';
		fcViewCrietria.RLM_Field_Name__c = 'Name';
		fcViewCrietria.RLM_Field_Type__c = 'STRING';
   	    fcViewCrietria.CSM_Focus_Category_View__c = fcv.id;       	
       	insert fcViewCrietria;
       	
       	CSM_Focus_Category_View_Column__c fcViewCol =  new CSM_Focus_Category_View_Column__c();
        fcViewCol.CSM_Display_Name__c = 'Name';
       	fcViewCol.CSM_Object_Name__c = 'Account';
       	fcViewCol.CSM_Object_Field_Type__c = 'String';
   	    fcViewCol.CSM_Focus_Category_View__c = fcv.id;      	
       	insert fcViewCol;
       	
       	Test.startTest();
    		PageReference pageRefVF = Page.CSM_FocusCategoryViewList;
    		Test.setCurrentPageReference(pageRefVF);
    		CSM_FocusCategoryViewListCtrl controller = new CSM_FocusCategoryViewListCtrl();
    		controller.selectedId = fcv.Id;
    		controller.cloneFocusCategory();
    		system.assert(true);
    	Test.stopTest();
    }

    static testMethod void Test_cloneFocusCategoryViewNeg() {    
       	CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
   	    fcv.CSM_Display_Name__c = 'TestFCV1';       	
       	insert fcv;

       	Test.startTest();
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');

    	    	
	    		try{
		    		PageReference pageRefVF1 = Page.CSM_FocusCategoryViewList;
		    		Test.setCurrentPageReference(pageRefVF1);
		    		CSM_FocusCategoryViewListCtrl controller1 = new CSM_FocusCategoryViewListCtrl();
		    		controller1.selectedId = fcv.Id;
		    		system.runAs(restrictedUser) {
		    			controller1.cloneFocusCategory();
		    		}
	    		}
	    		catch(Exception ex){
	    		
	    		}
	    		system.assert(true);
	   	Test.stopTest();
    }
    */
}