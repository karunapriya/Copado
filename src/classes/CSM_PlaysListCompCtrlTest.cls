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
private class CSM_PlaysListCompCtrlTest {

    static testMethod void playsListCompCtrlTest() {
    	CSM_TestUtility.setUp();
    	User adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
        System.RunAs(adminUser) {
	    	CSM_PlaysListCompCtrl cmpCtrl = new CSM_PlaysListCompCtrl();
	    	cmpCtrl.playbookId = CSM_TestUtility.playBook.Id;
	    	cmpCtrl.playId = CSM_TestUtility.play.Id;
	    	
	    	System.assert(cmpCtrl.playbookId!=null);
	    	
	    	cmpCtrl.retUrl = '/apex/csm_playbookmanagement';
	        System.assert(cmpCtrl.retUrl!=null);
	         
	    	List<CSM_Play__c> playList = cmpCtrl.getPlayList();
	    	//System.assert(playList!=null && !playList.isEmpty());
	    	
	    	PageReference pr = cmpCtrl.createPlay();
	    	System.assert(pr.getURL().contains('csm_playmanagement'));
	    	
	    	cmpCtrl.playId = CSM_TestUtility.play.Id;
	    	cmpCtrl.deactivatePlay();
			//System.assert(cmpCtrl.playId=='');
			 
			cmpCtrl.playId = CSM_TestUtility.play.Id;
			 
			cmpCtrl.activatePlay();
			//System.assert(cmpCtrl.playId=='');
			cmpCtrl.playId = CSM_TestUtility.play.Id;
	    	
			pr = cmpCtrl.createPlay();
			System.assert(pr!=null);
			 
			pr = cmpCtrl.editPlay();
			System.assert(pr!=null);
			 
			pr = cmpCtrl.cancelPlay();
			System.assert(pr!=null);
			
			CSM_Play__c playNew = CSM_TestUtility.insertPlayWithoutInsert();
			insert playNew;
			cmpCtrl.playId = playNew.Id;
	    	pr = cmpCtrl.addPlay();
	    	System.assert(pr!=null);
	    	
	    	pr = cmpCtrl.addPlay();
	    	System.assert(cmpCtrl.playAdded == false);
	    	
	    }    	
    	
    }

	static testMethod void playsListCompCtrlTest_DeletePlay() {
    	CSM_TestUtility.setUp();
    	User adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
        System.RunAs(adminUser) {
			CSM_PlaysListCompCtrl cmpCtrl = new CSM_PlaysListCompCtrl();
	    	cmpCtrl.playbookId = CSM_TestUtility.playBook.Id;
	    	cmpCtrl.playId = CSM_TestUtility.play.Id;
			cmpCtrl.removePlayId = CSM_TestUtility.play.Id;
	    	
	    	System.assert(cmpCtrl.playbookId!=null);
			List<CSM_Play__c> playList = cmpCtrl.getPlayList();
	    	System.assertNotEquals(playList,null);
			
			PageReference pr = cmpCtrl.getPlayBooksCountForPlay();
			
			 pr = cmpCtrl.deletePlay();
			//System.assert(cmpCtrl.playId=='');
		}
	}

    static testMethod void playsListCompCtrlTestNeg() {
    	CSM_TestUtility.setUp();
        User stdUser  = CSM_TestDataUtility.CreateTestUser('Standard User');
        
    	CSM_PlaysListCompCtrl cmpCtrl = new CSM_PlaysListCompCtrl();
    	cmpCtrl.playbookId = CSM_TestUtility.playBook.Id;
    	cmpCtrl.playId = CSM_TestUtility.play.Id;
    	cmpCtrl.retUrl = '/apex/csm_playbookmanagement';
		PageReference pr;
		    	        
        System.RunAs(stdUser) {
        	
        	try{
	    		List<CSM_Play__c> playList = cmpCtrl.getPlayList();        	
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
	    		pr = cmpCtrl.createPlay();        	
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
		    	cmpCtrl.playId = CSM_TestUtility.play.Id;
		    	cmpCtrl.deactivatePlay();
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
				cmpCtrl.playId = CSM_TestUtility.play.Id;
				cmpCtrl.activatePlay();
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
				cmpCtrl.playId = CSM_TestUtility.play.Id;
				pr = cmpCtrl.createPlay();
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
				cmpCtrl.playId = CSM_TestUtility.play.Id;			 
				pr = cmpCtrl.editPlay();
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
				cmpCtrl.playId = CSM_TestUtility.play.Id;			 
				pr = cmpCtrl.cancelPlay();
        	}
        	catch(Exception ex){
        	
        	}
        	
        	try{
				CSM_Play__c playNew = CSM_TestUtility.insertPlayWithoutInsert();
				insert playNew;
				cmpCtrl.playId = playNew.Id;
		    	pr = cmpCtrl.addPlay();
        	}
        	catch(Exception ex){
        	
        	}
			
			System.assert(pr!=null);
	    }    	
    	
    }



}