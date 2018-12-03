public class RS_Integrations {

    public pagereference invokeS3(){
        HttpRequest req = new HttpRequest();
        req.setHeader('content-type','application/octet-stream');
        req.setMethod('GET');
        
        req.setEndpoint('https://sbx.dev.ssi-cloud.com/upload/dell/PresignedUrl');
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        responseStr  = res.getbody();
      return null;
    }
   
    public PageReference invokeQuoteService() {
    
        HttpRequest req = new HttpRequest();
        req.setHeader('content-type','application/json');
        req.setMethod('POST');
        req.setHeader('Accept','*/*');
        
        req.setEndpoint('callout:RS_Echo'+'/odata/frb1/dell/opportunity/dell.QuoteImport');
                
        req.setBody('{"oppId":"foo","lineItemsAttachment":"fubar","dateFormat":"YYYY/MM/DD","numberFormat":"###,###.##","currency":"usd"}' );
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        responseStr  = res.getbody();
        return null;
        
    }


    Public Blob fileBody {get;set;}
 Public String fileName {get;set;}
 
 Public String responseStr {get;set;}
 
 
 public void invokeService(){
     uploadFile(fileName,'https://sbx.dev.ssi-cloud.com/upload/dell/Fubar');
 }
 
    public void uploadFile( String file_name, String reqEndPoint){
               system.debug('bodyEncoded 1  : '+system.limits.getheapsize()); 
              String boundary = '----------------------------741e90d31eff';
              String header = '--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="'+file_name+'"\r\nContent-Type: application/octet-stream'; // added '\r's removed ';' see Tim Smith's comment
              String footer = '\r\n--'+boundary+'--';              
              String bodyEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
              while(bodyEncoded.endsWith('='))
              {
               header+=' ';
               bodyEncoded  += EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
              }
              system.debug('bodyEncoded 2  : '+system.limits.getheapsize());
              //String bodyEncoded = EncodingUtil.base64Encode(file_body);
              bodyEncoded += EncodingUtil.base64Encode(fileBody);
              system.debug('bodyEncoded 3 : '+system.limits.getheapsize());
              bodyEncoded  =bodyEncoded + EncodingUtil.base64Encode(Blob.valueOf(footer));
    system.debug('bodyEncoded 4 : '+system.limits.getheapsize());
              Blob bodyBlob = null;
              String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
              /*if(last4Bytes.endsWith('='))
              {
                   Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
                   HttpRequest tmp = new HttpRequest();
                   tmp.setBodyAsBlob(decoded4Bytes);
                   String last4BytesFooter = tmp.getBody()+footer;   
                   bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
              }
              else
              {*/
                    //fileBody = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
                    system.debug('bodyEncoded 5 : '+system.limits.getheapsize());
                    //uploadFileinFuture(bodyEncoded);
                    fileBody = EncodingUtil.base64Decode(bodyEncoded);
              //}
              //Attachment att = [select Id, body, name from attachment where parentId = '0061N00000XLUW5'];
             HttpRequest req = new HttpRequest();
              req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
              req.setMethod('POST');
              req.setEndpoint(reqEndPoint);
              req.setBodyAsBlob(fileBody);
              req.setTimeout(120000);
    
              Http http = new Http();
              HTTPResponse res = http.send(req);
    
               responseStr  = res.getbody();
    }
    
    @future(callout=true)   
    private static void uploadFileinFuture(String fileEncoded) {
    system.debug('bodyEncoded 6 : '+system.limits.getheapsize());
    blob fileBody2 = EncodingUtil.base64Decode(fileEncoded);
    String boundary2 = '----------------------------741e90d31eff';
    HttpRequest req = new HttpRequest();
              req.setHeader('Content-Type','multipart/form-data; boundary='+boundary2 );
              req.setMethod('POST');
              req.setEndpoint('https://sbx.dev.ssi-cloud.com/upload/dell/Fubar');
              req.setBodyAsBlob(fileBody2);
              req.setTimeout(120000);
    
              Http http = new Http();
              HTTPResponse res = http.send(req);
    
               String responseStr  = res.getbody();
               system.debug('RES:::: '+responseStr );
               }


}