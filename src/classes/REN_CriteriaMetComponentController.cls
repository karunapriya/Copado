public with sharing class REN_CriteriaMetComponentController extends REN_BaseChildController {
      
    public String pushType {get; set;}
    private List<SelectOption> pushTypes;
    public Boolean ownerNotify {get; set;}
    public String pushTypeNetNew {get; set;}
    public String pushTypeAll {get; set;}
    private Boolean valueSet = false;
    public REN_Renew_Configuration__c renewConfiguration{get;
    	set{
    		renewConfiguration = value;
    	}
    }
    
	public String objectName {
		get; 
		set {
			System.debug('value - '+value);
			if (value != null){
				objectName = value;
				System.debug('objectName - '+objectName);
				this.objectNameSuper = value;
			}
		}
	}
       
    public REN_CriteriaMetComponentController() {
    	Super();
	}
	
	public List<SelectOption> getPushTypes() {
    	return pushTypes;
	}
		
	public String configurationId {get;
		set {
			if (value != null){
				configurationId = value;
				System.debug('In configurationId - '+configurationId);
			}
		}
	}

	public PageReference pushTypeChanged() {
		
		return null;
	}

	public void save(){
	}
}