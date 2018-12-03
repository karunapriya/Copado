global with sharing class CSM_OppBatchCreatePlaySchdDispatcher  implements Schedulable {
	global void execute(SchedulableContext schedulerContext){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'CSM_OppPlayTaskCreationBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(schedulerContext);
		}
	}
}