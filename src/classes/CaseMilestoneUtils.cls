public with sharing class CaseMilestoneUtils {

    public static void completeMilestone(Set<Id> caseIdSet, DateTime completeDate) {
        List<CaseMilestone> cmToUpdateList = MilestoneDataAccess.getCaseMilestoneByIdAndCompletionDate(caseIdSet, null);
        
        if (!cmToUpdateList.isEmpty())
        {
	        for(CaseMilestone cm : cmToUpdateList) {
            cm.CompletionDate = completeDate;
        }
            MilestoneDataAccess.updateCaseMilestone(cmToUpdateList, new List<String>{'CompletionDate'});
        }
    }
}