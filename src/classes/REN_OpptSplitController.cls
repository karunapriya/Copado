public with sharing class REN_OpptSplitController 
{
	public boolean hasRenewAccess {get; private set;}
	public Id opptId4Split{get; set;}
	public String opLnsStr{get; set;}
	public String rrIdsStr{get; set;}
	public String isConsolidatedRR{get; set;}
	public String isValidRli{get; set;}
	public String helpParam {get; set;}	
	
	//Constructor
    public REN_OpptSplitController(ApexPages.StandardController cntlr)
    {
    	helpParam = '';
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled; 	
        //consolidate opportunity
        isConsolidatedRR = ApexPages.currentPage().getParameters().get('rra');     
        isConsolidatedRR = String.isBlank(isConsolidatedRR)?'':isConsolidatedRR;
         
    }
    public PageReference setRecords(){
    	return null;
    } 
    
}