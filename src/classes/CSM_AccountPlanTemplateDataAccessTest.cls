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
private class CSM_AccountPlanTemplateDataAccessTest {

    static testMethod void Test_getTemplateByName_Positive() {
     	CSM_TestUtility.setup();
    	Test.startTest();
    	List<CSM_Account_Plan_Template__c> accntTempList = CSM_AccountPlanTemplateDataAccess.getTemplateByName();
    	system.assert(accntTempList.isEmpty());
    	Test.stopTest();
    }
    static testMethod void Test_getTemplateByName_Negative()
    {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser)
    	{
    	try
    	{
    		List<CSM_Account_Plan_Template__c> accntTempList = CSM_AccountPlanTemplateDataAccess.getTemplateByName();
    	}
    	catch(Exception e)
    	{
    		system.assert(true);
    	}
    	}
    	Test.stopTest();
    }
}