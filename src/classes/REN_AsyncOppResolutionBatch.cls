/**
 * Created Date     : Sep 6, 2016
 * Developed By     : admin, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * admin                    User Story              Sep 6, 2016         1.1                 @description
 *
 */
global with sharing class REN_AsyncOppResolutionBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {
    /**
     * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
     //Database.executeBatch(new REN_AsyncOppResolutionBatch(),1);
    private CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
    private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    private Map<String,String> opptyIdMap = new Map<String,String>();
    //Schedulable method
    global void execute(SchedulableContext schedulerContext) {   
        Integer batchSize = CSM_Util.getCustomListSetting('REN_AsyncOppResolutionBatch');
        batchSize = (batchSize == null || batchSize == 0) ? 1 : batchSize; 
        String batchprocessid = Database.executeBatch(this,batchSize);
    }
    //For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  
    //A maximum of 50 million records can be returned
    global Database.queryLocator start(Database.BatchableContext batchContext) {
        String jobId = batchContext.getJobId();
        try{
            logger.addLogRecord(batchResult, system.now(), 
                CSM_BatchResultsLogger.MODULE_RENEW, 
                CSM_BatchResultsLogger.STATUS_PENDING, 
                CSM_Constants.OBJ_ACCOUNT,jobId);
            String soqlStr = 'Select r.REN_Source_Opportunity__c, r.REN_OLIs_Qualified__c, r.REN_Assets_Qualified__c, r.REN_CLIs_Qualified__c, r.REN_Source_Opportunity__r.REN_Append_Renewal_Opportunity__c, r.REN_Renewal_Opportunity__c, r.Id, r.REN_Source_for_Renewed_Opportunity__c '
                + (CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c') ? (', r.REN_Source_Opportunity__r.' + CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c') : '')
                + (CSM_AccessController.hasField('REN_Renewal_Processing_Status__c', CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c') ? (', r.' + CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c') : '')
                + (CSM_AccessController.hasField('REN_Renewal_Processing_Status__c', CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') ? (', r.' + CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') : '')
                + ' From REN_Renewal_Processing_Status__c r ' 
                + ' WHERE r.REN_OLIs_Qualified__c = 0 AND r.REN_Assets_Qualified__c = 0 AND REN_CLIs_Qualified__c = 0';
            system.debug('\n\n~~~~Start method of REN_AsyncOppResolutionBatch : ' + soqlStr);
            if(Test.isRunningTest()) {
                soqlStr += ' LIMIT 1';
            }
            return Database.getQueryLocator(soqlStr);
        }catch (Exception ex) {
            batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
            logger.setErrorFieldValues(batchResult, system.now(), true, 'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
            logger.saveLogRecords();
            System.abortJob(jobId);
            return null;
        }
    }
    //Execute method
    global void execute(Database.BatchableContext batchContext, List<REN_Renewal_Processing_Status__c> renewalProcessStatusList) {
        Savepoint sp = Database.setSavepoint();
        try{
        	CSM_TriggerManager.disableAllTriggers();
            Map<String, String> opptyIdMap = REN_AsyncOppRenewalBatchHelper.getRenewalProcessStatusMap(renewalProcessStatusList);
            Set<Id> idSet = (Set<Id>)JSON.deserialize(JSON.serialize(opptyIdMap.keySet()), Set<Id>.class);
            Map<ID, List<OpportunityLineItem>> qualifiedAssetOli = REN_AsyncOppRenewalBatchHelper.executeOliBasedCriteria(idSet, REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET);
            Map<ID, List<OpportunityLineItem>> qualifiedCliOli = REN_AsyncOppRenewalBatchHelper.executeOliBasedCriteria(idSet, REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM);
            Map<ID, List<OpportunityLineItem>> qualifiedOliToOli = REN_AsyncOppRenewalBatchHelper.executeOliBasedCriteria(idSet, REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT);
            
            //Set of valid opportunity that needs to be proecessed for auto renew. 
            Set<Id> setOfOppId = new Set<Id>();
            Map<String, String> mapOfOppToRenProcess = new Map<String,String>();
            for(REN_Renewal_Processing_Status__c renProcessStatus: renewalProcessStatusList){
                List<OpportunityLineItem> lstOfOliFromAssets = qualifiedAssetOli.get(renProcessStatus.REN_Source_Opportunity__c);
                List<OpportunityLineItem> lstOfOliFromCLI = qualifiedCliOli.get(renProcessStatus.REN_Source_Opportunity__c);
                List<OpportunityLineItem> lstOfOliFromOLI = qualifiedOliToOli.get(renProcessStatus.REN_Source_Opportunity__c);
                if(    (lstOfOliFromAssets != null && !lstOfOliFromAssets.isEmpty()) 
                    || (lstOfOliFromCLI != null && !lstOfOliFromCLI.isEmpty())
                    || ((lstOfOliFromOLI != null && !lstOfOliFromOLI.isEmpty()) && (!SS_Constants.isSimplifiedDataModelEnabled) ) ){
                        
                    setOfOppId.add(renProcessStatus.REN_Source_Opportunity__c);
                    mapOfOppToRenProcess.put(renProcessStatus.REN_Source_Opportunity__c,renProcessStatus.id);
                }
            }
            List<Opportunity> lstToOppRenProcess = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<Id>(setOfOppId));
            REN_AsyncOpportunityResolutionHandler.handleAsyncRenewalUpdate(lstToOppRenProcess, qualifiedCliOli, qualifiedOliToOli);
            Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(setOfOppId), Set<String>.class);

            List<OpportunityLineItem> opportunityLineItemList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(idStrs);
            List<REN_Line_Processing_Status__c> lineProcessingStatusList = new List<REN_Line_Processing_Status__c>();
            List<String> lpsfieldList = new List<String>{'REN_Source_OLI_Id__c',
                'REN_Source_Asset__c','REN_Product__c','REN_OLI_Qualified__c', 'REN_Asset_Qualified__c', 'REN_CLI_Qualified__c', 'REN_Asset_RLI_Qualified__c', 'REN_CLI_RLI_Qualified__c'};
            
            
            if(opportunityLineItemList != null && !opportunityLineItemList.isEmpty()) {
                Set<Id> opptyIds = new Set<Id>();
                for(String opptyId : opptyIdMap.keySet()){
                    opptyIds.add((Id)opptyId);
                }
                lineProcessingStatusList = REN_AsyncOppRenewalBatchHelper.getLineProcessingStatusList(mapOfOppToRenProcess);  
                lineProcessingStatusList = REN_AsyncOppRenewalBatchHelper.setQualifiedFlag(lineProcessingStatusList, opptyIds);
                REN_LineProcessingStatusDataAccess.upsertLineProcessingStatusList(lineProcessingStatusList, lpsfieldList);
            }
            Map<ID, REN_Renewal_Processing_Status__c> prsMap = new Map<ID, REN_Renewal_Processing_Status__c>(renewalProcessStatusList);
            REN_AsyncOppRenewalBatchHelper.deleteDisqualifiedRpsRecords(prsMap.keySet());
        }
        catch (exception ex) {
            Database.rollback(sp);
            logger.setErrorFieldValues(batchResult, system.now(), true, 'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
            logger.saveLogRecords();
            
            for(REN_Renewal_Processing_Status__c rps: renewalProcessStatusList){
                rps.REN_Failed__c = true;
                rps.REN_Failure_Msg__c = ex.getMessage();
            }
            REN_RenewalProcessingStatusDataAccess.updatProcessingStatusRecords(renewalProcessStatusList);
        }
    }
    global void finish(Database.BatchableContext batchContext) {
        batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
        batchResult.CSM_Batch_Completion_Time__c = system.now();
        logger.saveLogRecords();
        String strDateTime = (system.now().addMinutes(2)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
        String jobID = system.schedule(String.format(Label.REN_BATCH_OLI_SCHEDULAR_NAME, new String[]{String.valueOf(system.now())}), strDateTime, new REN_AsyncOppResolutionOLIBatchDispatcher());
        /*REN_AsyncOppResolutionOLIBatch batch=new REN_AsyncOppResolutionOLIBatch();
        database.executebatch(batch,1);*/
    }
}