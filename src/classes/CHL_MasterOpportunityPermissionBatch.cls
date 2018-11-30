global with sharing class CHL_MasterOpportunityPermissionBatch implements Database.Batchable<SObject>, Database.Stateful {
	
	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	public string optyRowCause = 'Manual';			
	//public set<Id> idset = new set<Id>();
	//public string strID= 'a0lo0000002qzfo';	
	
	//Schedulable method below method is not required for this class as this batch gets called from CHL_PartnerOpportunityPermissionBatch, finish method
    /*global void execute(SchedulableContext SC) {   
        ID batchprocessid = Database.executeBatch(this);
    }*/
	
	//Start method
	global Database.QueryLocator start(Database.BatchableContext batchContext) {
		String jobId = batchContext.getJobId();
		try{   
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CHANNEL, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									'CHL_Partner_Opportunity__c', 
									jobId);
			//idset.add('a0lo0000002rKum');
			//idset.add('a0lo0000002rKtj');
			string queryStr = 'select Id,CHL_Opportunity__c from CHL_Partner_Opportunity__c where CHL_Opportunity__c != null' ;//where Id in :idset'; 	
			if(Test.isRunningTest() && CHL_MasterOpptyPermissionBatchTest.isNegative) {
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
	global void execute(Database.BatchableContext batchContext,List<CHL_Partner_Opportunity__c> partnerOptyList)	{	
		Set<ID> partnerOptyIds = new Set<Id>(); 	
		Map<Id, Set<ID>> masterOptyToPartnerOpty = new Map<Id, Set<ID>>();		
		Map<ID, Set<Id>> optyToNewUsers = new Map<ID, Set<Id>>();
		Set<Id> masterOptyIds = new Set<Id>();
		String jobId = batchContext.getJobId();
		try {
			String nameSpace = CSM_Util.getNamespace();
			String partnerObjStr = nameSpace <>''?nameSpace +'CHL_Partner_Opportunity__Share':'CHL_Partner_Opportunity__Share';
	 		string partnerOptyRowCause = nameSpace <>''?nameSpace +'CHL_Manual_Share_Reason__c':'CHL_Manual_Share_Reason__c';   
			if(CHL_Util.isOWDForOpportunityPrivate() && CHL_Util.sObjectExists(partnerObjStr))	{	
				for(CHL_Partner_Opportunity__c chl:partnerOptyList)	{				
					partnerOptyIds.add(chl.id);
					set<Id> pOptyIds = masterOptyToPartnerOpty.get(chl.CHL_Opportunity__c);
					if(pOptyIds == null) {
						pOptyIds = new set<Id>();
					}
					pOptyIds.add(chl.id);
					if(chl.CHL_Opportunity__c != null) {
						masterOptyToPartnerOpty.put(chl.CHL_Opportunity__c,pOptyIds);
					}
				}
				if(masterOptyToPartnerOpty != null ) {	//&& masterOptyToPartnerOpty.containskey('006o000000G6AKy')						
					string queryString = '';
					masterOptyIds = masterOptyToPartnerOpty.keyset();
					
					queryString = 'select ID, UserorGroupId,ParentId from CHL_Partner_Opportunity__Share where RowCause =:partnerOptyRowCause AND ParentId IN :partnerOptyIds limit 10000';
					List<SObject> partnerOpptyShare = Database.query(queryString); 					
					
					Map<ID,Set<Id>> partnerOptyToUsers = fetchPartnerOptyUsers(partnerOpptyShare);	
					Map<ID,Set<Id>> masterOptyToUsers = setMasterOptyToUserMap(masterOptyToPartnerOpty,partnerOptyToUsers);
					
					system.debug('\n masterOptyToUsers :: ' + JSON.serialize(String.valueOF(masterOptyToUsers)) );
					for(ID mOId :masterOptyIds)	{
						set<Id> usersForInsert = masterOptyToUsers.get(mOId);
						if(usersForInsert != null) {
							for(Id userToInsert:usersForInsert) {
								if(masterOptyToUsers.containskey(mOId)) { //(masterOptyUsers == null || (masterOptyUsers != null && !masterOptyUsers.contains(userToInsert))) &&
									Set<Id> usersToInsert = optyToNewUsers.get(mOId);							
									if(usersToInsert == null){
										usersToInsert = new Set<Id>();
									}
									usersToInsert.add(userToInsert);							
									optyToNewUsers.put(mOId,usersToInsert);
								}
							}
						}
					}		
					if(optyToNewUsers != null) {
						insertUsersForMasterOpty(optyToNewUsers);
					}
					Map<ID, Set<Id>> optyToUsersToDelete = getUnwantedUsersFromMasterOpty(masterOptyToUsers, masterOptyIds);
					
					system.debug('\n optyToNewUsers :: ' + JSON.serialize(String.valueOF(optyToNewUsers)) );
					system.debug('\n optyToUsersToDelete :: ' + JSON.serialize(String.valueOF(optyToUsersToDelete)) );				
					
					
					if(optyToUsersToDelete != null) {
						deleteUsersFromMasterOpty(optyToUsersToDelete);
					}
				}				
				logger.updateRecordsProcessed(batchResult, partnerOptyList.size());
			}
		} catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }		
        
	}
	 
	//finish Method 
	global void finish(Database.BatchableContext BC)
	{
		batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		logger.saveLogRecords();
	
	}
	
	private map<Id,Set<ID>> fetchPartnerOptyUsers(List<sObject> partnerOpptyShare)	{
		Map<ID,Set<Id>> partnerOptyUserMap = new Map<ID,Set<Id>>();
		for(sObject poshare: partnerOpptyShare) {						
			Set<Id> pOptyUsers = partnerOptyUserMap.get((ID)poshare.get('ParentId'));							
			if(pOptyUsers == null){
				pOptyUsers = new Set<Id>();
			}
			pOptyUsers.add((ID)poshare.get('UserorGroupId'));
			partnerOptyUserMap.put((ID)poshare.get('ParentId'), pOptyUsers);						
		}
		return partnerOptyUserMap;
	}	
	private Map<Id, Set<ID>> fetchMasterOptyUsers(List<sObject> masterOptyShareList)	{
		Map<ID,Set<Id>> masterOptyUserMap = new Map<ID,Set<Id>>();
		for(sObject sobj: masterOptyShareList) {
			Set<Id> userIdSet = masterOptyUserMap.get((ID)sobj.get('OpportunityId'));							
			if(userIdSet == null){
				userIdSet = new Set<Id>();
			}
			userIdSet.add((ID)sobj.get('UserorGroupId'));
			masterOptyUserMap.put((ID)sobj.get('OpportunityId'), userIdSet);
		}
		return masterOptyUserMap;
	}
	private Map<Id, Set<Id>> setMasterOptyToUserMap(map<Id, Set<Id>>masterOptyToPartnerOptys,map<Id, Set<Id>>partnerOptyToUsers)	{
		Map<Id,set<Id>> masterOptyToUserMap = new Map<Id,set<Id>>();
		for(Id masterOppId:masterOptyToPartnerOptys.keyset()) {
			if(masterOptyToPartnerOptys.get(masterOppId) != null) {
				for(Id pOId:masterOptyToPartnerOptys.get(masterOppId)) {
					//system.debug('partnerOptyToUsers.get(pOId : '+partnerOptyToUsers.get(pOId));
					if(partnerOptyToUsers.get(pOId) != null) {
						for(Id userIdForMO: partnerOptyToUsers.get(pOId))	{
							set<Id> pOUsers = masterOptyToUserMap.get(masterOppId);
							if(pOUsers == null){
								pOUsers = new Set<Id>();
							}
							pOUsers.add(userIdForMO);
							masterOptyToUserMap.put(masterOppId,pOUsers);
						}
					}
				}
			}
		}		
		return masterOptyToUserMap;
	}
	private void insertUsersForMasterOpty (Map<ID, Set<Id>> masterOptyUsersToInsert )	{
		List<SObject> opptyShareListToInsert = new List<SObject>();	
		Schema.SObjectType opptyShareSObjType = Schema.getGlobalDescribe().get('OpportunityShare');
		for(Id optyIdForInsert: masterOptyUsersToInsert.keyset()) {
			for(Id userIdForInsert:masterOptyUsersToInsert.get(optyIdForInsert))	{
				SObject sObj = opptyShareSObjType.newSObject();
				sObj.put('UserorGroupId' , userIdForInsert) ;                
				sObj.put('RowCause' , 'Manual') ; 
				sObj.put('OpportunityId' , optyIdForInsert) ;
				sObj.put('OpportunityAccessLevel' , 'Edit');
				opptyShareListToInsert.add(sObj);
			}
		}
		if(opptyShareListToInsert != null && !opptyShareListToInsert.isEmpty()) {
			insert opptyShareListToInsert;
		}
	}
	private Map<Id, Set<Id>> getUnwantedUsersFromMasterOpty(Map<Id, Set<Id>> masterOptyToNewUsers, Set<Id> masterOptyIds) {
		string optyShareQuery = 'select ID, UserorGroupId, OpportunityId from OpportunityShare where RowCause =:optyRowCause AND OpportunityId IN :masterOptyIds limit 10000';
		List<SObject> opportunityShareList = Database.query(optyShareQuery);  								
		Map<ID, Set<Id>> optyToShareUsers = fetchMasterOptyUsers(opportunityShareList); 
		Map<ID, Set<Id>> optyToUsersToDelete = new Map<ID, Set<Id>>();	
		for(ID mOId :masterOptyIds)	{
			set<Id> masterOptyUsers = optyToShareUsers.get(mOId);
			if(masterOptyUsers != null) {
				set<Id> insertedUsers = masterOptyToNewUsers.get(mOId);
				for(Id userToDelete:masterOptyUsers)	{					
					Set<Id> usersToDelete = optyToUsersToDelete.get(mOId);							
					if(usersToDelete == null){
						usersToDelete = new Set<Id>();
					}
					if(insertedUsers!= null && !insertedUsers.contains(userToDelete) && masterOptyToNewUsers.containskey(mOId)) { //&& (usersForInsert != null && !usersForInsert.contains(userToDelete)) 
						usersToDelete.add(userToDelete);
						optyToUsersToDelete.put(mOId,usersToDelete);
					} else if(!masterOptyToNewUsers.containskey(mOId)) {
						usersToDelete.add(userToDelete);
						optyToUsersToDelete.put(mOId,usersToDelete);
					}					
				}
			}
		}
		return optyToUsersToDelete;
	}
	private void deleteUsersFromMasterOpty (Map<ID,Set<Id>> masterOptyUsersToDelete )	{
		Set<ID>optyIdsToDelete = masterOptyUsersToDelete.KeySet();
		string userTypeStr =  'PowerPartner';
		string queryStr = 'select ID, UserorGroupId, OpportunityId from OpportunityShare where where RowCause =:optyRowCause AND OpportunityId IN :optyIdsToDelete AND UserorGroupId in ( select ID from user where usertype =: userTypeStr ) limit 1000';
		List<SObject> masterOptyListofUsers = Database.query(queryStr);  		            
		List<SObject> optyShareListToDelete = new List<SObject>();
		if(masterOptyListofUsers != null && !masterOptyListofUsers.isEmpty())	{
			for(SObject sObj:masterOptyListofUsers)	{
				set<Id> usersToDelete = masterOptyUsersToDelete.get((ID)sobj.get('OpportunityId'));
				if(masterOptyUsersToDelete.containsKey((ID)sobj.get('OpportunityId')) && usersToDelete.contains((ID)sobj.get('UserorGroupId')))	{
					optyShareListToDelete.add(sObj);
				}
			}
		}
		if(optyShareListToDelete != null && !optyShareListToDelete.isEmpty())	{
			if(CSM_AccessController.hasObject('OpportunityShare')) {
				//string sObjectName = CHL_Constants.OBJ_OPPORTUNITYSHARE;

				Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
				Schema.DescribeSObjectResult res = globalDescribe.get('OpportunityShare').getDescribe();
				if(res.isDeletable()&& CHL_Util.isOWDForOpportunityPrivate()){
					delete optyShareListToDelete;
				}
			}
		}
	}
}