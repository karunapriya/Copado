/**
* @description    Test utility to create data required for CHANNEL test methods 
*/
public with sharing class CHL_TestUtility {
   
   public static Account partnerAccount() {
		Account acct = new Account();
		acct.Name = 'Partner Test Acc';
		acct.BillingState = 'GA';
		return acct;
	}
	
	public static Contact partnerContact(Id AccountId) {
		Contact con = new Contact();
		con.LastName = 'Partner Contact Test';
		con.Email = 'testpartnercontact@test.com';
		con.AccountId = AccountId;
		return con;
	}
	
	public static Opportunity partnerOpportunity(Id AccountId,String stage) {
		Opportunity opp = new Opportunity();
		opp.Name = 'opportunity for Partner Test';
		opp.StageName = stage;
		opp.CloseDate = system.today().adddays(10);
		opp.Amount = 400;
		opp.AccountId = AccountId;
		return opp;
	}
	
	public static CHL_Partner_Opportunity__c createPartnerOpportunity(Id oppId) {
		CHL_Partner_Opportunity__c partOpp = new CHL_Partner_Opportunity__c();
		partOpp.Name = 'opportunity for Partner Test';
		partOpp.CHL_Sales_Stage__c = 'Prospecting';
		partOpp.CHL_Close_Date__c = system.today().adddays(10);
		partOpp.CHL_Amount__c = 400;
		partOpp.CHL_Opportunity__c = oppId;
		return partOpp;
	}
	
	public static CHL_Partner_Opportunity__c channelPartnerOpportunity(WrapperPartnerOpportunity partOppty) {
		CHL_Partner_Opportunity__c cOppty = new CHL_Partner_Opportunity__c();
		cOppty.Name = 'opportunity for Partner Test';
		cOppty.CHL_Sales_Stage__c = partOppty.Stage;
		cOppty.CHL_Close_Date__c = system.today().adddays(10);
		cOppty.CHL_Expiration_Date__c = partOppty.expirationDate;
		cOppty.CHL_Amount__c = 400;
		cOppty.CHL_Partner_Account_1__c = partOppty.partnerAcc1Id;
		cOppty.CHL_Partner_Account_2__c = partOppty.partnerAcc2Id;
		cOppty.CHL_Partner_Account_1_Type__c = partOppty.partnerAcc1Type;
		cOppty.CHL_Partner_Account_2_Type__c = partOppty.partnerAcc2Type;
		cOppty.CHL_Partner_Account_1_Contact__c = partOppty.contact1Id;
		cOppty.CHL_Partner_Account_2_Contact__c = partOppty.contact2Id;
		cOppty.CHL_Opportunity__c = partOppty.OpportunityId;
		cOppty.CHL_Syncing__c = (partOppty.syncing==null?'none':partOppty.syncing);
		return cOppty;
	}
	
	
	public static User createPartnerUser(Id profileId, String userName,Id contactID){
        User u = new User(
            FirstName = 'Test'
            , LastName = 'User'
            , Username = userName
            , Email = userName
            , IsActive = true
            , ContactId = contactId
            , Alias = 'tuser'
            , TimeZoneSidKey = 'GMT'
            , LocaleSidKey = 'en_US'
            , EmailEncodingKey = 'ISO-8859-1'
            , LanguageLocaleKey = 'en_US'
            , ProfileId = profileId);
            return u;
    }
    
    public static User createTestPartnerUser(String profileName,String userName,Id contactID){ 
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];        
        return createPartnerUser(p.Id,userName,contactID);
    }
    
    public static PermissionSet getPermissionSet(String permissionSetName)	{
    	PermissionSet ps = [SELECT Id From PermissionSet WHERE Name =:permissionSetName];
    	return ps;
    }
    
    
    public static List<CHL_Partner_Opportunity__c> channelPartnerOpportunityList(integer noOfRecords, WrapperPartnerOpportunity partOppty) {
    	List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
    	for(integer i=0;i<noOfRecords; i++){
			CHL_Partner_Opportunity__c cOppty = new CHL_Partner_Opportunity__c();
			cOppty.Name = 'opportunity for Partner Test';
			cOppty.CHL_Sales_Stage__c = partOppty.Stage;
			cOppty.CHL_Close_Date__c = system.today().adddays(10);
			cOppty.CHL_Expiration_Date__c = partOppty.expirationDate;
			cOppty.CHL_Amount__c = 400;
			cOppty.CHL_MSRP__c = 300;
			cOppty.CHL_Partner_Account_1__c = partOppty.partnerAcc1Id;
			cOppty.CHL_Partner_Account_2__c = partOppty.partnerAcc2Id;
			cOppty.CHL_Partner_Account_1_Type__c = partOppty.partnerAcc1Type;
			cOppty.CHL_Partner_Account_2_Type__c = partOppty.partnerAcc2Type;
			cOppty.CHL_Partner_Account_1_Contact__c = partOppty.contact1Id;
			cOppty.CHL_Partner_Account_2_Contact__c = partOppty.contact2Id;
			cOppty.CHL_Opportunity__c = partOppty.OpportunityId;
			cOppty.CHL_Last_Status_Update_Date__c = system.today().addDays(-10);
			if(partOppty.statusUpdate != null && partOppty.statusUpdate == true){
				cOppty.CHL_Needs_Status_Update__c = true;
			} else{
				cOppty.CHL_Needs_Status_Update__c = false;
			}
			partnerOptyList.add(cOppty);
    	}
		return partnerOptyList;
	}
    
    public static List<sObject> createQuotes(integer noOfQuotesPerOppty, List<Opportunity> opptyList,List < CHL_Partner_Opportunity__c > partnerOppList) {
    	List<sObject> quoteList = new List<sObject>();
    	if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
    		for(integer i=1;i<=noOfQuotesPerOppty;i++) {	    	
		       	//To create Quote Obj.
		   		Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject() ; 
		    	quoteObj.put('Name', 'Test Quote'+i) ; 
		    	quoteObj.put('Description', 'Test Quote'+i) ;
		    	quoteObj.put(CHL_Constants.STR_OPPOTUNITYID, opptyList[0].id) ;
		    	quoteObj.put(REN_Constants.OBJ_OPP_PRICEBOOK_ID, opptyList[0].Pricebook2Id) ;
		    	if(partnerOppList != null && !partnerOppList.isEmpty() && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
		        	quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, partnerOppList[0].id) ;
		   		}
		    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)) {
		    		quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY, false) ;
		    	}
		    	quoteList.add(quoteObj);
	 		}
    	}
    	return quoteList;
    }
    
    public static List<Sobject> createQuoteLineItems(List<Sobject> quoteList, List<OpportunityLineItem> OpptyLineItems) {
        List<Sobject> quoteItemList = new List<Sobject>();
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	        for(sObject objQuote:quoteList) {
	            for(OpportunityLineItem oli:OpptyLineItems) {
	                if(oli.opportunityId == objQuote.get('OpportunityId')) {
	                    Sobject quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
	                    quoteLineObj.put('QuoteId', objQuote.get('Id'));
	                    quoteLineObj.put('Product2Id', oli.Product2Id);
	                    quoteLineObj.put('Quantity', Oli.Quantity);
	                    quoteLineObj.put('UnitPrice', oli.ListPrice);
	                    quoteLineObj.put('PricebookEntryId', oli.PricebookEntryId);
	                    quoteItemList.add(quoteLineObj);
	                }
	            }
	        }   
        }    
        return quoteItemList;
    }
    
     public static List<OpportunityLineItem> createOplis(List<Opportunity> opportunityList, List<PricebookEntry> pbeList){
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
        for(Opportunity oppty : opportunityList){
            for(PricebookEntry pbe : pbeList){
                opliList.add(new OpportunityLineItem(OpportunityId = oppty.Id, Quantity = 2, TotalPrice = 20, PricebookEntryId = pbe.Id));
            }
        }
        return opliList;
    }
    
    public static List<Product2> createProducts(Integer recordCount){
        List<Product2> product2List = new List<Product2>();
        for (integer i=1; i<=recordCount; i++){
            Product2 prod = new Product2();
            prod.Name = 'TestProduct' + i;
            prod.IsActive = true;
            prod.ProductCode = 'TP' + i;
            product2List.add(prod);
        }
        //insert product2List;
        return product2List;
    }
    
    public static List<PricebookEntry> createPricebookEntry(List<Product2> product2List, Id pricebook2Id){
        
        if(pricebook2Id == null){
            List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true LIMIT 1];
            if(pbList != null && !pbList.isEmpty()){
                pricebook2Id = pbList[0].id;
            }
        }
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        Integer i = 1;
        for(Product2 a: product2List){
            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = a.id;
            pbe.Pricebook2Id = pricebook2Id;
            pbe.UnitPrice = i++ * 100 + 1;
            pbe.IsActive = true;
            pricebookEntryList.add(pbe);
        }
        return pricebookEntryList;
    }
    
    public static List<REN_Field_Mappings__c> createQuoteMapping() {
    	string namespace = CSM_Util.getNamespace();
    	string extNameSpace = CHL_Util.quoteExtnNameSpace;
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();    	
		fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'TEXTAREA','Description','Description','Opportunity','Quote',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'TEXTAREA','Description','Description','Quote','Opportunity',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'TEXTAREA','Description','Description','QuoteLineItem', 'OpportunityLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'PERCENT','Discount','Discount','QuoteLineItem', 'OpportunityLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'DOUBLE','Quantity','Quantity','QuoteLineItem' , 'OpportunityLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'DATE',extNameSpace +'CHL_Start_Date__c',namespace + 'REN_Start_Date__c','QuoteLineItem', 'OpportunityLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DATE',namespace + 'REN_Start_Date__c',extNameSpace +'CHL_Start_Date__c','OpportunityLineItem','QuoteLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'DATE',extNameSpace +'CHL_End_Date__c',namespace +'REN_End_Date__c','QuoteLineItem', 'OpportunityLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DATE',namespace +'REN_End_Date__c',extNameSpace +'CHL_End_Date__c','OpportunityLineItem','QuoteLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'TEXTAREA' ,'Description','Description','OpportunityLineItem','QuoteLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'PERCENT','Discount','Discount','OpportunityLineItem','QuoteLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DOUBLE','Quantity','Quantity','OpportunityLineItem','QuoteLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY, 'BOOLEAN',namespace +'REN_Is_CLM_Renewal__c', extNameSpace +'CHL_Is_CLM_Renewal__c', 'OpportunityLineItem', 'QuoteLineItem',true, ''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE, 'BOOLEAN',extNameSpace +'CHL_Is_CLM_Renewal__c',namespace +'REN_Is_CLM_Renewal__c' , 'QuoteLineItem', 'OpportunityLineItem',true, ''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'CURRENCY','UnitPrice','UnitPrice','QuoteLineItem','OpportunityLineItem',true,''));
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'CURRENCY','UnitPrice','UnitPrice', 'OpportunityLineItem','QuoteLineItem',true, ''));
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'DATE','ServiceDate','ServiceDate','QuoteLineItem','OpportunityLineItem',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DATE','ServiceDate','ServiceDate', 'OpportunityLineItem','QuoteLineItem',true, ''));
			
		return fieldMappingList;
		
	}
		    
    private static REN_Field_Mappings__c createFieldMapping(String mappingName, String dataType, String toName, String fromName, String toObject, 
			String fromObject, Boolean isRequired, String defaultValue) {
		REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
		fm.name = mappingName;
		fm.REN_Field_Data_Type__c = dataType;
		fm.REN_To_Field_API_Name__c = toName;
		fm.REN_From_Field_API_Name__c = fromName;
		fm.REN_To_Object_API_Name__c = toObject;
		fm.REN_From_Object_Api_Name__c = fromObject;
		fm.REN_Is_Required__c = isRequired;
		fm.REN_Default_Value__c = defaultValue;
		return fm;
	}
	
    public class WrapperPartnerOpportunity{
         public Id OpportunityId;
         public Id partnerAcc1Id;
         public Id partnerAcc2Id;
         public String partnerAcc1Type;
         public String partnerAcc2Type;
         public Id contact1Id;
         public Id contact2Id;
         public Date expirationDate;
         public String Stage;
         public Boolean statusUpdate;
         public String syncing;
    } 
    
    public static Asset createAsset(Id acctId) {
    	Asset asset = new Asset();
    	asset.Name = 'Test Asset';
    	asset.AccountId = acctId;
    	return asset;
    }
    
    public static List<REN_Field_Mappings__c> createPOMapping() {
    	string namespace = CSM_Util.getNamespace();
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();    	
		fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'STRING','Name','Name',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'PICKLIST',namespace+'CHL_Sales_Stage__c',namespace+'CHL_Sales_Stage__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'PICKLIST',namespace+'CHL_Color_Commit__c',namespace+'CHL_Color_Commit__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'Date',namespace+'CHL_Close_Date__c',namespace+'CHL_Close_Date__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'Date', namespace+'CHL_Expiration_Date__c', namespace+'CHL_Expiration_Date__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'NUMBER',namespace+'CHL_EQ__c',namespace+'CHL_EQ__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'STRING',namespace+'CHL_FY__c',namespace+'CHL_FY__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'REFERENCE',namespace+'CHL_Partner_Account_1__c',namespace+'CHL_Partner_Account_1__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'PICKLIST', namespace+'CHL_Partner_Account_1_Type__c', namespace+'CHL_Partner_Account_1_Type__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'REFERENCE' ,namespace+'CHL_Partner_Account_2__c',namespace+'CHL_Partner_Account_2__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_PO_TO_PO,'PICKLIST',namespace+'CHL_Partner_Account_2_Type__c',namespace+'CHL_Partner_Account_2_Type__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Partner_Opportunity__c',true,''));            	
		return fieldMappingList;		
	}
	
	public static List<Opportunity> createOpportunity(Integer recCount, Id AccountId){
		List<Opportunity> oppList = new List<Opportunity>();
		for(Integer i=0;i<recCount;i++){
			Opportunity opp = new Opportunity();
			opp.Name = 'TestOpp'+i;
			opp.StageName = 'Needs Analysis';
			opp.CloseDate = system.today().adddays(10);
			opp.Amount = 400;
			opp.AccountId = AccountId;
			oppList.add(opp);
		}
		return oppList;	
	}
	
	public static List<REN_Renews_To__c> createRenewableLineItems(Integer recordCount,Id oppId,Id productId){
		List<REN_Renews_To__c> rliList = new List<REN_Renews_To__c>();
		for(Integer i = 0;i<recordCount;i++){
			REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
			renRelationObj.Name = 'Ren-OPP'+i;
			renRelationObj.REN_Renews_To__c = oppId;
			renRelationObj.REN_Product__c = productId;
	        renRelationObj.REN_Quantity__c = 2;
	        renRelationObj.REN_Previous_Price__c= 500;
	        renRelationObj.REN_Start_Date__c = system.today();
	        renRelationObj.REN_End_Date__c = system.today() + 5;
	        renRelationObj.REN_New_Start_Date__c = system.today();
	        renRelationObj.REN_New_End_Date__c = system.today() + 5;
	        rliList.add(renRelationObj);
		}
		return rliList;		
	}
	
	public static List<CHL_Partner_Renewal_Relationship__c> createPartnerRenewableLineItems(Id poId, List<REN_Renews_To__c> rliList){
		List<CHL_Partner_Renewal_Relationship__c> prrList = new List<CHL_Partner_Renewal_Relationship__c>();
		for(REN_Renews_To__c rli : rliList){
			CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
	       	prr.CHL_Partner_Opportunity__c = poId;
	       	prr.CHL_Renewal_Relationship__c = rli.id;
	       	prrList.add(prr);
		}
		return prrList;
	}
	
	public static List<REN_Field_Mappings__c> createRLIToQLIMapping() {
    	String csmNamespace = CSM_Util.getNamespace();
    	String quoteExtNameSpace = CHL_Util.quoteExtnNameSpace;
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();    	
		fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_RLI_TO_QLI,'NUMBER','Quantity',csmNamespace+'REN_Quantity__c','QuoteLineItem',csmNamespace+'REN_Renews_To__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_RLI_TO_QLI,'CURRENCY','UnitPrice',csmNamespace+'REN_Previous_Price__c','QuoteLineItem',csmNamespace+'REN_Renews_To__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_RLI_TO_QLI,'DATE',quoteExtNameSpace+'CHL_Start_Date__c',csmNamespace+'REN_Start_Date__c','QuoteLineItem',csmNamespace+'REN_Renews_To__c',true,''));            
        fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_RLI_TO_QLI,'DATE',quoteExtNameSpace+'CHL_End_Date__c',csmNamespace+'REN_End_Date__c','QuoteLineItem',csmNamespace+'REN_Renews_To__c',true,''));            
        //fieldMappingList.add(createFieldMapping(system.label.CHL_LBL_RLI_TO_QLI,'STRING', quoteExtNameSpace+'REN_Original_Line_Item_ID__c', csmNamespace+'REN_Original_Line_Item_ID__c','QuoteLineItem',csmNamespace+'REN_Renews_To__c',true,''));            
        return fieldMappingList;		
	}
	
	public static List<REN_Field_Mappings__c> createOppToQuoteMapping() {
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();  
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'TEXTAREA','Description','Description','Quote','Opportunity',true,''));
    	return fieldMappingList;		
	}
	
	public static List<CHL_Opportunity_Status_Log__c> createOppStatusLog(){
		List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = new  List<CHL_Opportunity_Status_Log__c>();
		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
		optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
		optyStatusLogObj.CHL_Days_between_Update__c = 5;
		optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
		optyStatusLogObj.CHL_Create_New_Quote_On_Destination_PO__c = true;
		opptyStatusLogList.add(optyStatusLogObj);
		return opptyStatusLogList;
	}
	
	public static List<REN_Field_Mappings__c> createQuoteToOpptyMapping() {
    	String quoteExtNameSpace = CHL_Util.quoteExtnNameSpace;
    	String csmNamespace = CSM_Util.getNamespace();
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();  
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'TEXTAREA','Description','Description','Opportunity','Quote',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'TEXTAREA','Amount','GrandTotal','Opportunity','Quote',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'TEXTAREA',csmNamespace+'CHL_MSRP__c',quoteExtNameSpace+'CHL_MSRP__c','Opportunity','Quote',true,''));
    	return fieldMappingList;		
	}
	
	public static List<REN_Field_Mappings__c> createQliToOliMapping() {
		String nameSpace = CSM_Util.getNamespace();
        String extNameSpace = CHL_Util.quoteExtnNameSpace;
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();  
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DATE',namespace + 'REN_Start_Date__c',extNameSpace +'CHL_Start_Date__c','OpportunityLineItem','QuoteLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DATE',extNameSpace +'CHL_End_Date__c',namespace +'REN_End_Date__c','QuoteLineItem', 'OpportunityLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DATE',namespace +'REN_End_Date__c',extNameSpace +'CHL_End_Date__c','OpportunityLineItem','QuoteLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'TEXTAREA' ,'Description','Description','OpportunityLineItem','QuoteLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'DOUBLE','Quantity','Quantity','OpportunityLineItem','QuoteLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'BOOLEAN',namespace +'REN_Is_CLM_Renewal__c', extNameSpace +'CHL_Is_CLM_Renewal__c', 'OpportunityLineItem', 'QuoteLineItem',true, ''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_QUOTE_TO_OPPTY,'PERCENT','Discount','Discount','OpportunityLineItem','QuoteLineItem',true,''));
    	return fieldMappingList;		
	}
	
	public static List<Sobject> createMultipleQuoteLineItems(Integer qliCount, List<Sobject> quoteList, List<Product2> productsList, List<PricebookEntry> pbeList) {
        List<Sobject> quoteItemList = new List<Sobject>();
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	        for(sObject objQuote:quoteList) {
	            for(Integer i=0; i < qliCount;i++) {
                    Sobject quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                    quoteLineObj.put('QuoteId', objQuote.get('Id'));
                    quoteLineObj.put('Product2Id', productsList[0].Id);
                    quoteLineObj.put('Quantity', 1);
                    quoteLineObj.put('UnitPrice',100);
                    quoteLineObj.put('PricebookEntryId', pbeList[0].Id);
                    quoteItemList.add(quoteLineObj);
	                
	            }
	        }   
        }    
        return quoteItemList;
    }
    public static List<REN_Field_Mappings__c> createOpptyToQuoteMapping() {
    	String quoteExtNameSpace = CHL_Util.quoteExtnNameSpace;
    	String csmNamespace = CSM_Util.getNamespace();
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();  
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'TEXTAREA','Description','Description','Quote','Opportunity',true,''));
    	return fieldMappingList;		
	}
    public static List<REN_Field_Mappings__c> createOliToQliMapping() {
		String nameSpace = CSM_Util.getNamespace();
        String extNameSpace = CHL_Util.quoteExtnNameSpace;
    	List<REN_Field_Mappings__c> fieldMappingList =  new List<REN_Field_Mappings__c>();  
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'TEXTAREA' ,'Description','Description','QuoteLineItem' , 'OpportunityLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'DOUBLE','Quantity','Quantity','QuoteLineItem' , 'OpportunityLineItem',true,''));
    	fieldMappingList.add(createFieldMapping(system.label.REN_LBL_OPPTY_TO_QUOTE,'PERCENT','Discount','Discount','QuoteLineItem' , 'OpportunityLineItem',true,''));
    	return fieldMappingList;		
	}
}