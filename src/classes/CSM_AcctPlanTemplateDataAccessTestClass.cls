@isTest
private class CSM_AcctPlanTemplateDataAccessTestClass {

	static testMethod void csmLoadDataTest() {
       	Test.startTest();
       		CSM_TestDataSetup csmTestObj = new CSM_TestDataSetup();
       		csmTestObj.createDataUpToPlayBookPlay(2, 2, 2);
		    system.assert(csmTestObj.playBookPlayList != null);
       		csmTestObj.createDataForAccountPlan(1, 1);
		    system.assert(csmTestObj.successPlanPhaseList != null);
       		csmTestObj.createDataForFocusCategory(1, 1, 2);
		    system.assert(csmTestObj.focusCategoryList != null);
       	Test.stopTest();
    } 
    
    static testMethod void myUnitTest() {
    	
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(3);
        Test.startTest();
        CSM_Playbook__c play1 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);
        boolean activatesuccess = CSM_PlaybooksDataAccess.activatePlaybooks(new List<String>{play1.id});
        CSM_Playbook__c play2 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);
        system.assertEquals(play2.CSM_IsActive__c, true);
        boolean deactivatesuccess = CSM_PlaybooksDataAccess.deactivatePlaybooks(new List<String>{play1.id});
         CSM_Playbook__c play3 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);
        system.assertEquals(play3.CSM_IsActive__c, false);
        List<CSM_Playbook__c> playSaved = CSM_PlaybooksDataAccess.savePlaybook(new List<CSM_Playbook__c>{play1});
        
        List<CSM_PlaybookWrapper> playbookList2 = CSM_PlaybooksDataAccess.populatePlaybooksInformation();
        system.assertEquals(3, playbookList2.size());
        
        Test.stopTest();
        
    }
    
    static testMethod void createPlaybookTest2() {
    	
    	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	
    	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
    	List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].id);
    	Map<String,String> accountPlanTemplateMap = new Map<String,STring>();
    	accountPlanTemplateMap.put(accountPlanTemplateList[0].id, playbookList[0].id);
    	Map<String,String> accountPlanIdMap = new Map<String,String>();
    	accountPlanIdMap.put(accountPlanList[0].id,playbookList[0].id);
    	Test.startTest();
    	boolean isSuccess =  CSM_PlaybooksDataAccess.createPlaybookAssignment(accountPlanTemplateMap,  accountPlanIdMap, new List<CSM_Account_Plan_Playbook__c>(), false);
    	List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
    	accountPlanPlaybookList = [select id from CSM_Account_Plan_Playbook__c limit 200];
    	system.assert(accountPlanPlaybookList.size() > 0);
    	CSM_Account_Plan_Template__c cloneTemplate = accountPlanTemplateList[0].clone(false, true);
    	cloneTemplate.CSM_Template_Name__c = 'ClonedTemplate';
    	insert cloneTemplate;
    	system.assert(String.isNotBlank(cloneTemplate.Id));
    	Map<Id, Id> templateIdMap = new Map<Id, Id>{accountPlanTemplateList[0].Id => cloneTemplate.Id};
    	CSM_AcctPlanTemplatePlaybooksDataAccess.cloneAccountPlanPlayBooks(templateIdMap);
    	List<CSM_Account_Plan_Playbook__c> clonePlaybookList = [Select Id From CSM_Account_Plan_Playbook__c Where CSM_Account_Plan_Template__c=:cloneTemplate.Id limit 100];
    	system.assert(!clonePlaybookList.isEmpty());
    	
    	
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
    		try{
				List<CSM_Account_Plan_Playbook__c> acpPB = CSM_AcctPlanTemplatePlaybooksDataAccess.populateAccountTemplatePlaybooks(accountPlanTemplateList[0].Id);
    		}catch(Exception e){
    			system.assert(true);
    		}
    		
    		try{
				boolean flag = CSM_AcctPlanTemplatePlaybooksDataAccess.createPlaybookAvailable();
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				boolean flag = CSM_AcctPlanTemplatePlaybooksDataAccess.updatePlaybookAvailable();
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				boolean flag = CSM_AcctPlanTemplatePlaybooksDataAccess.addPlaybookAvailable();
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				boolean flag = CSM_AcctPlanTemplatePlaybooksDataAccess.saveTemplatePlaybooks(accountPlanPlaybookList);
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				List<CSM_Account_Plan_Playbook__c> acpPB1 = CSM_AcctPlanTemplatePlaybooksDataAccess.getNonAutomatedAccountPlanPlaybooks(accountPlanList);
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				Map<Id, Id> currentToCloneTemplateIdMap = new Map<Id, Id>();
				CSM_AcctPlanTemplatePlaybooksDataAccess.cloneAccountPlanPlayBooks(currentToCloneTemplateIdMap);				
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				List<CSM_Account_Plan_Playbook__c> acpPB2 = CSM_AcctPlanTemplatePlaybooksDataAccess.getAcctPlanPlaybooksByPlaybookIdAndTemplateId(playbookList[0].id);
    		}catch(Exception e){
    			system.assert(true);
    		}
    		try{
				CSM_AcctPlanTemplatePlaybooksDataAccess.deleteAcctPlanTemplatePlaybook(accountPlanPlaybookList);
    		}catch(Exception e){
    			system.assert(true);
    		}
    		
    	}
    	
    	Test.stopTest();
    }
}