public with sharing class CSM_Util {
	private static String NAME_SPACE_CLASS_NAME = '';
	private static Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = new Map<String, Schema.Sobjecttype>();		
	private static ApexClass cs;
	private static Map<String, Decimal> CONVERSION_RATE = new Map<String, Decimal>();
	
	public enum FieldToSort {
        Label, Value
    }
    
	public static void doSort(List<Selectoption> opts, FieldToSort sortField) {
        
		Map<String, Selectoption> mapping = new Map<String, Selectoption>();
		// Suffix to avoid duplicate values like same labels or values are in inbound list 
		Integer suffix = 1;
		for (Selectoption opt : opts) {
		    if (sortField == FieldToSort.Label) {
		        mapping.put(	// Done this cryptic to save scriptlines, if this loop executes 10000 times
		        				// it would every script statement would add 1, so 3 would lead to 30000.
		        			 (opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
		        			 opt);   
		    } else {
		        mapping.put(	
		        			 (opt.getValue() + suffix++), // Key using Label + Suffix Countfer  
		        			 opt);   
		    }
		}
		
		List<String> sortKeys = new List<String>();
		sortKeys.addAll(mapping.keySet());
		sortKeys.sort();
		// clear the original collection to rebuilt it
		opts.clear();
		
		for (String key : sortKeys) {
		    opts.add(mapping.get(key));
		}
	}
	
	
	/** 
	* @description: Finds the namespace for the managed package.
	* @returns the namespace string.
	*/
	public static String getNamespace(){
		String nameSpacePrefix = '';
		if (cs==null){
			cs =[select NamespacePrefix from ApexClass where Name =:'CSM_Util' limit 1];
		}
		return (String.isNotBlank(cs.nameSpacePrefix) ?  cs.nameSpacePrefix + '__' :  '');
		 
	}

	/** 
	* @description: Finds all the Public Groups.
	* @returns the list of Group Ids.
	*/
	public static Map<String, String> getAllPublicGroups(){
		Map<String, String> publicGroups = new Map<String, String>();
		List<Group> groups =[select Id, Name, DeveloperName from Group where Type in ('PRMOrganization', 'Organization', 'Regular', 'AllCustomerPortal')];
		for(Group grp: groups){
			if(!String.isEmpty(grp.Name)){
				publicGroups.put(grp.Id,grp.Name);			
			}else{
				publicGroups.put(grp.Id,grp.DeveloperName);			
			}
		}

		return publicGroups;
	}

	/** 
	* @description: Finds all the Roles.
	* @returns the list of Role Ids.
	*/
	public static Map<String,Map<String,String>> getAllRoles(){
		Map<Id,UserRole> userRolesMap = new Map<Id,UserRole>([select Id, rollupdescription,DeveloperName,PortalType from UserRole]);
		
        Map<String,Map<String,String>> userTypeToGroupIdnNameMap = new Map<String,Map<String,String>>();
		List<Group> groups =[select Id, DeveloperName,relatedId from Group where type = 'role' and RelatedId in (select Id from UserRole)];	
        if(userRolesMap != null && !userRolesMap.isEmpty()){
            for(Group grp: groups){
                if(userRolesMap.containsKey(grp.relatedId)){
                    String name = (String.isEmpty(userRolesMap.get(grp.relatedId).rollupdescription) ? userRolesMap.get(grp.relatedId).DeveloperName : userRolesMap.get(grp.relatedId).rollupdescription);
                    if(userRolesMap.get(grp.relatedId).PortalType == 'Partner'){
                        if(userTypeToGroupIdnNameMap.containsKey('Partner')){
                            userTypeToGroupIdnNameMap.get('Partner').put(grp.Id,name);
                        }else{
                            userTypeToGroupIdnNameMap.put('Partner', new Map<String,String>{grp.Id=>name});
                        }
                    }else{
                        if(userTypeToGroupIdnNameMap.containsKey('Internal')){
                            userTypeToGroupIdnNameMap.get('Internal').put(grp.Id,name);
                        }else{
                            userTypeToGroupIdnNameMap.put('Internal', new Map<String,String>{grp.Id=>name});
                        }
                    }
                        
                }
            }
        }

		return userTypeToGroupIdnNameMap;
	}


	/** 
	* @description: Finds all the Role and Subordinate.
	* @returns the list of Role and Subordinate Ids.
	*/
	public static Map<String, String> getAllRoleAndSubordinates(){
		Map<String, String> rolesAndSubordinates = new Map<String, String>();
		Map<String, String> userRoleNames = new Map<String, String>();		
		List<UserRole> userRoles =[select Id, rollupdescription,DeveloperName from UserRole where PortalType != 'Partner'];
		for(UserRole usrRole:userRoles){
			if(!String.isEmpty(usrRole.rollupdescription)){
				userRoleNames.put(usrRole.Id, usrRole.rollupdescription);			
			}else{
				userRoleNames.put(usrRole.Id, usrRole.DeveloperName);			
			}
		}

		List<Group> groups =[select Id, DeveloperName, relatedid from Group where type = 'roleandsubordinates' and RelatedId in (select Id from UserRole where PortalType != 'Partner')];
		for(Group grp: groups){
			rolesAndSubordinates.put(grp.Id,userRoleNames.get(grp.relatedId));			
		}

		return rolesAndSubordinates;
	}
	
	public static Boolean getRecordTypeExists(SObject sObj){
		Boolean recordTypeExists = false;
		//Schema.DescribeSObjectResult objectResult = Task.sObjectType.getDescribe();
 		Schema.DescribeSObjectResult objectResult = sObj.getSObjectType().getDescribe();		
		List<Schema.RecordTypeInfo> recordTypeList = objectResult.getRecordTypeInfos();
		for(Schema.RecordTypeInfo option :recordTypeList) {
			if(option.isDefaultRecordTypeMapping() && option.getName() != 'Master' && option.isAvailable()) {
				recordTypeExists = true;
				break;
			}
		}
		return recordTypeExists;		
	}
	
	private static String NAME_SPACE_OBJECT_NAME = '';
    static{
    	if (cs==null){
        	cs =[select NamespacePrefix from ApexClass where Name =:'CSM_Util' limit 1];
    	}
        if(!String.isBlank(cs.NamespacePrefix)){
            NAME_SPACE_OBJECT_NAME = cs.NamespacePrefix + '__';             
            NAME_SPACE_CLASS_NAME = cs.NamespacePrefix + '.';               
        }
    }
	
	/** This method returns corresponds to the specified fully qualified class name.
    * @param: apiNameStr - API name
    * @param: delimiterStr - For Object, fields, FieldSet it should be '__' and for class name it should be '.'. 
    * @param: isCustomCheckRequired; if TRUE: Add Prefix only if apiNameStr ends with '__c'; if FALSE: Add Prefix for all apiNameStr
    * @return: corresponds to the specified fully qualified class name
    */
    public static String getNameWithNameSpace(String apiNameStr, String delimiterStr, boolean isCustomCheckRequired){
        // In a managed package the SObjectType will be 'Prefix__SomeCustomObject__c' and in unmanaged it will just be 'SomeCustomObject__c'
        String apiName = '';
        String nameSpacePrefix = '';
        
        if(!String.isBlank(NAME_SPACE_OBJECT_NAME)){//Name Space is available
            if(delimiterStr == '.'){//For NameSpace with Dot (.)
                if(!apiNameStr.startsWith(NAME_SPACE_CLASS_NAME)){
                    if(isCustomCheckRequired){
                        if(apiNameStr.endsWith('__c')){
                            apiName = NAME_SPACE_CLASS_NAME; // Add Prefix only if apiNameStr ends with '__c'  
                        }
                    }else{
                        apiName = NAME_SPACE_CLASS_NAME;
                    }
                }
            }else{//For NameSpace with double underscore (__)
                if(!apiNameStr.startsWith(NAME_SPACE_OBJECT_NAME)){
                    if(isCustomCheckRequired){
                        if(apiNameStr.endsWith('__c')){
                            apiName = NAME_SPACE_OBJECT_NAME; // Add Prefix only if apiNameStr ends with '__c'  
                        }
                    }else{
                        apiName = NAME_SPACE_OBJECT_NAME;
                    }
                }
                
            }
        }
    
        apiName += apiNameStr;
        return apiName;
    }
    
    /** 
    * @description This method sorts a SelectOption by Label rather than Value.  Sorting by the Value is the defualt for Salesforce
    * @param apiNameStr - API name   
    */
    public static void sortSelectOptionByLabel(List<SelectOption> opts) 
    {
    	Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        for (Selectoption opt : opts) {
        
                mapping.put((opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
                			 opt);   
        
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
        sortKeys.sort();
        // clear the original collection to rebuild it
        opts.clear();
        
        for (String key : sortKeys) {
            opts.add(mapping.get(key));
        }
    }
    
    public static void sortSelectOptionByLabelRelatedFields(List<SelectOption> opts) 
    {
    	Map<String, Selectoption> mapping = new Map<String, Selectoption>();
    	Map<String, Selectoption> relatedMapping = new Map<String, Selectoption>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        Integer relatedSuffix = 1;
        for (Selectoption opt : opts) {
        	if(opt.getLabel().contains(':')){
        			relatedMapping.put((opt.getLabel() + relatedSuffix++), // Key using Label + Suffix Counter  
                			 			opt);
        	}else {
       	         mapping.put((opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
                			 opt);
        	}   
        
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
        sortKeys.sort();
        
        List<String> sortRelatedKeys = new List<String>();
        sortRelatedKeys.addAll(relatedMapping.keySet());
        sortRelatedKeys.sort();
        // clear the original collection to rebuild it
        opts.clear();
        
        for (String key : sortKeys) {
            opts.add(mapping.get(key));
        }
        
        for (String key : sortRelatedKeys) {
            opts.add(relatedMapping.get(key));
        }
        
    }
	
	public static String getColumns(String selectedObject){
		String columns = '';
		List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(selectedObject);
        for( Schema.SObjectField tmpfield :fieldList)
        {     
        	if (columns.length()==0){
        		columns += tmpField.getDescribe().getName().toLowerCase();
        	} else {
        		columns += ', '+ tmpField.getDescribe().getName().toLowerCase();
        	}
        }  
        return columns;
	}

	public static Set<String> getColumnsNames(String selectedObject){
		Set<String> columnsNameSet = new Set<String>();
		List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(selectedObject);
        for( Schema.SObjectField tmpfield :fieldList){     
        	columnsNameSet.add(tmpField.getDescribe().getName());
        }  
        return columnsNameSet;
	}

    /**
	* 
	* @description getFilterEditPage Get the list views based on object changes through standard list view page
	* 
	* @return String 
	* 
	*/
	public static String getFilterEditPage(String val, Boolean isEdit, String retURL, String focusCategoryObjectType) {
		
		String filterEditPage = '';
			
		// Check object type 
		if (focusCategoryObjectType!=null && focusCategoryObjectType.length()>0) {
			PageReference pageRef = Page.CSM_FocusCategoryView;
			filterEditPage = pageRef.getURL()+ (isEdit?CSM_Constants.ID_VAL+val:'?'+CSM_Constants.OBJ_TYPE+'='+focusCategoryObjectType) + CSM_Constants.PARAM_CANCEL_URL + retURL; 
		}
		return filterEditPage; 
	}	
	
	public static void sendEmail(String email, String message){
		
		// Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Assign the addresses for the To mail object.
        mail.setToAddresses(new string[]{email});
        
        // Specify the subject line for your email address.
        mail.setSubject('New Plays created');
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(message.replace('<br/>', '/n'));
        
        // Specify the HTML content of the email.
        mail.setHtmlBody(message);
         
        // Send the email that is created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	
	}
	
	private static String kHexChars = '0123456789abcdef';

    public static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    private static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }
    
    /**
	  * Returns the map with the fields of the given sobjectName
	  *
	  * @param sobjectName name of the sobject
	  * @returns fieldsMap map with all the fields of the sobject
	  */
	 public static Map < String, Schema.SObjectField > GetSObjectFieldsMap(String sobjectName) {
	
	     Map < String, Schema.SObjectField > fieldsMap = new Map < String, Schema.SObjectField > ();
	     Map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();
	     if (gd.containsKey(sobjectName)) {
	         fieldsMap = gd.get(sobjectName).getDescribe().fields.getMap();
	     }
	     return fieldsMap;
	 }
	 
	/**
     * Returns true if its an Admin user 
     * @param
     * @return boolean if user is an 'System Administrator'.
     */
    public static Boolean isUserAnSystemAdmin() {
      Boolean  isSysAdmin = false;
      List<String> pFieldList = new List<String>{'Id', 'Name'};
      CSM_Util.checkCRUD_FLS('Profile', pFieldList, CSM_Constants.DML_OPERATION_READ);
      Profile p = [Select p.Name, p.Id From Profile p where p.Id =: UserInfo.getProfileId() limit 1];
    	if (p.Name.contains(CSM_Constants.SYSTEM_ADMIN_NAME)) {
    	   isSysAdmin = true;
    	}
    	return isSysAdmin;
    }
    
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
    	//return getCreatableFieldsSOQL(objectName, '', whereClause);
    	//Eswar Bala - Removing above call because of Good Tech fix.
    	return getSOQLString(objectName, null, whereClause, null, null);
    }
    
    //Eswar Bala - 07/30/2015
    //Good Tech fix
    //Returns a dynamic SOQL statement for the whole object, for select Field Types 
    //For field types supported, look for the article https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm
    //IMPORTANT: This method will return all fields with the fieldTypes requested & also ones with the requested properties 
    //			 - it is not meant for checking if all the fields retrieved by type are also have all the properties requested for
    //			 - the superset of field types, properties and knownFields will be sent back

    public static String getSOQLString(String objectName, set<String> knownFields, String whereClause, set<String> fieldTypes, set<String> requestedProperties)
    {
    	String soqlStr = '';    	
    	
	    List<String> combinedRequestedFieldsList = getSOQLFieldsCollection(objectName, knownFields, whereClause, fieldTypes, requestedProperties);
	    //Changing above to be more elegant
	    
	    if(!combinedRequestedFieldsList.isEmpty())
	    {
	    	soqlStr = String.join(combinedRequestedFieldsList, ',');
	    }
	    
	    if(String.isNotEmpty(soqlStr))	
	    {
	    	if(UserInfo.isMultiCurrencyOrganization() && !soqlStr.contains(REN_Constants.REN_CURRENCY_ISO_CODE))
	    	{
	    		soqlStr = REN_Constants.REN_CURRENCY_ISO_CODE + ', ' + soqlStr;//US452
	    	}
	    
		    if(whereClause == null || whereClause == '')
		    {
		    	soqlStr = 'SELECT ' + soqlStr + ' FROM ' + objectName;
		    }
		    else
		    {
		    	soqlStr = 'SELECT ' + soqlStr + ' FROM ' + objectName + ' WHERE ' + whereClause;
		    }
	    }
    	return soqlStr;
    } 
    
    public static List<String> getSOQLFieldsCollection(String objectName, set<String> knownFields, String whereClause, set<String> fieldTypes, set<String> requestedProperties)
    {
    	system.debug('objectName : ' + objectName + ' - ' + 'knownFields : ' + knownFields + ' - ' + 'whereClause : ' + whereClause + ' - ' + 'fieldTypes : ' + fieldTypes + ' - ' + 'requestedProperties : ' + requestedProperties);
    	String soqlStr = '';    	
    	//Get a map of field name and field token
	    Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
	    
	    set<String> combinedRequestedFields = new set<String>();
	    system.debug('fMap : '  + fMap);
	    if(fMap != null)
	    {
	        //The following is not a true representation of 'anytype'  .. it includes in addition to those defined by salesforce, 'reference' & 'currency'
	        if(fieldTypes != null && !fieldTypes.isEmpty() && fieldTypes.contains('anytype'))
	        {
				fieldTypes.add('string');
		        fieldTypes.add('picklist');
		        fieldTypes.add('boolean');
		        fieldTypes.add('integer');
		        fieldTypes.add('double');
		        fieldTypes.add('percent');
		        fieldTypes.add('reference');
		        fieldTypes.add('id');
		        fieldTypes.add('date');
		        fieldTypes.add('datetime');
		        fieldTypes.add('url');
		        fieldTypes.add('email');
		        fieldTypes.add('textarea');
		        fieldTypes.add('currency');
		        fieldTypes.add('longtextarea');
		        fieldTypes.add('phone');
		        fieldTypes.add('multipicklist');
	        }
	        for(Schema.SObjectField ft : fMap.values()) //loop through all field tokens (ft)
	        { 
	            Schema.DescribeFieldResult fd = ft.getDescribe(); //describe each field (fd)
	            //system.debug( fd.getName() + ' fd.isAccessible() :  ' + fd.isAccessible() + ', Field-Type: ' + fd.getType());
	            if(fd.isAccessible())
	            { 
	                if(fieldTypes != null && !fieldTypes.isEmpty())
	                {
	                	//system.debug('Contains Fieldtype : ' + fieldTypes.contains((String.valueOf(fd.getType())).toLowerCase()) + ' - ' + fd.getType() + ' - ' + fd.getName());
	                }
	                if(fieldTypes != null && !fieldTypes.isEmpty() && fieldTypes.contains((String.valueOf(fd.getType())).toLowerCase())){
	                	combinedRequestedFields.add(fd.getName());
	                	//Added for Object which is not having Name Fields on Lookup relationship.
	                    if(String.valueOf(fd.getType()).equalsIgnoreCase(String.valueOf(Schema.DisplayType.Reference))){
	                    	List<Schema.SObjectType> oTypeList = fd.getReferenceTo();
            				if(!oTypeList.isEmpty()){
            					String refObjName = oTypeList[0].getDescribe().getName();
            					if(CSM_AccessController.hasField(refObjName, 'Name')){
            						combinedRequestedFields.add(fd.getRelationshipName() + '.Name');
            					}
            				}
	                	}
	                }
	                if(knownFields != null && knownFields.contains(String.valueOf(ft)) && (String.valueOf(fd.getType())).toLowerCase() == 'picklist'){
	                	if(combinedRequestedFields != null && combinedRequestedFields.contains(String.valueOf(ft))){
	                		combinedRequestedFields.remove(String.valueOf(ft));
	                	}
	                	combinedRequestedFields.add('toLabel('+String.valueOf(ft)+')');
	                	knownFields.remove(String.valueOf(ft));
	                }
	                if(requestedProperties != null && !requestedProperties.isEmpty())
	                {
		                //Check for different properties
						
		                if(requestedProperties.contains('isAutoNumber') && fd.isAutoNumber())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isCalculated') && fd.isCalculated())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isCascadeDelete') && fd.isCascadeDelete())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isCaseSensitive') && fd.isCaseSensitive())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isCreateable') && fd.isCreateable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isCustom') && fd.isCustom())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isDefaultedOnCreate') && fd.isDefaultedOnCreate())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isDependentPicklist') && fd.isDependentPicklist())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isDeprecatedAndHidden') && fd.isDeprecatedAndHidden())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isExternalID') && fd.isExternalID())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isFilterable') && fd.isFilterable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isGroupable') && fd.isGroupable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isHtmlFormatted') && fd.isHtmlFormatted())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isIdLookup') && fd.isIdLookup())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isNameField') && fd.isNameField())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isNamePointing') && fd.isNamePointing())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isNillable') && fd.isNillable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }   
		                if(requestedProperties.contains('isPermissionable') && fd.isPermissionable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isRestrictedDelete') && fd.isRestrictedDelete())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isRestrictedPicklist') && fd.isRestrictedPicklist())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isSortable') && fd.isSortable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isUnique') && fd.isUnique())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isUpdateable') && fd.isUpdateable())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
		                if(requestedProperties.contains('isWriteRequiresMasterRead') && fd.isWriteRequiresMasterRead())
		                {
		                	combinedRequestedFields.add(fd.getName());
		                }
	                }
	            }
	            
	        }
	    }
		system.debug('combinedRequestedFields : ' + combinedRequestedFields);
		if(knownFields != null && !knownFields.isEmpty())
		{
			combinedRequestedFields.addAll(knownFields);
		}
		
		return new List<String>(combinedRequestedFields);
    } 
    
	public static List<String> getNonCrossObjectFields(List<String> knownFields){
		List<String> returnList = new List<String>();
		if(knownFields != null){
			for(String s: knownFields){
				if(String.isNotBlank(s) && !s.contains('.')){
					returnList.add(s);
				}
			}
		}
		return returnList;
	}
	
	public static String formatDatetimeString(String dateTimeString, String format){
		String formattedDateTime = null;
		Map <String, Integer> monthNames = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 
																		'Apr'=>4, 'May'=>5, 'Jun'=>6, 
																		'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 
																		'Oct'=>10, 'Nov'=>11, 'Dec'=>12};		
		if(dateTimeString != null && dateTimeString.contains(' '))	{	//added if condition for test class 
			List <String> stringParts = dateTimeString.split(' ');
			if(stringParts.size()>=3){
				List <String> timeParts = stringParts[3].split(':');
				DateTime convertedDateTime = DateTime.newInstance(Integer.valueOf(stringParts[5]), 
																monthNames.get(stringParts[1]), 
																Integer.valueOf(stringParts[2]), 
																Integer.valueOf(timeParts[0]), 
																Integer.valueOf(timeParts[1]), 
																Integer.valueOf(timeParts[2]));
				formattedDateTime = convertedDateTime.format(format);
			}
		}
		else	{
			formattedDateTime = dateTimeString;
		}
		return formattedDateTime;
	}
	 // Get a list of picklist values from an existing object field.
   public static list<SelectOption> getPicklistValues(SObject obj, String fld)
   {
     String fldName;
     //Start -- Added for US2419
	 if(fld.endsWithIgnoreCase('__c')){
     	fldName = fld.removeEndIgnoreCase('__c');
		if(!fldName.contains('__')){
            fld = getNamespace() + fld;
         }
	  }
      //End -- Added for US2419
      list<SelectOption> options = new list<SelectOption>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
   }
   
   public static Map<ID, String> getCurrentPahse (List<CSM_Account_Plan__c> successPlanList) {
   	return null;
   }
   
    /**
	  * Returns the map with the id of the given sobjectName
	  * @param sobjectName name of the sobject
	  * @returns Map map with the Ids and Current Phase of the sobject
	  */
	 public static Map<ID, String> getCurrentPhase (List<CSM_Account_Plan__c> successPlanList) {
	 	Set<ID> templateIdSet = new Set<ID>();
	 	for(CSM_Account_Plan__c sp: successPlanList){
	 		templateIdSet.add(sp.CSM_Account_Plan_Template__c );
	 	}
	 	
	 	Map<ID,CSM_Account_Plan_Phase__c> acctPlanPhaseMap = new Map<ID,CSM_Account_Plan_Phase__c>();
	 	
	 	//To retrive the Phases details with lenght of phases return the Map with TemplateId with PlanPhase Object
	 	Map<ID, CSM_Account_Plan_Template__c> accPlanTemplateWithPhasesMap = getPhases(templateIdSet);
	    Map<ID, String> returnPlanPhaseMap = new Map<ID, String>();
	    Date todaysDate = System.today();
	    
	    for(CSM_Account_Plan__c sp: successPlanList){
	     	if(accPlanTemplateWithPhasesMap.containsKey(sp.CSM_Account_Plan_Template__c)){
	     		CSM_Account_Plan_Template__c templateObj = accPlanTemplateWithPhasesMap.get(sp.CSM_Account_Plan_Template__c);
	     		List<CSM_Account_Plan_Phase__c> phaseList = templateObj.Account_Plan_Phases__r;	
	     		if(phaseList != null && !phaseList.isEmpty()){
	     			String phaseName = '';
	     			Date phaseStartDate = sp.CSM_Phase_Start_date__c;
	     			Date phaseEndDate;
	     			
	     			if(todaysDate <  phaseStartDate){//If start date is in for future.
	     				returnPlanPhaseMap.put(sp.id,'');
	     			}else{//Find currect phase
		     			for(CSM_Account_Plan_Phase__c p: phaseList){
		     				Integer noOfDays = (Integer) p.CSM_Length__c;
		     				if(noOfDays != null){ 
		     					phaseEndDate = phaseStartDate.addDays(noOfDays);
		     						if(todaysDate <=  phaseEndDate){
	     								returnPlanPhaseMap.put(sp.id, p.CSM_Phase_Name__c);
	     								break;
		     						}
		     					phaseStartDate = phaseEndDate + 1;
		     				}//end of if
		     			} //end of for Loop
	     			
		     			if(phaseEndDate < todaysDate){//If all phases over
		     				returnPlanPhaseMap.put(sp.id,'');
		     			}
	     			}
	     		}else { //if no phases defined in the Business Plan
     				returnPlanPhaseMap.put(sp.id,'');
	     		}
	     			
     		}
     	}
	     
	     return returnPlanPhaseMap;
	 } 
	 
	 public static Map<ID, CSM_Account_Plan_Template__c> getPhases(Set<ID> templateIdSet) {	       
	    return CSM_AccountPlanTemplateDataAccess.getTemplateWithPhasesMap(templateIdSet);
	 }
     
    /***
    * @description get sObject list and return set<Id>.
    * @Param: sObject List.
    * @Return:  Set<Id> record Ids.
    ***/
    /*
    public static Set<Id> getIdSet(List<sObject> objectRecordList) {
        set<Id> idSet = new Set<Id> ();
         for (sObject obj:objectRecordList) {
            idSet.add(obj.Id);
        }
        return idSet;
    }
	*/
	/** 
	* @description: This method will return Record currency if isMultiCurrencyEnabled. If not enabled or input parameter is null it will return Default Currency
	* @Exception: SObjectException- SObject row was retrieved via SOQL without querying the requested field. Make sure if isMultiCurrencyEnabled, CurrencyIsoCode is available in input paramater object.
	*/
	public static String getAppliedCurrency(sObject sfObject){
		String currencyName; 
		if (UserInfo.isMultiCurrencyOrganization() && sfObject != null){
			currencyName = String.valueOf(sfObject.get('CurrencyIsoCode'));
		}else{
			currencyName = UserInfo.getDefaultCurrency(); 
		}
		//system.debug(sfObject + '\n\n~~~currencyName: ' + currencyName);
		return currencyName;
	}

	public static void setAppliedCurrency(sObject sfObject, String currencyName){
		if (UserInfo.isMultiCurrencyOrganization() && sfObject != null){
			sfObject.put('CurrencyIsoCode', currencyName);
		}
	}
	
	/** 
	* @description: Mainly created for US454 & US458 This method will return Record currency if isMultiCurrencyEnabled. If not enabled it will either return Default Currency symbol or blank 
	* @Exception: SObjectException- SObject row was retrieved via SOQL without querying the requested field. Make sure if isMultiCurrencyEnabled, CurrencyIsoCode is available in input paramater object.
	*/
	public static String getRecordLevelCurrency(sObject sfObject, boolean isDefaultCurrencyRequired){
		String currencyName = getAppliedCurrency(sfObject); 
		if (!UserInfo.isMultiCurrencyOrganization() ){
			if(isDefaultCurrencyRequired){
				currencyName = CSM_Util.convertCurrencyNameToSymbol(currencyName);
			}else{
				currencyName = '';
			}
		}			
		//system.debug(sfObject + '\n\n~~~currencyName: ' + currencyName);
		return currencyName;
	}
	
    /***
    * @description get conversion rate for currency.
    * @Param: String.
    * @Return: decimal.
    ***/
     public static Map<String, Decimal> getConversionRateMap(){
     	if(UserInfo.isMultiCurrencyOrganization() && CONVERSION_RATE.isEmpty()){
     		CSM_Util.checkCRUD_FLS('currencytype', new List<String>{'conversionrate', 'isocode'}, CSM_Constants.DML_OPERATION_READ);
			String querystring = 'SELECT conversionrate, isocode, IsCorporate FROM currencytype LIMIT 2000';
			List<SObject> currencylst = Database.query(queryString);
			for(SObject s: currencylst){
				CONVERSION_RATE.put((String)s.get('isocode'), (Decimal)s.get('conversionrate'));
			}
     	}
     	return CONVERSION_RATE;
     }
     
     public static List<SObject> getAllActiveCurrenciesInAMultiCurrOrg() {
     	List<SObject> currencylst = new List<SObject>();
     	if(UserInfo.isMultiCurrencyOrganization()) {
     		CSM_Util.checkCRUD_FLS('currencytype', new List<String>{'isactive', 'isocode'}, CSM_Constants.DML_OPERATION_READ);
     		String querystring = 'SELECT isactive, isocode, IsCorporate FROM currencytype where isactive = true LIMIT 2000';
			currencylst = Database.query(queryString);
     	}
     	return currencylst;
     }
    
    public static List<Pricebook2> getAllActivePriceBooks() {
    	List<String> fcFieldList = new List<String>{'Id','Name'};
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PRICEBOOK, fcFieldList, CSM_Constants.DML_OPERATION_READ);
    	//Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
    	List<Pricebook2> pricebookLst = new List<Pricebook2>();
    	pricebookLst =	[Select id, Name, isStandard From Pricebook2 where isActive = true OR isStandard = true];
		return pricebookLst;
    }
     
     public static decimal getExchangeRateToCorpCurrency(String currencyName){
     	getConversionRateMap();
		Decimal exchangeRate = CONVERSION_RATE.get(currencyName);
		if (exchangeRate == null){
			exchangeRate = 1;
		}
        return exchangeRate;
    }
	
	public static Decimal currencyConversion(Decimal amount, String fromCurrency, String toCurrency){
		Decimal returnAmt = amount;
		if (UserInfo.isMultiCurrencyOrganization() && amount != null && amount != 0 &&  fromCurrency != toCurrency){
			Decimal fromCurrencyExchangeRate = CSM_Util.getExchangeRateToCorpCurrency(fromCurrency);
			Decimal toCurrencyExchangeRate = CSM_Util.getExchangeRateToCorpCurrency(toCurrency);
			returnAmt = amount * (toCurrencyExchangeRate / fromCurrencyExchangeRate);
		}
		return returnAmt;
	}
	
	
