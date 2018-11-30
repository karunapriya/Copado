/**
* @description    CHL_DetailTabResponseWrapper class is used to construct JSON response structure of details tab in community
*/
public with sharing class CHL_DetailTabResponseWrapper {
	
	public string heading;
	public List<CHL_Details> details;
	public String accId;
	public CHL_Opportunity opp;
	
	public class CHL_Details {
		public String label;
		public String displayValue;
		public String relatedTo;
		public String relatedId;
		public String viewType;
	}
	
	public class CHL_Opportunity {
		public String acctId;
		public String oppId;
		public String oppName;
		public String acctName;
	}
	
}