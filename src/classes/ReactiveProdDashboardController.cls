// Controller for Reactive Dashboard page
global with sharing class ReactiveProdDashboardController {

    // Variables for showing data on the page
    public transient Map<String,grandSummaryCaseTypeWrapper> grandSummary {get;set;}
    // Variable to display message when date filters are not applied
    public Boolean currentFiscalYearDataOnlyFlag {get;set;}
    public ReactiveProdDashboardController parentController{get {return this;} set;}

    // Dashboard Filter picklists
    public List<SelectOption> theatres {get;set;}
    public List<SelectOption> businessLines {get;set;}
    public List<SelectOption> opportunityTypes {get;set;}
    public List<SelectOption> regions {get;set;}
    public List<SelectOption> territoris {get;set;}

    // Overall Dashboard Filters
    public String startDate {get;set;}
    public String endDate {get;set;}
    public String selectedTheatre{get;set;}
    public String selectedBusinessLine{get;set;}
    public String selectedTerritory{get;set;}
    public String selectedRegion{get;set;}
    public String selectedOpportunityType{get;set;}
    public String selectedUser {get;set;}
    
    // Filters for the reports:
    public String theatreFilter {get;set;}
    public String businessLineFilter {get;set;}
    public String territoryFilter {get;set;}
    public String regionFilter {get;set;}
    public String opportunityTypeFilter {get;set;}
    public String startDateFilter {get;set;}
    public String endDateFilter {get;set;}
    public String runAsUserFilter {get;set;}
    
    private Map<Id,User> subOrdinateUsers {get;set;}

    // By Default set the filter condition to Current quarter (unless a date filter is applied)
    public String filterConditions {get;set;}

    // Case record's priority values, Each one of these groups should exist in the dashboard
    private static Set<String> casePriorityValues = new Set<String>{'High','Normal','Low'};
    private static Set<String> caseRecordTypesToExclude = new Set<String>{'Master','Opportunity Creation Request'};

    // Flag to determine if any user filter has been applied. Used to navigate to different(Overall/User specific) version of the reports
    public Boolean singleUserReport{ get{ return (selectedUser != null && selectedUser != '' && selectedUser != 'All');} set;}
    // String acting as the place holder for summary matrix, when passed, sets the summary matrix value to be displayed in the page:
    public String grandSummaryPlaceholder{get;set{if(value != null){    grandSummary = (Map<String,GrandSummaryCaseTypeWrapper>)JSON.deserialize(value, Map<String,GrandSummaryCaseTypeWrapper>.class);}}}

    // List of users to be displayed as the selectable picklist
    public List<SelectOption> availableUsers {
        get {
            if(this.availableUsers == null) {
                this.availableUsers = new List<SelectOption>();
                // Add the 'All' option for selecting all users:
                this.availableUsers.add(new SelectOption('All','All'));
                if(subOrdinateUsers != null){
                    for(User usr: subOrdinateUsers.values()) {
                        this.availableUsers.add(new SelectOption(usr.Id,usr.Name));
                    }
                }
            }
            return this.availableUsers;
        }
        set;
    }
    
    // Dashboard element specific conditions specified here:
    private Map<String,String> queryConditionByDataSetKey = new Map<String,String> {
            'QuoteRequest' => ' AND Case.RecordType.DeveloperName =\'Quote_Request\' AND Case.Sub_Case_Type__c IN (\'New\',\'Revision\',\'Correction\') ',
            'QuoteNew' => ' AND Case.RecordType.DeveloperName =\'Quote_Request\' AND Case.Sub_Case_Type__c =\'New\' ',
            'QuoteRevision' => ' AND Case.RecordType.DeveloperName =\'Quote_Request\' AND Case.Sub_Case_Type__c =\'Revision\' ',
            'QuoteCorrection' => ' AND Case.RecordType.DeveloperName =\'Quote_Request\' AND Case.Sub_Case_Type__c =\'Correction\' ',
            'BookingRequest' => ' AND Case.RecordType.DeveloperName =\'Booking_Request\' AND Case.Sub_Case_Type__c IN (\'New\',\'Revision\',\'Correction\',\'Cancel Conversion\',\'MYA\',\'CBR\',\'Standard\') ',
            'BookingNew' => ' AND Case.RecordType.DeveloperName =\'Booking_Request\' AND Case.Sub_Case_Type__c =\'New\' ',
            'BookingRevision'=> ' AND Case.RecordType.DeveloperName =\'Booking_Request\' AND Case.Sub_Case_Type__c =\'Revision\' ',
            'BookingCorrection' => ' AND Case.RecordType.DeveloperName =\'Booking_Request\' AND Case.Sub_Case_Type__c =\'Correction\' ',
            'DataUpdateRequest' => ' AND Case.RecordType.DeveloperName =\'Data_Update_Request\' ',
            'DataProcessingRequest' => ' AND Case.RecordType.DeveloperName =\'Data_Processing_Request\' ',
            'LeadSubmission' => ' AND Case.RecordType.DeveloperName =\'Lead_Submission\' ',
            'ReportingRequest' => ' AND Case.RecordType.DeveloperName =\'Reporting_Request\' ',
            'ReviewRequest' => ' AND Case.RecordType.DeveloperName =\'Review_Request\' '
    };
    

    // Variables for priority level grouping of Grand summary table
    global class GrandSummaryPriorityWrapper{
        public Integer SLA {get;set;}
        public Decimal averageSLA{get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        public Integer totalCount {get;set;}
        public Integer totalCountCompliant{get;set;}        
        public GrandSummaryPriorityWrapper(){
            this.SLA = 0;
            this.averageSLA= 0;
            this.slaAdherence = 0;
            this.slaCompliance = 0;
            this.totalCount = 0;
            this.totalCountCompliant= 0;
        }
    }
    
    // Variables for case recor type level grouping of Grand summary table
    global class GrandSummaryCaseTypeWrapper{
        public Integer SLA {get;set;}
        public Decimal averageSLA{get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        public Integer totalCount {get;set;}
        public Integer totalCountCompliant{get;set;}
        public Map<String,GrandSummaryPriorityWrapper> prioritiesMap{get;set;}
        
        public GrandSummaryCaseTypeWrapper(){
            this.SLA = 0;
            this.averageSLA= 0;
            this.slaAdherence = 0;
            this.slaCompliance = 0;
            this.totalCount = 0;
            this.totalCountCompliant= 0;
            prioritiesMap = new Map<String,GrandSummaryPriorityWrapper>();
        }
    }
    

    // Constructor to set default picklist values
    public ReactiveProdDashboardController(){
        init();
    }

    // This method is just a place holder for setting the values (which came from the remote action call) into the wrapper of this controller
    public void updateValues(){}

    // From the dataset key, fetch the query for specific dashboard element (used by the components)
    public String getQueryCondition(String dataSetKey){
        return queryConditionByDataSetKey.get(dataSetKey);
    }

    // Init Method to prepare the data for all dashboard components
    public pageReference init(){
        // Initialize the filed filter pickilst values:
        String nameSpace = Util.solnExtnNameSpace;
        currentFiscalYearDataOnlyFlag = true;
        theatres = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'SSI_Theatre__c','None');
        businessLines = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Business_Line__c','None');
        opportunityTypes = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Opportunity_Type__c','None');
        regions = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Client_Region__c','None');
        territoris = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Client_Territory__c','None');
        // Fetch all available users:
        subOrdinateUsers = DashboardUtil.getRoleSubordinateUsers();
        
        // On page load, set the basic values for the filters:
        resetFilters();
        return null;
    }

    // Initialize or reset all variables to their default values
    public void resetFilters(){
        // Reset all filters and set the filter condition to current fiscal year:
        selectedTheatre = null;
        selectedBusinessLine = null;
        selectedTerritory = null;
        selectedRegion = null;
        selectedOpportunityType = null;
        startDate = null;
        endDate = null;
        // Set to all users by default
        selectedUser = 'All';
    
        // Set the filter condition to fetch data from this calendar quarter only
        filterConditions = ' AND Case.ClosedDate = THIS_QUARTER ';
            
        // Set the pv parameters for report:
        theatreFilter = DashboardUtil.concatenateAllOptions(theatres);
        businessLineFilter = DashboardUtil.concatenateAllOptions(businessLines);
        territoryFilter = DashboardUtil.concatenateAllOptions(territoris);
        regionFilter = DashboardUtil.concatenateAllOptions(regions);
        opportunityTypeFilter = DashboardUtil.concatenateAllOptions(opportunityTypes);
        startDateFilter = 'THIS_QUARTER';
        endDateFilter = 'THIS_QUARTER';
        runAsUserFilter = UserInfo.getName();
        
        // After resetting the filters, fetch all the data
        //prepareDashboardData();
    }

    // Based on the parameters selected on the page, create the filter segments for the dynamic query & Set filter parameters for reporting
    public pageReference filterData() {
        // Ensure User enters both Start & End dates:
        if((startDate != null && startDate !='' && (endDate == null ||endDate == '')) || ((startDate == null ||startDate == '') && endDate != null && endDate != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.BothStartAndEndDateRequired));
            return null;
        }
    
        filterConditions ='';
        // If any value is selected for Theatre picklist then add it to the filter conditions & set the report filter
        if(selectedTheatre != null && selectedTheatre != 'None'){
            filterConditions += ' AND Case.SSI_Theatre__c = \'' + selectedTheatre +'\' ';
            // Set theatreFilter for filtering in the report
            theatreFilter = selectedTheatre;
        }
        // If any value is selected for Business pickllist, then  add it to the filter conditions & set the report filter
        if(selectedBusinessLine != null && selectedBusinessLine != 'None'){
            filterConditions += ' AND Case.Business_Line__c = \'' + selectedBusinessLine +'\' ';
            // Set businessLineFilter for filtering in the report
            businessLineFilter = selectedBusinessLine;
        }
        // If any value is selected for Territory picklist then add it to the filter conditions & set the report filter
        if(selectedTerritory != null && selectedTerritory != 'None'){
            filterConditions += ' AND Case.Client_Territory__c = \'' + selectedTerritory +'\' ';
            // Set theatreFilter for filtering in the report
            territoryFilter = selectedTerritory;
        }
        // If any value is selected for Region picklist then add it to the filter conditions & set the report filter
        if(selectedRegion != null && selectedRegion != 'None'){
            filterConditions += ' AND Case.Client_Region__c = \'' + selectedRegion +'\' ';
            // Set theatreFilter for filtering in the report
            regionFilter = selectedRegion;
        }
        // If any value is selected for Opportunity Type picklist then add it to the filter conditions & set the report filter
        if(selectedOpportunityType != null && selectedOpportunityType != 'None'){
            filterConditions += ' AND Case.Opportunity_Type__c = \'' + selectedOpportunityType +'\' ';
            // Set theatreFilter for filtering in the report
            opportunityTypeFilter = selectedOpportunityType;
        }

        // If both Start & End dates are applied, then add to the query for filtering & set the report filter
        if(startDate != null && startDate != ''){
            // Set the current fiscal year flag to false to omit the message at page level
            currentFiscalYearDataOnlyFlag = false;
            // If any invalid date string is passed, ignore it and do not add in the filters
            try{
                Date stDt = Date.parse(startDate);
                filterConditions += ' AND Case.ClosedDate >= ' + String.valueOf(stDt) +'T00:00:00Z ';
                // Set date filter for filtering in the report
                startDateFilter = startDate;
            } catch(exception e){}
        }
        if(endDate != null && endDate != '' ){
            currentFiscalYearDataOnlyFlag = false;
            // If any invalid date string is passed, ignore it and do not add in the filters
            try{
                Date endDt = Date.parse(endDate);
                filterConditions += ' AND Case.ClosedDate <= ' + String.valueOf(endDt) +'T23:59:59Z ';
                // Set date filter for filtering in the report
                endDateFilter = endDate;
            } catch(exception e){}
        }
        
        // Only applicable for Individual dashboard: If any manager user selects any other user than him/her, add the user filter to condition
        if(selectedUser != null && selectedUser != '' && selectedUser != 'All') {
            filterConditions += ' AND Case.OwnerId = \''+selectedUser+'\' ';
            // Set user filter for filtering in the report (if not found, set to current user:
            runAsUserFilter = (subOrdinateUsers.get(selectedUser) != null ? subOrdinateUsers.get(selectedUser).Name : UserInfo.getName());
        }
        
        
        // If no date Filters are applied, show current Fiscal Year data (to reduce data volume)
        if((startDate == null || startDate == '') && (endDate == null || endDate == '')) {
            currentFiscalYearDataOnlyFlag = true;
            filterConditions += ' AND Case.ClosedDate = THIS_QUARTER ';
        }
        // After applying filters get the case records again
        //prepareDashboardData();
        return null;
    }
    
    
    // Remote action method to get the grand summary data
    // Record type filter and page level filters are passed in aditionalFilterConditions variable from the page
    @RemoteAction @ReadOnly
    global static Map<String,GrandSummaryCaseTypeWrapper> fetchGrandSummaryData(String aditionalFilterConditions){
        Map<String,GrandSummaryCaseTypeWrapper> grandSummary = new Map<String,GrandSummaryCaseTypeWrapper>();
        //overallWrapperData oData = new overallWrapperData();
        // Fetch the metrics for User level grouping:
        List<AggregateResult> lsUserGroupData = MilestoneDataAccess.getDynamicCaseMilestoneWithType(
            aditionalFilterConditions,  caseRecordTypesToExclude);
        // From the Priority level aggregate results, fill the priority level columns details of the dashboard element:
        if(lsUserGroupData != null && lsUserGroupData.size() > 0 ){  
            for(AggregateResult agr: lsUserGroupData){
                String priority = String.valueOf(agr.get('priority'));
                String caseType = String.valueOf(agr.get('caseType'));
                
                // Get the aggregate values from the query
                Integer recordCount = ( agr.get('recordCount') == null ? 0 : Integer.valueOf(agr.get('recordCount')) );
                Integer compliantCount = ( agr.get('compliantCount') == null ? 0 : Integer.valueOf(agr.get('compliantCount')) );
                Integer totalTargetSLA = (agr.get('totalTargetSLA') != null ? Integer.valueOf(agr.get('totalTargetSLA')) : 0);
                Decimal totalSLA = (agr.get('totalSLA') != null ? Double.valueOf(agr.get('totalSLA')) : 0);
                
                GrandSummaryPriorityWrapper gspw = new GrandSummaryPriorityWrapper();
                gspw.totalCount = recordCount;
                gspw.totalCountCompliant = compliantCount;
                // Calculate the average SLA & TargetSLA (averages)
                gspw.SLA = (recordCount == 0 ? 0 :  Math.round(totalTargetSLA / recordCount)  );
                gspw.averageSLA = (recordCount == 0 ? 0 :  totalSLA / recordCount  );
                // Findout the priority level level SLA Adherence from SLA & Average SLA
                gspw.slaAdherence = ((gspw.SLA == null || gspw.SLA == 0) ? 0 : ((gspw.SLA - gspw.averageSLA) / gspw.SLA * 100).setScale(2));
                // Priority level SLA compliance % = Number of Compliant records / Total records * 100;
                gspw.slaCompliance = ( gspw.totalCount == 0 ? 0 : Math.Round(((Decimal)gspw.totalCountCompliant / gspw.totalCount) * 100) );
                
                // Check if the case Record type key already exists in the map or not
                if(grandSummary.get(caseType) == null){
                    grandSummary.put(caseType , new GrandSummaryCaseTypeWrapper());
                }
                // Add the newly calculated priority wrapper details to the map:
                grandSummary.get(caseType).prioritiesMap.put(priority,gspw);
            }
            
            // After the priority level values are filled, populate the Case record type level values (summary of these priorities)
            for(GrandSummaryCaseTypeWrapper gsctw : grandSummary.values()) {
                Decimal totalCaseTypeTargetSLA = 0, totalCaseTypeAvgSLA = 0;
                // Get the prioirties map:
                for(GrandSummaryPriorityWrapper pw : gsctw.prioritiesMap.values()) {
                    // Increment the case type level values:
                    gsctw.totalCount += pw.totalCount;
                    gsctw.totalCountCompliant += pw.totalCountCompliant;
                    totalCaseTypeTargetSLA += (pw.totalCount * pw.SLA);
                    totalCaseTypeAvgSLA += (pw.totalCount * pw.averageSLA);
                }
                // Check if all the priority groups (High/Normal/Low) exists or not. If doesn't exist, set default values (0 for all columns)
                for(String prio : casePriorityValues){
                    if(gsctw.prioritiesMap.get(prio) == null){
                        gsctw.prioritiesMap.put(prio,new GrandSummaryPriorityWrapper());
                    }
                }
                
                // Findout the average at Owner Office Level:
                // Calculate the average SLA & TargetSLA (average values from the total and the total record counts)
                gsctw.SLA = (gsctw.totalCount == 0 ? 0 :  Math.round(totalCaseTypeTargetSLA / gsctw.totalCount)  );
                gsctw.averageSLA = (gsctw.totalCount == 0 ? 0 :  totalCaseTypeAvgSLA / gsctw.totalCount  );
                // Findout the OwnerOffice level level SLA Adherence from SLA & Average SLA
                gsctw.slaAdherence = ((gsctw.SLA == null || gsctw.SLA == 0) ? 0 : ((gsctw.SLA - gsctw.averageSLA) / gsctw.SLA * 100).setScale(2));
                // OwnerOffice level SLA compliance % = Number of Compliant records / Total records * 100;
                gsctw.slaCompliance = ( gsctw.totalCount == 0 ? 0 : Math.Round(((Decimal)gsctw.totalCountCompliant / gsctw.totalCount) * 100) );
            }
                    
        }
        return grandSummary;
    }
}