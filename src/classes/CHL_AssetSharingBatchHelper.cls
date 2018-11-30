/**
 * Created Date		: Oct 6, 2017
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - Helper class for Asset sharing batch, which have all the methods to share asset with partner users/groups.
 * Support Email 	: tanvi@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *_____________________________________________________________________________________________________________________________________
 *
 * Tanvi					US2765				Oct 6, 2017			1.1					Helper class for Asset sharing batch
 *
 */
public with sharing class CHL_AssetSharingBatchHelper {
	
	/**
	* Description : Method to fetch partner users based on partner accounts. It returns Map of Partner account with its corresponding users.
	**/
	public static Map<Id, Set<Id>> fetchPartnerAccountUsers(Set<Id> partnerAccIds)	{
		Map<Id, Set<Id>> partnerAccToUsersNGrp = new Map<Id, Set<Id>>();
		Set<Id> pUserIds; 
		for(User u:[SELECT id,Contact.AccountId FROM User WHERE Contact.AccountId in:partnerAccIds AND isActive=true]) {
        	//partnerUserIds.add(u.id);
			pUserIds = partnerAccToUsersNGrp.get(u.Contact.AccountId);
			if(pUserIds == null) {
				pUserIds = new Set<Id>();
			}					
			pUserIds.add(u.Id);
			partnerAccToUsersNGrp.put(u.Contact.AccountId, pUserIds);
        }   
        	            
        for(CHL_Portal_Group_Member__c pgm:[SELECT CHL_Portal_Group__c,CHL_Portal_Group__r.CHL_Public_Group__c,CHL_Partner_Account__c 
        												FROM CHL_Portal_Group_Member__c WHERE 
        												CHL_Partner_Account__c IN :partnerAccIds AND 
        												CHL_Portal_Group__r.CHL_Public_Group__c != null]){
        	pUserIds = partnerAccToUsersNGrp.get(pgm.CHL_Partner_Account__c);
			if(pUserIds == null) {
				pUserIds = new Set<Id>();
			}					
			pUserIds.add(pgm.CHL_Portal_Group__r.CHL_Public_Group__c);
			partnerAccToUsersNGrp.put(pgm.CHL_Partner_Account__c, pUserIds);													
		
		}
		return partnerAccToUsersNGrp;
	}	
	
	/**
	* Description : Method to fetch asset share users which returns Map of assetId with Set of users or groupId
	**/
	public static Map<Id, Set<Id>> fetchAssetShareUsers(List<sObject> assetShare)	{
		Map<Id, Set<Id>> assetShareUserMap = new Map<Id, Set<Id>>();
		for(sObject assshare: assetShare) {						
			Set<Id> assetUsers = assetShareUserMap.get((Id)assshare.get('AssetId'));							
			if(assetUsers == null){
				assetUsers = new Set<Id>();
			}
			assetUsers.add((Id)assshare.get('UserOrGroupId'));
			assetShareUserMap.put((Id)assshare.get('AssetId'), assetUsers);						
		}
		return assetShareUserMap;
	}	
	
	/**
	* Description : Method to construct Map of AssetId with partner users/groups based on 2 maps (1. asset with partner account Map and 2. Map of Partner account with corresponding partner users/groups.)
	**/
	public static Map<Id, Set<Id>> constructAssetToUserMap(Map<Id, Set<Id>>assetToPartnerAccountMap, Map<Id, Set<Id>> partnerAccToUsersNGrp)	{
		Map<Id, Set<Id>> assetToUserMap = new Map<Id, Set<Id>>();
		for(Id assetId:assetToPartnerAccountMap.keyset()) {
			if(assetToPartnerAccountMap.get(assetId) != null) {
				for(Id pAccId:assetToPartnerAccountMap.get(assetId)) {
					if(partnerAccToUsersNGrp.get(pAccId) != null) {
						for(Id userNGrpForAsset: partnerAccToUsersNGrp.get(pAccId))	{
							Set<Id> assetUsers = assetToUserMap.get(assetId);
							if(assetUsers == null){
								assetUsers = new Set<Id>();
							}
							assetUsers.add(userNGrpForAsset);
							assetToUserMap.put(assetId, assetUsers);
						}
					}
				}
			}
		}		
		return assetToUserMap;
	}
	
	/**
	* Description : Method to insert records in Assetshare based on above Map which is returned from constructAssetToUserMap()
	**/
	public static void insertUsersInAssetShare(Map<Id, Set<Id>> assetShareUsersToInsert )	{
		List<SObject> assetShareListToInsert = new List<SObject>();	
		for(Id assetId: assetShareUsersToInsert.keyset()) {
			for(Id userIdForInsert:assetShareUsersToInsert.get(assetId))	{
				SObject assetShareObj = Schema.getGlobalDescribe().get('AssetShare').newSObject();
        		assetShareObj.put('UserOrGroupId' , userIdForInsert) ;                
                assetShareObj.put('RowCause', 'Manual') ; 
                assetShareObj.put('AssetId' , assetId) ;
                assetShareObj.put('AssetAccessLevel' , 'Edit') ; 
                assetShareListToInsert.add(assetShareObj);
        	}
		}
		if(assetShareListToInsert != null && !assetShareListToInsert.isEmpty()) {
			Database.insert(assetShareListToInsert, false);
		}
	}
	
	/**
	* Description : Method to construct Map of AssetId and users/group Id those do not require access to that asset. 
	**/
	public static Map<Id, Set<Id>> getUnwantedUsersFromAssetShare(Map<Id, Set<Id>> assetShareToNewUsers, Set<Id> assetIds) {
		Map<Id, Set<Id>> assetToUsersToDelete = new Map<Id, Set<Id>>();
		String assetShareReason = 'Manual';
		String queryString = 'SELECT AssetAccessLevel,AssetId,Id,RowCause,UserOrGroupId FROM AssetShare WHERE RowCause =:assetShareReason AND AssetId IN :assetIds limit 10000';
    	List<SObject> assetShareList = Database.query(queryString); 
    	Map<Id, Set<Id>> assetShareToUsers = fetchAssetShareUsers(assetShareList);
		for(Id assetId :assetIds)	{
			Set<Id> assetUsers = assetShareToUsers.get(assetId);
			if(assetUsers != null) {
				Set<Id> insertedUsers = assetShareToNewUsers.get(assetId);
				for(Id userToDelete:assetUsers)	{					
					Set<Id> usersToDelete = assetToUsersToDelete.get(assetId);							
					if(usersToDelete == null){
						usersToDelete = new Set<Id>();
					}
					if(insertedUsers!= null && !insertedUsers.contains(userToDelete) && assetShareToNewUsers.containskey(assetId)) {  
						usersToDelete.add(userToDelete);
						assetToUsersToDelete.put(assetId,usersToDelete);
					} else if(!assetShareToNewUsers.containskey(assetId)) {
						usersToDelete.add(userToDelete);
						assetToUsersToDelete.put(assetId,usersToDelete);
					}					
				}
			}
		}
		return assetToUsersToDelete;
	}
	
	/**
	* Description : Delete records from AssetShare based on Map which got construct in getUnwantedUsersFromAssetShare() 
	**/
	public static void deleteUsersFromAssetShare(Map<Id, Set<Id>> assetShareUsersToDelete , Set<Id> assetIds)	{
		Set<Id> assetIdsToDelete = assetShareUsersToDelete.KeySet();
		String userTypeStr =  'PowerPartner';
		String assetShareReason = 'Manual';
		String queryStr = 'SELECT AssetAccessLevel,AssetId,Id,RowCause,UserOrGroupId FROM AssetShare WHERE RowCause =:assetShareReason AND AssetId IN :assetIds  limit 10000'; //AND UserOrGroupId in ( select Id from user where usertype =: userTypeStr )
		List<SObject> assetShareUsersList = Database.query(queryStr);  		            
		List<SObject> assetShareListToDelete = new List<SObject>();
		if(assetShareUsersList != null && !assetShareUsersList.isEmpty())	{
			for(SObject sObj:assetShareUsersList)	{
				Set<Id> usersToDelete = assetShareUsersToDelete.get((Id)sobj.get('AssetId'));
				if(assetShareUsersToDelete.containsKey((Id)sobj.get('AssetId')) && usersToDelete.contains((Id)sobj.get('UserOrGroupId')))	{
					assetShareListToDelete.add(sObj);
				}
			}
		}
		if(assetShareListToDelete != null && !assetShareListToDelete.isEmpty())	{
			if(CSM_AccessController.hasObject('AssetShare')) {
				Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
				Schema.DescribeSObjectResult res = globalDescribe.get('AssetShare').getDescribe();
				if(res.isDeletable()) {
					delete assetShareListToDelete;
				}
			}
		}
	}
    
}