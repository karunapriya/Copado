public with sharing class CHL_ChannelPartnerAdminPageCtrl extends REN_BaseMainController{
    public List<CHL_OptyFieldsWrapper> opptyFieldsWrapperList { get; set; }
    public CHL_Opportunity_Status_Log__c chlStatusLogObj {get;set;}
    public string selectedField {get;set;}
    public string fieldToDelete {get;set;}
    public List<SelectOption> FieldList{get;set;}
    public String channelNoAccessMsg {get; private set;}
    public integer daysBeforeExpiration {get;set;}
    public integer daysBetweenUpdates {get;set;}
    //US896
    public List<CHL_MultiSelectListWrapper> multiSelectWrpList{get;set;}
    public List<CHL_SalesStageMappingWrapper> salesStageMappingWrpList{get;set;}
    //public CHL_MultiSelectListWrapper multiSelectWrp{get;set;}
    
    public Boolean hasChannelAccess {
        get;
        private set;
    }
    public Boolean theLinksAreVisible {
        get;
        private set;
    }
    public String helpParam {
        get;
        set;
    }
    
    public CHL_ChannelPartnerAdminPageCtrl() {
        String namespace = CSM_Util.getNamespace();
        this.theLinksAreVisible = true;
       // SS_LicenseCheck.getUserType();
        channelNoAccessMsg = SS_Constants.SS_NO_LICENSE_MSG;  
        hasChannelAccess =  SS_LicenseCheck.getInstance().isChannelEnabled;
            
        helpParam = CSM_Constants.HELP_CHANNEL_PORTAL_CONFIGURATION;
        multiSelectWrpList = new List<CHL_MultiSelectListWrapper>();
        salesStageMappingWrpList = new List<CHL_SalesStageMappingWrapper>();
        init();
        
        List<String> srcList =  CHL_Util.fetchPartnerOppStagePicklistValues();
        Map<String,Set<String>> savedSalesStages = CHL_Util.getPipelineandAvlSalesStage();
        Set<String> destinationSet = savedSalesStages.get(CHL_Constants.STR_AVLBL_STAGES);
        List<String> sourceList = getSourceSalesStageOptions(srcList, new List<String>(destinationSet));
        multiSelectWrpList.add(new  CHL_MultiSelectListWrapper('avlblSS',Label.CHL_LBL_NOT_AVAILABLE_TO_PARTNER,Label.CHL_LBL_AVAILABLE_TO_PARTNER, sourceList, new List<String>(destinationSet),'avlbsalesRght','avlbsalesLft','avlbSalesUp','avlbSalesDown',this,true,0));
        
        // List initialization for multi language option
        Map<String,String> languageOption = CHL_Util.fetchUserLanguagePicklistValue(); // Fetch all available language
        Map<String,String> savedLanguages = CHL_Util.getActiveLanguges(); // Get all Active language selected by User
        Set<String> destinationLanguageSet = new Set<String>(savedLanguages.values());// Put these selected Languages to Set
        List<String> sourceLangList = getSourceLanguages(languageOption.values(),new List<String>(destinationLanguageSet)); // Generate source list based on selected Languages options. here we need to exclude active language options.
        List<String> srcLangList = languageOption.values();
        
        
        
        
        destinationSet = savedSalesStages.get(CHL_Constants.STR_PIPELINE_STAGES);
        sourceList = getSourceSalesStageOptions(srcList, new List<String>(destinationSet));
        salesStageMappingWrpList.add(new CHL_SalesStageMappingWrapper('CHL_SalesStageMappingCompCtrl',this,Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Master_Opportunity_Sales_Stage__c.label,
        Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Partner_Opportunity_Sales_Stage__c.label,
        Schema.SobjectType.CHL_Sales_Stage_Mapping__c.fields.CHL_Partner_Opportunity_Type__c.label,
        'Opportunity','StageName',namespace+'CHL_Sales_Stage_Mapping__c',namespace+'CHL_Partner_Opportunity_Type__c',namespace+'CHL_Partner_Opportunity__c',namespace+'CHL_Sales_Stage__c'));
        
        multiSelectWrpList.add(new CHL_MultiSelectListWrapper('dsplaySS',Label.CHL_HIDDEN_FROM_PIPELINE,Label.CHL_DISPLAY_IN_PIPELINE, sourceList, new List<String>(destinationSet),'displaySalesRght','displaySalesLft','displaySalesUp','displaySalesDown',this,false,0));
        
        // This list will be displayed for language options.
        multiSelectWrpList.add(new CHL_MultiSelectListWrapper('actvLang',Label.CHL_Available_Languages,Label.CHL_Displayed_Languages, sourceLangList, new List<String>(destinationLanguageSet),'avlbLangRght','avlbLangLft','avlbLangUp','avlbLangDown',this,true,1));
       
       //US1687
       destinationSet = savedSalesStages.get(CHL_Constants.STR_EXCLUDE_STAGES);
       sourceList = getSourceSalesStageOptions(srcList, new List<String>(destinationSet));
       multiSelectWrpList.add(new CHL_MultiSelectListWrapper('excludeSS',Label.CHL_LBL_AVAILABLE_SALES_STAGE,Label.CHL_LBL_EXCLUDED_SALES_STAGE, sourceList, new List<String>(destinationSet),'excludeSalesRght','excludeSalesLft','excludeSalesUp','excludeSalesDown',this,false,0)); 
    }
    
    private void init(){
        try{
            List<CHL_Opportunity_Status_Log__c> channelOpptyStatusLogList =  CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
            if(channelOpptyStatusLogList != null && !channelOpptyStatusLogList.isEmpty())   {
                this.chlStatusLogObj = channelOpptyStatusLogList[0];
                daysBeforeExpiration = integer.valueof(channelOpptyStatusLogList[0].CHL_Days_before_Expiration__c);
                //daysBetweenUpdates = integer.valueof(channelOpptyStatusLogList[0].CHL_Days_between_Update__c);
            }   else {
                this.chlStatusLogObj = new CHL_Opportunity_Status_Log__c();
            }
            opptyFieldsWrapperList = new List<CHL_OptyFieldsWrapper>();
            this.FieldList = new List<SelectOption>();
            String checkFieldValues= '';
            if(this.chlStatusLogObj != null && String.isNotBlank(this.chlStatusLogObj.CHL_Field_API_Names__c)){
                checkFieldValues= this.chlStatusLogObj.CHL_Field_API_Names__c;
            }
            Set<String> monitorFieldSet = new Set<String>(checkFieldValues.split(';'));
            
            opptyFieldsWrapperList.add(new CHL_OptyFieldsWrapper(Label.CHL_LBL_MONITOR_FIELD_SALES_STAGE,CHL_Constants.OBJ_PO_SALES_STAGE, true));
            
            if(string.isBlank(this.chlStatusLogObj.CHL_Field_API_Names__c) || monitorFieldSet.contains(CHL_Constants.OBJ_PO_CLOSE_DATE))    {
                opptyFieldsWrapperList.add(new CHL_OptyFieldsWrapper(Label.CHL_LBL_MONITOR_FIELD_CLOSE_DATE, 
                                                CHL_Constants.OBJ_PO_CLOSE_DATE, false));
            }
            else if(!monitorFieldSet.contains(CHL_Constants.OBJ_PO_CLOSE_DATE)) {
                FieldList.add(new SelectOption(CHL_Constants.OBJ_PO_CLOSE_DATE,Label.CHL_LBL_MONITOR_FIELD_CLOSE_DATE));
            }
            if(string.isBlank(this.chlStatusLogObj.CHL_Field_API_Names__c) || monitorFieldSet.contains(CHL_Constants.OBJ_PO_PROBABILITY))   {
                opptyFieldsWrapperList.add(new CHL_OptyFieldsWrapper(Label.CHL_LBL_MONITOR_FIELD_PROBABILITY, 
                                                CHL_Constants.OBJ_PO_PROBABILITY, false));
            }
            else if(!monitorFieldSet.contains(CHL_Constants.OBJ_PO_PROBABILITY))    {
                FieldList.add(new SelectOption(CHL_Constants.OBJ_PO_PROBABILITY,Label.CHL_LBL_MONITOR_FIELD_PROBABILITY));
            }
            CSM_Util.sortSelectOptionByLabel(FieldList);
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
    }    
    
    
    public PageReference save() {
        try {       
            String AvlSalesStage ;
            String dsplaySalesStage;
            String actvLang;
            String excludeStages;
            Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
            for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
                if(baseChildController instanceof CHL_ManagePickListValuesContrl){
                    CHL_ManagePickListValuesContrl pckContrl = (CHL_ManagePickListValuesContrl)baseChildController;
                    if(pckContrl.multiSelectWrp.keyClassName.equalsIgnoreCase('avlblSS')){
                        AvlSalesStage= pckContrl.getAllOptionsFromRight();
                    }
                    else if(pckContrl.multiSelectWrp.keyClassName.equalsIgnoreCase('dsplaySS')){
                        dsplaySalesStage = pckContrl.getAllOptionsFromRight();
                    }else if(pckContrl.multiSelectWrp.keyClassName.equalsIgnoreCase('actvLang')){//This key has been added when we instantiate Active language wrapper.                        
                        actvLang = mapLangWithCode(pckContrl.getAllOptionsFromRight());
                    } else if(pckContrl.multiSelectWrp.keyClassName.equalsIgnoreCase('excludeSS')){                        
                        excludeStages = pckContrl.getAllOptionsFromRight();
                    }
                } else if(baseChildController instanceof CHL_SalesStageMappingCompCtrl) {
                    ((CHL_SalesStageMappingCompCtrl)baseChildController).performSave();
                }
            }
        
            //String AvlSalesStage =    multiSelectWrpList[0].getAllOptionsFromRight();
            if(chlStatusLogObj.CHL_Days_between_Update__c == null  ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CHL_PARTNER_ADMIN_MSG)); 
            } else if(Integer.valueOf(chlStatusLogObj.CHL_Days_between_Update__c) < 0 ) { //this.chlStatusLogObj.CHL_Days_between_Update__c
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CHL_MSG_NO_OF_DAYS_VALIDATION));             
            } else  if(daysBeforeExpiration != null && daysBeforeExpiration < 0 && !string.isblank(string.valueof(daysBeforeExpiration))) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CHL_MSG_DAYS_UNTIL_EXPIRATION_VALIDATION));
            } else  {   
                
                this.chlStatusLogObj.CHL_Days_before_Expiration__c = daysBeforeExpiration;
                //this.chlStatusLogObj.CHL_Days_between_Update__c = daysBetweenUpdates;
                this.chlStatusLogObj.CHL_Field_API_Names__c = getFieldsToMonitorStr();   
                if(AvlSalesStage != null){
                    this.chlStatusLogObj.CHL_Available_Sales_Stages__c = AvlSalesStage;
                } 
                if(dsplaySalesStage != null){
                    this.chlStatusLogObj.CHL_Display_Pipeline_Sales_Stages__c = dsplaySalesStage;
                }
                if(actvLang != null){
                    this.chlStatusLogObj.CHL_Active_Languages__c = actvLang;
                }
                if(excludeStages != null){
                    this.chlStatusLogObj.CHL_Exclude_Sales_Stages__c = excludeStages;
                }
                List<CHL_Opportunity_Status_Log__c> optyStatusLogList = new List<CHL_Opportunity_Status_Log__c> {this.chlStatusLogObj};
                CHL_OpptyStatusLogDataAccess.upsertOpportunityStatusLogList(optyStatusLogList);                         
            }
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){ 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 
                                        String.format(Label.CHL_MSG_OPPORTUNITY_STATUS_LOG_SAVED, new String[]{'Channel Portal Configuration '})));
            }
            //OBJ_OPSL_DAYS_BEFORE_EXPIRATION
        }
        catch(Exception ex){
            system.debug('IN D ERROR : ');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    public PageReference cancel(){
        PageReference pageRef = Page.chl_channelpartneradmin;
        pageRef.getParameters().put('tabCategory', 'Channel');
        pageRef.setRedirect(true);
        return pageRef;

    } 
    private String getFieldsToMonitorStr(){
        String s ='';
        for(CHL_OptyFieldsWrapper wrapper: opptyFieldsWrapperList){
                if(String.isEmpty(s)){
                    s = wrapper.fieldAPIName;
                }else{
                    s += ';' + wrapper.fieldAPIName;
                }
        }
        return s;
    }
    
    public PageReference addFieldCriteria(){        
        string fieldLabelstr = getFieldLabel();
        this.opptyFieldsWrapperList.add(new CHL_OptyFieldsWrapper(fieldLabelstr,this.selectedField,false));
        removeSelectedField();
        
        return null;
    }
    
    private string getFieldLabel() {
        string fieldLblStr = '';
        for (SelectOption so : this.FieldList) {
            system.debug('this.selectedField; : '+this.selectedField+' so :'+so+ 'so.getValue() : '+so.getValue()); 
            if (String.isNotBlank(this.selectedField) && so.getValue().equals(this.selectedField)) {
                fieldLblStr = so.getlabel();
                break;
            }
        }
        return fieldLblStr;
    }
        
    private void removeSelectedField(){
        for(Integer i=0; i<this.FieldList.size(); i++){
            SelectOption sp = this.FieldList.get(i);
            if(sp.getValue().equals(this.selectedField)){
                this.FieldList.remove(i);
                break;
            }
        }
    }
    
    public PageReference deleteFieldCriteria(){
        if(String.isNotBlank(this.fieldToDelete)){
            
            for(Integer i=0; i<this.opptyFieldsWrapperList.size(); i++){
                CHL_OptyFieldsWrapper wrapper = this.opptyFieldsWrapperList.get(i);
                if(String.isNotBlank(wrapper.fieldAPIName) && wrapper.fieldAPIName.equals(this.fieldToDelete)){
                    this.opptyFieldsWrapperList.remove(i);
                    this.FieldList.add(new SelectOption(wrapper.fieldAPIName, wrapper.fieldLabel));
                    break;
                }
            }
            CSM_Util.sortSelectOptionByLabel(this.FieldList);
        }
        return null;
    }
    
   //US896    
   public List<String> getSourceSalesStageOptions(List<String> sourceOptList,List<String> destinationOptList){
        Set<String>  sourceSaleOptionSet = new Set<String>(sourceOptList);
        List<String> objToRemove = new List<String>();
        for(Integer i = destinationOptList.size() - 1; i > -1; i--){
            if(sourceSaleOptionSet.contains(destinationOptList[i])){
                objToRemove.add(destinationOptList[i]);
            }
        }
        sourceSaleOptionSet.removeAll(objToRemove);
        return new List<String>(sourceSaleOptionSet);
    } 
        
    public with sharing class CHL_OptyFieldsWrapper {
        public String fieldLabel{get;set;}
        public String fieldAPIName{get;set;}
        public boolean isFieldRequiredToMonitor{get;set;}
        public CHL_OptyFieldsWrapper(String fieldLabelParam, String fieldNameParam, boolean fieldRequiredFlag) {
            this.fieldLabel = fieldLabelParam;
            this.fieldAPIName = fieldNameParam;
            this.isFieldRequiredToMonitor = fieldRequiredFlag;
        }
    }
    
    public List<String> getSourceLanguages(List<String> lstOfAllLang,List<String> destLang){
            
          
          Set<String>  sourceLangOptionSet = new Set<String>(lstOfAllLang);
          List<String> objToRemove = new List<String>();
          
          sourceLangOptionSet.removeAll(destLang);
          
          return new List<String>(sourceLangOptionSet);
    }
    
    public String mapLangWithCode(String allAvlLang){
        
        Map<String,String> mapOfLangCode = CHL_Util.getMapOfLangAndCode();
        if(allAvlLang!=null){
        List<String> listAllAvlLang = allAvlLang.split(';');
            String concatAvlLang = '';
           for(String lang: listAllAvlLang){
               String code = mapOfLangCode.get(lang);
               concatAvlLang +=code+'-'+lang+';';
           } 
           return concatAvlLang; 
         }   
        return null;
    }
    
}