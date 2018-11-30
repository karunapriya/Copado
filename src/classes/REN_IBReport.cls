public with sharing class REN_IBReport extends REN_BaseMainController
{
    public String selectedObject{get; set;}
    public String criteria {get; set;}
    public String selCurrency {get; set;}    
    public String dataIds{get; set;}
    public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
    public String cancelUrl{get; set;}
    private SObject currentOpportunity{get; set;}
    private String nameSpace;
    public String helpParam {get;set;}
    @TestVisible
    private REN_Renew_Configuration__c renewObj;
    @TestVisible
    private sObject externalObj;
    public CSM_DataGridAttribute ibReportGridAttribute{get; set;} 
    public Boolean displayErrorMsg {get; set;}
    public boolean noPriceBookSelected {get;set;}
    public boolean closedOppSelected {get;set;}
    public boolean hasQuote {get;set;}
    public List<REN_Renews_To__c> listofselectedrli{get;set;}
    public List<Opportunity> selectedrliopplist{get;set;}
    public string currencyCode{get;set;}
    public string priceBookId{get;set;}
    public boolean noSearch {get;set;}   
    public set<String> noSearchStrings{get;set;}
    public string invalidCriteria{get;set;}
    public string validCriteria{get;set;}
    private Set<String> firstFilterSet = new Set<String>();

    
    public REN_IBReport(ApexPages.StandardSetController stdController){
        super();
       	helpParam = CSM_Constants.HELP_SEARCH_AND_MOVE_DETAIL;
        this.nameSpace = CSM_Util.getNamespace();
        this.selectedObject = REN_Constants.OBJ_REN_RENEWS_TO;
        displayErrorMsg = false;
        cancelUrl = '/apex/'+this.namespace+'CSM_Admin';
        externalObj = new REN_Renew_Configuration__c(REN_Record_Key__c='RenewalRelationship');
        this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
        
        REN_LogicBuilderInputWrapper ibReportLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.externalObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                                'IBReport_', true, this, '','refreshLB3', 'onChangeDate4', false, '');
		System.debug('ibReportLogicBuilderInputWrapper - '+ibReportLogicBuilderInputWrapper);
        this.lbInputWrapperList.add(ibReportLogicBuilderInputWrapper);
        setGridAttributes();
    }
    
    private void setGridAttributes(){                                
        ibReportGridAttribute = new CSM_DataGridAttribute();        
        ibReportGridAttribute.tableName = 'IBReport';
        ibReportGridAttribute.objectType ='searchAndMove';
        ibReportGridAttribute.viewName ='IBReport';
        ibReportGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
        ibReportGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
        ibReportGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
        ibReportGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
        ibReportGridAttribute.setFilterControl(CSM_Constants.GRID_ATTR_TRUE);
        ibReportGridAttribute.showExport ='true';
        ibReportGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
        gridInputParams.selectedFilterClause = criteria;
        gridInputParams.gridCurrency = selCurrency;
        
        ibReportGridAttribute.params = JSON.serialize(gridInputParams);
        system.debug('jjjssson' + ibReportGridAttribute.params);
    
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
        ibReportGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
    
      public PageReference findForSearch(){
        return findFor();
    }
    
    public PageReference createReport(){
        PageReference retPage=null;
        Savepoint sp = Database.setSavepoint();
        try{
        }catch(Exception e){
        }
        return retPage;   
    }
    
    public PageReference cancelAndReturnToOppt(){
        return new PageReference(cancelURL);
    }
    
    public void showLogicBuilder(){
        this.clearCriteria();
    }
    
    public PageReference findFor(){
        try{
            REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
            selectedCtrl.logicBuilderInput.isBulkSearch = true;
            selectedCtrl.logicBuilderInput.firstFilterSet = firstFilterSet;
            if(!Test.isRunningTest()){
                findForCriteria();
            }
            
            noSearchStrings=new set<String>();
            this.criteria = ApexPages.hasMessages()?'error':this.constructSearchSQOL();
            noSearch=false;                     
            String namespacePrefix = CSM_Util.getNamespace();
            List<SObject> criteriaList = new List<SObject>();
            for (REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper wrapper :selectedCtrl.criteriaWrapperList){
                String fieldName = String.valueOf(wrapper.criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
                if(wrapper.criteria!= null&& !fieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)){
                    criteriaList.add(wrapper.criteria);
                }
            }
           	String operatorName = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(namespacePrefix + 'RLM_Operator__c'));
            String fieldType = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(namespacePrefix + 'RLM_Field_Type__c'));   
            if(criteriaList != null && criteriaList.size() == 1 
            		&& (operatorName == CSM_Constants.OPERATOR_EQUAL
						|| operatorName	== CSM_Constants.OPERATOR_LIKE
						|| operatorName	==	CSM_Constants.OPERATOR_IN)){
                noSearch=true;
            }
            this.selCurrency = selectedCtrl.corpCurr;
            setGridAttributes();              
            system.debug('seeel -' + this.selCurrency);         
        }
        catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    private String constructSearchSQOL(){
        String soqlWhere='';
        system.debug('soqlWhere $$$$$$$>>>>>>>>>>>>> '+soqlWhere);
        return soqlWhere;
    }
    
    public  static String constructSearchMoveWhereClause(String Criteria, String OBJTYPE,String queryField,String DefaultWhereClause){
        String soqlWhere = '';
        if(String.isNotBlank(Criteria)){
            soqlWhere += DefaultWhereClause + ' AND ' + '(' + Criteria + ')';
        }else{
            soqlWhere += DefaultWhereClause;
        }
        return soqlWhere; 
    }
    
    @TestVisible
    private void findForCriteria(){
        REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
       	System.debug('selectedCtrl - '+selectedCtrl);
        if(selectedCtrl != null){
            selectedCtrl.performFind();
        }
        system.debug('selectedCtrl--->'+selectedCtrl);
    }
    
    public String formatProperSearchedString(String inputStr) {
        String valueInQueryStr = '';
        //check for new line
        if (inputStr.contains('\r\n')) {
            inputStr = inputStr.replace('\r\n', ',');
        }
        if (inputStr.contains('\n')) {
            inputStr = inputStr.replace('\n', ',');
        }
        if (inputStr.contains('\r')) {
            inputStr = inputStr.replace('\r', ',');
        }

        System.debug('inputStr===' + inputStr);
        //if the values contains comma, then split on the comma
        List<String> commaSplitList = new List<String>();
        if (inputStr.contains(',')) {
            commaSplitList = inputStr.split(',');
        }
        List<String> trimmedCommaSplitList = new List<String>();
        String tempStr;
        if (!commaSplitList.isEmpty()) {
            for (String str : commaSplitList) {
                tempStr = str.trim();
                if(String.isNotBlank(tempStr)){
                    trimmedCommaSplitList.add(tempStr);
                }
            }
        }
        for (String trimStr : trimmedCommaSplitList) {
            if (trimStr.contains('"') && trimStr.startsWith('"') && trimStr.endsWith('"')) {
                //add to the list of values to be included in the query string
                valueInQueryStr += trimStr.removeStart('"').removeEnd('"') + ',';
            } else if (!trimStr.contains('"') && !trimStr.contains('\'')) {
                valueInQueryStr +=  trimStr + ',';
            }else if (trimStr.startsWith('"') && !trimStr.endsWith('"')) {
                valueInQueryStr +=  trimStr.removeStart('"')+ ',';
            }else if (!trimStr.startsWith('"') && trimStr.endsWith('"')) {
                valueInQueryStr +=  trimStr.removeEnd('"') + ',';
            }
            if (trimStr.contains('\'') && trimStr.startsWith('\'') && trimStr.endsWith('\'')) {
                //add to the list of values to be included in the query string
                valueInQueryStr += trimStr.removeStart('\'').removeEnd('\'') + ',';
            }else if (trimStr.startsWith('\'') && !trimStr.endsWith('\'')) {
                valueInQueryStr +=  trimStr.removeStart('\'')+ ',';
            }else if (!trimStr.startsWith('\'') && trimStr.endsWith('\'')) {
                valueInQueryStr +=  trimStr.removeEnd('\'') + ',';
            }else if (!trimStr.contains('"') && !trimStr.contains('\'')) {
                valueInQueryStr +=  trimStr + ',';
            }
        }
        if (!inputStr.contains(',') && inputStr.contains('"')) {
            //find the string between the first and second occurrence of double quote
            String strBetweenDoubleQuotes = inputStr.substringBetween('"');
            valueInQueryStr += strBetweenDoubleQuotes + ',';
        }
        if (!inputStr.contains(',') && inputStr.contains('\'')) {
            //find the string between the first and second occurrence of single quote
            String strBetweenDoubleQuotes = inputStr.substringBetween('\'');
            valueInQueryStr += strBetweenDoubleQuotes + ',';
        }
        valueInQueryStr = valueInQueryStr.removeEnd(',');
        if (String.isNotBlank(valueInQueryStr)) {
            inputStr = valueInQueryStr;
        }
        System.debug('inputStr after massaging===' + inputStr);
        return inputStr;
    }
    
    private List<REN_Renews_To__c> getRliRecordList(String fieldName){
        system.debug('this.criteria->'+this.criteria);
        String filterStr = ''; 
        Set<String> strSet =new Set<String>();
        if(string.isNotEmpty(this.criteria) && this.criteria != null && !this.criteria.equals('error')) {
            filterStr = this.criteria;
            SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();            
            strSet = REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',');          
        }
        String nameSpace = CSM_Util.getNamespace();
