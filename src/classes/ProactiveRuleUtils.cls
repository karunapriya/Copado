public with sharing class ProactiveRuleUtils {

    public static String generateProRuleOutput(list<sObject> ProRuleId, String FilterLogic, String OrderBy, String OrderType, Integer RecordLimit,String ObjName) {
        
        String outputCondition = '';
        String outputOrderBy = '';
        String outputLimit = '';
        String outputFinal = 'SELECT Id, REN_Earliest_Expiration_Date__c FROM Opportunity';
        List<String> outputList = new List<String>();
        Map<String, String> outputMap = new Map<String, String>();
        if(ObjName.equals('ProactiveRuleLineItem')){
	        list<Proactive_Rule_Line_Item__c> proALineRItemList = new list<Proactive_Rule_Line_Item__c>();
	        proALineRItemList = ProRuleId;
	        for(Proactive_Rule_Line_Item__c prl : proALineRItemList) {
	            outputList.add(prl.Name);
	            outputMap.put(prl.Name, prl.Output__c);
	        }
    	}
        if(FilterLogic != null && FilterLogic != '' ) {
        	
        	Set<Id> pAIdSet = new Set<ID>();
	        for( sObject sobj : ProRuleId) {
	            pAIdSet.add((Id)sObj.get('Id'));
	        }
        	List<Proactive_Rule_Line_Item__c> proActiveLineItemLst = ProactiveDataAccess.getProactiveLineItemsByRule(pAIdSet);
        	for(Proactive_Rule_Line_Item__c prl : proActiveLineItemLst) {
	            outputList.add(prl.Name);
	            outputMap.put(prl.Name, prl.Output__c);
	        }
            outputCondition = ' WHERE ' + FilterLogic;
            for(String o : outputList) {
            	if(outputMap.get(o) != null){
            		system.debug('(o)----1-----'+o);
               		outputCondition = outputCondition.replace(o, outputMap.get(o));
            	}
            }
        }
        else {
            for(String o : outputList) {
                if(outputCondition == ''){
                	outputCondition = ' WHERE ';
                	//Eswar Bala - 08/29/2016
                	String wholeQuery = outputMap.get(o);
                	system.debug('wholeQuery pre : ' + wholeQuery);
                	if(wholeQuery != null){
                		//Integer wherePosition = (wholeQuery).indexOf('where');
                		outputCondition += wholeQuery ;// wholeQuery.right(wherePosition);
                		system.debug('outputCondition----pr if list--in---'+outputCondition);
                	}
                }
                else{
                	outputCondition += ' AND ' + outputMap.get(o);
                	system.debug('outputCondition----pr else list-----'+outputCondition);
                }
            }
        }
        
        if(OrderBy != null && OrderBy != '') {
            if(OrderType != null && OrderType != '') {
                if(OrderType == 'Descending') outputOrderBy = ' ORDER BY ' + OrderBy + ' DESC';
                else outputOrderBy = ' ORDER BY ' + OrderBy + ' ASC';
            }
            else outputOrderBy = ' ORDER BY ' + OrderBy + ' ASC';
        }
        system.debug('outputOrderBy--- -pr list-----'+outputOrderBy);
        if(RecordLimit != 0 && RecordLimit != null) {
        	outputLimit = ' LIMIT ' + RecordLimit;
        }
		
        system.debug('outputCondition--- -pr last list-----'+outputCondition);
        outputFinal += outputCondition + outputOrderBy + outputLimit;
        return outputFinal;
    }
    
    public static void regenerateProRuleOutput(List<String> ProRuleId, boolean isUpdated) {
    	map<Id,list<Proactive_Rule_Line_Item__c>> pliMap= new map<Id,list<Proactive_Rule_Line_Item__c>>();
    	Set<Id> ProRule = new  Set<Id>();
    	for(String proRuleStr : ProRuleId){
    		ProRule.add(Id.valueOf(proRuleStr));
    	}
    	list<Proactive_Rule_Line_Item__c> proLIList = ProactiveDataAccess.getProactiveLineItemsByRule(ProRule);
    												//[SELECT Id, Name, Output__c,Proactive_Rule__c FROM Proactive_Rule_Line_Item__c WHERE Proactive_Rule__c IN :ProRuleId];
        list<Proactive_Rule_Line_Item__c> proActiveList;
        for(Proactive_Rule_Line_Item__c prLi:proLIList){
       		if(!pliMap.isEmpty() && pliMap.containsKey(prLi.Proactive_Rule__c)){
       			proActiveList = pliMap.get(prLi.Proactive_Rule__c);
       			proActiveList.add(prLi);
       		}
       		else{
       			proActiveList = new list<Proactive_Rule_Line_Item__c>();
       			proActiveList.add(prLi);
       			pliMap.put(prLi.Proactive_Rule__c,proActiveList);
       		}
        }
        list<Proactive_Rule__c> prToRegenerateList = new List<Proactive_Rule__c>();
        String objName = 'ProactiveRuleLineItem';
        List<Proactive_Rule__c> prActiveList = ProactiveDataAccess.getProactiveRuleById(new Set<String>(ProRuleId));
        for(Proactive_Rule__c pr : prActiveList) {
            if(pliMap.get(pr.Id) != null)
            //pr.Output__c = generateProRuleOutput(pliMap.get(pr.Id), pr.Filter_Logic__c, pr.Order_By__c, pr.Order_Type__c, Integer.valueof(pr.Limit__c),objName);
            pr.Output__c = generateProRuleOutput(pliMap.get(pr.Id), pr.Filter_Logic__c, pr.Order_By__c, pr.Order_Type__c, Integer.valueof(pr.Limit__c),objName);
            
            system.debug('----pr.Output__c----'+pr.Output__c);
            prToRegenerateList.add(pr);
        }
        List<String> proactiveRuleFieldList =  new List<String>{Util.solnExtnNameSpace +'Output__c'};
        
        if(isUpdated){
        	ProactiveDataAccess.updateProactiveRules(prToRegenerateList, proactiveRuleFieldList);
        }
       
    }
}