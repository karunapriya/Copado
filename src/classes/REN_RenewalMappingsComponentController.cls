public with sharing class REN_RenewalMappingsComponentController extends REN_BaseMainController {
    
    public String selectedMapping{get;set;}
    public List<SelectOption> mappingOptionList{get;set;}
    public List<RenewalMappingsWrapper> mappingList{get;set;}
    public List<REN_FieldMappingInputWrapper> inputWrapperList{get;set;}
    public String parentIdsToRefresh {get;set;}
    public Boolean isSolExtLTIntegrator{get;private set;}
    public Boolean hasRenewAccess{get;private set;}
    private Boolean entitlementEnabled;
    private Boolean isAdminUser;
    private Boolean isBusinessAnalyst;
    private String csmNameSpace;

    
    public REN_RenewalMappingsComponentController(){
        selectedMapping = Apexpages.currentPage().getParameters().get('mappingname');
        parentIdsToRefresh='pageMessages, mappingsParentPanel, mappingsPanel';
        entitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        SS_LicenseCheck licenseCheck = SS_LicenseCheck.getInstance();
        isAdminUser= false;
        isBusinessAnalyst = false;
        csmNameSpace = CSM_Util.getNamespace();
        List<profile> profileList = [SELECT Name FROM profile WHERE id = :userinfo.getProfileId() LIMIT 1];
        if (profileList != null && !profileList.isEmpty()) {
            isAdminUser = profileList[0].Name.equalsIgnoreCase('System Administrator')?true:false;
            
        }
         
        if(licenseCheck.isPermissionSetAssigned(SS_Constants.PS_Business_Analyst)){
            isBusinessAnalyst = true;
        }
        this.populateFieldMappingInputWrapper();
        this.populateMappingsList();
        this.populateMappingOptionList();
    }
    
    private void populateFieldMappingInputWrapper(){
        this.inputWrapperList = new List<REN_FieldMappingInputWrapper>();
        if(String.isNotBlank(this.selectedMapping)){
            if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPPTY_TO_REN_OPPTY) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_OPPORTUNITY, system.label.REN_LBL_OPPTY_TO_REN_OPPTY, 
                                                    this, system.label.REN_LBL_RENEWAL_OPPTY_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, system.label.REN_LBL_SRC_OPPTY_FIELD, 
                                                    system.label.REN_LBL_RENEWAL_OPPTY_FIELD, parentIdsToRefresh));
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, system.label.REN_LBL_OPPTY_TO_REN_OPPTY, 
                                                    this, system.label.REN_LBL_OPPTY_LINE_FIELD, '', 
                                                    system.label.REN_LBL_OLI_MAPPING_FIELD, system.label.REN_LBL_SRC_OPPTY_LINE_FIELD, 
                                                    system.label.REN_LBL_OPPTY_LINE_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_ASSET_TO_OPLI) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPORTUNITY, system.label.REN_LBL_ASSET_TO_OPLI, 
                                                    this, system.label.REN_LBL_RENEWAL_OPPTY_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, system.label.REN_ASSET_FIELD, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, parentIdsToRefresh));
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPTY_LINE_ITEM, system.label.REN_LBL_ASSET_TO_OPLI, 
                                                    this, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, system.label.REN_ASSET_FIELD, 
                                                    system.label.REN_LBL_OPPTY_PRD_LINE_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPPTY_TO_SC) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_SERVICE_CONTRACT, system.label.REN_LBL_OPPTY_TO_SC, 
                                                    this, system.label.REN_LBL_SC_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_OPPTY_FIELD, system.label.REN_LBL_SRC_OPPTY_FIELD, 
                                                    system.label.REN_LBL_SC_FIELDS, parentIdsToRefresh));
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_CONTRACT_LINE_ITEM, system.label.REN_LBL_OPPTY_TO_SC, 
                                                    this, system.label.REN_LBL_SC_LINE_ITEM_FIELD, '', 
                                                    system.label.REN_LBL_OLI_MAPPING_FIELD, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, 
                                                    system.label.REN_LBL_SC_LINE_ITEM_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_SC_TO_OPPTY) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_SERVICE_CONTRACT, REN_Constants.OBJ_OPPORTUNITY, system.label.REN_LBL_SC_TO_OPPTY, 
                                                    this, system.label.REN_LBL_OPPTY_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, system.label.REN_LBL_SC_FIELD, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, parentIdsToRefresh));
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_CONTRACT_LINE_ITEM, REN_Constants.OBJ_OPPTY_LINE_ITEM, system.label.REN_LBL_SC_TO_OPPTY, 
                                                    this, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, '', 
                                                    system.label.REN_LBL_OLI_MAPPING_FIELD, system.label.REN_LBL_SC_LINE_ITEM_FIELD, 
                                                    system.label.REN_LBL_OPPTY_PRD_LINE_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPLI_TO_ASSET) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPTY_LINE_ITEM, REN_Constants.OBJ_ASSET, system.label.REN_LBL_OPLI_TO_ASSET, 
                                                    this, system.label.REN_ASSET_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_OPPTY_FIELDS, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, 
                                                    system.label.REN_LBL_ASSET_FIELDS, parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_RR_TO_OPLI) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, system.label.REN_LBL_RR_TO_OPLI, 
                                                    this, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_ASSET_TO_RR) && SS_Constants.isSimplifiedDataModelEnabled && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_ASSET, REN_Constants.OBJ_REN_RENEWS_TO, system.label.REN_LBL_ASSET_TO_RR, 
                                                    this, system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_ASSET_FIELDS,  system.label.REN_LBL_RR_FIELD + 's', parentIdsToRefresh));
            }else if(entitlementEnabled && selectedMapping.equalsIgnoreCase(system.label.REN_LBL_CLI_TO_RR) && SS_Constants.isSimplifiedDataModelEnabled && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_CONTRACT_LINE_ITEM, REN_Constants.OBJ_REN_RENEWS_TO, system.label.REN_LBL_CLI_TO_RR, 
                                                    this, system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_SCLI_FIELDS,  system.label.REN_LBL_RR_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPLI_TO_RR) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPTY_LINE_ITEM,REN_Constants.OBJ_REN_RENEWS_TO, system.label.REN_LBL_OPLI_TO_RR, 
                                                    this, system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, system.label.REN_LBL_RR_FIELD + 's', parentIdsToRefresh));
            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPP_TO_PO) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPORTUNITY,CHL_Constants.PARTNER_OPPORTUNITY_FROM_NAME, system.label.REN_LBL_OPP_TO_PO, 
                                                    this, System.label.REN_LBL_PO_FIELD, System.label.REN_SET_PO_NAME, 
                                                    system.label.REN_LBL_OPPTY_FIELD,system.label.REN_LBL_OPPTY_FIELD,System.label.REN_LBL_PO_FIELD+'s', parentIdsToRefresh));

            }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_CASE_TO_CASE_QR) && (isAdminUser || isBusinessAnalyst)){
                this.inputWrapperList.add(new REN_FieldMappingInputWrapper(CSM_Constants.OBJ_CASE,CSM_Constants.OBJ_CASE, system.label.REN_LBL_CASE_TO_CASE_QR, 
                                                    this, system.label.REN_LBL_CASE_FIELD, system.label.REN_LBL_CASE_FIELD_DESC, 
                                                    system.label.REN_LBL_CASE_FIELD,system.label.REN_LBL_CASE_FIELD,system.label.REN_LBL_CASE_FIELD+'s', parentIdsToRefresh));

            }else if(selectedMapping.equalsIgnoreCase(system.label.CHL_LBL_PO_TO_PO) && (isAdminUser || isBusinessAnalyst)){
                   this.inputWrapperList.add(new REN_FieldMappingInputWrapper(csmNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY, csmNameSpace+CHL_Constants.OBJ_PARTNER_OPPORTUNITY, system.label.CHL_LBL_PO_TO_PO, 
                                                    this, System.label.REN_LBL_PO_FIELD, '', 
                                                    system.label.REN_LBL_PO_FIELD,system.label.REN_LBL_PO_FIELD,System.label.REN_LBL_PO_FIELD+'s', parentIdsToRefresh));                                              
           }
           else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPPORTUNITY_TO_CASE) && (isAdminUser || isBusinessAnalyst)){
                   this.inputWrapperList.add(new REN_FieldMappingInputWrapper(csmNameSpace+REN_Constants.OBJ_OPPORTUNITY, csmNameSpace+CSM_Constants.OBJ_CASE, system.label.REN_LBL_OPPORTUNITY_TO_CASE, 
                                                    this, System.label.REN_LBL_CASE_FIELD, '', 
                                                    system.label.REN_LBL_OPPTY_FIELD,system.label.REN_LBL_OPPTY_FIELD,System.label.REN_LBL_CASE_FIELD+'s', parentIdsToRefresh));                                              
           }
           else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_ACCOUNT_TO_CASE) && (isAdminUser || isBusinessAnalyst)){
                   this.inputWrapperList.add(new REN_FieldMappingInputWrapper(csmNameSpace+CSM_Constants.OBJ_ACCOUNT, csmNameSpace+CSM_Constants.OBJ_CASE, system.label.REN_LBL_ACCOUNT_TO_CASE, 
                                                    this, System.label.REN_LBL_CASE_FIELD, '', 
                                                    system.label.REN_LBL_ACCOUNT_FIELD,system.label.REN_LBL_ACCOUNT_FIELD,System.label.REN_LBL_CASE_FIELD+'s', parentIdsToRefresh));                                              
           }
            else if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) ){
                REN_FieldMappingInputWrapper mappingWrapperObj ;
                if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_QUOTE_TO_OPPTY) && (isAdminUser || isBusinessAnalyst)){
                    
                    mappingWrapperObj = new REN_FieldMappingInputWrapper(  CHL_Constants.OBJ_QUOTE,REN_Constants.OBJ_OPPORTUNITY,system.label.REN_LBL_QUOTE_TO_OPPTY, 
                                                        this, system.label.REN_LBL_OPPTY_FIELD,system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                        system.label.REN_LBL_RR_FIELD, system.label.CHL_LBL_QUOTE_FIELD,system.label.REN_LBL_OPPTY_FIELD + 's', parentIdsToRefresh);
                    mappingWrapperObj.isDefaultShow = false;                                                            
                    this.inputWrapperList.add(mappingWrapperObj);
                    mappingWrapperObj = new REN_FieldMappingInputWrapper(   CHL_Constants.OBJ_QUOTELINEITEM,REN_Constants.OBJ_OPPTY_LINE_ITEM,system.label.REN_LBL_QUOTE_TO_OPPTY, 
                                                        this,system.label.REN_LBL_OPPTY_PRD_LINE_FIELD,system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                        system.label.REN_LBL_RR_FIELD, system.label.CHL_LBL_QUOTE_LI_FIELD, system.label.REN_LBL_OPLI_FIELDS, parentIdsToRefresh);
                    mappingWrapperObj.isDefaultShow = false;                                                                
                    this.inputWrapperList.add(mappingWrapperObj);
                }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_OPPTY_TO_QUOTE) && (isAdminUser || isBusinessAnalyst)){
                    mappingWrapperObj= new REN_FieldMappingInputWrapper(    REN_Constants.OBJ_OPPORTUNITY,CHL_Constants.OBJ_QUOTE,system.label.REN_LBL_OPPTY_TO_QUOTE, 
                                                        this, system.label.CHL_LBL_QUOTE_FIELD , system.label.REN_LBL_MAPPING_SECTION_HEADER, system.label.REN_LBL_RR_FIELD, 
                                                        system.label.REN_LBL_OPPTY_FIELD, system.label.CHL_LBL_QUOTE_FIELD + 's', parentIdsToRefresh);
                    mappingWrapperObj.isDefaultShow = false;                                                                
                    this.inputWrapperList.add(mappingWrapperObj);
                    
                    mappingWrapperObj = new REN_FieldMappingInputWrapper(   REN_Constants.OBJ_OPPTY_LINE_ITEM, CHL_Constants.OBJ_QUOTELINEITEM,system.label.REN_LBL_OPPTY_TO_QUOTE, 
                                                        this, system.label.CHL_LBL_QUOTE_LI_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                        system.label.REN_LBL_RR_FIELD, system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, system.label.CHL_LBL_QUOTE_LI_FIELD + 's', parentIdsToRefresh);
                    mappingWrapperObj.isDefaultShow = false;        
                    this.inputWrapperList.add(mappingWrapperObj);                        
                    
                }else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_QUOTE_TO_QUOTE) && (isAdminUser || isBusinessAnalyst)){
                    mappingWrapperObj = new REN_FieldMappingInputWrapper(  CHL_Constants.OBJ_QUOTE,CHL_Constants.OBJ_QUOTE,system.label.REN_LBL_QUOTE_TO_QUOTE, 
                                                        this, system.label.CHL_LBL_QUOTE_FIELD,system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                        system.label.CHL_LBL_QUOTE_FIELD, system.label.CHL_LBL_SRC_QUOTE_FIELD, system.label.CHL_LBL_QUOTE_FIELD + 's', parentIdsToRefresh);
                    mappingWrapperObj.isDefaultShow = false;                                                            
                    this.inputWrapperList.add(mappingWrapperObj);
                    
                    mappingWrapperObj = new REN_FieldMappingInputWrapper(CHL_Constants.OBJ_QUOTELINEITEM,CHL_Constants.OBJ_QUOTELINEITEM,system.label.REN_LBL_QUOTE_TO_QUOTE, 
                                                        this, system.label.CHL_LBL_QUOTE_LI_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                        system.label.CHL_LBL_QUOTE_LI_FIELD, system.label.CHL_LBL_SRC_QUOTE_LI_FIELD, system.label.CHL_LBL_QUOTE_LI_FIELD + 's', parentIdsToRefresh);
                    mappingWrapperObj.isDefaultShow = false;                                                            
                    this.inputWrapperList.add(mappingWrapperObj);
                }
                else if(selectedMapping.equalsIgnoreCase(system.label.CHL_LBL_RLI_TO_QLI) && (isAdminUser || isBusinessAnalyst)){
                   this.inputWrapperList.add(new REN_FieldMappingInputWrapper(csmNameSpace+REN_Constants.OBJ_REN_RENEWS_TO, CHL_Constants.OBJ_QUOTELINEITEM,system.label.CHL_LBL_RLI_TO_QLI, 
                                                    this, system.label.CHL_LBL_QUOTE_LI_FIELD, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
                                                    system.label.REN_LBL_RR_FIELD,system.label.REN_LBL_RR_FIELD,System.label.CHL_LBL_QUOTE_LI_FIELD+'s', parentIdsToRefresh));                                              
                }
                else if(selectedMapping.equalsIgnoreCase(system.label.REN_LBL_QUOTE_TO_CASE) && (isAdminUser || isBusinessAnalyst)){
                   this.inputWrapperList.add(new REN_FieldMappingInputWrapper(csmNameSpace+CHL_Constants.OBJ_QUOTE, CSM_Constants.OBJ_CASE,system.label.REN_LBL_QUOTE_TO_CASE, 
                                                    this, system.label.REN_LBL_CASE_FIELD, '', 
                                                    system.label.CHL_LBL_QUOTE_FIELD,system.label.CHL_LBL_QUOTE_FIELD,System.label.REN_LBL_CASE_FIELD+'s', parentIdsToRefresh));                                              
                }                 
            }
        }
    }
    
    private void populateMappingsList(){
       // Boolean entitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        this.mappingList = new List<RenewalMappingsWrapper>();
        RenewalMappingsWrapper wrapper;
        //String namespace = CSM_Util.getNamespace();
        //isSolExtLTIntegrator = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator);
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        
        
        if((hasRenewAccess || Test.isRunningTest())  && (isAdminUser || isBusinessAnalyst)){
            wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_ASSET_TO_OPLI, system.label.REN_LBL_ASSET_TO_OPLI_DESC);
            this.mappingList.add(wrapper);
            
            wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPPTY_TO_REN_OPPTY, system.label.REN_LBL_OPPTY_TO_REN_OPPTY_DESC);
            this.mappingList.add(wrapper);
            if(entitlementEnabled){
                wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPPTY_TO_SC, system.label.REN_LBL_OPPTY_TO_SC_DESC);
                this.mappingList.add(wrapper);
                
            }
            wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPLI_TO_ASSET, system.label.REN_LBL_OPLI_TO_ASSET_DESC);
            this.mappingList.add(wrapper);
            if(entitlementEnabled){
                wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_SC_TO_OPPTY, system.label.REN_LBL_SC_TO_OPPTY_DESC);
                this.mappingList.add(wrapper);
            }
            wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_RR_TO_OPLI, system.label.REN_LBL_RR_TO_OPLI_DESC);
            this.mappingList.add(wrapper);
            //us933
            //new mapping for simplified data model
            if(SS_Constants.isSimplifiedDataModelEnabled){
                wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_ASSET_TO_RR, system.label.REN_LBL_ASSET_TO_RR_DESC);
                this.mappingList.add(wrapper);
                if(entitlementEnabled){
                    wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_CLI_TO_RR, system.label.REN_LBL_CLI_TO_RR_DESC);
                    this.mappingList.add(wrapper);
                }
            }
            
            wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPLI_TO_RR, system.label.REN_LBL_OPLI_TO_RR_DESC);
            this.mappingList.add(wrapper);
            
            //US1066-US1069 - Quote Sync. mapping.
            if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)){
                wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_QUOTE_TO_OPPTY, system.label.REN_LBL_QUOTE_TO_OPTY_MAPPINGS_DESC);
                this.mappingList.add(wrapper);
            
                wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPPTY_TO_QUOTE, system.label.REN_LBL_OPTY_TO_QUOTE_MAPPINGS_DESC);
                this.mappingList.add(wrapper);
                
                wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_QUOTE_TO_QUOTE, system.label.REN_LBL_QUOTE_TO_QUOTE_MAPPINGS_DESC);
                this.mappingList.add(wrapper);
                
                wrapper = new RenewalMappingsWrapper(system.label.CHL_LBL_RLI_TO_QLI,system.label.CHL_LBL_RLI_TO_QLI_DESC );
            	this.mappingList.add(wrapper);
            }
            wrapper = new RenewalMappingsWrapper(system.label.REN_RENEWAL_STAT_VAL_MAP, system.label.REN_LBL_VALUE_MAP_DESC);
            this.mappingList.add(wrapper);
            if(UserInfo.isMultiCurrencyOrganization() && CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefixSolnExtn + 'Previous_Local_Currency_Amount__c')){
                wrapper = new RenewalMappingsWrapper(system.label.REN_PREVIOUS_PRICE_CALCULATION, system.label.REN_LBL_DATE_MAP_DESC);
                this.mappingList.add(wrapper);
            }
            wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPP_TO_PO,system.label.REN_LBL_OPP_TO_PO_DESC );
            this.mappingList.add(wrapper);
            wrapper = new RenewalMappingsWrapper(system.label.CHL_LBL_PO_TO_PO,system.label.CHL_LBL_PO_TO_PO_DESC );
            this.mappingList.add(wrapper);
        }
        if((isAdminUser || isBusinessAnalyst)){
            wrapper=new RenewalMappingsWrapper(system.label.REN_PORejectList,system.label.REN_PORejectListDesc );
            this.mappingList.add(wrapper);
        }
        if(hasRenewAccess && (isAdminUser || isBusinessAnalyst)){
            wrapper=new RenewalMappingsWrapper(system.label.REN_LBL_CASE_TO_CASE_QR,system.label.REN_LBL_QR_DESC);        
            this.mappingList.add(wrapper);
        }
        wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_OPPORTUNITY_TO_CASE, system.label.REN_LBL_OPPORTUNITY_TO_CASE_DESC);
        this.mappingList.add(wrapper);
        
        wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_ACCOUNT_TO_CASE, system.label.REN_LBL_ACCOUNT_TO_CASE_DESC);
        this.mappingList.add(wrapper);
        
        wrapper = new RenewalMappingsWrapper(system.label.REN_LBL_QUOTE_TO_CASE, system.label.REN_LBL_QUOTE_TO_CASE_DESC);
        this.mappingList.add(wrapper);
            
    }
    
    public PageReference loadSelectedMapping(){
        if(selectedMapping.equalsIgnoreCase(system.label.REN_RENEWAL_STAT_VAL_MAP)) {
            PageReference pageRef = Page.REN_ValueMapping;
            pageRef.getParameters().put('tabCategory','Renewal');
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        if(selectedMapping.equalsIgnoreCase(system.label.REN_PORejectList)) {
            PageReference pageRef = Page.REN_PORejectMapping;
            pageRef.getParameters().put('tabCategory','Renewal');
            pageRef.setRedirect(true);
            return pageRef;
        }
        if(selectedMapping.equalsIgnoreCase(system.label.REN_PREVIOUS_PRICE_CALCULATION)) {
            valueMappingCheck();
            PageReference pageRef = Page.REN_DateMapping;
            pageRef.getParameters().put('tabCategory','Renewal');
            pageRef.setRedirect(true);
            return pageRef;
        }
         
        return redirectToMappings(false);
    }
    
    public Pagereference redirectToMappings(boolean isCancel){
        PageReference pageRef = Page.REN_RenewalMappings;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        if(!isCancel) 
          pageRef.getParameters().put('mappingname',selectedMapping);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
     public void valueMappingCheck() {
        List<REN_Value_Mapping__c> valueMappingRecList = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RLI_DATE_MAP);
        if(valueMappingRecList == null || valueMappingRecList.isEmpty()){
            REN_Value_Mapping__c valueMappingObj = new REN_Value_Mapping__c();          
            valueMappingObj.REN_Record_Key__c = REN_Constants.REN_RLI_DATE_MAP;
            valueMappingObj.REN_Value__c  = 'None';
            valueMappingRecList = REN_ValueMappingDataAccess.saveValueMappingRecord(new List<REN_Value_Mapping__c>{valueMappingObj});           
            system.debug('----'+valueMappingRecList);
        }
    }
    
    
    public PageReference save(){
        try{
            Map<String, Set<REN_BaseChildController>> mappingToControllerMap = this.getMappingToControllerMap();
            Set<REN_BaseChildController> controllerList = mappingToControllerMap.get(this.selectedMapping);
            if(controllerList != null && !controllerList.isEmpty()){
                for(REN_BaseChildController baseChildController : controllerList){
                    if(baseChildController instanceof REN_FieldMappingComponentController){
                        ((REN_FieldMappingComponentController)baseChildController).save();
                    }else if(baseChildController instanceof REN_RelatedListComponentController){
                        ((REN_RelatedListComponentController)baseChildController).save();
                    }
                }
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 
                                    String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{'Mappings '})));
        }catch(system.DmlException dmlEx){
            if(!dmlEx.getDmlType(0).equals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, dmlEx.getMessage()));
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    public PageReference cancel(){
        return redirectToMappings(true);
    }
    
    private void populateMappingOptionList(){
        this.mappingOptionList = new List<SelectOption>();
        for(RenewalMappingsWrapper renMapping : mappingList){
            this.mappingOptionList.add(new SelectOption(renMapping.mapping, renMapping.mapping));
        }
    }
    
    public class RenewalMappingsWrapper {
        public String mapping{get;set;}
        public String description{get;set;}
        public RenewalMappingsWrapper(String mapping, String description){
            this.mapping = mapping;
            this.description = description;
        }
    }
}