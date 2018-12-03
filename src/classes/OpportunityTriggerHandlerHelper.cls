public with sharing class OpportunityTriggerHandlerHelper {
    
    public static Set<String> missingFields;
    
    /**
    * @description : This method update Sales target on opportunity. Refactored as part of US2947.
      @param :  Map<ID, Opportunity> isWonOppOldRecMap : Map of qualified old Opp. where stageName - itsType is set to Closed/Won.
                List<Opportunity> oppList : List of new opp. having isWon 
    */
    public static boolean validateChanges(List<Opportunity> oppList, Map<ID, Opportunity> isWonOppOldRecMap){
        List<Opportunity> listOfRecordsToCheck = new List<Opportunity>();
        Map<ID,Opportunity> oldRecordMap = new Map<ID,Opportunity>();
        PerformObjectFieldValidation performValid = new PerformObjectFieldValidation();
        if(PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_DataServicesUser ) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_SystemAdminUser) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_Edit_Closed_Sale_Opportunities)){
            if(performValid.validateObjectFields('Opportunity')){
               	performValid.checkForValidUpdate(oppList, isWonOppOldRecMap);
                return true;
            }else{
                missingFields = performValid.getMissingFields();
                return false;    
            }
        }else{
            return true;
        }
    }
    
    /**
    * @description : This method update Sales target on opportunity. Refactored as part of US2947.
      @param : List<Opportunity> oppList : Qualified opp. which is having (StageName = 'Closed Sale') and (OwnerId or CloseDate or StageName is changed).
               Set<Id> oppOwnerIdSet : Set of Ids of opportunity owners.
               Map<ID, Opportunity> isWonOppOldMap : Map of qualified old Opp. where stageName - itsType is set to Closed/Won.
               List<Opportunity> opptyList : List of new opp. having isWon in old Opp.
    */
    public static void updateSalesTarget(SS_TriggerCollectionParameters.OpportunityTriggerParams opptyTriggerParam){
        system.debug('@@ Called updateSalesTarget Qualified Opp : '+ opptyTriggerParam.qualifiedOpportunityList);
	      
        if(!opptyTriggerParam.qualifiedOpportunityList.isEmpty()){
	        Map<Id,List<Sales_Target_Line_Item__c>> stMap = new Map<Id,List<Sales_Target_Line_Item__c>> ();
	        List<Sales_Target_Line_Item__c> stLItemList = SalesTargetDataAccess.getSalesTargetLineItemByEmployee(opptyTriggerParam.filteredIdSet);
	        List<Sales_Target_Line_Item__c> stLItemLst;
	        if(!stLItemList.isEmpty()){
	            for(Sales_Target_Line_Item__c stLI:stLItemList){
	                if(!stMap.isEmpty() && stMap.containsKey(stLI.Sales_Target__r.Employee__c)){
	                    List<Sales_Target_Line_Item__c> stLILst = stMap.get(stLI.Sales_Target__r.Employee__c);
	                    stLILst.add(stLI);
	                    stMap.put(stLI.Sales_Target__r.Employee__c,stLILst);
	                }else{
	                    stLItemLst = new List<Sales_Target_Line_Item__c>();
	                    stLItemLst.add(stLI);
	                    stMap.put(stLI.Sales_Target__r.Employee__c,stLItemLst);
	                }
	            }
	
	            for(Opportunity opp : opptyTriggerParam.qualifiedOpportunityList) {
	                Opportunity oldOpp = opptyTriggerParam.oldRecordsMap.get(opp.Id);
	                List<Sales_Target_Line_Item__c> stLI = new List<Sales_Target_Line_Item__c>();
	                List<Sales_Target_Line_Item__c> stLineILst = stMap.get(opp.OwnerId);
	                    for(Sales_Target_Line_Item__c s:stLineILst){
	                        if(s.End_Date__c >= opp.CloseDate && s.Start_Date__c <= opp.CloseDate){
	                            stLI.add(s); 
	                        }
	                    }
	                opp.Sales_Target__c = (stLI.size() != 0) ? stLI[0].Id : null;
	            }
	        }
        }
    }
   
}