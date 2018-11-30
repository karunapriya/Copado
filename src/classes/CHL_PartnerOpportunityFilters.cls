public with sharing class CHL_PartnerOpportunityFilters {
    
    public list<CHL_OptyTypes> oppTypes{get;set;}
    public list<CHL_Quarters> quarters{get;set;}
    public integer maximumDaysBetweenUpdates{get;set;}
    public CHL_BulkUpdateOptions bulkUpdateOptions {get;set;}
    public list<CHL_CaseTypes> caseTypes{get;set;}
    public List<CHL_Years> years{get;set;}
    public CHL_CurrentYear currentYear{get;set;}
    public CHL_CurrentQuarter currentQuarter{get;set;}
    
    public class CHL_BulkUpdateOptions{
		//public list<string> stages{get;set;}
     	public list<CHL_ResellerReps> resellerReps{get;set;}
     	public list<CHL_DistributorReps> distributorReps{get;set;}  
     	public list<CHL_Stages> stages{get;set;}
    }
    
    public class CHL_ResellerReps{
		public String name{get;set;}
		public String id{get;set;}
    }
    
    public class CHL_DistributorReps{
		public String name{get;set;}
		public String id{get;set;}
    }
    
    public class CHL_OptyTypes{
        public String id{get;set;}
        public String name{get;set;}
    }
    
    public class CHL_CaseTypes{
        public String id{get;set;}
        public String name{get;set;}
    }
    
   	public class CHL_Stages{
        public String id{get;set;}
        public String name{get;set;}
    }
    
    
}