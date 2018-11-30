public with sharing class REN_BatchActivityHelper {
    //This method takes an sobject record and returns a wrapper record.
    //# of SOQLs = 1
    public static REN_BatchActivityWrapper getBatchActivityWrapperById(sObject batchActivitySObject){
    	REN_BatchActivityWrapper batchActivityWrap = new REN_BatchActivityWrapper();
		                                    
    	if(batchActivitySObject != null){
    		batchActivityWrap.batchActivity = batchActivitySObject;
    		batchActivityWrap.batchNumber = (String)batchActivitySObject.get('REN_Batch_Number__c');
    		batchActivityWrap.batchType = (String)batchActivitySObject.get('REN_Batch_Type__c');
    		batchActivityWrap.closedDateDependsOn = (String)batchActivitySObject.get('REN_Closed_Date_Depends_On__c');
    		batchActivityWrap.closedDateOption = (String)batchActivitySObject.get('REN_Closed_Date_Options__c');
    		
    		batchActivityWrap.createdById = (Id)batchActivitySObject.get('REN_Created_By__c');
    		if(batchActivityWrap.createdById != null){
    			batchActivityWrap.createdByName = (String)batchActivitySObject.getSObject('REN_Created_By__r').get('name');
    		}
    		
    		batchActivityWrap.createdOn = (DateTime)batchActivitySObject.get('REN_Created_On__c');
    		batchActivityWrap.emailNotificationOn = (Boolean)batchActivitySObject.get('REN_Email_Notification__c');
    		batchActivityWrap.assetsFailedCount = Integer.valueOf(batchActivitySObject.get('REN_Failure_Assets__c'));
    		batchActivityWrap.filterCriteria = (String)batchActivitySObject.get('REN_Filter_Criteria__c');
    		batchActivityWrap.generatedRecordsCount = Integer.valueOf(batchActivitySObject.get('REN_Generated_Records__c'));
    		
    		batchActivityWrap.groupingId = (Id)batchActivitySObject.get('REN_Grouping__c');
    		if(batchActivityWrap.groupingId != null){
	    		batchActivityWrap.groupingDesc = (String)batchActivitySObject.getSObject('REN_Grouping__r').get('REN_Description__c');
	    		batchActivityWrap.groupingFilterCriteria = (String)batchActivitySObject.getSObject('REN_Grouping__r').get('REN_Filter_Criteria__c');
	    		batchActivityWrap.groupingName = (String)batchActivitySObject.getSObject('REN_Grouping__r').get('REN_View_Name__c');
    		}
    		
    		batchActivityWrap.groupingAndFilterCriteria = (String)batchActivitySObject.get('REN_Grouping_Filter__c');
    		batchActivityWrap.groupingCriteria = (String)batchActivitySObject.get('REN_Grouping_Criteria__c');
    		
    		batchActivityWrap.jobCompletionDate = (DateTime)batchActivitySObject.get('REN_Job_Completion_Date__c');
    		batchActivityWrap.jobId = (String)batchActivitySObject.get('REN_Job_ID__c');
    		batchActivityWrap.jobStartDate = (DateTime)batchActivitySObject.get('REN_Job_Start_Date__c');
    		
    		batchActivityWrap.lastModifiedByUserId = (Id)batchActivitySObject.get('REN_Last_Modified_By__c');
    		if(batchActivityWrap.lastModifiedByUserId != null){
    			batchActivityWrap.lastModifiedByUserName = (String)batchActivitySObject.getSObject('REN_Last_Modified_By__r').get('name');
    		}
    		
    		batchActivityWrap.lastModifiedOn = (DateTime)batchActivitySObject.get('REN_Last_Modified_On__c');
    		batchActivityWrap.objectName = (String)batchActivitySObject.get('REN_Object__c');
    		batchActivityWrap.planTemplateAssignmentName = (String)batchActivitySObject.get('REN_Plan_Template_Name__c');
    		
    		batchActivityWrap.priceBookId = (Id)batchActivitySObject.get('REN_Pricebook__c');
    		
    		Pricebook2 pricebook = REN_Util.getPricebookbyID(batchActivityWrap.priceBookId);
			if(pricebook != null){
				batchActivityWrap.priceBookName = pricebook.Name;
			}
    		
    		batchActivityWrap.renewableProducts = (String)batchActivitySObject.get('REN_Renewable_Products__c');
    		batchActivityWrap.schedulerId = (String)batchActivitySObject.get('REN_Scheduler_ID__c');
    		
    		batchActivityWrap.sourceRecordFilterId = (Id)batchActivitySObject.get('REN_Source_Record_Filter__c');
    		if(batchActivityWrap.sourceRecordFilterId != null){
	    		batchActivityWrap.sourceRecordFilterName = (String)batchActivitySObject.getSObject('REN_Source_Record_Filter__r').get('REN_View_Name__c');
	    		batchActivityWrap.sourceRecordFilterDesc = (String)batchActivitySObject.getSobject('REN_Source_Record_Filter__r').get('REN_Description__c');
	    		batchActivityWrap.sourceRecordFilterRecordKey = (String)batchActivitySObject.getSobject('REN_Source_Record_Filter__r').get('REN_Record_Key__c');
    		}
    		batchActivityWrap.status = (String)batchActivitySObject.get('REN_Status__c');
    		
    		batchActivityWrap.successPlanTemplateId = (Id)batchActivitySObject.get('REN_Plan_Template_Id__c');
    		if(batchActivityWrap.successPlanTemplateId != null){
    			batchActivityWrap.successPlanTemplateName = (String)batchActivitySObject.getSObject('REN_Plan_Template_Id__r').get('CSM_Template_Name__c');
    		}
    		//Sadly this cannot be assigned once FORMAT(field) is used in the Query. The currency symbol in the formatted values messes this up.
    		batchActivityWrap.totalGeneratedValue = (String)batchActivitySObject.get('REN_Total_Amount__c');
    	}
    	return batchActivityWrap;
    }
}