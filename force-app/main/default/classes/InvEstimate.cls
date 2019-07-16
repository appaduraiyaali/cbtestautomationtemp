public class InvEstimate{
    public Boolean isRecur{get;set;}
    public Double subTot{get;set;}
    public Double tot{get;set;}
    public Double credApp{get;set;}
    public Double amtDue{get;set;}
    public Double amtPaid{get;set;}
    public List<BaseLineItem> lts{get;set;}
    public List<Discount> dts{get;set;}
    public String cc{get;set;}
    public Boolean isDisc{get;set;}
    
    public InvEstimate(Boolean isR,Double subT,Double t,Double credA,Double ad,Double ap,String code){
        lts = new List<BaseLineItem>();
        dts = new List<Discount>();
        isRecur=isR;
        subTot=subT;
        tot=t;
        credApp=credA;
        amtDue=ad;
        amtPaid=ap;
        cc=code;
    }
    
    public static InvEstBuilder builder(){
        return new InvEstBuilder(); 
    }
    
    public void addLte(String ua,String quan,String descrip,String amt,String damt,String fdate,String tdate,String et,String ei){
        lts.add(new BaseLineItem(ua,quan,descrip,amt,damt,cc,fdate,tdate,et,ei));
    }
    
    public void addDisc(String d,String a){
        dts.add(new Discount(d,a,cc));
    }
    
    public void setDisc(){
        if(dts.size()==0){
            isDisc=false;
        }else{
            isDisc=true;
        }
    }

}