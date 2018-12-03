public with sharing class ProactiveRuleTriggerHandlerHelper {
     public static void updateProactiveRule(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
	     Map<String, String> cronJobDetailMap = new Map<String, String>();
	     Map<String, String> cronTriggerMap = new Map<String, String>();
	     List<String> cronJobDetailIdList = new List<String>();
	    
	     for(CronJobDetail cjd : [SELECT Id,Name FROM CronJobDetail WHERE Name LIKE '%CaseCreationSchedule%']){
	         cronJobDetailIdList.add(cjd.Id);
	         cronJobDetailMap.put(cjd.Name, cjd.Id);
	     }
	    
	     for(CronTrigger ct : [SELECT Id, CronJobDetailId FROM CronTrigger WHERE CronJobDetailId IN :cronJobDetailIdList]){
	         cronTriggerMap.put(ct.CronJobDetailId, ct.Id);
	     }
	   
	     list<Proactive_Rule__c> proactiveRuleLst = new List<Proactive_Rule__c>();
	     proactiveRuleLst = newRecords;
	     String recurringDayStr = '';
	            
	     for(Proactive_Rule__c newPr : proactiveRuleLst) {
             Proactive_Rule__c oldPr = (Proactive_Rule__c)oldRecordsMap.get(newPr.Id);
        
             if(newPr.Is_Active__c && newPr.Is_Active__c != oldPr.Is_Active__c && !String.isBlank(newPr.Output__c))
             {
           	   
                 if(newPr.Recurring_Day__c != null) 
                 {
                     recurringDayStr = newPr.Recurring_Day__c.replace(';', ',');
                 }
                 else
                 {
               	     recurringDayStr = '*';
                 }
                 System.schedule('CaseCreationSchedule ' + newPr.Id, '0 ' + newPr.Preferred_Run_Minute__c + ' ' 
                   + newPr.Preferred_Run_Hour__c + ' ? * ' + recurringDayStr, new CaseCreationSchedule(newPr.Id, newPr.Output__c));
             }
           
             if(!newPr.Is_Active__c && newPr.Is_Active__c != oldPr.Is_Active__c && cronJobDetailMap.containskey('CaseCreationSchedule ' + newPr.Id)
	             && cronTriggerMap.containsKey(cronJobDetailMap.get('CaseCreationSchedule ' + newPr.Id)))
	         {
	             System.debug('mgl I am aborting '+newPr.Id);
	             System.abortJob(cronTriggerMap.get(cronJobDetailMap.get('CaseCreationSchedule ' + newPr.Id)));
	         } 
         }
	}
	
	public static void updateBeforeProactiveRuleCriteriaList(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
    	list<Proactive_Rule__c> proactiveRuleLst = new list<Proactive_Rule__c>();
    	list<Proactive_Rule__c> proActiveLst = new list<Proactive_Rule__c>();
    	list<Proactive_Rule__c> proactiveRuleOldLst = new list<Proactive_Rule__c>();
    	proactiveRuleOldLst = oldRecords;
    	map<ID, Proactive_Rule__c> proactiveOldMap = new map<ID, Proactive_Rule__c>(proactiveRuleOldLst);
    	proactiveRuleLst = newRecords;
    	String objName = 'ProactiveRule';
    	for(Proactive_Rule__c pr : proactiveRuleLst) {
            Proactive_Rule__c oldPr;
            proActiveLst.add(pr);
            oldPr = proactiveOldMap.get(pr.Id);
        
            if(pr.Filter_Logic__c != oldPr.Filter_Logic__c 
                    || pr.Order_By__c != oldPr.Order_By__c 
                    || pr.Order_Type__c != oldPr.Order_Type__c 
                    || pr.Limit__c != oldPr.Limit__c) {
                
                pr.Output__c = ProactiveRuleUtils.generateProRuleOutput(proActiveLst, pr.Filter_Logic__c, pr.Order_By__c, pr.Order_Type__c, Integer.valueof(pr.Limit__c),objName);
            }
        }
    }
}