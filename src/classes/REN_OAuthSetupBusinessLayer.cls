/**
 * Created Date		: Jan 11, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This class is used to display records on OAuth Admin page.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US1981					Jan 11, 2017	1.1					Added class in sprint 701
 *
 */
public with sharing class REN_OAuthSetupBusinessLayer extends CSM_BusinessLayer {
	
	private static Boolean displayDeleteOption;
	String nameSpace = CSM_Util.getNamespace();
	
    public REN_OAuthSetupBusinessLayer(CSM_CustomGridInputWrapper inputWrapper) {
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList() {
        return getRecordsWrapperList();
    }
    
    private CSM_GridResponseWrapper getRecordsWrapperList() {
        CSM_GridResponseWrapper recordsWrapperList = new CSM_GridResponseWrapper();
       	try {
       		displayDeleteOption = CSM_AccessController.getInstance().objectCrudCheck('REN_Low_Dollar_Client__c', CSM_Constants.DML_OPERATION_DELETE);
	        recordsWrapperList.header = setRenRelListHeader();
	        recordsWrapperList.hasAction = true;
	        recordsWrapperList.hasDetail = false;
	        recordsWrapperList.hasCheckbox = false;
	        Map<String, REN_Low_Dollar_Client__c> recordMap = new Map<String,REN_Low_Dollar_Client__c>(REN_LowTouchClientDataAccess.getLowDollarClientDetails());
            List<REN_Low_Dollar_Client__c> recordList = REN_LowTouchAdminDataAccess.getLowTouchAdminRecords();
	        recordsWrapperList.row = setRecordAsRows(recordList, recordsWrapperList.header);
		    system.debug('\n\n~~~gridResponseWrapper: '+recordsWrapperList);
       	} catch(Exception e) {
			recordsWrapperList.errorMessage = e.getMessage(); 
			system.debug(e.getStackTraceString());      		
       	}
      	return recordsWrapperList;
    } 
    
	private List<CSM_GridRowWrapper> setRecordAsRows(List<sObject> recordsList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		if(recordsList != null && !recordsList.isEmpty()) {
			Boolean isMcEnabled = CSM_Util.checkMCEnabled();
			for(sObject sObj : recordsList) {
				System.debug('ZZZ - '+sObj);
				CSM_GridRowWrapper row = new CSM_GridRowWrapper();
				row.id = (String)sObj.get('Id');
				setRowAction(row);
				row.sObj = sObj;
				row.isMC = isMcEnabled;
                row.columns = new List<CSM_GridColumnWrapper>();
				row.namespace = nameSpace;
                if (colList!=null){
                   row.columns = colList;
                   gridRowWrapper.add(row);	
                }
			}
		}
        return gridRowWrapper;
	}
	   	
    private List<CSM_GridColumnWrapper> setRenRelListHeader() {
        List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
		
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'Name';
			gridColumnWrapper.label = 'Heroku Organization Name';
			gridColumnWrapper.valueCol = 'Name';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);
			
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_OAuth_Credentials__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Low_Dollar_Client__c.fields.REN_OAuth_Credentials__c.label;
			gridColumnWrapper.valueCol = nameSpace + 'REN_OAuth_Credentials__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);
			
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'CreatedBy.Name';
			gridColumnWrapper.label = Label.CSM_LBL_CREATED_BY;
			gridColumnWrapper.valueCol = 'CreatedBy.Name';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);
			
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'CreatedDate';
			gridColumnWrapper.label = Schema.SobjectType.REN_Low_Dollar_Client__c.fields.CreatedDate.label;
			gridColumnWrapper.valueCol = 'CreatedDate';
	        gridColumnWrapper.isDateCol = true;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'DATETIME';
			gridColumnWrapperList.add(gridColumnWrapper);
			
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'LastModifiedBy.Name';
			gridColumnWrapper.label = Label.CSM_LBL_LAST_MODIFIED_BY;
			gridColumnWrapper.valueCol = 'LastModifiedBy.Name';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);
			
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'LastModifiedDate';
			gridColumnWrapper.label = Schema.SobjectType.REN_Low_Dollar_Client__c.fields.LastModifiedDate.label;
			gridColumnWrapper.valueCol = 'LastModifiedDate';
	        gridColumnWrapper.isDateCol = true;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'DATETIME';
			gridColumnWrapperList.add(gridColumnWrapper);
			
        return gridColumnWrapperList;
    }
    
    private void setRowAction(CSM_GridRowWrapper row) {
		row.actions = new List<CSM_GridActionWrapper>();

		if(displayDeleteOption) {
			CSM_GridActionWrapper checkWrap = new CSM_GridActionWrapper('checkboxAction');
			checkWrap.actionName = 'uniqueCBox'+ inputWrapper.viewName;
			checkWrap.actionId = 'cbID'+ inputWrapper.viewName + '_' + row.id;
			checkWrap.classAction =  'cbGrid' + inputWrapper.viewName;
			checkWrap.actionValue = row.id;
			row.actions.add(checkWrap);
			System.debug('$$here is the checkWrap'+checkWrap);
		    CSM_GridActionWrapper deleteWrap = new CSM_GridActionWrapper('Del');
			deleteWrap.hrefAction = 'javascript:void(0);';
			deleteWrap.onclickAction = 'confirmDelete(\''+row.id+'\', \'' + inputWrapper.viewName + '\')';
			deleteWrap.titleAction = Label.REN_Delete;
			row.actions.add(deleteWrap);
		}
	}
}