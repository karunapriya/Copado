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
private class CSM_ChartManagementTest {

    static testMethod void chartManagementListTest() {
       	List<CSM_Chart_Management__c> chartList = CSM_TestDataUtility.createChartList();
       	system.debug('chartList $$ ' + chartLIst);
       	Test.startTest();
       	
       	CSM_ChartManagementListCtrl cList = new CSM_ChartManagementListCtrl();
       	
       	cLIst.chartIdSelected = cList.chartMgmtList[0].id;
       	
       	PageReference p = cLIst.editChart();
       	system.assert(!String.isBlank(String.valueOf(p.getUrl())));
       	
       	
       	Test.stopTest();
    }
    
    static testMethod void chartManagementTest() {
    	List<CSM_Chart_Management__c> chartList = CSM_TestDataUtility.createChartList();
       	Test.startTest();
       	CSM_ChartManagementDataAccess.getCharts();
       	CSM_ChartManagementCtrl c = new CSM_ChartManagementCtrl();
       	c.chartId = chartLIst[0].id;
       	c.buildObjectFieldList();
       	c.selectedObject = 'Account';
       	c.buildObjectList(c.selectedObject);
       	c.getChart();
       	c.getField1Values();
       	c.getField2Values();
       	c.getField3Values();
       	c.getChart();
       	c.getObjectList();
       	
       	c.cancelButton();
       	c.saveButton();
       	system.assertEquals(c.chartManagement.CSM_Object_Name__c, 'Account'); 
       	
       	
       	
       	Test.stopTest();
    	
    }
}