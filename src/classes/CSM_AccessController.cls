/**
* @author         Michelle Lairson(michelle@comitydesigns.com)
* @date           07.23.2014
* @description    CSM_AccessController class performs CRUD/FLS checks
*/
public with sharing class CSM_AccessController {
	
	/**
	* @description Exception thrown when error occurs
	*/
    public with sharing class AccessControlDmlException extends Exception {}
    
    /**
    *@description map of object name as key and field map as value
    */
    public static Map<String,  Map<String, Schema.SObjectField>> objectFieldInfoMap;
    
    /**
    *@description private static variable referencing the class
    */
    private static CSM_AccessController instance = null;
    
    /**
    *@description map of object name as key and object describe as value
    */
    private static Map<String, Schema.DescribeSObjectResult> describeObjectMap;

    /**
    *@description private static variable referencing the class
    */
    private static Map<String, Schema.SObjectType> objectNameMap;
    
    
    /**
    *@description The constructor is private and initializes the maps
    */
    private CSM_AccessController()
    {
        objectFieldInfoMap = new Map<String,  Map<String, Schema.SObjectField>>();
        describeObjectMap = new  Map<String, Schema.DescribeSObjectResult>();
    }
    
    /**
    * @description a static method that returns the instance of the CSM_Accesso Controller
    */
    public static CSM_AccessController getInstance()
    {
        if(instance == null) 
        {
            instance = new CSM_AccessController();
        }
        return instance;        
    }   
    
    /**
		* @description Performs a CRUD/FLS check for the given objent name, CRUD operation and field name list
		* @param the object name to perform CRUD/FLS check on
		* @param the CRUD operation type
		* @param the list of field names to perform CRU check
		* @return a list of fields that are not accessible
		*/      
    public List<String> returnNoPermissionFieldsNameList(String objName, String operationType, List<String> fieldNames) {
    	System.debug('\n0. CSM_AccessController~~~~objName: ' + objName + '\noperationType: ' + operationType + '\n fieldNames: ' + JSON.serialize(fieldNames));
        List<String> returnNoPermissionFieldsNameList = new List<String>(); 
        Type objTypeName = Type.forName(objName);
        String nameSpace = CSM_Util.getNamespace();
        String fldName;
        if (objTypeName != null){
            SObject sObj = (SObject)objTypeName.newInstance();             
            Schema.sObjectType objType = sObj.getSObjectType();
            
            Map<String, Schema.SObjectField> fieldInfoMap = null;
            Schema.DescribeSObjectResult objResult = null;
            if (objectFieldInfoMap.containsKey(objName)){
                fieldInfoMap = objectFieldInfoMap.get(objName);
                objResult = describeObjectMap.get(objName);
            }else{    
                objResult =  objType.getDescribe();         
                fieldInfoMap = objResult.fields.getMap();
                objectFieldInfoMap.put(objName, fieldInfoMap); 
                describeObjectMap.put(objName, objResult);               
            }
            
            if((operationType == CSM_Constants.DML_OPERATION_READ && objResult.isAccessible())
                    || (operationType == CSM_Constants.DML_OPERATION_INSERT && objResult.isCreateable())
                    || (operationType == CSM_Constants.DML_OPERATION_UPDATE && objResult.isUpdateable())
                    || (operationType == CSM_Constants.DML_OPERATION_UPSERT && objResult.isCreateable() && objResult.isUpdateable()))
            {           
              	
              	String orignalFieldName = '';
                for(String fieldName :fieldNames){
                	//System.debug(' ~~ 1. CSM_AccessController~~~~fieldName: ' + fieldName);
                	if(String.isBlank(fieldName)){
                		continue;
                	}
                	orignalFieldName = fieldName;
                	//Start -- Added for US2419
		   			if(fieldName.endsWithIgnoreCase('__c')){
		   				orignalFieldName = fieldName;
                    	fldName = fieldName.removeEndIgnoreCase('__c');
		   			 	if(!fldName.contains('__')){
                         	fieldName = namespace + fieldName;
                    	}
		   			}
                    Schema.SObjectField tmpfield = fieldInfoMap.get(fieldName);
                    if(tmpfield == null && orignalFieldName != fieldName){ // in case of custom field has been created out side of package.
                    	fieldName = orignalFieldName;
                    	tmpfield = fieldInfoMap.get(fieldName);
                    }
                    
                    //End -- Added for US2419
                    if(tmpfield != null){
                        DescribeFieldResult fieldDefinition = tmpfield.getDescribe();
						if(operationType == CSM_Constants.DML_OPERATION_READ && !(fieldDefinition.isAccessible())){   
							System.debug('\n2.1. CSM_AccessController~~~~tmpfield: ' + tmpfield);                    
							returnNoPermissionFieldsNameList.add(tmpfield.getDescribe().getLabel());                        
						}else if(operationType != CSM_Constants.DML_OPERATION_READ && !fieldDefinition.isUpdateable() && !fieldName.equalsIgnoreCase('Id')){
							System.debug('\n2.1. CSM_AccessController~~~~tmpfield: ' + tmpfield);                    
							returnNoPermissionFieldsNameList.add(tmpfield.getDescribe().getLabel()); 
						}
                    }else{
                        //throw exception Invalid field name
                        String[] arguments = new String[] {fieldName};          
                        throw new AccessControlDmlException(String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, arguments)); 
                    }   
                }
                
                
           }else if(operationType == CSM_Constants.DML_OPERATION_DELETE){
           	   if (!objResult.isDeletable()){
           	   		System.debug('\n4. CSM_AccessController~~~~fieldName: ' + objName);
	               // throw exception it is not deleteable
	               throw new AccessControlDmlException(objName + ' ' + System.Label.CSM_MSG_OBJECT_NOT_DELETABLE);
               }
           }else{
           		System.debug('\n5. CSM_AccessController~~~~: ' + 'No ' + operationType + ' for '+ objName);
               // throw exception 
               String[] arguments = new String[] {objName}; 
               throw new AccessControlDmlException('No ' + operationType + ' for '+ objName);
           }
        }else{
        	System.debug('\n6. CSM_AccessController~~~~objName: ' + objName);
            //throw exception Invalid Object name
            String[] arguments = new String[] {objName};          
            throw new AccessControlDmlException(String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, arguments)); 
        }
        return returnNoPermissionFieldsNameList;
    }   
    
     /**
	* @description Returns a list of readable fields for the given object name
	* @param the object name to return the fields for
	* @return a list of fields that are read accessible
	*/  
    public List<Schema.SObjectField> returnPermissionFieldsNameList(String objName) {
    	return returnPermissionFieldsNameList(objName, new Set<String>{});
    }
    public List<Schema.SObjectField> returnPermissionFieldsNameList(String objName, Set<String> ignoreFieldSet) {
        List<Schema.SObjectField> returnPermissionFieldsNameList = new List<Schema.SObjectField>(); 
        Type objTypeName = Type.forName(objName);
        
        if (objTypeName != null) 
        {
            SObject sObj = (SObject)objTypeName.newInstance();             
            Schema.sObjectType objType = sObj.getSObjectType();
           
            Map<String, Schema.SObjectField> fieldInfoMap = null;
            Schema.DescribeSObjectResult objResult = null;
            
            if (objectFieldInfoMap.containsKey(objName))
            {
                fieldInfoMap = objectFieldInfoMap.get(objName);
                objResult = describeObjectMap.get(objName);
            }
            else
            {        
                objResult =  objType.getDescribe();     
                fieldInfoMap = objResult.fields.getMap();
                objectFieldInfoMap.put(objName, fieldInfoMap);    
                describeObjectMap.put(objName, objResult);           
            }
            
           
            if(objResult.isAccessible())
                   
            {           
               
                for( Schema.SObjectField tmpfield :fieldInfoMap.values())
                {         
                    DescribeFieldResult fldResult = tmpField.getDescribe();
                    // Added the check to ignore the ContractId field, as it was throwing not accessible error in the controller.
                    if(fldResult.isAccessible() && !CSM_Constants.CONTRACT_ID.equalsIgnoreCase(fldResult.getName()) && !ignoreFieldSet.contains(fldResult.getName()))
                    {                       
                        returnPermissionFieldsNameList.add(tmpfield);
                    }                   
                }
           }
           else
           {
               //throw exception Object is not accessible
               String[] arguments = new String[] {objName};          
               throw new AccessControlDmlException(String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, arguments)); 
           }
        }
        else 
        {
            //throw exception Invalid Object name
            String[] arguments = new String[] {objName};          
            throw new AccessControlDmlException(String.format(System.Label.CSM_MSG_INVALID_OBJECT_NAME, arguments)); 
        }
        return returnPermissionFieldsNameList;
    }   
    
     /**
		* @description Performs a CRUD check for object only
		* @param the object name to perform CRUD check on
		* @param the CRUD operation type
		* @return boolean
		*/      
    public Boolean objectCrudCheck(String objName, String operationType) {
        Boolean crudCheck = false;
        Type objTypeName = Type.forName(objName);
        
        if (objTypeName != null) 
        {
            SObject sObj = (SObject)objTypeName.newInstance();             
            Schema.sObjectType objType = sObj.getSObjectType();
            
           
            Schema.DescribeSObjectResult objResult = null;
            if (describeObjectMap.containsKey(objName))
            {               
                objResult = describeObjectMap.get(objName);
            }
            else
            {        
                objResult =  objType.getDescribe();    
                describeObjectMap.put(objName, objResult);           
            }
            
           
            if((operationType == CSM_Constants.DML_OPERATION_READ && objResult.isAccessible())
                    || (operationType == CSM_Constants.DML_OPERATION_DELETE && objResult.isDeletable())
                    || (operationType == CSM_Constants.DML_OPERATION_INSERT && objResult.isCreateable())
                    || (operationType == CSM_Constants.DML_OPERATION_UPDATE && objResult.isUpdateable())
                    || (operationType == CSM_Constants.DML_OPERATION_UPSERT && objResult.isCreateable() && objResult.isUpdateable()))
            {           
               
                return true;
           
            }         
        }
        return crudCheck;
    }
    
    public List<SelectOption> getFieldList(List <Schema.SObjectField> fieldList,
												Set<String> addedFields){
		List <SelectOption> soFieldList = new List <SelectOption> ();
		if(fieldList != null && !fieldList.isEmpty()){
	   		for (Schema.SObjectField tmpfield : fieldList) {
	   			Schema.DescribeFieldResult fieldDescribe = tmpfield.getDescribe();
				DisplayType fieldDisplayType = fieldDescribe.getType();
				if (fieldDescribe.isUpdateable()) {
					if (((!fieldDescribe.getName().toLowerCase().contains(CSM_Constants.CONTRACT_ID) && 
						fieldDescribe.isNillable() && !fieldDescribe.isCalculated())  || (string.valueOf(fieldDescribe.getType()) == 'BOOLEAN' )) && 
						!addedFields.contains(fieldDescribe.getName())){
						soFieldList.add(new SelectOption(fieldDescribe.getName(), tmpField.getDescribe().getLabel()));
					}	
				}
				else if(!addedFields.contains(fieldDescribe.getName()) && fieldDescribe.getName() == REN_Constants.OBJ_SC_TOTAL_PRICE)
				{
					soFieldList.add(new SelectOption(fieldDescribe.getName(), tmpField.getDescribe().getLabel()));
				}
			}
			CSM_Util.sortSelectOptionByLabel(soFieldList);
		}
		return soFieldList;
	}
	
	public Map<String, List<SelectOption>> getTypeToFieldListMap(List <Schema.SObjectField> fieldList){
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		Map<String, List<SelectOption>> typeToFieldListMap = new Map<String, List<SelectOption>>();
		if(fieldList != null && !fieldList.isEmpty()){
	   		for (Schema.SObjectField tmpfield : fieldList) {
	   			DisplayType fieldDisplayType = tmpfield.getDescribe().getType();
	   			
	   			//Modified for DE2989
	   			List<SelectOption> optionList = null;
                
                if(tmpField.getDescribe().getName() == (solnExtnNamespace + 'Local_CurrencyCode__c') && (Schema.getGlobalDescribe().containsKey('QuoteLineItem') ? Schema.getGlobalDescribe().get('QuoteLineItem').getDescribe().fields.getMap().containsKey(solnExtnNamespace + 'Local_CurrencyCode__c') : false)){
                    optionList = typeToFieldListMap.get('PICKLIST');
                }else{
	   				optionList = typeToFieldListMap.get(String.valueOf(fieldDisplayType));
                }
	   			
	   			if(optionList == null){
	   				optionList = new List<SelectOption>();
	   			}
	   			optionList.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
	   			if(tmpField.getDescribe().getName() == (solnExtnNamespace + 'Local_CurrencyCode__c') ){
                    typeToFieldListMap.put('PICKLIST',optionList);
                }else{
	   			 	typeToFieldListMap.put(String.valueOf(fieldDisplayType), optionList);
                }
	   		}
		}
		return typeToFieldListMap;
	}
	
	/** @description This method returns all the formula field from the given object, which has matching returnType. 
	  * @return If return type is null, it will return all formula fields,
	*/
	public List<SelectOption> getFormulaFields(List <Schema.SObjectField> fieldList, String returnType){
		List<SelectOption> optionList = new List<SelectOption>();
		boolean isAll = String.isBlank(returnType);
		if(fieldList != null && !fieldList.isEmpty()){
	   		for (Schema.SObjectField tmpfield : fieldList) {
	   			Schema.DescribeFieldResult fieldDescription = tmpfield.getDescribe();
	   			if(fieldDescription.IsCalculated()){
		   			DisplayType fieldDisplayType = fieldDescription.getType();
	   				if(isAll || returnType.equalsIgnoreCase(String.valueOf(fieldDisplayType))){
	   					optionList.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel() + ' (F)'));
	   				}
	   			}
	   		}
		}
		return optionList;
	}
	
	public List<SelectOption> getFieldsByType(List <Schema.SObjectField> fieldList, String returnType){
		List<SelectOption> optionList = new List<SelectOption>();
		boolean isAll = String.isBlank(returnType);
		if(fieldList != null && !fieldList.isEmpty()){
	   		for (Schema.SObjectField tmpfield : fieldList) {
	   			Schema.DescribeFieldResult fieldDescription = tmpfield.getDescribe();
	   			DisplayType fieldDisplayType = fieldDescription.getType();
   				if(isAll || returnType.equalsIgnoreCase(String.valueOf(fieldDisplayType))){
   					optionList.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
   				}
	   		}
		}
		return optionList;
	}
	
   /**
    * @description used to populate Field select list
    * @return a list of fields that have read access
    */
    public List<SelectOption> getFieldList(String selectedObject, 
    											Map<String, Schema.SObjectField> objectFieldMap, 
    											Map<String, Set<SelectOption>> objectSelectOptionMap, 
    											Map<String, Map<String, Set<SelectOption>>> objectDataTypeFieldMap) {
       try {
			List <SelectOption> soFieldList = new List <SelectOption> ();
			if (!String.isBlank(selectedObject)) {
				Set <SelectOption> selectOptionSet = new Set <SelectOption> ();
				Set <SelectOption> fieldSelectOptionSet;
				Map<String, Set<SelectOption>> fieldSelectOptionMap = new Map<String, Set <SelectOption>>();
				if (!objectSelectOptionMap.containsKey(selectedObject)) {
	           		List <Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(selectedObject);
					for (Schema.SObjectField tmpfield: fieldList) {
						DisplayType fieldDisplayType = tmpfield.getDescribe().getType();
						if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATE || 
							String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_STRING ||
							String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_INTEGER || 
							String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST || 
							String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DOUBLE || 
							String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_CURRENCY || 
							String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PERCENT) {
								
							if (fieldSelectOptionMap.containsKey(String.valueOf(fieldDisplayType)))	 {
								fieldSelectOptionSet = fieldSelectOptionMap.get(String.valueOf(fieldDisplayType));
							} else {
								fieldSelectOptionSet = new Set<SelectOption>();
							}
							
							selectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
							fieldSelectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
							fieldSelectOptionMap.put(String.valueOf(fieldDisplayType), fieldSelectOptionSet);
								
							objectFieldMap.put(tmpField.getDescribe().getName(), tmpfield); 
						}
					}
               		objectDataTypeFieldMap.put(selectedObject, fieldSelectOptionMap); 
               		objectSelectOptionMap.put(selectedObject, selectOptionSet);
				} else {
					selectOptionSet = objectSelectOptionMap.get(selectedObject);
				}
	            soFieldList.addAll(selectOptionSet);   
           }
           CSM_Util.sortSelectOptionByLabel(soFieldList);
           return soFieldList;
       } catch (Exception ex) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
           return null;
       }
	}
	
	
	public static Map<Id,boolean> hasEditRecordAccess(Set<Id> recordIds, String userId) {
		List<UserRecordAccess> userRecordsAccess = new List<UserRecordAccess>();
		Map<Id,boolean> editAccessMap = new Map<Id,boolean>();

		List<Id> listRecordIds = new List<Id>();
		listRecordIds.addAll(recordIds);

		Integer listLoop = Math.ABS(listRecordIds.size()/200) + 1;	 //2103 records will get the value of listLoop as 11 (ABS(2103/200) = 10 + 1 = 11)	
			
		if (!listRecordIds.isEmpty()) {
			for (Integer counter = 0; counter < listLoop; counter++) { //run the loop for the number of times e.x. 11 in our case
				List<Id> countedRecordIds = new List<Id>();
				for (Integer i = 0; i < 200; i++) {    //loop through 200 records sequentially in the list at a time and make the query 
														//ex. make the List from items List[0] to List[200] then from List[201] to List[400]..
					Integer listIdx = counter * 200 + i;  // ex: listIdx at the third counter = 3 * 200 + 0 = 600 and so on....
					if (listIdx < listRecordIds.size() && listRecordIds.get(listIdx) != null) {
						countedRecordIds.add(listRecordIds.get(listIdx));
					}
				}
				userRecordsAccess = [Select recordId,HasEditAccess from UserRecordAccess where recordID in :countedRecordIds and UserId=:userId limit 200];
				for(UserRecordAccess userRecordAccess: userRecordsAccess){
					editAccessMap.put(userRecordAccess.recordId, userRecordAccess.HasEditAccess);
				}						
			}
		}					
		return editAccessMap;
	}	
	
	public static Map<Id,boolean> isEditRecordAccess(Set<Id> recordIds, String userId) {
		List<UserRecordAccess> userRecordsAccess = new List<UserRecordAccess>();
		Map<Id,boolean> editAccessMap = new Map<Id,boolean>();

		userRecordsAccess = [Select recordId,HasEditAccess from UserRecordAccess where recordID in :recordIds and UserId=:userId limit 10000];
		for(UserRecordAccess userRecordAccess: userRecordsAccess){
			editAccessMap.put(userRecordAccess.recordId, userRecordAccess.HasEditAccess);
		}						
		return editAccessMap;
	}	


	
	public static Schema.SObjectType getObjectType(String objName) {
		String nameSpace = CSM_Util.getNamespace();
		if (objectNameMap == null || objectNameMap.IsEmpty()){
	        // Make the describeGlobal() call
	        objectNameMap = Schema.GetGlobalDescribe();
		}
		Schema.SObjectType objType;
		if (objectNameMap.containsKey(objName)){
			objType = objectNameMap.get(objName);
		}
		if (objectNameMap.containsKey(nameSpace + objName)){
			objType = objectNameMap.get(nameSpace + objName);
		}
		return objType;
	}
		
	public static Boolean hasObject(String objName) {
		if (objectNameMap == null || objectNameMap.IsEmpty()){
	        // Make the describeGlobal() call
	        objectNameMap = Schema.GetGlobalDescribe();
		}
		return objectNameMap.containsKey(objName);
	}
	
	public static Map<String, Schema.SObjectField> getFieldMap(String objName) {
		Map<String, Schema.SObjectField> fsMap = new Map<String, Schema.SObjectField>();
		String nameSpace = CSM_Util.getNamespace();
		if (objectNameMap == null || objectNameMap.IsEmpty()){
	        // Make the describeGlobal() call
	        objectNameMap = Schema.GetGlobalDescribe();
		}
		Schema.SObjectType objType;
		if (objectNameMap.containsKey(objName)){
			objType = objectNameMap.get(objName);
		}
		if (objectNameMap.containsKey(nameSpace + objName)){
			objType = objectNameMap.get(nameSpace + objName);
		}
		System.debug('ObjType - '+objType);
		if (objType!=null){
			// Get the sObject describe result for the Account object
			fsMap = objType.getDescribe().fields.getMap();
		}
		return fsMap;
	}
	
	public static Boolean hasField(String objName, String fieldName) {
		Boolean fieldExist = false; 
		String nameSpace = CSM_Util.getNamespace();
		Map<String, Schema.SObjectField> fsMap = getFieldMap(objName);
		//system.debug('\n~~~~fsMap: ' + fsMap.keySet());
		if (!fsMap.isEmpty()){
			if (fsMap.containsKey(fieldName) || fsMap.containsKey(namespace+fieldName) || fsMap.containsKey(fieldName.toLowerCase()) || fsMap.containsKey((namespace+fieldName).toLowerCase())){
				fieldExist = true;
			}
		}
		return fieldExist;
	}
	
	// typeName must be a valid API name (i.e. custom objects should be suffixed with "__c"):
	public static SObject newSObject(String objName) {
	    String nameSpace = CSM_Util.getNamespace();
		if (objectNameMap == null || objectNameMap.IsEmpty()){
	        // Make the describeGlobal() call
	        objectNameMap = Schema.GetGlobalDescribe();
		}
		Schema.SObjectType objType;
		if (objectNameMap.containsKey(objName)){
			objType = objectNameMap.get(objName);
		}
		if (objectNameMap.containsKey(nameSpace + objName)){
			objType = objectNameMap.get(nameSpace + objName);
		}
		System.debug('ObjType - '+objType);
		if (objType!=null){
	        return objType.newSObject();
	    }
	    // SObjects offer the only way in Apex to instantiate an object with a type determined at 
	    // runtime -- you can optionally pass an Id argument to instantiate an SObject for an 
	    // existing record:
	    return null;
	}
	
	public static Map<String, Schema.SobjectField> fetchAllFieldNames(Schema.SObjectType objectType)
	{
		Map<String, Schema.SobjectField> allFieldNames = new Map<String, Schema.SobjectField>();
		set<String> setFlds2Ignore = new set<String>();
        setFlds2Ignore.add('SyncedQuote');
		for(String F :(objectType.getDescribe().fields.getMap()).keySet())
		{
			Schema.SobjectField tmpF = (objectType.getDescribe().fields.getMap()).get(F);
			//if(!tmpF.getDescribe().isCalculated() && tmpF.getDescribe().isCreateable())
			{
				if(!setFlds2Ignore.contains(tmpF.getDescribe().getName()))
				{
					allFieldNames.put(tmpF.getDescribe().getName(), tmpF);
				}
			}
		}
		return allFieldNames;
	}
	
	public static Map<String,DescribeFieldResult> getTypeFromFieldnameObjectname(String objName, String refType, String fieldType)
	{
		Map<String,DescribeFieldResult> fieldTypeMap = new Map<String,DescribeFieldResult>();
		Type objTypeName = Type.forName(objName);
		System.debug('objTypeName - '+objTypeName);
        if (objTypeName != null) 
        {
            SObject sObj = (SObject)objTypeName.newInstance();    
            System.debug('SObj = '+sObj);         
            Schema.sObjectType objType = sObj.getSObjectType();
            
            Map<String, Schema.SObjectField> fieldInfoMap = null;
            Schema.DescribeSObjectResult objResult = null;
            if (describeObjectMap == null){
            	describeObjectMap = new  Map<String, Schema.DescribeSObjectResult>();
            }            
            if (objectFieldInfoMap == null){
            	objectFieldInfoMap = new Map<String,  Map<String, Schema.SObjectField>>();	
            }
            if (objectFieldInfoMap!=null && objectFieldInfoMap.containsKey(objName))
            {
                fieldInfoMap = objectFieldInfoMap.get(objName);
                objResult = describeObjectMap.get(objName);
            }
            else
            {    
                objResult =  objType.getDescribe();         
                fieldInfoMap = objResult.fields.getMap();
                objectFieldInfoMap.put(objName, fieldInfoMap); 
                describeObjectMap.put(objName, objResult);               
            }
            Schema.sObjectType sobjRefType;
            if (fieldType != null && refType != null) {
            	Type objRefType = Type.forName(refType);
            	SObject sObjRef = (SObject)objRefType.newInstance();    
	        	System.debug('SObj = '+sObj);         
    	    	sObjRefType = sObjRef.getSObjectType();
            }
            for (Schema.SObjectField tmpfield :fieldInfoMap.values())
            {
            	DescribeFieldResult fldResult = tmpField.getDescribe();
            	System.debug('fldResult -'+fldResult);
            	if (sobjRefType!=null && fieldType != null && refType != null) {
					if (String.valueOf(fldResult.getType()).toUpperCase() == fieldType && 
            			fldResult.getReferenceTo()[0] == sobjRefType){
            			fieldTypeMap.put(fldResult.getName(),fldResult);
            		}
            	} else {
            		fieldTypeMap.put(fldResult.getName(),fldResult);
            	}
            }
        }
    	return fieldTypeMap;
	}
	
	public Map<String,boolean> returnFieldIsCalculated(String objName)
	{
		Map<String,boolean> isCalculatedMap = new Map<String,boolean>();
		Type objTypeName = Type.forName(objName);
        if (objTypeName != null) 
        {
            SObject sObj = (SObject)objTypeName.newInstance();             
            Schema.sObjectType objType = sObj.getSObjectType();
            
            Map<String, Schema.SObjectField> fieldInfoMap = null;
            Schema.DescribeSObjectResult objResult = null;
            if (objectFieldInfoMap.containsKey(objName))
            {
                fieldInfoMap = objectFieldInfoMap.get(objName);
                objResult = describeObjectMap.get(objName);
            }
            else
            {    
                objResult =  objType.getDescribe();         
                fieldInfoMap = objResult.fields.getMap();
                objectFieldInfoMap.put(objName, fieldInfoMap); 
                describeObjectMap.put(objName, objResult);               
            }
            for (Schema.SObjectField tmpfield :fieldInfoMap.values())
            {
            	DescribeFieldResult fldResult = tmpField.getDescribe();
            	isCalculatedMap.put(fldResult.getName(),fldResult.isCalculated());
            }
        }
    	return isCalculatedMap;
	}
	
   /**
	* @description Returns reference object name for the given lookup field
	* @param the object name and lookup field name to return the reference object name
	* @return a string for the reference object name
	*/  
    public String returnReferenceFieldObjectName(String objName, String fieldName) {
        String nameSpace = CSM_Util.getNamespace();
        String strName = null;
        List<Schema.SObjectField> fieldListValues = returnPermissionFieldsNameList(objName);
        if(objectFieldInfoMap != null && objectFieldInfoMap.containsKey(objName)){
        	// DE748: Remove the namespace from the field name. As keys in the objectFieldInfoMap
        	// contains the field name without namespace.
        	//US2419 
           /* if(fieldName.startsWith(nameSpace)){
                fieldName = fieldName.removeStart(namespace).toLowerCase();
            } */
            Map<String, Schema.SObjectField> objFieldInfo = objectFieldInfoMap.get(objName);
            Schema.SObjectField fieldInfo = objFieldInfo.get(fieldName);
            if(String.valueOf(fieldInfo.getDescribe().getType()) == CSM_Constants.TYPE_REFERENCE){
                strName = fieldInfo.getDescribe().getReferenceTo()[0].getDescribe().getName();
            }
        }
        return strName;
    } 
    
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        //Get prefix from record ID
        //This assumes that you have passed at least 3 characters
        String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
        //Get schema information
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
        //Loop through all the sObject types returned by Schema
        for(Schema.SObjectType stype : gd.values()){
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            //Check if the prefix matches with requested prefix
            if(prefix!=null && prefix.equals(myIdPrefix)){
                objectName = r.getName();
                break;
            }
        }
        return objectName;
    }
}