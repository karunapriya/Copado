public with sharing class CHL_ResponseWrapperUtil {

	
	public static List < CHL_AngularResponeWrapper.CHL_ColumnHeader > getColumnHeaderFromFieldSet(String fieldSetName,String ObjectName) {
		return getColumnHeaderFromFieldSet(fieldSetName,ObjectName,false);
	}
	/* 
	* @description: Below method is used to create header list from the fieldset. Method is created as part of US729, US746 and US752.
	* @Param: objectname, fieldsetname
	*/
	public static List < CHL_AngularResponeWrapper.CHL_ColumnHeader > getColumnHeaderFromFieldSet(String fieldSetName,String ObjectName, boolean forGlobalSearch) {
		List <CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List <CHL_AngularResponeWrapper.CHL_ColumnHeader> ();
        List < Schema.FieldSetMember > fieldSet = CHL_Util.getFieldSet(fieldSetName, ObjectName);
        String fieldPath = '';
        boolean is2TierPricingEnabled = false;
		CHL_AngularResponeWrapper.CHL_ColumnHeader colHeader;
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && CHL_OpptyStatusLogDataAccess.opptyStatusLogList.size() > 0){
       		is2TierPricingEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
        }
        string nameSpacePrefix = CSM_Util.getNamespace();
		for (Schema.FieldSetMember fieldSetObj: fieldSet) {
			fieldPath = fieldSetObj.getFieldPath();
			colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
			colHeader.apiName = (fieldPath.contains('.') ? fieldPath.remove('.') : fieldPath);
			if ('ServiceContract.Id'.equalsIgnoreCase(fieldPath)) {
				colHeader.label = Label.REN_LBL_SC_NAME;
				if(forGlobalSearch){
					colHeader.cellView = 'DETAIL_LINK';
				}
			} else {
				colHeader.label = fieldSetObj.getLabel();
			}			
			colHeader.isSortable = true;
			colHeader.isSwitchable = true;
			if (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_CURRENCY) {
				colHeader.dataType = 'MULTI_CURRENCY';
				colHeader.currencyCode = 'currencyCode';
				colHeader.isDateCol = false;
			} else if (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_DATE) {
				colHeader.dataType = CHL_Constants.TYPE_DATE_TIME;
				colHeader.isDateCol = true;
			} else if (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_PERCENT) {
				colHeader.dataType = CHL_Constants.TYPE_PERCENT;
				colHeader.isDateCol = true;
			} else {
				colHeader.dataType = 'STRING';
				colHeader.isDateCol = false;
			}
			if(forGlobalSearch){
				system.debug('Inside ObjectName ::  '+ ObjectName + 'fieldPath ::' +fieldPath);
				if(((ObjectName == 'Account' || ObjectName == 'Quote' || ObjectName == 'Asset')  && fieldPath == 'Name') || (ObjectName == 'Contact' && fieldPath == 'LastName')) {
        			colHeader.cellView = 'DETAIL_LINK';
				} else if(ObjectName == nameSpacePrefix + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP && (fieldPath == nameSpacePrefix + 'CHL_Renewal_Relationship__c' || fieldPath == nameSpacePrefix + 'CHL_Partner_Opportunity__r.Name')) {
					colHeader.cellView = 'DETAIL_LINK';
				} 
					
			}
			if(ObjectName == CHL_Constants.OBJ_QUOTE && fieldPath == CHL_Constants.OBJ_QUOTE_QUOTENUMBER ) {
				colHeader.dataType = 'LINK';
        		colHeader.url = 'url'; 
			}
			colHeader.readOnly = true;
			//US1026
			if(ObjectName == CHL_Constants.OBJ_QUOTE && fieldPath == CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY) {
				colHeader.label = Label.CHL_LBL_PRIMARY_QUOTE;
				colHeader.editor = 'CHECKBOX';
				colHeader.readOnly = forGlobalSearch;
				colHeader.dataType = 'BOOLEAN';
			}
			//US2455
			if(ObjectName == CHL_Constants.OBJ_QUOTE && fieldPath == CHL_Util.quoteExtnNameSpace+'CHL_Is_Distributor_Quote__c') {
				colHeader.label = Label.CHL_LBL_IS_DISTRIBUTOR_QUOTE;
				colHeader.editor = 'CHECKBOX';
				colHeader.readOnly = forGlobalSearch;
				colHeader.dataType = 'BOOLEAN';
			}
			colHeader.isSimple = true;
			//Added for US1423
			if(is2TierPricingEnabled && CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType))	{
				if(ObjectName == CHL_Constants.OBJ_QUOTE && !(fieldPath == 'Subtotal' || fieldPath == 'Discount' || fieldPath == 'GrandTotal' || fieldPath == 'TotalPrice')) { //)
					colHeaderList.add(colHeader);
				} else if(ObjectName != CHL_Constants.OBJ_QUOTE) {
					colHeaderList.add(colHeader);
				}
			} else {
				colHeaderList.add(colHeader);
			}
			
			
			
		}
		return colHeaderList;
	}
	
	/*
	* @description: Below method is used to create data row from the fieldset.Method is created as part of US729, US746 and US752.
	* @Param: List <sObject>, objectname, fieldsetname
	*/
	public static List<CHL_AngularResponeWrapper.CHL_GridData> getRecordDetailsListFromFieldSet(List<sObject> sObjectList, String fieldSetName, String ObjectName) {
		return getRecordDetailsListFromFieldSet(sObjectList, fieldSetName, ObjectName, null);
	}
	public static List<CHL_AngularResponeWrapper.CHL_GridData> getRecordDetailsListFromFieldSet(List<sObject> sObjectList, String fieldSetName, String ObjectName, ID pOpportunityID) {
		List<CHL_AngularResponeWrapper.CHL_GridData> recordList = new List<CHL_AngularResponeWrapper.CHL_GridData> ();
		integer counter = 0;
		
		List <Schema.FieldSetMember > fieldSet = CHL_Util.getFieldSet(fieldSetName, ObjectName);
		Set<String> currencyFieldSet = new Set<String>();
		Set<String> dateFieldSet = new Set<String>();
		Set<String> precentFieldSet = new Set<String>();
		Set<String> pickListFieldSet = new Set<String>();
		List<String> coloumNames = new List<String>();
		Map<String,String> columnMap = new Map<String,String>();
		Map<String,String> columnToFieldTypeMap = new Map<String,String>();
		String fieldPath = '';
		Map<Id,SObject> mapOfQuote = new Map<Id,SObject>();
		Map<Id, SObject> mapofQuoteNQuotePdf = new Map<Id,SObject>();
		Map<Id,Attachment> mapOfQuotenQuoteAtt = new Map<Id,Attachment>();
		string quotePdfOptionstr = CHL_Util.getQuotePDFOption();  
		boolean is2TierEnabled = false;
 		String nameSpacePrefix = CSM_Util.getNamespace();
 		String userCurrency = UserInfo.getDefaultCurrency(); //US1364
 		String recordCurrency; //US1364
 		boolean flag = false;
 		
 		Set<String> currencyFldsFromSet = new Set<String>();
 		currencyFldsFromSet = CHL_Util.getCurrencyFldsFromFldSet(fieldSetName, ObjectName);

 		//US2383
 		Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
 		string currentUserAccountId = acc <>null ? acc.id : null;
 		Map<Id,Map<String, String>> mapOfAssetNPrice = new Map<Id,Map<String, String>>();
 		Set<Id> accAndChildAccIdSet = CHL_Util.getAccAndChildAccIDs(currentUserAccountId, null);
 		
 		if (('Asset').equalsIgnoreCase(ObjectName)) {
 			mapOfAssetNPrice = CHL_Util.CreateMapOfObjIdNPrice(sObjectList,'Asset',accAndChildAccIdSet, fieldSetName);
 			
 		} else if (('ContractLineItem').equalsIgnoreCase(ObjectName)) {
 			mapOfAssetNPrice = CHL_Util.CreateMapOfObjIdNPrice(sObjectList,'ContractLineItem',accAndChildAccIdSet, fieldSetName);
 		}
 		
		if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
            is2TierEnabled = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c');
        }
       
        for (Schema.FieldSetMember fieldSetObj: fieldSet) {
			if (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_CURRENCY) {
				currencyFieldSet.add(String.valueOf(fieldSetObj.getFieldPath()));
			} else if (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_DATE) {
				dateFieldSet.add(String.valueOf(fieldSetObj.getFieldPath()));
			} else if (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_PERCENT) {
				precentFieldSet.add(String.valueOf(fieldSetObj.getFieldPath()));
			} else if(String.valueOf(fieldSetObj.getType()) == 'PICKLIST') {
				pickListFieldSet.add(String.valueOf(fieldSetObj.getFieldPath()));
			}
			coloumNames.add(String.valueOf(fieldSetObj.getFieldPath()));
			fieldPath = String.valueOf(fieldSetObj.getFieldPath());
			//US1026
			if(ObjectName == CHL_Constants.OBJ_QUOTE && fieldPath == CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY) {
				coloumNames.add(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
				columnMap.put(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY,CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
				coloumNames.add(CHL_Constants.OBJ_QUOTE_TOTAL);
				columnMap.put(CHL_Constants.OBJ_QUOTE_TOTAL,CHL_Constants.OBJ_QUOTE_TOTAL);
				coloumNames.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c');
				columnMap.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c',CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c');				
				coloumNames.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
				columnMap.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c',CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
			}
			columnMap.put(fieldPath,(fieldPath.contains('.') ? fieldPath.remove('.'): fieldPath));
			columnToFieldTypeMap.put(fieldPath,string.valueof(fieldSetObj.getType()));
		}
		
		if(ObjectName == CHL_Constants.OBJ_QUOTE && CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
			for (sObject qObj: sObjectList) {
				mapOfQuote.put((ID)qObj.get('ID'),qObj);
			}
			if(String.isBlank(quotePdfOptionstr) || quotePdfOptionstr.contains('PDF') || quotePdfOptionstr == null) {            
	        	mapofQuoteNQuotePdf = CHL_PartnerOpportunityBusinessLayer.getQuotePDFsForQuote(mapofQuote,false);	            
	              
	        } else if(quotePdfOptionstr.contains('Attachment')){
	        	mapOfQuotenQuoteAtt = CHL_PartnerOpportunityBusinessLayer.getQuoteAttsForQuote(mapofQuote,false);            
	        }
		}
		
		
		for (sObject sObj: sObjectList) {
			CHL_AngularResponeWrapper.CHL_GridData wrp = new CHL_AngularResponeWrapper.CHL_GridData();
			wrp.recordID = String.valueOf(sObj.get('id'));
			wrp.index = counter;
			wrp.canEdit = false;
			Map <String, CHL_AngularResponeWrapper.CHL_RecordDetails> recordMap = new Map<String, CHL_AngularResponeWrapper.CHL_RecordDetails>();
			if(ObjectName == CHL_Constants.OBJ_QUOTE) { 
				wrp.pid = String.valueOf(sObj.get(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c'));
			} else if(ObjectName == 'Contact' || ObjectName == 'Asset') {
				wrp.pid = String.valueOf(sObj.get('AccountId'));    
			} else if(ObjectName == nameSpacePrefix + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP  )  {
				wrp.pid = String.valueOf(sObj.get(nameSpacePrefix+'CHL_Partner_Opportunity__c'));   
				flag = (boolean)sObj.get(nameSpacePrefix+'CHL_Incumbent__c'); 
			} else if (ObjectName == 'ContractLineItem') {
				sObject sObjSC = sObj.getSObject(REN_Constants.OBJ_SERVICE_CONTRACT); 
				wrp.pid = String.valueOf(sObjSC.get('AccountId'));
			}else {
				wrp.pid = String.valueOf(sObj.get('Id')); 
			}

			for (string tmpfield: coloumNames) {
				CHL_AngularResponeWrapper.CHL_RecordDetails rec = new CHL_AngularResponeWrapper.CHL_RecordDetails();
				Object fieldValue;
				if(columnToFieldTypeMap.get(tmpfield) == 'REFERENCE' && !tmpfield.contains('.') && !tmpfield.contains('Owner') && tmpfield.contains('__c')) {
					sObject sLookupObj;
                    string lookupField = tmpfield.replace('__c', '__r');
                    sLookupObj = sObj.getSObject(lookupField);
                    if(ObjectName == CHL_Constants.OBJ_QUOTE && tmpfield == CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY) {
                    	fieldValue = sObj.get(tmpfield);
                    } else if(sLookupObj != null) {
                        fieldValue = (String)sLookupObj.get('Name');
                    }                    
                } else if(tmpfield.contains(CHL_CONSTANTS.OBJ_QUOTELI_QTY)){ 
					fieldValue = String.valueOf(sObj.get(tmpfield));
					fieldValue = fieldValue != null ? fieldValue : '0'; 
                } else if (('Asset').equalsIgnoreCase(ObjectName) && tmpfield.contains(CHL_Constants.OBJ_ASSET_PRODUCT)) {
                	sObject sObjProd2 = sObj.getSObject(CHL_CONSTANTS.OBJ_ASSET_PRODUCT2);                	
                	if(sObjProd2 != null)   {
                        fieldValue = (String)sObjProd2.get('Name');
                	}
                } else if (tmpfield.contains(REN_Constants.OBJ_ASSET_PRODUCT2ID)) {
                	sObject sObjProd2 = sObj.getSObject(REN_CONSTANTS.OBJ_PricebookEntry);              	
                	if(sObjProd2 != null)   {
                        fieldValue = (String)sObjProd2.get('Name');
                    } 
                } else if (('ContractLineItem'.equalsIgnoreCase(ObjectName) || 'Asset'.equalsIgnoreCase(ObjectName)) 
                	&& String.isNotBlank(mapOfAssetNPrice.get(sObj.Id).get(tmpfield))) {
                	
					 Map<String, String> assetNPricemap = mapOfAssetNPrice.get(sObj.Id);
					 String amount = '';
					 if (!mapOfAssetNPrice.isEmpty()) {
					 	amount = mapOfAssetNPrice.get(sObj.Id).get(tmpfield);
					 }
					 recordCurrency = CSM_Util.getAppliedCurrency(sObj);
					 if(String.isNotBlank(amount)){
	                 	fieldvalue = String.valueOf(CSM_Util.currencyConversion(Decimal.valueOf(amount), recordCurrency, userCurrency));
	                 } else {
	                 	fieldvalue = '0.00';
	                 }
                }  else if (tmpfield.contains('ServiceContract.Id') || tmpfield.contains(REN_Constants.OBJ_SC_CONTRACT_NO)) {
                	sObject sObjSC = sObj.getSObject(REN_Constants.OBJ_SERVICE_CONTRACT);                	              	
                	if(sObjSC != null && tmpfield.contains('ServiceContract.Id'))   {
                        fieldValue = (String)sObjSC.get('Name');
                    } else if(sObjSC != null && tmpfield.contains(REN_Constants.OBJ_SC_CONTRACT_NO)) {
                    	fieldValue = (String)sObjSC.get(REN_Constants.OBJ_SC_CONTRACT_NO);
                	} 
                } else if (tmpfield.contains('.')) {
					List<String> relatedListColName = tmpfield.split('\\.');
					sObject sO = sObj.getSobject(relatedListColName[0]);
					if (sO != null) {
						if (String.valueOf(sObj.getSobject(relatedListColName[0]).get(relatedListColName[1])) != null) {
							fieldValue = sO.get(relatedListColName[1]);
						}
					}
				} else {
					fieldValue = sObj.get(tmpfield);
				}

				if((ObjectName == nameSpacePrefix + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP) && currencyFieldSet.contains(tmpfield)){
                	if((flag == false)||(is2TierEnabled && flag == true && currentUserAccountType == 'Reseller')){
                		fieldValue = '0.00';
                	} else { 
                		fieldValue = fieldValue;     
                	}
				}
				
				if(ObjectName == CHL_Constants.OBJ_QUOTE && CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && tmpfield== CHL_Constants.OBJ_QUOTE_QUOTENUMBER) {
					Attachment quoteAttachment;
                    SObject quotePdf;
                    string columnValue = String.valueOf(sObj.get('Id'));
                    
                    if(String.isBlank(quotePdfOptionstr) || quotePdfOptionstr.contains('PDF') || quotePdfOptionstr == null) {
                        if(columnValue != null && (columnValue).trim() != '') {
                            quotePdf =  mapofQuoteNQuotePdf.get(columnValue);
                        }
                    } else if(quotePdfOptionstr.contains('Attachment'))   {
                        if(columnValue != null && (columnValue).trim() != '') {
                            quoteAttachment = mapOfQuotenQuoteAtt.get(columnValue);
                        }
                    } 
                    if(quotePdf != null) {
                        rec.url  = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+ String.valueOf(quotePdf.Id); 
                    } else if(quoteAttachment != null) { 
                        rec.url = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+ String.valueOf(quoteAttachment.Id); 
                    } else  {
                        rec.url = '';
                    } 
                    
				}
				if(ObjectName == CHL_Constants.OBJ_QUOTE && tmpfield == CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY) {
					if(is2TierEnabled && CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType)) {
						fieldValue = (Boolean)sObj.get(CHL_Util.quoteExtnNameSpace+'CHL_Reseller_Primary__c');
					} else {
						fieldValue = (Boolean)sObj.get(tmpfield);
					}
				}
				
				if(fieldValue != null){
					rec.value = String.valueOf(fieldValue);
					
					if (currencyFieldSet.contains(tmpfield)) {
						//Added for US1364 : Currency conversion as per user currency.
                		recordCurrency = CSM_Util.getAppliedCurrency(sObj);
                		rec.value = String.valueOf(CSM_Util.currencyConversion(Double.valueOf(fieldValue), recordCurrency, userCurrency));
						rec.currencyCode = userCurrency;
					} else if (dateFieldSet.contains(tmpfield)) {
						rec.value = (Date.valueOf(fieldValue)).format();
					} else if (precentFieldSet.contains(tmpfield)) {
						Decimal ceilingAmount=Double.valueOf(fieldValue);
						rec.value = String.valueOf(ceilingAmount.setScale(2, RoundingMode.CEILING)) + CHL_Constants.PERCENT;
					} else if(pickListFieldSet.contains(tmpfield)) {
						Map<String,String> pickListValueMap = CHL_Util.getPickListValueMap(ObjectName,tmpfield);
             			//String picklistValue = string.valueof(sObjFld.get(fieldAPIName));
            			rec.value = pickListValueMap.get(String.valueOf(fieldValue));
					}
				}
				recordMap.put(columnMap.get(tmpfield), rec);
			}
			counter = counter + 1;
			wrp.rowData = recordMap;
			recordList.add(wrp);
		}
		return recordList;
	}
	
	/**
	**/
	
	public static List <CHL_DetailTabResponseWrapper> getObjectDetailsFromFieldSet(List<sObject> sObjectList, String fieldSetName, String ObjectName) {
		List<CHL_DetailTabResponseWrapper> optyDetailWrapperList = new List<CHL_DetailTabResponseWrapper>();
		List<Schema.FieldSetMember> fieldSetMemberList =  CHL_Util.getFieldSet(fieldSetName,ObjectName);
        String nameSpacePrefix = CSM_Util.getNamespace();
        String fieldAPIName ;
        String fieldValue;
        String fieldType;
        String[] referenceFields;
        String lookupField;
        String fieldLabel;
        String userLocale = UserInfo.getLocale();
        String userCurrency = UserInfo.getDefaultCurrency(); //US1364
        String recordCurrency;  //US1364
        String currencyAmount;  //US1364
		Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
        CHL_DetailTabResponseWrapper wrpObj;
        List<CHL_DetailTabResponseWrapper.CHL_Details> detailWrapperList = new List<CHL_DetailTabResponseWrapper.CHL_Details>();
        CHL_DetailTabResponseWrapper.CHL_Details detObj;
        Map<id,sObject> assetMap ;
		Map<id,sObject> scMap ;
		Map<id,sObject> quoteMap ;
		
		Set<String> assetIdSet = new Set<String>();
        Set<String> contractIdSet = new Set<String>();
        Set<String> quoteIdSet = new Set<String>();
        boolean is2TierPricingEnabled;
        
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
       		is2TierPricingEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
        } 
        
		if (ObjectName == 'Case') {
			for (sObject sObjFld: sObjectList) {
  				for (Schema.FieldSetMember fld: fieldSetMemberList) {
  					 String fieldName = string.valueof(fld.getFieldPath());
  					 if (fieldName.contains(CHL_Constants.CASE_RELATED_TO_TXT)) {
    					String relatedToText = sObjFld.get(CHL_Constants.CASE_RELATED_TO_TXT) != null ? string.valueof(sObjFld.get(CHL_Constants.CASE_RELATED_TO_TXT)) : '';
    					
    					if(!String.isBlank(relatedToText)){
	    					String IdToSearch = relatedToText.mid(0, 18);
	    					String objType = setObjectType(CSM_AccessController.findObjectNameFromRecordIdPrefix(IdToSearch));
	
	   						if (objType == 'ASSETS') {
	    				 		assetIdSet.add(IdToSearch);
	    					} else if (objType == 'CONTRACTS') {
	     						contractIdSet.add(IdToSearch);
	    					} else if (objType == 'QUOTE') {
	     						quoteIdSet.add(IdToSearch);
	    					}
    					}
   					}
  				}
 			}
 			if (assetIdSet.size()>0) { 
				assetMap = new Map < id, sObject > (REN_AssetDataAccess.getAccountByAsset(assetIdSet));
 			}
 			if (contractIdSet.size()>0) {
				scMap = new Map < id, sObject > (REN_ServiceContractsDataAccess.getAccountByServiceContractID(contractIdSet));
			}
 			if (quoteIdSet.size()>0) {
				quoteMap = new Map < id, sObject > (CHL_QuoteDataAccess.getQuotesById(quoteIdSet));
 			}
		}
		
		//us976
		boolean flag = false;
		if(ObjectName.toLowerCase() == (CSM_Util.getNamespace() + CHL_Constants.OBJ_PARTNER_OPPORTUNITY).toLowerCase() || ObjectName.toLowerCase() == CHL_Constants.OBJ_PARTNER_OPPORTUNITY.toLowerCase() ){
			if(sObjectList != null && !sObjectList.isEmpty()) {
				Set<Id> setIncumbentPO = CHL_Util.incumbentPOSet(new Set<Id>{sObjectList[0].id});
				if(!setIncumbentPO.isEmpty()){
					flag = true;
				}
			}
		}

		//Added  US1169
		Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
 		string currentUserAccountId = acc <>null ? acc.id : null;
		String loggedInAcountType = '';
		sObject oppObj;
		for(sObject sObjFld:sObjectList){ 
            for(Schema.FieldSetMember fld :fieldSetMemberList)  {
                wrpObj = new CHL_DetailTabResponseWrapper();
                detObj = new CHL_DetailTabResponseWrapper.CHL_Details();
                fieldValue = '';
                fieldAPIName = string.valueof(fld.getFieldPath());  
                fieldType = string.valueof(fld.getType());     
                fieldLabel = fld.getLabel();  
                  
                if(fieldType == 'REFERENCE' && !fieldAPIName.contains('.') && !fieldAPIName.contains('Owner') && fieldAPIName.contains('__c')) {
                    sObject sobj;
                    lookupField = fieldAPIName.replace('__c', '__r');
                    sobj = sObjFld.getSObject(lookupField);  
                    if(sobj != null) {
                        fieldValue = (String)sobj.get('Name');
                    }                    
                } else if(fieldAPIName.contains('.')) {
                    referenceFields = fieldAPIName.split('\\.');
                    if (referenceFields !=null && referenceFields.size()==2){
                        fieldValue = sObjFld.getSobject(referenceFields[0]) != null ? string.valueof(sObjFld.getSobject(referenceFields[0]).get(referenceFields[1])): '';
                    }
                } else if(fieldAPIName.contains('Owner') ) {
                    sObject sobj;
                    sobj = sObjFld.getSObject('Owner');
                    if(sobj != null) { 
                        fieldValue = (String)sobj.get('Name');
                    }
                    fieldLabel = Label.CHL_LBL_OWNER;//Owner
                } else if(fieldAPIName.contains('ParentId')){
                	sObject sobj;
                    sobj = sObjFld.getSObject('Parent');
                    if(ObjectName == 'Case'){
                    	if(sobj != null) { 
	                        fieldValue = (String)sobj.get('CaseNumber');
	                    }
	                    fieldLabel = Label.CHL_Parent_Case;//'Parent Case';
                    }else {
	                    if(sobj != null) { 
	                        fieldValue = (String)sobj.get('Name');
	                    }
	                    fieldLabel = Label.CHL_Parent_Account;
                    }
               }else if(fieldAPIName.contains('LastModifiedById')){
                	 sObject sobj;
                    sobj = sObjFld.getSObject('LastModifiedBy');
                    if(sobj != null) { 
                        fieldValue = (String)sobj.get('Name');
                    }
                    fieldLabel = Label.CHL_Update_Account_By;//'Last Updated by';
                } else if(fieldAPIName.containsIgnoreCase('CHL_Amount__c')){                	
                	if(is2TierPricingEnabled && currentUserAccountType == 'Reseller') {
	                	fieldLabel = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_MSRP__c.label;//'MSRP';
	                	fieldValue = string.valueof(sObjFld.get(nameSpacePrefix+'CHL_MSRP__c'));
                	} else {
                		fieldLabel = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Amount__c.label;//'Amount';
	                	fieldValue = string.valueof(sObjFld.get(nameSpacePrefix+'CHL_Amount__c'));
                	}
                } else if(fieldAPIName.containsIgnoreCase('CHL_MSRP__c')) {
                	if(is2TierPricingEnabled && currentUserAccountType == 'Distributor') {
	                	fieldLabel = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_MSRP__c.label;//'MSRP';
	                	fieldValue = string.valueof(sObjFld.get(nameSpacePrefix+'CHL_MSRP__c'));
                	} else {
                		fieldLabel = '';
	                	fieldValue = '';
                	}
                }
                else {
                    fieldValue = string.valueof(sObjFld.get(fieldAPIName));                      
                }
                if(ObjectName == CHL_Constants.OBJ_CASE && fieldAPIName.contains(CHL_Constants.CASE_RELATED_TO_TXT) ){
                	String relatedToText = sObjFld.get(CHL_Constants.CASE_RELATED_TO_TXT) != null ? string.valueof(sObjFld.get(CHL_Constants.CASE_RELATED_TO_TXT)) : '';					
					fieldLabel = Label.CSM_LBL_RELATEDTO;
					if(String.isNotBlank(relatedToText)){
						fieldValue = relatedToText.mid(18, relatedToText.length());						
						detObj.relatedId = relatedToText.mid(0, 18);
						
						detObj.relatedTo = setObjectType(CSM_AccessController.findObjectNameFromRecordIdPrefix(detObj.relatedId));
						if(detObj.relatedTo == 'ASSETS'){
							sObject asset = assetMap.get(detObj.relatedId);
							detObj.relatedId = string.valueOf(asset.get('AccountId') );
						}else if(detObj.relatedTo == 'CONTRACTS'){
							sObject sc = scMap.get(detObj.relatedId);
							detObj.relatedId = string.valueOf(sc.get('AccountId'));
						}else if(detObj.relatedTo == 'QUOTE' ){
							sObject quote = quoteMap.get(detObj.relatedId);
							detObj.relatedId = string.valueOf(quote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'));
						} 
						detObj.viewType = 'LINK';
					}
                } 
                if(fieldType == 'PICKLIST') {
					Map<String,String> pickListValueMap = CHL_Util.getPickListValueMap(ObjectName,fieldAPIName);
             		String picklistValue = string.valueof(sObjFld.get(fieldAPIName));
            		fieldValue = pickListValueMap.get(picklistValue);
				}
                if(fieldValue != null && (fieldValue).trim() != '' && fieldType == CHL_Constants.TYPE_PERCENT) {
                    fieldValue += CHL_Constants.PERCENT;
                }else if (fieldType == CHL_Constants.TYPE_CURRENCY) {
                	if(fieldValue != null && (fieldValue).trim() != '' && String.isNotBlank(fieldValue)) {
	                	//Added for US1364 : currency conversion as per user currency. 
	                	recordCurrency = CSM_Util.getAppliedCurrency(sObjFld);
	                	currencyAmount = String.valueOf(CSM_Util.currencyConversion(Decimal.valueOf(fieldValue), recordCurrency, userCurrency));
	                	fieldValue = userCurrency+' '+ CHL_Util.getFormattedValue(currencyAmount);
	                	if(((is2TierPricingEnabled && flag && currentUserAccountType== 'Reseller') ||
	                        (!flag)) && !(fieldAPIName.containsIgnoreCase('CHL_Amount__c') || fieldAPIName.containsIgnoreCase('CHL_MSRP__c')) ){  //removed condition for DE2756
								fieldValue = userCurrency +' 0.00';
	                	}
                	} else if(fieldValue == null) {
                		fieldValue = userCurrency +' 0.00';
                	}
				} else if (fieldValue != null && (fieldValue).trim() != '' && (fieldType == CHL_Constants.TYPE_DATE ||  fieldType == CHL_Constants.TYPE_DATE_TIME)) {
					fieldValue = (Date.valueOf(fieldValue)).format(); 
				}
                if(fieldValue != null && (fieldValue).trim() != '')     {   
                    detObj.displayValue = fieldValue;
                } else {
                    detObj.displayValue = '';
                }
                detObj.label = fieldLabel; 
                detailWrapperList.add(detObj);                
            }      
            if (ObjectName == 'Case') {
            	wrpObj.heading = (STRING)(sObjFld.get('CaseNumber')); 
            }   else {
            	wrpObj.heading = (STRING)(sObjFld.get('Name')); 
            }  
            if(ObjectName == nameSpacePrefix+'CHL_Partner_Opportunity__c'   )	{
            	oppObj = sObjFld.getSObject(nameSpacePrefix+'CHL_Opportunity__r');  
            	//wrpObj.accId = oppObj != null ? (String)oppObj.get('AccountId') : '';
            	CHL_DetailTabResponseWrapper.CHL_Opportunity oppDetails = new CHL_DetailTabResponseWrapper.CHL_Opportunity();
            	oppDetails.acctId = oppObj != null ? (String)oppObj.get('AccountId') : '';
            	oppDetails.oppId = (STRING)(sObjFld.get('Id'));
            	oppDetails.oppName = (STRING)(sObjFld.get('Name'));
            	oppDetails.acctName = (STRING)(sObjFld.get(nameSpacePrefix+'CHL_Opportunity_Account_Name__c')); 
            	wrpObj.opp = oppDetails;
            } 
        	wrpObj.details = detailWrapperList;
        	optyDetailWrapperList.add(wrpObj);
        }
        return optyDetailWrapperList;
	}
	
	public static String setObjectType(String objectType){
	   Map<String,String> objectTypeMap = new Map<String,String>
	   {'Quote' => 'QUOTE',
	   	'Asset' => 'ASSETS',
	   	'ServiceContract' => 'CONTRACTS',
	   	 CSM_Util.getNamespace()+'CHL_Partner_Opportunity__c' => 'OPPORTUNITY'
	   };
	   
	   return objectTypeMap.get(objectType);  
	 }
	 
}