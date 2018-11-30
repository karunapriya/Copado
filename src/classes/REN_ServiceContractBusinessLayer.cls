public with sharing class REN_ServiceContractBusinessLayer extends CSM_BusinessLayer
{
	private String RENEWAL_RELATIONSHIP = 'RenewalRelationship';
	
	public REN_ServiceContractBusinessLayer(CSM_CustomGridInputWrapper inputWrapper)
	{
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList()
	{
		return getRecordWrapperList();
	}
	
	private CSM_GridResponseWrapper getRecordWrapperList()
	{
		system.debug('Eswar this.inputWrapper : ' + this.inputWrapper);
		//business logic for setting up Lists for <CSM_GridRowWrapper> and <CSM_GridColumnWrapper>
		CSM_GridResponseWrapper recordWrapperList = new CSM_GridResponseWrapper();
		
		List<sObject> recordList;
		recordWrapperList.header = setServiceContractHeader();
		if(this.inputWrapper.params.selectedFilterClause == null)
		{
			recordList = REN_ServiceContractsDataAccess.getContractLineItemList(new List<String>{this.inputWrapper.params.accountId}, null, null,this.inputWrapper.params.gridCurrency);
			recordWrapperList.hasCheckbox = false;
		}
		else
        {
			recordList = REN_ServiceContractsDataAccess.getContractLineItemListForClause(this.inputWrapper.params.selectedFilterClause,this.inputWrapper.params.gridCurrency);
            recordWrapperList.hasCheckbox = true;
        }
		
		//setup the CSM_GridColumnWrapper object for header values, 
		//since this is specific for Task, we know what the headers need to set specifically
		
		recordWrapperList.hasAction = false;
		recordWrapperList.hasDetail = false;
		//setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
		recordWrapperList.row = setServiceContractRows(recordList, recordWrapperList.header);
		return recordWrapperList;
	}
	
	private List<CSM_GridRowWrapper> setServiceContractRows(List<sObject> recordList, List<CSM_GridColumnWrapper> colList)
	{
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		String entitlementExtnNamespace = CSM_Util.nameSpacePrefix21;
		Boolean hasRenewalField  = CSM_AccessController.hasField('ContractLineItem',entitlementExtnNamespace + 'REN_Oppty_Line_Item_id__c');
		String clmNamespace = CSM_Util.getNamespace();
		if(recordList != null && !recordList.isEmpty())
		{
			for(sObject sObj : recordList)
			{
				CSM_GridRowWrapper row = new CSM_GridRowWrapper();

                row.id = (String)sObj.get('Id');
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
				row.namespace = clmNamespace;
				row.entNameSpace = entitlementExtnNamespace;
                row.columns = new List<CSM_GridColumnWrapper>();
                if(colList != null)
                {
			        if(!UserInfo.isMultiCurrencyOrganization())
					{
						row.columns = colList;
					}else{
	                    SObject cliObj = SObj.clone();
						for(CSM_GridColumnWrapper colOrig :colList)
						{
	                        CSM_GridColumnWrapper col = colOrig.clone();							
								if('TotalPrice'.equalsIgnoreCase(col.valueCol))
								{
									String strColumn = String.ValueOf(cliObj.get(col.valueCol));
									if(strColumn !=null && strColumn != ''){
										Double totPrice = Double.ValueOf(cliObj.get(col.valueCol));
		            					Decimal totPriceDecimal = REN_Util.convertCurrencyValue(totPrice,UserInfo.getDefaultCurrency(),inputWrapper.params.gridCurrency);										
										totPriceDecimal = totPriceDecimal.setscale(2);
										col.value  = totPriceDecimal.format();
									}
								}
							row.columns.add(col);
						}                	
					}
					gridRowWrapper.add(row);
				}
			}
		}
		
		return gridRowWrapper;
	}
	
	private List<CSM_GridColumnWrapper> setServiceContractHeader()
	{
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Service Contract Name
		CSM_GridColumnWrapper colNew = new CSM_GridColumnWrapper();
		
		colNew.apiName = 'ServiceContract.Account.Name';
		colNew.label = Schema.SobjectType.Account.fields.Name.label;
		colNew.valueCol = 'ServiceContract.Account.Name';
		colNew.lookUpIdCol = 'ServiceContract.AccountId';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'ServiceContract.Name';
		colNew.label = system.label.REN_LBL_SC_NAME;
		colNew.valueCol = 'ServiceContract.Name';
		colNew.lookUpIdCol = 'ServiceContractId';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);

		//Service Contract Number
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'ServiceContract.ContractNumber';
		colNew.label = system.label.REN_LBL_SC_NUMBER;
		colNew.valueCol = 'ServiceContract.ContractNumber';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Line Item Number
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'LineItemNumber';
		colNew.label = system.label.REN_LBL_SC_LI_NUMBER;
		colNew.valueCol = 'LineItemNumber';
		colNew.lookUpIdCol = 'Id';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Product Name
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'PricebookEntry.Product2.Name';
		colNew.label = Schema.SobjectType.Product2.fields.Name.label;
		colNew.valueCol = 'PricebookEntry.Product2.Name';
		colNew.lookUpIdCol = 'PricebookEntry.Product2.Id';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Qty
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'Quantity';
		colNew.label = system.label.REN_LBL_SCLI_QUANTITY;
		colNew.valueCol = 'Quantity';
		colNew.isSortable = true;
		colNew.isNumberCol = true;
		colNew.dataAlign = 'right';
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Price
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'TotalPrice';
		colNew.label = 'Total Price';
		colNew.valueCol = 'TotalPrice';
		colNew.dataAlign = 'right';
		colNew.isCurrencyCol = true;
        if(UserInfo.isMultiCurrencyOrganization())
        {
			system.debug('cuuuuur' + inputWrapper.params.gridCurrency);
			colNew.label = colNew.label + ' ('+inputWrapper.params.gridCurrency +')';
        }else{
			colNew.label = colNew.label + ' ('+UserInfo.getDefaultCurrency() +')';        
        }
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		
		gridClmWrapper.add(colNew);
		
		//Status
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'Status';
		colNew.label = system.label.REN_LBL_SCLI_STATUS;
		colNew.valueCol = 'Status';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Start Date
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'StartDate';
		colNew.label = system.label.REN_LBL_SCLI_START_DATE;
		colNew.valueCol = 'StartDate';
		colNew.isSortable = true;
		colNew.isDateCol = true;
		gridClmWrapper.add(colNew);
		
		//End Date
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'EndDate';
		colNew.label = system.label.REN_LBL_SCLI_END_DATE;
		colNew.valueCol = 'EndDate';
		colNew.isSortable = true;
		colNew.isDateCol = true;
		gridClmWrapper.add(colNew);
			
		//Opportunity		
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'Name';
		colNew.label = 'Renewal Opportunity';
		colNew.valueCol = 'Opportunity';
		colNew.lookUpIdCol = 'REN_Renews_To__c';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Sales Stage
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'StageName';
		colNew.label = Schema.SobjectType.Opportunity.fields.StageName.label;
		colNew.valueCol = 'Stage';
		colNew.isSortable = true;
		colNew.customColumnSorter = 'customColumnSorter';
		gridClmWrapper.add(colNew);
		
		//Close Date
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'CloseDate';
		colNew.label = Schema.SobjectType.Opportunity.fields.CloseDate.label;
		colNew.valueCol = 'CloseDate';
		colNew.isSortable = true;
		colNew.isDateCol = true;
		gridClmWrapper.add(colNew);
		
		return gridClmWrapper;
	}
}