@isTest
private class CHL_ResponseWrapperUtilTest {
	public static String fieldSetName = '';
	public static String assetFieldSetName = '';
	public static List<CHL_Partner_Opportunity__c> sObjList = new List<CHL_Partner_Opportunity__c>();
	public static List<CHL_Partner_Opportunity__c> chlpartnerList;
	public static List<Account> accountList;
	public static List<Asset> assetList;
	static void setUp() { 
		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(CSM_Util.getNamespace()+'CHL_Partner_Opportunity__c');
   		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		Map<String, Schema.FieldSet> fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap();
   		for(FieldSet fieldSet:fieldSetObj.values()){
    		fieldSetName = fieldSet.getName();
 		}
 		
 		accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		assetList = new List<Asset>();

		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		
		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		insert contactList;

		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList; 
		
		Asset asset = CHL_TestUtility.createAsset(accountList[0].Id);
		assetList.add(asset);
		insert assetList;
		
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
	   	partOppty.OpportunityId = opptyList[0].id;
	   	partOppty.partnerAcc1Id = accountList[0].id ;
	   	partOppty.partnerAcc1Type = 'Reseller';
	   	partOppty.contact1Id = contactList[0].Id;
	   	partOppty.expirationDate= system.today().addDays(-10);
	   	partOppty.Stage= 'Needs Analysis';
	   	system.assert(partOppty != null);
	     
	   	chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(1,partOppty); 
	   	insert chlpartnerList;
		
		//sObjList.add(parOptyObj);
		System.assert(chlpartnerList!=null);
	}
	
    static testMethod void getColumnHeaderFromFieldSetTest() {
        setUp();
    	List < CHL_AngularResponeWrapper.CHL_ColumnHeader > tempList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CSM_Util.getNamespace()+fieldSetName,CSM_Util.getNamespace()+'CHL_Partner_Opportunity__c');
    }
    static testMethod void getRecordDetailsListFromFieldSetTest() {
        
        setUp();
 		List < CHL_AngularResponeWrapper.CHL_GridData > tempList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(chlpartnerList, CSM_Util.getNamespace()+fieldSetName, CSM_Util.getNamespace()+'CHL_Partner_Opportunity__c');
    }
    
    static testMethod void getRecordDetailsListFromFieldSetAssetTest() {        
        setUp();
 		List < CHL_AngularResponeWrapper.CHL_GridData > tempList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(assetList, CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community', 'Asset');
    }
    
    static testMethod void getObjectDetailsFromFieldSetTest() {
    	setup();
    	List<sObject> caseList = new List<sObject>();
    	Case c1 = new Case();
    	c1.AccountId = accountList[0].Id;
    	c1.status = 'New';
    	c1.Origin = 'Web';
    	c1.CHL_Related_To_Text__c = chlpartnerList[0].Id+chlpartnerList[0].Name;
    	//c1.CHL_Related_To__c = sObjList[0].Id;
    	insert c1;
    	caseList.add(c1);    	
		System.assert(caseList!=null);
    	CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
		optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
		optyStatusLogObj.CHL_Days_between_Update__c = 5;
		optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Needs Analysis;Closed Won';
		optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
		insert optyStatusLogObj;
    	List <CHL_DetailTabResponseWrapper> templist = CHL_ResponseWrapperUtil.getObjectDetailsFromFieldSet(chlpartnerList, CSM_Util.getNamespace()+'CHL_Partner_Opportunity_Details',  CSM_Util.getNamespace()+'CHL_Partner_Opportunity__c'); 
    	Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Case');
   		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		Map<String, Schema.FieldSet> fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap();
   		for(FieldSet fieldSet:fieldSetObj.values()){
    		fieldSetName = fieldSet.getName();
 		} 
    	List <CHL_DetailTabResponseWrapper> templist2 = CHL_ResponseWrapperUtil.getObjectDetailsFromFieldSet(caseList, CSM_Util.getNamespace()+'CHL_CaseDetails_Fieldset', 'Case'); 
    	CHL_ResponseWrapperUtil.setObjectType('Opportunity');
    }
    
    static testMethod void getColumnHeaderFromFieldSetAssetTest() {
        setUp();
    	List < CHL_AngularResponeWrapper.CHL_ColumnHeader > tempList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community','Asset');
    }
}