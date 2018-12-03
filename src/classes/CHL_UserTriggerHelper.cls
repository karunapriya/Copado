public with sharing class CHL_UserTriggerHelper {
	
	/********************************
	addUserToPublicGroup : This method finds portal groups having same account as user,
						   user is then added to the public group associated with the portal groups
	****************/
	public static void addUserToPublicGroup(List<sObject> newRecords){
		List<ID> accLst = new List<ID>();
		Map<Id,Id> userAccMap = new Map<Id,Id>();
		Set<Id> userIds = (new Map<Id,SObject>(newRecords)).keySet();
		List<User>userLst;
		
		// Partner Community not enabled in Master org.
		if(!Test.isRunningTest()){
			userLst = CHL_Util.getChannelPartnerUsers(userIds);
			for(User userRec : userLst){
				acclst.add((Id)userRec.AccountId);
				userAccMap.put(userRec.AccountId,userRec.id);
			}
		}
		else{
			userLst = [Select id from User where id IN: userIds];
			List<Account> accTestLst = [Select id from Account where Name = 'Test Account' Limit 1];
			if(accTestLst != null && !accTestLst.isEmpty()){
				for(User userRec : userLst){
					acclst.add(accTestLst[0].id);
					userAccMap.put(accTestLst[0].id,userRec.id);
				}
			}
		}
		if(!acclst.isEmpty()){
			Map<ID,Set<Id>> acctPublicGrpMap = populateAcctPublicGrpMap(accLst);
			createGroupMembers(acctPublicGrpMap,userAccMap);
		}
	}
	
	/**************
	populateAcctPublicGrpMap : This function creates a map with accountid as key and set of public groups as value.
	                          Same account can be added to different portal groups, which can be associated with different public group
	***************/
	private static Map<ID,Set<Id>> populateAcctPublicGrpMap (List<ID> accLst){
		List<CHL_Portal_Group_Member__c> portalGrpMemberList = CHL_PortalGroupDataAccess.getGrpMmberWithPblicGrp(acclst);
		Set<ID> publicGroupSet = new Set<ID>();
		Set<ID> publicGroupMapSet;
		Map<ID,Set<Id>> acctPublicGrpMap = new Map<ID,Set<Id>>();
		for (CHL_Portal_Group_Member__c portalGrpMember : portalGrpMemberList){
			publicGroupSet.add(portalGrpMember.CHL_Portal_Group__r.CHL_Public_Group__c);
			if(acctPublicGrpMap.containsKey(portalGrpMember.CHL_Partner_Account__c)){
				publicGroupMapSet = acctPublicGrpMap.get(portalGrpMember.CHL_Partner_Account__c);
				publicGroupMapSet.add(portalGrpMember.CHL_Portal_Group__r.CHL_Public_Group__c);
				acctPublicGrpMap.put(portalGrpMember.CHL_Partner_Account__c,publicGroupMapSet);
			}
			else{
				acctPublicGrpMap.put(portalGrpMember.CHL_Partner_Account__c,new Set<ID>{portalGrpMember.CHL_Portal_Group__r.CHL_Public_Group__c});
			}
		}
		return acctPublicGrpMap;
	}
	
	/*************
	createGroupMembers : This method creates and inserts groupmembers.
	*************/
	private static void createGroupMembers(Map<ID,Set<Id>> acctPublicGrpMap, Map<Id,Id> userAccMap){
		List<GroupMember> grpMmberLst = new List<GroupMember>();
		for(Id acctId : acctPublicGrpMap.keyset()){
			Set<ID> pGrpSet = acctPublicGrpMap.get(acctId);
			for(Id publicGrpId: pGrpSet){
				GroupMember grpMember = new GroupMember();
				grpMember.GroupId = publicGrpId;
				grpMember.UserOrGroupId = userAccMap.get(acctId);
				grpMmberLst.add(grpMember);
			}
		}
		
		if(!grpMmberLst.isEmpty()){
			system.debug('grpMmberLst :'+grpMmberLst);
			insert grpMmberLst;
		}
	}
	/**************
	Share Partner Cases with partner users
	**************/
	public static void updatePartnerCaseSharing(List<sObject> newRecords) {
		if(CHL_Util.isOWDForCASEPrivate()) {
			Map<Id,Id> userAccMap = new Map<Id,Id>();
			Set<Id> accIdSet = new Set<Id>();
			Set<Id> userIds = (new Map<Id,SObject>(newRecords)).keySet();
			if(!Test.isRunningTest()){ 
				List<User> userLst = CHL_Util.getChannelPartnerUsers(userIds);
				for(User userRec : userLst){
					accIdSet.add((Id)userRec.AccountId);
					userAccMap.put(userRec.id, userRec.AccountId);
				}
			} else {
				List<User> userLst = [Select id from User where id IN: userIds];
				List<Account> accTestLst = [Select id from Account where Name = 'Test Account' Limit 1];
				if(accTestLst != null && !accTestLst.isEmpty()){
					for(User userRec : userLst){
						accIdSet.add(accTestLst[0].id);
						userAccMap.put(userRec.id, accTestLst[0].id);
					}
				}
			}
			List<Case> caseList = CSM_CaseDataAccess.retrieveCaseByUserAccount(accIdSet);
			Map<Id, Set<Id>> acc2CaseMap = new Map<Id, Set<Id>>();
			Set<Id> caseIdList;
			Id accountId;
			for(Case caseRec : caseList) {
				if(!Test.isRunningTest()) {
					accountId = caseRec.contact.AccountId;
				} else {
					accountId = caseRec.AccountId;
				}
				if(acc2CaseMap != null && !acc2CaseMap.isEmpty()) {
					if(acc2CaseMap.containsKey(accountId)) {
						caseIdList = new Set<Id>();
						caseIdList = acc2CaseMap.get(accountId);
						caseIdList.add(caseRec.id);
						acc2CaseMap.put(accountId, caseIdList);	
					} else {
						acc2CaseMap.put(accountId, new Set<Id>{caseRec.id});
					}
				} else {
					acc2CaseMap.put(accountId, new Set<Id>{caseRec.id});	
				}
			}
			String serializeAcc2Casemap = JSON.serialize(acc2CaseMap);
			system.debug('serialized::::'+serializeAcc2Casemap);
			insertCaseShareList(userAccMap, serializeAcc2Casemap);
		}
	}
	/***************
	Created this method in order to avoid Mixed DML Error
	***************/
	@future
	private static void insertCaseShareList(Map<Id,Id> userAccMap, String serializeAcc2Casemap) {
		List<SObject> caseShareList = new List<SObject>();
		Map<Id, Set<Id>> acc2CaseMap = (Map<Id, Set<Id>>)System.JSON.deserialize(serializeAcc2Casemap, Map<Id, Set<Id>>.class);
		system.debug('deserialized::::'+acc2CaseMap);
		for(ID userId : userAccMap.keySet()) {
			if(acc2CaseMap.containsKey(userAccMap.get(userId))) {
				Set<Id> caseList = acc2CaseMap.get(userAccMap.get(userId));
				for(Id caseRec : caseList) { 
					SObject caseShareObj = CSM_AccessController.newSObject(CHL_Constants.OBJ_CASE_SHARE);
					caseShareObj.put('CaseId', caseRec);
					caseShareObj.put('RowCause', 'Manual');
					caseShareObj.put('UserOrGroupId', userId);
					caseShareObj.put('CaseAccessLevel', 'Edit');
					caseShareList.add(caseShareObj);
				}
			}
		}
		CSM_CaseDataAccess.insertCaseShare(caseShareList);
	}
	
	/* This method is used to assign Permission Sets to newly Created users based on Persona Field on User Record.*/
	public static void assignPermissionSets(Set<Id> userIdsSet){		
		List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
		Map<String,Set<String>> personaToPermissionSetMap = getPersonaToPermissionSetSMap();
		List<User> usersList = CSM_UserDataAccess.getUsersListForUserLicense(userIdsSet);
		Map<String,Id> psNameToIdMap = getPermissionSetNameToIdMap(usersList,personaToPermissionSetMap);
		for(User userObj :usersList){
			Boolean isValidUser = getValidUser(userObj,personaToPermissionSetMap);
			if(isValidUser){
				for(String ps : personaToPermissionSetMap.get(userObj.CHL_Persona__c)){
					if(psNameToIdMap.containsKey(ps)){
						PermissionSetAssignment psaRecord = new PermissionSetAssignment(AssigneeId = userObj.id, PermissionSetId = psNameToIdMap.get(ps));
						psAssignmentList.add(psaRecord);
					}
				}
			}
		}
		if(psAssignmentList != null && !psAssignmentList.isEmpty()){
			insert psAssignmentList;
		}
	}
	
	/* This method is used to get map of Permission Set Name to Id Map.*/
	private static Map<String,Id> getPermissionSetNameToIdMap(List<User> usersList, Map<String,Set<String>> personaToPermissionSetMap){
		Set<String> permissionSetsSet = new Set<String>();
		Map<String,Id> psNameToIdMap = new Map<String,Id>();
		for(User userObj :usersList){
			if(personaToPermissionSetMap.containsKey(userObj.CHL_Persona__c)){
				permissionSetsSet.addAll(personaToPermissionSetMap.get(userObj.CHL_Persona__c));
			}
		}
		List<PermissionSet> permissionSetsList = [Select Id,Name from PermissionSet where Name IN:permissionSetsSet];
		if(permissionSetsList != null && !permissionSetsList.isEmpty()){
			for(PermissionSet psObj : permissionSetsList){
				psNameToIdMap.put(psObj.Name, psObj.Id);
			}
		}
		return psNameToIdMap;	
	}
	
	/* This method is used to get map of Persona and Permission Sets.*/
	private static Map<String,Set<String>> getPersonaToPermissionSetSMap(){
		Map<String,Set<String>> personaToPermissionSetMap = new Map<String,Set<String>>();
		personaToPermissionSetMap.put('Sales Rep', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Sales_Rep_Restrictions'});
		personaToPermissionSetMap.put('Sales Manager', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Sales_Manager','PRISM_Sales_Manager_Restrictions','PRISM_Servicesource_Setup_Tab','PRISM_Create_Reports_Dashboards','PRISM_Manage_List_Views','PRISM_Manage_Focus_Categories','Prism_Mass_Update_Opportunities'});
		personaToPermissionSetMap.put('Ops Rep', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Ops','PRISM_Ops_Rep_Restrictions'});
		personaToPermissionSetMap.put('Ops Manager', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Ops','PRISM_Ops_Manager','PRISM_Ops_Manager_Restrictions','PRISM_Servicesource_Setup_Tab','PRISM_Create_Reports_Dashboards','PRISM_Manage_List_Views','PRISM_Manage_Focus_Categories','PRISM_Create_Opportunity','Prism_Mass_Update_Opportunities'});
		personaToPermissionSetMap.put('Channel Community User', new Set<String>{'PRISM_Channel_Community','PRISM_API_Enabled','PRISM_Base_Quote','PRISM_Base_Entitlement'});
		personaToPermissionSetMap.put('Business Intelligence Analyst', new Set<String>{'PRISM_Read_Only','PRISM_Read_Only_Extensions','PRISM_Read_Only_Quote','PRISM_Read_Only_Entitlement','PRISM_Create_Reports_Dashboards'});
		personaToPermissionSetMap.put('EDW Integration User', new Set<String>{'PRISM_Read_Only','PRISM_Read_Only_Extensions','PRISM_Read_Only_Quote','PRISM_Read_Only_Entitlement','PRISM_API_Only_User','PRISM_API_Enabled'});
		personaToPermissionSetMap.put('Data Services', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Data_Services','PRISM_Data_Services_Permissions','PRISM_API_Enabled','PRISM_Servicesource_Setup_Tab','PRISM_View_Setup','PRISM_View_All_Users','PRISM_Customize_Application','PRISM_RLI_Delete','PRISM_View_All_Data'});
		personaToPermissionSetMap.put('DS Integration User', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Data_Services','PRISM_Data_Services_Permissions','PRISM_API_Enabled','PRISM_API_Only_User','PRISM_Modify_All_Data','PRISM_RLI_Delete','PRISM_View_All_Users'});
		personaToPermissionSetMap.put('LT Integration User', new Set<String>{'PRISM_LT_Integration','PRISM_Servicesource_Setup_Tab','PRISM_Base_Quote','PRISM_API_Enabled'});
		personaToPermissionSetMap.put('Business Analyst', new Set<String>{'PRISM_Business_Analyst','PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Modify_All_Data','PRISM_Customize_Application','PRISM_Servicesource_Setup_Tab','PRISM_Assign_Permission_Sets','PRISM_Manage_Profiles_Permission_Sets','PRISM_Manage_List_Views','PRISM_View_Setup','PRISM_Manage_Focus_Categories','PRISM_Play_Maker','PRISM_Create_Opportunity','PRISM_Create_Reports_Dashboards'});
		personaToPermissionSetMap.put('Admin', new Set<String>{'PRISM_Servicesource_Setup_Tab','PRISM_System_Admin','PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Manage_Focus_Categories','PRISM_Play_Maker','PRISM_Create_Opportunity','PRISM_Edit_Delete_OLI'});
		personaToPermissionSetMap.put('Inside Sales Rep', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Sales_Rep_Restrictions','PRISM_Create_Opportunity'});
		personaToPermissionSetMap.put('Inside Sales Manager', new Set<String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Sales_Manager','PRISM_Sales_Manager_Restrictions','PRISM_Servicesource_Setup_Tab','PRISM_Create_Reports_Dashboards','PRISM_Manage_List_Views','PRISM_Create_Opportunity'});
		return personaToPermissionSetMap;
	}
	
	/* This method is used to check criteria for Valid User. */
	private static Boolean getValidUser(User userObj, Map<String,Set<String>> personaToPermissionSetMap){
		Boolean isValidUser = false;
		if((userObj.Profile.UserLicense.Name == CHL_Constants.PARTNER_LICENSE 
			|| userObj.Profile.UserLicense.Name == CHL_Constants.PARTNER_COMMUNITY_LOGIN_LICENSE  
			|| userObj.Profile.UserLicense.Name == CHL_Constants.SALESFORCE_LICENSE )
			&& personaToPermissionSetMap.containsKey(userObj.CHL_Persona__c)){
			isValidUser = true;
		}
		return isValidUser;
	}
	
	@future
	public static void updateUserContact(String userRecordsString){
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        
		if(CSM_AccessController.hasField('Contact', solnExtnNamespace + 'System_User_Reference__c') && String.isNotBlank(userRecordsString)){
			List<sObject> newRecords = (List<sObject>)JSON.deserialize(userRecordsString, List<Sobject>.class);
			
			List<User> newUserList = (List<User>)newRecords;
		
			Map<Id, Id> contactIdToUserIdMap = new Map<Id, Id>();
			
			for(User userObj : newUserList){
				if(userObj.ContactId != null){
					contactIdToUserIdMap.put(userObj.ContactId,userObj.Id);
				}
			}
			
			if(!contactIdToUserIdMap.isEmpty()){
				List<Contact> ContactList = CSM_ContactDataAccess.getContactsById(contactIdToUserIdMap.keySet());
				
                if(ContactList != null && !ContactList.isEmpty()){
                    
                    List<sObject> updateContactList = (List<sObject>)ContactList;
                    
                    for(sObject conObj : updateContactList){
                        if(contactIdToUserIdMap.containsKey(conObj.Id)){
                            conObj.put(solnExtnNamespace + 'System_User_Reference__c', contactIdToUserIdMap.get(conObj.Id));
                        }
                    }
                    
                    CSM_ContactDataAccess.updateContact(updateContactList,new List<String>{solnExtnNamespace + 'System_User_Reference__c'});
                }
			}
		}
			
	}
	
}