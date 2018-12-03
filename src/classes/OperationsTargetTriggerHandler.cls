public with sharing class OperationsTargetTriggerHandler extends TriggerManager.TriggerHandler {

	public override void onBeforeInsert(List<sObject> newRecords,Map<ID, sObject> newRecordsMap)	{
		List<Operations_Target__c> opTargetLst = new List<Operations_Target__c>();
		opTargetLst = newRecords;
		Map<String,Id> caseRecordTypeMap = new Map<String,Id>();
		Set<String> currentCriteriaCheckerSet = new Set<String>();
		Set<String> existingCriteriaCheckerSet = new Set<String>();
		
		caseRecordTypeMap = OperationsTargetExtension.getCaseRecordTypeMap();
		
		for(Operations_Target__c ot : opTargetLst){
			ot.Case_Record_Type_Id__c = caseRecordTypeMap.get(ot.Case_Record_Type__c);
			currentCriteriaCheckerSet.add(String.valueOf(ot.Period__c) + ':' + String.valueOf(ot.Employee__c) + ':' + String.valueOf(ot.Case_Record_Type_Id__c) + ':' + String.valueOf(ot.Case_Origin__c));
		}
		
		for(Operations_Target__c ot : OperationsTargetDataAccess.getOperationTargetsByCriteria(currentCriteriaCheckerSet)){
			existingCriteriaCheckerSet.add(ot.Criteria_Checker__c);
		}
		String dupeChecker;
		for(Operations_Target__c ot : opTargetLst){
			dupeChecker = String.valueOf(ot.Period__c) + ':' + String.valueOf(ot.Employee__c) + ':' + String.valueOf(ot.Case_Record_Type_Id__c) + ':' + String.valueOf(ot.Case_Origin__c);
			if(existingCriteriaCheckerSet.contains(dupeChecker)){
				ot.addError(Label.MSG_ERR_OPP_TARGET_PARTICULAR);
			}
			else{
				ot.Criteria_Checker__c = String.valueOf(ot.Period__c) + ':' + String.valueOf(ot.Employee__c) + ':' + String.valueOf(ot.Case_Record_Type_Id__c) + ':' + String.valueOf(ot.Case_Origin__c);
			}
		}
		
	}
	
	public override void onAfterInsert(List<sObject> newRecords,Map<ID, sObject> newRecordsMap)	{
		List<Operations_Target__c> opTargetLst = new List<Operations_Target__c>();
		opTargetLst = newRecords;
		List<Operations_Target__c> operationsTargetList = new List<Operations_Target__c>();
		for(Operations_Target__c ot : opTargetLst){
			operationsTargetList.add(ot);
		}
		if(operationsTargetList.size() > 0){
			OperationsTargetExtension.generateOperationsTarget(operationsTargetList);
		}
	}
	
}