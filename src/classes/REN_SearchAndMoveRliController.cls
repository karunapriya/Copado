public with sharing class REN_SearchAndMoveRliController extends REN_BaseMainController
{
    public String selectedObject{get; set;}
    public String criteria {get; set;}
    public String selCurrency {get; set;}    
    public String dataIds{get; set;}
    public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
    public String cancelUrl{get; set;}
    public String currentOpportunityId{get; set;}
    private SObject currentOpportunity{get; set;}
    private String nameSpace;
    public String helpParam {get;set;}
    @TestVisible
    private REN_Renew_Configuration__c renewObj;
    @TestVisible
    private REN_Renew_Configuration__c renewalRenewObj;
    public CSM_DataGridAttribute rliGridAttribute{get; set;} 
    public Boolean displayErrorMsg {get; set;}
    public boolean noPriceBookSelected {get;set;}
    public boolean closedOppSelected {get;set;}
    public boolean hasQuote {get;set;}
    public List<REN_Renews_To__c> selectedRliList{get;set;}
    public List<Opportunity> selectedRliOppList{get;set;}
    public boolean showValidRli{get;set;}
    public string currencyCode{get;set;}
    public string priceBookId{get;set;}
    public boolean noSearch {get;set;}   
    //public set<String> noSearchStrings{get;set;}
    public string invalidCriteria{get;set;}
    public string validCriteria{get;set;}
    private Set<String> firstFilterSet = new Set<String>();
    //private Set<String> firstFilterStrSet = new Set<String>();
    public transient String firstFilterStr {get;set;}
    public String noSearchResultString{get;set;}
    public Boolean isBatchRunning;
    
    public REN_SearchAndMoveRliController(ApexPages.StandardSetController  stdController){
        super();
       	showValidRli = true;
        helpParam = CSM_Constants.HELP_SEARCH_AND_MOVE_DETAIL;
        this.nameSpace = CSM_Util.getNamespace();
        this.selectedObject = REN_Constants.OBJ_ASSET;
        if(String.isBlank(this.currentOpportunityId)){
            this.currentOpportunityId = ApexPages.currentPage().getParameters().get('Id');
        }
        displayErrorMsg = false;
        cancelUrl = new PageReference('/' + currentOpportunityId).getUrl();
        
        List<Opportunity> opptyList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{currentOpportunityId});
        if(opptyList != null && !opptyList.isEmpty()){
            this.currentOpportunity = opptyList[0];
        }
        if (this.currentOpportunity != null && String.isBlank(((Opportunity) this.currentOpportunity).Pricebook2Id)){
            noPriceBookSelected=true;
        }else{
            priceBookId = ((Opportunity) this.currentOpportunity).Pricebook2Id;
        }
        if(UserInfo.isMultiCurrencyOrganization()){
            currencyCode = ''+((Opportunity) this.currentOpportunity).get('CurrencyIsoCode');
        }
        SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();
            if((REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',').contains(((Opportunity) this.currentOpportunity).StageName))){
                closedOppSelected=true;
        }
        this.renewObj = new REN_Renew_Configuration__c(REN_Record_Key__c=REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
        this.renewalRenewObj = new REN_Renew_Configuration__c(REN_Record_Key__c='RenewalRelationship');
        this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
        REN_LogicBuilderInputWrapper assetLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_ASSET, 
                                            'SearchAndMoveBaseAsset_', true, this, '', 'refreshLB1', 'onChangeDate1', false, '');
        this.lbInputWrapperList.add(assetLogicBuilderInputWrapper);
        REN_LogicBuilderInputWrapper rliLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewalRenewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                                'SearchAndMoveBaseRLI_', true, this, '','refreshLB3', 'onChangeDate4', false, '');
        this.lbInputWrapperList.add(rliLogicBuilderInputWrapper);
        setGridAttributes();
    }
    
    private void setGridAttributes(){                               
        rliGridAttribute = new CSM_DataGridAttribute();        
        rliGridAttribute.tableName = 'searchAndMove';
        rliGridAttribute.objectType ='searchAndMove';
        rliGridAttribute.viewName ='searchAndMove';
        rliGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
        rliGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
        rliGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
        rliGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
        //rliGridAttribute.setFilterControl(CSM_Constants.GRID_ATTR_TRUE);
        rliGridAttribute.showExport ='true';
        rliGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
        gridInputParams.selectedFilterClause = criteria;
        gridInputParams.gridCurrency = selCurrency;
        rliGridAttribute.params = JSON.serialize(gridInputParams);
        system.debug('jjjssson' + rliGridAttribute.params);
    
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
        rliGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
    
    public pageReference setInvalidRliFilter(){
        showValidRli = false;
        return findFor();
    }
    public pageReference setValidRliFilter(){
        showValidRli = true;
        return findFor();
    }
    
    public void noResultFound(){
        showValidRli = true;
        validCriteria = this.constructSearchSQOL();
        invalidCriteria =  constructSearchSQOLForInvalid();
        noSearchResultFound();
    }
    
    public pageReference PriceBookRedirect() {
         pageReference pageRef;
         pageRef = new PageReference('/oppitm/choosepricebook.jsp?id=' + currentOpportunity.Id + '&retURL=%2F' + currentOpportunity.Id + '&saveURL=%2F' + currentOpportunity.Id);
         return pageRef;
    }
   
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(REN_Constants.OBJ_ASSET, system.label.REN_LBL_ASSETS));
        options.add(new SelectOption(REN_Constants.OBJ_REN_RENEWS_TO, 'Renewable Line Item'));
        return options;
    }
    
    public PageReference ValidateAndMoveOpportunity(){     
        PageReference retPage=Null;
        Savepoint sp = Database.setSavepoint();
        try{
            hasQuote=false;
            isBatchRunning = false;
            SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();
            if((REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',').contains(((Opportunity) this.currentOpportunity).StageName))){
                throw new ClosedOppException(Label.REN_MSG_OPP_STAGE_BLOCK_TO_SEARCH_AND_MOVE);
            }
            if((currentOpportunity.get('CHL_QuoteSyncStatus__c') != null && currentOpportunity.get('CHL_QuoteSyncStatus__c') != 'None') || (currentOpportunity.get('REN_Renewal_Metrics_Status__c') != null && currentOpportunity.get('REN_Renewal_Metrics_Status__c') != 'Calculated')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,Label.REN_PREVENT_SEARCH_MOVE_IF_BATCHES_RUNNING));
            	return null;
            }
            List<String> selectedIdList=new  List<String>();
            if(!String.isBlank(dataIds)){
                 selectedIdList= dataIds.split('-');
            }
            Set<String> selectedIdset=new  Set<String>(selectedIdList);
            selectedRliList=REN_RenewRelationshipDataAccess.getRenewalRelationshipByIds(selectedIdset);
            Set<String> selectedrliOppid=new Set<String>();
            for(REN_Renews_To__c Ren:selectedRliList){
                selectedrliOppid.add(Ren.REN_Renews_To__c);
            }
            Set<String> oppFldSet = null;
            if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){
                oppFldSet = new Set<String>{'id','PriceBook2Id', 'SyncedQuoteId','StageName','REN_Renewal_Metrics_Status__c','CHL_QuoteSyncStatus__c'};
            }else{
                oppFldSet = new Set<String>{'id','PriceBook2Id','StageName','REN_Renewal_Metrics_Status__c','CHL_QuoteSyncStatus__c'};
            }
            selectedRliOppList = REN_OpportunityDataAccess.getOpportunityById(selectedrliOppid,oppFldSet,null);
            
            for(Opportunity op:selectedRliOppList){
                if(String.isNotBlank(String.valueOf(op.get('SyncedQuoteId'))) || String.isNotBlank(String.valueOf(((Opportunity) this.currentOpportunity).get('SyncedQuoteId')))){
                    hasQuote=true;
                }
                if((op.CHL_QuoteSyncStatus__c != null && op.CHL_QuoteSyncStatus__c != 'None') || (op.REN_Renewal_Metrics_Status__c != null && op.REN_Renewal_Metrics_Status__c != 'Calculated')){
                	isBatchRunning = true;
                }
            }
            if(!(hasQuote || isBatchRunning)){
               CSM_TriggerManager.disableAllTriggers();
               retPage = moveToOpportunity();
            }
            else if(isBatchRunning){
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,Label.REN_PREVENT_SEARCH_MOVE_IF_BATCHES_RUNNING));
            	return null;
            }
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage());
            system.debug('ApexPages value : ' + ApexPages.getMessages() );
            ApexPages.addMessage(myMsg);
            retPage=null;
        }
        
        return retPage;
    }
  
    public PageReference findForSearch(){
        showValidRli = true;
        return findFor();
    }
    
    public PageReference moveToOpportunity(){
        PageReference retPage=null;
        Savepoint sp = Database.setSavepoint();
        try{
            string  ErrorMsg='';
            CSM_TriggerManager.disableAllTriggers();
            Map<ID, Opportunity> sourceOppMap = new Map<ID, Opportunity>(selectedrliopplist);
            
            for(REN_Renews_To__c rli:selectedRliList){//US2685
                Opportunity opp=sourceOppMap.get(rli.REN_Renews_To__c);
                if(opp.StageName=='No Service'){
                    rli.REN_Renewal_Status__c = 'Open';
                }
            }
            ErrorMsg=REN_ConsolidateHandler.finalConsolidation(Null,selectedRliList,REN_Constants.STR_SEARCH_AND_MOVE, selectedRliOppList,((Opportunity) this.currentOpportunity));
            if(String.isNotBlank(ErrorMsg)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ErrorMsg));
            }else{
                retPage = new PageReference('/' + currentOpportunityId);
            }
            List<Opportunity> opplist = new List<Opportunity>();
            List<Opportunity> oppt = REN_OpportunityDataAccess.getOpportunityListWithRliSetAndStageNSApprovalStatusFields(sourceOppMap.keyset());
            String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
			for(Opportunity opp:oppt){                  
                if(opp.Renew_To__r == null || opp.Renew_To__r.isEmpty()){                   
                    if(opp.StageName == 'No Service'){  
                        if(CSM_AccessController.hasField('OPPORTUNITY', CSM_Util.nameSpacePrefixSolnExtn + 'NS_Approval_Status__c')) {
                        	opp.put(solnExtnNamespace +'NS_Approval_Status__c','Recalled');
                        }
                     } 
                     opp.StageName = 'Open - Consolidated';
                     opp.REN_Is_Consolidated__c = true;
                }
                opplist.add(opp);
            }
            List<String> oppFieldList;
            if(CSM_AccessController.hasField('OPPORTUNITY', CSM_Util.nameSpacePrefixSolnExtn + 'NS_Approval_Status__c')) {
                oppFieldList = new List<String>{'StageName',CSM_Util.nameSpacePrefixSolnExtn + 'NS_Approval_Status__c'};
            } else {
                oppFieldList = new List<String>{'StageName'};
            }
            REN_OpportunityDataAccess.updateOpportunitySObject(opplist,oppFieldList);
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage());
            system.debug('ApexPages value : ' + ApexPages.getMessages() );
            ApexPages.addMessage(myMsg);
            retPage=null;
        }
        return retPage;   
    }
    
    public PageReference cancelAndReturnToOppt(){
        return new PageReference('/' + currentOpportunityId);
    }
    
    public void showLogicBuilder(){
        this.clearCriteria();
    }
    
    public PageReference findFor(){
    		System.debug('in findFor===');
        try{
        		
            //Set<String> firstFilterSet = new Set<String>();                 
            REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
            selectedCtrl.logicBuilderInput.isBulkSearch = true;
            selectedCtrl.logicBuilderInput.firstFilterSet = firstFilterSet;
            String fieldValue='';
            if(selectedCtrl.criteriaWrapperList != null && !selectedCtrl.criteriaWrapperList.isEmpty()){
            	fieldValue = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Values__c'));
            }            
            if(!Test.isRunningTest()){
                findForCriteria();
            }
            //noSearchStrings=new set<String>();
            this.criteria = ApexPages.hasMessages()?'error':this.constructSearchSQOL();
            noSearch=false; 

            String namespacePrefix = CSM_Util.getNamespace();
            List<SObject> criteriaList = new List<SObject>();
            Integer iCount = 0;
            for (REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper wrapper :selectedCtrl.criteriaWrapperList){
                String fieldName = String.valueOf(wrapper.criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
                if(wrapper.criteria!= null&& !fieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)){
                    criteriaList.add(wrapper.criteria);
                }
            }
           	String operatorName = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(namespacePrefix + 'RLM_Operator__c'));
            String fieldType = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(namespacePrefix + 'RLM_Field_Type__c')); 
            system.debug('fieldType :: '+fieldType);  
            if(criteriaList != null && criteriaList.size() == 1 
            		&& (operatorName == CSM_Constants.OPERATOR_EQUAL
						|| operatorName	== CSM_Constants.OPERATOR_LIKE
						|| operatorName	==	CSM_Constants.OPERATOR_IN) ){
                noSearch=true;
            } 
            //String fieldType = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Field_Type__c'));
	        //fieldValue = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Values__c'));
	        if(String.isNotBlank(fieldValue)){
	            Set<String> firstFilterStrSet =  REN_Util.parseFilterValues(fieldValue);
	            firstFilterStr = JSON.serialize(firstFilterStrSet);
                firstFilterStrSet = null;
	        }
            fieldValue = null;
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
        this.criteria = this.renewObj.REN_Filter_Criteria__c;
        String renewalRelationCriteria = this.renewalRenewObj.REN_Filter_Criteria__c;
        String queryField;
        String soqlWhere='';
        if(showValidRli){
            soqlWhere += ' REN_Renews_To__r.Pricebook2Id  =\'' + ((Opportunity) this.currentOpportunity).Pricebook2Id + '\' AND REN_Renews_To__c != \'' + currentOpportunityId +'\'';   
        }else{
           soqlWhere += ' REN_Renews_To__r.Pricebook2Id  !=\'' + ((Opportunity) this.currentOpportunity).Pricebook2Id + '\' OR REN_Renews_To__c = \'' + currentOpportunityId +'\'';    
        }
        if (UserInfo.isMultiCurrencyOrganization()){
            
            soqlWhere+= showValidRli?' AND REN_Renews_To__r.CurrencyIsoCode  =\'' + ((Opportunity) this.currentOpportunity).get('CurrencyIsoCode')+'\'':' OR REN_Renews_To__r.CurrencyIsoCode  !=\'' + ((Opportunity) this.currentOpportunity).get('CurrencyIsoCode')+'\'';
        }
        if(!showValidRli){
            SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();            
            Set<String> strSet= REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ','); 
            if(strSet!= null && !strSet.isEmpty()){
                soqlWhere += ' OR REN_Renews_To__r.StageName IN : strSet';
            }
            
            soqlWhere = '('+soqlWhere+')';
        }
        if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
            queryField = 'REN_Asset__c';
            soqlWhere = constructSearchMoveWhereClause(this.criteria, firstFilterSet, REN_Constants.OBJ_ASSET,queryField,soqlWhere);
        }else if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
            soqlWhere = constructSearchMoveWhereClause(renewalRelationCriteria, firstFilterSet, REN_Constants.OBJ_REN_RENEWS_TO,Null,soqlWhere);
        }
    
        system.debug('soqlWhere $$$$$$$>>>>>>>>>>>>> '+soqlWhere);
        return soqlWhere;
    }
    
    public  static String constructSearchMoveWhereClause(String Criteria, Set<String> firstFilterSet, String OBJTYPE,String queryField,String DefaultWhereClause){
        String soqlWhere = '';
        if( OBJTYPE==REN_Constants.OBJ_ASSET){
            if(String.isBlank(Criteria) ){
                soqlWhere += DefaultWhereClause + ' AND ' + queryField +' IN (Select ' 
                            + 'id' 
                            + ' From Asset)';
            }else {
                soqlWhere +=DefaultWhereClause + ' AND ' + queryField + ' IN (Select ' 
                            + 'id' 
                            + ' From Asset Where ' + Criteria +')';
            }
        }else if(OBJTYPE==REN_Constants.OBJ_REN_RENEWS_TO){
            if(String.isNotBlank(Criteria)){
                soqlWhere += DefaultWhereClause + ' AND ' + '(' + Criteria + ')';
            }else{
                soqlWhere += DefaultWhereClause;
            }
        }
        return soqlWhere; 
    }
    
    @TestVisible
    private void findForCriteria(){
        REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
       
        if(selectedCtrl != null){
            selectedCtrl.performFind();
        }
    }
    
    public void noSearchResultFound(){
        REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();

        list<String> searchStringsList=new list<String>();
        set<String> filterStrSet =new set<String>();
        Set<Object> filterOptionSet =new Set<Object>();
        map<Object,String> filterOptionMap=new map<Object,String>();
        String fieldType = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Field_Type__c'));   
        noSearchResultString = '';
        system.debug('fieldType :: '+fieldType);
        if(fieldType != 'BOOLEAN')  {     
	        String fieldValue='';
	        
	        fieldValue = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Values__c'));
	        if(String.isBlank(fieldValue)){
	            filterStrSet = new Set<String>();
	        }else{
	            filterStrSet =  REN_Util.parseFilterValues(fieldValue);
	        }
	        
	        if(!String.isBlank(fieldValue)){            
	            for(String strs:filterStrSet){
	                if(String.isNotBlank(strs)){
	                    if(fieldType == CSM_Constants.TYPE_DOUBLE 
	                            || fieldType == CSM_Constants.TYPE_CURRENCY 
	                            || fieldType == CSM_Constants.TYPE_PERCENT){
	                    
	                        filterOptionSet.add(Double.valueOf(strs));
	                        filterOptionMap.put(Double.valueOf(strs),strs);
	                    }else{
	                        filterOptionSet.add(String.Valueof(strs));
	                    }
	                }
	            }       
	        }
	        if(filterStrSet != null && !filterStrSet.isEmpty()){
	            String operatorName = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Operator__c'));
	            if(operatorName==CSM_Constants.OPERATOR_EQUAL || operatorName==CSM_Constants.OPERATOR_LIKE || operatorName==CSM_Constants.OPERATOR_IN){
	                String fieldName = String.valueOf(selectedCtrl.criteriaWrapperList[0].criteria.get(CSM_Util.getNamespace() + 'RLM_Field_Name__c'));
	                string fieldNameToRetrive='';
	                if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
	                    fieldNameToRetrive = CSM_Util.getNamespace() + 'REN_Asset__r.'+ fieldName;
	                }else{
	                    fieldNameToRetrive = fieldName;
	                }
	                List<REN_Renews_To__c> validRliList = getRliRecordList(fieldNameToRetrive);                 
	                List<REN_Renews_To__c> invalidRliList = getRliInvalidRecordList(fieldNameToRetrive); 
	                system.debug('InvalidRliList->'+InvalidRliList);
	                system.debug('validRliList->'+validRliList);
	                system.debug('filterOptionSet->'+filterOptionSet);
	                if(validRliList!=Null){
	                    Object val = null;
	                    List<String> fieldNameList;
	                    for(REN_Renews_To__c rr:validRliList){
	                        val = null;
	                        if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
	                        	fieldNameList = fieldName.split('\\.');
	                        	if(fieldNameList != null && fieldNameList.size() == 1){
		                        	if(rr.getSobject('REN_Asset__r').get(fieldName)!=null){
		                                val = rr.getSobject('REN_Asset__r').get(fieldName);
		                            }
	                        	}else if(fieldNameList != null && fieldNameList.size() == 2){
	                        		val = rr.getSobject('REN_Asset__r').getSobject(fieldNameList[0]).get(fieldNameList[1]);
	                        	}
	                        }else{
	                        	fieldNameList = fieldName.split('\\.');
	                        	if(fieldNameList != null && fieldNameList.size() == 1){
	                        		val = rr.get(fieldName);
	                        	}else if(fieldNameList != null && fieldNameList.size() == 2){
	                        		val = rr.getSobject(fieldNameList[0]).get(fieldNameList[1]);
	                        	}
	                        }
	                        for(Object oVal: filterOptionSet){
	                            system.debug(oVal + ' == '+val);
	                            if(operatorName==CSM_Constants.OPERATOR_LIKE && fieldType == CSM_Constants.TYPE_STRING){
	                                if(String.ValueOf(val).containsIgnoreCase(String.ValueOf(oVal))){
	                                    filterOptionSet.remove(oVal);
	                                }
	                            }else if(fieldType == CSM_Constants.TYPE_STRING){
	                                if(String.ValueOf(val).equalsIgnoreCase(String.ValueOf(oVal))){
	                                    filterOptionSet.remove(oVal);
	                                }
	                            }else if(val.equals(oVal)){
	                                filterOptionSet.remove(oVal);
	                                filterOptionMap.remove(oVal);
	                                break;
	                            }
	                        }
	                    }
	                }
	                if(InvalidRliList !=Null){
	                    Object val = null;
	                    List<String> fieldNameList;
	                    for(REN_Renews_To__c rr:InvalidRliList){
	                        val = null;
	                        if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
	                            fieldNameList = fieldName.split('\\.');
	                        	if(fieldNameList != null && fieldNameList.size() == 2){
		                        	val = rr.getSobject('REN_Asset__r').getSobject(fieldNameList[0]).get(fieldNameList[1]);	
	                        	}else if(rr.getSobject('REN_Asset__r').get(fieldName)!=null){
		                         	val = rr.getSobject('REN_Asset__r').get(fieldName);
	                        	}
	                        }else{
	                            fieldNameList = fieldName.split('\\.');
	                        	if(fieldNameList != null && fieldNameList.size() == 2){
	                        		val = rr.getSobject(fieldNameList[0]).get(fieldNameList[1]);
	                        	}else{	                        		
	                        		val = rr.get(fieldName);
	                        	}
	                        }
	                        for(Object oVal: filterOptionSet){
	                            system.debug(oVal + ' == '+val);
	                            if(operatorName==CSM_Constants.OPERATOR_LIKE && fieldType == CSM_Constants.TYPE_STRING){
	                                if(String.ValueOf(val).containsIgnoreCase(String.ValueOf(oVal))){
	                                    filterOptionSet.remove(oVal);
	                                }
	                            }else if(fieldType == CSM_Constants.TYPE_STRING){
	                                if(String.ValueOf(val).equalsIgnoreCase(String.ValueOf(oVal))){
	                                    filterOptionSet.remove(oVal);
	                                }
	                            }else if(val.equals(oVal)){
	                                filterOptionSet.remove(oVal);
	                                filterOptionMap.remove(oVal);
	                                break;
	                            }
	                        }
	                    }
	                }
	                system.debug('filterOptionSet-> '+filterOptionSet);
	                //noSearchStrings=new set<String>();
	                noSearchResultString = '';
	                for(Object s:filterOptionSet) {
	                    if(fieldType == CSM_Constants.TYPE_DOUBLE 
	                            || fieldType == CSM_Constants.TYPE_CURRENCY 
	                            || fieldType == CSM_Constants.TYPE_PERCENT){
	                        //noSearchStrings.add(filterOptionMap.get(s));
	                        noSearchResultString +=   filterOptionMap.get(s) + '<br/>'  ;
	                    }else{
	                        //noSearchStrings.add(String.ValueOf(s));
	                        noSearchResultString +=  String.ValueOf(s) + '<br/>';
	                    }
	                }
	                //noSearchResultString = JSON.serialize(noSearchStrings);
	                system.debug('noSearchResultString->'+noSearchResultString);
	                //system.debug('noSearchStrings->'+noSearchStrings);
	            }
	        }
        }
    }
    
    private String constructSearchSQOLForInvalid(){
        this.criteria = this.renewObj.REN_Filter_Criteria__c;
        String renewalRelationCriteria = this.renewalRenewObj.REN_Filter_Criteria__c;
        String queryField;
        String soqlWhere='';
        soqlWhere += '(' + ' REN_Renews_To__r.Pricebook2Id  !=\'' + ((Opportunity) this.currentOpportunity).Pricebook2Id + '\' OR REN_Renews_To__c = \'' + currentOpportunityId +'\'' + ')';    
        if (UserInfo.isMultiCurrencyOrganization()){
            soqlWhere+= ' OR REN_Renews_To__r.CurrencyIsoCode  !=\'' + ((Opportunity) this.currentOpportunity).get('CurrencyIsoCode')+'\'';
        }
        SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();            
        Set<String> strSet= REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ','); 
        if(strSet!= null && !strSet.isEmpty()){
            soqlWhere += ' OR REN_Renews_To__r.StageName IN : strSet';
        }
        soqlWhere = '('+soqlWhere+')';
        if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
            queryField = 'REN_Asset__c';
            soqlWhere = constructSearchMoveWhereClause(this.criteria, firstFilterSet, REN_Constants.OBJ_ASSET,queryField,soqlWhere);
        }else if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
            soqlWhere = constructSearchMoveWhereClause(renewalRelationCriteria,firstFilterSet,REN_Constants.OBJ_REN_RENEWS_TO,Null,soqlWhere);
        }
    
        system.debug('soqlWhere $$$$$$$>>>>>>>>>>>>> '+soqlWhere);
        return soqlWhere;
    }
    
    @TestVisible
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
    
    @TestVisible
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
        if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
            uniqueLogicBuilderInstance = 'SearchAndMoveBaseAsset__' + this.selectedObject;
        }else if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
            
            uniqueLogicBuilderInstance = 'SearchAndMoveBaseRLI__' + this.selectedObject;
        }
        
        Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
        return (REN_LogicBuilderCmpCtrl)baseChildControllerMap.get(uniqueLogicBuilderInstance);
    }

    public with sharing class ClosedOppException extends Exception {}
}