public with sharing class REN_MergeComponentController {
	public String updateablFieldJSON{get;set;}
	public String selectedMasterId{get;set;}
	
	
	public String localeDateFormat {
		set;
		get {
			localeDateFormat = String.isBlank(localeDateFormat) ? CSM_Util.getLocaleDateMap().get(userInfo.getLocale()) : localeDateFormat;
			return String.isBlank(localeDateFormat) ? 'M/d/yyyy' : localeDateFormat;
		}
	}
	
	public List<SObject> sourceSObjects {
		get;
		set {
			if (value != null){
				sourceSObjects = value;
			}
		}
	}

	public List<REN_MergeOppFieldWrapper> sourceReadFieldList {
		get;
		set {
			if (value != null){
				sourceReadFieldList = value;
			}
			
		}
	}
	

	public List<REN_MergeOppFieldWrapper> sourceUpdateFieldList {
		get;
		set {
			if (value != null){
				sourceUpdateFieldList = value;
			}
			
		}
	}
	
	
	public String sourceUpdateFieldJSON {
		get;
		set {
			if (value != null){
				sourceUpdateFieldJSON = value;
			}
			
		}
	}
	
		
	public String targetSelectedValueJSON {
		get;
		set {
			if (value != null){
				targetSelectedValueJSON = value;
			}
			
		}
	}
}