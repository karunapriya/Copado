public with sharing class REN_SPServiceContractsController extends CSM_CustomPaginator {

	private static final String DEFAULT_SORT_EXPRESSION = 'ServiceContract.Name';
	private List<SObject> contractList;
	public List<String> scTableColumns{get;set;}
	public String sortExpression{get;set;}
	public String sortDirection{get;set;}
	public String acctId{
		get;
		set{
			if(String.isNotBlank(value) && contractList == null ){
				this.contractList = new List<SObject>();
				this.acctId = String.escapeSingleQuotes(value);
				this.retrieveSCForAccount();
			}
		}
	}
	
	private Boolean hasRenewAccess;
	private Boolean isEntitlementEnabled;
	
	public REN_SPServiceContractsController(){
		this.isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
		this.hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		this.sortDirection = CSM_Constants.SORT_DIRECTION_DESCENDING;
		this.sortExpression = DEFAULT_SORT_EXPRESSION;
		this.populateColumnNames();
	}
	
	public PageReference retrieveSCForAccount(){
		try{
			if(this.hasRenewAccess != null && this.hasRenewAccess 
				&& this.isEntitlementEnabled != null && this.isEntitlementEnabled){
				String sortExp = String.escapeSingleQuotes(this.sortExpression);
				String sortDir = String.escapeSingleQuotes(this.sortDirection);
				this.sortDirection = CSM_Util.toggleSortDirection(this.sortDirection);
				this.contractList = REN_ServiceContractsDataAccess.getContractLineItemList(new List<String>{this.acctId}, this.sortExpression, this.sortDirection,null);
				this.initiateSetController(this.contractList);
				this.pageNumber = 1;
				this.pageSize = 10;
			    this.updatePages();
			}
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getStackTraceString()));
		}
		return null;
	}
	
    public REN_SPServiceContractsController getThis(){
    	return this;
	}
    
    private void populateColumnNames(){
    	this.scTableColumns = new List<String>();
    	this.scTableColumns.add(system.label.REN_LBL_SC_NAME);
    	this.scTableColumns.add(system.label.REN_LBL_SC_NUMBER);
    	this.scTableColumns.add(system.label.REN_LBL_SC_LI_NUMBER);
    	this.scTableColumns.add(Schema.SobjectType.Product2.fields.Name.label);
    	this.scTableColumns.add(system.label.REN_LBL_SCLI_QUANTITY);
    	this.scTableColumns.add(system.label.REN_LBL_SC_TOTAL_PRICE);
    	this.scTableColumns.add(system.label.REN_LBL_SCLI_STATUS);
    	this.scTableColumns.add(system.label.REN_LBL_SCLI_START_DATE);
    	this.scTableColumns.add(system.label.REN_LBL_SCLI_END_DATE);
    	this.scTableColumns.add(Schema.SobjectType.Opportunity.fields.Name.label);
    	this.scTableColumns.add(Schema.SobjectType.Opportunity.fields.StageName.label);
    	this.scTableColumns.add(Schema.SobjectType.Opportunity.fields.CloseDate.label);
    }
	
}