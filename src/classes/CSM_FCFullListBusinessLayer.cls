public with sharing class CSM_FCFullListBusinessLayer extends CSM_BusinessLayer {

    private List<CSM_Focus_Category_View_Column__c> catViewList;

    public CSM_FCFullListBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getFCFullListWrapperList();
    }
    
    private CSM_GridResponseWrapper getFCFullListWrapperList() {
        //business logic for setting up Lists for <CSM_GridRowWrapper> and <CSM_GridColumnWrapper>
        CSM_GridResponseWrapper fcFullListWrapperList = new CSM_GridResponseWrapper();
        
        List<sObject> fcFullListList = getFCFullListList();
        fcFullListWrapperList.header = setFCFullListHeader();
        //setup the CSM_GridColumnWrapper object for header values, 
        //since this is specific for fcFullList, we know what the headers need to set specifically
        
        fcFullListWrapperList.hasCheckbox = false;
        fcFullListWrapperList.hasAction = false;
        fcFullListWrapperList.hasDetail = false;
        //setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
        fcFullListWrapperList.row = setFCFullListRows(fcFullListList, fcFullListWrapperList.header);
        return fcFullListWrapperList;
    }
    
    private List<CSM_GridRowWrapper> setFCFullListRows(List<sObject> fcFullListList, List<CSM_GridColumnWrapper> colList) {
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();

        if(fcFullListList != null && !fcFullListList.isEmpty()) {
            for(sObject sObj : fcFullListList) {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
				row.namespace = CSM_Util.getNamespace();
                row.columns = new List<CSM_GridColumnWrapper>();
                row.hasGridImage=true;
                if (colList!=null){
                    row.columns = colList;
                    /*
                    for (CSM_GridColumnWrapper colOrig : colList){
                        colOrig.value = '';
                        if (colOrig.valueCol.contains('.'))
                        {
                            String[] objSplit = colOrig.valueCol.split('\\.');
                            if (objSplit!=null && objSplit.size()==2)
                            {   
                                if(sObj.getSObject(objSplit[0])!=null)
                                {
                                    colOrig.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
                                }
                            }
                        }
                        else
                        {
                            
                            colOrig.value = String.valueOf(sObj.get(colOrig.valueCol));
                            
                        }
                        row.columns.add(colOrig);
                        
                        CSM_GridColumnWrapper col = colOrig.clone();
                        
                        col.value = '';
                        if (col.valueCol.contains('.'))
                        {
                            String[] objSplit = col.valueCol.split('\\.');
                            if (objSplit!=null && objSplit.size()==2)
                            {   
                                if(sObj.getSObject(objSplit[0])!=null)
                                {
                                    col.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
                                }
                            }
                        }
                        else
                        {
                            
                            col.value = String.valueOf(sObj.get(col.valueCol));
                            
                        }
                        if (col.lookUpIdCol!=null && col.lookUpIdCol.length()>0){
                            col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
                        }
                        if (col.isDateCol!=null && col.isDateCol){
                            if (String.isNotBlank(col.value))
                            {
                                Boolean tempIsDateTime = CSM_Util.isDateTime(col.value);
                                Boolean tempIsDate = CSM_Util.isDate(col.value);
                                if (tempIsDateTime || tempIsDate)
                                {
                                    Datetime currentDateVal = null;
                                    
                                    if (tempIsDateTime)
                                    {
                                        currentDateVal = Datetime.valueOf(col.value);
                                    }
                                    else 
                                    {
                                        Date tempDate = Date.valueOf(col.value);
                                        currentDateVal = Datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
                                    }
                                    col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal , localeMap);
                                    col.hiddenDate = String.valueOfGmt(currentDateVal);
                                }
                            }
                            else
                            {
                                col.value = '';
                                col.hiddenDate = '';
                            }
                        }                       
                        
                        if (col.lookUpIdCol!=null && col.lookUpIdCol.length()>0){
                                col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
                        }

                        if (col.isCurrencyCol != null && col.isCurrencyCol)
                        {
                            if (String.isEmpty(col.value))
                            {
                                col.value  = '';
                                col.hiddenValue = '0';
                            }
                            else
                            {    
                                col.value = col.value.SubString(1, col.value.length()).replaceAll(',','');
                                //Decimal ceilingAmount = Double.valueOf(col.value);        
                                col.value  = CSM_Util.formatCurrency(col.value);
                                col.hiddenValue = col.value;
                            }
                        }
                        else if(col.isNumberCol != null && col.isNumberCol)
                        {
                            if (String.isEmpty(col.value))
                            {
                                col.value  = '';
                                col.hiddenValue = '0';
                            }
                            else
                            {
                                Double doubleValue = Double.valueOf(col.value);
                                col.value  = doubleValue.format();
                                col.hiddenValue = String.valueOf(doubleValue);
                            }
                        }*/
                        //row.columns.add(colOrig);
                    //} 
                    gridRowWrapper.add(row);
                }                           
            }
        }
        
        return gridRowWrapper;
    }
    
    private List<CSM_GridColumnWrapper> setFCFullListHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has te be maintained for the headers to be set and the response columns
        //Completion Date
        CSM_GridColumnWrapper col = new CSM_GridColumnWrapper();
        col.apiName = 'id';
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{this.inputWrapper.objType}); // this can accept list of strings, we describe only one object here
        if (describeSobjectsResult!=null && !describeSobjectsResult.isEmpty()){
            Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
            if (this.inputWrapper.objType == CSM_Constants.OBJ_CASE){
                col.label = allFields.get(CSM_Constants.CASE_NUMBER).getDescribe().getLabel();
                col.valueCol = CSM_Constants.CASE_NUMBER;
            } 
            else if (this.inputWrapper.objType == CSM_Constants.OBJ_CONTRACT){
                col.label = allFields.get(CSM_Constants.CONTRACT_NUMBER).getDescribe().getLabel();
                col.valueCol = CSM_Constants.CONTRACT_NUMBER;
            } 
            else {
                col.label = allFields.get(CSM_Constants.NAME).getDescribe().getLabel();         
                col.valueCol = CSM_Constants.NAME;
            }
        }
        col.lookUpIdCol = 'Id';
        col.isSortable = true;
        gridClmWrapper.add(col);

        if (catViewList!=null){
            Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
            string refObjName = '';
            string refRelation = '';
            String namespace = CSM_Util.getNamespace();
            String fieldName = '';
            for (CSM_Focus_Category_View_Column__c colView : catViewList){
                if (!colView.CSM_Object_Field_Name__c.equalsIgnoreCase('id') && !colView.CSM_Object_Field_Name__c.equalsIgnoreCase('name')){
                    system.debug('colView::' + colView);
                    col = new CSM_GridColumnWrapper();
                    col.apiName = colView.CSM_Object_Field_Name__c;
                    col.label = colView.CSM_Display_Name__c;
                    system.debug('col.getType()::' + colView.CSM_Object_Field_Type__c);
                    /*if(colView.CSM_Object_Field_Name__c.equalsIgnoreCase(REN_CONSTANTS.OBJ_OPP_ACCOUNT))
                    {
                        col.valueCol = REN_Constants.REN_ACCOUNT_NAME;
                        col.lookUpIdCol = colView.CSM_Object_Field_Name__c;
                    }
                    else
                    {
                        col.valueCol = colView.CSM_Object_Field_Name__c;
                    }*/
                    if(colView.CSM_Object_Field_Type__c == CSM_Constants.TYPE_REFERENCE)
                    {
                        /*if(String.isNotBlank(colView.CSM_Object_Field_Name__c) && colView.CSM_Object_Field_Name__c.startsWith(nameSpace)) {
                            fieldName = colView.CSM_Object_Field_Name__c.removeStart(nameSpace);
                        } else {*/
                            fieldName = colView.CSM_Object_Field_Name__c;
                        //}
                        refRelation = CSM_Util.findNameForLookup(fieldName, allFields);
                        if(String.isNotBlank(refRelation))
                        {
                            col.valueCol = refRelation;
                            col.lookUpIdCol = colView.CSM_Object_Field_Name__c;
                        }
                        else
                        {
                            col.valueCol = colView.CSM_Object_Field_Name__c;
                        }
                    }
                    else if(colView.CSM_Object_Field_Type__c == CSM_Constants.TYPE_BOOLEAN)
                    {
                       col.valueCol = colView.CSM_Object_Field_Name__c;
                       col.dataType=colView.CSM_Object_Field_Type__c;                       
                    }
                    else
                    {
                        col.valueCol = colView.CSM_Object_Field_Name__c;
                    }
                    String fldType = String.valueOf(colView.CSM_Object_Field_Type__c);
                    col.isDateCol = fldType.equals(String.valueOf(Schema.DisplayType.DATE))?true:false;
                    col.isCurrencyCol = fldType.equals(String.valueOf(Schema.DisplayType.CURRENCY))?true:false;
                    col.isSortable = true;
                    col.customColumnSorter = 'customColumnSorter'; 
                    if (col.isCurrencyCol)
                    {   
                        col.label = col.label + ' ('+UserInfo.getDefaultCurrency() +')';
                        
                    }
                    
                    col.isNumberCol = (fldType.equals(String.valueOf(Schema.DisplayType.DOUBLE))
                     || fldType.equals(String.valueOf(Schema.DisplayType.INTEGER))) ? true:false;
                    
                    if (col.isCurrencyCol || col.isNumberCol)
                    {
                        col.dataAlign = 'right';
                    }
                    gridClmWrapper.add(col);
                }
            }
        }
        return gridClmWrapper;
    }   
    
    private List<sObject> getFCFullListList() {
        List<sObject> fcFullListList = new List<sObject>();
        List<String> soqlList = new List<String>();
        Boolean flag = false;
        if (String.isNotBlank(this.inputWrapper.params.taskOrViewId)){
            List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
            try {
                if(this.inputWrapper.params.userPrefWrapper != null 
                    && String.isNotBlank(this.inputWrapper.params.userPrefWrapper.attObjectType) 
                    && String.isNotBlank(this.inputWrapper.params.userPrefWrapper.attrFieldName) 
                    && String.isNotBlank(this.inputWrapper.params.userPrefWrapper.attrFieldType) 
                    && String.isNotBlank(this.inputWrapper.params.userPrefWrapper.attrFieldValue))
                {
                    fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewIDWithFilter(this.inputWrapper.params.taskOrViewId, this.inputWrapper.params.userPrefWrapper);
                }   
                else{
                    fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewID(this.inputWrapper.params.taskOrViewId);
                }   
            } catch (exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            }
            System.debug('ZZZ - fcViewList-'+fcViewList);
            if (fcViewList != null && !fcViewList.isEmpty()){
                CSM_Focus_Category_View__c fcView = fcViewList[0];
                if (fcView.CSM_SOQL__c != null){
                    try {
                        if (this.inputWrapper.params.userPrefWrapper != null && 
                            this.inputWrapper.params.userPrefWrapper.attObjectType != null &&  
                            this.inputWrapper.params.userPrefWrapper.attObjectType.equalsIgnoreCase('Success Plan')) {
                            
                            Set<Id> accountIdsList = new Set<Id>();
                            if (this.inputWrapper.params.userPrefWrapper.attrFieldName != null && this.inputWrapper.params.userPrefWrapper.attrFieldValue != null) 
                            {
                                List<CSM_Account_Plan__c> accountPlans = CSM_AccountPlanDataAccess.getFilterBasedAccountPlans(this.inputWrapper.params.userPrefWrapper.attrFieldName, this.inputWrapper.params.userPrefWrapper.attrFieldValue);
                                if (accountPlans != null && !accountPlans.isEmpty()) {
                                    for (CSM_Account_Plan__c accountPlan : accountPlans) {
                                        if (!accountIdsList.contains(accountPlan.CSM_AccountId__c)) {
                                            accountIdsList.add(accountPlan.CSM_AccountId__c);
                                        }
                                    }
                                }
                                if (accountIdsList != null && accountIdsList.size() > 0) {
                                    Set<Id> localSet = accountIdsList;
                                    if(fcView.CSM_SOQL__c.toUpperCase().contains('ORDER BY')) {
					                    soqlList = fcView.CSM_SOQL__c.split('ORDER BY');
					                    fcView.CSM_SOQL__c = soqlList[0];
                                    }
                                    fcView.CSM_SOQL__c += ' :localSet';
                                    if(soqlList != null && !soqlList.isEmpty() && soqlList.size() == 2) {
						                fcView.CSM_SOQL__c += ' ORDER BY ' + soqlList[1];
						            }
                                }
                                
		                        if(fcView.CSM_SOQL__c!=null){
		                        	fcView.CSM_SOQL__c = CSM_Util.processMyFCVSOQL(fcView.CSM_SOQL__c, fcView.CSM_Filter_By_Owner_Value__c);
		                        	flag = true;
		                        }
                            }
                        }                       

                        if(fcView.CSM_SOQL__c!=null && !flag){
                        	fcView.CSM_SOQL__c = CSM_Util.processMyFCVSOQL(fcView.CSM_SOQL__c, fcView.CSM_Filter_By_Owner_Value__c);
                        }

                        Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_FOCUS_CATEGORIES); 
                        if (fcView.CSM_SOQL__c!=null && ((String)fcView.CSM_SOQL__c).length()>0 && !((String)fcView.CSM_SOQL__c).toUpperCase().contains('LIMIT')){
                            fcView.CSM_SOQL__c += ' LIMIT ' + limitVal;
                        }
                        
                        system.debug('fcView.CSM_SOQL__c::' + fcView.CSM_SOQL__c);
                        fcFullListList = database.query(fcView.CSM_SOQL__c);
                    } catch (Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_EDIT_FC_AND_SAVE));
                    }
                }
                if (fcView.CSMFocusCategoryView__r!=null && !fcView.CSMFocusCategoryView__r.isEmpty()){
                    catViewList = fcView.CSMFocusCategoryView__r; 
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_OBJECT_TO_PROCEED));
        }
        system.debug('fcFullListList::' + fcFullListList);
        return fcFullListList;
    }
}