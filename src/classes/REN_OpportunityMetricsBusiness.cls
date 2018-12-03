public with sharing class REN_OpportunityMetricsBusiness {
	
	/*
        //Calculate and update below fields on Opportunity:
        1. REN_Earliest_Expiration_Date__c = Min (REN_End_Date__c) on RR relatedlist.
        2. REN_Renewal_Target__c  = ∑ (REN_Previous_Price__c * REN_Renewal_Target_Multiplier__c) on RR relatedlist.
        3. REN_Renewal_Target_Resolved__c = ∑ (REN_Previous_Price__c * REN_Renewal_Target_Multiplier__c) on RR related-list where REN_Renewal_Status__c != 'Open'.
        4. REN_Renewal_Target_Lost__c  = ∑ (REN_Previous_Price__c * REN_Renewal_Target_Multiplier__c) on RR related-list where REN_Renewal_Status__c == 'Lost'.
        5. REN_Renewal_Target_Won__c  = ∑ (REN_Previous_Price__c * REN_Renewal_Target_Multiplier__c) on RR related-list where REN_Renewal_Status__c == 'Won'.
        6. REN_AddsAmount__c  = ∑ (TotalPrice) on OpportunityLineItem related-list where REN_Is_CLM_Renewal__c == FALSE.
		
		Note: Do not rely on Opportunity’s Amount field for accuracy while calling this method from trigger. 
		It is Rollup field and will be updated almost at the end part of transaction. Calculate total amount from OLI’s TotalPrice field. 
	*/	
	public static void resetRliAndOliMetricsFields(Set<ID> oppIdSet){
		List<Opportunity> changedExpDateOppList = new List<Opportunity>();
	    List<String> fieldListForCrudFls = new List<String>{'REN_Renewal_Target__c','REN_AddsAmount__c'};
		List<Opportunity> oppListToUpdate = setRliAndOliMetricsFields(oppIdSet, changedExpDateOppList, fieldListForCrudFls, false);
		REN_OpportunityDataAccess.UpdateExpQuarterYear(changedExpDateOppList, null);		
	    CSM_OpportunityDataAccess.updateOpportunityList(oppListToUpdate, fieldListForCrudFls);
	}
	
	public static void resetMetricsFieldsOnChangedOpportunity(List<Opportunity> changedOppList, Map<ID,OpportunityLineItem>mapOfOppToOLI, List<Opportunity> changedExpDateOppList){							
		Map<ID,Opportunity> changedOppMap = new Map<ID, Opportunity>(changedOppList);		  
	    List<String> fieldListForCrudFls = new List<String>{'REN_Renewal_Target__c','REN_AddsAmount__c'};
		//call common method here
		List<Opportunity> changedExpDateOppLocalList = new List<Opportunity>();	
	    List<Opportunity> oppListToUpdate = setRliAndOliMetricsFields(changedOppMap.keySet(), changedExpDateOppLocalList, fieldListForCrudFls, true);
		Opportunity changedOpp = null;
		List<OpportunityLineItem> OliToUpdate =new List<OpportunityLineItem>();		
		Map<id,Opportunity> changedExpDateOppMap = null;
	    if(changedExpDateOppLocalList != null && !changedExpDateOppLocalList.isEmpty()){
	    	changedExpDateOppMap = new  Map<id,Opportunity>(changedExpDateOppLocalList);
	    }else{
	    	changedExpDateOppMap = new Map<id,Opportunity>();
	    }
	    String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
	    for(Opportunity opp: oppListToUpdate){
	    	changedOpp = changedOppMap.get(opp.id);
	    	if(changedExpDateOppMap.containsKey(opp.id)){
	    		changedExpDateOppList.add(changedOpp);						
	    	}	
	    	changedOpp.REN_Earliest_Expiration_Date__c = opp.REN_Earliest_Expiration_Date__c;
	    	changedOpp.REN_EQ__c = opp.REN_EQ__c;
	    	changedOpp.REN_FY__c = opp.REN_FY__c;  
	    	if(isSolutionExtnInstalled){
				changedOpp.put(solnExtnNamespace + 'Local_Renewal_Target__c',String.valueOf(opp.get(solnExtnNamespace + 'Local_Renewal_Target__c')));
			}
    		changedOpp.REN_Renewal_Target__c = opp.REN_Renewal_Target__c;
    		if(SS_Constants.isSimplifiedDataModelEnabled && mapOfOppToOLI.get(changedOpp.id) != null  && mapOfOppToOLI.get(changedOpp.id).REN_Is_CLM_Renewal__c == true){
				//updating oli here with sum of all privious price and assign to sales price
				mapOfOppToOLI.get(changedOpp.id).UnitPrice = Opp.REN_Renewal_Target__c;
				OliToUpdate.add(mapOfOppToOLI.get(changedOpp.id));
	    	}
	    	if(opp.REN_Is_CLM_Renewal__c != true){
	    		changedOpp.REN_Renewal_Target__c = 0;
	    	}
	    }
	    if(OliToUpdate != null && !OliToUpdate.isEmpty()){
            REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(OliToUpdate);
        }
	}
	
	private static List<Opportunity> setRliAndOliMetricsFields(Set<ID> oppIdSet, List<Opportunity> changedExpDateOppList, List<String> fieldListForCrudFls, boolean isOppUpdateFlow){
		if(oppIdSet == null || oppIdSet.isEmpty()){
			return new List<Opportunity>();
		}
        String filterString = getFilterString(isOppUpdateFlow);
	    List<Opportunity> oppListToUpdate = REN_OpportunityDataAccess.getOpptyListToProcesss(oppIdSet, filterString);
	    Map<id,Opportunity> oppIdToOppMap = new Map<id,Opportunity>(oppListToUpdate);
	    
	    Schema.SObjectType tOppt = Schema.getGlobalDescribe().get(CSM_Constants.OBJ_OPPORTUNITY);
		Schema.DescribeSObjectResult rOppt = tOppt.getDescribe();
	    
	    String clmNamespace = CSM_Util.getNamespace();
	    Integer renewalTargetScale = CSM_Util.getFieldScaleOptimized(rOppt,(clmNamespace +'REN_Renewal_Target__c').toLowerCase());
		//for oli
		Integer addsAmountScale = CSM_Util.getFieldScaleOptimized(rOppt,(clmNamespace +'REN_AddsAmount__c').toLowerCase());
		// metric Calculatation for RLI
		oppIdToOppMap = setRenewalTarget(oppIdToOppMap, changedExpDateOppList, renewalTargetScale, fieldListForCrudFls);		
		// metric Calculatation for OLI
		oppIdToOppMap = setAddsAmount(oppIdToOppMap,addsAmountScale);
	    return oppIdToOppMap.values();
	}

	private static set<String> getStatusForRessolve(Map<String, Set<String>> statusValueMap){
		set<String> RessolveStatus = new set<String>();
		if(statusValueMap != null && !statusValueMap.isEmpty()){
			if(statusValueMap.get('Won') != null && !statusValueMap.get('Won').isEmpty()){
				ressolveStatus.addall(statusValueMap.get('Won'));
			}
			if(statusValueMap.get('Lost') != null && !statusValueMap.get('Lost').isEmpty()){
		    	ressolveStatus.addall(statusValueMap.get('Lost'));
			}
		}
		return RessolveStatus;
	}
	
	private static set<String> getStatusForWon(Map<String, Set<String>> statusValueMap){
		set<String> wonStatus = new set<String>();
		if(statusValueMap != null && !statusValueMap.isEmpty()){
			if(statusValueMap.get('Won') != null && !statusValueMap.get('Won').isEmpty()){
				wonStatus.addall(statusValueMap.get('Won'));
			}
		}
		return wonStatus;
	}
	
	private static set<String> getStatusForLost(Map<String, Set<String>> statusValueMap){
		set<String> lostStatus = new set<String>();
		if(statusValueMap != null && !statusValueMap.isEmpty()){
			if(statusValueMap.get('Lost') != null && !statusValueMap.get('Lost').isEmpty()){
				lostStatus.addall(statusValueMap.get('Lost'));
			}
		}
		return lostStatus;
	}
	
	public static List<Opportunity> setRliMetricsFields(Set<ID> oppIdSet,List<Opportunity> changedExpDateOppList, List<String> fieldListForCrudFls, boolean isOppUpdateFlow){
		List<Opportunity> oppListToUpdate = getOpportunityWithRli(oppIdSet,isOppUpdateFlow);
		Map<id,Opportunity> oppIdToOppMap = new Map<id,Opportunity>(rliMetricsFieldsCalculation(oppListToUpdate, changedExpDateOppList, fieldListForCrudFls));
		
		return oppIdToOppMap.values();
	}
	
	public static List<Opportunity> getOpportunityWithRli(Set<ID> oppIdSet, boolean isOppUpdateFlow){
		String filterString = getFilterString(isOppUpdateFlow);
	    List<Opportunity> oppListToUpdate = new List<Opportunity>();
	    oppListToUpdate = REN_OpportunityDataAccess.getOpptyListToProcesss(oppIdSet, filterString);
	    
	    return oppListToUpdate;
	}
	
	public static List<Opportunity> rliMetricsFieldsCalculation(List<Opportunity> oppListToUpdate, List<Opportunity> returnChangedExpDateOppList, List<String> fieldListForCrudFls){
		if(oppListToUpdate == null || oppListToUpdate.isEmpty()){
			return new List<Opportunity>();
		}
		Map<id,Opportunity> oppIdToOppMap = new Map<id,Opportunity>(oppListToUpdate);
	    Schema.SObjectType tOppt = Schema.getGlobalDescribe().get(CSM_Constants.OBJ_OPPORTUNITY);
		Schema.DescribeSObjectResult rOppt = tOppt.getDescribe();    
	    String clmNamespace = CSM_Util.getNamespace();
	    Integer renewalTargetScale = CSM_Util.getFieldScaleOptimized(rOppt,(clmNamespace +'REN_Renewal_Target__c').toLowerCase());
		// metric Calculatation for RLI
		oppIdToOppMap = setRenewalTarget(oppIdToOppMap, returnChangedExpDateOppList, renewalTargetScale, fieldListForCrudFls);			
	
	    return oppIdToOppMap.values();
	}
	
	public static void setRliMetricsFieldsOnOpportunity(List<Opportunity> oppList){
	    Map<id,Opportunity> oppIdToOppMap = new Map<id,Opportunity>(oppList);	   
	    Schema.SObjectType tOppt = Schema.getGlobalDescribe().get(CSM_Constants.OBJ_OPPORTUNITY);
		Schema.DescribeSObjectResult rOppt = tOppt.getDescribe();    
	    String clmNamespace = CSM_Util.getNamespace();
	    Integer renewalTargetResolvedScale = CSM_Util.getFieldScaleOptimized(rOppt,(clmNamespace +'REN_Renewal_Target_Resolved__c').toLowerCase());
		Integer renewalTargetLostScale = CSM_Util.getFieldScaleOptimized(rOppt,(clmNamespace +'REN_Renewal_Target_Lost__c').toLowerCase());
		Integer renewalTargetWonScale = CSM_Util.getFieldScaleOptimized(rOppt,(clmNamespace +'REN_Renewal_Target_Won__c').toLowerCase());
		// metric Calculatation for RLI
		Map<String, Set<String>> statusValueMap =new Map<String, Set<String>>();
		set<String> ressolveStatus = new set<String>();
	    set<String> wonStatus = new set<String>();
	    set<String> lostStatus = new set<String>();
	    statusValueMap = REN_ValueMappingDataAccess.getRenewalStatusByInternalStatus();
	   	ressolveStatus = getStatusForRessolve(statusValueMap);
	    wonStatus = getStatusForWon(statusValueMap);
	    lostStatus = getStatusForLost(statusValueMap);
	    oppIdToOppMap = setRenewalTargetResolved(oppIdToOppMap, renewalTargetResolvedScale, ressolveStatus);
		oppIdToOppMap = setRenewalTargetLost(oppIdToOppMap, renewalTargetLostScale, lostStatus);
		oppIdToOppMap = setRenewalTargetWon(oppIdToOppMap, renewalTargetWonScale, wonStatus);
	}
	
	private static Map<id,Opportunity> setRenewalTargetResolved(Map<id,Opportunity> oppIdToOppMap, Integer renewalTargetResolvedScale, set<String> ressolveStatus){
		String whereClause = '';
		if(ressolveStatus.isEmpty()){
		 	whereClause = '(' + 'REN_Renewal_Status__c =' + '\'' + 'WON' + '\'' +
		    		 					 ' OR REN_Renewal_Status__c =' + '\'' + 'Lost' + '\'' + ')' ;
		}							 
		AggregateResult[] rliResultsForResolved = getListWithAggregateGroupBy('SUM', 'REN_Renewal_Target_Number__c', new Set<String>{'REN_Renews_To__c'},'REN_Renews_To__c', whereClause, oppIdToOppMap.keyset(), ressolveStatus);          
		Set<ID> aggregateOppSet = new Set<ID>();
		for(AggregateResult  ar :rliResultsForResolved){
			Id oppId  = (Id)ar.get(CSM_Util.getNameSpace() + 'REN_Renews_To__c');
			aggregateOppSet.add(oppId);
			oppIdToOppMap.get(oppId).put(CSM_Util.getNameSpace() + 'REN_Renewal_Target_Resolved__c',ar.get('expr0'));
			oppIdToOppMap.get(oppId).REN_Renewal_Target_Resolved__c = oppIdToOppMap.get(oppId).REN_Renewal_Target_Resolved__c == null ? 0 : oppIdToOppMap.get(oppId).REN_Renewal_Target_Resolved__c.setScale(renewalTargetResolvedScale, RoundingMode.CEILING);			
		}
		for(ID oppId: oppIdToOppMap.keySet()){
			if(!aggregateOppSet.contains(oppId)){
				oppIdToOppMap.get(oppId).REN_Renewal_Target_Resolved__c =  0;
			}
		}
		return oppIdToOppMap;
	}
	
	private static Map<id,Opportunity> setRenewalTargetLost(Map<id,Opportunity> oppIdToOppMap, Integer renewalTargetLostScale, set<String> lostStatus){
		String whereClauseForLostStaus ='';
		if(lostStatus.isEmpty()){
		 	whereClauseForLostStaus = '(' + 'REN_Renewal_Status__c =' + '\'' + 'LOST' + '\'' + ')' ;
		}
		AggregateResult[] rliResultsForLost = getListWithAggregateGroupBy('SUM', 'REN_Renewal_Target_Number__c', new Set<String>{'REN_Renews_To__c'},'REN_Renews_To__c', whereClauseForLostStaus, oppIdToOppMap.keyset(), lostStatus);          
		Set<ID> aggregateOppSet = new Set<ID>();
		for(AggregateResult  ar : rliResultsForLost){
			Id oppId  = (Id)ar.get(CSM_Util.getNameSpace() + 'REN_Renews_To__c');
			aggregateOppSet.add(oppId);
			oppIdToOppMap.get(oppId).put(CSM_Util.getNameSpace() + 'REN_Renewal_Target_Lost__c',ar.get('expr0'));
			oppIdToOppMap.get(oppId).REN_Renewal_Target_Lost__c = oppIdToOppMap.get(oppId).REN_Renewal_Target_Lost__c == null ? 0 : oppIdToOppMap.get(oppId).REN_Renewal_Target_Lost__c.setScale(renewalTargetLostScale, RoundingMode.CEILING);			
		}
		for(ID oppId: oppIdToOppMap.keySet()) {
			if(!aggregateOppSet.contains(oppId)) {
				oppIdToOppMap.get(oppId).REN_Renewal_Target_Lost__c = 0;	
			}
			
		}
		return oppIdToOppMap;
	}
	
	private static Map<id,Opportunity> setRenewalTargetWon(Map<id,Opportunity> oppIdToOppMap, Integer renewalTargetWonScale, set<String> wonStatus){
		String whereClauseForWonStaus = '';
		if(wonStatus.isEmpty()){
			whereClauseForWonStaus = '(' + 'REN_Renewal_Status__c =' + '\'' + 'WON' + '\'' + ')' +
									 ' AND REN_Renews_To__r.REN_Is_CLM_Renewal__c=true ' ;
		}
		AggregateResult[] rliResultsForWon = getListWithAggregateGroupBy('SUM', 'REN_Renewal_Target_Number__c', new Set<String>{'REN_Renews_To__c'},'REN_Renews_To__c', whereClauseForWonStaus, oppIdToOppMap.keyset(), wonStatus);          
		Set<ID> aggregateOppSet = new Set<ID>();
		for(AggregateResult  ar : rliResultsForWon){
			Id oppId  = (Id)ar.get(CSM_Util.getNameSpace() + 'REN_Renews_To__c');
			aggregateOppSet.add(oppId);
			oppIdToOppMap.get(oppId).put(CSM_Util.getNameSpace() + 'REN_Renewal_Target_Won__c',ar.get('expr0'));
			oppIdToOppMap.get(oppId).REN_Renewal_Target_Won__c = oppIdToOppMap.get(oppId).REN_Renewal_Target_Won__c == null ? 0 : oppIdToOppMap.get(oppId).REN_Renewal_Target_Won__c.setScale(renewalTargetWonScale, RoundingMode.CEILING);
		}
		for(ID oppId: oppIdToOppMap.keySet()) {
			if(!aggregateOppSet.contains(oppId)) {
				oppIdToOppMap.get(oppId).REN_Renewal_Target_Won__c = 0;	
			}
			
		}
		return oppIdToOppMap;
	}
	private static Map<id,Opportunity> setRenewalTarget(Map<id,Opportunity> oppIdToOppMap,List<Opportunity> changedExpDateOppList, Integer renewalTargetScale,List<String> fieldListForCrudFls){
		String nameSpacePrefix = CSM_Util.getNamespace();
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
		List<Opportunity> oppList = new List<Opportunity>();
		AggregateResult[] rliResults = getRenewalTargetAggregateGroupBy(new Set<String>{'REN_Renews_To__c'}, oppIdToOppMap.keyset());          
		Map<Id,AggregateResult> rliResultsForRenewalTargetMap = new Map<id,AggregateResult>(rliResults);
			for(Opportunity  oppObj :oppIdToOppMap.values()){
				AggregateResult rliAggregateResult = rliResultsForRenewalTargetMap.get(oppObj.id);				
				if(rliAggregateResult != null ){
					oppObj.put(nameSpacePrefix + 'REN_Renewal_Target__c',rliAggregateResult.get('renTarget'));
					if(SS_Constants.isSimplifiedDataModelEnabled && oppObj.OpportunityLineItems != null && !oppObj.OpportunityLineItems.isEmpty()){
						oppObj.OpportunityLineItems[0].UnitPrice = (Decimal)rliAggregateResult.get('renTarget');
					}
					oppObj.REN_Renewal_Target__c = oppObj.REN_Renewal_Target__c == null ? 0 : oppObj.REN_Renewal_Target__c.setScale(renewalTargetScale, RoundingMode.CEILING);
					if(oppObj.REN_Is_CLM_Renewal__c == true){
						if(oppObj.REN_Earliest_Expiration_Date__c != rliAggregateResult.get('minDate')){
							oppObj.put(nameSpacePrefix + 'REN_Earliest_Expiration_Date__c',rliAggregateResult.get('minDate'));
						}
						changedExpDateOppList.add(oppObj);
						if(isSolutionExtnInstalled){
							//Aggt Result will be null if currencycode is blank in any of the Rli.				
							if((Integer)rliAggregateResult.get('distinctCurrencyCount') > 1 || (Integer)rliAggregateResult.get('distinctCurrencyCount') == 0 
							|| rliAggregateResult.get('localCurrencyCode') == null || rliAggregateResult.get('localRenewalTarget') == null){
					   			oppObj.put(solnExtnNamespace + 'Local_Renewal_Target__c','');
							}else if(rliAggregateResult.get('localRenewalTarget') != null){								
								String val = (String)rliAggregateResult.get('localCurrencyCode') + ' ' + String.valueOf(rliAggregateResult.get('localRenewalTarget'));
								oppObj.put(solnExtnNamespace + 'Local_Renewal_Target__c', val);
								
							}
						}
					}
				}else{
					oppObj.put(nameSpacePrefix + 'REN_Renewal_Target__c',0);
					oppObj.put(nameSpacePrefix + 'REN_Earliest_Expiration_Date__c',null);
					oppObj.put(nameSpacePrefix + 'REN_EQ__c',null);
					oppObj.put(nameSpacePrefix + 'REN_FY__c',null);
					if(isSolutionExtnInstalled){
						oppObj.put(solnExtnNamespace + 'Local_Renewal_Target__c','');
					}
				}		
				
			}
			if(isSolutionExtnInstalled){
				fieldListForCrudFls.add(solnExtnNamespace + 'Local_Renewal_Target__c');
			}
		return oppIdToOppMap;
	}
	
	private static AggregateResult[] getRenewalTargetAggregateGroupBy(Set<String> fieldSetToQuery, Set<ID> oppIdSet){
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
		List<String> fieldList = new List<String>(fieldSetToQuery);
        List<String> crudCheckList = new List<String>(fieldSetToQuery);
        crudCheckList.add('REN_End_Date__c');
        crudCheckList.add('REN_Renewal_Target_Number__c');
        CSM_Util.checkCRUD_FLS('REN_Renews_To__c', crudCheckList, CSM_Constants.DML_OPERATION_READ);
        String sQuery = 'Select REN_Renews_To__c Id, SUM(REN_Renewal_Target_Number__c)renTarget,MIN(REN_End_Date__c)minDate,' ;
        if(isSolutionExtnInstalled){
            String fieldName = solnExtnNamespace + 'Previous_Local_Currency_Code__c';
        	sQuery += ' COUNT_DISTINCT(' + fieldName + ') distinctCurrencyCount,';
        	sQuery += ' SUM(' + solnExtnNamespace + 'Previous_Local_Currency_Amount__c' + ') localRenewalTarget,';
        	sQuery += ' MIN(' + fieldName + ') localCurrencyCode,';
        }
       sQuery += String.join(fieldList, ',') + ' From REN_Renews_To__c Where REN_Renews_To__c IN: oppIdSet '        
       + (SS_Constants.isSimplifiedDataModelEnabled ? ' ' : ' AND REN_Renews_To__r.REN_Is_CLM_Renewal__c = true ');
 		
       sQuery += ' Group By '+ String.join(fieldList, ',');
       //sQuery += ' limit 1000 ';
       system.debug('Query : '+sQuery);                  
       return Database.query(sQuery);
    }
    
    private static AggregateResult[] getListWithAggregateGroupBy(String aggregateType, String aggregateField,  Set<String> fldstoQuery, String objectName, string whereClause, Set<ID> oppIdSet, set<String>allStatus){
        List<String> fieldList = new List<String>(fldstoQuery);
        List<String> crudCheckList = new List<String>(fldstoQuery);
        crudCheckList.add(aggregateField); 
        CSM_Util.checkCRUD_FLS(objectName, crudCheckList, CSM_Constants.DML_OPERATION_READ);
        String sQuery = 'Select '+ aggregateType + '(' +aggregateField + '), '  +
                          String.join(fieldList, ',') + 
                        ' From '+ objectName + ' Where ' + 'REN_Renews_To__r.REN_Is_CLM_Renewal__c = true' + ' AND ' + 'REN_Renews_To__c IN: oppIdSet ' ;
               sQuery += (String.isBlank(whereClause)? 'AND REN_Renewal_Status__c IN:allStatus' : ' AND (' +  whereClause + ') ' );
               sQuery += ' Group By '+ String.join(fieldList, ',');
              // sQuery += ' limit 1000 ';
        system.debug('Query : '+sQuery);                  
        return Database.query(sQuery);
    }
	
	/* This method is used to set Adds Amount on Opportunity. */
	
	public static void setOliMetricsFields(Set<Id> oppIdsSet, Boolean isOppUpdateFlow){
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		Schema.SObjectType oppty = Schema.getGlobalDescribe().get(CSM_Constants.OBJ_OPPORTUNITY);
		Schema.DescribeSObjectResult oppObj = oppty.getDescribe();	    
		Integer addsAmountScale = CSM_Util.getFieldScaleOptimized(oppObj,(CSM_Util.getNamespace() +'REN_AddsAmount__c').toLowerCase());
        String filterString = getFilterString(isOppUpdateFlow);
	    List<Opportunity> opportunityList = REN_OpportunityDataAccess.getOpportunityWithFilter(oppIdsSet, filterString);
		Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>(opportunityList);
		opportunityMap = setAddsAmount(opportunityMap,addsAmountScale);
		if(opportunityMap != null && !opportunityMap.isEmpty()){
    		CSM_OpportunityDataAccess.updateOpportunityList(opportunityMap.values(), new List<String>{'REN_AddsAmount__c'});
        }      		
	}
	
	public static Map<Id,Opportunity> setAddsAmount(Map<Id,Opportunity> opportunityMap,Integer addsAmountScale ){
		List<AggregateResult> aggregateResults = REN_OpportunityLineItemDataAccess.getAggregateTotalPriceOnOli(opportunityMap.keySet());       
        if(aggregateResults != null && !aggregateResults.isEmpty()){
	        for (AggregateResult oliObj : aggregateResults){
				if(opportunityMap.containsKey((Id)oliObj.get('OpportunityId'))){
					opportunityMap.get((Id)oliObj.get('OpportunityId')).REN_AddsAmount__c = (Decimal)oliObj.get('totalPrice');
					opportunityMap.get((Id)oliObj.get('OpportunityId')).REN_AddsAmount__c = opportunityMap.get((Id)oliObj.get('OpportunityId')).REN_AddsAmount__c == null ? 0 : opportunityMap.get((Id)oliObj.get('OpportunityId')).REN_AddsAmount__c.setScale(addsAmountScale, RoundingMode.CEILING);
				}
	        }
        }
        else{
        	opportunityMap = setAddsAmountToZero(opportunityMap);
        }     
		return opportunityMap;
	}
	
	private static Map<Id,Opportunity> setAddsAmountToZero(Map<Id,Opportunity> opportunityMap){
		if(opportunityMap != null && !opportunityMap.isEmpty()){
			for(Id oppId : opportunityMap.keySet()){
				opportunityMap.get(oppId).REN_AddsAmount__c = 0;
			}
		}
		return opportunityMap;
	}
	
	private static String getFilterString(Boolean isOppUpdateFlow){
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		String filterString = ' ID != null ';
        if(!isOppUpdateFlow){
	        if(String.isNotBlank(solnExtnNamespace)){
	            filterString = ' isWon != true '; 
	        }
	        Boolean hasSolExtSystemAdminAccess = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_SystemAdminUser);
			Boolean hasSolExtDataServiceAccess = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
			if(!(hasSolExtSystemAdminAccess || hasSolExtDataServiceAccess)){
				filterString += ' AND StageName != \'Closed Sale\'';
			}
        }
        return filterString;
	}
}