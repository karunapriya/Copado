global with sharing class REN_BatchOppGenScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext sc){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'REN_OpportunityGenerationBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(sc);
		}
		/*
		targettype = Type.forName(namespace + 'REN_BatchOppFailureDataCleanupBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(sc);
		}
		*/
	}
}