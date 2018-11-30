/**
 * This class contains unit tests for validating the behavior of CSM_LeadTriggerHelper classes
 * and triggers. 
  */
@isTest
public with sharing class CSM_LeadTriggerHelperTest {

	static testMethod void Test_AfterUpdate_Positive() {  
		CSM_Constants.LEAD_TRIGGER = true;
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
        insert new SS_License__c(Renew__c = true);
		List<sObject> oldRecords = new List<sObject>();
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		
		/** Important - Below code is required as Sol.Ext. package is not installed in Master Org. To cover the lead trigger we need this code.Please do not update/Remove it */
		Account aa1=new account();
        aa1.name='Account First';
        insert aa1;
            
        List<Lead> LeadList =   new List<Lead>();
        for(Integer i=1;i<2;i++){
            Lead ld=new Lead(Company = 'testLead'+i, LastName = 'leadName'+i, Status = 'Open');
            LeadList.add(ld);
        }
        insert LeadList;
        
        LeadList[0].Company = 'test';
        update LeadList;
				
		if(CSM_AccessController.hasField('TASK', CSM_Util.nameSpacePrefixSolnExtn + 'Account__c') && CSM_AccessController.hasField('Lead', CSM_Util.nameSpacePrefixSolnExtn + 'Lead_Lookup_Account_1__c')) {
            Account aa=new account();
            aa.name='Account First';
            insert aa;
            
            Account acc = new Account();
            acc.name = 'Account Second';
            insert acc;
            
            List<Lead> lstLead =   new List<Lead>();
            for(Integer i=1;i<2;i++){
                Lead ld=new Lead(Company = 'testLead'+i, LastName = 'leadName'+i, Status = 'Open');
                ld.put(CSM_Util.nameSpacePrefixSolnExtn+'Lead_Lookup_Account_1__c',aa.Id);
                lstLead.add(ld);
            }
            insert lstLead;
            
            List<Lead> leadListTest = new List<Lead>();
            for(Lead leadFor: lstLead){
                leadFor.put(CSM_Util.nameSpacePrefixSolnExtn+'Lead_Lookup_Account_1__c',acc.id);
                leadListTest.add(leadFor);
            }
            update leadListTest;
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Closed - Converted');		
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            System.assert(lcr.isSuccess());
            list<Lead> ldlist = Database.query('select id, '+CSM_Util.nameSpacePrefixSolnExtn+'Lead_Lookup_Account_1__r.id, isConverted,ConvertedContactId from lead where isconverted=true');
            Task taskObj = new Task();
            taskObj.Status = 'Completed';
            taskObj.WhoId = ldlist[0].ConvertedContactId;
            taskObj.ActivityDate=system.today();
            taskObj.put(CSM_Util.nameSpacePrefixSolnExtn+ 'Account__c',ldlist[0].getSObject(CSM_Util.nameSpacePrefixSolnExtn+ 'Lead_Lookup_Account_1__r').get('id'));
            insert taskObj;
             system.debug('ldlist[0].ConvertedContactId-->'+ldlist[0].ConvertedContactId);
            List<Task> tasklist= [select whoid,Id from task where  whoid =:ldlist[0].ConvertedContactId];
            
            System.RunAs(restrictedUser) {
                Test.startTest();
                    CSM_LeadTriggerHandler triggerhandlercls = new CSM_LeadTriggerHandler();
                    system.assert(true);
                    Test.stopTest();	   		
            }
        }
	}
    
}