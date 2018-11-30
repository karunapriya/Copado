global with sharing class CSM_AccountPlanDispatcher implements Schedulable {

	//Schedulable method
    global void execute(SchedulableContext SC)
    {   
 		String namespace = CSM_Util.getNameSpace();
       	namespace = namespace.replace('__','');         
       	Type targettype = Type.forName((namespace!=null && namespace.length()>0?namespace+'.':'')+'CSM_AccountPlanBatchUpdate');
		if(targettype!=null){
			CSM_IScheduleDispatched obj = (CSM_IScheduleDispatched)targettype.NewInstance();
			obj.execute(sc);
		}
    } 
}