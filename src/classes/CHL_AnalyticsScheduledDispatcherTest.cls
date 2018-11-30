/**
 * Created Date     : Dec 13, 2016
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Code coverage for GA/Segment batches.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj                  US1837              Dec 13, 2016            1.1                 @description
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
private class CHL_AnalyticsScheduledDispatcherTest {

    /**
     * Method to create test records once and use for all the methods in this test class
     */ 
    @testSetup 
    static void testSetupMethod() {
    	Account ac = CHL_TestUtility.partnerAccount();
      insert ac;
      system.assert(ac!=null);
      Contact con = CHL_TestUtility.partnerContact(ac.Id);
      insert con;
      system.assert(con!=null);
      CSM_Admin__c mycs = CSM_Admin__c.getValues(UserInfo.getOrganizationId());
      if(mycs == null) {
         mycs = new CSM_Admin__c(CHL_Segment_API_Key__c= 'testtocken');
         insert mycs;
       }   
    }
    
    // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
      Test.startTest();
            // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new CHL_AnalyticsBatchScheduledDispatcher());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
      String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      Test.stopTest();

     
   }
}