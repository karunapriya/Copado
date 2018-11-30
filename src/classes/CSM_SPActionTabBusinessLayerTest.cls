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
private class CSM_SPActionTabBusinessLayerTest {

private static CSM_User_Preferences__c userPrefRecord = new CSM_User_Preferences__c();
    static testMethod void testSPActionTabBusinessLayerTasks() {
    	setUpData();
		Test.startTest();
		
		CSM_TestUtility.setup(); 
		String req = '{"objType": "Task","params" : {"selectedTaskFilter":"All","accountId":"'+CSM_TestUtility.acct.Id+'"},"viewName" : "actionTab"}';
		CSM_GridResponseWrapper grw = CSM_CustomGridController.getResponseForGrid(req);
		System.assert(grw.row!=null);
		System.assert(grw.header.size()>0);
		System.assert(grw.hasAction==true);
		System.assert(grw.hasDetail==true);      
        CSM_Constants.TASK_TRIGGER = true;
        req = '{"objType": "Task","params" : {"selectedTaskFilter":"","accountId":""},"viewName" : ""}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		System.assert(grw.row!=null);
		System.assert(grw.header.size()>0);
		System.assert(grw.row.size()==0);
		System.assert(grw.hasAction==true);
		System.assert(grw.hasDetail==true);
		
		userPrefRecord.CSM_Success_Plan_Actions_Grid_Columns__c = '';
		upsert userPrefRecord;
		req = '{"objType": "Task","params" : {"selectedTaskFilter":"All","accountId":"'+CSM_TestUtility.acct.Id+'"},"viewName" : "actionTab"}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		System.assert(grw.row!=null);
		System.assert(grw.header.size()>0);
		System.assert(grw.hasAction==true);
		System.assert(grw.hasDetail==true);      
        CSM_Constants.TASK_TRIGGER = true;
        
        userPrefRecord.CSM_Success_Plan_Actions_Grid_Columns__c = 'Test';
		upsert userPrefRecord;
		req = '{"objType": "Task","params" : {"selectedTaskFilter":"All","accountId":"'+CSM_TestUtility.acct.Id+'"},"viewName" : "actionTab"}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		System.assert(grw.row!=null);
		System.assert(grw.header.size()>0);
		System.assert(grw.hasAction==true);
		System.assert(grw.hasDetail==true);      
        CSM_Constants.TASK_TRIGGER = true;
		List<CSM_GridColumnWrapper> headerList = grw.header;
        Test.stopTest();
		System.debug('ZZZ -'+grw);
    }
    
    /*private static String setUp() 
	{
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        String testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        Task task = new Task();     
        task.Subject = 'Hello';
        task.WhatId = testAccountId;
        insert task;
        System.assertNotEquals(task.Id, null);
        return testAccountId;
	}*/
	
	static testMethod void setUpData() 
	{
        userPrefRecord.CSM_User__c = UserInfo.getUserId();
        userPrefRecord.CSM_Success_Plan_Actions_Grid_Columns__c = 'status,activitydate,subject,CSM_Play__c,CSM_Play_Status__c,CSM_Play_Enter_Date__c,whatid,ownerid';
        insert userPrefRecord;
	}
}