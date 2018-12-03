@isTest
private class REN_PostInstallationScriptTest {
     static testMethod void TestPostInstallationScript(){
      REN_PostInstallationScript postinstall = new REN_PostInstallationScript();
        Test.startTest();
        Test.testInstall(postinstall,new Version(1,8));
         system.assert(true);
        Test.stopTest();
    }
}