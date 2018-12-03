public with sharing class CSM_LeadTriggerHelper {
	// Method : When lead is converted then remove the field value of Account__c field on task.
    public static void getConvertedLead(List<sObject> newRecords) {
		String namespace = CSM_Util.nameSpacePrefixSolnExtn;
		// Set to hold references to all lead Id invoking trigger...    
		set<Id> leadSet =new set<Id>();
		
		// Interate over the lead which invoked this trigger (basically lead conversion on Update)... and to add set.
		for(Lead ld:(list<Lead>)newRecords){
		    if(ld.isConverted == true){
		       leadSet.add(ld.ConvertedContactId );	
		    }
		}
		
		// Query task that matching whoid in leadset.
		if(CSM_AccessController.hasField('TASK', CSM_Util.nameSpacePrefixSolnExtn + 'Account__c')){  
			 List<Task> tasklist = CSM_TaskDataAccess.getTasksByWhoId(leadSet);
			 List<Task> taskListToUpdate = new List<Task>();
		 
		// Finally, interate over task and update Account__c = null.
			for (task currentTask : taskList){	
			   if ((String)currentTask.get(namespace + 'Account__c') != null) {
				    currentTask.put(namespace + 'Account__c',null);
				    taskListToUpdate.add(currentTask);
			   }
			}
		
			// Update task 
			if (!taskListToUpdate.isEmpty() && taskListToUpdate != null) {
				CSM_TaskDataAccess.updateLeadTasks(taskListToUpdate);
			}
		}
    }
    
    //Method : When Lead Lookup (Account) 1 is udpated on lead then populated account__c field with the same value 
    public static void updatedLeadRecord(Map<ID, sObject> newRecordsMap){
		
		   // Set to hold the references to all lead Id invoking trigger...
		   Set<id> leadSet=new Set<id>();
		   // Map to hold the references to all lead Id invoking trigger...
		   Map<Id, Lead> leadMap = new Map<Id, Lead>();
		    	
		   // Interate over the lead Ids which invoked this trigger (basically on update)... and to add set and map.
		   for (Id ids : newRecordsMap.keyset()){
		    	leadMap.put(ids,(Lead)newRecordsMap.get(ids));
		    	leadSet.add(ids);
		   }
	       // Query on lead that matching id in leadSet.
	       if(CSM_AccessController.hasField('TASK', CSM_Util.nameSpacePrefixSolnExtn + 'Account__c') && CSM_AccessController.hasField('Lead', CSM_Util.nameSpacePrefixSolnExtn + 'Lead_Lookup_Account_1__c')){
		   		List<Task> taskListToUpdate = CSM_TaskDataAccess.updatetaskAcc(CSM_TaskDataAccess.getTasksByWhoId(leadSet),leadMap);
		   	
			   // Update Account__c field value on task object.
			   if (!taskListToUpdate.isEmpty() && taskListToUpdate != null) {
				   CSM_TaskDataAccess.updateLeadTasks(taskListToUpdate);
			   }
	       }
    }
}