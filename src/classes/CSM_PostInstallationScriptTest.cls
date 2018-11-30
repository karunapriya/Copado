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
private class CSM_PostInstallationScriptTest {
    
    static testMethod void TestSetup()
    {
        CSM_Play__c playtest = CSM_TestUtility.insertPlayWithoutInsert();
        insert playtest;
        
        REN_DocuSign_Config__c dsConfig = new REN_DocuSign_Config__c();
		dsConfig.REN_Acount_ID__c = 'TestAccount';
		dsConfig.REN_IntegratorKey__c = 'TestAccount';
		dsConfig.REN_EmailSubject__c = 'TestEmail';
		//dsConfig.REN_ReturnURL__c = 'TestreturnUrl';
		dsConfig.REN_EmailSubject__c = 'TestreturnUrl';
		dsConfig.REN_RESTAPIUrl__c = 'TestreturnUrl';
		//dsConfig.REN_HeaderContent__c = 'TestreturnUrl';
		dsConfig.REN_RecipientAuthenticationMethod__c = 'email';
		dsConfig.REN_SignHereAnchorString__c = 'TestreturnUrl';
		dsConfig.REN_SignHereAnchorXOffset__c = '200';
		dsConfig.REN_SignHereAnchorYOffset__c = '150';
		//dsConfig.REN_SignHereName__c = 'Sign here';
		dsConfig.REN_SignHereXPosition__c = '100';
		dsConfig.REN_SignHereYPosition__c= '100';
		insert dsConfig;
		
    }

    static testMethod void generateDataTest() {
        
    	List<CSM_Chart_Management__c> existingChartList = [select id, name from CSM_Chart_Management__c limit 10000];
    	delete existingChartList;
		Set<String> groupNames = new Set<String>();
    	groupNames.add(Label.REN_LBL_CSMGROUP_NAME);
    	groupNames.add(Label.REN_LBL_NETOPSGROUP_NAME);
    	groupNames.add(Label.REN_LBL_RENEWGROUP_NAME);
    	List<Group> groups = [SELECT Id, Name FROM GROUP WHERE DeveloperName IN :groupNames];
    	delete groups;
        Set<String> chartNames = new Set<String>();
		
        CSM_PostInstallationScript ps = new CSM_PostInstallationScript();
        //ps.generateData();
        
        groups = [SELECT Id, Name FROM GROUP WHERE DeveloperName IN :groupNames];
    	for (Group grp : groups){
        	if (grp.Name == Label.REN_LBL_CSMGROUP_NAME){
        		System.assert(grp.Name == Label.REN_LBL_CSMGROUP_NAME);
        	}
        	if (grp.Name == Label.REN_LBL_NETOPSGROUP_NAME){
        		System.assert(grp.Name == Label.REN_LBL_NETOPSGROUP_NAME);
        	}
        	if (grp.Name == Label.REN_LBL_RENEWGROUP_NAME){
        		System.assert(grp.Name == Label.REN_LBL_RENEWGROUP_NAME);
        	}
        }
    }
    
