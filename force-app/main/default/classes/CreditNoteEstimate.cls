public class CreditNoteEstimate{
    public String invRefId{get;set;}
    public String typ{get;set;}
    public Double subTot{get;set;}
    public Double tot{get;set;}
    public Double amtAlloc{get;set;}
    public String cc{get;set;}
    public List<BaseLineItem> lts{get;set;}
    public List<Discount> dts{get;set;}
    public Boolean isDisc{get;set;}
    
    public CreditNoteEstimate(String iid,String t,Double st,Double to,Double aa,String code){
        lts = new List<BaseLineItem>();
        dts = new List<Discount>();
        invRefId=iid;
        typ=t;
        subTot=st;
        tot=to;
        amtAlloc=aa;
        cc=code;
    }
    
    public static CreditNoteEstBuilder builder(){
        return new CreditNoteEstBuilder(); 
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