List<REN_Renews_To__c> renewalRelationShipList = REN_RenewRelationshipDataAccess.getRliToShowNoResultFound(
                                                        nameSpace + REN_Constants.OBJ_REN_RENEWS_TO,
                                                        SObjectType.REN_Renews_To__c.FieldSets.REN_ManageRenewals_Fieldset.getFields(), new Set<String>{nameSpace+'REN_Renews_To__r.Account.Name',fieldName,nameSpace+'REN_Product__c'} ,
                                                        validCriteria,firstFilterSet, strSet,true);        
        system.debug('renewalRelationshipList::' + renewalRelationShipList);
        return renewalRelationShipList;
        
    }
    
    private List<REN_Renews_To__c> getRliInvalidRecordList(String fieldName){
        system.debug('this.criteria->'+this.criteria);
        String filterStr = ''; 
        Set<String> strSet =new Set<String>();
        if(string.isNotEmpty(this.criteria) && this.criteria != null && !this.criteria.equals('error')) {
            filterStr = this.criteria;
            SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();            
            strSet = REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',');          
        }
        String nameSpace = CSM_Util.getNamespace();
        List<REN_Renews_To__c> renewalRelationShipList = REN_RenewRelationshipDataAccess.getRliToShowNoResultFound(
                                                        nameSpace + REN_Constants.OBJ_REN_RENEWS_TO,
                                                        SObjectType.REN_Renews_To__c.FieldSets.REN_ManageRenewals_Fieldset.getFields(), new Set<String>{nameSpace+'REN_Renews_To__r.Account.Name',fieldName,nameSpace+'REN_Product__c'} ,
                                                        invalidCriteria,firstFilterSet,strSet,false);
        system.debug('renewalRelationshipList::' + renewalRelationShipList);
        return renewalRelationShipList;
        
    }
    
    private void clearCriteria(){
        REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
        this.clearLogicBuilderValues(selectedCtrl);
        // clear renewal values.
        selectedCtrl = this.findLogicBuilderInstance();
        this.clearLogicBuilderValues(selectedCtrl);
    }
    
    private void clearLogicBuilderValues(REN_LogicBuilderCmpCtrl selectedCtrl){
        if(selectedCtrl != null){
            if(selectedCtrl.criteriaWrapperList != null){
                selectedCtrl.criteriaWrapperList.clear();
                selectedCtrl.populateDefaultCriteria();
            }
        }
    }
    
    private REN_LogicBuilderCmpCtrl findLogicBuilderInstance(){
        String uniqueLogicBuilderInstance;
        System.debug('this.selectedObject - '+this.selectedObject);
        if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
            uniqueLogicBuilderInstance = 'IBReport__' + this.selectedObject;
        }
        System.debug('uniqueLogicBuilderInstance - '+uniqueLogicBuilderInstance);
        
        Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
        System.debug('baseChildControllerMap --'+baseChildControllerMap);
        return (REN_LogicBuilderCmpCtrl)baseChildControllerMap.get(uniqueLogicBuilderInstance);
    }

    public with sharing class ClosedOppException extends Exception {}
}