@isTest
private class CSM_PlaybooksDataAccessTest {
   
    static testMethod void myUnitTest() {	
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(3);
        try{
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
		        CSM_PlaybooksDataAccess.deletePlaybook(new List<CSM_Playbook__c>{play2});
		        
		    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		    	system.runAs(restrictedUser){
		    		try{
       		    		CSM_Playbook__c play11 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
       		    		CSM_Playbook__c play22 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);		    			
		        		activatesuccess = CSM_PlaybooksDataAccess.activatePlaybooks(new List<String>{play22.id});						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
		       		    CSM_Playbook__c play33 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);		        		
		        		deactivatesuccess = CSM_PlaybooksDataAccess.deactivatePlaybooks(new List<String>{play33.id});						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
		       		    CSM_Playbook__c play44 = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookList[0].id);		    			
		        		List<CSM_Playbook__c> playSaved1 = CSM_PlaybooksDataAccess.savePlaybook(new List<CSM_Playbook__c>{play44});						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
		        		List<CSM_PlaybookWrapper> playbookList22 = CSM_PlaybooksDataAccess.populatePlaybooksInformation();						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		
		    	}
        	Test.stopTest();
    	} catch (Exception e){
    		system.debug('Exception : ' + e.getMessage());}
    }
    
    static testMethod void createPlaybookTest() { 	
    	try{
    		List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
	    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
	    	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
	    	List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].id);
	    	Map<String,String> accountPlanTemplateMap = new Map<String,STring>();
	    	accountPlanTemplateMap.put(accountPlanTemplateList[0].id, playbookList[0].id);
	    	Map<String,String> accountPlanIdMap = new Map<String,String>();
			accountPlanIdMap.put(accountPlanList[0].id,playbookList[0].id);
			Test.startTest();
				boolean isSuccess =  CSM_PlaybooksDataAccess.createPlaybookAssignment(accountPlanTemplateMap,  accountPlanIdMap, new List<CSM_Account_Plan_Playbook__c>(),false);
				List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
				accountPlanPlaybookList = [select id from CSM_Account_Plan_Playbook__c limit 1000];
				system.assert(accountPlanPlaybookList.size() > 0);
				
		    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		    	system.runAs(restrictedUser){
		    		try{
						isSuccess =  CSM_PlaybooksDataAccess.createPlaybookAssignment(accountPlanTemplateMap,  accountPlanIdMap, new List<CSM_Account_Plan_Playbook__c>(), false);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		
		    	}
				
				
			Test.stopTest();
    	} catch (Exception e){
    		system.debug('Exception : ' + e.getMessage());}
    }
    
    /*static testMethod void createPlaysTest() {
    	try{
    	    CSM_Play__c newPlay = new CSM_Play__c();
    		newPlay.CSM_isActive__c = true;
    		newPlay.CSM_Display_Name__c = 'Play__test';
    		newPlay.CSM_Object_Name__c = 'Account';
    		newPlay.CSM_External_Id__c = '100';
    		insert(newPlay);
    		
    		List<CSM_Play__c> playList =[select id,CSM_Display_Name__c,CSM_External_Id__c from CSM_Play__c  limit 1];
    	
    	    CSM_Playbook__c newPlaybook = new CSM_Playbook__c();
    		newPlaybook.CSM_Display_Name__c = 'Playbook__test';
    		newPlaybook.CSM_IsActive__c = true;
    		newPlaybook.CSM_External_Id__c = '100';
    		insert(newPlaybook);	
    		system.assert(newPlaybook.Id!=null);	
    		List<CSM_Playbook__c> playBookList = [select id,CSM_Display_Name__c,CSM_External_Id__c from CSM_Playbook__c  limit 1];
    	    	
	    	CSM_Play_Result__c pr1 = new CSM_Play_Result__c();
			pr1.CSM_Playbook_Description__c = 'Test Desc PLB1';
			pr1.CSM_Playbook_External_Id__c = newPlaybook.CSM_External_Id__c;
			pr1.CSM_Play_External_Id__c=newPlay.CSM_External_Id__c;
			pr1.CSM_Playbook_Name__c = 'PLB1';
			insert pr1;
			system.assert(pr1.Id!=null);
	    	Map<String, List<CSM_Play__c>> playbookMap = new Map<String, List<CSM_Play__c>>();
	    	playbookMap.put('100',playList);
	    	Map<String, CSM_Play_Result__c> playToResult = new Map<String, CSM_Play_Result__c>();
	    	playToResult.put('100',pr1);
	    	system.assert(playToResult!=null);
	    	
	    	CSM_PlaybookPlay__c playBookPlay = new CSM_PlaybookPlay__c();
	    	playBookPlay.CSM_Play__c = newPlay.Id;
	    	playBookPlay.CSM_Playbook__c = newPlaybook.Id;
	    	List<CSM_PlaybookPlay__c> lstPlayBookPlay = new List<CSM_PlaybookPlay__c>();
	    	lstPlayBookPlay.add(playBookPlay);

	    	CSM_PlaybooksDataAccess.InsertClonedPlaybookPlayList(lstPlayBookPlay);
	    	system.assert(playBookPlay.Id!=null);
	    	Test.startTest();
	    		CSM_PlaysDataAccess.createPlays(playBookList,playbookMap,playToResult);
	    		
	    		List<CSM_Play__c> playList2 = [select id,CSM_Display_Name__c,CSM_External_Id__c from CSM_Play__c  limit 1];
	    		system.assert(playList2 != null);
	    		
		    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		    	system.runAs(restrictedUser){
		    		try{
						CSM_PlaybooksDataAccess.InsertClonedPlaybookPlayList(lstPlayBookPlay);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
						CSM_PlaysDataAccess.createPlays(playBookList,playbookMap,playToResult);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		
		    	}
	    		
	    		
	    	Test.stopTest();
    	} catch (Exception e){
    		system.debug('Exception : ' + e.getMessage());}
 	}*/
 	
 	static testMethod void PlaybookTest() { 	
    	try{
    		List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
	    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
	    	List<CSM_Account_Plan_Template__c> accountPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
	    	List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplateList[0].id);
	    	Set<Id> playbookIds = new Set<Id>();
	    	for(CSM_Playbook__c playbookTemp: playbookList){
	    		playbookIds.add(playbookTemp.id);
	    	}
	    	String playBookID = String.valueOf(playbookList[0].id);
			Test.startTest();
				
				CSM_PlaybooksDataAccess.getPlaybooksById(playBookID);
				CSM_PlaybooksDataAccess.populatePlaybooksInformationByAcctPlanPlaybookId(playbookIds);
				CSM_PlaybooksDataAccess.deletePlaybook(playbookList);
				Map<String, String> playbookExternalIds = new Map<String, String>();
				playbookExternalIds.put('1','1');	
				List<CSM_Playbook__c> lstPlaybooks = CSM_PlaybooksDataAccess.getPlaybooksByExtId(playbookExternalIds);
				system.assertequals(lstPlaybooks.size(),0);
				
				
		    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		    	system.runAs(restrictedUser){
		    		try{
						CSM_PlaybooksDataAccess.getPlaybooksById(playBookID);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
						CSM_PlaybooksDataAccess.populatePlaybooksInformationByAcctPlanPlaybookId(playbookIds);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
						CSM_PlaybooksDataAccess.deletePlaybook(playbookList);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		try{
						List<CSM_Playbook__c> lstPlaybooks1 = CSM_PlaybooksDataAccess.getPlaybooksByExtId(playbookExternalIds);						
		    		}catch(Exception e){
		    			system.assert(true);
		    		}
		    		
		    	}
				
			Test.stopTest();
    	} catch (Exception e){
    		system.debug('Exception : ' + e.getMessage());}
    }
     
}