@isTest
public class CHL_MasterOpptyPermissionBatchTest {
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
       User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
           insert adminUser;
       
           
       if(CSM_AccessController.hasField('User', 'isportalenabled')) {  
           String nameSpace = CSM_Util.getNamespace();
           String partnerObjStr = nameSpace <>''?nameSpace +''+CHL_Constants.OBJ_PT_Opportunity_Share:CHL_Constants.OBJ_PT_Opportunity_Share;               
           if(CHL_Util.sObjectExists(partnerObjStr))    { 
                sObject poSObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_PT_Opportunity_Share).newSObject();
                poSObj.put(CHL_CONSTANTS.STR_USERGROUPID , adminUser.Id) ;                
                poSObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CHL_CONSTANTS.STR_SHARE_REASON) ; 
                poSObj.put(CHL_CONSTANTS.STR_PARENT , chlpartnerList[0].Id) ;
                poSObj.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
                insert poSObj;
            }
       }
       if(CHL_Util.isOWDForOpportunityPrivate())    {
            SObject sObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_OpportunityShare).newSObject();
            sObj.put(CHL_CONSTANTS.STR_USERGROUPID , adminUser.Id) ;                
            sObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CHL_CONSTANTS.STR_MANUAL) ; 
            sObj.put(CHL_CONSTANTS.STR_OPPOTUNITYID , opptyList[0].id) ;
            sObj.put(CHL_CONSTANTS.STR_OPPOTUNITYACCESS , CHL_CONSTANTS.STR_EDIT);
            insert sObj;
       }      
    }
    
    @isTest static void testBatch() {
        isNegative = false;
        Test.startTest();
         system.assert(true);
        CHL_MasterOpportunityPermissionBatch chl2 = new CHL_MasterOpportunityPermissionBatch();
        Database.executeBatch(chl2, 200);
        Test.stopTest();
    }
    
    @isTest static void testBatch_Negative() {
        isNegative = true;      
        Test.startTest();  
        system.assert(true);      
        CHL_MasterOpportunityPermissionBatch chl2 = new CHL_MasterOpportunityPermissionBatch();
        Database.executeBatch(chl2, 200);
        Test.stopTest();        
    }
}