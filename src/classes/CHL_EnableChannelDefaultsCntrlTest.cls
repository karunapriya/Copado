@isTest
private class CHL_EnableChannelDefaultsCntrlTest {
    
    //To test scenario for no mapping records exist in Org.
    static testMethod void myUnitTest() {
    	CHL_EnableChannelDefaultsCntrl chlDefaultObj = new CHL_EnableChannelDefaultsCntrl();
    	chlDefaultObj.createChlPortalDefaultConfigRec();
    }
    
     //To test scenario for valid mapping records exist in Org.
     static testMethod void myUnitTest1() {
     	REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
		fm.name = Label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY;
		fm.REN_Field_Data_Type__c =  'PICKLIST';
		fm.REN_To_Field_API_Name__c = 'CHL_Sales_Stage__c';
		fm.REN_From_Field_API_Name__c = 'StageName';
		fm.REN_To_Object_API_Name__c = 'CHL_Partner_Opportunity__c';
		fm.REN_From_Object_Api_Name__c = 'Opportunity';
		fm.REN_Is_Required__c = true;
		fm.REN_Default_Value__c = '';
		insert fm;
		
    	CHL_EnableChannelDefaultsCntrl chlDefaultObj = new CHL_EnableChannelDefaultsCntrl();
    	chlDefaultObj.createChlPortalDefaultConfigRec();
    }
        
}