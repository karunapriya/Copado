/**
 * Created Date		: Dec 6, 2016
 * Developed By		: Nkonkar, Comity Designs, Inc.
 *
 * Function			: This class is used to post message on chatter feed.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nkonkar					User Story				Dec 6, 2016			1.1					@description
 *
 */
public with sharing class REN_ChatterUtil {

	public static boolean isChatterEnabled(){
		Boolean isChatterEnabled = CSM_AccessController.hasObject('FeedItem');
		return isChatterEnabled;
	}

	public  static sObject addChatterMessage(Id objId, String postMsg, String linkURL){
		SObject feedItemObj = CSM_AccessController.newSObject('FeedItem');
		feedItemObj.put('ParentId', objId); 
		feedItemObj.put('Body', postMsg); 
		feedItemObj.put('LinkUrl', linkURL); 
		return feedItemObj;
	}

	public static void saveChatterMessages(List<SObject> feedItemObjList){
		if(feedItemObjList != null && !feedItemObjList.isEmpty()){
	 		insert feedItemObjList;
		}
	}
}