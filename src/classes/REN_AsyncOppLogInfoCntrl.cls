/**
 * Created Date		: Oct 5, 2016
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
 * Nidhi					US1458,US1459				Oct 5, 2016			1.1					@description
 *
 */
public with sharing class REN_AsyncOppLogInfoCntrl {
	public String helpParam {get;set;}
	public String tabCategory {get; set;} 
	public Integer selectedTab {get; set;}
	public List<liValues> liList {get; private set;}
	
    public CSM_DataGridAttribute dataGridAttribute1{
    	set;
    	get{
    		dataGridAttribute1 = new CSM_DataGridAttribute();
    		dataGridAttribute1.tableName = 'completeAutoGenLog';
    		dataGridAttribute1.objectType  = 'AutomatedGenerationLog';
    	    dataGridAttribute1.viewName = 'AutoGenCompleteView';
    	    dataGridAttribute1.gridToolBarId = 'filter-grid-toolbar';
    	    dataGridAttribute1.hasSearch = 'true';
    	    dataGridAttribute1.stateSave = 'true';
    	    dataGridAttribute1.hasShowColumns = 'true';
    	    dataGridAttribute1.showExport ='true';
    	    dataGridAttribute1.showGlobalSelect = 'true';
    	    
    	    CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     		gridInputParams.healthStatus = REN_Constants.STATUS_COMPLETED;
     	    dataGridAttribute1.params = JSON.serialize(gridInputParams);
     	    
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    dataGridAttribute1.userDateFormat =localeMap.get(userInfo.getLocale());
     	    return dataGridAttribute1;
    	}
    }

    public CSM_DataGridAttribute dataGridAttribute2{
    	set;
    	get{
    		dataGridAttribute2 = new CSM_DataGridAttribute();
    		dataGridAttribute2.tableName = 'inProgressAutoGenLog';
    		dataGridAttribute2.objectType  = 'AutomatedGenerationLog';
    	    dataGridAttribute2.viewName = 'AutoGenInprogressView';
    	    dataGridAttribute2.gridToolBarId = 'filter-grid-toolbar';
    	    dataGridAttribute2.hasSearch = 'true';
    	    dataGridAttribute2.stateSave = 'true';
    	    dataGridAttribute2.hasShowColumns = 'true';
    	    dataGridAttribute2.showExport ='true';
    	    dataGridAttribute2.showGlobalSelect = 'true';
    	    
    	    CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     		gridInputParams.healthStatus = REN_Constants.STATUS_INPROGRESS;
     	    dataGridAttribute2.params = JSON.serialize(gridInputParams);
    	    
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    dataGridAttribute2.userDateFormat =localeMap.get(userInfo.getLocale());
    	    return dataGridAttribute2;
    	}
    }

    public CSM_DataGridAttribute dataGridAttribute3{
    	set;
    	get{
    		dataGridAttribute3 = new CSM_DataGridAttribute();
    		dataGridAttribute3.tableName = 'failedAutoGenLog';
    		dataGridAttribute3.objectType  = 'AutomatedGenerationLog';
    	    dataGridAttribute3.viewName = 'AutoGenFailedView';
    	    dataGridAttribute3.gridToolBarId = 'filter-grid-toolbar';
    	    dataGridAttribute3.hasSearch = 'true';
    	    dataGridAttribute3.stateSave = 'true';
    	    dataGridAttribute3.hasShowColumns = 'true';
    	    dataGridAttribute3.showExport ='true';
    	    dataGridAttribute3.showGlobalSelect = 'true';
    	    
    	    CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     		gridInputParams.healthStatus = REN_Constants.STATUS_FAILED;
     	    dataGridAttribute3.params = JSON.serialize(gridInputParams);
    	    
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    dataGridAttribute3.userDateFormat =localeMap.get(userInfo.getLocale());
    	    return dataGridAttribute3;
    	    
    	}
    }

	public REN_AsyncOppLogInfoCntrl(){
		helpParam = CSM_Constants.HELP_AUTOMATED_GENERATION_LOG;
	 	liList = new List<liValues>();
	 	liList.add(new liValues('#completeAutoGenLog', Label.REN_LBL_COMPLETED, 'CompletedDiv'));
       	liList.add(new liValues('#inProgressAutoGenLog', Label.REN_LBL_INPROGRESS, 'InProgressDiv'));
        liList.add(new liValues('#failedAutoGenLog', Label.REN_LBL_FAILED, 'FailedDiv')); 
       	selectedTab = 0;
	 }
    	 
	 public class liValues {
    	public String linkValue {get; set;}
    	public String linkDescValue {get; set;}
    	public String linkInternalValue{get;set;}
    	public liValues(String liValue, String liDescValue, String linkInternalValue){
    		linkValue = liValue;
    		linkDescValue = liDescValue;
    		this.linkInternalValue = linkInternalValue;
    	}
    }
	
}