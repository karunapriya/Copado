@isTest
private class REN_RenewalMappingsComponentCtrlTest {

	static testMethod void Test_RenewalMappingsComponentController_Positive() {
		Test.startTest();
		REN_RenewalMappingsComponentController ctrl = new REN_RenewalMappingsComponentController();
		system.assert(ctrl.mappingOptionList != null);
		system.assert(!ctrl.mappingOptionList.isEmpty());
		system.assert(ctrl.mappingList != null);
		system.assert(!ctrl.mappingList.isEmpty());
		Test.stopTest();
	}
	
	static testMethod void Test_Cancel_Positive() {
		Test.startTest();
		REN_RenewalMappingsComponentController ctrl = new REN_RenewalMappingsComponentController();
		PageReference pageRef = ctrl.cancel();
		system.assert(pageRef != null);
		ctrl.selectedMapping = system.label.REN_RENEWAL_STAT_VAL_MAP;
		pageRef = ctrl.loadSelectedMapping();
		system.assert(pageRef != null);
		ctrl.selectedMapping = system.label.REN_LBL_OPPTY_TO_REN_OPPTY;
		pageRef = ctrl.loadSelectedMapping();
		system.assert(pageRef != null);
		Test.stopTest();
	}
	public static void callPageRefernce(String pageReference)
    {
		Apexpages.currentPage().getParameters().put('mappingname',pageReference);
        REN_RenewalMappingsComponentController ctrl=new REN_RenewalMappingsComponentController();        
    }
	static testMethod void Test_SaveMappings_Positive() {
       	Test.startTest();
        Apexpages.currentPage().getParameters().put('mappingname',system.label.REN_LBL_OPPTY_TO_REN_OPPTY);        
    	REN_RenewalMappingsComponentController controller = new REN_RenewalMappingsComponentController();
    	system.assert(controller.mappingOptionList != null);
		system.assert(!controller.mappingOptionList.isEmpty());
		system.assert(controller.mappingList != null);
		system.assert(!controller.mappingList.isEmpty());
    	system.assert(controller.getThis() != null);
    	REN_FieldMappingComponentController fmc = new REN_FieldMappingComponentController();
    	controller.setBaseChildController(fmc);
    	controller.setMappingToControllerMap(system.label.REN_LBL_OPPTY_TO_REN_OPPTY, controller.getBaseChildController());
    	controller.save();
    	REN_RelatedListComponentController rlcc = new REN_RelatedListComponentController();
    	controller.setBaseChildController(rlcc);
    	controller.setMappingToControllerMap(system.label.REN_LBL_OPPTY_TO_REN_OPPTY, controller.getBaseChildController());    	
        controller.selectedMapping = system.label.REN_LBL_OPPTY_TO_REN_OPPTY;                             
        controller.cancel();
        controller.loadSelectedMapping();
        controller.selectedMapping=system.label.REN_RENEWAL_STAT_VAL_MAP;
        controller.loadSelectedMapping();
        controller.selectedMapping=system.label.REN_PORejectList;
        controller.loadSelectedMapping();
        controller.selectedMapping=system.label.REN_PREVIOUS_PRICE_CALCULATION;
        controller.loadSelectedMapping();
        controller.save();        
        callPageRefernce(system.label.REN_LBL_ASSET_TO_OPLI);
        callPageRefernce(system.label.REN_LBL_OPPTY_TO_SC);
        callPageRefernce(system.label.REN_LBL_SC_TO_OPPTY);
        callPageRefernce(system.label.REN_LBL_OPLI_TO_ASSET);
        callPageRefernce(system.label.REN_LBL_RR_TO_OPLI);
        callPageRefernce(system.label.REN_LBL_OPLI_TO_RR);
        callPageRefernce(system.label.REN_LBL_OPP_TO_PO);
        callPageRefernce(system.label.REN_LBL_CASE_TO_CASE_QR);
        callPageRefernce(system.label.REN_LBL_QUOTE_TO_QUOTE);
        callPageRefernce(system.label.REN_LBL_QUOTE_TO_OPPTY);
		callPageRefernce(system.label.REN_LBL_OPPTY_TO_QUOTE);
    	Test.stopTest();
    }
    
}