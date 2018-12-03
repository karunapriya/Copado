/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/29/2016
 * @description  Reports and Dashboards Data Access class
 */
public with sharing class ReportDashboardDataAccess
{
	/**
    * @description : This method returns a list of all dashboards
    * @return a list of all dashboards
    */
	public static List<Dashboard> getAllDashboards(){
		Util.checkCRUD_FLS('Dashboard', new List<String> {'DeveloperName'}, Constants.DML_OPERATION_READ);
		return [SELECT Id, DeveloperName FROM Dashboard LIMIT 9999];
	}
	
	/**
    * @description : This method returns a list of all reports
    * @return a list of all reports
    */
	public static List<Report> getAllReports()	{
		Util.checkCRUD_FLS('Report', new List<String> {'DeveloperName'}, Constants.DML_OPERATION_READ);
		return [SELECT Id, DeveloperName FROM Report LIMIT 9999];
	}
	
	/**
    * @description : This method returns a list of active or inactive zenith dashboard tab elements
    * @param active flag
    * @return a list of zenith dashboard tab elements
    */
    public static List<Zenith_Dashboard_Tab_Elements__c> getDashboardTabElementsByActiveFlag(Boolean activeFlag){
    	String namespace = Util.solnExtnNameSpace;
    	List<String> dashboardTabFieldList = new List<String> {namespace + 'Element_Type__c',
            namespace + 'Display_Name__c',namespace + 'Value__c', namespace + 'Display_Section__c',
            namespace + 'Group_Name__c', namespace + 'Description__c', namespace + 'Group_Sequence__c',
            namespace + 'Active__c', namespace + 'Element_Sequence__c'};
    	Util.checkCRUD_FLS('Zenith_Dashboard_Tab_Elements__c', dashboardTabFieldList, Constants.DML_OPERATION_READ);
	    return [SELECT Id,Element_Type__c,Display_Name__c,Value__c,Display_Section__c, 
		               Group_Name__c, Description__c, Group_Sequence__c 
		          FROM Zenith_Dashboard_Tab_Elements__c 
		         WHERE Active__c = :activeFlag 
		      ORDER BY Group_Sequence__c,Element_Sequence__c NULLS LAST];
	}
	
	/**
    * @description : This method returns a list of reports by developer name
    * @param developer names
    * @return a list of reports
    */
    public static List<Report> getReportsByDeveloperName(Set<String> setReportDevloperNames){
    	Util.checkCRUD_FLS('Report', new List<String> {'DeveloperName'}, Constants.DML_OPERATION_READ);
	    return [SELECT Id, DeveloperName FROM Report WHERE DeveloperName IN :setReportDevloperNames LIMIT 9999];
	}
}