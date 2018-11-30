/**
* @author         Nidhi Chouksey(nidhi@comitydesigns.com)
* @date           03.10.2015
* @description    REN_AccountToAssetsCompController class information of all the assets and renewal Opp related to Account.
*/
public with sharing class REN_AccountToAssetsCompController extends CSM_CustomPaginator {
	
	private static final String DEFAULT_SORT_EXPRESSION = 'Name';
	public List<String> assetTableColumnNames{get;set;}
	public List<Asset> assetList {get; set;}
	public String sortExpression{get;set;}
	public String sortDirection{get;set;}
	
		
	public String accountId{
		get;
		set{
			if (String.isNotBlank(value) && this.assetList == null ){
				this.assetList = new List<Asset>();
				accountId = String.escapeSingleQuotes(value);
				this.getAssetForAccountId();
			}
		}
	}	
	
	private Boolean hasRenewAccess;
		
	public REN_AccountToAssetsCompController() {
		this.hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		this.sortDirection = CSM_Constants.SORT_DIRECTION_DESCENDING;
		this.sortExpression = DEFAULT_SORT_EXPRESSION;
		this.populateColumnNames();
	}
	
	public REN_AccountToAssetsCompController getThis(){
    	return this;
	}

	public PageReference getAssetForAccountId() {
		try{
			
			if(this.hasRenewAccess != null && this.hasRenewAccess){
				this.sortDirection = CSM_Util.toggleSortDirection(this.sortDirection);
				this.assetList = REN_AssetDataAccess.getAssetsByAccount(accountId,sortExpression,sortDirection,null);
				this.initiateSetController(assetList);
				this.pageNumber = 1;
				this.pageSize = 10;
			    this.updatePages();
			}
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getStackTraceString()));
		}
		return null;
	}

	private void populateColumnNames(){
    	this.assetTableColumnNames = new List<String>();
    	//this.assetTableColumnNames.add(Schema.SobjectType.Task.fields.Subject.label);
    	this.assetTableColumnNames.add('Asset Name');
    	this.assetTableColumnNames.add('Serial Number');
    	this.assetTableColumnNames.add('Product Name');
    	this.assetTableColumnNames.add('Quantity');
       	this.assetTableColumnNames.add('Price');
    	this.assetTableColumnNames.add('Status');
    	this.assetTableColumnNames.add('Start Date');
    	this.assetTableColumnNames.add('End Date');
    	this.assetTableColumnNames.add('Opportunity Name');
    	this.assetTableColumnNames.add('Sales Stage');
    	this.assetTableColumnNames.add('Close Date');
    }
}