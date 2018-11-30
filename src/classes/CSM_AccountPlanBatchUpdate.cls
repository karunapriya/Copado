global with sharing class CSM_AccountPlanBatchUpdate implements Schedulable, Database.Batchable<sObject>, Database.Stateful {

	//Variables
	global final String Query;
	public Integer testJobSize {get;set;}
    public Integer processSize {get;set;}
    public boolean isNegativeTest {get;set;}    
	//public List<CSM_Account_Plan__c> acctPlanList {get; set;}
	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();		
	
	//Schedulable method
    global void execute(SchedulableContext SC)
    { 
    	ID batchprocessid = Database.executeBatch(this);
        //System.abortJob(SC.getTriggerId());
    }
    
    //Constructor
	global CSM_AccountPlanBatchUpdate()
	{
		//acctPlanList = new List<CSM_Account_Plan__c>();
		String namespace = CSM_Util.getNameSpace();
		Query = 'select Id, '+ namespace + 'CSM_Account_Plan_Template__c, '
		                     + namespace + 'CSM_Phase_Start_date__c, CSM_AccountId__c, '
		                     + namespace + 'CSM_CurrentPhase__c from '
		                     +  namespace + 'CSM_Account_Plan__c ';
	}
	
	//Start method
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		Database.QueryLocator  qLocator = null;
        String jobId = BC.getJobId();
        try
        {    
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CSM, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CSM_Constants.OBJ_ACCOUNT, 
									jobId);
			        	
        	//build query locator for the batch execute
	        qLocator = Database.getQueryLocator(this.Query);
			if(Test.isRunningTest()  && isNegativeTest){
				throw new CSM_AccessController.AccessControlDmlException();
			}
	        
        }
        catch (Exception ex)
        {
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();

			System.abortJob(jobId);

        }
        return qLocator;
	}

	//Execute method
	global void execute(Database.BatchableContext BC,List<CSM_Account_Plan__c> scope)
	{
		String jobId = BC.getJobId();
		try
		{
			Map<ID, String> accountPlanCurrentPhaseMap = CSM_Util.getCurrentPhase(scope);
			List<CSM_Account_Plan__c> updateList = new List<CSM_Account_Plan__c>();
			//List<Account> updatedFlagAccountList = new List<Account>();
			for(CSM_Account_Plan__c ap : scope)
			{
				ap.CSM_CurrentPhase__c = accountPlanCurrentPhaseMap.get(ap.Id);
				updateList.add(ap);
				//acctPlanList.add(ap);
				// Load Testing Fix: Removing this code as it will be handled in trigger.
				//updatedFlagAccountList.add(new Account(Id=ap.CSM_AccountId__c, CSM_Account_Has_Success_Plan__c = true));
			}
			CSM_AccountPlanDataAccess.updateAccountPlanList(updateList);
			//CSM_AccountPlanDataAccess.setAccountsHavingPlanFlag(updatedFlagAccountList);			
 			logger.updateRecordsProcessed(batchResult, scope.size());
 			
			if(Test.isRunningTest() && isNegativeTest){
				throw new CSM_AccessController.AccessControlDmlException();
			}
		}
		catch (exception ex)
        {
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;			
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
            System.abortJob(jobId);
        }
	}
	 
	global void finish(Database.BatchableContext BC)
	{
		batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		batchResult.CSM_Batch_Completion_Time__c = system.now();		
		logger.saveLogRecords();
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
	}
	
	/*private void setPlanExistsFlagAccount(){
		List<Account> accountHavingPlan = new List<Account>();
		List<Account> accountNotHavingPlan = new List<Account>();
		List<Account> finalAccountHavingPlan = new List<Account>();
		List<Account> finalAccountNotHavingPlan = new List<Account>();
				
		accountHavingPlan = CSM_AccountPlanDataAccess.getAccountsHavingPlan(null);
		for (Account acct: accountHavingPlan){
			if(acct.CSM_Account_Has_Success_Plan__c == false){
				acct.CSM_Account_Has_Success_Plan__c = true;
				finalAccountHavingPlan.add(acct);			
			}
		}

		if(!finalAccountHavingPlan.isEmpty()){
			CSM_AccountPlanDataAccess.setAccountsHavingPlanFlag(finalAccountHavingPlan);//update finalAccountHavingPlan;		
		}

		accountNotHavingPlan = CSM_AccountPlanDataAccess.getAccountsNotHavingPlan(null);
		for (Account acct: accountNotHavingPlan){
			if(acct.CSM_Account_Has_Success_Plan__c == true){
				acct.CSM_Account_Has_Success_Plan__c = false;
				finalAccountNotHavingPlan.add(acct);							
			}
		}
		if(!finalAccountNotHavingPlan.isEmpty()){
			CSM_AccountPlanDataAccess.setAccountsHavingPlanFlag(finalAccountNotHavingPlan);			
		}
	 }*/
	
}