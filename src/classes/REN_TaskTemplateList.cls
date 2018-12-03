/** 
 * @author		Sanket Supe(sanket@comitydesigns.com)
 * @date		04.17.2017
 * @description	REN_TaskTemplateList controller class for the Success Plan template page 
 */

public with sharing class REN_TaskTemplateList{
	
	
    public String sectionHeader {get; private set;}
	public REN_Task_Template__c taskTemplate {get; set;}
	public Task taskFields {get; set;}		
	private String templateId {get; set;}
	public String tabCategory {get; set;}
	public PageReference REN_toggleFields{get;set;}
	public boolean toggleField {get;set;}
	public boolean toggleField1 {get;set;}
	public boolean toggleField2 {get;set;}
	public boolean toggleField3 {get;set;}
	public boolean toggleField4 {get;set;}
	public Boolean showGridMessage {get; set;}
	public String[] contacts = new String[]{};
	public String objectName = 'Opportunity';
	public String tType {get; set;}
	public String PRIMARY_CONTACT {get; set;}
	
	
	public REN_TaskTemplateList()
	{
		
		templateId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		tType = ApexPages.currentPage().getParameters().get('TypeId');
		
		
		taskTemplate = new REN_Task_Template__c();	
		//this.populatePageInformation();
		
	}
	
	public List<SelectOption> getContactFields() {
		
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        Schema.SObjectType ObjectSchema = schemaMap.get(objectName);

        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();

		
		List<SelectOption> fieldNames = new List<SelectOption>();
		
        for (String fieldName: fieldMap.keySet()) 
        {  
          String fName = fieldMap.get(fieldName).getDescribe().getLabel();
          fieldNames.add(new SelectOption(fName, fName));

        }
        return fieldNames;
		
	}
	
	/*public List<SelectOption> getContactOptions() {
            List<SelectOption> options = new List<SelectOption>();
            String objectName = 'Asset';
            if(tType == 'o'){
            	options.add(new SelectOption(REN_Constants.PRIMARY_CONTACT,REN_Constants.PRIMARY_CONTACT));
            	objectName = 'Opportunity';
            }
            //TODO
            for (){
            	options.add(new SelectOption(fieldApiName,fieldLabel));
            }
            return options;
        }*/
	

	private void populatePageInformation() {
		try {
			if(templateId != null)
			{
				taskTemplate = REN_TaskTemplateDataAccess.populateTaskTemplateInformation(templateId);
				if(taskTemplate != null)
				{
					//Sets page header
					sectionHeader = Label.REN_TASK_TEMPLATE;
					
				}
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
	}
	
	
	public void templateSave() {
		try {
			showGridMessage = false;
			
			boolean phaseSaveSuccess;
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				List<REN_Task_Template__c> saveList = REN_TaskTemplateDataAccess.saveTemplate(new List<REN_Task_Template__c>{taskTemplate});
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_TEMPLATE_SAVE));
				if(phaseSaveSuccess){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_PHASE_UPDATE));				
				}
				if(!SaveList.isEmpty())
				{
					taskTemplate = saveList[0];
				}
			}
			
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				this.populatePageInformation();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_TEMPLATE_SAVE));
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
		}
			
	}
	
	
	public PageReference templateCancel() {
		try { 
			PageREference pageRef = Page.REN_SegmentOverview;
			pageRef.getParameters().put('tabCategory', 'Admin');
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			return null;
		}
	} 
	
	
	public REN_TaskTemplateList getThis() 
	{
    	return this;
	}
	
	public PageReference REN_toggleFields()
	{
		if (taskTemplate.REN_Record_Type__c == 'Task - Email')
		toggleField=true;
		if (taskTemplate.REN_Record_Type__c == 'Task - Inbox' || taskTemplate.REN_Record_Type__c == 'Task - Standard' || taskTemplate.REN_Record_Type__c == 'Task - Phone Calls')
		toggleField1=true;
		if (taskTemplate.REN_Record_Type__c == 'Task - Phone Calls')
		toggleField2=true;
					
		return null;
	}
	
	
}