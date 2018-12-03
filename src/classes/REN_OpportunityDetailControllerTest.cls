@isTest(SeeAllData=true)
private class REN_OpportunityDetailControllerTest {
   
	static testMethod void Test_Init_Positive(){
		Account accountObj=new Account(Name='TestAccount');
		insert accountObj;
		User userObj=[select id from User where IsActive = true limit 1];
		Opportunity opp=new Opportunity();
		opp.Name='OppTest';
		opp.OwnerId=userObj.id;
		opp.AccountId=accountObj.id;
		opp.CloseDate = System.today();
		//opp.CloseDate=date.parse('8/17/2015');
		opp.StageName='Closed Won';
		insert Opp;
		
		Test.startTest();
		REN_OpportunityDetailController ctrl = new REN_OpportunityDetailController();
		ctrl.opportunityObject=opp;
		List<SelectOption> pbList = ctrl.getActivePricebooks();
		system.assert(pbList != null);
		system.assert(!pbList.isEmpty());
		Test.stopTest();
	}
}