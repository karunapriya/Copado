/**
 * Created Date		: Feb 17, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					User Story				Feb 17, 2017			1.1					@description
 * 
 */
public with sharing class CSM_MultiSelectLeftRightPicklistCmpCtrl  extends REN_BaseChildController{
	public String sourceLabel {get;set;}
	public String destinationLabel {get;set;}
	public String targetSelectedOptions {get;set;}
	public String destinationSelectedOptions {get;set;}
	
	public CSM_MultiSelectLeftRightListWrapper multiSelectWrp {
		get;
		set {
			if(value != null){
					multiSelectWrp = value;
					system.debug('MMMMMMMMMMM - ' + multiSelectWrp);
	    			sourceLabel = multiSelectWrp.leftListLabel;
	    			destinationLabel = multiSelectWrp.rightListLabel;
					this.objectNameSuper = multiSelectWrp.prefix + 'CSM_Focus_Category_View__c';	    			
					this.baseMainController = 	multiSelectWrp.baseMainController;	    			
	  		}
		}
	}

    public CSM_MultiSelectLeftRightPicklistCmpCtrl() {
	    super();
		// TODO Auto-generated constructor stub
		
	}

    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(this.multiSelectWrp.leftOptionList, value);
        }
    }

    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(this.multiSelectWrp.rightOptionList, value);
        }
    }
}