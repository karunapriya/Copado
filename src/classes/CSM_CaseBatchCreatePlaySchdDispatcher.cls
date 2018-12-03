global with sharing class CSM_CaseBatchCreatePlaySchdDispatcher implements Schedulable {
	global void execute(SchedulableContext schedulerContext){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'CSM_CasePlayTaskCreationBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(schedulerContext);
		}
	}
}