global with sharing class REN_APIController {
        
    public REN_APIController() {
        
    }
    
    public REN_APIController(REN_IBExportController controller){
        
    }
    
    @RemoteAction
    global static String gateway(String inputValue){
    	/*string oppReq = '{"status":"SUCCESS","meta":{"definitions":{"opportunity":{"type":"object","title":"opportunity","required":[],"relationships":{"account":{"type":"object","title":"account","required":["name"],"relationships":null,"properties":{"name":{"type":"STRING","title":"Account Name","order":0,"display":true,"dbRequired":true,"apiName":"name"}}}},"properties":{"quote-link":{"type":"url","title":"quote-link","order":0,"display":true,"dbRequired":null,"apiName":null},"amount":{"type":"CURRENCY","title":"Amount","order":1,"display":true,"dbRequired":false,"apiName":"amount"}}}}},"links":null,"included":[{"type":"account","relationships":null,"links":{"self":"/opportunity/006f100000c1an4AAA/relationships/account"},"Id":"001j000000XBiYbAAL","attributes":{"name":"Child2 Account"}}],"flowName":"PO Upload","errors":[],"error":null,"data":[{"type":"opportunity","relationships":{"account":{"links":{"related":"/opportunity/006f100000c1an4AAA/account","self":"/opportunity/006f100000c1an4AAA/relationships/account"},"data":{"Id":"001j000000XBiYbAAL","type":"account"}}},"links":{"self":"/opportunity/006f100000c1an4AAA"},"Id":"006f100000c1an4AAA","attributes":{"quote-link":"068f10000047BuBAAU","amount":"26652.00"}}],"action":"POST"}"';
        REN_LowTouchPayLoad payLoad = (REN_LowTouchPayLoad) JSON.deserialize(oppReq, REN_LowTouchPayLoad.class);
        new REN_LowTouchOpportunitiesService().postResponse('006f100000c1an4AAA', payLoad);
        return oppReq;*/
        String data = '';
        System.debug('inputValue - '+inputValue);
        REN_JSONAPIRouter ltRouter = new REN_JSONAPIRouter();
        data = ltRouter.getPostRequest(inputValue);
        system.debug('data :: '+data);
        return data;
    }
  
}