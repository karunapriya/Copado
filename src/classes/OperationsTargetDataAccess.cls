/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/29/2016
 * @description  Operations Target Data Access class
 */
public with sharing class OperationsTargetDataAccess
{
	/**
    * @description : This method returns a list of operation target line items for the given set of 
    *                operation targets
    * @param operation target ids
    * @return a list of operation target line items
    */
	/*public static List<Operations_Target_Line_Item__c> getOperationLineItemsByOperation(Set<String> operationTargets)	
	{   
		List<String> opTargetLIFieldList = new List<String>{Util.solnExtnNameSpace + 'Start_Date__c', Util.solnExtnNameSpace + 'End_Date__c', Util.solnExtnNameSpace + 'Target__c'};
	    Util.checkCRUD_FLS('Operations_Target_Line_Item__c', opTargetLIFieldList, Constants.DML_OPERATION_READ);
	
	    return [SELECT Id, Start_Date__c, End_Date__c, Target__c, LastModifiedById, LastModifiedDate 
                  FROM Operations_Target_Line_Item__c 
                 WHERE Operations_Target__c =:operationTargets 
                 ORDER BY Start_Date__c ASC];
	} */
	
    /**
    * @description : This method returns a list of operation line items for the given start ane end dates,
    *                caseRecordType caseOrigin and employee
    * @param start date
    * @param end date
    * @param case record type
    * @param case origin
    * @param employee
    * @return a list of operation target line items
    */
	public static List<Operations_Target_Line_Item__c> getOperationLineItems(Date startDate, Date endDate, 
	        String caseRecordType, String caseOrigin, String employee)	
	{
		String nameSpace = Util.solnExtnNameSpace;
		List<String> opTargetLIFieldList = new List<String>{nameSpace + 'Start_Date__c', 
			nameSpace + 'End_Date__c'};
	    Util.checkCRUD_FLS('Operations_Target_Line_Item__c', opTargetLIFieldList, Constants.DML_OPERATION_READ);
	    
	    List<String> opTargetFieldList = new List<String>{nameSpace + 'Employee__c',
	    	nameSpace + 'Case_Record_Type_Id__c', nameSpace + 'Case_Origin__c'};
	    Util.checkCRUD_FLS('Operations_Target__c', opTargetFieldList, Constants.DML_OPERATION_READ);
	    
		return [SELECT Id 
		          FROM Operations_Target_Line_Item__c 
                 WHERE Operations_Target__r.Employee__c = :employee
                   AND End_Date__c >= :endDate
                   AND Start_Date__c <= :startDate 
                   AND Operations_Target__r.Case_Record_Type_Id__c = :caseRecordType 
                   AND Operations_Target__r.Case_Origin__c = :caseOrigin LIMIT 5000];
	}
	
	/**
    * @description : This method returns a list of operation target line items for the given operations target
    * @param operation target
    * @return a map of operation target line items
    */
	public static Map<Id, Operations_Target_Line_Item__c> getOperationLineItemMapByOperation(Set<String> operationTargets)
	{
		String nameSpace = Util.solnExtnNameSpace;
		List<String> opTargetLIFieldList = new List<String>{nameSpace + 'Start_Date__c', 
			nameSpace + 'End_Date__c', nameSpace + 'Target__c'};
	    Util.checkCRUD_FLS('Operations_Target_Line_Item__c', opTargetLIFieldList, Constants.DML_OPERATION_READ);
	    
		return new Map<Id, Operations_Target_Line_Item__c>([SELECT Id, Start_Date__c, End_Date__c, Target__c, LastModifiedById, LastModifiedDate 
                                  					          FROM Operations_Target_Line_Item__c 
                                  					         WHERE Operations_Target__c IN :operationTargets LIMIT 5000]);
	}
	
	public static List<Operations_Target_Line_Item__c> getOperationLineItemListByOperationTargetIds(Set<String> operationTargets){
		String nameSpace = Util.solnExtnNameSpace;
		List<String> opTargetLIFieldList = new List<String>{nameSpace + 'Start_Date__c', 
			nameSpace + 'End_Date__c', nameSpace + 'Target__c'};
	    Util.checkCRUD_FLS('Operations_Target_Line_Item__c', opTargetLIFieldList, Constants.DML_OPERATION_READ);
	    
		return new List<Operations_Target_Line_Item__c>([SELECT Id, Start_Date__c, End_Date__c, Target__c, LastModifiedById, LastModifiedDate 
                                  					          FROM Operations_Target_Line_Item__c 
                                  					         WHERE Operations_Target__c IN :operationTargets ORDER BY Start_Date__c ASC Limit 5000]);
	}

    /**
    * @description : This method returns a list of operation target records for the given criteria checker value 
    * @param a set of criteria checker values
    * @return a list of operation target records
    */
    public static List<Operations_Target__c> getOperationTargetsByCriteria(Set<String> currentCriteriaCheckerSet)
    {
    	String nameSpace = Util.solnExtnNameSpace;
        List<String> opTargetLIFieldList = new List<String>{nameSpace + 'Criteria_Checker__c'};
	    Util.checkCRUD_FLS('Operations_Target__c', opTargetLIFieldList, Constants.DML_OPERATION_READ);
	    
        return [SELECT Id, Criteria_Checker__c 
                  FROM Operations_Target__c 
                 WHERE Criteria_Checker__c IN :currentCriteriaCheckerSet LIMIT 5000];
    }

    public static void updateOperationsTargetLineItems(List<Operations_Target_Line_Item__c> operationsTargetLineItems, 
            List<String> operationsLineItemsFieldList){
		Util.checkCRUD_FLS('Operations_Target_Line_Item__c', operationsLineItemsFieldList, Constants.DML_OPERATION_UPDATE);
		update operationsTargetLineItems;
	}
	
	public static void insertOperationsTargetLineItems(List<Operations_Target_Line_Item__c> operationsTargetLineItems, 
            List<String> operationsLineItemsFieldList){
		Util.checkCRUD_FLS('Operations_Target_Line_Item__c', operationsLineItemsFieldList, Constants.DML_OPERATION_INSERT);
		insert operationsTargetLineItems;
	}

}