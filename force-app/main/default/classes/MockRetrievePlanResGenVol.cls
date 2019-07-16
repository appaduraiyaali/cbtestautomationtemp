@isTest
global class MockRetrievePlanResGenVol implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"plan": {"addon_applicability": "restricted","charge_model": "per_unit","currency_code": "USD","enabled_in_hosted_pages": true,"enabled_in_portal": true,"free_quantity": 0,"giftable": false,"id": "Testplan2","is_shippable": false,"name": "Testplan","object": "plan","period": 1,"period_unit": "month","price": 0,"pricing_model": "per_unit","status": "active","taxable": true, "applicable_addons": [{"id": "TestAddon6","object": "applicable_addon"}],"attached_addons": [{"id": "TestAddon6", "quantity": 1,"type": "mandatory","object": "attached_addon"}]}}');
        res.setStatusCode(200);
        return res;
    }

}