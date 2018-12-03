/**
 * @author    	Karunapriya Rameshwaram (karunapriya@comitydesigns.com)     
 * @date         10/08/2014
 * @description  CSM_TaskTriggerHandler trigger handler for CSM_TaskTrigger
 */
public with sharing class CSM_TaskTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	
 	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
 		try {
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
	        Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
	        Boolean hasChannelAccess =SS_LicenseCheck.getInstance().isChannelEnabled;

	 		Set<Id> spplIds = new Set<Id>();
	 		Map<Id,Task> mapTaskSppl = new Map<Id,Task>();
	 		if(hasCSMAccess || hasRenewAccess) {
	 			for(sObject newObj : newRecords) {
	 				if(newObj.get('CSM_SuccessPlan_Play__c') != null && newObj.get('CSM_Play__c') == null && newObj.get('CSM_Account_Plan__c') == null){
		 				spplIds.add((Id)newObj.get('CSM_SuccessPlan_Play__c'));
		 				mapTaskSppl.put((Id)newObj.get('CSM_SuccessPlan_Play__c'),(Task)newObj);
	 				}
	 			}
	 			
	 			if(!spplIds.isEmpty()){
		 			List<CSM_SuccessPlan_Play__c> lstSppl = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListFollowUpTask(spplIds);
		 			for(CSM_SuccessPlan_Play__c sppl: lstSppl){
		 				Task newTask = mapTaskSppl.get(sppl.Id);
		 				newTask.CSM_Play__c = sppl.csm_play__c;
		 				newTask.CSM_Account_Plan__c = sppl.CSM_SuccessPlan_Playbook__r.csm_account_plan__c;	 				
		 			}
	 			}
	 			updatetask(newRecords, newRecordsMap);
	 		}
	 		if(hasChannelAccess) {
	 			String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
	 			for(Sobject taskObj: newRecords) {
	 				if(taskObj.get('CHL_Status_Update__c') == true && taskObj.get('CHL_Related_Partner_Opportunity__c') != null ) {
	 					if((taskobj.get('WhatId') == null || taskobj.get('WhatId') != taskObj.get('CHL_Related_Partner_Opportunity__c')) && ((String)taskObj.get('WhoId')).startsWith(contact_prefix)) {
	 						taskObj.put('WhatId', taskObj.get('CHL_Related_Partner_Opportunity__c'));	
	 					}
	 					if(taskObj.get('IsVisibleInSelfService') == false) {
	 						taskObj.put('IsVisibleInSelfService', true);
	 					}
	 				}
	 			}
	 			
	 		}
	 		
 			
 		} catch(exception ex) {
 
 		}
 	}
	
	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
 		try {
	 		Boolean hasChannelAccess =SS_LicenseCheck.getInstance().isChannelEnabled;
			
	 		if(hasChannelAccess) {
	 			Map<Id,Task> taskMap = new Map<Id,Task>();
	 			for(Sobject taskObj:newRecords) {
	 				if(taskObj.get('CHL_Status_Update__c') == true && taskObj.get('CHL_Related_Partner_Opportunity__c') != null) {
	 					taskMap.put((Id)taskObj.get('CHL_Related_Partner_Opportunity__c'),(Task)taskObj);
	 				}
	 			}
	 			processPartnerOpportunityStatusFromTask(taskMap);
	 			
	 		}
 			
 		} catch(exception ex) {
 
 		}
 	}
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 		Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	try 
	 	{
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
	        Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
	        Boolean hasChannelAccess =SS_LicenseCheck.getInstance().isChannelEnabled;
		 	
		 	if (hasCSMAccess || hasRenewAccess) {
		 		Set<Id> taskIds = new Set<Id>();
		 		Set<Id> closedTaskIds = new Set<Id>();
		 		Set<Id> spplIds = new Set<Id>();
		 		
			 	for(Task t : (List<Task>)newRecords)
			 	{
			 		Task oldTask = (Task)oldRecordsMap.get(t.Id);
			 		if(t.CSM_Play__c != null && t.isClosed && (oldTask.isClosed != t.isClosed || oldTask.status != t.status))
			 		{
			 			taskIds.add(t.Id);
			 			if(t.CSM_SuccessPlan_Play__c<>null)
			 			   spplIds.add(t.CSM_SuccessPlan_Play__c);		
				 		if(String.isEmpty(t.CSM_Task_State__c))
				 		{
				 			closedTaskIds.add(t.Id);
				 		}
			 		}
			 		
			 	}
			 	if (!taskIds.isEmpty() && Schema.sObjectType.CSM_Task_Processing__c.isAccessible()) {
		 			CSM_TaskProcessingDataAccess.updateTaskProcessingStatus(taskIds);
			 	}
			 	if (!closedTaskIds.isEmpty()) {
			 		List<Task> lstTask = CSM_TaskDataAccess.getTasksByIdSet(closedTaskIds);
			 		for(Task t1: lstTask){
			 			t1.CSM_Task_State__c = CSM_Constants.TASK_STATE_MANUAL_COMPLETION;
			 		}
		 			CSM_TaskDataAccess.updateTasks(lstTask);
			 	}
			 	
			  if(spplIds.size()>0)
			  	processSpplForAllClosedTasks(spplIds);
	 		}
	 		
	 		if (hasChannelAccess) {
	 			Map<Id,Task> taskMap = new Map<Id,Task>();
	 			for(Sobject taskObj:newRecords) {
	 				Task oldTask = (Task)oldRecordsMap.get(taskObj.Id);
	 				if((taskObj.get('CHL_Related_Partner_Opportunity__c') != oldTask.get('CHL_Related_Partner_Opportunity__c') || taskObj.get('Description') != oldTask.Description) && taskObj.get('CHL_Status_Update__c') == true && taskObj.get('CHL_Related_Partner_Opportunity__c') != null) {
	 					taskMap.put((Id)taskObj.get('CHL_Related_Partner_Opportunity__c'),(Task)taskObj);
	 				}
	 			}
	 			processPartnerOpportunityStatusFromTask(taskMap);
	 		}
	 	}
	 	catch (exception ex)
	 	{
	 		for (Integer i = 0; i < newRecords.size(); i++)
	 		{
	 			newRecords[i].addError(ex.getMessage());
	 		} 
	 	} 
	 }
	 
	 
	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 		Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	try 
	 	{
	 		Boolean hasChannelAccess =SS_LicenseCheck.getInstance().isChannelEnabled;
		 		
		 	if ((hasChannelAccess)) {
		 		for(Sobject taskObj:newRecords) {
	 				String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
	 				Task oldTask = (Task)oldRecordsMap.get(taskObj.Id);
	 				if(taskObj.get('CHL_Status_Update__c') == true && taskObj.get('CHL_Related_Partner_Opportunity__c') != null) { //(taskObj.get('CHL_Related_Partner_Opportunity__c') != oldTask.get('CHL_Related_Partner_Opportunity__c') || taskObj.get('CHL_Status_Update__c') != oldTask.get('CHL_Status_Update__c')) &&
	 					if((taskobj.get('WhatId') == null || taskobj.get('WhatId') != taskObj.get('CHL_Related_Partner_Opportunity__c')) && ((String)taskObj.get('WhoId')).startsWith(contact_prefix)) {
	 						taskObj.put('WhatId', taskObj.get('CHL_Related_Partner_Opportunity__c'));	
	 					}
	 					if(taskObj.get('IsVisibleInSelfService') == false) {
	 						taskObj.put('IsVisibleInSelfService', true);
	 					}
	 				}
	 			}
	 			
	 		}
	 	}
	 	catch (exception ex)
	 	{
	 		for (Integer i = 0; i < newRecords.size(); i++)
	 		{
	 			newRecords[i].addError(ex.getMessage());
	 		} 
	 	} 
	 	
	 	
	 }
	
	 private void processPartnerOpportunityStatusFromTask(Map<Id,Task> taskMap) {
	 	List<CHL_Partner_Opportunity__c> poListToUpdate = new List<CHL_Partner_Opportunity__c>();
	 	List<CHL_Partner_Opportunity__c> poListFromTask = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(taskMap.keyset());
	 	for(CHL_Partner_Opportunity__c poObj: poListFromTask) {
	 		Task taskObj = taskMap.get(poObj.Id);
	 		if(taskObj.Description != null && !String.IsEmpty(taskObj.Description)) {
	 			poObj.CHL_Status__c = taskObj.Description;
	 			poObj.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
                poObj.CHL_Needs_Status_Update__c = false;
	 			poListToUpdate.add(poObj);
	 		}
	 	}
	 	CHL_Constants.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
	 	CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
	 	if(poListToUpdate != null && !poListToUpdate.isEmpty())	{
	 		CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(poListToUpdate);	
	 	}
	 	
	 }
 	 public void processSpplForAllClosedTasks(Set<Id> spplIds){
 	 	List<Task> tskList;
 	 	
	 	if(!spplIds.isEmpty()){
	 		tskList = CSM_TaskDataAccess.getSPPLsForNotCompletedTasks(spplIds);
	 	}
	 	if(tskList != null && !tskList.isEmpty()){
			for(Task tsk: tskList){
				spplIds.remove(tsk.CSM_SuccessPlan_Play__c);					
			}
	 	}
		 	
	 	if(!spplIds.isEmpty()){
	 		List<CSM_SuccessPlan_Play__c> spplList = new List<CSM_SuccessPlan_Play__c>();
	 		List<CSM_SuccessPlan_Play__c> spplListNew = new List<CSM_SuccessPlan_Play__c>();
	 					 		
	 		spplList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListForTasks(spplIds, false);
	 		
	 		set<id> setSppl = new set<id>();
 			for(CSM_SuccessPlan_Play__c sppl: spplList){
 				setSppl.add(sppl.Id);	 			
 			}
	 		
 			List<CSM_SuccessPlan_Play__c> lstSppl = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListNoNewSPPL(setSppl);
 			set<string> setSpplPrevious = new Set<String>();
 			for(CSM_SuccessPlan_Play__c sppl: lstSppl){
 				setSpplPrevious.add(sppl.CSM_Previous_SPPL__c);	 			
 			}
	 		
		 	
		 	for(CSM_SuccessPlan_Play__c sppl: spplList){
		 		if(sppl.CSM_Play__r.CSM_Play_ReEntry__c  && !setSpplPrevious.contains(sppl.Id) ){
					CSM_SuccessPlan_Play__c insertSppl = new CSM_SuccessPlan_Play__c();
					insertSppl.CSM_Display_Name_Text__c = sppl.CSM_Display_Name_Text__c;
					insertSppl.CSM_Play__c = sppl.CSM_Play__c;
					insertSppl.CSM_Playbook_Play__c = sppl.CSM_Playbook_Play__c;
					insertSppl.CSM_SuccessPlan_Playbook__c = sppl.CSM_SuccessPlan_Playbook__c;
					insertSppl.CSM_Previous_SPPL__c = sppl.Id;
					spplListNew.add(insertSppl);
		 		}
		 	}
 			
			if(!spplListNew.isEmpty()){
				
	 			List<CSM_Task_Processing__c> taskProcessList = new List<CSM_Task_Processing__c>();
	 			List<String> spplIdLst = new List<String>();
	 			for(Id spPlayId:spplIds){
	 				spplIdLst.add(spPlayId); 			
	 			}
	
				taskProcessList = CSM_TaskProcessingDataAccess.getTskProcRecordsForDelete(spplIdLst);//[select Id from CSM_Task_Processing__c where CSM_SuccessPlan_Play__c in: spplIdList];
				if(!taskProcessList.isEmpty()){
					CSM_TaskProcessingDataAccess.deleteTaskProcRecords(taskProcessList);
				}
				
				CSM_SuccessPlanPlayDataAccess.insertSuccessPlanPlayList(spplListNew);
			}

	        processMetricsForAllClosedTasks(spplIds);
	 	}
 	 }
 	 
	 public void processMetricsForAllClosedTasks(Set<Id> spplIds){
		List<Task> allTasks = new List<Task>();
		if(!spplIds.isEmpty()){
			allTasks = CSM_TaskDataAccess.getTasksForSPPL(spplIds);			
		}

		Map<String,Integer> spplMetricsMap = new Map<String,Integer>();
		if(!allTasks.isEmpty()){
			integer count = 0;
			String firstId = '';
			String spplId = '';				
			for(Task tsk: allTasks){
				if(firstId ==''){
					firstId = tsk.CSM_SuccessPlan_Play__c;
					spplId = tsk.CSM_SuccessPlan_Play__c;
				}
				
				if(firstId != '' && spplId == tsk.CSM_SuccessPlan_Play__c){
					count = count + 1;
				}else{
					spplMetricsMap.put(spplId,count);
					count = 1;						
				}
				spplId = tsk.CSM_SuccessPlan_Play__c;					
			}
			spplMetricsMap.put(spplId,count);				
		}
		if(!spplMetricsMap.isEmpty()){
			CSM_TaskDataAccess.updateSPPLsMetrics(spplMetricsMap);			
		}
	 } 	
	 // Code added for US2567
	 // Method : when task created then populate Account__c field value from Lead Lead_Lookup_Account_1__c field.
	 public void updatetask(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
	 	try {
	 	  	if(CSM_AccessController.hasField('TASK', CSM_Util.nameSpacePrefixSolnExtn + 'Account__c') 
	 		   && CSM_AccessController.hasField('LEAD', CSM_Util.nameSpacePrefixSolnExtn + 'Lead_Lookup_Account_1__c')) {
		       
		       String namespace = CSM_Util.nameSpacePrefixSolnExtn;
			   // Set to hold references to all whoid invoking trigger... 
		 	   Set<Id> setLeadId = new Set<Id>();
		 	   // Interate over the Task which invoked this trigger (basically on after insert)... and to add set
			   for(Task t : (List<Task>)newRecords){
				   if(t.WhoId != null) {
					  String s1 = t.WhoId;
				      if(s1.left(3) == '00Q'){
						 setLeadId.add(t.whoId);
					  }
				   }
			   }
			   // Query on lead that matching id in setLeadId.
			   List<Lead> taskListToUpdate = CSM_TaskDataAccess.getLeadIds(setLeadId);
			   Map<Id,Lead> leadMap = new Map<Id,Lead>(taskListToUpdate);
			   CSM_TaskDataAccess.updatetaskAcc(newRecords,leadMap);
				
	 		}
 		} catch(exception ex) {
 
		}
 	}  	 
}