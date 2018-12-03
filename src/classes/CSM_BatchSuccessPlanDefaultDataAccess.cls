public with sharing class CSM_BatchSuccessPlanDefaultDataAccess {
public static List<CSM_Batch_Success_Plan_Default__c> getBatchSuccessPlanDefRec(String id){
     	//CSM_Batch_Success_Plan_Default__c thePlanDef = new CSM_Batch_Success_Plan_Default__c();
     	List<CSM_Batch_Success_Plan_Default__c> batchSuccessPlanDef = new List<CSM_Batch_Success_Plan_Default__c>();    
        List<String> fcFieldList = new List<String>{CSM_CONSTANTS.OBJ_AP_ACCOUNT_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_CSM_CONTACT,
        											CSM_CONSTANTS.OBJ_AP_CSM_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_CUSTOMER_SUCCESS_MGR,
        											CSM_CONSTANTS.OBJ_AP_EXEC_SPONSOR,
        											CSM_CONSTANTS.OBJ_AP_PHASE_START_DATE,
        											CSM_CONSTANTS.CSM_BPD_PLANDEFAULTNAME,
        											CSM_CONSTANTS.OBJ_AP_RENEWAL_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_RENEWAL_CONTACT,
        											CSM_CONSTANTS.OBJ_AP_SUPPORT_CONTACT};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BAT_PLAN_DEFAULT, fcFieldList, CSM_Constants.DML_OPERATION_READ);

        if(!String.isEmpty(id)){
          	batchSuccessPlanDef = [select id, name,
    								CSM_Account_Manager__c,
    								CSM_Contact__c,
    								CSM_Manager__c,
    								CSM_Customer_Success_Manager__c,
    								CSM_Exec_Sponsor__c,
    								CSM_Phase_Start_Date__c,
    								CSM_Plan_Default_Name__c,
    								CSM_Renewal_Manager__c,
    								CSM_Renewal_Contact__c,
    								CSM_Support_Contact__c,
    								CreatedById,
    								LastModifiedById,
    								CreatedDate,
    								LastModifiedDate,
    								CSM_Account_Manager__r.Name,
   									CSM_Contact__r.Name,
   									CSM_Manager__r.Name,
    								CSM_Customer_Success_Manager__r.Name,
    								CSM_Exec_Sponsor__r.Name,
    								CSM_Renewal_Manager__r.Name,
    								CSM_Renewal_Contact__r.Name,
    								CSM_Support_Contact__r.Name
          					from CSM_Batch_Success_Plan_Default__c
          					where id = :id
          					limit 1];
    	}
        return batchSuccessPlanDef;
    }
    
    public static List<CSM_Batch_Success_Plan_Default__c> saveBatchPlanDefRecord(List<CSM_Batch_Success_Plan_Default__c> batchSuccessPlanDef){        
        List<String> fcFieldList = new List<String>{CSM_CONSTANTS.OBJ_AP_ACCOUNT_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_CSM_CONTACT,
        											CSM_CONSTANTS.OBJ_AP_CSM_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_CUSTOMER_SUCCESS_MGR,
        											CSM_CONSTANTS.OBJ_AP_EXEC_SPONSOR,
        											CSM_CONSTANTS.OBJ_AP_PHASE_START_DATE,
        											CSM_CONSTANTS.CSM_BPD_PLANDEFAULTNAME,
        											CSM_CONSTANTS.OBJ_AP_RENEWAL_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_RENEWAL_CONTACT,
        											CSM_CONSTANTS.OBJ_AP_SUPPORT_CONTACT};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BAT_PLAN_DEFAULT, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        upsert batchSuccessPlanDef;          
        return batchSuccessPlanDef;
    }   
    public static List<CSM_Batch_Success_Plan_Default__c> getPlanDefaultRecords(){
		List<CSM_Batch_Success_Plan_Default__c> planDefaultList = new List<CSM_Batch_Success_Plan_Default__c>();
		List<String> planDefaultFieldList = new List<String>{CSM_CONSTANTS.OBJ_AP_ACCOUNT_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_CSM_CONTACT,
        											CSM_CONSTANTS.OBJ_AP_CSM_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_CUSTOMER_SUCCESS_MGR,
        											CSM_CONSTANTS.OBJ_AP_EXEC_SPONSOR,
        											CSM_CONSTANTS.OBJ_AP_PHASE_START_DATE,
        											CSM_CONSTANTS.CSM_BPD_PLANDEFAULTNAME,
        											CSM_CONSTANTS.OBJ_AP_RENEWAL_MANAGER,
        											CSM_CONSTANTS.OBJ_AP_RENEWAL_CONTACT,
        											CSM_CONSTANTS.OBJ_AP_SUPPORT_CONTACT};

        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BAT_PLAN_DEFAULT, planDefaultFieldList, CSM_Constants.DML_OPERATION_READ);        
    	String soql = 'select id, name,'+
								'CSM_Account_Manager__c,'+
								'CSM_Contact__c,'+
								'CSM_Manager__c,'+
								'CSM_Customer_Success_Manager__c,'+
								'CSM_Exec_Sponsor__c,'+
								'format(CSM_Phase_Start_Date__c),'+
								'CSM_Plan_Default_Name__c,'+
								'CSM_Renewal_Manager__c,'+
								'CSM_Renewal_Contact__c,'+
								'CSM_Support_Contact__c,'+
								'CreatedById,'+
								'LastModifiedById,'+
								'CreatedDate,'+
								'LastModifiedDate '+
      					'from CSM_Batch_Success_Plan_Default__c order by LastModifiedDate DESC '+
      					'limit 10000';
      	planDefaultList = database.query(soql);
    	return planDefaultList;
	}
}