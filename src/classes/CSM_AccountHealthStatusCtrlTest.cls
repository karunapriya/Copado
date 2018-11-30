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
@isTest
private class CSM_AccountHealthStatusCtrlTest {

    static testMethod void myUnitTest() {
        List<Account> accountList = CSM_TestDataUtility.createAccount(5);
       
        PageReference pageRef = Page.CSM_AccountHealthStatus;
    	pageRef.getParameters().put(CSM_Constants.STATUS_PARAM,CSM_Constants.OBJ_A_UNDETERMINED);
    	pageRef.getParameters().put(CSM_Constants.RANGE_DATE_PARAM,EncodingUtil.urlEncode(CSM_Constants.BETWEEN_91_120,CSM_Constants.UTF_8));
		pageRef.getParameters().put(CSM_Constants.USER_PREF_OBJECT_TYPE,'Account');    	
    	
    	Test.setCurrentPage(pageRef);
    	
    	Test.startTest();
	    	CSM_AccountHealthStatusCtrl con = new CSM_AccountHealthStatusCtrl();
	    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	inputWrapper.params = 
	    	(CSM_CustomGridInputWrapper.CSM_CustomGridParams)JSON.deserialize(con.gridParam,CSM_CustomGridInputWrapper.CSM_CustomGridParams.class);
	    	inputWrapper.viewName = 'HealthStatus';
	    	
	    	CSM_AccountBusinessLayer bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	
	    	
	    	CSM_GridResponseWrapper gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	
	    	con.returnPage();
	    	con.dateRange = CSM_Constants.BETWEEN_91_120;
	    	con.populateAccountPlanInfoFilter(CSM_Constants.OBJ_A_UNDETERMINED,'','','','');
	    	//system.assertEQuals(con.displayHealth, 'No Health Check - ');
	    	con.displayHealth = CSM_Constants.OBJ_A_UNDETERMINED;
	    	con.dateRange = CSM_Constants.MORE_THAN_121;
	    	con.populateAccountPlanInfoFilter(CSM_Constants.OBJ_A_UNDETERMINED,'','','','');
	    	con.displayHealth = CSM_Constants.OBJ_A_UNDETERMINED;
	    	con.dateRange = CSM_Constants.BETWEEN_61_90;
	    	con.populateAccountPlanInfoFilter(CSM_Constants.OBJ_A_UNDETERMINED,'','','','');
	    	con.displayHealth = CSM_Constants.OBJ_A_UNDETERMINED;
	    	con.dateRange = CSM_Constants.BETWEEN_31_60;
	    	con.populateAccountPlanInfoFilter(CSM_Constants.OBJ_A_UNDETERMINED,'','','','');
	    	con.displayHealth = CSM_Constants.OBJ_A_UNDETERMINED;
	 	   	con.dateRange = CSM_Constants.BETWEEN_0_30;
			con.populateAccountPlanInfoFilter(CSM_Constants.OBJ_A_UNDETERMINED,'','','','');
			con.displayHealth = CSM_Constants.OBJ_A_UNDETERMINED;
			con.dateRange = null;
			con.populateAccountPlanInfoFilter(CSM_Constants.OBJ_A_UNDETERMINED,'','','','');	
			system.assertEQuals(con.displayHealth, 'Undetermined');	
    	Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        //List<Account> accountList = CSM_TestDataUtility.createAccount(5);
        List<Account> accountList =  createTestAccounts();
        LIst<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        LIst<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        planList.addAll(CSM_TestDataUtility.createAccountPlan(new LIst<Account>{accountLIst[0]}, templateLIst[0].id));
        //List<CSM_Account_Plan_Template__c> acctTemplate = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        //List<CSM_Account_Plan__c> accountPlan = CSM_TestDataUtility.createAccountPlan(accountList, acctTemplate[0].id);
        PageReference pageRef = Page.CSM_AccountHealthStatus;
    	pageRef.getParameters().put(CSM_Constants.STATUS_PARAM,CSM_Constants.OBJ_A_UNDETERMINED);
		pageRef.getParameters().put(CSM_Constants.USER_PREF_OBJECT_TYPE,'Account');    	
    	Test.setCurrentPage(pageRef);
    	
    	Test.startTest();
    		CSM_AccountHealthStatusCtrl con = new CSM_AccountHealthStatusCtrl();
	    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	//inputWrapper.params = 
	    	//(CSM_CustomGridInputWrapper.CSM_CustomGridParams)JSON.deserialize(con.gridParam,CSM_CustomGridInputWrapper.CSM_CustomGridParams.class);
	    	inputWrapper.viewName = 'HealthStatus';
	    	inputWrapper.params = new CSM_CustomGridInputWrapper.CSM_CustomGridParams(); 
	    	inputWrapper.params.dateRange = CSM_Constants.BETWEEN_0_30;
	    	inputWrapper.params.healthStatus = 'Healthy';
	    	inputWrapper.params.userPrefWrapper = new CSM_UserPreferencesFilterWrapper();
			inputWrapper.params.userPrefWrapper.attrFieldName = 'AnnualRevenue';
			inputWrapper.params.userPrefWrapper.attrFieldType = 'Double';
			inputWrapper.params.userPrefWrapper.attrFieldValue = 'null';
	    	
	    	CSM_AccountBusinessLayer bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	CSM_GridResponseWrapper gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	system.assertEquals(gwrapper.row.size(), 2);
	    	 
	    	inputWrapper.params.dateRange = CSM_Constants.BETWEEN_91_120;
	    	inputWrapper.params.healthStatus = 'Healthy';
	    	 bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	 gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	
	    	inputWrapper.params.dateRange = CSM_Constants.MORE_THAN_121;
	    	inputWrapper.params.healthStatus = 'Healthy';
	    	 bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	
	    	
	    	inputWrapper.params.dateRange = CSM_Constants.BETWEEN_61_90;
	    	inputWrapper.params.healthStatus = 'Healthy';
	    	bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	inputWrapper.params.dateRange = CSM_Constants.BETWEEN_31_60;
	    	inputWrapper.params.healthStatus = 'Healthy';
	    	bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	
	    	inputWrapper.params.dateRange = null;
	    	inputWrapper.params.healthStatus = 'Healthy';
	    	bisLayer = new CSM_AccountBusinessLayer(inputWrapper);
	    	gwrapper = bisLayer.retrieveSObjectWrapperList();
	    	
    		
    	Test.stopTest();	
    }
    
    private static List<Account> createTestAccounts()
    {
    	List<Account> accountList = new List<Account>();
    	for(integer i = 1; i <40; i++)
    	{
    		Account newAccount = new Account();
    		newAccount.name = 'Test account ' + i ;
    		if(i <=15)
    		{
    			newAccount.CSM_Health_Status__c = 'Healthy';
    			if(i <=2){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-15);}
    			else if (i >2 && i <=5){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-35);}
    			else if (i>5 && i <=8){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-65);}
    			else if(i >8 && i <=10){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-95);}
    			else if(i >10 && i <=12){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-125);}
    		}
    		if(i>15)
    		{
    			if(i <=20){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-15);}
    			else if (i >20 && i <=22){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-35);}
    			else if (i>22 && i <=25){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-65);}
    			else if(i >25 && i <=27){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-95);}
    			else if(i >27 && i <=29){
    				newAccount.CSM_Last_Health_Status__c = System.today().addDays(-125);}
    		}
    		accountList.add(newAccount);
    	}
    	upsert accountList;
    	
    	return accountList;
    }
    
}