/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.21.2014
* @description    CSM_AdminLinksComponentController class provides links for the Admin screen
*/
public with sharing class CSM_AdminLinksComponentController {

    public static String titleHeader {get; set;}
    public static String subtitleHeader {get; set;}
    public String tabCategory {get; set;} 
    public Boolean isCSMNetOpsUser {get; private set;}
    public Boolean isRenewNetOpsUser {get; private set;}
    public Boolean isChannelNetOpsUser {get; private set;}
    
    public Boolean hasServiceContract {get; private set;}
    public Boolean hasChannelAccess {get; private set;}
    public Boolean isSolExtSalesManager {get; private set;}
    public Boolean isSolExtOpsManager {get; private set;}
    public String errorMsg {get; set;} 
    public String helpParam {get; set;}
    public Boolean isSolExtLTIntegrator {get; private set;}
    public Boolean simplifiedDataModelEnabled {get; set;}
    private SS_License__c licenseInstance;
    Boolean isMultiCurrencyOrg;
    
    public Boolean isSystemAdmin {get; set;}
    public Boolean isEnabledChannelDefaults {get; set;}
    public Boolean hasManageFCPermission{get;set;}
    public Boolean hasBusinessAnalystPerm{get;set;}
    public Boolean isCSMEnable{get;set;}
    public Boolean isChannelEnable{get;set;}
    public Boolean isPlaymakerUser {get; private set;}
    public static Boolean hasTemplate{get;set;}
        
    public CSM_AdminLinksComponentController() {
        //SS_LicenseCheck.getUserType();
        helpParam = CSM_Constants.HELP_ADMIN_TAB;
        this.isCSMNetOpsUser =true;
        this.isRenewNetOpsUser =true;
        this.isChannelNetOpsUser =true;
                
        this.hasServiceContract = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
        hasChannelAccess =true;
        this.isSolExtSalesManager =true;
        this.isSolExtOpsManager = true;
        
        this.simplifiedDataModelEnabled = false;
        this.isMultiCurrencyOrg = false;
        
        this.hasBusinessAnalystPerm = false;
        this.hasManageFCPermission = false;
        this.isPlaymakerUser =false;
        this.isSolExtLTIntegrator=false;
        
        SS_LicenseCheck licenseCheck = SS_LicenseCheck.getInstance();
        isCSMEnable = licenseCheck.isCSMEnabled;
        isChannelEnable = licenseCheck.isChannelEnabled;
        
        if(licenseCheck.isCustomPermissionAssigned(SS_Constants.PS_ManageFocusCategory)){
            hasManageFCPermission = true;
        }
        if(licenseCheck.isCustomPermissionAssigned(SS_Constants.PS_REN_Playmaker)){
            isPlaymakerUser= true;
            
        }
        if(licenseCheck.isPermissionSetAssigned(SS_Constants.PS_Business_Analyst)){
            hasBusinessAnalystPerm = true;
        }
        if(licenseCheck.isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator)){
            isSolExtLTIntegrator=true;
        }
        List<profile> profileList = [SELECT Name FROM profile WHERE id = :userinfo.getProfileId() LIMIT 1];
        if (profileList != null && !profileList.isEmpty()) {
            isSystemAdmin = profileList[0].Name.equalsIgnoreCase('System Administrator')?true:false;             
        }
        licenseInstance = SS_License__c.getOrgDefaults();
        if (licenseInstance != null) {
            this.simplifiedDataModelEnabled = licenseInstance.Simplified_Data_Model_Is_Enabled__c;
        }
        // Added for US2771
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
            isEnabledChannelDefaults = false;
        } else {
            isEnabledChannelDefaults = true;
        }
        List<Document> docList = CHL_DocumentDataAccess.getQuoteTemplate();
        if(docList != null && !docList.isEmpty()){
        	hasTemplate = true;
        }
        errorMsg();
    }  
    
    public PageReference redirectToHome() {
        PageReference pageRef = Page.CSM_Admin;
        pageRef.getParameters().put('tabCategory','Home');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToFocusCategoriesGroup() {
        PageReference pageRef = Page.CSM_FocusCategories;
        pageRef.getParameters().put('tabCategory', 'Admin');
        pageRef.setRedirect(true);
        return pageRef;
    }
   
    
    public PageReference getRedirectToFocusCategoriesLayout() {
        PageReference pageRef = Page.CSM_ManageHomePageDisplayWrap;
        pageRef.getParameters().put('vt', hasManageFCPermission?'m':'v');
        pageRef.setRedirect(true);  
        return pageRef;
    }
    
    public PageReference getRedirectToFocusCategories() {
        PageReference pageRef = Page.CSM_FocusCategoryViewList;
        pageRef.getParameters().put('tabCategory', 'Admin');
        pageRef.setRedirect(true);  
        return pageRef;
    }
    
    
    
    
    public PageReference getRedirectToAccountPlanTemplates() {
        PageReference pageRef = Page.CSM_AccountPlanTemplateList;
        pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToIndicatorGroups() {
        PageReference pageRef = Page.CSM_IndicatorGroup;
        pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToPlaybooks() {
        PageReference pageRef = Page.CSM_PlaybooksList;
        pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToPlays() {
        PageReference pageRef = Page.CSM_PlaysList;
        pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToBatchFilterActivity() {
        PageReference pageRef = Page.CSM_BatchFilterActivity;
        pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToReportAdmin() {
        PageReference pageRef = Page.CSM_ReportAdmin;
        pageRef.getParameters().put('tabCategory', 'ReportAdmin');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToMSTR() {
        Schema.DescribeSObjectResult result= CSM_MSTR__c.SObjectType.getDescribe();
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o');
        //pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToMSTD() {
        Schema.DescribeSObjectResult result= CSM_MSTD__c.SObjectType.getDescribe();
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o');
        //pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
     
    public PageReference redirectToServiceContracts() {
        return null;
    }  
    
    public PageReference redirectToAssets() {
        return null;
    } 
        
    public PageReference getRedirectToDataGeneration() {
        PageReference pageRef = Page.REN_DataGenerationAdmin;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    } 
    
    public PageReference getRedirectToRenewalOpportunity () {
        PageReference pageRef = Page.REN_OpportunityRenewalAdmin;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToRenewalOpportunityUpdate () {
        PageReference pageRef = Page.REN_OppRenewalAdminUpdate;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference redirectToChartManagement() {
        PageReference pageRef = Page.CSM_ChartManagementList;
        pageRef.getParameters().put('tabCategory', 'Admin');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToRenewalMappings() {
        PageReference pageRef = Page.REN_RenewalMappings;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToBatchOppGenActivity() {
        PageReference pageRef = Page.REN_BatchOppGenActivity;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToAutoGenerationLog() {
        PageReference pageRef = Page.REN_AsyncOppLogInfo;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToConsolidateOpportunitiesBatchLog() {
        PageReference pageRef = Page.REN_ConsolidateOpportunitiesBatchLog;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference redirectToBatchAssignActivity() {
        PageReference pageRef = Page.CSM_BatchSuccessPlanActivity;
        pageRef.getParameters().put('tabCategory', 'SuccessPlan');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToChannelAdmin() {
        PageReference pageRef = Page.CHL_ChannelPartnerAdmin;
        pageRef.getParameters().put('tabCategory', 'Channel');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToChannelDataSync() {
        PageReference pageRef = Page.CHL_RenPartnerDataSync;
        pageRef.getParameters().put('tabCategory', 'Channel');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToSegmentOverview() {
        PageReference pageRef = Page.REN_SegmentOverview;
        pageRef.getParameters().put('tabCategory', 'Playmaker');
        pageRef.setRedirect(true);
        return pageRef;
    }
   
    public PageReference getRedirectToTaskGenerationActivity() {
        PageReference pageRef = Page.REN_TaskGenerationActivity;
        pageRef.getParameters().put('tabCategory', 'Playmaker');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getRedirectToQuoteRequestResults() {
        PageReference pageRef = Page.REN_QuoteRequestBatchResult;
        pageRef.getParameters().put('tabCategory', 'Playmaker');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference getRedirectToOauthPage() {
        PageReference pageRef = Page.REN_LowTouchAuthorization; //REN_LowTouchHerokuConnection
        pageRef.getParameters().put('tabCategory', 'Playmaker');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getredirectToDocument(){
    	PageReference pageRef;
    	List<Document> docList = CHL_DocumentDataAccess.getQuoteTemplate();
    	if(docList != null && !docList.isEmpty()){
    		pageRef = new PageReference('/' + docList[0].Id);
    	}    	
        return pageRef;
    }
    
    public String param 
    {
        get;
        set { if(value != null)
            {
                param = value;
            }
        }
    
    }
    
    public void errorMsg() {
        
        errorMsg = SS_Constants.SS_NO_LICENSE_MSG;
    }
    
    public PageReference enableSimplifiedDataModel() {
        Savepoint sp = Database.setSavepoint();
        try {
            //check if the org uses multi currency 
            isMultiCurrencyOrg = UserInfo.isMultiCurrencyOrganization();
            
            String defaultOrCorporateCurr = '';
            Set<String> activeCurrSet = new Set<String>();
            
            if (!isMultiCurrencyOrg) {
                //it's a single currency org, find the default currency
                defaultOrCorporateCurr = UserInfo.getDefaultCurrency();
                activeCurrSet.add(defaultOrCorporateCurr);
            } 
            
            //for a multi currency org, get the list of all the active currencies
            if (isMultiCurrencyOrg) {           
                List<SObject> activeCurrTypeSobjList = CSM_Util.getAllActiveCurrenciesInAMultiCurrOrg();
                if (!activeCurrTypeSobjList.isEmpty()) {
                    for (Sobject sobj : activeCurrTypeSobjList) {
                        String isoCodeStr = (String)sobj.get('IsoCode');
                        if ((Boolean)sobj.get('isCorporate')) {
                            defaultOrCorporateCurr = isoCodeStr;
                        }                                               
                        activeCurrSet.add(isoCodeStr);
                    }
                }
            }
            
            //get the list of all active pricebooks in an org
            List<Pricebook2> priceBkList = CSM_Util.getAllActivePriceBooks();
            Set<Id> stdPbIdSet = new Set<Id>();
            Set<Id> pricebookIdSet = new Set<Id>(); // set of active pricebook ids
            if (priceBkList != null && !priceBkList.isEmpty()) {
                for (Pricebook2 pb : priceBkList) {
                    if (pb.isStandard) {
                        stdPbIdSet.add(pb.Id);
                    } else {
                        pricebookIdSet.add(pb.Id);
                    }
                }
            }
            
            //create dummy products
            List<sObject> prodToBeCreatedList = createDummyProduct(defaultOrCorporateCurr);
            if (!prodToBeCreatedList.isEmpty()) {
                insert prodToBeCreatedList;
            } 
            
            //get the ids of the dummy products created
            List<Id> dummyProdIdList = new List<Id>();
            List<Product2> dummProdList = [SELECT Id, Name FROM Product2 WHERE Name = 'Renewal Amount' OR Name = 'Adds Amount'];
            String renewalAmtProdId = '';
            String addsAmtProdId = '';
            if (dummProdList != null && !dummProdList.isEmpty()) {
                for (Product2 prod : dummProdList) {
                    dummyProdIdList.add(prod.Id);
                    if (CSM_Constants.STR_RENEWAL_AMOUNT_PRODUCT.equalsIgnoreCase(prod.Name)) {
                        renewalAmtProdId = prod.Id;
                    } else if (CSM_Constants.STR_ADDS_AMOUNT_PRODUCT.equalsIgnoreCase(prod.Name)) {
                        addsAmtProdId = prod.Id;
                    }
                }
            }
            
            //first insert into price book entry for standard price book
            List<sObject> pbeStdList = insertPriceBookEntry(dummyProdIdList, stdPbIdSet, activeCurrSet);
            if (!pbeStdList.isEmpty()) {
                insert pbeStdList;
            }
            
            //insert into price book entry for custom price books
            List<sObject> customPbeList = insertPriceBookEntry(dummyProdIdList, pricebookIdSet, activeCurrSet);
            if (!customPbeList.isEmpty()) {
                insert customPbeList;
            }
            
            //set simplified data model equals to true
            this.simplifiedDataModelEnabled = true;
            
            //get the values from custom setting SSLicense
            licenseInstance = SS_License__c.getOrgDefaults();
            licenseInstance.Simplified_Data_Model_Is_Enabled__c = true;
            licenseInstance.Renewal_Amount_Product_Id__c = renewalAmtProdId;
            licenseInstance.Adds_Amount_Product_Id__c = addsAmtProdId;
            upsert licenseInstance;

        } catch (DMLException dmlex) {
            System.debug('in catch dml rollback===');
            Database.rollback(sp);
        } 
        return null;
    }
    
    //private void createDummyProduct(Set<String> activeCurrSet) {
    private List<sObject> createDummyProduct(String defaultOrCorporateCurr) {
        CSM_Util.checkCRUD_FLS('product2', new List<String>{'name', 'isactive'}, CSM_Constants.DML_OPERATION_INSERT);
        List<sObject> prodToBeCreatedList = new List<sObject>();
        sObject renewalAmtProd = createProduct(CSM_Constants.STR_RENEWAL_AMOUNT_PRODUCT, true, defaultOrCorporateCurr);
        sObject addsAmtProd = createProduct(CSM_Constants.STR_ADDS_AMOUNT_PRODUCT, true, defaultOrCorporateCurr);
        prodToBeCreatedList.add(renewalAmtProd);
        prodToBeCreatedList.add(addsAmtProd);
        return  prodToBeCreatedList;        
    }
    
    private sObject createProduct(String prodName, Boolean isActive, String currIsoCode) {
        sObject productSobj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_ASSET_PRODUCT2).newSObject() ; 
        productSobj.put('Name', prodName);
        productSobj.put('IsActive', isActive);
        if (isMultiCurrencyOrg) {
            productSobj.put('CurrencyIsoCode', currIsoCode);
        }
        return productSobj;
    }

    private List<sObject> insertPriceBookEntry(List<Id> productIds, Set<Id> pbIdSet, Set<String> currIsoCodeList) {
        System.debug('productIds in insertPriceBookEntry ===' + productIds);
        System.debug('pbIdSet in insertPriceBookEntry ===' + pbIdSet);
        System.debug('currIsoCodeList in insertPriceBookEntry ===' + currIsoCodeList);
        CSM_Util.checkCRUD_FLS('pricebookentry', new List<String>{'IsActive', 'UseStandardPrice', 'UnitPrice'}, CSM_Constants.DML_OPERATION_INSERT);
        List<sObject> pbeList = new List<sObject>();
        for (String currIsoCode : currIsoCodeList) {
            for (Id pbId : pbIdSet) {
                sObject pbeSobj1 = Schema.getGlobalDescribe().get('PricebookEntry').newSObject() ;
                pbeSobj1.put('Product2Id', productIds[0]);
                pbeSobj1.put('Pricebook2Id', pbId);
                pbeSobj1.put('IsActive', true);
                if (isMultiCurrencyOrg) {
                    pbeSobj1.put('CurrencyIsoCode', currIsoCode);
                }
                pbeSobj1.put('UseStandardPrice', false);
                pbeSobj1.put('UnitPrice', 0.0);
                pbeList.add(pbeSobj1);
                
                sObject pbeSobj2 = Schema.getGlobalDescribe().get('PricebookEntry').newSObject() ;
                pbeSobj2.put('Product2Id', productIds[1]);
                pbeSobj2.put('Pricebook2Id', pbId);
                pbeSobj2.put('IsActive', true);
                if (isMultiCurrencyOrg) {
                    pbeSobj2.put('CurrencyIsoCode', currIsoCode);
                }
                pbeSobj2.put('UseStandardPrice', false);
                pbeSobj2.put('UnitPrice', 0.0);
                pbeList.add(pbeSobj2);
            }           
        }
        System.debug('pbeList===' + pbeList);   
        return pbeList;
    }
    
    //Added for US2771 : Enable Channel Defaults.
    public PageReference enableChannelDefaultsModel() {
        CHL_EnableChannelDefaultsHelper enableChannelDefaultObj = new CHL_EnableChannelDefaultsHelper();
        Savepoint sp = Database.setSavepoint();
        PageReference pageRef   ;
        try{
            if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
                pageRef = Page.csm_admin;
                enableChannelDefaultObj.createChlPortalDefaultConfigRec();
                pageRef.setRedirect(true);  
            }
        } catch (Exception e) {
            System.debug('@@@ rollback=== ' + e);
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getmessage()));
            pageRef = null;
        } 
        return pageRef;
        
    }
}