/**
 * Created Date     : Dec 8, 2016
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Will count total number of account by type.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj                  US1837              Dec 8, 2016         1.1                 @description
 *
 */
global with sharing class CHL_PartnerAccountAnalyticsBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    Set<Id> totalResellerAccount;
    Set<Id> totalDistributorAccount;
    String query;
    private final String TOTAL_DISTRIBUTOR_ACCOUNT;
    private final String TOTAL_RESELLER_ACCOUNT;
    private final String ALL_ACTIVE;
    private final String BATCH_END_POINT = 'https://api.segment.io/v1/batch';
    private final String RESELLER = 'Reseller';
    private final String DISTRIBUTOR= 'Distributor';
    
    public CHL_PartnerAccountAnalyticsBatch(){
        totalResellerAccount = new Set<Id>();
        totalDistributorAccount = new Set<Id>();
        TOTAL_DISTRIBUTOR_ACCOUNT = Label.CHL_GA_TOTAL_DISTRIBUTOR_ACCOUNT;
        TOTAL_RESELLER_ACCOUNT = Label.CHL_GA_TOTAL_RESELLER_ACCOUNT;
        ALL_ACTIVE = Label.CHL_GA_ALL_ACTIVE;
        if(Test.isRunningTest()){
            query = 'Select Id,CHL_Partner_Account_Type__c from Account';
        }else{
            query = 'Select Id,CHL_Partner_Account_Type__c from Account where isPartner = true';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        for(sObject obj: scope){
            if(String.valueOf(obj.get('CHL_Partner_Account_Type__c'))!=null && String.valueOf(obj.get('CHL_Partner_Account_Type__c')).equalsIgnoreCase('Reseller')){
                totalResellerAccount.add((Id)obj.get('Id'));
            }else if(String.valueOf(obj.get('CHL_Partner_Account_Type__c'))!=null && String.valueOf(obj.get('CHL_Partner_Account_Type__c')).equalsIgnoreCase('Distributor')){
                totalDistributorAccount.add((Id)obj.get('Id'));
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
       CHL_SegmentEventHandler.WrapperClass wrapper_ActiveAccDistributor = new CHL_SegmentEventHandler.WrapperClass(TOTAL_DISTRIBUTOR_ACCOUNT ,'Report',Label.CHL_GA_ACCOUNT_CATEGORY,ALL_ACTIVE ,totalDistributorAccount.size(),DISTRIBUTOR,null);
       CHL_SegmentEventHandler.WrapperClass wrapper_ActiveAccReseller = new CHL_SegmentEventHandler.WrapperClass(TOTAL_RESELLER_ACCOUNT ,'Report',Label.CHL_GA_ACCOUNT_CATEGORY,ALL_ACTIVE ,totalResellerAccount.size(),RESELLER ,null);
       
       List<CHL_SegmentEventHandler.WrapperClass> listOfWrapper = new List<CHL_SegmentEventHandler.WrapperClass>();
       listOfWrapper.add(wrapper_ActiveAccDistributor);
       listOfWrapper.add(wrapper_ActiveAccReseller);
       String req =  (JSON.serialize(listOfWrapper));
       req = '{"batch":'+req+',"integrations": {"All": true,"Google Analytics": true}}';
       
       CHL_SegmentCallout call = new CHL_SegmentCallout();
       call.sendCalloutToSegmentIdentity(req,BATCH_END_POINT);
         
    }
    
}