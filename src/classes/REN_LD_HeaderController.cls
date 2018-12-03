public class REN_LD_HeaderController {
    /*class FooterLinkCategory {
        String name;
        List<REN_Header_Footer_Links__c> links;
    }*/
    @AuraEnabled
    public static List<REN_Header_Footer_Links__c> getHeaderLinks() {
        return null;//REN_HeaderFooterDataAccess.getLinksBasedOnType('Header');
    }
    
    @AuraEnabled
    public static List<REN_Header_Footer_Links__c> getFooterLinks() {
        return null;//REN_HeaderFooterDataAccess.getLinksBasedOnType('Footer');
    }
    
    @AuraEnabled
    public static String getLogo() {
        //List<Attachment> attList = CHL_AttachmentDataAccess.getAttFrmLowDollorClient();
        return null;//String.valueof(attList[0].Id);
    }
    
     @AuraEnabled
    public static REN_Low_Dollar_Client__c getClientDetails() {
        return null;//REN_LowDollorClientDataAccess.getLowDollarClientDetails()[0];
        
    }
}