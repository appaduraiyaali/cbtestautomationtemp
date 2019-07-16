public class UnbilledCharges{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        public boolean isVoided{get;set;}
        public DateTime fdate{get;set;}
        public DateTime tdate{get;set;}
        public UnbilledCharges(String ua,String quan,String descrip,String amt,String curCode,boolean iv,DateTime f,DateTime t) 
        {
            long amnt = Long.valueOf(ua);
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            isVoided=iv;
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            fdate=f;
            tdate=t;
        }
    
    
}