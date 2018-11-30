public with sharing class REN_CreateRenewalOpportunityCtrl 
{
    public boolean hasRenewAccess{get; private set;}
	public List<Opportunity> renewOpportunityList{get;set;}
    public Opportunity existingOpportunity{get;set;}
    public list <REN_OpptLineWrapper> lstAllOpptLinesW{get;set;}
    public List <REN_Renew_Configuration__c> renewConfigurationList{get;set;}
    public string recordCurrencyCode{get;set;} // created for US454
    public static Map<String, List<OpportunityLineItem>> renewalQualifiedOpptLines = new Map<String, List<OpportunityLineItem>>();
	public static Map<String, String> mapOldOpptLine2assetIDs = new Map<String, String>();
    public static Map<String, String> mapOld2NewOppts = new Map<String, String>();
	public static Map<String, String> mapNew2OldOppts = new Map<String, String>();
	public string opptyId{get;set;}
 	private Boolean sdmFlag;
 	private ApexPages.StandardController standardController;
 	
 	public PageReference returnPage()
   	{
    	PageReference pageRef;
        if(sdmFlag){
            pageRef = Page.REN_GenerateSimplifiedOpportunity;
            pageRef.getParameters().put('OpptId', opptyId);     
        }
        return pageRef;
    }

    public REN_CreateRenewalOpportunityCtrl(ApexPages.StandardController stdController)
    {
		try
		{
			sdmFlag =false;
			SS_License__c ssLicense = SS_License__c.getOrgDefaults();
			if(ssLicense!=null){
          		sdmFlag = ssLicense.Simplified_Data_Model_Is_Enabled__c;
        	}
            this.standardController = stdController;
        	hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled; 	
        	String whereClause = 'id=\'' + stdController.getRecord().id + '\'';
        	Set<String> requestedFields=new Set<String>{'Pricebook2Id', 'Name', 'AccountId', 'Description', 'CHL_Partner_Account_1__c', 'CHL_Partner_Account_1_Contact__c', 'CHL_Partner_Account_1_Type__c', 'CHL_Partner_Account_2__c', 'CHL_Partner_Account_2_Contact__c', 'CHL_Partner_Account_2_Type__c'};
            if (CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c')){
                    requestedFields.add(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c');
            }
            List<REN_Field_Mappings__c> fieldMappings=REN_RenewReferenceData.getInstance().fieldMappingsMap.get(CSM_Constants.OBJ_OPPORTUNITY + ':' + CSM_Constants.OBJ_OPPORTUNITY);
            requestedFields.addAll(REN_Util.getFromFldsToQuery(fieldMappings));
        	String soqlStr = CSM_Util.getSOQLString(CSM_Constants.OBJ_TYPE_OPPORTUNITY, requestedFields, whereClause, null, null);
	        this.existingOpportunity = Database.query(soqlStr);
	        
	 		this.renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
	 		this.renewOpportunityList = REN_OpportunityResolutionTriggerHandler.createOpportunities(
	        											new List<Opportunity>{this.existingOpportunity}, renewConfigurationList);
	        if(CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c')){
				this.renewOpportunityList[0].put('Opportunity_Name__c',this.renewOpportunityList[0].Name);
			}
	        Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines = new Map<String, List<OpportunityLineItem>>();
	        Map<String, String> pbEntryIdToProdName = new Map<String, String>();
	        this.populateMapValues(oldOppt2ExistingLines, pbEntryIdToProdName);
	        this.populateOpliWrapperList(oldOppt2ExistingLines, pbEntryIdToProdName);
	        //Below code is added for US454			
		    SObject thisOpty = this.existingOpportunity;
		    recordCurrencyCode = CSM_Util.getRecordLevelCurrency(thisOpty,false);
		}
		catch(Exception ex)
		{
			system.debug('\n\n~~~~Error : '+ ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
		}
    }

    public PageReference save()
    {
    	CSM_TriggerManager.disableAllTriggers();
    	REN_CONSTANTS.IS_AUTO_REBUILD = false;
        PageReference page;
        Savepoint spBeforeOpptCreate = Database.setSavepoint();
        try
        {
        	if(lstAllOpptLinesW == null || lstAllOpptLinesW.isEmpty()){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.REN_NO_OPPTY_PRODUCT));
        		return null;
        	}
            List <Opportunity> opportunityList = CSM_OpportunityDataAccess.insertRenewalOpportunity(this.renewOpportunityList);
            CSM_TriggerManager.TriggerHandler triggerHandler = new CSM_OpportunityTriggerHandler();
            triggerHandler.onAfterInsert(opportunityList,new Map<Id,sObject>(opportunityList));
            list <REN_OpptLineWrapper> lstofAllOpptLinesW = this.saveOpli(new List<String>{opportunityList[0].Id});
            Map<String, Opportunity> oldOpptRecordsMap = new Map<String, Opportunity>(new list<Opportunity>{existingOpportunity});
            Map<ID, REN_Source__c> oppIdSourceMap = new Map<ID,REN_Source__c>();			
			List<SObject> contractLineItemList = new List<SObject>();
            List<Asset> assetsInserted = REN_OpportunityResolutionTriggerHandler.handleAssetCreation(oldOpptRecordsMap, oldOpptRecordsMap,false);
            if(assetsInserted != null && !assetsInserted.isEmpty()){
                for(Asset objAsset :assetsInserted)
                {
                	if (!String.isBlank(objAsset.REN_Oppty_Line_Item_Id__c)){                 
                        mapOldOpptLine2assetIDs.put(objAsset.REN_Oppty_Line_Item_Id__c, objAsset.Id);
                    }
                }
            }
            List<SObject> serviceContractList = REN_OpportunityResolutionTriggerHandler.handleServiceContracts(oldOpptRecordsMap, oldOpptRecordsMap, contractLineItemList, oppIdSourceMap,false);
            REN_OpportunityResolutionHelper.createRenewalRelationships(lstofAllOpptLinesW, serviceContractList, contractLineItemList, renewalQualifiedOpptLines, mapOldOpptLine2assetIDs,mapOld2NewOppts);			
			REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(opportunityList);
			List<String> oppFieldSetForCRUD = new List<String>{'Name'};
            List<REN_Source__c> sourceList = new List<REN_Source__c>();
            list<SObject> SCList=new list<SObject>();
			sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = opportunityList[0].Id, REN_Contributor__c = this.existingOpportunity.Id, REN_Type__c = 'Opportunity', REN_Reason__c = REN_Constants.REN_REASON_MAN_REN));
            if(serviceContractList!=null && !serviceContractList.isEmpty()){
                for(sObject sc: serviceContractList){
                    if (CSM_AccessController.hasField('REN_Source__c', CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c')){
                        REN_Source__c source = new REN_Source__c(REN_Inheriting_Opportunity__c = opportunityList[0].Id, REN_Type__c = 'Service Contract', REN_Reason__c = REN_Constants.REN_REASON_MAN_REN); 
                        source.put(CSM_Util.nameSpacePrefix21 +'REN_Contributor_SC__c', sc.id);
                       	oppFieldSetForCRUD.add(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__c');
                        opportunityList[0].put(CSM_Util.nameSpacePrefix21+'REN_Append_Service_Contract__c',sc.id);
                        //existingOpportunity.put(CSM_Util.nameSpacePrefix21+'REN_Append_Service_Contract__c',sc.id);
                        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c')){
                            sc.put(CSM_Util.nameSpacePrefix21+'REN_Renewal_Opportunity__c',opportunityList[0].Id);
                        }
                        sourceList.add(source);
                        SCList.add(sc);
                    }
				}
				if(existingOpportunity.get(CSM_Util.nameSpacePrefix21+'REN_Append_Service_Contract__c') != null){
                       	oppFieldSetForCRUD.add(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__c');
                        opportunityList[0].put(CSM_Util.nameSpacePrefix21+'REN_Append_Service_Contract__c',existingOpportunity.get(CSM_Util.nameSpacePrefix21+'REN_Append_Service_Contract__c'));
				}
                REN_OpportunityDataAccess.updateOpportunitySObject(opportunityList, oppFieldSetForCRUD);

                REN_ServiceContractsDataAccess.updateServiceContracts(SCList,new List<String>{CSM_Util.nameSpacePrefix21 +'REN_Renewal_Opportunity__c'});          	
            }  
            REN_SourceDataAccess.saveSourceRecords(sourceList);
            this.createRelatedLists(new List<String>{opportunityList[0].Id});
            page = new PageReference('/' + opportunityList[0].Id);
        }
        catch (Exception ex)
        {
        	system.debug('\n\n~~~~Error : '+ ex);
            Database.rollback(spBeforeOpptCreate);
            this.renewOpportunityList[0].id = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
        return page;
    } 

    public PageReference cancel()
    {
        PageReference page = new PageReference('/' + this.existingOpportunity.Id);
        return page;
    }
    
    private List<REN_OpptLineWrapper> saveOpli(List<String> optyIdList)
    {
        List <REN_OpptLineWrapper> lstofAllOpptLinesW = new List <REN_OpptLineWrapper> ();
    	List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        for(REN_OpptLineWrapper olW: this.lstAllOpptLinesW)
        {
            OpportunityLineItem newOLI = olW.opLine.clone(false, true);
            newOLI.OpportunityId = optyIdList[0];
            if(newOLI.UnitPrice != null)
            {
            	newOLI.TotalPrice = null;
            }
            oliListToInsert.add(newOLI);
        }
        list<OpportunityLineItem> insertedList=REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(oliListToInsert);
        Map<Id, OpportunityLineItem> oppLineItemMap = new  Map<Id, OpportunityLineItem>(); 
        for(OpportunityLineItem oli:insertedList){
            if(insertedList!=null){
                renewalQualifiedOpptLines.put(oli.OpportunityID, oliListToInsert);
                oppLineItemMap.put(oli.Id,oli);
            }           
        }
        List<REN_Field_Mappings__c> lstOliToRrFldMappings = REN_OpportunityResolutionHelper.fetchFieldMapping(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.FLD_MAP_OPPT_LINE_TO_RR);
		Set<String> additionalFieldSet =new Set<String>{'OpportunityId', 'Product2.Name', 'Description', 'ServiceDate', 'REN_Source_Opportunity_Line_Item_Id__c', 'Product2Id', 'REN_Start_Date__c', 'REN_End_Date__c','Quantity', 'REN_Covered_Asset__c'};
		REN_Util.getFromAndToFldsToQuery(lstOliToRrFldMappings,additionalFieldSet,null);
	    List<OpportunityLineItem> renewedOppLineItemList = REN_OpportunityLineItemDataAccess.getOpptyLineItems(oppLineItemMap.keySet(), additionalFieldSet);
        if(renewedOppLineItemList!=null && !renewedOppLineItemList.isEmpty()){
            for(OpportunityLineItem oli :renewedOppLineItemList){
                REN_OpptLineWrapper oliWrapper = new REN_OpptLineWrapper();
                oliWrapper.opLine = oli;
                oliWrapper.sourceOpptId = oli.OpportunityId;
                oliWrapper.sourceOpptLnId = oli.REN_Source_Opportunity_Line_Item_Id__c;
                lstofAllOpptLinesW.add(oliWrapper);
			}
        }    
        return lstofAllOpptLinesW;
    }
      
    private void createRelatedLists(List<String> optyIdList)
    {
    	Map<String, String> mapOld2NewOpportunityIds = new Map<String, String>();
    	Set<String> renewIdsSet = new Set<String>();
    	renewIdsSet.add(this.existingOpportunity.Id);
        mapOld2NewOpportunityIds.put(String.valueOf(this.existingOpportunity.Id), String.valueOf(optyIdList[0]));
        REN_OpportunityResolutionHelper.createRelatedListRecords(renewIdsSet, mapOld2NewOpportunityIds, renewConfigurationList);
    }   
    
    private void populateMapValues(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, Map<String, String> pbEntryIdToProdName)
    {
        //Eswar Bala: 12/30 - Fixing looping issue
        List<OpportunityLineItem > oliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new Set<String>{this.existingOpportunity.Id});
        if(!oliList.isEmpty())
        {
            for(OpportunityLineItem oli: oliList)
            { 
                List<OpportunityLineItem> lstOpptLn = oldOppt2ExistingLines.get(oli.OpportunityId);
                if(lstOpptLn == null)
                {
                	lstOpptLn = new List<OpportunityLineItem>(); 
                }
                lstOpptLn.add(oli);
                oldOppt2ExistingLines.put(oli.OpportunityId, lstOpptLn);
                pbEntryIdToProdName.put(oli.PricebookEntryId, oli.Product2.Name);
            }
        }
    }
    
    private void populateOpliWrapperList(Map<String, List<OpportunityLineItem>> oldOppt2ExistingLines, Map<String, String> pbEntryIdToProdName)
    {
    	Map<String, OpportunityLineItem> allOpptLinesMap = REN_OpportunityResolutionTriggerHandler.createOpportunityLineItemsMap(oldOppt2ExistingLines, null, true);
        List <OpportunityLineItem> lstAllOpptLines = new List <OpportunityLineItem>();
    	if(allOpptLinesMap != null){
    		lstAllOpptLines = allOpptLinesMap.values();
    	}
        this.lstAllOpptLinesW = new list <REN_OpptLineWrapper>();
        if (!lstAllOpptLines.isEmpty())
        {
            for (Integer i = 0; i < lstAllOpptLines.size(); i++)
            {
            	OpportunityLineItem ol = lstAllOpptLines.get(i);
                REN_OpptLineWrapper olW = new REN_OpptLineWrapper();
                olW.opLine = ol;
                olW.customId = i;
                olW.opportunityProduct =pbEntryIdToProdName.get(ol.PricebookEntryId);
                this.lstAllOpptLinesW.add(olW);
            }
        }
    }
}