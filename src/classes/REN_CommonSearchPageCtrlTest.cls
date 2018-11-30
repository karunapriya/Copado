@isTest
public with sharing class REN_CommonSearchPageCtrlTest {
    
    @testSetup 
    static void setup() {
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(3, accountList[0].id);
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
			partOppty.OpportunityId = opportunityList[0].id;
			partOppty.partnerAcc1Id = accountList[0].id ;
			partOppty.partnerAcc1Type = 'Reseller';
			partOppty.expirationDate= system.today().addDays(-10);
			partOppty.Stage= 'Needs Analysis';	
		CHL_Partner_Opportunity__c chlpartnerObj =   CHL_TestUtility.channelPartnerOpportunity(partOppty); 
		insert chlpartnerObj;
		system.assert(chlpartnerObj.Id != null);
        SS_Validations__c ssValidations = SS_Validations__c.getOrgDefaults();
    	ssValidations.REN_No_Split_allowed_for_Opp_Stage__c = 'Closed Sale';
    	upsert ssValidations;
    	String nameSpace = CSM_Util.getNamespace(); 
    	REN_Custom_Search_Config__c customSearchConfigRec = new REN_Custom_Search_Config__c();
	    customSearchConfigRec.Name = 'Opportunity';
	    customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	    customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace+'REN_Opportunity_Custom_Search';
	    customSearchConfigRec.REN_Related_Object__c = nameSpace + 'REN_Renews_To__c.' + nameSpace + 'REN_Renews_To__c';
	    insert customSearchConfigRec;
	    system.assert(customSearchConfigRec != null);
    }
    
	static testMethod void CommonSearchPage_PositiveTest() {
      	List<opportunity> oppList = [select id from opportunity];
      	ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
      	REN_CommonSearchPageCtrl ctrl = new REN_CommonSearchPageCtrl();
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Opportunity';
      	ctrl.selectedOpportunityIds = oppList[0].id;
        ctrl.redirectToConsolidate();
      	ctrl.consolidateOpportunity();
      	system.assert(ctrl != null);
	}
    static testMethod void CommonSearchPage_NegTest() {
      	List<opportunity> oppList = [select id from opportunity];
        oppList[0].stageName = 'Closed Sale';
        update oppList;
        REN_Custom_Search_Config__c customSearchConfigRec = REN_Custom_Search_Config__c.getOrgDefaults();
        delete customSearchConfigRec;
      	ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
      	REN_CommonSearchPageCtrl ctrl = new REN_CommonSearchPageCtrl();
        ctrl.selectedOpportunityIds = oppList[0].id;
        ctrl.consolidateOpportunity();
      	system.assert(ctrl != null);
	}
    static testMethod void CommonSearchNoResultTest() {
      	List<opportunity> oppList = [select id from opportunity];
      	ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
      	REN_CommonSearchPageCtrl ctrl = new REN_CommonSearchPageCtrl();
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Opportunity';
        REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
		assetLogicBuilder.logicBuilderInput = ctrl.logicBuilderInputWrapper;
		REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
		renewalLogicBuilder.logicBuilderInput = ctrl.logicBuilderInputWrapper;
		ctrl.callOnParentObjectChange();        
        ctrl.findFor();
        ctrl.noResultFound();
      	system.assert(ctrl != null);
	}
    static testMethod void CommonSearchNoResultNegTest() {
      	List<opportunity> oppList = [select id from opportunity];
      	ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
      	REN_CommonSearchPageCtrl ctrl = new REN_CommonSearchPageCtrl();
        ctrl.noResultFound();
      	system.assert(ctrl != null);
	}
    
}