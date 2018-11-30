/**
 * Created Date		: May 31, 2017
 * Developed By		: sanket, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________________
 *
 * sanketsupe			    User Story				May 31, 2017	 1.1					@description
 *
 */
@isTest
public with sharing class CSM_CreateFollowUpCSMTaskCtrlTest {
    
    static testMethod void myUnitTest() {
       // CSM_Admin__c  cmsAdmin = CSM_Admin__c.getOrgDefaults();
        //cmsAdmin.CSM_Inherit_Task_Record_Type__c = true;
        //upsert cmsAdmin;
        
    	PageREference pageRef = Page.CSM_CreateFollowUpCSMTask;
       	Test.setCurrentPage(pageRef);
       	       	       	
       	Account acc = new Account();
       	acc.Name = 'Test Account';
       	
       	insert acc;
       	
       	Task taskList = new Task();
       	taskList.Subject = 'Follow up Task';
       	//taskList.CSM_SuccessPlan_Play__c = 'test';
       	taskList.WhatId = acc.id;
       	       	
       	taskList.Priority = 'Normal';
		taskList.status = 'In Progress';
        taskList.ActivityDate = system.today();
       	
       	insert taskList;
       	
        ApexPages.CurrentPage().getparameters().put('Id', taskList.Id);
        ApexPages.StandardController task = new ApexPages.standardController(taskList);
       	CSM_CreateFollowUpCSMTaskCtrl controller = new CSM_CreateFollowUpCSMTaskCtrl(task);
       	
       	
       	Test.startTest();
       	controller.getRedirect();
       	system.debug('pageRef:::' +pageRef);
       	system.assert(pageRef != null); 
       	Test.stopTest();
    }
}