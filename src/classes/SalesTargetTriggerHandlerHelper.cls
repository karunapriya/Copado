public with sharing class SalesTargetTriggerHandlerHelper {
	public static void checkSetCriteriaBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		List<Sales_Target__c> lstSalesTarget = new List<Sales_Target__c>();
		system.debug('lstSalesTarget---1---'+ lstSalesTarget);
		lstSalesTarget = newRecords;
		system.debug('lstSalesTarget---1---'+ lstSalesTarget);
        Set<String> currentCriteriaCheckerSet = new Set<String>();
        Set<String> existingCriteriaCheckerSet = new Set<String>();
        
        for(Sales_Target__c st : lstSalesTarget){
        	
            currentCriteriaCheckerSet.add(String.valueOf(st.Period__c) + ':' + String.valueOf(st.Employee__c));
        }
        
        for(Sales_Target__c st : SalesTargetDataAccess.getSalesTargetsByCriteria(currentCriteriaCheckerSet)){
            existingCriteriaCheckerSet.add(st.Criteria_Checker__c);
        }
        
        for(Sales_Target__c st : lstSalesTarget){
            String dupeChecker = String.valueOf(st.Period__c) + ':' + String.valueOf(st.Employee__c);
            if(existingCriteriaCheckerSet.contains(dupeChecker)){
                st.addError(Label.MSG_SALES_TARGET_PERIOD);
            }
            else{
                st.Criteria_Checker__c = String.valueOf(st.Period__c) + ':' + String.valueOf(st.Employee__c);
            }
        }
    }

     public static void checkCriteriaForInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
        List<Sales_Target__c> salesTargetList = new List<Sales_Target__c>();
        List<Sales_Target__c> lstSalesTarget = new List<Sales_Target__c>();
        lstSalesTarget = newRecords;
        for(Sales_Target__c st : lstSalesTarget){
            salesTargetList.add(st);
        }
    
	    if(salesTargetList.size() > 0){
	        SalesTargetExtension.generateSalesTarget(salesTargetList);
	    }
     }
    
}