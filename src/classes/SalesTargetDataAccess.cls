/**
 * @author       Nikita Konkar (nikita@comitydesigns.com)    
 * @date         08/23/2016
 * @description  Sales Target Data Access class
 */
public with sharing class SalesTargetDataAccess 
{
	/**
    * @description : This method returns a list of sales target records for the given criteria checker value 
    * @param a set of criteria checker values
    * @return a list of sales target records
    */
	public static List<Sales_Target__c> getSalesTargetsByCriteria(Set<String> currentCriteriaCheckerSet){
		List<String> salesTargetLIFieldList = new List<String>{Util.solnExtnNameSpace + Constants.ST_CRITERIA_CHECKER};
		Util.checkCRUD_FLS(Constants.OBJ_SALES_TARGET, salesTargetLIFieldList, Constants.DML_OPERATION_READ);
		return [SELECT Id, Criteria_Checker__c FROM Sales_Target__c WHERE Criteria_Checker__c IN :currentCriteriaCheckerSet];		
	}
	
	public static Map<ID, Sales_Target__c> getSalesTargetsByID(Set<ID> salesTargetIdSet){
		Util.checkCRUD_FLS(Constants.OBJ_SALES_TARGET, new List<String>{'CurrencyIsoCode'}, Constants.DML_OPERATION_READ);
		return new Map<ID, Sales_Target__c>([SELECT Id, CurrencyIsoCode FROM Sales_Target__c WHERE ID IN :salesTargetIdSet]);		
	}
	
	/**
    * @description : This method returns a map of sales target line item records by Id 
    * @param a set of Sales Target Line Item Id
    * @return a list of sales target records
    */
	public static Map<Id, Sales_Target_Line_Item__c> getSalesTargetLineItemMapById(Set<Id> salesTargetIdSet){
		String namespace = Util.solnExtnNameSpace;
		List<String> salesTargetLIFieldList = new List<String>{namespace+ Constants.ST_START_DATE, 
			namespace+Constants.ST_END_DATE, namespace+Constants.ST_TARGET, 
			namespace+Constants.OBJ_SALES_TARGET};
		Util.checkCRUD_FLS(Constants.OBJ_SALES_TARGET_LI, salesTargetLIFieldList, Constants.DML_OPERATION_READ);
		
		return new Map<Id, Sales_Target_Line_Item__c>([SELECT Id, Start_Date__c, End_Date__c, Target__c, LastModifiedById, LastModifiedDate, CurrencyIsoCode 
                                  											FROM Sales_Target_Line_Item__c WHERE Sales_Target__c IN: salesTargetIdSet]);	
	}
	
	public static List<Sales_Target_Line_Item__c> getSalesTargetLineItemByStartDate(Set<Id> salesTargetIdSet){
		String namespace = Util.solnExtnNameSpace;
		List<String> salesTargetLIFieldList = new List<String>{namespace + Constants.ST_START_DATE, 
			namespace + Constants.ST_END_DATE, namespace + Constants.ST_TARGET, 
			namespace + Constants.OBJ_SALES_TARGET};
		Util.checkCRUD_FLS(Constants.OBJ_SALES_TARGET_LI, salesTargetLIFieldList, Constants.DML_OPERATION_READ);
		
		return [SELECT Id, Start_Date__c, End_Date__c, Target__c, LastModifiedById, LastModifiedDate 
                                  				FROM Sales_Target_Line_Item__c WHERE Sales_Target__c IN:salesTargetIdSet ORDER BY Start_Date__c ASC];
	}
	
	/**
    * @description : This method returns a list of sales target line item records whose employees have to achieve Target Opportunity 
    * @param a set of Opportunity Id
    * @return a list of sales target line item records
    */
	public static List<Sales_Target_Line_Item__c> getSalesTargetLineItemByEmployee(Set<Id> oppIds){
		String namespace = Util.solnExtnNameSpace;
		List<String> salesTargetLIFieldList = new List<String>{namespace+Constants.ST_END_DATE,
			namespace+Constants.ST_START_DATE};
		Util.checkCRUD_FLS(Constants.OBJ_SALES_TARGET_LI, salesTargetLIFieldList, Constants.DML_OPERATION_READ);
		
		List<String> salesTargetFieldList = new List<String>{namespace+Constants.ST_EMPLOYEE};
		Util.checkCRUD_FLS(Constants.OBJ_SALES_TARGET, salesTargetFieldList, Constants.DML_OPERATION_READ);
		
		return [SELECT Id , Sales_Target__r.Employee__c,Sales_Target_Line_Item__c.End_Date__c,Sales_Target_Line_Item__c.Start_Date__c FROM Sales_Target_Line_Item__c WHERE Sales_Target__r.Employee__c IN: oppIds];
	}
	
	public static void updateSalesTargetLI(List<Sales_Target_Line_Item__c> salesTargetLiList, List<String> salesTargetLIFieldList){
		Util.checkCRUD_FLS('Sales_Target_Line_Item__c', salesTargetLIFieldList, Constants.DML_OPERATION_UPDATE);
		update salesTargetLiList;
	}	
	
	public static void insertSalesTargetLI(List<Sales_Target_Line_Item__c> salesTargetLiList, List<String> salesTargetLIFieldList){
		Util.checkCRUD_FLS('Sales_Target_Line_Item__c', salesTargetLIFieldList, Constants.DML_OPERATION_INSERT);
		insert salesTargetLiList;
	}	
	
    
}