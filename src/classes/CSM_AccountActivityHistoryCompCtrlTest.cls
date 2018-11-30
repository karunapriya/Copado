@isTest
private class CSM_AccountActivityHistoryCompCtrlTest {

    static testMethod void testActivityStreamTab() {
       CSM_AccountActivityHistoryCompCtrl cmpCtrl = new CSM_AccountActivityHistoryCompCtrl();
       
        //cmpCtrl.columnList = 'ownerid';
        //cmpCtrl.selectedColumns = 'subject';
        
        Account acct = new Account();
		acct.Name = 'Test Account Activity';
		acct.BillingState = 'GA';
		insert acct;
		System.assert(acct.Id != null);
		cmpCtrl.accountHistoryId = acct.Id;
		
                
        PageReference userPref = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref==null);
        
        //cmpCtrl.columnList = 'ownerid,subject';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'ownerid,subject';
        
        PageReference userPref1 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref1==null);
        
        //cmpCtrl.columnList = 'ownerid';
        //cmpCtrl.selectedColumns = '';
        cmpCtrl.hiddenColumns = 'ownerid';
        
        PageReference userPref2 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref2==null);
        
        //cmpCtrl.columnList = 'ownerid';
        //cmpCtrl.selectedColumns = 'ownerid';
        cmpCtrl.hiddenColumns = '';
        
        PageReference userPref3 = cmpCtrl.saveColumnsToUserPreference();
        System.assert(userPref3==null);
        
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
    }
    static testMethod void testActivityStreamTab_Negative() {
    	
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	
    	CSM_AccountActivityHistoryCompCtrl cmpCtrl = new CSM_AccountActivityHistoryCompCtrl();
    	
    	system.runAs(restrictedUser) {
    		
    		//cmpCtrl.columnList = '';
        	//cmpCtrl.selectedColumns = '';
        	cmpCtrl.hiddenColumns = '';
    		
        	PageReference userPref = cmpCtrl.saveColumnsToUserPreference();
        	System.assert(userPref==null);
    	}
    }
}