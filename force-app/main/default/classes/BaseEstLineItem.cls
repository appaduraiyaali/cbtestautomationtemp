public class BaseEstLineItem{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        
        public BaseEstLineItem(String ua,String quan,String descrip,String amt,String curCode) {
            long amnt = Long.valueOf(ua);
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
        }
    }