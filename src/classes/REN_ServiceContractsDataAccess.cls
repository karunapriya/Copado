public with sharing class REN_ServiceContractsDataAccess{
    
  /***
    * @description Get Map with ServiceContract Id and Opportunity Id.
    * @Param: ServiceContract list
    * @Return: Id Map for ServiceContract Id and Opportunity Id.
    ***/
    public static Map<String, String> getServiceContractOpportunityMap(List<SObject> serviceContractList) {
        Map<String, String> serviceContractOpportunityMap = new Map<String, String>();
        if(serviceContractList !=null && !serviceContractList.isEmpty()) { 
            for(SObject sc:serviceContractList)
            {
               // VCP - ORG21 check
                if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID))
                {
                    if((Id)sc.get(REN_Constants.FLD_ID) != null && (Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID) != null)
                    {
                        serviceContractOpportunityMap.put((String)sc.get(REN_Constants.FLD_ID), (String)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID));
                    }
                }
            }
        }
        return serviceContractOpportunityMap;
    }
    
         
   /***
    * @description Get opportunity and service contract Id Map.
    * @Param: ServiceContract record list.
    * @Return:  Map<Id, Id> of opportunity and service contract Ids.
    ***/
     public static Map<String, String> getOpportunityServiceContractMap(List<SObject> serviceContractList) {
        Map<String, String> opportunityServiceContractMap = new Map<String, String>();
        if (!serviceContractList.isEmpty())
        {
            for (SObject sc:serviceContractList)
            {
               // VCP - ORG21 check
                if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID))
                {
                    if((Id)sc.get(REN_Constants.FLD_ID) != null && (Id)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID) != null)
                    {
                        opportunityServiceContractMap.put((String)sc.get(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID),(String)sc.get(REN_Constants.FLD_ID));
                    }
                }
            }
        }
        return opportunityServiceContractMap;
    }
    
   /***
    * @description Get Opportunity Service Contract list records
    * @Param: Map<Id, Id> of Service Contract and Opportunity Ids.
    * @Return: List<REN_Opportunity_Service_Contract__c> Opportunity Service Contract List 
    ***/
     public static List<SObject> getOpportunityServiceContractWithoutInsert(Map<String, String> serviceContractOpptyMap)
     {
        /*
        List<SObject> opportunityServiceContractList = new List<SObject>();
        if (serviceContractOpptyMap != null && !serviceContractOpptyMap.isEmpty())
        {
            for(String objId:serviceContractOpptyMap.keySet())
            {
                SObject opptyServiceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_T_REN_OPPORTUNITY_SERVICE_CONTRACT);
                opptyServiceContract.put(REN_Constants.OBJ_OP_OPPORTUNITY, (String)serviceContractOpptyMap.get(objId));
                // VCP - ORG21 check
                if(CSM_AccessController.hasField(REN_Constants.OBJ_T_REN_OPPORTUNITY_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT))
                {
                    opptyServiceContract.put(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, objId);
                }
                opportunityServiceContractList.add(opptyServiceContract);
            }
        }
        return opportunityServiceContractList;
        */
        return null;
     }
     
   /***
    * @description Filter Opportunity records without AccountId set.
    * @Param: Opportunity list to process.
    * @Return: filtered Opportunity list.
    ***/
    public static List<Opportunity> filterOpptyListWithoutAccount(List<Opportunity> opty2ProcessList) {
        List<Opportunity> filteredOpportunityList = new List<Opportunity>();
        for (Opportunity opty:opty2ProcessList) {
            if (opty.AccountId !=null) {
                filteredOpportunityList.add(opty);
            }
        }
        return filteredOpportunityList;
    }
    
    /***
    * @description get service contract list from service contract Id.
    * @Param: serviceContract Id Set.
    * @Return: serviceContract List.
    ***/
     public static List<SObject> getServiceContractsWithCLI (Set<ID> serviceContractIdSet){
     	List<SObject> serviceContractList = new List<SObject>();
     	List<String> serviceContractFieldList = new List<String>{REN_Constants.OBJ_SC_NAME};
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SERVICE_CONTRACT, serviceContractFieldList, CSM_Constants.DML_OPERATION_READ);
     	String queryString =  'SELECT id, (Select id from ContractLineItems limit 1) FROM ' + REN_Constants.OBJ_SERVICE_CONTRACT + ' WHERE Id IN :serviceContractIdSet LIMIT 10000';
        serviceContractList = Database.query(queryString);
        
        return serviceContractList;
     }
     public static List<SObject> getServiceContractList (List<String> serviceContractIdList)
     {
        Set<Id> serviceContractIds = new Set<Id>();
        for (String id : serviceContractIdList){
            serviceContractIds.add((Id)id);
        }
        return getServiceContractListForMerge(serviceContractIds);
     }
     
     
     
    public static List<SObject> getServiceContractListForMerge(Set<Id> serviceContractIdSet)
    {
        List<SObject> serviceContractList = new List<SObject>();
        List<String> serviceContractFieldList = new List<String>{REN_Constants.OBJ_SC_NAME, 
                                                                REN_Constants.OBJ_SC_OWNER_ID, 
                                                                REN_Constants.OBJ_SC_PRICEBOOK2_ID,
                                                                REN_Constants.OBJ_SC_ACCOUNT,
                                                                //REN_Constants.OBJ_SC_BILL_ADDR,
                                                                REN_Constants.OBJ_SC_CONTACT,
                                                                REN_Constants.OBJ_SC_CONTRACT_NO,
                                                                REN_Constants.OBJ_SC_DESC,
                                                                REN_Constants.OBJ_SC_DISC,
                                                                REN_Constants.OBJ_SC_END_DATE,
                                                                //REN_Constants.OBJ_SC_SHIP_ADDR,
                                                                REN_Constants.OBJ_SC_SHIP_HANDLING,
                                                                REN_Constants.OBJ_SC_SPECIAL_TERMS,
                                                                REN_Constants.OBJ_SC_START_DATE,
                                                                REN_Constants.OBJ_SC_STATUS,
                                                                REN_Constants.OBJ_SC_SUBTOTAL,
                                                                REN_Constants.OBJ_SC_TAX,
                                                                REN_Constants.OBJ_SC_TERM,
                                                                REN_Constants.OBJ_SC_TOTAL_PRICE};

        // VCP - ORG21 check                                                                
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_REN_OPPTID)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_REN_OPPTID);
        }
        // VCP - ORG21 check
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_SRC_OPPTID)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_SRC_OPPTID);
        }
        
        List<String> noAccessFieldList = new List<String>();
        if (!Test.IsRunningTest()){
            noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                                                                REN_Constants.OBJ_SERVICE_CONTRACT, 
                                                                                CSM_Constants.DML_OPERATION_READ, serviceContractFieldList);
        }
        //String soqlStr = CSM_Util.getCreatableFieldsSOQL(REN_Constants.OBJ_SERVICE_CONTRACT, 'Id IN :serviceContractIdSet');
        String soqlStr = joinList(getAccessibleFields(), ', ');
        if(UserInfo.isMultiCurrencyOrganization()){
        	if(!(soqlStr.containsIgnoreCase(CSM_CONSTANTS.CURRENCY_ISO_CD))){
        		soqlStr = soqlStr + ', ' + CSM_CONSTANTS.CURRENCY_ISO_CD;
        	}
        }
        if(CSM_AccessController.hasField('Opportunity',  'SyncedQuoteId') && CSM_AccessController.hasField('ServiceContract',  CSM_Util.nameSpacePrefix21+'REN_Renewal_Opportunity__c')){
        	soqlStr += ', ' + CSM_Util.nameSpacePrefix21+'REN_Renewal_Opportunity__r.SyncedQuoteId';
        }
        String queryString =  'SELECT ' + soqlStr + 
                                ' FROM ' + REN_Constants.OBJ_SERVICE_CONTRACT + 
                                ' WHERE Id IN :serviceContractIdSet LIMIT 10000';
        
        
        if(noAccessFieldList.isEmpty())
        {    
            //System.Debug('SCQuery' + soqlStr);
            serviceContractList = Database.query(queryString);
        }
        else
        {
            String[] arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':' + String.valueOf(noAccessFieldList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        
        return serviceContractList;
    }
    
    public static List<String> getAccessibleFields()
    {
        List<String> accessibleFields = new List<String>();
        
        Map<String, Schema.SobjectField> fields = CSM_AccessController.getFieldMap(REN_Constants.OBJ_SERVICE_CONTRACT);
        for(String field : fields.keySet())
        {
            DescribeFieldResult dfr = fields.get(field).getDescribe();
            if (dfr.isAccessible())
            {
                accessibleFields.add(field);
                if(dfr.getType().equals(Schema.DisplayType.Reference)){
                	List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                	if(!oTypeList.isEmpty()){
                		String refObjName = oTypeList[0].getDescribe().getName();
                		if(CSM_AccessController.hasField(refObjName, 'Name')){
                			accessibleFields.add(dfr.getRelationshipName() + '.Name');
                		}
                	}
                }

            }
        }
        return accessibleFields;
    }
     
     
    
    /***
    * @description get service contract list from service contract Id.
    * @Param: serviceContract Id Set.
    * @Return: serviceContract List.
    ***/
     public static List<SObject> getServiceContractList(Set<Id> serviceContractIdSet)
     {
        List<SObject> serviceContractList = new List<SObject>();
        List<String> serviceContractFieldList = new List<String>{REN_Constants.OBJ_SC_NAME, 
                                                                REN_Constants.OBJ_SC_OWNER_ID, 
                                                                REN_Constants.OBJ_SC_PRICEBOOK2_ID,
                                                                REN_Constants.OBJ_SC_ACCOUNT,
                                                                REN_Constants.OBJ_SC_BILL_ADDR,
                                                                REN_Constants.OBJ_SC_CONTACT,
                                                                REN_Constants.OBJ_SC_CONTRACT_NO,
                                                                REN_Constants.OBJ_SC_DESC,
                                                                REN_Constants.OBJ_SC_DISC,
                                                                REN_Constants.OBJ_SC_END_DATE,
                                                                REN_Constants.OBJ_SC_SHIP_ADDR,
                                                                REN_Constants.OBJ_SC_SHIP_HANDLING,
                                                                REN_Constants.OBJ_SC_SPECIAL_TERMS,
                                                                REN_Constants.OBJ_SC_START_DATE,
                                                                REN_Constants.OBJ_SC_STATUS,
                                                                REN_Constants.OBJ_SC_SUBTOTAL,
                                                                REN_Constants.OBJ_SC_TAX,
                                                                REN_Constants.OBJ_SC_TERM,
                                                                REN_Constants.OBJ_SC_TOTAL_PRICE};

        // VCP - ORG21 check                                                                
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_REN_OPPTID)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_REN_OPPTID);
        }
        // VCP - ORG21 check
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_SRC_OPPTID)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_SRC_OPPTID);
        }
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                                                                REN_Constants.OBJ_SERVICE_CONTRACT, 
                                                                                CSM_Constants.DML_OPERATION_READ, serviceContractFieldList);
        set<String> knownFields = new set<String>();
        knownFields.addAll(serviceContractFieldList);                                                                   
        String soqlStr = CSM_Util.getSOQLString(REN_Constants.OBJ_SERVICE_CONTRACT, knownFields, 'Id IN :serviceContractIdSet ', null, null);
        
        
        if(noAccessFieldList.isEmpty())
        {    
            //System.Debug('SCQuery' + soqlStr);
            serviceContractList = Database.query(soqlStr);
        }
        else
        {
            String[] arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':' + String.valueOf(noAccessFieldList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        
        return serviceContractList;
     }  

     public static void insertContractLineItems(List<SObject> contractLineItems)
     {
         List<String> contractlIneItemFieldList = new List<String>{REN_Constants.OBJ_SCLI_UNITPRICE, 
                                                                //REN_Constants.OBJ_SCLI_SERVICECONTRACTID, 
                                                                //REN_Constants.OBJ_SCLI_STATUS,
                                                                REN_Constants.OBJ_SCLI_QUANTITY,
                                                                REN_Constants.OBJ_SCLI_STARTDATE,
                                                                //REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,
                                                                // REN_Constants.OBJ_SCLI_LISTPRICE,
                                                                //REN_Constants.OBJ_SCLI_LINEITEMNUMBER,
                                                                REN_Constants.OBJ_SCLI_ENDDATE,
                                                                REN_Constants.OBJ_SCLI_DISCOUNT,
                                                                REN_Constants.OBJ_SCLI_DESCRIPTION,
                                                                REN_Constants.OBJ_SCLI_ASSETID};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                                                                REN_Constants.OBJ_CONTRACT_LINE_ITEM, 
                                                                                CSM_Constants.DML_OPERATION_INSERT, contractLineItemFieldList); 
        
        if(noAccessFieldList.isEmpty())
        {    
            insert contractLineItems;
        }
        else
        {
            String[] arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':' + String.valueOf(noAccessFieldList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, arguments));
        }
        
     }  

     public static void deleteServiceContracts(List<SObject> sContractList){
     	if(sContractList != null && !sContractList.isEmpty()){
	        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SERVICE_CONTRACT, null, CSM_Constants.DML_OPERATION_DELETE);
	        delete sContractList; 
     	}
     } 
     public static void deleteContractLineItems(List<SObject> contractLineItems)
     {
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM,null, CSM_Constants.DML_OPERATION_DELETE);
        delete contractLineItems; 
     } 

     public static List<SObject> getMergeContractLineItems(Set<String> serviceContractIdSet)
     {
        System.Debug('Setsize  - ' + serviceContractIdSet);
        List<SObject> contractLineItemList = new List<SObject>();
        List<String> contractlIneItemFieldList = new List<String>{REN_Constants.OBJ_SCLI_UNITPRICE, 
                                                                REN_Constants.OBJ_SCLI_SERVICECONTRACTID, 
                                                                REN_Constants.OBJ_SCLI_STATUS,
                                                                REN_Constants.OBJ_SCLI_QUANTITY,
                                                                REN_Constants.OBJ_SCLI_STARTDATE,
                                                                REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,
                                                                REN_Constants.OBJ_SCLI_LISTPRICE,
                                                                REN_Constants.OBJ_SCLI_LINEITEMNUMBER,
                                                                REN_Constants.OBJ_SCLI_ENDDATE,
                                                                REN_Constants.OBJ_SCLI_DISCOUNT,
                                                                REN_Constants.OBJ_SCLI_DESCRIPTION,
                                                                REN_Constants.OBJ_SCLI_ASSETID};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                                                                REN_Constants.OBJ_CONTRACT_LINE_ITEM, 
                                                                                CSM_Constants.DML_OPERATION_READ, contractLineItemFieldList);
        //String soqlStr = CSM_Util.getCreatableFieldsSOQL(REN_Constants.OBJ_SERVICE_CONTRACT, 'Id IN :serviceContractIdSet');
         
                                                                
        String soqlStr = 'SELECT ' + REN_Constants.OBJ_SCLI_UNITPRICE +','+ REN_Constants.OBJ_SCLI_SERVICECONTRACTID +','+ REN_Constants.OBJ_SCLI_STATUS +','+
                        REN_Constants.OBJ_SCLI_QUANTITY +','+REN_Constants.OBJ_SCLI_STARTDATE +','+REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID +','+
                        REN_Constants.OBJ_SCLI_LISTPRICE +','+REN_Constants.OBJ_SCLI_LINEITEMNUMBER +','+REN_Constants.OBJ_SCLI_ENDDATE +','+
                        REN_Constants.OBJ_SCLI_DISCOUNT +','+REN_Constants.OBJ_SCLI_DESCRIPTION +','+REN_Constants.OBJ_SCLI_ASSETID + 
                        ' FROM ' + REN_Constants.OBJ_CONTRACT_LINE_ITEM + ' WHERE ServiceContractId IN :serviceContractIdSet LIMIT 10000';
        
        if(noAccessFieldList.isEmpty())
        {    
            contractLineItemList = Database.query(soqlStr);
        }
        else
        {
            String[] arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':' + String.valueOf(noAccessFieldList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        return contractLineItemList;
     }  


    public static void getAccessibleFields(List<REN_MergeOppFieldWrapper> readOnlyFields, List<REN_MergeOppFieldWrapper> updateableFields)
    {
        Set<String> stdReadOnlyFields = new Set<String>{'subtotal', 'grandtotal', 'pricebook2id'};
        Set<String> notAllowedFields = new Set<String>{'Consolidated', 'Consolidated To'};
        Map<String, Schema.SobjectField> fields = CSM_AccessController.getFieldMap(REN_Constants.OBJ_SERVICE_CONTRACT);
        for(String field : fields.keySet())
        {
            DescribeFieldResult dfr = fields.get(field).getDescribe();
            if(!notAllowedFields.contains(dfr.getLabel()))
            {
                REN_MergeOppFieldWrapper wrapper = new REN_MergeOppFieldWrapper(dfr.getLabel(), dfr.getName(), dfr.isNillable(), 
                                                                        dfr.getType().name().toLowerCase(), dfr.getRelationshipName(), 
                                                                        field);
                if (!stdReadOnlyFields.contains(field) && dfr.isUpdateable())
                {
                    updateableFields.add(wrapper);
                }
                else if(!dfr.isCalculated() && dfr.isAccessible())
                {
                    readOnlyFields.add(wrapper);
                }
            }
        }
    } 
    
    public static void upsertServiceContractList(List<SObject> serviceContractList){
        List<String> serviceContractFieldList = new List<String>();
        // VCP - ORG21 check                                                                
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED);
        }
        // VCP - ORG21 check
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO);
        }                                           
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                REN_CONSTANTS.OBJ_SERVICECONTRACT,
                                CSM_Constants.DML_OPERATION_UPSERT, 
                                serviceContractFieldList);
        if(noAccessList.isEmpty())
        {
            upsert serviceContractList;         
        }
        else
        {
            String[] arguments = new String[] {CSM_CONSTANTS.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
                System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));  
        }
    }
    
    public static void insertServiceContractList(List<SObject> serviceContractList){
        List<String> serviceContractFieldList = new List<String>();
        // VCP - ORG21 check                                                                
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED);
        }
        // VCP - ORG21 check
        if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO)){
            serviceContractFieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO);
        }                                           
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                REN_CONSTANTS.OBJ_SERVICECONTRACT,
                                CSM_Constants.DML_OPERATION_INSERT, 
                                serviceContractFieldList);
        if(noAccessList.isEmpty())
        {
            insert serviceContractList;         
        }
        else
        {
            String[] arguments = new String[] {CSM_CONSTANTS.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
                System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));  
        }
    }
    
    private static String joinList(List<String> theList, String separator){
        if(theList == null)
        {
            return null; 
        }
        if(separator == null)
        {
            separator = ''; 
        }
        String joined = '';
        Boolean firstItem = true;
        for(String item : theList)
        {
            if(item != null && item.length()>0)
            {
                if(firstItem)
                {
                    firstItem = false;
                }
                else
                {
                    joined += separator;
                }
                
                joined += item;

            }
        }
        return joined;
    }
    
    public static List<SObject> getContractLineItemList(List<String> accountIds, String sortExpression, String sortDirection, String selectedCurr){
        List<SObject> contractLineItemList = new List<SObject>();
        List<String> contractlIneItemFieldList = new List<String>{REN_Constants.OBJ_SCLI_SERVICECONTRACTID, 
                                                                REN_Constants.OBJ_SCLI_STATUS,
                                                                REN_Constants.OBJ_SCLI_QUANTITY,
                                                                REN_Constants.OBJ_SCLI_STARTDATE,
                                                                REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,
                                                                REN_Constants.OBJ_SCLI_LINEITEMNUMBER,
                                                                REN_Constants.OBJ_SCLI_ENDDATE,
                                                                REN_Constants.OBJ_SCLI_DISCOUNT,
                                                                REN_Constants.OBJ_SCLI_DESCRIPTION,
                                                                REN_Constants.OBJ_SCLI_ASSETID};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                                                                REN_Constants.OBJ_CONTRACT_LINE_ITEM, 
                                                                                CSM_Constants.DML_OPERATION_READ, contractLineItemFieldList);
        Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_SERVICE_CONTRACT);
        //Eswar Bala - 04/15/2016 - Possible fix for "Visualforce Remoting Exception: Currency 000 is not supported by this org." DE1312. 
        							//Removing Format() for field "ServiceContract.TotalPrice".
        String soql = 'Select Id, ServiceContract.Name, ServiceContractId, format(Discount), '+
                        'ServiceContract.ContractNumber, LineItemNumber, PricebookEntry.Product2.Id, '+
                        'PricebookEntry.Product2.Name, Format(Quantity), ServiceContract.TotalPrice,ServiceContract.AccountId, ServiceContract.Account.Name,'+
                        'Status, Format(StartDate), Format(EndDate), ' + (UserInfo.isMultiCurrencyOrganization()?'convertCurrency(TotalPrice)':'format(TotalPrice)');
        if (CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c')){
            soql += ', (Select REN_Renews_To__c, REN_Renews_To__r.Name, REN_Renews_To__r.StageName, Format(REN_Renews_To__r.CloseDate) From '+
            			CSM_Util.nameSpacePrefix21 + 'Renewal_Relationship1__r LIMIT 1) ';
        }
        
        if(UserInfo.isMultiCurrencyOrganization())
        {
            soql += ', CurrencyIsoCode ';
        }
                    
        soql += ' From ContractLineItem Where ServiceContract.AccountId IN :accountIds LIMIT ' + limitVal;
        //system.debug('soql $$$$$$$ '+soql);
        if(noAccessFieldList.isEmpty()){    
            contractLineItemList = Database.query(soql);
	        /*if(UserInfo.isMultiCurrencyOrganization())
	        {
		        if(contractLineItemList != null)
		        {
		            for(SObject clItem: contractLineItemList){
		            	String strValue  = String.ValueOf(clItem.get('TotalPrice'));
		            	
		            	Double convertedVal = REN_Util.convertCurrencyValue(Double.ValueOf(strValue),UserInfo.getDefaultCurrency(),selectedCurr);
						clItem.put('TotalPrice',convertedVal);		            
		            }
		        }
	        }*/
            
        } else {
            String[] arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':' + String.valueOf(noAccessFieldList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        return contractLineItemList;
    }
    
    public static List<SObject> getContractLineItemListById(List<String> lstContractLineIds, Set<String> fieldSet){
        List<SObject> contractLineItemList = new List<SObject>();
        fieldSet.addAll( new List<String>{REN_Constants.FLD_ID,
        														REN_Constants.OBJ_SCLI_SERVICECONTRACTID, 
                                                                REN_Constants.OBJ_SCLI_STATUS,
                                                                REN_Constants.OBJ_SCLI_QUANTITY,
                                                                REN_Constants.OBJ_SCLI_STARTDATE,
                                                                REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,
                                                                REN_Constants.OBJ_SCLI_LINEITEMNUMBER,
                                                                REN_Constants.OBJ_SCLI_ENDDATE,
                                                                REN_Constants.OBJ_SCLI_DISCOUNT,
                                                                REN_Constants.OBJ_SCLI_DESCRIPTION,
                                                                REN_Constants.OBJ_SCLI_ASSETID});
        
        List<String> contractlIneItemFieldList = new List<String>();
        contractlIneItemFieldList.addAll(fieldSet);
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM, contractlIneItemFieldList, CSM_Constants.DML_OPERATION_READ);
        
        Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_SERVICE_CONTRACT);

        String soql = 'Select ServiceContract.Name, ServiceContract.ContractNumber, ServiceContract.TotalPrice, PricebookEntry.Product2.Id, PricebookEntry.Product2.Name, PricebookEntry.Product2Id, ' 
        + (String.join(contractlIneItemFieldList, ', ')) + ' From ContractLineItem Where Id IN :lstContractLineIds LIMIT ' + limitVal;
        system.debug('newsoql - ' + soql);
        contractLineItemList = Database.query(soql);
        return contractLineItemList;
    }
    
    public static List<SObject> getContractLineItemListForClause(String whereClause, String selectedCurr)
    {
        List<SObject> contractLineItemList = new List<SObject>();
        List<String> contractlIneItemFieldList = new List<String>{REN_Constants.OBJ_SCLI_SERVICECONTRACTID, 
                                                                REN_Constants.OBJ_SCLI_STATUS,
                                                                REN_Constants.OBJ_SCLI_QUANTITY,
                                                                REN_Constants.OBJ_SCLI_STARTDATE,
                                                                REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,
                                                                REN_Constants.OBJ_SCLI_LINEITEMNUMBER,
                                                                REN_Constants.OBJ_SCLI_ENDDATE,
                                                                REN_Constants.OBJ_SCLI_DISCOUNT,
                                                                REN_Constants.OBJ_SCLI_DESCRIPTION,
                                                                REN_Constants.OBJ_SCLI_ASSETID};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                                                                REN_Constants.OBJ_CONTRACT_LINE_ITEM, 
                                                                                CSM_Constants.DML_OPERATION_READ, contractLineItemFieldList);
        Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_SERVICE_CONTRACT);
        //Eswar Bala - 04/15/2016 - Possible fix for "Visualforce Remoting Exception: Currency 000 is not supported by this org." DE1312. 
        							//Removing Format() for field "ServiceContract.TotalPrice".
        String soql = 'Select Id, ServiceContract.Name, ServiceContractId, format(Discount),'+
                        'ServiceContract.ContractNumber, LineItemNumber, PricebookEntry.Product2.Id, '+
                        'PricebookEntry.Product2.Name, Format(Quantity), ServiceContract.TotalPrice,ServiceContract.AccountId, ServiceContract.Account.Name,'+
                        'Status, Format(StartDate), Format(EndDate), ' + (UserInfo.isMultiCurrencyOrganization()?'convertCurrency(TotalPrice),':'format(TotalPrice),')+
                        (UserInfo.isMultiCurrencyOrganization()?'convertCurrency(UnitPrice)':'format(UnitPrice)');
        if (CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c')){
        	soql += ', (Select REN_Renews_To__c, REN_Renews_To__r.Name, REN_Renews_To__r.StageName, Format(REN_Renews_To__r.CloseDate) From '+
            		CSM_Util.nameSpacePrefix21 + 'Renewal_Relationship1__r LIMIT 1) ';
        }
        
        if(UserInfo.isMultiCurrencyOrganization()) {
            soql += ', CurrencyIsoCode ';
        }
                    
        soql += ' From ContractLineItem ' + whereClause  + ' LIMIT ' + limitVal;
        system.debug('soql $$$$$$$ '+soql);
        if(noAccessFieldList.isEmpty()){    
            contractLineItemList = Database.query(soql);
	        /*if(UserInfo.isMultiCurrencyOrganization())
	        {
		        if(contractLineItemList != null)
		        {
		            for(SObject clItem: contractLineItemList){
		            	String strValue  = String.ValueOf(clItem.get('TotalPrice'));
		            	Double convertedVal = REN_Util.convertCurrencyValue(Double.ValueOf(strValue),UserInfo.getDefaultCurrency(),selectedCurr);
						clItem.put('TotalPrice',convertedVal);		            
		            }
		        }
	        }*/
            
        } else {
            String[] arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':' + String.valueOf(noAccessFieldList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        return contractLineItemList;
    }
    
    public static List<sObject> getAccountByServiceContractID(Set<String> scIDs){
        List<String> contractlIneItemFieldList = new List<String>{REN_Constants.OBJ_SCLI_SERVICECONTRACTID};
        String soql = 'SELECT AccountId FROM ServiceContract where id in :scIDs LIMIT 1';
        List<SObject> contractLineItemList =  Database.query(soql);
        return contractLineItemList;
    }
    
    public static void updateServiceContracts(List<sObject> serviceContracts, List<String> scFieldList)
    {
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SERVICE_CONTRACT, scFieldList, CSM_Constants.DML_OPERATION_UPDATE);
        update serviceContracts;
    }
}