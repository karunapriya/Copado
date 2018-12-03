public with sharing class CHL_ManagePickListValuesContrl extends REN_BaseChildController{
	public String sourceLabel {get;set;}
	public String destinationLabel {get;set;}
	public List<String> targetSelectedOptions {get;set;}
	public List<String> destinationSelectedOptions {get;set;}
	
	public CHL_MultiSelectListWrapper multiSelectWrp {
		get;
		set {
			if(value != null){
					multiSelectWrp = value;
					this.objectNameSuper = multiSelectWrp.keyClassName ;
					this.baseMainController = multiSelectWrp.baseMainController;
	    			sourceLabel = multiSelectWrp.leftListLable;
	    			destinationLabel = multiSelectWrp.rightListLable;
	  		}
		}
	}

	public void moveLeftToRight() {
		multiSelectWrp.addOptionsInRight(targetSelectedOptions);
	}
	
	public void moveRightToLeft() {
		multiSelectWrp.addOptionsInLeft(destinationSelectedOptions);
	}
	
	public String getAllOptionsFromRight(){
		return multiSelectWrp.getAllOptionsFromRight();
	}
	
	
	public void moveUp() {
		multiSelectWrp.moveOptionUp(destinationSelectedOptions);
	}
	
	public void moveDown() {
		multiSelectWrp.moveOptionDown(destinationSelectedOptions);
	}
}