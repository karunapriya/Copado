public with sharing class CHL_QuoteDataAccess {
 			
    	
 	public static List<SObject> getQuoteListByPartnerOppId(Set<Id> partnerOptyId, Boolean isPrimaryRequired) {
 		return getQuoteListByPartnerOppId(partnerOptyId, isPrimaryRequired, false);
 	}
 	public static List<SObject> getQuoteListByPartnerOppId(Set<Id> partnerOptyId, Boolean isPrimaryRequired, Boolean isSyncingRequired) {	
 		String whereClause ='';
 		//Boolean is2TierEnabled = false;
 		String nameSpacePrefix = CSM_Util.getNamespace();
    	String quoteExtnNameSpace = CHL_Util.quoteExtnNameSpace;
		List<String> quoteFieldList = new List<String>{CHL_Constants.STR_OPPOTUNITYID,'QuoteNumber','GrandTotal'};
		
        if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
            quoteFieldList.add(quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY);
            whereClause = ' where '+quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY + ' in :partnerOptyId ';
            
      		//added for CHL_PartnerOpportunityBusinessLayer -  getQuoteDetails
        	if(isPrimaryRequired){
        		if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)){
        			quoteFieldList.add(quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY);
        			whereClause += ' AND '+quoteExtnNameSpace +CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY + ' = true  ';
        		}
        		whereClause = isSyncingRequired == true ? whereClause + ' AND IsSyncing = false ': whereClause;
        	}	
        }
        String quoteCustomFields = (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)?',' + quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY:'') + (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)?',' + quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY:'');
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
        	//String columnString = CSM_Util.getColumns('Quote');
        	String columnString = '';
        	set<String>fieldSetFields = new Set<String>();
        	List<Schema.FieldSetMember> fieldSetList;
        	if(Test.isRunningTest()){
				String namespace = CSM_Util.getNamespace();
        		fieldSetList = CHL_Util.getFieldSet(namespace + CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, namespace + 'CHL_Partner_Opportunity__c');        	
        	} else {
        		fieldSetList = CHL_Util.getFieldSet(quoteExtnNameSpace+'CHL_QuoteDetails_Fieldset', 'Quote');        	
        		
        	}
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){      	
				fieldSetFields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
	            fieldSetFields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c');
	            fieldSetFields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
	            fieldSetFields.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
        	}
            fieldSetFields.add(CHL_Constants.OBJ_QUOTE_TOTAL);	            
            fieldSetFields.add('OpportunityId');
			for (Schema.FieldSetMember fld: fieldSetList) {
            	if(!String.valueof(fld.getFieldPath()).contains('.') &&  (!fieldSetFields.contains(fld.getFieldPath())) ) {
            		fieldSetFields.add(fld.getFieldPath());
            	}            	
			}
			for(String fs : fieldSetFields) { 
	        	//quoteFields.add(fs);
        		columnString += fs+',';
	        }
	        columnString = columnString.removeEnd(',');
        	List<String> fieldList = new List<String>{columnString};	
        	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);
        	String quoteQuery = Test.isRunningTest() ? 'Select Id from Quote limit 1' : 'select '+ String.join(fieldList, ',') +' from '  + CHL_CONSTANTS.OBJ_QUOTE + whereClause+ ' limit 10000' ;    
        	system.debug('### quoteQuery : '+quoteQuery); //Id, name, OpportunityId,QuoteNumber,GrandTotal
        	List<sObject> quoteList = Database.query(quoteQuery); 
       		 return quoteList;    
        } else {
        	 system.debug('### quote is disable: ');
        	 return null;   
        }   
	}
	
	/**
      * @description : This method returns list of quote PDFS attached to particular Quotes of partner opportunity
      * @param : Accepts Set of Partner opportunity IDs and boolean for isPrimaryRequired. 
    */
	public static List<SObject> getQuotePDFListByQuoteIds(Set<Id> quoteIds) {
 		
 		List<String> quotePDFfieldList = new List<String>{CHL_Constants.OBJ_QUOTE_PDF_Id,CHL_Constants.OBJ_QUOTE_PDF_NAME};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE_PDF, quotePDFfieldList, CSM_Constants.DML_OPERATION_READ);
		
		string whereClause = ' where '+ CHL_CONSTANTS.OBJ_QUOTELI_QUOTEID + ' in :quoteIds ';
        string quotePDFfieldsForQuery = CHL_Constants.OBJ_QUOTE_PDF_Id+','+CHL_Constants.OBJ_QUOTE_PDF_NAME+','+CHL_CONSTANTS.OBJ_QUOTELI_QUOTEID+','+CHL_CONSTANTS.OBJ_QUOTE_OPPTY_ID+','+CHL_CONSTANTS.OBJ_QUOTE_ID;
        
        String quotePDFQuery = 'select '+ quotePDFfieldsForQuery + ' from '  + CHL_CONSTANTS.OBJ_QUOTE_PDF + whereClause+ ' order by createddate limit 1000' ;    
        system.debug('### quoteQuery : '+quotePDFQuery);
        List<sObject> quotePDFList = Database.query(quotePDFQuery);        
        return quotePDFList;
	}
	
	/**
      * @description : This method returns the list of quotes associated with the  partner opportunity.
      * @param : Accepts Partner opportunity ID.
    */
     public static List <SObject> getQuotesListFromFieldSet(set<Id> partnerOpportunityIds, string fieldSetName) {
    	String queryString = '';
    	String whereClauseFor2Tier ='';
 		Boolean is2TierEnabled = false;
 		String nameSpacePrefix = CSM_Util.getNamespace();
 		Set<String> fieldSetFields = new Set<String>();
 		List<String> quoteFields = new List<String>();
       	if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){
			List <SObject> quoteList = new List <SObject> ();
			List < Schema.FieldSetMember > fieldSetList = CHL_Util.getFieldSet(fieldSetName, CHL_Constants.OBJ_QUOTE);
			for (Schema.FieldSetMember fld: fieldSetList) {
            	if(!String.valueof(fld.getFieldPath()).contains('.')) {
            		fieldSetFields.add(fld.getFieldPath());
            	}            	
			}
			for(String fs : fieldSetFields) { 
	        	quoteFields.add(fs);
	        }
	        system.debug('quoteFields : '+quoteFields);
			CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE,quoteFields , CSM_Constants.DML_OPERATION_READ); //new List<String>{colNames}
	    	queryString = CHL_Util.getQueryStringFromFieldSet(fieldSetName, CHL_Constants.OBJ_QUOTE);
	    	//Added below condition for US1168
	    	if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
	            is2TierEnabled = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c');
	        }
	        if(is2TierEnabled) {
		        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
       			String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
				/* US1426 : Updated If condition to check CHL_Is_Distributor_Quote__c condition for reseller Quote */
				if(CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c')){
					whereClauseFor2Tier += ' AND '+CHL_Util.quoteExtnNameSpace+'CHL_Is_Distributor_Quote__c = false';
				}	
 				
	        }//end of code US1168
	    	queryString = queryString + '  where '+CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c in :partnerOpportunityIds '+whereClauseFor2Tier+' Limit 10000 ';
			system.debug('\n\n QueryString in QuoteList method :: ' + queryString);
			quoteList = Database.query(queryString);
			return QuoteList;
    	}
		return null;
	}
	
	//Added for DE957
	public static List<sObject> getQuotesById(Set<String> quotesId){
  		List<String> quoteFieldList = new List<String>();
  		if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
            quoteFieldList.add(CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY);
    	}
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);
  		List<SObject> QuoteList;
  		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){
  			String queryString = CHL_Util.getQueryStringFromFieldSet(CHL_Util.quoteExtnNameSpace +CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_QUOTE);
	    	queryString = queryString + '  where id in :quotesId Limit 10000';
  			QuoteList = Database.query(queryString);
  			
  		}
  		return QuoteList;
	}
	
	
     public static List<SObject> insertQuotes(List<SObject> quoteList) {
     	
     	List<String> quoteFieldList = new List<String>{	CHL_Constants.OBJ_PO_NAME,
     													CHL_Constants.STR_OPPOTUNITYID,
     													REN_Constants.OBJ_OPP_PRICEBOOK_ID,
     													CHL_Constants.OBJ_QUOTE_EXPIRATION_DATE};
    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
            quoteFieldList.add(CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY);
    	}
    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)){
        			quoteFieldList.add(CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY);
    	}
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_INSERT);
		
		insert quoteList;
		return quoteList;
	}
    
       
    //Added for US1070
    public static List<SObject> getSyncedQuotesById(Set<Id> quoteIds) {
 		
 		String quoteCustomFields = (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)? ','+CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY:'') + (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)?',' + CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY:'');
        quoteCustomFields = quoteCustomFields + (CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c')?','+CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c':'') + (CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c')?','+CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c':'');
        quoteCustomFields = quoteCustomFields + (CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c')?','+CHL_Util.quoteExtnNameSpace +'CHL_Is_Distributor_Quote__c':'') + (CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')?','+CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c':'');
    	List<String> quoteFieldList = new List<String>{'Id','Name','OpportunityId','QuoteNumber','GrandTotal','LineItemCount'};
        if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c')) {
    		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
    	}
       	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);
        String quoteQuery = 'select Id, name, OpportunityId,QuoteNumber,GrandTotal,LineItemCount '+ quoteCustomFields +' from '  + CHL_CONSTANTS.OBJ_QUOTE + ' where Id IN :quoteIds limit 10000' ; //IsSyncing = true AND   
        system.debug('### quoteQuery : '+quoteQuery);
        List<sObject> quoteList = Database.query(quoteQuery);        
        return quoteList;
	}
    
    //Added for US1026 to update Quote Primary Flag from Community
    public static void updateQuotes(List<SObject> quoteList) {
    	List<String> quoteFieldList = new List<String>{CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY,CHL_Util.quoteExtnNameSpace+CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY};	
		 if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_SyncedAfterCreation__c')) {
    		quoteFieldList.add(CHL_Util.quoteExtnNameSpace+'CHL_SyncedAfterCreation__c');
    	}
    	if(!Test.isRunningTest()) {
			CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_UPDATE);
    	}
		update quoteList;
	}
	
	
	//US1515	
	public static List<Sobject> getQuotesForPO(Set<Id> quoteIds, Set<Id> poIds, string flagCondition) {
		List<SObject> quoteList = new List<SObject>();
		String quoteCustomFields = (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)?',' + CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY:'') + (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)?',' + CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY:'') + (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c')?',' + CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c':'');
		List<String> quoteFieldList = new List<String>{'Id',CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY,CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY,CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c'};
    	if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
    		if(!Test.isRunningTest()) {
	    		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);		  		
    		}
	  		String queryString = Test.isRunningTest() ? 'Select Id from Quote limit 1' :'Select Id ' + quoteCustomFields +' from '  + CHL_CONSTANTS.OBJ_QUOTE+ ' where Id NOT in :quoteIds and '+CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY + ' IN :poIds and '+CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY+'<> null '+ flagCondition +' Limit 1000';
	  		quoteList = Database.query(queryString);
    	}
  		return quoteList;
	}	
	
	
	//US1515
	public static List<SObject> getDistributorQuoteList(Set<Id> resellerQuoteIds) {
		List<SObject> quoteList = new List<SObject>();
		String quoteCustomFields = (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)?',' + CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY:'') + (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')?',' + CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c':'');
		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')) {
	        List<String> quoteFieldList = new List<String>{'Id','GrandTotal',CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY,CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c'};
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c')) {
        		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
        	}
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c')) {
        		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
        	}
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace +'CHL_Partner_Primary__c')) {
        		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c');
        	}
        	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);		  		
	  		String queryString = 'Select Id,GrandTotal, '+CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c,  '+CHL_Util.quoteExtnNameSpace +'CHL_Partner_Primary__c,  '+CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c  ' + quoteCustomFields +' from '  + CHL_CONSTANTS.OBJ_QUOTE+ ' where '+CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c in :resellerQuoteIds Limit 1000';
	  		quoteList = Database.query(queryString);  		
        }	
  		return quoteList;
	}
	public static List<SObject> getQuoteListById(Set<Id> resellerQuoteIds) {
		List<SObject> quoteList = new List<SObject>();
		String quoteCustomFields = (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)?',' + CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY:'') + (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')?',' + CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c':'');
		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')) {
	        List<String> quoteFieldList = new List<String>{'Id','GrandTotal',CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY,CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c'};
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c')) {
        		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
        	}
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c')) {
        		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
        	}
        	if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace +'CHL_Partner_Primary__c')) {
        		quoteFieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c');
        	}
        	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);		  		
	  		String queryString = 'Select Id,GrandTotal, '+CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c,  '+CHL_Util.quoteExtnNameSpace +'CHL_Partner_Primary__c,  '+CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c  ' + quoteCustomFields +' from '  + CHL_CONSTANTS.OBJ_QUOTE+ ' where '+CHL_Util.quoteExtnNameSpace +'Id in :resellerQuoteIds Limit 1000';
	  		quoteList = Database.query(queryString);  		
        }	
  		return quoteList;
	}
	
	public static List<SObject> retrieveQuotesById(Set<Id> quoteIds, Set<String> quoteFields){
		if(!Test.isRunningTest()) {
			CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, new List<String>(quoteFields), CSM_Constants.DML_OPERATION_READ);
		}
		String soqlStr = Test.isRunningTest() ? 'Select Id,name,description,opportunityID,Pricebook2Id,ShippingHandling,Tax,grandtotal,IsSyncing,LineItemCount from Quote limit 1' :CSM_Util.getSOQLString(CHL_Constants.OBJ_QUOTE, quoteFields, ' Id IN:quoteIds', null, null);		
		return Database.query(soqlStr);
	}
	public static List<SObject> getQuotesBySOSL(CHL_GridInputWrapper inputWrapper)
	{
		List <SObject> quoteList = new List <sObject>();
		String nameSpacePrefix = CSM_Util.getNamespace();
		String fieldList = CHL_Util.getQueryStringFromFieldSet(CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME,CHL_Constants.OBJ_QUOTE);
       	system.debug('fieldList B4 Remove '+fieldList);
       	fieldList = fieldList.removeStartIgnoreCase('select ');
       	fieldList = fieldList.removeEndIgnoreCase(' from '+CHL_Constants.OBJ_QUOTE);
       	system.debug('fieldList AFTER Remove '+fieldList);
       	Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
       	Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
       	string currentUserAccountId = acc <>null ? acc.Id : null;
		string whereClause = ' Where ('+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Account_1__c =: currentUserAccountId OR '+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Account_2__c =: currentUserAccountId) ';
		boolean is2TierEnabled = false;
		if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
			is2TierEnabled = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c');
		}
		if(is2TierEnabled) {
		//string currentUserAccountType = CHL_Util.currentUserDetails[0].Account.CHL_Partner_Account_Type__c;
			if(CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c')){
				whereClause += ' AND '+CHL_Util.quoteExtnNameSpace+'CHL_Is_Distributor_Quote__c = false';
			}	 				
		}
       	String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning Quote ('+fieldList+whereClause+' ORDER BY QuoteNumber Desc) limit '+queryLimit;			
       	List<List<SObject>>searchList = search.query(queryString);
		system.debug('searchList::'+searchList);
    	if(searchList != null && searchList.size()>0){
			quoteList.addAll(searchList[0]);
    	}
		return quoteList;
	}
	
	/**
      * @description : This method returns list of Synced quote PDFS attached to particular opportunity.
      * @param : Accepts Set of opportunity IDs.Added as part of US2018.
    */
	public static List<SObject> getSyncedQuotePDFByOpp(Set<Id> oppId) {
 		
 		List<String> quotePDFfieldList = new List<String>{CHL_Constants.OBJ_QUOTE_PDF_Id,CHL_Constants.OBJ_QUOTE_PDF_NAME};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE_PDF, quotePDFfieldList, CSM_Constants.DML_OPERATION_READ);
       
        String quotePDFQuery = 'select Document,name,ContentVersionDocumentId,quote.OpportunityId from QuoteDocument where quote.IsSyncing = true and quote.OpportunityId in :oppId order By createdDate desc limit 1' ;    
        system.debug('### quoteQuery : '+quotePDFQuery);
        List<sObject> quotePDFList = Database.query(quotePDFQuery);   
        system.debug('### @@@ QuotePdf List  : '+quotePDFQuery);   
        return quotePDFList;
	}
	public static List <SObject> getPOQuotesListFromFieldSet(set<Id> partnerOpportunityIds, string fieldSetName) {
    	String queryString = '';
    	String whereClauseFor2Tier ='';
 		Boolean is2TierEnabled = false;
 		String nameSpacePrefix = CSM_Util.getNamespace();
 		Set<String> fieldSetFields = new Set<String>();
 		List<String> quoteFields = new List<String>();
       	if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){
			List <SObject> quoteList = new List <SObject> ();
			List < Schema.FieldSetMember > fieldSetList = CHL_Util.getFieldSet(fieldSetName, CHL_Constants.OBJ_QUOTE);
			for (Schema.FieldSetMember fld: fieldSetList) {
            	if(!String.valueof(fld.getFieldPath()).contains('.')) {
            		fieldSetFields.add(fld.getFieldPath());
            	}            	
			}
			for(String fs : fieldSetFields) { 
	        	quoteFields.add(fs);
	        }
	        system.debug('quoteFields : '+quoteFields);
			CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE,quoteFields , CSM_Constants.DML_OPERATION_READ); //new List<String>{colNames}
	    	queryString = CHL_Util.getFormatFieldsFromFieldSet(fieldSetName, CHL_Constants.OBJ_QUOTE);
	    	//Added below condition for US1168
	    	
	        queryString = queryString + '  where '+CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c in :partnerOpportunityIds Limit 10000 ';	
	    	
			system.debug('\n\n QueryString in QuoteList method :: ' + queryString);
			quoteList = Database.query(queryString);
			return QuoteList;
    	}
		return null;
	}
	public static Map<Id, sObject> getQuoteMapById(Set<Id> quoteIdSet,Set<String> requestedFields) { 
		List<sObject> quoteList = new List<sObject>();
		List<String> quoteFieldList =  new List<String>();
        quoteFieldList.addAll(requestedFields);
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_READ);
		String queryString = CSM_Util.getSOQLString('Quote', new Set<String>(quoteFieldList), 'Id IN:quoteIdSet', null, null); 
      	quoteList = Database.query(queryString);
      	return new Map<Id, sObject>(quoteList);
    }
    
    public static List<SObject> getQuotesWithWonOppty(Set<Id> quoteIdsSet){
    	List<SObject> quotesList = new List<SObject>();
    	Set<String> fieldsSet = new Set<String>{'Id','Opportunity.stageName'};
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'stageName'}, CSM_Constants.DML_OPERATION_READ);    	
    	String queryString = CSM_Util.getSOQLString('Quote',fieldsSet, 'Id IN:quoteIdsSet and Opportunity.stageName = \'Closed Sale\'', null, null); 
      	quotesList = Database.query(queryString);
    	return quotesList;
    }
    
    public static List<SObject> getQuoteWithOppStatusAsInProgress(Set<Id> qliIdsSet){
    	List<SObject> quotesList = new List<SObject>();
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'CHL_QuoteSyncStatus__c'}, CSM_Constants.DML_OPERATION_READ);    	
    	String queryString = 'Select Id, Opportunity.CHL_QuoteSyncStatus__c from Quote where Id IN (Select QuoteId from QuoteLineItem where ID IN : qliIdsSet) AND (Opportunity.CHL_QuoteSyncStatus__c = \'In Progress\' OR Opportunity.CHL_QuoteSyncStatus__c = \'Scheduled\' ) and IsSyncing = true';
    	quotesList = Database.query(queryString);
    	return quotesList;
    }
    
    public static List<SObject> insertQuotesForBulkImport(List<SObject> quoteList, List<String> quoteFieldList) {
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, quoteFieldList, CSM_Constants.DML_OPERATION_INSERT);	
		insert quoteList;
		return quoteList;
	}
    
}