/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.22.2014
* @description    CSM_FocusCategoriesColumnWrapper class holds all the Focus Categories Column  
*/
public with sharing class CSM_FocusCategoryColumnWrapper implements Comparable {
	public Integer UniqueId {get; set;}
	public String GroupId {get; set;}
	public Boolean GroupHasTiles {get; set;}
	public String ColumnId {get; set;}
	public String ColumnOrder {get; set;}
	public String ColumnName {get; set;}
	public Boolean ColumnActive {get; set;}
	public Integer ColumnCategoryCount {get; set;}
	public List<CSM_FocusCategoryWrapper> ActiveCategoryList {get; set;}
	public List<String> ColumnNameList {get; set;}
	
	public CSM_FocusCategoryColumnWrapper() {
	}
	
	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
        
        // Cast argument to OpportunityWrapper
        CSM_FocusCategoryColumnWrapper compareToFCCatColumn = (CSM_FocusCategoryColumnWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        Integer cOrder = Integer.valueOf(ColumnOrder);
        Integer cmpCOrder = Integer.valueOf(compareToFCCatColumn.ColumnOrder);
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