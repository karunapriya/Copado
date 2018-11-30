public with sharing class REN_MergeServiceContractsController {
	/* This controller is deprecated under US3293
	
	public Boolean hasRenewAccess {get; private set;}
	public Boolean hasServiceContractAccess {get; private set;}
	public List<SObject> serviceContractList{get;set;}
	public Boolean allowMerge {get; set;}
	public List<REN_MergeOppFieldWrapper> readOnlyFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableDiffFields{get;set;}
	public List<REN_MergeOppFieldWrapper> updateableSortedFields{get;set;}
	public String updateableFieldJSON{get;set;}
	public String selectedMasterId{get;set;}
	public String selectedValuesJson{get;set;}
	private List<String> serviceContractIdList;
	public string recordCurrencyCode{get;set;}
	
	public REN_MergeServiceContractsController() 
	{
		allowMerge = false;
		hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		hasServiceContractAccess = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
		if (hasRenewAccess && hasServiceContractAccess){
			init();
		} 

	}
		
	private SObject findMasterServiceContract(){
		SObject masterServiceContract;
		if (serviceContractList!=null){
			for(SObject serviceContract : this.serviceContractList){
				if(this.selectedMasterId!=null && this.selectedMasterId.equals((String)serviceContract.get('Id'))){
					masterServiceContract = serviceContract;
				}else{
					// VCP - ORG21 check
					if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED) && 
						CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO)){
						// VCP - ORG21 check
						serviceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED, true);
						// VCP - ORG21 check
						serviceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO, this.selectedMasterId);
					}
				}
			}
		}
		return masterServiceContract;
	}
	
	private void updateMasterServiceContractMergeValues(SObject masterServiceContract){
		selectedValuesJson=selectedValuesJson.replaceAll('\n|\r|\t', ' ');
		Map<String, Object> selectedValuesMap = (Map<String, Object>)JSON.deserializeUntyped(selectedValuesJson);
		if(masterServiceContract != null && selectedValuesMap != null && !selectedValuesMap.isEmpty()){
			Map<String, Schema.SobjectField> fields = CSM_AccessController.getFieldMap(REN_Constants.OBJ_SERVICE_CONTRACT);
			for(REN_MergeOppFieldWrapper wrapper : this.updateableFields){
				String updateField = wrapper.name;
				Schema.DisplayType fieldType = fields.get(wrapper.fieldKey).getDescribe().getType();
				String value = (String)selectedValuesMap.get(updateField);
				
				if(!String.isBlank(value)){
					if(fieldType.equals(Schema.DisplayType.Boolean)){
						masterServiceContract.put(updateField, Boolean.valueOf(value));
					}else if(fieldType.equals(Schema.DisplayType.Date)){
						if(String.isBlank(value)){
							masterServiceContract.put(updateField, null);
						}else{
							masterServiceContract.put(updateField, 
										Date.valueOf(CSM_Util.formatDatetimeString(value, REN_CONSTANTS.DB_DATE_FORMAT)));
						}
					}else if(fieldType.equals(Schema.DisplayType.Datetime)){
						if(String.isBlank(value)){
							masterServiceContract.put(updateField, null);
						}else{
							masterServiceContract.put(updateField, 
										Datetime.valueOf(CSM_Util.formatDatetimeString(value, REN_CONSTANTS.DB_DATETIME_FORMAT)));
						}
					}else if(fieldType.equals(Schema.DisplayType.Double)
					       || fieldType.equals(Schema.DisplayType.CURRENCY)
					       || fieldType.equals(Schema.DisplayType.Percent)){
						masterServiceContract.put(updateField, Double.valueOf(value==null || value==''?'0':value));
					}else if(fieldType.equals(Schema.DisplayType.Integer)){
						masterServiceContract.put(updateField, Integer.valueOf(value==null || value==''?'0':value));
					}else {
						masterServiceContract.put(updateField, value);
					}
				
				}
			}
			System.Debug('finalcheck1' + masterServiceContract);
			//US 512 Updating Date in merge SC
			updateEndDateInConsolidatedSC();
			REN_ServiceContractsDataAccess.upsertServiceContractList(this.servicecontractList);
			
		}
		
	}
	
	private void updateEndDateInConsolidatedSC(){
			Set<String> serviceContractIdSet=new Set<String>();
			Date startdate;
			Date endDate;
			Date desStartDate;
			Date desEndDate;
			for(SObject scId:servicecontractList){
				serviceContractIdSet.add(scId.Id);
			}
			List<SObject> serviceContractliList = REN_ServiceContractsDataAccess.getMergeContractLineItems(serviceContractIdSet);
			system.debug('serviceContractliList--0-->'+serviceContractliList);
			for(SObject serviceContract : servicecontractList){
			system.debug('IN');
				if(serviceContract.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED) == true){
					if(serviceContract.get('StartDate') != null){
						serviceContract.put('EndDate',System.today());
					}
				}
				else{
					if(serviceContract.get('StartDate') != null && serviceContract.get('EndDate') != null){
						//No need to update 
					}
					else{
						if(serviceContractliList != null && !serviceContractliList.isEmpty()){
							system.debug('serviceContractliList---->'+serviceContractliList);
							if(desStartDate==null){
								desStartDate = (Date)serviceContractliList[0].get(REN_Constants.OBJ_SCLI_STARTDATE);
							}
							if(desEndDate==null){
								desEndDate = (Date)serviceContractliList[0].get(REN_Constants.OBJ_SCLI_ENDDATE);
							}
							system.debug('desEndDate---->'+desEndDate);
							system.debug('desStartDate---->'+desStartDate);
							for(SObject serviceContractliListItem : serviceContractliList){
								system.debug('desEndDate--loop-->'+(Date)serviceContractliListItem.get(REN_Constants.OBJ_SCLI_STARTDATE));
								system.debug('desStartDate--loop-->'+(Date)serviceContractliListItem.get(REN_Constants.OBJ_SCLI_ENDDATE));
								if((Date)serviceContractliListItem.get(REN_Constants.OBJ_SCLI_STARTDATE) < desStartDate || desStartDate==null){
									desStartDate=(Date)serviceContractliListItem.get(REN_Constants.OBJ_SCLI_STARTDATE);
								}
								if((Date)serviceContractliListItem.get(REN_Constants.OBJ_SCLI_ENDDATE) > desEndDate || desEndDate==null){
									desEndDate=(Date)serviceContractliListItem.get(REN_Constants.OBJ_SCLI_ENDDATE);
								}
								
								system.debug('desEndDate-i--->'+desEndDate);
								system.debug('desStartDate--i-->'+desStartDate);
							}
							system.debug('desEndDate-o--->'+desEndDate);
							system.debug('desStartDate--0-->'+desStartDate);
							serviceContract.put('StartDate',desStartDate);
							serviceContract.put('EndDate',desEndDate);
						}
					}
				}
			}
		}
	
	private void updateNonMasterSLIs(){
		REN_Constants.CONTRACTLINEITEM_TRIGGER = false; 
		//System.Debug('scids'+serviceContractIdList[0]);
		//throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, null));
		Set<String> serviceContractIdSet = new Set<String>();
		for(SObject serviceContract : this.serviceContractList){
			if(this.selectedMasterId.equals((String)serviceContract.get('Id'))){
				
			}else{
				serviceContractIdSet.add((String)serviceContract.get('Id'));
			}
		}
		
		List<SObject> serviceContractliList = REN_ServiceContractsDataAccess.getMergeContractLineItems(serviceContractIdSet);
		//System.debug('Setsize' + serviceContractIdSet.size() + 'flag '+flag + '   ' + this.selectedMasterId);
		List<SObject> cloneServiceContractliList = new List<SObject>();
		Map<String, sObject> oldToNewCliMap = new Map<String, sObject>(serviceContractliList);
		for(SObject serviceContractli : serviceContractliList){
			SObject cloneserviceContractli = serviceContractli.clone(false,true);
			cloneserviceContractli.put('ServiceContractId',this.selectedMasterId);
			cloneServiceContractliList.add(cloneserviceContractli);
			oldToNewCliMap.put(serviceContractli.id, cloneserviceContractli);
		}
		REN_ServiceContractsDataAccess.insertContractLineItems(cloneServiceContractliList);
		createRRRecords(oldToNewCliMap);
		REN_ServiceContractsDataAccess.deleteContractLineItems(serviceContractliList);
	}
	private void createRRRecords(Map<String, sObject> oldToNewCliMap){
		
		if(oldToNewCliMap != null && !oldToNewCliMap.isEmpty()){
			List<REN_Renews_To__c> renewalRelationshipList = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithServiceContracts(oldToNewCliMap.keySet(), null);
			system.debug('\n~~~~renewalRelationshipList: ' + renewalRelationshipList);
			if(renewalRelationshipList != null && !renewalRelationshipList.isEmpty()){
				for(REN_Renews_To__c rr: renewalRelationshipList){
					if(rr.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM) != null){
						
					}
					system.debug(rr +'\nRR~~~~CLI: ' + oldToNewCliMap.get(''+ rr.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)));
					rr.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT,
						oldToNewCliMap.get(''+ rr.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM))
						.get(REN_Constants.OBJ_SCLI_SERVICECONTRACTID));
	
					rr.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM,
						oldToNewCliMap.get('' + rr.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM))
						.get(REN_Constants.FLD_ID));
				}
				REN_RenewRelationshipDataAccess.upsertRenewalRelationship(renewalRelationshipList);
			}
		}
		
	}
	public PageReference mergeServiceContracts(){
		PageReference pageRef;
		System.Savepoint sp = Database.setSavepoint();
		try{
			SObject masterServiceContract = findMasterServiceContract();

			updateMasterServiceContractMergeValues(masterServiceContract);
			//throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, null));
			updateNonMasterSLIs();
			pageRef = new PageReference('/' + this.selectedMasterId);
		}catch(Exception ex){
			Database.rollback(sp);
			this.allowMerge = false;
			pageRef = null;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return pageRef;
	}
	
	public PageReference cancel(){
		return new PageReference('/810');
	}
	
	private void init() {
		try{
			String serviceContractIds = ApexPages.currentPage().getParameters().get(REN_Constants.OBJ_SC_IDS);
			//System.Debug('serviceConIds' + serviceContractIds);
			if(String.isNotBlank(serviceContractIds)){
				serviceContractIdList = serviceContractIds.split('-');
				if(!serviceContractIdList.isEmpty()){
					this.serviceContractList = REN_ServiceContractsDataAccess.getServiceContractList(serviceContractIdList);
					validateConsolidatedServiceContracts();
					this.readOnlyFields = new List<REN_MergeOppFieldWrapper>();
					this.updateableFields = new List<REN_MergeOppFieldWrapper>();
					REN_ServiceContractsDataAccess.getAccessibleFields(this.readOnlyFields, this.updateableFields);
					this.readOnlyFields.sort();
					this.updateableFields.sort();
					setFieldsWithDifference(updateableFields);
					//Below Code is added for US454
					SObject thisServiceContract = this.serviceContractList[0];
				    recordCurrencyCode = CSM_Util.getRecordLevelCurrency(thisServiceContract,false);
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
			for(SObject serviceContract : this.serviceContractList){
				if(count == 0){
					Obj = serviceContract.get(field.name);
				}
				else{
					if(Obj == serviceContract.get(field.name)){
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

	private void validateConsolidatedServiceContracts(){
		this.allowMerge = true;
		Set<Id> pricebookIds = new Set<Id>();
		// VCP - ORG21 check
		Boolean hasConsolidatedFld = CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED);
		Set<string> CurrencyCodes = new Set<string>();
		for(SObject srvContract : this.serviceContractList) {
			if (hasConsolidatedFld) {
				if(String.isNotBlank((String)srvContract.get(REN_Constants.OBJ_SC_PRICEBOOK2_ID)) && pricebookIds.isEmpty()) {
					pricebookIds.add((Id)srvContract.get(REN_Constants.OBJ_SC_PRICEBOOK2_ID));
				}
				// VCP - ORG21 check
				if ((Boolean)srvContract.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED)) {
					this.allowMerge = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(
												system.label.REN_LBL_CONSOIDATED_SC_MSG, new String[]{(String)srvContract.get(REN_Constants.OBJ_SC_NAME)})));
					break;
				} else if(String.isNotBlank((String)srvContract.get(REN_Constants.OBJ_SC_PRICEBOOK2_ID)) && 
					pricebookIds.add((String)srvContract.get(REN_Constants.OBJ_SC_PRICEBOOK2_ID))){
					this.allowMerge = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.REN_LBL_PB_ERROR_MSG));
					break;
				}
				else if(UserInfo.isMultiCurrencyOrganization())	{
					system.debug('$$ IN MULTI CURRENCY SC');
					if(String.isNotBlank((String)srvContract.get(REN_Constants.REN_CURRENCY_ISO_CODE)) && CurrencyCodes.isEmpty()){
						CurrencyCodes.add((String)srvContract.get(REN_Constants.REN_CURRENCY_ISO_CODE));
					}
					if(String.isNotBlank((String)srvContract.get(REN_Constants.REN_CURRENCY_ISO_CODE)) && CurrencyCodes.add((String)srvContract.get(REN_Constants.REN_CURRENCY_ISO_CODE)))	{
						this.allowMerge = false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.REN_LBL_SC_CURRENCY_ERROR_MSG));
						break;
					}
				}

			} else {
				this.allowMerge = false;
				if (Test.isRunningTest()) {
					this.allowMerge = true;
				}
			}
		}
	} */
}