public with sharing class REN_OpportunityResolutionHelper
{
    public static Schema.SObjectType objectServiceContract;
    public static List<REN_Field_Mappings__c> fetchFieldMapping(String toObjName, String fromObjName, String mappingName)
    {
        system.debug('IN fetchFieldMapping');
        return REN_FieldMappingsDataAccess.getFieldMappingListByConfig(toObjName, fromObjName);
    }
    
    //todo: Eswar 
    //See if this can be made @future
    public static Boolean createRelatedListRecords(Set<String> oldOpportunityIds, Map<String, String> mapOld2NewOpportunityIds,
                                                    List<REN_Renew_Configuration__c> renewConfigurationList)
    {
        REN_Renew_Configuration__c renewConfiguration = new REN_Renew_Configuration__c();
        if(renewConfigurationList != null && !renewConfigurationList.isEmpty()){
            renewConfiguration = renewConfigurationList[0];
        }
        Boolean isSuccess = false;      
        Set<String> oldOpptIds = oldOpportunityIds;
        
        Map<String, OpportunityCompetitor> competitorsOldMap = new Map<String, OpportunityCompetitor>();
        Map<String, OpportunityContactRole> contactRolesOldMap = new Map<String, OpportunityContactRole>();
        Map<String, OpportunityPartner> partnersOldMap = new Map<String, OpportunityPartner>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        Map<String, String> opportunityAccountMap = new Map<String, String>();
        
        List<OpportunityCompetitor> competitorsNewLst = new List<OpportunityCompetitor>();
        List<OpportunityContactRole> contactRolesNewLst = new List<OpportunityContactRole>();
        List<Partner> partnersNewLst = new List<Partner>();
        List<OpportunityCompetitor> lstCompetitors  = CSM_OpportunityDataAccess.fetchOpportunityCompetitor(oldOpptIds);
        List<OpportunityContactRole> lstContactRoles = CSM_OpportunityDataAccess.fetchOpportunityContactRole(oldOpptIds);
        List<OpportunityPartner> lstPartners = CSM_OpportunityDataAccess.fetchOpportunityPartner(oldOpptIds);
        
        REN_OpportunityResolutionTriggerHandler.REN_INN_PARTNER_HANDLER innerInst = new REN_OpportunityResolutionTriggerHandler.REN_INN_PARTNER_HANDLER();
        
        List<Partner> partnerList = innerInst.fetchPartners(mapOld2NewOpportunityIds.keySet());
        opportunityList = CSM_OpportunityDataAccess.getOpportunitiesById(oldOpptIds);
        
        for (Opportunity o :opportunityList)
        {
            opportunityAccountMap.put(o.Id, o.AccountId);
        }
        
        for(REN_Related_List__c relList :REN_RelatedListDataAccess.getRelatedListRecordsByConfig(renewConfiguration.Id))
        {
            if(relList.REN_Related_List_Type__c == 'Competitors')
            {
                for(OpportunityCompetitor com :lstCompetitors)
                {
                    competitorsOldMap.put(com.OpportunityId, com);
                }
            }
            else if(relList.REN_Related_List_Type__c == 'Contact Roles')
            {
                for(OpportunityContactRole com :lstContactRoles)
                {
                    contactRolesOldMap.put(com.OpportunityId, com);
                }
            }
            else if(relList.REN_Related_List_Type__c == 'Partners')
            {
                for(OpportunityPartner com :lstPartners)
                {
                    partnersOldMap.put(com.OpportunityId, com);
                }
            }
        }
        
        for(String comId :competitorsOldMap.keySet())
        {
            OpportunityCompetitor ocNew = (competitorsOldMap.get(comId)).clone(false, false);
            ocNew.OpportunityId = mapOld2NewOpportunityIds.get(comId);
            competitorsNewLst.add(ocNew);
        }
        
        for(String comId :contactRolesOldMap.keySet())
        {
            OpportunityContactRole ocNew = (contactRolesOldMap.get(comId)).clone(false, false);
            ocNew.OpportunityId = mapOld2NewOpportunityIds.get(comId);
            contactRolesNewLst.add(ocNew);
        }
        
        // added new fix and commented else part because it will give below error while creating renewal opty manually.
        //ref: https://developer.salesforce.com/forums/ForumsMain?id=906F00000008xKhIAI
        //Opportunity: field integrity exception: OpportunityId, AccountToId (account to cannot be opportunity account)
        //Insert failed. First exception on row 0; first error: FIELD_INTEGRITY_EXCEPTION, 
        // field integrity exception: OpportunityId, AccountToId (account to cannot be opportunity account): [OpportunityId, AccountToId]
        Partner ocNew = new Partner();
        for(String comId :partnersOldMap.keySet())
        {
            OpportunityPartner ocNewOP = partnersOldMap.get(comId);
            for (Partner pr :partnerList)
            {
                if (pr.AccountToId != opportunityAccountMap.get(comId))
                {
                    Partner newPR = pr.clone(false);
                    newPR.OpportunityId = mapOld2NewOpportunityIds.get(comId);
                    newPR.AccountFromId = null;
                    partnersNewLst.add(newPR);
                }
            }
        }
        if(competitorsNewLst != null && !competitorsNewLst.isEmpty())
        {
            CSM_OpportunityDataAccess.insertOpportunityCompetitor(competitorsNewLst);
        }
        
        if(contactRolesNewLst != null && !contactRolesNewLst.isEmpty())
        {
            CSM_OpportunityDataAccess.insertOpportunityContactRole(contactRolesNewLst);
        }
        
        if(partnersNewLst != null && !partnersNewLst.isEmpty())
        {
            CSM_OpportunityDataAccess.insertPartner(partnersNewLst);
        }
        return isSuccess;
    }
    
    public static List<SObject> handleOpportunityServiceContractCreation(Map<String, String> serviceContractOpptyMap)
    {
        List<SObject> opportunityServiceContractList = REN_ServiceContractsDataAccess.getOpportunityServiceContractWithoutInsert(serviceContractOpptyMap);
        return opportunityServiceContractList;
    }
    
    public static List<SObject> handleServiceContractCreation(List<Opportunity> filteredOpportunityList, List<REN_Renew_Configuration__c> renewConfigRecList)
    {
        List<SObject> serviceContractList;
        Savepoint spBeforeServContractCreate = Database.setSavepoint();
        if(filteredOpportunityList !=null && !filteredOpportunityList.isEmpty())
        {
            // Create Service Contract
            serviceContractList = getServiceContractWithoutInsert(filteredOpportunityList, renewConfigRecList);
            REN_ServiceContractsDataAccess.insertServiceContractList(serviceContractList);
        }
        return serviceContractList;
    }
    
    /***
    * @description Get Service Contract record list without insert
    * @Param: Opportunity list, renew configuration list.
    * @Return: ServiceContract list
    ***/
    public static List<SObject> getServiceContractWithoutInsert(List<Opportunity> oppts2ProcessLst, List<REN_Renew_Configuration__c> renewConfigRecList)
    {
        system.debug('IN getServiceContractWithoutInsert ');
        List<SObject> serviceContractToCreate = new List<SObject>();
        Map<String, SObject> currentOptyId2NewServiceContractMap = new Map<String, SObject>();
        Map<String, Opportunity> currentOptyId2CurrentOptyMap = new Map<String, Opportunity>();
        SObject serviceContract;
        String mappingName;
        objectServiceContract = CSM_AccessController.getObjectType(REN_Constants.OBJ_SERVICE_CONTRACT);
        Map<String, Schema.SobjectField> serviceContractFieldNames = CSM_AccessController.fetchAllFieldNames(objectServiceContract);
        set<String> serviceContractOptyCommonFieldSet = new set<String>{REN_Constants.OBJ_SC_PRICEBOOK2_ID};
        //Copy field values for Required fields first. Then, copy the ones from the mapping (overwriting is fine).
        for(Opportunity currentOpty: oppts2ProcessLst)
        {
            String contractName = 'Contract of' + currentOpty.Name;
            SObject newServiceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICE_CONTRACT);
            newServiceContract.put('AccountId', currentOpty.AccountId);
            newServiceContract.put('Name', contractName);
            CSM_Util.setAppliedCurrency(newServiceContract, CSM_Util.getAppliedCurrency(currentOpty));//US452
            // VCP - ORG21 check
            if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID)) {
                newServiceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID, currentOpty.Id);
            }
            for(String fieldName: serviceContractFieldNames.keySet())
            {
                if (serviceContractOptyCommonFieldSet.contains(fieldName))
                {
                    newServiceContract.put(fieldName, currentOpty.get(fieldName));
                }
            }
            //newServiceContract.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID, currentOpty.get(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID));
            currentOptyId2NewServiceContractMap.put(currentOpty.Id, newServiceContract);
            currentOptyId2CurrentOptyMap.put(currentOpty.Id, currentOpty);
        }
        mappingName = REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS;
        //Get Field Mapping Criteria for opty and follow while creating.
        List<REN_Field_Mappings__c> lstServContractFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_SERVICE_CONTRACT, REN_Constants.OBJ_OPPORTUNITY, mappingName);
        if(lstServContractFldMappings == null || lstServContractFldMappings.isEmpty()){
        	throw new REN_OpportunityResolutionTriggerHandler.FieldMappingException(String.format('Field mapping is not defined from {0} to {1}', new String[]{REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_SERVICE_CONTRACT}));
        }
        for(String optyId: currentOptyId2NewServiceContractMap.keySet())
        {
            SObject newServiceContract = currentOptyId2NewServiceContractMap.get(optyId);
            for(REN_Field_Mappings__c fMapping :lstServContractFldMappings)
            {
                SObjectField serviceContractSObjectFld = serviceContractFieldNames.get(fMapping.REN_To_Field_API_Name__c);
                newServiceContract = getMappedOptyBasedserviceContract(newServiceContract, optyId, String.valueOf(serviceContractSObjectFld.getDescribe().getType()),
                                                                        currentOptyId2CurrentOptyMap, fMapping.REN_Default_Value__c,
                                                                        fMapping.REN_To_Field_API_Name__c, fMapping.REN_From_Field_API_Name__c);
            }
            currentOptyId2NewServiceContractMap.put(optyId, newServiceContract);
        }
        for (SObject sc: currentOptyId2NewServiceContractMap.values())
        {
            serviceContractToCreate.add(sc);
        }
        return serviceContractToCreate;
    }
    
    /***
    * @description Get Mapped Service Contract record list 
    * @Param: newServiceContract, optyId, fieldTyp, currentOptyId2CurrentOptyMap, defaultVal, toField, fromField.
    * @Return: ServiceContract list
    ***/
    public static SObject getMappedOptyBasedserviceContract(SObject newServiceContract, String optyId, String fieldTyp, 
                                                            Map<String, Opportunity> currentOptyId2CurrentOptyMap, String defaultVal, String toField, 
                                                            String fromField)
    {
        if(defaultVal != null && defaultVal.trim() != '')
        {
            if(fieldTyp == CSM_Constants.TYPE_CURRENCY || fieldTyp == CSM_Constants.TYPE_DOUBLE)
            {
                newServiceContract.put(toField, Double.valueOf(defaultVal));
            }
            else if(fieldTyp == CSM_Constants.TYPE_INTEGER || fieldTyp == CSM_Constants.TYPE_PERCENT)
            {
                newServiceContract.put(toField, Integer.valueOf(defaultVal));
            }
            else if(fieldTyp == CSM_Constants.TYPE_DATETIME)
            {
                newServiceContract.put(toField, DateTime.valueOf(defaultVal + ' 00:00:00'));
            }
            else if(fieldTyp == CSM_Constants.TYPE_DATE)
            {
                newServiceContract.put(toField, Date.valueOf(defaultVal + ' 00:00:00'));
            }
            else if(fieldTyp == CSM_Constants.TYPE_BOOLEAN)
            {
                newServiceContract.put(toField, Boolean.valueOf(defaultVal));
            }
            else
            {
                newServiceContract.put(toField, defaultVal);
            }
        }
        else if(fromField != null)
        {
            newServiceContract.put(toField, (currentOptyId2CurrentOptyMap.get(optyId)).get(fromField));
        }
        return newServiceContract;
    }
    
    public static List<Opportunity> getOpportunity2ProcessList(Map<String, Opportunity> oldOpptRecordsMap, Map<String, Opportunity> newOpptRecordsMap, REN_Renew_Configuration__c renewConfiguration)
    {
        List<Opportunity> oppts2ProcessList;
        if(renewConfiguration == null){
            return new List<Opportunity>();
        }
        Map<String, String> serviceContractOpportunityMap = new Map<String, String>();
        if(renewConfiguration.REN_Is_Active__c == true){
            Map<String, Opportunity> oppts2ProcessMap = REN_Util.filterOpportunityAtStage(oldOpptRecordsMap, newOpptRecordsMap, renewConfiguration.REN_Filter_Criteria__c);
            if(!oppts2ProcessMap.isEmpty()){
                oppts2ProcessList = REN_ServiceContractsDataAccess.filterOpptyListWithoutAccount(oppts2ProcessMap.values());
            }
        }
        return oppts2ProcessList;
    }
    
    public static OpportunityLineItem getMappedAssetBasedOpportunityLineItem(List<OpportunityLineItem> existingOpportunityLineItemList, String fieldTyp, 
                                                                             List<Asset> currentAssetList, String defaultVal, 
                                                                             String toField, String fromField)
    {
        if (existingOpportunityLineItemList!=null && !existingOpportunityLineItemList.isEmpty()){
            OpportunityLineItem existingOpportunityLineItem = existingOpportunityLineItemList[0];
            if(defaultVal != null && defaultVal.trim() != '')
            {
                if(fieldTyp == CSM_Constants.TYPE_CURRENCY || fieldTyp == CSM_Constants.TYPE_DOUBLE)
                {
                    existingOpportunityLineItem.put(toField, Double.valueOf(defaultVal));
                }
                else if(fieldTyp == CSM_Constants.TYPE_INTEGER || fieldTyp == CSM_Constants.TYPE_PERCENT)
                {
                    existingOpportunityLineItem.put(toField, Integer.valueOf(defaultVal));
                }
                else if(fieldTyp == CSM_Constants.TYPE_DATETIME)
                {
                    existingOpportunityLineItem.put(toField, DateTime.valueOf(defaultVal + ' 00:00:00'));
                }
                else if(fieldTyp == CSM_Constants.TYPE_DATE)
                {
                    existingOpportunityLineItem.put(toField, Date.valueOf(defaultVal + ' 00:00:00'));
                }
                else if(fieldTyp == CSM_Constants.TYPE_BOOLEAN)
                {
                    existingOpportunityLineItem.put(toField, Boolean.valueOf(defaultVal));
                }
                else
                {
                    existingOpportunityLineItem.put(toField, defaultVal);
                }
            }
            else if(fromField != null && currentAssetList!=null && !currentAssetList.isEmpty()) //from Asset-->OpptLine //toField.put(fromFieldVal)
            {
                Asset currentAsset = currentAssetList[0]; 
                if(toField == REN_Constants.OBJ_OLI_UNITPRICE)
                {
                    if(existingOpportunityLineItem.get(toField) != null && currentAsset.get(fromField) != null) //existingOpportunityLineItem.get(toField) != null && 
                    {
                        existingOpportunityLineItem.put(toField, currentAsset.get(fromField));
                    }
                }
                else
                {
                    existingOpportunityLineItem.put(toField, currentAsset.get(fromField));
                }
                    
            }
            return existingOpportunityLineItem;
        }
        return null;
        
    }
    
    public static void createRenewalRelationships(List<REN_OpptLineWrapper> opportunityLinesInserted, List<SObject> serviceContractList, 
                                                  List<SObject> contractLineItemList, Map<String, List<OpportunityLineItem>> renewalQualifiedOpptLines,
                                                  Map<String, String> mapOldOpptLine2assetIDs, Map<String, String> mapOld2NewOppts)
                                                 
    { 
        Boolean coveredAssetFlag=false;
        List<OpportunityLineItem> lstOpptLns = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(renewalQualifiedOpptLines.keySet());//[SELECT Id, Name, ProductCode, Product2Id , Description, ServiceDate, Quantity, PricebookEntryId, OpportunityId, REN_Covered_Product__c, TotalPrice, UnitPrice, REN_Covered_Asset__c FROM OpportunityLineItem WHERE OpportunityId IN :renewalQualifiedOpptLines.keySet() limit 10000];
        Map<ID, OpportunityLineItem> oppLineItemMap = new Map<ID, OpportunityLineItem>(lstOpptLns);
        List<Sobject> upadtedserviceContractList2Asset = new List<Sobject>();
    	Map<String, OpportunityLineItem> mapOpptLnId2OpptLn_service = new Map<String, OpportunityLineItem>(lstOpptLns);        

        List<OpportunityLineItem> lstOpptLines4Update_withRelationships = new List<OpportunityLineItem>();
         
        //Find all assets created by Opportunity
        Map<String, List<Asset>> mapOpptId2Assets = new Map<String, List<Asset>>();
        List<Asset> lstAllAssetFromOppts = REN_AssetDataAccess.getAllAssetFromOppts(renewalQualifiedOpptLines.keySet());//[Select Id, AccountId, Name, Product2Id, REN_Opportunity__c, REN_Oppty_Line_Item_Id__c From Asset 
                                           // Where REN_Opportunity__c IN :renewalQualifiedOpptLines.keySet() limit 10000];
        
        for(Asset a :lstAllAssetFromOppts){
            String opptId = a.REN_Opportunity__c;
            List<Asset> lstAssets = mapOpptId2Assets.get(opptId);
            if(lstAssets == null) {
                lstAssets = new List<Asset>(); 
            }
            lstAssets.add(a);
            mapOpptId2Assets.put(opptId, lstAssets);
        }
        Map<String, SObject> mapOpptId2ServiceContract = new Map<String, SObject>();
        Map<String, String> mapServiceContractId2OpptId = new Map<String, String>();
        Map<String, String> mapOpptLnId2ContractLnId = new Map<String, String>();
        Map<String, SObject> mapContractLnId2ContractLn = new Map<String, SObject>();
        
        if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT) && serviceContractList != null && !serviceContractList.isEmpty()) {
            for(SObject so :serviceContractList)
            {
                // VCP - ORG21 check
                if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID)) {
                    String sourceOpptId;
                    if(so.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID) != null)
                    {
                        sourceOpptId = String.valueOf(so.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID));
                    }
                    if(sourceOpptId != null) {
                    	
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)) {
                        	String opportunityId = (String)so.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID);//originalOpportunityId
                        	opportunityId = mapOld2NewOppts.get(opportunityId);//RenewedOpportunityId
                        	if(String.isNotBlank(opportunityId)){
                            	so.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID, ID.valueOf(opportunityId));
                        	}
                        }                    	
                    	
                        mapOpptId2ServiceContract.put(sourceOpptId, so);
                        mapServiceContractId2OpptId.put(so.Id, sourceOpptId);
                    }
                }
            }
            
            for(SObject so :contractLineItemList)
            {
                if(CSM_AccessController.hasField(REN_Constants.OBJ_CONTRACT_LINE_ITEM, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID)) {
                    String sourceOpptLnId = String.valueOf(so.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID));
                    if(sourceOpptLnId != null) {
                        mapOpptLnId2ContractLnId.put(sourceOpptLnId, String.valueOf(so.get('Id')));
                        //Start : Added for US347:Service Contract Line Item to Asset relationship.
                        OpportunityLineItem oli = oppLineItemMap.get(sourceOpptLnId);
                        if(oli != null && oli.REN_Covered_Asset__c != null){
                            so.put(REN_Constants.OBJ_SCLI_ASSETID, oli.REN_Covered_Asset__c);
                        }
                        //End
                    }
                }
                mapContractLnId2ContractLn.put(String.valueOf(so.get('Id')), so);
            }
        }
        Map<String, REN_Renews_To__c> mapRenewalRelationship = new Map<String, REN_Renews_To__c>();
        map<id,Opportunity> mapUpdateSCOnRenewalOpp=new map<id,Opportunity>();
		Opportunity newOppt;
		List <REN_Field_Mappings__c> fieldMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM);
        Set<String> requestedFields = new Set<String>{'ren_asset__c','REN_Renews_To__c','REN_Product__c','REN_Start_Date__c','REN_End_Date__c','REN_Quantity__c'};
        REN_Util.getFromAndToFldsToQuery(fieldMappingLst,null,requestedFields);       
        Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(REN_Renews_To__c.sObjectType);
        List<String> opptIds = new List<String>();
        opptIds.addAll(mapOpptId2ServiceContract.keySet());
        Map<String,Opportunity> mapUpdateSCOnRenOpp=new Map<String,Opportunity>(REN_OpportunityDataAccess.getOpportunityAllDetailsById(opptIds));
		boolean isAssetConfigSet = false;
	    List<REN_Renew_Configuration__c> renewConfigForOpptyPro2Asset = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(new set<String>{REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET});       
	    if(renewConfigForOpptyPro2Asset!=null && !renewConfigForOpptyPro2Asset.isEmpty()){
	        if(renewConfigForOpptyPro2Asset[0].REN_Is_Active__c==true){
	        	isAssetConfigSet = true;
	        }
	    }
        Map<String, REN_Renews_To__c> oliIndexToRliMap = new Map<String, REN_Renews_To__c>();
        integer iCount = 0;
        if(opportunityLinesInserted != null && !opportunityLinesInserted.isEmpty())
        {
            for(REN_OpptLineWrapper olWrap :opportunityLinesInserted)
            {
                //find if there are any lines for which relationships need to be established 
                /* 1. Renewal Relationship */
                REN_Renews_To__c renewalRelAsset = new REN_Renews_To__c();
                renewalRelAsset.REN_Renews_To__c = olWrap.opLine.OpportunityId;
                renewalRelAsset.REN_Product__c =  olWrap.opLine.Product2Id;
                renewalRelAsset.REN_Start_Date__c =  olWrap.opLine.REN_Start_Date__c;
                renewalRelAsset.REN_End_Date__c =  olWrap.opLine.REN_End_Date__c;
                renewalRelAsset.REN_Quantity__c = olWrap.opLine.Quantity;	
				sObject sobjRR = REN_Util.copyObjectUsingAdminMapping(olWrap.opLine, renewalRelAsset, opptLineAllFieldNames, fieldMappingLst);
                CSM_Util.setAppliedCurrency(renewalRelAsset, CSM_Util.getAppliedCurrency(olWrap.opLine));//US452
                
                //ServiceContractLine - Renewal Relationship
                REN_Renews_To__c renewalRelService = new REN_Renews_To__c();
                renewalRelService.REN_Renews_To__c = olWrap.opLine.OpportunityId;
                renewalRelService.REN_Product__c =  olWrap.opLine.Product2Id;
                renewalRelService.REN_Start_Date__c =  olWrap.opLine.REN_Start_Date__c;
                renewalRelService.REN_End_Date__c =  olWrap.opLine.REN_End_Date__c;
                renewalRelService.REN_Quantity__c = olWrap.opLine.Quantity;
                sObject sobjRRForSC = REN_Util.copyObjectUsingAdminMapping(olWrap.opLine, renewalRelService, opptLineAllFieldNames, fieldMappingLst);
                CSM_Util.setAppliedCurrency(renewalRelService, CSM_Util.getAppliedCurrency(olWrap.opLine));//US452 
                
                //Asset - Renewal Relationship
                if(mapOldOpptLine2assetIDs.get(olWrap.sourceOpptLnId) != null && olWrap.opLine.OpportunityId != null)
                {
                    renewalRelAsset.REN_Asset__c = mapOldOpptLine2assetIDs.get(olWrap.sourceOpptLnId);
                    mapRenewalRelationship.put(olWrap.sourceOpptLnId + renewalRelAsset.REN_Asset__c, renewalRelAsset);
                    oliIndexToRliMap.put('asset' +iCount, renewalRelAsset);
                }
                //ServiceContractLine - Renewal Relationship
                if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT) && serviceContractList != null && !serviceContractList.isEmpty()) {
                    if(mapOpptId2ServiceContract.containsKey(olWrap.sourceOpptId)){
                        SObject so = mapOpptId2ServiceContract.get(olWrap.sourceOpptId);
                        Opportunity oppObj = mapUpdateSCOnRenOpp.get(olWrap.sourceOpptId);
                        /*if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Incumbent__c')) {
                        	so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Incumbent__c', OppObj.CHL_Incumbent__c);
                        }*/ //commented as per US1281
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1__c')) {
                        	so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1__c', OppObj.CHL_Partner_Account_1__c);
                        }
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Contact__c')) {
                       		so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Contact__c', OppObj.CHL_Partner_Account_1_Contact__c);
                        }
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Type__c')) {
                            so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Type__c', OppObj.CHL_Partner_Account_1_Type__c);
                        }
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2__c')) {
                            so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2__c', OppObj.CHL_Partner_Account_2__c);
                        }
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Contact__c')) {
                            so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Contact__c', OppObj.CHL_Partner_Account_2_Contact__c);
                        }
                        if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Type__c')) {
                            so.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Type__c', OppObj.CHL_Partner_Account_2_Type__c);
                        }
                        if(olWrap.opLine != null && olWrap.opLine.OpportunityId != null) {
                            // VCP - ORG21 check
                            if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)) {
                                so.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID, olWrap.opLine.OpportunityId);
                            }
                            mapOpptId2ServiceContract.put(olWrap.sourceOpptId, so);
                            newOppt = new Opportunity(Id=olWrap.opLine.OpportunityId);
							if(!mapUpdateSCOnRenewalOpp.containsKey(newOppt.id) && CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT)){
								 newOppt.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT, so.get('Id'));
								 mapUpdateSCOnRenewalOpp.put(newOppt.id,newOppt);
							}
                        }
                    }
                    
                    //Eswar Bala - 04/03/2015 - Fix for when Add-on Oppts close, the appended Contract Lines don't create Renewal Relationship records 
                    //                          even though the Contract Lines are being appended to the Existing Service Contract
                    //Analysis: The issue occurs because the Service Contract isn't updated (during the add-on close process) with the Add-on as being the source  
                    //See below commented code - Temp fix for design gap (Only One Oppt is Source for a Service Contract during resolution).
                    String contractLineId = mapOpptLnId2ContractLnId.get(olWrap.sourceOpptLnId);
                    if(contractLineId != null)
                    {                        
                        renewalRelService.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM, contractLineId);
                        //renewalRelService.put(REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, (mapOpptId2ServiceContract.get(olWrap.sourceOpptId)).Id);
                        renewalRelService.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, (mapContractLnId2ContractLn.get(contractLineId)).get(REN_Constants.OBJ_SERVICE_CONTRACT_ID));
                        mapRenewalRelationship.put(olWrap.sourceOpptLnId + mapOpptLnId2ContractLnId.get(olWrap.sourceOpptLnId), renewalRelService);
                        oliIndexToRliMap.put('cli' +iCount, renewalRelService);
                    }
                }
                
                /*2. If Oppts have Oppt Lines that act as Service - To Assets */
                OpportunityLineItem oline_serv = mapOpptLnId2OpptLn_service.get(olWrap.sourceOpptLnId);//this is the original item corresponding to the renewed item here olWrap.opline
                Asset serviceAsset;
                Asset physicalAsset;
                if(oline_serv != null)
                {
                    String serviceAssetId = mapOldOpptLine2assetIDs.get(olWrap.sourceOpptLnId);
                    //Eswar Bala - Removing the below check temporarily since this was causing issues for John's demo.
                    //             Not sure if this is needed. So, just keeping it uncommented.
                    //if(serviceAssetId != null)
                    {
                        if(mapOpptId2Assets.containsKey(olWrap.sourceOpptId))
                        {
                            for(Asset a :mapOpptId2Assets.get(olWrap.sourceOpptId))
                            {
                                if(a.Product2Id == oline_serv.REN_Covered_Product__c)
                                {
                                    physicalAsset = a;
                                    break;
                                }
                            }
                        }
                    }
                }
    			OpportunityLineItem ol = olWrap.opLine;
                if(physicalAsset != null) //find oppt line and update
                {
	                if(isAssetConfigSet){
	                    coveredAssetFlag = true;
	                    ol.REN_Covered_Asset__c = physicalAsset.Id;
	                    ol.REN_Covered_Product__c = null;
	                }
                }
                lstOpptLines4Update_withRelationships.add(ol);
                iCount += 1;
            }
        }
        
        //try{
            if(!mapRenewalRelationship.isEmpty())
            {
            	REN_RRSimplifiedTriggerHelper.processRliRecords(mapRenewalRelationship.values());
            	REN_RenewRelationshipDataAccess.insertRLI(mapRenewalRelationship.values(),new List<String>(requestedFields));
            	//REN_RenewRelationshipDataAccess.upsertRenewalRelationship( mapRenewalRelationship.values());
            }
            
            if(!lstOpptLines4Update_withRelationships.isEmpty())
            {
            	iCount = 0;
            	for(OpportunityLineItem oli: lstOpptLines4Update_withRelationships ){
            		REN_Renews_To__c rli = oliIndexToRliMap.get('asset' +iCount);
            		if(rli == null){
            			rli = oliIndexToRliMap.get('cli' +iCount);
            		}
            		if(rli != null){
            			oli.REN_Renewable_Line_Item__c = rli.id;
            		}
            		iCount += 1;
            	}
                REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(lstOpptLines4Update_withRelationships);
               // update lstOpptLines4Update_withRelationships;
                
            }
            
            if(!mapOpptId2ServiceContract.isEmpty())
            {
                update mapOpptId2ServiceContract.values();
            }
            
            if(!upadtedserviceContractList2Asset.isEmpty()){
                update upadtedserviceContractList2Asset;
            }
            if(!mapOpptId2ServiceContract.isEmpty())
            {
           		if(coveredAssetFlag==true){
            		updatedRenewalRelationshipsWithCoveredAsset(lstOpptLines4Update_withRelationships,contractLineItemList);
            		coveredAssetFlag = false;
            	}
            
            }
            
            if(!mapUpdateSCOnRenewalOpp.isEmpty())
			{
				update mapUpdateSCOnRenewalOpp.values();
			}
        //}
        /*
        catch(Exception e)
        {
            system.debug('An exception occurred : ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
         */   
    }

    
    public static void updatedRenewalRelationshipsWithCoveredAsset(List<OpportunityLineItem> lstOpptLines4Update_withRelationships,List<SObject> contractLineItemList) {
        String namespace = CSM_Util.getNamespace();
        Map<ID,OpportunityLineItem> renewedOpptLinesWithCoveredAssetMap = new Map<ID,OpportunityLineItem>(lstOpptLines4Update_withRelationships);
        Map<Id,Id> rliToOliId = new Map<Id,Id>();
        for(OpportunityLineItem oli : renewedOpptLinesWithCoveredAssetMap.values()){
        	rliToOliId.put(oli.REN_Renewable_Line_Item__c,oli.Id);
        }
        if (!renewedOpptLinesWithCoveredAssetMap.isEmpty()) {
            //Eswar Bala - 
            List<REN_Renews_To__c> renewalRelationshipList =REN_RenewRelationshipDataAccess.getLstRenRelationshipsByRenewalProductLineID(rliToOliId.keySet()); //Database.query(qryString);
            Map<ID,REN_Renews_To__c> contractLineItem_RenewalRelationshipMap = new Map<ID,REN_Renews_To__c>();
            for(REN_Renews_To__c renewalRelationshipObj: renewalRelationshipList) {
                contractLineItem_RenewalRelationshipMap.put((Id)renewalRelationshipObj.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM), renewalRelationshipObj);
            }
            for(SObject so :contractLineItemList){
                REN_Renews_To__c renewalRelationshipObj = contractLineItem_RenewalRelationshipMap.get(so.id);
                if(renewalRelationshipObj != null){
                	Id oliId = rliToOliId.get(renewalRelationshipObj.Id);
                    OpportunityLineItem renOppLineItemObj = renewedOpptLinesWithCoveredAssetMap.get(oliId);
                    if(renOppLineItemObj != null){
                        so.put(REN_Constants.OBJ_SCLI_ASSETID, renOppLineItemObj.REN_Covered_Asset__c);
                    }
                }
            }
            update contractLineItemList;
        }
    }
}