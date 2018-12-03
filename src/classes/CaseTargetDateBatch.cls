/**
 * Created Date		: Oct 27, 2016
 * Developed By		: prashant, Comity Designs, Inc.
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
 * prashant					User Story				Oct 27, 2016			1.1					@description
 * 
 */
public with sharing class CaseTargetDateBatch implements IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{
	
	public String namespace = Util.solnExtnNameSpace;
	private Zenith_Features__c zenithFeaturesCS;
	
	//Schedulable method
    public void executeScheduler(SchedulableContext SC){  
    	Integer batchSize = Util.getCustomListSetting('SE_CaseTargetDateBatch'); 
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        String batchprocessid = Database.executeBatch(this, batchSize);
        System.abortJob(SC.getTriggerId());
    }
    
	public Database.queryLocator start(Database.BatchableContext batchContext){
		zenithFeaturesCS = Zenith_Features__c.getOrgDefaults();
		Datetime d = zenithFeaturesCS.Last_Case_Target_Date_Batch_Executed_On__c;
		zenithFeaturesCS.Last_Case_Target_Date_Batch_Executed_On__c = datetime.now();
		String queryStr = 'Select TargetDate, CaseId From CaseMilestone WHERE Case.Status NOT IN (\'Closed\', \'Closed - Unsuccessfully\', \'Closed Automatically\')';
		if(d != null){
			queryStr += ' AND (CreatedDate >= :d OR (Case.Target_Date__c = null AND TargetDate != null)) ';
		}
		queryStr += ' ORDER BY CreatedDate';
		Util.checkCRUD_FLS('CaseMilestone', new List<String>{'TargetDate', 'CaseId'}, Constants.DML_OPERATION_READ);
		return Database.getQueryLocator(queryStr);
	}
	
    public void execute(Database.BatchableContext batchContext,List<SObject> recordList){
    	List<CaseMilestone> cMilestoneList = (List<CaseMilestone>)recordList;
    	Map<ID, Case> caseMap = new Map<ID, Case>();
    	for(CaseMilestone cMilestone: cMilestoneList){
    		caseMap.put(cMilestone.CaseId, new Case(ID=cMilestone.CaseId, Target_Date__c=cMilestone.TargetDate));
    	}
    	if(!caseMap.isEmpty()){
    		Constants.CASE_BEFORE_UPDATE_TRIGGER = false;
    		Constants.CASE_AFTER_UPDATE_TRIGGER = false;
    		System.debug('\n\n~~~~Case List: ' + caseMap.size() + ' Records :- ' + (JSON.serialize(caseMap.keySet())));
    		List<Database.SaveResult> saveSuseltList = CaseDataAccess.updateValidCases(caseMap.values(), new List<String>{namespace+'Target_Date__c'});
    		/*
			for(Database.SaveResult result: saveSuseltList){
	            if (!result.isSuccess()){
	            	//CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: ' + result.getId() + ' - ' + result.getErrors().get(0));
					//logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_PENDING, objectName,	batchContext.getJobId());
	            }
			}
			*/
    	}
    }

	public void finish(Database.BatchableContext batchContext){
		upsert zenithFeaturesCS;
		
		String strDateTime = (zenithFeaturesCS.Last_Case_Target_Date_Batch_Executed_On__c.addHours(1)).format('00 00 HH dd MM ? yyyy');
		String jobID = system.schedule('Case Target Date Batch', strDateTime, new CaseTargetDateScheduledDispatcher());        
		
	}

}