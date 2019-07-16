public class CBProd{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        public String cc{get;set;}
        public String etype{get;set;}
        public String charge_type{get;set;}
        
        public CBProd(String ua,String quan,String descrip,String amt,String curCode,String et,String ct) {
            long amnt = Long.valueOf(ua);
            
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            cc=curCode;
            etype=et;
            charge_type=ct;   
        }
        
        
    }