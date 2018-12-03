global with sharing class CaseCreationBatch implements Database.Batchable<sObject> {
    public String queryString;
    public String proRuleId;
    public String proRuleOutput;
   	 
    global CaseCreationBatch() {
    }
    
    global Database.QueryLocator Start(Database.BatchableContext BC) {
        System.debug('##### queryString : ' + queryString);
        if(String.isNotBlank(queryString)){
        	return Database.getQueryLocator(queryString);
        }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	Map<String, String> caseValueMap = new Map<String, String>();
        List<String> caseFieldList = new List<String>();
        List<Case> caseList = new List<Case>();
        List<String> caseFLSList = new List<String> {Util.solnExtnNameSpace + 'Opportunity__c',Util.solnExtnNameSpace + 'Opportunity_Earliest_Existing_End_Date__c',Util.solnExtnNameSpace + 'Proactive_Rule__c','Origin'};
    	Map<String, String> fieldTypeMap = new Map<String, String>();
    	Map<String, Schema.SObjectField> caseSchemaMap = Schema.SObjectType.Case.fields.getMap();
    	
    	for(Schema.SObjectField sfield : caseSchemaMap.values()) {
        	String fieldNameVal = String.valueOf(sfield.getDescribe().getName());
        	String fieldTypeVal = String.valueOf(sfield.getDescribe().getSoapType());
            fieldTypeMap.put(fieldNameVal, fieldTypeVal);
            system.debug('#### fieldNameVal : ' + fieldNameVal + ' #### fieldTypeVal : ' + fieldTypeVal);
        }
        
        List<Proactive_Case_Setup__c> proCaseSetupList = ProactiveDataAccess.getProactiveCaseSetupByRule(new Set<String>{proRuleId});
        if(proCaseSetupList != null){
	        for(Proactive_Case_Setup__c pcs : proCaseSetupList) {
	            caseFieldList.add(pcs.Field__c);
	            caseValueMap.put(pcs.Field__c, pcs.Value__c);
	        }
        }
    	
    	for(sObject sObj : scope){
            Opportunity opp = (Opportunity)sObj;
            Case c = new Case();
            System.debug('###### caseFieldList: ' + caseFieldList);
            for(String caseField : caseFieldList) {
            	String dataTypeVal = fieldTypeMap.get(caseField);
            	system.debug('dataTypeVal : ' + dataTypeVal);
                if(dataTypeVal == 'DOUBLE'){
                	if(!caseField.contains('__')){
                		c.put(Util.solnExtnNameSpace + caseField, Decimal.valueOf(caseValueMap.get(caseField)));
                	}
                	else{
                		c.put(caseField, Decimal.valueOf(caseValueMap.get(caseField)));
                	}
            	}
                else{     	
                    //System.debug('\n~~~~: ' + caseField);
                    if(caseField.endsWith('__c')){
                        String fName = caseField.replace('__c', '');
                        if(!fName.contains('__')){
                            c.put(Util.solnExtnNameSpace + caseField, caseValueMap.get(caseField));
                        }else{
                            c.put(caseField, caseValueMap.get(caseField));
                        }
                    }
                	else{
                		c.put(caseField, caseValueMap.get(caseField));
                	}
            	}
            }
    
            c.put(Util.solnExtnNameSpace + 'Opportunity__c', opp.Id);
            c.put(Util.solnExtnNameSpace + 'Opportunity_Earliest_Existing_End_Date__c', opp.REN_Earliest_Expiration_Date__c);
            c.put(Util.solnExtnNameSpace + 'Proactive_Rule__c', proRuleId);
            c.put('Origin', Constants.PROACTIVE);
            
            caseList.add(c);
        }
        if(!caseList.isEmpty()) 
        {
            CaseDataAccess.insertCases(caseList,caseFLSList);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('##### Finished');
    }
}