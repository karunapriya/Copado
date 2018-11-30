public with sharing class REN_CreateOptyFromServiceContractCtrl {
     public boolean hasRenewAccess {get; private set;}
     public List<Opportunity> renewOpportunityList {get;set;}
     public List<SObject> serviceContractList {get;set;}
     public String parentServiceContractId {get;set;}
     public list <REN_OpptLineWrapper> lstAllOpptLinesW {get;set;}
     public List <REN_Renew_Configuration__c> renewConfigurationList {get;set;}
     public List<SObject> contractLineItemList {get;set;}
     public List<OpportunityLineItem> opportunityLineItemList {get;set;}
     public Boolean isActive {get;set;}
     public string recordCurrencyCode{get;set;} //Created for US454
     private Map<Id, OpportunityLineItem> cliToOppLineItemMap = new Map<Id, OpportunityLineItem>();
     private Map<String, REN_OpptLineWrapper> oliWrapMap = new Map<String, REN_OpptLineWrapper>();
     private List<OpportunityLineItem> opplineItems{get;set;}
     List<OpportunityLineItem> mappedOpportunityLineItemList = new List<OpportunityLineItem>();
     Map<Id, String> pbEntryIdToProdName = new Map<Id, String>();
     private Boolean sdmFlag;
     public String serviceContractId;
     
     public PageReference returnPage() {
     	PageReference pageRef;
   		if(sdmFlag){
   			pageRef = Page.REN_GenerateSimplifiedOpportunity;
            pageRef.getParameters().put('contractId', serviceContractId);
            	
   		}
   		return pageRef;
        
     }
   
     /** standard controller **/
    public REN_CreateOptyFromServiceContractCtrl() {
        try {
        	sdmFlag =false;
        	SS_License__c ssLicense = SS_License__c.getOrgDefaults();
        	if(ssLicense!=null){
            	sdmFlag = ssLicense.Simplified_Data_Model_Is_Enabled__c;
        	}
        	
            serviceContractId = ApexPages.currentPage().getParameters().get('contractId'); 
            serviceContractId = String.escapeSingleQuotes(serviceContractId);
            this.isActive = true;
            hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled; 
            Boolean hasServiceContract = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
            
            if(serviceContractId != null && serviceContractId.length() > 0 && hasServiceContract == true) {
                this.parentServiceContractId = serviceContractId;
                List<sObject> existingServiceContractList = REN_ServiceContractsDataAccess.getServiceContractList(new Set<Id> {
                    this.parentServiceContractId
                });

                Set<String> fieldTypes = new Set<String>();
                fieldTypes.add('anytype');

                String soqlServiceContractStr = CSM_Util.getSOQLString(REN_Constants.OBJ_SERVICE_CONTRACT, null, 'id=\'' + existingServiceContractList[0].Id + '\'', fieldTypes, null);
                this.serviceContractList = Database.query(soqlServiceContractStr);
                String parentServiceEscpStr = '';
                if(this.parentServiceContractId != null){
                    parentServiceEscpStr = String.escapeSingleQuotes(this.parentServiceContractId);
                }

                String soqlContractLineItemStr = CSM_Util.getSOQLString(REN_Constants.OBJ_CONTRACT_LINE_ITEM, null, 'ServiceContractId=\'' + parentServiceEscpStr + '\'', fieldTypes, null);
                this.contractLineItemList = Database.query(soqlContractLineItemStr);
                this.renewOpportunityList = getServiceContractToOpportunityMappingList(serviceContractList);
           
                cliToOppLineItemMap = getContractLineToOpportunityLineMappingList(contractLineItemList);
        
                mappedOpportunityLineItemList = cliToOppLineItemMap.values();
                if(serviceContractList!=null && !serviceContractList.isEmpty()){
                    // VCP - ORG21 check
                    if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID)) {
                        String opptyId = (String)serviceContractList[0].get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID);
                        pbEntryIdToProdName = getPbEntryIdToProdName(new List <String> {opptyId});
                        this.populateOpliWrapperList(mappedOpportunityLineItemList, pbEntryIdToProdName);
                        system.debug('lstAllOpptLinesW::'+lstAllOpptLinesW.size());
                    }
                    //Below code is added for US454
                    SObject thisSC = serviceContractList[0];
                    recordCurrencyCode = CSM_Util.getRecordLevelCurrency(thisSC,false);
                }
            } else {    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, System.Label.REN_LBL_SERVICE_CONTRACTS_CONTACT_ADMIN)); 
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
    } 
            
       /***
       * @description Get Mapped Opportunity Mapped records with ServiceContract
       * @Param: List <ServiceContract>, List <REN_Renew_Configuration__c>.
       * @Return: Opportunity list
       ***/
      public static List <Opportunity> getServiceContractToOpportunityMappingList(List <SObject> serviceContract2ProcessList) {
          List <Opportunity> opportunityToCreate = new List <Opportunity> ();
          Map <String, Opportunity> currentServiceContract2OptyNewMap = new Map < String, Opportunity > ();
          Map <String, SObject> currentServiceContractId2CurrentServiceContractMap = new Map <String, SObject> ();
          Schema.SObjectType objectOpportunity;
          objectOpportunity = new Opportunity().getSobjectType();
          Map <String, Schema.SobjectField> opportunityFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpportunity);
          set <String> serviceContractOptyCommonFieldSet = new set <String> {
              REN_Constants.OBJ_SC_PRICEBOOK2_ID
          };
          for (SObject sc: serviceContract2ProcessList) {
              Opportunity newOpportunity = new Opportunity(AccountId = (String)sc.get('AccountId'),REN_Is_CLM_Renewal__c = true);
              CSM_Util.setAppliedCurrency(newOpportunity, CSM_Util.getAppliedCurrency(sc));//US452 
              for (String fieldName: opportunityFieldNames.keySet()) {
                  if (serviceContractOptyCommonFieldSet.contains(fieldName)) {
                      newOpportunity.put(fieldName, sc.get(fieldName));
                  }
              }
              currentServiceContract2OptyNewMap.put(sc.Id, newOpportunity);
              currentServiceContractId2CurrentServiceContractMap.put(sc.Id, sc);
          }
          String mappingName = REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY;
          List<REN_Field_Mappings__c> lstServContractFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_SERVICE_CONTRACT, mappingName);
          for(String scId: currentServiceContract2OptyNewMap.keySet()) {
              Opportunity newOpportunity = currentServiceContract2OptyNewMap.get(scId);
              //todo: Eswar: pass valid mapping 
              for(REN_Field_Mappings__c fMapping: lstServContractFldMappings) {
                  SObjectField serviceContractSObjectFld = opportunityFieldNames.get(fMapping.REN_To_Field_API_Name__c);
                  if(serviceContractSObjectFld != null)
                  {
                     system.debug('serviceContractSObjectFld.getDescribe().getType() : ' + serviceContractSObjectFld.getDescribe().getType());
                      
                      newOpportunity = getMappedserviceContractBasedOpty(newOpportunity, scId, String.valueOf(serviceContractSObjectFld.getDescribe().getType()),
                          currentServiceContractId2CurrentServiceContractMap, fMapping.REN_Default_Value__c,
                          fMapping.REN_To_Field_API_Name__c, fMapping.REN_From_Field_API_Name__c);
                  }
              }
              currentServiceContract2OptyNewMap.put(scId, newOpportunity);
          }
          for (Opportunity o: currentServiceContract2OptyNewMap.values()) {
              opportunityToCreate.add(o);
          }
          return opportunityToCreate;
      }
  
      /***
        * @description Get OpportunityLineItem Maped records with ContractLine records.
        * @Param: List <ContractLineItem>,List <REN_Renew_Configuration__c>.
        * @Return: OpportunityLineItem list
       ***/
       public static Map <Id, OpportunityLineItem> getContractLineToOpportunityLineMappingList(List<SObject> contractLineItem2ProcessList) {
           
           Map <Id, OpportunityLineItem> contractLine2OpportunityLineNewMap = new Map <Id, OpportunityLineItem> ();
           Map <String, SObject> currentContractLineItemId2ContractLineItemMap = new Map <String, SObject> ();
         
           Schema.SObjectType objectOpportunityLineItem;
           objectOpportunityLineItem = new OpportunityLineItem().getSobjectType();
           String mappingName = REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY;
 
           Map <String, Schema.SobjectField> opportunityLineItemFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpportunityLineItem);
           set <String> contractLineOptyLineCommonFieldSet = new set <String> {
               REN_Constants.OBJ_SC_PRICEBOOK2_ID
           };
           for (SObject cl: contractLineItem2ProcessList) {
                
               OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem(PricebookEntryId = (String)cl.get('PricebookEntryId'), UnitPrice = (double)cl.get('UnitPrice'), Quantity = (double)cl.get('Quantity'), REN_Is_CLM_Renewal__c = true);
               for (String fieldName: opportunityLineItemFieldNames.keySet()) {
                   if (contractLineOptyLineCommonFieldSet.contains(fieldName)) {
                       newOpportunityLineItem.put(fieldName, cl.get(fieldName));
                   }
               }
               contractLine2OpportunityLineNewMap.put(cl.Id, newOpportunityLineItem);
               currentContractLineItemId2ContractLineItemMap.put((String)cl.get('Id'), cl);
           }
           List<REN_Field_Mappings__c> lstServContractFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_CONTRACT_LINE_ITEM, mappingName);
           for (String clId: contractLine2OpportunityLineNewMap.keySet()) {
               OpportunityLineItem newOpportunityLineItem = contractLine2OpportunityLineNewMap.get(clId);
               newOpportunityLineItem.REN_Covered_Asset__c = (ID)currentContractLineItemId2ContractLineItemMap.get(clId).get('AssetId');//US605
               for (REN_Field_Mappings__c fMapping: lstServContractFldMappings) {
                   SObjectField ContractLineSObjectFld = opportunityLineItemFieldNames.get(fMapping.REN_To_Field_API_Name__c);
                   newOpportunityLineItem = getMappedContractLineBasedOli(newOpportunityLineItem, clId, String.valueOf(ContractLineSObjectFld.getDescribe().getType()),
                                                                       currentContractLineItemId2ContractLineItemMap, fMapping.REN_Default_Value__c,
                                                                       fMapping.REN_To_Field_API_Name__c, fMapping.REN_From_Field_API_Name__c);
               }
               contractLine2OpportunityLineNewMap.put(clId, newOpportunityLineItem);
           }
           return contractLine2OpportunityLineNewMap;
       }
   
    /***
      * @description get PricebookEntryId, product Name Map 
      * @Param: List<String>, opportunityId Set
      * @Return: PricebookEntryId, product Name Map.
      ***/
    @TestVisible private Map<Id, String> getPbEntryIdToProdName (List<String> optyIdList) {
        Map<Id, String> pbEntryIdToProductName = new Map<Id, String>();
        List <OpportunityLineItem > oliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new set<String>{optyIdList[0]});
        if (!oliList.isEmpty()){
            for (OpportunityLineItem oli: oliList){ 
                pbEntryIdToProductName.put(oli.PricebookEntryId, oli.Product2.Name);
            }
        }
        return pbEntryIdToProductName;
    }
    
     /***
      * @description populates REN_OpptLineWrapper
      * @Param: List<OpportunityLineItem>, Map<Id, String>
      * @Return: void method.
      ***/
      @TestVisible private void populateOpliWrapperList(List<OpportunityLineItem> OpportunityLineItemList, Map<Id, String> pbEntryIdToProductName) {
        this.lstAllOpptLinesW = new list <REN_OpptLineWrapper>();
        
        Map<ID,String> oliPricebookEntryIdProductNameMap = new Map<ID,String>();
        Map<ID, PricebookEntry> pricebookEntryMap = new Map <ID, PricebookEntry>();
        Map<ID, Product2> product2Map = new Map <ID, Product2>();
        
        if (!OpportunityLineItemList.isEmpty()) {
            Set<ID> pricebookEntryIdSet = new Set<ID>();
            for (OpportunityLineItem ol: OpportunityLineItemList) {
                if(ol.PricebookEntryId != null){
                    pricebookEntryIdSet.add(ol.PricebookEntryId);
                }
            }
            if(!pricebookEntryIdSet.isEmpty()){
                pricebookEntryMap = new Map <ID, PricebookEntry> ();
                pricebookEntryMap = REN_PricebookDataAccess.getPbEntryDetail(pricebookEntryIdSet);
                Set<ID> product2IdSet = new Set<ID>();
                for (PricebookEntry pricebookEntryObj: pricebookEntryMap.values()) {
                    product2IdSet.add(pricebookEntryObj.Product2Id);
                }
                
                if(!product2IdSet.isEmpty()){
                    product2Map = new Map <ID, Product2>(); 
                    product2Map = REN_ProductDataAccess.getProductDetail();
                }
            }
            
            for (Integer i=0; i<OpportunityLineItemList.size(); i++) {
                OpportunityLineItem ol = OpportunityLineItemList.get(i);
                REN_OpptLineWrapper olW = new REN_OpptLineWrapper();
                olW.opLine = ol;
                olW.customId = i;
                PricebookEntry pricebookEntryObj = pricebookEntryMap.get(ol.PricebookEntryId);
                if(pricebookEntryObj != null){
                    Product2 product2Obj = product2Map.get(pricebookEntryObj.Product2Id);
                    if(product2Obj!= null){
                        olW.opportunityProduct = product2Obj.name;
                        olW.product2Id = pricebookEntryObj.Product2Id;
                    }
                }
                this.lstAllOpptLinesW.add(olW);
                oliWrapMap.put(ol.PricebookEntryId, olW);
            }
        }
    }
     /***
      * @description Get Mapped OpportunityLineItemt record list
      * @Param: OpportunityLineItem, optyId, fieldTyp, currentContractLineItemId2ContractLineItemMap, defaultVal, toField, fromField.
      * @Return: OpportunityLineItem record
      ***/
     public static OpportunityLineItem getMappedContractLineBasedOli(OpportunityLineItem newOpportunityLineItem, String clId, String fieldTyp,
         Map < String, SObject > currentContractLineItemId2ContractLineItemMap, String defaultVal, String toField,
         String fromField) {
         if (defaultVal != null && defaultVal.trim() != '') {
             if (fieldTyp == CSM_Constants.TYPE_CURRENCY || fieldTyp == CSM_Constants.TYPE_DOUBLE) {
                 newOpportunityLineItem.put(toField, Double.valueOf(defaultVal));
             } else if (fieldTyp == CSM_Constants.TYPE_INTEGER || fieldTyp == CSM_Constants.TYPE_PERCENT) {
                 newOpportunityLineItem.put(toField, Integer.valueOf(defaultVal));
             } else if (fieldTyp == CSM_Constants.TYPE_DATETIME) {
                 newOpportunityLineItem.put(toField, DateTime.valueOf(defaultVal + ' 00:00:00'));
             } else if (fieldTyp == CSM_Constants.TYPE_DATE) {
                 newOpportunityLineItem.put(toField, Date.valueOf(defaultVal + ' 00:00:00'));
             } else if (fieldTyp == CSM_Constants.TYPE_BOOLEAN) {
                 newOpportunityLineItem.put(toField, Boolean.valueOf(defaultVal));
             } else {
                 newOpportunityLineItem.put(toField, defaultVal);
             }
         } else if (fromField != null) {
             newOpportunityLineItem.put(toField, (currentContractLineItemId2ContractLineItemMap.get(clId)).get(fromField));
         }
         return newOpportunityLineItem;
     }
    
       /***
        * @description Get Mapped Opportunity record list
        * @Param: Opportunity, String, String, Map<String, ServiceContract>, String
        * @Return: Opportunity list
        ***/
       public static Opportunity getMappedserviceContractBasedOpty(Opportunity newOpportunity, String scId, String fieldTyp,
           Map < String, SObject > currentServiceContractId2CurrentServiceContractMap, String defaultVal, String toField,
           String fromField) {
           if (defaultVal != null && defaultVal.trim() != '') {
               if (fieldTyp == CSM_Constants.TYPE_CURRENCY || fieldTyp == CSM_Constants.TYPE_DOUBLE) {
                   newOpportunity.put(toField, Double.valueOf(defaultVal));
               } else if (fieldTyp == CSM_Constants.TYPE_INTEGER || fieldTyp == CSM_Constants.TYPE_PERCENT) {
                   newOpportunity.put(toField, Integer.valueOf(defaultVal));
               } else if (fieldTyp == CSM_Constants.TYPE_DATETIME) {
                   newOpportunity.put(toField, DateTime.valueOf(defaultVal + ' 00:00:00'));
               } else if (fieldTyp == CSM_Constants.TYPE_DATE) {
                   newOpportunity.put(toField, Date.valueOf(defaultVal + ' 00:00:00'));
               } else if (fieldTyp == CSM_Constants.TYPE_BOOLEAN) {
                   newOpportunity.put(toField, Boolean.valueOf(defaultVal));
               } else {
                   newOpportunity.put(toField, defaultVal);
               }
           } else if (fromField != null) {
               newOpportunity.put(toField, (currentServiceContractId2CurrentServiceContractMap.get(scId)).get(fromField));
           }
           return newOpportunity;
       }
    

    
       /***
        * @description page reference cancel, takes back to parent ServiceContract
        * @Param: none
        * @Return: page reference of parent ServiceContract.
        ***/
      public PageReference cancel() {
        PageReference page = new PageReference('/' + this.parentServiceContractId);
        return page;
    }
    
      /***
        * @description page reference Save
        * @Param: none
        * @Return: page reference of newly created  Opportunity.
        ***/
      public PageReference save() {
 		REN_CONSTANTS.IS_AUTO_REBUILD = false;
        PageReference page;
        Savepoint spBeforeOpptCreate = Database.setSavepoint();
        try {
        	CSM_TriggerManager.disableAllTriggers();
            if(lstAllOpptLinesW == null || lstAllOpptLinesW.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.REN_NO_OPPTY_PRODUCT));
                return null;
            }
   
            if (Test.isRunningTest()){
            	for (Opportunity o: this.renewOpportunityList)
            	{
            		o.probability = 5;
            		o.CloseDate = System.today();
            	}
            }
            if(CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c')) {
              	this.renewOpportunityList[0].put('Opportunity_Name__c', this.renewOpportunityList[0].Name);	 
            } 
            List <Opportunity> opportunityList = CSM_OpportunityDataAccess.insertRenewalOpportunity(this.renewOpportunityList);
            CSM_TriggerManager.TriggerHandler triggerHandler = new CSM_OpportunityTriggerHandler();
            triggerHandler.onAfterInsert(opportunityList, new Map<ID, Opportunity> (opportunityList));
            this.saveOpli(new List<String>{opportunityList[0].Id});
            /******************************************/
            List<REN_Field_Mappings__c> lstOliToRrFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_LINE_TO_RR);
			Set<String> additionalFieldSet =new Set<String>{'OpportunityId','REN_Source_Opportunity_Line_Item_Id__c', 'Product2Id', 'REN_Start_Date__c', 'REN_End_Date__c','Quantity','REN_Covered_Asset__c','TotalPrice'};
			REN_Util.getFromAndToFldsToQuery(lstOliToRrFldMappings,additionalFieldSet,null);
			Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>(opplineItems);
            List<OpportunityLineItem> renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItemMap.keySet(), additionalFieldSet);
            Map<Id, OpportunityLineItem> oliDetailedMap = new Map<Id, OpportunityLineItem>(renewedOppLineItemList);	
			for(ID assetId: cliToOppLineItemMap.keySet()){
				cliToOppLineItemMap.put(assetId, oliDetailedMap.get(cliToOppLineItemMap.get(assetId).id));
			}
						
			
            /*******************************************/
            
            this.saveRrFromContractLineItem(cliToOppLineItemMap);

			List<REN_Source__c> sourceList = new List<REN_Source__c>();
			sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = opportunityList[0].Id, REN_Type__c = 'Service Contract', REN_Reason__c = REN_Constants.REN_REASON_MAN_REN));
			if (CSM_AccessController.hasField('REN_Source__c', CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c')){
				sourceList[0].put(CSM_Util.nameSpacePrefix21 +'REN_Contributor_SC__c', serviceContractList[0].id);
			}
			serviceContractList[0].put(CSM_Util.nameSpacePrefix21 +'REN_Renewal_Opportunity__c', opportunityList[0].Id);
			REN_ServiceContractsDataAccess.upsertServiceContractList(serviceContractList);
			REN_SourceDataAccess.saveSourceRecords(sourceList);
			
			if(opportunityList != null && !opportunityList.isEmpty()){
				REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(opportunityList);
			}
            
            page = new PageReference('/' + opportunityList[0].Id);
            
        } catch (Exception ex) {
            for(Opportunity s: renewOpportunityList){
				s.id = null;
			}
            Database.rollback(spBeforeOpptCreate);
            if(contractLineItemList != null && !contractLineItemList.isEmpty()){
            	cliToOppLineItemMap = getContractLineToOpportunityLineMappingList(contractLineItemList); 
            	mappedOpportunityLineItemList = cliToOppLineItemMap.values();	
            }
            if(mappedOpportunityLineItemList != null && pbEntryIdToProdName != null){
            	this.populateOpliWrapperList(mappedOpportunityLineItemList, pbEntryIdToProdName);  	
            }                     
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));            
        }
        return page;
    }
    
  /***
    * @description Inserts OpportunityLineItem records
    * @Param: List<String>
    * @Return: void method.
    ***/
   private void saveOpli(List<String> optyIdList ) {
    	List <OpportunityLineItem> oliListToInsert;
    	opplineItems = new List<OpportunityLineItem>();
    	for (String renewOpportunityId:optyIdList) {
	    	 oliListToInsert = new List <OpportunityLineItem> ();
	        for (REN_OpptLineWrapper olW: this.lstAllOpptLinesW) {
	            olW.opLine.OpportunityId = renewOpportunityId;
	            oliListToInsert.add(olW.opLine);
	        }
    	}
       opplineItems = REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(oliListToInsert);
    }
    
  
    /***
    * @description Inserts REN_Renews_To__c records
    * @param: Map<String, OpportunityLineItem>
    * @return: void method.
    ***/
    @TestVisible private void saveRrFromContractLineItem( Map<Id, OpportunityLineItem> cliToOLItemMap){
        List<REN_Renews_To__c> rrListToInsert;
        Set<String> fieldSetForCRUD = new Set<String>{'REN_Renewal_Target__c', 'ren_asset__c','REN_Renewal_Status__c', 'REN_Previous_Price__c','REN_Renewal_Target_Multiplier__c'};
        List <REN_Field_Mappings__c> fieldMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('',REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM);
        Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(REN_Renews_To__c.sObjectType);
        rrListToInsert = new List<REN_Renews_To__c>();
        Map<ID, sObject> cliMap = new Map<ID, sObject>(contractLineItemList);
        boolean isFieldAvailable = CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT);
       	Map<Id, REN_Renews_To__c> cliToRliMap = new Map<Id, REN_Renews_To__c> ();
       	for(ID cliId :cliToOLItemMap.keySet())
        {
            REN_Renews_To__c renewalRelationship = new REN_Renews_To__c();
            OpportunityLineItem oli = cliToOLItemMap.get(cliId);
            if(oli == null){
            	continue;
            }
            sObject sobjRR = REN_Util.copyObjectUsingAdminMapping(oli, renewalRelationship, opptLineAllFieldNames, fieldMappingLst);
            if (isFieldAvailable){
                // Entitlement Extension check
                renewalRelationship.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, this.parentServiceContractId);
                renewalRelationship.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM, cliId);
                cliToRliMap.put(cliId,renewalRelationship);
                fieldSetForCRUD.add(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT);
                fieldSetForCRUD.add(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM);
            }
            
            if (Test.isRunningTest()){
	           	String renewalOppId = cliToOLItemMap.get('' + cliId).OpportunityId;
                List<Account> accts = CSM_TestDataUtility.createAccount(1);
                List<Opportunity> opptys = CSM_TestDataUtility.createOpportunity(1, accts[0].Id);
                renewalOppId = opptys[0].Id;
            }
           
            renewalRelationship.put(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, oli.OpportunityId);
            if (UserInfo.isMultiCurrencyOrganization()){
            	renewalRelationship.put('CurrencyIsoCode',(String)oli.get('CurrencyIsoCode'));
                fieldSetForCRUD.add('CurrencyIsoCode');	
            }
            //renewalRelationship.put(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO_PRODUCT_ID,  oli.Id);
            //fieldSetForCRUD.add('REN_Renewal_Product_Line_Id__c');
            renewalRelationship.put(REN_Constants.OBJ_REN_RENEWS_TO_PRODUCT,  oli.product2Id);
            fieldSetForCRUD.add('REN_Product__c');
            rrListToInsert.add(renewalRelationship);
            REN_Util.getFromAndToFldsToQuery(fieldMappingLst ,null, fieldSetForCRUD);
        }
        REN_RRSimplifiedTriggerHelper.processRliRecords(rrListToInsert);
        REN_RenewRelationshipDataAccess.insertRLI(rrListToInsert, new List<String>(fieldSetForCRUD));
        updateOLIRecords(cliToRliMap, cliToOppLineItemMap);
    }
    
    /* US3467 : This method is used populate new relationship field 'Renewable Line Item' on OLI with the corresponding RLI created for CLI*/
    private void updateOLIRecords(Map<Id, REN_Renews_To__c> cliToRliMap, Map<Id, OpportunityLineItem> cliToOppLineItemMap){
    	List<OpportunityLineItem> oliListToUpdate = new List<OpportunityLineItem>();
    	for(ID cliId :cliToOppLineItemMap.keySet()){
	    	OpportunityLineItem oli = cliToOppLineItemMap.get(cliId);
	    	if(oli != null && cliToRliMap.containsKey(cliId)){
	    		REN_Renews_To__c renewsTo = cliToRliMap.get(cliId);
	    		oliListToUpdate.add(new OpportunityLineItem(id = oli.id, REN_Renewable_Line_Item__c = renewsTo.id));
	    	}
    	}
        REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliListToUpdate, new Set<String>{'REN_Renewable_Line_Item__c'});
    }
}