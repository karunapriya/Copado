/**
 * Created Date     : Sep 13, 2016
 * Developed By     : admin, Comity Designs, Inc.
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
 * Dheeraj                   US1572              Sep 13, 2016        1.1                 @description
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class CSM_BatchUpdateOldDataSPPLSPPBTest {

    
       
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        List<CSM_Account_Plan_Template__c> listOfTemp = CSM_TestDataUtility.createAccountPlanTemplateData(2);
        List<CSM_Playbook__c> listOfPb = CSM_TestDataUtility.createPlaybooks(2);
        List<CSM_Play__c> listOfPlay = CSM_TestDataUtility.createPlayTestData(2);
        List<Account> listOfAcct = CSM_TestDataUtility.createAccount(1);
        List<CSM_Account_Plan__c> listOfSP = CSM_TestDataUtility.createAccountPlan(listOfAcct!=null?listOfAcct:null,listOfTemp!=null&&listOfTemp.size()>0?listOfTemp.get(0).id:null);
        System.assertEquals(listOfSP.size(),1);
        CSM_TestDataUtility.createPlaybookPlayTestData(listOfPb!=null&&listOfPb.size()>0?listOfPb.get(0).id:'',listOfPlay!=null&&listOfPlay.size()>0?listOfPlay.get(0).id:'');
        
        List<CSM_Account_Plan_Playbook__c> mPlPb = CSM_TestDataUtility.createAccountPlanPlaybookData(null,listOfTemp!=null&&listOfTemp.size()>0?listOfTemp.get(0).id:'',listOfPb!=null&&listOfPb.size()>1?new List<String>{listOfPb.get(0).id,listOfPb.get(1).id}:new List<String>());
        CSM_TestDataUtility.createAccountPlanPlaybookData(null,null,listOfPb!=null&&listOfPb.size()>1?new List<String>{listOfPb.get(0).id,listOfPb.get(1).id}:new List<String>());
        CSM_TestDataUtility.createAccountPlanPlaybookData(null,listOfTemp.get(1).id,listOfPb!=null&&listOfPb.size()>1?new List<String>{listOfPb.get(0).id,listOfPb.get(1).id}:new List<String>());
        
        Test.startTest();
         CSM_BatchUpdateOldDataSPPLSPPB mBatch = new CSM_BatchUpdateOldDataSPPLSPPB();
         database.executebatch(mBatch);
        Test.stopTest();    
    }
    
    static testMethod void myUnitSchedulerTest() {
        List<CSM_Account_Plan_Template__c> listOfTemp = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Playbook__c> listOfPb = CSM_TestDataUtility.createPlaybooks(1);
        List<CSM_Play__c> listOfPlay = CSM_TestDataUtility.createPlayTestData(1);
        List<Account> listOfAcct = CSM_TestDataUtility.createAccount(1);
        List<CSM_Account_Plan__c> listOfSP = CSM_TestDataUtility.createAccountPlan(listOfAcct!=null?listOfAcct:null,listOfTemp!=null&&listOfTemp.size()>0?listOfTemp.get(0).id:null);
        System.assertEquals(listOfSP.size(),1);
        CSM_TestDataUtility.createPlaybookPlayTestData(listOfPb!=null&&listOfPb.size()>0?listOfPb.get(0).id:'',listOfPlay!=null&&listOfPlay.size()>0?listOfPlay.get(0).id:'');
        
        List<CSM_Account_Plan_Playbook__c> mPlPb = CSM_TestDataUtility.createAccountPlanPlaybookData(null,listOfTemp!=null&&listOfTemp.size()>0?listOfTemp.get(0).id:'',listOfPb!=null&&listOfPb.size()>0?new List<String>{listOfPb.get(0).id}:new List<String>());
            
        Test.startTest();
    
        // Schedule the test job
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
        String jobId = System.schedule('ScheduleApexClassTest',
                            strDateTime, 
                            new CSM_BatchUpdateOldDataSPPLSPPBDspatchr());
        Test.StopTest();  
          
    }
    
}