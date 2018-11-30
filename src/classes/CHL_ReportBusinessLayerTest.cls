@isTest(SeeAllData=true)
private class CHL_ReportBusinessLayerTest {

    static testMethod void getReportDetails_Test() {
        Test.startTest();  
            List<CHL_ReportBusinessLayer.CHL_ReportWrapper> resWrapperList = new List<CHL_ReportBusinessLayer.CHL_ReportWrapper>();
            resWrapperList = CHL_ReportBusinessLayer.getReportDetails('Test');
            
            CHL_ReportBusinessLayer.saveReports('{"id":"00Oo00c00a3YBK","name":"Quotes","tileVisible":true}');
            CHL_ReportBusinessLayer.saveReports('{"id":"00Oo00d400a3YBK","name":"Quotes_Test","tileVisible":false}');
            system.assert(resWrapperList != null);
        Test.stopTest();
    }
}