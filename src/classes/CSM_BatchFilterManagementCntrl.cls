/**
 * Created Date		: Nov 1, 2016
 * Developed By		: Nidhi, Comity Designs, Inc.
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
 * Nidhi					US1481				Nov 1, 2016			1.1					@description
 *
 */

public with sharing class CSM_BatchFilterManagementCntrl extends REN_BaseMainController{
	public Boolean isEdit {get; set;}
	public String helpParam {get;set;}
	public String tabCategory {get; set;}	
	public String selectedBatchName{get; set;}
	public String objectName{get; set;}
	public String endBoundaryCriteria {get; set;}
	public Boolean showReadOnly{get; set;}
	public String sectionHeader {get; set;}
	public Set<String> objNameSet {get; set;}
	public CSM_Batch_Filter__c batchFilterObj {get; set;}
	public List<SelectOption> batchNameOptionSet{set;}
	public Map<String,REN_LogicBuilderInputWrapper> lbInputWrapperMap {get; set;}

	public CSM_BatchFilterManagementCntrl(){
		isEdit = false;
		showReadOnly = false;
		helpParam = CSM_Constants.HELP_BATCH_FILTER_ACTIVITY;
		List<SelectOption> option = getbatchNameOptionSet();
		Map<String,String> batchNameMap = getJobNameandObjMap();
		if(!option.isEmpty()){
			objectName = batchNameMap.get(String.valueOf(option[0].getValue()));
		}
		endBoundaryCriteria = 'LAST_N_DAYS:365';
		String batchFilterId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		populateBatchFilterInfo(batchFilterId);
	}

	/**
	 * @description : This method is used to fetch value from custom custom setting "CSM_BatchJobs__c" and create map accordigly.
	 * @Return : Map as Key i.e Dispatcher class and value i.e Object name.
	*/
	public Map<String,String> getJobNameandObjMap(){
		Map<String,String> batchNameMap = new map<String,String>();
		Map<string, CSM_BatchJobs__c> mcs = CSM_BatchJobs__c.getAll();
		for(String key : mcs.keySet() ){
			CSM_BatchJobs__c customObj = mcs.get(key);
			batchNameMap.put(customObj.CSM_BatchJobName__c,customObj.CSM_ObjectName__c);
		}
		return batchNameMap;
	}

	/**
	 * @description : This method is used to create instance of logic builder as per object exist in custom setting "CSM_BatchJobs__c".
	*/
	public void populateBatchFilterRec(){

		lbInputWrapperMap = new Map<String,REN_LogicBuilderInputWrapper>();
		REN_LogicBuilderInputWrapper lbInputWrapper;
		objNameSet = new Set<String>();
		Map<String,String> batchNameMap = getJobNameandObjMap();
		List<String> objNameList = new List<String>();
		objNameList.addAll(batchNameMap.values());
		objNameSet.addAll(objNameList);
		for (String objName : objNameList){
			lbInputWrapper = new REN_LogicBuilderInputWrapper(batchFilterObj,'CSM_Batch_Filter_Criteria__c', objName, objName, false, this,'', 'refreshLB1', 'onChangeDate1',true,'');
			lbInputWrapperMap.put(objName,lbInputWrapper);
		}
		system.debug('\n\n ~~~~~~~~~~~` lbInputWrapperMap :: ' + lbInputWrapperMap);
	}

	/**
	 * @description : This method is used to create Apex Job picklist values.
	*/
	public List<SelectOption>  getBatchNameOptionSet(){
		Map<String,String> batchNameMap = getJobNameandObjMap();
		Set<String> batchNameSet = batchNameMap.keyset() ;
		List<SelectOption>  batchNameOptionSetTemp = new List<SelectOption>();
		for(String  str : batchNameSet){
			SelectOption objectToAdd = new SelectOption(str, str);
			batchNameOptionSetTemp.add(objectToAdd); 
		}
		system.debug('\n\n ~~~~~~~~~~~` batchNameOptionSetTemp :: ' + batchNameOptionSetTemp);
		return batchNameOptionSetTemp;
	}

	/**
	 * @description : This method is used to reset object name field as per the changed apex Job list value.
	*/
	public PageReference resetObjectName(){
		Map<String,String> batchNameMap = getJobNameandObjMap();
		objectName = batchNameMap.get(selectedBatchName);
		populateBatchFilterRec();
		return null;
	}

	/**
	 * @description : Builds the Batch Filter object. If param is null, creates new, otherwise edit existing.
	*/
	private void populateBatchFilterInfo(String batchFilterId) {
		try{
			if(!String.isEmpty(batchFilterId)){
				List<CSM_Batch_Filter__c> batchFilterList = CSM_BatchFilterDataAccess.getBatchFilterById(new Set<String>{batchFilterId});
				if(batchFilterList != null && !batchFilterList.isEmpty()){
					batchFilterObj = batchFilterList[0];
					setBatchFilterEdit();
				}
			} else {
				batchFilterObj = new CSM_Batch_Filter__c();
				sectionHeader = Label.CSM_LBL_CREATE_BATCH_FILTER;
				populateBatchFilterRec();
			}
		}catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}

	public PageReference saveAndNew(){
		String errMsg;
		try {
			batchFilterSave();
		}catch(Exception ex){
			errMsg = ex.getMessage();
			system.debug(batchFilterObj + '\n\n'+ ex);
			system.debug(ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  REN_Util.getGenericErrorMessage(ex, null)));
		}
		if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
			PageReference pageRef = Page.csm_batchfiltermanagement;
			pageRef.getParameters().put('tabCategory','SuccessPlan');
			pageRef.setRedirect(true);
			return pageRef;
		}
		return null;
	}

	/**
	 * @description : This method is used to create SQOL Query as per the seleted Object with all the conditon specified in logic Builder and End Boundary.
      @Return : List of Batch Filter 
	*/
	@TestVisible
	private List<CSM_Batch_Filter__c> createBatchFilterCrtieria(String strCriteria){
		List<CSM_Batch_Filter__c> batchFilterList = new List<CSM_Batch_Filter__c>();
		String finalQueryString;
		string nameSpace = CSM_UTIL.getNamespace();
		String additionalCondition = ''; //Used for adding additional condition which is in Batch query
		system.debug('\n\n batchFilterObj.CSM_Object_Name__c ::' + batchFilterObj.CSM_Object_Name__c);
		if(batchFilterObj.CSM_Object_Name__c.equalsIgnoreCase('Account')){
			finalQueryString = 'select id,Name from Account ';
			additionalCondition = ' AND Id in (select ' + namespace +'CSM_AccountId__c  from ' + namespace + 'CSM_Account_Plan__c)';
		}
		else if (batchFilterObj.CSM_Object_Name__c.equalsIgnoreCase('Opportunity')){
			finalQueryString = 'select id, accountId from Opportunity ';
			additionalCondition = ' AND AccountId in ( Select ' + + namespace +'CSM_AccountId__c FROM ' + namespace + 'CSM_Account_Plan__c)';
		} 
		else if (batchFilterObj.CSM_Object_Name__c.equalsIgnoreCase('CSM_Account_Plan__c')){
			finalQueryString = 'select id,'+ namespace + 'CSM_AccountId__c from ' + namespace + 'CSM_Account_Plan__c';
		}
		else if (batchFilterObj.CSM_Object_Name__c.equalsIgnoreCase('Case')){
			finalQueryString = 'select id, AccountId from Case ';
			additionalCondition = ' AND AccountId in ( Select ' + namespace +'CSM_AccountId__c FROM ' + namespace + 'CSM_Account_Plan__c)'; 
		}
		else if (batchFilterObj.CSM_Object_Name__c.equalsIgnoreCase('CSM_Survey_Response__c')){
			finalQueryString = 'select id, ' + nameSpace +'CSM_Account__c from ' +  nameSpace + 'CSM_Survey_Response__c';
			additionalCondition = ' AND ' + namespace + 'CSM_Account__c  in (Select CSM_AccountId__c FROM CSM_Account_Plan__c) ';
		}    
		finalQueryString += ' where LastModifiedDate = '  
			+ endBoundaryCriteria + '\n' 
			+ additionalCondition
			+ (String.isBlank(strCriteria) ? '' : ' AND (' + strCriteria + ') ')
			+ ' Limit 10000';	
		batchFilterObj.CSM_Query_Criteria__c = finalQueryString;
		batchFilterList.add(batchFilterObj);
		system.debug('\n\n ~~~~~~~~~~~` batchFilterList :: ' + batchFilterList);
		return batchFilterList;
	}

	/**
	 * @description : This method is used to save the Batch Filter and Batch Filter Criteria object.
	 */
	public PageReference batchFilterSave(){
		String errMsg;
		try {
			if(String.isBlank(batchFilterObj.CSM_Display_Name__c)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.CSM_LBL_NAME_VALIDATION_MESSAGE, new String[]{'View Name'})));
				return null;
			}
			/*if((!String.isBlank(selectedBatchName) && batchFilterObj.CSM_IsActive__c) ){
				List<CSM_Batch_Filter__c> batchActiveFilterList = CSM_BatchFilterDataAccess.getBatchFilterByJobName(new Set<String>{selectedBatchName});
				if(!batchActiveFilterList.isEmpty()){
					if(isEdit){
						if(batchActiveFilterList[0].id != batchFilterObj.id){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.CSM_LBL_ACTIVE_VALIDATION_MESSAGE, new String[]{'View Name'})));
					       return null;
						}
					}else{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.CSM_LBL_ACTIVE_VALIDATION_MESSAGE, new String[]{'View Name'})));
					return null;
					}
				}
			}*/
			system.debug((objectName + '_' + objectName)+ '\n\n **** check 1'+ getBaseChildControllerMap().keySet());

			REN_LogicBuilderCmpCtrl selectedCtrl = (REN_LogicBuilderCmpCtrl)getBaseChildControllerMap().get(objectName + '_' + objectName);
			selectedCtrl.performSave();
			Boolean isValidCriteria = selectedCtrl.isValidCSMCriteria;
			String strCriteria = selectedCtrl.strCriteria;
			
			
			setFilterObjValues();
			List<CSM_Batch_Filter__c> filterList = createBatchFilterCrtieria(strCriteria);
			CSM_BatchFilterDataAccess.saveBatchFilter(filterList);

			if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){ 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{batchFilterObj.CSM_Object_Name__c + ' Record Filter'})));
			    showReadOnly = true;
			}
		}catch(Exception ex){
			errMsg = ex.getMessage();
			system.debug(batchFilterObj + '\n\n'+ ex);
			system.debug(ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  REN_Util.getGenericErrorMessage(ex, null)));
		}
		if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
			//return cancel();
		}
		return null;

	}

	public void setFilterObjValues(){
		batchFilterObj.CSM_Object_Name__c = objectName;
		batchFilterObj.CSM_End_Boundary_Criteria__c = endBoundaryCriteria;
		batchFilterObj.CSM_Batch_Job_Name__c = selectedBatchName;
	}

	/**
	 * @description : This method is used to populate existing Batch Filter data.
	 */
	public void setBatchFilterEdit(){
		sectionHeader = Label.CSM_LBL_EDIT_BATCH_FILTER;
		isEdit = true;
		objectName = batchFilterObj.CSM_Object_Name__c ;
		selectedBatchName = batchFilterObj.CSM_Batch_Job_Name__c;
	    endBoundaryCriteria = batchFilterObj.CSM_End_Boundary_Criteria__c;
		populateBatchFilterRec();

	}

	/**
	 * @description : This method is used to navigate to CSM_BatchFilterActivity page.
	*/
	public PageReference cancel(){
		PageReference pageRef = Page.CSM_BatchFilterActivity;
		pageRef.getParameters().put('tabCategory','SuccessPlan');
		pageRef.setRedirect(true);
		return pageRef;
	}

}