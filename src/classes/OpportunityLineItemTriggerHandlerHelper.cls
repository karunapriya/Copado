public with sharing class OpportunityLineItemTriggerHandlerHelper {
    
    public static void validateFieldsUpdatesBeforeUpdate(Object triggerParamObj){   	
    	SS_TriggerCollectionParameters.OLITriggerParams oliTriggerParam = (SS_TriggerCollectionParameters.OLITriggerParams) triggerParamObj;
    	List<OpportunityLineItem> newRecordList = oliTriggerParam.newRecordList;
    	Map<Id,OpportunityLineItem> oldRecordsMap = oliTriggerParam.oldRecordsMap;
    	Map<Id,OpportunityLineItem> qualifiedOLIMap = oliTriggerParam.qualifiedOLIMap;
        PerformObjectFieldValidation performValidation = new PerformObjectFieldValidation();
       	if(performValidation.validateObjectFields('OpportunityLineItem')){
        	for(OpportunityLineItem oli: newRecordList){                    
            	if(PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_DataServicesUser ) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_SystemAdminUser) || PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_Edit_Closed_Sale_Opportunities)){
	            	if(qualifiedOLIMap.containskey(oli.id)){
	                	performValidation.checkObjectFieldValidation(oli,oldRecordsMap.get(oli.id));
	                }	                	
               	}else{
                 	oli.addError(System.Label.SYNCED_QUOTE_ID_BLANK_ERROR);
                }                    
        	}
   		}else{
        	Set<String> setOfInvalidFields = performValidation.getMissingFields();
           	for(sObject obj: newRecordList){
            	obj.addError(System.Label.FIELDS_ARE_MISSING_OR_INVALID + setOfInvalidFields);
            }
        }          
    }    
}