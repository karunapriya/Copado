/**
 * Created Date     : March 05, 2018
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : This class is act as a helper class for opportunity trigger. Added as part of US2947.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                 US2947             March 05, 2018            1.1                 @description
 *
 */
	

public with sharing class CSM_OpportunityTriggerHelper {
	
	 public static void updateRliStageToOpen(List<Opportunity> opportunityList){
        List<REN_Renews_To__c> rliToUpdate = new List<REN_Renews_To__c>();
     	List<REN_Renews_To__c> rliIdList = REN_RenewRelationshipDataAccess.getLstRenRelationshipByRenewalStatus(opportunityList);       
	    for(REN_Renews_To__c rliId : rliIdList){
	        rliId.REN_Renewal_Status__c = 'Open';
	        rliToUpdate.add(rliId);
	    }
        if(!rliToUpdate.isEmpty()){
        	REN_RenewRelationshipDataAccess.updateRenewalRelationship(rliToUpdate, new List<String>{'Id','REN_Renewal_Status__c'});
        }
	 } 
	 
	 /* This method is used to set CHL_QuoteSyncStatus__c to "Scheduled"  .*/
	 
	 public static void updateQuoteSyncStatusOnOppty(Set<String> oppIdsSet, String status){
	 	List<Opportunity> opportunityList = new List<Opportunity>();
	 	opportunityList = REN_OpportunityDataAccess.getOpportunityById(oppIdsSet, new Set<String>{'CHL_QuoteSyncStatus__c','CHL_Bypass_Validation_For_Quote_Async__c'},null);
	 	if(opportunityList != null && !opportunityList.isEmpty()){
	 		bypassValidationForQuoteSyncBatch(opportunityList, true);
	 		for(Opportunity opp : opportunityList){
	 			opp.CHL_QuoteSyncStatus__c = status;
	 		}
 			CSM_OpportunityDataAccess.updateOpportunityList(opportunityList, new List<String>{'CHL_QuoteSyncStatus__c'});	
	 	}
	 }
	 
	 /* This method is used to process QLI records via batch if QLI Count is greater than Threshold. */
	 public static void processQliRecordsByBatch(Decimal qliCount, Set<Id> filteredOppIdsSet, List<Sobject> distributorQuotesList){
	 	Boolean isChannelCommunityUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity);
		Boolean isDataServiceUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
	 	Decimal qliThreshold = CSM_Admin__c.getOrgDefaults().CHL_QliCount__c;
		Boolean isQuoteSyncBatchRunning = CHL_Util.isBatchRunning('CHL_QuoteSyncBatch');
		Boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
		Integer batchSize = CSM_Util.getCustomListSetting('CHL_QuoteSyncBatch');
		batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
		Set<String> syncedOppIdSet = new Set<String>();
		syncedOppIdSet = (Set<String>)JSON.deserialize(JSON.serialize(filteredOppIdsSet), Set<String>.class);
		if((qliCount > qliThreshold) && isFlexQueueAvailable && !isDataServiceUser && !isChannelCommunityUser && (distributorQuotesList == null || distributorQuotesList.isEmpty())){
			updateQuoteSyncStatusOnOppty(syncedOppIdSet,'In Progress ');
			CHL_QuoteSyncBatch quoteAsync = new CHL_QuoteSyncBatch();
			quoteAsync.oppIdsSet = filteredOppIdsSet;
			Database.executeBatch(quoteAsync,batchSize);
		}
		else if(isDataServiceUser && !isQuoteSyncBatchRunning && isFlexQueueAvailable){
			updateQuoteSyncStatusOnOppty(syncedOppIdSet,'Scheduled');
			Database.executeBatch(new CHL_QuoteSyncBatch(),batchSize);
		}
		else if(isDataServiceUser && isQuoteSyncBatchRunning){ 					
			updateQuoteSyncStatusOnOppty(syncedOppIdSet,'Scheduled');
		}
		else if(isChannelCommunityUser && qliCount > qliThreshold){
			updateQuoteSyncStatusOnOppty(syncedOppIdSet,'Scheduled');
		}
		else if(!isFlexQueueAvailable && ((!isDataServiceUser && (distributorQuotesList == null || distributorQuotesList.isEmpty())) || isDataServiceUser)){
			updateQuoteSyncStatusOnOppty(syncedOppIdSet,'Scheduled');
		}	 
	}
	
	/*This method is used to set Bypass Quote Async validations when copying custom fields is in progress.*/
	public static void bypassValidationForQuoteSyncBatch(List<Opportunity> opportunityList, Boolean isBypass){
		if(opportunityList != null && !opportunityList.isEmpty()){
			for(Opportunity opp : opportunityList){
				opp.CHL_Bypass_Validation_For_Quote_Async__c = isBypass;
	 		}
			CSM_OpportunityDataAccess.updateOpportunityList(opportunityList, new List<String>{'CHL_Bypass_Validation_For_Quote_Async__c'});	
		}	
	}
}