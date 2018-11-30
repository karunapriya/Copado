public with sharing class CHL_PortalContentWrapper {
    
    public string label{get;set;}
    public string url{get;set;}
    public string description{get;set;}
    public string type{get;set;}
    //public string category{get;set;}
    public List<CHL_Category> children{get;set;}
    //public Map<String, CHL_Category> items{get;set;}
    
    public class CHL_Category {
    	public string label{get;set;}
	    public string url{get;set;}
	    public string description{get;set;}
	    public string type{get;set;}
    }
}