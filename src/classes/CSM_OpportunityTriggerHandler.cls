/**
 * @author    	Mike Faust (mike@comitydesigns.com)    
 * @date         8/28/2014
 * @description  CSM_AccountTriggerHandler trigger handler for CSM_AccountTrigger
 */

public with sharing class CSM_OpportunityTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 									Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	{	 		
		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
		Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
		Boolean isChannelCommunityUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity);
		Boolean isDataServiceUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
		String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
		Boolean hasCommitLevelField = CSM_AccessController.hasField('Opportunity', solExtNameSpace+'Commit_Level__c');
		Boolean hasFirstQuoteCompletedField = CSM_AccessController.hasField('Opportunity', solExtNameSpace+'First_Quote_Completed_Date__c');
		Boolean hasSyncedQuoteField = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');
		Set<Id> accountIdSet = new Set<Id>();
		Set<String> syncedQuoteIdSet = new Set<String>();
		List<Opportunity> syncedOpportunityList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
		Decimal qliThreshold = CSM_Admin__c.getOrgDefaults().CHL_QliCount__c;
		Set<String> syncedOppIdSet = new Set<String>();
	        
		SS_TriggerCollectionParameters.OpportunityTriggerParams opptyParams = new SS_TriggerCollectionParameters.OpportunityTriggerParams();
		opptyParams.newRecordsMap = (Map<Id, Opportunity>)newRecordsMap;
		opptyParams.oldRecordsMap = (Map<Id, Opportunity>)oldRecordsMap;
		opptyParams.filteredOpportunityMap = new Map<Id, Opportunity>();
		opptyParams.filteredOpportunityList = new List<Opportunity>();
		opptyParams.qualifiedOpportunityList = new List<Opportunity>();
		opptyParams.qualifiedOpportunityMap = new Map<Id, Opportunity>();
		opptyParams.qualifiedIdSet = new Set<String>();
		 	
		for(Opportunity opptyObj : (List<Opportunity>)newRecords)	{
			Opportunity oldOpptyObj =  ((Map<Id, Opportunity>)oldRecordsMap).get(opptyObj.Id);
		 	if(opptyObj.accountId != null)	{
		 		accountIdSet.add(opptyObj.accountId);
		 	}
		 	if(opptyObj.StageName != null && String.isNotBlank(opptyObj.StageName) && opptyObj.StageName != oldOpptyObj.StageName){
	 			opptyParams.filteredOpportunityMap.put(opptyObj.Id, opptyObj);
	 			opptyParams.filteredOpportunityList.add(opptyObj);
	 			if(opptyObj.StageName == 'Closed Sale' || opptyObj.StageName == 'No Service' || opptyObj.StageName == 'House Account') {
	 				opptyParams.qualifiedIdSet.add(opptyObj.Id);
	 			}
	 		}
	 		if(hasSyncedQuoteField){
	 			if(opptyObj.get('Syncedquoteid') != null) {
		 			syncedQuoteIdSet.add((String)opptyObj.get('SyncedQuoteId'));
	 				syncedOpportunityList.add(opptyObj);
		 			if(oldOpptyObj.get('SyncedQuoteId') != opptyObj.get('SyncedQuoteId') ) {
		 				opptyParams.qualifiedOpportunityList.add(opptyObj);
		 				syncedOppIdSet.add((String)opptyObj.Id);
		 			}
		 			if(!isChannelCommunityUser && ((hasCommitLevelField && 
		 				oldOpptyObj.get(solExtNameSpace+'Commit_Level__c') != opptyObj.get(solExtNameSpace+'Commit_Level__c')) 
		 				|| (hasFirstQuoteCompletedField && 
		 					oldOpptyObj.get(solExtNameSpace+'First_Quote_Completed_Date__c') != opptyObj.get(solExtNameSpace+'First_Quote_Completed_Date__c')))) {
		 				opptyParams.qualifiedOpportunityMap.put(opptyObj.Id, opptyObj);
		 			}
		 		}
		 	}
		 }	 	
					 	
	 	if(!isChannelCommunityUser && hasRenewAccess && isRenewalEnabled() && !opptyParams.filteredOpportunityList.isEmpty() && opptyParams.filteredOpportunityList != null) {	 		
 			REN_OpportunityResolutionTriggerHandler.handleOpportunityResolution(opptyParams.filteredOpportunityList);
	 	}		 	
	 	if(hasChannelAccess) {
	 		partnerOptyList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunityId(opptyParams.newRecordsMap.keySet());
	 		
	 		if(partnerOptyList != null && !partnerOptyList.isEmpty()) {
	 			CHL_PartnerOppTriggerHelper.copyPOFieldsFromMasterOppty(opptyParams.newRecordsMap, partnerOptyList); //method added for US897 : If syncing option is FRom Master Opportunity
	 		
				if (opptyParams.filteredOpportunityMap != null && !opptyParams.filteredOpportunityMap.isEmpty()) {
			 		CHL_PartnerOpportunityStageHelper.syncSalesStageOnPartnerOpportunity(opptyParams.filteredOpportunityMap, partnerOptyList, syncedQuoteIdSet);
				}
	 		}
	 	}
	 	if(hasCSMAccess && Schema.sObjectType.CSM_Account_Plan__c.isAccessible() && !accountIdSet.isEmpty()){
		 	CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIdSet, newRecords, CSM_Constants.OBJ_TYPE_OPPORTUNITY);
	 	}
	 	//US1073: Update Opportunity only if Quote is Synced
 		if( !syncedQuoteIdSet.isEmpty()) { 			
 			Decimal qliCount = 0;
 			List<Sobject> distributorQuotesList;
			Set<Id> quoteIdSet = (Set<Id>)JSON.deserialize(JSON.serialize(syncedQuoteIdSet), Set<Id>.class);
			Set<Id> poIdSet = new Set<Id>();
			List<sObject> quoteList = CHL_QuoteDataAccess.getSyncedQuotesById(quoteIdSet);
			Boolean hasPOFieldOnQuote = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
			Set<String> quotesWithoutQLI = new Set<String>();
			Set<Id> opptyIdsWithQLI = new Map<Id,Opportunity>(opptyParams.qualifiedOpportunityList).keySet();
			for(sObject qObj: quoteList) {
	 			if(hasPOFieldOnQuote && qObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != null) {
	 				poIdSet.add((Id)qObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'));
				}
				qliCount = qliCount + (Decimal)qObj.get('LineItemCount');
				if(qObj.get('LineItemCount') == 0) {
					quotesWithoutQLI.add((Id)qObj.get('Id'));
					opptyIdsWithQLI.remove((Id)qObj.get('OpportunityId'));
				}
	 		}
	 		if(quoteList != null && !quoteList.isEmpty() && !poIdSet.isEmpty() && hasChannelAccess){
	 			CHL_QuoteSyncHandler.isQuoteSyncNeeded = true;
				if(CHL_QuoteSyncHandler.isExecutionNeeded){
                	distributorQuotesList = CHL_QuoteSyncHandler.handleQuotePrimary(quoteList, poIdSet);
                }
	 		}
 			if(opptyParams.qualifiedOpportunityList != null && !opptyParams.qualifiedOpportunityList.isEmpty()) {
 				if(quotesWithoutQLI != null && !quotesWithoutQLI.isEmpty() && isDataServiceUser) {
 					CHL_QuoteSyncHandler.onSyncUpdateOpportunity(quotesWithoutQLI, opptyParams.qualifiedOpportunityList, opptyParams.qualifiedOpportunityMap);
 				}
 				if(!isDataServiceUser && (qliCount <= qliThreshold)){
	 				CHL_QuoteSyncHandler.onSyncUpdateOpportunity(syncedQuoteIdSet, opptyParams.qualifiedOpportunityList, opptyParams.qualifiedOpportunityMap);
	 				List<String> oppIdList = new List<String>(syncedOppIdSet);
	 				Set<String> oliFldstoQuery = new Set<String> {'Id','PricebookEntryId','Quantity','SubTotal','OpportunityId','TotalPrice'};
	 				List<OpportunityLineItem> oliList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery, 'OpportunityLineItem', 'opportunityId IN (\''+String.join(oppIdList, '\',\'')+'\')');
	 				if(!oliList.isEmpty() && oliList != null && oliList.size()==qliCount) {
	 					Set<Id> opptySyncedquoteIdSet = new Set<Id>();
	 					opptySyncedquoteIdSet.addAll((Set<Id>)JSON.deserialize(JSON.serialize(syncedOppIdSet), Set<Id>.class));
	 					CHL_QuoteSyncHandler.handleQLI_OLIUpdate(opptySyncedquoteIdSet, oliList, syncedQuoteIdSet);
 					}
	 				/* @ Need to enable OLI trigger when a new quote is synced with Oppty to copy QLI values to OLI. It will enable only insert or delete event of OLI.  
	 				   @ If Quote is not created from UI (either created through PO/Backend), then while syncing quote OLIs get deleted & reinserted, so we need to enable OLI trigger.	
	 				*/
	 				CSM_TriggerManager.enableOLITrigger = true;
 				}
				else{
					system.debug('FROM TRIGGER :: '+quotesWithoutQLI);
					CSM_OpportunityTriggerHelper.processQliRecordsByBatch(qliCount,opptyIdsWithQLI,distributorQuotesList);
				}	 				
			}
 			else if (syncedOpportunityList != null && !syncedOpportunityList.isEmpty()) {
	 			CHL_QuoteSyncHandler.handleOpportunityUpdation(syncedQuoteIdSet, syncedOpportunityList, opptyParams.qualifiedOpportunityMap);			
 			}		
 		}		
		if(hasCommitLevelField && !opptyParams.qualifiedIdSet .isEmpty()){
			opptyParams.triggerEvent = 'onAfterUpdate';
        	(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'OpportunityTriggerInvocationHandler', opptyParams);
		}
	}
	 
	private Boolean isRenewalEnabled() {
		Boolean isRenewalEnabled = false;
		REN_Renew_Configuration__c renewConfig;
	 	Map<string, REN_Renew_Configuration__c> renewConfigMap = REN_RenewReferenceData.getInstance().renewalConfigMap;
	 	if(renewConfigMap != null && !renewConfigMap.isEmpty()) {
	 		// Check if opportunity generation is enabled.
	 		renewConfig = renewConfigMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
	 		if(renewConfig != null) {
	 			isRenewalEnabled = renewConfig.REN_Is_Active__c;
	 		}
	 		// Check if asset generation is enabled.
	 		renewConfig = renewConfigMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
	 		if(!isRenewalEnabled && renewConfig != null) {
	 			isRenewalEnabled = renewConfig.REN_Is_Active__c;
	 		}
	 		// Check if Service Contract generation is enabled.
	 		renewConfig = renewConfigMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
	 		if(!isRenewalEnabled && renewConfig != null) {
	 			isRenewalEnabled = renewConfig.REN_Is_Active__c;
	 		}
	 	}
	 	return isRenewalEnabled;
	}
	 
	public override void onAfterInsert( List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
		Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		Set<Id> accountIdsSet = new Set<Id>();	 	
		if ((hasCSMAccess || hasRenewAccess) && Schema.sObjectType.CSM_Account_Plan__c.isAccessible()) {
			for(Opportunity oppObj : (List<Opportunity>)newRecords){
				if(oppObj.accountId != null){
					accountIdsSet.add(oppObj.accountId);
				}
			}
			if(hasCSMAccess && !(accountIdsSet.isEmpty())){ 
				CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIdsSet, newRecords, CSM_Constants.OBJ_TYPE_OPPORTUNITY);
			}
		}
	}
     
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		Boolean isLtSelfServeIntegratorUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator);
		Boolean isChannelCommunityUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity);
		Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		Boolean hasOppNameField = CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c');
		Boolean isRenewalChecked = CSM_Admin__c.getOrgDefaults().REN_Set_New_Opportunity_as_Renewal__c;
		for(Opportunity opp: (List<opportunity>)newRecords){
			if(hasRenewAccess && isRenewalChecked){
				opp.REN_Is_CLM_Renewal__c = true;
			}
			if(hasOppNameField && (!isLtSelfServeIntegratorUser) && (!isChannelCommunityUser)){
				opp.put('Opportunity_Name__c',opp.Name);
			}
		}
	}
     
	
	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
		
		//Boolean hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
	    Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		//Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;	
		    
		Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
		Boolean isSystemAdminUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_SystemAdminUser);
		Boolean isOpsMgrUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_OperationServicesEditUser);
		Boolean isOpsRepUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_OperationServicesUser);
		Boolean isSalesMgrUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_SalesManager);
		Boolean isSalesRepUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_SalesRep);
		Boolean isLtSelfServeIntegratorUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator);
		Boolean isChannelCommunityUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity);
		Boolean hasClosedSaleOpptyEditAccess = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_Edit_Closed_Sale_Opportunities);
		
		String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
		Boolean hasOppNameField = CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c');
		Boolean isSolExt = CSM_AccessController.hasObject(solExtNameSpace+'Peer_Review__c');
		Boolean hasSyncedQuoteField = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');
		Boolean hasRecordTypeField = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_CASE_REC_TYPE);
		    
		SS_TriggerCollectionParameters.OpportunityTriggerParams oppParams =  new SS_TriggerCollectionParameters.OpportunityTriggerParams();
		oppParams.filteredOpportunityList = new List<Opportunity>();
		oppParams.qualifiedOpportunityList = new List<Opportunity>();
		//oppParams.opportunityList = new List<Opportunity>();
		oppParams.oldRecordsMap = new Map<ID, Opportunity>();
		oppParams.qualifiedOpportunityMap = new Map<ID, Opportunity>();
		oppParams.filteredIdSet = new Set<ID>();
		
		List<Opportunity> filteredOpportunityListByStage = new List<Opportunity>();
		List<Opportunity> closedOppList = new List<Opportunity>();
		
		for (Opportunity opportunity :  (list<Opportunity>) newRecords ){
					
			Opportunity oldOppObj = (Opportunity) oldRecordsMap.get(opportunity.Id);			
			//If condition for updating RLI stage to Open
			if(hasRecordTypeField){
				Id editRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity - Edit') != null ? Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity - Edit').getRecordTypeId() : null;
				Id readonlyRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity - Read Only') != null ? Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity - Read Only').getRecordTypeId() : null;
				if(oldOppObj.get('recordtypeId') != opportunity.get('recordtypeId') && oldOppObj.get('recordtypeId') == readonlyRecordtypeId && opportunity.get('recordtypeId') == editRecordtypeId && (opportunity.isClosed)){
					opportunity.put('recordtypeId',oldOppObj.get('recordtypeId'));
				}
			}
			if(hasRenewAccess && (opportunity.StageName != oldOppObj.StageName) && (oldOppObj.StageName == 'Closed Sale' || oldOppObj.StageName == 'House Account' || oldOppObj.StageName == 'No Service') && (!opportunity.isClosed) ){
				filteredOpportunityListByStage.add(opportunity);
    		}
    		
    		//Restrict LT and Community user to execute Sol Ext. fuctionality.
    		if(!isChannelCommunityUser && !isLtSelfServeIntegratorUser){
    			if(isSolExt && !opportunity.isClosed && opportunity.StageName != oldOppObj.StageName){
        			if(oldOppObj.StageName == 'No Service' && opportunity.get(solExtNameSpace +'NS_Approval_Status__c') == 'NS - Approved'){
        				opportunity.put(solExtNameSpace +'NS_Approval_Status__c','Recalled');
        			}else if(oldOppObj.StageName == 'House Account' && opportunity.get(solExtNameSpace +'HA_Approval_Status__c') == 'HA - Approved' ){
        				opportunity.put(solExtNameSpace +'HA_Approval_Status__c','Recalled');
        			}
    			}	
        		
        		//Setting Opportunity name in Opportunity_Name__c field.
        		if(hasOppNameField){
        			opportunity.put('Opportunity_Name__c',opportunity.Name);
        		}
        			
        		//If condition for update Sales Target on Opp. Sol Ext --> OpportunityTriggerHandlerHelper.updateSalesTarget
        		if(opportunity.StageName == 'Closed Sale' && (opportunity.OwnerId != oldOppObj.OwnerId || opportunity.CloseDate != oldOppObj.CloseDate || opportunity.StageName != oldOppObj.StageName)){
        			oppParams.qualifiedOpportunityList.add(opportunity);
        			oppParams.filteredIdSet .add(opportunity.OwnerId);
        			oppParams.oldRecordsMap.put(oldOppObj.id, oldOppObj);
        		}
        			
        		//If condition for Stage Validation : Prevent_Close_Stage_Change
        		if(oldOppObj.isClosed && !opportunity.isClosed && !(isSystemAdminUser || isDataServicesUser || isSalesMgrUser || isSalesRepUser 
        			|| isOpsMgrUser || isOpsRepUser || hasClosedSaleOpptyEditAccess && (oldOppObj.StageName == 'House Account' || oldOppObj.StageName =='No Service'))){
         		     opportunity.addError(System.Label.REN_LBL_UPDATE_CLOSED_OPP_NOT_ALLOWED); 
				}
        			
        		if(oldOppObj.stageName == 'Closed Sale'){
					if(!isSystemAdminUser && !isDataServicesUser && !hasClosedSaleOpptyEditAccess){//If condition for Stage Validation : Opportunity_stage_should_not_be_closed
						opportunity.addError(System.Label.REN_LBL_CLOSED_OPP_TO_REOPEN_TO_UPDATE); 
					}else{//condition for validateChanges used in updateSalesTarget function.
						oppParams.qualifiedOpportunityMap.put(opportunity.id, oldOppObj); 
						oppParams.filteredOpportunityList.add(opportunity);
					}
        		}
    		}
    		if(hasRenewAccess && (opportunity.StageName != oldOppObj.StageName) && (opportunity.StageName == 'Closed Sale' || opportunity.StageName == 'House Account' || opportunity.StageName == 'No Service')){
    			closedOppList.add(opportunity);
    		}
    		if(hasRenewAccess 
	    		&& (opportunity.StageName != oldOppObj.StageName) 
	    		&& (oldOppObj.StageName == 'Closed Sale' || oldOppObj.StageName == 'House Account' || oldOppObj.StageName == 'No Service')
	    		&& (opportunity.StageName != 'Closed Sale' || opportunity.StageName != 'House Account' || opportunity.StageName != 'No Service')){
    			opportunity.REN_Renewal_Target_Lost__c = 0;
    			opportunity.REN_Renewal_Target_Resolved__c = 0;
    			opportunity.REN_Renewal_Target_Won__c = 0;
    		}
    		if(!isDataServicesUser && ((opportunity.CHL_QuoteSyncStatus__c == 'In Progress') || (opportunity.CHL_QuoteSyncStatus__c == 'Scheduled'))){
    			opportunity.addError(System.Label.CHL_LBL_QUOTE_ASYNC_VALIDATION_ERROR);
    		}
		} //End of 'for' loop.
        if(!filteredOpportunityListByStage.isEmpty()){
        	CSM_OpportunityTriggerHelper.updateRliStageToOpen(filteredOpportunityListByStage);
        }
        if(closedOppList != null && !closedOppList.isEmpty()){
        	REN_OpportunityMetricsBusiness.setRliMetricsFieldsOnOpportunity(closedOppList);
        }	
        if(isSolExt && (!oppParams.qualifiedOpportunityList .isEmpty() || !oppParams.qualifiedOpportunityMap.isEmpty())){
        	oppParams.triggerEvent = 'onBeforeUpdate';
        	oppParams.qualifiedIdSet = new Set<String>{'onBeforeUpdate'};//Need to change it. Please refer Note in DE3104
            (new SS_FeatureInvocation()).invoke( (String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'OpportunityTriggerInvocationHandler', oppParams);
        }
			
		//} //End of If condition -- outer
			
		//CSM_Constants.OPPORTUNITY_TRIGGER_BEFORE = true;
	} 
          
}