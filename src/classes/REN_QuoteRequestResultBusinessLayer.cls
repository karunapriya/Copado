/**
 * Created Date		: Feb 7, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
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
 * abirjepatil					User Story				Feb 7, 2017			1.1					@description
 * 
 */
public with sharing class REN_QuoteRequestResultBusinessLayer  extends CSM_BusinessLayer {

    private String namespace;
    
    public REN_QuoteRequestResultBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
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
	** @Returns: List of grid columns
	*/
    private List<CSM_GridColumnWrapper> getGridHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has to be maintained for the headers to be set and the response columns
        String nameSpacePrefix = CSM_Util.getNamespace();
        CSM_GridColumnWrapper batchResultColumn = new CSM_GridColumnWrapper();
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = REN_Constants.OBJ_SE_NAME;
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.Name.label;
        batchResultColumn.valueCol = REN_Constants.OBJ_SE_NAME;
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        batchResultColumn = new CSM_GridColumnWrapper();
		batchResultColumn.apiName = 'Id';
		batchResultColumn.label = 'Id';
		batchResultColumn.valueCol = 'Id';
		batchResultColumn.lookUpIdCol = 'Id';
		batchResultColumn.isVisible = false;
		batchResultColumn.isSwitchable = false;
		batchResultColumn.isSortable = true;
		gridClmWrapper.add(batchResultColumn); 	
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Status__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Status__c.label;
        batchResultColumn.valueCol = 'CSM_Status__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
                
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Batch_Completion_Time__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Batch_Completion_Time__c.label;
        batchResultColumn.valueCol = 'CSM_Batch_Completion_Time__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isDateCol = true;        
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Batch_Start_Time__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Batch_Start_Time__c.label;
        batchResultColumn.valueCol = 'CSM_Batch_Start_Time__c';
        batchResultColumn.isLinkCol = true;
        batchResultColumn.isDateCol = true;        
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Module__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Module__c.label;
        batchResultColumn.valueCol = 'CSM_Module__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Objects_Processed__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Objects_Processed__c.label;
        batchResultColumn.valueCol = 'CSM_Objects_Processed__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_BatchId__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_BatchId__c.label;
        batchResultColumn.valueCol = 'CSM_BatchId__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Error_Description__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Error_Description__c.label;
        batchResultColumn.valueCol = 'CSM_Error_Description__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);

        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Errors__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Errors__c.label;
        batchResultColumn.valueCol = 'CSM_Errors__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);

        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'CSM_Records_Processed__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.CSM_Records_Processed__c.label;
        batchResultColumn.valueCol = 'CSM_Records_Processed__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);

        batchResultColumn = new CSM_GridColumnWrapper();
        batchResultColumn.apiName = 'REN_Segment_Names__c';
        batchResultColumn.label = Schema.SobjectType.CSM_Batch_Result__c.fields.REN_Segment_Names__c.label;
        batchResultColumn.valueCol = 'REN_Segment_Names__c';
        batchResultColumn.isLinkCol = false;
        batchResultColumn.isSortable = true;
        batchResultColumn.isSwitchable = true;
        batchResultColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(batchResultColumn);
        
        return gridClmWrapper;
    }
    
    /*
    ** @Description: Gets grid rows
    ** @Params colList: Columns of the grid
    ** @Returns: List of grid rows
    */
    private List<CSM_GridRowWrapper> getGridRows(List<CSM_GridColumnWrapper> colList) {
    	List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
    	
    	if(colList!=null) {
	        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
	        String userLocale = UserInfo.getLocale();
	        List<Sobject> batchResults = new List<CSM_Batch_Result__c>();
	        batchResults = CSM_BatchResultsLogger.getQuoteRequestResults();
	        
	        if (batchResults != null && !batchResults.isEmpty()){
	            for(SObject batchResult : batchResults) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) batchResult.get('Id');
	                row.sObj = batchResult;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                row.hasGridImage = false;
	                
	                //setRowAction(row, segment);
	                
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
    /*private void setRowAction(CSM_GridRowWrapper row, sObject segment) {
		row.actions = new List<CSM_GridActionWrapper>();
		
		CSM_GridActionWrapper actionWrapper = new CSM_GridActionWrapper(Label.REN_Segment_Add_Members);
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'editClick("' + row.id + '")';
		row.actions.add(actionWrapper);
	}  */
}