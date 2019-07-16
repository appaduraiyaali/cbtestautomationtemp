public class EndPointsIndex{
    
    public static final EndPoint update_est_url= new EndPoint('/api/v2/estimates/update_subscription', RequestType.POST);
    public static final EndPoint update_sub_url= new EndPoint('/api/v2/subscriptions/?', RequestType.POST);
    public static final EndPoint retrieve_sub_url = new EndPoint('/api/v2/subscriptions/?',RequestType.GET);
    public static final EndPoint cart_est_url= new EndPoint('/api/v2/subscriptions/?/cart_sub_update', RequestType.POST);
    public static final EndPoint create_sub_est_url= new EndPoint('/api/v2/customers/?/create_subscription_estimate',RequestType.GET);
    public static final EndPoint create_sub_url= new EndPoint('/api/v2/customers/?/subscriptions',RequestType.POST);
    public static final EndPoint checkout_new_url = new EndPoint('/api/v2/hosted_pages/checkout_new',RequestType.POST);
    public static final EndPoint add_charge_inv_now = new EndPoint('/api/v2/invoices/charge',RequestType.POST);
    public static final EndPoint add_charge_unbilled = new EndPoint('/api/v2/subscriptions/?/add_charge_at_term_end',RequestType.POST);
    public static final EndPoint get_plan_details = new EndPoint('/api/v2/plans/?',RequestType.GET);
    public static final EndPoint get_coupon_details = new EndPoint('/api/v2/coupons/?',RequestType.GET);
    
    public static final EndPoint get_quote_pdf = new EndPoint('/api/v2/quotes/?/pdf',RequestType.POST);
    public static final EndPoint create_subscription_quote= new EndPoint('/api/v2/customers/?/create_subscription_quote',RequestType.POST);
    public static final EndPoint update_subscription_quote= new EndPoint('/api/v2/quotes/update_subscription_quote',RequestType.POST);
    public static final EndPoint update_status_quote = new EndPoint('/api/v2/quotes/?/update_status',RequestType.POST);
    public static final EndPoint accept_quote = new EndPoint('/api/v2/hosted_pages/accept_quote',RequestType.POST);
    public static final EndPoint convert_quote = new EndPoint('/api/v2/quotes/?/convert',RequestType.POST);
    
}