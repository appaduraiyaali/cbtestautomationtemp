@isTest
global class MockCreditNoteResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estimate": {"subscription_estimate": {"currency_code": "USD"},"credit_note_estimates": [{ "type": "adjustment","total": 12000,"line_items": [{ "unit_amount": 12000,"quantity": 1, "amount": 12000,"description": "1 month - Prorated Credits for 06-Apr-2018 - 06-May-2018" }], "currency_code": "USD"}]}}');
        res.setStatusCode(200);
        return res;
    }


}