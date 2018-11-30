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
public with sharing class REN_AutomatedGenLogBusinessLayer extends CSM_BusinessLayer{
	
	public REN_AutomatedGenLogBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        system.debug('\n\n @@@called REN_AutomatedGenLogBusinessLayer ::::');
    }
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getAutoGenLogList();
    }
    
    /**
    * @description : This method fetch the Renewal Processing Status details as per the Health Status condition passed in CSM_CustomGridInputWrapper.
    */
    private CSM_GridResponseWrapper getAutoGenLogList(){
        CSM_GridResponseWrapper logWrapperList = new CSM_GridResponseWrapper();
        List<sObject> autoGenLogList;
        logWrapperList.header = setAutoGenHeader();
        String whereClauseStr = '';
        
        if(this.inputWrapper.params.healthStatus == REN_Constants.STATUS_COMPLETED){
        	whereClauseStr = ' where REN_Is_Renewal_Completed__c = true ';
        }else if(this.inputWrapper.params.healthStatus == REN_Constants.STATUS_INPROGRESS){
        	whereClauseStr = ' where REN_Is_Renewal_Completed__c = false AND REN_No_of_failure_line_items__c = 0 ';
        } else if(this.inputWrapper.params.healthStatus == REN_Constants.STATUS_FAILED){
        	whereClauseStr = ' where REN_Failed__c = true OR  REN_No_of_failure_line_items__c > 0 ';
        }
        
        autoGenLogList = REN_RenewalProcessingStatusDataAccess.getProcessingStatusRecByCondition(whereClauseStr);

        logWrapperList.hasCheckbox = false;
        logWrapperList.hasAction = false;
        logWrapperList.hasDetail = false;
        logWrapperList.row = setGeneratedLogRows(autoGenLogList, logWrapperList.header);
        return logWrapperList;
    }
    
    /**
      * @description : This method constrcts the Renewal Processing Status data for each column.
    */
    private List<CSM_GridRowWrapper> setGeneratedLogRows(List<sObject> autoGenLogList, List<CSM_GridColumnWrapper> colList){
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		String nameSpacePrefix = CSM_Util.getNamespace();
        if(autoGenLogList != null && !autoGenLogList.isEmpty()){
            Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
            String userLocale = UserInfo.getLocale();
            			
            for(sObject sObj : autoGenLogList){
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.id = (String)sObj.get('Id');
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
				row.namespace = CSM_Util.getNamespace();
                row.columns = new List<CSM_GridColumnWrapper>();
                if(colList != null) {
	            	SObject renObj = SObj.clone();
					for(CSM_GridColumnWrapper colOrig :colList){
	                	CSM_GridColumnWrapper col = colOrig.clone();
						row.columns.add(col);
					}               	
                    gridRowWrapper.add(row);
                }                           
            }
        }
        return gridRowWrapper;
    }
    
    /**
    * @description : This method constrcts the columns to show on Renewal Generation Batches grid in Automated Opportunity Generation link.
    */
    private List<CSM_GridColumnWrapper> setAutoGenHeader(){
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper colNew = new CSM_GridColumnWrapper();
        boolean isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
        String nameSpacePrefix = CSM_Util.getNamespace();
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Source_Opportunity__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_Source_Opportunity__c.label;
        colNew.valueCol = 'REN_Source_Opportunity__r.Name';
        colNew.lookUpIdCol = nameSpacePrefix + 'REN_Source_Opportunity__c';
    	colNew.isVisible = true;
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Renewal_Opportunity__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_Renewal_Opportunity__c.label;
        colNew.valueCol = 'REN_Renewal_Opportunity__r.Name';
        colNew.lookUpIdCol = nameSpacePrefix + 'REN_Renewal_Opportunity__c';
        colNew.isVisible = true;
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_OLIs_Qualified__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_OLIs_Qualified__c.label;
        colNew.valueCol = 'REN_OLIs_Qualified__c';
        colNew.isVisible = (this.inputWrapper.params.healthStatus != 'Completed');
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_OLIs_Created__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_OLIs_Created__c.label;
        colNew.valueCol = 'REN_OLIs_Created__c';
        colNew.isVisible = true;
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Assets_Qualified__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_Assets_Qualified__c.label;
        colNew.valueCol = 'REN_Assets_Qualified__c';
        colNew.isVisible = (this.inputWrapper.params.healthStatus != 'Completed');
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Assets_Created__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_Assets_Created__c.label;
        colNew.valueCol = 'REN_Assets_Created__c';
        colNew.isVisible = true;
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_RLIs_Qualified_Asset__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_RLIs_Qualified_Asset__c.label;
        colNew.valueCol = 'REN_RLIs_Qualified_Asset__c';
        colNew.isVisible = (this.inputWrapper.params.healthStatus != 'Completed');
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_RLIs_Created_for_Asset__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_RLIs_Created_for_Asset__c.label;
        colNew.valueCol = 'REN_RLIs_Created_for_Asset__c';
        colNew.isVisible = true;
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        if(isEntitlementEnabled){
	        colNew = new CSM_GridColumnWrapper();
	        colNew.apiName = CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c';
	        colNew.label = 'Generated/Destination Service Contract';
	        colNew.valueCol = CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c';
	        colNew.isVisible = true;
	        colNew.isSortable = true;
	        gridClmWrapper.add(colNew);

	        colNew = new CSM_GridColumnWrapper();
	        colNew.apiName = 'REN_CLIs_Qualified__c';
	        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_CLIs_Qualified__c.label;
	        colNew.valueCol = 'REN_CLIs_Qualified__c';
	        colNew.isVisible = (this.inputWrapper.params.healthStatus != 'Completed');
	        colNew.isSortable = true;
	        gridClmWrapper.add(colNew);
	        
	        colNew = new CSM_GridColumnWrapper();
	        colNew.apiName = 'REN_CLIs_Created__c';
	        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_CLIs_Created__c.label;
	        colNew.valueCol = 'REN_CLIs_Created__c';
	        colNew.isVisible = true;
	        colNew.isSortable = true;
	        gridClmWrapper.add(colNew);

	        colNew = new CSM_GridColumnWrapper();
	        colNew.apiName = 'REN_RLIs_Qualified_CLI__c';
	        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_RLIs_Qualified_CLI__c.label;
	        colNew.valueCol = 'REN_RLIs_Qualified_CLI__c';
	        colNew.isVisible = (this.inputWrapper.params.healthStatus != 'Completed');
	        colNew.isSortable = true;
	        gridClmWrapper.add(colNew);
	        
	        colNew = new CSM_GridColumnWrapper();
	        colNew.apiName = 'REN_RLIs_Created_for_CLI__c';
	        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_RLIs_Created_for_CLI__c.label;
	        colNew.valueCol = 'REN_RLIs_Created_for_CLI__c';
	        colNew.isVisible = true;
	        colNew.isSortable = true;
	        gridClmWrapper.add(colNew);
        }
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_No_of_failure_line_items__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_No_of_failure_line_items__c.label;
        colNew.valueCol = 'REN_No_of_failure_line_items__c';
        colNew.isVisible = (this.inputWrapper.params.healthStatus == 'Failed');
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Failed__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_Failed__c.label;
        colNew.valueCol = 'REN_Failed__c';
        colNew.isVisible = (this.inputWrapper.params.healthStatus == 'Failed');
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Failure_Msg__c';
        colNew.label = Schema.SobjectType.REN_Renewal_Processing_Status__c.fields.REN_Failure_Msg__c.label;
        colNew.valueCol = 'REN_Failure_Msg__c';
        colNew.isVisible = (this.inputWrapper.params.healthStatus == 'Failed');
        colNew.isSortable = true;
        gridClmWrapper.add(colNew);
        
        return gridClmWrapper;
    }
    
}