/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.25.2014
* @description    CSM_TaskListComponentController class contains methods for supporting the Task Data Access  
*/
public with sharing class CSM_TaskListComponentController {

	public List<SelectOption> taskViewList {get; private set;}
	public String taskViewId {get; set;}
	public String titleHeader {get; private set;}
	public String subtitleHeader {get; private set;}
	public String whatIdVal {get; set;}
	public String taskId {get; set;}
	public String notifMsg {get; set;}
    public Boolean hasTasks {get; set;}
    public Boolean isSelectLabel {get; set;}
    public Boolean showNotifMsg {get;set;}
	
	public String accountSelected {get; set;}
	public String widgetTaskId {get; set;}
	public String accountPlanId {get; set;}
	public String playSelected {get; set;}
	public CSM_Play__c playObj {get;set;}
 	
	public String columnList {get; set;}
	public String selectedColumns {get; set;}
	public String hiddenColumns {get; set;}
	public String pageSize {get; set;}	
	public String searchTerm {get; set;}
	public CSM_User_Preferences__c preferenceObj{get; set;} 
	
	//MF 11/16
	public Integer itemSelected {get; set;}
	public List<TRowItem> taskWrapperList {get; set;}
	
	public String helpParam {get; set;}
	public String helpParamComplete {get; set;}
	public String helpParamDismiss {get; set;}
	
	// US1378
	public  String strRecordType {get; set;}
//	public List<SelectOption> recordTypeOptionsList{get;set;}

//US1380
	public String strTaskStatus {get;set;}
	/*
    *   item in context from the page
    */
    
    // new data grid changes start
	public String taskIds{get;set;}
    // new data grid changes end
    	
    public String contextItem{get;set;}
    public String riskReason {get; set;}
    public String successPlan {get; set;}
 	public Boolean followUpTask {get; set;}
 	public Task taskVal {get; set;} //removed private set for test class
 	public Task newTask {get; set;}
 	public Boolean isComplete {get; set;}
 	public Boolean isMultiple {get; set;}
 	//public List<SelectOption> riskReasonList {get; private set;}
 	//public List<SelectOption> riskReasonDismissList {get; private set;}
	
 	private CSM_FocusCategoriesDataAccess fcDA = new CSM_FocusCategoriesDataAccess();
	private Task revertVal {get; set;}
	private CSM_TaskDataAccess taskDataAccess;
	private Map<String, Task> taskCheckMap = new Map<String, Task>();
	public List<Integer> removeColSort {get; private set;}	
	public List<CSM_Account_Plan__c> successPlanList {get; set;}
	/*
    *   the task ids selected by the user
    */
    public Set<Id> selectedTaskIds;
	public List<Schema.FieldSetMember> mandatoryFieldsInFieldSet{get;set;}
	private Set<String> completeDismissPopupFieldsSet;
	private List<String> fieldSetAndPopupFieldsCombo;   
	private Map<String, String> mandatoryFieldValuesMap;
	public Task tempTask;
	public List<SelectOption> newTaskRiskReasonList {get; private set;}	
	public CSM_DataGridAttribute taskListGridAttribute {get; set;}
	//US1264
	public boolean isSetPlayOutcome {get;set;}
	public boolean isStatusClosed {get;set;}
	public string playOutcomeValue {get;set;}
 	public Boolean inheritTaskType {get;set;}	 

	public CSM_TaskListComponentController() {
		inheritTaskType = CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c;		
		tempTask = (Task)Task.SObject.sObjectType.newSObject(null, true);
    	isSelectLabel = true;
    	hasTasks = false;
    	showNotifMsg = false;
		followUpTask = false;    	
		removeColSort = new List<Integer>();
		removeColSort.add(0);
		removeColSort.add(1);
		removeColSort.add(7);
		isMultiple = false;
		helpParam = CSM_Constants.HELP_SUCCESS_TASKS;
		helpParamComplete = CSM_Constants.HELP_TASK_COMPLETE;
		helpParamDismiss = CSM_Constants.HELP_TASK_DISMISS;
		//riskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
		//riskReasonDismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
		taskViewId = ApexPages.currentPage().getParameters().get(CSM_Constants.PARAM_VIEWID);
		titleHeader = Label.CSM_LBL_CSM;
		subtitleHeader = Label.CSM_LBL_SUCCESS_TASKS;
		taskViewList = new List<SelectOption>();
		taskDataAccess = new CSM_TaskDataAccess();
		accountSelected = '';
		playSelected = ''; 
		widgetTaskId = '';
		//MF 
		itemSelected = 0;
		isStatusClosed = false;
		isSetPlayOutcome = false;
			
		// get the list view from set controller or metadata service
		taskViewList.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
		List<SelectOption> tempTaskViewList = fcDA.setCon(CSM_Constants.OBJ_TYPE_TASK);
		
		List<String> viewIdList = new List<String>();
		if (tempTaskViewList!=null){
			for (SelectOption so : tempTaskViewList){
				viewIdList.add(so.getValue());
			}
			CSM_Util.doSort(tempTaskViewList, CSM_Util.FieldToSort.Label);	
			taskViewList.addAll(tempTaskViewList);
		}
		if (taskViewId!=null){
			//selectedTask();
		}
		taskVal = new Task();
		newTask = new Task();
		//get the fieldSet Values for the task
		completeDismissPopupFieldsSet = new Set<String>{'Id', 'Subject', 'CSM_Play__r.CSM_Display_Name__c', 'CSM_Risk_Reason__c', 'CSM_Task_State__c', 'CSM_Completed_Date__c', 'Description'};
		createFieldSetAndPopUpCombo(false);
		
		preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'CSM_Success_Task_Filter__c,CSM_Success_Task_Page_Size__c,CSM_Success_Task_Search__c');
		if(preferenceObj == null) {
			preferenceObj = new CSM_User_Preferences__c();
			preferenceObj.CSM_User__c = UserInfo.getUserId();
			if(taskViewList.size() > 1 && taskViewList[1]!=null){
				this.taskViewId = taskViewList[1].getValue();			
			}
		} else if(String.isBlank(this.taskViewId) && preferenceObj.CSM_Success_Task_Filter__c != null) {
			taskViewId = preferenceObj.CSM_Success_Task_Filter__c;
		}
		pageSize = preferenceObj.CSM_Success_Task_Page_Size__c;
		searchTerm = preferenceObj.CSM_Success_Task_Search__c;
		setGridAttributes();
		//newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);
	}
	
	
	
	private void setGridAttributes()
	{
		setGridValues();
		resetGridParams();
	}
	
	private void setGridValues()
	{
		taskListGridAttribute = new CSM_DataGridAttribute();
		taskListGridAttribute.tableName = CSM_Constants.GRID_ATTR_TASK_GRID;
		taskListGridAttribute.objectType = CSM_Constants.OBJ_TYPE_TASK;
		taskListGridAttribute.gridToolBarId = CSM_Constants.GRID_ATTR_TOOLBAR; 
		taskListGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
		taskListGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
		taskListGridAttribute.showGlobalSelect = CSM_Constants.GRID_ATTR_TRUE;
		taskListGridAttribute.showExport = CSM_Constants.GRID_ATTR_TRUE;
		taskListGridAttribute.clickDataToSelect = CSM_Constants.GRID_ATTR_FALSE;
		taskListGridAttribute.viewName='';
		
		if (String.isNotBlank(pageSize))
		{
		    taskListGridAttribute.gridSize=Integer.valueOf(pageSize);
		}
		taskListGridAttribute.gridSearchText=searchTerm;
		Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		taskListGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());  
	}
	
	 private void resetGridParams()
    {
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridInputParams.taskOrViewId = taskViewId;
    	gridInputParams.accountId = '';	
		taskListGridAttribute.params = JSON.serialize(gridInputParams);
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
		//if(!isNewTask){
			for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
				if (!completeDismissPopupFieldsSet.contains(f.FieldPath)){
					fieldSetAndPopupFieldsCombo.add(f.FieldPath);
				}
			}		
			//finally, add all the fields of popup
			fieldSetAndPopupFieldsCombo.addAll(completeDismissPopupFieldsSet);
		//}				
	}
		
	private void getFullList(String fcViewId) {
		List<Task> taskList = new List<Task>();
		showNotifMsg = false;
		if (fcViewId!=null && fcViewId.length()>0){
			fcViewId = String.escapeSingleQuotes(fcViewId);
			List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
			try
			{
				fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewID(fcViewId);	
			}
			catch (exception ex)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			}
			if (fcViewList!=null && !fcViewList.isEmpty()){
				CSM_Focus_Category_View__c fcView = fcViewList[0];
				if (fcView.CSM_SOQL__c!=null){
					try {
						if (fcView.CSM_SOQL__c!=null && ((String)fcView.CSM_SOQL__c).length()>0 && !((String)fcView.CSM_SOQL__c).toUpperCase().contains('LIMIT')){
                    		fcView.CSM_SOQL__c += ' LIMIT 250';
                    	}
                    	 
                        taskList = database.query(fcView.CSM_SOQL__c);
                        
                        if (taskList.size()>250 || taskList.size()==250){
                        	showNotifMsg = true;
                        	notifMsg = Label.CSM_MSG_LIMIT_RECORD_BY_CRITERIA;
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_LIMIT_RECORD_BY_CRITERIA));
                        }
					} catch (Exception ex){
						taskList = new List<Task>();
						ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_EDIT_FC_AND_SAVE));
					}
				}
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_OBJECT_TO_PROCEED));
		}
		if (taskList!=null && !taskList.isEmpty()) {
            //taskMap.put(taskViewId, taskList);
            //MF
            buildTaskWrapper(taskList);
            hasTasks = true;
        }
        else {
        	taskWrapperList = null;
        	hasTasks = false;
        }
	}	
	
	public PageReference selectedTask() {
		showNotifMsg = false;
        if (taskViewId!=null && taskViewId.length()>0){
            getFullList(taskViewId);
            isSelectLabel = false;
        }
        else {
        	isSelectLabel = true;
        	hasTasks = false;
        	taskWrapperList = null;
        } 
        return null;
	}
	
	private String getTaskURL(String ptaskViewId, Boolean isEdit) {
				
		// Get current page url through page reference 
		PageReference pageRefTemp = Page.CSM_TaskList;

		// Set up  current page reference with parameters
		String retURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL + ptaskViewId;
		
		String filterEditPage = CSM_Util.getFilterEditPage(ptaskViewId, isEdit, retURL, CSM_Constants.OBJ_TYPE_TASK);
		
		return filterEditPage;		
		
	}
	
    /*
    *   return current page of groups
    */
    public List<TRowItem> getListTask() {
    	return taskWrapperList;
    }
    public void buildTaskWrapper(List<Task> taskList) {
 		taskCheckMap = new Map<String, Task>();
        //MF
        taskWrapperList = new List<TRowItem>();
 		if (taskViewId!=null && taskList!=null){
 			Integer i = 0;
	        for(sObject r : taskList){
	            Task t = (Task)r;
	 			if (revertVal!=null && t.Id == revertVal.Id){
	 				t = revertVal;
	 				taskList[i] = t;
	 			}
	            TRowItem row = new TRowItem(t,false);
	            if(this.selectedTaskIds!=null && this.selectedTaskIds.contains(t.Id)){
	                row.IsSelected=true;
	            }
	            else{
	                row.IsSelected=false;
	            }
	           taskWrapperList.add(row);
	            taskCheckMap.put(t.Id, t);
	            i++;
	        }
 		}
 		if(!taskWrapperList.isEmpty())
 		{
 			if(String.isBlank(accountSelected))
 			{
 				accountSelected = taskWrapperList[0].tTask.CSM_Account_Plan__r.CSM_AccountId__c; 
 				
 			}
 			if(String.isBlank(playSelected))
 			{
 				playSelected = taskWrapperList[0].tTask.CSM_Play__c;
 			}
 			if(String.isBlank(widgetTaskId))
 			{
 				widgetTaskId = taskWrapperList[0].tTask.id;
 			}
 		} 
 
    } 
    
    // VCP - Deprecated
    public void buildTaskWrapper() {
    } 
    
	public PageReference createNewFocusCategory() {
		try {
			// Create new list view based on standard page
			CSM_Focus_Category_View__c fcView = new CSM_Focus_Category_View__c();
			fcView.CSM_Object_Name__c = 'Task';
			List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
			fcViewList.add(fcView);
			CSM_FocusCategoryViewDataAccess.upsertFCV(fcViewList);
			
			//String filterEditPage = getTaskURL(taskViewId, false);
			PageReference pageRefTemp = Page.CSM_TaskList;				
			// Get the List View through standard page
			//PageReference pageRef = new PageReference(filterEditPage);
			PageReference pageRef = Page.CSM_FocusCategoryView;
			pageRef.getParameters().put(CSM_Constants.OBJ_IG_ID, fcView.Id);				
			pageRef.getParameters().put(CSM_Constants.CANCEL_URL, pageRefTemp.getUrl());
			pageRef.getParameters().put(CSM_Constants.OBJ_TYPE, 'Task');
			
			pageRef.setRedirect(true);
			return pageRef;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
	}

	public PageReference setTaskInfo() {
		/*taskVal = new Task();
		if (isMultiple == false && taskId!=null && taskCheckMap != null && taskCheckMap.containsKey(taskId)) {
			this.selectedTaskIds = new Set<Id>();	
					
			taskVal = taskCheckMap.get(taskId);
			riskReason = taskVal.CSM_Risk_Reason__c;
			system.debug('\n\n\n ~~~~~~~~ ' + riskReason);
			revertVal = taskVal.clone(true);
			this.selectedTaskIds.add(taskVal.Id);
			
		}*/
		return null;
	}
	
		public PageReference newTaskDetails() {
		newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);
		isMultiple = false;
		createFieldSetAndPopUpCombo(true);		
		newTask = new Task();
		playObj = new CSM_Play__c();
		if(String.isNotBlank(accountselected)){
			newTask.WhatId = accountselected;
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
  	    
  	    successPlan = newTask.CSM_Account_Plan__r.CSM_DisplayName__c;
		successPlanList = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, accountSelected);
		playObj = CSM_PlaysDataAccess.populatePlayInformation(playSelected);
		newTask.CSM_Risk_Reason__c = '';
		newTask.Status = '';	
		if(successPlanList!=null && !successPlanList.isEmpty()){
			newTask.CSM_Account_Plan__c = successPlanList[0].Id;
			successPlan =successPlanList[0].CSM_DisplayName__c;
			newTask.CSM_Play__c = playObj.id;
		} else if(playObj != null) {
			newTask.CSM_Play__c = playObj.id;
		}
	
		setMandatoryFieldsForTask(newTask,true);
		system.debug('tesk3  - ' + newTask);
		return null;
	}
	
	private void createWrapperAndCompDismissTask() {
		try
		{
        	System.debug('selectedTaskIds - '+selectedTaskIds);
        	System.debug('taskCheckMap - '+taskCheckMap);
        	if (this.selectedTaskIds!=null && taskCheckMap!=null && !taskCheckMap.isEmpty()){
            	//taskVal.CSM_Risk_Reason__c = riskReason;
            	//revertVal = null;
            	List<Task> taskToProcess = new List<Task>();
            	for (String id : this.selectedTaskIds){
            		if (taskCheckMap.containsKey(id)){
            			taskToProcess.add(taskCheckMap.get(id));
            		}
            	}
            	if(isMultiple == false) {
            		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false; 
					CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);		
				}			
            	if (!taskToProcess.isEmpty()){
            		system.debug('taskVal:::' + taskVal);
					//setMandatoryFieldsForTask(taskVal);
					system.debug('taskValAfter:::' + taskVal);
					List<Task> taskValList = new List<Task>();
					taskValList.add(taskVal);
					system.debug('teeesk - ' + taskVal);
					system.debug('isComplete - ' + isComplete);
					setMandatoryFieldsForTask(taskVal, false);
            		taskDataAccess.createWrapperAndCompDismissTasks(this.selectedTaskIds, taskToProcess, taskValList, mandatoryFieldsInFieldSet, isComplete, true, isMultiple);
            		//taskDataAccess.createWrapperAndCompDismissTasks(this.selectedTaskIds, taskToProcess, taskVal, isComplete, true);
            	}
        	}
            //this.selectedTaskIds = new Set<Id>();
    		//this.taskCheckMap = new Map<String, Task>();
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            
        }
	}
	
	public PageReference resetTask() {
		taskVal = new Task();
		taskVal = tempTask;		
		
		/*if (isMultiple == false && taskId!=null && taskCheckMap != null && taskCheckMap.containsKey(taskId)) {
			taskVal = revertVal;
		} else {
			taskVal = new Task(); 
		}*/
		taskVal.CSM_Risk_Reason__c = '';
		taskVal.description = '';
		taskval.status = '';
		riskreason = '';
		//this.followUpTask = false;
		system.debug('followup***'+followUpTask);
		//this.selectedTaskIds = new Set<Id>();
		return null;
	}
	
	public PageReference getClosedStatus() {
		isStatusClosed = false;
		isSetPlayOutcome = false;
		playOutcomeValue = '';
//		strRecordType = null;
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
		
			
			//	taskval.status; 	
				system.debug('##Status : '+taskVal.Status);
		if(isSetPlayOutcome == true && String.isBlank(playOutcomeValue)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_ERR_SET_PLAYOUTCOME)); 
		} else {
			//createWrapperAndCompDismissTask();
			newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);
				
			try {
				if (followUpTask)
				{
					system.debug('Followup is checked');				
					Task newTask = new Task();
					system.debug('taskViewId $$ ' + taskViewId + ' ' + taskVal);
					newTask.CSM_Account__c = taskVal.CSM_Account__c;
					newTask.CSM_Play__c = taskVal.CSM_Play__c;
					newTask.CSM_Play_Task__c = taskVal.CSM_Play_Task__c;
					newTask.CSM_Account_Plan__c = taskVal.CSM_Account_Plan__c;
					newTask.CSM_Risk_Reason__c = '';
				//	System.debug('ReasonCode:'+taskVal.CSM_Risk_Reason__c);
					newTask.Status = 'Not Started';//taskVal.Status	
					newTask.REN_Opportunity__c = taskVal.REN_Opportunity__c;
					newTask.ownerId = taskVal.ownerId;
					newTask.whoId = taskVal.whoId;
					newTask.whatId = taskVal.whatId;
					newTask.subject = CSM_Constants.TASK_FOLLOWUP_SUBJECT + taskVal.subject;
					newTask.CSM_SuccessPlan_Play__c = taskVal.CSM_SuccessPlan_Play__c;
					if(CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c){
						String RecordTypeId = (string)taskVal.get('RecordTypeId');
						newTask.put('RecordTypeId',RecordTypeId);
						//system.debug('InheritRecordType'+taskVal.RecordTypeId);
					}else{
							if(CSM_Util.getRecordTypeExists(new Task())){
							newTask.put('RecordTypeId',strRecordType);
							}
					}
					System.debug('taskval -->'+strRecordType);
					if (newTask.ActivityDate==null){
						newTask.ActivityDate = Date.today();
					}
					setMandatoryFieldsForTask(newTask, true);
					List<Task> taskList = new List<Task>();
					taskList.add(newTask);
					CSM_TaskDataAccess.createTasks(taskList,followUpTask);
					//resetTask();  DE1770
					if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
					{
						createWrapperAndCompDismissTask();						
						String url = '/' + newTask.id + CSM_Constants.TASK_EXISTING_URL  + getRetURL();
						// Get the List View through standard page
						PageReference pageRef = new PageReference(url);
						pageRef.setRedirect(true);
						return pageRef; 

					}else{
						return null;
					}
					
				} else {
					createWrapperAndCompDismissTask();					
					resetTask();
				}
			}
			catch(exception ex)
			{
				
			}
		}
		return null;
	}
	
	private String getRetURL(){
		//Get current page url through page reference 
		PageReference pageRefTemp = Page.CSM_TaskList;
		String retURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL + taskViewId;
			return retURL;	
	}
	
	public PageReference populateAccountRelatedToSPPL() {
		if(newTask.CSM_SuccessPlan_Play__c != null){
			List<CSM_SuccessPlan_Play__c> successPPList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListbyId(new Set<Id> {newTask.CSM_SuccessPlan_Play__c});
			newTask.whatId = successPPList[0].CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__r.CSM_AccountId__c;
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
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
				        Schema.SobjectType.Task.fields.Status.label + ': '+Label.MSG_MUST_ENTER_VALUE));
				return null;
			}			
			else
			{ 
				createTask.Status = newTask.Status;
			}
			createTask.CSM_Risk_Reason__c = newTask.CSM_Risk_Reason__c;		
			createTask.CSM_SuccessPlan_Play__c = newTask.CSM_SuccessPlan_Play__c ;		
			if(newTask.CSM_SuccessPlan_Play__c != null){
				List<CSM_SuccessPlan_Play__c> successPPList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListbyId(new Set<Id> {newTask.CSM_SuccessPlan_Play__c});
				//Start - US1454 - Set Evalaution Date on SP_PL
				if(successPPList != null){
					if(successPPList[0].CSM_Evaluation_Date__c	== null) {
						spPlMap.put(successPPList[0].id,successPPList[0]);
					}
				}
				//End
				createTask.CSM_Play__c = successPPList[0].CSM_Play__c;
				system.debug('SPPList'+successPPList);
				createTask.CSM_Account_Plan__c = successPPList[0].CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c;
				if(successPPList[0].CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__r.CSM_AccountId__c != newTask.whatId){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CSM_LBL_ERROR_MASG_SP_PLAY_RELATED_ACCOUNT));
					return null;
				}
			}else{
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
			//createTask.CSM_Account_Plan__c = newTask.CSM_Account_Plan__c;
			setMandatoryFieldsForTask(createTask,true);
			List<Task> taskList = new List<Task>();
			taskList.add(createTask);
			system.debug('tesk  - ' + newTask);
			CSM_TaskDataAccess.createTasks(taskList,false);
			CSM_TaskCreationTriggerUtil.setSPPlEvalutionDate(taskList, spPlMap); //US1454 - Set evaluation on SP_PL.
			system.debug('tesk1  - ' + newTask);			
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
			return null;
		}
    	catch (Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
    		return null;
    	}
    	
	}

    	
	/**
	* @description Edit Focus Category Group
	*
	* @return  
	*/
	public PageReference editNewFocusCategory() {
		try {
			
			if (taskViewId!=null && taskViewId.length()>0){
				// Get the List View through standard page
				String editURL = CSM_Util.getFilterEditPage(taskViewId, true, getRetURL(), CSM_Constants.OBJ_TYPE_TASK);
				// Get the page reference
				PageReference pageRef = new PageReference(editURL);
				pageRef.setRedirect(true);
				return pageRef;
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_OBJECT_TO_PROCEED));
				return null;
			}
			
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
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
	* @description redirectToAccountPlan - Redirect to Account / Opportunity View
	*
	* @return PageReference 
	*/
	public PageReference redirectToAccountPlan() {
		if (accountPlanId!=null){
			PageReference ref = Page.CSM_AccountSuccessPlan;
			ref.getParameters().put(CSM_Constants.ID_PARAM, accountPlanId);
			ref.setRedirect(true);
			return ref;
		}
		return null;
	}	
		
	/**
	* @description redirectToTask - Redirect to Task View 
	*
	* @return PageReference 
	*/
	public PageReference redirectToTask() {
		
		if (taskId!=null){
			PageReference ref = new PageReference('/'+taskId);
			ref.setRedirect(true);
			return ref;
		}
		return null;
	}
	
    /*
    *   handle item selected
    */
    public PageReference doSelectItem(){
 
        if (this.selectedTaskIds ==  null)
        {
        	this.selectedTaskIds= new Set<Id>();
        }
        if (String.isNotBlank(this.contextItem))
        {
	        this.selectedTaskIds.add(this.contextItem);
	        itemSelected++;
        }
        return null;
  
    }
 
    /*
    *   handle item deselected
    */
    public PageReference doDeselectItem(){
        if (String.isNotBlank(this.contextItem))
        {
	        this.selectedTaskIds.remove(this.contextItem);
	        itemSelected--;
        }
        return null;
 
    }
     
    /*
    *   helper class that represents a row
    */
    public with sharing class TRowItem{
 
        public Task tTask{get;set;}
        public Boolean IsSelected{get;set;}
 
        public TRowItem(Task c, Boolean s){
            this.tTask=c;
            this.IsSelected=s;
        }
  
    }
    
    public PageReference updateWidget() {
    	this.accountSelected = accountSelected; 
    	this.playSelected = playSelected;
    	this.widgetTaskId = widgettaskId;
    	return null;
    }
    
   // new data grid changes start
    public PageReference setTaskIds() {				
    	this.selectedTaskIds = new Set<Id>();
    	isMultiple = false;
    	isStatusClosed = false;
		isSetPlayOutcome = false;		
    	//handle the task ids, it could be a single String of comma separated ids or a single id.
    	String[] tasksArray = taskIds.split(',');
    	if (tasksArray != null) {
    		
    		if (tasksArray.size() > 1) {
    			for (String lTasks : tasksArray) {
    				isMultiple = true;
    				this.selectedTaskIds.add((Id)lTasks);
    			}
    		}
    		else if (tasksArray.size() == 1) {
    			isMultiple = false;
    			taskId = taskIds;
    			this.selectedTaskIds.add((Id)taskIds);
    		}
			//retrieve each task with Id and add it to the task CheckMap
			//List<Task> tasks = CSM_TaskDataAccess.getTasksByIdSet(this.selectedTaskIds);
			List<Task> tasks = CSM_TaskDataAccess.getTasksByIdSet(this.selectedTaskIds, fieldSetAndPopupFieldsCombo);
			if (tasks != null && tasks.size() > 0) {
				setTaskCheckMap(tasks);
				setTaskInfoForPopup();
			}
    	}
    	return null;
    }
    
    private void setTaskCheckMap(List<Task> tasks) {
    	this.taskCheckMap = new Map<String, Task>();
		for (sObject task : tasks) {
	        Task t = (Task)task;
	        if(this.selectedTaskIds!=null && this.selectedTaskIds.contains(t.Id)){
	        	taskCheckMap.put(t.Id, t);
	        }
		}    	
    }
    
    private void setTaskInfoForPopup() {
 		taskVal = new Task();
 		
 		if(this.isComplete){
			newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
    	}else{
    		newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
    	}
		if (isMultiple == false && taskCheckMap != null && taskCheckMap.containsKey(taskId)) {
			taskVal = taskCheckMap.get(taskId);
			setMandatoryFieldsForTask(taskVal,false);
			//riskReason = taskVal.CSM_Risk_Reason__c;
			
		}
		if (taskVal.CSM_Completed_Date__c==null){
        	taskVal.CSM_Completed_Date__c = Date.today();
        } 
    }
    
    
    public PageReference findAccountForPlan() {
		List<CSM_Account_Plan__c> accountPlanList = CSM_AccountPlanDataAccess.getAccountPlanById((String)newTask.CSM_Account_Plan__c);
		
		if (accountPlanList != null && accountPlanList.size() > 0) {
			newTask.WhatId = (Id)accountPlanList[0].get('CSM_AccountId__c');
		}
		else {
			newTask.WhatId = null;
		}
		return null;
    }
    
    public PageReference setEmailTask() {
    	if (taskId != null) {
    		
    		taskVal = new Task();
    		this.taskCheckMap = null;
			try {
				//setup the taskCheckMap
				this.taskCheckMap = new Map<String, Task>(CSM_TaskDataAccess.getTasksById(taskId));
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
    
    public PageReference resetWidgetForNewTask() {
		accountSelected = '';
		playSelected = ''; 
		widgetTaskId = ''; 
		saveFilterToUserPreference();
		resetGridParams();
		//taskViewId = ''; 	
    	return null;
    }
    
    
    public PageReference resetPopupForNewTask() {
  	  	//newTask = new Task();
    	taskval.status = '';
		riskreason = '';
		followUpTask = false;
		system.debug('followup'+followUpTask);
    	return null;	
    }
    // new data grid changes end   
    
   	public void setMandatoryFieldsForTask(Task setTaskVal,boolean isNewTask) {
		if (mandatoryFieldsInFieldSet != null && !mandatoryFieldsInFieldSet.isEmpty()) {
			// populate the mandatory fields for the Task and reset them to TaskVal
			
			for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
				Map<String, Schema.SObjectField> objFieldInfo = Task.getSObjectType().getDescribe().fields.getMap();
				String fieldAccessibility = '';
				fieldAccessibility = String.valueOf(f.getFieldPath());
				Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(fieldAccessibility).getDescribe();
				if(fieldDescription.isUpdateable()){
					if (setTaskVal.get(f.FieldPath) == null) {
						System.debug('VVV - isNewTask - '+isNewTask);
						System.debug('VVV - newTask.get(f.FieldPath) - '+newTask.get(f.FieldPath));
						System.debug('VVV - TaskVal.get(f.FieldPath) - '+TaskVal.get(f.FieldPath));
						if(isNewTask){
							if (newTask.get(f.FieldPath) == null){
								setTaskVal.put(f.FieldPath, tempTask.get(f.FieldPath));
							} else {
								setTaskVal.put(f.FieldPath, newTask.get(f.FieldPath));
							}	
						}else{
							if (TaskVal.get(f.FieldPath) == null){
								TaskVal.put(f.FieldPath, tempTask.get(f.FieldPath));						
							} else {
								TaskVal.put(f.FieldPath, TaskVal.get(f.FieldPath));
							}			
							//taskVal.Status = (String)tempTask.get('Status');
							newTask.Status = (String)tempTask.get('Status');
						}
						system.debug('teeemp   - ' + tempTask);
					}
				}					
					
			}				
		}
   	}
   	
    public PageReference saveColumnsToUserPreference(){
	    try {
	    	preferenceObj.CSM_Success_Task_Grid_Columns__c = hiddenColumns;
	    	system.debug('Final List:'+hiddenColumns);
	    	List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    	userPreferenceList.add(preferenceObj);
	    	CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Task_Grid_Columns__c');
	    	system.debug('Final List:'+columnList);
	    }catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		    return null;
		}
    	return null;
    }
    
    public PageReference saveSearchToUserPreference(){
	    try {
	    	preferenceObj.CSM_Success_Task_Search__c = searchTerm;
	    	List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    	userPreferenceList.add(preferenceObj);
	    	CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Task_Search__c');
	    	taskListGridAttribute.gridSearchText=searchTerm;
	    }catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		    return null;
		}
    	return null;
    }

    public PageReference saveTaskPageSizeToUserPreference(){
	    try {
	    	preferenceObj.CSM_Success_Task_Page_Size__c = pageSize;
	    	List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    	userPreferenceList.add(preferenceObj);
	    	CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Task_Page_Size__c');
	    	if (String.isNotBlank(pageSize))
			{
			    taskListGridAttribute.gridSize=Integer.valueOf(pageSize);
			}
	    	system.debug('Final List:'+columnList);
	    }catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		    return null;
		}
    	return null;
    }
    
    
    
    public void saveFilterToUserPreference() {
	    try {
	    	System.debug('ZZZ - taskViewId - '+taskViewId);
	   		//if(taskViewId != null) {
	   			preferenceObj.CSM_Success_Task_Filter__c = taskViewId;
	   			List<CSM_User_Preferences__c> userPreferenceList = new List<CSM_User_Preferences__c>();
	    		userPreferenceList.add(preferenceObj);
	    		CSM_UserPreferencesUtil.saveUserPreference(userPreferenceList, 'CSM_Success_Task_Filter__c');
	    		playSelected = '';
	    		//taskViewId = '';
	    		accountSelected = '';
	   		//}
	    }catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		}
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
		public list<SelectOption> getRecordTypes(){
		list<SelectOption> options = new list<SelectOption>();
		if(CSM_Util.getRecordTypeExists(new Task())){
			System.debug('RecordType exists');
			List<RecordType> TaskRecordTypes = CSM_TaskDataAccess.getRecordTypeTask();
		for(RecordType sRecordType : TaskRecordTypes){					
        // Select options are added with key,value pairing
        	options.add(new SelectOption(sRecordType.Id, sRecordType.Name));
        }
     		options.add(new SelectOption('','--None--')); 
   	 		options.sort();   
   	 	} else {
   	 		System.debug('No RT');
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
	
    public void deleteFCV(){
    	List<CSM_Focus_Category_View__c> lstFCV = CSM_FocusCategoryViewDataAccess.getToDeleteFCV();
		if(lstFCV != null && !lstFCV.isEmpty()){
			CSM_FocusCategoryViewDataAccess.deleteFCV(lstFCV);
		}    	
    }

}