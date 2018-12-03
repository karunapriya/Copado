// Utility Class for custom dashboard components
public with sharing Class DashboardUtil{
    private static Set<String> managerRoles = new Set<String> {'Operations_Rep','Operations_Manager','Operations_Director','VP_Operations_Services','WW_Exec'};
    private static Map<Id,UserRole> allRolesMap;
    
    // From the given decimals, return the average
    public static Decimal findAverage(List<Decimal> lstValues) {
     /*   if(lstValues != null && lstValues.size() >0){
            Decimal total=0;
            for(Decimal i: lstValues) {
                total+= (i == null ? 0 :i);
            }
            return (total/lstValues.size()).setScale(2);
        }*/
        return 0;
    }
    
    // Build a picklist of values based upon the passed information
    public static List<selectOption> getPicklistValues(String objectName, String fieldName, String firstValue) {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        // If there is a first value being provided, add as the first option
        if (firstValue != null) { 
            options.add(new selectOption(firstValue, firstValue));
        }

        // Describe the sobject & get a map of fields for the passed sobject
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldMap = sObj.getDescribe().fields.getMap();
        // Grab the list of picklist values for the passed field on the sobject
        if(fieldMap.get(fieldName) != null) {
            List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
            // Add the value and label to the final selectoption list
            for(Schema.PicklistEntry a : picklistValues) {
                options.add(new selectOption(a.getLabel(), a.getValue()));
            }
        }
        return options; //return the List
    }
    
    
    // Return all report details from the custom setting (Zenith_Report_Urls)
    public static Map<String,String> fetchReportDetails(){
        // Get all reports' developer names from the custom setting:
        List<Zenith_Report_Urls__c> allReportSettings = Zenith_Report_Urls__c.getAll().values();
        
        // Collect Report Unique Namess:
        List<String> repUniqeNames = new List<String>();
        for(Zenith_Report_Urls__c rep: allReportSettings) {
            repUniqeNames.add(rep.Report_Unique_Name__c);
        }
        return fetchReportIds(repUniqeNames);
    }
    
    public static Map<String,String> fetchReportIds(List<String> lstReportDevloperNames){
        Map<String,String> allReportMap = new Map<String,String>();
        List<Report> allReports = ReportDashboardDataAccess.getReportsByDeveloperName(new Set<String>(lstReportDevloperNames));
        for(Report rep: allReports) {
            allReportMap.put(rep.DeveloperName, rep.Id);
        }
        return allReportMap;
    }
    
    // Return all values from a picklist/selectOption concatenated in a string (Do NOT omit the
    public static String concatenateAllOptions(List<SelectOption> allOptions){
        String result = '';
        if(allOptions != null ) {
            for(SelectOption so: allOptions) {
                result += ((so.getValue() != null && so.getValue() != 'None') ? so.getValue()+',' : '');
            }
        }
        return result;
    }
    
    
    // Get all sub ordinates for current user:
    public static Map<Id,User> getRoleSubordinateUsers() {
        Map<Id,User> users = new Map<Id,User>();
        if(UserInfo.getUserRoleId() != null) {
            String userRoleName = getUserRoleDeveloperName(UserInfo.getUserRoleId());
            users = UserDataAccess.getUserMapByIdsAndRoles(new Set<String> {UserInfo.getUserRoleId()},managerRoles,userRoleName);
        }
        // If nothing found, return empty map
        return users;
    }
    
    public static String getUserRoleDeveloperName(Id RoleId){
        String roleDevName;
        // Get the role's developer name from the given Id:
        if(allRolesMap == null) {
            allRolesMap = UserDataAccess.getAllUserRoles();
        }
        if(allRolesMap.get(RoleId) != null)
            roleDevName = allRolesMap.get(RoleId).DeveloperName;
        return roleDevName;
    }
}