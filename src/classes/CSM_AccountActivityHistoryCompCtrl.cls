public with sharing class CSM_AccountActivityHistoryCompCtrl {
	//public String columnList {get; set;}
	public String hiddenColumns {get; set;}
	public CSM_User_Preferences__c preferenceObj{get; set;}
	public CSM_DataGridAttribute aahDataGridAttribute {get; set;}
	public CSM_AccountActivityHistoryCompCtrl() {
		preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(), 'CSM_Success_Plan_Activity_Grid_Columns__c');
		if(preferenceObj == null) {
			preferenceObj = new CSM_User_Preferences__c();
			preferenceObj.CSM_User__c = UserInfo.getUserId();
		}
	}
	
	public String accountHistoryId
    {
    	get
    	{
    		return accountHistoryId;
    	}
    	set
    	{
    		accountHistoryId = value;
    		setGridAttribute();
    	}
    }
   
    private void setGridAttribute()
    {
    	aahDataGridAttribute = new CSM_DataGridAttribute();	
		aahDataGridAttribute.gridToolbarId = CSM_Constants.GRID_ATTR_ACCT_ACTIVITY;
		aahDataGridAttribute.tableName = CSM_Constants.OBJ_ACTIVITY_HISTORY;
		aahDataGridAttribute.objectType = CSM_Constants.OBJ_TYPE_TASK;
		aahDataGridAttribute.viewName = CSM_Constants.GRID_ATTR_ACT_HISTORY;
		aahDataGridAttribute.stateSave = CSM_Constants.GRID_ATTR_FALSE;
		aahDataGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
		aahDataGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
		aahDataGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;	
		aahDataGridAttribute.setFilterControl(CSM_Constants.GRID_ATTR_TRUE);
		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	
        if (String.isBlank(accountHistoryId))
     	{
     		gridInputParams.accountId = '';
     	}
     	else
     	{
     	    gridInputParams.accountId = accountHistoryId;
     	}
     	gridInputParams.taskOrViewId = '';
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		aahDataGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
     	aahDataGridAttribute.params = JSON.serialize(gridInputParams);      
    }

    public PageReference saveColumnsToUserPreference(){
	    try {
	    	preferenceObj.CSM_Success_Plan_Activity_Grid_Columns__c = hiddenColumns;
	    	List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    	userPreferenceList.add(preferenceObj);
	    	CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Plan_Activity_Grid_Columns__c');
	    	//system.debug('Final List:'+columnList);
	    }catch (exception ex) {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		    return null;
		}
    return null;
    }
}