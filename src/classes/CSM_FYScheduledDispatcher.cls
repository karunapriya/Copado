global class CSM_FYScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext sc) 
    {
    	String namespace = CSM_Util.getNameSpace();
        namespace = namespace.replace('__','');
        	
        Type targettype = Type.forName((namespace!=null && namespace.length()>0?namespace+'.':'')+'CSM_FiscalCustomSettingUpdatesBatch');   
        if(targettype!=null) {
            CSM_IScheduleDispatched obj = (CSM_IScheduleDispatched)targettype.NewInstance();
           	obj.execute(sc);
		}
    } 
}