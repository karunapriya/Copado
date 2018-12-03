public with sharing class CSM_TaskProcessingDataAccess {
 
    public static List<CSM_Task_Processing__c> getActiveTasks(Set<String> validAccountPlayIdsList, Set<Id> accountList)
    {
        List<CSM_Task_Processing__c> tmpList = new List<CSM_Task_Processing__c>();
        
        List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_TASK, CSM_Constants.OBJ_TASK_PROCESSING_SUCCESS_PLAN, 
            CSM_Constants.OBJ_TASK_PROCESSING_PLAY, CSM_Constants.OBJ_TASK_PROCESSING_PLAY_TASK, CSM_Constants.OBJ_TASK_PROCESSING_STATUS};
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
        List<String> criteriaFieldList2 = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT};
        List<String> noAccessFieldList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList2);
        //If can access all fields, query play task and return results                
        if (noAccessFieldList.isEmpty() && noAccessFieldList2.isEmpty())
        {
        
            tmpList = [select id, CSM_Play__c, CSM_PlayTask__c, CSM_Status__c, CSM_Success_Plan__c, 
                            CSM_Success_Plan__r.CSM_AccountId__c, CSM_Task_Id__c
                            from CSM_Task_Processing__c 
                            where CSM_Success_Plan__r.CSM_AccountId__c in :accountList
                            //MF made change
                            and CSM_Play__c in : validAccountPlayIdsList
                            limit 10000];
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessFieldList)};
             String[] arguments2 = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList2)};
             arguments.addall(arguments2);
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
            
        } 
  
        return tmpList; 
    }

    public static void updateTaskProcessing(List<CSM_Task_Processing__c> taskProcessingList){
     	List<String> fieldList = new List<String>{'CSM_SuccessPlan_Play__c'};
     	CSM_Util.checkCRUD_FLS('CSM_Task_Processing__c', fieldList, CSM_Constants.DML_OPERATION_UPDATE);
     	if(taskProcessingList!= null && !taskProcessingList.isEmpty()){
     		update taskProcessingList;
     	}
		
    }
    
    public static boolean createTaskProcessing(List<Task> taskList)
    {
        
        List<CSM_Task_Processing__c> tmpProcessingList = new List<CSM_Task_Processing__c>();
        
        for(Task t : taskList)
        {
            CSM_Task_Processing__c newProcessing = new CSM_Task_Processing__c();
            newProcessing.CSM_Success_Plan__c = t.CSM_Account_Plan__c;
            newProcessing.CSM_PlayTask__c = t.CSM_Play_task__c;
            newProcessing.CSM_Play__c = t.CSM_Play__c;
            newProcessing.CSM_SuccessPlan_Play__c = t.CSM_SuccessPlan_Play__c;
            
            //newProcessing.CSM_Account_Plan__c = t.CSM_Account_Plan__c;
            // TODO: remove below piece of code once data model issue related to Task Processing object is resolved.
            //if(newProcessing.CSM_Success_Plan__c == null){
            //  newProcessing.CSM_Succuess_Plan__c = [Select Id From CSM_Account_Plan__c Limit 1].Id;
            //}
            newProcessing.CSM_Task_Id__c = t.id;
            newProcessing.CSM_Status__c = 'Pending';
            tmpProcessingList.add(newProcessing);
            
        }
        
        
        List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_TASK, CSM_Constants.OBJ_TASK_PROCESSING_SUCCESS_PLAN, 
                CSM_Constants.OBJ_TASK_PROCESSING_PLAY, CSM_Constants.OBJ_TASK_PROCESSING_PLAY_TASK, CSM_Constants.OBJ_TASK_PROCESSING_STATUS,
                CSM_Constants.OBJ_TASK_PROCESSING_SUCCESS_PLAN_PLAY};
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_INSERT, criteriaFieldList);
        
        if (noAccessFieldList.isEmpty())
        {
            insert tmpProcessingList;
            
            return true;
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, arguments));
        } 

        return false;
    }
    
    public static void createTaskProcessing(List<Task> taskList, Map<String, CSM_Play_Result__c> accountPlayResult) {
        List<CSM_Play_Result__c> failedPlayResult = new List<CSM_Play_Result__c>();
        
        List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_TASK, CSM_Constants.OBJ_TASK_PROCESSING_SUCCESS_PLAN, 
            CSM_Constants.OBJ_TASK_PROCESSING_PLAY, CSM_Constants.OBJ_TASK_PROCESSING_PLAY_TASK, CSM_Constants.OBJ_TASK_PROCESSING_STATUS};
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_INSERT, criteriaFieldList);
        
        if (noAccessFieldList.isEmpty())
        {
            List<CSM_Task_Processing__c> tmpProcessingList = new List<CSM_Task_Processing__c>();
            for(Task t : taskList)
            {
                CSM_Task_Processing__c newProcessing = new CSM_Task_Processing__c();
                newProcessing.CSM_PlayTask__c = t.CSM_Play_task__c;
                newProcessing.CSM_Play__c = t.CSM_Play__c;
                newProcessing.CSM_Success_Plan__c = t.CSM_Account_Plan__c;
                newProcessing.CSM_Task_Id__c = t.id;
                newProcessing.CSM_Status__c = 'Pending';
            	newProcessing.CSM_Play_Result_Id__c = t.CSM_Play_Result_Id__c;
            	newProcessing.CSM_SuccessPlan_Play__c = t.CSM_SuccessPlan_Play__c;
                tmpProcessingList.add(newProcessing);
            }   
            Database.SaveResult[] srList = database.insert(tmpProcessingList, false);
            Integer i = 0;
            Task t;
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    String msg = 'The following error has occurred - ';                    
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        msg += err.getStatusCode() + ': ' + err.getMessage();
                        msg += ' - Tasks Processing fields that affected this error: ' + err.getFields();
                    }
                    t = taskList[i];
                    
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
                        pr.CSM_Failed_Description__c = 'Permission for following task fields are not set - '+String.valueOf(noAccessFieldList);
                        pr.CSM_Failed__c = true;
                        failedPlayResult.add(pr);
                    }*/
                }
                i++;
            }
        }
        else {
            // Iterate through each returned result
            for (Task t : taskList) {
            	
                //iterate throught the accountPlayResult to find the Play Result containing the failed CSM_Play_Result_Id__c
	            for(CSM_Play_Result__c pr :accountPlayResult.values()) {                                       
	                if(pr.CSM_Play_Result_Id__c != null && t.CSM_Play_Result_Id__c != null) {
						if (pr.CSM_Play_Result_Id__c.equals(t.CSM_Play_Result_Id__c)) {
	                        pr.CSM_Failed_Description__c = 'Permission for following task fields are not set - '+String.valueOf(noAccessFieldList);
	                        pr.CSM_Failed__c = true;
	                        failedPlayResult.add(pr);
						}
						break;
	                }   
	            }            	
           
                /*if (accountPlayResult.containsKey(t.CSM_Account__c)){
                    CSM_Play_Result__c pr = accountPlayResult.get(t.CSM_Account__c);
                    pr.CSM_Failed_Description__c = 'Permission for following task fields are not set - '+String.valueOf(noAccessFieldList);
                    pr.CSM_Failed__c = true;
                    failedPlayResult.add(pr);
                    
                }else if(accountPlayResult.containsKey(t.REN_Opportunity__c)){
                    CSM_Play_Result__c pr = accountPlayResult.get(t.REN_Opportunity__c);
                    pr.CSM_Failed_Description__c = 'Permission for following task fields are not set - '+String.valueOf(noAccessFieldList);
                    pr.CSM_Failed__c = true;
                    failedPlayResult.add(pr);
                }*/
            }

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
    
    public static List<CSM_Task_Processing__c> getTasksById(List<CSM_Play_Task__c> playtaskList)
    {
		return getTasksById(playtaskList, null);
    }
    
    public static List<CSM_Task_Processing__c> getTasksById(List<CSM_Play_Task__c> playtaskList, Set<String> setAccountsProcessed)
    {
        
        List<CSM_Task_Processing__c> tmpList = new List<CSM_Task_Processing__c>();
        
        List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_TASK, CSM_Constants.OBJ_TASK_PROCESSING_SUCCESS_PLAN, 
            CSM_Constants.OBJ_TASK_PROCESSING_PLAY, CSM_Constants.OBJ_TASK_PROCESSING_PLAY_TASK};
        List<String> criteriaFieldList2 = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT};
        List<String> criteriaFieldListPlay = new List<String>{CSM_Constants.OBJ_PLAY_EXTERNAL_ID, CSM_Constants.OBJ_PLAY_AUTO_COMPLETED_AUTOMATED_TASK};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
        List<String> noAccessFieldList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList2);
        List<String> noAccessFieldList3 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldListPlay);
        //If can access all fields, query play task and return results                
        if (noAccessFieldList.isEmpty() && noAccessFieldList2.isEmpty() && noAccessFieldList3.isEmpty())
        {       
        	if (setAccountsProcessed!=null){
	            tmpList = [SELECT CSM_PlayTask__c,
	                            CSM_Play__r.CSM_External_Id__c,
	                            CSM_Success_Plan__r.CSM_AccountId__c,
	                            CSM_Success_Plan__c,
	                            CSM_Task_Id__c,
	                            CSM_PlayTask__r.Id,
	                            CSM_Play_Result_Id__c
	                       FROM CSM_Task_Processing__c 
	                       WHERE CSM_PlayTask__c IN :playtaskList
	                       AND CSM_Success_Plan__r.CSM_AccountId__c IN :setAccountsProcessed 
	                       AND CSM_Play__r.CSM_Automated__c = true LIMIT 10000];
        	} else {
	            tmpList = [SELECT CSM_PlayTask__c,
	                            CSM_Play__r.CSM_External_Id__c,
	                            CSM_Success_Plan__r.CSM_AccountId__c,
	                            CSM_Success_Plan__c,
	                            CSM_Task_Id__c,
	                            CSM_PlayTask__r.Id,
	                            CSM_Play_Result_Id__c
	                       FROM CSM_Task_Processing__c 
	                       WHERE CSM_PlayTask__c IN :playtaskList 
	                       AND CSM_Play__r.CSM_Automated__c = true LIMIT 10000];
        	}
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessFieldList)};
             String[] arguments2 = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList2)};
             String[] arguments3 = new String[] {CSM_Constants.OBJ_PLAY + ':'+String.valueOf(noAccessFieldList3)};
             arguments.addall(arguments2);
             arguments.addall(arguments3);
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

        return tmpList; 
    }
    
    public static void updateTaskProcessingStatus(Set<Id> taskSet)
    {
        
        List<CSM_Task_Processing__c> tmpList = new List<CSM_Task_Processing__c>();

        List<String> tpFieldList = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_STATUS};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
            CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_READ, tpFieldList);
        //If can access all fields, query play task and return results                
        if (noAccessFieldList.isEmpty())
        {       
            tmpList = [SELECT CSM_Status__c
                       FROM CSM_Task_Processing__c 
                       WHERE CSM_Task_Id__c IN :taskSet 
                       AND CSM_Status__c != :CSM_Constants.TASK_PROCESSING_COMPLETE LIMIT 10000 ];
            for(CSM_Task_Processing__c t : tmpList)
            {
                t.csm_status__c = CSM_Constants.TASK_PROCESSING_COMPLETE;
            }
            List<String> noUpdateFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
            CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_UPDATE, tpFieldList);
            if (noUpdateFieldList.isEmpty())
            { 
                update tmpList;
            }
            else
            {
                String[] arguments = new String[] {CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
            }
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

    } 
    
	public static Database.queryLocator getQueryLocatorTaskBatch()
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID, CSM_Constants.OBJ_TASK_PROCESSING_TASK,CSM_Constants.OBJ_TASK_PROCESSING_SUCCESS_PLAN,CSM_Constants.OBJ_TASK_PROCESSING_PLAY,CSM_Constants.OBJ_PLAYBOOKPLAY};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK_PROCESSING, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		String namespace = CSM_Util.getNameSpace();
				
		String queryStr = 'SELECT Id,' + namespace +'CSM_Success_Plan__c,'  + namespace +'CSM_Play__c,' + namespace + 'CSM_Task_Id__c,' + namespace + 'CSM_PlaybookPlay__r.csm_playbook__c FROM '+ namespace + 'csm_task_processing__c order by createddate asc';

		return Database.getQueryLocator(queryStr);
	}	
    
    public static List<CSM_Task_Processing__c> getTskProcRecordsWithSPPlay(List<String> spPlist){
    	List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID};
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK_PROCESSING, fieldList, CSM_Constants.DML_OPERATION_READ);
    	List<CSM_Task_Processing__c> tskProLst = [Select id from CSM_Task_Processing__c where CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__c IN: spPlist LIMIT 10000] ;
    	
    	return tskProLst;
    }
    
    public static List<CSM_Task_Processing__c> getTskProcRecordsForDelete(List<String> spplList){
    	List<String> fieldList = new List<String>{CSM_Constants.OBJ_T_ID};
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK_PROCESSING, fieldList, CSM_Constants.DML_OPERATION_READ);
    	List<CSM_Task_Processing__c> tskProLst = [Select id from CSM_Task_Processing__c where CSM_SuccessPlan_Play__c IN: spplList LIMIT 10000] ;
    	
    	return tskProLst;
    }

    public static void deleteTaskProcRecords(List<CSM_Task_Processing__c> tskProLst){
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK_PROCESSING, null, CSM_Constants.DML_OPERATION_DELETE);
    	delete tskProLst;
    }        
}