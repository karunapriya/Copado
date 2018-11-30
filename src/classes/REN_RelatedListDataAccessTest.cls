@isTest
private class REN_RelatedListDataAccessTest {
	
	@testSetup 
	static void setUpData() {
		List<REN_Related_List__c> lstRL = new List<REN_Related_List__c>();
        lstRL.add(new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors'));
        lstRL.add(new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Contact Roles'));
        lstRL.add(new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Partners'));
        system.assert(lstRL != null);
        system.assert(!lstRL.isEmpty());
        insert lstRL;
	}
	
	static testMethod void getRelatedListRecordsByConfig() {
		Test.startTest();
		List<REN_Related_List__c> relatedListRecords = REN_RelatedListDataAccess.getRelatedListRecordsByConfig('');
		system.assert(relatedListRecords != null);
		system.assert(relatedListRecords.size() == 3);
		Test.stopTest();
	}
	
	static testMethod void upsertRelatedListRecords(){
		Test.startTest();
		List<REN_Related_List__c> relatedListRecords = [Select Id, Name, REN_Object_API_Name__c, REN_Related_List_Type__c 
    						From REN_Related_List__c limit 100];
		REN_RelatedListDataAccess.upsertRelatedListRecords(relatedListRecords);
		system.assert(relatedListRecords != null);
		system.assert(relatedListRecords.size() == 3);
		Test.stopTest();
	}
}