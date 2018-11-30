/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.25.2014
* @description    CSM_TaskListComponentController class contains methods for supporting the Task Data Access  
*/
public with sharing class CSM_PlayTasksComponentController extends CSM_CustomPaginator {

	private static final String DEFAULT_SORT_EXPRESSION = 'ActivityDate';
	private List<Task> accountPlanTaskList {get; set;}
	public Task taskVal {get; set;}
	public Task newTask {get; set;}
 	public Boolean isComplete {get; set;}
 	public Boolean isMultiple {get; set;} 	
 	//public List<SelectOption> riskReasonList {get; private set;}
 	//public List<SelectOption> riskReasonDismissList {get; private set;}
 	//public List<SelectOption> newRiskReasonList {get; private set;} 	
	public List<SelectOption> taskFilterOptions{get;set;}
	public List<String> taskTableColumnNames{get;set;}
 	public String whatIdVal {get; set;}
 	public String taskId {get; set;}
	public Boolean followUpTask {get; set;}
	public String accountSelected {get; set;}
	public String playSelected {get; set;}
	public String widgetTaskId {get; set;}
	public String selectedTaskFilter{get;set;}
	public String sortExpression{get;set;}
	public String sortDirection{get;set;}
	public String successPlan {get; set;}
	public List<CSM_Account_Plan__c> successPlanList {get; set;}
	public String accId{get;set;}
	public CSM_Play__c playObj {get;set;}
 	private Map<Id, Task> taskCheckMap; 
	private CSM_TaskDataAccess taskDataAccess = new CSM_TaskDataAccess();
	
	public String helpParamComplete {get; set;}
	public String helpParamDismiss {get; set;}
	
	//public String columnList {get; set;}
	//public String selectedColumns {get; set;}
	public String hiddenColumns {get; set;}
	public CSM_User_Preferences__c preferenceObj{get; set;}
	
	// US1378
	public String strRecordType {get; set;} 
	
	//US1380
	public String strTaskStatus {get;set;}
		
 	/*
    *   the task ids selected by the user
    */
    private Set<Id> selectedTaskIds;
    
	public List<Schema.FieldSetMember> mandatoryFieldsInFieldSet{get;set;}
	private Set<String> completeDismissPopupFieldsSet;
	private List<String> fieldSetAndPopupFieldsCombo;
	public Task tempTask;
	public List<SelectOption> newTaskRiskReasonList {get; private set;}	
	public CSM_DataGridAttribute playTasksGridAttribute {get; set;}
	public boolean isSetPlayOutcome {get;set;}
	public boolean isStatusClosed {get;set;}
	public string playOutcomeValue {get;set;}
 	public Boolean inheritTaskType {get;set;} 	
 
	public CSM_PlayTasksComponentController() {
		inheritTaskType = CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c;
		taskVal = new Task();
		newTask = new Task();
		isMultiple = true;		
		tempTask = (Task)Task.SObject.sObjectType.newSObject(null, true);
		//riskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
		//riskReasonDismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
		String accPlanId = ApexPages.currentPage().getParameters().get('Id');
		List<CSM_Account_Plan__c> accPlanList = CSM_AccountPlanDataAccess.getAccountPlanById(accPlanId);
		if(accPlanList!=null && !accPlanList.isEmpty()){
			accId=accPlanList[0].CSM_AccountId__c;
		}
		accountSelected = '';
		playSelected = '';
		widgetTaskId = '';
		helpParamComplete = CSM_Constants.HELP_TASK_COMPLETE;
		helpParamDismiss = CSM_Constants.HELP_TASK_DISMISS;
		isStatusClosed = false;
		isSetPlayOutcome = false;
		//this.selectedTaskFilter = CSM_Constants.TASK_FILTER_OPTION_ALL;
		this.sortDirection = CSM_Constants.SORT_DIRECTION_DESCENDING;
		this.sortExpression = DEFAULT_SORT_EXPRESSION;
		//this.populateColumnNames();
		//get the fieldSet Values for the task
		completeDismissPopupFieldsSet = new Set<String>{'Id', 'Subject', 'CSM_Play__r.CSM_Display_Name__c', 'CSM_Risk_Reason__c', 'CSM_Task_State__c', 'CSM_Completed_Date__c', 'Description'};
		createFieldSetAndPopUpCombo(false);
		preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'CSM_Success_Plan_Actions_Filter__c,CSM_Success_Plan_Actions_Grid_Columns__c');
		System.debug('preferenceObj - '+preferenceObj);
		if(preferenceObj == null) {
			preferenceObj = new CSM_User_Preferences__c();
			preferenceObj.CSM_User__c = UserInfo.getUserId();		
		} 
	}
	private void setPlayTaskAttributes()
	{
		playTasksGridAttribute = new CSM_DataGridAttribute();
		playTasksGridAttribute.viewName = CSM_Constants.GRID_ATTR_ACT_TAB;
		playTasksGridAttribute.stateSave = CSM_Constants.GRID_ATTR_FALSE;		
		playTasksGridAttribute.tableName = CSM_Constants.GRID_ATTR_ACT_SP_GRID;
		playTasksGridAttribute.objectType = CSM_Constants.OBJ_TYPE_TASK;	
		playTasksGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
		playTasksGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
		playTasksGridAttribute.setFilterControl(CSM_Constants.GRID_ATTR_TRUE);
		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
		gridInputParams.selectedTaskFilter = '';
    	/*if (String.isBlank(selectedTaskFilter))
      	{
      		
      	}
      	else
      	{
     		gridInputParams.selectedTaskFilter = this.selectedTaskFilter;
     	}*/
     	gridInputParams.accountId = this.accountId;
     	playTasksGridAttribute.params = JSON.serialize(gridInputParams);
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		playTasksGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
	}
	
	public void createFieldSetAndPopUpCombo(boolean isNewTask){
		fieldSetAndPopupFieldsCombo = new List<String>();
		mandatoryFieldsInFieldSet = new List<Schema.FieldSetMember>();
		List<Schema.FieldSetMember> tmpFieldsList;		
		if(isNewTask){
			tmpFieldsList = SObjectType.Task.FieldSets.CSM_New_Task_Popup.getFields();		
		}else{
			tmpFieldsList = SObjectType.Task.FieldSets.CSM_CompleteDismiss_Popup.getFields();		
		}
		
		Map<String, Schema.SObjectField> objFieldInfo = Task.getSObjectType().getDescribe().fields.getMap();
		String fieldAccessibility = '';
		for(Schema.FieldSetMember f : tmpFieldsList) {
			fieldAccessibility = String.valueOf(f.getFieldPath());
			if (objFieldInfo.containsKey(fieldAccessibility)){
				Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(fieldAccessibility).getDescribe();
	            if (String.valueOf(f.Type) != 'ID' && fieldDescription.isAccessible()){
	            	mandatoryFieldsInFieldSet.add(f);
	            }
			}
        }
		//set up the combined fieldsList based on which we will query the fields
		for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
			if (!completeDismissPopupFieldsSet.contains(f.FieldPath)){
				fieldSetAndPopupFieldsCombo.add(f.FieldPath);
			}
		}		

		/*if(!isNewTask){
			for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
				if (!completeDismissPopupFieldsSet.contains(f.FieldPath)){
					fieldSetAndPopupFieldsCombo.add(f.FieldPath);
				}
			}		
		}else{
			for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
				if (!completeDismissPopupFieldsSet.contains(f.FieldPath)){
					fieldSetAndPopupFieldsCombo.add(f.FieldPath);
				}
			}		
		
		
		}*/
		//finally, add all the fields of popup
		fieldSetAndPopupFieldsCombo.addAll(completeDismissPopupFieldsSet);
		//fieldSetAndPopupFieldsCombo.addAll(mandatoryFieldsInFieldSet);		
	}	

	public String accountPlanId {
		get{
			return accountPlanId;
		} 
		set;
	}
	
	public String accountId{
		get;
		set{
			if (String.isNotBlank(value)){
				accountId = String.escapeSingleQuotes(value);
				setPlayTaskAttributes();
			}
		}
	}
	
	public CSM_PlayTasksComponentController getThis(){
    	return this;
	}
	
	public PageReference getTaskForPlanId() {
		this.accountPlanTaskList = new List<Task>();
		//use the play as the key
		taskCheckMap = new Map<Id, Task>();
		this.sortDirection = CSM_Util.toggleSortDirection(this.sortDirection);
		String acctId = String.escapeSingleQuotes(this.accountId);
		//String selTaskFilter = String.escapeSingleQuotes(this.selectedTaskFilter);
		String sortExp = String.escapeSingleQuotes(this.sortExpression);
		String sortDir = String.escapeSingleQuotes(this.sortDirection);
		
		this.accountPlanTaskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(acctId, null, sortExp, sortDir);
		for (Task t : accountPlanTaskList) {
			taskCheckMap.put(t.Id, t);
		}
		//this.resourcesList = accountPlanTaskList;
		//MF Changed to reference paginator method
		//initiateResourcesList(accountPlanTaskList);
		this.pageNumber = 1;
		this.pageSize = 10;
	    this.updatePages();
		if (!this.accountPlanTaskList.isEmpty()){
 			this.accountSelected = this.accountPlanTaskList[0].CSM_Account_Plan__r.CSM_AccountId__c ;
 			this.playSelected = this.accountPlanTaskList[0].CSM_Play__c;
 			this.widgetTaskId = this.accountPlanTaskList[0].id;
 		}
		return null;
	}
	
	public PageReference setTaskInfo() {
		/*taskVal = new Task();
		selectedTaskIds = new Set<Id>();
		if (taskId!=null) {
			taskVal = taskCheckMap.get(taskId);
			selectedTaskIds.add(taskVal.Id);
		}*/
		return null;
	}
    public PageReference resetPopupForNewTask() {
    	newTask = new Task();
    	newTask.Status = 'Not Started';
    	setMandatoryFieldsForTask(newTask, true);
    	return null;	
    }
	
	
	public PageReference newTaskDetails() {
		newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);
		isMultiple = false;
		createFieldSetAndPopUpCombo(true);		
		newTask = new Task();
		playObj = new CSM_Play__c();
		//newTask = tempTask;
		//setMandatoryFieldsForTask(newTask,true);			
		
		if(String.isNotBlank(accountId)){
			newTask.WhatId = accountId;
			this.accountSelected = accountId;
		}
		if(String.isNotBlank(widgetTaskId))
		{
				system.debug('Selected TaskID:'+widgetTaskId);
				Set<Id> taskIdSet = new Set<Id>();
				taskIdSet.add(widgetTaskId);
				List<Task> TaskPlay = CSM_TaskDataAccess.getSSPLForSelectedTask(taskIdSet); 
				newTask.CSM_SuccessPlan_Play__c = TaskPlay[0].CSM_SuccessPlan_Play__c;
				system.debug('SPPL:'+TaskPlay[0].CSM_SuccessPlan_Play__c);
		}
		String acctPlanId = String.escapeSingleQuotes(this.accountPlanId);
		successPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(acctPlanId, null);
		playObj = CSM_PlaysDataAccess.populatePlayInformation(playSelected);	
		if(successPlanList!=null && !successPlanList.isEmpty()){
			newTask.CSM_Account_Plan__c = successPlanList[0].Id;
			successPlan = successPlanList[0].CSM_DisplayName__c;
			newTask.CSM_Play__c = playObj.id;
		}
		setMandatoryFieldsForTask(newTask, true);
		system.debug('tesk3  - ' + newTask);		
		return null;
	}
		
	private String getRetURL(){
		// Get current page url through page reference 
		PageReference pageRefTemp = Page.CSM_AccountSuccessPlan;
		String retURL = pageRefTemp.getURL() + '?' + CSM_Constants.OBJ_IG_ID + '=' + accountPlanId +'%26'+CSM_Constants.SELECTED_TAB+'='+CSM_Constants.SELECTED_TAB_PLAYS;
		return retURL;	
	}
	
	public PageReference emailToWhatId() {
		try {

			String url = CSM_Constants.EMAIL_URL+whatIdVal +CSM_Constants.PARAM_RETURN_URL+getRetURL();
			
			// Get the List View through standard page
			PageReference pageRef = new PageReference(url);
			pageRef.setRedirect(true);
			return pageRef;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
		
	}
			
	/**
	* @description redirectToTask - Redirect to Task View 
	*
	* @return PageReference 
	*/
	public PageReference redirectToTask() {
		PageReference ref = null;
		if (taskId!=null){
			
			ref = new PageReference('/'+taskId);
			ref.setRedirect(true);
		}
		return ref;
	}
	
	//Added for US1264
	public PageReference getClosedStatus() {
		isStatusClosed = false;
		isSetPlayOutcome = false;
		playOutcomeValue = '';
		system.debug('##Status : '+taskVal.Status);		
		Set<String> taskClosedStatusSet = CSM_TaskDataAccess.taskClosedStatusSet;
		system.debug('taskClosedStatusSet : '+taskClosedStatusSet);
		if(taskClosedStatusSet.contains(taskVal.Status)) {
			isStatusClosed = true;
		}
		system.debug('##isStatusClosed : '+isStatusClosed);
		return null;
	}
			
	public PageReference completeDismissTask() {
		try
		{
			List<Task> taskValList = new List<Task>();
			taskValList.add(taskVal);
			if(isSetPlayOutcome == true && String.isBlank(playOutcomeValue)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_ERR_SET_PLAYOUTCOME)); 
			} else {
				CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false; 
				//CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
				//taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), taskValList, mandatoryFieldsInFieldSet, isComplete, true, false);			
				if (followUpTask)
				{
					Task newTask = new Task();
					newTask.CSM_Account__c = taskVal.CSM_Account__c;
					newTask.CSM_Play__c = taskVal.CSM_Play__c;
					newTask.CSM_Play_Task__c = taskVal.CSM_Play_Task__c;
					newTask.CSM_Account_Plan__c = taskVal.CSM_Account_Plan__c;
					newTask.Status = 'Not Started';//taskVal.Status;
					newTask.CSM_Risk_Reason__c = '';						
					newTask.REN_Opportunity__c = taskVal.REN_Opportunity__c;
					newTask.description = taskVal.description;
					if(CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c){
						String RecordTypeId = (string)taskVal.get('RecordTypeId');
						newTask.put('RecordTypeId',RecordTypeId);
						//system.debug('InheritRecordType'+taskVal.RecordTypeId);
					}else{
							if(CSM_Util.getRecordTypeExists(new Task())){
							newTask.put('RecordTypeId',strRecordType);
							}
					}				
					newTask.ownerId = taskVal.ownerId;
					newTask.whoId = taskVal.whoId; 
					newTask.whatId = taskVal.whatId;
					newTask.CSM_SuccessPlan_Play__c = taskVal.CSM_SuccessPlan_Play__c;
					if (newTask.ActivityDate==null){
						newTask.ActivityDate = Date.today();
					}
					
					newTask.subject = CSM_Constants.TASK_FOLLOWUP_SUBJECT + taskVal.subject;
					setMandatoryFieldsForTask(newTask, true);
					List<Task> taskList = new List<Task>();
					taskList.add(newTask);
					system.debug('taskList--1---'+taskList);
					CSM_TaskDataAccess.createTasks(taskList,followUpTask);
					
					if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
					{
						CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
						taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), taskValList, mandatoryFieldsInFieldSet, isComplete, true, false);			

						String url = '/' + newTask.id + CSM_Constants.TASK_EXISTING_URL  + getRetURL();
						// Get the List View through standard page
						PageReference pageRef = new PageReference(url);
						pageRef.setRedirect(true);
						return pageRef;
					}else{
						return null;
					}
				} else{
					CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
					taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), taskValList, mandatoryFieldsInFieldSet, isComplete, true, false);			
				}
				taskVal = new Task();
				setMandatoryFieldsForTask(taskVal,false);	
			}		
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
		return null;
	}
	
	public PageReference resetTask() {
		taskVal = new Task();
		taskVal = tempTask;		
		//followUpTask = false;
		//this.selectedTaskIds = new Set<Id>();
		return null;
		
		
	}	
	
	public PageReference getValidateSuccessPlan() 
    {   
    	if (String.isNotBlank(newTask.CSM_SuccessPlan_Play__c))
    	{
			List<CSM_SuccessPlan_Play__c> successPlanPlayList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListbyId(new Set<Id> {newTask.CSM_SuccessPlan_Play__c});
	        if(successPlanPlayList != null && !successPlanPlayList.isEmpty() 
	                && successPlanPlayList[0].CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__r.CSM_AccountId__c != accountSelected)
	        {
	           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CSM_LBL_ERROR_MASG_SP_PLAY_RELATED_ACCOUNT));
	        }
    	}
		return null;
    }
    	
	public PageReference createNewTask() {
		Map<Id,CSM_SuccessPlan_Play__c> spPlMap = new Map<Id,CSM_SuccessPlan_Play__c>(); // US1454  SP_PL object which has evalution date = null  will be added in the map.
		try {
			Task createTask = new Task();
			createTask.subject = newTask.subject;
			//createTask.CSM_Play__c = newTask.CSM_Play__c;
			createTask.whatId = newTask.whatId;
			createTask.Type = newTask.Type;
			if (newTask.Status == null)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Status: '+Label.MSG_MUST_ENTER_VALUE));
                return null;
			}
			else
			{
			    createTask.Status = newTask.Status;
			}
			createTask.CSM_Risk_Reason__c = newTask.CSM_Risk_Reason__c;		
			createTask.CSM_SuccessPlan_Play__c = newTask.CSM_SuccessPlan_Play__c;	
			if(newTask.CSM_SuccessPlan_Play__c != null){
				List<CSM_SuccessPlan_Play__c> successPPList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListbyId(new Set<Id> {newTask.CSM_SuccessPlan_Play__c});
				createTask.CSM_Play__c = successPPList[0].CSM_Play__c;
				createTask.CSM_Account_Plan__c = successPPList[0].CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c;
				if(successPPList[0].CSM_Evaluation_Date__c	== null) {
						spPlMap.put(successPPList[0].id,successPPList[0]);
				}
				if(newTask.whatId != accountSelected){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CSM_LBL_ERROR_MASG_SP_PLAY_ACCOUNT_CHANGED));
                    return null;
                }
                else if(successPPList[0].CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__r.CSM_AccountId__c != newTask.whatId){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CSM_LBL_ERROR_MASG_SP_PLAY_RELATED_ACCOUNT));
                    return null;
                }
			}
			else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.SUCCESS_PLAN_PLAY_ERROR));
				return null;
			}
			if (newTask.ActivityDate == null)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.MSG_DUE_DATE_REQUIRED));
				return null;
			}			
			else
			{ 
				createTask.ActivityDate = newTask.ActivityDate;
			}
			createTask.description = newTask.description;
			setMandatoryFieldsForTask(createTask,true);
			List<Task> taskList = new List<Task>();
			taskList.add(createTask);
			system.debug('tesk  - ' + newTask);			
			CSM_TaskDataAccess.createTasks(taskList,false);
			CSM_TaskCreationTriggerUtil.setSPPlEvalutionDate(taskList, spPlMap); //US1454 - Set evaluation on SP_PL.
			system.debug('tesk1  - ' + newTask);			
			// For DE921
			/*List<Task> newTasks = new List<Task>();
			newTasks.add(createTask);
			CSM_TaskDataAccess.createTasks(newTasks);*/
			String url = '/' + createTask.id + CSM_Constants.TASK_EXISTING_URL  + getRetURL();
			// Get the List View through standard page
			PageReference pageRef = new PageReference(url);
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch(system.DmlException dmlEx){
			system.debug('Ex type -----> '+dmlEx.getDmlType(0));
			if(!dmlEx.getDmlType(0).equals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, dmlEx.getMessage()));
			}
		}
    	catch (Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
    	}
    	return null;
	}
	
	public PageReference addPlayBook() {
		return null;
	}

	public PageReference updateTabs() {
		return null;
	}
	
	public PageReference updateWidget() {
    	this.accountSelected = accountSelected; 
    	this.playSelected = playSelected;
    	this.widgetTaskId = widgetTaskId;
    	return null;
    }
    
   /*private void populateTaskFilterOptions(){
       this.taskFilterOptions = new List<SelectOption>();
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_ALL, System.Label.CSM_LBL_ALL)); 
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_ASSIGNED_TO, System.Label.CSM_LBL_ASSIGNEDTO)); 
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_HASPLAY, System.Label.CSM_LBL_HAS_PLAY)); 
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_PLAY, Schema.SobjectType.CSM_Play__c.label));
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_PLAYBOOK, Schema.SobjectType.CSM_Playbook__c.label));
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_RECORD_TYPE, System.Label.CSM_LBL_RECORD_TYPE));
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_RELATED_TO, System.Label.CSM_LBL_RELATEDTO));
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_TASK_TYPE, System.Label.CSM_LBL_Task_Type));
	   this.taskFilterOptions.add(new SelectOption(CSM_Constants.TASK_FILTER_OPTION_UNDETERMINEDPLAY, System.Label.CSM_LBL_UNDETERMINED_PLAY));
   }*/
    
    
    // code for action tab grid start
    
    public PageReference setEmailTask() {
    	if (taskId != null) {
    		
    		taskVal = new Task();
    		this.taskCheckMap = null;
			try {
				//setup the taskCheckMap
				this.taskCheckMap = new Map<Id, Task>(CSM_TaskDataAccess.getTasksById(taskId));
				taskVal = this.taskCheckMap.get(taskId);
				whatIdVal = taskVal.WhatId;
				
				String url = CSM_Constants.EMAIL_URL+whatIdVal +CSM_Constants.PARAM_RETURN_URL+getRetURL();
				
				// Get the List View through standard page
				PageReference pageRef = new PageReference(url);
				pageRef.setRedirect(true);
				return pageRef;
			}
	    	catch (exception ex)
	    	{
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
	    		return null;
	    	}
    	}
    	return null;
    }
    
    public PageReference setTaskAndShowPopup() {
    	this.selectedTaskIds = new Set<Id>();    	
    	isStatusClosed = false;
		isSetPlayOutcome = false;
    	taskVal = new Task();	
    	if(this.isComplete){
			newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
    	}else{
    		newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
    	}
    	if (taskId != null) {
    		this.selectedTaskIds.add((Id)taskId);
			this.taskCheckMap = new Map<Id, Task>(CSM_TaskDataAccess.getTasksById(taskId, fieldSetAndPopupFieldsCombo));
    		//this.taskCheckMap = new Map<Id, Task>(CSM_TaskDataAccess.getTasksById(taskId));
			if (this.taskCheckMap != null && this.taskCheckMap.containsKey(taskId)) {
				taskVal = this.taskCheckMap.get(taskId);
			}    		
			if (taskVal.CSM_Completed_Date__c==null){
            	taskVal.CSM_Completed_Date__c = Date.today();
            } 
    	}
		setMandatoryFieldsForTask(taskVal,false);			
    	return null;
    }
    
    public PageReference resetWidgetForNewTask() {
		accountSelected = '';
		playSelected = ''; 
		widgetTaskId = ''; 
		saveFilterToUserPreference();
    	return null;
    }    
    
    // code for action tab grid end
    
   	public void setMandatoryFieldsForTask(Task taskVal,boolean isNewTask) {
		if (mandatoryFieldsInFieldSet != null && !mandatoryFieldsInFieldSet.isEmpty()) {
			// populate the mandatory fields for the Task and reset them to TaskVal
			
				for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
					Map<String, Schema.SObjectField> objFieldInfo = Task.getSObjectType().getDescribe().fields.getMap();
					String fieldAccessibility = '';
					fieldAccessibility = String.valueOf(f.getFieldPath());
					Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(fieldAccessibility).getDescribe();
					if(fieldDescription.isUpdateable()){
						if (taskVal.get(f.FieldPath) == null) {
							System.debug('VVV - isNewTask - '+isNewTask);
							System.debug('VVV - newTask.get(f.FieldPath) - '+newTask.get(f.FieldPath));
							System.debug('VVV - TaskVal.get(f.FieldPath) - '+TaskVal.get(f.FieldPath));
							if(isNewTask){
								if (newTask.get(f.FieldPath) == null){
									taskVal.put(f.FieldPath, tempTask.get(f.FieldPath));
								} else {
									taskVal.put(f.FieldPath, newTask.get(f.FieldPath));
								}	
							}else{
								if (TaskVal.get(f.FieldPath) == null){
									taskVal.put(f.FieldPath, tempTask.get(f.FieldPath));						
								} else {
									taskVal.put(f.FieldPath, TaskVal.get(f.FieldPath));
								}			
							}
						}
					}
				}
		}   		
   	}
   	
    public PageReference saveColumnsToUserPreference(){
	    try {
	    	preferenceObj.CSM_Success_Plan_Actions_Grid_Columns__c = hiddenColumns;
	    	List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    	userPreferenceList.add(preferenceObj);
	    	CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Plan_Actions_Grid_Columns__c');
	    	//system.debug('Final List:'+columnList);
	    }catch (exception ex) {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		    return null;
		}
    	return null;
    }
    
    public void saveFilterToUserPreference() {
	    /*try {
	    	//System.debug('selectedTaskFilter - '+selectedTaskFilter);
	   		if(selectedTaskFilter != null) {
	   			preferenceObj.CSM_Success_Plan_Actions_Filter__c = selectedTaskFilter;
	   			system.debug('Inside Save Filter' + preferenceObj.CSM_Success_Plan_Actions_Filter__c);
	   			List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    		userPreferenceList.add(preferenceObj);
	    		CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Plan_Actions_Filter__c');
	   		}
	    }catch (exception ex) {
	    	//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		}*/
   	}
   	//Added for US1264
   	public List<SelectOption> getPlayOutcomeValues() {
  		//sObject sobj = Schema.getGlobalDescribe().get(CSM_Util.getNamespace()+'CSM_SuccessPlan_Play__c').newSObject();
		sObject sobj = new CSM_SuccessPlan_Play__c();
		List<SelectOption> options = CSM_Util.getPicklistValues(sobj,'CSM_Play_Outcome__c');
		options.add(new SelectOption('','--None--')); 
   		options.sort();
   		return options;
   	}
   	
   	//US1378
   //Create our list of record types
	public list<SelectOption> getRecordTypes()
	{
		list<SelectOption> options = new list<SelectOption>();
		List<RecordType> TaskRecordTypes = CSM_TaskDataAccess.getRecordTypeTask();
		if (CSM_Util.getRecordTypeExists(new Task())){
		for(RecordType sRecordType :TaskRecordTypes){
             // Select options are added with key,value pairing
            options.add(new SelectOption(sRecordType.Id, sRecordType.Name));
        }
     	    options.add(new SelectOption('','--None--')); 
   	 	    options.sort();   
   	 	}else{
   	 		 options.add(new SelectOption('','--None--')); 
   	 	} 
	         return options;
	}
	
	// US1380
	 public list<SelectOption> getTaskStatus(){
		list<SelectOption> options = new list<SelectOption>();
		List<TaskStatus> TaskStatus = CSM_TaskDataAccess.getTaskStatus();
  		for(TaskStatus stask :TaskStatus){
        	options.add(new SelectOption(stask.MasterLabel, stask.MasterLabel));
        }
     		options.add(new SelectOption('','--None--')); 
   	 		options.sort();   
   	 	   	return options;
	}

}