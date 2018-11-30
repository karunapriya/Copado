public with sharing class CSM_AccountPlanDataAccess
{
	public static List<CSM_Account_Plan__c> getAccountPlanByIdOrAccount(String id, String accountId)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_DISPLAY_NAME, 
		         CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE,
		         CSM_Constants.OBJ_AP_ID, 
		         CSM_Constants.OBJ_AP_RENEWAL_DATE, 
				 CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR,
				 CSM_Constants.OBJ_AP_ACCOUNT_OWNER_ID,
				 CSM_Constants.OBJ_AP_CSM_CONTACT,
				 CSM_Constants.OBJ_AP_CSM_MANAGER,
				 CSM_Constants.OBJ_AP_EXEC_SPONSOR,
				 CSM_Constants.OBJ_AP_RENEWAL_CONTACT,
				 CSM_Constants.OBJ_AP_RENEWAL_MANAGER,
				 CSM_Constants.OBJ_AP_SUPPORT_CONTACT,		         
		         CSM_Constants.OBJ_AP_ACCOUNT_MANAGER};
		String newUserLkpsAcctPlanFldsStr = '';
		Map<String, String> userLkpsForTaskMap = CSM_Util.getUserLookupsForSObject(CSM_Constants.OBJ_AP);
        if (userLkpsForTaskMap != null && !userLkpsForTaskMap.isEmpty()) {
        	for (String fldAPIName : userLkpsForTaskMap.keySet()) {
        		acctPlanFieldList.add(fldAPIName);
        		newUserLkpsAcctPlanFldsStr = newUserLkpsAcctPlanFldsStr + fldAPIName + ', ';
        	}
        }

		List<String> acctFieldList = new List<String>{CSM_Constants.OBJ_A_NAME};
		List<String> templateList = new List<String>{CSM_Constants.OBJ_APT_ID};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
    
        List<String> noAccessAcctFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_ACCOUNT, 
                CSM_Constants.DML_OPERATION_READ, acctFieldList);
                
        List<String> noAccessTemplateFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_APT, 
                CSM_Constants.DML_OPERATION_READ, templateList);            
        
        if (noAccessFieldList.isEmpty() && noAccessAcctFieldList.isEmpty() && noAccessTemplateFieldList.isEmpty())
        { 
			if (String.isNotBlank(id)) {
				/*tmpList =  [SELECT CSM_DisplayName__c,
	 				  	   CSM_AccountId__c, 
	                       CSM_Account_Plan_Template__c,
	                       CSM_Renewal_Date__c,
	                       CSM_Account_Owner_Id__c,
	                       CSM_Account_Manager__c,
	                       CSM_Phase_Start_Date__c,
	                       CSM_Contact__c,
						   CSM_Manager__c,
						   CSM_Exec_Sponsor__c,
						   CSM_Renewal_Contact__c,
						   CSM_Renewal_Manager__c,
						   CSM_Support_Contact__c,	
						   CSM_Customer_Success_Manager__c,						   	         
	                       Id,
						   CSM_AccountId__r.Name
	                  FROM CSM_Account_Plan__c 
	                 WHERE ID = :id LIMIT 1];*/
	                 String soqlForAcctPlan = 'SELECT CSM_DisplayName__c, ' + 
	 				  	   'CSM_AccountId__c, ' +  
	                       'CSM_Account_Plan_Template__c, '+
	                       'CSM_Renewal_Date__c, ' + 
	                       'CSM_Account_Owner_Id__c, ' + 
	                       'CSM_Account_Manager__c, ' +
	                       'CSM_Phase_Start_Date__c, ' +
	                       'CSM_Contact__c, ' +
						   'CSM_Manager__c, ' +
						   'CSM_Exec_Sponsor__c, ' +
						   'CSM_Renewal_Contact__c, ' +
						   'CSM_Renewal_Manager__c, ' +
						   'CSM_Support_Contact__c,	' + 
						   'CSM_Customer_Success_Manager__c, ' + 
						   newUserLkpsAcctPlanFldsStr + 
						   'Id, CSM_AccountId__r.Name FROM CSM_Account_Plan__c WHERE ID = :id LIMIT 1';   
					tmpList = Database.query(soqlForAcctPlan);
			} else if (String.isNotBlank(accountId)){
					/*tmpList =  [SELECT CSM_DisplayName__c,
		 				  	   CSM_AccountId__c, 
		                       CSM_Account_Plan_Template__c,
		                       CSM_Renewal_Date__c,
	                       	   CSM_Account_Owner_Id__c,		                       
		                       CSM_Account_Manager__c,
		                       CSM_Phase_Start_Date__c,
		                       CSM_Contact__c,
							   CSM_Manager__c,
							   CSM_Exec_Sponsor__c,
							   CSM_Renewal_Contact__c,
							   CSM_Renewal_Manager__c,
							   CSM_Support_Contact__c,	
							   CSM_Customer_Success_Manager__c,						   	         
		                       Id,
							   CSM_AccountId__r.Name
		                  FROM CSM_Account_Plan__c 
		                 WHERE CSM_AccountId__c =: accountId LIMIT 1];*/
		           String soqlForAcctPlan = 'SELECT CSM_DisplayName__c, ' + 
	 				  	   'CSM_AccountId__c, ' +  
	                       'CSM_Account_Plan_Template__c, '+
	                       'CSM_Renewal_Date__c, ' + 
	                       'CSM_Account_Owner_Id__c, ' + 
	                       'CSM_Account_Manager__c, ' +
	                       'CSM_Phase_Start_Date__c, ' +
	                       'CSM_Contact__c, ' +
						   'CSM_Manager__c, ' +
						   'CSM_Exec_Sponsor__c, ' +
						   'CSM_Renewal_Contact__c, ' +
						   'CSM_Renewal_Manager__c, ' +
						   'CSM_Support_Contact__c,	' + 
						   'CSM_Customer_Success_Manager__c, ' + 
						   newUserLkpsAcctPlanFldsStr + 
						   'Id, CSM_AccountId__r.Name FROM CSM_Account_Plan__c WHERE CSM_AccountId__c =: accountId LIMIT 1';
  
					tmpList = Database.query(soqlForAcctPlan);

			}
	    	return tmpList;
	    }
        else
        {
        	String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		String[] arguments2 = new String[] {CSM_Constants.OBJ_ACCOUNT + ':'+String.valueOf(noAccessAcctFieldList)};
    		String[] arguments3 = new String[] {CSM_CONSTANTS.OBJ_APT + ':'+String.valueOf(noAccessTemplateFieldList)};
    		
    		arguments.addAll(arguments2);
    		arguments.addAll(arguments3);
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
			System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));     	 
        }
        return tmpList;	
	}
	
	public static CSM_Account_Plan__c getAccountPlan(String accountId, String acctPlanTemplateId)
	{
		CSM_Account_Plan__c acctPlan = new CSM_Account_Plan__c();
		List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT_MANAGER,
			CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR, CSM_Constants.OBJ_AP_END_DATE, 
			CSM_Constants.OBJ_AP_PHASE_START_DATE, CSM_Constants.OBJ_AP_START_DATE, 
			CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE, 
			CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE};
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
                
        List<String> aptFieldList = new List<String>
						{CSM_Constants.OBJ_APT_OPP_DATES_TIMELINES, CSM_Constants.OBJ_APT_OPP_DATE};
        List<String> noAccessFieldList1 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APT,
									CSM_Constants.DML_OPERATION_READ, aptFieldList);
		//MF added                
        if (noAccessFieldList.isEmpty() && noAccessFieldList1.isEmpty())
        //if (noAccessFieldList.isEmpty() )
        {
        	List<CSM_Account_Plan__c> acctPlanList = [SELECT CSM_Account_Manager__c,
        	                                                 CSM_Customer_Success_Manager__c,
        	                                                 CSM_End_Date__c,
        	                                                 CSM_DisplayName__c,
                                                             CSM_Phase_Start_Date__c,
        	                                                 CSM_Start_Date__c, 
         	                                                 CSM_Account_Plan_Template__c,
        	                                                 CSM_Account_Plan_Template__r.CSM_Opp_Date__c
        	                                            FROM CSM_Account_Plan__c
        	                                           WHERE CSM_AccountId__c = :accountId
        	                                             AND CSM_Account_Plan_Template__c = :acctPlanTemplateId
        	                                             limit 1];
        	if (!acctPlanList.isEmpty())
        	{
        		return acctPlanList[0];
        	}
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList),
        	 				CSM_Constants.OBJ_APT + ':'+String.valueOf(noAccessFieldList1) };
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return 	acctPlan;
	}
	
	public static List<CSM_Account_Plan__c> getDetailFieldSet(String acctPlanId)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
		List<String> acctPlanFieldList = new List<String>();
		Id localAcctPlanId = acctPlanId;
		boolean firstField = true;
		String queryString = 'SELECT ';
		String nameSpace = CSM_Util.getNamespace();
        for(Schema.FieldSetMember fld :SObjectType.CSM_Account_Plan__c.FieldSets.CSM_Account_Plan_Details.getFields()) 
        {
        	String fldStr = fld.getFieldPath();
        	if (nameSpace!=null && nameSpace.length()>0){
        		fldStr = fldStr.replace(nameSpace, '');
        	}
        	acctPlanFieldList.add(fldStr);
        	if (firstField)
        	{
        		queryString += fldStr;
        		firstField = false;
        	}
        	else 
        	{
                queryString += ', ' + fldStr;
        	}
        }
        if (!queryString.contains(CSM_Constants.OBJ_AP_PHASE_START_DATE)){
        	queryString += ', '+CSM_Constants.OBJ_AP_PHASE_START_DATE;
        }
        if (!queryString.contains(CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE)){
        	queryString += ', '+CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE;
        }
        queryString += ' FROM CSM_Account_Plan__c WHERE Id = :localAcctPlanId LIMIT 1';   
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
        if (noAccessFieldList.isEmpty())
        {    
            tmpList = Database.query(queryString);
            return tmpList;
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tmpList;
	}
	
	//Added by MF
	public static List<CSM_Account_Plan__c> getActiveAccountPlans(Set<Id> accountList, List<String> fieldsToCheck)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
			
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, fieldsToCheck);
		if(noAccessFieldList.isEmpty())
        {
        	String soql;
        	
        	if (!fieldsToCheck.isEmpty()){
        		if (fieldsToCheck.size()>1){  
        			String accountPlanFieldsForSoql = '';
        			for (String s : fieldsToCheck) {
        				accountPlanFieldsForSoql = accountPlanFieldsForSoql + s + ', ';
        			}  		 
        			/*soql = 'Select id, CSM_AccountId__c, CSM_Account_Plan_Template__c , CSM_DisplayName__c, ' + 
						  'CSM_Account_Owner_Id__c, CSM_Customer_Success_Manager__c, CSM_Account_Manager__c, ' + 
						  'CSM_Contact__c, CSM_Manager__c, CSM_Exec_Sponsor__c, CSM_Renewal_Contact__c, ' +
						  'CSM_Renewal_Manager__c, CSM_Support_Contact__c from CSM_Account_Plan__c ' + 
					      'where CSM_accountId__c in :accountList and CSM_IsActive__c = true limit 200';*/
					soql = 'Select ' + accountPlanFieldsForSoql + 'CSM_DisplayName__c ' + 
						  'from CSM_Account_Plan__c ' + 
					      'where CSM_accountId__c in :accountList and CSM_IsActive__c = true limit 200';
        		} else {
        			soql = 'Select id, CSM_AccountId__c from CSM_Account_Plan__c ' + 
					      'where CSM_accountId__c in :accountList and CSM_IsActive__c = true limit 200';
        		} 
        		tmpList = database.query(soql);
        	}
			
        }
        else
        {
    	 	String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
		 	throw new CSM_AccessController.AccessControlDmlException( String.format(
		 	System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
		return tmpList;
	}

	//Added by MF
	public static List<CSM_Account_Plan__c> getActiveAccountPlans(Set<Id> accountList)
	{		
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
		List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT,
			CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE, CSM_Constants.OBJ_AP_ACCOUNT_OWNER_ID,
			CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR, CSM_Constants.OBJ_AP_ACCOUNT_MANAGER, 
			CSM_Constants.OBJ_AP_CSM_CONTACT, CSM_Constants.OBJ_AP_CSM_MANAGER,
			CSM_Constants.OBJ_AP_EXEC_SPONSOR, CSM_Constants.OBJ_AP_RENEWAL_CONTACT,
			CSM_Constants.OBJ_AP_RENEWAL_MANAGER, CSM_Constants.OBJ_AP_SUPPORT_CONTACT,
        	CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_AP_ID};
        Map<String, String> userLkpsForTaskMap = CSM_Util.getUserLookupsForSObject(CSM_Constants.OBJ_AP);
        if (userLkpsForTaskMap != null && !userLkpsForTaskMap.isEmpty()) {
        	for (String fldAPIName : userLkpsForTaskMap.keySet()) {
        		acctPlanFieldList.add(fldAPIName);
        	}
        }	
        return getActiveAccountPlans(accountList, acctPlanFieldList);
	}
	
	public static List<CSM_Account_Plan__c> getFilterBasedAccountPlans(String filterAttribute, Id userLookUpId)
	{		
		List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT,
			CSM_Constants.OBJ_AP_ACCOUNT_OWNER_ID,
			CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR, CSM_Constants.OBJ_AP_ACCOUNT_MANAGER, 
			CSM_Constants.OBJ_AP_CSM_CONTACT, CSM_Constants.OBJ_AP_CSM_MANAGER,
			CSM_Constants.OBJ_AP_EXEC_SPONSOR, CSM_Constants.OBJ_AP_RENEWAL_CONTACT,
			CSM_Constants.OBJ_AP_RENEWAL_MANAGER, CSM_Constants.OBJ_AP_SUPPORT_CONTACT,
        	CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_AP_ID};
        Map<String, String> userLkpsForTaskMap = CSM_Util.getUserLookupsForSObject(CSM_Constants.OBJ_AP);
        String accountPlanFieldsForSoql = '';
        if (userLkpsForTaskMap != null && !userLkpsForTaskMap.isEmpty()) {
        	for (String fldAPIName : userLkpsForTaskMap.keySet()) {
        		acctPlanFieldList.add(fldAPIName);
        		accountPlanFieldsForSoql = accountPlanFieldsForSoql + fldAPIName + ', ';
        	}
        }	
	
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
		if(noAccessFieldList.isEmpty())
        {
                
			/*String queryString = 'select id, CSM_AccountId__c, CSM_DisplayName__c, CSM_Account_Owner_Id__c,' +  
								'CSM_Customer_Success_Manager__c, CSM_Account_Manager__c,' + 
							  	'CSM_Contact__c, CSM_Manager__c, CSM_Exec_Sponsor__c, CSM_Renewal_Contact__c,' + 
							    'CSM_Renewal_Manager__c, CSM_Support_Contact__c from CSM_Account_Plan__c '; */
			String queryString = 'Select ' + accountPlanFieldsForSoql + 'CSM_DisplayName__c, CSM_AccountId__c ' + 
						  'from CSM_Account_Plan__c ';
			if(String.isNotBlank(filterAttribute) ){
				if(userLookUpId != null){
            		queryString += ' WHERE ' + filterAttribute + ' = ' + ' \'' + userLookUpId + '\' LIMIT 3000';
				}
				else{
					queryString += ' WHERE ' + filterAttribute + ' = null LIMIT 3000';
				}
            	system.debug('dbQuery:::' + queryString);
            	return Database.query(queryString);            	
            } 					   
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
		return null;
		
	}	
	
	public static void updateAccountPlan(List<CSM_Account_Plan__c> updatePlan)
	{
		 List<String> acctPlanFieldList = new List<String>();
		 String nameSpace = CSM_Util.getNamespace();
		 Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.CSM_Account_Plan__c.fields.getMap();
		 for(Schema.FieldSetMember fld :SObjectType.CSM_Account_Plan__c.FieldSets.CSM_Account_Plan_Details.getFields()) 
         {
        	String fldStr = fld.getFieldPath();
        	if (nameSpace!=null && nameSpace.length()>0){
        		fldStr = fldStr.replace(nameSpace, '');
        	}
        	Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fldStr).getDescribe();
        	if(fieldDescribe.isAccessible() && 
        		fieldDescribe.isCreateable() &&
        		fieldDescribe.isUpdateable()){
        		acctPlanFieldList.add(fldStr);
        	}
         }
         List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_UPDATE, acctPlanFieldList);
        if (noAccessFieldList.isEmpty())
        {    
            update updatePlan;
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
        }
	}
	
	public static List<CSM_Account_Plan__c> getAccountFieldSet(String acctPlanId)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
		List<String> acctPlanFieldList = new List<String>();
		Id localAcctPlanId = acctPlanId;
		boolean firstField = true;
		String queryString = 'SELECT ';
		String nameSpace = CSM_Util.getNamespace();
        for(Schema.FieldSetMember fld :SObjectType.CSM_Account_Plan__c.FieldSets.CSM_Account_Widget_FieldSet.getFields()) 
        {
        	String fldStr = fld.getFieldPath();
        	if (nameSpace!=null && nameSpace.length()>0){
        		fldStr = fldStr.replace(nameSpace, '');
        	}
        	acctPlanFieldList.add(fldStr);
        	if (firstField)
        	{
        		queryString += fld.getFieldPath();
        		firstField = false;
        	}
        	else 
        	{
                queryString += ', ' + fld.getFieldPath();
        	}
        }
        queryString += ' from ' + (nameSpace!=null && nameSpace.length()>0?nameSpace:'') +'CSM_Account_Plan__c where Id = :localAcctPlanId LIMIT 1';  
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
        if (noAccessFieldList.isEmpty())
        {    
            tmpList =  Database.query(queryString);
            return tmpList;
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
        return tmpList;	
	}
	
	public static List<CSM_Account_Plan__c> getAccountPlansById(Map<String, CSM_Play_Result__c> accountId)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, 
		         CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE,
		         CSM_Constants.OBJ_AP_ACCOUNT_MANAGER, CSM_Constants.OBJ_AP_SUPPORT_CONTACT,
		         CSM_Constants.OBJ_AP_RENEWAL_MANAGER, CSM_Constants.OBJ_AP_EXEC_SPONSOR,
		         CSM_Constants.OBJ_AP_ACCOUNT_OWNER, CSM_Constants.OBJ_AP_CSM_MANAGER,
		         CSM_Constants.OBJ_AP_RENEWAL_CONTACT, CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR,
		         CSM_Constants.OBJ_AP_CSM_CONTACT, CSM_Constants.OBJ_AP_ACCOUNT_OWNER};
		Map<String, String> userLkpsForTaskMap = CSM_Util.getUserLookupsForSObject(CSM_Constants.OBJ_AP);
		String newUserLkpsAcctPlanFldsStr = '';
        if (userLkpsForTaskMap != null && !userLkpsForTaskMap.isEmpty()) {
        	for (String fldAPIName : userLkpsForTaskMap.keySet()) {
        		acctPlanFieldList.add(fldAPIName);
        		newUserLkpsAcctPlanFldsStr = newUserLkpsAcctPlanFldsStr + fldAPIName + ', ';
        	}
        }
        System.debug('newUserLkpsAcctPlanFldsStr ===' + newUserLkpsAcctPlanFldsStr);
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
                
        if (noAccessFieldList.isEmpty())
        { 
			/*tmpList = [SELECT Id, 
						   CSM_AccountId__c, 
						   CSM_AccountId__r.OwnerId,
						   CSM_Support_Contact__c, 
						   CSM_Renewal_Manager__c, 
						   CSM_Renewal_Contract_Health__c, 
						   CSM_Manager__c, 
						   CSM_Renewal_Contact__c,
						   CSM_Exec_Sponsor__c, 
						   CSM_Customer_Success_Manager__c,
						   CSM_Contact__c, 
						   CSM_Account_Owner__c, 
						   CSM_Account_Owner_Id__c, 
						   CSM_Account_Manager__c, 
                           CSM_DisplayName__c,
						   CSM_Account_Plan_Template__c  
					  FROM CSM_Account_Plan__c
                     WHERE CSM_AccountId__c IN :accountId.keySet() LIMIT 1000];*/
            Set<String> acctIdSet = new Set<String>();
            if (accountId != null && !accountId.isEmpty()) {
            	for (String acctId : accountId.keySet()) {
            		acctIdSet.add(acctId);
            	}
            }
            //acctIdSet.add(accountId.keySet());
            if (!acctIdSet.isEmpty()) {
				String soqlForAcctPlan = 'SELECT Id, ' + 
							   'CSM_AccountId__c, ' + 
							   'CSM_AccountId__r.OwnerId, ' + 
							   'CSM_Support_Contact__c, ' + 
							   'CSM_Renewal_Manager__c, ' + 
							   'CSM_Renewal_Contract_Health__c, ' + 
							   'CSM_Manager__c, ' + 
							   'CSM_Renewal_Contact__c, ' + 
							   'CSM_Exec_Sponsor__c, ' + 
							   'CSM_Customer_Success_Manager__c, ' + 
							   'CSM_Contact__c, ' + 
							   'CSM_Account_Owner__c, ' + 
							   'CSM_Account_Owner_Id__c, ' + 
							   'CSM_Account_Manager__c, ' + 
	                           'CSM_DisplayName__c, ' + 
	                           newUserLkpsAcctPlanFldsStr + 
							   'CSM_Account_Plan_Template__c ' + 						   
							   'FROM CSM_Account_Plan__c ' + 
							   'WHERE CSM_AccountId__c IN :acctIdSet LIMIT 1000'; 
				System.debug('soqlForAcctPlan===' + soqlForAcctPlan) ; 
				tmpList = Database.query(soqlForAcctPlan);
            }
	    	return tmpList;
	    }
        else 
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tmpList;
	}
	
	public static List<CSM_Account_Plan__c> getAccountPlansByTemplateId(String acctPlanTemplateId)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, 
		         CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
                
        if (noAccessFieldList.isEmpty())
        { 
			tmpList = [SELECT Id,  
						   CSM_DisplayName__c,
						   CSM_Account_Plan_Template__r.Id  
					  FROM CSM_Account_Plan__c
					 WHERE CSM_Account_Plan_Template__r.Id = :acctPlanTemplateId LIMIT 10000];
	    	return tmpList;
	    }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tmpList;
	}
	
	public static List<CSM_Account_Plan__c> getAccountPlanById(String acctPlanId)
	{
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, 
		         CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
                
        if (noAccessFieldList.isEmpty())
        { 
			tmpList = [SELECT Id,  
						   CSM_DisplayName__c,
						   CSM_AccountId__c, 
						   CSM_Account_Owner_Id__c
					  FROM CSM_Account_Plan__c
					 WHERE Id = :acctPlanId LIMIT 1];
	    	return tmpList;
	    }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tmpList;
	}
	
	public static List<Account> getAccountsHavingPlan(Set<Id> accountIds)
	{
		List<Account> tmpList = new List<Account>();
        List<String> acctPlanFieldList = new List<String>{ CSM_Constants.OBJ_AP_ACCOUNT};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
                
        if (noAccessFieldList.isEmpty())
        { 
			if(accountIds == null){
			tmpList = [Select Id,CSM_Account_Has_Success_Plan__c from Account where Id IN (SELECT   
						   CSM_AccountId__c FROM CSM_Account_Plan__c)];
			} else{
			tmpList = [Select Id,CSM_Account_Has_Success_Plan__c from Account where Id IN (SELECT   
						   CSM_AccountId__c FROM CSM_Account_Plan__c where CSM_AccountId__c in :accountIds)];
			}
			
			return tmpList;
	    }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tmpList;
	}	
	
	public static List<Account> getAccountsNotHavingPlan(Set<Id> accountIds)
	{
		List<Account> tmpList = new List<Account>();
        List<String> acctPlanFieldList = new List<String>{ CSM_Constants.OBJ_AP_ACCOUNT};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_READ, acctPlanFieldList);
                
        if (noAccessFieldList.isEmpty())
        { 
			if(accountIds == null){
			tmpList = [Select Id,CSM_Account_Has_Success_Plan__c from Account where Id NOT IN (SELECT   
						   CSM_AccountId__c FROM CSM_Account_Plan__c)];
			} else{
			tmpList = [Select Id,CSM_Account_Has_Success_Plan__c from Account where Id NOT IN (SELECT   
						   CSM_AccountId__c FROM CSM_Account_Plan__c where CSM_AccountId__c in :accountIds)];
			}
			return tmpList;
	    }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tmpList;
	}	
	
	
	public static boolean setAccountsHavingPlanFlag(List<Account> acctList)
	{
		List<Account> tmpList = new List<Account>();
        List<String> acctFieldList = new List<String>{ CSM_Constants.ID_PARAM,CSM_Constants.OBJ_A_HAS_ACCOUNT_PLAN};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TYPE_ACCOUNT, 
                CSM_Constants.DML_OPERATION_UPDATE, acctFieldList);
                
        if (noAccessFieldList.isEmpty())
        { 
			update acctList;
			return true;
	    }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_TYPE_ACCOUNT + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
        }	
        return false;
	}	

	public static void updateAccountPlanList(List<CSM_Account_Plan__c> acctPlanList)
	{	
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_CURRENT_PHASE};
		
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_AP, 
                CSM_Constants.DML_OPERATION_UPDATE, acctPlanFieldList);
                
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, acctPlanFieldList, CSM_Constants.DML_OPERATION_UPDATE);        
        if (noAccessFieldList.isEmpty())
        { 
			update acctPlanList;
	    }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_AP + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
        }	
	}	
	
	public static Database.queryLocator getQueryLocatorAccountPlanBatch()
	{	
		List<String> apFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACTIVE};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, apFieldList, CSM_Constants.DML_OPERATION_READ);
		
		String namespace = CSM_Util.getNameSpace();
		
		String queryStr = 'SELECT Id,' + namespace + CSM_Constants.OBJ_AP_ACCOUNT + ' FROM ' + namespace + CSM_Constants.OBJ_TYPE_ACCOUNT_PLAN + ' where ' + namespace + CSM_Constants.OBJ_AP_ACTIVE +' = true';
		return Database.getQueryLocator(queryStr);
	}	
	
	public static List<csm_account_plan__c> getAccountPlansNotInPlanPlaybook() 
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_APP_ACCT_PLAN};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<String> apFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_APP_ACCT_TEMPLATE};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, apFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<csm_account_plan__c> accountPlanList = [select Id,CSM_Account_Plan_Template__c from csm_account_plan__c limit 50000] ;		
		return accountPlanList;
	}	
	
	public static List<CSM_Account_Plan__c> getAccountPlansByTemplateId(List<String> acctPlanTemplateLst){
		List<CSM_Account_Plan__c> tmpList = new List<CSM_Account_Plan__c>();
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, 
		         CSM_Constants.OBJ_AP_ACCOUNT, CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, acctPlanFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id,CSM_Account_Plan_Template__c 
					  FROM CSM_Account_Plan__c
					 WHERE CSM_Account_Plan_Template__c IN :acctPlanTemplateLst LIMIT 10000];
	    return tmpList;
	}
	
	public static List<CSM_Account_Plan__c> createSuccessPlans(List<CSM_Account_Plan__c> successPlans)
	{
		List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT, 
		         CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE, CSM_Constants.OBJ_AP_PHASE_START_DATE,
		         CSM_Constants.OBJ_AP_ACTIVE};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, acctPlanFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert successPlans;
		return successPlans;
	}
}