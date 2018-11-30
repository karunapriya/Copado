/**
 * Created Date     : Sep 28, 2017
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : This controller is used on service source setup page for common search. Added as part of US2810 and US2811,
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                 US2810 and US2811             Oct 23, 2017            1.1                 @description
 *
 */
public with sharing class REN_CommonSearchPageCtrl extends REN_BaseMainController {
	public String selectedParentObject{get; set;}
	public String selectedChildObject {get; set;}
	public List<SelectOption> parentObjectOptions {get; set;}
	public List<SelectOption> relatedObjectOptions {get; set;}
	public Map<String, String> relatedObjectLookupFieldMap {get; set;}
	public REN_LogicBuilderInputWrapper logicBuilderInputWrapper{get; set;}
	public CSM_DataGridAttribute dataGridAttribute{get; set;} 
	public String parentIdCSV{get;set;}
	public String criteria {get; set;}
	public String selCurrency {get; set;}    
	public String fieldSetName {get; set;}    
	public String selectedOpportunityIds{get; set;}
	public boolean isSyncQuoteEnabledOnAnySelectedOpp{get; set;}
	public String syncQuoteEnabledMsg{get; set;}
	public Boolean hasError{get;set;}
	public CSM_HelpLinks__c helpLinkSettings{get; set;} 
	private String selectedRelatedObject{get; set;}
	private REN_Renew_Configuration__c renewConfigObj;
	private String syncQuoteEnabledOpportunities{get; set;}
	private String urlParam{get; set;}
	private Map<String, Set<String>> customSerachSetingsMap;
    private Map<String, string> customSearchParentMap;
	private Map<String, String> customSerachfieldSetMap;
	public boolean noSearch {get;set;}   
	public set<String> noSearchStrings{get;set;}
	private List<sObject> relatedObjectRecordList;
	private boolean hasSyncedPO;
	private String syncPOEnabledOpportunities{get; set;}
    public String noSearchResultString{get;set;}
    public transient String selectedrecords {get;set;}
    public Boolean hasMassTransferAccess {get;set;}
    public String baseNamespace{get;set;}
    public String isLimitError {get;set;}
    public boolean hasMassUpdateFieldSet {get;set;}
    public Integer rsHighWaterMarkLimit {get;set;}
    public Boolean isNotLBError {get;set;}
    
	public REN_CommonSearchPageCtrl(){
		try{
			isNotLBError = false;		
			initializeCustomSerachMap();
			hasMassUpdateFieldSet = false;
			String defaultObjName = ApexPages.currentPage().getParameters().get('objName');
			populateParentObjectOptions();
			if(String.isBlank(selectedParentObject)){
				selectedParentObject = (String.isBlank(defaultObjName) || !customSerachSetingsMap.containsKey(defaultObjName) ) ? CSM_CONSTANTS.OBJ_OPPORTUNITY : defaultObjName;
				callOnParentObjectChange();
			}
			setGridAttributes();
			helpLinkSettings = CSM_AdminDataAccess.getCSMHelpLinksInstance(); 
			this.hasError = false;
            hasMassTransferAccess = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_Mass_Transfer_Opportunities);
            baseNamespace = CSM_Util.getNamespace();
            
            getMassUpdateSetting();
		}catch(Exception e){
			System.debug(e );
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));      
		}
	}

	private void setGridAttributes(){                                
		dataGridAttribute = new CSM_DataGridAttribute();        
		dataGridAttribute.tableName = 'commonSearch';
		dataGridAttribute.objectType ='commonSearch';
		dataGridAttribute.viewName ='commonSearch';
		dataGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
		dataGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
		dataGridAttribute.showExport ='true';
		dataGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
		criteria = '';
		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
		gridInputParams.selectedFilterClause = criteria;
		gridInputParams.gridCurrency = selCurrency;
		dataGridAttribute.params = JSON.serialize(gridInputParams);
		Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		dataGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
	}

	public pageReference callOnParentObjectChange() {
		try{
			hasMassUpdateFieldSet = false;
			isNotLBError = false;	
			selectedRelatedObject = '';
			selectedChildObject = '';
			populateRelatedObjectOptions(selectedParentObject);
			callOnRelatedObjectChange();
			//validateFieldSet(selectedParentObject);
			
			if(String.isNotBlank(selectedParentObject)){
                getMassUpdateSetting();
            }
		}catch(Exception e){
			System.debug(e );
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
		}
		return null;
	}

	public pageReference callOnRelatedObjectChange() {
		try{
			isNotLBError = false;	
			selectedRelatedObject = String.isBlank(selectedChildObject) ? '' : selectedChildObject.substringBefore('.');
			if(String.isBlank(selectedRelatedObject)){
				resetLogicBuilder(selectedParentObject, null);
			}else{
				resetLogicBuilder(selectedRelatedObject, relatedObjectLookupFieldMap.get(selectedRelatedObject));
			}
			this.clearCriteria();
		}catch(Exception e){
			System.debug(e );
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
		}
		return null;
	}

    private void resetLogicBuilder(String childObjectName, String parentLookupFieldApiName){
        String relatedGrandParentObjectName = '';
        if(parentLookupFieldApiName != null){
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(childObjectName).getDescribe().fields.getMap().get(parentLookupFieldApiName).getDescribe();
            String relatedParentObjectName = fieldResult.getReferenceTo()[0].getDescribe().getName();
            relatedGrandParentObjectName = customSearchParentMap.get(relatedParentObjectName);
            if(String.isNotBlank(relatedGrandParentObjectName)){
                Set<String> valueSet = REN_Util.parseFilterValues(relatedGrandParentObjectName);
                String relationString = '';
                for(String value : valueSet){
                    if(parentLookupFieldApiName.endsWithIgnoreCase('__c')){
                        relationString = parentLookupFieldApiName.replace('__c','__r');
                    }else if(parentLookupFieldApiName.endsWithIgnoreCase('Id')){
                        relationString = parentLookupFieldApiName.removeEndIgnoreCase('Id');
                    }
                    relationString += '.'+value;
                    parentLookupFieldApiName += ','+ relationString;
                }
            }
        }else{
            parentLookupFieldApiName = '';
            relatedGrandParentObjectName = customSearchParentMap.get(childObjectName);
            if(String.isNotBlank(relatedGrandParentObjectName)){
                Set<String> valueSet = REN_Util.parseFilterValues(relatedGrandParentObjectName);
                String relationString = childObjectName;
                for(String value : valueSet){
                    parentLookupFieldApiName += ',' + value;
                }
            }
        }
        this.renewConfigObj = new REN_Renew_Configuration__c();
        this.logicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewConfigObj, REN_Constants.OBJ_LC, childObjectName, 
            'CommonSearch_', true, this,'',  'refreshCommonObj', 'onChangeCommonObj', false, String.isBlank(parentLookupFieldApiName)? null : parentLookupFieldApiName);
        this.logicBuilderInputWrapper.lbSingleInstanceKey = 'CommonSearch_SingleInstance';   
    }

	private void populateParentObjectOptions(){

		parentObjectOptions = new List<SelectOption>();
		for(String parentObject: customSerachSetingsMap.keySet()) {
			Schema.SObjectType objType = Schema.getGlobalDescribe().get(parentObject);
			if(objType == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, new String[] {parentObject}) ));
			}else{
				parentObjectOptions.add(new SelectOption(parentObject, objType.getDescribe().getLabelPlural()));
			}
		}
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
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {s})));//Invalid Child relationship
				}else{
					System.debug('\n\n~~~ Child Data: ' + s);
					String[] sArray = s.split('\\.');
					String childObjApiName = sArray[0];//??
					relatedObjectLookupFieldMap.put(childObjApiName, sArray[1]);
					Schema.SObjectType objType = Schema.getGlobalDescribe().get(childObjApiName);
					if(objType == null){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, new String[] {childObjApiName})));
					}else{
						Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
						Schema.SObjectType objectSchema = schemaMap.get(childObjApiName);
						Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
						if(!fieldMap.containsKey(sArray[1])){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {s})));
						}else{
							Schema.DescribeFieldResult descField = fieldMap.get(sArray[1]).getDescribe();
							Schema.DisplayType fieldDataType = descField.getType();
							if(fieldDataType == Schema.DisplayType.Reference){
								List<Schema.SObjectType>  refObjType = descField.getReferenceTo();
								if( refObjType[0] != parentObjType){
									ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {s})));//'Invalid Child object relationship: ' + s + ' with parent Object ' + parentObject
								}else{
									relatedObjectOptions.add(new SelectOption(s, objType.getDescribe().getLabelPlural()));
								}
							}else{
								ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, new String[] {childObjApiName})));
							}
						}
					}
				}
			}
		}
	}
    
    public void displayTransferResult(){
        isNotLBError = true;		
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.LBL_Mass_Update_Success_Message));
    }
	
	public PageReference noResultFound(){
		try{
        	noSearchResultFound();
        }catch(Exception ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + ex.getMessage());
			ApexPages.addMessage(myMsg);
		}
        return null;
    }
    
     private void noSearchResultFound(){  
        REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
        //noSearchStrings = new set<String>();
        noSearchResultString = '';
        
        List<String> searchStringsList = new List<String>();
        Set<String> filterStrSet = new Set<String>();
        Set<Object> filterOptionSet = new Set<Object>();
        Map<Object,String> filterOptionMap = new Map<Object,String>();
        String fieldType = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Field_Type__c'));    
        if(fieldType != 'BOOLEAN')  {      
	        String fieldValue='';
	        fieldValue = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Values__c'));
	        if(String.isBlank(fieldValue)){
	        	filterStrSet = new Set<String>();
	        }else{
	        	filterStrSet =  REN_Util.parseFilterValues(fieldValue);
	        }        
	        if(!String.isBlank(fieldValue)){            
	            for(String strs:filterStrSet){
	                if(String.isNotBlank(strs)){
	                    if(fieldType == CSM_Constants.TYPE_DOUBLE 
	                            || fieldType == CSM_Constants.TYPE_CURRENCY 
	                            || fieldType == CSM_Constants.TYPE_PERCENT){
	                    
	                        filterOptionSet.add(Double.valueOf(strs));
	                        filterOptionMap.put(Double.valueOf(strs),strs);
	                    }else{
	                        filterOptionSet.add(String.Valueof(strs));
	                    }
	                }
	            }       
	        }
	        if(filterStrSet != null && !filterStrSet.isEmpty()){
	        	string fieldNameToRetrive = '';
	            String operatorName = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Operator__c'));
	            if(operatorName==CSM_Constants.OPERATOR_EQUAL || operatorName==CSM_Constants.OPERATOR_LIKE || operatorName==CSM_Constants.OPERATOR_IN){
	            	String relatedFieldName = '';	
					if(String.isNotBlank(selectedRelatedObject)){
						relatedFieldName = relatedObjectLookupFieldMap.get(selectedRelatedObject);						
					}
	            	String fieldName = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Field_Name__c'));
	                fieldNameToRetrive = fieldName;
	                List<String> fieldNameList = fieldName.split('\\.');
	                if(relatedObjectRecordList!=Null){
	                    Object val = null;
	                    for(sObject sObj : relatedObjectRecordList){
	                        val = null;
	                       	if(fieldNameList != null && fieldNameList.size() == 2){
	                        	val = sObj.getSobject(fieldNameList[0]).get(fieldNameList[1]);
	                        }else if(fieldNameList != null && fieldNameList.size() == 3){
	                        	val = sObj.getSobject(fieldNameList[0]).getSobject(fieldNameList[1]).get(fieldNameList[2]);
	                        }
                            else {
                                val = sObj.get(fieldName);
                            }                       
	                        for(Object oVal: filterOptionSet){
	                            //system.debug(oVal + ' == '+val);
	                            if(operatorName==CSM_Constants.OPERATOR_LIKE && fieldType == CSM_Constants.TYPE_STRING){
	                                if(String.ValueOf(val).containsIgnoreCase(String.ValueOf(oVal))){
	                                    filterOptionSet.remove(oVal);
	                                }
	                            }else if(fieldType == CSM_Constants.TYPE_STRING){
	                                if(String.ValueOf(val).equalsIgnoreCase(String.ValueOf(oVal))){
	                                    filterOptionSet.remove(oVal);
	                                }
	                            }else if(val.equals(oVal)){
	                            	 if(String.isNotBlank(selectedRelatedObject)){
										if(sObj.get(relatedFieldName)!=null){
		                                	filterOptionSet.remove(oVal);
		                                	filterOptionMap.remove(oVal);
		                                	break;
										}
	                            	}else{
	                            	 	filterOptionSet.remove(oVal);
	                                	filterOptionMap.remove(oVal);
	                                	break;
	                            	 }
	                            }
	                        }
	                    }
	                }
	                system.debug('filterOptionSet-> '+filterOptionSet);               
	                for(Object s:filterOptionSet) {
	                    if(fieldType == CSM_Constants.TYPE_DOUBLE 
	                            || fieldType == CSM_Constants.TYPE_CURRENCY 
	                            || fieldType == CSM_Constants.TYPE_PERCENT){
	                        //noSearchStrings.add(filterOptionMap.get(s));
	                        noSearchResultString +=   filterOptionMap.get(s) + '<br/>'  ;//Added for DE3031
	                    }else{
	                        //noSearchStrings.add(String.ValueOf(s));
	                        noSearchResultString +=   String.ValueOf(s) + '<br/>'  ; //Added for DE3031
	                    }
	                }
	                //system.debug('noSearchStrings->'+noSearchStrings);
	            }
	        }
            for(Integer i=selectedCtrl.criteriaWrapperList.size()-1;i>0;i--){
                if(selectedCtrl.criteriaWrapperList.get(i) != Null){
                    selectedCtrl.criteriaWrapperList.remove(i);
                }
            }
        }
    }
    
	public PageReference findFor(){
		try{
			isNotLBError = false;		
			this.hasError = false;
			isLimitError = 'false';
		    Set<String> firstFilterSet = new Set<String>();
		    noSearch=false;
			REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
			renewConfigObj.RLM_Currency_Code__c = selectedCtrl.corpCurr;
			selectedCtrl.logicBuilderInput.isBulkSearch = true;
			selectedCtrl.logicBuilderInput.firstFilterSet = firstFilterSet;
			Set<String> relatedFieldsSet = new Set<String>{};
			relatedObjectRecordList = new List<sObject>();
			checkForSingleCriteria(selectedCtrl);
			String fieldNameToRetrive = ''; 
			if(noSearch){
				fieldNameToRetrive = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Field_Name__c'));           								
    			relatedFieldsSet.add(fieldNameToRetrive);
    		}
			
			if(selectedCtrl != null){
				selectedCtrl.performSave();
				if(!ApexPages.hasMessages()){
					String relatedFieldName;					
					parentIdCSV = '';   
					String objName = String.isNotBlank(selectedRelatedObject)? selectedRelatedObject : selectedParentObject;
					String fieldSetMapKey = String.isNotBlank(selectedChildObject)? selectedChildObject : selectedParentObject;
					fieldSetName = customSerachfieldSetMap.get(fieldSetMapKey);
					fieldSetName = String.isBlank(fieldSetName) ? '' : fieldSetName;
					Integer recordLimit = 10000; //Added for DE3039
					Integer customSearchLimit = (Integer)CSM_Admin__c.getInstance().REN_Custom_Search_Records_Limit__c;
					if(String.isNotBlank(selectedRelatedObject)){
						relatedFieldName = relatedObjectLookupFieldMap.get(selectedRelatedObject);
						if(String.isNotBlank(relatedFieldName)){
							relatedFieldsSet.add(relatedFieldName);
						}
					}
					recordLimit = (String.isBlank(selectedRelatedObject) || selectedRelatedObject == selectedParentObject) ?  customSearchLimit: recordLimit;
					recordLimit++;
					if(relatedFieldsSet == null || relatedFieldsSet.isEmpty()){
						relatedFieldsSet.add('Id');
					}
					List<sObject> relatedObjList = REN_OpportunityDataAccess.getObjectRecordsList(objName, relatedFieldsSet, firstFilterSet,renewConfigObj.REN_Filter_Criteria__c, false,recordLimit);
					if(noSearch){
						relatedObjectRecordList = relatedObjList;
					}
					List<sObject> parentRecList = new List<sObject>();
					Set<String> parentIdSet = new Set<String>();
					if(relatedObjList != null){
						parentIdSet = getParentRecIds(relatedObjList,relatedFieldName);
						parentIdCSV = JSON.serialize(parentIdSet);
					}
					System.debug(relatedObjList.size() + '\n\n2~~~~parentIdSet.size(): ' + parentIdSet.size());
					if(parentIdSet.size() >= recordLimit){
						isLimitError ='true';
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,String.format(Label.REN_CUSTOM_SEARCH_LIMIT_ERROR, new String[]{String.valueOf(customSearchLimit)})));
					}
					setGridAttributes();
					
				}
                if(selectedCtrl.criteriaWrapperList != null && selectedCtrl.criteriaWrapperList.size() < 3){
                    selectedCtrl.populateDefaultCriteria();
                }
			}
		}
		catch(Exception ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + ex.getMessage());
			ApexPages.addMessage(myMsg);
		}
		return null;
	}

	private void checkForSingleCriteria(REN_LogicBuilderCmpCtrl selectedCtrl){                    
        String namespacePrefix = CSM_Util.getNamespace();
        String operatorName = '';
		String fieldType = '';
        List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper> criteriaWrapperListNew = new List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper>();
        for (REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper wrapper :selectedCtrl.criteriaWrapperList){
            String fieldName = String.valueOf(wrapper.criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
            if(wrapper.criteria!= null&& !fieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)){
                criteriaWrapperListNew.add(wrapper);
            }
        }
        if(criteriaWrapperListNew != null && !criteriaWrapperListNew.isEmpty()){
        	operatorName = String.valueOf(criteriaWrapperListNew[0].criteria.get(namespacePrefix + 'RLM_Operator__c'));
        	fieldType = String.valueOf(criteriaWrapperListNew[0].criteria.get(namespacePrefix + 'RLM_Field_Type__c')); 
        }
        if(criteriaWrapperListNew != null && criteriaWrapperListNew.size() == 1 
        		&& (operatorName == CSM_Constants.OPERATOR_EQUAL
					|| operatorName	== CSM_Constants.OPERATOR_LIKE
					|| operatorName	==	CSM_Constants.OPERATOR_IN) && fieldType != 'BOOLEAN'){
            noSearch=true;
		}
        selectedCtrl.criteriaWrapperList = criteriaWrapperListNew;
	}
	
	private REN_LogicBuilderCmpCtrl findLogicBuilderInstance(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		system.debug('baseChildControllerMap $$$$$$$ '+baseChildControllerMap);
		if(baseChildControllerMap != null && !baseChildControllerMap.isEmpty()){
			return (REN_LogicBuilderCmpCtrl )(baseChildControllerMap.values()[0]);
		}else{
			return null;
		}
	}

	private Set<String> getParentRecIds(List<sObject> relatedObjList, String relatedFieldName){
		Set<String> parentIdSet = new Set<String>();
		relatedFieldName = String.isBlank(relatedFieldName) ? 'id' : relatedFieldName;
		if(relatedObjList != null){
			Set<String> parentObjIdSet = new Set<String>();
			for(sObject obj: relatedObjList){
				ID parentObjId = (ID)obj.get(relatedFieldName);
				if(String.isNotBlank(parentObjId)){
					parentIdSet.add(parentObjId);
				}
			}
		}
		return parentIdSet;
	}

	private void clearCriteria(){
		REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
		if(selectedCtrl != null){
			if(selectedCtrl.criteriaWrapperList != null){
				selectedCtrl.criteriaWrapperList = null;
				selectedCtrl.fieldListByLogicBuilderExtName = null;
				selectedCtrl.logicBuilderInput = logicBuilderInputWrapper;
			}
		}
	}  
	
	public PageReference redirectToConsolidate(){
		PageReference pageRef = Page.REN_ConsolidateOpportunity;
		pageRef.getParameters().put('opptyIds', this.selectedOpportunityIds);
		PageReference returnPageRef = Page.REN_CommonSearchPage;					
		String retURL = returnPageRef.getUrl();
		pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
		return pageRef;
	}
	//This method is used to set selectedRecords variable
    public void transferOpportunity(){}
    
	public PageReference consolidateOpportunity(){
		system.debug('@@@@@@@@ consolidateOpportunity :: ' );
		this.hasError = false;
		isNotLBError = false;		
		PageReference pageRef = null;
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
	    	//hasSyncedPO = poList != null && !poList.isEmpty() ? true : false;	  
	    	
			if (validateSelectedOpportunities(oppIdSet, opptyToPOMap)) {
				isNotLBError = false;
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
				this.hasError = true;
				isNotLBError = true;
				
			}
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.MSG_AT_LEAST_ONE, new String[]{Schema.SObjectType.Opportunity.label})));
		}
		return pageRef;
	}

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

	public void initializeCustomSerachMap(){
		customSerachSetingsMap = new Map<String, Set<String>> ();
		customSerachfieldSetMap = new Map<String, String>();
        customSearchParentMap = new Map<String, String>();
		Map<String, REN_Custom_Search_Config__c> customSearchObjMap = REN_Custom_Search_Config__c.getAll();
		if(customSearchObjMap != null && !customSearchObjMap.isEmpty()){
			for(REN_Custom_Search_Config__c custSearchObj : customSearchObjMap.values()){
				if(!customSerachSetingsMap.containsKey(custSearchObj.REN_Parent_Object__c)){
					customSerachSetingsMap.put(custSearchObj.REN_Parent_Object__c, new Set<String>());
				}
				if(String.isNotBlank(custSearchObj.REN_Related_Object__c)){
					customSerachSetingsMap.get(custSearchObj.REN_Parent_Object__c).add(custSearchObj.REN_Related_Object__c);
				}
                //Defined grandparent relation in parent objects
                if(String.isBlank(custSearchObj.REN_Related_Object__c) && String.isNotBlank(custSearchObj.REN_Grandparent_Relation__c)){
                    Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(custSearchObj.REN_Parent_Object__c).getDescribe().fields.getMap().get(custSearchObj.REN_Grandparent_Relation__c).getDescribe();
                    if(fieldResult.getReferenceTo().isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {custSearchObj.REN_Grandparent_Relation__c})));
                    }else{
						customSearchParentMap.put(custSearchObj.REN_Parent_Object__c,custSearchObj.REN_Grandparent_Relation__c);
                    }
                }
				customSerachfieldSetMap.put(String.isNotBlank(custSearchObj.REN_Related_Object__c) ? custSearchObj.REN_Related_Object__c : custSearchObj.REN_Parent_Object__c, custSearchObj.REN_Field_Set_API_Name__c);
			}
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.REN_LBL_CUSTOM_SETTING_ERROR_MSG));
		}
	}
	
	private void getMassUpdateSetting(){
        REN_Custom_Search_Config__c searchConfigObj = REN_Custom_Search_Config__c.getValues(selectedParentObject);
                
        if(searchConfigObj != null && searchConfigObj.REN_Mass_Update_FieldSet_Name__c != null){
            if(Schema.getGlobalDescribe().get(selectedParentObject).getDescribe().fieldSets.getMap().containsKey(searchConfigObj.REN_Mass_Update_FieldSet_Name__c)){
                hasMassUpdateFieldSet = true;
            }
            
            if(searchConfigObj.REN_RS_High_Watermark_Threshold__c != null){
                rsHighWaterMarkLimit = (Integer)searchConfigObj.REN_RS_High_Watermark_Threshold__c;
            }
        }
    }

}