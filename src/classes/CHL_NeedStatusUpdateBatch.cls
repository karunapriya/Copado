global with sharing class CHL_NeedStatusUpdateBatch implements REN_IScheduleDispatched, Database.Batchable<sObject>, Database.Stateful {
	
	//Variables
	global final String Query;
	//public List<CHL_Partner_Opportunity__c> partnerOpportunityList {get; set;}
	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
  
    //Schedulable method
    global void execute(SchedulableContext SC) {   
    	Integer batchSize = CSM_Util.getCustomListSetting('CHL_NeedStatusUpdateBatch');
    	system.debug('batchSize=========>>' +batchSize);
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        ID batchprocessid = Database.executeBatch(this,batchSize);
        //System.abortJob(SC.getTriggerId()); //This is not required, jobs are running only at the time of 1st schedule. 
    }
  
    //Constructor
    global CHL_NeedStatusUpdateBatch()  {
	    //partnerOpportunityList = new List<CHL_Partner_Opportunity__c>();    
	    //List<CHL_Opportunity_Status_Log__c> channelOpptyStatusLogList  = new List<CHL_Opportunity_Status_Log__c>();
	    //Query = 'select Id, CHL_Last_Status_Update_Date__c, CHL_Sales_Stage__c,CHL_Needs_Status_Update__c, CreatedDate,CHL_Expiration_Date__c from CHL_Partner_Opportunity__c where CHL_Needs_Status_Update__c = false';   //id in :idset ';  
	    
  	}
  
 	//Start method
  	global Database.QueryLocator start(Database.BatchableContext batchContext) {
     	String jobId = batchContext.getJobId();
		try{  
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CHANNEL, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									'CHL_Partner_Opportunity__c',
									jobId);
			List<CHL_Opportunity_Status_Log__c> channelOpptyStatusLogList =  [SELECT Id, CHL_Field_API_Names__c, CHL_Exclude_Sales_Stages__c,CHL_Days_before_Expiration__c, CHL_Days_between_Update__c from CHL_Opportunity_Status_Log__c limit 1];
      
       		Set<String> strOfStages = CHL_Util.splitStages(channelOpptyStatusLogList.get(0).CHL_Exclude_Sales_Stages__c);
        	String queryStr = 'select Id, CHL_Last_Status_Update_Date__c, CHL_Sales_Stage__c,CHL_Needs_Status_Update__c, CreatedDate,CHL_Expiration_Date__c from CHL_Partner_Opportunity__c where CHL_Needs_Status_Update__c = false AND CHL_Sales_Stage__c NOT IN :strOfStages'; 
        	if(Test.isRunningTest() && CHL_PartnerOpptyPermissionBatchTest.isNegative) {
				queryStr = 'select Id,from CHL_Partner_Opportunity__c';
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
    global void execute(Database.BatchableContext BC, List<CHL_Partner_Opportunity__c> scope) {
	    String jobId = BC.getJobId();
	    Integer diffOfLastUpdateNToday;
	    Integer diffOfExpirationDateeNToday;
	    Date currDate = system.today();
	    Decimal daysBeforeExpiration = 0;
	    List<CHL_Partner_Opportunity__c> partnerOpportunityListToUpdate = new List<CHL_Partner_Opportunity__c>();
    	try	{
      
	      	List<CHL_Opportunity_Status_Log__c> channelOpptyStatusLogList =  [SELECT Id, CHL_Field_API_Names__c, CHL_Exclude_Sales_Stages__c,CHL_Days_before_Expiration__c, CHL_Days_between_Update__c from CHL_Opportunity_Status_Log__c limit 1];
	      
	      	// Set<String> strOfStages = CHL_Util.splitStages(channelOpptyStatusLogList.get(0).CHL_Exclude_Sales_Stages__c);
	      	//CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
	      	for(CHL_Partner_Opportunity__c ch : scope)      {
	        
	        	if(ch.CHL_Last_Status_Update_Date__c != null) {
		        	diffOfLastUpdateNToday = (ch.CHL_Last_Status_Update_Date__c).daysBetween(currDate);      
		        } else {
		        	diffOfLastUpdateNToday = ((ch.CreatedDate).Date()).daysBetween(currDate);  
		        }  
		        if(ch.CHL_Expiration_Date__c != null) {
		        	diffOfExpirationDateeNToday = (currDate).daysBetween(ch.CHL_Expiration_Date__c);  
		        } else {
		        	diffOfExpirationDateeNToday = 0;
		        }
		        if(channelOpptyStatusLogList[0].CHL_Days_before_Expiration__c != null && !string.isblank(string.valueof(channelOpptyStatusLogList[0].CHL_Days_before_Expiration__c))) {
		        	daysBeforeExpiration = channelOpptyStatusLogList[0].CHL_Days_before_Expiration__c;
		        }
		        system.debug('$$Date Difference : '+diffOfLastUpdateNToday + ' :: '+diffOfExpirationDateeNToday + ' : '+daysBeforeExpiration);
		        if(diffOfLastUpdateNToday >= channelOpptyStatusLogList[0].CHL_Days_between_Update__c && diffOfExpirationDateeNToday <= daysBeforeExpiration && daysBeforeExpiration > 0)  {
		        	ch.CHL_Needs_Status_Update__c = true;
		          	partnerOpportunityListToUpdate.add(ch);          
		        } else if(diffOfLastUpdateNToday >= channelOpptyStatusLogList[0].CHL_Days_between_Update__c && daysBeforeExpiration == 0) {
		          	ch.CHL_Needs_Status_Update__c = true;
		          	partnerOpportunityListToUpdate.add(ch);  
		        } 		        
      		}
      		if(partnerOpportunityListToUpdate != null && !partnerOpportunityListToUpdate.isEmpty()) {
	            CHL_Constants.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
		        CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
		        Database.update(partnerOpportunityListToUpdate, false);
	        }
  	  		logger.updateRecordsProcessed(batchResult, scope.size());
		}
    	catch (exception ex){
	      logger.setErrorFieldValues(batchResult, system.now(), true, 
	        'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
  	}
   
    //finish Method 
    global void finish(Database.BatchableContext BC)	{    
	    batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		logger.saveLogRecords();	
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
  	}

}