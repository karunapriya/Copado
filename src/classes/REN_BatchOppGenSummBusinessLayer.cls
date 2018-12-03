public with sharing class REN_BatchOppGenSummBusinessLayer extends CSM_BusinessLayer {
	
	//public static String accId = '';
	public REN_BatchOppGenSummBusinessLayer(CSM_CustomGridInputWrapper inputWrapper)
	{
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList()
	{
		return getBatchOppGenWrapperList();
	}
	
	private CSM_GridResponseWrapper getBatchOppGenWrapperList() 
	{	
		CSM_GridResponseWrapper batOppResponseWrapper = new CSM_GridResponseWrapper();
		try
		{
			batOppResponseWrapper.header = getGridColumnHeader();
			batOppResponseWrapper.row = getGridDataRows(getRecordList(), batOppResponseWrapper.header);
			batOppResponseWrapper.hasCheckbox = false;
			batOppResponseWrapper.hasAction = false;
			batOppResponseWrapper.hasDetail = false;
	        system.debug('\n\n~~~gridResponseWrapper: '+batOppResponseWrapper);
		}
		catch(Exception e)
		{
			batOppResponseWrapper.errorMessage = e.getMessage();
			system.debug(e);
		}
        return batOppResponseWrapper;
	}
	
	private List<CSM_GridColumnWrapper> getGridColumnHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper batchOppGenColumn = new CSM_GridColumnWrapper();
		
		//Account
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = REN_CONSTANTS.OBJ_OPP_ACCOUNT;
		batchOppGenColumn.label = 'Account';
		batchOppGenColumn.valueCol =  REN_Constants.REN_ACCOUNT_NAME;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		batchOppGenColumn.lookUpIdCol = REN_Constants.OBJ_OPP_ACCOUNT;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Opportunity Name
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = REN_Constants.FLD_NAME;
		batchOppGenColumn.label = 'Opportunity Name';
		batchOppGenColumn.valueCol =  REN_Constants.FLD_NAME;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		batchOppGenColumn.lookUpIdCol = REN_Constants.FLD_ID;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Amount
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = REN_Constants.OBJ_OPP_AMOUNT;
		batchOppGenColumn.label = 'Amount ('+UserInfo.getDefaultCurrency() +')';
		batchOppGenColumn.valueCol = REN_Constants.OBJ_OPP_AMOUNT;
		//batchOppGenColumn.lookUpIdCol = REN_Constants.REN_GROUPING;
		batchOppGenColumn.isDateCol = false;
		batchOppGenColumn.dataAlign = 'right';
		batchOppGenColumn.isCurrencyCol = true;
		//batchOppGenColumn.label = batchOppGenColumn.label + ' ('+UserInfo.getDefaultCurrency() +')';
		//batchOppGenColumn.label = batchOppGenColumn.label;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
			
		
		gridClmWrapper.add(batchOppGenColumn);
		
		//Stage
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = REN_Constants.OBJ_RC_OPPORTUNITY_STAGE;
		batchOppGenColumn.label = 'Stage';
		batchOppGenColumn.valueCol = REN_Constants.OBJ_RC_OPPORTUNITY_STAGE;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Closed Date
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = REN_Constants.OBJ_OPP_NEW_CLOSE_DATE;
		batchOppGenColumn.label = 'Closed Date';
		batchOppGenColumn.valueCol = REN_Constants.OBJ_OPP_NEW_CLOSE_DATE;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.isDateCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Earliest Expiration Date
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE;
		batchOppGenColumn.label = 'Earliest Expiration Date';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.isDateCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		return gridClmWrapper;
	}
	
	private List<Opportunity> getRecordList(){
		List<Opportunity> OpportunityList = REN_OpportunityDataAccess.getBatchOpptyRecordsBusinessLayer(this.inputWrapper.params.taskOrViewId);
		if (OpportunityList == null){
			OpportunityList = new List<Opportunity>();
		}
		return OpportunityList;
	}
	
	private List<CSM_GridRowWrapper> getGridDataRows(List<sObject> sObjectList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		//String userTimeZone = String.valueOf(UserInfo.getTimeZone());
		for(sObject sObj : sObjectList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			//accId = (String)sObj.get('AccountId');
			row.id = (String)sObj.get('Id');
		    row.sObj = sObj;
		    row.isMC = CSM_Util.checkMCEnabled();
            row.columns = new List<CSM_GridColumnWrapper>();
			row.namespace = CSM_Util.getNamespace();
            
			if (colList!=null){
				row.columns = colList;
				gridRowWrapper.add(row);
			}
		}
		
		return gridRowWrapper;
	}
	
}