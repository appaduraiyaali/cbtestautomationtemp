@isTest
global class MockInvoiceNoteResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        String resp='{"estimate": {"created_at": 1523262900,"object": "estimate","subscription_estimate": {"id": "2smoc98gQflrah01BN5","status": "active","next_billing_at": 1529755200,"object": "subscription_estimate","currency_code": "USD"},"invoice_estimate": {"recurring": true,"price_type": "tax_exclusive","sub_total": 46501,"total": 46501,"credits_applied": 0,"amount_paid": 0,"amount_due": 46501,"object": "invoice_estimate","line_items": [{"id": "li_2smoc96OQohztT8EgX","date_from": 1525599000,"date_to": 1529755200,"unit_amount": 46501,"quantity": 1,"is_taxed": false,"tax_amount": 0,"object": "line_item","subscription_id": "2smoc98gQflrah01BN5","amount": 46501,"description": "Ronaldo - Prorated Charges","entity_type": "plan","entity_id": "ronaldo","discount_amount": 0,"item_level_discount_amount": 0}],"taxes": [],"line_item_taxes": [],"currency_code": "USD","line_item_discounts": []},"credit_note_estimates": []}}';
        res.setBody(resp);
        res.setStatusCode(200);
        return res;
    }


}