/**
 * Created Date     : Feb, 18 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Low Touch service for Opportunity
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   User Story              Feb 18, 2018    1.0         Low Touch oAuth access token based on refresh token   
 *
 */
public with sharing class REN_LowTouchOpportunitiesService extends REN_LowTouchBusinessLayer {
        
    
    /* This method is used to handle GET response to fetch details of Opportunity */    
 	public override String getResponse(Set<String> oppIdSet){
 		String objectName = 'opportunity';
		String  oppId = (new List<String>(oppIdSet))[0];
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        REN_LowTouchPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, SObjectType.Opportunity.FieldSets.REN_Low_Touch_Renewal_Information.getFields(), null);
        System.debug('meta ->'+JSON.serialize(meta));
                
        if (!lowTouchUtil.apiNameSet.contains('quote-link')){
        	REN_LowTouchPayLoad.fieldProperties fldProperties = new REN_LowTouchPayLoad.fieldProperties();
            fldProperties.title = 'quote-link';
            fldProperties.type = 'url';
            fldProperties.display = true;
            fldProperties.order = 0;
            meta.properties.put(fldProperties.title, fldProperties);
            lowTouchUtil.apiNameSet.add(fldProperties.title);
        }
        
        lowTouchUtil.queryString += ' from Opportunity where Id IN :oppIdSet LIMIT 1'; 
        System.debug('queryString - '+lowTouchUtil.queryString +'meta ->'+JSON.serialize(meta));  
        List<Opportunity> oppList = CSM_OpportunityDataAccess.getOpportunitiesDetails(oppIdSet,lowTouchUtil.fieldList,lowTouchUtil.queryString);
        System.debug('@@@ oppList - '+ oppList);
		REN_LowTouchPayLoad payLoadParent = lowTouchUtil.getJSONData(objectName, oppList, lowTouchUtil.apiNameSet);
		payLoadParent.meta = new REN_LowTouchPayLoad.definitionsMain();
		payLoadParent.meta.definitions = new Map<String, REN_LowTouchPayLoad.MetaData>();
		payLoadParent.meta.definitions.put(objectName, meta);
        payLoadParent.action = 'GET';
        
        if(payLoadParent.data != null){
        	payLoadParent.data[0].attributes.put('StageName', 'Quote Delivered');
        } 
        REN_LowTouchUtil.LowTouchWrapper  lowTouchWrapper = new REN_LowTouchUtil.LowTouchWrapper();
        lowTouchWrapper.oppIdSet = new set<Id>{oppId};
        lowTouchWrapper.langCode = 'en';
        lowTouchWrapper.subscription = '';
        lowTouchWrapper.payLoad = payLoadParent;
        REN_LowTouchOpportunities.updateOppStageOnLoad(lowTouchWrapper);
        system.debug('@@ JSON.serialize(payLoadParent) :: '+ JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
	}
	
	/* This method is used to handle POST response to for Opportunity */    
    public override String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad){
    	return JSON.serialize(REN_LowTouchOpportunities.handelOpportunityOnBuyNow(oppIdSet, payLoad));
    }
	
}