/**
    * @author    	Mike Faust (mike@comitydesigns.com)    
    * @date         8/28/2014
    * @description  CSM_TriggerManager - Generic Manager to dispatch trigger execution flow
    */ 

global with sharing class CSM_TriggerManager {

	private static Set<ID> recordProcessedSet = new Set<ID>();
	private static String firstTriggerObjectName = null;	
	public static boolean enableOLITrigger = false;	//This static flag is used to turn on OLI Trigger explicitly from Quotesync Scenario
	public static boolean enableQLITrigger = false; //This static flag is used to turn on QLI Trigger explicitly from Quote during quote creation from UI
	private static Map<String, boolean> objectToLocalHandlerDefinedMap = new Map<String, boolean>();
	private static Map<String, String> objectToLocalHandlerClassMap = new Map<String, String>{'Opportunity' => 'Opportunity', 'OpportunityLineItem' => 'OLI', 'REN_Renews_To__c' => 'RLI', 'ServiceSource1__REN_Renews_To__c' => 'RLI'};		
	
	/**
	 * @description:  This method will block all the triggers. (Before/After, Insert/Update/Delete/Undelete). 
	 */
	global static void disableAllTriggers(){
		firstTriggerObjectName = 'None';
	}

	/**
	 * @description:  This method will allow to execution of first DML trigger block. (Before/After, Insert/Update/Delete/Undelete). 
	 */
	global static void enableFirstTrigger(){
		firstTriggerObjectName = null;
		recordProcessedSet.clear();
	}	
	
	/**
	 * @description  Invoke trigger handler by existing instance. Usage: in trigger make call like  CSM_TriggerManager.invokeHandler(new ContactTriggerhandler());
	 */
	public static void invokeHandler(TriggerHandler handler) {
		if (CSM_TriggerEnablementDataAccess.getInstance().byPassDataloadValidation){
			System.debug( '\n\nByPass Trigger CS is turned on');
			return;
		}
		String triggerObjectName = Trigger.isDelete ? Trigger.old[0].getSObjectType().getDescribe().getName() : Trigger.new[0].getSObjectType().getDescribe().getName();
		firstTriggerObjectName = String.isBlank(firstTriggerObjectName)?triggerObjectName:firstTriggerObjectName;
		
		String triggerDetails = triggerObjectName + (Trigger.isBefore ? ' Before' : (Trigger.isAfter ? ' After' : '')) + (Trigger.isInsert ? ' Insert' : (Trigger.isUpdate ? ' Update' : (Trigger.isDelete? ' Delete' : ' SomethingElse')));
		
		//Below condition is added to call OLI/QLI trigger explictly in Quote sync scenario. 
		Boolean isAfterInsertTrigger = Trigger.isAfter && Trigger.isInsert ; 
		Boolean isTriggerUnblocked = (
			(enableOLITrigger && triggerObjectName == 'OpportunityLineItem' && (Trigger.isDelete || isAfterInsertTrigger)) //Need to unable OLI trigger for : If Quote is Synced & new QLI is added, also if we add QLIs to quote which is not synced & then synced this quote, then to copy QLI to OLI Custom fields.
			|| (enableQLITrigger && triggerObjectName == 'QuoteLineItem' && (Trigger.isDelete || isAfterInsertTrigger)) //Need to unable QLI trigger if Quote is created from UI then to copy custom field values from OLI to QLI. If QLIs are deleted on synced Quote, then it first deletes OLI due to which QLI trigger wont get executed.
			
		);
		Boolean isFirstTrigger = firstTriggerObjectName == triggerObjectName ;
		Boolean isBeforeEvent = Trigger.isBefore && Trigger.isInsert ;
		//Set<Id> currentRecordSet = Trigger.isDelete ? Trigger.oldMap.keySet() : Trigger.newMap.keySet();
		Boolean isTriggerExecutionAllowed = (isBeforeEvent 	|| 	!recordProcessedSet.containsAll(Trigger.isDelete ? Trigger.oldMap.keySet() : Trigger.newMap.keySet())) ;
		
		if (isTriggerUnblocked || (isFirstTrigger && isTriggerExecutionAllowed)) {
			if (Trigger.isAfter ){
				recordProcessedSet.addAll(Trigger.isDelete ? Trigger.oldMap.keySet() : Trigger.newMap.keySet());
			}
			DateTime startTime = System.now();
            System.debug('\n\nTRIGGER-EXECUTION STARTED: ' + triggerDetails + ' at: ' + startTime);
			try {
				handler.invoke(
						Trigger.isBefore, 
						Trigger.isAfter, 
						Trigger.isInsert, 
						Trigger.isUpdate, 
						Trigger.isDelete,
						Trigger.isUnDelete,
						Trigger.old, 
						Trigger.new, 
						Trigger.oldMap,
						Trigger.newMap);
			} catch(Exception ex){
				REN_Util.setErrorInObjects (Trigger.isDelete ? Trigger.old : Trigger.new, ex);
			}
            System.debug('\n\nTRIGGER-EXECUTION FINISHED: ' + triggerDetails + '. Trigger execution finished. Total time taken: ' + (System.now().getTime() - startTime.getTime()) + 'ms');
		}else{
			System.debug( 'Trigger Blocked: ' + triggerDetails);
		}
	}

	/**
	 * @description  Invoke trigger handler by type Usage: in trigger make call like  CSM_TriggerManager.invokeHandler(ContactTriggerhandler.class);
	 */
	public static void invokeHandler(Type type) {
		Object handler = type.newInstance();
		if (handler instanceof TriggerHandler) {
			invokeHandler((TriggerHandler) handler);
		}
	} 

	/**
	 * @description  Invoke trigger handler by type Usage: in trigger make call like  CSM_TriggerManager.invokeHandler('ContactTriggerhandler.class');
	 */
	global static void invokeHandler(String typeName) {
		Type typeObj = type.forName(typeName);
		//invokeHandler(typeObj);
		Object handler = typeObj.newInstance();
		if (handler instanceof TriggerHandler) {
			invokeHandler((TriggerHandler) handler);
		} 
	}
	
//--------------------------------------Old logic-------------------------------------------------//
	public abstract class TriggerHandler{

		public virtual void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}
		public virtual void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {}
		public virtual void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}
		public virtual void onAfterUnDelete(List<sObject> newRecords) {}

		public virtual void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}
		public virtual void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {}
		public virtual void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}

		private void invoke(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUnDelete,
				List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap){
			if(isBefore) {
				if (isInsert) {
					onBeforeInsert(newRecords, newRecordsMap);
				}else if (isUpdate) {
					onBeforeUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
				}else if (isDelete) {
					onBeforeDelete(oldRecords, oldRecordsMap);
				}
			}else if(isAfter) {
				if (isInsert){
					onAfterInsert(newRecords, newRecordsMap);
				}else if (isUpdate){
					onAfterUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
				}else if (isDelete){
					onAfterDelete(oldRecords, oldRecordsMap);
				}else if (isUnDelete){
					onAfterUnDelete(newRecords);
				}
			}
		}
	}
	/**
	 * @description  Invoke trigger handler by type Usage: in trigger make call like  TriggerManager.invoke(ContactTriggerhandler.class);
	 */
	public static void invoke(Type type) {
		Object handler = type.newInstance();
		if (handler instanceof TriggerHandler) {
			invoke((TriggerHandler) handler);
		}
	} 

	/**
	 * @description  Invoke trigger handler by type Usage: in trigger make call like  TriggerManager.invoke(ContactTriggerhandler.class);
	 */
	global static void invoke(String typeName) {
		Type typeObj = type.forName(typeName);
		Object handler = typeObj.newInstance();
		if (handler instanceof TriggerHandler) {
			invoke((TriggerHandler) handler);
		}
	} 
 
  	/**
     * @description  Invoke trigger handler by existing instance. Usage: in trigger make call like  TriggerManager.invoke(new ContactTriggerhandler());
     */
    public static void invoke(TriggerHandler handler) {
		String triggerObjectName = Trigger.isDelete ? Trigger.old[0].getSObjectType().getDescribe().getName() : Trigger.new[0].getSObjectType().getDescribe().getName();
		DateTime startTime = System.now();
    	System.debug('\n\nOLD trigger handler started for: ' + triggerObjectName);
        handler.invoke(
            Trigger.isBefore, 
            Trigger.isAfter, 
            Trigger.isInsert, 
            Trigger.isUpdate, 
            Trigger.isDelete,
            Trigger.isUnDelete,
            Trigger.old, 
            Trigger.new, 
            Trigger.oldMap,
            Trigger.newMap
		);
    	System.debug('\n\nOLD trigger: ' + triggerObjectName + '. execution finished. Total time taken: ' + (System.now().getTime() - startTime.getTime()) + 'ms');
    }
    
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
				System.debug(localHandlerName + ' class invoked, defined locally.');
				(new SS_FeatureInvocation()).invoke('', localHandlerName, null);
			}
    		
    	}catch(Exception ex){
    		REN_Util.setErrorInObjects (Trigger.isDelete ? Trigger.old : Trigger.new, ex);
    		System.debug('**Exception ' + ex.getStackTraceString());
    	}
    }
 }