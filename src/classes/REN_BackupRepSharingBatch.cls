/**
 * Created Date		: Jan 11, 2018
 * Developed By		: Sanket, Comity Designs, Inc.
 *
 * Function			: @description -  Batch job for backup sales rep. 
 * Support Email 	: sanket@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *_____________________________________________________________________________________________________________________________________
 *
 * Sanket					 US3087				 Jan 11, 2018        1.1				Batch class for backup sales rep.
 */
 
global with sharing class REN_BackupRepSharingBatch implements REN_IScheduleDispatched,Database.Batchable<SObject>, Database.Stateful{
		
	private CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	//Schedule Method
    global void execute(SchedulableContext SC) {   
    	Integer batchSize = CSM_Util.getCustomListSetting('REN_BackupRepSharingBatch');
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        ID batchprocessid = Database.executeBatch(this,batchSize);     
    }
    //Start Method	
	global Database.QueryLocator start(Database.BatchableContext batchcontext) {
		String jobId = batchContext.getJobId();
		String queryStr = '';
		//String status = 'Scheduled';
		try {
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CHANNEL, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									'REN_Backup_Rules__c',
									jobId);
			queryStr = 'SELECT Id,REN_Backup_Rep__c,REN_End_Date__c,REN_Error_message__c,REN_Granted_Date__c,REN_Revoked_Date__c,REN_Sales_Rep__c,REN_Start_Date__c,REN_Status__c FROM REN_Backup_Rules__c ';
			
			/*if(Test.isRunningTest() && REN_BackupRepSharingBatchTest.isNegative) {
				queryStr = 'select Id,from REN_Backup_Rules__c';
			}*/
		} catch(Exception ex) {
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
			System.abortJob(jobId);
		}
		return Database.getQueryLocator(queryStr);
	}
	//Execute Method
	global void execute(Database.BatchableContext batchcontext, List<REN_Backup_Rules__c> backupRuleList) {
		//Get backup rule data
		String jobId = batchContext.getJobId();
		Map<Id, Id> backUpGrantMap = new Map<Id, Id>();
		Map<Id, Id> backupRevokeMap = new Map<Id, Id>();
		List<OpportunityShare> oppShareToInsert = new List<OpportunityShare>();
		Set<Id> updateAsGrantStatus = new Set<Id>();
		Set<Id> updateAsRevokedStatus = new Set<Id>();
		List<OpportunityShare> oppShareToDelete = new List<OpportunityShare>();
		//String opportunityShareReason = 'Owner';
		String processGrantOrRevoke = '';
		Database.SaveResult[] insertResults;
		Database.DeleteResult[] deleteResults;
		Database.SaveResult[] updateResults;
		if(CHL_Util.isOWDForOpportunityPrivate() && CSM_AccessController.hasObject('OpportunityShare')) {
			/*try {
				if(CSM_AccessController.hasObject('REN_Backup_Rules__c')) {
					processGrantOrRevoke = 'Access Granted';
					for(REN_Backup_Rules__c backupRule: backupRuleList) {
						if(backupRule.REN_Start_Date__c >= system.today() && backupRule.REN_Status__c == 'Scheduled') {
							backUpGrantMap.put(backupRule.REN_Sales_Rep__c,backupRule.REN_Backup_Rep__c);
							updateAsGrantStatus.add(backupRule.Id);
						}
						if(backupRule.REN_End_Date__c < system.today() && backupRule.REN_Status__c == 'Access Granted') {
							backupRevokeMap.put(backUpRule.REN_Backup_Rep__c,backUpRule.REN_Sales_Rep__c);
							updateAsRevokedStatus.add(backupRule.Id);
						}
					}
					List<OpportunityShare> oppySharesList = [SELECT Id,OpportunityAccessLevel,OpportunityId, UserOrGroupId, RowCause FROM OpportunityShare LIMIT 10000 ];
					for(Id backupUserId: backUpGrantMap.keySet()) {
						for(OpportunityShare oppyShareRecord : oppySharesList) {
							if(backUpGrantMap.containsKey(oppyShareRecord.UserOrGroupId) && oppyShareRecord.RowCause == 'Owner' && oppyShareRecord.UserOrGroupId == backupUserId) {
								OpportunityShare oppyShareForBackupUser = new OpportunityShare();
								oppyShareForBackupUser.OpportunityAccessLevel = 'Edit';
								oppyShareForBackupUser.UserOrGroupId = backUpGrantMap.get(backupUserId);
								oppyShareForBackupUser.OpportunityId = oppyShareRecord.OpportunityId;
								oppShareToInsert.add(oppyShareForBackupUser);
							}
						}
					}
					insertResults = Database.insert(oppShareToInsert);
					
					processGrantOrRevoke = 'Access Revoked';
					for(Id backupUserId: backupRevokeMap.keySet()) {
						for(OpportunityShare oppyShareRecord : oppySharesList) {
							if(backupRevokeMap.containsKey(oppyShareRecord.UserOrGroupId) && oppyShareRecord.RowCause == 'Manual' && oppyShareRecord.UserOrGroupId == backupUserId) {
								oppShareToDelete.add(oppyShareRecord);
							}
						}
					}
					deleteResults = Database.delete(oppShareToDelete);	
					
					for(REN_Backup_Rules__c backupRule: backupRuleList) {
						if(updateAsGrantStatus.contains(backupRule.id)) {
							backupRule.REN_Status__c = 'Access Granted';
							backupRule.REN_Granted_Date__c = backupRule.REN_Start_Date__c + 1;
							
						}
						if(updateAsRevokedStatus.contains(backupRule.id)) {
							backupRule.REN_Status__c = 'Access Revoked';
							backupRule.REN_Revoked_Date__c = backupRule.REN_End_Date__c + 1;
						}
					}
					updateResults= Database.update(backupRuleList);
				}
			} catch(Exception ex) {
				Boolean isUpdateSizeCorrect =  updateResults!=null && updateResults.size()==backupRuleList.size();
				for(Integer i=0; i<backupRuleList.size(); i++) {
					if(processGrantOrRevoke=='Access Granted') {
						backupRuleList[i].REN_Status__c = 'Grant Failed';
						backupRuleList[i].REN_Error_message__c = (isUpdateSizeCorrect) ? String.valueOf(updateResults[i].getErrors()) :  String.valueOf(ex);
					} else if(processGrantOrRevoke=='Access Revoked') {
						backupRuleList[i].REN_Status__c = 'Revoke Failed';
						backupRuleList[i].REN_Error_message__c = (isUpdateSizeCorrect) ? String.valueOf(updateResults[i].getErrors()) : String.valueOf(ex);
					}
					update backupRuleList;
				}
			}*/
		}
   }
   // Finish Method
   global void finish(Database.BatchableContext BC) {
    	batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		logger.saveLogRecords();	
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
	}
}