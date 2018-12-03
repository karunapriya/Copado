public with sharing class REN_GroupingLogicBuilder extends REN_BaseChildController{
	
	
	private Map<String, List<SelectOption>> fieldListByLogicBuilderExtName;
	private Map<String, FieldDescribedWrapper> fieldWrapperByLogicBuilderExtName;
	private Map<String, Map<String, FieldDescribedWrapper>> objfieldWrapperByLogicBuilderExtName;
	private List<SelectOption> sofieldList;
	public List<REN_LineCriteriaWrapper> criteriaWrapperList {get; set;}
	public String guidToCompare {get; set;}
	public List<SelectOption> soDateStringLiteral{get; private set;}
	public Boolean isValidCSMCriteria {get; set;}
    public String corpCurr {get; set;}
    public String strCriteria {get; set;}    
    public List<SelectOption> currList {get; set;} 
	public Boolean mcEnabled {get; set;}	
	public String relatedFieldsAPI;
	public Boolean viewUserLookup {get;set;}
	public String namespacePrefix;
	public Integer lineNumber  {get; set;}
	private List<SObject> criteriaToDelete = new List<SObject>();	
    public REN_GroupingLogicBuilder() {
    	super();
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
						this.objectNameSuper = logicBuilderInput.logicBuilderExtName 
												+ '_' 
												+ logicBuilderInput.logicBuilderObject;
						this.baseMainController = logicBuilderInput.baseMainController;
						relatedFieldsAPI = logicBuilderInput.relatedFields;
						getfieldWrapperByLogicBuilderExtName(logicBuilderInput.logicBuilderObject);
						this.criteriaWrapperList = new List<REN_LineCriteriaWrapper>();
						system.debug('---------IN-------------');
						populateCriteria();
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

	public List<SelectOption> getOperatorList() {
		List<SelectOption> operatorList = new List<SelectOption>();
		operatorList.add(new SelectOption('=', '='));
		operatorList.add(new SelectOption('>=', '>='));
		operatorList.add(new SelectOption('<', '<'));
		operatorList.add(new SelectOption('<=', '<='));
		operatorList.add(new SelectOption('!=', '!='));
		operatorList.add(new SelectOption('LIKE', 'LIKE'));
		operatorList.add(new SelectOption('IN', 'IN'));
		operatorList.add(new SelectOption('NOT IN', 'NOT IN'));
		if(!Test.isRunningTest()){
			if(this.logicBuilderInput.logicBuilderExtName == REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT || this.logicBuilderInput.logicBuilderExtName == REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT){
				operatorList.add(new SelectOption('ALL', 'ALL'));
			}
		}
		return operatorList;
	}
	
	public List<SelectOption> getFieldList() {
        try {  
        	 set<String> setIgnoreFields = new set<String>();
			 setIgnoreFields.add(REN_Constants.REN_CURRENCY_ISO_CODE);
			 setIgnoreFields.add(REN_Constants.OBJ_OPP_FORECAST_CATEGORY_2);
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
                    system.debug('fieldWrapperByLogicBuilderExtName--->'+fieldWrapperByLogicBuilderExtName);
                    for(FieldDescribedWrapper fdw : fieldWrapperByLogicBuilderExtName.values()) {  
                    	if(!setIgnoreFields.contains(fdw.selectedFieldAPIName)){
		 					selectOptionSet.add(fdw.fieldSO);
		 				}
                    }
                    soFieldList.addAll(selectOptionSet);
		            CSM_Util.sortSelectOptionByLabel(soFieldList);
                }
	                
				fieldListByLogicBuilderExtName.put(this.objectNameSuper, soFieldList);
			}
			CSM_Util.sortSelectOptionByLabelRelatedFields(soFieldList);
            return soFieldList;
        }
        catch (Exception ex) {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }  
	
	public void performSave(){
		List<SObject> criteriaList = new List<SObject>();
		for(REN_LineCriteriaWrapper r: criteriaWrapperList){
			if(r.criteria!= null){
				criteriaList.add(r.criteria);
			}
		}
		
		if(!criteriaToDelete.isEmpty()) {
	    	if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
	    		REN_LineCriteriaDataAccess.deleteLineCriteria(criteriaToDelete);	    		
	    	}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
				CSM_PlayCriteriaDataAccess.deletePlayCriteria((List<CSM_Play_Criteria__c>) criteriaToDelete);
	    	}else{
				CSM_FocusCategoryViewCriteriaDataAccess.deleteFCVCriteria((List<CSM_Focus_Category_View_Criteria__c>) criteriaToDelete);	    		
	    	}
	    }
	    this.saveConfigAndCriterias(criteriaList);
	}
	
	public void performFind()	{
		this.performSave();
	}
	
	private void saveConfigAndCriterias(List<SObject> criteriaList){
		if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
			REN_RenewConfigurationDataAccess.saveRenewConfiguration(new List<REN_Renew_Configuration__c>{(REN_Renew_Configuration__c)this.logicBuilderInput.parentObject});
			List<REN_Line_Criteria__c> criteriaListToUpsert = new List<REN_Line_Criteria__c>();
			if(!criteriaList.isEmpty()){
				String filterCriteria='';
				integer lstLength=0;
				Boolean upsertFlag=true;
				Set<String> fieldNameSet = new set<String>();
				for (SObject criteria : criteriaList) {
					lstLength++;
					if (criteria.get('REN_Renew_Configuration__c') == null && this.logicBuilderInput.parentObject.Id != null){
						criteria.put('REN_Renew_Configuration__c', this.logicBuilderInput.parentObject.Id);
						if(fieldNameSet.contains(String.valueOf(criteria.get('RLM_Field_Name__c')))){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_NOT_ALLOW_SAVE_DUPLICATE + criteria.get('RLM_Field_Name__c')));
							upsertFlag=false;
						}else{
							fieldNameSet.add(String.valueOf(criteria.get('RLM_Field_Name__c')));
							if(String.valueOf(criteria.get('RLM_Field_Name__c')) == 'Name'){
								criteria.put('RLM_Field_Display_Name__c','Asset Name');
							}
							if(lstLength<criteriaList.size())
							filterCriteria += criteria.get('RLM_Field_Name__c') +', ';
							else
							filterCriteria += criteria.get('RLM_Field_Name__c');
						}
					}
					else{
						if(fieldNameSet.contains(String.valueOf(criteria.get('RLM_Field_Name__c')))){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_NOT_ALLOW_SAVE_DUPLICATE + criteria.get('RLM_Field_Name__c')));
							upsertFlag=false;
						}else{
							
							fieldNameSet.add(String.valueOf(criteria.get('RLM_Field_Name__c')));
							if(String.valueOf(criteria.get('RLM_Field_Name__c')) == 'Name'){
								criteria.put('RLM_Field_Display_Name__c','Asset Name');
							}
							if(lstLength<criteriaList.size())
							filterCriteria += criteria.get('RLM_Field_Name__c') +', ';
							else
							filterCriteria += criteria.get('RLM_Field_Name__c');
						}
						
					}
					if(upsertFlag){
						criteriaListToUpsert.add((REN_Line_Criteria__c)criteria);
					}
				}
				REN_LineCriteriaDataAccess.upsertLineCriterias(criteriaListToUpsert);
				REN_Renew_Configuration__c rc=new REN_Renew_Configuration__c(Id=this.logicBuilderInput.parentObject.Id);
				rc.REN_Filter_Criteria__c=filterCriteria;
				REN_RenewConfigurationDataAccess.saveRenewConfiguration(new List<REN_Renew_Configuration__c>{rc});
				
			}
		}
	}
		
	public PageReference newCriteria() {
    	SObject newCriteriaObject;
    	if(this.logicBuilderInput.criteriaObject.equals(REN_Constants.OBJ_LC)){
    		newCriteriaObject = new REN_Line_Criteria__c(REN_Renew_Configuration__c = this.logicBuilderInput.parentObject.Id);
    	}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_FCV_CRITERIA)){
    		newCriteriaObject = new CSM_Focus_Category_View_Criteria__c(CSM_Focus_Category_View__c = this.logicBuilderInput.parentObject.Id);
    	}else if(this.logicBuilderInput.criteriaObject.equals(CSM_Constants.OBJ_PLAY_CRIT)){
    		newCriteriaObject = new CSM_Play_Criteria__c(CSM_Play__c = this.logicBuilderInput.parentObject.Id);
    	}
    	criteriaWrapperList.add(new REN_LineCriteriaWrapper(newCriteriaObject, fieldWrapperByLogicBuilderExtName, 
									criteriaWrapperList.size()+1, 
									this.logicBuilderInput.logicBuilderObject, null, '', null, 
									CSM_Util.NewGuid(), this.logicBuilderInput.criteriaObject));
		return null;
	}
	
    public PageReference deleteCriteria() {
    	try {
    		if(guidToCompare != null) {
	    		for(integer i=0; i< criteriaWrapperList.size(); i++){
	    			if(guidToCompare == criteriaWrapperList[i].guid){
	    				if(criteriaWrapperList[i].criteria!=null && criteriaWrapperList[i].criteria.id != null){
	    					criteriaToDelete.add(criteriaWrapperList[i].criteria);
	    				}
	    				criteriaWrapperList.remove(i);
	    				break;
	    			}	
	    		}
	    	}
	    	
	    	
			for (Integer i=0; i<criteriaWrapperList.size(); i++){
				REN_LineCriteriaWrapper criteriaWrapper = criteriaWrapperList.get(i);
				criteriaWrapper.criteria.put('RLM_LineNo__c', i+1);
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
		public REN_LineCriteriaWrapper(SObject criteriaVal, Map<String,FieldDescribedWrapper> fieldWrapperByLogicBuilderExtNameVal, 
										Integer num, String objectName, String fAPIName, String fv, 
										String operator, String newGuid, String criteriaObject) {
			this.criteria = criteriaVal;
			guid = newGuid;
			namespacePrefix = CSM_Util.getNamespace();
			fieldWrapperByLogicBuilderExtName = fieldWrapperByLogicBuilderExtNameVal;
			String objApiName = criteria.get(namespacePrefix + 'RLM_Field_Name__c') == null?null:(String)criteria.get(namespacePrefix + 'RLM_Field_Name__c');
			FieldDescribedWrapper fdw;
			if (fieldWrapperByLogicBuilderExtName!= null && objApiName != null && 
				fieldWrapperByLogicBuilderExtName.containsKey(objApiName)){
				fdw = fieldWrapperByLogicBuilderExtName.get(objApiName);
			}
			if (fdw != null && (fdw.dataType == CSM_Constants.TYPE_MULTIPICKLIST ||  fdw.dataType == CSM_Constants.TYPE_PICKLIST)){
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
		for(REN_LineCriteriaWrapper wrapper : this.criteriaWrapperList){
			String fieldApiName = wrapper.criteria.get('RLM_Field_Name__c') == null?null:(String)wrapper.criteria.get('RLM_Field_Name__c');
			if(fieldWrapperByLogicBuilderExtName.containsKey(fieldApiName)){
				FieldDescribedWrapper fdw = fieldWrapperByLogicBuilderExtName.get(fieldApiName);
				wrapper.criteria.put('RLM_Field_Type__c', fdw.dataType);
				wrapper.criteria.put('RLM_Field_Display_Name__c', fdw.displayName);
				system.debug('wraplist - ' + wrapper.criteria);				
				if (fdw.dataType == CSM_Constants.TYPE_MULTIPICKLIST || fdw.dataType == CSM_Constants.TYPE_PICKLIST){
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

		return null;
	}
	
	
	public PageReference rerenderTable(){	
    	return null;
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
	}
	
	private void getfieldWrapperByLogicBuilderExtName(String objectName) {
		Set<String> relatedFieldstoDisplay;
		objfieldWrapperByLogicBuilderExtName = new Map<String, Map<String, FieldDescribedWrapper>>();
		fieldWrapperByLogicBuilderExtName = new Map<String, FieldDescribedWrapper>();
		if (!objfieldWrapperByLogicBuilderExtName.containsKey(objectName)){
	        List<Schema.SObjectField> fieldListValues = CSM_AccessController.getInstance().returnPermissionFieldsNameList(objectName);
	        populateFldWrappper(fieldListValues,objectName,'','');
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
		system.debug('--NO-->refField--'+relatedFieldstoDisplay);
		for(String refField: relatedFieldstoDisplay){
			system.debug('--NO-->refField--'+refField);
			if(refField.contains('.')){
				system.debug('---->refField--'+refField);
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
							populateFldWrappper(fieldListValues,objectName,relatedFieldName,relationshipName);
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
							populateFldWrappper(fieldListValues,objectName,relatedFieldName,relationshipName);
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
					populateFldWrappper(fieldListValues,objectName,relatedFieldName,relationshipName);
				}
			}
		}
	}
	
	private void populateFldWrappper(List<Schema.SObjectField> fieldListValues,String objectName, String relatedFieldName,String relationshipName){
		system.debug('objectName---->'+objectName);
		String fieldLabel;
		String fieldName;
		String strName;
		FieldDescribedWrapper fieldWrapper;
		for( Schema.SObjectField tmpfield :fieldListValues) {
			List<SelectOption> pickListOptions = new List<SelectOption>();		        	   
			if (!String.valueOf(tmpfield).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
					!String.valueOf(tmpfield).toLowerCase().contains(CSM_Constants.CONTRACT_ID)){
				DescribeFieldResult tmpResult = tmpfield.getDescribe();
				DisplayType fieldDisplayType = tmpResult.getType();
				fieldLabel = tmpResult.getLabel();
				fieldName = tmpResult.getName();  
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
						|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_REFERENCE)) {
							system.debug('--------------1---------');
					if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_MULTIPICKLIST || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST) {
						system.debug('--------------2in---------');
						List<Schema.PicklistEntry> pleList = tmpResult.getPicklistValues();			            
						for (Schema.PicklistEntry a : pleList) { 
								pickListOptions.add(new SelectOption(a.getLabel(), a.getValue())); 
							}			            
							system.debug('--------------2out---------');
	                  }
					if(String.isNotBlank(relatedFieldName)&& String.isNotBlank(relationshipName)){
						system.debug('--------------3in---------');
						fieldLabel = relatedFieldName+': '+tmpResult.getLabel();
						fieldName = relationshipName+'.'+tmpResult.getName();
						system.debug('--------------3 out---------');
					}
										
				    if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_REFERENCE && viewUserLookup){
				    	system.debug('--------------4in---------');
						for(Schema.SObjectType ref : tmpResult.getReferenceTo()){
							 strName = ref.getDescribe().getName();
						}
						if(String.isNotBlank(strName)&&strName.toUpperCase() == 'USER'){
		    				    fieldWrapper = new FieldDescribedWrapper(objectName, 
																		fieldLabel, 
																		fieldName, 
																		String.valueOf(fieldDisplayType), pickListOptions);
																		system.debug('--------------4out---------');
						}
		              } else if(String.valueOf(fieldDisplayType) != CSM_Constants.TYPE_REFERENCE){
		              	system.debug('--------------5in---------');
    				    fieldWrapper = new FieldDescribedWrapper(objectName, 
																fieldLabel, 
																fieldName, 
																String.valueOf(fieldDisplayType), pickListOptions);
																system.debug('--------------5out---------');
                      }
	                	        system.debug('fieldWrapper---->'+fieldWrapper);
                      if(fieldWrapper != null){
	    				 fieldWrapperByLogicBuilderExtName.put(fieldName, fieldWrapper);
	    				 system.debug('fieldWrapperByLogicBuilderExtName---->'+fieldWrapperByLogicBuilderExtName);
			              objfieldWrapperByLogicBuilderExtName.put(objectName, fieldWrapperByLogicBuilderExtName);
                      }
	                }
				}                       
	        }
	}
	
}