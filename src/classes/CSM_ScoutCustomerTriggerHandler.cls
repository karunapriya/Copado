/**
 * @author    	Abhijit BirjePatil    
 * @date         8/21/2015
 * @description  CSM_ScoutCustomerTriggerHandler trigger handler for CSM_ScoutCustomerTrigger
 */

public with sharing class CSM_ScoutCustomerTriggerHandler extends CSM_TriggerManager.TriggerHandler {
	
    Set<String> objectSet;  
    String nameSpacePrefixScout;       
	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
	 {
	 	try {
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
				if(String.isBlank(nameSpacePrefixScout)){
					setNamespacePrefix();				
				}
		 		Set<Id> accountList = getAccountList(newRecords);
		 		CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountList, newRecords, nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER);
            }
	 	}
	 	catch (Exception ex)
	 	{
	 		for (Integer i = 0; i < newRecords.size(); i++)
	 		{
	 			newRecords[i].addError(ex.getMessage());
	 		} 
	 	}
	 	
	 }
	 
	 public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	try {
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
				if(String.isBlank(nameSpacePrefixScout)){
					setNamespacePrefix();				
				}
		 		Set<Id> accountList = getAccountList(newRecords);
		 		CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountList, newRecords, nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER);
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
	 
	 
	 private Set<Id> getAccountList(List<SObject> recordList)
	 {
	 	Set<Id> tmpSet = new Set<Id>();
	 	for(SObject scoutCustomer :  recordList)
	 	{
	 		tmpSet.add((Id)scoutCustomer.get(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID));
	 	}
	 	return tmpSet;
	 }
	 
	 private void setNamespacePrefix(){
	    objectSet = new Set<String>();           
	    objectSet.addAll(CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_PLAYS));
		for(String objName: objectSet){
			if(objName.ToLowerCase().contains(CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER.ToLowerCase())){
				nameSpacePrefixScout = objName.length() != CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER.length()? objName.substringBefore('__') + '__':'';
				break;
			}else{
				nameSpacePrefixScout = '';
			}
		}
	 }

}