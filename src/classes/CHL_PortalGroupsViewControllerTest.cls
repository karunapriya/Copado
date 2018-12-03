@isTest
private class CHL_PortalGroupsViewControllerTest {
	
	@testSetup 
    static void setUp() {
		   List<Account> accountList = new List<Account>();
		   List<Contact> contactList = new List<Contact>();
		   List<Opportunity> opptyList = new List<Opportunity>();
		   List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
		   
		   Account acc =  CHL_TestUtility.partnerAccount();
		   accountList.add(acc);
		   insert accountList;
		   
		   System.assert(accountList != null);
		   
		   Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		   contactList.add(con);
		   insert contactList;
		   
		   CHL_Portal_Group__c portalGroup = new CHL_Portal_Group__c();
		   portalGroup.Name = 'TestPortalGroup';
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
    static testMethod void testController() {
    	List<CHL_Portal_Group__c> portalGroup = [select id from CHL_Portal_Group__c];
    	List<CHL_Portal_Group_Member__c> portalGroupMember = [select id from CHL_Portal_Group_Member__c];
    	PageReference pageRef = Page.CHL_PortalGroupsView;
    	Test.setCurrentPageReference(pageRef);
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,portalGroup[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new CHL_Portal_Group__c());
    	CHL_PortalGroupsViewController ctrl = new CHL_PortalGroupsViewController(sc);
    	//setUp();
    	Test.startTest();
    		pageRef = ctrl.editPortalGroup();
    		system.assertNotEquals(pageRef,null);
    		pageRef = ctrl.returnPage();
    		system.assertNotEquals(pageRef,null);
    		ctrl.helpParam = 'Test';
    	Test.stopTest();
    }
}