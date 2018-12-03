public with sharing class REN_AssetBusinessLayer extends CSM_BusinessLayer
{
    private String RenewalRelationship = 'Renew_To__r';
    private String RenewalRelationship_plural = 'REN_Renews_To__r';
    
    public REN_AssetBusinessLayer(CSM_CustomGridInputWrapper inputWrapper)
    {
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList()
    {
        return getAssetWrapperList();
    }
    
    private CSM_GridResponseWrapper getAssetWrapperList()
    {
        //business logic for setting up Lists for <CSM_GridRowWrapper> and <CSM_GridColumnWrapper>
        CSM_GridResponseWrapper assetWrapperList = new CSM_GridResponseWrapper();
        
        List<sObject> assetList;
        assetWrapperList.header = setAssetHeader();
       
        if(this.inputWrapper.params.selectedFilterClause == null)
        {
            assetList = REN_AssetDataAccess.getAssetsByAccount(this.inputWrapper.params.accountId, null, null,this.inputWrapper.params.gridCurrency); //Remove this and use the method in the else
            assetWrapperList.hasCheckbox = false;
        }
        else 
        {
        	if(this.inputWrapper.viewName=='AssetView')
        	{
        		assetList = REN_AssetDataAccess.getAssetsForClause(this.inputWrapper.params.selectedFilterClause, false,this.inputWrapper.params.gridCurrency);
	            assetWrapperList.hasCheckbox = false;
        	}
        	else{
	            assetList = REN_AssetDataAccess.getAssetsForClause(this.inputWrapper.params.selectedFilterClause, false,this.inputWrapper.params.gridCurrency);
	            assetWrapperList.hasCheckbox = true;
        	}
        }
        //setup the CSM_GridColumnWrapper object for header values, 
        //since this is specific for Task, we know what the headers need to set specifically
        
        
        assetWrapperList.hasAction = false;
        assetWrapperList.hasDetail = false;
        //setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
        assetWrapperList.row = setAssetRows(assetList, assetWrapperList.header);
        return assetWrapperList;
    }
    
    private List<CSM_GridRowWrapper> setAssetRows(List<sObject> assetList, List<CSM_GridColumnWrapper> colList)
    {
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		String nameSpacePrefix = CSM_Util.getNamespace();
        if(assetList != null && !assetList.isEmpty())
        {
            for(sObject sObj : assetList)
            {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
              
                row.id = (String)sObj.get('Id');
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
				row.namespace = CSM_Util.getNamespace();
                row.columns = new List<CSM_GridColumnWrapper>();
                if(colList != null)
                {
			        if(!UserInfo.isMultiCurrencyOrganization())
					{
						row.columns = colList;
					}
					else{
	                    SObject assetObj = SObj.clone();
						for(CSM_GridColumnWrapper colOrig :colList)
						{
	                        CSM_GridColumnWrapper col = colOrig.clone();
							//strColumn = String.valueOf(sObj.get(col.valueCol))                       						
					        //if(UserInfo.isMultiCurrencyOrganization())
					        //{
								if('Price'.equalsIgnoreCase(col.valueCol))
								{
									String strColumn = String.ValueOf(assetObj.get(col.valueCol));
									if(strColumn !=null && strColumn != ''){
										Double assetPrice = Double.ValueOf(assetObj.get(col.valueCol));
		            					Decimal assetPriceDecimal = REN_Util.convertCurrencyValue(assetPrice,UserInfo.getDefaultCurrency(),inputWrapper.params.gridCurrency);										
										
										assetPriceDecimal = assetPriceDecimal.setscale(2);
										col.value  = assetPriceDecimal.format();
										//assetObj.put(col.valueCol, Double.ValueOf(col.value));										
									}
								}
					        //}
						row.columns.add(col);
						}               	
					}
                	
			        
                	/* 
                    for(CSM_GridColumnWrapper colOrig :colList)
                    {
                        CSM_GridColumnWrapper col = colOrig.clone();
                        if(col.valueCol.contains('.'))
                        {
                            String[] objSplit = col.valueCol.split('\\.');
                            if(objSplit != null && objSplit.size() == 2)
                            {
                                try
                                {
                                    col.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
                                    if (col.isDateCol!=null && col.isDateCol && String.isNotBlank(col.value)){
				                        Boolean tempIsDateTime = CSM_Util.isDateTime(col.value);
				                        Boolean tempIsDate = CSM_Util.isDate(col.value);
				                        if (tempIsDateTime || tempIsDate) {
				                            Datetime currentDateVal = null;
				                                
				                            if (tempIsDateTime)
				                            {
				                                currentDateVal = Datetime.valueOf(col.value);
				                            }
				                            else 
				                            {
				                                Date tempDate = Date.valueOf(col.value);
				                                currentDateVal = Datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
				                            }
				                            col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal , localeMap);
				                            col.hiddenDate = String.valueOfGmt(currentDateVal);
				                        }
				                    }
                                }
                                catch(Exception e)
                                {
                                }
                            }
                        }
                        else
                        {
                            if('Opportunity'.equalsIgnoreCase(col.valueCol))
                            {
                                List<SObject> rRelationships = new List<Sobject>();
                                rRelationships = sObj.getSObjects(RenewalRelationship);
                                system.debug('rRelationships : ' + rRelationships);
                                if(rRelationships != null && !rRelationships.isEmpty())
                                {
                                    for(Integer a = 0; a < rRelationships.size(); a++)
                                    {
                                        sObject sobj1 = rRelationships[a].getSObject(RenewalRelationship_plural);
                                        if(sobj1 != null)
                                        {
                                            col.value = (String)sobj1.get('Name');
                                            col.lookUpId = String.valueOf(rRelationships[a].get(col.lookUpIdCol));          
                                        }
                                    }
                                }
                            }
                            else if('Stage'.equalsIgnoreCase(col.valueCol))
                            {
                                List<SObject> rRelationships = new List<Sobject>();
                                rRelationships = sObj.getSObjects(RenewalRelationship);
                                system.debug('rRelationships : ' + rRelationships);
                                if(rRelationships != null && !rRelationships.isEmpty())
                                {
                                    for(Integer a = 0; a < rRelationships.size(); a++)
                                    {
                                        sObject sobj1 = rRelationships[a].getSObject(RenewalRelationship_plural);
                                        if(sobj1 != null)
                                        {
                                            col.value = (String)sobj1.get('StageName');
                                        }
                                    }
                                }
                            }
                            else if('CloseDate'.equalsIgnoreCase(col.valueCol))
                            {
                                List<SObject> rRelationships = new List<Sobject>();
                                rRelationships = sObj.getSObjects(RenewalRelationship);
                                system.debug('rRelationships : ' + rRelationships);
                                if(rRelationships != null && !rRelationships.isEmpty())
                                {
                                    for(Integer a = 0; a < rRelationships.size(); a++)
                                    {
                                        sObject sobj1 = rRelationships[a].getSObject(RenewalRelationship_plural);
                                        if(sobj1 != null)
                                        {
                                            col.value = String.valueOf(sobj1.get('CloseDate'));
                                        }
                                        if (col.isDateCol!=null && col.isDateCol && String.isNotBlank(col.value)){
					                        Boolean tempIsDateTime = CSM_Util.isDateTime(col.value);
					                        Boolean tempIsDate = CSM_Util.isDate(col.value);
					                        if (tempIsDateTime || tempIsDate) {
					                            Datetime currentDateVal = null;
					                                
					                            if (tempIsDateTime)
					                            {
					                                currentDateVal = Datetime.valueOf(col.value);
					                            }
					                            else 
					                            {
					                                Date tempDate = Date.valueOf(col.value);
					                                currentDateVal = Datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
					                            }
					                            col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal , localeMap);
					                            col.hiddenDate = String.valueOfGmt(currentDateVal);
					                        }
					                    }
                                    }
                                }
                            }
                            else
                            {
                                if('Price'.equalsIgnoreCase(col.valueCol) && String.valueOf(sObj.get(col.valueCol))!=null)
								{
									Decimal ceilingAmount=Double.valueOf(sObj.get(col.valueCol));		
									col.value  = ceilingAmount == null?'':CSM_Util.formatCurrency(String.valueOf(ceilingAmount));
									col.hiddenValue = ceilingAmount == null?'0':String.valueOf(ceilingAmount);
								}
								else{								
                                	col.value = String.valueOf(sObj.get(col.valueCol));
                                	if(col.isNumberCol != null && col.isNumberCol)
			                        {
			                            if (String.isEmpty(col.value))
			                            {
			                                col.value  = '';
			                                col.hiddenValue = '0';
			                            }
			                            else
			                            {
			                                Double doubleValue = Double.valueOf(col.value);
			                                col.value  = doubleValue.format();
			                                col.hiddenValue = String.valueOf(doubleValue);
			                            }
			                        }
								}
                                try
                                {
									if (col.isDateCol!=null && col.isDateCol && String.isNotBlank(col.value)){
				                        Boolean tempIsDateTime = CSM_Util.isDateTime(col.value);
				                        Boolean tempIsDate = CSM_Util.isDate(col.value);
				                        if (tempIsDateTime || tempIsDate) {
				                            Datetime currentDateVal = null;
				                                
				                            if (tempIsDateTime)
				                            {
				                                currentDateVal = Datetime.valueOf(col.value);
				                            }
				                            else 
				                            {
				                                Date tempDate = Date.valueOf(col.value);
				                                currentDateVal = Datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
				                            }
				                            col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal , localeMap);
				                            col.hiddenDate = String.valueOfGmt(currentDateVal);
				                        }
				                    }
                                }
                                catch(Exception e)
                                {
                                }
                            }
                        }
                    
                    
                        if(col.lookUpIdCol != null && col.lookUpIdCol.length() > 0)
                        {
                            if(!('Opportunity'.equalsIgnoreCase(col.valueCol) || 'Stage'.equalsIgnoreCase(col.valueCol) || 'CloseDate'.equalsIgnoreCase(col.valueCol)))
                            {
                                col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
                            }
                        }
                        if(col.value == null || (col.value).contains('null'))
                        {
                            col.value = '';
                        }
                        row.columns.add(col);
                    }   
                    */
                    //row.sObj = assetObj;
                    gridRowWrapper.add(row);
                }                           
            }
            
        }
        return gridRowWrapper;
    }
    
    private List<CSM_GridColumnWrapper> setAssetHeader()
    {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has te be maintained for the headers to be set and the response columns
        CSM_GridColumnWrapper colNew = new CSM_GridColumnWrapper();
        
        
        colNew.apiName ='Account.Name';
        colNew.label = Schema.SobjectType.Account.fields.Name.label;
        colNew.valueCol = 'Account.Name';
        colNew.lookUpIdCol = 'AccountId';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);
        
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Name';
        colNew.label = 'Asset Name';
        colNew.valueCol = 'Name';
        //colNew.lookUpId = 'Name';
        colNew.lookUpIdCol = 'Id';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'SerialNumber';
        colNew.label = 'Serial Number';
        colNew.valueCol = 'SerialNumber';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);

        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Product2.Name';
        colNew.label = 'Product Name';
        colNew.valueCol = 'Product2.Name';
        colNew.lookUpIdCol = 'Product2Id';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Quantity';
        colNew.label = 'Quantity';
        colNew.valueCol = 'Quantity';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        colNew.dataAlign = 'right';
        colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);

        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Price';
        colNew.label = 'Price';
        colNew.valueCol = 'Price';
        colNew.dataAlign = 'right';
        colNew.isCurrencyCol = true;
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        if(UserInfo.isMultiCurrencyOrganization())
        {
			system.debug('cuuuuur' + inputWrapper.params.gridCurrency);
        	colNew.label = colNew.label + ' ('+inputWrapper.params.gridCurrency +')';
        }else{
        	colNew.label = colNew.label + ' ('+UserInfo.getDefaultCurrency() +')';        
        }
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Status';
        colNew.label = 'Status';
        colNew.valueCol = 'Status';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Start_Date__c';
        colNew.label = 'Start Date';
        colNew.valueCol = 'REN_Start_Date__c';
        colNew.isSortable = true;
        colNew.isDateCol = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_End_Date__c';
        colNew.label = 'End Date';
        colNew.valueCol = 'REN_End_Date__c';
        colNew.isSortable = true;
        colNew.isDateCol = true;
        gridClmWrapper.add(colNew);
        
        //Opportunity       
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'OpportunityName';
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