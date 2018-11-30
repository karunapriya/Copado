/**
 * Created Date		: April 26, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dilip					US3340					April 26, 2018	1.1			 		Added in sprint 757
**/

public with sharing class REN_IBExportBusinessLayer extends CSM_BusinessLayer {
    
    private String objectName;
	private String fieldSetName;    
    private String responseStr;
    private Map<String,Schema.FieldSetMember> fieldNameToFieldMap;
    private Integer recordLimit;
    
    public REN_IBExportBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        if(inputWrapper.params.objectName!=null){
         	objectName = inputWrapper.params.objectName;
        }
        if(inputWrapper.params.fieldSetName!=null){
         	fieldSetName = inputWrapper.params.fieldSetName;
        }
        if(inputWrapper.params.responseStr!=null){
            responseStr = inputWrapper.params.responseStr;
        }
        if(inputWrapper.params.recordLimit!=null){
            recordLimit = inputWrapper.params.recordLimit;
        }
        
        fieldNameToFieldMap = new Map<String,Schema.FieldSetMember>();
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getCommonSearchWrapper();
    }
    
    private CSM_GridResponseWrapper getCommonSearchWrapper(){
        CSM_GridResponseWrapper gridResponseWrapper = new CSM_GridResponseWrapper();
        gridResponseWrapper.headerMap = setGridHeader();
        gridResponseWrapper.header = gridResponseWrapper.headerMap.values();
        gridResponseWrapper.hasAction = false;
        gridResponseWrapper.hasDetail = false;
        gridResponseWrapper.hasCheckbox = (inputWrapper.viewName == 'searchAndAdd') ? true : false;
        gridResponseWrapper.row = setResultGrid(responseStr, gridResponseWrapper.headerMap);
        if(gridResponseWrapper.row.size() >= recordLimit && inputWrapper.viewName != 'searchAndAdd') {
            gridResponseWrapper.errorMessage = Label.REN_PARTIAL_RESULTSET;
        }
        return gridResponseWrapper;
    }
    
	private List<CSM_GridRowWrapper> setResultGrid(String resp, Map<String, CSM_GridColumnWrapper> colMap){
    
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        //String str = '{"@odata.context":"http://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/$metadata#app_coveredassets(Data_Prot_End_Fiscal_Quarter,Advisory_Sku,Id)","value":[{"Id":"54d1c0f9e4b0ff5e2a14c428","Data_Prot_End_Fiscal_Quarter":"Test1","Advisory_Sku":"Test1"},{"Id":"54d1c0aee4b09726c27445c4","Data_Prot_End_Fiscal_Quarter":"Test2","Advisory_Sku":"Test2"},{"Id":"54d1c0aee4b09726c27445cc","Data_Prot_End_Fiscal_Quarter":"FY16Q2","Advisory_Sku":"Test3"},{"Id":"54d1c0aee4b09726c27445d1","Data_Prot_End_Fiscal_Quarter":"Test4","Advisory_Sku":"Test4"},{"Id":"54d1c0aee4b09726c27445d8","Data_Prot_End_Fiscal_Quarter":"Test5","Advisory_Sku":"Test5"},{"Id":"54d1c0aee4b09726c27445e6","Data_Prot_End_Fiscal_Quarter":"Test6","Advisory_Sku":"Test6"},{"Id":"54d1c0aee4b09726c27445f9","Data_Prot_End_Fiscal_Quarter":"Test7","Advisory_Sku":"Test7"},{"Id":"54d1c0aee4b0ff5e2a14a3a9","Data_Prot_End_Fiscal_Quarter":"Test8","Advisory_Sku":"Test8"},{"Id":"54d1c0aee4b0ff5e2a14a3b5","Data_Prot_End_Fiscal_Quarter":"Test9","Advisory_Sku":"Test9"},{"Id":"54d1c0aee4b0ff5e2a14a3c1","Data_Prot_End_Fiscal_Quarter":"Test10","Advisory_Sku":"Test10"}]}';
        
        if(Schema.getGlobalDescribe().containsKey(objectName) && resp != null){
            
            // Parse JSON response to get result grid field values.
            JSONParser parser = JSON.createParser(resp);
            CSM_GridRowWrapper row = new CSM_GridRowWrapper();
            sObject appCovAsset = Schema.getGlobalDescribe().get(objectName).newSObject();
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            boolean singleRecordFlag = false;
            
            while (parser.nextToken() != null && !fieldNameToFieldMap.isEmpty()) {
                Boolean newRecordflag = false;
                if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                    
                    while (parser.nextToken() != null) {
                        
                        if(parser.getCurrentToken() == JSONToken.START_OBJECT && newRecordflag == true  && singleRecordFlag == true){
                            row.sObj = appCovAsset;
                            row.isMC = CSM_Util.checkMCEnabled();
                            row.columns = new List<CSM_GridColumnWrapper>();
                            row.namespace = CSM_Util.getNamespace();
                            appCovAsset = Schema.getGlobalDescribe().get(objectName).newSObject();
                    
                            if (colMap!=null){
                               row.columns = colMap.values();
                               gridRowWrapper.add(row); 
                            }
                            row = new CSM_GridRowWrapper();
                        }
                        
                        Schema.SObjectField fieldName = null;
                        
                        if(fieldNameToFieldMap.containsKey(parser.getText() + '__c') && fieldMap.containsKey(parser.getText() + '__c')){
                            fieldName = fieldMap.get(parser.getText() + '__c');
                            System.debug('parser.getText() - '+parser.getText());
                            System.debug('colMap- '+colMap);
                            System.debug('colMap- '+colMap.containsKey(parser.getText() + '__c'));
                            if (colMap.containsKey(parser.getText() + '__c')){
                                if (parser.getText().equalsIgnoreCase('null') == false){
                                	singleRecordFlag = true;
                                    if (colMap.get(parser.getText() + '__c').dataType == 'string'){
			                            parser.nextToken();
                                        appCovAsset.put(fieldName, (parser.getText().equalsIgnoreCase('null') ? '' : parser.getText()));
                                    }else if(colMap.get(parser.getText() + '__c').dataType == 'DATETIME' || colMap.get(parser.getText() + '__c').dataType == 'DATE'){
                                        parser.nextToken();
                                        appCovAsset.put(fieldName, (parser.getText().equalsIgnoreCase('null') ? null : Date.valueOf(parser.getText())));
                                    } 
                                }
                            }
                             
                        } else if(fieldNameToFieldMap.containsKey(parser.getText()) && fieldMap.containsKey(parser.getText())){
                            fieldName = fieldMap.get(parser.getText());
                            parser.nextToken();
                            appCovAsset.put(fieldName, (parser.getText().equalsIgnoreCase('null') ? '' : parser.getText()));
                            singleRecordFlag = true;
                        } 
                        newRecordflag = true;
                    }
                }
            }
            row.sObj = appCovAsset;
            row.isMC = CSM_Util.checkMCEnabled();
            row.columns = new List<CSM_GridColumnWrapper>();
            row.namespace = CSM_Util.getNamespace();
            
            if (colMap!=null && singleRecordFlag == true){
                row.columns = colMap.values();
                gridRowWrapper.add(row); 
            }
        }    
        return gridRowWrapper;
    }
    
    private Map<String, CSM_GridColumnWrapper> setGridHeader(){
        Map<String, CSM_GridColumnWrapper> gridColumnWrapperMap = new Map<String, CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
        Set<String> fieldSet = new Set<String>();
        String fldpath ='';
        String nameSpace = CSM_Util.getNamespace();
    	if(String.isNotBlank(fieldSetName)){
	        List<Schema.FieldSetMember> fieldSetMemberList = CHL_Util.getFieldSet(fieldSetName, ObjectName);
	        for(Schema.FieldSetMember fld :fieldSetMemberList){
	            fldpath = fld.getFieldPath();
				fieldSet.add(fldpath);
				gridColumnWrapper = new CSM_GridColumnWrapper();
				gridColumnWrapper.apiName = fldpath;
				gridColumnWrapper.label = fld.getLabel().replace('_',' ');
				gridColumnWrapper.valueCol = fldpath;
				gridColumnWrapper.dataType = ''+fld.getType();
				
                fieldNameToFieldMap.put(fldpath, fld);
                
	            if(fldpath.contains('Contact.Id')){
					gridColumnWrapper.valueCol = fldpath.replaceAll('Contact.Id', 'Contact.Name');
	            }
	            
				if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fldpath.contains('.')){
					if(fldpath.contains('REN_Contract_Line_Item__c')){
						gridColumnWrapper.valueCol = fldpath.replace('__c', '__r') +'.LineItemNumber';
					}else {
						gridColumnWrapper.valueCol = fldpath.removeEndIgnoreCase('Id').replace('__c', '__r') +'.Name';
					}
					gridColumnWrapper.lookUpIdCol = fldpath;				
				}else if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DATETIME) ){
					gridColumnWrapper.isDateCol = true;
	            }
	            if(fldpath.contains('CaseNumber')){
	            	gridColumnWrapper.lookUpIdCol = 'Id';
	            }
				
				gridColumnWrapper.isSortable = true;
				gridColumnWrapper.customColumnSorter = 'customColumnSorter';
				gridColumnWrapper.isCurrencyCol = false;
				if(fld.getType().equals(Schema.DisplayType.CURRENCY)){
					gridColumnWrapper.dataAlign = 'right';
					gridColumnWrapper.label = gridColumnWrapper.label + ' ('+UserInfo.getDefaultCurrency() +')';	    	
			     	gridColumnWrapper.isCurrencyCol = true;
				}
				if (fld.getType().equals(Schema.DisplayType.DOUBLE)
						 || fld.getType().equals(Schema.DisplayType.INTEGER)){			
	                gridColumnWrapper.dataAlign = 'right';
	            }
				
				gridColumnWrapper.isDateCol = fld.getType().equals(Schema.DisplayType.DATE)?true:false;
				gridColumnWrapperMap.put(gridColumnWrapper.apiName, gridColumnWrapper);
	    	}
		}
        return gridColumnWrapperMap;
    }
}