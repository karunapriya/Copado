// Controller class for reactive dashboard component
global with sharing class ReactiveDashboardComponentController{

    public String dataSetKey {get;set;}
    public transient ReactiveProdDashboardController parentController {get;set;}
    public transient overallWrapperData allData {get;set;}
    
    public String dashboardSpecificCondition {get;set;}
    private static Set<String> caseRecordTypesToExclude = new Set<String>{'Master','Opportunity Creation Request'};
    private static Set<String> casePriorityValues = new Set<String>{'High','Normal','Low'};
    
    // String acting as the place holder for Q0Metrics, when passed, sets the q0DIAMetrics value to be displayed in the page:
    public String allDataPlaceholder{get;set{if(value != null){ allData = (overallWrapperData)JSON.deserialize(value, overallWrapperData.class);}}}
    
    
    // Wrapper class for storing the summary at case owner level
    global class UserWrapper{
        public Integer totalCount {get;set;}
        public Integer SLA {get;set;}        // 'Target SLA' Column on VF
        public Decimal averageSLA {get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        public Integer totalCountCompliant {get;set;}
        
        public UserWrapper(){
            totalCount = 0;
            SLA = 0;
            averageSLA = 0;
            slaAdherence = 0;
            slaCompliance = 0;
            totalCountCompliant = 0;
        }
    }
    
    // Wrapper class for storing the summary at Case priority level
    global class PriorityWrapper{
        public Integer totalCount {get;set;}
        public Integer SLA {get;set;}       // 'Target SLA' Column on VF
        public Decimal averageSLA {get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        public Integer totalCountCompliant {get;set;}
        
        public Map<String,UserWrapper> usersMap {get;set;}

        public PriorityWrapper(){
            usersMap = new Map<String,UserWrapper>();
            totalCount = 0;
            SLA = 0;
            averageSLA = 0;
            slaAdherence = 0;
            slaCompliance = 0;
            totalCountCompliant = 0;
        }
    }
    
    // Wrapper class for storing the summary at owner office level
    global class OwnerOfficeWrapper{
        public Integer totalCount {get;set;}
        public Integer SLA {get;set;}           // 'Target SLA' Column on VF
        public Decimal averageSLA {get;set;}
        public Decimal slaAdherence {get;set;}
        public Integer slaCompliance {get;set;}
        public Integer totalCountCompliant {get;set;}
        
        public Map<String,PriorityWrapper> prioritiesMap {get;set;}
        public OwnerOfficeWrapper(){
            prioritiesMap = new Map<String,PriorityWrapper>();
            totalCount = 0;
            SLA = 0;
            averageSLA = 0;
            slaAdherence = 0;
            slaCompliance = 0;
            totalCountCompliant = 0;
        }
    }
    
    // Wrapper class for storing the over all counts and the ownerOfficeMap variable referenced by the component
    global class overallWrapperData{
        public Map<String,OwnerOfficeWrapper> allOwnerOfficeMap{get;set;}
        public Integer overallTotalCount {get;set;}
        public Integer overallSLA {get;set;}
        public Decimal overallAverageSLA {get;set;}
        public Decimal overallSLAAdherence {get;set;}
        public Integer overallTotalCountCompliant{get;set;}
        public Integer overallSLACompliance {get;set;}
        
        public overallWrapperData(){
            allOwnerOfficeMap = new Map<String,OwnerOfficeWrapper>();
            overallTotalCount = 0;
            overallSLA = 0;
            overallAverageSLA = 0;
            overallSLAAdherence = 0;
            overallTotalCountCompliant = 0;
            overallSLACompliance = 0;
        }
    }
    // because constructor doesn't get all this attribute values, initAll is used
    public ReactiveDashboardComponentController(){}
    
    // This method is just a place holder for setting the values (which came from the remote action call) into the wrapper of this controller
    public void updateValues(){}

    // Componennt's init Method: Initializes all value from parent controller:
    public string getInitAll(){
        //Get the query conditions from the parent:
        dashboardSpecificCondition =  parentController.getQueryCondition(dataSetKey) + parentController.filterConditions;
        return null;
    }
    // Map to store all Users' Owner office details (company name field)
    public Static Map<String,String> allUsersMap {
        get{
            if(allUsersMap == null){
                // For the very first time define the user map:
                allUsersMap = new Map<String,String>();
                for(User u: UserDataAccess.getAllUsers()){
                    allUsersMap.put(u.Id,u.CompanyName);
                }
            }
            return allUsersMap;
        }
        set;
    }
    
    // From the Owner Id, determine the Owner office (For Queue: Queue name; For Users, user's companyName field )
    public static String findOwnerOffice(String ownerId, String OwnerName){
        // For Queue as owner, Owner office would be Queue Name
        String ownerOffice = OwnerName;
        // if user is owner, fetch the company name from User Map
        if(ownerId != null && ownerId.startsWith('005')){
            ownerOffice = allUsersMap.get(ownerId);
        }
        // If no owner office found, send 'N/A'
        return (ownerOffice != null ? ownerOffice : 'N/A');
    }
    
    // Remote action method to get the dashboard element data; 
    // Record type filter and page level filters are passed in aditionalFilterConditions variable from the page
    @RemoteAction @ReadOnly
    global static overallWrapperData fetchDashboardData(String aditionalFilterConditions){
        overallWrapperData oData = new overallWrapperData();
        // Fetch the metrics for User level grouping:
       
        List<AggregateResult> lsUserGroupData = MilestoneDataAccess.getDynamicCaseMilestone(aditionalFilterConditions,  caseRecordTypesToExclude);
       
        // From the Owner-Priority level aggregate results, fill the User level columns details of the dashboard element:
        if(lsUserGroupData != null && lsUserGroupData.size() > 0 ){  
            for(AggregateResult agr: lsUserGroupData){
                // Group by Owner Office, if not defined, set to 'N/A' group
                //String ownerOffice = (agr.get('ownerOffice') != null ? String.valueOf(agr.get('ownerOffice')) : 'N/A');
                String ownerId = (agr.get('ownerId') != null ? String.valueOf(agr.get('ownerId')) : 'N/A');
                String ownerName = (agr.get('ownerName') != null ? String.valueOf(agr.get('ownerName')) : 'N/A');
                String ownerOffice = findOwnerOffice(ownerId,OwnerName);
                String priority = String.valueOf(agr.get('priority'));
                
                Integer recordCount = ( agr.get('recordCount') == null ? 0 : Integer.valueOf(agr.get('recordCount')) );
                Integer compliantCount = ( agr.get('compliantCount') == null ? 0 : Integer.valueOf(agr.get('compliantCount')) );
                Integer totalTargetSLA = (agr.get('totalTargetSLA') != null ? Integer.valueOf(agr.get('totalTargetSLA')) : 0);
                Decimal totalSLA = (agr.get('totalSLA') != null ? Double.valueOf(agr.get('totalSLA')) : 0);
                
                // Create the User Wrapper and populate its values:
                UserWrapper uw = new UserWrapper();
                uw.totalCount = recordCount;
                uw.totalCountCompliant = compliantCount;
                // Calculate the average SLA & TargetSLA (averages)
                uw.SLA = (recordCount == 0 ? 0 :  Math.round(totalTargetSLA / recordCount)  );
                uw.averageSLA = (recordCount == 0 ? 0 :  totalSLA / recordCount  );
                // Findout the OwnerOffice level level SLA Adherence from SLA & Average SLA
                uw.slaAdherence = ((uw.SLA == null || uw.SLA == 0) ? 0 : ((uw.SLA - uw.averageSLA) / uw.SLA * 100).setScale(2));
                // OwnerOffice level SLA compliance % = Number of Compliant records / Total records * 100;
                uw.slaCompliance = ( uw.totalCount == 0 ? 0 : Math.Round(((Decimal)uw.totalCountCompliant / uw.totalCount) * 100) );
                
                // Check if the OwnerOffice entry exists already or not:
                if(oData.allOwnerOfficeMap.get(ownerOffice) == null){
                    oData.allOwnerOfficeMap.put(ownerOffice,new OwnerOfficeWrapper());
                }
                // Get the previously set Owner Office value from the map (the priority map will be added to this owner office wrapper)
                OwnerOfficeWrapper oow = oData.allOwnerOfficeMap.get(ownerOffice); 
                // Check if the priority entry alreday exists in the map or not:
                if(oow.prioritiesMap.get(priority) == null){
                    oow.prioritiesMap.put(priority, new PriorityWrapper());
                }
                // Get the Priority Map from given Priority
                PriorityWrapper pw = oow.prioritiesMap.get(priority);
                pw.usersMap.put(ownerName, uw);
            }
            
            // Once the User level values are populated, populate the Priority level values:
            Decimal totalOverallTargetSLA = 0, totalOverallAvgSLA = 0;
            for(OwnerOfficeWrapper oow : oData.allOwnerOfficeMap.values()) {
                Decimal totalOwnerOfficeTargetSLA = 0, totalOwnerOfficeAvgSLA = 0;
                // Get the prioirties map:
                for(PriorityWrapper pw : oow.prioritiesMap.values()) {
                    Decimal totalPriorityTargetSLA = 0, totalPriorityAvgSLA = 0;
                    // Loop through all users under the priority:
                    for(UserWrapper uw: pw.usersMap.values()){
                        // Increment the priority level values:
                        pw.totalCount += uw.totalCount;
                        pw.totalCountCompliant += uw.totalCountCompliant;
                        totalPriorityTargetSLA += (uw.totalCount * uw.SLA);
                        totalPriorityAvgSLA += (uw.totalCount * uw.averageSLA);
                        
                        // Increment the Owner office level values:
                        oow.totalCount +=uw.totalCount;
                        oow.totalCountCompliant += uw.totalCountCompliant;
                        totalOwnerOfficeTargetSLA += (uw.totalCount * uw.SLA);
                        totalOwnerOfficeAvgSLA += (uw.totalCount * uw.averageSLA);
                        // Increment the overall total (summary level) values:
                        oData.overallTotalCount += uw.totalCount;
                        oData.overallTotalCountCompliant += uw.totalCountCompliant;
                        totalOverallTargetSLA += (uw.totalCount * uw.SLA);
                        totalOverallAvgSLA += (uw.totalCount * uw.averageSLA);
                    }
                    // Findout the average at Priority Level:
                    // Calculate the average SLA & TargetSLA (average values from the total and the total record counts)
                    pw.SLA = (pw.totalCount == 0 ? 0 :  Math.round(totalPriorityTargetSLA / pw.totalCount)  );
                    pw.averageSLA = (pw.totalCount == 0 ? 0 :  totalPriorityAvgSLA / pw.totalCount  );
                    // Findout the Priority level level SLA Adherence from SLA & Average SLA
                    pw.slaAdherence = ((pw.SLA == null || pw.SLA == 0) ? 0 : ((pw.SLA - pw.averageSLA) / pw.SLA * 100).setScale(2));
                    // Priority level SLA compliance % = Number of Compliant records / Total records * 100;
                    pw.slaCompliance = ( pw.totalCount == 0 ? 0 : Math.Round(((Decimal)pw.totalCountCompliant / pw.totalCount) * 100) );
                }
                
                // Check if all the priority groups (High/Normal/Low) exists or not. If doesn't exist, set default values (0 for all columns)
                for(String prio : casePriorityValues){
                    if(oow.prioritiesMap.get(prio) == null){
                        oow.prioritiesMap.put(prio,new PriorityWrapper());
                    }
                }
                
                // Findout the average at Owner Office Level:
                // Calculate the average SLA & TargetSLA (average values from the total and the total record counts)
                oow.SLA = (oow.totalCount == 0 ? 0 :  Math.round(totalOwnerOfficeTargetSLA / oow.totalCount)  );
                oow.averageSLA = (oow.totalCount == 0 ? 0 :  totalOwnerOfficeAvgSLA / oow.totalCount  );
                // Findout the OwnerOffice level level SLA Adherence from SLA & Average SLA
                oow.slaAdherence = ((oow.SLA == null || oow.SLA == 0) ? 0 : ((oow.SLA - oow.averageSLA) / oow.SLA * 100).setScale(2));
                // OwnerOffice level SLA compliance % = Number of Compliant records / Total records * 100;
                oow.slaCompliance = ( oow.totalCount == 0 ? 0 : Math.Round(((Decimal)oow.totalCountCompliant / oow.totalCount) * 100) );
            }
            // Findout the average at overall summary Level:
            // Calculate the average SLA & TargetSLA (average values from the total and the total record counts)
            oData.overallSLA = (oData.overallTotalCount == 0 ? 0 :  Math.round(totalOverallTargetSLA / oData.overallTotalCount)  );
            oData.overallAverageSLA = (oData.overallTotalCount == 0 ? 0 :  totalOverallAvgSLA / oData.overallTotalCount  );
            // Findout the summary level level SLA Adherence from SLA & Average SLA
            oData.overallSLAAdherence = ((oData.overallSLA == null || oData.overallSLA == 0) ? 0 : ((oData.overallSLA - oData.overallAverageSLA) / oData.overallSLA * 100).setScale(2));
            // Summary level SLA compliance % = Number of Compliant records / Total records * 100;
            oData.overallSLACompliance = ( oData.overallTotalCount == 0 ? 0 : Math.Round(((Decimal)oData.overallTotalCountCompliant / oData.overallTotalCount) * 100) );
        }        
        return oData;
    }
}