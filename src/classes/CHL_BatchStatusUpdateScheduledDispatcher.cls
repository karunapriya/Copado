global class CHL_BatchStatusUpdateScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext sc){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'CHL_NeedStatusUpdateBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(sc);
		}
	}
}