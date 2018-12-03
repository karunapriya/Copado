/**
 * Created Date		: Aug 2, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - This class have service to expose OLIs to users.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Comity					US3617				Aug 2, 2018			1.1					@description
 * 
 */
public with sharing class REN_OliService extends REN_JSONAPIBusinessLayer {

   public override String getResponse(Set<String> oppIdSet){
  		String objectName = 'OpportunityLineItem';
		String  oppId = (new List<String>(oppIdSet))[0];
		REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        System.Savepoint sp;
        Pagereference pageRef;
        List<REN_Low_Dollar_Client__c> clientDetailsList = REN_LowTouchClientDataAccess.getLowDollarClientDetails();
        Boolean isExposeOli = clientDetailsList != null && !clientDetailsList.isEmpty() && clientDetailsList[0].REN_Expose_OLI__c?true:false;
        Integer oliLimit = (Integer)CSM_Admin__c.getOrgDefaults().REN_Low_Touch_OLI_Limit__c;
        if(isExposeOli){
        	try{
	        	List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppId});
		        String langCode = opptyRoleList != null && !opptyRoleList.isEmpty() ? opptyRoleList[0].Contact.REN_Prefered_Language_Code__c : 'en-US';
		        pageRef = Page.REN_LabelTranslatorPlaceholder;
	        	pageRef.getParameters().put('languageCode', langCode);
		        REN_LabelTranslatorAPI lblTranslator = new REN_LabelTranslatorAPI();
		        Map<String,String> mapOfTranslatedLabels = lblTranslator.translatedLabelsMap(new set<Pagereference>{pageRef});
	        
		        REN_JSONAPIPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, SObjectType.OpportunityLineItem.FieldSets.REN_Low_Touch_OLI_Information.getFields(), null, mapOfTranslatedLabels);
		        String queryString = 'Select '+String.join(lowTouchUtil.fieldList, ',')+ ' From OpportunityLineItem where OpportunityId IN :oppIdSet LIMIT '+ oliLimit;
		        List<String> requestedFields = lowTouchUtil.fieldList;
		        for(Integer i = requestedFields.size() - 1; i >= 0; i--) {
		        	if (requestedFields[i].indexOf('.')>-1){
		        		requestedFields.remove(i);
		        	}
		        }
		        List<OpportunityLineItem> oppLineList = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsDetails(oppIdSet, requestedFields, new set<String>{queryString});
		        payLoadParent = lowTouchUtil.getJSONData(objectName, oppLineList, lowTouchUtil.apiNameSet);
				payLoadParent.meta = new REN_JSONAPIPayLoad.definitionsMain();
				payLoadParent.meta.definitions = new Map<String, REN_JSONAPIPayLoad.MetaData>();
				payLoadParent.meta.definitions.put(objectName, meta);
		        
		    }   catch(Exception e){
	            Database.rollback(sp);
	            payLoadParent.status = 'ERROR';
	            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()));
	            REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, e.getMessage(), oppId);
	            payLoadParent.errors = errorList;
	        }
        }
        payLoadParent.action = 'GET';
		payLoadParent.status = 'SUCCESS'; 
		payLoadParent.links = new Map<String, String>();
		payLoadParent.links.put('self','/opportunities/'+ oppId +'/oli');
        System.debug('payLoad >>>> ' + JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);   
        
   }
   
   public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return JSON.serialize(REN_LowTouchOpportunities.handelOpportunityOnBuyNow(oppIdSet, payLoad));
    }
}