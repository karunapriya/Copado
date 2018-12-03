/**
    * @author    	Eswar Bala (eswar@comitydesigns.com)   
    * @date         May 18, 2016
    * @description  TriggerManager - Generic Manager to dispatch trigger execution flow
*/ 

global with sharing class TriggerManager {
	public static String TRIGGER_CHAIN = '';
	public interface ITriggerHandler {
       
        void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap);
        void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap);
        void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap);
        void onAfterUnDelete(List<sObject> newRecords);

	    void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap);
	    void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap);
	    void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap);
    }             
 
    public abstract class TriggerHandler implements ITriggerHandler {
	   
	    public virtual void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}
	    public virtual void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {}
	    public virtual void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}
	    public virtual void onAfterUnDelete(List<sObject> newRecords)	{}

	    public virtual void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}
	    public virtual void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {}
	    public virtual void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}

       	private void invoke(
                Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUnDelete,
                List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap) 
       	{
            	if(isBefore) 
                {
                	if (isInsert) 
                	{
                 		onBeforeInsert(newRecords, newRecordsMap);
                	}
                	else if (isUpdate) 
                	{
                 		onBeforeUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
                	}
                	else if (isDelete) 
                	{
                		onBeforeDelete(oldRecords, oldRecordsMap);
                	}

            	}
            	if(isAfter) 
                {
                	if (isInsert) 
                	{
                 		onAfterInsert(newRecords, newRecordsMap);
                	}
                	else if (isUpdate) 
                	{
                 		onAfterUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
                	}
                	else if (isDelete) 
                	{
                		onAfterDelete(oldRecords, oldRecordsMap);
                	}
                	else if (isUnDelete) 
                	{
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
       	String objName = (Trigger.new != null ? (Trigger.new[0].getSObjectType().getDescribe().getName()): (Trigger.old != null? (Trigger.old[0].getSObjectType().getDescribe().getName()): ''));
    	TRIGGER_CHAIN += '->' + objName;
    	DateTime startTime = System.now();
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
            System.debug('\n\n~-~-~- Finished SE ' + (Trigger.isBefore ? ' Before ' : (Trigger.isAfter ? ' After ' : '')) + (Trigger.isInsert ? ' Insert ' : (Trigger.isUpdate ? ' Update ' : (Trigger.isDelete? ' Delete ' : ' SomethingElse'))) + TRIGGER_CHAIN + (' trigger. \t Total time taken: ' + (System.now().getTime() - startTime.getTime()) + 'ms'));
            TRIGGER_CHAIN = TRIGGER_CHAIN.removeEnd('->' + objName);
    }
 }