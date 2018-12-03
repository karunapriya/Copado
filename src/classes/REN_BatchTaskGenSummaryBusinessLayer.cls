public with sharing class REN_BatchTaskGenSummaryBusinessLayer extends CSM_BusinessLayer{
    private String namespace;
    private CSM_CustomGridInputWrapper inputWrapper;
    
    public REN_BatchTaskGenSummaryBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        this.inputWrapper = inputWrapper;
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){        
        CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        
        try
        {
            pbResponseWrapper.header = getGridHeader();
            pbResponseWrapper.row = getGridRows(pbResponseWrapper.header);
            pbResponseWrapper.hasCheckbox = false;
            pbResponseWrapper.hasAction = false;
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
        
        CSM_GridColumnWrapper columnWrapper = new CSM_GridColumnWrapper();
        
        columnWrapper = new CSM_GridColumnWrapper();
        columnWrapper.apiName = 'REN_Segment_Member__r.Name';
        columnWrapper.label = Schema.SobjectType.REN_Batch_Opportunity_Failure__c.fields.REN_Segment_Member__c.label;
        columnWrapper.valueCol = 'REN_Segment_Member__r.Name';
        columnWrapper.isLinkCol = false;
        columnWrapper.isSortable = true;
        columnWrapper.isSwitchable = true;
        columnWrapper.isVisible = true;
        columnWrapper.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(columnWrapper);
        
        if(REN_Constants.OBJ_SE_TYPE_ABRLM.equalsIgnoreCase(inputWrapper.params.selectedFilterClause)) {
			columnWrapper = new CSM_GridColumnWrapper();
	        columnWrapper.apiName = 'REN_Asset__r.Name';
	        columnWrapper.label = Schema.SobjectType.REN_Batch_Opportunity_Failure__c.fields.REN_Asset__c.label;
	        columnWrapper.valueCol = 'REN_Asset__r.Name';
	        columnWrapper.isLinkCol = true;
	        columnWrapper.isSortable = true;
	        columnWrapper.isSwitchable = true;
	        columnWrapper.isVisible = true;
	        columnWrapper.customColumnSorter = 'customColumnSorter';
	        gridClmWrapper.add(columnWrapper);
		} else if(REN_Constants.OBJ_SE_TYPE_LOW_TOUCH.equalsIgnoreCase(inputWrapper.params.selectedFilterClause)) {
			columnWrapper = new CSM_GridColumnWrapper();
	        columnWrapper.apiName = 'REN_Opportunity__r.Name';
	        columnWrapper.label = Schema.SobjectType.REN_Batch_Opportunity_Failure__c.fields.REN_Opportunity__c.label;
	        columnWrapper.valueCol = 'REN_Opportunity__r.Name';
	        columnWrapper.isLinkCol = true;
	        columnWrapper.isSortable = true;
	        columnWrapper.isSwitchable = true;
	        columnWrapper.isVisible = true;
	        columnWrapper.customColumnSorter = 'customColumnSorter';
	        gridClmWrapper.add(columnWrapper);
		}
        
        if(inputWrapper.viewName.equalsIgnoreCase('BatchTaskGenSummary_Success')) {
	        columnWrapper = new CSM_GridColumnWrapper();
	        columnWrapper.apiName = 'REN_Segment_Task_ID__c';
	        columnWrapper.label = Schema.SobjectType.REN_Batch_Opportunity_Failure__c.fields.REN_Segment_Task_ID__c.label;
	        columnWrapper.valueCol = 'REN_Segment_Task_ID__c';
	        columnWrapper.isLinkCol = true;
	        columnWrapper.isSortable = true;
	        columnWrapper.isSwitchable = true;
	        columnWrapper.isVisible = true;
	        columnWrapper.customColumnSorter = 'customColumnSorter';
	        gridClmWrapper.add(columnWrapper);
        } else if(inputWrapper.viewName.equalsIgnoreCase('BatchTaskGenSummary_Failed')) {
	        columnWrapper = new CSM_GridColumnWrapper();
	        columnWrapper.apiName = 'REN_Failure_Message__c';
	        columnWrapper.label = Schema.SobjectType.REN_Batch_Opportunity_Failure__c.fields.REN_Failure_Message__c.label;
	        columnWrapper.valueCol = 'REN_Failure_Message__c';
	        columnWrapper.isLinkCol = false;
	        columnWrapper.isSortable = true;
	        columnWrapper.isSwitchable = true;
	        columnWrapper.isVisible = true;
	        columnWrapper.customColumnSorter = 'customColumnSorter';
	        gridClmWrapper.add(columnWrapper);
        }
        
        return gridClmWrapper;
    }
    
    private List<CSM_GridRowWrapper> getGridRows(List<CSM_GridColumnWrapper> colList){
    	List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
    	
    	if(colList!=null) {
	        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
	        String userLocale = UserInfo.getLocale();
	        List<Sobject> records = new List<REN_Batch_Opportunity_Failure__c>();
	        
	        if(inputWrapper.viewName.equalsIgnoreCase('BatchTaskGenSummary_Success')) {
	        	records = REN_BatchOppFailureDataAccess.getBatchActivityDetails(inputWrapper.params.taskOrViewId, false);
	        } else if(inputWrapper.viewName.equalsIgnoreCase('BatchTaskGenSummary_Failed')) {
	        	records = REN_BatchOppFailureDataAccess.getBatchActivityDetails(inputWrapper.params.taskOrViewId, true);
	        }
			
	        if (records != null && !records.isEmpty()){
	            for(SObject record : records) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) record.get('Id');
	                row.sObj = record;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                row.hasGridImage = true;
	                	                
	                gridRowWrapper.add(row);
	            }
	        }
    	}
        
        return gridRowWrapper;
    }
}