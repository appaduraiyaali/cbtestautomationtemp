@isTest
global class MockUnbilledChargesResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estimate":{"unbilled_charge_estimates":[{"voided_at":1524907800,"amount":6567,"quantity":1,"discount_amount":0,"description":"planNT - Prorated Charges","date_to":1607769000,"unit_amount":6567,"entity_id":"plannt","currency_code":"USD","subscription_id":"1mk51THQYVlDpE3QoT","deleted":false,"entity_type":"plan","is_voided":true,"id":"li_2smoc9CCQozfPAxB4w","date_from":1590746400,"object":"unbilled_charge"}],"created_at":1524662112,"credit_note_estimates":[{"taxes":[],"line_items":[{"tax_amount":0,"is_taxed":false,"amount":10534,"quantity":1,"discount_amount":0,"description":"planNT - Prorated Credits for 28-Apr-2018 - 10-Mar-2019","date_to":1552212000,"unit_amount":10534,"entity_id":"plannt","subscription_id":"1mk51THQYVlDpE3QoT","entity_type":"plan","tax_exempt_reason":"export","item_level_discount_amount":0,"id":"li_Hr551BVQqEgqQCOyl","date_from":1524907800,"object":"line_item"}],"type":"adjustment","amount_allocated":10534,"line_item_taxes":[],"currency_code":"USD","line_item_discounts":[],"total":10534,"reference_invoice_id":"317","amount_available":0,"sub_total":10534,"price_type":"tax_exclusive","object":"credit_note_estimate"},{"taxes":[],"line_items":[{"tax_amount":0,"is_taxed":false,"amount":10904,"quantity":1,"discount_amount":0,"description":"planNT - Prorated Credits for 10-Mar-2019 - 29-May-2020","date_to":1590746400,"unit_amount":10904,"entity_id":"plannt","subscription_id":"1mk51THQYVlDpE3QoT","entity_type":"plan","tax_exempt_reason":"export","item_level_discount_amount":0,"id":"li_Hr551BVQqEgqQZOyn","date_from":1552212000,"object":"line_item"}],"type":"adjustment","amount_allocated":10904,"line_item_taxes":[],"currency_code":"USD","line_item_discounts":[],"total":10904,"reference_invoice_id":"318","amount_available":0,"sub_total":10904,"price_type":"tax_exclusive","object":"credit_note_estimate"}],"subscription_estimate":{"next_billing_at":1524907800,"id":"1mk51THQYVlDpE3QoT","currency_code":"USD","status":"active","object":"subscription_estimate"},"object":"estimate"}}');
        res.setStatusCode(200);
        return res;
    }


}