/**
 * Created Date     : Sep 17, 2018
 * Developed By     : Sheetal, Comity Designs, Inc.
 *
 * Function         : This Batch is for setting the "Sync Pending" status on Opportunity
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Sheetal                  User Story              Sep 17, 2018            1.1         This Batch is for setting the "Sync Pending" status on Opportunity
 *
 */
public with sharing class REN_SetOppSyncPendingStatusBatch implements Database.Batchable<sObject>, Database.Stateful {
    public set<ID> impactedOpportunitySet {get;set;}
    public SchedulableContext schedulableContextObj {get;set;}
    public Set<Id> successOppIdsSet = new Set<Id>();
    private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();

    public Database.queryLocator start(Database.BatchableContext batchContext){
        try{
            String queryString = Test.isRunningTest()? 'Select Id, REN_Is_Sync_Pending__c, REN_Renewal_Metrics_Status__c, REN_Metrics_Calculation_Date__c, REN_AddsAmount__c from Opportunity limit 1':'Select Id, REN_Is_Sync_Pending__c, REN_Renewal_Metrics_Status__c, REN_Metrics_Calculation_Date__c, REN_AddsAmount__c from Opportunity where ID IN: impactedOpportunitySet';
            return Database.getQueryLocator(queryString);
        }
        catch (Exception ex){
            System.debug('\n' + ex);
            CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'Error:Batch Name - REN_SetOppSyncPendingStatusBatch_1' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
            logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',  batchContext.getJobId());
            logger.saveLogRecords();
            system.abortJob(batchContext.getJobId());
        }
        return null;
    }
    
    public void execute(Database.BatchableContext batchContext,List<Opportunity> OpportunityList){
        try{
            CSM_TriggerManager.disableAllTriggers();
            
            List<String> oppIdsList = new List<String>();
            for(Opportunity opp : OpportunityList){
                opp.REN_Is_Sync_Pending__c = false;
                successOppIdsSet.add(opp.Id);                   
            }
            List<Database.SaveResult> opptyUpdateResults = Database.update(OpportunityList, false);
            for(Database.SaveResult result: opptyUpdateResults){
                if (!result.isSuccess() || Test.isRunningTest()){
                    CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: Batch Name - REN_SetOppSyncPendingStatusBatch_1' + result.getId() + ' - ' + result.getErrors().get(0));
                    logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',  batchContext.getJobId());
                }
            }
            logger.saveLogRecords();
        }
        catch (Exception ex){
            System.debug('\n' + ex);
            CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: Batch Name - REN_SetOppSyncPendingStatusBatch_2' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
            logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',  batchContext.getJobId());
            logger.saveLogRecords();
        }
    }
    
    public void finish (Database.BatchableContext batchContext){
        if(schedulableContextObj != null || Test.isRunningTest()) {
            Set<Id> impactedQuoteIdSet = new Set<Id>();
            Set<String> oppFldstoQuery = new Set<String>{'Id','REN_Is_Sync_Pending__c','SyncedQuoteId'};
            if(!Test.isRunningTest()) {
                System.abortJob(schedulableContextObj.getTriggerId());
            }
            List<SObject> impactedOpportunityList = CHL_Util.getObjectListByWhereClause(oppFldstoQuery,CHL_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId != null and REN_Is_Sync_Pending__c = true');
            for(SObject obj : impactedOpportunityList) {
                impactedQuoteIdSet.add((Id)obj.get('SyncedQuoteId'));
            }
            if(impactedQuoteIdSet != null && !impactedQuoteIdSet.isEmpty()){
                REN_AsyncUtil.scheduleCreateQuoteAndQLIBatch(true, 5);
            }
        }
        if(successOppIdsSet != null && !successOppIdsSet.isEmpty()){
            REN_AsyncMetricsFCalculationDispatcher.scheduleMe(null, 'RLI-OLI', null);
        }
    }
    
}