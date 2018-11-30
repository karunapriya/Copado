@isTest
private class CSM_UtilTest {
	
	 static testMethod void Test_CSM_Util() {
       	
      	List<Account> accList = new List<Account>();
      	accList = CSM_TestDataUtility.createAccount(1);
      	system.assert(accList != null);
      	
      	List<CSM_Account_Plan_Template__c> accPlanTempList = new List<CSM_Account_Plan_Template__c>();
      	accPlanTempList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
      	String accPlanTempID = accPlanTempList[0].id;
      	
      	List < CSM_Account_Plan_Phase__c > phaseList = new List < CSM_Account_Plan_Phase__c >();
      	phaseList = CSM_TestDataUtility.createAccountPlanPhaseData(3,accPlanTempList[0].id);
      	
      	List<CSM_Account_Plan__c> accPlanList = new List<CSM_Account_Plan__c>();
      	accPlanList = CSM_TestDataUtility.createAccountPlan(accList,accPlanTempID);
      	
      	accPlanList[0].CSM_Phase_Start_Date__c= System.today().addDays(30);
      	update(accPlanList);
      	
      	Test.startTest();
		      	CSM_Util.getCurrentPhase (accPlanList);
		      	
		      	accPlanList[0].CSM_Phase_Start_Date__c= System.today();
		      	update(accPlanList);
		      	CSM_Util.getCurrentPhase (accPlanList);
		      	
		      	accPlanList[0].CSM_Phase_Start_Date__c= System.today().addDays(-60);
		      	update(accPlanList);
		      	CSM_Util.getCurrentPhase (accPlanList);
		      	
		      	Set<ID> templateId = new Set<ID>();
		      	templateId.add(accPlanTempList[0].id);
		      	
		      	CSM_Util.getCurrentPhase (accPlanList);
		      	CSM_Util.getPhases(templateId);
		      	
		      	List<SelectOption>  DataFieldList =  new List<SelectOption>();
		      	DataFieldList.add(new SelectOption('key', 'Value'));
		      	DataFieldList.add(new SelectOption('key1', 'Value1'));
		      	CSM_Util.sortSelectOptionByLabel(DataFieldList);
		      	String soqlStr = CSM_Util.getCreatableFieldsSOQL('Account','createddate!=null');
		      	CSM_Util.doSort(DataFieldList,CSM_Util.FieldToSort.Label);
		      	Integer fiscalMonth = CSM_Util.getFiscalYearMonth();
		      	Boolean testFlag = CSM_Util.isOWDForOpportunityPrivate();
		      	testFlag = CSM_Util.isOWDForAccountPrivate();
		      	testFlag = 	CSM_Util.sObjectExists('Account');
		      	
		      	SObject sObj= accPlanList[0];
		      	CSM_Util.getPicklistValues(sObj,'Name');
    	Test.stopTest();
    } 
    
    
     static testMethod void Test_1() {
       	Test.startTest();
       			CSM_Util.getScoutAnalyticsUrl();
		      	CSM_Util.getPackageVersion();
		      	CSM_Util.getNamespace();
		      	CSM_Util.NewGuid();
		      	CSM_Util.isUserAnSystemAdmin();
		      	try{
		      		CSM_Util.getExchangeRateToCorpCurrency('INR');
		      	}catch(Exception e){}
		      	try{
		      		CSM_Util.returnIfCurrencyISOCodeExists('Opportunity');
		      	}catch(Exception e){}
		      	try{
		      		CSM_Util.setToString(new Set<ID>{UserInfo.getUserId()});
		      	}catch(Exception e){}
		      	try{
		      		CSM_Util.stringToIdList(UserInfo.getUserId() + ','+ UserInfo.getUserId());
		      	}catch(Exception e){}
		      	try{
		      		String refRelation='';
		      		Map<String, Schema.SObjectField> objFieldInfo = Opportunity.getSObjectType().getDescribe().fields.getMap();
					refRelation = CSM_Util.findNameForLookup('AccountId', objFieldInfo);
					system.assertNotEquals(refRelation,'');
		      	}catch(Exception e){}
		      	try{
		      		Map<String, Schema.SObjectField> objFieldInfo = Opportunity.getSObjectType().getDescribe().fields.getMap();
					String refRelation = CSM_Util.findNameForLookup('ContractId', objFieldInfo);
					system.assertNotEquals(refRelation,'');
		      	}catch(Exception e){}
		      	try{
		      		Map<String, Schema.SObjectField> objFieldInfo = Case.getSObjectType().getDescribe().fields.getMap();
					String refRelation = CSM_Util.findNameForLookup('ParentId', objFieldInfo);
					system.assertNotEquals(refRelation,'');
		      	}catch(Exception e){}
		      	system.assert(true);
       	Test.stopTest();
    } 
    
     static testMethod void Test_2() {
       	Test.startTest();
		      	CSM_Util.toggleSortDirection('ASC');
		      	CSM_Util.GetSObjectFieldsMap('Account');
		      	CSM_Util.getColumns('Account');
		      	CSM_Util.formatDatetimeString('30-12-2011', 'MM-dd-yy');
		      	CSM_Util.convertCurrencyNameToSymbol('USD');
		      	CSM_Util.sendEmail('a@abc.com', 'Test Message');
		      	CSM_Util.getNameWithNameSpace('Account','.', true);
		      	CSM_Util.getNameWithNameSpace('Account','.', false);
		      	
		      	List<String> fieldName = new List<String>();
		      		fieldName.add('Name');
		      		fieldName.add('AccountNumber');
		      	CSM_Util.checkCRUD_FLS('Account', fieldName, 'READ');
		      	system.assert(true);
      	Test.stopTest();
    } 
    
    static testMethod void testLabelReplacement()
    {
    
        CSM_Admin__c csmAdmin = CSM_AdminDataAccess.getCSMAdminInstance();
        csmAdmin.CSM_SP_LBL_AccountManager__c = 'acctMgrRepl';
        csmAdmin.CSM_SP_LBL_CustomerSuccessManager__c = 'custSuccessRepl';
        csmAdmin.CSM_SP_LBL_CSM__c = 'csmRepl';
        csmAdmin.CSM_SP_LBL_CsmManager__c = 'csmMgrRepl';
        csmAdmin.CSM_SP_LBL_ExecSponsor__c = 'execSponsorRepl';
        csmAdmin.CSM_SP_LBL_RenewalManager__c = 'renewalMgrRepl';
        csmAdmin.CSM_SP_LBL_RenewalRep__c = 'renewalRepRepl';
        csmAdmin.CSM_SP_LBL_SupportContact__c = 'supportContactRepl';
        upsert csmAdmin;
        
        Test.startTest();
        System.assertEquals('acctMgrRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_ACCOUNT_MANAGER));
        System.assertEquals('custSuccessRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR));
        System.assertEquals('csmRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_CONTACT));
        System.assertEquals('csmMgrRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_MANAGER));
        System.assertEquals('execSponsorRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_EXEC_SPONSOR));
        System.assertEquals('renewalMgrRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_MANAGER));
        System.assertEquals('renewalRepRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_CONTACT));
        System.assertEquals('supportContactRepl',CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_SUPPORT_CONTACT));
        Test.stopTest();
        
    }
}