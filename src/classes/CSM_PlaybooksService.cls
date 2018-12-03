public with sharing class CSM_PlaybooksService {
	
   public static List<CSM_PlaybookPlay__c> getClonePlaybookPlayList(List<CSM_PlaybookPlay__c> playbookPlayList, List<CSM_Playbook__c> playbookList) {
        List<CSM_PlaybookPlay__c> clonedPlaybookList = new List<CSM_PlaybookPlay__c>();
     	for (CSM_PlaybookPlay__c pbook:playbookPlayList) {
     		CSM_PlaybookPlay__c pbookClone = pbook.clone(false,false,false,false);
     		pbookClone.CSM_Playbook__c = playbookList[0].id;
     		clonedPlaybookList.add(pbookClone);
    	}
    	return clonedPlaybookList;
    }
}