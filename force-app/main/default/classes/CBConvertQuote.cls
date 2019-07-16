public with sharing class CBConvertQuote{
    //UI related variables
    public String subId{get;set;}
    public String invOpt{get;set;}
    public String autoCol{get;set;}
    public String ponum{get;set;}
    
    //Quote related Info
    public chargebeeapps__CB_Quote__c quote{get;set;}
    public List<SelectOption> invoicingOpts{get;set;}
    public List<chargebeeapps__CB_Quote_Product__c> quoteProducts{get;set;}
    public List<chargebeeapps__CB_Quote_Coupon__c> coupons{get;set;}
    public BaseError er{get;set;}
    
    //popup related info
    public String cbCustomerId{get;set;}
    public List<CreditNoteEstimate> cne{get;set;}
    public List<UnbilledEstimate> ue{get;set;}
    public InvEstimate ie{get;set;}
    public InvEstimate iie{get;set;}
    public boolean showPopup{get;set;}
    public List<String> tab{get;set;}
    public List<String> ctab{get;set;}
    public String pname{get;set;}
    public Integer val{get;set;}
    public boolean createSubshowPopup{get;set;}
    public List<AddonObject> addonList {get;set;}
    public List<LineItem> lts{get;set;}
    public String cc{get;set;}
    public Double disc_amt{get;set;} 
    public String disc_desc{get;set;}
    public boolean disc{get;set;}
    public Double tot{get;set;}
    public Double subt{get;set;}
    public String createpname{get;set;}
    public List<String> dispTxt{get;set;}
    public String plans{get;set;}
    public Integer quan{get;set;}
    public String planPrice{get;set;}
    public String planCur{get;set;}
    public String coupen{get;set;}
    public String status{get;set;}
    public String style{get;set;}
    public List<CBProd> se{get;set;}
    public boolean multiCn{get;set;}
    public Map<String,Boolean> typeOfProduct{get;set;}
    
    public CBConvertQuote(){
      invoicingOpts = new List<SelectOption>();
      invoicingOpts.add(new SelectOption('true','Invoice immediately'));
      invoicingOpts.add(new SelectOption('false','Add to Unbilled Charges'));
      
      
      String quoteId = ApexPages.currentPage().getParameters().get('id');
      quote = [select Id,chargebeeapps__CB_Site__c,chargebeeapps__Operation_Type__c,chargebeeapps__Status__c,chargebeeapps__CB_Quote_Id__c,chargebeeapps__CustomerID__c,chargebeeapps__CB_Subscription__r.chargebeeapps__CB_Subscription_Id__c from chargebeeapps__CB_Quote__c where Id=:quoteId];   
      quoteProducts = [select Id,chargebeeapps__CB_Quote__c,chargebeeapps__Product__r.ProductCode,chargebeeapps__Product__r.chargebeeapps__Recurring_charge_model__c,chargebeeapps__Product__r.chargebeeapps__Product_Type__c,chargebeeapps__Product__r.chargebeeapps__Currency__c,chargebeeapps__Quantity__c,chargebeeapps__UnitPrice__c from chargebeeapps__CB_Quote_Product__c where chargebeeapps__CB_Quote__c=:quoteId];
      coupons = [select Id,chargebeeapps__CB_Quote__c,chargebeeapps__CB_Coupon__r.chargebeeapps__CB_Coupon_Id__c from chargebeeapps__CB_Quote_Coupon__c where chargebeeapps__CB_Quote__c=:quoteId]; 
      chargebeeapps__Contact_Associate_Site__c contactSite = [select Id,chargebeeapps__CB_Site__c,chargebeeapps__Contact__c,chargebeeapps__External_Id__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__CB_Site__c=:quote.chargebeeapps__CB_Site__c and chargebeeapps__Contact__c=:quote.chargebeeapps__CustomerID__c];
      cbCustomerId =  contactSite.chargebeeapps__External_Id__c;
      //cbCustomerId='cbdemo_prepaid_card';
      tab = new List<String>(4);
      ctab = new List<String>(2);
      addonList = new List<AddonObject>();
      pname='QUpdateSubPreview';
      createpname='QuoteNewSubscriptionPreview';
      style='cb-status';
      lts = new List<LineItem>();
      dispTxt=new List<String>();
      typeOfProduct = new Map<String,Boolean>();
      if(coupons.size()>0){
            coupen=coupons[0].chargebeeapps__CB_Coupon__r.chargebeeapps__CB_Coupon_Id__c;
        }
        
        for(chargebeeapps__CB_Quote_Product__c quoteProduct:quoteProducts){
            
            if(quoteProduct.chargebeeapps__Product__r.chargebeeapps__Product_Type__c=='PLAN'){
                plans = quoteProduct.chargebeeapps__Product__r.ProductCode;
                quan=(Integer)quoteProduct.chargebeeapps__Quantity__c;
                planPrice=String.valueOf(quoteProduct.chargebeeapps__UnitPrice__c);
                planCur=quoteProduct.chargebeeapps__Product__r.chargebeeapps__Currency__c;
            }else if(quoteProduct.chargebeeapps__Product__r.chargebeeapps__Product_Type__c=='ADDON'){
                typeOfProduct.put(quoteProduct.chargebeeapps__Product__r.ProductCode,quoteProduct.chargebeeapps__Product__r.chargebeeapps__Recurring_charge_model__c=='RECURRING');
                addonList.add(constructAddonObject(quoteProduct));
            }
            
        }
        
        
    }
    
    
    public PageReference preCheck(){
        if(quote.chargebeeapps__Status__c=='ACCEPTED'||quote.chargebeeapps__Status__c=='OPEN'){
            return null;
        }    
        else{
            return UIUtil.redirectToGeneralErrorPage('CANNOT_CONVERT',quote.Id);
        }    
    }
    
    public PageReference cancel(){
        showPopup=false;
        createSubshowPopup=false;
        pname='QUpdateSubPreview';
        createpname='QuoteNewSubscriptionPreview';
        clearSetData();
        return null;
    }
    
     public void clearSetData(){
        dispTxt.clear();
        ie=null;
        iie=null;
        cne=null;
        ue=null;
    }
    
    public PageReference invoke(){
        Integer tn = val;
        InvEstimate temp;
        if(tn==0){
            pname='QUpdateSubPreview';
            
        }else if(tn==1){
            pname='QCredits';
            
        }else if(tn==2){
            pname='QImmediateCharges';
        }else if(tn==3){
            pname='QNextRenewalChanges';
        }
        updateStyleClass(tn);
        return null;
    }
    public PageReference invokeCreatePages(){
        Integer tn = val;
        if(tn==0){
            createpname='QuoteNewSubscriptionPreview';   
        }else if(tn==1){
            createpname='QuoteSecondtab'; 
        }
        updateCreateSubStyleClass(tn);
        return null;
    }
    private void updateCreateSubStyleClass(Integer t){
        ctab[t]='cb-btn cb-btn--selected';
        for(Integer i=0;i<ctab.size();i++){
            if(i!=t){
                ctab[i]='cb-btn cb-btn--normaltab';
            }
        }
    }
    private void updateStyleClass(Integer t){
        tab[t]='cb-btn cb-btn--selected';
        for(Integer i=0;i<tab.size();i++){
            if(i!=t){
                tab[i]='cb-btn cb-btn--normaltab';
            }
        }
    }
    
    public PageReference createSubEst(){
        String domain=SiteUtil.getSiteName(quote.chargebeeapps__CB_Site__c);
        //String domain='chaitanya-test';
        CBURLUtil urlUtil = new CBURLUtil(domain);
        EndPoint ep = EndPointsIndex.create_sub_est_url;
        ep.domainName(domain);
        List<String> liststr = new List<String>();
        liststr.add(EncodingUtil.urlEncode(cbCustomerId,'UTF-8'));
        ep.replace(liststr);
        CreateSubEstUrlBuilder br = new CreateSubEstUrlBuilder(ep);
        lts = new List<LineItem>();
        
        
        boolean canOverRide=urlUtil.canOverRide();
        br.planId(plans).planQuan(String.valueOf(quan)).couponId(coupen);
        if( canOverRide ){
            if(planPrice != null && !planPrice.equals('') && ! CBCreateSubscription.IsNewPricingModel(plans)){
                try{
                    br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planPrice))));
                    
                }
                catch(Exception e){
                    showPopup=false;
                    er = new BaseError(e.getMessage());
                    return null;
                }
                    
            }
            
        }
        br.ustring = CBSubscriptionUtil.getAddonURLWithOutMap(addonList,br.ustring,canOverRide);
        UpdateSubEstController ctllr = new UpdateSubEstController(br);
        Map<String, Object> responseMap = ctllr.makeRequest();
        
        er = new BaseError(responseMap);
        if(er.isErr){
            createSubshowPopup=false;
            return null;
        }
        
        //popup info and logic
        Map<String, Object> estimate = (Map<String, Object>)responseMap.get('estimate');
        Map<String, Object> subEstimate = (Map<String, Object>)estimate.get('subscription_estimate');
        Map<String, Object> invEst = (Map<String, Object>)estimate.get('invoice_estimate');
        if(invEst==null){
            invEst = (Map<String, Object>)estimate.get('next_invoice_estimate');
        }
        cc = (String)subEstimate.get('currency_code');
        status = (String)subEstimate.get('status');
        style = getCssStyle(status);
        System.debug('style - '+style);
        List<Object> lineItems = (List<Object>)invEst.get('line_items');
        subt = ChargebeeUtil.convertToHigherOrderCurrency(cc,Integer.valueOf(invEst.get('amount_due')));
        tot = ChargebeeUtil.convertToHigherOrderCurrency(cc,Integer.valueOf(invEst.get('total')));
        for(Object lt:lineItems){
            String unitAmount = String.valueOf(((Map<String, Object>)lt).get('unit_amount'));
            String quantity =   String.valueOf(((Map<String, Object>)lt).get('quantity'));
            String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
            String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
            String et = String.valueOf(((Map<String, Object>)lt).get('entity_type'));
            String e_id = String.valueOf(((Map<String, Object>)lt).get('entity_id'));
            boolean isRecurring=isRecurringProduct(et,e_id);
            LineItem  linet = new LineItem(unitAmount,quantity,descrip,amt,cc,et,isRecurring);
            lts.add(linet);
        }
        
        List<Object> discounts =null;
        if(invEst!=null){
            discounts = (List<Object>)invEst.get('discounts');
        }
        if(discounts!=null){
            Integer sl = (Integer)((Map<String, Object>)discounts[0]).get('amount');
            disc=true;
            long l = (long)(sl);        
            disc_amt = ChargebeeUtil.convertToHigherOrderCurrency(cc,l); 
            disc_desc = (String)((Map<String, Object>)discounts[0]).get('description');   
        }
        return null;
    }
    
    private String getCssStyle(String status){
        if(status=='in_trial'){
            style += ' cb-status--trial';
        }else if(status=='future'){
            style += ' cb-status--future'; 
        }
       return style;
    }
    
    private boolean isRecurringProduct(String productType,String productId){
        if(productType=='plan_setup'){
            return false;
        }else if(productType=='plan'){
            return true;
        }else if(typeOfProduct.get(productId)!=null){
            return typeOfProduct.get(productId)==true;
        }else{
            return false;
        }
    }
    
    public PageReference updateSubEst(){
        String domain=SiteUtil.getSiteName(quote.chargebeeapps__CB_Site__c);
        //String domain='chaitanya-test';
        CBURLUtil urlUtil = new CBURLUtil(domain);
        clearSetData();
        EndPoint ep = EndPointsIndex.cart_est_url;
        ep.domainName(domain);
        List<String> liststr = new List<String>();
        liststr.add(EncodingUtil.urlEncode(quote.chargebeeapps__CB_Subscription__r.chargebeeapps__CB_Subscription_Id__c,'UTF-8'));
        //liststr.add('1rpcuzKRRBaMYDPEC');
        ep.replace(liststr);
        UpdateSubUrlBuilder br = new UpdateSubUrlBuilder(ep);
        boolean canOverRide=urlUtil.canOverRide();
        br.planId(plans);
        if(quan!=null && !CBSubscriptionUtil.isFlatPlan(plans)){
            br.planQuan(String.valueOf(quan));
        }
        if(coupen!='-1' && coupen!=null){
            br.couponId(coupen);
        }
        
        if( canOverRide ){
            if(planPrice != null && !planPrice.equals('') && ! CBCreateSubscription.IsNewPricingModel(plans)){
                try{
                    br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planPrice))));
                    
                }
                catch(Exception e){
                    showPopup=false;
                    er = new BaseError(e.getMessage());
                    return null;
                }
                    
            }
            
        }
        br.ustring = CBSubscriptionUtil.getAddonURLWithOutMap(addonList,br.ustring,canOverRide);
        UpdateSubEstController ctllr = new UpdateSubEstController(br);
        //making request through controller.
        Map<String, Object> mp=ctllr.makeRequest();
        
        
        er = new BaseError(mp);
        if(er.isErr){
            showPopup=false;
            return null;
        }
        UpdateSubEstResponse resp = new UpdateSubEstResponse(mp);
        
        iie = resp.getNextInvEst('immediate_invoice_estimate');
        if(iie!=null){
            addToDisplayText('immediate_invoice_estimate',iie.tot);
        }else{
            addToDisplayText('immediate_invoice_estimate',0);
        }
        
        ie = resp.getNextInvEst('next_invoice_estimates');
        if(ie!=null){
            addToDisplayText('next_invoice_estimates',ie.tot);
        }
        se=resp.getSubEstimate(ie.cc,quote.chargebeeapps__CB_Site__c);
        cne = resp.getCreditEst();
        if(cne!=null){
            multiCn = cne.size()>1;
            if(multiCn){
                addToDisplayText('credits',UpdateSub.getCNTotal(cne));
            }else{
                addToDisplayText('credits',cne[0].tot);
            }
            
            
        }
        if(ie==null && iie==null && cne==null){
            er = new BaseError();
            er.setError('There is no change in subscription.');
            showPopup=false;
            return null;
        }
        //se.getStyleClass()
        return null;
    }
    private void addToDisplayText(String key,Double amt){
        if(key=='immediate_invoice_estimate'){
            if(amt!=0){
                dispTxt.add('An invoice for '+iie.cc+' '+amt+' will be generated immediately.');
            }else{
                 dispTxt.add('There will be no immediate charges.');
            }
        }else if(key=='next_invoice_estimates'){
            dispTxt.add('Subsequent invoice for '+ie.cc+' '+amt+' will be generated upon renewal.');
        }
        else if(key=='credits'){
            dispTxt.add(cne[0].typ.capitalize()+' credits worth '+cne[0].cc+' '+amt+' will be created and applied on the immediate invoice.');   
        }else if(key=='unbilled_charge_estimates'){
            Double a= UpdateSub.getTotal(ue);
            dispTxt.add('A charge of '+ue[0].cc+' '+a+' will be added to the unbilled charges.');
        }
        
    }
    
    public PageReference save(){
        EndPoint ep = EndPointsIndex.convert_quote;
        ep.domainName(SiteUtil.getSiteName(quote.chargebeeapps__CB_Site__c));
        List<String> liststr = new List<String>();
        liststr.add(EncodingUtil.urlEncode(quote.chargebeeapps__CB_Quote_Id__c,'UTF-8'));
        ep.replace(liststr);
        GenericURLBuilder br = new GenericURLBuilder(ep);
        GenericController ctr = new GenericController(br);
        Map<String,Object> resp = ctr.makeRequest();
        er = new BaseError(resp);
        if(er.isErr){
            return null;
        }
        return new PageReference('/'+quote.Id);
    }
    
    public AddonObject constructAddonObject(chargebeeapps__CB_Quote_Product__c quoteProduct){
        AddonObject a=new AddonObject(quoteProduct.chargebeeapps__Product__r.ProductCode,(Integer)quoteProduct.chargebeeapps__Quantity__c,0,quoteProduct.chargebeeapps__UnitPrice__c,false);
        a.setStatus(2);
        return a;
    }
    
    public PageReference populate(){
        if(quote.chargebeeapps__Operation_Type__c=='CREATE_SUBSCRIPTION_FOR_CUSTOMER'){
            createSubshowPopup=true;
            updateCreateSubStyleClass(0);
            createSubEst();
        }else{
            showPopup=true;
            updateStyleClass(0);
            updateSubEst();
        }
        
        return null;
    }
    
    

}