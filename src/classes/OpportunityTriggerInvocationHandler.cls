global with sharing class OpportunityTriggerInvocationHandler extends SS_FeatureInvocation.FeatureHandler {
	
	global override void featureInvocation(Object parameters) {
    	SS_TriggerCollectionParameters.OpportunityTriggerParams opptyTriggerParam = (SS_TriggerCollectionParameters.OpportunityTriggerParams) parameters;
      	if(opptyTriggerParam.triggerEvent.equalsIgnoreCase('onBeforeUpdate')){
       		if(!OpportunityTriggerHandlerHelper.validateChanges(opptyTriggerParam.filteredOpportunityList,opptyTriggerParam.qualifiedOpportunityMap)){ // ObjectFieldValidation
	        	for(sObject obj : opptyTriggerParam.filteredOpportunityList){
	            	obj.addError(System.Label.LBL_MISSING_FIELDS_ON_OPP + OpportunityTriggerHandlerHelper.missingFields);
	            }
	            return;
	        }
			OpportunityTriggerHandlerHelper.updateSalesTarget(opptyTriggerParam);//Before Trigger
       }else if(opptyTriggerParam.triggerEvent.equalsIgnoreCase('onAfterUpdate')){
       		Constants.CASE_BEFORE_UPDATE_TRIGGER = false;//DE2965 
        	OpportunityUtils.updateCaseClosedAutomatically(parameters);//After Trigger
       }       
	}
}