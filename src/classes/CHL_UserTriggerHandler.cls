public with sharing class CHL_UserTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		CHL_UserTriggerHelper.addUserToPublicGroup(newRecords);
		CHL_UserTriggerHelper.updatePartnerCaseSharing(newRecords);
		CHL_UserTriggerHelper.assignPermissionSets(newRecordsMap.keySet());
		CHL_UserTriggerHelper.updateUserContact(JSON.serialize(newRecords));
	}
	
}