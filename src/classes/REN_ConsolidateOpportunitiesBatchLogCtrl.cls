/**
 * Created Date		: Dec 2, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Consolidate Opportunities Batch Log controller class
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Dec 2, 2016			1.1					@description
 * 
 */
public with sharing class REN_ConsolidateOpportunitiesBatchLogCtrl {
	public String helpParam {get;set;}
	
	public REN_ConsolidateOpportunitiesBatchLogCtrl(){
		helpParam = CSM_Constants.HELP_CONSOLIDATION_REQUEST_LOGS;
	}
    public CSM_DataGridAttribute dataGridAttribute1{
    	set;
    	
    	get
    	{
    		dataGridAttribute1 = new CSM_DataGridAttribute();
    		dataGridAttribute1.tableName = 'ConsolidateOpportunityLog';
    		dataGridAttribute1.objectType  = 'ConsolidateOpportunityLog';
    	    dataGridAttribute1.viewName = 'ConsolidateOpportunityView';
    	    dataGridAttribute1.gridToolBarId = 'filter-grid-toolbar';
    	    dataGridAttribute1.hasSearch = 'true';
    	    dataGridAttribute1.stateSave = 'true';
    	    dataGridAttribute1.hasShowColumns = 'true';
    	    dataGridAttribute1.showExport ='true';
    	    dataGridAttribute1.showGlobalSelect = 'true';
    	    dataGridAttribute1.params = '{}';
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    dataGridAttribute1.userDateFormat =localeMap.get(userInfo.getLocale());
    	    return dataGridAttribute1;
    	    
    	}
    }
}