/**
 * Created Date     : May 26, 2017
 * Developed By     : Sanket, Comity Designs, Inc.
 *
 * Function         : Validated record type from custom setting for task object.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Sanket                   US2410                  May 26, 2017    1.1                 
 *
 */

public with sharing class CSM_CreateFollowUpCSMTaskCtrl {
	
	public Task taskDetail {get; set;}
	public List<CSM_SuccessPlan_Play__c> successPlanPlay {get;set;}
	
    public CSM_CreateFollowUpCSMTaskCtrl(ApexPages.StandardController controller) {
    	taskDetail = (Task )controller.getRecord();
    	successPlanPlay = new List<CSM_SuccessPlan_Play__c>();
    	if(taskDetail.get('CSM_SuccessPlan_Play__c') != null && String.isNotBlank((String)taskDetail.get('CSM_SuccessPlan_Play__c'))) {
    		successPlanPlay = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayById((Id)taskDetail.get('CSM_SuccessPlan_Play__c'));
    	}
        system.debug('successPlanPlay::'+successPlanPlay);
    }   
     
    public PageReference getRedirect() {
    	String sppl = '';
        Boolean isRecordType = CSM_Util.getRecordTypeExists(new Task()); 
        if(successPlanPlay != null && !successPlanPlay.isEmpty()) {
        	sppl = (String)successPlanPlay[0].get('name');
        }
        //Fetching custom setting values
        CSM_Admin__c  cmsAdmin = CSM_Admin__c.getOrgDefaults();
        pageReference pageRef;
                            
	        // To check 'CSM_Inherit_Task_Record_Type__c' custom setting field value, if it is true then redirect below set URL
	        if(isRecordType && cmsAdmin.CSM_Inherit_Task_Record_Type__c == true){
            	
            	pageRef = new PageReference('/00T/e?retURL=%2F'+taskDetail.get('id')+'&RecordType='+ taskDetail.get('RecordTypeId') + '&what_id=' + taskDetail.get('WhatId') + '&tsk5=Follow up to ' + taskDetail.get('Subject') + '&' + cmsAdmin.CSM_SPPL_Default_ID__c + '=' + sppl);
         	
         	}else if (isRecordType){
            	
            	pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Task&retURL=%2F'+taskDetail.get('id')+'&save_new_url=/00T/e?retURL=/'+taskDetail.get('id')+'&what_id='+ taskDetail.get('WhatId') +'&tsk5=Follow up to ' + taskDetail.get('Subject') +'&'+ cmsAdmin.CSM_SPPL_Default_ID__c +'='+ sppl);
           	
           	}else {
            	
            	pageRef = new PageReference('/00T/e?retURL=%2F'+taskDetail.get('id')+'&what_id='+ taskDetail.get('WhatId') +'&tsk5=Follow up to '+ taskDetail.get('Subject') +'&amp'+ cmsAdmin.CSM_SPPL_Default_ID__c + '=' + sppl);
         	}
        		return pageRef.setRedirect(true);
    }
}