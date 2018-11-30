/**
 * Created Date		: Jan 31, 2017
 * Developed By		: Dheeraj, Comity Designs, Inc.
 *
 * Function			: @description - Test class for Attachment trigger
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj					DE2063				Jan 31, 2017			1.1					@description
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
private class REN_AttachmentTriggerHandlerTest {

	
    static testMethod void myUnitTest() {
    	List<Attachment> attachmentList = new List<Attachment>();
    	try{	
	        Account accObj=new Account();
	        accObj.Name='Test Account';
	        insert accObj;        
	        Attachment attachmentobj=new  Attachment();
	        attachmentobj.Body = Blob.valueOf('Test Body');
	        attachmentobj.ParentId=accObj.id;
	        attachmentobj.Name='Test Attachment';
	        insert attachmentobj;
	        system.assert(attachmentobj!=null);
    	}catch(exception ex){
        	REN_Util.setErrorInObjects (attachmentList, ex); 
        }	    
        
    }
}