/**
* @description    CHL_PartnerOpportunityGridUpdate class gets call from Opportunity tab when users performs Bulk update on list of partner Opportunities.
*/
public with sharing class CHL_PartnerOpportunityGridUpdate{    
   
    public static boolean isSuccess = false;
    public static boolean isError = false;
    public static string errorMsg ='';  
    private static String nameSpacePrefix;
    private static boolean is2TierPricingEnable = false;
    
    /**
      * @description : This method gets called from CHL_CommunityLandingController class,when users performs Bulk update on list of partner Opportunities from opportunity tab. 
                       this method returns the updated partner opoortunity list to show on Opportunities Tab
      * @param :Accepts list of opportunities that needs to update, as JSON String
    */
    public static CHL_AngularResponeWrapper updatePartnerOpportunity(CHL_AngularResponeWrapper inputData) {
    	Savepoint sp = Database.setSavepoint();
    	CHL_AngularResponeWrapper optyResultWrap;
    	try {
	    	nameSpacePrefix = CSM_Util.getNamespace();
	        CHL_AngularResponeWrapper wrp = inputData;
	        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = wrp.gridData;
	        List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
	        List<CHL_Partner_Opportunity__c> partnerOpptyToUpdate = new List<CHL_Partner_Opportunity__c>();
	        Map<Id,CHL_Partner_Opportunity__c> poIdToPoObjMap = new Map<Id,CHL_Partner_Opportunity__c>();
	        Map<Id,Integer> recIndex = new Map<Id,Integer>();
	        List<Task> statusTask=new List<Task>();
	        String repIdOne = '',repIdTwo = '',selectedQuoteId = '',accType1 = '', accType2 = '', saleStage = '';
	        String gmtDateTime = '';
	        Map<string,String> partnerOptyToQuote = new Map<string,String>();
	        
		    //Below Code Added for US1024        
		    Set<String> availableStages = CHL_Util.getAvailableSalesStage(); 
		    system.debug('availableStages : '+availableStages);
		    //Added for US1194       
	        if(opptyStatusLogList != null && !opptyStatusLogList.isEmpty()){
	        	is2TierPricingEnable = opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
	        }
		        //Added for DE868
	        for(CHL_AngularResponeWrapper.CHL_GridData griddatawrp:recordList) {
	            if(!String.isBlank(griddatawrp.recordId)){
	                //pOppIdSet.add(griddatawrp.recordId);
	            }
	        }
	        CHL_Partner_Opportunity__c sObj;
	        
	        for(CHL_AngularResponeWrapper.CHL_GridData griddatawrp:recordList) {	        	
	            sObj = new CHL_Partner_Opportunity__c();
	            sObj.Id = griddatawrp.recordId;
	            //Updated below code for DE1170
	            repIdOne = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Partner_Account_1_Contact__c').lookUpId:'';
	            repIdTwo = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Partner_Account_2_Contact__c').lookUpId:'';
	            accType1 = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Partner_Account_1_Type__c').value:'';
	            accType2 = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Partner_Account_2_Type__c').value:'';
	            saleStage = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Sales_Stage__c').lookUpId:'';
	            // Added if condition for US1194
	            if(!is2TierPricingEnable) {
	            	selectedQuoteId = griddatawrp.rowData<>null?griddatawrp.rowData.get(CHL_Constants.GRID_COLUMN_QUOTE_PDF).lookUpId:'';
	            	partnerOptyToQuote.put(sObj.Id,selectedQuoteId);
	            }
	            String partnerAccount1Id = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Partner_Account_1__c').value:'';
	            String partnerAccount2Id = griddatawrp.rowData<>null?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Partner_Account_2__c').value:'';            
	            if(!wrp.noChange)	{              
	                system.debug('TYPE 1: '+accType1+'accType2 '+accType2+'::'+repIdOne+'::'+repIdTwo);
	                //Updated below code for DE1170
	                if(accType1 == 'Reseller') {
	                    sObj.CHL_Partner_Account_1_Contact__c = (repIdOne <>'' && repIdOne <> '0' ?repIdOne:null);
	                } else if(accType2 == 'Reseller'){
	                    sObj.CHL_Partner_Account_2_Contact__c = (repIdOne <>'' && repIdOne <> '0' ?repIdOne:null);
	                }
	                if(accType1 == 'Distributor') {
	                    sObj.CHL_Partner_Account_1_Contact__c = (repIdTwo <>'' && repIdTwo <> '0' ?repIdTwo:null);
	                } else if(accType2 == 'Distributor'){
	                    sObj.CHL_Partner_Account_2_Contact__c = (repIdTwo <>'' && repIdTwo <> '0' ?repIdTwo:null);
	                }
	                sObj.CHL_Probability__c = (griddatawrp.rowData.get(nameSpacePrefix+'CHL_Probability__c').value<>''?Decimal.valueOf(griddatawrp.rowData.get(nameSpacePrefix+'CHL_Probability__c').value):null);
	                gmtDateTime = (griddatawrp.rowData.get(nameSpacePrefix+'CHL_Close_Date__c').value<>''?griddatawrp.rowData.get(nameSpacePrefix+'CHL_Close_Date__c').value:'');
	                if(gmtDateTime.contains('T')) {
	                	sObj.CHL_Close_Date__c = gmtDateTime<>''?CHL_Util.getDateFromGMT(gmtDateTime):null;
	                }
	                sObj.CHL_Sales_Stage__c = griddatawrp.rowData.get(nameSpacePrefix+'CHL_Sales_Stage__c').lookUpId;
	                sObj.CHL_Customer_Engagement_Type__c = griddatawrp.rowData.get(nameSpacePrefix+'CHL_Customer_Engagement_Type__c').lookUpId;              
	            }
	           
	            sObj.CHL_Status__c = griddatawrp.rowData.get(nameSpacePrefix+'CHL_Status__c').value;
	            sObj.CHL_Syncing__c = griddatawrp.rowData.get(nameSpacePrefix+'CHL_Syncing__c').value;	           
	            
	            //Below condition Added for US1024   
	           	if(!opptyStatusLogList.isEmpty() && opptyStatusLogList[0].CHL_Show_Oppty_for_Unavailable_Stage__c == true && !availableStages.contains(saleStage)) {
	        		isError = true;
	        		errorMsg = Label.CHL_ERR_UNAVAILABLE_STAGE_UPDATE;
	        	} else if(availableStages.contains(saleStage)) {
	        		//Updated for DE868 & DE914
		            //Added for US3116
		            Id oppId=griddatawrp.rowData.get(nameSpacePrefix+'CHL_Opportunity__c').value;
		            if(sObj.CHL_Status__c != null && sObj.CHL_Status__c != '') {
		            	Task taskObj = new Task(CSM_Related_Opportunity__c = oppId, Status ='Completed', Subject = 'Status Update', Type = 'Status Update', 
		            							CHL_Status_Update__c = true, WhatId = sObj.Id, CHL_Related_Partner_Opportunity__c = sObj.Id, Description = sObj.CHL_Status__c, 
		            							ActivityDate = date.today());
		                statusTask.add(taskObj);
		                sobj.CHL_Needs_Status_Update__c = false;
		                sobj.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
		            }
		            if(wrp.noChange){
		              sobj.CHL_Needs_Status_Update__c = false;
		              sobj.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
		            }
		            partnerOpptyToUpdate.add(sObj);   
		            poIdToPoObjMap.put(sObj.Id,sObj);
	        	}	        	
	            recIndex.put(griddatawrp.recordId,griddatawrp.index);      
	        	
	        } 	        
	        system.debug('rrrr'+partnerOpptyToUpdate + ' :: '+partnerOpptyToUpdate.size()+ ' :: '+saleStage +'\n errorMsg'+errorMsg);
	        
	        //Below code is Added for US754: to update PARTNER PRIMARY checkbox for the selected quote
	        Boolean isQuoteEnabled = CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE);       
	        //String errorMessage = '';    
	        if(!isError && isQuoteEnabled && selectedQuoteId != null && selectedQuoteId != '' && partnerOptyToQuote != null && !partnerOptyToQuote.isEmpty())  {  
	            setQuoteAsPrimary(poIdToPoObjMap,partnerOptyToQuote);
	        }  
	        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_UPDATE); 
	        List<Database.SaveResult> partnerOptyUpdateList  = Database.update(partnerOpptyToUpdate, false);
	        system.debug('partnerOptyUpdateList :: '+partnerOptyUpdateList);
	        if(partnerOptyUpdateList != null && !partnerOptyUpdateList.isEmpty() && partnerOptyUpdateList[0].isSuccess()) {
				CSM_Constants.TASK_TRIGGER = false;
		        List<Database.SaveResult> taskResultList  = Database.insert(statusTask, false);
	        	system.debug('rrrr resultList'+taskResultList );
	        }
	        
		    List<CHL_Partner_Opportunity__c> partnerOptyLst = CHL_PartnerOpportunityDataAccess.getPartnerOppDetailForOptyGrid(poIdToPoObjMap.keySet()); //US1490
		    CHL_PartnerOpportunityBusinessLayer.nameSpacePrefix = nameSpacePrefix;
		    List<CHL_AngularResponeWrapper.CHL_GridData> updatedrecordList = CHL_PartnerOpportunityBusinessLayer.getRecordDetailsList(partnerOptyLst);
		    
	        optyResultWrap = getUpdatedResult(partnerOptyUpdateList,updatedrecordList,recIndex); 
	      	
    	} catch(Exception ex) {
    		Database.rollback(sp);
    	}
    	return optyResultWrap;
    }
    
    /** Method to update Partner Primary flag on selected Quote and also to update amount based on selected Quote. 
    *	Below function gets call whenever user selects quote from Latest_Quote column in the opportunity grid
    **/
    @TestVisible
    private static void setQuoteAsPrimary(Map<Id,CHL_Partner_Opportunity__c> poIdToPoObjMap, Map<string,String> partnerOptyIdToQuote)   { //, Set<String> resellerPOList, Set<String> distributorPoID
        CSM_TriggerManager.disableAllTriggers();
        List<sObject> quoteListToUpdate = new List<sObject>();
        List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
    	Map<Id,Decimal> partnerOptyIdToAmount = new Map<Id,Decimal>();
        List<sObject> quoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIdToPoObjMap.keySet(), false);
        string quoteId = '';
        string partnerOptyId = '';
        Set<Id> quoteIdSet = new Set<Id>();
        if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
            for(sObject sObjQuote: quoteList) {
                quoteId = (String)sObjQuote.get('Id');
                quoteIdSet.add((String)sObjQuote.get('Id'));
                partnerOptyId =  (String)sObjQuote.get(CHL_Util.quoteExtnNameSpace+CHL_CONSTANTS.OBJ_PT_OPPORTUNITY); 
                if(quoteId == partnerOptyIdToQuote.get(partnerOptyId)) {
                	//sObjQuote.put(CHL_Util.quoteExtnNameSpace+CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY,true);
                	quoteListToUpdate.add(sObjQuote);  
                	if (String.isNotBlank(poIdToPoObjMap.get(partnerOptyId).CHL_Syncing__c) && poIdToPoObjMap.get(partnerOptyId).CHL_Syncing__c.contains(CHL_Constants.SYNCING_OPTION_TO_MO)) {
						partnerOptyList.add(poIdToPoObjMap.get(partnerOptyId));
					}
                }         
            }
        }
        
       
        if(quoteListToUpdate != null && !quoteListToUpdate.isEmpty()){  
        	CHL_QuoteSyncHandler.handleQuotePrimary(quoteListToUpdate, poIdToPoObjMap.keySet()); 
        	CHL_QuoteExtension.handlePOUpdationFromQuote(poIdToPoObjMap.keySet());        	   	        	
        	if(partnerOptyList != null && !partnerOptyList.isEmpty()){
        		List<sObject> parnetOpptyQuoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIdToPoObjMap.keySet(), false);
	        	Set<Id> quoteIds = new Set<Id>();
	        	for(SObject poquoteObj : parnetOpptyQuoteList){
	        		if((boolean)poquoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == true) {
	        			quoteIds.add(poquoteObj.Id);
	        		}
	        	}
	            CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
				CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
				CHL_QuoteSyncHandler.isExecutionNeeded =false;
				CHL_QuoteExtension.syncQuoteFromOpportunity(quoteIds);
				//ID jobID = System.enqueueJob(new CHL_QuoteSyncQueueableJob(partnerOptyList));
            }
        }
    }
    
    
    
    
    private static CHL_AngularResponeWrapper getUpdatedResult(List<Database.SaveResult> resultList, List<CHL_AngularResponeWrapper.CHL_GridData> updatedrecordList,Map<Id,Integer> recordIndexMap) {
    	CHL_AngularResponeWrapper optyWrap = new CHL_AngularResponeWrapper();
	    List<CHL_AngularResponeWrapper.CHL_GridData> newUpdatedRecordList = new List<CHL_AngularResponeWrapper.CHL_GridData>();	    
        set<Id> updatedRecordIds = new set<Id>();
        Set<String> errorContactFields = new Set<String>();
        Set<String> errorFields = new Set<String>();
        string exceptionMsg = '';
        Map<String, String> fieldLabelDisplay = new Map<String, String>{nameSpacePrefix + CHL_Constants.OBJ_PO_SALES_STAGE => Label.CHL_LBL_MONITOR_FIELD_SALES_STAGE, 
	            nameSpacePrefix + CHL_Constants.OBJ_PO_PROBABILITY => Label.CHL_LBL_MONITOR_FIELD_PROBABILITY,
	            nameSpacePrefix + CHL_Constants.OBJ_PO_CLOSE_DATE => Label.CHL_LBL_MONITOR_FIELD_CLOSE_DATE,
	            nameSpacePrefix + CHL_Constants.OBJ_PO_RESELLER_REP => Label.CHL_LBL_RESELLER_REP,
	            nameSpacePrefix + CHL_Constants.OBJ_PO_DISTRIBUTOR_REP => Label.CHL_LBL_DISTRIBUTOR_REP};
	    
    	for (Database.SaveResult sr : resultList) {
            if (sr.isSuccess()) {
                isSuccess = true;
                updatedRecordIds.add(sr.getId());
            }
            else {
                isError = true;
               for(Database.Error err:sr.getErrors()){
               	  if((err.getMessage()).equalsIgnorecase(Label.CHL_ERR_UNAVAILABLE_STAGE_UPDATE)) {
               	  	errorMsg = Label.CHL_ERR_UNAVAILABLE_STAGE_UPDATE;
               	  	break;
               	  } 
               	  exceptionMsg = err.getMessage();		
                  errorFields.addAll(err.getFields());
               }  
            }
        }
	    if(isSuccess == true && isError == true) {
	        optyWrap.status = 'PARTIAL_SUCCESS';
	    } else if(isSuccess == false && isError == true) {
	        optyWrap.status = 'ERROR';
	    } else {
	        optyWrap.status = 'SUCCESS';
	    } 
	    integer count = 0;
    	for(CHL_AngularResponeWrapper.CHL_GridData griddatawrp:updatedrecordList) {
	        if(updatedRecordIds.contains(griddatawrp.recordId)) {
	            griddatawrp.updated = true;
	        } else {
	            griddatawrp.updated = false;
	        }
	        if(recordIndexMap != null) {
	        	griddatawrp.index = recordIndexMap.get(griddatawrp.recordId);
	        } else {
	        	griddatawrp.index = count;
	        	count = count + 1;
	        	griddatawrp.updated = true; //grid was not refreshing after code is moved to trigger.
	        }	        
	        newUpdatedRecordList.add(griddatawrp);
	    }
	    system.debug('newUpdatedRecordList : '+newUpdatedRecordList);
	    optyWrap.gridData = newUpdatedRecordList;
	    
	    if(isError){
	    	Set<String> errorFieldLabels = new Set<String>();
	    	String fldLabel = '';
	    	for(String errFld:errorFields){            
	          	if(fieldLabelDisplay.containsKey(errFld))
	             	fldLabel = fieldLabelDisplay.get(errFld);
	           	else
	            	fldLabel = errFld;
	          
	          	errorFieldLabels.add(fldLabel);          
	    		if(fldLabel == Label.CHL_LBL_RESELLER_REP || fldLabel == Label.CHL_LBL_DISTRIBUTOR_REP)  
	        		errorContactFields.add(fldLabel);
			}          
			if(errorContactFields.size()>0)  
	 			optyWrap.errorMessage = errorContactFields +' '+ Label.CHL_ERR_CONTACT;
			else if(!string.isblank(errorMsg) || errorMsg != '') {
				optyWrap.errorMessage = errorMsg;
			} else if(errorFieldLabels == null || errorFieldLabels.isEmpty()) {
				optyWrap.errorMessage =  exceptionMsg;
			} else {
	  			optyWrap.errorMessage =  errorFieldLabels +' '+ Label.CHL_ERR_UPDATE; 
			}
	   	} 
	   	return optyWrap;
    }
    
    /*
    @ Description: Below method gets called from Quote sub tab, whenever user updates primary flag on quote
    */
    public static CHL_AngularResponeWrapper updateQuotes(CHL_AngularResponeWrapper inputData) {
    	CHL_AngularResponeWrapper wrp = inputData;
    	Savepoint sp = Database.setSavepoint();
    	try {
	    	CSM_TriggerManager.disableAllTriggers();
	        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = wrp.gridData;
	        sObject sObjQuote;
	        string isPrimary = '';
	        String partnerOptyId = recordList[0].rowData<>null? recordList[0].rowData.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c').value:'';
	        List<sObject> quoteListToUpdatePrimary = new List<sObject>();
	        List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
	        Map<Id,CHL_Partner_Opportunity__c> partnerOpptyMap = new Map<Id,CHL_Partner_Opportunity__c>(CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(new Set<Id>{partnerOptyId}));
	        Set<Id> quoteIdSet = new Set<Id>();
	        Set<String> availableStages = CHL_Util.getAvailableSalesStage(); 	      
	        String saleStage;  
	        for(CHL_AngularResponeWrapper.CHL_GridData griddatawrp:recordList) {
	        	saleStage = partnerOpptyMap.containsKey(partnerOptyId) && String.isNotBlank(partnerOpptyMap.get(partnerOptyId).CHL_Sales_Stage__c) ? partnerOpptyMap.get(partnerOptyId).CHL_Sales_Stage__c : '';
	        	if(!CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty() && CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Show_Oppty_for_Unavailable_Stage__c == true && !availableStages.contains(saleStage)) {
	        		isError = true;
	        		errorMsg = Label.CHL_ERR_UNAVAILABLE_STAGE_UPDATE;
	        	} else if(availableStages.contains(saleStage)) {
		        	sObjQuote = Schema.getGlobalDescribe().get(CHL_CONSTANTS.OBJ_QUOTE).newSObject();
		        	sObjQuote.Id = griddatawrp.recordId;
		        	isPrimary = griddatawrp.rowData<>null?griddatawrp.rowData.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c').value:'';
		        	if(boolean.valueof(isPrimary) == true) {
		        		quoteIdSet.add(griddatawrp.recordId);
			        	//sObjQuote.put(CHL_Util.quoteExtnNameSpace+CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY,Boolean.valueOf(isPrimary));
			        	quoteListToUpdatePrimary.add(sObjQuote);		        	
			        	if(partnerOpptyMap.containsKey(partnerOptyId) && String.isNotBlank(partnerOpptyMap.get(partnerOptyId).CHL_Syncing__c) && partnerOpptyMap.get(partnerOptyId).CHL_Syncing__c.contains(CHL_Constants.SYNCING_OPTION_TO_MO)){
			        		partnerOptyList.add(partnerOpptyMap.get(partnerOptyId));
			        	} 
		        	}  
	        	}         
	            
	        }
	  		if(isError) {
		    	wrp.errorMessage = errorMsg;
		    	wrp.status = 'ERROR';
		    	//throw new unavailableStageException(wrp.errorMessage);
		    	return wrp;
		    }
	  		else if(quoteListToUpdatePrimary != null && !quoteListToUpdatePrimary.isEmpty()){
	  			quoteListToUpdatePrimary = CHL_QuoteDataAccess.getSyncedQuotesById(quoteIdSet);
	  			system.debug('quoteListToUpdatePrimary :: '+quoteListToUpdatePrimary);  
	  			CHL_QuoteSyncHandler.handleQuotePrimary(quoteListToUpdatePrimary, partnerOpptyMap.keySet());  
	  			CHL_QuoteExtension.handlePOUpdationFromQuote(partnerOpptyMap.keySet());       		
		  		if(partnerOptyList != null && !partnerOptyList.isEmpty()){
		  			List<sObject> parnetOpptyQuoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(partnerOpptyMap.keySet(), false);
	        		Set<Id> quoteIds = new Set<Id>();
	        		for(SObject poquoteObj : parnetOpptyQuoteList){
	        			if((boolean)poquoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == true) {
	        				quoteIds.add(poquoteObj.Id);
	        			}
	        		}
		            CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
					CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
					CHL_QuoteSyncHandler.isExecutionNeeded = false;
					CHL_QuoteExtension.syncQuoteFromOpportunity(quoteIds);
					//ID jobID = System.enqueueJob(new CHL_QuoteSyncQueueableJob(partnerOptyList));
		    	}
		    	List<sObject> quoteList = CHL_QuoteDataAccess.getQuotesListFromFieldSet(partnerOpptyMap.keySet(), CHL_Util.quoteExtnNameSpace + CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME);
		        List<CHL_AngularResponeWrapper.CHL_GridData> updatedrecordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(quoteList, CHL_Util.quoteExtnNameSpace + CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_QUOTE);
			    wrp.status = 'SUCCESS';
			    integer count = 0;
	    		List<CHL_AngularResponeWrapper.CHL_GridData> newUpdatedRecordList = new List<CHL_AngularResponeWrapper.CHL_GridData>();	 
		    	for(CHL_AngularResponeWrapper.CHL_GridData griddatawrp:updatedrecordList) {
			        griddatawrp.updated = true;
			        griddatawrp.index = count;
		        	count = count + 1;	        
			        newUpdatedRecordList.add(griddatawrp);
			    }
			    wrp.gridData = newUpdatedRecordList;
	  		}
	    	 
    	} catch (Exception ex) {
    		wrp = inputData;
    		wrp.errorMessage = ex.getMessage();
	    	wrp.status = 'ERROR';
    		Database.rollback(sp);
    		return wrp;
    	}
    	return wrp;
    }
    
    public with sharing class unavailableStageException extends Exception {}  
        
    
}