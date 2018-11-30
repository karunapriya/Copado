/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@isTest
global class TChargentOperations {
    global static Boolean AllowMultipleAuth;
    global static Boolean DebugMode {
        get;
        set;
    }
    global static Boolean IsBatch;
    global static ChargentBase.ChargentWebService.ChargentWebOutput PaymentResult {
        get;
        set;
    }
    global static Set<Id> scopeIdSet;
    global TChargentOperations() {

    }
    webService static ChargentBase.TChargentOperations.TChargentResult AuthorizeOpportunity_Click(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult AuthorizeOpportunity_ClickJSON(String InputParams) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargeAuthorizedTransaction_Click(Id TransactionId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargeAuthorizedTransaction_ClickJSON(String InputParams) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargeOpportunity_Batch(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargeOpportunity_BatchSObject(SObject recordObject) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargeOpportunity_Click(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargeOpportunity_ClickJSON(String InputParams) {
        return null;
    }
    @Future(callout=true)
    global static void ChargeOpportunity_async(Id objectId) {

    }
    webService static ChargentBase.TChargentOperations.TChargentResult ChargentProcessing(String InputParams) {
        return null;
    }
    global static SObject GetOOCById(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult GetTransactionStatus_Batch(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult GetTransactionStatus_BatchSObject(SObject trxObj) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult RefundOpportunity_Click(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult RefundOpportunity_ClickJSON(String InputParams) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult RefundTransaction_Click(Id TransactionId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult RefundTransaction_ClickJSON(String InputParams) {
        return null;
    }
    @isTest(SeeAllData=false OnInstall=false)
    global static void TChargentOperationsTest() {

    }
    @isTest(SeeAllData=false OnInstall=false)
    global static void TChargentOperationsTest1() {

    }
    webService static ChargentBase.TChargentOperations.TChargentResult VoidOpportunity_Click(Id objectId) {
        return null;
    }
    webService static ChargentBase.TChargentOperations.TChargentResult VoidTransaction_Click(Id TransactionId) {
        return null;
    }
    global static void am11() {

    }
    global static void am12() {

    }
    global static void am13() {

    }
    global static void am14() {

    }
    global static void am15() {

    }
    global static void am16() {

    }
    global static void am17() {

    }
    global static void am18() {

    }
    global static void am19() {

    }
    global static void am20() {

    }
    global static void am21() {

    }
    global static void am22() {

    }
    global static void am23() {

    }
    global static void am24() {

    }
    global static void am25() {

    }
    global static void am26() {

    }
    global static void am27() {

    }
    global static void am28() {

    }
    global static void am29() {

    }
    global static void am30() {

    }
    global static void am31() {

    }
    global static void am32() {

    }
    global static void am33() {

    }
    global static void am34() {

    }
    global static void am35() {

    }
    global static void am36() {

    }
    global static void am37() {

    }
    global static void am38() {

    }
    global static void am39() {

    }
    global static void am40() {

    }
    global static void am41() {

    }
    global static void am42() {

    }
    global static void am43() {

    }
    global static void am44() {

    }
    global static void am45() {

    }
    global static void am46() {

    }
    global static void am47() {

    }
    global static void am48() {

    }
    global static void am49() {

    }
    webService static void createTransaction(Id objectId, String responseMessage, String responseStatus, String transactionType) {

    }
global class TChargentResult {
    @WebService
    webService String DebugString;
    @WebService
    webService String Message;
    @WebService
    webService String order_JSON;
    @WebService
    webService Boolean Reload;
    @WebService
    webService String responseData;
    @WebService
    webService String ReturnURL;
    @WebService
    webService String Status;
    @WebService
    webService String TransactID;
    @WebService
    webService String transaction_JSON;
    global TChargentResult() {

    }
    global void SetStatus(Boolean st) {

    }
}
}
