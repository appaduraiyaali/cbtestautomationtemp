@isTest
global class ChangeNextRenewalDateGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://cbtest1.chargebee.com/api/v2/subscriptions/1mk51ePQSZ5k7VILl', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"current_term_end":"1522161067"}');
        res.setStatusCode(200);
        return res;
    }
}