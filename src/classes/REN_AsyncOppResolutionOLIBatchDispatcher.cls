/**
 * Created Date		: May 25, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Created this scheduler in order to trigger async OLI creation batch. 
 					  This would add some delay so that all the data required for this batch is ready.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2422				 	May 25, 2017	1.1					Added in sprint 721
 *
 */
global with sharing class REN_AsyncOppResolutionOLIBatchDispatcher implements Schedulable {

    global void execute(SchedulableContext sc){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__','.');
		 
		Type targettype = Type.forName(namespace + 'REN_AsyncOppResolutionOLIBatch');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	    	obj.execute(sc);
		}
	}
}