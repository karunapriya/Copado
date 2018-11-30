public with sharing class REN_AsyncMetricsFieldCalculationSchedule implements Schedulable{

	public Set<ID> impactedOpportunitySet {get;set;}
	public String calculationType {get;set;} //RLI-OLI, RLI, OLI
	public Integer batchSize{get;set;}

	public void execute(SchedulableContext sc){
		System.debug('SchedulableContextID: ' + SC + '\n\n2-1- Call REN_AsyncMetricsFieldCalculationSchedule: execute: ');
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__', '.');
		Type targettype = Type.forName(namespace + 'REN_AsyncMetricsFieldCalculation');  
		if(targettype!=null) {
	   		REN_AsyncMetricsFieldCalculation obj = (REN_AsyncMetricsFieldCalculation)targettype.NewInstance();
	    	obj.execute(sc, calculationType, impactedOpportunitySet, batchSize);
		}
	}
	
}