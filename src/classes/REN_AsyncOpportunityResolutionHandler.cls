public with sharing class REN_AsyncOpportunityResolutionHandler {
    
    private static final Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
                                                            REN_Constants.OBJ_OPPORTUNITY, 
                                                            CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
    private static REN_Opportunities opptyRenewal = new REN_Opportunities();
    private static REN_ServiceContracts scRenewal = new REN_ServiceContracts();
    
    
    /**
     * @description Create ARP records based on Opportunity generation/Install base criteria
     * @param opportunityList: A list of Opportunity to process for arp
     * @return: void 
     */
    public static void handleRenewProcessGeneration(List<Opportunity> opportunityList){
        List<REN_Renewal_Processing_Status__c> lstOfRenProcess = new List<REN_Renewal_Processing_Status__c>();
        Map<Id, Opportunity> originalOpptyMap = new Map<Id,Opportunity>(opportunityList);
        List<Opportunity> filteredOpportunityOppList = opptyRenewal.applyOpportunityCriteria(originalOpptyMap.keySet(), REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, (REN_Constants.OBJ_OPPORTUNITY + ':' + REN_Constants.OBJ_OPPORTUNITY));
        List<Opportunity> filteredOpportunityForSc = scRenewal.applyOpportunityCriteria(originalOpptyMap.keySet(), REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT, (REN_Constants.OBJ_SERVICE_CONTRACT + ':' + REN_Constants.OBJ_OPPORTUNITY));
        Map<Id, Opportunity> mapOfFilteredOpp = new Map<Id, Opportunity>(filteredOpportunityOppList);
        for(Opportunity opp: filteredOpportunityForSc){
        	if(!mapOfFilteredOpp.containsKey(opp.Id)){
        		mapOfFilteredOpp.put(opp.Id,opp);
        	}
        }
        List<Opportunity> filteredOpportunityList = mapOfFilteredOpp.values();
        List<Opportunity> filteredOppForAddOn = new List<Opportunity>(filteredOpportunityList);
        List<Opportunity> opptyListWithAddOn = opptyRenewal.findAddOnOpportunities(filteredOppForAddOn);
        opptyRenewal.handleOpportunityWithAddOn(originalOpptyMap,opptyListWithAddOn);
        
        if(filteredOpportunityList != null && !filteredOpportunityList.isEmpty()){
            for(Opportunity opp: filteredOpportunityList){
                REN_Renewal_Processing_Status__c renProcess = new REN_Renewal_Processing_Status__c(REN_Source_Opportunity__c = opp.Id);
                lstOfRenProcess.add(renProcess);
            }
            REN_RenewalProcessingStatusDataAccess.saveProcessingStatusRecords(lstOfRenProcess);
        }
        
    }
    
    public static void handleAsyncRenewalUpdate(List<Opportunity> opportunityList, Map<ID, List<OpportunityLineItem>> mapOfOppToOliCLI, Map<ID, List<OpportunityLineItem>> mapOfOppToOli){
        if(opportunityList != null && !opportunityList.isEmpty()){
        	List<Opportunity> lstOfOpp = new List<Opportunity>();
            List<Opportunity> lstOfOppWithoutRenewSC = new List<Opportunity>();
                
            for(Opportunity opp: opportunityList){
            	if(mapOfOppToOli.containsKey(opp.Id)){
            		lstOfOpp.add(opp);
            	}else if(mapOfOppToOliCLI.containsKey(opp.Id)){
            		lstOfOppWithoutRenewSC.add(opp);
            	}
            }
            Map<Id, Opportunity> sourceOpptyMap = new Map<Id, Opportunity>(lstOfOpp);
            system.debug('*****************opportunityList  ::'+opportunityList);
            //Create a wrapper with source as well as add on opp renewal target map with original opportunity ID.
            REN_RenewalWrapper wrapper = createRenewalOpportunities(sourceOpptyMap);
            
            List<SObject> serviceContractList = createRenewalServiceContracts(sourceOpptyMap);
            Map<Id, REN_Source__c> opptyToSourceMap;
            if(entitlementPkgInstalled && serviceContractList != null && !serviceContractList.isEmpty()){
                opptyToSourceMap = scRenewal.createSourceForSC(serviceContractList, sourceOpptyMap);
                updateRenewalOpptyOnSc(serviceContractList, wrapper.opptyToRenewalMap);
            }
            saveSources(wrapper.sourceList, opptyToSourceMap);
            
            // US2774: After process Qualified OLI we need to process OLI which are qualified only for CLI.
            // below code will update ARP record based on service contract, without any Source record or Renewal Opportunity.
            if(lstOfOppWithoutRenewSC != null && !lstOfOppWithoutRenewSC.isEmpty()){
        		List<SObject> serviceContractListWithoutRenew = createRenewalServiceContracts(new Map<Id, opportunity>(lstOfOppWithoutRenewSC));
            	Map<Id,Id> mapOfOppToSC = new Map<Id,Id>();
            	Set<Id> setOfContributorId = new Set<Id>();
            	if(serviceContractListWithoutRenew != null){
            		for(sObject sc : serviceContractListWithoutRenew){
            			setOfContributorId.add((Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID));
            			mapOfOppToSC.put((Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID), (Id)sc.get('Id'));
            		}
            	}
            	List<REN_Renewal_Processing_Status__c> lstOfArp= REN_RenewalProcessingStatusDataAccess.getProcessingStatusRecBySourceOppId(setOfContributorId);
            	updateARPRecords(lstOfArp,mapOfOppToSC);
            }
        }
    }
    
    /**
     * @description Update ARP records for Opportunity which qualified only for Service Contract.
     * @param lstOfArp: A list of ARP to update and map of opportunity to service contract.
     * @param mapOfOppToSrvContract: Map of opportunity to ServiceContract
     * @return: void 
     */
    private static void updateARPRecords(List<REN_Renewal_Processing_Status__c> lstOfArp, Map<Id, Id> mapOfOppToSrvContract){
    	  for(REN_Renewal_Processing_Status__c renProcess : lstOfArp){
    		if(entitlementPkgInstalled){
    			renProcess.put(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c', mapOfOppToSrvContract.get(renProcess.REN_Source_Opportunity__c));
    		}
    	  }
    	   REN_RenewalProcessingStatusDataAccess.updatProcessingStatusRecords(lstOfArp);
    	  
    }
    private static void updateRenewalOpptyOnSc(List<SObject> serviceContractList, Map<Id, Opportunity> opptyToRenewalMap){
        List<SObject> scToUpdateList = new List<SObject>();
        List<Opportunity> opptyList = new List<SObject>();
        for(SObject serviceContract : serviceContractList){
            Id sourceOpptyId = (Id)serviceContract.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID);
            if(opptyToRenewalMap.containsKey(sourceOpptyId)){
                Opportunity renewalOppty = opptyToRenewalMap.get(sourceOpptyId);
                if(renewalOppty != null){
                    serviceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID, renewalOppty.Id);
                    renewalOppty.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT, serviceContract.Id);
                    scToUpdateList.add(serviceContract);
                    opptyList.add(renewalOppty);
                }
            }
        }
        if(!scToUpdateList.isEmpty()){
            update scToUpdateList;
        }
        if(!opptyList.isEmpty()){
            update opptyList;
        }
    }
    
    private static void saveSources(List<REN_Source__c> sourceList, Map<Id, REN_Source__c> opptyToSourceMap){
        List<REN_Source__c> sourceListToInsert = new List<REN_Source__c>();
        REN_Source__c sourceForSC = new REN_Source__c();
        List<REN_Renewal_Processing_Status__c> renProcessingStatusList = new List<REN_Renewal_Processing_Status__c>();
        Set<Id> sourceContributorID = new Set<Id>();
        Map<Id,REN_Renewal_Processing_Status__c> mapSourceOppToRenProcess = new Map<Id,REN_Renewal_Processing_Status__c>();
        if(sourceList != null && !sourceList.isEmpty()){
            sourceListToInsert.addAll(sourceList);
            for(REN_Source__c source: sourceList){
                sourceContributorID.add(source.REN_Contributor__c);
            }
            
            List<REN_Renewal_Processing_Status__c> lstOfArp= REN_RenewalProcessingStatusDataAccess.getProcessingStatusRecBySourceOppId(sourceContributorID);
            for(REN_Renewal_Processing_Status__c renProcess: lstOfArp){
                mapSourceOppToRenProcess.put(renProcess.REN_Source_Opportunity__c,renProcess);
            }
            
            for(REN_Source__c source : sourceList){
                if(opptyToSourceMap != null && source.REN_Contributor__c != null && opptyToSourceMap.containsKey(source.REN_Contributor__c)){
                    sourceForSC = opptyToSourceMap.get(source.REN_Contributor__c);
                    sourceForSC.REN_Inheriting_Opportunity__c = source.REN_Inheriting_Opportunity__c;
                    sourceListToInsert.add(sourceForSC);
                }
                updateRenewalProcessingStatus(source, sourceForSC, mapSourceOppToRenProcess);
            }
            if(!sourceListToInsert.isEmpty()){
                REN_SourceDataAccess.saveSourceRecords(sourceListToInsert);
                setSourcesOnRPS(sourceListToInsert, mapSourceOppToRenProcess.values());
                REN_RenewalProcessingStatusDataAccess.updatProcessingStatusRecords(mapSourceOppToRenProcess.values());  
            }
        }
    }

    private static void setSourcesOnRPS(List<REN_Source__c> sourceList, List<REN_Renewal_Processing_Status__c> renProcessingStatusList){
        Map<ID, REN_Source__c> renewedOpp2SourceMap = new Map<ID, REN_Source__c>();
        Map<ID, REN_Source__c> sc2SourceMap = new Map<ID, REN_Source__c>();
        
        for(REN_Source__c s: sourceList){
            if(s.REN_Contributor__c != null){
                renewedOpp2SourceMap.put(s.REN_Contributor__c, s);
            }
            if(entitlementPkgInstalled && s.get(CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c') != null){
                sc2SourceMap.put((ID)s.get(CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c'), s);
            }
        }
        for(REN_Renewal_Processing_Status__c rps : renProcessingStatusList){
            if(rps.REN_Source_Opportunity__c != null && renewedOpp2SourceMap.containsKey(rps.REN_Source_Opportunity__c)){
                rps.REN_Source_for_Renewed_Opportunity__c = renewedOpp2SourceMap.get(rps.REN_Source_Opportunity__c).id;
            }
            if(entitlementPkgInstalled){
                Id scId = (Id)rps.get(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
                if(scId != null && sc2SourceMap.containsKey(scId)){
                    rps.put(CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c', 
                            sc2SourceMap.get((Id)rps.get(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c')).id);
                }
            }
        }
    }
    
    private static REN_Renewal_Processing_Status__c updateRenewalProcessingStatus(REN_Source__c source, REN_Source__c sourceForSC,Map<Id,REN_Renewal_Processing_Status__c> mapSourceOppToRenProcess) {
        REN_Renewal_Processing_Status__c renProcessingStatus = mapSourceOppToRenProcess.get(source.REN_Contributor__c);
        if(renProcessingStatus!=null){
            renProcessingStatus.REN_Renewal_Opportunity__c = source.REN_Inheriting_Opportunity__c;
            if(entitlementPkgInstalled && String.isNotBlank((String)sourceForSC.get(CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c'))) {
                renProcessingStatus.put(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c',(String)sourceForSC.get(CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c'));
            }
        }
        return renProcessingStatus;
    }
    
    private static REN_RenewalWrapper createRenewalOpportunities(Map<Id, Opportunity> originalOpptyMap){
        REN_RenewalWrapper wrapper = new REN_RenewalWrapper();
        
        List<Opportunity> filteredOpportunityList = opptyRenewal.applyOpportunityCriteria(originalOpptyMap.keySet(), REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,(REN_Constants.OBJ_OPPORTUNITY + ':' + REN_Constants.OBJ_OPPORTUNITY));
        
        List<REN_Source__c> sourceList = new List<REN_Source__c>();
        if(!filteredOpportunityList.isEmpty()){
            List<Opportunity> opptyListWithAddOn = opptyRenewal.findAddOnOpportunities(filteredOpportunityList);
            Map<Id, SObject> sourceToRenewOpptyMap = new Map<Id, SObject>();
            Map<Id, Opportunity> sourceToRenewedObjMap = new Map<Id, Opportunity>();
            List<Opportunity> opportunityList = new List<Opportunity>();
            Opportunity renewedOppty;
            Boolean hasOppNameField = CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c');
            if(!filteredOpportunityList.isEmpty()){
                sourceToRenewOpptyMap = opptyRenewal.createRenewalsMap(filteredOpportunityList, null);
                if(!sourceToRenewOpptyMap.values().isEmpty()){
                    insert sourceToRenewOpptyMap.values();
                    for(Id opptyId : sourceToRenewOpptyMap.keySet()) {
                        renewedOppty = (Opportunity)sourceToRenewOpptyMap.get(opptyId);
                        if(hasOppNameField){
        					renewedOppty.put('Opportunity_Name__c',renewedOppty.Name);
        				}
                        sourceToRenewedObjMap.put(opptyId, renewedOppty);
                    }
                    sourceList = opptyRenewal.createSource(sourceToRenewOpptyMap);
                }
            }
            opptyRenewal.handleOpportunityWithAddOn(originalOpptyMap,opptyListWithAddOn, sourceList);
            wrapper.sourceList = sourceList;
            system.debug('\n wrapper.sourceList::::'+wrapper.sourceList);
            wrapper.opptyToRenewalMap = createSourceToRenewalOpptyMap(opptyListWithAddOn, sourceToRenewedObjMap);
            system.debug('\n wrapper.opptyToRenewalMap::::'+wrapper.opptyToRenewalMap);
        }
        return wrapper;
    }
    
    private static Map<Id, Opportunity> createSourceToRenewalOpptyMap(List<Opportunity> opptyListWithAddOn, Map<Id, Opportunity> opptyToRenewalOpptyMap){
        if(opptyListWithAddOn != null && !opptyListWithAddOn.isEmpty()){
            for(Opportunity oppty : opptyListWithAddOn){
                opptyToRenewalOpptyMap.put(oppty.Id, new Opportunity(Id = oppty.REN_Append_Renewal_Opportunity__c));
            }
        }
        return opptyToRenewalOpptyMap;
    }
    
    private static List<SObject> createRenewalServiceContracts(Map<Id, Opportunity> sourceOpptyMap){
        List<SObject> serviceContractList = new List<SObject>();
        List<REN_Source__c> sourceList = new List<REN_Source__c>();
        if(entitlementPkgInstalled){
            List<Opportunity> filteredOpportunityList = scRenewal.applyOpportunityCriteria(sourceOpptyMap.keySet(), REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,(REN_Constants.OBJ_SERVICE_CONTRACT + ':' + REN_Constants.OBJ_OPPORTUNITY));
            if(!filteredOpportunityList.isEmpty()){
                List<Opportunity> addOnOpptyList = new List<Opportunity>();
                List<SObject> appendedSCList = new List<SObject>();
                scRenewal.filterAppendedServiceContracts(filteredOpportunityList, addOnOpptyList, appendedSCList);
                if(!filteredOpportunityList.isEmpty()){
                    serviceContractList = scRenewal.createRenewals(filteredOpportunityList, null);
                    REN_ServiceContractsDataAccess.insertServiceContractList(serviceContractList);
                }
                appendedSCList = scRenewal.validateAddOnSC(appendedSCList, addOnOpptyList);
                if(appendedSCList != null && !appendedSCList.isEmpty()){
                    update appendedSCList;
                    serviceContractList.addAll(appendedSCList);
                }
            }
        }
        return serviceContractList;
    }
    
    public class REN_RenewalWrapper {
        public List<REN_Source__c> sourceList;
        public Map<Id, Opportunity> opptyToRenewalMap;
    }
}