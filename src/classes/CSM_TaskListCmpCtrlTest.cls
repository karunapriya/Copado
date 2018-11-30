@isTest
public with sharing class CSM_TaskListCmpCtrlTest {

    static testMethod void testCustomerSuccessPage() {
        
        CSM_TestUtility.setup();        
        CSM_Constants.TASK_TRIGGER = true;
        Test.startTest();   
        Test.setCurrentPage(Page.CSM_TaskList);
        
        CSM_TaskListController controller = new CSM_TaskListController();

        //System.assert(controller.hasCSMAccess==true);
        
        CSM_TaskListComponentController cmpCtrl = new CSM_TaskListComponentController();
                
        cmpCtrl.taskViewId = CSM_TestUtility.focusCategoryViewTask.Id;
        cmpCtrl.getListTask();
        cmpCtrl.isMultiple = false;
        cmpCtrl.isComplete = false;        
        cmpCtrl.taskId = CSM_TestUtility.tsk.id;
        cmpCtrl.taskVal = CSM_TestUtility.tsk;

        cmpCtrl.contextItem = CSM_TestUtility.tsk.Id;
        cmpCtrl.doSelectItem();
        cmpCtrl.taskIds = CSM_TestUtility.tsk.Id;
        cmpCtrl.setTaskIds();
        
        //cmpCtrl.taskList.add(CSM_TestUtility.tsk);
        cmpCtrl.buildTaskWrapper();
        List<CSM_TaskListComponentController.TRowItem> tskList = cmpCtrl.getListTask();
        System.assert(tskList==null);
        PageReference pageRef1 = cmpCtrl.selectedTask();
        System.assert(pageRef1==null);
        
        PageReference pageRef2 = cmpCtrl.setTaskInfo();
        System.assert(pageRef2==null);
        
        PageReference pageRef3 = cmpCtrl.createNewFocusCategory();
        System.assert(pageRef3!=null);
        
        CSM_Account_Plan_Template__c accPlanTemp = CSM_TestDataUtility.createAccountPlanTemplateData(1)[0];
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Id = CSM_TestUtility.acct.Id;//cmpCtrl.accountSelected;
        accList.add(acc);
        cmpCtrl.successPlanList = CSM_TestDataUtility.createAccountPlan(accList, accPlanTemp.Id);
        
        PageReference newTaskPageRef = cmpCtrl.newTaskDetails();
        System.assert(newTaskPageRef==null);
        
        PageReference pageRef4 = cmpCtrl.createNewTask();
        System.assert(pageRef4==null);
        
        PageReference pageRef5 = cmpCtrl.emailToWhatId();
        System.assert(pageRef5!=null);
        
        cmpCtrl.followUpTask = false;
        PageReference pageRef6 = cmpCtrl.completeDismissTask();
        System.assert(pageRef6==null);
        
        cmpCtrl.followUpTask = true;
		cmpCtrl.taskVal.ownerId = UserInfo.getUserId();        		      
        PageReference pageRef7 = cmpCtrl.completeDismissTask();
        //System.assert(pageRef7!=null);
        
        PageReference editRef = cmpCtrl.editNewFocusCategory();
        System.assert(editRef != null);
        
        PageReference resetRef = cmpCtrl.resetTask();
        System.assert(resetRef == null);
                
        List<SelectOption> optList =  cmpCtrl.getPlayOutcomeValues();
		System.assert(optList != null);
		
		List<SelectOption> optListRecordTypes = CmpCtrl.getRecordTypes();
		System.assert(optListRecordTypes != null);
          
        List<SelectOption> optListStatus = CmpCtrl.getTaskStatus();
		System.assert(optListStatus != null);
		
		PageReference statusRef = cmpCtrl.getClosedStatus();
		System.assert(statusRef == null);
		//cmpCtrl.columnList = 'ownerid';
        //cmpCtrl.selectedColumns = 'subject';
                
        PageReference userPref = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref==null);
        
        //cmpCtrl.columnList = 'ownerid,subject';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref1 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref1==null);
        
        //cmpCtrl.columnList = 'ownerid';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref2 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref2==null);
        
        //cmpCtrl.columnList = 'ownerid';
        //cmpCtrl.selectedColumns = 'ownerid';
        cmpCtrl.hiddenColumns = '';
        
        PageReference userPref3 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref3==null);
        
        PageReference userPref4 = cmpCtrl.resetWidgetForNewTask();
        System.assert(userPref4==null);
        
        //cmpCtrl.columnList = 'subject,ownerid';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref5 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref5==null);
        
        //cmpCtrl.columnList = 'activitydate,subject,ownerid';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref6 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref6==null);
        
        //PageReference userPref7 = cmpCtrl.setColumnList();
        //System.assert(userPref7==null);
        
        cmpCtrl.contextItem = cmpCtrl.taskViewId;
        System.assert(cmpCtrl.selectedTaskIds!=null);
        
        cmpCtrl.accountPlanId = CSM_TestUtility.acctPlan.Id;
        PageReference acctRef = cmpCtrl.redirectToAccountPlan();
        System.assert(acctRef!=null);
        
        cmpCtrl.accountSelected = CSM_TestUtility.acct.Id;
        cmpCtrl.doSelectItem();
        cmpCtrl.doDeselectItem();
        cmpCtrl.updateWidget();
        
        cmpCtrl.taskId = CSM_TestUtility.tsk.Id;
        PageReference taskRef = cmpCtrl.redirectToTask();
        System.assert(taskRef!=null);
        
        PageReference pageRef8 = cmpCtrl.resetWidgetForNewTask();
        System.assert(pageRef8==null);
        
        PageReference pageRef9 = cmpCtrl.resetPopupForNewTask();
        System.assert(pageRef9==null);
        
        pageRef9 = cmpCtrl.setEmailTask();
        System.assert(pageRef9!=null);
        
        pageRef9 = cmpCtrl.findAccountForPlan();
        System.assert(pageRef9==null);
        
        cmpCtrl.taskViewId = null;
        pageRef9 = cmpCtrl.selectedTask();
        System.assert(pageRef9==null);
        
        Test.stopTest();
    }
    
    static testMethod void testCustomerSuccessPageNeg() {
        
        CSM_TestUtility.setup();        
        CSM_Constants.TASK_TRIGGER = true;
        Test.startTest();   
        Test.setCurrentPage(Page.CSM_TaskList);
        
        CSM_TaskListController controller = new CSM_TaskListController();

        //System.assert(controller.hasCSMAccess==true);
        
        CSM_TaskListComponentController cmpCtrl = new CSM_TaskListComponentController();
                
        cmpCtrl.taskViewId = CSM_TestUtility.focusCategoryViewTask.Id;
        cmpCtrl.getListTask();
        cmpCtrl.isMultiple = false;
        cmpCtrl.isComplete = false;        
        cmpCtrl.taskId = CSM_TestUtility.tsk.id;
        cmpCtrl.taskVal = CSM_TestUtility.tsk;

        cmpCtrl.contextItem = CSM_TestUtility.tsk.Id;
        cmpCtrl.doSelectItem();
        cmpCtrl.taskIds = CSM_TestUtility.tsk.Id;
        cmpCtrl.setTaskIds();
        
        //cmpCtrl.taskList.add(CSM_TestUtility.tsk);
        cmpCtrl.buildTaskWrapper();
        List<CSM_TaskListComponentController.TRowItem> tskList = cmpCtrl.getListTask();
        System.assert(tskList==null);
        
        //cmpCtrl.columnList = 'activitydate,subject,ownerid';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'subject';
        
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
	        PageReference pageRef1 = cmpCtrl.selectedTask();
	        System.assert(pageRef1==null);
	        
	        PageReference pageRef2 = cmpCtrl.completeDismissTask();
	        System.assert(pageRef2==null);
	        
	        cmpCtrl.newTask = null;
	        PageReference pageRef3 = cmpCtrl.createNewTask();
	        System.assert(pageRef3==null);
	        
        	PageReference pageRef4 = cmpCtrl.saveColumnsToUserPreference();
        	System.assert(pageRef4==null);
        	
        	PageReference pageRef5 = cmpCtrl.resetWidgetForNewTask();
        	System.assert(pageRef5==null);
        	
        	List<SelectOption> optListRecordTypes = cmpCtrl.getRecordTypes();
			System.assert(optListRecordTypes != null);
    	}
       
        Test.stopTest();
    }
    
    
    static testMethod void testCustomerSuccessPage1() {
        CSM_TestUtility.setup();        
        CSM_Constants.TASK_TRIGGER = true;
        Test.startTest();   
	        Test.setCurrentPage(Page.CSM_TaskList);
	        
	        CSM_TaskListController controller = new CSM_TaskListController();
	        CSM_TaskListComponentController cmpCtrl = new CSM_TaskListComponentController();
	        cmpCtrl.taskViewId = CSM_TestUtility.focusCategoryViewTask.Id;
	        System.assert(cmpCtrl!=null);
	        
	        CSM_Account_Plan_Template__c accPlanTemp = CSM_TestDataUtility.createAccountPlanTemplateData(1)[0];
	        List<Account> accList = new List<Account>();
	        Account acc = new Account();
	        acc.Id = CSM_TestUtility.acct.Id;
	        accList.add(acc);
	        cmpCtrl.successPlanList = CSM_TestDataUtility.createAccountPlan(accList, accPlanTemp.Id);
	        
	        PageReference newTaskPageRef = cmpCtrl.newTaskDetails();
	        
	        cmpCtrl.populateAccountRelatedToSPPL();
	        cmpCtrl.saveSearchToUserPreference();
	        cmpCtrl.saveTaskPageSizeToUserPreference();
	        cmpCtrl.deleteFCV();
        Test.stopTest();
    }
    
}