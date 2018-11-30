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
private class CSM_TriggerHandlerTest {

  static testMethod void accounTriggerHandlerTest() {
  		Test.startTest();	
  		CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        accountList[0].NumberOfEmployees = 50;
        update accountList;
        system.assertEquals(accountList[0].numberOfEmployees,50);
        Test.stopTest();
    }
    
    static testMethod void opportunityHandlerTest() {
    	Test.startTest();
    	CSM_Constants.ACCOUNT_TRIGGER = false;
		CSM_Constants.OPPORTUNITY_TRIGGER = false;
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(1, accountList[0].id);
    	system.assertEquals(opportunityList[0].CloseDate, System.today());
    	Test.stopTest();
    } 
}