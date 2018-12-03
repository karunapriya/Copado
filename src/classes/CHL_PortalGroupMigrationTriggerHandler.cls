/**
 * Created Date     : Sep 2, 2016
 * Developed By     : Tanvi, Comity Designs, Inc.
 *
 * Function         : This class is created for US1541 i.e. for Portal Group Migration requirement. It is handler class, which gets call from PortalGroup migration data trigger.
 * Support Email    : tanvi@comitydesigns.com
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Tanvi                    US1541              Sep 2, 2016         1.1                 @description
 *
 */
public with sharing class CHL_PortalGroupMigrationTriggerHandler extends CSM_TriggerManager.TriggerHandler {

    

    /**
     * @description On Load of Portal group migration data, portal group should get create along with the portal members.
     */
    public override void onAfterInsert( List<sObject> newRecords, Map<ID, sObject> newRecordsMap){   
        try {
            /*SS_LicenseCheck.getUserType();
            Boolean hasChannelAccess = SS_Constants.isChannelUser==true || SS_Constants.isChannelNetOpsUser==true; 
            if(hasChannelAccess == true){
            }*/
            CHL_PortalGroupMigrationTriggerHelper.handlePortalGroupCreation((Map<Id, CHL_PortalGroup_Migration_Data__c>)newRecordsMap);
        }
        catch(exception ex){
            REN_Util.setErrorInObjects (newRecords, ex);
        }
        
     }
}