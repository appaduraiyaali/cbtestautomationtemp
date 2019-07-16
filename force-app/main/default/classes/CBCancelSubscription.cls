public with sharing class CBCancelSubscription
{
    public String sub_id{get;set;}
    
    public chargebeeapps__CB_Subscription__c subObj{get;set;}
    public boolean showPopup{get;set;}
    public boolean eotFlag{get;set;}
    public String response{get;set;}
    public datetime startDate{get;set;}
    public boolean empty{get;set;}
    public String err_msg{get;set;}
    
    public CBURLUtil urlUtil{get;set;}
    
    public CBCancelSubscription()
    {
        empty=false;
        response=null;
        sub_id=ApexPages.currentPage().getParameters().get('sub_id');
        sub_id=String.escapeSingleQuotes(sub_id);
        String que = 'select Id,Name,chargebeeapps__CB_Site__c,chargebeeapps__Next_billing__c,chargebeeapps__Subscription_status__c,chargebeeapps__CB_Subscription_Id__c from chargebeeapps__CB_Subscription__c where id=\''+sub_id+'\'';
        subObj = Database.query(que);
        if(subObj.chargebeeapps__CB_Site__c!=null){
            urlUtil = new CBURLUtil(SiteUtil.getSiteName(subObj.chargebeeapps__CB_Site__c));
        }
        showPopup = false;
        String endpoint = urlUtil.getUrl()+'/api/v2/subscriptions/'+EncodingUtil.urlEncode(subObj.chargebeeapps__CB_Subscription_Id__c,'UTF-8');
        Integer count;
        Map<String, Object> responseMap;
        String res;
        try{
            res= CBURLUtil.sendRequest(endpoint,null,urlUtil,true,'GET');
            System.debug('response----'+res);
            responseMap = CBURLUtil.convertMap(res);
            Map<String, Object> s = (Map<String, Object>)responseMap.get('subscription');
            startDate = datetime.newInstance(0);
            count = (Integer)s.get('current_term_end');
            String status = (String)s.get('status');
            startDate = startDate.addSeconds(count);
            if(status=='cancelled'){
                empty=true;
                err_msg='This Subscription is already cancelled.';
            }
        
        }catch(Exception e){
            empty=true;
            err_msg = (String)responseMap.get('message')+'.';
            if(err_msg==null){
                  err_msg='CB Internal Error - '+response;
            }
        }    
    }
    public PageReference CancelSub()
    {
        showPopup = false;
        return null;
    }
    public PageReference can()
    {
        if(response!=null)
        {
            showPopup = false;   
        }
        return null;
    
    }
    public PageReference Sub()
    {
        
        PageReference pr = new PageReference('/'+sub_id);
        
        pr.setRedirect(true);
        return pr;

        
    }
    
    public PageReference show1()
    {
        showPopup=true;
        eotFlag=false;
        return null;
    }
    public PageReference show2()
    {
        showPopup=true;
        eotFlag=true;
        return null;
    }
    
    public PageReference save()
    {
        String ext_id = subObj.chargebeeapps__CB_Subscription_Id__c;
        String endpointURL = CBSubscriptionUtil.getCancelSubscriptionEndPoint(urlUtil,ext_id);
        String bodyData = '';
        bodyData = CBURLUtil.buildURLString(bodyData,'end_of_term',CBURLUtil.boolToString(eotFlag));
        
        System.debug('endpointURL----'+endpointURL);
        String responseFromNet = CBURLUtil.sendRequest(endpointURL,bodyData, urlUtil, true);
        System.debug('responseFromNet---'+responseFromNet);
        Map<String, Object> responseMap = CBURLUtil.convertMap(responseFromNet);
        try
        {
            Map<String, Object> subscription = (Map<String, Object>)responseMap.get('subscription');
            String det = (String)subscription.get('id');
        }
        catch(Exception ex)
        {
            
            response = responseFromNet;
            return null;
        }
        return Sub();
    }

}