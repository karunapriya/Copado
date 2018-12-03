/**
 * Created Date		: Nov 17, 2016
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: This handler validates that only 1 filter is active for a given object. It deactivates the already active
                      record in the object, if the inserted record has active flag checke.   
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					US1754				Nov 17, 2016			1.1					@description
 * 
 */
public with sharing class CSM_BatchFilterTriggerHandler extends CSM_TriggerManager.TriggerHandler {

    public CSM_BatchFilterTriggerHandler() {
	    
		// TODO Auto-generated constructor stub
	}

     public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
     {
        Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
                      
        if (hasCSMAccess || hasRenewAccess){
        	processActiveFilters(newRecords);
        } 

		CSM_Constants.BatchFilter_TRIGGER = true;
     }
     
	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) 
	{
		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
		Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		
		if (hasCSMAccess || hasRenewAccess){
        	processActiveFilters((List<CSM_Batch_Filter__c>)newRecords);             
		}
		CSM_Constants.BatchFilter_TRIGGER = true;
	}    

	public void processActiveFilters(List<CSM_Batch_Filter__c> filterRecords){
     	String namespace = CSM_Util.getNameSpace();	
     	Set<string> ignoreIds = new Set<string>();	
        List<CSM_Batch_Filter__c> batchFilterList = new List<CSM_Batch_Filter__c>();
        Set<String> batchJobNames = new Set<String>();
	
    	for(CSM_Batch_Filter__c batchFilter: filterRecords){
    		batchJobNames.add(batchFilter.CSM_Batch_Job_Name__c);
    		if(Trigger.isUpdate){
    			ignoreIds.add(batchFilter.Id);
    		}
    	}
		List<CSM_Batch_Filter__c> batchActiveFilterList = CSM_BatchFilterDataAccess.getBatchFilterByJobName(batchJobNames);
		Set<String> filterActiveSet = new Set<String>();
		if(batchActiveFilterList != null && !batchActiveFilterList.isEmpty()){
			batchJobNames.clear();
			for(CSM_Batch_Filter__c batchFilter :batchActiveFilterList){
				filterActiveSet.add(batchFilter.CSM_Batch_Job_Name__c);					
			}

        	for(CSM_Batch_Filter__c batchFilter: filterRecords){
        		if(batchFilter.CSM_IsActive__c){
        			String batchName = batchFilter.CSM_Batch_Job_Name__c;
        			if(filterActiveSet.contains(batchName)){
        				batchJobNames.add(batchName);
        			}
        		}
        	}
				
            if(!batchJobNames.isEmpty()){
            	batchFilterList = CSM_BatchFilterDataAccess.getAllBatchFilterByJobName(batchJobNames,ignoreIds);  
            	
            	for(CSM_Batch_Filter__c batchFilter: batchFilterList){
           			batchFilter.CSM_IsActive__c = false;            		
            	} 
            	
            	CSM_BatchFilterDataAccess.updateBatchFilter(batchFilterList);
            } 
		}				
	}

}