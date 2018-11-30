/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.22.2014
* @description    CSM_FocusCategoriesGroupWrapper class holds all the Focus Categories Group  
*/
public with sharing class CSM_FocusCategoryGroupWrapper implements Comparable {
	public Integer UniqueId {get; set;}
	public String GroupId {get; set;}
	public String GroupType {get; set;}
	public String GroupOrder {get; set;}
	public String GroupName {get; set;}
	public String GroupOwnerName {get; set;}
	public String GroupOwnerId {get; set;}
	public Boolean GroupActive {get; set;}
	public Integer GroupColumnsCount {get; set;}
	
	/**
	* @description compareTo - Compare opportunities based on the opportunity amount.
	*
	* @return CSM_FocusCategoryGroupWrapper - compare and 
	*/
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        CSM_FocusCategoryGroupWrapper compareToFCCatGroup = (CSM_FocusCategoryGroupWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        Integer gOrder = Integer.valueOf(GroupOrder);
        Integer cmpGOrder = Integer.valueOf(compareToFCCatGroup.GroupOrder);
        if (gOrder > cmpGOrder) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (gOrder < cmpGOrder) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}