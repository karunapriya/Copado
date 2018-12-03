/**
 * Created Date		: Oct 27, 2016
 * Developed By		: prashant, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * prashant					User Story				Oct 27, 2016			1.1					@description
 * 
 */
	
	global class CaseTargetDateScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext sc){
		String namespace = Util.solnExtnNameSpace;
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'CaseTargetDateBatch');  
		if(targettype!=null) {
	   		IScheduleDispatched obj = (IScheduleDispatched)targettype.NewInstance();
	    	obj.executeScheduler(sc);
		}
	}
}