@isTest
private class REN_ValueMappingCtrlTest {

    static testMethod void valueMappingCtrl_Positive() {
        REN_ValueMappingCtrl controller = new REN_ValueMappingCtrl();
        	Test.startTest();
        		Test.setCurrentPage(Page.REN_ValueMapping);
        		controller.thisController = new REN_BaseMainController();
        		system.assert(controller.getThis() != null);
    			REN_BaseMainController baseMainCtrl = controller.thisController;
    			REN_ValueMappingCompCtrl vmc = new REN_ValueMappingCompCtrl();
	        	controller.setBaseChildController(vmc);
	        	controller.setBaseChildControllerMap('vmc', controller.getBaseChildController());
	        	controller.tabCategory = 'Renewal';
        		PageReference pageRef = controller.saveValueMapping();
        		pageRef = controller.redirectToMappingsPage();
        	Test.stopTest();
    }
    static testMethod void valueMappingCtrl_Negative() {
        REN_ValueMappingCtrl controller = new REN_ValueMappingCtrl();
        	Test.startTest();
        		Test.setCurrentPage(Page.REN_ValueMapping);
        		controller.thisController = new REN_BaseMainController();
        		system.assert(controller.getThis() != null);
    			REN_BaseMainController baseMainCtrl = controller.thisController;
    			REN_ValueMappingCompCtrl vmc = new REN_ValueMappingCompCtrl();
	        	controller.setBaseChildController(vmc);
        		PageReference pageRef = controller.saveValueMapping();
        	Test.stopTest();
    }
}