public with sharing class CSM_PlaybooksDataAccess {
	
	
	public static CSM_Playbook__c populatePlaybooksInformation(String playbookId) {
		CSM_Playbook__c thePlaybook = new CSM_Playbook__c(); 
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,CSM_Constants.OBJ_PLAYBOOK_ISACTIVE,
								CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC, CSM_Constants.OBJ_PLAYBOOK_LONG_DESC, 
								CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,
																								CSM_Constants.DML_OPERATION_READ, fcFieldList);
		
    	if (noAccessList.isEmpty())
    	{
    		if(!String.isEmpty(playbookId))
    		{
    			List<CSM_Playbook__c> playbookList = new List<CSM_Playbook__c>();
				playbookLIst = [select id, CSM_Display_Name__c, CSM_isActive__c, CSM_Automated__c, 
						CSM_Short_Description__c, CSM_Long_Description__c, CSM_Play_Total__c/*, CSM_Task_Total__c*/ 
						from CSM_Playbook__c where id = :playbookId order by CSM_Display_Name__c limit 1];
				if(!playbookList.isEmpty())
				{
					thePLaybook = playbookList[0];
				}
    		}
    	}
		else 
		{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	    
		}

		return thePlaybook;
	}
	
	public static List<CSM_PlaybookWrapper> populatePlaybooksInformation() {
		List<CSM_PlaybookWrapper> pbWList = new List<CSM_PlaybookWrapper>();

		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,
			    CSM_Constants.OBJ_PLAYBOOK_ISACTIVE, CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC, 
			    CSM_Constants.OBJ_PLAYBOOK_LONG_DESC, CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, 
			    CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		        CSM_CONSTANTS.OBJ_PLAYBOOK, CSM_Constants.DML_OPERATION_READ, fcFieldList);
    	List<String> pbpFieldList2 = new List<String>{CSM_Constants.OBJ_PBP_PLAY,CSM_Constants.OBJ_PBP_PLAYBOOK};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAYBOOKPLAY,
			CSM_Constants.DML_OPERATION_READ, pbpFieldList2);
			
		List<String> playFieldList = new List<String>{CSM_Constants.OBJ_PLAY_TASK_TOTAL};
		List<String> noAccessPlayList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAY,
			CSM_Constants.DML_OPERATION_READ, playFieldList);
    	if (noAccessList.isEmpty() && noAccessList2.isEmpty() && noAccessPlayList.isEmpty())
    	{
			List<CSM_Playbook__c> pbList=[Select id, CSM_Display_Name__c, CSM_isActive__c, CSM_Automated__c, 
										CSM_Short_Description__c, CSM_Long_Description__c, CSM_Play_Total__c
			    						FROM CSM_Playbook__c LIMIT 1000];
    		Map<String, Integer> pbPlayMap = new Map<String, Integer>(); 			
    		Integer taskTotal = 0;
			for (CSM_PlaybookPlay__c pbPlay : [SELECT CSM_Playbook__c, CSM_Play__r.CSM_Task_Total__c 
										FROM CSM_PlaybookPlay__c 
										WHERE CSM_Playbook__c IN : pbList
										ORDER BY CSM_Playbook__c LIMIT 1000]) {
				if (pbPlayMap.containsKey(pbPlay.CSM_Playbook__c)) {
    				taskTotal = pbPlayMap.get(pbPlay.CSM_Playbook__c);
    				taskTotal += (Integer) pbPlay.CSM_Play__r.CSM_Task_Total__c;
				} else {
					taskTotal = 0;
					taskTotal = (Integer) pbPlay.CSM_Play__r.CSM_Task_Total__c;
				}
				pbPlayMap.put(pbPlay.CSM_Playbook__c, taskTotal);
    		}
    		
    		for (CSM_Playbook__c pb : pbList) {
				CSM_PlaybookWrapper pbW = new CSM_PlaybookWrapper();
				pbW.playbook = pb;
				pbW.TaskTotal = 0;
				if (pbPlayMap.containsKey(pb.Id)){
					pbW.TaskTotal = pbPlayMap.get(pb.Id);
				}
    			pbWList.add(pbW);
			}
 			
    	}
		else 
		{	
			if (!noAccessList.isEmpty())
		    {
		    	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':' + String.valueOf(noAccessList)};
		    	throw new CSM_AccessController.AccessControlDmlException( String.format(
    			System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
		    }
		    else if (!pbpFieldList2.isEmpty())
		    {
		    	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOKPLAY + ':' + String.valueOf(pbpFieldList2)};
		    	throw new CSM_AccessController.AccessControlDmlException( String.format(
    			System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
		    }
		    else {
		    	
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAY + ':' +
    			String.valueOf(noAccessPlayList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
		    }
		}

		return pbWList;
	}
	
	public static boolean activatePlaybooks(List<String> playbookIdList) 
	{
		List<CSM_Playbook__c> playbookList = New List<CSM_Playbook__c>();
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_UPDATE, fcFieldList);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList.isEmpty())
    	{
    		playbookList = [select id, csm_isactive__c from CSM_Playbook__c where id in :playbookIdList limit 1000];
    		for(CSM_Playbook__c p : playbookList)
    		{
    			p.csm_isactive__c = true;
    		}
    		update playbookList;
    		return true;
    	}
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
    	}	

		return false;
	}
	
	public static boolean deactivatePlaybooks(List<String> playbookIdList) 
	{
		List<CSM_Playbook__c> playbookList = New List<CSM_Playbook__c>();
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_UPDATE, fcFieldList);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList.isEmpty())
    	{
    		playbookList = [select id, csm_isactive__c from CSM_Playbook__c where id in :playbookIdList limit 1000];
    		for(CSM_Playbook__c p : playbookList)
    		{
    			p.csm_isactive__c = false;
    		}
    		update playbookList;
    		return true;
    	}
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
    	}	

		return false;
	}
	
	/** 
	 * @description Creates playbook assignments. Can take a Map of Success Plan template or a map of Success Plans to create the relationship
	 */
	public static boolean createPlaybookAssignment(Map<String,String> accountPlanTemplateIdMap, Map<String,String> accountPlanIdMap, List<CSM_Account_Plan_Playbook__c> newAccountPlanPlaybookList, boolean isCriteriaSkipped)
	{
		Set<String> playbookIds = new Set<String>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_INSERT, fcFieldList);
		system.debug('noAccessList - ' + noAccessList);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList.isEmpty())
    	{
    		List<CSM_Account_Plan_Playbook__c> successPlanTemplatePlaybookList = [SELECT Id,CSM_Account_Plan_Template__c,CSM_Playbook__c FROM CSM_Account_Plan_Playbook__c WHERE CSM_Playbook__c in :accountPLanTemplateIdMap.values() AND CSM_Account_Plan_Template__c in :accountPLanTemplateIdMap.keySet() LIMIT 10000];
    		Map<String,CSM_Account_Plan_Playbook__c> spPlaybookmap = new Map<String,CSM_Account_Plan_Playbook__c> ();
    		
    		for(CSM_Account_Plan_Playbook__c spPlanPlayBookObj : successPlanTemplatePlaybookList){
				spPlaybookmap.put(spPlanPlayBookObj.CSM_Account_Plan_Template__c+ ':' +spPlanPlayBookObj.CSM_Playbook__c,spPlanPlayBookObj);
			}
    		
    		//Create all the Success Plan playbook entries for Success Plan templates
    		CSM_Account_Plan_Playbook__c spPlayBook;
    		for (String s : accountPlanTemplateIdMap.Keyset())
    		{   
				if(spPlaybookmap.containsKey(s +':'+accountPlanTemplateIdMap.get(s))){
					spPlayBook =  spPlaybookmap.get(s +':'+accountPlanTemplateIdMap.get(s));
				}
				
				if (spPlayBook==null){
	    			CSM_Account_Plan_Playbook__c newPlanPlaybook = new CSM_Account_Plan_Playbook__c();
	    			newPlanPlaybook.CSM_Account_Plan_Template__c = s;
	    			newPlanPlaybook.CSM_Source__c = CSM_Constants.STR_FROM_TEMPLATE;//Added for US1146
	    			newPlanPlaybook.CSM_Playbook__c = accountPLanTemplateIdMap.get(s);
	    			newPlanPlaybook.CSM_ByPass_Criteria__c = isCriteriaSkipped;
	    			newAccountPlanPlaybookList.add(newPlanPlaybook);
	    			playbookIds.add(accountPLanTemplateIdMap.get(s));
				}		    	    			
    		}
    		System.debug('accountPlanIdMap - '+accountPlanIdMap);
    		System.debug('playbookIds - '+playbookIds);
    		//Create all the Success Plan playbook entries for Success Plans
    		for (String s : accountPlanIdMap.Keyset())
    		{
    			if(!playbookIds.contains(accountPlanIdMap.get(s))){
	    			CSM_Account_Plan_Playbook__c newPlanPlaybook = new CSM_Account_Plan_Playbook__c();
	    			newPlanPlaybook.CSM_Account_Plan__c = s;
	    			newPlanPlaybook.CSM_ByPass_Criteria__c = isCriteriaSkipped;
	    			newPlanPlaybook.CSM_Source__c = CSM_Constants.STR_MANUAL_ADD;//Added for US1146
	    			newPlanPlaybook.CSM_Playbook__c = accountPlanIdMap.get(s);
	    			newAccountPlanPlaybookList.add(newPlanPlaybook);
    			}
    		}
    		//If there are records to insert, insert
    		if(!newAccountPlanPlaybookList.isEmpty())
    		{
    			CSM_AccountPlanPlaybookDataAccess.createAccountPlanPlaybook(newAccountPlanPlaybookList);
    			return true;
    		}else{
        		//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_MSG_PLAYBOOK_ALREADY_ADDED));
        		return false;    		
    		}
    		
			
		}
		//User does not have access to all the fields
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, arguments));
    	    return false;
    	}	

		return false;
	}
	
	
	public static List<CSM_Playbook__c> savePlaybook(List<CSM_Playbook__c> playbookList)
	{
	
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,CSM_Constants.OBJ_PLAYBOOK_ISACTIVE, 
					CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC, CSM_Constants.OBJ_PLAYBOOK_LONG_DESC,
						CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_EXTERNAL_ID};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,
																								CSM_Constants.DML_OPERATION_UPSERT, fcFieldList);
    	if (noAccessList.isEmpty())
    	{
    		
			upsert playbookList;
    	}
		else 
		{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));
    	    
		}

		return playbookList;
	}
	public static Map<Id, CSM_Playbook__c> getPlaybookMapByExtId(Set<String> externalIdSet)
	{
	    List<String> pbFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_ID, CSM_Constants.OBJ_PLAYBOOK_EXTERNAL_ID};
	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PLAYBOOK, pbFieldList, CSM_Constants.DML_OPERATION_READ);
		return new Map<Id, CSM_Playbook__c>([SELECT Id, CSM_External_Id__c FROM CSM_Playbook__c WHERE CSM_External_Id__c IN :externalIdSet LIMIT 200]);
	}
	
	public static List<CSM_Playbook__c> getPlaybooksByExtId(Map<String, String> playbookExternalIds)
	{
		
	    List<CSM_Playbook__c> playbookList = new List<CSM_Playbook__c>();
	
		List<String> fcPlaybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,
			                    CSM_Constants.OBJ_PLAYBOOK_EXTERNAL_ID, CSM_Constants.OBJ_PLAYBOOK_ID,
			                    CSM_Constants.OBJ_PLAYBOOK_NAME, CSM_Constants.OBJ_PLAYBOOK_EXTERNAL_ID,
								CSM_Constants.OBJ_PLAYBOOK_LONG_DESC, CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC,
								CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE,
								CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL, CSM_Constants.OBJ_PLAYBOOK_TYPE};
		
								
		List<String> noAccessListPlaybook = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAYBOOK, CSM_Constants.DML_OPERATION_READ, fcPlaybookFieldList);
		
    	if (noAccessListPlaybook.isEmpty())
    	{
			playbookList = [SELECT Name, Id,
								   CSM_Display_Name__c,
   				   				   CSM_Long_Description__c, 
   				   				   CSM_Short_Description__c,
   				   				   CSM_Playbook_Type__c,
   				   				   CSM_Play_Total__c,
   				   				   CSM_IsActive__c,
   				   				   CSM_Automated__c,
   				   				   CSM_External_Id__c 
		  					  FROM CSM_Playbook__c 
		 					 WHERE CSM_External_Id__c IN :playbookExternalIds.KeySet() LIMIT 1000];
    	}
		else 
		{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessListPlaybook)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	    
		}			

		return playbookList;
	}
	
   /**
	* @description Clone Playbook and insert clone records
	* @param List<String> of Playbook Id
	* @return List<CSM_Playbook__c>  Playbook Records
	*/
    public static List<CSM_Playbook__c> clonePlaybook(List<String> playbookIdList) {
        List<CSM_Playbook__c> playbookList = new List<CSM_Playbook__c>();
        CSM_Playbook__c playbook = GetPlaybookRecord(playbookIdList[0]);
        CSM_Playbook__c clonedPlaybook = playbook.clone(false, true);
        
        String displayName = Label.CSM_LBL_CLONE_PREFIX +' '+playbook.CSM_Display_Name__c;
        clonedPlaybook.CSM_Display_Name__c = displayName.length()>40?displayName.substring(0, 40):displayName;
        clonedPlaybook.CSM_IsActive__c = false;
        List<String> playbookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,
														            CSM_Constants.OBJ_PLAYBOOK_ISACTIVE,
														            CSM_Constants.OBJ_PLAYBOOK_AUTOMATED,
														            CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC,
														            CSM_Constants.OBJ_PLAYBOOK_LONG_DESC};
														            
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAYBOOK,
                                                                                                                CSM_Constants.DML_OPERATION_INSERT, playbookFieldList);
        if (noAccessList.isEmpty()) {
            playbookList.add(clonedPlaybook); 
            insert playbookList;   		
        } else {
        	  String[] arguments = new String[] {CSM_Constants.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};			   
	          throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, 
	          arguments));
        }
        
        return playbookList;
    }
    
   /**
	* @description Clone PbookPlay records and insert clone records
	* @param List<CSM_PlaybookPlay__c> of PbookPlayList Records.
	* @return void method
	*/ 
	public static void InsertClonedPlaybookPlayList(List<CSM_PlaybookPlay__c> PbookPlayList) {
	    if (!PbookPlayList.isEmpty()) {
	        List<String> playbookPlayFieldList = new List<String> {
	            	CSM_Constants.OBJ_PLAYBOOKPLAY_PLAYBOOK,
	                CSM_Constants.OBJ_PLAYBOOKPLAY_PLAY
	        };
	
	        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAYBOOKPLAY,
	            CSM_Constants.DML_OPERATION_INSERT, playbookPlayFieldList);
	
	        if (noAccessList.isEmpty() && !PbookPlayList.isEmpty()) {
	            insert PbookPlayList;
	        } else {
	            String[] arguments = new String[] {
	                CSM_Constants.OBJ_PLAYBOOKPLAY + ':' + String.valueOf(noAccessList)
	            };
	            throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE,
	                arguments));
	        }
	    }
	}
	
   /**
	* @description returns playbookplay record's by doing query.
	* @param List, playbook Id's.
	* @return CSM_PlaybookPlay__c, playbookplay record.
	*/
    public static List<CSM_PlaybookPlay__c> GetPlaybookPlayList(List<String> playbookIdList) { 
    	List<CSM_PlaybookPlay__c> playbookplay;
    	if (!playbookIdList.isEmpty()) {
        	CSM_QueryBuilder q = new CSM_QueryBuilder(CSM_Constants.OBJ_PLAYBOOKPLAY, ''); 
        	playbookplay = Database.Query(q.GetQueryByIdList(CSM_Constants.OBJ_PLAYBOOKPLAY_PLAYBOOK, playbookIdList));
    	}
        return playbookplay; 
    } 
  
   /**
	* @description returns playbook record by doing query.
	* @param String, playbook Id.
	* @return CSM_Playbook__c, playbook record.
	*/
    private static CSM_Playbook__c GetPlaybookRecord(String playbookId) { 
        CSM_QueryBuilder q = new CSM_QueryBuilder(CSM_Constants.OBJ_PLAYBOOK, ''); 
        CSM_Playbook__c playbook = Database.Query(q.GetQueryById(CSM_Constants.OBJ_AP_ID, playbookId));
        return playbook; 
    }
    
    public static List<CSM_PlaybookWrapper> populatePlaybooksInformationByAcctPlanPlaybookId(Set<Id> playbookIds) {
		List<CSM_PlaybookWrapper> pbWList = new List<CSM_PlaybookWrapper>();

		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,
			    CSM_Constants.OBJ_PLAYBOOK_ISACTIVE, CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC, 
			    CSM_Constants.OBJ_PLAYBOOK_LONG_DESC, CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, 
			    CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		        CSM_CONSTANTS.OBJ_PLAYBOOK, CSM_Constants.DML_OPERATION_READ, fcFieldList);
    	List<String> pbpFieldList2 = new List<String>{CSM_Constants.OBJ_PBP_PLAY,CSM_Constants.OBJ_PBP_PLAYBOOK};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAYBOOKPLAY,
			CSM_Constants.DML_OPERATION_READ, pbpFieldList2);
			
		List<String> playFieldList = new List<String>{CSM_Constants.OBJ_PLAY_TASK_TOTAL};
		List<String> noAccessPlayList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAY,
			CSM_Constants.DML_OPERATION_READ, playFieldList);
		Integer recLimit = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_PLAYBOOK);
    	if (noAccessList.isEmpty() && noAccessList2.isEmpty() && noAccessPlayList.isEmpty())
    	{
			String soql='Select id, CSM_Display_Name__c, CSM_isActive__c, CSM_Automated__c, '+
										'CSM_Short_Description__c, CSM_Long_Description__c, CSM_Play_Total__c '+
			    						'FROM CSM_Playbook__c '+
			    						'WHERE Id in :playbookIds LIMIT ' + recLimit;
    		Map<String, Integer> pbPlayMap = new Map<String, Integer>(); 			
    		Integer taskTotal = 0;
    		List<CSM_Playbook__c> pbList = Database.query(soql);
			for (CSM_PlaybookPlay__c pbPlay : [SELECT CSM_Playbook__c, CSM_Play__r.CSM_Task_Total__c 
										FROM CSM_PlaybookPlay__c 
										WHERE CSM_Playbook__c IN : pbList
										ORDER BY CSM_Playbook__c LIMIT 5000]) {
				if (pbPlayMap.containsKey(pbPlay.CSM_Playbook__c)) {
    				taskTotal = pbPlayMap.get(pbPlay.CSM_Playbook__c);
    				taskTotal += (Integer) pbPlay.CSM_Play__r.CSM_Task_Total__c;
				} else {
					taskTotal = 0;
					taskTotal = (Integer) pbPlay.CSM_Play__r.CSM_Task_Total__c;
				}
				pbPlayMap.put(pbPlay.CSM_Playbook__c, taskTotal);
    		}
    		
    		for (CSM_Playbook__c pb : pbList) {
				CSM_PlaybookWrapper pbW = new CSM_PlaybookWrapper();
				pbW.playbook = pb;
				pbW.TaskTotal = 0;
				if (pbPlayMap.containsKey(pb.Id)){
					pbW.TaskTotal = pbPlayMap.get(pb.Id);
				}
    			pbWList.add(pbW);
			}
 			
    	}
		else 
		{	
			if (!noAccessList.isEmpty())
		    {
		    	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':' + String.valueOf(noAccessList)};
		    	throw new CSM_AccessController.AccessControlDmlException( String.format(
    			System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
		    }
		    else if (!pbpFieldList2.isEmpty())
		    {
		    	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOKPLAY + ':' + String.valueOf(pbpFieldList2)};
		    	throw new CSM_AccessController.AccessControlDmlException( String.format(
    			System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
		    }
		    else {
		    	
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAY + ':' +
    			String.valueOf(noAccessPlayList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
		    }
		}

		return pbWList;
	}
	
	public static List<CSM_Playbook__c> getPlaybooksById(String playbookId)
	{
		
	    List<CSM_Playbook__c> playbookList = new List<CSM_Playbook__c>();
	
		List<String> fcPlaybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME,
			                    CSM_Constants.OBJ_PLAYBOOK_EXTERNAL_ID, CSM_Constants.OBJ_PLAYBOOK_ID,
			                    CSM_Constants.OBJ_PLAYBOOK_NAME, CSM_Constants.OBJ_PLAYBOOK_EXTERNAL_ID,
								CSM_Constants.OBJ_PLAYBOOK_LONG_DESC, CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC,
								CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE,
								CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL, CSM_Constants.OBJ_PLAYBOOK_TYPE};
		
								
		List<String> noAccessListPlaybook = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAYBOOK, CSM_Constants.DML_OPERATION_READ, fcPlaybookFieldList);
		
    	if (noAccessListPlaybook.isEmpty())
    	{
			playbookList = [SELECT Name, Id,
								   CSM_Display_Name__c,
   				   				   CSM_IsActive__c
		  					  FROM CSM_Playbook__c 
		 					 WHERE Id = :playbookId LIMIT 1];
    	}
		else 
		{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessListPlaybook)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	    
		}			

		return playbookList;
	}
	public static void deletePlaybook(List<CSM_Playbook__c> playbookList) 
	{
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP_PLAYBOOK,CSM_Constants.DML_OPERATION_DELETE, null);
    	if (noAccessList.isEmpty())
    	{
			delete playbookList;
    	}
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_DELETABLE, arguments));	
    	   
    	}
	}
	public static List<CSM_Playbook__c> getPlaybookList(List<String> playbookIdList) { 
    	List<CSM_Playbook__c> playbook;
    	if (!playbookIdList.isEmpty()) {
        	CSM_QueryBuilder q = new CSM_QueryBuilder(CSM_Constants.OBJ_PLAYBOOK, ''); 
        	playbook = Database.Query(q.GetQueryByIdList(CSM_Constants.OBJ_AP_ID, playbookIdList));
    	}
        return playbook; 
    } 
}