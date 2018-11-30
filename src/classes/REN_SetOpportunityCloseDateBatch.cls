global with sharing class REN_SetOpportunityCloseDateBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String batchActivityId ;
	REN_Batch_Activity__c batchActivity ;
	List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
	String errorDrtails = '';
	Integer errorCount;
	Boolean startFailed = false;
	
	public REN_SetOpportunityCloseDateBatch(REN_Batch_Activity__c batActivity,String errors,Boolean fail){
		errorDrtails = errors;
		batchActivity = batActivity;
		batchActivityId = (''+batchActivity.id).subString(0,15);
		startFailed = fail;
	}

	global Database.queryLocator start(Database.BatchableContext BC){
		String jobId = BC.getJobId();
		try{
			String query = 'Select id,closeDate FROM Opportunity WHERE REN_Batch_Activity_ID__c = :batchActivityId';
			CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OPPORTUNITY, new List<String>{'Id','CloseDate'}, CSM_Constants.DML_OPERATION_READ);
			return Database.getQueryLocator(query);
		}
		catch(Exception ex){
			batchActivity.REN_Status__c = REN_Constants.STATUS_PARTIAL_SUCCESS;
			REN_BatchActivityDataAccess.saveBatchAct(batchActivity);
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = null, REN_Batch_Activity__c = batchActivity.id, REN_Failure_Message__c = 'Failed to Update correct close date. ' + ex.getMessage()));
			REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
			errorDrtails +=  '<b>' + ++errorCount + '  : </b> - ' + ex.getMessage() + '<p/>'  + ex.getStackTraceString();
			REN_RenewBatchActivityHandler.sendEmailNotifications(batchActivity, errorDrtails);
			startFailed = true;
			//System.abortJob(jobId);
			return null;
		}
	}
	
	global void execute(Database.BatchableContext BC,List<Opportunity> oppList){
		//REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = false;
		//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = false;
		CSM_TriggerManager.disableAllTriggers();
		try{
			List<REN_Renews_To__c> renDelList = new List<REN_Renews_To__c>();
			Map<id,List<REN_Renews_To__c>> oppRenwalMap = new Map<id,List<REN_Renews_To__c>>();
			Map<id,Date> oliDateMap = new Map<id,Date>();
			Map<String,Integer> assetDateCountMap = new Map<String,Integer>();
			String assetDateField = batchActivity.REN_Closed_Date_Depends_On__c;
			Date closeDate;
			List<Opportunity> oppDelList = new List<Opportunity> ();
			REN_OpportunityCloseDateBatchHandler batHandler = new REN_OpportunityCloseDateBatchHandler();
			if(assetDateField != null){
				CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, new List<String>{'Id','REN_Renews_To__c','REN_Asset__c'}, CSM_Constants.DML_OPERATION_READ);
				String assetQuery = 'Select id,REN_Renews_To__c,REN_Asset__r.'+ assetDateField + ' FROM REN_Renews_To__c WHERE REN_Renews_To__c IN :oppList';
				List<REN_Renews_To__c> renewalList = Database.query(assetQuery);
				CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, new List<String>{'Id','TotalPrice'}, CSM_Constants.DML_OPERATION_READ);              
				Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>([Select id,TotalPrice,REN_Renewable_Line_Item__c from OpportunityLineItem WHERE OpportunityId IN :oppList]);
				Map<Id,Id> rliToOliId = new Map<Id,Id>();
				for(Id olid : oliMap.keyset()){
					rliToOliId.put(oliMap.get(olid).REN_Renewable_Line_Item__c,olid);
				}
				for(REN_Renews_To__c ren : renewalList){
					if(ren.getSobject('REN_Asset__r').get(assetDateField) != null){
						if(rliToOliId.get(ren.Id) != null){
							oliDateMap.put(rliToOliId.get(ren.Id),(Date)ren.getSobject('REN_Asset__r').get(assetDateField));
						}
					}
					if(oppRenwalMap.containsKey(ren.REN_Renews_To__c)){
						oppRenwalMap.get(ren.REN_Renews_To__c).add(ren);
					}
					else{
						oppRenwalMap.put(ren.REN_Renews_To__c,new List<REN_Renews_To__c>());
						oppRenwalMap.get(ren.REN_Renews_To__c).add(ren);
					}
				}
				Map<String,List<String>> assetDateMap = new Map<String,List<String>>();
				for(Opportunity opp : oppList){
					if(!assetDateMap.containsKey(opp.id)){
						assetDateMap.put(opp.id,new List<String>());	
					}
					if(opp != null && opp.Id != null && oppRenwalMap != null && oppRenwalMap.containsKey(opp.id)){
						for(REN_Renews_To__c renRelation : oppRenwalMap.get(opp.id)){
							if(renRelation.getSobject('REN_Asset__r').get(assetDateField) != null){
								assetDateMap.get(opp.id).add(''+renRelation.getSobject('REN_Asset__r').get(assetDateField));
							}	
						}
					}
					if(assetDateMap.containsKey(opp.id)){
						closeDate = batHandler.getCloseDate(assetDateMap.get(opp.id),oliMap,oliDateMap,batchActivity.REN_Closed_Date_Options__c);
						if(closeDate != null){
							opp.closeDate = closeDate;
						}
						else{
							oppDelList.add(opp);
							if(oppRenwalMap != null){
								renDelList =  oppRenwalMap.get(opp.id);
								if(renDelList != null){
									for(REN_Renews_To__c ren : renDelList){
										failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = ren.REN_Asset__c, 
																REN_Batch_Activity__c = batchActivity.id, REN_Failure_Message__c = assetDateField +': field mapped to Close Date is null'));
									}
								}
							}
						}
					}
				}
				//update oppList;
				List<Database.SaveResult> queryResultList = REN_OpportunityDataAccess.updateOpportunityReturnSaveResult(oppList);
				if(queryResultList != null){
					Database.Error error;
					for(Integer i=0;i<queryResultList.size();i++){
			            if (!queryResultList.get(i).isSuccess()){
			            	error = queryResultList.get(i).getErrors().get(0);
			                failureAssetList.add(new REN_Batch_Opportunity_Failure__c(
			                							REN_Opportunity__c = oppList[i].id, 
														REN_Batch_Activity__c = batchActivity.id, 
														REN_Failure_Message__c = error.getMessage()+':Failed to update correct close date'
													)
												);
			            }
			        }
				}
				if(oppDelList != null && !oppDelList.isEmpty()){
					REN_OpportunityDataAccess.deleteOpportunity(oppDelList);
					//delete oppDelList;
				}
				if(renDelList != null && !renDelList.isEmpty()){
					system.debug('renDelList:::'+renDelList);
					REN_RenewRelationshipDataAccess.deleteRenewalRelationship(renDelList);
					//delete renDelList;
				}
				if(failureAssetList != null && !failureAssetList.isEmpty())
					REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
			}
		}
		catch (exception ex){
			system.debug('Exception in execute of REN_SetOpportunityCloseDateBatch ~~'+ex.getmessage()+ex.getStackTraceString());
			failureAssetList.add(new REN_Batch_Opportunity_Failure__c(
			                			REN_Opportunity__c = null, 
										REN_Batch_Activity__c = batchActivity.id, 
										REN_Failure_Message__c = 'Iteration failed because '+ex.getmessage()+'<p/>'  + ex.getStackTraceString()
									)
								);
        }
        if(!oppList.isEmpty()){
			Set<ID> renewedOppIdSet = new Set<ID>();
			for(Opportunity opp: oppList){
				renewedOppIdSet.add(opp.id);
			}
			//Only need RLI calcualtion here as Oli Adds amount case not valid in this case.
			REN_RRSimplifiedTriggerHelper.rliAfterTriggerEvent(renewedOppIdSet);
		}
		
	}
	
	global void finish (Database.BatchableContext BC){
		try{
			//List<Opportunity> allCreatedOppList = [Select id, amount FROM Opportunity WHERE REN_Batch_Activity_ID__c = :batchActivityId];
			List<Opportunity> allCreatedOppList = REN_OpportunityDataAccess.getBatchOpptyRecords(batchActivityId);
			if(batchActivity.REN_Failure_Assets__c == null){
				batchActivity.REN_Failure_Assets__c = 0;
			}
			if(!failureAssetList.isEmpty()){
				batchActivity.REN_Failure_Assets__c += failureAssetList.size();
			}
			
			Decimal totalAmt = 0;
			batchActivity.REN_Generated_Records__c = allCreatedOppList.size();
    		if(batchActivity.REN_Generated_Records__c != 0){
	    		for(Opportunity o: allCreatedOppList){
	    			if(o.amount != null){
	    				totalAmt += o.amount;
	    			}
	    		}
	    	}
	    	system.debug('Exception in start method :::'+startFailed);
	    	if(batchActivity.REN_Failure_Assets__c > 0 && batchActivity.REN_Generated_Records__c >0 && !startFailed){
				batchActivity.REN_Status__c = REN_Constants.STATUS_PARTIAL_SUCCESS;
			}
			else if(batchActivity.REN_Failure_Assets__c > 0 && batchActivity.REN_Generated_Records__c == 0){
				batchActivity.REN_Status__c = REN_Constants.STATUS_FAILED;
			}
			else if(!startFailed){
				batchActivity.REN_Status__c = REN_Constants.STATUS_COMPLETED;
			}
    		batchActivity.REN_Total_Amount__c = totalAmt;
    		batchActivity.REN_Job_Completion_Date__c = System.now();
			REN_BatchActivityDataAccess.saveBatchAct(batchActivity);
			REN_RenewBatchActivityHandler.sendEmailNotifications(batchActivity, errorDrtails);	          
				           
		}
		catch (exception ex){
            system.debug('exception REN_SetOpportunityCloseDateBatch Finish $$ '  + ex.getStackTraceString());
            //System.abortJob(batchActivity.REN_Job_ID__c);
        }
	}
}