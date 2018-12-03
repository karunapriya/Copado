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
private class REN_MultiSelectPicklistCompCtrlTest {

    static testMethod void multiSelectPickListTest() 
    {
    	REN_MultiSelectPicklistCompCtrl controller = new REN_MultiSelectPicklistCompCtrl();
    	Profile renewProfile = [Select Name, Id From Profile where Name = 'Standard User' limit 1]; 
		User standardUser =  CSM_TestDataUtility.CreateUser(renewProfile.Id);
		insert standardUser;
		system.assertNotEquals(standardUser,null);
		User selectedUser = [select id,email,name from user where id = :standardUser.id limit 1];
		
        Test.startTest();
        
        	controller.mainControllerRef = new REN_BaseMainController();
        	
        	controller.allRecipients = [select id,email,name from user where id = :standardUser.id limit 1];
        	system.assertNotEquals(controller.allRecipients, null);
        	
        	controller.selectedRecipients = [select id,email,name from user where id = :standardUser.id limit 1];
        	system.assertNotEquals(controller.selectedRecipients, null);
        	
        	controller.finalRecipients = [select id,email,name from user where id = :standardUser.id limit 1];
        	system.assertNotEquals(controller.finalRecipients, null);
        	
        	controller.fieldNames = new List<String>();
        	controller.fieldNames.add('Id');
        	controller.fieldNames.add('Name');
        	controller.fieldNames.add('Email');
        	system.assertNotEquals(controller.fieldNames, null);
        	
        	String getjsonAllRecipients = controller.getjsonAllRecipients();
        	system.assertNotEquals(getjsonAllRecipients, null);
        	
        	String getjsonSelectedRecipients = controller.getjsonSelectedRecipients();
        	system.assertNotEquals(getjsonSelectedRecipients, null);
        	
        	controller.objectName = 'User';
        	PageReference pr = controller.retrieveSelectedRecipients();
        	
        	controller.jsonNewSelectedRecipients = getjsonSelectedRecipients;
        	system.assertNotEquals(controller.jsonNewSelectedRecipients, null);
        	
        	
        Test.stopTest();
    }
}