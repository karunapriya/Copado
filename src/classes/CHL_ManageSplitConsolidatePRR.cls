/**
 * Created Date     : Dec 21, 2017
 * Developed By     : Sheetal, Comity Designs, Inc.
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
 * Sheetal                  US2997                 Dec 21, 2017      1.1                 @description
 *
 */
public with sharing class CHL_ManageSplitConsolidatePRR { 
    
    public static void handlePRRSplitAndConsolidate(List<REN_Renews_To__c> selectedRRList,
    												  List<Opportunity> sourceOppList,
    												  Opportunity targetOpp,
    												  String actionName) {
    	handlePRRSplitAndConsolidate(selectedRRList,sourceOppList,targetOpp,actionName,false);    												  	
	}
	
    public static void handlePRRSplitAndConsolidate(List<REN_Renews_To__c> selectedRRList,
    												  List<Opportunity> sourceOppList,
    												  Opportunity targetOpp,
    												  String actionName,Boolean isBatchFlow) {
    	String csmNameSpace = CSM_Util.getNamespace();
    	CSM_TriggerManager.disableAllTriggers();
       	CSM_SplitConsolidateWrapper wrapper = new CSM_SplitConsolidateWrapper();
       	wrapper.targetOpp = targetOpp;
       	wrapper.fieldMappingListPO2PO = new List<REN_Field_Mappings__c>();
        wrapper.fieldMappingListPO2PO = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                                       Label.CHL_LBL_PO_TO_PO,csmNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY, csmNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
                                       
        Set<String> fieldsSet = new Set<String>{'Id','CHL_Opportunity__c','CHL_Incumbent__c','CHL_Syncing__c','CHL_Probability__c'};    
		REN_Util.getFromAndToFldsToQuery(wrapper.fieldMappingListPO2PO,fieldsSet,null);	
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(targetOpp.id);
        Map<Id, Opportunity> sourceOpportunityMap = new Map<Id, Opportunity> (sourceOppList);
        opportunityIds.addAll(sourceOpportunityMap.keySet());
        opportunityIds.remove(null);
        List<CHL_Partner_Opportunity__c> partnerOppList = CHL_PartnerOpportunityDataAccess.getPOListbyFields(opportunityIds, fieldsSet);
        if(partnerOppList != null && !partnerOppList.isEmpty()){
	        wrapper.targetPOList = new List<CHL_Partner_Opportunity__c>();
	        wrapper.sourcePOList = new List<CHL_Partner_Opportunity__c>();
	        for(CHL_Partner_Opportunity__c partnerOpportunity : partnerOppList) {
	            if(partnerOpportunity.CHL_Opportunity__c == targetOpp.id) {
	                wrapper.targetPOList.add(partnerOpportunity);
	            } else {
	            	wrapper.sourcePOList.add(partnerOpportunity);
	            }
	        }
	        Map<Id, CHL_Partner_Opportunity__c> targetPOMap = new Map<Id, CHL_Partner_Opportunity__c>(wrapper.targetPOList);
	        wrapper.sourcePOMap = new Map<Id, CHL_Partner_Opportunity__c>(wrapper.sourcePOList);
	        Set<Id> partnerOpportunityIds = new Set<Id>();
	        partnerOpportunityIds.addAll(targetPOMap.keySet());
	        partnerOpportunityIds.addAll(wrapper.sourcePOMap.keySet()); 
	    	List<REN_Renews_To__c> targetRLIsList = REN_RenewRelationshipDataAccess.getLstRenRelationshipByOppSet(new Set<String>{(String)targetOpp.id});
	        Set<Id> rlisIdSet = new  Set<Id>();
	        if(selectedRRList != null && !selectedRRList.isEmpty()){
	        	rlisIdSet = (new Map<Id,REN_Renews_To__c>(selectedRRList)).keySet();
	        } else if(targetRLIsList != null && !targetRLIsList.isEmpty()) {
	        	rlisIdSet = (new Map<Id,REN_Renews_To__c>(targetRLIsList)).keySet();
	        }
	        
	        wrapper.pRRList = new List<CHL_Partner_Renewal_Relationship__c>();
	        wrapper.pRRList = CHL_PartnerRenRelationshipDataAccess.getPRRByPartnerOpty(new List<String>{'CHL_Partner_Opportunity__c','CHL_Renewal_Relationship__c'}, partnerOpportunityIds,rlisIdSet);
	        
	        // Form here Partner Opportunity To PRR Map
	        Map<Id, List<CHL_Partner_Renewal_Relationship__c>> sourcePO2PRRMap = new Map<Id, List<CHL_Partner_Renewal_Relationship__c>>();
	        sourcePO2PRRMap = getPartnerOpportunity2PRRMap(wrapper);
	        
	        //Find PRR which can be reparented and which needs to be new one
	        Map<Id,CHL_Partner_Opportunity__c> notMatchingPOsMap = new Map<Id,CHL_Partner_Opportunity__c>();
	        wrapper.targetPO2SourcePOMap = new Map<Id, Id>();
	        wrapper.targetPO = new List<CHL_Partner_Opportunity__c>();
	    	wrapper.createNewPO = new List<CHL_Partner_Opportunity__c>();
	        notMatchingPOsMap = getList2ReParentPRR(wrapper);
	        //Create new Partner Opportunities
	        List<CHL_Partner_Opportunity__c> newPOList = new List<CHL_Partner_Opportunity__c>();
	        if(wrapper.createNewPO != null && !wrapper.createNewPO.isEmpty()) {
	            newPOList = createNewPartnerOpportunity(wrapper, actionName);     
	        }
	        wrapper.targetPO.addAll(newPOList);
	        wrapper.targetPO.addAll(notMatchingPOsMap.values());
	        if(wrapper.sourcePOList == null || wrapper.sourcePOList.isEmpty()){
	        	wrapper.targetPO.addAll(wrapper.targetPOList);
	        }
	        Map<Id,CHL_Partner_Opportunity__c> targetPosMap = new Map<Id,CHL_Partner_Opportunity__c>(wrapper.targetPO);
	        //Re-parent PRR
	        List<CHL_Partner_Renewal_Relationship__c> finalPRRList = new List<CHL_Partner_Renewal_Relationship__c>();
	        wrapper.reparentedPO2PRRMap = new Map<Id, List<CHL_Partner_Renewal_Relationship__c>>();
	        wrapper.reparentedPO2PRRMap = CHL_PartnerRenRelationshipDataAccess.getPO2PRRMap(targetPosMap.keySet());
	        finalPRRList = reparentPRR(wrapper, sourcePO2PRRMap);
	        //Create New PRR
	        createNewPartnerRenewalRelationship(wrapper, targetRLIsList, finalPRRList);
	        if(finalPRRList != null){
	        	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
				CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
	        	CHL_PartnerRenRelationshipDataAccess.upsertPartnerRenRealtionship(finalPRRList);
	        }
	        List<CHL_Partner_Opportunity__c> targetPartnerOpptyList = updateFieldsOnExistingPO(wrapper.targetPO,targetRLIsList);
	        List<CHL_Partner_Opportunity__c> sourcePOList = resetPOSyncing(wrapper.sourcePOList);
	        if(sourcePOList != null && !sourcePOList.isEmpty()){
        		targetPartnerOpptyList.addAll(sourcePOList); 
	        } 
	        if(targetPartnerOpptyList != null && !targetPartnerOpptyList.isEmpty()){
	        	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
				CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
				CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(targetPartnerOpptyList);
	        }
	        if(!isBatchFlow){
	       		createQuoteAndQLIs(new List<Opportunity>{targetOpp});
	        }	       
        }
    }
    
    // Form here Partner Opportunity To PRR Map
    private static Map<Id, List<CHL_Partner_Renewal_Relationship__c>> getPartnerOpportunity2PRRMap(CSM_SplitConsolidateWrapper wrapper) {
    	Map<Id, List<CHL_Partner_Renewal_Relationship__c>> sourcePO2PRRMap = new Map<Id, List<CHL_Partner_Renewal_Relationship__c>>();
        if(wrapper.pRRList != null && !wrapper.pRRList.isEmpty()) {
            List<CHL_Partner_Renewal_Relationship__c> pRRListToAdd = new List<CHL_Partner_Renewal_Relationship__c>();
            for(CHL_Partner_Renewal_Relationship__c prr : wrapper.pRRList) {
                if(wrapper.sourcePOMap != null && wrapper.sourcePOMap.containsKey(prr.CHL_Partner_Opportunity__c)) {
                    if(sourcePO2PRRMap.containsKey(prr.CHL_Partner_Opportunity__c)) {
                        pRRListToAdd = sourcePO2PRRMap.get(prr.CHL_Partner_Opportunity__c);
                        pRRListToAdd.add(prr);
                    } else {
                        pRRListToAdd = new List<CHL_Partner_Renewal_Relationship__c>();
                        pRRListToAdd.add(prr);
                    }
                    sourcePO2PRRMap.put(prr.CHL_Partner_Opportunity__c, pRRListToAdd);
                }
            }
        }
        return sourcePO2PRRMap;
    }
    
    //Find PRR which can be reparented and which needs to be new one
    private static Map<Id,CHL_Partner_Opportunity__c> getList2ReParentPRR(CSM_SplitConsolidateWrapper wrapper) {
        Map<Id,CHL_Partner_Opportunity__c> notMatchingPOsMap = new Map<Id,CHL_Partner_Opportunity__c>();
        Set<Id> sourcePoIdsSet = new Set<Id>();
        if(wrapper.sourcePOList != null && !wrapper.sourcePOList.isEmpty()) {
            for (CHL_Partner_Opportunity__c sourcePO : wrapper.sourcePOList) {
                if(wrapper.targetPOList != null && !wrapper.targetPOList.isEmpty()) {
                	Integer countPO = 0;
                    for(CHL_Partner_Opportunity__c targetPO : wrapper.targetPOList) {
                        if((sourcePO.CHL_Partner_Account_1__c == targetPO.CHL_Partner_Account_1__c && sourcePO.CHL_Partner_Account_2__c == targetPO.CHL_Partner_Account_2__c)
                        || (sourcePO.CHL_Partner_Account_1__c == targetPO.CHL_Partner_Account_2__c && sourcePO.CHL_Partner_Account_2__c == targetPO.CHL_Partner_Account_1__c) 
   						|| (sourcePO.CHL_Partner_Account_1__c == null && sourcePO.CHL_Partner_Account_2__c == null 
   							&& targetPO.CHL_Partner_Account_1__c == null && targetPO.CHL_Partner_Account_2__c == null)) {
   							notMatchingPOsMap.put(targetPO.Id,targetPO);
   							if(!sourcePoIdsSet.contains(sourcePO.id)) {
   								if(!wrapper.targetPO2SourcePOMap.containsKey(targetPO.id)) {
   									wrapper.targetPO2SourcePOMap.put(targetPO.id, sourcePO.id);
	                            	wrapper.targetPO.add(targetPO);
	                            	sourcePoIdsSet.add(sourcePO.id);	
   								} else {
   									countPO++;
   								}
   							} else {
	                        	countPO++;
	                        }
                        } else {
                        	notMatchingPOsMap.put(targetPO.Id,targetPO);
                        	countPO++;
                        }
                    }
                    if(countPO == wrapper.targetPOList.size()) {
                    	wrapper.createNewPO.add(sourcePO);
                    }
                } else {
                    wrapper.createNewPO.add(sourcePO);
                }
            }
        }        
        for(Id poId : wrapper.targetPO2SourcePOMap.keySet()){
        	if(notMatchingPOsMap.containsKey(poId)){
        		notMatchingPOsMap.remove(poId);
        	}
        }
        return notMatchingPOsMap;
    }
    
    //Create new Partner Opportunities
    private static List<CHL_Partner_Opportunity__c> createNewPartnerOpportunity(CSM_SplitConsolidateWrapper wrapper,
    																			String actionName) { 
    	//List<CHL_Partner_Opportunity__c> newPOList = new List<CHL_Partner_Opportunity__c>();	
    	String ssNameSpace = CSM_Util.getNamespace();																	
    	Sobject partnerOpportunityObj = Schema.getGlobalDescribe().get(ssNameSpace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY).newSObject();
        Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(partnerOpportunityObj.getSobjectType());                  
        SObject partnerOppObj;   
        List<SObject> newPartnerOpportunityList = new List<SObject>();  
        String partnerOpptyName;             
        if(wrapper.createNewPO != null && !wrapper.createNewPO.isEmpty()) {
            for(SObject po : (List<SObject>)wrapper.createNewPO) {
            	partnerOppObj = Schema.getGlobalDescribe().get(ssNameSpace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY).newSObject();
                REN_Util.copyObjectUsingAdminMapping(po, 
                									partnerOppObj, 
                                                    fieldDesctiptionMap, 
                                                    wrapper.fieldMappingListPO2PO);
                partnerOpptyName = partnerOppObj.get('Name') + '_' + actionName;
                partnerOpptyName = partnerOpptyName.length() > 80 ? partnerOpptyName.substring(0,79) : partnerOpptyName;                                      
                partnerOppObj.put(ssNameSpace + 'CHL_Opportunity__c', wrapper.targetOpp.id);
                partnerOppObj.put(ssNameSpace + 'CHL_Sales_Stage__c', wrapper.targetOpp.StageName);
                partnerOppObj.put(ssNameSpace + 'CHL_Probability__c', wrapper.targetOpp.Probability);
                partnerOppObj.put('Name', partnerOpptyName);
                partnerOppObj.put(ssNameSpace + 'CHL_Incumbent__c',po.get('CHL_Incumbent__c'));
                //partnerOppObj.put('CHL_Syncing__c',po.get('CHL_Syncing__c'));CHL_Probability__c
                partnerOppObj.put(ssNameSpace + 'CHL_Syncing__c',null); 
                if (UserInfo.isMultiCurrencyOrganization()){
                	partnerOppObj.put('CurrencyIsoCode',po.get('CurrencyIsoCode'));
                }
                newPartnerOpportunityList.add(partnerOppObj);
            }
            if(newPartnerOpportunityList != null && !newPartnerOpportunityList.isEmpty()) {
            	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
				CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
                return (List<CHL_Partner_Opportunity__c>)CHL_PartnerOpportunityDataAccess.insertPartnerOpportunity(newPartnerOpportunityList);
            }
        }
        return null;
    }
    
    //Re-parent PRR
    private static List<CHL_Partner_Renewal_Relationship__c> reparentPRR(CSM_SplitConsolidateWrapper wrapper, Map<Id, List<CHL_Partner_Renewal_Relationship__c>> sourcePO2PRRMap) {
        List<CHL_Partner_Renewal_Relationship__c> finalPRRList = new List<CHL_Partner_Renewal_Relationship__c>();
            List<CHL_Partner_Renewal_Relationship__c> pRRList = new List<CHL_Partner_Renewal_Relationship__c>();
            Set<Id> sourcePOIdSet = new Set<Id>();
            if(wrapper.targetPO != null && !wrapper.targetPO.isEmpty()) {
            for(CHL_Partner_Opportunity__c po : wrapper.targetPO) {
                if(wrapper.targetPO2SourcePOMap.containsKey(po.id)) {
                    Id sourcePOId = wrapper.targetPO2SourcePOMap.get(po.id);
                    if(sourcePO2PRRMap.containsKey(sourcePOId)) {
                    	sourcePOIdSet.add(sourcePOId);
                        pRRList = sourcePO2PRRMap.get(sourcePOId);
                        if(pRRList != null && !pRRList.isEmpty()) {
                            for(CHL_Partner_Renewal_Relationship__c prr : pRRList) {
                            		List<CHL_Partner_Renewal_Relationship__c> partnerRRList = new List<CHL_Partner_Renewal_Relationship__c>();
                                	prr.CHL_Partner_Opportunity__c = po.id;
		                           	if(wrapper.reparentedPO2PRRMap.containsKey(po.id)) {
		                            	partnerRRList = wrapper.reparentedPO2PRRMap.get(po.id);
		                          	}
		                          	partnerRRList.add(prr);
                                	wrapper.reparentedPO2PRRMap.put(po.id, partnerRRList);
                            }
                            finalPRRList.addAll(pRRList);
                        }
                    }
                } else {
                    Map<Id, Id> target2SourcePO = new Map<Id, Id>();
                    Id sourcePO = null;
                    if(wrapper.sourcePOList != null && !wrapper.sourcePOList.isEmpty()) {
	                    for(CHL_Partner_Opportunity__c spo : wrapper.sourcePOList) {
	                    	if((spo.CHL_Partner_Account_1__c == po.CHL_Partner_Account_1__c && spo.CHL_Partner_Account_2__c == po.CHL_Partner_Account_2__c)
	                        || (spo.CHL_Partner_Account_1__c == po.CHL_Partner_Account_2__c && spo.CHL_Partner_Account_2__c == po.CHL_Partner_Account_1__c) 
	   						|| (spo.CHL_Partner_Account_1__c == null && spo.CHL_Partner_Account_2__c == null 
	   							&& po.CHL_Partner_Account_1__c == null && po.CHL_Partner_Account_2__c == null)) {
	                    		if(!sourcePOIdSet.contains(spo.id)) {
		                    		if(!target2SourcePO.containsKey(po.id)) {
		                    			sourcePO = target2SourcePO.get(po.id);
		                    		} else {
		                    			sourcePO = null;
		                    		}
		          					if(sourcePO == null) {
		          						target2SourcePO.put(po.id, spo.id);
		          						sourcePOIdSet.add(spo.id);
		          						break;
		          					}
	                    		}
	                    		
	                    	}
	                    }
                    }
                    if(target2SourcePO != null && !target2SourcePO.isEmpty()) {
                    	if(target2SourcePO.containsKey(po.id)) {
	                    	Id sourcePOId = target2SourcePO.get(po.id);
	                    	if(sourcePO2PRRMap.containsKey(sourcePOId)) {
		                        pRRList = sourcePO2PRRMap.get(sourcePOId);
		                        if(pRRList != null && !pRRList.isEmpty()) {
		                        	List<CHL_Partner_Renewal_Relationship__c> partnerRRList;
		                            for(CHL_Partner_Renewal_Relationship__c prr : pRRList) {
		                            	partnerRRList = new List<CHL_Partner_Renewal_Relationship__c>();
		                                prr.CHL_Partner_Opportunity__c = po.id;
		                                if(wrapper.reparentedPO2PRRMap.containsKey(po.id)) {
		                               		partnerRRList = wrapper.reparentedPO2PRRMap.get(po.id);
		                               	}
		                               partnerRRList.add(prr);
	                                   wrapper.reparentedPO2PRRMap.put(po.id, partnerRRList);
		                            }
		                            finalPRRList.addAll(pRRList);
		                        }
	                    	}
                    	}
                    }
                }
            }
        }
        return finalPRRList;
    }
    
    //Create New PRR
    private static void createNewPartnerRenewalRelationship(CSM_SplitConsolidateWrapper wrapper, 
                                                           List<REN_Renews_To__c> selectedRRList,
                                                           List<CHL_Partner_Renewal_Relationship__c> finalPRRList) {  
        Map<Id, REN_Renews_To__c> selectedRRMap = new Map<Id, REN_Renews_To__c>(selectedRRList);    
        Set<Id> rliIdSet = new Set<Id>();  
        List<CHL_Partner_Renewal_Relationship__c> pRRList; 
        CHL_Partner_Renewal_Relationship__c prr;     
        Map<Id, CHL_Partner_Opportunity__c> targetPOMap = new Map<Id, CHL_Partner_Opportunity__c>(wrapper.targetPO);
        //system.debug('!!wrapper.reparentedPO2PRRMap :: '+wrapper.reparentedPO2PRRMap + '\n :: '+targetPOMap.keySet());      
        CHL_Partner_Opportunity__c poObj;                   	
        if(wrapper.targetPO != null && !wrapper.targetPO.isEmpty()) {
            for(Id po : targetPOMap.keySet()) { //wrapper.reparentedPO2PRRMap.keySet()
            	rliIdSet.addAll(selectedRRMap.keySet()); 
            	if(wrapper.reparentedPO2PRRMap.containsKey(po)) {
	            	pRRList = new List<CHL_Partner_Renewal_Relationship__c>(); 
	            	pRRList = wrapper.reparentedPO2PRRMap.get(po);
	                for(CHL_Partner_Renewal_Relationship__c prrObj : pRRList) {
	                	if(rliIdSet.contains(prrObj.CHL_Renewal_Relationship__c)) {
	                		rliIdSet.remove(prrObj.CHL_Renewal_Relationship__c);
	                	}
	                }
            	}
                for(Id rli : rliIdSet) {
                	prr = new CHL_Partner_Renewal_Relationship__c();                	
                	prr.CHL_Partner_Opportunity__c = po;
                    prr.CHL_Renewal_Relationship__c = rli;
                    poObj = targetPOMap.get(po);
                    if (UserInfo.isMultiCurrencyOrganization() && poObj!=null){
	                	prr.put('CurrencyIsoCode',poObj.get('CurrencyIsoCode'));
	                }
                    finalPRRList.add(prr);
                } 
            }
        }
    }
    
    /* US3018 - This method will update Eariest Expiration Date, Expiration Quarter and Expiration Year field of PO as per the RR details */
	private static  List<CHL_Partner_Opportunity__c> updateFieldsOnExistingPO(List<CHL_Partner_Opportunity__c> existingPoList, List<REN_Renews_To__c> selectedRRList) {
	    Map<Id,REN_Renews_To__c> OppToRRMap = new Map<Id, REN_Renews_To__c>();
	    //Created a Map having MO as Key and RR having least End Date as value.
	    List<CHL_Partner_Opportunity__c> poList = new List<CHL_Partner_Opportunity__c>();
	    if(selectedRRList != null && !selectedRRList.isEmpty()) {
			for(REN_Renews_To__c rrObj : selectedRRList ){
				if(OppToRRMap.containskey(rrObj.REN_Renews_To__c)){
					if(rrObj.REN_End_Date__c < OppToRRMap.get(rrObj.REN_Renews_To__c).REN_End_Date__c){
						OppToRRMap.put(rrObj.REN_Renews_To__c, rrObj);
					}
				}else{
					OppToRRMap.put(rrObj.REN_Renews_To__c, rrObj);
				}
			}
			
			REN_Renews_To__c rrObj;
			for(CHL_Partner_Opportunity__c poObj :existingPoList){
				rrObj = OppToRRMap.get(poObj.CHL_Opportunity__c);
				if(rrObj != null){
					poObj.CHL_Expiration_Date__c = rrObj.REN_End_Date__c;					
				}
				poObj.put('CHL_Syncing__c',null);
				poList.add(poObj);
			}
	    }
	    REN_OpportunityDataAccess.calculateExpQuarterYear(poList, CSM_Util.getNamespace()+'CHL_Expiration_Date__c');	    
		return poList;
	}
    
    public class CSM_SplitConsolidateWrapper {
    	List<CHL_Partner_Renewal_Relationship__c> pRRList {get; set;}
    	Map<Id, CHL_Partner_Opportunity__c> sourcePOMap {get; set;}
    	Map<Id, Id> targetPO2SourcePOMap {get; set;}
    	List<CHL_Partner_Opportunity__c> targetPO {get; set;}
    	List<CHL_Partner_Opportunity__c> createNewPO {get; set;}
    	List<CHL_Partner_Opportunity__c> targetPOList {get; set;}
    	Opportunity targetOpp {get; set;}
    	List<REN_Field_Mappings__c> fieldMappingListPO2PO {get; set;}
    	String actionName {get; set;}
    	Map<Id, List<CHL_Partner_Renewal_Relationship__c>> reparentedPO2PRRMap {get; set;}
    	List<REN_Renews_To__c> targetRLIsList {get; set;}
    	List<CHL_Partner_Opportunity__c> sourcePOList {get; set;}
    }
    
    /* US3021 : This method is used to create Quote and QLIs corresponding to PO on target Opportunity after Split or Consolidate. */
    
    public static void createQuoteAndQLIs(List<Opportunity> targetOppList){       //Opportunity targetOpp
        List<CHL_Opportunity_Status_Log__c> opptyStatusLogList =  CHL_OpptyStatusLogDataAccess.opptyStatusLogList;//CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
		List<CHL_Partner_Opportunity__c> poList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunityId(new Set<Id>{targetOppList[0].Id});
		Map<Id,Sobject>	quoteMap;
		if(opptyStatusLogList != null && !opptyStatusLogList.isEmpty() && poList != null && !poList.isEmpty()){
			if(opptyStatusLogList[0].CHL_Create_New_Quote_On_Destination_PO__c){
				if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) ){	
			        List<Sobject> quoteList = CHL_AddRenewalPartnerController.createQuoteForPO(targetOppList, poList, opptyStatusLogList);	
			        List<Sobject> quoteLineItemList = createQuoteLineItems(targetOppList, quoteList);
		        	
		        	if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
		        		//CHL_QuoteSyncHandler.QUOTELINEITEM_TRIGGER = false;
			        	CHL_QuoteLineItemDataAccess.insertQuotesLineItems(quoteLineItemList);
			        }
			        quoteMap = new Map<Id,Sobject>(quoteList);
			        Map<Id,CHL_Partner_Opportunity__c> poMap = new Map<Id,CHL_Partner_Opportunity__c>(poList);
			        /* Added below code to set newly added quote as Primary. */
			        List<Sobject> quotesToUpdate = CHL_QuoteSyncHandler.resetPrimaryForQuotes(quoteMap.keySet(),poMap.keySet());
			        CHL_QuoteDataAccess.updateQuotes(quotesToUpdate);
			        Set<String> quoteIdSet = new Set<String>();
			        quoteIdSet.addAll((Set<String>)JSON.deserialize(JSON.serialize(quoteMap.keySet()), Set<String>.class));
			        CHL_QuoteSyncHandler.rollupMsrpOnQuote(quoteIdSet);
				}
			}
			/* Setting Amount on PO based on QLI amount. */
			if(quoteMap != null && !quoteMap.isEmpty()){
				CHL_AddRenewalPartnerController.updatePartnerOpptyFields(quoteMap.keySet(),poList);
			}		
	        if(poList != null && !poList.isEmpty()){
	        	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
				CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
				CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(poList);
	        }
		}		
	}
	
	/* US3021 : This method returns list of QLIs which need to insert using RLI --> QLI mapping. */
	
	private static List<Sobject> createQuoteLineItems(List<Opportunity> targetOpportunityList, List<Sobject> targetQuoteList){
		List<Sobject> quoteLineItemList = new List<Sobject>();
		Set<Id> productIdsSet = new Set<Id>();
		Set<Id> poIdsSet = new Set<Id>();
		Decimal totalPrice = 0.0;
		Sobject quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
		Map<String, Schema.SobjectField> fieldDescriptionMap = CSM_AccessController.fetchAllFieldNames(quoteLineObj.getSobjectType());		
		List<REN_Field_Mappings__c> fieldMappingRliToQliList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(CHL_Constants.OBJ_QUOTELINEITEM, CSM_Util.getNamespace()+REN_Constants.OBJ_RENEW_LINE_ITEM);				
		
		Set<String> rliFldstoQuery = new Set<String> {'Id','REN_Product__c'};
		REN_Util.getFromAndToFldsToQuery(fieldMappingRliToQliList,rliFldstoQuery,null);	
		List<REN_Renews_To__c> targetRLIsList = REN_RenewRelationshipDataAccess.getRenewalRelationshipByOpportunityIds(new Set<Id>{targetOpportunityList[0].Id},rliFldstoQuery,rliFldstoQuery,null);
		for(REN_Renews_To__c rli : targetRLIsList){
			productIdsSet.add(rli.REN_Product__c);
			totalPrice = rli.REN_Previous_Price__c != null? (totalPrice+ rli.REN_Previous_Price__c) : (totalPrice + 0);
		}
		if(SS_Constants.isSimplifiedDataModelEnabled){	
        	SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
	        Map<Id,PriceBookEntry> mapofOppToPBE;
	        if(productIdSetting.Renewal_Amount_Product_Id__c != null){
	         	mapofOppToPBE = REN_PricebookDataAccess.getOppToPbEntry(targetOpportunityList, productIdSetting.Renewal_Amount_Product_Id__c);
	        }
	        for(sObject quoteObj : targetQuoteList){						
		        quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
				quoteLineObj.put(REN_Constants.OBJ_ASSET_PRODUCT2ID, productIdSetting.Renewal_Amount_Product_Id__c);
	    		quoteLineItemList.add(CHL_AddRenewalPartnerController.getAggregateQLIObject(quoteObj, quoteLineObj, targetOpportunityList[0], totalPrice, mapofOppToPBE)); 
	        }
    	}else{	
			Boolean hasPOFieldOnQuote = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
			if(hasPOFieldOnQuote) {
				for(sObject quoteObj : targetQuoteList){
					poIdsSet.add((ID)quoteObj.get(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c'));
				}		
			}
			Map<Id, Map<Id,CHL_Partner_Renewal_Relationship__c>> poToRliToPrrMap = getRliIdToPrrMapByPo(poIdsSet);		
			Map<Id, PricebookEntry> prodIdToPriceBookEntryMap = REN_PricebookDataAccess.getProductIdToPriceBookEntryMap(targetOpportunityList , productIdsSet);
			if(targetQuoteList != null){
				for(sObject quoteObj : targetQuoteList){
					for(REN_Renews_To__c rli : targetRLIsList){
						quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();					
						quoteLineObj = CHL_AddRenewalPartnerController.getQLIObjectBasedOnRLI(quoteObj,quoteLineObj,fieldDescriptionMap,fieldMappingRliToQliList,rli,prodIdToPriceBookEntryMap);
				        if(hasPOFieldOnQuote && poToRliToPrrMap.containsKey((ID)quoteObj.get(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c'))){
			        		Map<Id,CHL_Partner_Renewal_Relationship__c> rliIdToPrrRecMap = poToRliToPrrMap.get((ID)quoteObj.get(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c'));
			        		if(rliIdToPrrRecMap.containsKey(rli.Id)){
			        			if(rliIdToPrrRecMap.get(rli.Id).CHL_Incumbent__c == false){
			        				quoteLineObj.put(REN_Constants.OBJ_OLI_UNITPRICE, 0);
			        			}
			        		}
				        }
				        quoteLineItemList.add(quoteLineObj);	
					}
				}
			}
		}
		return quoteLineItemList;
	}
	
	/* US3021 & US3042 : This method is used to get map of RLI and its corressponding PRR based on Partner Opportunity. 
				This map will be used to check Incumbent flag on PRR. */
	
	private static Map<Id, Map<Id,CHL_Partner_Renewal_Relationship__c>> getRliIdToPrrMapByPo(Set<Id> poIdsSet){
		Map<Id, Map<Id,CHL_Partner_Renewal_Relationship__c>> poToRliToPrrMap = new Map<Id, Map<Id,CHL_Partner_Renewal_Relationship__c>>();
		Map<Id,List<CHL_Partner_Renewal_Relationship__c>> poToPrrMap = CHL_PartnerRenRelationshipDataAccess.getPO2PRRMap(poIdsSet);
		if(poToPrrMap != null){
			for(Id poId : poToPrrMap.keySet()){
				List<CHL_Partner_Renewal_Relationship__c> prrList = poToPrrMap.get(poId);
				Map<Id,CHL_Partner_Renewal_Relationship__c> rliIdToPrrMap = new Map<Id,CHL_Partner_Renewal_Relationship__c>();
				for(CHL_Partner_Renewal_Relationship__c prr : prrList){
					rliIdToPrrMap.put(prr.CHL_Renewal_Relationship__c, prr);
				}			
				poToRliToPrrMap.put(poId,rliIdToPrrMap);
			}
		}
		return poToRliToPrrMap;
	}
	
	/*US3135 : This method is used to reset PO syncing after Split/Consolidate. */
	
	private static List<CHL_Partner_Opportunity__c> resetPOSyncing(List<CHL_Partner_Opportunity__c> sourcePOList){
		List<CHL_Partner_Opportunity__c> resetPOsList = new List<CHL_Partner_Opportunity__c>();
		for(CHL_Partner_Opportunity__c poObj : sourcePOList){
			if (String.isNotBlank(poObj.CHL_Syncing__c)) {
				poObj.put('CHL_Syncing__c',null);
				resetPOsList.add(poObj);
			}
		}
		return resetPOsList;
	}
}