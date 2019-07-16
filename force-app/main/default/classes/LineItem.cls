public class LineItem
    {
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        public String etype{get;set;}
        public boolean isRecur{get;set;}
        public String plantype{get;set;}
        public boolean displayIcon{get;set;}
        public boolean displayTiers{get;set;}
        public boolean showUnit{get;set;}
        
        public List<Map<String,Object>> tierdata{get;set;}
        //public string units{get;set;}
        public LineItem(String ua,String quan,String descrip,String amt,String curCode,String et,boolean ir) 
        {
            
            long amnt = Long.valueOf(ua);
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            isRecur = ir;
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            etype=et;            
        }    
    }