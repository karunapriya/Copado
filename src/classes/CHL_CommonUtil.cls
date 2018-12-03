/**
 * Created Date		: Jul 27, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dilip					User Story				Jul 27, 2018			1.1					@description
 *
 */
public with sharing class CHL_CommonUtil {

   private static Map<String, boolean> objectToLocalHandlerDefinedMap = new Map<String, boolean>();
   private static Map<String, String> objectToLocalHandlerClassMap = new Map<String, String>{'QuoteLineItem' => 'QLI', 'Quote' => 'Quote'};		
	
	/*
     * @Description: This method is used to call the custom trigger handler and it will be invoked by all five base object trigger. (Opportunity, OLI, RLI, Quote, QLI)
    **/
    public static void customTriggerHandlerInvokation(){
    	try{
    		
    		String triggerObjectName = Trigger.isDelete ? Trigger.old[0].getSObjectType().getDescribe().getName() : Trigger.new[0].getSObjectType().getDescribe().getName();
    		String localHandlerName = 'TriggerHandlerFor' + objectToLocalHandlerClassMap.get(triggerObjectName); //Opportunity, OLI, Quote, QLI, RLI
			
			if(!objectToLocalHandlerDefinedMap.containsKey(triggerObjectName)){
				
			    if([select Id from ApexClass where Name = :localHandlerName].size() > 0){
			    	objectToLocalHandlerDefinedMap.put(triggerObjectName, true);
			    }else{
			    	objectToLocalHandlerDefinedMap.put(triggerObjectName, false);
			    }
			}
			
			if(objectToLocalHandlerDefinedMap.get(triggerObjectName)){
				System.debug(localHandlerName + ' class inviked, defined locally.');
				
				Type typeObj = type.forName(localHandlerName);
		        Object handler = typeObj.newInstance();
		        if (handler instanceof SS_FeatureInvocation.FeatureHandler) {
		            ((SS_FeatureInvocation.FeatureHandler)handler).featureInvocation(null);
		        }				
				
			}
    		
    	}catch(Exception ex){
    		system.debug(Logginglevel.ERROR, '\n\n~~~~ Exception:' + ex.getMessage());
            system.debug(ex);
            List<sObject> objList = (Trigger.isDelete ? Trigger.old : Trigger.new);
            for (Integer i = 0; i < objList.size(); i++){
                objList[i].addError(ex.getMessage());
            } 
    	}
    }
    
}