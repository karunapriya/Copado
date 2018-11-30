global with sharing class CSM_BatchUpdateOldDataSPPLSPPB 
					implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	//Schedulable method
    global void execute(SchedulableContext schedulerContext){ 
        String batchprocessid = Database.executeBatch(this,1);
    }
    
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  
	//A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext batchContext){
		String jobId = batchContext.getJobId();
		String queryStr = '';
		try{   
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CSM, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CSM_Constants.OBJ_AP,
									jobId);
			
			return Database.getQueryLocator('select Id, CSM_Account_Plan_Template__c from CSM_Account_Plan__c Order By Id');
		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			//logger.saveLogRecords();
			system.abortJob(jobId);
		}
		return null;
	}
	
	global void execute(Database.BatchableContext batchContext, List<CSM_Account_Plan_PlayBook__c> planAndPlaybookList){}
	
	//Execute method
	global void execute(Database.BatchableContext batchContext, List<SObject> spList){
		list<string> fieldList=new list<string>{'csm_account_plan_template__c','csm_account_plan__c','CSM_PlayBook__c'};
        CSM_Util.checkCRUD_FLS('CSM_Account_Plan_PlayBook__c', fieldList, CSM_Constants.DML_OPERATION_INSERT);
        
		try{
			List<CSM_Account_Plan__c> successPlanList = (List<CSM_Account_Plan__c>)spList;
			Set<Id> sptIdSet = new Set<Id>();
			
			// Get the spts for SP.
			for(CSM_Account_Plan__c sp : successPlanList){
				sptIdSet.add(sp.CSM_Account_Plan_Template__c);
			}
			
			// Get all SPPB for spts
			List<CSM_Account_Plan_PlayBook__c> spPbList = [Select Id, CSM_Account_Plan_Template__c, CSM_Playbook__c 
															From CSM_Account_Plan_PlayBook__c 
															Where CSM_Account_Plan_Template__c IN:sptIdSet
																AND CSM_Account_Plan__c = null];
			Map<Id, List<CSM_Account_Plan_PlayBook__c>> sptToPbListMap = new Map<Id, List<CSM_Account_Plan_PlayBook__c>>();
			List<String> playbookIds = new List<String>();
			
			// Generate the template to SPT to SPPB List map.
			for(CSM_Account_Plan_PlayBook__c spPb : spPbList){
				List<CSM_Account_Plan_PlayBook__c> spPbListFromSpt = sptToPbListMap.get(spPb.CSM_Account_Plan_Template__c);
				if(spPbListFromSpt == null){
					spPbListFromSpt = new List<CSM_Account_Plan_PlayBook__c>();
				}
				spPbListFromSpt.add(spPb);
				playbookIds.add(spPb.CSM_Playbook__c);
				sptToPbListMap.put(spPb.CSM_Account_Plan_Template__c, spPbListFromSpt);
			}
			
			// Generate the new SPPBs for SP and SPT.
			if(!sptToPbListMap.isEmpty()){
				List<CSM_Account_Plan_PlayBook__c> newSpPbList = new List<CSM_Account_Plan_PlayBook__c>();
				for(CSM_Account_Plan__c sp : successPlanList){
					List<CSM_Account_Plan_PlayBook__c> spPbListFromSpt = sptToPbListMap.get(sp.CSM_Account_Plan_Template__c);
					if(spPbListFromSpt != null && !spPbListFromSpt.isEmpty()){
						for(CSM_Account_Plan_PlayBook__c spPb : spPbListFromSpt){
							CSM_Account_Plan_PlayBook__c planAndPlaybook = new CSM_Account_Plan_PlayBook__c();
							planAndPlaybook.csm_account_plan__c = sp.Id;
							planAndPlaybook.CSM_PlayBook__c = spPb.CSM_PlayBook__c;
							planAndPlaybook.csm_account_plan_template__c = sp.csm_account_plan_template__c;
							newSpPbList.add(planAndPlaybook);
						}
					}
				}
				if(!newSpPbList.isEmpty()){
					insert newSpPbList;	
					
					// Get all the playbooks for the given playbook Ids.
					List<CSM_PlaybookPlay__c> fullPlayBookPlayList = CSM_PlaybookPlayDataAccess.getPlaybookPlaybyPlayBook(playbookIds);
					Map<Id, Set<Id>> pbToPlayMap = new Map<Id, Set<Id>>();
					Map<String, Id> pbPlayToPbPlayMap = new Map<String, Id>();
					
					// Get the data in sets/maps for SP Play generation.
					for(CSM_PlaybookPlay__c pbPlay : fullPlayBookPlayList){
						Set<Id> playList = pbToPlayMap.get(pbPlay.CSM_Playbook__c);
						if(playList == null){
							playList = new Set<Id>();
						}
						playList.add(pbPlay.CSM_Play__c);
						pbToPlayMap.put(pbPlay.CSM_Playbook__c, playList);
						pbPlayToPbPlayMap.put(pbPlay.CSM_Playbook__c + '' + pbPlay.CSM_Play__c,  pbPlay.Id);
					}
					
					// Generate the sp plays
					if(!pbToPlayMap.isEmpty()){
						List<CSM_SuccessPlan_Play__c> successplanPlayList = new List<CSM_SuccessPlan_Play__c>();
						for(CSM_Account_Plan_PlayBook__c spPb : newSpPbList){
							Set<Id> playList = pbToPlayMap.get(spPb.CSM_Playbook__c);
							if(playList != null && !playList.isEmpty()){
								for(Id playId : playList){
									CSM_SuccessPlan_Play__c successPlanPlay = new CSM_SuccessPlan_Play__c();						
									successPlanPlay.CSM_Play__c = playId;
									successPlanPlay.CSM_SuccessPlan_Playbook__c = spPb.Id;
									successPlanPlay.CSM_Playbook_Play__c = pbPlayToPbPlayMap.get(spPb.CSM_PlayBook__c + '' + playId); 
									successplanPlayList.add(successPlanPlay);
								}
							}
						}
					}
				}
			}
 			logger.updateRecordsProcessed(batchResult, spList.size());
		}
		catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
	}
	 
	global void finish(Database.BatchableContext batchContext){

		logger.updateBatchStatus(batchResult, CSM_BatchResultsLogger.STATUS_COMPLETED, system.now());
		logger.saveLogRecords();
		Database.executeBatch(new CSM_BatchUpdateTaskWithSPPL(),200);
		CSM_Util.notifyUserBatchFailure(batchContext.getJobId());
	}
}