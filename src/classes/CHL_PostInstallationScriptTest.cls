@isTest
private class CHL_PostInstallationScriptTest {

    static testMethod void generateDataTest() {
        CHL_PostInstallationScript postinstall = new CHL_PostInstallationScript();
        List<REN_Field_Mappings__c> fieldMappingList;
        Test.startTest();
            Test.testInstall(postinstall,null);
            
            fieldMappingList = [select id from REN_Field_Mappings__c where  name in ('Quote → Opportunity')];
            system.assert(fieldMappingList.size() != null);
            
            fieldMappingList = [select id from REN_Field_Mappings__c where  name in ('Opportunity → Quote')];
            system.assert(fieldMappingList.size() != null);
        Test.stopTest();
    }
}