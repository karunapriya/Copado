/**
 * Created Date		: Sep 15, 2017
 * Developed By		: admin, Comity Designs, Inc.
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
 * admin					User Story				Sep 15, 2017			1.1					@description
 *
 */
public with sharing class CSM_FocusCategoryOrderWrapper {
	
	public CSM_FCUserWrapper user {get; set;}
	public Boolean defaultCardsLayout {get; set;}
	public Boolean defaultTilesLayout {get; set;}
	public List<CSM_FCTilesOrderParams> tiles {get; set;}
	public List<CSM_FCCardsOrderParams> cards {get; set;}
	
    public CSM_FocusCategoryOrderWrapper(){
        defaultCardsLayout = true;
        defaultTilesLayout = true;
    }        

	public with sharing class CSM_FCTilesOrderParams implements Comparable {
		public String id {get; set;}
	    public String name {get; set;}
	    public Boolean visible {get; set;}
	    public Integer order {get; set;}
	    
	    public Integer compareTo(Object compareTo) {
	    	Integer returnValue = 0;
	    	CSM_FCTilesOrderParams compareToFcTiles = (CSM_FCTilesOrderParams)compareTo;
	    	if(this.order < compareToFcTiles.order) {
	    		returnValue = -1;
	    	}
	    	if(this.order > compareToFcTiles.order) {
	    		returnValue = 1;
	    	}
	    	return returnValue;
	    }
	}
	
	public with sharing class CSM_FCCardsOrderParams implements Comparable {
		public String id {get; set;}
	    public String name {get; set;}
	    public Boolean visible {get; set;}
	    public Integer order {get; set;}
	    
	    public Integer compareTo(Object compareTo) {
	    	Integer returnValue = 0;
	    	CSM_FCCardsOrderParams compareToFcCards = (CSM_FCCardsOrderParams)compareTo;
	    	if(this.order < compareToFcCards.order) {
	    		returnValue = -1;
	    	}
	    	if(this.order > compareToFcCards.order) {
	    		returnValue = 1;
	    	}
	    	return returnValue;
	    }
	}
	
	public with sharing class CSM_FCUserWrapper {
		public String id {get; set;}
    	public String name {get; set;}
	}
}