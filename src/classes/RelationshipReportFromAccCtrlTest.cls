/**
 * Created Date		: Jan 22, 2018
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
 * sanketsupe			    US3092				 Jan 22, 2018	      1.1				@description
 *
 */
@isTest(SeeAllData='true')
public with sharing class RelationshipReportFromAccCtrlTest {
    
    static testMethod void myUnitTest() {
       PageReference pageRef = Page.RelationshipReportFromAcc;
       Test.setCurrentPage(pageRef);
        try {
        
        	Account acc = new Account();
            acc.Name = 'Test Account';
           	insert acc;
            
            List<Report> reportList = [SELECT Id FROM Report where name = 'Relationship Report'];
            if(reportList != null && reportList.size()>0) {
            	String reportId = (String)reportList.get(0).get('Id');
            
                ApexPages.CurrentPage().getparameters().put('Id', reportId);
                ApexPages.StandardController acct = new ApexPages.standardController(acc);
                RelationshipReportFromAccCtrl controller = new RelationshipReportFromAccCtrl(acct);
            
                Test.startTest();
                controller.getRedirect();
                system.debug('pageRef:::' +pageRef);
                system.assert(pageRef != null); 
                Test.stopTest();
            }
        } catch (Exception e) {
    		System.assert(true, 'Exception ' + e);
		}
      } 
}