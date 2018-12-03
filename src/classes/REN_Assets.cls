/**
 * Created Date		: Sep 6, 2016
 * Developed By		: Amit, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Amit					User Story				Sep 6, 2016			1.1					@description
 *
 */
public with sharing class REN_Assets extends REN_Renewals {

	public override List<SObject> createRenewals(List<SObject> opliList, Map<Id, Id> sourceToRenewalMap){
		List<SObject> renewedObjectList = new List<SObject>();
    	if(opliList != null && !opliList.isEmpty()){
    		renewedObjectList = this.applyMapping(opliList, REN_Constants.OBJ_ASSET + ':' +REN_Constants.OBJ_OPPTY_LINE_ITEM);
    	}
    	return renewedObjectList;
	}
	
	public override List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey){
		List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
		List<SObject> renewedObjectList = new List<SObject>();
		if(fmList != null && !fmList.isEmpty()){
			for(SObject currentObj : objectList){
				Asset newAsset = new Asset(Name = (String)currentObj.get('Name'));
				newAsset.REN_Oppty_Line_Item_Id__c = currentObj.Id;
				newAsset.REN_Opportunity__c = (Id)currentObj.get('OpportunityId');
				newAsset.Product2Id = (Id)currentObj.get('Product2Id');
				for(REN_Field_Mappings__c fieldMapping : fmList){
					this.copyMappedValues(fieldMapping, newAsset, currentObj);
				}
				renewedObjectList.add(newAsset);
			}
		}
		return renewedObjectList;
	}
	
	public void filterOpportunityByAccountAndContactRole(Map<Id, Opportunity> filteredOpportunityMap,
																		Map<Id, Id> opptyToOpportunityContactMap){
		if(filteredOpportunityMap != null && !filteredOpportunityMap.isEmpty()){
			for(Opportunity oppty : filteredOpportunityMap.values()){
				if(String.isEmpty(oppty.AccountId) && !opptyToOpportunityContactMap.containsKey(oppty.Id)){
					filteredOpportunityMap.remove(oppty.Id);
				}
			}
		}
	}
	
	public void setChannelFields(List<Asset> assetList, Map<Id, Opportunity> filteredOpportunityMap, Map<Id, Id> opptyToOpportunityContactMap){
		for(Asset asset : assetList){
			if (asset.REN_Opportunity__c != null){
				Opportunity oppty = filteredOpportunityMap.get(asset.REN_Opportunity__c);
				if(oppty.AccountId != null){
					asset.AccountId = oppty.AccountId;
				}else if(opptyToOpportunityContactMap.containsKey(asset.REN_Opportunity__c)){
					asset.ContactId = opptyToOpportunityContactMap.get(asset.REN_Opportunity__c);
				}
				asset.CHL_Partner_Account_1__c = oppty.CHL_Partner_Account_1__c;
				asset.CHL_Partner_Account_1_Contact__c = oppty.CHL_Partner_Account_1_Contact__c;
				asset.CHL_Partner_Account_1_Type__c = oppty.CHL_Partner_Account_1_Type__c;
				asset.CHL_Partner_Account_2__c = oppty.CHL_Partner_Account_2__c;
				asset.CHL_Partner_Account_2_Contact__c = oppty.CHL_Partner_Account_2_Contact__c;
				asset.CHL_Partner_Account_2_Type__c = oppty.CHL_Partner_Account_2_Type__c;
			}
		}
	}
	
	public void setCoveredAssetOnOliAndAsset(List<Asset> renewAssetList, Map<Id, List<OpportunityLineItem>> opptyToLineItemMap, Map<Id, OpportunityLineItem> opliToRenewalMap){
		List<OpportunityLineItem> opliToUpdate = new List<OpportunityLineItem>();
		List<Asset> assetToUpdate = new List<Asset>();
		List<String> fieldList = new List<String>{REN_Constants.OBJ_OPPLN_FLD_CVD_ASSET,REN_Constants.OBJ_OPPLN_FLD_CVD_PRD};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM,fieldList,CSM_Constants.DML_OPERATION_UPDATE);
		//DE3045 : Updated code for CPU time limit issue.
		for(Asset asset : renewAssetList){
			List<OpportunityLineItem> sourceOpliList = opptyToLineItemMap.get(asset.REN_Opportunity__c);
			
			OpportunityLineItem renewedOptyli = opliToRenewalMap.get(asset.REN_Oppty_Line_Item_Id__c);
			if(renewedOptyli != null) {
				system.debug('renewedOpli.REN_Covered_Asset__c $$$$$$$ '+renewedOptyli.REN_Covered_Asset__c);
				asset.REN_Covered_Asset__c = renewedOptyli.REN_Covered_Asset__c;	
			}
			assetToUpdate.add(asset);
			
			//TODO: this logic can be improved to save some CPU time for large data processing.
			for(OpportunityLineItem sourceOpli : sourceOpliList){
				if(sourceOpli != null && asset.Product2Id.equals(sourceOpli.REN_Covered_Product__c)){
					OpportunityLineItem renewedOpli = opliToRenewalMap.get(sourceOpli.Id);
					renewedOpli.REN_Covered_Asset__c = asset.Id;
					renewedOpli.REN_Covered_Product__c = null;
					opliToUpdate.add(renewedOpli);
					break;
				}
			}
		}
		
		if(!assetToUpdate.isEmpty()){
			List<String> assetFieldList = new List<String>{REN_Constants.OBJ_OPPLN_FLD_CVD_ASSET};
			CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET,assetFieldList,CSM_Constants.DML_OPERATION_UPDATE);
			update assetToUpdate;
		}
	}
	
	public Map<Id, Id> getOpportunityContactMap(Set<Id> opptyIds){
		Map<Id, Id> opptyToOpportunityContactMap = new Map<Id, Id>();
		List<OpportunityContactRole> opptyContactRoleList = CSM_OpportunityDataAccess.fetchOpportunityContactRole(opptyIds);
		for(OpportunityContactRole ocr : opptyContactRoleList){
			opptyToOpportunityContactMap.put(ocr.OpportunityId, ocr.ContactId);
		}
		return opptyToOpportunityContactMap;
	}
}