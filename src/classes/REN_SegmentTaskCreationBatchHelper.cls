/**
 * Created Date		: Apr 18, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
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
 * Chandra					User Story				Apr 18, 2017			1.1					@description
 *
*/
public with sharing class REN_SegmentTaskCreationBatchHelper {

	public void createTask(List<REN_Batch_Activity__c> batchActivityList, List<REN_Segment_Member__c> segmentList, REN_Task_Template__c taskTemplateObj){
		List<Task> taskList = new List<Task>();
		boolean isSegmentOwnerDefined = CSM_AccessController.hasField('Asset', 'OwnerId');
		Set<String> fieldsForCrudFlsCheck = new Set<String>{'REN_Segment_Member__c', 'Description', 'CSM_Completed_Date__c', 'Priority', 'Status', 'Subject', 'ActivityDate', 'OwnerId', 'WhatId', 'WhoId'};
		for(REN_Segment_Member__c segMember: segmentList){
			Task taskObj = new Task();
			taskList.add(taskObj);
			taskObj.REN_Segment_Member__c = segMember.id;
			taskObj.Description = taskTemplateObj.REN_Comments__c;
			taskObj.CSM_Completed_Date__c = taskTemplateObj.REN_Completed_Date__c;
			taskObj.Priority = taskTemplateObj.REN_Priority__c;
			taskObj.Status = taskTemplateObj.REN_Status__c;
			taskObj.Subject = taskTemplateObj.REN_Subject__c;
			taskObj.ActivityDate = taskTemplateObj.REN_Due_Date__c;
			
			if(segMember.REN_Opportunity__c != null){
				taskObj.WhatId = segMember.REN_Opportunity__c;	
				if(String.isNotBlank(taskTemplateObj.REN_Contact__c)){	
					if(taskTemplateObj.REN_Contact__c == REN_Constants.PRIMARY_CONTACT){
						taskObj.WhoId = segMember.REN_Segment_Primary_Contact__c;
					}else{
						taskObj.WhoId = (ID)segMember.REN_Opportunity__r.get(taskTemplateObj.REN_Contact__c);
					}
				}
				if(batchActivityList[0].REN_Designated_TaskOwner__c != null){
					taskObj.OwnerId = batchActivityList[0].REN_Designated_TaskOwner__c;
				}else if(String.isNotBlank(batchActivityList[0].REN_Owner_Field_Name__c)){	
					taskObj.OwnerId = (ID)segMember.REN_Opportunity__r.get(batchActivityList[0].REN_Owner_Field_Name__c);
				}
			}else if(segMember.REN_Asset__c != null){
				taskObj.WhatId = segMember.REN_Asset__c;
				taskObj.WhoId = String.isNotBlank(taskTemplateObj.REN_Contact__c) ? (ID)segMember.REN_Asset__r.get(taskTemplateObj.REN_Contact__c) : null;
				if(batchActivityList[0].REN_Designated_TaskOwner__c != null){
					taskObj.OwnerId = batchActivityList[0].REN_Designated_TaskOwner__c;
				}else if(String.isNotBlank(batchActivityList[0].REN_Owner_Field_Name__c)){	
					if(batchActivityList[0].REN_Owner_Field_Name__c == 'OwnerId'){
						taskObj.OwnerId = (ID)segMember.REN_Asset__r.Account.OwnerId;
					}else{					
						taskObj.OwnerId = (ID)segMember.REN_Asset__r.get(batchActivityList[0].REN_Owner_Field_Name__c);
					}
				}
			}

			if(CSM_AccessController.hasField('Task', 'RecordTypeId')){
				taskObj.put('RecordTypeId', taskTemplateObj.REN_Record_Type__c);
				fieldsForCrudFlsCheck.add('RecordTypeId');
			}
			if(CSM_AccessController.hasField('Task', 'Type')){
				fieldsForCrudFlsCheck.add('Type');
				taskObj.put('Type', taskTemplateObj.REN_Type__c);
			}
			if(CSM_AccessController.hasField('Task', CSM_Util.nameSpacePrefixSolnExtn + 'BCC__c')){
				fieldsForCrudFlsCheck.add(CSM_Util.nameSpacePrefixSolnExtn + 'BCC__c');
				taskObj.put(CSM_Util.nameSpacePrefixSolnExtn + 'BCC__c', taskTemplateObj.REN_BCC__c);
			}
			if(CSM_AccessController.hasField('Task', CSM_Util.nameSpacePrefixSolnExtn + 'CC__c')){
				fieldsForCrudFlsCheck.add(CSM_Util.nameSpacePrefixSolnExtn + 'CC__c');
				taskObj.put(CSM_Util.nameSpacePrefixSolnExtn + 'CC__c', taskTemplateObj.REN_CC__c);
			}
			if(CSM_AccessController.hasField('Task', CSM_Util.nameSpacePrefixSolnExtn + 'ClosedDate__c')){
				fieldsForCrudFlsCheck.add(CSM_Util.nameSpacePrefixSolnExtn + 'ClosedDate__c');
				taskObj.put(CSM_Util.nameSpacePrefixSolnExtn + 'ClosedDate__c', taskTemplateObj.REN_ClosedDate__c);
			}
			if(CSM_AccessController.hasField('Task', CSM_Util.nameSpacePrefixSolnExtn + 'Direction__c')){
				fieldsForCrudFlsCheck.add(CSM_Util.nameSpacePrefixSolnExtn + 'Direction__c');
				taskObj.put(CSM_Util.nameSpacePrefixSolnExtn + 'Direction__c', taskTemplateObj.REN_Direction__c);
			}
		}
		Database.SaveResult[] srList = CSM_TaskDataAccess.createTask(taskList, fieldsForCrudFlsCheck);
		createBatchActivityDetails(batchActivityList, segmentList, srList);
	}

	
	private void createBatchActivityDetails(List<REN_Batch_Activity__c> batchActivityList, List<REN_Segment_Member__c> segmentList, Database.SaveResult[] srList){
		List<REN_Batch_Opportunity_Failure__c> batchActivityDetailList = new List<REN_Batch_Opportunity_Failure__c>();
		Integer iCount = 0;
		
        for (Database.SaveResult sr : srList) {
        	REN_Segment_Member__c segmentMember = segmentList[iCount];
        	REN_Batch_Opportunity_Failure__c batchActivityDetailObj = new REN_Batch_Opportunity_Failure__c(REN_Batch_Activity__c = batchActivityList[0].id);
			batchActivityDetailObj.REN_Segment_Member__c = segmentMember.id;
			batchActivityDetailObj.REN_Opportunity__c = segmentMember.REN_Opportunity__c;
			batchActivityDetailObj.REN_Asset__c = segmentMember.REN_Asset__c;			
            if (sr.isSuccess()) {
            	batchActivityDetailObj.REN_Segment_Task_ID__c = sr.id;
            }else{
                String msg = '';                    
                for(Database.Error err : sr.getErrors()) {
                    msg += err.getStatusCode() + ': ' + err.getMessage();
                    msg += ' \n' + err.getFields();
                }
                batchActivityDetailObj.REN_Failure_Message__c = msg;
            }
            batchActivityDetailList.add(batchActivityDetailObj);
            iCount++;
        }
        if(!batchActivityDetailList.isEmpty()){
        	REN_BatchOppFailureDataAccess.insertBatchFailure(batchActivityDetailList);
        }

	}

	public static void sendEmailNotifications(List<REN_Batch_Activity__c> batchActivityObjList, String messageDrtails){//bulkified this method
		System.debug(batchActivityObjList[0].REN_Segment__r.Name + '\neMail~~~~batchActivityObj: ' + batchActivityObjList);
		String subjectText = String.format(Label.REN_LBL_SEG_TASK_BATCH_EMAIL_SUBJECT, new String[]{batchActivityObjList[0].REN_Status__c, batchActivityObjList[0].REN_Segment__r.Name});
		String emailBody = String.format(Label.REN_LBL_Dear_Name, new String[]{'User'});
		
		emailBody  += '<br/><br/>' + String.format(Label.REN_LBL_SEG_TASK_BATCH_EMAIL_MESSAGE, new String[]{
			batchActivityObjList[0].REN_Segment__r.Name, 
			batchActivityObjList[0].REN_Status__c,
			'<br/>' + URL.getSalesforceBaseUrl().toExternalForm() + (Page.ren_batchtaskgensummary.getURL()) + '?type=success&id=' + batchActivityObjList[0].id,
			String.isNotBlank(messageDrtails) ? ('<br/><br/>' + Label.REN_LBL_ERROR + ':  ' + messageDrtails) : ''
		});

		String templateName = 'Segment_Task_Creation_Batch';
		ID templateID = REN_Util.getEmailTemplateId(templateName);
       	if(templateID == null && batchActivityObjList[0].REN_Email_Notification__c){        		
        	REN_Util.sendEmailNotification(REN_RenewBatchActivityHandler.getEmailRecipients(batchActivityObjList), subjectText, emailBody);
        }else if(batchActivityObjList[0].REN_Email_Notification__c){
        	REN_Util.sendEmailNotificationUsingTemplate(REN_RenewBatchActivityHandler.getEmailRecipients(batchActivityObjList), templateID + '', batchActivityObjList[0].id);
        }
		
       	
 	} 
}