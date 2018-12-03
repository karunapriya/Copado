public with sharing class CSM_MultiSelectPicklistDataAccess {
	
	public static String getQueryForFindReports(CSM_MSTR__c mstrObj){
		List<String> fieldList = new List<String>{'CSM_Object_Name__c', 'CSM_Multi_Picklist_API_Name__c', 'CSM_Multi_Picklist_Name__c', 'CSM_Picklist_Value__c'};
		CSM_Util.checkCRUD_FLS('CSM_MSTR__c', fieldList, CSM_Constants.DML_OPERATION_READ);    

    	String queryStr = 'Select ' + String.join(fieldList, ', ') + ' FROM CSM_MSTR__c ';
    	if(mstrObj != null){
    		queryStr += ' WHERE CSM_Object_Name__c = \'' + mstrObj.CSM_Object_Name__c + '\' AND  CSM_Multi_Picklist_API_Name__c = \'' + mstrObj.CSM_Multi_Picklist_API_Name__c + '\'';
    	}
    	return queryStr;
    }
	
	public static String getQueryForFindDetailReportRecords(CSM_MSTR__c mstrObj){
		Set<String> fieldSet = new Set<String>{'Id', mstrObj.CSM_Multi_Picklist_API_Name__c};
		//System.debug((mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY) + '\nCSM_MultiSelectPicklistDataAccess---------lookupFieldName:' + mstrObj.CSM_Object_Name__c);
		
		if(mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_TASK || mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY){
			//System.debug('\nCSM_MultiSelectPicklistDataAccess--------Query for Task:' + mstrObj.CSM_Object_Name__c);
			fieldSet.addAll( new List<String>{'Subject', 'ActivityDate', 'CreatedDate', 'CSM_SuccessPlan_Play__c', 'CSM_Task_State__c', 'Status', 'WhatId', 'WhoId', 'OwnerId'});
			if(CSM_AccessController.hasField(CSM_Constants.OBJ_TYPE_TASK, 'SSI_ZTH__ClosedDate__c')){
				fieldSet.addAll( new List<String>{'SSI_ZTH__ClosedDate__c', 'SSI_ZTH__Task_Multi_Select_1__c', 'SSI_ZTH__Task_Multi_Select_2__c', 'SSI_ZTH__Task_Multi_Select_3__c', 'SSI_ZTH__Task_Multi_Select_4__c', 'SSI_ZTH__Task_Number_1__c', 'SSI_ZTH__Task_Number_2__c', 'SSI_ZTH__Task_Number_3__c', 'SSI_ZTH__Task_Number_4__c', 'SSI_ZTH__Task_Picklist_1__c', 'SSI_ZTH__Task_Picklist_2__c', 'SSI_ZTH__Task_Picklist_3__c', 'SSI_ZTH__Task_Picklist_4__c', 'SSI_ZTH__Task_Picklist_5__c', 'SSI_ZTH__Task_Picklist_6__c', 'SSI_ZTH__Task_Checkbox_1__c', 'SSI_ZTH__Task_Text_1__c', 'SSI_ZTH__Task_URL_1__c'});
			}
			if(CSM_AccessController.hasField(CSM_Constants.OBJ_TYPE_TASK, 'RecordTypeId')){
				fieldSet.add('RecordTypeId');
			}
		}
		List<String> fieldList = new List<String>(fieldSet);
		CSM_Util.checkCRUD_FLS(((mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY) ? 'Task' : mstrObj.CSM_Object_Name__c), fieldList, CSM_Constants.DML_OPERATION_READ);    
    	if(mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_TASK || mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY){
    		fieldList.add('What.Name');
    		fieldList.add('Owner.Name');
    		fieldList.add('Who.Name');
    	}
    	return 'Select ' + String.join(fieldList, ', ') + ' FROM ' + ((mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY) ? 'Task' : mstrObj.CSM_Object_Name__c) + ' WHERE ' + mstrObj.CSM_Multi_Picklist_API_Name__c + ' != null';
    }
    
    public static void insertMstdRecords(List<CSM_MSTD__c> mstdList){
    	CSM_Util.checkCRUD_FLS('CSM_MSTD__c', 
    		New List<String>{'CSM_Account__c', 'CSM_Case__c', 'CSM_Lead__c', 'CSM_Opportunity__c', 'CSM_Task_Assigned_To_ID__c', 'CSM_Task_ClosedDate__c', 'CSM_Task_Created_On__c', 'CSM_Task_Due_Date__c', 'CSM_Task_ID__c', 'CSM_Task_Multi_Select_1__c', 'CSM_Task_Multi_Select_2__c', 'CSM_Task_Multi_Select_3__c', 'CSM_Task_Multi_Select_4__c', 'CSM_Task_Number_1__c', 'CSM_Task_Number_2__c', 'CSM_Task_Number_3__c', 'CSM_Task_Number_4__c', 'CSM_Task_Picklist_1__c', 'CSM_Task_Picklist_2__c', 'CSM_Task_Picklist_3__c', 'CSM_Task_Picklist_4__c', 'CSM_Task_Picklist_5__c', 'CSM_Task_Picklist_6__c', 'CSM_Task_Checkbox_1__c', 'CSM_Task_Record_Type__c', 'CSM_Task_Related_To_What_ID__c', 'CSM_Task_Related_To_Who_ID__c', 'CSM_Task_State__c', 'CSM_Task_Status__c', 'CSM_Task_SuccessPlan_Play__c', 'CSM_Task_Text_1__c', 'CSM_Task_URL_1__c'},
    		CSM_Constants.DML_OPERATION_INSERT);
    	insert mstdList;
    }
    
    public static void deleteMstdRecords(List<CSM_MSTD__c> mstdList){
    	CSM_Util.checkCRUD_FLS('CSM_MSTD__c', New List<String>{'id'}, CSM_Constants.DML_OPERATION_DELETE);
    	delete mstdList;
    }
    
    public static void insertMstrRecords(List<CSM_MSTR__c> mstrList){
    	List<String> mstrFieldList = new List<String>{'CSM_Object_Name__c', 
    		'CSM_Multi_Picklist_Name__c', 'CSM_Multi_Picklist_API_Name__c',
    		'CSM_Picklist_Value__c'};
    	CSM_Util.checkCRUD_FLS('CSM_MSTR__c', mstrFieldList, CSM_Constants.DML_OPERATION_INSERT);
    	insert mstrList;
    }
    
    public static void deleteMstrRecords(List<CSM_MSTR__c> mstrList){
    	CSM_Util.checkCRUD_FLS('CSM_MSTR__c', null, CSM_Constants.DML_OPERATION_DELETE);
    	delete mstrList;
    }
    
    public static List<CSM_MSTR__c> getMstrRecordsByName(String multiPickListValue)
    {
    	List<String> mstrFieldList = new List<String>{'CSM_Object_Name__c', 
    		'CSM_Multi_Picklist_Name__c', 'CSM_Multi_Picklist_API_Name__c',
    		'CSM_Picklist_Value__c'};
        CSM_Util.checkCRUD_FLS('CSM_MSTR__c', mstrFieldList, CSM_Constants.DML_OPERATION_READ);
    	return [SELECT CSM_Object_Name__c, 
    	               CSM_Multi_Picklist_Name__c, 
    	               CSM_Multi_Picklist_API_Name__c, 
    	               CSM_Picklist_Value__c
    			  FROM CSM_MSTR__c 
    			 WHERE CSM_Multi_Picklist_API_Name__c = :multiPickListValue];
    }
    
}