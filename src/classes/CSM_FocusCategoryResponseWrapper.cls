/**
 * Created Date		: Sep 28, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: US2757 - This wrapper class is used to give Fc records as response
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2757				    Sep 28, 2017			1.1			This wrapper class is used to give Fc records as response
 *
 */
public with sharing class CSM_FocusCategoryResponseWrapper {

	public Boolean defaultCardsLayout {get; set;}
	public Boolean defaultTilesLayout {get; set;}
    public List<CSM_FCTilesOrderParams> tiles {get; set;}
	public List<CSM_FCCardsOrderParams> cards {get; set;}
	
	public CSM_FocusCategoryResponseWrapper() {
		defaultCardsLayout = true;
		defaultTilesLayout = true;
	}	
	public with sharing class CSM_FCTilesOrderParams {
		public String id {get; set;}
	    public String name {get; set;}
	    public Boolean visible {get; set;}
	    public Integer order {get; set;}
	}
	
	public with sharing class CSM_FCCardsOrderParams {
		public String id {get; set;}
	    public String name {get; set;}
	    public Boolean visible {get; set;}
	    public Integer order {get; set;}
	}
}