/*
    Created By: PES
    Apex page:  REN_RenewalsInsight 
    Controller: REN_RenewalsInsightController 
    Created On: 30th April 2015
*/
@isTest(SeeAllData=true)
public class REN_RenewalsInsightTest
{ 

    /*
        *Method to Prepare Filter for the chart and filter the chart
    */
    static testMethod void UpdateExpQuarterYearBfrStrMonTest()
    {
        string userId = userinfo.getUserId();
        string userName = userinfo.getName();
                       
        //Create an Account with billing country as US
        Account acc = new Account(Name = 'TestAccount1' , BillingCountry = 'US');
        insert acc;
        
        string oppName = system.now() + '-TestOpp';
        //Insert a new Opportunity
        Opportunity opp = new Opportunity(Name = oppName, 
                                            REN_Is_CLM_Renewal__c = true , 
                                            CloseDate = System.Today().addDays(30) , 
                                            StageName = 'Closed Won',
                                            ownerid = userId , 
                                            REN_Renewal_Target__c = 1000 , 
                                            REN_Renewal_Target_Resolved__c = 500,
                                            REN_Renewal_Target_Lost__c = 250,
                                            REN_Renewal_Target_Won__c = 250,
                                            amount = 1000,
                                            REN_Earliest_Expiration_Date__c = date.newinstance(2015, 6, 17),
                                            AccountId = acc.Id);
        insert opp;
        Opportunity currentOpp = [select owner.name,CloseDate,Account.BillingCountry,REN_FY__c,REN_EQ__c,REN_Renewal_Target__c,REN_Renewal_Target_Resolved__c,REN_Renewal_Target_Lost__c ,REN_Renewal_Target_Won__c,amount from Opportunity where id =: opp.id];
        //Create controller instance      
        REN_RenewalsInsightController WF_Controller = new REN_RenewalsInsightController();
        WF_Controller.populateChart();
        WF_Controller.getCorporateCurrency();        
        //Assert Opportunity

        system.assertNotEquals(WF_Controller.total_Target,null);  
        //system.assert(WF_Controller.total_Resolved <= currentOpp.REN_Renewal_Target_Resolved__c); 
        //system.assert(WF_Controller.total_Lost >= 0-(currentOpp.REN_Renewal_Target_Lost__c)); 
        //system.assert(WF_Controller.total_Won <= currentOpp.REN_Renewal_Target_Won__c); 
       
        //Assert current filter  
        List<integer> lstCurrentQuaYear = REN_OpportunityDataAccess.UpdateExpQuarterYear(System.Now().Date());  
        System.assert(lstCurrentQuaYear!=null);
    }
}