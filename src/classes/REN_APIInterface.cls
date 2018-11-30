global with sharing class REN_APIInterface {
	
	@RemoteAction
	global static String lowTouchAPI(String req) {
		System.debug('req - '+req);
		REN_LowTouchRouter router = new REN_LowTouchRouter();
		String jsonStr = router.getPostRequest(req);
		return jsonStr;
	}
    
    
}