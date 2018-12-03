public class CSM_UpdateExistingFCHelper {
    private static final String namespace = 'ServiceSource1__';
    public static void updateExistingFC(){
		List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
		for(CSM_Focus_Category_View__c fcView : [Select Id, CSM_Object_Name__c, CSM_Columns__c, CSM_SOQL__c, CSM_Currency_Header__c, CSM_Criteria__c,
													(Select Id, CSM_Focus_Category_View__c, CSM_Object_Field_Name__c, CSM_Object_Name__c, 
													CSM_Object_Field_Type__c From CSMFocusCategoryView__r) 
													From CSM_Focus_Category_View__c LIMIT 5000]){
			if(fcView != null && String.isNotBlank(fcView.CSM_Object_Name__c)){
				if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Task')){
					// generate Task SOQL
					generateTaskSOQL(fcView, fcView.CSMFocusCategoryView__r);
				}
				else if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Case')){
					// generate Case SOQL
					generateCaseSOQL(fcView, fcView.CSMFocusCategoryView__r);
				}
				else if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Contract')){
					// generate Contract SOQL
					generateContractSOQL(fcView, fcView.CSMFocusCategoryView__r);
				}
				else {
					// generate Other objects SOQL
					generateOtherObjectSOQL(fcView, fcView.CSMFocusCategoryView__r);
				}
			}
			fcViewList.add(fcView);
		}
		if(!fcViewList.isEmpty()){
			update fcViewList;
		}
    }
    
    private static void generateTaskSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
    	String TASK_SOQL;
    	if(getRecordTypeExists(new Task())){
			TASK_SOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, format(ActivityDate), Subject, WhatId, What.Name, CSM_Play__c, format(CSM_Completed_Date__c), CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c,recordtype.name, IsClosed';
		}
		else{
			TASK_SOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, format(ActivityDate), Subject, WhatId, What.Name, CSM_Play__c, format(CSM_Completed_Date__c), CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c, IsClosed';	
		}
		Set<String> selectColumns = getTaskColumnList(fcvcList, TASK_SOQL);
		if(selectColumns == null){
			selectColumns = new Set<String>();
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		if(!selectColumns.isEmpty()){
			String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
			TASK_SOQL += ', ' + commaSeparatedColumns;
		}
		TASK_SOQL += ' FROM Task Where CSM_Play__c != NULL';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			TASK_SOQL += ' and (' + fcView.CSM_Criteria__c + ')';
		}
		system.debug('TASK_SOQL $$$$$$$ '+TASK_SOQL);
		fcView.CSM_SOQL__c = TASK_SOQL;
    }
    
    private static void generateCaseSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
		String soql = '';
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('CaseNumber')){
				selectColumns.add('CaseNumber');
			}
		}else{
			selectColumns = new Set<String>();
			selectColumns.add('CaseNumber');
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
		soql += 'Select Id, ' + commaSeparatedColumns;
		soql += ' FROM Case ';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			soql += fcView.CSM_Criteria__c;
		}
		system.debug('case soql $$$$$$$ '+soql);
		fcView.CSM_SOQL__c = soql;
    }
    
    private static void generateContractSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
		String soql = '';
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('ContractNumber')){
				selectColumns.add('ContractNumber');
			}
		}else{
			selectColumns = new Set<String>();
			selectColumns.add('ContractNumber');
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
		soql += 'Select Id, ' + commaSeparatedColumns;
		soql += ' FROM Contract ';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			soql += fcView.CSM_Criteria__c;
		}
		system.debug('Contract soql $$$$$$$ '+soql);
		fcView.CSM_SOQL__c = soql;
    }
    
    private static void addHeaderCurrencyField(Set<String> selectColumns, String headerField){
    	if(String.isNotBlank(headerField)){
	    	headerField = UserInfo.isMultiCurrencyOrganization()
	    					?'FORMAT(CONVERTCURRENCY('+headerField+'))'
	    					:'FORMAT('+headerField+')';
	    	if(!selectColumns.contains(headerField)){
		    	selectColumns.add(headerField);
	    	}
    	}
    }
    
    private static void generateOtherObjectSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
		String soql = '';
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('Name')){
				selectColumns.add('Name');
			}
		}else{
			selectColumns = new Set<String>();
			selectColumns.add('Name');
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
		soql += 'Select Id, ' + commaSeparatedColumns;
		soql += ' FROM ' + fcView.CSM_Object_Name__c + ' ';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			soql += fcView.CSM_Criteria__c;
		}
		system.debug(fcView.CSM_Object_Name__c + ' soql $$$$$$$ '+soql);
		fcView.CSM_SOQL__c = soql;
    }
    
    private static Set<String> getColumnList(List<CSM_Focus_Category_View_Column__c> fcvcList){
    	Set<String> selectColumns = new Set<String>();
    	if(fcvcList != null){
			for(CSM_Focus_Category_View_Column__c fcvc : fcvcList){
				if(fcvc != null && String.isNotBlank(fcvc.CSM_Object_Field_Type__c)){
					if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('REFERENCE')){
                        handleReferenceColumns(fcvc);
                        selectColumns.add(fcvc.CSM_Object_Field_Name__c);
                    }else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Currency')){
						if(UserInfo.isMultiCurrencyOrganization()){
							selectColumns.add('FORMAT(CONVERTCURRENCY('+fcvc.CSM_Object_Field_Name__c+'))');
						}else{
							selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
						}
					}else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Double')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Integer')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Percent')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Date')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Datetime')){
						selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
					}else{
						selectColumns.add(fcvc.CSM_Object_Field_Name__c);
					}
				}
			}
    	}
    	return selectColumns;
    }
    
    private static Set<String> getTaskColumnList(List<CSM_Focus_Category_View_Column__c> fcvcList, String taskSOQL){
    	Set<String> selectColumns = new Set<String>();
    	if(fcvcList != null){
			for(CSM_Focus_Category_View_Column__c fcvc : fcvcList){
				if(fcvc != null 
					&& String.isNotBlank(fcvc.CSM_Object_Field_Type__c)
					&& String.isNotBlank(fcvc.CSM_Object_Field_Name__c)
					&& !taskSOQL.contains(fcvc.CSM_Object_Field_Name__c)){
					if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('REFERENCE')){
						handleReferenceColumns(fcvc);
						selectColumns.add(fcvc.CSM_Object_Field_Name__c);
					} else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Currency')){
						if(UserInfo.isMultiCurrencyOrganization()){
							selectColumns.add('FORMAT(CONVERTCURRENCY('+fcvc.CSM_Object_Field_Name__c+'))');
						}else{
							selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
						}
					}else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Double')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Integer')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Percent')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Date')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Datetime')){
						selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
					}else{
						selectColumns.add(fcvc.CSM_Object_Field_Name__c);
					}
				}
			}
    	}
    	return selectColumns;
    }
    
    private static Boolean getRecordTypeExists(SObject sObj){
		Boolean recordTypeExists = false;
		//Schema.DescribeSObjectResult objectResult = Task.sObjectType.getDescribe();
 		Schema.DescribeSObjectResult objectResult = sObj.getSObjectType().getDescribe();		
		List<Schema.RecordTypeInfo> recordTypeList = objectResult.getRecordTypeInfos();
		for(Schema.RecordTypeInfo option :recordTypeList) {
			if(option.isDefaultRecordTypeMapping() && option.getName() != 'Master' && option.isAvailable()) {
				recordTypeExists = true;
				break;
			}
		}
		return recordTypeExists;		
	}
	
	private static String findNameForLookup(String focusCategoryViewColumn, Map<String, Schema.SObjectField> objFieldInfo){
		string refObjName = '';
		string refRelation = '';
		Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(focusCategoryViewColumn).getDescribe();
        List<Schema.sObjectType> refObjList = fieldDescription.getReferenceTo();
        refObjName = String.valueOf(refObjList[0]);	
        refRelation = fieldDescription.getRelationshipName();
        if(refObjName != 'Case' && refObjName!= 'Contract'){
        	refRelation = refRelation + '.Name';
        }else if(refObjName == 'Case'){
        	refRelation = refRelation + '.CaseNumber';
        }else if(refObjName == 'Contract'){
        	refRelation = refRelation + '.ContractNumber';
        }
        return refRelation;
	}
	
	private static void handleReferenceColumns(CSM_Focus_Category_View_Column__c fcvc){
		String refRelation = '';
		Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribe.get(fcvc.CSM_Object_Name__c);
        if(sObjType == null){
            sobjType = globalDescribe.get(nameSpace + fcvc.CSM_Object_Name__c);
        }
        if(sObjType != null){
            Map<String, Schema.SObjectField> objFieldInfo = sobjType.getDescribe().fields.getMap();
            String fieldName = '';
            if(String.isNotBlank(fcvc.CSM_Object_Field_Name__c) 
                && fcvc.CSM_Object_Field_Name__c.startsWith(nameSpace)){
                fieldName = fcvc.CSM_Object_Field_Name__c.removeStart(nameSpace);
            }else{
                fieldName = fcvc.CSM_Object_Field_Name__c;
            }
            refRelation = findNameForLookup(fieldName, objFieldInfo);
            fcvc.CSM_Object_Field_Name__c = refRelation;
        }
	}
}