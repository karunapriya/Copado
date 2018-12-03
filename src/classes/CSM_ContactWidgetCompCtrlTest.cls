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
private class CSM_ContactWidgetCompCtrlTest {

    static testMethod void myUnitTest() {
       List<Account> accountList = CSM_TestDataUtility.createAccount(1);
       List<Contact> contactList = CSM_TestDataUtility.createContacts(accountList[0].id, 3);
       CSM_ContactWidgetCompCtrl contactWidget = new CSM_ContactWidgetCompCtrl();
       Test.startTest();
       contactWidget.accountId = accountList[0].id;
       List<Contact> cList = contactWidget.getContacts();
       system.assertEquals(cList.size(),3);
       Integer i = contactWidget.csmRelatedSize;
       
       Integer c = contactWidget.conSize;
       system.assertEquals(c,3);
       contactWidget.contactToUpdate = contactList[0].id;
       contactWidget.relateContact();
       contactWidget.contactToUpdate = contactList[0].id;
       contactWidget.unrelateContact();
       Integer pSize = contactWidget.getPageSize();
       contactWidget.taskViewId = '1231231';
       contactWidget.successPlanId = '';
       PageReference pRef2 = contactWidget.emailToWhatId();
       contactWidget.taskViewId = '';
       contactWidget.successPlanId = '1231231';
       PageReference pRef3 = contactWidget.emailToWhatId();
       contactWidget.successPlanId = '';
       PageReference pRef4 = contactWidget.emailToWhatId();
       PageReference pRef = contactWidget.redirectToContact();
       PageReference pRef5 = contactWidget.updatePageSize();
       PageReference pRef6 = contactWidget.reducePageSize();
       contactWidget.contactToUpdate = contactList[0].id;
       PageReference pRef7 = contactWidget.redirectToContact();
       
       Test.stopTest();
       
		
    }
}