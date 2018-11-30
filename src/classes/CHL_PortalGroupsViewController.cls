public with sharing class CHL_PortalGroupsViewController {
	public CHL_Portal_Group__c portalGroup {get; set;}
	public String helpParam {get; set;}
	private String portalGroupId{get;set;}
	public CSM_DataGridAttribute portalGroupMemGridAttribute{get;set;}
    public CHL_PortalGroupsViewController(ApexPages.StandardController stdController) {
    	portalGroupId = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_IG_ID);
    	if(String.isNotBlank(portalGroupId)) {
    		List<CHL_Portal_Group__c> portalGroupList = CHL_PortalGroupDataAccess.getPortalGroupById(new List<Id> {portalGroupId});
    		if(portalGroupList != null && !portalGroupList.isEmpty()) {
    			portalGroup = portalGroupList[0];
    		}
    		setGridAttributes();
    	}
    }
    
    public PageReference editPortalGroup() {	
    	PageReference viewPageRef = Page.CHL_PortalGroupsView;	
    	PageReference pageRef = Page.CHL_PortalGroups;
    	pageRef.getParameters().put('id',portalGroupId);
    	String rUrl = viewPageRef.getUrl();
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL, rUrl);
    	pageRef.setRedirect(true);
    	return PageRef;	
    }
    
    public PageReference returnPage() {    
		Schema.DescribeSObjectResult r = CHL_Portal_Group__c.sObjectType.getDescribe();
		String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix+'/o');
		pageRef.setRedirect(true);
    	return pageRef;
    }
    
    private void setGridAttributes(){
    	portalGroupMemGridAttribute = new CSM_DataGridAttribute();        
        portalGroupMemGridAttribute.tableName = 'portalGroupMembersView';
    	portalGroupMemGridAttribute.objectType = 'portalGroupMembersView';
    	portalGroupMemGridAttribute.viewName = 'portalGroupMembersView';
    	portalGroupMemGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
    	portalGroupMemGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	portalGroupMemGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
    	portalGroupMemGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
    	portalGroupMemGridAttribute.showExport=CSM_Constants.GRID_ATTR_TRUE;
    	portalGroupMemGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE;  
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = portalGroupId;
     	portalGroupMemGridAttribute.params = JSON.serialize(gridInputParams);
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		portalGroupMemGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());  
    }
}