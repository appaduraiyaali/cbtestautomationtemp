public class UpdateSubEstUrlBuilder extends URLBuilder{
    
    private static final String amp='&';
    
    public UpdateSubEstUrlBuilder(){
        super();
    }
    
    public UpdateSubEstUrlBuilder(EndPoint ep){
        super(ep);
    }
    
    
    public UpdateSubEstUrlBuilder Id(String s){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[id]='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder planId(String s){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_id]='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder planQuan(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='plan_quantity='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder planUnitPrice(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='plan_unit_price='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder planSetupFee(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[setup_fee]='+s;
        return this;
    }
    
    
    
    public UpdateSubEstUrlBuilder billingCycles(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='billing_cycles='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder poNum(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='po_number='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder couponId(String s){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='coupon_ids[0]='+s;
        return this;
    }
    
    public UpdateSubEstUrlBuilder prorate(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='prorate='+checkBoolean(s);
        return this;
    }
    
    public UpdateSubEstUrlBuilder endOfTerm(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='end_of_term='+checkBoolean(s);
        return this;
    }
    
    public UpdateSubEstUrlBuilder invoiceImmediately(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='invoice_immediately='+checkBoolean(s);
        return this;
    }
    
    
    
    public UpdateSubEstUrlBuilder replaceAddons(String s){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='replace_addon_list='+checkBoolean(s);
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