@isTest
private class REN_LogicBuilderCmpCtrlTest {

	public static REN_Renew_Configuration__c rConfigObj = new REN_Renew_Configuration__c(); 
	public static  List<REN_Line_Criteria__c> lineCriteriaList;
	public static CSM_Focus_Category_View__c focusCategoryView = new CSM_Focus_Category_View__c();

	static void focusviewSetup() {
		focusCategoryView = CSM_TestUtility.insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 
		'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue');
		
		List<CSM_Focus_Category_View_Criteria__c> focusCategoryViewCriteriaList = new List<CSM_Focus_Category_View_Criteria__c>(); 
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = CSM_TestUtility.createFCVCriteria('BillingCity', 'Billing City', 'String', 'IN', 'Test', focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria);
		
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria2 = CSM_TestUtility.createFCVCriteria('BillingCity', 'Billing City', 'String', '=', 'Test', focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria2);
		
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria3 = CSM_TestUtility.createFCVCriteria('Multi', 'Multi', 'MULTIPICKLIST', 'INCLUDES', 'Test', focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria3);
		
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria4 = CSM_TestUtility.createFCVCriteria('CreatedDate', 'Created Date', 'DATETIME', '=', null, focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria4);
		
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria5 = CSM_TestUtility.createFCVCriteria('Boolean_Test', 'Boolean Test', 'Boolean', '=', 'true', focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria5);
		
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria6 = CSM_TestUtility.createFCVCriteria('Double_Test', 'Double Test', 'Double', '=', null, focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria6);
		
		CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria7 = CSM_TestUtility.createFCVCriteria('ClosedDate', 'Close Date', 'DATE', '=', null, focusCategoryView.Id);
		focusCategoryViewCriteriaList.add(focusCategoryViewCriteria7);
		
