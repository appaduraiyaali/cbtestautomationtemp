public class CreateSubEstUrlBuilder extends URLBuilder{
    
    private static final String amp='&';
    
    public CreateSubEstUrlBuilder(){
        super();
    }
    
    public CreateSubEstUrlBuilder(EndPoint ep){
        super(ep);
    }
    
    
    public CreateSubEstUrlBuilder Id(String s){
        if(s!= null && !s.equals('')){
            s=EncodingUtil.urlEncode(s,'UTF-8');
            if(ustring!=''){
                ustring+=amp;
            }
            ustring+='subscription[id]='+s;
        }    
        return this;
    }
    
    public CreateSubEstUrlBuilder planId(String s){
        if(s!= null && !s.equals('')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_id]='+s;
        }
        return this;
    }
    
    public CreateSubEstUrlBuilder planQuan(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_quantity]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder planUnitPrice(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_unit_price]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder planSetupFee(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[setup_fee]='+s;
    }    
        return this;
    }
    
    
    
    public CreateSubEstUrlBuilder billingCycles(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='billing_cycles='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder couponId(String s){
    if(s!= null && !s.equals('-1')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='coupon_ids[0]='+s;
    }    
        return this;
    }
    
    
    
    
    public CreateSubEstUrlBuilder invoiceImmediately(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='invoice_immediately='+checkBoolean(s);
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder autoCol(String s){
    if(s!=null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='auto_collection='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder poNum(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='po_number='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder fnSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[first_name]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder lnSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[last_name]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder eSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[email]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder pSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[phone]='+s;
     }   
        return this;
    }
    
    public CreateSubEstUrlBuilder cSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[company]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder l1SA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[line1]='+s;
     }   
        return this;
    }
    
    
    
    public CreateSubEstUrlBuilder l2SA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[line2]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder l3SA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[line3]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder ciSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[city]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder sSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[state]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder coSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[country]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder zSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[zip]='+s;
    }    
        return this;
    }
    
    public CreateSubEstUrlBuilder stDate(String dstr){
        if(dstr!=null && !dstr.equals('')){
            dstr += ':00';
            long milli = CBSubscriptionUtil.getSubscriptionStartDate(dstr).getTime();
            if(ustring!=''){
                ustring+=amp;
            }
            ustring+='subscription[start_date]='+String.valueOf(milli/1000);
        }
        
        
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