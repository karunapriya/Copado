/**
     * Created Date     : Sep 7, 2016
     * Developed By     : ebala, Comity Designs, Inc.
     *
     * Function         : @description - Description about the functionality that the class provides
     * Support Email    : email
     * Version          : 1.0
     *
     * Modification Log
     *
     * Developer Name           User Story              Date            Version             Description
     *____________________________________________________________________________________________________
     *
     * ebala                    US1555              Sep 7, 2016         1.1                 @description
     *
     */
public with sharing class RenewableLineItemHandlerHelper {
    public static String namespaceSE = Util.solnExtnNameSpace;
    private static final String SS_REN_RENEWAL_TO = 'ServiceSource1__REN_Renews_To__c';
    /**
 * @description One or more lines that provide an overview of the method
 * @param paramName A description of what the parameter does, use multiple @param for multiple params
 * @return A description of the return value from the method
 * @example Example code usage. This will be wrapped in tags to preserve whitespace
 */

    public static void validateFieldsUpdate(Object triggerParam){
        //Set<Id> oppIdSet = new Set<Id>();
        Map<Id,Opportunity> mapOfOpp;
        List<sObject> listOfRecordsToValidate;
        Map<Id,sObject> oldMapOfRecords;
        boolean isValidation = false;
        Set<String> setOfInvalidFields;
        SS_TriggerCollectionParameters.RLITriggerParams triggerParamObj = (SS_TriggerCollectionParameters.RLITriggerParams) triggerParam;
        SS_Validations__c validationSettings = SS_Validations__c.getInstance(); 
        boolean isDsUser = PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_DataServicesUser);
        Set<String> blockedStagesSet = Util.convertCSVtoSet(validationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',');
        triggerParamObj.impactedOppIdSet.remove(null);
        mapOfOpp = OpportunityDataAccess.getOpportunityMapById(triggerParamObj.impactedOppIdSet);
        PerformObjectFieldValidation performValidation = new PerformObjectFieldValidation();
        if(isDsUser || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_SystemAdminUser) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_Edit_Closed_Sale_Opportunities)){
            isValidation = performValidation.validateObjectFields('REN_Renews_To__c');
        
            if(isValidation){
                listOfRecordsToValidate = new List<sObject>();
                oldMapOfRecords = new Map<Id,sObject>();
            }
            else{
                setOfInvalidFields = performValidation.getMissingFields();
            }
        }
        if(mapOfOpp != null){
            for(REN_Renews_To__c rr: triggerParamObj.newRecordsMap.values()){
                if(rr.REN_Renews_To__c != triggerParamObj.oldRecordsMap.get(rr.id).REN_Renews_To__c){
                    Opportunity oldOpp = mapOfOpp.get(triggerParamObj.oldRecordsMap.get(rr.id).REN_Renews_To__c);  
                    Opportunity newOpp = mapOfOpp.get(rr.REN_Renews_To__c);
                    
                    if((isDsUser && oldOpp.StageName == 'Closed Sale') || (!isDsUser && blockedStagesSet.contains(oldOpp.StageName) )){
                        rr.addError(String.format(Label.CANNOT_REPARENT_RLI_ON_CLOSED_OPP, new String[]{oldOpp.Name}));                             
                    }
                    if((isDsUser && newOpp.StageName == 'Closed Sale') || (!isDsUser && blockedStagesSet.contains(newOpp.StageName) )){
                        rr.addError(String.format(Label.CANNOT_REPARENT_RLI_ON_CLOSED_OPP, new String[]{newOpp.Name}));                                 
                    }
                }
                if(isValidation){
                    if(rr.REN_Renews_To__c != null && (mapOfOpp.containsKey(rr.REN_Renews_To__c))){
                            if(mapOfOpp.get(rr.REN_Renews_To__c).StageName == 'Closed Sale'){
                                listOfRecordsToValidate.add(rr);
                                oldMapOfRecords.put(rr.id,triggerParamObj.oldRecordsMap.get(rr.id));
                            }
                        }
                }
                else if(setOfInvalidFields != null){
                    rr.addError(System.Label.FIELDS_ARE_MISSING_OR_INVALID + setOfInvalidFields);
                }
            }
            if(listOfRecordsToValidate!=null && listOfRecordsToValidate.size()>0){
                performValidation.checkForValidUpdate(listOfRecordsToValidate,oldMapOfRecords);
            }
            
        }
            
    }
        
}