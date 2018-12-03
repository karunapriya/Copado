/**
 * @author      Mike Faust (mike@comitydesigns.com)    
 * @date         8/28/2014
 * @description  CSM_TaskCreationTriggerUtil - trigger Utility for creating  for play Criteria Trigger
 */

public with sharing class CSM_TaskCreationTriggerUtil { 
  
	static String nameSpacePrefixScout;  
	static List<String> newAccountIdList;
	public static List<Id> acctPlanPlaybookList;	
	
	private static String accountIdName {get; set;}
	
	public static void CreatePlayActivities(Set<Id> accountList) { 
		CreatePlayActivities(accountList, null, null);
	}
 
 	public static void CreatePlayActivities(String acctIdName, Set<Id> accountList, List<SObject> newRecords, String triggerObject) {
		accountIdName = acctIdName; 
		CreatePlayActivities(accountList, newRecords, triggerObject);
	}
 
    /**
     * @author       Mike Faust (mike@comitydesigns.com)    
     * @date         8/28/2014
     * @description  CreatePlayActivities, Main method in process of finding an account's play tasks 
     *               and creating them if they aren't already existing
     */ 
    public static void CreatePlayActivities(Set<Id> accountList, List<SObject> newRecords, String triggerObject) { 
        /********* Processing *****/
        //Query the account plan object to get list of associated account plans and account plan templates.
        //List of account plans 
        //Take account List and create temporary set 
        Set<Id> accountSet = new Set<Id>();
        //Assign account list to working set
        system.debug('acclist -' + accountList);
        accountSet.addAll(accountList); 
        List<CSM_Account_Plan__c> accountPlanList = CSM_AccountPlanDataAccess.getActiveAccountPlans(accountSet);
        
        if (accountPlanList!=null && !accountPlanList.isEmpty()) {
            
        	Map<String,CSM_Account_Plan__c> accountPlanbyAccountMap = new Map<String,CSM_Account_Plan__c>();
            
            //Set of Playbooks
            Set<String> playbookIds = new Set<String>();
            
            
            //List of account plan playbooks
            List<CSM_Account_Plan_Playbook__c > accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
            // Map to account to related Playbook set. Created this for fix of DE858
            Map<Id, Set<Id>> accountToPbMap = new Map<Id, Set<Id>>();
            Map<Id, List<CSM_Account_Plan__c>> aptToApMap = new Map<Id, List<CSM_Account_Plan__c>>();
            
            //NOTE: Need change for multiple account plans
            //Build set of account plan ids and account plan template ids
            Set<Id> setAccountsWSuccessPlan = new Set<Id>();
            for (CSM_Account_Plan__c ap : accountPlanList) {
                accountPlanbyAccountMap.put(ap.CSM_AccountId__c,ap);
                setAccountsWSuccessPlan.add(ap.CSM_AccountId__c);
                List<CSM_Account_Plan__c> apList = aptToApMap.get(ap.CSM_Account_Plan_Template__c);
                if(apList == null){
                	apList = new List<CSM_Account_Plan__c>();
                }
                apList.add(ap);
                aptToApMap.put(ap.CSM_Account_Plan_Template__c, apList);
            }
            if(setAccountsWSuccessPlan != null && !setAccountsWSuccessPlan.isEmpty())
            {
	            //Get all the account plan playbook list
	            accountPlanPlaybookList = CSM_AcctPlanTemplatePlaybooksdataAccess.getNonAutomatedAccountPlanPlaybooks(accountPlanList);
	            // DE858: Added parameters to below method. To populate the account to Playbook set map.
	            playbookIds = getUniquePlaybookIds(accountPlanPlaybookList, aptToApMap, accountToPbMap);
	            //system.debug('accountToPbMap $$$$$$$ '+accountToPbMap);
		        acctPlanPlaybookList = new List<Id>();
		        for(CSM_Account_Plan_Playbook__c acctPb: accountPlanPlaybookList){
		        	acctPlanPlaybookList.add(acctPb.Id);
		        }      
	
	            CreateUpdateTaskWrapper(playbookIds, setAccountsWSuccessPlan, accountPlanbyAccountMap, newRecords, triggerObject, accountToPbMap, null);
            }
        }  
        //Query task processing object to verify that a task for the account and play task have been created. If it hasn't then create task. 
    }/* End of Create Play Activities */

	// DE858: Overloaded existing method. Not sure if this is required.
	public static List<CSM_TaskWrapper> CreateUpdateTaskWrapper(Set<String> playbookIds, Set<Id> accountSet, 
    						Map<String,CSM_Account_Plan__c> accountPlanbyAccountMap, 
    						List<SObject> newRecords, String triggerObject)
    {    
    	return CreateUpdateTaskWrapper(playbookIds, accountSet, accountPlanbyAccountMap, 
    									newRecords, triggerObject, new Map<Id, Set<Id>>(),null);
    }

    public static List<CSM_TaskWrapper> CreateUpdateTaskWrapper(Set<String> playbookIds, Set<Id> accountSet, 
    						Map<String,CSM_Account_Plan__c> accountPlanbyAccountMap, 
    						List<SObject> newRecords, String triggerObject, Map<Id, Set<Id>> accountToPbMap,boolean fromValidation)
    {
    	//Set of Playbooks
        List<String> playIds = new List<String>();
        List<CSM_TaskWrapper> taskWrapperList = new List<CSM_TaskWrapper>();
        //Map of account plays 
        Map<String, Set<String>> accountPlaysMap = new Map<String,Set<String>>();
        List<CSM_Task_Processing__c> taskProcessingList = new List<CSM_Task_Processing__c>();
        List<CSM_Play_Task__c> playTaskList = new List<CSM_Play_Task__c>();
        Map<String,List<CSM_Play_Task__c>> playsPlayTaskMap = new Map<String,List<CSM_Play_Task__c>>();
        Map<String,List<sObject>> playCriteriaResultsMap = new Map<String,List<sObject>>();
        Map<String, CSM_TaskWrapper> taskWrapperMap = new Map<String,CSM_TaskWrapper>();
        
    	//Get all the plays so as to get criteria query
    	List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>();
        playbookPlayList = CSM_PlaysDataAccess.getActiveNonAutomatedPlays(playbookIds, triggerObject);
        Map<Id, Set<Id>> accountToPlayMap = new Map<Id, Set<Id>>();
        Map<Id, CSM_PlaybookPlay__c> playbookPlayMap = new Map<Id, CSM_PlaybookPlay__c>();
            
        for (CSM_PlaybookPlay__c p : playbookPlayList){
        	// DE858: Create a map of account to Play set. So that we do not loose track 
        	// of play tasks related to account.
        	for(Id accountId : accountToPbMap.keySet()){
            	Set<Id> pbIdSet = accountToPbMap.get(accountId);
            	if(pbIdSet != null && pbIdSet.contains(p.CSM_Playbook__c)){
            		Set<Id> playSet = accountToPlayMap.get(accountId);
	    			if(playSet == null){
	    				playSet = new Set<Id>();
	    			}
        			playSet.add(p.CSM_Play__c);
        			accountToPlayMap.put(accountId, playSet);
        		}
            }
            //MF 11/6/2014 moved from line 42 into this for loop
            List<sObject> resultsList = new List<sObject>();
            if (p.CSM_Play__r.CSM_Query_Criteria__c != null) {
                //Mfaust 11/6/2014 changed structure of getplaycriteriaQueryResults
                resultsList.addAll(getPlayCriteriaQueryResults(accountSet, p, newRecords, triggerObject));
                playCriteriaResultsMap.put(p.CSM_Play__c, resultsList);
                playbookPlayMap.put(p.CSM_Play__c, p);
                system.debug('up playbookPlayMap -' + p + 'up playCriteriaResultsMap -' + playCriteriaResultsMap);
            }
        }
        //system.debug('accountToPlayMap $$$$$$$ '+accountToPlayMap);
        if (playCriteriaResultsMap!=null && !playCriteriaResultsMap.isEmpty()){
            playIds.addAll(playCriteriaResultsMap.keySet());
            Map<Id, CSM_Play__c> playMap = new Map<Id, CSM_Play__c>(CSM_PlaysDataAccess.populatePlayInformation(playIds));
            //build a map for all accounts and the plays that they match. 
            // DE858: Added parameters to below method. To make sure only play related to accounts are processed.
            accountPlaysMap = buildAccountPlaysMap(playCriteriaResultsMap, accountToPlayMap);
            //system.debug('accountPlaysMap $$$$$$$ '+accountPlaysMap);
            //Loop through LIst of ACcount Ids passed into process. 
            //If the account is in the map. Task those plays to the play list to query
            Set<String> validAccountPlayIdsList = new Set<String>();
            if(newAccountIdList != null && newAccountIdList.size() > 0){
                for (String accountId : newAccountIdList) {
                    if(accountPlaysMap.containsKey(accountId)) {
                        validAccountPlayIdsList.addAll(accountPlaysMap.get(accountId));
                    }
                }
            }else{
                for (String accountId : accountSet) {
                    if(accountPlaysMap.containsKey(accountId)) {
                        validAccountPlayIdsList.addAll(accountPlaysMap.get(accountId));
                    }
                }
            }
                
            //Query the PLay_Task__c for those tasks. 
            playTaskList = CSM_PlayTaskDataAccess.getActiveTasks(validAccountPlayIdsList);
            
            //Builds a map of play's playtasks
            playsPlayTaskMap  = buildPlaysPlayTaskMap(playTaskList);
            taskWrapperMap = buildTaskWrapperMap(playMap, playbookPlayMap, accountPlanbyAccountMap,accountPLaysMap, playsPlayTaskMap ,fromValidation);
            //Create Set of Task Ids to query task processing object.
             taskProcessingList = CSM_TaskProcessingDataAccess.getActiveTasks(validAccountPlayIdsList, accountSet);
            //Loop through task processing, if it exists in map, remove it. 
            //Items in taskWrapperMap at the end will be sent to task creation
            for (CSM_Task_Processing__c t : taskProcessingList) {
                String uniqueId = t.CSM_Success_Plan__r.CSM_AccountId__c + ':' +t.CSM_Play__c +':'+ t.CSM_PlayTask__c;
                //If the taskWrapperMap contains the account/play/playtaskcombination remove it
                if(taskWrapperMap.containsKey(uniqueId)) {
                    taskWrapperMap.remove(uniqueId);
                }
                
            }
            taskWrapperList = taskWrapperMap.values(); 
            system.debug('taskw ' + taskWrapperList);
            if(fromValidation == null){
            	CSM_TaskDataAccess.createUpdateTaskListFromWrapper(taskWrapperList);            
            }
            //setSuccessPlanPlayOnTaskAndTaskProcessing(accountSet, playbookIds, validAccountPlayIdsList, taskWrapperMap);
       }
    	return taskWrapperList;
    }
   public static Set<String> getUniquePlaybookIds(List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList, 
    												Map<Id, List<CSM_Account_Plan__c>> aptToApMap, 
    												Map<Id, Set<Id>> accountToPbMap) {
        Set<String> playbookIds = new Set<String>();
        
        for(CSM_Account_Plan_Playbook__c apPb: accountPlanPlaybookList){
        	if(apPb.CSM_Account_Plan__c != null){
            	Set<Id> pbSet = accountToPbMap.get(apPb.CSM_Account_Plan__r.CSM_AccountId__c);
            	if(pbSet == null){
            		pbSet = new Set<Id>();
            	}
            	pbSet.add(apPb.CSM_Playbook__c);
            	accountToPbMap.put(apPb.CSM_Account_Plan__r.CSM_AccountId__c, pbSet);
        	}else if(apPb.CSM_Account_Plan_Template__c != null){
        		List<CSM_Account_Plan__c> apList = aptToApMap.get(apPb.CSM_Account_Plan_Template__c);
        		if(apList != null && !apList.isEmpty()){
        			for(CSM_Account_Plan__c accountPlan : apList){
        				if(accountPlan != null){
		            		Set<Id> pbSet = accountToPbMap.get(accountPlan.CSM_AccountId__c);
			            	if(pbSet == null){
			            		pbSet = new Set<Id>();
			            	}
			            	pbSet.add(apPb.CSM_Playbook__c);
			            	accountToPbMap.put(accountPlan.CSM_AccountId__c, pbSet);
        				}
        			}
        		}
        	}
        	playbookIds.add(apPb.CSM_Playbook__c);
        }
        
        return playbookIds;
    }
    
    public static Map<String,List<CSM_Play_Task__c>> buildPlaysPlayTaskMap(List<CSM_Play_Task__c> playTaskList) {
        Map<String,LIst<CSM_Play_Task__c>> tmpMap = new Map<String,List<CSM_Play_Task__c>>();
        //Builds a map of play's playtasks          
        for(CSM_Play_Task__c p : playTaskList) {
            if(tmpMap.containsKey(p.CSM_Play__c)) {
                tmpMap.get(p.CSM_Play__c).add(p);
            }
            else {
                tmpMap.put(p.CSM_Play__c,new List<CSM_Play_Task__c>{p});
            }
        }
        return tmpMap;
    }
    
    //MF 11/6/2014 changed structure to include play instance
    //Added object Name check from Play so that it adds the accountId list filter properly
    private static  List<sObject> getPlayCriteriaQueryResults(Set<Id> accountIdList, CSM_PlaybookPlay__c playbook, 
    															List<SObject> newRecords, String triggerObject) {
        List<sobject> tmpList = new List<sObject>();
        String theQuery = playbook.CSM_Play__r.CSM_Query_Criteria__c;
        String objectName = playbook.CSM_Play__r.CSM_Object_Name__c;
		string nameSpace = CSM_UTIL.getNamespace();
		        
        if(objectName == CSM_Constants.OBJ_TYPE_ACCOUNT){
            if(theQuery.contains(CSM_Constants.TASK_WHERE)){
                theQuery += ' and id in :accountIdList'; 
            }
            else{
                theQuery += ' where id in :accountIdList';
            }
        }
        else if (ObjectName.equals(CSM_Constants.OBJ_TYPE_OPPORTUNITY) || ObjectName.equals(CSM_Constants.OBJ_CASE)){
            if(theQuery.contains(CSM_Constants.TASK_WHERE)){
                theQuery += ' and (accountId in :accountIdList)'; 
            }
            else{
                theQuery += ' where accountId in :accountIdList';
            }
        }
        else if (objectName.contains(CSM_Constants.OBJ_AP))
        {
            if(theQuery.contains(CSM_Constants.TASK_WHERE))
            {
                theQuery += ' and CSM_AccountId__c in :accountIdList'; 
            }
            else
            {
                theQuery += ' where CSM_AccountId__c in :accountIdList';
            }
        }
        else if (objectName.contains(CSM_Constants.OBJ_RESPONSE))
        {
			//newAccountIdList = new List<String>();        	
			//if (newRecords != null) {
				/*for(SObject sObj: newRecords){
					newAccountIdList.add((String)sObj.get(nameSpace +'CSM_Object_Id__c'));
				} */       	
        
	            if(theQuery.contains(CSM_Constants.TASK_WHERE))
	            {
	                theQuery += ' and  ' + nameSpace +'CSM_Account__c in :accountIdList'; 
	            }
	            else
	            {
	                theQuery += ' where  ' + nameSpace +'CSM_Account__c in :accountIdList';
	            }
			//}
        }
        
        else if (objectName.contains(CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER))
        {
			nameSpacePrefixScout = objectName.length() != CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER.length()? objectName.substringBefore('__') + '__':'';
			newAccountIdList = new List<String>();
			if (newRecords != null) {
				for(SObject sObj: newRecords){
					newAccountIdList.add((String)sObj.get(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID));
				}        	
	            if(theQuery.contains(CSM_Constants.TASK_WHERE))
	            {
	                theQuery += ' and ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID + ' in :newAccountIdList'; 
	            }
	            else
	            {
	                theQuery += ' where ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID + ' in :newAccountIdList';
	            }
			}
        } else if (accountIdName!=null) {
			if(theQuery.contains(CSM_Constants.TASK_WHERE))
            {
                theQuery += ' and ' + accountIdName + ' in :accountIdList'; 
            }
            else
            {
                theQuery += ' where ' + accountIdName + ' in :accountIdList';
            }
        }
        
        if(triggerObject!=null && 
        	((CSM_Constants.OBJ_TYPE_OPPORTUNITY.equals(ObjectName) && CSM_Constants.OBJ_TYPE_OPPORTUNITY.equals(triggerObject))
        	|| (CSM_Constants.OBJ_CASE.equals(ObjectName) && CSM_Constants.OBJ_CASE.equals(triggerObject))
        	|| (CSM_Constants.OBJ_AP.equals(ObjectName) && CSM_Constants.OBJ_AP.equals(triggerObject))
			|| (ObjectName.contains(CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER) && triggerObject.contains(CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER))        	
        	|| (CSM_Constants.OBJ_TYPE_ACCOUNT.equals(ObjectName) && CSM_Constants.OBJ_TYPE_ACCOUNT.equals(triggerObject))
        	|| (CSM_Constants.OBJ_RESPONSE.equals(ObjectName) && CSM_Constants.OBJ_RESPONSE.equals(triggerObject))
        	|| accountIdName!=null)){
        		if(theQuery.contains(CSM_Constants.TASK_WHERE))
            	{
                	theQuery += ' AND Id IN:newRecords'; 
            	}
            	else
            	{
            		theQuery += ' Where Id IN:newRecords';
            	}
        	
        }
        /*
        else if (objectName.contains(CSM_Constants.OBJ_TYPE_ACCOUNT_PLAN))
        {
            if(theQuery.contains(CSM_Constants.TASK_WHERE))
            {
                theQuery += ' and CSM_AccountId__c in :accountIdList'; 
            }
            else
            {
                theQuery += ' where CSM_AccountId__c in :accountIdList';
            }
        }
        */
        theQuery += ' limit 500';
        system.debug('theQuery $$$$$$$ '+ newRecords + theQuery + 'acccc -' + accountIdList);
        tmpList = Database.query(theQuery);
        system.debug('tmpList $$$$$$$ '+tmpList);
        return tmpList;
        
    }
    
    public static Map<String,Set<String>> buildAccountPlaysMap(Map<String,List<sObject>> playCriteriaResultsMap, 
    															Map<Id, Set<Id>> accountToPlayMap) {
        Map<String,Set<String>> accountPlaysMap = new Map<String,Set<String>>();
        for (String s : playCriteriaResultsMap.keySet()) {
            List<SObject> tmpSObjectSet = new List<Sobject>();
            tmpSObjectSet = playCriteriaResultsMap.get(s);
            for (sObject sObj : tmpSObjectSet) {
                Schema.SObjectType sType = sObj.getSObjectType();
                String sObjectType = String.valueOf(sType);
                System.debug('ZZZZ - '+sobjectType + ' == '+CSM_Constants.OBJ_TYPE_ACCOUNT);
                if(sobjectType == CSM_Constants.OBJ_TYPE_ACCOUNT) {
                	// DE858: Check if play belong to the account or not.
                	Set<Id> playSet = accountToPlayMap.get(sObj.Id);
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey(sObj.id)){
	                        accountPlaysMap.get(sObj.id).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put(sObj.id,new Set<String>{s});
	                    }
                	}
                }
                else if (sobjectType == CSM_Constants.OBJ_TYPE_OPPORTUNITY){
                    Opportunity tmpOpportunity = (Opportunity)sObj;
                    Set<Id> playSet = accountToPlayMap.get(tmpOpportunity.accountId);
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey(tmpOpportunity.accountId)){
	                        accountPlaysMap.get(tmpOpportunity.accountId).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put(tmpOpportunity.AccountId, new Set<String>{s});
	                    }
                	}
                }
                else if(sobjectType.contains(CSM_Constants.OBJ_AP)) {
                   	CSM_Account_Plan__c aPlan = (CSM_Account_Plan__c) sObj;
                   	Set<Id> playSet = accountToPlayMap.get(aPlan.CSM_AccountId__c);
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey(aPlan.CSM_AccountId__c)){
	                        accountPlaysMap.get(aPlan.CSM_AccountId__c).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put(aPlan.CSM_AccountId__c, new Set<String>{s});
	                    }
                	}
                }
                else if(sobjectType.contains(CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER)) {
                   	SObject scoutCustomer =  sObj;
                   	Set<Id> playSet = accountToPlayMap.get((String)scoutCustomer.get(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID));
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey((String)scoutCustomer.get(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID))){
	                        accountPlaysMap.get((String)scoutCustomer.get(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID)).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put((String)scoutCustomer.get(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID), new Set<String>{s});
	                    }
                	}
                }
                else if(sobjectType.equals(CSM_Constants.OBJ_CASE)) {
                    Case caseObj = (Case) sObj;
                    Set<Id> playSet = accountToPlayMap.get(caseObj.accountId);
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey(caseObj.accountId)){
	                        accountPlaysMap.get(caseObj.accountId).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put(caseObj.AccountId, new Set<String>{s});
	                    }
                	}
                }
                else if(sobjectType.contains(CSM_Constants.OBJ_RESPONSE)) {
                    CSM_Survey_Response__c responseObj = (CSM_Survey_Response__c) sObj;
                    Set<Id> playSet = accountToPlayMap.get(responseObj.CSM_Account__c);
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey(responseObj.CSM_Account__c)){
	                        accountPlaysMap.get(responseObj.CSM_Account__c).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put(responseObj.CSM_Account__c, new Set<String>{s});
	                    }
                	}
                	
                } else if (accountIdName!=null){
                	SObject customObj =  sObj;
                	Set<Id> playSet = accountToPlayMap.get((String)customObj.get(accountIdName));
                	if(playSet != null && playSet.contains(s)){
	                    if(accountPlaysMap.containsKey((String)customObj.get(accountIdName))){
	                        accountPlaysMap.get((String)customObj.get(accountIdName)).add(s);
	                    }
	                    else{
	                        accountPlaysMap.put((String)customObj.get(accountIdName), new Set<String>{s});
	                    }
                	}
                }
            }
        }
        return accountPlaysMap;
    }
    
    public static Map<String,CSM_TaskWrapper> buildTaskWrapperMap(Map<id,CSM_Play__c> playMap, 
                                                                  Map<id,CSM_PlaybookPlay__c> playbookPlayMap, 
                                                                  Map<String,CSM_Account_Plan__c> accountPlanbyAccountMap, 
                                                                  Map<String, Set<String>> accountPLaysMap, 
                                                                  Map<String,List<CSM_Play_Task__c>> playsPlayTaskMap,boolean fromValidation)
    {
        system.debug('IN buildTaskWrapperMap');
        system.debug('IN playbookPlayMap -' + playbookPlayMap );
        system.debug('accountPlanbyAccountMap : ' + accountPlanbyAccountMap);
        system.debug('IN accountPLaysMap');
        system.debug('IN playsPlayTaskMap');
        
        Map<String, CSM_TaskWrapper> taskWrapperMap = new Map<String,CSM_TaskWrapper>();
        system.debug('accountPlaysMap : ' + accountPlaysMap);
        
        //system.debug('sppppl' + playbookPlayMap.keySet());
       // system.debug('sppppl' + playMap.keySet());
       // system.debug('sppppl' + acctPlanPlaybookList);
	//	List<csm_successplan_play__c> lst = [select Id, csm_playbook_play__c,csm_play__c,CSM_SuccessPlan_Playbook__c from csm_successplan_play__c where /*csm_playbook_play__c in: playbookPlayMap.keySet() and*/ csm_play__c in: playMap.keySet() and CSM_SuccessPlan_Playbook__c in :acctPlanPlaybookList] ;
		
		//system.debug('sppppl' + lst);
        for (String s : accountPlaysMap.keySet()) {
            CSM_Account_Plan__c accountPlan = new CSM_Account_PLan__c();
            system.debug('s : ' + s);
            Id accountId = (Id)s;
            system.debug('accountId : ' + accountId);            
            if(accountPlanbyAccountMap.containsKey((String)accountId)){
                accountPlan = accountPlanbyAccountMap.get((String)accountId);
            }
            system.debug('accountPlan : ' + accountPlan);
            
            if(acctPlanPlaybookList == null){ 
            	List<CSM_Account_Plan__c> accountPlanList = new List<CSM_Account_Plan__c>();
            	accountPlanList.add(accountPlan);
            	List<CSM_Account_Plan_Playbook__c > accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();	            
		        if(!fromValidation){
		            accountPlanPlaybookList = CSM_AcctPlanTemplatePlaybooksdataAccess.getNonAutomatedAccountPlanPlaybooks(accountPlanList);
			        acctPlanPlaybookList = new List<Id>();
		        	
			        for(CSM_Account_Plan_Playbook__c acctPb: accountPlanPlaybookList){
			        	acctPlanPlaybookList.add(acctPb.Id);
			        }      
		        }else{
		        	List<String> pbIds = new List<String>();
		            for(csm_playbookplay__c pbPlay: playbookPlayMap.Values()){
		            	pbIds.add(pbPlay.csm_playbook__c);
		            }
		            accountPlanPlaybookList = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByPlaybookIdAndAcctPlanId(pbIds,accountPlan.Id);//[select Id from csm_account_plan_playbook__c where csm_playbook__c in : pbIds and csm_account_plan__c =: accountPlan.Id];
			        acctPlanPlaybookList = new List<Id>();
		        	
			        for(CSM_Account_Plan_Playbook__c acctPb: accountPlanPlaybookList){
			        	acctPlanPlaybookList.add(acctPb.Id);
			        }      
		        }
            }
            
			List<csm_successplan_play__c> successPlanlst = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListForTask(playMap,acctPlanPlaybookList,accountPlan);//[select Id, csm_playbook_play__c,csm_play__c,CSM_SuccessPlan_Playbook__c from csm_successplan_play__c where csm_play__c in: playMap.keySet() and CSM_SuccessPlan_Playbook__c in :acctPlanPlaybookList and CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c =: accountPlan.Id];            
            if(accountPlaysMap.containsKey(s)){
                system.debug('Yes, contains : ' + s);
                Set<String> playIds = accountPlaysMap.get(s);
                for (String p : playIds){
                	CSM_SuccessPlan_Play__c successPlanPlyTask = new CSM_SuccessPlan_Play__c();
                    CSM_Play__c thePlay = new CSM_Play__c();
                    CSM_PlaybookPlay__c thePlaybookPlay = new CSM_PlaybookPlay__c();
                    if(playMap.containsKey(p)){
                        thePlay = playMap.get(p);
                        thePlaybookPlay = playbookPlayMap.get(p);
                    }
                    if(playsPlayTaskMap.containsKey(p)){
                    	for(CSM_SuccessPlan_Play__c successPlanPly: successPlanlst){
                    		if(successPlanPly.csm_play__c == p){
                    			successPlanPlyTask = successPlanPly;
                    			break;
                    		}
                    	}
                    	system.debug('Yes, contains : ' + p);
                        List<CSM_Play_Task__c> tmpTaskList = playsPlayTaskMap.get(p);
                        system.debug('tmpTaskList : ' + tmpTaskList);
                        for(CSM_Play_Task__c pt : tmpTaskList){
                            String uniqueId = (Id)s + ':' + pt.CSM_Play__c + ':' + pt.id;
                            CSM_TaskWrapper newWrapper = new CSM_TaskWrapper();
                            newWrapper.AccountId = s;
                            newWrapper.Subject = pt.Name; 
                            newWrapper.comments = pt.CSM_Description__c;
                            //US520
                            newWrapper.taskType = pt.CSM_type__c;
                            newWrapper.recordTypeId = String.valueof(pt.CSM_Record_Type__c);
                            if(accountPlan != null){
                                newWrapper.AccountPlanId = accountPlan.id;
                                if(pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_ACCOUNT_OWNER){
                                    newWrapper.assignToPerson = accountPlan.CSM_Account_Owner_Id__c;
                                }
                                 else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_ACCOUNT_MANAGER) {
                    				newWrapper.assignToPerson = accountPlan.CSM_Account_Manager__c;
                				}
                                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CSM_CONTACT){
                                    newWrapper.assignToPerson = accountPlan.CSM_Contact__c;
                                }
                                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_SUPPORT_CONTACT){
                                    newWrapper.assignToPerson = accountPlan.CSM_Support_Contact__c;
                                }
                                else if(pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CSM_MANAGER){
                                    newWrapper.assignToPerson = accountPlan.CSM_Manager__c; 
                                }
                                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CUSTOMER_SUCCESS_MANAGER){
                                    newWrapper.assignToPerson = accountPlan.CSM_Customer_Success_Manager__c;    
                                }
                                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_EXEC_SPONSOR){
                                    newWrapper.AssignToPerson = accountPlan.CSM_Exec_Sponsor__c;
                                }
                                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_RENEWAL_MANAGER){
                                    newWrapper.AssignToPerson = accountPlan.CSM_Renewal_Manager__c;
                                }
                                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_RENEWAL_CONTACT){
                                    newWrapper.AssignToPerson = accountPlan.CSM_Renewal_Contact__c;
                                } 
                                else if(pt.CSM_Assign_To__c != null) {
                                   	newWrapper.AssignToPerson = (Id)accountPlan.get(pt.CSM_Assign_To__c);
                               	}
                                //If those got assigned as null set to account owner
                                if(newWrapper.AssignToPerson == null){
                                    newWrapper.AssignToPerson = accountPlan.CSM_Account_Owner_Id__c;
                                }
                                    
                            }
                            system.debug('newWrapper.AssignToPerson :' + newWrapper.AssignToPerson);
                            newWrapper.playTaskId = pt.id;
                            newWrapper.playId = p;
                            if(pt.CSM_Days_Until_Due__c != null){
                                Date theDate = System.Today();
                                newWrapper.ActivateDate = theDate.addDays(Integer.valueOf(pt.CSM_Days_Until_Due__c));
                            }
                            //Object references 
                            newWrapper.PlayTask = pt;
                            newWrapper.AccountPlan = accountPlan;
                            newWrapper.Play = thePlay;
                            newWrapper.PlaybookPlay = thePlaybookPlay;
                            newWrapper.PlaybookPlayId = thePlaybookPlay.Id;
                            system.debug('pbid -' + thePlaybookPlay);
                        	boolean createTask = false;                            
                            if(thePlaybookPlay.Id != null){// && uniqueSuccessPlanPlayMap == null
                            	//list<csm_PlaybookPlay__c> playbookPlayList = CSM_PlaybookPlayDataAccess.getPlaybookPlayById( thePlaybookPlay.Id);
                            	//system.debug('pbplidlist -' + playbookPlayList);                            	
                            	//list<CSM_Account_Plan_Playbook__c> planPlaybook;
								//list<CSM_SuccessPlan_Play__c> planPlay; 
                            	//system.debug('aplist -' + accountPlan);								                          	

                            	//if(fromValidation == null){
								newWrapper.successPlanPlay = successPlanPlyTask;
									//createTask = true;   
                            	//}
                            }
                            //if(createTask || fromValidation != null){
                            taskWrapperMap.put(uniqueId,newWrapper);                            
                            //}
 							system.debug('TWP -' + taskWrapperMap);
                        }
                    
                    }
                }
            }
        }
        system.debug('taskWrapperMap : ' + taskWrapperMap);
        return taskWrapperMap;
    }
    
    public static CSM_TaskWrapper getTaskWrapper(Boolean isComplete, 
                                                CSM_Play_Task__c pt, 
                                                Map<Id, CSM_Account_Plan__c> accountPlanMap, 
                                                String acctId) {
                                                    
        CSM_TaskWrapper tw = new CSM_TaskWrapper();
        tw.Comments = pt.CSM_Description__c;
        tw.PlayTask = pt;
        tw.PlayId = pt.CSM_Play__c;
        tw.PlayTaskId = pt.Id; 
        tw.isComplete = isComplete;
        tw.isManual = false;
        tw.Subject = pt.Name;
        tw.taskType = pt.CSM_type__c;
        if(pt.CSM_Days_Until_Due__c != null){
            Date theDate = System.Today();
            tw.ActivateDate = theDate.addDays(Integer.valueOf(pt.CSM_Days_Until_Due__c));
        }               
                            
        //Only need this for pending playbooks to create tasks
        if (accountPlanMap!=null && accountPlanMap.containsKey(acctId)) {
                
            CSM_Account_Plan__c accountPlan = accountPlanMap.get(acctId);
            if(accountPlan != null){
                tw.AccountPlanId = accountPlan.id;
                tw.AccountId = accountPlan.CSM_AccountId__c;
                
                if(pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_ACCOUNT_OWNER){
                    tw.assignToPerson = accountPlan.CSM_Account_Owner_Id__c;
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_ACCOUNT_MANAGER) {
                    tw.assignToPerson = accountPlan.CSM_Account_Manager__c;
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CSM_CONTACT){
                    tw.assignToPerson = accountPlan.CSM_Contact__c;
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_SUPPORT_CONTACT){
                    tw.assignToPerson = accountPlan.CSM_Support_Contact__c;
                }
                else if(pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CSM_MANAGER){
                    tw.assignToPerson = accountPlan.CSM_Manager__c; 
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CUSTOMER_SUCCESS_MANAGER){
                    tw.assignToPerson = accountPlan.CSM_Customer_Success_Manager__c;    
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_EXEC_SPONSOR){
                    tw.AssignToPerson = accountPlan.CSM_Exec_Sponsor__c;
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_RENEWAL_MANAGER){
                    tw.AssignToPerson = accountPlan.CSM_Renewal_Manager__c;
                }
                else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_RENEWAL_CONTACT){
                    tw.AssignToPerson = accountPlan.CSM_Renewal_Contact__c;
                }
                else if(pt.CSM_Assign_To__c != null) {
                   	tw.AssignToPerson = (Id)accountPlan.get(pt.CSM_Assign_To__c);
               	}
                //If those got assigned as null set to account owner
                if(tw.AssignToPerson == null){
                    tw.AssignToPerson = accountPlan.CSM_Account_Owner_Id__c;
                }
            }
        }
        return tw;      
    }
    
    /*
     * @description: Set Evaluation Date on SP_PL Object. Added as part US1454.
       @param : taskList - List of created task Object, sp_plMap - SP_PL map having Evaluation Date == null. 
     */
    public static void setSPPlEvalutionDate(List<sObject> taskList, Map<Id,CSM_SuccessPlan_Play__c> sp_plMap){
    	Set<Id> taskIdSet ;
    	List<Task> taskListToUpdate;
    	system.debug('\n\n @@@ setSPPlEvalutionDate :: ' + sp_plMap );
    	if(sp_plMap != null){
    		if(taskList != null){
    			taskIdSet = new Set<Id>();
    			for(Sobject t : taskList){
    				taskIdSet.add(t.id);
    			}
    			taskListToUpdate = CSM_TaskDataAccess.getTasksByIdSet(taskIdSet);
    			if(taskListToUpdate != null){
    				for(Task taskObj : taskListToUpdate){
    					if(sp_plMap.containsKey(taskObj.CSM_SuccessPlan_Play__c)){
    						sp_plMap.get(taskObj.CSM_SuccessPlan_Play__c).CSM_Evaluation_Date__c = (DateTime)taskObj.CreatedDate;
    					}
    				}
    				system.debug('\n\n @@@ updating SPPL values :: ' + sp_plMap );
    				CSM_SuccessPlanPlayDataAccess.updateSuccessPLanPlay(sp_plMap.values());
    			}
    		}
    	}
    }
}