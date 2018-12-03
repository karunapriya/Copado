/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/28/2016
 * @description  Milestone Data Access class
 */
public with sharing class MilestoneDataAccess
{
	
	public static List<AggregateResult> getDynamicCaseMilestone(String aditionalFilterConditions,  Set<String> caseRecordTypesToExclude)
	{
		List<String> caseFieldList = new List<String>{'OwnerId', 'Priority', Util.solnExtnNameSpace +'Total_Compliant_Rate__c','IsClosed','Origin'};
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_READ);
		
		List<String> milestoneFieldList = new List<String>{'TargetResponseInHrs', 'ElapsedTimeInHrs'};
		Util.checkCRUD_FLS('CaseMileStone', milestoneFieldList, Constants.DML_OPERATION_READ);
		
		String queryUserLevel = ' SELECT Case.OwnerId ownerId, Case.Owner.Name ownerName, Case.Priority priority, COUNT(Id) recordCount, SUM(Case.Total_Compliant_Rate__c) compliantCount, '
                                    +' SUM(TargetResponseInHrs) totalTargetSLA, SUM(ElapsedTimeInHrs) totalSLA '
                                    +' FROM CaseMileStone ';
        String conditions = ' WHERE Case.IsClosed = true AND Case.Origin != \'Proactive\' AND Case.Priority != null AND Case.RecordType.Name NOT IN :caseRecordTypesToExclude ';
        String queryLimit = ' LIMIT 999999 ';   // Limit upto 1 million rows
        String groupByConditionUserLevel = ' Group By Case.OwnerId, Case.Owner.Name, Case.Priority ';
        
        return  Database.query(queryUserLevel + conditions + aditionalFilterConditions + groupByConditionUserLevel + queryLimit);
	}
	
	/**
    * @description : This method returns a list of case milestones for the given set of case ids and completion date
    * @param a set of case ids
    * @param a completion date
    * @return a list of case milestones
    */
	public static List<CaseMilestone> getCaseMilestoneByIdAndCompletionDate(Set<Id> caseIds, Date compDate)	
	{
		List<String> milestoneFieldList = new List<String>{'Id', 'CaseId', 'CompletionDate'};
		Util.checkCRUD_FLS('CaseMileStone', milestoneFieldList, Constants.DML_OPERATION_READ);
		return [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId = :caseIds AND CompletionDate = :compDate];
	}
	
	/**
    * @description : This method updates cases
    * @param a list of cases
    */
	public static void updateCaseMilestone(List<CaseMilestone> updatedMilestones, List<String> caseMilestonefields)
	{
		Util.checkCRUD_FLS('CaseMileStone', caseMilestonefields, Constants.DML_OPERATION_UPDATE);
		update updatedMilestones;
	}	
	
	/**
    * @description : return various aggregate functions of CaseMilestone records
    */
    public static  List<AggregateResult> getAggregateGrpByNameTypeTarget(Boolean isCaseClosedFlag, Set<String> caseRecordTypesToExclude)
    {	
    	String namespace = Util.solnExtnNameSpace;
    	List<String> caseFieldList = new List<String>{namespace +'Total_Compliant_Rate__c',
    		namespace +'Operations_Target__c'};
    	Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_READ);
    	
    	List<String> milestoneCaseFieldList = new List<String>{'TargetResponseInHrs','ElapsedTimeInHrs','Id'};
    	Util.checkCRUD_FLS('CaseMileStone', milestoneCaseFieldList, Constants.DML_OPERATION_READ);
    	
    	return [SELECT Case.Owner.Name ownerName, 
    	               Case.RecordType.Name caseType, 
    	               Case.Operations_Target__c target,
    	               COUNT(Id) recordCount, 
    	               SUM(Case.Total_Compliant_Rate__c) compliantCount,
    	               SUM(Case.Opportunity__r.DIA_Compliance__c) diaCompliantCount, 
    	               SUM(Case.Operations_Target__r.Target__c) goal, 
    	               SUM(TargetResponseInHrs) totalTargetSLA, 
    	               SUM(ElapsedTimeInHrs) totalSLA 
    	          FROM CaseMileStone
    	         WHERE Case.IsClosed = :isCaseClosedFlag 
    	           AND Case.Operations_Target__c != null 
    	           AND Case.RecordType.Name NOT IN :caseRecordTypesToExclude
    	      GROUP BY Case.Owner.Name, Case.RecordType.Name, Case.Operations_Target__c
    	           LIMIT 10000];
    }
    
    /**
    * @description : return various aggregate functions of CaseMilestone records
    */
    public static  List<AggregateResult> getAggregateGrpByNameTarget(Boolean isCaseClosedFlag, Set<String> caseRecordTypesToExclude)
    {
        //List<String> milestoneCaseFieldList = new List<String>{'Case.Owner.Name','Case.Operations_Target__c','Case.Total_Compliant_Rate__c','Case.Operations_Target__r.Target__c','Case.Opportunity__r.DIA_Compliance__c','TargetResponseInHrs','ElapsedTimeInHrs'};
        List<String> milestoneCaseFieldList = new List<String>{'TargetResponseInHrs','ElapsedTimeInHrs'};
        Util.checkCRUD_FLS('CaseMileStone', milestoneCaseFieldList, Constants.DML_OPERATION_READ);
        
        String namespace = Util.solnExtnNameSpace;
        List<String> CaseFieldList = new List<String>{'Priority',namespace +'Total_Compliant_Rate__c',
        	namespace +'Operations_Target__c',namespace + 'Opportunity__c'};
    	Util.checkCRUD_FLS('Case', CaseFieldList, Constants.DML_OPERATION_READ);
    	
        return [SELECT Case.Owner.Name ownerName, 
                       Case.Operations_Target__c target, 
                       COUNT(Id) recordCount,
                       SUM(Case.Total_Compliant_Rate__c) compliantCount,
                       SUM(Case.Operations_Target__r.Target__c) goal, 
                       SUM(Case.Opportunity__r.DIA_Compliance__c) diaCompliantCount,
                       SUM(TargetResponseInHrs) totalTargetSLA, 
                       SUM(ElapsedTimeInHrs) totalSLA 
                  FROM CaseMileStone
                  WHERE Case.IsClosed = :isCaseClosedFlag 
                  AND Case.Operations_Target__c != null 
                  AND Case.RecordType.Name NOT IN :caseRecordTypesToExclude
             GROUP BY Case.Owner.Name, Case.Operations_Target__c
             LIMIT 10000];
    }
   
     /**
    * @description : return various aggregate functions of CaseMilestone records
    */
    public static  List<AggregateResult> getAggregateGrpByOwnerNamePriority(Boolean isCaseClosedFlag, Set<String> caseRecordTypesToExclude)
    {
    	//List<String> milestoneCaseFieldList = new List<String>{'Case.OwnerId','Case.Owner.Name','Case.Priority','Case.Total_Compliant_Rate__c','Case.Operations_Target__r.Target__c','Case.Opportunity__r.DIA_Compliance__c','TargetResponseInHrs','ElapsedTimeInHrs'};
    	List<String> milestoneCaseFieldList = new List<String>{'TargetResponseInHrs','ElapsedTimeInHrs'};
    	Util.checkCRUD_FLS('CaseMileStone', milestoneCaseFieldList, Constants.DML_OPERATION_READ);
    	
    	String namespace = Util.solnExtnNameSpace;
    	List<String> CaseFieldList = new List<String>{'Priority',namespace +'Total_Compliant_Rate__c',
    		namespace+'Operations_Target__c',namespace + 'Opportunity__c'};
    	Util.checkCRUD_FLS('Case', CaseFieldList, Constants.DML_OPERATION_READ);
    	
    	return [SELECT Case.OwnerId ownerId, 
    	               Case.Owner.Name ownerName, 
    	               Case.Priority priority, 
    	               COUNT(Id) recordCount,
    	               SUM(Case.Total_Compliant_Rate__c) compliantCount,
    	               SUM(TargetResponseInHrs) totalTargetSLA, 
    	               SUM(ElapsedTimeInHrs) totalSLA 
    	          FROM CaseMileStone
    	         WHERE Case.IsClosed = :isCaseClosedFlag 
    	         AND Case.Origin != 'Proactive' 
    	         AND Case.Priority != null 
    	         AND Case.RecordType.Name NOT IN :caseRecordTypesToExclude
    	    GROUP BY Case.OwnerId, Case.Owner.Name, Case.Priority
    	    LIMIT 10000];
    }
    
    public static  List<AggregateResult> getAggregateGrpByNamePriority(Boolean isCaseClosedFlag, Set<String> caseRecordTypesToExclude)
    {
    	//List<String> milestoneCaseFieldList = new List<String>{'Case.RecordType.Name','Case.Priority','Case.Total_Compliant_Rate__c','TargetResponseInHrs','ElapsedTimeInHrs'};
    	List<String> milestoneCaseFieldList = new List<String>{'TargetResponseInHrs','ElapsedTimeInHrs'};
    	Util.checkCRUD_FLS('CaseMileStone', milestoneCaseFieldList, Constants.DML_OPERATION_READ);
    	
    	List<String> CaseFieldList = new List<String>{'Priority',Util.solnExtnNameSpace +'Total_Compliant_Rate__c'};
    	Util.checkCRUD_FLS('Case', CaseFieldList, Constants.DML_OPERATION_READ);
    	
    	return[SELECT Case.RecordType.Name caseType, 
    	              Case.Priority priority, 
    	              COUNT(Id) recordCount, 
    	              SUM(Case.Total_Compliant_Rate__c) compliantCount,
    	              SUM(TargetResponseInHrs) totalTargetSLA, 
    	              SUM(ElapsedTimeInHrs) totalSLA
    	          FROM CaseMileStone
    	         WHERE Case.IsClosed = :isCaseClosedFlag 
    	           AND Case.Origin != 'Proactive' 
    	           AND Case.Priority != null 
    	           AND Case.RecordType.Name NOT IN :caseRecordTypesToExclude
    	      GROUP BY Case.RecordType.Name, Case.Priority
    	      LIMIT 10000];
    }
      
    
    public static List<AggregateResult> getCountByIsClosedAndType(Boolean isCaseClosedFlag, String developerNameStr, String subCaseType)
    {
    	List<String> caseFieldList = new List<String>{Util.solnExtnNameSpace +'Sub_Case_Type__c','Status'};
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_READ);
		
        List<String> milestoneCaseFieldList = new List<String>{'Id'};
        Util.checkCRUD_FLS('CaseMileStone', milestoneCaseFieldList, Constants.DML_OPERATION_READ);
    	
        return [SELECT Case.Status status, 
                       Count(Id) recordCount 
                  FROM CaseMileStone
                  WHERE Case.IsClosed = :isCaseClosedFlag
                   AND Case.RecordType.DeveloperName = :developerNameStr
                   AND Case.Sub_Case_Type__c = :subCaseType 
              GROUP BY Case.Status
              LIMIT 10000];
    }
    public static List<AggregateResult> getDynamicCaseMilestoneWithType(String aditionalFilterConditions,  Set<String> caseRecordTypesToExclude)
	{
		List<String> milestoneFieldList = new List<String>{'Id', 'TargetResponseInHrs','ElapsedTimeInHrs'};
	    Util.checkCRUD_FLS('CaseMileStone', milestoneFieldList, Constants.DML_OPERATION_READ);
	    
	    List<String> caseFieldList = new List<String>{'Priority',Util.solnExtnNameSpace +'Total_Compliant_Rate__c','IsClosed','Origin'};
		Util.checkCRUD_FLS('Case', caseFieldList, Constants.DML_OPERATION_READ);
	    
        String queryUserLevel = ' SELECT Case.RecordType.Name caseType, Case.Priority priority, COUNT(Id) recordCount, SUM(Case.Total_Compliant_Rate__c) compliantCount, '
                                    +' SUM(TargetResponseInHrs) totalTargetSLA, SUM(ElapsedTimeInHrs) totalSLA '
                                    +' FROM CaseMileStone ';
        String conditions = ' WHERE Case.IsClosed = true AND Case.Origin != \'Proactive\' AND Case.Priority != null AND Case.RecordType.Name NOT IN :caseRecordTypesToExclude ';
        String queryLimit = ' LIMIT 999999 ';   // Limit upto 1 million rows
        String groupByConditionUserLevel = ' Group By Case.RecordType.Name, Case.Priority ';
        return Database.query(queryUserLevel + conditions + aditionalFilterConditions + groupByConditionUserLevel + queryLimit);
	}
}