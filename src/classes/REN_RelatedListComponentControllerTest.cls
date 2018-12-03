@isTest
private class REN_RelatedListComponentControllerTest {

    static void setup() {
        Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
        REN_Renew_Configuration__c rc = new REN_Renew_Configuration__c(); 
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,rc);
        rc = REN_TestDataUtility.createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false', renewConfigurationMap);
        insert rc;
        system.assert(rc.Id != null);

        REN_Related_List__c rl = new REN_Related_List__c(Name = REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
        insert rl;
        system.assert(rl.Id != null);

        CSM_Admin__c admin = new CSM_Admin__c(REN_Opportunity_Related_List__c = 'Contact Roles;Competitors;Partners');
        insert admin;
        system.assert(admin.Id != null);

    }

    static testMethod void BaseChildRelatedListComponentController_Test() {
        Test.startTest();
        setup();
        REN_RelatedListComponentController rlcc = new REN_RelatedListComponentController();
        String objectName = 'REN_Opportunity_Related_List__c';
        String nameSpace = CSM_Util.getNamespace();
        if (nameSpace != null && nameSpace.length() > 0) {
            objectName = CSM_Util.getNamespace() + objectName;
        }
        List < REN_Renew_Configuration__c > rc = [select Id from REN_Renew_Configuration__c limit 1];
        system.assert(rc != null);
        List < REN_Related_List__c > rl = [select Id from REN_Related_List__c limit 1];
        system.assert(rl != null);
        rlcc.mappingName = rc[0].Id;
        rlcc.objectName = objectName;
        rlcc.recordId = rl[0].Id;
        rlcc.selectedField = 'Competitors';
        rlcc.getOpportunityRelatedList();
        rlcc.save();
        rlcc.getRENRelatedWrapperList();
        rlcc.AddField();
        rlcc.removeRelatedList();
        Test.stopTest();
    }

}