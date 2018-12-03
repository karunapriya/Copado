public with sharing class CHL_QuoteLineItemTriggerHandler extends CSM_TriggerManager.TriggerHandler {
    
    public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
    //IF Multicurrency Organization ,then only call the trigger functionality.
        if(!SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity) && !SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator)) {
            String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
            boolean isSolutionExtnInstalled = CSM_AccessController.hasField('QuoteLineItem', solnExtnNamespace + 'Local_Currency_Amount__c');
            
            if(isSolutionExtnInstalled && UserInfo.isMultiCurrencyOrganization() ) {                
                Set<Id> quoteIdSet = new Set<Id>();
                List<SObject> quoteLineItemList = new List<SObject>();
                for(sObject sObj: newRecords) {
                    if(sObj.get(solnExtnNamespace+'Local_Currency_Amount__c') != null && sObj.get(solnExtnNamespace+'Local_Currency_Amount__c') != 0) {
                        quoteIdSet.add((Id)sObj.get('QuoteId'));
                        quoteLineItemList.add(sObj);    
                    }   
                }   
                if(!quoteLineItemList.isEmpty() && REN_CurrencyExchangeRateDataAccess.IS_ACM_ENABLED) {
                    Set<String> requestedFields =new Set<String>{'OpportunityId','Id'};
                    if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CSM_Util.nameSpacePrefixSolnExtn + 'Local_Currency_Code__c')) {
                        requestedFields.add(CSM_Util.nameSpacePrefixSolnExtn + 'Local_Currency_Code__c');   
                    }
                    Map<Id, sObject> quoteMap = CHL_QuoteDataAccess.getQuoteMapById(quoteIdSet,requestedFields);
                    CHL_QuoteLineItemTriggerHelper.processQliRecords(quoteMap,quoteLineItemList, null);
                }
            }       
        }
    }  
    
    public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){ 
        //solution ext..
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        Map<Id, sObject> quoteLineItemMap = new Map<Id, sObject>();
        //base 
        
        Set<String> qualifiedQuoteId = new Set<String>();
        Set<id> quoteIdSet = new Set<id>();
        Set<String> subTotalQuoteSet = new Set<String>();
        List<Opportunity> opptyRecords = new List<sObject>();
        Map<id,Opportunity> masterOpportunityMap = new Map<id,Opportunity>();
        List<String> quoteIdList = new List<String>();
        Map<Id, sObject> poIdToQuoteMap = new Map<Id, sObject>();
        Boolean isSolutionExtnInstalled = CSM_AccessController.hasField('QuoteLineItem', CSM_Util.nameSpacePrefixSolnExtn  + 'Local_Currency_Amount__c');
        boolean updMsrpAllowed = CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);      
        for(sObject sObj: newRecords) {
            quoteIdList.add((Id)sObj.get('QuoteId'));
            qualifiedQuoteId.add((Id)sObj.get('QuoteId')); 
            if((Double)sObj.get('Subtotal') != (Double)oldRecordsMap.get(sObj.id).get('Subtotal')) {
                subTotalQuoteSet.add((Id)sObj.get('QuoteId'));
            }
            if (updMsrpAllowed) {
                if (oldRecordsMap != null)  {
                    if (((Double)oldRecordsMap.get(sObj.id).get(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c') != (Double)sObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c'))
                     || ((Double)oldRecordsMap.get(sObj.id).get('UnitPrice') != (Double)sObj.get('UnitPrice'))) {
                        quoteIdSet.add((Id)sObj.get('QuoteId'));
                        subTotalQuoteSet.add((Id)sObj.get('QuoteId'));
                    }
                }   
            }
            //solution ext..        
            if(isSolutionExtnInstalled && !SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity) && !SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator)){              
                if (sObj.get(solnExtnNamespace+'Local_Currency_Amount__c') != ((Double)oldRecordsMap.get(sObj.Id).get(solnExtnNamespace+'Local_Currency_Amount__c')) || sObj.get('Quantity') != ((Double)oldRecordsMap.get(sObj.Id).get('Quantity'))){
                    quoteLineItemMap.put(sObj.Id, sObj); 
                }   
            }                   
        }   
        CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper();
        if (!quoteIdSet.isEmpty()){
            quoteWrapper.quoteIdsSet = quoteIdSet;
            CHL_QuoteSyncHandler.rollupCountsOnQuoteFromQLI(quoteWrapper);
        }           
        
        Set<String> additionalFields = new Set<String>{'GrandTotal','TotalPrice'};
        if(isSolutionExtnInstalled && !SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity) && !SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator)){
            if(CSM_AccessController.hasField('Quote', solnExtnNamespace +'Local_Currency_Code__c')) {
                additionalFields.add(solnExtnNamespace+'Local_Currency_Code__c');
            }
            if(CSM_AccessController.hasField('Quote', 'CurrencyIsoCode')) {
                additionalFields.add('CurrencyIsoCode');
            }
        }
        CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper qliValueWrapper = new CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper();
        List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = CHL_QuoteSyncHandler.getQuoteToOpptyMapping();   
        qliValueWrapper.fieldMappingListQuoteToOppty = new List<REN_Field_Mappings__c>(fieldMappingListQuoteToOppty);
        qliValueWrapper.qualifiedQuoteId = new Set <String>(qualifiedQuoteId);
        qliValueWrapper.IsSyncing = false;
        qliValueWrapper.additionalFields = new Set<String>(additionalFields);
        List<SObject> quoteList = CHL_QuoteLineItemTriggerHelper.getQuoteListUsingMapping(qliValueWrapper);
        map<id,SObject> quoteIdMap = new map<id,SObject>(quoteList);

        Set<String> requestedFields = new Set<String>{'REN_AddsAmount__c','CloseDate'};
        if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +'Commit_Level__c')) {
            requestedFields.add(solnExtnNamespace+'Commit_Level__c');
        }
        if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +'First_Quote_Completed_Date__c')) {
            requestedFields.add(solnExtnNamespace+'First_Quote_Completed_Date__c');
        }           
        if(CSM_AccessController.hasField('Opportunity','SyncedQuoteId')) {
            opptyRecords = CHL_Util.getObjectListByWhereClause(requestedFields,'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') )');
        }                                                                                               
        map<id,Opportunity> opportunityIdMap = new map<id,Opportunity>(opptyRecords);
        List<SObject> syncQuoteList = new List<SObject>();
        //we cant use SyncedQuoteId field to query as QLI trigger contex not allowing.So instead of looping on opp. list loop on Quote list.        
        if(CSM_AccessController.hasField('Opportunity','SyncedQuoteId')) {
            for(SObject quoteObj : quoteList) {
                if(quoteObj.get('IsSyncing') == true){
                    if(quoteIdSet.contains((Id)quoteObj.id)){
                        syncQuoteList.add(quoteObj);
                     }
                     if(opportunityIdMap != null && !opportunityIdMap.isEmpty()){
                        if(subTotalQuoteSet.contains((String)quoteObj.get('id'))){
                            if(String.isNotBlank((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'))) {
                                poIdToQuoteMap.put((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj );
                                masterOpportunityMap.put((id)quoteObj.get('OpportunityId'),opportunityIdMap.get((id)quoteObj.get('OpportunityId')));
                            }
                        }               
                        
                    }
                }
            }            
        }
        
        //Move this method here as part of DE3358, need to update QLI 1st and then QLI to OLI
        if (quoteLineItemMap != null && !quoteLineItemMap.isEmpty() && REN_CurrencyExchangeRateDataAccess.IS_ACM_ENABLED){
           List<SObject> quoteLineItemList = CHL_QuoteLineItemDataAccess.getQliFromId(quoteLineItemMap.keySet());
           List<SObject> qliList = CHL_QuoteLineItemTriggerHelper.processQliRecords(quoteIdMap,quoteLineItemList,opportunityIdMap);
           if(qliList != null && !qliList.isEmpty()){
                CHL_QuoteLineItemDataAccess.updateQuoteLineItem(new set<String>{REN_Constants.OBJ_OLI_UNITPRICE}, qliList);
           }           
        }   
        if(syncQuoteList != null && !syncQuoteList.isEmpty()){
            quoteWrapper.newRecordList = syncQuoteList;
            quoteWrapper.quoteIdsSet = quoteIdSet;
            if (!quoteIdSet.isEmpty()){
                CHL_QuoteSyncHandler.handleQuoteUpdate(quoteWrapper,fieldMappingListQuoteToOppty);
            }
        }       
        
        List<String> oppIdList = new List<String>();
        oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opportunityIdMap.keySet()), List<String>.class)); 
        List<OpportunityLineItem> opliToUpdateList = CHL_QuoteSyncHandler.onSyncUpdateOLI(oppIdList,null,null);
        if(opliToUpdateList != null){
            if(!masterOpportunityMap.isEmpty() && !poIdToQuoteMap.isEmpty()) {  
                CHL_QuoteSyncHandler.updatePartnerOpptyFieldsFromQLI(poIdToQuoteMap, masterOpportunityMap, quoteWrapper);
            }
        }           
    }
    
    public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){    
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> qliIdSet = new Set<Id>();
        Set<String> qualifiedQuoteId = new Set<String>();
        Set<String> quoteIds = new Set<String>();
        List<String> quoteIdList = new List<String>();
        list<Sobject> QuoteList = new List<Sobject>();
        Set<String> allQuoteIdsSet = new Set<String>();
        Set<Id> quoteIdsSetWithLocalCurrency = new Set<Id>();
        Boolean hasMSRP = CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);
        Boolean hasSyncedAfterCreationFld = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_SyncedAfterCreation__c');
        Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
        Boolean hasSyncedQuoteField = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');        
        CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper(); 
        quoteWrapper.quoteIdsSet = new Set<Id>();
        quoteWrapper.newRecordList = new List<sObject>();
        String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;     
        //List<SObject> quoteLineItemList = new List<SObject>();
        for(sObject qli:newRecords){
            allQuoteIdsSet.add((Id)qli.get('QuoteId'));         
            if(hasMSRP){
                if((Decimal)qli.get(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP) != null){
                    qualifiedQuoteId.add((Id)qli.get('QuoteId')); 
                    quoteWrapper.quoteIdsSet.add((Id)qli.get('QuoteId'));       
                }
            }
            if(!Test.isRunningTest()) {
	            if(qli.get(solnExtNamespace+'Local_Currency_Amount__c') == null || qli.get(solnExtNamespace+'Local_Currency_Amount__c') == 0) {
	                quoteIdsSetWithLocalCurrency.add((Id)qli.get('QuoteId'));
	                //quoteLineItemList.add(qli);
	            }
	            if(qli.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c') != null){
	                quoteIdSet.add((Id)qli.get('QuoteId'));
	                qliIdSet.add(qli.Id);
	            }
	            else if(qli.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c') == null){
	                quoteIds.add((Id)qli.get('QuoteId'));
	            }
            }
        } 
        Decimal threshold = CSM_Admin__c.getOrgDefaults().CHL_QliCount__c;
        if(isDataServicesUser){
            if(qualifiedQuoteId != null && !qualifiedQuoteId.isEmpty()){
                CHL_QuoteSyncHandler.rollupMsrpOnQuote(qualifiedQuoteId);
            }
            //List<Opportunity> oppWithSyncQuoteList = new List<Opportunity>();
            Set<Id> oppWithSyncedQuoteIdSet = new Set<Id>();
            quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(allQuoteIdsSet), List<String>.class));
            if(hasSyncedQuoteField){                
                List<sObject> syncedQuoteList = CHL_Util.getObjectListByWhereClause(new Set<String>{'OpportunityId','Id','IsSyncing'},'Quote','Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') and IsSyncing=true ');    //      
                for(sObject sObj: syncedQuoteList) {
                    oppWithSyncedQuoteIdSet.add((ID)sObj.get('OpportunityId'));
                }
            }
            if(oppWithSyncedQuoteIdSet != null && !oppWithSyncedQuoteIdSet.isEmpty()){
                CSM_OpportunityTriggerHelper.processQliRecordsByBatch(newRecords.size(), oppWithSyncedQuoteIdSet, null);
            }
        }           
        else if(qliIdSet.size() > threshold && !isDataServicesUser) {
            List<sObject> quoteToUpdateList = new List<sObject>();
            List<sObject> insertedQuote = new List<sObject>();
            List<String> insertedQuoteIdList = new List<String>();              
            insertedQuoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteIdSet), List<String>.class));
            insertedQuote = CHL_Util.getOBjectListByWhereClause(new Set<String>{'Id','LineItemCount',CHL_Util.quoteExtnNameSpace+'CHL_SyncedAfterCreation__c'},'Quote','Id IN ( \''+String.join(insertedQuoteIdList, '\',\'')+'\') ');
            for(sObject quoteInserted : insertedQuote){
                if(hasSyncedAfterCreationFld){
                    quoteInserted.put(CHL_Util.quoteExtnNameSpace+'CHL_SyncedAfterCreation__c','No');
                    quoteToUpdateList.add(quoteInserted);
                }                   
            }
            if(quoteToUpdateList != null && !quoteToUpdateList.isEmpty()){
                CHL_QuoteDataAccess.updateQuotes(quoteToUpdateList);
                boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
                if(isFlexQueueAvailable){
                    Integer batchSize = CSM_Util.getCustomListSetting('CHL_CreateQuoteAndQLIBatch');
                    batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
                    CHL_CreateQuoteAndQLIBatch quoteQLIBatch = new CHL_CreateQuoteAndQLIBatch();
                    quoteQLIBatch.quoteIdSet = quoteIdSet;
                    quoteQLIBatch.isOppUpdateRequired = false;
                    Database.executeBatch(quoteQLIBatch, batchSize);
                } else{
                    REN_AsyncUtil.scheduleBatchForNewQuote(quoteIdSet, false, 15);
                }
            }               
        }   
        else if(!isDataServicesUser){   
            if(quoteIdSet != null && !quoteIdSet.isEmpty()) {
                Map<Id, sObject> quoteMap = new Map<Id, sObject>();
                Set<String> opportunityIdSet = new Set<String>();
                Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
                if(quoteIdsSetWithLocalCurrency != null && !quoteIdsSetWithLocalCurrency.isEmpty()) {
                    Set<String> requestedFields =new Set<String>{'OpportunityId','Id','IsSyncing'};
                    if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CSM_Util.nameSpacePrefixSolnExtn + 'Local_Currency_Code__c')) {
                        requestedFields.add(CSM_Util.nameSpacePrefixSolnExtn + 'Local_Currency_Code__c');   
                    }
                    quoteMap = CHL_QuoteDataAccess.getQuoteMapById(quoteIdsSetWithLocalCurrency,requestedFields);
                    for (sObject quoteObj: quoteMap.values()){
                        if(quoteObj.get(solnExtNamespace+'Local_Currency_Code__c') != null && String.isNotBlank((String)quoteObj.get(solnExtNamespace+'Local_Currency_Code__c')) ) {
                            opportunityIdSet.add((String)(quoteObj.get('OpportunityId')));
                        }
                    }
                    opportunityMap = new Map<Id, Opportunity>(CSM_OpportunityDataAccess.getOpportunitiesById(opportunityIdSet));
                }
                if(SS_Constants.isSimplifiedDataModelEnabled){  
                    qualifiedQuoteId.addAll(CHL_QuoteSyncHandler.handleSimplifiedQLICreation(quoteIdSet,qliIdSet,quoteMap,opportunityMap));
                }
                else {                  
                    qualifiedQuoteId.addAll(CHL_QuoteSyncHandler.handleQuoteLineItemAfterCreation(quoteIdSet,qliIdSet,quoteMap,opportunityMap));                    
                }   
            }                 
            quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteIds), List<String>.class));
            
            if(CSM_AccessController.hasObject('Quote')){
                QuoteList = CHL_Util.getObjectListByWhereClause(new Set<String>{'Id','IsSyncing'},'Quote','Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') and IsSyncing=true ');            
            }
            if(QuoteList != null && !QuoteList.isEmpty() ){
                CSM_TriggerManager.enableOLITrigger = true;
            }
            if(qliIdSet.size() <= threshold && qualifiedQuoteId != null && !qualifiedQuoteId.isEmpty()){
                CHL_QuoteSyncHandler.rollupMsrpOnQuote(qualifiedQuoteId);   
                if(QuoteList != null && !QuoteList.isEmpty()) {
                    CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper qliValueWrapper = new CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper();
                    List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = CHL_QuoteSyncHandler.getQuoteToOpptyMapping();   
                    qliValueWrapper.fieldMappingListQuoteToOppty = new List<REN_Field_Mappings__c>(fieldMappingListQuoteToOppty);
                    qliValueWrapper.qualifiedQuoteId = qualifiedQuoteId;
                    qliValueWrapper.IsSyncing = true;
                    quoteWrapper.newRecordList = CHL_QuoteLineItemTriggerHelper.getQuoteListUsingMapping(qliValueWrapper);          
                    CHL_QuoteSyncHandler.handleQuoteUpdate(quoteWrapper,fieldMappingListQuoteToOppty);  
                }
            }               
        }                   
        
     }
     
     public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap){
        
        Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
        Set<String> qualifiedQuoteId = new Set<String>();
        Set<Id> quoteIdsSet = new Set<Id>();
        List<String> quoteIdList = new List<String>();
        CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper();
        quoteWrapper.quoteIdsSet = new Set<Id>();
        quoteWrapper.newRecordList = new List<sObject>();
        Boolean isMSRPFieldExist = CSM_AccessController.hasField('QuoteLineItem', CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);
        //IF Channel license exists for user, then only call the trigger functionality
        for(sObject qli: oldRecords) {
            if (hasChannelAccess && ((isMSRPFieldExist &&  (Double)qli.get(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP) != null && (Double)qli.get(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP) != 0)
            || ((Double)qli.get('UnitPrice') != null && (Double)qli.get('UnitPrice') != 0))) {
                qualifiedQuoteId.add((Id)qli.get('QuoteId')); 
                quoteWrapper.quoteIdsSet.add((Id)qli.get('QuoteId'));
                quoteIdList.add((String)qli.get('QuoteId'));
            }
        }
        if(qualifiedQuoteId != null && !qualifiedQuoteId.isEmpty()){
            CHL_QuoteSyncHandler.rollupCountsOnQuoteFromQLI(quoteWrapper);  
            List<sObject> quoteList = CHL_Util.getObjectListByWhereClause(new Set<String>{'Id','IsSyncing'},'Quote','Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') and IsSyncing=true ');
            if(quoteList != null && !quoteList.isEmpty()) {
                CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper qliValueWrapper = new CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper();
                List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = CHL_QuoteSyncHandler.getQuoteToOpptyMapping();   
                qliValueWrapper.fieldMappingListQuoteToOppty = new List<REN_Field_Mappings__c>(fieldMappingListQuoteToOppty);
                qliValueWrapper.qualifiedQuoteId = qualifiedQuoteId;
                qliValueWrapper.IsSyncing = true;
                quoteWrapper.newRecordList = CHL_QuoteLineItemTriggerHelper.getQuoteListUsingMapping(qliValueWrapper);          
                CHL_QuoteSyncHandler.handleQuoteUpdate(quoteWrapper,fieldMappingListQuoteToOppty);  
            }
            Map<Id, sObject> poIdToQuoteMap = new Map<Id, sObject>();
            Map<id,Opportunity> masterOpportunityMap = new Map<id,Opportunity>();
            
            CHL_QuoteSyncHandler.processPartnerOpportunityList(quoteWrapper, poIdToQuoteMap, masterOpportunityMap);
            REN_OpportunityMetricsBusiness.setOliMetricsFields(quoteWrapper.opportunityIdSet, false);  
            if(!masterOpportunityMap.isEmpty() && !poIdToQuoteMap.isEmpty()) {  
                CHL_QuoteSyncHandler.updatePartnerOpptyFieldsFromQLI(poIdToQuoteMap, masterOpportunityMap, quoteWrapper);
            }
        }
        
    }
      //
    public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){  
        
        String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        Boolean isSolExt = CSM_AccessController.hasObject(solExtNameSpace+'Peer_Review__c');
        Boolean isLtSelfServeIntegratorUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator);
        Boolean isChannelCommunityUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity);
        Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
        SS_TriggerCollectionParameters.sObjectTriggerParams qliTriggerParams = new SS_TriggerCollectionParameters.sObjectTriggerParams();
        qliTriggerParams.qualifiedRecList = new List<sObject>();
        qliTriggerParams.oldRecordsMap =  new Map<id, sObject>();
        qliTriggerParams.objectName = 'QuoteLineItem';      
        Map<Id, sObject> qliIsWonOppMap = new Map<Id, sObject>(CHL_QuoteLineItemDataAccess.getSelectedQli(newRecordsMap.keySet(), new Set<String>{'QuoteId'}, new List<String>{' Quote.Opportunity.stageName = \'Closed Sale\' '}));
        List<SObject> quotesList = CHL_QuoteDataAccess.getQuoteWithOppStatusAsInProgress(newRecordsMap.keySet());
        Map<Id,SObject> quotesMap = new Map<Id,SObject>(quotesList);
        for(sObject qliObj : newRecords){
            sObject oldsObj = oldRecordsMap.get(qliObj.id);
            if(qliIsWonOppMap.containsKey(qliObj.id)){
                qliTriggerParams.qualifiedRecList.add(qliObj);
                qliTriggerParams.oldRecordsMap.put(oldsObj.id, oldsObj);
            }
            if(!isDataServicesUser && quotesMap != null && !quotesMap.isEmpty() && quotesMap.containsKey((Id)qliObj.get('QuoteId'))){
                qliObj.addError(System.Label.CHL_LBL_QUOTE_ASYNC_VALIDATION_ERROR);         
            }
        }
        if(isSolExt && !isChannelCommunityUser && !isLtSelfServeIntegratorUser) {
            if(qliTriggerParams.qualifiedRecList != null && !qliTriggerParams.qualifiedRecList.isEmpty()){
                 (new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'QLITriggerInvocationHandler', qliTriggerParams);
            }
        }       
     }
}