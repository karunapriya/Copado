/**
 * Created Date		: Mar 1, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
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
 * abirjepatil					User Story				Mar 1, 2017			1.1					@description
 *
 */
@isTest
private class CSM_FCCardsDisplayCompCntrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		csm_focus_category_view__c fcv1 = insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'','SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',true);
		insertFCVColumn(fcv1.Id);
		System.assert(fcv1.Id != null);		
		csm_focus_category_view__c fcv2 = insertFCV('View Account Test1', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',false);
		System.assert(fcv2.Id != null);
		insertFCVColumn(fcv2.Id);		
	}
	
	static testMethod void testFCCardsComponent() {
		
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_FCCardsDisplay;
        Test.setCurrentPage(csmPage);
    	
    	CSM_FCCardsDisplayCompCntrl fcCmpController = new CSM_FCCardsDisplayCompCntrl();
		fcCmpController.categoryViewId = '';
		fcCmpController.focusCategoryObjectType = '';
		fcCmpController.redirectId = '';
		fcCmpController.lnkActiveOrInactive = '';
		fcCmpController.newFocusCategoryGroupUrl = '';
		fcCmpController.editFocusCategoryGroupUrl = '';		
		fcCmpController.strTaskStatus = '';
   		fcCmpController.playOutcomeValue = '';
    	fcCmpController.accSPId = '';
    	fcCmpController.isComplete = true; 
    	
		if(CSM_Util.getRecordTypeExists(new Task())){
			List<RecordType> TaskRecordTypes = CSM_TaskDataAccess.getRecordTypeTask();
			for(RecordType sRecordType : TaskRecordTypes){
				fcCmpController.strRecordType = (String)sRecordType.Id;
				break;
			}
		}

		String curr = fcCmpController.defaultCurrency;
		Boolean multiCurr = fcCmpController.isMultiCurrency;
		String pkg = fcCmpController.packageVersion;		
		String scout = fcCmpController.scoutUrl;		
		
    	fcCmpController.packageVersion = CSM_Util.getPackageVersion(); 
    	fcCmpController.scoutUrl = CSM_Util.getScoutAnalyticsUrl();
    	fcCmpController.taskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
		fcCmpController.getPlayOutcomeValues();    	
		fcCmpController.getClosedStatus();		
	
    	//fcCmpController.riskReasonDismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
    	
    	PageReference pageRef;
    	
    	fcCmpController.whatId = CSM_TestUtility.acct.Id;
    	csm_account_plan__c acctPlan = new csm_account_plan__c();
    	acctPlan.CSM_AccountId__c =  CSM_TestUtility.acct.Id;
    	insert acctPlan;
    	
    	//fcCmpController.deleteUnwantedViews();
    	
    	fcCmpController.taskId = CSM_TestUtility.tsk.Id;
    	pageRef = fcCmpController.setTaskInfo();
    	System.assert(pageRef==null);
    	
    	fcCmpController.followUpTask = true;
		pageRef = fcCmpController.completeDismissTask();
    	//System.assert(pageRef!=null);
    	
    	fcCmpController.resetTask();
    	pageRef = fcCmpController.newFocusCategory();
    	System.assert(pageRef==null);
    	
    	pageRef = fcCmpController.redirectById();
    	System.assert(pageRef==null);
    	
    	List<SelectOption> optListRecordTypes = fcCmpController.getRecordTypes();
    	
		System.assert(optListRecordTypes != null);
          
        List<SelectOption> optListStatus = fcCmpController.getTaskStatus();
		System.assert(optListStatus != null);
		
		fcCmpController.redirectToSPEdit();		
    	Test.stopTest();
	}
	
	public static CSM_Focus_Category_View__c insertFCV(String displayName, String columns, String criteria, String soql, String objName,String currencyHeader, boolean isTiles) {
		CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
		fcv.CSM_Display_Name__c = displayName;
		fcv.CSM_Columns__c = columns;
		fcv.CSM_Criteria__c = criteria;
		fcv.CSM_SOQL__c = soql;
		fcv.CSM_Object_Name__c = objName;
		fcv.CSM_Currency_Header__c = currencyHeader;
		fcv.CSM_Filter_By_Owner_Value__c = 'My Account';
		fcv.CSM_IsTile__c = isTiles;		
		fcv.CSM_Is_Active__c = true;		
		insert fcv;
		return fcv;
	}	
	
	public static void insertFCVColumn(String viewId) {
		CSM_Focus_Category_View_Column__c focusCategoryViewColumn = new CSM_Focus_Category_View_Column__c();
		focusCategoryViewColumn.CSM_Display_Name__c = 'Billing City';
		focusCategoryViewColumn.CSM_Object_Field_Name__c = 'BillingCity';
		focusCategoryViewColumn.CSM_Object_Field_Type__c = 'String';
		focusCategoryViewColumn.CSM_Object_Name__c = 'Account';
		focusCategoryViewColumn.CSM_Focus_Category_View__c = viewId;
		insert focusCategoryViewColumn;
	}
	
	/* Test method for CSM_FCTilesDisplayCompCntrl and CSM_FCDisplayCntrl */
	static testMethod void fcTilesAndDisplayCntrl_test() {
		Test.startTest();	
			CSM_FCTilesDisplayCompCntrl fcTilesComCntrl = new CSM_FCTilesDisplayCompCntrl();
			System.assert(fcTilesComCntrl != null);
			CSM_FCDisplayCntrl fcDisplayCntrl = new CSM_FCDisplayCntrl();
		Test.stopTest();
	}
	
}