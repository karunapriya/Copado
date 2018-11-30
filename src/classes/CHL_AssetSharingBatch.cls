/**
 * Created Date		: Sep 28, 2017
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - Asset sharing batch, to share assets with partner users of the partner account which are stamped on Asset as Partner account 1/2. 
 *									 If Partner Account 1/2 is part of any of the portal group then asset should share with corresponding public group. 
 * Support Email 	: tanvi@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *_____________________________________________________________________________________________________________________________________
 *
 * Tanvi					US2765				Sep 28, 2017			1.1				Batch class to share Assets with partner users.	
 *
 */
 global with sharing class CHL_AssetSharingBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{
	
	private CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	
	//Schedulable method
    global void execute(SchedulableContext SC) {   
    	Integer batchSize = CSM_Util.getCustomListSetting('CHL_AssetSharingBatch');
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        Id batchprocessid = Database.executeBatch(this,batchSize);
    }
	
	//Start method
	global Database.QueryLocator start(Database.BatchableContext batchContext) {
		String jobId = batchContext.getJobId();
		try{  
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CHANNEL, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									'Asset',
									jobId);
			
        	String queryStr = 'select Id, CHL_Partner_Account_1__c, CHL_Partner_Account_2__c from Asset where CHL_Partner_Account_1__c != null or CHL_Partner_Account_2__c != null'; 
        	if(Test.isRunningTest() && CHL_AssetSharingBatchTest.isNegative) {
				queryStr = 'select Id,from Asset';
			}
        	return Database.getQueryLocator(queryStr);
		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
			System.abortJob(jobId);
		}
		return null;
	}
	
	//Execute method
	global void execute(Database.BatchableContext batchContext, List<Asset> assetList)	{
		String jobId = batchContext.getJobId();
		try {	
			if(CSM_AccessController.hasObject('AssetShare')){ 				
				Set<Id> partnerAccountIds = new Set<Id>();
	       		Map<Id, Set<Id>> assetToPartnerAccounts = new Map<Id, Set<Id>>();
	       		Set<Id> assetIds = new Set<Id>();	
				Map<Id, Set<Id>> assetToNewUsers = new Map<Id, Set<Id>>();
				String assetShareReason = 'Manual';
    			
				for(Asset assObj: assetList) {
					Set<Id> paIds = assetToPartnerAccounts.get(assObj.Id);
					if(paIds == null) {
						paIds = new Set<Id>();
					}			
					if(assObj.CHL_Partner_Account_1__c != null) {
						partnerAccountIds.add(assObj.CHL_Partner_Account_1__c);
						paIds.add(assObj.CHL_Partner_Account_1__c);
					}
					if(assObj.CHL_Partner_Account_2__c != null) {
						partnerAccountIds.add(assObj.CHL_Partner_Account_2__c);
						paIds.add(assObj.CHL_Partner_Account_2__c);
					}							
					assetToPartnerAccounts.put(assObj.Id, paIds);
				}
				
				Map<Id, Set<Id>> partnerAccToUsersNGrp = CHL_AssetSharingBatchHelper.fetchPartnerAccountUsers(partnerAccountIds);
				Map<Id, Set<Id>> assetToUsers = CHL_AssetSharingBatchHelper.constructAssetToUserMap(assetToPartnerAccounts, partnerAccToUsersNGrp);
				
				assetIds = assetToPartnerAccounts.keyset();
	            system.debug('\n assetIds :: ' + JSON.serialize(String.valueOF(assetIds)) );
	            system.debug('\n partnerAccountIds :: ' + JSON.serialize(String.valueOF(partnerAccountIds)) );
	            
	            for(Id assetId :assetIds)	{
					Set<Id> usersForInsert = assetToUsers.get(assetId);
					if(usersForInsert != null) {
						for(Id userId:usersForInsert) {
							if(assetToUsers.containskey(assetId)) { 
								Set<Id> usersToInsert = assetToNewUsers.get(assetId);							
								if(usersToInsert == null){
									usersToInsert = new Set<Id>();
								}
								usersToInsert.add(userId);							
								assetToNewUsers.put(assetId, usersToInsert);
							}
						}
					}
				}
				if(assetToNewUsers != null) {
					CHL_AssetSharingBatchHelper.insertUsersInAssetShare(assetToNewUsers);
				}	
				Map<Id, Set<Id>> assetToShareUsersToDelete = CHL_AssetSharingBatchHelper.getUnwantedUsersFromAssetShare(assetToNewUsers, assetIds);
            		
	            system.debug('\n AssetToNewUsers :: ' + JSON.serialize(String.valueOF(assetToNewUsers)) );
				system.debug('\n AssetToUsersToDelete :: ' + JSON.serialize(String.valueOF(assetToShareUsersToDelete)) );				
				
				
				if(assetToShareUsersToDelete != null) {
					CHL_AssetSharingBatchHelper.deleteUsersFromAssetShare(assetToShareUsersToDelete,assetIds);
				}
	            
				logger.updateRecordsProcessed(batchResult, assetList.size());
			}
		} catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
        
	}
	 
	//finish Method 
	global void finish(Database.BatchableContext BC) {
		batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		logger.saveLogRecords();	
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
	}
	
	
    
}