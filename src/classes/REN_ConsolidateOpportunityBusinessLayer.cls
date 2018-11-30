/**
 * Created Date		: Dec 2, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - BusinessLayer for Consolidate Opportunity log
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
public with sharing class REN_ConsolidateOpportunityBusinessLayer extends CSM_BusinessLayer{
	String nameSpace = CSM_Util.getNamespace();
    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    public REN_ConsolidateOpportunityBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }

    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getRecordsWrapperList();
    }
    
    private CSM_GridResponseWrapper getRecordsWrapperList()
    {
        CSM_GridResponseWrapper recordsWrapperList = new CSM_GridResponseWrapper();
        
       	try{
	        
	        recordsWrapperList.header = setRenRelListHeader();
	        recordsWrapperList.hasAction = false;
	        recordsWrapperList.hasDetail = false;
	        recordsWrapperList.hasCheckbox = false;
	        List<REN_Consolidation_Request__c> recordList = REN_ConsolidationRequestDataAccess.getConsolidationRequestList();
	        recordsWrapperList.row = setRecordAsRows(recordList, recordsWrapperList.header);
		    system.debug('\n\n~~~gridResponseWrapper: '+recordsWrapperList);
		  
       	} catch(Exception e) {
			recordsWrapperList.errorMessage = e.getMessage(); 
			system.debug(e.getStackTraceString());      		
       	}
      	return recordsWrapperList;
    } 
    
   
	
	private List<CSM_GridRowWrapper> setRecordAsRows(List<sObject> recordsList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		if(recordsList != null && !recordsList.isEmpty()) {
			Boolean isMcEnabled = CSM_Util.checkMCEnabled();
			for(sObject sObj : recordsList) {
				System.debug('ZZZ - '+sObj);
				CSM_GridRowWrapper row = new CSM_GridRowWrapper();

				row.id = (String)sObj.get('Id');
				row.sObj = sObj;
				row.isMC = isMcEnabled;
                row.columns = new List<CSM_GridColumnWrapper>();
				row.namespace = nameSpace;
                if (colList!=null){
                   row.columns = colList;
                   gridRowWrapper.add(row);	
                }
			}
		}
        return gridRowWrapper;
	}
	   	

    private List<CSM_GridColumnWrapper> setRenRelListHeader()
    {
        List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
		

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_Target_Opportunity__r.Name';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_Target_Opportunity__c.label;
			gridColumnWrapper.valueCol = nameSpace +'REN_Target_Opportunity__r.Name';
			gridColumnWrapper.lookUpIdCol = nameSpace + 'REN_Target_Opportunity__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_Consolidation_Request_Id__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_Consolidation_Request_Id__c.label;
			gridColumnWrapper.valueCol = nameSpace +'REN_Consolidation_Request_Id__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_No_of_Source_Opportunities__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_No_of_Source_Opportunities__c.label;
			gridColumnWrapper.valueCol = nameSpace +'REN_No_of_Source_Opportunities__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataAlign = 'right';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_Number_of_OLIs__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_Number_of_OLIs__c.label;
			gridColumnWrapper.valueCol = nameSpace +'REN_Number_of_OLIs__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataAlign = 'right';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_Number_of_RLIs__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_Number_of_RLIs__c.label;
			gridColumnWrapper.valueCol = nameSpace +'REN_Number_of_RLIs__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataAlign = 'right';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
	        gridColumnWrapper.apiName = 'CreatedDate';
	        gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.CreatedDate.label;
	        gridColumnWrapper.valueCol = 'CreatedDate';
	        gridColumnWrapper.isSortable = true;
	        gridColumnWrapper.isDateCol = true;
			gridColumnWrapperList.add(gridColumnWrapper);
			
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'REN_Processed_On__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_Processed_On__c.label;
			gridColumnWrapper.valueCol = 'REN_Processed_On__c';
	        gridColumnWrapper.isDateCol = true;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'DATETIME';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_No_of_Errors__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request_Source__c.fields.REN_Failure_Message__c.label;
			gridColumnWrapper.valueCol = nameSpace + 'REN_No_of_Errors__c';
			gridColumnWrapper.lookUpIdCol = 'Id';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapper.dataAlign = 'right';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'CreatedBy.Name';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.CreatedById.label;
			gridColumnWrapper.valueCol = 'CreatedBy.Name';
			gridColumnWrapper.lookUpIdCol = 'CreatedById';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);

			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = nameSpace + 'REN_Processing_Completed__c';
			gridColumnWrapper.label = Schema.SobjectType.REN_Consolidation_Request__c.fields.REN_Processing_Completed__c.label;
			gridColumnWrapper.valueCol = nameSpace +'REN_Processing_Completed__c';
	        gridColumnWrapper.isDateCol = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.isVisible = true;
			gridColumnWrapper.dataType = 'STRING';
			gridColumnWrapperList.add(gridColumnWrapper);

        return gridColumnWrapperList;
    }
      
}