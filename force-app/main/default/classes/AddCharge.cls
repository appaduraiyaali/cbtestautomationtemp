public with sharing class AddCharge
{
    public String amount{get;set;}
    public String description{get;set;}
    public String invoiceOpt{get;set;}
    public List<SelectOption> invoiceOptList{get;set;}
    
    private String subscriptionId;
    public String responseFromNet{get;set;}
    public Product2[] p{get;set;}
    public BaseError er{get;set;}
    public chargebeeapps__CB_Subscription__c rec{get;set;}
    public String oldPlanCur{get;set;}
    public PageReference checkPermissions(){
        List<String> fields1 = new List<String> {'Id','chargebeeapps__Currency__c'};
        List<String> fields2 = new List<String> {'chargebeeapps__Subscription_Plan__c'};
        List<String> objNames = new List<String>();
        String fs;
        if(!FlsUtil.isPermitable(fields1,'product2')){
            fs = FlsUtil.getNotAccessibleFields(fields1,'product2','access');
            objNames.add('product2');   
        }
        if(!FlsUtil.isPermitable(fields2,'chargebeeapps__CB_Subscription__c')){
            fs += FlsUtil.getNotAccessibleFields(fields2,'chargebeeapps__CB_Subscription__c','access');
            objNames.add('chargebeeapps__CB_Subscription__c');   
        }
        System.debug('fs-----'+fs);
        if(fs==null)
        {
            return null;
        }
        else
            return redirectToError(fs,String.join(objNames,','));
    }
    
    
    public AddCharge(){
        
        invoiceOptList = new List<SelectOption>();
        invoiceOptList.add(new SelectOption('ADD_UNBILLED_CHARGE','Add to Unbilled Charges'));                
        invoiceOptList.add(new SelectOption('INVOICE_NOW','Invoice Now'));
        
        List<String> fields1 = new List<String> {'Id','chargebeeapps__Currency__c'};
        List<String> fields2 = new List<String> {'chargebeeapps__Subscription_Plan__c'};
        
        
        er = new BaseError();
        String sfid = ApexPages.currentPage().getParameters().get('pk');
        sfid = String.escapeSingleQuotes(sfid);
        String que = 'select Id,chargebeeapps__CB_Site__c,chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c,chargebeeapps__CB_Subscription_Id__c from chargebeeapps__CB_Subscription__c where id=\''+sfid+'\'';
        rec = Database.query(que);
        oldPlanCur = rec.chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c;
        
    }
    
    public PageReference redirectToError(String err,String obj){
       PageReference pageRef = new PageReference('/apex/error');
       pageRef.getParameters().put('err',err);
       pageRef.getParameters().put('obj',obj);
       pageRef.setRedirect(true);
       return pageRef; 
    }

    public PageReference save(){
        
        String sfid = ApexPages.currentPage().getParameters().get('pk');
        
        
        //vars
        EndPoint ep;
        AddChargeBuilder br;
        
        //choose endpoint based on invoice options 
        if(invoiceOpt.equals('ADD_UNBILLED_CHARGE')){
            ep = EndPointsIndex.add_charge_unbilled;
            ep.domainName(SiteUtil.getSiteName(rec.chargebeeapps__CB_Site__c));
            List<String> liststr = new List<String>();
            liststr.add(EncodingUtil.urlEncode(rec.chargebeeapps__CB_Subscription_Id__c,'UTF-8'));
            ep.replace(liststr);
            br = new AddChargeBuilder(ep);
        }else{
            ep = EndPointsIndex.add_charge_inv_now;
            ep.domainName(SiteUtil.getSiteName(rec.chargebeeapps__CB_Site__c));
            br = new AddChargeBuilder(ep);
            br.subId(rec.chargebeeapps__CB_Subscription_Id__c);
        }
        
        //build the url
        try{
            br.amt(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(oldPlanCur,Double.valueOf(amount))));
        }catch(Exception ex){
            er = new BaseError();
            er.setError(ex.getMessage());
            return null;
        }
        br.descrip(description);
        
        
        //make request and check for errors
        UpdateSubEstController ctllr = new UpdateSubEstController(br);
        Map<String,Object> mp;
        try{
            mp=ctllr.makeRequest();
        }
        catch(Exception ex){
            er = new BaseError();
            er.setError(ex.getMessage());
            return null;
        }        
        er = new BaseError(mp);
        if(er.isErr){
            return null;
        }
        return new PageReference('/' + sfid);

    }
}