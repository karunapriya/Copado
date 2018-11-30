public with sharing class REN_OpportunityResolutionTriggerHandler
{
	public static Map<String, List<OpportunityLineItem>> renewalQualifiedOpptLines = new Map<String, List<OpportunityLineItem>>();
	public static Map<String, String> mapOld2NewOppts = new Map<String, String>();
	public static Map<String, String> mapNew2OldOppts = new Map<String, String>();
	public static Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
	public static Map<String, Asset> oldOpptLineId2NewAssetMap = new Map<String, Asset>();
	public static Map<String, String> mapOldOpptLine2assetIDs = new Map<String, String>();
	//private static List<Opportunity> newCreatedOppts = new List<Opportunity>();
	//private static set<Id> newOpptyIds = new Set<Id>(); 
	
	public static String mappingNotDefinedErrMsg = Label.REN_LBL_MAPPINGS_ERROR_MSG;

	static{
		List<REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(null);
		if(renewConfigurationList != null){
			for(REN_Renew_Configuration__c rConfig: renewConfigurationList){
				renewConfigurationMap.put(rConfig.REN_Record_Key__c, rConfig);
			}
		}
	}

	public without sharing class REN_INN_PARTNER_HANDLER {
		public List<Partner> fetchPartners(Set<String> opptSet) {
			return [SELECT AccountToId, AccountFromId, IsPrimary, OpportunityId, Role FROM Partner WHERE OpportunityId IN :opptSet limit 1000];
		}

		public void insertRelatedListPartner(List<Partner> partnersNewLst){
			if(partnersNewLst != null && !partnersNewLst.isEmpty()){
				insert partnersNewLst;
			}
		}
	}

	public static void handleOpportunityResolution(List<Opportunity> filteredOpportunityList){
		REN_CONSTANTS.IS_AUTO_REBUILD = false;
		//List<Opportunity> filteredOpportunityList = filterOpportunitiesByStageChange(oldRecords, newRecords);
		if(filteredOpportunityList != null && filteredOpportunityList.size() == 1){
			List<OpportunityLineItem> oliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new Set<String>{filteredOpportunityList[0].id});
			if(CSM_Admin__c.getOrgDefaults() != null 
				&& (CSM_Admin__c.getOrgDefaults().REN_Oppt_Resolution_Realtime_Threshold__c == null 
				|| oliList.size() <= CSM_Admin__c.getOrgDefaults().REN_Oppt_Resolution_Realtime_Threshold__c)) {
				if(SS_Constants.isSimplifiedDataModelEnabled) {
					REN_SimplifiedRenewalHandler.renewOpportunity(filteredOpportunityList);
				}else {
					REN_NonSimplifiedRenewalHandler.renewOpportunity(filteredOpportunityList);
				}
			} else {
				REN_AsyncOpportunityResolutionHandler.handleRenewProcessGeneration(filteredOpportunityList);
			}
		}else{
			REN_AsyncOpportunityResolutionHandler.handleRenewProcessGeneration(filteredOpportunityList);
		}
	}
	
	/*private static List<Opportunity> filterOpportunitiesByStageChange(List<Opportunity> oldRecords, List<Opportunity> newRecords){
		Map<Id, Opportunity> oldOpportunityMap = new Map<Id, Opportunity>(oldRecords);
		List<Opportunity> filteredOpportunityList = new List<Opportunity>();
		for(Opportunity oppty : newRecords){
			Opportunity oldOppty = oldOpportunityMap.get(oppty.Id);
			if(!oldOppty.StageName.equals(oppty.StageName)){
				filteredOpportunityList.add(oppty);
			}
		}
		return filteredOpportunityList;
	}*/
	
	public static void handleRealTimeOpportunityResolution(List<Opportunity> oldRecords, List<Opportunity> newRecords){
		REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = false;
		//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = false;
		if (Schema.sObjectType.REN_Renew_Configuration__c.isAccessible()) {

			Map<String, Opportunity> oldOpptRecordsMap = new Map<String, Opportunity>(oldRecords);
			Map<String, Opportunity> newOpptRecordsMap = new Map<String, Opportunity>(newRecords);
			List<REN_Source__c> sourceList = new List<REN_Source__c>();
			Map<ID, REN_Source__c> oppIdSourceMap = new Map<ID,REN_Source__c>();
			
			List<SObject> contractLineItemList = new List<SObject>();
			List<Asset> assetsInserted = handleAssetCreation(oldOpptRecordsMap, newOpptRecordsMap,true);
			System.debug('\n\n1. Asset Created~~~~: ' + assetsInserted + CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT));
			List<SObject> serviceContractList = handleServiceContracts(oldOpptRecordsMap, newOpptRecordsMap, contractLineItemList, oppIdSourceMap,true);
			System.debug(contractLineItemList + '\n\n2. serviceContract Created~~~~: ' + serviceContractList);
			List<REN_OpptLineWrapper> oppLnsInserted = handleRenewalCreation(oldOpptRecordsMap, newOpptRecordsMap, sourceList);
			System.debug('\n\n3. Renewed Opportunity Created~~~~: ' + oppLnsInserted);
			
			REN_OpportunityResolutionHelper.createRenewalRelationships(oppLnsInserted, serviceContractList, contractLineItemList, renewalQualifiedOpptLines, mapOldOpptLine2assetIDs,mapOld2NewOppts);
			if(!sourceList.isEmpty()){
				List<REN_Source__c> sourceListFinal = new List<REN_Source__c>();
				sourceListFinal.addAll(sourceList);
				for(REN_Source__c sObj: sourceList){
					if(sObj.REN_Contributor__c != null && oppIdSourceMap.containsKey(sObj.REN_Contributor__c)){
						REN_Source__c sObjForSC = oppIdSourceMap.get(sObj.REN_Contributor__c);
						sObjForSC.REN_Inheriting_Opportunity__c = sObj.REN_Inheriting_Opportunity__c;
						sourceListFinal.add(sObjForSC);
					}
				}
				REN_SourceDataAccess.saveSourceRecords(sourceListFinal);
			}
			setCoveredAssetOnAsset(mapOldOpptLine2assetIDs,oppLnsInserted);			
			/*if(SS_Constants.isSimplifiedDataModelEnabled){
				system.debug('IN D SDM : :::'+newOpptyIds);
        		
				REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(newOpptyIds);				
			} else {*/
			//Reverted Changes for US2549
			if(!mapNew2OldOppts.isEmpty()){
				Set<ID> renewedOppIdSet = new Set<ID>();
				for(String s: mapNew2OldOppts.keySet()){
					renewedOppIdSet.add((ID)s);
				}
				REN_OpportunityMetricsBusiness.resetRliAndOliMetricsFields(renewedOppIdSet);
			}
			//}
		}
	}

	private static void setCoveredAssetOnAsset(Map<String, String> oldOpptLine2assetIdMap, List<REN_OpptLineWrapper> opportunityLinesInserted){
		List<Asset> assetsToSetSelfCoveredAsset = new List<Asset>();
		for(REN_OpptLineWrapper olWrap :opportunityLinesInserted){
			if(oldOpptLine2assetIdMap.containsKey(olWrap.sourceOpptLnId) && olWrap.opLine.REN_Covered_Asset__c != null){
				assetsToSetSelfCoveredAsset.add(new Asset(id = oldOpptLine2assetIdMap.get(olWrap.sourceOpptLnId), REN_Covered_Asset__c = olWrap.opLine.REN_Covered_Asset__c));
			}
		}
		if(!assetsToSetSelfCoveredAsset.isEmpty()){
			List<String> assetFields = new List<String>{'REN_Covered_Asset__c','ContactId',
				'AccountId','REN_Opportunity__c'};
			REN_AssetDataAccess.updateAssets(assetsToSetSelfCoveredAsset, assetFields);
		}
	}

	public static List<SObject> handleServiceContracts(Map<String, Opportunity> oldOpptRecordsMap, Map<String, Opportunity> newOpptRecordsMap, List<SObject> contractLineItemList, Map<ID, REN_Source__c> oppIdSourceMap,boolean isAutoRenewal){

		List<SObject> serviceContractList;
		/*Service Contracts*/
		if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
			REN_Renew_Configuration__c renewConfigForOppty2SContract = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT); //Opportunity → Service Contract

			Set<String> lineCriteriaSet = new Set<String>();
			if(renewConfigForOppty2SContract != null && renewConfigForOppty2SContract.Line_Criteria__r != null){
				for(REN_Line_Criteria__c criteria : renewConfigForOppty2SContract.Line_Criteria__r) {
					lineCriteriaSet.add(criteria.RLM_Field_Name__c);
				}  
			}
			if(renewConfigForOppty2SContract == null || !renewConfigForOppty2SContract.REN_Is_Active__c
					|| renewConfigForOppty2SContract.REN_Filter_Criteria__c == null || !lineCriteriaSet.contains(REN_Constants.OBJ_RC_OPPORTUNITY_STAGE)){
				return serviceContractList;
			}

			List<Opportunity> oldOppty2ProcessSSList=new List<Opportunity>();
            if(isAutoRenewal){
                oldOppty2ProcessSSList = REN_OpportunityResolutionHelper.getOpportunity2ProcessList(oldOpptRecordsMap, newOpptRecordsMap, renewConfigForOppty2SContract);
            }
            else{
                oldOppty2ProcessSSList=oldOpptRecordsMap.values();
            }
			//system.debug('oldOppty2ProcessSSList---->'+oldOppty2ProcessSSList);
			if(oldOppty2ProcessSSList == null || oldOppty2ProcessSSList.isEmpty()){
				return serviceContractList;
			}
			//system.debug('oldOppty2ProcessSSList : ' + oldOppty2ProcessSSList);

			List<SObject> lstAppendServContracts = new List<SObject>();
			List<Opportunity> lstAddOnOpportunities = new List<Opportunity>();
			oldOppty2ProcessSSList = excludeAppendServiceContracts(oldOppty2ProcessSSList, lstAppendServContracts, lstAddOnOpportunities);

			if((oldOppty2ProcessSSList != null && !oldOppty2ProcessSSList.isEmpty()) || (lstAppendServContracts != null && !lstAppendServContracts.isEmpty())){
				//system.debug('IN the IF block');
				serviceContractList = REN_OpportunityResolutionHelper.handleServiceContractCreation(oldOppty2ProcessSSList, new List<REN_Renew_Configuration__c>{renewConfigForOppty2SContract});
				//system.debug('serviceContractList : ' + serviceContractList);
				if(serviceContractList == null){
					serviceContractList = new List<sObject>();
				}
				if (CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c')){
					Map<id,Sobject> servContMap = new Map<id,Sobject>(lstAppendServContracts);
					Sobject scont;
					for(Opportunity opp :newOpptRecordsMap.values()){
						if(opp.get(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__c')!= null){
							scont = servContMap.get((Id)opp.get(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__c'));
							if(scont != null){
								scont.put(CSM_Util.nameSpacePrefix21 +'REN_Opportunity__c',opp.id);
							}
						}
					}
					serviceContractList.addAll(servContMap.values());
				}
				else{
					serviceContractList.addAll(lstAppendServContracts);
				}
				//system.debug('serviceContractList : ' + serviceContractList);
				Map<String, String> opportunityServiceContractMap = new Map<String, String>();

				if(serviceContractList != null && !serviceContractList.isEmpty())
				{

					Map<String, String> serviceContractOpportunityMap = REN_ServiceContractsDataAccess.getServiceContractOpportunityMap(serviceContractList);
					if(serviceContractOpportunityMap == null)
					{
						serviceContractOpportunityMap = new Map<String, String>();
					}

					opportunityServiceContractMap = REN_ServiceContractsDataAccess.getOpportunityServiceContractMap(serviceContractList);
					Map<String, String> mapOppt2ServContr = REN_Util.fetchAppendOppt2ServContr(lstAddOnOpportunities);
					if(opportunityServiceContractMap == null)
					{
						opportunityServiceContractMap = new Map<String, String>(); 
					}
					if(mapOppt2ServContr != null && !mapOppt2ServContr.isEmpty())
					{
						//Keeping the scope local since we may not need the following map.
						Set<String> setOppt2Process = new Set<String>();
						for(Opportunity o :oldOppty2ProcessSSList)
						{
							setOppt2Process.add(o.Id);
						}
						for(Id oId :opportunityServiceContractMap.keySet())
						{
							if(!setOppt2Process.contains(oId))
							{
								opportunityServiceContractMap.remove(oId);
							}
						}
						List<sObject> appScList = new List<sObject>();
						Set<String> opptIdsTmpSet = new Set<String>();
						for(String oId :mapOppt2ServContr.keySet()){
							opptIdsTmpSet.add(oId);
						}
						
						if(UserInfo.isMultiCurrencyOrganization() && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
							List<Opportunity> oppList = REN_OpportunityDataAccess.checkPricebookAndCurrencyMatchForOppAndSC(opptIdsTmpSet);
							Map<Id, Opportunity> mapOpptId2OpptTmp = new Map<Id, Opportunity>(); 
							for(Opportunity o :oppList){
								mapOpptId2OpptTmp.put(o.Id, o);
							}
							
							for(String str:mapOppt2ServContr.keySet()){
								String errorMessage = '';
								SObject opp = mapOpptId2OpptTmp.get(str);
								if(opp.get(CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC) != null){
									Opportunity oppNew = newOpptRecordsMap.get(str);
								
									if(opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != null && opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != ''){
										if(opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID)){
											mapOppt2ServContr.remove(str);
											if(oppNew != null){
												errorMessage = Label.REN_ERROR_PRICEBOOK_MISMATCH_SC + '<br>';
											}
										}
									}
									else {
										SObject appServiceContract = opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r');
										appServiceContract.put('Pricebook2Id',opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID));
										appScList.add(appServiceContract);
									}
									if( opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(CSM_CONSTANTS.CURRENCY_ISO_CD) != opp.get(CSM_CONSTANTS.CURRENCY_ISO_CD)){
										mapOppt2ServContr.remove(str);
										if(oppNew != null){
											errorMessage = errorMessage + Label.REN_ERROR_CURRENCY_MISMATCH_SC;		    									
										}
									}
									if(errorMessage != ''){
										oppNew.addError(errorMessage,false);	
									}
								}
								
							}
						} else if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
							List<Opportunity> oppList = REN_OpportunityDataAccess.checkPricebookMatchForOppAndSC(opptIdsTmpSet);
							Map<Id, Opportunity> mapOpptId2OpptTmp = new Map<Id, Opportunity>(); 
							for(Opportunity o :oppList){
								mapOpptId2OpptTmp.put(o.Id, o);
							}
							for(String str:mapOppt2ServContr.keySet()){
								String errorMessage = '';
								SObject opp = mapOpptId2OpptTmp.get(str);
								if(opp.get(CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC) != null){
									Opportunity oppNew = newOpptRecordsMap.get(str);
									if(opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != null && opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != ''){
										if(opp.getSObject(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID)){
											mapOppt2ServContr.remove(str);
											if(oppNew != null){
												errorMessage = Label.REN_ERROR_PRICEBOOK_MISMATCH_SC;
											}
										}
									} else {
										SObject appServiceContract = opp.getSObject(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__r');
										appServiceContract.put('Pricebook2Id',opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID));
										appScList.add(appServiceContract);
									}
									if(errorMessage != ''){
										oppNew.addError(errorMessage,false);		    							
									}
								}
							}
						}
						if(!appScList.isEmpty()){
							//Set Pricebook2Id on existing records whereever it was missing
							List<String> scList = new List<String>{'Pricebook2Id'};
							REN_ServiceContractsDataAccess.updateServiceContracts(appScList, scList);
						}                       
						opportunityServiceContractMap.putAll(mapOppt2ServContr);
					}
				}
				List<SObject> conLineItemList=handleServiceContractLineItems(opportunityServiceContractMap, oldOppty2ProcessSSList, serviceContractList);
				Map <ID,sObject> sContractIdMap= new Map <ID,sObject>(serviceContractList);
				Map <ID,sObject> appendeSContractIdMap= new Map <ID,sObject>(lstAppendServContracts);
				
				List<SObject> oSContractList = REN_ServiceContractsDataAccess.getServiceContractsWithCLI (sContractIdMap.keySet());
				List<SObject> emptyServiceContract = new List<SObject>();
				for(SObject sObj: oSContractList){
					List<SObject> cliList = sObj.getSObjects('ContractLineItems');
					if((cliList == null || cliList.isEmpty()) && !appendeSContractIdMap.containsKey(sObj.id)){
						emptyServiceContract.add(sObj);
						sContractIdMap.remove(sObj.id);
					}
				}
				if(!emptyServiceContract.isEmpty()){
					REN_ServiceContractsDataAccess.deleteContractLineItems(emptyServiceContract);
					//return new List<SObject>();
				}
				//system.debug('conLineItemList--0-->'+conLineItemList);
				contractLineItemList.addAll(conLineItemList); 
				serviceContractList = sContractIdMap.values();  
			}
			for(sObject sc: serviceContractList){
				if (CSM_AccessController.hasField('REN_Source__c', CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c')){
					REN_Source__c scs = new REN_Source__c(REN_Type__c = 'Service Contract', REN_Reason__c = REN_Constants.REN_REASON_AUTO_REN); 
					String originalOppId = (ID)sc.get(CSM_Util.nameSpacePrefix21 + 'REN_Opportunity__c');
					scs.put(CSM_Util.nameSpacePrefix21 +'REN_Contributor_SC__c', sc.id);			
					if(newOpptRecordsMap.get(''+originalOppId) != null && newOpptRecordsMap.get(''+originalOppId).get(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c') == sc.id){
						scs.REN_Reason__c = REN_Constants.REN_REASON_ADDON;
					}else{
						oppIdSourceMap.put(originalOppId, scs);
					}
				}
			}
		}
		return serviceContractList;
	}

	private static List<Opportunity> excludeAppendServiceContracts(List<Opportunity> oldOppty2ProcessSSList, List<SObject> serviceContractList, List<Opportunity> addOnOpportunityList){
		//Filter by Append Service Contract                    
		Set<String> setAppendServContractIDs = new Set<String>();
		List<String> lstAddOnOpptIDs = new List<String>();

		if(oldOppty2ProcessSSList != null){
			setAppendServContractIDs = REN_Util.fetchAppendServiceContractIDs(oldOppty2ProcessSSList);
			lstAddOnOpptIDs = REN_Util.fetchAddOnOpportunityIDs4ServiceContract(oldOppty2ProcessSSList);
			//system.debug('lstAddOnOpptIDs : ' + lstAddOnOpptIDs);
			//system.debug('setAppendServContractIDs : ' + setAppendServContractIDs);
			if(setAppendServContractIDs != null && !setAppendServContractIDs.isEmpty()){
				set<Id> setAppendServContractIDs_IDVals = new set<Id>();
				for(String s :setAppendServContractIDs)
				{
					setAppendServContractIDs_IDVals.add(Id.valueOf(s));
				}
				List<SObject> lstAppendServContracts = REN_ServiceContractsDataAccess.getServiceContractList(setAppendServContractIDs_IDVals);
				if(lstAppendServContracts!= null && !lstAppendServContracts.isEmpty()){
					serviceContractList.addAll(lstAppendServContracts);
				}
			}
			Set<String> requestedFields=new Set<String>();
			if (CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c')){
                    requestedFields.add(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c');
            }
			if(lstAddOnOpptIDs != null && !lstAddOnOpptIDs.isEmpty()){
				set<String> oppIds=new set<String>();
                oppIds.addAll(lstAddOnOpptIDs);
				List<Opportunity> lstAddOnOpportunities = REN_OpportunityDataAccess.getOpportunityById(oppIds,requestedFields,null);
				if(lstAddOnOpportunities!= null && !lstAddOnOpportunities.isEmpty()){
					addOnOpportunityList.addAll(lstAddOnOpportunities);
				}
			}
			//system.debug('Before filter oldOppty2ProcessSSList : ' + oldOppty2ProcessSSList);
			oldOppty2ProcessSSList = REN_Util.filterOpportunityAppendServiceContracts(oldOppty2ProcessSSList);
			//system.debug('After filter oldOppty2ProcessSSList : ' + oldOppty2ProcessSSList);
		}
		return oldOppty2ProcessSSList;
	}
	/***
	 * @description: insert ContractLineItem for passed ServiceContract records based on Opportunity, Criteria and configuration.
	 * @Param: serviceContractOpportunityMap, serviceContractList, serviceContractList, renewConfigRecList.
	 * @Return: ContractLineItem list.
	 ***/
	private static List<SObject> handleServiceContractLineItems(Map<String, String> serviceContractOpportunityMap, List<Opportunity> optyProcessList, List<SObject> serviceContractList)
	{


		List<SObject> contractLineItemList;
		Map<String, OpportunityLineItem> existingOpportunityLineItemMap = new Map<String, OpportunityLineItem>();
		Map<String, List<OpportunityLineItem>> currentOppt2ExistingLines = new Map<String, List<OpportunityLineItem>>();
		Set<String> optyIdset = new set<String>();
		optyIdset.addAll(((new Map<String, Opportunity>(optyProcessList)).keySet()));
		if(serviceContractOpportunityMap != null && !serviceContractOpportunityMap.isEmpty()){
			optyIdset.addAll(serviceContractOpportunityMap.keySet());
		}
		List<REN_Field_Mappings__c> oli2cliFieldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_CONTRACT_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS);
		if(oli2cliFieldMappings == null || oli2cliFieldMappings.isEmpty()){
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_CONTRACT_LINE_ITEM}));
		}
		Set<String> fieldSet = REN_Util.getFromFldsToQuery(oli2cliFieldMappings);
		fieldSet.add('OpportunityId');
		if(UserInfo.isMultiCurrencyOrganization()){
			fieldSet.add(REN_Constants.REN_CURRENCY_ISO_CODE);
		}
		List<OpportunityLineItem> oldOpptLines = REN_OpportunityDataAccess.fetchOpptLinesByOppts(optyIdset, fieldSet);//??
		for(OpportunityLineItem ol :oldOpptLines)
		{
			List<OpportunityLineItem> opptLines = currentOppt2ExistingLines.get(ol.OpportunityId);
			if(opptLines != null && !opptLines.isEmpty())
			{
				//Leave list alone
			}
			else
			{
				opptLines = new List<OpportunityLineItem>();
			}
			opptLines.add(ol);
			currentOppt2ExistingLines.put(ol.OpportunityId, opptLines);
		}


		if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT))
		{
			contractLineItemList = createServiceContractLineItems(serviceContractOpportunityMap, currentOppt2ExistingLines, oli2cliFieldMappings);
			//system.debug('service contract line-->'+contractLineItemList);
			REN_ServiceContractsDataAccess.insertContractLineItems(contractLineItemList);
		}
		return contractLineItemList;
	}

	/***
	 * @description create ContractLineItem without insert.
	 * @Param: optyServiceContractMap, currentOppt2ExistingLines, serviceContractCriteria, renewConfigRecList
	 * @Return: ContractLineItem list.
	 ***/
	private static List<SObject> createServiceContractLineItems(Map<String, String> optyServiceContractMap, Map<String, List<OpportunityLineItem>> currentOppt2ExistingLines, List<REN_Field_Mappings__c> oli2cliFieldMappings){
		List<SObject> contractLine2Insert = new List<SObject>(); 
		set<String> contractLineFieldAddSet = new set<String>{REN_Constants.OBJ_OLI_UNITPRICE,REN_Constants.OBJ_OLI_QUANTITY};

		REN_Renew_Configuration__c renewConfigForOLI2CLI = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM); //Opportunity Product → Contract Line Item

		if(renewConfigForOLI2CLI == null ){
			return contractLine2Insert;
		}
		List<OpportunityLineItem> oldOpportunityLineItemList = new List<OpportunityLineItem> ();
		for(List<OpportunityLineItem> oliList: currentOppt2ExistingLines.values()){
			if(oliList != null && !oliList.isEmpty()){
				oldOpportunityLineItemList.addAll(oliList);
			}
		}
		Map<ID, OpportunityLineItem> oldOpportunityLineItemMap = new Map<ID, OpportunityLineItem> (oldOpportunityLineItemList);


		List<OpportunityLineItem> filteredOldOpportunityLineItemList = (List<OpportunityLineItem>)REN_OpportunityDataAccess.getFilteredRecords('OpportunityLineItem', new Set<String>(), oldOpportunityLineItemMap.keySet(), renewConfigForOLI2CLI.REN_Filter_Criteria__c, new Set<String>());
		if(filteredOldOpportunityLineItemList == null || filteredOldOpportunityLineItemList.isEmpty()){
			return contractLine2Insert;
		}

		Schema.SObjectType objectServiceContract = CSM_AccessController.getObjectType(REN_Constants.OBJ_CONTRACT_LINE_ITEM);

		Map<String, Schema.SobjectField> contractLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectServiceContract);

		Map<String, SObject> currentOpptLineId2NewContractLineMap = new Map<String, SObject>();
		Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap = new Map<String, OpportunityLineItem>();

		for(OpportunityLineItem oli :filteredOldOpportunityLineItemList){
			if (optyServiceContractMap.containsKey(oli.OpportunityId)){
				SObject contractLineItemNew = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
				contractLineItemNew.put('ServiceContractId', optyServiceContractMap.get(oli.OpportunityId));
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
		//Get Field Mapping Criteria for OpptLines and follow while creating.
		/*List<REN_Field_Mappings__c> lstServContractFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_CONTRACT_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS);
		if(lstServContractFldMappings == null || lstServContractFldMappings.isEmpty()){
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_CONTRACT_LINE_ITEM}));
		}*/
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
			contractLine2Insert.add(c);
		}
		return contractLine2Insert;
	}

	public static List<Asset> handleAssetCreation(Map<String, Opportunity> oldOpptRecordsMap, Map<String, Opportunity> newOpptRecordsMap,boolean isAutoRenewal)
	{
		List<Asset> assets2Insert = new List<Asset>();
		Map<String, String> mapOpptId2AcctId = new Map<String, String>(); 
		Map<String, String> mapOpptId2ContId = new Map<String, String>();   
		REN_Renew_Configuration__c renewConfigForOppty2Asset = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET); //Opportunity → Asset
		//system.debug('What is renewConfigForOppty2Asset : ' + renewConfigForOppty2Asset);
		//RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET  =  'Opportunity Product → Asset    
		Set<String> lineCriteriaSet = new Set<String>();
		if(renewConfigForOppty2Asset != null && renewConfigForOppty2Asset.Line_Criteria__r != null){
			for(REN_Line_Criteria__c criteria : renewConfigForOppty2Asset.Line_Criteria__r) {
				lineCriteriaSet.add(criteria.RLM_Field_Name__c);
			}  
		}
		if(renewConfigForOppty2Asset == null || !renewConfigForOppty2Asset.REN_Is_Active__c || renewConfigForOppty2Asset.REN_Filter_Criteria__c == null || !lineCriteriaSet.contains(REN_Constants.OBJ_RC_OPPORTUNITY_STAGE)
				){
			return assets2Insert;
		}
		Map<String, Opportunity> oppts2ProcessMap=new Map<String, Opportunity>();
		if(isAutoRenewal){
           oppts2ProcessMap = REN_Util.filterOpportunityAtStage(oldOpptRecordsMap, newOpptRecordsMap, renewConfigForOppty2Asset.REN_Filter_Criteria__c); 
        }
        else{
            oppts2ProcessMap=oldOpptRecordsMap;
        }
		if(oppts2ProcessMap == null || oppts2ProcessMap.isEmpty()){
			return assets2Insert; 
		}

		for(String opptId: oppts2ProcessMap.keySet()) {
			if(oppts2ProcessMap.containsKey(opptId) && (oppts2ProcessMap.get(opptId)).AccountId != null) {
				mapOpptId2AcctId.put(opptId, (oppts2ProcessMap.get(opptId)).AccountId);
			}
		}

		for(OpportunityContactRole opCR :CSM_OpportunityDataAccess.fetchOpportunityContactRole(oppts2ProcessMap.keySet())) {
			if(opCR.ContactId != null) {
				mapOpptId2ContId.put(opCR.OpportunityId, opCR.ContactId);
			}
		}

		oppts2ProcessMap = REN_Util.filterOpportunityByAcctContPresence(oppts2ProcessMap, mapOpptId2AcctId, mapOpptId2ContId);
		List<Opportunity> oppts2ProcessLst = oppts2ProcessMap.values();
		Savepoint spBeforeAssetCreate = Database.setSavepoint();
		//1. For each existing opptLine, filter lines & create Asset based on criteria.
		//Gather all OpptLines for currently processing Oppts
		Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines = new Map<String, List<OpportunityLineItem>>();
		List<REN_Field_Mappings__c> oli2AssetFieldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPTY_LINE_ITEM, null);
		if(oli2AssetFieldMappings == null || oli2AssetFieldMappings.isEmpty()){
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_ASSET}));
		}
		Set<String> fieldSet = REN_Util.getFromFldsToQuery(oli2AssetFieldMappings);
		fieldSet.add('OpportunityId');
		if(UserInfo.isMultiCurrencyOrganization()){
			fieldSet.add(REN_Constants.REN_CURRENCY_ISO_CODE);
		}
		List<OpportunityLineItem> oldOpptLines = REN_OpportunityDataAccess.fetchOpptLinesByOppts(oppts2ProcessMap.keySet(), fieldSet);//???
		Map<String, String> mapOpptLnId2OpptId = new Map<String, String>(); 
		for(OpportunityLineItem ol :oldOpptLines)
		{
			List<OpportunityLineItem> opptLines;
			if(oldOppt2ExistingLines.containsKey(ol.OpportunityId)){
				opptLines = oldOppt2ExistingLines.get(ol.OpportunityId);
				//mapOpptLnId2OpptId.put(ol.Id, ol.OpportunityId); taking and putting ouside of if, for issue assets were not getting generated for all the products. This was due to oldOppt2ExistingLines will be blank for 1st time.
				if(opptLines != null && !opptLines.isEmpty()) {
					//Leave list alone
				}
				else {
					opptLines = new List<OpportunityLineItem>();
				}
			}
			if(opptLines == null){
				opptLines = new List<OpportunityLineItem>();
			}
			opptLines.add(ol);
			oldOppt2ExistingLines.put(ol.OpportunityId, opptLines);
			mapOpptLnId2OpptId.put(ol.Id, ol.OpportunityId);
		}

		List<Asset> assets2InsertTmp = createAssets(oldOppt2ExistingLines, oli2AssetFieldMappings);
		//system.debug('!!assets2InsertTmp : '+assets2InsertTmp); 
		//system.debug('!!mapOpptLnId2OpptId :'+mapOpptLnId2OpptId); 
		for(Asset a :assets2InsertTmp)
		{
			if (a.REN_Oppty_Line_Item_Id__c!=null && mapOpptLnId2OpptId.containsKey(a.REN_Oppty_Line_Item_Id__c)){
				a.REN_Opportunity__c = mapOpptLnId2OpptId.get(a.REN_Oppty_Line_Item_Id__c); 
				if(mapOpptId2AcctId.containsKey(a.REN_Opportunity__c) && mapOpptId2AcctId.get(a.REN_Opportunity__c) != null) {
					a.AccountId = mapOpptId2AcctId.get(a.REN_Opportunity__c);
					assets2Insert.add(a);
				}
				else if(mapOpptId2ContId.containsKey(a.REN_Opportunity__c) && mapOpptId2ContId.get(a.REN_Opportunity__c) != null) {
					a.ContactId = mapOpptId2ContId.get(a.REN_Opportunity__c);
					assets2Insert.add(a);
				}
				Opportunity opp = oppts2ProcessMap.get(a.REN_Opportunity__c);
				//a.CHL_Incumbent__c = opp.CHL_Incumbent__c; //commented as per US1281
				a.CHL_Partner_Account_1__c = opp.CHL_Partner_Account_1__c;
				a.CHL_Partner_Account_1_Contact__c = opp.CHL_Partner_Account_1_Contact__c;
				a.CHL_Partner_Account_1_Type__c = opp.CHL_Partner_Account_1_Type__c;
				a.CHL_Partner_Account_2__c = opp.CHL_Partner_Account_2__c;
				a.CHL_Partner_Account_2_Contact__c = opp.CHL_Partner_Account_2_Contact__c;
				a.CHL_Partner_Account_2_Type__c = opp.CHL_Partner_Account_2_Type__c;
			}
		}
		
		List<String> fieldList = new List<String>{'Name',REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID,'ContactId','AccountId',REN_Constants.OBJ_ASSET_OPPORTUNITY};
		REN_AssetDataAccess.createAssets(assets2Insert, fieldList);
		//Eswar Bala: 02/01/2015
		for(Asset a :assets2Insert)
		{
			if (a.REN_Oppty_Line_Item_Id__c!=null){                 
				mapOldOpptLine2assetIDs.put(a.REN_Oppty_Line_Item_Id__c, a.Id);
			}
		}

		return assets2Insert;
	}


	public static List<REN_OpptLineWrapper> handleRenewalCreation(Map<String, Opportunity> oldOpptRecordsMap, Map<String, Opportunity> newOpptRecordsMap, List<REN_Source__c> sourceList)
	{
		List<REN_OpptLineWrapper> oppLnsWrapperLst = new List<REN_OpptLineWrapper>();
		
		//IF there was a record for trigger type 'Renewal Oppt' and isActive in GenConfig
		//List<REN_Renew_Configuration__c> renewConfigList = new List<REN_Renew_Configuration__c>();
		//renewConfigList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TRIGGER_TYPE_OPPORTUNITY);
		//REN_Renew_Configuration__c renewConfiguration = new REN_Renew_Configuration__c();
		REN_Renew_Configuration__c renewConfigForOppty2RenewOppty = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY); //Opportunity → Renew Opportunity
		Map<String, OpportunityLineItem> opLns2InsertMap = new Map<String, OpportunityLineItem>();
		List<OpportunityLineItem> olliLst = new List<OpportunityLineItem>();
		//system.debug('VarOne ' + renewConfigForOppty2RenewOppty + 'Vartwo ' + renewConfigForOppty2RenewOppty.REN_Is_Active__c);

		Set<String> lineCriteriaSet = new Set<String>();
		if(renewConfigForOppty2RenewOppty != null && renewConfigForOppty2RenewOppty.Line_Criteria__r != null){
			for(REN_Line_Criteria__c criteria : renewConfigForOppty2RenewOppty.Line_Criteria__r) {
				lineCriteriaSet.add(criteria.RLM_Field_Name__c);
			}  
		}
		if(renewConfigForOppty2RenewOppty == null || !renewConfigForOppty2RenewOppty.REN_Is_Active__c
				|| renewConfigForOppty2RenewOppty.REN_Filter_Criteria__c == null || !lineCriteriaSet.contains(REN_Constants.OBJ_RC_OPPORTUNITY_STAGE)

				){
			return oppLnsWrapperLst;
		}
		//Get AtStage
		Map<String, Opportunity> oppts2ProcessMap;
		
		oppts2ProcessMap = REN_Util.filterOpportunityAtStage(oldOpptRecordsMap, newOpptRecordsMap, renewConfigForOppty2RenewOppty.REN_Filter_Criteria__c);
		//system.debug('oppts2ProcessMap----->>>'+oppts2ProcessMap);
		if(oppts2ProcessMap == null || oppts2ProcessMap.isEmpty()){
			return new List<REN_OpptLineWrapper>(); 
		}

		//Eswar Bala - 02/10/2015 - Find the Opportunities appended onto (Need Query)
		// NOT USED  - List<String> lstAppendOpptIDs = REN_Util.fetchAppendOpportunityIDs(oppts2ProcessMap);
		List<String> lstAddOnOpptIDs = REN_Util.fetchAddOnOpportunityIDs4Opportunity(oppts2ProcessMap);
		//List<Opportunity> lstAppendOpportunities = REN_OpportunityDataAccess.getOpportunityDetailById(lstAppendOpptIDs);
		List<Opportunity> lstAddOnOpportunities = REN_OpportunityDataAccess.getOpportunityAllDetailsById(lstAddOnOpptIDs);
		//Eswar Bala - 02/10/2015 - Removing the Opportunities that have an Append Opportunity relationship
		List<REN_Field_Mappings__c> oli2RrFieldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_LINE_TO_RR);
		Set<String> fieldSet = REN_Util.getFromFldsToQuery(oli2RrFieldMappings);
		fieldSet.add('OpportunityId');
		if(UserInfo.isMultiCurrencyOrganization()){
			fieldSet.add(REN_Constants.REN_CURRENCY_ISO_CODE);
		}
		List<OpportunityLineItem> oldOpptLines = REN_OpportunityDataAccess.fetchOpptLinesByOppts(oppts2ProcessMap.keySet(), fieldSet);//??
		Map<String, List<OpportunityLineItem>> oldOppt2ExistLines=new Map<String, List<OpportunityLineItem>>();
		for(OpportunityLineItem ol :oldOpptLines)
		{
			List<OpportunityLineItem> opptLines = oldOppt2ExistLines.get(ol.OpportunityId);

			if(opptLines == null){
				opptLines = new List<OpportunityLineItem>();
			}
			opptLines.add(ol);
			oldOppt2ExistLines.put(ol.OpportunityId, opptLines);
		}

		List<OpportunityLineItem> filteredOpptyLines = filteredOpptyLineItems(oldOppt2ExistLines,false);
		// Restrict to renew source opportunity which dose't have renewable products. 
		if(filteredOpptyLines != null && !filteredOpptyLines.isEmpty()){
			Set<Id> opptyWithOpliIds = new Set<ID>();
			Set<String> existingOpptyids = oppts2ProcessMap.keySet();
			for(OpportunityLineItem opli : filteredOpptyLines){
				opptyWithOpliIds.add(opli.OpportunityId);
			}
			for(Id existingId : existingOpptyids){
				if(!opptyWithOpliIds.contains(existingId)){
					oppts2ProcessMap.remove(existingId);
				}
			}

			oppts2ProcessMap = REN_Util.filterOpportunityAppendOpportunities(oppts2ProcessMap);

			List<Opportunity> oppts2ProcessLst = oppts2ProcessMap.values();

			//Savepoint spBeforeOpptCreate = Database.setSavepoint();
			//Create Oppts
			List<Opportunity> newCreatedOppts = createOpportunities(oppts2ProcessLst, new List<REN_Renew_Configuration__c>{renewConfigForOppty2RenewOppty});
			if(newCreatedOppts != null && !newCreatedOppts.isEmpty()) {
				REN_OpportunityDataAccess.insertOpportunity(newCreatedOppts);
			}
			
			//Eswar Bala - 02/10/2015 - Adding the Append Oppts to the ones that we created since they are treated the same
			boolean flag;
			
			Set<String> oppSetTmp = new Set<String>();
			List<Opportunity> oppList = new List<Opportunity>();
			for(Opportunity o :lstAddOnOpportunities){
				 if(o.REN_Append_Renewal_Opportunity__c != null){
				 	oppSetTmp.add(String.valueOf(o.Id));
				 }
			}
			if(oppSetTmp != null && !oppSetTmp.isEmpty()){
				if(UserInfo.isMultiCurrencyOrganization()){
					oppList = REN_OpportunityDataAccess.getPricebookAndCurrencyForOppandAppendOpp(oppSetTmp);
				}
				else{
						oppList = REN_OpportunityDataAccess.getPricebookForOppandAppendOpp(oppSetTmp);
				}
			}
			List<SObject> lstOpptTmpUpdate = new List<SObject>();
			for(Integer i = 0; i < lstAddOnOpportunities.size(); i++) {
				flag = false;
				if (lstAddOnOpportunities[i].Id!=null){
					if(lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c!=null){
						//newOpptyIds.add(lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c);
						//system.debug('IN D ADDON '+lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c);
						if(UserInfo.isMultiCurrencyOrganization()){
							
							Map<Id, Opportunity> mapId2Oppt = new Map<Id, Opportunity>();
							for(Opportunity o :oppList){
								mapId2Oppt.put(o.Id, o);
							}
							String errorMessage = '';
							SObject opp = mapId2Oppt.get(lstAddOnOpportunities[i].Id);
							
							Opportunity oppNew = newOpptRecordsMap.get((String)opp.Id);
							if(opp.getSObject('REN_Append_Renewal_Opportunity__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != null && opp.getSObject('REN_Append_Renewal_Opportunity__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) !=''){
								if(opp.getSObject('REN_Append_Renewal_Opportunity__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID)){
									if(oppNew != null){
										errorMessage = Label.REN_ERROR_PRICEBOOK_MISMATCH_OPP + '<br>';
									}
								}
							} else {
								SObject appOpportunity = opp.getSObject('REN_Append_Renewal_Opportunity__r');
								appOpportunity.put('Pricebook2Id',opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID));
								lstOpptTmpUpdate.add(appOpportunity);
							}
	
							if( opp.getSObject('REN_Append_Renewal_Opportunity__r').get(CSM_CONSTANTS.CURRENCY_ISO_CD) != opp.get(CSM_CONSTANTS.CURRENCY_ISO_CD)){
								if(oppNew != null){
									errorMessage = errorMessage + Label.REN_ERROR_CURRENCY_MISMATCH_OPP;                                    	
								}
							}
							if(errorMessage != ''){
								oppNew.addError(errorMessage,false);
							}else{
								mapOld2NewOppts.put(lstAddOnOpportunities[i].Id, lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c);
								flag = true;                                                                    
							}
							
						} else{
							String errorMessage = '';
							
							Map<Id, Opportunity> mapId2Oppt = new Map<Id, Opportunity>();
							for(Opportunity o :oppList){
								mapId2Oppt.put(o.Id, o);
							}
							SObject opp = mapId2Oppt.get(lstAddOnOpportunities[i].Id);
							Opportunity oppNew = newOpptRecordsMap.get((String)opp.Id);
							if(opp.getSObject('REN_Append_Renewal_Opportunity__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != null && opp.getSObject('REN_Append_Renewal_Opportunity__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) !=''){
								if(opp.getSObject('REN_Append_Renewal_Opportunity__r').get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID)){
									if(oppNew != null){
										errorMessage = Label.REN_ERROR_PRICEBOOK_MISMATCH_OPP + '<br>';
									}
								}
							} else {
								SObject appOpportunity = opp.getSObject('REN_Append_Renewal_Opportunity__r');
								appOpportunity.put('Pricebook2Id',opp.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID));
								lstOpptTmpUpdate.add(appOpportunity);
							}
	
							if(errorMessage != ''){
								oppNew.addError(errorMessage,false);		    							
							}else{
								mapOld2NewOppts.put(lstAddOnOpportunities[i].Id, lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c);
								flag = true;                                                                    
							}
						}
				}else{
					mapOld2NewOppts.put(lstAddOnOpportunities[i].Id, lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c);
					flag = true;	                        				
				}                        

				}
				if (lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c!=null && flag){
					mapNew2OldOppts.put(lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c, lstAddOnOpportunities[i].Id);
					sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = lstAddOnOpportunities[i].REN_Append_Renewal_Opportunity__c, REN_Contributor__c = lstAddOnOpportunities[i].Id, REN_Type__c = 'Opportunity', REN_Reason__c = REN_Constants.REN_REASON_ADDON));
					
				}
			}
			if(lstOpptTmpUpdate != null && !lstOpptTmpUpdate.isEmpty()){
				List<String> oppFieldList = new List<String>{'Pricebook2Id'};
			    REN_OpportunityDataAccess.updateOpportunitySObject(lstOpptTmpUpdate,oppFieldList);
			}

			List<String> oppIdList=new List<String>();
			for(Integer i = 0; i < oppts2ProcessLst.size(); i++) {
				if (oppts2ProcessLst[i].Id!=null){
					mapOld2NewOppts.put(oppts2ProcessLst[i].Id, newCreatedOppts[i].Id);
					oppIdList.add(newCreatedOppts[i].Id);
				}
				if (newCreatedOppts[i].Id!=null){
					mapNew2OldOppts.put(newCreatedOppts[i].Id, oppts2ProcessLst[i].Id);
					sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = newCreatedOppts[i].Id, REN_Contributor__c = oppts2ProcessLst[i].Id, REN_Type__c = 'Opportunity', REN_Reason__c = REN_Constants.REN_REASON_AUTO_REN));
				}
				//newOpptyIds.add(newCreatedOppts[i].Id);
			}
			//Gather all OpptLines for currently processing Oppts
			Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines = new Map<String, List<OpportunityLineItem>>();
			//Eswar Bala - 02/10/2015 - Moving below line to before the append filter
			//List<OpportunityLineItem> oldOpptLines = REN_OpportunityDataAccess.fetchOpptLinesByOppts(oppts2ProcessMap.keySet());
			//system.debug('oldOpptLines : ' + oldOpptLines);
			//List<OpportunityLineItem> oldOLIList = new List<OpportunityLineItem>();
			for(OpportunityLineItem ol :filteredOpptyLines)
			{
				List<OpportunityLineItem> opptLines = oldOppt2ExistingLines.get(ol.OpportunityId);

				if(opptLines == null){
					opptLines = new List<OpportunityLineItem>();
				}
				opptLines.add(ol);
				//oldOLIList.add(ol);
				oldOppt2ExistingLines.put(ol.OpportunityId, opptLines);
			}
			opLns2InsertMap=createOppwithFilertedLineItems(filteredOpptyLines,mapOld2NewOppts,false);
			//opLns2InsertMap = createOpportunityLineItemsMap(oldOppt2ExistingLines, mapOld2NewOppts,false);
			/*************************************************/
			olliLst = opLns2InsertMap.values();
			system.debug('olliLst : ' + olliLst);
			if(olliLst != null && !olliLst.isEmpty()){
				REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = false;
				//if(!SS_Constants.isSimplifiedDataModelEnabled)	{				
					insert olliLst;	
				//}			
				REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = true;
			}
			if(mapOld2NewOppts != null && !mapOld2NewOppts.isEmpty()){//?? What is the use of this?
				//Create Related Lists
				//system.debug('olliLst : done IN' );
				REN_OpportunityResolutionHelper.createRelatedListRecords(oldOpptRecordsMap.keySet(), mapOld2NewOppts, new List<REN_Renew_Configuration__c> {renewConfigForOppty2RenewOppty});//???
			}


			if(!olliLst.isEmpty()){
				Set<String> additionalFieldSet =new Set<String>{'OpportunityId', 'REN_Source_Opportunity_Line_Item_Id__c', 'Product2Id', 'REN_Start_Date__c', 'REN_End_Date__c','Quantity', 'REN_Covered_Asset__c'};
				REN_Util.getFromAndToFldsToQuery(oli2RrFieldMappings,additionalFieldSet,null);
				Map<Id, OpportunityLineItem> oppLineItmMap = new  Map<Id, OpportunityLineItem>(olliLst);    
				List<OpportunityLineItem> renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItmMap.keySet(), additionalFieldSet);
				
				/* Reverting back changes for US2549
				if(SS_Constants.isSimplifiedDataModelEnabled)	{
					Map<Id, OpportunityLineItem> oldoppLineItmMap = new  Map<Id, OpportunityLineItem>(oldOLIList);
					renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oldoppLineItmMap.keySet(), additionalFieldSet);	
					system.debug('oldoppLineItmMap : '+oldoppLineItmMap+':::\n'+oldOLIList+'\n ::: '+renewedOppLineItemList);				
				} else {
					Map<Id, OpportunityLineItem> oppLineItmMap = new  Map<Id, OpportunityLineItem>(olliLst);    
					renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItmMap.keySet(), additionalFieldSet);
				}*/
				for(OpportunityLineItem oppLn :renewedOppLineItemList){
					REN_OpptLineWrapper olWr = new REN_OpptLineWrapper();
					olWr.opLine = oppLn;
					olWr.sourceOpptId = mapNew2OldOppts.get(oppLn.OpportunityId); //SS_Constants.isSimplifiedDataModelEnabled ? oppLn.OpportunityId:mapNew2OldOppts.get(oppLn.OpportunityId);
					olWr.sourceOpptLnId = oppLn.REN_Source_Opportunity_Line_Item_Id__c; //SS_Constants.isSimplifiedDataModelEnabled ? oppLn.Id:oppLn.REN_Source_Opportunity_Line_Item_Id__c;
					oppLnsWrapperLst.add(olWr);
				}
			}
		}
		system.debug('oppLnsWrapperLst---->'+oppLnsWrapperLst);
		return oppLnsWrapperLst;
	}

	public static List<OpportunityLineItem> filteredOpptyLineItems(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, boolean isManuallyRenewed)
	{
		//system.debug('oldOppt2ExistingLines : ' + oldOppt2ExistingLines);
		////system.debug('mapOld2NewOpportunityIds : ' + mapOld2NewOpportunityIds);
		List<OpportunityLineItem> opLns2InsertMap = new List<OpportunityLineItem>(); 
		REN_Renew_Configuration__c renewConfigForOpptyPro2RenewOpptyPro = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT); //Opportunity Product → Renew Opportunity Product

		if(renewConfigForOpptyPro2RenewOpptyPro == null){
			return opLns2InsertMap;
		}
		List<OpportunityLineItem> oldOpportunityLineItemList = new List<OpportunityLineItem> ();
		for(List<OpportunityLineItem> oliList: oldOppt2ExistingLines.values()){
			if(oliList != null && !oliList.isEmpty()){
				oldOpportunityLineItemList.addAll(oliList);
			}
		}
		Map<ID, OpportunityLineItem> oldOpportunityLineItemMap = new Map<ID, OpportunityLineItem> (oldOpportunityLineItemList);


		List<OpportunityLineItem> filteredOldOpportunityLineItemList = (List<OpportunityLineItem>)REN_OpportunityDataAccess.getFilteredRecords('OpportunityLineItem', new Set<String>(), oldOpportunityLineItemMap.keySet(), renewConfigForOpptyPro2RenewOpptyPro.REN_Filter_Criteria__c, new Set<String>());

		if(filteredOldOpportunityLineItemList == null || filteredOldOpportunityLineItemList.isEmpty()){
			return opLns2InsertMap;//No line items found
		}
		return filteredOldOpportunityLineItemList;
	}

	public static Map<String, OpportunityLineItem> createOppwithFilertedLineItems(List<OpportunityLineItem> filteredOldOpportunityLineItemList,Map<String, String> mapOld2NewOpportunityIds, boolean isManuallyRenewed)
	{
		Map<String, OpportunityLineItem> opLns2InsertMap = new Map<String, OpportunityLineItem>(); 
		//List<OpportunityLineItem> filteredOldOpportunityLineItemList = (List<OpportunityLineItem>)oldOppt2ExistingLines.value();
		renewalQualifiedOpptLines = new Map<String, List<OpportunityLineItem>>();////todo: find a way to pass this back.
		for(OpportunityLineItem oli: filteredOldOpportunityLineItemList){
			List<OpportunityLineItem> oliList = renewalQualifiedOpptLines.get(oli.id);
			if(oliList == null){
				oliList = new List<OpportunityLineItem>();
			}
			oliList.add(oli);
			renewalQualifiedOpptLines.put(oli.OpportunityID, oliList);
		}

		//system.debug('renewalQualifiedOpptLines : ' + renewalQualifiedOpptLines);
		Schema.SObjectType objectOpptLine = new OpportunityLineItem().getSobjectType();
		Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpptLine);

		Set<String> opptLineCalculatedFields = new Set<String>();
		for(Schema.SobjectField F :opptLineAllFieldNames.values())
		{
			if(F.getDescribe().isCalculated() || !F.getDescribe().isCreateable() || !F.getDescribe().isUpdateable())
			{
				opptLineCalculatedFields.add(F.getDescribe().getName());				
			}
		}
		
		//Copy field values for Required fields first. Then, copy the ones from the mapping (overwriting is fine).
		Map<String, OpportunityLineItem> oldOpptLineId2NewOpptLineMap = new Map<String, OpportunityLineItem>();
		Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap = new Map<String, OpportunityLineItem>();
		for(OpportunityLineItem olOld : filteredOldOpportunityLineItemList){

			OpportunityLineItem olNew = new OpportunityLineItem();
			olNew.TotalPrice = olOld.TotalPrice;
			olNew.put('PricebookEntryId', olOld.get('PricebookEntryId'));
			if(mapOld2NewOpportunityIds != null && mapOld2NewOpportunityIds.get(olOld.OpportunityId) !=null){
				olNew.OpportunityId = mapOld2NewOpportunityIds.get(olOld.OpportunityId);
				oldOpptLineId2NewOpptLineMap.put(olOld.Id, olNew);
				oldOpptLineId2OldOpptLineMap.put(olOld.Id, olOld);
			}
			if(isManuallyRenewed){
				oldOpptLineId2NewOpptLineMap.put(olOld.Id, olNew);
				oldOpptLineId2OldOpptLineMap.put(olOld.Id, olOld);
			}
			if(olNew.TotalPrice != null && olNew.UnitPrice != null){
				olNew.TotalPrice = null;
			}
		}
		//Get Field Mapping Criteria for OpptLines and follow while creating.
		List<REN_Field_Mappings__c> oliFieldMappingList = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_TO_RENEWAL_OPPT);
		//system.debug('\n\n~~~~oliFieldMappingList: ' + oliFieldMappingList);
		if(oliFieldMappingList == null || oliFieldMappingList.isEmpty()){
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM}));
		}

		for(String opLnId :oldOpptLineId2NewOpptLineMap.keySet()){
			OpportunityLineItem oldOli = oldOpptLineId2OldOpptLineMap.get(opLnId);
			OpportunityLineItem newOl = oldOpptLineId2NewOpptLineMap.get(opLnId);
			
			newOl.REN_Source_Opportunity_Line_Item_Id__c = opLnId;
			//newOl.REN_Original_Line_Item_ID__c = null;
			REN_Util.copyObjectUsingAdminMapping(oldOli, newOl, opptLineAllFieldNames, oliFieldMappingList);
			if(newOl.TotalPrice != null && newOl.UnitPrice != null){
				newOl.TotalPrice = null;
			}
			system.debug('newOl------------->'+newOl);
			newOl.REN_Is_CLM_Renewal__c = true;
			opLns2InsertMap.put(opLnId + ':::' + newOl.PricebookEntryId + newOl.Quantity + newOl.UnitPrice + newOl.REN_Source_Opportunity_Line_Item_Id__c, newOl);//Duplicate Line Item avoided here
		}
		return opLns2InsertMap;

	}
	public static Map<String, OpportunityLineItem> createOpportunityLineItemsMap(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, Map<String, String> mapOld2NewOpportunityIds, boolean isManuallyRenewed){
		Map<String, OpportunityLineItem> opLns2InsertMap = new Map<String, OpportunityLineItem>(); 
		REN_Renew_Configuration__c renewConfigForOpptyPro2RenewOpptyPro = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT); //Opportunity Product → Renew Opportunity Product

		if(renewConfigForOpptyPro2RenewOpptyPro == null){
			return opLns2InsertMap;
		}
		List<OpportunityLineItem> oldOpportunityLineItemList = new List<OpportunityLineItem> ();
		for(List<OpportunityLineItem> oliList: oldOppt2ExistingLines.values()){
			if(oliList != null && !oliList.isEmpty()){
				oldOpportunityLineItemList.addAll(oliList);
			}
		}
		Map<ID, OpportunityLineItem> oldOpportunityLineItemMap = new Map<ID, OpportunityLineItem> (oldOpportunityLineItemList);
		List<OpportunityLineItem> filteredOldOpportunityLineItemList = (List<OpportunityLineItem>)REN_OpportunityDataAccess.getFilteredRecords('OpportunityLineItem', new Set<String>(), oldOpportunityLineItemMap.keySet(), renewConfigForOpptyPro2RenewOpptyPro.REN_Filter_Criteria__c, new Set<String>());
		if(filteredOldOpportunityLineItemList == null || filteredOldOpportunityLineItemList.isEmpty()){
			return opLns2InsertMap;//No line items found
		}
		renewalQualifiedOpptLines = new Map<String, List<OpportunityLineItem>>();////todo: find a way to pass this back.
		for(OpportunityLineItem oli: filteredOldOpportunityLineItemList){
			List<OpportunityLineItem> oliList = renewalQualifiedOpptLines.get(oli.id);
			if(oliList == null){
				oliList = new List<OpportunityLineItem>();
			}
			oliList.add(oli);
			renewalQualifiedOpptLines.put(oli.OpportunityID, oliList);
		}
		Schema.SObjectType objectOpptLine = new OpportunityLineItem().getSobjectType();
		Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpptLine);
		//Copy field values for Required fields first. Then, copy the ones from the mapping (overwriting is fine).
		Map<String, OpportunityLineItem> oldOpptLineId2NewOpptLineMap = new Map<String, OpportunityLineItem>();
		Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap = new Map<String, OpportunityLineItem>();
		for(OpportunityLineItem olOld : filteredOldOpportunityLineItemList){
			OpportunityLineItem olNew = new OpportunityLineItem();
			olNew.put('PricebookEntryId', olOld.get('PricebookEntryId'));
			if(mapOld2NewOpportunityIds != null && mapOld2NewOpportunityIds.get(olOld.OpportunityId) !=null){
				olNew.OpportunityId = mapOld2NewOpportunityIds.get(olOld.OpportunityId);
				oldOpptLineId2NewOpptLineMap.put(olOld.Id, olNew);
				oldOpptLineId2OldOpptLineMap.put(olOld.Id, olOld);
			}
			if(isManuallyRenewed){
				oldOpptLineId2NewOpptLineMap.put(olOld.Id, olNew);
				oldOpptLineId2OldOpptLineMap.put(olOld.Id, olOld);
			}
		}
		//Get Field Mapping Criteria for OpptLines and follow while creating.
		List<REN_Field_Mappings__c> oliFieldMappingList = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_TO_RENEWAL_OPPT);
		if(oliFieldMappingList == null || oliFieldMappingList.isEmpty()){
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM}));
		}
		for(String opLnId :oldOpptLineId2NewOpptLineMap.keySet()){
			OpportunityLineItem newOl = oldOpptLineId2NewOpptLineMap.get(opLnId);
			OpportunityLineItem oldOli = oldOpptLineId2OldOpptLineMap.get(opLnId);
			newOl.REN_Source_Opportunity_Line_Item_Id__c = opLnId;
		    REN_Util.copyObjectUsingAdminMapping(oldOli, newOl, opptLineAllFieldNames, oliFieldMappingList);
		    
			if(newOl.TotalPrice != null && newOl.UnitPrice != null){
				newOl.TotalPrice = null;
			}
			newOl.REN_Is_CLM_Renewal__c = true;
			opLns2InsertMap.put(oldOli.Id + ':::' + newOl.PricebookEntryId + newOl.Quantity + newOl.UnitPrice + newOl.REN_Source_Opportunity_Line_Item_Id__c, newOl);//Duplicate Line Item avoided here			
		}
		return opLns2InsertMap;
	}

	public static Map<String, OpportunityLineItem> createOpportunityLineItemsMap(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, boolean isManuallyRenewed,String filterCriteriaName){
		Map<String, OpportunityLineItem> opLns2InsertMap = new Map<String, OpportunityLineItem>(); 
		REN_Renew_Configuration__c renewConfigForOpptyPro2RenewOpptyPro = renewConfigurationMap.get(filterCriteriaName); //Opportunity Product → Renew Opportunity Product

		if(renewConfigForOpptyPro2RenewOpptyPro == null || renewConfigForOpptyPro2RenewOpptyPro.REN_Is_Active__c==false){
			return opLns2InsertMap;
		}
		List<OpportunityLineItem> oldOpportunityLineItemList = new List<OpportunityLineItem> ();
		for(List<OpportunityLineItem> oliList: oldOppt2ExistingLines.values()){
			if(oliList != null && !oliList.isEmpty()){
				oldOpportunityLineItemList.addAll(oliList);
			}
		}
		Map<ID, OpportunityLineItem> oldOpportunityLineItemMap = new Map<ID, OpportunityLineItem> (oldOpportunityLineItemList);


		List<OpportunityLineItem> filteredOldOpportunityLineItemList = (List<OpportunityLineItem>)REN_OpportunityDataAccess.getFilteredRecords('OpportunityLineItem', new Set<String>{'Product2.Name','Product2Id','PricebookEntryId'}, oldOpportunityLineItemMap.keySet(), renewConfigForOpptyPro2RenewOpptyPro.REN_Filter_Criteria__c, new Set<String>());

		if(filteredOldOpportunityLineItemList == null || filteredOldOpportunityLineItemList.isEmpty()){
			return opLns2InsertMap;//No line items found
		}
		
		for(OpportunityLineItem oppLine: filteredOldOpportunityLineItemList){
			opLns2InsertMap.put(oppLine.id,oppLine);			
		}
		return opLns2InsertMap;
	}


	public static List<OpportunityLineItem> createOpportunityLineItems(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, Map<String, List<String>> productCriteria, 
			List<REN_Renew_Configuration__c> renewConfigurationList,Map<String, String> mapOld2NewOpportunityIds){
		return (createOpportunityLineItemsMap(oldOppt2ExistingLines, mapOld2NewOpportunityIds, false)).values();
	}

	/*Adding renewConfigurationList as additional parameter, so that we can reuse the method.*/
	public static List<Opportunity> createOpportunities(List<Opportunity> oppts2ProcessLst, List<REN_Renew_Configuration__c> renewConfigurationList)
	{
		/*String renewConfigId;
		if(renewConfigurationList != null && !renewConfigurationList.isEmpty())
		{
			renewConfigId = renewConfigurationList[0].Id;
		}*/
		String mappingName = REN_Constants.FLD_MAP_OPPT_TO_RENEWAL_OPPT;
		List<Opportunity> oppts2Create = new List<Opportunity>();
		Schema.SObjectType objectOppt = new Opportunity().getSobjectType();
		//todo: //Get Field Mapping Criteria for Oppts and follow while creating.
		Map<String, Schema.SobjectField> opptAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectOppt);
		Set<String> opptRequiredFields = new Set<String>();
		for(Schema.SobjectField F :opptAllFieldNames.values())
		{
			if(!F.getDescribe().isNillable() && !F.getDescribe().isCalculated() && F.getDescribe().isCreateable() && F.getDescribe().isUpdateable())
			{
				opptRequiredFields.add(F.getDescribe().getName());
			}
		}
		//set<String> setFieldsIgnore = new set<String>{'LastModifiedDate', 'REN_Adds_Ratio__c', 'REN_Default_Renewal_Opportunity_Name__c'};
		//Copy field values for Required fields first. Then, copy the ones from the mapping (overwriting is fine).
		List<REN_Field_Mappings__c> lstServContractFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(CSM_Constants.OBJ_OPPORTUNITY, CSM_Constants.OBJ_OPPORTUNITY, mappingName);
		if(lstServContractFldMappings != null && !lstServContractFldMappings.isEmpty()){
			Boolean recordTypeExists = CSM_Util.getRecordTypeExists(new Opportunity());
			for(Opportunity oppOld :oppts2ProcessLst){
				Opportunity oppNew = new Opportunity();
				CSM_Util.setAppliedCurrency(oppNew, CSM_Util.getAppliedCurrency(oppOld));//US452
				oppNew.AccountId = oppOld.AccountId;
				REN_ContractLineItemRenewalLogicHandler.copyObjectUsingAdminMapping(oppOld, oppNew, opptAllFieldNames, lstServContractFldMappings);
				oppNew.REN_Is_CLM_Renewal__c = true;
				oppNew.REN_Notify_Opportunity_Owner__c = true;
				oppNew.PriceBook2Id = oppOld.PriceBook2Id;
				if (recordTypeExists)
				{
					String RecordTypeIdStr = (String)oppOld.get('RecordTypeId');
					oppNew.put('RecordTypeId',RecordTypeIdStr);
				}
				oppts2Create.add(oppNew);
			}
		}else{
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_OPPORTUNITY}));
		}
		return oppts2Create;
	}   

	public static List<Asset> createAssets(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, List<REN_Field_Mappings__c> oli2AssetFieldMappings){
		//system.debug('IN createAssets');
		//system.debug('oldOppt2ExistingLines : ' + oldOppt2ExistingLines);
		String mappingName = REN_Constants.FLD_MAP_OPPT_LINE_TO_ASSET;
		List<Asset> asst2Insert = new List<Asset>(); 
		String renewConfigId;
		set<String> assetFieldIgnoreSet = new set<String>{'TotalPrice', 'REN_Oppty_Line_Item_Id__c', 'SerialNumber'};//'InstallDate'
		set<String> assetFieldAddSet = new set<String>{'Product2Id'};

		REN_Renew_Configuration__c renewConfigForOpptyPro2Asset = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET); //Opportunity Product → Asset        
		if(renewConfigForOpptyPro2Asset == null){
			return asst2Insert;
		}

		List<OpportunityLineItem> oldOpportunityLineItemList = new List<OpportunityLineItem> ();
		for(List<OpportunityLineItem> oliList: oldOppt2ExistingLines.values()){
			if(oliList != null && !oliList.isEmpty()){
				oldOpportunityLineItemList.addAll(oliList);
			}
		}
		Map<ID, OpportunityLineItem> oldOpportunityLineItemMap = new Map<ID, OpportunityLineItem> (oldOpportunityLineItemList);
		//Map<String, List<OpportunityLineItem>> lineItemsMatchPrdCriteria = REN_Util.fetchLinesMatchingCriteria(productCriteria, oldOppt2ExistingLines);

		List<OpportunityLineItem> filteredOldOpportunityLineItemList = (List<OpportunityLineItem>)REN_OpportunityDataAccess.getFilteredRecords('OpportunityLineItem', new Set<String>(), oldOpportunityLineItemMap.keySet(), renewConfigForOpptyPro2Asset.REN_Filter_Criteria__c, new Set<String>());
		if(filteredOldOpportunityLineItemList == null || filteredOldOpportunityLineItemList.isEmpty()){
			return asst2Insert;
		}
		Schema.SObjectType objectAsset = new Asset().getSobjectType();
		Map<String, Schema.SobjectField> assetAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectAsset);

		Set<String> assetRequiredFields = new Set<String>();
		for(Schema.SobjectField F :assetAllFieldNames.values())
		{
			if(!F.getDescribe().isNillable() && !F.getDescribe().isCalculated() && F.getDescribe().isCreateable() && F.getDescribe().isUpdateable())
			{
				assetRequiredFields.add(F.getDescribe().getName());
			}
		}


		Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap = new Map<String, OpportunityLineItem>();
		//system.debug('filteredOldOpportunityLineItemList : ' + filteredOldOpportunityLineItemList);
		//system.debug('oldOpptLineId2NewAssetMap : ' + oldOpptLineId2NewAssetMap);
		//system.debug('oldOpptLineId2OldOpptLineMap : ' + oldOpptLineId2OldOpptLineMap);
		//mapOldOpptLine2assetIDs
		for(OpportunityLineItem olOld :filteredOldOpportunityLineItemList){
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


		//Get Field Mapping Criteria for OpptLines and follow while creating.
		//system.debug('oldOpptLineId2NewAssetMap : ' + oldOpptLineId2NewAssetMap);
		/*List<REN_Field_Mappings__c> lstServContractFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPTY_LINE_ITEM, mappingName);
		if(lstServContractFldMappings == null || lstServContractFldMappings.isEmpty()){
			throw new FieldMappingException(String.format(mappingNotDefinedErrMsg, new String[]{REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_ASSET}));
		}*/
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
			oldOpptLineId2NewAssetMap.put(opLnId, newAsset);
		}
		//system.debug('oldOpptLineId2NewAssetMap final : ' + oldOpptLineId2NewAssetMap);

		for(Asset a :oldOpptLineId2NewAssetMap.values()) {
			asst2Insert.add(a);
		}
		return asst2Insert;
	}

	public with sharing class FieldMappingException extends Exception{}
	 
}