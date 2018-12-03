/**
 * Created Date     : March 30, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 * Function         : @description - This class is used to schedule CHL_QuoteSyncBatch after finish of CHL_SetQuoteSyncStatusOnOpptyBatch
 									 if there are some more opportuities having CHL_QuoteSyncStatus__c as "Scheduled".
 						
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha Palasapure      US3274 & US3273      March 30, 2018          1.1                 @description
 *
 */

global with sharing class CHL_OpportunityBatchScheduledDispatcher implements Schedulable{
	global void execute(SchedulableContext schedulerContext){
	    String namespace = CSM_Util.getNameSpace();
	    List<Opportunity> opportunityList =  new List<Opportunity>();
	    namespace = namespace.replace('__','.');    
	    Type targettype = Type.forName(namespace + 'CHL_QuoteSyncBatch');
	    Boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
	    if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId')){
	    	String queryString = 'Select Id, CHL_QuoteSyncStatus__c from Opportunity where CHL_QuoteSyncStatus__c = \'Scheduled\' and SyncedQuoteId != null limit 10000';
	    	opportunityList = Database.query(queryString);
	    }
	    if(targettype!=null && isFlexQueueAvailable && opportunityList != null && !opportunityList.isEmpty()) {
	         REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	         obj.execute(schedulerContext);
	    }
	    else{
            System.abortJob(schedulerContext.getTriggerId());
        }
	}    
}