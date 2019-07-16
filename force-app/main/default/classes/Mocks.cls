@isTest
global with sharing class Mocks {
public Mocks() {

}

public static HttpResponse successResponse(String body) {
	HTTPResponse res = new HTTPResponse();
	res.setHeader('Content-Type','application/json');
	res.setBody(body);
	res.setStatusCode(200);
	return res;
}

global class MockQuoteGenerator implements HttpCalloutMock
{
global HTTPResponse respond(HTTPRequest req)
{
	return Mocks.successResponse('{"quote": { "id": "31", "customer_id": "__dev__1mNJxxZRSof9xJbI", "status": "open", "operation_type": "create_subscription_for_customer", "price_type": "tax_exclusive", "valid_till": 1560941871, "date": 1560077871, "sub_total": 2900, "total": 2900, "credits_applied": 0, "amount_paid": 0, "amount_due": 2900, "updated_at": 1560077871, "resource_version": 1560077871122, "object": "quote", "line_items": [ { "id": "li___dev__1mNJxxZRStTl5ebM", "date_from": 1560077871, "date_to": 1560077871, "unit_amount": 1000, "quantity": 1, "amount": 1000, "pricing_model": "flat_fee", "is_taxed": false, "tax_amount": 0, "object": "line_item", "description": "tiered - Setup Fee", "entity_type": "plan_setup", "entity_id": "tiered", "discount_amount": 0, "item_level_discount_amount": 0 }, { "id": "li___dev__1mNJxxZRStTl5ibN", "date_from": 1560077871, "date_to": 1562669871, "unit_amount": 1000, "quantity": 1, "amount": 1000, "pricing_model": "tiered", "is_taxed": false, "tax_amount": 0, "object": "line_item", "description": "tiered", "entity_type": "plan", "entity_id": "tiered", "discount_amount": 100, "item_level_discount_amount": 100 }, { "id": "li___dev__1mNJxxZRStTl5jbO", "date_from": 1560077871, "date_to": 1562669871, "unit_amount": 1000, "quantity": 1, "amount": 1000, "pricing_model": "stairstep", "is_taxed": false, "tax_amount": 0, "object": "line_item", "description": "stairstep-addon", "entity_type": "addon", "entity_id": "stairstep-addon", "discount_amount": 0, "item_level_discount_amount": 0 } ], "discounts": [{ "object": "discount", "entity_type": "item_level_coupon", "description": "Plan Only Coupon", "amount": 100, "entity_id": "plan_only_coupon" }], "line_item_discounts": [{ "object": "line_item_discount", "line_item_id": "li___dev__1mNJxxZRStTl5ibN", "discount_type": "item_level_coupon", "discount_amount": 100, "coupon_id": "plan_only_coupon" }], "taxes": [], "line_item_taxes": [], "line_item_tiers": [{ "starting_unit": 1, "ending_unit": 10, "quantity_used": 1, "unit_amount": 1000, "object": "line_item_tier", "line_item_id": "li___dev__1mNJxxZRStTl5ibN" }], "currency_code": "USD", "billing_address": { "first_name": "Chargebee", "last_name": "Chargebee", "email": "test@chargebee.com", "company": "Chargebee", "validation_status": "not_validated", "object": "billing_address" } }}');
}
}


global class MockQuoteForUpdateSubscriptionGenerator implements HttpCalloutMock
{
global HTTPResponse respond(HTTPRequest req)
{
	return Mocks.successResponse('{"quote": { "id": "33", "customer_id": "active_direct", "subscription_id": "active_direct", "status": "open", "operation_type": "change_subscription", "price_type": "tax_exclusive", "valid_till": 1560960619, "date": 1560096619, "sub_total": 200, "total": 200, "credits_applied": 0, "amount_paid": 0, "amount_due": 200, "updated_at": 1560096619, "resource_version": 1560096619568, "object": "quote", "line_items": [{ "id": "li___dev__1mNJxxZRSukQQYbY", "date_from": 1560096619, "date_to": 1560096619, "unit_amount": 200, "quantity": 1, "amount": 200, "pricing_model": "per_unit", "is_taxed": false, "tax_amount": 0, "object": "line_item", "subscription_id": "active_direct", "description": "Day Pass", "entity_type": "addon", "entity_id": "day-pass", "discount_amount": 0, "item_level_discount_amount": 0 }], "line_item_discounts": [], "taxes": [], "line_item_taxes": [], "currency_code": "USD", "billing_address": { "first_name": "active_direct", "validation_status": "not_validated", "object": "billing_address" } }}');
}
}

global class MockPlanGenerator implements HttpCalloutMock
{
global HTTPResponse respond(HTTPRequest req)
{
	return Mocks.successResponse('{"plan": { "id": "test-mandatory-recommended", "name": "test mandatory recommended", "price": 0, "period": 1, "period_unit": "month", "pricing_model": "flat_fee", "free_quantity": 0, "status": "active", "enabled_in_hosted_pages": true, "enabled_in_portal": true, "addon_applicability": "restricted", "is_shippable": false, "updated_at": 1560188933, "giftable": false, "resource_version": 1560188933328, "object": "plan", "charge_model": "flat_fee", "taxable": true, "currency_code": "USD", "applicable_addons": [ { "id": "sms-credits", "object": "applicable_addon" }, { "id": "ssl", "object": "applicable_addon" }, { "id": "stairstep-addon", "object": "applicable_addon" } ], "attached_addons": [ { "id": "ssl", "quantity": 1, "type": "mandatory", "object": "attached_addon" }, { "id": "stairstep-addon", "quantity": 10, "type": "recommended", "object": "attached_addon" } ] }}');
}
}

global class MockCouponGenerator implements HttpCalloutMock
{
global HTTPResponse respond(HTTPRequest req)
{
	return Mocks.successResponse('{"coupon": { "id": "cbdemo_fitfreak1", "name": "cbdemo_fitfreak1", "discount_type": "fixed_amount", "discount_amount": 200, "duration_type": "forever", "status": "active", "apply_discount_on": "not_applicable", "apply_on": "each_unit_of_specified_items", "plan_constraint": "all", "addon_constraint": "none", "created_at": 1559296829, "object": "coupon", "redemptions": 1, "currency_code": "USD" }}}');
}
}

global class MockQuoteAcceptanceLinkGenerator implements HttpCalloutMock
{
global HTTPResponse respond(HTTPRequest req)
{
	return Mocks.successResponse('{"hosted_page":{"expires_at":1517658092,"updated_at":1517485292,"created_at":1517485292,"embed":true,"id":"__test__Fmt9uVN9ccuxRA3cufig0OLWdKjTYuGHEF","state":"created","type":"checkout_existing","resource_version":1517485292000,"url":"https://yourapp.chargebee.com/pages/v2/__test__Fmt9uVN9ccuxRA3cufig0OLWdKjTYuGHEF/checkout","object":"hosted_page"}}');
}
}


}
