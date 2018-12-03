public with sharing class REN_MultiSelectPickListCompCtrl extends REN_BaseChildController{
	public List<SObject> allRecipients{get;set;}
	public List<SObject> selectedRecipients{get;set;}
	public List<String> fieldNames{get;set;}
	public String jsonNewSelectedRecipients{get;set;}
	public String objectName{get;set;}	
	public List<SObject> finalRecipients{get;set;}
	public REN_BaseMainController mainControllerRef{get;
		set{
			mainControllerRef = value;
			this.objectNameSuper = 'dummy';
			this.baseMainController = mainControllerRef;
		}	
	}
	
	
	public REN_MultiSelectPickListCompCtrl(){
    	super();
	}
	
	public string getjsonAllRecipients(){
		List<RecipientWrap> lstRWrap = new List<RecipientWrap>();
		if(allRecipients != null){
			for(SObject sObj: allRecipients){
				RecipientWrap rWrap = new RecipientWrap();
				for(String field: fieldNames){
					if(field.toUpperCase() == 'ID'){
						rWrap.Id = (String)sObj.get(field);				
					}
					if(field.toUpperCase() == 'NAME'){
						rWrap.Name = (String)sObj.get(field);				
					}
					if(field.toUpperCase() == 'EMAIL'){
						rWrap.Email = (String)sObj.get(field);				
					}
				}
				lstRWrap.add(rWrap);		
			}
		}
		return JSON.serialize(lstRWrap);
	}
	
	public string getJsonSelectedRecipients(){
		List<RecipientWrap> lstRWrap = new List<RecipientWrap>();
		if(selectedRecipients != null){
			for(SObject sObj: selectedRecipients){
				RecipientWrap rWrap = new RecipientWrap();
				for(String field: fieldNames){
					if(field.toUpperCase() == 'ID'){
						rWrap.Id = (String)sObj.get(field);				
					}
					if(field.toUpperCase() == 'NAME'){
						rWrap.Name = (String)sObj.get(field);				
					}
					if(field.toUpperCase() == 'EMAIL'){
						rWrap.Email = (String)sObj.get(field);				
					}
				}
	
				lstRWrap.add(rWrap);		
			}
		}
		jsonNewSelectedRecipients = JSON.serialize(lstRWrap);
		return jsonNewSelectedRecipients;

	}


    public class RecipientWrap {
        public string Id;
        public string Name;
        public string Email;
    }

	public PageReference retrieveSelectedRecipients(){
		String str = EncodingUtil.urlDecode(jsonNewSelectedRecipients,CSM_Constants.UTF_8);
		List<Recipientwrap> lstUsers = (List<Recipientwrap>)JSON.deserialize(str,List<Recipientwrap>.class);
		finalRecipients = new List<SObject>();
		for(Recipientwrap rWrap: lstUsers){
			SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
			sObj.put('id',rWrap.Id);
			//sObj.put('Name',rWrap.Name);
			//sObj.put('Email',rWrap.Email);	
			finalRecipients.add(sObj);					
		}	
		return null;
	}
}