@isTest
global class MockCheckoutResponse1Generator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"hosted_page":{"id":"7R24UkirlHejZgMgUQt9eahrkOu7ZO5S","type":"checkout_new","url":"https://yourapp.chargebee.com/pages/v2/7R24UkirlHejZgMgUQt9eahrkOu7ZO5S/checkout","state":"created","embed":true,"created_at":1528093752,"expires_at":1528097352,"object":"hosted_page","updated_at":1528093752,"resource_version":1528093752000}}');
        res.setStatusCode(200);
        return res;
    }


}