/**
 * @author    	Vishal Patel (vishal@comitydesigns.com)    
 * @date         8/28/2014
 * @description  CSM_CustomObjectTriggerHandler trigger handler for any custom object trigger
 */
  
public with sharing class CSM_CustomObjectTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	 
	 public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 		Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	try { 
 			Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
	        Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
	        if (newRecords!=null && !newRecords.IsEmpty()){
		        SObject newRecord = newRecords[0];
		        String obj = newRecord.getSObjectType().getDescribe().getName();
		        
		        String acctFieldName;
		        Map<String,DescribeFieldResult> fldMap = CSM_AccessController.getTypeFromFieldnameObjectname(obj, CSM_Constants.OBJ_TYPE_ACCOUNT, CSM_Constants.TYPE_REFERENCE);
				if (fldMap!=null && !fldMap.isEmpty()){
					for (String acctField : fldMap.keySet()){
						acctFieldName = acctField;
						break;
					}
				}
				if (acctFieldName!=null){
					Set<Id> accountIdSet = new Set<Id>();
					for (SObject rec : newRecords){
						if (rec.get(acctFieldName)!=null){
							accountIdSet.add((Id)rec.get(acctFieldName));
						}	
					}
					
			 		//MF 11/10/2013 Added this check to only execute the task creation when the user has account Plan / CSM
			 		if ((hasCSMAccess || hasRenewAccess) && accountIdSet!=null & !accountIdSet.isEmpty() && 
			 			Schema.sObjectType.CSM_Account_Plan__c.isAccessible()) {
			 			CSM_TaskCreationTriggerUtil.CreatePlayActivities(acctFieldName, accountIdSet, newRecords, obj);
			 		}
				}
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