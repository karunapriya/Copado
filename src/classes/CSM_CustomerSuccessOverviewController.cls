/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.18.2014
* @description    CSM_CustomerSuccessOverviewController allows user to see three different components Focus Categories, Report Carousel and   
*/
public with sharing class CSM_CustomerSuccessOverviewController {
	public Boolean hasCSMAccess {get; private set;}
	public transient Boolean hasTaskFCV {get; set;}	
	public Boolean isFilterUserLookup {get; set;}
	public Boolean isFilterDateType {get; set;}
	public Boolean hasRenewAccess {get; private set;}
	public Boolean isChartsToBeShown {get; private set;}
	public Boolean isOverviewChartsToBeShown {get; private set;}
	public Boolean isShowInactiveCategories {get; private set;}
	public Boolean saveDefault {get; set;}
	public String filterAttributeVal {get; set;}
	public String filterInputText {get; set;}
	public String filterDisplayName {get; set;}
	public String lookUpValue {get;set;}
	public Boolean filterSaveNotification {get;set;} 	
	public String inputValForWrapper {get;set;}  
	
	
	public String tempFilterAttributeVal;
	public String tempFilterInputListVal;
	public String tempFilterInputText;
	public Date tempFilterDateType;
	public String tempFilterDisplayName;
	public String tempFilterObjectType;
	
	public String helpParam {get; set;}
	public CSM_User_Preferences__c preferenceObj{get; set;} 
	public CSM_UserPreferencesFilterWrapper preferenceWrapper {get; set;}
	
	public String focusCategoryGroup {get; private set;} 
	public String tilesGroupId {get; private set;} 
	public List<SelectOption> riskReasonList {get; private set;} 
 	public List<SelectOption> riskReasonDismissList {get; private set;}
	public List<SelectOption> newTaskRiskReasonList {get; private set;} 	
 	public String scoutUrl {get; set;}
 	
	private Map<String, String> objectFieldMap;
	private Map<String, String> objectTypeMap;
	
	public List<SelectOption> focusCategoryGroups {get; private set;}
	
    public List<SelectOption> filterObjectList {get; set;}
    public List<SelectOption> filterAttributesList {get;set;}
    public String filterObjectType {get; set;}	
   // public List<SelectOption> accountFilterAttributeList;
   // public List<SelectOption> successPlanFilterAttributeList;
    public Map<String, Schema.SObjectType> schemaMap;
    
	private CSM_FocusCategoriesGroupDataAccess fcgDA = new CSM_FocusCategoriesGroupDataAccess();
	
	public CSM_CustomerSuccessOverviewController() {
		try{
			scoutUrl = '';
			hasTaskFCV = checkForTaskFC();
	        hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        	hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
			helpParam = CSM_Constants.HELP_OVERVIEW;
			CSM_Admin__c adminSetting = CSM_Admin__c.getOrgDefaults();
			if(adminSetting != null)
			{
				scoutUrl = adminSetting.CSM_ScoutCollector__c;
			}
			schemaMap = Schema.getGlobalDescribe();
			String delimitedFields = 'CSM_Overview_FC_Group_Filter__c,CSM_Hide_Charts__c,CSM_Hide_Overview_Charts__c,CSM_Hide_Inactive_Categories__c,CSM_Object_Field_Filter__c,CSM_Filter_Display_Name__c,CSM_Object_Filter__c,CSM_Object_Field_Filter_User__c,CSM_Object_Field_Filter_Value__c,CSM_Object_Field_Date_Value__c';
			preferenceObj = CSM_UserPreferencesUtil.getUserPreferences(UserInfo.getUserId(), delimitedFields);
			system.debug('preferenceObj $$$$$$$ '+preferenceObj);
			preferenceWrapper = new CSM_UserPreferencesFilterWrapper();
			if(preferenceObj != null){
				isChartsToBeShown = !preferenceObj.CSM_Hide_Charts__c;
				isOverviewChartsToBeShown = !preferenceObj.CSM_Hide_Overview_Charts__c;
				isShowInactiveCategories = !preferenceObj.CSM_Hide_Inactive_Categories__c;
			}
			if (hasCSMAccess || hasRenewAccess){
	        	init();
	        }
			getfilterObjectList();
			//setFiltersList();
			setCSMEditFilterPreferenceValues();
			filterSaveNotification = false;			
			
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
	}
	
	public List<SelectOption> getfilterObjectList() {
		filterObjectList = new List<SelectOption>();
		filterObjectList.add(new SelectOption('Account', 'Account'));
		filterObjectList.add(new SelectOption('Success Plan', 'Success Plan'));
		if(hasTaskFCV){
			filterObjectList.add(new SelectOption('Task', 'Task'));		
		}
		
		return filterObjectList;
	}	
	
	private void init() {
		tilesGroupId = '';
		focusCategoryGroup = '';
		objectFieldMap = new Map<String, String>();
		objectTypeMap = new Map<String, String>();
		
		riskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
		riskReasonDismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
		newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);		
		
		focusCategoryGroups = fcgDA.getFocusCategoryGroups();
		
		for (CSM_FocusCategoryGroupWrapper gw : fcgDA.focusCategoryGroupActiveMap.values()){
			if (gw.GroupType == CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_TILES) {
				tilesGroupId = gw.GroupId;	
			}
		}
		//DE1127: Added the fix to show first FCG in the list as default.
		if (preferenceObj.Id == null){
			if(focusCategoryGroups!=null 
				&& !focusCategoryGroups.isEmpty() && focusCategoryGroups.size() > 1){
				focusCategoryGroup = focusCategoryGroups[1].getValue();
			}
		}else if(String.isNotBlank(preferenceObj.CSM_Overview_FC_Group_Filter__c)){
			focusCategoryGroup = preferenceObj.CSM_Overview_FC_Group_Filter__c;
		}
	} 
	
	public PageReference saveUserPreferenceForCharts() { 
		try{			
			preferenceObj.CSM_Hide_Charts__c = isChartsToBeShown;	 		
			isChartsToBeShown =!isChartsToBeShown;
			CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, 'CSM_Hide_Charts__c');
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
		return null; 
	}
	
	public PageReference saveUserPreferenceForOverviewCharts() { 
		try{			
			preferenceObj.CSM_Hide_Overview_Charts__c = isOverviewChartsToBeShown;	 		
			isOverviewChartsToBeShown =!isOverviewChartsToBeShown;
			CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, 'CSM_Hide_Overview_Charts__c');
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
		return null; 
	}
	
	public PageReference saveUserPreferenceForInactiveCategories() {
		try{			
			preferenceObj.CSM_Hide_Inactive_Categories__c = isShowInactiveCategories;
			preferenceWrapper.showInactive = !isShowInactiveCategories;
			isShowInactiveCategories =!isShowInactiveCategories;
			//CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj});
			CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, 'CSM_Hide_Inactive_Categories__c');
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
			
		return null; 
	}

	public PageReference saveUserPreferenceForCarouselCharts() { 
		try{	
			preferenceObj.CSM_Overview_Carousel_Chart__c = preferenceWrapper.overviewCarouselChart;
					
			//CSM_UserPreferencesDataAccess.saveUserPreferenceForOverviewChart(new List<CSM_User_Preferences__c>{preferenceObj});	
			CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, 'CSM_Overview_Carousel_Chart__c');		
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
		return null; 
	}


	
	//set the values in the popup from the system preferences
	public void setCSMEditFilterPreferenceValues() {		
		preferenceWrapper = new CSM_UserPreferencesFilterWrapper();
		filterAttributesList = new List<SelectOption>();
		String delimitedFields = 'CSM_Hide_Charts__c,CSM_Hide_Overview_Charts__c,CSM_Hide_Inactive_Categories__c,CSM_Object_Field_Filter__c,CSM_Filter_Display_Name__c,CSM_Object_Filter__c,CSM_Object_Field_Filter_User__c,CSM_Object_Field_Filter_Value__c,CSM_Object_Field_Date_Value__c,CSM_Object_Field_Type__c,CSM_Overview_Carousel_Chart__c,CSM_Overview_FC_Group_Filter__c,CSM_Success_Plan_Actions_Filter__c,CSM_Success_Plan_Actions_Grid_Columns__c,CSM_Success_Plan_Activity_Grid_Columns__c,CSM_Success_Task_Filter__c,CSM_Success_Task_Grid_Columns__c';
		preferenceObj = CSM_UserPreferencesUtil.getUserPreferences(UserInfo.getUserId(), delimitedFields);
		isChartsToBeShown = !preferenceObj.CSM_Hide_Charts__c;
		isOverviewChartsToBeShown = !preferenceObj.CSM_Hide_Overview_Charts__c;
		isShowInactiveCategories = !preferenceObj.CSM_Hide_Inactive_Categories__c;
		preferenceWrapper.showInactive = !preferenceObj.CSM_Hide_Inactive_Categories__c;
		
		if(preferenceObj.CSM_Object_Filter__c == 'Task' && !hasTaskFCV){
			filterAttributeVal = null;
			filterDisplayName = null;			
		}else{
			filterAttributeVal = preferenceObj.CSM_Object_Field_Filter__c;	
			filterDisplayName = preferenceObj.CSM_Filter_Display_Name__c;				
		}

		if(filterAttributeVal != null){
			saveDefault = true;
		}

		
		filterObjectType = preferenceObj.CSM_Object_Filter__c;
		
		if (preferenceObj.CSM_Object_Field_Filter_User__c == null && preferenceObj.CSM_Object_Field_Filter_Value__c != CSM_Constants.OBJ_UP_FIELD_LOOKUP_USER) {
			if(preferenceObj.CSM_Object_Field_Filter_Value__c == CSM_Constants.OBJ_UP_FIELD_DATE){
				isFilterDateType = true;
				isFilterUserLookup = false;
				filterInputText = null;
				inputValForWrapper = CSM_Constants.OBJ_UP_FIELD_DATE;
			}
			else{
				isFilterDateType = false;
				isFilterUserLookup = false;
				filterInputText = preferenceObj.CSM_Object_Field_Filter_Value__c;
				inputValForWrapper = preferenceObj.CSM_Object_Field_Filter_Value__c;
			}
		}
		else {
			isFilterDateType = false;
			isFilterUserLookup = true;
			filterInputText = null;
			inputValForWrapper = CSM_Constants.OBJ_UP_FIELD_LOOKUP_USER;
		}
		tempFilterAttributeVal = filterAttributeVal;
		tempFilterInputText = filterInputText;
		tempFilterDateType = preferenceObj.CSM_Object_Field_Date_Value__c;
		tempFilterDisplayName = filterDisplayName;
		tempFilterObjectType = filterObjectType;	
		
		preferenceWrapper.attrFieldName = preferenceObj.CSM_Object_Field_Filter__c;
		preferenceWrapper.attrFieldType = preferenceObj.CSM_Object_Field_Type__c;
		preferenceWrapper.attrFieldValue = inputValForWrapper;
		preferenceWrapper.attrFieldUserId = preferenceObj.CSM_Object_Field_Filter_User__c;
		if(preferenceObj.CSM_Object_Filter__c == 'Task' && !hasTaskFCV){
			preferenceObj.CSM_Object_Field_Filter_User__c = null;
		}
		preferenceWrapper.attrFieldDateValue = preferenceObj.CSM_Object_Field_Date_Value__c;
		
		preferenceWrapper.overviewCarouselChart = preferenceObj.CSM_Overview_Carousel_Chart__c;
		preferenceWrapper.overviewFCGroupFilter  = preferenceObj.CSM_Overview_FC_Group_Filter__c;
		preferenceWrapper.successPlanActionsFilter = preferenceObj.CSM_Success_Plan_Actions_Filter__c;
	 	preferenceWrapper.successPlanActionsGridColumns  = preferenceObj.CSM_Success_Plan_Actions_Grid_Columns__c;
	 	preferenceWrapper.successPlanActivityGridColumns = preferenceObj.CSM_Success_Plan_Activity_Grid_Columns__c;
	 	preferenceWrapper.successTaskFilter = preferenceObj.CSM_Success_Task_Filter__c;
	 	preferenceWrapper.successTaskGridColumns	 = preferenceObj.CSM_Success_Task_Grid_Columns__c;
		
		if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Success Plan')) {
    		//filterAttributesList = successPlanFilterAttributeList;
    		//setup the AccountsId List and assign it to the preferencWrapper
	    	populateFilterAttrList('Success Plan');
    		if(filterAttributeVal == null && filterInputText == null && preferenceObj.CSM_Object_Field_Date_Value__c == null){
				preferenceWrapper.attObjectType = null;
			}
			else{
    			preferenceWrapper.attObjectType = 'Success Plan';
    		}
    		preferenceWrapper.attrSPAccountIdsList = populateAccountIdsForSuccessPlan();
    	}

		else if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Account')) {
	    	populateFilterAttrList('Account');
    		//filterAttributesList = accountFilterAttributeList;
    		preferenceWrapper.attObjectType = 'Account';
    		preferenceWrapper.attrSPAccountIdsList = null;
    	}
		else if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Task') && hasTaskFCV) {
	    	populateFilterAttrList('Task');
    		//filterAttributesList = accountFilterAttributeList;
    		preferenceWrapper.attObjectType = 'Task';
    		preferenceWrapper.attrSPAccountIdsList = null;
    	}
    	else {
    		//give the default Object as Account to show something in the filter list initially
	   		filterObjectType = 'Account';
    		//filterAttributesList = accountFilterAttributeList;
    		if(filterAttributeVal == null && filterInputText == null && preferenceObj.CSM_Object_Field_Date_Value__c == null){
				preferenceWrapper.attObjectType = null;
			}
			else{
    			preferenceWrapper.attObjectType = 'Account';
    		}
    		//preferenceWrapper.attrSPAccountIdsList = populateAccountIdsForSuccessPlan();
    	}	
	}
	
	public Set<Id> populateAccountIdsForSuccessPlan() {
		Set<Id> accountIdsList = new Set<Id>();
		//based on the filter, populate the account ids list from the Success Plans.
		if ( preferenceWrapper.attrFieldName != null && preferenceWrapper.attrFieldUserId != null ) {
			List<CSM_Account_Plan__c> accountPlans = CSM_AccountPlanDataAccess.getFilterBasedAccountPlans(preferenceWrapper.attrFieldName, preferenceWrapper.attrFieldUserId);
			
			if (accountPlans != null && !accountPlans.isEmpty()) {
				for (CSM_Account_Plan__c accountPlan : accountPlans) {
					if (!accountIdsList.contains(accountPlan.CSM_AccountId__c)) {
						accountIdsList.add(accountPlan.CSM_AccountId__c);
					}
				}
			}
		}
		
		return accountIdsList;
	}

	
	public PageReference saveCSMEditFilter() {
		try{
			String lFilterDisplayName;
			//US2419 -- Start 
			String fieldName ;
			String nameSpace = CSM_Util.getNamespace();
			
			if(!String.isBlank(filterAttributeVal)){
				if(filterAttributeVal.endsWithIgnoreCase('__c')){
            		String fldName = filterAttributeVal.removeEndIgnoreCase('__c');
		   			if(!fldName.contains('__')){
                     	fieldName = nameSpace + filterAttributeVal;
                	}
				} else {
				fieldName = filterAttributeVal;
				}
			}
			// US2419 -- End
			if (filterAttributeVal != null) {
				String displayVal = null;
				if (isFilterUserLookup) {					
					if(lookUpValue.length() > 0){
						displayVal = lookUpValue;
						this.inputValForWrapper = CSM_Constants.OBJ_UP_FIELD_LOOKUP_USER;
					}
				}
				else if(isFilterDateType){	
		            if (preferenceObj.CSM_Object_Field_Date_Value__c!=null){
		            	displayVal = String.valueOf(preferenceObj.CSM_Object_Field_Date_Value__c);
		            }
				}
				else {
					if(filterInputText.length() > 0){
						displayVal = filterInputText;
					}
				}				
				if (filterObjectType.equalsIgnoreCase('Account')) {
					if(filterAttributeVal == 'OwnerId'){
						lFilterDisplayName = 'Account Owner' +' is '+displayVal;//schemaMap.get('Account').getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;					
					}else{
						lFilterDisplayName = schemaMap.get('Account').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel()+' is '+displayVal;	 //US2419				
						//lFilterDisplayName = schemaMap.get('Account').getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;					
					}
				}else if (filterObjectType.equalsIgnoreCase('Task')) {
					if(filterAttributeVal == 'OwnerId'){
						lFilterDisplayName = 'Assigned To' +' is '+displayVal;//schemaMap.get('Task').getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;
					}else if(filterAttributeVal == 'CreatedById'){
						lFilterDisplayName = 'Created By' +' is '+displayVal;//schemaMap.get('Task').getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;					
					}else if(filterAttributeVal == 'LastModifiedById'){
						lFilterDisplayName = 'Last Modified By' +' is '+displayVal;//schemaMap.get('Task').getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;					
					}else{
						lFilterDisplayName = schemaMap.get('Task').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel()+' is '+displayVal;		//US2419			
						//lFilterDisplayName = schemaMap.get('Task').getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;					
					}					
				}
				else if (filterObjectType.equalsIgnoreCase('Success Plan')) {
					//String nameSpace = CSM_Util.getNamespace();
					String successPlanObjName = nameSpace + 'CSM_Account_Plan__c';
					
				    String spLabelReplacement = CSM_Util.getLabelReplacement(filterAttributeVal);
				    if (spLabelReplacement == null)
				    {
				    	lFilterDisplayName = schemaMap.get(successPlanObjName.toLowerCase()).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel()+' is '+displayVal; //US2419
				    	//lFilterDisplayName = schemaMap.get(successPlanObjName.toLowerCase()).getDescribe().fields.getMap().get(filterAttributeVal).getDescribe().getLabel()+' is '+displayVal;
				    }
				    else
				    {
				    	lFilterDisplayName = spLabelReplacement+' is '+displayVal;
				    }
				}
				
				//save the values for all the filter fields in the Preferences Object
				//hardcoded to 'Account' for this implementation, can be dynamic later
				if (saveDefault) {
					system.debug('isFilterDateType $$' + isFilterDateType);
					system.debug('filterDateType $$' + preferenceObj.CSM_Object_Field_Date_Value__c);
					String delimitedFields = 'CSM_Overview_Carousel_Chart__c,CSM_Overview_FC_Group_Filter__c,CSM_Success_Plan_Actions_Filter__c,CSM_Success_Plan_Actions_Grid_Columns__c,CSM_Success_Plan_Activity_Grid_Columns__c,CSM_Success_Task_Filter__c,CSM_Success_Task_Grid_Columns__c,CSM_Hide_Charts__c,CSM_Hide_Overview_Charts__c,CSM_Hide_Inactive_Categories__c,CSM_Object_Field_Filter__c,CSM_Filter_Display_Name__c,CSM_Object_Filter__c,CSM_Object_Field_Filter_User__c,CSM_Object_Field_Filter_Value__c,CSM_Object_Field_Date_Value__c';
					preferenceObj.CSM_Object_Filter__c = filterObjectType;
					preferenceObj.CSM_Object_Field_Filter__c = filterAttributeVal;
					preferenceObj.CSM_Filter_Display_Name__c = lFilterDisplayName;	
					preferenceObj.CSM_Object_Field_Type__c = objectTypeMap.get(filterAttributeVal);
					//set the value of the filterInputField to be the id of the lookup(User), otherwise set the value of filterInputText
					if (isFilterUserLookup) {
						preferenceObj.CSM_Object_Field_Filter_Value__c = CSM_Constants.OBJ_UP_FIELD_LOOKUP_USER;
						preferenceObj.CSM_Object_Field_Date_Value__c = null;
						inputValForWrapper = CSM_Constants.OBJ_UP_FIELD_LOOKUP_USER;											
					}
					else if(isFilterDateType){
						preferenceObj.CSM_Object_Field_Filter_User__c = null;
						preferenceObj.CSM_Object_Field_Filter_Value__c = CSM_Constants.OBJ_UP_FIELD_DATE;
						//preferenceObj.CSM_Object_Field_Date_Value__c = filterDateType;
						inputValForWrapper = CSM_Constants.OBJ_UP_FIELD_DATE;
					}
					else {
						preferenceObj.CSM_Object_Field_Filter_User__c = null;
						preferenceObj.CSM_Object_Field_Date_Value__c = null;
						preferenceObj.CSM_Object_Field_Filter_Value__c = filterInputText;
						inputValForWrapper = filterInputText;
					}			
					//show the success or failure page message after the upsert is done to save the fields	 		
					CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, delimitedFields);
					filterSaveNotification = true;
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FILTER_SAVED));
				}
				
				tempFilterAttributeVal = filterAttributeVal;
				tempFilterInputText = filterInputText;
				tempFilterDateType = preferenceObj.CSM_Object_Field_Date_Value__c;				
				tempFilterDisplayName = lFilterDisplayName;
				filterDisplayName = lFilterDisplayName;
				tempFilterObjectType = filterObjectType;	
				
				preferenceWrapper.attObjectType = filterObjectType;
				preferenceWrapper.attrFieldName = filterAttributeVal;
				//MF Added contains key
				if(objectTypeMap.containsKey(filterAttributeVal))
				{
					preferenceWrapper.attrFieldType = objectTypeMap.get(filterAttributeVal);
				}
				else 
				{
					preferenceWrapper.attrFieldType = null;
				}
				preferenceWrapper.attrFieldValue = inputValForWrapper;
				preferenceWrapper.attrFieldUserId = preferenceObj.CSM_Object_Field_Filter_User__c;
				preferenceWrapper.attrFieldDateValue = preferenceObj.CSM_Object_Field_Date_Value__c;
				//get the success plan account Ids list
				system.debug('preferenceWrapper::' + preferenceWrapper);
				
				if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Account')) {
		    		preferenceWrapper.attrSPAccountIdsList = null;
		    	}
		    	else if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Success Plan')) {
		    		preferenceWrapper.attrSPAccountIdsList = populateAccountIdsForSuccessPlan();
		    	}				

									
			}else if(filterAttributeVal == null){
				system.debug('filterObjectType save $$$$$$$ '+filterObjectType);
				filterDisplayName = null;
				tempFilterAttributeVal = Label.CSM_LBL_PLEASESELECT;
				tempFilterInputText = null;
				tempFilterDateType = null;
				tempFilterDisplayName = null;
				tempFilterObjectType = filterObjectType;
				preferenceObj.CSM_Object_Filter__c = filterObjectType;
				preferenceObj.CSM_Object_Field_Filter__c = null;
				preferenceObj.CSM_Filter_Display_Name__c = null;	
				preferenceObj.CSM_Object_Field_Type__c = null;
				preferenceObj.CSM_Object_Field_Filter_User__c = null;
				preferenceObj.CSM_Object_Field_Date_Value__c = null;
				preferenceObj.CSM_Object_Field_Filter_Value__c = null;
				System.debug('preferenceObj - '+preferenceObj);
				if(saveDefault){
					//show the success or failure page message after the upsert is done to save the fields	 		
					String delimitedFields = 'CSM_Overview_Carousel_Chart__c,CSM_Overview_FC_Group_Filter__c,CSM_Success_Plan_Actions_Filter__c,CSM_Success_Plan_Actions_Grid_Columns__c,CSM_Success_Plan_Activity_Grid_Columns__c,CSM_Success_Task_Filter__c,CSM_Success_Task_Grid_Columns__c,CSM_Hide_Charts__c,CSM_Hide_Overview_Charts__c,CSM_Hide_Inactive_Categories__c,CSM_Object_Field_Filter__c,CSM_Filter_Display_Name__c,CSM_Object_Filter__c,CSM_Object_Field_Filter_User__c,CSM_Object_Field_Filter_Value__c,CSM_Object_Field_Date_Value__c';
					CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, delimitedFields);
					//CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj});
					filterSaveNotification = true;				
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FILTER_SAVED));
				}
				
				preferenceWrapper.attObjectType = null;
				preferenceWrapper.attrFieldName = null;
				preferenceWrapper.attrFieldType = null;
				preferenceWrapper.attrFieldValue = null;
				preferenceWrapper.attrFieldUserId = null;
				preferenceWrapper.attrFieldDateValue = null;
				preferenceWrapper.attrSPAccountIdsList = null;
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.CSM_MSG_FILTER_FIELDS_INVALID)); 
			}			
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
		return null; 		
	}
	
	public PageReference setUpCSMEditViewPopupValues() {
		updateListViews();
		filterAttributeVal = tempFilterAttributeVal;
		filterInputText = tempFilterInputText;
		filterDisplayName = tempFilterDisplayName; 
		return null;
	}
	
	public PageReference clearCSMEditViewFields() { 
		isFilterUserLookup = false;
		isFilterDateType = false;
		saveDefault = false;
		filterObjectType = 'Account';
		updateListViews();		
		return null;
	}
	
	public void filterAttrPickListProcess() {
		String referenceFieldType = objectFieldMap.get(filterAttributeVal);
		String dataType = objectTypeMap.get(filterAttributeVal);
		isFilterUserLookup = false;
		isFilterDateType = false;
		if (referenceFieldType != null && (referenceFieldType.equalsIgnoreCase('(User)') || referenceFieldType.equalsIgnoreCase('(Group, User)'))) {
			isFilterUserLookup = true;
		}
		else if(dataType != null && dataType == 'DATE'){
			isFilterDateType = true;
		}
	}
	
	//public void setFiltersList() {
		   	
        //we will return the filter list based on the option selected for the object
    	//if (accountFilterAttributeList == null || accountFilterAttributeList.isEmpty()) {
    		//set the up the Account Filter Attribute List
    	//	populateAccFilterAttrList();
    		
    	//}
    	//if (successPlanFilterAttributeList == null || successPlanFilterAttributeList.isEmpty()) {
    		//set the up the Success Plan Filter Attribute List
    	//	populateSPFilterAttrList();
    	//}
    	//populateFilterAttrList();
   // } 



	/**
	 * @description gets the available fields for the given object
	 * create the Select List after checking that those fields are present in the custom settings or not.
	 * @return List<SelectOption> 
	 */	
	     
    private void populateFilterAttrList(String objName) {
        filterAttributesList = new List<SelectOption>();
        try
        {   
            List<SelectOption> selectOptionSet = new List<SelectOption>();
           	String nameSpace = CSM_Util.getNamespace();
			List<Schema.SObjectField> fieldList;  
			List<SelectOption> csmSettingsFilterAttrList;
						         	
           	if(objName == 'Account'){
	            fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(CSM_Constants.OBJ_TYPE_ACCOUNT);
	            csmSettingsFilterAttrList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FILTER_ATTRIBUTES);
           	
           	}else if(objName == 'Success Plan') {
	            fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(CSM_Constants.OBJ_APP_ACCT_PLAN);
	            csmSettingsFilterAttrList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_SP_FILTER_ATTRIBUTES);
           	}else if(objName == 'Task') {
	            fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(CSM_Constants.OBJ_TASK);
	            csmSettingsFilterAttrList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_TASK_FILTER_ATTRIBUTES); 
				//csmSettingsFilterAttrList.add(new SelectOption(CSM_Constants.OBJ_T_OWNERID,CSM_Constants.OBJ_T_OWNERID));	
				//csmSettingsFilterAttrList.add(new SelectOption('CreatedById','CreatedById'));
				//csmSettingsFilterAttrList.add(new SelectOption('LastModifiedById','LastModifiedById'));								
           	}
            
            selectOptionSet.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
            if(csmSettingsFilterAttrList != null && !csmSettingsFilterAttrList.isEmpty()){
            	system.debug('fldlst - ' + fieldList);
	            for (SelectOption tmpFilterAttributeField : csmSettingsFilterAttrList) {
	            	//iterate and find out if the custom admin settings field exists in the Account's Object field
	            	for( Schema.SObjectField tmpfield :fieldList) {
	            		String fldStr;
						DescribeFieldResult tmpResult;	            		
						if(!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
                						!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.CONTRACT_ID)	){
		            		tmpResult = tmpField.getDescribe();
		            		fldStr = tmpResult.getName();  
		            		//check if namespace is there or not, if there, remove it from the name and set the object list		            		
				            if (nameSpace!=null && nameSpace.length()>0){
				                fldStr = fldStr.replace(nameSpace, '');
				            }
		            			            		
		            		DisplayType fieldDisplayType = tmpResult.getType(); 
		            		system.debug('refe1 -' + tmpResult.getReferenceTo());          		
		            		if (tmpFilterAttributeField.getValue().equalsIgnoreCase(fldStr)
		            			&& ('(User)'.equalsIgnoreCase(String.valueOf(tmpResult.getReferenceTo())) || '(Group, User)'.equalsIgnoreCase(String.valueOf(tmpResult.getReferenceTo())))) {
		            			objectFieldMap.put(fldStr, String.valueOf(tmpResult.getReferenceTo()));
		            			objectTypeMap.put(fldStr, String.valueOf(tmpResult.getType()));
	
	           					if(objName == 'Success Plan'){	            			
		            				selectOptionSet.add(new SelectOption(fldStr, CSM_Util.getLabelReplacement(fldStr)));
	           					}else{
		            				selectOptionSet.add(new SelectOption(fldStr, getFieldLabel(fldStr, tmpResult,objName)));           					
	           					}            			
		            		}
		            		      			            		
                		}            		
	            	}
	            }
	            filterAttributesList.addAll(selectOptionSet);
            }
        	//TBD: understand how and where to place this after code refactoring
        	filterAttrPickListProcess();
        }
        catch (Exception ex) {      
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }    	
    	
    }





    
	/**
	 * @description gets the available fields for the given object
	 * create the Select List after checking that those fields are present in the custom settings or not.
	 * @return List<SelectOption> 
	 */	
	     
   /* private void populateAccFilterAttrList() {
        accountFilterAttributeList = new List<SelectOption>();
        try
        {   
            List<SelectOption> selectOptionSet = new List<SelectOption>();
           	String nameSpace = CSM_Util.getNamespace();
            List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(CSM_Constants.OBJ_TYPE_ACCOUNT);
            List<SelectOption> csmSettingsFilterAttrList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FILTER_ATTRIBUTES);
            
            selectOptionSet.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
            if(csmSettingsFilterAttrList != null && !csmSettingsFilterAttrList.isEmpty()){
            	
	            for (SelectOption tmpFilterAttributeField : csmSettingsFilterAttrList) {
	            	//iterate and find out if the custom admin settings field exists in the Account's Object field
	            	for( Schema.SObjectField tmpfield :fieldList) {
	            		DescribeFieldResult tmpResult = tmpField.getDescribe();
	            		String fldStr = tmpResult.getName();        			            		
	            		
	            		//check if namespace is there or not, if there, remove it from the name and set the object list  
	            		
			            if (nameSpace!=null && nameSpace.length()>0){
			                fldStr = fldStr.replace(nameSpace, '');
			            }
	            			            		
	            		DisplayType fieldDisplayType = tmpResult.getType();           		
	            		if (tmpFilterAttributeField.getValue().equalsIgnoreCase(fldStr)
	            			&& '(User)'.equalsIgnoreCase(String.valueOf(tmpResult.getReferenceTo()))) {
	            			objectFieldMap.put(fldStr, String.valueOf(tmpResult.getReferenceTo()));
	            			objectTypeMap.put(fldStr, String.valueOf(tmpResult.getType()));
	            			selectOptionSet.add(new SelectOption(fldStr, getFieldLabel(fldStr, tmpResult)));
	            		}
	            	}
	            }
	            accountFilterAttributeList.addAll(selectOptionSet);
            }
        	//TBD: understand how and where to place this after code refactoring
        	filterAttrPickListProcess();
        }
        catch (Exception ex) {      
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }    	
    	
    }*/
    
    private String getFieldLabel(String fldStr, DescribeFieldResult fldDescribe,String objName){
    	if('OwnerId'.equalsIgnoreCase(fldStr) && objName == 'Account'){
    		fldStr = 'Account Owner';
    	} else if('CreatedById'.equalsIgnoreCase(fldStr)){
    		fldStr = 'Created By';
    	} else if('LastModifiedById'.equalsIgnoreCase(fldStr)){
    		fldStr = 'Last Modified By';
    	}else if('OwnerId'.equalsIgnoreCase(fldStr) && objName == 'Task'){
    		fldStr = 'Assigned To';    	 
    	}else {
    		fldStr = fldDescribe.getLabel();
    	}
    	
    	return fldStr;
    }
    
   /* private void populateSPFilterAttrList() {
        successPlanFilterAttributeList = new List<SelectOption>();
        try
        {   
            List<SelectOption> selectOptionSet = new List<SelectOption>();
           	String nameSpace = CSM_Util.getNamespace();
            List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(CSM_Constants.OBJ_APP_ACCT_PLAN);
            List<SelectOption> csmSettingsFilterAttrList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_SP_FILTER_ATTRIBUTES);
            
            selectOptionSet.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
            if(csmSettingsFilterAttrList != null && !csmSettingsFilterAttrList.isEmpty()){
            	
	            for (SelectOption tmpFilterAttributeField : csmSettingsFilterAttrList) {
	            	//iterate and find out if the custom admin settings field exists in the Success Plan's Object field
	            	for( Schema.SObjectField tmpfield :fieldList) {

	            		DescribeFieldResult tmpResult = tmpField.getDescribe();
	            		String fldStr = tmpResult.getName();        			            		
	            		
	            		//check if namespace is there or not, if there, remove it from the name and set the object list  
	            		
			            if (nameSpace!=null && nameSpace.length()>0){
			                fldStr = fldStr.replace(nameSpace, '');
			            }
			            		            		         		
	            		if (tmpFilterAttributeField.getValue().equalsIgnoreCase(fldStr)
	            			&& '(User)'.equalsIgnoreCase(String.valueOf(tmpResult.getReferenceTo()))) {
	            			objectFieldMap.put(fldStr, String.valueOf(tmpResult.getReferenceTo()));
	            			objectTypeMap.put(fldStr, String.valueOf(tmpResult.getType()));
	            			selectOptionSet.add(new SelectOption(fldStr, CSM_Util.getLabelReplacement(fldStr)));
	            		}
	            	}
	            }
	            successPlanFilterAttributeList.addAll(selectOptionSet);
            }
        	//TBD: understand how and where to place this after code refactoring
        	//filterAttrPickListProcess();
        }
        catch (Exception ex) {      
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }      	
    	
    }*/
    
    public PageReference updateListViews() {
    	system.debug('filterObjectType $$$$$$$ '+filterObjectType);
    	//filterAttributesList = new List<SelectOption>();
    	if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Account')) {
    		populateFilterAttrList('Account');
    	}
    	else if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Success Plan')) {
    		populateFilterAttrList('Success Plan');
    	}
    	else if (filterObjectType != null && filterObjectType.equalsIgnoreCase('Task')) {
    		populateFilterAttrList('Task');
    	}
    	
    	return null;
    }
    public PageReference resetNotification() {
    	
		filterSaveNotification = false;  
		return null;  	
    }   
    
    private Boolean checkForTaskFC() {
		Boolean flag = false;
		List<CSM_Focus_Category__c> lstFocusCategories = CSM_FocusCategoriesDataAccess.getAllTaskFCs();    	
		
		if(lstFocusCategories.size() > 0){
			flag = true;
		}
		return flag;  	
    }   

       
	
}