		insert focusCategoryViewCriteriaList;
	}

	static public void setup() {
		Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
		renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,rConfigObj);
		rConfigObj = REN_TestDataUtility.createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false', renewConfigurationMap);
		insert rConfigObj;
		
		rConfigObj.RLM_Currency_Code__c = 'EUR';
        update rConfigObj;
		
		lineCriteriaList = new List<REN_Line_Criteria__c>();
		
		REN_Line_Criteria__c lineCriteriaObj1 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2',
																						'CreatedDate',CSM_Constants.TYPE_DATETIME,null,System.Today(),
																						'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj1); 
		
		REN_Line_Criteria__c lineCriteriaObj2 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Test Name',
																						'INTEGER','100',null,'IN',false,'',null,rConfigObj.Id, null);
		
		lineCriteriaList.add(lineCriteriaObj2); 
		
		REN_Line_Criteria__c lineCriteriaObj3 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','TestName',
																						'DOUBLE','100',null,'>',false,'',null,rConfigObj.Id, null);
		  
		lineCriteriaList.add(lineCriteriaObj3);    
		
		REN_Line_Criteria__c lineCriteriaObj4 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DatFld',
																						'DATE','100',null,'ALL',false,'',null,rConfigObj.Id, null);
		
		lineCriteriaList.add(lineCriteriaObj4);
		
		REN_Line_Criteria__c lineCriteriaObj5 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Asset','CreatedById',
																						'REFERENCE',null,null,'=',false,'',null,rConfigObj.Id, null);
		  
		lineCriteriaList.add(lineCriteriaObj5);
		
		REN_Line_Criteria__c lineCriteriaObj6 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Asset','AccountId.CreatedById',
																						'REFERENCE',null,null,'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj6);
				
		REN_Line_Criteria__c lineCriteriaObj7 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','MULTI',
																						'MULTIPICKLIST','Test',null,'INCLUDES',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj7);  
		
		REN_Line_Criteria__c lineCriteriaObj8 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','CloseDate',
																						'DATE',null,System.Today(),'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj8); 
		
		REN_Line_Criteria__c lineCriteriaObj9 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Number1',
																						'INTEGER','100',null,'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj9);
		
		REN_Line_Criteria__c lineCriteriaObj10 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Number1',
																						'Boolean','true',null,'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj10);
		
		REN_Line_Criteria__c lineCriteriaObj11 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Name',
																						'String','Test',null,'LIKE',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj11);
		
		REN_Line_Criteria__c lineCriteriaObj12 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateField',
																						'Date',null,null,'>',true,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj12);
		
		REN_Line_Criteria__c lineCriteriaObj13 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Name',
																						'String','',null,'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj13); 
		
		REN_Line_Criteria__c lineCriteriaObj14 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateField',
																						'Date',null,System.Today(),'=',true,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj14);
		
		REN_Line_Criteria__c lineCriteriaObj15 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Name',
																						'Date','ab',null,'LIKE',false,'Last_N_Weeks',null,rConfigObj.Id, null);
		
		lineCriteriaList.add(lineCriteriaObj15);
		  
		REN_Line_Criteria__c lineCriteriaObj16 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateField',
																						'Date',null,null,'>',false,'Last_N_Weeks',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj16);
		
		REN_Line_Criteria__c lineCriteriaObj17 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateField',
																						'Date',null,null,'null',false,'Last_N_Weeks',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj17);
		
		REN_Line_Criteria__c lineCriteriaObj18 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','Name',
																						'String','ab',null,'=',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj18);
		
		REN_Line_Criteria__c lineCriteriaObj19 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','MULTI',
																						'MULTIPICKLIST','[]',null,'INCLUDES',false,'',null,rConfigObj.Id, null);
		lineCriteriaList.add(lineCriteriaObj19);
		
		REN_Line_Criteria__c lineCriteriaObj20 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateTimeField',
																						'DATETIME',null,null,'=',false,'',null,rConfigObj.Id, system.now());
		lineCriteriaList.add(lineCriteriaObj20);
		
		REN_Line_Criteria__c lineCriteriaObj21 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateTimeField',
																						'DATETIME',null,null,'>',false,'',null,rConfigObj.Id, system.now());
		lineCriteriaList.add(lineCriteriaObj21);
		
		REN_Line_Criteria__c lineCriteriaObj22 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateTimeField',
																						'DATETIME',null,null,'<',false,'',null,rConfigObj.Id, system.now());
		lineCriteriaList.add(lineCriteriaObj22);
		
		REN_Line_Criteria__c lineCriteriaObj23 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateTimeField',
																						'DATETIME',null,null,'<=',false,'',null,rConfigObj.Id, system.now());
		lineCriteriaList.add(lineCriteriaObj23);
		
		REN_Line_Criteria__c lineCriteriaObj24 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateTimeField',
																						'DATETIME',null,null,'>=',false,'',null,rConfigObj.Id, system.now());
		lineCriteriaList.add(lineCriteriaObj24);
		
		REN_Line_Criteria__c lineCriteriaObj25 = REN_TestDataUtility.createLineCriteria('Line Criteria Test','Product 1','Product2','DateTimeField',
																						'DATETIME',null,null,'!=',false,'',null,rConfigObj.Id, system.now());
		lineCriteriaList.add(lineCriteriaObj25);
		
		insert lineCriteriaList;
	}
	
	static testMethod void performFindTest() {
		setup();
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
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
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
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
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
		system.assert(rConfigObj != null);
		ctrl.criteriaWrapperList = new List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper>();
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
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
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
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
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
	
	static testMethod void lastFldRltedObjNameTest() {
		String relObjName;
		List<String> fieldList = new List<String>{CSM_Util.getNamespace()+'REN_Opportunity__r','AccountId'}; 
		Test.startTest();
		relObjName = REN_LogicBuilderCmpCtrl.lastFldRltedObjName('Asset',fieldList);
		Test.stopTest();
		system.assertEquals(relObjName,'Opportunity');
	}
	
	static testMethod void performSaveWithSetupData() {
		setup();
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
		system.assert(rConfigObj != null);
		ctrl.criteriaWrapperList = new List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper>();
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
	
	static testMethod void savewithFocusCategoryView1() {
		focusviewSetup();
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
        ctrl.criteriaWrapperList = new List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper>();
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
	
	static testMethod void savewithFocusCategoryViewTest() {
		focusviewSetup();
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA, 'Account', 
																				REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,
																				basemain,'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		ctrl.performSave();
		ctrl.rerenderTable();
		Test.stopTest();
	}
	
	static testMethod void newCriteriaTest() {
		focusviewSetup();
		CSM_TestUtility.insertFCVCriteria(focusCategoryView.id);
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
		//ctrl.renewConfigObj = rConfigObj;
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbiw = new REN_LogicBuilderInputWrapper(focusCategoryView,CSM_Constants.OBJ_FCV_CRITERIA, 'Account', 
		REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, false,basemain,
		'','refreshLB1', 'onChangeDate1');
		ctrl.logicBuilderInput = lbiw;
		Test.startTest();
		ctrl.newCriteria();
		Test.stopTest();
	}
	
	static testMethod void newPlayCriteriaTest() {
		CSM_Play__c play = CSM_TestUtility.insertPlayWithoutInsert();
		insert play;
		CSM_TestUtility.insertPlayCriteria(play.id);
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbInputWrapper = new REN_LogicBuilderInputWrapper(play,CSM_Constants.OBJ_PLAY_CRIT,play.CSM_Object_Name__c,'pl1',false,basemain,'', 'refreshLB1', 'onChangeDate1');				    																	    
		ctrl.logicBuilderInput = lbInputWrapper;
		Test.startTest();
		ctrl.newCriteria();
		Test.stopTest();
	}
	
	static testMethod void savePlayCriteriaTest() {
		CSM_Play__c play = CSM_TestUtility.insertPlayWithoutInsert();
		insert play;
		CSM_TestUtility.insertPlayCriteria(play.id);
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbInputWrapper = new REN_LogicBuilderInputWrapper(play,CSM_Constants.OBJ_PLAY_CRIT,play.CSM_Object_Name__c,'pl1',false,basemain,'', 'refreshLB1', 'onChangeDate1');				    																	    
		ctrl.logicBuilderInput = lbInputWrapper;
		Test.startTest();
		ctrl.performSave();
		Test.stopTest();
		List<csm_play_criteria__c> lstPlayC = [select Id from csm_play_criteria__c where csm_play__c =: play.Id];
		system.assert(lstPlayC.size() > 0);
		
	}
	
	static testMethod void deletePlayCriteriaTest() {
		CSM_Play__c play = CSM_TestUtility.insertPlayWithoutInsert();
		insert play;
		CSM_TestUtility.insertPlayCriteria(play.id);
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
		system.assert(focusCategoryView != null);
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbInputWrapper = new REN_LogicBuilderInputWrapper(play,CSM_Constants.OBJ_PLAY_CRIT,play.CSM_Object_Name__c,'pl1',false,basemain,'', 'refreshLB1', 'onChangeDate1');				    																	    
		ctrl.logicBuilderInput = lbInputWrapper;
		List<CSM_Play_Criteria__c> criteriaList = [Select id From CSM_Play_Criteria__c Where CSM_Play__c =: play.id];
		Test.startTest();
		CSM_PlayCriteriaDataAccess.deletePlayCriteria(criteriaList);
		Test.stopTest();
	}	
	
	static testMethod void saveWithoutPlayCriteriaTest() {
		CSM_Play__c play = CSM_TestUtility.insertPlayWithoutInsert();
		insert play;
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
		REN_OpportunityRenewalAdminController  basemain = new REN_OpportunityRenewalAdminController();
		REN_LogicBuilderInputWrapper lbInputWrapper = new REN_LogicBuilderInputWrapper(play,CSM_Constants.OBJ_PLAY_CRIT,play.CSM_Object_Name__c,'pl1',false,basemain,'', 'refreshLB1', 'onChangeDate1');				    																	    
		ctrl.logicBuilderInput = lbInputWrapper;
		Test.startTest();
		ctrl.performSave();
		Test.stopTest();
		List<csm_play_criteria__c> lstPlayC = [select Id from csm_play_criteria__c where csm_play__c =: play.Id];
		system.assert(lstPlayC.size() == 0);
		
	}
	static testMethod void saveWithExceptionTest() {
		focusviewSetup();
		CSM_TestUtility.insertFCVCriteria(focusCategoryView.id);
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();
        ctrl.criteriaWrapperList = new List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper>();
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
		REN_LogicBuilderCmpCtrl ctrl =  new REN_LogicBuilderCmpCtrl();	
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
		Test.startTest();
		String result = lBHObj.buildWhereCriteriaString(lineCriteriaList,rConfigObj);
		Test.stopTest();
		system.assert(result!= null);
		//Added below debug just to only use lable created for Quote Import for temporary purpose
		system.debug('Temp ------'+Label.REN_LBL_SELECT_QOUTE_IMPORT_TEMPLATE);
	}
	
}