@isTest
global class InvoiceUnbilledEstimateResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estimate":{"created_at":1540810353,"invoice_estimates":[{"amount_paid":0,"recurring":true,"taxes":[],"line_items":[{"tax_amount":0,"is_taxed":false,"amount":2000,"quantity":1,"discount_amount":0,"description":"arc plan","date_to":1542448991,"unit_amount":2000,"entity_id":"arc-plan","subscription_id":"2smoc9AHR6ivNafFzK","entity_type":"plan","pricing_model":"flat_fee","tax_exempt_reason":"export","item_level_discount_amount":0,"id":"li_2smoc9AHR6ivNbRFzM","date_from":1539766991,"object":"line_item"}],"line_item_taxes":[],"currency_code":"USD","line_item_discounts":[],"total":2000,"credits_applied":0,"sub_total":2000,"price_type":"tax_exclusive","amount_due":2000,"round_off_amount":0,"object":"invoice_estimate"}],"object":"estimate"}}');
        res.setStatusCode(200);
        return res;
    }
}