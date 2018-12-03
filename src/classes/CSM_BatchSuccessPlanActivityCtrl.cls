public with sharing class CSM_BatchSuccessPlanActivityCtrl {
	//Eswar Bala: uncommenting because of reference in associated page.
	public String helpParam {get;set;}
	public Id deletableRecordId{get;set;}


	public PageReference redirectToBatchSuccessPlan() {
		PageReference pageRef = Page.CSM_BatchPlanTemplateAssignment;
		pageRef.getParameters().put('tabCategory', 'SuccessPlan');
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	public PageReference deleteSelectedRecord()
    {
    	try{
	    	if(deletableRecordId != null)
	    	{
	    		REN_Batch_Activity__c delRec = REN_BatchActivityDataAccess.getBatchAct(deletableRecordId);
	    		try{
					System.abortJob(delRec.REN_Scheduler_ID__c); //abort the job
				}catch(Exception e){
					system.debug('## \n\n~~~~ ERROR: '+ e.getMessage());
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
				}
	    		delRec.REN_Status__c = 'Aborted';
	    		delRec = REN_BatchActivityDataAccess.saveBatchAct(delRec);
	    	}
    	}catch(Exception ex){
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    	}
    	return null;
    }
    
    public CSM_DataGridAttribute batchSuccessGridAttribute
    {
    	set;
    	get
    	{
    		batchSuccessGridAttribute = new CSM_DataGridAttribute();
    		batchSuccessGridAttribute.tableName = CSM_Constants.GRID_ATTR_BATCH_HISTORY;
    		batchSuccessGridAttribute.objectType  = CSM_Constants.GRID_ATTR_BATCH_SP_HISTORY;
    		
    	    batchSuccessGridAttribute.viewName = CSM_Constants.CSM_PTA;
    	    batchSuccessGridAttribute.gridToolBarId = CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
    	    batchSuccessGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
    	    batchSuccessGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
    	    batchSuccessGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
    	    batchSuccessGridAttribute.showExport =CSM_Constants.GRID_ATTR_FALSE;
    	    batchSuccessGridAttribute.showGlobalSelect = CSM_Constants.GRID_ATTR_TRUE;
    	    
    	    CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
    	    batchSuccessGridAttribute.params = JSON.serialize(gridInputParams);
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		    batchSuccessGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    	    return batchSuccessGridAttribute;
    	}
    }
    
}