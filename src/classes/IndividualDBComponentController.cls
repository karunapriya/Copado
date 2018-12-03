// Controller class for Individual dashboard component
global with sharing class IndividualDBComponentController{

    public String dataSetKey {get;set;}
    public transient IndividualDashboardController parentController {get;set;}
    public transient overallWrapperData allData {get;set;}
    public String dashboardSpecificCondition {get;set;}
    
    // Exclude these record types:
    private static Set<String> caseRecordTypesToExclude = new Set<String>{'Master','Opportunity Creation Request'};

    // String acting as the place holder for Q0Metrics, when passed, sets the q0DIAMetrics value to be displayed in the page:
    public String allDataPlaceholder{get;set{if(value != null){ allData = (overallWrapperData)JSON.deserialize(value, overallWrapperData.class);}}}

    // Stores all values by case owner:
    global class caseOwnerWrapper{
        public Integer SLA {get;set;}        // 'Target SLA' Column on VF
        public Decimal averageSLA {get;set;}
        public Decimal slaAdherence {get;set;}
        public Decimal slaCompliance {get;set;}
        public Decimal diaCompliance {get;set;}
        public Integer totalCompliantCount{get;set;}
        public Integer totalDIACompliantCount {get;set;}
        public Integer totalCount {get;set;}
        public Integer goal{get;set;}
        public Decimal goalPercentage{get;set;}
        // Used to store the sum total, to find the average later divided by count
        public Decimal sumSLA{get;set;}
        public Decimal sumAverageSLA {get;set;}

        public caseOwnerWrapper(){
            this.SLA = 0;
            this.averageSLA = 0;
            this.slaAdherence = 0;
            this.slaCompliance = 0;
            this.diaCompliance = 0;
            this.totalCompliantCount = 0;
            this.totalDIACompliantCount = 0;
            this.totalCount = 0;
            this.goal = 0;
            this.goalPercentage = 0;
            this.sumSLA = 0;
            this.sumAverageSLA = 0;
        }
    }
    
    // Wrapper class for storing the over all counts for the component
    global class overallWrapperData{
        //public String datasetKey{get;set;}
        
        public Integer overallSLA {get;set;}
        public Decimal overallAverageSLA {get;set;}
        public Decimal overallSLAAdherence {get;set;}
        public Integer overallSLACompliance {get;set;}
        public Integer overallDIACompliance {get;set;}
        public Integer overallTotalCompliantCount {get;set;}
        public Integer overallTotalDIACompliantCount {get;set;}
        public Integer overallTotalCount {get;set;}
        public Integer overallGoal{get;set;}
        public Decimal overallGoalPercentage{get;set;}
        public Map<String,caseOwnerWrapper> allCaseOwnerMap{get;set;}
        
        public overallWrapperData() {
            this.allCaseOwnerMap = new Map<String,caseOwnerWrapper>();
            this.overallSLA = 0;
            this.overallAverageSLA = 0;
            this.overallSLAAdherence = 0;
            this.overallSLACompliance =0 ;
            this.overallDIACompliance = 0;
            this.overallTotalCompliantCount = 0;
            this.overallTotalDIACompliantCount = 0;
            this.overallTotalCount = 0;
            this.overallGoal = 0;
            this.overallGoalPercentage = 0;
        }
    }
    
    // Component Constructor: All calculations/data fetching done in the init method:
    public IndividualDBComponentController(){}
    
    // This method is just a place holder for setting the values (which came from the remote action call) into the wrapper of this controller
    public void updateValues(){}
    
    // Componennt's init Method: Initializes all value from parent controller:    
    public string getInitAll(){
        //Get the query conditions from the parent controller:
        dashboardSpecificCondition =  parentController.getQueryCondition(dataSetKey) + parentController.filterConditions;
        return null;
    }
    
    
    // Remote action method to get the dashboard element data; 
    // Record type filter and page level filters are passed in aditionalFilterConditions variable from the page
    @RemoteAction @ReadOnly
    global static overallWrapperData fetchDashboardData(String aditionalFilterConditions){
        overallWrapperData oData = new overallWrapperData();
        // Fetch the metrics for User level grouping:
       
        List<AggregateResult> lsUserGroupData = MilestoneDataAccess.getAggregateGrpByNameTypeTarget(true, caseRecordTypesToExclude);
        // From the Owner-Priority level aggregate results, fill the User level columns details of the dashboard element:
        if(lsUserGroupData != null && lsUserGroupData.size() > 0 ){
            Decimal totalOverallTargetSLA = 0, totalOverallAvgSLA = 0;
            for(AggregateResult agr: lsUserGroupData){
                String ownerName = (agr.get('ownerName') != null ? String.valueOf(agr.get('ownerName')) : 'N/A');
                //String target = String.valueOf(agr.get('target')); // Grouped just to get unique Goal records
                
                Integer recordCount = ( agr.get('recordCount') == null ? 0 : Integer.valueOf(agr.get('recordCount')) );
                Integer compliantCount = ( agr.get('compliantCount') == null ? 0 : Integer.valueOf(agr.get('compliantCount')) );
                Integer diaCompliantCount = ( agr.get('diaCompliantCount') == null ? 0 : Integer.valueOf(agr.get('diaCompliantCount')) );
                Integer totalGoal = (agr.get('goal') != null ? Integer.valueOf(agr.get('goal')) : 0);
                Integer totalTargetSLA = (agr.get('totalTargetSLA') != null ? Integer.valueOf(agr.get('totalTargetSLA')) : 0);
                Decimal totalSLA = (agr.get('totalSLA') != null ? Double.valueOf(agr.get('totalSLA')) : 0);
                
                
                // Get the case owner wrapper details from the map:                
                if(oData.allCaseOwnerMap.get(ownerName) == null ){
                    oData.allCaseOwnerMap.put(ownerName,new caseOwnerWrapper());
                }
                
                // Get the case owner wrapper from the map and add the operations target level values there
                caseOwnerWrapper cow = oData.allCaseOwnerMap.get(ownerName);
                cow.totalCount += recordCount;
                cow.totalCompliantCount += compliantCount;
                cow.totalDIACompliantCount += diaCompliantCount;
                // The target comes as a sum of all goals, so divide it by the number of records to get the actual target/goal value
                cow.goal += (recordCount == 0? 0 : totalGoal/ recordCount);

                // Calculate the average SLA & TargetSLA (averages)
                cow.SLA = (recordCount == 0 ? 0 :  Math.round(totalTargetSLA / recordCount)  );
                cow.averageSLA = (recordCount == 0 ? 0 :  totalSLA / recordCount  );
                
                // Find out the case Owner's SLA adherence:
                cow.slaAdherence = ((cow.SLA ==null || cow.SLA ==0) ? 0: ((cow.SLA - cow.averageSLA) / cow.SLA * 100).setScale(2));
                // Find out the SLA Compliance of the case owner
                cow.slaCompliance = Math.Round(((Decimal)cow.totalCompliantCount / cow.totalCount) * 100);
                // Find out the DIA Compliance of the case owner
                cow.diaCompliance = Math.Round(((Decimal)cow.totalDIACompliantCount / cow.totalCount) * 100);
                // Find out the goal % at case owner level:
                cow.goalPercentage = ( cow.goal == 0? 0: (((Decimal)cow.totalCount / cow.goal) * 100)  ).setScale(2);
                
                
                
                // For the overall summary, add the counts to overall count
                oData.overallTotalCount += recordCount;
                oData.overallTotalCompliantCount += compliantCount;
                oData.overallTotalDIACompliantCount += diaCompliantCount;
                oData.overallGoal += (recordCount == 0? 0 : totalGoal/ recordCount);
                
                // Store the total of SLA & TargetSLA for finding average later on:
                totalOverallTargetSLA += (cow.totalCount * cow.SLA);
                totalOverallAvgSLA += (cow.totalCount * cow.averageSLA);
            }
            // Findout the average at Priority Level:
            // Calculate the average SLA & TargetSLA (average values from the total and the total record counts)
            oData.overallSLA = (oData.overallTotalCount == 0 ? 0 :  Math.round(totalOverallTargetSLA / oData.overallTotalCount)  );
            oData.overallAverageSLA = (oData.overallTotalCount == 0 ? 0 :  totalOverallAvgSLA / oData.overallTotalCount  );
            // Find out the overall SLA adherence:
            oData.overallSLAAdherence = ((oData.overallSLA ==null || oData.overallSLA ==0) ? 0: ((oData.overallSLA - oData.overallAverageSLA) / oData.overallSLA * 100).setScale(2));
            // Find out the overall SLA Compliance
            oData.overallSLACompliance = Math.Round(((Decimal)oData.overallTotalCompliantCount / oData.overallTotalCount) * 100);
            // Find out the overall DIA Compliance
            oData.overallDIACompliance = Math.Round(((Decimal)oData.overallTotalDIACompliantCount / oData.overallTotalCount) * 100);
            // Find out the overall goal %
            oData.overallGoalPercentage = ( oData.overallGoal == 0? 0: (((Decimal)oData.overallTotalCount / oData.overallGoal) * 100)  ).setScale(2);
        }
        return oData;
    }
}