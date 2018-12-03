/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           08.16.2014
* @description    CSM_FocusCategoriesComponentController allows user to see three different components Focus Categories group, columns and categories  
*/
public with sharing class CSM_FocusCategoriesComponentController {
	public String whatId {get; set;}
	public String taskId {get; set;}
    public String accountPrefix {get; set;}
    public String successPlanUrl {get; set;}
    public String editFocusCategoryGroupUrl {get; set;}
    public String editFocusCategoryUrl{get; set;}
    public String defaultCurrency{
    	get{
    		if(String.isBlank(defaultCurrency)){
    			defaultCurrency = UserInfo.getDefaultCurrency();
    		}
    		return defaultCurrency;
    	} 
    	private set;
    }
    public Boolean isMultiCurrency{
    	get{
    		if(isMultiCurrency == null){
    			isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
    		}
    		return isMultiCurrency;
    	} 
    	private set;
    }

	@TestVisible public Integer focusCategoryColumnSize {get; private set;}
	public List<CSM_FocusCategoryColumnWrapper> columnOrderedList {get; private set;}
	//DE1127: Added the boolean to avoid the multiple execution of setter methods.
	private Boolean fcCategoryChanged;
	
	public String categoryViewId {get; set;}
	public String focusCategoryObjectType{get; set;}
	public String redirectId {get; set;}
	
	public String helpParamComplete {get; set;}
	public String helpParamDismiss {get; set;}

	public Boolean isComplete {get; set;}
	public Boolean followUpTask {get; set;} 
	public Boolean isFCActive {get; set;}
	public String lnkActiveOrInactive {get; set;}
	public Account acct {get;set;}
	public Task taskVal {get; set;}
	public Task tempTask;
	@TestVisible public transient List<CSM_FocusCategoryColumnWrapper> tilesOrderedList {get; private set;}
	
	
	private String groupAndUserId;
	private Set<Id> selectedTaskIds;
	private Map<Id, Task> taskCheckMap;
 	@TestVisible private Map<String, List<CSM_FocusCategoryColumnWrapper>> groupColumnWrapperMap;
	private CSM_FocusCategoriesDataAccess fcDA;
	
	public List<Schema.FieldSetMember> mandatoryFieldsInFieldSet{get;set;}
	private Set<String> completeDismissPopupFieldsSet;
	private List<String> fieldSetAndPopupFieldsCombo;	
	
	public String newFocusCategoryGroupUrl{get;set;}
	
	// US1378
	public String strRecordType {get; set;}
	
	//US1380
	public String strTaskStatus {get;set;}
	
	//US1264
	public boolean isSetPlayOutcome {get;set;}
	public boolean isStatusClosed {get;set;}
	public string playOutcomeValue {get;set;}
	
	public String packageVersion {
		get {
			if(String.isBlank(packageVersion)) {
				packageVersion = CSM_Util.getPackageVersion();
			}
			return packageVersion;
		} set;
	} 
	
	public String scoutUrl {
		get {
			if(String.isBlank(scoutUrl)) {
				scoutUrl = CSM_Util.getScoutAnalyticsUrl();
			}
			return scoutUrl;
		} set;
	}
	
	/*public List<SelectOption> riskReasonList {
		get; 
		set{
			if (value!=null && !value.isEmpty()){
				riskReasonList = value;
			}
		}
	} 
 	public List<SelectOption> riskReasonDismissList {
 		get; 
 		set{
			if (value!=null && !value.isEmpty()){
				riskReasonDismissList = value;
			}
 		}
 	}*/
 	public List<SelectOption> taskRiskReasonList {
 		get; 
 		set;
 	}

	
	public List<SelectOption> focusCategoryGroups {
		get; 
		set {
			if (value!=null && !value.isEmpty()){
				focusCategoryGroups = value;
			}
		}
	}
	
	public String tilesGroupId {
		get;
		set {
			System.debug('Tiles Value - '+value);
			if (!String.IsBlank(value)){
				tilesGroupId = value;
				//MF Added so that userPref is populated	
				if(tilesGroupId != null && userPref != null)
				{
					selectedTilesGroup();
				}
				System.debug('tilesOrderedList - '+tilesOrderedList);
			}
		}
	}		

	public String focusCategoryGroup {
		get; 
		set;
	}

	public String focusCategoryGroupInitValue {
		get;
		set {
			if (!String.IsBlank(value)) {
				focusCategoryGroupInitValue = value;
				System.debug('focusCategoryGroupInitValue - '+focusCategoryGroupInitValue);
				System.debug('In focusCategoryGroup - '+focusCategoryGroup);
				System.debug('In focusCategoryGroup - '+focusCategoryGroup);
				System.debug('fcCategoryChanged '+this.fcCategoryChanged);
				System.debug('userPref '+userPref);
				if (!this.fcCategoryChanged && userPref!=null){
					this.fcCategoryChanged = true;
					focusCategoryGroup = value;
					focusCategoryColumnSize = CSM_AdminDataAccess.getFocusCategoryColumnLimit();
					// Since we are using bootstrap we are dividing it with 12 
					//Integer focusCategoryColumnLimit = (Integer) MATH.floor(12/focusCategoryColumnSize);
					selectedCategoryGroup();
				}
			}
		}
	}
	
	public CSM_UserPreferencesFilterWrapper userPref {
		get; 
		set {
			if(value != null)
			{
				userPref = value;
				system.debug('userPref $$ ' + userPref);
				if (focusCategoryGroup!=null && userPref!=null ){
					focusCategoryColumnSize = CSM_AdminDataAccess.getFocusCategoryColumnLimit();
					// Since we are using bootstrap we are dividing it with 12 
					//Integer focusCategoryColumnLimit = (Integer) MATH.floor(12/focusCategoryColumnSize);
					//if(groupColumnWrapperMap.containsKey(groupAndUserId))
					//	groupColumnWrapperMap.remove(groupAndUserId);
					selectedCategoryGroup();
				}
			}
		}
	}
	
 	public Boolean inheritTaskType {get;set;}	
	
	public CSM_FocusCategoriesComponentController() {
		inheritTaskType = CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c;		
		this.fcCategoryChanged = false;
		tempTask = (Task)Task.SObject.sObjectType.newSObject(null, true);
		this.isFCActive = true;
		this.lnkActiveOrInactive = 'Show Inactive';
		helpParamComplete = CSM_Constants.HELP_TASK_COMPLETE;
		helpParamDismiss = CSM_Constants.HELP_TASK_DISMISS;
		
		fcDA = new CSM_FocusCategoriesDataAccess();
		fcDA.getInActive = false;
		taskCheckMap = new Map<Id, Task>();
		acct = new Account();
		taskVal = new Task();
		isStatusClosed = false;
		isSetPlayOutcome = false;
		groupColumnWrapperMap = new Map<String, List<CSM_FocusCategoryColumnWrapper>>();
		
		//Configurable FieldSet for Tasks
    	completeDismissPopupFieldsSet = new Set<String>{'Id', 'Subject', 'CSM_Play__r.CSM_Display_Name__c', 'CSM_Risk_Reason__c', 'CSM_Task_State__c', 'CSM_Completed_Date__c', 'Description'};
		createFieldSetAndPopUpCombo();
   		accountPrefix = CSM_Constants.ACCOUNT_PREFIX;
   		successPlanUrl = Page.CSM_AccountSuccessPlan.getUrl() + '?AccountId=';
   		populateEditFocusCategoryGroupUrl();
   		populateNewFocusCategoryGroupUrl();
   		populateEditFocusCategoryUrl();
	}
	
	public void createFieldSetAndPopUpCombo(){
		fieldSetAndPopupFieldsCombo = new List<String>();
		mandatoryFieldsInFieldSet = new List<Schema.FieldSetMember>();
		List<Schema.FieldSetMember> tmpFieldsList = SObjectType.Task.FieldSets.CSM_CompleteDismiss_Popup.getFields();
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
        system.debug('mandatoryFields::' + mandatoryFieldsInFieldSet);
		//set up the combined fieldsList based on which we will query the fields
		
		for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
			if (!completeDismissPopupFieldsSet.contains(f.FieldPath)){
				fieldSetAndPopupFieldsCombo.add(f.FieldPath);
			}
		}		
		//finally, add all the fields of popup
		fieldSetAndPopupFieldsCombo.addAll(completeDismissPopupFieldsSet);		
	}	
	
	private void updateUserPreferencesForSelectedGroup(){
		CSM_User_Preferences__c preferenceObj = CSM_UserPreferencesUtil.getUserPreferences(UserInfo.getUserId(), 'CSM_Overview_FC_Group_Filter__c');		
		preferenceObj.CSM_Overview_FC_Group_Filter__c = focusCategoryGroup;
		CSM_UserPreferencesUtil.saveUserPreference( new List<CSM_User_Preferences__c>{preferenceObj}, 'CSM_Overview_FC_Group_Filter__c');
	}
	
	/**
	* @description getFocusCategoryColumnList - Get focus category column list 
	*
	* @return null 
	*/
	private void getColumnOrderedListInfo(String groupId) {
		Map<String, CSM_FocusCategoryColumnWrapper> fccActiveMap = new Map<String, CSM_FocusCategoryColumnWrapper>();
		//String groupAndUserId = groupId+(this.acct.OwnerId==null?'':this.acct.OwnerId)+(this.fcDA.getInActive==false?'false':'true');
		// groupAndUserId = groupId+(this.acct.OwnerId==null?'':this.acct.OwnerId)+(this.fcDA.getInActive==false?'false':'true');
		//MF Changed pattern for GroupAndUserId
		/*
		groupAndUserId = groupId;
		if(userPref != null)
		{
			groupAndUserId += (this.userPref.attrFieldUserId==null?'':this.userPref.attrFieldUserId) +
					(this.userPref.attObjectType==null?'':String.valueOf(this.userPref.attObjectType)) +
					(this.userPref.attrFieldValue==null?'':this.userPref.attrFieldValue)+
					(this.userPref.attrFieldDateValue==null?'':String.valueOf(this.userPref.attrFieldDateValue)) +
					(this.userPref.showInactive==true?'true':'false');
		}*/
		system.debug('groupanduserId $$ ' + groupAndUserId);
		this.fcDA.userPreferences = userPref;
		system.debug('fcDA.userPreferences ZZZZ $$ ' + fcDa.userPreferences);
		system.debug('groupAndUserId::'+groupAndUserId);
		system.debug('this.acct.OwnerId::'+this.acct.OwnerId);
		System.debug('groupColumnWrapperMap - '+groupColumnWrapperMap);
		if (!groupColumnWrapperMap.containsKey(groupAndUserId)) {
			Set<String> groupSet = new Set<String>();
			CSM_FocusCategoriesColumnDataAccess fccDA = new CSM_FocusCategoriesColumnDataAccess();
			
			groupSet.add(groupId);
			fccActiveMap = fccDA.getFocusCategoryColumnActiveMap(groupSet);
					
		 	if (fccActiveMap!=null && !fccActiveMap.isEmpty()) {
		 		Map<String, Map<String, CSM_FocusCategoryWrapper>> fcActiveMap = fcDA.getFocusCategoryColumnActiveMap(fccActiveMap.keySet());
		 		
				if (fcActiveMap!=null && !fcActiveMap.isEmpty()) {
					List<CSM_FocusCategoryColumnWrapper> localColumnOrderedList;
					for (String columnId : fccActiveMap.keyset()) {
						
						if (fcActiveMap.containsKey(columnId)) {
							fccActiveMap.get(columnId).ActiveCategoryList = fcActiveMap.get(columnId).values();
							fccActiveMap.get(columnId).ActiveCategoryList.sort();
							
							List<CSM_FocusCategoryWrapper> newActiveCategoryList = new List<CSM_FocusCategoryWrapper>();
							for (CSM_FocusCategoryWrapper fcW : fccActiveMap.get(columnId).ActiveCategoryList) {
								if (fcW.CategoryDisplayName.length() > 30)
								{
									fcW.CategoryDisplayName = fcW.CategoryDisplayName.substring(0,30);
								}
								newActiveCategoryList.add(fcW);
								
							}
							fccActiveMap.get(columnId).ActiveCategoryList = newActiveCategoryList;
							
							if (groupColumnWrapperMap.containsKey(groupAndUserId)){
								localColumnOrderedList = groupColumnWrapperMap.get(groupAndUserId);
							} else {
								localColumnOrderedList = new List<CSM_FocusCategoryColumnWrapper>();
							}
							
							localColumnOrderedList.add(fccActiveMap.get(columnId));
							groupColumnWrapperMap.put(groupAndUserId, localColumnOrderedList);
							System.debug('First groupColumnWrapperMap - '+groupColumnWrapperMap);
							//if (fccActiveMap.get(columnId).GroupHasTiles){
								//tilesGroupId = groupAndUserId;
							//}
						}
					}
				}
		 	}
		}						
	}	
	
	/**
	* @description selectedTilesGroup - Get selected tiles group, column and categories 
	*
	* @return null 
	*/
	public PageReference selectedTilesGroup() {
		system.debug('tilesGroupId : ' + tilesGroupId);
		
		groupAndUserId = tilesGroupId;
		if(userPref != null)
		{
			groupAndUserId += (this.userPref.attrFieldUserId==null?'':this.userPref.attrFieldUserId) +
					(this.userPref.attObjectType==null?'':String.valueOf(this.userPref.attObjectType)) +
					(this.userPref.attrFieldValue==null?'':this.userPref.attrFieldValue)+
					(this.userPref.attrFieldDateValue==null?'':String.valueOf(this.userPref.attrFieldDateValue)) +
					(this.userPref.showInactive==true?'true':'false');
		}
		system.debug('Vish groupAndUserId : ' + groupAndUserId);
		System.debug('groupColumnWrapperMap - '+groupColumnWrapperMap);
		if (!groupColumnWrapperMap.containsKey(groupAndUserId)){
			getColumnOrderedListInfo(tilesGroupId);
		}
		system.debug('Vish After groupColumnWrapperMap : ' + groupColumnWrapperMap);
		system.debug('Vish After groupAndUserId : ' + groupAndUserId);
		if (groupColumnWrapperMap.containsKey(groupAndUserId)) {
			System.debug('After - ');
			
			tilesOrderedList = groupColumnWrapperMap.get(groupAndUserId);
			List<CSM_FocusCategoryWrapper> newActiveCategoryList = new List<CSM_FocusCategoryWrapper>();
			if (tilesOrderedList!=null && !tilesOrderedList.isEmpty() && 
				tilesOrderedList[0].ActiveCategoryList != null && !tilesOrderedList[0].ActiveCategoryList.isEmpty()){
				List<CSM_FocusCategoryWrapper> activeCategoryList = tilesOrderedList[0].ActiveCategoryList;
				Integer focusCategoryTilesLimit = CSM_AdminDataAccess.getFocusCategoryTilesLimit();
				if (activeCategoryList.size() > focusCategoryTilesLimit)
				{
					Integer i=1;
					for (CSM_FocusCategoryWrapper fcW : activeCategoryList) {
						newActiveCategoryList.add(fcW);
						if (focusCategoryTilesLimit==i){
							break;
						}
						i++;
					}
					tilesOrderedList[0].ActiveCategoryList = newActiveCategoryList;
				}	
			}
		}		
		return null;
	}
		
	/**
	* @description selectedCategoryGroup - Get selected category group, column and categories 
	*
	* @return null 
	*/
	public PageReference selectedCategoryGroup() {
		this.focusCategoryGroup = focusCategoryGroup;
		system.debug('focusCategoryGroup : ' + focusCategoryGroup);
		columnOrderedList = new List<CSM_FocusCategoryColumnWrapper>();
		updateUserPreferencesForSelectedGroup();
		if (tilesGroupId == null || (tilesGroupId!=null && focusCategoryGroup != tilesGroupId)){
			//String groupAndUserId = focusCategoryGroup+(this.acct.OwnerId==null?'':this.acct.OwnerId)+(this.fcDA.getInActive==false?'false':'true');
			//MF
			groupAndUserId = focusCategoryGroup;
			if(userPref != null)
			{
			//groupAndUserId += (this.userPref.attrFieldValue==null?'':this.userPref.attrFieldValue)+(this.userPref.showInactive==true?'true':'false');
				groupAndUserId += (this.userPref.attrFieldUserId==null?'':this.userPref.attrFieldUserId) +
					(this.userPref.attObjectType==null?'':String.valueOf(this.userPref.attObjectType)) +
					(this.userPref.attrFieldValue==null?'':this.userPref.attrFieldValue)+
					(this.userPref.attrFieldDateValue==null?'':String.valueOf(this.userPref.attrFieldDateValue)) +
					(this.userPref.showInactive==true?'true':'false');
			}
			if (!groupColumnWrapperMap.containsKey(groupAndUserId)){
				getColumnOrderedListInfo(focusCategoryGroup);
			}
			system.debug('groupColumnWrapperMap : ' + groupColumnWrapperMap);
			system.debug('groupAndUserId : ' + groupAndUserId);
			if (groupColumnWrapperMap.containsKey(groupAndUserId)){
				columnOrderedList = groupColumnWrapperMap.get(groupAndUserId);
				columnOrderedList.sort();
			}
			system.debug('columnOrderedList : ' + columnOrderedList);
		}
		return null;
	}
		
	/**
	* @description redirectToAccountPlan - Redirect to Account / Opportunity View
	*
	* @return PageReference 
	*/
	public PageReference redirectToAccountPlan() {
		return null;
	}	
	/**
	* @description redirectToTask - Redirect to Task View 
	*
	* @return PageReference 
	*/
	public PageReference redirectToTask() {
		return null;
	}
		
	public PageReference setTaskInfo() {
		try {
			taskVal = new Task();
			selectedTaskIds = new Set<Id>();
			isStatusClosed = false;
			isSetPlayOutcome = false;
			if(this.isComplete){
				this.taskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
	    	}else{
	    		this.taskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
	    	}
			if (taskId!=null) {
				if (!taskCheckMap.containsKey(taskId)){
					taskCheckMap = new Map<Id, Task>(CSM_TaskDataAccess.getTasksById(taskId, fieldSetAndPopupFieldsCombo));
				}
				taskVal = taskCheckMap.get(taskId);
				//check if the mandatory Fields are present, if not, add them with default values
				setMandatoryFieldsForTask(taskVal);
				
				if (taskVal.CSM_Completed_Date__c==null){
                	taskVal.CSM_Completed_Date__c = Date.today();
                } 
				selectedTaskIds.add(taskVal.Id);
			}
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
		return null;
	}
	
	private String getRetURL(){
		// Get current page url through page reference 
		PageReference pageRefTemp = Page.CSM_CustomerSuccessOverview;
		String retURL = pageRefTemp.getURL() + CSM_Constants.PARAM_GROUPID + focusCategoryGroup;
		return retURL;	
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
			CSM_TaskDataAccess taskDataAccess = new CSM_TaskDataAccess();
			if(isSetPlayOutcome == true && String.isBlank(playOutcomeValue)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_ERR_SET_PLAYOUTCOME)); 
			} else {
				CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
				//CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
				//taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), new List<Task>{taskVal}, mandatoryFieldsInFieldSet, isComplete, true, false);			
				if (followUpTask){
					Task newTask = new Task();
					newTask.CSM_Account__c = taskVal.CSM_Account__c;
					newTask.CSM_Play__c = taskVal.CSM_Play__c;
					newTask.CSM_Play_Task__c = taskVal.CSM_Play_Task__c;
					newTask.CSM_Account_Plan__c = taskVal.CSM_Account_Plan__c;
					newTask.REN_Opportunity__c = taskVal.REN_Opportunity__c;
					newTask.ownerId = taskVal.ownerId;
					newTask.whoId = taskVal.whoId;
					newTask.whatId = taskVal.whatId;
					if(CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c){
						String RecordTypeId = (string)taskVal.get('RecordTypeId');
						newTask.put('RecordTypeId',RecordTypeId);
						//system.debug('InheritRecordType'+taskVal.RecordTypeId);
					}else{
							if(CSM_Util.getRecordTypeExists(new Task())){
							newTask.put('RecordTypeId',strRecordType);
							}
					}
					newTask.Status = 'Not Started';//taskVal.Status;
					newTask.CSM_Risk_Reason__c = '';
					newTask.CSM_SuccessPlan_Play__c = taskVal.CSM_SuccessPlan_Play__c;	
					System.debug('SuccessPlan_Play__c'+taskVal.CSM_SuccessPlan_Play__c);			
					if (newTask.ActivityDate==null){
						newTask.ActivityDate = Date.today();
					}
					
					newTask.subject = CSM_Constants.TASK_FOLLOWUP_SUBJECT + taskVal.subject;
					List<Task> insertTaskList = new List<Task>();
					insertTaskList.add(newTask);
					CSM_TaskDataAccess.createTasks(insertTaskList,followUpTask);
					
					if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
					{
						CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
						taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), new List<Task>{taskVal}, mandatoryFieldsInFieldSet, isComplete, true, false);			
						
						String url = '/' + newTask.id + CSM_Constants.TASK_EXISTING_URL  + getRetURL();
						//String url = CSM_Constants.TASK_CREATE_URL+getRetURL() +CSM_Constants.TASK_WHAT_ID+ (taskVal.WhatId==null?'':taskVal.WhatId) +CSM_Constants.TASK_SUBJECT+(taskVal.Subject==null?'':taskVal.Subject);
						// Get the List View through standard page
						PageReference pageRef = new PageReference(url);
						pageRef.setRedirect(true);
						return pageRef;

					}else{
						return null;
					}
				} else {
					CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
					taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), new List<Task>{taskVal}, mandatoryFieldsInFieldSet, isComplete, true, false);			
				}
				/*taskVal = new Task();
				taskVal.Status = 'Not Started';
				setMandatoryFieldsForTask(taskVal);	*/		
				taskCheckMap.clear();
	
				if(groupColumnWrapperMap.containsKey(groupAndUserId))
					groupColumnWrapperMap.remove(groupAndUserId);	
			}		
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
		return null;
	}
	
	public PageReference resetTask() {
		try { 
			taskVal = new Task(); 
			taskVal.Status = 'Not Started';
			//MF added for refresh issue
			taskCheckMap.clear();
	
			//followUpTask = false;
			//this.selectedTaskIds = new Set<Id>();
			setMandatoryFieldsForTask(taskVal);			
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
		return null;
	}
	 
	public PageReference newFocusCategory() {
		return null;
	} 
	
	//Eswar Bala: 11/24/2014
	public PageReference toggleActiveFC()
	{
		if(this.isFCActive)
		{
			this.isFCActive = false;
			this.lnkActiveOrInactive = Label.CSM_HIDE_INACTIVE;
		}
		else
		{
			this.isFCActive = true;
			this.lnkActiveOrInactive = Label.CSM_SHOW_INACTIVE;
		}
		PageReference pageRef = filterByOwner();
		return pageRef;
	}
	
	public PageReference clearOwnerFilter()
	{
		this.acct.OwnerId = null;
		filterByOwner();
		return null;
	}
          
    public PageReference filterByOwner() {
		//MF Deprecated
		/*columnOrderedList = new List<CSM_FocusCategoryColumnWrapper>();
		try {
			system.debug('acct.OwnerId::'+this.acct.OwnerId);
		    if (focusCategoryGroup != null) {
		    	fcDA.byOwnerId = this.acct.OwnerId;
		    	if(this.isFCActive)
		    	{
		    		fcDA.getInActive = false;
		    	}
		    	else
		    	{
		    		fcDA.getInActive = true;
		    	}
		    	system.debug('this.isFCActive : ' + this.isFCActive);
		    	system.debug('fcDA.getInActive : ' + fcDA.getInActive);
		    	String groupAndUserId = focusCategoryGroup+(fcDA.byOwnerId==null?'':fcDA.byOwnerId)+(fcDA.getInActive==false?'false':'true');
				getColumnOrderedListInfo(focusCategoryGroup);
				System.debug('groupColumnWrapperMap - '+groupColumnWrapperMap);
		    	if (groupColumnWrapperMap.containsKey(groupAndUserId)){
		    		system.debug('returned list for : ' + groupAndUserId + ' : ' + groupColumnWrapperMap.get(groupAndUserId));
					columnOrderedList = groupColumnWrapperMap.get(groupAndUserId);
					columnOrderedList.sort();
				}
		    }
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}*/
		return null;
	} 
	
	private void populateNewFocusCategoryGroupUrl()
	{
		PageReference pageRef;
		try {
			pageRef= Page.CSM_FocusCategories;
			pageRef.getParameters().put(CSM_Constants.ADMIN_HYPERLINK_FLAG,'false');
			pageRef.getParameters().put('tabCategory' , 'Admin');
			newFocusCategoryGroupUrl = pageRef.getUrl();
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
	}
	
	private void populateEditFocusCategoryGroupUrl()
	{
		PageReference returnUrl = Page.CSM_CustomerSuccessOverview;
		String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(),CSM_Constants.UTF_8);
		
		editFocusCategoryGroupUrl = Page.CSM_FocusColumnAndCategory.getUrl() + CSM_Constants.PARAM_GROUPID
		       +'&'+CSM_Constants.ADMIN_HYPERLINK_FLAG+'=false'
		       + CSM_Constants.PARAM_RETURN_URL + rUrl;
		try
		{
			returnUrl = Page.CSM_CustomerSuccessOverview;
			rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(),CSM_Constants.UTF_8);
			
			editFocusCategoryGroupUrl = Page.CSM_FocusColumnAndCategory.getUrl() + CSM_Constants.PARAM_GROUPID
			       +'&'+CSM_Constants.ADMIN_HYPERLINK_FLAG+'=false'
			       + CSM_Constants.PARAM_RETURN_URL + rUrl;
		}
	    catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
	}
	
	private void populateEditFocusCategoryUrl()
	{
		try {    
		    editFocusCategoryUrl = Page.CSM_FocusCategoryView.getUrl() + CSM_Constants.ID_VAL
			       + CSM_Constants.PARAM_CANCEL_URL + Page.CSM_CustomerSuccessOverview.getUrl();
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    	}
	}
	
	/**
	* @description Edit Focus Category Group
	*
	* @return  
	*/
	public PageReference editFocusCategoryGroup() {
		PageReference pageRef =null;
		try {
			system.debug('focusCategoryGroup $$$$$$$ '+focusCategoryGroup);
			if (focusCategoryGroup !=null) {
				String fcGroupId = fcDA.saveAndRetrieveId(focusCategoryGroup);
				
				PageReference returnUrl = Page.CSM_CustomerSuccessOverview;
				String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(),CSM_Constants.UTF_8);
				
			    pageRef = Page.CSM_FocusColumnAndCategory;
				pageRef.getParameters().put(CSM_Constants.OBJ_FCG_GROUPID, focusCategoryGroup);
				pageRef.getParameters().put(CSM_Constants.ADMIN_HYPERLINK_FLAG, 'false');
				pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
				//MF Temp comment out
				/*if (CSM_Util.isUserAnSystemAdmin() != true) {
					pageRef.getParameters().put(CSM_Constants.ADMIN_HYPERLINK_FLAG,'false');
				}*/ 
		        pageRef.setRedirect(true); 
			} 
			return pageRef;
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return pageRef;
    	}
		return null;
   	}
   	
   	/**
	* @description Edit Focus Category 
	*
	* @return  
	*/
	public PageReference editFocusCategory() {
		return null;
	}

   	/*
   	* @description redirectToAccountPlan - Redirect to Account / Opportunity View
    *
    * @return PageReference 
    */
    public PageReference redirectToEdit() {
        if (whatId.indexOf(CSM_Constants.ACCOUNT_PREFIX)>-1 && whatId.indexOf(CSM_Constants.ACCOUNT_PREFIX) < 1){
            List<CSM_Account_Plan__c> acctPlanList =  CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, whatId);
            if (acctPlanList!=null && !acctPlanList.isEmpty()){
                whatId = acctPlanList[0].Id;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_MSG_SUCCESS_PLAN_NOT_ASSOCIATED_TO_ACCOUNT));
                return null;
            }
        }
        PageReference ref = new PageReference('/'+whatId+'/e');
        PageReference ovRef = Page.CSM_CustomerSuccessOverview;
        String rUrl = ovRef.getUrl();
        
        ref.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
        ref.setRedirect(true);
        return ref;
        
    } 
    
    public PageReference redirectById(){
    	return null;
    }
   	
   	public void setMandatoryFieldsForTask(Task taskVal) {
		if (mandatoryFieldsInFieldSet != null && !mandatoryFieldsInFieldSet.isEmpty()) {
			// populate the mandatory fields for the Task and reset them to TaskVal
			for(Schema.FieldSetMember f : mandatoryFieldsInFieldSet) {
				Map<String, Schema.SObjectField> objFieldInfo = Task.getSObjectType().getDescribe().fields.getMap();
				String fieldAccessibility = '';
				fieldAccessibility = String.valueOf(f.getFieldPath());
				Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(fieldAccessibility).getDescribe();
				if(fieldDescription.isUpdateable()){
					if (taskVal.get(f.FieldPath) == null) {
						taskVal.put(f.FieldPath, tempTask.get(f.FieldPath));						
					}
				}
			}
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
		List<RecordType> TaskRecordTypes = CSM_TaskDataAccess.getRecordTypeTask();
		if (CSM_Util.getRecordTypeExists(new Task())){
		for(RecordType sRecordType : TaskRecordTypes){
        	// Select options are added with key,value pairing
        	options.add(new SelectOption(sRecordType.Id, sRecordType.Name));
        }
     		options.add(new SelectOption('','--None--')); 
   	 		options.sort();   
   	 	}else {
   	 		options.add(new SelectOption('','--None--')); 
   	 	} 
	 		return options;
	}

	// US1380
	public list<SelectOption> getTaskStatus(){
		list <SelectOption> options = new list<SelectOption>();
		List<TaskStatus> TaskStatus = CSM_TaskDataAccess.getTaskStatus();
  		for (TaskStatus stask : TaskStatus){
        	options.add(new SelectOption(stask.MasterLabel, stask.MasterLabel));
        }
     		options.add(new SelectOption('','--None--')); 
   	 		options.sort();   
   	 	   	return options;
	}

}