/**
 * Created Date     : Dec 2, 2016
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Batch for track Users in Google Analytics
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj S.                 US1837              Dec 2, 2016         1.1                 @description
 *
 */
global with sharing class CHL_CommunityAnalyticsBatch implements REN_IScheduleDispatched,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

 
    global Integer counterActiveUsersReseller = 0;
    global Integer counterActiveUsersDistributor = 0;
    global Integer counterNeverLoggedResellerUsr = 0;
    global Integer counterNeverLoggedDistributorUsr = 0;
    
    private final String BATCH_END_POINT = 'https://api.segment.io/v1/batch';
    global String query = '';
    Set<Id> NeverLoggedInReseller;
    Set<Id> NeverLoggedInDistributor;
    Set<Id> setResAccIds;
    Set<Id> setDisAccIds;
    Set<Id> loggedInAccIds;
    private final String RESELLER = 'Reseller';
    private final String DISTRIBUTOR= 'Distributor';
    private final String ALL_ACTIVE_USER_RESELLER;
    private final String ALL_ACTIVE_USER_DISTRIBUTOR ;
    private final String NEVER_LOGGED_IN_DISTRIBUTOR ;
    private final String NEVER_LOGGED_IN_RESELLER ;
    private final String NEVER_LOGGED_IN_DISTRIBUTOR_USERS ;
    private final String NEVER_LOGGED_IN_RESELLER_USERS ;
   
    private final String EVER_LOGGED_IN;
   
    private final String ALL_USER;
    global CHL_CommunityAnalyticsBatch(){
        NeverLoggedInReseller= new Set<Id>();
        NeverLoggedInDistributor= new Set<Id>();
        setResAccIds = new Set<Id>();
        setDisAccIds = new Set<Id>();
        loggedInAccIds = new Set<Id>();
        
        ALL_ACTIVE_USER_RESELLER =Label.CHL_GA_ALL_ACTIVE_USER_RESELLER;
        ALL_ACTIVE_USER_DISTRIBUTOR = Label.CHL_GA_ALL_ACTIVE_USER_DISTRIBUTOR;
        NEVER_LOGGED_IN_DISTRIBUTOR =Label.CHL_GA_NEVER_LOGGED_IN_DISTRIBUTOR;
        NEVER_LOGGED_IN_RESELLER =Label.CHL_GA_NEVER_LOGGED_IN_RESELLER;
        ALL_USER = Label.CHL_GA_ALL_USERS;
        EVER_LOGGED_IN = Label.CHL_GA_NEVER_LOGGED_IN;
        NEVER_LOGGED_IN_DISTRIBUTOR_USERS= Label.CHL_GA_NEVER_LOGGED_IN_DISTRIBUTOR_USR;
        NEVER_LOGGED_IN_RESELLER_USERS = Label.CHL_GA_NEVER_LOGGED_IN_RESELLER_USR;
        
        if(Test.isRunningTest()){
           query = 'Select id,Name, ContactId, LastLoginDate,AccountId,Account.CHL_Partner_Account_Type__c,UserType,isActive from User';
        }else{
           query = 'Select id,Name,isPortalEnabled ,ContactId, LastLoginDate,AccountId,Account.CHL_Partner_Account_Type__c,CHL_Use_Cookies_for_Channel__c, UserType,isActive from User where UserType = \'PowerPartner\' And ContactId != null'; 
        }
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
     }
    
     //Schedulable method
    global void execute(SchedulableContext schedulerContext){
    	Integer batchSize = CSM_Util.getCustomListSetting('CHL_CommunityAnalyticsBatch');
    	system.debug('batchSize----->'+batchSize);
    	batchSize = (batchSize == null || batchSize == 0) ? 1000 : batchSize;
        String batchprocessid = Database.executeBatch(this,batchSize);
    }
    
    
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        
        /*for(sObject obj: scope){
            setAccId.add((Id)obj.get('AccountId'));
        }
        mapOfAccount =new Map<Id,Account>(CSM_AccountDataAccess.getAccountInformationById(new List<Id>(setAccId)));
        for(Account obj: mapOfAccount.values()){
            //System.debug(''+obj);
            if(obj.CHL_Partner_Account_Type__c!=null && obj.CHL_Partner_Account_Type__c.equalsIgnoreCase(RESELLER)){
                //totalResellerAccount.add(obj.Id);
                NeverLoggedInReseller.add(obj.Id);
            }else if(obj.CHL_Partner_Account_Type__c!=null && obj.CHL_Partner_Account_Type__c.equalsIgnoreCase(DISTRIBUTOR)){
                //totalDistributorAccount.add(obj.Id);
                NeverLoggedInDistributor.add(obj.Id);
            }
        }*/
        List<User> userList = new List<User>();
        for(SObject obj: scope) {
	       userList.add((User)obj);
	    }
        for(User obj: userList){
        	Account acc = (Account)obj.getSobject('Account');
        	if(acc != null) {
	            if(obj.LastLoginDate != null){
	                if(acc.CHL_Partner_Account_Type__c !=null && acc.CHL_Partner_Account_Type__c.equalsIgnoreCase(RESELLER) && setResAccIds.contains(acc.Id)){
	                  setResAccIds.remove(acc.Id);
	                }else if(acc.CHL_Partner_Account_Type__c !=null && acc.CHL_Partner_Account_Type__c.equalsIgnoreCase(DISTRIBUTOR) && setDisAccIds.contains(acc.Id)){
	                  setDisAccIds.remove(acc.Id);
	                }
	                loggedInAccIds.add(acc.Id);
	            } else{
	              if(acc.CHL_Partner_Account_Type__c!=null && acc.CHL_Partner_Account_Type__c.equalsIgnoreCase(RESELLER)){
	                 counterNeverLoggedResellerUsr +=1;
	                 setResAccIds.add(acc.Id);
	              }else if(acc.CHL_Partner_Account_Type__c!=null && acc.CHL_Partner_Account_Type__c.equalsIgnoreCase(DISTRIBUTOR)){
	                 counterNeverLoggedDistributorUsr +=1;
	                 setDisAccIds.add(acc.Id);
	              }
	            }
            
	            if(obj.isActive && obj.CHL_Use_Cookies_for_Channel__c){
	                if(acc.CHL_Partner_Account_Type__c!=null && acc.CHL_Partner_Account_Type__c.equalsIgnoreCase(RESELLER )){
	                	counterActiveUsersReseller +=1;	
	                }else if(acc.CHL_Partner_Account_Type__c!=null && acc.CHL_Partner_Account_Type__c.equalsIgnoreCase(DISTRIBUTOR)){
	                	counterActiveUsersDistributor +=1;	
	                }
	            }
        	}
        } 
        
        setResAccIds.removeAll(loggedInAccIds);
        setDisAccIds.removeAll(loggedInAccIds);
    }
    
     global void finish(Database.BatchableContext BC){
        CHL_SegmentEventHandler eventHandler = CHL_SegmentEventHandler.newInstance();
        CHL_SegmentEventHandler.WrapperClass wrapper_userReseller = new CHL_SegmentEventHandler.WrapperClass(ALL_ACTIVE_USER_RESELLER ,'Report',Label.CHL_GA_USER_CATEGORY,ALL_USER ,counterActiveUsersReseller,RESELLER ,null);
        CHL_SegmentEventHandler.WrapperClass wrapper_userDistributor = new CHL_SegmentEventHandler.WrapperClass(ALL_ACTIVE_USER_DISTRIBUTOR ,'Report',Label.CHL_GA_USER_CATEGORY,ALL_USER ,counterActiveUsersDistributor,DISTRIBUTOR,null);
        CHL_SegmentEventHandler.WrapperClass wrapper_NeverLoggedInDistributor = new CHL_SegmentEventHandler.WrapperClass(NEVER_LOGGED_IN_DISTRIBUTOR ,'Report',Label.CHL_GA_ACCOUNT_CATEGORY,EVER_LOGGED_IN,setDisAccIds.size(),DISTRIBUTOR,null);
        CHL_SegmentEventHandler.WrapperClass wrapper_NeverLoggedInReseller = new CHL_SegmentEventHandler.WrapperClass(NEVER_LOGGED_IN_RESELLER ,'Report',Label.CHL_GA_ACCOUNT_CATEGORY,EVER_LOGGED_IN,setResAccIds.size(),RESELLER ,null);
        CHL_SegmentEventHandler.WrapperClass wrapper_NeverLoggedInDistributorUsr = new CHL_SegmentEventHandler.WrapperClass(NEVER_LOGGED_IN_DISTRIBUTOR_USERS ,'Report',Label.CHL_GA_USER_CATEGORY,EVER_LOGGED_IN,counterNeverLoggedDistributorUsr,DISTRIBUTOR,null);
        CHL_SegmentEventHandler.WrapperClass wrapper_NeverLoggedInResellerUsr = new CHL_SegmentEventHandler.WrapperClass(NEVER_LOGGED_IN_RESELLER_USERS ,'Report',Label.CHL_GA_USER_CATEGORY,EVER_LOGGED_IN,counterNeverLoggedResellerUsr,RESELLER ,null);
        
        List<CHL_SegmentEventHandler.WrapperClass> listOfWrapper = new List<CHL_SegmentEventHandler.WrapperClass>();
        listOfWrapper.add(wrapper_userReseller);
        listOfWrapper.add(wrapper_userDistributor);
        listOfWrapper.add(wrapper_NeverLoggedInDistributor);
        listOfWrapper.add(wrapper_NeverLoggedInReseller);
        listOfWrapper.add(wrapper_NeverLoggedInDistributorUsr);
        listOfWrapper.add(wrapper_NeverLoggedInResellerUsr);
        
        String req =  (JSON.serialize(listOfWrapper));
        req = '{"batch":'+req+',"integrations": {"All": true,"Google Analytics": true}}';
        
            
        CHL_SegmentCallout call = new CHL_SegmentCallout();
        call.sendCalloutToSegmentIdentity(req,BATCH_END_POINT);
        CHL_PartnerAccountAnalyticsBatch accBatch = new CHL_PartnerAccountAnalyticsBatch();
        Integer batchSize = CSM_Util.getCustomListSetting('CHL_PartnerAccountAnalyticsBatch');
        batchSize = (batchSize == null || batchSize == 0) ? 1000 : batchSize;
        Database.executeBatch(accBatch,batchSize);
        
     }
     
}