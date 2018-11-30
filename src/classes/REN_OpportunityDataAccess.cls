public with sharing class REN_OpportunityDataAccess
{
	 public static List<sObject> getFilteredRecords(String fromObject, Set<String> knownFields, Set<Id> idSet, String whereCondition, Set<String> fieldTypes){
	 if(fieldTypes == null || fieldTypes.isEmpty()){
            fieldTypes = new Set<String>();
	 }
	 fieldTypes.add('anytype');
	 Set<String> requestedProperties = new Set<String>{'isCalculated'};
	 List<sObject> resultList= getFilteredRecordsList(fromObject,knownFields,idSet,whereCondition,fieldTypes,requestedProperties);
	 return resultList; 
	 }
   
    public static List<sObject> getFilteredRecordsList(String fromObject, Set<String> knownFields, Set<Id> idSet, String whereCondition, Set<String> fieldTypes,set<String> requestedProperties){
        if(idSet == null || idSet.isEmpty()){
            return null;
        }
        if(String.isBlank(whereCondition)){
            whereCondition = '';
        }else{
            whereCondition = '( ' + whereCondition + ' ) AND ';
        }
        whereCondition += ' id IN :idSet ';
        
       	if(fromObject.equalsIgnoreCase(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
        	knownFields.add('PricebookEntry.Product2Id');
		}
        
        String soqlStr = CSM_Util.getSOQLString(fromObject, knownFields, whereCondition, fieldTypes, requestedProperties);
        system.debug(idSet+ '\n\n~~~~soqlStr: ' + soqlStr);
        List<sObject> resultList = Database.query(soqlStr);
        return resultList; 
    }
/*    
    public static List<AggregateResult> getCountOfOLI(Set<ID> opptIds){       
        List<AggregateResult> countOfOLI=[SELECT OpportunityId,count(Id) FROM OpportunityLineItem where 
                                   OpportunityId IN :opptIds group by OpportunityId];
        return countOfOLI;
    }
    public static List<AggregateResult> getCountOfRLI(Set<ID> opptIds){       
        List<AggregateResult> countOfRLI=[SELECT ren_renews_to__c,count(Id) FROM ren_renews_to__c where 
                                   ren_renews_to__c IN :opptIds group by ren_renews_to__c];
        return countOfRLI;
    }   
*/    
    public static List<Opportunity> getOpportunityWithRRnLI(Set<ID> opptIds){
        return getOpportunityWithRRnLI(opptIds, null);
    }
        
    public static List<Opportunity> getOpportunityWithRRnLI(Set<ID> opptIds, String filterString){
        
        List<String> opportunityFieldList = new List<String>{
            REN_Constants.OBJ_OPP_CONSOLIDATED, 
            REN_Constants.OBJ_OPP_APPEND_OPPTY,
            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
            REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER
        };
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);
        String initialPartQuery = 'Select id, Name, StageName,Pricebook2Id, Amount, REN_Is_CLM_Renewal__c,' +  
            '(SELECT id, name, REN_Source_Opportunity__c, REN_Previous_Opportunity__c, TotalPrice, REN_Is_CLM_Renewal__c, ServiceDate, UnitPrice, Product2.Name , PricebookEntryId , quantity, OpportunityId , REN_Source_Opportunity_Line_Item_Id__c , REN_Start_Date__c , REN_End_Date__c , Description , REN_Covered_Asset__c , REN_Covered_Product__c,REN_Renewable_Line_Item__c   FROM OpportunityLineItems),' + 
            '(SELECT id, Name, REN_Renews_To__c, REN_Source_Opportunity__c, REN_Previous_Opportunity__c, REN_Renewal_Target__c, REN_Previous_Price__c, REN_Renewal_Target_Multiplier__c, REN_Product__c, REN_Asset__c,  ' + 
                    'REN_Start_Date__c, REN_End_Date__c, REN_Renewal_Status__c, REN_Quantity__c';
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
        String intermediatePartQuery = '';
        if(isSolutionExtnInstalled){
            intermediatePartQuery += ', ' + solnExtnNamespace + 'Previous_Local_Currency_Code__c' + ', ' + solnExtnNamespace + 'Previous_Local_Currency_Amount__c';
        }
        intermediatePartQuery += ' FROM Renew_To__r) ';
        String finalPartquery = ' FROM Opportunity where ID in :opptIds' + (String.isNotBlank(filterString) ? ' AND (' +  filterString + ') ' : '');
        String finalQuery = initialPartQuery + intermediatePartQuery + finalPartquery;
       
        List<Opportunity> resultList = Database.query(finalQuery);
        return resultList;    
    }
    
     /** @return List<Opportunity> where Opportunity will have only Maseter OLI and / or max one RLI 
	*/
    public static List<Opportunity> getOpptyWithMasterProduct(Set<ID> opptIds){
        List<Opportunity> resultList = getOpptyListToProcesss(opptIds, null);
        return resultList; 
    }
    
    public static List<Opportunity> getOpptyListToProcesss(Set<ID> opptIds, String filterString){
         List<String> opportunityFieldList = new List<String>{
            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
			REN_Constants.OBJ_OPP_AMOUNT,
			REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
			REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE
        };
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);      
        SS_License__c ssLicenseCS = SS_License__c.getOrgDefaults();					
		String initialPartQuery = 'Select id, Name, StageName, Pricebook2Id, REN_Renewal_Target__c, REN_Earliest_Expiration_Date__c,REN_Is_CLM_Renewal__c, REN_EQ__c, REN_FY__c ';
        if (UserInfo.isMultiCurrencyOrganization()){
            initialPartQuery+= ',' + 'CurrencyIsoCode';
        }
        if(SS_Constants.isSimplifiedDataModelEnabled){
        	String masterProductId;
	        initialPartQuery+= ', ' + '(SELECT id, name,REN_Is_CLM_Renewal__c FROM OpportunityLineItems WHERE ';
			
			if( String.isNotBlank(ssLicenseCS.Renewal_Amount_Product_Id__c) ){
				masterProductId = ssLicenseCS.Renewal_Amount_Product_Id__c;    
				initialPartQuery += ' Product2Id = :masterProductId AND ';
			}
	        initialPartQuery += ' REN_Is_CLM_Renewal__c = true), (SELECT id, Name FROM Renew_To__r LIMIT 1)';
        }
        String finalPartquery = ' FROM Opportunity where ID in :opptIds' + (String.isNotBlank(filterString) ? ' AND (' +  filterString + ') ' : '');
       	String finalQuery = initialPartQuery + finalPartquery;
        
        system.debug('finalQuery IN getOpportunityWithRR'+finalQuery);

        List<Opportunity> resultList = Database.query(finalQuery);
        system.debug('resultList-->'+resultList);
        return resultList;    
    }
    
    //Need to delete this method
    /*
    public static List<OpportunityLineItem> fetchOpptLinesByOppts(Set<String> opptIds){
        return fetchOpptLinesByOppts(opptIds, new Set<String>{'id'});
    }
    */
    public static List<OpportunityLineItem> fetchOpptLinesByOppts(Set<String> opptIds, Set<String> fieldSet)
    {
        Schema.SObjectType objectOpptLine = new OpportunityLineItem().getSobjectType();
        //Map<String, Schema.SobjectField> opptLineAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectOpptLine);
        List<OpportunityLineItem> tmpOpptLine = null;
        List<String> opportunityLineFieldList = new List<String>();
        //String queryString = 'SELECT Id, Name, ProductCode, Product2Id ';
        if(fieldSet == null || fieldSet.isEmpty()){
            opportunityLineFieldList = new List<String>{'id'};
        }else{
            opportunityLineFieldList = new List<String>(fieldSet);
        }
        String queryString = 'SELECT ' + (String.join(opportunityLineFieldList, ', '));

        system.debug('opportunityLineFieldList : ' + opportunityLineFieldList);
        if (UserInfo.isMultiCurrencyOrganization()){
            queryString += ', Opportunity.CurrencyIsoCode '; 
        }
        queryString += ' FROM ' + CSM_Constants.OBJ_OPPORTUNITY_LINE_ITEM + ' WHERE OpportunityId IN :opptIds limit 10000'; 
        system.debug('OLI queryString : ' + queryString);
        system.debug('opptIds : ' + opptIds);
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY_LINE_ITEM, opportunityLineFieldList, CSM_Constants.DML_OPERATION_READ);
        
        tmpOpptLine = Database.query(queryString); 
        system.debug('tmpOpptLine : ' + tmpOpptLine);
        
        return tmpOpptLine;
    }
    //Depricated: Due to US2726
    public static List<Opportunity> getOpportunityDetailById(List<String> opptIds)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_Constants.OBJ_OPP_CONSOLIDATED, 
                                                            //Lumesse fields reference removal 
                                                            //REN_Constants.OBJ_OPP_ORIGINATOR,
                                                            //REN_Constants.OBJ_OPP_PARENT,
                                                            REN_Constants.OBJ_OPP_APPEND_OPPTY,
                                                            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
                                                            REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER
                                                            };
        boolean firstField = true;

        String nameSpace = CSM_Util.getNamespace();
        String soqlStr = joinList(getAccessibleFields(), ', ', nameSpace);
        system.debug('soqlStr --- ' + soqlStr);
        String queryString =  'SELECT ' + soqlStr + 
                                ' FROM Opportunity' + 
                                ' WHERE Id IN:opptIds Order By Name';
               
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
            
        tmplist = Database.query(queryString);
    
        return tmplist;
    }
    
    
    public static List<Opportunity> getOpportunityAllDetailsById(List<String> opptIds){
	
		String soqlStr = joinList(getAccessibleFields(false), ', ', CSM_Util.getNamespace());
        String queryString =  'SELECT ' + soqlStr + ' FROM Opportunity WHERE Id IN:opptIds Order By Name';
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'id'}, CSM_Constants.DML_OPERATION_READ);
        return Database.query(queryString);
	}
	
	public static List<Opportunity> getOpportunityDetailByIdWithSyncQuote(List<String> opptIds)	{
		return getOpportunityDetailByIdWithSyncQuote(opptIds,true);
	}
	// This method is created to handle ReadOnly issue for syncedquoteid and SyncedQuote.Name in trigger context
	public static List<Opportunity> getOpportunityDetailByIdWithSyncQuote(List<String> opptIds,  Boolean isCallFromTrigger)	{
		List<String> allAccessibleFieldsList = getAccessibleFields(false);
		if(isCallFromTrigger) {
			Set<String> accessibleFieldsSet =  new Set<String>();
			accessibleFieldsSet.addAll(allAccessibleFieldsList);		  	
			accessibleFieldsSet.remove(CHL_Constants.OBJ_OPP_SYNCE_QUOTE_ID); // To remove syncedquoteid and SyncedQuote.Name field from opp accessible field List
			accessibleFieldsSet.remove(CHL_Constants.OBJ_OPP_SYNCE_QUOTE_NAME);	  	
			allAccessibleFieldsList.clear();
			allAccessibleFieldsList.addAll(accessibleFieldsSet);
		}
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_OPPORTUNITY, new List<String>{'Name'}, CSM_Constants.DML_OPERATION_READ); 
		String soqlStr = REN_OpportunityDataAccess.joinList(allAccessibleFieldsList, ', ',CSM_Util.getNamespace());	  		    
   		String queryString =  'SELECT ' + soqlStr + 
                                ' FROM Opportunity' + 
                                ' WHERE Id IN:opptIds Order By Name';
		return Database.query(queryString);
	}
	
    /*public static List<Opportunity> getOpportunityDetailByIdForDocuSign(List<String> opptIds)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_Constants.OBJ_OPP_CONSOLIDATED, 
                                                            //Lumesse fields reference removal 
                                                            //REN_Constants.OBJ_OPP_ORIGINATOR,
                                                            //REN_Constants.OBJ_OPP_PARENT,
                                                            REN_Constants.OBJ_OPP_APPEND_OPPTY,
                                                            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
                                                            REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER
                                                            };
        boolean firstField = true;

        String nameSpace = CSM_Util.getNamespace();
        String soqlStr = joinList(getAccessibleFields(), ', ', nameSpace);
        system.debug('soqlStr --- ' + soqlStr);
        String strS = soqlStr.replace('syncedquoteid, SyncedQuote.Name,','');
        system.debug('strS --- ' + strS);
        String queryString =  'SELECT ' + strS + 
                                ' FROM Opportunity' + 
                                ' WHERE Id IN:opptIds Order By Name';
               
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
            
        tmplist = Database.query(queryString);
    
        return tmplist;
    }*/
    
    public static List<Opportunity> getRenewedOpportunity(Set<String> opptIds){
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_Constants.OBJ_OPP_CONSOLIDATED, 
                                                            REN_Constants.OBJ_OPP_APPEND_OPPTY,
                                                            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
                                                            REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER
                                                            };
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);
        return [SELECT id, REN_Renewal_Target__c,(Select PricebookEntry.Product2Id,UnitPrice, Quantity, TotalPrice, REN_Is_CLM_Renewal__c from OpportunityLineItems ) FROM Opportunity WHERE Id IN:opptIds AND REN_Is_CLM_Renewal__c = true];
    }
    
    public static List<String> getAccessibleFields(){
    	return getAccessibleFields(true);
    }
    
    public static List<String> getAccessibleFields(boolean isReferenceRecNameRequired){
        List<String> accessibleFields = new List<String>();
        Map<String, Schema.SobjectField> fields = Opportunity.getSObjectType().getDescribe().fields.getMap();
        for(String field : fields.keySet())
        {
            DescribeFieldResult dfr = fields.get(field).getDescribe();
            if(dfr.isAccessible())
            {
                accessibleFields.add(field);
                if(dfr.getType().equals(Schema.DisplayType.Reference)){
                    List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                    if(!oTypeList.isEmpty()){
                        String refObjName = oTypeList[0].getDescribe().getName();
                        if(isReferenceRecNameRequired && CSM_AccessController.hasField(refObjName, 'Name')){
                            accessibleFields.add(dfr.getRelationshipName() + '.Name');
                        }
                    }
                }
            }
        }
        return accessibleFields;
    }
    
    //Commented getAccessibleFields method - US3293
