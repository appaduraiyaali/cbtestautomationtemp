public class ListUnbilledCharges extends BaseEstimateResponse{

    public List<UnbilledCharges> unbilledCharges{get;set;}
    public Boolean isErrorResponse{get;set;}
    public ListUnbilledCharges(String js){
        super(js);
        unbilledCharges = new List<UnbilledCharges>();
        isErrorResponse=false;
        constructListObjects();
    }
    private void constructListObjects(){
         List<Object> details = (List<Object>)jsonMap.get('list');
         System.debug('details--'+details);
         if(details!=null){
                 for(Object each : details){
                        Object ltE = ((Map<String, Object>)each).get('unbilled_charge');
                        String fdate =   String.valueOf(((Map<String, Object>)ltE).get('date_from'));
                        String tdate =   String.valueOf(((Map<String, Object>)ltE).get('date_to'));
                        String unitAmount = String.valueOf(((Map<String, Object>)ltE).get('unit_amount'));
                        String quantity =   String.valueOf(((Map<String, Object>)ltE).get('quantity'));
                        String amt = String.valueOf(((Map<String, Object>)ltE).get('amount'));
                        String descrip = String.valueOf(((Map<String, Object>)ltE).get('description'));
                        String voided = String.valueOf(((Map<String, Object>)ltE).get('is_voided'));
                        String cc = String.valueOf(((Map<String, Object>)ltE).get('currency_code'));
                        String subId = String.valueOf(((Map<String, Object>)ltE).get('subscription_id'));
                        String disc_amt = String.valueOf(((Map<String, Object>)ltE).get('discount_amount')); 
                        UnbilledCharges temp = new UnbilledCharges(unitAmount,quantity,descrip,amt,cc,fdate,tdate,voided,subId,disc_amt);
                        unbilledCharges.add(temp);   
                 }
          }else{
              isErrorResponse=true;
          
          }
        
    }     
    public boolean isAllVoided(){
        List<Object> details = (List<Object>)jsonMap.get('list');
         System.debug('details--'+details);
         if(details!=null){
                 for(Object each : details){
                        Object ltE = ((Map<String, Object>)each).get('unbilled_charge');
                        String voided = String.valueOf(((Map<String, Object>)ltE).get('is_voided'));
                        if(voided=='false'){
                            return false;
                        }        
                 }
                 return true;
         }        
         return true;        
    }
    public class UnbilledCharges{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        public DateTime from_date{get;set;}
        public DateTime to_date{get;set;}
        public Boolean isVoided{get;set;}
        public String sub_id{get;set;}
        public String cCode{get;set;}
        public Double damt{get;set;}
        
        public UnbilledCharges(String ua,String quan,String descrip,String amt,String curCode,String fdate,String tdate,String isVoid,String subId,String disc_amt) {
            isVoided = Boolean.valueOf(isVoid);
            long amnt = Long.valueOf(ua);
            if(fdate==tdate){
                from_date = DateTime.newInstance(Long.valueOf(fdate)*1000);
                to_date=null;
            }else{
                from_date = DateTime.newInstance(Long.valueOf(fdate)*1000);
                to_date = DateTime.newInstance(Long.valueOf(tdate)*1000);
            }
            
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            long disc = Long.valueOf(disc_amt);
            if(disc!=0){
                amnt = amnt-disc;
            }
            damt=ChargebeeUtil.convertToHigherOrderCurrency(curCode,disc);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            sub_id=subId;
            cCode=curCode;
        }
    
    
    }


}