public with sharing class CSM_SuccessPlanPlayBusinessLayer extends CSM_BusinessLayer {
	private String namespace;
	public CSM_SuccessPlanPlayBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		return getSuccessPlanPlayWrapperList();
	}
	
	private CSM_GridResponseWrapper getSuccessPlanPlayWrapperList() {
		CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
		this.namespace = CSM_Util.getNamespace();
        try
        {
			pbResponseWrapper.header = setSuccessPlanPlayHeader();
			pbResponseWrapper.row = getRecordList(pbResponseWrapper.header);
	        pbResponseWrapper.hasCheckbox = false;
	        pbResponseWrapper.hasAction = false;
	        pbResponseWrapper.hasDetail = false;
	        system.debug('\n\n~~~gridResponseWrapper: '+pbResponseWrapper);
	    }
        catch(Exception e)
        {
            pbResponseWrapper.errorMessage = e.getMessage();
            system.debug(e);
        }
        return pbResponseWrapper;
	}
	
	private List<CSM_GridRowWrapper> getRecordList(List<CSM_GridColumnWrapper> colList){
        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
        String userLocale = UserInfo.getLocale();
        List<Sobject> successPlanPlay = new List<CSM_SuccessPlan_Play__c>();
        Set<Id> accountPlanIdSet = new Set<Id>();
        accountPlanIdSet.add((Id)this.inputWrapper.params.accountPlanId);
        successPlanPlay = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayList(accountPlanIdSet);
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        if (successPlanPlay != null && !successPlanPlay.isEmpty()){
            for(SObject succPlanPlay :successPlanPlay) {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.sObj = succPlanPlay;
                row.columns = new List<CSM_GridColumnWrapper>();
        		row.namespace = this.namespace;
                if (colList!=null){
                    row.columns = colList;
                    row.hasGridImage = true;
                    gridRowWrapper.add(row);
                }
            }
        }
        
        System.debug('ZZZZ - gridRowWrapper - '+gridRowWrapper.size());
        return gridRowWrapper;
    }
	
	private List<CSM_GridColumnWrapper> setSuccessPlanPlayHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		
		CSM_GridColumnWrapper spPlayColumn = new CSM_GridColumnWrapper();
		
		//Name
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FCG_DISPLAY_NAME;
		spPlayColumn.label = Schema.SobjectType.CSM_Play__c.fields.CSM_Display_Name__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_PLAY_REL_DISPLAY_NAME;
		spPlayColumn.lookUpIdCol = CSM_Constants.OBJ_PLAY_ID;
		spPlayColumn.isLinkCol = true;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(spPlayColumn);

		//Playbook
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_REL_PLAYBOOK_DISP_NAME;
		spPlayColumn.label = CSM_Constants.REC_LIMIT_PLAYBOOK;
		spPlayColumn.valueCol = CSM_Constants.OBJ_REL_PLAYBOOK_DISP_NAME;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = true;
		gridClmWrapper.add(spPlayColumn);
		
		//Status
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_TASK_PROCESSING_STATUS;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Status__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_TASK_PROCESSING_STATUS;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);
		
		//Outcome
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FLD_PLAY_OUTCOME;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Play_Outcome__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_FLD_PLAY_OUTCOME;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);	
		
		//Enter Date
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_PR_ENTER_DATE;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Enter_Date__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_PR_ENTER_DATE;
		spPlayColumn.isSortable = true;
		spPlayColumn.isLinkCol = false;
		spPlayColumn.isDateCol = true;
		gridClmWrapper.add(spPlayColumn);
		
		//Exit Date
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_PR_EXIT_DATE;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Exit_Date__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_PR_EXIT_DATE;
		spPlayColumn.isSortable = true;
		spPlayColumn.isLinkCol = false;
		spPlayColumn.isDateCol = true;
		gridClmWrapper.add(spPlayColumn);
		
		//Source
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FLD_SRC;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Source__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_FLD_SRC;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);
		
		//Short Description
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FLD_REL_PLAY_DESC;
		spPlayColumn.label = Schema.SobjectType.CSM_Play__c.fields.CSM_Short_Description__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_FLD_REL_PLAY_DESC;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);
		
		//Total No. of Tasks
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FLD_TOTL_TASKS;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Total_Number_of_Tasks__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_FLD_TOTL_TASKS;
		spPlayColumn.isNumberCol = true;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);
		
		//No. of Closed Tasks
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS;
		spPlayColumn.label = Schema.SobjectType.CSM_SuccessPlan_Play__c.fields.CSM_Number_of_Closed_Tasks__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_FLD_TOTL_CLOSED_TASKS;
		spPlayColumn.isNumberCol = true;
		spPlayColumn.isSortable = true;
		spPlayColumn.customColumnSorter = 'customColumnSorter';
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);
		
		//Active
		spPlayColumn = new CSM_GridColumnWrapper();
		spPlayColumn.apiName = CSM_Constants.OBJ_FLD_REL_PLAY_ISACTIVE;
		spPlayColumn.label = Schema.SobjectType.CSM_Play__c.fields.CSM_IsActive__c.label;
		spPlayColumn.valueCol = CSM_Constants.OBJ_FLD_REL_PLAY_ISACTIVE;
		spPlayColumn.isSortable = true;
		spPlayColumn.isLinkCol = false;
		gridClmWrapper.add(spPlayColumn);
		
		return gridClmWrapper;
	}    
}