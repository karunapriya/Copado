/**
 * Created Date		: Apr 17, 2017
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
 * admin					User Story				Apr 17, 2017			1.1					@description
 *
 */
public with sharing class REN_TaskTemplateBusinessLayer extends CSM_BusinessLayer {
	private static Boolean displayEditOption;
	private static Boolean displayDeleteOption;
	private static Boolean displayCloneOption;
	private static String namespace = CSM_Util.getNameSpace();
	
	public REN_TaskTemplateBusinessLayer(CSM_CustomGridInputWrapper inputWrapper) {
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList() {
		return getGridResponseWrapperList();
	}
	
	private CSM_GridResponseWrapper getGridResponseWrapperList() {
		CSM_GridResponseWrapper gridResponseWrapper = new CSM_GridResponseWrapper();
		try {
			displayEditOption = CSM_AccessController.getInstance().objectCrudCheck('REN_Task_Template__c', CSM_Constants.DML_OPERATION_UPDATE);
	   	    displayDeleteOption = CSM_AccessController.getInstance().objectCrudCheck('REN_Task_Template__c', CSM_Constants.DML_OPERATION_DELETE);
	   	    displayCloneOption = CSM_AccessController.getInstance().objectCrudCheck('REN_Task_Template__c', CSM_Constants.DML_OPERATION_INSERT);
			gridResponseWrapper.header = getGridColumnHeader();
			gridResponseWrapper.row = getGridDataRows(getRecordList(), gridResponseWrapper.header);
			gridResponseWrapper.hasCheckbox = false;
			gridResponseWrapper.hasAction = true;
			gridResponseWrapper.hasDetail = false;
	        system.debug('\n\n~~~gridResponseWrapper: '+gridResponseWrapper);
		} catch(Exception e) {
			system.debug('\n\n~~~Exception: '+ e.getStackTraceString());
			gridResponseWrapper.errorMessage = e.getMessage();
		}
        return gridResponseWrapper;
	}
	
	private List<REN_Task_Template__c> getRecordList() {
		List<REN_Task_Template__c> taskTemplateList = REN_TaskTemplateDataAccess.getTaskTemplateByObject(this.inputWrapper.params.selectedFilterClause);
		if (taskTemplateList == null) {
			taskTemplateList = new List<REN_Task_Template__c>();
		}
		List<REN_Task_Template__c> taskTemplateReturnList = new List<REN_Task_Template__c>();
		Set<REN_Task_Template__c> taskTemplateSet = new Set<REN_Task_Template__c>();
		boolean isFirstValueSet = false;
		if(String.isNotBlank(this.inputWrapper.params.selectedTaskFilter) && (this.inputWrapper.params.selectedTaskFilter).trim() != '-') {
			for(REN_Task_Template__c config : taskTemplateList) {
				if(config.id == this.inputWrapper.params.selectedTaskFilter) {
					taskTemplateSet.add(config);
					isFirstValueSet = true;
				}
			}
			if(isFirstValueSet) {
				for(REN_Task_Template__c config : taskTemplateList){
					taskTemplateSet.add(config);
				}
			}
			taskTemplateReturnList.addAll(taskTemplateSet);
		   return taskTemplateReturnList; 
		} else {
			return taskTemplateList;
		}
	}
	
	private List<CSM_GridRowWrapper> getGridDataRows(List<sObject> sObjectList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		for(sObject sObj : sObjectList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			row.id = (String)sObj.get('Id');
			setRowAction(row);
			row.sObj = sObj;
			row.isMC = CSM_Util.checkMCEnabled();
			row.namespace = CSM_Util.getNamespace();
			row.columns = new List<CSM_GridColumnWrapper>();
			if (colList!=null){
				row.columns = colList;
				gridRowWrapper.add(row);
			}
		}
		return gridRowWrapper;
	}
	
	private void setRowAction(CSM_GridRowWrapper row){
		row.actions = new List<CSM_GridActionWrapper>();
		if(displayEditOption) {
			CSM_GridActionWrapper checkWrap = new CSM_GridActionWrapper('checkboxAction');
			checkWrap.actionName = 'uniqueCBox'+ inputWrapper.viewName;
			checkWrap.actionId = 'cbID'+ inputWrapper.viewName + '_' + row.id;
			checkWrap.classAction =  'cbGrid' + inputWrapper.viewName;
			checkWrap.actionValue = row.id;
			row.actions.add(checkWrap);
			System.debug('$$here is the checkWrap'+checkWrap);
			CSM_GridActionWrapper editWrap = new CSM_GridActionWrapper('Edit');
			editWrap.hrefAction = 'javascript:void(0);';
			editWrap.onclickAction = 'editRecord(\''+row.id+'\')';
			editWrap.titleAction = Label.CSM_LBL_EDIT;
			row.actions.add(editWrap);
		}
		
		if(displayDeleteOption) {
		    CSM_GridActionWrapper deleteWrap = new CSM_GridActionWrapper('Del');
			deleteWrap.hrefAction = 'javascript:void(0);';
			deleteWrap.onclickAction = 'confirmDelete(\''+row.id+'\', \'' + inputWrapper.viewName + '\')';
			deleteWrap.titleAction = Label.REN_Delete;
			row.actions.add(deleteWrap);
		}
		if(displayCloneOption) {
			CSM_GridActionWrapper cloneWrap = new CSM_GridActionWrapper('Clone');
			cloneWrap.hrefAction = 'javascript:void(0);';
			cloneWrap.onclickAction = 'cloneRecord(\''+row.id+'\')';
			cloneWrap.titleAction = Label.CSM_LBL_CLONE;	
			row.actions.add(cloneWrap);
		}
	}
	
	private List<CSM_GridColumnWrapper> getGridColumnHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper taskTemplateColumn = new CSM_GridColumnWrapper();
		
		//Name
		taskTemplateColumn = new CSM_GridColumnWrapper();
		taskTemplateColumn.apiName = 'Name';
		taskTemplateColumn.label = REN_Constants.OBJ_SC_NAME;
		taskTemplateColumn.valueCol = 'Name';
		taskTemplateColumn.isSortable = true;
		taskTemplateColumn.customColumnSorter = 'customColumnSorter';
		taskTemplateColumn.lookUpIdCol = REN_Constants.FLD_ID;
		taskTemplateColumn.isDateCol = false;		
		gridClmWrapper.add(taskTemplateColumn);
		
		//Record Type
		taskTemplateColumn = new CSM_GridColumnWrapper();
		taskTemplateColumn.apiName = CSM_Util.getNamespace() + 'REN_Record_Type_Name__c';
		taskTemplateColumn.label = 'Record Type';
		taskTemplateColumn.valueCol = CSM_Util.getNamespace() + 'REN_Record_Type_Name__c';
		taskTemplateColumn.isSortable = true;
		taskTemplateColumn.customColumnSorter = 'customColumnSorter';
		taskTemplateColumn.isDateCol = false;		
		gridClmWrapper.add(taskTemplateColumn);

		return gridClmWrapper;
	}
}