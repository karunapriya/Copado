public with sharing class CSM_PlayTaskWrapper {
	public CSM_Play_Task__c playTask {get; set;}
	public Integer seqNum {get; set;}
	
	public CSM_PlayTaskWrapper(CSM_Play_Task__c playTaskItem, Integer num) {
		playTask = playTaskItem;
		seqNum = num;
	}
}