// Controller Class for IndividualDashboard (custom dashboard)
global with sharing class IndividualDashboardController {

    public IndividualDashboardController parentController{get {return this;} set;}
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
    
    public Boolean currentFiscalYearDataOnlyFlag {get;set;}
    public Map<Id,User> subOrdinateUsers {get;set;}
    public List<SelectOption> availableUsers {
        get {
            if(this.availableUsers == null) {
                this.availableUsers = new List<SelectOption>();
                // For Individual dashboard , add the 'All' option:
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
    // Flag to determine if any user filter has been applied. Used to navigate to different(Overall/User specific) version of the reports
    public Boolean singleUserReport{ get{ return (selectedUser != null && selectedUser != '' && selectedUser != 'All');} set;}

    // Exclude these record types:
    private static Set<String> caseRecordTypesToExclude = new Set<String>{'Master','Opportunity Creation Request'};
    
    // Collect only those records which fall under current Fiscal Quarter (by Default, unless date filters are applied) : Passed to component
    public String filterConditions {get;set;}
    public String quoteFilterConditions {get;set;}
    
    public transient Map<String,grandSummaryCaseOwnerWrapper> grandSummary {get;set;}
    
    // String acting as the place holder for grandSummary, when passed, sets the grandSummary value to be displayed in the page:
    public String grandSummaryPlaceholder{get;set{if(value != null){    grandSummary = (Map<String,GrandSummaryCaseOwnerWrapper>)JSON.deserialize(value, Map<String,GrandSummaryCaseOwnerWrapper>.class);}}}

    // String acting as the place holder for Q0Metrics, when passed, sets the q0DIAMetrics value to be displayed in the page:
    public String bookingReactivePlaceholder{get;set{if(value != null){ bookingReactiveQualityMetrics = (QualityWrapper)JSON.deserialize(value, QualityWrapper.class);}}}
    
    // String acting as the place holder for Q0Metrics, when passed, sets the q0DIAMetrics value to be displayed in the page:
    public String quoteOverallPlaceholder{
        get;
        set {
            if(value != null) {
                QuoteQualityWrappers qqw = (QuoteQualityWrappers)JSON.deserialize(value, QuoteQualityWrappers.class);
                this.quoteReactiveQualityMetrics = qqw.quoteReactiveQualityMetrics;
                this.quoteProactiveQualityMetrics = qqw.quoteProactiveQualityMetrics;
                this.quoteTotalQualityMetrics = qqw.quoteTotalQualityMetrics;
            }
        }
    }

    // Variables for case type level grouping of Grand summary table
    global class GrandSummaryCaseTypeWrapper{
        //public String recordType{get;set;}
        public Integer SLA {get;set;}
        public Decimal averageSLA{get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        //public Integer diaCompliance {get;set;}
        public Integer totalCount {get;set;}
        public Integer totalCompliantCount{get;set;}
        public Integer totalDIACompliantCount{get;set;}
        public Integer goal{get;set;}
        public Decimal goalPercentage{get;set;}
        
        // Used to store the sum total, to find the average later divided by count
        public Decimal sumSLA{get;set;}
        public Decimal sumAverageSLA {get;set;}
        
        public GrandSummaryCaseTypeWrapper(){
            this.SLA = 0;
            this.averageSLA= 0;
            this.slaAdherence = 0;
            this.slaCompliance = 0;
            this.totalCount = 0;
            this.totalCompliantCount= 0;
            this.totalDIACompliantCount = 0;
            this.goal = 0;
            this.goalPercentage = 0;
            this.sumSLA = 0;
            this.sumAverageSLA = 0;
        }
    }
    
    // Variables for case recor type level grouping of Grand summary table
    global class GrandSummaryCaseOwnerWrapper{
        public Integer SLA {get;set;}
        public Decimal averageSLA{get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        //public Integer diaCompliance {get;set;}
        public Integer totalCount {get;set;}
        public Integer totalCompliantCount{get;set;}
        public Integer totalDIACompliantCount{get;set;}
        public Integer goal{get;set;}
        public Decimal goalPercentage{get;set;}
        public Map<String,grandSummaryCaseTypeWrapper> caseTypeMap{get;set;}
        
        public GrandSummaryCaseOwnerWrapper(){
            this.SLA = 0;
            this.averageSLA= 0;
            this.slaAdherence = 0;
            this.slaCompliance = 0;
            this.totalCount = 0;
            this.totalCompliantCount= 0;
            this.totalDIACompliantCount = 0;
            this.goal = 0;
            this.goalPercentage = 0;
            caseTypeMap = new Map<String,grandSummaryCaseTypeWrapper>();
        }
    }
    
    public QualityWrapper quoteReactiveQualityMetrics {get;set;}
    public QualityWrapper quoteProactiveQualityMetrics {get;set;}
    public QualityWrapper quoteTotalQualityMetrics {get;set;}
    public QualityWrapper bookingReactiveQualityMetrics {get;set;}
    // Wrapper class to hold the Quality metrics values
    global class QualityWrapper{
        public Integer totalRecords {get;set;}
        public Integer totalPassed {get;set;}
        public Integer totalFailed {get;set;}
        public Decimal passPercentage {get;set;}
        public Decimal failPercentage {get;set;}
        
        public QualityWrapper(Integer totalRecords,Integer totalPassed,Integer totalFailed,Decimal passPercentage,Decimal failPercentage){
            this.totalRecords = totalRecords;
            this.totalPassed = totalPassed;
            this.totalFailed = totalFailed;
            this.passPercentage = passPercentage;
            this.failPercentage = failPercentage;
        }
    }
    
    // Wrapper class to hold all the quote related qaulity wrappers:
    global class QuoteQualityWrappers{
        public QualityWrapper quoteReactiveQualityMetrics {get;set;}
        public QualityWrapper quoteProactiveQualityMetrics {get;set;}
        public QualityWrapper quoteTotalQualityMetrics {get;set;}
        
        public QuoteQualityWrappers(){}
    }

    // Constructor: Invokes the init method to fetch all data:
    public IndividualDashboardController() {
        init();
    }

    // This method is just a place holder for setting the values (which came from the remote action call) into the wrapper of this controller
    public void updateValues(){}
    // Dashboard element specific conditions specified here:
    private Map<String,String> queryConditionByDataSetKey = new Map<String,String> {
            'ReactiveCases' => ' AND Case.Origin !=\'Proactive\' ',
            'ProactiveCases' => ' AND Case.Origin =\'Proactive\' '
    };
        
    // From the dataset key, fetch the query for specific dashboard element (used by the components)
    public String getQueryCondition(String dataSetKey){
        return queryConditionByDataSetKey.get(dataSetKey);
    }

    
    public pageReference init() {
        // On page load, set the basic values for the filters:
        currentFiscalYearDataOnlyFlag = true;
        String nameSpace = Util.solnExtnNameSpace;        
        // Initialize the filed filter pickilst values:
        currentFiscalYearDataOnlyFlag = true;
        theatres = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'SSI_Theatre__c','None');
        businessLines = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Business_Line__c','None');
        opportunityTypes = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Opportunity_Type__c','None');
        regions = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Client_Region__c','None');
        territoris = DashboardUtil.getPicklistValues('Opportunity',nameSpace+'Client_Territory__c','None');
        // Get all users of Operations roles
        subOrdinateUsers = DashboardUtil.getRoleSubordinateUsers();        
        
        resetFilters();
        return null;
    }
    
    // Initialize or reset all variables to their default values
    public void resetFilters() {
        // Reset all filters and set the filter condition to current fiscal year:
        selectedTheatre = null;
        selectedBusinessLine = null;
        selectedTerritory = null;
        selectedRegion = null;
        selectedOpportunityType = null;
        startDate = null;
        endDate = null;
        // Set to all users by default on page load
        selectedUser = 'All';
    
        // Set the filter condition to fetch data from this calendar quarter only (both for Quote & Case)
        filterConditions = ' AND Case.ClosedDate = THIS_QUARTER ';
        quoteFilterConditions = ' AND Case__r.ClosedDate = THIS_QUARTER ';
            
        // Set the pv parameters for report:
        theatreFilter = DashboardUtil.concatenateAllOptions(theatres);
        businessLineFilter = DashboardUtil.concatenateAllOptions(businessLines);
        territoryFilter = DashboardUtil.concatenateAllOptions(territoris);
        regionFilter = DashboardUtil.concatenateAllOptions(regions);
        opportunityTypeFilter = DashboardUtil.concatenateAllOptions(opportunityTypes);
        startDateFilter = 'THIS_QUARTER';
        endDateFilter = 'THIS_QUARTER';
        runAsUserFilter = UserInfo.getName();
    }
    
    // Based on the parameters selected on the page, create the filter segments for the dynamic query & Set filter parameters for reporting
    public pageReference filterData() {
        // Ensure User enters both Start & End dates:
        if((startDate != null && startDate !='' && (endDate == null ||endDate == '')) || ((startDate == null ||startDate == '') && endDate != null && endDate != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.BothStartAndEndDateRequired));
            return null;
        }
    
        filterConditions ='';
        quoteFilterConditions = '';
        // If any value is selected for Theatre picklist then add it to the filter conditions & set the report filter
        if(selectedTheatre != null && selectedTheatre != 'None'){
            filterConditions += ' AND Case.SSI_Theatre__c = \'' + selectedTheatre +'\' ';
            quoteFilterConditions += ' AND Case__r.SSI_Theatre__c = \'' + selectedTheatre +'\' ';
            // Set theatreFilter for filtering in the report
            theatreFilter = selectedTheatre;
        }
        // If any value is selected for Business pickllist, then  add it to the filter conditions & set the report filter
        if(selectedBusinessLine != null && selectedBusinessLine != 'None'){
            filterConditions += ' AND Case.Business_Line__c = \'' + selectedBusinessLine +'\' ';
            quoteFilterConditions += ' AND Case__r.Business_Line__c = \'' + selectedBusinessLine +'\' ';
            // Set businessLineFilter for filtering in the report
            businessLineFilter = selectedBusinessLine;
        }
        // If any value is selected for Territory picklist then add it to the filter conditions & set the report filter
        if(selectedTerritory != null && selectedTerritory != 'None'){
            filterConditions += ' AND Case.Client_Territory__c = \'' + selectedTerritory +'\' ';
            quoteFilterConditions += ' AND Case__r.Client_Territory__c = \'' + selectedTerritory +'\' ';
            // Set theatreFilter for filtering in the report
            territoryFilter = selectedTerritory;
        }
        // If any value is selected for Region picklist then add it to the filter conditions & set the report filter
        if(selectedRegion != null && selectedRegion != 'None'){
            filterConditions += ' AND Case.Client_Region__c = \'' + selectedRegion +'\' ';
            quoteFilterConditions += ' AND Case__r.Client_Region__c = \'' + selectedRegion +'\' ';
            // Set theatreFilter for filtering in the report
            regionFilter = selectedRegion;
        }
        // If any value is selected for Opportunity Type picklist then add it to the filter conditions & set the report filter
        if(selectedOpportunityType != null && selectedOpportunityType != 'None'){
            filterConditions += ' AND Case.Opportunity_Type__c = \'' + selectedOpportunityType +'\' ';
            quoteFilterConditions += ' AND Case__r.Opportunity_Type__c = \'' + selectedOpportunityType +'\' ';
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
                quoteFilterConditions += ' AND Case__r.ClosedDate >= ' + String.valueOf(stDt) +'T00:00:00Z ';
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
                quoteFilterConditions += ' AND Case__r.ClosedDate <= ' + String.valueOf(endDt) +'T23:59:59Z ';
                // Set date filter for filtering in the report
                endDateFilter = endDate;
            } catch(exception e){}
        }
        
        // Only applicable for Individual dashboard: If any manager user selects any other user than him/her, add the user filter to condition
        if(selectedUser != null && selectedUser != '' && selectedUser != 'All') {
            filterConditions += ' AND Case.OwnerId = \''+selectedUser+'\' ';
            quoteFilterConditions += ' AND Case__r.OwnerId = \''+selectedUser+'\' ';
            // Set user filter for filtering in the report (if not found, set to current user:
            runAsUserFilter = (subOrdinateUsers.get(selectedUser) != null ? subOrdinateUsers.get(selectedUser).Name : UserInfo.getName());
        }
        
        // If no date Filters are applied, show current Fiscal Year data (to reduce data volume)
        if((startDate == null || startDate == '') && (endDate == null || endDate == '')) {
            currentFiscalYearDataOnlyFlag = true;
            filterConditions += ' AND Case.ClosedDate = THIS_QUARTER ';
            quoteFilterConditions += ' AND Case__r.ClosedDate = THIS_QUARTER ';
        }
        return null;
    }
    

    // Remote action method to get the grand summary data
    // Record type filter and page level filters are passed in aditionalFilterConditions variable from the page
    @RemoteAction @ReadOnly
    global static Map<String,GrandSummaryCaseOwnerWrapper> fetchGrandSummaryData(String aditionalFilterConditions){
        Map<String,GrandSummaryCaseOwnerWrapper> grandSummary = new Map<String,GrandSummaryCaseOwnerWrapper>();
        // Fetch the aggregate metrics grouped by Owner and Record Type (and Target)
        // Grouped by Target to get unique count of goals, instead of adding the same goal record multiple times
       
        List<AggregateResult> lsUserGroupData = MilestoneDataAccess.getAggregateGrpByNameTypeTarget(true, caseRecordTypesToExclude);       
        // From the Priority level aggregate results, fill the priority level columns details of the dashboard element:
        if(lsUserGroupData != null && lsUserGroupData.size() > 0 ){  
            for(AggregateResult agr: lsUserGroupData){
                String ownerName = String.valueOf(agr.get('ownerName'));
                String caseType = String.valueOf(agr.get('caseType'));
                //String target = String.valueOf(agr.get('target')); // Grouped just to get unique Goal records
                
                // Get the aggregate values from the query
                Integer recordCount = ( agr.get('recordCount') == null ? 0 : Integer.valueOf(agr.get('recordCount')) );
                Integer compliantCount = ( agr.get('compliantCount') == null ? 0 : Integer.valueOf(agr.get('compliantCount')) );
                Integer totalTargetSLA = (agr.get('totalTargetSLA') != null ? Integer.valueOf(agr.get('totalTargetSLA')) : 0);
                Decimal totalSLA = (agr.get('totalSLA') != null ? Double.valueOf(agr.get('totalSLA')) : 0);
                Integer totalGoal = (agr.get('goal') != null ? Integer.valueOf(agr.get('goal')) : 0);
                
                // Check if the case Record type key already exists in the map or not
                if(grandSummary.get(ownerName) == null){
                    grandSummary.put(ownerName , new GrandSummaryCaseOwnerWrapper());
                }
                
                // Get the case type wrapper details from the map:                
                if(grandSummary.get(ownerName).caseTypeMap.get(caseType) == null ){
                    grandSummary.get(ownerName).caseTypeMap.put(caseType, new GrandSummaryCaseTypeWrapper() );
                }
                GrandSummaryCaseTypeWrapper gsctw = grandSummary.get(ownerName).caseTypeMap.get(caseType);
                
                // Add up the totals from the Target level to the Case type level 
                gsctw.totalCount += recordCount;
                gsctw.totalCompliantCount += compliantCount;
                // The target comes as a sum of all goals, so divide it by the number of records to get the actual target/goal value
                gsctw.goal += (recordCount == 0? 0 : totalGoal/ recordCount);
                
                // Store the sum of SLA and average SLA for finding the average later:
                gsctw.sumSLA += totalTargetSLA;
                gsctw.sumAverageSLA += totalSLA;
            }
            
            // After the Case record type level values are filled, populate the Case owner level values (summary of all record types for that user)
            for(GrandSummaryCaseOwnerWrapper gscow : grandSummary.values()) {
                Decimal totalOwnerLevelTargetSLA = 0, totalOwnerLevelAvgSLA = 0;
                // Get the prioirties map:
                for(GrandSummaryCaseTypeWrapper gsctw : gscow.caseTypeMap.values()) {
                    // Calculate the average SLA & TargetSLA (averages)
                    gsctw.SLA = (gsctw.totalCount == 0 ? 0 :  Math.round(gsctw.sumSLA / gsctw.totalCount)  );
                    gsctw.averageSLA = (gsctw.totalCount == 0 ? 0 :  gsctw.sumAverageSLA / gsctw.totalCount  );
                    // Findout the priority level level SLA Adherence from SLA & Average SLA
                    gsctw.slaAdherence = ((gsctw.SLA == null || gsctw.SLA == 0) ? 0 : ((gsctw.SLA - gsctw.averageSLA) / gsctw.SLA * 100).setScale(2));
                    // Priority level SLA compliance % = Number of Compliant records / Total records * 100;
                    gsctw.slaCompliance = ( gsctw.totalCount == 0 ? 0 : Math.Round(((Decimal)gsctw.totalCompliantCount / gsctw.totalCount) * 100) );
                    // Find out the goal % at case type level:
                    gsctw.goalPercentage = ( gsctw.goal == 0? 0: (((Decimal)gsctw.totalCount / gsctw.goal) * 100)  ).setScale(2);
                    
                    // Increment the case owner level values:
                    gscow.totalCount += gsctw.totalCount;
                    gscow.totalCompliantCount += gsctw.totalCompliantCount;
                    gscow.goal += gsctw.goal;
                    totalOwnerLevelTargetSLA += (gsctw.totalCount * gsctw.SLA);
                    totalOwnerLevelAvgSLA += (gsctw.totalCount * gsctw.averageSLA);
                }
                
                // Findout the average at Owner Office Level:
                // Calculate the average SLA & TargetSLA (average values from the total and the total record counts)
                gscow.SLA = (gscow.totalCount == 0 ? 0 :  Math.round(totalOwnerLevelTargetSLA / gscow.totalCount)  );
                gscow.averageSLA = (gscow.totalCount == 0 ? 0 :  totalOwnerLevelAvgSLA / gscow.totalCount  );
                // Findout the Owner level level SLA Adherence from SLA & Average SLA
                gscow.slaAdherence = ((gscow.SLA == null || gscow.SLA == 0) ? 0 : ((gscow.SLA - gscow.averageSLA) / gscow.SLA * 100).setScale(2));
                // Owner level SLA compliance % = Number of Compliant records / Total records * 100;
                gscow.slaCompliance = ( gscow.totalCount == 0 ? 0 : Math.Round(((Decimal)gscow.totalCompliantCount / gscow.totalCount) * 100) );
                // Find out the goal % at case owner level:
                gscow.goalPercentage = ( gscow.goal == 0? 0: (((Decimal)gscow.totalCount / gscow.goal) * 100)  ).setScale(2);
            }       
        }
        return grandSummary;
    }

    
    // Remote action method to get the Quote quality data (all three: reactive, proactive and combined)
    // Record type filter and page level filters are passed in aditionalFilterConditions variable from the page
    @RemoteAction @ReadOnly
    global static QuoteQualityWrappers fetchQualityQuoteMetrics(String aditionalFilterConditions){
        QuoteQualityWrappers allQuoteMetrics = new QuoteQualityWrappers();
        //Initialize the quote wrappers with zero values
        QualityWrapper quoteProactiveMetrics = new qualityWrapper(0,0,0,0,0);
        QualityWrapper quoteReactiveMetrics = new qualityWrapper(0,0,0,0,0);
        QualityWrapper quoteOverallMetrics = new qualityWrapper(0,0,0,0,0);
        
        List<AggregateResult> lstGroupData = QuoteDataAccess.getCountByConditions(aditionalFilterConditions);
        if(lstGroupData != null && lstGroupData.size() > 0 ){
            for(AggregateResult agr: lstGroupData) {
                // Get the aggregate values from the query
                String origin = String.valueOf(agr.get('origin'));
                String reviewStatus = String.valueOf(agr.get('reviewStatus'));
                Integer recordCount = ( agr.get('recordCount') == null ? 0 : Integer.valueOf(agr.get('recordCount')) );
                
                
                // Add all failed counts (for all origin type to overall metrics)
                quoteOverallMetrics.totalFailed += (reviewStatus == 'Fail' ? recordCount : 0);
                // Add to get the total record count
                quoteOverallMetrics.totalRecords += recordCount;
                
                
                // Add Proactive quote counts to quoteProactiveMetrics:
                // Add all failed counts (for proactive origin type)
                quoteProactiveMetrics.totalFailed += (origin == 'Proactive' && reviewStatus == 'Fail' ? recordCount : 0);
                // Add to get the total record count
                quoteProactiveMetrics.totalRecords += (origin == 'Proactive' ? recordCount : 0);
                
                // Add Reactive quote counts to quoteReactiveMetrics:                
                // Add all failed counts (for Reactive origin type)
                quoteReactiveMetrics.totalFailed += (origin != 'Proactive' && reviewStatus == 'Fail' ? recordCount : 0);
                // Add to get the total record count
                quoteReactiveMetrics.totalRecords += (origin != 'Proactive' ? recordCount : 0);
            }
            
            // Count overall total Passed and total failed %:
            quoteOverallMetrics.totalPassed = quoteOverallMetrics.totalRecords- quoteOverallMetrics.totalFailed;
            quoteOverallMetrics.failPercentage = (quoteOverallMetrics.totalRecords == 0 ? 0 : ((Decimal)quoteOverallMetrics.totalFailed/quoteOverallMetrics.totalRecords)*100 ).setScale(0);
            quoteOverallMetrics.passPercentage = (quoteOverallMetrics.totalRecords == 0 ? 0 : 100 - quoteOverallMetrics.failPercentage);
            
            // Count Proactive total Passed and total failed %:
            quoteProactiveMetrics.totalPassed = quoteProactiveMetrics.totalRecords- quoteProactiveMetrics.totalFailed;
            quoteProactiveMetrics.failPercentage = (quoteProactiveMetrics.totalRecords == 0 ? 0 : ((Decimal)quoteProactiveMetrics.totalFailed/quoteProactiveMetrics.totalRecords)*100 ).setScale(0);
            quoteProactiveMetrics.passPercentage = (quoteProactiveMetrics.totalRecords == 0 ? 0 : 100 - quoteProactiveMetrics.failPercentage);
            
            // Count reactive total Passed and total failed %:
            quoteReactiveMetrics.totalPassed = quoteReactiveMetrics.totalRecords- quoteReactiveMetrics.totalFailed;
            quoteReactiveMetrics.failPercentage = (quoteReactiveMetrics.totalRecords == 0 ? 0 : ((Decimal)quoteReactiveMetrics.totalFailed/quoteReactiveMetrics.totalRecords)*100 ).setScale(0);
            quoteReactiveMetrics.passPercentage = (quoteReactiveMetrics.totalRecords == 0 ? 0 : 100 - quoteReactiveMetrics.failPercentage);
        }  
        // Add the newly calculated wrappers in the quoteQualityWrapper:
        allQuoteMetrics.quoteReactiveQualityMetrics = quoteReactiveMetrics;
        allQuoteMetrics.quoteProactiveQualityMetrics = quoteProactiveMetrics;
        allQuoteMetrics.quoteTotalQualityMetrics = quoteOverallMetrics;
        
        return allQuoteMetrics;
    }
    
    // Remote action method to get the Booking reactive data
    // Record type filter and page level filters are passed in aditionalFilterConditions variable from the page
    @RemoteAction @ReadOnly
    global static QualityWrapper fetchBookingReactiveMetrics(String aditionalFilterConditions){
        QualityWrapper qualityMetrics = new qualityWrapper(0,0,0,0,0);
        
        List<AggregateResult> lstGroupData = MilestoneDataAccess.getCountByIsClosedAndType(true, 'Review_Request', 'Booking');
        // Fetch the aggregate metrics grouped by Owner and Record Type
       
        if(lstGroupData != null && lstGroupData.size() > 0 ){
            for(AggregateResult agr: lstGroupData){
                // Get the aggregate values from the query
                String status = String.valueOf(agr.get('status'));
                Integer recordCount = ( agr.get('recordCount') == null ? 0 : Integer.valueOf(agr.get('recordCount')) );
                
                // Check the failed record Count:
                if(status == 'Review Failed')
                    qualityMetrics.totalFailed += recordCount;
                // Add to get the total record count
                qualityMetrics.totalRecords += recordCount;
            }
            // Count total Passed by deducting the failed count from total
            qualityMetrics.totalPassed = qualityMetrics.totalRecords- qualityMetrics.totalFailed;
            
            // Calculate the total failed %
            qualityMetrics.failPercentage = (qualityMetrics.totalRecords == 0 ? 0 : ((Decimal)qualityMetrics.totalFailed/qualityMetrics.totalRecords)*100 ).setScale(0);
            qualityMetrics.passPercentage = (qualityMetrics.totalRecords == 0 ? 0 : 100 - qualityMetrics.failPercentage);
        }
        
        return qualityMetrics;
    }
}