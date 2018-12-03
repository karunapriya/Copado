public with sharing class REN_OpportunityLineItemDataAccess
{
    public static set<String> knownFields = new set<String>{REN_Constants.OBJ_OLI_SERVICEDATA, REN_Constants.OBJ_OLI_UNITPRICE,'Name','CreatedById', 'Product2.Name', 'PricebookEntryId', 
                                                            REN_Constants.OBJ_OLI_QUANTITY, 'OpportunityId', 'REN_Source_Opportunity_Line_Item_Id__c', 
                                                            'REN_Start_Date__c', 'REN_End_Date__c', 'Description','TotalPrice','Discount','Subtotal',
                                                            'REN_Is_CLM_Renewal__c', 'REN_Covered_Asset__c', 'REN_Covered_Product__c', 'REN_Source_Opportunity__c', 'REN_Previous_Opportunity__c', 'REN_Renewable_Line_Item__c'};
    public static List<OpportunityLineItem> insertOpportunityLineItem(List<OpportunityLineItem> opportunityLineItemList)
    {
        
        List<String> oliFieldList = new List<String>{REN_Constants.OBJ_OLI_UNITPRICE, 
                                                    //REN_Constants.OBJ_OLI_SORTORDER,
                                                    REN_Constants.OBJ_OLI_SERVICEDATA,
                                                    REN_Constants.OBJ_OLI_QUANTITY,
                                                    //REN_Constants.OBJ_OLI_PRODUCTCODE,
                                                    REN_Constants.OBJ_OPPLN_FLD_CVD_ASSET,
                                                    //REN_Constants.OBJ_OLI_TOTAL_PRICE,
                                                    REN_Constants.OBJ_OLI_PREV_OPP,
                                                    //REN_Constants.OBJ_OLI_ORIG_LI_ID,
                                                    REN_Constants.OBJ_OLI_SOURCE_OPP,
                                                    REN_Constants.OBJ_OLI_SOURCE_OPLI_ID,
                                                    'ren_is_end_date_modified__c'};   
                                                    
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, oliFieldList, CSM_Constants.DML_OPERATION_INSERT);                                                
        insert opportunityLineItemList;   
        return opportunityLineItemList; 
    }
    
    public static List<Database.SaveResult> insertOppLineItem(List<OpportunityLineItem> opportunityLineItemList){
        List<Database.SaveResult> queryResultList = null;
        if(!opportunityLineItemList.isEmpty()){
            List<String> oliFieldList = new List<String>{REN_Constants.OBJ_OLI_UNITPRICE,  //REN_Constants.OBJ_OLI_SORTORDER, 
                    REN_Constants.OBJ_OLI_SERVICEDATA, REN_Constants.OBJ_OLI_QUANTITY};   
            CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, oliFieldList, CSM_Constants.DML_OPERATION_INSERT);                                                
            queryResultList = Database.insert(opportunityLineItemList , false);
        }
        return queryResultList;
    }
    
    
    public static List<OpportunityLineItem> getOpportunityLineItemList(Set<String> optyIdSet)
    {
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, 'OpportunityId IN :optyIdSet', null, null);
        system.debug('soqlStr : ' + soqlStr);
        oliList = Database.query(soqlStr);
        return oliList;  
    }
    
   
	//Added for US3337 
	public static List<OpportunityLineItem> getOpportunityLineItemListByRLIRelationship(Set<Id> rliIdSet)
    {
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, 'REN_Renewable_Line_Item__c IN :rliIdSet', null, null);
        system.debug('soqlStr : ' + soqlStr);
        oliList = Database.query(soqlStr);
        return oliList;  
    }

	//Added for DE3360 
	public static List<OpportunityLineItem> getOliByRliId(Set<Id> rliIdSet){
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, null, 'REN_Renewable_Line_Item__c IN :rliIdSet', new Set<String>{'anytype'}, null);
        system.debug('soqlStr : ' + soqlStr);
        oliList = Database.query(soqlStr);
        return oliList;  
    }

    public static List<OpportunityLineItem> getOpportunityLineItems(Set<String> optyLineItemIdSet){
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, knownFields, ' id IN :optyLineItemIdSet', null, null);
        system.debug('soqlStr : ' + soqlStr);
        oliList = Database.query(soqlStr);
        return oliList;  
    }
    
    public static List<OpportunityLineItem> getOpptyLineItems(Set<ID> optyLineItemIdSet, Set<String> selectedFields){
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, selectedFields, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, selectedFields, ' id IN :optyLineItemIdSet', null, null);
        system.debug('soqlStr : ' + soqlStr);
        oliList = Database.query(soqlStr);
        return oliList;  
    }

    public static List<OpportunityLineItem> getOpportunityLineItemsByOppId(Set<String> optyIdSet){
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, null, ' OpportunityId IN :optyIdSet' , new Set<String>{'anytype'}, null);
        return Database.query(soqlStr);
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItemsById(Set<ID> oliIdSet){
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, null, ' Id IN :oliIdSet' , new Set<String>{'anytype'}, null);
        return Database.query(soqlStr);
    }
    
    //Added for US392
    public static List<OpportunityLineItem> updateOpportunityLineItem(List<OpportunityLineItem> opportunityLineItemList){
        List<String> oliFieldList = new List<String>{REN_Constants.OBJ_OLI_UNITPRICE, 
                                                    //REN_Constants.OBJ_OLI_SORTORDER,
                                                    REN_Constants.OBJ_OLI_SERVICEDATA,
                                                    REN_Constants.OBJ_OLI_QUANTITY,
                                                    //REN_Constants.OBJ_OLI_PRODUCTCODE,
                                                    REN_Constants.OBJ_OPPLN_FLD_CVD_PRD,
                                                    REN_Constants.OBJ_OPPLN_FLD_CVD_ASSET,
                                                    REN_Constants.OBJ_OPP_FLD_IS_CLM_RENEWAL,
                                                    'ren_is_end_date_modified__c'
                                                    //REN_Constants.OBJ_OLI_TOTAL_PRICE
                                                    };   
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, oliFieldList, CSM_Constants.DML_OPERATION_UPDATE);                                                
        update opportunityLineItemList;   
        return opportunityLineItemList; 
    }
    
    public static List<OpportunityLineItem> updateOpportunityLineItem(List<OpportunityLineItem> opportunityLineItemList, Set<String> fieldsForCrudFls){
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, fieldsForCrudFls, CSM_Constants.DML_OPERATION_UPDATE);                                                
        update opportunityLineItemList;   
        return opportunityLineItemList; 
    }
    
    
    public static List<OpportunityLineItem> getOpportunityLineItemsByOppIdWithlineItemId(Id optyId, set<Id> setOptyLineItemId, Set<String> fieldsSet){
        String condition = 'OpportunityId = :optyId ';
        if(setOptyLineItemId != null && !setOptyLineItemId.isEmpty()){
            condition += ' AND Id IN :setOptyLineItemId';
        }
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, fieldsSet, condition, new Set<String>{'anytype'}, null);
        return Database.query(soqlStr);
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItemsByOppIds(Set<Id> optyIdSet, Set<String> fieldsSet, Integer recLimit){
        String condition = 'OpportunityId In :optyIdSet';
        CSM_Util.checkCRUD_FlsPermissions(REN_Constants.OBJ_OPPTY_LINE_ITEM, fieldsSet, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, fieldsSet, condition, new Set<String>{'anytype'}, null);
        soqlStr += ' limit :recLimit';
        system.debug('\n\n~~~~ soqlStr:' + soqlStr);
        return Database.query(soqlStr);
    }
    
    public static List<OpportunityLineItem> getOpportunityProducts(String opptyId, Set<Id> oliSet){
        List<OpportunityLineItem> opportunityProductList = new List<OpportunityLineItem>();
        
        List<String> fieldList = new List<String>{'Name','OpportunityId', 'Product2Id'};

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, fieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'Select id, Name, OpportunityId, Product2Id,Product2.Name from OpportunityLineItem';

        if(opptyId != null){
        	queryString +=  (CSM_Util.getSDMFlag()) ? ' WHERE OpportunityId = :opptyId ' :' WHERE OpportunityId = :opptyId and id IN:oliSet ';
        }
        system.debug('\n\n~~~~ queryString:' + queryString);
        opportunityProductList = Database.query(queryString);
        return opportunityProductList;
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItemList(Set<String> oliFldstoQuery, Set<String> oppIdSet){
        List<String> oliFldList = new List<String>(oliFldstoQuery);
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, oliFldList, CSM_Constants.DML_OPERATION_READ);
        String oliQuery = 'Select '+String.join(oliFldList, ',')+ ' From OpportunityLineItem '+
                          'Where opportunityId in :oppIdSet limit 1000 ';
        oliList = Database.query(oliQuery);
        return oliList;
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItemList(Set<String> oliFldstoQuery, Set<Id> oppIdSet, String whereClause){
        List<String> oliFldList = new List<String>(oliFldstoQuery);
        List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, oliFldList, CSM_Constants.DML_OPERATION_READ);
        String oliQuery = 'Select '+String.join(oliFldList, ',')+ ' From OpportunityLineItem '+
                          'Where opportunityId in :oppIdSet';
        if(String.isNotBlank(whereClause)){
            oliQuery = oliQuery + ' And ' + whereClause;
        }
        oliQuery += ' Limit 5000';
        system.debug('~~~~ queryString: ' + oliQuery);
        oliList = Database.query(oliQuery);
        return oliList;  
    }
    
    public static void deleteOpportunityLineItems(List<OpportunityLineItem> opportunityLineItemList){
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, null, CSM_Constants.DML_OPERATION_DELETE);
        delete opportunityLineItemList;
    } 
    
    public static List<sObject> getFilteredRecords(String fromObject, Set<String> queryFields, Set<Id> idSet, String whereCondition, Set<String> fieldTypes){
        if(idSet == null || idSet.isEmpty()){
            return null;
        }
        if(String.isBlank(whereCondition)){
            whereCondition = '';
        }else{
            whereCondition = '( ' + whereCondition + ' ) AND ';
        }
        whereCondition += ' OpportunityId IN :idSet ';
        
        if(fieldTypes == null || fieldTypes.isEmpty()){
            fieldTypes = new Set<String>();
        }
        fieldTypes.add('anytype');
        Set<String> requestedProperties = new Set<String>{'isCalculated'};
        String soqlStr = CSM_Util.getSOQLString(fromObject, queryFields, whereCondition, fieldTypes, requestedProperties);
        system.debug(idSet+ '\n\n~~~~soqlStr: ' + soqlStr);
        List<sObject> resultList = Database.query(soqlStr);
        return resultList; 
    }
    public static List<Database.SaveResult> insertOpportunityLineItem(List<SObject> opportunityLineItemList){
        try {
        List<Database.SaveResult> queryResultList = null;
        if(!opportunityLineItemList.isEmpty()){
            List<String> oliFieldList = new List<String>{REN_Constants.OBJ_OLI_UNITPRICE, 
                    REN_Constants.OBJ_OLI_SERVICEDATA, REN_Constants.OBJ_OLI_QUANTITY
                    };   
            CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, oliFieldList, CSM_Constants.DML_OPERATION_INSERT);                                                
            queryResultList = Database.insert(opportunityLineItemList , false);
        }
        return queryResultList;
        } catch(Exception ex) {
            return null;
        }
    }
    public static List<SObject> getOpptyLineItemsById(Set<Id> optyLineItemIdSet, Set<String> queryFields){
        List<SObject> oliList; 
        String nameSpace = CSM_Util.getNamespace();
        Set<String> fieldSet = new Set<String>();
        if(queryFields != null && !queryFields.isEmpty()){
        	String fieldName = '';
        	for(String queryField : queryFields) {
        		if(queryField.startsWith(nameSpace)) {
        			fieldName = queryField.removeStart(nameSpace);
        		} else {
        			fieldName = queryField;
        		}
        		fieldSet.add(fieldName.toLowerCase());
        	}
        }
        if(knownFields != null && !knownFields.isEmpty()) {
        	for(String fieldNm : knownFields) {
        		fieldSet.add(fieldNm.toLowerCase());
        	}
        }
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_OPPTY_LINE_ITEM, fieldSet, ' id IN :optyLineItemIdSet', null, null);
        system.debug('soqlStr : ' + soqlStr);
        oliList = Database.query(soqlStr);
        return oliList;  
    }
    
    public static List<SObject> getDataUsingFieldSet(List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet,String filterStr) {   
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = fld.getFieldPath().removeEndIgnoreCase('Id').replace('__c', '__r') + (fld.getFieldPath().contains('REN_Contract_Line_Item__c') ? '.LineItemNumber':'.Name' ); //****
                if(!refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            
            if(!refrenceFieldSet.contains(fld.getFieldPath())){                  
                if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
                    fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
                    if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
                        queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
                    } else {
                        queryString += ', format(' + fld.getFieldPath() + ')';
                    }
                }
                else {   
                    queryString += ', ' + fld.getFieldPath();
                }
            } 
            system.debug('***'+fld);
            if(!fld.getFieldPath().contains('.')){
                fsFieldSet.add(fldStr);
            }
            refrenceFieldSet.add(fldStr);
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
            queryString += ', CurrencyIsoCode';
            fsFieldSet.add('CurrencyIsoCode'); 
        }
        if(additionalFieldSet != null){
            for(String s : additionalFieldSet){
                if(!refrenceFieldSet.contains(s)){
                    fsFieldSet.add(s);
                    queryString += ','+ s;  
                }
            }
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPTY_LINE_ITEM, fsFieldList, CSM_Constants.DML_OPERATION_READ);
        queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   ' + REN_Constants.OBJ_OPPTY_LINE_ITEM + ' WHERE id != null ' + (String.isBlank(filterStr) ? '':(' AND (' + filterStr + ' )'));
        
        system.debug(fieldSetMemberList + '\n\n queryString in oopt split oli --- :: ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
    
    public static List<AggregateResult> getAggregateTotalPriceOnOli(Set<ID> opptIdsSet){
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY_LINE_ITEM, new List<String>{'REN_Total_Price_formula__c','REN_Is_CLM_Renewal__c'}, CSM_Constants.DML_OPERATION_READ); 
	    String queryString = 'SELECT OpportunityId,Sum(REN_Total_Price_formula__c) totalPrice FROM OpportunityLineItem WHERE OpportunityId IN:opptIdsSet AND Opportunity.REN_Is_CLM_Renewal__c = true AND REN_Is_CLM_Renewal__c = false group By OpportunityId';             
        List<AggregateResult> results = Database.query(queryString);
        return results;
    }
    
    public static List<OpportunityLineItem> getOpportunityProductsOFWonOpp(Set<Id> oliIdSet){
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'stageName'}, CSM_Constants.DML_OPERATION_READ);
    	return [SELECT Id, Opportunity.stageName FROM OpportunityLineItem WHERE Id IN :oliIdSet and Opportunity.stageName = 'Closed Sale'];
    }
    
    /* Created for DE3072 : DO Not Add/Remove any fields from this SOQL, this SOQL is explictly created to resolve view state error on Add new PO Screen.
    */
    public static list<OpportunityLineItem> getOLIByOpportunity(set<String> opptyID){
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY_LINE_ITEM, new List<String>{'REN_Renewable_Line_Item__c', 'UnitPrice','REN_Start_Date__c','REN_End_Date__c','Quantity','REN_Is_CLM_Renewal__c'}, CSM_Constants.DML_OPERATION_READ);
    	return [select Id, REN_Renewable_Line_Item__c, UnitPrice , ListPrice, OpportunityId, REN_End_Date__c, REN_Start_Date__c, Product2Id,Quantity, REN_Is_CLM_Renewal__c, PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId IN:opptyID limit 10000] ;
    }
    
    
    public static List<OpportunityLineItem> getOpportunityLineItemsDetails(Set<String> oppIdSet, List<String> oppFieldSet,set<String> queryStringSet){
    	String  queryString = (new List<String>(queryStringSet))[0];
		CSM_Util.checkCRUD_FLS('OpportunityLineItem', oppFieldSet, CSM_Constants.DML_OPERATION_READ);
		return Database.query(queryString);
	}
    
}