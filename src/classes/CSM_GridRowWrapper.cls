public with sharing class CSM_GridRowWrapper {
    public String id {get;set;}
    public String accountId {get;set;}
    public String playSelected {get;set;}
    public Boolean taskState {get;set;} 
    public String actionValue{get;set;}
    public List<CSM_GridColumnWrapper> columns {get; set;}
    public List<CSM_GridActionWrapper> actions {get; set;}
    public String namespace {get; set;} 
    public String entNameSpace {get; set;} 
    public Boolean hasGridImage {get; set;}
    public Boolean isActive {get; set;}
    public Sobject sObj {get;set;}
    public Boolean hasAccess {get; set;}
    public Boolean isMC {get; set;}
    public Integer taskTotal {get; set;}
    public Map<Id,String> lineMap {get;set;}    
    public String reasonCode{get;set;}
    public String opptyProduct{get;set;}
}