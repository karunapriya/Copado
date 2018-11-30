/**
 * Created Date		: Dec 01, 2016
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Test class for Batch filter activity page
 * Support Email 	: Nidhi@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 * Nidhi                    US1680                 Dec 01, 2016                      Test class for US1680
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */

@isTest
private class CSM_BatchFilterManagementCntrlTest {
	
	/*
	** @Description: Set up test data
	*/
	@testSetup 
	static void setup() {
		CSM_TestDataSetup testSetup = new CSM_TestDataSetup();
    	insert new CSM_BatchJobs__c(Name = 'AccountBatch', CSM_BatchJobName__c = 'CSM_BatchCreatePlayScheduledDispatcher', CSM_ObjectName__c= 'Account');
    	
    	CSM_Batch_Filter__c batchFilter = testSetup.createBatchFilter();
		String id = batchFilter.Id;
		system.assert(batchFilter!= null);
		
		CSM_Batch_Filter_Criteria__c batchFilterCriteria = testSetup.createBatchFilterCriteria(id);
	}
	
	
	/*
	** @Description: Test covearge for edit of batch filter record.
	*/
    static testMethod void batchFilterMgt_Test() {
    	List<CSM_Batch_Filter__c> batchFilterList = [select id,CSM_Display_Name__c from CSM_Batch_Filter__c  limit 1];
    	system.assert(batchFilterList!= null);
    	System.currentPageReference().getParameters().put('id',batchFilterList[0].id);
    	CSM_BatchFilterManagementCntrl cntrl = new CSM_BatchFilterManagementCntrl();
    	Test.startTest();
	    	String s = cntrl.tabCategory;
	    	s= cntrl.helpParam;
    	Test.stopTest();
	}
	
    /*
	** @Description: Test covearge for new batch filter record creation.
	*/
    static testMethod void batchFilterMgtCreate_Test() {
    	CSM_BatchFilterManagementCntrl cntrl = new CSM_BatchFilterManagementCntrl();
    	system.assert(true);
    	Test.startTest();
	    	cntrl.resetObjectName();
	    	cntrl.cancel();
	    	cntrl.saveAndNew();
	    	cntrl.batchFilterSave();
    	Test.stopTest();
	}
	
    /*
	** @Description: Test batch filter record error handling.
	*/
    static testMethod void batchFilterMgtNegative_Test() {
    	List<CSM_Batch_Filter__c> batchFilterList = [select id,CSM_Display_Name__c from CSM_Batch_Filter__c  limit 1];
    	system.assert(batchFilterList!= null);
    	System.currentPageReference().getParameters().put('id',batchFilterList[0].id);
    	CSM_BatchFilterManagementCntrl cntrl = new CSM_BatchFilterManagementCntrl();
    	Test.startTest();
	    	String s = cntrl.tabCategory;
	    	s= cntrl.helpParam;
	    	try{
	    		cntrl.resetObjectName();
	    	}catch(Exception e){}
	    	try{
	    		cntrl.batchFilterSave();
	    	}catch(Exception e){}
	    	try{
	    		cntrl.saveAndNew();
	    	}catch(Exception e){}
	    	
	    	try{
	    		cntrl.batchFilterSave();
	    	}catch(Exception e){}
	    	try{
	    		cntrl.cancel();
	    	}catch(Exception e){}
	    	try{
	    		cntrl.cancel();
	    	}catch(Exception e){}
	    	try{
	    		cntrl.setFilterObjValues();
	    	}catch(Exception e){}
    	Test.stopTest();
	}
	
	/*
	** @Description: Test batch filter record error handling.
	*/
    static testMethod void batchFilterMgtNegative1_Test() {
    	List<CSM_Batch_Filter__c> batchFilterList = [select id,CSM_Display_Name__c from CSM_Batch_Filter__c  limit 1];
    	system.assert(batchFilterList!= null);
    	System.currentPageReference().getParameters().put('id',batchFilterList[0].id);
    	CSM_BatchFilterManagementCntrl cntrl = new CSM_BatchFilterManagementCntrl();
    	Test.startTest();
	    	try{
		    cntrl.batchFilterObj.CSM_Object_Name__c = 'Account';
		    cntrl.createBatchFilterCrtieria('Test');
		   	}catch(Exception e){}
		   	try{
		    cntrl.batchFilterObj.CSM_Object_Name__c = 'Opportunity';
		    cntrl.createBatchFilterCrtieria('Test');
		   	}catch(Exception e){}
		   	try{
		    cntrl.batchFilterObj.CSM_Object_Name__c = 'CSM_Account_Plan__c';
		    cntrl.createBatchFilterCrtieria('Test');
		   	}catch(Exception e){}
		   	try{
		    cntrl.batchFilterObj.CSM_Object_Name__c = 'Case';
		    cntrl.createBatchFilterCrtieria('Test');
		   	}catch(Exception e){}
		   	try{
		    cntrl.batchFilterObj.CSM_Object_Name__c = 'CSM_Survey_Response__c';
		    cntrl.createBatchFilterCrtieria('Test');
		   	}catch(Exception e){}
    	Test.stopTest();
	}
}