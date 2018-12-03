/**
* @author         Mike Faust (mike@comitydesigns.com)
* @date           08.22.2014
* @description    CSM_PlayTaskDataAccess class performs Data Access for  Play Task Object
*/

public with sharing class CSM_PlayTaskDataAccess {
	
	/**
	 * @description populates the play task information for given playId
	 * @return List<CSM_Play_Task__c>
	 */
	public static List<CSM_Play_Task__c> populatePlayTaskInformation(String playId)
	{
		List<CSM_Play_Task__c> taskList = new List<CSM_Play_Task__c>();
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_TASK_ASSIGN, CSM_Constants.OBJ_PLAY_TASK_DAYS_DUE, 
			CSM_Constants.OBJ_PLAY_TASK_DESCRIPTION, CSM_Constants.OBJ_PLAY_TASK_PLAY, CSM_Constants.OBJ_PLAY_TASK_ACTIVE, 
			CSM_Constants.OBJ_PLAY_TASK_TYPE, CSM_Constants.CSM_FLD_REC_TYPE};
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_TASK, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
		//If can access all fields, query play task and return results                
        if (noAccessFieldList.isEmpty())
        {
        	taskList = [SELECT id, Name, CSM_Play__c, CSM_Days_Until_Due__c, CSM_Description__c, CSM_Assign_To__c, CSM_IsActive__c, CSM_Type__c,
        						CSM_Record_Type__c	
        					from CSM_Play_Task__c
							where CSM_Play__c = :playId
							limit 100];
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAY_TASK + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return 	taskList;
	}
	
	/**
	 * @description saves the play tasks
	 * @return List<CSM_Play_Task__c>
	 */
	public static List<CSM_Play_Task__c> savePlayTask(List<CSM_Play_Task__c> playTaskList)
	{
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_TASK_ASSIGN, CSM_Constants.OBJ_PLAY_TASK_DAYS_DUE,
			CSM_Constants.OBJ_PLAY_TASK_DESCRIPTION, //CSM_Constants.OBJ_PLAY_TASK_PLAY, 
			CSM_Constants.OBJ_PLAY_TASK_ACTIVE,
			CSM_Constants.OBJ_PLAY_TASK_TYPE, CSM_Constants.CSM_FLD_REC_TYPE};
			CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAY_TASK, criteriaFieldList, CSM_Constants.DML_OPERATION_UPSERT);
            upsert playTaskList;
        	return 	playTaskList;
	}
	
	/**
	 * @description Deletes the play tasks
	 * @return boolean
	 */
	public static boolean deletePlayTask(List<CSM_Play_Task__c> playTaskList)
	{
        boolean isSuccess = false;
        //will throw error if we cannot delete
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_TASK, 
                CSM_Constants.DML_OPERATION_DELETE, null);
        
        List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_PLAY};
        List<String> noAccessFieldList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK_PROCESSING, 
                CSM_Constants.DML_OPERATION_READ, fcFieldList2);
        if (playTaskList != null) {
        	Set<String> playIds = new Set<String>();
			for (CSM_Play_Task__c pt : playTaskList) {
				if (pt.CSM_Play__c != null) {
					playIds.add(pt.CSM_Play__c);
				}
			}
			if (playIds!=null) {
				if (noAccessFieldList2.isEmpty())
				{
		        	List<CSM_Task_Processing__c> tpList = [SELECT Id FROM CSM_Task_Processing__c WHERE CSM_Play__c IN: playIds limit 1000];
		        	
			        // No need to check if list is empty, an AccessController will throw exception is user cannot delete
			        if (tpList==null || tpList.isEmpty()) {
			    		delete playTaskList;
			    		isSuccess = true;
			        }
				}
				else
				{
			    	String[] arguments = new String[] {CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessFieldList2)};
		    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
		    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
			    }
			}
        }
        return 	isSuccess;
	}
	
	/**
	 * @description get active tasks
	 * @return List<CSM_Play_task__c>
	 */
	public static List<CSM_Play_Task__c> getActiveTasks(Set<String> playIdList)
	{
		List<CSM_Play_Task__c> tmpList = new List<CSM_Play_Task__c>();
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_TASK_ASSIGN, CSM_Constants.OBJ_PLAY_TASK_DAYS_DUE,
			CSM_Constants.OBJ_PLAY_TASK_DESCRIPTION, CSM_Constants.OBJ_PLAY_TASK_PLAY, CSM_Constants.OBJ_PLAY_TASK_ACTIVE, 
			CSM_Constants.OBJ_PLAY_TASK_TYPE,CSM_Constants.CSM_FLD_REC_TYPE};
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_TASK, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
			tmpList =  [select id, Name, CSM_Play__c, CSM_Assign_To__c, CSM_Days_Until_Due__c, CSM_Description__c, CSM_Type__c, CSM_Record_Type__c
						from CSM_Play_Task__c
						where CSM_IsActive__c = true
						and CSM_Play__c in :playIdList
						limit 5000];
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAY_TASK + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        return 	tmpList;
	} 
	
	/**
	 * @description get active and automated tasks
	 * @return List<CSM_Play_task__c>
	 */
	public static List<CSM_Play_Task__c> getActiveAutomatedTasks(Set<String> playSet)
	{
		List<CSM_Play_Task__c> tmpList = new List<CSM_Play_Task__c>();
		List<String> criteriaFieldListPlayTask = new List<String>{CSM_Constants.OBJ_PLAY_TASK_ASSIGN, CSM_Constants.OBJ_PLAY_TASK_DAYS_DUE,
			CSM_Constants.OBJ_PLAY_TASK_DESCRIPTION, CSM_Constants.OBJ_PLAY_TASK_PLAY, CSM_Constants.OBJ_PLAY_TASK_ACTIVE, CSM_Constants.OBJ_PLAY_TASK_TYPE};
		List<String> criteriaFieldListPlay = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_AUTOMATED,
			CSM_Constants.OBJ_PLAY_EXTERNAL_ID, CSM_Constants.OBJ_PLAY_AUTO_COMPLETED_AUTOMATED_TASK, CSM_Constants.OBJ_PLAY_AUTO_DISMISS_AUTOMATED_TASK};
			
        List<String> noAccessFieldPlayTaskList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_TASK, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldListPlayTask);
        List<String> noAccessFieldPlayList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldListPlay);
                
        if (noAccessFieldPlayTaskList.isEmpty() && noAccessFieldPlayList.isEmpty())
        {
			tmpList =  [SELECT Id, Name, 
							CSM_Play__r.CSM_Auto_Complete_Automated_Tasks__c,
							CSM_Play__r.CSM_Auto_Dismiss_Automated_Tasks__c,
							CSM_Assign_To__c,
							CSM_Days_Until_Due__c,
							CSM_Description__c,
					 		CSM_Play__c, 
					 		CSM_Type__c,
					 		CSM_Play__r.CSM_External_Id__c, 
					 		CSM_Play__r.CSM_IsActive__c/*,
					 		CSM_Playbook_Id__c*/
						FROM CSM_Play_Task__c
			   		   WHERE CSM_Play__r.CSM_External_Id__c IN :playSet AND CSM_IsActive__c = true AND
			   		   		CSM_Play__r.CSM_Automated__c = true AND CSM_Play__r.CSM_IsActive__c = true LIMIT 5000];
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAY_TASK + ':'+String.valueOf(noAccessFieldPlayTaskList) + CSM_Constants.OBJ_PLAY + ':'+String.valueOf(noAccessFieldPlayList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
	    
        return 	tmpList;
	}

}