public with sharing class CSM_PlaybooksComponentController {
	
	public List<CSM_PlaybookWrapper> playbookList {
		get{
			populatePlaybooksList();
			return playbookList;
		}
		private set;
	}
	public String selectOptionChoice {get; set;}
	public String playbookId {get; set;}
	public Boolean playbookAdded {get; set;}
	public Boolean isPlaybookInactive {get; set;}
	public Boolean isCriteriaSkipped {get; set;}
	public Boolean playCriteriaValidation {get; set;}
	public Boolean doValidation {get; set;}
	public Integer accountplaybooktempCount{get; set;}
	public String acctplaybooktempName {get; set;}
	public String acctplaybookSuccessPlan{get;set;}
	public String successplantempDisplayList{get;set;}
	
	/** 
	 * @description	Constructor
	 */
	public CSM_PlaybooksComponentController() {
		playbookAdded = false;
		isPlaybookInactive = false;
		playCriteriaValidation = false;
		doValidation = false;
		isCriteriaSkipped = ApexPages.currentPage().getParameters().get('skip') == 'true';
	}
	
	/** 
	 * @description	populates the playbooks list 
	 */
	public void populatePlaybooksList() {
		
		playbookList = new List<CSM_PlaybookWrapper>();
		try
		{
    		playbookList = CSM_PlaybooksDataAccess.populatePlaybooksInformation();
    	}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
	}
	
	
	/** 
	 * @description	returns the return url
	 */
	public String retUrl 
	{
		get;
		set {
			if(value != null)
			{
				retUrl = EncodingUtil.urlDecode(value,CSM_Constants.UTF_8);
			}
		}
	}
	
	/** 
	 * @description	returns the Success Plan template id
	 */
	public String acctPlanTemplateId 
	{
		get; 
		set {
			if(value != null)
			{
				acctPlanTemplateId = value;
			}
		}
	}
	
	/** 
	 * @description	return the Success Plan id 
	 */
	public String accountPlanId
	{
		get; 
		set {
			if(value != null)
			{
				accountPlanId = value;
			}
		}
	}
	
	/** 
	 * @description	Constructor
	 */
	public boolean isAdding
	{
		get; 
		set {
			if(value != null)
			{
				isAdding = value;
			}
		}
	}
	
    /** 
	 * @description	adds playbook to Success Plan playbook object
	 */
    public PageReference addPlaybook() 
    {
    	try{
			if(!String.isEmpty(acctPlanTemplateId)){
				return createPlaybookRelationship();
			}else{
				//boolean fromValidation = true;
				playbookValidation();//fromValidation
			}   
    	}catch (exception ex){
			System.debug('\n\nError: ' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
		return null;	
    }
    
    public PageReference createPlaybookRelationship()
    {
    	boolean isSuccessful = false;
    	Map<String,String> acctTempIdMap = new Map<String,String>();
    	Map<String,String> acctPlanIdMap = new Map<String,String>();
    	Savepoint sp = Database.setSavepoint();
    	try
    	{
    		List<CSM_Account_Plan_Playbook__c> newAccountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
	    	if(!String.isEmpty(playbookId) && (!String.isEmpty(acctPlanTemplateId)|| !String.isEmpty(accountPlanId)))
	    	{
	    		//builds map to send to create playbook assignment, that method is written to add multiple assignments
	    		if(!String.isEmpty(acctPlanTemplateId))
	    		{
	    			acctTempIdMap.put(acctPlanTemplateId,playbookId);
	    		}
	    		if(!String.isEmpty(accountPlanId))
	    		{
	    			acctPlanIdMap.put(accountPlanId,playbookId);
	    		}
	    		isSuccessful = CSM_PlaybooksDataAccess.createPlaybookAssignment(acctTempIdMap, acctPlanIdMap, newAccountPlanPlaybookList, isCriteriaSkipped);	

	    	}	    	
    		if(!String.isEmpty(accountPlanId)){
    			
    			Map<ID, CSM_Account_Plan_Playbook__c> newAccountPlanPlaybookMap = new Map<ID, CSM_Account_Plan_Playbook__c>(newAccountPlanPlaybookList);
    			List<CSM_TaskWrapper> taskWrapperList = null;
				system.debug('assopb -' + playbookId + ' ' + newAccountPlanPlaybookMap);   			
    			taskWrapperList = isCriteriaSkipped ? getTaskWrapperListForSkipCriteria(playbookId, newAccountPlanPlaybookMap) : getTaskWrapperList(accountPlanId);
    		}
    		
    		system.debug('flag -' + isSuccessful + ' ' + retUrl);
	    	if(isSuccessful)
	    	{
	    		PageReference pageRef = new PageReference(retUrl);
	    		pageRef.setRedirect(true);
	    		playbookAdded = false;	    		
	    		return pageRef;
	    	}else{
	    		playbookAdded = true;
	    	}
	    }
		catch (exception ex){
			System.debug('\n\nError: ' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			Database.rollback(sp);
		}
    	return null;
    
    }
    
    public PageReference pageredirect()
    {
    	PageReference pageRef = new PageReference(retUrl);
	    pageRef.setRedirect(true);
	    return pageRef;
    }

    private List<CSM_TaskWrapper> getTaskWrapperListForSkipCriteria(String playbookId, Map<ID, CSM_Account_Plan_Playbook__c> newAccountPlanPlaybookMap){
    	
    	List<CSM_TaskWrapper> taskWrapperList = new List<CSM_TaskWrapper>();
     	List<CSM_Account_Plan__c> accountPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(accountPlanId, null);
 	    if(accountPlanList!=null && !accountPlanList.isEmpty()){
 			ID accountID = accountPlanList[0].CSM_AccountId__c;
			ID successPlanId = accountPlanList[0].ID;
	    	List<CSM_PlaybookPlay__c> playbookPlayList = CSM_PlaysDataAccess.getActiveNonAutomatedPlays(new Set<String>{playbookId});
	    	Set<String> playSet = new Set<String>();
	    	Map<Id, CSM_PlaybookPlay__c> playbookPlayMap = new Map<Id, CSM_PlaybookPlay__c>();
	    	for (CSM_PlaybookPlay__c p : playbookPlayList){
	    		if(p.CSM_Play__c != null){
	    			playSet.add(''+p.CSM_Play__c);
	    			playbookPlayMap.put(p.CSM_Play__c, p);
	    		}
			}
			/*
			List<CSM_SuccessPlan_Play__c> successPlanPlayList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayBy(newAccountPlanPlaybookMap.keySet(), playSet);
			
			Map<String, CSM_SuccessPlan_Play__c> uniqueSuccessPlanPlayMap = new Map<String, CSM_SuccessPlan_Play__c>();
			for(CSM_SuccessPlan_Play__c ssp: successPlanPlayList){
				uniqueSuccessPlanPlayMap.put(ssp.CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c + ':' + ssp.CSM_Play__c,ssp);
			}
			system.debug(playSet + '\n\n~~~~uniqueSuccessPlanPlayMap : ' + uniqueSuccessPlanPlayMap);
			*/
 			List<CSM_Play_Task__c> playTaskList = CSM_PlayTaskDataAccess.getActiveTasks(playSet);
			Map<Id, CSM_Play__c> playMap = new Map<Id, CSM_Play__c>(CSM_PlaysDataAccess.populatePlayInformation(new List<String>(playSet)));
			Map<String,CSM_Account_Plan__c> accountPlanbyAccountMap = new Map<String,CSM_Account_Plan__c>{accountID+'' => accountPlanList[0]};
			Map<String, Set<String>> accountPlaysMap = new Map<String,Set<String>>{accountID+'' => playSet};
 			//CSM_Account_Plan_Playbook__c
            //Builds a map of play's playtasks
            Map<String,List<CSM_Play_Task__c>> playsPlayTaskMap  = CSM_TaskCreationTriggerUtil.buildPlaysPlayTaskMap(playTaskList);
            Map<String,CSM_TaskWrapper> taskWrapperMap = CSM_TaskCreationTriggerUtil.buildTaskWrapperMap(playMap, playbookPlayMap, accountPlanbyAccountMap,accountPLaysMap, playsPlayTaskMap,true);
            //Create Set of Task Ids to query task processing object.
            List<CSM_Task_Processing__c> taskProcessingList = CSM_TaskProcessingDataAccess.getActiveTasks(playSet, new Set<Id>{accountID});
            //Loop through task processing, if it exists in map, remove it. 
            //Items in taskWrapperMap at the end will be sent to task creation
            for (CSM_Task_Processing__c t : taskProcessingList) {
                String uniqueId = t.CSM_Success_Plan__r.CSM_AccountId__c + ':' +t.CSM_Play__c +':'+ t.CSM_PlayTask__c;
                //If the taskWrapperMap contains the account/play/playtaskcombination remove it
                if(taskWrapperMap.containsKey(uniqueId)) {
                    taskWrapperMap.remove(uniqueId);
                }
            }
            taskWrapperList = taskWrapperMap.values(); 
			System.debug('\n\ntaskWrapperList: ' + taskWrapperList);
			if(taskWrapperList != null && !taskWrapperList.isEmpty()){
    			CSM_TaskDataAccess.createUpdateTaskListFromWrapper(taskWrapperList);
			}
			//CSM_TaskCreationTriggerUtil.setSuccessPlanPlayOnTaskAndTaskProcessing(new Set<Id>{accountID}, new Set<String>{playbookId}, playSet, taskWrapperMap);
			
		}
    	return taskWrapperList;
    }
    
    public List<CSM_TaskWrapper> getTaskWrapperList(String accountPlanId)//, boolean fromValidation
    {   	
    	List<CSM_TaskWrapper> taskWrapperList = new List<CSM_TaskWrapper>();
    	//create tasks for the added playbook
		Set<String> playbookIds = new Set<String>();
		Set<Id> accountSet = new Set<Id>();
		Map<Id, Set<Id>> accountToPbMap = new Map<Id, Set<Id>>();
		Map<String,CSM_Account_Plan__c> accountPlanbyAccountMap = new Map<String,CSM_Account_Plan__c>();
			    		
		playbookIds.add(playbookId);
		List<CSM_Account_Plan__c> accountPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(accountPlanId, null);
		if(accountPlanList!=null && !accountPlanList.isEmpty())
		{
			accountSet.add(accountPlanList[0].CSM_AccountId__c);
			accountPlanbyAccountMap.put(accountPlanList[0].CSM_AccountId__c, accountPlanList[0]);
			accountToPbMap.put(accountPlanList[0].CSM_AccountId__c, new Set<Id>{(Id)playbookId});
		}
		taskWrapperList = CSM_TaskCreationTriggerUtil.CreateUpdateTaskWrapper(playbookIds, 
				accountSet, accountPlanbyAccountMap, null, null, accountToPbMap,false);
		return taskWrapperList;
    }
    
    
    /** 
	 * @description	validatie playbook to be added.
	 */
    public void playbookValidation() //boolean fromValidation
    {
    	if(!String.isEmpty(playbookId) && (!String.isEmpty(accountPlanId)))
	    {
	    	doValidation = true;
	    	
	    	playbookAdded = verifySPPlaybookExists(playbookId, accountPlanId); 
	
	    	isPlaybookInactive = verifyPlaybookInActive(playbookId);
	    	
	    	if(!isCriteriaSkipped){
		    	List<CSM_TaskWrapper> taskWrapperList = getTaskWrapperList(accountPlanId);//,fromValidation
		    	if(taskWrapperList==null || taskWrapperList.isEmpty())
				{
					playCriteriaValidation = true;
				}  
	    	}
	    }  	
    }

     /** 
	 * @description	check if playbook already added to success plan.
	 */
    public boolean verifySPPlaybookExists(String playbookId, String accountPlanId) 
    {
    	String acctPlanTempId = '';
    	try 
    	{
    		List<CSM_Account_Plan__c> accPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(accountPlanId, null);
			if(accPlanList!=null && !accPlanList.isEmpty()){
				acctPlanTempId = accPlanList[0].CSM_Account_Plan_Template__c;
			}
    		List<CSM_Account_Plan_Playbook__c> accPlanPlaybooksList = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByAccPlanId(accountPlanId, acctPlanTempId);
    		for(CSM_Account_Plan_Playbook__c app : accPlanPlaybooksList)
    		{
    			if(app.CSM_Playbook__c == playbookId)
    			{
    				return true;
    			}
    		}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return false;
    }
    
    /** 
	 * @description	check if Playbook is active.
	 */
    public boolean verifyPlaybookInActive(String playbookId) 
    {
    	try 
    	{
    		List<CSM_Playbook__c> tmpList = CSM_PlaybooksDataAccess.getPlaybooksById(playbookId);
	    	if(tmpList!=null && !tmpList.isEmpty())
	    	{
	    		if(!tmpList[0].CSM_IsActive__c)
	    		{
	    			return true;
	    		}
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return false;
    }
    
     /** 
	 * @description	create new playbook page.
	 */
    public PageReference createPlaybook() {
    	try
    	{
			if(CSM_AcctPlanTemplatePlaybooksDataAccess.createPlaybookAvailable())
			{
		    	PageReference pageRefTemp = Page.CSM_PlaybooksList;
				String rUrl = pageRefTemp.getURL();
				if(retUrl != null) {
					rUrl = retUrl;
				}
				rUrl = EncodingUtil.urlEncode(rUrl,CSM_Constants.UTF_8);
				PageReference PageRef = Page.CSM_PlaybookManagement;
				pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
				pageRef.setRedirect(true);
				return pageRef;
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	public PageReference editPlaybook() {
		if(CSM_AcctPlanTemplatePlaybooksDataAccess.updatePlaybookAvailable())
		{
	    	PageReference pageRefTemp = Page.CSM_PlaybooksList;//Page.csm_playbookmanagement;
			pageRefTemp.getParameters().put('tabCategory', 'SuccessPlan');
			String rUrl = pageRefTemp.getURL();
			if(retUrl != null)
			{
				rUrl = retUrl;
			}
			
			rUrl = EncodingUtil.urlEncode(rUrl,CSM_Constants.UTF_8);
			PageReference PageRef = Page.CSM_PlaybookManagement;
			pageRef.getParameters().put(CSM_Constants.ID_PARAM,playbookId);
			pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
			pageRef.setRedirect(true);
			return pageRef;
		}
		return null;
	}
    
    /** 
	 * @description	returns to previous page
	 */
    public PageReference cancelAddPlaybook() {
    	PageReference pageRef = new PageReference(retUrl);
		pageRef.setRedirect(true);
		return pageRef;
    }
    
    public void activatePlaybook() {
    	try {
	    	if(!String.isEmpty(playbookId))
	    	{
	    		boolean isSuccessful = CSM_PlaybooksDataAccess.activatePlaybooks(new List<String>{playbookId});
	    		playbookId = '';
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	
    }
    public void deactivatePlaybook() {
    	try {
	    	if(!String.isEmpty(playbookId))
	    	{
	    		boolean isSuccessful = CSM_PlaybooksDataAccess.deactivatePlaybooks(new List<String>{playbookId});
	    		playbookId = '';	
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    }
	/*Getting count of Account-Playbook Template*/
	public PageReference getAccountPlaybookTemplateCount()
	{
		List<CSM_Account_Plan_Playbook__c> accntplaybooktemplateList = new List<CSM_Account_Plan_Playbook__c>();
    	accountplaybooktempCount = 0;
    	acctplaybooktempName = '';
    	acctplaybookSuccessPlan = '';
    	successplantempDisplayList = '';
		try
		{
			accntplaybooktemplateList = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByPlaybookId(playbookId);
			if(accntplaybooktemplateList != null && !accntplaybooktemplateList.isEmpty())
			{
				accountplaybooktempCount = accntplaybooktemplateList.size();
				if(accountplaybooktempCount <= 5 && accountplaybooktempCount != 0)
				{
					List<String> spDisplayNamesList = new List<String>();
					
					for(CSM_Account_Plan_Playbook__c app :accntplaybooktemplateList)
					{
						acctplaybooktempName = app.CSM_Account_Plan_Template__r.CSM_Template_Name__c;
						acctplaybookSuccessPlan = app.CSM_Account_Plan__r.CSM_DisplayName__c;		
					    if(acctplaybooktempName != null)
						{
							spDisplayNamesList.add(acctplaybooktempName);
							//successplantempDisplayList += acctplaybooktempName;
						}
						if(acctplaybookSuccessPlan != null)
						{
							spDisplayNamesList.add(acctplaybookSuccessPlan);
							//successplantempDisplayList += acctplaybookSuccessPlan;
						}	
						/*if(successplantempDisplayList != null)
						{
							successplantempDisplayList += '\\n';
						}*/
						acctplaybooktempName = '';
					    acctplaybookSuccessPlan = '';
					}
					successplantempDisplayList = JSON.serialize(spDisplayNamesList);
				}
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_PLAYBOOK_DELETE));
				return deleteAccountPlanPlaybookAssoc();
			}
		}
		catch(exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
		}
		return null;
	} 
	/*Delete Playbook association and Playbook*/
	public PageReference deleteAccountPlanPlaybookAssoc()
	{
		List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		List<CSM_Playbook__c> playbookList = new List<CSM_Playbook__c>();
		try
		{
			accountPlanPlaybookList = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByPlaybookId(playbookId);
			playbookList = CSM_PlaybooksDataAccess.getPlaybooksById(playbookId);
			if(accountPlanPlaybookList != null && !accountPlanPlaybookList.isEmpty())
			{
				boolean isSuccess;
				isSuccess = CSM_AcctPlanTemplatePlaybooksDataAccess.deleteAcctPlanTemplatePlaybook(accountPlanPlaybookList);
				if(isSuccess == true)
				{
					if(playbookList != null && !playbookList.isEmpty())
					{
						CSM_PlaybooksDataAccess.deletePlaybook(playbookList);
					}
				}
			}
			else if(playbookList != null && !playbookList.isEmpty())
			{
				CSM_PlaybooksDataAccess.deletePlaybook(playbookList);	
			}
		}
		catch(exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
		}
		return null;
	}
  /**
   * @description Clone Playbook
   *
   * @return  PageReference to csm_playbookslist page
   */
  public PageReference clonePlaybook() {  
      try {
          List<CSM_Playbook__c> pbList = CSM_PlaybooksDataAccess.clonePlaybook(new String[] {
              playbookId
          });
          List<CSM_PlaybookPlay__c> playbookPlayList = CSM_PlaybooksDataAccess.GetPlaybookPlayList(new String[] {
              playbookId 
          });
          List<CSM_PlaybookPlay__c> conedPlaybookPlay = CSM_PlaybooksService.getClonePlaybookPlayList(playbookPlayList,pbList);
          CSM_PlaybooksDataAccess.InsertClonedPlaybookPlayList(conedPlaybookPlay);
          PageReference pageRef = page.csm_playbookslist;
          pageRef.getParameters().put('tabCategory', 'SuccessPlan');
          pageRef.setRedirect(true);
          return pageRef;
      } catch (exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
          return null;
      }
  }
}