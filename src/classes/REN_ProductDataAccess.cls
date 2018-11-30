public with sharing class REN_ProductDataAccess {
	
	public static Map <ID, Product2> getProductDetail(){
		List<String> productFieldsList = new List<String>{REN_Constants.FLD_ID,  REN_Constants.OBJ_OLI_PRODUCTCODE};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PRODUCT, productFieldsList, CSM_Constants.DML_OPERATION_READ); 
		return new Map <ID, Product2> ([Select p.ProductCode, p.Name, p.Id From Product2 p LIMIT 50000]);
	}
}