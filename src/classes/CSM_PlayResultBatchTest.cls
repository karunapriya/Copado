/**
* @description :  Test class for CSM_PlayResultTriggerHandler. It is called by CSM_PlayResultBatch.       
*/
@isTest
private class CSM_PlayResultBatchTest 
{
	@testSetup 
	static void setUp() {
		
		CSM_TestUtility.addCSMAdmin();
		CSM_TestUtility.insertAccount();
		List<Account> accList = [select id from account limit 1];
		
		List<CSM_Play_Result__c> playResultList = new List<CSM_Play_Result__c>();

		//Insert Playbook
		CSM_Play_Result__c pr1 = new CSM_Play_Result__c();
		pr1.CSM_Playbook_Description__c = 'Test Desc PLB1';
		pr1.CSM_Playbook_External_Id__c = '11111';
		pr1.CSM_Playbook_Name__c = 'PLB1';
		playResultList.add(pr1);      

		//Insert Play1
		CSM_Play_Result__c pr2 = new CSM_Play_Result__c();
		pr2.CSM_Play_Description__c = 'Tst Desc PL1';
		pr2.CSM_Play_Name__c = 'PL1';
		pr2.CSM_Play_External_Id__c = '22222';
		pr2.CSM_Playbook_External_Id__c = '11111';
		playResultList.add(pr2); 

		//Insert recorrd for task data
		//For Resolution_Status = Pending
		CSM_Play_Result__c pr4 = new CSM_Play_Result__c();
		pr4.CSM_Account_Id__c = accList[0].id;
		pr4.CSM_Playbook_External_Id__c = '11111';
		pr4.CSM_Play_External_Id__c = '22222';
		pr4.CSM_Play_Result_Id__c = 'PlayResult-1';
		pr4.CSM_Resolution_Status__c = 'Pending';
		playResultList.add(pr4);

		//For Resolution_Status = Attained
		CSM_Play_Result__c pr5 = new CSM_Play_Result__c();
		pr5.CSM_Account_Id__c = accList[0].id;
		pr5.CSM_Playbook_External_Id__c = '11111';
		pr5.CSM_Play_External_Id__c = '22222';
		pr5.CSM_Play_Result_Id__c = 'PlayResult-2';
		pr5.CSM_Resolution_Status__c = 'Attained';
		playResultList.add(pr5);

		//For Resolution_Status = Halted
		CSM_Play_Result__c pr6 = new CSM_Play_Result__c();
		pr6.CSM_Account_Id__c = accList[0].id;
		pr6.CSM_Playbook_External_Id__c = '11111';
		pr6.CSM_Play_External_Id__c = '22222';
		pr6.CSM_Play_Result_Id__c = 'PlayResult-5';
		pr6.CSM_Resolution_Status__c = 'Halted';
		playResultList.add(pr6);

		//For Resolution_Status = null
		CSM_Play_Result__c pr7 = new CSM_Play_Result__c();
		pr7.CSM_Account_Id__c = accList[0].id;
		pr7.CSM_Playbook_External_Id__c = '11111';
		pr7.CSM_Play_External_Id__c = '22222';
		pr7.CSM_Play_Result_Id__c = 'PlayResult-5';
		pr7.CSM_Resolution_Status__c = null;
		playResultList.add(pr7);

		//For Resolution_Status = unknown
		CSM_Play_Result__c pr8 = new CSM_Play_Result__c();
		pr8.CSM_Account_Id__c = accList[0].id;
		pr8.CSM_Playbook_External_Id__c = '11111';
		pr8.CSM_Play_External_Id__c = '22222';
		pr8.CSM_Play_Result_Id__c = 'PlayResult-4';
		pr8.CSM_Resolution_Status__c = 'aaa';
		playResultList.add(pr8);

		//For Resolution_Status = unknown != null and playResult id == null
		CSM_Play_Result__c pr9 = new CSM_Play_Result__c();
		pr9.CSM_Account_Id__c = accList[0].id;
		pr9.CSM_Playbook_External_Id__c = '11111';
		pr9.CSM_Play_External_Id__c = '22222';
		pr9.CSM_Play_Result_Id__c = null;
		pr9.CSM_Resolution_Status__c = 'Pending';
		playResultList.add(pr9);

		CSM_Play_Result__c pr10 = new CSM_Play_Result__c();
		pr10.CSM_Account_Id__c = null;
		pr10.CSM_Playbook_External_Id__c = '11111';
		pr10.CSM_Play_External_Id__c = '22222';
		pr10.CSM_Play_Result_Id__c = 'PlayResult-4';
		pr10.CSM_Resolution_Status__c = 'Pending';
		playResultList.add(pr10);
		
		CSM_Play_Result__c pr11 = new CSM_Play_Result__c();
		pr11.CSM_Account_Id__c = accList[0].id;
		pr11.CSM_Playbook_External_Id__c = '11111';
		pr11.CSM_Play_External_Id__c = null;
		pr11.CSM_Play_Result_Id__c = 'PlayResult-4';
		pr11.CSM_Resolution_Status__c = 'Pending';
		playResultList.add(pr11);

		insert playResultList;

		List<CSM_Playbook__c>  PlayBookList = CSM_TestDataUtility.createPlaybooks(1);
		List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
		CSM_PlaybookPlay__c playBookPlayObj = CSM_TestDataUtility.createPlaybookPlayTestData(String.valueOF(PlayBookList[0].id), String.valueOF(playList[0].id));
		List<CSM_Account_Plan_Template__c> spPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		
		system.assert(spPlanTemplateList.size() > 0);		
	}

