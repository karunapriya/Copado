// Controller for the landing page /Tab. Helps navigating to all other standard/ custom dashboards
public with sharing class DashboardsTabController {
    public List<dbElementWrapper> leftColumnElements{get;set;}
    public List<dbElementWrapper> rightColumnElements{get;set;}
    public static String solnExtnNamespace{get; set;}
    
    public class dbElementWrapper{
        public String groupName {get;set;}
        public List<SubElementWrapper> subElements{get;set;}
        public dbElementWrapper(String groupName, List<SubElementWrapper> subElements){
            this.groupName = groupName;
            this.subElements = subElements;
        }
    }
    public class SubElementWrapper{
        public String elementName{get;set;}
        public String elementURL {get;set;}
        public String description {get;set;}
        
        public SubElementWrapper(String elementName, String elementURL, String description){
            this.elementName = elementName;
            this.elementURL = elementURL;
            this.description = description;
        }
    }
    // Map of all Dashboards in the system
    public Map<String,Id> allDashboardsMap {
        get{
            if(this.allDashboardsMap == null){
                Map<String,Id> allDBMap = new Map<String,Id>();
                List<Dashboard> lstDashboards = ReportDashboardDataAccess.getAllDashboards();
                if(lstDashboards != null) {
                    for(Dashboard db: lstDashboards){
                    	allDBMap.put(db.DeveloperName , db.Id);
                    }
                }
                allDashboardsMap = allDBMap;
            }
            return this.allDashboardsMap;
        }
        set;
    }
    
    // Map of All reports in the system
    public Map<String,Id> allReportsMap {
        get{
            if(this.allReportsMap == null) {
                Map<String,Id> allRepMap = new Map<String,Id>();
                List<Report> lstReports = ReportDashboardDataAccess.getAllReports();
                if(lstReports != null) {
                    for(Report rp: lstReports){
                    	allRepMap.put(rp.DeveloperName , rp.Id);
                    }
                }
                allReportsMap = allRepMap;
            }
            return this.allReportsMap;
        }
        set;
    }
    
    public DashboardsTabController(){
        init();
    }
    
    public pageReference init(){
        // Get all dashboard elements from the custom setting (in sequence):
        solnExtnNamespace = Util.solnExtnNameSpace;
        List<Zenith_Dashboard_Tab_Elements__c> lstDBElements = ReportDashboardDataAccess.getDashboardTabElementsByActiveFlag(true);
        // Create a map of elements by Group:
        Map<String,List<Zenith_Dashboard_Tab_Elements__c>> leftMap = new Map<String,List<Zenith_Dashboard_Tab_Elements__c>>();
        Map<String,List<Zenith_Dashboard_Tab_Elements__c>> rightMap = new Map<String,List<Zenith_Dashboard_Tab_Elements__c>>();
        for(Zenith_Dashboard_Tab_Elements__c dbe: lstDBElements){
            String mapKey = dbe.Group_Sequence__c + '';
            // Check for Display section and put in appropriate Map:
            if(dbe.Display_Section__c == 'Left'){
                if(leftMap.get(mapKey) == null){
                    leftMap.put(mapKey, new List<Zenith_Dashboard_Tab_Elements__c>());
                }
                leftMap.get(mapKey).add(dbe);
            }
            // Add more conditions here for the center section (if required)
            else {
                if(rightMap.get(mapKey) == null){
                    rightMap.put(mapKey, new List<Zenith_Dashboard_Tab_Elements__c>());
                }
                rightMap.get(mapKey).add(dbe);
            }
        }
        leftColumnElements = populateSubElements(leftMap);
        rightColumnElements = populateSubElements(rightMap);
        return null;
    }
    
    // Method to extract the Element and put those in the proper group:
    public List<DbElementWrapper> populateSubElements(Map<String,List<Zenith_Dashboard_Tab_Elements__c>> elementsMap){
        List<dbElementWrapper> columnGroup = new List<dbElementWrapper>();
        for(List<Zenith_Dashboard_Tab_Elements__c> lstEl : elementsMap.values()){
            if(lstEl != null && lstEl.size() > 0) {
                List<SubElementWrapper> lstSubElements = new List<SubElementWrapper>();
                String groupName;
                for(Zenith_Dashboard_Tab_Elements__c dbe: lstEl){
                    groupName = dbe.Group_Name__c;
                    lstSubElements.add(new SubElementWrapper(dbe.Display_Name__c, getURLFromElementType(dbe.Element_Type__c,dbe.Value__c),dbe.Description__c));
                }
                // Set to Uncategorized for no group names
                groupName = (groupName == null ? 'Uncategorized' : groupName);
                // Add the element to the outer group wrapper
                columnGroup.add(new DbElementWrapper(groupName, lstSubElements) );
            }
        }
        return columnGroup;
    }
    
    // Depending on the Element types, return the URL for navigation
    public String getURLFromElementType(String elType, String value){
        return (elType == 'Page' ? 'apex/'+ solnExtnNamespace + value : (elType == 'Dashboard' ? allDashboardsMap.get(value) : (elType == 'Report' ?allReportsMap.get(value) : (elType == 'url' ? value : ''))));
    }
}