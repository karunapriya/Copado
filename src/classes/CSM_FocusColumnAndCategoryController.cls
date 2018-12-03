/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.24.2014
* @description    CSM_FocusColumnAndCategoryController class contains methods for supporting the UI  
*/
public with sharing class CSM_FocusColumnAndCategoryController {
	
	private CSM_FocusCategoriesGroupDataAccess fcgDA = new CSM_FocusCategoriesGroupDataAccess();
	private String fcGroupId {get; set;}
	private Map<String, List<SelectOption>> objListViews {get; set;}
	private Map<String, String> selectOptionMap {get; set;}
	private Integer hasLimitReached;
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
		
	public CSM_FocusCategoriesDataAccess fcDA = new CSM_FocusCategoriesDataAccess();
	public CSM_FocusCategoriesColumnDataAccess fccDA = new CSM_FocusCategoriesColumnDataAccess();
	public Integer focusCategoryColumnLimit {get; private set;}
	public CSM_Focus_Category_Group__c focusCategoryGroup {get; private set;}
	public List<SelectOption> objectList {get; private set;}
	public String focusCategoryColumnId {get; set;}
	public String focusCategoryColumnName {get; set;}
	public String fCColumnName {get; set;}
	public String editFocusCategoryColumnName {get; set;}
	public String focusCategoryObjectType {get; set;}
	public String focusCategoryToAdd {get; set;}
	public String categoryViewId {get; set;}
	public String categoryId {get; set;}
	public String categoryDisplayName {get; set;}
	public Integer categoryUniqueId {get; set;}
	public Integer focusCategoryColumnUniqueId {get; set;}
	public boolean hasCSMAccess {get; private set;}
	public boolean hasRenewAccess {get; private set;}
	public Boolean theLinksAreVisible {get; private set;} 
	public String returnURL {get; private set;}	
	/**
	* @description getFocusCategoryColumnList
	*
	* @return List<CSM_FocusCategoryColumnWrapper> 
	*/
	public List<CSM_FocusCategoryColumnWrapper> getFocusCategoryColumnList() {
		return fccDA.focusCategoryColumnList;
	}
		
	/**
	* @description getFocusCategoryList
	*
	* @return List<CSM_FocusCategoryWrapper> 
	*/
	public List<CSM_FocusCategoryWrapper> getFocusCategoryList() {
		return fcDA.focusCategoryList;
	}
			
	/**
	* @description FocusCategoryGroupList
	*
	* @return nothing 
	*/
	public CSM_FocusColumnAndCategoryController(){
		helpParam = CSM_Constants.HELP_FOCUS_CATEGORY_GROUPS;
		focusCategoryColumnLimit = CSM_AdminDataAccess.getFocusCategoryColumnLimit();
		// Check for License
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
	    hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		fcGroupId = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_FCG_GROUPID);
		objectList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES);
		objectList.sort();
		this.theLinksAreVisible = true;
			/*if(!CSM_Util.isUserAnSystemAdmin()) {
				this.theLinksAreVisible =false;
			}*/
			
		String rURL = ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL);
		if (rURL != null)
		{
			returnURL = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL),CSM_Constants.UTF_8);
		}
		// Get the Group Id and check if there are multiple information entered
		if (fcGroupId!=null && fcGroupId.indexOf('_')>-1){
			String[] fcAndEditVar = fcGroupId.split('_');
			fcGroupId = fcAndEditVar[0];
			focusCategoryColumnId = fcAndEditVar[1];
			focusCategoryObjectType = fcAndEditVar[2];
			if (fcAndEditVar.size()>3){
				categoryViewId = fcAndEditVar[3];
			}
		}
		
		try
		{
			// Check if the Group Id exist
			if (fcGroupId!=null){
				// Retrieve Group info based on Group Id
				fcgDA.populateWrapperClass(fcGroupId);
				
				// Get Columns based on Group Id
				fccDA.populateWrapperClass(fcGroupId, null, null);
				
				if (fcgDA.hasTiles){
					focusCategoryColumnLimit = 1;
				}
				
				// Check if the Group Column Id exist if so we need to get the Focus Category Column info for display 
				if (focusCategoryColumnId!=null){
					// Get the column Name to display
					if (fccDA.focusCategoryColumnMap.containsKey(focusCategoryColumnId)) {
						editFocusCategoryColumnName = fccDA.focusCategoryColumnMap.get(focusCategoryColumnId).CSM_Display_Name__c;
					}
					
					// Retrieve the Categories for Column
					fcDA.populateWrapperClass(focusCategoryColumnId, null, null);
				} 
				// Get the focus category and display that record so that owner can be changed
				if (fcgDA.focusCategoryGroupMap.containsKey(fcGroupId)){
					focusCategoryGroup = fcgDA.focusCategoryGroupMap.get(fcGroupId);
				}
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}

	/**
	* @description Create New Focus Category Column
	*
	* @return PageReference  
	*/
	public PageReference createNewFocusCategoryColumn() {
		try {
			if (getHasLimitReached()>focusCategoryColumnLimit){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_LBL_COLUMN_LIMIT_REACHED));
			} else {
				// Check CategoryColumn Name and check update the Category Column Name
				if (focusCategoryColumnName!=null && focusCategoryColumnName.trim().length()>0) {
					fccDA.createFocusCategoryColumn(fcGroupId, focusCategoryColumnName);
					focusCategoryColumnName = '';
				}
			}
			return null;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
		
	}


	/**
	* @description Create New Focus Category Group
	*
	* @return PageReference  
	*/
	public PageReference addFocusCategory() {
		try {
			String viewName;
			if (selectOptionMap.containsKey(focusCategoryToAdd)){
				viewName = selectOptionMap.get(focusCategoryToAdd);
			}
			system.debug(' inadd-' + focusCategoryToAdd);
			
			Map<Id,CSM_Focus_Category__c> excludeDuplicateMap = CSM_FocusCategoriesDataAccess.getFocusCategoryByFCG(focusCategoryGroup.id);
			
			if(excludeDuplicateMap.containsKey(focusCategoryToAdd)) {
				CSM_Focus_Category__c fcRecord = excludeDuplicateMap.get(focusCategoryToAdd);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,String.format(System.Label.CSM_DUPLICATE_FC_LABEL_1, new String[]{fcRecord.CSM_Focus_Category_Column__r.CSM_Display_Name__c})));
			} else {
				fcDA.createFocusCategory(viewName, focusCategoryObjectType, focusCategoryColumnId, focusCategoryToAdd);
			}
			
			return null;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
	}
	
	public Integer getHasLimitReached() {
		Integer numberOfRec = 0;
		for(CSM_FocusCategoryColumnWrapper fccCW : fccDA.focusCategoryColumnList){
			if (fccCW.ColumnActive) {
				numberOfRec++;
			}
		}
		if (numberOfRec>focusCategoryColumnLimit){
			for(CSM_FocusCategoryColumnWrapper fccCW : fccDA.focusCategoryColumnList){
				if (fccDA.focusCategoryColumnMap.containsKey(fccCW.ColumnId)) {
					fccCW.ColumnActive = fccDA.focusCategoryColumnMap.get(fccCW.ColumnId).CSM_IsActive__c;
				}
			}
		}
		return numberOfRec;
	}
	
	/**
	* @description Save Focus Categories
	*
	* @return PageReference  
	*/
	public PageReference saveFocusCategories() {
		try {
			if (fcgDA.focusCategoryGroupList!=null && !fcgDA.focusCategoryGroupList.isEmpty()) {
				fcgDA.focusCategoryGroupList[0].GroupName = focusCategoryGroup.CSM_Display_Name__c;
				fcgDA.focusCategoryGroupList[0].GroupOwnerId = focusCategoryGroup.OwnerId;
				fcgDA.focusCategoryGroupList[0].GroupActive = focusCategoryGroup.CSM_IsActive__c;
			}
			if (getHasLimitReached()>focusCategoryColumnLimit){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_LBL_COLUMN_LIMIT_REACHED));
			} else {
				fcDA.saveFocusCategory();
				fccDA.saveFocusCategoryColumn();
				fcgDA.saveFocusCategoryGroup();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_SAVED_CATEGORY_GROUP_COLUMN_CATEGORIES));
			}
		} 
		catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    	}
		return null;
	}
	
	
	/**
	* @description Edit Focus Category Group
	*
	* @return PageReference  
	*/
	public PageReference editFocusCategoryColumn() {
		try {
			
			CSM_FocusCategoryColumnWrapper fcCW = fccDA.saveAndRetrieveId(focusCategoryColumnUniqueId);
			
			// Check and set the category column name
			if (fcCW.ColumnName!=null && fcCW.ColumnName.trim().length()>0) {
				editFocusCategoryColumnName = fcCW.ColumnName;
			}
			
			// Get the category Column id
			focusCategoryColumnId = fcCW.ColumnId;
			
			// Populate the Focus categories based on column
			fcDA.populateWrapperClass(fcCW.ColumnId, null, null);
			
			// Retrieve list views based on Account object
			getFocusCategoryViewList();
			
			// check if user is System Admin
			this.theLinksAreVisible = true;
			/*if(!CSM_Util.isUserAnSystemAdmin()) {
				this.theLinksAreVisible =false;
			}*/
			return null;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
	}
	
	
	/**
	* @description Delete Focus Category Column
	*
	* @return PageReference  
	*/
	public PageReference deleteFocusCategoryColumn() {
		
		CSM_FocusCategoryColumnWrapper fcCW;
		String lFocusCategoryColumnName;
		boolean isSuccessfulDelete;
		
		try {
			if(focusCategoryColumnUniqueId != null)
			{
				lFocusCategoryColumnName = fCColumnName;
											
				isSuccessfulDelete = fccDA.deleteFocusCategoryColumn(focusCategoryColumnUniqueId);
				if(isSuccessfulDelete)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, String.format(System.Label.CSM_MSG_FC_COLUMN_NAME, new String[]{lFocusCategoryColumnName})));
				}
				//populate the WrapperClass again after deleting the focus category column
				fCColumnName = '';
				fccDA.populateWrapperClass(fcGroupId, null, null);
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}	
	
    /**
	* 
	* @description updateListViews Get the list view based on object changes
	* 
	* @return PageReference 
	* 
	*/
	public PageReference updateListViews() {
		try {
			// Get the list views based on the object
			getFocusCategoryViewList();
			return null;	
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
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
			if (focusCategoryObjectType!=null && focusCategoryObjectType.length()>0){
				
				// Create new list view based on standard page
				String filterEditPage = getFilterEditPage(null, false, fcGroupId, focusCategoryColumnId, focusCategoryObjectType);
				
				CSM_Focus_Category_View__c fcView = new CSM_Focus_Category_View__c();
				fcView.CSM_Object_Name__c = focusCategoryObjectType;
				List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
				fcViewList.add(fcView);
				CSM_FocusCategoryViewDataAccess.upsertFCV(fcViewList);
				
				// Get the List View through standard page
				PageReference pageRef = new PageReference(filterEditPage + '&id=' + fcView.id);
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
	* @description Delete Focus Category from the Column, this is not outright Focus Category delete
	* @return PageReference
	*/
	
	public PageReference deleteFocusCategory() {
		boolean isSuccessfulDelete;
		
		try {
			//system.debug('Select Id From CSM_Focus_Category__c where CSM_Focus_Category_View__c =:' + categoryId + ' and  CSM_Focus_Category_Column__c =:' + focusCategoryColumnId);
			//List<CSM_Focus_Category__c> lstFocusCategories = [Select Id From CSM_Focus_Category__c where Id =:categoryId and CSM_Focus_Category_View__c =:categoryViewId and  CSM_Focus_Category_Column__c =:focusCategoryColumnId];
			if(categoryId != null && categoryId != ''){//!lstFocusCategories.isEmpty()
				isSuccessfulDelete = fcDA.deleteFocusCategory(focusCategoryColumnId, categoryId);		
				
				if (isSuccessfulDelete) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, String.format(System.Label.CSM_LBL_FC_CLMN_REFERENCE, new String[]{categoryDisplayName, editFocusCategoryColumnName})));
					
					fccDA.populateWrapperClass(fcGroupId, null, null);
					fcDA.populateWrapperClass(focusCategoryColumnId, null, null);				
				} 
							
				return null;
			}else{
				integer countFC = 0;
				List <CSM_FocusCategoryWrapper> lstFcw = getFocusCategoryList();
				if(!lstFcw.isEmpty()){
					for(CSM_FocusCategoryWrapper fcw: lstFcw){
						if(fcw.CategoryViewId ==categoryViewId &&  fcw.ColumnId ==focusCategoryColumnId ){
							fcDA.focusCategoryList.remove(countFC);
							break;	
						}
						countFC = countFC +1;
					}
				}
				return null;
			}
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
			return null;
		} 

	}
    	
	/**
	* @description Edit Focus Category Group
	*
	* @return  
	*/
	public PageReference editFocusCategory() {
		try {
			
			if (focusCategoryObjectType!=null && focusCategoryObjectType.length()>0){
				// Save Focus Category
				fcDA.saveFocusCategory();
				// Get the List View through standard page
				String filterEditPage = getFilterEditPage(categoryViewId, true, fcGroupId, focusCategoryColumnId, focusCategoryObjectType);
				// Get the page reference
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
	* 
	* @description getFocusCategoryViewList based on meta data service and set controller
	* 
	* @return list of objects from the custom setting 
	* 
	*/
    public List<SelectOption> getFocusCategoryViewList()
    {
        try
        {  
        	// Initialize list and maps 
        	List<SelectOption> fcViewList = new List<SelectOption>();
        	if (objListViews==null) {
        		objListViews = new Map<String, List<SelectOption>>();
        	}
        	
			// select option map for view id and label to be added to the grid
			if (selectOptionMap == null) {
				selectOptionMap = new Map<String, String>();
			}
			// Check if the dirty set is not set for a particular object type else get the list views from a map
        	if (objListViews.containsKey(focusCategoryObjectType)) {
        		fcViewList = objListViews.get(focusCategoryObjectType);
        		system.debug(fcViewList+'<---------------------------------------fcViewList');
        	} else {
        		// get the list view from set controller or metadata service
        		fcViewList = fcDA.setCon(focusCategoryObjectType);
        		
        		// Insert the values in option map to retrieve the label for the grid 
        		for (SelectOption opt : fcViewList){
        			selectOptionMap.put(opt.getValue(), opt.getLabel());
        		}
        		
        		// Insert the list views based on object type
        		objListViews.put(focusCategoryObjectType, fcViewList);        		
        	}
    		// remove existing items that are already in the list
    		fcViewList = removeExistingItems(fcViewList);
            return fcViewList;
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }
	   
    /**
	* 
	* @description removeExistingItems Remove existing items if it is present
	* 
	* @return list of SelectOption 
	* 
	*/
    private List<SelectOption> removeExistingItems(List<SelectOption> fcViewList) {
    	// Create a new List View items
    	List<SelectOption> fcViewListNew = new List<SelectOption>();
    	// Go through the list of SelectOption
    	for (SelectOption op : fcViewList){
    		// Get the list view that contains the view id
			if (fcDA.existingListViews.contains(op.getValue())==false){
				fcViewListNew.add(op);
			}
		}  
		return fcViewListNew;
    }
	
	public String getFilterEditPage(String val, Boolean isEdit, String pfcGroupId, String pfocusCategoryColumnId, String pfocusCategoryObjectType) {
				
		// Get current page url through page reference 
		PageReference pageRefTemp = Page.CSM_FocusColumnAndCategory;

		// Set up  current page reference with parameters
		String retURL;
		
		if (isEdit) {
			retURL = pageRefTemp.getURL() + CSM_Constants.PARAM_GROUPID + fcGroupId + '_' +focusCategoryColumnId+'_'+focusCategoryObjectType + '_' + val;
		} else {
			retURL = pageRefTemp.getURL() + CSM_Constants.PARAM_GROUPID + fcGroupId + '_' +focusCategoryColumnId+'_'+focusCategoryObjectType;
		}

		String filterEditPage = CSM_Util.getFilterEditPage(val, isEdit, retURL, pfocusCategoryObjectType);
		
		return filterEditPage;		
	}
	
	/**
	* @description Cancel Focus Categories
	*
	* @return  
	*/
	public PageReference cancelFocusCategories() {
		try {
			PageReference pageRef; 
			//if (ApexPages.currentPage().getParameters().get(CSM_Constants.ADMIN_HYPERLINK_FLAG) =='false' /* &&
		    	//CSM_Util.isUserAnSystemAdmin() != true*/) {
		        //pageRef = Page.CSM_FocusCategories;
		    //} else {
		    	//pageRef = Page.CSM_CustomerSuccessOverview;
		    //}
		    
		    if(returnURL != null)
			{
				pageRef = new PageReference(returnURL);
			}
			else
			{
				pageRef = Page.CSM_FocusCategories;
			}
		    
			pageRef.getParameters().put('tabCategory', 'Admin');
			pageRef.setRedirect(true);
			return pageRef;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
	}
}