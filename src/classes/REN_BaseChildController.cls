public with sharing virtual class REN_BaseChildController {
	public REN_BaseChildController(){}
	
	//the new property
	public String objectNameSuper { 
		get;
		set	{
			if(value != null) {
				objectNameSuper  = value;
			}
		}
    }
  
	public REN_BaseMainController baseMainController { 
		get; 
    	set {
			if (value != null) {
				baseMainController = value;
				baseMainController.setBaseChildController(this);
				if(objectNameSuper != null) {
					baseMainController.setBaseChildControllerMap(objectNameSuper, this);
					baseMainController.setMappingToControllerMap(objectNameSuper, this);
				}
			}
		}
	}
}