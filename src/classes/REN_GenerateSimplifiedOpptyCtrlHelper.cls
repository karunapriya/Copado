/**
 * Created Date     : Jul 19, 2017
 * Developed By     : Dheeraj, Comity Designs, Inc.
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
 * Dheeraj                  User Story              Jul 19, 2017            1.1                 @description
 * 
 */
public with sharing class REN_GenerateSimplifiedOpptyCtrlHelper {
    private static final Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
                                                            REN_Constants.OBJ_OPPORTUNITY, 
                                                            CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
    public REN_GenerateSimplifiedOpptyCtrlHelper() {
      
    }
    
    public List<REN_Field_Mappings__c> getOpportunityMapping(String toObj,String fromObj){
        return REN_FieldMappingsDataAccess.getFieldMappingListByConfig(toObj,fromObj);
    }
    
    public Opportunity getNewOpportunity(List<REN_Field_Mappings__c> fldMapping,sObject objToMap){
        Opportunity oppToCreate = new Opportunity();
        Schema.SObjectType objectOpportunity = new Opportunity().getSobjectType();
        Map <String, Schema.SobjectField> opportunityFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpportunity);
        
        REN_Util.copyObjectUsingAdminMapping(objToMap, 
                                             oppToCreate, 
                                             opportunityFieldNames, 
                                             fldMapping);        
      
        return oppToCreate;
    }
    
    public Map<String,List<REN_Renews_To__c>> getRLIList(List<REN_Field_Mappings__c> lstOfMapping, List<sObject> lstOfObj,String objType){
        Map<String,List<REN_Renews_To__c>> mapOfOliToRli = new Map<String,List<REN_Renews_To__c>>();
        
        Schema.SObjectType objectRLI = new REN_Renews_To__c().getSobjectType();
        Map <String, Schema.SobjectField> rliFieldNames = CSM_AccessController.fetchAllFieldNames(objectRLI);
        
            if(lstOfMapping!=null && lstOfObj != null){
                for(sObject obj: lstOfObj){
                    REN_Renews_To__c rli = new REN_Renews_To__c();
                    rli.REN_Quantity__c = 1;
                    if(objType.equals('OpportunityLineItem')){
                        rli.REN_Product__c = (Id)obj.get('Product2Id');
                        rli.REN_Start_Date__c =(Date)obj.get('REN_Start_Date__c'); 
                        rli.REN_End_Date__c = (Date)obj.get('REN_End_Date__c');
                        rli.REN_Total_Price__c = 0;
                        rli.REN_Previous_Price__c = 0;
                        rli.REN_Renewal_Target_Multiplier__c = 1;
                    }else if(objType.equals('Asset')){
                        rli.REN_Total_Price__c = 0;
                        rli.REN_Product__c = (Id)obj.get('Product2Id');
                        rli.REN_Previous_Price__c = 0;
                        rli.REN_Renewal_Target_Multiplier__c = 1;
                    }else if(objType.equals(REN_Constants.OBJ_SERVICE_CONTRACT)){
                    	rli.REN_Product__c = (Id)obj.getSObject('PricebookEntry').get('Product2Id');
                    }
                    REN_Util.copyObjectUsingAdminMapping(obj, 
                                             rli, 
                                             rliFieldNames, 
                                             lstOfMapping);
                    
                    List<REN_Renews_To__c> lstOfRli =mapOfOliToRli.get(''+obj.get('Id'));
                    if(lstOfRli==null){
                        lstOfRli = new List<REN_Renews_To__c>();
                    }
                    lstOfRli.add(rli);
                    mapOfOliToRli.put(''+obj.get('Id'),lstOfRli);
                    
                }
            }
        return mapOfOliToRli;
    }
    
    public Map<String,OpportunityLineItem> getValidOli(String sObjectName,Id oppId){
        List<OpportunityLineItem> lstOfOli = new List<OpportunityLineItem>();
        Map<String,List<OpportunityLineItem>> mapOfOppToOli = new Map<String,List<OpportunityLineItem>>();
        Map<String, OpportunityLineItem> allOpptLinesMap;
        Map<String,OpportunityLineItem> allOppLinesSC;
        
        if(sObjectName == REN_Constants.OBJ_ASSET){
            lstOfOli = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new Set<String>{oppId});            
           
            if(lstOfOli!=null){
                mapOfOppToOli.put(oppId, lstOfOli);
                allOpptLinesMap = REN_OpportunityResolutionTriggerHandler.createOpportunityLineItemsMap(mapOfOppToOli, true, REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET);
            }
            return allOpptLinesMap;
        }else if(sObjectName == REN_Constants.OBJ_SERVICE_CONTRACT){
            lstOfOli = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new Set<String>{oppId});
            if(lstOfOli!=null){
                mapOfOppToOli.put(oppId, lstOfOli);
                allOppLinesSC = REN_OpportunityResolutionTriggerHandler.createOpportunityLineItemsMap(mapOfOppToOli, true, REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM);
            }
            //system.debug('All Opp Line SC ==>> '+allOppLinesSC);
            return allOppLinesSC;
        }
        return null;
    }
    
    public Map<String,Asset> createAssets(Map<String,OpportunityLineItem> mapOffilteredOli,List<REN_Field_Mappings__c> oli2AssetFieldMappings){
        Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap = new Map<String, OpportunityLineItem>();
        Map<String, Asset> oldOpptLineId2NewAssetMap = new Map<String, Asset>();
        Schema.SObjectType objectAsset = new Asset().getSobjectType();
        Map<String, Schema.SobjectField> assetAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectAsset);
        set<String> assetFieldAddSet = new set<String>{'Product2Id'};
        
        for(OpportunityLineItem olOld :mapOffilteredOli.values()){
            //system.debug('olOld : ' + olOld);
            Asset assetNew = new Asset(Name = olOld.Name);
            if (UserInfo.isMultiCurrencyOrganization()){
                CSM_Util.setAppliedCurrency(assetNew, (String)olOld.get('CurrencyIsoCode')); //US452
            }
            for(String fieldName :assetAllFieldNames.keySet())
            {
                if(assetFieldAddSet.contains(fieldName))
                {
                    assetNew.put(fieldName, olOld.get(fieldName));
                }
            }
            oldOpptLineId2NewAssetMap.put(olOld.Id, assetNew);
            oldOpptLineId2OldOpptLineMap.put(olOld.Id, olOld);
        }
        
        for(String opLnId :oldOpptLineId2NewAssetMap.keySet())
        {
            Asset newAsset = oldOpptLineId2NewAssetMap.get(opLnId);
            for(REN_Field_Mappings__c fMapping :oli2AssetFieldMappings)
            {
                SObjectField assetSObjectFld = assetAllFieldNames.get(fMapping.REN_To_Field_API_Name__c);
                newAsset = REN_Util.getMappedLineItemBasedAsset(newAsset, opLnId, String.valueOf(assetSObjectFld.getDescribe().getType()),
                        oldOpptLineId2OldOpptLineMap, fMapping.REN_Default_Value__c, 
                        fMapping.REN_To_Field_API_Name__c, fMapping.REN_From_Field_API_Name__c);
                //system.debug('newAsset : ' + newAsset);
            }
            newAsset.REN_Oppty_Line_Item_Id__c = opLnId;
            //oldOpptLineId2NewAssetMap.put(opLnId, newAsset);
        }
        return oldOpptLineId2NewAssetMap;   
    }
    
    public List<Asset> getAssetsDetail(List<String> assetIdList){
        List<Asset> assetList = new List<Asset>();
        
        if(!assetIdList.isEmpty()){
            List<REN_Field_Mappings__c> asset2RliFieldMappings = getOpportunityMapping(REN_Constants.OBJ_RENEW_LINE_ITEM,REN_Constants.OBJ_ASSET);
            List<REN_Field_Mappings__c> asset2OFieldMappings = getOpportunityMapping(
                                  REN_Constants.OBJ_OPPORTUNITY,
                                  REN_Constants.OBJ_ASSET);
            Set<String> fieldSet = REN_Util.getFromFldsToQuery(asset2RliFieldMappings);
            fieldSet.addAll(REN_Util.getFromFldsToQuery(asset2OFieldMappings));  
            system.debug('Assets fields List '+fieldSet);                    
            if(UserInfo.isMultiCurrencyOrganization()){
              fieldSet.add(REN_Constants.REN_CURRENCY_ISO_CODE);
            }
            fieldSet.add('REN_Opportunity__c');
            fieldSet.add('Price');
            fieldSet.add('Name');
            assetList = REN_AssetDataAccess.getAssetDetailsById(assetIdList, fieldSet);
           
           return assetList;
       }
       return null;
    }
    
    public Map<String,sObject> getContractLineItem(List<Opportunity> lstOfOpp,List<sObject> serviceContractLst,List<OpportunityLineItem> filteredOldOpportunityLineItemList){
            List<sObject> lstOfCLI = new List<sObject>();
            set<String> contractLineFieldAddSet = new set<String>{REN_Constants.OBJ_OLI_UNITPRICE,REN_Constants.OBJ_OLI_QUANTITY};
            List<REN_Field_Mappings__c> oli2cliFieldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_CONTRACT_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS);
        //if(entitlementPkgInstalled){
            Map<String,String> mapOfOpp2SC = new Map<String,String>();
            if(!lstOfOpp.isEmpty() && !serviceContractLst.isEmpty()){
                mapOfOpp2SC.put(''+lstOfOpp.get(0).Id,''+serviceContractLst.get(0).get('Id'));
            }
            
            Schema.SObjectType objectServiceContract = CSM_AccessController.getObjectType(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
            
            Map<String, Schema.SobjectField> contractLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectServiceContract);

            Map<String, SObject> currentOpptLineId2NewContractLineMap = new Map<String, SObject>();
            Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap = new Map<String, OpportunityLineItem>();
            
            for(OpportunityLineItem oli :filteredOldOpportunityLineItemList){
                if (mapOfOpp2SC.containsKey(oli.OpportunityId)){
                    SObject contractLineItemNew = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
                    contractLineItemNew.put('ServiceContractId', mapOfOpp2SC.get(oli.OpportunityId));
                    contractLineItemNew.put('PricebookEntryId', (String)oli.PricebookEntryId);
                    if(oli.REN_Covered_Asset__c != null){
                        contractLineItemNew.put('AssetId',oli.REN_Covered_Asset__c);
                    }
                    for(String fieldName :contractLineAllFieldNames.keySet()) {
                        if(contractLineFieldAddSet.contains(fieldName)) {
                            contractLineItemNew.put(fieldName, oli.get(fieldName));
                        }
                    }
                    currentOpptLineId2NewContractLineMap.put(oli.Id, contractLineItemNew);
                    oldOpptLineId2OldOpptLineMap.put(oli.Id, oli);
                }
            }
            
            for(String opLnId :currentOpptLineId2NewContractLineMap.keySet())
            {
                SObject newContractLineItem = currentOpptLineId2NewContractLineMap.get(opLnId);
                for(REN_Field_Mappings__c fMapping :oli2cliFieldMappings)
                {
                    SObjectField contractLineItemSObjectFld = contractLineAllFieldNames.get(fMapping.REN_To_Field_API_Name__c);
                    newContractLineItem = REN_Util.getMappedLineItemBasedContractLineItem(newContractLineItem, opLnId, String.valueOf(contractLineItemSObjectFld.getDescribe().getType()),
                            oldOpptLineId2OldOpptLineMap, fMapping.REN_Default_Value__c, 
                            fMapping.REN_To_Field_API_Name__c, fMapping.REN_From_Field_API_Name__c);
                }
                // VCP - ORG21 check
                if(CSM_AccessController.hasField(REN_Constants.OBJ_CONTRACT_LINE_ITEM, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID)){
                    newContractLineItem.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID, opLnId);
                }
                currentOpptLineId2NewContractLineMap.put(opLnId, newContractLineItem);
            }
            for(SObject c :currentOpptLineId2NewContractLineMap.values()) {
                lstOfCLI.add(c);
            }
            insert lstOfCLI;
        //}
        return currentOpptLineId2NewContractLineMap;
    }
    public void createSourceOutBoundForOpp(Map<String,String> mapOfInToOut){
    	List<String> sourceFieldsList = new List<String>{'REN_Type__c','REN_Reason__c','REN_Inheriting_Opportunity__c','REN_Contributor__c'};
        CSM_Util.checkCRUD_FLS('REN_Source__c', sourceFieldsList,CSM_Constants.DML_OPERATION_INSERT);
        
    	List<REN_Source__c> srcLst = new List<REN_Source__c>();
    	for(String inSrc:mapOfInToOut.keyset()){
    		REN_Source__c src = new REN_Source__c();
    		src.REN_Contributor__c = mapOfInToOut.get(inSrc);
    		src.REN_Inheriting_Opportunity__c = inSrc; 
    		src.REN_Reason__c = REN_Constants.REN_REASON_MAN_REN;
    		src.REN_Type__c = 'Opportunity';
    		srcLst.add(src);
    	}
    	insert srcLst;
    }
    public void createSourceOutBoundForSC(Map<String,String> mapOfInToOut){
    	List<String> sourceFieldList = new List<String>{'REN_Type__c','REN_Reason__c','REN_Inheriting_Opportunity__c'};
        CSM_Util.checkCRUD_FLS('REN_Source__c', sourceFieldList,CSM_Constants.DML_OPERATION_INSERT);
        
    	List<REN_Source__c> srcLst = new List<REN_Source__c>();
    	for(String inSrc:mapOfInToOut.keyset()){
    		REN_Source__c src = new REN_Source__c();
    		src.REN_Inheriting_Opportunity__c = mapOfInToOut.get(inSrc);
    		src.REN_Reason__c = REN_Constants.REN_REASON_MAN_REN;
    		src.REN_Type__c = 'Service Contract';
    		if(entitlementPkgInstalled){
    			src.put(CSM_Util.nameSpacePrefix21+'REN_Contributor_SC__c',inSrc); 
    		}
    		srcLst.add(src);
    	}
    	insert srcLst;
    }
    public list<Sobject> getServiceContract(Map<String,String> srcInAndOutMapSC,List<Opportunity> currentOpp,Opportunity renewOpportunity,Map<String,OpportunityLineItem> mapOfOliForSC){
        List<sObject> lstOfSc = new List<sObject>();
        REN_ServiceContracts scHelper = new REN_ServiceContracts();
        if(currentOpp.get(0).get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT)==null){ 
            if(!mapOfOliForSC.isEmpty()){
                Map<Id,Id> sourceToTarget = new Map<Id,Id>();
                sourceToTarget.put(currentOpp.get(0).Id,renewOpportunity.id);
                lstOfSc = scHelper.createRenewals(currentOpp,sourceToTarget);
                REN_ServiceContractsDataAccess.insertServiceContractList(lstOfSc);
                if(lstOfSc!=null && lstOfSc.size()>0){
                    srcInAndOutMapSC.put(''+lstOfSc.get(0).get('Id'),''+renewOpportunity.Id);
                }
                renewOpportunity.put((CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT),lstOfSc.get(0).Id);
            }
        }else{
            SObject newServiceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICE_CONTRACT);
            newServiceContract.put('Id',(Id)currentOpp.get(0).get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT));
     
            renewOpportunity.put((CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT), 
            	currentOpp.get(0).get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT)
            );
           
            if(!mapOfOliForSC.isEmpty()){
                srcInAndOutMapSC.put(''+newServiceContract.get('Id'),''+renewOpportunity.Id);
            }
        	lstOfSc.add(newServiceContract);
        }
        REN_OpportunityDataAccess.updateOpportunitySObject(new List<Opportunity>{renewOpportunity}, new List<String>{CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT});
        return lstOfSc;
    }    
     public Opportunity getRenewOpp(List<Asset>lstOfAsset,List<Opportunity> currentOpp,String assetsId,List<sObject> scLst){
        Opportunity renewOpportunity = new Opportunity();
        if(currentOpp!=null && currentOpp.size()>0){
            if(assetsId==null){
                renewOpportunity = getNewOpportunity(getOpportunityMapping(REN_Constants.OBJ_OPPORTUNITY,REN_Constants.OBJ_OPPORTUNITY),currentOpp.get(0));
                renewOpportunity.Pricebook2Id = currentOpp.get(0).pricebook2Id;
                if (UserInfo.isMultiCurrencyOrganization()){
                    renewOpportunity.put('CurrencyIsoCode',currentOpp.get(0).get('CurrencyIsoCode'));
                }
            }else{
                renewOpportunity = getNewOpportunity(getOpportunityMapping(
                                  REN_Constants.OBJ_OPPORTUNITY,
                                  REN_Constants.OBJ_ASSET),lstOfAsset.get(0));
                renewOpportunity.Pricebook2Id = getStdPriceBook().Id;
            }
            
        }else if(!lstOfAsset.isEmpty()){
            renewOpportunity = getNewOpportunity(getOpportunityMapping(
                                  REN_Constants.OBJ_OPPORTUNITY,
                                  REN_Constants.OBJ_ASSET),lstOfAsset.get(0));
            renewOpportunity.Pricebook2Id = getStdPriceBook().Id;
            
        }else if(scLst!=null){
        	
        	renewOpportunity = getNewOpportunity(getOpportunityMapping(
                                  REN_Constants.OBJ_OPPORTUNITY,
                                  REN_Constants.OBJ_SERVICE_CONTRACT),scLst.get(0));
        	renewOpportunity.Pricebook2Id = scLst.get(0).get('PriceBook2Id')!=null?''+scLst.get(0).get('PriceBook2Id'):getStdPriceBook().Id;
        	if (UserInfo.isMultiCurrencyOrganization()){
                renewOpportunity.put('CurrencyIsoCode',scLst.get(0).get('CurrencyIsoCode'));
            }
        }
        renewOpportunity.REN_Is_CLM_Renewal__c = true;
        return renewOpportunity;
    }
    public List<REN_RenewLineWrapper> getRliWrapper(Map<String,List<REN_Renews_To__c>> mapOfRLI,Map<String,OpportunityLineItem> mapOfCombinedOli,Map<String,OpportunityLineItem> mapOfOliForAssets,Map<String,OpportunityLineItem> mapOfOliForSC,List<Asset>lstOfAsset,Map<Id,Asset>mapOfAssets,OpportunityLineItem masterOli,Map<Id,sObject> mapOfCli){
        List<REN_RenewLineWrapper> lstOfRLIWrapper = new List<REN_RenewLineWrapper>(); 
        integer totalPrice =0;
        integer i=0;
        for(String rliMap: mapOfRLI.keySet()){
                List<REN_Renews_To__c> rliLst = mapOfRLI.get(rliMap);
                Integer count =0;
                for(REN_Renews_To__c rli:rliLst){
                        if(rli.REN_Previous_Price__c!=null){
                            if(rli.REN_Renewal_Target_Multiplier__c!=null){
                                totalPrice += Integer.valueOf(rli.REN_Previous_Price__c)*Integer.valueOf(rli.REN_Renewal_Target_Multiplier__c);
                            }else{
                                totalPrice += Integer.valueOf(rli.REN_Previous_Price__c);
                            }
                        }
                        REN_RenewLineWrapper rlw = new REN_RenewLineWrapper();
                        rlw.renewLine = rli;
                        rlw.customId = i;
                        if(count==0 && mapOfOliForAssets!=null &&mapOfOliForAssets.containsKey(rliMap)){
                            rlw.typeOfRli= REN_Constants.OBJ_ASSET; 
                            count++;
                        }else if(mapOfOliForSC!=null && mapOfOliForSC.containsKey(rliMap)){
                            rlw.typeOfRli= REN_Constants.OBJ_SERVICE_CONTRACT;
                        }
                        if((mapOfCombinedOli!=null && !mapOfCombinedOli.isEmpty()) && (lstOfAsset==null || lstOfAsset.isEmpty()) && (mapOfCli==null || mapOfCli.isEmpty())){
                            rlw.renewProduct = mapOfCombinedOli.get(rliMap)!=null?mapOfCombinedOli.get(rliMap).Product2.Name:'';
                        }else if((mapOfAssets!=null && !mapOfAssets.isEmpty())&&(mapOfCli==null || mapOfCli.isEmpty())){
                            rlw.renewProduct = mapOfAssets.get(rliMap)!=null?mapOfAssets.get(rliMap).Name:'';
                        }else if(!mapOfCli.isEmpty()){
                        	rlw.renewProduct = mapOfCli.get(rliMap)!=null?''+mapOfCli.get(rliMap).getSObject('PricebookEntry').getSObject('Product2').get('Name'):'';
                        }
                        rlw.sourceOpptLnId = rliMap;
                        lstOfRLIWrapper.add(rlw);
                        i++;
               }
                           
        }
        if(masterOli!=null){
            masterOli.UnitPrice=totalPrice;
        }
      return lstOfRLIWrapper;  
    }
    
    public Pricebook2  getStdPriceBook () {
        Pricebook2 stdPriceBook;
        if (stdPriceBook == null) {
           if(!Test.isRunningTest()){
              stdPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
           }else{
            stdPriceBook = new Pricebook2(Id = Test.getStandardPricebookId());
           }
        }
        return stdPriceBook;    
    }
}