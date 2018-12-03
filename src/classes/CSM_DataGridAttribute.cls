public with sharing class CSM_DataGridAttribute {
    public String tableName {get;set;}
    public String objectType {get;set;}
    public String viewName {get;set;}
    public String gridToolbarId {get;set;}
    public String hasSearch {get;set;}
    public String hasShowColumns {get;set;}
    public String showExport {get;set;}
    public String showGlobalSelect {get;set;}
    public String clickDataToSelect {get;set;}
    public String stateSave {get;set;}
    public String stateLoad {get;set;}
    public Integer gridSize {get;set;}
    public String gridSearchText {get;set;}
    public String params {get;set;}
    public String userDateFormat {get;set;}
    
    private String filterControl='false';
   
    public String getFilterControl(){
    	return filterControl;
    }
    public void setFilterControl(String filterVal){
    	filterControl = filterVal;
    }
}