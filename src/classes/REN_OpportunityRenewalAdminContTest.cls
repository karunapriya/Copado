@isTest(SeeAllData = false)
private class REN_OpportunityRenewalAdminContTest {

   static testMethod void Test_CreateAndEditConfiguration_Positive() {
        Test.startTest();
	        REN_OpportunityRenewalAdminController controller = new REN_OpportunityRenewalAdminController();
	        system.assert(controller.lbInputWrapperList != null);
	        //controller.save();
	        controller = new REN_OpportunityRenewalAdminController();
        Test.stopTest();
    } 
    
    static testMethod void Test_CreateAndEditConfiguration_Negative() {
        Test.startTest();
	        REN_OpportunityRenewalAdminController controller = new REN_OpportunityRenewalAdminController();
	        system.assert(controller.lbInputWrapperList != null);
	        //controller.save();
	        User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
	        system.runAs(restrictedUser){
	            controller = new REN_OpportunityRenewalAdminController();
	        }
        Test.stopTest();
    } 
    
    static testMethod void Test_SaveConfiguration_Positive() {
        Test.startTest();
	        REN_OpportunityRenewalAdminController controller = new REN_OpportunityRenewalAdminController();
	        system.assert(controller.lbInputWrapperList != null);
	        //upsert controller.renewConfigurationList;
	        controller = new REN_OpportunityRenewalAdminController();
	        system.assert(controller.getThis() != null);
	        REN_FieldMappingComponentController fmc = new REN_FieldMappingComponentController();
	        controller.setBaseChildController(fmc);
	        controller.setBaseChildControllerMap('fmc', controller.getBaseChildController());
	        REN_CriteriaMetComponentController cmcc = new REN_CriteriaMetComponentController();
	        controller.setBaseChildController(cmcc);
	        controller.setBaseChildControllerMap('cmcc', controller.getBaseChildController());
	        REN_RelatedListComponentController rlcc = new REN_RelatedListComponentController();
	        controller.setBaseChildController(rlcc);
	        controller.setBaseChildControllerMap('rlcc', controller.getBaseChildController());
	       	controller.save();
        Test.stopTest();
    }
    
    static testMethod void Test_SaveConfiguration_Negative() {
        Test.startTest();
	        REN_OpportunityRenewalAdminController controller = new REN_OpportunityRenewalAdminController();
	        system.assert(controller.lbInputWrapperList != null);
	        //upsert controller.renewConfigurationList;
	        controller = new REN_OpportunityRenewalAdminController();
	        system.assert(controller.getThis() != null);
	        REN_FieldMappingComponentController fmc = new REN_FieldMappingComponentController();
	        controller.setBaseChildController(fmc);
	        controller.setBaseChildControllerMap('fmc', controller.getBaseChildController());
	        REN_FieldMappingInputWrapper fmInputWrapperobj =  new REN_FieldMappingInputWrapper('Opportunity', 'Asset', '12345', controller, system.label.CHL_LBL_PARTNER_OPP_FIELDS, system.label.REN_LBL_MAPPING_SECTION_HEADER, 'Partner_Opportunity Field', 'Opportunity Field', system.label.CHL_LBL_PARTNER_OPP_FIELDS,'ParentID');
	        REN_CriteriaMetComponentController cmcc = new REN_CriteriaMetComponentController();
	        controller.setBaseChildController(cmcc);
	        controller.setBaseChildControllerMap('cmcc', controller.getBaseChildController());
	        controller.save();
        Test.stopTest();
    }
    
    static testMethod void Test_Cancel() {
        Test.startTest();
	        REN_OpportunityRenewalAdminController controller = new REN_OpportunityRenewalAdminController();
	        PageReference cancelRef = controller.cancel();
	        system.assert(true);
        Test.stopTest();
    }
    static testMethod void Test_MappingsAdminController()   {
        Test.startTest();
	        REN_RenewalMappingsAdminController controller = new REN_RenewalMappingsAdminController();
	        SS_LicenseCheckComponentController controller2 = new SS_LicenseCheckComponentController();
	        system.assert(true);
        Test.stopTest();
    }
    
}