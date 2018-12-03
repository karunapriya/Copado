global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case c = CaseDataAccess.getCasesByIds(new Set<Id>{(id) caseId})[0]	;
        Date targetDate = c.Opportunity_Earliest_Existing_End_Date__c.addDays(-(Integer.valueOf(c.Target_DIA__c)));
        DateTime targetDateTime = DateTime.newInstanceGmt(targetDate.year(), targetDate.month(), targetDate.day());
        Long targetDateLong = targetDateTime.getTime();
        Long nowLong = DateTime.now().getTime();
        Long differentInMinuteLong = (((targetDateLong - nowLong) / 1000) / 60) + 1;
        Integer differentInMinute = Integer.valueOf(differentInMinuteLong);
        System.debug('##### differentInMinute: ' + differentInMinute);
        if(differentinMinute > 0) return differentInMinute;
        else return 1;
    }
}