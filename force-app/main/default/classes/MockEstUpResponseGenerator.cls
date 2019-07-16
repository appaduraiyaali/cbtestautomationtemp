@isTest
global class MockEstUpResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estimate":{"created_at":1546003617,"credit_note_estimates":[],"subscription_estimate":{"next_billing_at":1548659739,"id":"1mbDWfRRDVU9L714AG","currency_code":"USD","status":"active","object":"subscription_estimate"},"next_invoice_estimate":{"date":1548659739,"amount_paid":0,"recurring":true,"taxes":[],"line_items":[{"tax_amount":0,"is_taxed":false,"amount":12000,"quantity":1,"discount_amount":0,"description":"1 month","date_to":1551338139,"unit_amount":12000,"entity_id":"cbdemo_tryme","subscription_id":"1mbDWfRRDVU9L714AG","entity_type":"plan","pricing_model":"flat_fee","tax_exempt_reason":"export","item_level_discount_amount":0,"id":"li_J28UHQrRDWzckUG7J","date_from":1548659739,"object":"line_item"}],"line_item_taxes":[],"currency_code":"USD","line_item_discounts":[],"total":12000,"credits_applied":0,"sub_total":12000,"price_type":"tax_exclusive","amount_due":12000,"round_off_amount":0,"object":"invoice_estimate"},"object":"estimate"}}');
        res.setStatusCode(200);
        return res;
    }


}