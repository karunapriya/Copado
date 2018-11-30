/**
 * Created Date     : April 10, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 * Function         : @description - This class is a helper class for CHL_QuoteSyncBatch.
 *						
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha Palasapure       US3274 & US3273      April 10, 2018          1.1                 @description
 *
 */

public with sharing class CHL_QuoteSyncBatchHelper {
	   
    /* This method is used to save Batch Results Logs for Opportunity. */
    public static Set<Id> saveErrorLogsOfOpportunity(List<Database.SaveResult> results,Database.BatchableContext batchContext, Map<Id,Opportunity> opportunityMap){
    	CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    	Set<Id> failureOppIdsSet = new Set<Id>();
    	Set<Id> successIdsSet = new Set<Id>();
    	for(Database.SaveResult result: results){
            if (result.isSuccess()){
            	successIdsSet.add(result.getId());            	
            }
            else{
            	CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: '+ result.getErrors().get(0));
				logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',	batchContext.getJobId());						
            }
		}
		logger.saveLogRecords();
		if(successIdsSet.size() == opportunityMap.keySet().size()){
			return failureOppIdsSet;
		}
		else{
			for(Id oppId : opportunityMap.keySet()){
				if(!successIdsSet.contains(oppId)){
					failureOppIdsSet.add(oppId);
				}
			}
			return failureOppIdsSet;
		}
    }
    
    /* This method is used to save Batch Results Logs for OpportunityLineItem. */
    public static Set<Id> saveErrorLogsOfOpportunityLineItem(List<Database.SaveResult> results,Database.BatchableContext batchContext, Map<Id,OpportunityLineItem> oppLineItemMap){
    	CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    	Set<Id> failureOppIdsSet = new Set<Id>();
    	Set<Id> successIdsSet = new Set<Id>();
    	for(Database.SaveResult result: results){
            if (result.isSuccess()){
            	successIdsSet.add(result.getId());            	
            }
            else{
            	CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: '+ result.getErrors().get(0));
				logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'OpportunityLineItem',	batchContext.getJobId());						
            }
		}
		logger.saveLogRecords();
		if(successIdsSet.size() == oppLineItemMap.keySet().size()){
			return failureOppIdsSet;
		}
		else{
			for(Id oliId : oppLineItemMap.keySet()){
				if(!successIdsSet.contains(oliId)){
					failureOppIdsSet.add(oppLineItemMap.get(oliId).OpportunityId);
				}
			}
			return failureOppIdsSet;
		}
    }
}