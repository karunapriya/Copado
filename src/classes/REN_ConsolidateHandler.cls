/**
 * Created Date     : Jun 15, 2016
 * Developed By     : ARanpise, Comity Designs, Inc.
 *
 * Function         : @description - all consoldating logic will be summarised here.
 * Support Email    : servicesource@comitydesigns.com
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * ARanpise                  User Story              Jun 15, 2016         1.1                 @description
 *
 */
 
public with sharing class REN_ConsolidateHandler {
	
	public static String finalConsolidation(List<OpportunityLineItem> oliListToSplit,
    			 					List<REN_Renews_To__c> selectedRRList,
    								String actionName,
    								list<Opportunity> sourceOppList,
    								Opportunity targetOpp){
    	System.debug(oliListToSplit + '\n1~~~~RR: ' + selectedRRList);
    	System.debug(targetOpp + '\n1~~~~sourceOppList: ' + sourceOppList);
		String ErrorMsg='';
		//Check Opp stage for valid consolidation 
		//if( targetOpp.id != null){
	        SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();
            if(actionName == REN_Constants.STR_CONSOLIDATE && (String.valueOf(REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',')).contains(targetOpp.StageName) || targetOpp.StageName == 'No Service')){
	        	ErrorMsg = String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_CONSOLIDATE, new String[] {targetOpp.StageName});
	        	return ErrorMsg;
	        }else if(String.valueOf(REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',')).contains(targetOpp.StageName)  || targetOpp.StageName == 'No Service'){
	        	ErrorMsg = String.format(System.Label.REN_MSG_OPP_STAGE_BLOCKED_FOR_SPLIT, new String[] {targetOpp.StageName});
	        	return ErrorMsg;
	        }
		//}		
        Set<ID> impactedOppIdSet = new Set<ID>();                                  	
    	Map<ID, Opportunity> sourceOppMap = new Map<ID, Opportunity>(sourceOppList);
    	if(actionName == 'Consolidate' && selectedRRList == null){
    		selectedRRList = REN_RenewRelationshipDataAccess.getRenewalRelationshipByOpportunityIds(sourceOppMap.keySet(), new Set<String>{'Id','REN_Renews_To__c','REN_Source_Opportunity__c'}, new Set<String>{'Id'}, NULL);
    	}
    	set<ID>oliIdToSplit=new set<ID>();
    	if((selectedRRList != null && !selectedRRList.isEmpty()) && (oliListToSplit == null || oliListToSplit.isEmpty())){
    		Map<Id, OpportunityLineItem> oppProdMap = new Map<Id, OpportunityLineItem>(REN_OpportunityLineItemDataAccess.getOliByRliId(new Map<Id, REN_Renews_To__c>(selectedRRList).keySet()));
    		if(oppProdMap != null){
    	    	oliListToSplit = oppProdMap.values();
    		}
    	}    			
		List<Opportunity> oppListForUpsert = new List<Opportunity>();
		List<REN_Source__c> sourceList = new List<REN_Source__c>(); 
		Boolean IsSyncedQuoteField=CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId');
		
		Boolean isRemovedSyncQuote = !SS_Constants.isSimplifiedDataModelEnabled && IsSyncedQuoteField && oliListToSplit != null &&  oliListToSplit.size() >= 1 && actionName.equalsIgnoreCase(REN_Constants.STR_SPLIT);
		if(isRemovedSyncQuote || !actionName.equalsIgnoreCase(REN_Constants.STR_SPLIT) || SS_Constants.isSimplifiedDataModelEnabled){
			targetOpp.put('SyncedQuoteId',null);
		}
		targetOpp.REN_Is_Consolidated__c = false;
		targetOpp.REN_Is_CLM_Renewal__c = true;
		
		if(String.isBlank(targetOpp.Pricebook2Id)) {
			targetOpp.Pricebook2Id = sourceOppList[0].Pricebook2Id;
		}		
		if(UserInfo.isMultiCurrencyOrganization() && targetOpp.get(REN_Constants.REN_CURRENCY_ISO_CODE) == null){
			if(!sourceOppList.isEmpty()){
				targetOpp.put(REN_Constants.REN_CURRENCY_ISO_CODE,sourceOppList[0].get(REN_Constants.REN_CURRENCY_ISO_CODE));
			}
		}
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn; 
		if(CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c')){
	        	targetOpp.put('Opportunity_Name__c',targetOpp.Name);
	    }
		CSM_OpportunityDataAccess.upsertOpportunityList(new List<Opportunity>{targetOpp});
		impactedOppIdSet.add(targetOpp.id);
		
		for(Opportunity sourceOp: sourceOppList){
			if(isRemovedSyncQuote || !actionName.equalsIgnoreCase(REN_Constants.STR_SPLIT) || SS_Constants.isSimplifiedDataModelEnabled){
				sourceOp.put('SyncedQuoteId',null);
			}
			if(actionName.equalsIgnoreCase(REN_Constants.STR_CONSOLIDATE)){
				sourceOp.REN_Is_Consolidated__c = true;
			}
            oppListForUpsert.add(sourceOp);
            
            REN_Source__c sourceObj = new REN_Source__c(REN_Inheriting_Opportunity__c = targetOpp.id, 
            						REN_Contributor__c = sourceOp.Id, REN_Type__c = 'Opportunity');
			if(actionName.equalsIgnoreCase(REN_Constants.STR_CONSOLIDATE)){
				sourceObj.REN_Reason__c = REN_Constants.REN_REASON_CONSOLIDATED;
			}else if(actionName.equalsIgnoreCase(REN_Constants.STR_SPLIT)) {
				sourceObj.REN_Reason__c = REN_Constants.REN_REASON_SPLIT;
			}else if(actionName.equalsIgnoreCase(REN_Constants.STR_SEARCH_AND_MOVE)) {
				sourceObj.REN_Reason__c = REN_Constants.STR_SEARCH_AND_MOVE;
			}
            sourceList.add(sourceObj);
		}
		
		/*for(Opportunity sourceOp: sourceOppList){
			REN_Source__c sourceObj = new REN_Source__c(REN_Inheriting_Opportunity__c = targetOpp.id, 
            						REN_Contributor__c = sourceOp.Id, REN_Type__c = 'Opportunity');
			if(actionName.equalsIgnoreCase(REN_Constants.STR_CONSOLIDATE)){
				sourceObj.REN_Reason__c = REN_Constants.REN_REASON_CONSOLIDATED;
			}else if(actionName.equalsIgnoreCase(REN_Constants.STR_SPLIT)) {
				sourceObj.REN_Reason__c = REN_Constants.REN_REASON_SPLIT;
			}else if(actionName.equalsIgnoreCase(REN_Constants.STR_SEARCH_AND_MOVE)) {
				sourceObj.REN_Reason__c = REN_Constants.STR_SEARCH_AND_MOVE;
			}
            sourceList.add(sourceObj);
		}*/
		//Set Stage to Open Consolidated.
     
		Map<string,string> oldtoNewOpptylineMap = splitOpptLines(oliListToSplit, targetOpp);//KEY=Old OLI id, Valus = new OLI ID Correspond to old OLI.
		splitRLI(oldtoNewOpptylineMap,selectedRRList,targetOpp,oliListToSplit);
		
		CSM_OpportunityDataAccess.upsertOpportunityList(oppListForUpsert);
		impactedOppIdSet.addall((new Map<Id,Opportunity>(oppListForUpsert)).keySet());
		if(oliListToSplit != null && !oliListToSplit.isEmpty()){
			REN_OpportunityLineItemDataAccess.deleteOpportunityLineItems(oliListToSplit);
		}
		
		REN_SourceDataAccess.saveSourceRecords(sourceList);

		REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(impactedOppIdSet);

		return ErrorMsg;
	}

	private static Map<String, String> splitOpptLines(List<OpportunityLineItem> lstOldLines, Opportunity targetOppt){
        Map<String, String> oldtoNewOliIdMap = new Map<String, String>();
        if(lstOldLines != null && !lstOldLines.isEmpty()){
	       	List<OpportunityLineItem> newLinesLst = new List<OpportunityLineItem>();
			Map<String, OpportunityLineItem> oldtoNewOpptylineMap = new Map<String,OpportunityLineItem>();
	    	for(OpportunityLineItem ol :lstOldLines){
	        	OpportunityLineItem clonedOpli = ol.clone(false, true);
	        	oldtoNewOpptylineMap.put(ol.Id, clonedOpli);
	        	
	        	if(clonedOpli.REN_Source_Opportunity__c == null){
	            	clonedOpli.REN_Source_Opportunity__c = clonedOpli.OpportunityId;
	        	}
	        	clonedOpli.REN_Renewable_Line_Item__c = ol.REN_Renewable_Line_Item__c;
	        	//clonedOpli.REN_Original_Line_Item_ID__c = null; -- US3338 - Commented
	        	clonedOpli.REN_Previous_Opportunity__c = clonedOpli.OpportunityId;
	        	clonedOpli.OpportunityId = targetOppt.id;
	        	if(clonedOpli.UnitPrice != null){
	        		 clonedOpli.TotalPrice = null;
	        	}
	    	}
	        newLinesLst = oldtoNewOpptylineMap.values();
	        System.debug(lstOldLines + '\n2~~~~New OLI: ' + oldtoNewOpptylineMap);
	        REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(newLinesLst);
	       
        }
        
        return oldtoNewOliIdMap;
    }
    
	private static void splitRLI(Map<string,string> oldtoNewOliIdMap,List<REN_Renews_To__c> selectedRRList,Opportunity targetOpp,List<OpportunityLineItem> oliListToSplit){
		if(selectedRRList != null && !selectedRRList.isEmpty()){
			List<CHL_Partner_Renewal_Relationship__c> prtnerRR = new List<CHL_Partner_Renewal_Relationship__c>();
			List<Opportunity> opptyLst = new List<Opportunity>();
			opptyLst.add(targetOpp);
			system.debug('selectedRRList==='+selectedRRList);
			prtnerRR = CHL_PartnerRenRelationshipDataAccess.getPrtnrRenRelFromRenRel(new List<String> {'id'},selectedRRList);
			if(!prtnerRR.isEmpty()){
				//CHL_PartnerRenRelationshipDataAccess.deletePartnerRenRelationship(prtnerRR);
			}
			REN_Util.updateRenewalRelationships(opptyLst,oldtoNewOliIdMap,selectedRRList);
		}
 	}
 	
 	public static void updateConsolidationRequests(Set<Id> consolidationRequests){
		if(consolidationRequests != null && !consolidationRequests.isEmpty()){
			List<REN_Consolidation_Request__c> crList = new List<REN_Consolidation_Request__c>();
	        for(Id crId : consolidationRequests){
	        	crList.add(new REN_Consolidation_Request__c(Id = crId, REN_Processing_Completed__c = true, REN_Processed_On__c = System.now()));
	        }
	        update crList;
		}
	}
	public static void updateErrorMessageOnCRS(List<REN_Consolidation_Request_Source__c> crsList, String errorMessage, Boolean hasError){
		if(crsList != null && !crsList.isEmpty()){
			for(REN_Consolidation_Request_Source__c crs : crsList){
				crs.REN_Failure_Message__c = errorMessage;
				crs.REN_Is_Error_Reported__c = hasError;
			}
			update crsList;
		}
	}
	
	public static void createChatterFeeds(Map<String, String> sourceToTargetOpptyNameMap, Map<String, Id> sourceToTargetOpptyMap){
		if(sourceToTargetOpptyNameMap != null && !sourceToTargetOpptyNameMap.isEmpty() && REN_ChatterUtil.isChatterEnabled()){
			List<sObject> chatterFeedItems = new List<sObject>();
			for(String sourceOpptyId : sourceToTargetOpptyNameMap.keySet()){
				String url = '<a target="_blank" href="/"' + sourceToTargetOpptyMap.get(sourceOpptyId) + '>This Opportunity</a>';
				String postMsg = 'This Opportunity was consolidated into ' + sourceToTargetOpptyNameMap.get(sourceOpptyId);
			//	Id link = sourceToTargetOpptyNameMap.get(sourceOpptyId);
	            chatterFeedItems.add(REN_ChatterUtil.addChatterMessage(sourceOpptyId, postMsg, ('/' + sourceToTargetOpptyMap.get(sourceOpptyId))));
			}
			REN_ChatterUtil.saveChatterMessages(chatterFeedItems);
		}
	}
 	
 	
}