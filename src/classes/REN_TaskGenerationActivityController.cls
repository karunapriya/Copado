public with sharing class REN_TaskGenerationActivityController {
    public String helpParam {get; set;}
    public Id deletableRecordId{get;set;}
    
    public REN_TaskGenerationActivityController()  
	{
		helpParam = CSM_Constants.HELP_TASK_GENERATION_ACTIVITY;
	}
	
	public CSM_DataGridAttribute gridAttribute
    { 
    	set;
    	
    	get
    	{
    		if(gridAttribute == null) {
	    		gridAttribute = new CSM_DataGridAttribute();
	    		gridAttribute.tableName = 'TaskGenerationActivity';
	    		gridAttribute.objectType  = 'TaskGenerationActivity';
	    	    gridAttribute.viewName = 'TaskGenerationActivity';
	    	    gridAttribute.gridToolBarId = 'grid-toolbar';
	    	    gridAttribute.hasSearch = 'true';
	    	    gridAttribute.stateSave = 'true';
	    	    gridAttribute.hasShowColumns = 'true';
	    	    gridAttribute.showExport ='true';
	    	    gridAttribute.showGlobalSelect = 'true';
	    	    gridAttribute.params = '{}';
	    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
	     	    gridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
    		}
    		
     	    return gridAttribute;
    	}
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
}