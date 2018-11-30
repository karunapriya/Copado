public with sharing class REN_OpportunityLineItemListController {

	public List<REN_OpptLineWrapper> opliWrapperList{get;set;}
	public Integer numberOfRowToRemove {get;set;}
	public REN_OpportunityLineItemListController(){}
	
	// The method to remove an item from the list
    public PageReference removeOpli(){
       this.opliWrapperList.remove(this.numberOfRowToRemove);  
       this.updateCustomId();
       return null;
    }
    
    private void updateCustomId(){
    	for(Integer i=0; i<this.opliWrapperList.size(); i++){
    		REN_OpptLineWrapper wrapper = this.opliWrapperList.get(i);
    		wrapper.customId = i;
    	}
    }
}