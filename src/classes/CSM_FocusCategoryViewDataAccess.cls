public with sharing class CSM_FocusCategoryViewDataAccess {

    
    public static Map<String, Map<String, String>> populateViewInformation() {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
            CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL,CSM_Constants.OBJ_FCV_CURRENCY_HEADER, CSM_Constants.OBJ_FCV_FILTER_BY_OWNER, CSM_Constants.OBJ_FCV_Queue, CSM_Constants.OBJ_FCV_IS_SAVED_SEARCH };
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        if (noAccessList.isEmpty())
        {
            Map<String, Map<String, String>> fcViewObjMap = new Map<String, Map<String, String>>();
            Map<String, String> fcViewMap;
            for (CSM_Focus_Category_View__c fcView : ([SELECT Id,
                                                        CSM_Display_Name__c,
                                                        CSM_Columns__c,CSM_Currency_Header__c,
                                                        CSM_Criteria__c,
                                                        CSM_Object_Name__c,
                                                        CSM_SOQL__c,
                                                        RLM_Currency_Code__c,
                                                        CSM_Filter_By_Owner_Value__c,
                                                        CSM_Case_Queue__c, 
                                                        CreatedById,
                                                        CreatedDate,
                                                        LastModifiedById,
                                                        LastModifiedDate 
                                                    FROM CSM_Focus_Category_View__c WHERE RLM_Is_Saved_Search__c != true limit 2000])) {
                if (fcViewObjMap.containsKey(fcView.CSM_Object_Name__c)) {
                    fcViewMap = fcViewObjMap.get(fcView.CSM_Object_Name__c);
                } else {
                    fcViewMap = new Map<String, String>();
                }
                if(fcView.CSM_Display_Name__c != null){
                	fcViewMap.put(fcView.Id, fcView.CSM_Display_Name__c);                
                }

                fcViewObjMap.put(fcView.CSM_Object_Name__c, fcViewMap);
            }
            return fcViewObjMap;
        }
        else
        {   
             String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));            
        }
        return null;
    }
            
    public static List<CSM_Focus_Category_View__c> findFCVByViewID (String fcViewId) {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
            CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL,
            CSM_Constants.OBJ_FCV_FILTER_LOGIC, CSM_Constants.OBJ_FCV_IS_TILE,
            CSM_Constants.OBJ_FCV_IS_ACTIVE,CSM_Constants.OBJ_FCV_FILTER_BY_OWNER, CSM_Constants.OBJ_FCV_Queue,
            CSM_Constants.OBJ_FCV_Sort_By,CSM_Constants.OBJ_FCV_Sort_Order};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        if (noAccessList.isEmpty())
        {
            List<CSM_Focus_Category_View__c> listFCV = [SELECT Id, CSM_Display_Name__c, 
                                CSM_Columns__c, CSM_Criteria__c,CSM_Currency_Header__c,
                                CSM_Object_Name__c, CSM_SOQL__c, RLM_Currency_Code__c,RLM_Filter_Logic__c, CSM_IsTile__c, CSM_Is_Active__c,CSM_Filter_By_Owner_Value__c, CSM_Case_Queue__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate,CSM_Sort_By__c,CSM_Sort_Order__c,RLM_Related_Object_Name__c, 
                                (SELECT CSM_Display_Name__c, CSM_Object_Field_Name__c, CSM_Object_Field_Type__c FROM CSMFocusCategoryView__r)
                            FROM CSM_Focus_Category_View__c
                            WHERE Id = :fcViewId LIMIT 1];
                            
            return listFCV;
        }
        else
        {   
             String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));            
        }
        return null;
    }
    
    public static List<CSM_Focus_Category_View__c> findFCVByViewIDWithFilter (String fcViewId, CSM_UserPreferencesFilterWrapper userPreferences) {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
            CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL,
            CSM_Constants.OBJ_FCV_IS_SAVED_SEARCH};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);
        List<String> soqlList = new List<String>();
        if (noAccessList.isEmpty())
        {
            List<CSM_Focus_Category_View__c> listFCV = [SELECT Id, CSM_Display_Name__c, 
                                CSM_Columns__c, CSM_Criteria__c,CSM_Currency_Header__c,
                                CSM_Object_Name__c, CSM_SOQL__c, RLM_Currency_Code__c, CSM_Filter_By_Owner_Value__c,
                                (SELECT CSM_Display_Name__c, CSM_Object_Field_Name__c, CSM_Object_Field_Type__c FROM CSMFocusCategoryView__r)
                            FROM CSM_Focus_Category_View__c
                            WHERE Id = :fcViewId AND RLM_Is_Saved_Search__c != true LIMIT 1];          
            
            String soql = listFCV[0].CSM_SOQL__c;
            system.debug('SOQL FCV::' + soql);
            //IF if filter is not null or '' in soql build $$ 
            if(!String.isEmpty(userPreferences.attrFieldName) && !String.isEmpty(userPreferences.attrFieldType) && !String.isEmpty(userPreferences.attrFieldValue) 
            && !userPreferences.attObjectType.equalsIgnoreCase('Task'))
            {
                //Verify if and or where. 
                if(soql.toUpperCase().contains('ORDER BY')) {
                    soqlList = soql.split('Order By');
                    soql = soqlList[0];
                    if(soql.toUpperCase().contains('WHERE') )
                    {
                        soql += ' AND ';
                    }
                    else {
                        soql += ' WHERE ';
                    }
                } else if(soql.toUpperCase().contains('WHERE'))
	                {
	                    soql += ' AND ';
	                }
	                else {
	                    soql += ' WHERE ';
	                }
                                                                                
                //If Account Type
                
                //If Opportunity
                if (userPreferences.attObjectType != null && userPreferences.attObjectType.equalsIgnoreCase('Success Plan')) {

                    if (userPreferences.attrFieldName != null && userPreferences.attrFieldValue != null) {
                        if (listFCV[0].CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_OPPORTUNITY || listFCV[0].CSM_Object_Name__c == CSM_Constants.OBJ_CASE) {
                            soql += 'AccountId  IN';
                        }
                        else if (listFCV[0].CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACCOUNT_PLAN) {
                            soql += 'CSM_AccountId__c  IN';
                        }
                        else if (listFCV[0].CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACCOUNT) {
                            soql += 'Id  IN';
                        }                           
                    }
                }
                else if (userPreferences.attObjectType != null && userPreferences.attObjectType.equalsIgnoreCase('Account')) {              
                    if (listFCV[0].CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_OPPORTUNITY || listFCV[0].CSM_Object_Name__c == CSM_Constants.OBJ_CASE)
                    {
                        soql += ' Account.';
                    }
                    soql += userPreferences.attrFieldName;
                    if(userPreferences.attrFieldType == CSM_Constants.TYPE_DOUBLE 
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_INTEGER
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_CURRENCY
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_PERCENT
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_DATE){
                        soql +=  ' = ' +  userPreferences.attrFieldValue ;
                    }
                    else {
                        soql +=  ' = ' + ' \'' + userPreferences.attrFieldValue + '\' ';
                    }
                }else if (userPreferences.attObjectType != null) {
                    soql += userPreferences.attrFieldName;
                    if(userPreferences.attrFieldType == CSM_Constants.TYPE_DOUBLE 
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_INTEGER
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_CURRENCY
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_PERCENT
                       || userPreferences.attrFieldType == CSM_Constants.TYPE_DATE){
                        soql +=  ' = ' +  userPreferences.attrFieldValue ;
                   }
                }
            }
            if(soqlList != null && !soqlList.isEmpty() && soqlList.size() == 2) {
                soql += ' ORDER BY ' + soqlList[1];
            }
            soql = CSM_Util.processMyFCVSOQL(soql, listFCV[0].CSM_Filter_By_Owner_Value__c);
            listFCV[0].CSM_SOQL__c = soql; 

            system.debug('listFCV[0].CSM_SOQL__c::' + listFCV[0].CSM_SOQL__c);              
            return listFCV;
        }
        else
        {   
             String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));            
        }
        return null;
    }
    
    public static List<CSM_Focus_Category_View__c> populateViewInformation (List<String> fcViewIds) {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
            CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL,
            CSM_Constants.OBJ_FCV_CURRENCY_HEADER, CSM_Constants.OBJ_FCV_FILTER_BY_OWNER, CSM_Constants.OBJ_FCV_Queue,
            CSM_Constants.OBJ_FCV_Sort_By,CSM_Constants.OBJ_FCV_Sort_Order, CSM_Constants.OBJ_FCV_IS_SAVED_SEARCH};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        if (noAccessList.isEmpty())
        {
            List<CSM_Focus_Category_View__c> listFCV;
            if (fcViewIds!=null){
                listFCV = [SELECT Id,
                            CSM_Display_Name__c,
                            CSM_Columns__c,
                            CSM_IsTile__c,
                            CSM_Currency_Header__c,
                            CSM_Criteria__c,
                            CSM_Object_Name__c,
                            CSM_SOQL__c,
                            RLM_Currency_Code__c,
                            CSM_Filter_By_Owner_Value__c,
                            CSM_Case_Queue__c,
                            CSM_Sort_By__c,
                            CSM_Sort_Order__c
                        FROM CSM_Focus_Category_View__c
                        WHERE Id IN :fcViewIds AND RLM_Is_Saved_Search__c != true limit 1000];
            }
            return listFCV;
        }
        else
        {   
             String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));            
        }
        return null;
    }
        
    public static List<CSM_Focus_Category_View__c>  upsertFCV(List<CSM_Focus_Category_View__c> listFCV)
    {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
            CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL, 'CSM_Is_Active__c', 'CSM_IsTile__c', 'CSM_Sort_By__c', 'CSM_Sort_Order__c',
            'CSM_Filter_By_Owner_Value__c', 'CSM_Case_Queue__c'};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_UPSERT, fcvFieldList);
        if (noAccessList.isEmpty())
        {
            
            if (!listFCV.isEmpty())
            {
                upsert listFCV;
            }
        }
        else
        {
            
            String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};              
            throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, 
            arguments));        
        } 
        return listFCV;       
    }
    
    /**
     * @description  override of onAfterInsert gets list of play ids and calls the updateCriteria handler 
     */
    public static void updateSOQL(List<String> fcViewIdList)
    {
        List<CSM_Focus_Category_View_Criteria__c> allCriteriaList = new List<CSM_Focus_Category_View_Criteria__c>();
        List<CSM_Focus_Category_View_Column__c> allColumnList = new List<CSM_Focus_Category_View_Column__c>();
        List<CSM_Focus_Category_View__c> allViewList = new List<CSM_Focus_Category_View__c>();
        List<CSM_Focus_Category_View__c> viewListToUpdate = new List<CSM_Focus_Category_View__c>();
        List<CSM_Focus_Category_View_Column__c> allColumnListUpdate = new List<CSM_Focus_Category_View_Column__c>();
        Map<String, List<String>> viewCriteriaStringMap = new Map<String,List<String>>();
        Map<String,String> columnViewMap = new Map<String,String>();
        Map<String,String> columnViewMapForQuery = new Map<String,String>();
        
        try {
            //Query all criteria and plays
            
            //allCriteriaList = CSM_FocusCategoryViewCriteriaDataAccess.populateFCVCriteriaInformation(fcViewIdList);
            allColumnList = CSM_FocusCategoryViewColumnDataAccess.populateFCVColumnInformation(fcViewIdList);
            //Map<String, Schema.SObjectField> objContractFieldInfo = Contract.getSObjectType().getDescribe().fields.getMap();
            //Map<String, Schema.SObjectField> objOpptyFieldInfo = Opportunity.getSObjectType().getDescribe().fields.getMap();
            //Map<String, Schema.SObjectField> objCaseFieldInfo = Case.getSObjectType().getDescribe().fields.getMap();
            String refRelation = '';
            String nameSpace = CSM_Util.getNamespace();
            for(CSM_Focus_Category_View_Column__c fcvc :allColumnList)
            {
                if(fcvc.CSM_Object_Field_Type__c == CSM_Constants.TYPE_REFERENCE)
                {
                    Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                    Schema.SObjectType sobjType = globalDescribe.get(fcvc.CSM_Object_Name__c);
                    if(sObjType == null){
                        sobjType = globalDescribe.get(nameSpace + fcvc.CSM_Object_Name__c);
                    }
                    if(sObjType != null){
                        Map<String, Schema.SObjectField> objFieldInfo = sobjType.getDescribe().fields.getMap();
                        String fieldName = '';
                        /*if(String.isNotBlank(fcvc.CSM_Object_Field_Name__c) 
                            && fcvc.CSM_Object_Field_Name__c.startsWith(nameSpace)){
                            fieldName = fcvc.CSM_Object_Field_Name__c.removeStart(nameSpace);
                        }else{*/
                            fieldName = fcvc.CSM_Object_Field_Name__c;
                        //}
                        refRelation = CSM_Util.findNameForLookup(fieldName, objFieldInfo);
                        fcvc.CSM_Object_Field_Name__c = refRelation;
                    }
                }
                
                allColumnListUpdate.add(fcvc);
            }
            allViewList = populateViewInformation(fcViewIdList);
            columnViewMap = buildViewColumnStringMap(allColumnListUpdate);
            columnViewMapForQuery = buildViewColumnStringMapForQuery(allColumnListUpdate);
            //viewCriteriaStringMap = buildViewCriteriaStringMap(allCriteriaList);
            //Loop through criteria and build each section of criteria placing in map.
            viewListToUpdate = updateViewsWithCrtieria(columnViewMap, /*viewCriteriaStringMap,*/ allViewList, columnViewMapForQuery);
            if(viewListToUpdate!=null && !viewListToUpdate.isEmpty())
            {
                //update playListToUpdate;
                upsertFCV(viewListToUpdate);
            }
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }   
    }
    /**
     * @description  builds the Criteria String map for each Play's Related criteria
     * @return Map<String,List<String>> 
     */
    private static Map<String,String> buildViewColumnStringMapForQuery(List<CSM_Focus_Category_View_Column__c> allColumnList)
    {
        Map<String,String> columnViewMap = new Map<String,String>();
        String columns = '';
        String nameSpace = CSM_Util.getNamespace();
        Boolean isMCEnabled = CSM_Util.checkMCEnabled();
        String colWithNamespace;
        for(CSM_Focus_Category_View_Column__c c : allColumnList)
        {
            columns = '';
            if (columnViewMap.containsKey(c.CSM_Focus_Category_View__c)){
                columns = columnViewMap.get(c.CSM_Focus_Category_View__c);
            }
            
            if (c.CSM_Object_Field_Name__c.toLowerCase().trim()!= CSM_Constants.OBJ_IG_ID.toLowerCase() && 
                c.CSM_Object_Field_Name__c.toLowerCase().trim()!= CSM_Constants.OBJ_IG_NAME.toLowerCase()){
                    if(c.CSM_Object_Field_Type__c == CSM_Constants.TYPE_CURRENCY){
                        if(isMCEnabled){
                            columns += columns.length()>0?', FORMAT(convertCurrency('+c.CSM_Object_Field_Name__c + '))': 'FORMAT(convertCurrency('+c.CSM_Object_Field_Name__c+'))';
                        }else{
                            columns += columns.length()>0?', FORMAT('+c.CSM_Object_Field_Name__c +')':'FORMAT('+c.CSM_Object_Field_Name__c+')';
                        }
                    }else{
                        if(c.CSM_Object_Field_Type__c == CSM_Constants.TYPE_DOUBLE 
                           || c.CSM_Object_Field_Type__c == CSM_Constants.TYPE_INTEGER
                           || c.CSM_Object_Field_Type__c == CSM_Constants.TYPE_PERCENT
                           || c.CSM_Object_Field_Type__c == CSM_Constants.TYPE_DATE
                           || c.CSM_Object_Field_Type__c == CSM_Constants.TYPE_DATETIME){
                            columns += columns.length()>0?', '+'FORMAT('+c.CSM_Object_Field_Name__c+')':'FORMAT('+c.CSM_Object_Field_Name__c+')';
                        } else {
                            columns += columns.length()>0?', '+c.CSM_Object_Field_Name__c:c.CSM_Object_Field_Name__c;
                        }
                    }
                
            }
            if (columns != null && nameSpace!=null && nameSpace.length()>0){
                columns = columns.replaceAll(nameSpace, '');
            } 
            columnViewMap.put(c.CSM_Focus_Category_View__c, columns);
        }
        return columnViewMap;
    }
    
    /**
     * @description  builds the Criteria String map for each Play's Related criteria
     * @return Map<String,List<String>> 
     */
    private static Map<String,String> buildViewColumnStringMap(List<CSM_Focus_Category_View_Column__c> allColumnList)
    {
        Map<String,String> columnViewMap = new Map<String,String>();
        String columns = '';
        String nameSpace = CSM_Util.getNamespace();
        Boolean isMCEnabled = CSM_Util.checkMCEnabled();
        String colWithNamespace;
        for(CSM_Focus_Category_View_Column__c c : allColumnList)
        {
            columns = '';
            if (columnViewMap.containsKey(c.CSM_Focus_Category_View__c)){
                columns = columnViewMap.get(c.CSM_Focus_Category_View__c);
            }
            
            if (c.CSM_Object_Field_Name__c.toLowerCase().trim()!= CSM_Constants.OBJ_IG_ID.toLowerCase() && 
                c.CSM_Object_Field_Name__c.toLowerCase().trim()!= CSM_Constants.OBJ_IG_NAME.toLowerCase()){
                    
                columns += columns.length()>0?', '+c.CSM_Object_Field_Name__c:c.CSM_Object_Field_Name__c;               
            }
            
            //DE1091: Commented below lines of code to fix the date format issue on Overview page.
            /*if (columns != null && nameSpace!=null && nameSpace.length()>0){
                columns = columns.replaceAll(nameSpace, '');
            } */
            columnViewMap.put(c.CSM_Focus_Category_View__c, columns);
        }
        return columnViewMap;
    }   

    /**
     * @description  builds the Criteria String map for each Play's Related criteria
     * @return Map<String,List<String>> 
     */
