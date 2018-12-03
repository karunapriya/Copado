@isTest
private class CHL_PortalGroupMemViewBusinessLayerTest {
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
       
       //User userRecord = CSM_TestDataUtility.createTestUser('Standard User');
       
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
	   for(Account account :accountList) {
       		CHL_Portal_Group_Member__c portalGroupMember = new CHL_Portal_Group_Member__c();
       		portalGroupMember.CHL_Partner_User__c = account.ownerid;
       		portalGroupMember.CHL_Portal_Group__c = portalGroup.id;
       		portalGroupMemberList.add(portalGroupMember);
       }
       insert portalGroupMemberList;
    }
    static testMethod void testBusinessLayer_Positive() {
    	Test.startTest();
	        List<CHL_Portal_Group__c> portalGroup = [select id from CHL_Portal_Group__c];
		   	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
	    	gridParams.taskOrViewId = portalGroup[0].id;
	    	inputWrapper.params = gridParams;
	    	CSM_BusinessLayer businessLayer = new CHL_PortalGroupMembersViewBusinessLayer(inputWrapper);
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(responseWrapper != null);
	    	system.assert(responseWrapper.header != null);
	    	system.assert(responseWrapper.row != null);
	    	system.assertEquals(responseWrapper.hasAction, false);
	    	system.assertEquals(responseWrapper.hasCheckbox, false);
	    	system.assertEquals(responseWrapper.hasDetail, false);
	    Test.stopTest();
    }
    static testMethod void testBusinessLayer_Negative() {
    	Test.startTest();
    		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
	        List<CHL_Portal_Group__c> portalGroup = [select id from CHL_Portal_Group__c];
	        system.runAs(restrictedUser) {
			   	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
		    	gridParams.taskOrViewId = portalGroup[0].id;
		    	inputWrapper.params = gridParams;
		    	CSM_BusinessLayer businessLayer = new CHL_PortalGroupMembersViewBusinessLayer(inputWrapper);
		    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
		    	system.assert(responseWrapper != null);
	        }
		Test.stopTest();	    	
    }
}