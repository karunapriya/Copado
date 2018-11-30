public with sharing class REN_RRSimplifiedTriggerHelper {

	/** @return List<Opportunity> where Opportunity will have only Maseter OLI and / or max one RLI 
	*/
	public static void simplifiedOpportunity(Set<ID> opportunityIdSet){
		
		List<Opportunity> impactedOpportunityList =  REN_RRSimplifiedTriggerHelper.getOpportuntyDetails(opportunityIdSet);
		simplifiedOpportunity(impactedOpportunityList);
	}
	
	public static void simplifiedOpportunity(List<Opportunity> impactedOpportunityList){
		
		map<ID,OpportunityLineItem> mapOfOppToOLI=new map<ID,OpportunityLineItem>();
		if(SS_Constants.isSimplifiedDataModelEnabled){
			mapOfOppToOLI = manageMasterOli(impactedOpportunityList);
		}		
		List<Opportunity> changedExpDateOppList = new List<Opportunity>();
		REN_OpportunityMetricsBusiness.resetMetricsFieldsOnChangedOpportunity(impactedOpportunityList, mapOfOppToOLI, changedExpDateOppList);
		REN_OpportunityDataAccess.UpdateExpQuarterYear(changedExpDateOppList, null);	
		List<String> opportunityFieldList = new List<String>{'REN_Earliest_Expiration_Date__c','REN_Renewal_Target__c','REN_Renewal_Target_Resolved__c','REN_Renewal_Target_Lost__c','REN_Renewal_Target_Won__c','REN_AddsAmount__c','REN_EQ__c','REN_FY__c'};
		REN_OpportunityDataAccess.updateOpportunitySObject(impactedOpportunityList, opportunityFieldList);
	}
	
	/** @This method is used for RLI trigger to bypass metrics calculation for Data Service user
	*/
	public static List<Opportunity> rliAfterTriggerEvent(Set<ID> opportunityIdSet){
		CSM_TriggerEnablement__c triggerEnablement = CSM_TriggerEnablement__c.getOrgDefaults();
		Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
		List<Opportunity> impactedOpportunityList = new List<Opportunity>();
		List<String> opportunityFieldList;
		if(opportunityIdSet != null ){
			opportunityIdSet.remove(null);
		}
		if(!opportunityIdSet.isEmpty() ){
			List<String> fieldListForCrudFls = new List<String>{'REN_Renewal_Target__c','REN_Earliest_Expiration_Date__c'};		
			List<Opportunity> changedExpDateOppList = new List<Opportunity>();
			impactedOpportunityList = REN_OpportunityMetricsBusiness.setRliMetricsFields(opportunityIdSet, changedExpDateOppList, fieldListForCrudFls, false);
			if(!isDataServicesUser){
				if(SS_Constants.isSimplifiedDataModelEnabled){
					if(impactedOpportunityList != null && !impactedOpportunityList.isEmpty()){
						setUnitPriceOnMasterOli(impactedOpportunityList);
					}
				}
				REN_OpportunityDataAccess.UpdateExpQuarterYear(changedExpDateOppList, null);	
				opportunityFieldList = new List<String>{'REN_Earliest_Expiration_Date__c','REN_Renewal_Target__c','REN_EQ__c','REN_FY__c','REN_Is_Sync_Pending__c'};
				REN_OpportunityDataAccess.updateOpportunitySObject(impactedOpportunityList, opportunityFieldList);
			}else if(triggerEnablement.REN_Bypass_Metrics_Field_Calculations__c == false){
				
				impactedOpportunityList = REN_OpportunityDataAccess.getOpptyWithMasterProduct(opportunityIdSet);
				List<Opportunity> opportunityListToCompare = REN_OpportunityDataAccess.getOpportunityListById(opportunityIdSet);
				Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(opportunityListToCompare);
				Opportunity opp;
				for(Opportunity oppObj : impactedOpportunityList){
					opp = new Opportunity();
					if(opportunityMap.containsKey(oppObj.id)) {
						opp = opportunityMap.get(oppObj.id);
					}
					system.debug('Trigger.isInsert::>'+Trigger.isInsert);
					oppObj.REN_Is_Sync_Pending__c = opp.get('SyncedQuoteId') != null && Trigger.isInsert ? true : false;
					oppObj.REN_Renewal_Metrics_Status__c	 = 'Not Calculated';
					oppObj.REN_Metrics_Calculation_Date__c 	 = System.now();
				}
				REN_OpportunityDataAccess.updateOpportunitySObject(impactedOpportunityList, opportunityFieldList);
				if(SS_Constants.isSimplifiedDataModelEnabled){
					REN_RRSimplifiedTriggerHelper.manageMasterOli(impactedOpportunityList);
				} 
				scheduleAsyncBatches(opportunityIdSet, Trigger.isInsert);
			}
		}
		return impactedOpportunityList;
	}
	
	public static void setUnitPriceOnMasterOli(List<Opportunity> impactedOpportunityList){
		if(SS_Constants.isSimplifiedDataModelEnabled){
 			list<OpportunityLineItem> oliToUpdate =new list<OpportunityLineItem>();
			map<ID,OpportunityLineItem> mapOfOppToOLI=new map<ID,OpportunityLineItem>();
			if(impactedOpportunityList != null && !impactedOpportunityList.isEmpty()){
				mapOfOppToOLI = REN_RRSimplifiedTriggerHelper.manageMasterOli(impactedOpportunityList);
				for(Opportunity opp: impactedOpportunityList){
					if(mapOfOppToOLI.get(opp.id) != null  && mapOfOppToOLI.get(opp.id).REN_Is_CLM_Renewal__c == true){
						mapOfOppToOLI.get(opp.id).UnitPrice = Opp.REN_Renewal_Target__c;
						oliToUpdate.add(mapOfOppToOLI.get(Opp.id));
					}
					if(opp.REN_Is_CLM_Renewal__c != true){
	    				opp.REN_Renewal_Target__c = 0;
	    			}
	    		}
			}
    		if(oliToUpdate != null && !oliToUpdate.isEmpty()){
        		REN_OpportunityLineItemDataAccess.updateOpportunityLineItem(oliToUpdate);
    		}
		}
	}
	
	/** @return Map<ID, OpportunityLineItem> where KEY= Opportunity ID & Value = Master OLI 
	*/
	public static Map<ID, OpportunityLineItem> manageMasterOli(List<Opportunity> opportunityList){
		List<OpportunityLineItem> newMasterOliList = new List<OpportunityLineItem>();
		List<OpportunityLineItem> deleteMasterOliList = new List<OpportunityLineItem>();
		Map<Id,OpportunityLineItem> mapOfOppToOLI = new Map<Id,OpportunityLineItem>();
		
		List<Opportunity> oppToQueryPBE = new List<Opportunity>();
		for(Opportunity opp: opportunityList){
			if(opp.PriceBook2Id != null){
				oppToQueryPBE.add(opp);
			}else{
				if(!opp.Renew_To__r.isEmpty()){
					throw new InvalidDataException(System.Label.REN_OPPORTUNITY_MISSING_PB);
				}
			}
		}
		SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
		Map<Id,PriceBookEntry> mapofOppToPBE;
		if(productIdSetting.Renewal_Amount_Product_Id__c!=null){
			mapofOppToPBE = REN_PricebookDataAccess.getOppToPbEntry(oppToQueryPBE,productIdSetting.Renewal_Amount_Product_Id__c);
		}else{
			throw new InvalidDataException(System.Label.REN_MISSING_RENEWAL_AMOUNT_ID);
		}
		for(Opportunity opp: opportunityList){
			
			if(opp.OpportunityLineItems.isEmpty() && !opp.Renew_To__r.isEmpty()){
				OpportunityLineItem newMasterOli = new OpportunityLineItem();
				newMasterOli.OpportunityId = opp.Id;
				newMasterOli.Quantity = 1;
				newMasterOli.REN_Is_CLM_Renewal__c = true;
				newMasterOli.UnitPrice = 0;
				if(mapofOppToPBE.get(opp.Id)!= null){
					newMasterOli.PricebookEntryId = mapofOppToPBE.get(opp.Id).Id;
					//newMasterOli.UnitPrice = mapofOppToPBE.get(opp.Id).UnitPrice;
				}else{
					System.debug(opp + '\nError: Pricebook mismatch.');
                    throw new InvalidDataException(String.format(Label.REN_ERR_PB_ENTRY_MISSING, new String[]{productIdSetting.Renewal_Amount_Product_Id__c, opp.PriceBook2Id}));
				}
				newMasterOli.REN_Is_End_Date_Modified__c = true;
				mapOfOppToOLI.put(opp.Id, newMasterOli);
				newMasterOliList.add(newMasterOli);
			}else if(!opp.OpportunityLineItems.isEmpty() && opp.Renew_To__r.isEmpty()){
				//mapOfOppToOLI.put(opp.Id, null);
				deleteMasterOliList.add(opp.OpportunityLineItems[0]);
			}else if(!opp.OpportunityLineItems.isEmpty()){
				mapOfOppToOLI.put(opp.Id, opp.OpportunityLineItems[0]);
			}
			
		}
		system.debug('Opportunity Line Item size = '+newMasterOliList.size());
		if(newMasterOliList.size()>0){
			//REN_OpportunityLineItemRenewalHandler.checkForDuplicateMasterOLI(newMasterOliList);
			REN_OpportunityLineItemDataAccess.insertOpportunityLineItem(newMasterOliList);
		}
		if(deleteMasterOliList.size()>0){
			REN_OpportunityLineItemDataAccess.deleteOpportunityLineItems(deleteMasterOliList);
		}
		
		return mapOfOppToOLI;
	}
	
	
	/** @return List<Opportunity> where Opportunity will have only Maseter OLI and / or max one RLI 
	*/
	public static List<Opportunity> getOpportuntyDetails(Set<ID> opportunityIdSet){
		List<Opportunity> oppListToUpdate = REN_OpportunityDataAccess.getOpptyWithMasterProduct(opportunityIdSet);
		return oppListToUpdate;
	}
	public static void validateSyncQuoteOnOpportunity(Map<ID, REN_Renews_To__c> oldRecordsMap,Map<ID, List<REN_Renews_To__c>> oppId2rrMap){
		Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);//US3380
		if(!isDataServicesUser && oppId2rrMap!=null && !oppId2rrMap.isEmpty()){
			List<Opportunity> oppListWithSyncQuote = REN_OpportunityDataAccess.getOpportunitySyncQuoteEnabled(oppId2rrMap.keySet());
			if(!oppListWithSyncQuote.isEmpty()){
				REN_Renews_To__c oldRLI;
				String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
				boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
				for(Opportunity opp: oppListWithSyncQuote){// This for loop is on Opportunity having sync quote enabled
					for(REN_Renews_To__c newRLI :(List<REN_Renews_To__c>)(oppId2rrMap.get(opp.id))){
						if(oldRecordsMap == null){
							newRLI.addError(String.format(Label.REN_MSG_OPP_HAS_QUOTE_IN_RR_EDIT_TRIGGER, new String[]{opp.name, opp.id}));
						}
						else{
							oldRLI = oldRecordsMap.get(newRLI.id); // Getting old RLI record for comparison
							if(oldRLI != null) { 
								if(oldRLI.REN_Previous_Price__c != newRLI.REN_Previous_Price__c || oldRLI.REN_Renewal_Target_Multiplier__c != newRLI.REN_Renewal_Target_Multiplier__c || 
										(isSolutionExtnInstalled && (oldRLI.get(solnExtnNamespace + 'Previous_Local_Currency_Amount__c') != newRLI.get(solnExtnNamespace + 'Previous_Local_Currency_Amount__c') || oldRLI.get(solnExtnNamespace + 'Previous_Local_Currency_Code__c') != newRLI.get(solnExtnNamespace + 'Previous_Local_Currency_Code__c')))){
									newRLI.addError(String.format(Label.REN_MSG_OPP_HAS_QUOTE_IN_RR_EDIT_TRIGGER, new String[]{opp.name, opp.id}));
								}	
							}
						}
					}
				}
			}
		}
	}
	
	
	/**This method set RLI status ,RLI matrix calculations as a part of trigger refactoring **/
	public static void processRliRecords(List<sObject> newRecords) {
		Schema.DescribeFieldResult F = REN_Renews_To__c.REN_Renewal_Status__c.getDescribe();
		List <Schema.PicklistEntry> pickVals = F.getPicklistValues();
		boolean isDefaultStatusDefined = false;
		
		Map<ID, List<REN_Renews_To__c>> oppId2rrMap = new Map<ID, List<REN_Renews_To__c>>();
		List<REN_Renews_To__c> rliList=new List<REN_Renews_To__c>();
		boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn + 'Local_Renewal_Target__c');
		
		REN_RenewLineItemsWrapper rliParamsWrapper=new REN_RenewLineItemsWrapper();
		
		for (Schema.PicklistEntry av: pickVals) {
			if (av.isDefaultValue()) {
				isDefaultStatusDefined = true;
				break;
			}
		}
		for(REN_Renews_To__c rli : (List<REN_Renews_To__c>)newRecords) {
			/***set RR stage **/
			if(String.isBlank(rli.REN_Renewal_Status__c) && !isDefaultStatusDefined){
				rli.REN_Renewal_Status__c = 'Open';
			}	
			rli.name = null;
			/**set Renewal Target and populate Original line item Id**/
			if(!REN_RRSimplifiedTriggerHandler.isMaualOppGeneration) {
				resetRenewalFields(rli, 'insert');
			}
			/**validate sync quote on opportunity**/
			if(rli.REN_Renews_To__c != null){
				List<REN_Renews_To__c> rrList;
				if(oppId2rrMap.containsKey(rli.REN_Renews_To__c)) {
					rrList = oppId2rrMap.get(rli.REN_Renews_To__c);
				} else {
					rrList = new List<REN_Renews_To__c>();
				}
				rrList.add(rli);
				oppId2rrMap.put(rli.REN_Renews_To__c, rrList);
			}
			REN_Renews_To__c rliObj = rli;
			/**update RLI Previous price and reneal target calculations**/
			system.debug('**rliParamsWrapper 1::'+rliParamsWrapper);
			if(UserInfo.isMultiCurrencyOrganization() && isSolutionExtnInstalled) {
				REN_RRSimplifiedTriggerHelper.updateRLIPreviousPrice(rliObj ,rliParamsWrapper);	
			}
		}
		REN_RRSimplifiedTriggerHelper.validateSyncQuoteOnOpportunity(null,oppId2rrMap);
	}
	
	public static void updateRLIPreviousPrice(REN_Renews_To__c rliObject ,REN_RenewLineItemsWrapper rliParams)
	{
		if(!String.isEmpty(rliParams.dateForAcm) && rliParams.dateForAcm != 'None') {
			//Modified for DE2952
			Schema.DisplayType fieldDataType = rliParams.fieldMap.get(rliParams.dateForAcm).getDescribe().getType();
		
			if(rliObject.get(rliParams.dateForAcm) != null ) {
				if(fieldDataType == Schema.DisplayType.DateTime ) {
					DATETIME dateTimeField = (DATETIME)rliObject.get(rliParams.dateForAcm);
					rliParams.rliDate = dateTimeField.Date();
				}else{
					rliParams.rliDate = (Date)rliObject.get(rliParams.dateForAcm);
				}	
			}
		}
		rliParams.price = (double)rliObject.get(rliParams.solnExtnNamespace+'Previous_Local_Currency_Amount__c');
		rliParams.fromCurrencyCode = (String)rliObject.get(rliParams.solnExtnNamespace+'Previous_Local_Currency_Code__c');
		
		if(rliParams.price != null && String.isNotBlank(rliParams.fromCurrencyCode)) {
			rliParams.toCurrency = (String)rliObject.get('CurrencyIsoCode');
			rliParams.convertedPrice = REN_CurrencyExchangeRateDataAccess.acmCurrencyConversion(rliParams.price, rliParams.fromCurrencyCode, rliParams.toCurrency, rliParams.rliDate);
			rliObject.REN_Previous_Price__c = rliParams.convertedPrice;
		}
		resetRenewalFields(rliObject, 'update');
		
	}
	public with sharing class REN_RenewLineItemsWrapper {
		public double price {get; set;}
		public String fromCurrencyCode {get;set;}
		public double convertedPrice {get;set;}
		public Date rliDate {get;set;}
		public String toCurrency {get;set;}
		public String solnExtnNamespace {get;set;}
		public String dateForAcm {get;set;}
		public Map<String,Schema.SObjectField> fieldMap {get;set;}
		
		public REN_RenewLineItemsWrapper(){
			List<REN_Value_Mapping__c>  valueMappingLst = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RLI_DATE_MAP);
			if(!valueMappingLst.isEmpty()){
				dateForAcm = valueMappingLst[0].REN_Value__c;
			}
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType leadSchema = schemaMap.get(CSM_Util.getNamespace()+REN_Constants.OBJ_RENEW_LINE_ITEM);
			Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
			
			this.price= 0;
			this.fromCurrencyCode= '';
			this.convertedPrice = 0;
			this.rliDate=null;
			this.solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
			this.dateForAcm = dateForAcm;
			this.fieldMap = fieldMap;
		}
	}
	
	public static void resetRenewalFields(REN_Renews_To__c rli, String triggerEvent){
		if(triggerEvent.equalsIgnoreCase('insert')){
			//rli.REN_Original_Line_Item_ID__c = rli.REN_Renewal_Product_Line_Id__c;
			rli.REN_Renewal_Target_Multiplier__c = rli.REN_Renewal_Target_Multiplier__c == null ? 1 : rli.REN_Renewal_Target_Multiplier__c;
		}
		if(rli.REN_Previous_Price__c != null && rli.REN_Renewal_Target_Multiplier__c != null){
			rli.REN_Renewal_Target__c = rli.REN_Previous_Price__c * rli.REN_Renewal_Target_Multiplier__c;
		}else{
			rli.REN_Renewal_Target__c = 0;
		}
	}	
	
	//Process RLI for update
	public static void processRliBeforeUpdate(Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
		boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn + 'Local_Renewal_Target__c');
		
		//parameters for sol ext method call
		SS_TriggerCollectionParameters.RLITriggerParams rliParamsSolExt = new SS_TriggerCollectionParameters.RLITriggerParams();
		Map<ID, List<REN_Renews_To__c>> oppId2rrMap = new Map<ID, List<REN_Renews_To__c>>();
		
		if(hasRenewAccess == true){
			String endDateField = CSM_Util.getNameSpace() + 'REN_Is_End_Date_Modified__c';
			String comparableFieldName = CSM_Util.getNameSpace() + REN_Constants.OBJ_REN_RENEWS_TO_END_DATE;
			//rliList for updateRLIPreviousPrice
			List<REN_Renews_To__c> rliList=new List<REN_Renews_To__c>();
			
			//initializing parameters for calling solution extention method
			rliParamsSolExt.impactedOppIdSet = new Set<Id>();
			rliParamsSolExt.newRecordsMap = (Map<Id, REN_Renews_To__c>)newRecordsMap;
			rliParamsSolExt.oldRecordsMap = (Map<Id, REN_Renews_To__c>)oldRecordsMap;
			
			REN_RRSimplifiedTriggerHelper.REN_RenewLineItemsWrapper rliParamsWrapper=new REN_RRSimplifiedTriggerHelper.REN_RenewLineItemsWrapper();
			
			//Main For-loop starts
			for(REN_Renews_To__c newRec: (List<REN_Renews_To__c>)newRecordsMap.values()){
				if(oldRecordsMap.get(newRec.id).get(comparableFieldName) != newRec.get(comparableFieldName)){
					newRec.put(endDateField, true);
				}
				
				REN_RRSimplifiedTriggerHelper.resetRenewalFields(newRec, 'update');
				
				rliParamsSolExt.impactedOppIdSet.add(newRec.REN_Renews_To__c);
				REN_Renews_To__c oldRec = (REN_Renews_To__c)oldRecordsMap.get(newRec.id);
				rliParamsSolExt.impactedOppIdSet.add(oldRec.REN_Renews_To__c);	
				
				REN_Renews_To__c rliObj = newRec;
				if(UserInfo.isMultiCurrencyOrganization() && isSolutionExtnInstalled) {
					REN_RRSimplifiedTriggerHelper.updateRLIPreviousPrice(rliObj,rliParamsWrapper);
				}
				
				if(SS_Constants.isSimplifiedDataModelEnabled){
					if(newRec.REN_Renews_To__c != null){
						List<REN_Renews_To__c> rrList;
						if(oppId2rrMap.containsKey(newRec.REN_Renews_To__c)) {
							rrList = oppId2rrMap.get(newRec.REN_Renews_To__c);
						} else {
							rrList = new List<REN_Renews_To__c>();
						}
						rrList.add(newRec);
						oppId2rrMap.put(newRec.REN_Renews_To__c, rrList);
					}
				}
			}
			//Main for-loop ends
			if(SS_Constants.isSimplifiedDataModelEnabled){
				REN_RRSimplifiedTriggerHelper.validateSyncQuoteOnOpportunity((Map<ID, REN_Renews_To__c>)oldRecordsMap,oppId2rrMap);
			}
			if(isSolutionExtnInstalled && !rliParamsSolExt.newRecordsMap.isEmpty()){
				(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'RLITriggerInvocationHandler', rliParamsSolExt);
			}
		}
	}
	
	private static void scheduleAsyncBatches(Set<Id> opportunityIdSet, Boolean isInsertCall) {
		List<String> opportunityIdList = new List<String>();
		opportunityIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(opportunityIdSet), List<String>.class));
		Set<String> quoteFldstoQuery = new Set<String>{'Id', 'IsSyncing', 'OpportunityId'};
		List<Sobject> impactedQuoteList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,CHL_Constants.OBJ_QUOTE,'IsSyncing = true and OpportunityId IN ( \''+String.join(opportunityIdList, '\',\'')+'\') ');
		if(impactedQuoteList != null && !impactedQuoteList.isEmpty() && isInsertCall) {
	        REN_AsyncUtil.scheduleCreateQuoteAndQLIBatch(true, 5);
		} else {
			REN_AsyncUtil.scheduleMetricsFieldCalculation();
		}
	}
	
	public class InvalidDataException extends Exception{}
}