/*  private static Map<String,List<String>> buildViewCriteriaStringMap(List<CSM_Focus_Category_View_Criteria__c> allCriteriaList)
    {
        Map<String,List<String>> tmpMap = new Map<String,List<String>>();
        String nameSpace = CSM_Util.getNamespace();
        Boolean isMCEnabled = CSM_Util.checkMCEnabled();
        for(CSM_Focus_Category_View_Criteria__c c : allCriteriaList)
        {
            List<CSM_Focus_Category_View__c> fcvList = findFCVByViewID(c.CSM_Focus_Category_View__c);
            
            String queryString = '';
            if (c.RLM_Operator__c == CSM_Constants.OPERATOR_LIKE)
            {
                if(c.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
                    queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' \'%'+ fcvList[0].RLM_Currency_Code__c + c.RLM_Values__c + '%\'';
                }
                else{
                    queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' \'%' + c.RLM_Values__c + '%\'';
                }
            
            }
            else if (c.RLM_Operator__c == CSM_Constants.OPERATOR_IN || c.RLM_Operator__c == CSM_Constants.OPERATOR_NOTIN)
            {                
                queryString += CSM_CriteriaService.buildInNotInOperator(queryString,  c.RLM_Values__c, c.RLM_Operator__c, c.RLM_Field_Name__c, c.RLM_Field_Type__c); 
            }
            else
            {
                //If type is Date, read date field, convert to string for query string
                if(c.RLM_Field_Type__c == CSM_Constants.TYPE_DATE)
                {
                    queryString += CSM_CriteriaService.buildDateCriteria(queryString, c.RLM_Is_Specific_Date__c, c.RLM_Date_Value__c, c.RLM_Operator__c, 
                            c.RLM_Date_Literal_String__c, c.RLM_Field_Name__c, Integer.valueOf(c.RLM_Date_Literal_Number__c));
                }
                //If integer place as integer
                else if (c.RLM_Field_Type__c == CSM_Constants.TYPE_INTEGER)
                {
                    if(c.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
                        queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' '+ fcvList[0].RLM_Currency_Code__c + Integer.valueOf(c.RLM_Values__c);
                    }
                    else{
                        queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' ' + Integer.valueOf(c.RLM_Values__c);
                    }
                }
                //If double, place as integer
                else if (c.RLM_Field_Type__c == CSM_Constants.TYPE_DOUBLE || c.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY || c.RLM_Field_Type__c == CSM_Constants.TYPE_PERCENT)
                {
                    if(c.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
                        queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' '+ fcvList[0].RLM_Currency_Code__c + Double.valueOf(c.RLM_Values__c);
                    }
                    else{
                        queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' ' + Double.valueOf(c.RLM_Values__c);
                    }
                }
                //otherwise string or picklist and display as string in quotes
                else
                {
                    if (c.RLM_Values__c == null)
                    {
                        if(c.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
                            queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' '+ fcvList[0].RLM_Currency_Code__c + c.RLM_Values__c;
                        }
                        else{
                            queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' ' + c.RLM_Values__c;
                        }
                    }
                    else
                    {
                        if(c.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
                            queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' \''+ fcvList[0].RLM_Currency_Code__c + c.RLM_Values__c + '\'';
                        }
                        else{
                            queryString += c.RLM_Field_Name__c + ' ' + c.RLM_Operator__c + ' \'' + c.RLM_Values__c + '\'';
                        }
                    }
                }
            }
            if (queryString !=null && nameSpace!=null && nameSpace.length()>0){
                queryString = queryString.replaceAll(nameSpace, '');
            }
            //If the map contains the playid, add the query string to it, 
            if(tmpMap.containsKey(c.CSM_Focus_Category_View__c))
            {
                tmpMap.get(c.CSM_Focus_Category_View__c).add(queryString);
            }
            else
            {
                tmpMap.put(c.CSM_Focus_Category_View__c, new List<String>{queryString});
            }
        }
        return tmpMap; 
    }*/
    
    private static List<CSM_Focus_Category_View__c> updateViewsWithCrtieria(Map<String,String> columnViewMap, 
                                                                    Map<string,List<String>> viewCriteriaStringMap, 
                                                                    List<CSM_Focus_Category_View__c> allViewList) {
        return null;
    }
    
    /**
     * @description loops through all the plays, builds the full query string for criteria and updates the field on the play  
     * @return List<CSM_Focus_Category_View__c>
 
     */
    private static List<CSM_Focus_Category_View__c> updateViewsWithCrtieria(Map<String,String> columnViewMap, 
                                                                    /*Map<string,List<String>> viewCriteriaStringMap,*/ 
                                                                    List<CSM_Focus_Category_View__c> allViewList,
                                                                    Map<String,String> columnViewMapForQuery) {
        //Go through map and build total string 
        system.debug(' tst1- ' + columnViewMap);
        system.debug(' tst2- ' + allViewList);
        system.debug(' tst3- ' + columnViewMapForQuery);                
        List<CSM_Focus_Category_View__c> tmpViewList = new List<CSM_Focus_Category_View__c>();
        Boolean isMCEnabled = CSM_Util.checkMCEnabled();
        for(CSM_Focus_Category_View__c p : allViewList)
        {
            String finalQueryString='';
            String columns = '';
            String columsForQuery = '';
            String finalQueryParams = '';
            Set<String> arrFinalQueryParams = null;         
                        
            if (p.CSM_Object_Name__c.toLowerCase() != CSM_Constants.OBJ_TYPE_TASK.toLowerCase()) {
                if (columnViewMap!=null && columnViewMap.containsKey(p.id)){
                    columns = columnViewMap.get(p.id);                  
                }
                if (columnViewMapForQuery!=null && columnViewMapForQuery.containsKey(p.id)){
                    columsForQuery = columnViewMapForQuery.get(p.id);                   
                }
                if(CSM_Constants.OBJ_CASE.equals(p.CSM_Object_Name__c)){
                   finalQueryString = 'select id' ;
                   if(String.isNotBlank(columns)){
                   		finalQueryString += ', '+ columsForQuery;
                   }
                   if(!(finalQueryString.contains(', CaseNumber') || finalQueryString.contains(',CaseNumber') || finalQueryString.contains(',  CaseNumber'))){
                   		finalQueryString += ', CaseNumber' ;
                   }
                   finalQueryString = finalQueryString + ' from ' +p.CSM_Object_Name__c;
	               system.debug('\n\n @@ finalQueryString :: '+finalQueryString);
                }else if(CSM_Constants.OBJ_CONTRACT.equalsIgnoreCase(p.CSM_Object_Name__c)){
                    finalQueryString = 'select id ' + 
                                        (String.isNotBlank(columns) && columns.contains(CSM_Constants.CONTRACT_NUMBER)
                                            ?','+columsForQuery
                                            :(', '+CSM_Constants.CONTRACT_NUMBER) + (String.isNotBlank(columns)?', '+columsForQuery:''))
                                        +' from ' +p.CSM_Object_Name__c;
                }
                else{
                    if(p.CSM_Object_Name__c == CSM_Constants.OBJ_TYPE_ACCOUNT){
	                    if(columns.contains('CSM_Account_Has_Success_Plan__c')) {
	                    	finalQueryString = 'select id, name ' + (columns!=null && columns.length()>0?', '+columsForQuery:'') +' from ' +p.CSM_Object_Name__c;
	                	}
	                	else{
	                  	  finalQueryString = 'select id, name, CSM_Account_Has_Success_Plan__c ' + (columns!=null && columns.length()>0?', '+columsForQuery:'') +' from ' +p.CSM_Object_Name__c;
	                	}
                	}
                	else {
                		finalQueryString = 'select id, name ' + (columns!=null && columns.length()>0?', '+columsForQuery:'') +' from ' +p.CSM_Object_Name__c;
                	}
                }
            }
            
            if (!String.isBlank(finalQueryString)) {
                finalQueryParams = finalQueryString.substring('select '.length(),finalQueryString.indexOf(' from ')).deleteWhitespace();
                if (!String.isBlank(finalQueryParams)) {    
                    arrFinalQueryParams = new Set<String>(finalQueryParams.split(','));
                }
            }
            system.debug(' arr1-' + arrFinalQueryParams);
            //system.debug(' arr2-' + p.CSM_Currency_Header__c);
            //system.debug(' finalQueryString contains (p.CSM_Currency_Header__c)-' + finalQueryString.contains(p.CSM_Currency_Header__c));
            String namespace = CSM_Util.getNamespace();
            String headerCurrency = '';
            
             if (p.CSM_IsTile__c) 
            	p.CSM_Currency_Header__c = '';
            
            if(String.isNotBlank(p.CSM_Currency_Header__c) && p.CSM_Currency_Header__c.startsWith(nameSpace)){
                headerCurrency = p.CSM_Currency_Header__c.removeStart(nameSpace);
            }else{
                headerCurrency = p.CSM_Currency_Header__c;
            }
            if(!String.isBlank(headerCurrency) && arrFinalQueryParams!=null && !arrFinalQueryParams.isEmpty()){
                if(isMCEnabled && !arrFinalQueryParams.contains('FORMAT(convertCurrency('+ headerCurrency +'))')){
                    if (finalQueryString.contains(headerCurrency)) {
                        finalQueryString = finalQueryString.replace (headerCurrency, 'convertCurrency('+ headerCurrency +')');
                    } else {
                        finalQueryString = finalQueryString.replace( ' from ',(', convertCurrency('+ headerCurrency +') from '));
                    }
                }else if(!arrFinalQueryParams.contains(headerCurrency) && !finalQueryString.contains(headerCurrency)){
                    finalQueryString = finalQueryString.replace(' from ', (', '+ headerCurrency +' from '));
                }
            }
            if (p.CSM_Object_Name__c.toLowerCase() == CSM_Constants.OBJ_TYPE_TASK.toLowerCase()) {

                if(!String.isEmpty(headerCurrency)){
                    finalQueryString = CSM_Constants.TASK_SOQL + ' where ';                 
                    finalQueryString = finalQueryString.replace(' FROM ', (', '+ headerCurrency +' from '));//CSM_Constants.TASK_SOQL + ',' + p.CSM_Currency_Header__c + ' where ';                   
                    if(isMCEnabled){
                        finalQueryString = finalQueryString.replace (' FROM ', 'convertCurrency('+ headerCurrency +' from)');
                    }
                }else{
                    
                    finalQueryString = CSM_Constants.TASK_SOQL + ' where ';             
                }

                //Check for SOQL to only return task with plays in it
                finalQueryString += CSM_Constants.OBJ_T_PLAY+' != null';
            }
            system.debug(' finalQueryString-' + finalQueryString);
            String criteria='';
            /*if (viewCriteriaStringMap!=null && !viewCriteriaStringMap.isEmpty() && viewCriteriaStringMap.containsKey(p.Id)) {
                List<String> cList = viewCriteriaStringMap.get(p.id);
                for(Integer i=0; i<cList.size(); i++)
                {
                    String finalStringVal = cList[i];
                    if(i==0 && p.CSM_Object_Name__c.toLowerCase() != CSM_Constants.OBJ_TYPE_TASK.toLowerCase())
                    {
                        finalQueryString += ' WHERE ' + cList[i];
                        criteria += ' WHERE ' + cList[i];
                    }
                    else
                    {
                        finalQueryString += ' and ' + cList[i];
                        criteria += ' and ' + cList[i];
                    }
                }
            }*/
            if(p.CSM_Object_Name__c.toLowerCase() != CSM_Constants.OBJ_TYPE_TASK.toLowerCase() && p.CSM_Criteria__c!=null && !String.isEmpty(p.CSM_Criteria__c)){
                p.CSM_Criteria__c = ' WHERE (' + p.CSM_Criteria__c + ')';           
            } else {
                /*if(String.isNotBlank(p.CSM_Filter_By_Owner_Value__c) && p.CSM_Filter_By_Owner_Value__c.startsWith('My ')) {
                    p.CSM_Criteria__c = p.CSM_Criteria__c + ' and  ( OwnerId = \'' + UserInfo.getUserId() + '\'' + ')'; 
                }*/
            }

            /*if(String.isNotBlank(p.CSM_Filter_By_Owner_Value__c) && p.CSM_Filter_By_Owner_Value__c.startsWith('My ') && p.CSM_Criteria__c == null) {
                if(p.CSM_Object_Name__c.toLowerCase() == CSM_Constants.OBJ_TYPE_TASK.toLowerCase()){
	                p.CSM_Criteria__c = '  ( OwnerId = \'' + UserInfo.getUserId() + '\'' + ')';                
                }else{
	                p.CSM_Criteria__c = ' where  ( OwnerId = \'' + UserInfo.getUserId() + '\'' + ')';                
                }
            }*/

            p.CSM_Columns__c = columns;
            if(p.CSM_Object_Name__c.toLowerCase() != CSM_Constants.OBJ_TYPE_TASK.toLowerCase() && p.CSM_Criteria__c!=null && !String.isEmpty(p.CSM_Criteria__c)){
                p.CSM_SOQL__c = finalQueryString + p.CSM_Criteria__c;           
            }else if( p.CSM_Criteria__c!=null && !String.isEmpty(p.CSM_Criteria__c)){
                p.CSM_SOQL__c = finalQueryString + ' and (' + p.CSM_Criteria__c + ')';          
            }else{
                p.CSM_SOQL__c = finalQueryString;
            }
            
            if(String.isNotBlank(p.CSM_Case_Queue__c) && p.CSM_Filter_By_Owner_Value__c == 'Queue'){
            	if(p.CSM_SOQL__c.toLowerCase().contains('where')){
	            	p.CSM_SOQL__c += ' and ownerid = \'' + p.CSM_Case_Queue__c + '\'';
            	}else{
	            	p.CSM_SOQL__c += ' where ownerid = \'' + p.CSM_Case_Queue__c + '\'';            	
            	}
            }
            if(String.valueOf(p.CSM_Filter_By_Owner_Value__c).contains('My')) {
				if(p.CSM_SOQL__c.toLowerCase().contains('where')){
					p.CSM_SOQL__c += ' and ownerId = <placeholder>';
				} else {
					p.CSM_SOQL__c += ' where ownerId = <placeholder>';
				}
			}
            if(p.CSM_Sort_Order__c=='Asc')
            {
                p.CSM_SOQL__c+=' Order By '+p.CSM_Sort_By__c+' '+p.CSM_Sort_Order__c+' Nulls First';
            }
            else{
                p.CSM_SOQL__c+=' Order By '+p.CSM_Sort_By__c+' '+p.CSM_Sort_Order__c+' Nulls Last';
            }
            tmpViewList.add(p);
        }
        system.debug('tmpViewList~~'+tmpViewList);
        return tmpViewList;
    }
    
    public static List<CSM_Focus_Category_View__c> getAllFocusCategoryViewsByUser(String userId) 
    {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_FCV_IS_SAVED_SEARCH};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        List<CSM_Focus_Category_View__c> tmpList = new List<CSM_Focus_Category_View__c>();
        if (noAccessList.isEmpty())
        {
        	string query = 'SELECT Id, CSM_Display_Name__c, CSM_IsTile__c, CSM_Is_Active__c, CSM_Object_Name__c, CSM_Filter_By_Owner_Value__c, CSM_Currency_Header__c, lastModifiedBy.Name, FORMAT(lastModifiedDate) '
                      	   + 'FROM CSM_Focus_Category_View__c WHERE createdById = \'' + userId + '\' and CSM_Display_Name__c != null and RLM_Is_Saved_Search__c != true order by lastModifiedDate DESC LIMIT 2000';
                        
           	tmpList = database.query(query);
        }
        else {
        	String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            	System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        
        return tmpList; 
    }
    
    public static List<CSM_Focus_Category_View__c> getAllFocusCategoryViews() 
    {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_FCV_IS_SAVED_SEARCH};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        List<CSM_Focus_Category_View__c> tmpList = new List<CSM_Focus_Category_View__c>();
        if (noAccessList.isEmpty())
        {
       		string query = 'SELECT Id, CSM_Display_Name__c, CSM_IsTile__c, CSM_Is_Active__c, CSM_Object_Name__c, CSM_Filter_By_Owner_Value__c, CSM_Currency_Header__c, lastModifiedBy.Name, FORMAT(lastModifiedDate) '
                           + 'FROM CSM_Focus_Category_View__c WHERE CSM_Display_Name__c != null AND RLM_Is_Saved_Search__c != true order by lastModifiedDate DESC LIMIT 2000';
                        
       		tmpList = database.query(query);
        }
        else {
            String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            	System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        
        return tmpList; 
    }
    
    /*Added for US314 to get the group names and count to which the to be deleted Focus Category View belongs to*/  
    public static List<SObject> getAllGroupsforFocusCategoryView(String fcvId) 
    {

        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCG_DISPLAY_NAME};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCG,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        List<SObject> groups;
        
        if (noAccessList.isEmpty())
        {
            groups= [Select CSM_Focus_Category_Column__r.CSM_Focus_Category_Group__r.CSM_Display_Name__c, CSM_Focus_Category_Column__c From CSM_Focus_Category__c
            where CSM_Focus_Category_View__c =: fcvId and CSM_Focus_Category_Column__r.CSM_Focus_Category_Group__r.CSM_IsActive__c =: true];
        }
        else {
            String[] arguments = new String[] {CSM_Constants.OBJ_FCG + ':'+String.valueOf(noAccessList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

        //System.Debug('GroupList - ' + tmpGroups[0].getSObject('CSM_Focus_Category_Column__r').get('CSM_Focus_Category_Group__c'));
        return groups; 
    }
    
    /*Added for US314 to delete the Focus Category View*/
    public static void deleteFocusCategoryView(CSM_Focus_Category_View__c fcv) 
    {
        try{
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCV, null, CSM_Constants.DML_OPERATION_DELETE);
            List<CSM_Focus_Category_View__c> fcvList = new List<CSM_Focus_Category_View__c>();
            fcvList.add(fcv);
            delete fcvList;     
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }   

    }
    
    /* 
     *@description Get the detail of FC View obj and create the Clone of the object.
     *@Params : It accepts Id of FC view. 
     */
    public static List<CSM_Focus_Category_View__c> cloneFCViewById(String fcViewID){
        List<CSM_Focus_Category_View__c> fcView = findFCVByViewID (fcViewID);
        
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
                                    CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_I_OBJECT_NAME, 
                                    CSM_Constants.OBJ_FCV_CRIT, CSM_Constants.OBJ_FCV_SOQL, CSM_Constants.OBJ_FCV_CURRENCY_HEADER};
          
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCV, fcvFieldList, CSM_Constants.DML_OPERATION_INSERT);
            
        List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
        if(fcView != null){
            for(CSM_Focus_Category_View__c fcViewObj : fcView){
                CSM_Focus_Category_View__c fvcObj = new CSM_Focus_Category_View__c();
                fvcObj = fcViewObj.clone(false, false, false, false);
                String name = Label.CSM_LBL_CLONE_PREFIX + ' ' + fvcObj.CSM_Display_Name__c;
                String fcName;
                if(name.length() > 40){
                    fcName = name.substring(0, 40);
                }else {
                    fcName = name;
                }
                fvcObj.CSM_Display_Name__c = fcName;
                fvcObj.name = fcName;
                fcViewList.add(fvcObj);
                system.debug('\n\n\n This is Focus category clone fcvObj  ::  ' + fvcObj);
            }
            insert fcViewList;
        }
        return fcViewList;
     }
     
    public static List<CSM_Focus_Category_View__Share> retrieveFocusCategoryViewShare(String fcViewId) 
    {
            return [select Id,Parentid, UserOrGroupId from CSM_Focus_Category_View__Share where rowCause not in ('Owner', 'Rule') and ParentId =: fcViewId];     
    }

    public static void deleteFocusCategoryViewShare(List<CSM_Focus_Category_View__Share> fcvShareList) 
    {
            List<CSM_Focus_Category_View__Share> lstFcvShare = [select Id from CSM_Focus_Category_View__Share where id not in:fcvShareList and parentid =:fcvShareList[0].parentId and RowCause = 'Manual'];
            Database.delete(lstFcvShare, false);
            //delete fcvShareList;     
    }

    public static void insertFocusCategoryViewShare(List<CSM_Focus_Category_View__Share> fcvShareList) 
    {
            Database.upsert(fcvShareList, false);     
    }
    
    public static List<Group> retrieveIdsForGroups(Set<String> groupNames) 
    {
            return [select Id, DeveloperName from Group where DeveloperName in :groupNames];     
    }
     
     
     /* Start - Code Added for US2118 */
    
     /**
     * @description : This method returns the List of FCView objects as per 'Type' (Card or Tiles)  passed as parameter. Added for US2118.
     */
     public static List<CSM_Focus_Category_View__c> getFcViewInfoType(Boolean isTiles){
     	Set<Id> fcIds = getFocusCategoryIds(new Set<Id>{Userinfo.getUserId()});
        String soql = checkFlsAndFormSoql(isTiles);
        soql = soql+' AND Id IN :fcIds AND RLM_Is_Saved_Search__c != true'+' order by LastModifiedDate desc';
        system.debug('@@@@ soql :: ' + soql);
        List<CSM_Focus_Category_View__c>  fcvList = Database.query(soql);
        Integer fcCount = 0;
        List<CSM_Focus_Category_View__c> fcvFinalList = new List<CSM_Focus_Category_View__c>();
        if(fcvList != null && !fcvList.isEmpty()) {
	        for(CSM_Focus_Category_View__c fcv : fcvList) {
	        	if(fcCount < 6) {
	        		fcvFinalList.add(fcv);
	        		fcCount++;
	        	} else {
	        		break;
	        	}
	        }
        }
        return fcvFinalList;
     }
     
    /**
    * @description : This method returns the List of FCWrapper object and set all the required values to the FCWrapper Objects. Added for US2118.
    */
    public static List<CSM_FocusCategoryWrapper> populateFCWrapperClass(Boolean isTiles, Integer LimitVal) {
        Integer soqlCount = 0;
        PageReference pageRefTemp = Page.CSM_TaskList;
        String taskRetURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL; 
        pageRefTemp = Page.CSM_FocusCategoriesFullList;
        String acctOpptyRetURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL; 
        Integer recLimit = CSM_AdminDataAccess.getFocusCategoryRecLimit();
        Integer recMaxLimit = CSM_AdminDataAccess.getFocusCategoryMaxRecLimit();
        List<SObject> listSObjectCalc = new List<SObject>();
        Map<Id, Integer> soqlResultCountMap = new Map<Id, Integer>();
        List<CSM_FocusCategoryWrapper> fcWrapperList = new List<CSM_FocusCategoryWrapper>();
        Map<String, List<SObject>> mapViewInfo = new Map<String, List<SObject>>();  
        List<Schema.FieldSetMember> taskMandatoryFields = getTaskMandatoryFields();   
        /* US2757: Controlling Focus category view by ordering. */    
        //List<CSM_Focus_Category_View__c> fcViewList = getFcViewInfoType(isTiles,6);
        
        List<CSM_Focus_Category_View__c> fcViewList;
        List<Id> fcIdsByOrderList = CSM_FocusCategoryDisplayOrderDataAccess.getFocusCategoryIdsByOrder(new Set<Id>{ UserInfo.getUserId()},isTiles?'Tile':'Card');
        if(fcIdsByOrderList == null || fcIdsByOrderList.isEmpty()){
        	fcViewList = getFcViewInfoType(isTiles);
        }
        else{
        	fcViewList = getFcViewInfoByOrder(isTiles);
        }
        Map<Id, CSM_Focus_Category_View__c> mapFCView = new Map<Id, CSM_Focus_Category_View__c>(fcViewList);

        for (CSM_Focus_Category_View__c fc : mapFCView.values()) {
            Boolean hasSOQLError = false;
            soqlCount ++;
            // Create a new focus category wrapper
            CSM_FocusCategoryWrapper fcW = new CSM_FocusCategoryWrapper();
            fcW.CategoryId = fc.Id;
            fcW.CategoryDisplayName = fc.CSM_Display_Name__c;
            fcW.SOQL = fc.CSM_SOQL__c;
            fcW.Columns = fc.CSM_Columns__c;
            fcW.Criteria = fc.CSM_Criteria__c;
            fcW.CategoryActive = true;
            fcW.headerCurrencyFieldName = fc.CSM_Currency_Header__c;
            fcW.isTiles = fc.CSM_IsTile__c;
            fcw.fcvFilter = fc.CSM_Filter_By_Owner_Value__c;

            fcW.CategoryViewId = fc.Id;
            fcW.CategoryObjType = fc.CSM_Object_Name__c;
            if(CSM_Constants.OBJ_CONTRACT.equalsIgnoreCase(fcW.CategoryObjType)){
                fcW.linkName = CSM_Constants.CONTRACT_NUMBER;
            }else{
                fcW.linkName = CSM_Constants.NAME;
            }

            if (!String.isBlank(fcW.headerCurrencyFieldName)){
                String currencyName = UserInfo.getDefaultCurrency();
                if(UserInfo.isMultiCurrencyOrganization()){
                    fcW.headerCurrencyCode = currencyName+' ';
                }else{
                    fcW.headerCurrencyCode=currencyName+' ';
                }
            }

            fcW.UniqueId = CSM_Util.NewGuid();
            String fieldValue = null;
            String filter = '&';

            // Check if the Map contains object type  -- if not we need to create the View info
            if (fcW.CategoryObjType!=null){
                if(fcW.CategoryObjType != CSM_Constants.OBJ_TYPE_TASK){
                    fcW.ViewURL = acctOpptyRetURL+fcW.CategoryViewId;                               
                }else{
                    fcW.ViewURL = taskRetURL+fcW.CategoryViewId;
                }
            }

            if (Test.isRunningTest()){
                fcW.soql = 'SELECT Id, name,AnnualRevenue, BillingCity, BillingState FROM '+fcW.CategoryObjType ; 
            }
            ///
            try { 
                String soql = CSM_Util.processMyFCVSOQL(fcW.SOQL, fcw.fcvFilter);
                if(!soql.toLowerCase().contains('billingcountrycode')){
                	soql = soql.replace('BillingStateCode','BillingStateCode,BillingCountryCode');                
                }
                if(!soql.toLowerCase().contains('shippingcountrycode')){
                	soql = soql.replace('ShippingStateCode','ShippingStateCode,ShippingCountryCode');                
                }
                if(!soql.toLowerCase().contains('billingcountrycode')){
                	soql = soql.replace('ShippingStateCode','ShippingStateCode,BillingCountryCode');                
                }

                soql  += ' limit '+String.valueOf(recMaxLimit);
                //append the mandatory Task Parameters to the query
                if(fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_TASK && taskMandatoryFields != null && !taskMandatoryFields.isEmpty()) {
                    String mandatoryFieldStrings = ' ';
                    for(Schema.FieldSetMember f : taskMandatoryFields) {
                        if (!soql.toLowerCase().contains(f.FieldPath.toLowerCase())){
                            mandatoryFieldStrings += String.valueOf(f.FieldPath) + ',';
                        }
                    }
                    //get the query substring till 'select' and append the mandatory fields string                                      
                    soql = soql.substring(0, 6) + mandatoryFieldStrings + soql.substring(6);
                }                                   

                system.debug('soql fc$::' + soql);
                fcW.listSObject = database.query(soql);
                Set<Id> recIds = new Set<Id>();
                listSObjectCalc = fcW.listSObject;
                soqlResultCountMap.put(fcW.CategoryViewId, fcW.listSObject.size());
                List<SObject> objList = new List<SObject>();

                Integer iCounter = 1;
                for (SObject sobj : fcW.listSObject){
                    recIds.add(sobj.id);
                    if (iCounter<=recLimit){
                        objList.add(sObj);  
                    }
                    iCounter++;
                }

                if(fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_TASK) {
                    fcW.sObjectHasEditAccess = CSM_AccessController.hasEditRecordAccess(recIds,userinfo.getUserId());
                }
                // Get the controller for an object type
                mapViewInfo.put(fcW.CategoryViewId, objList);
            } catch (Exception ex){
                hasSOQLError = true;
            }

            if (hasSOQLError == false){
                if (soqlResultCountMap!=null && soqlResultCountMap.containsKey(fcW.CategoryViewId)){
                    fcW.CategoryCount = soqlResultCountMap.get(fcW.CategoryViewId);
                }
                // Get the list view rows
                fcW.listSObject = mapViewInfo.get(fcW.CategoryViewId); 
                System.debug('fcW.CategoryViewId - ' + fcW.CategoryViewId + ' - fcW.listSObject - '+fcW.listSObject);

                // Get the category count for display purposes
                if (fcW.Criteria!=null && fcW.Criteria.length() > 0){
                    fcW.CriteriaJSON = JSON.serialize(mapFCView.get(fcW.CategoryViewId).CSMFocusCategoriesViewCriteria__r);
                    fcW.CriteriaObjList = new List<CSM_Focus_Category_View_Criteria__c>();
                    for (CSM_Focus_Category_View_Criteria__c fcCrit: mapFCView.get(fcW.CategoryViewId).CSMFocusCategoriesViewCriteria__r){
                        if (fcCrit.RLM_Date_Literal_String__c != null){
                            if (fcCrit.RLM_Date_Literal_String__c.startsWith('N_')){
                                fcCrit.RLM_Date_Literal_String__c = fcCrit.RLM_Date_Literal_String__c.replace('N_', fcCrit.RLM_Date_Literal_Number__c + ' ');
                            }else if (fcCrit.RLM_Date_Literal_String__c.contains('_N_')){
                                fcCrit.RLM_Date_Literal_String__c = fcCrit.RLM_Date_Literal_String__c.replace('_N_', ' ' + fcCrit.RLM_Date_Literal_Number__c + ' ');
                            }
                        }
                        fcW.CriteriaObjList.add(fcCrit);
                    }
                }           
                String namespace = CSM_Util.getNamespace();
                Map<String, CSM_FocusCategoryWrapper.colNameForAPI> nameForAPI = new Map<String, CSM_FocusCategoryWrapper.colNameForAPI>();                 
                Map<String, CSM_FocusCategoryWrapper.colNameForAPI> nameForREF = new Map<String, CSM_FocusCategoryWrapper.colNameForAPI>(); 
                Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                Schema.SObjectType sobjType = globalDescribe.get(fcW.CategoryObjType);
                if(sobjType == null){
                    sobjType = globalDescribe.get(namespace + fcW.CategoryObjType);
                }
                Map<String, Schema.SObjectField> objFieldInfo = sobjType.getDescribe().fields.getMap();
                String refRelation = '';
                if (fcW.listSObject!=null && !fcW.listSObject.isEmpty()) {

                    if (fcW.Columns!=null ){
                        CSM_Focus_Category_View__c fcViewObj = mapFCView.get(fcW.CategoryViewId);
                        List<CSM_Focus_Category_View_Column__c> fcCategoryViewColList = fcViewObj.getSObjects('CSMFocusCategoryView__r');
                        if(fcCategoryViewColList != null && !fcCategoryViewColList.isEmpty()){
	                        for (CSM_Focus_Category_View_Column__c rcV : fcCategoryViewColList){
	                            CSM_FocusCategoryWrapper.colNameForAPI nForAPI = new CSM_FocusCategoryWrapper.colNameForAPI();
	                            CSM_FocusCategoryWrapper.colNameForAPI nForREF = new CSM_FocusCategoryWrapper.colNameForAPI();
	
	                            if(rcV.CSM_Object_Field_Type__c == CSM_Constants.TYPE_REFERENCE){
	                                String fieldName = '';
	                               /*if(String.isNotBlank(rcV.CSM_Object_Field_Name__c) 
	                                        && rcV.CSM_Object_Field_Name__c.startsWith(nameSpace)){
	                                    fieldName = rcV.CSM_Object_Field_Name__c.removeStart(nameSpace);
	                                }else{
	                                    fieldName = rcV.CSM_Object_Field_Name__c;
	                                } */
	                                // Added for US2419
	                                if(String.isNotBlank(rcV.CSM_Object_Field_Name__c)){
	                                	fieldName = rcV.CSM_Object_Field_Name__c;
	                                }
	                                
	                                refRelation = CSM_Util.findNameForLookup(fieldName, objFieldInfo);
	                                nForREF.apiName = refRelation.trim().toLowerCase();
	                                nForREF.displayName = rcV.CSM_Display_Name__c;
	                                nForREF.fieldType = rcV.CSM_Object_Field_Type__c;
	                                nForREF.refFieldId = rcV.CSM_Object_Field_Name__c.trim().toLowerCase();
	                                nameForREF.put(nForREF.apiName, nForREF);
	                            }else{
	                                nForAPI.apiName = rcV.CSM_Object_Field_Name__c.trim().toLowerCase();
	                                nForAPI.displayName = rcV.CSM_Display_Name__c;
	                                nForAPI.fieldType = rcV.CSM_Object_Field_Type__c;
	                                nameForAPI.put(nForAPI.apiName, nForAPI);
	                            }
	                        }
                        }
                    }
                }

                List<CSM_FocusCategoryWrapper.colNameForAPI> columnList = new List<CSM_FocusCategoryWrapper.colNameForAPI>();
                List<CSM_FocusCategoryWrapper.colNameForAPI> columnLimitList = new List<CSM_FocusCategoryWrapper.colNameForAPI>();

                Integer i = 0;
                if (fcW.Columns!=null){
                    System.debug('@@@ ColName nameForAPI - '+nameForAPI);
                    for (String column : fcW.Columns.split(',')) {
                        if (column!=null && column!='null' && 
                                column.trim().toLowerCase()!=CSM_Constants.OBJ_IG_ID.toLowerCase() && 
                                column.trim().toLowerCase()!=CSM_Constants.OBJ_IG_NAME.toLowerCase()){
                            String colName = column.toLowerCase().trim();
                            CSM_FocusCategoryWrapper.colNameForAPI cNameForAPI = new CSM_FocusCategoryWrapper.colNameForAPI();
                            cNameForAPI.apiName = colName;
                            cNameForAPI.displayName = colName;
                            cNameForAPI.fieldType = '';
                            System.debug('@@@ ColName - '+ colName + '@@@ ColName  in map - ' + nameForAPI.containsKey(colName));
                            if (nameForAPI.containsKey(colName)){
                                cNameForAPI.displayName = nameForAPI.get(colName).displayName;
                                cNameForAPI.fieldType = nameForAPI.get(colName).fieldType;
                                cNameForAPI.refFieldId = nameForAPI.get(colName).refFieldId;
                            }else if(nameForREF.containsKey(colName)){
                                cNameForAPI.displayName = nameForREF.get(colName).displayName;
                                cNameForAPI.fieldType = nameForREF.get(colName).fieldType;
                                cNameForAPI.lookUpField = CSM_Constants.TYPE_LOOKUP;
                                cNameForAPI.refFieldId = nameForREF.get(colName).refFieldId;
                            }
                            columnList.add(cNameForAPI);
                            if (i<2){
                                columnLimitList.add(cNameForAPI);
                            }
                            i++;
                        }
                    }
                    fcW.ColumnNameList = columnList;
                    fcW.ColumnNameLimitList = columnLimitList;
                } 
                fcW.totalCurrencyAmount = 0;
                if(!String.isBlank(fcW.headerCurrencyFieldName) && listSObjectCalc != null && !listSObjectCalc.isEmpty()){
                    //Count for max categories
                    for(sObject s: listSObjectCalc){
                        Double c;
                        try{
                            c = (Double)s.get(fcW.headerCurrencyFieldName);                             
                        }catch(System.TypeException ste){
                            String formattedValue = (String)s.get(fcW.headerCurrencyFieldName);
                            if(String.isNotBlank(formattedValue)){
                                if(UserInfo.isMultiCurrencyOrganization()){
                                    formattedValue = formattedValue.right(formattedValue.length() - 4);
                                }else{
                                    formattedValue = formattedValue.right(formattedValue.length() - 1);
                                }
                                // remove special chars
                                formattedValue = formattedValue.replaceAll('[^0-9.]', '');  //DE1772                                
                                c = Double.valueOf(formattedValue);
                            }
                        }
                        if(c != null){
                            fcW.totalCurrencyAmount += c;
                        }
                    }
                }
            }
            fcWrapperList.add(fcW);
        } //end for Loop
        system.debug('@@@@ FCV Wrapper List ::  ' + fcWrapperList);
        return fcWrapperList;
    }//end function


    public static List<Schema.FieldSetMember> getTaskMandatoryFields() {
        List<Schema.FieldSetMember> taskMandatoryFields = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> tmpFieldsList = SObjectType.Task.FieldSets.CSM_CompleteDismiss_Popup.getFields();
        for(Schema.FieldSetMember f : tmpFieldsList) {
            if (f.DBRequired && String.valueOf(f.Type) != 'ID'){
                taskMandatoryFields.add(f);
            }
        }
        return taskMandatoryFields;
    }     
     
    /*Fix for DE2175*/
    public static void deleteFCV(List<CSM_Focus_Category_View__c> fcvList)
    {
        try{
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCV, null, CSM_Constants.DML_OPERATION_DELETE);
            delete fcvList;     
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }   

    }
    
    /*Fix for DE2175*/
    public static List<CSM_Focus_Category_View__c> getToDeleteFCV()
    {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,'Id'};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        if (noAccessList.isEmpty())
        {
	    	List<CSM_Focus_Category_View__c> lstFCV = [select Id from CSM_Focus_Category_View__c where CSM_Display_Name__c = null and ownerid =: userInfo.getUserId()];        	
            return lstFCV;
        }
        else
        {   
             String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));            
        }
        return null;
    }
	
     
   /* End -- Code added for US2118 */
   
    public static List<QueueSobject> getQueues()
    {
        List<QueueSobject> queueObjlist = database.query('SELECT QueueId, Queue.Name FROM QueueSobject WHERE SobjectType = \'Case\' ');
        return queueObjlist;
    }
   
   /* US2730 : This method is used to get FocusCategoryViewShare records based on Group Ids.*/
	public static Set<Id> getFocusCategoryIds(Set<Id> userIds) {
        Set<Id> focusCatIdsSet = new Set<Id>();
        Boolean isPortalUser = false;
        
        if(CSM_AccessController.hasField('User', 'IsPortalEnabled')){
            Map<Id,User> userMap = CSM_UserDataAccess.getUserDetailsById((Set<String>)JSON.deserialize(JSON.serialize(userIds), Set<String>.class),new List<String>{'IsPortalEnabled'});
        	
        	isPortalUser = (userMap != null && !userMap.isEmpty() ? (Boolean)userMap.values()[0].get('IsPortalEnabled') : false);
        }
        
        Set<Id> groupIds = CHL_PublicGroupDataAccess.getGroupIdsSharedToUser(userIds,isPortalUser);
        
        if(groupIds != null && groupIds.size()>0){
            List<CSM_Focus_Category_View__Share> focusCatShareList = [SELECT Id,UserOrGroupId,ParentId 
                                                                      FROM CSM_Focus_Category_View__Share 
                                                                      WHERE (UserOrGroupId IN: userIds or UserOrGroupId IN:groupIds)];        
            for(CSM_Focus_Category_View__Share fcShare : focusCatShareList){
                focusCatIdsSet.add(fcShare.ParentId);
            }
        }
        return focusCatIdsSet;
    }
    
    /* US2757 : This method is used to get FocusCategoryView records by order set by current user.*/
    
    public static List<CSM_Focus_Category_View__c> getFcViewInfoByOrder(Boolean isTiles){
        List<Id> fcIds = CSM_FocusCategoryDisplayOrderDataAccess.getFocusCategoryIdsByOrder(new Set<Id>{ UserInfo.getUserId()},isTiles?'Tile':'Card');
        String soql = checkFlsAndFormSoql(isTiles);
        soql = soql+' AND Id IN :fcIds AND RLM_Is_Saved_Search__c != true';
        system.debug('@@@@ soql :: ' + soql);
        List<CSM_Focus_Category_View__c>  fcvList = Database.query(soql);
        List<CSM_Focus_Category_View__c>  fcvSortedList = new List<CSM_Focus_Category_View__c>();
        for(Id fcId : fcIds){
            for(CSM_Focus_Category_View__c fc:fcvList){
                if(fcId == fc.Id){
                    fcvSortedList.add(fc);                  
                }
        	}
        }
        return fcvSortedList;
     }
    
    /* US2730 : This method is used to form soql.*/ 
	public static String checkFlsAndFormSoql(Boolean isTiles){
     	List<String> fcvFieldList = new List<String>{'CSM_Columns__c','CSM_IsTile__c','CSM_Is_Active__c','CSM_Criteria__c','CSM_Filter_By_Owner_Value__c','CSM_Currency_Header__c','CSM_Display_Name__c','CSM_Object_Name__c',
                                                     'CSM_SOQL__c','RLM_Currency_Code__c','RLM_Filter_Logic__c','CSM_IsTile__c'};
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FCV, fcvFieldList, CSM_Constants.DML_OPERATION_READ);
       
        List<String> fcCriteriaFieldList = new List<String>{'RLM_Field_Display_Name__c','RLM_Field_Name__c','RLM_Operator__c','RLM_Values__c','RLM_Date_Literal_String__c','RLM_Date_Value__c','RLM_Date_Literal_Number__c'};
        CSM_Util.checkCRUD_FLS('CSM_Focus_Category_View_Criteria__c', fcCriteriaFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcViewColFieldList = new List<String>{'CSM_Object_Field_Name__c','CSM_Display_Name__c','CSM_Object_Field_Type__c'};
        CSM_Util.checkCRUD_FLS('CSM_Focus_Category_View_Column__c', fcViewColFieldList, CSM_Constants.DML_OPERATION_READ);
        
        String soql = 'SELECT CSM_Columns__c,CSM_IsTile__c,CSM_Filter_By_Owner_Value__c, CSM_Is_Active__c,CSM_Criteria__c,CSM_Display_Name__c,CSM_Object_Name__c,'
                       + 'CSM_SOQL__c,Id,RLM_Currency_Code__c,RLM_Filter_Logic__c,CSM_Currency_Header__c,'
                       +'(SELECT RLM_Field_Display_Name__c, RLM_Field_Name__c, RLM_Operator__c, RLM_Values__c, RLM_Date_Literal_String__c, RLM_Date_Value__c, RLM_DateTime_Value__c, RLM_Date_Literal_Number__c ' 
                       + 'FROM CSMFocusCategoriesViewCriteria__r)'
                       +',(Select CSM_Object_Field_Name__c, CSM_Display_Name__c, CSM_Object_Field_Type__c from CSMFocusCategoryView__r)'
                       +' FROM CSM_Focus_Category_View__c WHERE CSM_Is_Active__c = true and CSM_IsTile__c = '+isTiles 
                       + ' AND CSM_Object_Name__c !=  '+ '\'' + CSM_Constants.OBJ_TYPE_TASK +'\'';  
        return soql;   	
    }
    
    public static List<CSM_Focus_Category_View__c> getFocusCategoryList(Set<Id> fcvIdSet) {
    	List<String> fcvFieldList = new List<String>{'CSM_IsTile__c','CSM_Is_Active__c','CSM_Display_Name__c','RLM_Is_Saved_Search__c'};
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FCV, fcvFieldList, CSM_Constants.DML_OPERATION_READ);
    	String queryString = '';
    	if(fcvIdSet != null) {
        	queryString = 'select id, CSM_Display_Name__c, CSM_IsTile__c from CSM_Focus_Category_View__c where id in :fcvIdSet and CSM_Object_Name__c != \'' + CSM_Constants.OBJ_TYPE_TASK + '\'' + ' and CSM_Is_Active__c = true and RLM_Is_Saved_Search__c != true order by LastModifiedDate DESC';
        }
        return Database.query(queryString);
    }
    
    //Get all Bulk Update Focus Categories
    public static List<CSM_Focus_Category_View__c> getAllBulkUpdateFocusCategories() 
    {
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_FCV_IS_SAVED_SEARCH};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        List<CSM_Focus_Category_View__c> tmpList = new List<CSM_Focus_Category_View__c>();
        if (noAccessList.isEmpty())
        {
        	string query = 'SELECT Id, CSM_Display_Name__c, CSM_IsTile__c, CSM_Is_Active__c, CSM_Object_Name__c,RLM_Related_Object_Name__c, CSM_Filter_By_Owner_Value__c, CSM_Currency_Header__c, RLM_Sort_Order__c,  lastModifiedBy.Name, FORMAT(lastModifiedDate) '
                      	   + 'FROM CSM_Focus_Category_View__c WHERE RLM_Is_Saved_Search__c = true AND CSM_Display_Name__c != null order by RLM_Sort_Order__c ASC LIMIT 2000';
                        
           	tmpList = database.query(query);
        }
        else {
        	String[] arguments = new String[] {CSM_Constants.OBJ_FCV + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            	System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        
        return tmpList; 
    }
}