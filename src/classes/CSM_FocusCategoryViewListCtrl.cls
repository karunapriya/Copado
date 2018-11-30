public with sharing class CSM_FocusCategoryViewListCtrl extends CSM_CustomPaginator {
	public String selectedObject {get; set;}
	public String selectedId {get; set;}
	public String helpParam {get; set;}
	public List<SelectOption> objectList {get; set;}
	public String newObjectSelected {get; set;}
	public String nameSpace {get;set;}

	public CSM_FocusCategoryViewListCtrl()  
	{
		helpParam = CSM_Constants.HELP_FOCUS_CATEGORIES;
        nameSpace = CSM_Util.getNamespace();
		objectList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES); //, CSM_Constants.OBJ_TYPE_TASK);
		objectList.sort();
	}		
	
	public CSM_DataGridAttribute focusCategoryViewListGridAttribute
    { 
    	set;
    	
    	get
    	{
    		if(focusCategoryViewListGridAttribute == null) {
	    		focusCategoryViewListGridAttribute = new CSM_DataGridAttribute();
	    		focusCategoryViewListGridAttribute.tableName = 'FocusCategoryViewList';
	    		focusCategoryViewListGridAttribute.objectType  = 'FocusCategoryViewList';
	    	    focusCategoryViewListGridAttribute.viewName = 'FocusCategoryViewList';
	    	    focusCategoryViewListGridAttribute.gridToolBarId = 'grid-toolbar';
	    	    focusCategoryViewListGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
	    	    focusCategoryViewListGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
				focusCategoryViewListGridAttribute.stateLoad = ApexPages.currentPage().getParameters().get(CSM_Constants.PARAM_GSL_URL);
	    	    focusCategoryViewListGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
	    	    focusCategoryViewListGridAttribute.showExport = CSM_Constants.GRID_ATTR_TRUE;
	    	    focusCategoryViewListGridAttribute.showGlobalSelect = CSM_Constants.GRID_ATTR_TRUE;
	    	    focusCategoryViewListGridAttribute.params = '{}';
	    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
	     	    focusCategoryViewListGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    		}
    		
     	    return focusCategoryViewListGridAttribute;
    	}
    }
	
	/*Added for US314 to delete the Focus Category View*/
	public PageReference deleteFocusCategoryView() {
		CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c(Id = selectedId); 
		CSM_FocusCategoryViewDataAccess.deleteFocusCategoryView(fcv);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_FCV_DELETE));	
		
		//Integer currentPageNumber = this.pageNumber;
		//buildFocusCategoryList();
		//this.initiateSetController(focusCategoryList);
		//this.updatePagesafterDelete(currentPageNumber);		
		return null;	
	}
	
	public PageReference redirectToView() {
		//View task goes to task page
		if(selectedObject == CSM_Constants.OBJ_TYPE_TASK)
		{
			PageReference pageRefTask = Page.CSM_TaskList;
			pageRefTask.getParameters().put(CSM_Constants.PARAM_VIEWID,selectedId);
			pageRefTask.setRedirect(true);
			return pageRefTask;
		}
		//All other views go to the focus categories full list page
		else
		{
			PageReference pageRef = Page.CSM_FocusCategoriesFullList;
			pageRef.getParameters().put(CSM_Constants.PARAM_VIEWID,selectedId);
			pageRef.getParameters().put('FromServiceSourceSetup', 'true');
			pageRef.setRedirect(true);
			return pageRef;
		}
	}
	 
	/* 
	 *@description redirect the user to the edit focus category page
	 *@return pageReference
	 */
	public PageReference redirectToEdit()
	{
        try {
			Set<String> fcvFieldSet = new Set<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
            CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL,
            CSM_Constants.OBJ_FCV_FILTER_LOGIC, CSM_Constants.OBJ_FCV_IS_TILE,
            CSM_Constants.OBJ_FCV_IS_ACTIVE,CSM_Constants.OBJ_FCV_FILTER_BY_OWNER, CSM_Constants.OBJ_FCV_Queue,
            CSM_Constants.OBJ_FCV_Sort_By,CSM_Constants.OBJ_FCV_Sort_Order};
	        CSM_Util.checkCRUD_FlsPermissions(CSM_Constants.OBJ_FCV, fcvFieldSet, CSM_Constants.DML_OPERATION_UPSERT);
	        PageReference pageRefTemp = Page.CSM_FocusCategoryViewList;
	        PageReference pageRef = Page.CSM_FocusCategoryView;
	        pageRef.getParameters().put(CSM_Constants.ID_PARAM, selectedId);
	        pageRef.getParameters().put(CSM_Constants.CANCEL_URL, pageRefTemp.getUrl() + '?' + CSM_Constants.PARAM_GSL_URL + '=' + CSM_Constants.GRID_ATTR_TRUE);
	        pageRef.setRedirect(true);
        return pageRef;
        } catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            return null;
        }
        
	}
	
	/**
	* @description Create New Focus Category - Creates new focus category, i.e. new List view 
	*
	* @return PageReference 
	*/
	public PageReference createNewFocusCategory() {
		try {
			if (!String.isBlank(newObjectSelected)){
				//Fix for DE2175
				//deleteFCV();
				CSM_Focus_Category_View__c fcView = new CSM_Focus_Category_View__c();
				fcView.CSM_Object_Name__c = newObjectSelected;
				List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
				fcViewList.add(fcView);
				CSM_FocusCategoryViewDataAccess.upsertFCV(fcViewList);

				// Create cancel url
				PageReference pageRefTemp = Page.CSM_FocusCategoryViewList;

				// Get the List View through standard page
				PageReference pageRef = Page.CSM_FocusCategoryView;
				pageRef.getParameters().put(CSM_Constants.OBJ_IG_ID, fcView.Id);				
				pageRef.getParameters().put(CSM_Constants.CANCEL_URL, pageRefTemp.getUrl() + '?' + CSM_Constants.PARAM_GSL_URL + '=' + CSM_Constants.GRID_ATTR_TRUE);
				pageRef.getParameters().put(CSM_Constants.OBJ_TYPE, newObjectSelected);
				pageRef.setRedirect(true);
				return pageRef;
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_OBJECT_TO_PROCEED));
			}
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    	}
    	return null;
	}
	
	/* 
	 *@description Clone the focus category.Added as part of US646
	 *@return pageReference
	 */
	public PageReference cloneFocusCategory(){
		Savepoint sp;
		try {
			sp = Database.setSavepoint();
			List<CSM_Focus_Category_View__c> fcView = new List<CSM_Focus_Category_View__c>();
			//To clone Focus Category View
			fcView = CSM_FocusCategoryViewDataAccess.cloneFCViewById(selectedId);
			if(fcView != null){
				//To clone Focus Category View Criteria
				CSM_FocusCategoryViewCriteriaDataAccess.cloneFCCriteriaByFCId(selectedId, String.valueof(fcView[0].id));
				//To clone Focus Category View Columns
				CSM_FocusCategoryViewColumnDataAccess.cloneFCColViewByFcId(selectedId, String.valueof(fcView[0].id));
				// To clone Focus Category Restrict Visiblity
				CSM_FocusCategoryViewCriteriaDataAccess.cloneRestrictVisibilityByFCId(selectedId, String.valueof(fcView[0].id));
			}
			//PageReference pageRef = page.csm_focuscategoryviewlist;
			//pageRef.getParameters().put('tabCategory', 'Admin');
			//pageRef.setRedirect(true);
			//return pageRef;
		}catch (exception ex){
    		Database.rollback(sp);
			ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage());
			ApexPages.addMessage(msg);
    		//return null;
		}
		return null;
	}
	
	/*
	public boolean hasCSMAccess {get; private set;}
	public boolean hasRenewAccess {get; private set;}
	private List<CSM_Focus_Category_View__c> focusCategoryList;
	public String tabCategory {get; set;} 
	public Integer groupCount {get; set;}
	public String strGroupNames {get; set;}
	CSM_User_Preferences__c preferenceObj{get; set;}*/
	//public Map<Id,boolean> sObjectHasFcRecEditAccess {get; set;}
	
	/* 
	 * @description: controller
	 */
	/*public CSM_FocusCategoryViewListCtrl()  
	{
			selectedId = ''; 
			selectedObject = '';
			helpParam = CSM_Constants.HELP_FOCUS_CATEGORIES;
			SS_LicenseCheck.getUserType();
	        hasCSMAccess = SS_Constants.isCSMUser==true || SS_Constants.isCSMNetOpsUser==true;
	        hasRenewAccess = SS_Constants.isRenewUser==true || SS_Constants.isRenewNetOpsUser==true;
       
			buildFocusCategoryList();
			//this.pageSize = 10;
			this.pageNumber = 1;
			//this.resourcesList = focusCategoryList;
			//MF CHange to use set controller
			this.initiateSetController(focusCategoryList);

			objectList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES);//, CSM_Constants.OBJ_TYPE_TASK);
			objectList.sort();
			
			retrieveUserPreference();
			
			this.updatePages();	
			
			//Set<Id> fcRecIds = new Set<Id>();
			//if(!focusCategoryList.isEmpty()){
			//	for(CSM_Focus_Category_View__c fcv : focusCategoryList){
			//		fcRecIds.add(fcv.Id);
			//	}
			//}
			//sObjectHasFcRecEditAccess = CSM_AccessController.hasEditRecordAccess(fcRecIds,userinfo.getUserId());
	}*/
		
	/*
	 * @description builds the focus category list
	 */
	/*public void buildFocusCategoryList() {
		focusCategoryList = new List<CSM_Focus_Category_View__c>();
		if (!SS_Constants.isCSMNetOpsUser && !SS_Constants.isRenewNetOpsUser 
		        && (SS_Constants.isSolExtSalesManager || SS_Constants.isSolExtOpsManager))
		{
			focusCategoryList = CSM_FocusCategoryViewDataAccess.getAllFocusCategoryViewsByUser(UserInfo.getUserId()); 
		}
		else 
		{	
		    focusCategoryList = CSM_FocusCategoryViewDataAccess.getAllFocusCategoryViews(); 
		}
	}*/

	/*Added for US314 to get the group names and count to which the to be deleted Focus Category View belongs to*/
	/*public PageReference getGroupsFocusCategoryDelete() {
		List<SObject> sobjGroups = CSM_FocusCategoryViewDataAccess.getAllGroupsforFocusCategoryView(selectedId);
		Set<String> groupNames = new Set<String>();	
	    for(SObject sobjGroup: sobjGroups){
	    	groupNames.add((String)sobjGroup.getSObject('CSM_Focus_Category_Column__r').getSObject('CSM_Focus_Category_Group__r').get('CSM_Display_Name__c'));
	    }
	    strGroupNames = '';
	    groupCount = groupNames.size();
		if(groupCount < 6){
			List<String> tempObjList = new List<String>();
			for(String str: groupNames){
				tempObjList.add(str);
				//strGroupNames = strGroupNames + str + '\\n';
			}
			strGroupNames = JSON.serialize(tempObjList);
		}
		return null;
	}*/
	
	/* 
	 * @description gets focus category list
	 * @return List<CSM_Focus_Category_View__c>
	 */
	/*public List<CSM_Focus_Category_View__c> getFocusCategoryList() 
	{
		return (List<CSM_Focus_CAtegory_View__c>) this.getResults();
	}*/
	
    /*public void savePageSize(){
	    try {
	    	this.updatePages();
			//CSM_User_Preferences__c preferenceObj = new CSM_User_Preferences__c();	    	
	    	preferenceObj.CSM_FCV_Grid_Pagesize__c= String.ValueOf(pageSize);
	    	List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    	userPreferenceList.add(preferenceObj);
	    	CSM_UserPreferencesDataAccess.saveUserPreference(userPreferenceList, 'CSM_FCV_Grid_Pagesize__c');
	    	//system.debug('Final List:'+columnList);
	    }catch (exception ex) {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		}

    }*/
    
    /*public void retrieveUserPreference(){
		preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'CSM_FCV_Grid_Pagesize__c');
		if(preferenceObj == null) {
			preferenceObj = new CSM_User_Preferences__c();
			preferenceObj.CSM_User__c = UserInfo.getUserId();
			this.pageSize = Integer.ValueOf('10');			
		} else {
			if(!String.isEmpty(preferenceObj.CSM_FCV_Grid_Pagesize__c)){
				this.pageSize = Integer.ValueOf(preferenceObj.CSM_FCV_Grid_Pagesize__c);
			}else{
				this.pageSize = Integer.ValueOf('10');			
			}
		}
    } */
    
    /*public void deleteFCV(){
    	List<CSM_Focus_Category_View__c> lstFCV = CSM_FocusCategoryViewDataAccess.getToDeleteFCV();
		if(lstFCV != null && !lstFCV.isEmpty()){
			CSM_FocusCategoryViewDataAccess.deleteFCV(lstFCV);
			
			Integer currentPageNumber = this.pageNumber;
			buildFocusCategoryList();
			this.initiateSetController(focusCategoryList);
			this.updatePagesafterDelete(currentPageNumber);		
			
		}    	
    }*/
}