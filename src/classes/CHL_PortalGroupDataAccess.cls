public with sharing class CHL_PortalGroupDataAccess {
    public static List<CHL_Portal_Group__c> savePortalGroup(List<CHL_Portal_Group__c> portalGroupList)
	{
	
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_DESC,
													CHL_CONSTANTS.OBJ_PORTAL_HIERAR};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
		
		upsert portalGroupList;

		return portalGroupList;
	}
	public static List<CHL_Portal_Group_Member__c> savePortalGroupMembers(List<CHL_Portal_Group_Member__c> portalGroupMemList)
	{
	
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_USER,
													CHL_CONSTANTS.OBJ_PORTAL_GROUP_REL_MEM
													};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
		
			upsert portalGroupMemList;

		return portalGroupMemList;
	}
	public static Boolean findPoralGroupByName(String portalName) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_DESC,
													CHL_CONSTANTS.OBJ_PO_NAME,
													CHL_CONSTANTS.OBJ_PORTAL_HIERAR};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<CHL_Portal_Group__c> portalGroupList = new List<CHL_Portal_Group__c>();
		
		portalGroupList = [SELECT Id,Name FROM CHL_Portal_Group__c WHERE Name = :portalName LIMIT 1];
		
		if(portalGroupList.size()>0) {
			return true;
		} else {
			return false;
		}
	}
	
	public static Set<String> getPortalGroupName(Set<String> pgNameSet) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_DESC,
													CHL_CONSTANTS.OBJ_PO_NAME,
													CHL_CONSTANTS.OBJ_PORTAL_HIERAR};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		List<CHL_Portal_Group__c> portalGroupList = new List<CHL_Portal_Group__c>();
		Set<String> portalGroupNames = new Set<String>();
		portalGroupList = [SELECT Id,Name FROM CHL_Portal_Group__c WHERE Name IN :pgNameSet LIMIT 10000];
		for(CHL_Portal_Group__c pgObj: portalGroupList) {
			portalGroupNames.add(pgObj.name);
		}
		return portalGroupNames;
	}
	
	public static List<Id> getPublicGroupIdByAccount(Set<Id> partnerAcc) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_DESC,
													CHL_CONSTANTS.OBJ_PO_NAME,
													CHL_CONSTANTS.OBJ_PORTAL_HIERAR,
													CHL_CONSTANTS.OBJ_PORTAL_GROUP_PUB_GRP_ID};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<String> fcFieldList1 = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_USER};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList1, CSM_Constants.DML_OPERATION_READ);
		
		List<Id> publicGroupIdList = new List<Id>();
		
		for (CHL_Portal_Group__c pGroup: [SELECT Id, CHL_Public_Group__c FROM CHL_Portal_Group__c 
							WHERE Id in (SELECT CHL_Portal_Group__c FROM CHL_Portal_Group_Member__c 
							WHERE CHL_Partner_Account__c IN :partnerAcc) 
							limit 1000]) {
								if(String.isNotBlank(pGroup.CHL_Public_Group__c)) {
									publicGroupIdList.add(pGroup.CHL_Public_Group__c);
								}
							}
		return publicGroupIdList;
	}
	public static List<CHL_Portal_Group_Member__c> getPortalGroupMembers(Id portalGroupId) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
													CHL_CONSTANTS.OBJ_PO_NAME,
													CHL_CONSTANTS.FL_ID,
													CHL_CONSTANTS.OBJ_PORTAL_GROUP_REL_MEM,
													CHL_CONSTANTS.CASE_CREATED_DATE,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_USER};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);

		return [select id,name,CHL_Partner_Account__c,CHL_Partner_User__c,CHL_Portal_Group__c,CHL_Related_Group_Member__c,CreatedDate,CHL_Partner_User__r.name from CHL_Portal_Group_Member__c
				where CHL_Portal_Group__c = :portalGroupId
				and CHL_Related_Group_Member__c = null 
				limit 1000];
	}
	public static void deletePortalGroupMembers(List<CHL_Portal_Group_Member__c> portalGroupMembers) {
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, null, CSM_Constants.DML_OPERATION_DELETE);

		delete portalGroupMembers;
		
	}
	public static List<CHL_Portal_Group__c> getPortalGroupById(List<Id> portalGroupId) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_DESC,
													CHL_CONSTANTS.OBJ_PO_NAME,
													CHL_CONSTANTS.OBJ_PORTAL_HIERAR,
													CHL_CONSTANTS.FL_ID,
													'LastModifiedById',
													CHL_CONSTANTS.OBJ_ATT_LAST_MODIFIED_DATE};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP, fcFieldList, CSM_Constants.DML_OPERATION_READ);

		return [SELECT Id,
					   Name,
					   CHL_Description__c,
					   CHL_Public_Group__c,	
					   CHL_Roll_Up_Hierarchy__c,
					   LastModifiedById,
					   LastModifiedDate
					   FROM CHL_Portal_Group__c 
					   WHERE Id IN :portalGroupId LIMIT 1];
	}
	public static List<CHL_Portal_Group_Member__c> getPortalGroupMembersHierarchy(List<Id> portalGroupId, Set<Id> userIdsToExclude) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_USER,
													CHL_CONSTANTS.FL_ID,
													CHL_CONSTANTS.OBJ_PO_NAME,
													CHL_CONSTANTS.OBJ_PORTAL_GROUP_REL_MEM,
													CHL_CONSTANTS.CASE_CREATED_DATE};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);

		return [select id,name,CHL_Partner_Account__c,CHL_Partner_User__c,CHL_Portal_Group__c,CHL_Related_Group_Member__c,CreatedDate,CHL_Partner_User__r.name from CHL_Portal_Group_Member__c
				where CHL_Portal_Group__c IN :portalGroupId 
				and CHL_Related_Group_Member__c != null
				and CHL_Partner_User__c NOT IN :userIdsToExclude limit 1000];
	}
	public static List<CHL_Portal_Group_Member__c> getPortalGroupMembers(Set<Id> identifierIds,Set<Id> portalGroupId) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_USER};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<CHL_Portal_Group_Member__c> portalGroupMembersList = new List<CHL_Portal_Group_Member__c>();
		
		portalGroupMembersList = [select id,name,CHL_Partner_Account__c,CHL_Partner_User__c,CHL_Portal_Group__c,CHL_Related_Group_Member__c,FORMAT(CreatedDate),CHL_Partner_User__r.name 
								from CHL_Portal_Group_Member__c
								where CHL_Portal_Group__c IN :portalGroupId 
								and (CHL_Partner_Account__c IN :identifierIds OR CHL_Partner_User__c IN :identifierIds) and CHL_Related_Group_Member__c = null limit 1000];
		Set<Id> portalGroupMembersIds = new Set<Id>();
		if(portalGroupMembersList!=null && !portalGroupMembersList.isEmpty()) {
			for(CHL_Portal_Group_Member__c portalGroupMember :portalGroupMembersList) {
				portalGroupMembersIds.add(portalGroupMember.id);
			}
		}
		List<CHL_Portal_Group_Member__c> hierarchyGroupMembersList = new List<CHL_Portal_Group_Member__c>();
		
		hierarchyGroupMembersList = [select id,name,CHL_Partner_Account__c,CHL_Partner_User__c,CHL_Portal_Group__c,CHL_Related_Group_Member__c,CreatedDate,CHL_Partner_User__r.name 
								from CHL_Portal_Group_Member__c
								where CHL_Related_Group_Member__c IN :portalGroupMembersIds];
								
		if(hierarchyGroupMembersList!=null && !hierarchyGroupMembersList.isEmpty()) {
			for(CHL_Portal_Group_Member__c portalGroupMember:hierarchyGroupMembersList) {
				portalGroupMembersList.add(portalGroupMember);
			}
		}
		return portalGroupMembersList;
	}
	
	public static List<CHL_Portal_Group_Member__c> getGrpMmberWithPblicGrp(List<Id> acclst) {
		List<String> fcFieldList = new List<String>{'CHL_Partner_Account__c','CHL_Portal_Group__c'};
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		return [Select id,CHL_Partner_Account__c,CHL_Portal_Group__r.CHL_Public_Group__c from CHL_Portal_Group_Member__c 
				where CHL_Partner_Account__c IN :acclst AND CHL_Portal_Group__r.CHL_Public_Group__c != null];
		
	}
	public static List<CHL_Portal_Group_Member__c> getAllPortalGroupMembers(Id portalGroupId) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
													CHL_CONSTANTS.OBJ_PORTAL_MEM_USER};
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);

		String soql = 'Select Id, ' +
							'CHL_Partner_User__c, CHL_Portal_Group__c,'+
							'CHL_Related_Group_Member__c,'+
							'FORMAT(CreatedDate),'+
							'CHL_Partner_User__r.Name,'+
							'CHL_Partner_User__r.AccountId,'+
							'CHL_Partner_User__r.Account.Name,'+
							'FORMAT(CHL_Partner_User__r.LastLoginDate) FROM CHL_Portal_Group_Member__c '+
						'WHERE CHL_Portal_Group__c = :portalGroupId AND CHL_Partner_User__c != Null LIMIT 1000';
		return database.Query(soql);
	}
}