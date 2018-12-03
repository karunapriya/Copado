@isTest
private class CSM_PlaysDataAccessTest { 

    static testMethod void myUnitTest() {
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        List<CSM_Play__c>  playList = CSM_TestDataUtility.createPlayTestData(3);
        Test.startTest();
	        List<CSM_Play__c> foundPLayList = CSM_PlaysDataAccess.populatePlayList();
	        boolean activateSuccess = CSM_PlaysDataAccess.activatePlays(new List<String>{playList[1].id});
	        CSM_Play__c foundPlay = CSM_PlaysDataAccess.populatePlayInformation(playList[1].id);
	        system.assertEquals(foundPlay.CSM_IsActive__c, true);
	        boolean deactivateSuccess = CSM_PlaysDataAccess.deactivatePlays(new List<String>{playList[1].id});
	        CSM_Play__c foundPlay2 = CSM_PlaysDataAccess.populatePlayInformation(playList[1].id);+
	        system.assertEquals(foundPlay2.CSM_IsActive__c, false);
	        List<CSM_Play__c> savedPlayList = CSM_PlaysDataAccess.savePlays(playList);
	        set<String> pbidSet = new Set<String>();
	        pbidSet.add(playbookList[0].id);
			List<CSM_PlaybookPlay__c> PPBList = CSM_PlaysDataAccess.getActiveNonAutomatedPlays(pbidSet);
			String obj = 'CSM_Play__c';
			List<CSM_PlaybookPlay__c> PPBList1 = CSM_PlaysDataAccess.getActiveNonAutomatedPlays(pbidSet,obj);
			boolean isdelPlay = CSM_PlaysDataAccess.deletePlay(playList[1].id);
			system.assertEquals(isdelPlay, true);
		    CSM_PlaysDataAccess.populatePlayInformation(playList[2].id);
        Test.stopTest();
    }
    
      static testMethod void createPlaysTest() {
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
	    	List<string> playListId = new List<string>();
	    	
	    	system.assert(playToResult!=null);
	    	Test.startTest();
	    	//	CSM_PlaysDataAccess.createPlays(playBookList,playbookMap,playToResult);
	    		CSM_PlaysDataAccess.populatePlayInformation(playListId);
	    	Test.stopTest();
    	} catch (Exception e){
    		system.debug('Exception : ' + e.getMessage());}
 	}
}