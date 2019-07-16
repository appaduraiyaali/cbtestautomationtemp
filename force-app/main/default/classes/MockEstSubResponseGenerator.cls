@isTest
global class MockEstSubResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estimate":{"created_at":1527578695,"object":"estimate","subscription_estimate":{"status":"future","next_billing_at":1527665072,"object":"subscription_estimate","currency_code":"USD"},"next_invoice_estimate":{"recurring":true,"price_type":"tax_exclusive","sub_total":1000,"total":0,"credits_applied":0,"amount_paid":0,"amount_due":0,"object":"invoice_estimate","line_items":[{"id":"li_1mkVvolQtQ4X0EDKC","date_from":1527665072,"date_to":1530343472,"unit_amount":1000,"quantity":1,"is_taxed":false,"tax_amount":0,"object":"line_item","amount":1000,"description":"planNT","entity_type":"plan","entity_id":"plannt","tax_exempt_reason":"export","discount_amount":1000,"item_level_discount_amount":0}],"discounts":[{"object":"discount","entity_type":"document_level_coupon","description":"Hoildays are here!","amount":1000,"entity_id":"cbdemo_holiday"}],"taxes":[],"line_item_taxes":[],"currency_code":"USD","line_item_discounts":[{"object":"line_item_discount","line_item_id":"li_1mkVvolQtQ4X0EDKC","discount_type":"document_level_coupon","discount_amount":1000,"coupon_id":"cbdemo_holiday"}]}}}');
        res.setStatusCode(200);
        return res;
    }


}