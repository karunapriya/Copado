/**
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
 */
@isTest
private class CSM_PlaybooksComponentControllerTest {
    static User adminUser;
    public static List<CSM_PlaybookPlay__c> playbookPlay;
    public static List<CSM_Playbook__c> playbook;
    
    private static void init() {
        CSM_Constants.PLAY_RESULT_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;

        CSM_TestUtility.setup();
        List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(CSM_TestUtility.play.id));
        List<CSM_Play_Task__c> createPlayTask= CSM_TestDataUtility.createPlayTaskData(String.valueOf(CSM_TestUtility.play.id));
        playbookPlay = [select id from CSM_PlaybookPlay__c where id = :CSM_TestUtility.playBookPlay.id];
        playbook = [select id from CSM_Playbook__c where id = :CSM_TestUtility.playBook.id];
    }
    
    static testMethod void clonePlaybookTest() {
         CSM_TestUtility.addLicense();
         CSM_TestUtility.addCSMAdmin();
         init();
         adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
         //System.RunAs(adminUser) { 
             test.StartTest();
             CSM_PlaybooksComponentController PlaybooksComponentController = new CSM_PlaybooksComponentController();
             PlaybooksComponentController.playbookId = CSM_TestUtility.playbook.Id;
             
             PlaybooksComponentController.retUrl = '/apex/csm_playbookmanagement';
             System.assert(PlaybooksComponentController.retUrl!=null);
             
             PlaybooksComponentController.accountPlanId = CSM_TestUtility.acctPlan.Id;
             System.assert(PlaybooksComponentController.accountPlanId!=null);
             
             PlaybooksComponentController.acctPlanTemplateId = null;
             System.assert(PlaybooksComponentController.acctPlanTemplateId==null);
             
             PlaybooksComponentController.isAdding = true;           
             System.assert(PlaybooksComponentController.isAdding==true);

             PageReference pr = PlaybooksComponentController.createPlaybookRelationship();
             
             pr = PlaybooksComponentController.createPlaybook();
             System.assert(pr!=null);
             
             pr = PlaybooksComponentController.pageredirect();
             System.assert(pr!=null);
             
             pr = PlaybooksComponentController.editPlaybook();
             System.assert(pr!=null);
             
             pr = PlaybooksComponentController.cancelAddPlaybook();
             System.assert(pr!=null);
             
             PlaybooksComponentController.deactivatePlaybook();
             System.assert(PlaybooksComponentController.playbookId=='');
             
             PlaybooksComponentController.playbookId = CSM_TestUtility.playbook.Id;
             
             PlaybooksComponentController.activatePlaybook();
             System.assert(PlaybooksComponentController.playbookId=='');

             CSM_Playbook__c pbToClone = new CSM_Playbook__c();
             pbToClone.CSM_Display_Name__c = 'testpb';
             insert pbToClone;
             
             PlaybooksComponentController.playbookId = pbToClone.Id;
             pr = PlaybooksComponentController.clonePlaybook();
             System.assert(pr!=null);
             
             PlaybooksComponentController.accountPlanId = CSM_TestUtility.acctPlan.Id;
             PlaybooksComponentController.addPlaybook();
             System.assert(PlaybooksComponentController.playbookAdded==false);
             System.assert(PlaybooksComponentController.isPlaybookInactive==false);
             System.assert(PlaybooksComponentController.playCriteriaValidation==true);
             System.assert(PlaybooksComponentController.doValidation==true);

             CSM_Account_Plan_Template__c sptTest = new CSM_Account_Plan_Template__c();
             sptTest.CSM_Template_Name__c = 'testspt';
             insert sptTest;

             PlaybooksComponentController.acctPlanTemplateId = sptTest.Id;
             PlaybooksComponentController.addPlaybook();
             System.assert(PlaybooksComponentController.playbookAdded==false);

             pr = PlaybooksComponentController.getAccountPlaybookTemplateCount();
                          
             PlaybooksComponentController.playbookId = pbToClone.Id;
             pr = PlaybooksComponentController.deleteAccountPlanPlaybookAssoc();
             System.assert(pr==null);
             
             playbookPlay = CSM_PlaybooksService.getClonePlaybookPlayList(playbookPlay, playbook);
             
             test.stopTest();
         //}
    }

    static testMethod void addPlaybooWithCriteriaSkipped() {
         CSM_TestUtility.addLicense();
         CSM_TestUtility.addCSMAdmin();
         init();
         adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
             test.StartTest();
             CSM_PlaybooksComponentController PlaybooksComponentController = new CSM_PlaybooksComponentController();
             PlaybooksComponentController.playbookId = CSM_TestUtility.playbook.Id;
             
             PlaybooksComponentController.retUrl = '/apex/csm_playbookmanagement';
             System.assert(PlaybooksComponentController.retUrl!=null);
             
             PlaybooksComponentController.accountPlanId = CSM_TestUtility.acctPlan.Id;
             System.assert(PlaybooksComponentController.accountPlanId!=null);
             
             PlaybooksComponentController.acctPlanTemplateId = null;
             System.assert(PlaybooksComponentController.acctPlanTemplateId==null);
             
             PlaybooksComponentController.isAdding = true;           
             System.assert(PlaybooksComponentController.isAdding==true);
			 PlaybooksComponentController.isCriteriaSkipped = true;
             PageReference pr = PlaybooksComponentController.createPlaybookRelationship();
             
             
             test.stopTest();
    }


    static testMethod void addPlaybookTest() {
         CSM_TestUtility.addLicense();
         CSM_TestUtility.addCSMAdmin();
         init();
         adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
             test.StartTest();
        	 CSM_Constants.ACCOUNT_TRIGGER = false;             
             Account acc = new Account();
             acc.Name = 'TestAcc';
             acc.NumberOfEmployees = 100;
             insert acc;
             CSM_TaskCreationTriggerUtil.acctPlanPlaybookList = null;
             CSM_PlaybooksComponentController PlaybooksComponentController = new CSM_PlaybooksComponentController();
             PlaybooksComponentController.playbookId = CSM_TestUtility.playbook.Id;
             
             PlaybooksComponentController.retUrl = '/apex/csm_playbookmanagement';
             System.assert(PlaybooksComponentController.retUrl!=null);
             
             PlaybooksComponentController.accountPlanId = CSM_TestUtility.acctPlan.Id;
             System.assert(PlaybooksComponentController.accountPlanId!=null);
             
             PlaybooksComponentController.acctPlanTemplateId = CSM_TestUtility.acctPlan.csm_account_plan_template__c;
             
             PlaybooksComponentController.isAdding = true;           
             System.assert(PlaybooksComponentController.isAdding==true);
			 PlaybooksComponentController.isCriteriaSkipped = false;
             acc.NumberOfEmployees = 150;
             update acc;
			 CSM_TestUtility.play.CSM_Query_Criteria__c = 'select Id from Account where NumberOfEmployees >= 100';		 
             PageReference pr = PlaybooksComponentController.createPlaybookRelationship();
             
             
             test.stopTest();
    }


 
    
    static testMethod void clonePlaybookTestNeg() {
         CSM_TestUtility.addLicense();
         CSM_TestUtility.addCSMAdmin();
         init();
         User stdUser  = CSM_TestDataUtility.CreateTestUser('Standard User');
 	     PageReference pr;
         CSM_PlaybooksComponentController PlaybooksComponentController = new CSM_PlaybooksComponentController();
         PlaybooksComponentController.playbookId = CSM_TestUtility.playbook.Id;
         
         PlaybooksComponentController.retUrl = '/apex/csm_playbookmanagement';
         
         PlaybooksComponentController.accountPlanId = CSM_TestUtility.acctPlan.Id;
         
         PlaybooksComponentController.acctPlanTemplateId = null;
         
         PlaybooksComponentController.isAdding = true;   

         CSM_Playbook__c pbToClone = new CSM_Playbook__c();
         pbToClone.CSM_Display_Name__c = 'testpb';
         insert pbToClone;
                 
 	     
         System.RunAs(stdUser) { 
             test.StartTest();
	             try{
	             	pr = PlaybooksComponentController.createPlaybookRelationship();	             
	             }
	             catch(Exception ex){
	             
	             }


	             try{
	             	pr = PlaybooksComponentController.createPlaybook();	             
	             }
	             catch(Exception ex){
	             
	             }

	             try{
	             	pr = PlaybooksComponentController.pageredirect();	             
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
	             	pr = PlaybooksComponentController.editPlaybook();	             
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
	             	pr = PlaybooksComponentController.cancelAddPlaybook();	             
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
	             	PlaybooksComponentController.deactivatePlaybook();	             
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
	             	PlaybooksComponentController.playbookId = CSM_TestUtility.playbook.Id;	             
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
	             	PlaybooksComponentController.activatePlaybook();	             
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
		             
		             PlaybooksComponentController.playbookId = pbToClone.Id;
		             pr = PlaybooksComponentController.clonePlaybook();
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
		             PlaybooksComponentController.accountPlanId = CSM_TestUtility.acctPlan.Id;
		             PlaybooksComponentController.addPlaybook();
	             }
	             catch(Exception ex){
	             
	             }

	             try{
		             CSM_Account_Plan_Template__c sptTest = new CSM_Account_Plan_Template__c();
		             sptTest.CSM_Template_Name__c = 'testspt';
		             insert sptTest;
		
		             PlaybooksComponentController.acctPlanTemplateId = sptTest.Id;
		             PlaybooksComponentController.addPlaybook();
	             }
	             catch(Exception ex){
	             
	             }
	             
	             try{
	             	pr = PlaybooksComponentController.getAccountPlaybookTemplateCount();
	             }
	             catch(Exception ex){
	             
	             }

	             try{
		             PlaybooksComponentController.playbookId = pbToClone.Id;
		             pr = PlaybooksComponentController.deleteAccountPlanPlaybookAssoc();
	             }
	             catch(Exception ex){
	             
	             }

             System.assert(pr==null);             
             test.stopTest();
         }
    }
    
    
}