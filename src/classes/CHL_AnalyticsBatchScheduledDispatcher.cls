/**
 * Created Date		: Dec 7, 2016
 * Developed By		: Dheeraj, Comity Designs, Inc.
 *
 * Function			: @description - Schedule Analytics batch class.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj					US1837				Dec 7, 2016			1.1					@description
 *
 */
global  with sharing class CHL_AnalyticsBatchScheduledDispatcher  implements Schedulable {
  global void execute(SchedulableContext schedulerContext){
    String namespace = CSM_Util.getNameSpace();
    namespace = namespace.replace('__','.');
     
    Type targettype = Type.forName(namespace + 'CHL_CommunityAnalyticsBatch');  
    if(targettype!=null) {
         REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
         obj.execute(schedulerContext);
    }
  }
}