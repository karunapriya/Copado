/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Vishal, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Vishal					User Story				Apr 19, 2018			1.1					@description
 *
 */
public with sharing class REN_OpportunitiesService extends REN_JSONAPIBusinessLayer {
        
    
   /* This method is used to handle GET response to fetch details of Opportunity */    
 	public override String getResponse(Set<String> oppIdSet){
 		String objectName = 'opportunity';
		String  oppId = (new List<String>(oppIdSet))[0];
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        String stageValue;  
        String quoteLink;
        Pagereference pageRef;
        String currencyCode = '';
        try {
        	if(UserInfo.isMultiCurrencyOrganization()){
        		List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityDetailsForCurrency(oppIdSet);
        		if(oppList != null && !oppList.isEmpty()){
        			currencyCode = String.valueOf(oppList[0].get('CurrencyIsoCode'));	
        		}	
        	}else{
        		currencyCode = UserInfo.getDefaultCurrency();
        	}
	        List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppId});
	        String langCode = opptyRoleList != null && !opptyRoleList.isEmpty() ? opptyRoleList[0].Contact.REN_Prefered_Language_Code__c : 'en-US';
	        pageRef = Page.REN_LabelTranslatorPlaceholder;
        	pageRef.getParameters().put('languageCode', langCode);
	        REN_LabelTranslatorAPI lblTranslator = new REN_LabelTranslatorAPI();
	        Map<String,String> mapOfTranslatedLabels = lblTranslator.translatedLabelsMap(new set<Pagereference>{pageRef});
	        REN_LowTouchUtil.LowTouchMetadataWrapper  lowTouchMetadataWrapper = new REN_LowTouchUtil.LowTouchMetadataWrapper();
		    lowTouchMetadataWrapper.objectName = objectName;
		    lowTouchMetadataWrapper.fieldSetMemberList = SObjectType.Opportunity.FieldSets.REN_Low_Touch_Renewal_Information.getFields();
		    lowTouchMetadataWrapper.fieldsToAdd = null;
		    lowTouchMetadataWrapper.mapOfTranslatedLabels = mapOfTranslatedLabels;
		    lowTouchMetadataWrapper.currencyCode = currencyCode;
		    
	        REN_JSONAPIPayLoad.MetaData meta = lowTouchUtil.getMetaData(lowTouchMetadataWrapper);
	        //System.debug('meta ->'+JSON.serialize(meta));
	              
	        setFieldPropertiesForAdditionalFields(getAdditionalFields(), meta);
	        String additionalQueryFields = !lowTouchUtil.apiNameSet.contains('stagename') ? ',stagename' : '';
	        additionalQueryFields = !lowTouchUtil.apiNameSet.contains('SyncedQuoteId') && CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId')  ? additionalQueryFields + ',SyncedQuoteId' : additionalQueryFields;
	        additionalQueryFields = !lowTouchUtil.apiNameSet.contains('quoteNumber') && CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c') ? additionalQueryFields + ','+CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c' : additionalQueryFields;
	        //lowTouchUtil.queryString += ' from Opportunity where Id IN :oppIdSet LIMIT 1'; 
	        
	        String[] additionalFields = additionalQueryFields.split(',');
	        for(integer i = 0; i<additionalFields.size(); i++) {
	        	system.debug('fieldValue :: '+additionalFields[i]);
	        	if(String.isNotblank(additionalFields[i]) && additionalFields[i] != null) 
	        	lowTouchUtil.fieldList.add(additionalFields[i]);
	        }
	        String queryString = 'Select '+String.join(lowTouchUtil.fieldList, ',')+ ' From Opportunity where Id IN :oppIdSet LIMIT 1';
	        
	        System.debug('queryString - '+queryString +'\n lowTouchUtil.fieldList : '+lowTouchUtil.fieldList);  
	        //CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem',
	        List<String> requestedFields = lowTouchUtil.fieldList;
	        for(Integer i = requestedFields.size() - 1; i >= 0; i--) {
	        	if (requestedFields[i].indexOf('.')>-1){
	        		requestedFields.remove(i);
	        	}
	        }
	        //system.debug('requestedFields :: '+requestedFields);
	        List<Opportunity> oppList = CSM_OpportunityDataAccess.getOpportunitiesDetails(oppIdSet, requestedFields, queryString);
	        //System.debug('@@@ oppList - '+ oppList);
			payLoadParent = lowTouchUtil.getJSONData(objectName, oppList, lowTouchUtil.apiNameSet);
			payLoadParent.meta = new REN_JSONAPIPayLoad.definitionsMain();
			payLoadParent.meta.definitions = new Map<String, REN_JSONAPIPayLoad.MetaData>();
			payLoadParent.meta.definitions.put(objectName, meta);
	        payLoadParent.action = 'GET';
	        errorList = new List<REN_JSONAPIPayLoad.Error>();
	        if(payLoadParent.data != null){
	        	stageValue = oppList != null && !oppList.isEmpty() && (oppList[0].stagename == 'Quote Delivered' || oppList[0].stagename == 'No Service' || oppList[0].stagename == 'PO Received') ? oppList[0].stagename.toUpperCase() : 'QUOTE_DELIVERED';
	    		stageValue = stageValue.replaceAll('\\s+','_');
	    		system.debug('stageValue :: '+stageValue);
	    		payLoadParent.data[0].attributes.put('stageName', stageValue); //
	    		String domain = REN_LowTouchIntegration.getProtocolAndHost();
	            String accessToken = REN_LowTouchIntegration.accessToken;
	            if (accessToken==null){
	            	accessToken = REN_LowTouchIntegration.getAccessToken();
	            }
	            String quotePdfOption = CHL_Util.getQuotePDFOption();
	            if(String.isNotBlank(quotePdfOption) && quotePdfOption.containsIgnoreCase('Attachment')){
	            	if(CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId')) {
	                	Id syncQuoteId = (Id)oppList[0].get('SyncedQuoteId');
	                	List<sObject> lstOfAttch = CHL_AttachmentDataAccess.getAttachmentListByParentId(new Set<Id>{syncQuoteId},true);
	                	if(lstOfAttch != null && !lstOfAttch.isEmpty()) {
	                		quoteLink = domain + '/secur/frontdoor.jsp?sid='+accessToken+'&retURL='+domain+'/servlet/servlet.FileDownload?file='+lstOfAttch[0].Id ;
	                	} else {
							payLoadParent.status = 'ERROR';
		                	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, Label.REN_LT_SYNCED_QUOTE_ERR));
		                    REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, oppId); 	                    
	                	}
	            	}
	            } else {
					Map<String, String> oppToDocumnetIdMap = lowTouchUtil.getDocumentIdByOppty(oppList);
					if(oppToDocumnetIdMap != null && oppToDocumnetIdMap.containsKey((Id)oppList[0].get('Id')) ) {
		    			quoteLink = domain + '/secur/frontdoor.jsp?sid='+accessToken+'&retURL='+domain+'/sfc/servlet.shepherd/version/download/'+oppToDocumnetIdMap.get((Id)oppList[0].get('Id'))+'?asPdf=false' ;
					} else {
						payLoadParent.status = 'ERROR';
	                	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, Label.REN_LT_SYNCED_QUOTE_ERR));
	                    REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, oppId); 
					}
	            }
	            system.debug('quoteLink :: '+quoteLink);
	        	payLoadParent.data[0].attributes.put('quoteLink', quoteLink);
	        	//payLoadParent.data[0].attributes.put('quote-link', quoteLink);
	        	if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c')){
	        		payLoadParent.data[0].attributes.put('quoteNumber', (String)oppList[0].get(CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c'));
	        	}
	        	//payLoadParent.data[0].attributes.put('quoteNumber', CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c');
	        } 
	        if(stageValue == 'QUOTE_DELIVERED' && payLoadParent.status != 'ERROR') {
		        REN_LowTouchUtil.LowTouchWrapper  lowTouchWrapper = new REN_LowTouchUtil.LowTouchWrapper();
		        lowTouchWrapper.oppIdSet = new set<Id>{oppId};
		        lowTouchWrapper.langCode = 'en-US';
		        lowTouchWrapper.payLoad = payLoadParent;
		        lowTouchWrapper.payLoad.errors = errorList;
	        	REN_LowTouchOpportunities.updateOppStageOnLoad(lowTouchWrapper);
	        }
	       // system.debug('@@ JSON.serialize(payLoadParent) :: '+ JSON.serialize(payLoadParent));
        	payLoadParent.status = 'SUCCESS';
        }	catch(Exception e){
            //Database.rollback(sp);
            payLoadParent.status = 'ERROR';
            payLoadParent.action = 'GET';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()));
            REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, e.getMessage(), oppId);
            payLoadParent.errors = errorList;
        }
        payLoadParent.errors = errorList;
        System.debug('payLoad >>>> ' + JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
	}
	
	/* This method is used to handle POST response to for Opportunity */    
    public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return JSON.serialize(REN_LowTouchOpportunities.handelOpportunityOnBuyNow(oppIdSet, payLoad));
    }
    
    /**To get additional fields in the meta properties, add as field name & type (Separated by :) **/
    private Set<String> getAdditionalFields(){
 		Set<String> fieldsToAdd = new Set<String>();
        fieldsToAdd.add('quote-link:url');
        fieldsToAdd.add('stagename:STRING');
        fieldsToAdd.add('quoteNumber:NUMBER');
        fieldsToAdd.add('orderMethod:STRING');
        return fieldsToAdd;
    }
    
    private void setFieldPropertiesForAdditionalFields(Set<String> additionalFields, REN_JSONAPIPayLoad.MetaData meta){
    	Integer order = 0;
    	String[] fldValueArray;
    	for(String fld: additionalFields) {
    		fldValueArray = fld.split(':');
    		REN_JSONAPIPayLoad.fieldProperties fldProperties = new REN_JSONAPIPayLoad.fieldProperties();
            fldProperties.title = fldValueArray[0];
            fldProperties.type = fldValueArray[1];
            fldProperties.display = 'false';
            fldProperties.order = order;
            order++;
            meta.properties.put(fldProperties.title, fldProperties);
    	}
    }
}