/***
    * @description get Currecncy Name and return Currency Symbol.
    * @Param: String.
    * @Return: String.
    ***/
	public static String convertCurrencyNameToSymbol(String currencyName)
	{
			Map<String,String> currencySymbolsMap;
			currencySymbolsMap = new Map<String,String>{'AUD' => 'AU$', 
    														'CAD' => 'CA$',
    														'EUR' => '€',
    														'GBP' => '£',
    														'MYR' => 'RM',
    														'NZD' => 'NZ$',
    														'SGD' => 'SG$',
    														'USD' => '$',
    														'ZAR' => 'R'};
			if(currencySymbolsMap.containsKey(currencyName))
			{
				String cSymbol = currencySymbolsMap.get(currencyName);
				return cSymbol;
			}
			else
			{
				return currencyName;
			}
		
		return null;
	}
    
    /***
    * @description get Currecncy Name and return Currency Symbol.
    * @Param: String.
    * @Return: String.
    ***/
    public static Boolean isDateTime(String dateTimeToCheck){
		Boolean isDatetimeVal = false;
    	try{
        	Datetime toCheck = Datetime.valueOf(dateTimeToCheck);
        	isDatetimeVal = true;
    	} catch (Exception ex){
		}
		return isDatetimeVal;
    }
        
    /***
    * @description get Currecncy Name and return Currency Symbol.
    * @Param: String.
    * @Return: String.
    ***/
    public static Boolean isDate(String dateToCheck){
		Boolean isDateVal = false;
    	try{
        	Date toCheck = Date.valueOf(dateToCheck);
        	isDateVal = true;
    	} catch (Exception ex){
		}
		return isDateVal;
    }

	public static String toggleSortDirection(String sortDirection){
    	if(CSM_Constants.SORT_DIRECTION_ASCENDING.equals(sortDirection)){
    		sortDirection = CSM_Constants.SORT_DIRECTION_DESCENDING;
    	}else{
    		sortDirection = CSM_Constants.SORT_DIRECTION_ASCENDING;
    	}
    	return sortDirection;
    }
    
    	
	//Scout Collector
	private static String SCOUT_ANALYTICS_URL = '';
	private static String PACKAGE_VERSION = '';
		

	/** 
	* SolutionExtension check
	* @description: Finds the namespace for the managed package.
	* @returns the namespace string.
	*/
	public static String nameSpaceOfAsperato{
		get {
			if (nameSpaceOfAsperato == null){
				nameSpaceOfAsperato = '';
				try{
					List<ApexClass> tr =[Select NamespacePrefix From ApexClass where Name = 'IGetAuthorisationsService' limit 1];
					if (tr!=null && !tr.isEmpty()){
						nameSpaceOfAsperato = (String.isNotBlank(tr[0].NamespacePrefix) ?  tr[0].NamespacePrefix + '__' :  '');
					}
				} catch(Exception ex) {
					
				}
			}
			return nameSpaceOfAsperato;
		}
		private set;
	}
	// CSM_Util.checkCRUD_FLS(objectApiName, new List<String>{}, CSM_Constants.DML_OPERATION_READ);
	public static void checkCRUD_FlsPermissions(String objectApiName, Set<String> fieldListForCRUD, String dmlOperationType) {
		CSM_Util.checkCRUD_FLS(objectApiName, new List<String>(fieldListForCRUD), dmlOperationType);
	}
	/**
		* @description: Check CRUD & FLS permissions.
		* @param String objectApiName
		* @param List<String> fieldListForCRUD
		* @param String dmlOperation
	*/	
	// CSM_Util.checkCRUD_FLS(objectApiName, new List<String>{}, CSM_Constants.DML_OPERATION_READ);
	public static void checkCRUD_FLS(String objectApiName, List<String> fieldListForCRUD, String dmlOperationType) {
		fieldListForCRUD = getNonCrossObjectFields(fieldListForCRUD);
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(objectApiName, dmlOperationType, fieldListForCRUD);
		if (!noAccessFieldList.isEmpty()){   
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             	System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, new String[] {objectApiName + ':'+String.valueOf(noAccessFieldList)}));
		}
	}
			
	/**
	* @description: gets the Scout Analytics URL.
	* @returns the URL string.
	*/	
	public static String getScoutAnalyticsUrl() {
		if (String.isEmpty(SCOUT_ANALYTICS_URL)) {
			CSM_Admin__c adminRecord = CSM_Admin__c.getOrgDefaults();
			if(adminRecord != null && adminRecord.CSM_ScoutCollector__c != null && adminRecord.CSM_ScoutCollector__c != '') {
				SCOUT_ANALYTICS_URL = adminRecord.CSM_ScoutCollector__c;
			}				
		}
		return SCOUT_ANALYTICS_URL;
	}
	
	/**
	* @description: gets the package version
	* @returns the package version string
	*/
	public static String getPackageVersion() {
		try {
			if (String.isEmpty(PACKAGE_VERSION)) {
				if(!String.isEmpty(CSM_Util.getNamespace())) {
					PACKAGE_VERSION = System.requestVersion().major() + '.' + System.requestVersion().minor();
					
					if (System.requestVersion().patch() != null) {
						PACKAGE_VERSION += '.' + String.valueOf(System.requestVersion().patch());
					}
				}
			}
		} catch(Exception ex) {
			
		}
		return PACKAGE_VERSION;
	}

	/** 
	* ORG21 check
	* @description: Finds the namespace for the managed package.
	* @returns the namespace string.
	*/
	public static String nameSpacePrefix21{
		get {
			if (nameSpacePrefix21==null){
				nameSpacePrefix21 = '';
				try{
					List<ApexTrigger> tr =[select NamespacePrefix from ApexTrigger where Name like:'%REN_ContractLineItemTrigger%'];
					if (tr!=null && !tr.isEmpty()){
						nameSpacePrefix21 = (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
					}
				} catch(Exception ex) {
					
				}
			}
			return nameSpacePrefix21;
		}
		private set;
	}
	
	/** 
	* SolutionExtension check
	* @description: Finds the namespace for the managed package.
	* @returns the namespace string.
	*/
	public static String nameSpacePrefixSolnExtn{
		get {
			if (nameSpacePrefixSolnExtn == null){
				nameSpacePrefixSolnExtn = '';
				try{
					List<ApexTrigger> tr =[select NamespacePrefix from ApexTrigger where Name = 'PeerReviewTrigger' limit 1];
					if (tr!=null && !tr.isEmpty()){
						nameSpacePrefixSolnExtn = (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
					}
				} catch(Exception ex) {
					
				}
			}
			return nameSpacePrefixSolnExtn;
		}
		private set;
	}
	/*
	public static String getnameSpacePrefixSolnExtn(){
		String nameSpacePrefix = '';
		if (cs==null){
			cs =[select NamespacePrefix from ApexTrigger where Name like:'%CaseCreationBatch%' limit 1];
		}
		return (String.isNotBlank(cs.nameSpacePrefix) ?  cs.nameSpacePrefix + '__' :  '');
		 
	}
	*/
    /**
		* @description Checks if object contains the CurrencyISOCode field
		* @param the object name to perform check on
		* @return true if field is present
		*/      
    public static Boolean returnIfCurrencyISOCodeExists(String objName) {
        Type objTypeName = Type.forName(objName);
		Boolean flag = false;
        
        if (objTypeName != null) 
        {
            SObject sObj = (SObject)objTypeName.newInstance();             
            Schema.sObjectType objType = sObj.getSObjectType();
            
            Map<String, Schema.SObjectField> fieldInfoMap = null;
            Schema.DescribeSObjectResult objResult = null;
            objResult =  objType.getDescribe();         
            fieldInfoMap = objResult.fields.getMap();
		    Schema.SObjectField tmpfield = fieldInfoMap.get(CSM_Constants.CURRENCY_ISO_CD);
		    if(tmpfield == null){
				flag = false;
		    }
		    else{
				flag = true;
		    }
        }
		else   
		{         
	            //throw exception Invalid Object name
	            String[] arguments = new String[] {objName};          
	            throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, arguments)); 
        }
        return flag;
    }   
    
    /***
    * @description check if multi-currency is enabled.
    * @Return: Boolean.
    ***/
    public static Boolean checkMCEnabled(){
    	return UserInfo.isMultiCurrencyOrganization();
	}
	
	/***
    * @description get Corporate currency code.
    * @Return: string.
    ***/
    public static String getCorpCurrency(){         
        String corporateCurrencyIsoCode; 
        if (UserInfo.isMultiCurrencyOrganization()){
        	List<String> fieldList = new List<String>{'conversionrate', 'isocode','IsActive','IsCorporate'};
            CSM_Util.checkCRUD_FLS('currencytype', fieldList, CSM_Constants.DML_OPERATION_READ);
            String q='select IsoCode, ConversionRate from CurrencyType where IsActive=true and IsCorporate=true';
            List<SObject> currencies = Database.query(q);
            if (currencies.size()>0){
                corporateCurrencyIsoCode=(String)currencies[0].get('ISOCode');  
            }
        }
        return corporateCurrencyIsoCode;
    }
    
    /***
    * @description get list of currency values.
    * @Return: list of currency values.
    ***/
	public static List<SelectOption> currencyPicklist(){
		List<SelectOption> currList = new List<SelectOption>();
		Boolean isMCEnabled = checkMCEnabled();
		STring queryString ='';
		if(UserInfo.isMultiCurrencyOrganization()){
			List<String> pFieldList = new List<String>{'isocode'};
            CSM_Util.checkCRUD_FLS('currencytype', pFieldList, CSM_Constants.DML_OPERATION_READ);
			
			queryString = 'SELECT isocode FROM currencytype';
			List<SObject> currencies = Database.query(queryString);
	        if(currencies != null && !currencies.isEmpty())
	        {
	        	for(SObject ct : currencies)
	        	{
	        		currList.add(new SelectOption((String)ct.get('ISOCode'), (String)ct.get('ISOCode')));
	        	}
	        }
		}
		return currList;
	}
	
	public static String getLocaleFormattedDateValue(String user_locale, DateTime date_time, Map<String, String> locale_map)
	{
		String locale_formatted_date_time_value = getLocaleFormattedDateTimeValue(user_locale, date_time, locale_map);
		String[] dateSplit = locale_formatted_date_time_value.split(REN_Constants.WHITESPACE);
		return dateSplit[0];
	}
		
	//returns the properly formatted datetime value
	public static String getLocaleFormattedDateTimeValue(String user_locale, DateTime date_time, Map<String, String> locale_map)
	{
		String datetime_format = 'M/d/yyyy h:mm a'; //variable for the datetime format defaulted to the US format
		if(locale_map.containsKey(user_locale)) //if the map contains the correct datetime format
		{ 	
			datetime_format = locale_map.get(user_locale); //grab the datetime format for the locale
		}
		String locale_formatted_date_time_value = date_time.format(datetime_format); //create a string with the proper format
		return locale_formatted_date_time_value; //return the string
	}
	
	public static String getLocaleFormattedDateValueForTasks(String user_locale, DateTime date_time, Map<String, String> locale_map)
	{
		String locale_formatted_date_time_value = getLocaleFormattedDateTimeValueForTasks(user_locale, date_time, locale_map);
		String[] dateSplit = locale_formatted_date_time_value.split(REN_Constants.WHITESPACE);
		return dateSplit[0];
	}
	
	//returns the properly formatted datetime value
	public static String getLocaleFormattedDateTimeValueForTasks(String user_locale, DateTime date_time, Map<String, String> locale_map)
	{
		String datetime_format = 'M/d/yyyy h:mm a'; //variable for the datetime format defaulted to the US format
		if(locale_map.containsKey(user_locale)) //if the map contains the correct datetime format
		{ 	
			datetime_format = locale_map.get(user_locale); //grab the datetime format for the locale
		}
		String locale_formatted_date_time_value = date_time.format(datetime_format); //create a string with the proper format
		return locale_formatted_date_time_value; //return the string
	}	
	
	public static String setToString(Set<Id> itemList) {
		String str = '';
		for(Id tmpId :itemList) {
			String tmpStr = (String)tmpId;
		   	str += (str==''?'':',')+tmpStr;
		}
		return str;
	}
	
    
    public static Set<Id> stringToIdList(String stringToConvert) {
    	Set<Id> idSet = new Set<Id>();
    	String[] strSplit = stringToConvert.split(',');
    	for (String str : strSplit) {
    		idSet.add((Id)str);
    	}
    	return idSet;
    }		
    
    //Below method will give Fiscal Year starts month from Organization details
    public static Integer getFiscalYearMonth()	{
    	//List<String> pFieldList = new List<String>{'FiscalYearStartMonth', 'Id'};
        //CSM_Util.checkCRUD_FLS('Organization', pFieldList, CSM_Constants.DML_OPERATION_READ);
    	organization orgInfo = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()];
    	return orgInfo.FiscalYearStartMonth;
    }
    
    //Below Method will return true if OWD for opportunity is Private else it will return false.
    public static Boolean isOWDForOpportunityPrivate()	{
    	//List<String> pFieldList = new List<String>{'DefaultOpportunityAccess', 'Id'};
        //CSM_Util.checkCRUD_FLS('Organization', pFieldList, CSM_Constants.DML_OPERATION_READ);
    	organization orgInfo = [select DefaultOpportunityAccess from Organization where id=:Userinfo.getOrganizationId()];
    	if((orgInfo.DefaultOpportunityAccess).contains('Edit'))	{
    		return false;
    	} else {
    		return true;
    	}
    }
    
    //Below Method will return true if OWD for Account is Private else it will return false.
    public static Boolean isOWDForAccountPrivate()	{
    	//List<String> pFieldList = new List<String>{'DefaultAccountAccess', 'Id'};
        //CSM_Util.checkCRUD_FLS('Organization', pFieldList, CSM_Constants.DML_OPERATION_READ);
    	organization orgInfo = [select DefaultAccountAccess from Organization where id=:Userinfo.getOrganizationId()];
    	if((orgInfo.DefaultAccountAccess).contains('Edit'))	{
    		return false;
    	} else {
    		return true;
    	}
    }
    
    
    /*Below Method will return if an object exists or not. This method is used to check if
    the object sharing is private/public read*/
    public static Boolean sObjectExists(String objectName)	{
    	Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(objectName)) 
          return true;
        else
          return false;  
    }

	
	//populate a map with locale values and corresponding datetime formats
	public static Map<String, String> getLocaleDateTimeMap()
	{
		Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
		locale_map.put('ar', 'DD/MM/YYYY hh:mm a');
		locale_map.put('ar_AE', 'DD/MM/YYYY hh:mm a');
		locale_map.put('ar_BH', 'DD/MM/YYYY hh:mm a');
		locale_map.put('ar_JO', 'DD/MM/YYYY hh:mm a');
		locale_map.put('ar_KW', 'DD/MM/YYYY hh:mm a');
		locale_map.put('ar_LB', 'DD/MM/YYYY hh:mm a');
		locale_map.put('ar_SA', 'DD/MM/YYYY hh:mm a');
		locale_map.put('bg_BG', 'YYYY-M-D H:mm');
		locale_map.put('ca', 'DD/MM/YYYY HH:mm');
		locale_map.put('ca_ES', 'DD/MM/YYYY HH:mm');
		locale_map.put('ca_ES_EURO', 'DD/MM/YYYY HH:mm');
		locale_map.put('cs', 'D.M.YYYY H:mm');
		locale_map.put('cs_CZ', 'D.M.YYYY H:mm');
		locale_map.put('da', 'DD-MM-YYYY HH:mm');
		locale_map.put('da_DK', 'DD-MM-YYYY HH:mm');
		locale_map.put('de', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_AT', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_AT_EURO', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_CH', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_DE', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_DE_EURO', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_LU', 'DD.MM.YYYY HH:mm');
		locale_map.put('de_LU_EURO', 'DD.MM.YYYY HH:mm');
		locale_map.put('el_GR', 'D/M/YYYY h:mm a');
		locale_map.put('en_AU', 'D/MM/YYYY HH:mm');
		locale_map.put('en_B', 'M/D/YYYY h:mm a');
		locale_map.put('en_BM', 'M/D/YYYY h:mm a');
		locale_map.put('en_CA', 'DD/MM/YYYY h:mm a');
		locale_map.put('en_GB', 'DD/MM/YYYY HH:mm');
		locale_map.put('en_GH', 'M/D/YYYY h:mm a');
		locale_map.put('en_ID', 'M/D/YYYY h:mm a');
		locale_map.put('en_IE', 'DD/MM/YYYY HH:mm');
		locale_map.put('en_IE_EURO', 'DD/MM/YYYY HH:mm');
		locale_map.put('en_NZ', 'D/MM/YYYY HH:mm');
		locale_map.put('en_SG', 'M/D/YYYY h:mm a');
		locale_map.put('en_US', 'M/D/YYYY h:mm a');
		locale_map.put('en_ZA', 'YYYY/MM/DD hh:mm a');
		locale_map.put('es', 'D/MM/YYYY H:mm');
		locale_map.put('es_AR', 'DD/MM/YYYY HH:mm');
		locale_map.put('es_BO', 'DD-MM-YYYY hh:mm a');
		locale_map.put('es_CL', 'DD-MM-YYYY hh:mm a');
		locale_map.put('es_CO', 'D/MM/YYYY hh:mm a');
		locale_map.put('es_CR', 'DD/MM/YYYY hh:mm a');
		locale_map.put('es_EC', 'DD/MM/YYYY hh:mm a');
		locale_map.put('es_ES', 'D/MM/YYYY H:mm');
		locale_map.put('es_ES_EURO', 'D/MM/YYYY H:mm');
		locale_map.put('es_GT', 'D/MM/YYYY hh:mm a');
		locale_map.put('es_HN', 'MM-DD-YYYY hh:mm a');
		locale_map.put('es_MX', 'D/MM/YYYY hh:mm a');
		locale_map.put('es_PE', 'DD/MM/YYYY hh:mm a');
		locale_map.put('es_PR', 'MM-DD-YYYY hh:mm a');
		locale_map.put('es_PY', 'DD/MM/YYYY hh:mm a');
		locale_map.put('es_SV', 'MM-DD-YYYY hh:mm a');
		locale_map.put('es_UY', 'DD/MM/YYYY hh:mm a');
		locale_map.put('es_VE', 'DD/MM/YYYY hh:mm a');
		locale_map.put('et_EE', 'D.MM.YYYY H:mm');
		locale_map.put('fi', 'D.M.YYYY H:mm');
		locale_map.put('fi_FI', 'D.M.YYYY H:mm');
		locale_map.put('fi_FI_EURO', 'D.M.YYYY H:mm');
		locale_map.put('fr', 'DD/MM/YYYY HH:mm');
		locale_map.put('fr_BE', 'D/MM/YYYY H:mm');
		locale_map.put('fr_CA', 'YYYY-MM-DD HH:mm');
		locale_map.put('fr_CH', 'DD.MM.YYYY HH:mm');
		locale_map.put('fr_FR', 'DD/MM/YYYY HH:mm');
		locale_map.put('fr_FR_EURO', 'DD/MM/YYYY HH:mm');
		locale_map.put('fr_LU', 'DD/MM/YYYY HH:mm');
		locale_map.put('fr_MC', 'DD/MM/YYYY HH:mm');
		locale_map.put('hr_HR', 'YYYY.MM.DD HH:mm');
		locale_map.put('hu', 'YYYY.MM.DD. H:mm');
		locale_map.put('hy_AM', 'M/D/YYYY h:mm a');
		locale_map.put('is_IS', 'D.M.YYYY HH:mm');
		locale_map.put('it', 'DD/MM/YYYY H.mm');
		locale_map.put('it_CH', 'DD.MM.YYYY HH:mm');
		locale_map.put('it_IT', 'DD/MM/YYYY H.mm');
		locale_map.put('iw', 'HH:mm DD/MM/YYYY');
		locale_map.put('iw_IL', 'HH:mm DD/MM/YYYY');
		locale_map.put('ja', 'YYYY/MM/DD H:mm');
		locale_map.put('ja_JP', 'YYYY/MM/DD H:mm');
		locale_map.put('kk_KZ', 'M/D/YYYY h:mm a');
		locale_map.put('km_KH', 'M/D/YYYY h:mm a');
		locale_map.put('ko', 'YYYY. M. D a h:mm');
		locale_map.put('ko_KR', 'YYYY. M. D a h:mm');
		locale_map.put('lt_LT', 'YYYY.M.D HH.mm');
		locale_map.put('lv_LV', 'YYYY.D.M HH:mm');
		locale_map.put('ms_MY', 'DD/MM/YYYY h:mm a');
		locale_map.put('nl', 'D-M-YYYY H:mm');
		locale_map.put('nl_BE', 'D/MM/YYYY H:mm');
		locale_map.put('nl_NL', 'D-M-YYYY H:mm');
		locale_map.put('nl_SR', 'D-M-YYYY H:mm');
		locale_map.put('no', 'DD.MM.YYYY HH:mm');
		locale_map.put('no_NO', 'DD.MM.YYYY HH:mm');
		locale_map.put('pl', 'YYYY-MM-DD HH:mm');
		locale_map.put('pt', 'DD-MM-YYYY H:mm');
		locale_map.put('pt_AO', 'DD-MM-YYYY H:mm');
		locale_map.put('pt_BR', 'DD/MM/YYYY HH:mm');
		locale_map.put('pt_PT', 'DD-MM-YYYY H:mm');
		locale_map.put('ro_RO', 'DD.MM.YYYY HH:mm');
		locale_map.put('ru', 'DD.MM.YYYY H:mm');
		locale_map.put('sk_SK', 'D.M.YYYY H:mm');
		locale_map.put('sl_SI', 'D.M.y H:mm');
		locale_map.put('sv', 'YYYY-MM-DD HH:mm');
		locale_map.put('sv_SE', 'YYYY-MM-DD HH:mm');
		locale_map.put('th', 'M/D/YYYY h:mm a');
		locale_map.put('th_TH', 'D/M/YYYY, H:mm ?.');
		locale_map.put('tr', 'DD.MM.YYYY HH:mm');
		locale_map.put('ur_PK', 'M/D/YYYY h:mm a');
		locale_map.put('vi_VN', 'HH:mm DD/MM/YYYY');
		locale_map.put('zh', 'YYYY-M-D ah:mm');
		locale_map.put('zh_CN', 'YYYY-M-D ah:mm');
		locale_map.put('zh_HK', 'YYYY-M-D ah:mm');
		locale_map.put('zh_TW', 'YYYY/M/D a h:mm');
		return locale_map; //return the map
	}
    
    //populate a map with locale values and corresponding datetime formats
	public static Map<String, String> getLocaleDateMap()
	{
		Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
		locale_map.put('ar', 'dd/MM/yyyy');
		locale_map.put('ar_AE', 'dd/MM/yyyy');
		locale_map.put('ar_BH', 'dd/MM/yyyy');
		locale_map.put('ar_JO', 'dd/MM/yyyy');
		locale_map.put('ar_KW', 'dd/MM/yyyy');
		locale_map.put('ar_LB', 'dd/MM/yyyy');
		locale_map.put('ar_SA', 'dd/MM/yyyy');
		locale_map.put('bg_BG', 'yyyy-M-d');
		locale_map.put('ca', 'dd/MM/yyyy');
		locale_map.put('ca_ES', 'dd/MM/yyyy');
		locale_map.put('ca_ES_EURO', 'dd/MM/yyyy');
		locale_map.put('cs', 'd.M.yyyy');
		locale_map.put('cs_CZ', 'd.M.yyyy');
		locale_map.put('da', 'dd-MM-yyyy');
		locale_map.put('da_DK', 'dd-MM-yyyy');
		locale_map.put('de', 'dd.MM.yyyy');
		locale_map.put('de_AT', 'dd.MM.yyyy');
		locale_map.put('de_AT_EURO', 'dd.MM.yyyy');
		locale_map.put('de_CH', 'dd.MM.yyyy');
		locale_map.put('de_DE', 'dd.MM.yyyy');
		locale_map.put('de_DE_EURO', 'dd.MM.yyyy');
		locale_map.put('de_LU', 'dd.MM.yyyy');
		locale_map.put('de_LU_EURO', 'dd.MM.yyyy');
		locale_map.put('el_GR', 'd/M/yyyy');
		locale_map.put('en_AU', 'd/MM/yyyy');
		locale_map.put('en_B', 'M/d/yyyy');
		locale_map.put('en_BM', 'M/d/yyyy');
		locale_map.put('en_CA', 'dd/MM/yyyy');
		locale_map.put('en_GB', 'dd/MM/yyyy');
		locale_map.put('en_GH', 'M/d/yyyy');
		locale_map.put('en_ID', 'M/d/yyyy');
		locale_map.put('en_IE', 'dd/MM/yyyy');
		locale_map.put('en_IE_EURO', 'dd/MM/yyyy');
		locale_map.put('en_NZ', 'd/MM/yyyy');
		locale_map.put('en_SG', 'M/d/yyyy');
		locale_map.put('en_US', 'M/d/yyyy');
		locale_map.put('en_ZA', 'yyyy/MM/dd');
		locale_map.put('es', 'd/MM/yyyy');
		locale_map.put('es_AR', 'dd/MM/yyyy');
		locale_map.put('es_BO', 'dd-MM-yyyy');
		locale_map.put('es_CL', 'dd-MM-yyyy');
		locale_map.put('es_CO', 'd/MM/yyyy');
		locale_map.put('es_CR', 'dd/MM/yyyy');
		locale_map.put('es_EC', 'dd/MM/yyyy');
		locale_map.put('es_ES', 'd/MM/yyyy');
		locale_map.put('es_ES_EURO', 'd/MM/yyyy');
		locale_map.put('es_GT', 'd/MM/yyyy');
		locale_map.put('es_HN', 'MM-dd-yyyy');
		locale_map.put('es_MX', 'd/MM/yyyy');
		locale_map.put('es_PE', 'dd/MM/yyyy');
		locale_map.put('es_PR', 'MM-dd-yyyy');
		locale_map.put('es_PY', 'dd/MM/yyyy ');
		locale_map.put('es_SV', 'MM-dd-yyyy');
		locale_map.put('es_UY', 'dd/MM/yyyy');
		locale_map.put('es_VE', 'dd/MM/yyyy');
		locale_map.put('et_EE', 'd.MM.yyyy');
		locale_map.put('fi', 'd.M.yyyy');
		locale_map.put('fi_FI', 'd.M.yyyy');
		locale_map.put('fi_FI_EURO', 'd.M.yyyy');
		locale_map.put('fr', 'dd/MM/yyyy');
		locale_map.put('fr_BE', 'd/MM/yyyy');
		locale_map.put('fr_CA', 'yyyy-MM-dd');
		locale_map.put('fr_CH', 'dd.MM.yyyy');
		locale_map.put('fr_FR', 'dd/MM/yyyy');
		locale_map.put('fr_FR_EURO', 'dd/MM/yyyy');
		locale_map.put('fr_LU', 'dd/MM/yyyy');
		locale_map.put('fr_MC', 'dd/MM/yyyy');
		locale_map.put('hr_HR', 'yyyy.MM.dd');
		locale_map.put('hu', 'yyyy.MM.dd.');
		locale_map.put('hy_AM', 'M/d/yyyy');
		locale_map.put('is_IS', 'd.M.yyyy');
		locale_map.put('it', 'dd/MM/yyyy');
		locale_map.put('it_CH', 'dd.MM.yyyy');
		locale_map.put('it_IT', 'dd/MM/yyyy');
		locale_map.put('iw', 'dd/MM/yyyy');
		locale_map.put('iw_IL', 'dd/MM/yyyy');
		locale_map.put('ja', 'yyyy/MM/dd');
		locale_map.put('ja_JP', 'yyyy/MM/dd');
		locale_map.put('kk_KZ', 'M/d/yyyy');
		locale_map.put('km_KH', 'M/d/yyyy');
		locale_map.put('ko', 'yyyy. M. d');
		locale_map.put('ko_KR', 'yyyy. M. d');
		locale_map.put('lt_LT', 'yyyy.M.d');
		locale_map.put('lv_LV', 'yyyy.d.M');
		locale_map.put('ms_MY', 'dd/MM/yyyy');
		locale_map.put('nl', 'd-M-yyyy');
		locale_map.put('nl_BE', 'd/MM/yyyy');
		locale_map.put('nl_NL', 'd-M-yyyy');
		locale_map.put('nl_SR', 'd-M-yyyy');
		locale_map.put('no', 'dd.MM.yyyy');
		locale_map.put('no_NO', 'dd.MM.yyyy');
		locale_map.put('pl', 'yyyy-MM-dd');
		locale_map.put('pt', 'dd-MM-yyyy');
		locale_map.put('pt_AO', 'dd-MM-yyyy');
		locale_map.put('pt_BR', 'dd/MM/yyyy');
		locale_map.put('pt_PT', 'dd-MM-yyyy');
		locale_map.put('ro_RO', 'dd.MM.yyyy');
		locale_map.put('ru', 'dd.MM.yyyy');
		locale_map.put('sk_SK', 'd.M.yyyy');
		locale_map.put('sl_SI', 'd.M.y');
		locale_map.put('sv', 'yyyy-MM-dd');
		locale_map.put('sv_SE', 'yyyy-MM-dd');
		locale_map.put('th', 'M/d/yyyy');
		locale_map.put('th_TH', 'd/M/yyyy');
		locale_map.put('tr', 'dd.MM.yyyy');
		locale_map.put('ur_PK', 'M/d/yyyy');
		locale_map.put('vi_VN', 'dd/MM/yyyy');
		locale_map.put('zh', 'yyyy-M-d');
		locale_map.put('zh_CN', 'yyyy-M-d');
		locale_map.put('zh_HK', 'yyyy-M-d');
		locale_map.put('zh_TW', 'yyyy/M/d');
		return locale_map; //return the map
	}	
	
	static public Boolean isValidId(String idParam) { 
			if(idParam == null || String.isEmpty(idParam)){
				return false;
			}
	        if(idParam != '000000000000000' && idParam != '000000000000000AAA') { 
	            return true; 
	        } 
	        return false; 
	} 
	
	public static List<String> getKeyHighstValfrmMap(Map<String,Decimal> inputMap){
		Decimal counter = 0;
		Map<Decimal,Set<String>> inputCountMap = new Map<Decimal,Set<String>>();
		List<String> keyHighValList = new List <String>();
		for(String key : inputMap.keySet()){
			if(counter < inputMap.get(key)){
				counter = inputMap.get(key);
				//mostCommonDate = key;
				if(inputCountMap.containsKey(counter)){
					inputCountMap.get(counter).add(key);
				}
				else{
					inputCountMap.put(counter,new Set<String>());
					inputCountMap.get(counter).add(key);
				}
			}
		} 
		if(inputCountMap.containsKey(counter)){
			keyHighValList = new List<String>(inputCountMap.get(counter));
		}
		if(keyHighValList.size()>0){
			keyHighValList.sort();
			//opp.closeDate = keyHighValList[0];
		}
		
		return keyHighValList;
	}
	public static String findNameForLookup(String focusCategoryViewColumn, Map<String, Schema.SObjectField> objFieldInfo){
		string refObjName = '';
		string refRelation = '';
		Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(focusCategoryViewColumn.toLowerCase()).getDescribe();
        List<Schema.sObjectType> refObjList = fieldDescription.getReferenceTo();
        refObjName = String.valueOf(refObjList[0]);	
        refRelation = fieldDescription.getRelationshipName();
        if(refObjName != CSM_Constants.OBJ_CASE && refObjName!=CSM_Constants.OBJ_CONTRACT && refObjName.toLowerCase()!='quotelineitem')
        {
        	refRelation = refRelation + '.Name';
        }else if(refObjName == CSM_Constants.OBJ_CASE)
        {
        	refRelation = refRelation + '.CaseNumber';
        }else if(refObjName == CSM_Constants.OBJ_CONTRACT)
        {
        	refRelation = refRelation + '.ContractNumber';
        }else if(refObjName.toLowerCase() == 'quotelineitem')
        {
        	refRelation = refRelation + '.Description';
        }
        return refRelation;
	}
	
	public static Integer getFieldScaleOptimized(Schema.DescribeSObjectResult r, String fieldNameWithNamespace){
		
		return (r.fields.getMap().get(fieldNameWithNamespace).getDescribe()).getScale();
	}
	
	public static Integer getFieldScale(String sObjectName, String fieldNameWithNamespace)
	{
		String fieldName = fieldNameWithNamespace.toLowerCase();
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
		 
		Schema.DescribeSObjectResult r = t.getDescribe();
		Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
		
		return f.getScale();
	}
	
	public static String getLabelReplacement(String labelToReplace)
	{
		if (labelToReplace.equals(CSM_Constants.OBJ_AP_ACCOUNT_MANAGER))
		{
			String acctManagerLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_AccountManager__c;
			if (String.isNotBlank(acctManagerLabel))
			{
				return acctManagerLabel;
			}
			return Schema.CSM_Account_Plan__c.fields.CSM_Account_Manager__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR))
		{
			String customerSuccessMgrLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_CustomerSuccessManager__c;
			if (String.isNotBlank(customerSuccessMgrLabel))
			{
				return customerSuccessMgrLabel;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Customer_Success_Manager__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_CSM_CONTACT))
		{
			String csmReplacementLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_CSM__c;
			if (String.isNotBlank(csmReplacementLabel))
			{
				return csmReplacementLabel;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Contact__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_CSM_MANAGER))
		{
			String csmManagerLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_CsmManager__c;
			if (String.isNotBlank(csmManagerLabel))
			{
				return csmManagerLabel;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Manager__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_EXEC_SPONSOR))
		{
			String execSponsorLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_ExecSponsor__c;
			if (String.isNotBlank(execSponsorLabel))
			{
				return execSponsorLabel;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Exec_Sponsor__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_RENEWAL_MANAGER))
		{
			String renewMgrLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_RenewalManager__c;
			if (String.isNotBlank(renewMgrLabel))
			{
				return renewMgrLabel;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Renewal_Manager__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_RENEWAL_CONTACT))
		{
			String renewalRepLbl = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_RenewalRep__c;
			if (String.isNotBlank(renewalRepLbl))
			{
				return renewalRepLbl;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Renewal_Contact__c.getDescribe().getLabel();
		}
		else if (labelToReplace.equals(CSM_Constants.OBJ_AP_SUPPORT_CONTACT))
		{
			String SupportContactLbl = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_SupportContact__c;
			if (String.isNotBlank(SupportContactLbl))
			{
				return SupportContactLbl;
			}
		    return Schema.CSM_Account_Plan__c.fields.CSM_Support_Contact__c.getDescribe().getLabel();
		} else {
            Schema.SObjectType objSchema = CSM_Account_Plan__c.sObjectType;
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            return fieldMap.get(CSM_Util.getNamespace() + labelToReplace).getDescribe().getLabel();
		}
		return null;
	}
	
	public static String formatCurrency(String i)
	{

	    if (( i == null) || ( i == ''))
	    {
	        return null;
	    }
	    else
	    {
	        string s;
	        if ( Decimal.valueOf(i) >= 0 )
	        {
	            s =  ( Decimal.valueOf(i).setScale(2, RoundingMode.CEILING) + 0.001 ).format();
	        }
	        else
	        {
	            s = ( Decimal.valueOf(i).setScale(2, RoundingMode.CEILING) - 0.001 ).format();
	        }
	        return s.substring(0,s.length()-1);
	    }
	  
	}
	
	/*public static List<SelectOption> getSelectOptionsForPicklistField(Schema.DescribeFieldResult fieldResult) {
		List<SelectOption> options = new List<SelectOption>();        
   		//Schema.DescribeFieldResult fieldResult = CSM_SuccessPlan_Play__c.CSM_Play_Outcome__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--None--'));
   		for( Schema.PicklistEntry f : ple) {
      		options.add(new SelectOption(f.getLabel(), f.getValue()));
   		}       
   		return options;
	}*/
	
	public static void notifyUserBatchFailure(id batchJobId)
    {
        List<AsyncApexJob> failedList = [SELECT Id,
                                              CreatedDate,
                                              Status,
                                              CreatedBy.UserName,
                                              NumberOfErrors,ApexClass.Name,
                                              JobItemsProcessed,
                                              TotalJobItems,
                                              CreatedBy.Email,
                                              ExtendedStatus
                                         FROM AsyncApexJob
                                        WHERE (ExtendedStatus != null or Status in ('Failed','Aborted'))
                                          AND Id = :batchJobId];
                                          
         if (!failedList.isEmpty())
         {	
             String failedStr = '<table cellpadding="3" cellspacing="3" border="1"><tr style="background-color: lightgray;"><td style="font:bold;"><b>'+Label.LBL_BATCH_JOB_NAME 
                     +'</b></td><td><b>'+Label.LBL_TOTAL_NUMBER_BATCHES+'</b></td><td><b>'+Label.LBL_FAILURE_REASON
                     +'</b></td><td><b>'+Label.LBL_TOTAL_NUMBER_ERRORS+'</b></td><td><b>'+Label.CSM_LBL_Task_Status+'</b></td><td><b>'+Label.CSM_LBL_ORG_ID+'</b></td><td><b>'+Label.CSM_LBL_ORG_NAME+'</b></td></tr>';

             Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
             message.toAddresses = new String[] {userinfo.getuserid()};
             AsyncApexJob flJb = failedList[0];
             message.subject = 'Batch Jobs Failure Notification - '+flJb.ApexClass.Name;


             failedStr += '<tr><td>'+flJb.ApexClass.Name+'</td><td>'+flJb.TotalJobItems+'</td><td>'+(flJb.ExtendedStatus == null ? '' : flJb.ExtendedStatus)+'</td><td>'+flJb.NumberOfErrors+'</td><td>'+flJb.Status+'</td><td>'+Userinfo.getOrganizationId()+'</td><td>'+getOrgName()+'</td></tr>';


             failedStr += '</table>';

             message.htmlBody = failedStr;
             Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
             Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         }
    }
    
    
    /**
	 * @description : This method is used to get the query as per the Dispatcher class name passed as parameter. Added for the US1682.
	 */
	public static String getBatchFilterQueryString(String dispatcherClassName){
		String batchQuery;
		List<CSM_Batch_Filter__c> batchActiveFilterList = CSM_BatchFilterDataAccess.getBatchFilterByJobName(new Set<String>{dispatcherClassName});
		if(!batchActiveFilterList.isEmpty()){
			batchQuery = batchActiveFilterList[0].CSM_Query_Criteria__c;
		}
		return batchQuery;
	}	
    
    public static CSM_ShareWrapper getShareInformation(String objectName, Id recordId) {
    	CSM_ShareWrapper shareWrapper = new CSM_ShareWrapper();
    	String shareObjectName = '';
    	Set<String> developerNames = new Set<String>();
    	//developerNames.add(CSM_Constants.STR_ALL_PRTR_USERS);
    	developerNames.add(CSM_Constants.STR_ALL_INTERNAL_USERS);
    	//developerNames.add(CSM_Constants.STR_ALL_CUST_PORT_USERS);
    	List<SObject> shareObjectList = new List<SObject>();
    	String queryString = 'Select Id, UserOrGroupId from ';
    	if(objectName.endsWith('__c')) {
    		shareObjectName = objectName.replace('__c','__Share');
    		queryString += shareObjectName + 
    						' where ParentId = \'' + recordId + '\' and ';
    	} else {
    		shareObjectName = objectName + 'Share';
    		queryString += shareObjectName + 
    						' where ' + objectName + 'Id = \'' + recordId + '\' and ';
    	}
    	queryString += 'RowCause != \'Rule\' and RowCause != \'Owner\'';
    	shareObjectList = Database.query(queryString);
    	Set<String> groupIds = new Set<String>();
    	if(shareObjectList != null && !shareObjectList.isEmpty()) {
    		for(SObject obj : shareObjectList) {
    			groupIds.add((Id)obj.get('UserOrGroupId'));
    		}
            shareWrapper.visibility = CSM_Constants.STR_VISI_CERTAIN_GRP_USERS;    		
    	} else {
    		shareWrapper.visibility = CSM_Constants.STR_VISI_ONLY_ME;
    	}
    	List<SObject> groupObjectList = [select Id, DeveloperName from Group where id in :groupIds];
    	if(groupObjectList != null && !groupObjectList.isEmpty()) {
    		Integer cnt = 0;
    		for(SObject obj : groupObjectList) {
    			if(developerNames.contains(String.valueOf(obj.get('DeveloperName')))) {
    				cnt += 1;
    				//if(cnt == 3) {
					shareWrapper.visibility = CSM_Constants.STR_VISI_ALL_USERS;
					break;
    				//}
    			}
    		}
    		if(cnt != 1) {
    			shareWrapper.visibility = CSM_Constants.STR_VISI_CERTAIN_GRP_USERS;
    		}
    	}
		//if(String.isEmpty(shareWrapper.visibility)) {
		//	shareWrapper.visibility = CSM_Constants.STR_VISI_CERTAIN_GRP_USERS;
		//}
    	
    	shareWrapper.shareIds = groupIds;
    	system.debug('shareWrapper::::'+shareWrapper);
    	return shareWrapper;
    }
    
    public static String processMyFCVSOQL(String fcvSoql, String fcvFilter){
    	if(fcvFilter != null && fcvFilter.contains('My')){
    		if(fcvSoql.toLowerCase().contains('<placeholder>')) {
    			fcvSoql = fcvSoql.replace('<placeholder>', '\'' + UserInfo.getUserId() + '\'');
    		}
    		
    		/*if(fcvSoql.toLowerCase().contains('where')){
    			if(fcvSoql.toLowerCase().contains('order by')) {
    				String[] soqlArr = fcvSoql.split('order by');
    				fcvSoql = soqlArr[0] + ' and OwnerId = \'' + UserInfo.getUserId() + '\' order by ' + soqlArr[1];
    			} else {
    				fcvSoql += ' and OwnerId = \'' + UserInfo.getUserId() + '\'';	
    			}
    		} else {
    			if(fcvSoql.toLowerCase().contains('order by')) {
    				String[] soqlArr = fcvSoql.split('order by');
    				fcvSoql = soqlArr[0] + ' where OwnerId = \'' + UserInfo.getUserId() + '\' order by ' + soqlArr[1];
    			} else {
    				fcvSoql += ' where OwnerId = \'' + UserInfo.getUserId() + '\'';
    			}                      		
    		}*/
    	}
    	return fcvSoql;
    } 
    
    /**
	* @description Gets all the user lookup on Success Plan object that are not of the userLookupExclusionSet below(US2317)
	* @param sObjectName name of the sobject
	* @return Set<Sting> api name of the all the user lookups that are not part of the userLookupExclusionSet below
	*/
    public static Map<String, String> getUserLookupsForSObject(String sObjName) {
        Map<String, String> userLookupPlayTaskMap = new Map<String, String>();
        if (String.isNotBlank(sObjName)) {
            String refObjName = '';
            String refRelationName = '';

            String nameSpace = getNamespace();

            //set of all the user lookups on Success Plan other than the newly added user lookups
            Set<String> userLookupExclusionSet = new Set<String>{nameSpace+'CSM_Support_Contact__r', nameSpace+'CSM_Renewal_Manager__r', nameSpace+'CSM_Renewal_Contact__r',
                                                                nameSpace+'CSM_Manager__r', nameSpace+'CSM_Exec_Sponsor__r', nameSpace+'CSM_Account_Manager__r', nameSpace+'CSM_Contact__r',
                                                                nameSpace+'CSM_Customer_Success_Manager__r', 'CreatedBy', 'LastModifiedBy'};

            //get a map of fields
            Map<String, Schema.SObjectField> sObjFldMap = CSM_AccessController.getFieldMap(sObjName);
            if (sObjFldMap != null && !sObjFldMap.isEmpty()) {
                //loop thru and find the relationship type of the field
                for (String fieldName : sObjFldMap.keySet()) {
                    Schema.DescribeFieldResult fieldDescription = sObjFldMap.get(fieldName).getDescribe();
                    List<Schema.sObjectType> refObjList = fieldDescription.getReferenceTo();
                    if (refObjList != null && !refObjList.isEmpty()) {
                        refObjName = String.valueOf(refObjList[0]);
                    }
                    refRelationName = fieldDescription.getRelationshipName();

                    if (String.isNotBlank(refObjName) && 'User'.equalsIgnoreCase(refObjName) && String.isNotBlank(refRelationName) && !userLookupExclusionSet.contains(refRelationName)) {
                        //add the fields api name to userLookupPlayTaskSet
                        userLookupPlayTaskMap.put(fieldName, fieldDescription.getLabel());
                    }
                }
            }
        }
        return userLookupPlayTaskMap;
    }
    /* US2725 : this method us used to get batch size from custom setting */
    public static Integer getCustomListSetting(String batchName) {
		Integer batchSize;
		Map<string,CSM_Batch_Job_Config__c> customListRecord = CSM_Batch_Job_Config__c.getAll();
		if(customListRecord != null && customListRecord.get(batchName) != null) {
			batchSize = (Integer)customListRecord.get(batchName).CSM_Batch_Size__c;
		}
		return batchSize;
	}
    
    /*US2724 : This method is used to get Org Name.*/
    public static String getOrgName()  {
        organization orgInfo = [select Name from Organization where id=:Userinfo.getOrganizationId()];
        return orgInfo.Name;
    }
    
    public static boolean getSDMFlag(){
    	boolean flag = false;
    	SS_License__c ssLicense = SS_License__c.getOrgDefaults();
    	if(ssLicense!=null){
    		flag = ssLicense.Simplified_Data_Model_Is_Enabled__c;
    	}
    	return flag;
    }
    public static List<SObject> getCustomSetting(List<String> customSettingName ,List<String> customSettingfldsToQuery){
  		String soqlStr = 'SELECT ' + String.join(customSettingfldsToQuery, ',') + ' FROM ' + customSettingName[0] +' limit 10'; 
        return Database.query(soqlStr); 
  }
}