@isTest
private class CSM_AccPlanTemplateOppTimeLineCtrlTest {

   
    static testMethod void existingAccountPlanTemplateTimeLineTest() {
        try{
	        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
	        CSM_Account_Plan_Template__c testAccTempObj = accountPlanTemplateList[0];
	        PageREference pageRef = Page.CSM_AccountPlanTemplate;
	        pageRef.getParameters().put(CSM_Constants.ID_PARAM, accountPlanTemplateList[0].id);
	    	Test.setCurrentPage(pageRef);
	    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
	    	CSM_AccountPlanTemplateOppTimeLineCtrl con = new CSM_AccountPlanTemplateOppTimeLineCtrl();
	    	con.CSM_AccountPlanTemplateController = controller;
	    	con.theAccountPlanTemplate = testAccTempObj;
	    	Test.startTest();
		    	con.getSemiColonSeparatedFields();
		    	con.selectedField ='CloseDate';
		    	con.addField();
		    	con.removeField();
		    	system.assertNotEquals(con.theAccountPlanTemplate,null);
	    	Test.stopTest();
        }catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
        
   }
    
     static testMethod void existingAccountPlanTemplateOppTest() {
        try{
	        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
	        CSM_Account_Plan_Template__c testAccTempObj = accountPlanTemplateList[0];
	       	PageREference pageRef = Page.CSM_AccountPlanTemplate;
	        pageRef.getParameters().put(CSM_Constants.ID_PARAM, accountPlanTemplateList[0].id);
	    	Test.setCurrentPage(pageRef);
	    	CSM_AccountPlanTemplateController controller = new CSM_AccountPlanTemplateController();
	    	CSM_AccountPlanTemplateOpp acctPlanTemplateOpp = new CSM_AccountPlanTemplateOpp();
	    	acctPlanTemplateOpp.CSM_AccountPlanTemplateController = controller;
	        acctPlanTemplateOpp.theAccountPlanTemplate = testAccTempObj;
	        system.assertNotEquals(acctPlanTemplateOpp.theAccountPlanTemplate,null);
        }catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
    
     }
}