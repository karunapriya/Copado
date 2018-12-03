public with sharing class REN_OpportunityLineItemTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	
	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){   	
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
		SS_TriggerCollectionParameters.OLITriggerParams oliParams = new SS_TriggerCollectionParameters.OLITriggerParams();
		oliParams.newRecordList = new List<OpportunityLineItem>();
		oliParams.oldRecordsMap = new Map<Id,OpportunityLineItem>();
		oliParams.qualifiedOLIMap = new Map<Id,OpportunityLineItem>(REN_OpportunityLineItemDataAccess.getOpportunityProductsOFWonOpp(newRecordsMap.KeySet()));
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<String> oliIdsList = new List<String>();
		Set<Id> opportunityIdSet = new Set<Id>();
 		String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
 		Boolean isSolExt = CSM_AccessController.hasObject(solExtNameSpace+'Peer_Review__c');
 				    		
		oliIdsList.addAll((List<String>)JSON.deserialize(JSON.serialize(newRecordsMap.keySet()), List<String>.class));
		opportunityList = CHL_Util.getObjectListByWhereClause(new Set<String>{'Id','CHL_QuoteSyncStatus__c'},'Opportunity','Id IN (select OpportunityId from OpportunityLineItem where Id IN ( \''+String.join(oliIdsList, '\',\'')+'\') ) AND (CHL_QuoteSyncStatus__c = \'In Progress\' OR CHL_QuoteSyncStatus__c = \'Scheduled\') ');
		Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>(opportunityList);
		for(OpportunityLineItem oli : (List<OpportunityLineItem>)newRecordsMap.values()){
			if(hasRenewAccess && !REN_FiscalYearOLIBatch.isBatchRunning && oldRecordsMap.get(oli.id).get('REN_End_Date__c') != oli.get('REN_End_Date__c')){
				oli.put('REN_Is_End_Date_Modified__c', true);
			}
			if(hasRenewAccess && oliParams.qualifiedOLIMap .containskey(oli.id)){
				oliParams.newRecordList.add(oli);
				oliParams.oldRecordsMap.put(oli.id,(OpportunityLineItem)oldRecordsMap.get(oli.id));
			}			
			if(!isDataServicesUser && opportunityMap != null && !opportunityMap.isEmpty() && opportunityMap.containsKey(oli.OpportunityId)){
				oli.addError(System.Label.CHL_LBL_QUOTE_ASYNC_VALIDATION_ERROR);
				
			}
			opportunityIdSet.add(oli.OpportunityId);
		}			
		if(hasRenewAccess == true){			
 			if(SS_Constants.isSimplifiedDataModelEnabled){
 				REN_OpportunityLineItemRenewalHandler.checkForDuplicateMasterOLI(newRecords,opportunityIdSet);
 			}
 			if(isSolExt && oliParams.qualifiedOLIMap != null && !oliParams.qualifiedOLIMap.isEmpty()){
 				(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'OLITriggerInvocationHandler', oliParams);
 			}		 		
		}				
	}

	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){        	
     	Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id,Opportunity> mapOfQuoteToOpp = new Map<Id,Opportunity>();
        Set<String> setOfFieldsToQuery = new Set<String>{'REN_AddsAmount__c'};
		Boolean hasSyncedQuoteField = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');
		if(hasSyncedQuoteField){
			setOfFieldsToQuery.add('SyncedQuoteId');
		}
		Set<Id> filteredOppIdsSet = new Set<Id>();
        
        if(CSM_AccessController.hasField(CHL_Constants.OBJ_OPPORTUNITY,CSM_Util.nameSpacePrefixSolnExtn+'Commit_Level__c')){
            	setOfFieldsToQuery.add(CSM_Util.nameSpacePrefixSolnExtn+'Commit_Level__c');
            	setOfFieldsToQuery.add(CSM_Util.nameSpacePrefixSolnExtn+'First_Quote_Completed_Date__c');
        }
    	Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>((List<Opportunity>)CHL_Util.getObjectListByWhereClause(setOfFieldsToQuery,'Opportunity','Id IN (select OpportunityId from OpportunityLineItem where Id IN ( \''+String.join(new List<Id>(newRecordsMap.keySet()), '\',\'')+
    		'\')' + (hasSyncedQuoteField ? ' AND Opportunity.SyncedQuoteId != null' : '') + ')'));	          
        for(OpportunityLineItem oli : (List<OpportunityLineItem>)newRecords){
        	OpportunityLineItem oldOli = (OpportunityLineItem)oldRecordsMap.get(oli.Id);
        	if(hasSyncedQuoteField) {
                if(opptyMap!=null && opptyMap.containsKey(oli.OpportunityId) && oli.Subtotal != oldRecordsMap.get(oli.Id).get('Subtotal') && opptyMap.get(oli.OpportunityId).get('SyncedQuoteId') != null){
                    mapOfQuoteToOpp.put((Id)opptyMap.get(oli.OpportunityId).get('SyncedQuoteId'),opptyMap.get(oli.OpportunityId));
                }
                opportunityIdSet.add(oli.OpportunityId);
        	}
        	if((oli.REN_Is_CLM_Renewal__c == false && (oli.TotalPrice != oldOli.TotalPrice)) 
	        	|| (oli.REN_Is_CLM_Renewal__c != oldOli.REN_Is_CLM_Renewal__c)){
        		filteredOppIdsSet.add(oli.OpportunityId);
        	}        	
    	}      
    	  
        if(CSM_AccessController.hasField('QuoteLineItem',CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP) ){
            CHL_QuoteSyncHandler.handleOLIUpdate(newRecords,opportunityIdSet);
        }   
        /*if(hasChannelAccess && mapOfQuoteToOpp != null && !mapOfQuoteToOpp.isEmpty()) {   
            CHL_QuoteSyncHandler.handleRRCalculation(mapOfQuoteToOpp);
        }*/
        if(hasRenewAccess && filteredOppIdsSet != null && !filteredOppIdsSet.isEmpty()){
        	REN_OpportunityLineItemRenewalHandler.oliAfterTriggerEvent(filteredOppIdsSet);
        }
    }
 	
 	public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap){
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		Set<Id> oppsIdSet=new Set<Id>();	
		Set<Id> filteredOppIdsSet = new Set<Id>();	
		Boolean hasSyncedQuoteField = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');
	 	//&& REN_Constants.OPPORTUNITYLINEITEM_TRIGGER  removed this check for DE1241, as delete will not occur in recursive way.
		for(OpportunityLineItem oLIObj : (List<OpportunityLineItem>)oldRecords) {
			oppsIdSet.add(oLIObj.OpportunityId);
			if(oLIObj.REN_Is_CLM_Renewal__c == false){
        		filteredOppIdsSet.add(oLIObj.OpportunityId);
        	}	
		}
		if(hasSyncedQuoteField && !oppsIdSet.isEmpty()){
			List<String> opportunityIDList = new List<String>();
			opportunityIDList.addAll((List<String>)JSON.deserialize(JSON.serialize(oppsIdSet), List<String>.class));
			List<Opportunity> oppList = (List<Opportunity>) CHL_Util.getObjectListByWhereClause(new Set<String>{'Id', 'SyncedQuoteId'}, 'Opportunity', 'Id IN ( \''+String.join(opportunityIDList, '\',\'')+'\') AND SyncedQuoteId != null');
			if(oppList != null && !oppList.isEmpty()){
				CSM_TriggerManager.enableQLITrigger = true;
			}
		}
		if(hasRenewAccess && filteredOppIdsSet != null && !filteredOppIdsSet.isEmpty()){
			REN_OpportunityLineItemRenewalHandler.oliAfterTriggerEvent(filteredOppIdsSet);
		}
	}
 	
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		if(hasRenewAccess){
	        String endDateField = CSM_Util.getNameSpace() + 'REN_Is_End_Date_Modified__c'; 
	 		Set<id> oppIdSet = new Set<id>();			
	 		for(OpportunityLineItem oli : (List<OpportunityLineItem>)newRecords){
	 			oli.put(endDateField, true);
	 			oppIdSet.add(oli.OpportunityId);				
			}
	 		if(SS_Constants.isSimplifiedDataModelEnabled){
	 			REN_OpportunityLineItemRenewalHandler.checkForDuplicateMasterOLI(newRecords,oppIdSet);
	 		} 
		}
    }

	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		Boolean isDataServiceUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);	
 		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
        Boolean isChannelCommunityUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity);
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<Id> filteredOppIdsSet = new Set<Id>();
 		for(OpportunityLineItem oli : (List<OpportunityLineItem>)newRecords){
			opportunityIdSet.add(oli.OpportunityId);
			if(oli.REN_Is_CLM_Renewal__c == false){
        		filteredOppIdsSet.add(oli.OpportunityId);
        	}
		} 						 	 
		if(CSM_AccessController.hasField('QuoteLineItem',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c')){
			Decimal qliThreshold = CSM_Admin__c.getOrgDefaults().CHL_QliCount__c;
			Boolean isQuoteSyncBatchRunning = CHL_Util.isBatchRunning('CHL_QuoteSyncBatch');
			Boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
			Integer batchSize = CSM_Util.getCustomListSetting('CHL_QuoteSyncBatch');
			batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
			Boolean hasSyncedQuoteField = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');
			List<Opportunity> oppList = new List<Opportunity>();
			
			if(hasSyncedQuoteField && !filteredOppIdsSet.isEmpty()){
				List<String> oppIdsList = new List<String>();
				oppIdsList.addAll((List<String>)JSON.deserialize(JSON.serialize(filteredOppIdsSet), List<String>.class));
				oppList = (List<Opportunity>) CHL_Util.getObjectListByWhereClause(new Set<String>{'Id', 'SyncedQuoteId'}, 'Opportunity', 'Id IN ( \''+String.join(oppIdsList, '\',\'')+'\') AND SyncedQuoteId != null');
			}
			if(oppList != null && !oppList.isEmpty()){
				if(!isDataServiceUser && newRecords.size() <= qliThreshold){
					if(SS_Constants.isSimplifiedDataModelEnabled){	
					CHL_QuoteSyncHandler.handleSimplifiedOLIrecreation(opportunityIdSet);
					} 
					else {	
	 	 				CHL_QuoteSyncHandler.handleOLIrecreation(opportunityIdSet);
					}
					if(hasChannelAccess) {
			 	 		CHL_QuoteSyncHandler.calculateRRMetricsOnPO(opportunityIdSet);
			 	 	}
				}
				else{
					CSM_OpportunityTriggerHelper.processQliRecordsByBatch(newRecords.size(), filteredOppIdsSet, null);
				}
			}		
		}
		if(hasRenewAccess && filteredOppIdsSet != null && !filteredOppIdsSet.isEmpty()){	
			REN_OpportunityLineItemRenewalHandler.oliAfterTriggerEvent(filteredOppIdsSet);
		}
 	}
 }