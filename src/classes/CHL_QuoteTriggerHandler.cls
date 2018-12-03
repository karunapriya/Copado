public with sharing class CHL_QuoteTriggerHandler extends CSM_TriggerManager.TriggerHandler {
	
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		
	 	Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
	 	//Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
	 	Boolean hasPartnerOpportunity = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');	 		
	 	Set<ID> poIdSet = new Set<Id>();
	 	Set<string> opptyIdSet = new Set<string>();
	 	Map<Id,sObject> mapOfPOToQuote = new Map<Id,sObject>();
	 			
		for(sObject quoteObj : newRecords){
			opptyIdSet.add((String)quoteObj.get('OpportunityId'));
			if (hasPartnerOpportunity && !String.isBlank((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')) ) {
				mapofPOToQuote.put((Id)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj);
			}
		}
		List<String> oppIdList = new List<String>();
		oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opptyIdSet), List<String>.class));
		List<OpportunityLineItem> opliQueriedList = CHL_Util.getObjectListByWhereClause(new Set<String>{'Id'},'OpportunityLineItem','OpportunityId IN ( \''+String.join(oppIdList, '\',\'')+'\')');
		Decimal threshold = CSM_Admin__c.getOrgDefaults().CHL_QliCount__c;
		Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
		if(opliQueriedList.size() <= threshold && !isDataServicesUser){
			CHL_QuoteSyncHandler.handleQuoteCreation(newRecords, opptyIdSet);
		}		
		if(hasChannelAccess && !mapOfPOToQuote.isEmpty()){
			CHL_QuoteSyncHandler.copyPartnerOptyDetails(mapOfPOToQuote);
		}	
 	}
 	
 	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
 		//Need to enable QLI Trigger from here, as it will block those triggers. And we need to populate Original line item Id & copy custom field values from OLI TO QLI, when Quote is created from UI.
 		CSM_TriggerManager.enableQLITrigger = true;
 	}
 	
 	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		Boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Quote', solnExtNamespace + 'Local_Currency_Code__c');
		Map<Id,SObject> poIdToQuoteMap = new Map<Id,sObject>();
		Map<Id, Opportunity> opportunityMap ;
		Map<Id, SObject> quoteMap = new Map<Id, SObject>();
		Boolean hasCommitLevel = CSM_AccessController.hasField('Opportunity',solnExtNamespace +'Commit_Level__c');
 		Boolean hasFirstQuoteCompletedDate = CSM_AccessController.hasField('Opportunity',solnExtNamespace + 'First_Quote_Completed_Date__c');
	 	Boolean is2TierPricingEnable = false;
	 	Boolean hasPOField = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
	 	SS_TriggerCollectionParameters.sObjectTriggerParams quoteParams = new SS_TriggerCollectionParameters.sObjectTriggerParams();
	 	quoteParams.qualifiedRecList = new List<SObject>();
	 	
	 	CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper();

	 	quoteWrapper.oppIdsWithSyncQuoteList = new List<String>();
	 	quoteWrapper.optyListToUpdate = new List<Opportunity>();
	 	quoteWrapper.newRecordList = new List<SObject>();
		
		Map<Id,SObject> filteredOppMap = new Map<Id,SObject>(CHL_QuoteDataAccess.getQuotesWithWonOppty(newRecordsMap.keySet()));
	 	if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
        	is2TierPricingEnable = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
        }
	 	for(SObject quoteObj : newRecords){
	 		SObject oldQuote = oldRecordsMap.get(quoteObj.Id);
 			if(hasPOField && quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != null 
 				&& (Boolean)quoteObj.get('IsSyncing') == true
 				&& (quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != oldQuote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'))){
 				poIdToQuoteMap.put((Id)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj);
 			}
	 		if((boolean)quoteObj.get('IsSyncing') == true) {
				quoteWrapper.oppIdsWithSyncQuoteList.add((String)quoteObj.get(CHL_Constants.STR_OPPOTUNITYID));	
				quoteWrapper.newRecordList.add(quoteObj);			
			}				
	 		if(isSolutionExtnInstalled && (quoteObj.get(solnExtNamespace+'Local_Currency_Code__c') != oldQuote.get(solnExtNamespace+'Local_Currency_Code__c'))){
				quoteMap.put(quoteObj.Id, quoteObj);
 			}
 			if(filteredOppMap.containsKey(quoteObj.Id)){
 				quoteParams.qualifiedRecList.add(quoteObj);
 			}		 		
	 	}
 		quoteParams.objectName = 'Quote';
	 	quoteParams.oldRecordsMap = oldRecordsMap;
	 	if(isSolutionExtnInstalled && quoteParams.qualifiedRecList != null && !quoteParams.qualifiedRecList.isEmpty()){
 			(new SS_FeatureInvocation()).invoke((String.isBlank(solnExtNamespace) ? '' : (solnExtNamespace.replace('__','.'))) + 'QuoteTriggerInvocationHandler', quoteParams);
 		} 			
 		if(quoteMap != null && !quoteMap.isEmpty()){	 			
 			Set<String> qliFields = new Set<String>{solnExtNamespace+'Local_Currency_Amount__c',solnExtNamespace+'Local_CurrencyCode__c','QuoteId','Quantity'};
 			List<SObject> qliList = CHL_QuoteLineItemDataAccess.getQuoteLineItemsByQuote(quoteMap.keySet(),qliFields);
 			if(REN_CurrencyExchangeRateDataAccess.IS_ACM_ENABLED && qliList != null && !qliList.isEmpty()){
 				List<SObject> quoteLineItemsList = CHL_QuoteLineItemTriggerHelper.processQliRecords(quoteMap,qliList,opportunityMap);
 				if(quoteLineItemsList != null && !quoteLineItemsList.isEmpty()){
 					CHL_QuoteLineItemDataAccess.updateQuoteLineItem(new Set<String>{'UnitPrice', solnExtNamespace+'Local_Currency_Line_Total__c'}, quoteLineItemsList);
 				}
 			}	 			
 		}					 		
 		Set<String> frmFldSet = new Set<String>();
		Set<String> toFldSet = new Set<String>{};
 		List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
												Label.REN_LBL_QUOTE_TO_OPPTY, 'Opportunity', CHL_Constants.OBJ_QUOTE);
 		if(fieldMappingListQuoteToOppty != null && !fieldMappingListQuoteToOppty.isEmpty()){	 				
			REN_Util.getFromAndToFldsToQuery(fieldMappingListQuoteToOppty,frmFldSet,toFldSet);
 		}
		Set<String> oppFldstoQuery = new Set<String>{'Id','REN_AddsAmount__c','CloseDate'};
		if(hasCommitLevel && hasFirstQuoteCompletedDate){
			oppFldstoQuery.add(solnExtNamespace +'Commit_Level__c');
			oppFldstoQuery.add(solnExtNamespace + 'First_Quote_Completed_Date__c');		
		}
		oppFldstoQuery.addAll(toFldSet);				
		List<Opportunity> oppList = CHL_Util.getObjectListByWhereClause(oppFldstoQuery,'Opportunity','Id IN ( \''+String.join(quoteWrapper.oppIdsWithSyncQuoteList, '\',\'')+'\') ');
		opportunityMap = new Map<Id,Opportunity>(oppList);
		quoteWrapper.optyListToUpdate = oppList;
		if(quoteMap != null && !quoteMap.isEmpty()){	
			List<String> oppIdList = new List<String>();
        	oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opportunityMap.keySet()), List<String>.class)); 
        	quoteWrapper.oppIdsList = oppIdList;
		}
		if(quoteWrapper.oppIdsWithSyncQuoteList != null && !quoteWrapper.oppIdsWithSyncQuoteList.isEmpty()){
			CHL_QuoteSyncHandler.handleQuoteUpdate(quoteWrapper,fieldMappingListQuoteToOppty);
		}
		if(!poIdToQuoteMap.isEmpty()){			
	 		CHL_QuoteSyncHandler.updatePartnerOpptyFields(poIdToQuoteMap,(Map<Id,Opportunity>)opportunityMap);
		}
	 	
 	}
 	
 	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)	{
	 		Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;					
			
			SObject oldQuote;
			Map<Id,sObject> mapofPOToQuote = new Map<Id,sObject>();
			Boolean hasPartnerOpportunity = CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
			
			if(hasChannelAccess ) {
				for(sObject quoteObj : newRecords){
					if(!Test.isRunningTest()) {
	 					oldQuote  = Trigger.oldMap.get(quoteObj.Id);
						if (hasPartnerOpportunity){
			    			if((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != (String)oldQuote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') && String.isblank((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'))) {
			    				quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1__c', null);
						        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c', null);
						        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Contact__c', null);
						        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Incumbent__c', false);
						 		quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2__c', null);
						        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c', null);
						        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Contact__c', null);
			    			}else if((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != (String)oldQuote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')) {
								mapofPOToQuote.put((Id)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj);
							}
			    		}
					}
				}
				if(mapofPOToQuote != null && !mapofPOToQuote.isEmpty()) {
					CHL_QuoteSyncHandler.copyPartnerOptyDetails(mapofPOToQuote);	
				}
		 	}
 	}
}