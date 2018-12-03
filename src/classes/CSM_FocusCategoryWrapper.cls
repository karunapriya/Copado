/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.22.2014
* @description    CSM_FocusCategoryWrapper class holds all the Focus Categories Column  
*/
public with sharing class CSM_FocusCategoryWrapper implements Comparable {
	public String UniqueId {get; set;}
	public String ColumnId {get; set;}
	public String CategoryViewId {get; set;}
	public String CategoryId {get; set;}
	public String CategoryOrder {get; set;}
	public String CategoryDisplayName {get; set;}
	public String CategoryObjType {get; set;}
	public String CategoryFieldType {get; set;}
	public Boolean CategoryActive {get; set;}
	public Integer CategoryCount {get; set;}
	public String Criteria {get; set;}
	public String Columns {get; set;}
	public List<colNameForAPI> ColumnNameList {get; set;}
	public List<colNameForAPI> ColumnNameLimitList {get; set;}
	public String SOQL {get; set;}
	public String ViewURL {get; set;}
	public List<SObject> ListSObject {get; set;}
	public Map<Id,boolean> sObjectHasEditAccess {get; set;}
	public Double totalCurrencyAmount{get; set;}
	public String headerCurrencyFieldName {get; set;}
	public String headerCurrencyCode {get; set;}
	public String linkName {get;set;}
	public Boolean isTiles {get;set;} // Added for US2118
	public String fcvFilter {get;set;} 	

	public String CriteriaJSON {get; set;}
	public List<CSM_Focus_Category_View_Criteria__c> CriteriaObjList {get; set;}
	
	public with sharing class colNameForAPI {
		public String apiName {get; set;}
		public String displayName {get; set;}
		public String fieldType {get; set;}
		public String refFieldId {get; set;}
		public String lookUpField {get; set;}
	}
	
	public CSM_FocusCategoryWrapper() {
	}

	
	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        CSM_FocusCategoryWrapper compareToFC = (CSM_FocusCategoryWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        Integer cOrder = Integer.valueOf(CategoryOrder);
        Integer cmpCOrder = Integer.valueOf(compareToFC.CategoryOrder);
        if (cOrder > cmpCOrder) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (cOrder < cmpCOrder) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}