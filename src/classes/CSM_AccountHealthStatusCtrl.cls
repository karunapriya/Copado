/** 
 * @author      Mike Faust(mike@comitydesigns.com)
 * @date        09.12.2014
 * @description CSM_AccountHealthStatusCtrl for Account health Status page
 */

public with sharing class CSM_AccountHealthStatusCtrl extends CSM_CustomPaginator{
    
    public boolean hasCSMAccess {get; private set;}
    public boolean hasRenewAccess {get; private set;}
    public String helpParam {get; set;}
    public String displayHealth {get; set;}
    public String dateRange {get; set;}
    public String gridParam {get; set;}
    
    public CSM_DataGridAttribute healthStatusGridAttribute {get; set;}
    
    /**
     * @description controller
     */
    public CSM_AccountHealthStatusCtrl() {
    	//Default value
        helpParam = CSM_Constants.HELP_HEALTH_DONUT;
        hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
        String healthStatus = ApexPages.currentPage().getParameters().get(CSM_Constants.STATUS_PARAM);
        dateRange = ApexPages.currentPage().getParameters().get(CSM_Constants.RANGE_DATE_PARAM);
        String attrFieldName = ApexPages.currentPage().getParameters().get(CSM_Constants.USER_PREF_FIELD_NAME);
        String attrFieldType = ApexPages.currentPage().getParameters().get(CSM_Constants.USER_PREF_FIELD_TYPE);
        String attrFieldValue = ApexPages.currentPage().getParameters().get(CSM_Constants.USER_PREF_FIELD_VALUE);
        String attrObjectType = ApexPages.currentPage().getParameters().get(CSM_Constants.USER_PREF_OBJECT_TYPE);
        //String attrSPAccountIdsArray = ApexPages.currentPage().getParameters().get(CSM_Constants.USER_SP_ACCT_ARRAY);
        if(String.isNotBlank(attrFieldValue) && attrFieldValue.equalsIgnoreCase('UserLookupField')){
        	attrFieldValue = null;
        }
        displayHealth = healthStatus;
        //Set help param if heat map
        if(!String.isEmpty(dateRange))
        {
        	helpParam = CSM_Constants.HELP_HEALTH_MAP;
        }
        //populateAccountPlanInfoFilter(healthStatus, attrFieldName, attrFieldType, attrFieldValue, attrObjectType, attrSPAccountIdsArray);

        populateAccountPlanInfoFilter(healthStatus, attrFieldName, attrFieldType, attrFieldValue, attrObjectType);
        populateHelathStatusGridAttribute(healthStatus, attrFieldName, attrFieldType,  attrFieldValue, attrObjectType);
    }
    
    private void populateHelathStatusGridAttribute(String healthStatus, String attrFieldName,
        String attrFieldType, String attrFieldValue, String attrObjectType)
    {
    	healthStatusGridAttribute = new CSM_DataGridAttribute();
    	healthStatusGridAttribute.tableName=CSM_Constants.GRID_ATTR_HEALTH_STATUS_TBL;
    	healthStatusGridAttribute.objectType=CSM_Constants.OBJ_TYPE_ACCOUNT;
        healthStatusGridAttribute.viewName=CSM_Constants.GRID_ATTR_HEALTH_STATUS_VIEW;
       
    	healthStatusGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_HEALTH_STATUS_TOOLBAR;
    	healthStatusGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE; 
    	healthStatusGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE; 
    	healthStatusGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
    	 
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        gridInputParams.dateRange = dateRange;
        if(healthStatus == CSM_Constants.OBJ_A_UNDETERMINED)
        {
            healthStatus = null;
        }  
        gridInputParams.healthStatus = healthStatus;
        
    	CSM_UserPreferencesFilterWrapper userWrapper = new CSM_UserPreferencesFilterWrapper();
		if(attrObjectType != null && attrObjectType.toUpperCase() != 'TASK'){
        	userWrapper.attrFieldName = attrFieldName;
        	userWrapper.attrFieldType = attrFieldType;
        	userWrapper.attrFieldValue = attrFieldValue;
        	userWrapper.attObjectType = attrObjectType;
		}        	
    	
    	gridInputParams.userPrefWrapper = userWrapper;
    	gridParam = JSON.serialize(gridInputParams);  
    	healthStatusGridAttribute.params =JSON.serialize(gridInputParams);     
    }
    
   /* public List<Account> getAccountResults() {
    	return (List<Account>) this.getResults();
    }*/
    
    public void populateAccountPlanInfo(String healthStatus) {
     
    }
    public void populateAccountPlanInfoFilter(String healthStatus, String attrFieldName, String attrFieldType, String attrFieldValue, String attrObjectType) {
        if(!String.isBlank(healthStatus))
        {
            if(healthStatus == CSM_Constants.OBJ_A_UNDETERMINED)
            {
                healthStatus = null;
            }       
            
            //Build display message
            if (dateRange != null)
            {
	            if (dateRange == CSM_Constants.MORE_THAN_121)
	            {
	                displayHealth = displayHealth + ' - 121+ '+ Label.CSM_LBL_DAYS;
	            }
	            else if (dateRange == CSM_Constants.BETWEEN_91_120)
	            {
	                displayHealth = displayHealth + ' 91 - 120 '+ Label.CSM_LBL_DAYS;
	            }
	            else if (dateRange == CSM_Constants.BETWEEN_61_90)
	            {
	                displayHealth = displayHealth + ' 61 - 90 '+ Label.CSM_LBL_DAYS;
	            }
	            else if (dateRange == CSM_Constants.BETWEEN_31_60)
	            {
	                 displayHealth = displayHealth + ' 31 - 60 '+ Label.CSM_LBL_DAYS;
	            }
	            else if (dateRange == CSM_Constants.BETWEEN_0_30)
	            {
	                displayHealth = displayHealth + ' 0 - 30 '+ Label.CSM_LBL_DAYS;
	            }
	            else 
	            {
	                displayHealth = displayHealth + ' - ' + Label.CSM_LBL_NO_HEALTH_CHECK;
	            }
            }
        }
    }
    
    
    /**
     * @description builds account heatlh wrapper with accounts that match criteria
     */
    public void populateAccountPlanInfo(String healthStatus, String attrFieldName, String attrFieldType, String attrFieldValue) {
    	
    }
    
    /**
     * @description back button to return back to customer success overview page
     * @return PageReference
     */
    public PageReference returnPage() {
        
        PageReference pageRef = Page.CSM_CustomerSuccessOverview;
        pageRef.setRedirect(true);
        return pageRef;
    }
}