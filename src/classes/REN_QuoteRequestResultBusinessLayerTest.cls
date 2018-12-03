/**
 * Created Date		: Feb 7, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
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
 * abirjepatil					User Story				Feb 7, 2017			1.1					@description
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
private class REN_QuoteRequestResultBusinessLayerTest {

    static testMethod void myUnitTest() {
    	Test.startTest();
	        CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
	    	inputWrapper.params = gridParams;
	    	CSM_BusinessLayer businessLayer = new REN_QuoteRequestResultBusinessLayer(inputWrapper);
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(responseWrapper != null);
	    	system.assert(responseWrapper.header != null);
	    	system.assert(!responseWrapper.header.isEmpty());
	    	system.assert(responseWrapper.row != null);
	    	system.assertEquals(responseWrapper.hasAction, false);
	    	system.assertEquals(responseWrapper.hasCheckbox, false);
	    Test.stopTest();
    }
       
}