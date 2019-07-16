@isTest
global class MockRetNew1ResponseGen implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"subscription":{"billing_period":1,"plan_free_quantity":0,"billing_period_unit":"month","current_term_start":1542180337,"next_billing_at":1544772337,"created_at":1542180338,"plan_amount":11000,"resource_version":1542180339572,"currency_code":"USD","updated_at":1542180339,"auto_collection":"off","id":"B4eOO1R9MFX9r1IXv","base_currency_code":"USD","has_scheduled_changes":false,"due_invoices_count":1,"exchange_rate":1,"plan_quantity":12,"current_term_end":1544772337,"mrr":1057,"plan_unit_price":917,"activated_at":1542180337,"deleted":false,"due_since":1542180338,"total_dues":1057,"started_at":1542180337,"customer_id":"1mkVvlfR83eWh11Lkl","plan_id":"sample_volume","status":"active","object":"subscription"  "addons": [{"id": "stairstep-additional","quantity": 2,"unit_price": 1500,"amount": 3000, "object": "addon"}]}}');
        res.setStatusCode(200);
        return res;
    }


}