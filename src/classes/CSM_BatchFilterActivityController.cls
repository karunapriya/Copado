/**
 * Created Date		: Oct 28, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Controller class for Batch filter activity page
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 * Aditya Donthi			US1780					10/28/2016		1.0					Initial development
 *
 *
 */
public with sharing class CSM_BatchFilterActivityController {
	public String helpParam {get;set;}
	public String id {get;set;}
	
	public CSM_BatchFilterActivityController() {
		helpParam = CSM_Constants.HELP_BATCH_FILTER_ACTIVITY;
	}
	
    public CSM_DataGridAttribute batchFilterActivityGridAttribute
    { 
    	set;
    	
    	get
    	{
    		
    		
    		batchFilterActivityGridAttribute = new CSM_DataGridAttribute();
    		batchFilterActivityGridAttribute.tableName = 'batchFilter';
    		batchFilterActivityGridAttribute.objectType  = 'BatchFilterActivity';
    	    batchFilterActivityGridAttribute.viewName = 'BatchFilter';
    	    batchFilterActivityGridAttribute.gridToolBarId = 'filter-grid-toolbar';
    	    batchFilterActivityGridAttribute.hasSearch = 'true';
    	    batchFilterActivityGridAttribute.stateSave = 'true';
    	    batchFilterActivityGridAttribute.hasShowColumns = 'true';
    	    batchFilterActivityGridAttribute.showExport ='true';
    	    batchFilterActivityGridAttribute.showGlobalSelect = 'true';
    	    batchFilterActivityGridAttribute.params = '{}';
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    batchFilterActivityGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
     	    return batchFilterActivityGridAttribute;
    	}
    }

	/*
	** @Description: Navigates to BatchFilterManage page
	** @returns: Page reference to BatchFilterManage page
	*/
	public PageReference editClick() {
		try {			
			return getBatchFilterGenerationPageReference(id);
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
		return null;
	}
 
 	/*
	** @Description: Navigates to BatchFilterManage page
	** @returns: Page reference to BatchFilterManage page
	*/
	public PageReference redirectToBatchFilterGeneration() {
		try {
			return getBatchFilterGenerationPageReference(null);
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
		return null;
	}
	
	/*
	** @Description: Navigates to BatchFilterManage helper method
	** @returns: Page reference to BatchFilterManage page
	*/
	private PageReference getBatchFilterGenerationPageReference(String recordId) {
		PageReference pageRef = Page.CSM_BatchFilterManagement; 
		
		if(String.isNotEmpty(recordId)) {
			pageRef.getParameters().put('id', id);
		}
		
		pageRef.getParameters().put('tabCategory', 'SuccessPlan');
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/*
	** @Description: Deletes the batch filter record
	*/
    public void deleteClick() {
    	try {
    		CSM_BatchFilterDataAccess.deleteBatchFilters(new Set<String> {id});
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    }
    
    /*
	** @Description: Activates the batch filter record
	*/
    public void activateClick() {
    	try {
    		CSM_BatchFilterDataAccess.activateBatchFilters(new Set<String> {id});
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    }
    
    /*
	** @Description: Deactivates the batch filter record
	*/
    public void deactivateClick() {
    	try {
    		CSM_BatchFilterDataAccess.deactivateBatchFilters(new Set<String> {id});
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    }
    
    /*
	** @Description: Clones the batch filter record
	*/
    public void cloneClick() {
    	try {
    		CSM_BatchFilterDataAccess.cloneBatchFilters(new Set<String> {id});
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}   
    }
}