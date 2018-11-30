@istest
public with sharing class CSM_PlayTasksComponentCtrlTest {

	static testMethod void testPlayTasks(){
		CSM_TestUtility.setup();

		CSM_PlayTasksComponentController ptCmpCtrl = new CSM_PlayTasksComponentController();
		ptCmpCtrl.accountPlanId = CSM_TestUtility.acctPlan.Id;
		ptCmpCtrl.accountId = CSM_TestUtility.acct.Id;
		ptCmpCtrl.taskId = CSM_TestUtility.tsk.Id;
		PageReference ref = ptCmpCtrl.setTaskInfo();
		System.assert(ref==null);
		
		ptCmpCtrl.whatIdVal = ptCmpCtrl.accountPlanId;
		ref = ptCmpCtrl.emailToWhatId(); 
		System.assert(ref!=null);
		
		ref = ptCmpCtrl.redirectToTask();
		System.assert(ref!=null);
		
		ptCmpCtrl.followUpTask = true;
		ptCmpCtrl.isComplete = true;
		ptCmpCtrl.setTaskAndShowPopup();		
		ref = ptCmpCtrl.completeDismissTask();
		//System.assert(ref!=null);
		
		ptCmpCtrl.accountSelected = CSM_TestUtility.acct.Id;
		ref = ptCmpCtrl.updateWidget();
		System.assert(ref==null);
		
		ref = ptCmpCtrl.updateTabs();
		System.assert(ref==null);
		
		ref = ptCmpCtrl.addPlayBook();
		System.assert(ref==null);
		
		ref = ptCmpCtrl.getTaskForPlanId();
		System.assert(ref==null);
		System.assert(ptCmpCtrl.getThis()!=null);
		
		CSM_Account_Plan_Template__c accPlanTemp = CSM_TestDataUtility.createAccountPlanTemplateData(1)[0];
		List<Account> accList = new List<Account>();
		Account acc = new Account();
		acc.Id = ptCmpCtrl.accountSelected;
		accList.add(acc);
		ptCmpCtrl.successPlanList = CSM_TestDataUtility.createAccountPlan(accList, accPlanTemp.Id);
		ref = ptCmpCtrl.newTaskDetails();
		System.assert(ref==null);	

		ref=ptCmpCtrl.getValidateSuccessPlan();
        System.assert(ref==null);	
				
		ref = ptCmpCtrl.createNewTask();
		//System.assert(ref!=null);
		ptCmpCtrl.setEmailTask();
		ptCmpCtrl.resetTask();
		ptCmpCtrl.resetWidgetForNewTask();
		ptCmpCtrl.setEmailTask();
		ptCmpCtrl.createNewTask();
		ptCmpCtrl.completeDismissTask();
		ptCmpCtrl.createNewTask();
		
		CSM_User_Preferences__c userPrefRecord = new CSM_User_Preferences__c();
		userPrefRecord.CSM_User__c = UserInfo.getUserId();
        userPrefRecord.CSM_Success_Plan_Actions_Filter__c = 'All';
        insert userPrefRecord;
        
        ptCmpCtrl = new CSM_PlayTasksComponentController();
		
		Test.startTest();
		//ptCmpCtrl.columnList = 'ownerid';
        //ptCmpCtrl.selectedColumns = 'subject';
                
        PageReference userPref = ptCmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref==null);
        
        //ptCmpCtrl.columnList = 'ownerid,subject';
        //ptCmpCtrl.selectedColumns = '';
        ptCmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref1 = ptCmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref1==null);
        
        //ptCmpCtrl.columnList = 'ownerid';
        //ptCmpCtrl.selectedColumns = '';
        ptCmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref2 = ptCmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref2==null);
        
        //ptCmpCtrl.columnList = 'ownerid';
        //ptCmpCtrl.selectedColumns = 'ownerid';
        ptCmpCtrl.hiddenColumns = '';
        
        PageReference userPref3 = ptCmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref3==null);
        
        //ptCmpCtrl.saveFilterToUserPreference();
        //System.assert(userPref4==null);
        
        //ptCmpCtrl.columnList = 'subject,ownerid';
        //ptCmpCtrl.selectedColumns = '';
        ptCmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref5 = ptCmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref5==null);
        
        //ptCmpCtrl.columnList = 'activitydate,subject,ownerid';
        //ptCmpCtrl.selectedColumns = '';
        ptCmpCtrl.hiddenColumns = 'subject';
        
        PageReference userPref6 = ptCmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref6==null);
        
        PageReference userPref7 = ptCmpCtrl.getClosedStatus();
        System.assert(userPref7==null);
        
        PageReference userPref8 = ptCmpCtrl.resetPopupForNewTask();
        System.assert(userPref8==null);
        
        List<SelectOption> optList = ptCmpCtrl.getPlayOutcomeValues();
		System.assert(optList != null);
		
		List<SelectOption> optListRecordTypes = ptCmpCtrl.getRecordTypes();
		System.assert(optListRecordTypes != null);
          
        List<SelectOption> optListStatus = ptCmpCtrl.getTaskStatus();
		System.assert(optListStatus != null);
        
		Test.stopTest();
	}
	
	static testMethod void testPlayTasks_Negative() {
        Test.startTest();   
        User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
			CSM_User_Preferences__c userPrefRecord = new CSM_User_Preferences__c();
			userPrefRecord.CSM_User__c = UserInfo.getUserId();
        	userPrefRecord.CSM_Success_Plan_Actions_Filter__c = 'All';
        	insert userPrefRecord;
			CSM_PlayTasksComponentController cmpCtrl = new CSM_PlayTasksComponentController();
			//cmpCtrl.columnList = '';
        	//cmpCtrl.selectedColumns = '';
        	cmpCtrl.hiddenColumns = 'subject';
    		system.runAs(restrictedUser){
	        
        		PageReference pageRef = cmpCtrl.saveColumnsToUserPreference();
        		System.assert(pageRef==null);
        		
        		PageReference pageRef1 = cmpCtrl.resetWidgetForNewTask();
        		System.assert(pageRef1==null);
                
                 PageReference pageRef2 = cmpCtrl.saveColumnsToUserPreference();
                 System.assert(pageRef2==null);
                
                PageReference pageRef3 = cmpCtrl.saveColumnsToUserPreference();
                System.assert(pageRef3==null);
                
                PageReference pageRef5 = CmpCtrl.saveColumnsToUserPreference();
        		System.assert(pageRef5==null);
                
                PageReference pagePref6 = CmpCtrl.saveColumnsToUserPreference();
       			System.assert(pagePref6==null);
                
                PageReference pageRef7 = cmpCtrl.getClosedStatus();
                System.assert(pageRef7==null);
                
                PageReference pageRef8 = cmpCtrl.resetPopupForNewTask();
                System.assert(pageRef8==null);
                
                List<SelectOption> optList = CmpCtrl.getPlayOutcomeValues();
				System.assert(optList != null);
                
                

    		}
		Test.stopTest();
	}
}