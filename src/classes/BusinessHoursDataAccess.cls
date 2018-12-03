/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/29/2016
 * @description  BusinessHours Data Access class
 */
public with sharing class BusinessHoursDataAccess{
	/**
    * @description : This method returns a list of business hours records by default
    * @param boolean is default flag
    * @return a list of business hours
    */
	public static List<BusinessHours> getBusinessHoursListByDefault(Boolean defaultFlag){
		List<String> businessFields = new List<String> {'ID','IsDefault'};
		//Util.checkCRUD_FLS('BusinessHours', businessFields, Constants.DML_OPERATION_READ);
		return [SELECT Id FROM BusinessHours WHERE IsDefault = :defaultFlag limit 999];
	}
	
}