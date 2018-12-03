public with sharing class AccountTriggerHandler extends TriggerManager.TriggerHandler {
	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
    {
            AccountTriggerHandlerHelper.handleAccountList(newRecords, newRecordsMap);
    }
}