public with sharing class CSM_AccountPlanTriggerHelper {
    
    
    public static void createSPPlayBook (List<SObject> newRecords){
		Map<String,List<String>> templateSPlanMap = new Map<String,List<String>>();
		List<CSM_Account_Plan__c> splanLst = (List<CSM_Account_Plan__c>)newRecords;
		system.debug('splanLst::'+splanLst);
		templateSPlanMap = populateTemplateSPMap(splanLst);
		Map<String,Set<String>> templatePBookMap = new Map<String,Set<String>>();
		createandInsertSPPlayBook(templateSPlanMap);
	}
	
	/*********************
	function : deleteSPPlayBook 
	Description : On change of template in a successplan, the SP-PB records associated with Sucess Plan are deleted
	and new ones for the new template are created.
	**********************/
	public static void deleteSPPlayBook (List<SObject> newRecords,Map<ID, sObject> oldRecordsMap){
		List<CSM_Account_Plan__c> splanLst = (List<CSM_Account_Plan__c>)newRecords;
		List<String> splanIDLst = new List<String>();
		List<CSM_Account_Plan_Playbook__c> sppbToDelLst = new List<CSM_Account_Plan_Playbook__c>();
		List<CSM_Account_Plan__c> splantToUpdateLst = new List<CSM_Account_Plan__c>();
		CSM_Account_Plan__c  oldSplan;
		for(CSM_Account_Plan__c splan : splanLst){
			oldSplan = (CSM_Account_Plan__c) oldRecordsMap.get(splan.id);
			if(oldSplan != null && oldSplan.CSM_Account_Plan_Template__c != splan.CSM_Account_Plan_Template__c){
				splanIDLst.add(splan.id);
				splantToUpdateLst.add(splan);
			}
		}
		
		if(!splanIDLst.isEmpty()){
			sppbToDelLst = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByAccPlanIdwithTemp(splanIDLst);
			if(sppbToDelLst != null && !sppbToDelLst.isEmpty()){
				CSM_AccountPlanPlaybookDataAccess.deleteAcctPlanPlaybook(sppbToDelLst);
				CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;// so that after insert trigger is executed
				createSPPlayBook(splantToUpdateLst);
			}
		}
	}
	
	private static Map<String,List<String>> populateTemplateSPMap(List<CSM_Account_Plan__c> splanLst){
		Map<String,List<String>> templateSPMap = new Map<String,List<String>>();
		for(CSM_Account_Plan__c splan : splanLst){
			if(templateSPMap != null && !templateSPMap.containskey(splan.CSM_Account_Plan_Template__c)){
				templateSPMap.put(splan.CSM_Account_Plan_Template__c,new List<String>{splan.id});
			}
			else if(templateSPMap != null && templateSPMap.containskey(splan.CSM_Account_Plan_Template__c)){
				List<String> splanIDLst = templateSPMap.get(splan.CSM_Account_Plan_Template__c);
				splanIDLst.add(splan.id);
				templateSPMap.put(splan.CSM_Account_Plan_Template__c,splanIDLst);
			}
		}
		
		return templateSPMap;
	}
	
	
	/****************************
	function : createandInsertSPPlayBook
	Description : This method inserts success plan playbook.
	When a template is associated to a success plan, corresponding success plan playbook records are created.
	The number of records are number of playbooks in a template with success plan associated.
	************************************************/
	private static void createandInsertSPPlayBook(Map<String,List<String>> templateSPlanMap){
		List<CSM_Account_Plan_Playbook__c> sPPBUpsertLst = new List<CSM_Account_Plan_Playbook__c>();
		//List<CSM_Account_Plan_Playbook__c> sppbLst =  [Select id,CSM_Account_Plan__c,CSM_Playbook__c,CSM_Account_Plan_Template__c from CSM_Account_Plan_Playbook__c where CSM_Account_Plan_Template__c =: templateSPlanMap.keySet() and CSM_Account_Plan__c = null ];
		List<CSM_Account_Plan_Playbook__c> sppbLst = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByTmpltIDLstWthoutAccPlan(templateSPlanMap.keySet());
		for(CSM_Account_Plan_Playbook__c sppb:sppbLst){
			List<String> splanIDLst = templateSPlanMap.get(sppb.CSM_Account_Plan_Template__c);
			for(String splan :splanIDLst){
				CSM_Account_Plan_Playbook__c splanPBook = new CSM_Account_Plan_Playbook__c();
				splanPBook.CSM_Account_Plan__c = splan;
				splanPBook.CSM_Account_Plan_Template__c = sppb.CSM_Account_Plan_Template__c;
				splanPBook.CSM_Playbook__c = sppb.CSM_Playbook__c;
				splanPBook.CSM_Source__c = CSM_Constants.STR_FROM_TEMPLATE;
				sPPBUpsertLst.add(SplanPBook);
			}
 		}
 		
 		CSM_AccountPlanPlaybookDataAccess.insertAcctPlanPlaybook(sPPBUpsertLst);
 		//insert sPPBUpsertLst;
	}
    
    
}