/**
 * Created Date     : Sep 6, 2016
 * Developed By     : Chandra, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Chandra                  User Story              Sep 6, 2016         1.1                 @description
 * 
 */
public with sharing class REN_AsyncOppRenewalBatchHelper {
    
    private static REN_Opportunities opptyRenewal = new REN_Opportunities();
   
    /**
     * @description Set Qualified Flags
     * @param lpsList: A list of REN_Line_Processing_Status__c to update flag fields
     * @return: void
     * @example REN_AsyncOppRenewalBatchHelper.setQualifiedFlag(lpsList,renewConfigurationMap);
     */
    public static List<REN_Line_Processing_Status__c> setQualifiedFlag(List<REN_Line_Processing_Status__c> lpsList, Set<Id> opptyIds){
        
        REN_Renewals renewals = new REN_Renewals();
        Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
                                                            REN_Constants.OBJ_OPPORTUNITY, 
                                                            CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
        Map<ID, OpportunityLineItem> qualifiedOpportunityLineItemMap4Renew = new Map<ID, OpportunityLineItem>(
                                                                            (List<OpportunityLineItem>)renewals.applyOpliCriteria(opptyIds, 
                                                                            REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT));
        Map<ID, OpportunityLineItem> qualifiedOpportunityLineItemMap4Asset = new Map<ID, OpportunityLineItem>(
                                                                            (List<OpportunityLineItem>)renewals.applyOpliCriteria(opptyIds, 
                                                                            REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET));
        Map<ID, OpportunityLineItem> qualifiedOpportunityLineItemMap4CLI;
        if(entitlementPkgInstalled) {
            qualifiedOpportunityLineItemMap4CLI = new Map<ID, OpportunityLineItem>(
                                                                            (List<OpportunityLineItem>)renewals.applyOpliCriteria(opptyIds, 
                                                                            REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM));    
        } else {
            qualifiedOpportunityLineItemMap4CLI = new Map<ID, OpportunityLineItem>();
        }
        List<REN_Line_Processing_Status__c> newLineProcessStatusList = new List<REN_Line_Processing_Status__c>();
        for(REN_Line_Processing_Status__c lps: lpsList){
            lps.REN_OLI_Qualified__c = qualifiedOpportunityLineItemMap4Renew.containsKey(lps.REN_Source_OLI_Id__c);
            lps.REN_Asset_Qualified__c = qualifiedOpportunityLineItemMap4Asset.containsKey(lps.REN_Source_OLI_Id__c);
            lps.REN_CLI_Qualified__c = qualifiedOpportunityLineItemMap4CLI.containsKey(lps.REN_Source_OLI_Id__c);
            lps.REN_OLI_Qualified__c = qualifiedOpportunityLineItemMap4Renew.containsKey(lps.REN_Source_OLI_Id__c);
            lps.REN_Asset_RLI_Qualified__c = lps.REN_OLI_Qualified__c && lps.REN_Asset_Qualified__c;
            lps.REN_CLI_RLI_Qualified__c = lps.REN_OLI_Qualified__c && lps.REN_CLI_Qualified__c;
            if(SS_Constants.isSimplifiedDataModelEnabled){
                lps.REN_OLI_Qualified__c = false;
            }
            if(lps.REN_OLI_Qualified__c || lps.REN_Asset_Qualified__c || lps.REN_CLI_Qualified__c) {
                newLineProcessStatusList.add(lps);
            }
        }
        return newLineProcessStatusList;
    }
    
    public static Map<String, String> getRenewalProcessStatusMap(List<REN_Renewal_Processing_Status__c> renewalProcessStatusList){
        Map<String, String> renewalProcessStatusMap = new Map<String, String>();
        if (renewalProcessStatusList != null && !renewalProcessStatusList.isEmpty()){
            for(REN_Renewal_Processing_Status__c record : renewalProcessStatusList) {
                renewalProcessStatusMap.put(record.REN_Source_Opportunity__c,record.Id);
            }
        }
        return renewalProcessStatusMap;
    }
    
    public static List<REN_Line_Processing_Status__c> getLineProcessingStatusList(Map<String,String> opptyIdMap){
        List<REN_Line_Processing_Status__c> lineProcessingStatusList = new List<REN_Line_Processing_Status__c>();
        REN_Line_Processing_Status__c lineProcessingStatusRec;
        for(OpportunityLineItem oppLineItem : REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(opptyIdMap.keySet())) {
            lineProcessingStatusRec = new REN_Line_Processing_Status__c();
            lineProcessingStatusRec.REN_Source_OLI_Id__c = oppLineItem.Id;
            lineProcessingStatusRec.REN_Product__c = oppLineItem.Product2Id;
            lineProcessingStatusRec.REN_Source_Asset__c = oppLineItem.REN_Covered_Asset__c;
            if(opptyIdMap.containsKey(oppLineItem.OpportunityId)) {
                lineProcessingStatusRec.REN_Renewal_Processing_Status__c = opptyIdMap.get(oppLineItem.OpportunityId);
            }
            lineProcessingStatusList.add(lineProcessingStatusRec);
        }       
        return lineProcessingStatusList;
    }
    
    /**
     * @description Reset Line Processing Status records
     * @param queryResultList: Database.SaveResult, a list after insert records like LOI/Asset/CLI/RR 
     * @param lpsIdToCrestedObjMap: Map<ID, sObject> where KEY = Processing Status record's ID, VALUE = any one of newly created LOI/Asset/CLI/RR record
     * @param lpsMap: Map<ID, REN_Line_Processing_Status__c> where KEY = Processing Status record's ID, VALUE = REN_Line_Processing_Status__c record
     * @return: Map<ID, sObject> : Successfully inserted records' map
     * @example REN_AsyncOppRenewalBatchHelper.setLineProcessingStatus(Database.SaveResult[], Map<ID, sObject>, Map<ID, REN_Line_Processing_Status__c>);
     */
    public static Map<ID, sObject> setLineProcessingStatus(Database.SaveResult[] queryResultList, Map<ID, sObject> lpsIdToCrestedObjMap, Map<ID, REN_Line_Processing_Status__c> lpsMap){
        Map<ID, sObject> savedRecordMap = new Map<ID, sObject>();
        List<ID> processedRecordLpsIdList = new List <ID>(lpsIdToCrestedObjMap.keySet());
        List<sObject> processedRecordList = lpsIdToCrestedObjMap.values();
        if(queryResultList != null && queryResultList.size() > 0){
            ID lpsId = null;
            boolean isAsset = processedRecordList[0] instanceof Asset;
            boolean isLOI = processedRecordList[0] instanceof OpportunityLineItem;
            boolean isRR = processedRecordList[0] instanceof REN_Renews_To__c;
            boolean isCLI = ((processedRecordList[0].getSObjectType() + '') == 'ContractLineItem');
            
            for(Integer i=0;i<queryResultList.size();i++){
                lpsId = processedRecordLpsIdList[i];
                if (queryResultList.get(i).isSuccess()){
                    savedRecordMap.put(processedRecordList[i].id, processedRecordList[i]);
                    lpsMap.get(lpsId).REN_Failure__c = false;
                    lpsMap.get(lpsId).REN_Failure_Msg__c = null;
                    if(isLOI){
                        lpsMap.get(lpsId).REN_Renewal_OLI_Id__c = processedRecordList[i].id;
                    }else if(isAsset){
                        lpsMap.get(lpsId).REN_Renewal_Asset_Id__c = processedRecordList[i].id;
                    }else if(isCLI){
                        lpsMap.get(lpsId).REN_Renewal_Contract_Line_Item_Id__c = processedRecordList[i].id;
                    }else if(isRR){
                        if(processedRecordList[i].get('REN_Asset__c') != null){
                            lpsMap.get(lpsId).REN_Renewal_Asset_RLI_Id__c = processedRecordList[i].id;
                        }else if(processedRecordList[i].get(CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c') != null){
                            lpsMap.get(lpsId).REN_Renewal_CLI_RLI_Id__c = processedRecordList[i].id;
                        }
                    }
                }else{
                    Database.Error error = queryResultList.get(i).getErrors().get(0);
                    lpsMap.get(lpsId).REN_Failure__c = true;
                    lpsMap.get(lpsId).REN_Failure_Msg__c = error.getMessage();
                }
            }
        }
        return savedRecordMap;
    }
    
    public static void deleteDisqualifiedRpsRecords(Set<ID> processedRpsIdSet){
        List<REN_Renewal_Processing_Status__c> renewalProcessStatusList = REN_RenewalProcessingStatusDataAccess.getRecordsByIds(processedRpsIdSet);
        List<REN_Renewal_Processing_Status__c> rpsList = new List<REN_Renewal_Processing_Status__c>();
        
        for(REN_Renewal_Processing_Status__c rps: renewalProcessStatusList){
            if(rps.REN_OLIs_Qualified__c == 0 && rps.REN_Assets_Qualified__c == 0 && rps.REN_CLIs_Qualified__c == 0){
                rpsList.add(new REN_Renewal_Processing_Status__c(id = rps.id));
            }
        }
        
        REN_RenewalProcessingStatusDataAccess.deleteAllRPS(rpsList);
        
    }
    public static List<Opportunity> checkAndMarkRenewalCompleted(Set<ID> rpsIdSet) {
        List<REN_Renewal_Processing_Status__c> renewalProcessStatusList = REN_RenewalProcessingStatusDataAccess.getCompletedProcessingStatusByIds(rpsIdSet);
        List<Opportunity> renewedOpportynityList= new List<Opportunity>();
        for(REN_Renewal_Processing_Status__c rps: renewalProcessStatusList){
            Opportunity renewedOpp = (Opportunity)rps.getSObject('REN_Renewal_Opportunity__r');
            renewedOpp.REN_Notify_Opportunity_Owner__c = true;
            renewedOpp.REN_Is_CLM_Renewal__c = true;
            renewedOpportynityList.add(renewedOpp);
        }
        if(!renewedOpportynityList.isEmpty()){
            REN_OpportunityDataAccess.updateOpportunityforRenewals(renewedOpportynityList);
        }
        return renewedOpportynityList;
    }
    
    public static Map<Id,List<OpportunityLineItem>> executeOliBasedCriteria(Set<Id> oppIds,String filterWith){
        Map<Id,List<OpportunityLineItem>> mapOfOppToOli = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> listOfValidOli = new List<OpportunityLineItem>();
        
        listOfValidOli = (List<OpportunityLineItem>)opptyRenewal.applyOpliCriteria(oppIds, filterWith);
                                                                            //REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT);
        
                                                    
        for(OpportunityLineItem oli:listOfValidOli){
            List<OpportunityLineItem> lstOfOli = mapOfOppToOli.get(oli.OpportunityId);
            if(lstOfOli==null){
                lstOfOli = new List<OpportunityLineItem>();
            }
            lstOfOli.add(oli);
            mapOfOppToOli.put(oli.OpportunityId,lstOfOli);
        }
        return mapOfOppToOli;
    }
}