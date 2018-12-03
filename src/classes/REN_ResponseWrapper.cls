public class REN_ResponseWrapper { 

    public String envelopeId;
    public String uri; 
    public String statusDateTime; 
    public String status;
    public String url;

    public static REN_ResponseWrapper parse(String json) { 
        return (REN_ResponseWrapper ) System.JSON.deserialize(json, REN_ResponseWrapper.class); 
    } 

}