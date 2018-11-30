public with sharing class REN_MergeOpportunityController {
/*
	// This controller is Deprecated under US3293
	
	
	public Boolean hasRenewAccess {get; private set;}
	public List<SObject> OpportunityList{get;set;}
	public Boolean allowMerge {get; set;}
	public List<REN_MergeOppFieldWrapper> readOnlyFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableDiffFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableSortedFields{get;set;}
	public String updateableFieldJSON{get;set;}
	public String selectedMasterId{get;set;}
	public String selectedValuesJson{get;set;}
	private List<String> opportunityIdList;
	public string recordCurrencyCode{get;set;}
	
	public REN_MergeOpportunityController() 
	{
		allowMerge = false;
		hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled; 
		if (hasRenewAccess){
			init();
		} 

	}
		
	private SObject findMasterOpportunity(){
		SObject masterOpportunity;
		if (OpportunityList!=null){
			for(SObject oppObj : this.OpportunityList){
				if(this.selectedMasterId!=null && this.selectedMasterId.equals((String)oppObj.get('Id'))){
					masterOpportunity = oppObj;
				}else{
					oppObj.put(CSM_Util.getNamespace() + REN_Constants.OBJ_OPP_CONSOLIDATED, true);
				}
			}
		}
		return masterOpportunity;
	}
	
	private void updateMasterOpportunityMergeValues(SObject masterOpportunity){
		selectedValuesJson=selectedValuesJson.replaceAll('\n|\r|\t', ' ');
		Map<String, Object> selectedValuesMap = (Map<String, Object>)JSON.deserializeUntyped(selectedValuesJson);
		if(masterOpportunity != null && selectedValuesMap != null && !selectedValuesMap.isEmpty()){
			Map<String, Schema.SobjectField> fields = CSM_AccessController.getFieldMap(REN_Constants.OBJ_OPPORTUNITY);
			for(REN_MergeOppFieldWrapper wrapper : this.updateableFields){
				String updateField = wrapper.name;
				Schema.DisplayType fieldType = fields.get(wrapper.fieldKey).getDescribe().getType();
				String value = (String)selectedValuesMap.get(updateField);
				
				if(!String.isBlank(value)){
					if(fieldType.equals(Schema.DisplayType.Boolean)){
						masterOpportunity.put(updateField, Boolean.valueOf(value));
					}else if(fieldType.equals(Schema.DisplayType.Date)){
						if(String.isBlank(value)){
							masterOpportunity.put(updateField, null);
						}else{
							masterOpportunity.put(updateField, 
										Date.valueOf(CSM_Util.formatDatetimeString(value, REN_CONSTANTS.DB_DATE_FORMAT)));
						}
					}else if(fieldType.equals(Schema.DisplayType.Datetime)){
						if(String.isBlank(value)){
							masterOpportunity.put(updateField, null);
						}else{
							masterOpportunity.put(updateField, 
										Datetime.valueOf(CSM_Util.formatDatetimeString(value, REN_CONSTANTS.DB_DATETIME_FORMAT)));
						}
					}else if(fieldType.equals(Schema.DisplayType.Double)
					       || fieldType.equals(Schema.DisplayType.CURRENCY)
					       || fieldType.equals(Schema.DisplayType.Percent)){
						masterOpportunity.put(updateField, Double.valueOf(value==null || value==''?'0':value));
					}else if(fieldType.equals(Schema.DisplayType.Integer)){
						masterOpportunity.put(updateField, Integer.valueOf(value==null || value==''?'0':value));
					}else {
						masterOpportunity.put(updateField, value);
					}
				
				}
			}
			System.Debug('finalcheck1' + masterOpportunity);
			CSM_OpportunityDataAccess.upsertOpportunityList(this.OpportunityList);
		}
		
	}
	
	private void updateNonMasterOplis(){
		Set<String> oppIdSet = new Set<String>(this.opportunityIdList);
		oppIdSet.remove(this.selectedMasterId);
		List<OpportunityLineItem> opliList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsByOppId(oppIdSet);
													
		List<OpportunityLineItem> clonedOpliList = new List<OpportunityLineItem>();
		for(OpportunityLineItem opli : opliList){
			OpportunityLineItem clonedOpli = opli.clone(false, true);
			clonedOpli.OpportunityId = this.selectedMasterId;
			if(clonedOpli.UnitPrice != null) clonedOpli.TotalPrice = null;
			clonedOpliList.add(clonedOpli);
		}
		system.debug('\n\n\n clonedOpliList : ' + clonedOpliList);
		
		REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(clonedOpliList);
		REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = true;
		//List<Opportunity> OpptyList = new List <Opportunity>();
		Opportunity opp = new Opportunity();
		opp.id = this.selectedMasterId;
		//OpptyList.add(opp.id);
		//Eswar Bala
		Boolean optLnDeleted = false;
		Map<String,String> mapofoldtonewoli = new Map<String,string>();
		if(clonedOpliList != null && !clonedOpliList.isEmpty() && opliList !=null && !opliList.isEmpty())	{
			for(Integer i = 0; i< clonedOpliList.size(); i++){
				if(opliList[i].REN_Is_CLM_Renewal__c == true)	{
				
					mapofoldtonewoli.put(opliList[i].id, clonedOpliList[i].id);
				}
			}
			List<Opportunity> lstLosingOppts = new List<Opportunity>();
			lstLosingOppts.add(opp);
			REN_OpportunityLineItemDataAccess.deleteOpportunityLineItems(opliList);
			optLnDeleted = true;
			REN_Util.updateRenewalRelationships(lstLosingOppts,mapofoldtonewoli);			
		}
		if(optLnDeleted == false)
		{
			REN_OpportunityLineItemDataAccess.deleteOpportunityLineItems(opliList);
		}
		
		
	}
		
	public PageReference mergeOpportunities(){
		REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = false;
		REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = false;
		CSM_Constants.OPPORTUNITY_TRIGGER = false;
		PageReference pageRef;
		System.Savepoint sp = Database.setSavepoint();
		try{
			List<REN_Source__c> sourceList = new List<REN_Source__c>();
			SObject masterOpportunity = findMasterOpportunity();

			updateMasterOpportunityMergeValues(masterOpportunity);
			//throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, null));
			//updateNonMasterSLIs();
			updateNonMasterOplis();
			
			String nonMasterOppId;
			for(sObject opp:OpportunityList){
				if(opp.get(CSM_Util.getNamespace()+REN_Constants.OBJ_OPP_CONSOLIDATED)==true){
					nonMasterOppId = opp.id;
					break;
				}
			}
			sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = masterOpportunity.id, REN_Contributor__c = nonMasterOppId, REN_Type__c = 'Opportunity', REN_Reason__c = REN_Constants.REN_REASON_MERGE));
			REN_SourceDataAccess.saveSourceRecords(sourceList);

			pageRef = new PageReference('/' + this.selectedMasterId);
			if(!opportunityIdList.isEmpty()){
				Set<ID> renewedOppIdSet = new Set<ID>();
				for(String s: opportunityIdList){
					renewedOppIdSet.add((ID)s);
				}
				REN_OpportunityMetricsBusiness.resetMetricsFields(renewedOppIdSet);
			}			
		}catch(Exception ex){
			Database.rollback(sp);
			this.allowMerge = false;
			pageRef = null;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return pageRef;
	}
	
	public PageReference cancel(){
		return new PageReference('/006');
	}
	
	private void init() {
		try{
			String opportunityIds = ApexPages.currentPage().getParameters().get('opptIds');
			//System.Debug('serviceConIds' + opportunityIds);
			if(String.isNotBlank(opportunityIds)){
				opportunityIdList = opportunityIds.split('-');
				if(!opportunityIdList.isEmpty()){
					this.OpportunityList = REN_OpportunityDataAccess.getOpportunityDetailById(opportunityIdList);
					system.debug('OpportunityList-------->'+OpportunityList);
					validateConsolidatedOpportunity();
					this.readOnlyFields = new List<REN_MergeOppFieldWrapper>();
					this.updateableFields = new List<REN_MergeOppFieldWrapper>();
					REN_OpportunityDataAccess.getAccessibleFields(this.readOnlyFields, this.updateableFields);
					system.debug('readOnlyFields-------->'+readOnlyFields);
					system.debug('readOnlyFields-------->'+readOnlyFields);
					this.readOnlyFields.sort();
					this.updateableFields.sort();
					setFieldsWithDifference(updateableFields);
					//Below Code is added for US454
					SObject thisOpportunity = this.OpportunityList[0];
				    recordCurrencyCode = CSM_Util.getRecordLevelCurrency(thisOpportunity,false);
				}
			}
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
	}
	
	private void setFieldsWithDifference(List<REN_MergeOppFieldWrapper> updateableFields){
		this.updateableDiffFields = new List<REN_MergeOppFieldWrapper>();
		this.updateableSortedFields = updateableFields.clone();				
				
		Integer diffCount = 0;
		Integer sortCount = 0;
		for( REN_MergeOppFieldWrapper field : this.updateableFields){
			Object Obj = null;
			Integer count = 0;
			for(SObject oppObj : this.OpportunityList){
				if(count == 0){
					Obj = oppObj.get(field.name);
				}
				else{
					if(Obj == oppObj.get(field.name)){
						field.IsEqual = true;
					}
					else{
						field.IsEqual = false;							
					}
				}
				count = count + 1;
			}
					
			if(field.IsEqual == true){
				//this.updateableDiffFields.remove(diffCount);
				//diffCount = diffCount - 1;						
			}else{
				this.updateableSortedFields.remove(sortCount);
				this.updateableSortedFields.add(0,field);
				diffCount = diffCount + 1;
			}
			//diffCount = diffCount + 1;
			sortCount = sortCount + 1;
		}
		this.updateableFields.clear();
		this.updateableFields = this.updateableSortedFields;
		
		for(Integer i=0;i<diffCount;i++){
			//System.Debug('loopcheck - ' + i);
			this.updateableDiffFields.add(this.updateableFields.get(i));
		}
		
		this.updateableFieldJSON = JSON.serialize(this.updateableDiffFields);
	}

	private void validateConsolidatedOpportunity(){
		this.allowMerge = true;
		Set<Id> pricebookIds = new Set<Id>();
		// VCP - ORG21 check
		Boolean hasConsolidatedFld = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_OPP_CONSOLIDATED);
		if(hasConsolidatedFld)
		{
			Set<string> CurrencyCodes = new Set<string>();
			for(SObject oppObj : this.OpportunityList)
			{
				if(String.isNotBlank((String)oppObj.get(REN_Constants.OBJ_OPP_PRICEBOOK_ID)) && pricebookIds.isEmpty()) {
					pricebookIds.add((Id)oppObj.get(REN_Constants.OBJ_OPP_PRICEBOOK_ID));
				}
				// VCP - ORG21 check
				if ((Boolean)oppObj.get(CSM_Util.getNamespace() + REN_Constants.OBJ_OPP_CONSOLIDATED)) {
					this.allowMerge = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(
												system.label.REN_LBL_CONSOIDATED_MSG, new String[]{(String)oppObj.get(REN_Constants.OBJ_OPPORTUNITY)})));
					break;
				} else if(String.isNotBlank((String)oppObj.get(REN_Constants.OBJ_OPP_PRICEBOOK_ID)) && 
					pricebookIds.add((String)oppObj.get(REN_Constants.OBJ_OPP_PRICEBOOK_ID))){
					this.allowMerge = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.REN_LBL_PB_ERROR_MSG));
					break;
				}
				else if(UserInfo.isMultiCurrencyOrganization())	{
					system.debug('$$ IN MULTI CURRENCY SC');
					if(String.isNotBlank((String)oppObj.get(REN_Constants.REN_CURRENCY_ISO_CODE)) && CurrencyCodes.isEmpty()){
						CurrencyCodes.add((String)oppObj.get(REN_Constants.REN_CURRENCY_ISO_CODE));
					}
					if(String.isNotBlank((String)oppObj.get(REN_Constants.REN_CURRENCY_ISO_CODE)) && CurrencyCodes.add((String)oppObj.get(REN_Constants.REN_CURRENCY_ISO_CODE)))	{
						this.allowMerge = false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.REN_LBL_SC_CURRENCY_ERROR_MSG));
						break;
					}
				}
			}
		}
		else
		{
			this.allowMerge = false;
			if (Test.isRunningTest()) {
				this.allowMerge = true;
			}
		}
		
	} */
}