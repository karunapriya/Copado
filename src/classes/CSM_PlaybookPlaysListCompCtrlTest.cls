/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CSM_PlaybookPlaysListCompCtrlTest {

    static testMethod void playbookPlaysListCompCtrlTest() {
    	CSM_TestUtility.setUp();
    	User adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
        System.RunAs(adminUser) {
	    	CSM_PlaybookPlaysListCompCtrl cmpCtrl = new CSM_PlaybookPlaysListCompCtrl();
	    	cmpCtrl.playbookId = CSM_TestUtility.playBook.Id;
	    	cmpCtrl.playId = CSM_TestUtility.play.Id;
	    	
	    	System.assert(cmpCtrl.playbookId!=null);
	    	
	    	List<CSM_PlaybookPlay__c> pbPlayList = cmpCtrl.getPlaybookPlayList();
	    	System.assertNotEquals(pbPlayList,null);
	    	
	    	PageReference pr = cmpCtrl.createPlay();
	    	System.assert(pr.getURL().contains('csm_playmanagement'));
	    	
	    	pr = cmpCtrl.addPlay();
	    	System.assert(pr.getURL().contains('csm_addplay'));
	
	    	pr = cmpCtrl.editPlay();
	    	System.assert(pr.getURL().contains('csm_playmanagement'));
	    	
	    	pr = cmpCtrl.removePlayFromPlaybook();
	    	System.assert(pr==null);
        }    	
    	
    }

}