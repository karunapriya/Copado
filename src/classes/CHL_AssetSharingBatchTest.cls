/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class CHL_AssetSharingBatchTest {
	
	public static boolean isNegative;
	
    @testSetup 
	static void setUp() {
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();		
		
		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		Account acc1 =  CHL_TestUtility.partnerAccount();
		accountList.add(acc1);
		Account accChild =  CHL_TestUtility.partnerAccount();
		accountList.add(accChild);
		insert accountList;

		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		insert contactList;
		
		Group publicgrp = new Group();
		publicgrp.name = 'TestPortalGroup111';
		insert publicgrp;
			
		CHL_Portal_Group__c portalGroup = new CHL_Portal_Group__c();
		portalGroup.Name = 'TestPortalGroup111';
		portalGroup.CHL_Public_Group__c = publicgrp.id;
		insert portalGroup;		

		List<CHL_Portal_Group_Member__c> portalGroupMemberList = new List<CHL_Portal_Group_Member__c>();
		for(Account account :accountList) {
			CHL_Portal_Group_Member__c portalGroupMember = new CHL_Portal_Group_Member__c();
			portalGroupMember.CHL_Partner_Account__c = account.id;
			portalGroupMember.CHL_Portal_Group__c = portalGroup.id;
			portalGroupMemberList.add(portalGroupMember);
		}
		insert portalGroupMemberList;
		
		Asset assObj = new Asset();
        assObj.name = 'Partner Asset';
        assObj.AccountId = accountList[0].Id;
        assObj.CHL_Partner_Account_1__c = accountList[1].Id;
        assObj.CHL_Partner_Account_2__c = accountList[2].Id;
        insert assObj;        
        system.assert(assObj!=null);    
        
        User CSMUser = CSM_TestDataUtility.createTestUser('System Administrator');
        insert  CSMUser;   		
	    if(CSM_AccessController.hasObject('AssetShare'))	{ 	
	   		SObject assetShareObj = Schema.getGlobalDescribe().get('AssetShare').newSObject();
    		assetShareObj.put('UserOrGroupId' , CSMUser.Id) ;                
            assetShareObj.put('RowCause', 'Manual') ; 
            assetShareObj.put('AssetId' , assObj.Id) ;
            assetShareObj.put('AssetAccessLevel' , 'Edit') ; 
            insert assetShareObj;
		}
		List<CSM_Batch_Job_Config__c> cCSMBatchJobConfigList  = new List<CSM_Batch_Job_Config__c>();
		cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_AssetSharingBatch', CSM_Batch_Size__c=200));
		insert cCSMBatchJobConfigList;
	}
    static testMethod void assetShareTest() {
        isNegative = false;
        Test.startTest();
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Asset Sharing Batch', strDateTime, new CHL_AssetShareBatchScheduledDispatcher());	
		system.assert(jobID != null);
        Test.stopTest();
        
    }
    
    static testMethod void assetShareNegativeTest() {
        isNegative = true;
        Test.startTest();
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Asset Sharing Batch', strDateTime, new CHL_AssetShareBatchScheduledDispatcher());	
		system.assert(jobID != null);
        Test.stopTest();
        
    }
}