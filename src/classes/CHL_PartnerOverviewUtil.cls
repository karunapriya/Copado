/**
* @description    CHL_PartnerOverviewUtil class has methods required for the channel partner landing page
*/

public with Sharing class CHL_PartnerOverviewUtil{
  
  /**
  * @description : This method returns the data required for the expired opportunity matrix on channel partner overview page
  * @param : 
  */ 
      public Static List<CHL_OverviewWrapper.CHL_ExpiredMatrix> fetchExpiredMatrix(){
         List<CHL_OverviewWrapper.CHL_ExpiredMatrix> expiredOpptys = new List<CHL_OverviewWrapper.CHL_ExpiredMatrix>();

       
          Map<string,CHL_OverviewWrapper.CHL_ExpiredMatrix> oppWrapperMap = new map<string,CHL_OverviewWrapper.CHL_ExpiredMatrix>();
          
          //Query the parnter opportunties grouped by stages.
          List<AggregateResult> renOppList = CHL_PartnerOpportunityDataAccess.getAllExpiredPartnerOpportunities();
          Integer totalCount = 0;
          Decimal totalAmount = 0 ,exchangeRate = 1;
          
          //Fetch the muti currency org details
          String currencyName = UserInfo.getDefaultCurrency();
          String currencyCode=CSM_Util.convertCurrencyNameToSymbol(currencyName);
          Boolean isMultiCurrency = UserInfo.IsMultiCurrencyOrganization();
          
          //Check if the org is multi currency org or not.
          if(isMultiCurrency){
            exchangeRate = CSM_Util.getExchangeRateToCorpCurrency(currencyName);
          } 
          
          CHL_OverviewWrapper.CHL_ExpiredMatrix expMatOverall = new CHL_OverviewWrapper.CHL_ExpiredMatrix();
          expMatOverall.count = ''+totalCount;
          expMatOverall.name = Label.CSM_LBL_ALL;//CHL_COMMUNITY_OPPORTUNITIES
          expiredOpptys.add(expMatOverall);
          
          Decimal amount=0;
          //Schema.DescribeFieldResult fieldResult = CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe();
		  //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		  Map<String,String> picklistValueLabelMap = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe());
          for(AggregateResult ar:renOppList){
             CHL_OverviewWrapper.CHL_ExpiredMatrix expMat = new CHL_OverviewWrapper.CHL_ExpiredMatrix();
             expMat.count = ''+ar.get(CHL_CONSTANTS.EXP_MATRIX_COUNT);
             if(picklistValueLabelMap.containsKey(string.valueof(ar.get(CHL_CONSTANTS.EXP_MATRIX_STAGE)))) {
        		expMat.name = picklistValueLabelMap.get(string.valueof(ar.get(CHL_CONSTANTS.EXP_MATRIX_STAGE)));//plVal.getlabel();
      		 }
      		 amount = (Decimal)ar.get(CHL_CONSTANTS.EXP_MATRIX_AMOUNT);
             amount = (amount==null?0:amount);
             amount = (isMultiCurrency?exchangeRate*amount:amount);
             expMat.amount = currencyCode+''+ amount.setScale(2) ;
             expiredOpptys.add(expMat);
             totalCount += (Integer)ar.get(CHL_CONSTANTS.EXP_MATRIX_COUNT);
             totalAmount += (amount==null?0:amount.setScale(2));
          }
          
          expiredOpptys[0].count = ''+totalCount;
          
          expiredOpptys[0].amount =  currencyCode+''+totalAmount.setScale(2) +' '+currencyName ;
          
         return expiredOpptys;
      }//End of method
      
      //Method to construct whereCLause based on Chart Filters
      /****************Updated code for US119 *************************/    
     public Static String getChartFilterWhereClause(Set<String> quarterSet,Set<String> yearSet, Set<String> countrySet, Set<String> resellerRepSet, Set<String> distributerRepSet) {

		Map<String,String> queryParameterMap = new Map<String, String>();
		String countryValues = '';
		String resellerRepValues = '';
		String distributerRepValues = '';
		String quaterValues = '';
		String yearValues = '';
        
        //To add the  Quarter value in map
		if (quarterSet.size()>0) {
			for (String str: quarterSet) {
				String quarterNumber = '';
				if (str.startsWith('Q')) {
					quarterNumber = str.removeStartIgnoreCase('Q');
					quaterValues += String.escapeSingleQuotes(quarterNumber) + ',';
				} 		
			}
			if(quaterValues.contains(',')) {
				quaterValues = quaterValues.removeEnd(',');
			}
			queryParameterMap.put('Quarter', quaterValues);
		}
		//To add the Year in map
		if (yearSet.size()>0) {
			for (String str: yearSet) {
				yearValues += '\'' + String.escapeSingleQuotes(str) + '\'' + ',';
			}
			yearValues = yearValues.removeEnd(',');
			queryParameterMap.put('Year', yearValues);
		}
	
		if (!countrySet.contains(CHL_Constants.STR_ALL) && countrySet.size()>0) {
			for (String str: countrySet) {
				countryValues += '\'' + String.escapeSingleQuotes(str) + '\'' + ',';
			}
			countryValues = countryValues.removeEnd(',');
			queryParameterMap.put('Country', countryValues);
		}

		if (!resellerRepSet.contains(CHL_Constants.STR_ALL) && resellerRepSet.size()>0) {
			for (String str: resellerRepSet) {
				resellerRepValues += '\'' + String.escapeSingleQuotes(str) + '\'' + ',';
			}
			resellerRepValues = resellerRepValues.removeEnd(',');
			queryParameterMap.put('ResellerRep', resellerRepValues);
		}

		if (!distributerRepSet.contains(CHL_Constants.STR_ALL) && distributerRepSet.size()>0) {
			for (String str: distributerRepSet) {
				distributerRepValues += '\'' + String.escapeSingleQuotes(str) + '\'' + ',';
			}
			distributerRepValues = distributerRepValues.removeEnd(',');
			queryParameterMap.put('DistributerRep', distributerRepValues);
		}

		Integer counter = 1;
		String whereClause = '';
		
		for (String queryKey: queryParameterMap.keySet()) {

			if (queryKey == 'Quarter') {
				if (counter == queryParameterMap.size()) {
						whereClause += 'CHL_EQ__c in ('+ quaterValues + ' )' ;
					
				} else {
						whereClause += 'CHL_EQ__c in ('+ quaterValues + ' )'  + ' AND ';
					
				}
				counter++;
			}
			
			if (queryKey == 'Year') {
				if (counter == queryParameterMap.size()) {
						whereClause +='CHL_FY__c in ('+ yearValues + ' )' ;
				} else {
						whereClause += 'CHL_FY__c in ('+ yearValues + ' )'  + ' AND ';
					
				}
				counter++;
			}
			
			if (queryKey == 'Country') {
				if (counter == queryParameterMap.size()) {
					whereClause += '(CHL_Partner_Account_1__r.BillingCountry in (' + countryValues + ') OR CHL_Partner_Account_2__r.BillingCountry in (' + countryValues + ') ) ';
				} else {
					whereClause += '(CHL_Partner_Account_1__r.BillingCountry in (' + countryValues + ') OR CHL_Partner_Account_2__r.BillingCountry in (' + countryValues + ') ) AND ';
				}
				counter++;
			}
			
            if (queryKey == 'ResellerRep') {
				if (counter == queryParameterMap.size()) {
					whereClause += '(((CHL_Partner_Account_1_Contact__c  in (' + resellerRepValues + ')) AND (CHL_Partner_Account_1_Type__c = \'Reseller\')) OR ((CHL_Partner_Account_2_Contact__c  in (' + resellerRepValues + ')) AND (CHL_Partner_Account_2_Type__c = \'Reseller\')))';
				} else {
					whereClause += '(((CHL_Partner_Account_1_Contact__c  in (' + resellerRepValues + ')) AND (CHL_Partner_Account_1_Type__c = \'Reseller\')) OR ((CHL_Partner_Account_2_Contact__c  in (' + resellerRepValues + ')) AND (CHL_Partner_Account_2_Type__c = \'Reseller\'))) AND ';
				}
				counter++;
			}
			
			if (queryKey == 'DistributerRep') {
				if (counter == queryParameterMap.size()) {
					whereClause += '(((CHL_Partner_Account_1_Contact__c  in (' + distributerRepValues + ')) AND (CHL_Partner_Account_1_Type__c = \'Distributor\')) OR ((CHL_Partner_Account_2_Contact__c  in (' + distributerRepValues + ')) AND (CHL_Partner_Account_2_Type__c = \'Distributor\'))) ';
				} else {
					whereClause += '(((CHL_Partner_Account_1_Contact__c  in (' + distributerRepValues + ')) AND (CHL_Partner_Account_1_Type__c = \'Distributor\')) OR ((CHL_Partner_Account_2_Contact__c  in (' + distributerRepValues + ')) AND (CHL_Partner_Account_2_Type__c = \'Distributor\'))) AND ';
				}
				counter++;
			}
		}
        system.debug('\n\n Where Clause :: ' + whereClause);
		return whereClause;
	}
  
      /****************END********* US119 *************************/
      
  // @description : This method returns the details of partner opportunites i.e Reseller,Distributor and Counrty Returns in Map.
      
    public static Map< String, Map<String,String>> partnerOppInfo(){
        List<String> partnerOppColList = new  List<String>{  CHL_Constants.OBJ_PO_RESELLER_REP,
										CHL_Constants.OBJ_PO_PARTNER_ACC1_TYPE,
										CHL_Constants.OBJ_PO_PARTNER_ACC1,
		                                CHL_Constants.OBJ_PO_PARTNER_ACC2_TYPE,  
        	                           	'CHL_Partner_Account_1_Contact__r.name',
        	                           	'CHL_Partner_Account_2_Contact__r.name',
        	                           	'CHL_Partner_Account_1__r.BillingCountry',
            							'CHL_Partner_Account_2__r.BillingCountry'
        };
        
		List<CHL_Partner_Opportunity__c>  partnerOppList = CHL_PartnerOpportunityDataAccess.getPartnerOppDetails(partnerOppColList, '');
		
		Map<String,Map <String,String> > partnerOppInfoMap = new Map<String, Map <String,String> >();
		Map<String,String> resellerMap = new Map<String,String>();
		Map<String,String> distributorMap = new Map<String,String>();
		Map<String,String> countriesMap = new Map<String,String>();
		
		
		for(CHL_Partner_Opportunity__c opty : partnerOppList){
			if((opty.CHL_Partner_Account_1_Type__c) == CHL_Constants.STR_RESELLER){
				 resellerMap.put(opty.CHL_Partner_Account_1_Contact__c,opty.CHL_Partner_Account_1_Contact__r.name);
			}
			if((opty.CHL_Partner_Account_2_Type__c) == CHL_Constants.STR_RESELLER){
				resellerMap.put(opty.CHL_Partner_Account_2_Contact__c,opty.CHL_Partner_Account_2_Contact__r.name);
			}
		
			if((opty.CHL_Partner_Account_1_Type__c) == CHL_Constants.STR_DISTRIBUTOR){
				distributorMap.put(opty.CHL_Partner_Account_1_Contact__c,opty.CHL_Partner_Account_1_Contact__r.name);
			}
		
			if((opty.CHL_Partner_Account_2_Type__c) == CHL_Constants.STR_DISTRIBUTOR){
				distributorMap.put(opty.CHL_Partner_Account_2_Contact__c,opty.CHL_Partner_Account_2_Contact__r.name);
			}
			
			if((opty.CHL_Partner_Account_1__r.BillingCountry) != null){
				countriesMap.put(opty.CHL_Partner_Account_1__r.BillingCountry,opty.CHL_Partner_Account_1__r.BillingCountry);
			}
			
			if((opty.CHL_Partner_Account_2__r.BillingCountry) != null){
				countriesMap.put(opty.CHL_Partner_Account_2__r.BillingCountry,opty.CHL_Partner_Account_2__r.BillingCountry);
			}
		}
		
		partnerOppInfoMap.put(CHL_Constants.STR_RESELLER,resellerMap);
		partnerOppInfoMap.put(CHL_Constants.STR_DISTRIBUTOR,distributorMap);
		partnerOppInfoMap.put(CHL_Constants.STR_COUNTRY,countriesMap);
		
		return  partnerOppInfoMap;
		}
		
   	/**
 	 * @description : This method returns the stage picklist values for partner opportunity
  	*/ 
	/*public Static List<String> fetchStagePicklistValues(){
		  //Added below code as per US896 to fetch only sales stages that are avialble for community users & Updated for US1379
          List <string> stageNameList = new List <string>();
          stageNameList.addall(new List<String>(CHL_Util.getTranslatedAvailableSalesStage()));
          return stageNameList;
	}*/
	
	//Below method is created as part of US1379, to translate Sales Stages as per User's Language. It will be used to show available sales stages in Oppty Grid.
    public static List<CHL_PartnerOpportunityFilters.CHL_Stages> getTranslatedAvailableSalesStage()    {
        List<CHL_PartnerOpportunityFilters.CHL_Stages> availableStages = new List<CHL_PartnerOpportunityFilters.CHL_Stages>();
        Map<String,String> picklistValueLabelMap = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe());
      	for(String str : CHL_Util.getAvailableSalesStage()){
  			CHL_PartnerOpportunityFilters.CHL_Stages oppStage = new CHL_PartnerOpportunityFilters.CHL_Stages();   
  			if(picklistValueLabelMap.containsKey(str)) {
    			oppStage.id = str;//plVal.getvalue();
    			oppStage.name = picklistValueLabelMap.get(str);//plVal.getlabel(); 
    			availableStages.add(oppStage);
    			//break;
  			}
    	}
        return availableStages;
    }
  	/**
  	* @description : This method returns the data of contacts of looged in users account as reseller reps and distributor reps
 	*/ 
	public Static CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions fetchResellerDistributorReps(){
        
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        Id currentUserAccountId =  acc <>null ? acc.id : null; //CHL_Util.currentUserDetails[0].Contact.AccountId;//CHL_Util.fetchAccountIdOfUser(UserInfo.getUserId());
        List<Contact> contactList = CSM_ContactDataAccess.getContactListByAccount(currentUserAccountId);
        List <CHL_PartnerOpportunityFilters.CHL_ResellerReps> resellerRepList = new List <CHL_PartnerOpportunityFilters.CHL_ResellerReps>();
        List <CHL_PartnerOpportunityFilters.CHL_DistributorReps> distributorRepList = new List <CHL_PartnerOpportunityFilters.CHL_DistributorReps>();
        
        CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions bulkUpdateOptions = new CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions();
        
        CHL_PartnerOpportunityFilters.CHL_ResellerReps resNoneValue = new CHL_PartnerOpportunityFilters.CHL_ResellerReps();
        resNoneValue.id = '0';
        resNoneValue.name = 'None';
        
        CHL_PartnerOpportunityFilters.CHL_DistributorReps disNoneValue = new CHL_PartnerOpportunityFilters.CHL_DistributorReps();
        disNoneValue.id = '0';
        disNoneValue.name = 'None';
        
        resellerRepList.add(resNoneValue);
        distributorRepList.add(disNoneValue);
        
        for (Contact con: contactList) {
            CHL_PartnerOpportunityFilters.CHL_ResellerReps resellerRepObj = new CHL_PartnerOpportunityFilters.CHL_ResellerReps();
            resellerRepObj.id = con.Id;
            resellerRepObj.name = con.name;
            resellerRepList.add(resellerRepObj);
            
            CHL_PartnerOpportunityFilters.CHL_DistributorReps distributorReps = new CHL_PartnerOpportunityFilters.CHL_DistributorReps();
            distributorReps.id = con.Id;
            distributorReps.name = con.name;
            distributorRepList.add(distributorReps);
        }
        
        bulkUpdateOptions.resellerReps = resellerRepList;
        bulkUpdateOptions.distributorReps = distributorRepList;
        
        return bulkUpdateOptions;
     }
     
	/**
	* @description : This method returns data to populate new request,picklist values from case object are returned
	*/ 
    public static CHL_NewRequestResponseWrapper getFieldOptions(){

		CHL_NewRequestResponseWrapper  respWrp = new CHL_NewRequestResponseWrapper();
		//Populate related to picklist and also quote & service contract check if they exist in the org.
		CHL_NewRequestResponseWrapper.CHL_RelatedTo relateToObj;   
		for(String rel : CHL_Constants.RELATED_TO){
			if(rel.equalsIgnoreCase(CHL_Constants.OBJ_QUOTE)){
				if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)){
					relateToObj = new CHL_NewRequestResponseWrapper.CHL_RelatedTo();
					relateToObj.id = rel;
					relateToObj.value = Label.CHL_LBL_QUOTE;
					respWrp.relatedTo.add(relateToObj); 
				}
			} else if(rel.equalsIgnoreCase(CHL_Constants.STR_SERVICE_CONTRACT)){
				if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT)){
					relateToObj = new CHL_NewRequestResponseWrapper.CHL_RelatedTo();
					relateToObj.id = rel;
					relateToObj.value = CHL_Constants.OBJ_SERVICECONTRACT;
					respWrp.relatedTo.add(relateToObj); 
				}
			} else if(rel.equalsIgnoreCase(REN_Constants.OBJ_OPPORTUNITY)){
				relateToObj = new CHL_NewRequestResponseWrapper.CHL_RelatedTo();
				relateToObj.id = rel;
				relateToObj.value = Label.REN_LBL_OPPTY;
				respWrp.relatedTo.add(relateToObj); 
			} else if(rel.equalsIgnoreCase(REN_Constants.OBJ_ASSET)){
				relateToObj = new CHL_NewRequestResponseWrapper.CHL_RelatedTo();
				relateToObj.id = rel;
				relateToObj.value = Label.CHL_ASSET;
				respWrp.relatedTo.add(relateToObj); 
			}
		}
	    //Populate priority picklist
		Schema.DescribeFieldResult priorityFldDesc = Schema.sObjectType.Case.fields.Priority;
		List<Schema.PicklistEntry> prioVal = priorityFldDesc.getPicklistValues();
		CHL_NewRequestResponseWrapper.CHL_Priority priorityObj;
		Map<String,String> pickListValueMap =  populatePickListValues(prioVal);
		for(String  priorityValue : pickListValueMap.keySet()){
			priorityObj = new CHL_NewRequestResponseWrapper.CHL_Priority();
			priorityObj.id = priorityValue;
			priorityObj.value = pickListValueMap.get(priorityValue);
			respWrp.priority.add(priorityObj);
		}
		Schema.DescribeFieldResult reqTypeFldDesc = Schema.sObjectType.Case.fields.CHL_CaseSubtype__c;
		List<Schema.PicklistEntry> reqTypeVals = reqTypeFldDesc.getPicklistValues();
		Map<String,String> pickListValueMap1 =   populatePickListValues(reqTypeVals);
		CHL_NewRequestResponseWrapper.CHL_RequestType reqestTypeObj;
		for(String  requestType : pickListValueMap1.keySet()){
			reqestTypeObj = new CHL_NewRequestResponseWrapper.CHL_RequestType();
			reqestTypeObj.id = requestType;
			reqestTypeObj.value = pickListValueMap1.get(requestType);
			respWrp.requestType.add(reqestTypeObj);
		}
		system.debug('\n\n @@@@@@ getFieldOptions :: ' + JSON.serialize(respWrp));
		return respWrp;
	}
	//Neet to replace the function from populatePickListValues
	private static List<String> populatePicklist(List<Schema.PicklistEntry> pickValList){
		List<String> picklistValList = new List<String>();
		for( Schema.PicklistEntry pickVal : pickValList){
      		picklistValList.add(pickVal.getLabel());
   		}
   		return picklistValList;
	}
	
	public static Map<String,String> populatePickListValues(List<Schema.PicklistEntry> pickValList){
		Map<String,String> picklistValueMap = new Map<String,String>();
		List<String> picklistValList = new List<String>();
		for( Schema.PicklistEntry pickVal : pickValList){
      		picklistValueMap.put(pickVal.getValue(),pickVal.getLabel());
   		}
   		return picklistValueMap;
	}
	
	/**
    * @description : This method inserts new request i.e case. Added for US852.
    */
	public static Object saveRequest (String newRequest){
    	
    	String relRec ='';
    	String msg = '';
    	CHL_NewRequestCreationWrapper newRqstWrper = (CHL_NewRequestCreationWrapper)JSON.deserialize(newRequest,CHL_NewRequestCreationWrapper.class);
    	
    	Case cs = new Case();
    	if(newRqstWrper.type != null){
    		cs.CHL_CaseSubtype__c = newRqstWrper.type.Id;
    	}
    	cs.AccountID = newRqstWrper.account.Id;	
    	cs.Type = CHL_Constants.STR_RENEWAL_SALES_REQUEST; //updated for translation.
    	//cs.Type = 'Renewal Sales Request';
    	
    	if(String.isNotBlank(newRqstWrper.subject)){
    		cs.Subject = newRqstWrper.subject;	
    	}
    	if(newRqstWrper.relatedObject != null && String.isNotBlank(newRqstWrper.relatedObject.Id)&& String.isNotBlank(newRqstWrper.relatedObject.Value)){
    		relRec = newRqstWrper.relatedObject.Id+newRqstWrper.relatedObject.Value;
    	}
    	
    	if(String.isNotBlank(newRqstWrper.message)){
    		msg = newRqstWrper.message;
    	}
    	cs.CHL_Related_To_Text__c = relRec;
    	cs.Description = msg;
    	
    	if(newRqstWrper.priority != null){
    		cs.Priority = newRqstWrper.priority.id;	
    	} 
    	CHL_NewRequestCreationResponseWrapper rqstRspnse = new CHL_NewRequestCreationResponseWrapper();
    	try {
    		List<Case> caseLst = CSM_CaseDataAccess.insertCases(new List<Case>{cs});
    		if(CHL_Util.isOWDForCASEPrivate() ){ 
    			//Id userAccountId = CHL_Util.currentUserDetails[0].Contact.AccountId;
    			Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');  		
    			List<sObject> caseShareList = new List<sObject>();
	    		for (User usr: CHL_Util.getUsersForAccount(acc.Id)) {
	    			sObject caseShareObj = Schema.getGlobalDescribe().get('CaseShare').newSObject();
                    caseShareObj.put(CHL_CONSTANTS.STR_USERGROUPID , usr.Id) ;                
                    caseShareObj.put(CHL_CONSTANTS.STR_ROWCAUSE , 'Manual') ; 
                    caseShareObj.put('CaseId' , caseLst[0].id) ;
                    caseShareObj.put('CaseAccessLevel', CHL_CONSTANTS.STR_EDIT) ; 
                    caseShareList.add(caseShareObj);
	    		}
	    		insert caseShareList;
    		}
    		if(!caseLst.isEmpty()){
    			rqstRspnse.recordId = caseLst[0].id;
    		}
			rqstRspnse.errorMessage = '';
			rqstRspnse.success = true;
			
			//assign case to queue here
			RecordType rtObj = database.query('SELECT Id FROM RecordType WHERE SobjectType = \'Case\' AND (Name = \'Channel Sales Request\')');
	    	List<QueueSobject> queueObjlist = database.query('SELECT QueueId FROM QueueSobject WHERE SobjectType = \'Case\' AND (Queue.Name = \'Channel Sales Request\') Limit 1');
	        cs.put(REN_Constants.OBJ_CASE_REC_TYPE, rtObj.Id);
	        if(queueObjlist != null && !queueObjlist.isEmpty()) {
	        	caseLst[0].put('OwnerId', queueObjlist[0].QueueId);
	      	} 
	      	CSM_Constants.CASE_TRIGGER = false;
	      	update caseLst[0];
    	}
    	catch (exception ex){
    		rqstRspnse.recordId = '';
			rqstRspnse.errorMessage = ''+ex;
			rqstRspnse.success = false;
    	}
    	return rqstRspnse;
    }
    
    /**
    * @description : This method takes input as search string and returns the matched Object Details .
    *				Objects supported : Account,Asset,Service Contract,Quote
    *				Returns id,value
    *               Added for US852.
    */
    public static Object searchRelatedTo(String srch){
    	String queryString;
    	String accFilter = 'accountId =: accountId';
    	CHL_RelatedToSearchResponse resp;
    	String nameSpacePrefix = CSM_Util.getNamespace();
    	String quoteExtnNameSpace = CHL_Util.quoteExtnNameSpace;
    	List<SObject> sobjList = new List<SObject>();
    	List<CHL_RelatedToSearchResponse> respList = new List<CHL_RelatedToSearchResponse>();
	    system.debug('##srch : '+srch);
	    CHL_RelatedToSearchRequest srchReq = (CHL_RelatedToSearchRequest)JSON.deserialize(srch,CHL_RelatedToSearchRequest.class);
	    //CHL_RelatedToSearchRequest.objectType objType = new CHL_RelatedToSearchRequest.objectType();
    	system.debug('##srchReq : '+srchReq);
    	String obj = srchReq.objectType;
    	String searchAcc = srchReq.searchString;
    	String accountId = srchReq.accountId;
    	
    	if(String.isNotBlank(obj)&& String.isNotBlank(searchAcc) && String.isNotBlank(accountId)){
    		searchAcc = String.escapeSingleQuotes(searchAcc);
    		accountId = String.escapeSingleQuotes(accountId);
			if (CHL_Constants.STR_SERVICE_CONTRACT.equalsIgnoreCase(srchReq.objectType)){
    			obj = CHL_Constants.OBJ_SERVICE_CONTRACT;
			}
    		else if(CHL_Constants.OBJ_OPPORTUNITY.equalsIgnoreCase(srchReq.objectType)){
    			obj = nameSpacePrefix + CHL_Constants.OBJ_PARTNER_OPPORTUNITY;  
    			accFilter = 'CHL_Opportunity__r.accountId =: accountId';
    		}
    		if(searchAcc != null && searchAcc.length() > 1){
    			String whereClause = '';
    			Boolean is2TierEnabled = false;
    			List <CHL_Opportunity_Status_Log__c> opptyStatusList = CHL_OpptyStatusLogDataAccess.opptyStatusLogList;
    			if(opptyStatusList != null && !opptyStatusList.isEmpty()){
    				is2TierEnabled = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c');
    			}
    			List<User> currentUserDetails = CHL_Util.currentUserDetails;
                Account acc = (Account)currentUserDetails[0].getSobject('Account');
                String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
    			if(is2TierEnabled && !currentUserDetails.isEmpty() && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c')){
    				//string currentUserAccountType = currentUserDetails[0].Account.CHL_Partner_Account_Type__c;
					if(CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType) && CHL_Constants.OBJ_QUOTE.equalsIgnoreCase(srchReq.objectType)){
						//whereClause = '('+quoteExtnNameSpace+'CHL_Partner_Account_1_Type__c =\''+CHL_Constants.STR_RESELLER +'\'OR '+quoteExtnNameSpace+'CHL_Partner_Account_2_Type__c =\''+CHL_Constants.STR_RESELLER+'\')';
						whereClause = quoteExtnNameSpace+'CHL_Is_Distributor_Quote__c = false';
					}
    			}
    			queryString = 'FIND\''+ searchAcc +'*\' IN NAME Fields Returning '+ obj +'(Id,Name Where '+(String.isNotBlank(whereClause) ? whereClause+' AND '+accFilter : accFilter)+')';
    			system.debug('queryString::'+queryString);
		    	List<List<SObject>>searchList = search.query(queryString);
	    		if(searchList != null && searchList.size()>0){
	    			sobjList.addAll(searchList[0]);
    			}
    		}
    		for(SObject sobj: sobjList){
		    	resp = new CHL_RelatedToSearchResponse();
		   		resp.value = (String)sobj.get('Name');
				resp.Id = sobj.id;
				respList.add(resp);
			}
	    }
    	return 	respList;
    }
    
   
}