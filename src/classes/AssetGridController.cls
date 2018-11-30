global with sharing class AssetGridController {

	private static final String DEFAULT_SORT_EXPRESSION = 'Name';
	public List<Asset> assetList {get; set;}
	
	@RemoteAction
	global static List<Asset> getAssetForAccountId(Integer pageNumber, Integer offset) {
		String sortDirection = 'ASC';
		String sortExpression = 'Name';
		List<Asset> assetList = REN_AssetDataAccess.getAssetsByAccount('001o0000004QIqi', sortExpression, sortDirection);
		
		return assetList;
	}
}