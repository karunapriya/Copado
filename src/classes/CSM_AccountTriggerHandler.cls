/**
 * @author    	Mike Faust (mike@comitydesigns.com)    
 * @date         8/28/2014
 * @description  CSM_AccountTriggerHandler trigger handler for CSM_AccountTrigger
 */
  
public with sharing class CSM_AccountTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	 
	 public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 		Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	try { 
 			Boolean hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
	        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
	 		//MF 11/10/2013 Added this check to only execute the task creation when the user has account Plan / CSM
	 		if (hasCSMAccess && Schema.sObjectType.CSM_Account_Plan__c.isAccessible()) {
	 			CSM_TaskCreationTriggerUtil.CreatePlayActivities(newRecordsMap.keySet(), newRecords, CSM_Constants.OBJ_TYPE_ACCOUNT);
	 		}
	 	}
	 	catch (exception ex)
	 	{
	 		for (Integer i = 0; i < newRecords.size(); i++)
	 		{
	 			newRecords[i].addError(ex.getMessage());
	 		} 
	 	} 
	 } 
 
}