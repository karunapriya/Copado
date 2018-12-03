public with sharing class CSM_SuccessPlanPlayDataAccess {
	
	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayList(Set<Id> successPlanId)
	{
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOKPLAY_PLAY,
																CSM_Constants.OBJ_PLAYBOOK_PLAY,
																CSM_Constants.OBJ_TASK_PROCESSING_STATUS,
																CSM_Constants.OBJ_FLD_PLAY_OUTCOME,
																CSM_Constants.OBJ_PR_ENTER_DATE,
																CSM_Constants.OBJ_PR_EXIT_DATE,
																CSM_Constants.OBJ_FLD_SRC,
																CSM_Constants.OBJ_FLD_TOTL_TASKS,
																CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS};
		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		String soql = 'select id, '+ 
					  'FORMAT(CSM_Enter_Date__c),'+
					  'FORMAT(CSM_Exit_Date__c),'+
					  'CSM_Number_of_Closed_Tasks__c,'+
					  'CSM_Play__c,'+
					  'CSM_Play__r.CSM_Display_Name__c,'+
					  'CSM_Playbook_Play__c,'+
					  'CSM_Play_Outcome__c,'+
					  'CSM_Source__c,'+
					  'CSM_Status__c,'+
					  'CSM_SuccessPlan_Playbook__c,'+
					  'CSM_Total_Number_of_Tasks__c,'+
					  'CSM_Playbook_Play__r.CSM_Playbook__r.CSM_Display_Name__c,'+
					  'CSM_Playbook_Play__r.CSM_Playbook__c,'+
					  'CSM_Play__r.CSM_Short_Description__c, '+
					  'CSM_Play__r.CSM_IsActive__c '+
				'from CSM_SuccessPlan_Play__c '+
				'where CSM_SuccessPlan_Playbook__c IN '+ 
				'(select id from CSM_Account_Plan_Playbook__c '+
				'where CSM_Account_Plan__c = :successPlanId) LIMIT 1000';		
		return database.Query(soql);
	}
	
	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListbyId(set<Id> successPlayPlayIdSet)
	{
	    //List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOKPLAY_PLAY,
																CSM_Constants.OBJ_PLAYBOOK_PLAY,
																CSM_Constants.OBJ_TASK_PROCESSING_STATUS,
																CSM_Constants.OBJ_FLD_PLAY_OUTCOME,
																CSM_Constants.OBJ_PR_ENTER_DATE,
																CSM_Constants.OBJ_PR_EXIT_DATE,
																CSM_Constants.OBJ_FLD_SRC,
																CSM_Constants.OBJ_FLD_TOTL_TASKS,
																CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS,CSM_Constants.OBJ_FLD_EVALUATION_DATE};		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		String soql = 'select id, '+ 
					  'FORMAT(CSM_Enter_Date__c),'+
					  'CSM_Exit_Date__c,'+
					  'CSM_Number_of_Closed_Tasks__c,'+
					  'CSM_Play__c,'+
					  'CSM_Play__r.CSM_Display_Name__c,'+
					  'CSM_Playbook_Play__c,'+
					  'CSM_Play_Outcome__c,'+
					  'CSM_Source__c,'+
					  'CSM_Status__c,'+
					  'CSM_SuccessPlan_Playbook__c,'+
					  'CSM_Total_Number_of_Tasks__c,'+
					  'CSM_Playbook_Play__r.CSM_Playbook__r.CSM_Display_Name__c,'+
					  'CSM_Playbook_Play__r.CSM_Playbook__c,'+
					  'CSM_Play__r.CSM_Short_Description__c, '+
					  'CSM_Play__r.CSM_IsActive__c, '+
					  'CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c, '+
					  'CSM_Evaluation_Date__c, '+
					  'CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__r.CSM_AccountId__c ' +
				'from CSM_SuccessPlan_Play__c '+
				'where Id IN :successPlayPlayIdSet  LIMIT 1000';
						
		return database.Query(soql);
	}


	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListForTasks(set<Id> successPlayPlayIdSet, boolean ignorePlayOutcome)
	{
		List<CSM_SuccessPlan_Play__c> spplList = new List<CSM_SuccessPlan_Play__c>();

		List<String> succPlanPlayFieldList = new List<String>{'CSM_Display_Name_Text__c',
																'CSM_Play__c',
																'CSM_Playbook_Play__c','CSM_Evaluation_Date__c',
																'CSM_SuccessPlan_Playbook__c',
																'CSM_Previous_SPPL__c','csm_status__c',
																'Id'};		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 

 		if(ignorePlayOutcome){
 			spplList = [select CSM_Display_Name_Text__c, CSM_Play__c, CSM_Playbook_Play__c, CSM_SuccessPlan_Playbook__c, CSM_Previous_SPPL__c,CSM_Play__r.CSM_Play_ReEntry__c,CSM_Evaluation_Date__c,csm_status__c from CSM_SuccessPlan_Play__c where Id in: successPlayPlayIdSet]; 		
 		}else{
 			spplList = [select CSM_Display_Name_Text__c, CSM_Play__c, CSM_Playbook_Play__c, CSM_SuccessPlan_Playbook__c, CSM_Previous_SPPL__c,CSM_Play__r.CSM_Play_ReEntry__c,CSM_Evaluation_Date__c,csm_status__c from CSM_SuccessPlan_Play__c where Id in: successPlayPlayIdSet and CSM_Play_Outcome__c = null ]; 		
 		}
						
		return spplList;
	}



	
	public static void updateSuccessPLanPlay(List<CSM_SuccessPlan_Play__c> listToUpdate){
    	List<String> succPlanPlayFieldList = new List<String>{  CSM_Constants.OBJ_PLAYBOOK_PLAY,
																CSM_Constants.OBJ_FLD_PLAY_OUTCOME,
																CSM_Constants.OBJ_PR_EXIT_DATE,
																'CSM_Previous_SPPL__c','CSM_Display_Name_Text__c',
																CSM_Constants.OBJ_FLD_TOTL_TASKS,
																CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_UPDATE); 
        update listToUpdate;
    	
    }
    
    public static List<CSM_SuccessPlan_Play__c> insertSuccessPlanPlayList(List<CSM_SuccessPlan_Play__c> successPlanLst){
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_PLAY,
																CSM_Constants.OBJ_FLD_PLAY_OUTCOME,
																CSM_Constants.OBJ_PR_EXIT_DATE,
																CSM_Constants.OBJ_FLD_TOTL_TASKS,
																CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS,
																'CSM_Display_Name_Text__c',
																'CSM_Previous_SPPL__c'
																};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert successPlanLst;
		
		return successPlanLst;
	}
	
	public static void setPlayOutcome(Set<Id> spPLIds, String tskPlayOutCome, integer closedTasks, integer totalTasks) {
		List<CSM_SuccessPlan_Play__c> successPlanPlayList = getSuccessPlanPlayListbyId(spPLIds);
        List<CSM_SuccessPlan_Play__c> successPlanPlayListToUpdate = new List<CSM_SuccessPlan_Play__c>();
        for(CSM_SuccessPlan_Play__c sppl:successPlanPlayList) {
        	if(!String.isBlank(tskPlayOutCome)) {
	        	sppl.CSM_Play_Outcome__c = tskPlayOutCome;
	        	sppl.CSM_Exit_Date__c = system.now(); //today
                if(closedTasks != null && closedTasks != 0){
	                sppl.CSM_Number_of_Closed_Tasks__c = closedTasks;
					sppl.CSM_Total_number_of_Tasks__c = totalTasks;
                }
	        	
	        	successPlanPlayListToUpdate.add(sppl);
        	}
        }
        if(successPlanPlayListToUpdate != null && !successPlanPlayListToUpdate.isEmpty()) {
        	updateSuccessPLanPlay(successPlanPlayListToUpdate);
        }
	}
	public static void deleteSPPlayListByPlaybookPlay(Set<Id> playbookPlayId)
	{
	    
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_PLAY};
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCCESS_PLAN_PLAY, null, CSM_Constants.DML_OPERATION_DELETE); 
		List<CSM_SuccessPlan_Play__c> deleteRecordList = [select id from CSM_SuccessPlan_Play__c where CSM_Playbook_Play__c IN :playbookPlayId limit 1000];
		
		delete deleteRecordList;
	}
	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListByPlaybookId(Set<Id> playbookIds)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOKPLAY_PLAY,
																CSM_Constants.OBJ_PLAYBOOK_PLAY,
																CSM_Constants.OBJ_TASK_PROCESSING_STATUS,
																CSM_Constants.OBJ_FLD_PLAY_OUTCOME,
																CSM_Constants.OBJ_PR_ENTER_DATE,
																CSM_Constants.OBJ_PR_EXIT_DATE,
																CSM_Constants.OBJ_FLD_SRC,
																CSM_Constants.OBJ_FLD_TOTL_TASKS,
																CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS};
		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList = [SELECT id,CSM_SuccessPlan_Playbook__c,CSM_Playbook_Play__r.CSM_Playbook__c 
							  FROM CSM_SuccessPlan_Play__c 
							  WHERE CSM_Playbook_Play__r.CSM_Playbook__c 
							  IN :playbookIds limit 1000];
		return successPlanPlayList;
	}

	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayForRefresh(List<CSM_Account_Plan_Playbook__c> spPlaybookList)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_PLAY,CSM_Constants.OBJ_SPP_PLAYBOOK,
																'CSM_Status__c'};
		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 

		List<String> playbookPlayFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK,CSM_Constants.OBJ_PLAY};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOKPLAY, playbookPlayFieldList, CSM_Constants.DML_OPERATION_READ); 

		List<String> playbookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOK, playbookFieldList, CSM_Constants.DML_OPERATION_READ); 

		List<String> playFieldList = new List<String>{CSM_Constants.OBJ_PLAY_REENtry};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAY, playFieldList, CSM_Constants.DML_OPERATION_READ); 

		List<String> sppbFieldList = new List<String>{CSM_Constants.OBJ_APP_ACCT_TEMPLATE};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, sppbFieldList, CSM_Constants.DML_OPERATION_READ); 

		
		successPlanPlayList = [select Id, CSM_SuccessPlan_Playbook__c, CSM_Playbook_Play__r.csm_playbook__c from csm_successplan_play__c where CSM_Playbook_Play__r.csm_playbook__r.csm_automated__c = false 
														and CSM_SuccessPlan_Playbook__c in : spPlaybookList and CSM_Status__c = 'Completed' and CSM_Playbook_Play__r.csm_play__r.CSM_Play_ReEntry__c = true
															and CSM_SuccessPlan_Playbook__r.CSM_Account_Plan_Template__c = null limit 1000];		
		return successPlanPlayList;
	}


	/*public static List<CSM_SuccessPlan_Play__c> getOpenSuccessPlanPlayForRefresh(List<String> spplIds)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{CSM_Constants.OBJ_SPP_PLAYBOOK, 'CSM_Status__c', 'CSM_Previous_SPPL__c'};
		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		if(spplIds != null && !spplIds.isEmpty()){
			List<String> spplIdsTask = new List<String>();
			List<Task> taskList = [select csm_successplan_play__c from Task where csm_successplan_play__c in: spplIds];
			if(taskList != null && !taskList.isEmpty()){
				for(Task tsk: taskList){
					spplIdsTask.add(tsk.csm_successplan_play__c);
				}
			}
			if(spplIdsTask != null && !spplIdsTask.isEmpty()){
				successPlanPlayList = [select Id, CSM_SuccessPlan_Playbook__c,CSM_Previous_SPPL__c from csm_successplan_play__c where CSM_Previous_SPPL__c in : spplIds and CSM_Status__c != 'Completed' and Id in: spplIdsTask];			
			}
		}
		return successPlanPlayList;
	}*/



	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListByplanPlaybookAndPlayId(string[] planPlaybook, string playId)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{	CSM_Constants.OBJ_PBP_ID,CSM_Constants.OBJ_SPP_PLAYBOOK,
																CSM_Constants.OBJ_PLAY};
		
								
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList = [select Id,CSM_Evaluation_Date__c from CSM_SuccessPlan_Play__c where CSM_SuccessPlan_Playbook__c =: planPlaybook and csm_play__c =: playId];
		return successPlanPlayList;
	}

	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListForTask(Map<id,CSM_Play__c> playMap, List<Id> acctPlanPlaybookList, CSM_Account_PLan__c accountPlan)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{	CSM_Constants.OBJ_PBP_ID,CSM_Constants.OBJ_SPP_PLAYBOOK,
																CSM_Constants.OBJ_PLAY, CSM_Constants.OBJ_FLD_EVALUATION_DATE};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList =  [select Id, csm_playbook_play__c,csm_play__c,CSM_SuccessPlan_Playbook__c,CSM_Evaluation_Date__c from csm_successplan_play__c where csm_play__c in: playMap.keySet() and CSM_SuccessPlan_Playbook__c in :acctPlanPlaybookList and CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c =: accountPlan.Id and CSM_Play_Outcome__c = null and csm_status__c != 'Completed'];
		return successPlanPlayList;
	}

	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListFollowUpTask(Set<Id> spplList)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{	CSM_Constants.OBJ_PBP_ID,CSM_Constants.OBJ_SPP_PLAYBOOK,
																CSM_Constants.OBJ_PLAY};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList =  [select Id, csm_play__c, CSM_SuccessPlan_Playbook__r.csm_account_plan__c from csm_successplan_play__c where Id in : spplList];
		return successPlanPlayList;
	}

	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayListNoNewSPPL(Set<Id> spplList)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{	CSM_Constants.OBJ_PBP_ID,'CSM_Previous_SPPL__c'};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList =  [select Id, CSM_Previous_SPPL__c from csm_successplan_play__c where CSM_Previous_SPPL__c in : spplList];// and csm_status__c != 'Completed'
		return successPlanPlayList;
	}

	public static List<CSM_SuccessPlan_Play__c> getPlayOutcomeForSppl(String spplId)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{	'CSM_Previous_SPPL__c'};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList =  [select CSM_Play_Outcome__c from csm_successplan_play__c where Id =: spplId];
		return successPlanPlayList;
	}
	public static List<CSM_SuccessPlan_Play__c> getSuccessPlanPlayById(Id spplId)
	{
	    List<CSM_SuccessPlan_Play__c> successPlanPlayList = new List<CSM_SuccessPlan_Play__c>();
	
		List<String> succPlanPlayFieldList = new List<String>{'CSM_Display_Name_Text__c',
																'CSM_Play__c',
																'CSM_Playbook_Play__c','CSM_Evaluation_Date__c',
																'CSM_SuccessPlan_Playbook__c',
																'CSM_Previous_SPPL__c','csm_status__c',
																'Id',
																'name'};
		
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SUCC_PLAN_PLAY, succPlanPlayFieldList, CSM_Constants.DML_OPERATION_READ); 
		successPlanPlayList =  [select name from CSM_SuccessPlan_Play__c where id = :spplId];
		return successPlanPlayList;
	}
	
}