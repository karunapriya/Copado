@isTest
private class REN_CriteriaMetComponentControllerTest {
	 static void setup() {
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
        system.assert(renewConfigurationList != null);
	 }
	  static testMethod void REN_CriteriaMetComponentController_Test() {
        Test.startTest();
        setup();
        List < REN_Renew_Configuration__c > rc = [select Id  from REN_Renew_Configuration__c limit 1];
        system.assert(rc != null);
        
        REN_CriteriaMetComponentController cmc = new REN_CriteriaMetComponentController();
        cmc.configurationId = rc[0].Id;
        cmc.objectName = 'Opportunity';
        cmc.getPushTypes();
        cmc.pushTypeChanged();
        cmc.renewConfiguration = rc[0];
        String s = cmc.pushType + cmc.ownerNotify + cmc.pushTypeAll;
        Boolean b = cmc.ownerNotify;
        cmc.save();
        
        Test.stopTest();
	  }
}