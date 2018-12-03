/**
 * Created Date		: Feb 20, 2017
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: This class act as controller for displaying FC as Cards and Tiles.
 * Support Email 	: Nidhi@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US2118				Feb 20, 2017		1.1					@description
 * 
 */
public with sharing class CSM_FCCardsDisplayCompCntrl {
	public Boolean inheritTaskType {get;set;}
	public Boolean isComplete {get; set;}
	public Boolean followUpTask {get; set;} 
	public Boolean isSetPlayOutcome {get;set;}
	public Boolean isStatusClosed {get;set;}
	public Boolean isError {get;set;}
	
	public String whatId {get; set;}
	public String accountPrefix {get; set;}
	public String successPlanUrl {get; set;}
	public String categoryViewId {get; set;}
	public String focusCategoryObjectType{get; set;}
	public String redirectId {get; set;}
	public String helpParamComplete {get; set;}
	public String helpParamDismiss {get; set;}
	public String taskId {get; set;}
	public String editFocusCategoryGroupUrl {get; set;}
	public String editFocusCategoryUrl{get; set;}
	public String lnkActiveOrInactive {get; set;}
	public String newFocusCategoryGroupUrl{get;set;}
	public String strRecordType {get; set;}
	public String strTaskStatus {get;set;}
    public string playOutcomeValue {get;set;}
    public string accSPId {get;set;}
    public Map<Id,boolean> sObjectHasFcRecEditAccess {get; set;}
    public String nameSpace {get;set;}
   
	
	public Integer focusCategoryColumnSize {get; private set;} // need to check once Task issue resolved
	
	public Task taskVal {get; set;}
	public Account acct {get;set;}
	public Task tempTask;
	
	public List<CSM_FocusCategoryColumnWrapper> columnOrderedList {get; private set;}
	public List<Schema.FieldSetMember> mandatoryFieldsInFieldSet{get;set;}
	
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

	//DE1127: Added the boolean to avoid the multiple execution of setter methods.
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

	public List<SelectOption> taskRiskReasonList {
		get; 
		set;
	}
	
	private Set<String> completeDismissPopupFieldsSet;
	private Set<Id> selectedTaskIds;
	private List<String> fieldSetAndPopupFieldsCombo;	
	private Map<Id, Task> taskCheckMap;
	
	//Declaring Constant
	private  final String STR_NONE = '--None--';
	private  final String STR_NO_FC_FOUND = 'No FC found';// Need to create label and add here...
	private  final String RECORD_TYPE_ID = 'RecordTypeId';
	private  final String  STR_NOT_STRATED = 'Not Started';
	private  final Integer RECORD_LIMIT = 6;
	
	
	
	public CSM_FCCardsDisplayCompCntrl() {
		inheritTaskType = CSM_Admin__c.getOrgDefaults().CSM_Inherit_Task_Record_Type__c;		
		tempTask = (Task)Task.SObject.sObjectType.newSObject(null, true);
		helpParamComplete = CSM_Constants.HELP_TASK_COMPLETE;
		helpParamDismiss = CSM_Constants.HELP_TASK_DISMISS;
		nameSpace = CSM_Util.getNamespace();
		
		completeDismissPopupFieldsSet = new Set<String>{CSM_Constants.OBJ_OCR_ID, CSM_Constants.OBJ_E_SUBJECT, CSM_Constants.OBJ_PLAY_REL_DISPLAY_NAME, CSM_Constants.OBJ_T_RISK_REASON, CSM_Constants.OBJ_AH_TASK_STATE, CSM_Constants.OBJ_AH_COMPLETED_DATE, CSM_Constants.OBJ_PRODUCT_PD};
		createFieldSetAndPopUpCombo();
   		accountPrefix = CSM_Constants.ACCOUNT_PREFIX;
   		successPlanUrl = Page.CSM_AccountSuccessPlan.getUrl() + '?AccountId=';
		
		taskVal = new Task();
		taskCheckMap = new Map<Id, Task>();
		isStatusClosed = false;
		isSetPlayOutcome = false;
		isError = false;
		focusCategoryColumnSize = CSM_AdminDataAccess.getFocusCategoryColumnLimit();
		populateEditFocusCategoryUrl();
		getFCWrapperList();
		focusCategoryViewMapForEdit();
		
	}
	
	/**
    * @description : This method gets the list of FCWrapper which have type = Tiles. At Max need to return 6 Object of FCWrapper.
    */
	public void getFCWrapperList(){
		List<CSM_FocusCategoryWrapper> FCWrapperList;
		FCWrapperList = CSM_FocusCategoryViewDataAccess.populateFCWrapperClass(false,RECORD_LIMIT);
		if(FCWrapperList != null){
			system.debug('\n\n FCWrapperList @@@@ :: ' + FCWrapperList);
			getFCColumnWrapperList(FCWrapperList);

		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.CSM_LBL_NO_FC_FOUND));
		}
	}

	/**
    * @description : This method creates the list of FCColWrapper and set the attribute values from FCWrapper List. FCCOlWrapper List is used for displaying the FC as Tiles.
    */
	public void getFCColumnWrapperList(List<CSM_FocusCategoryWrapper> fcWrapperList){
		columnOrderedList = new List<CSM_FocusCategoryColumnWrapper>();
		Integer countInt = 1;
        List<CSM_FocusCategoryWrapper> fcFirstColList = new List<CSM_FocusCategoryWrapper>();
        List<CSM_FocusCategoryWrapper> fcSecondColList  = new List<CSM_FocusCategoryWrapper>();
        List<CSM_FocusCategoryWrapper> fcThirdColList = new List<CSM_FocusCategoryWrapper>();
        
		if(fcWrapperList != null){
			for(Integer i = 0; i < fcWrapperList.size(); i++ ){
				CSM_FocusCategoryWrapper obj = fcWrapperList[i];
				/* US2696: Commenting below logic of column wise data insertion. Adding logic for row wise data insertion.
				if(i < 2){
					fcFirstColList.add(obj);
				}else if(i > 3){
					fcThirdColList.add(obj);
				}else{
					fcSecondColList.add(obj);
				}*/
				
				if(i == 0 || i == 3){
					fcFirstColList.add(obj);
				}
				if(i == 1 || i == 4){
					fcSecondColList.add(obj);
				}
				if(i == 2 || i == 5){
					fcThirdColList.add(obj);
				}
			}
			
			if(!fcWrapperList.isEmpty()){
				//Integer size = (fcWrapperList.size() +1 ) / 2;
				for(Integer i = 0; i < fcWrapperList.size(); i++ ){
					CSM_FocusCategoryWrapper fcatWrapperObj = fcWrapperList[i];
					CSM_FocusCategoryColumnWrapper fcColWrapperObj = new CSM_FocusCategoryColumnWrapper();
					fcColWrapperObj.GroupId = fcatWrapperObj.CategoryViewId;
					fcColWrapperObj.ColumnCategoryCount = 2;
					
					if(i == 0){
						fcColWrapperObj.ActiveCategoryList = fcFirstColList;
					} 
					if(i == 1){
						fcColWrapperObj.ActiveCategoryList = fcSecondColList;
					} 
					if(i == 2) {
						fcColWrapperObj.ActiveCategoryList = fcThirdColList;
					}
					fcColWrapperObj.ColumnActive = true;
					fcColWrapperObj.ColumnOrder = '1';
					countInt++;
					columnOrderedList.add(fcColWrapperObj);
					if(countInt >3){
						break;
					}
				}
			}
		} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.CSM_LBL_NO_FC_FOUND));
		}

	}

	public list<SelectOption> getRecordTypes(){
		list<SelectOption> options = new list<SelectOption>();
		List<RecordType> TaskRecordTypes = CSM_TaskDataAccess.getRecordTypeTask();
		if (CSM_Util.getRecordTypeExists(new Task())){
			for(RecordType sRecordType : TaskRecordTypes){
				// Select options are added with key,value pairing
				options.add(new SelectOption(sRecordType.Id, sRecordType.Name));
			}
			options.add(new SelectOption('',STR_NONE)); 
			options.sort();   
		}else {
			options.add(new SelectOption('',STR_NONE)); 
		} 
		return options;
	}

	public List<SelectOption> getPlayOutcomeValues() {
		sObject sobj = new CSM_SuccessPlan_Play__c();
		List<SelectOption> options = CSM_Util.getPicklistValues(sobj,'CSM_Play_Outcome__c');
		options.add(new SelectOption('',STR_NONE)); 
		options.sort();
		return options;
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
		catch (Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
		return null;
	}

	public PageReference redirectToEdit() {
		/* if (whatId.indexOf(CSM_Constants.ACCOUNT_PREFIX)>-1 && whatId.indexOf(CSM_Constants.ACCOUNT_PREFIX) < 1){
            List<CSM_Account_Plan__c> acctPlanList =  CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, whatId);
            if (acctPlanList!=null && !acctPlanList.isEmpty()){
                whatId = acctPlanList[0].Id;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_MSG_SUCCESS_PLAN_NOT_ASSOCIATED_TO_ACCOUNT));
                return null;
            }
        }
        PageReference ref = new PageReference('/'+whatId+'/e');
        PageReference ovRef = Page.CSM_FCCardsDisplay;
        String rUrl = ovRef.getUrl();
        ref.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
        ref.setRedirect(true);
        return ref; */
        return null;
	} 
	
	
	public PageReference redirectToSPEdit() {
		    isError = false;
		    accSPId = null;
            List<CSM_Account_Plan__c> acctPlanList =  CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, whatId);
            if (acctPlanList!=null && !acctPlanList.isEmpty()){
                whatId = acctPlanList[0].Id;
                accSPId = '/'+whatId+'/e';
            } else {
            	isError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_MSG_SUCCESS_PLAN_NOT_ASSOCIATED_TO_ACCOUNT));
            }
            return null;
	} 

	//Added for US1264
	public PageReference getClosedStatus() {
		isStatusClosed = false;
		isSetPlayOutcome = false;
		playOutcomeValue = '';
		Set<String> taskClosedStatusSet = CSM_TaskDataAccess.taskClosedStatusSet;
		if(taskClosedStatusSet.contains(taskVal.Status)) {
			isStatusClosed = true;
		}
		return null;
	}

	public PageReference redirectById(){
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
						String RecordTypeId = (string)taskVal.get(RECORD_TYPE_ID);
						newTask.put(RECORD_TYPE_ID,RecordTypeId);
					}else{
							if(CSM_Util.getRecordTypeExists(new Task())){
							newTask.put(RECORD_TYPE_ID,strRecordType);
							}
					}
					newTask.Status = STR_NOT_STRATED;//taskVal.Status;
					newTask.CSM_Risk_Reason__c = '';
					newTask.CSM_SuccessPlan_Play__c = taskVal.CSM_SuccessPlan_Play__c;	
					System.debug('SuccessPlan_Play__c'+taskVal.CSM_SuccessPlan_Play__c);			
					if (newTask.ActivityDate==null){
						newTask.ActivityDate = Date.today();
					}
					
					newTask.subject = CSM_Constants.TASK_FOLLOWUP_SUBJECT + taskVal.subject;
					List<Task> insertTaskList = new List<Task>();
					insertTaskList.add(newTask);
					System.debug(taskVal+ '\n\n-----\n' + insertTaskList);
					
					CSM_TaskDataAccess.createTasks(insertTaskList,followUpTask);
					
					if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR)){
						CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{taskVal.CSM_SuccessPlan_Play__c}, playOutcomeValue, null, null);	
						taskDataAccess.createWrapperAndCompDismissTasks(selectedTaskIds, taskCheckMap.values(), new List<Task>{taskVal}, mandatoryFieldsInFieldSet, isComplete, true, false);			
						
						String url = '/' + newTask.id + CSM_Constants.TASK_EXISTING_URL  + getRetURL();
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
				taskCheckMap.clear();
	
			 	}
		}
		catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
		return null;
	}

	// US1380
	public list<SelectOption> getTaskStatus(){
		list <SelectOption> options = new list<SelectOption>();
		List<TaskStatus> TaskStatus = CSM_TaskDataAccess.getTaskStatus();
		for (TaskStatus stask : TaskStatus){
			options.add(new SelectOption(stask.MasterLabel, stask.MasterLabel));
		}
		options.add(new SelectOption('',STR_NONE)); 
		options.sort();   
		return options;
	}

	public PageReference resetTask() {
		try { 
			taskVal = new Task(); 
			taskVal.Status = STR_NOT_STRATED;
			taskCheckMap.clear();
			setMandatoryFieldsForTask(taskVal);			
		}
		catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
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

	public PageReference newFocusCategory() {
		return null;
	} 
	
	private String getRetURL(){
		// Get current page url through page reference 
		PageReference pageRefTemp = Page.CSM_FCCardsDisplay;
		String retURL = pageRefTemp.getURL();
		return retURL;	
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
	
	private void populateEditFocusCategoryUrl(){
		try {  
		    editFocusCategoryUrl = Page.CSM_FocusCategoryView.getUrl() + CSM_Constants.ID_VAL
			       + CSM_Constants.PARAM_CANCEL_URL + Page.CSM_FCCardsDisplay.getUrl();
		}
    	catch (exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    	}
	}
	
	public void focusCategoryViewMapForEdit()
    {
        Set<Id> fcRecIds = new Set<Id>();
        if(!columnOrderedList.isEmpty()){
            for(CSM_FocusCategoryColumnWrapper fcv:columnOrderedList){
                for(CSM_FocusCategoryWrapper fcw: fcv.ActiveCategoryList){
                    fcRecIds.add(fcw.CategoryViewId);
                }
            }
        }
   		if(!fcRecIds.isEmpty()){
	        sObjectHasFcRecEditAccess = CSM_AccessController.hasEditRecordAccess(fcRecIds,userinfo.getUserId());
			system.debug('Map -----@@-----&&--'+sObjectHasFcRecEditAccess);
   		}
    }
    
}