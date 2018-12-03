/* 
      * author : PES 
      * date : 20-04-2015
      * description : As per user story US415.
*/

@isTest(SeeAllData=false)
public class REN_SetExpQuaterYearTest {
    /*
        *Method to Test if the month of Expiration date of Opportunity is before the Organization's FiscalYearStartMonth,
        *then the Expiration Quater and Expiration Year of Opportunity is updated based on Expiration Date of Opportunity.
    */
    static testMethod void UpdateExpQuaYearBfrStrMonTest(){
        string userId = userinfo.getUserId();
        
        Opportunity oppBeforeStartMonth = new Opportunity(REN_Earliest_Expiration_Date__c=System.Today(),Name = 'Test Opp' , REN_Is_CLM_Renewal__c = true , CloseDate = System.Today().addDays(30) , StageName = 'Prospecting' , ownerid = userId);
        insert oppBeforeStartMonth;
       
        
        Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
		
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		
		OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = oppBeforeStartMonth.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		insert opptyLineItem;
		
        REN_Renews_To__c renMgmtBfrStrMon1 = new REN_Renews_To__c(Name = 'Test REN1' , REN_Renews_To__c = oppBeforeStartMonth.id , REN_End_Date__c = date.newinstance(2015, 4, 17), REN_Product__c = prod.id);
        insert renMgmtBfrStrMon1;
        
        REN_Renews_To__c renMgmtBfrStrMon2 = new REN_Renews_To__c(Name = 'Test REN2' , REN_Renews_To__c = oppBeforeStartMonth.id , REN_End_Date__c = date.newinstance(2015, 3, 17), REN_Product__c = prod.id);
        insert renMgmtBfrStrMon2;
        
        REN_Renews_To__c updatedRenMgmtBefStrMon = [Select id,Name,REN_End_Date__c from REN_Renews_To__c where id =: renMgmtBfrStrMon1.id];
        updatedRenMgmtBefStrMon.REN_End_Date__c = Date.newinstance(2015, 2, 17);
      	CSM_TriggerManager.enableFirstTrigger();
        update updatedRenMgmtBefStrMon;
       
        Opportunity updatedOppBeforeStartMonth = [Select REN_Earliest_Expiration_Date__c , REN_EQ__c , REN_FY__c from Opportunity where id =: oppBeforeStartMonth.id];

        system.assertequals(oppBeforeStartMonth.REN_Earliest_Expiration_Date__c ,System.Today());
    }
    
    /*
        *Method to Test if the month of Expiration date of Opportunity is after the Organization's FiscalYearStartMonth,
        *then the Expiration Quater and Expiration Year of Opportunity is updated based on Expiration Date of Opportunity.
    */
    static testMethod void UpdateExpQuaYearAftStrMonTest()
    {
        string userId = userinfo.getUserId();
        
        Opportunity oppAfterStartMonth = new Opportunity(REN_Earliest_Expiration_Date__c=System.Today(),Name = 'Test Opp' , REN_Is_CLM_Renewal__c = true , CloseDate = System.Today().addDays(30) , StageName = 'Prospecting' , ownerid = userId);
        insert oppAfterStartMonth;
        
       // Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
        Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;

		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		
		OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = oppAfterStartMonth.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		insert opptyLineItem;
        
        REN_Renews_To__c renMgmtAftStrMon1 = new REN_Renews_To__c(Name = 'Test REN3' , REN_Renews_To__c = oppAfterStartMonth.id , REN_End_Date__c = date.newinstance(2015, 4, 17), REN_Product__c =prod.id);
        insert renMgmtAftStrMon1;
        
        REN_Renews_To__c renMgmtAftStrMon2 = new REN_Renews_To__c(Name = 'Test REN4' , REN_Renews_To__c = oppAfterStartMonth.id , REN_End_Date__c = date.newinstance(2015, 9, 17), REN_Product__c =prod.id);
        insert renMgmtAftStrMon2;
        
        REN_Renews_To__c updatedRenMgmtAftStrMon = [Select id,Name,REN_End_Date__c from REN_Renews_To__c where id =: renMgmtAftStrMon1.id];
        updatedRenMgmtAftStrMon.REN_End_Date__c = date.newinstance(2015, 8, 17);
		//REN_Constants.RENEWALRELATIONSHIP_BEFORE_TRIGGER = true;
		//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = true;
        update updatedRenMgmtAftStrMon;
        
        Opportunity updatedOppAfterStartMonth = [Select REN_Earliest_Expiration_Date__c , REN_EQ__c , REN_FY__c from Opportunity where id =: oppAfterStartMonth.id];
        

        system.assertequals(oppAfterStartMonth.REN_Earliest_Expiration_Date__c ,System.Today());
    }
     
    /*
        *Test Method for Before Insert method of OpportunityTriggerHandler 
        *Method to Test if the opportunity is inserted with Expiration Date,
        *then the Expiration Quater and Expiration Year of Opportunity is updated based on Expiration Date of Opportunity.
    */
    static testMethod void OpportunityTriggerInsertTest(){
        string userId = userinfo.getUserId();
        Opportunity oppInsert = new Opportunity(REN_EQ__c=3,Name = 'Test Opp' , REN_Earliest_Expiration_Date__c = date.newinstance(2015, 4, 22),  REN_Is_CLM_Renewal__c = true , CloseDate = System.Today().addDays(30) , StageName = 'Prospecting' , ownerid = userId);
        insert oppInsert;
        Opportunity updatedOppInsert = [Select REN_Earliest_Expiration_Date__c , REN_EQ__c , REN_FY__c from Opportunity where id =: oppInsert.id];
        
        system.assert(updatedOppInsert.REN_EQ__c>0);
        if (updatedOppInsert.REN_FY__c!=null){
            system.assert(Integer.valueOf(updatedOppInsert.REN_FY__c)>2000);
        }
     
    }
    
    /*
        *Test Method for Before Update method of OpportunityTriggerHandler 
        *Method to Test if the opportunity Expiration Date is changed,
        *then the Expiration Quater and Expiration Year of Opportunity is updated based on Expiration Date of Opportunity.
    */
    static testMethod void OpportunityTriggerUpdateTest()
    {
        string userId = userinfo.getUserId();
        Opportunity oppUpdate = new Opportunity(REN_EQ__c=3,Name = 'Test Opp1' , REN_Earliest_Expiration_Date__c = date.newinstance(2015, 2, 17),  REN_Is_CLM_Renewal__c = true , CloseDate = System.Today().addDays(30) , StageName = 'Prospecting' , ownerid = userId);
        insert oppUpdate;
        Id oppId = oppUpdate.id;
        oppUpdate = [Select id, REN_Earliest_Expiration_Date__c , REN_EQ__c , REN_FY__c from Opportunity where id =: oppId];
        oppUpdate.REN_Earliest_Expiration_Date__c = date.newinstance(2015, 2, 17);
        update oppUpdate;

        oppUpdate = [Select id, REN_Earliest_Expiration_Date__c , REN_EQ__c , REN_FY__c from Opportunity where id =: oppId];
        system.assert(oppUpdate.REN_EQ__c>0);
        if (oppUpdate.REN_FY__c!=null){
            system.assert(Integer.valueOf(oppUpdate.REN_FY__c)>2000);
        }

    }
}