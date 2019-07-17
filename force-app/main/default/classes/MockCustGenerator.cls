@isTest
global class MockCustGenerator implements HttpCalloutMock
{
    public static final String SYNC_NEW_CUSTOMER='SyncNew';
    public static final String SYNC_EXISTING_CUSTOMER='SyncExisting';
    public static final String APIERROR='APIError';
    
    string setContext;
    public  MockCustGenerator(string setContext)
    {
      this.setContext = setContext;
        
    }   
    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type','application/json');
        if(setContext == SYNC_NEW_CUSTOMER)
        {
            res.setBody('{"customer": {"id": "1n6BPujRUOG1LeV2R","first_name": "con1","last_name": "test1","email": "con1test1@gmail.com","auto_collection": "on","net_term_days": 0,"allow_direct_debit": false,"created_at": 1561448796,"taxability": "taxable","updated_at": 1561448796,"pii_cleared": "active","resource_version": 1561448796242,"deleted": false,"object": "customer","card_status": "no_card","promotional_credits": 0,"refundable_credits": 0,"excess_payments": 0,"unbilled_charges": 0,"preferred_currency_code": "USD"}}');
        	res.setStatusCode(200);
        }
        else if(setContext == SYNC_EXISTING_CUSTOMER)
        {
            res.setBody('{"customer": {"id": "1t0Aw4lRUsqQiYsg","first_name": "con2","last_name": "test2","email": "con2test2@gmail.com","auto_collection": "on","net_term_days": 0,"allow_direct_debit": false,"created_at": 1561448796,"taxability": "taxable","updated_at": 1561448796,"pii_cleared": "active","resource_version": 1561448796242,"deleted": false,"object": "customer","card_status": "no_card","promotional_credits": 0,"refundable_credits": 0,"excess_payments": 0,"unbilled_charges": 0,"preferred_currency_code": "USD"}}');
        	res.setStatusCode(200);
        }
        else if(setContext == APIERROR)
        {
            res.setBody('{"message":"1n6BPujRUOG1LeV2R not found","type":"invalid_request","api_error_code":"resource_not_found","error_code":"resource_not_found","error_msg":"1n6BPujRUOG1LeV2R not found","http_status_code":404}');
        	res.setStatusCode(404);
        }
        return res;
    }
   
}