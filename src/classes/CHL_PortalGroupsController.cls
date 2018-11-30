public with sharing class CHL_PortalGroupsController {
	public CHL_Portal_Group__c portalGroup {get; set;}
	public String helpParam {get; set;}
	public List<SelectOption> options {get; set;}
	public String selectedValue{get;set;}
	public String searchCriteria{get;set;}
	public boolean displaySearchRecs {get;set;}
	public boolean displayUserSearchRecs {get;set;}
	public List<CHL_PortalGroupWrapper> wrapPortalGroupList {get; set;}
    public List<CHL_Portal_Group_Member__c> portalGroupMemList {get;set;}
    public String deleteRec {get;set;}
    public List<CHL_PortalGroupCommonWrapper> finalListOfGroupMembers{get;set;}
    public String retURL {get; private set;}
    private String portalGroupId;
    private Set<Id> identifierIds;
    
    private Map<Id, Set<Id>> selectedHierarchyAccMap = new Map<Id, Set<Id>>();//US1162
    private  Set<Id> existingAccIdSet;
    
    public CHL_PortalGroupsController(ApexPages.StandardController stdController) {
    	options = new List<SelectOption>();
        options.add(new SelectOption('Accounts',System.label.CHL_GA_ACCOUNT_CATEGORY));
        options.add(new SelectOption('Partner Users',System.label.REN_LBL_PARTNER_USERS));
        displaySearchRecs = false;
        displayUserSearchRecs = false;
        finalListOfGroupMembers = new List<CHL_PortalGroupCommonWrapper>();
        portalGroupId = ApexPages.currentPage().getParameters().get('id');
        List<CHL_Portal_Group_Member__c> portalGroupMemberExistingList;
        if(String.isNotBlank(portalGroupId)) {
        	List<CHL_Portal_Group__C> portalGroupList = CHL_PortalGroupDataAccess.getPortalGroupById(new List<Id> {portalGroupId});
        	if(portalGroupList!=null && !portalGroupList.isEmpty()) {
        		portalGroup = portalGroupList[0];
        	}
        	portalGroupMemberExistingList = CHL_PortalGroupDataAccess.getPortalGroupMembers(portalGroupId);
        	if(portalGroupMemberExistingList!=null && !portalGroupMemberExistingList.isEmpty()) {
        		List<Id> accountIds = new List<Id>();
        		List<Id> userIds = new List<Id>();
        		for(CHL_Portal_Group_Member__c groupMember :portalGroupMemberExistingList) {
        			if(String.isNotBlank(groupMember.CHL_Partner_Account__c)) {
        				accountIds.add(groupMember.CHL_Partner_Account__c);
        			} else {
        				userIds.add(groupMember.CHL_Partner_User__c);
        			}
        		}
        		addToGroupMemberWrapper(accountIds,userIds);
        	}
        } else {
        	portalGroup = new CHL_Portal_Group__c();
        }
        retURL = ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL);
    }
    private void addToGroupMemberWrapper(List<Id> partnerAccountIds, List<Id> partnerUserIds) {
    	List<Account> partnerAccountList = CSM_AccountDataAccess.getAccountInformationById(partnerAccountIds);
       	List<User> partnerUserList = CHL_Util.getUserInformationById(partnerUserIds);
       	if(partnerAccountList != null && !partnerAccountList.isEmpty()) {
       		for(Account account :partnerAccountList) {
       			finalListOfGroupMembers.add(new CHL_PortalGroupCommonWrapper(account,null,'Partner Account',account.id));
       		}
       	}
       	if(partnerUserList != null && !partnerUserList.isEmpty()) {
       		for(User user :partnerUserList) {
       			finalListOfGroupMembers.add(new CHL_PortalGroupCommonWrapper(null,user,'Partner User',user.id));
       		}
       	}
    }
    public PageReference searchRecords() {
    	if(String.isNotBlank(selectedValue)) {
	    	if(String.isNotBlank(searchCriteria)) {
	    		Set<Id> idsToExclude = new Set<Id>();
	    		for(CHL_PortalGroupCommonWrapper finalListWrap:finalListOfGroupMembers) {
	    			if(finalListWrap.partnerAccount != null) {
	    				idsToExclude.add(finalListWrap.partnerAccount.id);
	    			} else if(finalListWrap.partnerUser != null) {
	    				idsToExclude.add(finalListWrap.partnerUser.id);
	    			}
	    		}
	    		if(selectedValue.equalsIgnoreCase('Accounts')) {
	    			List<Account> accountList = CSM_AccountDataAccess.getPartnerAccountByCriteria(searchCriteria,idsToExclude);
	    			if(accountList != null && !accountList.isEmpty()) {
	    				wrapPortalGroupList = new List<CHL_PortalGroupWrapper>();
		    			for(Account accnt :accountList) {
		    				wrapPortalGroupList.add(new CHL_PortalGroupWrapper(accnt,null));
		    			}
	    			} else {
	    				wrapPortalGroupList = new List<CHL_PortalGroupWrapper>();
	    			}
	    			displaySearchRecs = true;
	    			displayUserSearchRecs = false;
	    		} else {
	    			List<User> partnerUserList = CHL_Util.getPartnerUserByCriteria(searchCriteria,idsToExclude);
	    			if(partnerUserList != null && !partnerUserList.isEmpty()) {
	    				wrapPortalGroupList = new List<CHL_PortalGroupWrapper>();
		    			for(User user :partnerUserList) {
		    				wrapPortalGroupList.add(new CHL_PortalGroupWrapper(null,user));
		    			}
	    			} else {
	    				wrapPortalGroupList = new List<CHL_PortalGroupWrapper>();
	    			}
	    			displaySearchRecs = false;
	    			displayUserSearchRecs = true;
	    		}
	    	} else {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.PORTAL_GROUP_SEARCH_TXT_VAL_MSG));
	    	}
    	} else {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.PORTAL_GROUP_SEL_OBJ_MSG));
    	}
    	return null;
    }
    public PageReference addToGroup() {
    	List<Integer> toDelete = new List<Integer>();
    	if(wrapPortalGroupList != null && !wrapPortalGroupList.isEmpty()) {
	    	for(integer j=0;j<wrapPortalGroupList.size();j++) {
	    		if(wrapPortalGroupList[j].selected == true && wrapPortalGroupList[j].partnerAccount != null) {
	    			toDelete.add(j);
	    			finalListOfGroupMembers.add(new CHL_PortalGroupCommonWrapper(wrapPortalGroupList[j].partnerAccount,null,'Partner Account',wrapPortalGroupList[j].partnerAccount.id));
	    		} 
	    		if(wrapPortalGroupList[j].selected == true && wrapPortalGroupList[j].partnerUser != null) {
	    			toDelete.add(j);
	    			finalListOfGroupMembers.add(new CHL_PortalGroupCommonWrapper(null,wrapPortalGroupList[j].partnerUser,'Partner User',wrapPortalGroupList[j].partnerUser.id));
	    		}
	    	}
    	}
    	if(toDelete != null && !toDelete.isEmpty()) {
    		searchRecords();
    	} else {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.PORTAL_GROUP_ATLEAST_ONE_MEM_MSG));
    	}
    	return null;
    }
    
    public PageReference removeFromList() {
    	identifierIds = new Set<Id>();
    	if(String.isNotBlank(this.deleteRec)) {
	    	for(integer i=0;i<this.finalListOfGroupMembers.size();i++) {
	    		if(finalListOfGroupMembers[i].identifier.equals(this.deleteRec)) {
	 				identifierIds.add(finalListOfGroupMembers[i].identifier);
	    			this.finalListOfGroupMembers.remove(i);
		    			if(String.isNotBlank(selectedValue)) {
		    				if(String.isNotBlank(searchCriteria)) {
		    					searchRecords();
		    				}
		    			}
	    			break;
	    		}
	    	}
    	}
    	
    	return null;
    }
    
    public PageReference savePortalGroup() {
    	Set<Id> deletedUserIds = new Set<Id>();
		if(String.isBlank(portalGroup.Name)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.PORTAL_GROUP_NAME_VAL_MSG));
		} else {
			Savepoint sp = Database.setSavepoint();
			List<CHL_Portal_Group_Member__c> membersToDelete;
			try {
				if(finalListOfGroupMembers != null && !finalListOfGroupMembers.isEmpty()) {
						//Added for US1162
					Set<Id> accountToFetchHierarchy = getAccountIds(finalListOfGroupMembers, existingAccIdSet);
					Map<Id,Set<Id>> accountHierarchyMap = new Map<Id,Set<Id>>();
					if(portalGroup.CHL_Roll_Up_Hierarchy__c){
						if(accountToFetchHierarchy != null && !accountToFetchHierarchy.isEmpty()){
							accountHierarchyMap = CHL_Util.getAccountHierarchy(accountToFetchHierarchy, 90);
						}
					}
	
					if(portalGroup.CHL_Roll_Up_Hierarchy__c && accountHierarchyMap == null){
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.CHL_LBL_LIMIT_EXCEED_MSG));
						return null;
					} else {
						if(accountHierarchyMap  !=  null){
							selectedHierarchyAccMap.putAll(accountHierarchyMap);
						}
					}
					// End 
					system.debug('\n\n Check for Portal Group 1 :: ' + portalGroup);
					portalGroup = CHL_PortalGroupDataAccess.savePortalGroup(new List<CHL_Portal_Group__c> {portalGroup})[0];
					system.debug('\n\n Check for Portal Group 2 :: ' + portalGroup);
					if(!portalGroup.CHL_Roll_Up_Hierarchy__c) {
						Set<Id> userIdsToExclude = CHL_Util.getUsersByPortalGroupMembers(portalGroup.id);
			    		membersToDelete = CHL_PortalGroupDataAccess.getPortalGroupMembersHierarchy(new List<Id> {portalGroup.id},userIdsToExclude);
						if(membersToDelete!=null && !membersToDelete.isEmpty())
							for(CHL_Portal_Group_Member__c deletedMembers :membersToDelete) {
								if(String.isNotBlank(deletedMembers.CHL_Partner_User__c)) {
									deletedUserIds.add(deletedMembers.CHL_Partner_User__c);
								}
							}
						CHL_PortalGroupDataAccess.deletePortalGroupMembers(membersToDelete);
					}
					system.debug('\n\n Check for Portal Group 3 :: '+identifierIds);
					if(identifierIds!=null && !identifierIds.isEmpty()) {
						membersToDelete = CHL_PortalGroupDataAccess.getPortalGroupMembers(identifierIds,new Set<Id> {portalGroup.id});
						if(membersToDelete!=null && !membersToDelete.isEmpty())
						{
							for(CHL_Portal_Group_Member__c deletedMembers :membersToDelete) {
								if(String.isNotBlank(deletedMembers.CHL_Partner_User__c)) {
									deletedUserIds.add(deletedMembers.CHL_Partner_User__c);
								}
							}
							CHL_PortalGroupDataAccess.deletePortalGroupMembers(membersToDelete);
						}
					}
					portalGroupMemList = new List<CHL_Portal_Group_Member__c> ();
					CHL_Portal_Group_Member__c portalGroupMember;
					List<CHL_Portal_Group_Member__c> existingPortalGroupMember = CHL_PortalGroupDataAccess.getPortalGroupMembers(portalGroup.id);
					Boolean match = false;
					for(integer i=0;i<finalListOfGroupMembers.size();i++) {
						if(existingPortalGroupMember != null && !existingPortalGroupMember.isEmpty())
						{
							for(CHL_Portal_Group_Member__c existingGroupMembers :existingPortalGroupMember) {
								if(String.isNotBlank(existingGroupMembers.CHL_Partner_Account__c)) {
									if(existingGroupMembers.CHL_Partner_Account__c == finalListOfGroupMembers[i].identifier) {
										match = true;
										break;
									} else {
	
									}
								} else {
									if(existingGroupMembers.CHL_Partner_User__c == finalListOfGroupMembers[i].identifier){
										match = true;
										break;
									}
								}
							}
						} 
						if(!match) {
							portalGroupMember = new CHL_Portal_Group_Member__c();
							portalGroupMember.CHL_Portal_Group__c = portalGroup.id; 
							if(finalListOfGroupMembers[i].partnerAccount!=null) {
								portalGroupMember.CHL_Partner_Account__c = finalListOfGroupMembers[i].partnerAccount.id;
							} else if(finalListOfGroupMembers[i].partnerUser!=null) {
								portalGroupMember.CHL_Partner_User__c = finalListOfGroupMembers[i].partnerUser.id;
							}
							portalGroupMemList.add(portalGroupMember);
						} else {
							match = false;
						}
					}
					system.debug('portalGroupMemList :: '+portalGroupMemList+':::'+deletedUserIds);
					if(portalGroupMemList!=null && !portalGroupMemList.isEmpty()){
						portalGroupMemList = CHL_PortalGroupDataAccess.savePortalGroupMembers(portalGroupMemList);
						managePortalGroups(portalGroup, portalGroupMemList, selectedHierarchyAccMap, deletedUserIds);//US1162
					} else if(!deletedUserIds.isEmpty()) {
						List<Id> publicGroupIdList = getPublicGroupId(portalGroup);	
						// method for removing Portal group member from public group 
						if(publicGroupIdList != null && !publicGroupIdList.isEmpty() ){
							CHL_PortalGroupsController.managePublicGroups(publicGroupIdList[0], null, deletedUserIds);
						}
					}
					return cancel();
	
				} else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.PORTAL_GROUP_ATLEAST_ONE_MEM_MSG));
				}
			} catch(exception ex) {
				Database.rollback(sp);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			}
		}
	return null;
    }
    
    public PageReference cancel() {
    	PageReference pageRef;
    	if (portalGroup.id == null && retURL != null){ 
    		pageRef = new PageReference(retURL);
			pageRef.setRedirect(true);
    	}else if(portalGroup.id == null && retURL == null){ 
    		Schema.DescribeSObjectResult result = CHL_Portal_Group__c.SObjectType.getDescribe();
  			pageRef = new PageReference('/' + result.getKeyPrefix());
  			pageRef.setRedirect(true);
     	}else{ 
    		system.debug('New');
			pageRef = Page.chl_portalgroupsview;
	    	pageRef.getParameters().put('id',portalGroup.id);
	    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
	    	pageRef.setRedirect(true);
    	}
		return pageRef;
    }
    
    public PageReference clearWrapperList() {
    	wrapPortalGroupList = new List<CHL_PortalGroupWrapper>();
    	return null;
    }
    
	// ---- Start --- Added for US1162 
	
	@future
	public static void managePublicGroups(Id publicGroupId ,Set<Id> userIdToAdd, Set<Id> userIdToRemove){
		try{
			//Remove users from Public group
			List<Id> deletedUserIdList = new List<Id>();
			deletedUserIdList.addAll(userIdToRemove);
			
			if(deletedUserIdList  != null){
				CHL_PublicGroupDataAccess.removeGroupMembers(publicGroupId, deletedUserIdList);
			}
			
			//Add member in public group members
			if(userIdToAdd  != null){
				List<GroupMember> publicGroupMemberList = CHL_PublicGroupDataAccess.createGroupMember(publicGroupId, userIdToAdd);
			}
			
		}catch(Exception e){
			Set<Id> userIdSet = new Set<Id>{userInfo.getUserId()};
			REN_Util.sendEmailNotification(userIdSet, System.label.CHL_LBL_PUBLIC_GROUP_CREATION_FAILED_MAIL_SUBJECT, System.label.CHL_LBL_PUBLIC_GROUP_CREATION_FAILED_MAIL_TEXT+e.getMessage());
		}
	} 
	
	//Retrun set Of Account Ids for fetching the account hierarchy
	@TestVisible
	private Set<Id> getAccountIds(List<CHL_PortalGroupCommonWrapper> finalListOfGroupMembers, Set<Id> existingAccIdSet){
		Set<Id> allAccIdSet = new Set<Id>();
		Set<Id> accountToFetchHierarchy = new Set<Id>();
	    
	    if(finalListOfGroupMembers != null &&  !finalListOfGroupMembers.isEmpty()){
			for(CHL_PortalGroupCommonWrapper pGCommenWrapper:finalListOfGroupMembers){
				if(pGCommenWrapper.partnerAccount != null){
					allAccIdSet.add(pGCommenWrapper.partnerAccount.id);
				}
			}
	    }
		//To check the existing member 
		if(existingAccIdSet != null &&  !existingAccIdSet.isEmpty()){
			//For update
			for(Id accId :allAccIdSet ){
				if(!existingAccIdSet.contains(accId)){
					accountToFetchHierarchy.add(accId);
				}
			}
		} else {
			//For Insert 
			accountToFetchHierarchy.addAll(allAccIdSet);
		}
		return accountToFetchHierarchy;
	}

	private List<User> managePortalGroups(CHL_Portal_Group__c portalGroup,List<CHL_Portal_Group_Member__c> portalGroupMemberlist, Map<Id,Set<Id>> hierarchySetAccount, Set<Id> userIdToRemove){
		Set<Id> accountIdSet = new Set<Id>();
		Set<Id> userIdGroupSet;
		List<CHL_Portal_Group_Member__c> memeberListForPublicGroup;

		Map<Id,String> relatedToIdMap = new Map<Id,String>();
		List<CHL_Portal_Group_Member__c> portalMemberList = new List<CHL_Portal_Group_Member__c>();

		for(CHL_Portal_Group_Member__c pGMember : portalGroupMemberlist){
			if(pGMember.CHL_Partner_Account__c != null){
				relatedToIdMap.put(pGMember.CHL_Partner_Account__c, String.valueOF(pGMember.id));
			}
		}

		if(hierarchySetAccount != null){
			for(Id id :hierarchySetAccount.keySet() ){
				if(hierarchySetAccount.containsKey(id)){
					accountIdSet.addAll(hierarchySetAccount.get(id));
				}
			}
		}

		List<CHL_Portal_Group_Member__c> newGroupMemberList = new List<CHL_Portal_Group_Member__c>();

		//Insert Account obj
		for(id accoutId: accountIdSet){
			CHL_Portal_Group_Member__c newGroupMember = new CHL_Portal_Group_Member__c();
			newGroupMember.CHL_Partner_Account__c = accoutId;
			newGroupMember.CHL_Portal_Group__c = portalGroup.id;

			for(id AccoutnID :hierarchySetAccount.keySet()){
				Set<ID> parentAccount = hierarchySetAccount.get(AccoutnID);
				newGroupMember.CHL_Related_Group_Member__c = parentAccount.contains(accoutId) ? relatedToIdMap.get(AccoutnID) : null;
			}
			newGroupMemberList.add(newGroupMember);
		}

		//Added account from portal group to fetch users for the corresponding account
		if( hierarchySetAccount != null && !hierarchySetAccount.isEmpty() ){
			accountIdSet.addAll(hierarchySetAccount.keySet());
		} else {
			//if rollup hierarchy = false ,add Accout to get users
			for(CHL_Portal_Group_Member__c pGroupMemberObj : portalGroupMemberlist){
				if(pGroupMemberObj.CHL_Partner_Account__c != null){
					accountIdSet.add(pGroupMemberObj.CHL_Partner_Account__c);
				}
			}
		}

		createGroupMembers(accountIdSet, hierarchySetAccount, newGroupMemberList, relatedToIdMap);
		
		//Public group memberlist
		memeberListForPublicGroup =  new List<CHL_Portal_Group_Member__c>();
		//added already added member by portal
		memeberListForPublicGroup.addAll(portalGroupMemberlist);
		//added member by roll up hierarchy
		if(newGroupMemberList != null){
			memeberListForPublicGroup.addAll(newGroupMemberList);
		}
		//2. To fetch User Id from portal group member   
		Set<Id> userIdToAdd = new Set<Id>();
		for(CHL_Portal_Group_Member__c portalGrpMemberObj : memeberListForPublicGroup){
			if(portalGrpMemberObj.CHL_Partner_User__c != null){
				userIdToAdd.add(portalGrpMemberObj.CHL_Partner_User__c);
			}
		}

		List<Id> publicGroupIdList = getPublicGroupId(portalGroup);

		// method for adding Portal group member 
		if(publicGroupIdList != null && !publicGroupIdList.isEmpty() ){
			CHL_PortalGroupsController.managePublicGroups(publicGroupIdList[0], userIdToAdd, userIdToRemove);
		}
		return null;
	}

	private void createGroupMembers(Set<ID> accountIdSet, Map<Id,Set<Id>> hierarchySetAccount, List<CHL_Portal_Group_Member__c> newGroupMemberList, Map<Id,String> relatedToIdMap){
		if(test.isRunningTest()){
			List<User> userlistFromAccount = [select id from user where isActive = true limit 1];
		} else {
			List<User> userlistFromAccount = CHL_Util.getUserFromAccount(accountIdSet);
		}
		List<User> userlistFromAccount = CHL_Util.getUserFromAccount(accountIdSet);
		for(User usr : userlistFromAccount){
			if(hierarchySetAccount != null && !hierarchySetAccount.isEmpty() ){
				for(id AccoutnID :hierarchySetAccount.keySet() ){
					Set<ID> parentAccount = hierarchySetAccount.get(AccoutnID);
					if(parentAccount.contains(usr.AccountId) || usr.AccountId == AccoutnID){
						CHL_Portal_Group_Member__c newGroupMember = new CHL_Portal_Group_Member__c(
							CHL_Partner_User__c = usr.id,
							CHL_Portal_Group__c = portalGroup.id,
							CHL_Related_Group_Member__c = relatedToIdMap.get(AccoutnID)
						);
						newGroupMemberList.add(newGroupMember);
					}
				}
			} else {
				//rollup hierarchy  = false
				CHL_Portal_Group_Member__c newGroupMember = new CHL_Portal_Group_Member__c();
				newGroupMember.CHL_Partner_User__c = usr.id;
				newGroupMember.CHL_Portal_Group__c = portalGroup.id;
				newGroupMember.CHL_Related_Group_Member__c = relatedToIdMap.get(usr.AccountId);
				newGroupMemberList.add(newGroupMember);
			}
		}
		if(newGroupMemberList != null){
			CHL_PortalGroupDataAccess.savePortalGroupMembers(newGroupMemberList);
		}
		
	}
	
	@TestVisible
	private List<Id> getPublicGroupId(CHL_Portal_Group__c portalGroup){//To create public group 
		system.debug('\n\n Method getPublicGroupId :: ' + portalGroup);
		List<Group> publicGroupList ;
		if(String.isblank(portalGroup.CHL_Public_Group__c)){
			system.debug('\n\n Inside if check :: ' );
			//To create public group as per portal group name
			List<String> portalGroupNameList = new List<String>();
			portalGroupNameList.add(String.valueOF(portalGroup.name));
			system.debug('\n\n Before Public group creation :: ' );
			publicGroupList = CHL_PublicGroupDataAccess.createGroup(portalGroupNameList);
			system.debug('\n\n After Public group creation :: ' + publicGroupList);
			//To populate pulic group id in Portal group
			if(publicGroupList != null){
				portalGroup.CHL_Public_Group__c = publicGroupList[0].id;
				system.debug('\n\n Before portal group updation :: ' + portalGroup );
				CHL_PortalGroupDataAccess.savePortalGroup(new List<CHL_Portal_Group__c>{portalGroup});
				system.debug('\n\n After portal group updation :: ' + portalGroup);
			}
			system.debug('\n\n return 1 :: ' + portalGroup);
			return new List<Id>{publicGroupList[0].id};
		}
		else {
			system.debug('\n\n return 2 :: ' + portalGroup);
			return  new List<Id>{portalGroup.CHL_Public_Group__c};
		}
	}
	// ---- End --- Added for US1162 
	
	public class CHL_PortalGroupCommonWrapper {
    	public String identifier {get; set;}
        public Account partnerAccount {get; set;}
        public User partnerUser {get; set;}
        public String typeOfMember {get; set;}
        
        public CHL_PortalGroupCommonWrapper(Account partnerAccount, User partnerUser, String typeOfMember, String identifier) {
        	this.identifier = identifier;
            this.partnerAccount = partnerAccount;
            this.partnerUser = partnerUser;
            this.typeOfMember = typeOfMember;
        }
    }
    public class CHL_PortalGroupWrapper {
    	public Account partnerAccount {get; set;}
        public Boolean selected {get; set;}
        public User partnerUser {get;set;}
 		public CHL_PortalGroupWrapper(Account a,User u) {
            partnerAccount = a;
            partnerUser = u;
            selected = false;
        }
    }
}