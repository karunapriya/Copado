public with sharing class REN_BatchOppGenFailedSummBusinessLayer extends CSM_BusinessLayer {
public REN_BatchOppGenFailedSummBusinessLayer(CSM_CustomGridInputWrapper inputWrapper)
	{
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList()
	{
		return getBatchOppGenWrapperList();
	}
	
	private CSM_GridResponseWrapper getBatchOppGenWrapperList() 
	{	
		CSM_GridResponseWrapper failedAssetResponseWrapper = new CSM_GridResponseWrapper();
		try
		{
			failedAssetResponseWrapper.header = getGridColumnHeader();
			failedAssetResponseWrapper.row = getGridDataRows(getRecordList(), failedAssetResponseWrapper.header);
			failedAssetResponseWrapper.hasCheckbox = false;
			failedAssetResponseWrapper.hasAction = false;
			failedAssetResponseWrapper.hasDetail = false;
	        system.debug('\n\n~~~gridResponseWrapper: '+failedAssetResponseWrapper);
		}
		catch(Exception e)
		{
			failedAssetResponseWrapper.errorMessage = e.getMessage();
			system.debug(e);
		}
        return failedAssetResponseWrapper;
	}
	
	private List<CSM_GridColumnWrapper> getGridColumnHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper batchOppGenColumn = new CSM_GridColumnWrapper();
		
		//Account name
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + 'REN_Asset__r.Account.Name';
		batchOppGenColumn.label = 'Account';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + 'REN_Asset__r.Account.Name';
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		
		//Asset
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName =  CSM_Util.getNamespace() + REN_CONSTANTS.OBJ_REN_RENEWS_TO_ASSET;
		batchOppGenColumn.label = 'Asset Name';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + REN_CONSTANTS.REN_RECORD_NAME;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		batchOppGenColumn.lookUpIdCol = CSM_Util.getNamespace() + REN_CONSTANTS.REN_RECORDID;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Product name
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + 'REN_Asset__r.Product2.Name';
		batchOppGenColumn.label = 'Product';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + 'REN_Asset__r.Product2.Name';
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Amount
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + 'REN_Asset__r.Price';
		batchOppGenColumn.label = 'Amount';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + 'REN_Asset__r.Price';
		batchOppGenColumn.dataAlign = 'right';
		batchOppGenColumn.isCurrencyCol = true;
		batchOppGenColumn.label = batchOppGenColumn.label + ' ('+UserInfo.getDefaultCurrency() +')';
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		//End Date
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + 'REN_Asset__r.REN_End_Date__c';
		batchOppGenColumn.label = 'End Date';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + 'REN_Asset__r.REN_End_Date__c';
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.isDateCol = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		//Message
		batchOppGenColumn = new CSM_GridColumnWrapper();
		batchOppGenColumn.apiName = CSM_Util.getNamespace() + REN_CONSTANTS.REN_MSG;
		batchOppGenColumn.label = 'Reason for Failure';
		batchOppGenColumn.valueCol =  CSM_Util.getNamespace() + REN_CONSTANTS.REN_MSG;
		batchOppGenColumn.isSortable = true;
		batchOppGenColumn.customColumnSorter = 'customColumnSorter';
		batchOppGenColumn.isDateCol = false;
		gridClmWrapper.add(batchOppGenColumn);
		
		
		return gridClmWrapper;
	}
	
	private List<REN_Batch_Opportunity_Failure__c> getRecordList(){
		List<REN_Batch_Opportunity_Failure__c> failedAssetsList = REN_BatchOppFailureDataAccess.getFailedAssetsRecords(this.inputWrapper.params.taskOrViewId);
		if (failedAssetsList == null){
			failedAssetsList = new List<REN_Batch_Opportunity_Failure__c>();
		}
		return failedAssetsList;
	}
	
	private List<CSM_GridRowWrapper> getGridDataRows(List<sObject> sObjectList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		
		for(sObject sObj : sObjectList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			row.sObj = sObj;
			row.columns = new List<CSM_GridColumnWrapper>();
			row.isMC = CSM_Util.checkMCEnabled();
			row.namespace = CSM_Util.getNamespace();
			if (colList!=null){
				row.columns = colList;
				/*
				for (CSM_GridColumnWrapper colOrig : colList){
					CSM_GridColumnWrapper col = colOrig.clone();
					
					if (col.valueCol.contains('.')){
						String[] objSplit = col.valueCol.split('\\.');
						if (objSplit!=null && objSplit.size()==2 && sObj.getSObject(objSplit[0]) != null){
							col.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
						}
						if (objSplit!=null && objSplit.size()==3 && sObj.getSObject(objSplit[0]) != null){
							if(sObj.getSObject(objSplit[0]).get('AccountId') != null  && col.valueCol.contains('Account')){
								col.value = String.valueOf(sObj.getSObject(objSplit[0]).getSObject(objSplit[1]).get(objSplit[2]));
							}
							if (sObj.getSObject(objSplit[0]).get('Product2Id') != null && col.valueCol.contains('Product2')){
								col.value = String.valueOf(sObj.getSObject(objSplit[0]).getSObject(objSplit[1]).get(objSplit[2]));
							}
						}
					}
					else
					{
						col.value = String.valueOf(sObj.get(col.valueCol));
					}
					
					if (col.lookUpIdCol!=null && col.lookUpIdCol.length()>0){
						//col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
						system.debug('>>>::'+col.lookUpIdCol);
						col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
					}
				    
				    if (col.isCurrencyCol != null && col.isCurrencyCol) {
				    	String currencyPrefix = '';
						
						if (String.isEmpty(col.value))
						{
							col.value  = '';
						    col.hiddenValue = '0';
						}
						else
						{    
						    Decimal ceilingAmount = Double.valueOf(col.value);		
						    col.value  = CSM_Util.formatCurrency(String.valueOf(ceilingAmount));
						    col.hiddenValue = String.valueOf(ceilingAmount);
						}
				    }
					row.columns.add(col);
				}	
				*/
				gridRowWrapper.add(row);
			}
		}
		
		return gridRowWrapper;
	}
}