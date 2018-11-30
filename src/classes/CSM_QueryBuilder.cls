public with sharing class CSM_QueryBuilder {
    private String internalQuery;
    /** Base fields for the query */
    private String baseFields;

    /** SObject name */
    private String objectName;

    public String Query {
        get {
            return this.internalQuery;
        }
    }

    /**
     * Constructor
     *
     * @param objectName sobject name
     * @param baseFields base fields for the query for the object
     */
    public CSM_QueryBuilder(String objectName, String baseFields) {
        this.baseFields = baseFields;
        this.objectName = objectName;
    } 

    public void AddCondition(String operator, String idFieldName, String idValue) {
            this.internalQuery += ' ' + String.escapeSingleQuotes(operator) + ' ' + String.escapeSingleQuotes(idFieldName) + ' = \'' + String.escapeSingleQuotes(idValue) + '\'';
        }
        
   /**
     * Builds and returns the query string according to the given fieldname and value
     *
     * @param idFieldName field name of the id
     * @param idValue value of the field name
     * @returns query according to the given parameters
     */
    public String GetQueryByIdList(String idFieldName, List<String> idValues) {
        internalQuery = '';
        internalQuery = GetQueryAll();
        internalQuery += ' WHERE ' + String.escapeSingleQuotes(idFieldName) + ' IN ';
        internalQuery += '(';
        for (String value: idValues) {
            internalQuery += '\'' + String.escapeSingleQuotes(value) + '\',';
        }
        internalQuery = internalQuery.substring(0, internalQuery.length() - 1);
        internalQuery += ')';
        return internalQuery;
    }
    
    /**
     * Builds and returns the query string according to the given fieldname and value
     *
     * @param idFieldName field name of the id
     * @param idValue value of the field name
     * @returns query according to the given parameters
     */
    public String GetQueryById(String idFieldName, String idValue) {
        internalQuery = '';
        internalQuery = GetQueryAll();
        AddCondition(' WHERE ',idFieldName,idValue);
      
        return internalQuery;
    }

    /**
     * Builds and returns the query string
     * @returns query string query
     */
    public String GetQueryAll() {
       internalQuery = '';
       internalQuery = 'SELECT';
       
       if (this.baseFields != null && this.baseFields != '') {
           internalQuery += ' ' + baseFields + ',';
          
       }
       Schema.Describefieldresult fldResult;
       String namespace = CSM_Util.getNamespace();
       
       if (nameSpace!=null && nameSpace.length()>0){
           objectName = CSM_Util.getNamespace() + objectName;
       } 
       for (Schema.SObjectField field: CSM_Util.GetSObjectFieldsMap(objectName).values()) {
           try {
               fldResult = field.getDescribe();
               internalQuery += ' ' + fldResult.getName() + ',';
              
           } catch (System.SObjectException ex) {
            
               continue;
           }
       }
      
       internalQuery = internalQuery.substring(0, internalQuery.length() - 1);
       internalQuery += ' FROM ' + objectName;
       return internalQuery;
   }
}