/*    
    public static void getAccessibleFields(List<REN_MergeOppFieldWrapper> readOnlyFields, List<REN_MergeOppFieldWrapper> updateableFields)
    {
        String currentNamespace = CSM_Util.getNamespace();
        Set<String> stdReadOnlyFields = new Set<String>{'amount', 'totalopportunityquantity', 'pricebook2id'};
        Set<String> notAllowedFields = new Set<String>{'Consolidated', 'Consolidated To'};
        set<String> calculatedFieldsSet = new Set<String>{currentNamespace + REN_Constants.OBJ_OPP_EARLIEST_EXPIRATION_DATE, currentNamespace + REN_Constants.OBJ_OPP_LOSS_RATE, 
                                                            currentNamespace + 'REN_DIA_Contacted__c', currentNamespace + 'REN_DIA_Closed__c', 
                                                            currentNamespace + 'REN_DIA_Quoted__c', currentNamespace + 'REN_AddsAmount__c', currentNamespace +'REN_Renewal_Target_Lost__c', 
                                                            currentNamespace + 'REN_Renewal_Target_Resolved__c', currentNamespace + 'REN_Renewal_Target_Unresolved__c', 
                                                            currentNamespace + 'REN_Renewal_Target_Won__c', currentNamespace +'REN_Resolution_Date__c',
                                                            currentNamespace + 'REN_EQ__c', currentNamespace +'REN_Expiration_Quarter_Year__c', currentNamespace + 'REN_FY__c', 
                                                            currentNamespace + 'REN_First_Contact_Date__c', currentNamespace +'REN_First_Quote_Date__c',
                                                            currentNamespace + 'REN_Renewal_Target__c', currentNamespace +'REN_Days_Until_Expiration__c', currentNamespace +'REN_AddsRatio_formula__c', 
                                                            currentNamespace + 'REN_Conversion_Delta_Amount__c'};
        Map<String, Schema.SobjectField> fields = Opportunity.getSObjectType().getDescribe().fields.getMap();
        for(String field : fields.keySet())
        {
            DescribeFieldResult dfr = fields.get(field).getDescribe();
            if(!notAllowedFields.contains(dfr.getLabel()))
            {
                REN_MergeOppFieldWrapper wrapper = new REN_MergeOppFieldWrapper(dfr.getLabel(), dfr.getName(),dfr.isNillable(),dfr.getType().name().toLowerCase(), dfr.getRelationshipName(), field);
                if (!stdReadOnlyFields.contains(field) && dfr.isUpdateable())
                {
                    if(calculatedFieldsSet.contains(dfr.getName()))
                    {
                        readOnlyFields.add(wrapper);
                    }
                    else
                    {
                        updateableFields.add(wrapper);
                    }
                }
                else if(!dfr.isCalculated() && dfr.isAccessible())
                {
                    readOnlyFields.add(wrapper);
                }
            }
        }
    }
*/    
    public static String joinList(List<String> theList, String separator, String namespace)
    {
        if(theList == null)
        {
            return null; 
        }
        if(separator == null)
        {
            separator = ''; 
        }
        namespace = String.isBlank(namespace)?'':namespace;
        String joined = '';
        Boolean firstItem = true;
        System.debug('namespace - '+ namespace);
        for(String item : theList)
        {
            //system.debug('ZZZ item - '+item);
            //system.debug('namespace - '+ namespace.indexOf(item));
            //Eswar Bala - 05-05-2015 - Issues caused by assuming the fields are part of the package.
            Boolean isPartOfSSPackage = namespace.indexOf(item) != -1?true:false;
            item = item.replace(namespace, '');
            //system.debug('ZZZ item - '+item);
            if(item != null && item.length() > 0)
            {
                if(firstItem)
                {
                    firstItem = false;
                }
                else
                {
                    joined += separator;
                }
                
                if(item.contains('__c') && isPartOfSSPackage)   //Eswar Bala - 05-05-2015 - Issues caused by assuming the fields are part of the package.
                {
                    joined += namespace + item;
                }
                else
                {
                    joined += item;
                }
            }
        }
        return joined;
    }
   
   
    public static void updateOpportunityforRenewals(List<Opportunity> opptyToUpdatelst){
        List<String> opptyFieldList = new List<String>{REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
        	REN_Constants.OBJ_SC_IS_CONSOLIDATED,REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER,
        	REN_Constants.FLD_ID, REN_Constants.OBJ_OPP_OWNER_ID,
        	REN_Constants.OBJ_OPP_CLOSE_DATE};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList,CSM_Constants.DML_OPERATION_UPDATE);
         if(!opptyToUpdatelst.isEmpty()){        
                update opptyToUpdatelst;
         }
         
    }
    
    public static List<Database.SaveResult> updateOpportunityReturnSaveResult(List<Opportunity> oppList){
        List<Database.SaveResult> queryResultList = null;
        if(!oppList.isEmpty()){
            List<String> opptyFieldList = new List<String>{REN_Constants.OBJ_OPP_PROBABILITY};
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList,CSM_Constants.DML_OPERATION_UPDATE);
            queryResultList = Database.update(oppList , false);
        }
        return queryResultList;
    }
    
    public static List<Opportunity> insertOpportunity(List<Opportunity> opptyToCreateList){
        List<String> opptyFieldList = new List<String>{REN_Constants.OBJ_OPP_PROBABILITY,REN_Constants.OBJ_OPP_ISCLM_RENEWAL,REN_Constants.OBJ_OPP_PRICEBOOK_ID};
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList,CSM_Constants.DML_OPERATION_INSERT);
            if(!opptyToCreateList.isEmpty()){
                insert opptyToCreateList;
            }
        return opptyToCreateList; 
    }

    public static List<Database.SaveResult> insertOpportunityReturnSaveResult(List<Opportunity> oppListToCreate){
        List<Database.SaveResult> queryResultList = null;
        if(!oppListToCreate.isEmpty()){
            List<String> opptyFieldList = new List<String>{REN_Constants.OBJ_OPP_PROBABILITY};
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList,CSM_Constants.DML_OPERATION_INSERT);
            queryResultList = Database.insert(oppListToCreate , false);
        }
        return queryResultList;
    }
    
    public static List<Database.DeleteResult> deleteOpportunity(List<Opportunity> oppListToDelete){
        List<Database.DeleteResult> queryResultList = null;
        if(!oppListToDelete.isEmpty()){
            List<String> opptyFieldList = new List<String>{REN_Constants.OBJ_OPP_PROBABILITY};
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList,CSM_Constants.DML_OPERATION_DELETE);
            queryResultList = Database.delete(oppListToDelete , false);
        }
        return queryResultList;
    }
    public static void deleteAllOpportunities(List<Opportunity> oppListToDelete){
        if(oppListToDelete != null && !oppListToDelete.isEmpty()){
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, null,CSM_Constants.DML_OPERATION_DELETE);
            delete oppListToDelete;
        }
    }
    
    public static Opportunity getOpportunityById(String opptyID, set<String> requestedFields){
        List<Opportunity> oppList=getOpportunityById(new set<string>{opptyID},requestedFields,null);
        if(oppList != null && !oppList.isEmpty()){
            return oppList[0];
        }
        return null;
    }

     public static list<Opportunity> getOpportunityById(set<String> opptyID, set<String> requestedFields,set<string> refFields){
        List<String> opptyFieldList =  new List<String>();
        opptyFieldList.addAll(requestedFields);
        opptyFieldList.add(REN_Constants.OBJ_OPP_ISCLM_RENEWAL);
        //isMultiCurrency
        if(UserInfo.isMultiCurrencyOrganization())
        {
            opptyFieldList.add(REN_Constants.REN_CURRENCY_ISO_CODE);    
        }
        if (CSM_Util.getRecordTypeExists(new Opportunity()))
        {
            opptyFieldList.add(REN_Constants.RECORD_TYPE_ID);
        }  
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList, CSM_Constants.DML_OPERATION_READ);
        if(refFields != null){
        	opptyFieldList.addAll(refFields);
        }       
        String soqlStr = CSM_Util.getSOQLString('Opportunity', new Set<String>(opptyFieldList), 'id IN:opptyID', null, null);
        system.debug(opptyID + '\n----soqlStr : ' + soqlStr);
        List<Opportunity> oppList = Database.query(soqlStr);
        if(oppList != null && !oppList.isEmpty()){
            return oppList;
        }
        return null; 
    }
    
    //Adding to support Nitin's changes
    //Eswar: observation - method lacking field permissions checks
    public static List<Opportunity> getOpportunityByAcctIdAndName(String acctId, String name){
        List<String> opptyFieldList =  new List<String>{REN_Constants.OBJ_OPP_ACCOUNT, 
                                                        'OwnerId',
                                                        REN_Constants.FLD_NAME, REN_Constants.FLD_ID
                                                       };
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList, CSM_Constants.DML_OPERATION_READ);
        
        String soqlStr = 'Select Id, Name, AccountId, Account.Name, OwnerId, Owner.name from Opportunity where AccountId =: acctId and OwnerId =:name LIMIT 1';
        List<Opportunity> oppList = Database.query(soqlStr);
        if(oppList != null && !oppList.isEmpty()){
            return oppList;
        }
        return null; 
    }
    
    public static Set<String> getFieldsByFieldSet(String fieldSetName)
    {
        String nameSpace = CSM_Util.getNamespace();
        List<Schema.FieldSetMember> lstFieldMembers;
        if(fieldSetName == 'Opportunity Split Edit')
        {
            lstFieldMembers = SObjectType.Opportunity.FieldSets.REN_Opportunity_Split_Edit.getFields();
        }
        else if(fieldSetName == 'Opportunity Read Only')
        {
            lstFieldMembers = SObjectType.Opportunity.FieldSets.REN_Opportunity_Split_ReadOnly.getFields();
        }

        Set<String> setFields = new Set<String>();
        
        for(Schema.FieldSetMember fld :lstFieldMembers)
        {
            String fldStr = fld.getFieldPath();
            if (nameSpace != null && nameSpace.length() > 0)
            {
                fldStr = fldStr.replace(nameSpace, '');
            }
            setFields.add(fldStr);
        }
        return setFields;
    }
    
    private class CSM_PeriodInfo {
        
        public String fiscalYear {get; set;}
        public Date startDateVal {get; set;}
        public Date endDateVal {get; set;}
        public Integer quarterNumber {get; set;}
        public Date fyStartDateVal {get; set;}
        public Date fyEndDateVal {get; set;}
    } 
    
    /* author : PES 
     * date : 15-05-2015
     * description : As per user story US415. This method accepts date as parameter and 
     * returns quarter and year for that date(depending on the custom or standard fiscal 
     * year the organization is following).
     */
    public static list<integer> updateExpQuarterYear(date currentDate)
    {       
        list<integer> lstQuaYear = new list<integer>();
        integer currentFY ;
        Integer quarter;
        if(CSM_AccessController.hasObject(REN_Constants.OBJ_PERIOD))
        {
            if(currentDate != null) 
            {
                String periodQry = 'select Number, FiscalYearSettings.Name from Period  where Type = \'Quarter\' and StartDate <=: currentDate and EndDate >=: currentDate limit 1';
                list<SObject> lstFiscalPeriod = Database.query(periodQry);     
                System.debug('lstFiscalPeriod - '+lstFiscalPeriod);       
                if(lstFiscalPeriod!=null && !lstFiscalPeriod.isEmpty()){
                    String fy = (String)lstFiscalPeriod[0].getSObject('FiscalYearSettings').get('Name');
                    if (fy != null){
                        currentFY = Integer.valueOf(fy);
                    }
                    quarter = (Integer)lstFiscalPeriod[0].get('Number');
                }
                else {
                    //Eswar Bala: Below query changed to sObject but is not used.
                    //periodQry = 'select f.Name from Period p, p.FiscalYearSettings f where Type = \'Quarter\' limit 1';
                    //list<SObject> lstFiscalPeriodPlain = Database.query(periodQry);
                    if(lstFiscalPeriod==null || lstFiscalPeriod.isEmpty())
                    {                
                        list<Organization> lstOrgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id=:Userinfo.getOrganizationId()];           
                        if(currentDate.month() >= lstOrgInfo[0].FiscalYearStartMonth)
                        {
                            quarter = ((currentDate.month() - lstOrgInfo[0].FiscalYearStartMonth) / 3) + 1;                    
                            if (lstOrgInfo[0].UsesStartDateAsFiscalYearName) 
                            {
                                currentFY = currentDate.year();
                            } 
                            else 
                            {
                                currentFY = currentDate.year() + 1;
                            }
                        }
                        else
                        {
                            quarter = ((12 + currentDate.month() - lstOrgInfo[0].FiscalYearStartMonth) / 3) + 1;                
                            if (lstOrgInfo[0].UsesStartDateAsFiscalYearName) 
                            {
                                currentFY = currentDate.year() - 1;
                            }
                            else 
                            {
                                currentFY = currentDate.year();
                            }                    
                        }                                
                    }
                }
            }
        }
        lstQuaYear.add(quarter);
        lstQuaYear.add(currentFY);
        return lstQuaYear;
    }
       
    private static Set<Integer> calcualteYearSet(List<sObject> changedRecordLst,String dateColumnApiName){
       Set<Integer> yearSet = new Set<Integer>();
	    for(sObject sObj :changedRecordLst) {
	        if (sObj.get(dateColumnApiName)!=null){
	            yearSet.add(((Date)sObj.get(dateColumnApiName)).year()-1);
	            yearSet.add(((Date)sObj.get(dateColumnApiName)).year());
	            yearSet.add(((Date)sObj.get(dateColumnApiName)).year()+1);
	        } 
	    }
	    return yearSet;
  	}             
  	
    public static void calculateExpQuarterYear(List<sObject> changedRecordLst, String dateColumnApiName) {
	    Set<Integer> yearSet = new Set<Integer>();
	    yearSet = calcualteYearSet(changedRecordLst,dateColumnApiName);
	    // NO need to check for FLS as these objects are accessible to all the users
	   	//organization orgInfo = [select FiscalYearStartMonth, UsesStartDateAsFiscalYearName from Organization where id=:Userinfo.getOrganizationId()];
	    // NO need to check for FLS as these objects are accessible to all the users
	    calculateExpQuarterYear(changedRecordLst,yearSet,dateColumnApiName);
	}            
    
    private static void calculateExpQuarterYear(List<sObject> changedRecordLst, Set<Integer> yearSet, String dateColumnApiName) {
    	if(!CSM_AccessController.hasObject(REN_Constants.OBJ_PERIOD)){ 
	        return;
	    }
	    organization orgInfo = [select FiscalYearStartMonth, UsesStartDateAsFiscalYearName from Organization where id=:Userinfo.getOrganizationId()]; 
    	String periodSoqlQuarter = 'SELECT Number, FiscalYearSettings.IsStandardYear, FiscalYearSettings.Name, StartDate, EndDate from Period '+
	                                'WHERE Type = \'Quarter\' AND '+ 
	                                '(CALENDAR_YEAR(EndDate) IN :yearSet OR CALENDAR_YEAR(StartDate) IN :yearSet)';
	                                
	    List<SObject> periodList = Database.query(periodSoqlQuarter);
	    
	    // NO need to check for FLS as these objects are accessible to all the users (Eswar Bala: Except Portal users)
	    String periodSoqlYear = 'SELECT Number, FiscalYearSettings.IsStandardYear, FiscalYearSettings.Name, StartDate, EndDate from Period '+
	                                'WHERE Type = \'Year\' AND '+ 
	                                '(CALENDAR_YEAR(EndDate) IN :yearSet OR CALENDAR_YEAR(EndDate) IN :yearSet)';
	    List<SObject> yearList = Database.query(periodSoqlYear);
	    String clmNamespace = CSM_Util.getNameSpace();  
	    
	    for(sObject sObj :changedRecordLst) {
	        String currentFY = null;
	        Integer quarter = null;
	        if(sObj.get(dateColumnApiName)!=null){
	        	if(periodList != null && !periodList.isEmpty()){
			        for(SObject p : periodList){
			        	if ((Date)sObj.get(dateColumnApiName) >= (Date)p.get('StartDate') && 
			                		(Date)p.get('EndDate') >= (Date)sObj.get(dateColumnApiName)){
				        	for(SObject yr : yearList) {               		            	
				            	if ((Date)p.get('StartDate') >= (Date)yr.get('startDate') && (Date)p.get('EndDate') <= (Date)yr.get('endDate')) {
				                    currentFY = (String)yr.getSObject('FiscalYearSettings').get('Name');
				                    break;
				                } 
				            }				           
			                quarter = (Integer)p.get('Number');
			                break;				            
			        	}
			        }
	  			} else {
	                if(((Date)sObj.get(dateColumnApiName)).month() >= orgInfo.FiscalYearStartMonth) {
	                    quarter = ((((Date)sObj.get(dateColumnApiName)).month() - orgInfo.FiscalYearStartMonth) / 3) + 1;                    
	                      if (orgInfo.UsesStartDateAsFiscalYearName)  {                                  
	                          currentFY = String.valueOf(((Date)sObj.get(dateColumnApiName)).year());
	                      } 
	                      else {
	                          currentFY = String.valueOf(((Date)sObj.get(dateColumnApiName)).year() + 1);
	                      }
	                }
	                else {
	                    quarter = ((12 + ((Date)sObj.get(dateColumnApiName)).month() - orgInfo.FiscalYearStartMonth) / 3) + 1;                
	                    if (orgInfo.UsesStartDateAsFiscalYearName) {
	                        currentFY = String.valueOf(((Date)sObj.get(dateColumnApiName)).year() - 1);
	                    }
	                    else {
	                        currentFY = String.valueOf(((Date)sObj.get(dateColumnApiName)).year());
	                    }                                
	                }
	            }
	        }
	             //Added for US1082   
	      if(changedRecordLst.get(0) instanceof CHL_Partner_Opportunity__c ){
	            sObj.put(clmNamespace+'CHL_EQ__c',quarter);
	            sObj.put(clmNamespace+'CHL_FY__c',currentFY);
	        } else {
	            sObj.put(clmNamespace+'REN_EQ__c',quarter);
	            sObj.put(clmNamespace+'REN_FY__c',currentFY);
	        }
	    }
    }
    /* author : PES 
     * date : 28-04-2015
     * description : As per user story US415. This method accepts list of opportunities as parameter and 
     * returns quarter and year for each opportunity's earliest expiration date(depending on the custom 
     * or standard fiscal year the organization is following).
     */
    public static void updateExpQuarterYear(list<Opportunity> lstOpp, Map<ID, Opportunity> oldRecordsMap)
    {
        if(CSM_AccessController.hasObject(REN_Constants.OBJ_PERIOD))
        {   
        	String dateColumnApiName = CSM_Util.getNameSpace()+'REN_Earliest_Expiration_Date__c';
        	Set<Integer> yearSet = new Set<Integer>();
            List<Opportunity> opptyToProcess = new List<Opportunity>();
            for(Opportunity opp: lstOpp){
                
                if (oldRecordsMap != null) {
                    if (opp.REN_Earliest_Expiration_Date__c!=oldRecordsMap.get(opp.Id).REN_Earliest_Expiration_Date__c) {
                        opptyToProcess.add(opp);
                        yearSet.add(((Date)opp.get(dateColumnApiName)).year()-1);
	            		yearSet.add(((Date)opp.get(dateColumnApiName)).year());
	            		yearSet.add(((Date)opp.get(dateColumnApiName)).year()+1);
                    }
                } else {
                    if (opp.REN_Earliest_Expiration_Date__c!=null)  {
                        opptyToProcess.add(opp);
                        yearSet.add(((Date)opp.get(dateColumnApiName)).year()-1);
	            		yearSet.add(((Date)opp.get(dateColumnApiName)).year());
	            		yearSet.add(((Date)opp.get(dateColumnApiName)).year()+1);
                    }else{
                    	opp.REN_EQ__c = null;
                    	opp.REN_FY__c = null;
                    }
                }
            }
            if (!opptyToProcess.isEmpty() && !yearSet.isEmpty()){
                calculateExpQuarterYear(opptyToProcess, yearSet, CSM_Util.getNameSpace()+'REN_Earliest_Expiration_Date__c');
            }
        }
    }
    
    public static List<Opportunity> checkPricebookAndCurrencyMatchForOppAndSC(Set<String> opptIds)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> noAccessFieldListSC = new List<String>();        
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID, 
                                                            CSM_CONSTANTS.OBJ_O_NAME,
                                                            CSM_CONSTANTS.CURRENCY_ISO_CD
                                                            };


        if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
            //opportunityFieldList.add(REN_CONSTANTS.OBJ_OPP_APPEND_SC_Pricebook2Id);   
            opportunityFieldList.add(CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC);
            List<String> serviceContractFieldList = new List<String>{CSM_CONSTANTS.CURRENCY_ISO_CD,
                                                                        REN_Constants.OBJ_SC_PRICEBOOK2_ID
                                                                    };
            noAccessFieldListSC = CSM_AccessController.getInstance(
                                                                            ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_SERVICE_CONTRACT, 
                                                                            CSM_Constants.DML_OPERATION_READ, serviceContractFieldList);
        }
                                                            
        String nameSpace = CSM_Util.getNamespace();
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                                                                            ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_OPPORTUNITY, 
                                                                            CSM_Constants.DML_OPERATION_READ, opportunityFieldList);

        if(noAccessFieldList.isEmpty() && noAccessFieldListSC.isEmpty() && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT))
        {    
            string soql = 'Select ' + CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC + ','  + CSM_CONSTANTS.OBJ_O_NAME + ',' + CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SC_CURRENCY + ',' + CSM_CONSTANTS.CURRENCY_ISO_CD  + ',' + CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC_Pricebook2Id  + ','  + REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID + ' From Opportunity where Id IN :opptIds';
            tmplist = Database.query(soql);
        }
        else
        {
             String[] arguments;
             if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
                arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessFieldList) + ' ' + REN_Constants.OBJ_SERVICE_CONTRACT + ':'+String.valueOf(noAccessFieldListSC)};             
             } else {
                arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':'+String.valueOf(noAccessFieldListSC)};             
             }

             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
    
        return tmplist;
    }


    public static List<Opportunity> checkPricebookMatchForOppAndSC(Set<String> opptIds)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> noAccessFieldListSC = new List<String>();        
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID, 
                                                            CSM_CONSTANTS.OBJ_O_NAME
                                                            };


        if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
            //opportunityFieldList.add(REN_CONSTANTS.OBJ_OPP_APPEND_SC_Pricebook2Id);   
            opportunityFieldList.add(CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC);
            List<String> serviceContractFieldList = new List<String>{
                                                                        REN_Constants.OBJ_SC_PRICEBOOK2_ID
                                                                    };
            noAccessFieldListSC = CSM_AccessController.getInstance(
                                                                            ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_SERVICE_CONTRACT, 
                                                                            CSM_Constants.DML_OPERATION_READ, serviceContractFieldList);
        }
                                                            
        String nameSpace = CSM_Util.getNamespace();
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                                                                            ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_OPPORTUNITY, 
                                                                            CSM_Constants.DML_OPERATION_READ, opportunityFieldList);

        if(noAccessFieldList.isEmpty() && noAccessFieldListSC.isEmpty() && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT))
        {    
            string soql = 'Select ' + CSM_Util.nameSpacePrefix21 + REN_CONSTANTS.OBJ_OPP_APPEND_SC + ','  + CSM_CONSTANTS.OBJ_O_NAME + ',' + CSM_Util.nameSpacePrefix21 +REN_CONSTANTS.OBJ_OPP_APPEND_SC_Pricebook2Id  + ',' 
             + REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID + ' From Opportunity where Id IN :opptIds';
            tmplist = Database.query(soql);
        }
        else
        {
             String[] arguments;
             if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
                arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessFieldList) + ' ' + REN_Constants.OBJ_SERVICE_CONTRACT + ':'+String.valueOf(noAccessFieldListSC)};             
             } else {
                arguments = new String[] {REN_Constants.OBJ_SERVICE_CONTRACT + ':'+String.valueOf(noAccessFieldListSC)};             
             }

             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
    
        return tmplist;
    }



    
    public static List<Opportunity> getPricebookAndCurrencyForOppandAppendOpp(Set<String> opptIds)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID, CSM_CONSTANTS.OBJ_O_NAME};

        String nameSpace = CSM_Util.getNamespace();
        
         
        string soql = 'Select REN_Append_Renewal_Opportunity__r.Name, ' + CSM_CONSTANTS.OBJ_O_NAME  + ',' + CSM_Util.getNamespace() + REN_CONSTANTS.OBJ_OPP_APPEND_OPP_Pricebook2Id + ','  + REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID ;
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId')){
        	soql += ',SyncedQuoteId, REN_Append_Renewal_Opportunity__r.SyncedQuoteId';
        }
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_CONSTANTS.CURRENCY_ISO_CD)){
        	opportunityFieldList.add(CSM_CONSTANTS.CURRENCY_ISO_CD);
        	soql += ', ' + CSM_CONSTANTS.CURRENCY_ISO_CD + ', ' + REN_CONSTANTS.OBJ_OPP_APPEND_OPP_CURRENCY ;
        }
        soql += ' From Opportunity where Id IN :opptIds';
		System.debug(opportunityFieldList+ '\n\n~~~~soql: ' + soql);
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        tmplist = Database.query(soql);
        
        return tmplist;
    }

    public static List<Opportunity> getPricebookForOppandAppendOpp(Set<String> opptIds)
    {
        return getPricebookAndCurrencyForOppandAppendOpp(opptIds);
    }
    
    public static List<Opportunity> getBatchOpptyRecords(String batchId)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_ACCOUNT, 
                                                            REN_Constants.FLD_NAME,
                                                            REN_Constants.OBJ_OPP_AMOUNT,
                                                            REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
                                                            REN_Constants.OBJ_OPP_CLOSE_DATE,
                                                            REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE
                                                            };

        String nameSpace = CSM_Util.getNamespace();
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
          
        string soql = 'Select ' + REN_CONSTANTS.OBJ_OPP_ACCOUNT + ',' 
                                + CSM_Util.getNamespace() + REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE + ','  
                                + REN_Constants.FLD_NAME + ','
                                + REN_Constants.OBJ_OPP_AMOUNT + ','
                                + REN_Constants.OBJ_RC_OPPORTUNITY_STAGE + ','
                                + REN_Constants.OBJ_OPP_CLOSE_DATE + ','
                                + REN_Constants.REN_ACCOUNT_NAME+ ','
                                + REN_Constants.REN_ACCOUNT_ID
                                + ' From Opportunity where REN_Batch_Activity_ID__c = \'' + batchId + '\''+ 'ORDER BY Amount DESC';
        tmplist = Database.query(soql);
        
        return tmplist;
    }
    public static List<Opportunity> getBatchOpptyRecordsBusinessLayer(String batchId)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_ACCOUNT, 
                                                            REN_Constants.FLD_NAME,
                                                            REN_Constants.OBJ_OPP_AMOUNT,
                                                            REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
                                                            REN_Constants.OBJ_OPP_NEW_CLOSE_DATE,
                                                            REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE
                                                            };

        String nameSpace = CSM_Util.getNamespace();
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
       
        string soql = 'Select ' + REN_CONSTANTS.OBJ_OPP_ACCOUNT + ',' 
                                + 'FORMAT ( '+CSM_Util.getNamespace() + REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE + ') ,'  
                                + REN_Constants.FLD_NAME + ','
                                + (UserInfo.isMultiCurrencyOrganization()?'FORMAT ( '+ REN_Constants.OBJ_OPP_AMOUNT + '),':'FORMAT ( '+ REN_Constants.OBJ_OPP_AMOUNT + '),')
                                + REN_Constants.OBJ_RC_OPPORTUNITY_STAGE + ','
                                + 'FORMAT ( '+ REN_Constants.OBJ_OPP_NEW_CLOSE_DATE + '),'
                                + REN_Constants.REN_ACCOUNT_NAME+ ','
                                + REN_Constants.REN_ACCOUNT_ID
                                + ' From Opportunity where REN_Batch_Activity_ID__c = \'' + batchId + '\''+ 'ORDER BY Amount DESC';
        tmplist = Database.query(soql);
        
        return tmplist;
    }
    
    public static OpportunityStage getProbabilityValueByStage(String stageName)
    {
        OpportunityStage tmpVal = new OpportunityStage();
        List<OpportunityStage> tmpList = new List<OpportunityStage>();
        List<String> fieldList = new List<String>{REN_CONSTANTS.OBJ_OPPSTAGE_PROB, REN_CONSTANTS.OBJ_OPPSTAGE_MASTERLABEL};
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPSTAGE, fieldList, CSM_Constants.DML_OPERATION_READ);
           
        tmpList = [select DefaultProbability From OpportunityStage where MasterLabel = :stageName];
        if(tmpList != null && !tmpList.isEmpty()){
            tmpVal = tmpList[0];
        }
        return tmpVal;
    }
    
    public static list<opportunity> getRenewalOppListForChartData(){
        Boolean checkMCEnabled = CSM_Util.checkMCEnabled();
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_ACCOUNT, 
                                                            REN_Constants.FLD_NAME,
                                                            REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
                                                            REN_Constants.OBJ_OPP_CLOSE_DATE,
                                                            REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE,
                                                            REN_CONSTANTS.OBJ_OPP_FY,
                                                            REN_CONSTANTS.OBJ_OPP_EXPIRATION_QUARTER_YEAR,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET_RESOLVED,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET_LOST,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET_WON
                                                            };
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        String soql = 'select ';
        
        if (checkMCEnabled) {
            soql +=' currencyIsoCode, ';
        }
        soql +='closeDate, Account.BillingCountry, REN_Expiration_Quarter_Year__c, owner.Name,REN_EQ__c,REN_FY__c, ';
        String renewalSOQL = soql+'REN_Renewal_Target__c, REN_Renewal_Target_Resolved__c,  REN_Renewal_Target_Lost__c,REN_Renewal_Target_Won__c';
        //Lumesse fields reference removal 
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_OPP_CONVERSION_DELTA)){
            renewalSOQL += ' ,REN_Conversion_Delta_Amount__c';
        }
        renewalSOQL += ' from opportunity where REN_Is_CLM_Renewal__c = true AND REN_Earliest_Expiration_Date__c != null';
        return database.query(renewalSOQL);
   
    }
    
    public static list<opportunity> getCloseWonOppListForChartData(String queryStageName){
        Boolean checkMCEnabled = CSM_Util.checkMCEnabled();
        List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_ACCOUNT, 
                                                            REN_Constants.FLD_NAME,
                                                            REN_Constants.OBJ_OPP_AMOUNT,
                                                            REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
                                                            REN_Constants.OBJ_OPP_CLOSE_DATE,
                                                            REN_CONSTANTS.OBJ_OPP_EARLIEST_EXPIRATION_DATE,
                                                            REN_CONSTANTS.OBJ_OPP_FY,
                                                            REN_CONSTANTS.OBJ_OPP_EXPIRATION_QUARTER_YEAR,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET_RESOLVED,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET_LOST,
                                                            REN_CONSTANTS.OBJ_OPP_RENEWAL_TARGET_WON
                                                            };
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        String soql = 'select ';
        
        if (checkMCEnabled) {
            soql +=' currencyIsoCode, ';
        }
        soql +='closeDate, Account.BillingCountry, REN_Expiration_Quarter_Year__c, owner.Name,REN_EQ__c,REN_FY__c, ';
        String closeWonSOQL = soql+'Amount ';
        //Lumesse fields reference removal  
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_OPP_ADDS_AMOUNT)){
        closeWonSOQL += ' ,REN_AddsAmount__c ';
        }
        closeWonSOQL += ' from opportunity where StageName=: queryStageName and REN_Is_CLM_Renewal__c = true AND REN_Earliest_Expiration_Date__c != null';
        return database.query(closeWonSOQL);
   
    }
    
    public static List<Report> getReportList(){
        List<String> fieldList = new List<String>{REN_Constants.FLD_NAME};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REPORT, fieldList, CSM_Constants.DML_OPERATION_READ);
        return [SELECT Name FROM Report WHERE OwnerId in (SELECT id FROM folder where developerName =: REN_Constants.REPORTNAME)];
      
    }
    public static List<Opportunity> getOpportunitiesByIds(Set<ID> opptIds){
        
        List<String> opportunityFieldList = new List<String>{
            REN_Constants.OBJ_OPP_CONSOLIDATED, 
            REN_Constants.OBJ_OPP_APPEND_OPPTY,
            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
            REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER
        };
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);
        
        return [Select id, Amount, StageName,Name,AccountId,CHL_Partner_Account_1__c,CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_1_Type__c,CHL_Partner_Account_2__c,CHL_Partner_Account_2_Contact__c,CHL_Partner_Account_2_Type__c from Opportunity where ID in :opptIds];
    }
    
    public static void updateOpportunitySObject(List<SObject> opportunityToUpdate, List<String> opptyFieldList)
    {
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptyFieldList,CSM_Constants.DML_OPERATION_UPDATE);
         if(!opportunityToUpdate.isEmpty()){        
             update opportunityToUpdate;
         }
    }
    
    public static List<Opportunity> getConsolidateFieldSetByAccount(Set<Id> accountIdSet, 
        Boolean isConsolidated, Boolean allowSyncedQuote, Set<String> notAllowedStages,
        Boolean isClosedFlag,String filterId)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>();
        Set<Id> localAccountIdSet  = accountIdSet;
        boolean firstField = true;

        String queryString = 'SELECT Id, Name, Account.Name, Pricebook2.Name ';
        String nameSpace = CSM_Util.getNamespace();
        Integer recLimit = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_OPPORTUNITIES);
        CSM_Admin__c adminCustomSetting = CSM_AdminDataAccess.getCSMAdminInstance();
        
        if (adminCustomSetting != null 
            && adminCustomSetting.REN_Consolidate_Oppt_Grid_Rec_Limit__c != null)
        {
            recLimit = (Integer)adminCustomSetting.REN_Consolidate_Oppt_Grid_Rec_Limit__c;
        }
        recLimit = recLimit > 2000 ? 2000 : recLimit;
        
        for(Schema.FieldSetMember fld :SObjectType.Opportunity.FieldSets.REN_Consolidate_ListView_Fieldset.getFields()) 
        {
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }
            opportunityFieldList.add(fldStr);
            String fieldPathString = fld.getFieldPath();  
            String fieldTypeString = String.valueOf(fld.getType());
            if (fieldTypeString == CSM_Constants.TYPE_DATE || fieldTypeString == CSM_Constants.TYPE_INTEGER 
                    || fieldTypeString == CSM_Constants.TYPE_DOUBLE || fieldTypeString == CSM_Constants.TYPE_CURRENCY)
            {
                if (UserInfo.isMultiCurrencyOrganization() && fieldTypeString == CSM_Constants.TYPE_CURRENCY){
                    queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
                } else {
                    queryString += ', format(' + fld.getFieldPath() + ')';
                }
            }
            else
            {    
                queryString += ', ' + fld.getFieldPath(); 
            }          
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode'))
        {
            queryString += ', CurrencyIsoCode';
        }
        queryString += ', ownerId, Owner.Name';
        queryString += ' from Opportunity where '+nameSpace+'REN_Is_Consolidated__c = :isConsolidated';
        if(String.isNotBlank(filterId)) {
        	queryString += ' AND Id IN:oppIdSet';
        }
        if (localAccountIdSet != null && !localAccountIdSet.isEmpty())
        {
             queryString+= ' AND AccountId IN :localAccountIdSet';
        }
        if (notAllowedStages != null && !notAllowedStages.isEmpty())
        {
            queryString+= ' AND StageName NOT IN :notAllowedStages';
        }
        
        if (!allowSyncedQuote)
        {
            queryString += ' AND SyncedQuoteId = null';
        }
        if (isClosedFlag != null)
        {
            queryString += ' AND isClosed = :isClosedFlag'; 
        }
        queryString += ' Order by Account.Name ASC, CloseDate DESC ';
        queryString += ' Limit ' + recLimit;
        System.debug('queryString - '+queryString);
        String query = 'Select Id from Opportunity limit 10000';
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ); 
        Set<ID> oppIdSet = new Set<Id>();
        List<Opportunity> filteredOppList = new List<Opportunity>();
        if(String.isNotBlank(filterId)){
	        ApexPages.StandardSetController standSetCont = new ApexPages.StandardSetController(Database.getQueryLocator(query));
	    	standSetCont.setFilterId(filterId);
	    	standSetCont.setPageSize(recLimit);
	    	filteredOppList = (List<Opportunity>)standSetCont.getRecords();   	
			Map<ID, Opportunity> filteredOppMap = new Map<ID, Opportunity>(filteredOppList);			
			oppIdSet = filteredOppMap.keySet();
        }
		filteredOppList = Database.query(queryString);
        return filteredOppList;
    }
    
     public static List<OpportunityContactRole> getOpportunityContactRoles(Set<String>opptIds){
        List<OpportunityContactRole> tmplist = new List<OpportunityContactRole>();
        List<String> OpportunityContactRoleFieldList = new List<String>{REN_Constants.OBJ_OPPCONROLE_OPPTY, 
                                                            REN_Constants.OBJ_OPPCONROLE_CONTACT
                                                            };
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITYCONTACTROLE, OpportunityContactRoleFieldList,CSM_Constants.DML_OPERATION_READ);
        return [SELECT id,OpportunityId ,contactid,contact.Name,contact.Email from OpportunityContactRole where IsPrimary=true AND OpportunityId in :opptIds];
     }
    
    public static List<OpportunityContactRole> getOpportunityContactRoleswithoutcontact(Set<ID>opptIds){
        List<OpportunityContactRole> tmplist = new List<OpportunityContactRole>();
        List<String> OpportunityContactRoleFieldList = new List<String>{REN_Constants.OBJ_OPPCONROLE_OPPTY, 
                                                            REN_Constants.OBJ_OPPCONROLE_CONTACT
                                                            };
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITYCONTACTROLE, OpportunityContactRoleFieldList,CSM_Constants.DML_OPERATION_READ);
        return [SELECT id,OpportunityId ,contactid,contact.Name from OpportunityContactRole where Contact.Email = null AND IsPrimary=true AND OpportunityId  IN :opptIds];
     }
     
     public static List<OpportunityContactRole> getOpportunityContactRoleswithcontact(Set<ID>opptIds){
        List<OpportunityContactRole> tmplist = new List<OpportunityContactRole>();
        List<String> OpportunityContactRoleFieldList = new List<String>{REN_Constants.OBJ_OPPCONROLE_OPPTY, 
                                                            REN_Constants.OBJ_OPPCONROLE_CONTACT
                                                            };
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITYCONTACTROLE, OpportunityContactRoleFieldList,CSM_Constants.DML_OPERATION_READ);
        return [SELECT id,OpportunityId ,contactid,contact.Name,contact.Email from OpportunityContactRole where Contact.Email != null AND IsPrimary=true AND OpportunityId  IN :opptIds];
     }
     
      public static List<Opportunity> getOpportunitySyncQuote(Set<String> opptIds){
     // return [select id,SyncedQuoteId from Opportunity where id =: opptIds];
        //Set<String> opptIds1 = opptIds;
        List<String> opportunityFieldList = new List<String>{'StageName','REN_Low_Touch_Renewal_Id__c','REN_LT_Renewal_Details__c'};
        String soql = 'Select Id,Name, StageName, isClosed,REN_Low_Touch_Renewal_Id__c,REN_LT_Renewal_Details__c ';
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId')){
            soql += ', SyncedQuoteId, SyncedQuote.QuoteNumber';
        }
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c')){
            soql += ', '+CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c';
        }
        soql += ' From Opportunity WHERE Id IN :opptIds';
        system.debug('soqlQuote : ' + soql);
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        List<Opportunity> oppsyncQuote = Database.query(soql);  
        return oppsyncQuote;
    }
    
      public static List<Opportunity> getOpportunitySyncQuoteEnabled(Set<Id> opptIds){
        List<Opportunity> oppSyncQuote = new List<Opportunity>();
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId')){
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'Id', 'Name'}, CSM_Constants.DML_OPERATION_READ);
            oppSyncQuote = Database.query('SELECT Id, Name From Opportunity WHERE Id IN :opptIds AND SyncedQuoteId != null ');    
        }
        return oppSyncQuote;
    }
    
    public static List<Opportunity> getOpportunitiesByIdsWithContactRole(List<Schema.FieldSetMember> fieldSetMemberList,Set<String> segmentIds,String filter,Integer recordLimit){
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
            
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
            queryString += ', CurrencyIsoCode';
            fsFieldSet.add('CurrencyIsoCode'); 
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, fsFieldList, CSM_Constants.DML_OPERATION_READ);
        if(String.isNotEmpty(filter)) {
             //queryString = 'SELECT ' + queryString.removeStart(',') + ','+'(' + 'SELECT id,contactid,contact.Name,contact.Email from OpportunityContactRoles where IsPrimary=true'+')' + ' FROM Opportunity ' + filter +  ' AND ' + ' ID IN ' + '(' + 'SELECT REN_Renews_To__c FROM REN_Renews_To__c where REN_Renews_To__c!=NULL ' + ')' + ' AND ' + ' ID NOT IN (SELECT REN_Opportunity__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds)';
             queryString = 'SELECT ' + queryString.removeStart(',') + ','+'(' + 'SELECT id,contactid,contact.Name,contact.Email from OpportunityContactRoles where IsPrimary=true'+')' + ' FROM Opportunity ' + filter +  ' AND ID NOT IN (SELECT REN_Opportunity__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds)';
        }else{
             queryString = 'SELECT ' + queryString.removeStart(',') + ','+'(' + 'SELECT id,contactid,contact.Name,contact.Email from OpportunityContactRoles where IsPrimary=true'+')' + ' FROM Opportunity WHERE ID NOT IN (SELECT REN_Opportunity__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds)';
        }
      
        if(recordLimit == null) {
            recordLimit = 1000;
        }
        queryString += ' LIMIT ' + recordLimit;
        system.debug(fieldSetMemberList + '\n\n queryString in getDataUsingFieldSet --- : ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }   
    
    public static List<Opportunity> getOpportunitiesByIdsWithInvalidContact(List<Schema.FieldSetMember> fieldSetMemberList,Set<ID>opptIds,Integer recordLimit){
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
            
            
            if(!fld.getFieldPath().contains('.')){
                fsFieldSet.add(fldStr);
            }
            refrenceFieldSet.add(fldStr);
        }
        system.debug('*******************fsFieldSet'+fsFieldSet);
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
            queryString += ', CurrencyIsoCode';
            fsFieldSet.add('CurrencyIsoCode'); 
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, fsFieldList, CSM_Constants.DML_OPERATION_READ);
    
        queryString = 'SELECT ' + queryString.removeStart(',') + ','+ (queryString.contains('SyncedQuote.Name')? '': ' SyncedQuote.Name, ') +'(' + 'SELECT id,contactid,contact.Name,contact.Email from OpportunityContactRoles where IsPrimary=true'+')' + ' FROM Opportunity WHERE id != null AND ID in :opptIds';
        
        if(recordLimit == null) {
            recordLimit = 1000;
        }
        queryString += ' LIMIT ' + recordLimit;
        system.debug(fieldSetMemberList + '\n\n queryString in getDataUsingFieldSet --- : ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
    
    public static List<SObject> getDataUsingFieldSet(List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet, String filterStr, Integer recordLimit) {   
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
        system.debug('filterStr---->'+filterStr);
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, fsFieldList, CSM_Constants.DML_OPERATION_READ);
        if(String.isNotBlank(filterStr)){
            queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Opportunity WHERE id != null ' + (String.isBlank(filterStr) ? ' ': (' AND (' + filterStr + ' ) '));
        }
        else{
            queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Opportunity WHERE id != null ' + (String.isBlank(filterStr) ? ' ': (' (' + filterStr + ' ) '));
        }
        
        if(recordLimit == null) {
            recordLimit = 1000;
        }
        
        queryString += ' LIMIT ' + recordLimit;
        
        system.debug(fieldSetMemberList + '\n\n queryString in getDataUsingFieldSet --- : ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
        //For Opportunity With Amount Format
    public static List<SObject> getDataUsingFieldWithoutFormat(List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet, String filterStr, Integer recordLimit) {   
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
        if(fld.getType().equals(Schema.DisplayType.DATE) || //fld.getType().equals(Schema.DisplayType.DOUBLE) ||
           fld.getType().equals(Schema.DisplayType.DATETIME)){
            queryString += ', format(' + fld.getFieldPath() + ')';
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
                //fsFieldSet.add(s);
                queryString += ','+ s;  
            }
        }
    }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        system.debug('filterStr---->'+filterStr);
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, fsFieldList, CSM_Constants.DML_OPERATION_READ);
        if(String.isNotBlank(filterStr)){
          queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Opportunity WHERE id != null ' + (String.isBlank(filterStr) ? ' ': (' AND (' + filterStr + ' ) '));
        }
        else{
          queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Opportunity WHERE id != null ' + (String.isBlank(filterStr) ? ' ': (' (' + filterStr + ' ) '));
        }
        
        if(recordLimit == null) {
           recordLimit = 1000;
        }
        
        queryString += ' LIMIT ' + recordLimit;
        system.debug('+++'+queryString); 
        system.debug(fieldSetMemberList + '\n\n queryString in getDataUsingFieldSet --- : ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        
        return sObjectList;
    }
    //To fetch primary contact from opportunity
    public static List<OpportunityContactRole> getPrimaryContacts(set<String> oppIds) {
        //List<OpportunityContactRole> opptyContactRoleList = [SELECT ContactId,Id,IsPrimary,OpportunityId,Contact.FirstName,Contact.LastName,Contact.Email,Contact.REN_Prefered_Language_Code__c,Contact.HasOptedOutOfEmail FROM OpportunityContactRole where OpportunityId IN :oppIds and IsPrimary = true limit 100];
        return getPrimaryContacts(oppIds,null);
    }
    
    public static List<OpportunityContactRole> getPrimaryContacts(set<String> oppIds, String AccountId) {
    	List<OpportunityContactRole> opptyContactRoleList;
    	if(String.isNotBlank(AccountId) && AccountId != null ) {
        	opptyContactRoleList = [SELECT ContactId,Id,IsPrimary,OpportunityId,Contact.FirstName,Contact.LastName,Contact.Email,Contact.REN_Prefered_Language_Code__c,Contact.HasOptedOutOfEmail FROM OpportunityContactRole where OpportunityId IN :oppIds and IsPrimary = true AND Contact.AccountId =:AccountId limit 100];
    	} else {
    		opptyContactRoleList = [SELECT ContactId,Id,IsPrimary,OpportunityId,Contact.FirstName,Contact.LastName,Contact.Email,Contact.REN_Prefered_Language_Code__c,Contact.HasOptedOutOfEmail FROM OpportunityContactRole where OpportunityId IN :oppIds and IsPrimary = true limit 100];
    	}
        return opptyContactRoleList;
    }
    public static List<Opportunity> getOpportunityListWithRliSetAndStageNSApprovalStatusFields(Set<ID> opptIds){
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        List<String> opportunityFieldList = new List<String>{'id','StageName'};
        
        SS_License__c ssLicenseCS = SS_License__c.getOrgDefaults();					
		
        String finalQuery = 'Select id,StageName,'+ CSM_Util.getNamespace()+'REN_Is_Consolidated__c,';
        opportunityFieldList.add(CSM_Util.getNamespace()+'REN_Is_Consolidated__c');
        if(CSM_AccessController.hasField('OPPORTUNITY', CSM_Util.nameSpacePrefixSolnExtn + 'NS_Approval_Status__c')) {
        	opportunityFieldList.add(solnExtnNamespace + 'NS_Approval_Status__c');
        	finalQuery += solnExtnNamespace + 'NS_Approval_Status__c,';
        }
        finalQuery += ' (SELECT id, Name FROM '+ CSM_Util.getNamespace() +'Renew_To__r LIMIT 1) FROM Opportunity where ID in :opptIds';

        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);
        system.debug('\n\nQuery : '+finalQuery);
        return Database.query(finalQuery);            
    }
    
    public static List<sObject> getObjectRecordsList(String fromObject, Set<String> knownFields, Set<String> firstFilterSet, String whereCondition, boolean isFirstFilterSetRequired,Integer recordLimit){
        if(isFirstFilterSetRequired && (firstFilterSet == null || firstFilterSet.isEmpty())){
            return null;
        }
        CSM_Util.checkCRUD_FlsPermissions(fromObject, knownFields, CSM_Constants.DML_OPERATION_READ);       
        String soqlStr = CSM_Util.getSOQLString(fromObject, knownFields, whereCondition, null, null);
        soqlStr += ' LIMIT ' + recordLimit;
        system.debug(firstFilterSet + 'firstFilterSet, \n\n check this SOQL :: ' + soqlStr);
        List<sObject> resultList = Database.query(soqlStr);
        return resultList;
     }
     
     public static List<sObject> getObjectRecordsList(REN_CustomSearchController.REN_SOQLWrapper wrapper){
        if((wrapper.isFirstFilterSetRequired && (wrapper.sFilter1 == null || wrapper.sFilter1.isEmpty())) || (wrapper.isFirstFilterSetRequired && (wrapper.nFilter1 == null || wrapper.nFilter1.isEmpty()))){
            return null;
        }
        Set<String> sFilter1 = wrapper.sFilter1 != null && !wrapper.sFilter1.isEmpty() ? wrapper.sFilter1 : new Set<String>();
        Set<Integer> nFilter1 = wrapper.nFilter1 != null && !wrapper.nFilter1.isEmpty() ? wrapper.nFilter1 : new Set<Integer>();
        CSM_Util.checkCRUD_FlsPermissions(wrapper.fromObject, wrapper.knownFields, CSM_Constants.DML_OPERATION_READ);       
        String soqlStr = CSM_Util.getSOQLString(wrapper.fromObject, wrapper.knownFields, wrapper.whereCondition, null, null);
        soqlStr += ' LIMIT ' + wrapper.recordLimit;
        system.debug(wrapper.sFilter1 + 'wrapper.sFilter1, \n\n check this SOQL :: ' + soqlStr);
        List<sObject> resultList = Database.query(soqlStr);
        return resultList;
     }
     
	public static List<sObject> getObjectRecordsList(String fromObject, String fieldsInCsvFormatToSelect, String whereCondition, Set<String> firstFilterSet, Integer recLimit){
       //CRUD_Fls check is not required. Fields in fieldsInCsvFormatToSelect variables should be added after CRUD_FLS check in calling method.
       String soqlStr = 'SELECT '+ fieldsInCsvFormatToSelect + ' from ' + fromObject + (String.isBlank(whereCondition) ? '' : ' WHERE ' + whereCondition + (recLimit > 0 ? ' LIMIT ' + recLimit : ''));
       system.debug(firstFilterSet + 'firstFilterSet, \n\n check this SOQL :: ' + soqlStr);
       List<sObject> resultList = Database.query(soqlStr); 
       return resultList;
    }

	public static List<Opportunity> getOpportunityWithRli(Set<ID> opptIds, String filterString){
        List<String> opportunityFieldList = new List<String>{
            REN_Constants.OBJ_OPP_CONSOLIDATED, 
            REN_Constants.OBJ_OPP_APPEND_OPPTY,
            REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
            REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER
        };
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);
        String initialPartQuery = 'Select id,StageName,Pricebook2Id, Amount,REN_Is_CLM_Renewal__c,REN_Renewal_Target__c,REN_Renewal_Target_Lost__c,REN_Renewal_Target_Won__c,REN_Earliest_Expiration_Date__c,REN_Renewal_Target_Resolved__c,' +  
            '(SELECT id, Name, REN_Renews_To__c, REN_Source_Opportunity__c, REN_Previous_Opportunity__c, REN_Renewal_Target__c, REN_Previous_Price__c, REN_Renewal_Target_Multiplier__c, REN_Product__c, REN_Asset__c,  ' + 
                    'REN_Start_Date__c, REN_End_Date__c, REN_Renewal_Status__c, REN_Quantity__c';
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
        String intermediatePartQuery = '';
        if(isSolutionExtnInstalled){
            intermediatePartQuery += ', ' + solnExtnNamespace + 'Previous_Local_Currency_Code__c' + ', ' + solnExtnNamespace + 'Previous_Local_Currency_Amount__c';
        }
        intermediatePartQuery += ' FROM Renew_To__r) ';
        String finalPartquery = ' FROM Opportunity where ID in :opptIds' + (String.isNotBlank(filterString) ? ' AND (' +  filterString + ') ' : '');
        String finalQuery = initialPartQuery + intermediatePartQuery + finalPartquery;
        List<Opportunity> resultList = Database.query(finalQuery);
        return resultList;    
    }
    
    public static List<Opportunity> getOpportunityWithFilter(Set<ID> opptIdsSet, String filterString){       
        List<String> opportunityFieldList = new List<String>{REN_Constants.OBJ_OPP_ISCLM_RENEWAL,REN_Constants.OBJ_OPP_ADDS_AMOUNT};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_READ);       
        String initialPartQuery = 'Select Id,REN_Is_CLM_Renewal__c,REN_AddsAmount__c'; 
        String finalPartquery = ' FROM Opportunity where ID in :opptIdsSet' + (String.isNotBlank(filterString) ? ' AND (' +  filterString + ') ' : '');
        String finalQuery = initialPartQuery + finalPartquery;
        List<Opportunity> resultList = Database.query(finalQuery);
        return resultList;    
    }
    
    public static List<Opportunity> getOpportunityDetailsForCurrency(Set<String> oppIdSet){
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'CurrencyIsoCode'},CSM_Constants.DML_OPERATION_READ);
    	String queryString = 'Select Id,CurrencyIsoCode FROM Opportunity where ID in :oppIdSet';
        List<Opportunity> resultList = Database.query(queryString);
        return resultList;   	
    }
    public static List<Opportunity> getOpportunityListById(Set<Id> oppIdSet){
    	List<Opportunity> resultList = new List<Opportunity>();
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId')){
	    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'Id','Name'},CSM_Constants.DML_OPERATION_READ);
	    	String queryString = 'Select Id, SyncedQuoteId FROM Opportunity where ID in :oppIdSet';
	        resultList = Database.query(queryString);
        }
        return resultList;   	
    }
    
    public static List<Opportunity> getOpportunityDetailsById(Set<Id> opportunityIdSet, List<String> fldsToQuery, List<String> additionlFields){
       CSM_Util.checkCRUD_FLS('Opportunity', fldsToQuery, CSM_Constants.DML_OPERATION_READ);
       String soqlStr;
       if(additionlFields != null){
       	   fldsToQuery.addAll(additionlFields);
       }
       soqlStr = String.join(fldsToQuery, ',');
       soqlStr = 'SELECT ' + soqlStr + ' FROM Opportunity WHERE Id IN:opportunityIdSet limit 1000'; 
       return Database.query(soqlStr); 
   }
    
}