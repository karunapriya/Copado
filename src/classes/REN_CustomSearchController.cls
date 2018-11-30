/**
 * Created Date		: Oct 9, 2018
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Mass Update : Custom Page to Search RS and Salesforce to perform mass actions
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US3854				Oct 9, 2018			1.1				Mass Update : Custom Page to Search RS and Salesforce to perform mass actions
 *
 */
public with sharing class REN_CustomSearchController extends REN_BaseMainController{
    
    public REN_BaseMainController baseMainController {get; set;}
	public String selectedParentObject{get; set;}
	public List<SelectOption> parentObjectOptions {get; set;}
	private Map<String, Set<String>> customSerachSetingsMap;
	private Map<String, String> customSerachfieldSetMap;
	private Map<String, string> customSearchParentMap;
	private Map<String, String> parentObjToFieldSetMap;
	public transient String parentIdCSV{get;set;}
	private String selectedRelatedObject{get; set;}
	public String selectedChildObject {get; set;}
	public List<SelectOption> relatedObjectOptions {get; set;}
	public Map<String, String> relatedObjectLookupFieldMap {get; set;}
	
    public String selectedObject {get;set;}
    public transient CSM_DataGridAttribute dataGridAttribute{get; set;} 
    public String fieldSetName {get; set;} 
    public String filterableFieldSetName {get; set;}
    public boolean showQueryBuilder {get;set;}
	public String displayMsg {get;set;}
	public String baseNamespace{get;set;}
	public transient String selectedrecords {get;set;}
	public Boolean hasMassTransferAccess {get;set;}
	public boolean hasMassUpdateFieldSet {get;set;}
	public Integer rsHighWaterMarkLimit {get;set;}
    public Integer rsRequestLimit {get;set;}
    public Integer filterCriteriaCount {get;set;}
    public Integer selectedRecordCount {get;set;}
    public Integer recordLimit {get;set;}
    public String filterCriteriaStr {get;set;}
    public String successMessage {get;set;}
    private Boolean isCountRequested;
    public Integer customSearchLimit {get;set;}
    public Boolean isCountResponseSuccess {get;set;}
    public Boolean isValidSelection {get; set;}
    public Boolean isRSConfig {get; set;}
    public Boolean isUpdateAllRecords {get;set;}
    public String jsonString {get;set;}
    List<REN_RS_Config__c> configSettingList;
    public Integer userSelectedCount {get;set;}
    public string responseStr{get;set;}
    
    public List<SelectOption> ownerOptionsList {get;set;}
    public String selectOwnerOption {get;set;}
    public Boolean caseObjSelected {get;set;}
    public boolean isQueueOptDisable {get;set;}
    public List<SelectOption> queueOptionsList {get;set;}
    public String selectedGroupId {get;set;}
    
	public List<CSM_Focus_Category_View__c> fcvList {get;set;}
	public CSM_Focus_Category_View__c fcView {get;set;}
    public transient String fcViewName {get;set;}
	public Boolean hasError{get;set;}
	private boolean hasSyncedPO;
	public boolean isSyncQuoteEnabledOnAnySelectedOpp{get; set;}
	public String selectedOpportunityIds{get; set;}
	private String syncQuoteEnabledOpportunities{get; set;}
	private String syncPOEnabledOpportunities{get; set;}
	public String syncQuoteEnabledMsg{get; set;}
    public String fcViewId {get; set;}
    private String urlParam{get; set;}
    
    public set<String> noSearchStrings{get;set;}
    public transient String noSearchResultString{get;set;}
    
    public transient Map<String, String> fetchedTranslationMap {get;set;}
    public transient boolean savedSearch {get;set;}
    public REN_ConfigSettings configSettings {get; set;}
    private List<REN_QueryBuilderWrapper.ColumnFilter> ownerFilterCriteria;
    public Boolean externalSelected {get;set;}
    private transient Map<String, String> externalObjectToFlowname;
    public transient Boolean isMergeRequired {get; set;}
    public transient String param{get;set;}
    public REN_CustomSearchController(){
        super();
        try{
            baseMainController = this;
        	fcView = new CSM_Focus_Category_View__c();
        	savedSearch = false;
        	initializeCustomSerachMap();
            baseNamespace = CSM_Util.getNamespace();
            configSettings = new REN_ConfigSettings();
        	populateParentObjectOptions();
            isCountResponseSuccess = false;
            
            filterCriteriaCount = 0;
            filterCriteriaStr = '';
        	showQueryBuilder = false;
            isCountRequested = false;
            isRSConfig = true;
            isValidSelection = false;
            isUpdateAllRecords = false;
            caseObjSelected = false;
            isQueueOptDisable = true;
            
            customSearchLimit = (Integer)CSM_Admin__c.getInstance().REN_Custom_Search_Records_Limit__c;
            String defaultObjName = ApexPages.currentPage().getParameters().get('objName');
            
            SS_LicenseCheck licenseCheck = SS_LicenseCheck.getInstance();
           	hasMassTransferAccess = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_Mass_Transfer_Opportunities);
           	hasMassUpdateFieldSet = false;
            if(String.isNotBlank(selectedParentObject)) {
            	selectedParentObject = (String.isBlank(defaultObjName) || !customSerachSetingsMap.containsKey(defaultObjName) ) ? CSM_CONSTANTS.OBJ_OPPORTUNITY : defaultObjName;
            	selectedObject = selectedParentObject;
            	String getCustomSearchKey = String.isNotBlank(selectedChildObject)? selectedParentObject + ':' + selectedChildObject : selectedParentObject + ':' + selectedParentObject;
				String fieldSetMapKey = String.isNotBlank(selectedChildObject)? selectedChildObject : selectedParentObject;
				fieldSetName = customSerachfieldSetMap.get(fieldSetMapKey);
	        	filterableFieldSetName = parentObjToFieldSetMap.get(getCustomSearchKey);
                showQueryBuilder = true;
                configSettings.initializeConfigSettings(selectedParentObject, fieldSetMapKey, filterableFieldSetName, false, 'Mass Update');
                
                system.debug('Inside Controller----------------');
                callOnParentObjectChange();
            }
            fcViewId = System.currentPageReference().getParameters().get('id');
            
           	fcvList = CSM_FocusCategoryViewDataAccess.getAllBulkUpdateFocusCategories();
           	fetchedTranslationMap = new Map<String,String>();
           	List<SObject> soList = (List<SObject>)(fcvList);
           	getTranslatedStringMap(soList, 'CSM_Focus_Category_View__c');
            setGridAttributes();
            getMassUpdateSetting();
            manageFilterOwnerOptions(selectedParentObject);
            queueOptionsList = new List<SelectOption>();
            
            List<QueueSObject> queueList = CSM_FocusCategoryViewDataAccess.getQueues();
            queueOptionsList.add(new SelectOption(Label.CSM_LBL_NONE,Label.CSM_LBL_NONE));
            for(QueueSObject queueRecord : queueList){
                queueOptionsList.add(new SelectOption(queueRecord.QueueId, queueRecord.Queue.Name));
            }
            configSettings.isLimitError = 'false';
            configSettings.isNotLBError = false;
        }catch(Exception excp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        
    }//End of constructor
    
    private void populateParentObjectOptions(){
		parentObjectOptions = new List<SelectOption>();
        System.debug('customSerachSetingsMap == ' + customSerachSetingsMap);
        List<String> flowNamesToInitialize = new List<String>();
        String flowName = '';
		for(String parentObject: customSerachSetingsMap.keySet()) {
            if(externalObjectToFlowname.containsKey(parentObject)){
            	Boolean externalToAdd = false;
            	flowName = externalObjectToFlowname.get(parentObject);
                System.debug('parentObject == ' + parentObject);
		        configSettings.flowName = flowName;
		        flowNamesToInitialize.add(flowName);
		    	configSettings.initializeConfigSettings(baseNamespace, flowNamesToInitialize);
		    	sObject configSettingObj = configSettings.configSettingMap.get(flowName);
			    if(configSettingObj != null){
			        String customPermission = (String)configSettingObj.get('REN_Custom_Permission_Name__c');
			        if(customPermission != null){
			            externalToAdd = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(customPermission);
			        }
			        if(externalToAdd || String.isBlank(customPermission)){
			        	parentObjectOptions.add(new SelectOption(parentObject, parentObject.split(':')[1]));
			        }
			    }
            }else if(!externalObjectToFlowname.containsKey(parentObject)){
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(parentObject);
                if(objType == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, new String[] {parentObject}) ));
                }else{
                    parentObjectOptions.add(new SelectOption(parentObject, objType.getDescribe().getLabelPlural()));
                }
            }
		}
	}
	
	public void initializeCustomSerachMap(){
		
		Map<String, REN_Custom_Search_Config__c> customSearchObjMap = REN_Custom_Search_Config__c.getAll();
		system.debug('customSearchObjMap::'+customSearchObjMap);
		if(customSearchObjMap != null && !customSearchObjMap.isEmpty()){
			collectCustomSearchInfo(customSearchObjMap);
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.REN_LBL_CUSTOM_SETTING_ERROR_MSG));
		}
	}
    
    private void setGridAttributes(){                                
		dataGridAttribute = new CSM_DataGridAttribute();        
		dataGridAttribute.tableName = 'massUpdate';
		dataGridAttribute.objectType = 'massUpdate';
		dataGridAttribute.viewName = 'massUpdate';
		dataGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
		dataGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
		dataGridAttribute.showExport = CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
		gridInputParams.selectedFilterClause = '';
		gridInputParams.gridCurrency = null;
		//gridRecordLimit = (Integer)CSM_Admin__c.getInstance().REN_IB_Export_Records_Limit__c;
        dataGridAttribute.params = JSON.serialize(gridInputParams);
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		dataGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
	}
    
    public PageReference findFor(){
    	try{
    		
            configSettings.isNotLBError = false;
            isCountRequested = false;
            configSettings.noSearch=false;
           	REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
            System.debug('selectedParentObject =' + selectedParentObject);
            if(externalSelected){
                REN_Custom_Search_Config__c externalobjectCustomSearch = REN_Custom_Search_Config__c.getInstance(selectedParentObject.split(':')[1]);
                String flowName = externalobjectCustomSearch.REN_Flow_Name__c;
                sObject configSettingObj = configSettings.configSettingMap.get(flowName);
                configSettings.configSettingObj = configSettingObj;
                if(configSettingObj != null){
                    fieldSetName = (String)configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c');
                }
                responseStr = baseChildController.doSearch();
            }else{
                parentIdCSV = baseChildController.findFor(customSearchLimit, selectedChildObject, selectOwnerOption, selectedGroupId, ownerFilterCriteria);
            }
        }catch(Exception excp){
            configSettings.isNotLBError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference refreshMessages() {
        if(String.isNotBlank(displayMsg)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, displayMsg));
        }
        return null;
    }
    
    public void transferOpportunity(){}
    
    private void getMassUpdateSetting(){
        REN_Custom_Search_Config__c searchConfigObj = REN_Custom_Search_Config__c.getValues(selectedParentObject);
                
        if(searchConfigObj != null && searchConfigObj.REN_Mass_Update_FieldSet_Name__c != null){
            if(Schema.getGlobalDescribe().get(selectedParentObject).getDescribe().fieldSets.getMap().containsKey(searchConfigObj.REN_Mass_Update_FieldSet_Name__c)){
                hasMassUpdateFieldSet = true;
            }
            
            if(searchConfigObj.REN_RS_High_Watermark_Threshold__c != null){
                rsHighWaterMarkLimit = (Integer)searchConfigObj.REN_RS_High_Watermark_Threshold__c;
            }else{
                rsHighWaterMarkLimit = customSearchLimit;
            }
            
            if(searchConfigObj.REN_RS_Request_Limit_Threshold__c != null){
                rsRequestLimit = (Integer)searchConfigObj.REN_RS_Request_Limit_Threshold__c;
            }else{
                rsRequestLimit = customSearchLimit;
            }
        }
    }
    
    public void validateRecordCount(){
    	if(selectedRecordCount < rsRequestLimit) {
            isValidSelection = true;
    	} else if((selectedRecordCount > rsRequestLimit && selectedRecordCount <= rsHighWaterMarkLimit) && isRSConfig) {
            isValidSelection = true;
            
            if((selectedRecordCount <= customSearchLimit && isCountResponseSuccess) || (selectedRecordCount < customSearchLimit && !isCountResponseSuccess) ){
                isUpdateAllRecords = false;
            }else{
                isUpdateAllRecords = true;
            }
        } else if((selectedRecordCount > rsRequestLimit && selectedRecordCount < rsHighWaterMarkLimit) && !isRSConfig) {
            isValidSelection = false;
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, String.format(Label.REN_LBL_Config_Setting_Error, new List<String>{Label.REN_Mass_Update_Request_count})));
        } else if(selectedRecordCount > rsHighWaterMarkLimit) {
            isValidSelection = false;
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.REN_Mass_Update_RS_Threshold_Exceed_Error, new List<String>{''+rsHighWaterMarkLimit})));
    	}
    }
    
    public void manageFilterOwnerOptions(String selectedParentObject){
        ownerOptionsList = new List<SelectOption>();
        caseObjSelected = false;
        
        String objLabel = Schema.getGlobalDescribe().get(selectedParentObject).getDescribe().getLabelPlural();
        ownerOptionsList.add(new SelectOption('All', Label.CSM_LBL_ALL + ' ' + objLabel));
        ownerOptionsList.add(new SelectOption('My', Label.CSM_LBL_My + ' ' + objLabel));
        if(selectedParentObject == CSM_CONSTANTS.OBJ_OPPORTUNITY && CSM_AccessController.hasObject('OpportunityTeamMember')){
            ownerOptionsList.add(new SelectOption('Teams', Label.REN_LBL_All_Opp_Team));
        }else if(selectedParentObject == 'Case'){
        	caseObjSelected = true;
        	ownerOptionsList.add(new SelectOption('Teams', Label.REN_LBL_All_Case_Team));
        } 
        selectOwnerOption = 'My';
    }
    
    public void updateSelectionToNone(){
        selectOwnerOption = '';
        isQueueOptDisable = false;
    }
    
    public void disableQueueOpt(){
        isQueueOptDisable = true;
        selectedGroupId = Label.CSM_LBL_NONE;
    }
    
    public pageReference callOnParentObjectChange() {
		try{
			hasMassUpdateFieldSet = false;
			selectedRelatedObject = '';
			selectedChildObject = '';
            configSettings.isNotLBError = false;
            isQueueOptDisable = true;
            selectedGroupId = Label.CSM_LBL_NONE;
            selectedObject = selectedParentObject;
            fieldSetName = customSerachfieldSetMap.containsKey(selectedObject) ? customSerachfieldSetMap.get(selectedObject) : '';
            if(!selectedParentObject.contains(':')){
                externalSelected = false;
				populateRelatedObjectOptions(selectedParentObject);
				callOnRelatedObjectChange();
				manageFilterOwnerOptions(selectedParentObject);
			
				if(String.isNotBlank(selectedParentObject)){
                	getMassUpdateSetting();
            	}
            }else if(selectedParentObject.contains(':')){
                externalSelected = true;
                REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
                selectedObject = selectedParentObject.split(':')[0];
                String relatedObjFieldSetName = '';
                relatedObjFieldSetName = parentObjToFieldSetMap.get(selectedParentObject + ':' + selectedParentObject);
                fieldSetName = relatedObjFieldSetName;
                configSettings.objApiName=selectedObject;
                configSettings.filterableFieldSet = relatedObjFieldSetName;
                REN_Custom_Search_Config__c externalobjectCustomSearch = REN_Custom_Search_Config__c.getInstance(selectedParentObject.split(':')[1]);
                configSettings.flowName = externalobjectCustomSearch.REN_Flow_Name__c;
                if(baseChildController != null){
                    baseChildController.initializeQueryBuilderWrapper(String.isBlank(selectedRelatedObject) ? selectedObject : selectedRelatedObject, 
                                                                      configSettings.objApiName, configSettings.filterableFieldSet, false, relatedObjectLookupFieldMap);
                }
            }
		}catch(Exception e){
            configSettings.isNotLBError = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
		}
		return null;
	}
	
	public pageReference callOnRelatedObjectChange() {
		try{
            configSettings.isNotLBError = false;
			selectedRelatedObject = String.isBlank(selectedChildObject) ? '' : selectedChildObject.substringBefore('.');
			String relatedObjFieldSetName = '';
			
            REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
			if(String.isBlank(selectedRelatedObject)){
				relatedObjFieldSetName = parentObjToFieldSetMap.get(selectedObject + ':' + selectedObject);
                configSettings.objApiName=selectedObject;
                configSettings.filterableFieldSet = relatedObjFieldSetName;
			}else{
				relatedObjFieldSetName = parentObjToFieldSetMap.get(selectedObject + ':' + selectedRelatedObject);
                configSettings.objApiName=selectedRelatedObject;
                configSettings.filterableFieldSet = relatedObjFieldSetName;
			}
			if(baseChildController != null){
	            baseChildController.initializeQueryBuilderWrapper(String.isBlank(selectedRelatedObject) ? selectedObject : selectedRelatedObject, 
	            configSettings.objApiName, configSettings.filterableFieldSet, false, relatedObjectLookupFieldMap);
			}
			isQueueOptDisable = true;
            selectedGroupId = Label.CSM_LBL_NONE;
            selectOwnerOption = 'My';
            savedSearch = false;
		}catch(Exception e){
            configSettings.isNotLBError = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
		}
		return null;
	}
	
	private void populateRelatedObjectOptions(String parentObject){
		relatedObjectOptions = new List<SelectOption>();
		relatedObjectLookupFieldMap = new Map<String, String>();
		Schema.SObjectType parentObjType = Schema.getGlobalDescribe().get(parentObject);
		String defaultChildOption = parentObjType.getDescribe().getLabelPlural();
		relatedObjectOptions.add(new SelectOption('', defaultChildOption));

		Set<String> relatedObjectSet = customSerachSetingsMap.get(parentObject);
		if(relatedObjectSet == null){
			//add error
		}else{
			for(String s: relatedObjectSet){
				if(!s.contains('.')){
                    configSettings.isNotLBError = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {s})));//Invalid Child relationship
				}else{
					System.debug('\n\n~~~ Child Data: ' + s);
					String[] sArray = s.split('\\.');
					String childObjApiName = sArray[0];//??
					relatedObjectLookupFieldMap.put(childObjApiName, sArray[1]);
					Schema.SObjectType objType = Schema.getGlobalDescribe().get(childObjApiName);
					system.debug('objType::::'+objType);
					if(objType == null){
                        configSettings.isNotLBError = false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, new String[] {childObjApiName})));
					}else{
						Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
						Schema.SObjectType objectSchema = schemaMap.get(childObjApiName);
						Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
						if(!fieldMap.containsKey(sArray[1])){
                            configSettings.isNotLBError = false;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {s})));
						}else{
							Schema.DescribeFieldResult descField = fieldMap.get(sArray[1]).getDescribe();
							Schema.DisplayType fieldDataType = descField.getType();
							if(fieldDataType == Schema.DisplayType.Reference){
								
								List<Schema.SObjectType>  refObjType = descField.getReferenceTo();
								if( refObjType[0] != parentObjType){
                                    configSettings.isNotLBError = false;
									ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {s})));//'Invalid Child object relationship: ' + s + ' with parent Object ' + parentObject
								}else{
									relatedObjectOptions.add(new SelectOption(s, objType.getDescribe().getLabelPlural()));
								}
							}else{
                                configSettings.isNotLBError = false;
								ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, new String[] {childObjApiName})));
							}
						}
					}
				}
			}
		}
	}
	
	private void collectCustomSearchInfo(Map<String, REN_Custom_Search_Config__c> customSearchObjMap) {
		customSerachSetingsMap = new Map<String, Set<String>> ();
		customSerachfieldSetMap = new Map<String, String>();
        customSearchParentMap = new Map<String, String>();
        parentObjToFieldSetMap = new Map<String, String>();
        externalObjectToFlowname = new Map<String, String>();
		for(REN_Custom_Search_Config__c custSearchObj : customSearchObjMap.values()){
			system.debug('custSearchObj::'+custSearchObj);
			if(!customSerachSetingsMap.containsKey(custSearchObj.REN_Parent_Object__c) && String.isBlank(custSearchObj.REN_Flow_Name__c)){
				customSerachSetingsMap.put(custSearchObj.REN_Parent_Object__c, new Set<String>());
			}
			if(String.isNotBlank(custSearchObj.REN_Related_Object__c) && String.isBlank(custSearchObj.REN_Flow_Name__c)){
				customSerachSetingsMap.get(custSearchObj.REN_Parent_Object__c).add(custSearchObj.REN_Related_Object__c);
			}
			
			if(String.isNotBlank(custSearchObj.REN_Parent_Object__c) 
			&& String.isBlank(custSearchObj.REN_Related_Object__c)  && String.isBlank(custSearchObj.REN_Flow_Name__c)) {
				if(String.isNotBlank(custSearchObj.REN_Filterable_Field_Set_Name__c)) {
					parentObjToFieldSetMap.put(custSearchObj.REN_Parent_Object__c + ':' + custSearchObj.REN_Parent_Object__c, custSearchObj.REN_Filterable_Field_Set_Name__c);
				}
			} 
			if(String.isNotBlank(custSearchObj.REN_Parent_Object__c) 
			&& String.isNotBlank(custSearchObj.REN_Related_Object__c) && String.isBlank(custSearchObj.REN_Flow_Name__c)) {
				String[] splitString;
				if(custSearchObj.REN_Related_Object__c.contains('.')) {
					splitString = custSearchObj.REN_Related_Object__c.split('\\.');
				}
				if(String.isNotBlank(custSearchObj.REN_Filterable_Field_Set_Name__c)) {
					parentObjToFieldSetMap.put(custSearchObj.REN_Parent_Object__c+ ':'+ splitString[0], custSearchObj.REN_Filterable_Field_Set_Name__c);
				}
			}
			if(String.isBlank(selectedParentObject) && String.isBlank(custSearchObj.REN_Flow_Name__c)) {
				selectedParentObject = custSearchObj.REN_Parent_Object__c;
				system.debug('selectedParentObject::'+selectedParentObject);
			}
            //Defined grandparent relation in parent objects
            if(String.isBlank(custSearchObj.REN_Related_Object__c) && String.isNotBlank(custSearchObj.REN_Grandparent_Relation__c) && String.isBlank(custSearchObj.REN_Flow_Name__c)){
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(custSearchObj.REN_Parent_Object__c).getDescribe().fields.getMap().get(custSearchObj.REN_Grandparent_Relation__c).getDescribe();
                if(fieldResult.getReferenceTo().isEmpty()){
                    configSettings.isNotLBError = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {custSearchObj.REN_Grandparent_Relation__c})));
                }else{
					customSearchParentMap.put(custSearchObj.REN_Parent_Object__c,custSearchObj.REN_Grandparent_Relation__c);
                }
            }
            if(String.isBlank(custSearchObj.REN_Flow_Name__c)){
                customSerachfieldSetMap.put(String.isNotBlank(custSearchObj.REN_Related_Object__c) ? custSearchObj.REN_Related_Object__c : custSearchObj.REN_Parent_Object__c, custSearchObj.REN_Field_Set_API_Name__c);
            }else if(String.isNotBlank(custSearchObj.REN_Flow_Name__c)){
                String externalObject = custSearchObj.REN_Parent_Object__c + ':' + custSearchObj.Name;
                parentObjToFieldSetMap.put(externalObject + ':' + externalObject, custSearchObj.REN_Filterable_Field_Set_Name__c);
                customSerachSetingsMap.put(custSearchObj.REN_Parent_Object__c + ':' + custSearchObj.Name, new Set<String>{custSearchObj.REN_Parent_Object__c});
                externalObjectToFlowname.put(externalObject,custSearchObj.REN_Flow_Name__c);
                //customSerachfieldSetMap.put(String.isNotBlank(custSearchObj.REN_Related_Object__c) ? custSearchObj.REN_Related_Object__c : custSearchObj.REN_Parent_Object__c, custSearchObj.REN_Field_Set_API_Name__c);
            }
			
		}
	}
    
    public void showSelectedRecInfoMsg(){
        configSettings.isNotLBError = true;
        
        if(selectedRecordCount != 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+selectedRecordCount})));
        }
        
    }
    
    public void showRSThresholdExceedError(){
        configSettings.isNotLBError = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.REN_Mass_Update_RS_Threshold_Exceed_Error, new List<String>{''+rsHighWaterMarkLimit})));
    }
    
    public void displayTransferResult(){
        configSettings.isNotLBError = true;		
        if(successMessage == null || String.isBlank(successMessage)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.LBL_Mass_Update_Success_Message));
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, successMessage));
        }
        
    }
    
    public void sendCountRequest(){
        try {
        	REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
        if(!isCountRequested){
            isCountRequested = true;
            configSettingList = REN_RSConfigurationDataAccess.getConfigByObjNFlow(new Set<String>{Label.REN_Mass_Update_Request_count}, new Set<String>{selectedParentObject}, new List<String>{'REN_Named_Credential__c','REN_Named_Credential_URL_Extension__c','REN_RS_Request_Timeout_Limit__c'});
            
            //Please don't change the if else order.
            if(configSettingList != null && !configSettingList.isEmpty() && hasMassTransferAccess){
                REN_RSIntegrationUtil.REN_RSIntegrationWrapper countWrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
                countWrapper.namedCredential = configSettingList[0].REN_Named_Credential__c;
                countWrapper.namedCredentialExtn = configSettingList[0].REN_Named_Credential_URL_Extension__c;
                countWrapper.timeout = (configSettingList[0].REN_RS_Request_Timeout_Limit__c != null ? (Integer)configSettingList[0].REN_RS_Request_Timeout_Limit__c : null);
                String fieldSetMapKey = String.isNotBlank(selectedChildObject)? selectedChildObject : selectedParentObject;
                
                String ownerFilterCriteriaStr = '';
                if(ownerFilterCriteria != null && !ownerFilterCriteria.isEmpty()){
                	ownerFilterCriteriaStr = REN_IBExportODataController.formODataQueryInJson(ownerFilterCriteria,baseChildController.inputWrapper.filterLogic, True, '');
                }
                
                String jsonFilterCriteria = REN_IBExportODataController.formODataQueryInJson(baseChildController.inputWrapper.columnFilterList,baseChildController.inputWrapper.filterLogic, True, fieldSetMapKey);
                if(String.isNotBlank(jsonFilterCriteria)) {
                	jsonFilterCriteria = String.isNotBlank(ownerFilterCriteriaStr) ? '(' + jsonFilterCriteria + ') and ' + ownerFilterCriteriaStr : jsonFilterCriteria;
                } else {
                	jsonFilterCriteria = ownerFilterCriteriaStr;
                }
                
                jsonString = jsonFilterCriteria;
                countWrapper.jsonData = '{"filter":"'+jsonFilterCriteria+'"}';
                //DE3431 - Closed sale Opportunity owner should not be updated.
                filterCriteriaStr = String.isNotBlank(jsonFilterCriteria)? '{"filter":"'+jsonFilterCriteria+' and StageName ne \'Closed Sale\'"}' : '{"filter":"StageName ne \'Closed Sale\'"}';//countWrapper.jsonData;
                countWrapper.action = 'POST';
                countWrapper.auditTag = REN_RSIntegrationUtil.constructUniqueString();
                System.debug('**Req ' + countWrapper);
                REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
                HttpResponse resp = callout.postHttpRequest(countWrapper);
                configSettings.isNotLBError = true;
                configSettings.isLimitError = 'True';
                
                //This block to handle real time bulk update mode
               if(resp != null && resp.getStatusCode() == 400){
               		filterCriteriaCount = rsHighWaterMarkLimit;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+userSelectedCount})));
	            	String badRequestErrorCode = REN_Util.jsonStrParser(new List<String>{resp.getBody()},'code');
		            if(badRequestErrorCode == 'OD400'){
		            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, String.format(Label.REN_LBL_ERRORCODE_MSG, new List<String>{''+userSelectedCount})));
		            } else {
		            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.REN_Mass_Update_Request_Count_Error));
		            }
               }else if(resp == null || resp.getStatusCode() != 200){
                    filterCriteriaCount = rsHighWaterMarkLimit;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+userSelectedCount})));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.REN_Mass_Update_Request_Count_Error));
               }else{//This block shows actual filter criteria count
                    filterCriteriaCount = Integer.valueOf(REN_Util.jsonStrParser(new List<String>{resp.getBody()},'value'));
                    isCountResponseSuccess = true;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+filterCriteriaCount})));
                }
            }else if(hasMassTransferAccess == false){
                filterCriteriaCount = rsRequestLimit;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+userSelectedCount})));  
            }else if(configSettingList == null || configSettingList.isEmpty()){
                filterCriteriaCount = recordLimit;
                isRSConfig = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.REN_Mass_Update_RS_Config_Error));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+userSelectedCount})));
            }
        }else{
            if(configSettingList != null && !configSettingList.isEmpty() && isCountResponseSuccess){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+filterCriteriaCount})));
            }else if(configSettingList != null && !configSettingList.isEmpty() && !isCountResponseSuccess){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+userSelectedCount})));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.REN_Mass_Update_Request_Count_Error));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.REN_Mass_Update_RS_Config_Error));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(Label.REN_Mass_Update_Selected_Record_Count, new List<String>{''+userSelectedCount})));
            }
            
        }
        } catch (exception ex) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage())); 
        }
    }
	/***** Begin : US3859 Custom Search: Move Consolidate & Not Found Items to new mass update page *****/
    
    /**
	* @description :  This method is created to perform Consolidate request on Opportunity for Mass Update. Added as part of US3859.      
	*/	
	public PageReference consolidateOpportunity(){
		PageReference pageRef = null;
		system.debug('@@@@@@@@ consolidateOpportunity :: ' );
		this.hasError = false;
		configSettings.isNotLBError = false;		
		if(String.isNotBlank(this.selectedOpportunityIds)){
			Set<String> oppIdSet = REN_Util.convertCSVtoSet(this.selectedOpportunityIds, '-');
			Set<Id> opptyIdSet = (Set<Id>)JSON.deserialize(JSON.serialize(oppIdSet), Set<Id>.class);
			List<CHL_Partner_Opportunity__c> poList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunity (opptyIdSet);
			Map<Id, CHL_Partner_Opportunity__c> opptyToPOMap = new Map<Id, CHL_Partner_Opportunity__c>();
			if(poList != null && !poList.isEmpty()) {
				for(CHL_Partner_Opportunity__c poObj: poList) {
					opptyToPOMap.put(poObj.CHL_Opportunity__c, poObj);
				}
			}
	    	system.debug('@@@@@@@@@@@ validte Opp :: ' + validateSelectedOpportunities(oppIdSet, opptyToPOMap));
			if (validateSelectedOpportunities(oppIdSet, opptyToPOMap)) {
				if(isSyncQuoteEnabledOnAnySelectedOpp && String.isNotBlank(syncQuoteEnabledOpportunities)){
					syncQuoteEnabledOpportunities = syncQuoteEnabledOpportunities.removeEnd(', ');
					syncPOEnabledOpportunities = syncPOEnabledOpportunities.removeEnd(', ');
					syncQuoteEnabledMsg = String.format(Label.REN_MSG_OPP_HAS_QUOTE_ENABLED_CONS_ON_TARGET, new String[]{Label.REN_MSG_PO_HAS_SYNC_ENABLED_ON_SRC_CONS});
					syncQuoteEnabledMsg = hasSyncedPO == true && String.isNotBlank(syncPOEnabledOpportunities) ? syncQuoteEnabledMsg + ' <BR/>  <BR/>' + String.format(Label.CHL_MSG_PO_HAS_SYNC_ENABLED_CONS, new String[]{Label.REN_MSG_PO_HAS_SYNC_ENABLED_ON_SRC_CONS}) : syncQuoteEnabledMsg;
					urlParam = this.selectedOpportunityIds;
				} else if(!isSyncQuoteEnabledOnAnySelectedOpp && hasSyncedPO && String.isNotBlank(syncPOEnabledOpportunities)) {
					syncPOEnabledOpportunities = syncPOEnabledOpportunities.removeEnd(', ');
					syncQuoteEnabledMsg = String.format(Label.CHL_MSG_PO_HAS_SYNC_ENABLED_CONS, new String[]{Label.REN_MSG_PO_HAS_SYNC_ENABLED_ON_SRC_CONS});
					urlParam = this.selectedOpportunityIds;
				}
			} else {
				system.debug('@@@@@@@@@@@ has Error value ' + hasError);
				this.hasError = true;
				configSettings.isNotLBError = true;
			}
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.MSG_AT_LEAST_ONE, new String[]{Schema.SObjectType.Opportunity.label})));
		}
		return pageRef;
	}
	
	/**
	* @description: This method validate all the selected opportunities for Consolidate request based on different parameters i.e Pricebook, Currency and Record type mismatch, Record Types etc and Displayed message accordingly. 
					Added as part of US3859.      
	*/
	private boolean validateSelectedOpportunities(Set<String> oppIdSet, Map<Id, CHL_Partner_Opportunity__c> opptyToPOMap){
		isSyncQuoteEnabledOnAnySelectedOpp = false;
		syncQuoteEnabledOpportunities = '';
		syncPOEnabledOpportunities = '';
		syncQuoteEnabledMsg = '';
		Boolean isValid = true;
		hasSyncedPO = false;
		Boolean recordTypeExists = CSM_Util.getRecordTypeExists(new Opportunity());
		Set<String> knownFields = new Set<String>{'Name','Pricebook2Id', 'IsClosed','REN_Is_Consolidated__c','CHL_QuoteSyncStatus__c','REN_Renewal_Metrics_Status__c'};
		Set<String> stagesNotAllowed = new Set<String>();
		Set<String> recordTypes = new Set<String>();
		if (CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){ 	    
			knownFields.add('SyncedQuoteId');
		}
		SS_Validations__c ssValidationsGlobal = SS_Validations__c.getOrgDefaults();
		if (String.isNotBlank(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c)){
			knownFields.add('StageName');
			stagesNotAllowed = REN_Util.convertCSVtoSet(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c, ',');
		}
		if(UserInfo.isMultiCurrencyOrganization()){
			knownFields.add(REN_Constants.REN_CURRENCY_ISO_CODE);
		}

		if (recordTypeExists){
			knownFields.add('RecordTypeId');
		}
		Set<Id> idSet2 = new Set<Id>( (List<Id>)new List<String>( oppIdSet ) );
		Set<String> pricebookSet = new Set<String>();
		Set<String> currencySet = new Set<String>();

		List<sObject> sObjects = REN_OpportunityDataAccess.getFilteredRecordsList('Opportunity', knownFields, idSet2, null, null,null);
		for(sObject sObjectOpp: sObjects){
			if (recordTypeExists && recordTypes.isEmpty()){
				recordTypes.add((String)sObjectOpp.get('RecordTypeId'));
			}else if(recordTypeExists && !recordTypes.contains((String)sObjectOpp.get('RecordTypeId'))){
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.REN_LBL_OPP_RECTYPE_ERROR_MSG));
				break;
			}
			if (pricebookSet.isEmpty()){
				pricebookSet.add((String)sObjectOpp.get('Pricebook2Id'));
			}else if (!pricebookSet.contains((String)sObjectOpp.get('Pricebook2Id'))){
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_LBL_PB_ERROR_MSG));
				break;
			}
			if(UserInfo.isMultiCurrencyOrganization()){
				if (currencySet.isEmpty()){
					currencySet.add((String)sObjectOpp.get(REN_Constants.REN_CURRENCY_ISO_CODE));
				}else if (!currencySet.contains((String)sObjectOpp.get(REN_Constants.REN_CURRENCY_ISO_CODE))){
					isValid = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_LBL_CURRENCY_ERROR_MSG));
					break;
				}
			}
			if (sObjectOpp.get('IsClosed') != null && Boolean.valueOf(sObjectOpp.get('IsClosed'))){
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_MSG_CLOSED_OPP_CONS));
				break;
			}
			if ((CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId') && sObjectOpp.get('SyncedQuoteId') != null)){				
				isSyncQuoteEnabledOnAnySelectedOpp = true; //sObjectOpp.get('SyncedQuoteId') != null ? true : false;
				syncQuoteEnabledOpportunities = syncQuoteEnabledOpportunities + (String)sObjectOpp.get('Name') + ', '; //: syncQuoteEnabledOpportunities;
				
				system.debug('syncQuoteEnabledOpportunities : '+syncQuoteEnabledOpportunities );
			}
			if(opptyToPOMap != null && opptyToPOMap.ContainsKey((ID)sObjectOpp.get('Id'))) {
				hasSyncedPO = true;
				syncPOEnabledOpportunities = syncPOEnabledOpportunities + (String)sObjectOpp.get('Name') + ', '; // : syncPOEnabledOpportunities;
				system.debug( ' \n syncPOEnabledOpportunities '+syncPOEnabledOpportunities);
			}
			if (!stagesNotAllowed.isEmpty() && stagesNotAllowed.contains((String)sObjectOpp.get('StageName'))){
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_CONSOLIDATE, new String[] {(String)sObjectOpp.get('StageName')})));
				break;
			}
			if (sObjectOpp.get('REN_Is_Consolidated__c') != null & (Boolean)sObjectOpp.get('REN_Is_Consolidated__c')){
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.REN_LBL_CONSOIDATED_MSG, new String[] {(String)sObjectOpp.get('Name')})));
				break;
			}
			if ((sObjectOpp.get('CHL_QuoteSyncStatus__c') != null && sObjectOpp.get('CHL_QuoteSyncStatus__c') != 'None') 
				|| ((sObjectOpp.get('REN_Renewal_Metrics_Status__c') != null && sObjectOpp.get('REN_Renewal_Metrics_Status__c') != 'Calculated'))){
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.REN_PREVENT_CONSOLIDATE_IF_BATCHES_RUNNING));
				break;
			}
		}
		if(ApexPages.hasMessages()){
			isSyncQuoteEnabledOnAnySelectedOpp = false;
		}
		return isValid;
	}
	
	/**
	* @description: This method is used to redirect request to Consolidate page, If all the selected opportunities are valid. Added as part of US3859.      
	*/
	public PageReference redirectToConsolidate(){
		system.debug('@@@ test redirectToConsolidate');
		PageReference pageRef = Page.REN_ConsolidateOpportunity;
		pageRef.getParameters().put('opptyIds', this.selectedOpportunityIds);
		PageReference returnPageRef = Page.REN_CustomSearchPage;					
		String retURL = returnPageRef.getUrl();
		pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
		return pageRef;
	}
	
	/**
	* @description: This method cater 'No Result Found' functionality. Added as part of US3859.      
	*/
	public PageReference noResultFound(){
		try{
        	noSearchResultFound();
        }catch(Exception ex){
        	System.debug('stackTrace::'+ex.getStackTraceString());
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + ex.getMessage());
			ApexPages.addMessage(myMsg);
		}
        return null;
    }
    
    /**
	* @description: This method used to identify criteria having no records. Displayed as a String in 'No Result Found' Tab. 
					Added as part of US3859.      
	*/
    private void noSearchResultFound(){ 
    	REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
        //baseChildController.queryBuilder(queryBuilderInputWrapper);
        
    	//system.debug('#### queryBuilderInputWrapper1::'+queryBuilderInputWrapper);
    	noSearchResultString = '';
        
        List<String> searchStringsList = new List<String>();
        Set<String> filterStrSet = new Set<String>();
        Set<Object> filterOptionSet = new Set<Object>();
        Map<Object,String> filterOptionMap = new Map<Object,String>();
    	
    	List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterLst = baseChildController.inputWrapper.columnFilterList;
    	system.debug('####  columnFilterLst ::'+columnFilterLst);
        String fieldType = String.valueOf(columnFilterLst[0].fieldDataType);
        system.debug('####  fieldType ::'+fieldType);
        if(fieldType != 'BOOLEAN')  {      
	        String fieldValue='';
	        fieldValue = String.valueOf(String.valueOf(columnFilterLst[0].filterValue));
	        if(String.isBlank(fieldValue)){
	        	filterStrSet = new Set<String>();
	        }else{
	        	filterStrSet =  REN_QueryBuilderHelper.parseCsvString(fieldValue);
	        }        
	        if(!String.isBlank(fieldValue)){            
	            for(String strs:filterStrSet){
	                if(String.isNotBlank(strs)){
	                    if(fieldType == CSM_Constants.TYPE_DOUBLE 
	                            || fieldType == CSM_Constants.TYPE_CURRENCY 
	                            || fieldType == CSM_Constants.TYPE_PERCENT){
	                    
	                        filterOptionSet.add(Double.valueOf(strs.toLowerCase()));
	                        filterOptionMap.put(Double.valueOf(strs.toLowerCase()),strs);
	                    }else{
	                        filterOptionSet.add(String.Valueof(strs.toLowerCase()));
	                        filterOptionMap.put(String.valueOf(strs.toLowerCase()),strs);
	                    }
	                }
	            }       
	        }
	        system.debug('filterStrSet**'+filterStrSet);
	        if(filterStrSet != null && !filterStrSet.isEmpty()){
	        	string fieldNameToRetrive = '';
	            String operatorName = String.valueOf(columnFilterLst[0].operator);
	            if(operatorName==CSM_Constants.OPERATOR_EQUAL || operatorName==CSM_Constants.OPERATOR_LIKE || operatorName==CSM_Constants.OPERATOR_IN){
	            	String relatedFieldName = '';	
					if(String.isNotBlank(selectedRelatedObject)){
						relatedFieldName = relatedObjectLookupFieldMap.get(selectedRelatedObject);						
					}
	            	String fieldName = String.valueOf(columnFilterLst[0].fieldApiName);
	                fieldNameToRetrive = fieldName;
	                List<String> fieldNameList = fieldName.split('\\.');
	                
	                REN_SOQLWrapper wrapper = new REN_SOQLWrapper();
			        wrapper.fromObject = String.isNotBlank(selectedRelatedObject)? selectedRelatedObject : configSettings.selectedParentObject;
			        wrapper.knownFields = new Set<String>{fieldNameToRetrive};
			    	//wrapper.sFilter1 = baseChildController.inputWrapper.columnFilterList[0].filterStringValueSet;
					//wrapper.nFilter1 = baseChildController.inputWrapper.columnFilterList[0].filterNumberValueSet;
					wrapper.whereCondition = baseChildController.inputWrapper.filterCondition;
					Set<String> filterSet = REN_QueryBuilderHelper.parseCsvString(baseChildController.inputWrapper.columnFilterList[0].filterValue);
					Set<String> filterStringValueSet = filterSet;
					wrapper.sFilter1 = filterStringValueSet;
			    	wrapper.isFirstFilterSetRequired = false;
			   		wrapper.recordLimit = 20000;
			   		configSettings.relatedObjectRecordList = REN_OpportunityDataAccess.getObjectRecordsList(wrapper);
	                
	                set<Object> foundItemsSet = new set<Object>();
	                if(configSettings.relatedObjectRecordList!=Null){
	                    Object val = null;
	                    for(sObject sObj : configSettings.relatedObjectRecordList){
	                    	foundItemsSet.add(String.valueOf(sObj.get(fieldNameToRetrive)).toLowerCase());
	                    }
	                }
	                filterOptionSet.removeAll(foundItemsSet);           
	                for(Object s:filterOptionSet) {
	                	noSearchResultString +=   filterOptionMap.get(s) + '<br/>'  ;
	                }
	               
	            }
	        }
	        system.debug('####  noSearchResultString-> '+noSearchResultString);  
	        //DE3426:Added below code to Show 3 Criterias by Default for Not Found Items.
	       	if(baseChildController.inputWrapper.columnFilterList != null){
            	baseChildController.reInitialize();            		
            } 
	                   
        }
    }
    
    /***** End : US3859 Custom Search: Move Consolidate & Not Found Items to new mass update page *****/
    
	private void getTranslatedStringMap(List<sObject> sObjectList, String sObjectType){
    	fetchedTranslationMap = REN_RSLanguageSupportDataAccess.getMapOfTranslatedStrings(new Set<String>{UserInfo.getLanguage()}, new List<String>{'REN_Translated_Text__c', 'REN_English_Text__c', 'REN_Language_Code__c'});
    	if(sObjectType == 'CSM_Focus_Category_View__c'){
    		for(sObject record: sObjectList){
    			String displayName = (String) record.get('CSM_Display_Name__c');
    			if(!fetchedTranslationMap.containsKey(displayName)){
    				fetchedTranslationMap.put(displayName, displayName);
    			}
    		}
    	}
    }
    
        
    public with sharing class REN_SOQLWrapper {
        public String fromObject {get; set;}
        public Set<String> knownFields {get; set;} 
        public Set<String> sFilter1 {get; set;} 
        public Set<Integer> nFilter1 {get; set;} 
        public String whereCondition {get; set;} 
        public boolean isFirstFilterSetRequired {get; set;}
        public Integer recordLimit {get; set;} 
    }
    
    public PageReference renderSavedSearch(){
		System.debug('fcViewId == ' + fcViewId);
        if (fcViewId!=null && fcViewId.length()>0){
			fcViewId = String.escapeSingleQuotes(fcViewId);
			List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
			try
			{
				Set<String> fieldsetApiNameSet = new Set<String>();
				Set<String> childObjects = new Set<String>();
				fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewID(fcViewId);
				if (fcViewList!=null && !fcViewList.isEmpty()){
                    fcView = fcViewList[0];
                    //Set Parent and child object from FC
                    if(!customSerachSetingsMap.containsKey(fcView.CSM_Object_Name__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.CSM_CRITERIA_UNAVAIL_PARENT));
                        fcView = null;
                        return null;
                    }
                    if(customSerachSetingsMap.containsKey(fcView.CSM_Object_Name__c)){
                        system.debug('customSerachSetingsMap --'+customSerachSetingsMap);
                        system.debug('fcView.CSM_Object_Name__c --'+fcView.CSM_Object_Name__c);
                        childObjects = customSerachSetingsMap.get(fcView.CSM_Object_Name__c);
                        System.debug('childObjects --'+ childObjects);
                        system.debug('fcView.RLM_Related_Object_Name__c --'+fcView.RLM_Related_Object_Name__c);
                        if(!childObjects.contains(fcView.RLM_Related_Object_Name__c) && !customSerachSetingsMap.containsKey(fcView.RLM_Related_Object_Name__c)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.CSM_CRITERIA_UNAVAIL_CHILD));
                            fcView = null;
                            return null;
                        }
                        
                    }
                    if(fcView.RLM_Related_Object_Name__c != null && fcView.CSM_Object_Name__c != null){
                        String childObjApiName = fcView.RLM_Related_Object_Name__c.split('\\.')[0];
                        configSettings.filterableFieldSet = parentObjToFieldSetMap.get(fcView.CSM_Object_Name__c + ':' + childObjApiName);
                        List<Schema.FieldSetMember> fieldSetMemberList = CHL_Util.getFieldSet(configSettings.filterableFieldSet, childObjApiName);
                        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                            fieldsetApiNameSet.add(fieldSetMemberObj.getFieldPath());
                        }
                    }
                    List<CSM_Focus_Category_View_Criteria__c> fcvCriteriaList = CSM_FocusCategoryViewCriteriaDataAccess.populateFCVCriteriaInformation(fcView.Id);
                    for(CSM_Focus_Category_View_Criteria__c fcvc : fcvCriteriaList){
                        if(!fieldsetApiNameSet.contains(fcvc.RLM_Field_Name__c)){
                            fcView = null;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.CSM_CRITERIA_FIELD_UNAVAIL_FIELDSET,new String[] {fcvc.RLM_Field_Display_Name__c})));
                            return null;
                        }
                    }
                    configSettings.selectedParentObject = fcView.CSM_Object_Name__c;
                    //selectedObject = selectedParentObject;
                    configSettings.selectedChildObject = fcView.RLM_Related_Object_Name__c;
                    callOnParentObjectChange();
                    fcViewName = 'Opportunity FC for Testing!!!!!!!!!!!!!!';
                    System.debug('fetchedTranslationMap - '+fetchedTranslationMap);
                    //fcViewName = fetchedTranslationMap.get(fcView.CSM_Display_Name__c);
                    System.debug('ZZZZ - fcViewName - '+fcViewName);
                    if(fcView.CSM_Filter_By_Owner_Value__c == 'Queue') {
                        isQueueOptDisable = false;
                        selectedGroupId = fcView.CSM_Case_Queue__c;
                        selectOwnerOption = '';
                    } else if(String.isNotBlank(fcView.CSM_Filter_By_Owner_Value__c)) {
                        selectOwnerOption = fcView.CSM_Filter_By_Owner_Value__c.indexOf(' ') == -1 ? fcView.CSM_Filter_By_Owner_Value__c: fcView.CSM_Filter_By_Owner_Value__c.substring(0,fcView.CSM_Filter_By_Owner_Value__c.indexOf(' '));
                    }
                    System.debug('ZZZZ - fcView - '+fcView);
                    REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
                    baseChildController.renderSavedSearch(fcView, fcvCriteriaList);
                }
                savedSearch = true;
			}
			catch (exception ex)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			}
			
		}
        return null;
    }
    
    public void validateMerge(){
        String externalAccountJSON = ApexPages.currentPage().getParameters().get('selectedExternalRecord');
        System.debug('externalAccountJSON == '+ externalAccountJSON);
        string whereCondition = '';
        isMergeRequired = false;
        String objectName = configSettings.objApiName;
        Map<String, Object> externalAccMap = (Map<String, Object>)JSON.deserializeUntyped(externalAccountJSON);
        List<String> requestedFields=new List<String>{'REN_oData_Param__c','REN_Custom_Mapped_Field__c','REN_RS_Matching_Field__c','REN_Editable__c','REN_Param_Type__c','REN_Object_Field_Name__c', 'REN_Picklist_Object__c', 'REN_Picklist_Field__c','REN_Picklist_Filter__c','REN_PickList_Default_Value__c'};
        configSettings.fieldMappingList = REN_RSConfigurationDataAccess.getFieldMapping(new Set<String>{(String)configSettings.configSettingMap.values()[0].get('Id')},requestedFields);
        sObject externalAcc = Schema.getGlobalDescribe().get(objectName).newSObject();
        Set<String> FldstoQuery = new Set<String>();
        if(configSettings.fieldMappingList != null){
        	for(REN_RS_Field_Mapping__c fldMapObj : configSettings.fieldMappingList){
                FldstoQuery.add(fldMapObj.REN_Object_Field_Name__c);
                if(fldMapObj.REN_RS_Matching_Field__c){
                    whereCondition+= fldMapObj.REN_Object_Field_Name__c+'='+'\''+externalAccMap.get(fldMapObj.REN_Object_Field_Name__c)+'\'AND ';
                }
                externalAcc.put(fldMapObj.REN_Object_Field_Name__c,externalAccMap.get(fldMapObj.REN_Object_Field_Name__c));
        	}
        	whereCondition=whereCondition.removeEnd(' ');
            whereCondition=whereCondition.removeEnd('AND');
            List<sObject> sfdcReordList = CHL_Util.getObjectListByWhereClause(FldstoQuery,objectName,whereCondition);
            configSettings.recordList = new List<sObject>();
            if(sfdcReordList != null && !sfdcReordList.isEmpty()){
            	for(REN_RS_Field_Mapping__c fldMapObj : configSettings.fieldMappingList){
                	if(sfdcReordList[0].get(fldMapObj.REN_Object_Field_Name__c) != externalAcc.get(fldMapObj.REN_Object_Field_Name__c)){
                        isMergeRequired = true;
                        break;
                	}
            	}
                if(isMergeRequired){
                    configSettings.recordList.add(externalAcc);
                    configSettings.recordList.add(sfdcReordList[0]);
                    param = JSON.serialize(configSettings);    
                }else{
                    String successMsg = String.format(Label.REN_LBL_MERGE_NOT_REQUIRED, new List<String>{(String)externalAcc.get('Name')});
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, successMsg));   
                }
                        
        	}else{
                List<sObject> recordList = REN_Util.insertSObjectRecords(new List<sObject>{externalAcc},(List<String>)JSON.deserialize(JSON.serialize(FldstoQuery), List<String>.class),objectName);
                if(recordList != null && !recordList.isEmpty()){
                    String successMsg = String.format(Label.REN_LBL_ADD_SUCCESS, new List<String>{(String)externalAcc.get('Name')});
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, successMsg));    
                }           
        	}
        }        
    }
}