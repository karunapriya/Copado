public with sharing class CSM_PlayResultDataAccess {

	/**
	 * @description get play results
	 * @return List<CSM_Play_Result__c>
	 */
	public static List<CSM_Play_Result__c> getPlayResultsById(List<CSM_Play_Result__c> newRecords)
	{
		List<CSM_Play_Result__c> tmpList = new List<CSM_Play_Result__c>();
		
		List<String> criteriaFieldListPlayTask = new List<String>{CSM_Constants.OBJ_PR_ID, CSM_Constants.OBJ_PR_ACCOUNT_ID,
			CSM_Constants.OBJ_PR_ASSIGNEE, CSM_Constants.OBJ_PR_ENTER_DATE, 
			CSM_Constants.OBJ_PR_EXIT_DATE, CSM_Constants.OBJ_PR_FAILED,
			CSM_Constants.OBJ_PR_FAILED_DESC, CSM_Constants.OBJ_PR_PLAYBOOK_DESC,
			CSM_Constants.OBJ_PR_PLAYBOOK_EXT_ID, CSM_Constants.OBJ_PR_PLAYBOOK_NAME,
			CSM_Constants.OBJ_PR_PLAY_DESC, CSM_Constants.OBJ_PR_PLAY_EXT_ID,
			CSM_Constants.OBJ_PR_PLAY_NAME, CSM_Constants.OBJ_PR_PLAYRESULT_ID,
			CSM_Constants.OBJ_PR_PLAY_OBJECT, CSM_Constants.OBJ_PR_PROCESSED,
			CSM_Constants.OBJ_PR_RES_STATUS, CSM_Constants.OBJ_PR_SUBSCRIPTION};
			
        List<String> noAccessFieldPlayTaskList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PR, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldListPlayTask);
                
        if (noAccessFieldPlayTaskList.isEmpty())
        {
			tmpList =  [SELECT CSM_Account_Id__c, 
							   CSM_Assignee__c, 
							   CSM_Enter_Date__c, 
							   CSM_Exit_Date__c, 
							   CSM_Failed__c, 
							   CSM_Failed_Description__c, 
							   CSM_Playbook_Description__c, 
							   CSM_Playbook_External_Id__c, 
							   CSM_Playbook_Name__c,
							   CSM_Play_Description__c, 
							   CSM_Play_External_Id__c, 
							   CSM_Play_Name__c, 
							   CSM_Play_Object__c, 
							   CSM_Play_Result_Id__c,
							   CSM_Processed__c, 
							   CSM_Resolution_Status__c, 
							   CSM_Subscription_Id__c 
						  FROM CSM_Play_Result__c 
						 WHERE Id IN : newRecords LIMIT 200];
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PR + ':'+String.valueOf(noAccessFieldPlayTaskList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
	
        return 	tmpList;
	}
	
	public static void updatePlayResults(List<CSM_Play_Result__c> updateResults)
	{
	    List<String> playResultFieldList = new List<String>{CSM_Constants.OBJ_PR_FAILED,
	    	CSM_Constants.OBJ_PR_FAILED_DESC, CSM_Constants.OBJ_PR_PROCESSED, 
	    	CSM_Constants.OBJ_PR_PLAYBOOK_NAME};
	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PR, playResultFieldList, CSM_Constants.DML_OPERATION_UPDATE);
	    update updateResults;
	}
}