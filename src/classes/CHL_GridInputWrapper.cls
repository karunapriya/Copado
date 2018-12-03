public with sharing class CHL_GridInputWrapper {
	public CHL_CustomGridParams queryParams{get;set;}
  	public String gridType{get;set;}  
  	public String q{get;set;} //This will be used as search string to show grid results based on search string. Created as part of US1624
  	public string ot; //This will be used to identify object type while loading serach results for respective tabs. Created for US1624
  	public Integer lm; //This will be used to identify limit for SOSL Query to show results on Top Results / Individual grids. Created for US1624 
	public Integer id;
	public String name;
	public CHL_Query query {get;set;}
	public string filters;

	public with sharing class CHL_CustomGridParams {
		public String currentQuarter;
	    public String oppsType;
	    public String stage;
	    public set<String> resellerReps;
	    public set<String> distributorReps;
	    public set<String> countries;
	    public Set<String> quarters;
	    public Set<String> years;
	    public String needColDef;
	    public String requestType;
	    public string accountID;
	    public string oppID;
	    public string caseID;
	    public string requestId;
	    public String q;
	 }
	 
	public with sharing class CHL_Query {
		public String name;
		public Boolean hasLogic;
		public String logic;
		public List<CHL_GridFilterParams> filters {get; set;}
	}
	public with sharing class CHL_GridFilterParams {
		//public List<CHL_GridParamsOption> value;
		public string value;
		public List<CHL_GridParamsOption> values {get; set;}
		public String minValue;
		public String maxValue;
		public CHL_GridParamsPredicate predicate {get; set;}
		public CHL_GridParamsOperator operator {get; set;}
		public Integer index;	
	}

	public class CHL_GridParamsPredicate {
		public String type {get; set;}
		public String objectType {get; set;}
		public String apiName{get; set;}
		
	}
	public class CHL_GridParamsOperator {
		public String id {get; set;}
		public String value {get; set;}
	}
	public class CHL_GridParamsOption {
		public String id {get; set;}
		public String name {get; set;}
	}
  
}