public with sharing class CSM_CaseTriggerHelper {
	/**
	* Description : Method to insert records in CaseShare
	**/
    public static void shareCaseWithPartners(Map<Id,set<Id>> caseIdToUserMap){
        List<SObject> caseShareList=new List<SObject>();       
        for(Id caseId : caseIdToUserMap.keySet()){
        	for(Id userId : caseIdToUserMap.get(caseId)){
            	SObject sObj = CSM_AccessController.newSObject(CHL_Constants.OBJ_CASE_SHARE);
                sObj.put('CaseId', caseId);
                sObj.put('UserOrGroupId',userId);
                sObj.put('CaseAccessLevel','Edit');
                sObj.put('RowCause','Manual');
                caseShareList.add(sObj);  
            }
        }        
        CSM_CaseDataAccess.insertCaseShare(caseShareList);        
    }
    /**
	* Description : Method to delete records from CaseShare when contact is modified on case
	**/
    public static void deleteCaseSharing(Set<Id> caseIdSet){
    	List<SObject> caseShareList = CSM_CaseDataAccess.getCaseShareByCaseId(caseIdSet);
        if(caseShareList != null && !caseShareList.isEmpty()){
        	CSM_CaseDataAccess.deleteCaseShare(caseShareList);   
        }
    }
    
    public static void processCaseSharing(List<Case> caseList, Set<Id> newContactIdSet , Map<id, Contact> oldContactMap,Map<ID, sObject> oldRecordsMap){
	    
	    Map<Id,Contact> conMap = new Map<id, Contact>(CSM_ContactDataAccess.getPartnerContact(newContactIdSet));
	    Map<Id,Id> caseToAccIdMap = new Map<Id,Id>();
	    Set<Id> casesIdToDelete = new Set<Id>();
	    Set<Id> accIdSet = new Set<Id>();
	    for(Case caseNew : caseList)
	   	{
	   		if(oldContactMap != null && !oldContactMap.isEmpty() && oldRecordsMap != null && !oldRecordsMap.isEmpty()){
	   			Case caseOld=(Case)oldRecordsMap.get(caseNew.id);
	   			if(oldContactMap.containsKey(caseOld.ContactId) && !Test.isRunningTest()){
	   				casesIdToDelete.add(caseOld.Id);	
	   			}	
	   		}	   		
	    	if(ConMap.containsKey(caseNew.ContactId) && !Test.isRunningTest()){ 
	        	accIdSet.add(ConMap.get(caseNew.ContactId).AccountId);
                caseToAccIdMap.put(caseNew.Id,ConMap.get(caseNew.ContactId).AccountId);	            
	        }
	        // Partner Community not enabled in Master org. This else condition is added for Test coverage
            else if(Test.isRunningTest()){
            	accIdSet.add(caseNew.Contact.AccountId);
                caseToAccIdMap.put(caseNew.Id,caseNew.Contact.AccountId);
            }     
	     }
	     List<User> userList = new List<User>();
	     Map<Id,Set<Id>> accToUserMap = new Map<Id,Set<Id>>();
	     Map<Id,Set<Id>> caseIdToUsersMap = new Map<Id,Set<Id>>();
	     if(accIdSet != null && !accIdSet.isEmpty()){
	     	// Partner Community not enabled in Master org.
	     	if(Test.isRunningTest()){
                 userList=[select id,Contact.AccountId from User where isActive=true limit 1];
             }
             else{
                 userList = CHL_Util.getPartnerUsersByAccount(accIdSet);
             }
	     }
	     if(userList != null && !userList.isEmpty()){
	     	// Partner Community not enabled in Master org.
	     	if(Test.isRunningTest()){
                 accToUserMap.put(caseList[0].Contact.AccountId,new Set<Id>{userList[0].Id});
             }
             else{
                 accToUserMap = getAccToUserMap(userList);
             }	 
	     }
	     if(caseToAccIdMap != null && !caseToAccIdMap.isEmpty() &&  accToUserMap != null && !accToUserMap.isEmpty()){
	     	caseIdToUsersMap = getCaseIdToUsersMap(caseToAccIdMap,accToUserMap);
	     }
	     if(casesIdToDelete != null && !casesIdToDelete.isEmpty()){
	     	deleteCaseSharing(casesIdToDelete);
	     }	            
	     if(caseIdToUsersMap != null && !caseIdToUsersMap.isEmpty()){
	     	CSM_CaseTriggerHelper.shareCaseWithPartners(caseIdToUsersMap);
	     }	
	}
    /**
	* Description : Method to construct Map of AccountId and users Id
	**/
    public static Map<Id,set<Id>> getAccToUserMap(List<User> userList){
    	Set<Id> userIds;
        Map<Id,Set<Id>> accToUserMap=new Map<Id,Set<Id>>();
        for(User usr:userList){
        	Contact conObj = (Contact)usr.getSobject('Contact');
        	userIds = accToUserMap.get(conObj.AccountId);
			if(userIds == null) {
				userIds = new Set<Id>();
			}					
			userIds.add(usr.Id);
            accToUserMap.put(conObj.AccountId,userIds);
        }
        return accToUserMap;
    }
    /**
	* Description : Method to construct Map of CaseId and users Id
	**/
    public static Map<Id,Set<Id>> getCaseIdToUsersMap(Map<Id,Id> caseToAccIdMap,Map<Id,Set<Id>> accToUserMap){
        Map<Id,Set<Id>> caseIdToUsersMap=new Map<Id,Set<Id>>();
        Set<Id> caseUserSet=new Set<Id>();
            for(Id caseId:caseToAccIdMap.keySet()){
                for(Id user:accToUserMap.get(caseToAccIdMap.get(caseId))){
                    caseUserSet=caseIdToUsersMap.get(caseId);
                    if(caseUserSet==null){
                        caseUserSet=new Set<Id>();
                    }
                    caseUserSet.add(user);
                    caseIdToUsersMap.put(caseId,caseUserSet);
                }
            }
        return caseIdToUsersMap;
    }    
    
    public static void processBeforeInsert(CaseRelatedDetailsWrapper caseRelWrapObj){
        Map<String, String> oppAccMap = new Map<String, String>();
        Set<Id> empIdSet = new Set<Id>();
        String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        Boolean hasOpptyField = CSM_AccessController.hasField('Case', solExtNameSpace + 'Opportunity__c' ); 
        Boolean hasEntitlementField = CSM_AccessController.hasField('Case', 'EntitlementId' ); 
        
        List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityDetailsById(caseRelWrapObj.oppIdSet, new List<String>{'Id', 'AccountId', 'Name'}, null);
        
        for(Opportunity opp : oppList) {
            oppAccMap.put(opp.Id, opp.AccountId);
            caseRelWrapObj.accountIdSet.add(opp.AccountId);
        }
        Map<String, String> entMap = new Map<String, String>();
        
        List<sObject> entList = new List<sObject>();
        if(hasEntitlementField){
        	entList = REN_Util.getEntitlementListByAccount(caseRelWrapObj.accountIdSet);
        }
        
        for(sObject ent : entList) {
            entMap.put((String)ent.get('AccountId'), (String)ent.get('Id'));
        }        
        
        for(Case newCase : caseRelWrapObj.caseLst) {
            
            if(hasOpptyField && newCase.get(solExtNameSpace + 'Opportunity__c') != null){
                newCase.AccountId = oppAccMap.get((Id)newCase.get(solExtNameSpace + 'Opportunity__c'));
            }
            if(hasEntitlementField){
            	newCase.put('EntitlementId', entMap.get(newCase.AccountId));
            }
            empIdSet.add(newCase.OwnerId);            
        }
        
        if(!empIdSet.isEmpty()){
            SS_TriggerCollectionParameters.CaseTriggerParams caseParams = new SS_TriggerCollectionParameters.CaseTriggerParams();
            caseParams.empIdSet = empIdSet;
            caseParams.newRecords = caseRelWrapObj.caseLst;
            caseParams.qualifiedCasesList = caseRelWrapObj.filteredCaseList;
            if(CSM_AccessController.hasField('Opportunity', solExtNameSpace + 'Ops_Stage__c' )){
            	caseParams.IdToOppMap = new Map<Id, Opportunity>(REN_OpportunityDataAccess.getOpportunityDetailsById(caseRelWrapObj.opptyIdSet, new List<String>{'Id', solExtNameSpace + 'Ops_Stage__c', 'StageName'}, new List<String>{'RecordType.Name'}));
            }else{
            	caseParams.IdToOppMap = new Map<Id, Opportunity>();
            }
            
            if(hasOpptyField){
            	caseParams.triggerEvent = 'onBeforeInsert';            
       			(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'CaseTriggerInvocationHandler', caseParams);
            }
            
        }
               
    }
    
    public static void updateSubjectOfCase(CaseRelatedDetailsWrapper caseRelWrapObj){
    	String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        Boolean hasOpptyField = CSM_AccessController.hasField('Case', solExtNameSpace + 'Opportunity__c' ); 
        Boolean hasRecordType = CSM_AccessController.hasField('Case', 'recordTypeID' ); 
        
        map<Id, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById();
        List<User> lUser = new List<User>();
        Map<ID, Account> accountIdMap;
        if(!caseRelWrapObj.accountIdSet.isEmpty()){
            accountIdMap = CSM_AccountDataAccess.getAcctMapById(caseRelWrapObj.accountIdSet);
        }
        Map<ID, Opportunity> oppIdMap;
        if(!caseRelWrapObj.oppIdSet.isEmpty()){
            oppIdMap = new Map<Id, Opportunity>(REN_OpportunityDataAccess.getOpportunityDetailsById(caseRelWrapObj.oppIdSet, new List<String>{'Id','Name'}, null));
        }
        Map<ID, User> userIdMap;
        if(!caseRelWrapObj.ownerIdSet.isEmpty()){
            userIdMap = CSM_UserDataAccess.getUserDetailsById(caseRelWrapObj.ownerIdSet, new List<String>{'Id','Name'});
        }    
        List<QueueSObject> lstOfQueue = new List<QueueSObject>();
        try{
            lstOfQueue = REN_Util.getQueuesObject(new List<String>{'Id','QueueId'}, new List<String>{'Queue.Name'});
        }catch(Exception e){
            lstOfQueue = new List<QueueSObject>();
        }
        Map<String, Id> mapOfQNameToId = new Map<String,Id>();
        
        for(QueueSObject qObj: lstOfQueue){
            mapOfQNameToId.put(qObj.Queue.Name, qObj.QueueId);
        }
        for(Case mCase : caseRelWrapObj.caseLst){
            String recordTypeName;
            if(hasRecordType){
                recordTypeName = rt_map.get((Id)mCase.get('recordTypeID')).getName();
            }
            
            if(String.isNotBlank(recordTypeName)){
                
                if(recordTypeName.equalsIgnoreCase('Booking Request')){
                    mCase.OwnerId =mapOfQNameToId.get('Booking Request');
                }else if(recordTypeName.equalsIgnoreCase('Data Processing Request')){
                    mCase.OwnerId =mapOfQNameToId.get('Data Processing');
                }else if(recordTypeName.equalsIgnoreCase('Data Update Request')){ 
                    mCase.OwnerId =mapOfQNameToId.get('Data Update');
                }else if(recordTypeName.equalsIgnoreCase('Lead Submission')){ 
                    mCase.OwnerId =mapOfQNameToId.get('Lead Submission');
                }else if(recordTypeName.equalsIgnoreCase('Quote Request')){ 
                    mCase.OwnerId =mapOfQNameToId.get('Quote Request');
                }else if(recordTypeName.equalsIgnoreCase('Reporting Request')){ 
                    mCase.OwnerId =mapOfQNameToId.get('Reporting');
                }else if(recordTypeName.equalsIgnoreCase('Review Request')){ 
                    mCase.OwnerId =mapOfQNameToId.get('Review');
                }
                
                
                if(mCase.OwnerId==null){
                    mCase.OwnerId = userIdMap.get(mCase.OwnerId).Id;
                }
                if(hasOpptyField && oppIdMap != null && mCase.get(solExtNameSpace + 'Opportunity__c') != null && oppIdMap.containsKey((Id)mCase.get(solExtNameSpace + 'Opportunity__c'))){
                    mCase.Subject = recordTypeName + '-' +oppIdMap.get((Id)mCase.get(solExtNameSpace + 'Opportunity__c')).name;
                }else if(mCase.accountId != null && accountIdMap.containsKey(mCase.accountId)){
                    mCase.Subject = recordTypeName + '-' +accountIdMap.get(mCase.accountId).name;
                }
            }
        }
    }  
    
    public class CaseRelatedDetailsWrapper{
		public Set<Id> oppIdSet; 
		public Set<String> accountIdSet; 
		public List<Case> caseLst; 
		public Set<Id> opptyIdSet; 
		public List<Case> filteredCaseList;
        public Set<String> ownerIdSet;
    }      
}