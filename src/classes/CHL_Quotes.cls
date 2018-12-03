/**
 * Created Date     : Nov 10, 2016
 * Developed By     : Amit, Comity Designs, Inc.
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
 * Amit                 User Story              Nov 10, 2016            1.1                 @description
 *
 */
public with sharing class CHL_Quotes extends REN_Renewals {
    
    public override List<SObject> createRenewals(List<SObject> quoteList, Map<Id, Id> opptyToRenewalOpptyMap){
        List<SObject> renewedObjectList = new List<SObject>();
        if(quoteList != null && !quoteList.isEmpty()){
            renewedObjectList = this.applyMapping(quoteList, CHL_Constants.OBJ_QUOTE + ':' + CHL_Constants.OBJ_QUOTE);
        }
        return renewedObjectList;
    }
    
    public override List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey){
        List<SObject> renewedObjectList = new List<SObject>();
        List<REN_Field_Mappings__c> fmList;
        if(!Test.isRunningTest()) {
        	fmList = getFieldMappingByKey(toFromObjectKey);
        }else {
        	fmList = getFieldMappingByKey('Opportunity:Quote');
        }
        Boolean hasPOField = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c');
        if(fmList != null && !fmList.isEmpty()){
            for(SObject currentObj : objectList){
                SObject renewedSobj = currentObj.clone(false, true, false, false);
                for(REN_Field_Mappings__c fieldMapping : fmList){
                    this.copyMappedValues(fieldMapping, renewedSobj, currentObj);
                }
                renewedSobj.put('OpportunityId', currentObj.get('OpportunityId'));
                renewedSobj.put('Pricebook2Id', currentObj.get('Pricebook2Id')) ;
                renewedSobj.put('ShippingHandling', currentObj.get('ShippingHandling')) ;
                renewedSobj.put('Tax', currentObj.get('Tax'));
                if(hasPOField) {
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c', 
	                        currentObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'));
	                sObject partnerOpptyObject = currentObj.getsObject(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r');
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1__c', partnerOpptyObject.get('CHL_Partner_Account_1__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Contact__c', partnerOpptyObject.get('CHL_Partner_Account_1_Contact__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c', partnerOpptyObject.get('CHL_Partner_Account_1_Type__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2__c', partnerOpptyObject.get('CHL_Partner_Account_2__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Contact__c', partnerOpptyObject.get('CHL_Partner_Account_2_Contact__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c', partnerOpptyObject.get('CHL_Partner_Account_2_Type__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Incumbent__c', partnerOpptyObject.get('CHL_Incumbent__c'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c', currentObj.get('Id'));
	                renewedSobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c', 
	                currentObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c'));
                }
                renewedObjectList.add(renewedSobj);
            }
        }
        return renewedObjectList;
    }
    
    //this will update the syncing opp & update Quote's Partner Primary
    public void updateDistributorQuote(List<SObject> quoteList, Map<Id,Id> mResToDestMap){
        List<Opportunity> opptyToUpdateList = new List<Opportunity>();
        List<String> opptIdList = new List<String>();
        Opportunity oppObj;   
        Boolean hasPPField = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c');
        for(Sobject qObj : quoteList){
        	if(hasPPField) {
           		qObj.put(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c',false); 
        	}
           	if((boolean)qObj.get('IsSyncing')){
             	oppObj = new Opportunity();
             	oppObj.put('SyncedQuoteId',mResToDestMap.get((Id)qObj.get('Id')));
             	oppObj.Id = (ID)qObj.get('OpportunityId');
             	opptIdList.add((String)qObj.get('OpportunityId'));
             	opptyToUpdateList.add(oppObj);
           	}  
        } 
                
        CHL_QuoteDataAccess.updateQuotes(quoteList); 
        if(!opptyToUpdateList.isEmpty() && opptyToUpdateList != null) {
        	List<Opportunity> oldOpptyList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(opptIdList);
	        REN_OpportunityDataAccess.updateOpportunityforRenewals(opptyToUpdateList);
	        CSM_TriggerManager.TriggerHandler triggerHandler = new CSM_OpportunityTriggerHandler();
            triggerHandler.onAfterUpdate(oldOpptyList, opptyToUpdateList, new Map<ID,Opportunity>(oldOpptyList), new Map<ID,Opportunity>(opptyToUpdateList));             
        }
    }
    
}