public class CreateSubUrlBuilder extends URLBuilder{
    
    private static final String amp='&';
    
    public CreateSubUrlBuilder(EndPoint ep){
        super(ep);
    }
    
    
    public CreateSubUrlBuilder Id(String s){
    if(s!= null && !s.equals('')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='id='+s;
    }
        return this;
    }
    
    public CreateSubUrlBuilder planId(String s){
    if(s!= null && !s.equals('')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='plan_id='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder planQuan(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='plan_quantity='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder planUnitPrice(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='plan_unit_price='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder planSetupFee(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='setup_fee='+s;
    }    
        return this;
    }
    
    
    
    public CreateSubUrlBuilder billingCycles(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='billing_cycles='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder couponId(String s){
    if(s!= null && !s.equals('-1')){
        s=EncodingUtil.urlEncode(s,'UTF-8');
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='coupon_ids[0]='+s;
    }    
        return this;
    }
    
    
    
    
    public CreateSubUrlBuilder invoiceImmediately(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='invoice_immediately='+checkBoolean(s);
    }    
        return this;
    }
    
    public CreateSubUrlBuilder autoCol(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='auto_collection='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder poNum(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='po_number='+s;
    }
        return this;
    }
    
    public CreateSubUrlBuilder fnSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[first_name]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder lnSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[last_name]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder eSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[email]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder pSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[phone]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder cSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[company]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder l1SA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[line1]='+s;
    }    
        return this;
    }
    
    
    
    public CreateSubUrlBuilder l2SA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[line2]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder l3SA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[line3]='+s;
        
     }   
        return this;
    }
    
    public CreateSubUrlBuilder ciSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[city]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder sSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[state]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder coSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[country]='+s;
     }   
        return this;
    }
    
    public CreateSubUrlBuilder zSA(String s){
    if(s!= null && !s.equals('')){
        if(ustring!=''){
            ustring+=amp;
        }
        ustring+='shipping_address[zip]='+s;
    }    
        return this;
    }
    
    public CreateSubUrlBuilder stDate(String dstr){
        if(dstr!=null && !dstr.equals('')){
            dstr += ':00';
            long milli = CBSubscriptionUtil.getSubscriptionStartDate(dstr).getTime();
            if(ustring!=''){
                ustring+=amp;
            }
            ustring+='start_date='+String.valueOf(milli/1000);
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