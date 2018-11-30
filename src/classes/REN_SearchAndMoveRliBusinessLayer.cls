public with sharing class REN_SearchAndMoveRliBusinessLayer extends CSM_BusinessLayer {

 private CSM_User_Preferences__c userPreferenceObj = new CSM_User_Preferences__c();
 private  List<Schema.FieldSetMember> fieldSetMemberList =  null;
 public boolean showValidRli;
 public String oppId;
 public String pricebookId;
 public String currencyCode;
 public Set<String> oppCloseStageSet;
 public List<String> firstFilterList;
    public REN_SearchAndMoveRliBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        System.debug('inputWrapper.params.idSet===' + inputWrapper.params.idSet);
        if(inputWrapper.params.isValidRli!=null){
            showValidRli = inputWrapper.params.isValidRli == 'true'?true:false;
        }
        if(inputWrapper.params.opptyId!=null){
            oppId = inputWrapper.params.opptyId;
        }
        if(inputWrapper.params.PriceBook!=null){
            pricebookId = inputWrapper.params.PriceBook;
        }    
        if(inputWrapper.params.currencyCode!=null){
            currencyCode = inputWrapper.params.currencyCode;
        } 
        if(inputWrapper.params.IdSet!=null){
           firstFilterList = inputWrapper.params.idSet;
        }
        userPreferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'REN_Manage_RR_Grid_Columns__c');
        fieldSetMemberList =  SObjectType.REN_Renews_To__c.FieldSets.REN_ManageRenewals_Fieldset.getFields();        
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getRenewalRelationShipWrapperList();
    }
    
    private CSM_GridResponseWrapper getRenewalRelationShipWrapperList()
    {
        CSM_GridResponseWrapper renewalRelationshipWrapperList = new CSM_GridResponseWrapper();
        
        try{
            
            renewalRelationshipWrapperList.header = setRenRelListHeader();
            renewalRelationshipWrapperList.hasAction = false;
            renewalRelationshipWrapperList.hasDetail = false;
            renewalRelationshipWrapperList.hasCheckbox = showValidRli?true:false;
            List<REN_Renews_To__c> RRlist;
             RRlist = getRecordList();
            renewalRelationshipWrapperList.row = setRenRelationshipRows(RRlist, renewalRelationshipWrapperList.header);
            system.debug('\n\n~~~gridResponseWrapper: '+renewalRelationshipWrapperList);
          
        } catch(Exception e) {
            renewalRelationshipWrapperList.errorMessage = e.getMessage();
            system.debug(e.getStackTraceString());              
        }
        system.debug('-----'+renewalRelationshipWrapperList);
         return renewalRelationshipWrapperList;
    } 
    
    private List<REN_Renews_To__c> getRecordList(){
        String filterStr = ''; 
        oppCloseStageSet =new Set<String>();
        Set<String> firstFilterSet = new Set<String>();
        if(firstFilterList != null){
        	firstFilterSet.addAll(firstFilterList);
        }
        if(string.isNotEmpty(this.inputWrapper.params.selectedFilterClause) && this.inputWrapper.params.selectedFilterClause != null && !this.inputWrapper.params.selectedFilterClause.equals('error')) {
            filterStr = this.inputWrapper.params.selectedFilterClause;
            SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();            
            oppCloseStageSet = REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',');          
        }
        String nameSpace = CSM_Util.getNamespace();
        Set<String> additionalFieldSet = new Set<String>{nameSpace+'REN_Renews_To__r.Account.Name',nameSpace+'REN_Product__c',nameSpace+'REN_Renews_To__r.PriceBook2Id',nameSpace+'REN_Renews_To__c',nameSpace+'REN_Renews_To__r.StageName'};
        if(UserInfo.isMultiCurrencyOrganization()){
            additionalFieldSet.add(nameSpace+'REN_Renews_To__r.CurrencyIsoCode');
        }
        List<REN_Renews_To__c> renewalRelationShipList = REN_RenewRelationshipDataAccess.getRliDataUsingFieldSet(
                                                        nameSpace + REN_Constants.OBJ_REN_RENEWS_TO,
                                                        fieldSetMemberList, additionalFieldSet,
                                                        filterStr,firstFilterSet,oppCloseStageSet,showValidRli);
        
        system.debug('renewalRelationshipList::' + renewalRelationShipList);
        return renewalRelationShipList;
        
    }    
    
