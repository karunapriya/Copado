@isTest
private class SalesTargetTest {
    static testMethod void salesTargetTest(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account acc = new Account(Name = 'Test Account');
        Database.insert(acc);
        String tName = Util.solnExtnNameSpace + 'Period__c';
        Id periodRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = :tName  and Name = 'SSI Period' LIMIT 1].Id;
        Period__c p = new Period__c(Name = '2016-Q1', Account__c = acc.Id,
                             Period_Start_Date__c = Date.newInstance(2016, 1, 1),
                             Period_End_Date__c = Date.newInstance(2016, 3, 31),
                             Quarter__c = 'Q1',
                             RecordTypeId = periodRecordTypeId);
        Database.insert(p);
        
        Test.startTest();
        Sales_Target__c salesTarget = new Sales_Target__c(Period__c = p.Id, Employee__c = thisUser.Id, CurrencyIsoCode = 'USD');
        Database.insert(salesTarget);
        ApexPages.StandardController sc = new ApexPages.StandardController(salesTarget);
        SalesTargetExtension salesTargetExt = new SalesTargetExtension(sc);
        PageReference salesTargetView = sc.view();
        Test.setCurrentPage(salesTargetView);
        salesTargetExt.goToEditPage();
        salesTargetExt.getEditModeAndSingle();
        salesTargetExt.genSalesTargetWrapperList[0].genSales.Target__c = 123;
        salesTargetExt.saveChanges();
        Test.setCurrentPage(salesTargetView);
        salesTargetExt.goToEditPage();
        salesTargetExt.updateMode = 'Mass';
        salesTargetExt.getEditModeOrMass();
        salesTargetExt.selectAll = true;
        salesTargetExt.bulkTarget = 444;
        salesTargetExt.genSalesTargetWrapperList[0].selectGenSales = true;
        salesTargetExt.genSalesTargetWrapperList[2].selectGenSales = true;
        salesTargetExt.saveChanges();
        
        Opportunity opp = new Opportunity(Account = acc, AccountId = acc.Id, Name = 'Test Opp', CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2016, 1, 15), StageName = 'Contacted', OwnerId = thisUser.Id, PO_Number__c = '12345');
        Database.insert(opp);
        System.assert(opp.id != null);
        Test.stopTest();
        
        System.assertEquals(14, [SELECT Id FROM Sales_Target_Line_Item__c WHERE Sales_Target__c =: salesTarget.Id].size());
        
    }
}