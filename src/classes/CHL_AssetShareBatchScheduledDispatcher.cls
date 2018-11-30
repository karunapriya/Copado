/**
 * Created Date		: Sep 29, 2017
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - Scheduler class for Asset sharing batch
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *___________________________________________________________________________________________________________________________________
 *
 * Tanvi					US2765				Sep 29, 2017			1.1				Schedule class to schedule Asset sharing batch	
 *
 */
global with sharing class CHL_AssetShareBatchScheduledDispatcher implements Schedulable {
	
	global void execute(SchedulableContext schedulerContext){
	    String namespace = CSM_Util.getNameSpace();
	    namespace = namespace.replace('__','.');
	     
	    Type targettype = Type.forName(namespace + 'CHL_AssetSharingBatch');  
	    if(targettype!=null) {
	         REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	         obj.execute(schedulerContext);
	    }
  	}
}