public class AddChargeBuilder extends URLBuilder{
    
    private static final String amp='&';
    
    public AddChargeBuilder(){
        super();
    }
    
    public AddChargeBuilder(EndPoint ep){
        super(ep);
    }
    
    
    public AddChargeBuilder subId(String s){
        if(s!= null && !s.equals('')){
            s=EncodingUtil.urlEncode(s,'UTF-8');
            if(ustring!=''){
                ustring+=amp;
            }
            ustring+='subscription_id='+s;
        }    
        return this;
    }
    
    public AddChargeBuilder amt(String s){
        if(s!= null && !s.equals('')){
            s=EncodingUtil.urlEncode(s,'UTF-8');
            if(ustring!=''){
                ustring+=amp;
            }
            ustring+='amount='+s;
        }    
        return this;
    }
    public AddChargeBuilder descrip(String s){
        if(s!= null && !s.equals('')){
            s=EncodingUtil.urlEncode(s,'UTF-8');
            if(ustring!=''){
                ustring+=amp;
            }
            ustring+='description='+s;
        }    
        return this;
    }
    
    
    
    

}