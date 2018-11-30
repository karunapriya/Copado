@isTest
public with sharing class CSM_FocusCategoriesComponentCntrlTest {

	static testMethod void testCustomerSuccessPage() {
		
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_CustomerSuccessOverview;
        Test.setCurrentPage(csmPage);
    	CSM_CustomerSuccessOverviewController controller = new CSM_CustomerSuccessOverviewController();
    	system.assert(controller.hasCSMAccess==true);
    	
    	CSM_FocusCategoriesComponentController fcCmpController = new CSM_FocusCategoriesComponentController();
    	String delimitedFields = 'CSM_Overview_Carousel_Chart__c,CSM_Overview_FC_Group_Filter__c,CSM_Success_Plan_Actions_Filter__c,CSM_Success_Plan_Actions_Grid_Columns__c,CSM_Success_Plan_Activity_Grid_Columns__c,CSM_Success_Task_Filter__c,CSM_Success_Task_Grid_Columns__c,CSM_Hide_Overview_Charts__c,CSM_Hide_Inactive_Categories__c,CSM_Object_Field_Filter__c,CSM_Filter_Display_Name__c,CSM_Object_Filter__c,CSM_Object_Field_Filter_User__c,CSM_Object_Field_Filter_Value__c,CSM_Object_Field_Date_Value__c';
    	CSM_User_Preferences__c preferenceObj = CSM_UserPreferencesUtil.getUserPreferences(UserInfo.getUserId(), delimitedFields);
    	
    	fcCmpController.userPref = new CSM_UserPreferencesFilterWrapper();
    	
		fcCmpController.userPref.attrFieldName = preferenceObj.CSM_Object_Field_Filter__c;
		fcCmpController.userPref.attrFieldType = preferenceObj.CSM_Object_Field_Type__c;
		fcCmpController.userPref.attrFieldValue = preferenceObj.CSM_Object_Field_Filter_Value__c;
		fcCmpController.userPref.attrFieldUserId = preferenceObj.CSM_Object_Field_Filter_User__c;
		fcCmpController.userPref.attrFieldDateValue = preferenceObj.CSM_Object_Field_Date_Value__c;
		    	
		CSM_FocusCategoriesGroupDataAccess fcgDA = new CSM_FocusCategoriesGroupDataAccess();
		fcCmpController.groupColumnWrapperMap = new Map<String, List<CSM_FocusCategoryColumnWrapper>>();
    	 

		fcCmpController.focusCategoryGroups = fcgDA.getFocusCategoryGroups();
		
		for (CSM_FocusCategoryGroupWrapper gw : fcgDA.focusCategoryGroupActiveMap.values()){
			if (gw.GroupType == CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_TILES) {
				fcCmpController.tilesGroupId = gw.GroupId;
				
				fcCmpController.selectedTilesGroup();
				fcCmpController.groupColumnWrapperMap.put(fcCmpController.tilesGroupId, new List<CSM_FocusCategoryColumnWrapper>());
				fcCmpController.selectedTilesGroup();
			}
		}
		
		
		fcCmpController.focusCategoryGroup = fcCmpController.focusCategoryGroups[1].getValue();
		fcCmpController.focusCategoryGroupInitValue = fcCmpController.focusCategoryGroup;

    	//fcCmpController.focusCategoryGroup = CSM_TestUtility.focusCategoryGroup.Id;
    	
    	fcCmpController.focusCategoryColumnSize = 3;
    	fcCmpController.packageVersion = CSM_Util.getPackageVersion(); 
    	fcCmpController.scoutUrl = CSM_Util.getScoutAnalyticsUrl();
    	fcCmpController.taskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
    	//fcCmpController.riskReasonDismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
    	
    	PageReference pageRef = fcCmpController.selectedCategoryGroup();
    	System.assert(pageRef==null);
    	
    	fcCmpController.whatId = CSM_TestUtility.acct.Id;
    	pageRef = fcCmpController.redirectToAccountPlan();
    	System.assert(pageRef==null);
    	
    	//fcCmpController.deleteUnwantedViews();
    	
    	fcCmpController.taskId = CSM_TestUtility.tsk.Id;
    	pageRef = fcCmpController.setTaskInfo();
    	System.assert(pageRef==null);
    	
    	fcCmpController.followUpTask = true;
		pageRef = fcCmpController.completeDismissTask();
    	//System.assert(pageRef!=null);
    	
    	pageRef = fcCmpController.redirectToTask();
    	System.assert(pageRef==null);
    	
    	fcCmpController.resetTask();
    	pageRef = fcCmpController.newFocusCategory();
    	System.assert(pageRef==null);
    	
    	/*Boolean isSysAdmin = CSM_Util.isUserAnSystemAdmin();*/
    	//if(isSysAdmin) {
    		CSM_Focus_Category_Group__c fcg =[SELECT Id, OwnerId from CSM_Focus_Category_Group__c WHERE OwnerId =:UserInfo.getUserId() limit 1];
    		if (fcg !=null) {
    			//fcCmpController.fcGroup = fcg;
    			fcCmpController.focusCategoryGroup = fcg.Id;
    		}  
    	//} 
    	pageRef = fcCmpController.filterByOwner();
    	System.assert(pageRef==null);
    	
    	pageRef = fcCmpController.clearOwnerFilter();
    	System.assert(pageRef==null);
    	
    	pageRef = fcCmpController.editFocusCategoryGroup(); 
    	
    	fcCmpController.isFCActive = true;
    	pageRef = fcCmpController.toggleActiveFC();
    	System.assert(pageRef==null);
    	
    	fcCmpController.isFCActive = false;
    	pageRef = fcCmpController.toggleActiveFC();
    	System.assert(pageRef==null);
    	
    	pageRef = fcCmpController.editFocusCategory();
    	System.assert(pageRef==null);
    	
    	pageRef = fcCmpController.redirectToEdit();
    	System.assert(pageRef!=null);
    	
    	pageRef = fcCmpController.redirectById();
    	System.assert(pageRef==null);
    	
    	List<SelectOption> optListRecordTypes = fcCmpController.getRecordTypes();
		System.assert(optListRecordTypes != null);
          
        List<SelectOption> optListStatus = fcCmpController.getTaskStatus();
		System.assert(optListStatus != null);
    	
    	CSM_TestUtility tUtility = new CSM_TestUtility();
    	
    	CSM_FocusCategoriesDataAccess fcDA = new CSM_FocusCategoriesDataAccess();
    	fcDA.saveFocusCategory();
    	

		fcCmpController.focusCategoryGroup = null;
    	fcCmpController.userPref = new CSM_UserPreferencesFilterWrapper();	
		fcCmpController.userPref.attrFieldName = preferenceObj.CSM_Object_Field_Filter__c;
		fcCmpController.userPref.attrFieldType = preferenceObj.CSM_Object_Field_Type__c;
		fcCmpController.userPref.attrFieldValue = preferenceObj.CSM_Object_Field_Filter_Value__c;
		fcCmpController.userPref.attrFieldUserId = preferenceObj.CSM_Object_Field_Filter_User__c;
		fcCmpController.userPref.attrFieldDateValue = preferenceObj.CSM_Object_Field_Date_Value__c;

    	system.debug('testId' + fcg.Id);	
		fcCmpController.focusCategoryGroupInitValue = fcg.Id;
    	
    	Test.stopTest();
	}
	
	static testMethod void testRiskAdminVal() {
		CSM_TestUtility.setup();		
		CSM_Admin__c csmAdmin = CSM_AdminDataAccess.getCSMAdminInstance();
		csmAdmin.CSM_Risk_Reason__c = '';
		csmAdmin.CSM_Risk_Reason_Cont__c = 'Adoption Issue Related;CSAT Issues Related';
		csmAdmin.CSM_Risk_Reason_Dismiss__c = '';
		csmAdmin.CSM_Risk_Reason_Dismiss_Cont__c = 'Support Related';
		upsert csmAdmin;
		Test.startTest();
		List <SelectOption> reasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
		List <SelectOption> dismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);

    	CSM_FocusCategoriesComponentController fcCmpController = new CSM_FocusCategoriesComponentController();
		CSM_Focus_Category_Group__c fcg =[SELECT Id, OwnerId from CSM_Focus_Category_Group__c WHERE OwnerId =:UserInfo.getUserId() limit 1];
		fcCmpController.focusCategoryGroup = null;
    	fcCmpController.userPref = new CSM_UserPreferencesFilterWrapper();	
    	
    	system.debug('testId' + fcg.Id);	
		fcCmpController.focusCategoryGroupInitValue = fcg.Id;

		Test.stopTest();
		system.assert(!reasonList.isEmpty());
		system.assert(!dismissList.isEmpty());
	
	}
}