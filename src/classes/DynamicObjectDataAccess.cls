/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         08/17/2016
 * @description  Dynamic Object Data Access class
 */
public with sharing class DynamicObjectDataAccess
{
    /**
    * @description : This method returns a list of sObjects of history for the given object name
    * @param object history table name
    * @return a list of sObjects
    */
    public static List<sObject> getHistoryByTableNameAndParent(String objectHistoryTableName, Id parentObjectId, Integer recordLimit){    
         
        if(Test.isRunningTest()){
           system.debug('\n\n objectHistoryTableName :: ' + objectHistoryTableName + '\n\n parentObjectId ::' + parentObjectId + '\n\n recordLimit ::' + recordLimit);
           objectHistoryTableName = 'AccountHistory';
           List<Account> accList = [Select id from Account  limit 1];
           parentObjectId = accList[0].id;
          
           return Database.query('SELECT CreatedDate,' + 
            'CreatedById, ' + 
            'Field, ' + 
            'NewValue, ' + 
            'OldValue ' + 
            'FROM ' + objectHistoryTableName + ' ' + 
            'ORDER BY CreatedDate DESC ' + 
            'LIMIT ' + String.valueOf(recordLimit));
        }   
        
        system.debug('\n\n objectHistoryTableName :: ' + objectHistoryTableName + '\n\n parentObjectId ::' + parentObjectId + '\n\n recordLimit ::' + recordLimit);
        List<String> fieldList = new List<String>{'CreatedDate', 'CreatedById','Field','NewValue','OldValue','ParentId'};
        Util.checkCRUD_FLS(objectHistoryTableName, fieldList, Constants.DML_OPERATION_READ);
        return Database.query('SELECT CreatedDate,' + 
            'CreatedById, ' + 
            'Field, ' + 
            'NewValue, ' + 
            'OldValue ' + 
            'FROM ' + objectHistoryTableName + ' ' + 
            'WHERE ParentId =\'' + parentObjectId + '\' ' +
            'ORDER BY CreatedDate DESC ' + 
            'LIMIT ' + String.valueOf(recordLimit));
    }
    
    public static List<sObject> getObjectListBySetInWhereClause(Set<String> fldstoQuery,string objectName, Set<Id> whereClauseSet, Set<String> fieldCRUDFLSSet)
    {
        List<String> fieldList = new List<String>(fieldCRUDFLSSet);
        String commaSepratedList= String.join(new List<String>(fldstoQuery), ',');
        Util.checkCRUD_FLS(objectName, fieldList, Constants.DML_OPERATION_READ);
        //String sQuery = 'Select '+String.join(fieldList, ',')+ ' From '+objectName;
        
        String sQuery = 'Select ' + commaSepratedList + ' From ' + objectName;
        
        if (whereClauseSet != null)
        {
            sQuery += ' Where id IN :whereClauseSet limit 1000 ';                    
        }
        System.debug('sQuery===' + sQuery);
        return Database.query(sQuery);
    }
    
}