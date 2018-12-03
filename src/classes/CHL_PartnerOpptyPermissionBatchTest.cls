@isTest
public class CHL_PartnerOpptyPermissionBatchTest {	
	public static boolean isNegative;
	@testSetup static void setup() {
       List<Account> accountList = new List<Account>();
	   List<Contact> contactList = new List<Contact>();
	   List<Opportunity> opptyList = new List<Opportunity>();
	   Account acc =  CHL_TestUtility.partnerAccount();
	   Account acc2 =  CHL_TestUtility.partnerAccount();
	   accountList.add(acc);
	   accountList.add(acc2);
	   insert accountList;
	   
	   Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
	   Contact con2 =  CHL_TestUtility.partnerContact(accountList[1].id);
	   contactList.add(con);
	   contactList.add(con2);
	   insert contactList;
	   
	   Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
	   opptyList.add(oppty);
	   insert opptyList; 
	   
	   CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
	   partOppty.OpportunityId = opptyList[0].id;
	   partOppty.partnerAcc1Id = accountList[0].id ;
	   partOppty.partnerAcc1Type = 'Reseller';
	   partOppty.contact1Id = contactList[0].Id;
	   partOppty.expirationDate= system.today().addDays(-10);
	   partOppty.Stage= 'Needs Analysis';
	   system.assert(partOppty != null);
	     
	   List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(1,partOppty); 
	   insert chlpartnerList;
	   if(CSM_AccessController.hasField('User', 'isportalenabled')) {
		   User partnerUser1 = CHL_TestUtility.createTestPartnerUser('System Administrator','con@partner.com',contactList[1].Id);
		   insert partnerUser1;
	   }   
	   User CSMUser = CSM_TestDataUtility.createTestUser('System Administrator');
       insert  CSMUser;
	   String nameSpace = CSM_Util.getNamespace();
   	   String partnerObjStr = nameSpace <>''?nameSpace +CHL_Constants.OBJ_PT_Opportunity_Share:CHL_Constants.OBJ_PT_Opportunity_Share;       		
	   if(CHL_Util.sObjectExists(partnerObjStr))	{ 
	   		string sharingReason = nameSpace+CHL_CONSTANTS.STR_SHARE_REASON;
    		sObject poSObj = Schema.getGlobalDescribe().get(partnerObjStr).newSObject();
    		poSObj.put(CHL_CONSTANTS.STR_USERGROUPID , CSMUser.Id) ;                
            poSObj.put(CHL_CONSTANTS.STR_ROWCAUSE , sharingReason) ; 
            poSObj.put(CHL_CONSTANTS.STR_PARENT , chlpartnerList[0].Id) ;
            poSObj.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
            insert poSObj;
		}
	   
	   
    }
    
    @isTest static void testBatchScheduler() {
    	isNegative = false;
    	Test.startTest();
    	List<Account> accList = [select Id,ParentId from Account limit 2];
    	List<Account> accListToUpdate = new List<Account>();
    	Account accObj = new Account(Id = accList[0].Id);
    	accObj.ParentId = accList[1].Id;
    	update accObj;
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Partner Opportunity Permission', strDateTime, new CHL_PartnerOptyPermissionSchDispatcher());	
		system.assert(jobID != null);
        Test.stopTest();
    }
    
   @isTest static void testBatchScheduler_Negative() {
   		isNegative = true;    	
        Test.startTest();
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Partner Opportunity Permission', strDateTime, new CHL_PartnerOptyPermissionSchDispatcher());	
		system.assert(jobID != null);
        Test.stopTest();        
    }
}