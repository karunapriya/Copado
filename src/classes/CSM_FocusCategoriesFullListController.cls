public with sharing class CSM_FocusCategoriesFullListController {

    public String fcViewId {get; set;}
    public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public String idVal {get; set;}
    //public List<SelectOption> objectList {get; private set;}
    public String focusCategoryObjectType {get; set;}
    public String focusCategoryDisplayName {get; set;}
    //public List<SelectOption> focusCategoryViewList {get; private set;}
    public String helpParam {get; set;}
    private CSM_FocusCategoriesDataAccess fcDA = new CSM_FocusCategoriesDataAccess();
    public String gridParam {get; set;}
    public CSM_DataGridAttribute fcDataGridAttribute {get; set;}
    public Map<Id,boolean> sObjectHasFcRecEditAccess {get; set;}
    public String isFromSSSetup {get; set;}
            
    public CSM_FocusCategoriesFullListController() {
        helpParam = CSM_Constants.HELP_FOCUS_CATEGORY_VIEWS;
        hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        //focusCategoryViewList = new List<SelectOption>();
        gridParam = '';
        fcViewId = ApexPages.currentPage().getParameters().get(CSM_Constants.PARAM_VIEWID);
        isFromSSSetup = ApexPages.currentPage().getParameters().get('FromServiceSourceSetup');
        String attrObjectType = ApexPages.currentPage().getParameters().get('amp;'+CSM_Constants.USER_PREF_OBJECT_TYPE);
        String attrFieldName = ApexPages.currentPage().getParameters().get('amp;'+CSM_Constants.USER_PREF_FIELD_NAME);
        String attrFieldType = ApexPages.currentPage().getParameters().get('amp;'+CSM_Constants.USER_PREF_FIELD_TYPE);
        String attrFieldValue = ApexPages.currentPage().getParameters().get('amp;'+CSM_Constants.USER_PREF_FIELD_VALUE);
        if(String.isNotBlank(attrFieldValue) && attrFieldValue.equalsIgnoreCase('UserLookupField')){
        	attrFieldValue = null;
        }
        populateFCInfo(fcViewId, attrObjectType, attrFieldName, attrFieldType, attrFieldValue);
        /*objectList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES, CSM_Constants.OBJ_TYPE_TASK);
        objectList.sort();*/
    	system.debug('In Constructor');
        getFullList();
        setGridAttributes();
        Set<Id> fcRecIds = new Set<Id>{fcViewId};
        if(!fcRecIds.isEmpty()){
	        sObjectHasFcRecEditAccess = CSM_AccessController.hasEditRecordAccess(fcRecIds,userinfo.getUserId());
			//system.debug('Map -----@@-----&&--'+sObjectHasFcRecEditAccess);
   		}
    }
    
    private void setGridAttributes()
    {	
    	
        fcDataGridAttribute = new CSM_DataGridAttribute();
		fcDataGridAttribute.tableName = CSM_Constants.GRID_ATTR_FC_FULL_LIST_TBL;
		fcDataGridAttribute.objectType = focusCategoryObjectType;
		fcDataGridAttribute.viewName = CSM_Constants.GRID_ATTR_FC_FULL_LIST_VIEW;
		fcDataGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
		fcDataGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE; 
		fcDataGridAttribute.showExport = CSM_Constants.GRID_ATTR_TRUE;
		fcDataGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
		fcDataGridAttribute.gridToolBarId = 'grid-toolbar';
		Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		fcDataGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
		fcDataGridAttribute.params = gridParam;
    }
    
    public void populateFCInfo(String fcViewId, String attrObjectType, String attrFieldName, String attrFieldType, String attrFieldValue) {
        if(!String.isBlank(fcViewId))
        {
            
            //Build parameters for grid  
            CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        	gridInputParams.taskOrViewId = fcViewId;
        	gridInputParams.accountId = '';
        	
        	CSM_UserPreferencesFilterWrapper userWrapper = new CSM_UserPreferencesFilterWrapper();
        	userWrapper.attObjectType = attrObjectType;
        	userWrapper.attrFieldName = attrFieldName;
        	userWrapper.attrFieldType = attrFieldType;
        	userWrapper.attrFieldValue = attrFieldValue;
        	gridInputParams.userPrefWrapper = userWrapper;
        	gridParam = JSON.serialize(gridInputParams);
        	system.debug('gridParamsFC $$ ' + gridParam);
        }
    }
    
    private void getFullList() {
        if (fcViewId!=null && fcViewId.length()>0){
            List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
            try
            {
                fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewID(fcViewId);
            }
            catch (exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            }
            if (fcViewList!=null && !fcViewList.isEmpty()){
                CSM_Focus_Category_View__c fcView = fcViewList[0];
                focusCategoryObjectType = fcView.CSM_Object_Name__c;
                focusCategoryDisplayName = fcView.CSM_Display_Name__c;
                // Get the list views based on the object
                /*focusCategoryViewList = fcDA.setCon(focusCategoryObjectType);
                CSM_Util.doSort(focusCategoryViewList, CSM_Util.FieldToSort.Label);*/
            }
        }
    }
    
    public PageReference getListForViewId() {
        getFullList();
        
        return null;
    }   
    
    /**
    * 
    * @description updateListViews Get the list view based on object changes
    * 
    * @return PageReference 
    * 
    */
    /*public PageReference updateListViews() {
        try {
            focusCategoryViewList = new List<SelectOption>();
            focusCategoryViewList.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
        
            // Get the list views based on the object
            List<SelectOption> tempList = fcDA.setCon(focusCategoryObjectType);
            CSM_Util.doSort(tempList, CSM_Util.FieldToSort.Label);	
            if (tempList!=null && !tempList.isEmpty()){
                focusCategoryViewList.addAll(tempList);
            }
            
            return null;    
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
    }*/
    
    /**
    * @description redirectToAccountPlan - Redirect to Account / Opportunity View
    *
    * @return PageReference 
    */
    public PageReference redirectToAccountPlan() {
        if (idVal!=null && (idVal.startsWith(CSM_Constants.ACCOUNT_PREFIX)
                || idVal.startsWith(CSM_Constants.OPPTY_PREFIX)
                || idVal.startsWith(CSM_Constants.CASE_PREFIX))){
            PageReference ref;
            if (idVal.startsWith(CSM_Constants.ACCOUNT_PREFIX)){
                ref = Page.CSM_AccountSuccessPlan;
                ref.getParameters().put(CSM_Constants.OBJ_T_ACCOUNTID, idVal);
            }else{
                ref = new PageReference('/'+idVal);
            }
            ref.setRedirect(true);
            return ref;
        }
        return null;
    }   
    
        
    /**
    * @description Create New Focus Category - Creates new focus category, i.e. new List view 
    *
    * @return PageReference 
    */
    public PageReference createNewFocusCategory() {
        try {
            if (focusCategoryObjectType!=null && focusCategoryObjectType.length()>0){
                
                // Create new list view based on standard page
                String filterEditPage = getFilterEditPage(false);
                
                // Get the List View through standard page
                PageReference pageRef = new PageReference(filterEditPage);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_OBJECT_TO_PROCEED));
                return null;
            }
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
    }
                
    /**
    * @description Edit Focus Category Group
    *
    * @return  
    */
    public PageReference editNewFocusCategory() {
        try {
            
            if (fcViewId!=null && fcViewId.length()>0){
                
                // Get the List View through standard page
                String filterEditPage = getFilterEditPage(true);
                // Get the page reference
                PageReference pageRef = new PageReference(filterEditPage);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_VIEW_TO_PROCEED));
                return null;
            }
            
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
    }
    
    public String getFilterEditPage(Boolean isEdit) {
                
        // Get current page url through page reference 
        PageReference pageRefTemp = Page.CSM_FocusCategoriesFullList;

        // Set up  current page reference with parameters
        String retURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL + fcViewId;

        String filterEditPage = CSM_Util.getFilterEditPage(fcViewId, isEdit, retURL, focusCategoryObjectType);
        
        
        return filterEditPage;      
    } 
    
    public PageReference backButtonClick() {
    	PageReference pageRef;
    	
    	if(isFromSSSetup != null && isFromSSSetup.equalsIgnoreCase(CSM_Constants.GRID_ATTR_TRUE)) {
    		pageRef = Page.CSM_FocusCategoryViewList;
    		pageRef.getParameters().put('tabCategory', 'Admin');
			pageRef.getParameters().put(CSM_Constants.PARAM_GSL_URL, CSM_Constants.GRID_ATTR_TRUE);
    	} else {
    		pageRef = new PageReference('/home/home.jsp');
    	}
    	
		pageRef.setRedirect(true);
    	return pageRef;
	}
}