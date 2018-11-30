public with sharing class REN_NonSimplifiedRenewalHandler {
	
	private static REN_Opportunities opptyRenewal = new REN_Opportunities();
	private static REN_ServiceContracts scRenewal = new REN_ServiceContracts();
	private static REN_Assets assetsRenewal = new REN_Assets();
	private static REN_OpportunityLineItems oliRenewal = new REN_OpportunityLineItems();
	private static REN_ContractLineItems cliRenewals = new REN_ContractLineItems();
	
	public static void renewOpportunity(List<Opportunity> opportunityList){
		REN_Opportunities.NOTIFY_OWNER = true;
		List<Opportunity> filteredOpportunityList = new List<Opportunity>();
		List<Opportunity> filteredOpptyListForAssets = new List<Opportunity>();
		List<Opportunity> filteredOpptyListForSc = new List<Opportunity>();
		Map<Id, Opportunity> sourceOpptyMap = new Map<Id, Opportunity>(opportunityList);
		if(opportunityList != null && !opportunityList.isEmpty()){
			filteredOpptyListForAssets = getOriginalOpportunityFromCriteria(sourceOpptyMap, REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
			filteredOpptyListForSc = getOriginalOpportunityFromCriteria(sourceOpptyMap, REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
			filteredOpportunityList = getOriginalOpportunityFromCriteria(sourceOpptyMap, REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);					
		}
		Map<Id, Opportunity> opptyToCreateAssetsMap = new Map<Id, Opportunity>(filteredOpptyListForAssets);
		Map<Id, Opportunity> opptyToCreateScMap = new Map<Id, Opportunity>(filteredOpptyListForSc);		
		Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>(filteredOpportunityList);		
        Map<Id, Id> opptyToOpportunityContactMap =  new Map<Id, Id>();        
        //Check for all qualified assets,OLI and CLI here.  
        Map<ID, OpportunityLineItem> qualifiedAssetOli = filterAssetOli(opptyToCreateAssetsMap, opptyToOpportunityContactMap);
        Map<ID, OpportunityLineItem> qualifiedCliOli = filterCliOli(opptyToCreateScMap);
        Map<ID, OpportunityLineItem> qualifiedOli = filterOli(opptyMap);
       
		String toFromObjectKey = REN_Constants.OBJ_REN_RENEWS_TO + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM;
        List<REN_Field_Mappings__c> fmList = REN_RenewReferenceData.getInstance().fieldMappingsMap.get(toFromObjectKey);
		List<REN_Renews_To__c> rliList = new List<REN_Renews_To__c>();
		List<REN_Renews_To__c> cliRliList = new List<REN_Renews_To__c>();
		List<Asset> renewedAssetList = new List<Asset>();
		List<SObject> renewedCliList = new List<SObject>();
		Map<Id, Id> sourceOpptyLineId2AssetIdMap = new Map<Id, Id>();
		Map<Id, SObject> sourceOliId2CliMap = new Map<Id, SObject>();
		
		//Create assets here whether or not Renewed Opportunity generated.
		if(qualifiedAssetOli != null && !qualifiedAssetOli.isEmpty() && filteredOpptyListForAssets != null && !filteredOpptyListForAssets.isEmpty()) {
	        renewedAssetList = processAssetOli(qualifiedAssetOli, opptyToCreateAssetsMap, opptyToOpportunityContactMap, fmList);
	        if(renewedAssetList!=null && !renewedAssetList.isEmpty()){
	    		REN_AssetDataAccess.insertAssets(renewedAssetList);
	    	}
			For(Asset assetsRetrieved : renewedAssetList){
				sourceOpptyLineId2AssetIdMap.put(assetsRetrieved.REN_Oppty_Line_Item_Id__c, assetsRetrieved.id);
			}
		}
		//Create Sc here whether or not Renewed Opportunity generated.
		Map<Id, SObject> opptyToSCMap = new  Map<Id, SObject>();
		List<SObject> ScList = new List<SObject>();
		if(scRenewal.entitlementPkgInstalled && qualifiedCliOli != null 
			&& !qualifiedCliOli.isEmpty() && opptyToCreateScMap != null 
			&& !opptyToCreateScMap.isEmpty()) {					
			opptyToSCMap = handleRenewalScGeneration(opptyToCreateScMap);
			Map<Id, id> opptyIdToScIdMap = new  Map<Id, id>();
			for(SObject sc : opptyToSCMap.values()){
				opptyIdToScIdMap.put((Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID), sc.id);
			}
			if(qualifiedCliOli != null && !qualifiedCliOli.isEmpty()) {
				renewedCliList = processCliOli(qualifiedCliOli,opptyIdToScIdMap, fmList);
				if(renewedCliList!=null && !renewedCliList.isEmpty()){
					REN_ContractLineItemDataAccess.insertContractLineItem(renewedCliList);
				}
				String namespace = CSM_Util.getNameSpace();
				if(renewedCliList != null && !renewedCliList.isEmpty()) {
					for(SObject cli:renewedCliList){
						sourceOliId2CliMap.put((Id)cli.get(CSM_Util.nameSpacePrefix21 + 'REN_Oppty_Line_Item_Id__c'), cli);
					}
				}
			}		        
		}
			
		//create Renewal opportunity here only if there are qualifiedOli from given criteria.
      	REN_RenewalWrapper wrapper;     	
       	if(qualifiedOli != null && !qualifiedOli.isEmpty()){
       		Map<Id, Id> opptyToRenewalIdMap = new Map<Id, Id>();
			wrapper = handleRenewalGeneration(opportunityList,filteredOpportunityList);			
			if(wrapper.opptyToRenewalMap != null && !wrapper.opptyToRenewalMap.isEmpty()){
				 opptyToRenewalIdMap = wrapper.createOpptyToRenewalIdMap();
			}			
			List<OpportunityLineItem> renewedOliList=new List<OpportunityLineItem>();
	    	if(wrapper.opptyToRenewalMap != null && !wrapper.opptyToRenewalMap.isEmpty()){
	    		List<SObject> serviceContractList = new List<SObject>(); 
	    		if(scRenewal.entitlementPkgInstalled){
		    		for(SObject sc : opptyToSCMap.values()){
		    			Id sourceOpptyId = (Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID);
		    			if(wrapper.opptyToRenewalMap.containsKey(sourceOpptyId)){
		    				Opportunity renewalOppty = wrapper.opptyToRenewalMap.get(sourceOpptyId);
		    				sc.put(CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c', renewalOppty.id);
							serviceContractList.add(sc);
		    			}
					}
					//update serviceContractList;				
					if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c')){
						REN_ServiceContractsDataAccess.updateServiceContracts(serviceContractList,new List<String>{CSM_Util.nameSpacePrefix21 +'REN_Renewal_Opportunity__c'});
					}
					handleRenewalScSource(wrapper, opptyToSCMap.values(), opptyMap);
	    		}
				renewedOliList = processOli(qualifiedOli, opptyToRenewalIdMap);
				if(renewedOliList != null && !renewedOliList.isEmpty()){
					REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(renewedOliList);
				}										
				set<ID> renewedOliIdSet = new set<ID>();
				List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
				Map<Id, OpportunityLineItem> sourceToRenewalOli = new Map<Id, OpportunityLineItem>();
				// Set the original line item id here itself.
				for(OpportunityLineItem oli:renewedOliList){
					
					renewedOliIdSet.add(oli.id);
					OpportunityLineItem newOLI = new OpportunityLineItem(id = oli.id, REN_Covered_Asset__c = oli.REN_Covered_Asset__c);
					sourceToRenewalOli.put(oli.REN_Source_Opportunity_Line_Item_Id__c, newOLI);
					oliList.add(newOLI);
				}
				assetsRenewal.setCoveredAssetOnOliAndAsset(renewedAssetList, createOpptyToLineItemListMap(qualifiedAssetOli.values()), sourceToRenewalOli);
				REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliList, new Set<String>{'REN_Covered_Asset__c', 'REN_Covered_Product__c'});
				REN_RenewalRelationships renewalRelationship = new REN_RenewalRelationships();
				List<OpportunityLineItem> renewOliList = REN_OpportunityLineItemDataAccess.getOpptyLineItemsById(renewedOliIdSet, 
									renewalRelationship.getMappingFieldsToQuery(REN_Constants.OBJ_REN_RENEWS_TO + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM));				
				Map<String,REN_Renews_To__c> oliToRliObjMap = renewalRelationship.createRenewalRelationships(renewOliList, sourceOpptyLineId2AssetIdMap, sourceOliId2CliMap, opptyToRenewalIdMap);	
				rliList = oliToRliObjMap.values();
				saveSources(wrapper.sourceList, wrapper.opptyToSourceMap);
				REN_RRSimplifiedTriggerHelper.processRliRecords(rliList);
				REN_RenewRelationshipDataAccess.insertRenewalRelationship(rliList);        	
	        	// perform metrics calculation.
	        	REN_OpportunityMetricsBusiness.resetRliAndOliMetricsFields(new Set<Id>(opptyToRenewalIdMap.values()));
	        	//Populating Renewable Line Item lookup on OLI with corresponding RLI
                List<OpportunityLineItem> oliUpdateRliLookup = new List<OpportunityLineItem>();
                if(!oliToRliObjMap.isEmpty()){
                    for(String opliId : oliToRliObjMap.keySet()){
                    	String oliId = opliId.split(':')[1];
                    	OpportunityLineItem newOLI;
                    	if(opliId.startsWith('C:') && !oliToRliObjMap.containsKey('A:'+oliId)){
                    		newOLI = new OpportunityLineItem(id = oliId, REN_Renewable_Line_Item__c = oliToRliObjMap.get(opliId).Id);
                    	}else{
                    		newOLI = new OpportunityLineItem(id = oliId, REN_Renewable_Line_Item__c = oliToRliObjMap.get(opliId).Id);
                    	}
                        oliUpdateRliLookup.add(newOLI);
                    }
                }
                if(oliUpdateRliLookup.size() > 0){
                    REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliUpdateRliLookup, new Set<String>{'REN_Renewable_Line_Item__c'});
                }
	    	}
	    } 	    	    	    
	}
	
	private static Map<ID, OpportunityLineItem> filterAssetOli(Map<Id, Opportunity> opptyMap, Map<Id, Id> opptyToOpportunityContactMap) {
		Set<Id> opptyIds = opptyMap.keySet();
		assetsRenewal.getOpportunityContactMap(opptyIds);
		assetsRenewal.filterOpportunityByAccountAndContactRole(opptyMap, opptyToOpportunityContactMap);
		opptyIds = opptyMap.keySet();
		return new Map<ID, OpportunityLineItem>((List<OpportunityLineItem>)assetsRenewal.applyOpliCriteria(opptyIds, 
													REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET));
	}
	
	private static Map<ID, OpportunityLineItem> filterOli(Map<Id, Opportunity> opptyMap) {
		return new Map<ID, OpportunityLineItem>((List<OpportunityLineItem>)oliRenewal.applyOpliCriteria(opptyMap.keySet(), 
													REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT));
	}
	
	private static Map<ID, OpportunityLineItem> filterCliOli(Map<Id, Opportunity> opptyMap) {
		Map<ID, OpportunityLineItem> filteredCliOli = new Map<ID, OpportunityLineItem>();
		if(scRenewal.entitlementPkgInstalled) {
			filteredCliOli =  new Map<ID, OpportunityLineItem>((List<OpportunityLineItem>)scRenewal.applyOpliCriteria(opptyMap.keySet(), 
																			REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM));
		}
		return filteredCliOli;
	}
	
	private static REN_RenewalWrapper handleRenewalGeneration(List<Opportunity> opportunityList,List<Opportunity> filteredOpportunityList){
		REN_RenewalWrapper wrapper;
		if(opportunityList != null && !opportunityList.isEmpty()){
			Map<Id, Opportunity> sourceOpptyMap = new Map<Id, Opportunity>(opportunityList);
			wrapper = createRenewalOpportunities(sourceOpptyMap,filteredOpportunityList);
		}
		return wrapper;
	}
	
	private static Map<Id, SObject> handleRenewalScGeneration(Map<Id, Opportunity> sourceOpptyMap){
		Map<Id, SObject> opptyToSCMap=new Map<Id, SObject>();
		if(sourceOpptyMap != null && !sourceOpptyMap.isEmpty()){		
			List<SObject> serviceContractList = createRenewalServiceContracts(sourceOpptyMap);
			if(serviceContractList != null && !serviceContractList.isEmpty()){
				opptyToSCMap = createSourceToRenewalSCMap(serviceContractList);
			}
        }
        return opptyToSCMap;
	}
	
	private static void handleRenewalScSource(REN_RenewalWrapper wrapper,List<SObject> serviceContractList,Map<Id, Opportunity> sourceOpptyMap){
		if(wrapper.opptyToRenewalMap != null && !wrapper.opptyToRenewalMap.isEmpty()){
			wrapper.opptyToSourceMap = scRenewal.createSourceForSC(serviceContractList, sourceOpptyMap);
			updateRenewalOpptyOnSc(serviceContractList, wrapper.opptyToRenewalMap);
		}
	}
	private static Map<Id, SObject> createSourceToRenewalSCMap(List<SObject> serviceContractList) {
		Map<Id, SObject> opptyToSCMap = new  Map<Id, SObject>();
		for(SObject sc : serviceContractList){
			opptyToSCMap.put((Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID), sc);
		}
		return opptyToSCMap;
	}
	
	private static void updateRenewalOpptyOnSc(List<SObject> serviceContractList, Map<Id, Opportunity> opptyToRenewalMap){
		List<Opportunity> opptyList = new List<SObject>();
		for(SObject serviceContract : serviceContractList){
			Id sourceOpptyId = (Id)serviceContract.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID);
			if(opptyToRenewalMap.containsKey(sourceOpptyId)){
				Opportunity renewalOppty = opptyToRenewalMap.get(sourceOpptyId);
				if(renewalOppty != null){
					renewalOppty.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT, serviceContract.Id);
					opptyList.add(renewalOppty);
				}
			}
		}
		if(!opptyList.isEmpty()){
			update opptyList;
		}
	}
	
	private static void saveSources(List<REN_Source__c> sourceList, Map<Id, REN_Source__c> opptyToSourceMap){
		List<REN_Source__c> sourceListToInsert = new List<REN_Source__c>();
		REN_Source__c sourceForSC = new REN_Source__c();
		if(sourceList != null && !sourceList.isEmpty()){
			sourceListToInsert.addAll(sourceList);
			for(REN_Source__c source : sourceList){
				if(opptyToSourceMap != null && source.REN_Contributor__c != null && opptyToSourceMap.containsKey(source.REN_Contributor__c)){
					sourceForSC = opptyToSourceMap.get(source.REN_Contributor__c);
					sourceForSC.REN_Inheriting_Opportunity__c = source.REN_Inheriting_Opportunity__c;
					sourceListToInsert.add(sourceForSC);
				}
			}
			if(!sourceListToInsert.isEmpty()){
				REN_SourceDataAccess.saveSourceRecords(sourceListToInsert);
			}
		}
	}
	
	private static List<Opportunity> getOriginalOpportunityFromCriteria(Map<Id, Opportunity> originalOpptyMap, String renewConfigName){
		List<Opportunity> filteredOpportunityList = opptyRenewal.applyOpportunityCriteria(originalOpptyMap.keySet(), renewConfigName,(REN_Constants.OBJ_OPPORTUNITY + ':' + REN_Constants.OBJ_OPPORTUNITY));	
		return filteredOpportunityList;
	}
	
	private static REN_RenewalWrapper createRenewalOpportunities(Map<Id, Opportunity> originalOpptyMap,List<Opportunity> filteredOpportunityList){
		REN_RenewalWrapper wrapper = new REN_RenewalWrapper();
  		List<REN_Source__c> sourceList = new List<REN_Source__c>();
		if(!filteredOpportunityList.isEmpty()){
			List<Opportunity> opptyListWithAddOn = opptyRenewal.findAddOnOpportunities(filteredOpportunityList);
			Map<Id, SObject> sourceToRenewOpptyMap = new Map<Id, SObject>();
			Map<Id, Opportunity> sourceToRenewedObjMap = new Map<Id, Opportunity>();
			List<Opportunity> opportunityList = new List<Opportunity>();
			Opportunity renewedOppty;
			system.debug('filteredOpportunityList====>'+filteredOpportunityList);
			if(!filteredOpportunityList.isEmpty()){
				sourceToRenewOpptyMap = opptyRenewal.createRenewalsMap(filteredOpportunityList, null);
				if(!sourceToRenewOpptyMap.values().isEmpty()){
					insert sourceToRenewOpptyMap.values();
					for(Id opptyId : sourceToRenewOpptyMap.keySet()) {
						renewedOppty = (Opportunity)sourceToRenewOpptyMap.get(opptyId);
						sourceToRenewedObjMap.put(opptyId, renewedOppty);
					}
					sourceList = opptyRenewal.createSource(sourceToRenewOpptyMap);
				}
			}
			opptyRenewal.handleOpportunityWithAddOn(originalOpptyMap,opptyListWithAddOn, sourceList);
			wrapper.sourceList = sourceList;
			wrapper.opptyToRenewalMap = createSourceToRenewalOpptyMap(opptyListWithAddOn, sourceToRenewedObjMap);
		}
		return wrapper;
	}
	
	private static Map<Id, Opportunity> createSourceToRenewalOpptyMap(List<Opportunity> opptyListWithAddOn, Map<Id, Opportunity> opptyToRenewalOpptyMap){
		if(opptyListWithAddOn != null && !opptyListWithAddOn.isEmpty()){
			for(Opportunity oppty : opptyListWithAddOn){
				opptyToRenewalOpptyMap.put(oppty.Id, new Opportunity(Id = oppty.REN_Append_Renewal_Opportunity__c));
			}
		}
		return opptyToRenewalOpptyMap;
	}
	
	private static List<SObject> createRenewalServiceContracts(Map<Id, Opportunity> sourceOpptyMap){
		List<SObject> serviceContractList = new List<SObject>();
		List<REN_Source__c> sourceList = new List<REN_Source__c>();
		if(scRenewal.entitlementPkgInstalled){
			List<Opportunity> filteredOpportunityList = sourceOpptyMap.values();
			if(!filteredOpportunityList.isEmpty()){
				List<Opportunity> addOnOpptyList = new List<Opportunity>();
				List<SObject> appendedSCList = new List<SObject>();
				scRenewal.filterAppendedServiceContracts(filteredOpportunityList, addOnOpptyList, appendedSCList);
				if(!filteredOpportunityList.isEmpty()){
					serviceContractList = scRenewal.createRenewals(filteredOpportunityList, null);
					//insert serviceContractList;
					REN_ServiceContractsDataAccess.insertServiceContractList(serviceContractList);
				}
				appendedSCList = scRenewal.validateAddOnSC(appendedSCList, addOnOpptyList);
				if(appendedSCList != null && !appendedSCList.isEmpty()){
					update appendedSCList;
					serviceContractList.addAll(appendedSCList);
				}
			}
		}
		return serviceContractList;
	}
	
	private static List<Asset> processAssetOli(Map<ID, OpportunityLineItem> qualifiedAssetOli,
													Map<Id, Opportunity> opptyMap, 
													Map<Id, Id> opptyToOpportunityContactMap, 
													List<REN_Field_Mappings__c> fmList){
		List<Asset> renewedAssetList;
		if(qualifiedAssetOli != null && !qualifiedAssetOli.isEmpty()) {
			renewedAssetList = (List<Asset>)assetsRenewal.createRenewals(qualifiedAssetOli.values(), null);
			assetsRenewal.setChannelFields(renewedAssetList, opptyMap, opptyToOpportunityContactMap);
		}
		return renewedAssetList;
	}
	
	private static List<SObject> processCliOli(Map<ID, OpportunityLineItem> qualifiedCliOli, Map<Id, Id> opptyToSCMap,
													   List<REN_Field_Mappings__c> fmList) {
		List<SObject> renewedCliList;
		if(qualifiedCliOli != null && !qualifiedCliOli.isEmpty()) {
			renewedCliList = cliRenewals.createRenewals(qualifiedCliOli.values(),opptyToSCMap);
		}
		return renewedCliList;
	}
	
	private static List<OpportunityLineItem>  processOli(Map<ID, OpportunityLineItem> qualifiedOli, 
	 														Map<Id, id> opptyToRenewalMap){
		List<OpportunityLineItem>renewedOliList=new List<OpportunityLineItem>();								
		renewedOliList = oliRenewal.createRenewals(qualifiedOli.values(), opptyToRenewalMap);			
		return renewedOliList;
	}
	
	private static Map<Id, List<OpportunityLineItem>> createOpptyToLineItemListMap(List<OpportunityLineItem> opliList) {
		Map<Id, List<OpportunityLineItem>> opptyToLineItemListMap = new Map<Id, List<OpportunityLineItem>>();
		if(opliList != null && !opliList.isEmpty()) {
			for(OpportunityLineItem oli : opliList){
				List<OpportunityLineItem> oppToOliList = opptyToLineItemListMap.get(oli.OpportunityId);
				if(oppToOliList == null) {
					oppToOliList = new List<OpportunityLineItem>();
				}
				oppToOliList.add(oli);
				opptyToLineItemListMap.put(oli.OpportunityId, oppToOliList);
			}
		}
		return opptyToLineItemListMap;
	}

	public class REN_RenewalWrapper {
		public List<REN_Source__c> sourceList;
		public Map<Id, Opportunity> opptyToRenewalMap;
		public Map<Id, Id> opptyToRenewalSCMap;
		public Map<Id, REN_Source__c> opptyToSourceMap;
		
		public Map<Id, Id> createOpptyToRenewalIdMap(){
			Map<Id, Id> opptyToRenewalMap = new Map<Id, Id>();
			if(this.opptyToRenewalMap != null && !this.opptyToRenewalMap.isEmpty()){
				for(Id opptyId : this.opptyToRenewalMap.keySet()){
					Opportunity renewalOppty = this.opptyToRenewalMap.get(opptyId);
					opptyToRenewalMap.put(opptyId, renewalOppty.Id);
				}
			}
			return opptyToRenewalMap;
		}
	}
}