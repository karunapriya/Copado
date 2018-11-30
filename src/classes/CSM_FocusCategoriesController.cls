/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.18.2014
* @description    CSM_FocusCategories class contains methods for supporting the UI  
*/
public with sharing class CSM_FocusCategoriesController  {

	public String focusCategoryGroupName {get; set;}
	public String focusCategoryGroupType {get; set;}
	public String focusCategoryId {get; set;}
	public Integer focusCategoryGroupUniqueId {get; set;}
	public Boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public Boolean theLinksAreVisible {get; private set;}
	public String helpParam {get; set;} 
	public String tabCategory {get; set;} 
	
	private CSM_FocusCategoriesGroupDataAccess fcDA = new CSM_FocusCategoriesGroupDataAccess();
	private List<SelectOption> focusCategoryGroupTypes {get; set;}

	/**
	* @description FocusCategoryGroupList
	*
	* @return List<CSM_FocusCategoryGroupWrapper> 
	*/
	public List<CSM_FocusCategoryGroupWrapper> getFocusCategoryGroupList() {
		return fcDA.focusCategoryGroupList;
	}

	/**
	* @description Constructor
	*
	* @return null 
	*/
	public CSM_FocusCategoriesController() { 
		system.debug('EnteredController');
		this.theLinksAreVisible = true;
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
       	helpParam = CSM_Constants.HELP_FOCUS_CATEGORY_GROUPS;
		if (ApexPages.currentPage().getParameters().get(CSM_Constants.ADMIN_HYPERLINK_FLAG) =='false' 
		&& (!hasCSMAccess && !hasRenewAccess)) {
			this.theLinksAreVisible =false;  
		}
		
		focusCategoryGroupTypes = new List<SelectOption>();
		
		// Retrieve focus category Groups 
		fcDA.populateWrapperClass();
		// Check CSM Access
	}

	/**
	* @description Gets a list of Focus Category Groups
	*
	* @return  
	*/
	public List<SelectOption> getFocusCategoryGroups() {
        List<SelectOption> focusCategoryGroups = new List<SelectOption>();
        focusCategoryGroups.add(new SelectOption(Label.CSM_VAL_NONE,Label.CSM_VAL_NONE));
        return focusCategoryGroups;
	}
	
	
		/*Added for US315 to delete the Focus Category Group*/
	public PageReference deleteFocusCategoryGroup() {
		if(!String.isBlank(focusCategoryId)){
			List<CSM_Focus_Category_Group__c> fcgList = new List<CSM_Focus_Category_Group__c>();
			CSM_Focus_Category_Group__c fcg = new CSM_Focus_Category_Group__c(Id = focusCategoryId);
			fcgList.add(fcg); 
			CSM_FocusCategoriesGroupDataAccess.deleteFocusCategoryGroup(fcgList);
		}
		fcDA.populateWrapperClass();
		
		if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_FCG_DELETE));	
		}
		
		return null;	
	}

	/**
	* @description Gets a list of Focus Category Groups
	*
	* @return  
	*/
	public List<SelectOption> getFocusCategoryGroupTypes() {
		if (focusCategoryGroupTypes.IsEmpty()){
	        focusCategoryGroupTypes.add(new SelectOption(Label.CSM_VAL_MAIN,Label.CSM_VAL_MAIN));
	        if (fcDA.hasTiles != null && !fcDA.hasTiles){
				focusCategoryGroupTypes.add(new SelectOption(Label.CSM_VAL_TILES,Label.CSM_VAL_TILES));
	        }
		}
        return focusCategoryGroupTypes;
	}

	/**
	* @description Edit Focus Category Group
	*
	* @return  
	*/
	public PageReference editFocusCategoryGroup() {
		try {
			String fcGroupId = fcDA.saveAndRetrieveId(focusCategoryGroupUniqueId);
			PageReference pageRef = Page.CSM_FocusColumnAndCategory;
			pageRef.getParameters().put(CSM_Constants.ADMIN_HYPERLINK_FLAG,'false');
			pageRef.getParameters().put(CSM_Constants.OBJ_FCG_GROUPID, fcGroupId);
	        pageRef.setRedirect(true);
	        return pageRef;
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
	* @return  
	*/
	public PageReference createNewFocusCategoryGroup() {
		try {
			if (focusCategoryGroupName!=null && focusCategoryGroupName.trim().length()>0) {
				if (focusCategoryGroupType == Label.CSM_VAL_TILES){
					focusCategoryGroupTypes.remove(1);
				}
	
				fcDA.createFocusCategoryGroup(focusCategoryGroupName, focusCategoryGroupType);
				focusCategoryGroupName = '';
				focusCategoryGroupType = Label.CSM_VAL_MAIN;
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.CSM_GROUP_NAME));
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
	* @description Save Focus Categories
	*
	* @return  
	*/
	public PageReference saveFocusCategories() {
		try {
			fcDA.saveFocusCategoryGroup();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_SAVED_CATEGORY_GROUP));
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
		return null;
	}
	
	
	/**
	* @description Cancel Focus Categories
	*
	* @return  
	*/
	public PageReference cancelFocusCategories() {
		try {
			PageReference pageRef;
			if (ApexPages.currentPage().getParameters().get(CSM_Constants.ADMIN_HYPERLINK_FLAG) =='false' /*&&
		    	CSM_Util.isUserAnSystemAdmin() != true*/) {
		        pageRef = Page.CSM_CustomerSuccessOverview;
		    } else {
			    pageRef = Page.CSM_FocusCategories;
		    }
		    pageRef.getParameters().put('tabCategory', 'Admin');
			pageRef.setRedirect(true);
			return pageRef;
		}
    	catch (exception ex) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
	}  
	
   /**
	* @description Clone Focus Category Group
	*
	* @return  PageReference to csm_focuscategories page
	*/
	public PageReference cloneFocusCategoryGroup() {
		try {
			List<CSM_Focus_Category_Group__c> focusCategoryGroupList = fcDA.cloneFocusCategoryGroup(new String[]{focusCategoryId});
			
			if (!focusCategoryGroupList.isEmpty()) {
				List<CSM_Focus_Category_Column__c> focusCategoryColumnList = fcDA.cloneFocusCategoryColumn(focusCategoryGroupList, new String[]{focusCategoryId});
				CSM_FocusCategoriesGroupService.cloneFocusCategory(focusCategoryColumnList); 
			}
			PageReference pageRef = page.csm_focuscategories;
			pageRef.getParameters().put('tabCategory', 'Admin');
			pageRef.setRedirect(true); 
			return pageRef;
    	}
    	catch (exception ex) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
   	}
}