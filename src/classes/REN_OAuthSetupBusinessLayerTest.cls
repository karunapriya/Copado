/**
 * Created Date		: Jan 17, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US1981					Jan 17, 2017	1.1					Added class in sprint 701
 *
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
 *
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class REN_OAuthSetupBusinessLayerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List<REN_Low_Dollar_Client__c> listOfLTConfig = REN_LowTouchClientDataAccess.getLowDollarClientDetails();
        REN_Low_Dollar_Client__c adminRecord = null;
        if(listOfLTConfig != null && !listOfLTConfig.isEmpty()){
            adminRecord  = listOfLTConfig.get(0);
        }
        if(adminRecord == null) {
             adminRecord = new REN_Low_Dollar_Client__c(Name='test',REN_Low_Touch_Admin_URL__c= 'https://login.salesforce.com', REN_OAuth_Credentials__c = 'test');
             insert adminRecord;
        }
        system.assert(adminRecord!=null);
       
	}
	
    static testMethod void myUnitTest() {
    	
    	Test.startTest();
	        CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
	    	inputWrapper.params = gridParams;
	    	CSM_BusinessLayer businessLayer = new REN_OAuthSetupBusinessLayer(inputWrapper);
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(responseWrapper != null);
	    	system.assert(responseWrapper.header != null);
	    	system.assert(!responseWrapper.header.isEmpty());
	    	system.assert(responseWrapper.row != null);
	    	system.assertEquals(responseWrapper.hasAction, true);
	    	system.assertEquals(responseWrapper.hasCheckbox, false);
	    	system.assertEquals(responseWrapper.hasDetail, false);
	    Test.stopTest();
    }
}