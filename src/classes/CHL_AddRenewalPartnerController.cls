public with sharing class CHL_AddRenewalPartnerController {
    
    public CHL_Partner_Opportunity__c partnerOppObj  {get; set;}
    private Attachment attach {get;set;}
    public transient Blob attachFile{get;set;}
    public transient String fileName{get;set;} //transient
    public Note note {get;set;}
    public list<REN_Renews_To__c>  partnerRenewalRelationshipList {get; set;}
    public list<RenRelationshipLineItemsWrapper> renRelLineItemWrapperList {get; set;}
    public list<OpportunityLineItem> oppLIList {get; set;}
    public List<OpportunityProductWrapper> oppProductWrapperList {get; set;}
    public List<Opportunity> OppDetailList {get; set;}
    public List<Opportunity> oppList {get; set;}
    public String oppID{get; set;}
    public String partnerOppID{get; set;}
    public String noteText{get; set;}
    public Boolean isAllPreviousTermsSelected{get;set;}
    public Boolean isEntitlementEnabled{get;set;}
    public Boolean hasChannelAccess{get;set;}
    public Boolean hasOppAccess{get;set;}
    public string syncingVaule{get;set;}
    public List<Id> publicGroupIds {get; set;}
    public Boolean is2TierEnabled{get;set;}
    private string nameSpacePrefix;
    public boolean hasIncumbentPO{get;set;}
    private List<CHL_Partner_Opportunity__c> poList;
    public Boolean isQLIFromRLI{get;set;}
    private boolean hasIncumbentPOsOnOppty = false;
    
    private final String SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE = 'First_Quote_Completed_Date__c';
    private final String SSL_ZTH_COMMIT_LEVEL = 'Commit_Level__c';
    private final String CHL_COLOR_LEVEL = 'CHL_Color_Commit__c';
    private final String CHL_FIRST_QUOTE_COMPLETED_DATE = 'CHL_First_Quote_Completed_Date__c';
    
    public List<SelectOption> getsyncingOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(' ',Label.CSM_VAL_NONE)); 
        options.add(new SelectOption(CHL_Constants.SYNCING_OPTION_TO_MO,Label.CHL_SYNCING_TO_MASTER_OPTY)); 
        options.add(new SelectOption(CHL_Constants.SYNCING_OPTION_FROM_MO,Label.CHL_SYNCING_FROM_MASTER_OPTY));          
        return options; 
    }
   
   public CHL_AddRenewalPartnerController()
   {} 
  
   public CHL_AddRenewalPartnerController(ApexPages.StandardSetController standardSetController)
   {
        this.hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
        hasIncumbentPO=false;
        this.hasOppAccess = true;
        oppID = ApexPages.currentPage().getParameters().get('Id');
        oppID = String.escapeSingleQuotes(oppID);
        Set<ID> recordIds = new set<ID>();
        recordIds.add(oppID);
        String userID = string.valueOf(UserInfo.getUserId());
        Map<Id,boolean> accessRecordMap = CSM_AccessController.hasEditRecordAccess(recordIds,userID);
        nameSpacePrefix = CSM_Util.getNamespace();
            
        if(this.hasChannelAccess){  
           if(accessRecordMap.get(oppID)){
                attach = new Attachment();
                this.isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
                //Added for US1194
                is2TierEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty() ? (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c') : false;
                boolean isIncumbentEnabled = CSM_Admin__c.getOrgDefaults().CHL_Restrict_Multiple_Incumbent_On_PO__c;
		    	if(isIncumbentEnabled){
		    		//poList = new list<CHL_Partner_Opportunity__c>();
		    		List<String> partnerOppColList = new  List<String>{'CHL_Opportunity__c', CHL_Constants.OBJ_PO_INCUMBENT};
		    		String whereCondition = ' where CHL_Opportunity__c= \''+oppID+'\' and CHL_Incumbent__c = true';
		    		poList = CHL_PartnerOpportunityDataAccess.getPartnerOppDetails(partnerOppColList, whereCondition);
		    		if(poList != null && !poList.isEmpty()){
		    			hasIncumbentPOsOnOppty = true; 		
		    		}     		   		
		    	} 
                
                renRelLineItemWrapperList = new  list<RenRelationshipLineItemsWrapper>();
                OppDetailList  = new List<Opportunity>();
                String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
                set<String> fldList=new set<String>{'Name','Amount','CloseDate','Probability','StageName','REN_Earliest_Expiration_Date__c','Pricebook2Id'};
                if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +SSL_ZTH_COMMIT_LEVEL)) {
            		fldList.add(solnExtnNamespace +SSL_ZTH_COMMIT_LEVEL);
        		}
        		if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE)) {
             		fldList.add(solnExtnNamespace +SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE);
       			}
                set<string> refFields=new set<String>{'Account.Name'};
                OppDetailList= REN_OpportunityDataAccess.getOpportunityById(new set<string>{oppID},fldList,refFields);
                
                partnerOppObj = new  CHL_Partner_Opportunity__c(CHL_Opportunity__c = oppID);
                partnerRenewalRelationshipList = new list<REN_Renews_To__c>();
                partnerRenewalRelationshipList = CHL_PartnerOpportunityDataAccess.getRenewedRelationsDetailByOppId(oppID);
                
                isAllPreviousTermsSelected = true;
                if(!partnerRenewalRelationshipList.isEmpty()){
                    for (REN_Renews_To__c renObj : partnerRenewalRelationshipList){
                        renRelLineItemWrapperList.add(new RenRelationshipLineItemsWrapper(renObj));
                    }
                }
                     
                if(!isEntitlementEnabled){
                    List<RenRelationshipLineItemsWrapper> renAssetList = new List<RenRelationshipLineItemsWrapper>();
                        for(RenRelationshipLineItemsWrapper r : renRelLineItemWrapperList){
                            if(r.renLineObj.REN_Asset__c != null){
                                renAssetList.add(r);
                            }
                        }
                    renRelLineItemWrapperList.clear();
                    renRelLineItemWrapperList =  renAssetList ;
                }
                              
                //set<String> oppIDs = new set<String>{oppID};
                list<Ren_Renews_To__c> renOppList=REN_RenewRelationshipDataAccess.getRenewalRelationshipForOppty(new set<String>{oppID});                
                list<OpportunityLineItem> oppLIList = REN_OpportunityLineItemDataAccess.getOLIByOpportunity(new set<String>{oppID});
                Map<String,REN_Renews_To__c> renewalRelMap = new Map<String,REN_Renews_To__c>(renOppList);
                oppProductWrapperList = new List<OpportunityProductWrapper>();
                if(oppLIList!= null){
                    for(OpportunityLineItem oli :oppLIList ){
                        oppProductWrapperList.add(new OpportunityProductWrapper(oli, renewalRelMap));
                    }
                }
                
                
                
                //US1623 
                try{
                    REN_Field_Mappings__c fieldMapping = [SELECT Id, REN_Default_Value__c,REN_Field_Data_Type__c, REN_From_Field_API_Name__c, REN_From_Object_Api_Name__c, REN_To_Field_API_Name__c, REN_To_Object_API_Name__c FROM REN_Field_Mappings__c where REN_From_Object_Api_Name__c ='Opportunity' AND REN_To_Object_API_Name__c =:CHL_Constants.PARTNER_OPPORTUNITY_FROM_NAME];
                    
                    
                    if(fieldMapping != null){
                        if(fieldMapping.REN_Default_Value__c!=null && fieldMapping.REN_Default_Value__c!=''){
                            partnerOppObj.Name = fieldMapping.REN_Default_Value__c;
                        }else{
                           SObject opp = Database.query('Select '+fieldMapping.REN_From_Field_API_Name__c
                               +' from Opportunity where id = \''+String.escapeSingleQuotes(oppID)+'\'');
                            partnerOppObj.Name = String.valueOf(opp.get(fieldMapping.REN_From_Field_API_Name__c));
                        }
                    }
                }catch(Exception e){
                    System.debug('No Row found for mapping');
               }
              //partnerOppObj.Name = oppDetailList[0].name+'-'+oppDetailList[0].Account.name;
              //partnerOppObj.Name = (partnerOppObj.Name.length()<=80?partnerOppObj.Name:partnerOppObj.Name.subString(0,80));
            }else {
                    this.hasOppAccess = false;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,Label.CHL_LBL_INSUFFICIENT_ACCESS);
                    ApexPages.addMessage(msg);
            }
        }else{
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,SS_Constants.SS_NO_LICENSE_MSG));
        }
    }
    
    public void validatePopup(){
    	//boolean isIncumbentEnabled = CSM_Admin__c.getOrgDefaults().CHL_Restrict_Multiple_Incumbent_On_PO__c;
    	if(hasIncumbentPOsOnOppty && partnerOppObj.CHL_Incumbent__c == true){
    			hasIncumbentPO = true; 		    	   		   		
    	}else{
           hasIncumbentPO = false; 
        } 
    	//system.debug('poList :: '+poList+':: \n hasIncumbentPOsOnOppty '+hasIncumbentPOsOnOppty);  	
    }
    
    public void cancelIncumbent(){
    	partnerOppObj.CHL_Incumbent__c = false; 
    }
    
    private static void resetIncumbent(list<CHL_Partner_Opportunity__c> poList){
    	List<CHL_Partner_Opportunity__c> resetPOList = new List<CHL_Partner_Opportunity__c>();
    	if(poList != null && !poList.isEmpty()){
    		for (CHL_Partner_Opportunity__c obj: poList) {
				obj.CHL_Incumbent__c = false;
				resetPOList.add(obj);
			}											
		}
		if (!resetPOList.isEmpty()) {
        	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
			CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
			CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(resetPOList);
		}   	
    }
    
    public pagereference save(){ 
    	boolean isMinRowSelected =false; 
        for(RenRelationshipLineItemsWrapper r : renRelLineItemWrapperList){
            if(r.isSelected == true){
              isMinRowSelected = true;
              break;
            }
        }
        if(renRelLineItemWrapperList.size()>0 && !isMinRowSelected){
            attach.body = null;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,Label.CHL_LBL_LINE_ITEM_VALIDATION);
            ApexPages.addMessage(msg);
            return null;
        }
        
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)){
            Integer numberDaysDue = 0;
            for (OpportunityProductWrapper oppWrapperObj: oppProductWrapperList) {
                    numberDaysDue = 0;
                    if (oppWrapperObj.isSelected == true) {
                        if (oppWrapperObj.renewedOLI.REN_Start_Date__c != null && oppWrapperObj.renewedOLI.REN_End_Date__c != null) {
                            numberDaysDue = oppWrapperObj.renewedOLI.REN_Start_Date__c.daysBetween(oppWrapperObj.renewedOLI.REN_End_Date__c);
                            if (numberDaysDue < 0) {
                                ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,Label.CHL_LBL_INVALID_START_DATE_VALIDATION);
                                ApexPages.addMessage(msg);
                                return null;
                            }
                        }
                    }
            }
        }
        Savepoint sp;
        Id partnerAcc1;
        Id partnerAcc2;
        pagereference detailPage = null;
        try{
            sp = Database.setSavepoint();   
    		CSM_TriggerManager.disableAllTriggers();
               
            //1.To Create the Partner Opp records.
            List<sObject> sObjList = new List<sObject>();
            sObjList = createPartnerOpp();
            
            sObject sObj = sObjList[0];
                
            partnerOppObj = (CHL_Partner_Opportunity__c)sObj;
            partnerOppID = partnerOppObj.id;
                 
            //2.To Create the Partner Renewal Relationship records.
            createPartnerRenwalRelationship(new List<CHL_Partner_Opportunity__c>{partnerOppObj});
        
            if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) ){
            	//4.To create Quote Obj.
              	List<Sobject>  quoteList = createQuoteForPO(OppDetailList, new List<CHL_Partner_Opportunity__c>{partnerOppObj}, CHL_OpptyStatusLogDataAccess.opptyStatusLogList);
              	Sobject quoteObj = quoteList[0]; 
              	
            	//5.To create QuoteLineItem Objs.  
            	createQuoteLineItems(quoteList, isQLIFromRLI);
            	CHL_QuoteSyncHandler.rollupMsrpOnQuote(new Set<String>{(String)quoteList[0].get('Id')});
            	List<CHL_Partner_Opportunity__c> poListToUpdate =  updatePartnerOpptyFields(new Set<Id>{quoteObj.Id}, new List<CHL_Partner_Opportunity__c>{partnerOppObj});
            	if(poListToUpdate != null && !poListToUpdate.isEmpty()) {
		        	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
					CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
					CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(poListToUpdate);
    			}
            	
            }
  
            //6.To upload Attachment.    
            uploadAttachment();
            
            //6.To insert Notes.
            insertNote();
            
            //7.To create Records for account and contacts.
            partnerAcc1 = partnerOppObj.CHL_Partner_Account_1__c;
            partnerAcc2 = partnerOppObj.CHL_Partner_Account_2__c;
            Set<Id> partnerAccounts = new Set<Id>();
            if(String.isNotBlank(partnerAcc1)) {
                partnerAccounts.add(partnerAcc1);
            }
            if(String.isNotBlank(partnerAcc2)) {
                partnerAccounts.add(partnerAcc2);
            }
            publicGroupIds = CHL_PortalGroupDataAccess.getPublicGroupIdByAccount(partnerAccounts);
            
            CHL_PartnerOpportunityDataAccess.insertShareRecords(partnerAcc1,partnerAcc2,partnerOppObj,publicGroupIds);
            //return new PageReference('/' + partnerOppObj.id);
            detailPage = new PageReference('/' + partnerOppObj.id);
          }catch(Exception ex){
            Database.rollback(sp);
            attach.body = null;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
            //return null;
         }
         return detailPage;
         //Try-Catch for Share records have been added in data access class. This is done for US1381 - Changes undone for US1381 due to DE1572
         //CHL_PartnerOpportunityDataAccess.insertShareRecords(partnerAcc1,partnerAcc2,partnerOppObj,publicGroupIds);
         //return new PageReference('/' + partnerOppObj.id);
    }
    
    private List<sObject> createPartnerOpp(){   
        List<Account> partnerAcc1List = new List<Account>();
        ID partnerAcc1ID = partnerOppObj.CHL_Partner_Account_1__c ;
        partnerAcc1List = CSM_AccountDataAccess.getAccountInformationById(String.valueOf(partnerAcc1ID));
        List<Account> partnerAcc2List = CSM_AccountDataAccess.getAccountInformationById(String.valueOf(partnerOppObj.CHL_Partner_Account_2__c));
        if(is2TierEnabled && ((!partnerAcc1List.isEmpty() && String.isBlank(partnerAcc1List[0].CHL_Partner_Account_Type__c)) || (!partnerAcc2List.isEmpty() && String.isBlank(partnerAcc2List[0].CHL_Partner_Account_Type__c)))){
                String arguments = Label.CHL_ERR_PARTNER_ACCOUNT_TYPE; 
                throw new CSM_AccessController.AccessControlDmlException(arguments); 
        }
        List<sObject>  partnerOppList = new  List<sObject>();    
        sObject sObj = Schema.getGlobalDescribe().get(nameSpacePrefix + CHL_Constants.OBJ_PT_OPPORTUNITY).newSObject() ;  
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_OPPTY,oppID) ; 
        sObj.put('Name', partnerOppObj.Name); 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC1,partnerOppObj.CHL_Partner_Account_1__c) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC2, partnerOppObj.CHL_Partner_Account_2__c) ;
        //Added below condition for US1194
        if(is2TierEnabled) {
            String accType1 = !partnerAcc1List.isEmpty() ? partnerAcc1List[0].CHL_Partner_Account_Type__c : '';
            String accType2 = !partnerAcc2List.isEmpty() ? partnerAcc2List[0].CHL_Partner_Account_Type__c : '';
            sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC1_TYPE,accType1); 
            sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC2_TYPE,accType2);
            //Added below code for US1423
            AggregateResult[] groupedResults = CHL_Util.getListWithAggregateGroupBy('SUM', 'CHL_MSRP__c', new Set<String>{'OpportunityId'},'OpportunityLineItem',' OpportunityId = \'' + oppID + '\' '); // OpportunityId IN (\''+String.join(oppIdList, '\',\'')+'\')
            if(groupedResults != null && !groupedResults.isEmpty() && (Double)groupedResults[0].get('expr0') != null) {
            	//Added currency conversion for DE3048
            	//Updated currency conversion based on Record Currency for DE3351
                Boolean isMultiCurrency = UserInfo.IsMultiCurrencyOrganization();
                String currencyName = (String)OppDetailList[0].get('CurrencyISOCODE'); //UserInfo.getDefaultCurrency();
                Decimal exchangeRate = isMultiCurrency ? CSM_Util.getExchangeRateToCorpCurrency(currencyName) : 1;
                Decimal msrp =  isMultiCurrency ? exchangeRate * ((Double)groupedResults[0].get('expr0')) : (Double)groupedResults[0].get('expr0'); 
                sObj.put(nameSpacePrefix + 'CHL_MSRP__c', msrp) ; 
            }//end of code for US1423
        } else {
            sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC1_TYPE,partnerOppObj.CHL_Partner_Account_1_Type__c) ; 
            sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PARTNER_ACC2_TYPE, partnerOppObj.CHL_Partner_Account_2_Type__c) ;
        }
        //sObj.put(nameSpacePrefix + 'CHL_MSRP__c', OppDetailList[0].Amount) ; 
        
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_INCUMBENT,partnerOppObj.CHL_Incumbent__c) ;   
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_SYNCING, syncingVaule) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_RESELLER_REP, partnerOppObj.CHL_Partner_Account_1_Contact__c) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_DISTRIBUTOR_REP, partnerOppObj.CHL_Partner_Account_2_Contact__c) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_AMOUNT, OppDetailList[0].Amount) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_CLOSE_DATE, OppDetailList[0].CloseDate) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_PROBABILITY, OppDetailList[0].Probability) ; 
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_SALES_STAGE, OppDetailList[0].StageName) ;
        sObj.put(nameSpacePrefix + CHL_Constants.OBJ_PO_EXPIRATIONDATE, OppDetailList[0].REN_Earliest_Expiration_Date__c) ;
        sObj.put(nameSpacePrefix + 'CHL_Customer_Engagement_Type__c',partnerOppObj.CHL_Customer_Engagement_Type__c ); 
        
        Map<String,String> mapOfFields = new Map<String,String>();
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
       
        if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +SSL_ZTH_COMMIT_LEVEL)) {
            mapOfFields.put(SSL_ZTH_COMMIT_LEVEL,CHL_COLOR_LEVEL);
        }
        if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE)) {
             mapOfFields.put(SSL_ZTH_CHL_FIRST_QUOTE_COMPLETED_DATE,CHL_FIRST_QUOTE_COMPLETED_DATE);
        }
        /*if(CSM_AccessController.hasField('Opportunity', solnExtnNamespace +'Quote_Completed_DIA__c')) {
             mapOfFields.put('Quote_Completed_DIA__c','CHL_Quote_Completed_DIA__c');
        }*/
        
        if(mapOfFields.values().size()>0){
            for(String oppField: new List<String>(mapOfFields.KeySet())){
                sObj.put(nameSpacePrefix+mapOfFields.get(oppField),OppDetailList[0].get(solnExtnNamespace+oppField));
            }
        }
        
        
        if(OppDetailList[0].REN_Earliest_Expiration_Date__c != null){
          REN_OpportunityDataAccess.calculateExpQuarterYear( new List<sObject> {sObj}, CHL_Constants.OBJ_PO_EXPIRATIONDATE) ;
        }
        if(UserInfo.isMultiCurrencyOrganization()){
            sObj.put(CHL_Constants.OBJ_PO_CURRENCYISOCODE, OppDetailList[0].get(CHL_Constants.OBJ_PO_CURRENCYISOCODE));
        }
        
        
      	partnerOppList.add(sObj);
      	    	
    	CHL_CONSTANTS.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
		CHL_CONSTANTS.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
        CHL_PartnerOpportunityDataAccess.insertPartnerOpportunity(partnerOppList);
      	Map<Id, CHL_Partner_Opportunity__c> partnerOpptyMap = new Map<Id, CHL_Partner_Opportunity__c>((List<CHL_Partner_Opportunity__c>)partnerOppList);
        CHL_PartnerOppTriggerHelper.resetSyncFieldAfterInsert(partnerOpptyMap);  
        //system.debug('poList :: '+poList);
        if(poList!=null && !poList.isEmpty() && partnerOppObj.CHL_Incumbent__c==true){
        	resetIncumbent(poList);
        }
        
      return partnerOppList;
    }
     
    private void createPartnerRenwalRelationship(List<CHL_Partner_Opportunity__c> partnerOpportunityList){ 
        List<CHL_Partner_Renewal_Relationship__c> partnerRenRelationList = new List<CHL_Partner_Renewal_Relationship__c>();
        for (RenRelationshipLineItemsWrapper r: renRelLineItemWrapperList) {
            if (r.isSelected == true) {
                CHL_Partner_Renewal_Relationship__c partnerRelRelationObj = new CHL_Partner_Renewal_Relationship__c();
                partnerRelRelationObj.CHL_Partner_Opportunity__c = partnerOpportunityList[0].id;
                partnerRelRelationObj.CHL_Renewal_Relationship__c = r.renLineObj.id;
                partnerRelRelationObj.CHL_Incumbent__c = partnerOpportunityList[0].CHL_Incumbent__c == true ? true : false;
                if (UserInfo.isMultiCurrencyOrganization()){
                	partnerRelRelationObj.put('CurrencyIsoCode', partnerOpportunityList[0].get('CurrencyIsoCode'));
                }
                partnerRenRelationList.add(partnerRelRelationObj);
            }
        }
        CHL_PartnerRenRelationshipDataAccess.insertPartnerRenRealtionship(partnerRenRelationList);
     }
     
    public static List<sObject> createQuoteForPO(List<Opportunity> targetOppObjList , List<CHL_Partner_Opportunity__c> poList, List<CHL_Opportunity_Status_Log__c> opptyStatusLogList) {
        
        List<Sobject> quoteList =  new List<Sobject>();
        Map<Id, CHL_Partner_Opportunity__c> partnerOpportunityMap = new Map<Id, CHL_Partner_Opportunity__c>(poList);
        Map<Id,Decimal> partnerOptyIdToAmount = new Map<Id,Decimal>();
        Boolean is2TierEnabled = opptyStatusLogList != null && !opptyStatusLogList.isEmpty() ? opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c : false;
        if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	        Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject();
	        Map<String, Schema.SobjectField> fieldDescriptionMap = CSM_AccessController.fetchAllFieldNames(quoteObj.getSobjectType());
			List<REN_Field_Mappings__c> fieldMappingOppToQuoteList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(CHL_Constants.OBJ_QUOTE, CHL_Constants.OBJ_OPPORTUNITY);		
			Set<String> oppFldstoQuery = new Set<String> {'Id','Pricebook2Id','Name'};
			REN_Util.getFromAndToFldsToQuery(fieldMappingOppToQuoteList,oppFldstoQuery,null);	
			Opportunity oppObj = REN_OpportunityDataAccess.getOpportunityById(targetOppObjList[0].Id, oppFldstoQuery);
			for(Id poId : partnerOpportunityMap.keySet()){
				quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject();
				quoteObj = REN_Util.copyObjectUsingAdminMapping(oppObj, quoteObj, fieldDescriptionMap, fieldMappingOppToQuoteList);		
		        quoteObj.put('Name', oppObj.name);
		        quoteObj.put(CHL_Constants.STR_OPPOTUNITYID, oppObj.id);
		        quoteObj.put(REN_Constants.OBJ_OPP_PRICEBOOK_ID, oppObj.Pricebook2Id);
		        if (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')) {
		            quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c', poId);
		            //US2963 - Copy PO field details to Quote.
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1__c', partnerOpportunityMap.get(poId).CHL_Partner_Account_1__c);
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c', partnerOpportunityMap.get(poId).CHL_Partner_Account_1_Type__c);
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_1_Contact__c', partnerOpportunityMap.get(poId).CHL_Partner_Account_1_Contact__c);
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Incumbent__c', partnerOpportunityMap.get(poId).CHL_Incumbent__c);
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2__c', partnerOpportunityMap.get(poId).CHL_Partner_Account_2__c);
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c', partnerOpportunityMap.get(poId).CHL_Partner_Account_2_Type__c);
			        quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Account_2_Contact__c', partnerOpportunityMap.get(poId).CHL_Partner_Account_2_Contact__c);
		        }
		        if (CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)) {
		            quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY, true);
		        }
		        if(is2TierEnabled && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c')) {
		            quoteObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c', true);
		        }
		        
		        	        
		        quoteList.add(quoteObj);
			}
			CHL_QuoteDataAccess.insertQuotes(quoteList);
        }
        return quoteList;
    }
     
    
    
    private void createQuoteLineItems(List<sObject> quoteObjList, boolean isQLIFromRLI) {
    	sObject quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();    
    	Map<String, Schema.SobjectField> fieldDesctiptionMap = CSM_AccessController.fetchAllFieldNames(quoteLineObj.getSobjectType());
	    List<Sobject> quoteLineItemList = new List<Sobject> ();
	    Decimal totalPrice = 0.0;
        if(isQLIFromRLI){
        	List<REN_Field_Mappings__c> fieldMappingListRLIToQLI = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                                            Label.CHL_LBL_RLI_TO_QLI,CHL_Constants.OBJ_QUOTELINEITEM, CSM_Util.getNamespace()+REN_Constants.OBJ_REN_RENEWS_TO);
            Set<Id> productIdSet = new Set<Id>();
            for (RenRelationshipLineItemsWrapper rliObj: renRelLineItemWrapperList) {
            	if (rliObj.isSelected == true) {
	            	productIdSet.add(rliObj.renLineObj.REN_Product__c);
	            	totalPrice = rliObj.renLineObj.REN_Previous_Price__c != null? (totalPrice+ rliObj.renLineObj.REN_Previous_Price__c) : (totalPrice + 0);
            	}
            }
            if(SS_Constants.isSimplifiedDataModelEnabled){	
	            SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
		        Map<Id,PriceBookEntry> mapofOppToPBE;
		        if(productIdSetting.Renewal_Amount_Product_Id__c!=null){
		         	mapofOppToPBE = REN_PricebookDataAccess.getOppToPbEntry(new List<Opportunity>{OppDetailList[0]},productIdSetting.Renewal_Amount_Product_Id__c);
		        }							
		        quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
				quoteLineObj.put(REN_Constants.OBJ_ASSET_PRODUCT2ID, productIdSetting.Renewal_Amount_Product_Id__c);
        		quoteLineItemList.add(getAggregateQLIObject(quoteObjList[0],quoteLineObj,OppDetailList[0],totalPrice,mapofOppToPBE)); 
        	} else {                                       
	            Map<Id, PricebookEntry> prodIdToPriceBookEntryMap = REN_PricebookDataAccess.getProductIdToPriceBookEntryMap(new List<Opportunity>{OppDetailList[0]}, productIdSet);     
	        	for (RenRelationshipLineItemsWrapper rliWrapperObj: renRelLineItemWrapperList) {
					if (rliWrapperObj.isSelected == true) {
						quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();					
						quoteLineObj = getQLIObjectBasedOnRLI(quoteObjList[0],quoteLineObj,fieldDesctiptionMap,fieldMappingListRLIToQLI,rliWrapperObj.renLineObj,prodIdToPriceBookEntryMap);
						if(!partnerOppObj.CHL_Incumbent__c){
							quoteLineObj.put(REN_Constants.OBJ_OLI_UNITPRICE, 0);
						}					
						quoteLineItemList.add(quoteLineObj);
					}
				}					               		
        	}                	
        } else{
	    	List<REN_Field_Mappings__c> fieldMappingListOLIToQLI = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
	                                                Label.REN_LBL_OPPTY_TO_QUOTE,CHL_Constants.OBJ_QUOTELINEITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM);
	        Set<String> frmFldSet = new Set<String>();
            Set<String> oliFldstoQuery = new Set<String> {'Id','Product2Id','ListPrice','PricebookEntryId','Quantity','SubTotal','OpportunityId','UnitPrice','REN_Start_Date__c','REN_End_Date__c','Quantity','REN_Is_CLM_Renewal__c','REN_Renewable_Line_Item__c'};   
            REN_Util.getFromAndToFldsToQuery(fieldMappingListOLIToQLI,frmFldSet,new Set<String>());              
	        oliFldstoQuery.addall(frmFldSet);      
            List <OpportunityLineItem> oppLIList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','OpportunityId =\''+oppID+'\'');     
            Map<Id, OpportunityLineItem> oLIMap = new Map<Id, OpportunityLineItem>(oppLIList);                                
        	for (OpportunityProductWrapper oppWrapperObj: oppProductWrapperList) {
                if (oppWrapperObj.isSelected == true) {
                    quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
                    quoteLineObj = getQLIObjectBasedOnOLI(quoteObjList[0],quoteLineObj,fieldDesctiptionMap,fieldMappingListOLIToQLI, oLIMap.get(oppWrapperObj.renewedOLI.Id));
        			quoteLineObj.put(REN_Constants.OBJ_OLI_QUANTITY, oppWrapperObj.renewedOLI.Quantity);
			        if(!partnerOppObj.CHL_Incumbent__c){  //&& !SS_Constants.isSimplifiedDataModelEnabled
						quoteLineObj.put(REN_Constants.OBJ_OLI_UNITPRICE, 0);
					}
			      	quoteLineObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_START_DATE, oppWrapperObj.renewedOLI.REN_Start_Date__c);
			        quoteLineObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_END_DATE, oppWrapperObj.renewedOLI.REN_End_Date__c);
			        quoteLineObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_ASSET, oppWrapperObj.renewedAsset.REN_Asset__c);
			        
			        quoteLineItemList.add(quoteLineObj);                    
                }
        	}
        }
        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
        	//CHL_QuoteSyncHandler.QUOTELINEITEM_TRIGGER = false;
        	CHL_QuoteLineItemDataAccess.insertQuotesLineItems(quoteLineItemList);
        }
    } 
    
    public static sObject getQLIObjectBasedOnRLI(sObject quoteObj, sObject quoteLineObj, Map<String, Schema.SobjectField> fieldDesctiptionMap, List<REN_Field_Mappings__c> fieldMappingList, REN_Renews_To__c renLineObj, Map<Id, PricebookEntry> prodIdToPriceBookEntryMap) {
    	if(Test.isRunningTest()) {
    		quoteLineObj.put(REN_Constants.OBJ_OLI_QUANTITY, 1);   
    		quoteLineObj.put('unitprice', 1);   
    	} else {    		
	    	REN_Util.copyObjectUsingAdminMapping(renLineObj, quoteLineObj, fieldDesctiptionMap, fieldMappingList);
        	quoteLineObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Is_CLM_Renewal__c', true);
    	}
        quoteLineObj.put('QuoteId', quoteObj.Id);
        quoteLineObj.put('Product2Id', renLineObj.REN_Product__c);
        quoteLineObj.put('PricebookEntryId', prodIdToPriceBookEntryMap.containsKey(renLineObj.REN_Product__c)? prodIdToPriceBookEntryMap.get(renLineObj.REN_Product__c).Id : '');
		if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + 'REN_Renewable_Line_Item__c') && !SS_Constants.isSimplifiedDataModelEnabled) {
			quoteLineObj.put(CHL_Util.quoteExtnNameSpace + 'REN_Renewable_Line_Item__c', renLineObj.Id);
		}
		return quoteLineObj;	        
    }
    
    public static sObject getQLIObjectBasedOnOLI(sObject quoteObj, sObject quoteLineObj, Map<String, Schema.SobjectField> fieldDesctiptionMap, List<REN_Field_Mappings__c> fieldMappingList, OpportunityLineItem oliObj) {
    	
    	REN_Util.copyObjectUsingAdminMapping(oliObj, quoteLineObj, fieldDesctiptionMap, fieldMappingList);
    	quoteLineObj.put(CHL_Constants.OBJ_QUOTELI_QUOTEID, quoteObj.Id);
        quoteLineObj.put(REN_Constants.OBJ_ASSET_PRODUCT2ID, oliObj.Product2Id);
        quoteLineObj.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID, oliObj.PricebookEntryId);
		if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + 'REN_Renewable_Line_Item__c') && !SS_Constants.isSimplifiedDataModelEnabled && oliObj.REN_Renewable_Line_Item__c != null) {
            quoteLineObj.put(CHL_Util.quoteExtnNameSpace+'REN_Renewable_Line_Item__c', oliObj.REN_Renewable_Line_Item__c);
        }
		return quoteLineObj;	        
    }
    
    public static List<CHL_Partner_Opportunity__c> updatePartnerOpptyFields(Set<Id> quoteIdSet, List<CHL_Partner_Opportunity__c>poList) {
    	List<sObject> quoteList = CHL_QuoteDataAccess.getSyncedQuotesById(quoteIdSet);
    	Map<Id, sObject> partnerOpptyToQuoteMap = new Map<Id, sObject>();
		List<CHL_Partner_Opportunity__c> poListToUpdate = new List<CHL_Partner_Opportunity__c>();
		Boolean hasPOFieldOnQuote = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
		if(hasPOFieldOnQuote) {
	    	for(sObject quoteObj: quoteList) {
	    		partnerOpptyToQuoteMap.put((ID)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj);
	    		//system.debug('$$$ GRAND AMOUNT :: '+quoteObj.get('GrandTotal'));
	    	}
			for(CHL_Partner_Opportunity__c partnerOpptyObj : poList) {	
					
				partnerOpptyObj.CHL_Amount__c = partnerOpptyToQuoteMap!= null && partnerOpptyToQuoteMap.ContainsKey(partnerOpptyObj.Id) ? (Decimal)partnerOpptyToQuoteMap.get(partnerOpptyObj.Id).get('GrandTotal') : partnerOpptyObj.CHL_Amount__c;
				poListToUpdate.add(partnerOpptyObj);
			}
		}
		return poListToUpdate;
    }
     
    private void uploadAttachment() {
    	list<string> fieldList=new list<String>{'body','Name'};
        CSM_Util.checkCRUD_FLS('Attachment', fieldList, CSM_Constants.DML_OPERATION_UPSERT);
        
        IF(attach != null && attachFile != null && fileName != null) {
            attach.body = attachFile;
            attach.Name = fileName;
            attach.ParentId = partnerOppID;
            insert attach;
            attach.body = null;
        }
    }
    
    private void insertNote(){
    	list<string> fieldList=new list<String>{'title','body'};
        CSM_Util.checkCRUD_FLS('Note', fieldList, CSM_Constants.DML_OPERATION_UPSERT);
        
        if(String.isNotBlank(noteText)) {
            Note note = new Note();
            note.parentId = partnerOppID;
            note.title = 'Note : ' + partnerOppObj.name;
            note.body = noteText;
            IF(note.body != null) {
                insert note;
                note.body = null;
            }
        }
    }
    
    /*public static double rollupMSRP(String fieldName,String ObjectName,String whereClause, ) {
        AggregateResult[] groupedResults = CHL_Util.getListWithAggregateGroupBy('SUM', whereClause,fldstoQuery,objectName,whereClause);
        
    }*/
     
    @TestVisible
    public string recordCurrencyCode{
       get{
            if(String.isBlank(recordCurrencyCode) && renRelLineItemWrapperList != null && renRelLineItemWrapperList[0] != null){
                if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(REN_Constants.OBJ_REN_RENEWS_TO))     {
                        recordCurrencyCode = (String)renRelLineItemWrapperList[0].renLineObj.get(REN_Constants.REN_CURRENCY_ISO_CODE) + ' ';
                }else{
                        recordCurrencyCode = CSM_Util.convertCurrencyNameToSymbol(UserInfo.getDefaultCurrency()) + ' ';
                }
             }
           return recordCurrencyCode;
       }
       private set;
    }
        
    public PageReference cancelAndReturnToOppt(){
        return new PageReference('/' + oppID);
    }
    
       
    public class OpportunityProductWrapper {
        public REN_Renews_To__c renewedAsset {get; set;}
        public REN_Renews_To__c renewedSCLI {get; set;}
        public OpportunityLineItem renewedOLI {get; set;}
        public Boolean isSelected {get; set;}
        public String contractName{get; set;}
        public Boolean isEntitlementEnabled{get;set;}
        
        public OpportunityProductWrapper(OpportunityLineItem renewedProduct, Map<String,REN_Renews_To__c> renewalRelMap){
            this.isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
            this.renewedOLI = renewedProduct;
          	REN_Renews_To__c rli = (renewedOLI.REN_Renewable_Line_Item__c == null ? null : renewalRelMap.get(renewedOLI.REN_Renewable_Line_Item__c + ''));
            if(rli != null){
                this.renewedAsset = rli.REN_Asset__c == null ? null : rli;
                this.renewedSCLI = (!CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT) || rli.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM) == null) ? null : rli;
            }
            if(renewedSCLI != null && CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
                sObject sc = renewedSCLI.getSObject(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_RELATION);
                if(sc != null){
                    contractName = (String)sc.get(CHL_Constants.CUSTOM_OBJ_NAME) ;
                }
            }
            this.isSelected = true;
        }
    }
    
    public class RenRelationshipLineItemsWrapper {
        public REN_Renews_To__c renLineObj {get; set;}
        public String contractName{get; set;}
        public Boolean isSelected {get; set;}
        
        public RenRelationshipLineItemsWrapper(REN_Renews_To__c renRelLine) {
            this.renLineObj = renRelLine;
            this.isSelected = true;
            if(CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
                sObject sc = renLineObj.getSObject(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_RELATION);
                    if(sc != null){
                        contractName = (String)sc.get(CHL_Constants.CUSTOM_OBJ_NAME) ;
                    }
            } else{ contractName = '';}
        }
    }
    
    public static sObject getAggregateQLIObject(sObject quoteObj, sObject quoteLineObj, Opportunity opp, Decimal totalPrice, Map<Id,PriceBookEntry> mapofOppToPBE){    	
    	
        //Sobject quoteLineObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTELINEITEM).newSObject();
        quoteLineObj.put(CHL_Constants.OBJ_QUOTELI_QUOTEID, quoteObj.Id);
        quoteLineObj.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID, mapofOppToPBE.get(opp.Id).Id);
        quoteLineObj.put(REN_Constants.OBJ_OLI_QUANTITY, 1);   	
        if(CSM_AccessController.hasField('QuotelineItem', CHL_Util.quoteExtnNameSpace + 'CHL_Is_CLM_Renewal__c')) {
        	quoteLineObj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Is_CLM_Renewal__c', true);
        }
		/*if(selectedRLIs != null && !selectedRLIs.isEmpty()){
			for(REN_Renews_To__c rli : selectedRLIs){
				totalPrice = rli.REN_Previous_Price__c != null? (totalPrice+ rli.REN_Previous_Price__c) : (totalPrice + 0);
			}
		}*/
		quoteLineObj.put(REN_Constants.OBJ_OLI_UNITPRICE, totalPrice);
    	return quoteLineObj;
    }
}