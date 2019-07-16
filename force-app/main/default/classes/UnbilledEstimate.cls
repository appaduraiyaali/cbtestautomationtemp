public virtual class UnbilledEstimate{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        public Double disc_amount{get;set;}
        public DateTime from_date{get;set;}
        public DateTime to_date{get;set;}
        public String ent_type{get;set;}
        public String ent_id{get;set;}
        public String cc{get;set;}
        public Boolean isVoid{get;set;}
        public Boolean isDel{get;set;}
        
        public UnbilledEstimate(String ua,String quan,String descrip,String amt,String damt,String curCode,String fdate,String tdate,String et,String ei,Boolean iv,Boolean isd) {
            long amnt = Long.valueOf(ua);
            from_date = DateTime.newInstance(Long.valueOf(fdate)*1000);
            to_date = DateTime.newInstance(Long.valueOf(tdate)*1000);
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            amnt=Long.valueOf(damt);
            disc_amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            ent_type=et;
            ent_id=ei;
            cc=curCode;
            isVoid=iv;
            isDel=isd;
        }
    }