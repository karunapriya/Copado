@isTest
public class CSM_TriggerEnablementDataAccessTest {
	@testSetup 
	static void setUpData() {
       	CSM_TriggerEnablement__c cTriggerEnablement  = new CSM_TriggerEnablement__c(CLM_Bypass_Data_Load_Validation__c=false, CSM_OpportunityTrigger__c=true);
    	insert cTriggerEnablement;
    	system.assert(cTriggerEnablement!=null);        
    }
    static testmethod void triggerEnablementTest(){
        CSM_TriggerEnablementDataAccess obj = CSM_TriggerEnablementDataAccess.getInstance();
        system.assert(obj!=null);
        boolean isEnabled=obj.byPassDataloadValidation;
        obj.isTriggerEnabled(CSM_TriggerEnablementDataAccess.OpportunityTrigger);
    }
}