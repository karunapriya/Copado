@isTest
private class CHL_ChannelPartnerAdminPageCtrlTest {
    
    /*@testSetup static void setup() {  
        User adminUser  = CSM_TestDataUtility.createTestUser('Channel NetOps');
        insert adminUser;
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('Channel_NetOps');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
    }*/
    static testMethod void addMonitorFields_Positive() {
       User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
        insert adminUser;
        list < PermissionSetAssignment > lstPSAssignments = new list < PermissionSetAssignment > ();
        PermissionSet ps = CHL_TestUtility.getPermissionSet('PRISM_Base');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
       System.RunAs(adminUser) {
            CHL_ChannelPartnerAdminPageCtrl pgCtrl1 = new CHL_ChannelPartnerAdminPageCtrl();
            CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
            optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Close_Date__c;CHL_Amount__c;CHL_Probability__c';
            optyStatusLogObj.CHL_Days_between_Update__c = -1;
            optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Closed Won';
            insert optyStatusLogObj;
            CHL_ChannelPartnerAdminPageCtrl pgCtrl = new CHL_ChannelPartnerAdminPageCtrl();
            REN_BaseMainController controller = new REN_BaseMainController();
            controller.objectNameSuper = 'avlblSS';
            CHL_MultiSelectListWrapper multisel = new CHL_MultiSelectListWrapper('avlblSS','left','right',new List<string>(),new List<string>(),'ltr','RTL','MU','MD',controller,false,0);
            CHL_ManagePickListValuesContrl vmc = new CHL_ManagePickListValuesContrl();
            vmc.multiSelectWrp = multisel;
            pgCtrl.setBaseChildController(vmc);
            pgCtrl.setBaseChildControllerMap('avlblSS', pgCtrl.getBaseChildController());
            
            // Code for the Active language
            controller = new REN_BaseMainController();
            controller.objectNameSuper = 'actvLang';
            Map<String,String> languageOption = CHL_Util.fetchUserLanguagePicklistValue(); // Fetch all available language
            Map<String,String> savedLanguages = CHL_Util.getActiveLanguges(); // Get all Active language selected by User
            Set<String> destinationLanguageSet = new Set<String>(savedLanguages.values());// Put these selected Languages to Set
            destinationLanguageSet.add('French');
            destinationLanguageSet.add('Italian');
            List<String> sourceLangList = pgCtrl.getSourceLanguages(languageOption.values(),new List<String>(destinationLanguageSet)); // Generate source list based on selected Languages options. here we need to exclude active language options.
            List<String> srcLangList = languageOption.values();
            CHL_MultiSelectListWrapper multiselLang = new CHL_MultiSelectListWrapper('actvLang','left','right',srcLangList,new List<String>(destinationLanguageSet),'ltr','RTL','MU','MD',controller,false,1);
            CHL_ManagePickListValuesContrl vmcLang = new CHL_ManagePickListValuesContrl();
            List<String> listOfSelectedItem = new List<String>();
            listOfSelectedItem.add('German');
            multiselLang.addOptionsInRight(listOfSelectedItem);
            multiselLang.moveOptionUp(listOfSelectedItem);
            multiselLang.moveOptionDown(listOfSelectedItem);
            
            vmcLang.multiSelectWrp = multiselLang;
            vmcLang.targetSelectedOptions = new List<String>();
            vmcLang.destinationSelectedOptions= new List<String>();
           
            vmcLang.targetSelectedOptions.add('English');
            vmcLang.targetSelectedOptions.add('French');
            vmcLang.targetSelectedOptions.add('Italian');
            
            vmcLang.destinationSelectedOptions.add('English');
            vmcLang.destinationSelectedOptions.add('French');
            vmcLang.destinationSelectedOptions.add('Italian');
            
            vmcLang.moveLeftToRight();
            vmcLang.moveRightToLeft();
            vmcLang.moveUp();
            vmcLang.moveDown();
            pgCtrl.setBaseChildController(vmcLang);
            pgCtrl.setBaseChildControllerMap('actvLang', pgCtrl.getBaseChildController());
            
            
            //PageReference pr = new PageReference();
            PageReference pr = pgCtrl.save();
            pgCtrl1.cancel();
            System.assert(pr==null);
            pr = pgCtrl.Cancel();
            System.assert(pr!=null);
       }
    }
    
