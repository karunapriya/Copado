public with sharing class RS_AuthenticateAndRedirectCtrl {
    private String fileId {get; set;}
    public String urlToRedirect {get; private set;}
    public RS_AuthenticateAndRedirectCtrl() {
        System.debug('Start - ');
        fileId = ApexPages.currentPage().getParameters().get('fileId');
    }
    
    public PageReference authenticateAndDownload(){
        this.urlToRedirect = 'https://vishlightningss-dev-ed--c.na78.content.force.com/sfc/servlet.shepherd/version/download/0681N000003IaXW?asPdf=false&operationContext=CHATTER';
        PageReference page = new PageReference(this.urlToRedirect);
        page.setRedirect(true);
        
        return page;
    }
}