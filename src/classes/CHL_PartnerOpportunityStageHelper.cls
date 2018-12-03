public with sharing class CHL_PartnerOpportunityStageHelper {
	private static String PO_ALL = 'All Partner Opportunities';
	private static String PO_WINNING = 'Winning Partner Opportunities';
	private static String PO_LOSING = 'Losing Partner Opportunities';
	
	public static void syncSalesStageOnPartnerOpportunity(Map<Id, Opportunity> opportunityMap, List<CHL_Partner_Opportunity__c> poList, Set<String> syncedQuoteIdSet){ //REN_OpportunityTriggerParams opptyParams
		/*Map<Id, Opportunity> opportunityMap = opptyParams.filteredOpportunityMap;
		List<CHL_Partner_Opportunity__c> poList = opptyParams.partnerOptyList;
		Set<Id> syncedQuoteIdSet = opptyParams.filteredIdSet;*/
		boolean isQuoteEnabled = CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId');
		List<CHL_Sales_Stage_Mapping__c> salesStageMappingList = CHL_SalesStageMappingDataAccess.getSalesStageMapping();
		Map<String, CHL_Sales_Stage_Mapping__c> salesStageMappingMap = new Map<String, CHL_Sales_Stage_Mapping__c>();
		Map<Id, Id> winningPartnerOpportunityMap = new Map<Id, Id>();
		if(salesStageMappingList == null || salesStageMappingList.isEmpty()){
			return;
		} else {			
			for(CHL_Sales_Stage_Mapping__c mapObj: salesStageMappingList){
				salesStageMappingMap.put(mapObj.CHL_Master_Opportunity_Sales_Stage__c + ':' + mapObj.CHL_Partner_Opportunity_Type__c, mapObj);	            
			}
			if(isQuoteEnabled){
				if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){
					Set<Id> quoteIdSet = (Set<Id>)JSON.deserialize(JSON.serialize(syncedQuoteIdSet), Set<Id>.class);
					List<SObject> quoteList = CHL_QuoteDataAccess.getSyncedQuotesById(quoteIdSet); //getQuoteByIds
					for(sObject quoteObj: quoteList){
						if(quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != null){
							winningPartnerOpportunityMap.put((ID)quoteObj.get('OpportunityId'), (ID)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'));
						}
					}
				}
			}
			List<CHL_Partner_Opportunity__c> poListToUpdate = new List<CHL_Partner_Opportunity__c>();
			Opportunity newOpp;
			for(CHL_Partner_Opportunity__c poObj: poList){
				if(opportunityMap.containsKey(poObj.CHL_Opportunity__c)) {
					newOpp = opportunityMap.get(poObj.CHL_Opportunity__c);				
					boolean isUpdateRequired = false;
					if(salesStageMappingMap != null ) {
						CHL_Sales_Stage_Mapping__c salesStageMapping = salesStageMappingMap.get(newOpp.StageName + ':' + PO_ALL);
						if(salesStageMapping != null )	{
							isUpdateRequired = true;
							poObj.CHL_Sales_Stage__c = salesStageMapping.CHL_Partner_Opportunity_Sales_Stage__c;
						} else	{
 							salesStageMapping = salesStageMappingMap.get(newOpp.StageName + ':' + PO_LOSING);
							if(salesStageMapping != null && winningPartnerOpportunityMap!= null && winningPartnerOpportunityMap.containsKey(poObj.CHL_Opportunity__c) && poObj.id != winningPartnerOpportunityMap.get(poObj.CHL_Opportunity__c)) {
								isUpdateRequired = true;
								poObj.CHL_Sales_Stage__c = salesStageMapping.CHL_Partner_Opportunity_Sales_Stage__c;
							}
							salesStageMapping = salesStageMappingMap.get(newOpp.StageName + ':' + PO_WINNING);
							if(salesStageMapping != null && winningPartnerOpportunityMap!= null && winningPartnerOpportunityMap.containsKey(poObj.CHL_Opportunity__c) && poObj.id == winningPartnerOpportunityMap.get(poObj.CHL_Opportunity__c)){
								isUpdateRequired = true;
								poObj.CHL_Sales_Stage__c = salesStageMapping.CHL_Partner_Opportunity_Sales_Stage__c;
							}
						}
						if(isUpdateRequired){
							poObj.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
							poObj.CHL_Needs_Status_Update__c = false;
							poListToUpdate.add(poObj);
						}
					}
				}
			}
			if(!poListToUpdate.isEmpty()){
				CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
				CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
				CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(poListToUpdate);
			}
		}
	}
	
	
}