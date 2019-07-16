public class CreditNoteEstBuilder{
    public String invRefId{get;set;}
    public String type{get;set;}
    public Double subTot{get;set;}
    public Double tot{get;set;}
    public Double amtAlloc{get;set;}
    public String cc{get;set;}
    public CreditNoteEstBuilder(){
    
    }
    
    public CreditNoteEstBuilder refId(String id){
        invRefId=id;
        return this;
    }
    
    public CreditNoteEstBuilder type(String t){
        type=t;
        return this;
    }
    
    public CreditNoteEstBuilder subTot(Long st){
        subTot=ChargebeeUtil.convertToHigherOrderCurrency(cc,st);
        return this;
    }
    
    public CreditNoteEstBuilder tot(Long t){
        tot=ChargebeeUtil.convertToHigherOrderCurrency(cc,t);
        return this;
    }
    
    public CreditNoteEstBuilder amtAlloc(Long aa){
        amtAlloc=ChargebeeUtil.convertToHigherOrderCurrency(cc,aa);
        return this;
    }
    
    public CreditNoteEstBuilder currency(String ccode){
        cc=ccode;
        return this;
    }
    
    public CreditNoteEstimate build(){
        return new CreditNoteEstimate(invRefId,type,subTot,tot,amtAlloc,cc);
    }

}