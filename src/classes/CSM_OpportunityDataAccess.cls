public with sharing class CSM_OpportunityDataAccess
{
    public static List<Opportunity> getDetailFieldSetByAccount(String accountId)
    {
       return getDetailFieldSetByAccount(accountId, null);
    }
    
    public static List<Opportunity> getDetailFieldSetByAccount(String accountId, Date phaseDate)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>();
        Id localAccountId = accountId;
        boolean firstField = true;

        String queryString = 'SELECT Id, Name';
        String nameSpace = CSM_Util.getNamespace();
        Integer recLimit = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_OPPORTUNITIES);
        for(Schema.FieldSetMember fld :SObjectType.Opportunity.FieldSets.CSM_Details_Fieldset.getFields()) 
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
        queryString += ' from Opportunity where AccountId = :localAccountId AND IsClosed = false';
        if (phaseDate!=null && CSM_Util.isDate(phaseDate.format())){
    		queryString += ' AND CloseDate >= :phaseDate';
        }
        queryString += ' Limit ' + recLimit;
        System.debug('queryString - '+queryString);
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_OPPORTUNITY, 
                CSM_Constants.DML_OPERATION_READ, opportunityFieldList);
        if (noAccessFieldList.isEmpty())
        {    
            tmplist = Database.query(queryString);
            return tmplist;
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
    
        return tmplist;
    }
    
    
    public static void deleteOpportunity(List<Opportunity> opportunityDelete)
    {
    
        List<String> noAccessList = CSM_AccessController.getInstance(
            ).returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_OPPORTUNITY,
            CSM_Constants.DML_OPERATION_DELETE, null);
        
        //No need to check if access list is empty.  If user cannot delete then exception will be thrown
        delete opportunityDelete;
    }
    
    public static List<Opportunity> getDetailFieldSetById(String opptId)
    {
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>();
        boolean firstField = true;

        String queryString = 'SELECT Id';
        String nameSpace = CSM_Util.getNamespace();
        List<Schema.FieldSetMember> lstSplitEditFields = SObjectType.Opportunity.FieldSets.REN_Opportunity_Split_Edit.getFields();
        List<Schema.FieldSetMember> lstSplitReadOnlyFields = SObjectType.Opportunity.FieldSets.REN_Opportunity_Split_ReadOnly.getFields();

        Set<String> fieldNamesSet = new Set<String>();
        
        for(Schema.FieldSetMember fld :lstSplitEditFields)
        {
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0)
            {
                fldStr = fldStr.replace(nameSpace, '');
            }

            opportunityFieldList.add(fldStr);
            queryString += ', ' + fld.getFieldPath();
            fieldNamesSet.add(fldStr);
        }
        
        for(Schema.FieldSetMember fld :lstSplitReadOnlyFields)
        {
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0)
            {
                fldStr = fldStr.replace(nameSpace, '');
            }
            if(!fieldNamesSet.contains(fldStr))
            {
                opportunityFieldList.add(fldStr);
                queryString += ', ' + fld.getFieldPath();
                fieldNamesSet.add(fldStr);
            }
        }
        
        if(!fieldNamesSet.contains('REN_Split_Counter__c')){
        	opportunityFieldList.add('REN_Split_Counter__c');
        	queryString += ', REN_Split_Counter__c';
            fieldNamesSet.add('REN_Split_Counter__c');
        }
        
        Boolean recordTypeExists = CSM_Util.getRecordTypeExists(new Opportunity());
        if (recordTypeExists && !fieldNamesSet.contains('RecordTypeId'))
        {
        	opportunityFieldList.add('RecordTypeId');
            queryString += ', RecordTypeId';
            fieldNamesSet.add('RecordTypeId');
        }

        queryString += ' from Opportunity where Id = :opptId LIMIT 1';   
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_OPPORTUNITY, 
                CSM_Constants.DML_OPERATION_READ, opportunityFieldList);
        if (noAccessFieldList.isEmpty())
        {    
            tmplist = Database.query(queryString);
            return tmplist;
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
    
        return tmplist;
    }
    
    /*public static List<Opportunity> getOpportunityDetailById(List<String> opptIds){
        List<Opportunity> tmplist = new List<Opportunity>();
        List<String> opportunityFieldList = new List<String>{REN_Constants.OBJ_OPP_CONSOLIDATED};
        boolean firstField = true;

        String nameSpace = CSM_Util.getNamespace();
        String soqlStr = joinList(CSM_Util.getSOQLFieldsCollection(CSM_Constants.OBJ_OPPORTUNITY, new Set<String>(opportunityFieldList), '', null, null), 
        							', ', nameSpace);
        System.debug('soqlStr - ' + soqlStr);
        String queryString =  'SELECT ' + soqlStr + 
                                ' FROM Opportunity' + 
                                ' WHERE Id IN:opptIds Order By Name Limit 10';
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_OPPORTUNITY, 
                CSM_Constants.DML_OPERATION_READ, opportunityFieldList);
        if (noAccessFieldList.isEmpty())
        {    
            tmplist = Database.query(queryString);
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
    
        return tmplist;
    }*/
    
    /*public static List<String> getAccessibleFields() {
        List<String> accessibleFields = new List<String>();
        Map<String, Schema.SobjectField> fields = 
            Opportunity.getSObjectType().getDescribe().fields.getMap();
        for (String field : fields.keySet()) {
            DescribeFieldResult dfr = fields.get(field).getDescribe();
            if (dfr.isAccessible(3)) {
                accessibleFields.add(field);
                if(dfr.getType().equals(Schema.DisplayType.Reference)){
                    accessibleFields.add(dfr.getRelationshipName() + '.Name');
                }
            }
        }
        return accessibleFields;
    }*/
    
    /*public static void getAccessibleFields(List<REN_MergeOppFieldWrapper> readOnlyFields, List<REN_MergeOppFieldWrapper> updateableFields) {
        Set<String> stdReadOnlyFields = new Set<String>{'amount', 'totalopportunityquantity', 'pricebook2id'};
        Set<String> notAllowedFields = new Set<String>{'Consolidated', 'Consolidated To'};
        Map<String, Schema.SobjectField> fields = 
            Opportunity.getSObjectType().getDescribe().fields.getMap();
        for (String field : fields.keySet()) {
            DescribeFieldResult dfr = fields.get(field).getDescribe();
            if(!notAllowedFields.contains(dfr.getLabel())){
                REN_MergeOppFieldWrapper wrapper = new REN_MergeOppFieldWrapper(dfr.getLabel(), dfr.getName(), field);
                if (!stdReadOnlyFields.contains(field) && dfr.isUpdateable()) {
                    updateableFields.add(wrapper);
                }else if(!dfr.isCalculated() && dfr.isAccessible()){
                    readOnlyFields.add(wrapper);
                }
            }
        }
    }*/
    
    public static void updateOpportunityList(List<Opportunity> opportunityList, List<String> fieldListForCrudFls){        
        CSM_Util.checkCRUD_FLS('Opportunity', fieldListForCrudFls, CSM_Constants.DML_OPERATION_UPDATE);
        update opportunityList;         
        
    }
    public static void upsertOpportunityList(List<Opportunity> opportunityList){
        List<String> opportunityFieldList = new List<String>{
        	REN_Constants.OBJ_OPP_CONSOLIDATED, 
            REN_Constants.OBJ_OPP_ISCLM_RENEWAL, 
            REN_Constants.OBJ_OPP_STAGE,
            REN_Constants.OBJ_OPP_OWNER_ID,
            REN_Constants.OBJ_OPP_ACCOUNT,
            REN_Constants.OBJ_OPP_PRICEBOOK_ID,
            'Id'};      
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                CSM_CONSTANTS.OBJ_OPPORTUNITY,
                                CSM_Constants.DML_OPERATION_UPSERT, 
                                opportunityFieldList);
        if(noAccessList.isEmpty())
        {
            upsert opportunityList;         
        }
        else
        {
            String[] arguments = new String[] {CSM_CONSTANTS.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
                System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));  
        }
    }
    
	private static String joinList(List<String> theList, String separator, String namespace) {
        if (theList == null)   { return null; }
        if (separator == null) { separator = ''; }
        namespace = String.isBlank(namespace)?'':namespace;
        String joined = '';
        Boolean firstItem = true;
        System.debug('namespace - '+ namespace);
        for (String item : theList) {
            System.debug('ZZZ item - '+item);
            System.debug('namespace - '+ namespace.indexOf(item));
            item = item.replace(namespace, '');
            System.debug('ZZZ item - '+item);
            if(item != null && item.length()>0) {
                if(firstItem){ firstItem = false; }
                else { joined += separator; }
                if (item.contains('__c')) {
                    joined += namespace + item;
                } else {
                    joined += item;
                }
            }
        }
        return joined;
    }
    
    public static List<Opportunity> insertRenewalOpportunity(List<Opportunity> opportunityList){
        
        List<String> opportunityFieldList = new List<String>{REN_Constants.OBJ_OPP_CONSOLIDATED,
        	REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
        	REN_Constants.OBJ_OPP_CLOSE_DATE,REN_Constants.OBJ_OPP_ACCOUNT,CSM_Constants.OBJ_O_NAME,
        	CSM_Constants.OBJ_O_IS_CLM_RENEWAL};    
                                                        
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
                                CSM_CONSTANTS.OBJ_OPPORTUNITY,
                                CSM_Constants.DML_OPERATION_INSERT, 
                                opportunityFieldList);
        if(noAccessList.isEmpty()) {
            insert opportunityList;   
        }
        else {
            String[] arguments = new String[] {CSM_CONSTANTS.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
                System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, arguments));  
        }
        return opportunityList;
    }
    
    public static List<Opportunity> getOpportunitiesByAccount(String accountId)
    {
        List<String> oppFieldList = new List<String>{CSM_Constants.OBJ_O_NAME, CSM_Constants.OBJ_O_ID, CSM_Constants.OBJ_O_CLOSE_DATE, CSM_Constants.OBJ_O_IS_CLOSED, 
            CSM_Constants.OBJ_O_ACCOUNT_ID, CSM_Constants.OBJ_O_IS_CLM_RENEWAL};
        List<Opportunity> listOfOpportunities = new List<Opportunity>();
        
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_OPPORTUNITY,
            CSM_Constants.DML_OPERATION_READ, oppFieldList);   
        
        if (noAccessList.isEmpty())
        {
            listOfOpportunities = [SELECT Id,
                                          Name,
                                          CloseDate,
                                          IsClosed,
                                          REN_Is_CLM_Renewal__c
                                     FROM Opportunity
                                    WHERE AccountId = :accountId LIMIT 250];
        }
        else
        {
            String[] arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY + ':'+String.valueOf(noAccessList)};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));       
        }
        return listOfOpportunities;
    }
    public static List<Opportunity> getRenewalOpportunitiesByAccount(String accountId)
    {
        /*List<Opportunity> listOfOpportunities = new List<Opportunity>();
        
        if (CSM_AccessController.getInstance().objectCrudCheck(CSM_Constants.OBJ_TYPE_OPPORTUNITY, CSM_Constants.DML_OPERATION_READ))
        {
        	//Eswar Bala: 07/16/2015 - Good Tech - FIX for Timeline issue where Success Plan page load was breaking because there was a query to fetch all fields that had access
        	List<String> opportunityFields = new List<String>{REN_Constants.OBJ_OPP_CLOSE_DATE, 
        													  REN_Constants.OBJ_OPP_CREATED_DATE,
		                                                      REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
		                                                      REN_Constants.FLD_NAME,
		                                                      REN_Constants.OBJ_OPP_ACCOUNT,
		                                                      REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
		                                                      REN_Constants.FLD_ISDELETED
		                                                  	  };
        	List<String> noAccessFieldList = CSM_AccessController.getInstance()
								        									.returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TYPE_OPPORTUNITY, 
								                							CSM_Constants.DML_OPERATION_READ, opportunityFields);
                							
			if(noAccessFieldList.isEmpty())
			{
				String columnString = REN_Constants.OBJ_OPP_CLOSE_DATE + ', ' + REN_Constants.OBJ_RC_OPPORTUNITY_STAGE + ', ' + REN_Constants.FLD_NAME + ', ' + REN_Constants.OBJ_OPP_CREATED_DATE;
	        	String queryString = 'SELECT ' + columnString;
	        	queryString += ' FROM Opportunity WHERE ' + REN_Constants.OBJ_OPP_ACCOUNT + ' = :accountId AND ' + REN_Constants.OBJ_OPP_ISCLM_RENEWAL + ' = true AND ' 
	        					+ REN_Constants.FLD_ISDELETED + ' = false limit 100'; 
	        	listOfOpportunities = Database.query(queryString);
			}
        }
        else
        {
            String[] arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            																System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));  
        }
        return listOfOpportunities;*/
        return null;
    }
    
    public static List<Opportunity> getRenewalOpptyByAcctAndLocationOnSuccessPlan(String accountId, String opptyLocFldOnSPT)
    {
        List<Opportunity> listOfOpportunities = new List<Opportunity>();
        String columnString = '';
        
        if (CSM_AccessController.getInstance().objectCrudCheck(CSM_Constants.OBJ_TYPE_OPPORTUNITY, CSM_Constants.DML_OPERATION_READ))
        {
        	List<String> opportunityFields = new List<String>{REN_Constants.OBJ_OPP_CLOSE_DATE,
        													  REN_Constants.OBJ_OPP_CREATED_DATE,
		                                                      REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
		                                                      REN_Constants.FLD_NAME,
		                                                      REN_Constants.OBJ_OPP_ACCOUNT,
		                                                      REN_Constants.OBJ_OPP_ISCLM_RENEWAL,
		                                                      REN_Constants.FLD_ISDELETED,REN_Constants.IS_WON,
		                                                      opptyLocFldOnSPT
		                                                  	  };
        	List<String> noAccessFieldList = CSM_AccessController.getInstance()
								        									.returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TYPE_OPPORTUNITY, 
								                							CSM_Constants.DML_OPERATION_READ, opportunityFields);
                							
			if(noAccessFieldList.isEmpty())
			{
				// check if not close date, since timeline uses the close date as default if date location for oppty is not specified.
				if (opptyLocFldOnSPT != null && opptyLocFldOnSPT.equalsIgnoreCase(REN_Constants.OBJ_OPP_CLOSE_DATE)) {
					columnString = opptyLocFldOnSPT + ', ' + REN_Constants.OBJ_RC_OPPORTUNITY_STAGE + ', ' + REN_Constants.FLD_NAME + ', ' + REN_Constants.OBJ_OPP_CREATED_DATE + ',' + REN_Constants.IS_WON;
				}
				else {
					columnString = REN_Constants.OBJ_OPP_CLOSE_DATE + ', ' + opptyLocFldOnSPT + ', ' + REN_Constants.OBJ_RC_OPPORTUNITY_STAGE + ', ' + REN_Constants.FLD_NAME + ', ' + REN_Constants.OBJ_OPP_CREATED_DATE+ ',' + REN_Constants.IS_WON;
				}
	        	String queryString = 'SELECT ' + columnString;
	        	queryString += ' FROM Opportunity WHERE ' + REN_Constants.OBJ_OPP_ACCOUNT + ' = :accountId AND ' + REN_Constants.OBJ_OPP_ISCLM_RENEWAL + ' = true AND ' 
	        					+ REN_Constants.FLD_ISDELETED + ' = false limit 100'; 
                system.debug('queryString------->'+queryString);
	        	listOfOpportunities = Database.query(queryString);
			}
        }
        else
        {
            String[] arguments = new String[] {CSM_Constants.OBJ_OPPORTUNITY};
            throw new CSM_AccessController.AccessControlDmlException( String.format(
            																System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));  
        }
        return listOfOpportunities;
    }     
    
    public static List<Opportunity> getOpportunitiesById(Set<String> opptyIds){
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OPPORTUNITY, new List<String>{
    		CSM_Constants.OBJ_O_ID, CSM_Constants.OBJ_O_ACCOUNT_ID, 'CloseDate'}, 
    	    CSM_Constants.DML_OPERATION_READ);
    	return [SELECT Id, AccountId,CloseDate FROM Opportunity WHERE Id IN :opptyIds limit 200];
    }
    
	public static List<OpportunityContactRole> fetchOpportunityContactRole(Set<String> opptIds)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OCR, new List<String>{
    		CSM_Constants.OBJ_OCR_ID, CSM_Constants.OBJ_OCR_ROLE, CSM_Constants.OBJ_OCR_OPP_ID,
    		CSM_Constants.OBJ_OCR_IS_PRIMARY, CSM_Constants.OBJ_OCR_CONTACT_ID}, 
    	    CSM_Constants.DML_OPERATION_READ);
		return [Select Id, Role, OpportunityId, IsPrimary, ContactId From OpportunityContactRole WHERE OpportunityId IN :opptIds limit 1000];
	}
	
	public static List<OpportunityContactRole> fetchOpportunityContactRole(Set<Id> opptIds)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OCR, new List<String>{
    		CSM_Constants.OBJ_OCR_ID, CSM_Constants.OBJ_OCR_ROLE, CSM_Constants.OBJ_OCR_OPP_ID,
    		CSM_Constants.OBJ_OCR_IS_PRIMARY, CSM_Constants.OBJ_OCR_CONTACT_ID}, 
    	    CSM_Constants.DML_OPERATION_READ);
		return [Select Id, Role, OpportunityId, IsPrimary, ContactId From OpportunityContactRole WHERE OpportunityId IN :opptIds limit 1000];
	}
	
	public static void insertOpportunityContactRole(List<OpportunityContactRole> oppContactRoleList)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OCR, new List<String>{
    		CSM_Constants.OBJ_OCR_ROLE,
    		CSM_Constants.OBJ_OCR_IS_PRIMARY, CSM_Constants.OBJ_OCR_CONTACT_ID}, 
    	    CSM_Constants.DML_OPERATION_INSERT);
		insert oppContactRoleList;
	}
	
	public static List<OpportunityCompetitor> fetchOpportunityCompetitor(Set<String> opptIds)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OC, new List<String>{
    		CSM_Constants.OBJ_OC_WEAKNESSES, CSM_Constants.OBJ_OC_STRENGTHS, //CSM_Constants.OBJ_OC_OPP_ID,
    		CSM_Constants.OBJ_OC_COMP_NAME}, 
    	    CSM_Constants.DML_OPERATION_READ);
		return [Select Weaknesses, Strengths, OpportunityId, CompetitorName From OpportunityCompetitor WHERE OpportunityId IN :opptIds limit 1000];
	}
	
	public static void insertOpportunityCompetitor(List<OpportunityCompetitor> oppCompetitorList)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OC, new List<String>{
    		CSM_Constants.OBJ_OC_WEAKNESSES, CSM_Constants.OBJ_OC_STRENGTHS, CSM_Constants.OBJ_OC_COMP_NAME}, 
    	    CSM_Constants.DML_OPERATION_INSERT);
		insert oppCompetitorList;
	}		
	
	public static List<OpportunityPartner> fetchOpportunityPartner(Set<String> opptIds)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OP, new List<String>{
    		CSM_Constants.OBJ_OP_ROLE, CSM_Constants.OBJ_OP_REV_PART_ID, CSM_Constants.OBJ_OP_OPP_ID,
    		CSM_Constants.OBJ_OP_IS_PRIMARY, CSM_Constants.OBJ_OP_ID, CSM_Constants.OBJ_OP_ACCOUNT_TO_ID}, 
    	    CSM_Constants.DML_OPERATION_READ);
		return [Select Role, ReversePartnerId, OpportunityId, IsPrimary, Id, AccountToId From OpportunityPartner WHERE OpportunityId IN :opptIds limit 1000];
	}
	
	public static void insertPartner(List<Partner> partnerList)
	{
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PARTNER, new List<String>{'Id'}, 
    	    CSM_Constants.DML_OPERATION_INSERT);
		insert partnerList;
	}
	
	public static List<Opportunity> getOpportunitiesDetails(Set<String> oppIdSet, List<String> oppFieldSet,String queryString){
		CSM_Util.checkCRUD_FLS('Opportunity', oppFieldSet, CSM_Constants.DML_OPERATION_READ);
		return Database.query(queryString);
	}
}