@isTest
private class CHL_PortalGroupsControllerTest {

	@testSetup 
	static void setUp() {
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

		//To create account hierarchy
		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		Account acc1 =  CHL_TestUtility.partnerAccount();
		accountList.add(acc1);
		Account accChild =  CHL_TestUtility.partnerAccount();
		accountList.add(accChild);
		insert accountList;

		accountList[0].ParentId = accountList[1].id;
		update  accountList[0];
		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		insert contactList;

		User userRecord = CSM_TestDataUtility.createTestUser('Standard User');
		 insert new SS_License__c(Channel__c = true);
		CHL_Portal_Group__c portalGroup = new CHL_Portal_Group__c();
		portalGroup.Name = 'TestPortalGroup111';
		insert portalGroup;

		List<CHL_Portal_Group_Member__c> portalGroupMemberList = new List<CHL_Portal_Group_Member__c>();
		for(Account account :accountList) {
			CHL_Portal_Group_Member__c portalGroupMember = new CHL_Portal_Group_Member__c();
			portalGroupMember.CHL_Partner_Account__c = account.id;
			portalGroupMember.CHL_Portal_Group__c = portalGroup.id;
			portalGroupMemberList.add(portalGroupMember);
		}
		insert portalGroupMemberList;
	}
	
	static testMethod void CHL_PortalGroupsController_Positive() {
		List<CHL_Portal_Group__c> portalGroup = [select id from CHL_Portal_Group__c];
		PageReference pageRef = Page.CHL_PortalGroups;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(CSM_Constants.ID_PARAM,portalGroup[0].id);
		pageRef.getParameters().put(CSM_Constants.RET_TO_URL,'/apex/chl_portalgroupsview');
		ApexPages.StandardController sc = new ApexPages.StandardController(new CHL_Portal_Group__c());
		CHL_PortalGroupsController ctrl = new CHL_PortalGroupsController(sc);
		Test.startTest();
			ctrl.selectedValue = 'Accounts';
			ctrl.searchCriteria = '%';
			pageRef = ctrl.searchRecords();
			system.assertEquals(pageRef,null);
			if(!ctrl.wrapPortalGroupList.isEmpty()) {
				ctrl.wrapPortalGroupList[0].selected = true;
			}
			ctrl.portalGroup.name = 'Test';
			pageRef = ctrl.addToGroup();
			system.assertEquals(pageRef,null);
			ctrl.deleteRec = ctrl.finalListOfGroupMembers[0].identifier;
			pageRef = ctrl.removeFromList();
			system.assertEquals(pageRef,null);
			pageRef = ctrl.savePortalGroup();
			system.assertNotEquals(pageRef,null);
			ctrl.selectedValue = 'Partner Users';
			ctrl.searchCriteria = '%';
			pageRef = ctrl.searchRecords();
			pageRef = ctrl.addToGroup();
			pageRef = ctrl.savePortalGroup();
		Test.stopTest();
	}
	
	static testMethod void CHL_PortalGroupsController_Negative() {
		ApexPages.StandardController sc = new ApexPages.StandardController(new CHL_Portal_Group__c());
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		CHL_PortalGroupsController ctrl = new CHL_PortalGroupsController(sc);
		Test.startTest();
			ctrl.selectedValue = 'Accounts';
			ctrl.searchCriteria = '';
			ctrl.searchRecords();
			system.assertEquals(ctrl.wrapPortalGroupList,null);
			ctrl.searchCriteria = '%';
			ctrl.searchRecords();
			ctrl.addToGroup();
			system.runAs(restrictedUser) {
				ctrl.savePortalGroup();
			}
		Test.stopTest();
	}

	static testMethod void CHL_PortalGroupsController_savePortalGroup() {
		List<Account> acclist = [Select id  from account];
		
		List<CHL_Portal_Group__c> portalGroupList = [Select id,name  from CHL_Portal_Group__c];
		portalGroupList[0].CHL_Roll_Up_Hierarchy__c =  false;
		update portalGroupList;
		
		List<CHL_Portal_Group_Member__c> portalGroupMemberList = [Select id,name  from CHL_Portal_Group_Member__c];
		
		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(acclist[0], null, 'Partner Account', String.valueOf(acclist[0]));
		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj1 = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(acclist[1], null, 'Partner Account', String.valueOf(acclist[1]));

		List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>  pGCommonWrapperList = new List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>{pGCommonWrapperObj};

		ApexPages.StandardController sc = new ApexPages.StandardController(portalGroupList[0]);

		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		PageReference pageRef = Page.CHL_PortalGroups;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(CSM_Constants.ID_PARAM,portalGroupList[0].id);
		CHL_PortalGroupsController ctrl = new CHL_PortalGroupsController(sc);
		Test.startTest();
			ctrl.selectedValue = 'Accounts';
			ctrl.searchCriteria = '';
			ctrl.searchRecords();
			system.assertEquals(ctrl.wrapPortalGroupList,null);
			ctrl.searchCriteria = '%';
			ctrl.searchRecords();
			ctrl.finalListOfGroupMembers = pGCommonWrapperList;
			ctrl.addToGroup();
			system.runAs(restrictedUser) {
				ctrl.savePortalGroup();
			}
		Test.stopTest();
	}

