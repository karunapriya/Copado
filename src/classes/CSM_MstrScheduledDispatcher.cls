global class CSM_MstrScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext sc){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		Type targettype = Type.forName(namespace + 'CSM_MstdDeleteBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
			obj.execute(sc);
		}
	}
}