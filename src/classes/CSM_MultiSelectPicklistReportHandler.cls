public with sharing class CSM_MultiSelectPicklistReportHandler {
	
    public static String getLookupFieldName(CSM_MSTR__c mstrObj){
    	String lookupFieldName = '';
    	//System.debug((mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY) + '\n---------lookupFieldName:' + mstrObj.CSM_Object_Name__c);
		//System.debug((mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_TASK) + '\n---------lookupFieldName:' + mstrObj.CSM_Object_Name__c);
		if(mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_TASK || mstrObj.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACTIVITY){
			System.debug('\n--------My name is-lookupFieldName:' + mstrObj.CSM_Object_Name__c);
			lookupFieldName = CSM_Constants.OBJ_TYPE_TASK;
		}else{
			Map<String, Schema.SObjectField> fieldInfoMap = Schema.getGlobalDescribe().get(CSM_Util.getNamespace() + 'CSM_MSTD__c').getDescribe().fields.getMap();
			
			for(String fieldName:fieldInfoMap.keySet()){
				Schema.SObjectField fieldObj = fieldInfoMap.get(fieldName);
				Schema.DisplayType fieldDataType = fieldObj.getDescribe().getType();
				String fieldLabel = fieldObj.getDescribe().getLabel();
				if(fieldDataType.equals(Schema.DisplayType.REFERENCE) && fieldLabel == mstrObj.CSM_Object_Name__c){
					lookupFieldName = fieldName;
					break;
				}
			}
		}
		return lookupFieldName;
    }

    public static List<CSM_MSTD__c> createDetailRecords(List<sObject> recordList, String lookupFieldName, Map<String, CSM_MSTR__c> mstrUniqueKeyValueMap, CSM_MSTR__c mstrObj){
    	List<CSM_MSTD__c> mstdList = new List<CSM_MSTD__c>();
    	List<RecordType> taskRecordTypeList = (lookupFieldName == CSM_Constants.OBJ_TYPE_TASK || lookupFieldName == CSM_Constants.OBJ_TYPE_ACTIVITY) ? CSM_TaskDataAccess.getRecordTypeTask() : new List<RecordType>();
    	Map<ID, RecordType> taskRecordTypeMap = new Map<ID, RecordType>(taskRecordTypeList);
    	
    	for(sObject obj: recordList){
    		String msFieldValue = (String)obj.get(mstrObj.CSM_Multi_Picklist_API_Name__c);
    		List<String> sList = msFieldValue.split(';');
    		
    		System.debug(JSON.serialize(obj) + '\n\n~~~~filteredObj: ' + sList);
    		for(String oneValue: sList){
    			if(String.isNotBlank(oneValue)){
		    		CSM_MSTD__c mstdObj = new CSM_MSTD__c( );
		    		if(lookupFieldName == CSM_Constants.OBJ_TYPE_TASK || lookupFieldName == CSM_Constants.OBJ_TYPE_ACTIVITY){
						setTaskValues(obj, mstdObj, mstrUniqueKeyValueMap, taskRecordTypeMap);
					}else{
		    			mstdObj.put(lookupFieldName, obj.id);
		    		}
		    		String uniqueMapKey = mstrObj.CSM_Object_Name__c + ':' + mstrObj.CSM_Multi_Picklist_API_Name__c + ':' + (oneValue.trim());
		    		System.debug(JSON.serialize(mstrUniqueKeyValueMap) + '\n\n~~~~uniqueMapKey: ' + uniqueMapKey);
					if(mstrUniqueKeyValueMap.containsKey(uniqueMapKey)){
						mstdObj.CSM_MSTR__c = mstrUniqueKeyValueMap.get(uniqueMapKey).id;
						mstdList.add(mstdObj);
					}
    			}
    		}
    	}
    	CSM_MultiSelectPicklistDataAccess.insertMstdRecords(mstdList);
    	return mstdList;
    }
    
    private static void setTaskValues(sObject obj, CSM_MSTD__c mstdObj, Map<String, CSM_MSTR__c> mstrUniqueKeyValueMap, Map<ID, RecordType> taskRecordTypeMap){
		if(CSM_AccessController.hasField(CSM_Constants.OBJ_TYPE_TASK, 'SSI_ZTH__ClosedDate__c')){
			Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
			setTaskSolutionExtensionValues(obj, objMap, mstdObj);
		}
		if(CSM_AccessController.hasField(CSM_Constants.OBJ_TYPE_TASK, 'RecordTypeId')){
			mstdObj.put('CSM_Task_Record_Type__c', taskRecordTypeMap.containsKey((ID)obj.get('RecordTypeId')) ? taskRecordTypeMap.get((ID)obj.get('RecordTypeId')).Name: null);
		}
		String assignToId = null;
		system.debug(obj + '~~~~OwnerId: ' + obj.getSobject('Owner'));
		if(obj.get('OwnerId') != null){
			assignToId = (String)obj.get('OwnerId') + ': ' + (String) (obj.getSobject('Owner') != null ? obj.getSobject('Owner').get('Name') : '');
			mstdObj.put('CSM_Task_Assigned_To_ID__c', assignToId);
		}
		if(obj.get('id') != null){
			assignToId = (String)obj.get('id') + ': ' + (String) obj.get('Subject');
			mstdObj.put('CSM_Task_ID__c', assignToId);
		}
		if(obj.get('WhatId') != null){
			assignToId = (String)obj.get('WhatId') + ': ' + (String)obj.getSobject('What').get('Name');
			mstdObj.put('CSM_Task_Related_To_What_ID__c', assignToId);
		}
		if(obj.get('WhoId') != null){
			assignToId = (String)obj.get('WhoId') + ': ' + (String)obj.getSobject('Who').get('Name');
			mstdObj.put('CSM_Task_Related_To_Who_ID__c', assignToId);
		}
		mstdObj.put('CSM_Task_Created_On__c', obj.get('CreatedDate'));
		mstdObj.put('CSM_Task_State__c', obj.get('CSM_Task_State__c'));
		mstdObj.put('CSM_Task_Status__c', obj.get('Status'));
		mstdObj.put('CSM_Task_SuccessPlan_Play__c', obj.get('CSM_SuccessPlan_Play__c'));
		mstdObj.put('CSM_Task_Due_Date__c', obj.get('ActivityDate'));
    }

    @TestVisible
    private static void setTaskSolutionExtensionValues(sObject sObj, Map<String,Object> obj, CSM_MSTD__c mstdObj){
    	if(CSM_AccessController.hasField(CSM_Constants.OBJ_TYPE_TASK, 'SSI_ZTH__ClosedDate__c')){
			mstdObj.put('CSM_Task_ClosedDate__c', sObj.get('SSI_ZTH__ClosedDate__c'));
    	}
		mstdObj.put('CSM_Task_Multi_Select_1__c', obj.get('SSI_ZTH__Task_Multi_Select_1__c'));
		mstdObj.put('CSM_Task_Multi_Select_2__c', obj.get('SSI_ZTH__Task_Multi_Select_2__c'));
		mstdObj.put('CSM_Task_Multi_Select_3__c', obj.get('SSI_ZTH__Task_Multi_Select_3__c'));
		mstdObj.put('CSM_Task_Multi_Select_4__c', obj.get('SSI_ZTH__Task_Multi_Select_4__c'));
		mstdObj.put('CSM_Task_Number_1__c', obj.get('SSI_ZTH__Task_Number_1__c'));
		mstdObj.put('CSM_Task_Number_2__c', obj.get('SSI_ZTH__Task_Number_2__c'));
		mstdObj.put('CSM_Task_Number_3__c', obj.get('SSI_ZTH__Task_Number_3__c'));
		mstdObj.put('CSM_Task_Number_4__c', obj.get('SSI_ZTH__Task_Number_4__c'));
		mstdObj.put('CSM_Task_Picklist_1__c', obj.get('SSI_ZTH__Task_Picklist_1__c'));
		mstdObj.put('CSM_Task_Picklist_2__c', obj.get('SSI_ZTH__Task_Picklist_2__c'));
		mstdObj.put('CSM_Task_Picklist_3__c', obj.get('SSI_ZTH__Task_Picklist_3__c'));
		mstdObj.put('CSM_Task_Picklist_4__c', obj.get('SSI_ZTH__Task_Picklist_4__c'));
		mstdObj.put('CSM_Task_Picklist_5__c', obj.get('SSI_ZTH__Task_Picklist_5__c'));
		mstdObj.put('CSM_Task_Picklist_6__c', obj.get('SSI_ZTH__Task_Picklist_6__c'));
		mstdObj.put('CSM_Task_Checkbox_1__c', obj.get('SSI_ZTH__Task_Checkbox_1__c'));
		mstdObj.put('CSM_Task_Text_1__c', obj.get('SSI_ZTH__Task_Text_1__c'));
		mstdObj.put('CSM_Task_URL_1__c', obj.get('SSI_ZTH__Task_URL_1__c'));
	}

	public static void sendConfirmedEmail(CSM_MSTR__c mstrObj){
		ID templateID = REN_Util.getEmailTemplateId('Multi-select Picklist Report Status Notification');
		Set<Id> userInfoId = new Set<Id>();
		userInfoId.add(Id.valueOf(userinfo.getuserid()));
		REN_Util.sendEmailNotificationUsingTemplate(userInfoId, templateID + '', mstrObj.id);
	}
	
	public static void mstrRefreshByBatch(String objName, String mstFieldApiName){
		CSM_MSTR__c mstrObj = new CSM_MSTR__c();
		mstrObj.CSM_Object_Name__c = objName;
		mstrObj.CSM_Multi_Picklist_API_Name__c = mstFieldApiName;
		CSM_MstdDeleteBatch refreshBatch = new CSM_MstdDeleteBatch();
		refreshBatch.mstrObj = mstrObj;
		String batchprocessid = Database.executeBatch(refreshBatch);
	}   
}