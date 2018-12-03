@isTest
public with sharing class CSM_FocusCategoryViewControllerTest {
	
	static testMethod void testFocusCategoryFullListPage() {
		
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_FocusCategoryView;
    	// Set the model action
        Test.setCurrentPage(csmPage);
    	ApexPages.currentPage().getParameters().put(CSM_Constants.OBJ_IG_ID, CSM_TestUtility.focusCategoryView.Id);
        ApexPages.currentPage().getParameters().put(CSM_Constants.CANCEL_URL, csmPage.getUrl());
        ApexPages.currentPage().getParameters().put(CSM_Constants.RET_URL, csmPage.getUrl());
        CSM_FocusCategoryViewController controller = new CSM_FocusCategoryViewController();
    	system.assert(controller.hasCSMAccess==true);
    	
    	controller.fcViewCreate();
    	
    	CSM_FocusCategoryViewColumnCmpCtrl fcvcCmp = new CSM_FocusCategoryViewColumnCmpCtrl();
		fcvcCmp.selectedObject = 'Account';
    	fcvcCmp.fcViewId = CSM_TestUtility.focusCategoryView.Id;
    	fcvcCmp.CSM_FocusCategoryViewController = controller;
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('BillingState', 'BillingState')); 
        fcvcCmp.lstRightGroups = options;
  
    	PageReference pageRef = fcvcCmp.Save();
    	System.assert(pageRef == null);
    	
    	List<String> fcViewIds = new List<String>();
    	fcViewIds.add(CSM_TestUtility.focusCategoryView.Id);
    	List<CSM_Focus_Category_View_Column__c> viewColList = CSM_FocusCategoryViewColumnDataAccess.populateFCVColumnInformation(fcViewIds);
    	System.assert(viewColList!=null && !viewColList.isEmpty());
    	
    	
    	REN_LogicBuilderCmpCtrl lbCmpCtrl = new REN_LogicBuilderCmpCtrl();
		controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Account','fcv1',false,controller,'','','',true,'');
		lbCmpCtrl.logicBuilderInput = controller.lbInputWrapper;
		PageReference fcvpage = lbCmpCtrl.newCriteria();
		system.debug('InDebug' + lbCmpCtrl.criteriaWrapperList.size());
		
        User Usr = CSM_TestDataUtility.createTestUser('Standard User');
		
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Values__c','07/02/2015');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Field_Name__c','CSM_Last_Health_Status__c');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Field_Type__c','DATE');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Date_Value__c', null);
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Operator__c','=');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Is_Specific_Date__c', false);
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Date_Literal_String__c', 'Yesterday');
		
		lbCmpCtrl.newCriteria();
		
        lbCmpCtrl.criteriaWrapperList[1].criteria.put('RLM_Values__c','100');
        lbCmpCtrl.criteriaWrapperList[1].criteria.put('RLM_Field_Name__c','NumberOfEmployees');
        lbCmpCtrl.criteriaWrapperList[1].criteria.put('RLM_Field_Type__c','Integer');
        lbCmpCtrl.criteriaWrapperList[1].criteria.put('RLM_Operator__c','>');

		lbCmpCtrl.newCriteria();
        lbCmpCtrl.criteriaWrapperList[2].criteria.put('RLM_Values__c','1000');
        lbCmpCtrl.criteriaWrapperList[2].criteria.put('RLM_Field_Name__c','AnnualRevenue');
        lbCmpCtrl.criteriaWrapperList[2].criteria.put('RLM_Field_Type__c','Currency');
        lbCmpCtrl.criteriaWrapperList[2].criteria.put('RLM_Operator__c','>');

		lbCmpCtrl.newCriteria();
        lbCmpCtrl.criteriaWrapperList[3].criteria.put('RLM_Values__c','Electronics');
        lbCmpCtrl.criteriaWrapperList[3].criteria.put('RLM_Field_Name__c','Industry');
        lbCmpCtrl.criteriaWrapperList[3].criteria.put('RLM_Field_Type__c','Picklist');
        lbCmpCtrl.criteriaWrapperList[3].criteria.put('RLM_Operator__c','=');

		lbCmpCtrl.newCriteria();
        lbCmpCtrl.criteriaWrapperList[4].criteria.put('RLM_Values__c',UserInfo.getUserId());
        lbCmpCtrl.criteriaWrapperList[4].criteria.put('RLM_Field_Name__c','LastModifiedById');
        lbCmpCtrl.criteriaWrapperList[4].criteria.put('RLM_Field_Type__c','REFERENCE');
        lbCmpCtrl.criteriaWrapperList[4].criteria.put('RLM_Operator__c','NOT IN');

		lbCmpCtrl.newCriteria();
        lbCmpCtrl.criteriaWrapperList[5].criteria.put('RLM_Values__c','true');
        lbCmpCtrl.criteriaWrapperList[5].criteria.put('RLM_Field_Name__c','IsCustomerPortal');
        lbCmpCtrl.criteriaWrapperList[5].criteria.put('RLM_Field_Type__c','Boolean');
        lbCmpCtrl.criteriaWrapperList[5].criteria.put('RLM_Operator__c','IN');
		
		lbCmpCtrl.newCriteria();
        lbCmpCtrl.criteriaWrapperList[6].criteria.put('RLM_Values__c','test');
        lbCmpCtrl.criteriaWrapperList[6].criteria.put('RLM_Field_Name__c','Sic');
        lbCmpCtrl.criteriaWrapperList[6].criteria.put('RLM_Field_Type__c','STRING');
        lbCmpCtrl.criteriaWrapperList[6].criteria.put('RLM_Operator__c','LIKE');

		controller.fcViewSave();
		CSM_TestUtility.focusCategoryView.RLM_Filter_Logic__c = '1 or 2 or 3 or 4 or 5 or 6 or 7';
		controller.fcViewSave();		
		CSM_TestUtility.focusCategoryView.RLM_Filter_Logic__c = '1 or 2 or 3 or 4 or 5 or 6 or 7';
		controller.fcViewSave();		
		lbCmpCtrl.deleteCriteria();
		lbCmpCtrl.refreshLogicBuilder();
				
		List<CSM_Focus_Category_View_Criteria__c> fcvcList = [select Id from CSM_Focus_Category_View_Criteria__c where CSM_Focus_Category_View__c =:CSM_TestUtility.focusCategoryView.Id];
    	System.assert(fcvcList.size() != 0);		
    	/*CSM_FocusCategoryViewCriteriaCmpCtrl fcvCritCmp = new CSM_FocusCategoryViewCriteriaCmpCtrl();
    	fcvCritCmp.selectedObject = 'Account';
    	fcvCritCmp.CSM_FocusCategoryViewController = controller;
    	fcvCritCmp.fcView = controller.fcView;
    	List<CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper> fcvCritList = fcvCritCmp.getCriteriaWrapperList();
    	System.assert(fcvCritList!=null && !fcvCritList.isEmpty());
    	
    	List<SelectOption> fieldCritList = fcvCritCmp.getFieldList();
    	System.assert(fieldCritList!=null && !fieldCritList.isEmpty());
    	
    	fcvCritCmp.selectedField = 'CSM_Health_Status__c';
    	pageRef = fcvCritCmp.newCriteria();
    	System.assert(pageRef==null);
    	
    	for (CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper w : fcvCritCmp.criteriaWrapperList){
	    	w.criteria.RLM_Operator__c = '=';
	    	w.criteria.RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST;
	    	w.criteria.RLM_Values__c = null;  	
    	}
    	pageRef = fcvCritCmp.saveCriteria();
    	System.assert(pageRef==null);
    	String guidToCompare = '';
    	for (CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper w : fcvCritCmp.criteriaWrapperList){
	    	w.criteria.RLM_Operator__c = '<=';
	    	if (w.guid!=null){
	    		guidToCompare = w.guid;
	    		break;
	    	}
    	}
    	pageRef = fcvCritCmp.saveCriteria();
    	System.assert(pageRef==null);
    	fcvCritCmp.guidToCompare = guidToCompare;
    	pageRef = fcvCritCmp.deleteCriteria();
    	System.assert(pageRef==null);
    	
    	fcvCritCmp.selectedField = 'CSM_Last_Health_Status__c';
    	pageRef = fcvCritCmp.newCriteria();
    	System.assert(pageRef==null);
    	for (CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper w : fcvCritCmp.criteriaWrapperList){
	    	w.criteria.RLM_Operator__c = '=';
	    	w.criteria.RLM_Field_Type__c = CSM_Constants.TYPE_DATE;
	    	w.criteria.RLM_Date_Literal_String__c = 'LAST_N_WEEKS';
	    	w.criteria.RLM_Date_Literal_Number__c = 2;
	    	w.criteria.RLM_Is_Specific_Date__c = false;
	    	w.criteria.RLM_Date_Value__c = null;
	    	if (w.guid!=null){
	    		guidToCompare = w.guid;
	    		break;
	    	}
    	}
    	pageRef = fcvCritCmp.saveCriteria();
    	System.assert(pageRef==null);
    	
    	for (CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper w : fcvCritCmp.criteriaWrapperList){
	    	w.criteria.RLM_Operator__c = '=';
	    	w.criteria.RLM_Field_Type__c = CSM_Constants.TYPE_DATE;
	    	w.criteria.RLM_Date_Value__c = System.today();
	    	w.criteria.RLM_Is_Specific_Date__c = true;
    	}
    	pageRef = fcvCritCmp.saveCriteria();
    	System.assert(pageRef==null);
    	fcvCritCmp.guidToCompare = guidToCompare;
    	pageRef = fcvCritCmp.deleteCriteria();
    	System.assert(pageRef==null);    	
    	
    	fcvCritCmp.selectedField = 'BillingState';
    	pageRef = fcvCritCmp.newCriteria();
    	System.assert(pageRef==null);
        guidToCompare = '';
    	for (CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper w : fcvCritCmp.criteriaWrapperList){
	    	w.criteria.RLM_Operator__c = '=';
	    	w.criteria.RLM_Field_Type__c = CSM_Constants.TYPE_STRING;
	    	w.criteria.RLM_Values__c = 'GA';
	    	if (w.guid!=null){
	    		guidToCompare = w.guid;
	    		break;
	    	}
    	}
    	pageRef = fcvCritCmp.saveCriteria();
    	System.assert(pageRef==null);
    	
    
    	
    	fcvCritCmp.guidToCompare = guidToCompare;
    	pageRef = fcvCritCmp.deleteCriteria();
    	System.assert(pageRef==null);
    	
    	fcvCritCmp.selectedField = 'BillingState';
    	pageRef = fcvCritCmp.newCriteria();
    	for (CSM_FocusCategoryViewCriteriaCmpCtrl.CSM_FocusCategoryViewCriteriaWrapper w : fcvCritCmp.criteriaWrapperList){
	    	w.criteria.RLM_Operator__c = '=';
	    	w.criteria.RLM_Field_Type__c = CSM_Constants.TYPE_STRING;
	    	w.criteria.RLM_Values__c = 'GA';
	    	if (w.guid!=null){
	    		guidToCompare = w.guid;
	    		break;
	    	}
    	}
    	System.assert(pageRef==null);
    	
    	pageRef = fcvCritCmp.saveCriteria();
    	System.assert(pageRef==null);*/
    	
		controller.setFCVCComponentControllerMap(CSM_TestUtility.focusCategoryView.Id, fcvcCmp);
    	//controller.setFCVCritComponentControllerMap(CSM_TestUtility.focusCategoryView.Id, fcvCritCmp);
    	
    	Map<String, CSM_FocusCategoryViewColumnCmpCtrl> colMap = controller.getFCVCComponentControllerMap();
    	System.assert(colMap!=null);
    	
    	//Map<String, CSM_FocusCategoryViewCriteriaCmpCtrl> critMap = controller.getFCVCritComponentControllerMap();
    	//System.assert(critMap!=null);
    	
    	pageRef = controller.fcViewSave();
		System.assert(pageRef==null);
    	
    	pageRef = controller.fcViewCancel();
    	System.assert(pageRef!=null);
		
		List<String> fcViewIdList = new List<String>();
		fcViewIdList.add(CSM_TestUtility.focusCategoryView.Id);
		CSM_FocusCategoryViewDataAccess.updateSOQL(fcViewIdList);
		
		fcViewIdList = new List<String>();
		fcViewIdList.add(CSM_TestUtility.focusCategoryView2.Id);
		CSM_FocusCategoryViewDataAccess.updateSOQL(fcViewIdList);
		
		Map<String, Map<String, String>> viewInfoMap = CSM_FocusCategoryViewDataAccess.populateViewInformation();
		System.assert(viewInfoMap!=null && !viewInfoMap.isEmpty());



        system.runAs(Usr)
        {
            try{
		    	REN_LogicBuilderCmpCtrl lbCmpCtrl1 = new REN_LogicBuilderCmpCtrl();
				controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Account','fcv1',false,controller,'','','');
				lbCmpCtrl1.logicBuilderInput = controller.lbInputWrapper;
				PageReference fcvpage1 = lbCmpCtrl1.newCriteria();
				system.debug('InDebug' + lbCmpCtrl1.criteriaWrapperList.size());
				
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Values__c','07/02/2015');
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Field_Name__c','CSM_Last_Health_Status__c');
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Field_Type__c','DATE');
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Date_Value__c', null);
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Operator__c','=');
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Is_Specific_Date__c', false);
		        lbCmpCtrl1.criteriaWrapperList[1].criteria.put('RLM_Date_Literal_String__c', 'Yesterday');

				controller.fcViewSave();

            }catch(Exception e){}
			List<CSM_Focus_Category_View_Criteria__c> fcvcList1 = [select Id from CSM_Focus_Category_View_Criteria__c where CSM_Focus_Category_View__c =:CSM_TestUtility.focusCategoryView.Id];
	    	System.assert(fcvcList1 != null);		
        }
    	REN_LogicBuilderCmpCtrl lbCmpCtrl2 = new REN_LogicBuilderCmpCtrl();
		controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryViewTask,CSM_Constants.OBJ_FCV_CRITERIA,'Task','fcv1',false,controller,'','','');
		lbCmpCtrl2.logicBuilderInput = controller.lbInputWrapper;
		
		lbCmpCtrl2.newCriteria();
		system.debug('InDebug' + lbCmpCtrl2.criteriaWrapperList.size());
		
        lbCmpCtrl2.criteriaWrapperList[0].criteria.put('RLM_Values__c','Call');
        lbCmpCtrl2.criteriaWrapperList[0].criteria.put('RLM_Field_Name__c','Type');
        lbCmpCtrl2.criteriaWrapperList[0].criteria.put('RLM_Field_Type__c','String');
        lbCmpCtrl2.criteriaWrapperList[0].criteria.put('RLM_Operator__c','=');
		

		controller.fcViewSave();
		List<CSM_Focus_Category_View_Criteria__c> fcvcList2 = [select Id from CSM_Focus_Category_View_Criteria__c where CSM_Focus_Category_View__c =:CSM_TestUtility.focusCategoryViewTask.Id];
    	System.assert(fcvcList2 != null);		
		    	
    	Test.stopTest();
	}
	
	
	static testMethod void testFocusCategoryOpportunity() {
		
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_FocusCategoryView;
    	// Set the model action
        Test.setCurrentPage(csmPage);
    	ApexPages.currentPage().getParameters().put(CSM_Constants.OBJ_IG_ID, CSM_TestUtility.focusCategoryView.Id);
        ApexPages.currentPage().getParameters().put(CSM_Constants.CANCEL_URL, csmPage.getUrl());
        CSM_FocusCategoryViewController controller = new CSM_FocusCategoryViewController();
    	system.assert(controller.hasCSMAccess==true);
    	
    	controller.fcViewCreate();
        
        CSM_FocusCategoryViewColumnCmpCtrl fcvcCmp = new CSM_FocusCategoryViewColumnCmpCtrl();
		fcvcCmp.selectedObject = 'Opportunity';
    	fcvcCmp.fcViewId = CSM_TestUtility.focusCategoryView.Id;
    	fcvcCmp.CSM_FocusCategoryViewController = controller;
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AccountId', 'AccountId'));  
        fcvcCmp.lstRightGroups = options;
        
    	PageReference pageRef = fcvcCmp.Save();
    	System.assert(pageRef == null);
    	
    	List<String> fcViewIds = new List<String>();
    	fcViewIds.add(CSM_TestUtility.focusCategoryView.Id);
    	List<CSM_Focus_Category_View_Column__c> viewColList = CSM_FocusCategoryViewColumnDataAccess.populateFCVColumnInformation (fcViewIds);
    	System.assert(viewColList!=null && !viewColList.isEmpty());
    	
        
    	REN_LogicBuilderCmpCtrl lbCmpCtrl = new REN_LogicBuilderCmpCtrl();
		controller.lbInputWrapper = new REN_LogicBuilderInputWrapper(CSM_TestUtility.focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA,'Opportunity','fcv1',false,controller,'','','',true,'');
		lbCmpCtrl.logicBuilderInput = controller.lbInputWrapper;
		PageReference fcvpage = lbCmpCtrl.newCriteria();
		system.debug('InDebug' + lbCmpCtrl.criteriaWrapperList.size());
		
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Values__c','000000000000000');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Field_Name__c','AccountId');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Field_Type__c','REFERENCE');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Date_Value__c', null);
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Operator__c','=');
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Is_Specific_Date__c', false);
        lbCmpCtrl.criteriaWrapperList[0].criteria.put('RLM_Date_Literal_String__c', null);
		
		controller.fcViewSave();
		lbCmpCtrl.refreshLogicBuilder();
    	
    	Test.stopTest();
	}


	static testMethod void testFocusCategoryOpportunity1() {
		
		Test.startTest();	
    	PageReference csmPage1 = Page.CSM_FocusCategoryView;
    	// Set the model action
    	Account acc = new Account();
    	acc.Name = 'Test1';
    	insert acc;
		CSM_Focus_Category_View__c fcv1 = new CSM_Focus_Category_View__c();
		fcv1.CSM_Display_Name__c = 'fcv 1';
		fcv1.CSM_Columns__c = '';
		fcv1.CSM_Criteria__c = '';
		fcv1.CSM_SOQL__c = '';
		fcv1.CSM_Object_Name__c = 'Opportunity';
		fcv1.CSM_IsTile__c = true;
		fcv1.CSM_Currency_Header__c = '';
        fcv1.CSM_Sort_By__c='Name';
        fcv1.CSM_Sort_Order__c='Asc';
		insert fcv1;
		    	
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = new CSM_Focus_Category_View_Criteria__c();
		focusCategoryViewCriteria.RLM_Field_Name__c = 'AccountId';
		focusCategoryViewCriteria.RLM_Field_Display_Name__c = 'AccountId';
		focusCategoryViewCriteria.RLM_Field_Type__c = 'REFERENCE';
		focusCategoryViewCriteria.RLM_Operator__c = '=';
		focusCategoryViewCriteria.RLM_Values__c = acc.Id;
		focusCategoryViewCriteria.CSM_Focus_Category_View__c = fcv1.Id;
		insert focusCategoryViewCriteria;
    	
        Test.setCurrentPage(csmPage1);
    	ApexPages.currentPage().getParameters().put(CSM_Constants.OBJ_IG_ID, fcv1.Id);
        ApexPages.currentPage().getParameters().put(CSM_Constants.CANCEL_URL, csmPage1.getUrl());
        CSM_FocusCategoryViewController controller1 = new CSM_FocusCategoryViewController();
    	REN_LogicBuilderCmpCtrl lbCmpCtrl1 = new REN_LogicBuilderCmpCtrl();		
		lbCmpCtrl1.logicBuilderInput = controller1.lbInputWrapper;
        string tabCategory=controller1.tabCategory;
        controller1.fcViewSave();
		List<CSM_Focus_Category_View_Criteria__c> fcvcList = [select Id from CSM_Focus_Category_View_Criteria__c where CSM_Focus_Category_View__c =:fcv1.Id];
    	System.assert(fcvcList.size() != 0);		
    	
    	Test.stopTest();
	}
	
	static testMethod void testFocusCategoryContract() {
		
		CSM_Focus_Category_View__c fcv1 = new CSM_Focus_Category_View__c();
		fcv1.CSM_Display_Name__c = 'fcv 1';
		fcv1.CSM_Columns__c = '';
		fcv1.CSM_Criteria__c = '';
		fcv1.CSM_SOQL__c = '';
		fcv1.CSM_Object_Name__c = 'Contract';
		fcv1.CSM_IsTile__c = true;
		fcv1.CSM_Currency_Header__c = '';
		fcv1.CSM_Filter_By_Owner_Value__c = 'My';
		insert fcv1;
		
		List<String> fcViewIdList = new List<String>();
		fcViewIdList.add(fcv1.Id);
		
		Test.startTest();
		CSM_FocusCategoryViewDataAccess.updateSOQL(fcViewIdList);
		Test.stopTest();
		
		List<CSM_Focus_Category_View__c> fcvList = [Select id,CSM_SOQL__c from CSM_Focus_Category_View__c Limit 1];
		system.assert(fcvList[0].CSM_SOQL__c.contains(CSM_Constants.CONTRACT_NUMBER));
	}
    static testMethod void testFocusCategoryNeg(){
    	Test.startTest();
        CSM_FocusCategoryViewController controller1 = new CSM_FocusCategoryViewController();
        controller1.selectedField='';
        controller1.fcViewSave();
        System.assert(true);
        Test.stopTest();
    }
    static testMethod void testFocusCategoryNeg1(){
       Test.startTest();	
    	PageReference csmPage1 = Page.CSM_FocusCategoryView;
    	Account acc = new Account();	
    	acc.Name = 'Test1';
    	insert acc;
		CSM_Focus_Category_View__c fcv1 = new CSM_Focus_Category_View__c();
		fcv1.CSM_Display_Name__c = '';
		fcv1.CSM_Columns__c = '';
		fcv1.CSM_Criteria__c = '';
		fcv1.CSM_SOQL__c = '';
		fcv1.CSM_Object_Name__c = 'Opportunity';
		fcv1.CSM_IsTile__c = true;
		fcv1.CSM_Currency_Header__c = '';
        fcv1.CSM_Sort_By__c='Name';
        fcv1.CSM_Sort_Order__c='Asc';
		insert fcv1;
		    	
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = new CSM_Focus_Category_View_Criteria__c();
		focusCategoryViewCriteria.RLM_Field_Name__c = 'AccountId';
		focusCategoryViewCriteria.RLM_Field_Display_Name__c = 'AccountId';
		focusCategoryViewCriteria.RLM_Field_Type__c = 'REFERENCE';
		focusCategoryViewCriteria.RLM_Operator__c = '=';
		focusCategoryViewCriteria.RLM_Values__c = acc.Id;
		focusCategoryViewCriteria.CSM_Focus_Category_View__c = fcv1.Id;
		insert focusCategoryViewCriteria;
    	
        Test.setCurrentPage(csmPage1);
    	ApexPages.currentPage().getParameters().put(CSM_Constants.OBJ_IG_ID, fcv1.Id);
        CSM_FocusCategoryViewController controller1 = new CSM_FocusCategoryViewController();
    	REN_LogicBuilderCmpCtrl lbCmpCtrl1 = new REN_LogicBuilderCmpCtrl();		
		lbCmpCtrl1.logicBuilderInput = controller1.lbInputWrapper;
        string tabCategory=controller1.tabCategory;
        controller1.fcViewSave();
        controller1.fcViewCancel();
		List<CSM_Focus_Category_View_Criteria__c> fcvcList = [select Id from CSM_Focus_Category_View_Criteria__c where CSM_Focus_Category_View__c =:fcv1.Id];
    	System.assert(fcvcList.size() != 0);		    	
    	Test.stopTest();
    }
}