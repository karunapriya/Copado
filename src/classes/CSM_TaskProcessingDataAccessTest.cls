/**
 This is only a stop-gap test class.
 */
@isTest
private class CSM_TaskProcessingDataAccessTest
{
	static testMethod void testAll()
	{
		Set<String> validAccountPlayIdsList = new Set<String>(); 
		Set<Id> accountList = new Set<Id>(); 
		
		Account testAccount = new Account(Name = 'Test Account ServiceSource');
		insert testAccount;
		
		List<Task> lstTasks = new List<Task>();
		Task task = new Task();     
        task.Subject = 'Hello';
        task.WhatId = testAccount.Id;
        task.ActivityDate = System.today();        
        insert task;
        lstTasks.add(task);

		task = new Task();     
        task.Subject = 'World';
        task.WhatId = testAccount.Id;
        task.ActivityDate = System.today();        
        insert task;
        lstTasks.add(task);        
        
		Test.StartTest();
        boolean createTasklst = CSM_TaskProcessingDataAccess.createTaskProcessing(lstTasks);

		task = new Task();     
        task.Subject = 'World';
        task.WhatId = testAccount.Id;
        task.ActivityDate = System.today();        
        insert task;
        lstTasks.add(task);        

        CSM_TaskProcessingDataAccess.createTaskProcessing(lstTasks, new Map<String, CSM_Play_Result__c>());
        
        List<CSM_Task_Processing__c> lstTaskProcessing = CSM_TaskProcessingDataAccess.getTasksById(new List<CSM_Play_Task__c>());
        
        CSM_TaskProcessingDataAccess.updateTaskProcessingStatus(new Set<Id>());
        
        List<CSM_Task_Processing__c> lstTaskProcessingActive = 	CSM_TaskProcessingDataAccess.getActiveTasks(validAccountPlayIdsList, accountList);
        
        system.assertequals(createTasklst, true);
        
        lstTasks[0].CSM_Play__c = '000000010000000000';
        CSM_TaskProcessingDataAccess.createTaskProcessing(lstTasks, new Map<String, CSM_Play_Result__c>());
                
        User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
        boolean rcreateTasklst = false;
        system.runAs(restrictedUser){
           		try{
        			rcreateTasklst = CSM_TaskProcessingDataAccess.createTaskProcessing(lstTasks);           		
           		}catch(Exception ex){
           		
           		}

           		try{
		        	CSM_TaskProcessingDataAccess.createTaskProcessing(lstTasks, new Map<String, CSM_Play_Result__c>());           		
           		}catch(Exception ex){
           		
           		}
        		           

           		try{
		       		List<CSM_Task_Processing__c> rlstTaskProcessing = CSM_TaskProcessingDataAccess.getTasksById(new List<CSM_Play_Task__c>());           		
           		}catch(Exception ex){
           		
           		}
		        

           		try{
		        	CSM_TaskProcessingDataAccess.updateTaskProcessingStatus(new Set<Id>());           		
           		}catch(Exception ex){
           		
           		}
		        

           		try{
		        	List<CSM_Task_Processing__c> rlstTaskProcessingActive = 	CSM_TaskProcessingDataAccess.getActiveTasks(validAccountPlayIdsList, accountList);           		
           		}catch(Exception ex){
           		
           		}
		        system.assertequals(rcreateTasklst, false);
        }
       // system.assert(lstTaskProcessing.size() > 0);        
        //system.assert(lstTaskProcessingActive.size() > 0);        
        
        Test.StopTest();
        
	}
}