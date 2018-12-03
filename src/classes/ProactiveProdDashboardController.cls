// Controller class for Proactive Production Dashboard (both Overall & with Date)
// The Dashboard elements are fetched using remote action methods to avoid hitting the max row limit
// Once they fetch the data via the remote action methods, they are set in the controller for further reference/use
global with sharing class ProactiveProdDashboardController {
    
    public ProactiveProdDashboardController parentController {get {return this;} set;}
    // Determines which DB is running,  Proactive Production Dashboard Overall or with Date
    public String dashboardType {get;set;}
    public Boolean currentFiscalYearDataOnlyFlag {get;set;}

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
    //public String selectedUser {get;set;}
    
    // Filters for the reports:
    public String theatreFilter {get;set;}
    public String businessLineFilter {get;set;}
    public String territoryFilter {get;set;}
    public String regionFilter {get;set;}
    public String opportunityTypeFilter {get;set;}
    public String startDateFilter {get;set;}
    public String endDateFilter {get;set;}

    global String filterConditions {get;set;}
    private static Set<String> diaCompliantStages = new Set<String>{'Quote Completed','Quote Delivered','Customer Commitment','PO Received','Closed Sale' };
    private static Set<String> rollingDIAStageNames = new Set<String>{'Not Contacted','Contacted','Quote Request'};
    private static Set<String> quoteCompletedAverageDIAStageNames = new Set<String>{'Quote Completed', 'Quote Delivered', 'Customer Commitment', 'PO Received', 'Closed Sale'};
    
    // String acting as the place holder for Q0Metrics, when passed, sets the q0DIAMetrics value to be displayed in the page:
    public String q0MetricsPlaceholder{get;set{if(value != null){   q0DIAMetrics = (List<DIAMetrics>)JSON.deserialize(value, List<DIAMetrics>.class); }}}
    // String acting as the place holder for Q1Metrics, when passed, sets the q0DIAMetrics value to be displayed in the page:
    public String q1MetricsPlaceholder{get;set{if(value != null){   q1DIAMetrics = (List<DIAMetrics>)JSON.deserialize(value, List<DIAMetrics>.class); }}}
    // String acting as the place holder for q0DIASnapShot, when passed, sets the q0DIASnapShot value to be displayed in the page:
    public String q0DIASnapshotPlaceholder{get;set{if(value != null){   q0DIASnapShot = (DIASnapShot)JSON.deserialize(value, DIASnapShot.class); }}}
    // String acting as the place holder for q1DIASnapShot, when passed, sets the q1DIASnapShot value to be displayed in the page:
    public String q1DIASnapshotPlaceholder{get;set{if(value != null){   q1DIASnapShot = (DIASnapShot)JSON.deserialize(value, DIASnapShot.class); }}}
    // String acting as the place holder for rolling DIA Wrapper, when passed, sets the quoteCompletedRollingDIA value to be displayed in the page:
    public String rollingDIAPlaceholder{get;set{if(value != null){  system.debug('@@@ + ' +value);quoteCompletedRollingDIA = (List<RollingDIAWrapper>)JSON.deserialize(value, List<RollingDIAWrapper>.class); }}}
    // String acting as the place holder for quoteCompletedAverageDIA, when passed, sets the quoteCompletedAverageDIA value to be displayed in the page:
    public String quoteCompletedAverageDIAPlaceholder{get;set{if(value != null){    quoteCompletedAverageDIA = (Integer)JSON.deserialize(value, Integer.class); }}}
    // String acting as the place holder for q0SalesPipeline, when passed, sets the q0SalesPipeline value to be displayed in the page:
    public String q0SalesPipelinePlaceholder{get;set{if(value != null){ q0SalesPipeline = (SalesPipelineWrapper)JSON.deserialize(value, SalesPipelineWrapper.class); }}}
    // String acting as the place holder for q1SalesPipeline, when passed, sets the q1SalesPipeline value to be displayed in the page:
    public String q1SalesPipelinePlaceholder{get;set{if(value != null){ q1SalesPipeline = (SalesPipelineWrapper)JSON.deserialize(value, SalesPipelineWrapper.class); }}}
        
    // All Wrapper data to display on the page    
    // DIA Metrics
    public List<DIAMetrics> q0DIAMetrics {get;set;}
    public List<DIAMetrics> q1DIAMetrics {get;set;}
    // DIA Snapshots
    public DIASnapShot q0DIASnapShot {get;set;}
    public DIASnapShot q1DIASnapShot {get;set;}
    // Sales Pipeline related variables
    public SalesPipelineWrapper q0SalesPipeline {get;set;}
    public SalesPipelineWrapper q1SalesPipeline {get;set;}
    public Integer quoteCompletedAverageDIA {get;set;}
    public List<RollingDIAWrapper> quoteCompletedRollingDIA {get;set;}


    // Wrapper class for DIA metrics
    global class DIAMetrics{
        public String businessLine {get;set;}
        public Integer averageTargetDIA {get;set;}
        public Integer averageQuoteCompletedDIA {get;set;}
        public Integer averageQuoteDeliveredDIA {get;set;}

        public DIAMetrics(String businessLine, Integer averageTargetDIA, Integer averageQuoteCompletedDIA, Integer averageQuoteDeliveredDIA){ //, Integer averageLeadTime){
            this.businessLine = businessLine;
            this.averageTargetDIA = averageTargetDIA;
            this.averageQuoteCompletedDIA = averageQuoteCompletedDIA;
            this.averageQuoteDeliveredDIA = averageQuoteDeliveredDIA;
        }
    }
    
    // Wrapper class for DIA Snapshot metrics
    global class DIASnapShot{
        public Integer totalAverageTargetDIA {get;set;}
        public Integer totalAverageQuoteCompletedDIA {get;set;}
        public Integer totalAverageQuoteDeliveredDIA {get;set;}
        public Integer totalAverageLeadTime {get;set;}
        public Integer totalAverageDIACompliance {get;set;}
        public DIASnapShot(){
            this.totalAverageTargetDIA = 0;
            this.totalAverageQuoteCompletedDIA = 0;
            this.totalAverageQuoteDeliveredDIA = 0;
            this.totalAverageLeadTime = 0;
            this.totalAverageDIACompliance = 0;
        }
    }

    // Wrapper for storing Sales pipeline values by Stage
    global class SalesPipelineStageWrapper{
        public String stage{get;set;}
        public Integer recordCount {get;set;}
        public Decimal renewalAmount {get;set;}
        
        public SalesPipelineStageWrapper(String Stage, Integer recordCount, Decimal renewalAmount){
            this.Stage = Stage;
            this.recordCount = recordCount;
            this.renewalAmount = renewalAmount;
        }
    }
    
    // Wrapper for storing overall Sales pipeline values
    global class SalesPipelineWrapper{
         public Integer totalRecordCount {get;set;}
        public Decimal totalRenewalAmount {get;set;}
        public List<SalesPipelineStageWrapper> salesPipelineStages {get;set;}
        public SalesPipelineWrapper() {
            totalRecordCount = 0;
            totalRenewalAmount = 0;
            salesPipelineStages = new List<SalesPipelineStageWrapper>();
        }
    }
    
    // Wrapper class for Rolling DIA metrics
    global class RollingDIAWrapper{
        public String earliestExistingEndDate {get;set;}
        public Integer averageRollingDIA {get;set;}
        public String stage {get;set;}
        public Integer recordCount {get;set;}
        public RollingDIAWrapper(String earliestExistingEndDate, Integer averageRollingDIA, String stage, Integer recordCount){
            this.earliestExistingEndDate = earliestExistingEndDate;
            this.averageRollingDIA = averageRollingDIA;
            this.stage = stage;
            this.recordCount = recordCount;
        }
    }        
        
        
    // controller's constructor: logic moved to the respective action methods ( to support both Overall & with Date DB)
    public ProactiveProdDashboardController(){}
            
    // This method is just a place holder for setting the values (which came from the remote action call) into the wrapper of this controller
    public void updateValues(){}
    
    // Action method for ProactiveProdWithDates DB , set the dashboardType so that only current quarter data is fetched.
    public void initProactiveProdWithDates(){
        dashboardType = 'ProactiveProdWithDates';
        init();
    }
    
    // Action method for ProactiveProd Overall DB , set the dashboardType so that current & next quarter data is fetched.
    public void initProactiveProdOverall(){
        dashboardType = 'ProactiveProdOverall';
        init();
    }
    
    // Init method to fetch all records only once (to avoid hitting limits) and prepare all dashboard data
    public void init(){
        // Initialize the filed filter pickilst values:
        currentFiscalYearDataOnlyFlag = true;
        String nameSpace = Util.solnExtnNameSpace;
        theatres = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'SSI_Theatre__c','None');
        businessLines = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Business_Line__c','None');
        opportunityTypes = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Opportunity_Type__c','None');
        regions = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Client_Region__c','None');
        territoris = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Client_Territory__c','None');

        // On page load, set the basic values for the filters:
        resetFilters();
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
    
        // Set the filter condition to fetch data from this current & Next calendar quarter only (for Proactive DB)
        if (dashboardType != 'ProactiveProdWithDates')
          filterConditions = ' AND (REN_Earliest_Expiration_Date__c = THIS_QUARTER OR REN_Earliest_Expiration_Date__c = NEXT_QUARTER) ';
        // Set the filter condition to fetch data from this current & Next calendar quarter only (for Proactive with dates DB)
        else
            filterConditions = ' AND REN_Earliest_Expiration_Date__c = THIS_QUARTER ';
            
        // Set the pv parameters for report:
        theatreFilter = DashboardUtil.concatenateAllOptions(theatres);
        businessLineFilter = DashboardUtil.concatenateAllOptions(businessLines);
        territoryFilter = DashboardUtil.concatenateAllOptions(territoris);
        regionFilter = DashboardUtil.concatenateAllOptions(regions);
        opportunityTypeFilter = DashboardUtil.concatenateAllOptions(opportunityTypes);
        startDateFilter = 'THIS_QUARTER';
        endDateFilter = 'THIS_QUARTER';
    }
    
    // Based on the parameters selected on the page, create the filter segments for the dynamic query & Set filter parameters for reporting
    public pageReference filterData() {
        // Ensure User enters both Start & End dates:
        if((startDate != null && startDate !='' && (endDate == null ||endDate == '')) || ((startDate == null ||startDate == '') && endDate != null && endDate != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.MSG_START_END_DATE_FILTER));
            return null;
        }
    
        filterConditions ='';
        // If any value is selected for Theatre picklist then add it to the filter conditions & set the report filter
        if(selectedTheatre != null && selectedTheatre != 'None'){
            filterConditions += ' AND SSI_Theatre__c = \'' + selectedTheatre +'\' ';
            // Set theatreFilter for filtering in the report
            theatreFilter = selectedTheatre;
        }
        // If any value is selected for Business pickllist, then  add it to the filter conditions & set the report filter
        if(selectedBusinessLine != null && selectedBusinessLine != 'None'){
            filterConditions += ' AND Business_Line__c = \'' + selectedBusinessLine +'\' ';
            // Set businessLineFilter for filtering in the report
            businessLineFilter = selectedBusinessLine;
        }
        // If any value is selected for Territory picklist then add it to the filter conditions & set the report filter
        if(selectedTerritory != null && selectedTerritory != 'None'){
            filterConditions += ' AND Client_Territory__c = \'' + selectedTerritory +'\' ';
            // Set theatreFilter for filtering in the report
            territoryFilter = selectedTerritory;
        }
        // If any value is selected for Region picklist then add it to the filter conditions & set the report filter
        if(selectedRegion != null && selectedRegion != 'None'){
            filterConditions += ' AND Client_Region__c = \'' + selectedRegion +'\' ';
            // Set theatreFilter for filtering in the report
            regionFilter = selectedRegion;
        }
        // If any value is selected for Opportunity Type picklist then add it to the filter conditions & set the report filter
        if(selectedOpportunityType != null && selectedOpportunityType != 'None'){
            filterConditions += ' AND Opportunity_Type__c = \'' + selectedOpportunityType +'\' ';
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
                filterConditions += ' AND REN_Earliest_Expiration_Date__c >= ' + String.valueOf(stDt) +' ';
                // Set date filter for filtering in the report
                startDateFilter = startDate;
            } catch(exception e){}
        }
        if(endDate != null && endDate != '' ){
            currentFiscalYearDataOnlyFlag = false;
            // If any invalid date string is passed, ignore it and do not add in the filters
            try{
                Date endDt = Date.parse(endDate);
                filterConditions += ' AND REN_Earliest_Expiration_Date__c <= ' + String.valueOf(endDt) +' ';
                // Set date filter for filtering in the report
                endDateFilter = endDate;
            } catch(exception e){}
        }
        
        // If no date Filters are applied, show current Fiscal Year data (to reduce data volume)
        if((startDate == null || startDate == '') && (endDate == null || endDate == '')) {
            currentFiscalYearDataOnlyFlag = true;
            filterConditions += ' AND (REN_Earliest_Expiration_Date__c = THIS_QUARTER OR REN_Earliest_Expiration_Date__c = NEXT_QUARTER) ';
        }
        return null;
    }
    
    // Remote action methods to fetch Q0 DIA Metrics Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static List<DIAMetrics> fetchQ0DIAMetrics (String aditionalFilterConditions){
        List<DIAMetrics> q0DIAMetrics = new List<DIAMetrics>();
        // When avg is directly fetched , it ignores null value records and the average comes wrong, so get the sum and record count to find the average
       
        
        List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountWithBusinessByFilterConditionsByExpDate(aditionalFilterConditions, 
            diaCompliantStages, 'THIS_QUARTER');
        for(AggregateResult agr: lstGroupedData) {
            String businessLine = agr.get('businessLine') == null ? 'N/A' : String.valueOf(agr.get('businessLine'));
            Decimal recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            Integer avgTargetDIA = agr.get('sumTargetDIA') == null ? 0 : Math.round(Integer.valueOf( agr.get('sumTargetDIA') ) / recordCount);
            Integer avgQuoteCompletedDIA = agr.get('sumQuoteCompletedDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteCompletedDIA')) / recordCount);
            Integer avgQuoteDeliveredDIA = agr.get('sumQuoteDeliveredDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteDeliveredDIA')) / recordCount);
            q0DIAMetrics.add(new DIAMetrics(businessLine, avgTargetDIA, avgQuoteCompletedDIA, avgQuoteDeliveredDIA));
        }
        return q0DIAMetrics;
    }
    
    // Remote action methods to fetch Q+1 DIA Metrics Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static List<DIAMetrics> fetchQ1DIAMetrics (String aditionalFilterConditions){
        List<DIAMetrics> q1DIAMetrics = new List<DIAMetrics>();
        // When avg is directly fetched , it ignores null value records and the average comes wrong, so get the sum and record count to find the average
       
         List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountWithBusinessByFilterConditionsByExpDate(aditionalFilterConditions, 
            diaCompliantStages, 'NEXT_QUARTER');
       
        for(AggregateResult agr: lstGroupedData) {
            String businessLine = agr.get('businessLine') == null ? 'N/A' : String.valueOf(agr.get('businessLine'));
            Decimal recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            Integer avgTargetDIA = agr.get('sumTargetDIA') == null ? 0 : Math.round(Integer.valueOf( agr.get('sumTargetDIA') ) / recordCount);
            Integer avgQuoteCompletedDIA = agr.get('sumQuoteCompletedDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteCompletedDIA')) / recordCount);
            Integer avgQuoteDeliveredDIA = agr.get('sumQuoteDeliveredDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteDeliveredDIA')) / recordCount);
            q1DIAMetrics.add(new DIAMetrics(businessLine, avgTargetDIA, avgQuoteCompletedDIA, avgQuoteDeliveredDIA));
        }
        return q1DIAMetrics;
    }
    
    // Remote action methods to fetch Q0 DIA Snapshot Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static DIASnapShot fetchQ0DIASnapshot (String aditionalFilterConditions){
        DIASnapShot q0DIASnapShot = new DIASnapShot();
        // When avg is directly fetched , it ignores null value records and the average comes wrong, so get the sum and record count to find the average
        
        List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountByFilterConditionsByExpDate(
        aditionalFilterConditions, diaCompliantStages, 'THIS_QUARTER');
       
        if(lstGroupedData != null && lstGroupedData.size() > 0) {
            AggregateResult agr = lstGroupedData[0];    // Only one row will be fetched, as no grouping is in place
            Decimal recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            q0DIASnapShot.totalAverageTargetDIA = agr.get('sumTargetDIA') == null ? 0 : Math.round(Integer.valueOf( agr.get('sumTargetDIA') ) / recordCount);
            q0DIASnapShot.totalAverageQuoteCompletedDIA = agr.get('sumQuoteCompletedDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteCompletedDIA')) / recordCount);
            q0DIASnapShot.totalAverageQuoteDeliveredDIA = agr.get('sumQuoteDeliveredDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteDeliveredDIA')) / recordCount);
            q0DIASnapShot.totalAverageLeadTime = agr.get('sumLeadTime') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumLeadTime')) / recordCount);
            q0DIASnapShot.totalAverageDIACompliance = agr.get('sumDIACompliance') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumDIACompliance'))*100 / recordCount);
        }
        return q0DIASnapShot;
    }
    
    // Remote action methods to fetch Q+1 DIA Snapshot Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static DIASnapShot fetchQ1DIASnapshot (String aditionalFilterConditions){
        DIASnapShot q1DIASnapShot = new DIASnapShot();
       
        List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountByFilterConditionsByExpDate(aditionalFilterConditions,
                diaCompliantStages, 'NEXT_QUARTER');
       
        if(lstGroupedData != null && lstGroupedData.size() > 0) {
            AggregateResult agr = lstGroupedData[0];    // Only one row will be fetched, as no grouping is in place
            Decimal recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            q1DIASnapShot.totalAverageTargetDIA = agr.get('sumTargetDIA') == null ? 0 : Math.round(Integer.valueOf( agr.get('sumTargetDIA') ) / recordCount);
            q1DIASnapShot.totalAverageQuoteCompletedDIA = agr.get('sumQuoteCompletedDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteCompletedDIA')) / recordCount);
            q1DIASnapShot.totalAverageQuoteDeliveredDIA = agr.get('sumQuoteDeliveredDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteDeliveredDIA')) / recordCount);
            q1DIASnapShot.totalAverageLeadTime = agr.get('sumLeadTime') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumLeadTime')) / recordCount);
            q1DIASnapShot.totalAverageDIACompliance = agr.get('sumDIACompliance') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumDIACompliance'))*100 / recordCount);
        }
        return q1DIASnapShot;
    }
    
    
    // Remote action methods to fetch Q0 & Q+1 Completed Rolling DIA Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static List<RollingDIAWrapper> fetchRollingDIA(String aditionalFilterConditions){
        List<RollingDIAWrapper> quoteCompletedRollingDIA = new List<RollingDIAWrapper>();
        // Average can be directly fetched, because Rolling_DIA__c is a formula field, Rolling_DIA__C is now REN_Days_Until_Expiration__c
       List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountWithExpDateAndStage(
           aditionalFilterConditions, 'THIS_QUARTER', 'NEXT_QUARTER', rollingDIAStageNames, '5');
        for(AggregateResult agr: lstGroupedData) {
            String stage = agr.get('stage') == null ? 'N/A' : String.valueOf(agr.get('stage'));
            Date dt = Date.valueOf(agr.get('endDate'));
            String earliestExistingEndDate = dt.month() + '/' + dt.day() + '/'+ dt.year();
            Integer recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            Integer avgRollingDIA = agr.get('avgRollingDIA') == null ? 0 : Integer.valueOf( agr.get('avgRollingDIA') );
            // populate the grouping value in the wrapper
            quoteCompletedRollingDIA.add(new RollingDIAWrapper(earliestExistingEndDate,avgRollingDIA,stage,recordCount));
        }
        return quoteCompletedRollingDIA;
    }
    
    // Calculate the Quote Completed AverageDIA for current and future quarter:
    @RemoteAction @ReadOnly
    global static Integer fetchQuoteCompletedAverageDIA(String aditionalFilterConditions){
        Integer quoteCompletedAverageDIA = 0 ;
        List<RollingDIAWrapper> quoteCompletedRollingDIA = new List<RollingDIAWrapper>();
        // Average can be directly fetched, because Rolling_DIA__c is a formula field
       
        List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountByDateAndStage(aditionalFilterConditions, 
            'THIS_QUARTER', 'NEXT_QUARTER', quoteCompletedAverageDIAStageNames);
        if(lstGroupedData != null && lstGroupedData.size() > 0) {
            AggregateResult agr = lstGroupedData [0];   // Only one row will be fetched
            Decimal recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            // Caclulate the quoteCompletedAverageDIA from the total sum and total record count
            quoteCompletedAverageDIA = agr.get('sumQuoteCompletedDIA') == null ? 0 : Math.round(Integer.valueOf(agr.get('sumQuoteCompletedDIA')) / recordCount);
        }
        return quoteCompletedAverageDIA;
    }
    
    // Remote action methods to fetch Q0 Sales Pipeline Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static SalesPipelineWrapper fetchQ0SalesPipelines(String aditionalFilterConditions){
        // Initilize the Sales pipeline list and the total sums to zero (in the wrapper constructor)
        SalesPipelineWrapper salesPipeline = new SalesPipelineWrapper();
        
        // Average can be directly fetched, because Rolling_DIA__c is a formula field
        
        List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountWithStageByDate('THIS_QUARTER', aditionalFilterConditions);
        
        for(AggregateResult agr: lstGroupedData) {
            String stage = agr.get('stage') == null ? 'N/A' : String.valueOf(agr.get('stage'));
            Integer recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            Decimal renewalAmtSum = agr.get('sumRenewalAmount') == null ? 0 : (Decimal)( agr.get('sumRenewalAmount') );
            // populate the grouping value in the wrapper
            salesPipeline.salesPipelineStages.add(new SalesPipelineStageWrapper(stage,recordCount,renewalAmtSum));
            // Calculate the overall total record count & renewal amounts
            salesPipeline.totalRecordCount += recordCount;
            salesPipeline.totalRenewalAmount += renewalAmtSum;
        }
        return salesPipeline;
    }
    
    // Remote action methods to fetch Q1 Sales Pipeline Data; The filter condition is passed in to the method
    @RemoteAction @ReadOnly
    global static SalesPipelineWrapper fetchQ1SalesPipelines(String aditionalFilterConditions){
        // Initilize the Sales pipeline list and the total sums to zero (in the wrapper constructor)
        SalesPipelineWrapper salesPipeline = new SalesPipelineWrapper();
        
        List<AggregateResult> lstGroupedData = OpportunityDataAccess.getCountWithStageByDate('NEXT_QUARTER', aditionalFilterConditions);
        for(AggregateResult agr: lstGroupedData) {
            String stage = agr.get('stage') == null ? 'N/A' : String.valueOf(agr.get('stage'));
            Integer recordCount = agr.get('recordCount') == null ? 1 : Integer.valueOf(agr.get('recordCount'));
            Integer renewalAmtSum = agr.get('sumRenewalAmount') == null ? 0 : Integer.valueOf( agr.get('sumRenewalAmount') );
            // populate the grouping value in the wrapper
            salesPipeline.salesPipelineStages.add(new SalesPipelineStageWrapper(stage,recordCount,renewalAmtSum));
            // Calculate the overall total record count & renewal amounts
            salesPipeline.totalRecordCount += recordCount;
            salesPipeline.totalRenewalAmount += renewalAmtSum;
        }
        return salesPipeline;
    }
}