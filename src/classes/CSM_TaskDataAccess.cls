public with sharing class CSM_TaskDataAccess
{      
	
	public static Database.SaveResult[] createTask(List<Task> taskList, Set<String> fieldsForCrudFlsCheck){
		CSM_Util.checkCRUD_FlsPermissions(CSM_Constants.OBJ_TASK, fieldsForCrudFlsCheck, CSM_Constants.DML_OPERATION_INSERT);
	    Database.SaveResult[] srList = database.insert(taskList, false);
	    return srList;
	}
	
    public void createWrapperAndCompDismissTasks(Set<Id> selectedTaskIds, List<Task> taskList, List<Task> taskValList, Boolean isComplete, Boolean isManual){

    }
    
    
    public void createWrapperAndCompDismissTasks(Set<Id> selectedTaskIds, List<Task> taskList, List<Task> taskValList, List<Schema.FieldSetMember> mandatoryFields, Boolean isComplete, Boolean isManual, Boolean isMultiple){
        Map<Id, CSM_TaskWrapper> taskWrapperMap = new Map<Id, CSM_TaskWrapper>();
		Task taskVal = null;
		
        if (taskValList != null && !taskValList.isEmpty() ){
               taskVal = taskValList.get(0);
        }
		for (Task task : taskList)  {
        	if (selectedtaskIds.contains(task.Id)){// && task.status!=CSM_Constants.TASK_COMPLETED
                CSM_TaskWrapper taskWrapper = new CSM_TaskWrapper();
                taskWrapper.isComplete = isComplete;
                //MF added for task completion date 
                if(taskVal!=null){                	
                	if (taskVal.CSM_Completed_Date__c != null)
                	{ 
                	    taskWrapper.completedDate = taskVal.CSM_Completed_Date__c;
                	}
                	taskWrapper.isManual = isManual;
	                taskWrapper.TaskId = task.Id;
	                taskWrapper.RiskReason = taskVal.CSM_Risk_Reason__c;
	                taskWrapper.Comments = taskVal.Description;
	                taskWrapper.Status = taskVal.Status;
	              //  taskWrapper.RecordType = taskval.RecordType;                
					//taskWrapper.playOutcome = taskVal.CSM_Play_Outcome__c;
	                taskWrapperMap.put(task.Id, taskWrapper);
                } 
                
            }
        }   
        System.debug('VVV - taskWrapperMap - '+taskWrapperMap);
        //completeDismissTasks(taskWrapperMap);
        completeDismissTasks(taskWrapperMap, mandatoryFields, taskVal, isMultiple);
    }    

    public void completeDismissTasks(Map<Id, CSM_TaskWrapper> taskWrapperMap, List<Schema.FieldSetMember> mandatoryFields, Task taskVal, Boolean isMultiple){      

		Set<Id> spPLIds = new Set<Id>();
        String tskStatus = '';
        Boolean isPlayOutcome = false;
     	List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_PLAY_STATUS,
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_TASK_STATE, CSM_Constants.OBJ_T_WHOID,CSM_Constants.OBJ_T_STATUS};
   
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ); 
        
            if (taskWrapperMap!=null && !taskWrapperMap.isEmpty()){
                Set<Id> taskToUpdate = new Set<Id>();
                List<Task> taskToCloseDismiss = new List<Task>();
                List<Task> taskForMetrics = new List<Task>();                
                
                List<Task> tasks = [SELECT Id, Status ,isClosed, CSM_Risk_Reason__c , CSM_Task_State__c, CSM_Play__c, REN_Opportunity__c,
                                    ActivityDate, WhatId, WhoId, CSM_Play_Exit_Date__c, CSM_Play_Status__c, Description,
                                    CSM_Completed_Date__c, CSM_SuccessPlan_Play__c,CSM_SuccessPlan_Play__r.CSM_Play_Outcome__c  
                                    FROM Task WHERE Id IN : taskWrapperMap.keySet() AND isClosed = false LIMIT 5000];

                
                Map<Id, CSM_Account_Plan__c> acctPlanMap = new Map<Id, CSM_Account_Plan__c>();
                if (tasks!=null && !tasks.IsEmpty()){                   
                    for (Task tsk : tasks){
                            //tsk.Status = CSM_Constants.TASK_COMPLETED; 
                            
                            if (taskWrapperMap.containsKey(tsk.Id)){ 
                                tsk.CSM_Risk_Reason__c = taskWrapperMap.get(tsk.Id).RiskReason;
                                tsk.Status = taskWrapperMap.get(tsk.Id).Status;
                                tskStatus = tsk.Status;
                                if(tsk.CSM_SuccessPlan_Play__c != null) {
                                	spPLIds.add(tsk.CSM_SuccessPlan_Play__c);
                                }
                                if(!String.isBlank(tsk.CSM_SuccessPlan_Play__r.CSM_Play_Outcome__c)) {
                                	isPlayOutcome = true;
                                }
                                //MF added for completion date
                                if (taskWrapperMap.get(tsk.Id).completedDate!=null){
                                	tsk.CSM_Completed_Date__c =  taskWrapperMap.get(tsk.Id).completedDate;
                                }
                                tsk.Description = tsk.Description!=null?tsk.Description+taskWrapperMap.get(tsk.Id).Comments:taskWrapperMap.get(tsk.Id).Comments;
                                if (taskWrapperMap.get(tsk.Id).isManual!=null && tsk.Status == 'Completed'){ //tsk.isComplete!=null
                                    tsk.CSM_Task_State__c =  taskWrapperMap.get(tsk.Id).isManual?
                                                                (taskWrapperMap.get(tsk.Id).isComplete?CSM_Constants.TASK_STATE_MANUAL_COMPLETION:CSM_Constants.TASK_STATE_MANUAL_DISMISSAL):
                                                                (taskWrapperMap.get(tsk.Id).isComplete?CSM_Constants.TASK_STATE_SYSTEM_COMPLETION:CSM_Constants.TASK_STATE_SYSTEM_DISMISSAL);
                                }
                                //Eswar Bala - 09/11/2014
                                if(taskWrapperMap.get(tsk.Id).processingStatus == CSM_Constants.INT_PLAYRESULT_ATTAINED)
                                {
                                    tsk.CSM_Task_State__c = CSM_Constants.TASK_STATE_SYSTEM_COMPLETION;
                                }
                                else if(taskWrapperMap.get(tsk.Id).processingStatus == CSM_Constants.INT_PLAYRESULT_HALTED)
                                {
                                    tsk.CSM_Task_State__c = CSM_Constants.TASK_STATE_SYSTEM_DISMISSAL;
                                }
                                
                                tsk.CSM_Play_Exit_Date__c = taskWrapperMap.get(tsk.Id).playExitDate;
								tsk.CSM_Play_Status__c = taskWrapperMap.get(tsk.Id).processingStatus;
								
								//iterating through the mandatoryFieldValuesMap to set the required values
								system.debug('isMultiple::'+isMultiple);
								if (mandatoryFields != null) {
									system.debug('enter AAA MandatoryFields::'+mandatoryFields);
									for(Schema.FieldSetMember f : mandatoryFields) {
										if (tsk.get(f.FieldPath) == null || String.valueOf(tsk.get(f.FieldPath)) == '') {
											tsk.put(f.FieldPath, taskVal.get(f.FieldPath));
										}
									}
								}
								system.debug('task after setting::'+tsk);								

                            }
                            taskToCloseDismiss.add(tsk);
                        	taskForMetrics.add(tsk);                            
                    }
					//Added for US1264                                
	                if(spPLIds != null && spPLIds.size() > 0 && isPlayOutcome == true && isMultiple == false) {
	                	system.debug('spPLIds : '+spPLIds);
	                	List<Task> spPLtasksList = getTasksForSPPL(spPLIds);
	                    for (Task tskSPPL : spPLtasksList){
	                        if(!String.isBlank(tskStatus) && tskSPPL.isClosed != true) {
	                        	tskSPPL.Status = tskStatus;
	                        } else {
	                        	if(tskSPPL.isClosed != true){
	                        		tskSPPL.Status = CSM_Constants.TASK_COMPLETED;	                        	
	                        	}
	                        }
	                        //Set Mandatory fields for other tasks of same SPPL
	                        if (mandatoryFields != null) {
								for(Schema.FieldSetMember f : mandatoryFields) {
									if(taskWrapperMap.containsKey(tskSPPL.Id)){
										if (tskSPPL.get(f.FieldPath) == null || String.valueOf(tskSPPL.get(f.FieldPath)) == '') {
											tskSPPL.put(f.FieldPath, taskVal.get(f.FieldPath));
										}
									}
								}
							}
	                        if (!taskWrapperMap.containsKey(tskSPPL.Id)  && tskSPPL.isClosed != true){ 
	                        	taskToCloseDismiss.add(tskSPPL);
	                        }
	                        if (!taskWrapperMap.containsKey(tskSPPL.Id)){ 
	                        	taskForMetrics.add(tskSPPL);
	                        }
	                    }	                    
	                }		
                    if (taskToCloseDismiss!=null && !taskToCloseDismiss.isEmpty())  {
                        updateTasks(taskToCloseDismiss);
						if(isPlayOutcome == true){
							updateSuccessPlayMetrics(taskForMetrics);	//taskToCloseDismiss					
						}
                        
                    }
                }
            }
    }
    
    public static void updateTasks(List<Task> taskList){
    	List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_PLAY_STATUS,
            CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_TASK_STATE, 
            CSM_Constants.OBJ_T_WHOID, 'CSM_SuccessPlan_Play__c', 'CSM_Play_Exit_Date__c', CSM_Constants.OBJ_T_DESCRIPTION,
            CSM_Constants.OBJ_T_COMPLETED_DATE,CSM_Constants.OBJ_T_RISK_REASON, CSM_Constants.OBJ_T_STATUS ,'WhatId'};
   
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_UPDATE); 
        update taskList;
    	
    }

    public static void updateSuccessPlayMetrics(List<Task> taskList){
    	List<String> successPlayList = new List<String>{CSM_Constants.OBJ_T_ID,CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS,CSM_Constants.OBJ_FLD_TOTL_TASKS};

        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY, successPlayList, CSM_Constants.DML_OPERATION_UPDATE);
        
   		String successPlanPlayId = taskList[0].CSM_SuccessPlan_Play__c;
   		CSM_SuccessPlan_Play__c successPlanPlay = new CSM_SuccessPlan_Play__c(Id = successPlanPlayId);
   		successPlanPlay.CSM_Number_of_Closed_Tasks__c = taskList.size();
   		successPlanPlay.CSM_Total_number_of_Tasks__c = taskList.size();
        
        List<CSM_SuccessPlan_Play__c> sppList = new List<CSM_SuccessPlan_Play__c>();
        sppList.add(successPlanPlay);
         system.debug('xxx - ' + successPlanPlay);
        CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false; 
        update sppList;
    	
    }

    public static void updateSPPLsMetrics(Map<String,Integer> spplMetricsMap){
    	List<String> successPlayList = new List<String>{CSM_Constants.OBJ_T_ID,CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS,CSM_Constants.OBJ_FLD_TOTL_TASKS,CSM_Constants.OBJ_FLD_TOTL_TASKS,CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS,CSM_Constants.OBJ_PR_EXIT_DATE};

        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY, successPlayList, CSM_Constants.DML_OPERATION_UPDATE);
        List<CSM_SuccessPlan_Play__c> spplList = new List<CSM_SuccessPlan_Play__c>();
   		for(String strId:spplMetricsMap.KeySet()){
	   		String successPlanPlayId = strId;
	   		CSM_SuccessPlan_Play__c successPlanPlay = new CSM_SuccessPlan_Play__c(Id = successPlanPlayId);
	   		successPlanPlay.CSM_Number_of_Closed_Tasks__c = spplMetricsMap.get(strId);
	   		successPlanPlay.CSM_Total_number_of_Tasks__c = spplMetricsMap.get(strId);
        	successPlanPlay.CSM_Exit_Date__c = system.now(); 	   		
	   		spplList.add(successPlanPlay);
   		}
        CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
        update spplList;
    	
    }


    
   public void completeDismissTasks(Map<Id, CSM_TaskWrapper> taskWrapperMap){
        
       List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_PLAY_STATUS,
            CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_TASK_STATE, CSM_Constants.OBJ_T_WHOID,
            CSM_Constants.OBJ_T_IS_CLOSED};

        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList,  CSM_Constants.DML_OPERATION_READ);  
            
            if (taskWrapperMap!=null && !taskWrapperMap.isEmpty()){
                Set<Id> taskToUpdate = new Set<Id>();
                List<Task> taskToCloseDismiss = new List<Task>();
                
                List<Task> tasks = [SELECT Id, CSM_Task_State__c, CSM_Play__c, REN_Opportunity__c, Description,
                                    CSM_Risk_Reason__c, ActivityDate, Status, WhatId, WhoId, CSM_Play_Exit_Date__c, CSM_Play_Status__c,
                                    CSM_Completed_Date__c, IsClosed
                                    FROM Task WHERE Id IN : taskWrapperMap.keySet() LIMIT 5000];
                
                Map<Id, CSM_Account_Plan__c> acctPlanMap = new Map<Id, CSM_Account_Plan__c>();
                if (tasks!=null && !tasks.IsEmpty()){                   
                    for (Task tsk : tasks){
                            //tsk.Status = CSM_Constants.TASK_COMPLETED; 
                            
                            if (taskWrapperMap.containsKey(tsk.Id)){
                            	if (!tsk.IsClosed)
                                { 
	                                tsk.CSM_Risk_Reason__c = taskWrapperMap.get(tsk.Id).RiskReason;
	                                system.debug('taskWrapperMap.get(tsk.Id).playResultId ' + taskWrapperMap.get(tsk.Id).playResultId);
	                                if(taskWrapperMap.get(tsk.Id).playResultId == null){
	                                	tsk.Status = taskWrapperMap.get(tsk.Id).Status;
	                                }
	                                else{
	                                	tsk.Status = CSM_Constants.TASK_COMPLETED;
	                                }
	                                //MF added for completion date
	                                if (taskWrapperMap.get(tsk.Id).completedDate!=null){
	                                	tsk.CSM_Completed_Date__c =  taskWrapperMap.get(tsk.Id).completedDate;
	                                }
	                                tsk.Description = tsk.Description!=null?tsk.Description+taskWrapperMap.get(tsk.Id).Comments:taskWrapperMap.get(tsk.Id).Comments;
	                                if (taskWrapperMap.get(tsk.Id).isManual!=null && tsk.Status!=null){
	                                    tsk.CSM_Task_State__c =  taskWrapperMap.get(tsk.Id).isManual?
	                                                                (taskWrapperMap.get(tsk.Id).isComplete?CSM_Constants.TASK_STATE_MANUAL_COMPLETION:CSM_Constants.TASK_STATE_MANUAL_DISMISSAL):
	                                                                (taskWrapperMap.get(tsk.Id).isComplete?CSM_Constants.TASK_STATE_SYSTEM_COMPLETION:CSM_Constants.TASK_STATE_SYSTEM_DISMISSAL);
	                                }
	                                //Eswar Bala - 09/11/2014
	                                if(taskWrapperMap.get(tsk.Id).processingStatus == CSM_Constants.INT_PLAYRESULT_ATTAINED)
	                                {
	                                    tsk.CSM_Task_State__c = CSM_Constants.TASK_STATE_SYSTEM_COMPLETION;
	                                }
	                                else if(taskWrapperMap.get(tsk.Id).processingStatus == CSM_Constants.INT_PLAYRESULT_HALTED)
	                                {
	                                    tsk.CSM_Task_State__c = CSM_Constants.TASK_STATE_SYSTEM_DISMISSAL;
	                                }
                                }
                                tsk.CSM_Play_Exit_Date__c = taskWrapperMap.get(tsk.Id).playExitDate;
								tsk.CSM_Play_Status__c = taskWrapperMap.get(tsk.Id).processingStatus;
                            }
                            taskToCloseDismiss.add(tsk);
                    }   
                    if (taskToCloseDismiss!=null && !taskToCloseDismiss.isEmpty())  {
                        updateTasks(taskToCloseDismiss);
                    }
                }
            }
    }         
    
     public static void createUpdateTaskListFromWrapper(List<CSM_TaskWrapper> wrapperList, Map<String, CSM_Play_Result__c> accountPlayResult, Map<String, ID> uniqueSuccessPlanPlayMap)
    {
        List<CSM_Play_Result__c> failedPlayResult = new List<CSM_Play_Result__c>();
        List<Task> createTaskList = new List<Task>();
        system.debug('\n\n Calling createUpdateTaskListFromWrapper method with CSM_TaskWrapperList:: ' + wrapperList + '\n accountPlayResult :: ' + accountPlayResult + '\n uniqueSuccessPlanPlayMap :: ' + uniqueSuccessPlanPlayMap);
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_PLAY, 
            CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_DESCRIPTION, 
            CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_PR_PLAYRESULT_ID};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK,
        CSM_Constants.DML_OPERATION_INSERT, taskFieldList);     
        Map<Id,CSM_SuccessPlan_Play__c> spPlMap = new Map<Id,CSM_SuccessPlan_Play__c>(); //SP_PL object which has evalution date = null will be added in the map.
        Set<Id> spPlIdSet = new Set<Id>();
        if (noAccessList.isEmpty()){
            for (CSM_TaskWrapper t : wrapperList){
                Task newTask = new Task();
                //What Id = account plan Id 
                newTask.whatID = t.accountId;
                if (t.activateDate!=null){
                	newTask.ActivityDate = Date.valueOf(t.activateDate);
                }
                newTask.CSM_Account__c = t.accountId;
                newTask.CSM_Account_Plan__c = t.accountPlanId;
                newTask.REN_Opportunity__c = t.opportunityId;
                newTask.CSM_Play__c = t.PlayId;
                newTask.CSM_Play_Task__c = t.PlayTaskid; 
                newTask.description = t.comments;
                newTask.subject = t.subject;
                newTask.Ownerid = t.assignToPerson; 
                newTask.CSM_Play_Enter_Date__c = t.playEnterDate;
                newTask.CSM_Play_Exit_Date__c = t.playExitDate;
                newTask.CSM_Play_Status__c = t.processingStatus;
                newTask.CSM_Play_Result_Id__c = t.playResultId;
                newTask.Type = t.taskType;
                newTask.CSM_SuccessPlan_Play__c = uniqueSuccessPlanPlayMap.get(t.accountPlanId + ':' + t.PlayId);
                spPlIdSet.add(uniqueSuccessPlanPlayMap.get(t.accountPlanId + ':' + t.PlayId));

                createTaskList.add(newTask); 
                system.debug(t.successPlanPlay + '\n\n~~~~Task : ' + newTask);
            }
            
            Database.SaveResult[] srList = database.insert(createTaskList, false);
            Integer i = 0;
            Task t;
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    String msg = 'The following error has occurred - ';                    
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        msg += err.getStatusCode() + ': ' + err.getMessage();
                        msg += ' - Tasks fields that affected this error: ' + err.getFields();
                    }
                    t = createTaskList[i];
                    
                    //iterate throught the accountPlayResult to find the Play Result containing the failed CSM_Play_Result_Id__c
		            for(CSM_Play_Result__c pr :accountPlayResult.values()) {                                       
		                if(pr.CSM_Play_Result_Id__c != null && t.CSM_Play_Result_Id__c != null) {
							if (pr.CSM_Play_Result_Id__c.equals(t.CSM_Play_Result_Id__c)) {
		                        pr.CSM_Failed_Description__c = msg;
		                        pr.CSM_Failed__c = true;
		                        failedPlayResult.add(pr);
							}
							break;
		                }   
		            }
		            
                    /*if (accountPlayResult.containsKey(t.CSM_Account__c)){
                        CSM_Play_Result__c pr = accountPlayResult.get(t.CSM_Account__c);
                        pr.CSM_Failed_Description__c = msg;
                        pr.CSM_Failed__c = true;
                        failedPlayResult.add(pr);
                        
                    }else if(accountPlayResult.containsKey(t.REN_Opportunity__c)){
                        CSM_Play_Result__c pr = accountPlayResult.get(t.REN_Opportunity__c);
                        pr.CSM_Failed_Description__c = msg;
                        pr.CSM_Failed__c = true;
                        failedPlayResult.add(pr);
                    }*/
                    createTaskList.remove(i);
                }
                i++;
                
            }
            //Added For US1454 - Set Evalution Date on SP_Pl record
            List<CSM_SuccessPlan_Play__c> spPlList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListbyId(spPlIdSet);
            if(spPlList != null){
            	for(CSM_SuccessPlan_Play__c spPlObj : spPlList){
            		if(spPlObj != null && spPlObj.CSM_Evaluation_Date__c == null){
                		spPlMap.put(spPlObj.id, spPlObj);
                	}
            	}
            }
            CSM_TaskCreationTriggerUtil.setSPPlEvalutionDate(createTaskList, spPlMap); //Added For US1454 - Set Evalution Date on SP_Pl record
            CSM_TaskProcessingDataAccess.createTaskProcessing(createTaskList, accountPlayResult);
        }
        if (!failedPlayResult.isEmpty()){
            List<String> prFieldList = new List<String>{CSM_Constants.OBJ_PR_FAILED_DESC, CSM_Constants.OBJ_PR_FAILED};
            
        List<String> noAccessPrList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
            CSM_Constants.OBJ_PR, CSM_Constants.DML_OPERATION_UPDATE, prFieldList); 
         if (noAccessPrList.isEmpty())
         {
            update failedPlayResult;
         }
         else
         {
            String[] arguments = new String[] {CSM_Constants.OBJ_PR + ':'+String.valueOf(noAccessPrList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments)); 
         }
        }

    }                      
    
    public static void createUpdateTaskListFromWrapper(List<CSM_TaskWrapper> wrapperList)
    {
        List<Sobject> createTaskList = new List<Sobject>();
        system.debug('debb - ' + wrapperList);
        Map<Id,CSM_SuccessPlan_Play__c> spPlMap = new Map<Id,CSM_SuccessPlan_Play__c>(); //Added US1454 : SP_pl object which has evalution date = null will be added in the map.
        try {
        for (CSM_TaskWrapper taskWrapper : wrapperList)
        {
        	Sobject sObjTask = Schema.getGlobalDescribe().get(CSM_Constants.OBJ_TASK).newSObject();
        	sObjTask.put('whatID',taskWrapper.accountId);
        	if (taskWrapper.activateDate!=null){
        		sObjTask.put('ActivityDate',Date.valueOf(taskWrapper.activateDate));
            }
           	sObjTask.put('CSM_Account__c',taskWrapper.accountId);
           	sObjTask.put('CSM_Play__c',taskWrapper.playid);
           	sObjTask.put('CSM_Play_Task__c',taskWrapper.PlayTaskid);
        	sObjTask.put('CSM_Account_Plan__c',taskWrapper.AccountPlanId);
        	sObjTask.put('description',taskWrapper.comments);
        	sObjTask.put('subject',taskWrapper.subject);
        	sObjTask.put('Ownerid',taskWrapper.assignToPerson);
        	sObjTask.put('Type',taskWrapper.taskType);
        	if(taskWrapper.successPlanPlay != null){
        		sObjTask.put('CSM_SuccessPlan_Play__c',taskWrapper.successPlanPlay.Id);   
        		//Added For US1454 - Set Evalution Date on SP_Pl record
        		if(taskWrapper.successPlanPlay.CSM_Evaluation_Date__c == null){
					if(!String.isEmpty(taskWrapper.successPlanPlay.id)){
						spPlMap.put(taskWrapper.successPlanPlay.id, taskWrapper.successPlanPlay);					
					}
        		}     	
        	}
        	if(String.isNotBlank(taskWrapper.recordTypeId)) {
        		sObjTask.put('RecordTypeId',taskWrapper.recordTypeId);
        	}
		createTaskList.add(sObjTask);
        }
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_PLAY, 
            CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_DESCRIPTION, 
            CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_PLAY};
                
       	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_INSERT);
        insert createTaskList;
            
        CSM_TaskCreationTriggerUtil.setSPPlEvalutionDate(createTaskList, spPlMap);//US1454 - Set Evalution Date on SP_Pl record
        CSM_TaskProcessingDataAccess.createTaskProcessing(createTaskList);
        }
        catch(exception ex) {
        	System.debug('\n\nError: ' + ex.getStackTraceString());
        	if((String.valueOf(ex)).contains(System.Label.CSM_EXCEPTION_STRING)) {
	 			throw new invalidDataException(System.Label.CSM_RECORD_TYPE_EXCEP_MSG);
	 		} else {
	 			throw new invalidDataException(ex.getMessage());
	 		}
        }      
        
    }    
    
    public static List<Task> getTasksByAccountPlan(String accountPlanId)
    {
        List<Task> tmplist = new List<Task>();
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, 
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_DESCRIPTION, 
            CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_PLAY, 
            CSM_Constants.OBJ_T_ACCTPLAN, CSM_Constants.OBJ_T_STATUS, CSM_Constants.OBJ_T_PLAY_STATUS};
           
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);   
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_DISPLAY_NAME};
                                                                                                   
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);
                                                                                                    
            tmplist =  [SELECT id, activitydate, subject, whatid, CSM_Account__c, CSM_Account_Plan__r.CSM_AccountId__r.Name, 
                            CSM_Risk_Reason__c, CSM_Account_Plan__c, what.name, ownerid, status, CSM_Task_State__c, 
                            CSM_Play__c, Description, CSM_Completed_Date__c, REN_Opportunity__c, 
                            CSM_Play__r.CSM_Display_Name__c, CSM_Play_Status__c 
                    FROM Task 
                    WHERE CSM_Account_Plan__c = :accountPlanId AND 
                        CSM_Play__c !=null 
                    ORDER BY CSM_Play__c LIMIT 1000];
            return tmplist;
    } 


    public static List<Task> getOverdueTasksByAccountPlan(List<CSM_Account_Plan__c> accountPlanIds)
    {
        List<Task> tmplist = new List<Task>();
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_PLAY,
        							CSM_Constants.OBJ_T_ACCTPLAN,CSM_Constants.OBJ_T_ACTIVITYDATE,CSM_Constants.OBJ_T_STATUS
        							,CSM_Constants.OBJ_O_IS_CLOSED};
            
        CSM_Util.checkCRUD_FLS( CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        
        
            tmplist =  [SELECT id,CSM_Account_Plan__c 
                    		FROM Task 
                    		WHERE CSM_Account_Plan__c in :accountPlanIds AND 
                        	CSM_Play__c !=null and activitydate <= TODAY
                        	and isClosed = false];
            return tmplist;
    } 

    public static List<Task> getTasksById(String taskId)
    {
       List<Task> tmplist = new List<Task>();
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_DESCRIPTION, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_SUBJECT, 
            CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_ACCTPLAN,
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_WHOID, REN_Constants.OBJ_T_REN_OPPORTUNITY,
            CSM_Constants.OBJ_T_TASK_STATE, CSM_Constants.OBJ_T_COMPLETED_DATE, CSM_Constants.OBJ_T_STATUS, CSM_Constants.OBJ_T_PLAY_STATUS};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_DISPLAY_NAME};
                                                                                                    
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);        
        
            tmplist =  [SELECT id,
                           CSM_Risk_Reason__c,
                           Description,
                           activitydate, 
                           subject, 
                           whatid, 
                           what.name,
                           whoid,
                           ownerid,
                           status,
                           REN_Opportunity__c,
                           CSM_Task_State__c,
                           CSM_Completed_Date__c,
                           CSM_Account__c,
                           CSM_Account_Plan__c, 
                           CSM_Play_Task__c,
                           CSM_Play__c,
                           CSM_Play__r.CSM_Display_Name__c,
                           CSM_Play_Status__c,
                           CSM_SuccessPlan_Play__c	
                      FROM Task  WHERE Id = :taskId LIMIT 1];
            return tmplist;
    }
    
    
    public static List<Task> getTasksById(String taskId, List<String> queryList){
        return getTasksByIdSet(new Set<Id>{(ID)taskId}, queryList);
    }
        
    public static List<Task> getTasksByIdSet(Set<Id> taskIds)
    {
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_TASK_STATE, 'CSM_SuccessPlan_Play__c'};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<Task> lstTask = [select Id,CSM_Task_State__c,createdDate,CSM_SuccessPlan_Play__c from Task where Id in : taskIds]; 		
 		return lstTask;
    }
    
    public static List<Task> getTasksByIdSet(Set<Id> taskIds, List<String> queryList)
    {
        List<Task> tmplist = new List<Task>();
        
       List<String> taskDefaultQueryFields = new List<String>{'Id', 'CSM_Risk_Reason__c', 'Description', 'ActivityDate', 'Subject', 'WhatId', 'What.Name', 'WhoId',
        				   'OwnerId', 'Status', 'REN_Opportunity__c',
                           'CSM_Task_State__c',
                           'CSM_Completed_Date__c',
                           'CSM_Account__c',
                           'CSM_Account_Plan__c',
                           'CSM_Play_Task__c',
                           'CSM_Play__c',
                           'CSM_Play__r.CSM_Display_Name__c',
                           'CSM_Play_Status__c',
                           'CSM_SuccessPlan_Play__c',
                           'CSM_SuccessPlan_Play__r.CSM_Display_Name__c'};
                           
		Set<String>tempSet = new Set<String>();
		List<String> queryStringList = new List<String>();
		tempSet.addAll(taskDefaultQueryFields);
		tempSet.addAll(queryList);
		queryStringList.addAll(tempSet);
        
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_DESCRIPTION, CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_SUBJECT, 
            CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_ACCTPLAN,
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_WHOID, REN_Constants.OBJ_T_REN_OPPORTUNITY,
            CSM_Constants.OBJ_T_TASK_STATE, CSM_Constants.OBJ_T_COMPLETED_DATE, CSM_Constants.OBJ_T_STATUS, CSM_Constants.OBJ_T_PLAY_STATUS,CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
            
             
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_DISPLAY_NAME};
                                                                                                   
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);
        	
        	String queryString = null;
        	
        	if (!queryStringList.isEmpty() && queryStringList.size() > 0) {
        		queryString = 'Select ';
        		
        		for (Integer idx = 1; idx <= queryStringList.size(); idx++) {
        			if (idx < queryStringList.size()) {
        				queryString += queryStringList[idx-1] + ',';
        			}
        			else if (idx == queryStringList.size()) {
        				queryString += queryStringList[idx-1];
        			}
        		}
        	}
        	queryString = String.escapeSingleQuotes(queryString) + ' FROM Task WHERE Id IN :taskIds LIMIT 5000'; 
        	tmplist = database.query(queryString);
            return tmplist;
    }             
    
    public static List<Task> getNotCompletedTasksByAccount(String accountId, String filter, String sortExpression, String sortDirection)
    {
        List<Task> tmplist = new List<Task>();
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE,  
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_DESCRIPTION, 
            CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_ACCTPLAN, CSM_Constants.OBJ_T_PLAY_STATUS,
            CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
            
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_DISPLAY_NAME};
                                                                                                    
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);  
        
        List<String> sppList = new List<String>{CSM_Constants.OBJ_SPP_PLAYBOOK};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAY, sppList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> appList = new List<String>{CSM_Constants.OBJ_SPPB_PLAYBOOK};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAYBOOK, appList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> pbList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_ID, CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOK, pbList, CSM_Constants.DML_OPERATION_READ);                                                                                          
                                                                                                    
			Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ACTIONS); 
        	String sortExpressionEscp = '';
        	String sortDirectionEscp = '';
        	if(sortExpression != null){
        		sortExpressionEscp = String.escapeSingleQuotes(sortExpression);
        	}
        	if(sortDirection != null){
        		sortDirectionEscp = String.escapeSingleQuotes(sortDirection);
        	}
        	String orderByStr = sortExpressionEscp + ' ' + sortDirectionEscp;
                //List<Opportunity> opptList = [Select Id From Opportunity Where AccountId=:accountId];
                String soql = 'SELECT id, What.Type, CSM_Account_Plan__r.CSM_AccountId__c, activitydate, subject, whatid, CSM_Account__c, '+
                                'CSM_Account_Plan__r.CSM_AccountId__r.Name, '+
                                'CSM_Risk_Reason__c, CSM_Account_Plan__c, what.name, ownerid, Owner.Name, status, CSM_Task_State__c, '+ 
                                'CSM_Play__c, Description, CSM_Completed_Date__c, CSM_Play_Task__c, whoid, REN_Opportunity__c, '+
                                'CSM_Play__r.CSM_Display_Name__c, CSM_Play_Enter_Date__c, CSM_Play_Exit_Date__c, CSM_Play_Status__c, '+
                                'CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__r.CSM_Playbook__r.CSM_Display_Name__c ' +
                        'FROM Task '+
                        'WHERE isClosed = false AND WhatId=:accountId '//(WhatId=:accountId OR WhatId IN:opptList) 
                        + buildTaskWhereClause(filter) +
                        ' ORDER BY ' + orderByStr + ' LIMIT ' + limitVal;
                        
                tmplist = Database.query(soql);

        return tmplist;
        
    }
    
    
    public static List<Task> getNotCompletedTasksByAccountPlan(String accountId, String filter, String sortExpression, String sortDirection)
    {
        List<Task> tmplist = new List<Task>();
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE,  
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_PLAY, CSM_Constants.OBJ_T_DESCRIPTION, 
            CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_ACCTPLAN, CSM_Constants.OBJ_T_PLAY_STATUS,
            CSM_Constants.OBJ_T_TYPE, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
        
        String strRecord = '';
        if(CSM_Util.getRecordTypeExists(new Task())){
        	strRecord = ',RecordType.Name';
        	taskFieldList.add(CSM_Constants.OBJ_RECORD_TYPE);
        }
            
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_DISPLAY_NAME};
                                                                                                    
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);  
        
        List<String> sppList = new List<String>{CSM_Constants.OBJ_SPP_PLAYBOOK};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAY, sppList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> appList = new List<String>{CSM_Constants.OBJ_SPPB_PLAYBOOK};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAYBOOK, appList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> pbList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_ID, CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOK, pbList, CSM_Constants.DML_OPERATION_READ);                                                                                         
                                                                                                    
			Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ACTIONS); 
        	String sortExpressionEscp = '';
        	String sortDirectionEscp = '';
        	if(sortExpression != null){
        		sortExpressionEscp = String.escapeSingleQuotes(sortExpression);
        	}
        	if(sortDirection != null){
        		sortDirectionEscp = String.escapeSingleQuotes(sortDirection);
        	}
        	
        	List<CSM_Account_Plan__c> successPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, accountId);
        	        	
        	if (successPlanList != null && !successPlanList.isEmpty()) {
        		
	        	String orderByStr = sortExpressionEscp + ' ' + sortDirectionEscp;
	                String soql = 'SELECT id, What.Type, CSM_Account_Plan__r.CSM_AccountId__c, format(activitydate), subject, whatid, CSM_Account__c, '+
	                                'CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_SuccessPlan_Play__r.CSM_Play__c, '+
	                                'CSM_Risk_Reason__c, CSM_Account_Plan__c, what.name, ownerid, Owner.Name, status, CSM_Task_State__c, '+ 
	                                'CSM_Play__c, Description, format(CSM_Completed_Date__c), CSM_Play_Task__c, whoid, REN_Opportunity__c, '+
                                    'CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__r.CSM_Playbook__r.CSM_Display_Name__c, ' +
	                                'CSM_Play__r.CSM_Display_Name__c, format(CSM_Play_Enter_Date__c), format(CSM_Play_Exit_Date__c), CSM_Play_Status__c,Type '+ strRecord
	                       + ' FROM Task '+
	                        'WHERE isClosed = false AND CSM_Account_Plan__c IN:successPlanList '+
	                        //+ buildTaskWhereClause(filter) +
	                        ' ORDER BY ' + orderByStr + ' LIMIT ' + limitVal;
	                        
	                system.debug(' finsoq- ' + soql);
	                tmplist = Database.query(soql);
        	}

        return tmplist;
    }     


    public static List<Task> getSPPLsForNotCompletedTasks(Set<Id> spplIds){
        List<Task> tmplist = new List<Task>();
        
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);

		tmplist = [select Id,CSM_SuccessPlan_Play__c from Task where isClosed = false and CSM_SuccessPlan_Play__c in: spplIds and CSM_SuccessPlan_Play__r.CSM_Play_Outcome__c = null];       
    
    	return tmplist;
    }

    private static String buildTaskWhereClause(String filter){
        String whereClause = '';
        if(String.isNotBlank(filter) && !CSM_Constants.TASK_FILTER_OPTION_ALL.equals(filter)){
            if(CSM_Constants.TASK_FILTER_OPTION_CONT_TASKS.equals(filter)){
                whereClause = whereClause + 'AND Type=\'Meeting\' AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_EMAIL_TASKS.equals(filter)){
                whereClause = whereClause + 'AND Type=\'Email\' AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_OTHER_TASKS.equals(filter)){
                whereClause = whereClause + 'AND (Type!=\'Email\'  AND Type!=\'Meeting\'  AND Type!=\'Call\') AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_PC_TASKS.equals(filter)){
                whereClause = whereClause + 'AND Type=\'Call\' AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_RT_ACCOUNT.equals(filter)){
                whereClause = whereClause + 'AND What.Type=\'Account\' AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_RT_OPPORTUNITY.equals(filter)){
                whereClause = whereClause + 'AND What.Type=\'Opportunity\' AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_HASPLAY.equals(filter)){
                whereClause = whereClause + 'AND CSM_Play__c != null';
            }else if(CSM_Constants.TASK_FILTER_OPTION_UNDETERMINEDPLAY.equals(filter)){
                whereClause = whereClause + 'AND CSM_Play__c = null';
            }
        }
        return whereClause;
    }
     
    public static List<Task> getTasksByAccountAndAccountPlan(String accountId, String accountPlanId)
    {
        List<Task> tmplist = new List<Task>();
        system.debug('account Id in Task $$ ' + accountId + ' ' + accountPlanId);
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_RISK_REASON,
            CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_ACTIVITYDATE, 
            CSM_Constants.OBJ_T_ACCOUNTID, CSM_Constants.OBJ_T_WHATID, CSM_Constants.OBJ_T_DESCRIPTION, 
            CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_PLAY, 
            CSM_Constants.OBJ_T_ACCTPLAN, CSM_Constants.OBJ_T_STATUS, CSM_Constants.OBJ_T_TYPE,
            CSM_Constants.OBJ_T_IS_CLOSED, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
           
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_DISPLAY_NAME};
                                                                                                   
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);
        
        List<String> sppList = new List<String>{CSM_Constants.OBJ_SPP_PLAYBOOK};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAY, sppList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> appList = new List<String>{CSM_Constants.OBJ_SPPB_PLAYBOOK};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAYBOOK, appList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> pbList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_ID, CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOK, pbList, CSM_Constants.DML_OPERATION_READ); 
        
        	//
        	if(accountId != null || accountPlanId != null) {
	        	String queryString = 'SELECT id, activitydate, subject, whatid, CSM_Account__c, CSM_Account_Plan__r.CSM_AccountId__r.Name,' +
	                            'CSM_Risk_Reason__c, CSM_Account_Plan__c, what.name, ownerid, status, CSM_Task_State__c, ' +  
	                            'CSM_Play__c, Description, CSM_Completed_Date__c, REN_Opportunity__c, Type, createdDate, '+ 
	                            'CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__r.CSM_Playbook__r.CSM_Display_Name__c, ' +
	                            'CSM_Play__r.CSM_Display_Name__c, IsClosed FROM Task '; 
	           // if(accountId !=  null && accountPlanId != null)
	            /*if(String.isNotBlank(accountId)  && String.isNotBlank(accountPlanId))
	            {
	            	queryString += ' WHERE whatId = :accountId or whatId = :accountPlanId ';
	            } 
	            //else if (accountId != null && accountPlanId == null)
	            else if (String.isNotBlank(accountId)  && String.isBlank(accountPlanId))
	            {
	            	queryString += ' WHERE whatId = :accountId ';
	            }
	            //else if (accountId == null && accountPlanId != null)
	            else if (String.isBlank(accountId) && String.isNotBlank(accountPlanId))
	            {
	            	queryString += ' WHERE whatId  :accountPlanId ';
	            }*/
	            
        		List<CSM_Account_Plan__c> successPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(accountPlanId, accountId);
        		
	        	if (successPlanList != null && !successPlanList.isEmpty()) {
	        		queryString += ' WHERE CSM_Account_Plan__c IN:successPlanList'; 
	        	}        		
	            
	            queryString += '  order by isclosed desc limit 500';
				system.debug('query string task $$ ' + queryString);
	    		tmpList = Database.query(queryString);
	    		system.debug('tmpList in dataAccess $$ ' + tmpLIst);
	        	
	            return tmplist;
        	}
        
        return tmplist;
    } 
    
    public static void createTasks(List<Task> taskList, Boolean isFollowupTask)
    {
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_T_PLAY, 
        	CSM_Constants.OBJ_T_PLAY_TASK, CSM_Constants.OBJ_T_ACCTPLAN, CSM_Constants.OBJ_T_REN_OPP, 
        	CSM_Constants.OBJ_T_OWNERID, CSM_Constants.OBJ_T_WHOID, CSM_Constants.OBJ_T_WHATID, 
        	CSM_Constants.OBJ_T_ACTIVITYDATE, CSM_Constants.OBJ_T_SUBJECT, CSM_Constants.OBJ_T_TYPE,
        	CSM_Constants.OBJ_T_DESCRIPTION,CSM_Constants.OBJ_T_STATUS, CSM_Constants.OBJ_T_RISK_REASON,
        	CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY,CSM_Constants.OBJ_T_ACCOUNT,CSM_Constants.OBJ_T_COMPLETED_DATE};
        	
       
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_INSERT);
        
        Boolean doInsert = true;
        
        if(isFollowupTask) {
	        for(SObject tsk: taskList){
				if(CSM_Util.getRecordTypeExists(new Task())){
					if((String)tsk.get('RecordTypeId') == '' || (String)tsk.get('RecordTypeId') == null){
						doInsert = false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.CSM_LBL_INVALID_RECORD_TYPE));
					}
				}					
	        }
        }
        if(doInsert){
        	insert taskList;        
        }
    }
    /*
	public static Database.queryLocator getQueryLocatorTaskBatch()
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY,CSM_Constants.OBJ_T_IS_CLOSED};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		String namespace = CSM_Util.getNameSpace();
				
		//String queryStr = 'SELECT Id,isClosed, ' + namespace +'CSM_SuccessPlan_Play__c,' + namespace +'CSM_SuccessPlan_Play__r.' + namespace +'CSM_Play_Outcome__c FROM Task  order by ' + namespace +'CSM_SuccessPlan_Play__c';
		String queryStr = 'select id, ( select Id, isClosed from ' + namespace +' Related_Activities__r)  from ' + namespace +'CSM_SuccessPlan_Play__c where ' + namespace +'CSM_Play_Outcome__c = null or '  + namespace +'CSM_Play_Outcome__c = \'\'';
				
		return Database.getQueryLocator(queryStr);
		//return Database.getQueryLocator([Select (Select Id, IsClosed From Related_Activities__r) From CSM_SuccessPlan_Play__c ]);
		
	} */
	
	/*public static List<Task> getClosedTasksBatch(List<String> planPlayIdList)
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY,CSM_Constants.OBJ_T_IS_CLOSED};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		String namespace = CSM_Util.getNameSpace();
				
		String queryStr = 'SELECT Id,' + namespace +'CSM_SuccessPlan_Play__c'  + ' FROM Task where  ' + namespace +'CSM_SuccessPlan_Play__c in:planPlayIdList '  + ' and isClosed= true order by ' + namespace +'CSM_SuccessPlan_Play__c';

		return Database.query(queryStr);
	}	*/
		
    public static List<Task> getTasksForSPPL(Set<Id>spPLIds) {
    	List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY,CSM_Constants.OBJ_T_IS_CLOSED};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, fieldList, CSM_Constants.DML_OPERATION_READ);
		
    	List<Task> spPLtasks = [SELECT Id, Status ,isClosed, CSM_Risk_Reason__c , CSM_Task_State__c, CSM_Play__c, REN_Opportunity__c,
	                                ActivityDate, WhatId, WhoId, CSM_Play_Exit_Date__c, CSM_Play_Status__c, Description, 
	                                CSM_Completed_Date__c, CSM_SuccessPlan_Play__c, CSM_SuccessPlan_Play__r.CSM_Play_Outcome__c 
	                                FROM Task WHERE CSM_SuccessPlan_Play__c IN : spPLIds order by CSM_SuccessPlan_Play__c LIMIT 5000]; // AND isClosed = false
        return spPLtasks;
    }


    public static List<Task> getTasksForSPPLRefresh(Set<String> spPLIds) {
    	List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, fieldList, CSM_Constants.DML_OPERATION_READ);
		
    	List<Task> spPLtasks = [select Id,csm_successplan_play__c from Task where  csm_successplan_play__c in:spPLIds]; // AND isClosed = false
        return spPLtasks;
    }


    
    public static List<Task> getSSPLForSelectedTask(Set<Id> taskIdSet){
    	List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, fieldList, CSM_Constants.DML_OPERATION_READ);
    	List<Task> TaskSPPL = [select Id, CSM_SuccessPlan_Play__c from Task where Id in : taskIdSet];
    	return TaskSPPL;
   	}
    
    public static List<RecordType> getRecordTypeTask (){
    	List<RecordType> RecordTypeTask = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Task'];
    	return RecordTypeTask;
    }
    
    public static List<Taskstatus> getTaskStatus(){
    	List<Taskstatus> TaskStatus = [Select Id, MasterLabel From TaskStatus Where IsClosed = true];
    	return TaskStatus;
    }
    
    /*public static Set<String> getIsClosedStatusValues() {
    	Set<String> taskClosedStatusSet = new Set<String>();
   		for(TaskStatus ts: [select MasterLabel from TaskStatus WHERE IsClosed=TRUE]){
		    taskClosedStatusSet.add(ts.MasterLabel);
		}
		return taskClosedStatusSet;
    }*/
    
    public static Set<String> taskClosedStatusSet {
		get{
			if(taskClosedStatusSet == null){
				taskClosedStatusSet = new Set<String>();
				for(TaskStatus ts: [select MasterLabel from TaskStatus WHERE IsClosed=TRUE]){
				    taskClosedStatusSet.add(ts.MasterLabel);
				}
			}
			return taskClosedStatusSet;
		}
		private set;
	} 
	// Method Code Added for US2663 and US2567
	public static List<Task> getTasksByWhoId(set<Id> leadSet)
    {
    	List<Task> taskList = new List<Task>();
       	String namespace = CSM_Util.nameSpacePrefixSolnExtn;
        
        List<String> taskFieldList = new List<String>{namespace +'Account__c'};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
        string quesrystr ;
        
        quesrystr = 'select whoid,Id,' + namespace + 'Account__c from task where  whoid  in : leadSet limit 10000';
        
        return Database.Query(quesrystr);
    }
    // Method code added for US2557 
    public static List<Lead> getLeadIds(Set<Id> setLeadId){
    	
    	String namespace = CSM_Util.nameSpacePrefixSolnExtn;
        
        List<String> leadFieldList = new List<String>{namespace +'Lead_Lookup_Account_1__c'};
        
        CSM_Util.checkCRUD_FLS('Lead', leadFieldList, CSM_Constants.DML_OPERATION_READ);
        string quesrystr ;
        
        quesrystr = 'Select Id,' +namespace+ 'Lead_Lookup_Account_1__c From Lead Where Id In : setLeadId limit 1';
        
        return Database.Query(quesrystr);
    }
    public static List<Task> updatetaskAcc(List<Task> taskList,Map<Id, Lead> leadMap){
    	List<Task> taskListToUpdate = new List<Task>();
    	String namespace = CSM_Util.nameSpacePrefixSolnExtn;
    	for(Task currentTask : taskList){
			if (leadMap.get(currentTask.whoid).get(namespace + 'Lead_Lookup_Account_1__c') != null){
				currentTask.put(namespace + 'Account__c',leadMap.get(currentTask.whoid).get(namespace + 'Lead_Lookup_Account_1__c'));
				taskListToUpdate.add(currentTask);
			}
	  	}
		return taskListToUpdate;
    }
    
    public static List<SObject> getTaskListByPartnerOpp(Set<Id> poIdSet) {
		List<String> taskFieldList = new List<String>{'CSM_Related_Opportunity__c','Status','Type','CHL_Related_Partner_Opportunity__c','CHL_Status_Update__c','Description'};
		CSM_Util.checkCRUD_FLS('Task', taskFieldList, CSM_Constants.DML_OPERATION_READ);
		String queryString ='SELECT CreatedBy.name, CreatedById, CreatedDate,Type,CHL_Related_Partner_Opportunity__c,CHL_Status_Update__c,Description FROM Task where CHL_Related_Partner_Opportunity__c IN :poIdSet and CHL_Status_Update__c = true Order by LastmodifiedDate DESC LIMIT 1000';
		List<Task> taskList = Database.query(queryString);
		return taskList;
	}
	
    public static void updateLeadTasks(List<Task> taskListToUpdate){
    	String namespace = CSM_Util.nameSpacePrefixSolnExtn;
    	List<String> taskFieldList = new List<String>{namespace +'Account__c'};
   
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_UPDATE); 
        update taskListToUpdate;
    	
    }// End 
    
    private class invalidDataException extends Exception{}
         
}