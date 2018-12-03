public with sharing class REN_BatchActivityWrapper {
    public SObject batchActivity{get; set;}
    public String batchNumber{get; set;}
    public String batchType{get; set;}
    public String closedDateDependsOn{get; set;}
    public String closedDateOption{get; set;}
    public String createdByName{get; set;}
    public Id createdById{get; set;}
    public DateTime createdOn{get; set;}
    public Boolean emailNotificationOn{get; set;}
    public Integer assetsFailedCount{get; set;}
    public String filterCriteria{get; set;}
    public Integer generatedRecordsCount{get; set;}
    
    public Id groupingId{get; set;}
    public String groupingDesc{get; set;}
    public String groupingFilterCriteria{get; set;}
    public String groupingName{get; set;}
    
    public String groupingAndFilterCriteria{get; set;}
    public String groupingCriteria{get; set;}
    
    public DateTime jobCompletionDate{get; set;}
    public String jobId{get; set;}
    public DateTime jobStartDate{get; set;}
    
    public Id lastModifiedByUserId{get; set;}
    public String lastModifiedByUserName{get; set;}
    
    public DateTime lastModifiedOn{get; set;}
    public String objectName{get; set;}
    public String planTemplateAssignmentName{get; set;}
    
    public Id priceBookId{get; set;}
    public String priceBookName{get; set;}
    
    public String renewableProducts{get; set;}
    public Id schedulerId{get; set;}
    
    public Id sourceRecordFilterId{get; set;}
    public String sourceRecordFilterName{get; set;}
    public String sourceRecordFilterDesc{get; set;}
    public String sourceRecordFilterRecordKey{get; set;}
    
    public String status{get; set;}
    
    public Id successPlanTemplateId{get; set;}
    public String successPlanTemplateName{get; set;}
    
    public String totalGeneratedValue{get; set;}
}