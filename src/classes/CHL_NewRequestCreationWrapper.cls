public with sharing class CHL_NewRequestCreationWrapper {
	
	public String message;
	public String subject;
	public CHL_Data account;
	public CHL_Data priority;
	public CHL_Data relatedTo;
	public CHL_Data type;
	public CHL_Data relatedObject;
	
	public CHL_NewRequestCreationWrapper (){
		account = new CHL_Data();
		priority = new CHL_Data();
		relatedTo = new CHL_Data();
		type = new CHL_Data();
		relatedObject = new CHL_Data();
	}	
	
	public class CHL_Data{
		public String id;
		public String value;
	} 
}