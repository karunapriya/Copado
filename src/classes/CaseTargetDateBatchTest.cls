/**
 * Created Date		: Nov 7, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Nov 7, 2016			1.1					@description
 * 
 */
@isTest
public class CaseTargetDateBatchTest {

	@isTest
    static void caseTargetDateBatchSchedulerTest() {
		Test.startTest(); 
			String strDateTime = (System.now().addMinutes(1)).format('ss mm HH dd MM ? yyyy');
			String jobID = system.schedule('Case TargetDate Scheduler', strDateTime, new CaseTargetDateScheduledDispatcher());	
			System.assert(jobID != null);
	    Test.stopTest();
	}
	@isTest
    static void caseTargetDateBatchTest() {
		Test.startTest(); 
			String jobID = Database.executeBatch(new CaseTargetDateBatch());
			System.assert(jobID != null);
	    Test.stopTest();
	}
}