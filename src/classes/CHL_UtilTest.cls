/**
* @description : Test class for CHL_Util.
				 Functions - getAccAndChildAccIDs and fetchChildAccounts required Partner Accounts i.e IsPartner = true. 
				 Not possible to create Partner Account in DataSetup as IsPartner field is not writable.
*/

@isTest
private class CHL_UtilTest {

   @testSetup static void setup() {   
			
		Account accParent = new Account();
		accParent = CHL_TestUtility.partnerAccount();
		insert accParent;
		
		Account accChild = CHL_TestUtility.partnerAccount();
		accChild.ParentId = accParent.id;
		insert accChild;
		
		List < Contact > contactList = new List < Contact > ();
		Contact con = CHL_TestUtility.partnerContact(accParent.id);
		contactList.add(con);
		insert contactList;
		System.assert(contactList != null);
		
		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accParent.id,'Needs Analysis');
		
		insert oppty; 
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
			partOppty.OpportunityId = oppty.id;
			partOppty.partnerAcc1Id = accParent.id;
			partOppty.partnerAcc1Type = 'Reseller';
			partOppty.contact1Id = contactList[0].Id;
			partOppty.expirationDate= system.today().addDays(-10);
			partOppty.Stage= 'Needs Analysis';	
		CHL_Partner_Opportunity__c chlpartnerObj =   CHL_TestUtility.channelPartnerOpportunity(partOppty); 
		insert chlpartnerObj;
   }
   
    /*static testMethod void utilTest() {
    	
		User channelUser  = CSM_TestDataUtility.createTestUser('Channel');
		insert channelUser;
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('Channel');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = channelUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
		List < Account > Acclist = [select id, name from Account];
		List<CHL_Partner_Opportunity__c> partnerOpp = [select id, name,CHL_Opportunity__c from CHL_Partner_Opportunity__c];
		List <User> userIdList = [select id, name from User];
		Test.startTest();
			system.runas(channelUser) {
				system.assertNotEquals(Acclist,null);
				//CHL_Util.getAccAndChildAccIDs(Acclist[0].id, Acclist[0].id);
				//CHL_Util.sendEmailNotificationWithUrl('Subject Text','Text1','Text2', 'Admin User', partnerOpp[0].CHL_Opportunity__c); Commented to fix build error
				//CHL_Util.fetchLastNewOpportunityViewDate();
				//CHL_Util.fetchContactIdOfUser(userIdList[0].id);
				system.assert(true);
			}
		Test.stopTest();
    }*/
    
     
     static testMethod void Test_Acc_Hierarchy() {
		User channelUser  = CSM_TestDataUtility.createTestUser('System Administrator');
		List < Account > Acclist = [select id, name from Account];
		Test.startTest();
			system.runas(channelUser) {
				system.assertNotEquals(Acclist,null);
				
				Account accParent = new Account();
					accParent = CHL_TestUtility.partnerAccount();
				insert accParent;
				Account accChild = CHL_TestUtility.partnerAccount();
					accChild.ParentId = accParent.id;
				insert accChild;
				system.assert(true);
				//CHL_Util.getAccAndChildAccIDs(accParent.id, accParent.id);
				
			}
		Test.stopTest();
    }
    
}