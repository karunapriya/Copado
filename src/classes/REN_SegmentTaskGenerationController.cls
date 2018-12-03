/**
 * Created Date		: Apr 14, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Controller for Segment task generation
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2320					Apr 14, 2017	1.1					Controller for Segment task generation
 *
 */
public with sharing class REN_SegmentTaskGenerationController extends REN_BaseMainController {
	public String helpParam {get;set;}
    public User userRecord {get;set;}
    public String ownerOptionSelected {get;set;}
    public List<SelectOption> getTaskOwnerOptions{get;set;}
    public List<SelectOption> options {get; set;}
    public String selectedValue{get;set;}
    public List<User> addRecipient{get; set;}
    public List<User> populateEmailRecip{get; set;}
    private String batchId;
    public REN_Batch_Activity__c batchActivity {get; set;}
    public List<REN_Email_Recipient__c> emailRecipient {get; private set;}
    public List<String> emailRep {get; set;}
    public List<SObject> selectedRecipients{get;set;}
    public String selectedRowId {get; set;}
    public Id userId = UserInfo.getUserId();
    public CSM_DataGridAttribute taskTemplateGridAttribute{get;set;}
    public String selectedSegmentId {get; set;}
    public REN_Segment__c segmentRecord{get; set;}
    public String objType{get; set;}
    public Boolean recordDeleted = false;
    public Id deletableRecordId{get;set;}
    public String cloneRecordId{get;set;}
    public String editRecordId{get;set;}
    public List<SelectOption> fieldNames {get;set;}
    
    public REN_BaseMainController thisController{
		get{
			return this;
		}
		set;
	}
	
	public REN_SegmentTaskGenerationController() {
		batchActivity = new REN_Batch_Activity__c();
		emailRecipient = new List<REN_Email_Recipient__c>();
		helpParam = CSM_Constants.HELP_SEGMENT_DETAIL;
		userRecord = new User();
		batchId = ApexPages.currentPage().getParameters().get('id');
		selectedRowId = ApexPages.currentPage().getParameters().get('tid');
		selectedSegmentId = ApexPages.currentPage().getParameters().get('seid');
		emailRep = new List<String>();
        emailRep.add('Id');
        emailRep.add('Name');
        emailRep.add('Email');
        selectedRecipients = new List<SObject>();
        segmentRecord = new REN_Segment__c();
        if(String.isNotBlank(selectedSegmentId)) {
        	setObjectType(selectedSegmentId);
        }
		if(String.isNotBlank(batchId)) {
        	populateInfo();
        }
        else {
        	batchActivity.REN_Created_By__c = userId;
        	batchActivity.REN_Created_On__c = DateTime.now();
        	populateEmailRecip = REN_EmailRecipientDataAccess.getUser(userId);
        	batchActivity.REN_Object__c = ''; //To be updated
        	selectedValue = 'Generate now';
        	ownerOptionSelected = 'Record Owner';
        	batchActivity.REN_Owner_Field_Name__c = 'OwnerId';
        }
		selectedValue = 'Generate now';
		options = new List<SelectOption>();
        options.add(new SelectOption('Generate now','Generate now'));
        options.add(new SelectOption('Generate on','Generate on')); 
        addRecipient = REN_EmailRecipientDataAccess.getAllUsersForSelection();
        setGridAttributes();
	}
	
	public void setObjectType(String selectedSegmentId) {
		List<REN_Segment__c> segmentList = REN_SegmentDataAccess.getSegmentsById(new Set<String>{selectedSegmentId});
        	if(segmentList != null && !segmentList.isEmpty()) {
        		segmentRecord = segmentList[0];	
        		if(segmentRecord.REN_Type__c == 'Low Touch') {
        			objType = 'Opportunity';
        		} else {
        			objType = 'Asset';
        			
        		}
        	}
	}
	private void populateInfo() {
    	try {
	    	batchActivity = REN_BatchActivityDataAccess.getBatchAct(batchId);
	    	setObjectType(batchActivity.REN_Segment__c);
	    	if(String.isBlank(selectedSegmentId)) {
	    		selectedSegmentId = batchActivity.REN_Segment__c;	
	    	}
	    	DateTime tempVar = batchActivity.REN_Job_Start_Date__c;
	    	if(String.isBlank(selectedRowId)) {
	    		selectedRowId = batchActivity.REN_Task_Template__c;	
	    	}
	    	String strBatchId = String.valueOf(batchId);
	    	populateEmailRecip = new List<User>();
	    	populateEmailRecip = REN_EmailRecipientDataAccess.getUsers(strBatchId);	  
	    	 
	    	selectedValue = 'Generate on';
	    	if(String.isNotBlank(batchActivity.REN_Object__c)) {
	    		ownerOptionSelected = 'Record Owner';	
	    	} else {
	    		ownerOptionSelected = 'Designated Owner';
	    	}
    	}
    	catch(exception e) {    		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
    	}
    }
    
    private void setGridAttributes() {
        taskTemplateGridAttribute = new CSM_DataGridAttribute();
        taskTemplateGridAttribute.tableName = 'segmentTaskTemplate';
    	taskTemplateGridAttribute.objectType = 'objSegmentTaskTemplate';
    	taskTemplateGridAttribute.viewName = 'segmentTaskTemplate';
    	taskTemplateGridAttribute.gridSize=5;
    	taskTemplateGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
    	taskTemplateGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	taskTemplateGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
    	taskTemplateGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE;
    	taskTemplateGridAttribute.showExport=CSM_Constants.GRID_ATTR_FALSE;
    	taskTemplateGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = '';
     	gridInputParams.selectedTaskFilter = selectedRowId;
     	gridInputParams.selectedFilterClause = objType;
     	taskTemplateGridAttribute.params = JSON.serialize(gridInputParams);
    }
	
	public PageReference saveSegmentBatch() {
    	REN_Batch_Activity__c saveRec = new REN_Batch_Activity__c();
    	Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
    	string criteria;
    	try {
	    	saveRec.REN_Segment__c = selectedSegmentId;
	    	saveRec.REN_Task_Template__c = ApexPages.currentPage().getParameters().get('uniqueCBoxsegmentTaskTemplate');
	    	if(String.isNotBlank(selectedRowId) && selectedRowId != '-') {
	    		saveRec.REN_Task_Template__c = selectedRowId;
	    	}
	    	saveRec.REN_Email_Notification__c = batchActivity.REN_Email_Notification__c;
	    	saveRec.REN_Last_Modified_By__c = userId;
	    	saveRec.REN_Last_Modified_On__c = DateTime.now();
	    	saveRec.REN_Created_By__c =  batchActivity.REN_Created_By__c;
	    	saveRec.REN_Created_On__c =  batchActivity.REN_Created_On__c;
	    	saveRec.REN_Batch_Type__c = REN_Constants.BATCH_ACTIVITY_TYPE_SEGMENT_TASK;
	    	if(batchActivity.id != null) {
	    		saveRec.id = batchActivity.id;
	    	}
	    	if(selectedValue.contains('now')) {
    			saveRec.REN_Job_Start_Date__c = DateTime.now();
    		} else {
    			saveRec.REN_Job_Start_Date__c = batchActivity.REN_Job_Start_Date__c;
    		}
	    	if(ownerOptionSelected.contains('Designated')) {
	    		if(batchActivity.REN_Designated_TaskOwner__c != null ) {
	    			saveRec.REN_Designated_TaskOwner__c = batchActivity.REN_Designated_TaskOwner__c;
	    			saveRec.REN_Owner_Field_Name__c = '';
	    		}
	    	} else {
	    		if(batchActivity.REN_Owner_Field_Name__c != null) {
	    			saveRec.REN_Owner_Field_Name__c = batchActivity.REN_Owner_Field_Name__c;
	    			saveRec.REN_Designated_TaskOwner__c = null;	
	    		}
	    	}
	    	List<REN_Email_Recipient__c> saveEmailRecipRec = new List<REN_Email_Recipient__c>();
				for(REN_BaseChildController baseChildController : baseChildControllerMap.values()) {
					if(baseChildController instanceof REN_MultiSelectPickListCompCtrl) {
						((REN_MultiSelectPickListCompCtrl)baseChildController).retrieveSelectedRecipients();
						selectedRecipients = ((REN_MultiSelectPickListCompCtrl)baseChildController).finalRecipients;
					}
				}
	    	if(String.isBlank(saveRec.REN_Task_Template__c)) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_TASK_TMPL));
	    	}
	    	if(String.isBlank(saveRec.REN_Designated_TaskOwner__c) && String.isBlank(saveRec.REN_Owner_Field_Name__c)) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_DESIG_OWNER));
	    	}
	    	if(saveRec.REN_Job_Start_Date__c == null) {
		    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_DATE_TIME));
	    	}
	    	if(saveRec.REN_Job_Start_Date__c != null && saveRec.REN_Job_Start_Date__c < DateTime.now() && !selectedValue.contains('now')) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_DATE));
	    	}
	    	if(selectedRecipients == null || selectedRecipients.isEmpty() && batchActivity.REN_Email_Notification__c == true) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_LBL_EMAIL_SEL_VAL));
	    	}
	    	if(!ApexPages.hasMessages()) {
	    		REN_Batch_Activity__c batchActivity = null;
	    		if(saveRec.id != null) {
	    			batchActivity = REN_BatchActivityDataAccess.getBatchAct(saveRec.id);
	    			if(batchActivity.REN_Status__c != 'Scheduled') {
	    				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_LBL_BATCH_STARTED));
	    				return null;
	    			}
	    		}
				saveRec = REN_BatchActivityDataAccess.saveBatchAct(saveRec);
				if(batchId != null) {
					recordDeleted = REN_EmailRecipientDataAccess.deleteEmailRecip(populateEmailRecip, batchId);
				}
				for(SObject emailRepRec : selectedRecipients) {
						REN_Email_Recipient__c tempVar = new REN_Email_Recipient__c();
						tempVar.put('REN_User__c', emailRepRec.id);
						tempVar.put('REN_Recipient__c', tempVar.REN_User__c);
						tempVar.put('REN_Batch__c', saveRec.id);
						saveEmailRecipRec.add(tempVar);
				}
				emailRecipient = REN_EmailRecipientDataAccess.saveEmailRecip(saveEmailRecipRec);
				//Scheduled Batch here
				if(batchActivity != null && batchActivity.REN_Job_Start_Date__c != saveRec.REN_Job_Start_Date__c && String.isNotBlank(batchActivity.REN_Scheduler_ID__c)) {
					//Remove scheduler
					try {
						System.abortJob(batchActivity.REN_Scheduler_ID__c); //abort the job
					}catch(Exception e) {
						system.debug('## \n\n~~~~ ERROR: '+ e.getMessage());
					}
				}
				if(batchActivity == null || batchActivity.REN_Job_Start_Date__c != saveRec.REN_Job_Start_Date__c) {
					batchActivity = REN_BatchActivityDataAccess.getBatchAct(saveRec.id);
					List<REN_Batch_Activity__c> batchActivityList = new List<REN_Batch_Activity__c>();
					batchActivityList.add(batchActivity);
					scheduledBatchJob(batchActivityList);
				}
	    	}
    	}
    	catch(exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
	   	}
	    if(ApexPages.hasMessages()) {
	   		return null;
	   	} else {
		   	PageReference pageRef = Page.REN_TaskGenerationActivity;
			pageRef.getParameters().put('tabCategory', 'Playmaker');
			pageRef.setRedirect(true);
	    	return pageRef;
	   	}
    }
    public void scheduledBatchJob(List<REN_Batch_Activity__c> saveRecList) {
    	List<REN_Batch_Activity__c> batchList = new List<REN_Batch_Activity__c>();
    	for (REN_Batch_Activity__c saveRec : saveRecList) {
	    	String strDateTime = (saveRec.REN_Job_Start_Date__c.addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
			String jobID = system.schedule(String.format(Label.REN_SEG_TASK_SCHEDULAR_NAME, new String[]{saveRec.REN_Batch_Number__c, segmentRecord.name}), strDateTime, new REN_BatchSegmentTaskScheduledDispatcher());	
			saveRec.REN_Scheduler_ID__c = jobID;
			if(saveRec.REN_Job_Start_Date__c <= System.now().addMinutes(1)) {
				saveRec.REN_Status__c = 'Processing';
			}
			batchList.add(saveRec);
			REN_Segment__c segmentObj = new REN_Segment__c(id = saveRec.REN_Segment__c, REN_Task_Batch_Status__c = 'Scheduled');
			REN_SegmentDataAccess.saveSegments(new List<REN_Segment__c>{segmentObj});
			System.debug(strDateTime + '\n~~~~ScheduledId: ' + jobID);
    	}
		REN_BatchActivityDataAccess.saveBatchAct(batchList);
    }
    public PageReference cancel() {
    	PageReference pageRef = Page.REN_SegmentOverview;
		pageRef.getParameters().put('tabCategory', 'Playmaker');
		pageRef.setRedirect(true);
    	return pageRef;
    }
    public List<SelectOption> getTaskOwnerOptions() {
    	List<selectOption> options = new List<selectOption>();
		options.add(new SelectOption('Designated Owner','Designated Owner'));
        options.add(new SelectOption('Record Owner', 'Record Owner')); 
      	return options;
    }
    public PageReference createTaskTemplate() {
    	String typ;
    	PageReference pageRef = Page.REN_TaskTemplate;
    	pageRef.getParameters().put('tabCategory', 'Playmaker');
    	if(objType == 'Opportunity') {
    		typ = 'o';
    	} else {
    		typ = 'a';
    	}
    	pageRef.getParameters().put('type', typ);
    	pageRef.getParameters().put('seid',selectedSegmentId);
		pageRef.setRedirect(true);
		return pageRef;
    }
    public PageReference deleteSelectedRecord() {
    	try {
	    	if(deletableRecordId != null) {
	    		REN_Task_Template__c taskTemplateObj = REN_TaskTemplateDataAccess.getTaskTemplateById(deletableRecordId);
	    		List<REN_Batch_Activity__c> bAList = REN_BatchActivityDataAccess.getBatchActivityByTskTmpl(deletableRecordId);
	    		if(bAList != null && bAList.size() > 0) {
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.ERR_MESG_BATCH_OPP_GEN));
	    		} else {
	    			REN_TaskTemplateDataAccess.deleteTaskTemplate(new List<REN_Task_Template__c>{taskTemplateObj});
	    			if(deletableRecordId == selectedRowId) {
			    		selectedRowId = '-';
	    			}
	    		}
	    	}
    	} catch(Exception ex) {
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    	}
    	return null;
    }
    public PageReference cloneRecord() {
    	REN_Task_Template__c cloneSourceObj = null;
    	try {
	    	REN_Task_Template__c origTaskTemplateObj = REN_TaskTemplateDataAccess.getTaskTemplateById(cloneRecordId);
	    	cloneSourceObj = origTaskTemplateObj.clone(false, true, false, false);
	    	String taskTmplName = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.Name;
	    	if (taskTmplName.length() > 70) {
	    		taskTmplName = taskTmplName.substring(0,69);
	    	}
	    	cloneSourceObj.Name = taskTmplName;
	    	List<REN_Task_Template__c> taskTemplateList = new List<REN_Task_Template__c>();
	    	taskTemplateList.add(cloneSourceObj);
	    	List<REN_Task_Template__c> savedList = REN_TaskTemplateDataAccess.saveTaskTemplate(taskTemplateList);
    	}
    	catch(Exception ex) {
    		String errMsg = ex.getMessage();    	
    		if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
    		    String message = String.format(System.Label.DUPLICATE_TSK_TMPL_NAME, new String[] {cloneSourceObj.Name});
    		    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, message));
    		}
    		else {
   			    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    		}
    	}
    	return null;
    }
    
    public PageReference editRecord()
    {
    	String typ;
    	PageReference pageRef = Page.REN_TaskTemplate;
    	pageRef.getParameters().put('tabCategory', 'Playmaker');
    	pageRef.getParameters().put('id', batchId);
    	pageRef.getParameters().put('tid', editRecordId);
    	pageRef.getParameters().put('seid',selectedSegmentId);
    	if(objType == 'Opportunity') {
    		typ = 'o';
    	} else {
    		typ = 'a';
    	}
    	pageRef.getParameters().put('type', typ);
		pageRef.setRedirect(true);
		return pageRef;
    }  
    
    public List<SelectOption> getTaskOwnerFields() {
    	fieldNames = new List<SelectOption>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType ObjectSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
        	String fNameApi = fieldMap.get(fieldName).getDescribe().getName();
          	Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
           	if(fielddataType == Schema.DisplayType.Reference && !fNameApi.contains('LastModifiedById')) {
           		String fName = fieldMap.get(fieldName).getDescribe().getLabel();
           		String nameApi = fieldMap.get(fieldName).getDescribe().getName();
           		List<Schema.SObjectType>  refObj = fieldMap.get(fieldName).getDescribe().getReferenceTo();
           		if(nameApi == 'OwnerID') {
       				String tempName = objType + ' ' + fName;
       				fName = tempName;
           		}
           		String objectStr = 'User';
				Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectStr);
	           	if(refObj[0] == convertType){
			        fieldNames.add(new SelectOption(fNameApi, fName.removeEnd(' ID')));
	           	}
           }
        }
        if(objType == 'Asset' && !(CSM_AccessController.hasField(objType, 'OwnerId'))) {
        	fieldNames.add(new SelectOption('OwnerId', objType + ' Owner'));
        }
        return fieldNames;
	}
}