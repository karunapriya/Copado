global with sharing class CSM_CustomGridController {
	
	@RemoteAction
	global static CSM_GridResponseWrapper getResponseForGrid(String req) {
		System.debug('req - '+req);
		CSM_CustomGridInputWrapper inputJsonWrapper = (CSM_CustomGridInputWrapper)JSON.deserialize(req, CSM_CustomGridInputWrapper.class);
		CSM_BusinessLayerFactory blFactory = new CSM_BusinessLayerFactory(inputJsonWrapper);
		CSM_GridResponseWrapper tasks = blFactory.retrieveSObjectWrapperList();
		//CSM_GridResponseWrapper tasks = new CSM_GridResponseWrapper();
		return tasks;
	}
	
	public static String getLanguage(){
        return UserInfo.getLanguage();
    }
}