public class CreateQuoteForUpdateSubUrlBuilder extends UrlBuilder{

    private static final String amp='&';
    
    public CreateQuoteForUpdateSubUrlBuilder(EndPoint ep){
        super(ep);
    }
    
    public CreateQuoteForUpdateSubUrlBuilder subscriptionId(String s) {
        addEncode('subscription[id]',s);
        return this;
    }

    private void addEncode(String key, String value) {
        value=EncodingUtil.urlEncode(value,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+=key+'='+value;
    }

    private void add(String key, String value) {
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+=key+'='+value;
    }

    public CreateQuoteForUpdateSubUrlBuilder planId(String s){
        addEncode('subscription[plan_id]',s);
        return this;
    }
    
    public CreateQuoteForUpdateSubUrlBuilder planQuan(String s){
        add('subscription[plan_quantity]',s);
        return this;
    }
    
    public CreateQuoteForUpdateSubUrlBuilder planUnitPrice(String s){
        add('subscription[plan_unit_price]',s);
        return this;
    }
    
    public CreateQuoteForUpdateSubUrlBuilder billingCycles(String s){
        add('billing_cycles',s);
        return this;
    }
    
    public CreateQuoteForUpdateSubUrlBuilder couponId(String s){
        addEncode('coupon_ids[0]',s);
        return this;
    }
    
    public CreateQuoteForUpdateSubUrlBuilder replaceAddons(String s){
        add('replace_addon_list',checkBoolean(s));
        return this;
    }
    
    private String checkBoolean(String s){
        if(s!=null){
            List<String> boolVals=new List<String>();
            boolVals.add('true');
            boolVals.add('false');
            if(boolVals.contains(s.toLowerCase())){
                return s.toLowerCase();
            }
            else
                return null;
        }
        return null;
            
    }
    
    

}