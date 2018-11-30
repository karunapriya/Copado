/**
 * Created Date		: Feb 20, 2017
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: This class act as controller for displaying FC as Cards and Tiles.
 * Support Email 	: Nidhi@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US2118				Feb 20, 2017		1.1					@description
 * 
 */
public with sharing class CSM_FCTilesDisplayCompCntrl {
	
	
	public List<CSM_FocusCategoryColumnWrapper> tilesOrderedList {get; private set;}
	private  final Integer RECORD_LIMIT = 6;
	
	public CSM_FCTilesDisplayCompCntrl(){
		getFCWrapperList();
	}
	
	/**
    * @description : This method gets the list of FCWrapper which have type = Tiles. At Max need to return 6 Object of FCWrapper.
    */
	public void getFCWrapperList(){
		List<CSM_FocusCategoryWrapper> FCWrapperList;
		FCWrapperList = CSM_FocusCategoryViewDataAccess.populateFCWrapperClass(true,RECORD_LIMIT);
		List<CSM_FocusCategoryWrapper> FCWrapperListForCards = CSM_FocusCategoryViewDataAccess.populateFCWrapperClass(false,RECORD_LIMIT);
		if((FCWrapperList == null || FCWrapperList.isEmpty()) && (FCWrapperListForCards == null || FCWrapperListForCards.isEmpty())) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,Label.CSM_LBL_NO_FC_ASSIGNED)); 
		}
		if(FCWrapperList != null){
			system.debug('\n\n FCWrapperList1 :: ' + FCWrapperList);
			getFCColumnWrapperList(FCWrapperList);
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.CSM_LBL_NO_FC_FOUND));
		}
	}

    /**
    * @description : This method creates the list of FCColWrapper and set the attribute values from FCWrapper List. FCCOlWrapper List is used for displaying the FC as Tiles.
    */
	public void getFCColumnWrapperList(List<CSM_FocusCategoryWrapper> fcWrapperList){
		tilesOrderedList = new List<CSM_FocusCategoryColumnWrapper>();
        if(!fcWrapperList.isEmpty()){
			for(CSM_FocusCategoryWrapper fcatWrapperObj: fcWrapperList){
				CSM_FocusCategoryColumnWrapper fcColWrapperObj = new CSM_FocusCategoryColumnWrapper();
				fcColWrapperObj.GroupId = fcatWrapperObj.CategoryViewId;
				fcColWrapperObj.ColumnCategoryCount = 2;
				fcColWrapperObj.ActiveCategoryList = new List<CSM_FocusCategoryWrapper>{fcatWrapperObj};
				fcColWrapperObj.ColumnActive = true;
				fcColWrapperObj.ColumnOrder = '1';
				tilesOrderedList.add(fcColWrapperObj);
			} 
        }

	}

}