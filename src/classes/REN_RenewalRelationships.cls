/**
 * Created Date		: Oct 7, 2016
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
 * Amit					User Story				Oct 7, 2016			1.1					@description
 *
 */
public with sharing class REN_RenewalRelationships extends REN_Renewals {
	
	private static final Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
															REN_Constants.OBJ_OPPORTUNITY, 
															CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);

	public Map<String,REN_Renews_To__c> createRenewalRelationships(List<SObject> renewedOpliList, Map<Id, Id> opliToRenewAssetIdMap, Map<Id, SObject> opliToRenewCliMap, Map<Id, Id> sourceOpp2RenewOppMap){
		List<SObject> scToUpdateList = new List<SObject>();
		List<Opportunity> opptyToUpdateList = new List<Opportunity>();
        Map<String,REN_Renews_To__c> oliToRliObjMap = new Map<String,REN_Renews_To__c>();
    	if(renewedOpliList != null && !renewedOpliList.isEmpty()){
    		String toFromObjectKey = REN_Constants.OBJ_REN_RENEWS_TO + ':' + REN_Constants.OBJ_OPPTY_LINE_ITEM;
            List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
    		for(SObject sObj : renewedOpliList){
    			OpportunityLineItem opli = (OpportunityLineItem)sObj;
    			REN_Renews_To__c renewalRelAsset = new REN_Renews_To__c();
    			if(SS_Constants.isSimplifiedDataModelEnabled){
    				renewalRelAsset = createAssetRRWithSDMEnabled(opli, opliToRenewAssetIdMap, fmList, sourceOpp2RenewOppMap);
    			} else {
    				renewalRelAsset = createAssetRR(opli, opliToRenewAssetIdMap, fmList);
    			}
    			if(renewalRelAsset != null){
		    		oliToRliObjMap.put('A:'+opli.Id, renewalRelAsset);
    			}
    			if(entitlementPkgInstalled){
    				REN_Renews_To__c renewalRelCli = new REN_Renews_To__c();
    				if(SS_Constants.isSimplifiedDataModelEnabled){
    					renewalRelCli = createCliRRWithSDMEnabled(opli, opliToRenewCliMap, fmList, sourceOpp2RenewOppMap);
    				} else {
	    				renewalRelCli = createCliRR(opli, opliToRenewCliMap, fmList);
    				}
	    			if(renewalRelCli != null){
			    		oliToRliObjMap.put('C:'+opli.Id, renewalRelCli);
	    			}
    			}
    		}
    	}
    	return oliToRliObjMap;
	}
	
	public REN_Renews_To__c createAssetRR(OpportunityLineItem opli, Map<Id, Id> opliToRenewAssetIdMap, List<REN_Field_Mappings__c> fmList){
		REN_Renews_To__c renewalRelAsset;
		if(opliToRenewAssetIdMap.containsKey(opli.REN_Source_Opportunity_Line_Item_Id__c)){
			renewalRelAsset = new REN_Renews_To__c();
            renewalRelAsset.REN_Renews_To__c = opli.OpportunityId;
            renewalRelAsset.REN_Product__c =  opli.Product2Id;
            renewalRelAsset.REN_Start_Date__c =  opli.REN_Start_Date__c;
            renewalRelAsset.REN_End_Date__c =  opli.REN_End_Date__c;
            renewalRelAsset.REN_Quantity__c = opli.Quantity;	
            renewalRelAsset.REN_Asset__c = opliToRenewAssetIdMap.get(opli.REN_Source_Opportunity_Line_Item_Id__c);
            for(REN_Field_Mappings__c fieldMapping : fmList){
            	this.copyMappedValues(fieldMapping, renewalRelAsset, opli);
            }
		}
		return renewalRelAsset;
	}
	public REN_Renews_To__c createAssetRRWithSDMEnabled(OpportunityLineItem opli, Map<Id, Id> opliToRenewAssetIdMap, List<REN_Field_Mappings__c> fmList, Map<Id, Id> sourceOpp2RenewOppMap){
		REN_Renews_To__c renewalRelAsset;
		if(opliToRenewAssetIdMap.containsKey(opli.Id)){
			renewalRelAsset = new REN_Renews_To__c();
            //renewalRelAsset.REN_Renewal_Product_Line_Id__c = opli.Id;
            if(sourceOpp2RenewOppMap != null && !sourceOpp2RenewOppMap.isEmpty()) {
            	if(sourceOpp2RenewOppMap.containsKey((Id)opli.OpportunityId)) {
            		renewalRelAsset.REN_Renews_To__c = sourceOpp2RenewOppMap.get((Id)opli.OpportunityId);
            	}
            }
            renewalRelAsset.REN_Product__c =  opli.Product2Id;
            renewalRelAsset.REN_Start_Date__c =  opli.REN_Start_Date__c;
            renewalRelAsset.REN_End_Date__c =  opli.REN_End_Date__c;
            renewalRelAsset.REN_Quantity__c = opli.Quantity;	
            renewalRelAsset.REN_Asset__c = opliToRenewAssetIdMap.get(opli.Id);
            for(REN_Field_Mappings__c fieldMapping : fmList){
            	this.copyMappedValues(fieldMapping, renewalRelAsset, opli);
            }
		}
		return renewalRelAsset;
	}
	
	public REN_Renews_To__c createCliRR(OpportunityLineItem opli, Map<Id, SObject> opliToRenewCliMap, List<REN_Field_Mappings__c> fmList){
		REN_Renews_To__c renewalRelCli;
		if(opliToRenewCliMap.containsKey(opli.REN_Source_Opportunity_Line_Item_Id__c)){
			renewalRelCli = new REN_Renews_To__c();
            renewalRelCli.REN_Renews_To__c = opli.OpportunityId;
            renewalRelCli.REN_Product__c =  opli.Product2Id;
            renewalRelCli.REN_Start_Date__c =  opli.REN_Start_Date__c;
            renewalRelCli.REN_End_Date__c =  opli.REN_End_Date__c;
            renewalRelCli.REN_Quantity__c = opli.Quantity;	
            SObject cli = opliToRenewCliMap.get(opli.REN_Source_Opportunity_Line_Item_Id__c);
            renewalRelCli.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM, cli.Id);
            renewalRelCli.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, (Id)cli.get('ServiceContractId'));
            for(REN_Field_Mappings__c fieldMapping : fmList){
            	this.copyMappedValues(fieldMapping, renewalRelCli, opli);
            }
		}
		return renewalRelCli;
	}
	
	public REN_Renews_To__c createCliRRWithSDMEnabled(OpportunityLineItem opli, Map<Id, SObject> opliToRenewCliMap, List<REN_Field_Mappings__c> fmList, Map<Id, Id> sourceOpp2RenewOppMap){
		REN_Renews_To__c renewalRelCli;
		if(opliToRenewCliMap.containsKey(opli.Id)){
			renewalRelCli = new REN_Renews_To__c();
            //renewalRelCli.REN_Renewal_Product_Line_Id__c = opli.Id;
            if(sourceOpp2RenewOppMap != null && !sourceOpp2RenewOppMap.isEmpty()) {
            	if(sourceOpp2RenewOppMap.containsKey((Id)opli.OpportunityId)) {
            		renewalRelCli.REN_Renews_To__c = sourceOpp2RenewOppMap.get((Id)opli.OpportunityId);
            	}
            }
            renewalRelCli.REN_Product__c =  opli.Product2Id;
            renewalRelCli.REN_Start_Date__c =  opli.REN_Start_Date__c;
            renewalRelCli.REN_End_Date__c =  opli.REN_End_Date__c;
            renewalRelCli.REN_Quantity__c = opli.Quantity;	
            SObject cli = opliToRenewCliMap.get(opli.Id);
            renewalRelCli.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM, cli.Id);
            renewalRelCli.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, (Id)cli.get('ServiceContractId'));
            for(REN_Field_Mappings__c fieldMapping : fmList){
            	this.copyMappedValues(fieldMapping, renewalRelCli, opli);
            }
		}
		return renewalRelCli;
	}
}