/**
* @author         Eswar Bala(eswar@comitydesigns.com)
* @date           05.25.2016
* @description    AccessController class performs CRUD/FLS checks
*/
global with sharing class AccessController {
     
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
    private static AccessController instance = null;
    
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
    private AccessController()
    {
        objectFieldInfoMap = new Map<String,  Map<String, Schema.SObjectField>>();
        describeObjectMap = new  Map<String, Schema.DescribeSObjectResult>();
    }
    
    /**
    * @description a static method that returns the instance of the Controller
    */
    public static AccessController getInstance()
    {
        if(instance == null) 
        {
            instance = new AccessController();
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
        List<String> returnNoPermissionFieldsNameList = new List<String>(); 
        Type objTypeName = Type.forName(objName);
        String nameSpace = Util.solnExtnNameSpace;
        String fldName;
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
            
            if((operationType == Constants.DML_OPERATION_READ && objResult.isAccessible())
                    || (operationType == Constants.DML_OPERATION_INSERT && objResult.isCreateable())
                    || (operationType == Constants.DML_OPERATION_UPDATE && objResult.isUpdateable())
                    || (operationType == Constants.DML_OPERATION_UPSERT && objResult.isCreateable() && objResult.isUpdateable()))
            {      
            	String orignalFieldName = '';     
                for(String fieldName :fieldNames){
                	if(String.isBlank(fieldName)){
                		continue;
                	}
                	orignalFieldName = fieldName;
                	//Start -- Added for US3587
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
                    //End -- Added for US3587
                    if( tmpfield != null ){
                        DescribeFieldResult fieldDefinition = tmpfield.getDescribe();
						if(operationType == Constants.DML_OPERATION_READ && !(fieldDefinition.isAccessible())){    
							System.debug('\n1. AccessController~~~~fieldName: ' + fieldName);                   
							returnNoPermissionFieldsNameList.add(tmpfield.getDescribe().getLabel());                        
						}else if(operationType != Constants.DML_OPERATION_READ && !fieldDefinition.isUpdateable() && !fieldName.equalsIgnoreCase('Id')){ 
							System.debug('\n2.2 CSM_AccessController~~~~Possible edit permission Error: ' + tmpfield);  
							returnNoPermissionFieldsNameList.add(tmpfield.getDescribe().getLabel());
						}
                    }else{
                    	System.debug('\n3. AccessController~~~~fieldName: ' + fieldName);
                        String[] arguments = new String[] {fieldName};         
                        throw new AccessControlDmlException(String.format(Label.MSG_INVALID_FIELD_NAME, arguments)); 
                    }   
                }
           }else if(operationType == Constants.DML_OPERATION_DELETE){
               if (!objResult.isDeletable()){
               	   system.debug('\n\n @@@ AccessControlDmlException : deleteable :: ' + objName);
                   // throw exception it is not deleteable
                   throw new AccessControlDmlException(objName + ' ' + Label.MSG_OBJECT_NOT_DELETE);
               }
           }else{
               system.debug('\n\n @@@ AccessControlDmlException : OBJ Type :: ' + objName);
               // throw exception 
               String[] arguments = new String[] {objName}; 
               throw new AccessControlDmlException(String.format(Label.MSG_NO_OPTYPE_OBJECT, new String[]{operationType, objName}));
           }
        }else {
            //throw exception Invalid Object name
            String[] arguments = new String[] {objName};      
            throw new AccessControlDmlException(String.format(Constants.INVALID_OBJECT_NAME, arguments)); 
        }
        return returnNoPermissionFieldsNameList;
    }   
    
     public static Boolean hasObject(String objName) {
		if (objectNameMap == null || objectNameMap.IsEmpty()){
	        // Make the describeGlobal() call
	        objectNameMap = Schema.GetGlobalDescribe();
		}
		return objectNameMap.containsKey(objName);
	}
	
	public static SObject newSObject(String objName) {
	   // String nameSpace = Util.solnExtnNameSpace;
		if (objectNameMap == null || objectNameMap.IsEmpty()){
	        // Make the describeGlobal() call
	        objectNameMap = Schema.GetGlobalDescribe();
		}
		Schema.SObjectType objType;
		if (objectNameMap.containsKey(objName)){
			objType = objectNameMap.get(objName);
		}
		if (objectNameMap.containsKey(objName)){
			objType = objectNameMap.get(objName);
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

}