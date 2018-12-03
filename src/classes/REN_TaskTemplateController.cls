/** 
 * @author		Sanket Supe(sanket@comitydesigns.com)
 * @date		04.17.2017
 * @description	REN_TaskTemplateController controller class for the task template page 
 */

public with sharing class REN_TaskTemplateController{
    public String sectionHeader {get; private set;}
	public Task taskObj {get; set;}	
	public REN_Task_Template__c taskTemplate {get; set;}
	private String templateId {get; set;}
	public String tabCategory {get; set;}
	public PageReference populateTextFieldsFromRecType{get;set;}
	public boolean toggleField {get;set;}
	public boolean toggleField1 {get;set;}
	public String[] contacts = new String[]{};
	public String objectNames {get; set;}
	public String tType {get; set;}
	public String PRIMARY_CONTACT {get; set;}
	public String contactValue{get;set;}
	public Map<Id, String> recordId2Name;
	public Boolean isRecordType {get; set;} 
	public String segmentId {get; set;}
	public String batchActivityId {get; set;}
	public String recordTypeToRender {get; set;}
	public String recordTypeId {get; set;}
	public List<SelectOption> recordTypes{get; set;}
	//public String id{get; set;}
	
	public REN_TaskTemplateController()
	{
		taskObj = new Task();	
		recordId2Name = new Map<Id, String>();
		recordTypes = getRecordTypeList();
		batchActivityId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		segmentId = ApexPages.currentPage().getParameters().get('seid');
		templateId = ApexPages.currentPage().getParameters().get('tid');
		System.debug('id>>>>>' + templateId);
		tType = ApexPages.currentPage().getParameters().get('type');
		toggleField1=true;
		if(String.isNotBlank(templateId)) {
			populatePageInformation();
		}else{
			taskTemplate = new REN_Task_Template__c();
		}
		if (tType == 'o') {
			taskTemplate.REN_Related_To__c = 'Opportunity';
			objectNames = 'Opportunity';
			}
			if (tType == 'a') {
				taskTemplate.REN_Related_To__c = 'Asset';
				objectNames = 'Asset';
			}
		isRecordType = CSM_Util.getRecordTypeExists(new Task());
		
	}
	/**
     * @description	public method that fetching Contact Lookup fileds API Names and Label Names on Opportuninty and Asset Object
     */
	public List<SelectOption> getContactFields() {
		
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType ObjectSchema = schemaMap.get(objectNames);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        List<SelectOption> fieldNames = new List<SelectOption>();
		if (tType == 'o') {
			fieldNames.add(new SelectOption(REN_Constants.PRIMARY_CONTACT,REN_Constants.PRIMARY_CONTACT));
		}
        for (String fieldName: fieldMap.keySet()){  
          system.debug('FieldMap >>>>' + fieldMap.get(fieldName));
          String fName = fieldMap.get(fieldName).getDescribe().getLabel();
          String fNameApi = fieldMap.get(fieldName).getDescribe().getName();
          Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
          
          //String fNameType = fieldMap.get(fieldName).getDescribe().getType();
           if(fielddataType == Schema.DisplayType.Reference){
           	List<Schema.SObjectType>  fNahmeApi = fieldMap.get(fieldName).getDescribe().getReferenceTo();
           	String objectStr = 'Contact';

			// Convert to schema.sObjectType
			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectStr);
           	system.debug('fNahmeApi---'+fNahmeApi);
            
	           	if( fNahmeApi[0] == convertType){
	           		
			        fieldNames.add(new SelectOption(fNameApi, fName));
		           	
	           	}
           }
           
         // fieldNames.add(new SelectOption(fNameApi, fName));

        }
        return fieldNames;
	//}
        
        
		
	}
	
	public void populatePageInformation() {
		try {
			taskTemplate = new REN_Task_Template__c();
			taskTemplate = REN_TaskTemplateDataAccess.populateTaskTemplateInformation(templateId);
			if(taskTemplate != null) {
				taskObj.Subject = taskTemplate.REN_Subject__c;
				taskTemplate.REN_Record_Type__c = taskTemplate.REN_Record_Type__c;
				//taskObj.Description = taskTemplate.REN_Comments__c;
				taskObj.Priority = taskTemplate.REN_Priority__c;
				taskObj.Status = taskTemplate.REN_Status__c;
				taskObj.ActivityDate = taskTemplate.REN_Due_Date__c;
				taskObj.Type = taskTemplate.REN_Type__c;
			}
			system.debug('taskTemplate>>>>>>>>>>>>>>>'+taskTemplate);
		} catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
	}
	
	/**
     * @description	public method that Save the task template page
     */
	public PageReference templateSave() {
		try {
			REN_Task_Template__c taskTemplateRec = new REN_Task_Template__c();
			taskTemplateRec.REN_Contact__c = taskTemplate.REN_Contact__c;
			if(recordId2Name.containsKey(taskTemplate.REN_Record_Type__c)) {
				taskTemplateRec.REN_Record_Type_Name__c = recordId2Name.get(taskTemplate.REN_Record_Type__c);
				taskTemplateRec.REN_Record_Type__c = taskTemplate.REN_Record_Type__c;
			} else {
				taskTemplateRec.REN_Record_Type_Name__c = '';
				taskTemplateRec.REN_Record_Type__c = '';
			}
			if(String.isNotBlank(taskTemplate.id)) {
				taskTemplateRec.id = taskTemplate.id;
			}
			taskTemplateRec.REN_Subject__c = taskObj.Subject;
			taskTemplateRec.REN_Due_Date__c = taskObj.ActivityDate;
			taskTemplateRec.REN_Status__c = taskObj.Status;
			taskTemplateRec.REN_Priority__c = taskObj.Priority;
			taskTemplateRec.REN_Type__c = taskObj.Type;
			taskTemplateRec.REN_CC__c = taskTemplate.REN_CC__c;
			taskTemplateRec.REN_BCC__c = taskTemplate.REN_BCC__c;
			taskTemplateRec.REN_Completed_Date__c = taskTemplate.REN_Completed_Date__c;
			taskTemplateRec.REN_Direction__c = taskTemplate.REN_Direction__c;
			taskTemplateRec.REN_Comments__c = taskTemplate.REN_Comments__c;
			taskTemplateRec.Name = taskTemplate.Name;
			taskTemplateRec.REN_Related_To__c = taskTemplate.REN_Related_To__c;
			taskTemplateRec.REN_Template_Description__c = taskTemplate.REN_Template_Description__c;
			if(!ApexPages.hasMessages()) {
				List<REN_Task_Template__c> saveList = REN_TaskTemplateDataAccess.saveTemplate(new List<REN_Task_Template__c>{taskTemplateRec});
				taskTemplate = saveList[0];
				System.debug('saveList:::::' +saveList);
				PageReference pageRef = Page.REN_SegmentTaskGeneration;
		    	pageRef.getParameters().put('tabCategory', 'Playmaker');
		    	pageRef.getParameters().put('tid', taskTemplate.id);
		    	pageRef.getParameters().put('seid', segmentId);
		    	if(String.isNotBlank(batchActivityId)) {
	    			pageRef.getParameters().put('id', batchActivityId);
	    		}
				pageRef.setRedirect(true);
				return pageRef;
			}
			return null;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			return null;
		}
			
	}
	
	/**
     * @description	public method that navigates user to Segment Generation page when clicked on Cancel button
     */
	
	public PageReference populateTextFieldsFromRecType() {
		try { 
			System.debug('Inside Onchange');
			PageREference pageRef = Page.REN_SegmentTaskGeneration;
			String RecTypeVal = recordId2Name.get(taskTemplate.REN_Record_Type__c);
			System.debug('RecTypeVal' + RecTypeVal);
			if (RecTypeVal== 'Task - Email') 
				toggleField1=true;
				
			if (RecTypeVal == 'Task - Inbox' || RecTypeVal == 'Task - Standard' || RecTypeVal == 'Task - Fax' || RecTypeVal == 'Task - Phone Calls')
				toggleField1=false;
			//if (taskTemplate.REN_Record_Type__c == 'Task - Phone Calls')
			//	toggleField2=true;
			return null;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			return null;
		}
	} 
	
	/**
     * @description	public method that navigates user to Segment Generation page when clicked on Cancel button
     */
	
	public PageReference templateCancel() {
		try { 
			PageReference pageRef = Page.REN_SegmentTaskGeneration;
	    	pageRef.getParameters().put('tabCategory', 'Playmaker');
	    	pageRef.getParameters().put('seid', segmentId);
	    	if(String.isNotBlank(batchActivityId)) {
	    		pageRef.getParameters().put('id', batchActivityId);
	    	}
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			return null;
		}
	} 
	
	public REN_TaskTemplateController getThis() 
	{
    	return this;
	}
		
	/**
     * @description	public method that user get task object record types.
     */	
	private List<SelectOption> getRecordTypeList(){
		Map<String,Id> recordTypeMap = REN_Util.getRecordTypes('Task');
		List<SelectOption> options = new List<SelectOption>();
		List<RecordType> TaskRecordTypes = CSM_TaskDataAccess.getRecordTypeTask();
		options.add(new SelectOption('','None')); 
		for(String name: recordTypeMap.keySet()){
			options.add(new SelectOption(recordTypeMap.get(name), name));
			recordId2Name.put(recordTypeMap.get(name), name);
		}
		return options;
	}
	public PageReference renderFields() {
		if(String.isNotBlank(recordTypeId)) {
			if(recordId2Name.containsKey(recordTypeId)) {
				recordTypeToRender = recordId2Name.get(recordTypeId);
			}
		}
		return null;
	}
			
}