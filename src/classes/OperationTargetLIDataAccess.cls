/**
 * Created Date		: Aug 30, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dilip					User Story				Aug 30, 2018			1.1					@description
 *
 */
public with sharing class OperationTargetLIDataAccess {
    public static Map<Id,List<Operations_Target_Line_Item__c>> getOperationLineItemsByEmpId(Set<Id> empIdSet){
        String nameSpace = Util.solnExtnNameSpace;
        Util.checkCRUD_FLS('Operations_Target_Line_Item__c', new List<String>{nameSpace + 'Start_Date__c', 
            nameSpace + 'End_Date__c'}, Constants.DML_OPERATION_READ);
        
        Util.checkCRUD_FLS('Operations_Target__c', new List<String>{nameSpace + 'Employee__c',
            nameSpace + 'Case_Record_Type_Id__c', nameSpace + 'Case_Origin__c'}, Constants.DML_OPERATION_READ);
        
        Map<Id,List<Operations_Target_Line_Item__c>> empIdToOPTLIListMap = new Map<Id,List<Operations_Target_Line_Item__c>>();
        for(Operations_Target_Line_Item__c optliObj : [SELECT Id, Start_Date__c, End_Date__c, Operations_Target__r.Employee__c, Operations_Target__r.Case_Record_Type_Id__c, Operations_Target__r.Case_Origin__c FROM Operations_Target_Line_Item__c WHERE Operations_Target__r.Employee__c In :empIdSet]){
            if(empIdToOPTLIListMap.containsKey(optliObj.Operations_Target__r.Employee__c)){
                empIdToOPTLIListMap.get(optliObj.Operations_Target__r.Employee__c).add(optliObj);
            }else{
                empIdToOPTLIListMap.put(optliObj.Operations_Target__r.Employee__c, new List<Operations_Target_Line_Item__c>{optliObj});
            }
        }
        return empIdToOPTLIListMap;
    }
}