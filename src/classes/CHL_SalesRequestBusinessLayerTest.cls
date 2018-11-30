/**
* @description    Test class for CHL_SalesRequestBusinessLayer        
*/
@isTest
public with sharing class CHL_SalesRequestBusinessLayerTest {
    
@testSetup static void setup() {       
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();

        Account acc =  CHL_TestUtility.partnerAccount();
        accountList.add(acc);
        insert accountList;
        
        System.assert(accountList != null);

        Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
        contactList.add(con);
        insert contactList;
        
        Case caseObj = new Case(
        ContactId = contactList[0].id,
        AccountId = accountList[0].id,
        Status = 'Closed',
        Origin = 'Phone');
        insert caseObj;
        
        Case caseObjAll = new Case(
        ContactId = contactList[0].id,
        AccountId = accountList[0].id,
        Status = 'All',
        Origin = 'Phone');
        insert caseObjAll;
        
        Case caseObjOpen = new Case(
        ContactId = contactList[0].id,
        AccountId = accountList[0].id,
        Status = 'Open',
        Origin = 'Phone');
        insert caseObjOpen;
        
    	CaseComment caseComment = new CaseComment();
		caseComment.CommentBody  = 'test subject';
		caseComment.ParentId = caseObj.id;
		insert caseComment;
    }
    
    static testMethod void Request_Grid_PositiveTest() {
        
        List<Contact> contactList = [select Id, name from contact limit 1];
        User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
        insert adminUser;
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('PRISM_Base');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        Test.startTest();   
        CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
            CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
            gridParams.requestType = 'Closed';
            inputWrapper.queryParams = gridParams;
            inputWrapper.gridType = 'CHANNEL_OPPS';
            string inputvalue= JSON.serialize(inputWrapper);
            CHL_SalesRequestBusinessLayer pobl = new CHL_SalesRequestBusinessLayer(inputWrapper);
            CHL_AngularResponeWrapper wrp = new CHL_AngularResponeWrapper();
            wrp = pobl.constructGridWrapper();  
            CHL_SalesRequestBusinessLayer.getCaseTypes();
            system.assert(wrp<>null);
                
            
            gridParams.requestType = 'All';
            inputWrapper.queryParams = gridParams;
            inputWrapper.gridType = 'CHANNEL_OPPS';
            inputvalue= JSON.serialize(inputWrapper);
            pobl = new CHL_SalesRequestBusinessLayer(inputWrapper);
            wrp = new CHL_AngularResponeWrapper();
            wrp = pobl.constructGridWrapper();  
            system.assert(wrp<>null);
            
            gridParams.requestType = 'OPEN';
            inputWrapper.queryParams = gridParams;
            inputWrapper.gridType = 'CHANNEL_OPPS';
            inputvalue= JSON.serialize(inputWrapper);
            pobl = new CHL_SalesRequestBusinessLayer(inputWrapper);
            wrp = new CHL_AngularResponeWrapper();
            wrp = pobl.constructGridWrapper();  
            system.assert(wrp<>null);
            
            Test.stopTest();
    }
    
    // Test method for CHL_CommunityLandingController - getRequestNotes()
    static testMethod void caseComments_PositiveTest() {
     	List<Case> caseList = [select id from Case  where Status = 'Closed' ];
        CHL_AngularTabsInputWrapper inputWrapper = new CHL_AngularTabsInputWrapper();
        system.assert(caseList != null);
        if(!caseList.isEmpty()){
            inputWrapper.requestId = caseList[0].Id;
        }
        String inputValue = JSON.serialize(inputWrapper);
        Test.startTest();   
           CHL_CommunityLandingController.getRequestNotes(inputValue);
        Test.stopTest();
     }
     
        
}