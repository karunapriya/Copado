public with sharing class CHL_RelatedToSearchRequest {
	public String objectType;
	public String searchString;
	public String accountId;
	//public List<CHL_ObjectType> objectType;
	
	public class CHL_ObjectType {
		public String id;
		public String value;
	}
}