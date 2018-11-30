@isTest
public with sharing class CSM_IndicatorComponentControllerTest
{
    private static CSM_Indicator_Group__c indicatorGroup;
    public static List<CSM_Account_Plan_Template__c> accPlanTemplates;
    public static List<Account> accountList;
    public static List<CSM_Account_Plan__c> accPlans;
    public static List<CSM_Indicator_Group__c> indicatorGroupList;
    public static List<CSM_Indicator__c> indicatorList;
    public static List<CSM_Account_Plan_Template_Indicator__c> acctPlanTemplateIndicatorList;
    
    static testMethod void testIndicator() {
        setUp();
        test.startTest();
        CSM_Indicator_Group__c objtest = new CSM_Indicator_Group__c();
        objtest.CSM_Display_Name__c='test';
        insert objtest;
        CSM_IndicatorComponentController controller = new CSM_IndicatorComponentController();
        controller.selectedField='CSM_Object_Field_Name__c';
        controller.indicatorGroupId = indicatorGroup.Id;
        controller.accounttempindicatorName = acctPlanTemplateIndicatorList[0].Name;
        controller.indicatorId = objtest.Id;
        List<SelectOption> objectList = controller.getObjectList();
        System.assert(objectList.size() > 0);
        
        controller.selectedObject = 'Account';
        List<SelectOption> fieldList = controller.getFieldList();
        System.assert(fieldList.size() > 0);
        
        controller.selectedField = fieldList[0].getValue();
        controller.addField();
        System.assert(controller.indicatorList.size() > 0);
        
        controller.indicatorList[0].csmIndicator.CSM_Indicator_Display_Name__c = 'Display Column Name';     
        controller.Save();
        System.assertNotEquals(null,  controller.indicatorList[0].csmIndicator.Id);
        
        Pagereference pr = controller.successplantempindicatorList();
        
        pr = controller.deleteSuccessPlanIndicator();
        system.assertEquals(pr, null);
        
        pr = controller.cancel();
        system.assertEquals(pr, null);
        test.stopTest();
                
    }    


    static testMethod void testIndicatorNeg() {
        setUp();
        test.startTest();
        User Usr = CSM_TestDataUtility.createTestUser('Standard User');
        Pagereference pr;

        CSM_IndicatorComponentController controller = new CSM_IndicatorComponentController();
        controller.indicatorGroupId = indicatorGroup.Id;
        controller.accounttempindicatorName = acctPlanTemplateIndicatorList[0].Name;
        controller.indicatorId = indicatorList[0].Id;
        List<SelectOption> objectList = controller.getObjectList();
        controller.selectedObject = 'Account';
        List<SelectOption> fieldList = controller.getFieldList();
        controller.addField();
        system.runAs(Usr)
        {
            
            try{
                controller.selectedField = fieldList[0].getValue();
                controller.addField();
                
            }
            catch(Exception ex){
            
            }
            try{
                
                controller.selectedField = fieldList[0].getValue();
               // controller.addField();
                
                controller.indicatorList[0].csmIndicator.CSM_Indicator_Display_Name__c = 'Display Column Name';             
            }
            catch(Exception ex){
            
            }
            
            try{
            
                controller.selectedField = fieldList[0].getValue();
               // controller.addField();
                
                controller.Save();
                
            }
            catch(Exception ex){
            
            }
            
            try{
                pr = controller.successplantempindicatorList();
                
            }
            catch(Exception ex){
            
            }
            try{
                pr = controller.deleteSuccessPlanIndicator();
            
            }
            catch(Exception ex){
            
            }
            
        }
        system.assertEquals(pr, null);        
        test.stopTest();
                
    }    


       
    static testMethod void testAdminLinks()
    {
         test.startTest();
         CSM_AdminLinksComponentController controller = new CSM_AdminLinksComponentController();
         
         PageReference pr = controller.getRedirectToFocusCategoriesGroup();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToFocusCategories();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToAccountPlanTemplates();
         System.assertNotEquals(null, pr);
          
         pr = controller.getRedirectToIndicatorGroups();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToPlaybooks();
         System.assertNotEquals(null,pr);
          
         pr = controller.getRedirectToPlays();
         System.assertNotEquals(null, pr);
          
         pr = controller.redirectToServiceContracts();
         //System.assertNotEquals(null, pr);
           
         pr = controller.redirectToAssets();
         System.assert(pr==null);
           
         pr = controller.getRedirectToRenewalOpportunity();
         System.assertNotEquals(null, pr);
           
         pr = controller.redirectToChartManagement();
         System.assertNotEquals(null, pr);
         
         pr = controller.redirectToHome();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToDataGeneration();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToRenewalMappings();
         System.assertNotEquals(null, pr);
         
         CSM_AdminLinksComponentController.titleHeader = 'Test';
         CSM_AdminLinksComponentController.subtitleHeader = 'Test';
         controller.tabCategory = 'CSM';
         
         pr = controller.getRedirectToBatchOppGenActivity();
         System.assertNotEquals(null, pr);
        
         pr = controller.getRedirectToChannelAdmin();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToChannelDataSync();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToRenewalOpportunityUpdate();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToBatchFilterActivity();
         System.assertNotEquals(null, pr);
          
         pr = controller.getRedirectToReportAdmin();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToMSTR();
         System.assertNotEquals(null, pr);
          
         pr = controller.getRedirectToMSTD();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToAutoGenerationLog();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToConsolidateOpportunitiesBatchLog();
         System.assertNotEquals(null, pr);
         
         pr = controller.redirectToBatchAssignActivity();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToSegmentOverview();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToQuoteRequestResults();
         System.assertNotEquals(null, pr);
         
         pr = controller.getRedirectToOauthPage();
         System.assertNotEquals(null, pr);
          
         system.assertEquals(controller.param,null);
         controller.param = CSM_Constants.HELP_ADMIN_TAB;
         system.assertNotEquals(controller.param,null);
         
         test.stopTest();
    } 
       
    static testMethod void testenableSimplifiedDataModel() {
        CSM_AdminLinksComponentController controller = new CSM_AdminLinksComponentController();
        Test.startTest();
            System.assertEquals(null, controller.enableSimplifiedDataModel());
        Test.stopTest();
    }    
        
    
    static void setUp() 
    {
        /*CSM_Admin__c csmAdmin = new CSM_Admin__c();
        csmAdmin.Name = CSM_Constants.CSM_ADMIN;
        csmAdmin.CSM_IndicatorObjects__c = 'Account;Opportunity';
        insert csmAdmin;*/
        
        indicatorGroup = new CSM_Indicator_Group__c();
        indicatorGroup.CSM_Display_Name__c = 'New Group';
        insert indicatorGroup;
        
        CSM_Indicator__c indicator = new CSM_Indicator__c();
        indicator.CSM_Indicator_Display_Name__c = 'Display Opportunity Name';
        indicator.CSM_Indicator_Group__c = indicatorGroup.Id;
        indicator.CSM_isActive__c = true;
        indicator.CSM_Object_Field_Name__c = 'TotalOpportunityQuantity';
        indicator.CSM_Object_Name__c = 'Opportunity';
        indicator.CSM_Object_Field_Type__c = CSM_Constants.TYPE_STRING;
        insert indicator;
        
        indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
        indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,6);
        accPlanTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accPlanTemplates[0].id, indicatorList);
                
        accountList = CSM_TestDataUtility.createAccount(3); 
        
        system.assert(indicatorGroupList != null);
        system.assert(indicatorList !=null);
        system.assert(accountList !=null);
        
    }
}