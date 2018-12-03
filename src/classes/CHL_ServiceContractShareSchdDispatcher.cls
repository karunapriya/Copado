global  with sharing class CHL_ServiceContractShareSchdDispatcher implements Schedulable {
    
    global void execute(SchedulableContext schedulerContext){
    String namespace = CSM_Util.getNameSpace();
    namespace = namespace.replace('__','.');
     
    Type targettype = Type.forName(namespace + 'CHL_ServiceContractShareBatch');  
    if(targettype!=null) {
         REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
         obj.execute(schedulerContext);
    }
  }
    
    
}