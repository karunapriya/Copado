@isTest
public class REN_TaskTemplateBusinessLayerTest {    
    static testMethod void testBusinessLayer() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
        REN_Task_Template__c taskTemplateObj=new REN_Task_Template__c();
        taskTemplateObj.Name='TestTemplate';
        insert taskTemplateObj; 
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.params = gridParams;
        inputWrapper.params.selectedTaskFilter=taskTemplateObj.Id;
    	REN_TaskTemplateBusinessLayer businessLayer = new REN_TaskTemplateBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
   		system.assertEquals(responseWrapper.hasAction, true);
    	system.assertEquals(responseWrapper.hasCheckbox, false);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	Test.stopTest();
    }
}