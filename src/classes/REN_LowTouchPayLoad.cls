public with sharing class REN_LowTouchPayLoad {
    public String status {get; set;}
    public String action {get;set;}
    public List<mainData> data {get;set;}
    public List<mainData> included {get; set;}
    public List<Error> errors {get;set;}
	public definitionsMain meta {get; set;}
	public Map<String, String> links {get;set;}
    
    public class mainData{
		public String type {get;set;}
	    public String Id {get;set;}
	    public Map<String, String> attributes{get;set;}
	    public Map<String, String> links {get;set;}
	    public Map<String, relatedData> relationships {get;set;}
	}

    public class relatedData{
		public Map<String, String> links {get;set;}
	    public Map<String, String> data {get;set;}
	}
	
    public class definitionsMain{
    	public Map<String, metaData> definitions {get;set;}
    }
    
    public class metaData {
		public String title	{get; set;}
		public String type	{get; set;}
		public Map<String, fieldProperties> properties {get; set;}
		public Map<String, metaData> relationships {get; set;}
		public Set<String> required {get; set;}
	}   
	
	public class fieldProperties {
		public String title {get; set;}
		public String type {get; set;}
        public Boolean display {get; set;}
		public Boolean dbRequired {get; set;}
		public String apiName {get; set;}
        public Integer order {get; set;}
	}
	
	public class Error {
		public String status {get; set;}
		public String source  {get; set;}
		public String title  {get; set;}
		public String detail  {get; set;}
	}
	
}