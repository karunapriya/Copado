/**
 * Created Date     : Nov 30, 2016
 * Developed By     : Aditya, Comity Designs, Inc.
 *
 * Function         : Controller for segment detail page
 * Support Email    : aditya@comitydesigns.com
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Aditya                   US1863                  Nov 30, 2016    1.0                 Initial development
 * Aditya                   US1949                  Jan 9, 2017                         Iteration 1
 * Aditya                   US2013                  Jan 18, 2017                        Save logic builder filter
 */
public with sharing class REN_SegmentDetailController extends REN_BaseMainController {
    public Boolean isEdit {get; set;}
    public Boolean isSearch {get; set;}
    public Boolean updateinvalidcheck {get; set;}
    public String helpParam {get;set;}
    public REN_Segment__c segment {get; set;}
    public String sectionHeader {get; set;}
    public Boolean isPlaymakerUser {get; private set;}
    public String recordIds {get; set;}
    public String segmentId {get; set;}
    public String criteriaQuery {get; set;}
    public String criteriaQueryModified {get; set;}
    public String REN_DurationField {get; set;}
    public String finalcriteriaQueryModified {get; set;}
    public String createButtonLabel {get; set;}
    public Boolean showGridMessage {get; set;} 
    public Boolean InvalidContactcheck {get; set;} 
    public Boolean isSegmentFieldsVisible {get; set; }
    public List<SelectOption> typeOptions {get; set;}
    
    /*****************************************************/
    
    public String selectedObject{get; set;}
    public String criteria {get; set;}
    public String selCurrency {get; set;}    
    public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
    @TestVisible
    private String nameSpace;
    @TestVisible
    private REN_Renew_Configuration__c renewOppObj;
    private REN_Renew_Configuration__c renewObj;
    private REN_Renew_Configuration__c renewalRenewObj;
    @TestVisible
    private REN_Renew_Configuration__c renewalRenewOpAssetAccountObj;
    public Boolean displayErrorMsg {get; set;}
    public map<string,REN_LogicBuilderInputWrapper> mapLG{get; set;}
    public string selectedObjectTemp {get; set;}
    public boolean isErrorOnPage {get;set;}

    public CSM_DataGridAttribute segmentDetailGridAttribute {
        set;
        
        get
        {
            if(segmentDetailGridAttribute != null) {
                String segmentType;
                if(Segment == null || String.isEmpty(segment.REN_Type__c)){
                    if(selectedObjectTemp == REN_Constants.OBJ_OPPORTUNITY) {
                        segmentType = REN_Constants.OBJ_SE_TYPE_LOW_TOUCH;              
                    } else if(selectedObjectTemp == REN_Constants.OBJ_ASSET 
                            || selectedObjectTemp == REN_Constants.OBJ_REN_RENEWS_TO 
                            || selectedObjectTemp == REN_Constants.OBJ_AORA) {
                        segmentType = REN_Constants.OBJ_SE_TYPE_ABRLM;
                    }
                } else {
                    segmentType = segment.REN_Type__c;
                }           
                                
              segmentDetailGridAttribute.params = '{"selectedTaskFilter":"' + segmentType + '", "selectedFilterClause":"' + criteriaQueryModified + '","taskOrViewId":"' + InvalidContactcheck + '","accountId":"' + selectedObjectTemp + '","opptyId":"' + segmentId + '"}';
            }
            return segmentDetailGridAttribute;
        }
    }

    public REN_SegmentDetailController() {
        super();
        this.nameSpace = CSM_Util.getNamespace();
        InvalidContactcheck=false;
        updateinvalidcheck=true;
        isErrorOnPage = false;
        try {
            this.isPlaymakerUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_REN_Playmaker);
                    
            if(!this.isPlaymakerUser) {
                return;
            }
                    
            
            helpParam = CSM_Constants.HELP_SEGMENT_DETAIL;
            
            typeOptions = new List<SelectOption>();
            typeOptions.add(new SelectOption(REN_Constants.OBJ_SE_TYPE_ABRLM, REN_Constants.OBJ_SE_TYPE_ABRLM));
            typeOptions.add(new SelectOption(REN_Constants.OBJ_SE_TYPE_LOW_TOUCH, REN_Constants.OBJ_SE_TYPE_LOW_TOUCH));
            
            segmentDetailGridAttribute = new CSM_DataGridAttribute();
            segmentDetailGridAttribute.tableName = 'SegmentDetail';
            segmentDetailGridAttribute.objectType  = 'SegmentDetail';
            segmentDetailGridAttribute.viewName = 'SegmentDetail';
            segmentDetailGridAttribute.gridToolBarId = 'grid-toolbar';
            segmentDetailGridAttribute.hasSearch = 'true';
            segmentDetailGridAttribute.stateSave = 'true';
            segmentDetailGridAttribute.hasShowColumns = 'true';
            segmentDetailGridAttribute.showExport ='true';
            segmentDetailGridAttribute.showGlobalSelect = 'true';
            
            Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
            segmentDetailGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());            
            
            segmentId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
            populateSegmentInfo();
            
            isSearch = false;
            showGridMessage = false;
            
            this.selectedObject = REN_Constants.OBJ_ASSET;
            this.selectedObjectTemp = REN_Constants.OBJ_ASSET;
            
            if(String.isNotEmpty(segment.REN_Last_Filter__c)) {
                if(segment.REN_Last_Filter__c == REN_Constants.OBJ_AORA) {
                    this.selectedObject = REN_Constants.OBJ_REN_RENEWS_TO;
                    this.selectedObjectTemp = segment.REN_Last_Filter__c;
                } else {
                    this.selectedObject = this.selectedObjectTemp = segment.REN_Last_Filter__c;
                }
            } else if(String.isNotEmpty(segment.REN_Type__c)) {
                if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
                    this.selectedObject = this.selectedObjectTemp = REN_Constants.OBJ_OPPORTUNITY;
                }
            }
            isSegmentFieldsVisible = true;
            /*if(String.isNotEmpty(segment.REN_Type__c)) {
                if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
                    isSegmentFieldsVisible = true;
                }
            }*/
            
            displayErrorMsg = false;
            
            if(segmentId != null) {
                this.renewObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(segmentId + '_Asset_Filter');
                this.renewalRenewObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(segmentId + '_AOR_Filter');
                this.renewalRenewOpAssetAccountObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(segmentId + '_AORA_Filter');
                this.renewOppObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(segmentId + '_Oppt_Filter');
            }
            
            if(this.renewObj == null) {
                this.renewObj = new REN_Renew_Configuration__c();
            }
            
            if(this.renewalRenewObj == null) {
                this.renewalRenewObj = new REN_Renew_Configuration__c();
            }
            
            if(this.renewalRenewOpAssetAccountObj == null) {
                this.renewalRenewOpAssetAccountObj = new REN_Renew_Configuration__c();
            }
            
            if(this.renewOppObj == null) {
                this.renewOppObj = new REN_Renew_Configuration__c();
            }
            
            this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
            mapLG = new map<string,REN_LogicBuilderInputWrapper>();
            
            REN_LogicBuilderInputWrapper rrLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_ASSET, 
                                            'SegmentFiltereAsset_', true, this, 'Segmentation Filter', 
                                            'refreshLB3', 'onChangeDate4', false, '');
            this.lbInputWrapperList.add(rrLogicBuilderInputWrapper);   
            mapLG.put(REN_Constants.OBJ_ASSET,rrLogicBuilderInputWrapper);
            
              REN_LogicBuilderInputWrapper rrAOLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewalRenewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                                'SegmentFilterRLI_', true, this, 'Segmentation Filter', 
                                                'refreshLB3', 'onChangeDate4', false, this.nameSpace + 'REN_Renews_To__c' + ',' + this.nameSpace + 'REN_Asset__c');
            this.lbInputWrapperList.add(rrAOLogicBuilderInputWrapper);  
            mapLG.put(REN_Constants.OBJ_REN_RENEWS_TO,rrAOLogicBuilderInputWrapper);
            
            REN_LogicBuilderInputWrapper rrAOALogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewalRenewOpAssetAccountObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                                'SegmentFilterRLIAcc_', true, this, 'Segmentation Filter', 
                                                'refreshLB3', 'onChangeDate4', false, this.nameSpace + 'REN_Renews_To__c' + ',' + this.nameSpace + 'REN_Renews_To__c.AccountId' + ',' + this.nameSpace + 'REN_Asset__c');
            this.lbInputWrapperList.add(rrAOALogicBuilderInputWrapper);   
             mapLG.put(REN_Constants.OBJ_AORA,rrAOALogicBuilderInputWrapper);
             
            REN_LogicBuilderInputWrapper oppLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewOppObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_OPPORTUNITY, 
                                                'SegmentFilterOpportunity_', true, this, 'Segmentation Filter', 
                                                'refreshLB3', 'onChangeDate4', true, '');
            this.lbInputWrapperList.add(oppLogicBuilderInputWrapper);   
            mapLG.put(REN_Constants.OBJ_OPPORTUNITY,oppLogicBuilderInputWrapper);
            REN_DurationField=String.valueOf(segment.REN_Duration__c);
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));     
        }   
    }
    
    /*
    **@Description calculates difference between startdate and endadate
    */
    public PageReference calculateDateDifference() {
        String startDate = String.valueOf(segment.REN_Start_Date__c);
        String endDate = String.valueOf(segment.REN_End_Date__c);
        System.debug('segment.REN_Start_Date__c: '+segment.REN_Start_Date__c+', segment.REN_End_Date__c: '+segment.REN_End_Date__c);
        if(String.isBlank(startDate) || String.isBlank(endDate)) {
            REN_DurationField='';
        } else {
            REN_DurationField = String.valueOf(segment.REN_Start_Date__c.daysBetween(segment.REN_End_Date__c));
        }
        return null;
    }
    
     public PageReference onSegmentTypeChange(){
        System.debug('segment.REN_Type__c##'+segment.REN_Type__c);
        if(segment.REN_Type__c ==  REN_Constants.OBJ_SE_TYPE_ABRLM){
            isSegmentFieldsVisible = true;
        }else if(segment.REN_Type__c ==  REN_Constants.OBJ_SE_TYPE_LOW_TOUCH ){
            isSegmentFieldsVisible = true;
        }
        return null;
    }
   
    /*
    ** @Description: Add segment members to segment
    */
    public PageReference addMembersToSegmentClick() {
        try {
        	CSM_TriggerManager.disableAllTriggers();
            showGridMessage = false;
            //system.debug('addMembersToSegmentClick : ' + recordIds);
            
            if(String.isNotEmpty(recordIds)) {
                List<String> splitRecordIds = recordIds.split('-');
                
                if(splitRecordIds.size() > 0) {
                    List<REN_Segment_Member__c> segmentMembers = new List<REN_Segment_Member__c>();
                    
                    Set<String> selectedoppid = new Set<String>();
                    for(String recordId : splitRecordIds)
                    {
                        selectedoppid.add(recordId);
                    }
                    map<String,id> opptocr = new map<String,id>();
                    list<OpportunityContactRole> cr=REN_OpportunityDataAccess.getOpportunityContactRoles(selectedoppid);
                    for(OpportunityContactRole CRL:cr){
                        opptocr.put(CRL.opportunityid, CRL.contactid);
                    }
                    //Added below code for US2156, to encrypt oppId and store in custom field 
                    SS_License__c licenseInstance = SS_License__c.getOrgDefaults(); 
                    if(licenseInstance.REN_AES_Encryption_Key__c != null && String.isNotBlank(licenseInstance.REN_AES_Encryption_Key__c)) {
                        Blob encryptionKey = Crypto.generateAesKey(256);                
                        string keystring = licenseInstance.REN_AES_Encryption_Key__c; //: EncodingUtil.base64Encode(encryptionKey);
                        Blob key = EncodingUtil.base64Decode(keystring);
                        List<opportunity> opptyList = REN_OpportunityDataAccess.getOpportunitySyncQuote(selectedoppid);
                        List<opportunity> opptyListToUpdate = new List<Opportunity>();
                        for(opportunity opp:opptyList) {
                            if(opp.REN_Low_Touch_Renewal_Id__c == null || String.isBlank(opp.REN_Low_Touch_Renewal_Id__c)) {                            
                                opp.REN_Low_Touch_Renewal_Id__c = REN_Util.getEncryptedData(String.valueOf(opp.Id),key);
                                opp.REN_Primary_Contact__c = opptocr != null && opptocr.containskey(opp.Id) ? opptocr.get(opp.Id) : null;
                                opptyListToUpdate.add(opp);
                            }
                        }
                        /*try {
                            if(opptyListToUpdate != null && !opptyListToUpdate.isEmpty()) {
                                REN_OpportunityDataAccess.updateOpportunityforRenewals(opptyList);
                            }
                        } catch (exception ex){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
                        }*/
                        if(opptyListToUpdate != null && !opptyListToUpdate.isEmpty()) {
                            REN_OpportunityDataAccess.updateOpportunityforRenewals(opptyListToUpdate);
                        }
                    }
                    //end code for US2156
                    
                    map<String,Id> oppToSyncQuote = new map<String,id>();
                    List<Opportunity> syncQ = REN_OpportunityDataAccess.getOpportunitySyncQuote(selectedoppid);
                    if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){
                    	for(Opportunity oppQuote:syncQ){                       
                            oppToSyncQuote.put(oppQuote.Id,(ID)oppQuote.get('SyncedQuoteId'));
                        }   
                    }
                    boolean isQouteExtInstalled = CSM_AccessController.hasField('REN_Segment_Member__c',CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__c');
                    for(String recordId : splitRecordIds) {
                        REN_Segment_Member__c segmentMember = new REN_Segment_Member__c();
                        segmentMember.REN_Segment__c = segmentId;
                        
                        if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_ABRLM) {
                            segmentMember.REN_Asset__c = recordId;
                        } else if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
                            segmentMember.REN_Opportunity__c = recordId;
                            segmentMember.REN_Segment_Primary_Contact__c = opptocr.get(segmentMember.REN_Opportunity__c);
                            if(isQouteExtInstalled){
                                if(oppToSyncQuote.containsKey(recordId)){
                                    segmentMember.put(CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__c', oppToSyncQuote.get(recordId));
                                }   
                            } 
                        }
                        
                        segmentMembers.add(segmentMember);
                    }
                   
                    List<REN_Segment_Member__c> segmentMemberList = REN_SegmentMemberDataAccess.insertSegmentMembers(segmentMembers);
                    
                    if(segmentMemberList != null && !segmentMemberList .isEmpty()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.REN_Segment_Members_Added));
                        showGridMessage = true;
                        isErrorOnPage = false;
                    }
                    /*
                    if(segment.REN_Task_Batch_Status__c == 'Task created'){
                        REN_Segment__c segmentObj = new REN_Segment__c(id = segmentId, REN_Task_Batch_Status__c = 'Re-run batch');
                        REN_SegmentDataAccess.saveSegments(new List<REN_Segment__c>{segmentObj});
                    }*/
                    updateCriteriaQuery();
                }
            }
        }
        catch (exception ex)
        {
            isErrorOnPage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            showGridMessage = true;            
        }
        
        return null;
    }
    
    /*
    ** @Description: Navigate to segment members
    */
    public PageReference navigateToSegmentMembers() {
        PageReference pageRef = Page.REN_SegmentAdditionalDetails;
        pageRef.getParameters().put('parentId', segment.Id);
        pageRef.getParameters().put('tabCategory', 'Playmaker');
        pageRef.getParameters().put('src', 'segmentdetail');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference saveLastFilter() {
        if(String.isNotEmpty(segmentId)) {
            List<REN_Segment__c> segments = REN_SegmentDataAccess.getSegmentsById(new Set<String>{ segmentId });
            
            if(segments != null && !segments.isEmpty()) {
                REN_Segment__c segmentTemp = segments[0];
                segment.REN_Last_Filter__c = segmentTemp.REN_Last_Filter__c = this.selectedObjectTemp;
                //segment.REN_Task_Batch_Status__c = segmentTemp.REN_Task_Batch_Status__c;
                REN_SegmentDataAccess.saveSegments(new List<REN_Segment__c>{ segmentTemp });
            }
        }
        
        return null;
    }
    
    /*
    ** @Description: Save segment details
    */
    public PageReference saveButtonClick(){
        try {            
            isSearch = false;
            showGridMessage = false;
            
            if(segment.REN_Start_Date__c != null && segment.REN_End_Date__c != null && segment.REN_Start_Date__c > segment.REN_End_Date__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_START_DATE_LESS_THAN_OR_EQUAL_TO_END_DATE));
                return null;
            }else if (segment.REN_End_Date__c != null && segment.REN_Start_Date__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_END_DATE_SET_YOU_MUST_HAVE_START_DATE));
                return null;
            }/*else if (segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH){
                segment.REN_Start_Date__c = null;
                segment.REN_End_Date__c = null;
                segment.REN_Status__c = null;
            }*/
            
            if(String.isEmpty(segment.Name)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_Segment_Name_Validation));
            } else {
                if(String.isEmpty(segmentId)) {
                    if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_ABRLM) {
                        segment.REN_Last_Filter__c = REN_Constants.OBJ_ASSET;
                    } else if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
                        segment.REN_Last_Filter__c = REN_Constants.OBJ_OPPORTUNITY;
                    }
                    
                    this.selectedObject = this.selectedObjectTemp = segment.REN_Last_Filter__c;
                }
                
                List<REN_Segment__c> segments = REN_SegmentDataAccess.saveSegments(new List<REN_Segment__c>{ segment });
                
                if(!segments.isEmpty() && !ApexPages.HasMessages(ApexPages.SEVERITY.ERROR)) {
                    segment = segments[0];
                    
                    if(String.isEmpty(segmentId)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.REN_Segment_Create_Success));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.REN_Segment_Save_Success));
                    }
                    
                    segmentId = segment.Id;                 
                    populateSegmentInfo();
                }
                
                //system.debug('@@@@@@@@@@@@ ' + this.selectedObject);
                //system.debug('@@@@@@@@@@@@ ' + this.selectedObjectTemp);
            }
            
        }
        
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        
        return null;
    }
    
    /*
    ** @Description: Load segment details
    */
    @TestVisible
    private void populateSegmentInfo() {
        if(!String.isEmpty(segmentId)) {    
            if(segment == null) {
                List<REN_Segment__c> segments = REN_SegmentDataAccess.getSegmentsById(new Set<String>{ segmentId });
                
                if(segments != null && !segments.isEmpty()) {
                    segment = segments[0];
                }
            }
            
            sectionHeader = Label.REN_Segment_Detail_Edit;
            createButtonLabel = Label.CSM_LBL_SAVE;
            isEdit = true;
        } else {
            isEdit = false;
            segment = new REN_Segment__c();
            sectionHeader = Label.REN_Segment_Detail_Create;
            createButtonLabel = Label.CSM_LBL_CREATE;
        }
        
        isSearch = false;
    }
    
    /*
    ** @Description: Update query returned from logic builder
    */
    public void updateCriteriaQuery() {
        String modifiedQuery = '';
        criteriaQueryModified=criteriaQuery;
        finalcriteriaQueryModified=criteriaQueryModified;
        //finalcriteriaQueryModified=criteriaQueryModified;
        
        if(InvalidContactcheck){
            if(selectedObjectTemp == REN_Constants.OBJ_ASSET) {
                if(String.isEmpty(criteriaQueryModified)){
                    criteriaQueryModified =  ' (Contact.email = NULL) ';
                }else{
                    criteriaQueryModified += ' AND ' + ' (Contact.email = NULL) ';
                }   
            }else if(selectedObjectTemp == REN_Constants.OBJ_REN_RENEWS_TO || selectedObjectTemp == REN_Constants.OBJ_AORA){
                if(String.isEmpty(criteriaQueryModified)){
                    criteriaQueryModified =  'REN_Asset__r.Contact.email = NULL';
                }else{
                    criteriaQueryModified += ' AND ' + 'REN_Asset__r.Contact.email = NULL';
                } 
            }
        }else{
            if(selectedObjectTemp == REN_Constants.OBJ_ASSET) {
                if(String.isEmpty(criteriaQueryModified)){
                    criteriaQueryModified =  ' (Contact.email != NULL) ';
                }else{
                    criteriaQueryModified += 'AND ' + ' (Contact.email != NULL) ';
                }   
            }else if(selectedObjectTemp == REN_Constants.OBJ_REN_RENEWS_TO || selectedObjectTemp == REN_Constants.OBJ_AORA){
                if(String.isEmpty(criteriaQueryModified)){
                    criteriaQueryModified =  'REN_Asset__r.Contact.email != NULL';
                }else{
                    criteriaQueryModified += 'AND ' + 'REN_Asset__r.Contact.email != NULL';
                } 
            }
        }
        
        system.debug('## updateCriteriaQuery: ' + criteriaQueryModified);
    }
    
    public void setcriteriaQueryModified()
    {
        criteriaQueryModified=finalcriteriaQueryModified;
        if(InvalidContactcheck){
            if(!criteriaQueryModified.equals('error')){
                if(selectedObjectTemp==REN_Constants.OBJ_ASSET){
                    if(String.isEmpty(criteriaQueryModified)){
                        criteriaQueryModified =  '(Contact.email = NULL)';
                    }else{
                        criteriaQueryModified += 'AND ' + '(Contact.email = NULL)';
                    }   
                }else if(selectedObjectTemp == REN_Constants.OBJ_REN_RENEWS_TO || selectedObjectTemp == REN_Constants.OBJ_AORA){
                    if(String.isEmpty(criteriaQueryModified)){
                        criteriaQueryModified =  'REN_Asset__r.Contact.email = NULL';
                    }else{
                        criteriaQueryModified += 'AND ' + 'REN_Asset__r.Contact.email = NULL';
                    }
                }
            }
        }else{
            if(criteriaQueryModified != null && !criteriaQueryModified.equals('error')){
                if(selectedObjectTemp==REN_Constants.OBJ_ASSET){
                    if(String.isEmpty(criteriaQueryModified)){
                        criteriaQueryModified =  '(Contact.email != NULL)';
                    }else{
                        criteriaQueryModified += 'AND ' + '(Contact.email != NULL)';
                    }   
                }else if(selectedObjectTemp == REN_Constants.OBJ_REN_RENEWS_TO || selectedObjectTemp == REN_Constants.OBJ_AORA){
                    if(String.isEmpty(criteriaQueryModified)){
                        criteriaQueryModified =  'REN_Asset__r.Contact.email != NULL';
                    }else{
                        criteriaQueryModified += 'AND ' + 'REN_Asset__r.Contact.email != NULL';
                    } 
                }
            }
        }       
    }
    /*
    ** @Description: Get segment filter picklist values
    */
    public List<SelectOption> getItems(){
        showGridMessage = false;
        //updateinvalidcheck=true;
        List<SelectOption> options = new List<SelectOption>();
        
        if(segment != null){            
            if(String.isNotEmpty(segment.REN_Type__c)) {
                if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
                    options.add(new SelectOption(REN_Constants.OBJ_OPPORTUNITY, Label.REN_Segment_Filter_Opportunity));
                } else if(segment.REN_Type__c == REN_Constants.OBJ_SE_TYPE_ABRLM){
                    options.add(new SelectOption(REN_Constants.OBJ_ASSET, Label.REN_Segment_Filter_Asset));
                    options.add(new SelectOption(REN_Constants.OBJ_AORA, Label.REN_Segment_Filter_AORA));
                    options.add(new SelectOption(REN_Constants.OBJ_REN_RENEWS_TO, Label.REN_Segment_Filter_AOR));
                }
            } else {
                options.add(new SelectOption(REN_Constants.OBJ_ASSET, Label.REN_Segment_Filter_Asset));
                options.add(new SelectOption(REN_Constants.OBJ_AORA, Label.REN_Segment_Filter_AORA));
                options.add(new SelectOption(REN_Constants.OBJ_REN_RENEWS_TO, Label.REN_Segment_Filter_AOR));           
                options.add(new SelectOption(REN_Constants.OBJ_OPPORTUNITY, Label.REN_Segment_Filter_Opportunity));
            }
        } else {
            options.add(new SelectOption(REN_Constants.OBJ_ASSET, Label.REN_Segment_Filter_Asset));
            options.add(new SelectOption(REN_Constants.OBJ_AORA, Label.REN_Segment_Filter_AORA));
            options.add(new SelectOption(REN_Constants.OBJ_REN_RENEWS_TO, Label.REN_Segment_Filter_AOR));
            options.add(new SelectOption(REN_Constants.OBJ_OPPORTUNITY, Label.REN_Segment_Filter_Opportunity));
        }
        
        return options;
    }
    
    /**********************************************/
    
    public PageReference findFor(){
        try{
            createRenewConfig();
            saveLastFilter();
            
            showGridMessage = false;
            
            if(!Test.isRunningTest()){
                findForCriteria();
            }
            this.criteria = ApexPages.hasMessages()?'error':this.constructSearchSQOL();
            if(this.criteria.equals('error')){
                criteriaQueryModified=this.criteria;
                finalcriteriaQueryModified=criteriaQueryModified;
            }
            if(this.selectedObject != null && this.selectedObject != '' && !String.isEmpty(this.selectedObject)){
                REN_LogicBuilderCmpCtrl  selectedCtrl = this.findLogicBuilderInstance();    
                //system.debug('selectedCtrl ---' + selectedCtrl);
                this.selCurrency = selectedCtrl.corpCurr;
            }
        }
        catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
        if(ApexPages.hasMessages()) {
            isSearch = false;
        } else {
            isSearch = true;
        }
        updateinvalidcheck=false;
        return null;
    }
    
    private String constructSearchSQOL(){
        String queryField;
        if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
            this.criteria = this.renewObj.REN_Filter_Criteria__c;
            queryField = 'REN_Asset__c';
        }if(this.selectedObject.equals(REN_Constants.OBJ_OPPORTUNITY)){
            this.criteria = this.renewOppObj.REN_Filter_Criteria__c;
            queryField =  REN_Constants.OBJ_OPPORTUNITY;
        }if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
            this.criteria = this.renewalRenewObj.REN_Filter_Criteria__c;
            queryField = nameSpace + 'REN_Renews_To__c';
        }if(this.selectedObjectTemp.equals(REN_Constants.OBJ_AORA)){
            this.criteria = this.renewalRenewOpAssetAccountObj.REN_Filter_Criteria__c;
            queryField = nameSpace + 'REN_Renews_To__c';
        }
        String soqlWhere = '';      
        if(String.isEmpty(criteria)) {
            criteriaQuery = '';
        } else {
            soqlWhere = ' Where ' + '(' + criteria + ')';
            criteriaQuery = '(' + criteria + ')';
        }

        updateCriteriaQuery();
        return soqlWhere;
    }
    
    @TestVisible
    private void findForCriteria(){
        REN_LogicBuilderCmpCtrl  selectedCtrl = this.findLogicBuilderInstance();
        
        selectedCtrl.logicBuilderInput.isSearch=false;
        
        if(selectedCtrl != null){
            selectedCtrl.performFind();
        }
        //system.debug('selectedCtrl--->'+selectedCtrl);
        if(selectedCtrl != null){
            selectedCtrl.performFind();
        }
        //system.debug('selectedCtrl--->'+selectedCtrl);
    }    
   
    private void createRenewConfig()
    {
        if(segment != null) {
            renewObj.REN_Configuration_Type__c = 'Segment Asset Filter';
            renewObj.REN_Is_Active__c = true;
            renewObj.REN_Record_Key__c = segment.Id + '_Asset_Filter';
            renewObj.REN_View_Name__c = segment.Name;
            
            renewalRenewObj.REN_Configuration_Type__c = 'Segment AOR Filter';
            renewalRenewObj.REN_Is_Active__c = true;
            renewalRenewObj.REN_Record_Key__c = segment.Id + '_AOR_Filter';
            renewalRenewObj.REN_View_Name__c = segment.Name;
            
            renewalRenewOpAssetAccountObj.REN_Configuration_Type__c = 'Segment AORA Filter';
            renewalRenewOpAssetAccountObj.REN_Is_Active__c = true;
            renewalRenewOpAssetAccountObj.REN_Record_Key__c = segment.Id + '_AORA_Filter';
            renewalRenewOpAssetAccountObj.REN_View_Name__c = segment.Name;
            
            renewOppObj.REN_Configuration_Type__c = 'Segment Oppt Filter';
            renewOppObj.REN_Is_Active__c = true;
            renewOppObj.REN_Record_Key__c = segment.Id + '_Oppt_Filter';
            renewOppObj.REN_View_Name__c = segment.Name;            
        }
    }
    
    private REN_LogicBuilderCmpCtrl findLogicBuilderInstance(){
        String uniqueLogicBuilderInstance;
        if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO) && this.selectedObjectTemp == REN_Constants.OBJ_AORA){
            uniqueLogicBuilderInstance = 'SegmentFilterRLIAcc__' + this.selectedObject;
        }else if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
            uniqueLogicBuilderInstance = 'SegmentFilterRLI__' + this.selectedObject;
        }else if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
            uniqueLogicBuilderInstance = 'SegmentFiltereAsset__' + this.selectedObject;
        }else if(this.selectedObject.equals(REN_Constants.OBJ_OPPORTUNITY)){
            uniqueLogicBuilderInstance = 'SegmentFilterOpportunity__' + this.selectedObject;
        }
        Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
        return (REN_LogicBuilderCmpCtrl )baseChildControllerMap.get(uniqueLogicBuilderInstance);
    }
    
    public void showLogicBuilder(){
        isSearch = false;
        
        if(this.selectedObjectTemp == REN_Constants.OBJ_AORA){
            this.selectedObject = REN_Constants.OBJ_REN_RENEWS_TO;
        }else
        {
            this.selectedObject = this.selectedObjectTemp;
        }
    }
    
    private void clearCriteria(){
        if(findLogicBuilderInstance() != null){
            REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
            this.clearLogicBuilderValues(selectedCtrl);
        }
    }
    
    private void clearLogicBuilderValues(REN_LogicBuilderCmpCtrl selectedCtrl){
        if(selectedCtrl != null){
            if(selectedCtrl.criteriaWrapperList != null){
                selectedCtrl.criteriaWrapperList.clear();
                selectedCtrl.populateDefaultCriteria();
            }
        }
    }
    
    public with sharing class PricebookEntryException extends Exception {}
}