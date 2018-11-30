public with sharing class CSM_PlayResultHistoryDataAccess {
	public static void createPlayResultHistory(List<CSM_Play_Result_History__c> playResultHistoryList)
	{
		
		List<String> playHistoryList = new List<String>{CSM_Constants.OBJ_PRH_ACCOUNT_ID, 
			CSM_Constants.OBJ_PRH_ASSIGNEE, CSM_Constants.OBJ_PRH_ENTER_DATE, CSM_Constants.OBJ_PRH_ENTER_DATE,
			CSM_Constants.OBJ_PRH_EXIT_DATE, CSM_Constants.OBJ_PRH_FAILED, CSM_Constants.OBJ_PRH_FAILED_DESC,
			CSM_Constants.OBJ_PRH_PLAYBOOK_DESC, CSM_Constants.OBJ_PRH_PLAYBOOK_EXT_ID, 
			CSM_Constants.OBJ_PRH_PLAYBOOK_NAME, CSM_Constants.OBJ_PRH_PLAY_DESC, CSM_Constants.OBJ_PRH_PLAY_EXT_ID,
			CSM_Constants.OBJ_PRH_PLAY_NAME, CSM_Constants.OBJ_PRH_PLAY_OBJECT, CSM_Constants.OBJ_PRH_PLAY_RESULT,
			CSM_Constants.OBJ_PRH_PROCESSED, CSM_Constants.OBJ_PRH_RES_STATUS, CSM_Constants.OBJ_PRH_SUBSCRIPTION, CSM_Constants.OBJ_PR_PLAYBOOK_DESC};
	
	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PRH, playHistoryList, CSM_Constants.DML_OPERATION_INSERT);
	    
	    insert playResultHistoryList;
	}
}