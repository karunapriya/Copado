public with sharing class CSM_PlaybookPlayDataAccess {

	
	public static List<CSM_PlaybookPlay__c> populatePlaybookPlayInformation(String playbookId) {
		List<CSM_PlaybookPlay__c> playbookList = new List<CSM_PlaybookPlay__c>();
				
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_PLAYBOOK/*, CSM_Constants.OBJ_PLAY_ISACTIVE*/};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAYBOOKPLAY,
																								CSM_Constants.DML_OPERATION_READ, fcFieldList);
    	List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_DISPLAY_NAME, 
    												CSM_Constants.OBJ_PLAY_AUTOMATED, CSM_Constants.OBJ_PLAY_TASK_TOTAL};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAY, 
																									CSM_Constants.DML_OPERATION_READ, fcFieldList2);
       if (noAccessList.isEmpty() && noAccessList2.isEmpty())
    	{
    		if(playbookId!=null)
    		{							
    			playbookList = [SELECT id, CSM_Play__c, CSM_Playbook__c, CSM_Play__r.CSM_Display_Name__c, 
    							CSM_Play__r.CSM_IsActive__c, CSM_Play__r.CSM_Task_Total__c
								FROM CSM_PlaybookPlay__c 
								WHERE CSM_Playbook__c = :playbookId LIMIT 100];									
				
    		}
    	}
		else 
		{
    		String[] arguments = new String[] {(noAccessList!=null?CSM_CONSTANTS.OBJ_PLAYBOOKPLAY + ':'+String.valueOf(noAccessList):noAccessList2!=null?CSM_CONSTANTS.OBJ_PLAY + ':'+String.valueOf(noAccessList2):'')};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_DELETABLE, arguments));
    	    
		}

		return playbookList;
	}
	
	public static List<CSM_PlaybookPlay__c> getPlaybookPlaybyPlayBook(List<String> playbookLst) {
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_PLAYBOOK};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_PLAY_QUERY_CRIT};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAY, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<CSM_PlaybookPlay__c> pbPlayLst = [Select id,CSM_Play__c,CSM_Playbook__c,csm_play__r.CSM_Query_Criteria__c from CSM_PlaybookPlay__c where CSM_Playbook__c IN: playbookLst order by CSM_Playbook__c LIMIT 10000];
		
		return pbPlayLst;
	}
		
	public static Boolean addPlayToPlaybook(String playbookId, String playId) {
		List<String> fcFieldList = new List<String>{/*CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_PLAYBOOK*/};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, fcFieldList, CSM_Constants.DML_OPERATION_INSERT);
    	List<CSM_PlaybookPlay__c> pbPlays = [SELECT Id FROM CSM_PlaybookPlay__c WHERE CSM_Playbook__c =:playbookId AND CSM_Play__c =:playId LIMIT 1];
    	if (pbPlays==null || pbPlays.isEmpty()){
    		CSM_PlaybookPlay__c pbPlay = new CSM_PlaybookPlay__c();
    		pbPlay.CSM_Playbook__c = playBookId;
    		pbPlay.CSM_Play__c = playId;
    		//pbPlay.CSM_IsActive__c = true;
    		insert pbPlay;
    		return true;
    	}
		return false;        
	}
	
			
	public static Boolean removePlayFromPlaybook(String playbookId, String playId) {
		//check if we can delete from playbook play
		List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAYBOOKPLAY,
																								CSM_Constants.DML_OPERATION_DELETE, null);
																								
		//check if we can select from pbp and task processing
		List<String> pbpFieldList = new List<String>{CSM_Constants.OBJ_PBP_ID, CSM_Constants.OBJ_PBP_PLAYBOOK, CSM_Constants.OBJ_PBP_PLAY};
																						
		List<String> noAccessPbpFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAYBOOKPLAY,
																								CSM_Constants.DML_OPERATION_READ, pbpFieldList);
	    List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_TASK_PROCESSING_ID};
	    List<String> noAccessTaskFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TASK_PROCESSING,
																								CSM_Constants.DML_OPERATION_READ, taskFieldList);
																								
        if (noAccessPbpFieldList.isEmpty() && noAccessTaskFieldList.isEmpty())
        {
        	List<CSM_PlaybookPlay__c> pbPlays = [SELECT Id FROM CSM_PlaybookPlay__c 
        										WHERE CSM_Playbook__c =:playbookId AND CSM_Play__c =:playId LIMIT 1];
        	List<CSM_Task_Processing__c> tpList = [SELECT Id FROM CSM_Task_Processing__c WHERE CSM_Play__c =: playId AND CSM_Status__c = 'Pending' LIMIT 1];
        	
        	if (pbPlays!=null && !pbPlays.isEmpty() && (tpList == null || tpList.isEmpty())){
        		delete pbPlays;
        		return true;
        	} else {
				return false;
        	}    	
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAYBOOKPLAY + ':'+String.valueOf(noAccessPbpFieldList) + ' ' 
        	 	+ CSM_Constants.OBJ_TASK_PROCESSING + ':'+String.valueOf(noAccessTaskFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
	}
	public static List<CSM_PlaybookPlay__c> getPlaybookPlaysforPlay(String playId) {
		List<CSM_PlaybookPlay__c> playbookList = new List<CSM_PlaybookPlay__c>();
				
		List<String> PPBFieldList = new List<String>{CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_PLAYBOOK};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAYBOOKPLAY,
																								CSM_Constants.DML_OPERATION_READ, PPBFieldList);
    	List<String> PBFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,CSM_Constants.OBJ_PLAYBOOK_ISACTIVE,CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK, 
																									CSM_Constants.DML_OPERATION_READ, PBFieldList);
       if (noAccessList.isEmpty() && noAccessList2.isEmpty())
    	{
    		if(playId!=null)
    		{
    									
    			playbookList = [SELECT id, CSM_Play__c, CSM_Playbook__c, CSM_Playbook__r.CSM_Display_Name__c, 
    							CSM_Playbook__r.CSM_IsActive__c
								FROM CSM_PlaybookPlay__c 
								WHERE CSM_Play__c = :playId LIMIT 10000];									
				
    		}
    	}
		else 
		{
    		String[] arguments = new String[] {(noAccessList!=null?CSM_CONSTANTS.OBJ_PLAYBOOKPLAY + ':'+String.valueOf(noAccessList):noAccessList2!=null?CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList2):'')};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_DELETABLE, arguments));
    	    
		}

		return playbookList;
	}
	
	public static List<CSM_PlaybookPlay__c> getPlaybookPlayByExternalId(Set<String> pbExternalSet, Set<String> pExternalSet)
	{ 
		List<String> PPBFieldList = new List<String>{CSM_Constants.OBJ_PBP_ID, CSM_Constants.OBJ_PBP_PLAY, CSM_Constants.OBJ_PBP_PLAYBOOK};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, PPBFieldList, CSM_Constants.DML_OPERATION_READ);
		return [SELECT Id, CSM_Playbook__c, CSM_Play__c FROM CSM_PlaybookPlay__c WHERE CSM_Playbook__r.CSM_External_Id__c IN :pbExternalSet AND CSM_Play__r.CSM_External_Id__c IN :pExternalSet];
	}

	public static List<CSM_PlaybookPlay__c> getPlaybookPlayById(string playbookPlayId)
	{ 
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_PBP_ID,  CSM_Constants.OBJ_PBP_PLAYBOOK};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, fieldList, CSM_Constants.DML_OPERATION_READ);
		return [SELECT Id, CSM_Playbook__c FROM CSM_PlaybookPlay__c WHERE Id =: playbookPlayId order by CSM_Playbook__c];
	}

	
	public static void upsertPlaybookPlay(List<CSM_PlaybookPlay__c> playbookPlays)
	{
	    List<String> pbpFieldList = new List<String>{/*CSM_Constants.OBJ_PBP_PLAY, CSM_Constants.OBJ_PBP_PLAYBOOK*/};
	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, pbpFieldList, CSM_Constants.DML_OPERATION_UPSERT);
	    upsert playbookPlays;
	}
}