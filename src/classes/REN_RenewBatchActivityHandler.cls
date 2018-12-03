public with sharing class REN_RenewBatchActivityHandler{
    
    /** processBatch
            Each batch iteration will do following:
                Excluded already renewed Assets
                Excluded records for which PriceBook & Currency is not matching, add failure records.
                For each remaining Asset record:
                    Find group by key
                    If it is first time occurred - YES
                        Create Renewed Opportunity using Mapping
                        Add it is global map with key
                    Create lineItem using mapping
                    Add lineItem under Opportunity against find Key 
                Save Opportunities & LineItems.
                Note: In case of any error found, log Asset record as failure
    */
	public static Map<Id,REN_Renews_To__c> olidToRliMap {get;set;}
	
    public static void processBatch(List<REN_Batch_Activity__c> batchActivityList, List<Asset> assetList, Set<String> groupingFieldsSet, List<REN_Field_Mappings__c> asset2OppFMapping, List<REN_Field_Mappings__c> asset2ProductFMapping, Map<String, Opportunity> allRenewedOpportunityMap){
        Map<String, Opportunity> renewedOpportunityMap = new Map<String, Opportunity>();
        Map<ID, Asset> assetIdMap = new Map<ID, Asset>(assetList);
        Map<String, List<OpportunityLineItem>> renewedOpportunityProductsMap = new Map<String, List<OpportunityLineItem>>();
        Map<String, List<Asset>> assetKeyMap = new Map<String, List<Asset>>();
        List<REN_Batch_Opportunity_Failure__c> failureAssetList = new List<REN_Batch_Opportunity_Failure__c>();
        Map<String, PricebookEntry> currencyProductPricebookEntryMap = new Map<String, PricebookEntry> ();
        
        List<Asset> filteredAssetList = getValidAssetList(batchActivityList, assetList, currencyProductPricebookEntryMap, failureAssetList);
    
        if(filteredAssetList.isEmpty()){
            if(!failureAssetList.isEmpty()){
                REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
                batchActivityList[0].REN_Failure_Assets__c += failureAssetList.size();
            }
            return;
        }

        Map<String, Schema.SobjectField> oppFieldDefinition = CSM_AccessController.fetchAllFieldNames(new Opportunity().getSobjectType());
        Map<String, Schema.SobjectField> oliFieldDefinition  = CSM_AccessController.fetchAllFieldNames(new OpportunityLineItem().getSobjectType());
        boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        List<Asset> assetOppList = new List<Asset>();
        for(Asset assetObj : filteredAssetList){
            //System.debug('\n\n~~~~assetObj: ' + assetObj);
            OpportunityLineItem oli = new OpportunityLineItem();
            
            String key = isMultiCurrency? assetObj.get('CurrencyIsoCode') + '' + assetObj.product2Id : assetObj.product2Id;
            if(currencyProductPricebookEntryMap.containsKey(key)){
                oli.PricebookEntryId = currencyProductPricebookEntryMap.get(key).id;
            }
            oli.REN_Is_CLM_Renewal__c = true;
            //oli.REN_Original_Line_Item_ID__c='';
            String oppGroupKey = REN_RenewBatchActivityHandler.createProductReturnKey(batchActivityList, assetObj, oli, groupingFieldsSet, asset2ProductFMapping, failureAssetList, oliFieldDefinition);
            if(String.isBlank(oppGroupKey)){
                continue;
            }
            if(!allRenewedOpportunityMap.containsKey(oppGroupKey)){
                assetOppList = new List<Asset>();
                assetOppList.add(assetObj);
                Opportunity rOpportunity = REN_RenewBatchActivityHandler.createRenewalOpportunity(batchActivityList, assetOppList, asset2OppFMapping, failureAssetList, oppFieldDefinition);
                if(rOpportunity == null){
                    continue;
                }
                allRenewedOpportunityMap.put(oppGroupKey, rOpportunity);
                renewedOpportunityMap.put(oppGroupKey, rOpportunity);
            }
            if(!renewedOpportunityProductsMap.containsKey(oppGroupKey)){
                renewedOpportunityProductsMap.put(oppGroupKey, new List<OpportunityLineItem>());
                assetKeyMap.put(oppGroupKey, new List<Asset>());
            }
            renewedOpportunityProductsMap.get(oppGroupKey).add(oli);
            assetKeyMap.get(oppGroupKey).add(assetObj);
        }
        List<Opportunity> oppList = renewedOpportunityMap.values();
        List<Opportunity> oppListToCreate = new List<Opportunity>(oppList);
        //System.debug(oppListToCreate.size() + '\n\n1 Save oppListToCreate~~~~: ' + oppListToCreate);
        if(!oppListToCreate.isEmpty()){
            List<Database.SaveResult> queryResultList = REN_OpportunityDataAccess.insertOpportunityReturnSaveResult(oppListToCreate);
            if(queryResultList != null){
                for(Integer i=0;i<queryResultList.size();i++){
                    if (queryResultList.get(i).isSuccess()){
                        oppList[i].id = oppListToCreate[i].id;
                    }else{
                        Database.Error error = queryResultList.get(i).getErrors().get(0);
                        oppList.get(i).Description = error.getMessage();
                    }
                }
            }
        }
         
        //System.debug(oppList + '\n\n1.1 Save renewedOpportunityMap~~~~: ' + renewedOpportunityMap);
        //System.debug(allRenewedOpportunityMap.size() + '\n\n1.2 Save renewedOpportunityMap~~~~: ' + allRenewedOpportunityMap);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<Asset> renewableAssetList = new List<Asset>();
        if(!renewedOpportunityProductsMap.isEmpty()){
            for(String key: renewedOpportunityProductsMap.keySet()){
                Opportunity rOpportunity = allRenewedOpportunityMap.get(key);
                for(Integer i = renewedOpportunityProductsMap.get(key).size()-1; i >= 0 ; i--){
                    //System.debug(key + ':-' + i + '\n\n1.2 Save renewedOpportunityMap~~~~: ' + renewedOpportunityProductsMap.get(key));
                    if(renewedOpportunityProductsMap != null && renewedOpportunityProductsMap.containsKey(key)){
                        OpportunityLineItem p = renewedOpportunityProductsMap.get(key)[i];
                        if(p != null){
                            if(rOpportunity.id != null){
                                p.OpportunityId = rOpportunity.id;  
                                oliList.add(p);
                                renewableAssetList.add(assetKeyMap.get(key)[i]);
                            }else{
                                if(rOpportunity.Description != null){
                                    failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetKeyMap.get(key)[i].Id, REN_Batch_Activity__c = batchActivityList[0].id, REN_Failure_Message__c = rOpportunity.Description));
                                }else{
                                    failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetKeyMap.get(key)[i].Id, REN_Batch_Activity__c = batchActivityList[0].id, REN_Failure_Message__c = 'Unknown Error'));
                                }
                                renewedOpportunityProductsMap.get(key).remove(i);
                                allRenewedOpportunityMap.remove(key);
                                renewedOpportunityMap.remove(key);
                            }
                        }
                    }                   
                }
            }
            //System.debug(oliList.size() + '\n\n2 Save oliList~~~~: ' + oliList);
            
            Map<ID, OpportunityLineItem> asset2OliMap = new Map<ID, OpportunityLineItem>();
            Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>();
            List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
            if(!oliList.isEmpty()){
                REN_OpportunityDataAccess.calculateExpQuarterYear(oliList,CSM_Util.getNameSpace()+ REN_Constants.OBJ_OPPLN_END_DATE);
                List<Database.SaveResult> queryResultList = REN_OpportunityLineItemDataAccess.insertOppLineItem(oliList);
                if(queryResultList != null){
                    for(Integer i=0;i<queryResultList.size();i++){
                        if (queryResultList.get(i).isSuccess()){
                            asset2OliMap.put(renewableAssetList[i].id, oliList[i]);
                            oppLineItemMap.put(oliList[i].id, oliList[i]);
                            //oliList[i].REN_Original_Line_Item_ID__c = oliList[i].Id;
                            oliToUpdate.add(oliList[i]);
                        }else{
                            Database.Error error = queryResultList.get(i).getErrors().get(0);
                            String msg = error.getMessage();
                            failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = renewableAssetList[i].Id, REN_Batch_Activity__c = batchActivityList[0].id, REN_Failure_Message__c = msg));
                        }
                    }
                    if(!oliToUpdate.isEmpty()){
                        REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliToUpdate);
                    }
                    
                }
                
                
            }
            System.debug(oliList.size() + '\n\n2.1 Save oliList~~~~: ' + oliList);
            List<REN_Field_Mappings__c> lstOliToRrFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_LINE_TO_RR);
            Set<String> additionalFieldSet =new Set<String>{'OpportunityId','REN_Source_Opportunity_Line_Item_Id__c', 'Product2Id', 'REN_Start_Date__c', 'REN_End_Date__c','Quantity','REN_Covered_Asset__c'};
            REN_Util.getFromAndToFldsToQuery(lstOliToRrFldMappings,additionalFieldSet,null);
            //Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>(oliList);
            List<OpportunityLineItem> renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItemMap.keySet(), additionalFieldSet);
            Map<ID, OpportunityLineItem> oliDetailedMap = new Map<ID, OpportunityLineItem>(renewedOppLineItemList); 
            for(ID assetId: asset2OliMap.keySet()){
                asset2OliMap.put(assetId, oliDetailedMap.get(asset2OliMap.get(assetId).id));
            }
            createRenewalRelationship(asset2OliMap,assetIdMap);

            deletOpportunityWitoutProduct(renewedOpportunityMap, allRenewedOpportunityMap);
            
            //Update RLI lookup field on OLI
            List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();
            if(olidToRliMap != null && !olidToRliMap.isEmpty()){
            	for(Id olid : olidToRliMap.keySet()){
            		OpportunityLineItem oppLineItem = new OpportunityLineItem(Id = olid, REN_Renewable_Line_Item__c = olidToRliMap.get(olid).Id);
            		olisToUpdate.add(oppLineItem);
            	}
            }
            REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(olisToUpdate);
        }
        //System.debug(failureAssetList.size() + '\n\n3 Save failureAssetList~~~~: ' + failureAssetList);
        if(!failureAssetList.isEmpty()){
            REN_BatchOppFailureDataAccess.insertBatchFailure(failureAssetList);
            batchActivityList[0].REN_Failure_Assets__c += failureAssetList.size();
        }

    } 

    /** Excluded already renewed Assets
      * Excluded records for which PriceBook & Currency is not matching, add failure records.
    */
    private static List<Asset> getValidAssetList(List<REN_Batch_Activity__c> batchActivityList, List<Asset> assetList, Map<String, PricebookEntry> currencyProductPricebookEntryMap, List<REN_Batch_Opportunity_Failure__c> failureAssetList){
        
        /*Map<String, Asset> assetMap = new Map<String, Asset>(assetList);
        List<REN_Renews_To__c> renewRelationshipList = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithAssetRenewal(assetMap.keySet());
        for(REN_Renews_To__c r: renewRelationshipList){ // Excluded already renewed Assets
            assetMap.remove(''+r.REN_Asset__c);
        }
        List<Asset> filteredAssetList = new List<Asset>(assetMap.values());*/
        List<Asset> filteredAssetList = assetList;
        filteredAssetList = getAssetByPriceBook(batchActivityList, filteredAssetList, failureAssetList, currencyProductPricebookEntryMap); // Excluded records for which PriceBook & Currency is not matching, add failure records.
        return filteredAssetList;
    }   

    private static void deletOpportunityWitoutProduct(Map<String, Opportunity> renewedOpportunityMap, Map<String, Opportunity> allRenewedOpportunityMap){
        Map<ID, Opportunity> createdOpportunityMap = new Map<ID, Opportunity>(renewedOpportunityMap.values());
        createdOpportunityMap.remove(null);
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'Name','Amount','Id'},CSM_Constants.DML_OPERATION_READ);
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, new List<String>{'Id'}, CSM_Constants.DML_OPERATION_READ);                
        Map<id, Opportunity> savedOpportunityMap = new Map<id, Opportunity>([Select o.Name, o.Id, amount, (Select Id From OpportunityLineItems limit 1) From Opportunity o where ID in : createdOpportunityMap.keySet()]);
        List<Opportunity> emptyOppotunityList = new List<Opportunity>();
        for(String key: renewedOpportunityMap.keySet()){
            if(renewedOpportunityMap.get(key).id != null){
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                //Eswar Bala: Added to resolve null pointer issue reported by QA on 02/11/2016
                if(savedOpportunityMap != null && !savedOpportunityMap.isEmpty()){
                    oliList = savedOpportunityMap.get(renewedOpportunityMap.get(key).id).OpportunityLineItems;
                }
                if(oliList == null || oliList.isEmpty()){
                    emptyOppotunityList.add(renewedOpportunityMap.get(key));
                    allRenewedOpportunityMap.remove(key);
                }
            }else{
                allRenewedOpportunityMap.remove(key);
            }
        }
    
        if(!emptyOppotunityList.isEmpty()){//Delete Opportunity if no product added.
            //System.debug(emptyOppotunityList.size() + '\n\n2.2 Delete Saveed Opp. id no oliList~~~~: ' + emptyOppotunityList);
            List<Database.DeleteResult> queryResultList = REN_OpportunityDataAccess.deleteOpportunity(emptyOppotunityList);
        }
    }


    private static Opportunity createRenewalOpportunity(List<REN_Batch_Activity__c> batchActivityList, List<Asset> assetList, List<REN_Field_Mappings__c> asset2OppFMapping, List<REN_Batch_Opportunity_Failure__c> failureAssetList, Map<String, Schema.SobjectField> fieldDefinition){
        Opportunity oppNew = new Opportunity();
        REN_Util.copyObjectUsingAdminMapping(assetList[0], oppNew, fieldDefinition, asset2OppFMapping);
        Boolean hasOppNameField = CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c');
        //Setting Opportunity name in Opportunity_Name__c field.
        if(hasOppNameField){
        	oppNew.put('Opportunity_Name__c',oppNew.Name);
        }
        oppNew.REN_Is_CLM_Renewal__c = true;
        REN_Batch_Activity__c  batchActivityObj = batchActivityList[0];
        oppNew.REN_Batch_Activity_ID__c = (''+batchActivityObj.id).subString(0,15);
        if(UserInfo.isMultiCurrencyOrganization()){
            oppNew.put(REN_Constants.REN_CURRENCY_ISO_CODE, assetList[0].get(REN_Constants.REN_CURRENCY_ISO_CODE));
        }
        // Setting temporary closedate to avoid failure, actual closedate set via REN_SetOpportunityCloseDateBatch
        if(oppNew.closeDate == null){
            oppNew.closeDate = system.Today();
        }
        //System.debug(assetObj + '\n\n createRenewalOpportunity for~~~~: ' + oppNew);
        return oppNew;
    }
    
    public static void createRenewalRelationship(Map<id, OpportunityLineItem> asset2OliMap, Map<ID, Asset> assetIdMap){
    	Set<Id> oppIdSet = new Set<Id>();
        List<REN_Renews_To__c> renewalRelAssetList = new List<REN_Renews_To__c>();
        List <REN_Field_Mappings__c> fieldMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM);
        Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(REN_Renews_To__c.sObjectType);
        olidToRliMap = new Map<Id,REN_Renews_To__c>();
        for(ID assetID :asset2OliMap.keySet()){
            OpportunityLineItem oli = asset2OliMap.get(assetID);
            //find if there are any lines for which relationships need to be established 
            /* 1. Renewal Relationship */
               //Asset - Renewal Relationship
                REN_Renews_To__c renewalRelAsset = new REN_Renews_To__c();
                //renewalRelAsset.REN_Renewal_Product_Line_Id__c = oli.Id;
                //renewalRelAsset.REN_Original_Line_Item_ID__c = oli.Id;
                renewalRelAsset.REN_Renews_To__c = oli.OpportunityId;
                renewalRelAsset.REN_Product__c =  assetIdMap.get(assetID).Product2Id;
                renewalRelAsset.REN_Start_Date__c =  oli.REN_Start_Date__c;
                renewalRelAsset.REN_End_Date__c =  oli.REN_End_Date__c;
                renewalRelAsset.REN_Asset__c = assetID;
                renewalRelAsset.REN_Quantity__c = oli.Quantity;
                sObject sobjRR = REN_Util.copyObjectUsingAdminMapping(oli, renewalRelAsset, opptLineAllFieldNames, fieldMappingLst);
                CSM_Util.setAppliedCurrency(renewalRelAsset, CSM_Util.getAppliedCurrency(assetIdMap.get(assetID)));//US452
                olidToRliMap.put(oli.id,renewalRelAsset);
                renewalRelAssetList.add(renewalRelAsset);
                oppIdSet.add(oli.OpportunityId);
        }
        if(!renewalRelAssetList.isEmpty()){
           REN_OpportunityDataAccess.calculateExpQuarterYear(renewalRelAssetList,CSM_Util.getNameSpace()+ REN_Constants.OBJ_REN_RENEWS_TO_END_DATE);
           REN_RRSimplifiedTriggerHelper.processRliRecords((List<REN_Renews_To__c>)renewalRelAssetList);
           REN_RenewRelationshipDataAccess.upsertRenewalRelationship(renewalRelAssetList);
           //REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(oppIdSet);	
        }
    }
    
    
    private static String createProductReturnKey(List<REN_Batch_Activity__c> batchActivityList,Asset assetObj, OpportunityLineItem oli, Set<String> groupingFields,List<REN_Field_Mappings__c> asset2ProductFMapping,List<REN_Batch_Opportunity_Failure__c> failureAssetList, Map<String, Schema.SobjectField> fieldDefinition){
        String concatenatedFields = '';
        String NullFields = '';
        //List<REN_Batch_Opportunity_Failure__c> failureLst = new List<REN_Batch_Opportunity_Failure__c>();
        for(String field : groupingFields){
            Object fValue = REN_RenewBatchActivityHandler.getFieldValueFromSObject(assetObj, field);
            if(fValue == null){
                if(String.isBlank(NullFields)){
                    NullFields = field;
                }
                else{
                    NullFields = NullFields + ',' +field;
                }
            }
            else{
                concatenatedFields += field +'='+ String.valueOf(fValue)+'~';
            }
        }
        System.debug(NullFields + '\n\n ~~~~concatenatedFields: ' + concatenatedFields);
        if(String.isNotBlank(NullFields)){
            concatenatedFields = null;
            failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetObj.Id, REN_Batch_Activity__c = batchActivityList[0].id, REN_Failure_Message__c = String.format(Label.REN_MSG_FIELDS_ARE_NULL, new String[]{NullFields})));
        }else if(String.isNotBlank(concatenatedFields)){
            concatenatedFields = concatenatedFields.removeEnd('~');
            concatenatedFields = concatenatedFields.toUpperCase();
        
            //System.debug('\n\n create OLI for~~~~: ' + assetObj);
            try{
                //Eswar Bala - 10/29/2015
                oli.REN_Covered_Asset__c = assetObj.REN_Covered_Asset__c;//US708
                REN_Util.copyObjectUsingAdminMapping(assetObj, oli, fieldDefinition, asset2ProductFMapping);
            }catch(Exception e){
                concatenatedFields = null;
                failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetObj.Id, REN_Batch_Activity__c = batchActivityList[0].id, REN_Failure_Message__c = e.getMessage()));
            }
        }
        return concatenatedFields;
    }
    
    public static String getGroupingFields(REN_Batch_Activity__c batchActivityObj, Set<String> groupingFields){
        String queryStr = batchActivityObj.REN_Grouping__r.REN_Filter_Criteria__c;
        if(String.isNotBlank(queryStr)){
            queryStr = queryStr.replaceAll(' ', '');
            groupingFields.addAll(queryStr.split(','));
        }
        
        if(UserInfo.isMultiCurrencyOrganization() && !groupingFields.contains(REN_Constants.REN_CURRENCY_ISO_CODE)){
            queryStr += ', ' + REN_Constants.REN_CURRENCY_ISO_CODE;
            groupingFields.add(REN_Constants.REN_CURRENCY_ISO_CODE);
        }
        
        return queryStr;
    }
    
    public static String createWhereClause(REN_Batch_Activity__c batchActivityObj){
        //String queryStr = batchActivityObj.REN_Source_Record_Filter__r.REN_Filter_Criteria__c;
        String queryStr ='';
        String renewableProd = '';
        String additionalClause ='';
        String renewalCrit = '';
        
        if(batchActivityObj != null){
            String renewRecKey = batchActivityObj.REN_Source_Record_Filter__r.REN_Record_Key__c+'_πRR';
            REN_Renew_Configuration__c renewalRenewObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(renewRecKey);
            List<REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT);
            REN_Renew_Configuration__c renewConfigForOpptyPro2RenewOpptyPro = (renewConfigurationList == null || renewConfigurationList.isEmpty())? null : renewConfigurationList[0];
            if(renewConfigForOpptyPro2RenewOpptyPro != null && String.isNotBlank(renewConfigForOpptyPro2RenewOpptyPro.REN_Filter_Criteria__c)){
                renewableProd = renewConfigForOpptyPro2RenewOpptyPro.REN_Filter_Criteria__c.replaceAll('PricebookEntry.', '');
                queryStr += '\n AND (' + renewableProd + ') ';
            }
            if(renewalRenewObj != null){
                renewalCrit = renewalRenewObj.REN_Filter_Criteria__c;
            }
            additionalClause = REN_Util.constructWhereClause(batchActivityObj.REN_Source_Record_Filter__r.REN_Filter_Criteria__c,renewalCrit,'REN_Asset__c'); 
            if(String.isNotBlank(additionalClause)){
                queryStr += 'AND '+additionalClause;
            }
            batchActivityObj.REN_Grouping_Criteria__c = batchActivityObj.REN_Grouping__r.REN_Filter_Criteria__c;
            batchActivityObj.REN_Filter_Criteria__c = additionalClause;
            batchActivityObj.REN_Renewable_Products__c = renewableProd;
        }
        
        return ' ID != null ' + queryStr;
    } 
    
    private static List<Asset> getAssetByPriceBook(List<REN_Batch_Activity__c> batchActivityObjList, List<Asset> assetList,List<sObject> failureAssetList, Map<String, PricebookEntry> currencyProductPricebookEntryMap){
        Set<ID> productIdSet = new Set<ID>();
        List<Asset> validAssetList = new List<Asset>();
        Set<Asset> validAssetSet = new Set<Asset>();
        Set<String> productPricebookEntrySet = new Set<String>();
        List<Sobject> priceBookEntryList;
        String priceBookId, query;
        Map<ID,Asset> assetMap = new Map<Id,Asset>(); 
        boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        //create set of product id & currencyIsoCode for fetching PricebookEntries
        // assetMap to maintain assets which do not have pricebook entry for the product and currencyIsocode for the selected pricebook
        //initialised to all assets,valid assets removed from this map
        REN_Batch_Activity__c batchActivityObj = batchActivityObjList[0];
        for(Asset assetRecord: assetList){
            if(assetRecord.product2Id != null){
                productIdSet.add(assetRecord.product2Id);
                assetMap.put(assetRecord.Id,assetRecord);
             }else{
                failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetRecord.Id, REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = Label.REN_LBL_PRODUCT_NOT_ASSIGNED));
            }
        }
        
        priceBookId = batchActivityObj.REN_Pricebook__c ;
        query = 'SELECT id, product2Id, pricebook2Id ';
        List<String>fieldList = new List<String>{'id','product2Id','pricebook2Id'};
        
        if(isMultiCurrency){
            query += ', CurrencyIsoCode' ;
            fieldList.add('CurrencyIsoCode');
        }
        CSM_UTIL.checkCRUD_FLS(REN_CONSTANTS.OBJ_PricebookEntry,fieldList,CSM_Constants.DML_OPERATION_READ);
        query = query + ' FROM PricebookEntry WHERE Product2Id IN : productIdSet AND Pricebook2Id = :priceBookId ';
        //System.debug(productIdSet + '\n\n productIdSet for priceBookId~~~~: ' + priceBookId);
        //get all pricebookentries for the selected pricebook having productIDset 
        priceBookEntryList = Database.query(query);
        
        for(PricebookEntry bookEntry : (List<PricebookEntry>)priceBookEntryList){
            String key = isMultiCurrency? bookEntry.get('CurrencyIsoCode') + ''+ bookEntry.product2Id : bookEntry.product2Id;
            currencyProductPricebookEntryMap.put(key, bookEntry);
            productPricebookEntrySet.add(bookEntry.product2Id);
        }
        
        for(Asset assetRec : assetList){
                if(isMultiCurrency){
                    if(currencyProductPricebookEntryMap.containskey((String)assetRec.get('CurrencyIsoCode')+assetRec.product2Id)){
                        validAssetSet.add(assetRec);
                        assetMap.remove(assetRec.Id);
                    }
                    else if(productPricebookEntrySet.contains(assetRec.product2Id)){
                        //removing from assetmap to differentiate currency mismatch and pricebook mismatch and directly adding the currency mismatch failure
                        assetMap.remove(assetRec.Id);
                        failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetRec.Id, REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = Label.REN_MSG_CURRENCY_MISMATCH));
                    }
                }
                else{
                    if(productPricebookEntrySet.contains(assetRec.product2Id)){
                        validAssetSet.add(assetRec);
                        assetMap.remove(assetRec.Id);
                    }
                }   
            }
        //assetMap now contains only invalid assets with pricebook mismatch, adding those invalid assets to failureAssetList
        for(ID assetId : assetMap.keySet()){
            failureAssetList.add(new REN_Batch_Opportunity_Failure__c(REN_Asset__c = assetId, REN_Batch_Activity__c = batchActivityObj.id, REN_Failure_Message__c = Label.REN_Product_does_not_belong_to_selected_Pricebook));
        }
        validAssetList = new List<Asset>(validAssetSet);
        return validAssetList;
    }
