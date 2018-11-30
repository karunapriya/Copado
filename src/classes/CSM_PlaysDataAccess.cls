public with sharing class CSM_PlaysDataAccess {


	public static List<CSM_Play__c> populatePlayList()
	{
		List<CSM_Play__c> playList = new List<CSM_Play__c>();
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_AUTOMATED, 
					CSM_Constants.OBJ_PLAY_DISPLAY_NAME, CSM_Constants.OBJ_PLAY_DESCRIPTION,
					CSM_Constants.OBJ_PLAY_OBJECT_NAME, CSM_Constants.OBJ_PLAY_TASK_TOTAL, 
					CSM_Constants.OBJ_PLAY_TASK_AUTOCOMPLETE, CSM_Constants.OBJ_PLAY_TASK_AUTODISMISS,
					CSM_Constants.OBJ_PLAY_ACTIVE_TASK_TOTAL
					};
																									
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		
			playList = [select id, CSM_IsActive__c, CSM_Automated__c, CSM_Object_Name__c, CSM_Display_Name__c, CSM_Play_Description__c, 
						CSM_Task_Total__c, CSM_Auto_Complete_Automated_Tasks__c, CSM_Auto_Dismiss_Automated_Tasks__c, RLM_Currency_Code__c, CreatedDate,
						CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, CSM_Active_Play_Task_Total__c
						from CSM_Play__c limit 1000];
			
				
		return playlist;
	}
	public static CSM_Play__c populatePlayInformation(String playId)
	{
		CSM_Play__c play = new CSM_Play__c();
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE,  CSM_Constants.OBJ_PLAY_SHORTDESCRIPTION, 
					CSM_Constants.OBJ_PLAY_AUTOMATED, 
					CSM_Constants.OBJ_PLAY_DISPLAY_NAME, CSM_Constants.OBJ_PLAY_DESCRIPTION,
					CSM_Constants.OBJ_PLAY_OBJECT_NAME, CSM_Constants.OBJ_PLAY_TASK_TOTAL, CSM_Constants.OBJ_PLAY_FILTER_LOGIC,
					CSM_Constants.OBJ_PLAY_TASK_AUTOCOMPLETE, CSM_Constants.OBJ_PLAY_TASK_AUTODISMISS,CSM_Constants.OBJ_PLAY_REENtry};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAY,
																									CSM_Constants.DML_OPERATION_READ, fcFieldList);
																									
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
			List<CSM_Play__c> playList = new List<CSM_Play__c>();
			playList = [select id, CSM_Short_Description__c, CSM_IsActive__c, CSM_Object_Name__c, CSM_Automated__c, 
						CSM_Display_Name__c, CSM_Play_Description__c, RLM_Currency_Code__c,RLM_Filter_Logic__c,
						CSM_Task_Total__c, CSM_Auto_Complete_Automated_Tasks__c, CSM_Auto_Dismiss_Automated_Tasks__c,CSM_Play_ReEntry__c
						from CSM_Play__c where id = :playId limit 1];
			if(!playList.isEmpty())
			{
				play = playList[0];
			}
				
		return play;
	}
	
	public static List<CSM_Play__c> populatePlayInformation(List<String> playIdList)
	{
		List<CSM_Play__c> playList = new LIst<CSM_Play__c>();
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_AUTOMATED, 
					CSM_Constants.OBJ_PLAY_DISPLAY_NAME, CSM_Constants.OBJ_PLAY_DESCRIPTION,
					CSM_Constants.OBJ_PLAY_OBJECT_NAME, CSM_Constants.OBJ_PLAY_TASK_TOTAL, CSM_Constants.OBJ_PLAY_TASK_AUTOCOMPLETE, CSM_Constants.OBJ_PLAY_TASK_AUTODISMISS};
																									
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
			playList = [select id, CSM_IsActive__c, CSM_Object_Name__c, CSM_Automated__c, CSM_Display_Name__c, CSM_Play_Description__c,
						CSM_Task_Total__c, CSM_Auto_Complete_Automated_Tasks__c, CSM_Auto_Dismiss_Automated_Tasks__c, RLM_Currency_Code__c
						from CSM_Play__c where id in :playIdList limit 1000];
		
		return playList;
	}

	public static List<CSM_Play__c> getPlayReEntryInformation(List<String> playIdList)
	{
		List<CSM_Play__c> playList = new LIst<CSM_Play__c>();
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ID, CSM_Constants.OBJ_PLAY_REENtry};
																									
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
			playList = [select id, CSM_Play_ReEntry__c from CSM_Play__c where id in :playIdList limit 1000];
		
		return playList;
	}

	
	public static boolean activatePlays(List<String> playIdList) 
	{
		List<CSM_Play__c> playList = New List<CSM_Play__c>();
	
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_UPDATE);
		
    	//If user has access to fields, query the Success Plan Phase
    		playList = [select id, csm_isactive__c from CSM_Play__c where id in :playIdList limit 1000];
    		for(CSM_Play__c p : playList)
    		{
    			p.csm_isactive__c = true;
    		}
    		update playList;
	
		return false;
	}
	
	public static boolean deactivatePlays(List<String> playIdList) 
	{
		List<CSM_Play__c> playList = New List<CSM_Play__c>();
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_UPDATE);
		
    	//If user has access to fields, query the Success Plan Phase
    		playList = [select id, csm_isactive__c from CSM_Play__c where id in :playIdList limit 1000];
    		for(CSM_Play__c p : playList)
    		{
    			p.csm_isactive__c = false;
    		}
    		update playList;	

		return false;
	}
	
	public static List<CSM_Play__c> savePlays(List<CSM_Play__c> playList)
	{
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_AUTOMATED, 
					CSM_Constants.OBJ_PLAY_DISPLAY_NAME, CSM_Constants.OBJ_PLAY_DESCRIPTION, 
					CSM_Constants.OBJ_PLAY_OBJECT_NAME, //CSM_Constants.OBJ_PLAY_TASK_TOTAL, 
					CSM_Constants.OBJ_PLAY_TASK_AUTOCOMPLETE, CSM_Constants.OBJ_PLAY_TASK_AUTODISMISS,
					CSM_Constants.OBJ_PLAY_EXTERNAL_ID, CSM_Constants.OBJ_PLAY_QUERY_CRIT};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
		
			upsert playList;

		return playList;
	}

	public static List<CSM_PlaybookPlay__c> getActiveNonAutomatedPlays(Set<String> playbookIds)
	{
		return getActiveNonAutomatedPlays(playbookIds, null);
	}
	
	public static List<CSM_PlaybookPlay__c> getActiveNonAutomatedPlays(Set<String> playbookIds, String playObjectName)
	{
		List<CSM_PlaybookPlay__c> tmpList = new List<CSM_PlaybookPlay__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_AUTOMATED, 
						CSM_Constants.OBJ_PLAY_OBJECT_NAME, CSM_Constants.OBJ_PLAY_QUERY_CRIT};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
	
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_PLAYBOOK};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOKPLAY, CSM_Constants.DML_OPERATION_READ, fcFieldList2);
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOKPLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);
	
			if(String.isBlank(playObjectName)){
				tmpList = [select id, CSM_Play__r.CSM_isActive__c, CSM_Play__r.CSM_Object_Name__c, 
						CSM_Playbook__c, CSM_Play__r.CSM_Query_Criteria__c, CSM_Play__c
						from CSM_PlaybookPlay__c
						where CSM_Playbook__c in :playbookIds
						and CSM_Play__r.CSM_IsActive__c = true
						and CSM_Play__r.CSM_Automated__c = false
						limit 1000];
			}else{
				tmpList = [select id, CSM_Play__r.CSM_isActive__c, CSM_Play__r.CSM_Object_Name__c, 
						CSM_Playbook__c, CSM_Play__r.CSM_Query_Criteria__c, CSM_Play__c
						from CSM_PlaybookPlay__c
						where CSM_Playbook__c in :playbookIds
						and CSM_Play__r.CSM_IsActive__c = true
						and CSM_Play__r.CSM_Object_Name__c =: playObjectName
						limit 1000];
			}
			
		return tmpList;
	} 
	
	public static List<CSM_PlaybookPlay__c> getActiveAutomatedPlays(Set<String> playbookIds)
	{
		List<CSM_PlaybookPlay__c> tmpList = new List<CSM_PlaybookPlay__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_AUTOMATED, 
						CSM_Constants.OBJ_PLAY_OBJECT_NAME, CSM_Constants.OBJ_PLAY_QUERY_CRIT};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, fcFieldList, CSM_Constants.DML_OPERATION_READ);
	
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_PLAYBOOK};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOKPLAY, CSM_Constants.DML_OPERATION_READ, fcFieldList2);
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOKPLAY, fcFieldList2, CSM_Constants.DML_OPERATION_READ);
	
		tmpList = [select id, CSM_Play__r.CSM_isActive__c, CSM_Play__r.CSM_Object_Name__c, CSM_Play__r.CSM_External_Id__c,
				CSM_Playbook__r.CSM_External_Id__c, CSM_Playbook__c, CSM_Play__r.CSM_Query_Criteria__c, CSM_Play__c
				from CSM_PlaybookPlay__c
				where CSM_Playbook__c IN :playbookIds
				and CSM_Play__r.CSM_IsActive__c = true
				and CSM_Play__r.CSM_Automated__c = true
				limit 1000];
			
		return tmpList;
	}
	
	//@params: List<Play_Book>, Map<PLB_External, playListToUpsert>, Map<PL_External, PlayResult>
	public static void createPlays(List<CSM_Playbook__c> listOfPlaybooks, 
									Map<String, List<CSM_Play__c>> playbookMap,
									Map<String, CSM_Play_Result__c> playToResult) {
	/*	List<CSM_Play_Result__c> failedPlayResult = new List<CSM_Play_Result__c>();
		String email;
		
		CSM_Admin__c adminValuesCS = CSM_Admin__c.getOrgDefaults();
		if(adminValuesCS != null && adminValuesCS.CSM_Email__c != null && adminValuesCS.CSM_Email__c != '')
		{
			email = adminValuesCS.CSM_Email__c;
		}
		String message = 'Following plays have been created :';
		String baseURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
		Boolean playsCreated = false;					
		List<CSM_Play__c> listOfPlays = new List<CSM_Play__c>();
		
		//Eswar Bala - 09/24/2014 - Not a blind upsert anymore
		List<CSM_Play__c> lstPlaysAll = new List<CSM_Play__c>(); //All plays for given Playbooks regardless of if PlayResults had those
		
		for(CSM_Playbook__c plb:listOfPlaybooks)
		{
			List<CSM_Play__c> playListTemp = playbookMap.get(plb.CSM_External_Id__c);
			if(playListTemp != null && !playListTemp.isEmpty())
			{
    			lstPlaysAll.addAll(playListTemp);
			}
		}
		for(CSM_Play__c pl :lstPlaysAll)
		{
    		if((playToResult.keySet()).contains(pl.CSM_External_Id__c)) //Only retrieve those that were part of the new list of PlayResults
    		{
    			listOfPlays.add(pl);
    		}
		}
		Database.UpsertResult[] srList = database.upsert(listOfPlays, false);
		
		Integer i = 0;
		CSM_Play__c play;
		// Iterate through each returned result
		for (Database.UpsertResult sr : srList) {
			play = listOfPlays[i];
		        
		    if (!sr.isSuccess()) {
		        String msg = 'The following error has occurred - ';                    
		        // Operation failed, so get all errors                
		        for(Database.Error err : sr.getErrors()) {
		            msg += err.getStatusCode() + ': ' + err.getMessage();
		            msg += ' - Play fields that affected this error: ' + err.getFields();
		        }
		        if (playToResult.containsKey(play.CSM_External_Id__c)){
		        	CSM_Play_Result__c pr = playToResult.get(play.CSM_External_Id__c);
		        	pr.CSM_Failed_Description__c = msg;
		        	pr.CSM_Failed__c = true;
		        	failedPlayResult.add(pr);
		        }
		    }
		    i++;
		}
		if (!failedPlayResult.isEmpty()){
			List<String> prFieldList = new List<String>{CSM_Constants.OBJ_PR_FAILED_DESC, CSM_Constants.OBJ_PR_FAILED};
			CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PR, prFieldList, CSM_Constants.DML_OPERATION_UPDATE);
			    update failedPlayResult;
		}	*/

	}
	
	/*
	@Description - Delete Play which is selected for Delete. It is created as part of US317.
	*/
	public static boolean deletePlay(String PlayId) 
	{
		
		List<CSM_Play__c> playList = new List<CSM_Play__c>();
		List<String> playFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ISACTIVE, CSM_Constants.OBJ_PLAY_ID, 
					CSM_Constants.OBJ_PLAY_DISPLAY_NAME, CSM_Constants.OBJ_PLAY_NAME, CSM_Constants.OBJ_PLAY_AUTOMATED, 
					CSM_Constants.OBJ_PLAY_AUTO_COMPLETED_AUTOMATED_TASK, CSM_Constants.OBJ_PLAY_DESCRIPTION,CSM_Constants.OBJ_PLAY_QUERY_CRIT,
					CSM_Constants.OBJ_PLAY_OBJECT_NAME, CSM_Constants.OBJ_PLAY_TASK_TOTAL, CSM_Constants.OBJ_PLAY_SHORTDESCRIPTION,
					CSM_Constants.OBJ_PLAY_TASK_AUTOCOMPLETE, CSM_Constants.OBJ_PLAY_TASK_AUTODISMISS,CSM_Constants.OBJ_PLAY_AUTO_DISMISS_AUTOMATED_TASK};
		   
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAY, playFieldList, CSM_Constants.DML_OPERATION_READ);
		    
		List<String> pbpFieldList = new List<String>{CSM_Constants.OBJ_PBP_ID, CSM_Constants.OBJ_PBP_PLAYBOOK, CSM_Constants.OBJ_PBP_PLAY};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, pbpFieldList, CSM_Constants.DML_OPERATION_READ);
																	
		List<String> noAccessPlayList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PBP_PLAY, 
                CSM_Constants.DML_OPERATION_DELETE, null);
        																						
		
			playList = [select id,name from CSM_Play__c
						where Id = :PlayId 
					 	limit 1];
					 	
			if (playList != null && playList.size() > 0) {
				//delete the playList
				delete playList;
				return true;
			}
		
		return false;
	}
	
	public static Map<Id, CSM_Play__c> getPlayMapByExternalId(Set<String> extIdSet)
	{
		List<String> playFieldList = new List<String>{CSM_Constants.OBJ_PLAY_ID, CSM_Constants.OBJ_PLAY_EXTERNAL_ID};
	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAY, playFieldList, CSM_Constants.DML_OPERATION_READ);
		return new Map<Id, CSM_Play__c>([SELECT Id, CSM_External_Id__c FROM CSM_Play__c WHERE CSM_External_Id__c IN :extIdSet LIMIT 200]);
	}
	 
}