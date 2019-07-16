@isTest
global class MockSubGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estimate": {"created_at": 1546671010,"object": "estimate","subscription_estimate": {"status": "active","next_billing_at": 1549349410,"object": "subscription_estimate", "currency_code": "USD"},"invoice_estimate": { "recurring": true,"date": 1546671010, "price_type": "tax_exclusive","sub_total": 14000,"total": 14000,"credits_applied": 0,"amount_paid": 0,"amount_due": 14000,"object": "invoice_estimate", "line_items": [ { "id": "li_Hr55140REG9w7u16Za","date_from": 1546671010,"date_to": 1546671010,  "unit_amount": 2000,"quantity": 1,"amount": 2000,"pricing_model": "flat_fee", "is_taxed": false,"tax_amount": 0,"object": "line_item","description": "1 month - Setup Fee","entity_type": "plan_setup","entity_id": "cbdemo_tryme", "tax_exempt_reason": "product_exempt", "discount_amount": 0, "item_level_discount_amount": 0},{ "id": "li_Hr55140REG9w7w16Zb","date_from": 1546671010,"date_to": 1549349410, "unit_amount": 12000, "quantity": 1,"amount": 12000,"pricing_model": "flat_fee","is_taxed": false,"tax_amount": 0, "object": "line_item","description": "1 month","entity_type": "plan","entity_id": "cbdemo_tryme","tax_exempt_reason": "product_exempt","discount_amount": 0, "item_level_discount_amount": 0} ],"taxes": [], "line_item_taxes": [],"currency_code": "USD","round_off_amount": 0, "line_item_discounts": [] }}} { "hosted_page": {"id": "HeDTEQCy74cd5Bcd4rUq2iuDqLoYcdDQ5Gcd","type": "checkout_new","url": "https://cbtest1.chargebee.com/pages/v3/HeDTEQCy74cd5Bcd4rUq2iuDqLoYcdDQ5Gcd/","state": "created","embed": true,"created_at": 1546678992,"expires_at": 1546689792, "object": "hosted_page", "updated_at": 1546678992,"resource_version": 1546678992621}}');
        res.setStatusCode(200);
        return res;
    }


}