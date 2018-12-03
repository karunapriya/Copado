/**
 * Created Date		: Nov 13, 2018
 * Developed By		: admin, Comity Designs, Inc.
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
 * admin					User Story				Nov 13, 2018			1.1					@description
 *
 */
public with sharing class REN_ConfigSettings {

    public Map<String, SObject> configSettingMap {get; private set;}
    public sObject configSettingObj {get; set;}
    public String flowName {get; set;}
    public Integer recordLimit {get; private set;}
    public String selectedParentObject {get; set;}
    public String selectedChildObject {get; set;}
    public String selectedRelatedObject {get; set;}
    public String objApiName {get; set;}
    public String filterableFieldSet {get; set;}
    public Boolean isRSReq {get; private set;}
    public Boolean noSearch {get; set;}
    public transient List<sObject> relatedObjectRecordList;
    public String requiredFieldName;
    public String isLimitError {get;set;}
    public Boolean isNotLBError {get;set;}
    public String uniqueName {get;set;} //Added for US3928 : Support for picklist values and multi-select picklist values.
    public List<sObject> recordList{get;set;}
    public List<REN_RS_Field_Mapping__c> fieldMappingList {get;set;}
    public String parentChildRelationShipField {get;set;} // Added for US3980 :  Grandparent fields in custom search
    public Map<String, String> gParentRelationShipFieldSetMap {get;set;} // Added for US3980 :  Grandparent fields in custom search
    
       
    public void initializeConfigSettings(String baseNamespace, List<String> flowNames){
        List<sObject> configSettingList = REN_RSConfigurationDataAccess.getConfigSettings(flowNames);
        configSettingMap = new Map<String, SObject>();
        if(configSettingList != null && !configSettingList.isEmpty()){
            for(SObject configObj : configSettingList) {
                configSettingMap.put((String)configObj.get(baseNamespace+'REN_Flow_Name__c'), configObj);
            }
            setFlowName();
        }
    }
    
    public void initializeConfigSettings(String selectedParentObject, String objApiName, String filterableFieldSet, Boolean isRSReq, String flowName){
        this.objApiName = objApiName;
        this.filterableFieldSet = filterableFieldSet;
        this.isRSReq = isRSReq;
        this.flowName = flowName;
        this.selectedParentObject = selectedParentObject;
    }
    
    public void setFlowName(){
        if (flowName != null){
            if(configSettingMap.containsKey(flowName)){
                configSettingObj = configSettingMap.get(flowName);
            }
        }
    }

    public Integer getRecordLimit(){

        if (flowName == 'IB Export'){
            return (Integer)CSM_Admin__c.getInstance().REN_IB_Export_Records_Limit__c;
        }else if(flowName == 'External Account Search'){
        	return (Integer.valueOf(configSettingObj.get(CSM_Util.getNamespace() + 'REN_RS_Record_Limit__c')));
        }
		return 0;        
    }
    
}