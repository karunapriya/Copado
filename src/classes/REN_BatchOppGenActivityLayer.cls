public with sharing class REN_BatchOppGenActivityLayer extends CSM_BusinessLayer
{
	private static Boolean displayEditOption;
	private static Boolean displayDeleteOption;
	public static String status;
	public static Decimal generated;
	public static Decimal failedAssets;
	
	public REN_BatchOppGenActivityLayer(CSM_CustomGridInputWrapper inputWrapper)
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
			displayEditOption = CSM_AccessController.getInstance().objectCrudCheck(REN_Constants.OBJ_BATCH_ACT, CSM_Constants.DML_OPERATION_UPDATE);
	   	    displayDeleteOption = CSM_AccessController.getInstance().objectCrudCheck(REN_Constants.OBJ_BATCH_ACT, CSM_Constants.DML_OPERATION_DELETE);
			batOppResponseWrapper.header = getGridColumnHeader();
			batOppResponseWrapper.row = getGridDataRows(getRecordList(), batOppResponseWrapper.header);
			batOppResponseWrapper.hasCheckbox = false;
			batOppResponseWrapper.hasAction = true;
			batOppResponseWrapper.hasDetail = false;
	        system.debug('\n\n~~~gridResponseWrapper: '+batOppResponseWrapper);
		}
		catch(Exception e)
		{
			batOppResponseWrapper.errorMessage = e.getMessage();
		}
        return batOppResponseWrapper;
	}
	
	private List<CSM_GridColumnWrapper> getGridColumnHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
		String viewName = this.inputWrapper.viewName;
		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper batchOppGenColumn = new CSM_GridColumnWrapper();
		
		//Batch Number
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.REN_BAT_NUM;
		batchOppGenColumn.label = 'Batch #';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + REN_Constants.REN_BAT_NUM;//CSM_Util.getNamespace() + REN_Constants.REN_SRC_REC_FLTR;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		//batchOppGenColumn.lookUpIdCol = REN_Constants.FLD_ID;
		gridClmWrapper.add(batchOppGenColumn);
		
		if(viewName == 'BatchHistory') {
			//Filter
			batchOppGenColumn = new CSM_GridColumnWrapper();
			batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_SRC_REC_FLTR;
			batchOppGenColumn.label = 'Source Record Filter';
			batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + REN_Constants.REN_RELATION_FILTER_NAME;//CSM_Util.getNamespace() + REN_Constants.REN_SRC_REC_FLTR;
			batchOppGenColumn.isSortable = true;
			batchOppGenColumn.customColumnSorter = 'customColumnSorter';
			//batchOppGenColumn.lookUpIdCol = REN_Constants.REN_SRC_REC_FLTR;
			gridClmWrapper.add(batchOppGenColumn);
		
			//Grouping
			batchOppGenColumn = new CSM_GridColumnWrapper();
			batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_GROUPING;
			batchOppGenColumn.label = 'Grouping';
			batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_RELATION_GROUPING_NAME;
			//batchOppGenColumn.lookUpIdCol = REN_Constants.REN_GROUPING;
			batchOppGenColumn.isSortable = true;
			batchOppGenColumn.customColumnSorter = 'customColumnSorter';
			gridClmWrapper.add(batchOppGenColumn);
		}
		//Object Name
		if(viewName == 'CSM_PTA') {
			batchOppGenColumn = new CSM_GridColumnWrapper();
			batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_OBJ_TYPE;
			batchOppGenColumn.label = 'Filter Object';
			batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + REN_Constants.REN_OBJ_TYPE;
			batchOppGenColumn.isSortable = true;
			gridClmWrapper.add(batchOppGenColumn);
		}
		//Job Start Date
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_JOB_STRT_DT;
		batchOppGenColumn.label = 'Job Start Date';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_JOB_STRT_DT;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.isDateCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Job Completion Date
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_JOB_COMPLT_DT;
		batchOppGenColumn.label = 'Job Completion Date';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_JOB_COMPLT_DT;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.isDateCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Last Modified on
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.REN_LAST_MOD_ON;
		batchOppGenColumn.label = 'Last Modified Date';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_CONSTANTS.REN_LAST_MOD_ON;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.isDateCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Status
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_STATUS;
		batchOppGenColumn.label = 'Status';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_STATUS;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(batchOppGenColumn);
		
		//Generated
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_GEN_RECS;
		if(viewName == 'BatchHistory') {
			batchOppGenColumn.label = 'Generated';
			batchOppGenColumn.isSortable = true;
		} else {
			batchOppGenColumn.label = 'Assigned';
			batchOppGenColumn.isSortable = false;
		}
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_GEN_RECS;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';		
	    batchOppGenColumn.dataAlign = 'right';
	    batchOppGenColumn.isNumberCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Failure Assets
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.REN_FAIL_ASSET;
		batchOppGenColumn.label = 'Failure Records';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_CONSTANTS.REN_FAIL_ASSET;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';	
		batchOppGenColumn.dataAlign = 'right';	
		if(viewName == 'BatchHistory') {
			batchOppGenColumn.isSortable = true;
		} else {
			batchOppGenColumn.isSortable = false;
		}
		batchOppGenColumn.isNumberCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Created By
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.REN_CREATEDBY;
		batchOppGenColumn.label = 'Created By';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_CONSTANTS.REN_CREATEDBY_NAME_CUST;
		if(viewName == 'BatchHistory') {
			batchOppGenColumn.isSortable = true;
			batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		} else {
			batchOppGenColumn.isSortable = false;
		}
		batchOppGenColumn.isVisible = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Created on
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.REN_CREATEDON;
		batchOppGenColumn.label = 'Created on';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_CONSTANTS.REN_CREATEDON;
		if(viewName == 'BatchHistory') {
			batchOppGenColumn.isSortable = true;
		} else {
			batchOppGenColumn.isSortable = false;
		}
		batchOppGenColumn.isVisible = false;
		batchOppGenColumn.isDateCol = true;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Last Modified By
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_LAST_MOD_DT;
		batchOppGenColumn.label = 'Last Modified By';
		batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_LAST_MOD_NAME;
		if(viewName == 'BatchHistory') {
			batchOppGenColumn.isSortable = true;
			batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		} else {
			batchOppGenColumn.isSortable = false;
		}
		batchOppGenColumn.isVisible = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		if(viewName == 'BatchHistory') {
			//Opportunity Amount Total
			batchOppGenColumn = new CSM_GridColumnWrapper();
			batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_Constants.REN_OPP_AMOUNT_TOTL;
			batchOppGenColumn.label = Schema.REN_Batch_Activity__c.fields.REN_Total_Amount__c.getDescribe().getLabel() 
			        + ' ('+UserInfo.getDefaultCurrency() +')';
			batchOppGenColumn.valueCol = CSM_Util.getNamespace() + REN_Constants.REN_OPP_AMOUNT_TOTL;
			batchOppGenColumn.dataAlign = 'right';
			batchOppGenColumn.isSortable = true;
			batchOppGenColumn.customColumnSorter = 'customColumnSorter';
			batchOppGenColumn.isVisible = false;
			batchOppGenColumn.isCurrencyCol = true;
			gridClmWrapper.add(batchOppGenColumn);
		}
		
		return gridClmWrapper;
	}
	
	private List<REN_Batch_Activity__c> getRecordList(){
		List<REN_Batch_Activity__c> batchActList = REN_BatchActivityDataAccess.getBatchActivityRecords(this.inputWrapper.viewName);
		if (batchActList == null){
			batchActList = new List<REN_Batch_Activity__c>();
		}
		return batchActList;
	}
	
	private List<CSM_GridRowWrapper> getGridDataRows(List<sObject> sObjectList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		String userTimeZone = String.valueOf(UserInfo.getTimeZone());
		for(sObject sObj : sObjectList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			row.id = (String)sObj.get('Id'); 
			row.sObj = sObj;
			status = (String)sObj.get('REN_Status__c');
			generated = (Decimal)sObj.get('REN_Generated_Records__c');
			failedAssets = (Decimal)sObj.get('REN_Failure_Assets__c');
			row.namespace = CSM_Util.getNamespace();
			row.isMC = CSM_Util.checkMCEnabled();
			setRowAction(row);
			row.columns = new List<CSM_GridColumnWrapper>();
			if (colList!=null){
				row.columns = colList;
				gridRowWrapper.add(row);
			}
		}
		return gridRowWrapper;
	}
	
	private void setRowAction(CSM_GridRowWrapper row){
		if(status == 'Scheduled')
		{
			row.actions = new List<CSM_GridActionWrapper>();
			if((this.inputWrapper.viewName).equalsIgnoreCase('BatchHistory')){
				if(displayEditOption)
				{	
					CSM_GridActionWrapper editWrap = new CSM_GridActionWrapper('Edit');
					editWrap.hrefAction = '/apex/ren_batchoppgeneration?tabCategory=Renewal&id=' + row.id;
					editWrap.titleAction = Label.CSM_LBL_EDIT;
			    	row.actions.add(editWrap);
				}
			
				if(displayDeleteOption){
					CSM_GridActionWrapper deleteWrap = new CSM_GridActionWrapper('Del');
					deleteWrap.hrefAction = 'javascript:void(0);';
					deleteWrap.onclickAction = 'confirmDelete(\''+row.id+'\')';
					deleteWrap.titleAction = Label.REN_Delete;
					row.actions.add(deleteWrap);
				}
			} else {
				if(displayEditOption)
				{	
					CSM_GridActionWrapper editWrap = new CSM_GridActionWrapper('Edit');
					editWrap.hrefAction = '/apex/CSM_BatchPlanTemplateAssignment?tabCategory=SuccessPlan&id=' + row.id;
					editWrap.titleAction = Label.CSM_LBL_EDIT;
			    	row.actions.add(editWrap);
				}
			
				if(displayDeleteOption){
					CSM_GridActionWrapper deleteWrap = new CSM_GridActionWrapper('Del');
					deleteWrap.hrefAction = 'javascript:void(0);';
					deleteWrap.onclickAction = 'confirmDelete(\''+row.id+'\')';
					deleteWrap.titleAction = Label.REN_Delete;
					row.actions.add(deleteWrap);
				}
			}
		}
	}
}