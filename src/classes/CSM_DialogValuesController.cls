global with sharing class CSM_DialogValuesController {
    public CSM_DialogValuesController(object controller){
    }

    public CSM_DialogValuesController() {
    }

    @RemoteAction
    global static Object getResponseForDialogBoxValues(String req) {
        System.debug('req - ' + req);
        CSM_DialogInputParams inputJsonWrapper = (CSM_DialogInputParams)JSON.deserialize(req, CSM_DialogInputParams.class);
        CSM_DialogBoxBusinessLayer db = new CSM_DialogBoxBusinessLayer(inputJsonWrapper);
        List<Map<String, String>> grw = db.retrieveObjectWrapperList();
        system.debug('grw -- > '+JSON.serialize(grw));
        //CSM_GridResponseWrapper tasks = new CSM_GridResponseWrapper();
        return JSON.serialize(grw);
    }
}