    static testMethod void migrateDataTest(){
        TestSetup();
    	List<CSM_Play__c> playtest=[select id ,name from CSM_Play__c where CSM_Display_Name__c ='Play A'];
        
    	List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(playtest[0].id));
    	CSM_Focus_Category_View__c focusCategoryView = CSM_TestUtility.insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 
		'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue');
    	CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = CSM_TestUtility.createFCVCriteria('BillingCity', 'Billing City', 'String', 'IN', 'Test', focusCategoryView.Id);
    	insert focusCategoryViewCriteria;
    	
    	CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(1,23));
		Test.stopTest();
        
        List<CSM_Play_Criteria__c> playCritList = [Select id,RLM_LineNo__c from CSM_Play_Criteria__c Limit 1];
        system.assert(playCritList[0].RLM_LineNo__c != null);
        
        List<CSM_Focus_Category_View_Criteria__c> fcvcList = [Select id,RLM_LineNo__c from CSM_Focus_Category_View_Criteria__c Limit 1];
        system.assert(fcvcList[0].RLM_LineNo__c != null);
        
        
    }
    
    
    static testMethod void setisSpecificDateTest(){
    	TestSetup();
    	Datetime systemDateTime = system.now();
    	system.assert(systemDateTime!=null);
    	CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(1,25));
		Test.stopTest();
        }
    
    static testMethod void insertTriggerEnablementTest(){
    	TestSetup();
    	CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.CSM_AccountPlanTrigger__c = true;
		cTriggerEnablement.CSM_AccountPlan_PlaybookTrigger__c = true;
		cTriggerEnablement.CSM_PlaybookPlayTrigger__c = true;
		cTriggerEnablement.CSM_AccountTrigger__c = true;
		cTriggerEnablement.REN_AssetTrigger__c = false;
		cTriggerEnablement.CSM_CaseTrigger__c = false;
		cTriggerEnablement.CSM_OpportunityTrigger__c = false;
		cTriggerEnablement.CSM_PlayResultTrigger__c = true;
		cTriggerEnablement.CSM_TaskTrigger__c = true;
		cTriggerEnablement.REN_RenewalRelationshipTrigger__c  = false;
		cTriggerEnablement.CSM_ScoutCustomerTrigger__c  = false;		
		cTriggerEnablement.CHL_PartnerOpportunityTrigger__c = false;
		cTriggerEnablement.CHL_UserTrigger__c = false;
		cTriggerEnablement.CSM_SuccessPlanPlayTrigger__c = false;		
		cTriggerEnablement.CSM_BatchFilterTrigger__c = true;
		system.assert(cTriggerEnablement.CSM_AccountPlanTrigger__c == true);
        CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(1,28));
		Test.stopTest();
        }
    
    static testMethod void updateExistingFCTest(){
        TestSetup();
    	List<CSM_Play__c> playtest=[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
        List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(playtest[0].id));
    	CSM_Focus_Category_View__c focusCategoryView = CSM_TestUtility.insertFCV('View Task Test', 'Task State', 'WHERE Priority=\'High\'', 
		'SELECT Id, Name, FROM Task  WHERE Priority=\'High\'', 'Task','Task State');
    	CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = CSM_TestUtility.createFCVCriteria('BillingCity', 'Billing City', 'String', 'IN', 'Test', focusCategoryView.Id);
    	insert focusCategoryViewCriteria;
    	CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,0));
		Test.stopTest();
		
		List<CSM_Play__c> playList =[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
		system.assert(playList[0].name != null);

    }
    
     static testMethod void updateExistingFCTestNegative(){
         TestSetup();
    	List<CSM_Play__c> playtest=[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
        List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(playtest[0].id));
    	CSM_Focus_Category_View__c focusCategoryView = CSM_TestUtility.insertFCV('View Case Test', 'Case Origin', 'WHERE Case Origin=\'Email\'', 
		'SELECT Id, Name, FROM Case  WHERE Case Origin=\'Email\'', 'Case','Case Origin');
    	CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = CSM_TestUtility.createFCVCriteria('CaseOrigin', 'Case Origin', 'String', 'IN', 'Test', focusCategoryView.Id);
    	insert focusCategoryViewCriteria;
        CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,0));
		Test.stopTest();
		List<CSM_Play__c> playList =[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
		system.assert(playList[0].name != null);

    }
    
     static testMethod void updateExistingFCTestNegative1(){
         TestSetup();
    	List<CSM_Play__c> playtest=[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
        List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(playtest[0].id));
    	CSM_Focus_Category_View__c focusCategoryView = CSM_TestUtility.insertFCV('View 	Contract Name Test', 'Contract Name', 'WHERE Shipping Address=\'Test\'', 
		'SELECT Id, Name, FROM Contract Name  WHERE Shipping Address=\'Test\'', 'Contract','Contract Name');
    	CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = CSM_TestUtility.createFCVCriteria('ContractName', 'Contract Name', 'String', 'IN', 'Test', focusCategoryView.Id);
    	insert focusCategoryViewCriteria;
        
    	CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,0));
		Test.stopTest();
		List<CSM_Play__c> playList =[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
		system.assert(playList[0].name != null);

    }
    
     static testMethod void updateExistingFCTestNegative2(){
         TestSetup();
    	List<CSM_Play__c> playtest=[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
        List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(playtest[0].id));
    	CSM_Focus_Category_View__c focusCategoryView = CSM_TestUtility.insertFCV('View 	Contract Name Test', 'Contract Name', 'WHERE Shipping Address=\'Test\'', 
		'SELECT Id, Name, FROM Contract Name  WHERE Shipping Address=\'Test\'', 'Contract','Contract Name');
    	CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria = CSM_TestUtility.createFCVCriteria('ContractName', 'Contract Name', 'String', 'IN', 'Test', focusCategoryView.Id);
    	insert focusCategoryViewCriteria;
    	CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,0));
		Test.stopTest();
		List<CSM_Play__c> playList =[select id ,name from CSM_Play__c where CSM_Play__c.CSM_IsActive__c=true];
		system.assert(playList[0].name != null);

    }
	
	static testMethod void populateFieldMapping_Positive() {
		CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	Test.startTest();
		Test.testInstall(postinstall,new Version(2,34));
		system.assert(true);
		Test.stopTest();
	}
	
	/**This method will uncomment when version for updateSOQLExistingFCV() method will decided.
	
    static testMethod void updateSOQLExistingFCVTest()  {
        CSM_PostInstallationScript postinstall = new CSM_PostInstallationScript();
    	CSM_Focus_Category_View__c focusCategoryView = CSM_TestUtility.insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 
		'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\' order by lastModifiedDate DESC', 'Account','AnnualRevenue');
        Test.startTest();
        Test.testInstall(postinstall,new Version(2,34));
        Test.stopTest();
        
    }**/
    
    
           
}