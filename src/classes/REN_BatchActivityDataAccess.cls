public with sharing class REN_BatchActivityDataAccess {
    
    public static REN_Batch_Activity__c getBatchAct(String id){
        REN_Batch_Activity__c theBatch = new REN_Batch_Activity__c();    
        List<String> fcFieldList = new List<String>{REN_CONSTANTS.EMAIL_NOTIFI,REN_CONSTANTS.REN_PB,REN_CONSTANTS.REN_GROUPING,REN_CONSTANTS.REN_SRC_REC_FLTR,REN_CONSTANTS.REN_JOB_STRT_DT,REN_CONSTANTS.REN_LAST_MOD_DT,REN_CONSTANTS.REN_LAST_MOD_ON,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    'REN_Task_Template__c',
                                                    'REN_Segment__c',
                                                    'REN_Owner_Field_Name__c',
                                                    'REN_Object__c',
                                                    'REN_Designated_TaskOwner__c',
                                                    REN_CONSTANTS.REN_OPP_AMOUNT_TOTL,
                                                    REN_CONSTANTS.REN_BAT_NUM,
                                                    REN_CONSTANTS.REN_GEN_RECS,
                                                    REN_CONSTANTS.REN_JOB_COMPLT_DT,
                                                    REN_CONSTANTS.REN_RENEWABLE_PROD,
                                                    REN_CONSTANTS.REN_FILT_CRITERIA,
                                                    REN_CONSTANTS.REN_GROUP_CRITERIA,
                                                    REN_CONSTANTS.REN_FAIL_ASSET};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_ACT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        List<String> ttFieldList = new List<String>{ 'REN_BCC__c', 'REN_CC__c', 'REN_ClosedDate__c', 'REN_Comments__c', 'REN_Completed_Date__c', 'REN_Contact__c', 'REN_Direction__c', 'REN_Due_Date__c', 'REN_Priority__c', 'REN_Record_Type__c', 'REN_Related_To__c', 'REN_Status__c', 'REN_Subject__c', 'REN_Template_Description__c', 'REN_Type__c'};
        CSM_Util.checkCRUD_FLS('REN_Task_Template__c', ttFieldList, CSM_Constants.DML_OPERATION_READ);

        if(!String.isEmpty(id)){
            List<REN_Batch_Activity__c> batchActivityLst = new List<REN_Batch_Activity__c>();
            String batchActivityQueryStr = 'select id, name, REN_Task_Template__c, REN_Segment__c, REN_Designated_TaskOwner__c, REN_Object__c, REN_Segment__r.Name, REN_Segment__r.REN_Type__c, REN_Owner_Field_Name__c, REN_Email_Notification__c, REN_Pricebook__c, REN_Grouping__c, REN_Source_Record_Filter__c, REN_Job_Start_Date__c,' + 
		                                    'REN_Scheduler_ID__c, REN_Job_ID__c, REN_Status__c, REN_Source_Record_Filter__r.REN_Filter_Criteria__c, REN_Source_Record_Filter__r.REN_Record_Key__c,' + 
		                                    'REN_Grouping__r.REN_Filter_Criteria__c, REN_Source_Record_Filter__r.REN_View_Name__c, REN_Grouping__r.REN_View_Name__c, REN_Last_Modified_By__c,' + 
		                                    'REN_Last_Modified_On__c, REN_Created_On__c, REN_Created_By__c, REN_Created_By__r.name, REN_Batch_Number__c,' + 
		                                    'REN_Generated_Records__c, REN_Job_Completion_Date__c, REN_Last_Modified_By__r.name, REN_Source_Record_Filter__r.REN_Description__c,' + 
		                                    'REN_Grouping__r.REN_Description__c, REN_Renewable_Products__c, REN_Filter_Criteria__c, REN_Grouping_Criteria__c, REN_Closed_Date_Depends_On__c,' + 
		                                    'REN_Closed_Date_Options__c, REN_Failure_Assets__c, ' + 
		                                    'REN_Task_Template__r.REN_BCC__c, REN_Task_Template__r.REN_CC__c, REN_Task_Template__r.REN_ClosedDate__c, REN_Task_Template__r.REN_Comments__c, ' +
		                                    'REN_Task_Template__r.REN_Completed_Date__c, REN_Task_Template__r.REN_Contact__c, REN_Task_Template__r.REN_Direction__c, ' + 
		                                    'REN_Task_Template__r.REN_Due_Date__c, REN_Task_Template__r.REN_Priority__c, REN_Task_Template__r.REN_Record_Type__c, ' + 
		                                    'REN_Task_Template__r.REN_Related_To__c, REN_Task_Template__r.REN_Status__c, REN_Task_Template__r.REN_Subject__c, REN_Task_Template__r.REN_Template_Description__c, ' + 
		                                    'REN_Task_Template__r.REN_Type__c ';
            
            //Eswar Bala - Partial fix for DE1371. ConvertCurrency still needs to apply for below field when the field is replaced with a Currency field.
            if(UserInfo.isMultiCurrencyOrganization()){
            	batchActivityQueryStr += ', format(convertCurrency(REN_Total_Amount__c)), CurrencyIsoCode';
            }
            else{
            	batchActivityQueryStr += ', format(REN_Total_Amount__c)';
            }
            batchActivityQueryStr += ' FROM REN_Batch_Activity__c where id = :id OR REN_Scheduler_ID__c = :id OR REN_Job_ID__c = :id  limit 1';
            batchActivityLst = Database.query(batchActivityQueryStr);
            
            if(!batchActivityLst.isEmpty()){
                theBatch = batchActivityLst[0];
            }
        }
        return theBatch;
    }
    
    public static REN_Batch_Activity__c getBatchActSObject(String batchId){
        REN_Batch_Activity__c theBatch;    
        List<String> fcFieldList = new List<String>{REN_CONSTANTS.EMAIL_NOTIFI,REN_CONSTANTS.REN_PB,REN_CONSTANTS.REN_GROUPING,REN_CONSTANTS.REN_SRC_REC_FLTR,REN_CONSTANTS.REN_JOB_STRT_DT,REN_CONSTANTS.REN_LAST_MOD_DT,REN_CONSTANTS.REN_LAST_MOD_ON,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    REN_CONSTANTS.REN_OPP_AMOUNT_TOTL,
                                                    REN_CONSTANTS.REN_BAT_NUM,
                                                    REN_CONSTANTS.REN_GEN_RECS,
                                                    REN_CONSTANTS.REN_JOB_COMPLT_DT,
                                                    REN_CONSTANTS.REN_RENEWABLE_PROD,
                                                    REN_CONSTANTS.REN_FILT_CRITERIA,
                                                    REN_CONSTANTS.REN_GROUP_CRITERIA,
                                                    'REN_Task_Template__c',
                                                    'REN_Owner_Field_Name__c',
                                                    'REN_Segment__c',
                                                    'REN_Designated_TaskOwner__c',
                                                    REN_CONSTANTS.REN_FAIL_ASSET};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_ACT, fcFieldList, CSM_Constants.DML_OPERATION_READ);

        if(!String.isEmpty(batchId)){
            List<REN_Batch_Activity__c> batchActivityLst = new List<REN_Batch_Activity__c>();
            String batchActivityQueryStr = 'select id, name, REN_Email_Notification__c, REN_Pricebook__c, REN_Grouping__c, REN_Owner_Field_Name__c, REN_Designated_TaskOwner__c, REN_Source_Record_Filter__c, REN_Job_Start_Date__c,' + 
		                                    'REN_Scheduler_ID__c, REN_Job_ID__c, REN_Status__c, REN_Source_Record_Filter__r.REN_Filter_Criteria__c, REN_Source_Record_Filter__r.REN_Record_Key__c,' + 
		                                    'REN_Grouping__r.REN_Filter_Criteria__c, REN_Source_Record_Filter__r.REN_View_Name__c, REN_Grouping__r.REN_View_Name__c, REN_Last_Modified_By__c,' + 
		                                    'REN_Last_Modified_On__c, REN_Created_On__c, REN_Created_By__c, REN_Created_By__r.name, REN_Batch_Number__c,' + 
		                                    'REN_Generated_Records__c, REN_Job_Completion_Date__c, REN_Last_Modified_By__r.name, REN_Source_Record_Filter__r.REN_Description__c,' + 
		                                    'REN_Grouping__r.REN_Description__c, REN_Renewable_Products__c, REN_Filter_Criteria__c, REN_Grouping_Criteria__c, REN_Closed_Date_Depends_On__c,' + 
		                                    'REN_Closed_Date_Options__c, REN_Failure_Assets__c, REN_Batch_Type__c, REN_Grouping_Filter__c, REN_Object__c, REN_Plan_Template_Name__c, REN_Plan_Template_Id__c, REN_Plan_Template_Id__r.CSM_Template_Name__c, ' + 
		                                    'REN_Task_Template__c, REN_Task_Template__r.Name, REN_Segment__c, REN_Segment__r.REN_Type__c, REN_Segment__r.Name ';
            
            //Eswar Bala - Partial fix for DE1371. ConvertCurrency still needs to apply for below field when the field is replaced with a Currency field.
            if(UserInfo.isMultiCurrencyOrganization()){
            	batchActivityQueryStr += ', format(convertCurrency(REN_Total_Amount__c)), CurrencyIsoCode';
            }
            else{
            	batchActivityQueryStr += ', format(REN_Total_Amount__c)';
            }
            
            batchActivityQueryStr += ' FROM REN_Batch_Activity__c where id = :batchId OR REN_Scheduler_ID__c = :batchId OR REN_Job_ID__c = :batchId  limit 1';

            batchActivityLst = Database.query(batchActivityQueryStr);
            
            if(!batchActivityLst.isEmpty()){
                theBatch = batchActivityLst[0];
            }
        }
        return theBatch;
    }
    //@Deprecated
    public static REN_Batch_Activity__c saveBatchAct(REN_Batch_Activity__c batchActivity){
        return saveBatchAct(new List<REN_Batch_Activity__c> {batchActivity})[0];
    }
    
    public static List<REN_Batch_Activity__c> saveBatchAct(List<REN_Batch_Activity__c> batchActivityList){        
        List<String> fcFieldList = new List<String>{REN_CONSTANTS.EMAIL_NOTIFI,
        	                                        REN_CONSTANTS.REN_PB,
        	                                        REN_CONSTANTS.REN_GROUPING,
        	                                        REN_CONSTANTS.REN_SRC_REC_FLTR,
        	                                        REN_CONSTANTS.REN_JOB_STRT_DT,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    REN_CONSTANTS.REN_OPP_AMOUNT_TOTL,
                                                    REN_CONSTANTS.REN_OBJ_TYPE,
                                                    REN_CONSTANTS.REN_GROUPING_FILTER,
                                                    REN_CONSTANTS.REN_JOB_ID,
                                                    REN_CONSTANTS.REN_JOB_COMPLT_DT,
                                                    REN_CONSTANTS.REN_FAILURE_ASSETS,
                                                    REN_CONSTANTS.REN_SCHEDULER_ID,
                                                    REN_CONSTANTS.REN_LAST_MOD_ON,
                                                    REN_CONSTANTS.REN_LAST_MOD_DT,
                                                    REN_CONSTANTS.REN_CLOSED_DATE_OPTIONS,
                                                    REN_CONSTANTS.REN_CLOSED_DATE_DEPENDS_ON,
                                                    REN_CONSTANTS.REN_STATUS,
                                                    REN_CONSTANTS.REN_GEN_RECS,
                                                    REN_CONSTANTS.OBJ_SEGMENT,
                                                    REN_CONSTANTS.REN_BATCH_TYPE,
                                                    'Id',
                                                    'REN_Owner_Field_Name__c',
                                                    'REN_Designated_TaskOwner__c',
                                                    'REN_Task_Template__c'
                                                    };
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_ACT, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        upsert batchActivityList;          
        return batchActivityList;
    }

    public static List<REN_Batch_Activity__c> getBatchActivityRecords(String batchType)
    {
        List<REN_Batch_Activity__c> batchActList = new List<REN_Batch_Activity__c>();
        List<String> batchActFieldList = new List<String>{
                                                    REN_CONSTANTS.REN_GROUPING,
                                                    REN_CONSTANTS.REN_SRC_REC_FLTR,
                                                    REN_CONSTANTS.REN_JOB_STRT_DT,
                                                    REN_CONSTANTS.REN_JOB_COMPLT_DT,
                                                    REN_CONSTANTS.REN_LAST_MOD_DT,
                                                    REN_CONSTANTS.REN_STATUS,
                                                    REN_CONSTANTS.REN_GEN_RECS,
                                                    REN_CONSTANTS.REN_BAT_NUM,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    REN_CONSTANTS.REN_LAST_MOD_ON,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    REN_CONSTANTS.REN_OPP_AMOUNT_TOTL,
                                                    REN_CONSTANTS.REN_FAIL_ASSET
            };

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_ACT, batchActFieldList, CSM_Constants.DML_OPERATION_READ);        
        
        if(batchType.equalsIgnoreCase('BatchHistory'))
        {
        batchActList = Database.query('Select  Id,'+
                                'REN_Grouping__c,'+
                                'REN_Source_Record_Filter__c,'+
                                'FORMAT(REN_Job_Start_Date__c),'+
                                'FORMAT(REN_Job_Completion_Date__c),'+
                                'REN_Last_Modified_By__c,'+
                                'REN_Status__c,'+
                                'REN_Generated_Records__c,'+
                                'REN_Source_Record_Filter__r.REN_View_Name__c,'+
                                'REN_Grouping__r.REN_View_Name__c,'+
                                'REN_Batch_Number__c,'+
                                'CreatedById,'+
                                'FORMAT(CreatedDate),'+
                                'FORMAT(REN_Last_Modified_On__c),'+
                                'REN_Last_Modified_By__r.name,'+
                                'CreatedBy.name,'+
                                'FORMAT(REN_Created_On__c),'+
                                'REN_Created_By__c,'+
                                'FORMAT(REN_Total_Amount__c),'+
                                'REN_Created_By__r.name,'+
                                'REN_Closed_Date_Depends_On__c,'+
                                'REN_Closed_Date_Options__c,'+
                                'REN_Failure_Assets__c,'+
                                'REN_Batch_Type__c,'+
                                'REN_Object__c'+
                                ' From REN_Batch_Activity__c Where REN_Batch_Type__c = null ORDER BY LastModifiedDate DESC  LIMIT 10000'); 
        } else if(batchType.equalsIgnoreCase('CSM_PTA')) {
            batchActList = Database.query('Select  Id,'+
                                'REN_Grouping__c,'+
                                'REN_Source_Record_Filter__c,'+
                                'FORMAT(REN_Job_Start_Date__c),'+
                                'FORMAT(REN_Job_Completion_Date__c),'+
                                'REN_Last_Modified_By__c,'+
                                'REN_Status__c,'+
                                'REN_Generated_Records__c,'+
                                'REN_Source_Record_Filter__r.REN_View_Name__c,'+
                                'REN_Grouping__r.REN_View_Name__c,'+
                                'REN_Batch_Number__c,'+
                                'CreatedById,'+
                                'FORMAT(CreatedDate),'+
                                'FORMAT(REN_Last_Modified_On__c),'+
                                'REN_Last_Modified_By__r.name,'+
                                'CreatedBy.name,'+
                                'FORMAT(REN_Created_On__c),'+
                                'REN_Created_By__c,'+
                                'FORMAT(REN_Total_Amount__c),'+
                                'REN_Created_By__r.name,'+
                                'REN_Closed_Date_Depends_On__c,'+
                                'REN_Closed_Date_Options__c,'+
                                'REN_Failure_Assets__c,'+
                                'REN_Batch_Type__c,'+
                                'REN_Object__c'+
                                ' From REN_Batch_Activity__c Where REN_Batch_Type__c = :batchType ORDER BY LastModifiedDate DESC  LIMIT 10000');
        } else if(batchType.equalsIgnoreCase(REN_Constants.BATCH_ACTIVITY_TYPE_SEGMENT_TASK)) {
        	 batchActList = Database.query('Select  Id,'+
                                'FORMAT(REN_Job_Start_Date__c),'+
                                'FORMAT(REN_Job_Completion_Date__c),'+
                                'REN_Status__c,'+
                                'REN_Generated_Records__c,'+
                                'REN_Batch_Number__c,'+
                                'FORMAT(REN_Last_Modified_On__c),'+ 
                                'REN_Failure_Assets__c,'+
                                'REN_Segment__r.Name,' +
                                'REN_Task_Template__r.Name,' +
                                'REN_Designated_TaskOwner__r.Name' +
                                ' From REN_Batch_Activity__c Where REN_Batch_Type__c = :batchType ORDER BY LastModifiedDate DESC  LIMIT 10000');
        	
        }
        return batchActList;
    }
    
    public static List<REN_Batch_Activity__c> getBatchActivityByTskTmpl(String taskTemplateId)
    {
        List<REN_Batch_Activity__c> batchActList = new List<REN_Batch_Activity__c>();
        List<String> batchActFieldList = new List<String>{
                                                    REN_CONSTANTS.REN_GROUPING,
                                                    REN_CONSTANTS.REN_SRC_REC_FLTR,
                                                    REN_CONSTANTS.REN_JOB_STRT_DT,
                                                    REN_CONSTANTS.REN_JOB_COMPLT_DT,
                                                    REN_CONSTANTS.REN_LAST_MOD_DT,
                                                    REN_CONSTANTS.REN_STATUS,
                                                    REN_CONSTANTS.REN_GEN_RECS,
                                                    REN_CONSTANTS.REN_BAT_NUM,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    REN_CONSTANTS.REN_LAST_MOD_ON,
                                                    REN_CONSTANTS.REN_CREATEDBY,
                                                    REN_CONSTANTS.REN_CREATEDON,
                                                    REN_CONSTANTS.REN_OPP_AMOUNT_TOTL,
                                                    REN_CONSTANTS.REN_FAIL_ASSET,
                                                    'REN_Task_Template__c'
       	};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_ACT, batchActFieldList, CSM_Constants.DML_OPERATION_READ);        
        
        if(String.isNotBlank(taskTemplateId))
        {
        	batchActList = [Select  Id, REN_Task_Template__c From REN_Batch_Activity__c Where REN_Task_Template__c = :taskTemplateId LIMIT 10]; 
        } 
        return batchActList;
    }
    
}