/*
    public static void sendEmailNotifications(AsyncApexJob a, REN_Batch_Activity__c batchActivityObj, Integer errorCount, String errorDrtails, String messageDrtails){
        // Send an email to the Apex job's submitter notifying of job completion.  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);

        mail.setTargetObjectId(UserInfo.getUserId());
        //mail.setCcAddresses(new List<String>{'Vishal@comitydesigns.com'});
        mail.setSenderDisplayName('Opportunity Generation Batch Completed');
        mail.setSubject('Opportunity Generation Batch');
        
        String MailBody = '';
        MailBody += '<table align="center" width="700" border="1" style="font-family:Arial;font-size:12px;background-color: lightgray"> ';
        MailBody += '<caption style="font-size: 18px; color: blue;">Opportunity Generation Batch Status </caption> ';
        MailBody += '<tr style="background-color: #E8E8E8;"><td style="font-size: 14px;">Batch Status</td><td>' + a.Status + '</td> </tr> ';
        MailBody += '<tr style="background-color: lightgray;"> <td style="font-size: 14px;">No. of records processed</td>  <td>' + a.TotalJobItems + '</td> ';
        MailBody += '<tr style="background-color: #E8E8E8;"> <td style="font-size: 14px;">No. of batches executed</td>  <td>' + a.JobItemsProcessed + '</td> </tr> ';
        MailBody += '<tr style="background-color: lightgray;"> <td style="font-size: 14px;">No. of errors </td>  <td>' + errorCount + '</td> </tr> ';
        MailBody += '<tr style="background-color: #E8E8E8;"> <td style="font-size: 14px;" valign="top">Updated Description</td>  <td>' + messageDrtails + '</td> </tr> ';
        MailBody += '<tr style="background-color: #E8E8E8;"> <td style="font-size: 14px;" valign="top">Error Description</td>  <td>' + errorDrtails + '</td> </tr> ';
        MailBody += '<tr style="background-color: lightgray;"> <td style="font-size: 14px;">Batch start date</td>  <td>' + a.CreatedDate + '</td> </tr> ';
        MailBody += '<tr style="background-color: #E8E8E8;"> <td style="font-size: 14px;">Batch end date</td>  <td>' + a.CompletedDate + '</td> </tr> ';
        MailBody += '<tr style="background-color: lightgray;"> <td style="font-size: 14px;">Batch created by</td>  <td>' + a.CreatedBy.Email + '</td> </tr> </table> ';
        mail.setHtmlBody(MailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    } 
*/
    public static void sendEmailNotifications(REN_Batch_Activity__c batchActivityObj, String messageDrtails){
        sendEmailNotifications(new List<REN_Batch_Activity__c>{ batchActivityObj}, messageDrtails);
    }
    private static void sendEmailNotifications(List<REN_Batch_Activity__c> batchActivityObjList, String messageDrtails){//bulkified this method
        String templateName = '';
        String subjectText = 'Batch Opportunity Generation ' + batchActivityObjList[0].REN_Status__c + ' for ' + batchActivityObjList[0].name;
        String emailBody = String.format(Label.REN_LBL_Dear_Name, new String[]{'User'});
        emailBody  += '<br>' + String.format(Label.REN_LBL_BATCH_TEXT_EMAIL_MESSAGE, new String[]{
            batchActivityObjList[0].REN_Source_Record_Filter__r.REN_View_Name__c, 
            batchActivityObjList[0].REN_Grouping__r.REN_View_Name__c,
            batchActivityObjList[0].REN_Status__c,
            URL.getSalesforceBaseUrl().toExternalForm() + (Page.ren_batchoppgensummary.getURL()) + '?id=' + batchActivityObjList[0].id,
            String.isNotBlank(messageDrtails) ? '<br/><br/>Below errors have been identified:  ' + messageDrtails : ''
        });

        if(REN_Constants.STATUS_COMPLETED.equalsIgnoreCase(batchActivityObjList[0].REN_Status__c)){
            templateName = 'Batch-Activity-Success';
        }
        else if(REN_Constants.STATUS_PARTIAL_SUCCESS.equalsIgnoreCase(batchActivityObjList[0].REN_Status__c)){
            templateName = 'Batch-Activity-PartialSuccess';
        }
        else {
            templateName = 'Batch-Activity-Failed';
        }
        ID templateID = REN_Util.getEmailTemplateId(templateName);
        if(templateID == null && batchActivityObjList[0].REN_Email_Notification__c){                
            REN_Util.sendEmailNotification(getEmailRecipients(batchActivityObjList), subjectText, emailBody);
        }else if(batchActivityObjList[0].REN_Email_Notification__c){
            REN_Util.sendEmailNotificationUsingTemplate(getEmailRecipients(batchActivityObjList), templateID + '', batchActivityObjList[0].id);
        }
        
    } 
    
    public static Set<Id> getEmailRecipients(List<REN_Batch_Activity__c> batchActivityList) {
        List< REN_Email_Recipient__c > emailRecepientList = REN_EmailRecipientDataAccess.getEmailRecipients(batchActivityList[0].id);
        return REN_Util.getUniqueEmailRecipients(emailRecepientList);
    }
    public static String retrieveReferenceField(String colString,String groupingFields){
        set<String> colSet=new set<String>();
        set<String> groupSet=new set<String>();
        String queryStr;
            colString = colString.replaceAll(' ', '');
            colString = colString.toLowerCase();
            colSet.addAll(colString.split(','));
            if(groupingFields!=null || String.isNotBlank(groupingFields)){
                groupingFields = groupingFields.replaceAll(' ', '');
                groupingFields = groupingFields.toLowerCase();
                groupSet.addAll(groupingFields.split(','));
                colSet.addAll(groupSet);
            }
            for(String str:colSet){
                if(queryStr==null || String.isBlank(queryStr))
                    queryStr=str;
                else
                    queryStr=queryStr+','+str;
            }
            system.debug('queryStr--->'+queryStr);
            return queryStr;
    }
    public static Object getFieldValueFromSObject(sObject parentObj,String queryString){
        if(String.isBlank(queryString) || parentObj == null){
            return null;
        }
        if(!queryString.contains('.')){
            return parentObj.get(queryString);
        }
        String key = queryString.subString(0, queryString.indexOf('.'));
        sObject refObj = parentObj.getSobject(key);
        return getFieldValueFromSObject(refObj, queryString.subString(queryString.indexOf('.')+1));
        
        
    }
}