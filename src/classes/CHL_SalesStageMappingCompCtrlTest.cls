@isTest
private class CHL_SalesStageMappingCompCtrlTest {
	@testSetup 
    static void setup() {
    	List<CHL_Sales_Stage_Mapping__c> mappingList = new List<CHL_Sales_Stage_Mapping__c>();     
   		CHL_Sales_Stage_Mapping__c salesStageMappingList = new CHL_Sales_Stage_Mapping__c();
   		salesStageMappingList.CHL_Master_Opportunity_Sales_Stage__c = 'Prospecting';
   		salesStageMappingList.CHL_Partner_Opportunity_Sales_Stage__c = 'Qualification';
   		salesStageMappingList.CHL_Partner_Opportunity_Type__c = 'All Partner Opportunities';
   		mappingList.add(salesStageMappingList);

   		insert mappingList;
   		system.assert(mappingList!=null);
    }
    static testMethod void testCompCtrl_Positive() {
    	PageReference pageRef = Page.CHL_ChannelPartnerAdmin;
    	Test.setCurrentPageReference(pageRef);
        CHL_SalesStageMappingCompCtrl controller = new CHL_SalesStageMappingCompCtrl();
        CHL_ChannelPartnerAdminPageCtrl mainCtrl = new CHL_ChannelPartnerAdminPageCtrl();
        String namespace = CSM_Util.getNamespace();
        Test.startTest();
        	CHL_SalesStageMappingWrapper wrapper = new CHL_SalesStageMappingWrapper('CHL_SalesStageMappingCompCtrl', mainCtrl,Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Master_Opportunity_Sales_Stage__c.label,
	        Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Partner_Opportunity_Sales_Stage__c.label,
	        Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Partner_Opportunity_Type__c.label,
	        'Opportunity','StageName',namespace+'CHL_Sales_Stage_Mapping__c',namespace+'CHL_Partner_Opportunity_Type__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Sales_Stage__c');
			controller.salesStageMappingWrp = wrapper;
			controller.performSave();
			pageRef = controller.addSalesStageMappingRow();
			controller.performSave();
			system.assert(controller.wrapSalesStageMapList!=null);
			controller.wrapSalesStageMapList.add(new CHL_SalesStageMappingCompCtrl.CHL_SalesStageMappingInternalWrapper('Prospecting',
																					'Qualification',
																					'All Partner Opportunities',
																					'1'));
			controller.performSave();
			controller = new CHL_SalesStageMappingCompCtrl();
			controller.salesStageMappingWrp = wrapper;
			controller.wrapSalesStageMapList.add(new CHL_SalesStageMappingCompCtrl.CHL_SalesStageMappingInternalWrapper('Prospecting',
																					'Prospecting',
																					'Winning Partner Opportunities',
																					'1'));
																					
			controller.performSave();
			
			controller.deleteRec = '1';
			pageRef = controller.removeFromList();
			controller.performSave();
			pageRef = Page.CHL_ChannelPartnerAdmin;
    		Test.setCurrentPageReference(pageRef);
			controller = new CHL_SalesStageMappingCompCtrl();
			controller.salesStageMappingWrp = wrapper;
			for(integer i = 0; i < controller.wrapSalesStageMapList.size(); i++){
				controller.wrapSalesStageMapList.remove(i);
			}
			controller.performSave();
			
        Test.stopTest();
    }
    static testMethod void testCompCtrl_Negative() {
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	PageReference pageRef = Page.CHL_ChannelPartnerAdmin;
    	Test.setCurrentPageReference(pageRef);
        CHL_SalesStageMappingCompCtrl controller = new CHL_SalesStageMappingCompCtrl();
        CHL_ChannelPartnerAdminPageCtrl mainCtrl = new CHL_ChannelPartnerAdminPageCtrl();
        String namespace = CSM_Util.getNamespace();
        Test.startTest();
        	CHL_SalesStageMappingWrapper wrapper = new CHL_SalesStageMappingWrapper('CHL_SalesStageMappingCompCtrl', mainCtrl,Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Master_Opportunity_Sales_Stage__c.label,
	        Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Partner_Opportunity_Sales_Stage__c.label,
	        Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Partner_Opportunity_Type__c.label,
	        'Opportunity','StageName',namespace+'CHL_Sales_Stage_Mapping__c',namespace+'CHL_Partner_Opportunity_Type__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Sales_Stage__c');
			controller.salesStageMappingWrp = wrapper;
			system.runAs(restrictedUser) {
				controller.performSave();
			}
			system.assert(controller.wrapSalesStageMapList!=null);
        Test.stopTest();
    }
    
}