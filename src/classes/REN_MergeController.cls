/**
 * Created Date		: Nov 22, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					User Story				Nov 22, 2018			1.1					@description
 *
 */
public with sharing class REN_MergeController {

    public List<REN_MergeOppFieldWrapper> readOnlyFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableFields{get;set;} 
    public Boolean hasRenewAccess {get; private set;}
    public String updateableFieldJSON{get;set;}
	public String selectedValuesJson{get;set;}
    public String objectName{get;set;}
    public List<SObject> recordList{get;set;}
    public REN_ConfigSettings configSettings;
    public String readFieldJSON;
    public String successMessage {get;set;}
    public String param {get;set;}
    
    
    public REN_MergeController() {
        try{
            successMessage = '';
            CSM_TriggerManager.disableAllTriggers();
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));  
            System.debug('**ex ' + ex.getStackTraceString());
        }
    }
    public void mergeAccounts(){
        try{
            system.debug('readFieldJSON----'+readFieldJSON);
            if(!String.isEmpty(readFieldJSON)){
                selectedValuesJson=selectedValuesJson.removeEnd('}');
                selectedValuesJson+=',';
                selectedValuesJson += this.readFieldJSON;
                selectedValuesJson=selectedValuesJson.removeEnd(',');
                selectedValuesJson += '}';   
            }
            selectedValuesJson=selectedValuesJson.replaceAll('\n|\r|\t', ' ');
            Map<String, Object> selectedValuesMap = (Map<String, Object>)JSON.deserializeUntyped(selectedValuesJson);
            sObject recordToUpdate = configSettings.recordList[1];
            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for(String fld:selectedValuesMap.keySet()){
                DescribeFieldResult dfr = fieldMap.get(fld).getDescribe();
                String value = (String)selectedValuesMap.get(fld);
                Schema.DisplayType fieldType = dfr.getType();
                if(fieldType.equals(Schema.DisplayType.Boolean)){
                    recordToUpdate.put(fld,Boolean.valueOf(value));
                }else if(fieldType.equals(Schema.DisplayType.Date)){
                    if(String.isBlank(value)){
                        recordToUpdate.put(fld, null);
                    }else{
                        recordToUpdate.put(fld, 
                        Date.valueOf(CSM_Util.formatDatetimeString(value, REN_CONSTANTS.DB_DATE_FORMAT)));
                    }
                }else if(fieldType.equals(Schema.DisplayType.Datetime)){
                    if(String.isBlank(value)){
                        recordToUpdate.put(fld, null);
                    }else{
                        recordToUpdate.put(fld, 
                        Datetime.valueOf(CSM_Util.formatDatetimeString(value, REN_CONSTANTS.DB_DATETIME_FORMAT)));
                    }
                }else if(fieldType.equals(Schema.DisplayType.Double)
                               || fieldType.equals(Schema.DisplayType.CURRENCY)
                               || fieldType.equals(Schema.DisplayType.Percent)){
                            recordToUpdate.put(fld, Double.valueOf(value==null || value==''?'0':value));
                        }else if(fieldType.equals(Schema.DisplayType.Integer)){
                            recordToUpdate.put(fld, Integer.valueOf(value==null || value==''?'0':value));
                        }else {
                            recordToUpdate.put(fld,value);	
                        }
            }
            List<sObject> updatedRecordList = REN_Util.updateSObjectRecords(new List<sObject>{recordToUpdate},(List<String>)JSON.deserialize(JSON.serialize(selectedValuesMap.keySet()), List<String>.class),objectName);
            if(updatedRecordList != null && !updatedRecordList.isEmpty()){
           		successMessage = String.format(Label.REN_LBL_MERGE_SUCCESS, new List<String>{(String)recordToUpdate.get('Name')});    
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));  
            System.debug('**ex ' + ex.getStackTraceString());
        }
    }
    
    public void setRecords(){
    	try{
            system.debug('param----'+param);
            configSettings = (REN_ConfigSettings)JSON.deserialize(param, REN_ConfigSettings.class);
            objectName = configSettings.objApiName;
            System.debug('configSettings - '+configSettings);
            hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled; 	
            String baseNamespace = CSM_Util.getNamespace();
            this.readFieldJSON = '';
            Map<String,String> readFieldValMap = new Map<String,String>();
            this.readOnlyFields = new List<REN_MergeOppFieldWrapper>();
            this.updateableFields = new List<REN_MergeOppFieldWrapper>();
            Set<String> FldstoQuery = new Set<String>();
            if(configSettings != null){
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                for(REN_RS_Field_Mapping__c fldMapObj : configSettings.fieldMappingList){
                    DescribeFieldResult dfr = fieldMap.get(fldMapObj.REN_Object_Field_Name__c).getDescribe();
                    REN_MergeOppFieldWrapper wrapper = new REN_MergeOppFieldWrapper(dfr.getLabel(), dfr.getName(),dfr.isNillable(),dfr.getType().name().toLowerCase(), dfr.getRelationshipName(), fldMapObj.REN_Object_Field_Name__c);
                    if(fldMapObj.REN_Editable__c){
                        updateableFields.add(wrapper);   
                    } else{
                        readOnlyFields.add(wrapper);
                        this.readFieldJSON+= '"' + wrapper.name + '":"' +configSettings.recordList[0].get(wrapper.name) + '",';
                    }  
                }
                this.updateableFieldJSON = JSON.serialize(this.updateableFields);
                recordList = configSettings.recordList;
            } 
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));  
            System.debug('**ex ' + ex.getStackTraceString());
        }
    }       
}