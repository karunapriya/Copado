@isTest
public class REN_LT_LiveAgentControllerTest {
    @testsetup
    static void setup(){
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList!=null);
        List<Contact> contList = CSM_TestDataUtility.createContacts(accList[0].Id,1);
        List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, (String)accList[0].id);
        system.assert(opptyList!=null);
        OpportunityContactRole objOppConRole=new OpportunityContactRole();
        objOppConRole.OpportunityId=opptyList[0].id;
        objOppConRole.ContactId=contList[0].Id;
        objOppConRole.IsPrimary=true;
        insert objOppConRole;
        REN_LT_LiveAgentDetails__c objLiveAgent=new REN_LT_LiveAgentDetails__c();
        objLiveAgent.Name='LT';
        objLiveAgent.REN_LT_Chat_button_Id__c='123';
        insert objLiveAgent;
        SS_License__c licenseInstance = SS_License__c.getOrgDefaults();
        if(licenseInstance.REN_AES_Encryption_Key__c == null || String.isBlank(licenseInstance.REN_AES_Encryption_Key__c)) {
            Blob key = Crypto.generateAesKey(256);
            licenseInstance.REN_AES_Encryption_Key__c = EncodingUtil.base64Encode(key);             
            upsert licenseInstance;
        }
    }
    static testmethod void myUnitTest(){
        list<Opportunity> objOppList=[select Id from Opportunity];
        system.assert(objOppList!=null);
        
        PageReference tpageRef = Page.REN_LT_LiveAgent;
        Test.setCurrentPage(tpageRef);
        SS_License__c licenseInstance = SS_License__c.getOrgDefaults(); 
        Blob encryptionKey = Crypto.generateAesKey(256);                
        string keystring = licenseInstance.REN_AES_Encryption_Key__c != null && String.isNotBlank(licenseInstance.REN_AES_Encryption_Key__c) ? licenseInstance.REN_AES_Encryption_Key__c : EncodingUtil.base64Encode(encryptionKey);
        Blob key = EncodingUtil.base64Decode(keystring);
        String renIdData = REN_Util.getEncryptedData(String.valueof(objOppList[0].Id),key);
        ApexPages.currentPage().getParameters().put('renId', renIdData);
        
        REN_LT_LiveAgentController objLiveAgentCtrl=new REN_LT_LiveAgentController();
        objLiveAgentCtrl.oppID=objOppList[0].id;
    }
}