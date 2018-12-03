public with sharing class REN_RSConfigurationDataAccess {
	
	//It returns configuration object according to the flow name passed to method
	public static List<sObject> getConfigSettings(Set<String> flowNames){
		String baseNamespace = CSM_Util.getNamespace();
        
		List<String> fieldNameList = new List<String>{baseNamespace + 'REN_Invoking_Object__c', baseNamespace + 'REN_Named_Credential__c', baseNamespace + 'REN_Named_Credential_URL_Extension__c', baseNamespace + 'REN_Field_Set_Name__c', 
			baseNamespace + 'REN_Flow_Name__c', baseNamespace + 'REN_Columns__c', baseNamespace + 'REN_Custom_Object__c', baseNamespace + 'REN_Custom_Permission_Name__c', baseNamespace + 'REN_Display_Dialog__c', baseNamespace + 'REN_SOQL__c',baseNamespace + 'REN_RS_Record_Limit__c'};
		
		CSM_Util.checkCRUD_FLS(baseNamespace + 'REN_RS_Config__c', fieldNameList, CSM_Constants.DML_OPERATION_READ);
		
		if(!flowNames.isEmpty()){
			
			String queryString = 'Select ' + baseNamespace + 'REN_Invoking_Object__c, ' + baseNamespace + 'REN_Named_Credential__c, ' + baseNamespace + 'REN_Named_Credential_URL_Extension__c, ' + baseNamespace + 'REN_Field_Set_Name__c, ' + baseNamespace + 'REN_Flow_Name__c, ' + baseNamespace + 'REN_Columns__c, ' + baseNamespace + 'REN_Custom_Object__c, ' + baseNamespace + 'REN_Custom_Permission_Name__c, ' + baseNamespace + 'REN_Display_Dialog__c, '+ baseNamespace + 'REN_RS_Record_Limit__c, ' + baseNamespace + 'REN_SOQL__c from ' + baseNamespace + 'REN_RS_Config__c where ' + baseNamespace + 'REN_Flow_Name__c IN: flowNames ';
            
            List<sObject> configurationObjList = Database.query(queryString);
			
			if(!configurationObjList.isEmpty())
				return configurationObjList;
		}
		
		return null;
	}

    //It returns configuration object according to the flow name passed to method
	public static List<sObject> getConfigSettings(List<String> flowNames){
		String baseNamespace = CSM_Util.getNamespace();
        
		List<String> fieldNameList = new List<String>{baseNamespace + 'REN_Invoking_Object__c', baseNamespace + 'REN_Named_Credential__c', baseNamespace + 'REN_Named_Credential_URL_Extension__c', baseNamespace + 'REN_Field_Set_Name__c', 
			baseNamespace + 'REN_Flow_Name__c', baseNamespace + 'REN_Columns__c', baseNamespace + 'REN_Custom_Object__c', baseNamespace + 'REN_Custom_Permission_Name__c', baseNamespace + 'REN_Display_Dialog__c', baseNamespace + 'REN_SOQL__c', baseNamespace + 'REN_RS_Record_Limit__c'};
		
		CSM_Util.checkCRUD_FLS(baseNamespace + 'REN_RS_Config__c', fieldNameList, CSM_Constants.DML_OPERATION_READ);
		
		if(!flowNames.isEmpty()){
			
			String queryString = 'Select ' + baseNamespace + 'REN_Invoking_Object__c, ' + baseNamespace + 'REN_Named_Credential__c, ' + baseNamespace + 'REN_Named_Credential_URL_Extension__c, ' + baseNamespace + 'REN_Field_Set_Name__c, ' + baseNamespace + 'REN_Flow_Name__c, ' + baseNamespace + 'REN_Columns__c, ' + baseNamespace + 'REN_Custom_Object__c, ' + baseNamespace + 'REN_Custom_Permission_Name__c, ' + baseNamespace + 'REN_Display_Dialog__c, '+ baseNamespace + 'REN_RS_Record_Limit__c, ' + baseNamespace + 'REN_SOQL__c from ' + baseNamespace + 'REN_RS_Config__c where ' + baseNamespace + 'REN_Flow_Name__c IN: flowNames ';
            
            List<sObject> configurationObjList = Database.query(queryString);
			
			if(!configurationObjList.isEmpty())
				return configurationObjList;
		}
		
		return null;
	}

	public static List<REN_RS_Config__c>getConfigByObjNFlow(Set<String> flowNameSet, Set<String> objNameSet, List<String> fieldsList){
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RS_CONFIGURATION, fieldsList, CSM_Constants.DML_OPERATION_READ); 
        String qryString = 'SELECT '+ String.join(fieldsList, ',') + ' FROM REN_RS_Config__c '+ 'WHERE REN_Flow_Name__c in :flowNameSet and REN_Invoking_Object__c in :objNameSet';
        System.debug('**qryString ' + qryString);
        return Database.query(qryString);
    }
	
	public static List<REN_RS_Field_Mapping__c> getFieldMapping(Set<String> configIdSet, List<string> requestedFields){
		CSM_Util.checkCRUD_FLS('REN_RS_Field_Mapping__c', requestedFields, CSM_Constants.DML_OPERATION_READ); 
        String soqlStr = 'SELECT '+String.join(requestedFields, ',')+ ' FROM REN_RS_Field_Mapping__c WHERE REN_RS_Config__c IN: configIdSet';        
        return Database.query(soqlStr);
	} 
    public static list<REN_RS_Config__c> getRSConfigration(List<String> requestedFields, List<string> whereCondition){
		CSM_Util.checkCRUD_FLS('REN_RS_Config__c', requestedFields, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = 'SELECT '+String.join(requestedFields, ',')+' FROM REN_RS_Config__c '+whereCondition[0];
        return Database.query(soqlStr);
    }   
}