	@isTest 
	static void testPlayResultBatch() {
		CSM_TestUtility.addLicense();
		Test.startTest();
			String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
			String jobID = system.schedule('Test Play Result Batch1', strDateTime, new CSM_PlayResultBatchScheduledDispatcher());    
			Database.executeBatch(new CSM_PlayResultBatch());
		Test.stopTest();
		
		List<CSM_Play__c> playList = [Select Id, CSM_External_Id__c From CSM_Play__c Where CSM_External_Id__c = '22222' Limit 1];
        system.assert(playList<>null);
	}  

	@isTest 
	static void testPlayResultBatch1() {
		CSM_TestUtility.addLicense();
		//To set Active flag for Play and PlayBook.
		List<CSM_Playbook__c>  PlayBookList = [select id, CSM_IsActive__c,CSM_Automated__c, CSM_External_Id__c  from CSM_Playbook__c ];
		PlayBookList[0].CSM_IsActive__c = true;
		PlayBookList[0].CSM_Automated__c = true;
		PlayBookList[0].CSM_External_Id__c = '11111';
		update PlayBookList;

		List<CSM_Play__c> playList = [select id, CSM_IsActive__c,CSM_Automated__c, CSM_External_Id__c  from CSM_Play__c ];
		playList[0].CSM_IsActive__c = true ;
		playList[0].CSM_Automated__c = true ;
		playList[0].CSM_External_Id__c = '22222';
		playList[0].CSM_Query_Criteria__c = null;
		update playList;

		List<CSM_Account_Plan_Template__c> spPlanTemplateList = [Select id ,CSM_UseasScout_Default_Template__c from CSM_Account_Plan_Template__c];
		spPlanTemplateList[0].CSM_UseasScout_Default_Template__c = true;
		update spPlanTemplateList;

		List<Account> accList = [select id from account limit 1];
		List<CSM_Account_Plan__c>  accPlanList = CSM_TestDataUtility.createAccountPlan(accList, spPlanTemplateList[0].id);
		List<CSM_Account_Plan_Playbook__c> accplanPlayPlayBookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accPlanList[0].id, spPlanTemplateList[0].id,new List<String>{PlayBookList[0].id});

		List<CSM_Play_Task__c> lstPlTasks = new List<CSM_Play_Task__c>();
		CSM_Constants.PLAY_RESULT_TRIGGER = true;
		//Create PlayTasks for all Plays
		for(CSM_Play__c pl :playList){
			for(Integer i = 0; i < 2; i++){
				CSM_Play_Task__c newPlTsk = new CSM_Play_Task__c();
				newPlTsk.CSM_IsActive__c = true;
				newPlTsk.CSM_Assign_To__c = 'Account Owner';
				newPlTsk.CSM_Days_Until_Due__c = 10;
				newPlTsk.CSM_Description__c = 'Test Desc ' + i + ' ' + pl.CSM_External_Id__c;
				newPlTsk.CSM_Play__c = pl.Id;
				lstPlTasks.add(newPlTsk);
			}
		}
		if(lstPlTasks != null && !lstPlTasks.isEmpty()){
			insert lstPlTasks;
		}
		
		Test.startTest();     
			String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
			String jobID = system.schedule('Test Play Result Batch2', strDateTime, new CSM_PlayResultBatchScheduledDispatcher());    
			Database.executeBatch(new CSM_PlayResultBatch());
		Test.stopTest();
		
		List<CSM_Play__c> playListToCheck = [Select Id, CSM_External_Id__c From CSM_Play__c Where CSM_External_Id__c = '22222' Limit 1];
        system.assert(playListToCheck<>null);
	} 

}