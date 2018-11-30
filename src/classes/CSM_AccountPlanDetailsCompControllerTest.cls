@isTest
public with sharing class CSM_AccountPlanDetailsCompControllerTest
{
    private static Id testAccountId;
    private static CSM_Account_Plan_Template__c testTemplate;
    private static CSM_Account_Plan__c testAcctPlan;
    private static  Id opportunityId;
    
    static testMethod void testAccountPlanDetails() {
        setUp();
        Test.startTest();
        CSM_AccountPlanDetailsCompController controller = new CSM_AccountPlanDetailsCompController();
        controller.accountId = testAccountId;
        controller.acctPlanId = testAcctPlan.Id;
        controller.populatePlaybooksList();
        controller.playbookList = CSM_PlaybooksDataAccess.populatePlaybooksInformation();
        
        System.assertNotEquals(null,  controller.getAccountPlanDetail());
        
        System.assertNotEquals(null, controller.getAccountDetail());
        
        System.assertEquals(null, controller.opportunityDetails);
        
        System.assertNotEquals(null, controller.newOpportunity());
        
        System.assertNotEquals(null, controller.editOpportunity());
        
        System.assertNotEquals(null, controller.viewOpportunity());
        
        //System.assertNotEquals(null, controller.addPlayBook());
        
        controller.deleteOpportunityId = opportunityId;
        System.assertEquals(null, controller.deleteOpportunity());
        
        
        System.assertEquals(null,controller.saveDetails());
        
        System.assertEquals(null, controller.getRetURL());
        
        //System.assertEquals(null, controller.removePlaybookAssociation());
        
        List<CSM_PlaybookWrapper> pBWrapper = new List<CSM_PlaybookWrapper>();
        pBWrapper = controller.getPlaybookList();
        
        system.assertNotEquals(controller.recordCurrencyCode, null);
        system.assertNotEquals(controller.acctPlanRecordCurrencyCode, null);
        
        controller.acctPlanId = null;
        pBWrapper = controller.getPlaybookList();
        
        List<Opportunity> oppty = new List<Opportunity>();
        oppty = controller.getOpportunityDetails();
        String namespace = CSM_Util.getNamespace();
       
        System.assertEquals(controller.accountManager, namespace + CSM_Constants.OBJ_AP_ACCOUNT_MANAGER);
        System.assertEquals(controller.customerSuccessManager, namespace + CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR);
        System.assertEquals(controller.csmReplacement, namespace + CSM_Constants.OBJ_AP_CSM_CONTACT);
        System.assertEquals(controller.csmManagerReplacement, namespace + CSM_Constants.OBJ_AP_CSM_MANAGER);
        System.assertEquals(controller.execSponsorReplacement, namespace + CSM_Constants.OBJ_AP_EXEC_SPONSOR);
        System.assertEquals(controller.renewalMgrReplacement, namespace + CSM_Constants.OBJ_AP_RENEWAL_MANAGER);
        System.assertEquals(controller.renewalRepReplacement, namespace + CSM_Constants.OBJ_AP_RENEWAL_CONTACT);
        System.assertEquals(controller.supportContactReplacement, namespace + CSM_Constants.OBJ_AP_SUPPORT_CONTACT);
        
        System.assertEquals(controller.accountManagerLabel, Schema.CSM_Account_Plan__c.fields.CSM_Account_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.customerSuccessManagerLabel, Schema.CSM_Account_Plan__c.fields.CSM_Customer_Success_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.csmReplacementLabel, Schema.CSM_Account_Plan__c.fields.CSM_Contact__c.getDescribe().getLabel());
        System.assertEquals(controller.csmManagerReplacementLabel, Schema.CSM_Account_Plan__c.fields.CSM_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.execSponsorReplacementLabel, Schema.CSM_Account_Plan__c.fields.CSM_Exec_Sponsor__c.getDescribe().getLabel());
        System.assertEquals(controller.renewalMgrReplacementLabel, Schema.CSM_Account_Plan__c.fields.CSM_Renewal_Manager__c.getDescribe().getLabel());
        System.assertEquals(controller.renewalRepReplacementLabel, Schema.CSM_Account_Plan__c.fields.CSM_Renewal_Contact__c.getDescribe().getLabel());
        System.assertEquals(controller.supportContactReplacementLabel, Schema.CSM_Account_Plan__c.fields.CSM_Support_Contact__c.getDescribe().getLabel());
      
        Test.stopTest();
    }
    
    static testMethod void testAccountPlanDataAccess() {
        setUp();
        Test.startTest();
        	CSM_AccountPlanDataAccess.getFilterBasedAccountPlans('CSM_IsActive__c',null);
        	CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(testAcctPlan.id,testAccountId);
        	CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount('',testAccountId);
        	CSM_AccountPlanDataAccess.getAccountPlan(testAccountId,testTemplate.id);
        Test.stopTest();
    }
    
    static testMethod void testAccessController() {
        Test.startTest();
        	
			    String selectedObject = 'Account';
				Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
				Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
			
				Map<String, Schema.SObjectField> fieldMap1 = dsr.fields.getMap();
				Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
				fieldMap.putAll(fieldMap1);
				Map<String, Set<SelectOption>> objectSelectOptionMap = new Map<String, Set<SelectOption>>();
				Set<SelectOption> soList = new Set<SelectOption>();
			
				for(String key : fieldMap.keySet()) {
				  soList.add(new SelectOption(key, key));
				  objectSelectOptionMap.put(key,soList);
				}
				
				Map<String, Map<String, Set<SelectOption>>> objectDataTypeFieldMap = new Map<String, Map<String, Set<SelectOption>>>();
				for(String key : objectSelectOptionMap.keySet()){
				  objectDataTypeFieldMap.put(key,objectSelectOptionMap);
				}
				 System.assertNotEquals(null, fieldMap);
				CSM_AccessController.getInstance().getFieldList(selectedObject, fieldMap, objectSelectOptionMap, objectDataTypeFieldMap);
        	
        	    
        Test.stopTest();
    }
    
    static testMethod void testAccessControllerNegative() {
        Test.startTest();
        	try{  	
			    String selectedObject = 'Account';
			    System.assertNotEquals(null, selectedObject);
				CSM_AccessController.getTypeFromFieldnameObjectname(selectedObject, 'Name', 'String');
        	 }catch(exception e){
        	 	
        	 }
        Test.stopTest();
    }
     
    static void setUp() 
    {
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        testTemplate = testTemplates[0];
        
        List<CSM_Account_Plan__c> acctPlanList = CSM_TestDataUtility.createAccountPlan(accountList, testTemplate.Id);
        System.assert(!acctPlanList.isEmpty());
        testAcctPlan = acctPlanList[0];
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(10);
        List<String> pbIdList = new List<String>();
        for(CSM_Playbook__c p : playbookList)
        {
            pbIdList.add(p.id);
        }
        List<CSM_Account_Plan_Playbook__c> appList = CSM_TestDataUtility.createAccountPlanPlaybookData(acctPlanList[0].Id, testTemplates[0].Id, pbIdList );
        
        Opportunity opport = new Opportunity();
        opport.AccountId = testAccountId;
        opport.StageName = 'Prospecting';
        opport.CloseDate = System.today();
        opport.Name = 'Opportunity Test';
        insert opport;
        opportunityId = opport.Id;
        System.assertNotEquals(opport.Id, null);
        
        
        
    }
    
}