@isTest
global class ListUnbilledChargeResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"list":[{"unbilled_charge":{"amount":1000,"quantity":1,"discount_amount":0,"description":"fdsg","date_to":1542195592,"unit_amount":1000,"currency_code":"USD","subscription_id":"cai","deleted":false,"entity_type":"adhoc","pricing_model":"flat_fee","is_voided":false,"id":"li_B3ikfUR9NHXcaAAT","customer_id":"1mk51dxR83hukCXu4","date_from":1542195592,"object":"unbilled_charge"}}]}');
        res.setStatusCode(200);
        return res;
    }
}