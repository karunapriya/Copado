/**
 * Created Date		: Jul 13, 2018
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: US3598 - Scheduler for CreateQuoteAndQLIBatch
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US3598				    Jul 13, 2018			1.1			Scheduler for CreateQuoteAndQLIBatch
 *
 */
global with sharing class CHL_CreateQuoteAndQLIBatchDispatcher implements Schedulable {
	public Boolean isOppUpdateRequired {get;set;}
	public Static Integer batchInterval = 15;
	global void execute(SchedulableContext sc){
		Set<String> oppFldstoQuery = new Set<String>{'Id','REN_Is_Sync_Pending__c','SyncedQuoteId'};
		Set<Id> impactedQuoteIdSet = new Set<Id>();
		List<SObject> impactedOpportunityList = CHL_Util.getObjectListByWhereClause(oppFldstoQuery,CHL_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId != null and REN_Is_Sync_Pending__c = true');
    	for(SObject obj : impactedOpportunityList) {
    		impactedQuoteIdSet.add((Id)obj.get('SyncedQuoteId'));
    	}
    	system.debug('impactedQuoteIdSet::>'+impactedQuoteIdSet);
    	if(impactedQuoteIdSet != null && !impactedQuoteIdSet.isEmpty()){
    		boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
            if(isFlexQueueAvailable){
            	system.debug('1-->'+sc);
            	Integer batchSize = CSM_Util.getCustomListSetting('CHL_CreateQuoteAndQLIBatch');
    			batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
		    	CHL_CreateQuoteAndQLIBatch quoteQLIBatch = new CHL_CreateQuoteAndQLIBatch();
		    	quoteQLIBatch.quoteIdSet = impactedQuoteIdSet;
		    	quoteQLIBatch.isOppUpdateRequired = isOppUpdateRequired;
		    	quoteQLIBatch.schedulableContextObj = sc;
		 		Database.executeBatch(quoteQLIBatch, batchSize);
            } else{
            	if(sc != null) {
            		System.abortJob(SC.getTriggerId());
            	}
                REN_AsyncUtil.scheduleCreateQuoteAndQLIBatch(this.isOppUpdateRequired, batchInterval);
            }
    	} else {
    		if(sc != null) {
				System.abortJob(SC.getTriggerId());
			}
    	}
	}
}