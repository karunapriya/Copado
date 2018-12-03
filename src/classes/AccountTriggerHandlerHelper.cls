public with sharing class AccountTriggerHandlerHelper {
    public static void handleAccountList( List<sObject> newRecords, Map<ID, sObject> newRecordsMap ){
        EntitlementUtils.EntitlementCreation(newRecords);
    }
}