public with sharing class CHL_PipeLineChartBusinessLayer {
	
	public CHL_GridInputWrapper inputWrapper;	
    
    public CHL_PipeLineChartBusinessLayer(CHL_GridInputWrapper inputWrapper){
		this.inputWrapper = inputWrapper;	    	
    }
    
    public CHL_ChartResponseWrapper constructChartWrapper()	{
    	   	
    	//Set <String> quarterSet = this.inputWrapper.queryParams.quarter;
    	Set<String> quarterSet = new Set<String>();
    	Set<String> countrySet = new Set<String>();
    	Set<String> resellerRepSet = new Set<String>();
    	Set<String> distributerRepSet = new Set<String>();
    	Set<String> yearSet = new Set<String>();
    	
    	//Added for US1119
    	if(this.inputWrapper.queryParams.quarters != null && !this.inputWrapper.queryParams.quarters.isEmpty()) {
    		quarterSet = this.inputWrapper.queryParams.quarters;
    	} else {
    		CHL_CurrentQuarter currentQtr = CHL_Util.getCurrentQuarter();
			quarterSet.add(currentQtr.id);
    	}
    	if(this.inputWrapper.queryParams.years != null && !this.inputWrapper.queryParams.years.isEmpty()) {
    		yearSet = this.inputWrapper.queryParams.years;
    	} else {
    		CHL_CurrentYear currentYearObj = CHL_Util.getCurrentYear();
			yearSet.add(currentYearObj.Id);
    	}
    	if(this.inputWrapper.queryParams.countries == null) {
    		countrySet.add(CHL_Constants.STR_ALL);
    	} else {
    		countrySet = this.inputWrapper.queryParams.countries;
    	}
    	if(this.inputWrapper.queryParams.resellerReps == null)	{
    		resellerRepSet.add(CHL_Constants.STR_ALL);
    	} else {    	
    		resellerRepSet = this.inputWrapper.queryParams.resellerReps;
    	}
    	if(this.inputWrapper.queryParams.distributorReps == null) {
    		distributerRepSet.add(CHL_Constants.STR_ALL);
    	} else {
    		distributerRepSet = this.inputWrapper.queryParams.distributorReps;
    	}
    	
    	system.debug('IN D CHART LAYER : '+ quarterSet +' : ' + countrySet +' : '+ resellerRepSet +' : '+ distributerRepSet);
	    List<String> pipeLineStages = new List<String>(CHL_Util.getPipelineSalesStage());
		String queryString = '';
		
		String whereClause = CHL_PartnerOverviewUtil.getChartFilterWhereClause(quarterSet,yearSet,countrySet , resellerRepSet, distributerRepSet);
		
		string whereClauseForStage = '';
		if(!pipeLineStages.isEmpty()){
			whereClauseForStage = ' CHL_Sales_Stage__c IN ( \''+String.join(pipeLineStages, '\',\'')+'\')';
		}
		else {
			whereClauseForStage = ' CHL_Sales_Stage__c = null';
		}
		if(whereClause == null || String.isblank(whereClause)) {
			whereClause += whereClauseForStage;
		} else {
			whereClause += ' AND '+ whereClauseForStage;
		}
		system.debug('whereClause : '+whereClause + ':: '+pipeLineStages);
		
		List<AggregateResult> aggResultList = CHL_PartnerOpportunityDataAccess.getChartDataByFilter(whereClause);
		System.debug('\n\n Result : ' + aggResultList);
		
		map<String, map<Boolean,Integer>> chartDatamap = new map<String, map<Boolean,Integer>> ();
		Boolean isMultiCurrency = UserInfo.IsMultiCurrencyOrganization();
		String currencyName = UserInfo.getDefaultCurrency();
		Decimal exchangeRate = 1;
		if(isMultiCurrency){
        	exchangeRate = CSM_Util.getExchangeRateToCorpCurrency(currencyName);
      	} 
      	
      	//Schema.DescribeFieldResult fieldResult = CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe();
	  	Map<String,String> picklistValueLabelMap = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe());
	  	
        String translatedSalesStage = '';  
        Decimal amount;
		for (AggregateResult resultObj: aggResultList) {
			if(picklistValueLabelMap.containskey(string.valueof(resultObj.get(CSM_Util.getNamespace()+CHL_CONSTANTS.OBJ_PO_SALES_STAGE)))) {
        		translatedSalesStage = picklistValueLabelMap.get(string.valueof(resultObj.get(CSM_Util.getNamespace()+CHL_CONSTANTS.OBJ_PO_SALES_STAGE)));        		
      		}
			Map < Boolean, Integer > stageAmountMap = chartDatamap.get(translatedSalesStage);
			if (stageAmountMap == null) {
				stageAmountMap = new Map < Boolean, Integer > ();
				stageAmountMap.put(true, 0);
				stageAmountMap.put(false, 0);
			}
			
			if((Decimal)resultObj.get(CHL_Constants.STR_TOTAL) == null || (Decimal)resultObj.get(CHL_Constants.STR_TOTAL) == 0.0) {
				amount = 0;
			} else {
				amount = (Decimal)resultObj.get(CHL_Constants.STR_TOTAL);
			}
			if (resultObj.get(CSM_Util.getNamespace()+CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE) == true) {
				amount = isMultiCurrency?exchangeRate*amount : amount;
				stageAmountMap.put(true, Integer.valueOf(amount));
			}
			if (resultObj.get(CSM_Util.getNamespace()+CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE) == false) {
				amount = isMultiCurrency?exchangeRate*amount : amount;
				stageAmountMap.put(false, Integer.valueOf(amount));
			}
			system.debug('amount : '+amount+':: '+(Decimal)resultObj.get(CHL_Constants.STR_TOTAL));
			
			
        	system.debug('translatedSalesStage : '+translatedSalesStage+'\n resultObj'+resultObj);
			//chartDatamap.put(string.valueOF(resultObj.get(CSM_Util.getNamespace()+CHL_Constants.OBJ_PO_SALES_STAGE)), stageAmountMap);
			chartDatamap.put(translatedSalesStage, stageAmountMap);
		}
		system.debug('chartDatamap : '+chartDatamap);
		CHL_ChartResponseWrapper resWrapper = new CHL_ChartResponseWrapper(chartDatamap);
		resWrapper.currencyCode = UserInfo.getDefaultCurrency();
		system.debug('\n\n :: ' + JSON.serialize(resWrapper));
    	return resWrapper;
    }
    
   
    
    /**
      * @description : This method returns the filter options for country,reseller reps & distributor reps for pipeline chart on Overview Tab.
    */
    public static CHL_OverviewWrapper partnerOppDetails() {

            Map < String, Map < String, String >> partnerOppInfoMap = new Map < String, Map < String, String >> ();
            partnerOppInfoMap = CHL_PartnerOverviewUtil.partnerOppInfo();
            CHL_OverviewWrapper overviewWrapper = new CHL_OverviewWrapper();
        
            //fetching ResellerList
            List < CHL_OverviewWrapper.CHL_ResellerReps > resellerRepList = new List < CHL_OverviewWrapper.CHL_ResellerReps > ();
            for (String resellerID: partnerOppInfoMap.get('Reseller').keySet()) {
                CHL_OverviewWrapper.CHL_ResellerReps resellerRepObj = new CHL_OverviewWrapper.CHL_ResellerReps();
                resellerRepObj.id = resellerID;
                resellerRepObj.name = partnerOppInfoMap.get('Reseller').get(resellerID);
                if (resellerRepObj.id != null) {
                    resellerRepList.add(resellerRepObj);
                }
            }
            /*CHL_OverviewWrapper.CHL_ResellerReps resellerRepObjALL = new CHL_OverviewWrapper.CHL_ResellerReps();
            resellerRepObjALL.id = 'All';
            resellerRepObjALL.name = 'All';
            resellerRepList.add(resellerRepObjALL);*/
         
            //fetching DistributorList
            List < CHL_OverviewWrapper.CHL_DistributorReps > distributorRepList = new List < CHL_OverviewWrapper.CHL_DistributorReps > ();
            for (String distributorID: partnerOppInfoMap.get('Distributor').keySet()) {
                CHL_OverviewWrapper.CHL_DistributorReps distributorReps = new CHL_OverviewWrapper.CHL_DistributorReps();
                distributorReps.id = distributorID;
                distributorReps.name = partnerOppInfoMap.get('Distributor').get(distributorID);
                if (distributorReps.id != null) {
                    distributorRepList.add(distributorReps);
                }
            }
            /*CHL_OverviewWrapper.CHL_DistributorReps distributorRepsALL = new CHL_OverviewWrapper.CHL_DistributorReps();
            distributorRepsALL.id = 'All';
            distributorRepsALL.name = 'All';
            distributorRepList.add(distributorRepsALL);*/
                   
            //fetching CountryList
            List < String > counrtyList = new List < String > ();
            for (String countryName: partnerOppInfoMap.get('Country').keySet()) {
                counrtyList.add(countryName);
            }
            //counrtyList.add('All');
            system.debug('\n\n counrtyList :: ' + counrtyList +'\n\n resellerRepList :: ' + resellerRepList + '\n\n distributorRepList :: ' + distributorRepList);
           
            overviewWrapper.resellerReps = resellerRepList;
            overviewWrapper.distributorReps = distributorRepList;
            overviewWrapper.countries = counrtyList;
            return overviewWrapper;
    }
    

}