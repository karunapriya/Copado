public with sharing class REN_RenewalRelationshipTriggerHandler extends CSM_TriggerManager.TriggerHandler{
 	
 	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		//IF Renew license exists for user, proceed with the call 
		if(hasRenewAccess == true){
	    	REN_RRSimplifiedTriggerHelper.processRliRecords(newRecords);	
		}
	}
 	
 	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		REN_RRSimplifiedTriggerHelper.processRliBeforeUpdate(oldRecordsMap, newRecordsMap);
	}
 	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
	 	if(hasRenewAccess == true){
	 		SS_TriggerCollectionParameters.RLITriggerParams rliTriggerParams = new SS_TriggerCollectionParameters.RLITriggerParams();
	 		rliTriggerParams.impactedOppIdSet = new Set<id>();
	 		if(REN_Constants.IS_AUTO_REBUILD) {
		 		rliTriggerParams.newRecordsMap = (Map<Id, REN_Renews_To__c>)newRecordsMap;
		 		rliTriggerParams.productIdSet = new Set<id>();
		 		rliTriggerParams.oppty2rrListMap = new Map<Id, List<REN_Renews_To__c>>();
		 		rliTriggerParams.oppty2RenewalIDMap = new Map<String, String>(); 
	 		}
	        for(REN_Renews_To__c rr: (List<REN_Renews_To__c>)newRecords) {
	        	rliTriggerParams.impactedOppIdSet.add(rr.REN_Renews_To__c);
	        	if(REN_Constants.IS_AUTO_REBUILD) {
		            if(rr.REN_Renews_To__c != null) {
		                rliTriggerParams.oppty2RenewalIDMap.put((String)rr.REN_Renews_To__c, (String)rr.Id);
		                if(!rliTriggerParams.oppty2rrListMap.containsKey(rr.REN_Renews_To__c)){
		                	rliTriggerParams.oppty2rrListMap.put(rr.REN_Renews_To__c, new List<REN_Renews_To__c>());
		                }
		                rliTriggerParams.oppty2rrListMap.get(rr.REN_Renews_To__c).add((REN_Renews_To__c)rr);
		            }
		            rliTriggerParams.productIdSet.add(rr.REN_Product__c);
	        	}
	        }
	        rliTriggerParams.impactedOppIdSet.remove(null);
	 		if(REN_Constants.IS_AUTO_REBUILD) {
	 			REN_OpportunityLineItemRenewalHandler.createOLI(rliTriggerParams);
	 		}
	 		REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(rliTriggerParams.impactedOppIdSet);
		}
	}

 	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
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
 	public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
		
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		//IF Renew license exists for user, proceed with the call 
		Set<Id> impactedOppIdSet = new Set<Id>();
		if(hasRenewAccess == true){
			for(REN_Renews_To__c rr: (List<REN_Renews_To__c>) oldRecords){
			     if(rr.REN_Renews_To__c != null){
			         impactedOppIdSet.add(rr.REN_Renews_To__c);
			     }
			}
	        impactedOppIdSet.remove(null);
	 		REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(impactedOppIdSet);
		}
 	}
 	
 	public override void onAfterUnDelete(List<sObject> newRecords){
        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
	 	if(hasRenewAccess == true){
	 		Set<id> impactedOppIdSet = new Set<id>();
	        for(REN_Renews_To__c rliObj: (List<REN_Renews_To__c>)newRecords) {
	        	if(rliObj.REN_Renews_To__c != null){
	        		impactedOppIdSet.add(rliObj.REN_Renews_To__c);
	        	}
	        }
	 		REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(impactedOppIdSet);
	 	}
 	}
 	
}