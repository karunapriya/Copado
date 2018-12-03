@isTest//(seeAllData=true)
private class OperationsTargetTest {
    static testMethod void opsTargetTest(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account acc = new Account(Name = 'Test Account');
        Database.insert(acc);
        
        Opportunity opp = new Opportunity(Account = acc, AccountId = acc.Id, Name = 'Test Opp', CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2016, 1, 15), StageName = 'Open', OwnerId = thisUser.Id, PO_Number__c = '12345');
        Database.insert(opp);
        String tName = Util.solnExtnNameSpace + 'Period__c';
        Id periodRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = :tName and Name = 'SSI Period' LIMIT 1].Id;
        Period__c p = new Period__c(Name = '2016-Q1', Account__c = acc.Id,
                             Period_Start_Date__c = Date.newInstance(2016, 1, 1),
                             Period_End_Date__c = Date.newInstance(2016, 3, 31),
                             Quarter__c = 'Q1',
                             RecordTypeId = periodRecordTypeId);
        Database.insert(p);
        
        Test.startTest();
        Operations_Target__c opsTarget = new Operations_Target__C();
        ApexPages.StandardController sc = new ApexPages.StandardController(opsTarget);
        OperationsTargetExtension opsTargetExt = new OperationsTargetExtension(sc);
        //opsTargetExt.initializeNew();
        opsTarget.Period__c = p.Id;
        opsTarget.Employee__c = thisUser.Id;
        List<SelectOption> selOpts = opsTargetExt.caseRecordTypeOptions;
        opsTarget.Case_Record_Type__c = 'Booking Request';
        opsTarget.Case_Origin__c = 'Proactive';
        Database.insert(opsTarget);
        PageReference opsTargetView = sc.view();
        Test.setCurrentPage(opsTargetView);
        opsTargetExt.initializeView();
        opsTargetExt.goToEditPage();
        opsTargetExt.getEditModeAndSingle();
        opsTargetExt.genOpsTargetWrapperList[0].genOps.Target__c = 123;
        opsTargetExt.saveChanges();
        Test.setCurrentPage(opsTargetView);
        opsTargetExt.goToEditPage();
        opsTargetExt.updateMode = 'Mass';
        opsTargetExt.getEditModeOrMass();
        opsTargetExt.selectAll = true;
        opsTargetExt.bulkTarget = 444;
        opsTargetExt.genOpsTargetWrapperList[0].selectGenOps = true;
        opsTargetExt.genOpsTargetWrapperList[2].selectGenOps = true;
        opsTargetExt.saveChanges();
        
        Id testCaseRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' and Name = 'Booking Request' LIMIT 1].Id;
        Case c = new Case(RecordTypeId = testCaseRecordType, Origin = 'Proactive', Status = 'New', CurrencyIsoCode = 'USD', Account = acc, AccountId = acc.Id, Opportunity__c = opp.Id);
        Database.insert(c);
        //Case c = new Case(RecordTypeId = testCaseRecordType, Origin = 'Proactive', Status = 'Closed', CurrencyIsoCode = 'USD', Account = acc, AccountId = acc.Id, Opportunity__c = opp.Id);
        c.OwnerId = thisUser.Id;
        Database.update(c);
        
        System.assertEquals(14, opsTargetExt.genOpsTargetWrapperList.size());
        Test.stopTest();
    }
}