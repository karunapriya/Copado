/**
 * Created Date     : Oct 31, 2016
 * Developed By     : Aditya, Comity Designs, Inc.
 *
 * Function         : Business layer class for Batch filter activity page
 * Support Email    : aditya@comitydesigns.com
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 *
 */
public with sharing class CSM_BatchFilterActivityBusinessLayer extends CSM_BusinessLayer {
    private String namespace;
    
    public CSM_BatchFilterActivityBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){        
        CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        
        try
        {
            pbResponseWrapper.header = getGridHeader();
            pbResponseWrapper.row = getGridRows(pbResponseWrapper.header);
            pbResponseWrapper.hasCheckbox = false;
            pbResponseWrapper.hasAction = true;
            pbResponseWrapper.hasDetail = false;
        }
        catch(Exception e)
        {
            pbResponseWrapper.errorMessage = e.getMessage();
            system.debug(e);
        }
        
        return pbResponseWrapper;
    }
    
    /*
	** @Description: Gets grid header details
	** @returns: Page reference to BatchFilterManage page
	*/
    private List<CSM_GridColumnWrapper> getGridHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has to be maintained for the headers to be set and the response columns
        
        CSM_GridColumnWrapper spPlayColumn = new CSM_GridColumnWrapper();
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_DISPLAY_NAME;
        spPlayColumn.label = Schema.SobjectType.CSM_Batch_Filter__c.fields.CSM_Display_Name__c.label;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_DISPLAY_NAME;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_DESCRIPTION;
        spPlayColumn.label = Schema.SobjectType.CSM_Batch_Filter__c.fields.CSM_Description__c.label;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_DESCRIPTION;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
                
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_BATCH_JOB_NAME;
        spPlayColumn.label = Schema.SobjectType.CSM_Batch_Filter__c.fields.CSM_Batch_Job_Name__c.label;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_BATCH_JOB_NAME;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_OBJECT_NAME;
        spPlayColumn.label = Schema.SobjectType.CSM_Batch_Filter__c.fields.CSM_Object_Name__c.label;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_OBJECT_NAME;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);        
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_CREATED_BY_NAME;
        spPlayColumn.label = Label.CSM_LBL_CREATED_BY;        
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_CREATED_BY_NAME;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_CREATED_DATE;
        spPlayColumn.label = Label.CSM_CREATED_ON;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_CREATED_DATE;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isDateCol = true; 
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_LAST_MODIFIED_BY_NAME;
        spPlayColumn.label = Label.CSM_LBL_LAST_MODIFIED_BY;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_LAST_MODIFIED_BY_NAME;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE;
        spPlayColumn.label = Label.CSM_LBL_LASTMOD_ON;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE;
        spPlayColumn.isLinkCol = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        spPlayColumn = new CSM_GridColumnWrapper();
        spPlayColumn.apiName = CSM_Constants.OBJ_BF_IS_ACTIVE;
        spPlayColumn.label = Schema.SobjectType.CSM_Batch_Filter__c.fields.CSM_IsActive__c.label;
        spPlayColumn.valueCol = CSM_Constants.OBJ_BF_IS_ACTIVE;
        spPlayColumn.isLinkCol = false;
        //spPlayColumn.isSortable = false;
        spPlayColumn.isSortable = true;
        spPlayColumn.isSwitchable = true;
        //spPlayColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(spPlayColumn);
        
        return gridClmWrapper;
    }
    
    private List<CSM_GridRowWrapper> getGridRows(List<CSM_GridColumnWrapper> colList){
    	List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
    	
    	if(colList!=null) {
	        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
	        String userLocale = UserInfo.getLocale();
	        List<Sobject> batchFilters = new List<CSM_Batch_Filter__c>();
	        batchFilters = CSM_BatchFilterDataAccess.getAllBatchFilters();
	        
	        if (batchFilters != null && !batchFilters.isEmpty()){
	            for(SObject batchFilter : batchFilters) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) batchFilter.get('Id');
	                row.sObj = batchFilter;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                row.hasGridImage = true;
	                
	                setRowAction(row, batchFilter);
	                
	                gridRowWrapper.add(row);
	            }
	        }
    	}
        
        return gridRowWrapper;
    }
    
    private void setRowAction(CSM_GridRowWrapper row, sObject batchFilter){
		row.actions = new List<CSM_GridActionWrapper>();
		
		CSM_GridActionWrapper actionWrapper = new CSM_GridActionWrapper('Edit');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'editClick("' + row.id + '")';
		actionWrapper.titleAction = Label.CSM_LBL_EDIT;
		row.actions.add(actionWrapper);
		
		actionWrapper = new CSM_GridActionWrapper('Del');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'confirmDelete("' + row.id + '", "' + Label.CSM_LBL_BATCH_FILTER_ACTIVITY + '")';
		actionWrapper.titleAction = Label.REN_Delete;
		row.actions.add(actionWrapper);
		
		if((Boolean) batchFilter.get('CSM_IsActive__c')) {
			actionWrapper = new CSM_GridActionWrapper('Deactivate');
			actionWrapper.hrefAction = 'javascript:void(0);';
			actionWrapper.onclickAction = 'deactivateClick("' + row.id + '")';
			actionWrapper.titleAction = Label.CSM_LBL_DEACTIVATE;
			row.actions.add(actionWrapper);
		} else {
			actionWrapper = new CSM_GridActionWrapper('Activate');
			actionWrapper.hrefAction = 'javascript:void(0);';
			actionWrapper.onclickAction = 'confirmActivate("'+ row.id + '")';
			actionWrapper.titleAction = Label.CSM_LBL_ACTIVATE;
			row.actions.add(actionWrapper);
		}
		
		actionWrapper = new CSM_GridActionWrapper('Clone');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'cloneClick("'+ row.id + '")';
		actionWrapper.titleAction = Label.CSM_LBL_CLONE;
		row.actions.add(actionWrapper);
	}  
}