public with sharing class CHL_PartnerOpportunityTriggerHandler extends CSM_TriggerManager.TriggerHandler
{
 	
 	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)	{
 		try	{
	 		Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
	 		Set<ID> oppIdSet = new Set<ID> ();
	 		Map<ID, CHL_Partner_Opportunity__c> syncPartOppMap = new Map <ID, CHL_Partner_Opportunity__c> ();
	 		if(hasChannelAccess == true)	{
		 		CHL_NeedStatusUpdateUtil.updateStatusFlag(newRecordsMap, oldRecordsMap);
		 		//CHL_PartnerOppTriggerHelper.resetSyncFieldBeforeUpdate((Map<Id, CHL_Partner_Opportunity__c>)newRecordsMap, (Map<Id, CHL_Partner_Opportunity__c>)oldRecordsMap);
	 		 	
	 		 	List<sObject> recToProceed = new List<sObject>();
		        for(sObject newObj : newRecords){
		        	if(newObj.get('CHL_Expiration_Date__c') != oldRecordsMap.get(newObj.id).get('CHL_Expiration_Date__c')){
				    	recToProceed.add(newObj);
			      	}
			      	if (newObj.get('CHL_Syncing__c') != oldRecordsMap.get(newObj.id).get('CHL_Syncing__c') && newObj.get('CHL_Syncing__c')!=null) {
						syncPartOppMap.put(newObj.id, (CHL_Partner_Opportunity__c)newObj);
						oppIdSet.add((Id)newObj.get('CHL_Opportunity__c'));						
					}
		        }
		        if(syncPartOppMap!=null && !syncPartOppMap.isEmpty()){
		        	CHL_PartnerOppTriggerHelper.resetFields(oppIdSet , newRecordsMap);
					CHL_PartnerOppTriggerHelper.syncWithOpportunityBeforeUpdate(syncPartOppMap);
				}
			    if(!recToProceed.isEmpty() && recToProceed != null){
					REN_OpportunityDataAccess.calculateExpQuarterYear((List<CHL_Partner_Opportunity__c>) recToProceed,CSM_Util.getNamespace()+'CHL_Expiration_Date__c');
	 		 	}	 	
		 	}
 		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex); 
	 	}
 	}
 	
 	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
  									   Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)	{
  		try	{
	 		Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
	 	 	if(hasChannelAccess == true)	{
	 		 		CHL_PartnerOppTriggerHelper.syncToMasterOpty((List<CHL_Partner_Opportunity__c>) newRecords);
	 		 }
		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex); 
	 	}
  	
   }	 
 	
 	public override void onAfterInsert( List<sObject> newRecords, Map<ID, sObject> newRecordsMap){	 
 	 	try	{
	 		Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
	 		if(hasChannelAccess == true){
		 		CHL_PartnerOppTriggerHelper.resetSyncFieldAfterInsert((Map<Id, CHL_Partner_Opportunity__c>)newRecordsMap);
		 	}
 		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
 	 	
 	 }

}