public with sharing class UserTriggerHandler extends TriggerManager.TriggerHandler {
	
	public override void onAfterInsert(List<sObject> newRecords,Map<ID, sObject> newRecordsMap)	{
		List<String> userToInsertList = new List<String>();
		userToInsertList = populateStandardUserLst(newRecords);
		if(userToInsertList.size() > 0){
			UserUtils.userCreateContact(userToInsertList);
		}
	}
	
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)	{
		if(Constants.USER_AFTER_UPDATE_TRIGGER){ 
			List<String> userToUpdateList = new List<String>();
			userToUpdateList = populateStandardUserLst(newRecords);
			if(userToUpdateList.size() > 0){
				UserUtils.userUpdateContact(userToUpdateList);
			}
			Constants.USER_AFTER_UPDATE_TRIGGER = true;
		}
	}
	
	
	private List<String> populateStandardUserLst(List<sObject> newRecords){
		List<User> userLst = new List<User>();
		userLst = newRecords;
		List<String> stdUserLst = new List<String>();
		for(User u : userLst) {
			if(u.UserType == 'Standard'){
				stdUserLst.add(u.Id);
			}
		}
		return stdUserLst;
	}

}