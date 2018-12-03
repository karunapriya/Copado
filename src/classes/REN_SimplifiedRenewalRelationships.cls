public with sharing class REN_SimplifiedRenewalRelationships extends REN_Renewals {
	
	public List<REN_Renews_To__c> createAssetRLIs(List<Asset> renewedAssetList, 
															Map<ID, OpportunityLineItem> qualifiedAssetOli,
															Map<Id, Opportunity> opptyToRenewalMap, 
															List<REN_Field_Mappings__c> fmList) {
		List<REN_Renews_To__c> assetRLIList = new List<REN_Renews_To__c>();
		if(renewedAssetList != null && !renewedAssetList.isEmpty()) {
			for(Asset asset : renewedAssetList){
				if(qualifiedAssetOli.containsKey(asset.REN_Oppty_Line_Item_Id__c)){
					OpportunityLineItem opli = qualifiedAssetOli.get(asset.REN_Oppty_Line_Item_Id__c);
					REN_Renews_To__c assetRLI = new REN_Renews_To__c();
		            assetRLI.REN_Renews_To__c = opptyToRenewalMap.get(opli.OpportunityId).Id;
		            assetRLI.REN_Product__c =  opli.Product2Id;
		            assetRLI.REN_Start_Date__c = opli.REN_Start_Date__c;
		            assetRLI.REN_End_Date__c =  opli.REN_End_Date__c;
		            assetRLI.REN_Quantity__c = opli.Quantity;	
		            assetRLI.REN_Asset__c = asset.Id;
		            for(REN_Field_Mappings__c fieldMapping : fmList){
		            	this.copyMappedValues(fieldMapping, assetRLI, opli);
		            }
		            assetRLIList.add(assetRLI);
				}
			}
		}
		return assetRLIList;	
	}
	
	public List<REN_Renews_To__c> createCliRR(List<SObject> renewedCliList, 
										Map<ID, OpportunityLineItem> qualifiedCliOli, 
										Map<Id, Opportunity> opptyToRenewalMap, 
										List<REN_Field_Mappings__c> fmList){
		List<REN_Renews_To__c> cliRLIList = new List<REN_Renews_To__c>();
		if(renewedCliList != null && !renewedCliList.isEmpty()) {
			for(SObject cli : renewedCliList){
				if(qualifiedCliOli.containsKey((Id)cli.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID))){
					OpportunityLineItem opli = qualifiedCliOli.get((Id)cli.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID));
					REN_Renews_To__c renewalRelCli = new REN_Renews_To__c();
		            renewalRelCli.REN_Renews_To__c = opptyToRenewalMap.get(opli.OpportunityId).Id;
		            renewalRelCli.REN_Product__c =  opli.Product2Id;
		            renewalRelCli.REN_Start_Date__c =  opli.REN_Start_Date__c;
		            renewalRelCli.REN_End_Date__c =  opli.REN_End_Date__c;
		            renewalRelCli.REN_Quantity__c = opli.Quantity;	
		            renewalRelCli.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM, cli.Id);
		            renewalRelCli.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, (Id)cli.get('ServiceContractId'));
		            for(REN_Field_Mappings__c fieldMapping : fmList){
		            	this.copyMappedValues(fieldMapping, renewalRelCli, opli);
		            }
		            cliRLIList.add(renewalRelCli);
				}
			}
		}
		return cliRLIList;
	}
}