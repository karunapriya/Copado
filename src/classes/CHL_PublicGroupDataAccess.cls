/**
* @description   CHL_PublicGroupDataAccess validates the user permission on the public group
*                records that are being queried for.             
*/
public without sharing class CHL_PublicGroupDataAccess {
	
	//Not added CRUD\FLS check for this method intentionally, As "Manage Users" permission is required for Read and Edit of public group.
	public static List<Group> createGroup(List<String> grpNamesList){
		//CSM_Util.checkCRUD_FLS('GroupMember', new List<String>{'Id'}, CSM_Constants.DML_OPERATION_INSERT);
		List<Group> groupList = new List<Group>();
		for(String grpName : grpNamesList){
			Group groupObj = new Group();
			groupObj.Name = grpName;
			groupList.add(groupObj);
		}
		if(groupList != null){
			upsert groupList;
		}
		return groupList;
	}
	
	//Not added CRUD\FLS check for this method intentionally, As "Manage Users" permission is required for Read and Edit of public group.
	public static List<GroupMember> createGroupMember(Id groupId, Set<Id> userIdSet){
    	//CSM_Util.checkCRUD_FLS('GroupMember', new List<String>{'Id'}, CSM_Constants.DML_OPERATION_INSERT);
		List<GroupMember> groupMemberList = new List<GroupMember>();
		for(Id  usrId : userIdSet){
			GroupMember newGroupMember=new GroupMember();
			newGroupMember.GroupId = groupId;
			newGroupMember.UserOrGroupId =  usrId;
			groupMemberList.add(newGroupMember);
		}
		upsert groupMemberList;
		return groupMemberList;
	}
	
	//Not added CRUD\FLS check for this method intentionally, As "Manage Users" permission is required for Read and Edit of public group.
	public static void removeGroupMembers(Id groupId, List<Id> userIdSetToRemove){
    	//CSM_Util.checkCRUD_FLS('GroupMember', new List<String>{'Id'}, CSM_Constants.DML_OPERATION_DELETE);
		List<GroupMember> groupMemberList = [select id from GroupMember where  UserOrGroupID in :userIdSetToRemove and GroupId =:groupId ];
		if(groupMemberList != null){
			if(Schema.sObjectType.GroupMember.isDeletable()){
				delete groupMemberList;
			}
		}
	}
	
	/* US2730 : This method is used to get map of UserRole Id and its corresponding group ids.*/
	public static Map<Id,Set<Id>> getGroupIdsForRoles(){
		 Map<Id,Set<Id>> roleGroupMap = new Map<Id,Set<Id>>();  
		 Set<Id> roleGroupIdsSet; 
		 List<Group> groupsList = [select id,relatedId,name from Group where relatedId != null];
		 if(groupsList != null && groupsList.size() > 0){
			 for(Group gr :groupsList){
	            if(roleGroupMap.containsKey(gr.relatedId)){
	                roleGroupIdsSet = roleGroupMap.get(gr.relatedId);
	                roleGroupIdsSet.add(gr.Id);
	                roleGroupMap.put(gr.relatedId,roleGroupIdsSet);               
	            }
	            else{
	                roleGroupIdsSet = new Set<Id>();
	                roleGroupIdsSet.add(gr.Id);
	            	roleGroupMap.put(gr.relatedId,roleGroupIdsSet);                
	            }
	         }  
		 }
        return roleGroupMap;     
	}
	
	/* US2730 : This method is used to get Group Ids shared to user based on User, Role and Public Group.*/
    public static Set<Id> getGroupIdsSharedToUser(Set<Id> userIds, Boolean isPartnerUser){
		Set<Id> groupIdsSet = new Set<Id>();
        
        if(!isPartnerUser){
        	Set<String> developerNames = new Set<String>{CSM_Constants.STR_ALL_INTERNAL_USERS};
            List<Group> groupList = CSM_FocusCategoryViewDataAccess.retrieveIdsForGroups(developerNames);
            Map<Id,Group> groupsMap = new Map<Id,Group>(groupList);
            groupIdsSet.addAll(groupsMap.keySet());		       
        }
			
	   	groupIdsSet.addAll(getGroupIds(userIds));
        Map<Id,Set<Id>> roleGroupMap = getGroupIdsForRoles();
	    Set<Id> userRoleIds = CSM_UserDataAccess.getUserRoleId(userIds);
        if(userRoleIds != null && userRoleIds.size() > 0){
	    	for(Id roleId : userRoleIds){
		        if(roleGroupMap.containsKey(roleId)){
		            groupIdsSet.addAll(roleGroupMap.get(roleId));   
		        }
	    	}   
	    }
	    groupIdsSet.addAll(getGroupIds(groupIdsSet)); 
	    return groupIdsSet;        
    }
    
    /* US2730 : This method is used to get Group Ids shared to user based on user ids or nested group ids.*/
	public static Set<Id> getGroupIds(Set<Id> ids){
     	Set<Id> groupIdsSet = new Set<Id>();
     	List<GroupMember> groupMembersList = [select Id,UserOrGroupId,GroupId from GroupMember where UserOrGroupId IN: ids];
     	if(groupMembersList != null && groupMembersList.size() > 0){
     		for(GroupMember gm : groupMembersList){
     			groupIdsSet.add(gm.groupId);
			}
		}
     	return groupIdsSet;
	}
	
}