/**
 * Created Date		: April 21, 2017
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
 * sanketsupe			    User Story				April 21, 2017	 1.1					@description
 *
 */

@isTest
private class REN_TaskTemplateControllerTest {
	
	static testMethod void myUnitTest() {
		String tType;
    	//REN_TaskTemplateController controller = new REN_TaskTemplateController();
    	string temp;
    	REN_Task_Template__c temp1 = new REN_Task_Template__c();
    	String insertRc = 'Task - Standard';	
    	temp1.REN_Record_Type__c = insertRc;
    	insert temp1;
    	PageREference pageRef = Page.REN_TaskTemplate;
       	Test.setCurrentPage(pageRef);
    	    	
    	Test.startTest();
   
    	REN_TaskTemplateController controller = new REN_TaskTemplateController();
    	tType = ApexPages.currentPage().getParameters().get('type');
    	controller.tType = 'Opportunity';
    	  		
    	controller.PRIMARY_CONTACT = 'primary';
    	controller.tabCategory = 'testdata';
    	controller.toggleField = true;
    	
    	PageReference testRef3 = controller.templateCancel();
    	controller.recordTypeId = temp1.id;
    	
    	PageReference testRef4 = controller.populateTextFieldsFromRecType();
    	
    	controller.recordId2Name =new Map<Id, String>();
    	controller.recordId2Name.put(temp1.id,insertRc);
    	testRef4 = controller.populateTextFieldsFromRecType();
    	controller.renderFields();
    	
    	controller.populatePageInformation();
    	//List<SelectOption> listoptions=controller.getRecordTypes();
   		//controller.populatePageInformation();
       	controller.templateSave();
        controller.objectNames = 'Opportunity';
    	controller.getContactFields();
    	controller.getThis();
    	system.assert(ApexPages.hasMessages());
    	
    	Test.stopTest();
	}
}