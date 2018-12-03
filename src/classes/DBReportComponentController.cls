// Generic Controller class for fetching all report names and passing appropriate filters:
public with sharing class DBReportComponentController {
    // Attributes for the report:
    public String dashboardElementName {get;set;}
    public transient ProactiveProdDashboardController proactiveProdDBController {get;set;}
    public transient IndividualDashboardController individualDBController{get;set;}
    public transient ReactiveProdDashboardController reactiveProdDBController {get;set;}
    
    public String repName{get;set;}
    public String repUrl{get;set;}
    
    // Component Constructor, all processing done in getInitAll() method as constructor doesn't get attribute values on load
    public DBReportComponentController(){}

    
    // Componennt's init Method: Initializes all value from parent controller:
    // Done in this method instead of controller, because constructor doesn't get all this value during load:
    public string getInitAll(){
        // Get report Name & hyperlink:
        if(dashboardElementName != null && Zenith_Report_Urls__c.getInstance(dashboardElementName) != null){
            Zenith_Report_Urls__c reportDetail = Zenith_Report_Urls__c.getInstance(dashboardElementName);
            
            // Get report Url from the custom setting:
            Map<String,String> allReportsMap = DashboardUtil.fetchReportDetails();
            String repId = allReportsMap.get(reportDetail.Report_Unique_Name__c);
            String repFilter = reportDetail.Report_Filter__c; 
            
            // Replace the keywords with actual value in the report filter to prepare the final url
            if(repFilter != null) {
                
                // At a time only one parent controller can be active. Take all the filter values from that particular parent:
                if(proactiveProdDBController != null) {
                    repFilter = repFilter.replace('#THEATRE#',proactiveProdDBController.theatreFilter);
                    repFilter = repFilter.replace('#BUSINESS#',proactiveProdDBController.businessLineFilter);
                    repFilter = repFilter.replace('#TERRITORY#',proactiveProdDBController.territoryFilter);
                    repFilter = repFilter.replace('#REGION#',proactiveProdDBController.regionFilter);
                    repFilter = repFilter.replace('#OPPTYPE#',proactiveProdDBController.opportunityTypeFilter);
                    repFilter = repFilter.replace('#STARTDATE#',proactiveProdDBController.startDateFilter);
                    repFilter = repFilter.replace('#ENDDATE#',proactiveProdDBController.endDateFilter);
                }
                // Replace for reactive Producion DB filters
                if(reactiveProdDBController != null) {
                    repFilter = repFilter.replace('#THEATRE#',reactiveProdDBController.theatreFilter);
                    repFilter = repFilter.replace('#BUSINESS#',reactiveProdDBController.businessLineFilter);
                    repFilter = repFilter.replace('#TERRITORY#',reactiveProdDBController.territoryFilter);
                    repFilter = repFilter.replace('#REGION#',reactiveProdDBController.regionFilter);
                    repFilter = repFilter.replace('#OPPTYPE#',reactiveProdDBController.opportunityTypeFilter);
                    repFilter = repFilter.replace('#STARTDATE#',reactiveProdDBController.startDateFilter);
                    repFilter = repFilter.replace('#ENDDATE#',reactiveProdDBController.endDateFilter);
                    repFilter = repFilter.replace('#USERNAME#',reactiveProdDBController.runAsUserFilter);
                }
                // Replace for Individual DB filters
                if(individualDBController != null) {
                    repFilter = repFilter.replace('#THEATRE#',individualDBController.theatreFilter);
                    repFilter = repFilter.replace('#BUSINESS#',individualDBController.businessLineFilter);
                    repFilter = repFilter.replace('#TERRITORY#',individualDBController.territoryFilter);
                    repFilter = repFilter.replace('#REGION#',individualDBController.regionFilter);
                    repFilter = repFilter.replace('#OPPTYPE#',individualDBController.opportunityTypeFilter);
                    repFilter = repFilter.replace('#STARTDATE#',individualDBController.startDateFilter);
                    repFilter = repFilter.replace('#ENDDATE#',individualDBController.endDateFilter);
                    repFilter = repFilter.replace('#USERNAME#',individualDBController.runAsUserFilter);
                }
            }
            
            // Values to be used in the component for redirection:
            repName = reportDetail.Report_Name__c;
            repUrl = (repId != null ? repId : '') + (repFilter != null ? repFilter : '');
        }
        return null;
    }
}