/**
 * Created Date		: Apr 17, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This  class will have all DML operations done on Task Template
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					User Story				Apr 17, 2017	1.1					Data Access Class
 *
 */
public with sharing class REN_TaskTemplateDataAccess {
	public static List<REN_Task_Template__c> getTaskTemplateByObject(String objectType){
		
		List<REN_Task_Template__c> taskTemplateList = new List<REN_Task_Template__c>();
		List<String> taskTemplateFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													'REN_Record_Type__c',
													'REN_Template_Description__c',
													'REN_Related_To__c',
													'REN_Record_Type_Name__c'};

        CSM_Util.checkCRUD_FLS('REN_Task_Template__c', taskTemplateFieldList, CSM_Constants.DML_OPERATION_READ); 
    	if(String.isNotBlank(objectType)){
    		taskTemplateList = [Select Id, name, REN_Record_Type__c, REN_Template_Description__c, REN_Record_Type_Name__c From REN_Task_Template__c Where REN_Related_To__c=:objectType ORDER BY LastModifiedDate DESC LIMIT 10000];
    	}else{
    		taskTemplateList = [Select Id, name, REN_Record_Type__c, REN_Template_Description__c, REN_Record_Type_Name__c From REN_Task_Template__c ORDER BY LastModifiedDate DESC LIMIT 10000]; 
    	}
		return taskTemplateList;
	}
	public static REN_Task_Template__c getTaskTemplateById(String taskTempId){
		
		REN_Task_Template__c taskTemplateObj = new REN_Task_Template__c();
		List<String> taskTemplateFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													'REN_Record_Type__c',
													'REN_Template_Description__c',
													'REN_Related_To__c'};

        CSM_Util.checkCRUD_FLS('REN_Task_Template__c', taskTemplateFieldList, CSM_Constants.DML_OPERATION_READ); 
    	if(String.isNotBlank(taskTempId)){
    		taskTemplateObj = [Select Id, name, REN_Record_Type__c, REN_Template_Description__c, REN_Related_To__c, REN_Record_Type_Name__c From REN_Task_Template__c Where Id=:taskTempId];
    	}else{
    		taskTemplateObj = [Select Id, name, REN_Record_Type__c, REN_Template_Description__c, REN_Related_To__c, REN_Record_Type_Name__c From REN_Task_Template__c LIMIT 1000]; 
    	}
		return taskTemplateObj;
	}
	public static void deleteTaskTemplate(List<REN_Task_Template__c> taskTemplateList){
		if(taskTemplateList != null && !taskTemplateList.isEmpty()){
			CSM_Util.checkCRUD_FLS('REN_Task_Template__c', null, CSM_Constants.DML_OPERATION_DELETE);
			delete taskTemplateList;
		}
	}
	
	public static List<REN_TASK_TEMPLATE__c> saveTaskTemplate(List<REN_TASK_TEMPLATE__c> taskTemplateList){        
        List<String> taskTemplateFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													'REN_Record_Type__c',
													'REN_Template_Description__c',
													'REN_Related_To__c'};
        CSM_Util.checkCRUD_FLS('REN_Task_Template__c', taskTemplateFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        upsert taskTemplateList;          
        return taskTemplateList;
    }
    // Methods Added by Sanket
    // Need to revisit when working on edit task template functionality
    public static REN_Task_Template__c populateTaskTemplateInformation(String templateId) {
        REN_Task_Template__c taskTemplate = new REN_Task_Template__c();
        try {
            if(templateId != null)
            {
                
                List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ID, CSM_Constants.OBJ_APT_NAME, CSM_Constants.OBJ_APT_DISPLAY_NAME,CSM_Constants.OBJ_APT_ISACTIVE,CSM_Constants.OBJ_APT_CURRENCY_CODE,CSM_Constants.OBJ_APT_USEAS_SCOUT_DEF};
                
                CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
                
                    List<REN_Task_Template__c> tList = new List<REN_Task_Template__c>();
                    tList = [select id, 
                                    name, 
                                    REN_Template_Description__c,REN_Record_Type__c,REN_Subject__c,
                                    REN_Due_Date__c,REN_Status__c ,REN_BCC__c,REN_CC__c,REN_Comments__c
                                    ,REN_Completed_Date__c,REN_Contact__c,REN_ClosedDate__c,
                                    REN_Direction__c,REN_Priority__c,REN_Record_Type_Name__c,
                                    REN_Related_To__c,REN_Type__c
                               from REN_Task_Template__c 
                              where id = :templateId limit 1];
                    if(!tList.isEmpty())
                    {
                        taskTemplate = tList[0];
                    }
            }
                
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            
        }
        return taskTemplate;
    }
        
    
    public static List<REN_Task_Template__c> saveTemplate(List<REN_Task_Template__c> taskTemplatesToSave)
    {
        
        List<String> taskTmplFieldList = new List<String>{'REN_BCC__c',
        											'REN_CC__c',
        											'REN_Comments__c',
        											'REN_Completed_Date__c',
        											'REN_Contact__c',
        											'REN_ClosedDate__c',
        											'REN_Direction__c',
        											'REN_Due_Date__c',
        											'REN_Priority__c',
        											'REN_Record_Type__c',
        											'REN_Record_Type_Name__c',
        											'REN_Related_To__c',
        											'REN_Status__c',
        											'REN_Subject__c',
        											'REN_Template_Description__c',
        											'REN_Type__c'};
                  
        CSM_Util.checkCRUD_FLS('REN_Task_Template__c', taskTmplFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        
        upsert taskTemplatesToSave;          
        
        return taskTemplatesToSave;
    }
    
       
    
     public static List<REN_Task_Template__c> insertTemplate(List<REN_Task_Template__c> taskTemplatesToSave)
    {
        List<String> aptFieldList = new List<String>{CSM_Constants.OBJ_APT_DISPLAY_NAME, 
        	CSM_Constants.OBJ_APT_ISACTIVE, CSM_Constants.OBJ_APT_USEAS_SCOUT_DEF};
                  
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, aptFieldList, CSM_Constants.DML_OPERATION_INSERT);
        
        insert taskTemplatesToSave;          
        
        return taskTemplatesToSave;
    }
       
}