private List<CSM_GridRowWrapper> setRenRelationshipRows(List<sObject> renewalRelationShipList, List<CSM_GridColumnWrapper> colList) {

        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        String clmNamespace = CSM_Util.getNamespace();
        if(renewalRelationShipList != null && !renewalRelationShipList.isEmpty()) {
            Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
            String userLocale = UserInfo.getLocale();           
            String reasonCode='';
            for(sObject sObj : renewalRelationShipList) {
                System.debug('ZZZ - '+sObj);
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();

                row.id = (String)sObj.get('Id');
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
                row.columns = new List<CSM_GridColumnWrapper>();
                row.namespace = clmNamespace;
                Opportunity opp = (Opportunity)sObj.getSObject(clmNamespace+'REN_Renews_To__r');
                if(opp !=null){
                    if(String.isNotBlank(oppId)&& opp.Id == oppId){
                       reasonCode = Label.REN_LBL_CURRENT_OPP; 
                    }
                    if(String.isNotBlank(pricebookId) && opp.PriceBook2Id != Id.valueOf(pricebookId)){
                       reasonCode +=String.isBlank(reasonCode)?'':', ';
                       reasonCode += Label.REN_LBL_DIFF_PRICEBOOK;
                    }
                    if(String.isNotBlank(currencyCode) && opp.get('CurrencyIsoCode') != currencyCode){
                       reasonCode +=String.isBlank(reasonCode)?'':', ';
                       reasonCode += Label.REN_LBL_DIFF_CURRENCY;  
                    }
                    if(oppCloseStageSet!=null && oppCloseStageSet.contains(opp.StageName)){
                       reasonCode +=String.isBlank(reasonCode)?'':', ';
                       reasonCode += Label.REN_LBL_CLOSED_OPP;   
                    }
                }
                row.reasonCode=reasonCode;
                reasonCode='';
                if (colList!=null){
                   row.columns = colList;
                   gridRowWrapper.add(row); 
                }
            }
        }
         return gridRowWrapper;
    }
        

    private List<CSM_GridColumnWrapper> setRenRelListHeader()
    {
        List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
        String manageRRColumnStr = '';
        if(userPreferenceObj != null){
            if(userPreferenceObj.REN_Manage_RR_Grid_Columns__c != null){
                manageRRColumnStr  = userPreferenceObj.REN_Manage_RR_Grid_Columns__c.toLowerCase();
                system.debug(manageRRColumnStr+'Entire List in Business Layer');
            }
        }
        Set<String> fieldSet = new Set<String>();
        String fldpath ='';
        String nameSpace = CSM_Util.getNamespace();
        Map<String, Schema.SobjectField> fields = REN_Renews_To__c.getSObjectType().getDescribe().fields.getMap();
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            fldpath = fld.getFieldPath();
            fieldSet.add(fldpath);
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName = fldpath;
            system.debug('fld.getFieldPath::'+fldpath);
            gridColumnWrapper.label = fld.getLabel();
            gridColumnWrapper.valueCol = fldpath;
            gridColumnWrapper.dataType = ''+fld.getType();
            
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fldpath.contains('.')){
                DescribeFieldResult dfr = fields.get(fldpath).getDescribe();
                List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                if(!oTypeList.isEmpty()){
                    String refObjName = oTypeList[0].getDescribe().getName();
                    if(CSM_AccessController.hasField(refObjName, 'Name')){
                        gridColumnWrapper.valueCol = dfr.getRelationshipName() + '.Name';
                        gridColumnWrapper.lookUpIdCol = fldpath;                
                    }else if (fld.getFieldPath().contains('REN_Contract_Line_Item__c')){
                        gridColumnWrapper.valueCol = dfr.getRelationshipName() + '.LineItemNumber';
                        gridColumnWrapper.lookUpIdCol = fldpath;                
                    }
                }
            }else if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DATETIME) ){
                gridColumnWrapper.isDateCol = true;
                
            }
            
            gridColumnWrapper.isSortable = true;
            gridColumnWrapper.customColumnSorter = 'customColumnSorter';
            gridColumnWrapper.isCurrencyCol = false;
            if(fld.getType().equals(Schema.DisplayType.CURRENCY)){
                gridColumnWrapper.dataAlign = 'right';
                gridColumnWrapper.label = gridColumnWrapper.label + ' ('+UserInfo.getDefaultCurrency() +')';            
                gridColumnWrapper.isCurrencyCol = true;
            }
            if (fld.getType().equals(Schema.DisplayType.DOUBLE)
                     || fld.getType().equals(Schema.DisplayType.INTEGER)) 
            {           
                gridColumnWrapper.dataAlign = 'right';
            }
            
            
            gridColumnWrapper.isDateCol = fld.getType().equals(Schema.DisplayType.DATE)?true:false;
            if(manageRRColumnStr.contains(gridColumnWrapper.apiName.toLowerCase())){
                gridColumnWrapper.isVisible = false;
            }
             gridColumnWrapperList.add(gridColumnWrapper);
         }      
         
         if(!fieldSet.contains('Id')){
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName = 'Id';
            gridColumnWrapper.label = 'Id';
            gridColumnWrapper.valueCol = 'Id';
            gridColumnWrapper.lookUpIdCol = 'Id';
            gridColumnWrapper.isVisible = false;
            gridColumnWrapper.isSwitchable = false;
            gridColumnWrapper.isSortable = true;
            
            gridColumnWrapperList.add(gridColumnWrapper);   
         }
         if(showValidRli == false){
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName = 'Reason_Code';
            gridColumnWrapper.label = Label.CSM_LBL_RISK_REASON;
            gridColumnWrapper.valueCol = 'Reason_Code';
            gridColumnWrapper.isDateCol = false;
            gridColumnWrapper.filterControl = 'select';
            gridColumnWrapper.isSortable = true;
            gridColumnWrapper.isVisible = true;
            gridColumnWrapper.dataType = 'STRING';
            gridColumnWrapperList.add(gridColumnWrapper);
         }
         if(!fieldSet.contains('REN_Renews_To__r.Account.Name')){
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName ='Account.Name';
            gridColumnWrapper.label = 'Account Name';
            gridColumnWrapper.valueCol = 'REN_Renews_To__r.Account.Name';
            gridColumnWrapper.lookUpIdCol = 'AccountId';
            gridColumnWrapper.isSortable = true;
            gridColumnWrapper.customColumnSorter = 'customColumnSorter';
            gridColumnWrapperList.add(gridColumnWrapper);
         }
         
         if(!fieldSet.contains(CSM_Util.getNamespace() +'REN_Product__c')){
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName = nameSpace + 'REN_Product__c';
            gridColumnWrapper.label = 'Existing Product';
            gridColumnWrapper.valueCol = nameSpace +'REN_Product__c';
            gridColumnWrapper.isDateCol = false;
            gridColumnWrapper.isSortable = true;
            gridColumnWrapper.isVisible = true;
            gridColumnWrapper.dataType = 'STRING';
            gridColumnWrapperList.add(gridColumnWrapper);
         }   
        return gridColumnWrapperList;
    }
      
}