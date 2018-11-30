public with sharing class REN_BatchOppGenBusinessLayer extends CSM_BusinessLayer {
	private static Boolean displayEditOption;
	private static Boolean displayDeleteOption;
	private static Boolean displayCloneOption;
	private static String namespace = CSM_Util.getNameSpace();
 
	public REN_BatchOppGenBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		return getGridResponseWrapperList();
	}
	
	private CSM_GridResponseWrapper getGridResponseWrapperList() {
		CSM_GridResponseWrapper gridResponseWrapper = new CSM_GridResponseWrapper();
		try{
			displayEditOption = CSM_AccessController.getInstance().objectCrudCheck(REN_Constants.OBJ_RC, CSM_Constants.DML_OPERATION_UPDATE);
	   	    displayDeleteOption = CSM_AccessController.getInstance().objectCrudCheck(REN_Constants.OBJ_RC, CSM_Constants.DML_OPERATION_DELETE);
	   	    displayCloneOption = CSM_AccessController.getInstance().objectCrudCheck(REN_Constants.OBJ_RC, CSM_Constants.DML_OPERATION_INSERT);
			gridResponseWrapper.header = getGridColumnHeader();
			gridResponseWrapper.row = getGridDataRows(getRecordList(), gridResponseWrapper.header);
			gridResponseWrapper.hasCheckbox = false;
			gridResponseWrapper.hasAction = true;
			gridResponseWrapper.hasDetail = false;
	        system.debug('\n\n~~~gridResponseWrapper: '+gridResponseWrapper);
		}catch(Exception e){
			system.debug('\n\n~~~Exception: '+ e.getStackTraceString());
			gridResponseWrapper.errorMessage = e.getMessage();
		}
        return gridResponseWrapper;
	}
	
	private List<REN_Renew_Configuration__c> getRecordList(){
		List<REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByConfigurationType(this.inputWrapper.viewName);
		if (renewConfigurationList == null){
			renewConfigurationList = new List<REN_Renew_Configuration__c>();
		}
		
		List<REN_Renew_Configuration__c> renewConfigurationReturnList = new List<REN_Renew_Configuration__c>();
		Set<REN_Renew_Configuration__c> renewConfigurationSet = new Set<REN_Renew_Configuration__c>();
		boolean isFirstValueSet = false;
		
		if(String.isNotBlank(this.inputWrapper.params.selectedTaskFilter) && (this.inputWrapper.params.selectedTaskFilter).trim() != '-'){
			for(REN_Renew_Configuration__c config : renewConfigurationList){
				if(config.id == this.inputWrapper.params.selectedTaskFilter){
					renewConfigurationSet.add(config);
					isFirstValueSet = true;
				}
				
			}
			
			if(isFirstValueSet){
				for(REN_Renew_Configuration__c config : renewConfigurationList){
					renewConfigurationSet.add(config);
				}
			}
			renewConfigurationReturnList.addAll(renewConfigurationSet);
		   return renewConfigurationReturnList; 
		} else {
			return renewConfigurationList;
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
				/*
				for (CSM_GridColumnWrapper colOrig : colList){
					CSM_GridColumnWrapper col = colOrig.clone();
					
					if (col.valueCol.contains('.')){
						String[] objSplit = col.valueCol.split('\\.');
						if (objSplit!=null && objSplit.size()==2){
							col.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
						}
					}else{
						col.value = String.valueOf(sObj.get(col.valueCol));
					}
					
					if (col.lookUpIdCol!=null && col.lookUpIdCol.length()>0){
						//col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
						col.recordID = String.valueOf(sObj.get(col.lookUpIdCol));
					}
					
					row.columns.add(col);
				}	
				*/
				gridRowWrapper.add(row);
			}
		}
		
		return gridRowWrapper;
	}
	
	private void setRowAction(CSM_GridRowWrapper row){
		row.actions = new List<CSM_GridActionWrapper>();
		
		if(displayEditOption){
			

			//row.actionValue = '<input name="uniqueCBox'+ inputWrapper.viewName + '" type="checkbox" id="cbID'+ inputWrapper.viewName + '_' + row.id + '"  value="' + row.id + '" class="cbGrid' + inputWrapper.viewName + '" />' + ' | 	\n' ;
			CSM_GridActionWrapper checkWrap = new CSM_GridActionWrapper('checkboxAction');
			checkWrap.actionName = 'uniqueCBox'+ inputWrapper.viewName;
			checkWrap.actionId = 'cbID'+ inputWrapper.viewName + '_' + row.id;
			checkWrap.classAction =  'cbGrid' + inputWrapper.viewName;
			checkWrap.actionValue = row.id;
			row.actions.add(checkWrap);
			System.debug('$$here is the checkWrap'+checkWrap);
			CSM_GridActionWrapper editWrap = new CSM_GridActionWrapper('Edit');
			editWrap.hrefAction = 'javascript:void(0);';
			editWrap.titleAction = Label.CSM_LBL_EDIT;
					
      		if(inputWrapper.viewName == 'Filter'){
				 editWrap.onclickAction = 'editSourceRecord(\''+row.id+'\')';
			}else{
				  editWrap.onclickAction = 'editGroupRecord(\''+row.id+'\')';
			}
			 row.actions.add(editWrap);
		}
		if(displayDeleteOption){
		    CSM_GridActionWrapper deleteWrap = new CSM_GridActionWrapper('Del');
			deleteWrap.hrefAction = 'javascript:void(0);';
			deleteWrap.onclickAction = 'confirmDelete(\''+row.id+'\', \'' + inputWrapper.viewName + '\')';
			deleteWrap.titleAction = Label.REN_Delete;
			row.actions.add(deleteWrap);
		}
		if(displayCloneOption){
			CSM_GridActionWrapper cloneWrap = new CSM_GridActionWrapper('Clone');
			cloneWrap.hrefAction = 'javascript:void(0);';
			cloneWrap.titleAction = Label.CSM_LBL_CLONE;
			
			if(inputWrapper.viewName == 'Filter'){
				cloneWrap.onclickAction = 'cloneSourceRecord(\''+row.id+'\')';	
			}else{
				cloneWrap.onclickAction = 'cloneGroupRecord(\''+row.id+'\')';
			}
			row.actions.add(cloneWrap);
		}
	}
	
	private List<CSM_GridColumnWrapper> getGridColumnHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper opportunityColumn = new CSM_GridColumnWrapper();
		
		//Name
		opportunityColumn = new CSM_GridColumnWrapper();
		opportunityColumn.apiName = CSM_Util.getNamespace() + REN_Constants.OBJ_RC_VIEW_NAME;
		opportunityColumn.label = REN_Constants.OBJ_SC_NAME;
		opportunityColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.OBJ_RC_VIEW_NAME;
		opportunityColumn.isSortable = true;
		opportunityColumn.customColumnSorter = 'customColumnSorter';
		opportunityColumn.lookUpIdCol = REN_Constants.FLD_ID;
		opportunityColumn.isDateCol = false;		
		gridClmWrapper.add(opportunityColumn);

		return gridClmWrapper;
	}
}