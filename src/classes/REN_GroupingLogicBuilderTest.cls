@isTest
public with sharing class REN_GroupingLogicBuilderTest {
	public static REN_Renew_Configuration__c rConfigObj = new REN_Renew_Configuration__c(); 
	public static  List<REN_Line_Criteria__c> lineCriteriaList;
	public static CSM_Focus_Category_View__c focusCategoryView = new CSM_Focus_Category_View__c();
	public static CSM_Play__c playObj = new CSM_Play__c();
	public static REN_Renew_Configuration__c objLC = new REN_Renew_Configuration__c();
	
	static void focusviewSetup() {
		focusCategoryView = CSM_TestUtility.insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 
		'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue');
		
	}

	static public void setup() {
		Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
		renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,rConfigObj);
		rConfigObj = REN_TestDataUtility.createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false', renewConfigurationMap);
		insert rConfigObj;
		
		lineCriteriaList = new List<REN_Line_Criteria__c>();
		
		REN_Line_Criteria__c lineCriteriaObj1 = new REN_Line_Criteria__c();
		lineCriteriaObj1.Name = 'Line Criteria Test';
		lineCriteriaObj1.RLM_Criteria__c = 'Product 1';
		lineCriteriaObj1.RLM_Values__c = 'Name';
		lineCriteriaObj1.RLM_Object_API_Name__c = 'Product2';
		lineCriteriaObj1.RLM_Field_Name__c = 'Name';
		lineCriteriaObj1.RLM_Field_Type__c = 'DATE';
		lineCriteriaObj1.RLM_Date_Value__c = null;
		lineCriteriaObj1.RLM_Operator__c = 'LIKE';
		lineCriteriaObj1.RLM_Is_Specific_Date__c = false;
		lineCriteriaObj1.RLM_Date_Literal_String__c = '';
		lineCriteriaObj1.REN_Renew_Configuration__c = rConfigObj.Id;  
		lineCriteriaList.add(lineCriteriaObj1);  
		
		REN_Line_Criteria__c lineCriteriaObj2 = new REN_Line_Criteria__c();
		lineCriteriaObj2.Name = 'Line Criteria Test';
		lineCriteriaObj2.RLM_Criteria__c = 'Product 1';
		lineCriteriaObj2.RLM_Values__c = '100';
		lineCriteriaObj2.RLM_Object_API_Name__c = 'Product2';
		lineCriteriaObj2.RLM_Field_Name__c = 'Name';
		lineCriteriaObj2.RLM_Field_Type__c = 'INTEGER';
		lineCriteriaObj2.RLM_Date_Value__c = null;
		lineCriteriaObj2.RLM_Operator__c = '>';
		lineCriteriaObj2.RLM_Is_Specific_Date__c = false;
		lineCriteriaObj2.RLM_Date_Literal_String__c = '';
		lineCriteriaObj2.REN_Renew_Configuration__c = rConfigObj.Id;  
		lineCriteriaList.add(lineCriteriaObj2); 
		
		REN_Line_Criteria__c lineCriteriaObj3 = new REN_Line_Criteria__c();
		lineCriteriaObj3.Name = 'Line Criteria Test';
		lineCriteriaObj3.RLM_Criteria__c = 'Product 1';
		lineCriteriaObj3.RLM_Values__c = '100';
		lineCriteriaObj3.RLM_Object_API_Name__c = 'Product2';
		lineCriteriaObj3.RLM_Field_Name__c = 'Name';
		lineCriteriaObj3.RLM_Field_Type__c = 'DOUBLE';
		lineCriteriaObj3.RLM_Date_Value__c = null;
		lineCriteriaObj3.RLM_Operator__c = '>';
		lineCriteriaObj3.RLM_Is_Specific_Date__c = false;
		lineCriteriaObj3.RLM_Date_Literal_String__c = '';
		lineCriteriaObj3.REN_Renew_Configuration__c = rConfigObj.Id;  
		lineCriteriaList.add(lineCriteriaObj3);    
		
		REN_Line_Criteria__c lineCriteriaObj4 = new REN_Line_Criteria__c();
		lineCriteriaObj4.Name = 'Line Criteria Test';
		lineCriteriaObj4.RLM_Criteria__c = 'Product 1';
		lineCriteriaObj4.RLM_Object_API_Name__c = 'Product2';
		lineCriteriaObj4.RLM_Field_Name__c = 'Name';
		lineCriteriaObj4.RLM_Field_Type__c = 'DATE';
		lineCriteriaObj4.RLM_Date_Value__c = null;
		lineCriteriaObj4.RLM_Operator__c = '=';
		lineCriteriaObj4.RLM_Is_Specific_Date__c = false;
		lineCriteriaObj4.RLM_Date_Literal_String__c = '';
		lineCriteriaObj4.REN_Renew_Configuration__c = rConfigObj.Id;  
		lineCriteriaList.add(lineCriteriaObj4);
		
		REN_Line_Criteria__c lineCriteriaObj5 = new REN_Line_Criteria__c();
		lineCriteriaObj5.Name = 'Line Criteria Test';
		lineCriteriaObj5.RLM_Criteria__c = 'Product 1';
		lineCriteriaObj5.RLM_Object_API_Name__c = 'Asset';
		lineCriteriaObj5.RLM_Field_Name__c = 'CreatedById';
		lineCriteriaObj5.RLM_Field_Type__c = 'REFERENCE';
		lineCriteriaObj5.RLM_Date_Value__c = null;
		lineCriteriaObj5.RLM_Operator__c = '=';
		lineCriteriaObj5.RLM_Is_Specific_Date__c = false;
		lineCriteriaObj5.RLM_Date_Literal_String__c = '';
		lineCriteriaObj5.REN_Renew_Configuration__c = rConfigObj.Id;  
		lineCriteriaList.add(lineCriteriaObj5);
		
		REN_Line_Criteria__c lineCriteriaObj6 = new REN_Line_Criteria__c();
		lineCriteriaObj6.Name = 'Line Criteria Test';
		lineCriteriaObj6.RLM_Criteria__c = 'Product 1';
		lineCriteriaObj6.RLM_Object_API_Name__c = 'Asset';
		lineCriteriaObj6.RLM_Field_Name__c = 'AccountId.CreatedById';
		lineCriteriaObj6.RLM_Field_Type__c = 'REFERENCE';
		lineCriteriaObj6.RLM_Date_Value__c = null;
		lineCriteriaObj6.RLM_Operator__c = '=';
		lineCriteriaObj6.RLM_Is_Specific_Date__c = false;
		lineCriteriaObj6.RLM_Date_Literal_String__c = '';
		lineCriteriaObj6.REN_Renew_Configuration__c = rConfigObj.Id;  
		lineCriteriaList.add(lineCriteriaObj6);
		insert lineCriteriaList;
		system.assert(lineCriteriaList != null);
	}
	
	static testMethod void performFindTest() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(rConfigObj,REN_Constants.OBJ_LC, 'Opportunity', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		system.assert(rConfigObj != null);
		Test.startTest();
		ctrl.performFind();
		Test.stopTest();
	}
	
	static testMethod void performSaveTest() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(rConfigObj,REN_Constants.OBJ_LC, 'Opportunity', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		system.assert(rConfigObj != null);
		Test.startTest();
		ctrl.performSave();
		Test.stopTest();
	} 

	static testMethod void refreshLogicBuilder() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		system.assert(rConfigObj != null);
		ctrl.criteriaWrapperList = null;
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(rConfigObj,REN_Constants.OBJ_LC, 'Product2', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		Boolean maxCriteria = ctrl.isMaxCriteriaReached;
		Test.startTest();
		ctrl.refreshLogicBuilder();
		Test.stopTest();
	}
	static testMethod void getRelatedObjFldsTest() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw =new REN_LogicBuilderInputWrapper(rConfigObj,REN_Constants.OBJ_LC, 'Asset', 'recordKeyName',
		 																	false, basemain, '', 'refreshLB1', 'onChangeDate1',true,'AccountId');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		List<SelectOption> fieldList = ctrl.getFieldList();
		Test.stopTest();
		Boolean optContainsAccountFld = false;
		for(SelectOption opt : fieldList){
			if(opt != null && opt.getValue()!= null)
				if(opt.getValue().contains('Account.')){
					optContainsAccountFld = true;
					break;
				}
		}
		system.assert(optContainsAccountFld);
	}
	
	static testMethod void getSpannedRelatedObjFldsTest() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw =new REN_LogicBuilderInputWrapper(rConfigObj,REN_Constants.OBJ_LC, 'Asset', 'recordKeyName',
																			false, basemain, '', 'refreshLB1', 'onChangeDate1',true,
																			'ContactId.AccountId');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		List<SelectOption> fieldList = ctrl.getFieldList();
		Test.stopTest();
		Boolean optContainsAccountFld = false;
		for(SelectOption opt : fieldList){
			if(opt != null && opt.getValue()!= null)
				if(opt.getValue().contains('Account.')){
					optContainsAccountFld = true;
					break;
				}
		}
		
		system.assert(optContainsAccountFld);
	}
	
	static testMethod void performSaveWithSetupData() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		system.assert(rConfigObj != null);
		ctrl.criteriaWrapperList = null;
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(rConfigObj,REN_Constants.OBJ_LC, 'Product2',
																				REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,
																				basemain,'','refreshLB1', 'onChangeDate1',true,'');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		ctrl.performSave();
		Test.stopTest();
		List<REN_Line_Criteria__c> criteriaList = [Select id From REN_Line_Criteria__c Where REN_Renew_Configuration__c =: rConfigObj.id];
	}
	
	
	static testMethod void newCriteriaTest() {
		focusviewSetup();
		CSM_TestUtility.insertFCVCriteria(focusCategoryView.id);
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();	
		//ctrl.renewConfigObj = rConfigObj;
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA, 'Account', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		ctrl.newCriteria();
		lbiw = new REN_LogicBuilderInputWrapper(playObj,CSM_Constants.OBJ_PLAY_CRIT, 'Account', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		ctrl.newCriteria();
		lbiw = new REN_LogicBuilderInputWrapper(objLC,REN_Constants.OBJ_LC, 'Account', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		ctrl.newCriteria();
		Test.stopTest();
	}
	
	
	static testMethod void performSaveCriteriaTest() {
		CSM_Play__c play = CSM_TestUtility.insertPlayWithoutInsert();
		insert play;
		system.assert(play != null);
		CSM_TestUtility.insertPlayCriteria(play.id);
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();	
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbInputWrapper = new REN_LogicBuilderInputWrapper(play,CSM_Constants.OBJ_PLAY_CRIT,play.CSM_Object_Name__c,'pl1',false,basemain,'', 'refreshLB1', 'onChangeDate1');				    																	    
		ctrl.logicBuilderInput = lbInputWrapper;
		Test.startTest();
		ctrl.performSave();
		Test.stopTest();
	}
	
	static testMethod void saveWithExceptionTest() {
		focusviewSetup();
		CSM_TestUtility.insertFCVCriteria(focusCategoryView.id);
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();	
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		//focusCategoryView has soql of account , passing logicBuilderObject as 'Product2' to generate exception 
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA, 'Product2', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		ctrl.performSave();
		Test.stopTest();
	}
	
	static testMethod void deleteCriteriaTest() {
		focusviewSetup();
		CSM_TestUtility.insertFCVCriteria(focusCategoryView.id);
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();	
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA, 'Account', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		ctrl.guidToCompare = ctrl.criteriaWrapperList[0].guid;
		Test.startTest();
		ctrl.deleteCriteria();
		Test.stopTest();
	}
	
	
	static testMethod void logicBHTest2() {
		setup();
		REN_LogicBuilderValidationHelper lBHObj = new REN_LogicBuilderValidationHelper();
		lBHObj.validateFilterLogic('1',lineCriteriaList);
		rConfigObj.REN_Record_Key__c=REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT;
		rConfigObj.RLM_Filter_Logic__c='1';
		system.assert(rConfigObj != null);
		Test.startTest();
		lBHObj.buildWhereCriteriaString(lineCriteriaList,rConfigObj);
		Test.stopTest();
	}
	static testMethod void operatorListTest() {
		setup();
		REN_GroupingLogicBuilder ctrl =  new REN_GroupingLogicBuilder();
		system.assert(ctrl != null);
		Test.startTest();
		ctrl.getOperatorList();
		ctrl.getFieldList();
		Test.stopTest();
	}
}