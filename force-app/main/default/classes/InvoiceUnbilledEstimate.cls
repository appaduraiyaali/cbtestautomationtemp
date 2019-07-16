public class InvoiceUnbilledEstimate extends BaseEstimateResponse{

    public List<InvoiceEstimateDetails> estDetails{get;set;}
    
    public InvoiceUnbilledEstimate(String js){
        super(js);
        estDetails = new List<InvoiceEstimateDetails>();
        constructEstimateDetails();
    }
    
    /*
        Methods to construct and access unbilled estimates.
    */
    private void constructEstimateDetails(){
         Object est = jsonMap.get('estimate');
         System.debug('getResponse()---'+ getResponse());
         List<Object> estDets = (List<Object>)((Map<String, Object>)est).get('invoice_estimates');
         
         if(estDets!=null){
         
                 for(Object cnE : estDets){
                        Integer tot = (Integer)((Map<String, Object>)cnE).get('total');
                        Integer credits = (Integer)((Map<String, Object>)cnE).get('credits_applied');
                        Integer amtDue = (Integer)((Map<String, Object>)cnE).get('amount_due');
                        Integer amtPaid = (Integer)((Map<String, Object>)cnE).get('amount_paid');
                        String cc = (String)((Map<String, Object>)cnE).get('currency_code');
                        List<Object> lt = (List<Object>)((Map<String, Object>)cnE).get('line_items');
                        List<Object> discounts = (List<Object>)((Map<String, Object>)cnE).get('discounts');
                        InvoiceEstimateDetails cdtemp = new InvoiceEstimateDetails(cc,tot,credits,amtDue,amtPaid);
                        if(lt!=null){
                            for(Object ltE : lt)
                            {
                                String fdate =   String.valueOf(((Map<String, Object>)ltE).get('date_from'));
                                String tdate =   String.valueOf(((Map<String, Object>)ltE).get('date_to'));
                                String unitAmount = String.valueOf(((Map<String, Object>)ltE).get('unit_amount'));
                                String quantity =   String.valueOf(((Map<String, Object>)ltE).get('quantity'));
                                String amt = String.valueOf(((Map<String, Object>)ltE).get('amount'));
                                String descrip = String.valueOf(((Map<String, Object>)ltE).get('description'));
                                cdtemp.addLineItems(unitAmount,quantity,descrip,amt,fdate,tdate);
                            }
                        }
                        if(discounts!=null){
                            for(Object d : discounts)
                            {
                                Integer amt = (Integer)((Map<String, Object>)d).get('amount');
                                String descrip = String.valueOf(((Map<String, Object>)d).get('description'));
                                cdtemp.addDiscounts(descrip,amt);
                            }
                        }
                        estDetails.add(cdtemp);    
                  }
         }               
                
    }
    public class LineItem{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        public DateTime from_date{get;set;}
        public DateTime to_date{get;set;}
        public LineItem(String ua,String quan,String descrip,String amt,String curCode,String fdate,String tdate) {
            long amnt = Long.valueOf(ua);
            from_date = DateTime.newInstance(Long.valueOf(fdate)*1000);
            to_date = DateTime.newInstance(Long.valueOf(tdate)*1000);
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
        }
    }
    
    public class Discount{
        public Double amt{get;set;}
        public String description{get;set;}
        public String cur{get;set;}
        public Discount(String descrip,Integer a,String cc)
        {
            cur=cc;
            long at = (long)(a);
            amt = ChargebeeUtil.convertToHigherOrderCurrency(cc,at);
            description = descrip;
        
        }
    }
    
    public class InvoiceEstimateDetails{
        public List<LineItem> cnl{get;set;}
        public List<Discount> discounts{get;set;}
        public String curCode{get;set;}
        public Double total{get;set;}
        public Double credits{get;set;}
        public Double dueAmt{get;set;}
        public Double paidAmt{get;set;}
        public InvoiceEstimateDetails(String curCode,Integer tot,Integer creds,Integer amtDue,Integer amtPaid){
            cnl = new List<LineItem>();
            discounts = new List<Discount>();
            long tt = (long)(tot);
            long cred = (long)(creds);
            long aDue = (long)(amtDue);
            long aPaid =(long)(amtPaid); 
            total=ChargebeeUtil.convertToHigherOrderCurrency(curCode,tt);
            credits=ChargebeeUtil.convertToHigherOrderCurrency(curCode,cred);
            dueAmt=ChargebeeUtil.convertToHigherOrderCurrency(curCode,aDue);
            paidAmt=ChargebeeUtil.convertToHigherOrderCurrency(curCode,aPaid);
            this.curCode=curCode;      
        }
        public void addLineItems(String ua,String quan,String descrip,String amt,String fdate,String tdate){
            LineItem temp = new LineItem(ua,quan,descrip,amt,curCode,fdate,tdate);   
            cnl.add(temp);
        }
        public void addDiscounts(String descrip,Integer a){
            Discount disc = new Discount(descrip,a,curCode);
            discounts.add(disc);
        }
    }
    
    
}