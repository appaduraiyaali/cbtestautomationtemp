public class InvEstBuilder{
    public Boolean isRecur{get;set;}
    public Double subTot{get;set;}
    public Double tot{get;set;}
    public Double credApp{get;set;}
    public Double amtDue{get;set;}
    public Double amtPaid{get;set;}
    public String cc{get;set;}
    
    public InvEstBuilder(){
    
    }
    
    public InvEstBuilder recur(Boolean r){
        isRecur=r;
        return this;
    }
    
    
    public InvEstBuilder subTot(Long st){
        subTot=ChargebeeUtil.convertToHigherOrderCurrency(cc,st);
        return this;
    }
    
    public InvEstBuilder tot(Long t){
        tot=ChargebeeUtil.convertToHigherOrderCurrency(cc,t);
        return this;
    }
    
    public InvEstBuilder credApp(Long aa){
        credApp=ChargebeeUtil.convertToHigherOrderCurrency(cc,aa);
        return this;
    }
    
    public InvEstBuilder amountDue(Long aa){
        amtDue=ChargebeeUtil.convertToHigherOrderCurrency(cc,aa);
        return this;
    }
    
    public InvEstBuilder amountPaid(Long aa){
        amtPaid=ChargebeeUtil.convertToHigherOrderCurrency(cc,aa);
        return this;
    }
    
    public InvEstBuilder currency(String curcode){
        cc=curcode;
        return this;
    }
    
    public InvEstimate build(){
        return new InvEstimate(isRecur,subTot,tot,credApp,amtDue,amtPaid,cc);
    }

}