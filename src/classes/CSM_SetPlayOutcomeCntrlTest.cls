@isTest
private class CSM_SetPlayOutcomeCntrlTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        CSM_TestUtility.setup();        
        CSM_Constants.TASK_TRIGGER = true;
        Test.startTest();   
        Test.setCurrentPage(Page.CSM_SetPlayOutCome);
        PageReference pageRef = Page.CSM_SetPlayOutCome;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('taskId', CSM_TestUtility.tsk.id);
        pageRef.getParameters().put('status', 'Completed');
        pageRef.getParameters().put('spplId', CSM_TestUtility.spPlay.id);
                
      	Account acc = new Account();
        acc.Name = 'Test account';
        insert acc;
        
        CSM_Play__c play = new CSM_Play__c();
        play.CSM_IsActive__c = true;
        insert play;
        
        CSM_Account_Plan__c successPlan = new CSM_Account_Plan__c();
        successPlan.CSM_IsActive__c = true;
        successPlan.CSM_AccountId__c = acc.Id;
        insert successPlan;
        
        CSM_Account_Plan_Playbook__c successPlanPlaybook = new CSM_Account_Plan_Playbook__c();
        successPlanPlaybook.CSM_IsActive__c = true;
        successPlanPlaybook.CSM_Source__c ='Manual Add';
        successPlanPlaybook.CSM_Account_Plan__c = successPlan.Id;
        insert successPlanPlaybook;
        
        CSM_SuccessPlan_Play__c spp = new CSM_SuccessPlan_Play__c();
        spp.CSM_Play__c = play.Id;
        spp.CSM_SuccessPlan_Playbook__c = successPlanPlaybook.id;
        insert spp;
		
		Task tsk = new Task();
		tsk.Subject = 'Call';
		tsk.ActivityDate = Date.today();
        tsk.Status = 'Completed';
        tsk.CSM_SuccessPlan_Play__c = spp.Id;
        tsk.WhatId = acc.Id;
        insert tsk;        
        
        ApexPages.StandardController sc = new ApexPages.standardController(tsk);
        CSM_SetPlayOutcomeCntrl ctrl = new CSM_SetPlayOutcomeCntrl(sc);
        
        ctrl.playOutcomeValue = 'Completed Successfully';
        List<SelectOption> optList =  ctrl.getPlayOutcomeValues();
        System.assert(optList != null); 
       
        ctrl.Cancel();
        
        ctrl.Save();
    }
}