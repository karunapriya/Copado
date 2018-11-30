public with sharing class CSM_UserPreferencesFilterWrapper {
	
	public String attrFieldName{get; set;}
	public String attrFieldType {get; set;}
	public String attrFieldValue {get; set;}
	public String attrFieldUserId {get; set;}
	public Date attrFieldDateValue {get; set;}
	public boolean showInactive {get; set;}
	public Set<Id> attrSPAccountIdsList {get;set;}
	public String attObjectType {get;set;}
	
	public String overviewCarouselChart{get;set;}
	public String overviewFCGroupFilter{get;set;} 
	public String successPlanActionsFilter{get;set;}
 	public String successPlanActionsGridColumns{get;set;} 
 	public String successPlanActivityGridColumns{get;set;}
 	public String successTaskFilter{get;set;}
 	public String successTaskGridColumns{get;set;}	

	public CSM_UserPreferencesFilterWrapper(){
		
	}
}