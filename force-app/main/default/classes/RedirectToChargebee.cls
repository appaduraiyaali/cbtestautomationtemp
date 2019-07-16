public with sharing class RedirectToChargebee{
    public String sub_id{get;set;}    
    public CBURLUtil urlUtil{get;set;}
    public chargebeeapps__CB_Subscription__c subObj{get;set;}
    public Set<String> whiteListedDomains{get;set;}
    
    public RedirectToChargebee(){
        whiteListedDomains = new Set<String>();
        String subParamId = ApexPages.currentPage().getParameters().get('sub_id').escapeHtml4();
        subParamId = String.escapeSingleQuotes(subParamId);
        String que = 'select chargebeeapps__CB_Subscription_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__CB_Subscription__c where Id=:subParamId';
        subObj = Database.query(que);
        urlUtil = new CBURLUtil(SiteUtil.getSiteName(subObj.chargebeeapps__CB_Site__c));
        String url = urlUtil.getUrl()+'/admin-console/subscriptions/';
        whiteListedDomains.add(url);
    }
    
    public PageReference redirectToError(){
           PageReference pageRef = new PageReference('/apex/error');
           pageRef.setRedirect(true);
           return pageRef; 
    }
    
    public PageReference setSubId(){
            
            List<String> fields = new List<String> {'chargebeeapps__CB_Subscription_Id__c'};
            if(!FlsUtil.isPermitable(fields,'chargebeeapps__CB_Subscription__c'))
            {
                return redirectToError();
            }
            String url =  urlUtil.getUrl()+'/admin-console/subscriptions/';
                if(!whiteListedDomains.contains(url))
                {
                     url = '/home/home.jsp';
                     return new PageReference(''+url);   
                }
            sub_id = url + subObj.chargebeeapps__CB_Subscription_Id__c;
            return new PageReference(''+sub_id);
    }
    public PageReference back(){
           PageReference pageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('sub_id'));
           pageRef.setRedirect(true);
           return pageRef;
    }
}