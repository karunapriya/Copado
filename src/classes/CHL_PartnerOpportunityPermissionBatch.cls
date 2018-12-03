global with sharing class CHL_PartnerOpportunityPermissionBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	//public string strID= 'a0hj0000001ZTVs';
	
	//Schedulable method
    global void execute(SchedulableContext SC) {   
        //ID batchprocessid = Database.executeBatch(this,1);
        Integer batchSize = CSM_Util.getCustomListSetting('CHL_PartnerOpportunityPermissionBatch');
		batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
		Id batchprocessid = Database.executeBatch(this,batchSize);
        //System.abortJob(SC.getTriggerId()); //This is not required, jobs are running only at the time of 1st schedule. 
    }
	
	//Start method
	global Database.QueryLocator start(Database.BatchableContext batchContext) {
		String jobId = batchContext.getJobId();
		try{  
			system.debug('current User -- '+UserInfo.getName()); 
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CHANNEL, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CHL_Constants.OBJ_PARTNER_OPPORTUNITY,
									jobId);
			
        	string queryStr = 'select Id, CHL_Partner_Account_1__c, CHL_Partner_Account_2__c, CHL_Opportunity__c from CHL_Partner_Opportunity__c where CHL_Opportunity__c != null AND (CHL_Partner_Account_1__c != null or CHL_Partner_Account_2__c != null) ';	
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
	global void execute(Database.BatchableContext batchContext, List<CHL_Partner_Opportunity__c> partnerOptyList)	{
		String jobId = batchContext.getJobId();
		try {			
			if(partnerOptyList.size() > 1) {
				processMultiplePOs(partnerOptyList);
			} else {
				processSinglePO(partnerOptyList);
			}       
			logger.updateRecordsProcessed(batchResult, partnerOptyList.size());
		} catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
        
	}
	 
	//finish Method 
	global void finish(Database.BatchableContext BC) {
		if(!Test.isRunningTest()) { //Test method fails when 2 execute batch methods are called in a single transaction
			if(CHL_Util.isOWDForOpportunityPrivate())	{
				Integer batchSize = CSM_Util.getCustomListSetting('CHL_MasterOpportunityPermissionBatch');
				batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
				Database.executeBatch(new CHL_MasterOpportunityPermissionBatch(), batchSize);
			}
		}
		batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		logger.saveLogRecords();	
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
	}
	
	private void processMultiplePOs(List<CHL_Partner_Opportunity__c> partnerOptyList){
		Set<Id> partnerAccountIds = new Set<Id>();
   		Map<Id, Set<Id>> poToPartnerAccounts = new Map<Id, Set<Id>>();
   		Set<Id> poIds = new Set<Id>();	
		Map<Id, Set<Id>> poToNewUsers = new Map<Id, Set<Id>>();
		String baseNameSpace = CSM_Util.getNamespace();
   		String poShareObjStr = baseNameSpace <>''? baseNameSpace +''+CHL_Constants.OBJ_PT_Opportunity_Share:CHL_Constants.OBJ_PT_Opportunity_Share;
		String poShareReason = baseNameSpace <>''?baseNameSpace +''+CHL_CONSTANTS.STR_SHARE_REASON:CHL_CONSTANTS.STR_SHARE_REASON;
		for(CHL_Partner_Opportunity__c poObj: partnerOptyList) {
			Set<Id> paIds = poToPartnerAccounts.get(poObj.Id);
			if(paIds == null) {
				paIds = new Set<Id>();
			}			
			if(poObj.CHL_Partner_Account_1__c != null) {
				partnerAccountIds.add(poObj.CHL_Partner_Account_1__c);
				paIds.add(poObj.CHL_Partner_Account_1__c);
			}
			if(poObj.CHL_Partner_Account_2__c != null) {
				partnerAccountIds.add(poObj.CHL_Partner_Account_2__c);
				paIds.add(poObj.CHL_Partner_Account_2__c);
			}							
			poToPartnerAccounts.put(poObj.Id, paIds);
		}
				
		Map<Id, Set<Id>> partnerAccToUsersNGrp = CHL_AssetSharingBatchHelper.fetchPartnerAccountUsers(partnerAccountIds);
		Map<Id, Set<Id>> poToUsers = constructPOToUserMap(poToPartnerAccounts, partnerAccToUsersNGrp);
		
		poIds = poToPartnerAccounts.keyset();
        system.debug('\n POIds :: ' + JSON.serialize(String.valueOF(poIds)) );
        system.debug('\n partnerAccountIds :: ' + JSON.serialize(String.valueOF(partnerAccountIds)) );
        system.debug('\n poToUsers :: ' + JSON.serialize(String.valueOF(poToUsers)) );
        
        for(Id poId :poIds)	{
			Set<Id> usersForInsert = poToUsers.get(poId);
			if(usersForInsert != null) {
				for(Id userId:usersForInsert) {
					if(poToUsers.containskey(poId)) { 
						Set<Id> usersToInsert = poToNewUsers.get(poId);							
						if(usersToInsert == null){
							usersToInsert = new Set<Id>();
						}
						usersToInsert.add(userId);							
						poToNewUsers.put(poId, usersToInsert);
					}
				}
			}
		}
		if(poToNewUsers != null && CHL_Util.sObjectExists(poShareObjStr)) {
			//insertUsersInAssetShare(poToNewUsers);
			List<SObject> poShareListToInsert = new List<SObject>();	
			Schema.SObjectType poSObjType = Schema.getGlobalDescribe().get(poShareObjStr);
			for(Id poId: poToNewUsers.keyset()) {
				for(Id userIdForInsert:poToNewUsers.get(poId))	{
					sObject poShareObj = poSObjType.newSObject();
	        		poShareObj.put('UserOrGroupId' , userIdForInsert) ;                
	                poShareObj.put('RowCause', poShareReason) ; 
	                poShareObj.put('ParentId' , poId) ;
	                poShareObj.put('AccessLevel' , 'Edit') ; 
	                poShareListToInsert.add(poShareObj);
	        	}
			}
			if(poShareListToInsert != null && !poShareListToInsert.isEmpty()) {
				Database.insert(poShareListToInsert, false);
			}
		}	
		List<SObject> poShareUsersToDelete = getUnwantedUsersFromPOShare(poToNewUsers, poIds, poShareReason);
    		
        system.debug('\n AssetToNewUsers :: ' + JSON.serialize(String.valueOF(poToNewUsers)) );
		system.debug('\n poToUsersToDelete :: ' + JSON.serialize(String.valueOF(poShareUsersToDelete)) );				
		
		
		if(poShareUsersToDelete != null) {
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
			Schema.DescribeSObjectResult res = globalDescribe.get(poShareObjStr).getDescribe();
			if(res.isDeletable()) {
					delete poShareUsersToDelete;
				}
		}
	}
	
	/**
	* Description : Method to construct Map of POId with partner users/groups based on 2 maps (1. PO with partner account Map and 2. Map of Partner account with corresponding partner users/groups.)
	**/
	private static Map<Id, Set<Id>> constructPOToUserMap(Map<Id, Set<Id>>partnerOpptyToPartnerAccountMap, Map<Id, Set<Id>> partnerAccToUsersNGrp)	{
		Map<Id, Set<Id>> poToUserMap = new Map<Id, Set<Id>>();
		for(Id poId:partnerOpptyToPartnerAccountMap.keyset()) {
			if(partnerOpptyToPartnerAccountMap.get(poId) != null) {
				for(Id pAccId:partnerOpptyToPartnerAccountMap.get(poId)) {
					if(partnerAccToUsersNGrp.get(pAccId) != null) {
						for(Id userNGrpForAsset: partnerAccToUsersNGrp.get(pAccId))	{
							Set<Id> assetUsers = poToUserMap.get(poId);
							if(assetUsers == null){
								assetUsers = new Set<Id>();
							}
							assetUsers.add(userNGrpForAsset);
							poToUserMap.put(poId, assetUsers);
						}
					}
				}
			}
		}		
		return poToUserMap;
	}
	
	/**
	* Description : Method to construct Map of PO Id and users/group Id those do not require access to that PO. 
	**/
	public static List<SObject> getUnwantedUsersFromPOShare(Map<Id, Set<Id>> poShareToNewUsers, Set<Id> poIdSet, String sharingReason) {
		Map<Id, Set<Id>> poToUsersToDelete = new Map<Id, Set<Id>>();
		String queryString  = 'select ID, UserOrGroupId, ParentId from CHL_Partner_Opportunity__Share where RowCause =:sharingReason AND ParentId IN :poIdSet limit 50000';
        List<SObject> poShareList = Database.query(queryString); 
    	Map<Id, Set<Id>> poShareToUsers = fetchPOShareUsers(poShareList); 		            
		List<SObject> poShareListToDelete = new List<SObject>();
		for(Id poId :poIdSet)	{
			Set<Id> poUsers = poShareToUsers.get(poId);
			if(poUsers != null) {
				Set<Id> insertedUsers = poShareToNewUsers.get(poId);
				for(Id userToDelete:poUsers)	{					
					Set<Id> usersToDelete = poToUsersToDelete.get(poId);							
					if(usersToDelete == null){
						usersToDelete = new Set<Id>();
					}
					if(insertedUsers!= null && !insertedUsers.contains(userToDelete) && poShareToNewUsers.containskey(poId)) {  
						usersToDelete.add(userToDelete);
						poToUsersToDelete.put(poId,usersToDelete);
					} else if(!poShareToNewUsers.containskey(poId)) {
						usersToDelete.add(userToDelete);
						poToUsersToDelete.put(poId,usersToDelete);
					}					
				}
			}
		}
		for(SObject sObj:poShareList)	{
			Set<Id> usersToDelete = poToUsersToDelete.get((Id)sobj.get('ParentId'));
			if(poToUsersToDelete.containsKey((Id)sobj.get('ParentId')) && usersToDelete.contains((Id)sobj.get('UserOrGroupId')))	{
				poShareListToDelete.add(sObj);
			}
		}
		return poShareListToDelete;
	}
	
	private static Map<Id, Set<Id>> fetchPOShareUsers(List<sObject> poShareList)	{
		Map<Id, Set<Id>> poShareUserMap = new Map<Id, Set<Id>>();
		for(sObject poshare: poShareList) {						
			Set<Id> poUsers = poShareUserMap.get((Id)poshare.get('ParentId'));							
			if(poUsers == null){
				poUsers = new Set<Id>();
			}
			poUsers.add((Id)poshare.get('UserOrGroupId'));
			poShareUserMap.put((Id)poshare.get('ParentId'), poUsers);						
		}
		return poShareUserMap;
	}

	private void processSinglePO(List<CHL_Partner_Opportunity__c> partnerOptyList){
		set<ID> accountUserIDs = new Set<Id>();    
		Set<ID> shareUserIDs = new Set<Id>(); 			
		Set<Id> userIdsToDelete = new Set<Id>();
		List<SObject> opptyShareListToInsert = new List<SObject>();
       	List<SObject> partnerOptyShareListToInsert = new List<SObject>();			
		String nameSpace = CSM_Util.getNamespace();
   		String partnerObjStr = nameSpace <>''?nameSpace +''+CHL_Constants.OBJ_PT_Opportunity_Share:CHL_Constants.OBJ_PT_Opportunity_Share;
   		Id partnerAccount1ID = partnerOptyList[0].CHL_Partner_Account_1__c != null ? partnerOptyList[0].CHL_Partner_Account_1__c:null;
		Id partnerAccount2ID = partnerOptyList[0].CHL_Partner_Account_2__c != null ? partnerOptyList[0].CHL_Partner_Account_2__c:null;
		Id partnerOptyId = partnerOptyList[0].Id;
		Id OptyId = partnerOptyList[0].CHL_Opportunity__c;
		string rowCause = 'Manual';
		string queryString = '';
		Set<Id> partnerAccIds = CHL_Util.getAccAndParentAccIDs(partnerAccount1ID, partnerAccount2ID);
		string sharingReason = nameSpace <>''?nameSpace +''+CHL_CONSTANTS.STR_SHARE_REASON:CHL_CONSTANTS.STR_SHARE_REASON;//Schema.CHL_Partner_Opportunity__Share.rowCause.CHL_Manual_Share__c;
		             
        for(User u:[Select id from User where Contact.AccountId in:partnerAccIds AND isActive=true]) {
        	accountUserIDs.add(u.id);
        }   
        
        
        for (CHL_Portal_Group__c portalGrp :[SELECT Id, CHL_Public_Group__c FROM CHL_Portal_Group__c WHERE 
        										Id in (SELECT CHL_Portal_Group__c FROM CHL_Portal_Group_Member__c WHERE 
        												CHL_Partner_Account__c IN :partnerAccIds) AND 
        												CHL_Public_Group__c != null]){
        	accountUserIDs.add(portalGrp.CHL_Public_Group__c);
        }
        
        if(CHL_Util.sObjectExists(partnerObjStr)){ 
        	queryString = 'select ID, '+CHL_CONSTANTS.STR_USERGROUPID+', '+CHL_CONSTANTS.STR_PARENT+ ' from '+CHL_Constants.OBJ_PT_Opportunity_Share+ ' where RowCause =:sharingReason AND '+CHL_CONSTANTS.STR_PARENT+ ' =:partnerOptyId limit 1000';
        	List<SObject> partnerOpptyShare = Database.query(queryString); 
        	for(sObject poshare: partnerOpptyShare) {
            	shareUserIDs.add((ID)poshare.get(CHL_CONSTANTS.STR_USERGROUPID));
            }
        }
        
        system.debug('---PARTNER OPTY DETAILS : '+OptyId+'::'+accountUserIDs+'::'+shareUserIDs);
        if(accountUserIDs != null && accountUserIDs.size() > 0 && CHL_Util.sObjectExists(partnerObjStr)) {
        	Schema.SObjectType poSObjType = Schema.getGlobalDescribe().get(partnerObjStr);
            for(Id userToInsert:accountUserIDs)	{
            	if(shareUserIDs.size() == 0 || !shareUserIDs.contains(userToInsert)) {
            		//if(CHL_Util.sObjectExists(partnerObjStr))	{ 
	            		sObject poSObj = poSObjType.newSObject();
	            		poSObj.put(CHL_CONSTANTS.STR_USERGROUPID , userToInsert) ;                
	                    poSObj.put(CHL_CONSTANTS.STR_ROWCAUSE , sharingReason) ; 
	                    poSObj.put(CHL_CONSTANTS.STR_PARENT , partnerOptyId) ;
	                    poSObj.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
	                    partnerOptyShareListToInsert.add(poSObj);
            		//}
            	}
            }
        }
        if(shareUserIDs != null && shareUserIDs.size() > 0) {
            for(Id userToDelete:shareUserIDs)	{
            	if(accountUserIDs.size() == 0 || !accountUserIDs.contains(userToDelete)) {
            		userIdsToDelete.add(userToDelete);
            	}
            }       
        }     
		System.debug('Need to insert Share record for : '+partnerOptyShareListToInsert);
		System.debug('Need to delete Share record for : '+userIdsToDelete);
		if(partnerOptyShareListToInsert != null && !partnerOptyShareListToInsert.isEmpty()) {
        	insert partnerOptyShareListToInsert;
        }
        if(CHL_Util.sObjectExists(partnerObjStr)){ 
        	queryString  = 'select ID, '+CHL_CONSTANTS.STR_USERGROUPID+', '+CHL_CONSTANTS.STR_PARENT+ ' from '+CHL_Constants.OBJ_PT_Opportunity_Share+ ' where RowCause =:sharingReason AND '+CHL_CONSTANTS.STR_PARENT+ ' =:partnerOptyId AND '+CHL_CONSTANTS.STR_USERGROUPID+' IN :userIdsToDelete limit 1000';
        	List<SObject> partnerOpportunityShareList = Database.query(queryString);   
            if(partnerOpportunityShareList != null && !partnerOpportunityShareList.isEmpty())	{
				//if(CSM_AccessController.hasObject(CHL_Constants.OBJ_PT_Opportunity_Share)) {
				//string sObjectName = CHL_Constants.OBJ_PT_Opportunity_Share;
 
				Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
				Schema.DescribeSObjectResult res = globalDescribe.get(partnerObjStr).getDescribe();
				if(res.isDeletable()){
					delete partnerOpportunityShareList;
				}
				//}
			}	 
		} 
	}
	
}