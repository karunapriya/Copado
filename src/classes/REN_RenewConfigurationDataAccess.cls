public with sharing class REN_RenewConfigurationDataAccess
{

	public static List<REN_Renew_Configuration__c> getRenewConfigByTriggerType(String triggerType){
		
		List<REN_Renew_Configuration__c> renConfigList = new List<REN_Renew_Configuration__c>();
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													REN_Constants.OBJ_RC_IS_ACTIVE, 
													REN_Constants.OBJ_RC_FILTER_LOGIC, 
													REN_Constants.OBJ_RC_FILTER_CRITERIA, 
													REN_Constants.OBJ_RC_RECORD_KEY,
													REN_Constants.OBJ_RC_UPDATED_ON,
													REN_Constants.OBJ_RC_CURRENCYCODE};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, renewConfigFieldList, CSM_Constants.DML_OPERATION_READ); 
    	if(String.isNotBlank(triggerType)){
    		renConfigList = [Select Id, name, REN_Record_Key__c, RLM_Currency_Code__c, RLM_Filter_Logic__c, REN_Filter_Criteria__c, REN_Is_Active__c, REN_Update_On__c, (Select RLM_LineNo__c, RLM_Field_Name__c, RLM_Field_Type__c, RLM_Values__c, RLM_Operator__c, RLM_Is_Specific_Date__c, RLM_Date_Value__c From Line_Criteria__r) From REN_Renew_Configuration__c Where REN_Record_Key__c=:triggerType AND (REN_Configuration_Type__c = null OR REN_Configuration_Type__c = :REN_Constants.OBJ_RC_CTYPE_RENEW_OP) LIMIT 100];
    	}else{
    		renConfigList = [Select Id, name, REN_Record_Key__c, RLM_Currency_Code__c, RLM_Filter_Logic__c, REN_Filter_Criteria__c, REN_Is_Active__c, REN_Update_On__c, (Select RLM_LineNo__c, RLM_Field_Name__c, RLM_Field_Type__c, RLM_Values__c, RLM_Operator__c, RLM_Is_Specific_Date__c, RLM_Date_Value__c From Line_Criteria__r) From REN_Renew_Configuration__c WHERE IsDeleted = false AND (REN_Configuration_Type__c = null OR REN_Configuration_Type__c = :REN_Constants.OBJ_RC_CTYPE_RENEW_OP) LIMIT 100];
    	}
		return renConfigList;
	}
	
	public static List<REN_Renew_Configuration__c> getRenewConfigByConfigurationType(String configType){
		system.debug('\n~~~~configType: ' + configType);
		List<REN_Renew_Configuration__c> renConfigList = new List<REN_Renew_Configuration__c>();
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													REN_Constants.OBJ_RC_IS_ACTIVE, 
													REN_Constants.OBJ_RC_FILTER_LOGIC, 
													REN_Constants.OBJ_RC_FILTER_CRITERIA, 
													REN_Constants.OBJ_RC_RECORD_KEY,
													REN_Constants.OBJ_RC_UPDATED_ON,
													REN_Constants.OBJ_RC_CONFIGURATION_TYPE,
													REN_Constants.OBJ_RC_DESCRIPTION,
													REN_Constants.OBJ_RC_VIEW_NAME,
													REN_Constants.OBJ_RC_CURRENCYCODE};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, renewConfigFieldList, CSM_Constants.DML_OPERATION_READ);  
       Integer limitVal = CSM_AdminDataAccess.getRecLimit(REN_Constants.REC_LIMIT_BATCH_OPP_GENRATION_GRID);
        if(String.isNotBlank(configType)){       	
    	renConfigList = [Select Id, name, REN_View_Name__c, REN_Description__c, RLM_Currency_Code__c, REN_Record_Key__c, RLM_Filter_Logic__c, REN_Filter_Criteria__c, REN_Is_Active__c, REN_Update_On__c, (Select format(RLM_LineNo__c), RLM_Field_Name__c, RLM_Field_Type__c, RLM_Values__c, RLM_Operator__c, RLM_Is_Specific_Date__c, format(RLM_Date_Value__c)	 From Line_Criteria__r) From REN_Renew_Configuration__c Where REN_Configuration_Type__c = :configType ORDER BY LastModifiedDate DESC LIMIT :limitVal];
        }
		system.debug('soqlren: ' + renConfigList);
		return renConfigList;
		}
	
	public static List<REN_Renew_Configuration__c> getRenewConfigByRecordKey(Set<String> recordKeySet){
		List<REN_Renew_Configuration__c> renConfigList = new List<REN_Renew_Configuration__c>();
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													REN_Constants.OBJ_RC_IS_ACTIVE, 
													REN_Constants.OBJ_RC_FILTER_LOGIC, 
													REN_Constants.OBJ_RC_FILTER_CRITERIA, 
													REN_Constants.OBJ_RC_RECORD_KEY,
													REN_Constants.OBJ_RC_UPDATED_ON,
													REN_Constants.OBJ_RC_CURRENCYCODE};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, renewConfigFieldList, CSM_Constants.DML_OPERATION_READ);        
   		renConfigList = [Select Id, name, REN_Record_Key__c, RLM_Currency_Code__c, RLM_Filter_Logic__c, REN_Filter_Criteria__c, REN_Is_Active__c, REN_Update_On__c, 
   				(Select RLM_LineNo__c, RLM_Field_Name__c, RLM_Field_Type__c, RLM_Values__c, RLM_Operator__c, RLM_Is_Specific_Date__c, RLM_Date_Value__c From Line_Criteria__r) 
   			From REN_Renew_Configuration__c Where REN_Record_Key__c IN:recordKeySet LIMIT 100];
        return renConfigList;
	}
	
	public static REN_Renew_Configuration__c getRenewConfigByRecordKey(String recordKey){
		List<REN_Renew_Configuration__c> renConfigList = new List<REN_Renew_Configuration__c>();
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													REN_Constants.OBJ_RC_IS_ACTIVE, 
													REN_Constants.OBJ_RC_FILTER_LOGIC, 
													REN_Constants.OBJ_RC_CONFIGURATION_TYPE,
													REN_Constants.OBJ_RC_VIEW_NAME,
													REN_Constants.OBJ_RC_FILTER_CRITERIA, 
													REN_Constants.OBJ_RC_RECORD_KEY,
													REN_Constants.OBJ_RC_UPDATED_ON,
													REN_Constants.OBJ_RC_CURRENCYCODE};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, renewConfigFieldList, CSM_Constants.DML_OPERATION_READ);        
    	renConfigList = [Select Id, name, REN_Record_Key__c,REN_View_Name__c, REN_Configuration_Type__c,RLM_Currency_Code__c, RLM_Filter_Logic__c, REN_Filter_Criteria__c, REN_Is_Active__c, REN_Update_On__c From REN_Renew_Configuration__c Where REN_Record_Key__c =:recordKey LIMIT 1];
        if(!renConfigList.isEmpty()){
        	return renConfigList[0];
        }
        else {
        	return null;
        }
	}
	
	public static List<REN_Renew_Configuration__c> getRenewConfigByViewName(String viewName){
		List<REN_Renew_Configuration__c> renConfigList = new List<REN_Renew_Configuration__c>();
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_RC_VIEW_NAME};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, renewConfigFieldList, CSM_Constants.DML_OPERATION_READ);        
    	renConfigList = [Select Id, REN_View_Name__c From REN_Renew_Configuration__c Where REN_View_Name__c =:viewName LIMIT 40001];
        return renConfigList;
	}
	
	public static REN_Renew_Configuration__c getRenewConfigByIdy(Id configId){
		List<REN_Renew_Configuration__c> renConfigList = new List<REN_Renew_Configuration__c>();
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													REN_Constants.OBJ_SC_NAME, 
													REN_Constants.OBJ_RC_IS_ACTIVE, 
													REN_Constants.OBJ_RC_FILTER_LOGIC, 
													REN_Constants.OBJ_RC_FILTER_CRITERIA, 
													REN_Constants.OBJ_RC_RECORD_KEY,
													REN_Constants.OBJ_RC_UPDATED_ON,
													REN_Constants.OBJ_RC_DESCRIPTION,
													REN_Constants.OBJ_RC_VIEW_NAME,
													REN_Constants.OBJ_RC_CONFIGURATION_TYPE,
													REN_Constants.OBJ_RC_CURRENCYCODE};

        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_RC, 
                CSM_Constants.DML_OPERATION_READ, renewConfigFieldList);
        if (noAccessFieldList.isEmpty())
        {    
        	renConfigList = [Select Id, name, REN_Configuration_Type__c, RLM_Currency_Code__c, REN_View_Name__c, REN_Record_Key__c, RLM_Filter_Logic__c, REN_Filter_Criteria__c, REN_Description__c, REN_Plan_Object_Name__c, CreatedById, LastModifiedById, CreatedDate, LastModifiedDate  From REN_Renew_Configuration__c Where Id =:configId LIMIT 1];
        }
        else
        {
        	 String[] arguments = new String[] {REN_Constants.OBJ_RC + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
		if (renConfigList.isEmpty())
		{
			return null;
		}
		return renConfigList[0];
	}
	
	public static List<REN_Renew_Configuration__c> saveRenewConfiguration(List<REN_Renew_Configuration__c> renConfigList){
		List<String> renewConfigFieldList = new List<String>{
													REN_Constants.FLD_ID, 
													//REN_Constants.OBJ_SC_NAME, 
													REN_Constants.OBJ_RC_IS_ACTIVE, 
													REN_Constants.OBJ_RC_FILTER_LOGIC, 
													REN_Constants.OBJ_RC_FILTER_CRITERIA, 
													REN_Constants.OBJ_RC_RECORD_KEY,
													REN_Constants.OBJ_RC_UPDATED_ON,
													REN_Constants.OBJ_RC_VIEW_NAME};


        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_RC, 
                CSM_Constants.DML_OPERATION_UPSERT, renewConfigFieldList);
        if (noAccessFieldList.isEmpty()){
        	upsert renConfigList;
        }else{
        	String[] arguments = new String[] {REN_Constants.OBJ_RC + ':'+String.valueOf(noAccessFieldList)};
			throw new CSM_AccessController.AccessControlDmlException( String.format(
		        System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments)); 
        }
        return renConfigList;
	}
	
	public static void deleteRenewConfig(List<REN_Renew_Configuration__c> renewConfigList){
		if(renewConfigList != null && !renewConfigList.isEmpty()){
			CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, null, CSM_Constants.DML_OPERATION_DELETE);
			delete renewConfigList;
		}
	}
	public static List<SObject> getRecordsByCriteria(List<String> fieldList , String obj, string criteria ,integer limitRecord){
		String queryFields='';
		integer i =fieldList.size();
		for(integer index =0 ; index< fieldList.size(); index++ ){
			queryFields =  queryFields +fieldList[index] ;
			if(i>1 && index != i-1)
			{
			queryFields = queryFields +',';
			}
		}
		CSM_Util.checkCRUD_FLS(obj, fieldList, CSM_Constants.DML_OPERATION_READ);
		String soql = 'SELECT '+String.escapeSingleQuotes(queryFields)+' FROM ' + String.escapeSingleQuotes(obj) + ' WHERE '  + criteria + ' Limit 1';
		System.debug('\n\n~~~~soql: ' + soql);
		List<SObject> sObjList = Database.query(soql);
		return sObjList;
	}
	
	public static Integer getPTAObjectFilterCount(String fromSoql, Integer recLimits){
			List<String> fieldList = new List<String>{};
	     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, fieldList, CSM_Constants.DML_OPERATION_READ);
			String soql = 'Select id ' + fromSoql + (recLimits > 0 ? ' LIMIT ' + recLimits : '');
	
			List<SObject> sObjectList = Database.query(soql);
			if(sObjectList == null || sObjectList.isEmpty()){
				return 0;
			}
	
			return sObjectList.size();
	}
	
	public static REN_Renew_Configuration__c getPTAFilterCriteria(String renConfigId){
		List<String> fieldList = new List<String>{REN_Constants.OBJ_RC_FILTER_CRITERIA};
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RC, fieldList, CSM_Constants.DML_OPERATION_READ);
		REN_Renew_Configuration__c renConfig = [Select REN_Filter_Criteria__c from REN_Renew_Configuration__c where id = :renConfigId ];

		return renConfig;
	}
		
}