//US2490:Channel Portal - Enable Service Contracts to inherit sharing based on Account Access
//If the Account is shared with the partner account, partner group, partner user, then the Service Contract should also be shared with the partner account, partner group, partner user.

global with sharing class CHL_ServiceContractShareBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{
	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	String namespace=CSM_Util.nameSpacePrefix21;
	//Schedulable method
    global void execute(SchedulableContext SC) {   
    	Integer batchSize = CSM_Util.getCustomListSetting('CHL_ServiceContractShareBatch');
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        ID batchprocessid = Database.executeBatch(this,batchSize);
         
    }
	
	//Start method
	global Database.QueryLocator start(Database.BatchableContext batchContext) {
    	String jobId = batchContext.getJobId();
    	String queryStr='';
    	try{  
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CHANNEL, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CHL_Constants.OBJ_SERVICE_CONTRACT,
									jobId);
									
			if(Test.isRunningTest()){
	    		if(CHL_ServiceContractShareBatchTest.isNegative == true){
					queryStr = 'SELECT Id,';
					return Database.getQueryLocator(queryStr);	 
	    		}
			}	
        	queryStr = 'select Id,AccountId from ServiceContract where ' + namespace +'CHL_Partner_Account_1__c != null or ' + namespace +'CHL_Partner_Account_2__c != null';
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
	global void execute(Database.BatchableContext batchContext,List<SObject> serviceContractList)	{
    	
    	if(CSM_AccessController.hasObject('ServiceContractShare')){
        	try{
	    		Map<Id,SObject> scMap=new Map<Id,SObject>((List<SObject>)serviceContractList);
	        	Set<Id> scSet=scMap.keySet();
	            Map<Id,Id> ScToAccMap=new Map<Id,Id>();
	    		Set<Id> userFromAc=new set<Id>();
	        
	        	Set<Id> accIdSet=new Set<Id>();
	            string queryString = '';
	        	for(SObject serviceCon:scMap.values()){
	            	accIdSet.add((Id)serviceCon.get('AccountId'));
	            	ScToAccMap.put((Id)serviceCon.get('Id'),(Id)serviceCon.get('AccountId'));
	            }
	            //Get users whome account is shared.
	            Map<Id,user> userMap=new Map<Id,user>([SELECT Id,UserType FROM User WHERE UserType = 'PowerPartner' limit 10000]);
	            Map<Id,Group> groupMap=new Map<Id,Group>([SELECT Id FROM Group where Type='Regular' limit 10000]);
	            Set<Id> userGroupIdSet=new Set<Id>();
	            userGroupIdSet.addAll(userMap.keySet());
	            userGroupIdSet.addAll(groupMap.keySet());
	           
	            queryString='SELECT AccountId,Id,UserOrGroupId FROM  AccountShare WHERE AccountId IN :accIdSet AND UserOrGroupId IN :userGroupIdSet  limit 10000';
	            List<SObject> accShareList=Database.query(queryString);
	    	    
	    	    if(accShareList != null && !accShareList.isEmpty()) {
	                List<SObject> scShareDeleteList = new List<SObject>();
		            Map<Id,SObject> accShareMap=new Map<Id,SObject>((List<SObject>) accShareList);
		            Map<Id,Id> accToUserMap=new Map<Id,Id>();
		            for(SObject accShare:accShareList){
		           		userFromAc.add((Id)accShare.get('UserOrGroupId'));
		            }
		            
		            queryString='select Id,ParentId,UserOrGroupId from ServiceContractShare where ParentId IN:scSet limit 10000';
		            List<SObject> ScSharedList = Database.query(queryString);
		            Map<Id,SObject> scSharedMap=new Map<Id,SObject>((List<SObject>) ScSharedList);
		            
		             Map<Id,Set<Id>> sctoUserFromscshareMap=new Map<Id,Set<Id>>();
		                
		            for(SObject scshare:ScSharedList){
		            	Set<Id> userIdSet=sctoUserFromscshareMap.get((Id)scshare.get('ParentId'));
		                if(userIdSet==null){
		                	userIdSet=new Set<Id>(); 
		                }
		                userIdSet.add((Id)scshare.get('UserOrGroupId'));
		                sctoUserFromscshareMap.put((Id)scshare.get('ParentId'),userIdSet);
		            }
		            
		       		//Prepare Service Contract share list to insert.
		        	List<SObject> ScShareList=new List<SObject>();
		        	
			    	for(SObject ScIdforInsert:scMap.values())	{
			   	  		for(SObject UserIdforInsert:accShareMap.values())	{
		      				if((Id)ScIdforInsert.get('AccountId')==(Id)UserIdforInsert.get('AccountId')){
		      					Set<Id> userFromScShared=sctoUserFromscshareMap.get((Id)ScIdforInsert.get('Id'));
		      					if(!userFromScShared.contains((Id)UserIdforInsert.get('UserOrGroupId'))){
		            				SObject sObj = Schema.getGlobalDescribe().get('ServiceContractShare').newSObject();
		        					sObj.put('ParentId', ScIdforInsert.Id);
		            				sObj.put('UserOrGroupId',(Id)UserIdforInsert.get('UserOrGroupId'));
		            				sObj.put('AccessLevel','Edit');
		            				sObj.put('RowCause','Manual');
		        					ScShareList.add(sObj);
		      					}
		        	        }
		                }
			        }
	           
		           	//Prepere Service Contract Share List to delete.
		            
		           // Map<Id,SObject> scSharedMap=new Map<Id,SObject>((List<SObject>) ScSharedList);
		           
		               
		            Map<Id,set<Id>> accTouserFromAccshare=new Map<Id,set<Id>>();
		            for(SObject sccShare:accShareList){
		            	Set<Id> userFromAccShare=accTouserFromAccshare.get((Id)sccShare.get('AccountId'));
		                if(userFromAccShare==null){
		                	userFromAccShare=new Set<Id>();
		                }
		                userFromAccShare.add((Id)sccShare.get('UserOrGroupId'));
		                accTouserFromAccshare.put((Id)sccShare.get('AccountId'),userFromAccShare);   
		            }
		            if(accTouserFromAccshare != null) {    
			            Map<Id,Set<Id>> scToUserDeleteMap=new Map<Id,Set<Id>>();
			            set<Id>scUserSet = new Set<Id>();
			            for(Id scUser:sctoUserFromscshareMap.keyset()){
			                scUserSet = sctoUserFromscshareMap.get(scuser);
			                for(Id UsertoAcc:accTouserFromAccshare.get(ScToAccMap.get(scUser))){
			                 	if(scUserSet.contains(UsertoAcc)) {
			                    	scUserSet.remove(UsertoAcc);
			                        scToUserDeleteMap.put(scUser,scUserSet);
			                    }
			                 }    
			             }
			             if(scToUserDeleteMap != null) {
					         Set<Id> scShareIdToDelete=new Set<Id>();
					         for(SObject ScShare:scSharedMap.values()) {
					         	if(scToUserDeleteMap.containskey((Id)ScShare.get('ParentId'))) {
						         	for(Id sctouser:scToUserDeleteMap.Keyset()) {
						            	if((Id)ScShare.get('ParentId')==sctouser) {
						                	Set<Id> userFromSC=scToUserDeleteMap.get(sctouser);
					                    	if(userFromSC.contains((Id)ScShare.get('UserOrGroupId')))   {
					                           scShareIdToDelete.add(ScShare.Id);
					                    	}
					                    }
					                }
					         	}
				            }	                
			            	String str='Owner';
			            	queryString='select Id ,UserOrGroupId,ParentId from ServiceContractShare where Id IN:scShareIdToDelete  and RowCause!=:str limit 10000';
			            	scShareDeleteList = Database.query(queryString);
			             }
		            }       
	            	if(ScShareList!=null && !ScShareList.isEmpty()){
	                    Database.insert(ScShareList, false);
	            	}
	            	//logger.updateRecordsProcessed(batchResult, serviceContractList.size());
	                if(scShareDeleteList!=null && !scShareDeleteList.isEmpty()){
	           			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
						Schema.DescribeSObjectResult res = globalDescribe.get('ServiceContractShare').getDescribe();
						if(res.isDeletable()){
	                        Database.delete(scShareDeleteList,false);
	            		}
	            	}
	    	    }
            	logger.updateRecordsProcessed(batchResult, serviceContractList.size());      
            	
    		}  
            catch (exception ex){
				logger.setErrorFieldValues(batchResult, system.now(), true, 
					'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
            }
    
       }   
	}
	 
	//finish Method 
	global void finish(Database.BatchableContext BC) {
    	batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		logger.saveLogRecords();	
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
		
	}
    
}