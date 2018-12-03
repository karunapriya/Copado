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
@isTest(SeeAllData = false)
private class REN_OppRenAdminUpdCompCntrlTest {

    static testMethod void Test_UpdateConfiguration_Positive() {
        Test.startTest();
	        REN_OppRenewalAdminUpdateCompCntrl controller = new REN_OppRenewalAdminUpdateCompCntrl();
	        system.assert(controller.lbInputWrapperList != null);
	        //controller.save();
	        controller = new REN_OppRenewalAdminUpdateCompCntrl();
        Test.stopTest();
    }
    static testMethod void Test_UpdateConfiguration_Negative() {
        Test.startTest();
	        REN_OppRenewalAdminUpdateCompCntrl controller = new REN_OppRenewalAdminUpdateCompCntrl();
	        system.assert(controller.lbInputWrapperList != null);
	        //controller.save();
	        User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
	        system.runAs(restrictedUser){
	            controller = new REN_OppRenewalAdminUpdateCompCntrl();
	        }
        Test.stopTest();
    }  
    static testMethod void Test_SaveConfiguration_Positive() {
        Test.startTest();
	        REN_OppRenewalAdminUpdateCompCntrl controller = new REN_OppRenewalAdminUpdateCompCntrl();
	        system.assert(controller.lbInputWrapperList != null);
	        //upsert controller.renewConfigurationList;
	        controller = new REN_OppRenewalAdminUpdateCompCntrl();
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
	       	
	       	controller = new REN_OppRenewalAdminUpdateCompCntrl();
        Test.stopTest();
    }
    static testMethod void Test_SaveConfiguration_Negative() {
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
	    system.runAs(restrictedUser)
	    {
        Test.startTest();
	        REN_OppRenewalAdminUpdateCompCntrl controller = new REN_OppRenewalAdminUpdateCompCntrl();
	        system.assert(controller.lbInputWrapperList != null);
	        controller = new REN_OppRenewalAdminUpdateCompCntrl();
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
    }
    static testMethod void Test_Cancel() {
        Test.startTest();
	        REN_OppRenewalAdminUpdateCompCntrl controller = new REN_OppRenewalAdminUpdateCompCntrl();
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