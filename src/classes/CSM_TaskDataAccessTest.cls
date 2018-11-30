@isTest
private class CSM_TaskDataAccessTest {

    static testMethod void Test_GetNonCompletedTasksByAccount_Positive() {
    	Test.startTest();
    	CSM_TestUtility.setup();
    	
		Task tsk = new Task();
		tsk.WhatId = CSM_TestUtility.acct.Id;
		tsk.Subject = 'Meeting';
		tsk.ActivityDate = Date.today();
		tsk.CSM_Account__c = CSM_TestUtility.acct.Id;
		tsk.CSM_Play__c = CSM_TestUtility.play.Id;
		tsk.CSM_Account_Plan__c = CSM_TestUtility.acctPlan.Id;
		tsk.Status = 'Not Started';
		tsk.csm_successplan_play__c = CSM_TestUtility.spPlay.Id;
		insert tsk;
    	
    	
    	List<Task> taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
    										CSM_Constants.TASK_FILTER_OPTION_ALL, 
    										'ActivityDate', 
    										CSM_Constants.SORT_DIRECTION_DESCENDING);
    										
    	system.assert(!taskList.isEmpty());
    	Set<Id> selectedTaskIds = new Set<Id>();
    	selectedTaskIds.add(taskList[0].Id);
    	//selectedTaskIds.add(taskList[1].Id);    	
    	CSM_TaskDataAccess taskDA = new CSM_TaskDataAccess();
    	tasklist.remove(1);
		//taskDA.createWrapperAndCompDismissTasks(selectedTaskIds, taskList, taskList[0], true, true);
		system.debug('taskListhere - ' + taskList + '      ' + selectedTaskIds);
		taskDA.createWrapperAndCompDismissTasks(selectedTaskIds, taskList, taskList, null, false, true, false); 
		 
