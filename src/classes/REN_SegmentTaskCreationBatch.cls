/**
 * Created Date		: Apr 17, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
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
 * Chandra					User Story				Apr 17, 2017			1.1					@description
 *
*/
global with sharing class REN_SegmentTaskCreationBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{

	//Variables
	//private Map<String, Opportunity> allRenewedOpportunityMap = new Map<String, Opportunity>();
    private String errorDrtails = '';
    private String messageDrtails = '';
    private Integer errorCount = 0; 
    private Integer successCount = 0; 
    public Boolean startFailed = false;
    public String testClassTest = 'a';
	
	public REN_Batch_Activity__c batchActivityObj = null;
	public REN_Task_Template__c taskTemplateObj = null;
	
	//Schedulable method
    global void execute(SchedulableContext SC){   
    	String schedularID = SC.getTriggerId();
    	schedularID = schedularID.substring(0,15);
    	batchActivityObj = REN_BatchActivityDataAccess.getBatchAct(schedularID);
    	taskTemplateObj = batchActivityObj.REN_Task_Template__r;
    	System.debug('\nSchedule Start~~~~batchActivityObj: ' + batchActivityObj);
    	Integer batchSize = CSM_Util.getCustomListSetting('REN_SegmentTaskCreationBatch'); 
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        String batchprocessid = Database.executeBatch(this,batchSize);
        batchActivityObj.REN_Job_ID__c = batchprocessid.subString(0,15);
        batchActivityObj.REN_Status__c = REN_Constants.STATUS_PROCESSING;
        REN_BatchActivityDataAccess.saveBatchAct(batchActivityObj);
        //System.abortJob(SC.getTriggerId());
    }
    
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext BC){
		System.debug('\nBatch Start~~~~batchActivityObj: ' + batchActivityObj);
		String jobId = BC.getJobId();
		jobId = jobId.substring(0,15);
		List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
		String queryStr = '';
		try{    
			ID segmentId = batchActivityObj.REN_Segment__c;
			List<String> fieldList = new List<String>{'REN_Asset__c', 'REN_Opportunity__c', 'REN_Segment_Primary_Contact__c', 'REN_Segment__c'};
        	queryStr = 'Select REN_Asset__c, REN_Opportunity__c, REN_Asset__r.Account.OwnerId, REN_Asset__r.Contact.OwnerId, REN_Segment_Primary_Contact__c, REN_Segment__c, REN_Segment__r.Name ';

			String contactFieldWithoutNamespace = taskTemplateObj.REN_Contact__c;
			contactFieldWithoutNamespace = String.isBlank(contactFieldWithoutNamespace) ? '' : contactFieldWithoutNamespace.replaceFirst(CSM_Util.getNamespace(), '');
			String ownerFieldWithoutNamespace = batchActivityObj.REN_Owner_Field_Name__c;
			ownerFieldWithoutNamespace = String.isBlank(ownerFieldWithoutNamespace) ? '' : ownerFieldWithoutNamespace.replaceFirst(CSM_Util.getNamespace(), '');
			
			if(batchActivityObj.REN_Segment__r.REN_Type__c == 'ABRLM'){
				if(CSM_AccessController.hasField('Asset', contactFieldWithoutNamespace)){
					queryStr += (String.isNotBlank(contactFieldWithoutNamespace)) ? ', REN_Asset__r.' + contactFieldWithoutNamespace : '';
				}
				if(CSM_AccessController.hasField('Asset', ownerFieldWithoutNamespace)){
					queryStr += ', REN_Asset__r.' + ownerFieldWithoutNamespace;
				}
			}else{
				if(CSM_AccessController.hasField('Opportunity', contactFieldWithoutNamespace)){
					queryStr += (String.isNotBlank(contactFieldWithoutNamespace)) ? ', REN_Opportunity__r.' + contactFieldWithoutNamespace : '';
				}
				if(CSM_AccessController.hasField('Opportunity', ownerFieldWithoutNamespace)){
					queryStr += ', REN_Opportunity__r.' + ownerFieldWithoutNamespace;
				}else{
					queryStr += ', REN_Opportunity__r.OwnerId' ;
				}
			}
			CSM_Util.checkCRUD_FLS('REN_Segment_Member__c', fieldList, CSM_Constants.DML_OPERATION_READ);
			
			testClassTest = Test.isRunningTest() ? testClassTest.subString(0) : testClassTest; // if testClassTest == null, it will throw an exception.
			System.debug('\n\n' + queryStr + ' from REN_Segment_Member__c  WHERE REN_Segment__c =:segmentId AND (REN_Asset__c != null OR REN_Opportunity__c != null)');
			return Database.getQueryLocator(queryStr + ' from REN_Segment_Member__c  WHERE REN_Segment__c =:segmentId AND (REN_Asset__c != null OR REN_Opportunity__c != null)');
		}catch (Exception ex){
			System.debug(queryStr + '\n' + ex);
			batchActivityObj.REN_Failure_Assets__c = (batchActivityObj.REN_Failure_Assets__c == null? 1 : batchActivityObj.REN_Failure_Assets__c+1);
			batchActivityObj.REN_Status__c = REN_Constants.STATUS_FAILED;
			REN_BatchActivityDataAccess.saveBatchAct(batchActivityObj);
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = 'No Task has been created. ' + ex.getMessage() + '\n\n' + ex.getStackTraceString()));
			REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
			errorDrtails +=  '<b>' + ++errorCount + '  : </b> - ' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
			String dummyQuery = 'Select id from REN_Segment_Member__c where ID = null';
			Database.QueryLocator querLoc = Database.getQueryLocator(dummyQuery);
			startFailed = true;
			system.debug('Exception in start method::::::'+startFailed);
			return querLoc;
		}
		return null;
	}

	//Execute method
	global void execute(Database.BatchableContext BC,List<REN_Segment_Member__c> segmentList){
		System.debug('\nExecute~~~~batchActivityObj: ' + batchActivityObj);
		String jobId = BC.getJobId();
		List<REN_Batch_Activity__c> batchActivityList = new List<REN_Batch_Activity__c>();
		batchActivityList.add(batchActivityObj);
		List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
		try{
			REN_SegmentTaskCreationBatchHelper helper = new REN_SegmentTaskCreationBatchHelper();
			helper.createTask(batchActivityList, segmentList, taskTemplateObj);
		}
		catch (exception ex){
    		errorDrtails +=  '<b>' + ++errorCount + '  : </b> - ' + ex.getMessage() + '<br/>'  + ex.getStackTraceString();
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = 'Iteration Failed because ' + ex.getMessage()+'<p/>'  + ex.getStackTraceString()));
            system.debug('exception in execute $$ ' + errorDrtails);
			REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
        }
	}
	 
	global void finish(Database.BatchableContext BC){
		try{
			System.debug('\nFinish~~~~batchActivityObj: ' + batchActivityObj);
			//List<Opportunity> allCreatedOppList = [Select id, amount FROM Opportunity WHERE REN_Batch_Activity_ID__c = :batchActivityId];
			List<REN_Batch_Opportunity_Failure__c> batchActivityDetailList = REN_BatchOppFailureDataAccess.getBatchActivityDetails(batchActivityObj.id, null);
			batchActivityObj.REN_Failure_Assets__c = 0;
			batchActivityObj.REN_Generated_Records__c  = 0;
			
    		for(REN_Batch_Opportunity_Failure__c o: batchActivityDetailList){
    			if(o.REN_Segment_Task_ID__c != null){
    				batchActivityObj.REN_Generated_Records__c++;
    			}else{
    				batchActivityObj.REN_Failure_Assets__c++;
    			}
    		}
	    	//String segmentStatus = 'Task creation failed';
	    	if(!startFailed){
		    	if(batchActivityObj.REN_Failure_Assets__c > 0 && batchActivityObj.REN_Generated_Records__c > 0){
					batchActivityObj.REN_Status__c = REN_Constants.STATUS_PARTIAL_SUCCESS;
					//segmentStatus = 'Task created with errors';
				}
				else if(batchActivityObj.REN_Failure_Assets__c > 0 && batchActivityObj.REN_Generated_Records__c == 0){
					batchActivityObj.REN_Status__c = REN_Constants.STATUS_FAILED;
					//segmentStatus = 'Task creation failed';
				}
				else if(batchActivityObj.REN_Failure_Assets__c == 0 && batchActivityObj.REN_Generated_Records__c > 0){
					batchActivityObj.REN_Status__c = REN_Constants.STATUS_COMPLETED;
					//segmentStatus = 'Task created';
				}else{
					batchActivityObj.REN_Status__c = 'Processed';
				}
	    		batchActivityObj.REN_Job_Completion_Date__c = System.now();
				REN_BatchActivityDataAccess.saveBatchAct(batchActivityObj);
			}
			REN_Segment__c segmentObj = new REN_Segment__c(id = batchActivityObj.REN_Segment__c, REN_Task_Batch_Status__c = batchActivityObj.REN_Status__c);
			REN_SegmentDataAccess.saveSegments(new List<REN_Segment__c>{segmentObj});
			REN_SegmentTaskCreationBatchHelper.sendEmailNotifications(new List<REN_Batch_Activity__c>{batchActivityObj}, errorDrtails);	          
				           
		}
		catch (exception ex){
            system.debug('\n\nException REN_SegmentTaskCreationBatch: '  + ex.getStackTraceString());
            List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = 'Finish method failed because ' + ex.getMessage()+'<br/>'  + ex.getStackTraceString()));
			REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
		}
	}
	
	private class InvalidDataException extends Exception{}
}