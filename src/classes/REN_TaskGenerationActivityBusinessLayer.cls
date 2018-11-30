public with sharing class REN_TaskGenerationActivityBusinessLayer extends CSM_BusinessLayer {
    private String namespace;
    
    public REN_TaskGenerationActivityBusinessLayer(CSM_CustomGridInputWrapper inputWrapper)
	{
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList()
	{
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
	** @returns: List of grid column wrapper
	*/
    private List<CSM_GridColumnWrapper> getGridHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has to be maintained for the headers to be set and the response columns
        
        CSM_GridColumnWrapper tgaColumn = new CSM_GridColumnWrapper();
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Batch_Number__c';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Batch_Number__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Batch_Number__c';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Task_Template__r.Name';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Task_Template__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Task_Template__r.Name';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Segment__r.Name';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Segment__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Segment__r.Name';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Job_Start_Date__c';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Job_Start_Date__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Job_Start_Date__c';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
             
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Job_Completion_Date__c';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Job_Completion_Date__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Job_Completion_Date__c';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Last_Modified_On__c';
        tgaColumn.label = Label.CSM_LBL_LASTMOD_ON;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Last_Modified_On__c';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Status__c';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Status__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Status__c';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Generated_Records__c';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Generated_Records__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Generated_Records__c';
        tgaColumn.isLinkCol = false;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        tgaColumn = new CSM_GridColumnWrapper();
        tgaColumn.apiName = CSM_Util.getNamespace() + 'REN_Failure_Assets__c';
        tgaColumn.label = Schema.SobjectType.REN_Batch_Activity__c.fields.REN_Failure_Assets__c.label;
        tgaColumn.valueCol = CSM_Util.getNamespace() + 'REN_Failure_Assets__c';
        tgaColumn.isLinkCol = true;
        tgaColumn.isSortable = true;
        tgaColumn.isSwitchable = true;
        tgaColumn.isVisible = true;
        tgaColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(tgaColumn);
        
        return gridClmWrapper;
    }
    
    private List<CSM_GridRowWrapper> getGridRows(List<CSM_GridColumnWrapper> colList){
    	List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
    	
    	if(colList!=null) {
	        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
	        String userLocale = UserInfo.getLocale();
	        List<Sobject> batchActivities = new List<REN_Batch_Activity__c>();
	        
	        batchActivities = REN_BatchActivityDataAccess.getBatchActivityRecords(REN_Constants.BATCH_ACTIVITY_TYPE_SEGMENT_TASK);
			
	        if (batchActivities != null && !batchActivities.isEmpty()){
	            for(SObject batchActivity : batchActivities) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) batchActivity.get('Id');
	                row.sObj = batchActivity;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                row.hasGridImage = true;
	                
	                String status = (String) batchActivity.get('REN_Status__c');
	                
	                if(status.equalsIgnoreCase('Scheduled')) {
	                	setRowAction(row, batchActivity);
	                }
	                
	                gridRowWrapper.add(row);
	            }
	        }
    	}
        
        return gridRowWrapper;
    }
    
    /*
    ** @Description: Sets row actions
    ** @Params row: Grid row
    ** @Params segment: Segment object
    */
    private void setRowAction(CSM_GridRowWrapper row, sObject segment) {
		row.actions = new List<CSM_GridActionWrapper>();
		
		CSM_GridActionWrapper actionWrapper;
		
		actionWrapper = new CSM_GridActionWrapper(Label.CSM_LBL_EDIT);
		actionWrapper.hrefAction = '/apex/ren_segmenttaskgeneration?tabCategory=Playmaker&id=' + row.id;
		actionWrapper.titleAction = Label.REN_Delete;
		row.actions.add(actionWrapper);
		
		actionWrapper = new CSM_GridActionWrapper(Label.REN_Delete);
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'confirmDelete("' + row.id + '")';
		actionWrapper.titleAction = Label.CSM_LBL_EDIT;
		row.actions.add(actionWrapper);
	} 
}