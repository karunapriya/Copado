@isTest
public with sharing class CSM_CustomerSuccessOverviewCntrlTest {

	static testMethod void testCustomerSuccessPage() {
		
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_CustomerSuccessOverview;
        Test.setCurrentPage(csmPage);
    	CSM_CustomerSuccessOverviewController controller = new CSM_CustomerSuccessOverviewController();
    	system.assert(controller.hasCSMAccess==true);
 
 		system.assert(controller.isChartsToBeShown);
    	controller.saveUserPreferenceForCharts();
    	CSM_CustomerSuccessOverviewController controller22 = new CSM_CustomerSuccessOverviewController();
    	system.assert(!controller22.isChartsToBeShown);
 
     	system.assert(controller.isOverviewChartsToBeShown);
    	controller.saveUserPreferenceForOverviewCharts();
    	CSM_CustomerSuccessOverviewController controller2 = new CSM_CustomerSuccessOverviewController();
    	system.assert(!controller2.isOverviewChartsToBeShown);
    	
    	system.assert(!controller.isShowInactiveCategories);
    	controller.saveUserPreferenceForInactiveCategories();
    	controller2 = new CSM_CustomerSuccessOverviewController();
    	system.assert(controller2.isShowInactiveCategories);
    	//controller.getFilterAttributesList();
    	
    	controller.setUpCSMEditViewPopupValues();
    	controller.filterAttrPickListProcess(); 
    	controller.filterAttributeVal = 'Owner ID';
    	controller.saveDefault = true;
    	controller.isFilterUserLookup = true; 
    	controller.lookUpValue = 'SampleData';    	

    	controller.saveCSMEditFilter();
    	
    	controller.filterAttributeVal = 'ARR';
    	controller.isFilterUserLookup = false;
    	controller.lookUpValue = null;
    	controller.filterAttrPickListProcess();

    	controller.saveCSMEditFilter();  
    	
    	controller.clearCSMEditViewFields(); 
    	controller.filterAttrPickListProcess();
    	controller.filterAttributeVal = null;
    	controller.isFilterUserLookup = false;
    	controller.isFilterDateType = true;
    	//controller.filterDateType = System.today();
    	controller.saveDefault = true;    	
    	controller.lookUpValue = null;
		
    	controller.saveCSMEditFilter();  	

		controller.preferenceObj.CSM_Object_Field_Filter_Value__c = CSM_Constants.OBJ_UP_FIELD_DATE;
    	update controller.preferenceObj;
    	//controller.clearCSMEditViewFields(); 
    	controller.filterAttrPickListProcess();
    	controller.filterAttributeVal = 'Last Health Status';
    	controller.isFilterUserLookup = false;
    	controller.isFilterDateType = true;
		//controller.preferenceObj.CSM_Object_Field_Filter_Value__c = CSM_Constants.OBJ_UP_FIELD_DATE; 	

		controller.setCSMEditFilterPreferenceValues();    	
    	//controller.filterDateType = System.today();
    	controller.lookUpValue = null;
    	
    	//controller.clearCSMEditViewFields(); 
    	
		controller.preferenceObj.CSM_Object_Field_Filter_Value__c = CSM_Constants.OBJ_UP_FIELD_LOOKUP_USER;
    	update controller.preferenceObj;		    	 
		controller.setCSMEditFilterPreferenceValues();
		
    	controller.filterAttributeVal = 'Last Health Status';
    	controller.isFilterUserLookup = false;
    	controller.isFilterDateType = true;
		controller.preferenceObj.CSM_Object_Field_Date_Value__c = system.today();    	
    	controller.saveDefault = true;    	
    	controller.saveCSMEditFilter();  	
		
    	controller.saveUserPreferenceForCarouselCharts(); 
    	system.assert(String.isEmpty(controller.preferenceObj.CSM_Overview_Carousel_Chart__c));
    	controller.preferenceObj = null;	
     	controller.saveUserPreferenceForCarouselCharts();
    	
    	
    	Test.stopTest();
	}


	static testMethod void testCustomerSuccessPage1() {
		
		CSM_TestUtility.setup();
		Test.startTest();	
    	PageReference csmPage = Page.CSM_CustomerSuccessOverview;
        Test.setCurrentPage(csmPage);
    	CSM_CustomerSuccessOverviewController controller = new CSM_CustomerSuccessOverviewController();
    	controller.hasTaskFCV = true;
    	controller.filterObjectType = 'Account';
		controller.preferenceObj.CSM_Object_Filter__c = 'Account';
		controller.preferenceObj.CSM_Object_Field_Filter__c = 'OwnerId';
		controller.preferenceObj.CSM_Filter_Display_Name__c = null;	
		controller.preferenceObj.CSM_Object_Field_Type__c = 'Reference';
		controller.preferenceObj.CSM_Object_Field_Filter_User__c = UserInfo.getUserId();
		controller.preferenceObj.CSM_Object_Field_Date_Value__c = null;
		controller.filterAttributeVal = 'OwnerId';
    	controller.isFilterUserLookup = true;
    	controller.isFilterDateType = false;    			
    	controller.saveDefault = true; 
		controller.lookUpValue = UserInfo.getUserId();    	   	
    	controller.setUpCSMEditViewPopupValues();

		controller.filterAttributeVal = 'OwnerId';
    	controller.isFilterUserLookup = true;
    	
    	controller.saveCSMEditFilter();
    	

    	controller.filterAttrPickListProcess(); 
    	
		controller.filterObjectType = 'Success Plan';
		controller.preferenceObj.CSM_Object_Filter__c = 'Success Plan';
		controller.preferenceObj.CSM_Object_Field_Filter__c = 'CSM_Account_Manager__c';
		controller.preferenceObj.CSM_Filter_Display_Name__c = null;	
		controller.preferenceObj.CSM_Object_Field_Type__c = 'Reference';
		controller.preferenceObj.CSM_Object_Field_Filter_User__c = UserInfo.getUserId();
		controller.preferenceObj.CSM_Object_Field_Date_Value__c = null;
		controller.filterAttributeVal = 'CSM_Account_Manager__c';
    	controller.isFilterUserLookup = true;
    	controller.isFilterDateType = false;    					
    	controller.saveDefault = true;    	
		controller.lookUpValue = UserInfo.getUserId();
    	controller.setUpCSMEditViewPopupValues();
		controller.filterAttributeVal = 'CSM_Account_Manager__c';
    	controller.isFilterUserLookup = true;

    	controller.saveCSMEditFilter();


    	controller.filterAttrPickListProcess(); 
    	
		controller.filterObjectType = 'Task';
		controller.preferenceObj.CSM_Object_Filter__c = 'Task';
		controller.preferenceObj.CSM_Object_Field_Filter__c = 'OwnerId';
		controller.preferenceObj.CSM_Filter_Display_Name__c = null;	
		controller.preferenceObj.CSM_Object_Field_Type__c = 'Reference';
		controller.preferenceObj.CSM_Object_Field_Filter_User__c = UserInfo.getUserId();
		controller.preferenceObj.CSM_Object_Field_Date_Value__c = null;
		controller.filterAttributeVal = 'OwnerId';	
    	controller.isFilterUserLookup = true;	
    	controller.isFilterDateType = false;		
    	controller.saveDefault = true;  
		controller.lookUpValue = UserInfo.getUserId();    	  	
    	controller.setUpCSMEditViewPopupValues();
		controller.filterAttributeVal = 'OwnerId';
    	controller.isFilterUserLookup = true;
    	
    	controller.saveCSMEditFilter();


    	controller.filterAttrPickListProcess(); 
    	system.assert(controller.preferenceObj.CSM_Object_Filter__c == 'Task');    	
    	controller.preferenceObj = null;	
    	
    	Test.stopTest();
	}



}