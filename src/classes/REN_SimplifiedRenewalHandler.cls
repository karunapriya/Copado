public with sharing class REN_SimplifiedRenewalHandler {
	
	private static REN_Opportunities opptyRenewal = new REN_Opportunities();
	private static REN_ServiceContracts scRenewal = new REN_ServiceContracts();
	private static REN_Assets assetsRenewal = new REN_Assets();
	private static REN_ContractLineItems cliRenewals = new REN_ContractLineItems();
	private static REN_SimplifiedRenewalRelationships srrRenewals = new REN_SimplifiedRenewalRelationships();
	
	public static void renewOpportunity(List<Opportunity> opportunityList){
		REN_Opportunities.NOTIFY_OWNER = true;
		Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>(opportunityList);
        Map<Id, Id> opptyToOpportunityContactMap =  new Map<Id, Id>();
        Map<ID, OpportunityLineItem> qualifiedAssetOli = filterAssetOli(opptyMap, opptyToOpportunityContactMap);
        Map<ID, OpportunityLineItem> qualifiedCliOli = filterCliOli(opptyMap);
        if((qualifiedAssetOli != null && !qualifiedAssetOli.isEmpty())
        	|| (qualifiedCliOli != null && !qualifiedCliOli.isEmpty())) {
			REN_RenewalWrapper wrapper = handleRenewalGeneration(opportunityList);
			if(wrapper.opptyToRenewalMap != null && !wrapper.opptyToRenewalMap.isEmpty()){
				Map<Id, Id> opptyToRenewalIdMap = wrapper.createOpptyToRenewalIdMap();
				String toFromObjectKey = REN_Constants.OBJ_REN_RENEWS_TO + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM;
		        List<REN_Field_Mappings__c> fmList = REN_RenewReferenceData.getInstance().fieldMappingsMap.get(toFromObjectKey);
				List<REN_Renews_To__c> rliList = new List<REN_Renews_To__c>();
				List<REN_Renews_To__c> cliRliList = new List<REN_Renews_To__c>();
				if(qualifiedAssetOli != null && !qualifiedAssetOli.isEmpty()) {
			        rliList = processAssetOli(qualifiedAssetOli, opptyMap, opptyToOpportunityContactMap, wrapper.opptyToRenewalMap, fmList);
				}
				if(scRenewal.entitlementPkgInstalled && qualifiedCliOli != null && !qualifiedCliOli.isEmpty()) {
					hanndleRenewalScGeneration(wrapper, opptyMap, opptyToRenewalIdMap);
			        cliRliList = processCliOli(qualifiedCliOli, wrapper, fmList);
			        rliList.addAll(cliRliList);
				}
				saveSources(wrapper.sourceList, wrapper.opptyToSourceMap);
				REN_RRSimplifiedTriggerHelper.processRliRecords(rliList);
		        REN_RenewRelationshipDataAccess.insertRenewalRelationship(rliList);
		        // Generate master OLI and perform metrics calculation.
		        REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(new Set<Id>(opptyToRenewalIdMap.values()));
			}
        }
	}
	
	private static Map<ID, OpportunityLineItem> filterAssetOli(Map<Id, Opportunity> opptyMap, Map<Id, Id> opptyToOpportunityContactMap) {
		Set<Id> opptyIds = opptyMap.keySet();
		assetsRenewal.getOpportunityContactMap(opptyIds);
		assetsRenewal.filterOpportunityByAccountAndContactRole(opptyMap, opptyToOpportunityContactMap);
		// Some of the opportunities might have been filtered based on contact role.
		// so re-populate the keyset
		opptyIds = opptyMap.keySet();
		return new Map<ID, OpportunityLineItem>((List<OpportunityLineItem>)assetsRenewal.applyOpliCriteria(opptyIds, 
													REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET));
	}
	
	private static Map<ID, OpportunityLineItem> filterCliOli(Map<Id, Opportunity> opptyMap) {
		Map<ID, OpportunityLineItem> filteredCliOli = new Map<ID, OpportunityLineItem>();
		if(scRenewal.entitlementPkgInstalled) {
			filteredCliOli =  new Map<ID, OpportunityLineItem>((List<OpportunityLineItem>)scRenewal.applyOpliCriteria(opptyMap.keySet(), 
																			REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM));
		}
		return filteredCliOli;
	}
	
	private static REN_RenewalWrapper handleRenewalGeneration(List<Opportunity> opportunityList){
		REN_RenewalWrapper wrapper;
		if(opportunityList != null && !opportunityList.isEmpty()){
			Map<Id, Opportunity> sourceOpptyMap = new Map<Id, Opportunity>(opportunityList);
			wrapper = createRenewalOpportunities(sourceOpptyMap);
		}
		return wrapper;
	}
	
	private static void hanndleRenewalScGeneration(REN_RenewalWrapper wrapper, Map<Id, Opportunity> sourceOpptyMap, Map<Id, Id> opptyToRenewalIdMap){
		if(wrapper.opptyToRenewalMap != null && !wrapper.opptyToRenewalMap.isEmpty()){
			List<SObject> serviceContractList = createRenewalServiceContracts(sourceOpptyMap, opptyToRenewalIdMap);
			if(serviceContractList != null && !serviceContractList.isEmpty()){
				wrapper.opptyToSourceMap = scRenewal.createSourceForSC(serviceContractList, sourceOpptyMap);
				updateRenewalOpptyOnSc(serviceContractList, wrapper.opptyToRenewalMap);
				createSourceToRenewalSCMap(wrapper, serviceContractList);
			}
        }
	}
	
	private static void createSourceToRenewalSCMap(REN_RenewalWrapper wrapper, List<SObject> serviceContractList) {
		wrapper.opptyToRenewalSCMap = new  Map<Id, Id>();
		for(SObject sc : serviceContractList){
			wrapper.opptyToRenewalSCMap.put((Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID), sc.Id);
		}
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
	
	private static REN_RenewalWrapper createRenewalOpportunities(Map<Id, Opportunity> originalOpptyMap){
		REN_RenewalWrapper wrapper = new REN_RenewalWrapper();
        
		List<Opportunity> filteredOpportunityList = opptyRenewal.applyOpportunityCriteria(originalOpptyMap.keySet(), REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,(REN_Constants.OBJ_OPPORTUNITY + ':' + REN_Constants.OBJ_OPPORTUNITY));
		
        List<REN_Source__c> sourceList = new List<REN_Source__c>();
		if(!filteredOpportunityList.isEmpty()){
			List<Opportunity> opptyListWithAddOn = opptyRenewal.findAddOnOpportunities(filteredOpportunityList);
			Map<Id, SObject> sourceToRenewOpptyMap = new Map<Id, SObject>();
			Map<Id, Opportunity> sourceToRenewedObjMap = new Map<Id, Opportunity>();
			List<Opportunity> opportunityList = new List<Opportunity>();
			Opportunity renewedOppty;
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
	
	private static List<SObject> createRenewalServiceContracts(Map<Id, Opportunity> sourceOpptyMap, Map<Id, Id> opptyToRenewalIdMap){
		List<SObject> serviceContractList = new List<SObject>();
		List<REN_Source__c> sourceList = new List<REN_Source__c>();
		if(scRenewal.entitlementPkgInstalled){
			List<Opportunity> filteredOpportunityList = scRenewal.applyOpportunityCriteria(sourceOpptyMap.keySet(), REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,(REN_Constants.OBJ_SERVICE_CONTRACT + ':' + REN_Constants.OBJ_OPPORTUNITY));
			if(!filteredOpportunityList.isEmpty()){
				List<Opportunity> addOnOpptyList = new List<Opportunity>();
				List<SObject> appendedSCList = new List<SObject>();
				scRenewal.filterAppendedServiceContracts(filteredOpportunityList, addOnOpptyList, appendedSCList);
				if(!filteredOpportunityList.isEmpty()){
					serviceContractList = scRenewal.createRenewals(filteredOpportunityList, opptyToRenewalIdMap);
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
	
	private static List<REN_Renews_To__c> processAssetOli(Map<ID, OpportunityLineItem> qualifiedAssetOli, Map<Id, Opportunity> opptyMap, 
															Map<Id, Id> opptyToOpportunityContactMap, Map<Id, Opportunity> opptyToRenewalMap, 
															List<REN_Field_Mappings__c> fmList){
		List<REN_Renews_To__c> assetRLIList;
		if(qualifiedAssetOli != null && !qualifiedAssetOli.isEmpty()) {
			List<Asset> renewedAssetList = (List<Asset>)assetsRenewal.createRenewals(qualifiedAssetOli.values(), null);
			assetsRenewal.setChannelFields(renewedAssetList, opptyMap, opptyToOpportunityContactMap);
			REN_AssetDataAccess.insertAssets(renewedAssetList);
			assetRLIList = srrRenewals.createAssetRLIs(renewedAssetList, qualifiedAssetOli, opptyToRenewalMap, fmList);
		}
		return assetRLIList;
	}
	
	private static List<REN_Renews_To__c> processCliOli(Map<ID, OpportunityLineItem> qualifiedCliOli, 
															REN_RenewalWrapper wrapper, List<REN_Field_Mappings__c> fmList) {
		List<REN_Renews_To__c> cliRLIList;
		if(qualifiedCliOli != null && !qualifiedCliOli.isEmpty()) {
			List<SObject> renewedCliList = cliRenewals.createRenewals(qualifiedCliOli.values(), wrapper.opptyToRenewalSCMap);
			REN_ContractLineItemDataAccess.insertContractLineItem(renewedCliList);
			cliRLIList = srrRenewals.createCliRR(renewedCliList, qualifiedCliOli, wrapper.opptyToRenewalMap, fmList);
		}
		return cliRLIList;
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