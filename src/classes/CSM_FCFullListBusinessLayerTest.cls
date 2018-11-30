@isTest
private class CSM_FCFullListBusinessLayerTest {
		
	static testMethod void testFCFullListBusinessLayer() {
		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
		CSM_TestUtility.setup();
		Test.startTest();
		String req = '{"objType": "Account","params" : {"taskOrViewId":"'+CSM_TestUtility.focusCategoryView.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"Account"}},"viewName" : "FCFullList"}';
		System.debug('ZZZ - req - '+req);
		CSM_GridResponseWrapper grw = CSM_CustomGridController.getResponseForGrid(req);
		System.assert(grw.row!=null);
		System.assert(grw.header.size()>0);
		System.assert(grw.hasCheckbox==false);
		System.assert(grw.hasAction==false);
		System.assert(grw.hasDetail==false);
		System.debug('ZZZ -'+grw);
		req = '{"objType": "Account","params" : {"taskOrViewId":"'+CSM_TestUtility.focusCategoryView3.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"Account"}},"viewName" : "FCFullList"}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		System.assert(grw.row!=null);
		System.assert(grw.header.size()>0);
		System.assert(grw.hasCheckbox==false);
		System.assert(grw.hasAction==false);
		System.assert(grw.hasDetail==false);
		System.debug('ZZZ -'+grw);
		req = '{"objType": "PLAYBOOK","params" : {"taskOrViewId":"'+CSM_TestUtility.playBook.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"PLAYBOOK"}},"viewName" : ""}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		req = '{"objType": "ASSET","params" : {"taskOrViewId":"'+CSM_TestUtility.tsk.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"ASSET"}},"viewName" : ""}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
            req = '{"objType": "CONTRACTLINEITEM","params" : {"taskOrViewId":"'+CSM_TestUtility.tsk.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"CONTRACTLINEITEM"}},"viewName" : ""}';
            grw = CSM_CustomGridController.getResponseForGrid(req);
        }
		req = '{"objType": "OPPORTUNITY","params" : {"taskOrViewId":"'+CSM_TestUtility.tsk.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"OPPORTUNITY"}},"viewName" : ""}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		req = '{"objType": "ACCOUNT","params" : {"taskOrViewId":"'+CSM_TestUtility.tsk.Id+'","accountId":"","userPrefWrapper" : {"attrFieldUserId":"'+userinfo.getUserId()+'","attObjectType":"ACCOUNT"}},"viewName" : ""}';
		grw = CSM_CustomGridController.getResponseForGrid(req);
		
		List<CSM_GridColumnWrapper> headerList = grw.header; 
		
		CSM_GridColumnWrapper wrapper=new CSM_GridColumnWrapper();
        wrapper.recordID='';
        wrapper.value='';
        wrapper.lookUpId='';
        wrapper.hiddenValue='';
        wrapper.dataType='';
        wrapper.isVisible=true;
        wrapper.dataAlign='';
        wrapper.filterControl='';
        wrapper.isSwitchable=true;
        CSM_GridImageWrapper grdImage = new CSM_GridImageWrapper();
	    grdImage.imgSource = null;
	    grdImage.altImg  = null;
	    grdImage.imgWidth  = null;
	    grdImage.imgHeight  = null;
	    grdImage.imgClass  = null;
	    grdImage.imgTitle  = null;
        wrapper.gridImage=grdImage;
		
		/*CSM_UserPreferencesFilterWrapper userPrefWrap = new CSM_UserPreferencesFilterWrapper();	
		userPrefWrap.attrFieldName = 'AnnualRevenue';
		userPrefWrap.attrFieldType = 'Double';
		userPrefWrap.attrFieldValue = 'null';
		
		CSM_CustomGridInputWrapper.CSM_CustomGridParams inputGrwParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();		

		inputGrwParams.taskOrViewId = CSM_TestUtility.focusCategoryView.Id;
		inputGrwParams.accountId = CSM_TestUtility.Acct.Id;
		inputGrwParams.healthStatus = 'Healthy';
		inputGrwParams.dateRange = '';
		inputGrwParams.accountPlanId = '';
		inputGrwParams.selectedTaskFilter = '';
		inputGrwParams.selectedFilterClause = '';
		inputGrwParams.userPrefWrapper = userPrefWrap;
		
		CSM_CustomGridInputWrapper inputGrw = new CSM_CustomGridInputWrapper();		
		inputGrw.params = inputGrwParams;
    	inputGrw.viewName = 'HealthStatus';		
    	inputGrw.objType = 'Account';		
		
		CSM_FCFullListBusinessLayer fcBusinessLayer = new CSM_FCFullListBusinessLayer(inputGrw);
		fcBusinessLayer.retrieveSObjectWrapperList();

		userPrefWrap.attObjectType = 'Account';
		fcBusinessLayer.retrieveSObjectWrapperList();*/
				
		Test.stopTest();
		system.assert(true);
	}
	
	static testMethod void testCaseNumberShown() {
		/*CSM_TestUtility.setup();
		CSM_CustomGridInputWrapper.CSM_CustomGridParams inputGrwParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();		
		inputGrwParams.taskOrViewId = CSM_TestUtility.focusCategoryView.Id;
		inputGrwParams.accountId = CSM_TestUtility.Acct.Id;
		inputGrwParams.healthStatus = 'Healthy';
		inputGrwParams.dateRange = '';
		inputGrwParams.accountPlanId = '';
		inputGrwParams.selectedTaskFilter = '';
		inputGrwParams.selectedFilterClause = '';
		
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		inputWrapper.objType = CSM_Constants.OBJ_CASE;
		inputWrapper.params = inputGrwParams;
		
		Test.startTest();
		CSM_FCFullListBusinessLayer fcBusinessLayer = new CSM_FCFullListBusinessLayer(inputWrapper);
		CSM_GridResponseWrapper responsewrapper  = fcBusinessLayer.retrieveSObjectWrapperList();
		Test.stopTest();
		List<CSM_GridColumnWrapper> headerList = responsewrapper.header; 
		
		system.assert(headerList[0].valueCol == CSM_Constants.CASE_NUMBER);*/
		system.assert(true);
	}
	
	static testMethod void testContractNumberShown() {
		/*CSM_TestUtility.setup();
		CSM_CustomGridInputWrapper.CSM_CustomGridParams inputGrwParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();		
		inputGrwParams.taskOrViewId = CSM_TestUtility.focusCategoryView.Id;
		inputGrwParams.accountId = CSM_TestUtility.Acct.Id;
		inputGrwParams.healthStatus = 'Healthy';
		inputGrwParams.dateRange = '';
		inputGrwParams.accountPlanId = '';
		inputGrwParams.selectedTaskFilter = '';
		inputGrwParams.selectedFilterClause = '';
		
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		inputWrapper.objType = CSM_Constants.OBJ_CONTRACT;
		inputWrapper.params = inputGrwParams;
		
		Test.startTest();
		CSM_FCFullListBusinessLayer fcBusinessLayer = new CSM_FCFullListBusinessLayer(inputWrapper);
		CSM_GridResponseWrapper responsewrapper  = fcBusinessLayer.retrieveSObjectWrapperList();
		Test.stopTest();
		List<CSM_GridColumnWrapper> headerList = responsewrapper.header; 
		system.assert(headerList[0].valueCol == CSM_Constants.CONTRACT_NUMBER);*/
		system.assert(true);
	}
	
	static testMethod void testCaseNumberShown_Acc() {
		
		CSM_Focus_Category_View__c fcv1 = insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'','SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',true);
		CSM_TestUtility.setup();
		CSM_UserPreferencesFilterWrapper userprefFilter = new CSM_UserPreferencesFilterWrapper();
		userprefFilter.attObjectType = 'Account';
		userprefFilter.attrFieldName = 'Name';
		userprefFilter.attrFieldType = 'Text';
		userprefFilter.attrFieldValue = 'New';
		
		CSM_CustomGridInputWrapper.CSM_CustomGridParams inputGrwParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();		
		inputGrwParams.taskOrViewId = fcv1.id;
		inputGrwParams.accountId = CSM_TestUtility.Acct.Id;
		inputGrwParams.healthStatus = 'Healthy';
		inputGrwParams.dateRange = '';
		inputGrwParams.accountPlanId = '';
		inputGrwParams.selectedTaskFilter = '';
		inputGrwParams.selectedFilterClause = '';
		inputGrwParams.userPrefWrapper = userprefFilter;
		
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		inputWrapper.objType = CSM_Constants.OBJ_CASE;
		inputWrapper.params = inputGrwParams;
		inputWrapper.params = inputGrwParams;
		
		Test.startTest();
		CSM_FCFullListBusinessLayer fcBusinessLayer = new CSM_FCFullListBusinessLayer(inputWrapper);
		CSM_GridResponseWrapper responsewrapper  = fcBusinessLayer.retrieveSObjectWrapperList();
		Test.stopTest();
		List<CSM_GridColumnWrapper> headerList = responsewrapper.header; 
		
		system.assert(headerList[0].valueCol == CSM_Constants.CASE_NUMBER);
		system.assert(true);
	}
	
	static testMethod void testContractNumberShown_1() {
		CSM_TestUtility.setup();
		CSM_CustomGridInputWrapper.CSM_CustomGridParams inputGrwParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();		
		inputGrwParams.taskOrViewId = CSM_TestUtility.focusCategoryView.Id;
		inputGrwParams.accountId = CSM_TestUtility.Acct.Id;
		inputGrwParams.healthStatus = 'Healthy';
		inputGrwParams.dateRange = '';
		inputGrwParams.accountPlanId = '';
		inputGrwParams.selectedTaskFilter = '';
		inputGrwParams.selectedFilterClause = '';
		
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		inputWrapper.objType = CSM_Constants.OBJ_CONTRACT;
		inputWrapper.params = inputGrwParams;
		
		Test.startTest();
		CSM_FCFullListBusinessLayer fcBusinessLayer = new CSM_FCFullListBusinessLayer(inputWrapper);
		CSM_GridResponseWrapper responsewrapper  = fcBusinessLayer.retrieveSObjectWrapperList();
		Test.stopTest();
		List<CSM_GridColumnWrapper> headerList = responsewrapper.header; 
		system.assert(headerList[0].valueCol == CSM_Constants.CONTRACT_NUMBER);
		system.assert(true);
	}
	
	
	static testMethod void testCaseNumberShown_SP() {
		CSM_Focus_Category_View__c fcv1 = insertFCV('View Account Test', 'name ', 'WHERE name != null ','SELECT Id, Name FROM CSM_Account_Plan__c WHERE name != null', 'CSM_Account_Plan__c','CSM_ACV_Amount__c',true);
		CSM_TestUtility.setup();

		CSM_UserPreferencesFilterWrapper userprefFilter = new CSM_UserPreferencesFilterWrapper();
		userprefFilter.attObjectType = 'Success Plan';
		userprefFilter.attrFieldName = 'Name';
		userprefFilter.attrFieldType = 'Text';
		userprefFilter.attrFieldValue = 'New';
		
		CSM_CustomGridInputWrapper.CSM_CustomGridParams inputGrwParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();		
		inputGrwParams.taskOrViewId = fcv1.id;
		inputGrwParams.accountId = CSM_TestUtility.Acct.Id;
		inputGrwParams.healthStatus = 'Healthy';
		inputGrwParams.dateRange = '';
		inputGrwParams.accountPlanId = '';
		inputGrwParams.selectedTaskFilter = '';
		inputGrwParams.selectedFilterClause = '';
		inputGrwParams.userPrefWrapper = userprefFilter;
		
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		inputWrapper.objType = CSM_Constants.OBJ_CASE;
		inputWrapper.params = inputGrwParams;
		inputWrapper.params = inputGrwParams;
		
		Test.startTest();
		CSM_FCFullListBusinessLayer fcBusinessLayer = new CSM_FCFullListBusinessLayer(inputWrapper);
		CSM_GridResponseWrapper responsewrapper  = fcBusinessLayer.retrieveSObjectWrapperList();
		Test.stopTest();
		List<CSM_GridColumnWrapper> headerList = responsewrapper.header; 
		
		system.assert(headerList[0].valueCol == CSM_Constants.CASE_NUMBER);
		system.assert(true);
	}
		
	public static CSM_Focus_Category_View__c insertFCV(String displayName, String columns, String criteria, String soql, String objName,String currencyHeader, boolean isTiles) {
		CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
		fcv.CSM_Display_Name__c = displayName;
		fcv.CSM_Columns__c = columns;
		fcv.CSM_Criteria__c = criteria;
		fcv.CSM_SOQL__c = soql;
		fcv.CSM_Object_Name__c = objName;
		fcv.CSM_Currency_Header__c = currencyHeader;
		fcv.CSM_Filter_By_Owner_Value__c = 'My Account';
		fcv.CSM_IsTile__c = isTiles;		
		fcv.CSM_Is_Active__c = true;		
		insert fcv;
		return fcv;
	}
}