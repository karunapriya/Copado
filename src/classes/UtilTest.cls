@isTest
public with sharing class UtilTest {
		
    	static testMethod void setupDataTest(){
    	/*SELECT AccountId,Amount,Business_Line__c,Client_Region__c,
    	Client_Territory__c,CloseDate,Commit__c,Country__c,CurrencyIsoCode,
    	SSI_Theatre__c,StageName FROM Opportunity*/
    	
    	List<Account> accountList = new List<Account>();
    	Account newAccount = new Account();
    	newAccount.Name =  'Test-Account ' ;
    	accountList.add(newAccount);
    	
    	insert accountList;
    	List<sObject> currencylst;
    	if(UserInfo.isMultiCurrencyOrganization()){
    		String querystring = 'SELECT conversionrate, isocode, IsCorporate FROM currencytype LIMIT 2000';
            currencylst = Database.query(queryString);
    	}
    	List<String> currencyCodeLst = new List<String> ();
    	for(sObject sObj:currencylst){
    		currencyCodeLst.add((String)sObj.get('isocode'));
    	}
    	List<Opportunity> opportunityList = new List<Opportunity>();
    	Opportunity newOpportunity = new Opportunity();
	   	newOpportunity.accountId = accountList[0].id;
	    newOpportunity.Name = 'Original Opp ';
	    newOpportunity.CloseDate = System.Today();
	    newOpportunity.StageName = 'Contacted';
	    newOpportunity.Type = 'New Customer';
	    newOpportunity.Amount= 1000;
	    newOpportunity.Business_Line__c = 'Core';
	    newOpportunity.Client_Region__c = 'USA';
	    newOpportunity.Client_Territory__c = 'USA';
	    newOpportunity.Country__c = 'India';
	    newOpportunity.SSI_Theatre__c = 'APJ';
	    if(UserInfo.isMultiCurrencyOrganization()){
	    	newOpportunity.CurrencyIsoCode = currencyCodeLst[0];
	    }
	    opportunityList.add(newOpportunity);
	    insert opportunityList;
	    System.assert(opportunityList[0].id != null);
	    
	    List<BusinessHours> lstBusinessHours =  [SELECT Id,Name FROM BusinessHours WHERE IsDefault=true];
	    
	   
        Test.startTest();
	         //Util.getAllAccessibleFieldsFrom( 'Case', null, new Set<String>());
	         if(lstBusinessHours.size() > 0){
	         	Util.defaultDifferentInMin(lstBusinessHours[0].id, system.now()-2, system.now());
	         }
        Test.stopTest();
    	
    }
    static testMethod void testsetErrorInObjects(){
    	try{
    		integer i = 0;
    		integer j = 1/i;
    		system.assert(false);
    	}catch(Exception e){
    		system.assert(true);
    		Util.setErrorInObjects(new List<Case>{new Case()}, e);
    	}
    }
    
}