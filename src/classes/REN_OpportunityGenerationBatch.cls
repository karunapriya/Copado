global with sharing class REN_OpportunityGenerationBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{

	//Variables
	private Map<String, Opportunity> allRenewedOpportunityMap = new Map<String, Opportunity>();
    private String errorDrtails = '';
    private String messageDrtails = '';
    private Integer errorCount = 0; 
    private Integer successCount = 0; 
    public Boolean startFailed = false;
	
	private REN_Batch_Activity__c batchActivityObj = null;
	
	private List<REN_Field_Mappings__c> asset2OppFMapping = null;
	private List<REN_Field_Mappings__c> asset2ProductFMapping = null;
	private Set<String> groupingFieldsSet = new Set<String>();
	private String whereClause = '';
	
	//Schedulable method
    global void execute(SchedulableContext SC){   
    	String schedularID = SC.getTriggerId();
    	schedularID = schedularID.substring(0,15);
    	REN_Batch_Activity__c batchActivity = REN_BatchActivityDataAccess.getBatchAct(schedularID);
        String batchprocessid = Database.executeBatch(this);
        batchActivity.REN_Job_ID__c = batchprocessid.subString(0,15);
        batchActivity.REN_Status__c = REN_Constants.STATUS_PROCESSING;
        REN_BatchActivityDataAccess.saveBatchAct(batchActivity);
        //System.abortJob(SC.getTriggerId());
    }
    
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext BC){
		String jobId = BC.getJobId();
		jobId = jobId.substring(0,15);
		List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
		String queryStr = '';
		try{    
			batchActivityObj = REN_BatchActivityDataAccess.getBatchAct(jobId);
			batchActivityObj.REN_Failure_Assets__c = (batchActivityObj.REN_Failure_Assets__c == null? 0 : batchActivityObj.REN_Failure_Assets__c);
			asset2OppFMapping = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_ASSET, REN_Constants.FLD_MAP_ASSET_TO_OPPT);
			asset2ProductFMapping = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_ASSET, REN_Constants.FLD_MAP_ASSET_TO_OPPT);
			if(SS_Constants.isSimplifiedDataModelEnabled){
				throw new InvalidDataException('SDM Enabled : This Action not allowed in SDM ON');
			}
			if(asset2OppFMapping == null || asset2OppFMapping.isEmpty()){
				throw new REN_OpportunityResolutionTriggerHandler.FieldMappingException(String.format(Label.REN_LBL_MAPPINGS_ERROR_MSG, new String[]{REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPORTUNITY}));
			}
			
			if(asset2ProductFMapping == null || asset2ProductFMapping.isEmpty()){
				throw new REN_OpportunityResolutionTriggerHandler.FieldMappingException(String.format(Label.REN_LBL_MAPPINGS_ERROR_MSG, new String[]{REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPTY_LINE_ITEM}));
			}
			
			String groupingFields = REN_RenewBatchActivityHandler.getGroupingFields(batchActivityObj, groupingFieldsSet);
			whereClause = REN_RenewBatchActivityHandler.createWhereClause(batchActivityObj);
			if(String.isBlank(groupingFields) || String.isBlank(batchActivityObj.REN_Source_Record_Filter__c)|| String.isBlank(batchActivityObj.REN_Source_Record_Filter__r.REN_Filter_Criteria__c)){
				throw new InvalidDataException('Invalid Groups or Filters');
			}
			
			List<String> fieldList = new List<String>{REN_CONSTANTS.FLD_ID};
        	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
			batchActivityObj.REN_Grouping_Filter__c = 'SELECT id FROM Asset WHERE ' + whereClause + '\n GROUP BY ' + groupingFields ;
			String columnString = CSM_Util.getColumns(REN_Constants.OBJ_ASSET);
			String trimmedColumnString = columnString.deletewhitespace();
			CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, trimmedColumnString.split(','), CSM_Constants.DML_OPERATION_READ);  
			columnString = REN_RenewBatchActivityHandler.retrieveReferenceField(columnString,groupingFields);
			queryStr = ' Select ' + columnString + ' from Asset  WHERE ' + whereClause;
			REN_BatchActivityDataAccess.saveBatchAct(batchActivityObj);
			return Database.getQueryLocator(queryStr);
		}catch (Exception ex){
			System.debug(queryStr + '\n' + ex);
			batchActivityObj.REN_Failure_Assets__c = (batchActivityObj.REN_Failure_Assets__c == null? 1 : batchActivityObj.REN_Failure_Assets__c+1);
			batchActivityObj.REN_Status__c = REN_Constants.STATUS_FAILED;
			REN_BatchActivityDataAccess.saveBatchAct(batchActivityObj);
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = null, REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = 'No Asset has been renewed. ' + ex.getMessage()));
			REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
			errorDrtails +=  '<b>' + ++errorCount + '  : </b> - ' + ex.getMessage() + '<p/>' + ex.getStackTraceString();
			REN_RenewBatchActivityHandler.sendEmailNotifications(batchActivityObj, errorDrtails);
			String dummyQuery = 'Select id from Asset where ID = null';
			Database.QueryLocator querLoc = Database.getQueryLocator(dummyQuery);
			startFailed = true;
			system.debug('Exception in start method::::::'+startFailed);
			return querLoc;
			//System.abortJob(jobId);
		}
		return null;
	}

	//Execute method
	global void execute(Database.BatchableContext BC,List<Asset> assetList){
		CSM_TriggerManager.disableAllTriggers();
		REN_CONSTANTS.IS_AUTO_REBUILD = false;
		String jobId = BC.getJobId();
		List<REN_Batch_Activity__c> batchActivityList = new List<REN_Batch_Activity__c>();
		batchActivityList.add(batchActivityObj);
		List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
		try{
			REN_RenewBatchActivityHandler.processBatch(batchActivityList, assetList, groupingFieldsSet, asset2OppFMapping, asset2ProductFMapping, allRenewedOpportunityMap);
		}
		catch (exception ex){
    		errorDrtails +=  '<b>' + ++errorCount + '  : </b> - ' + ex.getMessage() + '<p/>'  + ex.getStackTraceString();
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = null, REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = 'Iteration Failed because ' + ex.getMessage()+'<p/>'  + ex.getStackTraceString()));
            system.debug('exception in execute $$ ' + errorDrtails);
			REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
        }
	}
	 
	global void finish(Database.BatchableContext BC){
		String jobId = BC.getJobId();
		jobId = jobId.substring(0,15);
    	//batchActivityObj.REN_Status__c = REN_Constants.STATUS_COMPLETED;
    	Map<ID, Opportunity> createdRenewedOpportunityMap = new Map<ID, Opportunity>(allRenewedOpportunityMap.values());
    	createdRenewedOpportunityMap.remove(null);
    	batchActivityObj.REN_Generated_Records__c = createdRenewedOpportunityMap.size();
    	if(!Test.isRunningTest()){ //Test method fails when 2 execute batch methods are called in a single transaction
    		Integer batchSize = CSM_Util.getCustomListSetting('REN_SetOpportunityCloseDateBatch');
    		batchSize = (batchSize == null || batchSize == 0) ? 1 : batchSize;
    		Database.executeBatch(new REN_SetOpportunityCloseDateBatch(batchActivityObj,errorDrtails,startFailed),batchSize);
    	} 
	}
	private class InvalidDataException extends Exception{}	
}