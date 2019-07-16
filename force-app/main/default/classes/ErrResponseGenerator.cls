@isTest
global class ErrResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"error_msg":"fdgsfdhgfgjhk gdhfgjh"}');
        res.setStatusCode(200);
        return res;
    }


}