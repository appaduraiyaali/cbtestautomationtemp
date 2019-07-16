public with sharing class ChangeNextRenewalDate{
    public DateTime currd{get;set;}
    public String newrd{get;set;}
    public CBURLUtil urlUtil{get;set;}
    public String currRDString{get;set;}
    public String Description{get;set;}
    public String subscriptionId{get;set;}
    public String invoiceOpt{get;set;}
    public List<SelectOption> invoiceOptList{get;set;}
    public boolean prorate{get;set;}
    public String curCode{get;set;}
    public String err{get;set;}
    public boolean errFlag{get;set;}
    
    //preview related
    public boolean showPopup {get;set;}
    public boolean creditNote{get;set;}
    public boolean invoiceNote{get;set;}
    public boolean unbilledCharges{get;set;}
    
    public String pname{get;set;}
    public String unitAmount{get;set;}
    public String quantity{get;set;}
    public String descrip{get;set;}
    public String tot{get;set;}
    public String amt{get;set;}
    public List<CreditDetails> cd{get;set;}
    public InvoiceDetails id{get;set;}
    public DateTime newrDT{get;set;}
    public long milli{get;set;}
    public List<UnbilledCharges> unbilled{get;set;}
    public string pkid{get;set;}
    public string subId{get;set;}
    public ChangeNextRenewalDate(){
        
        String sfId = ApexPages.currentPage().getParameters().get('pk');
        sfId=String.escapeSingleQuotes(sfId);
        String que = 'select Id,chargebeeapps__CB_Site__c,chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c,chargebeeapps__CB_Subscription_Id__c from chargebeeapps__CB_Subscription__c where id=\''+sfId+'\'';
        chargebeeapps__CB_Subscription__c rec = Database.query(que);
        subscriptionId = rec.chargebeeapps__CB_Subscription_Id__c;
        if(rec.chargebeeapps__CB_Site__c!=null){
            urlUtil = new CBURLUtil(SiteUtil.getSiteName(rec.chargebeeapps__CB_Site__c));
        }else{
            urlUtil = new CBURLUtil();
        }
        
        getCurRenewalDate();
        invoiceOptList = new List<SelectOption>();
        invoiceOptList.add(new SelectOption('ADD_UNBILLED_CHARGE','Add to Unbilled Charges'));                
        invoiceOptList.add(new SelectOption('INVOICE_NOW','Invoice Now'));
        pname='ChangeNextRenewalPopup';
        showPopup=false;
        creditNote=false;
        invoiceNote=false;
        unbilledCharges=false;
        cd = new List<CreditDetails>();
        unbilled = new List<UnbilledCharges>();
        errFlag=false;
        err='';
        
    }


    public void getCurRenewalDate(){
        String endPoint = urlUtil.getUrl() + '/api/v2/subscriptions/' + EncodingUtil.urlEncode(subscriptionId,'UTF-8');
        String cbResponse;
        String current_term_end;  
        DateTime dt = DateTime.now();
              
        try{
         cbResponse =  CBURLUtil.sendRequest(endPoint, null, urlUtil, true);
         current_term_end = CBURLUtil.getValueFromResponse(cbResponse, 'current_term_end');
         System.debug('cbResponse---'+cbResponse);
        }catch(Exception e){
            errFlag=true;
            err = e.getMessage();
            System.debug('Callout Exception-'+e);
            
        }
        if(current_term_end==null){
            current_term_end = String.valueOf(dt.getTime());
        }
        currd = DateTime.newInstance(Long.valueOf(current_term_end)*1000);
        System.debug('currd--' + currd);
    }




    public PageReference save(){
        if(newrd!=null){
            newrd += ':00';
        }
        try{
            newrDT = DateTime.newInstanceGmt(Integer.valueOf(newrd.subString(0,4)),
                    Integer.valueOf(newrd.subString(5,7)),Integer.valueOf(newrd.subString(8,10)),
                    Integer.valueOf(newrd.subString(11,13)),Integer.valueOf(newrd.subString(14,16)),
                    Integer.valueOf(newrd.subString(17,19)));
            milli = newrDT.getTime();
            milli /= 1000;
        }catch(exception e){
            errFlag=true;
            err = e.getMessage();
        }
        String bodyData = '';
        String endpoint = urlUtil.getUrl() + '/api/v2/subscriptions/' + EncodingUtil.urlEncode(subscriptionId,'UTF-8') + '/change_term_end';
        bodyData = CBURLUtil.buildURLString(bodyData, 'term_ends_at', String.valueOf(milli));
        bodyData = CBURLUtil.buildURLString(bodyData, 'prorate', String.valueOf(prorate));
        if( invoiceOpt.equals('INVOICE_NOW')){
            bodyData = CBURLUtil.buildURLString(bodyData, 'invoice_immediately', String.valueOf(true));        
        }
        else{
            bodyData = CBURLUtil.buildURLString(bodyData, 'invoice_immediately', String.valueOf(false));
        }
        String cbResponse;
        try{
         cbResponse =  CBURLUtil.sendRequest(endpoint, bodyData, urlUtil, true);
        }catch(Exception e){
        errFlag=true;
        err = e.getMessage();
        }
        Map<String, Object> responseMap = CBURLUtil.convertMap(cbResponse);
        if(responseMap.containsKey('error_msg')){
        
            errFlag=true;
            showPopup=false;
            err = (String)responseMap.get('error_msg');
            return null;
        }
        System.debug('cbResponse---'+cbResponse);
    return new PageReference('/' + ApexPages.currentPage().getParameters().get('pk'));
    }
    
    public void populate(){
        if(newrd!=null){
            newrd += ':00';
        }
        
        
        try{
            newrDT = DateTime.newInstanceGmt(Integer.valueOf(newrd.subString(0,4)),
                    Integer.valueOf(newrd.subString(5,7)),Integer.valueOf(newrd.subString(8,10)),
                    Integer.valueOf(newrd.subString(11,13)),Integer.valueOf(newrd.subString(14,16)),
                    Integer.valueOf(newrd.subString(17,19)));
            milli = newrDT.getTime();
            milli /= 1000;
            System.debug('milli----'+milli);
        }catch(exception e){
            errFlag=true;
            err = e.getMessage();
        }
        
        String bodyData = '';
        String endpoint = urlUtil.getUrl() + '/api/v2/subscriptions/' + EncodingUtil.urlEncode(subscriptionId,'UTF-8') + '/change_term_end_estimate';
        bodyData = CBURLUtil.buildURLString(bodyData, 'term_ends_at', String.valueOf(milli));
        bodyData = CBURLUtil.buildURLString(bodyData, 'prorate', String.valueOf(prorate));
        if( invoiceOpt.equals('INVOICE_NOW')){
            bodyData = CBURLUtil.buildURLString(bodyData, 'invoice_immediately', String.valueOf(true));
        }
        else{
            bodyData = CBURLUtil.buildURLString(bodyData, 'invoice_immediately', String.valueOf(false));            
        }
        String cbResponse;
        try{
         cbResponse =  CBURLUtil.sendRequest(endpoint, bodyData, urlUtil, true);
        }catch(Exception e){
            errFlag=true;
            err = e.getMessage();
        }
        System.debug('cbResponse---'+cbResponse);
        Integer tot;
        String type;
        Map<String, Object> responseMap = CBURLUtil.convertMap(cbResponse);
        if(responseMap.containsKey('error_msg')){
        
            errFlag=true;
            showPopup=false;
            err = (String)responseMap.get('error_msg');
            return;
        }
        Map<String, Object> estimate = (Map<String, Object>)responseMap.get('estimate');
        Map<String, Object> subEstimate = (Map<String, Object>)estimate.get('subscription_estimate');
        curCode = (String)subEstimate.get('currency_code');

        List<Object> cnEstimates = (List<Object>)estimate.get('credit_note_estimates');
        List<Object> unbilledEst = (List<Object>)estimate.get('unbilled_charge_estimates');
        Map<String, Object> inestimate = (Map<String, Object>)estimate.get('invoice_estimate');
        if(!cnEstimates.isEmpty()){
            creditNote = true;
        }
        if(unbilledEst!=null){
            unbilledCharges = true;
        }
        if(inestimate!=null){
            invoiceNote = true;
        }
        
        if(creditNote){
            for(Object cnE : cnEstimates){
                tot = (Integer)((Map<String, Object>)cnE).get('total');
                type = (String)((Map<String, Object>)cnE).get('type');
                List<Object> lt = (List<Object>)((Map<String, Object>)cnE).get('line_items');
                CreditDetails cdtemp = new CreditDetails(tot,type,curCode);
                for(Object ltE : lt)
                {
                    unitAmount = String.valueOf(((Map<String, Object>)ltE).get('unit_amount'));
                    quantity =   String.valueOf(((Map<String, Object>)ltE).get('quantity'));
                    amt = String.valueOf(((Map<String, Object>)ltE).get('amount'));
                    descrip = String.valueOf(((Map<String, Object>)ltE).get('description'));
                    cdtemp.addLineItems(unitAmount,quantity,descrip,amt);
                
                }
                cd.add(cdtemp);
            }
        }
        if(unbilledCharges){
            for(Object ubE : unbilledEst){
                    Long frmDate = (Long)((Map<String, Object>)ubE).get('date_from');
                    DateTime fd = DateTime.newInstance(frmDate*1000);
                    Long toDate = (Long)((Map<String, Object>)ubE).get('date_to');
                    DateTime td= DateTime.newInstance(toDate*1000);
                    unitAmount = String.valueOf(((Map<String, Object>)ubE).get('unit_amount'));
                    quantity =   String.valueOf(((Map<String, Object>)ubE).get('quantity'));
                    amt = String.valueOf(((Map<String, Object>)ubE).get('amount'));
                    descrip = String.valueOf(((Map<String, Object>)ubE).get('description'));
                    boolean iv=Boolean.valueOf(String.valueOf(((Map<String, Object>)ubE).get('is_voided')));
                    UnbilledCharges li = new UnbilledCharges(unitAmount,quantity,descrip,amt,curCode,iv,fd,td);
                    unbilled.add(li);   
            
            }
        }
        if(invoiceNote){
           
           tot = (Integer)((Map<String, Object>)inestimate).get('total');
           List<Object> lnEstimates = (List<Object>)inestimate.get('line_items');
           id = new InvoiceDetails(tot,curCode); 
           for(Object ltE : lnEstimates){
                    unitAmount = String.valueOf(((Map<String, Object>)ltE).get('unit_amount'));
                    quantity =   String.valueOf(((Map<String, Object>)ltE).get('quantity'));
                    amt = String.valueOf(((Map<String, Object>)ltE).get('amount'));
                    descrip = String.valueOf(((Map<String, Object>)ltE).get('description'));   
                    id.addLineItems(unitAmount,quantity,descrip,amt);
           }
        }        
    
    
    }
    
    public PageReference Cancel(){
        showPopup = false;
        
        PageReference pr = new PageReference('/apex/ChangeNextRenewalDate');
        
        pr.getParameters().put('pk',ApexPages.currentPage().getParameters().get('pk'));
        pr.getParameters().put('sub_id',ApexPages.currentPage().getParameters().get('sub_id'));
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference preview(){
        showPopup = true;
        pname = 'ChangeNextRenewalPopup';
        pkid = ApexPages.currentPage().getParameters().get('pk');
        subId = ApexPages.currentPage().getParameters().get('sub_id');
        system.debug('pk--'+pkid+','+'subId--'+subId);
        if(prorate)
        {
            populate();
        }    
        return null;
    }
     
    public class LineItem{
        public Double unitAmount{get;set;}
        public String quantity{get;set;}
        public String description{get;set;}
        public Double amount{get;set;}
        
        public LineItem(String ua,String quan,String descrip,String amt,String curCode) {
            long amnt = Long.valueOf(ua);
            unitAmount = ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
            
            quantity=quan;
            description=descrip;
            amnt = Long.valueOf(amt);
            amount=ChargebeeUtil.convertToHigherOrderCurrency(curCode,amnt);
        }
    }
    
    public class CreditDetails{
        public List<LineItem> cnl{get;set;}
        public Double total{get;set;}
        public String type{get;set;}
        public String curCode{get;set;}
        
        public CreditDetails(Integer tot,String ty,String curCode){
            cnl = new List<LineItem>();
            long tt=(long)(tot);
            total=ChargebeeUtil.convertToHigherOrderCurrency(curCode,tt);
            type=ty;
            this.curCode=curCode;      
        }
        
        public void addLineItems(String ua,String quan,String descrip,String amt){
            LineItem temp = new LineItem(ua,quan,descrip,amt,curCode);   
            cnl.add(temp);
        
        }
    }
    
    public class InvoiceDetails{
        public List<LineItem> cnl{get;set;}
        public Double total{get;set;}
        public String curCode{get;set;}
        public InvoiceDetails(Integer tot,String curCode){
            cnl = new List<LineItem>();
            long tt = (long)(tot);
            total=ChargebeeUtil.convertToHigherOrderCurrency(curCode,tt);
            this.curCode=curCode;      
        }
        public void addLineItems(String ua,String quan,String descrip,String amt){
            LineItem temp = new LineItem(ua,quan,descrip,amt,curCode);   
            cnl.add(temp);
        }
    }
    
    

}