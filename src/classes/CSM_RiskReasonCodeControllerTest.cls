@isTest
private class CSM_RiskReasonCodeControllerTest {
    static testMethod void testController() {
    	Task newTask = new Task();
    	ApexPages.StandardController sc = new ApexPages.standardController(newTask);
   		CSM_RiskReasonCodeController ctrl = new CSM_RiskReasonCodeController(sc);
   		system.assertNotEquals(ctrl.riskReasonList,null);
    }
}