public with sharing class CHL_PartnerOppTriggerHelper {

	public static void copyPOFieldsFromMasterOppty(Map<ID, Opportunity> opportunityMap, List<CHL_Partner_Opportunity__c> partnerOpptyList) {
		List<CHL_Partner_Opportunity__c> partnerOptyUpdatedList = copyFromMasterOppty(opportunityMap, partnerOpptyList);
		if(partnerOptyUpdatedList != null && !partnerOptyUpdatedList.isEmpty()) {
			CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
			CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
			CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(partnerOptyUpdatedList);
		}
	}

	public static void resetSyncFieldAfterInsert(Map<Id, CHL_Partner_Opportunity__c> newRecordsMap) {
		List<CHL_Partner_Opportunity__c> newRecords = newRecordsMap.values();
		Set<ID> oppIdSet = new Set<ID>();
		List<CHL_Partner_Opportunity__c> oppIdToSetSet = new List<CHL_Partner_Opportunity__c> ();
		Map<ID, CHL_Partner_Opportunity__c> syncPartOppMap = new Map<ID, CHL_Partner_Opportunity__c>();
		for (CHL_Partner_Opportunity__c newRec: newRecords) {
			if (String.isNotBlank(newRec.CHL_Syncing__c)) {
				syncPartOppMap.put(newRec.id, newRec);
				oppIdSet.add(newRec.CHL_Opportunity__c);
				if (newRec.CHL_Syncing__c.contains(CHL_Constants.SYNCING_OPTION_TO_MO)) {
					oppIdToSetSet.add(newRec);
				}
			}					
		}
		if(oppIdSet!=null && !oppIdSet.isEmpty()){
			resetFields(oppIdSet , null);
		}		
		if (!oppIdToSetSet.isEmpty()) {
			ID jobID = System.enqueueJob(new CHL_QuoteSyncQueueableJob(oppIdToSetSet));
		}
	}

	public static void resetFields(Set<ID> oppIdSet, Map<ID, sObject> newRecordsMap ) {
		List<CHL_Partner_Opportunity__c> resetPOList = new List<CHL_Partner_Opportunity__c>();
		List<CHL_Partner_Opportunity__c> poList;
		Map<Id,List<CHL_Partner_Opportunity__c>> oppIdToListOfPOMap = new Map<Id,List<CHL_Partner_Opportunity__c>>();
		List<CHL_Partner_Opportunity__c> partnerOpptyList;		
		List<CHL_Partner_Opportunity__c> allPOList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunity(oppIdSet);
		if(allPOList != null && !allPOList.isEmpty()){
			for(CHL_Partner_Opportunity__c po : allPOList){
				if(oppIdToListOfPOMap.containsKey(po.CHL_Opportunity__c)){
					poList = oppIdToListOfPOMap.get(po.CHL_Opportunity__c);					
				} else{
					poList = new List<CHL_Partner_Opportunity__c>();
					//poList.add(po);
				}
				poList.add(po);
				oppIdToListOfPOMap.put(po.CHL_Opportunity__c,poList);
			}
		}
		if(oppIdToListOfPOMap != null && !oppIdToListOfPOMap.isEmpty()){
			for(Id oppId : oppIdToListOfPOMap.keySet()){
				partnerOpptyList = new List<CHL_Partner_Opportunity__c>();
				partnerOpptyList = oppIdToListOfPOMap.get(oppId);
				if(newRecordsMap == null) {
					partnerOpptyList.remove(0);
				}
				//system.debug('partnerOpptyList :: '+partnerOpptyList);
				for(CHL_Partner_Opportunity__c poObj: partnerOpptyList){
					if(newRecordsMap != null && !newRecordsMap.containsKey(poObj.Id)) {
						poObj.CHL_Syncing__c = null;											
						resetPOList.add(poObj);
					} else if(newRecordsMap == null ) {
						poObj.CHL_Syncing__c = null;											
						resetPOList.add(poObj);
					}
				}
			}
			//system.debug('resetPOList :: '+resetPOList);
		}
		if (!resetPOList.isEmpty() ) {
			//CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
			//CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
			CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(resetPOList);
		}
	
	}

	public static void syncWithOpportunityBeforeUpdate(Map<ID, CHL_Partner_Opportunity__c> syncPartOppMap) {
		List < String > oppIdList = new List < String > ();
		for (CHL_Partner_Opportunity__c obj: syncPartOppMap.values()) {
			oppIdList.add(obj.CHL_Opportunity__c);
		}
		Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>(REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(oppIdList));
		syncWithOpportunity(syncPartOppMap, oppMap);
	}


	private static void syncWithOpportunity(Map<ID, CHL_Partner_Opportunity__c> syncPartOppMap, Map<ID, Opportunity> oppMap) {
		List<CHL_Partner_Opportunity__c> partnerOppQuoteList = new List<CHL_Partner_Opportunity__c>();
		copyFromMasterOppty(oppMap, syncPartOppMap.values());
	}
	
	private static List<CHL_Partner_Opportunity__c> copyFromMasterOppty(Map<ID, Opportunity> oppMap, List<CHL_Partner_Opportunity__c> partnerOpptyList){
		List <REN_Field_Mappings__c> fieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(CHL_Constants.FLD_MAP_PARTNER_OPPT_TO_MASTER_OPPT, CSM_Util.getNamespace() + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, REN_Constants.OBJ_OPPORTUNITY);
		List<CHL_Partner_Opportunity__c> partnerOpptyUpdatedList = new List<CHL_Partner_Opportunity__c>();
		List<CHL_Partner_Opportunity__c> partnerOpptyListToUpdateExpQtr = new List<CHL_Partner_Opportunity__c>();
		for (CHL_Partner_Opportunity__c obj: partnerOpptyList) {
			boolean isUpdateRequiredOnPO = false;
			if (obj.CHL_Syncing__c != null && obj.CHL_Syncing__c.contains(CHL_Constants.SYNCING_OPTION_FROM_MO)) {
				Opportunity oppObj = oppMap.get(obj.CHL_Opportunity__c);
				for (REN_Field_Mappings__c fieldMapping: fieldMappingList) {
					if (!REN_Constants.FLD_ISDELETED.equalsIgnoreCase(fieldMapping.REN_To_Field_API_Name__c)) {
						if((fieldMapping.REN_To_Field_API_Name__c).containsIgnoreCase('CHL_Expiration_Date__c') && obj.CHL_Expiration_Date__c != oppObj.REN_Earliest_Expiration_Date__c) {
							partnerOpptyListToUpdateExpQtr.add(obj);							
						}
						obj.put(fieldMapping.REN_To_Field_API_Name__c, oppObj.get(fieldMapping.REN_From_Field_API_Name__c));
						//system.debug('OUTSIDE OF IF');
						isUpdateRequiredOnPO = true;
					}
				}
			}
			if(isUpdateRequiredOnPO) {
				obj.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
				obj.CHL_Needs_Status_Update__c = false;
				partnerOpptyUpdatedList.add(obj);
			}
		}
		if(partnerOpptyListToUpdateExpQtr != null && !partnerOpptyListToUpdateExpQtr.isEmpty()) {
			REN_OpportunityDataAccess.calculateExpQuarterYear(partnerOpptyListToUpdateExpQtr, CSM_Util.getNamespace()+'CHL_Expiration_Date__c');
		}
		return partnerOpptyUpdatedList;
	}

	public static void syncToMasterOpty(List<CHL_Partner_Opportunity__c> newRecords) {
		List<String> oppIdList = new List<String>();
		List<CHL_Partner_Opportunity__c> partnerOppQuoteList  = new List<CHL_Partner_Opportunity__c>();
		List<Opportunity > syncedOpportunityList = new List<Opportunity>();
		system.debug('\n\n @@ syncToMasterOpty - newRecords :: ' + newRecords);
		if(!newRecords.isEmpty()){
			for (CHL_Partner_Opportunity__c objTo: newRecords) {
				if (objTo.CHL_Syncing__c != null && objTo.CHL_Syncing__c.contains(CHL_Constants.SYNCING_OPTION_TO_MO)) {
					oppIdList.add(objTo.CHL_Opportunity__c);
					partnerOppQuoteList.add(objTo);
				}
			}
		}
		Map<ID, Opportunity> oppMap = new Map <ID, Opportunity> (REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(oppIdList));
		List <REN_Field_Mappings__c> fieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(CHL_Constants.FLD_MAP_PARTNER_OPPT_TO_MASTER_OPPT, CSM_Util.getNamespace()+CHL_Constants.OBJ_PARTNER_OPPORTUNITY, REN_Constants.OBJ_OPPORTUNITY);
		for (CHL_Partner_Opportunity__c obj: partnerOppQuoteList) {
				Opportunity oppObj = oppMap.get(obj.CHL_Opportunity__c);
				for (REN_Field_Mappings__c fieldMapping: fieldMappingList) {
					if (!REN_Constants.FLD_ISDELETED.equalsIgnoreCase(fieldMapping.REN_To_Field_API_Name__c)) {
						oppObj.put(fieldMapping.REN_From_Field_API_Name__c, obj.get(fieldMapping.REN_To_Field_API_Name__c));
					}
				}
			
				syncedOpportunityList.add(oppObj);
		}
		if (!partnerOppQuoteList.isEmpty()) {
			ID jobID = System.enqueueJob(new CHL_QuoteSyncQueueableJob(partnerOppQuoteList));
		}

		if (!syncedOpportunityList.isEmpty()) {
			CHL_QuoteSyncHandler.isExecutionNeeded = false;
			REN_OpportunityDataAccess.updateOpportunityforRenewals(syncedOpportunityList);
		}	
	}	
}