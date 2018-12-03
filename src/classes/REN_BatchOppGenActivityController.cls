public with sharing class REN_BatchOppGenActivityController {
	public String helpParam {get;set;}
	public Id deletableRecordId{get;set;}


	public REN_BatchOppGenActivityController(){
		helpParam = CSM_Constants.HELP_BATCH_GENERATION_ACTIVITY;
	}
	
	public PageReference redirectToBatchOppGeneration() {
		PageReference pageRef = Page.REN_BatchOppGeneration;
		pageRef.getParameters().put('tabCategory', 'Renewal');
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
				}
	    		delRec.REN_Status__c = 'Aborted';
	    		delRec = REN_BatchActivityDataAccess.saveBatchAct(delRec);
	    	}
    	}catch(Exception ex){
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    	}
    	return null;
    }
    
    public CSM_DataGridAttribute batchOppGenGridAttribute
    {
    	set;
    	
    	get
    	{
    		batchOppGenGridAttribute = new CSM_DataGridAttribute();
    		batchOppGenGridAttribute.tableName = 'batchHistory';
    		batchOppGenGridAttribute.objectType  = 'BatchOppGenBatchHistory';
    	    batchOppGenGridAttribute.viewName = 'BatchHistory';
    	    batchOppGenGridAttribute.gridToolBarId = 'filter-grid-toolbar';
    	    batchOppGenGridAttribute.hasSearch = 'true';
    	    batchOppGenGridAttribute.stateSave = 'true';
    	    batchOppGenGridAttribute.hasShowColumns = 'true';
    	    batchOppGenGridAttribute.showExport ='true';
    	    batchOppGenGridAttribute.showGlobalSelect = 'true';
    	    batchOppGenGridAttribute.params = '{}';
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    batchOppGenGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    	    return batchOppGenGridAttribute;
    	    
    	}
    }

}