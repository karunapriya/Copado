@isTest
private class CSM_PlayResultTriggerHandlerTest {
    
    private static Id testAccountId;
    private static Id accountPlanId;
    
    static private void init()
    {
    	CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_TestUtility.addLicense();
        CSM_TestUtility.addCSMAdmin();
        CSM_TestUtility.insertAccount();
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        setUp();
    }

    static testMethod void playResultPlayBookAndPlayInsert()
    {
        init();
        Test.startTest();
        List<CSM_Play_Result__c> rtList = new List<CSM_Play_Result__c>();
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        
        //Insert Playbook
        CSM_Play_Result__c pr1 = new CSM_Play_Result__c();
        pr1.CSM_Playbook_Description__c = 'Test Desc PLB1';
        pr1.CSM_Playbook_External_Id__c = '11111';
        pr1.CSM_Playbook_Name__c = 'PLB1';
        rtList.add(pr1);
        
        
        //Insert Play1
        CSM_Play_Result__c pr2 = new CSM_Play_Result__c();
        pr2.CSM_Play_Description__c = 'Tst Desc PL1';
        pr2.CSM_Play_Name__c = 'PL1';
        pr2.CSM_Play_External_Id__c = '22222';
        pr2.CSM_Playbook_External_Id__c = '11111';
        rtList.add(pr2);
        insert rtList;
        
        
        CSM_PlayResultTriggerHandler rt = new CSM_PlayResultTriggerHandler();
        //rt.onAfterInsert(rtList,null);
        
        List<CSM_Play__c> playtmpList = [Select Id, CSM_External_Id__c From CSM_Play__c Where CSM_External_Id__c = :pr2.CSM_Play_External_Id__c  Limit 1];
        CSM_Play__c playtmp;
        if (playtmpList!=null && !playtmpList.isEmpty()) {
            playtmp = playtmpList[0];
            system.assert(playtmp.CSM_External_Id__c == pr2.CSM_Play_External_Id__c);
        } else {
            system.assert(playtmpList.IsEmpty()==true);
        }
        
        CSM_Play_Result__c plr = [Select Id, CSM_Failed_Description__c, CSM_Processed__c, CSM_Failed__c From CSM_Play_Result__c Where Id = :pr2.Id];
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        //Insert Play2
        CSM_Play_Result__c pr3 = new CSM_Play_Result__c();
        pr3.CSM_Play_Description__c = 'Tst Desc PL1';
        pr3.CSM_Play_Name__c = 'PL1';
        pr3.CSM_Play_External_Id__c = '22221';
        pr3.CSM_Playbook_External_Id__c = '11111';
        insert pr3;
        
        playtmpList = [Select Id, CSM_External_Id__c From CSM_Play__c Where CSM_External_Id__c = :pr3.CSM_Play_External_Id__c  Limit 1];
        if (playtmpList!=null && !playtmpList.isEmpty()) {
            playtmp = playtmpList[0];
            system.assert(playtmp.CSM_External_Id__c == pr3.CSM_Play_External_Id__c);
        } else {
            system.assert(playtmpList.IsEmpty()==true);
        }
        set<String> playIds = new set<String>();
        playIds.add(pr2.CSM_Play_External_Id__c);
        playIds.add(pr3.CSM_Play_External_Id__c);

        
        //Activate Playbook
        List<CSM_Playbook__c> lstPlaybooks = [Select CSM_IsActive__c, Id, CSM_Automated__c, CSM_External_Id__c From CSM_Playbook__c
                                              Where CSM_External_Id__c = '11111'];
        if (lstPlaybooks!=null && !lstPlaybooks.isEmpty()) {
            lstPlaybooks[0].CSM_IsActive__c = true;
            lstPlaybooks[0].CSM_Automated__c = true;
            update lstPlaybooks[0];
        }    
        //Activate Plays
        List<CSM_Play__c> lstPlays = [Select CSM_IsActive__c, Id, CSM_Automated__c, CSM_External_Id__c From CSM_Play__c
                                       Where CSM_External_Id__c IN :playIds];
        
        for(CSM_Play__c pl :lstPlays)
        {
            pl.CSM_IsActive__c = true;
            pl.CSM_Automated__c = true;
        }
        update lstPlays;
        
        CSM_Constants.ACCOUNT_TRIGGER = false;
        //Insert Account
        Account a = new Account(Name = 'Test Account ABC');
        insert a;
        
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        List<CSM_Play_Task__c> lstPlTasks = new List<CSM_Play_Task__c>();
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        //Create PlayTasks for all Plays
        for(CSM_Play__c pl :lstPlays)
        {
            for(Integer i = 0; i < 2; i++)
            {
                CSM_Play_Task__c newPlTsk = new CSM_Play_Task__c();
                newPlTsk.CSM_IsActive__c = true;
                newPlTsk.CSM_Assign_To__c = 'Account Owner';
                newPlTsk.CSM_Days_Until_Due__c = 10;
                newPlTsk.CSM_Description__c = 'Test Desc ' + i + ' ' + pl.CSM_External_Id__c;
                newPlTsk.CSM_Play__c = pl.Id;
                lstPlTasks.add(newPlTsk);
            }
        }
        if(lstPlTasks != null && !lstPlTasks.isEmpty())
        {
            insert lstPlTasks;
        }
        
        
        CSM_Task_Processing__c taskProcessing = new  CSM_Task_Processing__c();  
        if (lstPlTasks!=null && !lstPlTasks.isEmpty()){
            taskProcessing.CSM_PlayTask__c=lstPlTasks[0].id ;               
            insert(taskProcessing); 
        }                
        
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        //Run Play 1 - PENDING
        CSM_Play_Result__c pr4 = new CSM_Play_Result__c();
        pr4.CSM_Play_External_Id__c = '22222';
        pr4.CSM_Playbook_External_Id__c = '11111';
        pr4.CSM_Play_Result_Id__c = 'playResult1';
        pr4.CSM_Account_Id__c = a.Id;
        pr4.CSM_Resolution_Status__c = CSM_Constants.INT_PLAYRESULT_PENDING;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr4);
        insert rtList;
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        //Run Play 2 - PENDING
        CSM_Play_Result__c pr5 = new CSM_Play_Result__c();
        pr5.CSM_Play_External_Id__c = '22221';
        pr5.CSM_Playbook_External_Id__c = '11111';
        pr5.CSM_Play_Result_Id__c = 'playResult2';
        pr5.CSM_Account_Id__c = a.Id;
        pr5.CSM_Resolution_Status__c = CSM_Constants.INT_PLAYRESULT_PENDING;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr5);
        insert rtList;
        //rt.onAfterInsert(rtList,null);
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        //Run Play 1 - ATTAINED
        CSM_Play_Result__c pr6 = new CSM_Play_Result__c();
        pr6.CSM_Play_External_Id__c = '22222';
        pr6.CSM_Playbook_External_Id__c = '11111';
        pr6.CSM_Play_Result_Id__c = 'playResult3';
        pr6.CSM_Account_Id__c = a.Id;
        pr6.CSM_Resolution_Status__c = CSM_Constants.INT_PLAYRESULT_ATTAINED;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr6);
        insert rtList;
        //rt.onAfterInsert(rtList);
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        //Run Play 2 - HALTED
        CSM_Play_Result__c pr7 = new CSM_Play_Result__c();
        pr7.CSM_Play_External_Id__c = '22221';
        pr7.CSM_Playbook_External_Id__c = '11111';
        pr7.CSM_Play_Result_Id__c = 'playResult4';
        pr7.CSM_Account_Id__c = a.Id;
        pr7.CSM_Resolution_Status__c = CSM_Constants.INT_PLAYRESULT_HALTED;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr7);
        insert rtList;
        //rt.onAfterInsert(rtList,null);
        
        //Check Validations START
     /*   CSM_Constants.PLAY_RESULT_TRIGGER = true;
        CSM_Play_Result__c pr8 = new CSM_Play_Result__c();
        pr8.CSM_Play_Result_Id__c = 'pr_111';
        pr8.CSM_Account_Id__c = null;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr8);
        insert rtList;
        //rt.onAfterInsert(rtList, null);
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        CSM_Play_Result__c pr9 = new CSM_Play_Result__c();
        pr9.CSM_Resolution_Status__c = 'Attained';
        pr9.CSM_Account_Id__c = null;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr9);
        insert rtList;
        //rt.onAfterInsert(rtList,null);
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        CSM_Play_Result__c pr10 = new CSM_Play_Result__c();
        pr10.CSM_Resolution_Status__c = 'Attained';
        pr10.CSM_Play_Result_Id__c = null;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr10);
        insert rtList;
        //rt.onAfterInsert(rtList,null);
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        CSM_Play_Result__c pr11 = new CSM_Play_Result__c();
        pr11.CSM_Account_Id__c = a.Id;
        pr11.CSM_Resolution_Status__c = null;
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr11);
        insert rtList;
        //rt.onAfterInsert(rtList,null);
        
        CSM_Constants.PLAY_RESULT_TRIGGER = true;
        CSM_Play_Result__c pr12 = new CSM_Play_Result__c();
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr12);
        insert rtList;
        //rt.onAfterInsert(rtList,null);

        //Check Validations END
        
        //Update Play2
        CSM_Play_Result__c pr13 = new CSM_Play_Result__c();
        pr13.CSM_Play_Description__c = 'Tst Desc PL1A';
        pr13.CSM_Play_Name__c = 'PL1A';
        pr13.CSM_Play_External_Id__c = '22221';
        pr13.CSM_Playbook_External_Id__c = '11111';
        rtList = new List<CSM_Play_Result__c>();
        rtList.add(pr13);
        insert rtList;*/
        //rt.onAfterInsert(rtList,null);
        Test.stopTest();
	}


	static void setUp() 
    {
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        CSM_TestUtility.addCSMAdmin();
        
        CSM_Account_Plan_Template__c newTemplate = new CSM_Account_Plan_Template__c();
        newTemplate.CSM_Template_Name__c = CSM_Constants.NAME_AUTOMATED_TEMPLATE;
        newTemplate.CSM_isActive__c = true;
        insert newTemplate;

        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        
        List<CSM_Account_Plan_Template__c> acctPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!acctPlanTemplateList.isEmpty());
        ID testAccountPlanTemplateId = acctPlanTemplateList[0].Id;
        
        List<CSM_Account_Plan_Phase__c> phaseData = CSM_TestDataUtility.createAccountPlanPhaseData(4, testAccountPlanTemplateId);
        
        CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c();
        accountPlan.CSM_AccountId__c = testAccountId;
        accountPlan.CSM_Account_Plan_Template__c = testAccountPlanTemplateId;
        accountPlan.CSM_Phase_Start_Date__c = System.today();
        insert accountPlan;
        accountPlanId = accountPlan.Id;
        System.assertNotEquals(accountPlan.Id, null);
	}
}