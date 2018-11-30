@isTest
public with sharing class CSM_SuccessPlanDetailsControllerTest
{
	static testMethod void testSuccessPlanDetails()
	{
		
        Account testAccount = new Account(Name='Test Company Name123');
        insert testAccount;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        CSM_SuccessPlanDetailsController controller = new CSM_SuccessPlanDetailsController(sc);
        
        
        PageReference pageRef = Page.CSM_SuccessPlanDetails;
        pageRef.getParameters().put('id', String.valueOf(testAccount.Id));
        Test.setCurrentPage(pageRef);
        
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
}