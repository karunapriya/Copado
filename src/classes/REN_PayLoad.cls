public class REN_PayLoad {
	public List<mainData> data {get;set;}
	
    public class mainData{
		public String type {get;set;}
	    public String id {get;set;}
	    public Map<String, String> attributes{get;set;}
	    public Map<String, String> links {get;set;}
	}
}