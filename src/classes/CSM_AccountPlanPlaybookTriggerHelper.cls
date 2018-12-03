public with sharing class CSM_AccountPlanPlaybookTriggerHelper {
	
	/*************
	function : processSPlanPlayBook
	Description : if success plan is not null in SP-PB, create corresponding SP-PL
	if success plan is null and the added playbook is part of template which is associated with Success plan then create
	SP-PB for records
	***************/
	public static void processSPlanPlayBook(List<SObject> newRecords){
		List<CSM_Account_Plan_Playbook__c> splanPbookLst = (List<CSM_Account_Plan_Playbook__c>)newRecords;
		List<String> templateLst = new List<String>();
		Map<String,List<CSM_Playbook__c>>templatePBMap = new Map<String,List<CSM_Playbook__c>>();
		Map<String,String> sppbPBMap = new Map<String,String>();
		List<String> playbookLst = new List<String>();
		Map<Id,CSM_Playbook__c> playBookMap = new Map<Id,CSM_Playbook__c>();
		List<String> playbookToQueryLst = new List<String>();
		for(CSM_Account_Plan_Playbook__c splanPbook : splanPbookLst){
			if(splanPbook.CSM_Account_Plan__c == null){
				playbookToQueryLst.add(splanPbook.CSM_Playbook__c);
			}
		}
		if(!playbookToQueryLst.isEmpty()){
			playBookMap = new Map<Id,CSM_Playbook__c>(CSM_PlaybooksDataAccess.getPlaybookList(playbookToQueryLst));
		}
		List<CSM_Playbook__c> splanbookLst;
		for(CSM_Account_Plan_Playbook__c splanPbook : splanPbookLst){
			if(splanPbook.CSM_Account_Plan__c == null){
				templateLst.add(splanPbook.CSM_Account_Plan_Template__c);
				if(templatePBMap != null && !templatePBMap.containskey(splanPbook.CSM_Account_Plan_Template__c)){
					templatePBMap.put(splanPbook.CSM_Account_Plan_Template__c,new List<CSM_Playbook__c>{playBookMap.get(splanPbook.CSM_Playbook__c)});
				}
				else if(templatePBMap != null && templatePBMap.containskey(splanPbook.CSM_Account_Plan_Template__c)){
					splanbookLst = templatePBMap.get(splanPbook.CSM_Account_Plan_Template__c);
					splanbookLst.add(playBookMap.get(splanPbook.CSM_Playbook__c));
					templatePBMap.put(splanPbook.CSM_Account_Plan_Template__c,splanbookLst);
				}
			}
			else { 
				sppbPBMap.put(splanPbook.id,splanPbook.CSM_Playbook__c);
				playbookLst.add(splanPbook.CSM_Playbook__c);
			}
		}
		if(playbookLst!= null && !playbookLst.isEmpty()){
			createAndInsertSPPLay(playbookLst,sppbPBMap);
		}
		
		if(templateLst != null && !templateLst.isEmpty()){
			createSuccessPlanPlayBook(templateLst,templatePBMap);
		}
	}
	
	/***********
	function : createAndInsertSPPLay
	Description : On insert of SP-PB, create corressponding SP-PL
	SP-PL will have a record for each play in the playbook SP-PB
	************/
	private static void createAndInsertSPPLay(List<String> playbookLst,Map<String,String> sppbPBMap){
		
		List<CSM_PlaybookPlay__c> pbPlayLst = CSM_PlaybookPlayDataAccess.getPlaybookPlaybyPlayBook(playbookLst);
 		Map<String,List<CSM_PlaybookPlay__c>>plbookPlayMap = new Map<String,List<CSM_PlaybookPlay__c>>();
 		List<CSM_PlaybookPlay__c> playbookPlayLst ;
 		for(CSM_PlaybookPlay__c pbPlay : pbPlayLst){
			if(plbookPlayMap != null && !plbookPlayMap.containskey(pbPlay.CSM_Playbook__c)){
				plbookPlayMap.put(pbPlay.CSM_Playbook__c,new List<CSM_PlaybookPlay__c>{pbPlay});
			}
			else if(plbookPlayMap != null && plbookPlayMap.containskey(pbPlay.CSM_Playbook__c)){
				playbookPlayLst = plbookPlayMap.get(pbPlay.CSM_Playbook__c);
				playbookPlayLst.add(pbPlay);
				plbookPlayMap.put(pbPlay.CSM_Playbook__c,playbookPlayLst);
			}
 		}
		List<CSM_PlaybookPlay__c> playsfrmPBLst ;	
		List<CSM_SuccessPlan_Play__c> splanPlayLst = new List<CSM_SuccessPlan_Play__c>();
		String play = '';
		String spPlbook = '';
		CSM_SuccessPlan_Play__c spPlay ;		
		for(String sppB : sppbPBMap.keyset()){
			spPlbook = sppbPBMap.get(sppB);
			if(String.isNotBlank(spPlbook) && plbookPlayMap.containsKey(spPlbook)){
			 	playsfrmPBLst = plbookPlayMap.get(spPlbook);
				for(CSM_PlaybookPlay__c playBplay : playsfrmPBLst){
					spPlay = new CSM_SuccessPlan_Play__c();
					spPlay.CSM_Play__c = playBplay.CSM_Play__c;
					spPlay.CSM_SuccessPlan_Playbook__c = sppB;
					spPlay.CSM_Playbook_Play__c = playBplay.id; 
					splanPlayLst.add(spPlay);
			 	}
			}
		}
		CSM_SuccessPlanPlayDataAccess.insertSuccessPlanPlayList(splanPlayLst);
	}
	
	/*********************
	function : createSuccessPlanPlayBook
	Description : When a playbook is added to a template after creation Success plan, create
	SP-PB for the newly added playbook for all the success plan with the concerned template.
	*********************/
	private static void createSuccessPlanPlayBook(List<String> templateLst,Map<String,List<CSM_Playbook__c>>templatePBMap){
		
		List<CSM_Account_Plan__c> spList = CSM_AccountPlanDataAccess.getAccountPlansByTemplateId(templateLst);
		List<CSM_Playbook__c> playbookLst;
		List<String> plbookLst= new List<String>();
		Map<String,String> splanPlBookMap = new Map<String,String>();
		CSM_Account_Plan_Playbook__c SplanPBook;
		List<CSM_Account_Plan_Playbook__c> sPlanPBInsertLst = new List<CSM_Account_Plan_Playbook__c>();
		for(CSM_Account_Plan__c sp : spList){
			playbookLst = templatePBMap.get(sp.CSM_Account_Plan_Template__c);
			for(CSM_Playbook__c pBook:playbookLst){
				splanPBook = new CSM_Account_Plan_Playbook__c();
				splanPBook.CSM_Account_Plan__c = sp.id;
				splanPBook.CSM_Account_Plan_Template__c = sp.CSM_Account_Plan_Template__c;
				splanPBook.CSM_Playbook__c = pBook.id;
				splanPBook.CSM_IsActive__c = pBook.CSM_IsActive__c;
				splanPBook.CSM_Source__c = CSM_Constants.STR_FROM_TEMPLATE;
				sPlanPBInsertLst.add(splanPBook);
			}	
		}
		if(sPlanPBInsertLst != null && !sPlanPBInsertLst.isEmpty()){
			CSM_AccountPlanPlaybookDataAccess.insertAcctPlanPlaybook(sPlanPBInsertLst); 
			// recursion trigger will not happen as the constant ACCOUNT_PLAN_PLAYBOOK_TRIGGER is set to false
			for(CSM_Account_Plan_Playbook__c spPB : sPlanPBInsertLst){
				plbookLst.add(spPB.CSM_Playbook__c);
				splanPlBookMap.put(spPB.id,spPB.CSM_Playbook__c);
			}
			createAndInsertSPPLay(plbookLst,splanPlBookMap);
		}
	}
    
}