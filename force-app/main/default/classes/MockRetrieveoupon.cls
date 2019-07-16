@isTest
global class MockRetrieveoupon implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"coupon":{"addon_constraint": "not_applicable","apply_discount_on": "not_applicable","apply_on": "invoice_amount","created_at": 1517507479,"currency_code": "USD","discount_amount": 500,"discount_type": "fixed_amount","duration_type": "forever","id": "cbdemo_fitfreak","name": "Sample Offer","object": "coupon","plan_constraint": "not_applicable","redemptions": 0,"resource_version": 1517507479000,"status": "active","updated_at": 1517507479}}');
        res.setStatusCode(200);
        return res;
    }

}