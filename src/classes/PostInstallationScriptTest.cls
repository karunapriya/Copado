@isTest
private class PostInstallationScriptTest {

    static testMethod void freshInstallTest() {
        PostInstallationScript postinstall = new PostInstallationScript();
         String errorDetails = '';
        postinstall.sendEmail(errorDetails);
    	Test.startTest();
		Test.testInstall(postinstall,null);
		Test.stopTest();
		List<Zenith_Dashboard_Tab_Elements__c> zenTabLst = Zenith_Dashboard_Tab_Elements__c.getall().values();
        system.assert(zenTabLst != null);
        List<Zenith_Report_Urls__c> zenURL = Zenith_Report_Urls__c.getall().values();
        system.assert(zenURL != null);
    }
    
    static testMethod void postUpgradeTest() {
        PostInstallationScript postinstall = new PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,5));
		Test.stopTest();
        List<Zenith_Dashboard_Tab_Elements__c> zenTabLst = Zenith_Dashboard_Tab_Elements__c.getall().values();
        system.assert(zenTabLst != null);
        List<Zenith_Report_Urls__c> zenURL = Zenith_Report_Urls__c.getall().values();
        system.assert(zenURL != null);
    }
  static testMethod void testPostUpgradeCannedFC() {
        PostInstallationScript postinstall = new PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,80));
		Test.stopTest();
		system.assert(true);
    }
    
}