public with sharing class CSM_CustomGridInputWrapper {

    public String objType;
    public CSM_CustomGridParams params;
    public String viewName;
    
    
  
    public with sharing class CSM_CustomGridParams {
        public String taskOrViewId;
        public String opptyId;
        public String accountId;
        public String healthStatus;
        public String dateRange;
        public String accountPlanId;
        public String selectedTaskFilter;
        public String selectedFilterClause;
        public String opportunityStage;     //This is created for Channel Partner Filters
        public String selectedQuarter;      //This is created for Channel Partner Filters
        public String gridCurrency;
        public CSM_UserPreferencesFilterWrapper userPrefWrapper;
        public string dialogBoxValue;
        public String isValidRli;
        public String currencyCode;
        public String PriceBook;
        public List<String> IdSet;
        public String objectName;
        public String fieldSetName;
        public String responseStr;
        public Boolean hasMassUpdateAccess;
        public Integer recordLimit;
    }
}