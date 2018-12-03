/**
 * Created Date     : Jan 13, 2017
 * Developed By     : Tanvi, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Tanvi                    User Story              Jan 13, 2017            1.1                 @description
 *
 */
public with sharing class REN_LowTouchClientDataAccess {

   	public static List<REN_Low_Dollar_Client__c> lstOfLTClient;
    
	public static List<REN_Low_Dollar_Client__c> getLowDollarClientDetails() {
        List<String> lowtouchclientFields = new List<String>{'REN_Logo_URL__c','REN_Docusign__c', 'REN_Expose_OLI__c', 'REN_Live_Agent__c','REN_PO_Upload__c','REN_Request_Contact_Case_Type__c','REN_OAuth_Credentials__c','REN_Low_Touch_Admin_URL__c','REN_Asparato_Payment__c'};
        CSM_Util.checkCRUD_FLS('REN_Low_Dollar_Client__c', lowtouchclientFields , 'Read'); 
         
        if(lstOfLTClient==null){
            lstOfLTClient = [Select Id, name,REN_Logo_URL__c, REN_Expose_OLI__c, REN_Docusign__c,REN_Asparato_Payment__c,REN_Live_Agent__c,REN_PO_Upload__c,REN_Request_Contact_Case_Type__c,REN_Low_Touch_Admin_URL__c,REN_OAuth_Credentials__c from REN_Low_Dollar_Client__c limit 1];
        }
        return lstOfLTClient;
	}
    
    public static List<REN_Low_Dollar_Client__c> getLowTouchRecords(){
        List<String> lowtouchclientFields = new List<String>{'Ren_Oauth_Credentials__c','REN_Low_Touch_Admin_URL__c'};
        CSM_Util.checkCRUD_FLS('REN_Low_Dollar_Client__c',lowtouchclientFields ,'Read');
        return Database.query('select name, id, ren_oauth_credentials__c,REN_Low_Touch_Admin_URL__c,format(createddate),' +
                              'createdById,createdBy.name,format(lastmodifieddate),lastmodifiedbyId,lastmodifiedby.name from REN_Low_Dollar_Client__c  where REN_Low_Touch_Admin_URL__c != null');                 
    }
    
    public static REN_Low_Dollar_Client__c getLowTouchRecordsById(String recordId){
         List<String> lowtouchclientFields = new List<String>{'Ren_Oauth_Credentials__c','REN_Low_Touch_Admin_URL__c'};
        CSM_Util.checkCRUD_FLS('REN_Low_Dollar_Client__c',lowtouchclientFields ,'Read');
        return [select name, id, ren_oauth_credentials__c, REN_Low_Touch_Admin_URL__c,
                        format(createddate), createdById, createdBy.name, format(lastmodifieddate), 
                        lastmodifiedbyId, lastmodifiedby.name 
                from REN_Low_Dollar_Client__c
                where id = :recordId];                 
    }
    
    public static boolean deleteLowTouchRecord(List<REN_Low_Dollar_Client__c> recordList){
       List<String> lowtouchclientFields = new List<String>{'REN_Low_Touch_Admin_URL__c'};
       CSM_Util.checkCRUD_FLS('REN_Low_Dollar_Client__c', lowtouchclientFields, 'Update'); 
       if(Schema.sObjectType.REN_Low_Dollar_Client__c.isUpdateable()){
             update recordList;
             return true;
        }      
        return false;
    }
    
    public static List<REN_Low_Dollar_Client__c> getLowtouchClientRecordForGuestUser() {
        List<String> lowtouchclientFields = new List<String>{'REN_Live_Agent__c', 'REN_Logo_URL__c'};
        CSM_Util.checkCRUD_FLS('REN_Low_Dollar_Client__c', lowtouchclientFields, 'Read'); 
        return [SELECT Id, REN_Live_Agent__c, REN_Logo_URL__c, Name from REN_Low_Dollar_Client__c limit 1];
    }
    
    
}