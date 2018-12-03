/**
* @author         Vishal Patel (vishal@comitydesigns.com)
* @date           05.14.2015
* @description    REN_LogicBuilderCmpCtrl class 
*/
public with sharing class REN_LogicBuilderCmpCtrl extends REN_BaseChildController { 
	
	public Map<String, List<SelectOption>> fieldListByLogicBuilderExtName;
	@TestVisible
	private Map<String, FieldDescribedWrapper> fieldWrapperByLogicBuilderExtName;
	private Map<String, Map<String, FieldDescribedWrapper>> objfieldWrapperByLogicBuilderExtName;
	private List<SelectOption> sofieldList;
	public List<REN_LineCriteriaWrapper> criteriaWrapperList {get; set;}
	public String guidToCompare {get; set;}
	public List<SelectOption> soDateStringLiteral{get; private set;}
	public List<SelectOption> soRecordTypeStringLiteral{get; private set;}
	public Boolean isValidCSMCriteria {get; set;}
	private boolean flagRT;
	public String corpCurr {
		get; 
		set{
			corpCurr = String.isNotBlank(value) ? String.escapeSingleQuotes(value) : '';
			if(logicBuilderInput != null && logicBuilderInput.dependentLogicBuilder != null){
				logicBuilderInput.dependentLogicBuilder.parentObject.put(namespacePrefix + 'RLM_Currency_Code__c', corpCurr);
				if(logicBuilderInput.dependentLogicBuilder.dependentLogicBuilder != null){
					logicBuilderInput.dependentLogicBuilder.dependentLogicBuilder.parentObject.put(namespacePrefix + 'RLM_Currency_Code__c', corpCurr);
				}
			}
		}
	}
	public String strCriteria {get; set;}    
	public List<SelectOption> currList {get; set;} 
	public Boolean mcEnabled {get; set;}
	public Integer lineNumber  {get; set;}	
	public Map<String, List<SelectOption>> operatorMap{get;set;}
	public String relatedFieldsAPI;
	public String namespacePrefix;
	public Boolean viewUserLookup {get;set;}
	public List<SObject> criteriaToDelete{get;set;}
	public String selectedValue {get;set;}
	public String selectedQueue {get;set;}	
	//public List<SelectOption> options{get;set;}
	public List<String> lstOptions{get;set;}
	public List<SelectOption> optionsQueue{get;set;}	
	public List<SelectOption> optionsRecordType{get;set;}
	
	public REN_LogicBuilderCmpCtrl() {
		super();
		flagRT = true;
		this.soDateStringLiteral = CSM_CriteriaService.getDateStringList();
		currList = CSM_Util.currencyPicklist();  
		mcEnabled = CSM_Util.checkMCEnabled();
		namespacePrefix =  CSM_Util.getNamespace();
	}
	
	public REN_LogicBuilderInputWrapper logicBuilderInput {
		get;
		set{
			if(value != null){
				try{
					logicBuilderInput = value;
					viewUserLookup = logicBuilderInput.showUserLookup;
					if (logicBuilderInput.logicBuilderObject != null && this.criteriaWrapperList == null){
						this.objectNameSuper = String.isNotBlank(logicBuilderInput.lbSingleInstanceKey)
						?logicBuilderInput.lbSingleInstanceKey 
						:logicBuilderInput.logicBuilderExtName
						+ '_' 
						+ logicBuilderInput.logicBuilderObject;
						this.baseMainController = logicBuilderInput.baseMainController;
						relatedFieldsAPI = logicBuilderInput.relatedFields != null ? logicBuilderInput.relatedFields : '';
						getfieldWrapperByLogicBuilderExtName(logicBuilderInput.logicBuilderObject);
						this.criteriaWrapperList = new List<REN_LineCriteriaWrapper>();
						populateCriteria();
						populateOperatorMap();
						populateDefaultCriteria();
						if(this.logicBuilderInput.criteriaObject == CSM_CONSTANTS.OBJ_FCV_CRITERIA) {
							Schema.SObjectType objType;
							if(this.logicBuilderInput.logicBuilderObject.contains('__c')){
								objType = Schema.getGlobalDescribe().get(namespacePrefix +this.logicBuilderInput.logicBuilderObject);							
							}else{
								objType = Schema.getGlobalDescribe().get(this.logicBuilderInput.logicBuilderObject);							
							}

							Schema.DescribeSObjectResult objectResult = objType.getDescribe();
							String objectName = objectResult.getLabel();
							String ObjectNamePlural = objectResult.getLabelPlural();
							/*options = new List<SelectOption>();
							options.add(new SelectOption('All '+ObjectNamePlural, 'All '+ObjectNamePlural));
							options.add(new SelectOption('My '+ObjectNamePlural, 'My '+ObjectNamePlural));	
							options.add(new SelectOption('Queue', 'Queue'));*/	
							lstOptions = new List<String>();
							lstOptions.add('All '+ObjectNamePlural);
							lstOptions.add('My '+ObjectNamePlural);	
							if(objectName.toLowerCase() == 'case'){
								lstOptions.add('Queue');
								
								List<QueueSObject> lstQueue = CSM_FocusCategoryViewDataAccess.getQueues();
								optionsQueue = new List<SelectOption>();
								optionsQueue.add(new SelectOption('- None -', '- None -'));
								if(lstQueue != null && !lstQueue.isEmpty()){
									for(QueueSObject que: lstQueue){
										optionsQueue.add(new SelectOption(que.QueueId, que.Queue.Name));
									}
								}
							}
							
							if(String.isNotBlank((String)this.logicBuilderInput.parentObject.get(namespacePrefix +'CSM_Filter_By_Owner_Value__c'))) {
								selectedValue = (String)this.logicBuilderInput.parentObject.get(namespacePrefix +'CSM_Filter_By_Owner_Value__c');
							}else{
								selectedValue = 'All '+ObjectNamePlural;
							}
							
							if(String.isNotBlank((String)this.logicBuilderInput.parentObject.get(namespacePrefix +'CSM_Case_Queue__c'))) {
								selectedQueue = (String)this.logicBuilderInput.parentObject.get(namespacePrefix +'CSM_Case_Queue__c');
							}
						}	
					}
				}catch (Exception ex) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
				}
			}
		}
	}
	
	public boolean isMaxCriteriaReached {
		get{
			return (criteriaWrapperList != null && criteriaWrapperList.size() >= 10);
		} 
		set;
	}

	
	public List<SelectOption> getFieldList() {
		try {  
			set<String> setIgnoreFields = new set<String>();
			//setIgnoreFields.add(REN_Constants.REN_CURRENCY_ISO_CODE);
			setIgnoreFields.add(REN_Constants.OBJ_OPP_FORECAST_CATEGORY_2);
			setIgnoreFields.add('Opportunity__r.ForecastCategoryName');
			setIgnoreFields.add('Opportunity__r.ForecastCategory');
			setIgnoreFields.add(REN_Constants.FLD_ISDELETED);
			if (this.logicBuilderInput.logicBuilderExtName!=null 
					&& this.logicBuilderInput.logicBuilderObject!=null){
				if (fieldListByLogicBuilderExtName==null) {
					fieldListByLogicBuilderExtName = new Map<String, List<SelectOption>>();
				}
				
				sofieldList = new List<SelectOption>();
				if (fieldListByLogicBuilderExtName.containsKey(this.objectNameSuper)) {
					sofieldList = fieldListByLogicBuilderExtName.get(this.objectNameSuper);  
				} else {
					Set<SelectOption> selectOptionSet = new Set<SelectOption>();
					for(FieldDescribedWrapper fdw : fieldWrapperByLogicBuilderExtName.values()) {  
						//system.debug('fdw------------>'+fdw.selectedFieldAPIName);
						if(!setIgnoreFields.contains(fdw.selectedFieldAPIName) && fdw.selectedFieldAPIName != 'PartnerAccountId'){
							selectOptionSet.add(fdw.fieldSO);
						}
					}
					soFieldList.add(new SelectOption(Label.CSM_LBL_NONE, Label.CSM_LBL_NONE));
					soFieldList.addAll(selectOptionSet);
					CSM_Util.sortSelectOptionByLabelRelatedFields(soFieldList);
				}
				
				fieldListByLogicBuilderExtName.put(this.objectNameSuper, soFieldList);
			}
			system.debug('soFieldList------------>'+soFieldList);
			return soFieldList;
		}
		catch (Exception ex) {            
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
			return null;
		}
	}  
	
	
	public void performSave(){
		List<SObject> criteriaList = new List<SObject>();
		isValidCSMCriteria = true;
		if(viewUserLookup){
			//assignPlaceholderObject();
		}
		REN_LogicBuilderValidationHelper helper = new REN_LogicBuilderValidationHelper();
		operationsBeforeSave(helper);
		if(helper.validateCriteria(criteriaList, this.criteriaWrapperList, this.fieldWrapperByLogicBuilderExtName) 
				&& !criteriaList.isEmpty()) {
			Boolean isValidFilter = helper.validateFilterLogic((String)this.logicBuilderInput.parentObject.get(namespacePrefix + 'RLM_Filter_Logic__c'), criteriaList);
			if(isValidFilter){
				try{
					String criteriaLogicStr;
					if(!this.logicBuilderInput.isCurrencyOptionDisabled){					
						this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Currency_Code__c', String.escapeSingleQuotes(corpCurr));
					}
					if(this.logicBuilderInput.isBulkSearch && this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
						criteriaLogicStr = helper.buildWhereCriteriaBulkSearch(criteriaList, (REN_Renew_Configuration__c)this.logicBuilderInput.parentObject, false,this.logicBuilderInput.firstFilterSet);
					}else if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
						criteriaLogicStr = helper.buildWhereCriteriaString(criteriaList, (REN_Renew_Configuration__c)this.logicBuilderInput.parentObject, false);	
					}else {
						System.debug('ZZZ');
						criteriaLogicStr = helper.buildWhereCriteriaStringCSM(criteriaList, this.logicBuilderInput.parentObject);
						/*if(this.logicBuilderInput.criteriaObject == CSM_CONSTANTS.OBJ_FCV_CRITERIA) {
							if(String.isNotBlank(selectedValue) && selectedValue.startsWith('My ')) {
								criteriaLogicStr = criteriaLogicStr + ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';
							}
						}*/
						system.debug(criteriaLogicStr+'::::criteriaLogicStr');				
					}
					/* US2502 --  Added code to check the Where condition chareters, Display error message if WhereCondchar > 3800   */
					system.debug('@@@@@@@@@@ Check criteria length ::: '+ criteriaLogicStr.length() );
					if(criteriaLogicStr.length() > 3800){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.REN_LBL_CRITERIA_LIMIT_EXCEED, new String[]{String.valueOf(criteriaLogicStr.length() - 3800)})));
						isValidCSMCriteria = false;
						return;
					}
					
					String soql;
					List<String> fieldList = new List<String>{REN_Constants.FLD_ID};
					String Obj;
					integer recordsLimit;
					if(this.logicBuilderInput.logicBuilderObject == REN_Constants.OBJ_PRODUCT){
						Obj= REN_Constants.OBJ_OPPTY_LINE_ITEM;
						recordsLimit=1;
					} else {
						Obj= this.logicBuilderInput.logicBuilderObject;
						recordsLimit = 1;
					}
					system.debug('@@@@@@ criteriaLogicStr :: ' + criteriaLogicStr);
					
					if(!this.logicBuilderInput.isBulkSearch){
						List<SObject> sObjList = REN_RenewConfigurationDataAccess.getRecordsByCriteria(fieldList, obj,criteriaLogicStr, recordsLimit);
					}
					system.debug('SaveValues' + this.logicBuilderInput.criteriaObject);
					if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
						this.logicBuilderInput.parentObject.put(namespacePrefix + 'REN_Filter_Criteria__c', criteriaLogicStr);					
					}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
						strCriteria = criteriaLogicStr;			
					}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)){
						this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Criteria__c', criteriaLogicStr);					
					}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
						strCriteria = criteriaLogicStr;				
					}
				} catch(Exception ex) {
					isValidFilter = false;
					isValidCSMCriteria = false;
					String errMsg = String.format(System.Label.REN_LBL_FILTER_LOGIC_ERROR_MSG,new List<String>{ex.getMessage()});
					this.logicBuilderInput.parentObject.addError(errMsg);
					populateDefaultCriteria();
				}
				if(!this.logicBuilderInput.isSearch && isValidFilter){
					this.saveConfigAndCriterias(criteriaList);
				}
				else {
					populateDefaultCriteria();
					system.debug('-----------------5--------------');
				}
			}else{
				this.logicBuilderInput.parentObject.addError(System.Label.REN_LBL_FILTER_LOGIC_VALIDATE_ERROR_MSG);
				isValidCSMCriteria = false;
				populateDefaultCriteria();
			}
		}else if(criteriaList.isEmpty()){
			if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'REN_Filter_Criteria__c', '');
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', '');
				if(!this.logicBuilderInput.isSearch){
					deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
					this.saveConfigAndCriterias(criteriaList);
				}
			} else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Query_Criteria__c', '');
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', '');
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
				CSM_PlaysDataAccess.savePlays(new List<CSM_Play__c>{(CSM_Play__c)this.logicBuilderInput.parentObject});
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_SAVE));							
			} else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)){
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Criteria__c', '');
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', '');
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Filter_By_Owner_Value__c', selectedValue);
				if(selectedQueue == '- None -'){
					selectedQueue = null;
				}
				
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Case_Queue__c', selectedQueue);				
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
				CSM_FocusCategoryViewDataAccess.upsertFCV(new List<CSM_Focus_Category_View__c>{(CSM_Focus_Category_View__c)this.logicBuilderInput.parentObject});
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_SAVED));								
			}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Query_Criteria__c', '');
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', '');
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);	
				CSM_BatchFilterDataAccess.saveBatchFilter(new List<CSM_Batch_Filter__c>{(CSM_Batch_Filter__c)this.logicBuilderInput.parentObject});
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_LBL_BATCH_FILTER_SAVE));								
			}
			populateDefaultCriteria();						
		}else{
			isValidCSMCriteria = false;
			populateDefaultCriteria();
		}
	}
	
	public void performFind()	{
		this.performSave();
	}
	
	public PageReference newCriteria() {
		SObject newCriteriaObject;
		String fieldName = '';
		if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
			newCriteriaObject = new REN_Line_Criteria__c(REN_Renew_Configuration__c = this.logicBuilderInput.parentObject.Id);
		}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)){
			newCriteriaObject = new CSM_Focus_Category_View_Criteria__c(CSM_Focus_Category_View__c = this.logicBuilderInput.parentObject.Id);
		}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
			newCriteriaObject = new CSM_Play_Criteria__c(CSM_Play__c = this.logicBuilderInput.parentObject.Id);
		}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
			newCriteriaObject = new CSM_Batch_Filter_Criteria__c(CSM_Batch_Filter__c = this.logicBuilderInput.parentObject.Id);
		}
		
		
		if(viewUserLookup){
			//assignPlaceholderObject();
		}
		
		if(sofieldList != null && sofieldList.size() >0){
			fieldName = sofieldList[0].getValue();
		}else{
			getFieldList();
			if(sofieldList != null && sofieldList.size() >0){
				fieldName = sofieldList[0].getValue();
			}
		}
		
		criteriaWrapperList.add(new REN_LineCriteriaWrapper(newCriteriaObject, fieldWrapperByLogicBuilderExtName, 
		criteriaWrapperList.size()+1, 
		this.logicBuilderInput.logicBuilderObject,fieldName, '', null, 
		CSM_Util.NewGuid(), this.logicBuilderInput.criteriaObject));
		return null;
	}
	
	public PageReference deleteCriteria() {
		try {
			if(criteriaToDelete == null) {
				criteriaToDelete = new List<SObject>();
			}    		
			if(guidToCompare != null) {
				system.debug('indel -' + guidToCompare);
				for(integer i=0; i< criteriaWrapperList.size(); i++){
					if(guidToCompare == criteriaWrapperList[i].guid){
						system.debug('inguid -' + criteriaWrapperList[i].guid);
						if(criteriaWrapperList[i].criteria!=null && criteriaWrapperList[i].criteria.id != null){
							system.debug('inid -' + criteriaWrapperList[i].criteria.id);	    					
							criteriaToDelete.add(criteriaWrapperList[i].criteria);
						}
						criteriaWrapperList.remove(i);
						break;
					}	
				}
			}
			if (criteriaWrapperList.size() == 0) {
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', '');
			}
			
			for (Integer i=0; i<criteriaWrapperList.size(); i++){
				REN_LineCriteriaWrapper criteriaWrapper = criteriaWrapperList.get(i);
				criteriaWrapper.criteria.put(namespacePrefix + 'RLM_LineNo__c', i+1);
			}
		}
		catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}

	public class REN_LineCriteriaWrapper {
		public String guid {get; set;}
		public SObject criteria {get; set;}
		public List<SelectOption> msOptionList {get;set;}		
		public Map<String, FieldDescribedWrapper> fieldWrapperByLogicBuilderExtName;
		public SObject placeholderObject {get; set;}		
		public String namespacePrefix;
		public String referenceName {get; set;}
		public REN_LineCriteriaWrapper(SObject criteriaVal, Map<String,FieldDescribedWrapper> fieldWrapperByLogicBuilderExtNameVal, 
		Integer num, String objectName, String fAPIName, String fv, 
		String operator, String newGuid, String criteriaObject) {

			this.criteria = criteriaVal;
			
			guid = newGuid;
			referenceName = '';
			namespacePrefix = CSM_Util.getNamespace();
			fieldWrapperByLogicBuilderExtName = fieldWrapperByLogicBuilderExtNameVal;
			String objApiName = criteria.get(namespacePrefix + 'RLM_Field_Name__c') == null?null:(String)criteria.get(namespacePrefix + 'RLM_Field_Name__c');
			FieldDescribedWrapper fdw;
			if (fieldWrapperByLogicBuilderExtName!= null && objApiName != null && 
					fieldWrapperByLogicBuilderExtName.containsKey(objApiName)){
				fdw = fieldWrapperByLogicBuilderExtName.get(objApiName);
			}
			if (fdw != null && (fdw.dataType == CSM_Constants.TYPE_MULTIPICKLIST)){//||  fdw.dataType == CSM_Constants.TYPE_PICKLIST)){
				//populate the picklist values using the describe call
				if (!fdw.pickListOptions.isEmpty()) {
					msOptionList = fdw.pickListOptions;					
				}
			}	
			
			if(this.criteria.Id == null){
				criteria.put(namespacePrefix + 'RLM_LineNo__c', num);
				criteria.put(namespacePrefix + 'RLM_Field_Type__c', 'STRING');
				criteria.put(namespacePrefix + 'RLM_Field_Name__c', fAPIName);
				criteria.put(namespacePrefix + 'RLM_Values__c', fv);
				if (objectName!=null && criteriaObject.equals(REN_Constants.OBJ_LC)){
					criteria.put(namespacePrefix + 'RLM_Object_API_Name__c', objectName);
				}
				if(fdw != null){
					criteria.put(namespacePrefix + 'RLM_Field_Type__c', fdw.dataType);
					criteria.put(namespacePrefix + 'RLM_Field_Display_Name__c', fdw.displayName);
					criteria.put(namespacePrefix + 'RLM_Field_Name__c', fdw.selectedFieldAPIName);					
				}
				criteria.put(namespacePrefix + 'RLM_Operator__c', operator);
			}
			if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_REFERENCE){
				String relatedObjectName;
				String fieldValue;
				List<String> fieldList = new List<String>();
				fieldValue = (String)criteria.get(namespacePrefix + 'RLM_Field_Name__c') ;
				if(fieldValue.contains('.')){
					fieldList = fieldValue.split('\\.');
					if(fieldList.size()>= 2)
					relatedObjectName = REN_LogicBuilderCmpCtrl.lastFldRltedObjName(objectName,fieldList);
				}
				else {
					relatedObjectName = CSM_AccessController.getInstance().returnReferenceFieldObjectName(objectName,(String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
				}
				/*
				if((String.isNotBlank(relatedObjectName)&&relatedObjectName.toUpperCase() == 'USER') || (String.isNotBlank(relatedObjectName)&&relatedObjectName.toUpperCase() == 'GROUP')){
					referenceName = relatedObjectName.toUpperCase();
					placeholderObject = new CSM_User_Preferences__c();//Schema.getGlobalDescribe().get('CSM_User_Preferences__c').newSObject();//new CSM_User_Preferences__c();
					if(CSM_Util.isValidId((String)criteria.get(namespacePrefix + 'RLM_Values__c'))){
						placeholderObject.put(namespacePrefix + 'CSM_User__c',(Id)criteria.get(namespacePrefix + 'RLM_Values__c'));					
					}
				}
				if(criteriaObject.equals(REN_Constants.OBJ_LC) || criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA) || criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT) || criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
					if(String.isNotBlank(relatedObjectName)&&relatedObjectName.toUpperCase() == 'ACCOUNT' && objectName.toUpperCase()=='OPPORTUNITY'){
						referenceName = relatedObjectName.toUpperCase();
						placeholderObject = new Contact();//Schema.getGlobalDescribe().get('CSM_User_Preferences__c').newSObject();//new CSM_User_Preferences__c();
						if(CSM_Util.isValidId((String)criteria.get(namespacePrefix + 'RLM_Values__c'))){
							placeholderObject.put('AccountId',(Id)criteria.get(namespacePrefix + 'RLM_Values__c'));					
						}
					}
				}*/
			}
		}
	}
	
	public class FieldDescribedWrapper {
		public String objectName {get; set;}
		public SelectOption fieldSO {get; set;}
		public List<SelectOption> pickListOptions {get;set;}
		public String displayName {get; set;} 
		public String selectedFieldAPIName {get; set;} 
		public String dataType {get; set;}
		
		FieldDescribedWrapper(String objectNameVal, String displayNameVal, String selectedFieldAPINameVal, String dataTypeVal,
		List<SelectOption> options ){
			objectName = objectNameVal;
			displayName = displayNameVal;
			selectedFieldAPIName = selectedFieldAPINameVal;
			dataType = dataTypeVal;
			SelectOption so = new SelectOption(selectedFieldAPIName, displayName);
			fieldSO = so;
			pickListOptions = options;			
		}
	}
	
	public PageReference refreshLogicBuilder(){
		namespacePrefix = CSM_Util.getNamespace();		
		for(REN_LineCriteriaWrapper wrapper : this.criteriaWrapperList){
			String fieldApiName = wrapper.criteria.get('RLM_Field_Name__c') == null?null:(String)wrapper.criteria.get('RLM_Field_Name__c');
			if(fieldWrapperByLogicBuilderExtName.containsKey(fieldApiName)){
				FieldDescribedWrapper fdw = fieldWrapperByLogicBuilderExtName.get(fieldApiName);
				wrapper.criteria.put('RLM_Field_Type__c', fdw.dataType);
				wrapper.criteria.put('RLM_Field_Display_Name__c', fdw.displayName);
				system.debug('wraplist - ' + wrapper.criteria);
				if(fdw.dataType != CSM_Constants.TYPE_DATE && fdw.dataType != CSM_Constants.TYPE_DATETIME ) {
					wrapper.criteria.put(namespacePrefix + 'RLM_Date_Literal_Number__c', null);
					wrapper.criteria.put(namespacePrefix + 'RLM_Date_Literal_String__c', null);
				}		
				if(fdw.dataType != CSM_Constants.TYPE_DATE){
					wrapper.criteria.put(namespacePrefix + 'RLM_Date_Value__c', null);
				}
				if(fdw.dataType != CSM_Constants.TYPE_DATETIME){
					wrapper.criteria.put(namespacePrefix + 'RLM_DateTime_Value__c', null);
				}
				
				if (fdw.dataType == CSM_Constants.TYPE_MULTIPICKLIST){// || fdw.dataType == CSM_Constants.TYPE_PICKLIST){
					//populate the picklist values using the describe call
					if (fdw.pickListOptions != null && !fdw.pickListOptions.isEmpty()) {
						wrapper.msOptionList = fdw.pickListOptions;
					}
				}
			} else if (Label.CSM_LBL_NONE.equalsIgnoreCase(fieldApiName)){ //when Field is '--None--'
				wrapper.criteria.put(namespacePrefix + 'RLM_Field_Type__c', 'STRING');
				wrapper.criteria.put(namespacePrefix + 'RLM_Field_Display_Name__c', Label.CSM_LBL_NONE);
			}
		}
		
		if(criteriaWrapperList != null && lineNumber != null && lineNumber >0 && criteriaWrapperList.size() >= lineNumber){
			criteriaWrapperList[lineNumber-1].criteria.put('RLM_Values__c',null);
		}

		if(viewUserLookup){
			//assignPlaceholderObject();
		}
		return null;
	}
	
	public PageReference rerenderTable(){	
		return null;
	}
	
	public static String lastFldRltedObjName(String parentObjectName, List<String> fieldList){
		String relatedObjectName;
		Map<String, Schema.SObjectField> objFieldInfo;
		Schema.SObjectField fieldInfo;
		Schema.DescribeFieldResult dfr;
		if(fieldList[fieldList.size()-2].endsWithIgnoreCase('__r')){
			for(integer i= 0 ; i< fieldList.size();i++ ){
				if(i== 0){
					if(CSM_AccessController.objectFieldInfoMap != null && CSM_AccessController.objectFieldInfoMap.containsKey(parentObjectName)){
						objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(parentObjectName);
					}
					else{
						CSM_AccessController.getInstance().returnPermissionFieldsNameList(parentObjectName);
						objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(parentObjectName);
					}
					if(fieldList[i].endsWithIgnoreCase('__r'))
					fieldInfo = objFieldInfo.get(fieldList[i].replace('__r','__c'));
					else
					fieldInfo = objFieldInfo.get(fieldList[i]);
					
					if(fieldInfo != null){
						dfr = fieldInfo.getDescribe();
						relatedObjectName = dfr.getReferenceTo()[0].getDescribe().getName();
					}
					
				}
				else{
					if(CSM_AccessController.objectFieldInfoMap != null && CSM_AccessController.objectFieldInfoMap.containsKey(relatedObjectName)){
						objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(relatedObjectName);
					}
					else {
						CSM_AccessController.getInstance().returnPermissionFieldsNameList(relatedObjectName);
						objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(relatedObjectName);
					}
					if(fieldList[i].endsWithIgnoreCase('__r')){
						fieldInfo = objFieldInfo.get(fieldList[i].replace('__r','__c'));
						if(fieldInfo != null){								
							dfr = fieldInfo.getDescribe();
							relatedObjectName = dfr.getReferenceTo()[0].getDescribe().getName();
						}
					}
				}
			}
		}
		else{
			Schema.DescribeFieldResult relatedObject =  Schema.getGlobalDescribe().get(parentObjectName).getDescribe().fields.getMap().get(fieldList[fieldList.size()-2]+'Id').getDescribe();
			relatedObjectName = CSM_AccessController.getInstance().returnReferenceFieldObjectName(String.valueOf(relatedObject.getReferenceTo()[0].getDescribe().getName()),fieldList[fieldList.size()-1]);
			//relatedObjectName = CSM_AccessController.getInstance().returnReferenceFieldObjectName(fieldList[fieldList.size()-2],fieldList[fieldList.size()-1]);
		}
		
		return relatedObjectName;
	}
	
	private void populateOperatorMap(){
		operatorMap = new Map<String, List<SelectOption>>();
		List<SelectOption> multiPicklistOperatorsOptions = new List<SelectOption>();
		List<SelectOption> lookupOperatorsOptions = new List<SelectOption>();
		List<SelectOption> checkBoxOperatorsOptions = new List<SelectOption>();
		Map<String, String> operatorToLabelMap = new Map<String, String>();
		// TODO: This code needs to be changed to take the operator label and values from picklist.
		operatorToLabelMap.put(CSM_Constants.STR_NONE, Label.CSM_LBL_NONE);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_EQUAL, Label.REN_LBL_EQUALS);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_NOTEQUAL, Label.REN_LBL_NOT_EQUAL);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_GREATERTHAN, Label.REN_LBL_GREATER_THAN);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_GREATERTHANEQUALTO, Label.REN_LBL_GREATER_THAN_EQUAL_TO);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_LESSERTHAN, Label.REN_LBL_LESSER_THAN);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_LESSERTHANEQUALTO, Label.REN_LBL_LESSER_THAN_EQUAL_TO);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_LIKE, Label.REN_LBL_CONTAINS);
		operatorToLabelMap.put(CSM_Constants.DOES_NOT_CONTAINS, Label.REN_LBL_DOES_NOT_CONTAIN);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_IN, Label.REN_LBL_IN);
		operatorToLabelMap.put(CSM_Constants.OPERATOR_NOTIN, Label.REN_LBL_NOT_IN);
		
		List<SelectOption> allOperatorsOptions = new List<SelectOption>();
		List<String> multiPicklistOperatorsList = new List<String> { 
			Label.CSM_LBL_NONE, CSM_Constants.OPERATOR_EQUAL,CSM_Constants.OPERATOR_NOTEQUAL,
			CSM_Constants.OPERATOR_INCLUDES,CSM_Constants.OPERATOR_EXCLUDES 
		};
		List<String> checkBoxOperatorsList = new List<String> { 
			Label.CSM_LBL_NONE, CSM_Constants.OPERATOR_EQUAL,CSM_Constants.OPERATOR_NOTEQUAL
		};		

		List<String> lookupOperatorsList = new List<String> { 
			Label.CSM_LBL_NONE, CSM_Constants.OPERATOR_EQUAL,CSM_Constants.OPERATOR_NOTEQUAL,
			CSM_Constants.OPERATOR_IN,CSM_Constants.OPERATOR_NOTIN
		};
		
		List<String> allOperatorsList = new List<String> {
			Label.CSM_LBL_NONE, CSM_Constants.OPERATOR_EQUAL,CSM_Constants.OPERATOR_GREATERTHAN,
			CSM_Constants.OPERATOR_GREATERTHANEQUALTO,CSM_Constants.OPERATOR_LESSERTHAN,
			CSM_Constants.OPERATOR_LESSERTHANEQUALTO,CSM_Constants.OPERATOR_NOTEQUAL,
			CSM_Constants.OPERATOR_LIKE,CSM_Constants.OPERATOR_IN,CSM_Constants.OPERATOR_NOTIN, CSM_Constants.DOES_NOT_CONTAINS
		};										
		
		if(logicBuilderInput != null && (this.logicBuilderInput.logicBuilderExtName == REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT || this.logicBuilderInput.logicBuilderExtName == REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT)){
			allOperatorsList.add(CSM_Constants.OPERATOR_ALL);
		}
		
		for(String operator : multiPicklistOperatorsList){
			multiPicklistOperatorsOptions.add(operatorToLabelMap.containsKey(operator)
			?new SelectOption(operator,operatorToLabelMap.get(operator))
			:new SelectOption(operator,operator));
		}
		
		for(String operator : lookupOperatorsList){
			lookupOperatorsOptions.add(operatorToLabelMap.containsKey(operator)
			?new SelectOption(operator,operatorToLabelMap.get(operator))
			:new SelectOption(operator,operator));
		}
		
		for(String operator : checkBoxOperatorsList){
			checkBoxOperatorsOptions.add(operatorToLabelMap.containsKey(operator)
			?new SelectOption(operator,operatorToLabelMap.get(operator))
			:new SelectOption(operator,operator));
		}		

		for(String operator : allOperatorsList){
			allOperatorsOptions.add(operatorToLabelMap.containsKey(operator)
			?new SelectOption(operator,operatorToLabelMap.get(operator))
			:new SelectOption(operator,operator));
		}
		operatorMap.put(CSM_Constants.TYPE_STRING, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_DATE, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_DATETIME, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_INTEGER, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_PICKLIST, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_DOUBLE, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_CURRENCY, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_PERCENT, allOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_MULTIPICKLIST, multiPicklistOperatorsOptions);	
		operatorMap.put(CSM_Constants.TYPE_REFERENCE, lookupOperatorsOptions);		
		operatorMap.put(CSM_Constants.TYPE_BOOLEAN, checkBoxOperatorsOptions);	
		operatorMap.put(REN_Constants.OBJ_CASE_RECORD_TYPE, lookupOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_ID, lookupOperatorsOptions);
		operatorMap.put(CSM_Constants.TYPE_TEXTAREA, allOperatorsOptions);      	
	}
	
	private void populateCriteria(){
		if (this.logicBuilderInput.parentObject != null && String.isNotBlank(this.logicBuilderInput.parentObject.Id)){
			List<SObject> listOfCriteria;
			system.debug('listOfCriteria----'+this.logicBuilderInput.criteriaObject);
			if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
				listOfCriteria = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(this.logicBuilderInput.parentObject.Id, 
				this.logicBuilderInput.logicBuilderObject);
				system.debug('listOfCriteria------------>'+listOfCriteria);
			}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)){
				listOfCriteria = CSM_FocusCategoryViewCriteriaDataAccess.populateFCVCriteriaInformation(this.logicBuilderInput.parentObject.Id);
			}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
				listOfCriteria = CSM_PlayCriteriaDataAccess.populatePlayCriteriaInformation(this.logicBuilderInput.parentObject.Id);
			}else if(this.logicBuilderInput.criteriaObject.equals('CSM_Batch_Filter_Criteria__c')){
				listOfCriteria = CSM_BatchFilterCriteriaDataAccess.populateBatchFilterCriteriaInformation(this.logicBuilderInput.parentObject.Id);
			}
			if(this.logicBuilderInput.parentObject.get('RLM_Currency_Code__c') != null 
					&& (String)this.logicBuilderInput.parentObject.get('RLM_Currency_Code__c') !=''){
				corpCurr = (String)this.logicBuilderInput.parentObject.get('RLM_Currency_Code__c');
			}
			else{
				corpCurr = CSM_Util.getCorpCurrency();
			}
			
			if (listOfCriteria != null) {
				for (SObject lc: listOfCriteria) {
					criteriaWrapperList.add(new REN_LineCriteriaWrapper(lc, 
					fieldWrapperByLogicBuilderExtName, criteriaWrapperList.size()+1, 
					this.logicBuilderInput.logicBuilderObject, null, null, null, 
					CSM_Util.NewGuid(), this.logicBuilderInput.criteriaObject));
				}
			}
		}
		else {
			corpCurr = CSM_Util.getCorpCurrency();
		}
	}
	
	private void getfieldWrapperByLogicBuilderExtName(String objectName) {
		Set<String> relatedFieldstoDisplay;
		objfieldWrapperByLogicBuilderExtName = new Map<String, Map<String, FieldDescribedWrapper>>();
		fieldWrapperByLogicBuilderExtName = new Map<String, FieldDescribedWrapper>();
		if (!objfieldWrapperByLogicBuilderExtName.containsKey(objectName)){
			List<Schema.SObjectField> fieldListValues = CSM_AccessController.getInstance().returnPermissionFieldsNameList(objectName);
			populateFldWrapper(fieldListValues,objectName,'','');
		}
		if(String.isNotBlank(relatedFieldsAPI)){
			relatedFieldstoDisplay = new Set<String>(relatedFieldsAPI.split(','));
			getRelatedObjFlds(objectName,relatedFieldstoDisplay);
		}
	}
	
	private void getRelatedObjFlds(String objectName,Set<String> relatedFieldstoDisplay){
		List<Schema.SObjectField> fieldListValues;
		String relatedObjectName;
		String parentObjectName;
		String fieldName;
		Map<String, Schema.SObjectField> objFieldInfo;
		Schema.SObjectField fieldInfo;
		Schema.DescribeFieldResult fieldDescribe;
		String relatedFieldName;
		String relationshipName;
		List<String> fieldList = new List<String>();
		for(String refField: relatedFieldstoDisplay){
			if(refField.contains('.')){
				fieldList = refField.split('\\.');
				for(integer i= 0 ; i<fieldList.size();i++ ){
					if(fieldList[i].endsWithIgnoreCase('__r'))
					fieldName = fieldList[i].replace('__r','__c');
					else
					fieldName = fieldList[i];
					
					if(i== 0){
						if(CSM_AccessController.objectFieldInfoMap != null && CSM_AccessController.objectFieldInfoMap.containsKey(objectName)){
							objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(objectName);
						}
						else{
							CSM_AccessController.getInstance().returnPermissionFieldsNameList(objectName);
							objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(objectName);
						}
						fieldInfo = objFieldInfo.get(fieldName);
						if(fieldInfo != null){
							fieldDescribe = fieldInfo.getDescribe();
							relatedObjectName = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
							if(fieldDescribe.getName().endsWithIgnoreCase('__c')){
								relatedFieldName = fieldDescribe.getLabel();
							}
							else if(fieldDescribe.getName().endsWithIgnoreCase('ID')){
								relatedFieldName = fieldDescribe.getLabel().removeEndIgnoreCase('Id').trim();
							}
							relationshipName = fieldDescribe.getRelationshipName();
							fieldListValues = CSM_AccessController.getInstance().returnPermissionFieldsNameList(relatedObjectName);
							populateFldWrapper(fieldListValues,objectName,relatedFieldName,relationshipName);
						}
					}
					else{
						objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(relatedObjectName);
						fieldInfo = objFieldInfo.get(fieldName);
						if(fieldInfo != null){
							fieldDescribe = fieldInfo.getDescribe();
							relatedObjectName = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
							if(fieldDescribe.getName().endsWithIgnoreCase('__c')){
								relatedFieldName = relatedFieldName+': '+fieldDescribe.getLabel();
							}
							else if(fieldDescribe.getName().endsWithIgnoreCase('ID')){
								relatedFieldName = relatedFieldName+': '+fieldDescribe.getLabel().removeEndIgnoreCase('Id').trim();
							}
							relationshipName = relationshipName+'.'+fieldDescribe.getRelationshipName();
							fieldListValues = CSM_AccessController.getInstance().returnPermissionFieldsNameList(relatedObjectName);
							populateFldWrapper(fieldListValues,objectName,relatedFieldName,relationshipName);
						}
					}
				}
			}
			else{
				if(CSM_AccessController.objectFieldInfoMap != null && CSM_AccessController.objectFieldInfoMap.containsKey(objectName)){
					objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(objectName);
				}
				else{
					CSM_AccessController.getInstance().returnPermissionFieldsNameList(objectName);
					objFieldInfo = CSM_AccessController.objectFieldInfoMap.get(objectName);
				}
				fieldInfo = objFieldInfo.get(refField);
				if(fieldInfo != null){
					fieldDescribe = fieldInfo.getDescribe();
					relatedObjectName = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
					if(fieldDescribe.getName().endsWithIgnoreCase('__c')){
						relatedFieldName = fieldDescribe.getLabel();
					}
					else if(fieldDescribe.getName().endsWithIgnoreCase('ID')){
						relatedFieldName = fieldDescribe.getLabel().removeEndIgnoreCase('Id').trim();
					}
					relationshipName = fieldDescribe.getRelationshipName();
					fieldListValues = CSM_AccessController.getInstance().returnPermissionFieldsNameList(relatedObjectName);
					populateFldWrapper(fieldListValues,objectName,relatedFieldName,relationshipName);
				}
			}
		}
	}
	
	private void populateFldWrapper(List<Schema.SObjectField> fieldListValues,String objectName, String relatedFieldName,String relationshipName){
		String fieldLabel;
		String fieldName;
		String strName;
		FieldDescribedWrapper fieldWrapper;
		FieldDescribedWrapper fieldWrapperName; //Reference to Name of lookup
		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(CSM_Util.getNamespace() + objectName).getDescribe().fields.getMap();
		String fieldNameRef;
		String relatedObjectName;
		Schema.SObjectField nameField;
		for( Schema.SObjectField tmpfield :fieldListValues) {
			fieldWrapper = null; //setting to null to avoid overriding
			List<SelectOption> pickListOptions = new List<SelectOption>();		        	   
			if (!String.valueOf(tmpfield).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
					!String.valueOf(tmpfield).toLowerCase().contains(CSM_Constants.CONTRACT_ID)
					&& !String.valueOf(tmpfield).equalsIgnoreCase('ExternalDataSourceId')
					&& !String.valueOf(tmpfield).equalsIgnoreCase('RecurrenceActivityId')){
				DescribeFieldResult tmpResult = tmpfield.getDescribe();
				DisplayType fieldDisplayType = tmpResult.getType();
				fieldLabel = tmpResult.getLabel();
				fieldName = tmpResult.getName();
				System.debug('fieldName == ' + fieldName);
				if (!fieldName.equalsIgnoreCase(REN_Constants.REN_CURRENCY_ISO_CODE) && 
						(String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_STRING
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATE
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATETIME
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_INTEGER
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DOUBLE
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_CURRENCY
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_MULTIPICKLIST
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PERCENT
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_BOOLEAN
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_REFERENCE
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_ID
							|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_TEXTAREA
							) && tmpResult.filterable == true) {
					if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_MULTIPICKLIST){//|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST) {
						List<Schema.PicklistEntry> pleList = tmpResult.getPicklistValues();			            
						for (Schema.PicklistEntry a : pleList) { 
							pickListOptions.add(new SelectOption(a.getLabel(), a.getValue())); 
						}			            
					}
					if(String.isNotBlank(relatedFieldName)&& String.isNotBlank(relationshipName)){
						fieldLabel = relatedFieldName+': '+tmpResult.getLabel();
						fieldName = relationshipName+'.'+tmpResult.getName();
					}
					if(String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_REFERENCE 
							&& fieldMap.containsKey(fieldName) 
							&& !fieldWrapperByLogicBuilderExtName.containsKey(fieldName)
							&& !String.valueOf(tmpResult.getRelationshipName()).equalsIgnoreCase('Partneraccount')){
						//Adding ID
						fieldWrapper = new FieldDescribedWrapper(objectName, 
						fieldLabel, 
						fieldName, 
						String.valueOf(fieldDisplayType), pickListOptions);
						//Adding Name field
						relatedObjectName = tmpResult.getReferenceTo()[0].getDescribe().getName();
						if(CSM_AccessController.hasField(relatedObjectName, 'Name')){
							nameField = Schema.getGlobalDescribe().get(relatedObjectName).getDescribe().fields.getMap().get('Name');
							if(String.valueOf(tmpResult.getRelationshipName()).containsIgnoreCase('__r')){
								fieldLabel = tmpfield.getDescribe().getLabel() + ' ' + nameField;
							}else if(tmpfield.getDescribe().getLabel().endsWithIgnoreCase('ID')){
								fieldLabel = tmpfield.getDescribe().getLabel().removeEndIgnoreCase('Id').trim() + ' ' + nameField;
							}
							fieldNameRef = tmpResult.getRelationshipName() + '.' + nameField;
							fieldWrapperName = new FieldDescribedWrapper(relatedObjectName, 
							fieldLabel, 
							fieldNameRef, 
							String.valueOf(CSM_Constants.TYPE_STRING), pickListOptions);
						}
					}else if(String.valueOf(fieldDisplayType) != CSM_Constants.TYPE_REFERENCE 
							&& !fieldWrapperByLogicBuilderExtName.containsKey(fieldName)
							&& !(String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_ID && String.isNotBlank(relatedFieldName))){
						fieldWrapper = new FieldDescribedWrapper(objectName, 
						fieldLabel, 
						fieldName, 
						String.valueOf(fieldDisplayType), pickListOptions);
					}
					
					if(fieldWrapper != null){
						fieldWrapperByLogicBuilderExtName.put(fieldName, fieldWrapper);
						if(fieldWrapperName != null){
							fieldWrapperByLogicBuilderExtName.put(fieldNameRef, fieldWrapperName);
						}
						objfieldWrapperByLogicBuilderExtName.put(objectName, fieldWrapperByLogicBuilderExtName);
					}
				}
			}                        
		}
		List<SelectOption> pickListOptions = new List<SelectOption>();
		soRecordTypeStringLiteral = CSM_CriteriaService.getRecordTypeFromObject(objectName);
		if(!soRecordTypeStringLiteral.isEmpty()){
			fieldWrapper= new FieldDescribedWrapper(objectName, 
			//REN_Constants.OBJ_CASE_RECORD_TYPE,
			Label.CSM_LBL_RECORD_TYPE,
			REN_Constants.RECORD_TYPE_ID, 
			CSM_Constants.TYPE_REFERENCE, pickListOptions);
		}
		if(fieldWrapper != null){
			fieldWrapperByLogicBuilderExtName.put('RecordTypeId', fieldWrapper);
			objfieldWrapperByLogicBuilderExtName.put(objectName, fieldWrapperByLogicBuilderExtName);
		}
		system.debug('fieldWrapper--****'+fieldWrapper);
	}
	
	private void saveConfigAndCriterias(List<SObject> criteriaList){
		if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
			REN_RenewConfigurationDataAccess.saveRenewConfiguration(new List<REN_Renew_Configuration__c>{(REN_Renew_Configuration__c)this.logicBuilderInput.parentObject});
			List<REN_Line_Criteria__c> criteriaListToUpsert = new List<REN_Line_Criteria__c>();
			if(!criteriaList.isEmpty()){
				for (SObject criteria : criteriaList) {
					if (criteria.get(namespacePrefix + 'REN_Renew_Configuration__c') == null && this.logicBuilderInput.parentObject.Id != null){
						criteria.put(namespacePrefix + 'REN_Renew_Configuration__c', this.logicBuilderInput.parentObject.Id);
					}
					criteriaListToUpsert.add((REN_Line_Criteria__c)criteria);
				}
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
				REN_LineCriteriaDataAccess.upsertLineCriterias(criteriaListToUpsert);
			}
		}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
			CSM_PlaysDataAccess.savePlays(new List<CSM_Play__c>{(CSM_Play__c)this.logicBuilderInput.parentObject});			
			List<CSM_Play_Criteria__c> criteriaListToUpsert = new List<CSM_Play_Criteria__c>();
			if(!criteriaList.isEmpty()){
				for (SObject criteria : criteriaList) {
					if (criteria.get(namespacePrefix + 'CSM_Play__c') == null && this.logicBuilderInput.parentObject.Id != null){
						criteria.put(namespacePrefix + 'CSM_Play__c', this.logicBuilderInput.parentObject.Id);
					}
					criteriaListToUpsert.add((CSM_Play_Criteria__c)criteria);
				}
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
				CSM_PlayCriteriaDataAccess.savePlayCriteria(criteriaListToUpsert);
			}
		} else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)) {
			this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Filter_By_Owner_Value__c', selectedValue);
			if(selectedQueue == '- None -'){
				selectedQueue = null;
			}
			this.logicBuilderInput.parentObject.put(namespacePrefix + 'CSM_Case_Queue__c', selectedQueue);			
			CSM_FocusCategoryViewDataAccess.upsertFCV(new List<CSM_Focus_Category_View__c>{(CSM_Focus_Category_View__c)this.logicBuilderInput.parentObject});			
			List<CSM_Focus_Category_View_Criteria__c> criteriaListToUpsert = new List<CSM_Focus_Category_View_Criteria__c>();
			if(!criteriaList.isEmpty()){
				for (SObject criteria : criteriaList) {
					if (criteria.get(namespacePrefix + 'CSM_Focus_Category_View__c') == null && this.logicBuilderInput.parentObject.Id != null){
						criteria.put(namespacePrefix + 'CSM_Focus_Category_View__c', this.logicBuilderInput.parentObject.Id);
					}
					criteriaListToUpsert.add((CSM_Focus_Category_View_Criteria__c)criteria);
				}
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
				CSM_FocusCategoryViewCriteriaDataAccess.saveFCVCriteria(criteriaListToUpsert);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_SAVED));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_CRITERIA_SAVED));				
			}
		} else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
			//CSM_PlaysDataAccess.savePlays(new List<CSM_Batch_Filter__c>{(CSM_Batch_Filter__c)this.logicBuilderInput.parentObject});			
			List<CSM_Batch_Filter__c> batchFilterlist = new List<CSM_Batch_Filter__c>{(CSM_Batch_Filter__c)this.logicBuilderInput.parentObject};
			CSM_BatchFilterDataAccess.saveBatchFilter(batchFilterlist);
			
			List<CSM_Batch_Filter_Criteria__c> criteriaListToUpsert = new List<CSM_Batch_Filter_Criteria__c>();
			if(!criteriaList.isEmpty()){
				for (SObject criteria : criteriaList) {
					if (criteria.get(namespacePrefix + 'CSM_Batch_Filter__c') == null && this.logicBuilderInput.parentObject.Id != null){
						criteria.put(namespacePrefix + 'CSM_Batch_Filter__c', this.logicBuilderInput.parentObject.Id);
					}
					criteriaListToUpsert.add((CSM_Batch_Filter_Criteria__c)criteria);
				}
				deleteCriteriaFromObject(this.logicBuilderInput.criteriaObject);
				CSM_BatchFilterCriteriaDataAccess.saveBatchFilterCriteria(criteriaListToUpsert);
			}
		} 
		criteriaWrapperList.clear();
		populateCriteria();
		populateDefaultCriteria();				
	}
	
	private void assignPlaceholderObject() { 
		String strName;
		String fieldValue;
		List<String> fieldList = new List<String>();
		for(REN_LineCriteriaWrapper lcWrap: criteriaWrapperList){
			lcWrap.placeholderObject = null;
			if(lcWrap.criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_REFERENCE){
				fieldValue = (String)lcWrap.criteria.get(namespacePrefix + 'RLM_Field_Name__c') ;
				if(fieldValue.contains('.')){
					fieldList = fieldValue.split('\\.');
					if(fieldList.size()>= 2)
					strName = lastFldRltedObjName(logicBuilderInput.logicBuilderObject,fieldList);
				}
				else {
					strName = CSM_AccessController.getInstance().returnReferenceFieldObjectName(logicBuilderInput.logicBuilderObject,(String)lcWrap.criteria.get('RLM_Field_Name__c'));
				}
				
				if((String.isNotBlank(strName) && strName.toUpperCase() == 'USER') || (String.isNotBlank(strName) && strName.toUpperCase() == 'GROUP')){
					lcWrap.referenceName = strName.toUpperCase();
					if((lcWrap.criteria.get(namespacePrefix + 'RLM_Values__c') == null || String.IsEmpty((String)lcWrap.criteria.get(namespacePrefix + 'RLM_Values__c'))) && lcWrap.placeholderObject !=null){
						lcWrap.criteria.put(namespacePrefix + 'RLM_Values__c',lcWrap.placeholderObject.get(namespacePrefix + 'CSM_User__c'));						
					}else{
						lcWrap.placeholderObject = new CSM_User_Preferences__c();//Schema.getGlobalDescribe().get('CSM_User_Preferences__c').newSObject();//new CSM_User_Preferences__c();//						
						if(CSM_Util.isValidId((String)lcWrap.criteria.get(namespacePrefix +'RLM_Values__c'))){
							lcWrap.placeholderObject.put(namespacePrefix +'CSM_User__c',(Id)lcWrap.criteria.get(namespacePrefix +'RLM_Values__c'));						
						}
					}
				}	
				if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC) || this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA) || this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT) || this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
					if(String.isNotBlank(strName) && strName.toUpperCase() == 'ACCOUNT' && this.logicBuilderInput.logicBuilderObject.toUpperCase() == 'OPPORTUNITY'){
						lcWrap.referenceName = strName.toUpperCase();						
						if((lcWrap.criteria.get(namespacePrefix + 'RLM_Values__c') == null || String.IsEmpty((String)lcWrap.criteria.get(namespacePrefix + 'RLM_Values__c'))) && lcWrap.placeholderObject !=null){
							lcWrap.criteria.put(namespacePrefix + 'RLM_Values__c',lcWrap.placeholderObject.get('AccountId'));						
						}else{
							lcWrap.placeholderObject = new Contact();//Schema.getGlobalDescribe().get('CSM_User_Preferences__c').newSObject();//new CSM_User_Preferences__c();//						
							if(CSM_Util.isValidId((String)lcWrap.criteria.get(namespacePrefix +'RLM_Values__c'))){
								lcWrap.placeholderObject.put('AccountId',(Id)lcWrap.criteria.get(namespacePrefix +'RLM_Values__c'));						
							}
						}
					}	
				}
			}
		}
	}
	
	private void deleteCriteriaFromObject(String criteriaObject){
		system.debug('criteriaToDelete::' + criteriaToDelete);
		if(criteriaToDelete != null && !criteriaToDelete.isEmpty()) {
			if(criteriaObject.equals(REN_Constants.OBJ_LC)){
				REN_LineCriteriaDataAccess.deleteLineCriteria(criteriaToDelete);			
			} else if(criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
				CSM_PlayCriteriaDataAccess.deletePlayCriteria((List<CSM_Play_Criteria__c>) criteriaToDelete);			
			} else if(criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)){
				CSM_FocusCategoryViewCriteriaDataAccess.deleteFCVCriteria((List<CSM_Focus_Category_View_Criteria__c>) criteriaToDelete);			
			} else if(criteriaObject.equals(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA)){
				CSM_BatchFilterCriteriaDataAccess.deleteBatchFilterCriteria((List<CSM_Batch_Filter_Criteria__c>) criteriaToDelete);			
			}		
			criteriaToDelete.clear();	
		}
		
	}
	public void populateDefaultCriteria() {
		Integer tempCounter = REN_Constants.DEFAULT_CRITERIA_COUNT - this.criteriaWrapperList.size();
		if (tempCounter > 0) {
			for (Integer idx = 0; idx < tempCounter; idx++) {
				newCriteria();
				system.debug('inhere');
			}
		}		
	}
	
	private void operationsBeforeSave(REN_LogicBuilderValidationHelper helper) {

		if (this.criteriaWrapperList.size() == 0) {
			this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', '');
		}
		Boolean isValidFilter = helper.validateFilterLogicForWrapper((String)this.logicBuilderInput.parentObject.get(namespacePrefix + 'RLM_Filter_Logic__c'), this.criteriaWrapperList);
		Boolean hasValidOperator = helper.validateOperatorsForWrapper(this.criteriaWrapperList);
		
		if (!isValidFilter) {
			isValidCSMCriteria = false;
			throw new InvalidFilterException(System.Label.REN_LBL_FILTER_LOGIC_VALIDATE_ERROR_MSG);
		}
		else if (!hasValidOperator) {
			isValidCSMCriteria = false;
			throw new InvalidOperatorException(System.Label.REN_LBL_INVALID_OPERATOR_ERROR_MSG);
		}
		else {
			try {
				Map<String, Map<String,String>> originalGuidLineNumberMap = new Map<String, Map<String,String>>();
				if (this.criteriaWrapperList != null && this.criteriaWrapperList.size() > 0) {
					for(integer i=0; i< this.criteriaWrapperList.size(); i++){
						REN_LineCriteriaWrapper criteriaWrapper = this.criteriaWrapperList.get(i);
						String guid = String.valueOf(criteriaWrapper.guid);
						String lineNumber = String.valueOf(criteriaWrapper.criteria.get(namespacePrefix + 'RLM_LineNo__c'));
						Map<String, String> tmpMap = new Map<String, String>();
						tmpMap.put(lineNumber, '');
						originalGuidLineNumberMap.put(guid, tmpMap);								
					}
				}
				if (this.criteriaWrapperList != null && this.criteriaWrapperList.size() > 0) {
					for(integer i = this.criteriaWrapperList.size() - 1; i >= 0; --i){
						if (criteriaWrapperList[i].criteria != null) {
							String strFieldName = String.valueOf(this.criteriaWrapperList[i].criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
							if (String.isBlank(strFieldName) || strFieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)) {
								if(criteriaToDelete == null) {
									criteriaToDelete = new List<SObject>();
								}
								if (criteriaWrapperList[i].criteria != null && criteriaWrapperList[i].criteria.id != null){
									criteriaToDelete.add(criteriaWrapperList[i].criteria);										
								}				
								this.criteriaWrapperList.remove(i);						
							}
						}
					}
				}								
				if (this.criteriaWrapperList != null && this.criteriaWrapperList.size() > 0) {			
					for(Integer i=0; i< this.criteriaWrapperList.size(); i++){
						REN_LineCriteriaWrapper criteriaWrapper = this.criteriaWrapperList.get(i);
						criteriaWrapper.criteria.put(namespacePrefix + 'RLM_LineNo__c', i+1);
						String guid = String.valueOf(criteriaWrapper.guid);
						Map<String, String> tmpMap = originalGuidLineNumberMap.get(guid);
						Set <String> valueSet = tmpMap.keySet();
						if (valueSet.size() > 0 && !valueSet.isEmpty()) {
							tmpMap.put(String.valueOf(valueSet.iterator().next()), String.valueOf(criteriaWrapper.criteria.get(namespacePrefix + 'RLM_LineNo__c')));
						}
					}
				}				
				List<Map<String, String>> lineMapList = originalGuidLineNumberMap.values();
				//finally update the new filter logic and repopulate it
				String filterLogic = (String)this.logicBuilderInput.parentObject.get(namespacePrefix + 'RLM_Filter_Logic__c');
				
				if (lineMapList != null && !lineMapList.isEmpty() && filterLogic != null) {
					for (Integer i = 0; i < lineMapList.size(); i++) {
						Map <String, String> replaceMap = lineMapList.get(i);
						Set <String> valueSet = replaceMap.keySet();
						String fromLineNo = String.valueOf(valueSet.iterator().next());
						String toLineNo = replaceMap.get(fromLineNo);
						if (fromLineNo.length() > 0 && toLineNo.length() > 0) {
							filterLogic = filterLogic.replaceAll(fromLineNo, toLineNo);
						}
					}
				}				
				this.logicBuilderInput.parentObject.put(namespacePrefix + 'RLM_Filter_Logic__c', filterLogic);
			} catch(Exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
			}
		}
	}
	
	private class InvalidFilterException extends Exception{}
	private class InvalidOperatorException extends Exception{}	 
	

}