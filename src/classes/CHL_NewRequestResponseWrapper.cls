public class CHL_NewRequestResponseWrapper {
	//public list<String> requestType;
	//public list<String> priority; //Need  to comment for intregration
	//public list<String> relatedTo; //Need  to comment for intregration
	 public List<CHL_RelatedTo> relatedTo; //-- US809 : Need  to uncomment for intregration
	 public List<CHL_Priority> priority; //-- US809 : Need  to uncomment for intregration
	 public List<CHL_RequestType> requestType;
	
	public CHL_NewRequestResponseWrapper (){
		requestType = new List<CHL_RequestType>();
		//priority = new List<String>(); //Need  to comment for intregration
		//relatedTo = new List<String>(); //Need  to comment for intregration
		priority = new List<CHL_Priority>(); //-- US809 : Need  to uncomment for intregration
		relatedTo = new List<CHL_RelatedTo>(); //-- US809 : Need  to uncomment for intregration
	}
	
	  //US809 : Need  to uncomment for intregration
	public class CHL_RelatedTo{
		public String id;
		public String value;
	}
	
	public class CHL_Priority{
		public String id;
		public String value;
		
	}
	
	public class CHL_RequestType{
		public String id;
		public String value;
	}
	
}