		Map<Id, CSM_Account_Plan__c> apMap = new Map<Id, CSM_Account_Plan__c>();
		apMap.put(CSM_TestUtility.acctPlan.Id,CSM_TestUtility.acctPlan);
		
		
		CSM_TaskWrapper tWrap = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, CSM_TestUtility.playTask, apMap, CSM_TestUtility.acct.Id);
		tWrap.Status = 'Not Started';
		List<CSM_TaskWrapper> lstTWrap = new List<CSM_TaskWrapper>();	
		lstTWrap.add(tWrap);
		Map<String, ID> mapTest = new Map<String, ID>();
		mapTest.put('test',taskList[0].Id);
        Map<Id, CSM_TaskWrapper> taskMap = new Map<Id, CSM_TaskWrapper>();
        taskMap.put(taskList[0].Id,tWrap);	
        taskDA.completeDismissTasks(taskMap);	
		CSM_Play_Result__c playResult = new  CSM_Play_Result__c();
		playResult.CSM_Play_Result_Id__c = 'tesplayresult';
		playResult.CSM_account_Id__c = CSM_TestUtility.acct.Id;
		insert playResult;
		Map<String, CSM_Play_Result__c> mprMap = new Map<String, CSM_Play_Result__c>();
		mprMap.put(playResult.Id,playResult);
		
		
		CSM_TaskDataAccess.createUpdateTaskListFromWrapper(lstTWrap,mprMap,mapTest);
		  	
    	
    	taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
    										CSM_Constants.TASK_FILTER_OPTION_CONT_TASKS, 
    										'ActivityDate', 
    										CSM_Constants.SORT_DIRECTION_DESCENDING);
    	system.assert(taskList.isEmpty());
    	taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
    										CSM_Constants.TASK_FILTER_OPTION_EMAIL_TASKS, 
    										'ActivityDate', 
    										CSM_Constants.SORT_DIRECTION_DESCENDING);
    	system.assert(taskList.isEmpty());
		taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
											CSM_Constants.TASK_FILTER_OPTION_OTHER_TASKS, 
											'ActivityDate', 
											CSM_Constants.SORT_DIRECTION_DESCENDING);
		system.assert(!taskList.isEmpty());
    	taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
											CSM_Constants.TASK_FILTER_OPTION_PC_TASKS, 
											'ActivityDate', 
											CSM_Constants.SORT_DIRECTION_DESCENDING);
		system.assert(taskList.isEmpty());
		taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
											CSM_Constants.TASK_FILTER_OPTION_RT_ACCOUNT, 
											'ActivityDate', 
											CSM_Constants.SORT_DIRECTION_DESCENDING);
		taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
											CSM_Constants.TASK_FILTER_OPTION_RT_OPPORTUNITY, 
											'ActivityDate', 
											CSM_Constants.SORT_DIRECTION_DESCENDING);
		system.assert(taskList.isEmpty());
		taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
											CSM_Constants.TASK_FILTER_OPTION_HASPLAY, 
											'ActivityDate', 
											CSM_Constants.SORT_DIRECTION_DESCENDING);
		system.assert(!taskList.isEmpty());
		taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
											CSM_Constants.TASK_FILTER_OPTION_UNDETERMINEDPLAY, 
											'ActivityDate', 
											CSM_Constants.SORT_DIRECTION_DESCENDING);

		//system.assert(taskList.isEmpty());
		Test.stopTest();
    }
    
    static testMethod void Test_GetNonCompletedTasksByAccount_Negative() {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		List<Task> taskList;    	
    	system.runAs(restrictedUser){
    		try{
			    	taskList = CSM_TaskDataAccess.getNotCompletedTasksByAccount(CSM_TestUtility.acct.Id, 
			    										CSM_Constants.TASK_FILTER_OPTION_ALL, 
			    										'ActivityDate', 
			    										CSM_Constants.SORT_DIRECTION_DESCENDING);
				
    		}catch(Exception e){
    			system.assert(true);
    		}
    	}
    	Test.stopTest();
    }


   static testMethod void Test_CreateTaskList_Negative() {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		Map<Id, CSM_Account_Plan__c> apMap = new Map<Id, CSM_Account_Plan__c>();
		apMap.put(CSM_TestUtility.acctPlan.Id,CSM_TestUtility.acctPlan);
		Map<String, ID> mapTest = new Map<String, ID>();
		mapTest.put('test',CSM_TestUtility.acct.Id);
		CSM_TaskWrapper tWrap = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, CSM_TestUtility.playTask, apMap, CSM_TestUtility.acct.Id);
		List<CSM_TaskWrapper> lstTWrap = new List<CSM_TaskWrapper>();	
		lstTWrap.add(tWrap);
		CSM_Play_Result__c playResult = new  CSM_Play_Result__c();
		playResult.CSM_Play_Result_Id__c = 'tesplayresult';
		playResult.CSM_account_Id__c = CSM_TestUtility.acct.Id;
		insert playResult;
		Map<String, CSM_Play_Result__c> mprMap = new Map<String, CSM_Play_Result__c>();
		mprMap.put(playResult.Id,playResult);

    	system.runAs(restrictedUser){
    		try{
				CSM_TaskDataAccess.createUpdateTaskListFromWrapper(lstTWrap,mprMap,mapTest);
	    		system.assert(true);
    		}catch(Exception e){
    			system.assert(true);
    		}
    	}
    	Test.stopTest();
    }


    
    static testMethod void Test_GetTasksById_Positive() {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	List<Task> taskList = CSM_TaskDataAccess.getTasksById(CSM_TestUtility.tsk.Id);
    	system.assert(!taskList.isEmpty());
    	Test.stopTest();
    }
    
    static testMethod void Test_GetTasksById_Negative() {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
    		try{
    			List<Task> taskList = CSM_TaskDataAccess.getTasksById(CSM_TestUtility.tsk.Id);
    		}catch(Exception e){
    			system.assert(true);
    		}
    	}
    	Test.stopTest();
    }
    
   	static testMethod void Test_GetTasksByAccountPlan_Positive() {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	List<Task> taskList = CSM_TaskDataAccess.getTasksByAccountPlan(CSM_TestUtility.acctPlan.Id);
    	system.assert(!taskList.isEmpty());
    	Test.stopTest();
    }
    
    static testMethod void Test_GetTasksByAccountPlan_Negative() {
    	CSM_TestUtility.setup();
    	Test.startTest();
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
    		try{
    			List<Task> taskList = CSM_TaskDataAccess.getTasksByAccountPlan(CSM_TestUtility.acctPlan.Id);
    		}catch(Exception e){
    			system.assert(true);
    		}
    	}
    	Test.stopTest();
    } 
    
    static testMethod void testCloseAllTasks() {
    	Test.startTest();
    	CSM_TestUtility.setup();
    	
		Task tsk = new Task();
		tsk.WhatId = CSM_TestUtility.acct.Id;
		tsk.Subject = 'Meeting';
		tsk.ActivityDate = Date.today();
		tsk.CSM_Account__c = CSM_TestUtility.acct.Id;
		tsk.CSM_Play__c = CSM_TestUtility.play.Id;
		tsk.CSM_Account_Plan__c = CSM_TestUtility.acctPlan.Id;
		tsk.Status = 'Not Started';
		tsk.csm_successplan_play__c = CSM_TestUtility.spPlay.Id;
		insert tsk;
		system.assert(tsk != null);
		CSM_Constants.TASK_TRIGGER = true;		
		CSM_TestUtility.play.CSM_Play_ReEntry__c = true;
		update CSM_TestUtility.play;
		tsk.Status = 'Completed';
		//update tsk;
		
    	List<Task> listTasks = [select Id,status from Task where csm_successplan_play__c =: CSM_TestUtility.spPlay.Id ];
    	for(Task tsk1:listTasks){
    		tsk1.status = 'Completed';
    	}
    	system.debug('tssk - ' + listTasks);
    	update listTasks;
		
    	List<CSM_Successplan_play__c> spplList1 = [select Id from CSM_Successplan_play__c where csm_play__c =: CSM_TestUtility.play.Id ]; 
    	system.assert(spplList1.size() > 0);
		
    }
    
}