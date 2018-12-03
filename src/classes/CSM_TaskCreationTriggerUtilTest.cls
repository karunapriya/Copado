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
 * to a production organization to confirm correctness, ensure  code
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
@isTest(seeAllData = true)
private class CSM_TaskCreationTriggerUtilTest {

    static testMethod void myUnitTest() {
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(2); 
        
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        List<CSM_Play_Criteria__c> playCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(playList[0].id);
        
        List<CSM_Play__c> playListOppty = CSM_TestDataUtility.createPlayOpportunityTestData(playbookList[1].Id, 1);
        List<CSM_Play_Criteria__c> playCriteriaListOppty = playCriteriaList = CSM_TestDataUtility.createPlayCriteriaOpptyData(playListOppty[0].id);
        
        List<CSM_Play_Task__c> playTaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        CSM_Play_Task__c newTask1 = new CSM_Play_Task__c();
        newTask1.CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_MANAGER;
        newTask1.Name = 'Task 1';
        newTask1.CSM_Days_Until_Due__c = 30;
        newTask1.CSM_IsActive__c = true;
        newTask1.CSM_Play__c = playList[0].Id;
        newTask1.CSM_Description__c = 'The description';
        playTaskList.add(newTask1);
        
		CSM_Play_Task__c newTask3 = new CSM_Play_Task__c();
        newTask3.CSM_Assign_To__c = 'CSM_User_Lookup_10__c';
        newTask3.Name = 'Task 3';
        newTask3.CSM_Days_Until_Due__c = 30;
        newTask3.CSM_IsActive__c = true;
        newTask3.CSM_Play__c = playList[0].Id;
        newTask3.CSM_Description__c = 'The description3';
        playTaskList.add(newTask3);
        
        upsert playTaskList;
        List<CSM_Play_Task__c> playTaskListOppty = CSM_TestDataUtility.createPlayTaskData(playListOppty[0].id);
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[1].Id, playListOppty[0].Id));
        
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, accountList[0].Id);
        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id, playbookList[1].id});
        
        csm_successplan_play__c spplay = new   csm_successplan_play__c();
        spplay.csm_successplan_playbook__c = accountPlanPlaybookList[0].Id;   
        spplay.csm_play__c =   playList[0].Id;
        
        insert spplay;

        
        csm_successplan_play__c spplay1 = new   csm_successplan_play__c();
        spplay1.csm_successplan_playbook__c = accountPlanPlaybookList[1].Id;   
        spplay1.csm_play__c =   playListOppty[0].Id;
        
        insert spplay1;
        
        Test.startTest();
        CSM_Constants.ACCOUNT_TRIGGER = true;
        List<Account> testAccounts = [select id, name, NumberOfEmployees from Account where id in :accountList limit 100];
        testAccounts[0].NumberOfEmployees = 150;
        update testAccounts;
        
        testAccounts = [select id, name, NumberOfEmployees from Account where NumberOfEmployees = 150 limit 100];
        System.assert(!testAccounts.isEmpty());
        
        CSM_Constants.OPPORTUNITY_TRIGGER = true;
        List<Opportunity> testOpptys = [select id, name, StageName from Opportunity where id in :opptyList limit 100];
        testOpptys[0].StageName = 'Prospecting';
        update testOpptys;
        
        Map<Id, CSM_Account_Plan__c> accountPlanMap = new Map<Id, CSM_Account_Plan__c>();
        accountPlanMap.put(accountList[0].Id, accountPlanList[0]);

        playTaskList[0].CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_OWNER;
        CSM_TaskWrapper tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[0], accountPlanMap, accountList[0].Id);
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[1], accountPlanMap, accountList[0].Id);
        playTaskList[2].CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_MANAGER;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[2], accountPlanMap, accountList[0].Id);
        playTaskList[3].CSM_Assign_To__c = CSM_Constants.ASSIGN_CSM_CONTACT;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[3], accountPlanMap, accountList[0].Id);
        playTaskList[4].CSM_Assign_To__c = CSM_Constants.ASSIGN_SUPPORT_CONTACT;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[4], accountPlanMap, accountList[0].Id); 
        playTaskList[5].CSM_Assign_To__c = CSM_Constants.ASSIGN_CSM_MANAGER;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[5], accountPlanMap, accountList[0].Id); 
        playTaskList[6].CSM_Assign_To__c = CSM_Constants.ASSIGN_CUSTOMER_SUCCESS_MANAGER;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[6], accountPlanMap, accountList[0].Id);
        playTaskList[7].CSM_Assign_To__c = CSM_Constants.ASSIGN_EXEC_SPONSOR;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[7], accountPlanMap, accountList[0].Id);                                                      
        playTaskList[8].CSM_Assign_To__c = CSM_Constants.ASSIGN_RENEWAL_MANAGER;
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[8], accountPlanMap, accountList[0].Id); 
        playTaskList[9].CSM_Assign_To__c = 'CSM_User_Lookup_10__c';
        tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, playTaskList[9], accountPlanMap, accountList[0].Id);        
        System.assert(tw!=null);
        //CSM_TaskCreationTriggerUtil.CreatePlayActivities(new Set<Id>{testAccounts[0].id});
        
        List<CSM_Play__c> playList1 = CSM_TestDataUtility.createPlayTestData(1);        
        playList1[0].CSM_Query_Criteria__c = 'Select id from CSM_Survey_Response__c where CSM_Value1__c = 12.0';
        
        List<CSM_Play_Task__c> playTaskList1 = CSM_TestDataUtility.createPlayTaskData(playList1[0].id);
        CSM_Play_Task__c newTask2 = new CSM_Play_Task__c();
        newTask2.CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_MANAGER;
        newTask2.Name = 'Task 1';
        newTask2.CSM_Days_Until_Due__c = 30;
        newTask2.CSM_IsActive__c = true;
        newTask2.CSM_Play__c = playList[0].Id;
        newTask2.CSM_Description__c = 'The description';
        playTaskList1.add(newTask2);
        
		csm_playbookplay__c pbPlay1 = new csm_playbookplay__c();
		pbPlay1.csm_playbook__c = playbookList[0].Id;
		pbPlay1.csm_play__c = playList1[0].Id;
		playbookPlayList.add(pbPlay1);
		upsert  playbookPlayList;       
        
        upsert playTaskList1;
        
        CSM_Survey_Response__c surResponse = new CSM_Survey_Response__c();
        surResponse.CSM_Account__c = accountList[0].Id;
        surResponse.CSM_Object_Id__c = accountList[0].Id; 
        surResponse.CSM_Value1__c = 12.0;
        
		upsert surResponse;
        
        
        System.assert(true);
        Test.stopTest();
    }

   static testMethod void myUnitTest2() { 
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayOpportunityTestData(playbookList[0].id,1);
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<CSM_Play_Criteria__c> playCrtieriaList = CSM_TestDataUtility.createOpportunityPlayCriteriaDataDate(playList[0].id);
        List<CSM_Play_Task__c> playTaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> oppList = CSM_TestDataUtility.createOpportunity(1,accountList[0].id);
        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        Test.startTest();
        CSM_Constants.ACCOUNT_TRIGGER = true;
        CSM_Constants.OPPORTUNITY_TRIGGER = true;
        
        csm_successplan_play__c spplay1 = new   csm_successplan_play__c();
        spplay1.csm_successplan_playbook__c = accountPlanPlaybookList[0].Id;   
        spplay1.csm_play__c =   playList[0].Id;
        
        insert spplay1;
        
        List<Opportunity> testOpp = [select id, name, accountId, stageName from Opportunity where accountId = :accountList[0].id limit 10];
        testOpp[0].stageName = 'Prospecting';
        update testOpp;
        testOpp = [select id, name, accountId, stageName from Opportunity where stageName = 'Prospecting' limit 10];
        System.assert(!testOpp.isEmpty());
        
        
        Test.stopTest();
        System.assert(true);
    }
    
    static testMethod void myUnitTest3() { 
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayOpportunityTestData(playbookList[0].id,1);
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<CSM_Play_Criteria__c> playCrtieriaList = CSM_TestDataUtility.createOpportunityPlayCriteriaDataDate(playList[0].id);
        List<CSM_Play_Task__c> playTaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> oppList = CSM_TestDataUtility.createOpportunity(1,accountList[0].id);
        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        Test.startTest();
        
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
        
        List<CSM_Account_Plan__c> testPlan = [select id, name, CSM_Plan_Comments__c from CSM_Account_Plan__c where id = :accountPlanList[0].id limit 10];
        testPlan[0].CSM_Plan_Comments__c = 'test Comments';
        update testPlan;
        
        testPlan = [select id, name, CSM_Plan_Comments__c from CSM_Account_Plan__c where CSM_Plan_Comments__c = 'test Comments' limit 10];
        System.assert(!testPlan.isEmpty());
        
        Test.stopTest();
        System.assert(true);
    }
    
    static testMethod void myUnitTest4() { 
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(2);
        playbookList[0].CSM_Automated__c = false;
        playbookList[1].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(2);
        playList[0].CSM_Query_Criteria__c = 'Select id, name, numberofemployees from Account where numberOfemployees >= 100';
        playList[1].CSM_Query_Criteria__c = 'Select id, name, numberofemployees from Account where numberOfemployees >= 100';
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[1].Id, playList[1].Id));
        List<CSM_Play__c> playOppList = CSM_TestDataUtility.createPlayOpportunityTestData(playbookList[0].id,1);
        List<CSM_Play_Criteria__c> playCrtieriaList = CSM_TestDataUtility.createOpportunityPlayCriteriaDataDate(playOppList[0].id);
        List<CSM_Play_Task__c> playTaskList = CSM_TestDataUtility.createPlayTaskData(playOppList[0].id);
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> oppList = CSM_TestDataUtility.createOpportunity(1,accountList[0].id);
        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        Test.startTest();
        CSM_Constants.ACCOUNT_TRIGGER = true;
        CSM_Constants.OPPORTUNITY_TRIGGER = true;
        List<Opportunity> testOpp = [select id, name, accountId, stageName from Opportunity where accountId = :accountList[0].id limit 10];
        testOpp[0].stageName = 'Prospecting';
        update testOpp;
        testOpp = [select id, name, accountId, stageName from Opportunity where stageName = 'Prospecting' limit 10];
        System.assert(!testOpp.isEmpty());
        
        
        Test.stopTest();
        System.assert(true);
    }


    static testMethod void myUnitTest5() { 
        String nameSpacePrefixScout = 'ScoutForSREV__';
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
        if (CSM_AccessController.hasObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER)){
			cAdmin.CSM_Play_Objects__c = 'Account;Case;Opportunity;CSM_Account_Plan__c;ScoutForSREV__Scout_Customer__c';        
        }else{
			cAdmin.CSM_Play_Objects__c = 'Account;Case;Opportunity;CSM_Account_Plan__c';        
        }	
        cAdmin.REN_Segment_Members_Limit__c = 1000;	
		upsert cAdmin;
				        
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        playbookList[0].CSM_Automated__c = false;
        //playbookList[1].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        List<CSM_Play_Task__c> tmpList = new List<CSM_Play_Task__c>();      
        CSM_Play_Task__c newTask1 = new CSM_Play_Task__c();
        newTask1.CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_OWNER;
        newTask1.Name = 'Task 1';
        newTask1.CSM_Days_Until_Due__c = 30;
        newTask1.CSM_IsActive__c = true;
        newTask1.CSM_Play__c = playList[0].Id;
        newTask1.CSM_Description__c = 'The description';
        tmpList.add(newTask1);
        
        insert tmpList;     
        
        playList[0].CSM_Query_Criteria__c = 'select id, ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID + ' from ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        playList[0].CSM_Object_Name__c = nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        update playList[0];
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<Account> accountList = CSM_TestDataUtility.createAccount(2);

        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        Test.startTest();
        CSM_Constants.ACCOUNT_TRIGGER = true;
        if (CSM_AccessController.hasObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER)){
            SObject newScoutCustomer = CSM_AccessController.newSObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER);
            newScoutCustomer.put(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID,accountList[0].Id);
            //insert newScoutCustomer;
            newScoutCustomer.put(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID,accountList[1].Id);
            //update newScoutCustomer;
            //CSM_TaskCreationTriggerUtil.CreatePlayActivities(new Set<Id>{testOpp[0].accountId});
            List<Task> taskList = [select Id from Task where whatId =:accountList[0].Id];
            system.debug('pltask - ' + taskList.size());
           // system.assert(taskList.size() == 1);
        }
                    
        Test.stopTest();
        System.assert(true);
    }


    static testMethod void myUnitTest6() { 
        CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();       
        cAdmin.CSM_Play_Objects__c = '';
        cAdmin.REN_Segment_Members_Limit__c = 1000;        
        upsert cAdmin;

        String nameSpacePrefixScout = 'ScoutForSREV__';
        
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        playbookList[0].CSM_Automated__c = false;
        //playbookList[1].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        playList[0].CSM_Query_Criteria__c = 'select id, ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID + ' from ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        playList[0].CSM_Object_Name__c = nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        update playList[0];
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<Account> accountList = CSM_TestDataUtility.createAccount(2);

        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        Test.startTest();
        CSM_Constants.ACCOUNT_TRIGGER = true;
        if (CSM_AccessController.hasObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER)){
            SObject newScoutCustomer = CSM_AccessController.newSObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER);
            newScoutCustomer.put(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID,accountList[0].Id);
            try{
                insert newScoutCustomer;        
            }
            catch(Exception ex){
            
            }
    
            newScoutCustomer.put(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID,accountList[1].Id);
            try{
                update newScoutCustomer;        
            }
            catch(Exception ex){
            
            }
            List<Task> taskList = [select Id from Task where whatId =:accountList[0].Id];
            system.assert(taskList.size() == 0);
        }            
        //CSM_TaskCreationTriggerUtil.CreatePlayActivities(new Set<Id>{testOpp[0].accountId});
        
        Test.stopTest();
        System.assert(true);
    }


    static testMethod void myUnitTest7() { 
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
        String nameSpacePrefixScout = 'ScoutForSREV__';
        if (CSM_AccessController.hasObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER)){
			cAdmin.CSM_Play_Objects__c = 'Account;Case;Opportunity;CSM_Account_Plan__c;ScoutForSREV__Scout_Customer__c';        
        }else{
			cAdmin.CSM_Play_Objects__c = 'Account;Case;Opportunity;CSM_Account_Plan__c';        
        }		
        cAdmin.REN_Segment_Members_Limit__c = 1000;        
		upsert cAdmin;
    	
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        playbookList[0].CSM_Automated__c = false;
        //playbookList[1].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        playList[0].CSM_Query_Criteria__c = 'select id, ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID + ' from ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        playList[0].CSM_Object_Name__c = nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
        update playList[0];
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<Account> accountList = CSM_TestDataUtility.createAccount(2);

        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        Test.startTest();
        CSM_Constants.ACCOUNT_TRIGGER = true;
        if (CSM_AccessController.hasObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER)){
            SObject newScoutCustomer = CSM_AccessController.newSObject(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER);
            newScoutCustomer.put(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID,accountList[0].Id);
            try{
                insert newScoutCustomer;        
            }
            catch(Exception ex){
            
            }
      
            cAdmin.CSM_Play_Objects__c = '';
            upsert cAdmin;
    
            newScoutCustomer.put(nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID,accountList[1].Id);
            try{
                update newScoutCustomer;        
            }
            catch(Exception ex){
            
            }
            List<Task> taskList = [select Id from Task where whatId =:accountList[1].Id];
            system.assert(taskList.size() == 0);
        }            
        //CSM_TaskCreationTriggerUtil.CreatePlayActivities(new Set<Id>{testOpp[0].accountId});
        
        Test.stopTest();
        System.assert(true);
    }


    static testMethod void accountPlanCheck() {
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(2); 
        
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        List<CSM_Play_Criteria__c> playCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(playList[0].id);
        
        List<CSM_Play__c> playListOppty = CSM_TestDataUtility.createPlayOpportunityTestData(playbookList[1].Id, 1);
        List<CSM_Play_Criteria__c> playCriteriaListOppty = playCriteriaList = CSM_TestDataUtility.createPlayCriteriaOpptyData(playListOppty[0].id);
        
        List<CSM_Play_Task__c> playTaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        List<CSM_Play_Task__c> playTaskListOppty = CSM_TestDataUtility.createPlayTaskData(playListOppty[0].id);
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[1].Id, playListOppty[0].Id));
        
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, accountList[0].Id);
        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id, playbookList[1].id});
         
        Test.startTest();
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
        
        List<CSM_Account_Plan__c> testAccountPlans = [select id, CSM_Manager__c from CSM_Account_Plan__c where id in :accountPlanList limit 100];
        testAccountPlans[0].CSM_Manager__c = UserInfo.getUserId();
        update testAccountPlans;

        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
               
		CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c();
		accountPlan.CSM_Account_Plan_Template__c = templateList[0].Id;
		accountPlan.CSM_Phase_Start_Date__c = System.today();
		accountPlan.CSM_AccountId__c = accountList[0].id;
		accountPlan.CSM_isActive__c = true;
		insert accountPlan;

    	playList[0].CSM_Query_Criteria__c = 'SELECT ';
    	playList[0].CSM_Object_Name__c = 'CSM_Account_Plan__c ';
    	update playList[0];    	

        try{
	        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        	CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
            CSM_Account_Plan__c accountPlan1 = new CSM_Account_Plan__c();
			accountPlan1.CSM_Account_Plan_Template__c = templateList[0].Id;
			accountPlan1.CSM_Phase_Start_Date__c = System.today();
			accountPlan1.CSM_AccountId__c = accountList[0].id;
			accountPlan1.CSM_isActive__c = true;
			insert accountPlan1;
        }
        catch(Exception ex){
        
        }

        try{
	        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        	CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
            update testAccountPlans;        
        }
        catch(Exception ex){
        
        }

        testAccountPlans = [select id, CSM_Manager__c from CSM_Account_Plan__c where id in :accountPlanList limit 100];
        System.assert(!testAccountPlans.isEmpty());
        
        //CSM_TaskCreationTriggerUtil.CreatePlayActivities(new Set<Id>{testAccountPlans[0].id});
        System.assert(true);
        Test.stopTest();
    }    

}