public class RevenueServices {

 Public transient Blob fileBody {get;set;}
 Public String fileName {get;set;}
 
 Public String responseStr {get;set;}
 
 
 public void invokeService(){
     uploadFile(fileBody,fileName,'https://sbx.dev.ssi-cloud.com/upload/dell/Fubar');
 }
 
    public void uploadFile(Blob file_body, String file_name, String reqEndPoint){
    		  system.debug('Limits.getHeapSize1'+Limits.getHeapSize());
              String boundary = '----------------------------741e90d31eff';
              String header = '--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="'+file_name+'"\r\nContent-Type: application/octet-stream'; // added '\r's removed ';' see Tim Smith's comment
              String footer = '\r\n--'+boundary+'--';              
              String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
              while(headerEncoded.endsWith('='))
              {
               header+=' ';
               headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
              }
              String bodyEncoded = EncodingUtil.base64Encode(file_body);
         	  system.debug('Limits.getHeapSize2'+Limits.getHeapSize());
              file_body = null;
              system.debug('Limits.getHeapSize3'+Limits.getHeapSize());
              String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
    
              transient Blob bodyBlob = null;
              String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
              if(last4Bytes.endsWith('='))
              {
                   Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
                   HttpRequest tmp = new HttpRequest();
                   tmp.setBodyAsBlob(decoded4Bytes);
                   String last4BytesFooter = tmp.getBody()+footer;   
                   bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
              }
              else
              {
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
              }
    
              HttpRequest req = new HttpRequest();
              req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
              req.setMethod('POST');
              req.setEndpoint(reqEndPoint);
              req.setBodyAsBlob(bodyBlob);
              req.setTimeout(120000);
    
              Http http = new Http();
              HTTPResponse res = http.send(req);
    
    responseStr  = res.getbody();
    }

}