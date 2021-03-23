@isTest
global class MockEstSubResponseGenerator implements HttpCalloutMock
{
    public enum ResponseType {SUCCESS, ERROR, MANDATORY_ADDON_FAILURE, SUCCESS_FUTURESUBSCRIPTION,
        SUCCESS_INVNOW_IMMDSUBSCRIPTION,SUCCESS_UNBILLEDCHARGES} 
    ResponseType cbresponse;     
    public MockEstSubResponseGenerator(ResponseType responseType)
    {
        this.cbresponse=responseType;
    }
    
    public MockEstSubResponseGenerator()
    {
        cbresponse=ResponseType.SUCCESS;
    }
    
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        if(cbresponse == ResponseType.SUCCESS){        	        	
        	res.setBody('{"estimate":{"created_at":1527578695,"object":"estimate","subscription_estimate":{"status":"future","next_billing_at":1527665072,"object":"subscription_estimate","currency_code":"USD"},"next_invoice_estimate":{"recurring":true,"price_type":"tax_exclusive","sub_total":1000,"total":0,"credits_applied":0,"amount_paid":0,"amount_due":0,"object":"invoice_estimate","line_items":[{"id":"li_1mkVvolQtQ4X0EDKC","date_from":1527665072,"date_to":1530343472,"unit_amount":1000,"quantity":1,"is_taxed":false,"tax_amount":0,"object":"line_item","amount":1000,"description":"planNT","entity_type":"plan","entity_id":"plannt","tax_exempt_reason":"export","discount_amount":1000,"item_level_discount_amount":0}],"discounts":[{"object":"discount","entity_type":"document_level_coupon","description":"Hoildays are here!","amount":1000,"entity_id":"cbdemo_holiday"}],"taxes":[],"line_item_taxes":[],"currency_code":"USD","line_item_discounts":[{"object":"line_item_discount","line_item_id":"li_1mkVvolQtQ4X0EDKC","discount_type":"document_level_coupon","discount_amount":1000,"coupon_id":"cbdemo_holiday"}]}}}');
        	res.setStatusCode(200);    
        }
		if(cbresponse == ResponseType.SUCCESS_FUTURESUBSCRIPTION)
        {            
            res.setBody(invNowFutureSubResponse);
            res.setStatusCode(200);    
        }
        if(cbresponse == ResponseType.SUCCESS_INVNOW_IMMDSUBSCRIPTION)
        {            
        	res.setBody(invNowImmediateSubscription);
            res.setStatusCode(200);
        }
        if(cbresponse == ResponseType.SUCCESS_UNBILLEDCHARGES)
        {            
        	res.setBody(invNowImmediateSubscription);
            res.setStatusCode(200);
        }
        return res;
    }
    
    private static final String invNowFutureSubResponse='{"estimate": {'+
                '"created_at": 1564544579,"object": "estimate",'+
                 '"subscription_estimate": {'+
                    '"status": "future",'+
                    '"next_billing_at": 1564737120,'+
                    '"object": "subscription_estimate",'+
                    '"currency_code": "USD"'+
                '},'+
                '"next_invoice_estimate": {'+
                    '"recurring": true,'+
                    '"date": 1564737120,'+
                    '"price_type": "tax_exclusive",'+
                    '"sub_total": 37000,'+
                    '"total": 37000,'+
                    '"credits_applied": 0,'+
                    '"amount_paid": 0,'+
                    '"amount_due": 37000,'+
                    '"object": "invoice_estimate",'+
                    '"customer_id": "1t0Aw0TRUsRKCC1kgG",'+
                    '"line_items": ['+
                       ' {'+
                            '"id": "li_1t0AvvYRXllc4M1lZJ",'+
                            '"date_from": 1564737120,'+
                            '"date_to": 1564737120,'+
                            '"unit_amount": 2000,'+
                            '"quantity": 1,'+
                            '"amount": 2000,'+
                            '"pricing_model": "flat_fee",'+
                            '"is_taxed": false,'+
                            '"tax_amount": 0,'+
                            '"object": "line_item",'+
                            '"customer_id": "1t0Aw0TRUsRKCC1kgG",'+
                            '"description": "stairstepplan - Setup Fee",'+
                            '"entity_type": "plan_setup",'+
                            '"entity_id": "stairstepplan",'+
                            '"discount_amount": 0,'+
                            '"item_level_discount_amount": 0'+
                        '},'+
                        '{'+
                            '"id": "li_1t0AvvYRXllc4O1lZK",'+
                            '"date_from": 1564737120,'+
                            '"date_to": 1567415520,'+
                            '"unit_amount": 5000,'+
                            '"quantity": 1,'+
                            '"amount": 5000,'+
                            '"pricing_model": "stairstep",'+
                            '"is_taxed": false,'+
                            '"tax_amount": 0,'+
                            '"object": "line_item",'+
                            '"customer_id": "1t0Aw0TRUsRKCC1kgG",'+
                            '"description": "stairstepplan",'+
                            '"entity_type": "plan",'+
                            '"entity_id": "stairstepplan",'+
                            '"discount_amount": 0,'+
                            '"item_level_discount_amount": 0'+
                        '},'+
                        '{'+
                            '"id": "li_1t0AvvYRXllc4Q1lZL",'+
                            '"date_from": 1564737120,'+
                            '"date_to": 1567415520,'+
                            '"unit_amount": 30000,'+
                            '"quantity": 1,'+
                            '"amount": 30000,'+
                            '"pricing_model": "volume",'+
                            '"is_taxed": false,'+
                            '"tax_amount": 0,'+
                            '"object": "line_item",'+
                            '"customer_id": "1t0Aw0TRUsRKCC1kgG",'+
                            '"description": "volumeAddon",'+
                            '"entity_type": "addon",'+
                            '"entity_id": "volumeaddon",'+
                            '"discount_amount": 0,'+
                     '"item_level_discount_amount": 0'+
                    '    }'+
                   ' ],'+
                  '  "taxes": [],'+
                 '   "line_item_taxes": [],'+
                '    "currency_code": "USD",'+
               '     "round_off_amount": 0,'+
              '      "line_item_discounts": []'+
             '   }'+
            '}}';
    private static  String invNowImmediateSubscription='{"estimate": {'+
    '"created_at": 1564553594,'+
    '"object": "estimate",'+
    '"subscription_estimate": {'+
        '"status": "active",'+
        '"next_billing_at": 1567231994,'+
        '"object": "subscription_estimate",'+
        '"currency_code": "USD"'+
    '},'+
    '"invoice_estimate": {'+
        '"recurring": true,'+
        '"date": 1564553594,'+
        '"price_type": "tax_exclusive",'+
        '"sub_total": 10000,'+
        '"total": 10000,'+
        '"credits_applied": 0,'+
        '"amount_paid": 0,'+
        '"amount_due": 10000,'+
        '"object": "invoice_estimate",'+
        '"customer_id": "1t0Aw0TRUsRKCC1kgG",'+
        '"line_items": [{'+
            '"id": "li_1t0AvvYRXmNRJO1y8P",'+
            '"date_from": 1564553594,'+
            '"date_to": 1567231994,'+
            '"unit_amount": 10000,'+
            '"quantity": 1,'+
            '"amount": 10000,'+
            '"pricing_model": "per_unit",'+
            '"is_taxed": false,'+
            '"tax_amount": 0,'+
            '"object": "line_item",'+
            '"customer_id": "1t0Aw0TRUsRKCC1kgG",'+
            '"description": "perunitplan",'+
            '"entity_type": "plan",'+
            '"entity_id": "perunitplan",'+
            '"discount_amount": 0,'+
            '"item_level_discount_amount": 0'+
        '}],'+
        '"taxes": [],'+
        '"line_item_taxes": [],'+
        '"currency_code": "USD",'+
        '"round_off_amount": 0,'+
        '"line_item_discounts": []'+
    '}'+
'}}';
}