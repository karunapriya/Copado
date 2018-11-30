/**
 * Created Date		: Sep 17, 2018
 * Developed By		: admin, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * admin					User Story				Sep 17, 2018			1.1					@description
 *
 */
public with sharing class REN_CreateNewQuoteDispatcher implements Schedulable {
	public Set<ID> impactedQuoteIdSet {get;set;}
	public Boolean isOppUpdateRequired {get;set;}
	public Static Integer batchInterval = 15;
	public void execute(SchedulableContext sc){
    	if(impactedQuoteIdSet != null){
    		boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
            if(isFlexQueueAvailable){
            	if(sc != null) {
					System.abortJob(SC.getTriggerId());
				}
            	Integer batchSize = CSM_Util.getCustomListSetting('CHL_CreateQuoteAndQLIBatch');
    			batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
		    	CHL_CreateQuoteAndQLIBatch quoteQLIBatch = new CHL_CreateQuoteAndQLIBatch();
		    	quoteQLIBatch.quoteIdSet = impactedQuoteIdSet;
		    	quoteQLIBatch.isOppUpdateRequired = isOppUpdateRequired;
		 		Database.executeBatch(quoteQLIBatch, batchSize);
            } else{
            	system.debug('New Quote Sceduler::>'+sc);
	    		if(sc != null) {
					System.abortJob(SC.getTriggerId());
				}
                REN_AsyncUtil.scheduleBatchForNewQuote(this.impactedQuoteIdSet, this.isOppUpdateRequired, batchInterval);
            }
    	}
	}
}