public class CheckoutNewURLB extends URLBuilder{
    private static final String amp='&';
    
    public CheckoutNewURLB(){
        super();
    }
    
    public CheckoutNewURLB(EndPoint ep){
        super(ep);
    }
    
    
    public CheckoutNewURLB Id(String s){
    if(s!= null && !s.equals('')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[id]='+s;
     }   
        return this;
    }
    
    public CheckoutNewURLB custId(String s){
    if(s!= null && !s.equals('')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='customer[id]='+s;
    }    
        return this;
    }
    
    public CheckoutNewURLB planId(String s){
    if(s!= null && !s.equals('')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_id]='+s;
    }    
        return this;
    }
    
    public CheckoutNewURLB planQuan(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_quantity]='+s;
    }    
        return this;
    }
    
    
    
    
    public CheckoutNewURLB autoCol(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[auto_collection]='+s;
    }    
        return this;
    }
    
    public CheckoutNewURLB poNum(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='po_number='+s;
    }    
        return this;
    }
    
    public CheckoutNewURLB billingCycles(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='billing_cycles='+s;
     }   
        return this;
    }
    
    public CheckoutNewURLB couponId(String s){
    if(s!= null && !s.equals('-1')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[coupon]='+s;
     }   
        return this;
    }
    
    public CheckoutNewURLB planUnitPrice(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[plan_unit_price]='+s;
    }    
        return this;
    }
    
    public CheckoutNewURLB planSetupFee(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='subscription[setup_fee]='+s;
    }    
        return this;
    }
    
    public CheckoutNewURLB stDate(String dstr){
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
    
    


}