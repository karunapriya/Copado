/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           08.27.2014
* @description    CSM_TaskWrapper allows user to make use of this wrapper class to pass information 
*/
public with sharing class CSM_TaskWrapper {

    public String TaskId {get; set;}
	public String playResultId {get;set;}    
    public String AccountId {get; set;}
    public Boolean UpdatedBy_Play_Task_Batch_c {get; set;}    
    public String Subject {get; set;}
    public String assignToPerson {get; set;}
    public Datetime ActivateDate {get; set;}
    public Date completedDate {get; set;} 
    public Boolean isComplete {get; set;}
    public Boolean isManual {get; set;}
    public String AccountPlanId {get; set;}
    public String TaskProcessingId {get; set;}
    public String PlayTaskId {get; set;}
    public String PlayId {get; set;}
    public String PlayBookPlayId {get; set;}
    public String RiskReason {get; set;}
    public String Comments {get; set;}
    public CSM_Account_Plan__c AccountPlan {get; set;}
    public CSM_Play_Task__c PlayTask {get; set;}
    public CSM_PlaybookPlay__c PlayBookPlay {get; set;}
    public CSM_Play__c Play {get; set;}
    public CSM_Task_Processing__c TaskProcessing {get; set;}
    public CSM_SuccessPlan_Play__c successPlanPlay {get; set;}
    public String processingStatus {get; set;}
    public DateTime playEnterDate {get; set;}
    public DateTime playExitDate {get; set;}
    public String opportunityId{get;set;}
    //US520
    public String taskType {get; set;}
    public String Status {get; set;}    
    public String recordTypeId {get; set;}
    //US1264
    public String playOutcome{get;set;}
}