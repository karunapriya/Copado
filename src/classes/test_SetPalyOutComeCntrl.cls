public with sharing class test_SetPalyOutComeCntrl {
    
    public boolean isError{get;set;}
    public string taskId;
    private String nameSpace;
    Private Task taskDetail;

    public test_SetPalyOutComeCntrl (ApexPages.StandardController sc) {
        taskId= sc.getId();
        taskDetail = (Task )sc.getRecord();
        nameSpace= '';
        isError= false;
        List<ApexTrigger> tr =[select NamespacePrefix from ApexTrigger where Name like:'%CSM_PlaybookPlayTrigger%'];
        if (tr!=null && !tr.isEmpty()){
            nameSpace= (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
        }
    }
    
     public PageReference redirectTaskDetail(){
     
       if(taskDetail.IsClosed){
          isError = false;
          return new PageReference( '/apex/' +nameSpace+ 'CSM_SetPlayOutCome?taskId='+taskDetail.id +'&spplId='+taskDetail.CSM_SuccessPlan_Play__c+'&status='+taskDetail.Status);
       } else {
          isError = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Before setting the play outcome, please make sure to update the status to a value in Completed, Resolved, or any value where isClosed '+taskDetail.IsClosed  )); 
          return null; 
       }
       
     }
    
}