/**
 * @author    	 Eswar Bala (eswar@comitydesigns.com)    
 * @date         01/15/2015
 * @description  REN_AssetTriggerHandler trigger handler for REN_AssetTrigger
 */
public with sharing class REN_AssetTriggerHandler extends CSM_TriggerManager.TriggerHandler
{
	
    public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
    	try
 		{
	        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		 		
		 	//IF Renew license exists for user, proceed with the call 
		 	if(hasRenewAccess==true) {
		 		REN_AssetMonitoringTriggerHandler.validateCurrencyChange(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
		 	}
 		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
    	
    }
	
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 									Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
 	{
 		try
 		{
	        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		 	
 			//Eswar Bala - 01/15/2015
		 	/*Asset Update Functionality - Admin Page*/
		 	//IF Renew license exists for user, proceed with the call 
		 	if(hasRenewAccess==true) {
		 		REN_AssetMonitoringTriggerHandler.handleAssetUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
		 	}
 		}
 		catch(exception ex)	{
		 	REN_Util.setErrorInObjects (newRecords, ex);
	 	}
 	}
}