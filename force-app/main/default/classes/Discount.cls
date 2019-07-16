public class Discount{
    public String descrip{get;set;}
    public Double amt{get;set;}
    
    public Discount(String d,String a,String curCode){
        descrip=d;
        Long amount = Long.valueOf(a);
        amt=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amount);
    }
    
}