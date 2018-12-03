/**
 * Created Date		: April 26, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: IB Report Business Layer class.
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

public with sharing class REN_IBReportBusinessLayer extends CSM_BusinessLayer {
    
    private List<String> parentIDList;
	private String objectName;
	private String fieldSetName;   
	private String responseStr; 
    private Map<String,Schema.FieldSetMember> fieldNameToFieldMap;
    
    public REN_IBReportBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        if(inputWrapper.params.IdSet!=null){
           parentIDList = inputWrapper.params.idSet;
        }
        if(inputWrapper.params.objectName!=null){
         	objectName = inputWrapper.params.objectName;
        }
        if(inputWrapper.params.fieldSetName!=null){
         	fieldSetName = inputWrapper.params.fieldSetName;
        }
        if(inputWrapper.params.responseStr!=null){
            responseStr = inputWrapper.params.responseStr;
        }
        
        fieldNameToFieldMap = new Map<String,Schema.FieldSetMember>();
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getCommonSearchWrapper();
    }
    
    private CSM_GridResponseWrapper getCommonSearchWrapper(){
        CSM_GridResponseWrapper gridResponseWrapper = new CSM_GridResponseWrapper();
        gridResponseWrapper.header = setGridHeader();
        gridResponseWrapper.hasAction = false;
        gridResponseWrapper.hasDetail = false;
        gridResponseWrapper.hasCheckbox = (objectName == 'Opportunity') ? true : false;
        gridResponseWrapper.row = setResultGrid(responseStr, gridResponseWrapper.header);
        return gridResponseWrapper;
    }
    
    private List<CSM_GridRowWrapper> setResultGrid(String resp, List<CSM_GridColumnWrapper> colList){
        
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        //String str = '{"@odata.context":"http://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/$metadata#app_coveredassets(Data_Prot_End_Fiscal_Quarter,Advisory_Sku,Id)","value":[{"Id":"54d1c0f9e4b0ff5e2a14c428","Data_Prot_End_Fiscal_Quarter":"Test1","Advisory_Sku":"Test1"},{"Id":"54d1c0aee4b09726c27445c4","Data_Prot_End_Fiscal_Quarter":"Test2","Advisory_Sku":"Test2"},{"Id":"54d1c0aee4b09726c27445cc","Data_Prot_End_Fiscal_Quarter":"FY16Q2","Advisory_Sku":"Test3"},{"Id":"54d1c0aee4b09726c27445d1","Data_Prot_End_Fiscal_Quarter":"Test4","Advisory_Sku":"Test4"},{"Id":"54d1c0aee4b09726c27445d8","Data_Prot_End_Fiscal_Quarter":"Test5","Advisory_Sku":"Test5"},{"Id":"54d1c0aee4b09726c27445e6","Data_Prot_End_Fiscal_Quarter":"Test6","Advisory_Sku":"Test6"},{"Id":"54d1c0aee4b09726c27445f9","Data_Prot_End_Fiscal_Quarter":"Test7","Advisory_Sku":"Test7"},{"Id":"54d1c0aee4b0ff5e2a14a3a9","Data_Prot_End_Fiscal_Quarter":"Test8","Advisory_Sku":"Test8"},{"Id":"54d1c0aee4b0ff5e2a14a3b5","Data_Prot_End_Fiscal_Quarter":"Test9","Advisory_Sku":"Test9"},{"Id":"54d1c0aee4b0ff5e2a14a3c1","Data_Prot_End_Fiscal_Quarter":"Test10","Advisory_Sku":"Test10"}]}';
 		
        if(Schema.getGlobalDescribe().containsKey(objectName)){
            // Parse JSON response to get all the totalPrice field values.
            JSONParser parser = JSON.createParser(resp);
            CSM_GridRowWrapper row = new CSM_GridRowWrapper();
            sObject appCovAsset = Schema.getGlobalDescribe().get(objectName).newSObject();
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            while (parser.nextToken() != null && !fieldNameToFieldMap.isEmpty()) {
                Boolean flag = false;
                if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                    
                    while (parser.nextToken() != null) {
                        
                        if(parser.getCurrentToken() == JSONToken.START_OBJECT && flag == true){
                            row.sObj = appCovAsset;
                            row.isMC = CSM_Util.checkMCEnabled();
                            row.columns = new List<CSM_GridColumnWrapper>();
                            row.namespace = CSM_Util.getNamespace();
                            appCovAsset = Schema.getGlobalDescribe().get(objectName).newSObject();
                    
                            if (colList!=null){
                               row.columns = colList;
                               gridRowWrapper.add(row); 
                            }
                            row = new CSM_GridRowWrapper();
                        }
                        
                        Schema.SObjectField fieldName = null;
                        
                        if(fieldNameToFieldMap.containsKey(parser.getText() + '__c') && fieldMap.containsKey(parser.getText() + '__c')){
                            fieldName = fieldMap.get(parser.getText() + '__c');
                            parser.nextToken();
                            appCovAsset.put(fieldName, parser.getText());
                             
                        } else if(fieldNameToFieldMap.containsKey(parser.getText()) && fieldMap.containsKey(parser.getText())){
                            fieldName = fieldMap.get(parser.getText());
                            parser.nextToken();
                            appCovAsset.put(fieldName, parser.getText());
                            
                        } 
                        flag = true;
                    }
                }
            }
            row.sObj = appCovAsset;
            row.isMC = CSM_Util.checkMCEnabled();
            row.columns = new List<CSM_GridColumnWrapper>();
            row.namespace = CSM_Util.getNamespace();
            
            if (colList!=null){
                row.columns = colList;
                gridRowWrapper.add(row); 
            }
        }    
        return gridRowWrapper;
    }
    
    private List<CSM_GridColumnWrapper> setGridHeader(){
        List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
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
				gridColumnWrapper.label = fld.getLabel();
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
				gridColumnWrapperList.add(gridColumnWrapper);
	    	}
		}else{
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName = 'Id';
            gridColumnWrapper.label = 'Id';
            gridColumnWrapper.valueCol = 'Id';
            gridColumnWrapper.lookUpIdCol = 'Id';
            gridColumnWrapper.isVisible = true;
            gridColumnWrapper.isSwitchable = false;
            gridColumnWrapper.isSortable = true;
            
            gridColumnWrapperList.add(gridColumnWrapper);   
         
	        if (CSM_AccessController.hasField(objectName, 'Name')){
	            gridColumnWrapper = new CSM_GridColumnWrapper();
	            gridColumnWrapper.apiName = 'Name';
	            gridColumnWrapper.label = 'Name';
	            gridColumnWrapper.valueCol = 'Name';
	            gridColumnWrapper.isDateCol = false;
	            gridColumnWrapper.isSortable = true;
	            gridColumnWrapper.isVisible = true;
	            gridColumnWrapper.dataType = 'STRING';
	            gridColumnWrapperList.add(gridColumnWrapper);
	         }
    	}
        return gridColumnWrapperList;
    }

}