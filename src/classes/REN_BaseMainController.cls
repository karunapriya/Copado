public with sharing virtual class REN_BaseMainController {
    // New Changes
    //Vishal's Comment
    private REN_BaseChildController baseChildController;
    private Map<String, REN_BaseChildController> baseChildControllerMap; //new
    private Map<String, Set<REN_BaseChildController>> mappingToControllerMap;
    
    public virtual REN_BaseChildController getBaseChildController() {
        return baseChildController;
    }
    
    public virtual Map<String, Set<REN_BaseChildController>> getMappingToControllerMap() {
        return mappingToControllerMap;
    }

    //new getter for the hashmap
    public virtual Map<String, REN_BaseChildController> getBaseChildControllerMap() {
        return baseChildControllerMap;
    }
    
    //new method for putting value in the hashmap
    public virtual void setBaseChildControllerMap(String key, REN_BaseChildController childController) {
        if (baseChildControllerMap == null) {
            baseChildControllerMap = new Map<String, REN_BaseChildController>();
        }
        baseChildControllerMap.put(key, childController); 
    }
    
    public virtual void setMappingToControllerMap(String key, REN_BaseChildController childController) {
        if (mappingToControllerMap == null) {
            mappingToControllerMap = new Map<String, Set<REN_BaseChildController>>();
        }
        Set<REN_BaseChildController> controllerList = mappingToControllerMap.get(key);
        if(controllerList == null){
            controllerList = new Set<REN_BaseChildController>();
        }
        controllerList.add(childController);
        mappingToControllerMap.put(key, controllerList);
    }

    public virtual void setBaseChildController(REN_BaseChildController childController) {
        baseChildController = childController;
    }
    
    public REN_BaseMainController getThis() {
        return this;
    }
    
        //the new property
    public String objectNameSuper {
        get;
        set {
            if(value != null) {
                objectNameSuper  = value;
            }
        }
    }
  
    public REN_BaseGrandParentController baseGrandParentController { 
        get; 
        set {
            if (value != null) {
                baseGrandParentController = value;
                baseGrandParentController.setBaseMainController(this);
                if(objectNameSuper != null) {
                    baseGrandParentController.setBaseMainControllerMap(objectNameSuper, this);
                }
            }
        }
    }

}