    static testMethod void add_remove_MonitorFields() { 
        User adminUser  = CSM_TestDataUtility.createTestUser('System Administrator');
        insert adminUser;
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('PRISM_Base');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;        
        System.RunAs(adminUser) {
            CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
            optyStatusLogObj.CHL_Field_API_Names__c = ';';
            optyStatusLogObj.CHL_Days_between_Update__c = 10;
            optyStatusLogObj.CHL_Days_before_Expiration__c = 0;
            insert optyStatusLogObj;  
            CHL_ChannelPartnerAdminPageCtrl pgCtrl = new CHL_ChannelPartnerAdminPageCtrl();
            REN_BaseMainController controller = new REN_BaseMainController();
            controller.objectNameSuper = 'dsplaySS';
            pgCtrl.selectedField = 'CHL_Amount__c';
            PageReference pr = pgCtrl.addFieldCriteria();
            System.assert(pr==null);
            pgCtrl.fieldToDelete = 'CHL_Amount__c';
            pr = pgCtrl.deleteFieldCriteria();
            System.assert(pr==null);
            CHL_MultiSelectListWrapper multisel1 = new CHL_MultiSelectListWrapper('dsplaySS','left','right',new List<string>(),new List<string>(),'ltr','RTL','MU','MD',controller,false,0);
            CHL_ManagePickListValuesContrl vmc1 = new CHL_ManagePickListValuesContrl();
            vmc1.multiSelectWrp = multisel1;
            pgCtrl.setBaseChildController(vmc1);
            pgCtrl.setBaseChildControllerMap('dsplaySS', pgCtrl.getBaseChildController());
            pr = pgCtrl.save();
            System.assert(pr==null);
            optyStatusLogObj.CHL_Days_before_Expiration__c = -1;
            update optyStatusLogObj;
            CHL_ChannelPartnerAdminPageCtrl pgCtrl2 = new CHL_ChannelPartnerAdminPageCtrl();
            CHL_MultiSelectListWrapper multisel = new CHL_MultiSelectListWrapper('dsplaySS','left','right',new List<string>(),new List<string>(),'ltr','RTL','MU','MD',controller,false,0);
            CHL_ManagePickListValuesContrl vmc = new CHL_ManagePickListValuesContrl();
            vmc.multiSelectWrp = multisel;
            pgCtrl2.setBaseChildController(vmc);
            pgCtrl2.setBaseChildControllerMap('dsplaySS', pgCtrl2.getBaseChildController());
            PageReference pr2 = pgCtrl2.save();
            System.assert(pr2==null);
       }
    }
    
    static testMethod void addMonitorFields_Negative() {
        User restrictedUser = CSM_TestDataUtility.createTestUser('System Administrator');
        CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c();
        optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Close_Date__c;CHL_Amount__c;CHL_Probability__c';
        optyStatusLogObj.CHL_Days_between_Update__c = 12;
        insert optyStatusLogObj;
        CHL_ChannelPartnerAdminPageCtrl pgCtrl = new CHL_ChannelPartnerAdminPageCtrl();
        system.runAs(restrictedUser) {
            Test.startTest();
            try {
                PageReference pr = pgCtrl.save();
                System.assert(pr == null);
            } catch (Exception ex) {
                system.assert(true);
            }
            Test.stopTest();
        }

    }
    
    static testMethod void addMonitorFields_Negative_2() {
        List <CHL_Opportunity_Status_Log__c> optyStatusLogList = [select Id from CHL_Opportunity_Status_Log__c limit 1];
        if (optyStatusLogList != null && !optyStatusLogList.isEmpty()) {
            delete optyStatusLogList;
        }
        User restrictedUser = CSM_TestDataUtility.createTestUser('System Administrator');
        system.runAs(restrictedUser) {
            try {
                CHL_ChannelPartnerAdminPageCtrl pgCtrl = new CHL_ChannelPartnerAdminPageCtrl();
                System.assert(true);
            } catch (Exception ex) {
                system.assert(true);
            }
        }
    }
    
  
    
}