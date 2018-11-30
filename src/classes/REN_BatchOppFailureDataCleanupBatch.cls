global with sharing class REN_BatchOppFailureDataCleanupBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>
{
	Set<string> setBatchIds = new Set<String>();
	Boolean isManualMode = false;
	Integer daysToCheckBefore = 0;
	
	global void execute(SchedulableContext SC)
	{
		
	}  
	
	//daysToCheckBefore is a negative integer
	public REN_BatchOppFailureDataCleanupBatch(Set<String> setBatchIdsTmp, Boolean isManualModeTmp, Integer daysToCheckBeforeTmp)
	{ 
		setBatchIds = setBatchIdsTmp;
		isManualMode = isManualModeTmp;
		daysToCheckBefore = daysToCheckBeforeTmp;
	}

	global Database.queryLocator start(Database.BatchableContext BC)
	{
		List<String> fieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_CREATED_DATE,REN_CONSTANTS.REN_BATCH_ACTVTY};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_FAIL, fieldList, CSM_Constants.DML_OPERATION_READ);
		string query = 'Select ' +  CSM_Util.getNamespace() + REN_CONSTANTS.REN_BATCH_ACTVTY + ', CreatedDate '
            						+ ' FROM REN_Batch_Opportunity_Failure__c WHERE ';
        if(isManualMode)
        {
        	query += ' REN_Batch_Activity__c IN :setBatchIds';
        }
        else
        {
        	query += ' CreatedDate < :'; 
        	date d = Date.today().addDays(daysToCheckBefore);//Delete anything older than 90 days in normal mode        	
        	query += 'd';
        }
        system.debug('what is query : ' + query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<REN_Batch_Opportunity_Failure__c> failList)
	{
			if(failList != null && !failList.isEmpty())
			{
				system.debug('Fail list size : ' + failList.size());
				if(Schema.sObjectType.REN_Batch_Opportunity_Failure__c.isDeletable()){
					delete failList;
				}
			}
	}
	
	global void finish (Database.BatchableContext BC)
	{
	}
}