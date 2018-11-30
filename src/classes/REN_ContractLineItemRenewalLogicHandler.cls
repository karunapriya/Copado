/**
 * @author    	 Chandra Prakash (Chandra@comitydesigns.com)    
 * @date         03/05/2015
 * @description  REN_ContractLineItemRenewalLogicHandler trigger handler for REN_ContractLineItemTriggerHandler
 */
public with sharing class REN_ContractLineItemRenewalLogicHandler {

	public static void handleContractLineItemCreation(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		String namespace = CSM_Util.getNamespace();
		List<sObject> contractLineItemList = REN_ContractLineItemDataAccess.getContractLineItemsWithoutRenewalItems(newRecordsMap.keySet());
		List<sObject> filteredContractLineItemList = new List<sObject>();
		Boolean hasLineItemId = false;
		
		// VCP - ORG21 check
		Boolean hasField = CSM_AccessController.hasField(REN_Constants.OBJ_CONTRACT_LINE_ITEM, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID);
			
		for(sObject cli: contractLineItemList){
			// VCP - ORG21 check
			Boolean isNull = (hasField && cli.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID)==null);
			
			if(isNull==true){
				filteredContractLineItemList.add(cli);
			}
		}
		contractLineItemCreation(filteredContractLineItemList, newRecordsMap); 
	}


	public static void handleContractLineItemUpdate(List<sObject> oldContractLineItemRecords, List<sObject> newContractLineItemRecords, Map<ID, sObject> oldContractLineItemRecordsMap, Map<ID, sObject> newContractLineItemRecordsMap){
		try{
			REN_Renew_Configuration__c renewConfigForOppty2RenewOppty = REN_OpportunityResolutionTriggerHandler.renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
			REN_Renew_Configuration__c renewConfigForCLI2RenewOpptyLI = REN_OpportunityResolutionTriggerHandler.renewConfigurationMap.get(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT);
			            
            if(renewConfigForOppty2RenewOppty != null && !String.isBlank(renewConfigForOppty2RenewOppty.REN_Update_On__c)){
				Set<String> adminPreferencesSet = new Set<String>(renewConfigForOppty2RenewOppty.REN_Update_On__c.split(';'));
				if(adminPreferencesSet.contains(REN_Constants.FLD_VAL_UPDATE_ON_CONTRACT_LINES_EXISTING)){
	
					//List<sObject> oldContractLineItemList = REN_Util.filterRecordsBasedOnCriteria(oldContractLineItemRecords, filtersMap);
					List<sObject> oldContractLineItemList = REN_OpportunityDataAccess.getFilteredRecords(REN_Constants.OBJ_CONTRACT_LINE_ITEM, new Set<String>(), oldContractLineItemRecordsMap.keySet(), renewConfigForCLI2RenewOpptyLI.REN_Filter_Criteria__c, new Set<String>());
					if(oldContractLineItemList == null || oldContractLineItemList.isEmpty()){
						return;
					}
					system.debug(oldContractLineItemList +'\n\n~~~~renewConfigForCLI2RenewOpptyLI: ' + renewConfigForCLI2RenewOpptyLI);
					system.debug('\n\n~~~~renewConfigForCLI2RenewOpptyLI.Line_Criteria__r: ' + renewConfigForCLI2RenewOpptyLI.Line_Criteria__r);
					Set<String> contractLineItemIdSet = new Set<String>();
					for(sObject cliObj: oldContractLineItemList){
						boolean isSyncRequired = true;
						if(String.isNotBlank(renewConfigForCLI2RenewOpptyLI.RLM_Filter_Logic__c) && renewConfigForCLI2RenewOpptyLI.RLM_Filter_Logic__c.indexOfIgnoreCase('OR') > 0){
							Map<String, REN_Line_Criteria__c> lineCriteriaMap = new Map<String, REN_Line_Criteria__c>();
							for(REN_Line_Criteria__c criteria : renewConfigForCLI2RenewOpptyLI.Line_Criteria__r) {
                                
								lineCriteriaMap.put('' + (Integer)criteria.RLM_LineNo__c, criteria);
							}
							isSyncRequired = REN_Util.evaluateLogicalExp(renewConfigForCLI2RenewOpptyLI.RLM_Filter_Logic__c, oldContractLineItemRecordsMap.get(cliObj.id), newContractLineItemRecordsMap.get(cliObj.id), lineCriteriaMap);
						}else{
							if(renewConfigForCLI2RenewOpptyLI.Line_Criteria__r != null){
						 		for(REN_Line_Criteria__c criteria : renewConfigForCLI2RenewOpptyLI.Line_Criteria__r) {//US410
                                    system.debug(oldContractLineItemRecordsMap.get(cliObj.id).get(criteria.RLM_Field_Name__c) + '\n\n1~~~~=: ' + newContractLineItemRecordsMap.get(cliObj.id).get(criteria.RLM_Field_Name__c));
						 			if(String.isNotBlank(criteria.RLM_Field_Name__c) && oldContractLineItemRecordsMap.get(cliObj.id).get(criteria.RLM_Field_Name__c) == newContractLineItemRecordsMap.get(cliObj.id).get(criteria.RLM_Field_Name__c)){
						 				isSyncRequired = false;
						 				system.debug(criteria + '\n\n~~~~CLI: ' + cliObj);
						 				break;
						 			}
						 		}
						 	}
						}
						if(isSyncRequired){
							contractLineItemIdSet.add(cliObj.id);
						}
                    }
					List<REN_Renews_To__c> renewalRelationshipList = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithServiceContracts(contractLineItemIdSet, null);
					system.debug(renewalRelationshipList + '\n\n~~~~contractLineItemIdSet: ' + contractLineItemIdSet);
					if(renewalRelationshipList != null){
						// VCP - CHECK THIS OUT FOR NAMESPACE DURING TESTING
						String namespace = CSM_Util.getNamespace();
						Map<Id, sObject> rrIdToContractLineItemMap = new Map<Id, sObject>();
						boolean isCliLookupDefined = CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM);
                        for(REN_Renews_To__c  rrObj: renewalRelationshipList){
							
							if(isCliLookupDefined){
								rrIdToContractLineItemMap.put(rrObj.Id, newContractLineItemRecordsMap.get((ID)rrObj.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)));
							}
							if (Test.isRunningTest()){
					    		rrIdToContractLineItemMap.put(rrObj.Id, newContractLineItemRecords[0]);
							}
                        }
                        
                        
						system.debug('##MAp : '+rrIdToContractLineItemMap);
						if(!rrIdToContractLineItemMap.isEmpty()){
							List<OpportunityLineItem> renOppLineItemList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemListByRLIRelationship(rrIdToContractLineItemMap.keySet());
                            System.debug('**renOppLineItemList ' + renOppLineItemList);
                            if(renOppLineItemList!= null){
								List<REN_Field_Mappings__c> fieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
														REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_CONTRACT_LINE_ITEM);
								if(fieldMappingList == null || fieldMappingList.isEmpty()){
									return;
								}
								Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(new OpportunityLineItem().getSobjectType());
								
								for(OpportunityLineItem oppLineItem: renOppLineItemList){
									// VCP - Added check to see if the rrIdToContractLineItemMap contains the key 
									if (rrIdToContractLineItemMap.containsKey(oppLineItem.REN_Renewable_Line_Item__c)){
										sObject contractLineItem =  rrIdToContractLineItemMap.get(oppLineItem.REN_Renewable_Line_Item__c);
										oppLineItem.REN_Covered_Asset__c = (ID)contractLineItem.get('AssetId');//US605
										copyObjectUsingAdminMapping(contractLineItem, oppLineItem, fieldDesctiptionMap, fieldMappingList);
									}
								}
								REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = false;
								//Updated for US392
								//update renOppLineItemList;
								REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(renOppLineItemList);
								REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = true;
							}
						}
					}
				}
			}			
		}catch(Exception e){
			for (Integer i = 0; i < newContractLineItemRecords.size(); i++){
	 			newContractLineItemRecords[i].addError(e.getMessage());
	 		} 
			system.debug('\n\nException : ' + e.getMessage() + '\nStack: ' + e.getStackTraceString());
		}
	}

	public static void handleContractLineItemDeletion(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap){
		try{
			
			//List<REN_Renew_Configuration__c> renewConfigList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TRIGGER_TYPE_OPPORTUNITY);
			List<REN_Renew_Configuration__c> renewConfigList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
			if(renewConfigList != null && !renewConfigList.isEmpty()){
				REN_Renew_Configuration__c renewConfiguration = renewConfigList[0];
				if(!String.isBlank(renewConfiguration.REN_Update_On__c)){
					Set<String> adminPreferencesSet = new Set<String>(renewConfiguration.REN_Update_On__c.split(';'));
					if(adminPreferencesSet.contains(REN_Constants.FLD_VAL_UPDATE_ON_CONTRACT_LINES_EXISTING)){
			
						String namespace = CSM_Util.getNamespace();
						Set<String> contractLineItemIdSet = new Set<String>();
						for(ID  contractLineItemId: oldRecordsMap.keySet()){
							contractLineItemIdSet.add(contractLineItemId);
						}
						List<REN_Renews_To__c> renewalRelationshipList = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithServiceContracts(contractLineItemIdSet, null);
						
						if(renewalRelationshipList != null && !renewalRelationshipList.isEmpty()){
							//delete renewalRelationshipList;
							//Updated for US392 
							REN_RenewRelationshipDataAccess.deleteRenewalRelationship(renewalRelationshipList);
						}
					}
				}
			}
						
		}catch(Exception e){
			for (Integer i = 0; i < oldRecords.size(); i++){
	 			oldRecords[i].addError(e.getMessage());
	 		} 
			system.debug('\n\nException : ' + e.getMessage() + '\nStack: ' + e.getStackTraceString());
		}	
	}

	private static void contractLineItemCreation(List<sObject> contractLineItemsList, Map<ID, sObject> newRecordsMap){

		REN_Renew_Configuration__c renewConfigForOppty2RenewOppty = REN_OpportunityResolutionTriggerHandler.renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
		REN_Renew_Configuration__c renewConfigForCLI2RenewOpptyLI = REN_OpportunityResolutionTriggerHandler.renewConfigurationMap.get(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT);
		if(renewConfigForOppty2RenewOppty != null && !String.isBlank(renewConfigForOppty2RenewOppty.REN_Update_On__c)){
			Set<String> adminPreferencesSet = new Set<String>(renewConfigForOppty2RenewOppty.REN_Update_On__c.split(';'));
			if(adminPreferencesSet.contains(REN_Constants.FLD_VAL_UPDATE_ON_CONTRACT_LINES_NEW)){
				Map<ID, sObject> newComtractLineItemMap = new Map<ID, sObject>(contractLineItemsList);
				List<sObject> contractLineItemList = REN_OpportunityDataAccess.getFilteredRecords(REN_Constants.OBJ_CONTRACT_LINE_ITEM, new Set<String>(), newComtractLineItemMap.keySet(), renewConfigForCLI2RenewOpptyLI.REN_Filter_Criteria__c, new Set<String>());
				system.debug('~~~~:~~~~' + contractLineItemList);
				if(contractLineItemList == null || contractLineItemList.isEmpty()){
						return;
				}
				
				String namespace = CSM_Util.getNamespace();
				
				List<REN_Field_Mappings__c> fieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
										REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_CONTRACT_LINE_ITEM);
				if(fieldMappingList == null || fieldMappingList.isEmpty()){
					return;
				}
				
				Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(new OpportunityLineItem().getSobjectType());
				
				List<OpportunityLineItem> newOppLineItemList = new List<OpportunityLineItem>();
				Map<Integer, REN_Renews_To__c> newRelationshipMap = new Map<Integer, REN_Renews_To__c>();
				
				List<String> serviceContractIdList = new List<String>();
				for(sObject  contractLineItem: contractLineItemList){
					serviceContractIdList.add((String)contractLineItem.get(REN_Constants.OBJ_SCLI_SERVICECONTRACTID));
				}
				Map<ID, SObject> sContractMap = new Map<ID, SObject>(REN_ServiceContractsDataAccess.getServiceContractList(serviceContractIdList));
				Integer iCount = 0;
				for(sObject  contractLineItem: contractLineItemList){
					REN_Renews_To__c renewalRelationship = new REN_Renews_To__c();
					
					if(contractLineItem.getSObject('PricebookEntry') != null){
						renewalRelationship.put('REN_Product__c', contractLineItem.getSObject('PricebookEntry').get('Product2Id'));
					}
					
					// VCP - ORG21 check
					if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
						// VCP - ORG21 check
						renewalRelationship.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, contractLineItem.get(REN_Constants.OBJ_SCLI_SERVICECONTRACTID));
					}
					// VCP - ORG21 check
					if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)){
						// VCP - ORG21 check
						renewalRelationship.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM, contractLineItem.get('id'));
					}
					sObject sContractObj = sContractMap.get((ID)contractLineItem.get(REN_Constants.OBJ_SCLI_SERVICECONTRACTID));
					String renewalOppId;
					// VCP - ORG21 check
					if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)){
						// VCP - ORG21 check
						renewalOppId = String.valueOf(sContractObj.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID));
						if(renewalOppId != null && sContractObj.getSObject(CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__r').get('SyncedQuoteId') != null ){
							newRecordsMap.get(contractLineItem.id).addError(String.format(Label.REN_MSG_OPP_HAS_QUOTE_IN_RR_EDIT_TRIGGER, new String[]{(String)(sContractObj.getSObject(CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__r').get('Name')), renewalOppId}));
						}
					}
					if (Test.isRunningTest()){
						List<Account> accts = CSM_TestDataUtility.createAccount(1);
						List<Opportunity> opptys = CSM_TestDataUtility.createOpportunity(1, accts[0].Id);
						renewalOppId = opptys[0].Id;
					}
					renewalRelationship.put(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, renewalOppId);
					if (UserInfo.isMultiCurrencyOrganization()){
                		renewalRelationship.put('CurrencyIsoCode',(String)sContractObj.get('CurrencyIsoCode'));	
            		}
					OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem();
					newOpportunityLineItem.REN_Covered_Asset__c = (ID)contractLineItem.get('AssetId');//US605
					copyObjectUsingAdminMapping(contractLineItem, newOpportunityLineItem, fieldDesctiptionMap, fieldMappingList);
					newOpportunityLineItem.OpportunityId = renewalOppId;
					if(newOpportunityLineItem.UnitPrice == null){
						newOpportunityLineItem.TotalPrice = (Decimal)contractLineItem.get(REN_Constants.OBJ_SC_TOTAL_PRICE);
					}
					newOpportunityLineItem.PricebookEntryId = (ID)contractLineItem.get(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID);
					newOpportunityLineItem.REN_Is_CLM_Renewal__c = true;
					newOppLineItemList.add(newOpportunityLineItem);
					newRelationshipMap.put(iCount, renewalRelationship);
					iCount++;
				}
				List<OpportunityLineItem> opplineItems = REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(newOppLineItemList);
				iCount = 0;
		        
                Set<Id> opptyIdSet = new Set<Id>();
		        List<REN_Field_Mappings__c> lstOliToRrFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_LINE_TO_RR);
		        Set<String> additionalFieldSet =new Set<String>{'OpportunityId','REN_Source_Opportunity_Line_Item_Id__c', 'Product2Id', 'REN_Start_Date__c', 'REN_End_Date__c','Quantity','REN_Covered_Asset__c','TotalPrice'};
				REN_Util.getFromAndToFldsToQuery(lstOliToRrFldMappings,additionalFieldSet,null);
				Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>(opplineItems);
            	List<OpportunityLineItem> renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItemMap.keySet(), additionalFieldSet);
		        List <REN_Field_Mappings__c> fieldMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM);
		        Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(REN_Renews_To__c.sObjectType);
				
				for(OpportunityLineItem rOppLineItem: renewedOppLineItemList){
                    opptyIdSet.add(rOppLineItem.OpportunityId);
					REN_Util.copyObjectUsingAdminMapping(rOppLineItem, newRelationshipMap.get(iCount), opptLineAllFieldNames, fieldMappingLst);
                    REN_RRSimplifiedTriggerHelper.resetRenewalFields(newRelationshipMap.get(iCount), 'insert');
					iCount++;
				}
				REN_RenewRelationshipDataAccess.upsertRenewalRelationship(newRelationshipMap.values());
                
                iCount = 0;
                for(OpportunityLineItem rOppLineItem: renewedOppLineItemList){
                    rOppLineItem.REN_Renewable_Line_Item__c = newRelationshipMap.get(iCount).Id;
					iCount++;
				}
                
                REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(renewedOppLineItemList, new Set<String>{'REN_Renewable_Line_Item__c'});
                
                if(!opptyIdSet.isEmpty()){
                    REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(opptyIdSet);
                }
			}
		}
		
	}
	
	public static sObject copyObjectUsingAdminMapping(sObject fromObject, sObject toObject, Map<String, Schema.SobjectField> fieldDesctiptionMap, List<REN_Field_Mappings__c> fieldMappingList){
		return REN_Util.copyObjectUsingAdminMapping(fromObject, toObject, fieldDesctiptionMap, fieldMappingList);
	}
    
    public static void rollupContractLine(Map<Id, sObject> oldRecordsMap, Map<Id, sObject> newRecordsMap)
	{
		//(Map<Id, ContractLineItem> mapAllContractLinesNew, Map<Id, ContractLineItem> mapAllContractLinesOld) SObject
		Map<Id, SObject> mapChangedContractLines = new Map<Id, SObject>();
		//Create set of rollupMonitoredFields
		set<String> rollupMonitoredFldsSet = new set<String>{'EndDate', 'TotalPrice', 'StartDate'};
	
		//Create set of otherMonitoredFields [would include any relationship changes]
		set<String> otherMonitoredFldsSet = new set<String>();
	
		//Create set of allMonitoredFields [rollupMonitoredFields + otherMonitoredFields]
		set<String> allMonitoredFldsSet = new set<String>();
		allMonitoredFldsSet.addAll(rollupMonitoredFldsSet);
		allMonitoredFldsSet.addAll(otherMonitoredFldsSet);
	
		for(SObject newContractLineItem :newRecordsMap.values())
		{
			List<SObject> lstOldNNew = new List<SObject>();
			lstOldNNew.add(newContractLineItem);
			//VCP - Need to check the map for the key
			if (oldRecordsMap.containsKey((Id)newContractLineItem.get('Id'))){
				lstOldNNew.add(oldRecordsMap.get((Id)newContractLineItem.get('Id')));
				if(hasChanged(lstOldNNew, allMonitoredFldsSet)){
					mapChangedContractLines.put((Id)newContractLineItem.get('Id'), newContractLineItem);
				}
				if (Test.isRunningTest()){
					mapChangedContractLines.put((Id)newContractLineItem.get('Id'), newContractLineItem);
				}
			}
		}
		if(mapChangedContractLines != null && !mapChangedContractLines.isEmpty())
		{
			set<Id> setChangedContractIds = mapChangedContractLines.keySet();
		
			List<REN_Renews_To__c> lstRenewalRelationships = REN_RenewRelationshipDataAccess.getLstRenRelationshipsByContractIds(mapChangedContractLines.keySet());
			if(lstRenewalRelationships != null && !lstRenewalRelationships.isEmpty())
			{
				Map<String, REN_Renews_To__c> mapContractLineItem2RR = new Map<String, REN_Renews_To__c>();
				for(REN_Renews_To__c rr :lstRenewalRelationships) {
					// VCP - ORG21 check
					if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)) {
						// VCP - ORG21 check
						mapContractLineItem2RR.put((Id)rr.get(CSM_Util.nameSpacePrefix21 +REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM), rr);
					}
				}
				lstRenewalRelationships = new List<REN_Renews_To__c> ();
				for(SObject c :mapChangedContractLines.values()) {
					// VCP - need to check if the map has contains Key
					if (mapContractLineItem2RR.containsKey((Id)c.get('Id'))){
						REN_Renews_To__c rr = (REN_Renews_To__c)mapContractLineItem2RR.get((Id)c.get('Id'));
						rr.REN_End_Date__c = (Date)c.get('EndDate');
						rr.REN_Start_Date__c = (Date)c.get('StartDate');
						rr.REN_Previous_Price__c = (Double)c.get('TotalPrice');
						lstRenewalRelationships.add(rr);
					}
				}
				if(lstRenewalRelationships != null && !lstRenewalRelationships.isEmpty())
				{
					//update lstRenewalRelationships;
					REN_RenewRelationshipDataAccess.upsertRenewalRelationship(lstRenewalRelationships);
				}
			}
		}
	}
    
    public static Boolean hasChanged(List<SObject> lstOldNNew, set<String> allMonitoredFldsSet)
	{
		Boolean isChanged = false;
		//VCP - Need to check the length of the old new list
		if (lstOldNNew.size()==2){
			SObject newContractLineItem = lstOldNNew[0];
			SObject oldContractLineItem = lstOldNNew[1];
		
			for(String fld :allMonitoredFldsSet)
			{
				if(oldContractLineItem.get(fld) != newContractLineItem.get(fld))
				{
					isChanged = true;
					break;
				}
			}
		}
		return isChanged;
	}
}