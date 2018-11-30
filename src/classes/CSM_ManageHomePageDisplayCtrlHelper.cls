/**
 * Created Date		: Sep 26, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Implementation of US2669 (Design a way to specify the order of Focus categories displayed on the home page)
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2757				    Sep 26, 2017	1.1			        Specifiy order for Focus Category to be displayed on Home page
 *
 */
public with sharing class CSM_ManageHomePageDisplayCtrlHelper {
	public static List<CSM_Focus_Category_Display_Order__c> getFocusCategoryOrderList(CSM_FocusCategoryOrderWrapper wrpObj, String userId) {
    	List<CSM_Focus_Category_Display_Order__c> fcViewOrderingList = new List<CSM_Focus_Category_Display_Order__c>();
        System.debug('1');
		String userInfoId = userId;
        if (wrpObj.user!=null) {
			 userInfoId = wrpObj.user.id;
        }
        System.debug('2');
        
    	if(wrpObj !=  null) {
    		Integer fcCount = 1;
    		if(wrpObj.tiles != null && !wrpObj.tiles.isEmpty()){
    			system.debug('1-----\nwrpObj.tiles');
	    		wrpObj.tiles.sort();
	    		system.debug('2-----\nwrpObj.tiles');
    			for(CSM_FocusCategoryOrderWrapper.CSM_FCTilesOrderParams wrp : wrpObj.tiles){
    				if (wrp.visible){
                        CSM_Focus_Category_Display_Order__c fcViewOrderObj = new CSM_Focus_Category_Display_Order__c();
                        fcViewOrderObj.CSM_Focus_Category_View_Id__c = wrp.id;
                        fcViewOrderObj.CSM_User_Id__c = userInfoId;
                        fcViewOrderObj.CSM_Order__c = fcCount;
                        fcViewOrderObj.CSM_Type__c = 'Tile';
                        fcViewOrderingList.add(fcViewOrderObj);
                        fcCount++;
                    }
    			}
    			deleteFocusCategoryOrderList(userInfoId, true);
    		}
    		
    		if(wrpObj.cards != null && !wrpObj.cards.isEmpty()){
    			system.debug('1-----\nwrpObj.cards'+wrpObj.cards);
	    		wrpObj.cards.sort();
	    		system.debug('2-----\nwrpObj.cards'+wrpObj.cards);
	    		fcCount = 1;
    			for(CSM_FocusCategoryOrderWrapper.CSM_FCCardsOrderParams wrp : wrpObj.cards){
    				if (wrp.visible){
                        CSM_Focus_Category_Display_Order__c fcViewOrderObj = new CSM_Focus_Category_Display_Order__c();
                        fcViewOrderObj.CSM_Focus_Category_View_Id__c = wrp.id;
                        fcViewOrderObj.CSM_User_Id__c = userInfoId;
                        fcViewOrderObj.CSM_Order__c = fcCount;
                        fcViewOrderObj.CSM_Type__c = 'Card';
                        fcViewOrderingList.add(fcViewOrderObj);
                        fcCount++;
                    }
    			}
    			deleteFocusCategoryOrderList(userInfoId, false);
    		}
    	}
        return fcViewOrderingList;
    }
    
    public static void deleteFocusCategoryOrderList(Id userId, Boolean isTile) {
    	List<CSM_Focus_Category_Display_Order__c> fcOrderList = CSM_FocusCategoryDisplayOrderDataAccess.getFCDisplayOrderByUser(new Set<Id>{userId}, isTile? 'Tile':'Card');
        if(fcOrderList != null && !fcOrderList.isEmpty()) {
        	CSM_FocusCategoryDisplayOrderDataAccess.deleteFCDisplayOrder(fcOrderList);
        }
    }
    
    public static CSM_FocusCategoryResponseWrapper getFocusCategoryOrderWrapper(List<CSM_Focus_Category_View__c> searchList, List<CSM_Focus_Category_Display_Order__c> displayOrderList) {
    	CSM_FocusCategoryResponseWrapper wrpObj = new CSM_FocusCategoryResponseWrapper();
    	Map<Id, Integer> displayOrderMap = new Map<Id, Integer>();
    	Map<Id, String> displayOrderFCTypeMap = new Map<Id, String>();
        Set<String> fcTypeSet = new Set<String>();
        
        if(displayOrderList != null && !displayOrderList.isEmpty()) {
        	for(CSM_Focus_Category_Display_Order__c orderObj :displayOrderList) {
	    		displayOrderMap.put(orderObj.CSM_Focus_Category_View_Id__c, (Integer)orderObj.CSM_Order__c);
	    		displayOrderFCTypeMap.put(orderObj.CSM_Focus_Category_View_Id__c, orderObj.CSM_Type__c);
	    		fcTypeSet.add(orderObj.CSM_Type__c);
        	}	
        }
    	if(fcTypeSet != null && !fcTypeSet.isEmpty()) {
    		wrpObj.defaultTilesLayout = fcTypeSet.contains('Tile')? false:true;
    		wrpObj.defaultCardsLayout = fcTypeSet.contains('Card')? false:true;
     	}
    	List<CSM_FocusCategoryResponseWrapper.CSM_FCCardsOrderParams> fcCardsWrapper = new List<CSM_FocusCategoryResponseWrapper.CSM_FCCardsOrderParams>();
        List<CSM_FocusCategoryResponseWrapper.CSM_FCTilesOrderParams> fcTilesWrapper = new List<CSM_FocusCategoryResponseWrapper.CSM_FCTilesOrderParams>();
        if((searchList != null && !searchList.isEmpty()) && (displayOrderMap != null && !displayOrderMap.isEmpty())) {
        	for(CSM_Focus_Category_View__c str : searchList) {
        		system.debug('str::::::::::::::::'+str.CSM_Display_Name__c);
        		if(str.CSM_IsTile__c == true) {
        			CSM_FocusCategoryResponseWrapper.CSM_FCTilesOrderParams tileWrp;
		        	if(displayOrderMap.containsKey((String)str.Id)) {
		        		if(displayOrderFCTypeMap.get(str.Id) == 'Tile') {
		        			tileWrp = new CSM_FocusCategoryResponseWrapper.CSM_FCTilesOrderParams();
			        		tileWrp.id = (String)str.Id;
			        		tileWrp.visible = true;
			        		tileWrp.order = displayOrderMap.get((String)str.Id);
			        		tileWrp.name = (String)str.CSM_Display_Name__c;
			        		fcTilesWrapper.add(tileWrp);
		        		} else {
		        			displayOrderMap.remove(str.Id);
		        		}
		        	}
	        	} else {
	        		CSM_FocusCategoryResponseWrapper.CSM_FCCardsOrderParams cardWrp;
		        	if(displayOrderMap.containsKey((String)str.Id)) {
		        		if(displayOrderFCTypeMap.get(str.Id) == 'Card') {
		        			cardWrp = new CSM_FocusCategoryResponseWrapper.CSM_FCCardsOrderParams();
			        		cardWrp.id = (String)str.Id;
			        		cardWrp.visible = true;
			        		cardWrp.order = displayOrderMap.get((String)str.Id);
			        		cardWrp.name = (String)str.CSM_Display_Name__c;
			        		fcCardsWrapper.add(cardWrp);
		        		} else {
		        			displayOrderMap.remove(str.Id);
		        		}
		        	}
	        	}
        	}
        }
        Integer tileCount = fcTilesWrapper.size()+1;
        Integer cardCount = fcCardsWrapper.size()+1;
        
    	for(integer i=0;i<=searchList.size()-1;i++) {
    		if(searchList[i].CSM_IsTile__c == true && !displayOrderMap.containsKey((String)searchList[i].Id)) {
	        	CSM_FocusCategoryResponseWrapper.CSM_FCTilesOrderParams tileWrp = new CSM_FocusCategoryResponseWrapper.CSM_FCTilesOrderParams();
        		tileWrp.id = searchList[i].id;
        		system.debug('searchList[i].CSM_Display_Name__c:::::::::::::::'+searchList[i].CSM_Display_Name__c);
                if (wrpObj.defaultTilesLayout==true){
                    if (tileCount<7){
                    	tileWrp.visible = true;    
                    } else {
                        tileWrp.visible = false;
                    }
                } else {                        
	        		tileWrp.visible = false;
                }
        		tileWrp.order = tileCount;
	        	tileWrp.name = (String)searchList[i].CSM_Display_Name__c;
	        	fcTilesWrapper.add(tileWrp);
	        	tileCount++;
    		} else if(searchList[i].CSM_IsTile__c == false && !displayOrderMap.containsKey((String)searchList[i].Id)) {
        		CSM_FocusCategoryResponseWrapper.CSM_FCCardsOrderParams cardWrp = new CSM_FocusCategoryResponseWrapper.CSM_FCCardsOrderParams();
        		cardWrp.id = searchList[i].id;
        		system.debug('searchList[i].CSM_Display_Name__c:::::::::::::::CARDS:::::::::::'+searchList[i].CSM_Display_Name__c);
                if (wrpObj.defaultCardsLayout==true){
                    if (cardCount<7){
                    	cardWrp.visible = true;    
                    } else {
                        cardWrp.visible = false;
                    }
                } else {                        
	        		cardWrp.visible = false;
                }
        		cardWrp.order = cardCount;
	        	cardWrp.name = (String)searchList[i].CSM_Display_Name__c;
	        	fcCardsWrapper.add(cardWrp);
	        	cardCount++;
    		}
    	}
        wrpObj.tiles = fcTilesWrapper;
        wrpObj.cards = fcCardsWrapper;
        return wrpObj;
    }
}