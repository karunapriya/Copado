public with sharing class REN_LowTouchUtil {

    public Set<String> apiNameSet {get; set;}
    public String queryString {get; set;}
    public List<String> fieldList {get; set;}
    public String recordCurrencyCode;
		
    private List<REN_JSONAPIPayLoad.fieldProperties> getfieldProperties(List<Schema.FieldSetMember> fieldSetMemberList, Map<String, String> mapOfTranslatedLabels, String objectName) {
        List<REN_JSONAPIPayLoad.fieldProperties> fldList = new List<REN_JSONAPIPayLoad.fieldProperties>();
        Integer order = 1;
        Schema.DescribeSObjectResult res = Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<Schema.SObjectType> referenceList;
        Set<String> fieldAPINames = new Set<String>();
        String relatedFieldName;
        for(Schema.FieldSetMember fld : fieldSetMemberList) 
        {
            REN_JSONAPIPayLoad.fieldProperties fldProp = new REN_JSONAPIPayLoad.fieldProperties();
            fldProp.title = mapOfTranslatedLabels != null && mapOfTranslatedLabels.containsKey(fld.getFieldPath()) ? mapOfTranslatedLabels.get(fld.getFieldPath()) : fld.getLabel();//fld.getLabel();
            fldProp.type = String.valueOf(fld.getType());
            if(fldProp.type == 'PICKLIST')
                fldProp.type = 'SELECT';
            else if(fldProp.type == 'DATE'|| fldProp.type == 'DATETIME')
                  fldProp.type = 'DATE';
            else if(fldProp.type == 'CURRENCY'){
            	fldProp.type = 'CURRENCY';
                fldProp.code = recordCurrencyCode;	
            }
                 
            //fldProp.required = fld.getRequired();           
            fldProp.display = 'true';            
            fldProp.dbRequired = String.Valueof((fld.getDBRequired() || fld.getRequired()));
            
            
            if((fld.getFieldPath()).indexOf('.')>-1) {
            	String[] apiNameString = (fld.getFieldPath()).split('\\.');
				string lookupField =  (apiNameString[0].tolowercase()).endsWith('__r') ?  (apiNameString[0].tolowercase()).removeEnd('__r') +  '__c' : apiNameString[0].tolowercase();
				if(res.fields.getMap().get(lookupField) != null) {
					referenceList = res.fields.getMap().get(lookupField).getDescribe().getReferenceTo();
					relatedFieldName = referenceList != null && !referenceList.isEmpty() && referenceList[0].getDescribe().getName() != objectName ? (referenceList[0].getDescribe().getName().toLowerCase())+'.'+apiNameString[1].toLowerCase() : apiNameString[1].toLowerCase();
					
				} else {
					relatedFieldName = fld.getFieldPath().toLowerCase();
					//fieldAPINames.add(relatedFieldName);
				}
				if(!fieldAPINames.contains(relatedFieldName.toLowerCase())) {
					fldProp.apiName = relatedFieldName.toLowerCase();
					fieldAPINames.add(relatedFieldName.toLowerCase());					
				}
            } else  {
            	if(!fieldAPINames.contains(fld.getFieldPath().toLowerCase())) {
	            	fldProp.apiName = fld.getFieldPath().toLowerCase();
	            	fieldAPINames.add(fld.getFieldPath().toLowerCase());
            	}
            }
            //system.debug('fldProp.apiName :: '+fldProp.apiName);
            fldProp.order = order;
            order++;
            fldList.add(fldProp);
        }
        return fldList;
	}
    
    private List<REN_JSONAPIPayLoad.fieldProperties> getfieldProperties(String objectName, Set<String> fieldsToAdd) {
        String[] types = new String[]{objectName};
        Map <String, Schema.SObjectField> fieldsMap = Schema.describeSObjects(types)[0].fields.getMap();
        List<REN_JSONAPIPayLoad.fieldProperties> fldList = new List<REN_JSONAPIPayLoad.fieldProperties>();
        Integer order = 0;
        String fieldNameWithoutNS;
        String namespace = CSM_Util.getNamespace(); 
        if (fieldsToAdd.contains('selected'))	{ //|| fieldsToAdd.contains('unsubscribed')
            REN_JSONAPIPayLoad.fieldProperties fldProp = new REN_JSONAPIPayLoad.fieldProperties();
            fldProp.title = 'selected';
            fldProp.type = 'BOOLEAN';
            fldProp.display = 'false';
            fldProp.dbRequired = 'false';
            fldProp.apiName = 'selected';
            fldProp.order = order;
            order++;
            fldList.add(fldProp);
        }
		for(Schema.SObjectField objfield : fieldsMap.values()){
            DescribeFieldResult dfr = objfield.getDescribe();
            fieldNameWithoutNS = (dfr.getName().toLowerCase()).startswith(namespace.toLowerCase()) ? (dfr.getName().toLowerCase()).remove(namespace.toLowerCase()) : dfr.getName().toLowerCase();
            //system.debug('dfr :: '+dfr.getName().toLowerCase());
            if (fieldsToAdd.contains(dfr.getName().toLowerCase()) || fieldsToAdd.contains(fieldNameWithoutNS)){
                REN_JSONAPIPayLoad.fieldProperties fldProp = new REN_JSONAPIPayLoad.fieldProperties();
                fldProp.title = dfr.getLabel();
                fldProp.type = String.valueOf(dfr.getType());
                if(fldProp.type == 'PICKLIST')
                  fldProp.type = 'SELECT';
               else if(fldProp.type == 'DATE' || fldProp.type == 'DATETIME')
                  fldProp.type = 'DATE';
               else if(fldProp.type == 'CURRENCY'){
               		fldProp.type = 'CURRENCY';
               		fldProp.code = recordCurrencyCode;
               }
                   
                //fldProp.required = dfr.getRequired();
                fldProp.display = 'true';
                fldProp.dbRequired = String.Valueof((dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate() && !dfr.isAutoNumber() && !dfr.isCalculated()));
                fldProp.apiName = dfr.getName().toLowerCase();
                fldProp.order = order;
	            order++;
	            fldList.add(fldProp);
            } 
        }
        return fldList;
	}
    public REN_JSONAPIPayLoad.MetaData getMetaData(String objectName, List<Schema.FieldSetMember> fieldSetMemberList, Set<String> fieldsToAdd) {
    	REN_LowTouchUtil.LowTouchMetadataWrapper  lowTouchMetadataWrapper = new REN_LowTouchUtil.LowTouchMetadataWrapper();
	    lowTouchMetadataWrapper.objectName = objectName;
		lowTouchMetadataWrapper.fieldSetMemberList = fieldSetMemberList;
		lowTouchMetadataWrapper.fieldsToAdd = fieldsToAdd;
		lowTouchMetadataWrapper.mapOfTranslatedLabels = null;
		lowTouchMetadataWrapper.currencyCode = null;
    	return getMetaData(lowTouchMetadataWrapper);
    }
    public REN_JSONAPIPayLoad.MetaData getMetaData(LowTouchMetadataWrapper lowTouchMetadataWrapper){
     	String nameSpace = CSM_Util.getNamespace();
     	system.debug('currencyCode  ::'+lowTouchMetadataWrapper.currencyCode);
		recordCurrencyCode = lowTouchMetadataWrapper.currencyCode;
		system.debug('recordCurrencyCode ::'+recordCurrencyCode);
        boolean firstField = true;
        this.apiNameSet = new Set<String>(); 
		this.fieldList = new List<String>();
        this.queryString = 'SELECT ';
        
        List<REN_JSONAPIPayLoad.fieldProperties> fieldPropertiesList;
        if (lowTouchMetadataWrapper.fieldSetMemberList!=null){
        	fieldPropertiesList = getfieldProperties(lowTouchMetadataWrapper.fieldSetMemberList, lowTouchMetadataWrapper.mapOfTranslatedLabels, lowTouchMetadataWrapper.objectName);
        } else {
            fieldPropertiesList = getfieldProperties(lowTouchMetadataWrapper.objectName, lowTouchMetadataWrapper.fieldsToAdd);
        }
        
        REN_JSONAPIPayLoad.MetaData meta = new REN_JSONAPIPayLoad.MetaData();
		meta.properties = new Map<String, REN_JSONAPIPayLoad.fieldProperties>();
		meta.title = lowTouchMetadataWrapper.objectName;
		meta.type = 'object';
		
        meta.relationships = new Map<String, REN_JSONAPIPayLoad.metaData>();
        REN_JSONAPIPayLoad.metaData relatedMeta;
        
        Set<String> required = new Set<String>();
		Set<String> relRequired;
        for(REN_JSONAPIPayLoad.fieldProperties fld : fieldPropertiesList) 
        {
            if(fld.apiName != null) {
	            String fldStr = fld.apiName;
	            //system.debug('fldStr '+fldStr);
	            if (nameSpace!=null && nameSpace.length()>0){
	                fldStr = fldStr.replace(nameSpace, '');
	            }
	            fieldList.add(fldStr);
	            if (firstField)
	            {
	                queryString += fld.apiName;
	                firstField = false;
	            }
	            else 
	            {
	                queryString += ', ' + fld.apiName;
	            }
	            
	            REN_JSONAPIPayLoad.fieldProperties fldProperties = new REN_JSONAPIPayLoad.fieldProperties();
	            fldProperties = fld;
	            if (fldProperties.apiName.indexOf('.')==-1 && Boolean.valueof(fldProperties.dbRequired)){
	            	required.add(fldProperties.apiName.toLowerCase());
	            }
	            //Integer addedFieldsSize = fieldsToAdd != null && !fieldsToAdd.isEmpty() ? fieldsToAdd.size():0;
	            //Integer orderRel = fieldSetMemberList != null && !fieldSetMemberList.isEmpty() ? fieldSetMemberList.size() : addedFieldsSize;
	            if (fldProperties.apiName.indexOf('.')>-1){
	            	
	            	String[] apiNameString = fldProperties.apiName.split('\\.');
	                //System.debug('ApiName String ->'+apiNameString + ' - '+meta.relationships.containsKey(apiNameString[0]));
	                REN_JSONAPIPayLoad.fieldProperties fldRelatedProperties = new REN_JSONAPIPayLoad.fieldProperties();
		            fldRelatedProperties.title = fld.title;
		            fldRelatedProperties.type = String.valueOf(fld.type);
		            fldRelatedProperties.display = 'true';
	                //fldRelatedProperties.required = fld.dbrequired;
		            fldRelatedProperties.dbRequired = String.valueOf(fld.dbrequired);
		            fldRelatedProperties.apiName = apiNameString[1].toLowerCase();
		            fldRelatedProperties.order = fldProperties.order;
	                //orderRel++;
	                if (meta.relationships.containsKey(apiNameString[0])==false){
	                    relatedMeta = new REN_JSONAPIPayLoad.metaData();
	        	    	relatedMeta.title = apiNameString[0].toLowerCase();
	            		relatedMeta.type = 'object'; 
		                relatedMeta.properties = new Map<String, REN_JSONAPIPayLoad.fieldProperties>();
	                    relRequired = new Set<String>();
	                    //orderRel--;
	                    fldRelatedProperties.order = fldProperties.order;
	                } else {
						relatedMeta = meta.relationships.get(apiNameString[0].toLowerCase());                    
	                }
		            if (fldRelatedProperties.dbRequired == 'true'){
		            	relRequired.add(fldRelatedProperties.apiName.toLowerCase());
		            }
	                //system.debug('apiNameString[1] :: '+apiNameString[1]+'apiNameString[0] :: '+apiNameString[0]);
	                //system.debug('relatedMeta.properties :: '+relatedMeta.properties);
		            relatedMeta.properties.put(apiNameString[1], fldRelatedProperties);
		            relatedMeta.required = relRequired;
		            meta.relationships.put(apiNameString[0].toLowerCase(), relatedMeta);
		            if(!(apiNameString[0].toLowerCase() == 'account' && apiNameString[1].toLowerCase() == 'name')) {
		            	meta.properties.put(apiNameString[1], fldRelatedProperties);
		            }
	            } else {
	            	meta.properties.put(fldProperties.apiName, fldProperties);
	            	meta.required = required;
	            }
	            apiNameSet.add(fldProperties.apiName);
            }
        }
        return meta;
    }
    
    public REN_JSONAPIPayLoad getJSONData(String payloadType, List<SObject> objList, Set<String> apiNameSet) {
		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
		Map<String, Schema.SObjectField> fieldsMap = CSM_AccessController.getFieldMap(payloadType);
		String nameSpace = CSM_Util.getNamespace();
		if (!objList.IsEmpty()){			
            payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
            payLoadParent.included = new List<REN_JSONAPIPayLoad.mainData>();
            system.debug('apiNameSet :: '+apiNameSet);
            //sObject sLookupObj;
			sObject sRelatedObject;
			Schema.SObjectField objRelatedField; 
			DescribeFieldResult dfr;
			Schema.SObjectField objRelatedLookupField; 
			DescribeFieldResult desclookupfield;
			List<Schema.SObjectType> referenceList;
            for (SObject obj : objList){
				REN_JSONAPIPayLoad.mainData payLoad = new REN_JSONAPIPayLoad.mainData();
                payLoad.type = payloadType;
                payLoad.id = (String) obj.get('Id');
                if (!apiNameSet.isEmpty()){
                    payLoad.attributes = new Map<String, String>();
                    payLoad.links = new Map<String, String>();
                    //payLoadParent.included = new List<REN_JSONAPIPayLoad.mainData>();
                    String jsonStr = JSON.serialize(obj);
                    payLoad.relationships = new Map<String, REN_JSONAPIPayLoad.relatedData>();
                    
                    for (String vals : apiNameSet){
                        if (vals.indexOf('.')>-1){
                            String[] objectAndField = vals.split('\\.');
                            System.debug('objectAndField - '+objectAndField);
                            String relId;
                            JSONParser parser = JSON.createParser(jsonStr);
                            System.JSONToken token;
                            REN_JSONAPIPayLoad.relatedData relatedData = new REN_JSONAPIPayLoad.relatedData();
                    		REN_JSONAPIPayLoad.mainData includedData = new REN_JSONAPIPayLoad.mainData(); 
                            relatedData.data = new Map<String, String>();
                            relatedData.data.put('type', objectAndField[0]);
                            
                            includedData.type = objectAndField[0];
                            includedData.attributes = new Map<String, String>();
                            
                            /*Boolean mainLookupField = false;
                            system.debug('token :: '+token+'\n parser.nextToken() : '+parser.nextToken());
                            while((token = parser.nextToken()) != null) {
                                if (token == JSONToken.FIELD_Name && parser.getText() == objectAndField[0]){
                                    mainLookupField = true;
                                }
                                System.debug('parser.getCurrentName() - '+parser.getCurrentName());
                                if (mainLookupField == true) {
                                    if (parser.getCurrentName() == 'Id'){
                                        relId = parser.getText();
                                        relatedData.data.put('Id', relId);
                                        includedData.Id = relId;
                                    }
                                    if (parser.getCurrentName() == objectAndField[1]){
                                        includedData.attributes.put(objectAndField[1], parser.getText());
                                    }
                                } 
                                token = parser.nextToken();
                                if (token == JSONToken.END_ARRAY) {             
                                    // we reached end of array of objects 
                                    break;
                                }
                            }*/
                            /*string lookupField = (objectAndField[0].tolowercase()).endsWith('__c') ?  objectAndField[0].tolowercase().replace('__c', '__r') : objectAndField[0].tolowercase();
		                    sLookupObj = obj.getSObject(lookupField);
		                    includedData.attributes.put(objectAndField[1], String.valueOf(sLookupObj.get(objectAndField[1])));*/
		                    string lookupField =  (objectAndField[0].tolowercase()).endsWith('__r') ?  (objectAndField[0].tolowercase()).removeEnd('__r') +  '__c' : objectAndField[0].tolowercase();
                            if(fieldsMap.containsKey(lookupField)) {
                            	objRelatedField = fieldsMap.get(lookupField);
                            	dfr = objRelatedField.getDescribe();
								if(String.valueof(dfr.getType()) == 'REFERENCE') {
									referenceList  = dfr.getReferenceTo();									
									if(payloadType == referenceList[0].getDescribe().getName()) {
										objRelatedLookupField = fieldsMap.get(objectAndField[1]);
										sRelatedObject = obj;
									} else {
										sRelatedObject = obj.getSObject(referenceList[0].getDescribe().getName());
										objRelatedLookupField = Schema.GetGlobalDescribe().get(referenceList[0].getDescribe().getName()).getDescribe().fields.getMap().get(objectAndField[1]);
									}
									
								}
                            }else {
								sRelatedObject = obj.getSObject(lookupField);
								String lookupObjectName = String.valueof(sRelatedObject.getsObjectType());
								objRelatedLookupField = Schema.GetGlobalDescribe().get(lookupObjectName).getDescribe().fields.getMap().get(objectAndField[1]);
							}
							if(objRelatedLookupField != null) {
								desclookupfield = objRelatedLookupField.getDescribe();						
							
								if((String.valueof(desclookupfield.getType()) == 'DATE' || String.valueof(desclookupfield.getType()) == 'DATE' ) && (String.valueOf(sRelatedObject.get(objectAndField[1])) != null && String.isNotBlank(String.valueOf(sRelatedObject.get(objectAndField[1]))))) {
									Date dateValue = Date.valueOf(sRelatedObject.get(objectAndField[1]));
									Datetime dateTimeValue = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
									String dateFieldValue = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
									includedData.attributes.put(objectAndField[1], dateFieldValue);
									payLoad.attributes.put(objectAndField[1], dateFieldValue);
								} else {
									includedData.attributes.put(objectAndField[1], String.valueOf(sRelatedObject.get(objectAndField[1])));
									payLoad.attributes.put(objectAndField[1], String.valueOf(sRelatedObject.get(objectAndField[1])));
								}
							}
                            relatedData.links = new Map<String, String>();
                            String self = '/'+payloadType+'/'+obj.get('Id')+'/relationships/'+objectAndField[0];
                            relatedData.links.put('self', self);
                            relatedData.links.put('related','/'+payloadType+'/'+obj.get('Id')+'/'+objectAndField[0]);
                            includedData.links = new Map<String, String>();
                            includedData.links.put('self', self);
                            payLoadParent.included.add(includedData);
                            payLoad.relationships.put(objectAndField[0], relatedData);
		                    
                        } else {
                            
                            if(fieldsMap.containsKey(vals)) {
                            	Schema.SObjectField objfield = fieldsMap.get(vals);
                            	dfr = objfield.getDescribe();
                            	if((String.valueof(dfr.getType()) == 'DATE' || String.valueof(dfr.getType()) == 'DATETIME') && String.valueOf(obj.get(vals)) != null && String.isNotBlank(String.valueOf(obj.get(vals)))) {
                            		Date dateValue = Date.valueOf(obj.get(vals));
                            		Datetime dateTimeValue = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
									String dateFieldValue = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); //.SSS
									payLoad.attributes.put(vals, dateFieldValue);
                            	} else {
                            		if(payloadType.equalsIgnoreCase(nameSpace+'ren_field_mappings__c')) {
                            			payLoad.attributes.put((vals.toLowerCase()).remove(namespace.toLowerCase()) , String.valueOf(obj.get(vals)));
                            		} else {
                            			payLoad.attributes.put(vals, String.valueOf(obj.get(vals)));
                            		}
                            	}
                            } else {
                            	payLoad.attributes.put(vals, 'false'); 
                            }
                        }
                    }
                    payLoad.links.put('self','/'+payloadType+'/'+obj.get('Id'));
                }
                //System.debug('payLoad - '+payLoad);
                payLoadParent.data.add(payLoad);
            }
		}
		return payLoadParent;
	}
        
    public REN_JSONAPIPayLoad getJSONData(String payloadType, List<SObject> objList, Set<String> apiNameSet, String objConstraint) {
		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();

		if (!objList.IsEmpty()){
            payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
            for (SObject obj : objList){
                //System.debug('obj - '+obj);
                
				REN_JSONAPIPayLoad.mainData payLoad = new REN_JSONAPIPayLoad.mainData();
                payLoad.type = payloadType;
                payLoad.id = (String) obj.get('Id');
                if (!apiNameSet.isEmpty()){
                    payLoad.attributes = new Map<String, String>();
                    payLoad.links = new Map<String, String>();
                    String jsonStr = JSON.serialize(obj);
                    //System.debug('jsonStr ->'+jsonStr);
                    REN_JSONAPIPayLoad.mainData includedData = new REN_JSONAPIPayLoad.mainData(); 
                    payLoadParent.included = new List<REN_JSONAPIPayLoad.mainData>();
    
                    for (String vals : apiNameSet){
                        JSONParser parser = JSON.createParser(jsonStr);
                        System.JSONToken token;                        
                        Boolean mainLookupField = false;
                        payLoad.attributes.put(vals, '');
                        while((token = parser.nextToken()) != null) {
                            
                            if (token == JSONToken.FIELD_Name && parser.getText() == objConstraint){
                                mainLookupField = true;
                            }
                            if (mainLookupField == true && parser.getCurrentName() != null) {
                                //Added to display contact mobile number in case creation request.
                            	String fieldApiName = parser.getCurrentName().toLowerCase();
                            	/*if(fieldApiName == 'MobilePhone'){
                            		fieldApiName = 'contactmobile';
                            	}*/
                            	fieldApiName = fieldApiName == 'MobilePhone' ? 'contactmobile' : fieldApiName;
                            	fieldApiName = fieldApiName == 'Name' ? 'contactName' : fieldApiName;
                            	//system.debug('vals :: '+vals+'::fieldApiName::'+fieldApiName+'::parser.getText()::'+parser.getText()+':parser.getCurrentName() :'+parser.getCurrentName() );
                                if (vals.contains(fieldApiName)){
                                    if (parser.getText() != objConstraint){
                                        if (parser.getCurrentName() == 'Id'){ 
                                            if (parser.getText().indexOf('003')>-1){
                                                payLoad.attributes.put(vals, parser.getText());
                                            }
                                        } else {
                                            payLoad.attributes.put(vals, parser.getText());
                                        }
                                    } else {
                                        payLoad.attributes.put(vals, '');
                                    }
                                }
                            } 
                            token = parser.nextToken();
                            if (token == JSONToken.END_ARRAY) {             
                                // we reached end of array of objects 
                                break;
                            }
                        }
                    }
                    payLoad.links.put('self','/'+payloadType+'/'+obj.get('Id'));
                }
                payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
                payLoadParent.data.add(payLoad);
            }
		}
		return payLoadParent;
	}
    
    public static List<REN_Error_Log__c> updateErrorLog(String flow, String e, ID opportunityId) {
        List<REN_Error_Log__c> errorLogList = new List<REN_Error_Log__c>();
        REN_Error_Log__c errorLog = new REN_Error_Log__c();
        errorLog.REN_Error_Description__c = e;
        errorLog.REN_Flow__c = flow;
        errorLog.REN_OpportunityId__c = String.valueOf(opportunityId);
        errorLogList.add(errorLog);
        REN_LT_ErrorLogDataAccess.insertErrorLog(errorLogList);
        return errorLogList;
    }
    
    public REN_JSONAPIPayLoad.Error createErrorList(String status, String source, String title, String detail) {
		REN_JSONAPIPayLoad.Error errorObj = new REN_JSONAPIPayLoad.Error();
		errorObj.status = status;
		errorObj.source = source;
		errorObj.title = title;
		errorObj.detail = detail;
		return errorObj;
	}
    
    public Map<String, String> getDocumentIdByOppty(List<SObject> objList){
    	Map<String, String> oppToDocumnetIdMap;
    	if (!objList.IsEmpty()){
			Set<Id> objIdSet = new Set<Id>();
			for(SObject obj : objList){
				objIdSet.add((Id)obj.get('Id'));
			}
        	oppToDocumnetIdMap = new Map<String, String>();
        	if(CSM_AccessController.hasObject('QuoteDocument')) {
	        	List<SObject> quoteList = CHL_QuoteDataAccess.getSyncedQuotePDFByOpp(objIdSet);
	        	for(SObject quote : quoteList){
	        		oppToDocumnetIdMap.put((string) quote.getSobject('quote').get('OpportunityId'),(string)quote.get('ContentVersionDocumentId'));
	        	}
        	}
    	}
	   return oppToDocumnetIdMap;
    }
	
    /* @description Class LowTouchWrapper - Its a wrapper class to pass as parametere in different service class */
	public with sharing class LowTouchWrapper { 
		public Set<Id> oppIdSet;
		public String langCode;
		public String fieldDefaultValue;
		public String fieldApiName;
		public REN_JSONAPIPayLoad payLoad;
	}
	
	/* @description Class LowTouchMetadataWrapper - Its a wrapper class to pass as parametere in different service class for metadata*/
	public with sharing class LowTouchMetadataWrapper { 
		public String objectName;
		public List<Schema.FieldSetMember> fieldSetMemberList;
		public Set<String> fieldsToAdd;
		public Map<String, String> mapOfTranslatedLabels;
		public String currencyCode;
	}
    
}