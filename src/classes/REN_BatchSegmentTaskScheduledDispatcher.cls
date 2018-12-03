/**
 * Created Date		: Apr 17, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - This class will be used to schedule a batch for Segment Task creation
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Apr 17, 2017			1.1					@description
 *
*/
global with sharing class REN_BatchSegmentTaskScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext sc){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'REN_SegmentTaskCreationBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(sc);
		}
	}
}