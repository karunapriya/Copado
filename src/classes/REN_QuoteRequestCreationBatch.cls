/**
 * Created Date		: Feb 5, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
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
 * abirjepatil					User Story				Feb 5, 2017			1.1					@description
 * 
 */
global with sharing class REN_QuoteRequestCreationBatch
					implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	public String segmentsProcessed = '';
	
	//Schedulable method
	// This REN_QuoteRequestCreationBatch batch do not have dispatcher class so, we can not schedule from UI so, this method will not be invoked.
    global void execute(SchedulableContext schedulerContext){ 
    	Integer batchSize = CSM_Util.getCustomListSetting('REN_QuoteRequestCreationBatch');
    	batchSize = (batchSize == null || batchSize == 0) ? 1 : batchSize;
        String batchprocessid = Database.executeBatch(this,batchSize);
    }
    
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  
	//A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext batchContext){
		String jobId = batchContext.getJobId();
		String queryStr = '';
		try{   
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_SEGMENT, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									REN_Constants.OBJ_SEGMENT,
									jobId);
			
			String namespace = CSM_Util.getNameSpace(); 
			Datetime queryDate = Test.isRunningTest()?(system.now() + 1):(system.now());
			
			if(CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId')){
				queryStr = 'select id, ' + namespace + 'REN_segment__c,' + namespace + 'REN_segment__r.Name,' + namespace + 'REN_Opportunity__c, ' + namespace + 'ren_opportunity__r.accountid,  ' + namespace + 'ren_opportunity__r.ownerid from  ' + namespace + 'ren_segment_member__c where  ' + namespace + 'ren_opportunity__r.SyncedQuoteid = null and  ' + namespace + 'REN_Segment__r.' + namespace + 'ren_quoterequest_submitted__c = true and  ' + namespace + 'REN_Segment__r.' + namespace + 'ren_quoterequest_created__c = false order by  ' + namespace + 'ren_segment__c';				
			} else if(Test.isRunningTest()) {
				queryStr = 'select id, ' + namespace + 'REN_segment__c,' + namespace + 'REN_segment__r.Name,' + namespace + 'REN_Opportunity__c, ' + namespace + 'ren_opportunity__r.accountid,  ' + namespace + 'ren_opportunity__r.ownerid from  ' + namespace + 'ren_segment_member__c where  ' +  namespace + 'REN_Segment__r.' + namespace + 'ren_quoterequest_submitted__c = true and  ' + namespace + 'REN_Segment__r.' + namespace + 'ren_quoterequest_created__c = false order by  ' + namespace + 'ren_segment__c';
			}
			
	    	if(Test.isRunningTest()){
	    		if(REN_QuoteRequestCreationBatchTest.isNegative == true){
					queryStr = 'SELECT Id,';	 
	    		} 	
	    	}

            CSM_Util.checkCRUD_FLS(REN_CONSTANTS.OBJ_SEGMEMBER, new List<String>{
    		CSM_Constants.OBJ_O_ID, REN_CONSTANTS.OBJ_SM_OPPORTUNITY,REN_CONSTANTS.OBJ_SEGMENT}, 
    	    CSM_Constants.DML_OPERATION_READ);
            

            CSM_Util.checkCRUD_FLS(REN_CONSTANTS.OBJ_SEGMENT, new List<String>{
    		CSM_Constants.OBJ_O_ID, REN_CONSTANTS.OBJ_SE_QR_CREATED,REN_CONSTANTS.OBJ_SE_QR_SUBMITTED}, 
    	    CSM_Constants.DML_OPERATION_READ);

			if(queryStr != ''){
				return Database.getQueryLocator(queryStr);			
			}else{
				return null;
			}

		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			//logger.saveLogRecords();
			system.abortJob(jobId);
		}
		return null;
	}

	//Execute method
	global void execute(Database.BatchableContext batchContext, List<SObject> segmentMemberList){
		String jobId = batchContext.getJobId();
		String namespace = CSM_Util.getNameSpace();
		String senamespace = CSM_Util.nameSpacePrefixSolnExtn;		

		String strSegment = '';
		String strSegmentName = '';	
		
		try{
			set<string> strOwner = new set<string>(); 
			for(SObject segmentMember: segmentMemberList){
				if(segmentMember != null && segmentMember.getSObject(namespace + 'REN_Opportunity__r') != null){
					strOwner.add((String)segmentMember.getSObject(namespace + 'REN_Opportunity__r').get('OwnerId'));
				}
			}			
			
			List<SObject> contactList = new List<SObject>();
			if(CSM_AccessController.hasField('Contact', 'ssi_zth__system_user_reference__c')){
				contactList = Database.query('select Id,SSI_ZTH__System_User_Reference__c from Contact where SSI_ZTH__System_User_Reference__c in: strOwner');				
			} else if(CSM_AccessController.hasField('Contact', 'system_user_reference__c')){
				contactList = Database.query('select Id,' + senamespace + 'System_User_Reference__c from Contact where ' + senamespace + 'System_User_Reference__c in: strOwner');				
			}
			

			Map<string,string> contactMap = new Map<string,string>();
			
			if(CSM_AccessController.hasField('Contact', 'ssi_zth__system_user_reference__c')){
				for(SObject individualContact:contactList){
					contactMap.put((String)individualContact.get('SSI_ZTH__System_User_Reference__c'),(String)individualContact.get('Id'));
				}
			}else if(CSM_AccessController.hasField('Contact', 'system_user_reference__c')){
				for(SObject individualContact:contactList){
					contactMap.put((String)individualContact.get(senamespace + 'System_User_Reference__c'),(String)individualContact.get('Id'));
				}
			}
			
			
			List<REN_Field_Mappings__c> caseMapping = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(CSM_Constants.OBJ_CASE,CSM_Constants.OBJ_CASE);
			List<RecordType> recordType = CSM_CaseDataAccess.getRecordTypes(CSM_Constants.OBJ_CASE,'Quote Request');
			
			List<Case> caseList = new List<Case>();
			
			for(SObject segmentMember: segmentMemberList){
				if(strSegment == ''){
					strSegment = (String)segmentMember.get(namespace + 'REN_Segment__c');
					strSegmentName = (String)segmentMember.getSObject(namespace + 'REN_segment__r').get('Name');				
					if(!segmentsProcessed.contains(strSegmentName)){
						segmentsProcessed += strSegmentName;
					}
				}else if (strSegment != (String)segmentMember.get(namespace + 'REN_Segment__c')){
 					try{
 						insert caseList; 

						processSegment(strSegment, false);						
 					}
 					catch(Exception ex){
						logger.setErrorFieldValues(batchResult, system.now(), true, 
							'For Segment :- ' + strSegmentName + ' Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
						
						processSegment(strSegment, true);						
 					}

					caseList = new List<Case>(); 					
				}
				
				strSegment = (String)segmentMember.get(namespace + 'REN_Segment__c');	
				strSegmentName = (String)segmentMember.getSObject(namespace + 'REN_segment__r').get('Name');
				if(!segmentsProcessed.contains(strSegmentName)){
					segmentsProcessed += ',' + strSegmentName;
				}
											
				SObject newCase = new Case();
				
				newCase.put('AccountId',(String)segmentMember.getSObject(namespace + 'REN_Opportunity__r').get('AccountId'));
				if(CSM_AccessController.hasField('Case', 'ssi_zth__opportunity__c')){
					newCase.put('SSI_ZTH__Opportunity__c',(String)segmentMember.get(namespace + 'REN_Opportunity__c'));				
				}else if(CSM_AccessController.hasField('Case', 'opportunity__c')){
					newCase.put(senamespace + 'Opportunity__c',(String)segmentMember.get(namespace + 'REN_Opportunity__c'));				
				}


				if(CSM_AccessController.hasField('Contact', 'ssi_zth__system_user_reference__c')){
					newCase.put('ContactId',contactMap.get((String)segmentMember.getSObject(namespace + 'REN_Opportunity__r').get('OwnerId')));
				} else if(CSM_AccessController.hasField('Contact', 'system_user_reference__c')){
					newCase.put('ContactId',contactMap.get((String)segmentMember.getSObject(namespace + 'REN_Opportunity__r').get('OwnerId')));
				}
				

				if(CSM_AccessController.hasField('Case', 'ssi_zth__sub_case_type__c')){
					newCase.put('SSI_ZTH__Sub_Case_Type__c', 'New');				
				}else if(CSM_AccessController.hasField('Case', 'sub_case_type__c')){
					newCase.put(senamespace + 'Sub_Case_Type__c', 'New');				
				}


				if(recordType != null && !recordType.isEmpty()){
					newCase.put('RecordTypeId',recordType[0].id);				
				}

				for(REN_Field_Mappings__c fieldMapping: caseMapping){
					newCase.put(fieldMapping.REN_To_Field_API_Name__c,fieldMapping.REN_Default_Value__c);
				}
			
				caseList.add((Case)newCase);
			}
 			
 			insert caseList;

			processSegment(strSegment, false); 			
 			
 			logger.updateRecordsProcessed(batchResult, segmentMemberList.size());
		}
		catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'For Segment :- ' + strSegmentName + ' Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());

			processSegment(strSegment,true);
        }
	}
	 
	global void finish(Database.BatchableContext batchContext){
		batchResult.REN_Segment_Names__c = segmentsProcessed;
		logger.updateBatchStatus(batchResult, CSM_BatchResultsLogger.STATUS_COMPLETED, system.now());
		logger.saveLogRecords();
		//CSM_Util.notifyUserBatchFailure(batchContext.getJobId());
	}
	
	private void processSegment(string segmentId,boolean fromError){
		List<String> fieldList = new List<String>{REN_Constants.OBJ_SE_QR_SUBMITTED,REN_Constants.OBJ_SE_QR_CREATED};
		
		List<Ren_segment__c> segmentLst = REN_SegmentDataAccess.getQuoteRequestDetails(segmentId);
		if(fromError){
			segmentLst[0].REN_QuoteRequest_Submitted__c = false;		
		} else {
			segmentLst[0].REN_QuoteRequest_Created__c = true;		
		}
		CSM_Util.checkCRUD_FLS('Ren_segment__c', fieldList, CSM_Constants.DML_OPERATION_UPDATE);
		update segmentLst;
	}
}