public with sharing class CSM_CaseDataAccess {

	public static List<Case> getCasesByAccount(set<Id> accountIds)	{
		List<String> caseFieldList = new List<String>{CSM_Constants.OBJ_CASE_ID,CSM_Constants.OBJ_CASE_ACC_ID, CSM_Constants.OBJ_CASE_DiffOf_Creation_Closed_Date,CSM_Constants.OBJ_CASE_PRIORITY,CSM_Constants.OBJ_CASE_STATUS};
        List<String> noAccessCaseFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_CASE, 
            CSM_Constants.DML_OPERATION_READ, caseFieldList);
        if (noAccessCaseFieldList.isEmpty())
        {      
        	if (accountIds.IsEmpty()){
        		return new List<Case>();
        	} else {
        		//Set<String> status = new Set<String>{CSM_Constants.OBJ_CASE_STATUS_CLOSED, CSM_Constants.OBJ_CASE_STATUS_NEW, CSM_Constants.OBJ_CASE_STATUS_WORKING};
        		//Comented below variables as part of DE1587
        		//Date firstDayOfMonth = Date.newInstance(date.today().year(), date.today().month(), 1);
				//Date lastDayOfMonth = date.today().addMonths(1).toStartofMonth().addDays(-1);

				return [select  Id, AccountId, CSM_DiffOf_Creation_Closed_Dates__c,priority,status,CreatedDate,lastmodifieddate 
	                   from Case 
    	              where IsDeleted = false AND 
    	              		AccountId IN :accountIds AND 
    	              		//Status IN :status AND
    	              		lastmodifieddate <= THIS_MONTH limit 10000]; //firstDayOfMonth AND lastModifiedDate <=:lastDayOfMonth
        	}
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_CASE + ':'+String.valueOf(noAccessCaseFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
	}
	public static List<Case> getOldestCaseforAccount(set<Id> accountIds)	{
		List<String> caseFieldList = new List<String>{CSM_Constants.OBJ_CASE_ID,CSM_Constants.OBJ_CASE_ACC_ID,CSM_Constants.OBJ_CASE_CASENUMBER, CSM_Constants.OBJ_CASE_DiffOf_Creation_Closed_Date,CSM_Constants.OBJ_CASE_PRIORITY,CSM_Constants.OBJ_CASE_STATUS};
        List<String> noAccessCaseFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_CASE, 
            CSM_Constants.DML_OPERATION_READ, caseFieldList);
        if (noAccessCaseFieldList.isEmpty())
        {   
        	if (accountIds.IsEmpty()){
        		return new List<Case>();
        	} else {   
        		Date firstDate = date.today().AddMonths(-2);
				Date lastDate = date.today();
        		
        		return [SELECT Id, AccountId, CaseNumber FROM Case 
        			WHERE IsDeleted = false AND AccountId IN :accountIds AND status != 'Closed' AND
					lastmodifieddate >= :firstDate AND 
    	            lastModifiedDate <=:lastDate
					limit 10000];
        		
        		/*
        		List<AggregateResult> cl = [select Min(CaseNumber) CaseNumber, Min(Id) Id from Case
					GROUP BY AccountId, Status, IsDeleted 
					HAVING IsDeleted = false AND AccountId IN :accountIds AND status != 'Closed' 
					ORDER BY CaseNumber DESC 
					limit 10000];
					
				if (cl.isEmpty()){
					return new List<Case>();
				} else {
					Set<Id> ids = new Set<Id>();
					for (AggregateResult ar : cl){
						ids.add((Id)ar.get('Id'));
					}
					if (ids.isEmpty()){
						return new List<Case>();
					} else {
						return [SELECT Id, AccountId, CaseNumber FROM Case WHERE Id IN :ids LIMIT 10000];
					}
				}
				*/
        	}
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_CASE + ':'+String.valueOf(noAccessCaseFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        } 
	}
	
	public static List<Case> insertCases(List<Case> caseLst){
        //{'Subject','AccountID','Description','Priority'};
        List<String> caseFieldList = new List<String>{CHL_Constants.CASE_SUBJECT, 
                                                    CHL_Constants.CASE_ACCOUNTID,
                                                    CHL_Constants.CASE_DESCRIPTION,
                                                    CHL_Constants.CASE_PRIORITY
                                                    };    
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_INSERT);                                                 
            insert caseLst;   
           
        return caseLst;
    }
    public static List<Case> getCasesByFilterCondition(String filterCondition, string accountId)	{
    	String userId =  UserInfo.getUserId();
    	//Id userAccountId = CHL_Util.currentUserDetails[0].Contact.AccountId;//CHL_Util.fetchAccountIdOfUser(userID);
    	List<String> caseFieldList = new List<String>{CHL_Constants.CASE_NUMBER,
													  CHL_Constants.CASE_ACCOUNTID,
													  CHL_Constants.CASE_STATUS,
													  CHL_Constants.CASE_CREATED_DATE,
													  CHL_Constants.CASE_CLOSED_DATE,
													  CHL_Constants.CASE_DESCRIPTION,
													  CHL_Constants.CASE_SUBTYPE,
													  CHL_Constants.CASE_SUBJECT,
													  CHL_Constants.CASE_RELATED_TO_TXT};
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_READ);
    	String queryCondition;
		String queryString = 'Select Id, AccountId, Account.name, CaseNumber, CHL_CaseSubtype__c, Type, Status, CreatedDate, ' + 
								'ClosedDate, CreatedById, CreatedBy.name, Description, Subject, CHL_Related_To_Text__c FROM Case ';
        if(filterCondition.containsIgnoreCase('Open')){
            queryCondition = 'Where isClosed = false  AND CreatedById =: userID Limit 1000';
        }else if(filterCondition.containsIgnoreCase('Closed')){
            queryCondition = 'Where isClosed = true AND CreatedById =: userID Limit 1000';
        } else if(filterCondition.containsIgnoreCase('ALL')){
        	queryCondition = 'Limit 1000';
        } else{
        	if(accountId != null && !string.isBlank(accountId)){
        		queryCondition = 'Where AccountId =: accountId Limit 1000';
        	} else{
        		//Added for US3113
            	queryCondition = filterCondition + 'Limit 1000';
        	}
        }
    	queryString += queryCondition;
		return Database.query(queryString);
	}
	
	//Added for US904
	public static List<Case> getCaseDetailsByFieldSet(String caseId, String fieldSetName)	{
		List<String> caseFieldList = new List<String>{CHL_Constants.CASE_NUMBER};
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_READ);
		String queryString = CHL_Util.getQueryStringFromFieldSet(CSM_Util.getNamespace() + fieldSetName, CSM_Constants.OBJ_CASE);
        queryString += ' where Id =:caseId LIMIT 1'; 
        system.debug('\n\n queryString :: ' + queryString);
        List<Case>  caseList =  Database.query(queryString);     
        return caseList;
	}
	public static List<SObject> getCasesBySOSL(CHL_GridInputWrapper inputWrapper)
	{
		List<sObject> caseList = new List<sObject>();
		String fieldList = 'Id, AccountId, Account.name, CaseNumber, CHL_CaseSubtype__c, Type, Status, CreatedDate, ClosedDate, CreatedById, CreatedBy.name, Description, Subject, CHL_Related_To_Text__c';  		
   		Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
   			
   		/*Id userAccountId = CHL_Util.currentUserDetails[0].Contact.AccountId;
        Set<Id> userSet =new Set<Id>();
        for(User us: CHL_Util.getUsersForAccount(userAccountId)){
        	userSet.add(us.Id);
       	}*/
            
        String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning Case ('+fieldList+' ORDER BY CaseNumber Desc) Limit '+queryLimit;
   			
   		system.debug('queryString : '+queryString);
		List<List<SObject>>searchList = search.query(queryString);
		system.debug('searchList::'+searchList);
		if(searchList != null && searchList.size()>0){
			caseList.addAll(searchList[0]);
		}
		return caseList;
	}
    public static List<RecordType> getRecordTypes (String objectName, String recordTypaName){
    	List<RecordType> recordTypeList = null;
    	if(String.isBlank(recordTypaName)){
    		recordTypeList = [SELECT Id, Name FROM RecordType WHERE sObjectType = :objectName];
    	}else{
    		recordTypeList = [SELECT Id, Name FROM RecordType WHERE sObjectType = :objectName AND Name = :recordTypaName];
    	}
    	return recordTypeList;
    }

      public static Case createBookingRequest(ID oppId){
          String seNamespace = CSM_Util.nameSpacePrefixSolnExtn;
          Case objCase = new Case();
          List<Case> caseList = new List<Case>();
          List<OpportunityContactRole> contactRoleLst = CSM_ContactDataAccess.getContactFromOpp(new Set<Id>{oppId});
          
          if(CSM_AccessController.hasField('Opportunity', seNamespace + 'Commit_Level__c') && !contactRoleLst.isEmpty()){
          	
		        List<String> caseFieldList = new List<String>{CHL_Constants.CASE_SUBJECT, REN_Constants.OBJ_CASE_STATUS, CHL_Constants.CASE_DESCRIPTION, CHL_Constants.CASE_PRIORITY, REN_Constants.OBJ_CASE_CONTACT_ID,
		        	seNamespace+REN_Constants.OBJ_CASE_OPP, REN_Constants.OBJ_CASE_REC_TYPE, seNamespace+REN_Constants.OBJ_CASE_SUB_CASE_TYPE, seNamespace+REN_Constants.OBJ_CASE_CONTRACT_AMOUNT
				};    
		        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_INSERT);                                                 
          	
                RecordType rtObj = database.query('SELECT Id FROM RecordType WHERE SobjectType = \'Case\' AND (Name = \'Booking Request\')');
                List<QueueSobject> queueObjlist = database.query('SELECT QueueId FROM QueueSobject WHERE SobjectType = \'Case\' AND (Queue.Name = \'Booking Request\') Limit 1');
                objCase.put(seNamespace+REN_Constants.OBJ_CASE_OPP, oppId);
                objCase.put(REN_Constants.OBJ_CASE_REC_TYPE, rtObj.Id);
                objCase.put(seNamespace+REN_Constants.OBJ_CASE_SUB_CASE_TYPE, 'New');
                objCase.put(REN_Constants.OBJ_CASE_STATUS, 'New');
                objCase.put(REN_Constants.OBJ_CASE_DESC, label.REN_LT_BOOKING_REQUEST);
                objCase.put(seNamespace+REN_Constants.OBJ_CASE_CONTRACT_AMOUNT, 2000);///???????????????????????????????????
                objCase.put(REN_Constants.OBJ_CASE_CONTACT_ID, (contactRoleLst.isEmpty()? null: contactRoleLst.get(0).ContactId));
                objCase.put(REN_Constants.OBJ_CASE_SUBJECT, label.REN_LT_BOOKING_REQUEST_CASE);
                objCase.put('Type', label.REN_LT_LBL_BOOKING_REQUEST);
                if(queueObjlist != null && !queueObjlist.isEmpty()) {
                	objCase.put('OwnerId', queueObjlist[0].QueueId);
                }
                caseList.add(objCase);
                insert caseList;
          }
      System.debug('\n\n~~~~: ' + objCase);
          return objCase;
      
      }
	public static void insertCaseShare(List<SObject> caseShareList) 
    {
    	Database.insert(caseShareList, false);     
    }
    public static List<Case> retrieveCaseByUserAccount(Set<Id> accIdSet) 
    {
    	List<String> caseFieldList = new List<String>{CHL_Constants.CASE_SUBJECT, 
                                                    CHL_Constants.CASE_ACCOUNTID,
                                                    CHL_Constants.CASE_DESCRIPTION,
                                                    CHL_Constants.CASE_PRIORITY
                                                    };    
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_READ); 
        if(!Test.isRunningTest()) {
        	return [select id, contact.AccountId from Case where contact.AccountId in :accIdSet];  
        } else {
        	return [select id, AccountId from Case where accountId in :accIdSet];
        }    
    }
    public static List<Sobject> getCaseShareByCaseId(Set<Id> caseIdSet){
    	String queryString='SELECT CaseId,Id,UserOrGroupId FROM  CaseShare WHERE CaseId IN :caseIdSet and UserOrGroupId IN(select Id from User where UserType=\'PowerPartner\') limit 10000';
        return Database.query(queryString);
    }
    public static void deleteCaseShare(List<SObject> caseShareList)  {
    	if(CSM_AccessController.hasObject('CaseShare')) {
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
			Schema.DescribeSObjectResult res = globalDescribe.get('CaseShare').getDescribe();
			if(res.isDeletable()&& CHL_Util.isOWDForCASEPrivate()){
				Database.delete(caseShareList, false);  
			}
    	}   
    }
  
    public static List<QueueSobject> getQueuesDetailByName(Set<String> queueNameSet){
    	//No need to check CRUD FLS for Queue.
    	return database.query('SELECT QueueId FROM QueueSobject WHERE SobjectType = \'Case\' AND (Queue.Name IN :queueNameSet) Limit 1');
    }
    public static List<Case> getCaseDetailsById(Set<String> caseIdsSet, List<String> fieldsList){
    	List<Case>  caseList = new List<Case>();
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_CASE, fieldsList, CSM_Constants.DML_OPERATION_READ);
		String queryString = 'Select Status from Case where Id IN: caseIdsSet';
        caseList =  Database.query(queryString);     
        return caseList;
	}
	
	public static List<Case> updateCases(List<Case> caseList, List<String> fieldsList){
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_CASE, fieldsList, CSM_Constants.DML_OPERATION_READ);
    	update caseList;
    	return caseList;
	}
	//This method is deprecated. Need to delete it.
	public static List<Case> getClosedCases(Set<Id> caseIdSet){
		List<String> caseFields = new List<String> {'IsClosed'};
		CSM_Util.checkCRUD_FLS('Case', caseFields, CSM_Constants.DML_OPERATION_READ);
		return [SELECT Id, IsClosed FROM Case WHERE Id IN :caseIdSet AND IsClosed = true limit 50000];
	}
	public static List<Case> getCasesById(Set<Id> caseIdSet){
		List<String> caseFields = new List<String> {'IsClosed'};
		CSM_Util.checkCRUD_FLS('Case', caseFields, CSM_Constants.DML_OPERATION_READ);
		return [SELECT Id, IsClosed,Owner.Type FROM Case WHERE Id IN :caseIdSet limit 50000];
	}
    
}