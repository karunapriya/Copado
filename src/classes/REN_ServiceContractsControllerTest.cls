@isTest
private class REN_ServiceContractsControllerTest {
	private static void init() {
		CSM_TestUtility.addRenewLicense();
	}
    static testMethod void REN_ServiceContractsController_Test() {
    	init();
    	REN_ServiceContractsController scc = new REN_ServiceContractsController();
    	system.assert(scc.retURL != null);
    	system.assert(scc.helpParam != null);
    }
}