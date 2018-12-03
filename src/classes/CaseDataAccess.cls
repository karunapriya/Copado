/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/27/2016
 * @description  Case Data Access class
 */
public with sharing class CaseDataAccess{
	/**
    * @description : This method returns a list of cases for the given set of case ids
    * @param a set of case ids
    * @return a list of cases
    */
	public static List<Case> getCasesByIds(Set<Id> caseIds)	{
		String nameSpace = Util.solnExtnNameSpace;
		List<String> caseFields = new List<String> {'ParentId', nameSpace +'Opportunity_Earliest_Existing_End_Date__c', 
			nameSpace +'Target_DIA__c'};
		Util.checkCRUD_FLS('Case', caseFields, Constants.DML_OPERATION_READ);
		return [SELECT Id, ParentId, Opportunity_Earliest_Existing_End_Date__c, Target_DIA__c FROM Case WHERE Id = :caseIds limit 50000];
	}
	
	/**
    * @description : This method returns a list of cases for the given set of case opportunities and closed flag
    * @param a set of opportunity ids
    * @param whether the case is closed or not
    * @return a list of cases
    */
	public static List<Case> getCasesByOpportintyAndClosed(Set<String> oppList, set<boolean> isClosedFlag){
		List<String> caseFields = new List<String> {Util.solnExtnNameSpace +'Opportunity__c'};
		Util.checkCRUD_FLS('Case', caseFields, Constants.DML_OPERATION_READ);
		return [SELECT Id, Status,Total_Resolved_Business_Hour_min__c,CreatedDate, Origin, RecordTypeId,Operations_Target__c,OwnerId FROM Case WHERE Opportunity__c IN :oppList AND IsClosed in :isClosedFlag limit 50000];
	}
	
	/**
    * @description : This method returns a list of cases based on the zenith setting record types and for the given set of case ids
    * @param a set of case ids
    * @return a list of cases
    */
	public static List<Case> getCasesByRecordTypeAndIds(Set<Id> caseIds){   
		List<String> caseFields = new List<String> {'RecordTypeId'};
		Util.checkCRUD_FLS('Case', caseFields, Constants.DML_OPERATION_READ);
		Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
		return [SELECT Id, 
            Status 
            FROM Case 
            WHERE (RecordTypeId = :ZS.Case_Booking_Request_Record_Type_Id__c OR RecordTypeId = :ZS.Case_Quote_Request_Record_Type_Id__c) 
            AND Id = :caseIds limit 50000];
	}
	public static List<Case> getCasesByRecordTypeAndIds(List<Case> csList){   
		List<String> caseFields = new List<String> {'RecordTypeId'};
		Util.checkCRUD_FLS('Case', caseFields, Constants.DML_OPERATION_READ);
		Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
		return [SELECT Id, 
            Status 
            FROM Case 
            WHERE (RecordTypeId = :ZS.Case_Booking_Request_Record_Type_Id__c OR RecordTypeId = :ZS.Case_Quote_Request_Record_Type_Id__c) 
            AND Id IN :csList limit 50000];
	}
	
	/**
    * @description : This method returns a list of recordtype id based on the case 
    * @param a set of record type id
    * @return a list of record type id
    */
	public static List<RecordType> getRecordTypeIdByCase(Set<Id> recordTypeIds){
		return [SELECT Id, Name 
            FROM RecordType 
            WHERE SobjectType = 'Case' 
            AND (Name = 'Booking Request' OR Name = 'Quote Request')];
		
	}
	
	/**
    * @description : This method updates cases
    * @param a list of cases
    */
	public static void updateCases(List<Case> updatedCasesList, List<String> caseFieldList){
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_UPDATE);
		update updatedCasesList;
	}	
	
	/**
    * @description : This method updates cases
    * @param a list of cases
    */
	public static List<Database.SaveResult> updateValidCases(List<Case> updatedCasesList, List<String> caseFieldList){
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_UPDATE);
		List<Database.SaveResult> queryResultList = Database.update(updatedCasesList , false);
		return queryResultList;
	}	
	
	public static void insertCases(List<Case> insertCasesList, List<String> caseFieldList){
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_INSERT);
		insert insertCasesList;
	}
	public static List<Case> getCasesByWhereClause(set<Id> caseIds, List<String> caseFieldList){
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_READ);
		String soqlString = 'SELECT '+ String.join(caseFieldList, ',') + ' FROM Case WHERE Id IN: caseIds AND Status=\'Ready\' LIMIT 10000';
		return Database.query(soqlString);			
	}		
}