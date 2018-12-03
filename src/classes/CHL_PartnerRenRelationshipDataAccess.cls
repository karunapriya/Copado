/**
* @description    CHL_PartnerRenRelationshipDataAccess validates the user permission on the partner renewal relationship records that are being queried for.             
*/
public with sharing class CHL_PartnerRenRelationshipDataAccess {

	public static List<SObject> getPartnerRenRealtionshipListFromFieldSet(Id partnerOppID){
		List<SObject> pRenRelationshipList1 = new List<SObject>();
		String queryString = '';
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP, new List<String>{CHL_Constants.OBJ_PARTNER_REN_REL_FLD}, CSM_Constants.DML_OPERATION_READ);
		queryString = CHL_Util.getQueryStringFromFieldSet(CSM_Util.getNamespace() + CHL_Constants.PARTNER_RENEWAL_RELATIONSHIP_FIELDSET_NAME, CSM_Util.getNamespace() + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP);
		queryString = queryString +' where ' +CSM_Util.getNamespace() + 'CHL_Partner_Opportunity__c =:partnerOppID Limit 10000';
		system.debug('\n\n queryString in RenRelationship --- :: ' + queryString);
		pRenRelationshipList1 = Database.query(queryString);
		return pRenRelationshipList1;
	}
	
	public static void insertPartnerRenRealtionship(List<CHL_Partner_Renewal_Relationship__c> partnerRenRelList) {
		List<String> pRenRelationshipList = new List<String>{CHL_Constants.OBJ_PARTNER_REN_REL_FLD,CHL_Constants.OBJ_PT_OPPORTUNITY};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,pRenRelationshipList, CSM_Constants.DML_OPERATION_INSERT);
		insert partnerRenRelList;
	}
	
	public static void deletePartnerRenRelationship (List<CHL_Partner_Renewal_Relationship__c> partnerRenRelList){
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,null, CSM_Constants.DML_OPERATION_DELETE);
		delete partnerRenRelList;
	}
	public static List<CHL_Partner_Renewal_Relationship__c> getPrtnrRenRelFromRenRel (List<String>fldLst,List<REN_Renews_To__c> renRelList){
		return getPrtnrRenRelFromRenRel(fldLst,renRelList,false);
	}
	
	public static List<CHL_Partner_Renewal_Relationship__c> getPrtnrRenRelFromRenRel (List<String>fldLst,List<REN_Renews_To__c> renRelList,Boolean isDeleteTrigger){
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,fldLst, CSM_Constants.DML_OPERATION_READ);
		List<CHL_Partner_Renewal_Relationship__c> partnerRenRelList = new List<CHL_Partner_Renewal_Relationship__c>();
		if(isDeleteTrigger) {
			partnerRenRelList = [Select id,Name, CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c,CHL_Renewal_Relationship__r.REN_Renewal_Target_Multiplier__c,CHL_Renewal_Relationship__r.REN_Previous_Price__c from CHL_Partner_Renewal_Relationship__c where CHL_Renewal_Relationship__c IN :renRelList ALL ROWS];
		} else {
			partnerRenRelList = [Select id,Name, CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c,CHL_Renewal_Relationship__r.REN_Renewal_Target_Multiplier__c,CHL_Renewal_Relationship__r.REN_Previous_Price__c from CHL_Partner_Renewal_Relationship__c where CHL_Renewal_Relationship__c IN :renRelList];
		}
		return partnerRenRelList;
	}

	public static List<SObject> getPartnerRenRealtionshipListByRLI(set<Id> rliIdSet, integer queryLimit) {
		List<SObject> pRenewalRelationshipList = new List<SObject>();
		String queryString = '';
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP, new List<String>{CHL_Constants.OBJ_PARTNER_REN_REL_FLD}, CSM_Constants.DML_OPERATION_READ);
		queryString = CHL_Util.getQueryStringFromFieldSet(CSM_Util.getNamespace() + CHL_Constants.PARTNER_RENEWAL_RELATIONSHIP_FIELDSET_NAME, CSM_Util.getNamespace() + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP);
		queryString = queryString +' where ' + CSM_Util.getNamespace() + 'CHL_Renewal_Relationship__c =: rliIdSet Limit '+queryLimit;
		system.debug('\n\n queryString in RenRelationship --- :: ' + queryString);
		pRenewalRelationshipList = Database.query(queryString);
		return pRenewalRelationshipList;
	}
	
	
	public static List<CHL_Partner_Renewal_Relationship__c> getPartnerRenRelById(List<String>fldLst,Set<Id>prrIdset,boolean isDeleteTrigger){
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,fldLst, CSM_Constants.DML_OPERATION_READ);
		List<CHL_Partner_Renewal_Relationship__c> partnerRenRelList = new List<CHL_Partner_Renewal_Relationship__c>();
		if(isDeleteTrigger) {
			partnerRenRelList = [Select id,Name, CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c from CHL_Partner_Renewal_Relationship__c where Id IN:prrIdset ALL ROWS];
		} else {
			partnerRenRelList = [Select id,Name, CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c from CHL_Partner_Renewal_Relationship__c where Id IN:prrIdset];
		}
		return partnerRenRelList;
	}
	
	public static List<CHL_Partner_Renewal_Relationship__c> getPartnerRenRelByPartnerOpty(List<String>fldLst,Set<Id>poIdset){
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,fldLst, CSM_Constants.DML_OPERATION_READ);
		/*List<CHL_Partner_Renewal_Relationship__c> partnerRenRelList = new List<CHL_Partner_Renewal_Relationship__c>();
		if(isDeleteTrigger) {
			partnerRenRelList = [Select id,Name, CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c,CHL_Partner_Opportunity__r.CHL_Renewal_Target_Amount__c,CHL_Partner_Opportunity__r.CHL_Renewal_Target_Won__c from CHL_Partner_Renewal_Relationship__c where Id IN:prrIdset ALL ROWS];
		} else {
			partnerRenRelList = [Select id,Name, CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c,CHL_Partner_Opportunity__r.CHL_Renewal_Target_Amount__c,CHL_Partner_Opportunity__r.CHL_Renewal_Target_Won__c from CHL_Partner_Renewal_Relationship__c where Id IN:prrIdset];
		}*/
		return [Select id,Name,CHL_Incumbent__c,CHL_Partner_Opportunity__c,CHL_Partner_Opportunity__r.CHL_Incumbent__c,CHL_Renewal_Relationship__c,CHL_Renewal_Relationship__r.REN_Renewal_Target__c,CHL_Renewal_Relationship__r.REN_Renewal_Status__c,CHL_Renewal_Relationship__r.REN_Renewal_Target_Multiplier__c,CHL_Renewal_Relationship__r.REN_Previous_Price__c from CHL_Partner_Renewal_Relationship__c where CHL_Partner_Opportunity__c IN:poIdset];
	}
	
	public static List<CHL_Partner_Renewal_Relationship__c> getPRRByPartnerOpty(List<String>fldLst,Set<Id>poIdset, Set<Id> rlisIdSet){
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,fldLst, CSM_Constants.DML_OPERATION_READ);
		
		return [Select CHL_Partner_Opportunity__c, CHL_Renewal_Relationship__c,CHL_Incumbent__c from CHL_Partner_Renewal_Relationship__c where CHL_Partner_Opportunity__c IN:poIdset and CHL_Renewal_Relationship__c IN: rlisIdSet];
	}
	public static void upsertPartnerRenRealtionship(List<CHL_Partner_Renewal_Relationship__c> partnerRenRelList) {
		List<String> pRenRelationshipList = new List<String>{CHL_Constants.OBJ_PARTNER_REN_REL_FLD,CHL_Constants.OBJ_PT_OPPORTUNITY};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,pRenRelationshipList, CSM_Constants.DML_OPERATION_UPSERT);
		upsert partnerRenRelList;
	}
	
	public static Map<Id, List<CHL_Partner_Renewal_Relationship__c>> getPO2PRRMap(Set<Id> poIdsSet) {
		Map<Id, List<CHL_Partner_Renewal_Relationship__c>> targetPO2PRRMap = new Map<Id, List<CHL_Partner_Renewal_Relationship__c>>();
		List<String> pRenRelationshipList = new List<String>{CHL_Constants.OBJ_PARTNER_REN_REL_FLD,CHL_Constants.OBJ_PT_OPPORTUNITY, 'CHL_Incumbent__c'};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP,pRenRelationshipList, CSM_Constants.DML_OPERATION_READ);
		List<CHL_Partner_Renewal_Relationship__c> pRRList = [select CHL_Renewal_Relationship__c, CHL_Partner_Opportunity__c,CHL_Incumbent__c from CHL_Partner_Renewal_Relationship__c
																where CHL_Partner_Opportunity__c IN :poIdsSet];
		for(CHL_Partner_Renewal_Relationship__c prr : pRRList) {
			List<CHL_Partner_Renewal_Relationship__c> prrListToAdd = new List<CHL_Partner_Renewal_Relationship__c>();
			if(targetPO2PRRMap.containsKey(prr.CHL_Partner_Opportunity__c)) {
				prrListToAdd = targetPO2PRRMap.get(prr.CHL_Partner_Opportunity__c);
			}
			prrListToAdd.add(prr);
			targetPO2PRRMap.put(prr.CHL_Partner_Opportunity__c, prrListToAdd);
		}	
		return targetPO2PRRMap;
	}
}