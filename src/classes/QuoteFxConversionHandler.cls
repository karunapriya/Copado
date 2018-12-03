/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         05/20/2016
 * @description  QuoteFxConversionHandler called from OpportunityTriggerHandler, QuoteFxTriggerHandler and QuoteFxLineItemTriggerHandler
 */
public with sharing class QuoteFxConversionHandler{  
    
    /**
    * @description : This method is to validate fields and object as per PerformObjectFieldValidation rec. Refactored as part of US2963.
      @param : List<Opportunity> qualifiedRecList : List of new opp. having isWon 
    */
    public static void validateObjectFieldsToUpdate(Object triggerParamObj){
		SS_TriggerCollectionParameters.sObjectTriggerParams objTriggerParam = (SS_TriggerCollectionParameters.sObjectTriggerParams) triggerParamObj;      
        PerformObjectFieldValidation performValidation = new PerformObjectFieldValidation();
        if(!objTriggerParam.qualifiedRecList.isEmpty()){
        	if(performValidation.validateObjectFields(objTriggerParam.objectName)){
        		boolean isAdminOrDSUser = (PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_DataServicesUser) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_SystemAdminUser) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_Edit_Closed_Sale_Opportunities));
        		for(sObject obj : objTriggerParam.qualifiedRecList){ 
            		if(isAdminOrDSUser){
	        			performValidation.checkObjectFieldValidation(obj,objTriggerParam.oldRecordsMap.get(obj.id));
        			} else {
        				obj.addError(System.Label.OPP_CLOSED_REOPEN_TO_UPDATE);
            		}
        		}
   			}else{
        		Set<String> setOfInvalidFields = performValidation.getMissingFields();
           		for(sObject obj: objTriggerParam.qualifiedRecList){
            		obj.addError(System.Label.FIELDS_ARE_MISSING_OR_INVALID + setOfInvalidFields);
        		}
        	}
    	}
    }
}