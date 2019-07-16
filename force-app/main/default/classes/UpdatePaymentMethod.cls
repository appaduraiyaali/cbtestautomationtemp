public with sharing class UpdatePaymentMethod
{

  public String subject{get;set;}
  
  public String email{get;set;}
  
  public String link{get;set;}
    
  public String pre_message{get;set;}
  
  public String post_message{get;set;}
  
  public  Account acct {get;set;}
  
  public Contact cont {get;set;}

  public String response{get;set;}  
    
  public CBURLUtil urlUtil{get;set;}     
  
  public boolean isMultiSite{get;set;} 
  public boolean flag{get;set;} 
  public boolean disableSelectedSite{get;set;}
  public chargebeeapps__CB_Settings__c sites {get;set;}
  public chargebeeapps__Contact_Associate_Site__c consite{get;set;}
  public List<chargebeeapps__Contact_Associate_Site__c> existingConSite{get;set;}  
  public String selectedSites{get;set;}
  public boolean now{get;set;}
  public boolean isSiteConnected{get;set;}  
    public List<selectOption> getSiteDetails()
    {
    system.debug('csdscd');
         String cus_id = ApexPages.currentPage().getParameters().get('id');
         List<selectOption> multiSites = new List<selectOption>();
         List<Contact_Associate_Site__c> syncedSites = [SELECT chargebeeapps__Contact__c ,chargebeeapps__External_Id__c ,chargebeeapps__CB_Site__c FROM chargebeeapps__Contact_Associate_Site__c WHERE chargebeeapps__Contact__c =: cus_id AND chargebeeapps__External_Id__c != null];
         isSiteConnected = syncedSites.size()==1;
         for(Contact_Associate_Site__c siteList:syncedSites){
             string sid = siteList.chargebeeapps__CB_Site__c;
             
             String domain = SiteUtil.getSiteName(sid);
             multiSites.add(new SelectOption(domain,domain));
             system.debug('SiteName:'+multiSites);
         }
         system.debug('multiSites:'+multiSites);
         return multiSites;
     }  
   public PageReference send()
  {
      
        urlUtil = new CBURLUtil(selectedSites);
        response = null;
        String responseFromNet;
        System.debug('The other one is before the select statement');
        fetchLinkUrl(selectedSites);
      
        string endpointURL = urlUtil.getUrl()+'/adhoc_checkout_email/api/send';
        system.debug('URL:'+endpointURL);
        String mailContent = pre_message.replace('\n','<br>') + link +'<br>'+ post_message.replace('\n','<br>');
        system.debug(mailContent);
        System.debug('email--'+email);
        if(email==null){
          response='Please make sure the email is present.';
          return null;
        }
        String bodyData = '';
        bodyData = CBURLUtil.buildURLString(bodyData, 'content', mailContent);
        bodyData = CBURLUtil.buildURLString(bodyData, 'subject', subject);
        bodyData = CBURLUtil.buildURLString(bodyData, 'to_address', email);
        bodyData = CBURLUtil.buildURLString(bodyData, 'api_key', urlUtil.getApiKey());
        system.debug('Bodysent:'+bodyData);
                                
        try {
            responseFromNet = CBURLUtil.sendRequest(endpointURL, bodyData, urlUtil, true);
            system.debug('Response2:'+responseFromNet);
        }
        catch(Exception exp){
                    System.debug('exception '+exp);
                    responseFromNet = 'exception '+exp;
                    response = 'error';
        }  
        
        if(response==null){
            String cus_id = ApexPages.currentPage().getParameters().get('id');
            PageReference pageRef = new PageReference('/'+cus_id);
            pageRef.setRedirect(true);
            return pageRef;
        } 
        
          return null;
  
  }    
  
  
  public PageReference cancel(){
    String cus_id = ApexPages.currentPage().getParameters().get('id');
    PageReference pageRef = new PageReference('/'+cus_id);
    return pageRef;
  }
  
 public Boolean useV3UpdatePayment{get;set;}

  public PageReference fetchLinkUrl(string selectedSites){
        List<String> fields1 = new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c'};
        List<String> fields2 = new List<String> {'Name'};
        List<String> fields3 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
        List<String> objNames = new List<String>();
        String fs;
        if(!FlsUtil.isPermitable(fields1,'contact')){
            fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
            objNames.add('contact');   
        }
        if(!FlsUtil.isPermitable(fields2,'account')){
            fs += FlsUtil.getNotAccessibleFields(fields2,'account','access');
            objNames.add('account');   
        }
        if(!FlsUtil.isPermitable(fields3,'chargebeeapps__Contact_Associate_Site__c')){
            fs += FlsUtil.getNotAccessibleFields(fields3,'chargebeeapps__Contact_Associate_Site__c','access');
            objNames.add('chargebeeapps__Contact_Associate_Site__c');   
        }
        if(fs!=null)
        {
            return redirectToError(fs,String.join(objNames,','));
        }
        fetchLink(selectedSites);          
    return null;
  }
  
  public PageReference fetchLinkForRedirection(){
      List<String> fields1 = new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c'};
        List<String> fields2 = new List<String> {'Name'};
        List<String> fields3 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
        List<String> objNames = new List<String>();
        String fs;
        if(!FlsUtil.isPermitable(fields1,'contact')){
            fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
            objNames.add('contact');   
        }
        if(!FlsUtil.isPermitable(fields2,'account')){
            fs += FlsUtil.getNotAccessibleFields(fields2,'account','access');
            objNames.add('account');   
        }
        if(!FlsUtil.isPermitable(fields3,'chargebeeapps__Contact_Associate_Site__c')){
            fs += FlsUtil.getNotAccessibleFields(fields3,'chargebeeapps__Contact_Associate_Site__c','access');
            objNames.add('chargebeeapps__Contact_Associate_Site__c');   
        }
        if(fs!=null)
        {
            return redirectToError(fs,String.join(objNames,','));
        }
        fetchLink(selectedSites);
        if(link == null){
            return null;
        }
        return new PageReference(link);
  }
  
  public PageReference check(){
      if(now){
          return fetchLinkForRedirection();
      }
      return null;    
  }
  public boolean useV3HP(CBURLUtil util){
      System.debug('util----'+util);
      String settingString = util.getSiteSettingJSON();
        Map<String, Object> SiteSettingObject = 
            settingString!=null?(Map<String, Object>)JSON.deserializeUntyped(settingString):null;
      System.debug('SiteSettingObject----'+SiteSettingObject);      
        if( SiteSettingObject != null){
        System.debug('SiteSettingObject-------'+SiteSettingObject.get('useV3UpdatePayment'));      
            return SiteSettingObject.get('useV3UpdatePayment') == 'V3';
        }
        return false;
  
  }
  private void fetchLink(string selectedSites){
        response = null;
        String responseFromNet;
        System.debug('The other one is before the select statement');
        String paymentMethodURL = 'update_payment_method';
      
         String sid = SiteUtil.getSiteId(selectedSites);
        existingConSite = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c, chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c=:sid)];
        system.debug(existingConSite);
      
      urlUtil = new CBURLUtil(selectedSites);
        if(useV3HP(urlUtil)){
            paymentMethodURL = 'manage_payment_sources';
        }        
        string endpointURL = urlUtil.getUrl()+'/api/v2/hosted_pages/';
        endpointURL += paymentMethodURL;
        system.debug(endpointURL);
        String bodyData = '';
        
            bodyData = CBURLUtil.buildURLString(bodyData, 'customer[id]', existingConSite[0].chargebeeapps__External_Id__c);
            system.debug('BODY:'+bodyData);
        
        
        try {
            responseFromNet = CBURLUtil.sendRequest(endpointURL, bodyData, urlUtil, true);
            system.debug('Response:'+responseFromNet);
        }
        catch(Exception exp){
            System.debug('exception '+exp);
            responseFromNet = 'exception '+exp;
            response = 'error';
        }
      system.debug('response1:'+responseFromNet);
        link = CBURLUtil.getValueFromResponse(responseFromNet, 'url');
      system.debug('link:'+responseFromNet);
        if(link == null){
            response = responseFromNet;
        }
  }
  
  public PageReference redirectToError(String err,String obj){
       PageReference pageRef = new PageReference('/apex/error');
       pageRef.getParameters().put('err',err);
       pageRef.getParameters().put('obj',obj);
       pageRef.setRedirect(true);
       return pageRef; 
    }
  
  public UpdatePaymentMethod(){
      isMultiSite=CBURLUtil.isMultiSite();
        
      if(isMultiSite)
        {           
            system.debug(isMultiSite);
             
        }
    urlUtil = new CBURLUtil(selectedSites);
    String cus_id = ApexPages.currentPage().getParameters().get('id');
    String flag = ApexPages.currentPage().getParameters().get('immediate');
    now=false;
    if(flag!=null){
        now = Boolean.valueOf(ApexPages.currentPage().getParameters().get('immediate'));
    }
        

    system.debug('now---'+now);
    
    cus_id = String.escapeSingleQuotes(cus_id);
    String que = 'select Name,LastName, FirstName,Email, AccountId, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, chargebeeapps__Auto_collection__c, chargebeeapps__External_Id__c from contact where id=\''+cus_id+'\'';
    //cont = [select Name,LastName, FirstName,Email, AccountId, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Auto_collection__c, External_Id__c from contact where id=:cus_id];   
    cont = Database.query(que);
    if(cont.AccountId != null)
    {
        
        acct = [select Name from Account where id=:cont.AccountId];
    }
    subject = 'Update your payment method';
    email = cont.email;
    pre_message = 'Dear '+cont.name+',\n\nPlease use the secure link below (valid for 5 hours) to update your payment method: \n\n';
    post_message = '\n\nIf you run into any issues, please contact us. \n\nThank you.';
    String link = null;
  }
  
}