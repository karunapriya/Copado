/**
 * Created Date		: Dec 10, 2016
 * Developed By		: Amit, Comity Designs, Inc.
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
 * Amit					User Story				Dec 10, 2016			1.1					@description
 *
 */
global with sharing class REN_ConsolOpportunityScheduledDispatcher implements Schedulable {

	global void execute(SchedulableContext schedulerContext){
	    String namespace = CSM_Util.getNameSpace();
	    namespace = namespace.replace('__','.');
	     
	    Type targettype = Type.forName(namespace + 'REN_ConsolidateOpportunityBatch');  
	    if(targettype!=null) {
	         REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	         obj.execute(schedulerContext);
	    }
	}
}