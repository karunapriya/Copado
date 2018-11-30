@isTest
public with sharing class CSM_AccountWidgetCompCntrlTest {
  public static List < CSM_Account_Plan_Template__c > accPlanTemplates;
  public static List < Account > accountList;
  static User adminUser;
  public static List < CSM_Account_Plan__c > accPlans;
  public static List < CSM_Account_Plan_Phase__c > phaseList;
  
  static testMethod void testPlayWidget() {
    adminUser = CSM_TestDataUtility.GetTestRunAsUser();
    Account accRec = new Account();
    System.RunAs(adminUser) {
      CSM_TestUtility.setup();
      setup();
      Test.startTest();
      CSM_AccountWidgetComponentController controller = new CSM_AccountWidgetComponentController();
      if (accountList[0].Id != null) {
        controller.accountId = accountList[0].Id;
        controller.getAccountDetails();
        String namespace = CSM_Util.getNamespace();
		System.assertEquals(controller.accountManager, namespace + CSM_Constants.OBJ_AP_ACCOUNT_MANAGER);
		System.assertEquals(controller.accountManagerLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_ACCOUNT_MANAGER));
		System.assertEquals(controller.customerSuccessManager, namespace + CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR);
		System.assertEquals(controller.customerSuccessManagerLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR));
		System.assertEquals(controller.csmReplacement, namespace + CSM_Constants.OBJ_AP_CSM_CONTACT);
		System.assertEquals(controller.csmReplacementLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_CONTACT));
		System.assertEquals(controller.csmManagerReplacement, namespace + CSM_Constants.OBJ_AP_CSM_MANAGER);
		System.assertEquals(controller.csmManagerReplacementLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_MANAGER));
		System.assertEquals(controller.execSponsorReplacement, namespace + CSM_Constants.OBJ_AP_EXEC_SPONSOR);
		System.assertEquals(controller.execSponsorReplacementLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_EXEC_SPONSOR));
		System.assertEquals(controller.renewalMgrReplacement, namespace + CSM_Constants.OBJ_AP_RENEWAL_MANAGER);
		System.assertEquals(controller.renewalMgrReplacementLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_MANAGER));
		System.assertEquals(controller.renewalRepReplacement, namespace + CSM_Constants.OBJ_AP_RENEWAL_CONTACT);
		System.assertEquals(controller.renewalRepReplacementLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_CONTACT));
		System.assertEquals(controller.supportContactReplacement, namespace + CSM_Constants.OBJ_AP_SUPPORT_CONTACT);
		System.assertEquals(controller.supportContactReplacementLabel, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_SUPPORT_CONTACT));
     	accRec = controller.getAcctObject();
     	system.assertEquals(controller.acctPlanRecordCurrencyCode,CSM_Util.convertCurrencyNameToSymbol(UserInfo.getDefaultCurrency()) + ' ');
      	accPlans[0].CSM_Phase_Start_Date__c= System.today().addDays(30);
      	update(accPlans);
      	system.debug('\n\n\n ~~~~~~ updated Phase Start Date ' + accPlans);
      	controller.getAccountDetails();
       }
      
      System.assert(controller.indicatorWrapperList.size() == 0);
      Test.stopTest();
    }
  }
   static testMethod void testPlayWidget_Negative() {
   		Account accRec = new Account();
   		CSM_TestUtility.setup();
   		setup();
   		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
   		system.assertNotEquals(restrictedUser,null);
    	System.RunAs(restrictedUser) {
      		Test.startTest();
      			CSM_AccountWidgetComponentController controller = new CSM_AccountWidgetComponentController();
      			if (accountList[0].Id != null) {
        			controller.accountId = accountList[0].Id;
        			controller.getAccountDetails();
      			}
        	Test.stopTest();
   		}
  	}
  
  
  static void setup() {
    accPlanTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
    accountList = CSM_TestDataUtility.createAccount(1);
    accPlans = CSM_TestDataUtility.createAccountPlan(accountList, accPlanTemplates[0].Id);
    phaseList = CSM_TestDataUtility.createAccountPlanPhaseData(3,accPlanTemplates[0].id);
    system.debug('\n\n\n `````````````` Phase List In Test Class' + phaseList);
  }

}