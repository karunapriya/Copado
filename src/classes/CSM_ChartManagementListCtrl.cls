public with sharing class CSM_ChartManagementListCtrl {
	
	public List<CSM_Chart_Management__c> chartMgmtList {get; set;}
	public String chartIdSelected {get; set;}
	public boolean hasCSMAccess {get; set;}
	public Boolean hasRenewAccess {get; private set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	 
	
	public CSM_ChartManagementListCtrl() { 
		chartMgmtList = new List<CSM_Chart_Management__c>();
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
        chartMgmtList = CSM_ChartManagementDataAccess.getCharts(true);
	}
	
	public PageReference editChart() {
		PageReference pageRef = Page.CSM_ChartManagement;
		pageRef.getParameters().put('id',chartIdSelected);
		pageRef.getParameters().put('tabCategory', 'Admin');
		pageRef.setRedirect(true);
		return pageRef;
		
	}

}