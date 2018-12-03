@isTest
private class REN_DataGenerationAdminControllerTest {

   static testMethod void myUnitTest() {
     	try{
     		Test.startTest();
     		List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
	        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
	        upsert renewConfigurationList;
	     	REN_DataGenerationAdminController controller = new REN_DataGenerationAdminController();
	     	PageReference pageRef;
	     	pageRef = controller.cancel();	     	 
	     	System.assert( controller.getThis() != null);
	     	controller.tabCategory='Test';
	     	REN_FieldMappingComponentController fmc = new REN_FieldMappingComponentController();
	    	controller.setBaseChildController(fmc);
	    	controller.setBaseChildControllerMap('fmc', controller.getBaseChildController());
	    	//List<REN_Renew_Configuration__c> renewConfigListgetRenewConfigByTriggerType
	    	REN_Renew_Configuration__c assetRenConfigurationObj = controller.mapofConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
	     	system.debug('In d test : '+assetRenConfigurationObj);
	     	REN_Line_Criteria__c linecriteriaObj = new REN_Line_Criteria__c();
		     	linecriteriaObj.REN_Renew_Configuration__c = assetRenConfigurationObj.id;
		     	linecriteriaObj.RLM_LineNo__c = 1.0;
		     	linecriteriaObj.RLM_Field_Name__c = 'Name';
		     	linecriteriaObj.RLM_Field_Type__c = 'String';
		     	linecriteriaObj.RLM_Values__c = 'Test';
		     	linecriteriaObj.RLM_Operator__c = 'LIKE';
		     	linecriteriaObj.RLM_Object_API_Name__c  = REN_Constants.OBJ_OPPORTUNITY;
	     	insert linecriteriaObj;
	     	pageRef = controller.saveDataGeneration();
	     	pageRef = controller.manageMappings();
	     	System.assert(controller.getThis() != null);
	     	//controller.setBaseMainControllerMap('key', new REN_BaseMainController());
	     	//controller.setBaseMainController(controller.getBaseMainControllerMap().get('key'));
	     	//System.assert( controller.getBaseMainControllerMap() != null);
	     	//System.assert( controller.getBaseMainController() != null);
	     	Test.stopTest();	
	     	}catch(Exception e){
	     		system.debug('Exception : ' + e.getMessage());
	     	}
     }
     static testMethod void myUnitTest_withNoRenewconfigData() {
     	try{
     		Test.startTest();
     		REN_DataGenerationAdminController controller = new REN_DataGenerationAdminController();
	     	PageReference pageRef;
	     	pageRef = controller.cancel();	     	 
	     	System.assert( controller.getThis() != null);
	     	pageRef = controller.saveDataGeneration();
	     	Test.stopTest();	
	     	}catch(Exception e){
	     		system.debug('Exception : ' + e.getMessage());
	     	}
     }
}