/**
 * Created Date		: May 24, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3344				May 24, 2018			1.1					@description
 *
 */
public with sharing class REN_QuoteImportHelper {

   private static Set<String> fieldsToAdd {get; set;}
	 
	 /**It will return additional fields**/
	 
	 private static void getObjectAndAdditionalFields(){
		fieldsToAdd = new Set<String>();
        fieldsToAdd.add('primary');
    }   
    
    /**It will return field properties for additional field**/
    
    private static List<REN_JSONAPIPayLoad.fieldProperties> getfieldProperties(Set<String> fieldsToAdd) {
    	List<REN_JSONAPIPayLoad.fieldProperties> fldList = new List<REN_JSONAPIPayLoad.fieldProperties>(); 
        Integer order = 0;
        if (fieldsToAdd.contains('primary')) {
        	REN_JSONAPIPayLoad.fieldProperties fldProp = new REN_JSONAPIPayLoad.fieldProperties();
            fldProp.title = 'primary';
            fldProp.type = 'Checkbox';
            fldProp.display = 'true';
            fldProp.dbRequired = 'false';
            fldProp.apiName = 'primary';
            fldProp.order = order;
            fldList.add(fldProp);
     	}
     	return fldList;
    }
    /* It will return Quote fields from FieldSet. */
    
    public static REN_JSONAPIPayLoad getQuoteObjectMetaData(Set<String> oppIdSet){
    	String objectName = 'quote';
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>(); 
        try{
        	String oppId = (new List<String>(oppIdSet))[0];   
	        getObjectAndAdditionalFields();
	        List<Document> docList = CHL_DocumentDataAccess.getQuoteTemplate();
	        String quoteTemplateURL = docList != null && !docList.isEmpty() ? Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+ String.valueOf(docList[0].Id) : '';
	          	
	        List <Schema.FieldSetMember> fieldSetList;
	        List<REN_JSONAPIPayLoad.fieldProperties> fieldPropertiesList = getfieldProperties(fieldsToAdd);
	        set<String>fieldSetFields = new Set<String>();
	        if(CSM_AccessController.hasObject('Quote')){
	        	fieldSetList = new List <Schema.FieldSetMember>();
	        	if(Test.isRunningTest()){
	        		String namespace = CSM_Util.getNamespace();
                	fieldSetList = CHL_Util.getFieldSet(namespace + CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, namespace + 'CHL_Partner_Opportunity__c');
	        	}else {
	        		fieldSetList = CHL_Util.getFieldSet(CSM_Util.nameSpacePrefixSolnExtn+'REN_Quote_Fields_for_Bulk_Import', 'quote');        			       
	        	}
	        }
	        if(fieldSetList != null){
	        	REN_JSONAPIPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, fieldSetList, new Set<String>{'OpportunityId'}); 
	        	REN_JSONAPIPayLoad.fieldProperties fldProp = new REN_JSONAPIPayLoad.fieldProperties();
		        fldProp.title = 'primary';
		        fldProp.type = 'STRING';
		        fldProp.display = 'false';
		        fldProp.apiName = 'primary';
		        fldProp.dbRequired = 'false';
		        fldProp.order = 1;
		        meta.properties.put(fldProp.title, fldProp);
		        lowTouchUtil.apiNameSet.add(fldProp.title);
		        REN_JSONAPIPayLoad.fieldProperties fldCaseIdProp = new REN_JSONAPIPayLoad.fieldProperties();
		        fldCaseIdProp.title = 'caseId';
		        fldCaseIdProp.type = 'STRING';
		        fldCaseIdProp.display = 'false';
		        fldCaseIdProp.apiName = 'caseId';
		        fldCaseIdProp.dbRequired = 'false';
		        fldCaseIdProp.order = 0;
		        meta.properties.put(fldCaseIdProp.title, fldCaseIdProp);
		        lowTouchUtil.apiNameSet.add(fldProp.title);
		     	if (!lowTouchUtil.apiNameSet.contains('opportunityId')){
		        	REN_JSONAPIPayLoad.fieldProperties fldProperties = new REN_JSONAPIPayLoad.fieldProperties();
		            fldProperties.title = 'opportunityId';
		            fldProperties.type = 'STRING';
		            fldProperties.display = 'false';
		            fldProperties.apiName = 'opportunityId';
		            fldProperties.dbRequired = 'false';
		            fldProperties.order = 0;
		            meta.properties.put(fldProperties.title, fldProperties);
		            lowTouchUtil.apiNameSet.add(fldProperties.title);
		        }      
		        System.debug('meta ->'+JSON.serialize(meta));	   
		        //payLoadParent = lowTouchUtil.getJSONData(objectName, new, lowTouchUtil.apiNameSet);     			
				payLoadParent.meta = new REN_JSONAPIPayLoad.definitionsMain();
				payLoadParent.meta.definitions = new Map<String, REN_JSONAPIPayLoad.MetaData>();
				payLoadParent.meta.definitions.put(objectName, meta);
		        payLoadParent.action = 'GET';
		        payLoadParent.links = new Map<String, String>();
		        REN_JSONAPIPayLoad.mainData payLoad = new REN_JSONAPIPayLoad.mainData();
		        payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
		        payLoad.type = 'quote';
		        Map<String, String> picklistOptionsMap =  new Map<String, String>();
		        payLoad.attributes = new Map<String,String>();
		        Date currentDate = system.today().addDays(30);
		        Datetime currentDateNTime = datetime.newInstance(currentDate.year(), currentDate.month(),currentDate.day());
				String quoteExpirationDate = currentDateNTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		        for(Schema.FieldSetMember fld:fieldSetList){	        	
		        	if(String.valueOf(fld.getType()).containsIgnoreCase('PICKLIST')){	 	        			
		        		string[] fldandObject = fld.getFieldPath().split('\\.');
		        		if(fldandObject != null && fldandObject.size()>1){
		        			picklistOptionsMap.put(fldandObject[1].toLowerCase(), '/options/'+(fldandObject[0]).toLowerCase()+'/'+fldandObject[1].toLowerCase());	        			
		        		}
		        		else{
		        			picklistOptionsMap.put(fld.getFieldPath().toLowerCase() , '/options/'+objectName.toLowerCase()+'/'+fld.getFieldPath().toLowerCase());
		        		}	       			
		        	}
		        	
		        	if (fld.getFieldPath().indexOf('.')<=-1 && fld.getFieldPath() != 'expirationdate'){
		        		payLoad.attributes.put(fld.getFieldPath().toLowerCase() , null);	 
		        	}
		        	else{
		        		payLoad.attributes.put('expirationdate', quoteExpirationDate);
		        	}      	
		        }
		       	payLoad.links = picklistOptionsMap;
		        payLoad.links.put('data_file_template', quoteTemplateURL);
		        payLoad.attributes.put('opportunityId', oppId);
		        payLoad.attributes.put('caseId', '');
	            payload.attributes.put(fieldPropertiesList[0].title,'false');
	    		payLoadParent.data.add(payLoad); 
		        payLoadParent.links.put('self' , '/opportunities/'+oppId+'/bulkquotes');
		        payLoadParent.status = 'SUCCESS';
	        }       	
        }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payloadParent.status='ERROR';
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), (new List<String>(oppIdSet))[0]);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured', e.getMessage()));
            payLoadParent.errors = errorList;           
        }       
        return payLoadParent;
	}
	
	public static REN_JSONAPIPayLoad createQuoteAndQlis(REN_JSONAPIPayLoad payLoad, Set<String> oppIdSet) {
    	List<REN_JSONAPIPayLoad.mainData> mainData = payLoad.data;
    	List<String> quoteData = new List<String>();   	
     	if(!mainData.isEmpty() && mainData != null){
     		for(REN_JSONAPIPayLoad.mainData mData : mainData){
     			String quoteObj = JSON.serialize(mainData[0].attributes);
     			quoteData.add(quoteObj);
     		}   		
     	}
     	Savepoint spBeforeQuoteCreate = Database.setSavepoint();
     	List<sObject> quotes;  	    	
    	try{   		
    		if(quoteData != null && !quoteData.isEmpty() && oppIdSet!= null && !oppIdSet.isEmpty()){
    			quotes=createQuotes(quoteData,oppIdSet);
    		}	  		
	    	payLoad.status = 'SUCCESS';
	    	payLoad.data[0].id= quotes[0].id;
    	}
    	catch(Exception e){
    		Database.rollback(spBeforeQuoteCreate);
    		List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
    		payLoad.status = 'ERROR';
    		errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured', e.getMessage()));
    		REN_LowTouchUtil.updateErrorLog(system.label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), (new List<String>(oppIdSet))[0]);
    		payLoad.errors = errorList;
    	}
    	return payLoad;
    }
    
    @TestVisible
    private static List<Opportunity> getOpportunityRecord(Set<String> oppIdsSet){
    	List<Opportunity> oppList = new List<Opportunity>();
    	List<String> oppIdsList = new List<String>();
    	oppIdsList.addAll((List<String>)JSON.deserialize(JSON.serialize(oppIdsSet), List<String>.class));
    	String initialPartQuery = 'Select Id, Pricebook2Id,CloseDate';
    	List<String> oppFldList = new List<String>{'Pricebook2Id'};
    	if (UserInfo.isMultiCurrencyOrganization()){
            initialPartQuery+= ',' + 'CurrencyIsoCode';
            oppFldList.add('CurrencyIsoCode');
        }
    	String finalPartquery = ' FROM Opportunity where ID IN ( \''+String.join(oppIdsList, '\',\'')+'\')';    	
       	String finalQuery = initialPartQuery + finalPartquery;
    	oppList = CSM_OpportunityDataAccess.getOpportunitiesDetails(oppIdsSet, oppFldList, finalQuery);
    	return oppList;   	
    }
    
    private static List<SObject> createQuotes(List<String> quoteData, Set<String> oppIdSet){
    	String solnExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
    	String quoteExtNamespace = CHL_Util.quoteExtnNameSpace;
    	CSM_TriggerManager.disableAllTriggers();
    	List<SObject> quotesList = new List<SObject>();
    	List<SObject> primaryQuotesList = new List<SObject>();
    	List <Schema.FieldSetMember> fieldSetList = new List <Schema.FieldSetMember>();
    	if(Test.isRunningTest()){
    		String namespace = CSM_Util.getNamespace();
        	fieldSetList = CHL_Util.getFieldSet(namespace + CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, namespace + 'CHL_Partner_Opportunity__c');
	    }else {
    		fieldSetList = CHL_Util.getFieldSet(CSM_Util.nameSpacePrefixSolnExtn+'REN_Quote_Fields_for_Bulk_Import', 'quote'); 
	    }
    	List<String> quoteFieldsList = new List<String>{CHL_Constants.STR_OPPOTUNITYID,
     													REN_Constants.OBJ_OPP_PRICEBOOK_ID};
    	String oppId = (new List<String>(oppIdSet))[0];
    	List<Opportunity> oppList = getOpportunityRecord(oppIdSet);
    	Map<String,String> inputFormMap;
    	List<SObject> quoteInserted;
    	for(String quoteObj : quoteData){
			inputFormMap = new Map<String,String>();
	    	inputFormMap = (Map<String,String>)JSON.deserialize(quoteObj, Map<String,String>.class);
	    	Sobject quoteObject = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject();
	    	quoteObject.put('Pricebook2Id',oppList[0].Pricebook2Id);
	    	quoteObject.put('OpportunityId',oppId);
	    	if(fieldSetList != null && !fieldSetList.isEmpty()){
		    	for(Schema.FieldSetMember  fieldMember : fieldSetList){
		    		quoteFieldsList.add((String)fieldMember.getFieldPath());
		    		if(fieldMember.getType() == Schema.DisplayType.CURRENCY && inputFormMap.get(fieldMember.getFieldPath().toLowerCase()) != null){
		    			quoteObject.put(fieldMember.getFieldPath(),Decimal.valueOf(inputFormMap.get(fieldMember.getFieldPath().toLowerCase())));
		    		}
		    		else if(inputFormMap.get(fieldMember.getFieldPath().toLowerCase()) != null && (fieldMember.getType() == Schema.DisplayType.DATE || fieldMember.getType() == Schema.DisplayType.DATETIME)){
                        if(fieldMember.getType() == Schema.DisplayType.DATE ){
                            quoteObject.put(fieldMember.getFieldPath(),Date.valueof(inputFormMap.get(fieldMember.getFieldPath().toLowerCase())));
                        }else{
                           quoteObject.put(fieldMember.getFieldPath(),(datetime)json.deserialize('"'+inputFormMap.get(fieldMember.getFieldPath().toLowerCase())+'"', datetime.class));}                        
		  		    }
		    		else{
		    			quoteObject.put(fieldMember.getFieldPath(),inputFormMap.get(fieldMember.getFieldPath().toLowerCase()));
		    		}
		    	}
	    	}	    	
	    	if(inputFormMap.get('caseId') != ''){
	    		quoteObject.put(solnExtNameSpace+'Case__c',inputFormMap.get('caseId'));
	    	}
	    	if(inputFormMap.get('primary') == 'true'){
	    		primaryQuotesList.add(quoteObject);
	    	}
	    	else{
	    		quotesList.add(quoteObject);
	    	}	
		}
		if(primaryQuotesList != null && !primaryQuotesList.isEmpty()){
			quoteInserted=CHL_QuoteDataAccess.insertQuotesForBulkImport(primaryQuotesList,quoteFieldsList); 
		}		
		if(quotesList != null && !quotesList.isEmpty()){
			quoteInserted=CHL_QuoteDataAccess.insertQuotesForBulkImport(quotesList,quoteFieldsList); 
		}
		quotesList.addAll(primaryQuotesList);
		createQuoteLineItems(quotesList, oppList);
		/* Sync Primary Quote..*/		
		if(primaryQuotesList != null && !primaryQuotesList.isEmpty() && primaryQuotesList.size() == 1){
			Map<Id,Id> opptyIdToQuoteIdMap = new Map<Id,Id>();
			opptyIdToQuoteIdMap.put((Id)primaryQuotesList[0].get('OpportunityId'), primaryQuotesList[0].Id);
			syncPrimaryQuote(oppList,opptyIdToQuoteIdMap);
		}
		return quoteInserted;    		
    }
    
    @TestVisible
    private static void createQuoteLineItems(List<SObject> quotesList, List<Opportunity> oppList){
    	String quoteExtNamespace = CHL_Util.quoteExtnNameSpace;
    	String solnExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
		List<SObject> quoteLineItemList = new List<SObject>();
    	SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
    	Boolean hasQuoteAmount = CSM_AccessController.hasField('Quote', quoteExtNamespace+'REN_QuoteAmount__c');
    	Boolean hasLocalCurrencyLineTotal = CSM_AccessController.hasField('QuoteLineItem', solnExtNameSpace+'Local_Currency_Line_Total__c');
    	Boolean hasLocalCurrencyAmount = CSM_AccessController.hasField('QuoteLineItem', solnExtNameSpace+'Local_Currency_Amount__c');
    	Decimal totalPrice;
    		 
        Map<Id,PriceBookEntry> mapofOppToPBE;
        if(productIdSetting.Renewal_Amount_Product_Id__c != null){
         	mapofOppToPBE = REN_PricebookDataAccess.getOppToPbEntry(oppList, productIdSetting.Renewal_Amount_Product_Id__c);
        }
        for(sObject quoteObj : quotesList){						
	        SObject quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
			quoteLineObj.put(REN_Constants.OBJ_ASSET_PRODUCT2ID, productIdSetting.Renewal_Amount_Product_Id__c);
			totalPrice = 0;
			if(hasQuoteAmount){			
				if(String.isNotBlank((String)quoteObj.get(solnExtNamespace+'Local_Currency_Code__c'))){		
					if(hasLocalCurrencyLineTotal){
						quoteLineObj.put(solnExtNameSpace+'Local_Currency_Line_Total__c',quoteObj.get(quoteExtNamespace+'REN_QuoteAmount__c'));
					}
					if(hasLocalCurrencyAmount){
						quoteLineObj.put(solnExtNameSpace+'Local_Currency_Amount__c',quoteObj.get(quoteExtNamespace+'REN_QuoteAmount__c'));
					}
					totalPrice = REN_CurrencyExchangeRateDataAccess.acmCurrencyConversion(
			                                    (Decimal)quoteLineObj.get(solnExtNamespace+'Local_Currency_Amount__c'), 
			                                    (String)quoteObj.get(solnExtNamespace+'Local_Currency_Code__c'), 
			                                    (String)oppList[0].get('CurrencyIsoCode'),
			                                    (oppList[0] == null ? null : oppList[0].CloseDate));
				}else{
					totalPrice = (Decimal)quoteObj.get(quoteExtNamespace+'REN_QuoteAmount__c');
				}			
			}
    		quoteLineItemList.add(CHL_AddRenewalPartnerController.getAggregateQLIObject(quoteObj, quoteLineObj, oppList[0], totalPrice, mapofOppToPBE)); 
        }
        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
        	CHL_QuoteLineItemDataAccess.insertQuotesLineItems(quoteLineItemList);
        }
    }
    
    @TestVisible
    private static void syncPrimaryQuote(List<Opportunity> oppList, Map<Id,Id> opptyIdToQuoteIdMap){
    	if(CSM_AccessController.hasField('opportunity','SyncedQuoteId')){
    		if(!oppList.isEmpty() && !opptyIdToQuoteIdMap.isEmpty()){
    			for(Opportunity opp : oppList){
    				if(opptyIdToQuoteIdMap.containsKey(opp.Id)){
    					opp.put('SyncedQuoteId', opptyIdToQuoteIdMap.get(opp.Id));
    				}
    			}
    		}
			REN_OpportunityDataAccess.updateOpportunitySObject(oppList,new List<String>{'SyncedQuoteId'});    				
		} 
    }
}