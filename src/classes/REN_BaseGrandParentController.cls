public with sharing virtual class REN_BaseGrandParentController {
	private REN_BaseMainController baseMainController;
	private Map<String, REN_BaseMainController> baseMainControllerMap; //new
	
	public virtual REN_BaseMainController getBaseMainController() {
		return baseMainController;
	}

	//new getter for the hashmap
	public virtual Map<String, REN_BaseMainController> getBaseMainControllerMap() {
		return baseMainControllerMap;
	}
	
	//new method for putting value in the hashmap
	public virtual void setBaseMainControllerMap(String key, REN_BaseMainController mainController) {
		if (baseMainControllerMap == null) {
      		baseMainControllerMap = new Map<String, REN_BaseMainController>();
		}
		baseMainControllerMap.put(key, mainController); 
	}

	public virtual void setBaseMainController(REN_BaseMainController mainController) {
		baseMainController = mainController;
	}
	
	public REN_BaseGrandParentController getThis() {
    	return this;
	}
}