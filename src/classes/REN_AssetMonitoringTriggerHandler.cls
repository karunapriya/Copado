public with sharing class REN_AssetMonitoringTriggerHandler
{
	public static List<Asset> newAssets = new List<Asset>();
	public static Schema.SObjectType objectOpptLine;
	
	public static void handleAssetUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	{
			Map<Id, Asset> mapAllAssetsNew = new Map<Id, Asset>();
			Map<Id, Asset> mapAllAssetsOld = new Map<Id, Asset>();
			if(oldRecordsMap != null && !oldRecordsMap.isEmpty())
			{
				for(Id i :oldRecordsMap.keySet())
				{
					mapAllAssetsOld.put(Id.valueOf(i), (Asset)(oldRecordsMap.get(i)));
				}
			}
			if(newRecordsMap != null && !newRecordsMap.isEmpty())
			{
				for(Id i :newRecordsMap.keySet())
				{
					mapAllAssetsNew.put(Id.valueOf(i), (Asset)(newRecordsMap.get(i)));
				}
			}
			rollupAsset(mapAllAssetsNew, mapAllAssetsOld);
			
			//loop through Assets
			REN_Renew_Configuration__c renewConfiguration = REN_OpportunityResolutionTriggerHandler.renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
			if(renewConfiguration != null){
				newAssets = (List<Asset>)newRecords;
				map<String, Asset> mapAssetId2Assets = new map<String, Asset>();
				//Map<String, List<String>> assetFilter = REN_Util.getConfiguredFilter(renewConfiguration.Id, REN_Constants.OBJ_ASSET);
				if(renewConfiguration.REN_Update_On__c != null && (renewConfiguration.REN_Update_On__c).trim() != '')
				{
					List<String> lstUpdateOns = (renewConfiguration.REN_Update_On__c).split(';');
					Boolean canUpdateOppt = false;
					if(lstUpdateOns != null && !lstUpdateOns.isEmpty())
					{
						for(String s :lstUpdateOns)
						{
							if(s == REN_Constants.FLD_VAL_UPDATE_ON_ASSET_EX)
							{
								canUpdateOppt = true;
							}
						}
					}
					if(canUpdateOppt){
						system.debug('In here'); 
						REN_Renew_Configuration__c renewConfigurationForAssetToROLI = REN_OpportunityResolutionTriggerHandler.renewConfigurationMap.get(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT);
						Map<ID, Asset> assetIdMap = new Map<ID, Asset>(newAssets);
						List<Asset> filteredRocordList = (List<Asset>)REN_OpportunityDataAccess.getFilteredRecords('Asset', new Set<String>(), assetIdMap.keySet(), renewConfigurationForAssetToROLI.REN_Filter_Criteria__c, new Set<String>());
						if(filteredRocordList == null || filteredRocordList.isEmpty()){
							return;
						}
						mapAssetId2Assets = new Map<String, Asset>();
						
						for(Asset assetObj: filteredRocordList){//US410
							boolean isSyncRequired = true;
							if(String.isNotBlank(renewConfigurationForAssetToROLI.RLM_Filter_Logic__c) && renewConfigurationForAssetToROLI.RLM_Filter_Logic__c.indexOfIgnoreCase('OR') > 0){
								Map<String, REN_Line_Criteria__c> lineCriteriaMap = new Map<String, REN_Line_Criteria__c>();
								for(REN_Line_Criteria__c criteria : renewConfigurationForAssetToROLI.Line_Criteria__r) {
									lineCriteriaMap.put('' + (Integer)criteria.RLM_LineNo__c, criteria);
								}
								isSyncRequired = REN_Util.evaluateLogicalExp(renewConfigurationForAssetToROLI.RLM_Filter_Logic__c, oldRecordsMap.get(assetObj.id), newRecordsMap.get(assetObj.id), lineCriteriaMap);
							}else{
								if(renewConfigurationForAssetToROLI.Line_Criteria__r != null){
							 		for(REN_Line_Criteria__c criteria : renewConfigurationForAssetToROLI.Line_Criteria__r) {
							 			system.debug(oldRecordsMap.get(assetObj.id).get(criteria.RLM_Field_Name__c) + '\n\n1~~~~=: ' + newRecordsMap.get(assetObj.id).get(criteria.RLM_Field_Name__c));
							 			if(String.isNotBlank(criteria.RLM_Field_Name__c) && oldRecordsMap.get(assetObj.id).get(criteria.RLM_Field_Name__c) == newRecordsMap.get(assetObj.id).get(criteria.RLM_Field_Name__c)){
							 				isSyncRequired = false;
							 				system.debug(criteria + '\n\n~~~~CLI: ' + assetObj);
							 				break;
							 			}
							 		}
							 	}
							}
							if(isSyncRequired){
								mapAssetId2Assets.put(assetObj.id, assetObj);
							}
						}
						
						system.debug('mapAssetId2Assets : ' + mapAssetId2Assets);
						if(mapAssetId2Assets != null && !mapAssetId2Assets.isEmpty())
						{
							//Updated for US392 
							List<REN_Renews_To__c> lstRenewsTo = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithAssetRenewal(mapAssetId2Assets.keySet());
							
							//one asset can renew to multiple opptlines
							//so, Map<String, Set<String>> //assetId, set<renOpptLnIds>
							map<String,set<String>> mapAssetId2MultipleRli = new 	map<String,set<String>>();
							set<Id> rliIdSet = new set<Id>();
							for(REN_Renews_To__c rt :lstRenewsTo){
								set<String> rrIdSet = mapAssetId2MultipleRli.get(rt.REN_Asset__c);
								if(rrIdSet == null){
									rrIdSet = new set<String>();
								}
								rrIdSet.add(rt.Id);
								mapAssetId2MultipleRli.put(rt.REN_Asset__c, rrIdSet);
								rliIdSet.add(rt.Id);
							}
						    List<OpportunityLineItem> lstOpportunityLines = REN_OpportunityLineItemDataAccess.getOpportunityLineItemListByRLIRelationship(rliIdSet);
						    
						    map<String, OpportunityLineItem> rrIdToOliMap = new map<String, OpportunityLineItem>(); 
						    for(OpportunityLineItem opLn :lstOpportunityLines)
						    {
						    	rrIdToOliMap.put(opLn.REN_Renewable_Line_Item__c, opLn);
						    }
						    
						    objectOpptLine = new OpportunityLineItem().getSobjectType();
						    Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpptLine);
						    List<OpportunityLineItem> lstOpptLines2Update = new List<OpportunityLineItem>(); 
							String mappingName = REN_Constants.FLD_MAP_ASSET_TO_OPPT;
							List<REN_Field_Mappings__c> lstFMapping = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_ASSET, mappingName);
							system.debug('lstFMapping : ' + lstFMapping);
							for(String aId: mapAssetId2MultipleRli.keySet())
							{
						        Asset currentAsset = mapAssetId2Assets.get(aId);
						        system.debug('currentAsset : ' + currentAsset);
						        set<String> setRliIds = mapAssetId2MultipleRli.get(aId);
						        List<OpportunityLineItem> lstExistingOpptLines = new List<OpportunityLineItem>();
						        for(String s :setRliIds){
						        	if(rrIdToOliMap.containsKey(s)){
						        		lstExistingOpptLines.add(rrIdToOliMap.get(s));
						        	}
						        }
						        
						        system.debug('lstExistingOpptLines : ' + lstExistingOpptLines);
						        for(OpportunityLineItem existingOpptLine :lstExistingOpptLines)
						        {		        
							        system.debug('existingOpptLine : ' + existingOpptLine);
							        if(currentAsset != null)
							        {
								        for(REN_Field_Mappings__c fMapping :lstFMapping)
								        {
								            SObjectField opptLineSObjectFld = opptLineAllFieldNames.get(fMapping.REN_To_Field_API_Name__c);
								            existingOpptLine = REN_OpportunityResolutionHelper.getMappedAssetBasedOpportunityLineItem(new List<OpportunityLineItem>{existingOpptLine}, String.valueOf(opptLineSObjectFld.getDescribe().getType()),
																					                  new List<Asset> {currentAsset}, fMapping.REN_Default_Value__c,
																					                  fMapping.REN_To_Field_API_Name__c, fMapping.REN_From_Field_API_Name__c);
									    }
								        if(existingOpptLine.Quantity == null && currentAsset.Quantity == null){
								        	newRecordsMap.get(currentAsset.id).addError(String.format(System.Label.REN_LBL_FIELD_IS_REQUIRED, new String[] {System.Label.REN_LBL_SCLI_QUANTITY}));
								        }else{
								        	lstOpptLines2Update.add(existingOpptLine);
								        }
							        }
						        }
						    }
							//update lstOpptLines2Update;
							//Updated for US392  
							REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(lstOpptLines2Update);
						}
					}
				}
			}
	}
	
	public static void rollupAsset(Map<Id, Asset> mapAllAssetsNew, Map<Id, Asset> mapAllAssetsOld)
	{
		Map<Id, Asset> mapChangedAssets = new Map<Id, Asset>();
		//Create set of rollupMonitoredFields
		set<String> rollupMonitoredFldsSet = new set<String>{'REN_End_Date__c', 'Price'};
	
		//Create set of otherMonitoredFields [would include any relationship changes]
		set<String> otherMonitoredFldsSet = new set<String>();
	
		//Create set of allMonitoredFields [rollupMonitoredFields + otherMonitoredFields]
		set<String> allMonitoredFldsSet = new set<String>();
		allMonitoredFldsSet.addAll(rollupMonitoredFldsSet);
		allMonitoredFldsSet.addAll(otherMonitoredFldsSet);
	
		for(Asset newAsset :mapAllAssetsNew.values())
		{
			List<Asset> lstOldNNew = new List<Asset>();
			lstOldNNew.add(newAsset);
			lstOldNNew.add(mapAllAssetsOld.get(newAsset.Id));
			if(hasChanged(lstOldNNew, allMonitoredFldsSet))
			{
				mapChangedAssets.put(newAsset.Id, newAsset);
			}
		}
		
		if(mapChangedAssets != null && !mapChangedAssets.isEmpty())
		{
			List<REN_Renews_To__c> lstRenewalRelationships = REN_RenewRelationshipDataAccess.getLstRenewalRelationships(mapChangedAssets.values());
			if(lstRenewalRelationships != null && !lstRenewalRelationships.isEmpty())
			{
				//Eswar Bala - DE1383 - Fix for earlier bad assumption in code that 1 Asset is tied to 1 RR. Changed that to be Map<String, List>
				Map<String, List<REN_Renews_To__c>> mapAsset2RR = new Map<String, List<REN_Renews_To__c>>();
				for(REN_Renews_To__c rr :lstRenewalRelationships)
				{
					List<REN_Renews_To__c> rrLstTmp = new List<REN_Renews_To__c>();
					if(mapAsset2RR.containsKey(rr.REN_Asset__c))
					{
						rrLstTmp = mapAsset2RR.get(rr.REN_Asset__c);
					}
					rrLstTmp.add(rr);
					mapAsset2RR.put(rr.REN_Asset__c, rrLstTmp);
				}
				lstRenewalRelationships = new List<REN_Renews_To__c> ();
				for(Asset a :mapChangedAssets.values())
				{
					List<REN_Renews_To__c> rrLst = mapAsset2RR.get(a.Id);
					for(REN_Renews_To__c rr : rrLst)
					{
						rr.REN_End_Date__c = a.REN_End_Date__c;
						rr.REN_Previous_Price__c = a.Price;
						lstRenewalRelationships.add(rr);
					}
				}
				if(lstRenewalRelationships != null && !lstRenewalRelationships.isEmpty())
				{
					REN_RenewRelationshipDataAccess.updateRenewalRelationship(lstRenewalRelationships);
				}
			}
		}
	}
	
	public static Boolean hasChanged(List<Asset> lstOldNNew, set<String> allMonitoredFldsSet)
	{
		Asset newAsset = lstOldNNew[0];
		Asset oldAsset = lstOldNNew[1];
		Boolean isChanged = false;
	
		for(String fld :allMonitoredFldsSet)
		{
			if(oldAsset.get(fld) != newAsset.get(fld))
			{
				isChanged = true;
				break;
			}
		}
		return isChanged;
	}
	
	public static void validateCurrencyChange(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		boolean isMultiCurrencyEnabled = UserInfo.isMultiCurrencyOrganization();
		if (isMultiCurrencyEnabled){	
	    	Set<String> assetIdSet = new Set<String>();
	    	for(ID aID: newRecordsMap.keySet()){
	    		assetIdSet.add(aID);
	    	}
	    		
	    	List<REN_Renews_To__c> assetRelationshipList = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithAssetRenewal(assetIdSet);
	    	Map<ID, REN_Renews_To__c> assetIDRenewRelationshipMap = new Map<ID, REN_Renews_To__c>();
	    		
	    	for(REN_Renews_To__c rr: assetRelationshipList){
	    		assetIDRenewRelationshipMap.put(rr.REN_Asset__c, rr);
	    	}
		    for(sObject newAsset: newRecords){
		    	sObject oldAsset = oldRecordsMap.get(newAsset.id);
		    	if(isMultiCurrencyEnabled && (oldAsset.get(REN_Constants.REN_CURRENCY_ISO_CODE) != newAsset.get(REN_Constants.REN_CURRENCY_ISO_CODE) && assetIDRenewRelationshipMap.containsKey(newAsset.id))){
		    		newAsset.addError(Label.CSM_LBL_ASSET_CURRENCY_ERROR_MSG);
		    	}
		    }
	    }	
	}
}