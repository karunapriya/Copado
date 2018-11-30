public with sharing class REN_BatchOppFailureDataAccess {
   public static void insertBatchFailure (List<REN_Batch_Opportunity_Failure__c> failureList){
       List<String> fieldList = new List<String>{REN_CONSTANTS.REN_ASSET,REN_CONSTANTS.REN_BATCH_ACTVTY,REN_CONSTANTS.REN_MSG, 'REN_Segment_Member__c', 'REN_Opportunity__c', 'REN_Segment_Task_ID__c'};
       CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_FAIL, fieldList, CSM_Constants.DML_OPERATION_UPSERT);
       Upsert failureList;
    }
    
	public static List<REN_Batch_Opportunity_Failure__c> getFailedAssetsRecords(String batchId)
	{
		List<String> opportunityFailFieldList = new List<String>{REN_CONSTANTS.OBJ_REN_RENEWS_TO_ASSET,
        														REN_CONSTANTS.REN_MSG,
        														REN_CONSTANTS.REN_RECORD_NAME,
        														REN_CONSTANTS.REN_RECORDID,
        														REN_CONSTANTS.REN_BATCH_ACTVTY
		                                                    };
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_FAIL, opportunityFailFieldList, CSM_Constants.DML_OPERATION_READ);
		String soql = 'Select REN_Record_Id__c, REN_Record_Name__c, REN_Asset__r.name, REN_Batch_Activity__c, REN_Failure_Message__c, '+
						'REN_Asset__c, REN_Asset__r.Account.Name, REN_Asset__r.Product2.Name, '+
						(UserInfo.isMultiCurrencyOrganization()?'Format(convertCurrency(REN_Asset__r.Price)),':'Format(REN_Asset__r.Price),') +
						'Format(REN_Asset__r.REN_End_Date__c) From REN_Batch_Opportunity_Failure__c where REN_Batch_Activity__c = :batchId';
		return database.query(soql);
	}
	
	public static List<REN_Batch_Opportunity_Failure__c> getBatchActivityDetails(ID batchId, Boolean isErrorRecords){
		List<String> opportunityFailFieldList = new List<String>{REN_CONSTANTS.OBJ_REN_RENEWS_TO_ASSET,
        														REN_CONSTANTS.REN_MSG,
        														REN_CONSTANTS.REN_RECORD_NAME,
        														REN_CONSTANTS.REN_RECORDID,
        														REN_CONSTANTS.REN_BATCH_ACTVTY,
        														'REN_Segment_Member__c','REN_Opportunity__c','REN_Segment_Task_ID__c'
		                                                    };
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_FAIL, opportunityFailFieldList, CSM_Constants.DML_OPERATION_READ);
		String soql = 'Select REN_Segment_Member__c, REN_Opportunity__c, REN_Opportunity__r.Name, REN_Segment_Task_ID__c, REN_Record_Id__c, REN_Record_Name__c, REN_Asset__r.name, REN_Batch_Activity__c, REN_Failure_Message__c, '+
						'REN_Asset__c, REN_Asset__r.Account.Name, REN_Asset__r.Product2.Name, REN_Segment_Member__r.Name,'+
						(UserInfo.isMultiCurrencyOrganization()?'Format(convertCurrency(REN_Asset__r.Price)),':'Format(REN_Asset__r.Price),') +
						'Format(REN_Asset__r.REN_End_Date__c) From REN_Batch_Opportunity_Failure__c where REN_Batch_Activity__c = :batchId';
		if(isErrorRecords != null){
			if(isErrorRecords){
				soql += ' AND REN_Segment_Task_ID__c = null ';
			}else{
				soql += ' AND REN_Segment_Task_ID__c != null ';
			}
		}
		soql += ' LIMIT 40000 ';
		return database.query(soql);
	}
}