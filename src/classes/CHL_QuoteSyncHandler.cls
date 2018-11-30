/*
@ Author      : Tanvi & Vishal S
@ Description : Below class is created to handle Opportunity, Quote and their corresponding lineitems creation, updation and maintain Renewal Relationship product Ids during Quote sync Process.
              : Class is mainly cater to userstories; US1070, US1071, US1072, US1073, US1075, US1076
*/
public with sharing class CHL_QuoteSyncHandler {
    
    //Static Variable to handle trigger recusrive behaviour on update of Opportunity & Quote and its corresponding lineitems during Sync . 
    //public static Boolean postQuoteSyncingUpdate = false;
    //public static Boolean QUOTELINEITEM_TRIGGER = true;
    //private static Boolean is2TierPricingEnable = false;
    public static Boolean quoteUpdateIn2Tier = false;
    public static Boolean isQuoteSyncNeeded = false;
    public static Boolean isExecutionNeeded = true;
    private static final String SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE = 'First_Quote_Completed_Date__c';
    private static final String SSL_ZTH_COMMIT_LEVEL = 'Commit_Level__c';
    
    /*
    @ Description: Method is called after new QuoteLineItems have been inserted. 
    @                   
    */
    public static Set<String> handleQuoteLineItemAfterCreation(Set<Id> quoteIdSet, Set<Id> qliIdSet, Map<Id, sObject> quotesMap, Map<Id, Opportunity> opportunityMap)    {
        List<String> quoteIdList = new List<String>();      
        List<String> qliIdList = new List<String>();
        quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteIdSet), List<String>.class));
        qliIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(qliIdSet), List<String>.class));
        ID syncedID ;
        OpportunityLineItem opli;
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<String> qualifiedQuoteIds = new Set<String>();
        Set<String> oliFldstoQuery = new Set<String> {'Id','PricebookEntryId','Quantity','SubTotal','OpportunityId'};        
        List<REN_Field_Mappings__c> fieldMappingListOLIToQLI = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                            Label.REN_LBL_OPPTY_TO_QUOTE,CHL_Constants.OBJ_QUOTELINEITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM);
        REN_Util.getFromAndToFldsToQuery(fieldMappingListOLIToQLI,frmFldSet,toFldSet);              
        oliFldstoQuery.addall(frmFldSet);                               
        List<OpportunityLineItem> opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') )');
        Map<Id, OpportunityLineItem> oppLineMap = new Map<Id, OpportunityLineItem>(opliQueriedList); 
        Sobject quoteLineItemObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
        Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(quoteLineItemObj.getSobjectType());
        Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId','Quantity',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'};
        List<sObject> qliListToUpdate = new List<sObject>();    
        qliFldstoQuery.addall(toFldSet);
        qliListToUpdate = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem','Id IN ( \''+String.join(qliIdList, '\',\'')+'\') ');  
        String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        for(Sobject sobj:qliListToUpdate) {
            syncedID = (ID)sobj.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c');                      
            opli = oppLineMap.get(syncedID);
            REN_Util.copyObjectUsingAdminMapping(opli, sobj, fieldDesctiptionMap, fieldMappingListOLIToQLI);
            if((Decimal)sobj.get(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP) != null){
                qualifiedQuoteIds.add((Id)sobj.get('QuoteId'));
            }
            if(quotesMap != null && !quotesMap.isEmpty() && opportunityMap!= null && !opportunityMap.isEmpty()) {
                sObject quoteObj = quotesMap.get((Id)sobj.get('QuoteId'));
                Opportunity oppObj = opportunityMap.get((Id)quoteObj.get('OpportunityId'));
                if(sobj.get(solnExtNamespace+'Local_Currency_Amount__c') != null && quoteObj.get(solnExtNamespace+'Local_Currency_Code__c') != null && sObj.get(solnExtNamespace+'Local_Currency_Amount__c') != 0){
                    Decimal unitPrice = REN_CurrencyExchangeRateDataAccess.acmCurrencyConversion(
                                        (Decimal)sobj.get(solnExtNamespace+'Local_Currency_Amount__c'), 
                                        (String)quoteObj.get(solnExtNamespace+'Local_Currency_Code__c'), 
                                        (String)quoteObj.get('CurrencyIsoCode'),
                                        (oppObj == null ? null : oppObj.CloseDate));                        
                    if(unitPrice != null){                      
                        Decimal totalAmount = (Decimal)sobj.get(solnExtNamespace+'Local_Currency_Amount__c') * (Decimal)sobj.get('Quantity');
                        sobj.put('UnitPrice',unitPrice);
                        sobj.put(solnExtNamespace+'Local_Currency_Line_Total__c',totalAmount);
                    }
                }
            }
        }
        Set<String> qliFieldsSet = new Set<String> {'Id','Quantity'};
        CHL_QuoteLineItemDataAccess.updateQuoteLineItem(qliFieldsSet,qliListToUpdate);
        return qualifiedQuoteIds;           
    }
    
    public static void handleQuoteLineItemUpdation(List<sObject> oldRecords, List<sObject> newQuoteLineItemRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
    {
        List<String> quoteIdList = new List<String>();
        Set<String> msrpQuoteSet = new Set<String>();
        List<String> qliIdList = new List<String>();
        Double newMsrp = 0;
        Id qliId = null;
        sObject oldQli = null;
        boolean calculateAddsAmt = false;
        ID originalID ;
        ID syncedID ;
        OpportunityLineItem opli;
        boolean updMsrpAllowed = CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);
        
        for(sObject sObj: newQuoteLineItemRecords) {
            quoteIdList.add((Id)sObj.get(CHL_Constants.OBJ_QUOTELI_QUOTEID));
            //qliIdList.add((Id)sObj.get('Id'));
            oldQli  = Trigger.oldMap.get(sObj.Id);
            if((Double)sObj.get('Subtotal') != (Double)oldQli.get('Subtotal')) {
                calculateAddsAmt = true;
            }
            //if old and new are different then
            if (updMsrpAllowed) {
                qliId = (Id)sObj.get('Id');
                newMsrp = (Double)sObj.get(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);
                if (oldRecordsMap != null)  {
                    if ((Double)oldQli.get(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP) != newMsrp)    {
                        msrpQuoteSet.add((Id)sObj.get(CHL_Constants.OBJ_QUOTELI_QUOTEID));      
                    }
                }   
            }   
        }
    
        if (!msrpQuoteSet.isEmpty())    {
            rollupMsrpOnQuote(msrpQuoteSet);    
        }
        List<REN_Field_Mappings__c> fieldMappingListQLIToOLI = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                        Label.REN_LBL_QUOTE_TO_OPPTY, REN_Constants.OBJ_OPPTY_LINE_ITEM, CHL_Constants.OBJ_QUOTELINEITEM);
        if(fieldMappingListQLIToOLI == null || fieldMappingListQLIToOLI.isEmpty()){
            return;
        }
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<Id> oppIdSet = new Set<Id>();
        /*toFldSet.add('TotalPrice');
        toFldSet.add('OpportunityId');*/
        REN_Util.getFromAndToFldsToQuery(fieldMappingListQLIToOLI,frmFldSet,toFldSet);      
        Set<String> oliFldstoQuery = new Set<String> {'Id','PricebookEntryId','Quantity','SubTotal','OpportunityId','TotalPrice'};
        oliFldstoQuery.addall(toFldSet);    
        List<OpportunityLineItem> optyLineItemList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') AND IsSyncing = true)');
        
        if(optyLineItemList != null && !optyLineItemList.isEmpty()) {
            List<sObject> optyLineItemListToUpdate = QLItoOLIMapping(fieldMappingListQLIToOLI,newQuoteLineItemRecords,optyLineItemList,oppIdSet);
            if(!optyLineItemListToUpdate.isEmpty() && optyLineItemListToUpdate != null){
                //postQuoteSyncingUpdate = true;
                REN_Util.resetTriggersTo(false);
                REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(optyLineItemListToUpdate, toFldSet);
                REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdSet,false);
                REN_OpportunityDataAccess.calculateExpQuarterYear(optyLineItemListToUpdate,'REN_End_Date__c');
            }
            //US1757 : This code is explictly added here, as any updation on QLI will call Renewal metrics logic on Opportunity, and it will stop opportunity trigger.
            if(calculateAddsAmt && CSM_AccessController.hasField('Opportunity',  'SyncedQuoteId')) {
                List<Opportunity> opptyList = CHL_Util.getObjectListByWhereClause(new Set<String>{'SyncedQuoteId','REN_AddsAmount__c',CSM_Util.nameSpacePrefixSolnExtn+'Commit_Level__c',CSM_Util.nameSpacePrefixSolnExtn+'First_Quote_Completed_Date__c'},'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') AND IsSyncing = true)');
                Map<Id,sObject>quoteToMOMap = new Map<Id,Sobject>();
                for(sObject opp:opptyList) {
                    if(opp.get('SyncedQuoteId') != null) {
                        quoteToMOMap.put((Id)opp.get('SyncedQuoteId'),opp);             
                    }
                }
                if(quoteToMOMap != null && !quoteToMOMap.isEmpty()) {   
                    handleRRCalculation(quoteToMOMap);
                }
            }
            //end of US1757
        }
    }
    
    
    /*
    @ Description: Below method will get call, If the QUOTE is synced with the opportunity any updates from the Quote line Item should update the Opportunity Line Item.
    @              It will use the formula field  "REN Synced Line Item ID"  on the QLI and query the corresponding OLI.
    @              Update the field values on the OLI based on the mapping defined in the "QLI - OLI" mapping.          
    */
    public static void handleQuoteLineItemUpdation(List<sObject> newQuoteLineItemRecords){
        handleQuoteLineItemUpdation(null, newQuoteLineItemRecords, null, null); 
    }
    
    /*
    @ Description: Below method will get call, whenever new Quote get inserted/created. It will query corresponding the opportunity fields from the Quote.
    @              Update the quote record as defined in the "Opportunity-Quote" mapping.       
    */
    public static void handleQuoteCreation(List<sObject> newRecords, Set<String> opptyIdSet) {
        List<REN_Field_Mappings__c> fieldMappingListOpptyToQuote = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_OPPTY_TO_QUOTE,'Quote', 'Opportunity');
        if(fieldMappingListOpptyToQuote != null && !fieldMappingListOpptyToQuote.isEmpty()){            
            Set<String> frmFldSet = new Set<String>();
            Set<String> toFldSet = new Set<String>();
            REN_Util.getFromAndToFldsToQuery(fieldMappingListOpptyToQuote,frmFldSet, toFldSet);
            if (!opptyIdSet.isEmpty()) {
                List<Opportunity> opportunityList = CHL_Util.getObjectListByWhereClause(frmFldSet,'Opportunity','Id IN ( \''+String.join(new List<String>(opptyIdSet), '\',\'')+'\')');         
                List<sObject> quoteList = OpptyToQuoteMapping(fieldMappingListOpptyToQuote,newRecords,opportunityList,false);
            }
        }
    }
    
    public static List<REN_Field_Mappings__c> getQuoteToOpptyMapping(){
        List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                        Label.REN_LBL_QUOTE_TO_OPPTY, 'Opportunity', CHL_Constants.OBJ_QUOTE);
        return fieldMappingListQuoteToOppty;
    }
    
    public static void handleQuoteUpdate(REN_QuoteWrapper quoteWrapper,List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty) {
        if((quoteWrapper.optyListToUpdate == null || quoteWrapper.optyListToUpdate.isEmpty())){
            quoteWrapper.optyListToUpdate = new List<Opportunity>();
            Set<String> frmFldSet = new Set<String>();
            Set<String> toFldSet = new Set<String>();
            REN_Util.getFromAndToFldsToQuery(fieldMappingListQuoteToOppty,frmFldSet,toFldSet);
            List<String> quoteIdList = new List<String>();
            quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteWrapper.quoteIdsSet), List<String>.class)); 
            quoteWrapper.optyListToUpdate = CHL_Util.getObjectListByWhereClause(toFldSet,'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') )');          
        }
        if(fieldMappingListQuoteToOppty != null){
            List<Opportunity> oppListForRenewals = QuoteToOpportunityMapping(fieldMappingListQuoteToOppty,quoteWrapper.optyListToUpdate,quoteWrapper.newRecordList);    
            REN_OpportunityDataAccess.updateOpportunityforRenewals(oppListForRenewals);
        }       
        if(quoteWrapper.oppIdsList != null && !quoteWrapper.oppIdsList.isEmpty()){
            onSyncUpdateOLI(quoteWrapper.oppIdsList,null,null);
        }
        /*if(quoteWrapper.poIdSet != null && !quoteWrapper.poIdSet.isEmpty() ) {
            onSyncUpdateQuotePrimary(quoteWrapper.resellerQuoteIds,quoteWrapper.quoteIdsSet,quoteWrapper.poIdSet,quoteWrapper.primaryResellerIdsSet);   
        }*/
    }    
     /*
    @ Description: Below method will get call, whenever any Opportunity gets update which has Synched Quote. 
    @              Method will handle, If the QUOTE is synced with the opportunity any updates from the Opportunity should update the Quote.
    @              Update the field values on the Quote based on the mapping defined in the "Opportunity - Quote" mapping.                  
    */
    public static void handleOpportunityUpdation(Set<String> quoteIdSet, List<Opportunity> opportunityList, Map<Id, Opportunity> opportunityMap) {
        List<String> quoteIdList = new List<String>(quoteIdSet);
        List<sObject> quoteList;        
        List<REN_Field_Mappings__c> fieldMappingListOpptyToQuote = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                        Label.REN_LBL_OPPTY_TO_QUOTE,CHL_Constants.OBJ_QUOTE, 'Opportunity');
        system.debug('fieldMappingList :: '+fieldMappingListOpptyToQuote.size());                                               
        if(fieldMappingListOpptyToQuote != null && !fieldMappingListOpptyToQuote.isEmpty()){            
            Set<String> frmFldSet = new Set<String>();
            Set<String> toFldSet = new Set<String>();
            REN_Util.getFromAndToFldsToQuery(fieldMappingListOpptyToQuote,frmFldSet,toFldSet);      
            Set<String> quoteFldstoQuery = new Set<String> {'Id','OpportunityId',CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c',CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c','GrandTotal'};
            quoteFldstoQuery.addall(toFldSet);
            quoteList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,'Quote','Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') AND IsSyncing = true ');
        }
        if(quoteList != null && !quoteList.isEmpty()) {
            List<sObject> quoteListToUpdate = OpptyToQuoteMapping(fieldMappingListOpptyToQuote, quoteList, opportunityList, true);
            CHL_QuoteDataAccess.updateQuotes(quoteListToUpdate);                
            //postQuoteSyncingUpdate = true;        
            handlePOUpdationOnQuoteSync(opportunityMap, quoteList);                     
        }
    }
    
    public static void handlePOUpdationOnQuoteSync(Map<Id, Opportunity> opportunityMap, List<sObject> quoteList) {
        Map<Id,sObject> poIdToQuoteMap = new Map<Id,sObject>();
        for(sObject quoteObj:quoteList) {
            if(String.isNotBlank((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'))) {
                poIdToQuoteMap.put((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj );
            }
        }           
        if(!opportunityMap.isEmpty() || !poIdToQuoteMap.isEmpty()) {    
            updatePartnerOpptyFields(poIdToQuoteMap, opportunityMap);
        }   
    }
    
     /*
    @ Description: Below method will update PO fields (Commit Level, First quote Completed Date, Adds Amount), if quote is synced with Opportunity and it have PO. This is as part of US1974.               
    */
    public static void updatePartnerOpptyFields(Map<Id,sObject> poIdToQuoteMap, Map<Id, Opportunity> opportunityMap) {
        List<CHL_Partner_Opportunity__c> partnerOpptyUpdatedList = new List<CHL_Partner_Opportunity__c>();
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;        
        Boolean hasCommitLevelField = CSM_AccessController.hasField('Opportunity', solnExtnNamespace+'Commit_Level__c');
        Boolean hasFirstQuoteCompletedField = CSM_AccessController.hasField('Opportunity', solnExtnNamespace+'First_Quote_Completed_Date__c');
        for(Id partnerOpptyId:poIdToQuoteMap.keySet()) {
            sObject quoteObj = poIdToQuoteMap.get(partnerOpptyId);  
            Id opportunityId = quoteObj != null ? (ID)quoteObj.get('OpportunityId') : null;
            CHL_Partner_Opportunity__c partnerOpptyObj = new CHL_Partner_Opportunity__c(Id = partnerOpptyId); //(Id)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')
            partnerOpptyObj.put('CHL_Amount__c',(Decimal)quoteObj.get('GrandTotal'));
            partnerOpptyObj.put('CHL_MSRP__c',(Decimal)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c'));
            if (opportunityMap != null && opportunityMap.containsKey(opportunityId))    {
                //CHL_Partner_Opportunity__c partnerOpptyObj = new CHL_Partner_Opportunity__c(Id = partnerOpptyId); //(Id)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')
                //system.debug('partnerOpptyObj : '+partnerOpptyObj.CHL_Amount__c);
                Opportunity oppObj = opportunityMap.get(opportunityId);                 
                partnerOpptyObj.put('CHL_Color_Commit__c', hasCommitLevelField ? oppObj.get(solnExtnNamespace +SSL_ZTH_COMMIT_LEVEL) : '');
                partnerOpptyObj.put('CHL_First_Quote_Completed_Date__c', hasFirstQuoteCompletedField ? oppObj.get(solnExtnNamespace +SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE) : null);   
                partnerOpptyObj.put('CHL_AddsAmount__c', oppObj.REN_AddsAmount__c);  
            }                        
            partnerOpptyUpdatedList.add(partnerOpptyObj);     
        }
        if(partnerOpptyUpdatedList != null && !partnerOpptyUpdatedList.isEmpty()) {
            CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
            CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
            CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(partnerOpptyUpdatedList);
        }
    }
    
    
    public static void handleOpportunityUpdation(List<sObject> newRecords){
        
    }
    
    //US175 
    public static void handleRRCalculation(Map<Id,sObject> quoteToMOMap) {
                
        Map<Id,Decimal> partnerOptyIdToAddsAmount = new Map<Id,Decimal>();
        //sObject oppObj;
        Opportunity oppObj;
        Map<Id, sObject> poIdToQuoteMap = new Map<Id, sObject>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for(sObject quoteObj:CHL_QuoteDataAccess.getSyncedQuotesById(quoteToMOMap.keyset())) {
            oppObj = (Opportunity)quoteToMOMap.get((ID)quoteObj.get('Id'));
            opportunityMap.put(oppObj.Id, oppObj);
            if(String.isNotBlank((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'))) {
                poIdToQuoteMap.put((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj );
            }
            //partnerOptyIdToAddsAmount.put((Id)sobj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),(Decimal)oppObj.get('REN_AddsAmount__c'));
        }
        
        /*if(partnerOptyIdToAddsAmount != null) {           
            handlePartnerOpportunityUpdation(partnerOptyIdToAddsAmount, null, null);
        }*/
        if(!opportunityMap.isEmpty() && !poIdToQuoteMap.isEmpty()) {    
            updatePartnerOpptyFields(poIdToQuoteMap, opportunityMap);
        }
        
    }
    
    /*
    @ Description: Below method will get call, whenever any OpportunityLineItems gets update of the Opportunity which has Synched Quote. 
    @              Method will handle, If the QUOTE is synced with the opportunity any updates from the Opportunity line Item should update the Quote Line Item.
    @              Update the field values on the QuoteLineItem based on the mapping defined in the "Opportunity - Quote" mapping.
    */
    public static void handleOLIUpdate(List<OpportunityLineItem> oppLineItemLst,Set<Id> opportunityIdSet){
        CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper();
        
        List<Id> oppIdList = new List<Id>(opportunityIdSet);
        
        Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c',CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP,'Subtotal'};
        Set<String> oliFldstoQuery = new Set<String> {'Id','REN_Synced_Line_Item_ID__c'};
        
        List<REN_Field_Mappings__c> OLItoQLIMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_OPPTY_TO_QUOTE,CHL_Constants.OBJ_QUOTELINEITEM,REN_Constants.OBJ_OPPTY_LINE_ITEM);
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        REN_Util.getFromAndToFldsToQuery(OLItoQLIMappingLst,frmFldSet,toFldSet);
        qliFldstoQuery.addAll(toFldSet);
        String whereClause = 'QuoteId IN (select Id from '+CHL_Constants.OBJ_QUOTE+' where IsSyncing = true and opportunityId IN (\''+String.join(oppIdList, '\',\'')+'\') )';
        List<Sobject> qliList = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem',whereClause);
        
        List<sObject> qliCloneList = new List<sObject>(); 
        
        for(sObject obj: qliList){
            qliCloneList.add(obj.clone(true,false));
        }
        Map<Id,sObject> cloneQliMap = new Map<Id,sObject>(qliCloneList);
        
        if(qliList != null && !frmFldSet.isEmpty()){
            List<Sobject> qliToUpdateList = new List<Sobject>();
            String syncedID ;
            Sobject qli;
            qliToUpdateList = OLItoQLIMapping(OLItoQLIMappingLst,qliList,oppLineItemLst);
            
            if(!qliToUpdateList.isEmpty()){
                Set<String> qliFieldsSet = new Set<String> {'Id',CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP};
                CHL_QuoteLineItemDataAccess.updateQuoteLineItem(qliFieldsSet,qliToUpdateList);
            }
            Set<String> msrpQuoteSet = new Set<String>();
            Set<Id> quoteIdSet = new Set<Id>();
            boolean calculateAddsAmt = false;
            
            for(sObject qliObj:qliList){
                Double newMsrp = (Double)qliObj.get(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);
                quoteIdSet.add((Id)qliObj.get(CHL_Constants.OBJ_QUOTELI_QUOTEID));
                if((Double)cloneQliMap.get((Id)qliObj.get('Id')).get(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP)!=newMsrp){
                    msrpQuoteSet.add((Id)qliObj.get(CHL_Constants.OBJ_QUOTELI_QUOTEID));
                }
            }
            if (!msrpQuoteSet.isEmpty()){
                quoteWrapper.quoteIdsSet = new Set<Id>();
                quoteWrapper.quoteIdsSet.addAll((Set<Id>)JSON.deserialize(JSON.serialize(msrpQuoteSet), Set<Id>.class));
                rollupCountsOnQuoteFromQLI(quoteWrapper); 
                
                Map<Id, sObject> poIdToQuoteMap = new Map<Id, sObject>();
                Map<id,Opportunity> masterOpportunityMap = new Map<id,Opportunity>();
                
                processPartnerOpportunityList(quoteWrapper, poIdToQuoteMap, masterOpportunityMap);
                if(!masterOpportunityMap.isEmpty() && !poIdToQuoteMap.isEmpty()) {  
                    CHL_QuoteSyncHandler.updatePartnerOpptyFieldsFromQLI(poIdToQuoteMap, masterOpportunityMap, quoteWrapper);
                }
                
                CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper qliValueWrapper = new CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper();
                List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = CHL_QuoteSyncHandler.getQuoteToOpptyMapping();   
                qliValueWrapper.fieldMappingListQuoteToOppty = new List<REN_Field_Mappings__c>(fieldMappingListQuoteToOppty);
                qliValueWrapper.qualifiedQuoteId = msrpQuoteSet;
                qliValueWrapper.IsSyncing = true;
                quoteWrapper.newRecordList = CHL_QuoteLineItemTriggerHelper.getQuoteListUsingMapping(qliValueWrapper);
                    
                CHL_QuoteSyncHandler.handleQuoteUpdate(quoteWrapper,fieldMappingListQuoteToOppty);  
            }
            
        }
        
    }
    
    /*
    @ Description: Below method will handle OpportunityLineItem updation after sync, 
    @              If Quotelineitems are updated, and then its corresponding quote gets sync with opportunity then,
    @              it should Update the field values on the OpportunityLineItem based on the mapping defined in the "quote - Opportunity" mapping.
    */
    public static List<Sobject> onSyncUpdateOLI(List<String> oppIdList,List<String> quoteIdList,List<Sobject> quoteLineItemList){
        List<REN_Field_Mappings__c> QLItoOLIMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_QUOTE_TO_OPPTY, REN_Constants.OBJ_OPPTY_LINE_ITEM, CHL_Constants.OBJ_QUOTELINEITEM);
        List<OpportunityLineItem> opliToUpdateList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> opliQueriedList = new List<OpportunityLineItem>();
        if(QLItoOLIMappingLst == null || QLItoOLIMappingLst.isEmpty()){
            return opliQueriedList;
        }
        List<Sobject> qliList = new List<Sobject>();
        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()){
            qliList.addAll(quoteLineItemList);
        }
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> oliFldstoQuery = new Set<String> {'Id','PricebookEntryId','Quantity','SubTotal','OpportunityId','TotalPrice'};
        if(!Test.isRunningTest()) {
        	REN_Util.getFromAndToFldsToQuery(QLItoOLIMappingLst,frmFldSet,toFldSet);        
        	oliFldstoQuery.addAll(toFldSet);
        }
        
        if(oppIdList != null && !oppIdList.isEmpty()){
        	Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId'};      
            if(CSM_AccessController.hasField('QuoteLineItem', CHL_Util.quoteExtnNameSpace + 'REN_Synced_Line_Item_ID__c')) {
        		qliFldstoQuery.add(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c');        		
            	qliFldstoQuery.addAll(frmFldSet);
        	}
            String whereClause = 'QuoteId IN (select Id from '+CHL_Constants.OBJ_QUOTE+' where IsSyncing = true and opportunityId IN (\''+String.join(oppIdList, '\',\'')+'\') )';
            qliList = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem',whereClause);
            opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN ( \''+String.join(oppIdList, '\',\'')+'\')');      
        }else if(quoteIdList != null && !quoteIdList.isEmpty()){
            opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') AND IsSyncing = true)');           
        }
        if(qliList != null && !qliList.isEmpty()){
            opliToUpdateList = QLItoOLIMapping(QLItoOLIMappingLst,qliList,opliQueriedList,oppIdSet);
        }
        if(!opliToUpdateList.isEmpty()){
            //REN_Util.resetTriggersTo(false);
            REN_OpportunityDataAccess.calculateExpQuarterYear(opliToUpdateList,'REN_End_Date__c');
            REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(opliToUpdateList, toFldSet);
            REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdSet,false);     
        }
         return opliQueriedList;
    }
    
    /*
    @ Description: Whenever Quote is created from Apex, and its gets sync to Opportunity, then OpportunityLineitems gets deleted and reinserted.
    @              Due to this Renewal Relationship records lost the correct product id.    
    @              Below method will update the product id on Renewal relationship records with the Original Product Id (of OpportunityLineItems) after Quote sync.
    @              This method will also Update the field values on the OpportunityLineItem during sync, based on the mapping defined in the "quote - Opportunity" mapping.
    */
    public static void handleOLIrecreation(Set<Id> opptyIdSet){
        List<String> oppIdList = new List<String>();
        oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opptyIdSet), List<String>.class));
        Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'};
        Set<String> oliFldstoQuery = new Set<String> {'Id','TotalPrice','OpportunityId'};
        List<REN_Field_Mappings__c> QLItoOLIMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_QUOTE_TO_OPPTY, REN_Constants.OBJ_OPPTY_LINE_ITEM, CHL_Constants.OBJ_QUOTELINEITEM);
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<Id> oppIdSet =new Set<Id>();
        REN_Util.getFromAndToFldsToQuery(QLItoOLIMappingLst,frmFldSet,toFldSet);
        qliFldstoQuery.addAll(frmFldSet);
        oliFldstoQuery.addAll(toFldSet);
        String whereClause = 'QuoteId IN (select Id from '+CHL_Constants.OBJ_QUOTE+' where IsSyncing = true and opportunityId IN (\''+String.join(oppIdList, '\',\'')+'\') )';
        List<Sobject> qliList = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem',whereClause);
        if(qliList != null && !qliList.isEmpty()){
            Map<ID,ID> originalIDToNewIDMap = new Map<ID,ID>();
            List<OpportunityLineItem> opliToUpdateList = new List<OpportunityLineItem>();
            ID originalID ;
            ID syncedID ;
            OpportunityLineItem opli;
            List<OpportunityLineItem> opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN ( \''+String.join(oppIdList, '\',\'')+'\')');
            Map<Id, OpportunityLineItem> oppLineMap = new Map<Id, OpportunityLineItem>(opliQueriedList); 
            
            if(qliList != null && !qliList.isEmpty()){
                opliToUpdateList = QLItoOLIMapping(QLItoOLIMappingLst,qliList,opliQueriedList,oppIdSet);
                if(!opliToUpdateList.isEmpty()){
                    REN_Util.resetTriggersTo(false);
                    //REN_OpportunityDataAccess.calculateExpQuarterYear(opliToUpdateList,'REN_End_Date__c');
                    REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(opliToUpdateList, toFldSet);
                    REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdSet,false);
                }
            }
        }
    }
    
    /*
    @ Description: Below method will handle Quote updation during (before) sync, 
    @              If any Quote is updated and if it gets sync with opportunity then,
    @              it should Update the field values on the Opportunity based on the mapping defined in the "Quote - Opportunity" mapping.
    */
    public static void onSyncUpdateOpportunity(Set<String> quoteIdSet, List<Opportunity> opptyRecords, Map<Id, Opportunity>opportunityMap) {
        List<String> quoteIdList = new List<String>(quoteIdSet);
        List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                        Label.REN_LBL_QUOTE_TO_OPPTY, 'Opportunity', CHL_Constants.OBJ_QUOTE);
        if(fieldMappingListQuoteToOppty == null || fieldMappingListQuoteToOppty.isEmpty()){
            return;
        }
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        REN_Util.getFromAndToFldsToQuery(fieldMappingListQuoteToOppty,frmFldSet,toFldSet);
        Set<String> quoteFldstoQuery = new Set<String> {'Id','OpportunityId','IsSyncing',CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c',CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c','GrandTotal'};
        quoteFldstoQuery.addall(frmFldSet);
        List<sobject> quoteList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,'Quote','Id IN ( \''+String.join(quoteIdList, '\',\'')+'\')');
        List<Opportunity> opportunityListToProcess = CHL_Util.getObjectListByWhereClause(toFldSet,'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') )');         
        List<Opportunity> opptyListToUpdate = QuoteToOpportunityMapping(fieldMappingListQuoteToOppty,opportunityListToProcess,quoteList);
        if(!opptyListToUpdate.isEmpty()) {
            //postQuoteSyncingUpdate = true;
            REN_OpportunityDataAccess.updateOpportunityforRenewals(opptyListToUpdate);  
        }
        if(quoteList != null && !quoteList.isEmpty()) {
            handlePOUpdationOnQuoteSync(opportunityMap, quoteList);                     
        }
    }
    
    /*  Below method is created for US1757, It will handle when new OLIs are added on Oppty when Quote is synced with Oppty.
    */
    public static void calculateRRMetricsOnPO(Set<Id> opptyIdSet) {
        if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
            List<String> oppIdList = new List<String>();
            String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
            oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opptyIdSet), List<String>.class));
            Set<String> requestedFields =new Set<String>{'SyncedQuoteId','REN_AddsAmount__c'};
            if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +SSL_ZTH_COMMIT_LEVEL)) {
                requestedFields.add(solnExtnNamespace+SSL_ZTH_COMMIT_LEVEL);
            }
            if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE)) {
                 requestedFields.add(solnExtnNamespace+SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE);
            }
            List<Opportunity> opptyList = CHL_Util.getObjectListByWhereClause(requestedFields,'Opportunity','Id IN ( \''+String.join(oppIdList, '\',\'')+'\') AND SyncedQuoteId != null');
            Map<Id,sObject>quoteToMOMap = new Map<Id,Sobject>();
            for(sObject opp:opptyList) {
                if(opp.get('SyncedQuoteId') != null) {
                    quoteToMOMap.put((Id)opp.get('SyncedQuoteId'),opp);             
                }
            }
            if(quoteToMOMap != null && !quoteToMOMap.isEmpty()) {   
                handleRRCalculation(quoteToMOMap);
            }
        }
    }
    
    
    
    public static List<Sobject> resetPrimaryForQuotes(set<Id> primaryQuoteIdSet, set<Id>poIds) {
        List<sObject> resetQuoteList = new List<sobject>();
        String whereCondition = 'AND '+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c = true';
        if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c')) {
            for(sObject qObj : CHL_QuoteDataAccess.getQuotesForPO(primaryQuoteIdSet,poIds,whereCondition)) {
                qObj.put(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c',false); 
                if((boolean)qObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c') == true) {
                    qObj.put(CHL_Util.quoteExtnNameSpace+'CHL_Reseller_Primary__c',false); 
                }
                resetQuoteList.add(qObj);
            }
        }
        return resetQuoteList;      
    }
    
    public static List<Sobject> resetResellerPrimaryForQuotes(set<Id> resellerQuoteIdSet, set<Id>poIds) {
        List<sObject> resetQuoteList = new List<sobject>();
        String whereCondition = 'AND '+CHL_Util.quoteExtnNameSpace+'CHL_Reseller_Primary__c = true';
        if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_Reseller_Primary__c')) {
            for(sObject qObj : CHL_QuoteDataAccess.getQuotesForPO(resellerQuoteIdSet,poIds,whereCondition)) {
                qObj.put(CHL_Util.quoteExtnNameSpace+'CHL_Reseller_Primary__c',false); 
                resetQuoteList.add(qObj);
            }
        }
        return resetQuoteList;      
    }
    
    /*
    @ Description: Below method will be used to return the updated list of OpportunityLineItem list.
    @              It will copy field values from QLI to OLI based on Quote - Opportunity mapping which gets passed to method.
    */  
    @TestVisible    
    public static List<OpportunityLineItem> QLItoOLIMapping(List<REN_Field_Mappings__c> QLItoOLIMappingLst,List<Sobject> qliList,List<OpportunityLineItem> opliList, set<Id> oppIdSet){
        
        List<OpportunityLineItem> opliToUpdateList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oppLineMap = new Map<Id, OpportunityLineItem>(opliList); 
        Map<String, Schema.SobjectField> fieldDefinition = CSM_AccessController.fetchAllFieldNames(new OpportunityLineItem().getSobjectType());
        OpportunityLineItem opli;
        ID syncedID;
        for(Sobject qli : qliList){
            syncedID = (ID)qli.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c');
            opli = oppLineMap.get(syncedID);
            if(oppLineMap.containsKey(syncedID)){
                REN_Util.copyObjectUsingAdminMapping(qli, opli, fieldDefinition, QLItoOLIMappingLst);
                opliToUpdateList.add(opli);
                oppIdSet.add(opli.OpportunityId);
            }
        }
        system.debug(' opliToUpdateList : '+opliToUpdateList);
        return opliToUpdateList;
    }
    
    /*
    @ Description: Below method will be used to return the updated list of QuoteLineItem list.
    @              It will copy field values from OLI to QLI based on Opportunity - Quote mapping which gets passed to method.
    */
    public static List<Sobject> OLItoQLIMapping(List<REN_Field_Mappings__c> OLItoQLIMappingLst,List<Sobject> qliList,List<OpportunityLineItem> opliList){
        String syncedID ;
        Sobject qli;
        List<Sobject> qliToUpdateList = new List<Sobject>();
        Schema.SObjectType objectQuoteLineItem = CSM_AccessController.getObjectType(CHL_Constants.OBJ_QUOTELINEITEM);
        Map<String, Schema.SobjectField> fieldDefinition = CSM_AccessController.fetchAllFieldNames(objectQuoteLineItem);
        Map<String, Sobject> quoteLineMap = new Map<String, Sobject>();
        
        for(Sobject quoteli : qliList){
            if(quoteli.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c')!= null){
                quoteLineMap.put((String)quoteli.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'),quoteli);
            }
        }   
        
        for(OpportunityLineItem opli : opliList){
            syncedID = opli.id;
            if(quoteLineMap.containsKey(syncedID)){
                qli = quoteLineMap.get(syncedID);
                if(OLItoQLIMappingLst != null & !OLItoQLIMappingLst.isEmpty()){
                    REN_Util.copyObjectUsingAdminMapping(opli,qli ,fieldDefinition, OLItoQLIMappingLst);
                }
                qliToUpdateList.add(qli);
            }
        }
        return qliToUpdateList;
    }
    
    /*
    @ Description: Below method will be used to return the updated list of Quote list.
    @              It will copy field values from Opportunity to Quote based on Opportunity - Quote mapping which gets passed to method.
    */
    public static List<sObject> OpptyToQuoteMapping(List<REN_Field_Mappings__c> fieldMappingListOpptyToQuote,List<Sobject> newRecords,List<Opportunity> opportunityList, boolean useDefaultMappingMethod){
        Map<String,Opportunity> opportunityMap = new Map<String,Opportunity>(opportunityList);
        List<sObject> quoteList = new List<sObject>();
        Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject();
        Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(quoteObj.getSobjectType());      
        for(sObject sObj: newRecords) {
            if(opportunityMap.containsKey((String)sObj.get(CHL_Constants.STR_OPPOTUNITYID))) {
                Opportunity opptyObj = opportunityMap.get((String)sObj.get(CHL_Constants.STR_OPPOTUNITYID));    
                if(useDefaultMappingMethod == true) {                           
                    REN_Util.copyObjectUsingAdminMapping(opptyObj, sObj, fieldDesctiptionMap, fieldMappingListOpptyToQuote);
                } else {
                    CHL_Util.copyObjectUsingAdminMapping(opptyObj, sObj, fieldDesctiptionMap, fieldMappingListOpptyToQuote);
                }
                quoteList.add(sObj);
            }
        }
        return quoteList;
    }
    
    /*
    @ Description: Below method will be used to return the updated list of Opportunity list.
    @              It will copy field values from Quote to Opportunity based on Quote - Opportunity mapping which gets passed to method.
    */
    @TestVisible
    public static List<Opportunity> QuoteToOpportunityMapping(List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty,List<Opportunity> opportunityList,List<Sobject> newRecords) {
        Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(new Opportunity().getSobjectType());
        Map<String,sObject> mapOfSyncedQuote = new Map<String,sObject>();
        List<Opportunity> optyListToUpdate = new List<Opportunity>();
        for(sObject quoteObj:newRecords) {
            mapOfSyncedQuote.put((String)quoteObj.get(CHL_Constants.STR_OPPOTUNITYID),quoteObj);
        }
        for(Opportunity oppty: opportunityList) {
            if(mapOfSyncedQuote.containsKey(oppty.Id)) {
                sObject quoteSObj = mapOfSyncedQuote.get(oppty.Id);
                REN_Util.copyObjectUsingAdminMapping(quoteSObj, oppty, fieldDesctiptionMap, fieldMappingListQuoteToOppty);
                optyListToUpdate.add(oppty);
            }
        }
        return optyListToUpdate;
    }
    
    /*
    @Description: Below method is created as part of US1059.
    @             Below method will copy partner opportunity field details to Quote 
    */
    @TestVisible
    public static List<Sobject> copyPartnerOptyDetails(Map<Id,sObject> partnerOpptyToQuoteMap) {
        
        List<SObject> quoteListforPODetails = new List<SObject>();
        List<CHL_Partner_Opportunity__c> poList;
        
        if(!partnerOpptyToQuoteMap.isEmpty()){
            poList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(partnerOpptyToQuoteMap.keySet());
            for(CHL_Partner_Opportunity__c partnerOppObj : polist) {
                if(partnerOpptyToQuoteMap.containskey(partnerOppObj.Id)) {
                    sObject quoteSObj = partnerOpptyToQuoteMap.get(partnerOppObj.Id);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1__c', partnerOppObj.CHL_Partner_Account_1__c);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c', partnerOppObj.CHL_Partner_Account_1_Type__c);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Contact__c', partnerOppObj.CHL_Partner_Account_1_Contact__c);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Incumbent__c', partnerOppObj.CHL_Incumbent__c);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2__c', partnerOppObj.CHL_Partner_Account_2__c);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c', partnerOppObj.CHL_Partner_Account_2_Type__c);
                    quoteSObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Contact__c', partnerOppObj.CHL_Partner_Account_2_Contact__c);
                    quoteListforPODetails.add(quoteSObj);
                }
            }
        }
        return quoteListforPODetails;
    }
    
    
    
    /*
    @Description: Calculate the MSRP of the master Quote object.
    */
    public static void rollupMsrpOnQuote(Set<String> quoteIdSet) {       
        rollupMsrpOnQuote(quoteIdSet, 10000);
    }
    
    public static void rollupMsrpOnQuote(Set<String> quoteIdSet, Integer qliRecordLimit) {       
        //retrieve the sum of all msrp from the quote line item records
        List<String> quoteIdList = new List<String>(quoteIdSet);
        Map<Id,Decimal> quoteMSRP = new Map<Id,Decimal>();    
        List<Sobject> quotesToUpdate = new List<Sobject>();  
       //retrieve the quote Line records for the given quote list
       Boolean hasMSRPFieldOnQuote = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);
       Set<String> fieldsToQuery = new Set<String> {'Id', 'QuoteId'};
       if(hasMSRPFieldOnQuote) {
       	fieldsToQuery.add(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP);	
       }
        Map<Id, sObject> quoteLineMap = CHL_Util.getObjectMapByWhereClause(fieldsToQuery,'QuoteLineItem', 
            'QuoteId IN ( \''+String.join(quoteIdList, '\',\'')+'\') ', qliRecordLimit);       
        if(quoteLineMap != null && !quoteLineMap.isEmpty()){
        	Decimal QLIMSRP = 0;  
        	if(hasMSRPFieldOnQuote) {         
            for(Sobject qLi: quoteLineMap.values()){
                QLIMSRP = (Decimal)qLi.get(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP); 
                QLIMSRP = (QLIMSRP == null ? 0 : QLIMSRP);
                if(quoteMSRP.containsKey((Id)qLi.get('QuoteId')))
                quoteMSRP.put((Id)qLi.get('QuoteId'), quoteMSRP.get((Id)qLi.get('QuoteId'))+QLIMSRP);
                else
                quoteMSRP.put((Id)qLi.get('QuoteId'),QLIMSRP);
            }           
            for(Id quoteID:quoteMSRP.keySet()){ 
                Sobject quoteSobj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject();
                quoteSobj.put('id',quoteID);
                quoteSobj.put(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP,quoteMSRP.get(quoteId));
                quotesToUpdate.add(quoteSobj);
            }   
        	}         
            CHL_QuoteDataAccess.updateQuotes(quotesToUpdate);
        } 
    }
    //US1475
    public static void handlePOUpdation(Map<Id,Decimal>partnerOptyIdToAmount, Map<Id,Decimal>partnerOptyTOMSRP, List<CHL_Partner_Opportunity__c> partnerOptyList) {
        /*
            CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
            CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
            CHL_PartnerOpportunityGridUpdate.updateQuoteAmountOnPO(partnerOptyIdToAmount,partnerOptyTOMSRP);
            if (partnerOptyList!= null && !partnerOptyList.isEmpty() && Limits.getQueueableJobs() == 0) {
                ID jobID = System.enqueueJob(new CHL_QuoteSyncQueueableJob(partnerOptyList));
            }
        */  
    }
    
            
    
    
    /*  Below method will handle QLI Creation when simplified data model is ON.
        Method will copy OLI field values to QLI based on synced quote ID. It will use OLI to QLI(Opportunity -> Quote) mapping to copy custom field values..
    */
    public static Set<String> handleSimplifiedQLICreation(Set<Id> quoteIdSet, Set<Id> qliIdSet, Map<Id, sObject> quotesMap, Map<Id, Opportunity> opportunityMap){
        List<String> quoteIdList = new List<String>();      
        List<String> qliIdList = new List<String>();
        quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteIdSet), List<String>.class));
        qliIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(qliIdSet), List<String>.class));
        ID syncedID ;
        OpportunityLineItem opli;
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<String> qualifiedQuoteIds = new Set<String>();
        Set<String> oliFldstoQuery = new Set<String> {'Id','PricebookEntryId','Quantity','SubTotal','OpportunityId'};
        List<REN_Field_Mappings__c> fieldMappingListOLIToQLI = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                            Label.REN_LBL_OPPTY_TO_QUOTE,CHL_Constants.OBJ_QUOTELINEITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM);
        REN_Util.getFromAndToFldsToQuery(fieldMappingListOLIToQLI,frmFldSet,toFldSet);              
        oliFldstoQuery.addall(frmFldSet);                               
        List<OpportunityLineItem> opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') )');
        String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        if(opliQueriedList != null && !opliQueriedList.isEmpty()) {
            Map<Id, OpportunityLineItem> oppLineMap = new Map<Id, OpportunityLineItem>(opliQueriedList); 
            Sobject quoteLineItemObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
            Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(quoteLineItemObj.getSobjectType());          
            Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId','Quantity',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'};
            qliFldstoQuery.addall(toFldSet);                
            List<sObject> qliListToUpdate = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem','Id IN ( \''+String.join(qliIdList, '\',\'')+'\') ');
            //List<sObject> qliListToUpdate = new List<sObject>();
            for(Sobject sobj:qliListToUpdate) {
                syncedID = (ID)sobj.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c');    
                if(oppLineMap!= null && oppLineMap.containskey(syncedID))   {           
                    opli = oppLineMap.get(syncedID);
                    REN_Util.copyObjectUsingAdminMapping(opli, sobj, fieldDesctiptionMap, fieldMappingListOLIToQLI); //qliListToUpdate.add(
                }
                if((Decimal)sobj.get(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP) != null){
                    qualifiedQuoteIds.add((Id)sobj.get('QuoteId'));
                }
                if(quotesMap != null && !quotesMap.isEmpty() && opportunityMap!= null && !opportunityMap.isEmpty()) {
                    sObject quoteObj = quotesMap.get((Id)sobj.get('QuoteId'));
                    Opportunity oppObj = opportunityMap.get((Id)quoteObj.get('OpportunityId'));
                    if(sobj.get(solnExtNamespace+'Local_Currency_Amount__c') != null && quoteObj.get(solnExtNamespace+'Local_Currency_Code__c') != null && sObj.get(solnExtNamespace+'Local_Currency_Amount__c') != 0){
                        Decimal unitPrice = REN_CurrencyExchangeRateDataAccess.acmCurrencyConversion(
                                            (Decimal)sobj.get(solnExtNamespace+'Local_Currency_Amount__c'), 
                                            (String)quoteObj.get(solnExtNamespace+'Local_Currency_Code__c'), 
                                            (String)quoteObj.get('CurrencyIsoCode'),
                                            (oppObj == null ? null : oppObj.CloseDate));                        
                        if(unitPrice != null){                      
                            Decimal totalAmount = (Decimal)sobj.get(solnExtNamespace+'Local_Currency_Amount__c') * (Decimal)sobj.get('Quantity');
                            sobj.put('UnitPrice',unitPrice);
                            sobj.put(solnExtNamespace+'Local_Currency_Line_Total__c',totalAmount);
                            //qliListToUpdate.add(sobj);
                        }
                    }
                }
            }       
            if(qliListToUpdate != null && !qliListToUpdate.isEmpty()) { 
                Set<String> qliFieldsSet = new Set<String> {'Id','Quantity'}; 
                CHL_QuoteLineItemDataAccess.updateQuoteLineItem(qliFieldsSet,qliListToUpdate);
            }
        }
        return qualifiedQuoteIds;
    }
    /*
    @ Description: Below method will handle RR Updation for Simified data model.
    @   Whenever Quote is created from Apex, and its gets sync to Opportunity, then OpportunityLineitems gets deleted and reinserted.
    @   Due to this Renewal Relationship records lost the correct product id. 
    @   Below method will update the product id on Renewal relationship records with the OLI Id based on Renewal flag of OLI.
    @   Tis method will also Update the field values on the OpportunityLineItem during sync, based on the mapping defined in the "quote - Opportunity" mapping.
    */
    public static void handleSimplifiedOLIrecreation(Set<Id> opptyIdSet){
        List<String> oppIdList = new List<String>();
        oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opptyIdSet), List<String>.class));
        Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'};
        Set<String> oliFldstoQuery = new Set<String> {'Id','TotalPrice','OpportunityId','REN_Is_CLM_Renewal__c'};
        List<REN_Field_Mappings__c> QLItoOLIMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_QUOTE_TO_OPPTY, REN_Constants.OBJ_OPPTY_LINE_ITEM, CHL_Constants.OBJ_QUOTELINEITEM);
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<Id> oppIdSet =new Set<Id>();
        REN_Util.getFromAndToFldsToQuery(QLItoOLIMappingLst,frmFldSet,toFldSet);
        qliFldstoQuery.addAll(frmFldSet);
        oliFldstoQuery.addAll(toFldSet);
        String whereClause = 'QuoteId IN (select Id from '+CHL_Constants.OBJ_QUOTE+' where  opportunityId IN (\''+String.join(oppIdList, '\',\'')+'\') AND IsSyncing = true)';
        List<Sobject> qliList = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem',whereClause);
        if(qliList != null && !qliList.isEmpty()){
            List<OpportunityLineItem> opliToUpdateList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId IN ( \''+String.join(oppIdList, '\',\'')+'\')');
            opliToUpdateList = QLItoOLIMapping(QLItoOLIMappingLst,qliList,opliQueriedList,oppIdSet);
            if(!opliToUpdateList.isEmpty()){
                REN_Util.resetTriggersTo(false);
                REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(opliToUpdateList, toFldSet);
                REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdSet,false);
            }
        }
    }
    
    public static void handleQuotePrimaryOnSync(List<sObject> quoteList, Set<Id> poIdSet) {
        
    }
    
    public static list<sObject> handleQuotePrimary(List<sObject> quoteList, Set<Id> poIdSet) {
        boolean is2TierEnabled = false;
        SObject resellerQuote;
        SObject distributorQuote;
        Set<Id> primaryQuoteIdSet = new Set<Id>();
        Set<Id> resellerQuoteIdSet = new Set<Id>();
        List<sObject> quoteListToUpdate = new List<sObject>();
        List<sObject> quoteListToResetPrimary = new List<sObject>();
        Map<Id, Id> resellerToDistributorQuoteMap = new Map<Id, Id>();
        Set<Id> partnerOpptyToSync = new Set<Id>();
        Id distributorQuoteId;
        List<sObject> distributorQuoteList = new List<sObject>();
        
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
            is2TierEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
        }
        List<sObject> parnetOpptyQuoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIdSet, false);
        Map<Id, sObject> partnerOpptyQuotesMap = new Map<Id, sObject>(parnetOpptyQuoteList);
        for(SObject poquoteObj : parnetOpptyQuoteList){
            if((Id)poquoteObj.get(CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c') != null) {
                resellerToDistributorQuoteMap.put((Id)poquoteObj.get(CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c'), (Id)poquoteObj.get('Id'));
            }
        }
        for(SObject quoteObj : quoteList){
            if(is2TierEnabled) {
                if((boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c') == true) {
                    if((Boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == false) {
                        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c', true);
                        primaryQuoteIdSet.add((Id)quoteObj.get('Id'));
                        quoteListToUpdate.add(quoteObj);
                    }
                    if(partnerOpptyQuotesMap.ContainsKey((Id)quoteObj.get(CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c'))) {
                        resellerQuote = partnerOpptyQuotesMap.get((Id)quoteObj.get(CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c'));
                        if((Boolean)resellerQuote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c') == false) {
                            resellerQuote.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c', true);
                            resellerQuoteIdSet.add((Id)quoteObj.get(CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c'));
                            quoteListToUpdate.add(resellerQuote);
                        }
                    }
                } else if((boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c') == false) {
                    distributorQuoteId = resellerToDistributorQuoteMap.containsKey((Id)quoteObj.get('Id')) ? resellerToDistributorQuoteMap.get((Id)quoteObj.get('Id')) : null;
                    //system.debug('IN D ELSE IF :: '+distributorQuoteId);
                    if(distributorQuoteId == null && (Boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == false) {
                        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c', true);
                        primaryQuoteIdSet.add((Id)quoteObj.get('Id'));
                        if((Boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c') == false) {
                            resellerQuoteIdSet.add((Id)quoteObj.get('Id'));
                            quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c', true);
                        }
                        quoteListToUpdate.add(quoteObj);
                    } else if(distributorQuoteId != null) {
                        distributorQuote = partnerOpptyQuotesMap.get(distributorQuoteId);
                        partnerOpptyToSync.add((Id)distributorQuote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'));
                        distributorQuoteList.add(distributorQuote);
                        if((Boolean)distributorQuote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == false){
                            primaryQuoteIdSet.add((Id)quoteObj.get('Id'));
                            distributorQuote.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c', true);
                            quoteListToUpdate.add(distributorQuote);
                        }
                        if((Boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c') == false) {
                            quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c', true);
                            resellerQuoteIdSet.add((Id)quoteObj.get('Id'));
                            quoteListToUpdate.add(quoteObj);
                        }
                    }
                }
            } else {
                if((Boolean)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == false) {
                    quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c', true);
                    primaryQuoteIdSet.add((Id)quoteObj.get('Id'));
                    quoteListToUpdate.add(quoteObj);
                }
            }
        }
        system.debug('primaryQuoteIdSet :: '+primaryQuoteIdSet+'\n :: '+resellerQuoteIdSet);
        if(primaryQuoteIdSet != null && !primaryQuoteIdSet.isEmpty()) {
            quoteListToResetPrimary = resetPrimaryForQuotes(primaryQuoteIdSet, poIdSet);
        }
        if(resellerQuoteIdSet != null && !resellerQuoteIdSet.isEmpty()) {
            List<sObject> quoteListToResetResellerPrimary = resetResellerPrimaryForQuotes(resellerQuoteIdSet, poIdSet);
            for(sObject sQuote :quoteListToResetPrimary) {
                for (Integer i = quoteListToResetResellerPrimary.size() - 1; i >= 0 ; --i) {
                    if(quoteListToResetResellerPrimary.get(i).get('id') == sQuote.get('id')){
                        quoteListToResetResellerPrimary.remove(i);
                        break;
                    }
                }
            }
            quoteListToResetPrimary.addall(quoteListToResetResellerPrimary);
        }
    //system.debug('quoteListToResetPrimary :: '+quoteListToResetPrimary);
        for(sObject sQuote :quoteListToUpdate) {
            for (Integer i = quoteListToResetPrimary.size() - 1; i >= 0 ; --i) {
                if(quoteListToResetPrimary.get(i).get('id') == sQuote.get('id')){
                    quoteListToResetPrimary.remove(i);
                    break;
                }
            }
        }
        quoteListToUpdate.addall(quoteListToResetPrimary);
        //List<sObject> listToUpdateResellerPrimary = resetResellerPrimaryForQuotes(primaryResellerIds,poIdSet);
        if(quoteListToUpdate != null && !quoteListToUpdate.isEmpty()) {
            system.debug('quoteListToUpdate SYNC : '+quoteListToUpdate);
            CHL_QuoteDataAccess.updateQuotes(quoteListToUpdate); 
        }
        
        if(isQuoteSyncNeeded && !partnerOpptyToSync.isEmpty() && partnerOpptyToSync != null) {
            List<CHL_Partner_Opportunity__c> partnerOptyList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(partnerOpptyToSync);
            if (partnerOptyList!= null && !partnerOptyList.isEmpty() && Limits.getQueueableJobs() == 0) {
                ID jobID = System.enqueueJob(new CHL_QuoteSyncQueueableJob(partnerOptyList));
            }
        }
        return distributorQuoteList;
    }
    
    public static void handleQLI_OLIUpdate(Set<Id> opptyIdSet, List<OpportunityLineItem> oliList, Set<String> quoteIdSet){
        List<String> oppIdList = new List<String>();
        List<String> quoteIdList = new List<String>(quoteIdSet);
        oppIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opptyIdSet), List<String>.class));
        Set<String> qliFldstoQuery = new Set<String> {'Id','QuoteId',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'};
        //Set<String> oliFldstoQuery = new Set<String> {'Id','TotalPrice','OpportunityId','REN_Is_CLM_Renewal__c'};
        List<REN_Field_Mappings__c> QLItoOLIMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('OpportunityLineItem', 'QuoteLineItem');
        Set<String> frmFldSet = new Set<String>();
        Set<String> toFldSet = new Set<String>();
        Set<Id> oppIdSet =new Set<Id>();
        REN_Util.getFromAndToFldsToQuery(QLItoOLIMappingLst,frmFldSet,toFldSet);
        qliFldstoQuery.addAll(frmFldSet);
        //oliFldstoQuery.addAll(toFldSet);
        //String whereClause = 'QuoteId IN (select Id from '+CHL_Constants.OBJ_QUOTE+' where  opportunityId IN (\''+String.join(quoteIdList, '\',\'')+'\') AND Id IN (\''+String.join(quoteIdList, '\',\'')+'\') )';
        List<Sobject> qliList = CHL_Util.getObjectListByWhereClause(qliFldstoQuery,'QuoteLineItem', ' QuoteId IN (\''+String.join(quoteIdList, '\',\'')+'\')');
        system.debug('qliList :: '+qliList);
        if(qliList != null && !qliList.isEmpty()){
            List<OpportunityLineItem> opliToUpdateList = new List<OpportunityLineItem>();
            opliToUpdateList = QLItoOLIMapping(QLItoOLIMappingLst, qliList, oliList, oppIdSet);
            if(!opliToUpdateList.isEmpty()){
                REN_Util.resetTriggersTo(false);
                REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(opliToUpdateList, toFldSet);
                REN_OpportunityMetricsBusiness.setOliMetricsFields(oppIdSet, false);
            }
        }
    }
    
    public with sharing class REN_QuoteWrapper {
        public Map<ID, sObject> newRecordsMap {get; set;}
        public Map<ID, sObject> oldRecordsMap {get; set;}
        public List<String> oppIdsList;
        public List<string> oppIdsWithSyncQuoteList;
        public Set<Id> quoteIdsSet;     
        public List<sObject> newRecordList;
        public List<Opportunity> optyListToUpdate;
        public Map<Id, Decimal> quoteToMsrpMap;
        public Map<Id, Decimal> quoteToAmountMap;
        public Map<Id, Decimal> quoteToAddsAmount;
        public Set<Id> opportunityIdSet;   
    }
    
    public static void rollupCountsOnQuoteFromQLI(REN_QuoteWrapper quoteWrapper) {       
        //retrieve the sum of all msrp from the quote line item records
        List<String> quoteIdList = new List<String>();
        quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteWrapper.quoteIdsSet), List<String>.class));
        Set<String> qliFldstoQuery = new Set<String> {'Id','UnitPrice','TotalPrice','QuoteId'}; 
    	Boolean hasMSRPField = CSM_AccessController.hasField('QuoteLineItem', CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c'); 
        if(CSM_AccessController.hasField('QuoteLineItem', CHL_Util.quoteExtnNameSpace + 'REN_Synced_Line_Item_ID__c')) {
        	qliFldstoQuery.add(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c');
        	qliFldstoQuery.add(CHL_Util.quoteExtnNameSpace+'CHL_Is_CLM_Renewal__c');
        	qliFldstoQuery.add(CHL_Util.quoteExtnNameSpace+'CHL_MSRP__c');
        }
       //retrieve the quote Line records for the given quote list
        Map<Id, sObject> quoteLineMap = CHL_Util.getObjectMapByWhereClause(qliFldstoQuery,'QuoteLineItem', 
            'QuoteId IN ( \''+String.join(quoteIdList, '\',\'')+'\') ');        
        quoteWrapper.quoteToMsrpMap = new Map<Id,Decimal>(); 
        quoteWrapper.quoteToAmountMap = new Map<Id,Decimal>();  
        quoteWrapper.quoteToAddsAmount = new Map<Id, Decimal>();  
        List<Sobject> quotesToUpdate = new List<Sobject>();        
        Decimal QLIMSRP = 0;
        Decimal TOTALPRICE = 0;           
        Map<Id, Id> syncedIdsMap = new Map<Id, Id>();
        if(quoteLineMap != null && !quoteLineMap.isEmpty()) {
            for(Sobject qLi: quoteLineMap.values()){
                QLIMSRP = hasMSRPField ? (Decimal)qLi.get(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP) : 0; 
                QLIMSRP = (QLIMSRP == null ? 0 : QLIMSRP);
                
                TOTALPRICE = (Decimal)qLi.get('TotalPrice'); 
                TOTALPRICE = (TOTALPRICE == null ? 0 : TOTALPRICE);
                
                if(quoteWrapper.quoteToMsrpMap.containsKey((Id)qLi.get('QuoteId'))) {
                    quoteWrapper.quoteToMsrpMap.put((Id)qLi.get('QuoteId'), quoteWrapper.quoteToMsrpMap.get((Id)qLi.get('QuoteId'))+QLIMSRP);
                } else {
                    quoteWrapper.quoteToMsrpMap.put((Id)qLi.get('QuoteId'),QLIMSRP);
                }
                
                if(quoteWrapper.quoteToAmountMap.containsKey((Id)qLi.get('QuoteId'))) {
                    quoteWrapper.quoteToAmountMap.put((Id)qLi.get('QuoteId'), quoteWrapper.quoteToAmountMap.get((Id)qLi.get('QuoteId'))+TOTALPRICE); 
                } else {
                    quoteWrapper.quoteToAmountMap.put((Id)qLi.get('QuoteId'),TOTALPRICE);    
                }
                if((Boolean)qLi.get(CHL_Util.quoteExtnNameSpace+'CHL_Is_CLM_Renewal__c') == false) {
                    if(quoteWrapper.quoteToAddsAmount.containsKey((Id)qLi.get('QuoteId'))) {
                        quoteWrapper.quoteToAddsAmount.put((Id)qLi.get('QuoteId'), quoteWrapper.quoteToAddsAmount.get((Id)qLi.get('QuoteId'))+TOTALPRICE);   
                    } else {
                        quoteWrapper.quoteToAddsAmount.put((Id)qLi.get('QuoteId'),TOTALPRICE);   
                    }
                }
            }
        } 
        for(Id quoteId : quoteWrapper.quoteIdsSet) {
            if(!quoteWrapper.quoteToMsrpMap.keySet().contains(quoteId)) {
                quoteWrapper.quoteToMsrpMap.put(quoteId,0); 
            }
            if(!quoteWrapper.quoteToAmountMap.keySet().contains(quoteId)) {
                quoteWrapper.quoteToAmountMap.put(quoteId,0);   
            }
            if(!quoteWrapper.quoteToAddsAmount.keySet().contains(quoteId)) {
                quoteWrapper.quoteToAddsAmount.put(quoteId,0);  
            }   
        }         
        if(quoteWrapper.quoteToMsrpMap != null && !quoteWrapper.quoteToMsrpMap.isEmpty()) {
            for(Id quoteID : quoteWrapper.quoteToMsrpMap.keySet()){ 
                Sobject quoteSobj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject();
                quoteSobj.put('id',quoteID);
                if(hasMSRPField) {
                	quoteSobj.put(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP,quoteWrapper.quoteToMsrpMap.get(quoteId));
                }
                quotesToUpdate.add(quoteSobj);
            }
        }
        
        CHL_QuoteDataAccess.updateQuotes(quotesToUpdate);
        
    }
    
    public static void updatePartnerOpptyFieldsFromQLI(Map<Id,sObject> poIdToQuoteMap, Map<Id, Opportunity> opportunityMap, REN_QuoteWrapper quoteWrapper) {
        
        List<CHL_Partner_Opportunity__c> partnerOpptyUpdatedList = new List<CHL_Partner_Opportunity__c>();
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;        
        Boolean hasCommitLevelField = CSM_AccessController.hasField('Opportunity', solnExtnNamespace+'Commit_Level__c');
        Boolean hasFirstQuoteCompletedField = CSM_AccessController.hasField('Opportunity', solnExtnNamespace+'First_Quote_Completed_Date__c');
        for(Id partnerOpptyId:poIdToQuoteMap.keySet()) {
            sObject quoteObj = poIdToQuoteMap.get(partnerOpptyId);  
            Id opportunityId = quoteObj != null ? (ID)quoteObj.get('OpportunityId') : null;
            CHL_Partner_Opportunity__c partnerOpptyObj = new CHL_Partner_Opportunity__c(Id = partnerOpptyId); //(Id)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')
            
            if(quoteWrapper.quoteToAmountMap != null && quoteWrapper.quoteToAmountMap.containsKey((ID)quoteObj.get('Id'))) {
                partnerOpptyObj.put('CHL_Amount__c',quoteWrapper.quoteToAmountMap.get((ID)quoteObj.get('Id')));
            }
            if(quoteWrapper.quoteToMsrpMap != null && quoteWrapper.quoteToMsrpMap.containsKey((ID)quoteObj.get('Id'))) {
                partnerOpptyObj.put('CHL_MSRP__c',quoteWrapper.quoteToMsrpMap.get((ID)quoteObj.get('Id'))); 
            }
            if (opportunityMap != null && opportunityMap.containsKey(opportunityId))    {
                Opportunity oppObj = opportunityMap.get(opportunityId);                 
                if(quoteWrapper.quoteToAddsAmount != null) {
                    partnerOpptyObj.put('CHL_AddsAmount__c', quoteWrapper.quoteToAddsAmount.get((ID)quoteObj.get('Id')));   
                }    
            }                        
            partnerOpptyUpdatedList.add(partnerOpptyObj);     
        }
        if(partnerOpptyUpdatedList != null && !partnerOpptyUpdatedList.isEmpty()) {
            CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
            CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
            CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(partnerOpptyUpdatedList);
        }
    }
    
    public static void processPartnerOpportunityList(REN_QuoteWrapper quoteWrapper, Map<Id, sObject> poIdToQuoteMap, Map<id,Opportunity> masterOpportunityMap) {
        List<String> quoteIdList = new List<String>();
        quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteWrapper.quoteIdsSet), List<String>.class));
        Set<String> quoteFldstoQuery = new Set<String> {'Id','IsSyncing','OpportunityId'}; 
        if(CSM_AccessController.hasField('QuoteLineItem', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')) {
        	quoteFldstoQuery.add(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c');
        	quoteFldstoQuery.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
        }
        Map<Id, sObject> quoteLineMap = CHL_Util.getObjectMapByWhereClause(quoteFldstoQuery,'Quote', 
            'Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') ');
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        List<Opportunity> opptyRecords = new List<sObject>();
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
        Map<id,Opportunity> opportunityIdMap = new Map<id,Opportunity>(opptyRecords);
        quoteWrapper.opportunityIdSet = opportunityIdMap.keySet();
        if(CSM_AccessController.hasField('Opportunity','SyncedQuoteId')) {
            for(SObject quoteObj : quoteLineMap.values()) {
                if(quoteObj.get('IsSyncing') == true){
                     if(opportunityIdMap != null && !opportunityIdMap.isEmpty()){
                        if(quoteWrapper.quoteIdsSet.contains((String)quoteObj.get('id'))){
                            if(String.isNotBlank((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'))) {
                                poIdToQuoteMap.put((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj );
                                masterOpportunityMap.put((id)quoteObj.get('OpportunityId'),opportunityIdMap.get((id)quoteObj.get('OpportunityId')));
                            }
                        }               
                        
                    }
                }
            }            
        }
    }
}