	static testMethod void PortalGroupsCntrl_savePortalGroup1() {
		List<Account> acclist = [Select id  from account];
		
		List<CHL_Portal_Group__c> portalGroupList = [Select id,name  from CHL_Portal_Group__c];
		portalGroupList[0].CHL_Roll_Up_Hierarchy__c =  true;
		update portalGroupList;
		
		List<CHL_Portal_Group_Member__c> portalGroupMemberList = [Select id,name  from CHL_Portal_Group_Member__c];
		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(acclist[0], null, 'Partner Account', String.valueOf(acclist[0]));
		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj1 = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(acclist[1], null, 'Partner Account', String.valueOf(acclist[1]));

		List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>  pGCommonWrapperList = new List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>{pGCommonWrapperObj};

		ApexPages.StandardController sc = new ApexPages.StandardController(portalGroupList[0]);

		User restrictedUser = CSM_TestDataUtility.createTestUser('System Administrator');
		PageReference pageRef = Page.CHL_PortalGroups;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(CSM_Constants.ID_PARAM,portalGroupList[0].id);
		CHL_PortalGroupsController ctrl = new CHL_PortalGroupsController(sc);
		Test.startTest();
			ctrl.selectedValue = 'Accounts';
			ctrl.searchCriteria = '';
			ctrl.searchRecords();
			system.assertEquals(ctrl.wrapPortalGroupList,null);
			ctrl.searchCriteria = '%';
			ctrl.searchRecords();
			ctrl.finalListOfGroupMembers = pGCommonWrapperList;
			ctrl.addToGroup();
	
			Set<Id> accIdSet = new Set<Id>();
			accIdSet.add(acclist[0].id);
			ctrl.savePortalGroup();
			ctrl.getAccountIds(pGCommonWrapperList, accIdSet);
			ctrl.getPublicGroupId(portalGroupList[0]);
		Test.stopTest();
	}


	static testMethod void savePortalGroup_HierarchyTrue() {
		List<Account> accChildlist = [Select id from account where ParentId != null];
		List<Account> acclist = [Select id from account where ParentId = null];

		CHL_Portal_Group__c portalGroup = new CHL_Portal_Group__c();
		portalGroup.Name = 'TestPortalGroup';
		portalGroup.CHL_Roll_Up_Hierarchy__c =  true;
		insert portalGroup;

		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(accChildlist[0], null, 'Partner Account', String.valueOf(acclist[0]));
		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj1 = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(acclist[0], null, 'Partner Account', String.valueOf(acclist[1]));

		List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>  pGCommonWrapperList = new List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>{pGCommonWrapperObj};

		ApexPages.StandardController sc = new ApexPages.StandardController(portalGroup);

		User restrictedUser = CSM_TestDataUtility.createTestUser('System Administrator');
		PageReference pageRef = Page.CHL_PortalGroups;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(CSM_Constants.ID_PARAM,portalGroup.id);
		CHL_PortalGroupsController ctrl = new CHL_PortalGroupsController(sc);
		Test.startTest();
			ctrl.selectedValue = 'Accounts';
			ctrl.searchCriteria = '';
			ctrl.searchRecords();
			system.assertEquals(ctrl.wrapPortalGroupList,null);
			ctrl.searchCriteria = '%';
			ctrl.searchRecords();
			ctrl.finalListOfGroupMembers = pGCommonWrapperList;
			ctrl.addToGroup();
	
			Set<Id> accIdSet = new Set<Id>();
			accIdSet.add(acclist[0].id);
			ctrl.savePortalGroup();
			ctrl.getAccountIds(pGCommonWrapperList, accIdSet);
			ctrl.getPublicGroupId(portalGroup);
			ctrl.clearWrapperList();
		Test.stopTest();
	}

	static testMethod void savePortalGroup_HierarchyFalse() {

		List<Account> accChildlist = [Select id from account where ParentId != null];
		List<Account> acclist = [Select id from account where ParentId = null];

		CHL_Portal_Group__c portalGroup = new CHL_Portal_Group__c();
		portalGroup.Name = 'TestPortalGroup';
		insert portalGroup;

		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(accChildlist[0], null, 'Partner Account', String.valueOf(acclist[0]));
		CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper pGCommonWrapperObj1 = new CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper(acclist[0], null, 'Partner Account', String.valueOf(acclist[1]));

		List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>  pGCommonWrapperList = new List<CHL_PortalGroupsController.CHL_PortalGroupCommonWrapper>{pGCommonWrapperObj};

		ApexPages.StandardController sc = new ApexPages.StandardController(portalGroup);

		User restrictedUser = CSM_TestDataUtility.createTestUser('System Administrator');
		PageReference pageRef = Page.CHL_PortalGroups;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(CSM_Constants.ID_PARAM,portalGroup.id);
		pageRef.getParameters().put(CSM_Constants.RET_TO_URL,'/apex/chl_test');
		CHL_PortalGroupsController ctrl = new CHL_PortalGroupsController(sc);
		Test.startTest();
			ctrl.selectedValue = 'Accounts';
			ctrl.searchCriteria = '';
			ctrl.searchRecords();
			system.assertEquals(ctrl.wrapPortalGroupList,null);
			ctrl.searchCriteria = '%';
			ctrl.searchRecords();
			ctrl.finalListOfGroupMembers = pGCommonWrapperList;
			ctrl.addToGroup();
	
			Set<Id> accIdSet = new Set<Id>();
			accIdSet.add(accChildlist[0].id);
			ctrl.savePortalGroup();
			ctrl.getAccountIds(pGCommonWrapperList, accIdSet);
			ctrl.getPublicGroupId(portalGroup);
			ctrl.clearWrapperList();
		Test.stopTest();
	} 
}