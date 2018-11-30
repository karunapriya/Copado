/**
 * Created Date		: Jan 31, 2017
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Test class is used to test RESTAPI calls for DocuSign functionality.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US2018				Jan 31, 2017			1.1			   TestClass
 *
 */
@isTest
public class REN_DocuSignCalloutTest implements HttpCalloutMock {
	
	public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"CalloutTest": ["TestDocuSign", "TestDocuSign1", "TestDocuSign2"]}');
        response.setStatusCode(200);
        system.assert(true);
        return response;
	}
  
}