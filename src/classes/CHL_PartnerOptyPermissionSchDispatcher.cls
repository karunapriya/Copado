global with sharing class CHL_PartnerOptyPermissionSchDispatcher implements Schedulable {
	global void execute(SchedulableContext schedulerContext){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'CHL_PartnerOpportunityPermissionBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(schedulerContext);
		}
	}
}