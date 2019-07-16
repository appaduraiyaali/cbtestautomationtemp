@isTest
global class MockUpdatePaymentGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"hosted_page": { "id": "i4pEPgZcdtfcuVwjcu0LEr37Gl4zcdcpC76d","type": "manage_payment_sources","url": "https://cbtest1.chargebee.com/pages/v3/i4pEPgZcdtfcuVwjcu0LEr37Gl4zcdcpC76d/","state": "created","object": "hosted_page"}}');
        res.setStatusCode(200);
        return res;
    }


}