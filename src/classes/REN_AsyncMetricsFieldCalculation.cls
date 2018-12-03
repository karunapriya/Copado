public with sharing abstract class REN_AsyncMetricsFieldCalculation implements REN_IScheduleDispatched, Database.Stateful, Database.Batchable<SObject> {
	
	public Set<ID> impactedOpportunitySet {get;set;}
	public String  calculationType {get;set;} //RLI-OLI, RLI, OLI
	public Integer batchSize{get;set;}


	//This method will be executed when we schedule from UI. Called from REN_AsyncMetricsFCalculationDispatcher.execute();
	public void execute(SchedulableContext SC) {  //It will execute first time. 
		batchSize = CSM_Util.getCustomListSetting('REN_AsyncMetricsFieldCalculation');
		batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
		System.debug('SchedulableContextID: ' + SC + '\n\nA- Call REN_AsyncMetricsFieldCalculation: execute: ' + this);
		REN_AsyncMetricsFCalculationDispatcher.executeMe(null, 'RLI-OLI', null, batchSize, true);
	}
	
	//This method will be executed when we schedule from Code. Called from REN_AsyncMetricsFieldCalculationSchedule.execute().
	public void execute(SchedulableContext SC, String calculationType, Set<ID> impactedOpportunitySet, Integer batchSize) {  
		this.calculationType = calculationType; 
		this.impactedOpportunitySet = impactedOpportunitySet; 
		this.batchSize = batchSize; 
		System.debug('SchedulableContextID: ' + SC +  '\n\nB- Call REN_AsyncMetricsFieldCalculation: execute: ' + this);
		REN_AsyncMetricsFCalculationDispatcher.executeMe(SC, calculationType, impactedOpportunitySet, batchSize, true);
	}
}