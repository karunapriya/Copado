public with sharing class CSM_SuccessPlanPlayTriggerHandler extends CSM_TriggerManager.TriggerHandler {
 	Set<Id> setSppl;

 	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
		CSM_Constants.SPPL_TRIGGER = false;
		for(SObject sObj:newRecords){
			sObj.put('CSM_Display_Name_Text__c',sObj.get('CSM_Display_Name__c'));
		}	 	
	 	
	 }

	 public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 		Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	//try { 
			CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
			String namespace = CSM_Util.getNamespace();	 		
 			Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
	        Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
	 		//MF 11/10/2013 Added this check to only execute the task creation when the user has account Plan / CSM
	 		if (hasCSMAccess || hasRenewAccess) {
	 			List<CSM_SuccessPlan_Play__c> spplList = new List<CSM_SuccessPlan_Play__c>();
	 			List<CSM_Task_Processing__c> taskProcessList = new List<CSM_Task_Processing__c>();
	 			List<String> spplIdList = new List<String>();
	 			Map<String,Boolean> playMap = new Map<String,Boolean>();
	 			setSppl = new Set<Id>();	 			
	 			playMap = getPlaysMap(newRecords, namespace);
	 			List<CSM_SuccessPlan_Play__c> lstSppl = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListNoNewSPPL(setSppl);
	 			set<string> setSpplPrevious = new Set<String>();
	 			for(CSM_SuccessPlan_Play__c sppl: lstSppl){
	 				setSpplPrevious.add(sppl.CSM_Previous_SPPL__c);	 			
	 			}
	 			
				for(SObject newSppl : newRecords){
					if(playMap.get((String)newSppl.get(namespace + 'CSM_Play__c')) && newSppl.get(namespace + 'CSM_Play_Outcome__c') != null && !String.isEmpty((String)newSppl.get(namespace + 'CSM_Play_Outcome__c'))){
						SObject oldSppl = oldRecordsMap.get((Id)newSppl.get('Id'));
						String oldPlayOutcome = (String)oldSppl.get(namespace + 'CSM_Play_Outcome__c');
						if(String.isEmpty(oldPlayOutcome) && !setSpplPrevious.contains((String)oldSppl.get('Id'))){
							CSM_SuccessPlan_Play__c insertSppl = new CSM_SuccessPlan_Play__c();
							insertSppl.CSM_Display_Name_Text__c = (String)oldSppl.get(namespace + 'CSM_Display_Name_Text__c');
							insertSppl.CSM_Play__c = (String)oldSppl.get(namespace + 'CSM_Play__c');
							insertSppl.CSM_Playbook_Play__c = (String)oldSppl.get(namespace + 'CSM_Playbook_Play__c');
							insertSppl.CSM_SuccessPlan_Playbook__c = (String)oldSppl.get(namespace + 'CSM_SuccessPlan_Playbook__c');
							insertSppl.CSM_Previous_SPPL__c = (String)oldSppl.get('Id');
							spplList.add(insertSppl);
							spplIdList.add(insertSppl.CSM_Previous_SPPL__c);
						}
					}
				}

				if(!spplIdList.isEmpty()){
					taskProcessList = CSM_TaskProcessingDataAccess.getTskProcRecordsForDelete(spplIdList);//[select Id from CSM_Task_Processing__c where CSM_SuccessPlan_Play__c in: spplIdList];
					if(!taskProcessList.isEmpty()){
						CSM_TaskProcessingDataAccess.deleteTaskProcRecords(taskProcessList);
					}
				}
				
				if(!spplList.isEmpty()){
					CSM_SuccessPlanPlayDataAccess.insertSuccessPlanPlayList(spplList);
				}
	 		}
	 	/*}
	 	catch (exception ex)
	 	{
	 		for (Integer i = 0; i < newRecords.size(); i++)
	 		{
	 			newRecords[i].addError(ex.getMessage());
	 		} 
	 	} */
	 } 
	 
	 private Map<String,Boolean> getPlaysMap(List<sObject> newRecords, String namespace){
 		List<String> playIdList = new List<String>();	 			
 		List<CSM_Play__c> playList = new List<CSM_Play__c>();	 			
 		Map<String,Boolean> playMap = new Map<String,Boolean>();
 		for(SObject newSppl : newRecords){
 			playIdList.add((String)newSppl.get(namespace + 'CSM_Play__c'));	
			setSppl.add((String)newSppl.get('Id')); 			 			
 		}
 		playList = CSM_PlaysDataAccess.getPlayReEntryInformation(playIdList);//[select Id, CSM_Play_ReEntry__c from CSM_Play__c where Id in: playIdList];
 		for(CSM_Play__c play: playList){
 			playMap.put(play.Id,play.CSM_Play_ReEntry__c);
 		}	
	 	return playMap;
	 }
}