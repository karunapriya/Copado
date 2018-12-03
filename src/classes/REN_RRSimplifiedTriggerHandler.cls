public with sharing class REN_RRSimplifiedTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	public static boolean isMaualOppGeneration=false;
	public static boolean isRRSimplifiedInsertTriggerByPass = false;
	
 	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		REN_RRSimplifiedTriggerHelper.processRliBeforeUpdate(oldRecordsMap, newRecordsMap);
	}
 	
 	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;			
			if(hasRenewAccess == true) {
			Set<id> impactedOppIdSet = new Set<id>(); 		
	 		for(REN_Renews_To__c rr: (List<REN_Renews_To__c>)newRecordsMap.Values()) {
	 			REN_Renews_To__c oldRecord = (REN_Renews_To__c)oldRecordsMap.get(rr.id);
	 			if(rr.REN_Renews_To__c != null && (
	 				(rr.REN_Previous_Price__c != oldRecord.REN_Previous_Price__c) // REN_Previous_Price__c changed
	 				|| 	(rr.REN_Renewal_Target_Multiplier__c != oldRecord.REN_Renewal_Target_Multiplier__c) // REN_Renewal_Target_Multiplier__c changed
	 				||	(rr.REN_End_Date__c != oldRecord.REN_End_Date__c) // REN_End_Date__c changed
	 			)) {
	                impactedOppIdSet.add((Id)rr.REN_Renews_To__c);
	            }
	 			if(rr.REN_Renews_To__c != oldRecord.REN_Renews_To__c && oldRecord.REN_Renews_To__c != null) {
	 				impactedOppIdSet.add(rr.REN_Renews_To__c);
	                impactedOppIdSet.add((id)oldRecord.REN_Renews_To__c);
	            }
	 		}
	 		REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(impactedOppIdSet);
		 }
 	}
 	
 	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
 		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		if(hasRenewAccess == true && !isRRSimplifiedInsertTriggerByPass){
			REN_RRSimplifiedTriggerHelper.processRliRecords(newRecords);		
		}
 	}
 	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
	 	if(hasRenewAccess == true && !isRRSimplifiedInsertTriggerByPass){
	 		Set<id> impactedOppIdSet = new Set<id>();
	 		for(REN_Renews_To__c rr : (List<REN_Renews_To__c>)newRecords){
	 			impactedOppIdSet.add(rr.REN_Renews_To__c);
	 		}
	 		REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(impactedOppIdSet);
	 	}
 	}

 	public override void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
 		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
 		Map<ID, List<REN_Renews_To__c>> oppId2rrMap = new Map<ID, List<REN_Renews_To__c>>();
		if(hasRenewAccess == true){
			//REN_RRSimplifiedTriggerHelper.validateSyncQuoteOnOpportunity(null,null);
			List<REN_Renews_To__c> rliList;
			for(REN_Renews_To__c rliObj: (List<REN_Renews_To__c>)oldRecords) {
				if(rliObj.REN_Renews_To__c != null) {
					rliList = new List<REN_Renews_To__c>();
					if(oppId2rrMap.containsKey(rliObj.REN_Renews_To__c)) {
						rliList = oppId2rrMap.get(rliObj.REN_Renews_To__c);
					} else {
						rliList = new List<REN_Renews_To__c>();
					}
					rliList.add(rliObj);
					oppId2rrMap.put(rliObj.REN_Renews_To__c, rliList);
				}
			}
			REN_RRSimplifiedTriggerHelper.validateSyncQuoteOnOpportunity((Map<ID, REN_Renews_To__c>)oldRecordsMap,oppId2rrMap);	
		}
 	}

 	public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
 		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		if(hasRenewAccess == true){
		 	Set<ID> impactedOppIdSet = new Set<ID>();
		 	for(REN_Renews_To__c rr : (List<REN_Renews_To__c>)oldRecords){
		 		impactedOppIdSet.add(rr.REN_Renews_To__c);
		 	}
		 	REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(impactedOppIdSet);
		 }
 	}
 	
 	public override void onAfterUnDelete(List<sObject> newRecords){
 		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		if(hasRenewAccess){
			Set<ID> impactedOppIdSet = new Set<ID>();
		 	for(REN_Renews_To__c rliObj : (List<REN_Renews_To__c>)newRecords){
		 		impactedOppIdSet.add(rliObj.REN_Renews_To__c);
		 	}
		 	REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(impactedOppIdSet);
		 }
 	}
}