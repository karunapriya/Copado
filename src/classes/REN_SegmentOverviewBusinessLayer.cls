/**
 * Created Date		: Nov 30, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Business layer for Segment overview
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1861					Nov 30, 2016	1.0					Initial development
 *
 */
public with sharing class REN_SegmentOverviewBusinessLayer extends CSM_BusinessLayer {
    private String namespace;
    
    public REN_SegmentOverviewBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){        
        CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        
        try
        {
            pbResponseWrapper.header = getGridHeader();
            pbResponseWrapper.row = getGridRows(pbResponseWrapper.header);
            pbResponseWrapper.hasCheckbox = true;
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
	** @Returns: List of grid columns
	*/
    private List<CSM_GridColumnWrapper> getGridHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has to be maintained for the headers to be set and the response columns
        String nameSpacePrefix = CSM_Util.getNamespace();
        CSM_GridColumnWrapper segmentColumn = new CSM_GridColumnWrapper();
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_NAME;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.Name.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_NAME;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
		segmentColumn.apiName = 'Id';
		segmentColumn.label = 'Id';
		segmentColumn.valueCol = 'Id';
		segmentColumn.lookUpIdCol = 'Id';
		segmentColumn.isVisible = false;
		segmentColumn.isSwitchable = false;
		segmentColumn.isSortable = true;
		gridClmWrapper.add(segmentColumn); 	
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_DESCRIPTION;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_Description__c.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_DESCRIPTION;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
                
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_TYPE;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_Type__c.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_TYPE;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_VALUE;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_Value__c.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_VALUE;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.isCurrencyCol = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_NUMBER_OF_SEGMENT_MEMBERS;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_Number_of_Segment_Members__c.label;
        segmentColumn.valueCol = nameSpacePrefix + REN_Constants.OBJ_SE_NUMBER_OF_SEGMENT_MEMBERS;
        segmentColumn.isLinkCol = true;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_LAST_MODIFIED_BY_NAME;
        segmentColumn.label = Label.CSM_LBL_LAST_MODIFIED_BY;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_LAST_MODIFIED_BY_NAME;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_LAST_MODIFIED_DATE;
        segmentColumn.label = Schema.SobjectType.CSM_Batch_Filter__c.fields.LastModifiedDate.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_LAST_MODIFIED_DATE;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_QR_CREATED;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_QuoteRequest_Created__c.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_QR_CREATED;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        //segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = REN_Constants.OBJ_SE_QR_SUBMITTED;
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_QuoteRequest_Submitted__c.label;
        segmentColumn.valueCol = REN_Constants.OBJ_SE_QR_SUBMITTED;
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        //segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
        segmentColumn = new CSM_GridColumnWrapper();
        segmentColumn.apiName = 'REN_Task_Batch_Status__c';
        segmentColumn.label = Schema.SobjectType.REN_Segment__c.fields.REN_Task_Batch_Status__c.label;
        segmentColumn.valueCol = 'REN_Task_Batch_Status__c';
        segmentColumn.isLinkCol = false;
        segmentColumn.isSortable = true;
        segmentColumn.isSwitchable = true;
        segmentColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(segmentColumn);
        
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
	        List<Sobject> segments = new List<REN_Segment__c>();
	        segments = REN_SegmentDataAccess.getAllSegments();
	        
	        if (segments != null && !segments.isEmpty()){
	            for(SObject segment : segments) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) segment.get('Id');
	                row.sObj = segment;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                //changed for US2455
	                //row.hasGridImage = false;
	                row.hasGridImage = true;
	                
	                setRowAction(row, segment);
	                
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
		
		CSM_GridActionWrapper actionWrapper = new CSM_GridActionWrapper(Label.REN_Segment_Add_Members);
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'editClick("' + row.id + '")';
		actionWrapper.titleAction = Label.REN_Segment_Add_Members;
		row.actions.add(actionWrapper);
	}  
}