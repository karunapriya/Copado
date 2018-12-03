public with sharing class SalesTargetTriggerHandler  extends TriggerManager.TriggerHandler{
	
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		SalesTargetTriggerHandlerHelper.checkSetCriteriaBeforeInsert(newRecords , newRecordsMap);
	}
    public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
    {
    	SalesTargetTriggerHandlerHelper.checkCriteriaForInsert(newRecords , newRecordsMap);
    }
    
}