/**
  * @description : CHL_PartnerOpportunityBusinessLayer class is used to return JSON response to show the list of partner opportunities in the Opportunities Tab .
    @Params : It accepts input from CHL_GridInputWrapper, which has quarters, filters opptypes etc as input
*/
public with sharing class CHL_PartnerOpportunityBusinessLayer {
     
    public static String nameSpacePrefix;
    private CHL_GridInputWrapper inputWrapper; 
    private static boolean is2TierPricingEnabled;
   
    public CHL_PartnerOpportunityBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;
    }
    
    /**
      * @description : This method returns the JSON object to show list of partner opportunities on opportunity tab.
    */
    public CHL_AngularResponeWrapper constructGridWrapper() {
    	nameSpacePrefix = CSM_Util.getNamespace();
    	//Boolean selectionNeeded = this.inputWrapper.queryParams != null && this.inputWrapper.queryParams.q != null && String.isNotBlank(this.inputWrapper.queryParams.q) ? false : true;	
    	List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = getColumnHeader();
        List<SObject> partnerOptyLst = getRecordList();
        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = getRecordDetailsList(partnerOptyLst); 
        CHL_AngularResponeWrapper optyWrap = new CHL_AngularResponeWrapper();           
        optyWrap.columnHeader = colHeaderList;
        optyWrap.gridData = recordList;
        optyWrap.gridConfiguration = CHL_Util.getGridExportOptions(Boolean.valueOf(CHL_Util.isDownloadable),Label.CHL_LBL_PARTNER_OPPORTUNITIES,true);
        return optyWrap;        
    }
    

    /**
      * @description : This method returns the list of partner opportunities matching the filter conditions based on input passed.
    */
    private List<SObject> getRecordList(){
        
       // System.debug('Called Method getRecordList ');
        //Set<String> quarterSet = new Set<String>();
        //Set<String> yearSet = new Set<String>();
        List<SObject> partnerOpportunityList = new List<SObject>();
        try {
           if(this.inputWrapper.queryParams != null && this.inputWrapper.queryParams.q != null && String.isNotBlank(this.inputWrapper.queryParams.q))	{
           	partnerOpportunityList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityBySOSL(this.inputWrapper);				
		  } else if(this.inputWrapper.queryParams != null && this.inputWrapper.queryParams.accountId != null) {
            partnerOpportunityList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataByAccount(this.inputWrapper.queryParams.accountId);
          } else {
          	 if(this.inputWrapper.query != null ) {
          	 	
        		String queryCondition = CHL_QueryBuilderUtil.buildQueryCriteria(this.inputWrapper.query.filters,this.inputWrapper.query.name,
        								this.inputWrapper.query.hasLogic ? this.inputWrapper.query.logic : '');
				//system.debug('this.inputWrapper.filters : '+this.inputWrapper.query.name);
				if((this.inputWrapper.query.name).ContainsIgnoreCase(Label.CHL_LBL_PREDEFINED) && String.isNotBlank(queryCondition)){
					if(queryCondition.contains('CHL_Partner_Account_1_Contact__c') && queryCondition.contains('CHL_Partner_Account_2_Contact__c')) {
						String[] partnerContactQuery = queryCondition.split('AND  CHL_Partner_Account_1_Contact__c');
						String partnerContact2Query = partnerContactQuery[1];
						String[] partnerContactFinalQuery = partnerContact2Query.split('AND');
						queryCondition = partnerContactQuery[0] + ' AND (CHL_Partner_Account_1_Contact__c '+partnerContactFinalQuery[0]+' OR CHL_Partner_Account_2_Contact__c'+partnerContactFinalQuery[0]+')';
						//system.debug('resellerQuery : '+partnerContactFinalQuery+':: \n ::'+queryCondition);
					}
				}
	        	partnerOpportunityList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunitiesByCriteria(queryCondition);
        	}
          	
          } 
        } catch(exception e) {
          //system.debug('ERROR : '+e);
        }
        if (partnerOpportunityList == null){
            partnerOpportunityList = new List<SObject>();
        }
        //system.debug('IN D CHL_PartnerOpportunityBusinessLayer '+partnerOpportunityList + '\n size of List : '+partnerOpportunityList.size());
        return partnerOpportunityList;
    }
    
    /**
      * @description : This method constrcts the partner opportunity data for each column.
    */
    public static List<CHL_AngularResponeWrapper.CHL_GridData> getRecordDetailsList(List<sObject> sObjectList) {      
         
        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = new List<CHL_AngularResponeWrapper.CHL_GridData>();
		set<Id> partnerOptyIds = new set<Id>();
		string columnValue;        
		//String user_locale = UserInfo.getLocale();
		//Map<String, String> locale_map = CSM_Util.getLocaleDateMap();
		Boolean isQuoteEnabled = CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE);           
		Boolean isStatusUpdated;
		Map<Id,SObject> mapofPartnerOptyNQuotePdf = new Map<Id,SObject>();
		Map<Id, Attachment> mapOfPartnerOptynQuoteAtt = new Map<Id, Attachment>();
		Map<string, String> mapofPartnerOptyNQuote = new Map<string, String>();
		//add starts
		is2TierPricingEnabled = false;
		//add ends
		//if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null){
		if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
			is2TierPricingEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
		}        
        Boolean isIncumbent = false;
		Map<String,String> picklistValueLabelMap = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe());
		Map<String,String> picklistMapForType = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Customer_Engagement_Type__c.getDescribe());
		//Added for US1169 

		String quotePdfOptionstr;
		if(!is2TierPricingEnabled && isQuoteEnabled)  {  
			quotePdfOptionstr = CHL_Util.getQuotePDFOption();
		    for(sObject chl : sObjectList) {
				partnerOptyIds.add((Id)chl.get('ID'));
			}
				Map<Id, SObject> mapOfQuote = new Map<Id,SObject>(CHL_QuoteDataAccess.getQuoteListByPartnerOppId(partnerOptyIds, true));

				mapofPartnerOptyNQuote = getQuoteDetails(partnerOptyIds, mapofQuote);
				if(String.isBlank(quotePdfOptionstr) || quotePdfOptionstr.contains('PDF') || quotePdfOptionstr == null) {            
					mapofPartnerOptyNQuotePdf = getQuotePDFsForQuote(mapOfQuote, true);              
				} else if(quotePdfOptionstr.contains('Attachment')){
					mapOfPartnerOptynQuoteAtt = getQuoteAttsForQuote(mapOfQuote, true);
				} 
			}
			integer counter = 0;
			Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
			String userLocale = UserInfo.getLocale();
			String userCurrency = UserInfo.getDefaultCurrency();
			String recordCurrency;
			sObject sOppty;

			//Added for US1490 .
			Set<String> OptyFieldSet = getFieldsToDispalyInGrid();
			Map<String, Schema.FieldSetMember> optyGridMap = getFieldsNotInOptyGrid(); //added
			Schema.FieldSetMember fieldSetObj;
			
			Boolean isMCEnabled = CSM_Util.checkMCEnabled(); //Added for US1862
            String accType1;
            String accType2;
            Id partnerAccount1Id;
            Id partnerAccount2Id;
            String currentUserAccountId;            
            Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
            String currentUserAccountType = acc <> null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
			for(sObject sObj : sObjectList) {
				CHL_AngularResponeWrapper.CHL_GridData wrp = new CHL_AngularResponeWrapper.CHL_GridData();
				wrp.recordID = (String)sObj.get('Id');           
				wrp.index = counter;
				wrp.updated = false;
				accType1 =  (String)sObj.get(CHL_Constants.OBJ_PO_PARTNER_ACC1_TYPE);
				accType2 =  (String)sObj.get(CHL_Constants.OBJ_PO_PARTNER_ACC2_TYPE);
				partnerAccount1Id = (ID)(sObj.get(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC1));
				partnerAccount2Id = (ID)(sObj.get(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC2));
				currentUserAccountId = acc <> null ? acc.id : null; //CHL_Util.currentUserDetails[0].Contact.AccountId;
				wrp.pid = (String)sObj.get('Id'); 		
                isIncumbent = (Boolean)(sObj.get('CHL_Incumbent__c'));
				//system.debug('currentUserAccountId : '+currentUserAccountId+' : '+partnerAccount1Id+' : '+partnerAccount2Id);
				if(currentUserAccountId != null && ((partnerAccount1Id != null && currentUserAccountId == partnerAccount1Id) || currentUserAccountId == partnerAccount2Id))  {
					wrp.canEdit = true;
				} else {
					wrp.canEdit = false;
				}

				Map<String,CHL_AngularResponeWrapper.CHL_RecordDetails>  recordMap = new  Map<String,CHL_AngularResponeWrapper.CHL_RecordDetails>();
				string lookupId = '';    
				string urlValue = '';
				string columnName = '';  
				//Added for US1862
				if(isMCEnabled){
					recordCurrency = CSM_Util.getAppliedCurrency(sObj);
				}else{
					recordCurrency = userCurrency;
				}
                // End
				for(string tmpfield :OptyFieldSet) {
					lookupId = '';    
					urlValue = '';
					columnName = '';
					CHL_AngularResponeWrapper.CHL_RecordDetails rec = new CHL_AngularResponeWrapper.CHL_RecordDetails();
					fieldSetObj = optyGridMap.get(tmpfield); //added
					//system.debug('\n\n @@@ tmpfield name  :: ' + tmpfield);
					if(tmpfield == CHL_Constants.OBJ_PO_NAME)  {
						columnValue = String.valueOf(sObj.get(tmpfield));
						lookupId = (String)sObj.get('Id');
						columnName = tmpfield;
					} else if(tmpfield.contains(CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE)) {
						columnValue = String.valueOf(sObj.get(nameSpacePrefix + CHL_Constants.OBJ_PO_LASTUPDATE));
						if(columnValue != null && (columnValue).trim() != '') {
							columnValue = (Date.valueOf(columnValue)).format();
						} else {
							columnValue = String.valueOf(sObj.get('CreatedDate'));
							columnValue = (Date.valueOf(columnValue)).format();					
						} 
						isStatusUpdated = (boolean)sObj.get(nameSpacePrefix + CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE);
						columnName =  tmpfield;
					} else if(tmpfield.contains(CHL_Constants.OBJ_PO_RESELLER_REP)) {
						sObject sobj1;
						if(accType1 != null && (accType1).trim() != '' && accType1.contains('Reseller'))    {
							sobj1 = sObj.getSObject(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_RESELLER_REP_NAME);
							lookupId = String.valueOf(sObj.get(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_RESELLER_REP));
						} else if(accType2 != null && (accType2).trim() != '' && accType2.contains('Reseller')) {
							sobj1 = sObj.getSObject(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_DISTRIBUTOR_REP_NAME);
							lookupId = String.valueOf(sObj.get(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_DISTRIBUTOR_REP));
						}
						if(sobj1 != null)   {
							columnValue = (String)sobj1.get('Name');
						} else {
							columnValue= 'None';
						}
						columnName =  tmpfield;                    
					} else if(tmpfield.contains(CHL_Constants.OBJ_PO_DISTRIBUTOR_REP))  {
						sObject sobj2;
						if(accType1 != null && (accType1).trim() != '' && accType1.contains('Distributor')) {
							sobj2 = sObj.getSObject(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_RESELLER_REP_NAME);
							lookupId = String.valueOf(sObj.get(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_RESELLER_REP));
						} else if(accType2 != null && (accType2).trim() != '' && accType2.contains('Distributor')) {
							sobj2 = sObj.getSObject(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_DISTRIBUTOR_REP_NAME);
							lookupId = String.valueOf(sObj.get(nameSpacePrefix + CHL_CONSTANTS.OBJ_PO_DISTRIBUTOR_REP));
						}
						if(sobj2 != null)   {
							columnValue = (String)sobj2.get('Name');
						} else {
							columnValue= 'None';
						}
						columnName =  tmpfield;
					} else if(tmpfield.contains(CHL_Constants.GRID_COLUMN_QUOTE_PDF)) {                     
						if(!is2TierPricingEnabled && isQuoteEnabled) {                      
							Attachment quoteAttachment;
							SObject quotePdf;
							columnValue = String.valueOf(sObj.get('Id'));

							if(String.isBlank(quotePdfOptionstr) || quotePdfOptionstr.contains('PDF') || quotePdfOptionstr == null) {
								if(columnValue != null && (columnValue).trim() != '') {
									quotePdf =  mapofPartnerOptyNQuotePdf.get(columnValue);
								}
							} else if(quotePdfOptionstr.contains('Attachment'))   {
								if(columnValue != null && (columnValue).trim() != '') {
									quoteAttachment = mapOfPartnerOptynQuoteAtt.get(columnValue);
								}
							} 
							columnValue = mapofPartnerOptyNQuote.get(columnValue);
							if(quotePdf != null) {
								urlValue  = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+ String.valueOf(quotePdf.Id); 
							} else if(quoteAttachment != null) { 
								urlValue = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+ String.valueOf(quoteAttachment.Id); 
							} else  {
								urlValue = '';
							}  
						} else {
							columnValue = '';
						}
						columnName = tmpfield;

					} else if(tmpfield.contains(CHL_Constants.OBJ_PO_SALES_STAGE)) {
						columnValue = String.valueOf(sObj.get(tmpfield));		
						lookupId = columnValue;      	
						if(picklistValueLabelMap.containsKey(columnValue)) {
							columnValue= picklistValueLabelMap.get(columnValue);           		           		
						}
						columnName = tmpfield;       	
					}
					else if(tmpfield.contains('CHL_Customer_Engagement_Type__c')) {
						columnValue = String.valueOf(sObj.get(tmpfield));		
						lookupId = columnValue;      	
						if(picklistMapForType.containsKey(columnValue)) {
							columnValue= picklistMapForType.get(columnValue);           		           		
						}
						columnName = tmpfield;       	
					}
					 else if(tmpfield.contains(CHL_Constants.OBJ_PO_OPPTY_ACCOUNT_NAME)) {
						sOppty = sObj.getSObject(nameSpacePrefix + 'CHL_Opportunity__r');
						columnValue = String.valueOf(sObj.get(tmpfield));
						columnName = tmpfield;
						lookupId = sOppty != null ? (String)sOppty.get('AccountId') : '';
						//Added For US1490 
					} else if(tmpfield.contains('.')) {
						String relationName = tmpfield.substringBefore('.');
						String fieldName = tmpfield.substringAfterLast('.');
						//system.debug('\n\n @@ tmpfield ::  ' + tmpfield + '\n\n @@ relationName :: ' + relationName + '\n\n @@ fieldName :: ' + fieldName);
						sOppty = sObj.getSObject(relationName);
						String valueToAdd ; 
						//system.debug('\n\n @@ sOppty ::  ' + sOppty);
						if(fieldSetObj != null){
							//system.debug('\n\n columnName :: in rec list 1 ::  ' + tmpfield);
							columnName =  (tmpfield.contains('.') ? tmpfield.remove('.') : tmpfield);
							//system.debug('\n\n columnName :: in rec list ' + columnName);
							if(String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_CURRENCY){ //US1490 :Added after refactoring
								//Added US1682
								//recordCurrency = CSM_Util.getAppliedCurrency(sObj);  
								Decimal value = sOppty != null ? (Decimal) sOppty.get(fieldName) : 0.0;
								if(isMCEnabled){
									columnValue = String.valueOf(CSM_Util.currencyConversion(value, recordCurrency, userCurrency));
								}else{
									columnValue = String.valueOf(value);
								}
								//End US1682
								columnValue = valueToAdd;
								lookupId = valueToAdd;
							} else if(String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_DATE_TIME || String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_DATE){ //US1490 : Added after refactoring
								columnValue = String.valueOf(sOppty.get(fieldName)); //Todo: ADD namespace condition
								if(columnValue != null && (columnValue).trim() != '') {
									Datetime currentDateVal = Datetime.valueOf(columnValue);
									columnValue = CSM_Util.getLocaleFormattedDateTimeValue(userLocale, currentDateVal, localeMap); 
									lookupId = CSM_Util.getLocaleFormattedDateTimeValue(userLocale, currentDateVal, localeMap);
								}
							}else if(String.valueOf(fieldSetObj.getType()) == 'Boolean'){ //US1490 : Added after refactoring
								Boolean value = sOppty != null ? (Boolean)sOppty.get(fieldName) : false;
								columnValue = String.valueOf(value);
								lookupId = String.valueOf(value);
							}else if(String.valueOf(fieldSetObj.getType()) == 'DOUBLE'|| String.valueOf(fieldSetObj.getType()) == 'PERCENT'){ //US1490 : Added after refactoring
								Decimal value = sOppty != null ? (Decimal)sOppty.get(fieldName) : 0.0;
								columnValue = String.valueOf(value);
								lookupId = String.valueOf(value);
							}else { 
								//US1490 : Added after refactoring
								columnValue = sOppty != null ? (String)sOppty.get(fieldName) : '';
								lookupId = sOppty != null ? (String)sOppty.get(fieldName) : '';
							}
						} else {
							columnName = tmpfield;
						}

					} else if(tmpfield.contains(CHL_Constants.OBJ_PO_CLOSE_DATE) || tmpfield.contains(CHL_Constants.OBJ_PO_EXPIRATIONDATE) || (fieldSetObj != null && (String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_DATE_TIME || String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_DATE)) ) { //
						columnValue = String.valueOf(sObj.get(tmpfield)); //Todo: ADD namespace condition
						if(columnValue != null && (columnValue).trim() != '') {
							columnValue = (Date.valueOf(columnValue)).format();
						}
						columnName =  tmpfield;
					} else if(tmpfield.contains(CHL_Constants.OBJ_PO_AMOUNT) || tmpfield.contains('CHL_MSRP__c') || (fieldSetObj != null && String.valueOf(fieldSetObj.getType()) == CHL_Constants.TYPE_CURRENCY) ){
						//Added US1682
						//recordCurrency = CSM_Util.getAppliedCurrency(sObj);  //Commented US1682
						columnValue = String.valueOf(sObj.get(tmpfield));
						if(isMCEnabled){
							columnValue = String.isNotBlank(columnValue) ? String.valueOf(CSM_Util.currencyConversion(Decimal.valueOf(columnValue), recordCurrency, userCurrency)) : userCurrency +'0.0';
						} else {
							columnValue = String.isNotBlank(columnValue) ? columnValue : userCurrency +'0.0';
						}
						//columnValue = String.isNotBlank(columnValue) ? String.valueOf(CSM_Util.currencyConversion(Decimal.valueOf(columnValue), recordCurrency, userCurrency)) : userCurrency +'0.0';
						if(((is2TierPricingEnabled && isIncumbent && currentUserAccountType == 'Reseller') || (!isIncumbent)) && !(tmpfield.contains('CHL_Amount__c') || tmpfield.contains('CHL_MSRP__c'))){
							columnValue = userCurrency +' 0.0';
						}
						//End US1682
						columnName =  tmpfield;
					} else {
						//system.debug('\n\n @@@ tmpfield name in else 22 :: ' + tmpfield);
						columnValue = String.valueOf(sObj.get(tmpfield));
						columnName = tmpfield;
					}
					//system.debug('\n\n @@ tmpfield 22  ::' + tmpfield);
					columnValue = columnValue != null ? columnValue : '';
					lookupId = lookupId != null ? (lookupId =='None' ? '0': lookupId): '';

					rec.value = columnValue;
					rec.url = urlValue;
					rec.currencyCode = userCurrency; //US1364
					rec.needsUpdate = isStatusUpdated;
					rec.lookupId = lookupId;
					recordMap.put(columnName,rec);
				}
				wrp.rowData = recordMap;
				recordList.add(wrp);
				//system.debug('#recordMap : '+recordMap + '\n recordList size : '+recordList.size());            
				counter = counter +1;
				recordMap = null;
			}
			return recordList;
    }   

    /**
      * @description : This method fetch the quote details and quote pdf/attachment(if attached) for partner opportunity
    */
    private static Map<string, String> getQuoteDetails(Set<Id> opportunityIds, Map<Id, SObject> mapofQuote){ 
    	Map<string, String> mapofPartnerOptyNQuote = new Map<string, String>();
        for(SObject squote : mapofQuote.values()){
        	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
        		mapofPartnerOptyNQuote.put(String.valueOf(squote.get(CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)), String.valueOf(squote.get('Name')));
        	}
        }   
        return mapofPartnerOptyNQuote;     
    }
    
    /**
      * @description : This method constrcts below two maps. 
                 1. From Partner Opportunity to QuotePDF (This will be used in Opportunity Grid, to download the PDF)
                 2. From Quote to QuotePDF (This will be used in Quote Subtab, to download the PDF)
    */
    public static Map<ID,sObject> getQuotePDFsForQuote(Map<Id,sObject> quoteMap, boolean partnerOptyMapNeeded) {
    	Map<Id,SObject> mapofPartnerOptyNQuotePdf = new Map<Id,SObject>();
    	List<SObject> quotePdflist = CHL_QuoteDataAccess.getQuotePDFListByQuoteIds(quoteMap.Keyset());              	
		Boolean hasPOFieldOnQuote = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
        if(quotePdflist != null && !quotePdflist.isEmpty()) {
            for(SObject qd: quotePdflist)   {
                if(quoteMap.containsKey((String)qd.get(CHL_CONSTANTS.OBJ_QUOTELI_QUOTEID)))   {
                    SObject quoteobjForPDF = quoteMap.get((String)qd.get(CHL_CONSTANTS.OBJ_QUOTELI_QUOTEID)); //
                    //system.debug('quoteobjForPDF : '+quoteobjForPDF);
                    if(hasPOFieldOnQuote && quoteobjForPDF != null && partnerOptyMapNeeded) {
	                    mapofPartnerOptyNQuotePdf.put((String)quoteobjForPDF.get(CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY), qd);
            		} else if(quoteobjForPDF != null && !partnerOptyMapNeeded) {
            			mapofPartnerOptyNQuotePdf.put((String)quoteobjForPDF.get('Id'), qd);
            		}                           
            	}                   
            }
        }
    	return mapofPartnerOptyNQuotePdf;
    }
    
    /**
      * @description : This method constrcts below two maps. 
                 1. From Partner Opportunity to Quote Attachement (This will be used in Opportunity Grid, to download the Attachment)
                 2. From Quote to Quote Attachment (This will be used in Quote Subtab, to download the Attachment)
    */
    public static Map<ID,Attachment> getQuoteAttsForQuote(Map<Id,sObject> quoteMap, boolean partnerOptyMapNeeded) {
		Map<Id, Attachment> mapOfPartnerOptynQuoteAtt = new Map<Id, Attachment>();
		List<Attachment> quoteAttachmentList = CHL_AttachmentDataAccess.getAttachmentListByParentId(quoteMap.keyset());            
		if(quoteAttachmentList != null && !quoteAttachmentList.isEmpty()) {
	      	for(Attachment att:quoteAttachmentList){
	        	if(quoteMap.containskey(att.ParentId)){
	            	SObject quoteObj = quoteMap.get(att.ParentId);
	                if(quoteObj != null && partnerOptyMapNeeded) {
						mapOfPartnerOptynQuoteAtt.put((String)quoteObj.get(CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY),att);
	                } else if(quoteObj != null && !partnerOptyMapNeeded) {	                	
						mapOfPartnerOptynQuoteAtt.put((String)quoteObj.get('Id'),att);
	                }
	            }
	       	}
        }
        return mapOfPartnerOptynQuoteAtt;
    }
    
    /**
      * @description : This method constrcts the columns to show on opportunity data grid in opportunity tab.
    */
    private static List<CHL_AngularResponeWrapper.CHL_ColumnHeader> getColumnHeader()  {
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List<CHL_AngularResponeWrapper.CHL_ColumnHeader>();
        CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions bulkUpdateOptions = new CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions();
        bulkUpdateOptions = CHL_PartnerOverviewUtil.fetchResellerDistributorReps();
        List<CHL_PartnerOpportunityFilters.CHL_Stages> salesStageList = CHL_PartnerOverviewUtil.getTranslatedAvailableSalesStage();
        CHL_AngularResponeWrapper.CHL_ColumnHeader colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        nameSpacePrefix = CSM_Util.getNamespace();
        is2TierPricingEnabled = false;
        //if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null){
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
       		is2TierPricingEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
        }        
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <> null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        
        colHeader.apiName = CHL_Constants.OBJ_PO_NAME;
        colHeader.label = Label.CHL_Partner_Opportunity_Name;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeader.cellView = 'DETAIL_LINK';
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_OPPTY_ACCOUNT_NAME;
        colHeader.label = Label.CHL_Account;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_SALES_STAGE;
        colHeader.label = Label.CHL_LBL_MONITOR_FIELD_SALES_STAGE;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = false;
        colHeader.isSimple = false;
        colHeader.editor = 'SELECT';
        colHeader.remoteOptions = false;
        
        List<CHL_AngularResponeWrapper.CHL_ColumnOptions> oppStages = new List<CHL_AngularResponeWrapper.CHL_ColumnOptions>();          
        for(CHL_PartnerOpportunityFilters.CHL_Stages stage : salesStageList){
			CHL_AngularResponeWrapper.CHL_ColumnOptions oppStage = new CHL_AngularResponeWrapper.CHL_ColumnOptions();
			oppStage.lookupId= stage.id;
			oppStage.value=stage.name;
			oppStages.add(oppStage);
        }  

        colHeader.options = oppStages;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_PROBABILITY;
        colHeader.label = Label.CHL_LBL_MONITOR_FIELD_PROBABILITY;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'PROBABILITY';
        colHeader.readOnly = false;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        if(!is2TierPricingEnabled || (is2TierPricingEnabled && currentUserAccountType == 'Distributor'))	{        
	        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
	        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_AMOUNT;
	        colHeader.label = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Amount__c.label;
	        colHeader.isSortable = true;
	        colHeader.isSwitchable = true;
	        colHeader.isDateCol = false;        
	        colHeader.dataType = 'MULTI_CURRENCY';
	        colHeader.currencyCode = 'currencyCode';
	        colHeader.readOnly = true;
	        colHeader.isSimple = true;
	        colHeader.remoteOptions = false;
	        colHeaderList.add(colHeader);     
        }   
        
        if(is2TierPricingEnabled)	{        
	        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
	        colHeader.apiName = nameSpacePrefix + 'CHL_MSRP__c';
	        colHeader.label = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_MSRP__c.label;
	        colHeader.isSortable = true;
	        colHeader.isSwitchable = true;
	        colHeader.isDateCol = false;        
	        colHeader.dataType = 'MULTI_CURRENCY';
	        colHeader.currencyCode = 'currencyCode';
	        colHeader.readOnly = true;
	        colHeader.isSimple = true;
	        colHeader.remoteOptions = false;
	        colHeaderList.add(colHeader);     
        }  
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_EXPIRATIONDATE;
        colHeader.label = Label.CHL_LBL_EXPIRATION_DATE;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = true;
        colHeader.dataType = 'DATETIME';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_CLOSE_DATE;
        colHeader.label = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Close_Date__c.label;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = true;
        colHeader.dataType = 'DATETIME';
        colHeader.readOnly = false;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeader.editor = 'DATE';
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_RESELLER_REP;
        colHeader.label = Label.CHL_LBL_RESELLER_REP;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = false;
        colHeader.isSimple = false;
        colHeader.editor = 'SELECT';
        colHeader.remoteOptions = false;
        List<CHL_AngularResponeWrapper.CHL_ColumnOptions> reps = new List<CHL_AngularResponeWrapper.CHL_ColumnOptions>();
          
        for(CHL_PartnerOpportunityFilters.CHL_ResellerReps rep : bulkUpdateOptions.resellerReps){
			CHL_AngularResponeWrapper.CHL_ColumnOptions resellerRep = new CHL_AngularResponeWrapper.CHL_ColumnOptions();
			resellerRep.lookupId= rep.id;
			resellerRep.value=rep.name;
			reps.add(resellerRep);
        }  
        colHeader.options = reps;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_DISTRIBUTOR_REP;
        colHeader.label = Label.CHL_LBL_DISTRIBUTOR_REP;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = false;
        colHeader.isSimple = false;
        colHeader.editor = 'SELECT';
        colHeader.options = reps;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        if(!is2TierPricingEnabled){
	        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
	        colHeader.apiName = CHL_Constants.GRID_COLUMN_QUOTE_PDF;
	        colHeader.label = Label.CHL_LBL_LATEST_QUOTE;
	        colHeader.isSortable = true;
	        colHeader.isSwitchable = true;
	        colHeader.isDateCol = false;
	        colHeader.dataType = 'LINK';
	        colHeader.url = 'url'; 
	        colHeader.readOnly = false;
	        colHeader.isSimple = false;
	        colHeader.editor = 'SELECT';
	        colHeader.optionsApiName = 'getQuoteList';
	        colHeaderList.add(colHeader);
        }
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_STATUS;
        colHeader.label = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Status__c.label;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;        
        colHeader.dataType = 'STRING';
        colHeader.readOnly = false;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeader.cellView = 'OPP_STATUS_TEXT';
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = nameSpacePrefix + CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE;
        colHeader.label = Label.CHL_LBL_UPDATE_STATUS;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = true;        
        colHeader.dataType = 'DATETIME';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.label = Label.CHL_LBL_EDIT_STATUS;
        colHeader.cellView = 'BTN_EDIT_STATUS';
        colHeader.readOnly = true;
        colHeaderList.add(colHeader);
        
        // Added US899 
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.label = Label.CHL_LBL_NEW_REQUEST;
        colHeader.cellView = 'BTN_ACTION';
        colHeader.readOnly = true;
        colHeaderList.add(colHeader);
        
        //Added For US1490 - To create ColumnHeader for the fieldSet fields.
        Map<String, Schema.FieldSetMember> fieldToAddMap = getFieldsNotInOptyGrid();
        fieldToAddMap.remove(nameSpacePrefix+'CHL_Opportunity__r.'+ nameSpacePrefix +'REN_Renewal_Target__c');
        List<Schema.FieldSetMember> fieldsToAddList = getFieldsForHeader();
        String fieldPath;
        if(fieldToAddMap != null){
        	if(fieldsToAddList != null){
        		for(Schema.FieldSetMember schemaObj : fieldsToAddList){
        			fieldToAddMap.put(String.valueOf(schemaObj.getFieldPath()), schemaObj);
        		}
        	}
        	for(Schema.FieldSetMember obj : fieldToAddMap.values()){
        		colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        		fieldPath = obj.getFieldPath();
        		//system.debug('\n\n columnName :: in header list 1 ::  ' + fieldPath);
        	    colHeader.apiName = (fieldPath.contains('.') ? fieldPath.remove('.') : fieldPath);
        		colHeader.label = obj.getLabel();
        		colHeader.isSortable = true;
       			colHeader.isSwitchable = true;
        		colHeader.isDateCol = true;
        	    if(String.valueOf(obj.getType()) == CHL_Constants.TYPE_CURRENCY) {
        			colHeader.dataType = CHL_Constants.GRID_TYPE_MULTI_CURRENCY;
	            	colHeader.currencyCode = CHL_Constants.STR_CURRENCY_CODE;
        		}  else if(String.valueOf(obj.getType()) == CHL_Constants.TYPE_PERCENT){
        			colHeader.dataType = CHL_Constants.GRID_TYPE_PROBABILITY;
        		}else if(String.valueOf(obj.getType()) == CHL_Constants.TYPE_DATE){
        			colHeader.dataType = CHL_Constants.TYPE_DATE_TIME;
        		}else {
        			colHeader.dataType = CHL_Constants.TYPE_STRING;
        		} 
        		colHeader.readOnly = true;
        		if(colHeader.apiName==nameSpacePrefix+'CHL_Customer_Engagement_Type__c') {
        			colHeader.readOnly = false;
        			colHeader.editor='SELECT';
        			List<CHL_AngularResponeWrapper.CHL_ColumnOptions> engType = new List<CHL_AngularResponeWrapper.CHL_ColumnOptions>();          
        			Map<String,String> picklistValueLabelMap=CHL_Util.getPicklistValuesMap(Schema.sObjectType.CHL_Partner_Opportunity__c.fields.CHL_Customer_Engagement_Type__c);
   					for(String str:picklistValueLabelMap.keyset()){
   						CHL_AngularResponeWrapper.CHL_ColumnOptions e = new CHL_AngularResponeWrapper.CHL_ColumnOptions();
   						e.lookupId=str;
   						e.value=picklistValueLabelMap.get(str);
   						engType.add(e);
   					} 
        			colHeader.options = engType;
        		}  
        		colHeader.isSimple = true;
        		colHeader.remoteOptions = false;
        		colHeader.visible = false;
        		//system.debug('\n\n @@@ colHeader for fieldSet fields :: ' + colHeader );
        		colHeaderList.add(colHeader);
        	}        
        }  
        return colHeaderList;
    }
      
    /**
      * @description : This method returns the data for Opportunity Details tab in community.
    */
    public static Object  getOpportunityDetails(String inputvalue) {    //CHL_OpportunityDetailWrapper
    	String nameSpace = CSM_Util.getNamespace();
        CHL_AngularTabsInputWrapper tabInputObj = new CHL_AngularTabsInputWrapper();
        tabInputObj = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        String partnerOpportunityId = tabInputObj.oppId;        
        String queryString = CHL_Util.getQueryStringFromFieldSet(nameSpace +CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME,nameSpace +CHL_Constants.OBJ_PT_OPPORTUNITY);
        queryString += ' where Id =:partnerOpportunityId LIMIT 1'; 
        List<CHL_Partner_Opportunity__c>  partnerOptyList =  Database.query(queryString);        
        List<CHL_DetailTabResponseWrapper> optyDetailWrapperList = CHL_ResponseWrapperUtil.getObjectDetailsFromFieldSet(partnerOptyList, nameSpace +CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, nameSpace +CHL_Constants.OBJ_PT_OPPORTUNITY);
        return optyDetailWrapperList[0];
       
    }
    
    /**
      * @description : This method returns the map of fields which is present in fieldSet but not in CHL_Constants.GRID_COLUMNS. Added for US1490.
    */   
	public static Map<String, Schema.FieldSetMember> getFieldsNotInOptyGrid(){
		String nameSpace = CSM_Util.getNamespace();
		Map<String, Schema.FieldSetMember> fieldsToAddInOptyGrid  = new Map<String, Schema.FieldSetMember>();
   	    List<Schema.FieldSetMember> fieldSet = CHL_Util.getFieldSet(nameSpace +CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, nameSpace+ CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
    	Set<String> colWithNameSapce = getColumnsWithNameSpace();
    	for (Schema.FieldSetMember fieldSetObj: fieldSet) {
      		if(!colWithNameSapce.contains(String.valueOf(fieldSetObj.getFieldPath()))){
      		  fieldsToAddInOptyGrid.put(String.valueOf(fieldSetObj.getFieldPath()),fieldSetObj);
      		}
         }
         //system.debug('\n\n @@@ field added in Fieldset :: ' + fieldsToAddInOptyGrid.keySet());
         return fieldsToAddInOptyGrid;
	}
	
	/**
      * @description : This method returns the Set of all fields required for Opty Grid. It includes all the fields i.e fieldSet and CHL_Constants.GRID_COLUMNS. 
                       Added for US1490.
    */ 
	public static Set<String> getFieldsToDispalyInGrid(){
		Map<String, Schema.FieldSetMember> optyGridMap = getFieldsNotInOptyGrid();
		Set<String> OptyFieldSet = new Set<String>();
		OptyFieldSet.addAll(getColumnsWithNameSpace());

		for(String fieldApi : optyGridMap.keySet()){
			OptyFieldSet.add(fieldApi);
		}
		//system.debug('\n\n @@@ All fields for OptyGrid  :: ' + OptyFieldSet);
		return OptyFieldSet;
	} 
     
    /**
      * @description : This method returns string of all field included in CHL_Constants.GRID_COLUMNS and FieldSet for SOQL. Used as Select column name. Added for US1490.
    */  
    public static String getOptyGridFieldsInSOQL(){
    	String nameSpace = CSM_Util.getNamespace();
		Set<String> OptyFieldSet = getFieldsToDispalyInGrid();
		
		//Added field which are reqired in SOQL for OptyGrid
		OptyFieldSet.add(nameSpace + CHL_Constants.OBJ_PO_RESELLER_REP_NAME_COL);
		OptyFieldSet.add(nameSpace + CHL_Constants.OBJ_PO_DISTRIBUTOR_REP_NAME_COL);
		OptyFieldSet.add(nameSpace + 'CHL_Opportunity__r.AccountId');
		OptyFieldSet.add(nameSpace + 'CHL_Last_Status_Update_Date__c');
		OptyFieldSet.add(nameSpace + 'CHL_Incumbent__c');
		OptyFieldSet.add( 'CreatedDate');

		OptyFieldSet.remove('Latest_Quote');

		String optyColumns = '';
		for(String columnPo : OptyFieldSet){
			optyColumns  = optyColumns +  columnPo + ',';
		}
		String str = optyColumns.removeEnd(',');
		//system.debug('\n\n @@@ optyColumns for SOQL :: ' + str); 
		return str;
	}
	
	public static Set<String> getColumnsWithNameSpace(){
		String nameSpace = CSM_Util.getNamespace();
		Set<String> GRID_COLUMNS_NAMESPACE = new Set<String>{CHL_Constants.OBJ_PO_NAME,
     														nameSpace + CHL_Constants.OBJ_PO_OPPTY_ACCOUNT_NAME,
                                                            nameSpace + CHL_Constants.OBJ_PO_SALES_STAGE, 
                                                            nameSpace + CHL_Constants.OBJ_PO_PROBABILITY, 
                                                            nameSpace + CHL_Constants.OBJ_PO_AMOUNT,
                                                            nameSpace + CHL_Constants.OBJ_PO_EXPIRATIONDATE, 
                                                            nameSpace + CHL_Constants.OBJ_PO_CLOSE_DATE, 
                                                            nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC1_TYPE,
                                                            nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC2_TYPE,
                                                            nameSpace + CHL_Constants.OBJ_PO_RESELLER_REP,
                                                            nameSpace + CHL_Constants.OBJ_PO_DISTRIBUTOR_REP,
                                                            CHL_Constants.GRID_COLUMN_QUOTE_PDF,
                                                            nameSpace + CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE,
                                                            nameSpace + CHL_Constants.OBJ_PO_STATUS,
                                                            nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC1,
                                                    		nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC2,
                                                    		nameSpace + 'CHL_MSRP__c',
                                                    		nameSpace + 'CHL_Syncing__c'
                                                           }; 
     	return GRID_COLUMNS_NAMESPACE;
   }
   
   /**
      * @description : DE1653/DE1659 : Added for fields that are present in GridColoums but not displaying in OptyGrid and added in fieldset.
    */   
	public static List<Schema.FieldSetMember> getFieldsForHeader(){
		String nameSpace = CSM_Util.getNamespace();
   	    List<Schema.FieldSetMember> fieldSet = CHL_Util.getFieldSet(nameSpace +CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, nameSpace+ CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
    	List<Schema.FieldSetMember> headerColList =  new List<Schema.FieldSetMember>();
    	Set<String> fieldToBeAddedSet  = new Set<String>();
    	fieldToBeAddedSet.add(nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC1_TYPE);
    	fieldToBeAddedSet.add(nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC2_TYPE);
    	fieldToBeAddedSet.add(nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC1);
    	fieldToBeAddedSet.add(nameSpace + CHL_Constants.OBJ_PO_PARTNER_ACC2);
    	for (Schema.FieldSetMember fieldSetObj: fieldSet) {
      		//system.debug('\n\n @@@ field in fieldSet :: ' + fieldSetObj);
      		if(fieldToBeAddedSet.contains(String.valueOf(fieldSetObj.getFieldPath()))){
      			headerColList.add(fieldSetObj);
      		}
         }
         //system.debug('\n\n @@@ field added in headerColList :: ' + headerColList);
         return headerColList;
	}
}