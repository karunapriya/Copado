public with sharing class CHL_BusinessLayerFactory {    
    
    private static final String GRID_TYPE_OPPORTUNITY = 'CHANNEL_OPPS';
    private static final String GRID_TYPE_REQUESTS = 'CHANNEL_REQUESTS';
    private static final String GRID_TYPE_CONTACTS = 'CHANNEL_CONTACTS';
    private static final String GRID_TYPE_QUOTES = 'CHANNEL_QUOTES';
    private static final String GRID_TYPE_RENEWALS = 'CHANNEL_RENEWALS';
    private static final String GRID_TYPE_ASSETS = 'CHANNEL_ASSETS';
    private static final String GRID_TYPE_SC = 'CHANNEL_CONTRACTS';
    private static final String GRID_TYPE_CASE_ATTACHMENT = 'CHANNEL_REQUEST_ATTACHMENTS';
    private static final String GRID_TYPE_ACCOUNT = 'CHANNEL_ACCOUNTS';
    
    private CHL_GridInputWrapper inputWrapper;
    
    public CHL_BusinessLayerFactory(CHL_GridInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;
    }
    
    public CHL_AngularResponeWrapper constructGridResponseList()    {
        CHL_AngularResponeWrapper responseWrp = new CHL_AngularResponeWrapper();
        if(String.isNotBlank(this.inputWrapper.gridType) || String.isNotBlank(this.inputWrapper.ot))   {
            if (GRID_TYPE_OPPORTUNITY.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'OP') { //To call Partner Opportunity Grid
                CHL_PartnerOpportunityBusinessLayer businessLayer = new CHL_PartnerOpportunityBusinessLayer(this.inputWrapper);
                responseWrp = businessLayer.constructGridWrapper();
            } else if(GRID_TYPE_REQUESTS.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'RQ') {  //To call Requests Grid
                CHL_SalesRequestBusinessLayer businessLayer = new CHL_SalesRequestBusinessLayer(this.inputWrapper);
                responseWrp = businessLayer.constructGridWrapper();
            } else if(GRID_TYPE_CONTACTS.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'CN') {  //To call Contacts Grid
                CHL_ContactBusinessLayer contactBusinesLayerObj = new CHL_ContactBusinessLayer(this.inputWrapper);
                responseWrp = contactBusinesLayerObj.constructGridWrapper();
            } else if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && (GRID_TYPE_QUOTES.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'QU')) {  //To call Quotes Grid
                CHL_QuoteBusinessLayer quoteBusinesLayerObj = new CHL_QuoteBusinessLayer(this.inputWrapper);
                responseWrp = quoteBusinesLayerObj.constructGridWrapper();
            } else if(GRID_TYPE_RENEWALS.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'LI') {  //To call Renewals Grid
                CHL_RenRelationshipBusinessLayer rrBusinesLayerObj = new CHL_RenRelationshipBusinessLayer(this.inputWrapper);
                responseWrp = rrBusinesLayerObj.constructGridWrapper();
            } else if(GRID_TYPE_ASSETS.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'AS') {  //To call Assets Grid
                CHL_AssetBusinessLayer assetBusinesLayerObj = new CHL_AssetBusinessLayer(this.inputWrapper);
                responseWrp = assetBusinesLayerObj.constructAssetGrid();
            } else if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT) && (GRID_TYPE_SC.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'CT')){ // To check entitlement for SC
                   //To call Contract line Item Grid
                    CHL_ContractLineItemBusinessLayer scBusinesLayerObj = new CHL_ContractLineItemBusinessLayer(this.inputWrapper);
                    responseWrp = scBusinesLayerObj.constructGridWrapper();
            } else if(GRID_TYPE_CASE_ATTACHMENT.equalsIgnoreCase(this.inputWrapper.gridType)) {  //To call case attachment Grid
                CHL_AttachmentBusinessLayer attachmentBusinesLayerObj = new CHL_AttachmentBusinessLayer(this.inputWrapper);
                responseWrp = attachmentBusinesLayerObj.constructGridWrapper();
            } else if(GRID_TYPE_ACCOUNT.equalsIgnoreCase(this.inputWrapper.gridType) || this.inputWrapper.ot == 'AC') {  //To call Requests Grid
                CHL_AccountBusinessLayer businessLayer = new CHL_AccountBusinessLayer(this.inputWrapper);
                responseWrp = businessLayer.constructGridWrapper();
            }
        }
        return responseWrp;
    }

}