public with sharing class CSM_BatchResultsLogger {
    	
	public static final String MODULE_CSM = 'CSM';
	public static final String MODULE_RENEW = 'Renew';
	public static final String MODULE_CHANNEL = 'Channel';
	public static final String MODULE_SEGMENT = 'Segment';	
	
	public static final String STATUS_PENDING = 'Pending';
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String STATUS_FAILED = 'Failed';
	
	private static CSM_BatchResultsLogger logger;
	private List<CSM_Batch_Result__c> batchResultList;
	
	private CSM_BatchResultsLogger(){
		batchResultList = new List<CSM_Batch_Result__c>();
	}
	
	public static CSM_BatchResultsLogger getInstance() {
	    if (logger == null){
	    	logger = new CSM_BatchResultsLogger();
	    }
	    return logger;
	}
	
	public void addLogRecord(CSM_Batch_Result__c batchResult, Datetime batchStartTime, 
								String module, String status, String objectProcessed, String jobId){
		if(batchResult == null){
			batchResult = new CSM_Batch_Result__c();
		}
		batchResult.CSM_Batch_Start_Time__c = batchStartTime;
		batchResult.CSM_Module__c = module; 
		batchResult.CSM_Status__c = status;
		batchResult.CSM_Objects_Processed__c = objectProcessed;
		batchResult.CSM_BatchId__c = jobId;
		this.batchResultList.add(batchResult);
	}
	
	public void setErrorFieldValues(CSM_Batch_Result__c batchResult, Datetime batchCompleteTime, 
									Boolean hasErrors, String errorDescription){
		if(batchResult != null){
			batchResult.CSM_Batch_Completion_Time__c = batchCompleteTime;
			batchResult.CSM_Errors__c = true;
			if(String.isNotEmpty(errorDescription)){
				batchResult.CSM_Error_Description__c = 
					(batchResult.CSM_Error_Description__c == null)
					? '' + errorDescription 
					: batchResult.CSM_Error_Description__c + errorDescription;
			}
			batchResult.CSM_Error_Description__c = errorDescription;
		}
	}
	
	public void updateRecordsProcessed(CSM_Batch_Result__c batchResult, Integer recordCount){
		if(batchResult != null){
			batchResult.CSM_Records_Processed__c = 
 				(batchResult.CSM_Records_Processed__c == null) 
 				? 0 + recordCount 
 				: batchResult.CSM_Records_Processed__c + recordCount;
		}
	}
	
	public void updateBatchStatus(CSM_Batch_Result__c batchResult, String status, Datetime competionTime){
		if(batchResult != null){
			batchResult.CSM_Status__c = status;
			batchResult.CSM_Batch_Completion_Time__c = competionTime;
		}
	}
	
	public void saveLogRecords(){
		if(!this.batchResultList.isEmpty()){
			List<String> batchResultsFieldList = new List<String>{CSM_Constants.OBJ_BR_STATUS, 
			    CSM_Constants.OBJ_BR_COMPLETION_TIME, CSM_Constants.OBJ_BR_START_TIME, 
			    CSM_Constants.OBJ_BR_MODULE, CSM_Constants.OBJ_BR_OBJECTS_PROCESSED, CSM_Constants.OBJ_BR_ERROR, CSM_Constants.OBJ_BR_ERROR_DESC, CSM_Constants.OBJ_BR_ID};
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BR, batchResultsFieldList, CSM_Constants.DML_OPERATION_UPSERT);
			
			upsert this.batchResultList;
			this.batchResultList.clear();
		}
	}
	
	/*
	** @Description: Gets all Batch results for Quote Requests
	*/
    public static List<CSM_Batch_Result__c> getQuoteRequestResults() {
		List<String> readFieldsList = new List<String> {
														CSM_Constants.OBJ_BR_STATUS,
														CSM_Constants.OBJ_BR_COMPLETION_TIME,
														CSM_Constants.OBJ_BR_START_TIME,
														CSM_Constants.OBJ_BR_MODULE,
														CSM_Constants.OBJ_BR_OBJECTS_PROCESSED,
														CSM_Constants.OBJ_BR_ID,
														CSM_Constants.OBJ_BR_ERROR_DESC,
														CSM_Constants.OBJ_BR_ERROR,
														CSM_Constants.OBJ_BR_RECORDS,
														CSM_Constants.OBJ_BR_SEGMENTS																																										
				    								};
    	
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BR, readFieldsList, CSM_Constants.DML_OPERATION_READ);
        
        return [SELECT name, CSM_Status__c, format(CSM_Batch_Completion_Time__c), format(CSM_Batch_Start_Time__c), CSM_Module__c, CSM_Objects_Processed__c, CSM_BatchId__c, CSM_Error_Description__c, CSM_Errors__c, CSM_Records_Processed__c, REN_Segment_Names__c
        		FROM CSM_Batch_Result__c where CSM_Module__c = 'Segment' order by createddate desc];
    }
	
}