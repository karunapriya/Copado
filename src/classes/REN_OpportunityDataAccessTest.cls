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
private class REN_OpportunityDataAccessTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Test.startTest();
		Account a = new Account(Name = 'RENEW DIRECT Test Account A');
		insert a;
        
		List < Opportunity > testOppList = new List < Opportunity > ();
		for (Integer i = 0; i < 10; i++) {
			testOppList.add(new Opportunity(Name = 'TestOpp' + i, StageName = 'Prospecting',
			CloseDate = System.Today(), AccountId = a.Id, Type = 'New Customer'));
		}
		insert testOppList;
		testOppList[0].Name = 'UpdateOpp';
        
        REN_OpportunityDataAccess.updateOpportunityforRenewals(testOppList);
        system.assertequals(testOppList[0].Name,'UpdateOpp'); 
        
        
    	String standardPriceBookId = Test.getStandardPricebookId();
		Product2 p2 = new Product2(Name='Test Product',isActive=true);
		insert p2;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=p2.Id, UnitPrice=99, isActive=true);
		insert pbe;
		List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
		for(Integer i=0; i<5; i++){
			OpportunityLineItem newol = new OpportunityLineItem();
			newol.UnitPrice = 50000;
			newol.ServiceDate = System.today();
			newol.Description = 'Desc 1';
			newol.Quantity = 1;
			newol.PricebookEntryId = pbe.Id;
			if(i < 3){
				newol.OpportunityId = testOppList[0].Id;
				opliList.add(newol);
			}else{
				newol.OpportunityId = testOppList[1].Id;
				opliList.add(newol);
			}
		}
		insert opliList;
        Set<String> testSet = new Set<String>();
        testSet.add(testOppList[0].Id);
        testSet.add(testOppList[1].Id);        
        List<OpportunityLineItem> testopliList = REN_OpportunityDataAccess.fetchOpptLinesByOppts(testSet, new Set<String>{'id'});
        system.assertequals(testopliList.size(),5);
        Test.stopTest();
    }
}